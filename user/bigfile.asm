
user/_bigfile:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fcntl.h"
#include "kernel/fs.h"

int
main()
{
   0:	bd010113          	addi	sp,sp,-1072
   4:	42113423          	sd	ra,1064(sp)
   8:	42813023          	sd	s0,1056(sp)
   c:	40913c23          	sd	s1,1048(sp)
  10:	41213823          	sd	s2,1040(sp)
  14:	41313423          	sd	s3,1032(sp)
  18:	41413023          	sd	s4,1024(sp)
  1c:	43010413          	addi	s0,sp,1072
  char buf[BSIZE];
  int fd, i, blocks;

  fd = open("big.file", O_CREATE | O_WRONLY);
  20:	20100593          	li	a1,513
  24:	00001517          	auipc	a0,0x1
  28:	90450513          	addi	a0,a0,-1788 # 928 <malloc+0xe4>
  2c:	00000097          	auipc	ra,0x0
  30:	412080e7          	jalr	1042(ra) # 43e <open>
  if(fd < 0){
  34:	00054b63          	bltz	a0,4a <main+0x4a>
  38:	892a                	mv	s2,a0
  3a:	4481                	li	s1,0
    *(int*)buf = blocks;
    int cc = write(fd, buf, sizeof(buf));
    if(cc <= 0)
      break;
    blocks++;
    if (blocks % 100 == 0)
  3c:	06400993          	li	s3,100
      printf(".");
  40:	00001a17          	auipc	s4,0x1
  44:	928a0a13          	addi	s4,s4,-1752 # 968 <malloc+0x124>
  48:	a01d                	j	6e <main+0x6e>
    printf("bigfile: cannot open big.file for writing\n");
  4a:	00001517          	auipc	a0,0x1
  4e:	8ee50513          	addi	a0,a0,-1810 # 938 <malloc+0xf4>
  52:	00000097          	auipc	ra,0x0
  56:	734080e7          	jalr	1844(ra) # 786 <printf>
    exit(-1);
  5a:	557d                	li	a0,-1
  5c:	00000097          	auipc	ra,0x0
  60:	3a2080e7          	jalr	930(ra) # 3fe <exit>
      printf(".");
  64:	8552                	mv	a0,s4
  66:	00000097          	auipc	ra,0x0
  6a:	720080e7          	jalr	1824(ra) # 786 <printf>
    *(int*)buf = blocks;
  6e:	bc942823          	sw	s1,-1072(s0)
    int cc = write(fd, buf, sizeof(buf));
  72:	40000613          	li	a2,1024
  76:	bd040593          	addi	a1,s0,-1072
  7a:	854a                	mv	a0,s2
  7c:	00000097          	auipc	ra,0x0
  80:	3a2080e7          	jalr	930(ra) # 41e <write>
    if(cc <= 0)
  84:	00a05a63          	blez	a0,98 <main+0x98>
    blocks++;
  88:	0014879b          	addiw	a5,s1,1
  8c:	0007849b          	sext.w	s1,a5
    if (blocks % 100 == 0)
  90:	0337e7bb          	remw	a5,a5,s3
  94:	ffe9                	bnez	a5,6e <main+0x6e>
  96:	b7f9                	j	64 <main+0x64>
  }

  printf("\nwrote %d blocks\n", blocks);
  98:	85a6                	mv	a1,s1
  9a:	00001517          	auipc	a0,0x1
  9e:	8d650513          	addi	a0,a0,-1834 # 970 <malloc+0x12c>
  a2:	00000097          	auipc	ra,0x0
  a6:	6e4080e7          	jalr	1764(ra) # 786 <printf>
  if(blocks != 65803) {
  aa:	67c1                	lui	a5,0x10
  ac:	10b78793          	addi	a5,a5,267 # 1010b <__global_pointer$+0xeeaa>
  b0:	00f48f63          	beq	s1,a5,ce <main+0xce>
    printf("bigfile: file is too small\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	8d450513          	addi	a0,a0,-1836 # 988 <malloc+0x144>
  bc:	00000097          	auipc	ra,0x0
  c0:	6ca080e7          	jalr	1738(ra) # 786 <printf>
    exit(-1);
  c4:	557d                	li	a0,-1
  c6:	00000097          	auipc	ra,0x0
  ca:	338080e7          	jalr	824(ra) # 3fe <exit>
  }
  
  close(fd);
  ce:	854a                	mv	a0,s2
  d0:	00000097          	auipc	ra,0x0
  d4:	356080e7          	jalr	854(ra) # 426 <close>
  fd = open("big.file", O_RDONLY);
  d8:	4581                	li	a1,0
  da:	00001517          	auipc	a0,0x1
  de:	84e50513          	addi	a0,a0,-1970 # 928 <malloc+0xe4>
  e2:	00000097          	auipc	ra,0x0
  e6:	35c080e7          	jalr	860(ra) # 43e <open>
  ea:	892a                	mv	s2,a0
  if(fd < 0){
    printf("bigfile: cannot re-open big.file for reading\n");
    exit(-1);
  }
  for(i = 0; i < blocks; i++){
  ec:	4481                	li	s1,0
  if(fd < 0){
  ee:	04054463          	bltz	a0,136 <main+0x136>
  for(i = 0; i < blocks; i++){
  f2:	69c1                	lui	s3,0x10
  f4:	10b98993          	addi	s3,s3,267 # 1010b <__global_pointer$+0xeeaa>
    int cc = read(fd, buf, sizeof(buf));
  f8:	40000613          	li	a2,1024
  fc:	bd040593          	addi	a1,s0,-1072
 100:	854a                	mv	a0,s2
 102:	00000097          	auipc	ra,0x0
 106:	314080e7          	jalr	788(ra) # 416 <read>
    if(cc <= 0){
 10a:	04a05363          	blez	a0,150 <main+0x150>
      printf("bigfile: read error at block %d\n", i);
      exit(-1);
    }
    if(*(int*)buf != i){
 10e:	bd042583          	lw	a1,-1072(s0)
 112:	04959d63          	bne	a1,s1,16c <main+0x16c>
  for(i = 0; i < blocks; i++){
 116:	2485                	addiw	s1,s1,1
 118:	ff3490e3          	bne	s1,s3,f8 <main+0xf8>
             *(int*)buf, i);
      exit(-1);
    }
  }

  printf("bigfile done; ok\n"); 
 11c:	00001517          	auipc	a0,0x1
 120:	91450513          	addi	a0,a0,-1772 # a30 <malloc+0x1ec>
 124:	00000097          	auipc	ra,0x0
 128:	662080e7          	jalr	1634(ra) # 786 <printf>

  exit(0);
 12c:	4501                	li	a0,0
 12e:	00000097          	auipc	ra,0x0
 132:	2d0080e7          	jalr	720(ra) # 3fe <exit>
    printf("bigfile: cannot re-open big.file for reading\n");
 136:	00001517          	auipc	a0,0x1
 13a:	87250513          	addi	a0,a0,-1934 # 9a8 <malloc+0x164>
 13e:	00000097          	auipc	ra,0x0
 142:	648080e7          	jalr	1608(ra) # 786 <printf>
    exit(-1);
 146:	557d                	li	a0,-1
 148:	00000097          	auipc	ra,0x0
 14c:	2b6080e7          	jalr	694(ra) # 3fe <exit>
      printf("bigfile: read error at block %d\n", i);
 150:	85a6                	mv	a1,s1
 152:	00001517          	auipc	a0,0x1
 156:	88650513          	addi	a0,a0,-1914 # 9d8 <malloc+0x194>
 15a:	00000097          	auipc	ra,0x0
 15e:	62c080e7          	jalr	1580(ra) # 786 <printf>
      exit(-1);
 162:	557d                	li	a0,-1
 164:	00000097          	auipc	ra,0x0
 168:	29a080e7          	jalr	666(ra) # 3fe <exit>
      printf("bigfile: read the wrong data (%d) for block %d\n",
 16c:	8626                	mv	a2,s1
 16e:	00001517          	auipc	a0,0x1
 172:	89250513          	addi	a0,a0,-1902 # a00 <malloc+0x1bc>
 176:	00000097          	auipc	ra,0x0
 17a:	610080e7          	jalr	1552(ra) # 786 <printf>
      exit(-1);
 17e:	557d                	li	a0,-1
 180:	00000097          	auipc	ra,0x0
 184:	27e080e7          	jalr	638(ra) # 3fe <exit>

0000000000000188 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 18e:	87aa                	mv	a5,a0
 190:	0585                	addi	a1,a1,1
 192:	0785                	addi	a5,a5,1
 194:	fff5c703          	lbu	a4,-1(a1)
 198:	fee78fa3          	sb	a4,-1(a5)
 19c:	fb75                	bnez	a4,190 <strcpy+0x8>
    ;
  return os;
}
 19e:	6422                	ld	s0,8(sp)
 1a0:	0141                	addi	sp,sp,16
 1a2:	8082                	ret

00000000000001a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1aa:	00054783          	lbu	a5,0(a0)
 1ae:	cb91                	beqz	a5,1c2 <strcmp+0x1e>
 1b0:	0005c703          	lbu	a4,0(a1)
 1b4:	00f71763          	bne	a4,a5,1c2 <strcmp+0x1e>
    p++, q++;
 1b8:	0505                	addi	a0,a0,1
 1ba:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	fbe5                	bnez	a5,1b0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1c2:	0005c503          	lbu	a0,0(a1)
}
 1c6:	40a7853b          	subw	a0,a5,a0
 1ca:	6422                	ld	s0,8(sp)
 1cc:	0141                	addi	sp,sp,16
 1ce:	8082                	ret

00000000000001d0 <strlen>:

uint
strlen(const char *s)
{
 1d0:	1141                	addi	sp,sp,-16
 1d2:	e422                	sd	s0,8(sp)
 1d4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1d6:	00054783          	lbu	a5,0(a0)
 1da:	cf91                	beqz	a5,1f6 <strlen+0x26>
 1dc:	0505                	addi	a0,a0,1
 1de:	87aa                	mv	a5,a0
 1e0:	4685                	li	a3,1
 1e2:	9e89                	subw	a3,a3,a0
 1e4:	00f6853b          	addw	a0,a3,a5
 1e8:	0785                	addi	a5,a5,1
 1ea:	fff7c703          	lbu	a4,-1(a5)
 1ee:	fb7d                	bnez	a4,1e4 <strlen+0x14>
    ;
  return n;
}
 1f0:	6422                	ld	s0,8(sp)
 1f2:	0141                	addi	sp,sp,16
 1f4:	8082                	ret
  for(n = 0; s[n]; n++)
 1f6:	4501                	li	a0,0
 1f8:	bfe5                	j	1f0 <strlen+0x20>

00000000000001fa <memset>:

void*
memset(void *dst, int c, uint n)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e422                	sd	s0,8(sp)
 1fe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 200:	ce09                	beqz	a2,21a <memset+0x20>
 202:	87aa                	mv	a5,a0
 204:	fff6071b          	addiw	a4,a2,-1
 208:	1702                	slli	a4,a4,0x20
 20a:	9301                	srli	a4,a4,0x20
 20c:	0705                	addi	a4,a4,1
 20e:	972a                	add	a4,a4,a0
    cdst[i] = c;
 210:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 214:	0785                	addi	a5,a5,1
 216:	fee79de3          	bne	a5,a4,210 <memset+0x16>
  }
  return dst;
}
 21a:	6422                	ld	s0,8(sp)
 21c:	0141                	addi	sp,sp,16
 21e:	8082                	ret

0000000000000220 <strchr>:

char*
strchr(const char *s, char c)
{
 220:	1141                	addi	sp,sp,-16
 222:	e422                	sd	s0,8(sp)
 224:	0800                	addi	s0,sp,16
  for(; *s; s++)
 226:	00054783          	lbu	a5,0(a0)
 22a:	cb99                	beqz	a5,240 <strchr+0x20>
    if(*s == c)
 22c:	00f58763          	beq	a1,a5,23a <strchr+0x1a>
  for(; *s; s++)
 230:	0505                	addi	a0,a0,1
 232:	00054783          	lbu	a5,0(a0)
 236:	fbfd                	bnez	a5,22c <strchr+0xc>
      return (char*)s;
  return 0;
 238:	4501                	li	a0,0
}
 23a:	6422                	ld	s0,8(sp)
 23c:	0141                	addi	sp,sp,16
 23e:	8082                	ret
  return 0;
 240:	4501                	li	a0,0
 242:	bfe5                	j	23a <strchr+0x1a>

0000000000000244 <gets>:

char*
gets(char *buf, int max)
{
 244:	711d                	addi	sp,sp,-96
 246:	ec86                	sd	ra,88(sp)
 248:	e8a2                	sd	s0,80(sp)
 24a:	e4a6                	sd	s1,72(sp)
 24c:	e0ca                	sd	s2,64(sp)
 24e:	fc4e                	sd	s3,56(sp)
 250:	f852                	sd	s4,48(sp)
 252:	f456                	sd	s5,40(sp)
 254:	f05a                	sd	s6,32(sp)
 256:	ec5e                	sd	s7,24(sp)
 258:	1080                	addi	s0,sp,96
 25a:	8baa                	mv	s7,a0
 25c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 25e:	892a                	mv	s2,a0
 260:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 262:	4aa9                	li	s5,10
 264:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 266:	89a6                	mv	s3,s1
 268:	2485                	addiw	s1,s1,1
 26a:	0344d863          	bge	s1,s4,29a <gets+0x56>
    cc = read(0, &c, 1);
 26e:	4605                	li	a2,1
 270:	faf40593          	addi	a1,s0,-81
 274:	4501                	li	a0,0
 276:	00000097          	auipc	ra,0x0
 27a:	1a0080e7          	jalr	416(ra) # 416 <read>
    if(cc < 1)
 27e:	00a05e63          	blez	a0,29a <gets+0x56>
    buf[i++] = c;
 282:	faf44783          	lbu	a5,-81(s0)
 286:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 28a:	01578763          	beq	a5,s5,298 <gets+0x54>
 28e:	0905                	addi	s2,s2,1
 290:	fd679be3          	bne	a5,s6,266 <gets+0x22>
  for(i=0; i+1 < max; ){
 294:	89a6                	mv	s3,s1
 296:	a011                	j	29a <gets+0x56>
 298:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 29a:	99de                	add	s3,s3,s7
 29c:	00098023          	sb	zero,0(s3)
  return buf;
}
 2a0:	855e                	mv	a0,s7
 2a2:	60e6                	ld	ra,88(sp)
 2a4:	6446                	ld	s0,80(sp)
 2a6:	64a6                	ld	s1,72(sp)
 2a8:	6906                	ld	s2,64(sp)
 2aa:	79e2                	ld	s3,56(sp)
 2ac:	7a42                	ld	s4,48(sp)
 2ae:	7aa2                	ld	s5,40(sp)
 2b0:	7b02                	ld	s6,32(sp)
 2b2:	6be2                	ld	s7,24(sp)
 2b4:	6125                	addi	sp,sp,96
 2b6:	8082                	ret

00000000000002b8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2b8:	1101                	addi	sp,sp,-32
 2ba:	ec06                	sd	ra,24(sp)
 2bc:	e822                	sd	s0,16(sp)
 2be:	e426                	sd	s1,8(sp)
 2c0:	e04a                	sd	s2,0(sp)
 2c2:	1000                	addi	s0,sp,32
 2c4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2c6:	4581                	li	a1,0
 2c8:	00000097          	auipc	ra,0x0
 2cc:	176080e7          	jalr	374(ra) # 43e <open>
  if(fd < 0)
 2d0:	02054563          	bltz	a0,2fa <stat+0x42>
 2d4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2d6:	85ca                	mv	a1,s2
 2d8:	00000097          	auipc	ra,0x0
 2dc:	17e080e7          	jalr	382(ra) # 456 <fstat>
 2e0:	892a                	mv	s2,a0
  close(fd);
 2e2:	8526                	mv	a0,s1
 2e4:	00000097          	auipc	ra,0x0
 2e8:	142080e7          	jalr	322(ra) # 426 <close>
  return r;
}
 2ec:	854a                	mv	a0,s2
 2ee:	60e2                	ld	ra,24(sp)
 2f0:	6442                	ld	s0,16(sp)
 2f2:	64a2                	ld	s1,8(sp)
 2f4:	6902                	ld	s2,0(sp)
 2f6:	6105                	addi	sp,sp,32
 2f8:	8082                	ret
    return -1;
 2fa:	597d                	li	s2,-1
 2fc:	bfc5                	j	2ec <stat+0x34>

00000000000002fe <atoi>:

int
atoi(const char *s)
{
 2fe:	1141                	addi	sp,sp,-16
 300:	e422                	sd	s0,8(sp)
 302:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 304:	00054603          	lbu	a2,0(a0)
 308:	fd06079b          	addiw	a5,a2,-48
 30c:	0ff7f793          	andi	a5,a5,255
 310:	4725                	li	a4,9
 312:	02f76963          	bltu	a4,a5,344 <atoi+0x46>
 316:	86aa                	mv	a3,a0
  n = 0;
 318:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 31a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 31c:	0685                	addi	a3,a3,1
 31e:	0025179b          	slliw	a5,a0,0x2
 322:	9fa9                	addw	a5,a5,a0
 324:	0017979b          	slliw	a5,a5,0x1
 328:	9fb1                	addw	a5,a5,a2
 32a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 32e:	0006c603          	lbu	a2,0(a3)
 332:	fd06071b          	addiw	a4,a2,-48
 336:	0ff77713          	andi	a4,a4,255
 33a:	fee5f1e3          	bgeu	a1,a4,31c <atoi+0x1e>
  return n;
}
 33e:	6422                	ld	s0,8(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret
  n = 0;
 344:	4501                	li	a0,0
 346:	bfe5                	j	33e <atoi+0x40>

0000000000000348 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 348:	1141                	addi	sp,sp,-16
 34a:	e422                	sd	s0,8(sp)
 34c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 34e:	02b57663          	bgeu	a0,a1,37a <memmove+0x32>
    while(n-- > 0)
 352:	02c05163          	blez	a2,374 <memmove+0x2c>
 356:	fff6079b          	addiw	a5,a2,-1
 35a:	1782                	slli	a5,a5,0x20
 35c:	9381                	srli	a5,a5,0x20
 35e:	0785                	addi	a5,a5,1
 360:	97aa                	add	a5,a5,a0
  dst = vdst;
 362:	872a                	mv	a4,a0
      *dst++ = *src++;
 364:	0585                	addi	a1,a1,1
 366:	0705                	addi	a4,a4,1
 368:	fff5c683          	lbu	a3,-1(a1)
 36c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 370:	fee79ae3          	bne	a5,a4,364 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 374:	6422                	ld	s0,8(sp)
 376:	0141                	addi	sp,sp,16
 378:	8082                	ret
    dst += n;
 37a:	00c50733          	add	a4,a0,a2
    src += n;
 37e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 380:	fec05ae3          	blez	a2,374 <memmove+0x2c>
 384:	fff6079b          	addiw	a5,a2,-1
 388:	1782                	slli	a5,a5,0x20
 38a:	9381                	srli	a5,a5,0x20
 38c:	fff7c793          	not	a5,a5
 390:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 392:	15fd                	addi	a1,a1,-1
 394:	177d                	addi	a4,a4,-1
 396:	0005c683          	lbu	a3,0(a1)
 39a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 39e:	fee79ae3          	bne	a5,a4,392 <memmove+0x4a>
 3a2:	bfc9                	j	374 <memmove+0x2c>

00000000000003a4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3a4:	1141                	addi	sp,sp,-16
 3a6:	e422                	sd	s0,8(sp)
 3a8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3aa:	ca05                	beqz	a2,3da <memcmp+0x36>
 3ac:	fff6069b          	addiw	a3,a2,-1
 3b0:	1682                	slli	a3,a3,0x20
 3b2:	9281                	srli	a3,a3,0x20
 3b4:	0685                	addi	a3,a3,1
 3b6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3b8:	00054783          	lbu	a5,0(a0)
 3bc:	0005c703          	lbu	a4,0(a1)
 3c0:	00e79863          	bne	a5,a4,3d0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3c4:	0505                	addi	a0,a0,1
    p2++;
 3c6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3c8:	fed518e3          	bne	a0,a3,3b8 <memcmp+0x14>
  }
  return 0;
 3cc:	4501                	li	a0,0
 3ce:	a019                	j	3d4 <memcmp+0x30>
      return *p1 - *p2;
 3d0:	40e7853b          	subw	a0,a5,a4
}
 3d4:	6422                	ld	s0,8(sp)
 3d6:	0141                	addi	sp,sp,16
 3d8:	8082                	ret
  return 0;
 3da:	4501                	li	a0,0
 3dc:	bfe5                	j	3d4 <memcmp+0x30>

00000000000003de <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3de:	1141                	addi	sp,sp,-16
 3e0:	e406                	sd	ra,8(sp)
 3e2:	e022                	sd	s0,0(sp)
 3e4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3e6:	00000097          	auipc	ra,0x0
 3ea:	f62080e7          	jalr	-158(ra) # 348 <memmove>
}
 3ee:	60a2                	ld	ra,8(sp)
 3f0:	6402                	ld	s0,0(sp)
 3f2:	0141                	addi	sp,sp,16
 3f4:	8082                	ret

00000000000003f6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3f6:	4885                	li	a7,1
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <exit>:
.global exit
exit:
 li a7, SYS_exit
 3fe:	4889                	li	a7,2
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <wait>:
.global wait
wait:
 li a7, SYS_wait
 406:	488d                	li	a7,3
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 40e:	4891                	li	a7,4
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <read>:
.global read
read:
 li a7, SYS_read
 416:	4895                	li	a7,5
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <write>:
.global write
write:
 li a7, SYS_write
 41e:	48c1                	li	a7,16
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <close>:
.global close
close:
 li a7, SYS_close
 426:	48d5                	li	a7,21
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <kill>:
.global kill
kill:
 li a7, SYS_kill
 42e:	4899                	li	a7,6
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <exec>:
.global exec
exec:
 li a7, SYS_exec
 436:	489d                	li	a7,7
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <open>:
.global open
open:
 li a7, SYS_open
 43e:	48bd                	li	a7,15
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 446:	48c5                	li	a7,17
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 44e:	48c9                	li	a7,18
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 456:	48a1                	li	a7,8
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <link>:
.global link
link:
 li a7, SYS_link
 45e:	48cd                	li	a7,19
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 466:	48d1                	li	a7,20
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 46e:	48a5                	li	a7,9
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <dup>:
.global dup
dup:
 li a7, SYS_dup
 476:	48a9                	li	a7,10
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 47e:	48ad                	li	a7,11
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 486:	48b1                	li	a7,12
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 48e:	48b5                	li	a7,13
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 496:	48b9                	li	a7,14
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <connect>:
.global connect
connect:
 li a7, SYS_connect
 49e:	48d9                	li	a7,22
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 4a6:	48dd                	li	a7,23
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ae:	1101                	addi	sp,sp,-32
 4b0:	ec06                	sd	ra,24(sp)
 4b2:	e822                	sd	s0,16(sp)
 4b4:	1000                	addi	s0,sp,32
 4b6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ba:	4605                	li	a2,1
 4bc:	fef40593          	addi	a1,s0,-17
 4c0:	00000097          	auipc	ra,0x0
 4c4:	f5e080e7          	jalr	-162(ra) # 41e <write>
}
 4c8:	60e2                	ld	ra,24(sp)
 4ca:	6442                	ld	s0,16(sp)
 4cc:	6105                	addi	sp,sp,32
 4ce:	8082                	ret

00000000000004d0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4d0:	7139                	addi	sp,sp,-64
 4d2:	fc06                	sd	ra,56(sp)
 4d4:	f822                	sd	s0,48(sp)
 4d6:	f426                	sd	s1,40(sp)
 4d8:	f04a                	sd	s2,32(sp)
 4da:	ec4e                	sd	s3,24(sp)
 4dc:	0080                	addi	s0,sp,64
 4de:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4e0:	c299                	beqz	a3,4e6 <printint+0x16>
 4e2:	0805c863          	bltz	a1,572 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4e6:	2581                	sext.w	a1,a1
  neg = 0;
 4e8:	4881                	li	a7,0
 4ea:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4ee:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4f0:	2601                	sext.w	a2,a2
 4f2:	00000517          	auipc	a0,0x0
 4f6:	55e50513          	addi	a0,a0,1374 # a50 <digits>
 4fa:	883a                	mv	a6,a4
 4fc:	2705                	addiw	a4,a4,1
 4fe:	02c5f7bb          	remuw	a5,a1,a2
 502:	1782                	slli	a5,a5,0x20
 504:	9381                	srli	a5,a5,0x20
 506:	97aa                	add	a5,a5,a0
 508:	0007c783          	lbu	a5,0(a5)
 50c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 510:	0005879b          	sext.w	a5,a1
 514:	02c5d5bb          	divuw	a1,a1,a2
 518:	0685                	addi	a3,a3,1
 51a:	fec7f0e3          	bgeu	a5,a2,4fa <printint+0x2a>
  if(neg)
 51e:	00088b63          	beqz	a7,534 <printint+0x64>
    buf[i++] = '-';
 522:	fd040793          	addi	a5,s0,-48
 526:	973e                	add	a4,a4,a5
 528:	02d00793          	li	a5,45
 52c:	fef70823          	sb	a5,-16(a4)
 530:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 534:	02e05863          	blez	a4,564 <printint+0x94>
 538:	fc040793          	addi	a5,s0,-64
 53c:	00e78933          	add	s2,a5,a4
 540:	fff78993          	addi	s3,a5,-1
 544:	99ba                	add	s3,s3,a4
 546:	377d                	addiw	a4,a4,-1
 548:	1702                	slli	a4,a4,0x20
 54a:	9301                	srli	a4,a4,0x20
 54c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 550:	fff94583          	lbu	a1,-1(s2)
 554:	8526                	mv	a0,s1
 556:	00000097          	auipc	ra,0x0
 55a:	f58080e7          	jalr	-168(ra) # 4ae <putc>
  while(--i >= 0)
 55e:	197d                	addi	s2,s2,-1
 560:	ff3918e3          	bne	s2,s3,550 <printint+0x80>
}
 564:	70e2                	ld	ra,56(sp)
 566:	7442                	ld	s0,48(sp)
 568:	74a2                	ld	s1,40(sp)
 56a:	7902                	ld	s2,32(sp)
 56c:	69e2                	ld	s3,24(sp)
 56e:	6121                	addi	sp,sp,64
 570:	8082                	ret
    x = -xx;
 572:	40b005bb          	negw	a1,a1
    neg = 1;
 576:	4885                	li	a7,1
    x = -xx;
 578:	bf8d                	j	4ea <printint+0x1a>

000000000000057a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 57a:	7119                	addi	sp,sp,-128
 57c:	fc86                	sd	ra,120(sp)
 57e:	f8a2                	sd	s0,112(sp)
 580:	f4a6                	sd	s1,104(sp)
 582:	f0ca                	sd	s2,96(sp)
 584:	ecce                	sd	s3,88(sp)
 586:	e8d2                	sd	s4,80(sp)
 588:	e4d6                	sd	s5,72(sp)
 58a:	e0da                	sd	s6,64(sp)
 58c:	fc5e                	sd	s7,56(sp)
 58e:	f862                	sd	s8,48(sp)
 590:	f466                	sd	s9,40(sp)
 592:	f06a                	sd	s10,32(sp)
 594:	ec6e                	sd	s11,24(sp)
 596:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 598:	0005c903          	lbu	s2,0(a1)
 59c:	18090f63          	beqz	s2,73a <vprintf+0x1c0>
 5a0:	8aaa                	mv	s5,a0
 5a2:	8b32                	mv	s6,a2
 5a4:	00158493          	addi	s1,a1,1
  state = 0;
 5a8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5aa:	02500a13          	li	s4,37
      if(c == 'd'){
 5ae:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5b2:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5b6:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5ba:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5be:	00000b97          	auipc	s7,0x0
 5c2:	492b8b93          	addi	s7,s7,1170 # a50 <digits>
 5c6:	a839                	j	5e4 <vprintf+0x6a>
        putc(fd, c);
 5c8:	85ca                	mv	a1,s2
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	ee2080e7          	jalr	-286(ra) # 4ae <putc>
 5d4:	a019                	j	5da <vprintf+0x60>
    } else if(state == '%'){
 5d6:	01498f63          	beq	s3,s4,5f4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5da:	0485                	addi	s1,s1,1
 5dc:	fff4c903          	lbu	s2,-1(s1)
 5e0:	14090d63          	beqz	s2,73a <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5e4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5e8:	fe0997e3          	bnez	s3,5d6 <vprintf+0x5c>
      if(c == '%'){
 5ec:	fd479ee3          	bne	a5,s4,5c8 <vprintf+0x4e>
        state = '%';
 5f0:	89be                	mv	s3,a5
 5f2:	b7e5                	j	5da <vprintf+0x60>
      if(c == 'd'){
 5f4:	05878063          	beq	a5,s8,634 <vprintf+0xba>
      } else if(c == 'l') {
 5f8:	05978c63          	beq	a5,s9,650 <vprintf+0xd6>
      } else if(c == 'x') {
 5fc:	07a78863          	beq	a5,s10,66c <vprintf+0xf2>
      } else if(c == 'p') {
 600:	09b78463          	beq	a5,s11,688 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 604:	07300713          	li	a4,115
 608:	0ce78663          	beq	a5,a4,6d4 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 60c:	06300713          	li	a4,99
 610:	0ee78e63          	beq	a5,a4,70c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 614:	11478863          	beq	a5,s4,724 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 618:	85d2                	mv	a1,s4
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	e92080e7          	jalr	-366(ra) # 4ae <putc>
        putc(fd, c);
 624:	85ca                	mv	a1,s2
 626:	8556                	mv	a0,s5
 628:	00000097          	auipc	ra,0x0
 62c:	e86080e7          	jalr	-378(ra) # 4ae <putc>
      }
      state = 0;
 630:	4981                	li	s3,0
 632:	b765                	j	5da <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 634:	008b0913          	addi	s2,s6,8
 638:	4685                	li	a3,1
 63a:	4629                	li	a2,10
 63c:	000b2583          	lw	a1,0(s6)
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	e8e080e7          	jalr	-370(ra) # 4d0 <printint>
 64a:	8b4a                	mv	s6,s2
      state = 0;
 64c:	4981                	li	s3,0
 64e:	b771                	j	5da <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 650:	008b0913          	addi	s2,s6,8
 654:	4681                	li	a3,0
 656:	4629                	li	a2,10
 658:	000b2583          	lw	a1,0(s6)
 65c:	8556                	mv	a0,s5
 65e:	00000097          	auipc	ra,0x0
 662:	e72080e7          	jalr	-398(ra) # 4d0 <printint>
 666:	8b4a                	mv	s6,s2
      state = 0;
 668:	4981                	li	s3,0
 66a:	bf85                	j	5da <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 66c:	008b0913          	addi	s2,s6,8
 670:	4681                	li	a3,0
 672:	4641                	li	a2,16
 674:	000b2583          	lw	a1,0(s6)
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	e56080e7          	jalr	-426(ra) # 4d0 <printint>
 682:	8b4a                	mv	s6,s2
      state = 0;
 684:	4981                	li	s3,0
 686:	bf91                	j	5da <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 688:	008b0793          	addi	a5,s6,8
 68c:	f8f43423          	sd	a5,-120(s0)
 690:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 694:	03000593          	li	a1,48
 698:	8556                	mv	a0,s5
 69a:	00000097          	auipc	ra,0x0
 69e:	e14080e7          	jalr	-492(ra) # 4ae <putc>
  putc(fd, 'x');
 6a2:	85ea                	mv	a1,s10
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	e08080e7          	jalr	-504(ra) # 4ae <putc>
 6ae:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b0:	03c9d793          	srli	a5,s3,0x3c
 6b4:	97de                	add	a5,a5,s7
 6b6:	0007c583          	lbu	a1,0(a5)
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	df2080e7          	jalr	-526(ra) # 4ae <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c4:	0992                	slli	s3,s3,0x4
 6c6:	397d                	addiw	s2,s2,-1
 6c8:	fe0914e3          	bnez	s2,6b0 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6cc:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	b721                	j	5da <vprintf+0x60>
        s = va_arg(ap, char*);
 6d4:	008b0993          	addi	s3,s6,8
 6d8:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6dc:	02090163          	beqz	s2,6fe <vprintf+0x184>
        while(*s != 0){
 6e0:	00094583          	lbu	a1,0(s2)
 6e4:	c9a1                	beqz	a1,734 <vprintf+0x1ba>
          putc(fd, *s);
 6e6:	8556                	mv	a0,s5
 6e8:	00000097          	auipc	ra,0x0
 6ec:	dc6080e7          	jalr	-570(ra) # 4ae <putc>
          s++;
 6f0:	0905                	addi	s2,s2,1
        while(*s != 0){
 6f2:	00094583          	lbu	a1,0(s2)
 6f6:	f9e5                	bnez	a1,6e6 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6f8:	8b4e                	mv	s6,s3
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	bdf9                	j	5da <vprintf+0x60>
          s = "(null)";
 6fe:	00000917          	auipc	s2,0x0
 702:	34a90913          	addi	s2,s2,842 # a48 <malloc+0x204>
        while(*s != 0){
 706:	02800593          	li	a1,40
 70a:	bff1                	j	6e6 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 70c:	008b0913          	addi	s2,s6,8
 710:	000b4583          	lbu	a1,0(s6)
 714:	8556                	mv	a0,s5
 716:	00000097          	auipc	ra,0x0
 71a:	d98080e7          	jalr	-616(ra) # 4ae <putc>
 71e:	8b4a                	mv	s6,s2
      state = 0;
 720:	4981                	li	s3,0
 722:	bd65                	j	5da <vprintf+0x60>
        putc(fd, c);
 724:	85d2                	mv	a1,s4
 726:	8556                	mv	a0,s5
 728:	00000097          	auipc	ra,0x0
 72c:	d86080e7          	jalr	-634(ra) # 4ae <putc>
      state = 0;
 730:	4981                	li	s3,0
 732:	b565                	j	5da <vprintf+0x60>
        s = va_arg(ap, char*);
 734:	8b4e                	mv	s6,s3
      state = 0;
 736:	4981                	li	s3,0
 738:	b54d                	j	5da <vprintf+0x60>
    }
  }
}
 73a:	70e6                	ld	ra,120(sp)
 73c:	7446                	ld	s0,112(sp)
 73e:	74a6                	ld	s1,104(sp)
 740:	7906                	ld	s2,96(sp)
 742:	69e6                	ld	s3,88(sp)
 744:	6a46                	ld	s4,80(sp)
 746:	6aa6                	ld	s5,72(sp)
 748:	6b06                	ld	s6,64(sp)
 74a:	7be2                	ld	s7,56(sp)
 74c:	7c42                	ld	s8,48(sp)
 74e:	7ca2                	ld	s9,40(sp)
 750:	7d02                	ld	s10,32(sp)
 752:	6de2                	ld	s11,24(sp)
 754:	6109                	addi	sp,sp,128
 756:	8082                	ret

0000000000000758 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 758:	715d                	addi	sp,sp,-80
 75a:	ec06                	sd	ra,24(sp)
 75c:	e822                	sd	s0,16(sp)
 75e:	1000                	addi	s0,sp,32
 760:	e010                	sd	a2,0(s0)
 762:	e414                	sd	a3,8(s0)
 764:	e818                	sd	a4,16(s0)
 766:	ec1c                	sd	a5,24(s0)
 768:	03043023          	sd	a6,32(s0)
 76c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 770:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 774:	8622                	mv	a2,s0
 776:	00000097          	auipc	ra,0x0
 77a:	e04080e7          	jalr	-508(ra) # 57a <vprintf>
}
 77e:	60e2                	ld	ra,24(sp)
 780:	6442                	ld	s0,16(sp)
 782:	6161                	addi	sp,sp,80
 784:	8082                	ret

0000000000000786 <printf>:

void
printf(const char *fmt, ...)
{
 786:	711d                	addi	sp,sp,-96
 788:	ec06                	sd	ra,24(sp)
 78a:	e822                	sd	s0,16(sp)
 78c:	1000                	addi	s0,sp,32
 78e:	e40c                	sd	a1,8(s0)
 790:	e810                	sd	a2,16(s0)
 792:	ec14                	sd	a3,24(s0)
 794:	f018                	sd	a4,32(s0)
 796:	f41c                	sd	a5,40(s0)
 798:	03043823          	sd	a6,48(s0)
 79c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7a0:	00840613          	addi	a2,s0,8
 7a4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7a8:	85aa                	mv	a1,a0
 7aa:	4505                	li	a0,1
 7ac:	00000097          	auipc	ra,0x0
 7b0:	dce080e7          	jalr	-562(ra) # 57a <vprintf>
}
 7b4:	60e2                	ld	ra,24(sp)
 7b6:	6442                	ld	s0,16(sp)
 7b8:	6125                	addi	sp,sp,96
 7ba:	8082                	ret

00000000000007bc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7bc:	1141                	addi	sp,sp,-16
 7be:	e422                	sd	s0,8(sp)
 7c0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7c2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c6:	00000797          	auipc	a5,0x0
 7ca:	2a27b783          	ld	a5,674(a5) # a68 <freep>
 7ce:	a805                	j	7fe <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7d0:	4618                	lw	a4,8(a2)
 7d2:	9db9                	addw	a1,a1,a4
 7d4:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d8:	6398                	ld	a4,0(a5)
 7da:	6318                	ld	a4,0(a4)
 7dc:	fee53823          	sd	a4,-16(a0)
 7e0:	a091                	j	824 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7e2:	ff852703          	lw	a4,-8(a0)
 7e6:	9e39                	addw	a2,a2,a4
 7e8:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7ea:	ff053703          	ld	a4,-16(a0)
 7ee:	e398                	sd	a4,0(a5)
 7f0:	a099                	j	836 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f2:	6398                	ld	a4,0(a5)
 7f4:	00e7e463          	bltu	a5,a4,7fc <free+0x40>
 7f8:	00e6ea63          	bltu	a3,a4,80c <free+0x50>
{
 7fc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fe:	fed7fae3          	bgeu	a5,a3,7f2 <free+0x36>
 802:	6398                	ld	a4,0(a5)
 804:	00e6e463          	bltu	a3,a4,80c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 808:	fee7eae3          	bltu	a5,a4,7fc <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 80c:	ff852583          	lw	a1,-8(a0)
 810:	6390                	ld	a2,0(a5)
 812:	02059713          	slli	a4,a1,0x20
 816:	9301                	srli	a4,a4,0x20
 818:	0712                	slli	a4,a4,0x4
 81a:	9736                	add	a4,a4,a3
 81c:	fae60ae3          	beq	a2,a4,7d0 <free+0x14>
    bp->s.ptr = p->s.ptr;
 820:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 824:	4790                	lw	a2,8(a5)
 826:	02061713          	slli	a4,a2,0x20
 82a:	9301                	srli	a4,a4,0x20
 82c:	0712                	slli	a4,a4,0x4
 82e:	973e                	add	a4,a4,a5
 830:	fae689e3          	beq	a3,a4,7e2 <free+0x26>
  } else
    p->s.ptr = bp;
 834:	e394                	sd	a3,0(a5)
  freep = p;
 836:	00000717          	auipc	a4,0x0
 83a:	22f73923          	sd	a5,562(a4) # a68 <freep>
}
 83e:	6422                	ld	s0,8(sp)
 840:	0141                	addi	sp,sp,16
 842:	8082                	ret

0000000000000844 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 844:	7139                	addi	sp,sp,-64
 846:	fc06                	sd	ra,56(sp)
 848:	f822                	sd	s0,48(sp)
 84a:	f426                	sd	s1,40(sp)
 84c:	f04a                	sd	s2,32(sp)
 84e:	ec4e                	sd	s3,24(sp)
 850:	e852                	sd	s4,16(sp)
 852:	e456                	sd	s5,8(sp)
 854:	e05a                	sd	s6,0(sp)
 856:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 858:	02051493          	slli	s1,a0,0x20
 85c:	9081                	srli	s1,s1,0x20
 85e:	04bd                	addi	s1,s1,15
 860:	8091                	srli	s1,s1,0x4
 862:	0014899b          	addiw	s3,s1,1
 866:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 868:	00000517          	auipc	a0,0x0
 86c:	20053503          	ld	a0,512(a0) # a68 <freep>
 870:	c515                	beqz	a0,89c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 872:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 874:	4798                	lw	a4,8(a5)
 876:	02977f63          	bgeu	a4,s1,8b4 <malloc+0x70>
 87a:	8a4e                	mv	s4,s3
 87c:	0009871b          	sext.w	a4,s3
 880:	6685                	lui	a3,0x1
 882:	00d77363          	bgeu	a4,a3,888 <malloc+0x44>
 886:	6a05                	lui	s4,0x1
 888:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 88c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 890:	00000917          	auipc	s2,0x0
 894:	1d890913          	addi	s2,s2,472 # a68 <freep>
  if(p == (char*)-1)
 898:	5afd                	li	s5,-1
 89a:	a88d                	j	90c <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 89c:	00000797          	auipc	a5,0x0
 8a0:	1d478793          	addi	a5,a5,468 # a70 <base>
 8a4:	00000717          	auipc	a4,0x0
 8a8:	1cf73223          	sd	a5,452(a4) # a68 <freep>
 8ac:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ae:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8b2:	b7e1                	j	87a <malloc+0x36>
      if(p->s.size == nunits)
 8b4:	02e48b63          	beq	s1,a4,8ea <malloc+0xa6>
        p->s.size -= nunits;
 8b8:	4137073b          	subw	a4,a4,s3
 8bc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8be:	1702                	slli	a4,a4,0x20
 8c0:	9301                	srli	a4,a4,0x20
 8c2:	0712                	slli	a4,a4,0x4
 8c4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8c6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ca:	00000717          	auipc	a4,0x0
 8ce:	18a73f23          	sd	a0,414(a4) # a68 <freep>
      return (void*)(p + 1);
 8d2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8d6:	70e2                	ld	ra,56(sp)
 8d8:	7442                	ld	s0,48(sp)
 8da:	74a2                	ld	s1,40(sp)
 8dc:	7902                	ld	s2,32(sp)
 8de:	69e2                	ld	s3,24(sp)
 8e0:	6a42                	ld	s4,16(sp)
 8e2:	6aa2                	ld	s5,8(sp)
 8e4:	6b02                	ld	s6,0(sp)
 8e6:	6121                	addi	sp,sp,64
 8e8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8ea:	6398                	ld	a4,0(a5)
 8ec:	e118                	sd	a4,0(a0)
 8ee:	bff1                	j	8ca <malloc+0x86>
  hp->s.size = nu;
 8f0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8f4:	0541                	addi	a0,a0,16
 8f6:	00000097          	auipc	ra,0x0
 8fa:	ec6080e7          	jalr	-314(ra) # 7bc <free>
  return freep;
 8fe:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 902:	d971                	beqz	a0,8d6 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 904:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 906:	4798                	lw	a4,8(a5)
 908:	fa9776e3          	bgeu	a4,s1,8b4 <malloc+0x70>
    if(p == freep)
 90c:	00093703          	ld	a4,0(s2)
 910:	853e                	mv	a0,a5
 912:	fef719e3          	bne	a4,a5,904 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 916:	8552                	mv	a0,s4
 918:	00000097          	auipc	ra,0x0
 91c:	b6e080e7          	jalr	-1170(ra) # 486 <sbrk>
  if(p == (char*)-1)
 920:	fd5518e3          	bne	a0,s5,8f0 <malloc+0xac>
        return 0;
 924:	4501                	li	a0,0
 926:	bf45                	j	8d6 <malloc+0x92>
