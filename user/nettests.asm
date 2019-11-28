
user/_nettests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <decode_qname>:
}

// Decode a DNS name
static void
decode_qname(char *qn)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  while(*qn != '\0') {
   6:	00054783          	lbu	a5,0(a0)
    int l = *qn;
   a:	0007861b          	sext.w	a2,a5
    if(l == 0)
      break;
    for(int i = 0; i < l; i++) {
   e:	4581                	li	a1,0
  10:	4885                	li	a7,1
      *qn = *(qn+1);
      qn++;
    }
    *qn++ = '.';
  12:	02e00813          	li	a6,46
  while(*qn != '\0') {
  16:	ef81                	bnez	a5,2e <decode_qname+0x2e>
  }
}
  18:	6422                	ld	s0,8(sp)
  1a:	0141                	addi	sp,sp,16
  1c:	8082                	ret
    *qn++ = '.';
  1e:	0709                	addi	a4,a4,2
  20:	953a                	add	a0,a0,a4
  22:	01078023          	sb	a6,0(a5)
  while(*qn != '\0') {
  26:	0017c603          	lbu	a2,1(a5)
  2a:	d67d                	beqz	a2,18 <decode_qname+0x18>
    int l = *qn;
  2c:	2601                	sext.w	a2,a2
{
  2e:	87aa                	mv	a5,a0
    for(int i = 0; i < l; i++) {
  30:	872e                	mv	a4,a1
      *qn = *(qn+1);
  32:	0017c683          	lbu	a3,1(a5)
  36:	00d78023          	sb	a3,0(a5)
      qn++;
  3a:	0785                	addi	a5,a5,1
    for(int i = 0; i < l; i++) {
  3c:	2705                	addiw	a4,a4,1
  3e:	fec74ae3          	blt	a4,a2,32 <decode_qname+0x32>
  42:	fff6069b          	addiw	a3,a2,-1
  46:	1682                	slli	a3,a3,0x20
  48:	9281                	srli	a3,a3,0x20
  4a:	87c6                	mv	a5,a7
  4c:	00c05463          	blez	a2,54 <decode_qname+0x54>
  50:	00168793          	addi	a5,a3,1
  54:	97aa                	add	a5,a5,a0
    *qn++ = '.';
  56:	872e                	mv	a4,a1
  58:	fcc053e3          	blez	a2,1e <decode_qname+0x1e>
  5c:	8736                	mv	a4,a3
  5e:	b7c1                	j	1e <decode_qname+0x1e>

0000000000000060 <ping>:
{
  60:	7131                	addi	sp,sp,-192
  62:	fd06                	sd	ra,184(sp)
  64:	f922                	sd	s0,176(sp)
  66:	f526                	sd	s1,168(sp)
  68:	f14a                	sd	s2,160(sp)
  6a:	ed4e                	sd	s3,152(sp)
  6c:	0180                	addi	s0,sp,192
  6e:	84aa                	mv	s1,a0
  70:	892e                	mv	s2,a1
  72:	89b2                	mv	s3,a2
  char obuf[13] = "hello world!";
  74:	00001797          	auipc	a5,0x1
  78:	fcc78793          	addi	a5,a5,-52 # 1040 <malloc+0x198>
  7c:	6398                	ld	a4,0(a5)
  7e:	fce43023          	sd	a4,-64(s0)
  82:	4798                	lw	a4,8(a5)
  84:	fce42423          	sw	a4,-56(s0)
  88:	00c7c783          	lbu	a5,12(a5)
  8c:	fcf40623          	sb	a5,-52(s0)
  printf("hi1\n");
  90:	00001517          	auipc	a0,0x1
  94:	f0050513          	addi	a0,a0,-256 # f90 <malloc+0xe8>
  98:	00001097          	auipc	ra,0x1
  9c:	d52080e7          	jalr	-686(ra) # dea <printf>
  if((fd = connect(dst, sport, dport)) < 0){
  a0:	864a                	mv	a2,s2
  a2:	85a6                	mv	a1,s1
  a4:	0a000537          	lui	a0,0xa000
  a8:	20250513          	addi	a0,a0,514 # a000202 <__global_pointer$+0x9ffe7e1>
  ac:	00001097          	auipc	ra,0x1
  b0:	a56080e7          	jalr	-1450(ra) # b02 <connect>
  b4:	0c054c63          	bltz	a0,18c <ping+0x12c>
  b8:	892a                	mv	s2,a0
  printf("hi2\n");
  ba:	00001517          	auipc	a0,0x1
  be:	ef650513          	addi	a0,a0,-266 # fb0 <malloc+0x108>
  c2:	00001097          	auipc	ra,0x1
  c6:	d28080e7          	jalr	-728(ra) # dea <printf>
  for(int i = 0; i < attempts; i++) {
  ca:	03305063          	blez	s3,ea <ping+0x8a>
  ce:	4481                	li	s1,0
    if(write(fd, obuf, sizeof(obuf)) < 0){
  d0:	4635                	li	a2,13
  d2:	fc040593          	addi	a1,s0,-64
  d6:	854a                	mv	a0,s2
  d8:	00001097          	auipc	ra,0x1
  dc:	9aa080e7          	jalr	-1622(ra) # a82 <write>
  e0:	0c054463          	bltz	a0,1a8 <ping+0x148>
  for(int i = 0; i < attempts; i++) {
  e4:	2485                	addiw	s1,s1,1
  e6:	fe9995e3          	bne	s3,s1,d0 <ping+0x70>
  printf("hi3\n");
  ea:	00001517          	auipc	a0,0x1
  ee:	ee650513          	addi	a0,a0,-282 # fd0 <malloc+0x128>
  f2:	00001097          	auipc	ra,0x1
  f6:	cf8080e7          	jalr	-776(ra) # dea <printf>
  int cc = read(fd, ibuf, sizeof(ibuf));
  fa:	08000613          	li	a2,128
  fe:	f4040593          	addi	a1,s0,-192
 102:	854a                	mv	a0,s2
 104:	00001097          	auipc	ra,0x1
 108:	976080e7          	jalr	-1674(ra) # a7a <read>
 10c:	84aa                	mv	s1,a0
  if(cc < 0){
 10e:	0a054b63          	bltz	a0,1c4 <ping+0x164>
  printf("hi4\n");
 112:	00001517          	auipc	a0,0x1
 116:	ede50513          	addi	a0,a0,-290 # ff0 <malloc+0x148>
 11a:	00001097          	auipc	ra,0x1
 11e:	cd0080e7          	jalr	-816(ra) # dea <printf>
  printf("\"%s\" : \"%s\"\n", obuf, ibuf);
 122:	f4040613          	addi	a2,s0,-192
 126:	fc040593          	addi	a1,s0,-64
 12a:	00001517          	auipc	a0,0x1
 12e:	ece50513          	addi	a0,a0,-306 # ff8 <malloc+0x150>
 132:	00001097          	auipc	ra,0x1
 136:	cb8080e7          	jalr	-840(ra) # dea <printf>
  printf("%d\n", cc);
 13a:	85a6                	mv	a1,s1
 13c:	00001517          	auipc	a0,0x1
 140:	ecc50513          	addi	a0,a0,-308 # 1008 <malloc+0x160>
 144:	00001097          	auipc	ra,0x1
 148:	ca6080e7          	jalr	-858(ra) # dea <printf>
  close(fd);
 14c:	854a                	mv	a0,s2
 14e:	00001097          	auipc	ra,0x1
 152:	93c080e7          	jalr	-1732(ra) # a8a <close>
  if (strcmp(obuf, ibuf) || cc != sizeof(obuf)){
 156:	f4040593          	addi	a1,s0,-192
 15a:	fc040513          	addi	a0,s0,-64
 15e:	00000097          	auipc	ra,0x0
 162:	6aa080e7          	jalr	1706(ra) # 808 <strcmp>
 166:	ed2d                	bnez	a0,1e0 <ping+0x180>
 168:	47b5                	li	a5,13
 16a:	06f49b63          	bne	s1,a5,1e0 <ping+0x180>
  printf("hi5\n");
 16e:	00001517          	auipc	a0,0x1
 172:	eca50513          	addi	a0,a0,-310 # 1038 <malloc+0x190>
 176:	00001097          	auipc	ra,0x1
 17a:	c74080e7          	jalr	-908(ra) # dea <printf>
}
 17e:	70ea                	ld	ra,184(sp)
 180:	744a                	ld	s0,176(sp)
 182:	74aa                	ld	s1,168(sp)
 184:	790a                	ld	s2,160(sp)
 186:	69ea                	ld	s3,152(sp)
 188:	6129                	addi	sp,sp,192
 18a:	8082                	ret
    fprintf(2, "ping: connect() failed\n");
 18c:	00001597          	auipc	a1,0x1
 190:	e0c58593          	addi	a1,a1,-500 # f98 <malloc+0xf0>
 194:	4509                	li	a0,2
 196:	00001097          	auipc	ra,0x1
 19a:	c26080e7          	jalr	-986(ra) # dbc <fprintf>
    exit(1);
 19e:	4505                	li	a0,1
 1a0:	00001097          	auipc	ra,0x1
 1a4:	8c2080e7          	jalr	-1854(ra) # a62 <exit>
      fprintf(2, "ping: send() failed\n");
 1a8:	00001597          	auipc	a1,0x1
 1ac:	e1058593          	addi	a1,a1,-496 # fb8 <malloc+0x110>
 1b0:	4509                	li	a0,2
 1b2:	00001097          	auipc	ra,0x1
 1b6:	c0a080e7          	jalr	-1014(ra) # dbc <fprintf>
      exit(1);
 1ba:	4505                	li	a0,1
 1bc:	00001097          	auipc	ra,0x1
 1c0:	8a6080e7          	jalr	-1882(ra) # a62 <exit>
    fprintf(2, "ping: recv() failed\n");
 1c4:	00001597          	auipc	a1,0x1
 1c8:	e1458593          	addi	a1,a1,-492 # fd8 <malloc+0x130>
 1cc:	4509                	li	a0,2
 1ce:	00001097          	auipc	ra,0x1
 1d2:	bee080e7          	jalr	-1042(ra) # dbc <fprintf>
    exit(1);
 1d6:	4505                	li	a0,1
 1d8:	00001097          	auipc	ra,0x1
 1dc:	88a080e7          	jalr	-1910(ra) # a62 <exit>
    fprintf(2, "ping didn't receive correct payload\n");
 1e0:	00001597          	auipc	a1,0x1
 1e4:	e3058593          	addi	a1,a1,-464 # 1010 <malloc+0x168>
 1e8:	4509                	li	a0,2
 1ea:	00001097          	auipc	ra,0x1
 1ee:	bd2080e7          	jalr	-1070(ra) # dbc <fprintf>
    exit(1);
 1f2:	4505                	li	a0,1
 1f4:	00001097          	auipc	ra,0x1
 1f8:	86e080e7          	jalr	-1938(ra) # a62 <exit>

00000000000001fc <dns>:
  }
}

static void
dns()
{
 1fc:	7119                	addi	sp,sp,-128
 1fe:	fc86                	sd	ra,120(sp)
 200:	f8a2                	sd	s0,112(sp)
 202:	f4a6                	sd	s1,104(sp)
 204:	f0ca                	sd	s2,96(sp)
 206:	ecce                	sd	s3,88(sp)
 208:	e8d2                	sd	s4,80(sp)
 20a:	e4d6                	sd	s5,72(sp)
 20c:	e0da                	sd	s6,64(sp)
 20e:	fc5e                	sd	s7,56(sp)
 210:	f862                	sd	s8,48(sp)
 212:	f466                	sd	s9,40(sp)
 214:	f06a                	sd	s10,32(sp)
 216:	ec6e                	sd	s11,24(sp)
 218:	0100                	addi	s0,sp,128
 21a:	83010113          	addi	sp,sp,-2000
  uint8 ibuf[N];
  uint32 dst;
  int fd;
  int len;

  memset(obuf, 0, N);
 21e:	3e800613          	li	a2,1000
 222:	4581                	li	a1,0
 224:	ba840513          	addi	a0,s0,-1112
 228:	00000097          	auipc	ra,0x0
 22c:	636080e7          	jalr	1590(ra) # 85e <memset>
  memset(ibuf, 0, N);
 230:	3e800613          	li	a2,1000
 234:	4581                	li	a1,0
 236:	77fd                	lui	a5,0xfffff
 238:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffdd9f>
 23c:	00f40533          	add	a0,s0,a5
 240:	00000097          	auipc	ra,0x0
 244:	61e080e7          	jalr	1566(ra) # 85e <memset>

  // 8.8.8.8: google's name server
  dst = (8 << 24) | (8 << 16) | (8 << 8) | (8 << 0);

  if((fd = connect(dst, 10000, 53)) < 0){
 248:	03500613          	li	a2,53
 24c:	6589                	lui	a1,0x2
 24e:	71058593          	addi	a1,a1,1808 # 2710 <__global_pointer$+0xcef>
 252:	08081537          	lui	a0,0x8081
 256:	80850513          	addi	a0,a0,-2040 # 8080808 <__global_pointer$+0x807ede7>
 25a:	00001097          	auipc	ra,0x1
 25e:	8a8080e7          	jalr	-1880(ra) # b02 <connect>
 262:	02054d63          	bltz	a0,29c <dns+0xa0>
 266:	892a                	mv	s2,a0
  hdr->id = htons(6828);
 268:	77ed                	lui	a5,0xffffb
 26a:	c1a78793          	addi	a5,a5,-998 # ffffffffffffac1a <__global_pointer$+0xffffffffffff91f9>
 26e:	baf41423          	sh	a5,-1112(s0)
  hdr->rd = 1;
 272:	baa45783          	lhu	a5,-1110(s0)
 276:	0017e793          	ori	a5,a5,1
 27a:	baf41523          	sh	a5,-1110(s0)
  hdr->qdcount = htons(1);
 27e:	10000793          	li	a5,256
 282:	baf41623          	sh	a5,-1108(s0)
  for(char *c = host; c < host+strlen(host)+1; c++) {
 286:	00001497          	auipc	s1,0x1
 28a:	dca48493          	addi	s1,s1,-566 # 1050 <malloc+0x1a8>
  char *l = host;
 28e:	8a26                	mv	s4,s1
  for(char *c = host; c < host+strlen(host)+1; c++) {
 290:	bb440993          	addi	s3,s0,-1100
 294:	8aa6                	mv	s5,s1
    if(*c == '.') {
 296:	02e00b13          	li	s6,46
  for(char *c = host; c < host+strlen(host)+1; c++) {
 29a:	a01d                	j	2c0 <dns+0xc4>
    fprintf(2, "ping: connect() failed\n");
 29c:	00001597          	auipc	a1,0x1
 2a0:	cfc58593          	addi	a1,a1,-772 # f98 <malloc+0xf0>
 2a4:	4509                	li	a0,2
 2a6:	00001097          	auipc	ra,0x1
 2aa:	b16080e7          	jalr	-1258(ra) # dbc <fprintf>
    exit(1);
 2ae:	4505                	li	a0,1
 2b0:	00000097          	auipc	ra,0x0
 2b4:	7b2080e7          	jalr	1970(ra) # a62 <exit>
      *qn++ = (char) (c-l);
 2b8:	89b6                	mv	s3,a3
      l = c+1; // skip .
 2ba:	00148a13          	addi	s4,s1,1
  for(char *c = host; c < host+strlen(host)+1; c++) {
 2be:	0485                	addi	s1,s1,1
 2c0:	8556                	mv	a0,s5
 2c2:	00000097          	auipc	ra,0x0
 2c6:	572080e7          	jalr	1394(ra) # 834 <strlen>
 2ca:	1502                	slli	a0,a0,0x20
 2cc:	9101                	srli	a0,a0,0x20
 2ce:	0505                	addi	a0,a0,1
 2d0:	9556                	add	a0,a0,s5
 2d2:	02a4fc63          	bgeu	s1,a0,30a <dns+0x10e>
    if(*c == '.') {
 2d6:	0004c783          	lbu	a5,0(s1)
 2da:	ff6792e3          	bne	a5,s6,2be <dns+0xc2>
      *qn++ = (char) (c-l);
 2de:	00198693          	addi	a3,s3,1
 2e2:	414487b3          	sub	a5,s1,s4
 2e6:	00f98023          	sb	a5,0(s3)
      for(char *d = l; d < c; d++) {
 2ea:	fc9a77e3          	bgeu	s4,s1,2b8 <dns+0xbc>
 2ee:	87d2                	mv	a5,s4
      *qn++ = (char) (c-l);
 2f0:	8736                	mv	a4,a3
        *qn++ = *d;
 2f2:	0705                	addi	a4,a4,1
 2f4:	0007c603          	lbu	a2,0(a5)
 2f8:	fec70fa3          	sb	a2,-1(a4)
      for(char *d = l; d < c; d++) {
 2fc:	0785                	addi	a5,a5,1
 2fe:	fef49ae3          	bne	s1,a5,2f2 <dns+0xf6>
 302:	414489b3          	sub	s3,s1,s4
 306:	99b6                	add	s3,s3,a3
 308:	bf4d                	j	2ba <dns+0xbe>
  *qn = '\0';
 30a:	00098023          	sb	zero,0(s3)
  len += strlen(qname) + 1;
 30e:	bb440513          	addi	a0,s0,-1100
 312:	00000097          	auipc	ra,0x0
 316:	522080e7          	jalr	1314(ra) # 834 <strlen>
 31a:	0005049b          	sext.w	s1,a0
  struct dns_question *h = (struct dns_question *) (qname+strlen(qname)+1);
 31e:	bb440513          	addi	a0,s0,-1100
 322:	00000097          	auipc	ra,0x0
 326:	512080e7          	jalr	1298(ra) # 834 <strlen>
 32a:	02051793          	slli	a5,a0,0x20
 32e:	9381                	srli	a5,a5,0x20
 330:	0785                	addi	a5,a5,1
 332:	bb440713          	addi	a4,s0,-1100
 336:	97ba                	add	a5,a5,a4
  h->qtype = htons(0x1);
 338:	00078023          	sb	zero,0(a5)
 33c:	4705                	li	a4,1
 33e:	00e780a3          	sb	a4,1(a5)
  h->qclass = htons(0x1);
 342:	00078123          	sb	zero,2(a5)
 346:	00e781a3          	sb	a4,3(a5)
  }

  len = dns_req(obuf);

  if(write(fd, obuf, len) < 0){
 34a:	0114861b          	addiw	a2,s1,17
 34e:	ba840593          	addi	a1,s0,-1112
 352:	854a                	mv	a0,s2
 354:	00000097          	auipc	ra,0x0
 358:	72e080e7          	jalr	1838(ra) # a82 <write>
 35c:	10054e63          	bltz	a0,478 <dns+0x27c>
    fprintf(2, "dns: send() failed\n");
    exit(1);
  }
  int cc = read(fd, ibuf, sizeof(ibuf));
 360:	3e800613          	li	a2,1000
 364:	77fd                	lui	a5,0xfffff
 366:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffdd9f>
 36a:	00f405b3          	add	a1,s0,a5
 36e:	854a                	mv	a0,s2
 370:	00000097          	auipc	ra,0x0
 374:	70a080e7          	jalr	1802(ra) # a7a <read>
 378:	89aa                	mv	s3,a0
  if(cc < 0){
 37a:	10054d63          	bltz	a0,494 <dns+0x298>
  if(!hdr->qr) {
 37e:	77fd                	lui	a5,0xfffff
 380:	7c278793          	addi	a5,a5,1986 # fffffffffffff7c2 <__global_pointer$+0xffffffffffffdda1>
 384:	97a2                	add	a5,a5,s0
 386:	00078783          	lb	a5,0(a5)
 38a:	1207d363          	bgez	a5,4b0 <dns+0x2b4>
  if(hdr->id != htons(6828))
 38e:	77fd                	lui	a5,0xfffff
 390:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffdd9f>
 394:	97a2                	add	a5,a5,s0
 396:	0007d783          	lhu	a5,0(a5)
 39a:	0007869b          	sext.w	a3,a5
 39e:	672d                	lui	a4,0xb
 3a0:	c1a70713          	addi	a4,a4,-998 # ac1a <__global_pointer$+0x91f9>
 3a4:	10e69b63          	bne	a3,a4,4ba <dns+0x2be>
  if(hdr->rcode != 0) {
 3a8:	777d                	lui	a4,0xfffff
 3aa:	7c370793          	addi	a5,a4,1987 # fffffffffffff7c3 <__global_pointer$+0xffffffffffffdda2>
 3ae:	97a2                	add	a5,a5,s0
 3b0:	0007c783          	lbu	a5,0(a5)
 3b4:	8bbd                	andi	a5,a5,15
 3b6:	12079263          	bnez	a5,4da <dns+0x2de>
// endianness support
//

static inline uint16 bswaps(uint16 val)
{
  return (((val & 0x00ffU) << 8) |
 3ba:	7c470793          	addi	a5,a4,1988
 3be:	97a2                	add	a5,a5,s0
 3c0:	0007d783          	lhu	a5,0(a5)
 3c4:	0087d71b          	srliw	a4,a5,0x8
 3c8:	0087979b          	slliw	a5,a5,0x8
 3cc:	8fd9                	or	a5,a5,a4
  for(int i =0; i < ntohs(hdr->qdcount); i++) {
 3ce:	17c2                	slli	a5,a5,0x30
 3d0:	93c1                	srli	a5,a5,0x30
 3d2:	4a81                	li	s5,0
  len = sizeof(struct dns);
 3d4:	44b1                	li	s1,12
  char *qname = 0;
 3d6:	4a01                	li	s4,0
  for(int i =0; i < ntohs(hdr->qdcount); i++) {
 3d8:	c3b1                	beqz	a5,41c <dns+0x220>
    char *qn = (char *) (ibuf+len);
 3da:	7b7d                	lui	s6,0xfffff
 3dc:	7c0b0793          	addi	a5,s6,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffdd9f>
 3e0:	97a2                	add	a5,a5,s0
 3e2:	00978a33          	add	s4,a5,s1
    decode_qname(qn);
 3e6:	8552                	mv	a0,s4
 3e8:	00000097          	auipc	ra,0x0
 3ec:	c18080e7          	jalr	-1000(ra) # 0 <decode_qname>
    len += strlen(qn)+1;
 3f0:	8552                	mv	a0,s4
 3f2:	00000097          	auipc	ra,0x0
 3f6:	442080e7          	jalr	1090(ra) # 834 <strlen>
    len += sizeof(struct dns_question);
 3fa:	2515                	addiw	a0,a0,5
 3fc:	9ca9                	addw	s1,s1,a0
  for(int i =0; i < ntohs(hdr->qdcount); i++) {
 3fe:	2a85                	addiw	s5,s5,1
 400:	7c4b0793          	addi	a5,s6,1988
 404:	97a2                	add	a5,a5,s0
 406:	0007d783          	lhu	a5,0(a5)
 40a:	0087d71b          	srliw	a4,a5,0x8
 40e:	0087979b          	slliw	a5,a5,0x8
 412:	8fd9                	or	a5,a5,a4
 414:	17c2                	slli	a5,a5,0x30
 416:	93c1                	srli	a5,a5,0x30
 418:	fcfac1e3          	blt	s5,a5,3da <dns+0x1de>
 41c:	77fd                	lui	a5,0xfffff
 41e:	7c678793          	addi	a5,a5,1990 # fffffffffffff7c6 <__global_pointer$+0xffffffffffffdda5>
 422:	97a2                	add	a5,a5,s0
 424:	0007d783          	lhu	a5,0(a5)
 428:	0087d71b          	srliw	a4,a5,0x8
 42c:	0087979b          	slliw	a5,a5,0x8
 430:	8fd9                	or	a5,a5,a4
  for(int i = 0; i < ntohs(hdr->ancount); i++) {
 432:	17c2                	slli	a5,a5,0x30
 434:	93c1                	srli	a5,a5,0x30
 436:	24078663          	beqz	a5,682 <dns+0x486>
 43a:	00001797          	auipc	a5,0x1
 43e:	cf678793          	addi	a5,a5,-778 # 1130 <malloc+0x288>
 442:	000a0363          	beqz	s4,448 <dns+0x24c>
 446:	87d2                	mv	a5,s4
 448:	76fd                	lui	a3,0xfffff
 44a:	7b068713          	addi	a4,a3,1968 # fffffffffffff7b0 <__global_pointer$+0xffffffffffffdd8f>
 44e:	9722                	add	a4,a4,s0
 450:	e31c                	sd	a5,0(a4)
  int record = 0;
 452:	7b868793          	addi	a5,a3,1976
 456:	97a2                	add	a5,a5,s0
 458:	0007b023          	sd	zero,0(a5)
  for(int i = 0; i < ntohs(hdr->ancount); i++) {
 45c:	4a01                	li	s4,0
    if((int) qn[0] > 63) {  // compression?
 45e:	03f00d93          	li	s11,63
    if(ntohs(d->type) == ARECORD && ntohs(d->len) == 4) {
 462:	4a85                	li	s5,1
 464:	4d11                	li	s10,4
      printf("DNS arecord for %s is ", qname ? qname : "" );
 466:	00001c97          	auipc	s9,0x1
 46a:	c62c8c93          	addi	s9,s9,-926 # 10c8 <malloc+0x220>
      if(ip[0] != 128 || ip[1] != 52 || ip[2] != 129 || ip[3] != 126) {
 46e:	08000c13          	li	s8,128
 472:	03400b93          	li	s7,52
 476:	a8d9                	j	54c <dns+0x350>
    fprintf(2, "dns: send() failed\n");
 478:	00001597          	auipc	a1,0x1
 47c:	bf058593          	addi	a1,a1,-1040 # 1068 <malloc+0x1c0>
 480:	4509                	li	a0,2
 482:	00001097          	auipc	ra,0x1
 486:	93a080e7          	jalr	-1734(ra) # dbc <fprintf>
    exit(1);
 48a:	4505                	li	a0,1
 48c:	00000097          	auipc	ra,0x0
 490:	5d6080e7          	jalr	1494(ra) # a62 <exit>
    fprintf(2, "dns: recv() failed\n");
 494:	00001597          	auipc	a1,0x1
 498:	bec58593          	addi	a1,a1,-1044 # 1080 <malloc+0x1d8>
 49c:	4509                	li	a0,2
 49e:	00001097          	auipc	ra,0x1
 4a2:	91e080e7          	jalr	-1762(ra) # dbc <fprintf>
    exit(1);
 4a6:	4505                	li	a0,1
 4a8:	00000097          	auipc	ra,0x0
 4ac:	5ba080e7          	jalr	1466(ra) # a62 <exit>
    exit(1);
 4b0:	4505                	li	a0,1
 4b2:	00000097          	auipc	ra,0x0
 4b6:	5b0080e7          	jalr	1456(ra) # a62 <exit>
 4ba:	0087d59b          	srliw	a1,a5,0x8
 4be:	0087979b          	slliw	a5,a5,0x8
 4c2:	8ddd                	or	a1,a1,a5
    printf("DNS wrong id: %d\n", ntohs(hdr->id));
 4c4:	15c2                	slli	a1,a1,0x30
 4c6:	91c1                	srli	a1,a1,0x30
 4c8:	00001517          	auipc	a0,0x1
 4cc:	bd050513          	addi	a0,a0,-1072 # 1098 <malloc+0x1f0>
 4d0:	00001097          	auipc	ra,0x1
 4d4:	91a080e7          	jalr	-1766(ra) # dea <printf>
 4d8:	bdc1                	j	3a8 <dns+0x1ac>
    printf("DNS rcode error: %x\n", hdr->rcode);
 4da:	77fd                	lui	a5,0xfffff
 4dc:	7c378793          	addi	a5,a5,1987 # fffffffffffff7c3 <__global_pointer$+0xffffffffffffdda2>
 4e0:	97a2                	add	a5,a5,s0
 4e2:	0007c583          	lbu	a1,0(a5)
 4e6:	89bd                	andi	a1,a1,15
 4e8:	00001517          	auipc	a0,0x1
 4ec:	bc850513          	addi	a0,a0,-1080 # 10b0 <malloc+0x208>
 4f0:	00001097          	auipc	ra,0x1
 4f4:	8fa080e7          	jalr	-1798(ra) # dea <printf>
    exit(1);
 4f8:	4505                	li	a0,1
 4fa:	00000097          	auipc	ra,0x0
 4fe:	568080e7          	jalr	1384(ra) # a62 <exit>
      decode_qname(qn);
 502:	855a                	mv	a0,s6
 504:	00000097          	auipc	ra,0x0
 508:	afc080e7          	jalr	-1284(ra) # 0 <decode_qname>
      len += strlen(qn)+1;
 50c:	855a                	mv	a0,s6
 50e:	00000097          	auipc	ra,0x0
 512:	326080e7          	jalr	806(ra) # 834 <strlen>
 516:	2485                	addiw	s1,s1,1
 518:	9ca9                	addw	s1,s1,a0
 51a:	a0a1                	j	562 <dns+0x366>
      len += 4;
 51c:	00eb049b          	addiw	s1,s6,14
      record = 1;
 520:	77fd                	lui	a5,0xfffff
 522:	7b878793          	addi	a5,a5,1976 # fffffffffffff7b8 <__global_pointer$+0xffffffffffffdd97>
 526:	97a2                	add	a5,a5,s0
 528:	0157b023          	sd	s5,0(a5)
  for(int i = 0; i < ntohs(hdr->ancount); i++) {
 52c:	2a05                	addiw	s4,s4,1
 52e:	77fd                	lui	a5,0xfffff
 530:	7c678793          	addi	a5,a5,1990 # fffffffffffff7c6 <__global_pointer$+0xffffffffffffdda5>
 534:	97a2                	add	a5,a5,s0
 536:	0007d783          	lhu	a5,0(a5)
 53a:	0087d71b          	srliw	a4,a5,0x8
 53e:	0087979b          	slliw	a5,a5,0x8
 542:	8fd9                	or	a5,a5,a4
 544:	17c2                	slli	a5,a5,0x30
 546:	93c1                	srli	a5,a5,0x30
 548:	0efa5263          	bge	s4,a5,62c <dns+0x430>
    char *qn = (char *) (ibuf+len);
 54c:	77fd                	lui	a5,0xfffff
 54e:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffdd9f>
 552:	97a2                	add	a5,a5,s0
 554:	00978b33          	add	s6,a5,s1
    if((int) qn[0] > 63) {  // compression?
 558:	000b4783          	lbu	a5,0(s6)
 55c:	fafdf3e3          	bgeu	s11,a5,502 <dns+0x306>
      len += 2;
 560:	2489                	addiw	s1,s1,2
    struct dns_data *d = (struct dns_data *) (ibuf+len);
 562:	77fd                	lui	a5,0xfffff
 564:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffdd9f>
 568:	97a2                	add	a5,a5,s0
 56a:	009786b3          	add	a3,a5,s1
    len += sizeof(struct dns_data);
 56e:	00048b1b          	sext.w	s6,s1
 572:	24a9                	addiw	s1,s1,10
    if(ntohs(d->type) == ARECORD && ntohs(d->len) == 4) {
 574:	0006c783          	lbu	a5,0(a3)
 578:	0016c703          	lbu	a4,1(a3)
 57c:	0722                	slli	a4,a4,0x8
 57e:	8fd9                	or	a5,a5,a4
 580:	0087979b          	slliw	a5,a5,0x8
 584:	8321                	srli	a4,a4,0x8
 586:	8fd9                	or	a5,a5,a4
 588:	17c2                	slli	a5,a5,0x30
 58a:	93c1                	srli	a5,a5,0x30
 58c:	fb5790e3          	bne	a5,s5,52c <dns+0x330>
 590:	0086c783          	lbu	a5,8(a3)
 594:	0096c703          	lbu	a4,9(a3)
 598:	0722                	slli	a4,a4,0x8
 59a:	8fd9                	or	a5,a5,a4
 59c:	0087979b          	slliw	a5,a5,0x8
 5a0:	8321                	srli	a4,a4,0x8
 5a2:	8fd9                	or	a5,a5,a4
 5a4:	17c2                	slli	a5,a5,0x30
 5a6:	93c1                	srli	a5,a5,0x30
 5a8:	f9a792e3          	bne	a5,s10,52c <dns+0x330>
      printf("DNS arecord for %s is ", qname ? qname : "" );
 5ac:	77fd                	lui	a5,0xfffff
 5ae:	7b078793          	addi	a5,a5,1968 # fffffffffffff7b0 <__global_pointer$+0xffffffffffffdd8f>
 5b2:	97a2                	add	a5,a5,s0
 5b4:	638c                	ld	a1,0(a5)
 5b6:	8566                	mv	a0,s9
 5b8:	00001097          	auipc	ra,0x1
 5bc:	832080e7          	jalr	-1998(ra) # dea <printf>
      uint8 *ip = (ibuf+len);
 5c0:	77fd                	lui	a5,0xfffff
 5c2:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffdd9f>
 5c6:	97a2                	add	a5,a5,s0
 5c8:	94be                	add	s1,s1,a5
      printf("%d.%d.%d.%d\n", ip[0], ip[1], ip[2], ip[3]);
 5ca:	0034c703          	lbu	a4,3(s1)
 5ce:	0024c683          	lbu	a3,2(s1)
 5d2:	0014c603          	lbu	a2,1(s1)
 5d6:	0004c583          	lbu	a1,0(s1)
 5da:	00001517          	auipc	a0,0x1
 5de:	b0650513          	addi	a0,a0,-1274 # 10e0 <malloc+0x238>
 5e2:	00001097          	auipc	ra,0x1
 5e6:	808080e7          	jalr	-2040(ra) # dea <printf>
      if(ip[0] != 128 || ip[1] != 52 || ip[2] != 129 || ip[3] != 126) {
 5ea:	0004c783          	lbu	a5,0(s1)
 5ee:	03879263          	bne	a5,s8,612 <dns+0x416>
 5f2:	0014c783          	lbu	a5,1(s1)
 5f6:	01779e63          	bne	a5,s7,612 <dns+0x416>
 5fa:	0024c703          	lbu	a4,2(s1)
 5fe:	08100793          	li	a5,129
 602:	00f71863          	bne	a4,a5,612 <dns+0x416>
 606:	0034c703          	lbu	a4,3(s1)
 60a:	07e00793          	li	a5,126
 60e:	f0f707e3          	beq	a4,a5,51c <dns+0x320>
        printf("wrong ip address");
 612:	00001517          	auipc	a0,0x1
 616:	ade50513          	addi	a0,a0,-1314 # 10f0 <malloc+0x248>
 61a:	00000097          	auipc	ra,0x0
 61e:	7d0080e7          	jalr	2000(ra) # dea <printf>
        exit(1);
 622:	4505                	li	a0,1
 624:	00000097          	auipc	ra,0x0
 628:	43e080e7          	jalr	1086(ra) # a62 <exit>
  if(len != cc) {
 62c:	04999d63          	bne	s3,s1,686 <dns+0x48a>
  if(!record) {
 630:	77fd                	lui	a5,0xfffff
 632:	7b878793          	addi	a5,a5,1976 # fffffffffffff7b8 <__global_pointer$+0xffffffffffffdd97>
 636:	97a2                	add	a5,a5,s0
 638:	639c                	ld	a5,0(a5)
 63a:	c79d                	beqz	a5,668 <dns+0x46c>
  }
  dns_rep(ibuf, cc);

  close(fd);
 63c:	854a                	mv	a0,s2
 63e:	00000097          	auipc	ra,0x0
 642:	44c080e7          	jalr	1100(ra) # a8a <close>
}
 646:	7d010113          	addi	sp,sp,2000
 64a:	70e6                	ld	ra,120(sp)
 64c:	7446                	ld	s0,112(sp)
 64e:	74a6                	ld	s1,104(sp)
 650:	7906                	ld	s2,96(sp)
 652:	69e6                	ld	s3,88(sp)
 654:	6a46                	ld	s4,80(sp)
 656:	6aa6                	ld	s5,72(sp)
 658:	6b06                	ld	s6,64(sp)
 65a:	7be2                	ld	s7,56(sp)
 65c:	7c42                	ld	s8,48(sp)
 65e:	7ca2                	ld	s9,40(sp)
 660:	7d02                	ld	s10,32(sp)
 662:	6de2                	ld	s11,24(sp)
 664:	6109                	addi	sp,sp,128
 666:	8082                	ret
    printf("Didn't receive an arecord\n");
 668:	00001517          	auipc	a0,0x1
 66c:	ad050513          	addi	a0,a0,-1328 # 1138 <malloc+0x290>
 670:	00000097          	auipc	ra,0x0
 674:	77a080e7          	jalr	1914(ra) # dea <printf>
    exit(1);
 678:	4505                	li	a0,1
 67a:	00000097          	auipc	ra,0x0
 67e:	3e8080e7          	jalr	1000(ra) # a62 <exit>
  if(len != cc) {
 682:	fe9983e3          	beq	s3,s1,668 <dns+0x46c>
    printf("Processed %d data bytes but received %d\n", len, cc);
 686:	864e                	mv	a2,s3
 688:	85a6                	mv	a1,s1
 68a:	00001517          	auipc	a0,0x1
 68e:	a7e50513          	addi	a0,a0,-1410 # 1108 <malloc+0x260>
 692:	00000097          	auipc	ra,0x0
 696:	758080e7          	jalr	1880(ra) # dea <printf>
    exit(1);
 69a:	4505                	li	a0,1
 69c:	00000097          	auipc	ra,0x0
 6a0:	3c6080e7          	jalr	966(ra) # a62 <exit>

00000000000006a4 <main>:

int
main(int argc, char *argv[])
{
 6a4:	7179                	addi	sp,sp,-48
 6a6:	f406                	sd	ra,40(sp)
 6a8:	f022                	sd	s0,32(sp)
 6aa:	ec26                	sd	s1,24(sp)
 6ac:	e84a                	sd	s2,16(sp)
 6ae:	1800                	addi	s0,sp,48
  int i, ret;
  uint16 dport = NET_TESTS_PORT;

  printf("nettests running on port %d\n", dport);
 6b0:	6499                	lui	s1,0x6
 6b2:	40048593          	addi	a1,s1,1024 # 6400 <__global_pointer$+0x49df>
 6b6:	00001517          	auipc	a0,0x1
 6ba:	aa250513          	addi	a0,a0,-1374 # 1158 <malloc+0x2b0>
 6be:	00000097          	auipc	ra,0x0
 6c2:	72c080e7          	jalr	1836(ra) # dea <printf>

  printf("testing one ping: ");
 6c6:	00001517          	auipc	a0,0x1
 6ca:	ab250513          	addi	a0,a0,-1358 # 1178 <malloc+0x2d0>
 6ce:	00000097          	auipc	ra,0x0
 6d2:	71c080e7          	jalr	1820(ra) # dea <printf>
  ping(2000, dport, 2);
 6d6:	4609                	li	a2,2
 6d8:	40048593          	addi	a1,s1,1024
 6dc:	7d000513          	li	a0,2000
 6e0:	00000097          	auipc	ra,0x0
 6e4:	980080e7          	jalr	-1664(ra) # 60 <ping>
  printf("OK\n");
 6e8:	00001517          	auipc	a0,0x1
 6ec:	aa850513          	addi	a0,a0,-1368 # 1190 <malloc+0x2e8>
 6f0:	00000097          	auipc	ra,0x0
 6f4:	6fa080e7          	jalr	1786(ra) # dea <printf>

  printf("testing single-process pings: ");
 6f8:	00001517          	auipc	a0,0x1
 6fc:	aa050513          	addi	a0,a0,-1376 # 1198 <malloc+0x2f0>
 700:	00000097          	auipc	ra,0x0
 704:	6ea080e7          	jalr	1770(ra) # dea <printf>
 708:	4495                	li	s1,5
  for (i = 0; i < 5; i++)
    ping(2000, dport, 1);
 70a:	6919                	lui	s2,0x6
 70c:	40090913          	addi	s2,s2,1024 # 6400 <__global_pointer$+0x49df>
 710:	4605                	li	a2,1
 712:	85ca                	mv	a1,s2
 714:	7d000513          	li	a0,2000
 718:	00000097          	auipc	ra,0x0
 71c:	948080e7          	jalr	-1720(ra) # 60 <ping>
  for (i = 0; i < 5; i++)
 720:	34fd                	addiw	s1,s1,-1
 722:	f4fd                	bnez	s1,710 <main+0x6c>
  printf("OK\n");
 724:	00001517          	auipc	a0,0x1
 728:	a6c50513          	addi	a0,a0,-1428 # 1190 <malloc+0x2e8>
 72c:	00000097          	auipc	ra,0x0
 730:	6be080e7          	jalr	1726(ra) # dea <printf>

  printf("testing multi-process pings: ");
 734:	00001517          	auipc	a0,0x1
 738:	a8450513          	addi	a0,a0,-1404 # 11b8 <malloc+0x310>
 73c:	00000097          	auipc	ra,0x0
 740:	6ae080e7          	jalr	1710(ra) # dea <printf>
  for (i = 0; i < 10; i++){
 744:	4929                	li	s2,10
    int pid = fork();
 746:	00000097          	auipc	ra,0x0
 74a:	314080e7          	jalr	788(ra) # a5a <fork>
    if (pid == 0){
 74e:	c92d                	beqz	a0,7c0 <main+0x11c>
  for (i = 0; i < 10; i++){
 750:	2485                	addiw	s1,s1,1
 752:	ff249ae3          	bne	s1,s2,746 <main+0xa2>
 756:	44a9                	li	s1,10
      ping(2000 + i + 1, dport, 1);
      exit(0);
    }
  }
  for (i = 0; i < 10; i++){
    wait(&ret);
 758:	fdc40513          	addi	a0,s0,-36
 75c:	00000097          	auipc	ra,0x0
 760:	30e080e7          	jalr	782(ra) # a6a <wait>
    if (ret != 0)
 764:	fdc42783          	lw	a5,-36(s0)
 768:	efad                	bnez	a5,7e2 <main+0x13e>
  for (i = 0; i < 10; i++){
 76a:	34fd                	addiw	s1,s1,-1
 76c:	f4f5                	bnez	s1,758 <main+0xb4>
      exit(1);
  }
  printf("OK\n");
 76e:	00001517          	auipc	a0,0x1
 772:	a2250513          	addi	a0,a0,-1502 # 1190 <malloc+0x2e8>
 776:	00000097          	auipc	ra,0x0
 77a:	674080e7          	jalr	1652(ra) # dea <printf>

  printf("testing DNS\n");
 77e:	00001517          	auipc	a0,0x1
 782:	a5a50513          	addi	a0,a0,-1446 # 11d8 <malloc+0x330>
 786:	00000097          	auipc	ra,0x0
 78a:	664080e7          	jalr	1636(ra) # dea <printf>
  dns();
 78e:	00000097          	auipc	ra,0x0
 792:	a6e080e7          	jalr	-1426(ra) # 1fc <dns>
  printf("DNS OK\n");
 796:	00001517          	auipc	a0,0x1
 79a:	a5250513          	addi	a0,a0,-1454 # 11e8 <malloc+0x340>
 79e:	00000097          	auipc	ra,0x0
 7a2:	64c080e7          	jalr	1612(ra) # dea <printf>

  printf("all tests passed.\n");
 7a6:	00001517          	auipc	a0,0x1
 7aa:	a4a50513          	addi	a0,a0,-1462 # 11f0 <malloc+0x348>
 7ae:	00000097          	auipc	ra,0x0
 7b2:	63c080e7          	jalr	1596(ra) # dea <printf>
  exit(0);
 7b6:	4501                	li	a0,0
 7b8:	00000097          	auipc	ra,0x0
 7bc:	2aa080e7          	jalr	682(ra) # a62 <exit>
      ping(2000 + i + 1, dport, 1);
 7c0:	7d14851b          	addiw	a0,s1,2001
 7c4:	4605                	li	a2,1
 7c6:	6599                	lui	a1,0x6
 7c8:	40058593          	addi	a1,a1,1024 # 6400 <__global_pointer$+0x49df>
 7cc:	1542                	slli	a0,a0,0x30
 7ce:	9141                	srli	a0,a0,0x30
 7d0:	00000097          	auipc	ra,0x0
 7d4:	890080e7          	jalr	-1904(ra) # 60 <ping>
      exit(0);
 7d8:	4501                	li	a0,0
 7da:	00000097          	auipc	ra,0x0
 7de:	288080e7          	jalr	648(ra) # a62 <exit>
      exit(1);
 7e2:	4505                	li	a0,1
 7e4:	00000097          	auipc	ra,0x0
 7e8:	27e080e7          	jalr	638(ra) # a62 <exit>

00000000000007ec <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 7ec:	1141                	addi	sp,sp,-16
 7ee:	e422                	sd	s0,8(sp)
 7f0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 7f2:	87aa                	mv	a5,a0
 7f4:	0585                	addi	a1,a1,1
 7f6:	0785                	addi	a5,a5,1
 7f8:	fff5c703          	lbu	a4,-1(a1)
 7fc:	fee78fa3          	sb	a4,-1(a5)
 800:	fb75                	bnez	a4,7f4 <strcpy+0x8>
    ;
  return os;
}
 802:	6422                	ld	s0,8(sp)
 804:	0141                	addi	sp,sp,16
 806:	8082                	ret

0000000000000808 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 808:	1141                	addi	sp,sp,-16
 80a:	e422                	sd	s0,8(sp)
 80c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 80e:	00054783          	lbu	a5,0(a0)
 812:	cb91                	beqz	a5,826 <strcmp+0x1e>
 814:	0005c703          	lbu	a4,0(a1)
 818:	00f71763          	bne	a4,a5,826 <strcmp+0x1e>
    p++, q++;
 81c:	0505                	addi	a0,a0,1
 81e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 820:	00054783          	lbu	a5,0(a0)
 824:	fbe5                	bnez	a5,814 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 826:	0005c503          	lbu	a0,0(a1)
}
 82a:	40a7853b          	subw	a0,a5,a0
 82e:	6422                	ld	s0,8(sp)
 830:	0141                	addi	sp,sp,16
 832:	8082                	ret

0000000000000834 <strlen>:

uint
strlen(const char *s)
{
 834:	1141                	addi	sp,sp,-16
 836:	e422                	sd	s0,8(sp)
 838:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 83a:	00054783          	lbu	a5,0(a0)
 83e:	cf91                	beqz	a5,85a <strlen+0x26>
 840:	0505                	addi	a0,a0,1
 842:	87aa                	mv	a5,a0
 844:	4685                	li	a3,1
 846:	9e89                	subw	a3,a3,a0
 848:	00f6853b          	addw	a0,a3,a5
 84c:	0785                	addi	a5,a5,1
 84e:	fff7c703          	lbu	a4,-1(a5)
 852:	fb7d                	bnez	a4,848 <strlen+0x14>
    ;
  return n;
}
 854:	6422                	ld	s0,8(sp)
 856:	0141                	addi	sp,sp,16
 858:	8082                	ret
  for(n = 0; s[n]; n++)
 85a:	4501                	li	a0,0
 85c:	bfe5                	j	854 <strlen+0x20>

000000000000085e <memset>:

void*
memset(void *dst, int c, uint n)
{
 85e:	1141                	addi	sp,sp,-16
 860:	e422                	sd	s0,8(sp)
 862:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 864:	ce09                	beqz	a2,87e <memset+0x20>
 866:	87aa                	mv	a5,a0
 868:	fff6071b          	addiw	a4,a2,-1
 86c:	1702                	slli	a4,a4,0x20
 86e:	9301                	srli	a4,a4,0x20
 870:	0705                	addi	a4,a4,1
 872:	972a                	add	a4,a4,a0
    cdst[i] = c;
 874:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 878:	0785                	addi	a5,a5,1
 87a:	fee79de3          	bne	a5,a4,874 <memset+0x16>
  }
  return dst;
}
 87e:	6422                	ld	s0,8(sp)
 880:	0141                	addi	sp,sp,16
 882:	8082                	ret

0000000000000884 <strchr>:

char*
strchr(const char *s, char c)
{
 884:	1141                	addi	sp,sp,-16
 886:	e422                	sd	s0,8(sp)
 888:	0800                	addi	s0,sp,16
  for(; *s; s++)
 88a:	00054783          	lbu	a5,0(a0)
 88e:	cb99                	beqz	a5,8a4 <strchr+0x20>
    if(*s == c)
 890:	00f58763          	beq	a1,a5,89e <strchr+0x1a>
  for(; *s; s++)
 894:	0505                	addi	a0,a0,1
 896:	00054783          	lbu	a5,0(a0)
 89a:	fbfd                	bnez	a5,890 <strchr+0xc>
      return (char*)s;
  return 0;
 89c:	4501                	li	a0,0
}
 89e:	6422                	ld	s0,8(sp)
 8a0:	0141                	addi	sp,sp,16
 8a2:	8082                	ret
  return 0;
 8a4:	4501                	li	a0,0
 8a6:	bfe5                	j	89e <strchr+0x1a>

00000000000008a8 <gets>:

char*
gets(char *buf, int max)
{
 8a8:	711d                	addi	sp,sp,-96
 8aa:	ec86                	sd	ra,88(sp)
 8ac:	e8a2                	sd	s0,80(sp)
 8ae:	e4a6                	sd	s1,72(sp)
 8b0:	e0ca                	sd	s2,64(sp)
 8b2:	fc4e                	sd	s3,56(sp)
 8b4:	f852                	sd	s4,48(sp)
 8b6:	f456                	sd	s5,40(sp)
 8b8:	f05a                	sd	s6,32(sp)
 8ba:	ec5e                	sd	s7,24(sp)
 8bc:	1080                	addi	s0,sp,96
 8be:	8baa                	mv	s7,a0
 8c0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 8c2:	892a                	mv	s2,a0
 8c4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 8c6:	4aa9                	li	s5,10
 8c8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 8ca:	89a6                	mv	s3,s1
 8cc:	2485                	addiw	s1,s1,1
 8ce:	0344d863          	bge	s1,s4,8fe <gets+0x56>
    cc = read(0, &c, 1);
 8d2:	4605                	li	a2,1
 8d4:	faf40593          	addi	a1,s0,-81
 8d8:	4501                	li	a0,0
 8da:	00000097          	auipc	ra,0x0
 8de:	1a0080e7          	jalr	416(ra) # a7a <read>
    if(cc < 1)
 8e2:	00a05e63          	blez	a0,8fe <gets+0x56>
    buf[i++] = c;
 8e6:	faf44783          	lbu	a5,-81(s0)
 8ea:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 8ee:	01578763          	beq	a5,s5,8fc <gets+0x54>
 8f2:	0905                	addi	s2,s2,1
 8f4:	fd679be3          	bne	a5,s6,8ca <gets+0x22>
  for(i=0; i+1 < max; ){
 8f8:	89a6                	mv	s3,s1
 8fa:	a011                	j	8fe <gets+0x56>
 8fc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 8fe:	99de                	add	s3,s3,s7
 900:	00098023          	sb	zero,0(s3)
  return buf;
}
 904:	855e                	mv	a0,s7
 906:	60e6                	ld	ra,88(sp)
 908:	6446                	ld	s0,80(sp)
 90a:	64a6                	ld	s1,72(sp)
 90c:	6906                	ld	s2,64(sp)
 90e:	79e2                	ld	s3,56(sp)
 910:	7a42                	ld	s4,48(sp)
 912:	7aa2                	ld	s5,40(sp)
 914:	7b02                	ld	s6,32(sp)
 916:	6be2                	ld	s7,24(sp)
 918:	6125                	addi	sp,sp,96
 91a:	8082                	ret

000000000000091c <stat>:

int
stat(const char *n, struct stat *st)
{
 91c:	1101                	addi	sp,sp,-32
 91e:	ec06                	sd	ra,24(sp)
 920:	e822                	sd	s0,16(sp)
 922:	e426                	sd	s1,8(sp)
 924:	e04a                	sd	s2,0(sp)
 926:	1000                	addi	s0,sp,32
 928:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 92a:	4581                	li	a1,0
 92c:	00000097          	auipc	ra,0x0
 930:	176080e7          	jalr	374(ra) # aa2 <open>
  if(fd < 0)
 934:	02054563          	bltz	a0,95e <stat+0x42>
 938:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 93a:	85ca                	mv	a1,s2
 93c:	00000097          	auipc	ra,0x0
 940:	17e080e7          	jalr	382(ra) # aba <fstat>
 944:	892a                	mv	s2,a0
  close(fd);
 946:	8526                	mv	a0,s1
 948:	00000097          	auipc	ra,0x0
 94c:	142080e7          	jalr	322(ra) # a8a <close>
  return r;
}
 950:	854a                	mv	a0,s2
 952:	60e2                	ld	ra,24(sp)
 954:	6442                	ld	s0,16(sp)
 956:	64a2                	ld	s1,8(sp)
 958:	6902                	ld	s2,0(sp)
 95a:	6105                	addi	sp,sp,32
 95c:	8082                	ret
    return -1;
 95e:	597d                	li	s2,-1
 960:	bfc5                	j	950 <stat+0x34>

0000000000000962 <atoi>:

int
atoi(const char *s)
{
 962:	1141                	addi	sp,sp,-16
 964:	e422                	sd	s0,8(sp)
 966:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 968:	00054603          	lbu	a2,0(a0)
 96c:	fd06079b          	addiw	a5,a2,-48
 970:	0ff7f793          	andi	a5,a5,255
 974:	4725                	li	a4,9
 976:	02f76963          	bltu	a4,a5,9a8 <atoi+0x46>
 97a:	86aa                	mv	a3,a0
  n = 0;
 97c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 97e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 980:	0685                	addi	a3,a3,1
 982:	0025179b          	slliw	a5,a0,0x2
 986:	9fa9                	addw	a5,a5,a0
 988:	0017979b          	slliw	a5,a5,0x1
 98c:	9fb1                	addw	a5,a5,a2
 98e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 992:	0006c603          	lbu	a2,0(a3)
 996:	fd06071b          	addiw	a4,a2,-48
 99a:	0ff77713          	andi	a4,a4,255
 99e:	fee5f1e3          	bgeu	a1,a4,980 <atoi+0x1e>
  return n;
}
 9a2:	6422                	ld	s0,8(sp)
 9a4:	0141                	addi	sp,sp,16
 9a6:	8082                	ret
  n = 0;
 9a8:	4501                	li	a0,0
 9aa:	bfe5                	j	9a2 <atoi+0x40>

00000000000009ac <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 9ac:	1141                	addi	sp,sp,-16
 9ae:	e422                	sd	s0,8(sp)
 9b0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 9b2:	02b57663          	bgeu	a0,a1,9de <memmove+0x32>
    while(n-- > 0)
 9b6:	02c05163          	blez	a2,9d8 <memmove+0x2c>
 9ba:	fff6079b          	addiw	a5,a2,-1
 9be:	1782                	slli	a5,a5,0x20
 9c0:	9381                	srli	a5,a5,0x20
 9c2:	0785                	addi	a5,a5,1
 9c4:	97aa                	add	a5,a5,a0
  dst = vdst;
 9c6:	872a                	mv	a4,a0
      *dst++ = *src++;
 9c8:	0585                	addi	a1,a1,1
 9ca:	0705                	addi	a4,a4,1
 9cc:	fff5c683          	lbu	a3,-1(a1)
 9d0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 9d4:	fee79ae3          	bne	a5,a4,9c8 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 9d8:	6422                	ld	s0,8(sp)
 9da:	0141                	addi	sp,sp,16
 9dc:	8082                	ret
    dst += n;
 9de:	00c50733          	add	a4,a0,a2
    src += n;
 9e2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 9e4:	fec05ae3          	blez	a2,9d8 <memmove+0x2c>
 9e8:	fff6079b          	addiw	a5,a2,-1
 9ec:	1782                	slli	a5,a5,0x20
 9ee:	9381                	srli	a5,a5,0x20
 9f0:	fff7c793          	not	a5,a5
 9f4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 9f6:	15fd                	addi	a1,a1,-1
 9f8:	177d                	addi	a4,a4,-1
 9fa:	0005c683          	lbu	a3,0(a1)
 9fe:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 a02:	fee79ae3          	bne	a5,a4,9f6 <memmove+0x4a>
 a06:	bfc9                	j	9d8 <memmove+0x2c>

0000000000000a08 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 a08:	1141                	addi	sp,sp,-16
 a0a:	e422                	sd	s0,8(sp)
 a0c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 a0e:	ca05                	beqz	a2,a3e <memcmp+0x36>
 a10:	fff6069b          	addiw	a3,a2,-1
 a14:	1682                	slli	a3,a3,0x20
 a16:	9281                	srli	a3,a3,0x20
 a18:	0685                	addi	a3,a3,1
 a1a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 a1c:	00054783          	lbu	a5,0(a0)
 a20:	0005c703          	lbu	a4,0(a1)
 a24:	00e79863          	bne	a5,a4,a34 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 a28:	0505                	addi	a0,a0,1
    p2++;
 a2a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 a2c:	fed518e3          	bne	a0,a3,a1c <memcmp+0x14>
  }
  return 0;
 a30:	4501                	li	a0,0
 a32:	a019                	j	a38 <memcmp+0x30>
      return *p1 - *p2;
 a34:	40e7853b          	subw	a0,a5,a4
}
 a38:	6422                	ld	s0,8(sp)
 a3a:	0141                	addi	sp,sp,16
 a3c:	8082                	ret
  return 0;
 a3e:	4501                	li	a0,0
 a40:	bfe5                	j	a38 <memcmp+0x30>

0000000000000a42 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 a42:	1141                	addi	sp,sp,-16
 a44:	e406                	sd	ra,8(sp)
 a46:	e022                	sd	s0,0(sp)
 a48:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 a4a:	00000097          	auipc	ra,0x0
 a4e:	f62080e7          	jalr	-158(ra) # 9ac <memmove>
}
 a52:	60a2                	ld	ra,8(sp)
 a54:	6402                	ld	s0,0(sp)
 a56:	0141                	addi	sp,sp,16
 a58:	8082                	ret

0000000000000a5a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 a5a:	4885                	li	a7,1
 ecall
 a5c:	00000073          	ecall
 ret
 a60:	8082                	ret

0000000000000a62 <exit>:
.global exit
exit:
 li a7, SYS_exit
 a62:	4889                	li	a7,2
 ecall
 a64:	00000073          	ecall
 ret
 a68:	8082                	ret

0000000000000a6a <wait>:
.global wait
wait:
 li a7, SYS_wait
 a6a:	488d                	li	a7,3
 ecall
 a6c:	00000073          	ecall
 ret
 a70:	8082                	ret

0000000000000a72 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 a72:	4891                	li	a7,4
 ecall
 a74:	00000073          	ecall
 ret
 a78:	8082                	ret

0000000000000a7a <read>:
.global read
read:
 li a7, SYS_read
 a7a:	4895                	li	a7,5
 ecall
 a7c:	00000073          	ecall
 ret
 a80:	8082                	ret

0000000000000a82 <write>:
.global write
write:
 li a7, SYS_write
 a82:	48c1                	li	a7,16
 ecall
 a84:	00000073          	ecall
 ret
 a88:	8082                	ret

0000000000000a8a <close>:
.global close
close:
 li a7, SYS_close
 a8a:	48d5                	li	a7,21
 ecall
 a8c:	00000073          	ecall
 ret
 a90:	8082                	ret

0000000000000a92 <kill>:
.global kill
kill:
 li a7, SYS_kill
 a92:	4899                	li	a7,6
 ecall
 a94:	00000073          	ecall
 ret
 a98:	8082                	ret

0000000000000a9a <exec>:
.global exec
exec:
 li a7, SYS_exec
 a9a:	489d                	li	a7,7
 ecall
 a9c:	00000073          	ecall
 ret
 aa0:	8082                	ret

0000000000000aa2 <open>:
.global open
open:
 li a7, SYS_open
 aa2:	48bd                	li	a7,15
 ecall
 aa4:	00000073          	ecall
 ret
 aa8:	8082                	ret

0000000000000aaa <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 aaa:	48c5                	li	a7,17
 ecall
 aac:	00000073          	ecall
 ret
 ab0:	8082                	ret

0000000000000ab2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 ab2:	48c9                	li	a7,18
 ecall
 ab4:	00000073          	ecall
 ret
 ab8:	8082                	ret

0000000000000aba <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 aba:	48a1                	li	a7,8
 ecall
 abc:	00000073          	ecall
 ret
 ac0:	8082                	ret

0000000000000ac2 <link>:
.global link
link:
 li a7, SYS_link
 ac2:	48cd                	li	a7,19
 ecall
 ac4:	00000073          	ecall
 ret
 ac8:	8082                	ret

0000000000000aca <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 aca:	48d1                	li	a7,20
 ecall
 acc:	00000073          	ecall
 ret
 ad0:	8082                	ret

0000000000000ad2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 ad2:	48a5                	li	a7,9
 ecall
 ad4:	00000073          	ecall
 ret
 ad8:	8082                	ret

0000000000000ada <dup>:
.global dup
dup:
 li a7, SYS_dup
 ada:	48a9                	li	a7,10
 ecall
 adc:	00000073          	ecall
 ret
 ae0:	8082                	ret

0000000000000ae2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 ae2:	48ad                	li	a7,11
 ecall
 ae4:	00000073          	ecall
 ret
 ae8:	8082                	ret

0000000000000aea <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 aea:	48b1                	li	a7,12
 ecall
 aec:	00000073          	ecall
 ret
 af0:	8082                	ret

0000000000000af2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 af2:	48b5                	li	a7,13
 ecall
 af4:	00000073          	ecall
 ret
 af8:	8082                	ret

0000000000000afa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 afa:	48b9                	li	a7,14
 ecall
 afc:	00000073          	ecall
 ret
 b00:	8082                	ret

0000000000000b02 <connect>:
.global connect
connect:
 li a7, SYS_connect
 b02:	48d9                	li	a7,22
 ecall
 b04:	00000073          	ecall
 ret
 b08:	8082                	ret

0000000000000b0a <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 b0a:	48dd                	li	a7,23
 ecall
 b0c:	00000073          	ecall
 ret
 b10:	8082                	ret

0000000000000b12 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 b12:	1101                	addi	sp,sp,-32
 b14:	ec06                	sd	ra,24(sp)
 b16:	e822                	sd	s0,16(sp)
 b18:	1000                	addi	s0,sp,32
 b1a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 b1e:	4605                	li	a2,1
 b20:	fef40593          	addi	a1,s0,-17
 b24:	00000097          	auipc	ra,0x0
 b28:	f5e080e7          	jalr	-162(ra) # a82 <write>
}
 b2c:	60e2                	ld	ra,24(sp)
 b2e:	6442                	ld	s0,16(sp)
 b30:	6105                	addi	sp,sp,32
 b32:	8082                	ret

0000000000000b34 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 b34:	7139                	addi	sp,sp,-64
 b36:	fc06                	sd	ra,56(sp)
 b38:	f822                	sd	s0,48(sp)
 b3a:	f426                	sd	s1,40(sp)
 b3c:	f04a                	sd	s2,32(sp)
 b3e:	ec4e                	sd	s3,24(sp)
 b40:	0080                	addi	s0,sp,64
 b42:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 b44:	c299                	beqz	a3,b4a <printint+0x16>
 b46:	0805c863          	bltz	a1,bd6 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 b4a:	2581                	sext.w	a1,a1
  neg = 0;
 b4c:	4881                	li	a7,0
 b4e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 b52:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 b54:	2601                	sext.w	a2,a2
 b56:	00000517          	auipc	a0,0x0
 b5a:	6ba50513          	addi	a0,a0,1722 # 1210 <digits>
 b5e:	883a                	mv	a6,a4
 b60:	2705                	addiw	a4,a4,1
 b62:	02c5f7bb          	remuw	a5,a1,a2
 b66:	1782                	slli	a5,a5,0x20
 b68:	9381                	srli	a5,a5,0x20
 b6a:	97aa                	add	a5,a5,a0
 b6c:	0007c783          	lbu	a5,0(a5)
 b70:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 b74:	0005879b          	sext.w	a5,a1
 b78:	02c5d5bb          	divuw	a1,a1,a2
 b7c:	0685                	addi	a3,a3,1
 b7e:	fec7f0e3          	bgeu	a5,a2,b5e <printint+0x2a>
  if(neg)
 b82:	00088b63          	beqz	a7,b98 <printint+0x64>
    buf[i++] = '-';
 b86:	fd040793          	addi	a5,s0,-48
 b8a:	973e                	add	a4,a4,a5
 b8c:	02d00793          	li	a5,45
 b90:	fef70823          	sb	a5,-16(a4)
 b94:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 b98:	02e05863          	blez	a4,bc8 <printint+0x94>
 b9c:	fc040793          	addi	a5,s0,-64
 ba0:	00e78933          	add	s2,a5,a4
 ba4:	fff78993          	addi	s3,a5,-1
 ba8:	99ba                	add	s3,s3,a4
 baa:	377d                	addiw	a4,a4,-1
 bac:	1702                	slli	a4,a4,0x20
 bae:	9301                	srli	a4,a4,0x20
 bb0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 bb4:	fff94583          	lbu	a1,-1(s2)
 bb8:	8526                	mv	a0,s1
 bba:	00000097          	auipc	ra,0x0
 bbe:	f58080e7          	jalr	-168(ra) # b12 <putc>
  while(--i >= 0)
 bc2:	197d                	addi	s2,s2,-1
 bc4:	ff3918e3          	bne	s2,s3,bb4 <printint+0x80>
}
 bc8:	70e2                	ld	ra,56(sp)
 bca:	7442                	ld	s0,48(sp)
 bcc:	74a2                	ld	s1,40(sp)
 bce:	7902                	ld	s2,32(sp)
 bd0:	69e2                	ld	s3,24(sp)
 bd2:	6121                	addi	sp,sp,64
 bd4:	8082                	ret
    x = -xx;
 bd6:	40b005bb          	negw	a1,a1
    neg = 1;
 bda:	4885                	li	a7,1
    x = -xx;
 bdc:	bf8d                	j	b4e <printint+0x1a>

0000000000000bde <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 bde:	7119                	addi	sp,sp,-128
 be0:	fc86                	sd	ra,120(sp)
 be2:	f8a2                	sd	s0,112(sp)
 be4:	f4a6                	sd	s1,104(sp)
 be6:	f0ca                	sd	s2,96(sp)
 be8:	ecce                	sd	s3,88(sp)
 bea:	e8d2                	sd	s4,80(sp)
 bec:	e4d6                	sd	s5,72(sp)
 bee:	e0da                	sd	s6,64(sp)
 bf0:	fc5e                	sd	s7,56(sp)
 bf2:	f862                	sd	s8,48(sp)
 bf4:	f466                	sd	s9,40(sp)
 bf6:	f06a                	sd	s10,32(sp)
 bf8:	ec6e                	sd	s11,24(sp)
 bfa:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 bfc:	0005c903          	lbu	s2,0(a1)
 c00:	18090f63          	beqz	s2,d9e <vprintf+0x1c0>
 c04:	8aaa                	mv	s5,a0
 c06:	8b32                	mv	s6,a2
 c08:	00158493          	addi	s1,a1,1
  state = 0;
 c0c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 c0e:	02500a13          	li	s4,37
      if(c == 'd'){
 c12:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 c16:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 c1a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 c1e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 c22:	00000b97          	auipc	s7,0x0
 c26:	5eeb8b93          	addi	s7,s7,1518 # 1210 <digits>
 c2a:	a839                	j	c48 <vprintf+0x6a>
        putc(fd, c);
 c2c:	85ca                	mv	a1,s2
 c2e:	8556                	mv	a0,s5
 c30:	00000097          	auipc	ra,0x0
 c34:	ee2080e7          	jalr	-286(ra) # b12 <putc>
 c38:	a019                	j	c3e <vprintf+0x60>
    } else if(state == '%'){
 c3a:	01498f63          	beq	s3,s4,c58 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 c3e:	0485                	addi	s1,s1,1
 c40:	fff4c903          	lbu	s2,-1(s1)
 c44:	14090d63          	beqz	s2,d9e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 c48:	0009079b          	sext.w	a5,s2
    if(state == 0){
 c4c:	fe0997e3          	bnez	s3,c3a <vprintf+0x5c>
      if(c == '%'){
 c50:	fd479ee3          	bne	a5,s4,c2c <vprintf+0x4e>
        state = '%';
 c54:	89be                	mv	s3,a5
 c56:	b7e5                	j	c3e <vprintf+0x60>
      if(c == 'd'){
 c58:	05878063          	beq	a5,s8,c98 <vprintf+0xba>
      } else if(c == 'l') {
 c5c:	05978c63          	beq	a5,s9,cb4 <vprintf+0xd6>
      } else if(c == 'x') {
 c60:	07a78863          	beq	a5,s10,cd0 <vprintf+0xf2>
      } else if(c == 'p') {
 c64:	09b78463          	beq	a5,s11,cec <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 c68:	07300713          	li	a4,115
 c6c:	0ce78663          	beq	a5,a4,d38 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 c70:	06300713          	li	a4,99
 c74:	0ee78e63          	beq	a5,a4,d70 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 c78:	11478863          	beq	a5,s4,d88 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 c7c:	85d2                	mv	a1,s4
 c7e:	8556                	mv	a0,s5
 c80:	00000097          	auipc	ra,0x0
 c84:	e92080e7          	jalr	-366(ra) # b12 <putc>
        putc(fd, c);
 c88:	85ca                	mv	a1,s2
 c8a:	8556                	mv	a0,s5
 c8c:	00000097          	auipc	ra,0x0
 c90:	e86080e7          	jalr	-378(ra) # b12 <putc>
      }
      state = 0;
 c94:	4981                	li	s3,0
 c96:	b765                	j	c3e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 c98:	008b0913          	addi	s2,s6,8
 c9c:	4685                	li	a3,1
 c9e:	4629                	li	a2,10
 ca0:	000b2583          	lw	a1,0(s6)
 ca4:	8556                	mv	a0,s5
 ca6:	00000097          	auipc	ra,0x0
 caa:	e8e080e7          	jalr	-370(ra) # b34 <printint>
 cae:	8b4a                	mv	s6,s2
      state = 0;
 cb0:	4981                	li	s3,0
 cb2:	b771                	j	c3e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 cb4:	008b0913          	addi	s2,s6,8
 cb8:	4681                	li	a3,0
 cba:	4629                	li	a2,10
 cbc:	000b2583          	lw	a1,0(s6)
 cc0:	8556                	mv	a0,s5
 cc2:	00000097          	auipc	ra,0x0
 cc6:	e72080e7          	jalr	-398(ra) # b34 <printint>
 cca:	8b4a                	mv	s6,s2
      state = 0;
 ccc:	4981                	li	s3,0
 cce:	bf85                	j	c3e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 cd0:	008b0913          	addi	s2,s6,8
 cd4:	4681                	li	a3,0
 cd6:	4641                	li	a2,16
 cd8:	000b2583          	lw	a1,0(s6)
 cdc:	8556                	mv	a0,s5
 cde:	00000097          	auipc	ra,0x0
 ce2:	e56080e7          	jalr	-426(ra) # b34 <printint>
 ce6:	8b4a                	mv	s6,s2
      state = 0;
 ce8:	4981                	li	s3,0
 cea:	bf91                	j	c3e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 cec:	008b0793          	addi	a5,s6,8
 cf0:	f8f43423          	sd	a5,-120(s0)
 cf4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 cf8:	03000593          	li	a1,48
 cfc:	8556                	mv	a0,s5
 cfe:	00000097          	auipc	ra,0x0
 d02:	e14080e7          	jalr	-492(ra) # b12 <putc>
  putc(fd, 'x');
 d06:	85ea                	mv	a1,s10
 d08:	8556                	mv	a0,s5
 d0a:	00000097          	auipc	ra,0x0
 d0e:	e08080e7          	jalr	-504(ra) # b12 <putc>
 d12:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 d14:	03c9d793          	srli	a5,s3,0x3c
 d18:	97de                	add	a5,a5,s7
 d1a:	0007c583          	lbu	a1,0(a5)
 d1e:	8556                	mv	a0,s5
 d20:	00000097          	auipc	ra,0x0
 d24:	df2080e7          	jalr	-526(ra) # b12 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 d28:	0992                	slli	s3,s3,0x4
 d2a:	397d                	addiw	s2,s2,-1
 d2c:	fe0914e3          	bnez	s2,d14 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 d30:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 d34:	4981                	li	s3,0
 d36:	b721                	j	c3e <vprintf+0x60>
        s = va_arg(ap, char*);
 d38:	008b0993          	addi	s3,s6,8
 d3c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 d40:	02090163          	beqz	s2,d62 <vprintf+0x184>
        while(*s != 0){
 d44:	00094583          	lbu	a1,0(s2)
 d48:	c9a1                	beqz	a1,d98 <vprintf+0x1ba>
          putc(fd, *s);
 d4a:	8556                	mv	a0,s5
 d4c:	00000097          	auipc	ra,0x0
 d50:	dc6080e7          	jalr	-570(ra) # b12 <putc>
          s++;
 d54:	0905                	addi	s2,s2,1
        while(*s != 0){
 d56:	00094583          	lbu	a1,0(s2)
 d5a:	f9e5                	bnez	a1,d4a <vprintf+0x16c>
        s = va_arg(ap, char*);
 d5c:	8b4e                	mv	s6,s3
      state = 0;
 d5e:	4981                	li	s3,0
 d60:	bdf9                	j	c3e <vprintf+0x60>
          s = "(null)";
 d62:	00000917          	auipc	s2,0x0
 d66:	4a690913          	addi	s2,s2,1190 # 1208 <malloc+0x360>
        while(*s != 0){
 d6a:	02800593          	li	a1,40
 d6e:	bff1                	j	d4a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 d70:	008b0913          	addi	s2,s6,8
 d74:	000b4583          	lbu	a1,0(s6)
 d78:	8556                	mv	a0,s5
 d7a:	00000097          	auipc	ra,0x0
 d7e:	d98080e7          	jalr	-616(ra) # b12 <putc>
 d82:	8b4a                	mv	s6,s2
      state = 0;
 d84:	4981                	li	s3,0
 d86:	bd65                	j	c3e <vprintf+0x60>
        putc(fd, c);
 d88:	85d2                	mv	a1,s4
 d8a:	8556                	mv	a0,s5
 d8c:	00000097          	auipc	ra,0x0
 d90:	d86080e7          	jalr	-634(ra) # b12 <putc>
      state = 0;
 d94:	4981                	li	s3,0
 d96:	b565                	j	c3e <vprintf+0x60>
        s = va_arg(ap, char*);
 d98:	8b4e                	mv	s6,s3
      state = 0;
 d9a:	4981                	li	s3,0
 d9c:	b54d                	j	c3e <vprintf+0x60>
    }
  }
}
 d9e:	70e6                	ld	ra,120(sp)
 da0:	7446                	ld	s0,112(sp)
 da2:	74a6                	ld	s1,104(sp)
 da4:	7906                	ld	s2,96(sp)
 da6:	69e6                	ld	s3,88(sp)
 da8:	6a46                	ld	s4,80(sp)
 daa:	6aa6                	ld	s5,72(sp)
 dac:	6b06                	ld	s6,64(sp)
 dae:	7be2                	ld	s7,56(sp)
 db0:	7c42                	ld	s8,48(sp)
 db2:	7ca2                	ld	s9,40(sp)
 db4:	7d02                	ld	s10,32(sp)
 db6:	6de2                	ld	s11,24(sp)
 db8:	6109                	addi	sp,sp,128
 dba:	8082                	ret

0000000000000dbc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 dbc:	715d                	addi	sp,sp,-80
 dbe:	ec06                	sd	ra,24(sp)
 dc0:	e822                	sd	s0,16(sp)
 dc2:	1000                	addi	s0,sp,32
 dc4:	e010                	sd	a2,0(s0)
 dc6:	e414                	sd	a3,8(s0)
 dc8:	e818                	sd	a4,16(s0)
 dca:	ec1c                	sd	a5,24(s0)
 dcc:	03043023          	sd	a6,32(s0)
 dd0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 dd4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 dd8:	8622                	mv	a2,s0
 dda:	00000097          	auipc	ra,0x0
 dde:	e04080e7          	jalr	-508(ra) # bde <vprintf>
}
 de2:	60e2                	ld	ra,24(sp)
 de4:	6442                	ld	s0,16(sp)
 de6:	6161                	addi	sp,sp,80
 de8:	8082                	ret

0000000000000dea <printf>:

void
printf(const char *fmt, ...)
{
 dea:	711d                	addi	sp,sp,-96
 dec:	ec06                	sd	ra,24(sp)
 dee:	e822                	sd	s0,16(sp)
 df0:	1000                	addi	s0,sp,32
 df2:	e40c                	sd	a1,8(s0)
 df4:	e810                	sd	a2,16(s0)
 df6:	ec14                	sd	a3,24(s0)
 df8:	f018                	sd	a4,32(s0)
 dfa:	f41c                	sd	a5,40(s0)
 dfc:	03043823          	sd	a6,48(s0)
 e00:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 e04:	00840613          	addi	a2,s0,8
 e08:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 e0c:	85aa                	mv	a1,a0
 e0e:	4505                	li	a0,1
 e10:	00000097          	auipc	ra,0x0
 e14:	dce080e7          	jalr	-562(ra) # bde <vprintf>
}
 e18:	60e2                	ld	ra,24(sp)
 e1a:	6442                	ld	s0,16(sp)
 e1c:	6125                	addi	sp,sp,96
 e1e:	8082                	ret

0000000000000e20 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 e20:	1141                	addi	sp,sp,-16
 e22:	e422                	sd	s0,8(sp)
 e24:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 e26:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e2a:	00000797          	auipc	a5,0x0
 e2e:	3fe7b783          	ld	a5,1022(a5) # 1228 <freep>
 e32:	a805                	j	e62 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 e34:	4618                	lw	a4,8(a2)
 e36:	9db9                	addw	a1,a1,a4
 e38:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 e3c:	6398                	ld	a4,0(a5)
 e3e:	6318                	ld	a4,0(a4)
 e40:	fee53823          	sd	a4,-16(a0)
 e44:	a091                	j	e88 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 e46:	ff852703          	lw	a4,-8(a0)
 e4a:	9e39                	addw	a2,a2,a4
 e4c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 e4e:	ff053703          	ld	a4,-16(a0)
 e52:	e398                	sd	a4,0(a5)
 e54:	a099                	j	e9a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e56:	6398                	ld	a4,0(a5)
 e58:	00e7e463          	bltu	a5,a4,e60 <free+0x40>
 e5c:	00e6ea63          	bltu	a3,a4,e70 <free+0x50>
{
 e60:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e62:	fed7fae3          	bgeu	a5,a3,e56 <free+0x36>
 e66:	6398                	ld	a4,0(a5)
 e68:	00e6e463          	bltu	a3,a4,e70 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e6c:	fee7eae3          	bltu	a5,a4,e60 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 e70:	ff852583          	lw	a1,-8(a0)
 e74:	6390                	ld	a2,0(a5)
 e76:	02059713          	slli	a4,a1,0x20
 e7a:	9301                	srli	a4,a4,0x20
 e7c:	0712                	slli	a4,a4,0x4
 e7e:	9736                	add	a4,a4,a3
 e80:	fae60ae3          	beq	a2,a4,e34 <free+0x14>
    bp->s.ptr = p->s.ptr;
 e84:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 e88:	4790                	lw	a2,8(a5)
 e8a:	02061713          	slli	a4,a2,0x20
 e8e:	9301                	srli	a4,a4,0x20
 e90:	0712                	slli	a4,a4,0x4
 e92:	973e                	add	a4,a4,a5
 e94:	fae689e3          	beq	a3,a4,e46 <free+0x26>
  } else
    p->s.ptr = bp;
 e98:	e394                	sd	a3,0(a5)
  freep = p;
 e9a:	00000717          	auipc	a4,0x0
 e9e:	38f73723          	sd	a5,910(a4) # 1228 <freep>
}
 ea2:	6422                	ld	s0,8(sp)
 ea4:	0141                	addi	sp,sp,16
 ea6:	8082                	ret

0000000000000ea8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 ea8:	7139                	addi	sp,sp,-64
 eaa:	fc06                	sd	ra,56(sp)
 eac:	f822                	sd	s0,48(sp)
 eae:	f426                	sd	s1,40(sp)
 eb0:	f04a                	sd	s2,32(sp)
 eb2:	ec4e                	sd	s3,24(sp)
 eb4:	e852                	sd	s4,16(sp)
 eb6:	e456                	sd	s5,8(sp)
 eb8:	e05a                	sd	s6,0(sp)
 eba:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ebc:	02051493          	slli	s1,a0,0x20
 ec0:	9081                	srli	s1,s1,0x20
 ec2:	04bd                	addi	s1,s1,15
 ec4:	8091                	srli	s1,s1,0x4
 ec6:	0014899b          	addiw	s3,s1,1
 eca:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 ecc:	00000517          	auipc	a0,0x0
 ed0:	35c53503          	ld	a0,860(a0) # 1228 <freep>
 ed4:	c515                	beqz	a0,f00 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ed6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ed8:	4798                	lw	a4,8(a5)
 eda:	02977f63          	bgeu	a4,s1,f18 <malloc+0x70>
 ede:	8a4e                	mv	s4,s3
 ee0:	0009871b          	sext.w	a4,s3
 ee4:	6685                	lui	a3,0x1
 ee6:	00d77363          	bgeu	a4,a3,eec <malloc+0x44>
 eea:	6a05                	lui	s4,0x1
 eec:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 ef0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 ef4:	00000917          	auipc	s2,0x0
 ef8:	33490913          	addi	s2,s2,820 # 1228 <freep>
  if(p == (char*)-1)
 efc:	5afd                	li	s5,-1
 efe:	a88d                	j	f70 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 f00:	00000797          	auipc	a5,0x0
 f04:	33078793          	addi	a5,a5,816 # 1230 <base>
 f08:	00000717          	auipc	a4,0x0
 f0c:	32f73023          	sd	a5,800(a4) # 1228 <freep>
 f10:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 f12:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 f16:	b7e1                	j	ede <malloc+0x36>
      if(p->s.size == nunits)
 f18:	02e48b63          	beq	s1,a4,f4e <malloc+0xa6>
        p->s.size -= nunits;
 f1c:	4137073b          	subw	a4,a4,s3
 f20:	c798                	sw	a4,8(a5)
        p += p->s.size;
 f22:	1702                	slli	a4,a4,0x20
 f24:	9301                	srli	a4,a4,0x20
 f26:	0712                	slli	a4,a4,0x4
 f28:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 f2a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 f2e:	00000717          	auipc	a4,0x0
 f32:	2ea73d23          	sd	a0,762(a4) # 1228 <freep>
      return (void*)(p + 1);
 f36:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 f3a:	70e2                	ld	ra,56(sp)
 f3c:	7442                	ld	s0,48(sp)
 f3e:	74a2                	ld	s1,40(sp)
 f40:	7902                	ld	s2,32(sp)
 f42:	69e2                	ld	s3,24(sp)
 f44:	6a42                	ld	s4,16(sp)
 f46:	6aa2                	ld	s5,8(sp)
 f48:	6b02                	ld	s6,0(sp)
 f4a:	6121                	addi	sp,sp,64
 f4c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 f4e:	6398                	ld	a4,0(a5)
 f50:	e118                	sd	a4,0(a0)
 f52:	bff1                	j	f2e <malloc+0x86>
  hp->s.size = nu;
 f54:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 f58:	0541                	addi	a0,a0,16
 f5a:	00000097          	auipc	ra,0x0
 f5e:	ec6080e7          	jalr	-314(ra) # e20 <free>
  return freep;
 f62:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 f66:	d971                	beqz	a0,f3a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f68:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 f6a:	4798                	lw	a4,8(a5)
 f6c:	fa9776e3          	bgeu	a4,s1,f18 <malloc+0x70>
    if(p == freep)
 f70:	00093703          	ld	a4,0(s2)
 f74:	853e                	mv	a0,a5
 f76:	fef719e3          	bne	a4,a5,f68 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 f7a:	8552                	mv	a0,s4
 f7c:	00000097          	auipc	ra,0x0
 f80:	b6e080e7          	jalr	-1170(ra) # aea <sbrk>
  if(p == (char*)-1)
 f84:	fd5518e3          	bne	a0,s5,f54 <malloc+0xac>
        return 0;
 f88:	4501                	li	a0,0
 f8a:	bf45                	j	f3a <malloc+0x92>
