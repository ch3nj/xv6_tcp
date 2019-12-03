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
  uint16 lport;      // the local UDP port number
  uint16 rport;      // the remote UDP port number
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
sockalloc(struct file **f, uint32 raddr, uint16 lport, uint16 rport)
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
  wakeup(&si->lport);
  pos = sockets;
  if (pos->raddr == si->raddr &&
      pos->lport == si->lport &&
  pos->rport == si->rport) {
    sockets = pos->next;
  } else {
    while(pos->next) {
      next = pos->next;
      if (next->raddr == si->raddr &&
          next->lport == si->lport &&
      next->rport == si->rport) {
        pos->next = next->next;
        break;
      }
    }
  }
  release(&lock);
  // clean up
  release(&si->lock);
  kfree((char*)si);

}

int
sockwrite(struct sock *si, uint64 addr, int n) {
  printf("calling sockwrite\n");
  struct mbuf *m;
  struct proc *pr = myproc();

  acquire(&si->lock);
  m = mbufalloc(MBUF_DEFAULT_HEADROOM);

  if (copyin(pr->pagetable, mbufput(m, n), addr, n) == -1) {
    release(&si->lock);
    return -1;
  }
  net_tx_udp(m, si->raddr ,si->lport, si->rport);
  // wakeup(&si->rxq);
  release(&si->lock);
  return n;
}

int
sockread(struct sock *si, uint64 addr, int n) {
  printf("sockread\n");
  struct mbuf *m;
  struct proc *pr = myproc();
  int i = n;

  acquire(&si->lock);
  printf("%p: acquired si lock\n", si);
  while(mbufq_empty(&si->rxq)) {
    if(myproc()->killed){
      release(&si->lock);
      return -1;
    }
    printf("%p: sleeping\n", si);
    sleep(&si->rxq, &si->lock);
    printf("%p: woken up\n", si);
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

  printf("%p: finish sockread for \n", si);
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
  printf("sockrecvudp\n");
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
    printf("%p: waking up\n", si);
    wakeup(&si->rxq);
    release(&si->lock);
    
  } else {
    mbuffree(m);
  }
}
