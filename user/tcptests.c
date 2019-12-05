#include "kernel/types.h"
#include "kernel/net.h"
#include "kernel/stat.h"
#include "user/user.h"

//
// port 2000
//
static void
ping(uint16 sport, uint16 dport, int attempts)
{
  int fd;
  char obuf[13] = "hello world!";
  uint32 dst;

  // 10.0.2.2, which qemu remaps to the external host,
  // i.e. the machine you're running qemu on.
  dst = (10 << 24) | (0 << 16) | (2 << 8) | (2 << 0);

  // you can send a UDP packet to any Internet address
  // by using a different dst.
  printf("hi1, %d, %d, %d\n", dst, sport, dport);
  if((fd = connect(dst, sport, dport, SOCK_TYPE_TCP_CLIENT)) < 0){
    fprintf(2, "ping: connect() failed\n");
    exit(1);
  }
  close(fd);
}

int
main(int argc, char *argv[])
{
  // int ret;
  // int i;
  uint16 dport = NET_TESTS_PORT;

  printf("nettests running on port %d\n", dport);

  printf("testing one ping: ");
  ping(2000, dport, 2);
  printf("OK\n");

  exit(0);

}
