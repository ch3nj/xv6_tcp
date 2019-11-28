
user/_kalloctest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test0>:
  test1();
  exit(0);
}

void test0()
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  void *a, *a1;
  int n = 0;
  printf("start test0\n");  
   e:	00001517          	auipc	a0,0x1
  12:	a7250513          	addi	a0,a0,-1422 # a80 <malloc+0xea>
  16:	00001097          	auipc	ra,0x1
  1a:	8c2080e7          	jalr	-1854(ra) # 8d8 <printf>
  ntas(0);
  1e:	4501                	li	a0,0
  20:	00000097          	auipc	ra,0x0
  24:	5d8080e7          	jalr	1496(ra) # 5f8 <ntas>
  for(int i = 0; i < NCHILD; i++){
    int pid = fork();
  28:	00000097          	auipc	ra,0x0
  2c:	520080e7          	jalr	1312(ra) # 548 <fork>
    if(pid < 0){
  30:	06054363          	bltz	a0,96 <test0+0x96>
      printf("fork failed");
      exit(-1);
    }
    if(pid == 0){
  34:	cd35                	beqz	a0,b0 <test0+0xb0>
    int pid = fork();
  36:	00000097          	auipc	ra,0x0
  3a:	512080e7          	jalr	1298(ra) # 548 <fork>
    if(pid < 0){
  3e:	04054c63          	bltz	a0,96 <test0+0x96>
    if(pid == 0){
  42:	c53d                	beqz	a0,b0 <test0+0xb0>
      exit(-1);
    }
  }

  for(int i = 0; i < NCHILD; i++){
    wait(0);
  44:	4501                	li	a0,0
  46:	00000097          	auipc	ra,0x0
  4a:	512080e7          	jalr	1298(ra) # 558 <wait>
  4e:	4501                	li	a0,0
  50:	00000097          	auipc	ra,0x0
  54:	508080e7          	jalr	1288(ra) # 558 <wait>
  }
  printf("test0 results:\n");
  58:	00001517          	auipc	a0,0x1
  5c:	a5850513          	addi	a0,a0,-1448 # ab0 <malloc+0x11a>
  60:	00001097          	auipc	ra,0x1
  64:	878080e7          	jalr	-1928(ra) # 8d8 <printf>
  n = ntas(1);
  68:	4505                	li	a0,1
  6a:	00000097          	auipc	ra,0x0
  6e:	58e080e7          	jalr	1422(ra) # 5f8 <ntas>
  if(n < 10) 
  72:	47a5                	li	a5,9
  74:	08a7c863          	blt	a5,a0,104 <test0+0x104>
    printf("test0 OK\n");
  78:	00001517          	auipc	a0,0x1
  7c:	a4850513          	addi	a0,a0,-1464 # ac0 <malloc+0x12a>
  80:	00001097          	auipc	ra,0x1
  84:	858080e7          	jalr	-1960(ra) # 8d8 <printf>
  else
    printf("test0 FAIL\n");
}
  88:	70a2                	ld	ra,40(sp)
  8a:	7402                	ld	s0,32(sp)
  8c:	64e2                	ld	s1,24(sp)
  8e:	6942                	ld	s2,16(sp)
  90:	69a2                	ld	s3,8(sp)
  92:	6145                	addi	sp,sp,48
  94:	8082                	ret
      printf("fork failed");
  96:	00001517          	auipc	a0,0x1
  9a:	9fa50513          	addi	a0,a0,-1542 # a90 <malloc+0xfa>
  9e:	00001097          	auipc	ra,0x1
  a2:	83a080e7          	jalr	-1990(ra) # 8d8 <printf>
      exit(-1);
  a6:	557d                	li	a0,-1
  a8:	00000097          	auipc	ra,0x0
  ac:	4a8080e7          	jalr	1192(ra) # 550 <exit>
{
  b0:	6961                	lui	s2,0x18
  b2:	6a090913          	addi	s2,s2,1696 # 186a0 <__global_pointer$+0x172f7>
        *(int *)(a+4) = 1;
  b6:	4985                	li	s3,1
        a = sbrk(4096);
  b8:	6505                	lui	a0,0x1
  ba:	00000097          	auipc	ra,0x0
  be:	51e080e7          	jalr	1310(ra) # 5d8 <sbrk>
  c2:	84aa                	mv	s1,a0
        *(int *)(a+4) = 1;
  c4:	01352223          	sw	s3,4(a0) # 1004 <__BSS_END__+0x43c>
        a1 = sbrk(-4096);
  c8:	757d                	lui	a0,0xfffff
  ca:	00000097          	auipc	ra,0x0
  ce:	50e080e7          	jalr	1294(ra) # 5d8 <sbrk>
        if (a1 != a + 4096) {
  d2:	6785                	lui	a5,0x1
  d4:	94be                	add	s1,s1,a5
  d6:	00951a63          	bne	a0,s1,ea <test0+0xea>
      for(i = 0; i < N; i++) {
  da:	397d                	addiw	s2,s2,-1
  dc:	fc091ee3          	bnez	s2,b8 <test0+0xb8>
      exit(-1);
  e0:	557d                	li	a0,-1
  e2:	00000097          	auipc	ra,0x0
  e6:	46e080e7          	jalr	1134(ra) # 550 <exit>
          printf("wrong sbrk\n");
  ea:	00001517          	auipc	a0,0x1
  ee:	9b650513          	addi	a0,a0,-1610 # aa0 <malloc+0x10a>
  f2:	00000097          	auipc	ra,0x0
  f6:	7e6080e7          	jalr	2022(ra) # 8d8 <printf>
          exit(-1);
  fa:	557d                	li	a0,-1
  fc:	00000097          	auipc	ra,0x0
 100:	454080e7          	jalr	1108(ra) # 550 <exit>
    printf("test0 FAIL\n");
 104:	00001517          	auipc	a0,0x1
 108:	9cc50513          	addi	a0,a0,-1588 # ad0 <malloc+0x13a>
 10c:	00000097          	auipc	ra,0x0
 110:	7cc080e7          	jalr	1996(ra) # 8d8 <printf>
}
 114:	bf95                	j	88 <test0+0x88>

0000000000000116 <test1>:

// Run system out of memory and count tot memory allocated
void test1()
{
 116:	715d                	addi	sp,sp,-80
 118:	e486                	sd	ra,72(sp)
 11a:	e0a2                	sd	s0,64(sp)
 11c:	fc26                	sd	s1,56(sp)
 11e:	f84a                	sd	s2,48(sp)
 120:	f44e                	sd	s3,40(sp)
 122:	0880                	addi	s0,sp,80
  void *a;
  int pipes[NCHILD];
  int tot = 0;
  char buf[1];
  
  printf("start test1\n");  
 124:	00001517          	auipc	a0,0x1
 128:	9bc50513          	addi	a0,a0,-1604 # ae0 <malloc+0x14a>
 12c:	00000097          	auipc	ra,0x0
 130:	7ac080e7          	jalr	1964(ra) # 8d8 <printf>
  for(int i = 0; i < NCHILD; i++){
 134:	fc840913          	addi	s2,s0,-56
    int fds[2];
    if(pipe(fds) != 0){
 138:	fb840513          	addi	a0,s0,-72
 13c:	00000097          	auipc	ra,0x0
 140:	424080e7          	jalr	1060(ra) # 560 <pipe>
 144:	84aa                	mv	s1,a0
 146:	e905                	bnez	a0,176 <test1+0x60>
      printf("pipe() failed\n");
      exit(-1);
    }
    int pid = fork();
 148:	00000097          	auipc	ra,0x0
 14c:	400080e7          	jalr	1024(ra) # 548 <fork>
    if(pid < 0){
 150:	04054063          	bltz	a0,190 <test1+0x7a>
      printf("fork failed");
      exit(-1);
    }
    if(pid == 0){
 154:	c939                	beqz	a0,1aa <test1+0x94>
          exit(-1);
        }
      }
      exit(0);
    } else {
      close(fds[1]);
 156:	fbc42503          	lw	a0,-68(s0)
 15a:	00000097          	auipc	ra,0x0
 15e:	41e080e7          	jalr	1054(ra) # 578 <close>
      pipes[i] = fds[0];
 162:	fb842783          	lw	a5,-72(s0)
 166:	00f92023          	sw	a5,0(s2)
  for(int i = 0; i < NCHILD; i++){
 16a:	0911                	addi	s2,s2,4
 16c:	fd040793          	addi	a5,s0,-48
 170:	fd2794e3          	bne	a5,s2,138 <test1+0x22>
 174:	a85d                	j	22a <test1+0x114>
      printf("pipe() failed\n");
 176:	00001517          	auipc	a0,0x1
 17a:	97a50513          	addi	a0,a0,-1670 # af0 <malloc+0x15a>
 17e:	00000097          	auipc	ra,0x0
 182:	75a080e7          	jalr	1882(ra) # 8d8 <printf>
      exit(-1);
 186:	557d                	li	a0,-1
 188:	00000097          	auipc	ra,0x0
 18c:	3c8080e7          	jalr	968(ra) # 550 <exit>
      printf("fork failed");
 190:	00001517          	auipc	a0,0x1
 194:	90050513          	addi	a0,a0,-1792 # a90 <malloc+0xfa>
 198:	00000097          	auipc	ra,0x0
 19c:	740080e7          	jalr	1856(ra) # 8d8 <printf>
      exit(-1);
 1a0:	557d                	li	a0,-1
 1a2:	00000097          	auipc	ra,0x0
 1a6:	3ae080e7          	jalr	942(ra) # 550 <exit>
      close(fds[0]);
 1aa:	fb842503          	lw	a0,-72(s0)
 1ae:	00000097          	auipc	ra,0x0
 1b2:	3ca080e7          	jalr	970(ra) # 578 <close>
 1b6:	64e1                	lui	s1,0x18
 1b8:	6a048493          	addi	s1,s1,1696 # 186a0 <__global_pointer$+0x172f7>
        *(int *)(a+4) = 1;
 1bc:	4905                	li	s2,1
        if (write(fds[1], "x", 1) != 1) {
 1be:	00001997          	auipc	s3,0x1
 1c2:	94298993          	addi	s3,s3,-1726 # b00 <malloc+0x16a>
        a = sbrk(PGSIZE);
 1c6:	6505                	lui	a0,0x1
 1c8:	00000097          	auipc	ra,0x0
 1cc:	410080e7          	jalr	1040(ra) # 5d8 <sbrk>
        *(int *)(a+4) = 1;
 1d0:	01252223          	sw	s2,4(a0) # 1004 <__BSS_END__+0x43c>
        if (write(fds[1], "x", 1) != 1) {
 1d4:	864a                	mv	a2,s2
 1d6:	85ce                	mv	a1,s3
 1d8:	fbc42503          	lw	a0,-68(s0)
 1dc:	00000097          	auipc	ra,0x0
 1e0:	394080e7          	jalr	916(ra) # 570 <write>
 1e4:	01251963          	bne	a0,s2,1f6 <test1+0xe0>
      for(i = 0; i < N; i++) {
 1e8:	34fd                	addiw	s1,s1,-1
 1ea:	fcf1                	bnez	s1,1c6 <test1+0xb0>
      exit(0);
 1ec:	4501                	li	a0,0
 1ee:	00000097          	auipc	ra,0x0
 1f2:	362080e7          	jalr	866(ra) # 550 <exit>
          printf("write failed");
 1f6:	00001517          	auipc	a0,0x1
 1fa:	91250513          	addi	a0,a0,-1774 # b08 <malloc+0x172>
 1fe:	00000097          	auipc	ra,0x0
 202:	6da080e7          	jalr	1754(ra) # 8d8 <printf>
          exit(-1);
 206:	557d                	li	a0,-1
 208:	00000097          	auipc	ra,0x0
 20c:	348080e7          	jalr	840(ra) # 550 <exit>
  int stop = 0;
  while (!stop) {
    stop = 1;
    for(int i = 0; i < NCHILD; i++){
      if (read(pipes[i], buf, 1) == 1) {
        tot += 1;
 210:	2485                	addiw	s1,s1,1
      if (read(pipes[i], buf, 1) == 1) {
 212:	4605                	li	a2,1
 214:	fc040593          	addi	a1,s0,-64
 218:	fcc42503          	lw	a0,-52(s0)
 21c:	00000097          	auipc	ra,0x0
 220:	34c080e7          	jalr	844(ra) # 568 <read>
 224:	4785                	li	a5,1
 226:	02f50a63          	beq	a0,a5,25a <test1+0x144>
 22a:	4605                	li	a2,1
 22c:	fc040593          	addi	a1,s0,-64
 230:	fc842503          	lw	a0,-56(s0)
 234:	00000097          	auipc	ra,0x0
 238:	334080e7          	jalr	820(ra) # 568 <read>
 23c:	4785                	li	a5,1
 23e:	fcf509e3          	beq	a0,a5,210 <test1+0xfa>
 242:	4605                	li	a2,1
 244:	fc040593          	addi	a1,s0,-64
 248:	fcc42503          	lw	a0,-52(s0)
 24c:	00000097          	auipc	ra,0x0
 250:	31c080e7          	jalr	796(ra) # 568 <read>
 254:	4785                	li	a5,1
 256:	02f51163          	bne	a0,a5,278 <test1+0x162>
        tot += 1;
 25a:	2485                	addiw	s1,s1,1
  while (!stop) {
 25c:	b7f9                	j	22a <test1+0x114>
    }
  }
  int n = (PHYSTOP-KERNBASE)/PGSIZE;
  printf("total allocated number of pages: %d (out of %d)\n", tot, n);
  if(n - tot > 1000) {
    printf("test1 FAILED: cannot allocate enough memory");
 25e:	00001517          	auipc	a0,0x1
 262:	8ba50513          	addi	a0,a0,-1862 # b18 <malloc+0x182>
 266:	00000097          	auipc	ra,0x0
 26a:	672080e7          	jalr	1650(ra) # 8d8 <printf>
    exit(-1);
 26e:	557d                	li	a0,-1
 270:	00000097          	auipc	ra,0x0
 274:	2e0080e7          	jalr	736(ra) # 550 <exit>
  printf("total allocated number of pages: %d (out of %d)\n", tot, n);
 278:	6621                	lui	a2,0x8
 27a:	85a6                	mv	a1,s1
 27c:	00001517          	auipc	a0,0x1
 280:	8dc50513          	addi	a0,a0,-1828 # b58 <malloc+0x1c2>
 284:	00000097          	auipc	ra,0x0
 288:	654080e7          	jalr	1620(ra) # 8d8 <printf>
  if(n - tot > 1000) {
 28c:	67a1                	lui	a5,0x8
 28e:	409784bb          	subw	s1,a5,s1
 292:	3e800793          	li	a5,1000
 296:	fc97c4e3          	blt	a5,s1,25e <test1+0x148>
  }
  printf("test1 OK\n");  
 29a:	00001517          	auipc	a0,0x1
 29e:	8ae50513          	addi	a0,a0,-1874 # b48 <malloc+0x1b2>
 2a2:	00000097          	auipc	ra,0x0
 2a6:	636080e7          	jalr	1590(ra) # 8d8 <printf>
}
 2aa:	60a6                	ld	ra,72(sp)
 2ac:	6406                	ld	s0,64(sp)
 2ae:	74e2                	ld	s1,56(sp)
 2b0:	7942                	ld	s2,48(sp)
 2b2:	79a2                	ld	s3,40(sp)
 2b4:	6161                	addi	sp,sp,80
 2b6:	8082                	ret

00000000000002b8 <main>:
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e406                	sd	ra,8(sp)
 2bc:	e022                	sd	s0,0(sp)
 2be:	0800                	addi	s0,sp,16
  test0();
 2c0:	00000097          	auipc	ra,0x0
 2c4:	d40080e7          	jalr	-704(ra) # 0 <test0>
  test1();
 2c8:	00000097          	auipc	ra,0x0
 2cc:	e4e080e7          	jalr	-434(ra) # 116 <test1>
  exit(0);
 2d0:	4501                	li	a0,0
 2d2:	00000097          	auipc	ra,0x0
 2d6:	27e080e7          	jalr	638(ra) # 550 <exit>

00000000000002da <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 2da:	1141                	addi	sp,sp,-16
 2dc:	e422                	sd	s0,8(sp)
 2de:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2e0:	87aa                	mv	a5,a0
 2e2:	0585                	addi	a1,a1,1
 2e4:	0785                	addi	a5,a5,1
 2e6:	fff5c703          	lbu	a4,-1(a1)
 2ea:	fee78fa3          	sb	a4,-1(a5) # 7fff <__global_pointer$+0x6c56>
 2ee:	fb75                	bnez	a4,2e2 <strcpy+0x8>
    ;
  return os;
}
 2f0:	6422                	ld	s0,8(sp)
 2f2:	0141                	addi	sp,sp,16
 2f4:	8082                	ret

00000000000002f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2f6:	1141                	addi	sp,sp,-16
 2f8:	e422                	sd	s0,8(sp)
 2fa:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2fc:	00054783          	lbu	a5,0(a0)
 300:	cb91                	beqz	a5,314 <strcmp+0x1e>
 302:	0005c703          	lbu	a4,0(a1)
 306:	00f71763          	bne	a4,a5,314 <strcmp+0x1e>
    p++, q++;
 30a:	0505                	addi	a0,a0,1
 30c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 30e:	00054783          	lbu	a5,0(a0)
 312:	fbe5                	bnez	a5,302 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 314:	0005c503          	lbu	a0,0(a1)
}
 318:	40a7853b          	subw	a0,a5,a0
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret

0000000000000322 <strlen>:

uint
strlen(const char *s)
{
 322:	1141                	addi	sp,sp,-16
 324:	e422                	sd	s0,8(sp)
 326:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 328:	00054783          	lbu	a5,0(a0)
 32c:	cf91                	beqz	a5,348 <strlen+0x26>
 32e:	0505                	addi	a0,a0,1
 330:	87aa                	mv	a5,a0
 332:	4685                	li	a3,1
 334:	9e89                	subw	a3,a3,a0
 336:	00f6853b          	addw	a0,a3,a5
 33a:	0785                	addi	a5,a5,1
 33c:	fff7c703          	lbu	a4,-1(a5)
 340:	fb7d                	bnez	a4,336 <strlen+0x14>
    ;
  return n;
}
 342:	6422                	ld	s0,8(sp)
 344:	0141                	addi	sp,sp,16
 346:	8082                	ret
  for(n = 0; s[n]; n++)
 348:	4501                	li	a0,0
 34a:	bfe5                	j	342 <strlen+0x20>

000000000000034c <memset>:

void*
memset(void *dst, int c, uint n)
{
 34c:	1141                	addi	sp,sp,-16
 34e:	e422                	sd	s0,8(sp)
 350:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 352:	ce09                	beqz	a2,36c <memset+0x20>
 354:	87aa                	mv	a5,a0
 356:	fff6071b          	addiw	a4,a2,-1
 35a:	1702                	slli	a4,a4,0x20
 35c:	9301                	srli	a4,a4,0x20
 35e:	0705                	addi	a4,a4,1
 360:	972a                	add	a4,a4,a0
    cdst[i] = c;
 362:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 366:	0785                	addi	a5,a5,1
 368:	fee79de3          	bne	a5,a4,362 <memset+0x16>
  }
  return dst;
}
 36c:	6422                	ld	s0,8(sp)
 36e:	0141                	addi	sp,sp,16
 370:	8082                	ret

0000000000000372 <strchr>:

char*
strchr(const char *s, char c)
{
 372:	1141                	addi	sp,sp,-16
 374:	e422                	sd	s0,8(sp)
 376:	0800                	addi	s0,sp,16
  for(; *s; s++)
 378:	00054783          	lbu	a5,0(a0)
 37c:	cb99                	beqz	a5,392 <strchr+0x20>
    if(*s == c)
 37e:	00f58763          	beq	a1,a5,38c <strchr+0x1a>
  for(; *s; s++)
 382:	0505                	addi	a0,a0,1
 384:	00054783          	lbu	a5,0(a0)
 388:	fbfd                	bnez	a5,37e <strchr+0xc>
      return (char*)s;
  return 0;
 38a:	4501                	li	a0,0
}
 38c:	6422                	ld	s0,8(sp)
 38e:	0141                	addi	sp,sp,16
 390:	8082                	ret
  return 0;
 392:	4501                	li	a0,0
 394:	bfe5                	j	38c <strchr+0x1a>

0000000000000396 <gets>:

char*
gets(char *buf, int max)
{
 396:	711d                	addi	sp,sp,-96
 398:	ec86                	sd	ra,88(sp)
 39a:	e8a2                	sd	s0,80(sp)
 39c:	e4a6                	sd	s1,72(sp)
 39e:	e0ca                	sd	s2,64(sp)
 3a0:	fc4e                	sd	s3,56(sp)
 3a2:	f852                	sd	s4,48(sp)
 3a4:	f456                	sd	s5,40(sp)
 3a6:	f05a                	sd	s6,32(sp)
 3a8:	ec5e                	sd	s7,24(sp)
 3aa:	1080                	addi	s0,sp,96
 3ac:	8baa                	mv	s7,a0
 3ae:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3b0:	892a                	mv	s2,a0
 3b2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3b4:	4aa9                	li	s5,10
 3b6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3b8:	89a6                	mv	s3,s1
 3ba:	2485                	addiw	s1,s1,1
 3bc:	0344d863          	bge	s1,s4,3ec <gets+0x56>
    cc = read(0, &c, 1);
 3c0:	4605                	li	a2,1
 3c2:	faf40593          	addi	a1,s0,-81
 3c6:	4501                	li	a0,0
 3c8:	00000097          	auipc	ra,0x0
 3cc:	1a0080e7          	jalr	416(ra) # 568 <read>
    if(cc < 1)
 3d0:	00a05e63          	blez	a0,3ec <gets+0x56>
    buf[i++] = c;
 3d4:	faf44783          	lbu	a5,-81(s0)
 3d8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3dc:	01578763          	beq	a5,s5,3ea <gets+0x54>
 3e0:	0905                	addi	s2,s2,1
 3e2:	fd679be3          	bne	a5,s6,3b8 <gets+0x22>
  for(i=0; i+1 < max; ){
 3e6:	89a6                	mv	s3,s1
 3e8:	a011                	j	3ec <gets+0x56>
 3ea:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3ec:	99de                	add	s3,s3,s7
 3ee:	00098023          	sb	zero,0(s3)
  return buf;
}
 3f2:	855e                	mv	a0,s7
 3f4:	60e6                	ld	ra,88(sp)
 3f6:	6446                	ld	s0,80(sp)
 3f8:	64a6                	ld	s1,72(sp)
 3fa:	6906                	ld	s2,64(sp)
 3fc:	79e2                	ld	s3,56(sp)
 3fe:	7a42                	ld	s4,48(sp)
 400:	7aa2                	ld	s5,40(sp)
 402:	7b02                	ld	s6,32(sp)
 404:	6be2                	ld	s7,24(sp)
 406:	6125                	addi	sp,sp,96
 408:	8082                	ret

000000000000040a <stat>:

int
stat(const char *n, struct stat *st)
{
 40a:	1101                	addi	sp,sp,-32
 40c:	ec06                	sd	ra,24(sp)
 40e:	e822                	sd	s0,16(sp)
 410:	e426                	sd	s1,8(sp)
 412:	e04a                	sd	s2,0(sp)
 414:	1000                	addi	s0,sp,32
 416:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 418:	4581                	li	a1,0
 41a:	00000097          	auipc	ra,0x0
 41e:	176080e7          	jalr	374(ra) # 590 <open>
  if(fd < 0)
 422:	02054563          	bltz	a0,44c <stat+0x42>
 426:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 428:	85ca                	mv	a1,s2
 42a:	00000097          	auipc	ra,0x0
 42e:	17e080e7          	jalr	382(ra) # 5a8 <fstat>
 432:	892a                	mv	s2,a0
  close(fd);
 434:	8526                	mv	a0,s1
 436:	00000097          	auipc	ra,0x0
 43a:	142080e7          	jalr	322(ra) # 578 <close>
  return r;
}
 43e:	854a                	mv	a0,s2
 440:	60e2                	ld	ra,24(sp)
 442:	6442                	ld	s0,16(sp)
 444:	64a2                	ld	s1,8(sp)
 446:	6902                	ld	s2,0(sp)
 448:	6105                	addi	sp,sp,32
 44a:	8082                	ret
    return -1;
 44c:	597d                	li	s2,-1
 44e:	bfc5                	j	43e <stat+0x34>

0000000000000450 <atoi>:

int
atoi(const char *s)
{
 450:	1141                	addi	sp,sp,-16
 452:	e422                	sd	s0,8(sp)
 454:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 456:	00054603          	lbu	a2,0(a0)
 45a:	fd06079b          	addiw	a5,a2,-48
 45e:	0ff7f793          	andi	a5,a5,255
 462:	4725                	li	a4,9
 464:	02f76963          	bltu	a4,a5,496 <atoi+0x46>
 468:	86aa                	mv	a3,a0
  n = 0;
 46a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 46c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 46e:	0685                	addi	a3,a3,1
 470:	0025179b          	slliw	a5,a0,0x2
 474:	9fa9                	addw	a5,a5,a0
 476:	0017979b          	slliw	a5,a5,0x1
 47a:	9fb1                	addw	a5,a5,a2
 47c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 480:	0006c603          	lbu	a2,0(a3)
 484:	fd06071b          	addiw	a4,a2,-48
 488:	0ff77713          	andi	a4,a4,255
 48c:	fee5f1e3          	bgeu	a1,a4,46e <atoi+0x1e>
  return n;
}
 490:	6422                	ld	s0,8(sp)
 492:	0141                	addi	sp,sp,16
 494:	8082                	ret
  n = 0;
 496:	4501                	li	a0,0
 498:	bfe5                	j	490 <atoi+0x40>

000000000000049a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 49a:	1141                	addi	sp,sp,-16
 49c:	e422                	sd	s0,8(sp)
 49e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4a0:	02b57663          	bgeu	a0,a1,4cc <memmove+0x32>
    while(n-- > 0)
 4a4:	02c05163          	blez	a2,4c6 <memmove+0x2c>
 4a8:	fff6079b          	addiw	a5,a2,-1
 4ac:	1782                	slli	a5,a5,0x20
 4ae:	9381                	srli	a5,a5,0x20
 4b0:	0785                	addi	a5,a5,1
 4b2:	97aa                	add	a5,a5,a0
  dst = vdst;
 4b4:	872a                	mv	a4,a0
      *dst++ = *src++;
 4b6:	0585                	addi	a1,a1,1
 4b8:	0705                	addi	a4,a4,1
 4ba:	fff5c683          	lbu	a3,-1(a1)
 4be:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4c2:	fee79ae3          	bne	a5,a4,4b6 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4c6:	6422                	ld	s0,8(sp)
 4c8:	0141                	addi	sp,sp,16
 4ca:	8082                	ret
    dst += n;
 4cc:	00c50733          	add	a4,a0,a2
    src += n;
 4d0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4d2:	fec05ae3          	blez	a2,4c6 <memmove+0x2c>
 4d6:	fff6079b          	addiw	a5,a2,-1
 4da:	1782                	slli	a5,a5,0x20
 4dc:	9381                	srli	a5,a5,0x20
 4de:	fff7c793          	not	a5,a5
 4e2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4e4:	15fd                	addi	a1,a1,-1
 4e6:	177d                	addi	a4,a4,-1
 4e8:	0005c683          	lbu	a3,0(a1)
 4ec:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4f0:	fee79ae3          	bne	a5,a4,4e4 <memmove+0x4a>
 4f4:	bfc9                	j	4c6 <memmove+0x2c>

00000000000004f6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4f6:	1141                	addi	sp,sp,-16
 4f8:	e422                	sd	s0,8(sp)
 4fa:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4fc:	ca05                	beqz	a2,52c <memcmp+0x36>
 4fe:	fff6069b          	addiw	a3,a2,-1
 502:	1682                	slli	a3,a3,0x20
 504:	9281                	srli	a3,a3,0x20
 506:	0685                	addi	a3,a3,1
 508:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 50a:	00054783          	lbu	a5,0(a0)
 50e:	0005c703          	lbu	a4,0(a1)
 512:	00e79863          	bne	a5,a4,522 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 516:	0505                	addi	a0,a0,1
    p2++;
 518:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 51a:	fed518e3          	bne	a0,a3,50a <memcmp+0x14>
  }
  return 0;
 51e:	4501                	li	a0,0
 520:	a019                	j	526 <memcmp+0x30>
      return *p1 - *p2;
 522:	40e7853b          	subw	a0,a5,a4
}
 526:	6422                	ld	s0,8(sp)
 528:	0141                	addi	sp,sp,16
 52a:	8082                	ret
  return 0;
 52c:	4501                	li	a0,0
 52e:	bfe5                	j	526 <memcmp+0x30>

0000000000000530 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 530:	1141                	addi	sp,sp,-16
 532:	e406                	sd	ra,8(sp)
 534:	e022                	sd	s0,0(sp)
 536:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 538:	00000097          	auipc	ra,0x0
 53c:	f62080e7          	jalr	-158(ra) # 49a <memmove>
}
 540:	60a2                	ld	ra,8(sp)
 542:	6402                	ld	s0,0(sp)
 544:	0141                	addi	sp,sp,16
 546:	8082                	ret

0000000000000548 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 548:	4885                	li	a7,1
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <exit>:
.global exit
exit:
 li a7, SYS_exit
 550:	4889                	li	a7,2
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <wait>:
.global wait
wait:
 li a7, SYS_wait
 558:	488d                	li	a7,3
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 560:	4891                	li	a7,4
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <read>:
.global read
read:
 li a7, SYS_read
 568:	4895                	li	a7,5
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <write>:
.global write
write:
 li a7, SYS_write
 570:	48c1                	li	a7,16
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <close>:
.global close
close:
 li a7, SYS_close
 578:	48d5                	li	a7,21
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <kill>:
.global kill
kill:
 li a7, SYS_kill
 580:	4899                	li	a7,6
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <exec>:
.global exec
exec:
 li a7, SYS_exec
 588:	489d                	li	a7,7
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <open>:
.global open
open:
 li a7, SYS_open
 590:	48bd                	li	a7,15
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 598:	48c5                	li	a7,17
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5a0:	48c9                	li	a7,18
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5a8:	48a1                	li	a7,8
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <link>:
.global link
link:
 li a7, SYS_link
 5b0:	48cd                	li	a7,19
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5b8:	48d1                	li	a7,20
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5c0:	48a5                	li	a7,9
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5c8:	48a9                	li	a7,10
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5d0:	48ad                	li	a7,11
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5d8:	48b1                	li	a7,12
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5e0:	48b5                	li	a7,13
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5e8:	48b9                	li	a7,14
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <connect>:
.global connect
connect:
 li a7, SYS_connect
 5f0:	48d9                	li	a7,22
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 5f8:	48dd                	li	a7,23
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 600:	1101                	addi	sp,sp,-32
 602:	ec06                	sd	ra,24(sp)
 604:	e822                	sd	s0,16(sp)
 606:	1000                	addi	s0,sp,32
 608:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 60c:	4605                	li	a2,1
 60e:	fef40593          	addi	a1,s0,-17
 612:	00000097          	auipc	ra,0x0
 616:	f5e080e7          	jalr	-162(ra) # 570 <write>
}
 61a:	60e2                	ld	ra,24(sp)
 61c:	6442                	ld	s0,16(sp)
 61e:	6105                	addi	sp,sp,32
 620:	8082                	ret

0000000000000622 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 622:	7139                	addi	sp,sp,-64
 624:	fc06                	sd	ra,56(sp)
 626:	f822                	sd	s0,48(sp)
 628:	f426                	sd	s1,40(sp)
 62a:	f04a                	sd	s2,32(sp)
 62c:	ec4e                	sd	s3,24(sp)
 62e:	0080                	addi	s0,sp,64
 630:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 632:	c299                	beqz	a3,638 <printint+0x16>
 634:	0805c863          	bltz	a1,6c4 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 638:	2581                	sext.w	a1,a1
  neg = 0;
 63a:	4881                	li	a7,0
 63c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 640:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 642:	2601                	sext.w	a2,a2
 644:	00000517          	auipc	a0,0x0
 648:	55450513          	addi	a0,a0,1364 # b98 <digits>
 64c:	883a                	mv	a6,a4
 64e:	2705                	addiw	a4,a4,1
 650:	02c5f7bb          	remuw	a5,a1,a2
 654:	1782                	slli	a5,a5,0x20
 656:	9381                	srli	a5,a5,0x20
 658:	97aa                	add	a5,a5,a0
 65a:	0007c783          	lbu	a5,0(a5)
 65e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 662:	0005879b          	sext.w	a5,a1
 666:	02c5d5bb          	divuw	a1,a1,a2
 66a:	0685                	addi	a3,a3,1
 66c:	fec7f0e3          	bgeu	a5,a2,64c <printint+0x2a>
  if(neg)
 670:	00088b63          	beqz	a7,686 <printint+0x64>
    buf[i++] = '-';
 674:	fd040793          	addi	a5,s0,-48
 678:	973e                	add	a4,a4,a5
 67a:	02d00793          	li	a5,45
 67e:	fef70823          	sb	a5,-16(a4)
 682:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 686:	02e05863          	blez	a4,6b6 <printint+0x94>
 68a:	fc040793          	addi	a5,s0,-64
 68e:	00e78933          	add	s2,a5,a4
 692:	fff78993          	addi	s3,a5,-1
 696:	99ba                	add	s3,s3,a4
 698:	377d                	addiw	a4,a4,-1
 69a:	1702                	slli	a4,a4,0x20
 69c:	9301                	srli	a4,a4,0x20
 69e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6a2:	fff94583          	lbu	a1,-1(s2)
 6a6:	8526                	mv	a0,s1
 6a8:	00000097          	auipc	ra,0x0
 6ac:	f58080e7          	jalr	-168(ra) # 600 <putc>
  while(--i >= 0)
 6b0:	197d                	addi	s2,s2,-1
 6b2:	ff3918e3          	bne	s2,s3,6a2 <printint+0x80>
}
 6b6:	70e2                	ld	ra,56(sp)
 6b8:	7442                	ld	s0,48(sp)
 6ba:	74a2                	ld	s1,40(sp)
 6bc:	7902                	ld	s2,32(sp)
 6be:	69e2                	ld	s3,24(sp)
 6c0:	6121                	addi	sp,sp,64
 6c2:	8082                	ret
    x = -xx;
 6c4:	40b005bb          	negw	a1,a1
    neg = 1;
 6c8:	4885                	li	a7,1
    x = -xx;
 6ca:	bf8d                	j	63c <printint+0x1a>

00000000000006cc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6cc:	7119                	addi	sp,sp,-128
 6ce:	fc86                	sd	ra,120(sp)
 6d0:	f8a2                	sd	s0,112(sp)
 6d2:	f4a6                	sd	s1,104(sp)
 6d4:	f0ca                	sd	s2,96(sp)
 6d6:	ecce                	sd	s3,88(sp)
 6d8:	e8d2                	sd	s4,80(sp)
 6da:	e4d6                	sd	s5,72(sp)
 6dc:	e0da                	sd	s6,64(sp)
 6de:	fc5e                	sd	s7,56(sp)
 6e0:	f862                	sd	s8,48(sp)
 6e2:	f466                	sd	s9,40(sp)
 6e4:	f06a                	sd	s10,32(sp)
 6e6:	ec6e                	sd	s11,24(sp)
 6e8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6ea:	0005c903          	lbu	s2,0(a1)
 6ee:	18090f63          	beqz	s2,88c <vprintf+0x1c0>
 6f2:	8aaa                	mv	s5,a0
 6f4:	8b32                	mv	s6,a2
 6f6:	00158493          	addi	s1,a1,1
  state = 0;
 6fa:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6fc:	02500a13          	li	s4,37
      if(c == 'd'){
 700:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 704:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 708:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 70c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 710:	00000b97          	auipc	s7,0x0
 714:	488b8b93          	addi	s7,s7,1160 # b98 <digits>
 718:	a839                	j	736 <vprintf+0x6a>
        putc(fd, c);
 71a:	85ca                	mv	a1,s2
 71c:	8556                	mv	a0,s5
 71e:	00000097          	auipc	ra,0x0
 722:	ee2080e7          	jalr	-286(ra) # 600 <putc>
 726:	a019                	j	72c <vprintf+0x60>
    } else if(state == '%'){
 728:	01498f63          	beq	s3,s4,746 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 72c:	0485                	addi	s1,s1,1
 72e:	fff4c903          	lbu	s2,-1(s1)
 732:	14090d63          	beqz	s2,88c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 736:	0009079b          	sext.w	a5,s2
    if(state == 0){
 73a:	fe0997e3          	bnez	s3,728 <vprintf+0x5c>
      if(c == '%'){
 73e:	fd479ee3          	bne	a5,s4,71a <vprintf+0x4e>
        state = '%';
 742:	89be                	mv	s3,a5
 744:	b7e5                	j	72c <vprintf+0x60>
      if(c == 'd'){
 746:	05878063          	beq	a5,s8,786 <vprintf+0xba>
      } else if(c == 'l') {
 74a:	05978c63          	beq	a5,s9,7a2 <vprintf+0xd6>
      } else if(c == 'x') {
 74e:	07a78863          	beq	a5,s10,7be <vprintf+0xf2>
      } else if(c == 'p') {
 752:	09b78463          	beq	a5,s11,7da <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 756:	07300713          	li	a4,115
 75a:	0ce78663          	beq	a5,a4,826 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 75e:	06300713          	li	a4,99
 762:	0ee78e63          	beq	a5,a4,85e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 766:	11478863          	beq	a5,s4,876 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 76a:	85d2                	mv	a1,s4
 76c:	8556                	mv	a0,s5
 76e:	00000097          	auipc	ra,0x0
 772:	e92080e7          	jalr	-366(ra) # 600 <putc>
        putc(fd, c);
 776:	85ca                	mv	a1,s2
 778:	8556                	mv	a0,s5
 77a:	00000097          	auipc	ra,0x0
 77e:	e86080e7          	jalr	-378(ra) # 600 <putc>
      }
      state = 0;
 782:	4981                	li	s3,0
 784:	b765                	j	72c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 786:	008b0913          	addi	s2,s6,8
 78a:	4685                	li	a3,1
 78c:	4629                	li	a2,10
 78e:	000b2583          	lw	a1,0(s6)
 792:	8556                	mv	a0,s5
 794:	00000097          	auipc	ra,0x0
 798:	e8e080e7          	jalr	-370(ra) # 622 <printint>
 79c:	8b4a                	mv	s6,s2
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	b771                	j	72c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7a2:	008b0913          	addi	s2,s6,8
 7a6:	4681                	li	a3,0
 7a8:	4629                	li	a2,10
 7aa:	000b2583          	lw	a1,0(s6)
 7ae:	8556                	mv	a0,s5
 7b0:	00000097          	auipc	ra,0x0
 7b4:	e72080e7          	jalr	-398(ra) # 622 <printint>
 7b8:	8b4a                	mv	s6,s2
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	bf85                	j	72c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7be:	008b0913          	addi	s2,s6,8
 7c2:	4681                	li	a3,0
 7c4:	4641                	li	a2,16
 7c6:	000b2583          	lw	a1,0(s6)
 7ca:	8556                	mv	a0,s5
 7cc:	00000097          	auipc	ra,0x0
 7d0:	e56080e7          	jalr	-426(ra) # 622 <printint>
 7d4:	8b4a                	mv	s6,s2
      state = 0;
 7d6:	4981                	li	s3,0
 7d8:	bf91                	j	72c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7da:	008b0793          	addi	a5,s6,8
 7de:	f8f43423          	sd	a5,-120(s0)
 7e2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 7e6:	03000593          	li	a1,48
 7ea:	8556                	mv	a0,s5
 7ec:	00000097          	auipc	ra,0x0
 7f0:	e14080e7          	jalr	-492(ra) # 600 <putc>
  putc(fd, 'x');
 7f4:	85ea                	mv	a1,s10
 7f6:	8556                	mv	a0,s5
 7f8:	00000097          	auipc	ra,0x0
 7fc:	e08080e7          	jalr	-504(ra) # 600 <putc>
 800:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 802:	03c9d793          	srli	a5,s3,0x3c
 806:	97de                	add	a5,a5,s7
 808:	0007c583          	lbu	a1,0(a5)
 80c:	8556                	mv	a0,s5
 80e:	00000097          	auipc	ra,0x0
 812:	df2080e7          	jalr	-526(ra) # 600 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 816:	0992                	slli	s3,s3,0x4
 818:	397d                	addiw	s2,s2,-1
 81a:	fe0914e3          	bnez	s2,802 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 81e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 822:	4981                	li	s3,0
 824:	b721                	j	72c <vprintf+0x60>
        s = va_arg(ap, char*);
 826:	008b0993          	addi	s3,s6,8
 82a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 82e:	02090163          	beqz	s2,850 <vprintf+0x184>
        while(*s != 0){
 832:	00094583          	lbu	a1,0(s2)
 836:	c9a1                	beqz	a1,886 <vprintf+0x1ba>
          putc(fd, *s);
 838:	8556                	mv	a0,s5
 83a:	00000097          	auipc	ra,0x0
 83e:	dc6080e7          	jalr	-570(ra) # 600 <putc>
          s++;
 842:	0905                	addi	s2,s2,1
        while(*s != 0){
 844:	00094583          	lbu	a1,0(s2)
 848:	f9e5                	bnez	a1,838 <vprintf+0x16c>
        s = va_arg(ap, char*);
 84a:	8b4e                	mv	s6,s3
      state = 0;
 84c:	4981                	li	s3,0
 84e:	bdf9                	j	72c <vprintf+0x60>
          s = "(null)";
 850:	00000917          	auipc	s2,0x0
 854:	34090913          	addi	s2,s2,832 # b90 <malloc+0x1fa>
        while(*s != 0){
 858:	02800593          	li	a1,40
 85c:	bff1                	j	838 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 85e:	008b0913          	addi	s2,s6,8
 862:	000b4583          	lbu	a1,0(s6)
 866:	8556                	mv	a0,s5
 868:	00000097          	auipc	ra,0x0
 86c:	d98080e7          	jalr	-616(ra) # 600 <putc>
 870:	8b4a                	mv	s6,s2
      state = 0;
 872:	4981                	li	s3,0
 874:	bd65                	j	72c <vprintf+0x60>
        putc(fd, c);
 876:	85d2                	mv	a1,s4
 878:	8556                	mv	a0,s5
 87a:	00000097          	auipc	ra,0x0
 87e:	d86080e7          	jalr	-634(ra) # 600 <putc>
      state = 0;
 882:	4981                	li	s3,0
 884:	b565                	j	72c <vprintf+0x60>
        s = va_arg(ap, char*);
 886:	8b4e                	mv	s6,s3
      state = 0;
 888:	4981                	li	s3,0
 88a:	b54d                	j	72c <vprintf+0x60>
    }
  }
}
 88c:	70e6                	ld	ra,120(sp)
 88e:	7446                	ld	s0,112(sp)
 890:	74a6                	ld	s1,104(sp)
 892:	7906                	ld	s2,96(sp)
 894:	69e6                	ld	s3,88(sp)
 896:	6a46                	ld	s4,80(sp)
 898:	6aa6                	ld	s5,72(sp)
 89a:	6b06                	ld	s6,64(sp)
 89c:	7be2                	ld	s7,56(sp)
 89e:	7c42                	ld	s8,48(sp)
 8a0:	7ca2                	ld	s9,40(sp)
 8a2:	7d02                	ld	s10,32(sp)
 8a4:	6de2                	ld	s11,24(sp)
 8a6:	6109                	addi	sp,sp,128
 8a8:	8082                	ret

00000000000008aa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8aa:	715d                	addi	sp,sp,-80
 8ac:	ec06                	sd	ra,24(sp)
 8ae:	e822                	sd	s0,16(sp)
 8b0:	1000                	addi	s0,sp,32
 8b2:	e010                	sd	a2,0(s0)
 8b4:	e414                	sd	a3,8(s0)
 8b6:	e818                	sd	a4,16(s0)
 8b8:	ec1c                	sd	a5,24(s0)
 8ba:	03043023          	sd	a6,32(s0)
 8be:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8c2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8c6:	8622                	mv	a2,s0
 8c8:	00000097          	auipc	ra,0x0
 8cc:	e04080e7          	jalr	-508(ra) # 6cc <vprintf>
}
 8d0:	60e2                	ld	ra,24(sp)
 8d2:	6442                	ld	s0,16(sp)
 8d4:	6161                	addi	sp,sp,80
 8d6:	8082                	ret

00000000000008d8 <printf>:

void
printf(const char *fmt, ...)
{
 8d8:	711d                	addi	sp,sp,-96
 8da:	ec06                	sd	ra,24(sp)
 8dc:	e822                	sd	s0,16(sp)
 8de:	1000                	addi	s0,sp,32
 8e0:	e40c                	sd	a1,8(s0)
 8e2:	e810                	sd	a2,16(s0)
 8e4:	ec14                	sd	a3,24(s0)
 8e6:	f018                	sd	a4,32(s0)
 8e8:	f41c                	sd	a5,40(s0)
 8ea:	03043823          	sd	a6,48(s0)
 8ee:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8f2:	00840613          	addi	a2,s0,8
 8f6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8fa:	85aa                	mv	a1,a0
 8fc:	4505                	li	a0,1
 8fe:	00000097          	auipc	ra,0x0
 902:	dce080e7          	jalr	-562(ra) # 6cc <vprintf>
}
 906:	60e2                	ld	ra,24(sp)
 908:	6442                	ld	s0,16(sp)
 90a:	6125                	addi	sp,sp,96
 90c:	8082                	ret

000000000000090e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 90e:	1141                	addi	sp,sp,-16
 910:	e422                	sd	s0,8(sp)
 912:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 914:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 918:	00000797          	auipc	a5,0x0
 91c:	2987b783          	ld	a5,664(a5) # bb0 <freep>
 920:	a805                	j	950 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 922:	4618                	lw	a4,8(a2)
 924:	9db9                	addw	a1,a1,a4
 926:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 92a:	6398                	ld	a4,0(a5)
 92c:	6318                	ld	a4,0(a4)
 92e:	fee53823          	sd	a4,-16(a0)
 932:	a091                	j	976 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 934:	ff852703          	lw	a4,-8(a0)
 938:	9e39                	addw	a2,a2,a4
 93a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 93c:	ff053703          	ld	a4,-16(a0)
 940:	e398                	sd	a4,0(a5)
 942:	a099                	j	988 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 944:	6398                	ld	a4,0(a5)
 946:	00e7e463          	bltu	a5,a4,94e <free+0x40>
 94a:	00e6ea63          	bltu	a3,a4,95e <free+0x50>
{
 94e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 950:	fed7fae3          	bgeu	a5,a3,944 <free+0x36>
 954:	6398                	ld	a4,0(a5)
 956:	00e6e463          	bltu	a3,a4,95e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 95a:	fee7eae3          	bltu	a5,a4,94e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 95e:	ff852583          	lw	a1,-8(a0)
 962:	6390                	ld	a2,0(a5)
 964:	02059713          	slli	a4,a1,0x20
 968:	9301                	srli	a4,a4,0x20
 96a:	0712                	slli	a4,a4,0x4
 96c:	9736                	add	a4,a4,a3
 96e:	fae60ae3          	beq	a2,a4,922 <free+0x14>
    bp->s.ptr = p->s.ptr;
 972:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 976:	4790                	lw	a2,8(a5)
 978:	02061713          	slli	a4,a2,0x20
 97c:	9301                	srli	a4,a4,0x20
 97e:	0712                	slli	a4,a4,0x4
 980:	973e                	add	a4,a4,a5
 982:	fae689e3          	beq	a3,a4,934 <free+0x26>
  } else
    p->s.ptr = bp;
 986:	e394                	sd	a3,0(a5)
  freep = p;
 988:	00000717          	auipc	a4,0x0
 98c:	22f73423          	sd	a5,552(a4) # bb0 <freep>
}
 990:	6422                	ld	s0,8(sp)
 992:	0141                	addi	sp,sp,16
 994:	8082                	ret

0000000000000996 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 996:	7139                	addi	sp,sp,-64
 998:	fc06                	sd	ra,56(sp)
 99a:	f822                	sd	s0,48(sp)
 99c:	f426                	sd	s1,40(sp)
 99e:	f04a                	sd	s2,32(sp)
 9a0:	ec4e                	sd	s3,24(sp)
 9a2:	e852                	sd	s4,16(sp)
 9a4:	e456                	sd	s5,8(sp)
 9a6:	e05a                	sd	s6,0(sp)
 9a8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9aa:	02051493          	slli	s1,a0,0x20
 9ae:	9081                	srli	s1,s1,0x20
 9b0:	04bd                	addi	s1,s1,15
 9b2:	8091                	srli	s1,s1,0x4
 9b4:	0014899b          	addiw	s3,s1,1
 9b8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9ba:	00000517          	auipc	a0,0x0
 9be:	1f653503          	ld	a0,502(a0) # bb0 <freep>
 9c2:	c515                	beqz	a0,9ee <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9c6:	4798                	lw	a4,8(a5)
 9c8:	02977f63          	bgeu	a4,s1,a06 <malloc+0x70>
 9cc:	8a4e                	mv	s4,s3
 9ce:	0009871b          	sext.w	a4,s3
 9d2:	6685                	lui	a3,0x1
 9d4:	00d77363          	bgeu	a4,a3,9da <malloc+0x44>
 9d8:	6a05                	lui	s4,0x1
 9da:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9de:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9e2:	00000917          	auipc	s2,0x0
 9e6:	1ce90913          	addi	s2,s2,462 # bb0 <freep>
  if(p == (char*)-1)
 9ea:	5afd                	li	s5,-1
 9ec:	a88d                	j	a5e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 9ee:	00000797          	auipc	a5,0x0
 9f2:	1ca78793          	addi	a5,a5,458 # bb8 <base>
 9f6:	00000717          	auipc	a4,0x0
 9fa:	1af73d23          	sd	a5,442(a4) # bb0 <freep>
 9fe:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a00:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a04:	b7e1                	j	9cc <malloc+0x36>
      if(p->s.size == nunits)
 a06:	02e48b63          	beq	s1,a4,a3c <malloc+0xa6>
        p->s.size -= nunits;
 a0a:	4137073b          	subw	a4,a4,s3
 a0e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a10:	1702                	slli	a4,a4,0x20
 a12:	9301                	srli	a4,a4,0x20
 a14:	0712                	slli	a4,a4,0x4
 a16:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a18:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a1c:	00000717          	auipc	a4,0x0
 a20:	18a73a23          	sd	a0,404(a4) # bb0 <freep>
      return (void*)(p + 1);
 a24:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a28:	70e2                	ld	ra,56(sp)
 a2a:	7442                	ld	s0,48(sp)
 a2c:	74a2                	ld	s1,40(sp)
 a2e:	7902                	ld	s2,32(sp)
 a30:	69e2                	ld	s3,24(sp)
 a32:	6a42                	ld	s4,16(sp)
 a34:	6aa2                	ld	s5,8(sp)
 a36:	6b02                	ld	s6,0(sp)
 a38:	6121                	addi	sp,sp,64
 a3a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a3c:	6398                	ld	a4,0(a5)
 a3e:	e118                	sd	a4,0(a0)
 a40:	bff1                	j	a1c <malloc+0x86>
  hp->s.size = nu;
 a42:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a46:	0541                	addi	a0,a0,16
 a48:	00000097          	auipc	ra,0x0
 a4c:	ec6080e7          	jalr	-314(ra) # 90e <free>
  return freep;
 a50:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a54:	d971                	beqz	a0,a28 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a56:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a58:	4798                	lw	a4,8(a5)
 a5a:	fa9776e3          	bgeu	a4,s1,a06 <malloc+0x70>
    if(p == freep)
 a5e:	00093703          	ld	a4,0(s2)
 a62:	853e                	mv	a0,a5
 a64:	fef719e3          	bne	a4,a5,a56 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a68:	8552                	mv	a0,s4
 a6a:	00000097          	auipc	ra,0x0
 a6e:	b6e080e7          	jalr	-1170(ra) # 5d8 <sbrk>
  if(p == (char*)-1)
 a72:	fd5518e3          	bne	a0,s5,a42 <malloc+0xac>
        return 0;
 a76:	4501                	li	a0,0
 a78:	bf45                	j	a28 <malloc+0x92>
