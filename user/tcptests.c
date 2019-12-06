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
  dst = (10 << 24) | (0 << 16) | (2 << 8) | (15 << 0);

  // you can send a UDP packet to any Internet address
  // by using a different dst.
  printf("hi1, %d, %d, %d\n", dst, sport, dport);
  if((fd = connect(dst, sport, dport, SOCK_TYPE_TCP_CLIENT)) < 0){
    fprintf(2, "ping: connect() failed\n");
    exit(1);
  }

  for (int i = 0; i < attempts; ++i) {
    printf("hi2\n");
    if(write(fd, obuf, sizeof(obuf)) < 0){
      fprintf(2, "ping: send() failed\n");
      exit(1);
    }

    printf("hi3\n");
    char ibuf[128];
    int cc = read(fd, ibuf, sizeof(ibuf));
    if(cc < 0){
      fprintf(2, "ping: recv() failed\n");
      exit(1);
    }
    printf("got %d, %c\n", cc, ibuf[0]);
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
  ping(2000, dport, 100);
  printf("OK\n");

  // printf("testing multiple ping: ");
  // for (int i = 0; i < 100; ++i) {
  //   ping(2000, dport, 1);
  // }
  // printf("OK\n");

  exit(0);

}
