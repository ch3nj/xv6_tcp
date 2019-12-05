//
// network system calls.
//

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "fs.h"
#include "sleeplock.h"
#include "file.h"
#include "net.h"

struct sock {
  struct sock *next; // the next socket in the list
  uint32 raddr;      // the remote IPv4 address
  uint16 lport;      // the local port number
  uint16 rport;      // the remote port number
  uint8 type;        // 0 for UDP, 1 for TCP
  struct spinlock lock; // protects the rxq
  struct mbufq rxq;  // a queue of packets waiting to be received
  struct tcp_state tcp; // unused for UDP
};

static struct spinlock lock;
static struct sock *sockets;

void
sockinit(void)
{
  initlock(&lock, "socktbl");
}

int
sockalloc(struct file **f, uint32 raddr, uint32 lport, uint32 rport, uint32 type)
{
  struct sock *si, *pos;

  si = 0;
  *f = 0;
  if ((*f = filealloc()) == 0)
    goto bad;
  if ((si = (struct sock*)kalloc()) == 0)
    goto bad;

  // initialize objects
  si->raddr = raddr;
  si->lport = lport;
  si->rport = rport;
  si->type = type;
  initlock(&si->lock, "sock");
  acquire(&si->lock);
  mbufq_init(&si->rxq);
  (*f)->type = FD_SOCK;
  (*f)->readable = 1;
  (*f)->writable = 1;
  (*f)->sock = si;
  // add to list of sockets
  acquire(&lock);
  pos = sockets;
  while (pos) {
    if (pos->raddr == raddr &&
        pos->lport == lport &&
	      pos->rport == rport) {
      release(&lock);
      release(&si->lock);
      goto bad;
    }
    pos = pos->next;
  }
  si->next = sockets;
  sockets = si;
  release(&lock);

  if (type == SOCK_TYPE_TCP_CLIENT || type == SOCK_TYPE_TCP_SERVER) {
    // create random initial sequence number
    // uint32 iss = rand() & 0xff;
    // iss |= (rand() & 0xff) << 8;
    // iss |= (rand() & 0xff) << 16;
    // iss |= (rand() & 0xff) << 24;
    uint32 iss = 0;
    si->tcp.iss = iss;
    si->tcp.snd_una = iss + 1;
    si->tcp.snd_nxt = iss + 1;
    si->tcp.rcv_wnd = TCP_WINDOW;
  }
  if (type == SOCK_TYPE_TCP_CLIENT) {
    si->tcp.state = TS_SEND_SYN;
    struct mbuf *m = mbufalloc(MBUF_DEFAULT_HEADROOM);
    net_tx_tcp(m, si->raddr, si->lport, si->rport, si->tcp);
    si->tcp.state = TS_SYN_SENT;
  }
  if (type == SOCK_TYPE_TCP_SERVER) {
    si->tcp.state = TS_LISTEN;
  }
  release(&si->lock);
  return 0;

bad:
  printf("bad alloc\n");
  if (si)
    kfree((char*)si);
  if (*f)
    fileclose(*f);
  return -1;
}

//
// Your code here.
//
// Add and wire in methods to handle closing, reading,
// and writing for network sockets.
//

void
sockclose(struct sock *si, int writable) {
  struct sock *pos, *next;
  acquire(&si->lock);


  // if tcp, do the closing dance
  if (si->type == SOCK_TYPE_TCP_CLIENT || si->type == SOCK_TYPE_TCP_SERVER) {
    if (si->tcp.state == TS_ESTAB) {
      si->tcp.state = TS_SEND_FIN;
      struct mbuf *m = mbufalloc(MBUF_DEFAULT_HEADROOM);
      net_tx_tcp(m, si->raddr, si->lport, si->rport, si->tcp);
      si->tcp.snd_nxt++; // fin takes 1 sequence num
      si->tcp.state = TS_FIN_W1;
      while (!(si->tcp.state == TS_TIME_W  ||
               si->tcp.state == TS_CLOSED)) {
        sleep(&si->tcp, &si->lock);
      }
    }
    if (si->tcp.state == TS_CLOSE_W) {
      si->tcp.state = TS_SEND_FIN;
      struct mbuf *m = mbufalloc(MBUF_DEFAULT_HEADROOM);
      net_tx_tcp(m, si->raddr, si->lport, si->rport, si->tcp);
      si->tcp.snd_nxt++; // fin takes 1 sequence num
      si->tcp.state = TS_LAST_ACK;
      while (si->tcp.state != TS_CLOSED) {
        sleep(&si->tcp, &si->lock);
      }
    }
  }

  // free outstanding mbufs
  while(!mbufq_empty(&si->rxq)) {
    mbuffree(mbufq_pophead(&si->rxq));
  }

  // remove from sockets
  acquire(&lock);
  wakeup(&si->rxq);
  pos = sockets;
  if (pos->raddr == si->raddr && pos->lport == si->lport && pos->rport == si->rport) {
    sockets = pos->next;
  } else {
    while(pos) {
      next = pos->next;
      if (next->raddr == si->raddr && next->lport == si->lport && next->rport == si->rport) {
        pos->next = next->next;
        break;
      }
      pos = pos->next;
    }
  }
  release(&lock);
  // clean up
  release(&si->lock);
  kfree((char*)si);
}

int
sockwrite(struct sock *si, uint64 addr, int n) {
  struct mbuf *m;
  struct proc *pr = myproc();

  acquire(&si->lock);
  m = mbufalloc(MBUF_DEFAULT_HEADROOM);

  if (copyin(pr->pagetable, mbufput(m, n), addr, n) == -1) {
    release(&si->lock);
    return -1;
  }
  printf("SOCKET TYPE: %d", si->type);
  if (si->type == SOCK_TYPE_UDP) {
    printf("going to udp");
    net_tx_udp(m, si->raddr, si->lport, si->rport);
  } else {
    while (si->tcp.state != TS_ESTAB) {
      sleep(&si->tcp, &si->lock);
    }
    net_tx_tcp(m, si->raddr, si->lport, si->rport, si->tcp);
    si->tcp.snd_nxt = si->tcp.snd_nxt + n;
  }
  release(&si->lock);
  return n;
}

int
sockread(struct sock *si, uint64 addr, int n) {
    struct mbuf *m;
    struct proc *pr = myproc();
    int i = n;

    acquire(&si->lock);
    while(mbufq_empty(&si->rxq)) {
      if(myproc()->killed){
        release(&si->lock);
        return -1;
      }
      sleep(&si->rxq, &si->lock);
    }

    m = mbufq_pophead(&si->rxq);
    release(&si->lock);

    if (n > m->len) {
      copyout(pr->pagetable, addr, m->head, m->len);
      i = m->len;
    } else {
      copyout(pr->pagetable, addr, m->head, n);
    }

    mbuffree(m);

    return i;

}

// called by protocol handler layer to deliver UDP packets
void
sockrecvudp(struct mbuf *m, uint32 raddr, uint16 lport, uint16 rport)
{
  //
  // Your code here.
  //
  // Find the socket that handles this mbuf and deliver it, waking
  // any sleeping reader. Free the mbuf if there are no sockets
  // registered to handle it.
  //
  struct sock *si;
  acquire(&lock);
  si = sockets;
  while(si) {
    if (si->raddr == raddr &&
        si->lport == lport &&
	si->rport == rport) {
      break;
    }
    si = si->next;
  }
  // printf("%p", si);
  release(&lock);
  if (si) {
    acquire(&si->lock);
    mbufq_pushtail(&si->rxq, m);
    release(&si->lock);
    wakeup(&si->rxq);
  } else {
    mbuffree(m);
  }
}

void
sockrecvtcp(struct mbuf *m, uint32 raddr, uint16 lport, uint16 rport, struct tcp_info *info) {
  struct sock *si;
  struct tcp_state *state;

  acquire(&lock);
  si = sockets;
  while(si) {
    if (si->raddr == raddr &&
        si->lport == lport &&
	      si->rport == rport) {
      break;
    }
    if (si->lport == lport &&
        si->tcp.state == TS_LISTEN &&
        info->syn == 1) {
      break;
    }
    si = si->next;
  }
  // printf("%p", si);
  release(&lock);
  if (!si)
    goto dump;

  acquire(&si->lock);
  state = &si->tcp;
  switch (state->state)
  {
    case TS_SEND_SYN:
      wakeup(&si->tcp);
      goto dump;
      break;
    case TS_LISTEN:
      if (info->syn == 1 && info->ack == 0) {
        si->raddr = raddr;
        si->rport = rport;
        state->irs = info->seqnum;
        state->rcv_nxt = info->seqnum + 1; // TODO: + m->len
        state->snd_wnd = info->window;
        struct mbuf *emp = mbufalloc(MBUF_DEFAULT_HEADROOM);
        net_tx_tcp(emp, raddr, lport, rport, *state); // send syn-ack
        state->state = TS_SYN_RECV;
        wakeup(&si->tcp);
        goto dump; // TODO: if m->len > 0, deliver
      }
      goto dump;
      break;
    case TS_SYN_SENT:
      if (info->syn == 1 && info->ack == 1 && state->snd_una <= info->acknum) {
          state->snd_una = info->acknum;
          state->irs = info->seqnum;
          state->rcv_nxt = info->seqnum + 1; // TODO: + m->len
          state->snd_wnd = info->window;
          struct mbuf *emp = mbufalloc(MBUF_DEFAULT_HEADROOM);
          net_tx_tcp(emp, raddr, lport, rport, *state); // send an ack
          state->state = TS_ESTAB;
          wakeup(&si->tcp);
          goto dump; // TODO: if m->len > 0, deliver
          return;
        }
      break;
    case TS_SYN_RECV:
      if (info->syn == 0 && info->ack == 1 && state->snd_una <= info->acknum) {
          state->snd_una = info->acknum;
          state->rcv_nxt = info->seqnum; // TODO: + m->len
          state->snd_wnd = info->window;
          state->state = TS_ESTAB;
          wakeup(&si->tcp);
          goto dump; // TODO: if m->len > 0, deliver
          return;
        }
      break;
    case TS_ESTAB:
      if (info->syn == 0 && info->ack == 1) {
        //legal packet
        state->snd_una = info->acknum;
        state->rcv_nxt = info->seqnum; // TODO: + m->len
        state->snd_wnd = info->window;
        wakeup(&si->tcp);
        goto deliver;
      }
      goto dump;
      break;
    case TS_SEND_FIN:
      goto dump;
      break;
    case TS_FIN_W1:
      if (info->fin) {
        struct mbuf *emp = mbufalloc(MBUF_DEFAULT_HEADROOM);
        net_tx_tcp(emp, raddr, lport, rport, *state); // needs to send an ack
        if (info->ack && info->acknum == state->snd_nxt) {
          state->state = TS_TIME_W;
          wakeup(&si->tcp);
          goto dump;
        }
        state->state = TS_CLOSING;
        goto dump;
      }
      if (info->ack && info->acknum == state->snd_nxt) {
        state->state = TS_FIN_W2;
        goto dump;
      }
      break;
    case TS_FIN_W2:
      if (info->fin) {
        struct mbuf *emp = mbufalloc(MBUF_DEFAULT_HEADROOM);
        net_tx_tcp(emp, raddr, lport, rport, *state); // needs to send an ack
        state->state = TS_TIME_W;
        wakeup(&si->tcp);
        goto dump;
      }
      break;
    case TS_CLOSING:
      if (info->ack && info->acknum == state->snd_nxt) {
        state->state = TS_TIME_W;
        wakeup(&si->tcp);
        goto dump;
      }
      break;
    case TS_TIME_W:
      wakeup(&si->tcp);
      goto dump;
      break;
    case TS_CLOSE_W:
      goto dump;
      break;
    case TS_LAST_ACK:
      if (info->ack && info->acknum == state->snd_nxt) {
        state->state = TS_CLOSED;
        wakeup(&si->tcp);
        goto dump;
      }
      break;
    default:
      goto dump;
      break;
  }

deliver:
  mbufq_pushtail(&si->rxq, m);
  release(&si->lock);
  wakeup(&si->rxq);
  return;
dump:
  release(&si->lock);
  mbuffree(m);
}
