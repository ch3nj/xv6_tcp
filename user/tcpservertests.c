#include "kernel/types.h"
#include "kernel/net.h"
#include "kernel/stat.h"
#include "user/user.h"

//
// port 25600
//
static void
echo(uint16 sport, uint64 echoes)
{
  int fd;

  printf("listen, %d\n", sport);
  if((fd = listen(sport)) < 0){
    fprintf(2, "ping: listen() failed\n");
    exit(1);
  }


  for (int i = 0; i < echoes; ++i) {
    // printf("read\n");
    char ibuf[128];
    int cc = read(fd, ibuf, sizeof(ibuf));
    if(cc < 0){
      fprintf(2, "echo: recv() failed\n");
      exit(1);
    }

    printf("echoing %s, len: %d\n", ibuf, cc);
    if(write(fd, ibuf, cc) < 0){
      fprintf(2, "echo: send() failed\n");
      exit(1);
    }
  }

  sleep(5);
  close(fd);
}


int
main(int argc, char *argv[])
{
  // int ret;
  // int i;
  uint16 dport = NET_TESTS_PORT;

  printf("nettests running on port %d\n", dport);

  printf("testing listen: ");
  echo(25600, 100);
  printf("OK\n");

  exit(0);
}
