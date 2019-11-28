
user/_alloctest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test0>:
#include "kernel/fcntl.h"
#include "kernel/memlayout.h"
#include "user/user.h"

void
test0() {
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	0880                	addi	s0,sp,80
  enum { NCHILD = 50, NFD = 10};
  int i, j;
  int fd;

  printf("filetest: start\n");
  12:	00001517          	auipc	a0,0x1
  16:	9e650513          	addi	a0,a0,-1562 # 9f8 <malloc+0xe4>
  1a:	00001097          	auipc	ra,0x1
  1e:	83c080e7          	jalr	-1988(ra) # 856 <printf>
  22:	03200493          	li	s1,50
    printf("test setup is wrong\n");
    exit(1);
  }

  for (i = 0; i < NCHILD; i++) {
    int pid = fork();
  26:	00000097          	auipc	ra,0x0
  2a:	4a0080e7          	jalr	1184(ra) # 4c6 <fork>
    if(pid < 0){
  2e:	00054f63          	bltz	a0,4c <test0+0x4c>
      printf("fork failed");
      exit(1);
    }
    if(pid == 0){
  32:	c915                	beqz	a0,66 <test0+0x66>
  for (i = 0; i < NCHILD; i++) {
  34:	34fd                	addiw	s1,s1,-1
  36:	f8e5                	bnez	s1,26 <test0+0x26>
  38:	03200493          	li	s1,50
      sleep(10);
      exit(0);  // no errors; exit with 0.
    }
  }

  int all_ok = 1;
  3c:	4905                	li	s2,1
  for(int i = 0; i < NCHILD; i++){
    int xstatus;
    wait(&xstatus);
    if(xstatus != 0) {
      if(all_ok == 1)
  3e:	4985                	li	s3,1
        printf("filetest: FAILED\n");
  40:	00001a97          	auipc	s5,0x1
  44:	9e8a8a93          	addi	s5,s5,-1560 # a28 <malloc+0x114>
      all_ok = 0;
  48:	4a01                	li	s4,0
  4a:	a0a5                	j	b2 <test0+0xb2>
      printf("fork failed");
  4c:	00001517          	auipc	a0,0x1
  50:	9c450513          	addi	a0,a0,-1596 # a10 <malloc+0xfc>
  54:	00001097          	auipc	ra,0x1
  58:	802080e7          	jalr	-2046(ra) # 856 <printf>
      exit(1);
  5c:	4505                	li	a0,1
  5e:	00000097          	auipc	ra,0x0
  62:	470080e7          	jalr	1136(ra) # 4ce <exit>
  66:	44a9                	li	s1,10
        if ((fd = open("README", O_RDONLY)) < 0) {
  68:	00001917          	auipc	s2,0x1
  6c:	9b890913          	addi	s2,s2,-1608 # a20 <malloc+0x10c>
  70:	4581                	li	a1,0
  72:	854a                	mv	a0,s2
  74:	00000097          	auipc	ra,0x0
  78:	49a080e7          	jalr	1178(ra) # 50e <open>
  7c:	00054e63          	bltz	a0,98 <test0+0x98>
      for(j = 0; j < NFD; j++) {
  80:	34fd                	addiw	s1,s1,-1
  82:	f4fd                	bnez	s1,70 <test0+0x70>
      sleep(10);
  84:	4529                	li	a0,10
  86:	00000097          	auipc	ra,0x0
  8a:	4d8080e7          	jalr	1240(ra) # 55e <sleep>
      exit(0);  // no errors; exit with 0.
  8e:	4501                	li	a0,0
  90:	00000097          	auipc	ra,0x0
  94:	43e080e7          	jalr	1086(ra) # 4ce <exit>
          exit(1);
  98:	4505                	li	a0,1
  9a:	00000097          	auipc	ra,0x0
  9e:	434080e7          	jalr	1076(ra) # 4ce <exit>
        printf("filetest: FAILED\n");
  a2:	8556                	mv	a0,s5
  a4:	00000097          	auipc	ra,0x0
  a8:	7b2080e7          	jalr	1970(ra) # 856 <printf>
      all_ok = 0;
  ac:	8952                	mv	s2,s4
  for(int i = 0; i < NCHILD; i++){
  ae:	34fd                	addiw	s1,s1,-1
  b0:	cc89                	beqz	s1,ca <test0+0xca>
    wait(&xstatus);
  b2:	fbc40513          	addi	a0,s0,-68
  b6:	00000097          	auipc	ra,0x0
  ba:	420080e7          	jalr	1056(ra) # 4d6 <wait>
    if(xstatus != 0) {
  be:	fbc42783          	lw	a5,-68(s0)
  c2:	d7f5                	beqz	a5,ae <test0+0xae>
      if(all_ok == 1)
  c4:	ff3915e3          	bne	s2,s3,ae <test0+0xae>
  c8:	bfe9                	j	a2 <test0+0xa2>
    }
  }

  if(all_ok)
  ca:	00091b63          	bnez	s2,e0 <test0+0xe0>
    printf("filetest: OK\n");
}
  ce:	60a6                	ld	ra,72(sp)
  d0:	6406                	ld	s0,64(sp)
  d2:	74e2                	ld	s1,56(sp)
  d4:	7942                	ld	s2,48(sp)
  d6:	79a2                	ld	s3,40(sp)
  d8:	7a02                	ld	s4,32(sp)
  da:	6ae2                	ld	s5,24(sp)
  dc:	6161                	addi	sp,sp,80
  de:	8082                	ret
    printf("filetest: OK\n");
  e0:	00001517          	auipc	a0,0x1
  e4:	96050513          	addi	a0,a0,-1696 # a40 <malloc+0x12c>
  e8:	00000097          	auipc	ra,0x0
  ec:	76e080e7          	jalr	1902(ra) # 856 <printf>
}
  f0:	bff9                	j	ce <test0+0xce>

00000000000000f2 <test1>:

// Allocate all free memory and count how it is
void test1()
{
  f2:	7139                	addi	sp,sp,-64
  f4:	fc06                	sd	ra,56(sp)
  f6:	f822                	sd	s0,48(sp)
  f8:	f426                	sd	s1,40(sp)
  fa:	f04a                	sd	s2,32(sp)
  fc:	ec4e                	sd	s3,24(sp)
  fe:	0080                	addi	s0,sp,64
  void *a;
  int tot = 0;
  char buf[1];
  int fds[2];
  
  printf("memtest: start\n");  
 100:	00001517          	auipc	a0,0x1
 104:	95050513          	addi	a0,a0,-1712 # a50 <malloc+0x13c>
 108:	00000097          	auipc	ra,0x0
 10c:	74e080e7          	jalr	1870(ra) # 856 <printf>
  if(pipe(fds) != 0){
 110:	fc040513          	addi	a0,s0,-64
 114:	00000097          	auipc	ra,0x0
 118:	3ca080e7          	jalr	970(ra) # 4de <pipe>
 11c:	e525                	bnez	a0,184 <test1+0x92>
 11e:	84aa                	mv	s1,a0
    printf("pipe() failed\n");
    exit(1);
  }
  int pid = fork();
 120:	00000097          	auipc	ra,0x0
 124:	3a6080e7          	jalr	934(ra) # 4c6 <fork>
  if(pid < 0){
 128:	06054b63          	bltz	a0,19e <test1+0xac>
    printf("fork failed");
    exit(1);
  }
  if(pid == 0){
 12c:	e959                	bnez	a0,1c2 <test1+0xd0>
      close(fds[0]);
 12e:	fc042503          	lw	a0,-64(s0)
 132:	00000097          	auipc	ra,0x0
 136:	3c4080e7          	jalr	964(ra) # 4f6 <close>
      while(1) {
        a = sbrk(PGSIZE);
        if (a == (char*)0xffffffffffffffffL)
 13a:	597d                	li	s2,-1
          exit(0);
        *(int *)(a+4) = 1;
 13c:	4485                	li	s1,1
        if (write(fds[1], "x", 1) != 1) {
 13e:	00001997          	auipc	s3,0x1
 142:	93298993          	addi	s3,s3,-1742 # a70 <malloc+0x15c>
        a = sbrk(PGSIZE);
 146:	6505                	lui	a0,0x1
 148:	00000097          	auipc	ra,0x0
 14c:	40e080e7          	jalr	1038(ra) # 556 <sbrk>
        if (a == (char*)0xffffffffffffffffL)
 150:	07250463          	beq	a0,s2,1b8 <test1+0xc6>
        *(int *)(a+4) = 1;
 154:	c144                	sw	s1,4(a0)
        if (write(fds[1], "x", 1) != 1) {
 156:	8626                	mv	a2,s1
 158:	85ce                	mv	a1,s3
 15a:	fc442503          	lw	a0,-60(s0)
 15e:	00000097          	auipc	ra,0x0
 162:	390080e7          	jalr	912(ra) # 4ee <write>
 166:	fe9500e3          	beq	a0,s1,146 <test1+0x54>
          printf("write failed");
 16a:	00001517          	auipc	a0,0x1
 16e:	90e50513          	addi	a0,a0,-1778 # a78 <malloc+0x164>
 172:	00000097          	auipc	ra,0x0
 176:	6e4080e7          	jalr	1764(ra) # 856 <printf>
          exit(1);
 17a:	4505                	li	a0,1
 17c:	00000097          	auipc	ra,0x0
 180:	352080e7          	jalr	850(ra) # 4ce <exit>
    printf("pipe() failed\n");
 184:	00001517          	auipc	a0,0x1
 188:	8dc50513          	addi	a0,a0,-1828 # a60 <malloc+0x14c>
 18c:	00000097          	auipc	ra,0x0
 190:	6ca080e7          	jalr	1738(ra) # 856 <printf>
    exit(1);
 194:	4505                	li	a0,1
 196:	00000097          	auipc	ra,0x0
 19a:	338080e7          	jalr	824(ra) # 4ce <exit>
    printf("fork failed");
 19e:	00001517          	auipc	a0,0x1
 1a2:	87250513          	addi	a0,a0,-1934 # a10 <malloc+0xfc>
 1a6:	00000097          	auipc	ra,0x0
 1aa:	6b0080e7          	jalr	1712(ra) # 856 <printf>
    exit(1);
 1ae:	4505                	li	a0,1
 1b0:	00000097          	auipc	ra,0x0
 1b4:	31e080e7          	jalr	798(ra) # 4ce <exit>
          exit(0);
 1b8:	4501                	li	a0,0
 1ba:	00000097          	auipc	ra,0x0
 1be:	314080e7          	jalr	788(ra) # 4ce <exit>
        }
      }
      exit(0);
  }
  close(fds[1]);
 1c2:	fc442503          	lw	a0,-60(s0)
 1c6:	00000097          	auipc	ra,0x0
 1ca:	330080e7          	jalr	816(ra) # 4f6 <close>
  while(1) {
      if (read(fds[0], buf, 1) != 1) {
 1ce:	4605                	li	a2,1
 1d0:	fc840593          	addi	a1,s0,-56
 1d4:	fc042503          	lw	a0,-64(s0)
 1d8:	00000097          	auipc	ra,0x0
 1dc:	30e080e7          	jalr	782(ra) # 4e6 <read>
 1e0:	4785                	li	a5,1
 1e2:	00f51463          	bne	a0,a5,1ea <test1+0xf8>
        break;
      } else {
        tot += 1;
 1e6:	2485                	addiw	s1,s1,1
      if (read(fds[0], buf, 1) != 1) {
 1e8:	b7dd                	j	1ce <test1+0xdc>
      }
  }
  //int n = (PHYSTOP-KERNBASE)/PGSIZE;
  //printf("allocated %d out of %d pages\n", tot, n);
  if(tot < 31950) {
 1ea:	67a1                	lui	a5,0x8
 1ec:	ccd78793          	addi	a5,a5,-819 # 7ccd <__global_pointer$+0x69cc>
 1f0:	0297ca63          	blt	a5,s1,224 <test1+0x132>
    printf("expected to allocate at least 31950, only got %d\n", tot);
 1f4:	85a6                	mv	a1,s1
 1f6:	00001517          	auipc	a0,0x1
 1fa:	89250513          	addi	a0,a0,-1902 # a88 <malloc+0x174>
 1fe:	00000097          	auipc	ra,0x0
 202:	658080e7          	jalr	1624(ra) # 856 <printf>
    printf("memtest: FAILED\n");  
 206:	00001517          	auipc	a0,0x1
 20a:	8ba50513          	addi	a0,a0,-1862 # ac0 <malloc+0x1ac>
 20e:	00000097          	auipc	ra,0x0
 212:	648080e7          	jalr	1608(ra) # 856 <printf>
  } else {
    printf("memtest: OK\n");  
  }
}
 216:	70e2                	ld	ra,56(sp)
 218:	7442                	ld	s0,48(sp)
 21a:	74a2                	ld	s1,40(sp)
 21c:	7902                	ld	s2,32(sp)
 21e:	69e2                	ld	s3,24(sp)
 220:	6121                	addi	sp,sp,64
 222:	8082                	ret
    printf("memtest: OK\n");  
 224:	00001517          	auipc	a0,0x1
 228:	8b450513          	addi	a0,a0,-1868 # ad8 <malloc+0x1c4>
 22c:	00000097          	auipc	ra,0x0
 230:	62a080e7          	jalr	1578(ra) # 856 <printf>
}
 234:	b7cd                	j	216 <test1+0x124>

0000000000000236 <main>:

int
main(int argc, char *argv[])
{
 236:	1141                	addi	sp,sp,-16
 238:	e406                	sd	ra,8(sp)
 23a:	e022                	sd	s0,0(sp)
 23c:	0800                	addi	s0,sp,16
  test0();
 23e:	00000097          	auipc	ra,0x0
 242:	dc2080e7          	jalr	-574(ra) # 0 <test0>
  test1();
 246:	00000097          	auipc	ra,0x0
 24a:	eac080e7          	jalr	-340(ra) # f2 <test1>
  exit(0);
 24e:	4501                	li	a0,0
 250:	00000097          	auipc	ra,0x0
 254:	27e080e7          	jalr	638(ra) # 4ce <exit>

0000000000000258 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 258:	1141                	addi	sp,sp,-16
 25a:	e422                	sd	s0,8(sp)
 25c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 25e:	87aa                	mv	a5,a0
 260:	0585                	addi	a1,a1,1
 262:	0785                	addi	a5,a5,1
 264:	fff5c703          	lbu	a4,-1(a1)
 268:	fee78fa3          	sb	a4,-1(a5)
 26c:	fb75                	bnez	a4,260 <strcpy+0x8>
    ;
  return os;
}
 26e:	6422                	ld	s0,8(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret

0000000000000274 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 274:	1141                	addi	sp,sp,-16
 276:	e422                	sd	s0,8(sp)
 278:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 27a:	00054783          	lbu	a5,0(a0)
 27e:	cb91                	beqz	a5,292 <strcmp+0x1e>
 280:	0005c703          	lbu	a4,0(a1)
 284:	00f71763          	bne	a4,a5,292 <strcmp+0x1e>
    p++, q++;
 288:	0505                	addi	a0,a0,1
 28a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 28c:	00054783          	lbu	a5,0(a0)
 290:	fbe5                	bnez	a5,280 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 292:	0005c503          	lbu	a0,0(a1)
}
 296:	40a7853b          	subw	a0,a5,a0
 29a:	6422                	ld	s0,8(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret

00000000000002a0 <strlen>:

uint
strlen(const char *s)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e422                	sd	s0,8(sp)
 2a4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2a6:	00054783          	lbu	a5,0(a0)
 2aa:	cf91                	beqz	a5,2c6 <strlen+0x26>
 2ac:	0505                	addi	a0,a0,1
 2ae:	87aa                	mv	a5,a0
 2b0:	4685                	li	a3,1
 2b2:	9e89                	subw	a3,a3,a0
 2b4:	00f6853b          	addw	a0,a3,a5
 2b8:	0785                	addi	a5,a5,1
 2ba:	fff7c703          	lbu	a4,-1(a5)
 2be:	fb7d                	bnez	a4,2b4 <strlen+0x14>
    ;
  return n;
}
 2c0:	6422                	ld	s0,8(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret
  for(n = 0; s[n]; n++)
 2c6:	4501                	li	a0,0
 2c8:	bfe5                	j	2c0 <strlen+0x20>

00000000000002ca <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e422                	sd	s0,8(sp)
 2ce:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2d0:	ce09                	beqz	a2,2ea <memset+0x20>
 2d2:	87aa                	mv	a5,a0
 2d4:	fff6071b          	addiw	a4,a2,-1
 2d8:	1702                	slli	a4,a4,0x20
 2da:	9301                	srli	a4,a4,0x20
 2dc:	0705                	addi	a4,a4,1
 2de:	972a                	add	a4,a4,a0
    cdst[i] = c;
 2e0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2e4:	0785                	addi	a5,a5,1
 2e6:	fee79de3          	bne	a5,a4,2e0 <memset+0x16>
  }
  return dst;
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret

00000000000002f0 <strchr>:

char*
strchr(const char *s, char c)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e422                	sd	s0,8(sp)
 2f4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2f6:	00054783          	lbu	a5,0(a0)
 2fa:	cb99                	beqz	a5,310 <strchr+0x20>
    if(*s == c)
 2fc:	00f58763          	beq	a1,a5,30a <strchr+0x1a>
  for(; *s; s++)
 300:	0505                	addi	a0,a0,1
 302:	00054783          	lbu	a5,0(a0)
 306:	fbfd                	bnez	a5,2fc <strchr+0xc>
      return (char*)s;
  return 0;
 308:	4501                	li	a0,0
}
 30a:	6422                	ld	s0,8(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret
  return 0;
 310:	4501                	li	a0,0
 312:	bfe5                	j	30a <strchr+0x1a>

0000000000000314 <gets>:

char*
gets(char *buf, int max)
{
 314:	711d                	addi	sp,sp,-96
 316:	ec86                	sd	ra,88(sp)
 318:	e8a2                	sd	s0,80(sp)
 31a:	e4a6                	sd	s1,72(sp)
 31c:	e0ca                	sd	s2,64(sp)
 31e:	fc4e                	sd	s3,56(sp)
 320:	f852                	sd	s4,48(sp)
 322:	f456                	sd	s5,40(sp)
 324:	f05a                	sd	s6,32(sp)
 326:	ec5e                	sd	s7,24(sp)
 328:	1080                	addi	s0,sp,96
 32a:	8baa                	mv	s7,a0
 32c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 32e:	892a                	mv	s2,a0
 330:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 332:	4aa9                	li	s5,10
 334:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 336:	89a6                	mv	s3,s1
 338:	2485                	addiw	s1,s1,1
 33a:	0344d863          	bge	s1,s4,36a <gets+0x56>
    cc = read(0, &c, 1);
 33e:	4605                	li	a2,1
 340:	faf40593          	addi	a1,s0,-81
 344:	4501                	li	a0,0
 346:	00000097          	auipc	ra,0x0
 34a:	1a0080e7          	jalr	416(ra) # 4e6 <read>
    if(cc < 1)
 34e:	00a05e63          	blez	a0,36a <gets+0x56>
    buf[i++] = c;
 352:	faf44783          	lbu	a5,-81(s0)
 356:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 35a:	01578763          	beq	a5,s5,368 <gets+0x54>
 35e:	0905                	addi	s2,s2,1
 360:	fd679be3          	bne	a5,s6,336 <gets+0x22>
  for(i=0; i+1 < max; ){
 364:	89a6                	mv	s3,s1
 366:	a011                	j	36a <gets+0x56>
 368:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 36a:	99de                	add	s3,s3,s7
 36c:	00098023          	sb	zero,0(s3)
  return buf;
}
 370:	855e                	mv	a0,s7
 372:	60e6                	ld	ra,88(sp)
 374:	6446                	ld	s0,80(sp)
 376:	64a6                	ld	s1,72(sp)
 378:	6906                	ld	s2,64(sp)
 37a:	79e2                	ld	s3,56(sp)
 37c:	7a42                	ld	s4,48(sp)
 37e:	7aa2                	ld	s5,40(sp)
 380:	7b02                	ld	s6,32(sp)
 382:	6be2                	ld	s7,24(sp)
 384:	6125                	addi	sp,sp,96
 386:	8082                	ret

0000000000000388 <stat>:

int
stat(const char *n, struct stat *st)
{
 388:	1101                	addi	sp,sp,-32
 38a:	ec06                	sd	ra,24(sp)
 38c:	e822                	sd	s0,16(sp)
 38e:	e426                	sd	s1,8(sp)
 390:	e04a                	sd	s2,0(sp)
 392:	1000                	addi	s0,sp,32
 394:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 396:	4581                	li	a1,0
 398:	00000097          	auipc	ra,0x0
 39c:	176080e7          	jalr	374(ra) # 50e <open>
  if(fd < 0)
 3a0:	02054563          	bltz	a0,3ca <stat+0x42>
 3a4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3a6:	85ca                	mv	a1,s2
 3a8:	00000097          	auipc	ra,0x0
 3ac:	17e080e7          	jalr	382(ra) # 526 <fstat>
 3b0:	892a                	mv	s2,a0
  close(fd);
 3b2:	8526                	mv	a0,s1
 3b4:	00000097          	auipc	ra,0x0
 3b8:	142080e7          	jalr	322(ra) # 4f6 <close>
  return r;
}
 3bc:	854a                	mv	a0,s2
 3be:	60e2                	ld	ra,24(sp)
 3c0:	6442                	ld	s0,16(sp)
 3c2:	64a2                	ld	s1,8(sp)
 3c4:	6902                	ld	s2,0(sp)
 3c6:	6105                	addi	sp,sp,32
 3c8:	8082                	ret
    return -1;
 3ca:	597d                	li	s2,-1
 3cc:	bfc5                	j	3bc <stat+0x34>

00000000000003ce <atoi>:

int
atoi(const char *s)
{
 3ce:	1141                	addi	sp,sp,-16
 3d0:	e422                	sd	s0,8(sp)
 3d2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3d4:	00054603          	lbu	a2,0(a0)
 3d8:	fd06079b          	addiw	a5,a2,-48
 3dc:	0ff7f793          	andi	a5,a5,255
 3e0:	4725                	li	a4,9
 3e2:	02f76963          	bltu	a4,a5,414 <atoi+0x46>
 3e6:	86aa                	mv	a3,a0
  n = 0;
 3e8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3ea:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3ec:	0685                	addi	a3,a3,1
 3ee:	0025179b          	slliw	a5,a0,0x2
 3f2:	9fa9                	addw	a5,a5,a0
 3f4:	0017979b          	slliw	a5,a5,0x1
 3f8:	9fb1                	addw	a5,a5,a2
 3fa:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3fe:	0006c603          	lbu	a2,0(a3)
 402:	fd06071b          	addiw	a4,a2,-48
 406:	0ff77713          	andi	a4,a4,255
 40a:	fee5f1e3          	bgeu	a1,a4,3ec <atoi+0x1e>
  return n;
}
 40e:	6422                	ld	s0,8(sp)
 410:	0141                	addi	sp,sp,16
 412:	8082                	ret
  n = 0;
 414:	4501                	li	a0,0
 416:	bfe5                	j	40e <atoi+0x40>

0000000000000418 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 418:	1141                	addi	sp,sp,-16
 41a:	e422                	sd	s0,8(sp)
 41c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 41e:	02b57663          	bgeu	a0,a1,44a <memmove+0x32>
    while(n-- > 0)
 422:	02c05163          	blez	a2,444 <memmove+0x2c>
 426:	fff6079b          	addiw	a5,a2,-1
 42a:	1782                	slli	a5,a5,0x20
 42c:	9381                	srli	a5,a5,0x20
 42e:	0785                	addi	a5,a5,1
 430:	97aa                	add	a5,a5,a0
  dst = vdst;
 432:	872a                	mv	a4,a0
      *dst++ = *src++;
 434:	0585                	addi	a1,a1,1
 436:	0705                	addi	a4,a4,1
 438:	fff5c683          	lbu	a3,-1(a1)
 43c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 440:	fee79ae3          	bne	a5,a4,434 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 444:	6422                	ld	s0,8(sp)
 446:	0141                	addi	sp,sp,16
 448:	8082                	ret
    dst += n;
 44a:	00c50733          	add	a4,a0,a2
    src += n;
 44e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 450:	fec05ae3          	blez	a2,444 <memmove+0x2c>
 454:	fff6079b          	addiw	a5,a2,-1
 458:	1782                	slli	a5,a5,0x20
 45a:	9381                	srli	a5,a5,0x20
 45c:	fff7c793          	not	a5,a5
 460:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 462:	15fd                	addi	a1,a1,-1
 464:	177d                	addi	a4,a4,-1
 466:	0005c683          	lbu	a3,0(a1)
 46a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 46e:	fee79ae3          	bne	a5,a4,462 <memmove+0x4a>
 472:	bfc9                	j	444 <memmove+0x2c>

0000000000000474 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 474:	1141                	addi	sp,sp,-16
 476:	e422                	sd	s0,8(sp)
 478:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 47a:	ca05                	beqz	a2,4aa <memcmp+0x36>
 47c:	fff6069b          	addiw	a3,a2,-1
 480:	1682                	slli	a3,a3,0x20
 482:	9281                	srli	a3,a3,0x20
 484:	0685                	addi	a3,a3,1
 486:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 488:	00054783          	lbu	a5,0(a0)
 48c:	0005c703          	lbu	a4,0(a1)
 490:	00e79863          	bne	a5,a4,4a0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 494:	0505                	addi	a0,a0,1
    p2++;
 496:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 498:	fed518e3          	bne	a0,a3,488 <memcmp+0x14>
  }
  return 0;
 49c:	4501                	li	a0,0
 49e:	a019                	j	4a4 <memcmp+0x30>
      return *p1 - *p2;
 4a0:	40e7853b          	subw	a0,a5,a4
}
 4a4:	6422                	ld	s0,8(sp)
 4a6:	0141                	addi	sp,sp,16
 4a8:	8082                	ret
  return 0;
 4aa:	4501                	li	a0,0
 4ac:	bfe5                	j	4a4 <memcmp+0x30>

00000000000004ae <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4ae:	1141                	addi	sp,sp,-16
 4b0:	e406                	sd	ra,8(sp)
 4b2:	e022                	sd	s0,0(sp)
 4b4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4b6:	00000097          	auipc	ra,0x0
 4ba:	f62080e7          	jalr	-158(ra) # 418 <memmove>
}
 4be:	60a2                	ld	ra,8(sp)
 4c0:	6402                	ld	s0,0(sp)
 4c2:	0141                	addi	sp,sp,16
 4c4:	8082                	ret

00000000000004c6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4c6:	4885                	li	a7,1
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <exit>:
.global exit
exit:
 li a7, SYS_exit
 4ce:	4889                	li	a7,2
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4d6:	488d                	li	a7,3
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4de:	4891                	li	a7,4
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <read>:
.global read
read:
 li a7, SYS_read
 4e6:	4895                	li	a7,5
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <write>:
.global write
write:
 li a7, SYS_write
 4ee:	48c1                	li	a7,16
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <close>:
.global close
close:
 li a7, SYS_close
 4f6:	48d5                	li	a7,21
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <kill>:
.global kill
kill:
 li a7, SYS_kill
 4fe:	4899                	li	a7,6
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <exec>:
.global exec
exec:
 li a7, SYS_exec
 506:	489d                	li	a7,7
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <open>:
.global open
open:
 li a7, SYS_open
 50e:	48bd                	li	a7,15
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 516:	48c5                	li	a7,17
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 51e:	48c9                	li	a7,18
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 526:	48a1                	li	a7,8
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <link>:
.global link
link:
 li a7, SYS_link
 52e:	48cd                	li	a7,19
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 536:	48d1                	li	a7,20
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 53e:	48a5                	li	a7,9
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <dup>:
.global dup
dup:
 li a7, SYS_dup
 546:	48a9                	li	a7,10
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 54e:	48ad                	li	a7,11
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 556:	48b1                	li	a7,12
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 55e:	48b5                	li	a7,13
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 566:	48b9                	li	a7,14
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <connect>:
.global connect
connect:
 li a7, SYS_connect
 56e:	48d9                	li	a7,22
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 576:	48dd                	li	a7,23
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 57e:	1101                	addi	sp,sp,-32
 580:	ec06                	sd	ra,24(sp)
 582:	e822                	sd	s0,16(sp)
 584:	1000                	addi	s0,sp,32
 586:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 58a:	4605                	li	a2,1
 58c:	fef40593          	addi	a1,s0,-17
 590:	00000097          	auipc	ra,0x0
 594:	f5e080e7          	jalr	-162(ra) # 4ee <write>
}
 598:	60e2                	ld	ra,24(sp)
 59a:	6442                	ld	s0,16(sp)
 59c:	6105                	addi	sp,sp,32
 59e:	8082                	ret

00000000000005a0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5a0:	7139                	addi	sp,sp,-64
 5a2:	fc06                	sd	ra,56(sp)
 5a4:	f822                	sd	s0,48(sp)
 5a6:	f426                	sd	s1,40(sp)
 5a8:	f04a                	sd	s2,32(sp)
 5aa:	ec4e                	sd	s3,24(sp)
 5ac:	0080                	addi	s0,sp,64
 5ae:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5b0:	c299                	beqz	a3,5b6 <printint+0x16>
 5b2:	0805c863          	bltz	a1,642 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5b6:	2581                	sext.w	a1,a1
  neg = 0;
 5b8:	4881                	li	a7,0
 5ba:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5be:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5c0:	2601                	sext.w	a2,a2
 5c2:	00000517          	auipc	a0,0x0
 5c6:	52e50513          	addi	a0,a0,1326 # af0 <digits>
 5ca:	883a                	mv	a6,a4
 5cc:	2705                	addiw	a4,a4,1
 5ce:	02c5f7bb          	remuw	a5,a1,a2
 5d2:	1782                	slli	a5,a5,0x20
 5d4:	9381                	srli	a5,a5,0x20
 5d6:	97aa                	add	a5,a5,a0
 5d8:	0007c783          	lbu	a5,0(a5)
 5dc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5e0:	0005879b          	sext.w	a5,a1
 5e4:	02c5d5bb          	divuw	a1,a1,a2
 5e8:	0685                	addi	a3,a3,1
 5ea:	fec7f0e3          	bgeu	a5,a2,5ca <printint+0x2a>
  if(neg)
 5ee:	00088b63          	beqz	a7,604 <printint+0x64>
    buf[i++] = '-';
 5f2:	fd040793          	addi	a5,s0,-48
 5f6:	973e                	add	a4,a4,a5
 5f8:	02d00793          	li	a5,45
 5fc:	fef70823          	sb	a5,-16(a4)
 600:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 604:	02e05863          	blez	a4,634 <printint+0x94>
 608:	fc040793          	addi	a5,s0,-64
 60c:	00e78933          	add	s2,a5,a4
 610:	fff78993          	addi	s3,a5,-1
 614:	99ba                	add	s3,s3,a4
 616:	377d                	addiw	a4,a4,-1
 618:	1702                	slli	a4,a4,0x20
 61a:	9301                	srli	a4,a4,0x20
 61c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 620:	fff94583          	lbu	a1,-1(s2)
 624:	8526                	mv	a0,s1
 626:	00000097          	auipc	ra,0x0
 62a:	f58080e7          	jalr	-168(ra) # 57e <putc>
  while(--i >= 0)
 62e:	197d                	addi	s2,s2,-1
 630:	ff3918e3          	bne	s2,s3,620 <printint+0x80>
}
 634:	70e2                	ld	ra,56(sp)
 636:	7442                	ld	s0,48(sp)
 638:	74a2                	ld	s1,40(sp)
 63a:	7902                	ld	s2,32(sp)
 63c:	69e2                	ld	s3,24(sp)
 63e:	6121                	addi	sp,sp,64
 640:	8082                	ret
    x = -xx;
 642:	40b005bb          	negw	a1,a1
    neg = 1;
 646:	4885                	li	a7,1
    x = -xx;
 648:	bf8d                	j	5ba <printint+0x1a>

000000000000064a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 64a:	7119                	addi	sp,sp,-128
 64c:	fc86                	sd	ra,120(sp)
 64e:	f8a2                	sd	s0,112(sp)
 650:	f4a6                	sd	s1,104(sp)
 652:	f0ca                	sd	s2,96(sp)
 654:	ecce                	sd	s3,88(sp)
 656:	e8d2                	sd	s4,80(sp)
 658:	e4d6                	sd	s5,72(sp)
 65a:	e0da                	sd	s6,64(sp)
 65c:	fc5e                	sd	s7,56(sp)
 65e:	f862                	sd	s8,48(sp)
 660:	f466                	sd	s9,40(sp)
 662:	f06a                	sd	s10,32(sp)
 664:	ec6e                	sd	s11,24(sp)
 666:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 668:	0005c903          	lbu	s2,0(a1)
 66c:	18090f63          	beqz	s2,80a <vprintf+0x1c0>
 670:	8aaa                	mv	s5,a0
 672:	8b32                	mv	s6,a2
 674:	00158493          	addi	s1,a1,1
  state = 0;
 678:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 67a:	02500a13          	li	s4,37
      if(c == 'd'){
 67e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 682:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 686:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 68a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 68e:	00000b97          	auipc	s7,0x0
 692:	462b8b93          	addi	s7,s7,1122 # af0 <digits>
 696:	a839                	j	6b4 <vprintf+0x6a>
        putc(fd, c);
 698:	85ca                	mv	a1,s2
 69a:	8556                	mv	a0,s5
 69c:	00000097          	auipc	ra,0x0
 6a0:	ee2080e7          	jalr	-286(ra) # 57e <putc>
 6a4:	a019                	j	6aa <vprintf+0x60>
    } else if(state == '%'){
 6a6:	01498f63          	beq	s3,s4,6c4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6aa:	0485                	addi	s1,s1,1
 6ac:	fff4c903          	lbu	s2,-1(s1)
 6b0:	14090d63          	beqz	s2,80a <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 6b4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6b8:	fe0997e3          	bnez	s3,6a6 <vprintf+0x5c>
      if(c == '%'){
 6bc:	fd479ee3          	bne	a5,s4,698 <vprintf+0x4e>
        state = '%';
 6c0:	89be                	mv	s3,a5
 6c2:	b7e5                	j	6aa <vprintf+0x60>
      if(c == 'd'){
 6c4:	05878063          	beq	a5,s8,704 <vprintf+0xba>
      } else if(c == 'l') {
 6c8:	05978c63          	beq	a5,s9,720 <vprintf+0xd6>
      } else if(c == 'x') {
 6cc:	07a78863          	beq	a5,s10,73c <vprintf+0xf2>
      } else if(c == 'p') {
 6d0:	09b78463          	beq	a5,s11,758 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6d4:	07300713          	li	a4,115
 6d8:	0ce78663          	beq	a5,a4,7a4 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6dc:	06300713          	li	a4,99
 6e0:	0ee78e63          	beq	a5,a4,7dc <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6e4:	11478863          	beq	a5,s4,7f4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6e8:	85d2                	mv	a1,s4
 6ea:	8556                	mv	a0,s5
 6ec:	00000097          	auipc	ra,0x0
 6f0:	e92080e7          	jalr	-366(ra) # 57e <putc>
        putc(fd, c);
 6f4:	85ca                	mv	a1,s2
 6f6:	8556                	mv	a0,s5
 6f8:	00000097          	auipc	ra,0x0
 6fc:	e86080e7          	jalr	-378(ra) # 57e <putc>
      }
      state = 0;
 700:	4981                	li	s3,0
 702:	b765                	j	6aa <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 704:	008b0913          	addi	s2,s6,8
 708:	4685                	li	a3,1
 70a:	4629                	li	a2,10
 70c:	000b2583          	lw	a1,0(s6)
 710:	8556                	mv	a0,s5
 712:	00000097          	auipc	ra,0x0
 716:	e8e080e7          	jalr	-370(ra) # 5a0 <printint>
 71a:	8b4a                	mv	s6,s2
      state = 0;
 71c:	4981                	li	s3,0
 71e:	b771                	j	6aa <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 720:	008b0913          	addi	s2,s6,8
 724:	4681                	li	a3,0
 726:	4629                	li	a2,10
 728:	000b2583          	lw	a1,0(s6)
 72c:	8556                	mv	a0,s5
 72e:	00000097          	auipc	ra,0x0
 732:	e72080e7          	jalr	-398(ra) # 5a0 <printint>
 736:	8b4a                	mv	s6,s2
      state = 0;
 738:	4981                	li	s3,0
 73a:	bf85                	j	6aa <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 73c:	008b0913          	addi	s2,s6,8
 740:	4681                	li	a3,0
 742:	4641                	li	a2,16
 744:	000b2583          	lw	a1,0(s6)
 748:	8556                	mv	a0,s5
 74a:	00000097          	auipc	ra,0x0
 74e:	e56080e7          	jalr	-426(ra) # 5a0 <printint>
 752:	8b4a                	mv	s6,s2
      state = 0;
 754:	4981                	li	s3,0
 756:	bf91                	j	6aa <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 758:	008b0793          	addi	a5,s6,8
 75c:	f8f43423          	sd	a5,-120(s0)
 760:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 764:	03000593          	li	a1,48
 768:	8556                	mv	a0,s5
 76a:	00000097          	auipc	ra,0x0
 76e:	e14080e7          	jalr	-492(ra) # 57e <putc>
  putc(fd, 'x');
 772:	85ea                	mv	a1,s10
 774:	8556                	mv	a0,s5
 776:	00000097          	auipc	ra,0x0
 77a:	e08080e7          	jalr	-504(ra) # 57e <putc>
 77e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 780:	03c9d793          	srli	a5,s3,0x3c
 784:	97de                	add	a5,a5,s7
 786:	0007c583          	lbu	a1,0(a5)
 78a:	8556                	mv	a0,s5
 78c:	00000097          	auipc	ra,0x0
 790:	df2080e7          	jalr	-526(ra) # 57e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 794:	0992                	slli	s3,s3,0x4
 796:	397d                	addiw	s2,s2,-1
 798:	fe0914e3          	bnez	s2,780 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 79c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7a0:	4981                	li	s3,0
 7a2:	b721                	j	6aa <vprintf+0x60>
        s = va_arg(ap, char*);
 7a4:	008b0993          	addi	s3,s6,8
 7a8:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 7ac:	02090163          	beqz	s2,7ce <vprintf+0x184>
        while(*s != 0){
 7b0:	00094583          	lbu	a1,0(s2)
 7b4:	c9a1                	beqz	a1,804 <vprintf+0x1ba>
          putc(fd, *s);
 7b6:	8556                	mv	a0,s5
 7b8:	00000097          	auipc	ra,0x0
 7bc:	dc6080e7          	jalr	-570(ra) # 57e <putc>
          s++;
 7c0:	0905                	addi	s2,s2,1
        while(*s != 0){
 7c2:	00094583          	lbu	a1,0(s2)
 7c6:	f9e5                	bnez	a1,7b6 <vprintf+0x16c>
        s = va_arg(ap, char*);
 7c8:	8b4e                	mv	s6,s3
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	bdf9                	j	6aa <vprintf+0x60>
          s = "(null)";
 7ce:	00000917          	auipc	s2,0x0
 7d2:	31a90913          	addi	s2,s2,794 # ae8 <malloc+0x1d4>
        while(*s != 0){
 7d6:	02800593          	li	a1,40
 7da:	bff1                	j	7b6 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7dc:	008b0913          	addi	s2,s6,8
 7e0:	000b4583          	lbu	a1,0(s6)
 7e4:	8556                	mv	a0,s5
 7e6:	00000097          	auipc	ra,0x0
 7ea:	d98080e7          	jalr	-616(ra) # 57e <putc>
 7ee:	8b4a                	mv	s6,s2
      state = 0;
 7f0:	4981                	li	s3,0
 7f2:	bd65                	j	6aa <vprintf+0x60>
        putc(fd, c);
 7f4:	85d2                	mv	a1,s4
 7f6:	8556                	mv	a0,s5
 7f8:	00000097          	auipc	ra,0x0
 7fc:	d86080e7          	jalr	-634(ra) # 57e <putc>
      state = 0;
 800:	4981                	li	s3,0
 802:	b565                	j	6aa <vprintf+0x60>
        s = va_arg(ap, char*);
 804:	8b4e                	mv	s6,s3
      state = 0;
 806:	4981                	li	s3,0
 808:	b54d                	j	6aa <vprintf+0x60>
    }
  }
}
 80a:	70e6                	ld	ra,120(sp)
 80c:	7446                	ld	s0,112(sp)
 80e:	74a6                	ld	s1,104(sp)
 810:	7906                	ld	s2,96(sp)
 812:	69e6                	ld	s3,88(sp)
 814:	6a46                	ld	s4,80(sp)
 816:	6aa6                	ld	s5,72(sp)
 818:	6b06                	ld	s6,64(sp)
 81a:	7be2                	ld	s7,56(sp)
 81c:	7c42                	ld	s8,48(sp)
 81e:	7ca2                	ld	s9,40(sp)
 820:	7d02                	ld	s10,32(sp)
 822:	6de2                	ld	s11,24(sp)
 824:	6109                	addi	sp,sp,128
 826:	8082                	ret

0000000000000828 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 828:	715d                	addi	sp,sp,-80
 82a:	ec06                	sd	ra,24(sp)
 82c:	e822                	sd	s0,16(sp)
 82e:	1000                	addi	s0,sp,32
 830:	e010                	sd	a2,0(s0)
 832:	e414                	sd	a3,8(s0)
 834:	e818                	sd	a4,16(s0)
 836:	ec1c                	sd	a5,24(s0)
 838:	03043023          	sd	a6,32(s0)
 83c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 840:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 844:	8622                	mv	a2,s0
 846:	00000097          	auipc	ra,0x0
 84a:	e04080e7          	jalr	-508(ra) # 64a <vprintf>
}
 84e:	60e2                	ld	ra,24(sp)
 850:	6442                	ld	s0,16(sp)
 852:	6161                	addi	sp,sp,80
 854:	8082                	ret

0000000000000856 <printf>:

void
printf(const char *fmt, ...)
{
 856:	711d                	addi	sp,sp,-96
 858:	ec06                	sd	ra,24(sp)
 85a:	e822                	sd	s0,16(sp)
 85c:	1000                	addi	s0,sp,32
 85e:	e40c                	sd	a1,8(s0)
 860:	e810                	sd	a2,16(s0)
 862:	ec14                	sd	a3,24(s0)
 864:	f018                	sd	a4,32(s0)
 866:	f41c                	sd	a5,40(s0)
 868:	03043823          	sd	a6,48(s0)
 86c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 870:	00840613          	addi	a2,s0,8
 874:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 878:	85aa                	mv	a1,a0
 87a:	4505                	li	a0,1
 87c:	00000097          	auipc	ra,0x0
 880:	dce080e7          	jalr	-562(ra) # 64a <vprintf>
}
 884:	60e2                	ld	ra,24(sp)
 886:	6442                	ld	s0,16(sp)
 888:	6125                	addi	sp,sp,96
 88a:	8082                	ret

000000000000088c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 88c:	1141                	addi	sp,sp,-16
 88e:	e422                	sd	s0,8(sp)
 890:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 892:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 896:	00000797          	auipc	a5,0x0
 89a:	2727b783          	ld	a5,626(a5) # b08 <freep>
 89e:	a805                	j	8ce <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8a0:	4618                	lw	a4,8(a2)
 8a2:	9db9                	addw	a1,a1,a4
 8a4:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a8:	6398                	ld	a4,0(a5)
 8aa:	6318                	ld	a4,0(a4)
 8ac:	fee53823          	sd	a4,-16(a0)
 8b0:	a091                	j	8f4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8b2:	ff852703          	lw	a4,-8(a0)
 8b6:	9e39                	addw	a2,a2,a4
 8b8:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8ba:	ff053703          	ld	a4,-16(a0)
 8be:	e398                	sd	a4,0(a5)
 8c0:	a099                	j	906 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c2:	6398                	ld	a4,0(a5)
 8c4:	00e7e463          	bltu	a5,a4,8cc <free+0x40>
 8c8:	00e6ea63          	bltu	a3,a4,8dc <free+0x50>
{
 8cc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ce:	fed7fae3          	bgeu	a5,a3,8c2 <free+0x36>
 8d2:	6398                	ld	a4,0(a5)
 8d4:	00e6e463          	bltu	a3,a4,8dc <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d8:	fee7eae3          	bltu	a5,a4,8cc <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8dc:	ff852583          	lw	a1,-8(a0)
 8e0:	6390                	ld	a2,0(a5)
 8e2:	02059713          	slli	a4,a1,0x20
 8e6:	9301                	srli	a4,a4,0x20
 8e8:	0712                	slli	a4,a4,0x4
 8ea:	9736                	add	a4,a4,a3
 8ec:	fae60ae3          	beq	a2,a4,8a0 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8f0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8f4:	4790                	lw	a2,8(a5)
 8f6:	02061713          	slli	a4,a2,0x20
 8fa:	9301                	srli	a4,a4,0x20
 8fc:	0712                	slli	a4,a4,0x4
 8fe:	973e                	add	a4,a4,a5
 900:	fae689e3          	beq	a3,a4,8b2 <free+0x26>
  } else
    p->s.ptr = bp;
 904:	e394                	sd	a3,0(a5)
  freep = p;
 906:	00000717          	auipc	a4,0x0
 90a:	20f73123          	sd	a5,514(a4) # b08 <freep>
}
 90e:	6422                	ld	s0,8(sp)
 910:	0141                	addi	sp,sp,16
 912:	8082                	ret

0000000000000914 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 914:	7139                	addi	sp,sp,-64
 916:	fc06                	sd	ra,56(sp)
 918:	f822                	sd	s0,48(sp)
 91a:	f426                	sd	s1,40(sp)
 91c:	f04a                	sd	s2,32(sp)
 91e:	ec4e                	sd	s3,24(sp)
 920:	e852                	sd	s4,16(sp)
 922:	e456                	sd	s5,8(sp)
 924:	e05a                	sd	s6,0(sp)
 926:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 928:	02051493          	slli	s1,a0,0x20
 92c:	9081                	srli	s1,s1,0x20
 92e:	04bd                	addi	s1,s1,15
 930:	8091                	srli	s1,s1,0x4
 932:	0014899b          	addiw	s3,s1,1
 936:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 938:	00000517          	auipc	a0,0x0
 93c:	1d053503          	ld	a0,464(a0) # b08 <freep>
 940:	c515                	beqz	a0,96c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 942:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 944:	4798                	lw	a4,8(a5)
 946:	02977f63          	bgeu	a4,s1,984 <malloc+0x70>
 94a:	8a4e                	mv	s4,s3
 94c:	0009871b          	sext.w	a4,s3
 950:	6685                	lui	a3,0x1
 952:	00d77363          	bgeu	a4,a3,958 <malloc+0x44>
 956:	6a05                	lui	s4,0x1
 958:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 95c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 960:	00000917          	auipc	s2,0x0
 964:	1a890913          	addi	s2,s2,424 # b08 <freep>
  if(p == (char*)-1)
 968:	5afd                	li	s5,-1
 96a:	a88d                	j	9dc <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 96c:	00000797          	auipc	a5,0x0
 970:	1a478793          	addi	a5,a5,420 # b10 <base>
 974:	00000717          	auipc	a4,0x0
 978:	18f73a23          	sd	a5,404(a4) # b08 <freep>
 97c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 97e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 982:	b7e1                	j	94a <malloc+0x36>
      if(p->s.size == nunits)
 984:	02e48b63          	beq	s1,a4,9ba <malloc+0xa6>
        p->s.size -= nunits;
 988:	4137073b          	subw	a4,a4,s3
 98c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 98e:	1702                	slli	a4,a4,0x20
 990:	9301                	srli	a4,a4,0x20
 992:	0712                	slli	a4,a4,0x4
 994:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 996:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 99a:	00000717          	auipc	a4,0x0
 99e:	16a73723          	sd	a0,366(a4) # b08 <freep>
      return (void*)(p + 1);
 9a2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9a6:	70e2                	ld	ra,56(sp)
 9a8:	7442                	ld	s0,48(sp)
 9aa:	74a2                	ld	s1,40(sp)
 9ac:	7902                	ld	s2,32(sp)
 9ae:	69e2                	ld	s3,24(sp)
 9b0:	6a42                	ld	s4,16(sp)
 9b2:	6aa2                	ld	s5,8(sp)
 9b4:	6b02                	ld	s6,0(sp)
 9b6:	6121                	addi	sp,sp,64
 9b8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9ba:	6398                	ld	a4,0(a5)
 9bc:	e118                	sd	a4,0(a0)
 9be:	bff1                	j	99a <malloc+0x86>
  hp->s.size = nu;
 9c0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9c4:	0541                	addi	a0,a0,16
 9c6:	00000097          	auipc	ra,0x0
 9ca:	ec6080e7          	jalr	-314(ra) # 88c <free>
  return freep;
 9ce:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9d2:	d971                	beqz	a0,9a6 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9d4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9d6:	4798                	lw	a4,8(a5)
 9d8:	fa9776e3          	bgeu	a4,s1,984 <malloc+0x70>
    if(p == freep)
 9dc:	00093703          	ld	a4,0(s2)
 9e0:	853e                	mv	a0,a5
 9e2:	fef719e3          	bne	a4,a5,9d4 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9e6:	8552                	mv	a0,s4
 9e8:	00000097          	auipc	ra,0x0
 9ec:	b6e080e7          	jalr	-1170(ra) # 556 <sbrk>
  if(p == (char*)-1)
 9f0:	fd5518e3          	bne	a0,s5,9c0 <malloc+0xac>
        return 0;
 9f4:	4501                	li	a0,0
 9f6:	bf45                	j	9a6 <malloc+0x92>
