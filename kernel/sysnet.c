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

#define SOCK_TYPE_UDP 0
#define SOCK_TYPE_TCP 1

struct sock {
  struct sock *next; // the next socket in the list
  uint32 raddr;      // the remote IPv4 address
  uint16 lport;      // the local port number
  uint16 rport;      // the remote port number
  uint8 type;        // 0 for UDP, 1 for TCP
  struct spinlock lock; // protects the rxq
  struct mbufq rxq;  // a queue of packets waiting to be received
};

static struct spinlock lock;
static struct sock *sockets;

void
sockinit(void)
{
  initlock(&lock, "socktbl");
}

int
sockalloc(struct file **f, uint32 raddr, uint16 lport, uint16 rport, uint8 type)
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
      goto bad;
    }
    pos = pos->next;
  }
  si->next = sockets;
  sockets = si;
  release(&lock);
  return 0;

bad:
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
    while(pos->next) {
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
  if (si->type == SOCK_TYPE_UDP) {
    struct mbuf *m;
    struct proc *pr = myproc();

    acquire(&si->lock);
    m = mbufalloc(MBUF_DEFAULT_HEADROOM);

    if (copyin(pr->pagetable, mbufput(m, n), addr, n) == -1) {
      release(&si->lock);
      return -1;
    }
    net_tx_udp(m, si->raddr ,si->lport, si->rport);
    release(&si->lock);
    return n;
  }

}

int
sockread(struct sock *si, uint64 addr, int n) {
  if (si->type == SOCK_TYPE_UDP) {
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
sockrecvtcp(struct mbuf *m, uint32 raddr, uint16 lport, uint16 rport) {
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
