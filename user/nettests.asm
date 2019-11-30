
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

0000000000000060 <dns>:
  }
}

static void
dns()
{
  60:	7119                	addi	sp,sp,-128
  62:	fc86                	sd	ra,120(sp)
  64:	f8a2                	sd	s0,112(sp)
  66:	f4a6                	sd	s1,104(sp)
  68:	f0ca                	sd	s2,96(sp)
  6a:	ecce                	sd	s3,88(sp)
  6c:	e8d2                	sd	s4,80(sp)
  6e:	e4d6                	sd	s5,72(sp)
  70:	e0da                	sd	s6,64(sp)
  72:	fc5e                	sd	s7,56(sp)
  74:	f862                	sd	s8,48(sp)
  76:	f466                	sd	s9,40(sp)
  78:	f06a                	sd	s10,32(sp)
  7a:	ec6e                	sd	s11,24(sp)
  7c:	0100                	addi	s0,sp,128
  7e:	83010113          	addi	sp,sp,-2000
  uint8 ibuf[N];
  uint32 dst;
  int fd;
  int len;

  memset(obuf, 0, N);
  82:	3e800613          	li	a2,1000
  86:	4581                	li	a1,0
  88:	ba840513          	addi	a0,s0,-1112
  8c:	00000097          	auipc	ra,0x0
  90:	726080e7          	jalr	1830(ra) # 7b2 <memset>
  memset(ibuf, 0, N);
  94:	3e800613          	li	a2,1000
  98:	4581                	li	a1,0
  9a:	77fd                	lui	a5,0xfffff
  9c:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffdea7>
  a0:	00f40533          	add	a0,s0,a5
  a4:	00000097          	auipc	ra,0x0
  a8:	70e080e7          	jalr	1806(ra) # 7b2 <memset>

  // 8.8.8.8: google's name server
  dst = (8 << 24) | (8 << 16) | (8 << 8) | (8 << 0);

  if((fd = connect(dst, 10000, 53)) < 0){
  ac:	03500613          	li	a2,53
  b0:	6589                	lui	a1,0x2
  b2:	71058593          	addi	a1,a1,1808 # 2710 <__global_pointer$+0xdf7>
  b6:	08081537          	lui	a0,0x8081
  ba:	80850513          	addi	a0,a0,-2040 # 8080808 <__global_pointer$+0x807eeef>
  be:	00001097          	auipc	ra,0x1
  c2:	998080e7          	jalr	-1640(ra) # a56 <connect>
  c6:	02054d63          	bltz	a0,100 <dns+0xa0>
  ca:	892a                	mv	s2,a0
  hdr->id = htons(6828);
  cc:	77ed                	lui	a5,0xffffb
  ce:	c1a78793          	addi	a5,a5,-998 # ffffffffffffac1a <__global_pointer$+0xffffffffffff9301>
  d2:	baf41423          	sh	a5,-1112(s0)
  hdr->rd = 1;
  d6:	baa45783          	lhu	a5,-1110(s0)
  da:	0017e793          	ori	a5,a5,1
  de:	baf41523          	sh	a5,-1110(s0)
  hdr->qdcount = htons(1);
  e2:	10000793          	li	a5,256
  e6:	baf41623          	sh	a5,-1108(s0)
  for(char *c = host; c < host+strlen(host)+1; c++) {
  ea:	00001497          	auipc	s1,0x1
  ee:	df648493          	addi	s1,s1,-522 # ee0 <malloc+0xe4>
  char *l = host;
  f2:	8a26                	mv	s4,s1
  for(char *c = host; c < host+strlen(host)+1; c++) {
  f4:	bb440993          	addi	s3,s0,-1100
  f8:	8aa6                	mv	s5,s1
    if(*c == '.') {
  fa:	02e00b13          	li	s6,46
  for(char *c = host; c < host+strlen(host)+1; c++) {
  fe:	a01d                	j	124 <dns+0xc4>
    fprintf(2, "ping: connect() failed\n");
 100:	00001597          	auipc	a1,0x1
 104:	df858593          	addi	a1,a1,-520 # ef8 <malloc+0xfc>
 108:	4509                	li	a0,2
 10a:	00001097          	auipc	ra,0x1
 10e:	c06080e7          	jalr	-1018(ra) # d10 <fprintf>
    exit(1);
 112:	4505                	li	a0,1
 114:	00001097          	auipc	ra,0x1
 118:	8a2080e7          	jalr	-1886(ra) # 9b6 <exit>
      *qn++ = (char) (c-l);
 11c:	89b6                	mv	s3,a3
      l = c+1; // skip .
 11e:	00148a13          	addi	s4,s1,1
  for(char *c = host; c < host+strlen(host)+1; c++) {
 122:	0485                	addi	s1,s1,1
 124:	8556                	mv	a0,s5
 126:	00000097          	auipc	ra,0x0
 12a:	662080e7          	jalr	1634(ra) # 788 <strlen>
 12e:	1502                	slli	a0,a0,0x20
 130:	9101                	srli	a0,a0,0x20
 132:	0505                	addi	a0,a0,1
 134:	9556                	add	a0,a0,s5
 136:	02a4fc63          	bgeu	s1,a0,16e <dns+0x10e>
    if(*c == '.') {
 13a:	0004c783          	lbu	a5,0(s1)
 13e:	ff6792e3          	bne	a5,s6,122 <dns+0xc2>
      *qn++ = (char) (c-l);
 142:	00198693          	addi	a3,s3,1
 146:	414487b3          	sub	a5,s1,s4
 14a:	00f98023          	sb	a5,0(s3)
      for(char *d = l; d < c; d++) {
 14e:	fc9a77e3          	bgeu	s4,s1,11c <dns+0xbc>
 152:	87d2                	mv	a5,s4
      *qn++ = (char) (c-l);
 154:	8736                	mv	a4,a3
        *qn++ = *d;
 156:	0705                	addi	a4,a4,1
 158:	0007c603          	lbu	a2,0(a5)
 15c:	fec70fa3          	sb	a2,-1(a4)
      for(char *d = l; d < c; d++) {
 160:	0785                	addi	a5,a5,1
 162:	fef49ae3          	bne	s1,a5,156 <dns+0xf6>
 166:	414489b3          	sub	s3,s1,s4
 16a:	99b6                	add	s3,s3,a3
 16c:	bf4d                	j	11e <dns+0xbe>
  *qn = '\0';
 16e:	00098023          	sb	zero,0(s3)
  len += strlen(qname) + 1;
 172:	bb440513          	addi	a0,s0,-1100
 176:	00000097          	auipc	ra,0x0
 17a:	612080e7          	jalr	1554(ra) # 788 <strlen>
 17e:	0005049b          	sext.w	s1,a0
  struct dns_question *h = (struct dns_question *) (qname+strlen(qname)+1);
 182:	bb440513          	addi	a0,s0,-1100
 186:	00000097          	auipc	ra,0x0
 18a:	602080e7          	jalr	1538(ra) # 788 <strlen>
 18e:	02051793          	slli	a5,a0,0x20
 192:	9381                	srli	a5,a5,0x20
 194:	0785                	addi	a5,a5,1
 196:	bb440713          	addi	a4,s0,-1100
 19a:	97ba                	add	a5,a5,a4
  h->qtype = htons(0x1);
 19c:	00078023          	sb	zero,0(a5)
 1a0:	4705                	li	a4,1
 1a2:	00e780a3          	sb	a4,1(a5)
  h->qclass = htons(0x1);
 1a6:	00078123          	sb	zero,2(a5)
 1aa:	00e781a3          	sb	a4,3(a5)
  }

  len = dns_req(obuf);

  if(write(fd, obuf, len) < 0){
 1ae:	0114861b          	addiw	a2,s1,17
 1b2:	ba840593          	addi	a1,s0,-1112
 1b6:	854a                	mv	a0,s2
 1b8:	00001097          	auipc	ra,0x1
 1bc:	81e080e7          	jalr	-2018(ra) # 9d6 <write>
 1c0:	10054e63          	bltz	a0,2dc <dns+0x27c>
    fprintf(2, "dns: send() failed\n");
    exit(1);
  }
  int cc = read(fd, ibuf, sizeof(ibuf));
 1c4:	3e800613          	li	a2,1000
 1c8:	77fd                	lui	a5,0xfffff
 1ca:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffdea7>
 1ce:	00f405b3          	add	a1,s0,a5
 1d2:	854a                	mv	a0,s2
 1d4:	00000097          	auipc	ra,0x0
 1d8:	7fa080e7          	jalr	2042(ra) # 9ce <read>
 1dc:	89aa                	mv	s3,a0
  if(cc < 0){
 1de:	10054d63          	bltz	a0,2f8 <dns+0x298>
  if(!hdr->qr) {
 1e2:	77fd                	lui	a5,0xfffff
 1e4:	7c278793          	addi	a5,a5,1986 # fffffffffffff7c2 <__global_pointer$+0xffffffffffffdea9>
 1e8:	97a2                	add	a5,a5,s0
 1ea:	00078783          	lb	a5,0(a5)
 1ee:	1207d363          	bgez	a5,314 <dns+0x2b4>
  if(hdr->id != htons(6828))
 1f2:	77fd                	lui	a5,0xfffff
 1f4:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffdea7>
 1f8:	97a2                	add	a5,a5,s0
 1fa:	0007d783          	lhu	a5,0(a5)
 1fe:	0007869b          	sext.w	a3,a5
 202:	672d                	lui	a4,0xb
 204:	c1a70713          	addi	a4,a4,-998 # ac1a <__global_pointer$+0x9301>
 208:	10e69b63          	bne	a3,a4,31e <dns+0x2be>
  if(hdr->rcode != 0) {
 20c:	777d                	lui	a4,0xfffff
 20e:	7c370793          	addi	a5,a4,1987 # fffffffffffff7c3 <__global_pointer$+0xffffffffffffdeaa>
 212:	97a2                	add	a5,a5,s0
 214:	0007c783          	lbu	a5,0(a5)
 218:	8bbd                	andi	a5,a5,15
 21a:	12079263          	bnez	a5,33e <dns+0x2de>
// endianness support
//

static inline uint16 bswaps(uint16 val)
{
  return (((val & 0x00ffU) << 8) |
 21e:	7c470793          	addi	a5,a4,1988
 222:	97a2                	add	a5,a5,s0
 224:	0007d783          	lhu	a5,0(a5)
 228:	0087d71b          	srliw	a4,a5,0x8
 22c:	0087979b          	slliw	a5,a5,0x8
 230:	8fd9                	or	a5,a5,a4
  for(int i =0; i < ntohs(hdr->qdcount); i++) {
 232:	17c2                	slli	a5,a5,0x30
 234:	93c1                	srli	a5,a5,0x30
 236:	4a81                	li	s5,0
  len = sizeof(struct dns);
 238:	44b1                	li	s1,12
  char *qname = 0;
 23a:	4a01                	li	s4,0
  for(int i =0; i < ntohs(hdr->qdcount); i++) {
 23c:	c3b1                	beqz	a5,280 <dns+0x220>
    char *qn = (char *) (ibuf+len);
 23e:	7b7d                	lui	s6,0xfffff
 240:	7c0b0793          	addi	a5,s6,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffdea7>
 244:	97a2                	add	a5,a5,s0
 246:	00978a33          	add	s4,a5,s1
    decode_qname(qn);
 24a:	8552                	mv	a0,s4
 24c:	00000097          	auipc	ra,0x0
 250:	db4080e7          	jalr	-588(ra) # 0 <decode_qname>
    len += strlen(qn)+1;
 254:	8552                	mv	a0,s4
 256:	00000097          	auipc	ra,0x0
 25a:	532080e7          	jalr	1330(ra) # 788 <strlen>
    len += sizeof(struct dns_question);
 25e:	2515                	addiw	a0,a0,5
 260:	9ca9                	addw	s1,s1,a0
  for(int i =0; i < ntohs(hdr->qdcount); i++) {
 262:	2a85                	addiw	s5,s5,1
 264:	7c4b0793          	addi	a5,s6,1988
 268:	97a2                	add	a5,a5,s0
 26a:	0007d783          	lhu	a5,0(a5)
 26e:	0087d71b          	srliw	a4,a5,0x8
 272:	0087979b          	slliw	a5,a5,0x8
 276:	8fd9                	or	a5,a5,a4
 278:	17c2                	slli	a5,a5,0x30
 27a:	93c1                	srli	a5,a5,0x30
 27c:	fcfac1e3          	blt	s5,a5,23e <dns+0x1de>
 280:	77fd                	lui	a5,0xfffff
 282:	7c678793          	addi	a5,a5,1990 # fffffffffffff7c6 <__global_pointer$+0xffffffffffffdead>
 286:	97a2                	add	a5,a5,s0
 288:	0007d783          	lhu	a5,0(a5)
 28c:	0087d71b          	srliw	a4,a5,0x8
 290:	0087979b          	slliw	a5,a5,0x8
 294:	8fd9                	or	a5,a5,a4
  for(int i = 0; i < ntohs(hdr->ancount); i++) {
 296:	17c2                	slli	a5,a5,0x30
 298:	93c1                	srli	a5,a5,0x30
 29a:	24078663          	beqz	a5,4e6 <dns+0x486>
 29e:	00001797          	auipc	a5,0x1
 2a2:	d3a78793          	addi	a5,a5,-710 # fd8 <malloc+0x1dc>
 2a6:	000a0363          	beqz	s4,2ac <dns+0x24c>
 2aa:	87d2                	mv	a5,s4
 2ac:	76fd                	lui	a3,0xfffff
 2ae:	7b068713          	addi	a4,a3,1968 # fffffffffffff7b0 <__global_pointer$+0xffffffffffffde97>
 2b2:	9722                	add	a4,a4,s0
 2b4:	e31c                	sd	a5,0(a4)
  int record = 0;
 2b6:	7b868793          	addi	a5,a3,1976
 2ba:	97a2                	add	a5,a5,s0
 2bc:	0007b023          	sd	zero,0(a5)
  for(int i = 0; i < ntohs(hdr->ancount); i++) {
 2c0:	4a01                	li	s4,0
    if((int) qn[0] > 63) {  // compression?
 2c2:	03f00d93          	li	s11,63
    if(ntohs(d->type) == ARECORD && ntohs(d->len) == 4) {
 2c6:	4a85                	li	s5,1
 2c8:	4d11                	li	s10,4
      printf("DNS arecord for %s is ", qname ? qname : "" );
 2ca:	00001c97          	auipc	s9,0x1
 2ce:	ca6c8c93          	addi	s9,s9,-858 # f70 <malloc+0x174>
      if(ip[0] != 128 || ip[1] != 52 || ip[2] != 129 || ip[3] != 126) {
 2d2:	08000c13          	li	s8,128
 2d6:	03400b93          	li	s7,52
 2da:	a8d9                	j	3b0 <dns+0x350>
    fprintf(2, "dns: send() failed\n");
 2dc:	00001597          	auipc	a1,0x1
 2e0:	c3458593          	addi	a1,a1,-972 # f10 <malloc+0x114>
 2e4:	4509                	li	a0,2
 2e6:	00001097          	auipc	ra,0x1
 2ea:	a2a080e7          	jalr	-1494(ra) # d10 <fprintf>
    exit(1);
 2ee:	4505                	li	a0,1
 2f0:	00000097          	auipc	ra,0x0
 2f4:	6c6080e7          	jalr	1734(ra) # 9b6 <exit>
    fprintf(2, "dns: recv() failed\n");
 2f8:	00001597          	auipc	a1,0x1
 2fc:	c3058593          	addi	a1,a1,-976 # f28 <malloc+0x12c>
 300:	4509                	li	a0,2
 302:	00001097          	auipc	ra,0x1
 306:	a0e080e7          	jalr	-1522(ra) # d10 <fprintf>
    exit(1);
 30a:	4505                	li	a0,1
 30c:	00000097          	auipc	ra,0x0
 310:	6aa080e7          	jalr	1706(ra) # 9b6 <exit>
    exit(1);
 314:	4505                	li	a0,1
 316:	00000097          	auipc	ra,0x0
 31a:	6a0080e7          	jalr	1696(ra) # 9b6 <exit>
 31e:	0087d59b          	srliw	a1,a5,0x8
 322:	0087979b          	slliw	a5,a5,0x8
 326:	8ddd                	or	a1,a1,a5
    printf("DNS wrong id: %d\n", ntohs(hdr->id));
 328:	15c2                	slli	a1,a1,0x30
 32a:	91c1                	srli	a1,a1,0x30
 32c:	00001517          	auipc	a0,0x1
 330:	c1450513          	addi	a0,a0,-1004 # f40 <malloc+0x144>
 334:	00001097          	auipc	ra,0x1
 338:	a0a080e7          	jalr	-1526(ra) # d3e <printf>
 33c:	bdc1                	j	20c <dns+0x1ac>
    printf("DNS rcode error: %x\n", hdr->rcode);
 33e:	77fd                	lui	a5,0xfffff
 340:	7c378793          	addi	a5,a5,1987 # fffffffffffff7c3 <__global_pointer$+0xffffffffffffdeaa>
 344:	97a2                	add	a5,a5,s0
 346:	0007c583          	lbu	a1,0(a5)
 34a:	89bd                	andi	a1,a1,15
 34c:	00001517          	auipc	a0,0x1
 350:	c0c50513          	addi	a0,a0,-1012 # f58 <malloc+0x15c>
 354:	00001097          	auipc	ra,0x1
 358:	9ea080e7          	jalr	-1558(ra) # d3e <printf>
    exit(1);
 35c:	4505                	li	a0,1
 35e:	00000097          	auipc	ra,0x0
 362:	658080e7          	jalr	1624(ra) # 9b6 <exit>
      decode_qname(qn);
 366:	855a                	mv	a0,s6
 368:	00000097          	auipc	ra,0x0
 36c:	c98080e7          	jalr	-872(ra) # 0 <decode_qname>
      len += strlen(qn)+1;
 370:	855a                	mv	a0,s6
 372:	00000097          	auipc	ra,0x0
 376:	416080e7          	jalr	1046(ra) # 788 <strlen>
 37a:	2485                	addiw	s1,s1,1
 37c:	9ca9                	addw	s1,s1,a0
 37e:	a0a1                	j	3c6 <dns+0x366>
      len += 4;
 380:	00eb049b          	addiw	s1,s6,14
      record = 1;
 384:	77fd                	lui	a5,0xfffff
 386:	7b878793          	addi	a5,a5,1976 # fffffffffffff7b8 <__global_pointer$+0xffffffffffffde9f>
 38a:	97a2                	add	a5,a5,s0
 38c:	0157b023          	sd	s5,0(a5)
  for(int i = 0; i < ntohs(hdr->ancount); i++) {
 390:	2a05                	addiw	s4,s4,1
 392:	77fd                	lui	a5,0xfffff
 394:	7c678793          	addi	a5,a5,1990 # fffffffffffff7c6 <__global_pointer$+0xffffffffffffdead>
 398:	97a2                	add	a5,a5,s0
 39a:	0007d783          	lhu	a5,0(a5)
 39e:	0087d71b          	srliw	a4,a5,0x8
 3a2:	0087979b          	slliw	a5,a5,0x8
 3a6:	8fd9                	or	a5,a5,a4
 3a8:	17c2                	slli	a5,a5,0x30
 3aa:	93c1                	srli	a5,a5,0x30
 3ac:	0efa5263          	bge	s4,a5,490 <dns+0x430>
    char *qn = (char *) (ibuf+len);
 3b0:	77fd                	lui	a5,0xfffff
 3b2:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffdea7>
 3b6:	97a2                	add	a5,a5,s0
 3b8:	00978b33          	add	s6,a5,s1
    if((int) qn[0] > 63) {  // compression?
 3bc:	000b4783          	lbu	a5,0(s6)
 3c0:	fafdf3e3          	bgeu	s11,a5,366 <dns+0x306>
      len += 2;
 3c4:	2489                	addiw	s1,s1,2
    struct dns_data *d = (struct dns_data *) (ibuf+len);
 3c6:	77fd                	lui	a5,0xfffff
 3c8:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffdea7>
 3cc:	97a2                	add	a5,a5,s0
 3ce:	009786b3          	add	a3,a5,s1
    len += sizeof(struct dns_data);
 3d2:	00048b1b          	sext.w	s6,s1
 3d6:	24a9                	addiw	s1,s1,10
    if(ntohs(d->type) == ARECORD && ntohs(d->len) == 4) {
 3d8:	0006c783          	lbu	a5,0(a3)
 3dc:	0016c703          	lbu	a4,1(a3)
 3e0:	0722                	slli	a4,a4,0x8
 3e2:	8fd9                	or	a5,a5,a4
 3e4:	0087979b          	slliw	a5,a5,0x8
 3e8:	8321                	srli	a4,a4,0x8
 3ea:	8fd9                	or	a5,a5,a4
 3ec:	17c2                	slli	a5,a5,0x30
 3ee:	93c1                	srli	a5,a5,0x30
 3f0:	fb5790e3          	bne	a5,s5,390 <dns+0x330>
 3f4:	0086c783          	lbu	a5,8(a3)
 3f8:	0096c703          	lbu	a4,9(a3)
 3fc:	0722                	slli	a4,a4,0x8
 3fe:	8fd9                	or	a5,a5,a4
 400:	0087979b          	slliw	a5,a5,0x8
 404:	8321                	srli	a4,a4,0x8
 406:	8fd9                	or	a5,a5,a4
 408:	17c2                	slli	a5,a5,0x30
 40a:	93c1                	srli	a5,a5,0x30
 40c:	f9a792e3          	bne	a5,s10,390 <dns+0x330>
      printf("DNS arecord for %s is ", qname ? qname : "" );
 410:	77fd                	lui	a5,0xfffff
 412:	7b078793          	addi	a5,a5,1968 # fffffffffffff7b0 <__global_pointer$+0xffffffffffffde97>
 416:	97a2                	add	a5,a5,s0
 418:	638c                	ld	a1,0(a5)
 41a:	8566                	mv	a0,s9
 41c:	00001097          	auipc	ra,0x1
 420:	922080e7          	jalr	-1758(ra) # d3e <printf>
      uint8 *ip = (ibuf+len);
 424:	77fd                	lui	a5,0xfffff
 426:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffdea7>
 42a:	97a2                	add	a5,a5,s0
 42c:	94be                	add	s1,s1,a5
      printf("%d.%d.%d.%d\n", ip[0], ip[1], ip[2], ip[3]);
 42e:	0034c703          	lbu	a4,3(s1)
 432:	0024c683          	lbu	a3,2(s1)
 436:	0014c603          	lbu	a2,1(s1)
 43a:	0004c583          	lbu	a1,0(s1)
 43e:	00001517          	auipc	a0,0x1
 442:	b4a50513          	addi	a0,a0,-1206 # f88 <malloc+0x18c>
 446:	00001097          	auipc	ra,0x1
 44a:	8f8080e7          	jalr	-1800(ra) # d3e <printf>
      if(ip[0] != 128 || ip[1] != 52 || ip[2] != 129 || ip[3] != 126) {
 44e:	0004c783          	lbu	a5,0(s1)
 452:	03879263          	bne	a5,s8,476 <dns+0x416>
 456:	0014c783          	lbu	a5,1(s1)
 45a:	01779e63          	bne	a5,s7,476 <dns+0x416>
 45e:	0024c703          	lbu	a4,2(s1)
 462:	08100793          	li	a5,129
 466:	00f71863          	bne	a4,a5,476 <dns+0x416>
 46a:	0034c703          	lbu	a4,3(s1)
 46e:	07e00793          	li	a5,126
 472:	f0f707e3          	beq	a4,a5,380 <dns+0x320>
        printf("wrong ip address");
 476:	00001517          	auipc	a0,0x1
 47a:	b2250513          	addi	a0,a0,-1246 # f98 <malloc+0x19c>
 47e:	00001097          	auipc	ra,0x1
 482:	8c0080e7          	jalr	-1856(ra) # d3e <printf>
        exit(1);
 486:	4505                	li	a0,1
 488:	00000097          	auipc	ra,0x0
 48c:	52e080e7          	jalr	1326(ra) # 9b6 <exit>
  if(len != cc) {
 490:	04999d63          	bne	s3,s1,4ea <dns+0x48a>
  if(!record) {
 494:	77fd                	lui	a5,0xfffff
 496:	7b878793          	addi	a5,a5,1976 # fffffffffffff7b8 <__global_pointer$+0xffffffffffffde9f>
 49a:	97a2                	add	a5,a5,s0
 49c:	639c                	ld	a5,0(a5)
 49e:	c79d                	beqz	a5,4cc <dns+0x46c>
  }
  dns_rep(ibuf, cc);

  close(fd);
 4a0:	854a                	mv	a0,s2
 4a2:	00000097          	auipc	ra,0x0
 4a6:	53c080e7          	jalr	1340(ra) # 9de <close>
}
 4aa:	7d010113          	addi	sp,sp,2000
 4ae:	70e6                	ld	ra,120(sp)
 4b0:	7446                	ld	s0,112(sp)
 4b2:	74a6                	ld	s1,104(sp)
 4b4:	7906                	ld	s2,96(sp)
 4b6:	69e6                	ld	s3,88(sp)
 4b8:	6a46                	ld	s4,80(sp)
 4ba:	6aa6                	ld	s5,72(sp)
 4bc:	6b06                	ld	s6,64(sp)
 4be:	7be2                	ld	s7,56(sp)
 4c0:	7c42                	ld	s8,48(sp)
 4c2:	7ca2                	ld	s9,40(sp)
 4c4:	7d02                	ld	s10,32(sp)
 4c6:	6de2                	ld	s11,24(sp)
 4c8:	6109                	addi	sp,sp,128
 4ca:	8082                	ret
    printf("Didn't receive an arecord\n");
 4cc:	00001517          	auipc	a0,0x1
 4d0:	b1450513          	addi	a0,a0,-1260 # fe0 <malloc+0x1e4>
 4d4:	00001097          	auipc	ra,0x1
 4d8:	86a080e7          	jalr	-1942(ra) # d3e <printf>
    exit(1);
 4dc:	4505                	li	a0,1
 4de:	00000097          	auipc	ra,0x0
 4e2:	4d8080e7          	jalr	1240(ra) # 9b6 <exit>
  if(len != cc) {
 4e6:	fe9983e3          	beq	s3,s1,4cc <dns+0x46c>
    printf("Processed %d data bytes but received %d\n", len, cc);
 4ea:	864e                	mv	a2,s3
 4ec:	85a6                	mv	a1,s1
 4ee:	00001517          	auipc	a0,0x1
 4f2:	ac250513          	addi	a0,a0,-1342 # fb0 <malloc+0x1b4>
 4f6:	00001097          	auipc	ra,0x1
 4fa:	848080e7          	jalr	-1976(ra) # d3e <printf>
    exit(1);
 4fe:	4505                	li	a0,1
 500:	00000097          	auipc	ra,0x0
 504:	4b6080e7          	jalr	1206(ra) # 9b6 <exit>

0000000000000508 <main>:

int
main(int argc, char *argv[])
{
 508:	7131                	addi	sp,sp,-192
 50a:	fd06                	sd	ra,184(sp)
 50c:	f922                	sd	s0,176(sp)
 50e:	f526                	sd	s1,168(sp)
 510:	f14a                	sd	s2,160(sp)
 512:	0180                	addi	s0,sp,192
  // printf("testing single-process pings: ");
  // for (i = 0; i < 5; i++)
  //   ping(2000, dport, 1);
  // printf("OK\n");

  printf("testing multi-process pings: ");
 514:	00001517          	auipc	a0,0x1
 518:	aec50513          	addi	a0,a0,-1300 # 1000 <malloc+0x204>
 51c:	00001097          	auipc	ra,0x1
 520:	822080e7          	jalr	-2014(ra) # d3e <printf>
  for (i = 0; i < 5; i++){
 524:	4481                	li	s1,0
 526:	4915                	li	s2,5
    int pid = fork();
 528:	00000097          	auipc	ra,0x0
 52c:	486080e7          	jalr	1158(ra) # 9ae <fork>
    if (pid == 0){
 530:	c151                	beqz	a0,5b4 <main+0xac>
  for (i = 0; i < 5; i++){
 532:	2485                	addiw	s1,s1,1
 534:	ff249ae3          	bne	s1,s2,528 <main+0x20>
 538:	4495                	li	s1,5
      ping(2000 + i + 1, dport, 1);
      exit(0);
    }
  }
  for (i = 0; i < 5; i++){
    wait(&ret);
 53a:	fdc40513          	addi	a0,s0,-36
 53e:	00000097          	auipc	ra,0x0
 542:	480080e7          	jalr	1152(ra) # 9be <wait>
    if (ret != 0)
 546:	fdc42783          	lw	a5,-36(s0)
 54a:	1e079663          	bnez	a5,736 <main+0x22e>
  for (i = 0; i < 5; i++){
 54e:	34fd                	addiw	s1,s1,-1
 550:	f4ed                	bnez	s1,53a <main+0x32>
      exit(1);
  }
  printf("OK\n");
 552:	00001517          	auipc	a0,0x1
 556:	b6650513          	addi	a0,a0,-1178 # 10b8 <malloc+0x2bc>
 55a:	00000097          	auipc	ra,0x0
 55e:	7e4080e7          	jalr	2020(ra) # d3e <printf>
  // for (i = 0; i < 10; i++){
  //   wait(&ret);
  //   if (ret != 0)
  //     exit(1);
  // }
  printf("OK\n");
 562:	00001517          	auipc	a0,0x1
 566:	b5650513          	addi	a0,a0,-1194 # 10b8 <malloc+0x2bc>
 56a:	00000097          	auipc	ra,0x0
 56e:	7d4080e7          	jalr	2004(ra) # d3e <printf>

  printf("testing DNS\n");
 572:	00001517          	auipc	a0,0x1
 576:	b4e50513          	addi	a0,a0,-1202 # 10c0 <malloc+0x2c4>
 57a:	00000097          	auipc	ra,0x0
 57e:	7c4080e7          	jalr	1988(ra) # d3e <printf>
  dns();
 582:	00000097          	auipc	ra,0x0
 586:	ade080e7          	jalr	-1314(ra) # 60 <dns>
  printf("DNS OK\n");
 58a:	00001517          	auipc	a0,0x1
 58e:	b4650513          	addi	a0,a0,-1210 # 10d0 <malloc+0x2d4>
 592:	00000097          	auipc	ra,0x0
 596:	7ac080e7          	jalr	1964(ra) # d3e <printf>

  printf("all tests passed.\n");
 59a:	00001517          	auipc	a0,0x1
 59e:	b3e50513          	addi	a0,a0,-1218 # 10d8 <malloc+0x2dc>
 5a2:	00000097          	auipc	ra,0x0
 5a6:	79c080e7          	jalr	1948(ra) # d3e <printf>
  exit(0);
 5aa:	4501                	li	a0,0
 5ac:	00000097          	auipc	ra,0x0
 5b0:	40a080e7          	jalr	1034(ra) # 9b6 <exit>
  char obuf[13] = "hello world!";
 5b4:	00001797          	auipc	a5,0x1
 5b8:	b3c78793          	addi	a5,a5,-1220 # 10f0 <malloc+0x2f4>
 5bc:	6398                	ld	a4,0(a5)
 5be:	f4e43423          	sd	a4,-184(s0)
 5c2:	4798                	lw	a4,8(a5)
 5c4:	f4e42823          	sw	a4,-176(s0)
 5c8:	00c7c783          	lbu	a5,12(a5)
 5cc:	f4f40a23          	sb	a5,-172(s0)
  printf("hi1\n");
 5d0:	00001517          	auipc	a0,0x1
 5d4:	a5050513          	addi	a0,a0,-1456 # 1020 <malloc+0x224>
 5d8:	00000097          	auipc	ra,0x0
 5dc:	766080e7          	jalr	1894(ra) # d3e <printf>
      ping(2000 + i + 1, dport, 1);
 5e0:	7d14859b          	addiw	a1,s1,2001
  if((fd = connect(dst, sport, dport)) < 0){
 5e4:	6619                	lui	a2,0x6
 5e6:	40060613          	addi	a2,a2,1024 # 6400 <__global_pointer$+0x4ae7>
 5ea:	15c2                	slli	a1,a1,0x30
 5ec:	91c1                	srli	a1,a1,0x30
 5ee:	0a000537          	lui	a0,0xa000
 5f2:	20250513          	addi	a0,a0,514 # a000202 <__global_pointer$+0x9ffe8e9>
 5f6:	00000097          	auipc	ra,0x0
 5fa:	460080e7          	jalr	1120(ra) # a56 <connect>
 5fe:	84aa                	mv	s1,a0
 600:	0c054363          	bltz	a0,6c6 <main+0x1be>
  printf("hi2\n");
 604:	00001517          	auipc	a0,0x1
 608:	a2450513          	addi	a0,a0,-1500 # 1028 <malloc+0x22c>
 60c:	00000097          	auipc	ra,0x0
 610:	732080e7          	jalr	1842(ra) # d3e <printf>
    if(write(fd, obuf, sizeof(obuf)) < 0){
 614:	4635                	li	a2,13
 616:	f4840593          	addi	a1,s0,-184
 61a:	8526                	mv	a0,s1
 61c:	00000097          	auipc	ra,0x0
 620:	3ba080e7          	jalr	954(ra) # 9d6 <write>
 624:	0a054f63          	bltz	a0,6e2 <main+0x1da>
  printf("hi3\n");
 628:	00001517          	auipc	a0,0x1
 62c:	a2050513          	addi	a0,a0,-1504 # 1048 <malloc+0x24c>
 630:	00000097          	auipc	ra,0x0
 634:	70e080e7          	jalr	1806(ra) # d3e <printf>
  int cc = read(fd, ibuf, sizeof(ibuf));
 638:	08000613          	li	a2,128
 63c:	f5840593          	addi	a1,s0,-168
 640:	8526                	mv	a0,s1
 642:	00000097          	auipc	ra,0x0
 646:	38c080e7          	jalr	908(ra) # 9ce <read>
 64a:	892a                	mv	s2,a0
  if(cc < 0){
 64c:	0a054963          	bltz	a0,6fe <main+0x1f6>
  printf("hi4\n");
 650:	00001517          	auipc	a0,0x1
 654:	a1850513          	addi	a0,a0,-1512 # 1068 <malloc+0x26c>
 658:	00000097          	auipc	ra,0x0
 65c:	6e6080e7          	jalr	1766(ra) # d3e <printf>
  printf("\"%s\" : \"%s\"\n", obuf, ibuf);
 660:	f5840613          	addi	a2,s0,-168
 664:	f4840593          	addi	a1,s0,-184
 668:	00001517          	auipc	a0,0x1
 66c:	a0850513          	addi	a0,a0,-1528 # 1070 <malloc+0x274>
 670:	00000097          	auipc	ra,0x0
 674:	6ce080e7          	jalr	1742(ra) # d3e <printf>
  printf("%d\n", cc);
 678:	85ca                	mv	a1,s2
 67a:	00001517          	auipc	a0,0x1
 67e:	a0650513          	addi	a0,a0,-1530 # 1080 <malloc+0x284>
 682:	00000097          	auipc	ra,0x0
 686:	6bc080e7          	jalr	1724(ra) # d3e <printf>
  close(fd);
 68a:	8526                	mv	a0,s1
 68c:	00000097          	auipc	ra,0x0
 690:	352080e7          	jalr	850(ra) # 9de <close>
  if (strcmp(obuf, ibuf) || cc != sizeof(obuf)){
 694:	f5840593          	addi	a1,s0,-168
 698:	f4840513          	addi	a0,s0,-184
 69c:	00000097          	auipc	ra,0x0
 6a0:	0c0080e7          	jalr	192(ra) # 75c <strcmp>
 6a4:	e93d                	bnez	a0,71a <main+0x212>
 6a6:	47b5                	li	a5,13
 6a8:	06f91963          	bne	s2,a5,71a <main+0x212>
  printf("hi5\n");
 6ac:	00001517          	auipc	a0,0x1
 6b0:	a0450513          	addi	a0,a0,-1532 # 10b0 <malloc+0x2b4>
 6b4:	00000097          	auipc	ra,0x0
 6b8:	68a080e7          	jalr	1674(ra) # d3e <printf>
      exit(0);
 6bc:	4501                	li	a0,0
 6be:	00000097          	auipc	ra,0x0
 6c2:	2f8080e7          	jalr	760(ra) # 9b6 <exit>
    fprintf(2, "ping: connect() failed\n");
 6c6:	00001597          	auipc	a1,0x1
 6ca:	83258593          	addi	a1,a1,-1998 # ef8 <malloc+0xfc>
 6ce:	4509                	li	a0,2
 6d0:	00000097          	auipc	ra,0x0
 6d4:	640080e7          	jalr	1600(ra) # d10 <fprintf>
    exit(1);
 6d8:	4505                	li	a0,1
 6da:	00000097          	auipc	ra,0x0
 6de:	2dc080e7          	jalr	732(ra) # 9b6 <exit>
      fprintf(2, "ping: send() failed\n");
 6e2:	00001597          	auipc	a1,0x1
 6e6:	94e58593          	addi	a1,a1,-1714 # 1030 <malloc+0x234>
 6ea:	4509                	li	a0,2
 6ec:	00000097          	auipc	ra,0x0
 6f0:	624080e7          	jalr	1572(ra) # d10 <fprintf>
      exit(1);
 6f4:	4505                	li	a0,1
 6f6:	00000097          	auipc	ra,0x0
 6fa:	2c0080e7          	jalr	704(ra) # 9b6 <exit>
    fprintf(2, "ping: recv() failed\n");
 6fe:	00001597          	auipc	a1,0x1
 702:	95258593          	addi	a1,a1,-1710 # 1050 <malloc+0x254>
 706:	4509                	li	a0,2
 708:	00000097          	auipc	ra,0x0
 70c:	608080e7          	jalr	1544(ra) # d10 <fprintf>
    exit(1);
 710:	4505                	li	a0,1
 712:	00000097          	auipc	ra,0x0
 716:	2a4080e7          	jalr	676(ra) # 9b6 <exit>
    fprintf(2, "ping didn't receive correct payload\n");
 71a:	00001597          	auipc	a1,0x1
 71e:	96e58593          	addi	a1,a1,-1682 # 1088 <malloc+0x28c>
 722:	4509                	li	a0,2
 724:	00000097          	auipc	ra,0x0
 728:	5ec080e7          	jalr	1516(ra) # d10 <fprintf>
    exit(1);
 72c:	4505                	li	a0,1
 72e:	00000097          	auipc	ra,0x0
 732:	288080e7          	jalr	648(ra) # 9b6 <exit>
      exit(1);
 736:	4505                	li	a0,1
 738:	00000097          	auipc	ra,0x0
 73c:	27e080e7          	jalr	638(ra) # 9b6 <exit>

0000000000000740 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 740:	1141                	addi	sp,sp,-16
 742:	e422                	sd	s0,8(sp)
 744:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 746:	87aa                	mv	a5,a0
 748:	0585                	addi	a1,a1,1
 74a:	0785                	addi	a5,a5,1
 74c:	fff5c703          	lbu	a4,-1(a1)
 750:	fee78fa3          	sb	a4,-1(a5)
 754:	fb75                	bnez	a4,748 <strcpy+0x8>
    ;
  return os;
}
 756:	6422                	ld	s0,8(sp)
 758:	0141                	addi	sp,sp,16
 75a:	8082                	ret

000000000000075c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 75c:	1141                	addi	sp,sp,-16
 75e:	e422                	sd	s0,8(sp)
 760:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 762:	00054783          	lbu	a5,0(a0)
 766:	cb91                	beqz	a5,77a <strcmp+0x1e>
 768:	0005c703          	lbu	a4,0(a1)
 76c:	00f71763          	bne	a4,a5,77a <strcmp+0x1e>
    p++, q++;
 770:	0505                	addi	a0,a0,1
 772:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 774:	00054783          	lbu	a5,0(a0)
 778:	fbe5                	bnez	a5,768 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 77a:	0005c503          	lbu	a0,0(a1)
}
 77e:	40a7853b          	subw	a0,a5,a0
 782:	6422                	ld	s0,8(sp)
 784:	0141                	addi	sp,sp,16
 786:	8082                	ret

0000000000000788 <strlen>:

uint
strlen(const char *s)
{
 788:	1141                	addi	sp,sp,-16
 78a:	e422                	sd	s0,8(sp)
 78c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 78e:	00054783          	lbu	a5,0(a0)
 792:	cf91                	beqz	a5,7ae <strlen+0x26>
 794:	0505                	addi	a0,a0,1
 796:	87aa                	mv	a5,a0
 798:	4685                	li	a3,1
 79a:	9e89                	subw	a3,a3,a0
 79c:	00f6853b          	addw	a0,a3,a5
 7a0:	0785                	addi	a5,a5,1
 7a2:	fff7c703          	lbu	a4,-1(a5)
 7a6:	fb7d                	bnez	a4,79c <strlen+0x14>
    ;
  return n;
}
 7a8:	6422                	ld	s0,8(sp)
 7aa:	0141                	addi	sp,sp,16
 7ac:	8082                	ret
  for(n = 0; s[n]; n++)
 7ae:	4501                	li	a0,0
 7b0:	bfe5                	j	7a8 <strlen+0x20>

00000000000007b2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 7b2:	1141                	addi	sp,sp,-16
 7b4:	e422                	sd	s0,8(sp)
 7b6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 7b8:	ce09                	beqz	a2,7d2 <memset+0x20>
 7ba:	87aa                	mv	a5,a0
 7bc:	fff6071b          	addiw	a4,a2,-1
 7c0:	1702                	slli	a4,a4,0x20
 7c2:	9301                	srli	a4,a4,0x20
 7c4:	0705                	addi	a4,a4,1
 7c6:	972a                	add	a4,a4,a0
    cdst[i] = c;
 7c8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 7cc:	0785                	addi	a5,a5,1
 7ce:	fee79de3          	bne	a5,a4,7c8 <memset+0x16>
  }
  return dst;
}
 7d2:	6422                	ld	s0,8(sp)
 7d4:	0141                	addi	sp,sp,16
 7d6:	8082                	ret

00000000000007d8 <strchr>:

char*
strchr(const char *s, char c)
{
 7d8:	1141                	addi	sp,sp,-16
 7da:	e422                	sd	s0,8(sp)
 7dc:	0800                	addi	s0,sp,16
  for(; *s; s++)
 7de:	00054783          	lbu	a5,0(a0)
 7e2:	cb99                	beqz	a5,7f8 <strchr+0x20>
    if(*s == c)
 7e4:	00f58763          	beq	a1,a5,7f2 <strchr+0x1a>
  for(; *s; s++)
 7e8:	0505                	addi	a0,a0,1
 7ea:	00054783          	lbu	a5,0(a0)
 7ee:	fbfd                	bnez	a5,7e4 <strchr+0xc>
      return (char*)s;
  return 0;
 7f0:	4501                	li	a0,0
}
 7f2:	6422                	ld	s0,8(sp)
 7f4:	0141                	addi	sp,sp,16
 7f6:	8082                	ret
  return 0;
 7f8:	4501                	li	a0,0
 7fa:	bfe5                	j	7f2 <strchr+0x1a>

00000000000007fc <gets>:

char*
gets(char *buf, int max)
{
 7fc:	711d                	addi	sp,sp,-96
 7fe:	ec86                	sd	ra,88(sp)
 800:	e8a2                	sd	s0,80(sp)
 802:	e4a6                	sd	s1,72(sp)
 804:	e0ca                	sd	s2,64(sp)
 806:	fc4e                	sd	s3,56(sp)
 808:	f852                	sd	s4,48(sp)
 80a:	f456                	sd	s5,40(sp)
 80c:	f05a                	sd	s6,32(sp)
 80e:	ec5e                	sd	s7,24(sp)
 810:	1080                	addi	s0,sp,96
 812:	8baa                	mv	s7,a0
 814:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 816:	892a                	mv	s2,a0
 818:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 81a:	4aa9                	li	s5,10
 81c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 81e:	89a6                	mv	s3,s1
 820:	2485                	addiw	s1,s1,1
 822:	0344d863          	bge	s1,s4,852 <gets+0x56>
    cc = read(0, &c, 1);
 826:	4605                	li	a2,1
 828:	faf40593          	addi	a1,s0,-81
 82c:	4501                	li	a0,0
 82e:	00000097          	auipc	ra,0x0
 832:	1a0080e7          	jalr	416(ra) # 9ce <read>
    if(cc < 1)
 836:	00a05e63          	blez	a0,852 <gets+0x56>
    buf[i++] = c;
 83a:	faf44783          	lbu	a5,-81(s0)
 83e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 842:	01578763          	beq	a5,s5,850 <gets+0x54>
 846:	0905                	addi	s2,s2,1
 848:	fd679be3          	bne	a5,s6,81e <gets+0x22>
  for(i=0; i+1 < max; ){
 84c:	89a6                	mv	s3,s1
 84e:	a011                	j	852 <gets+0x56>
 850:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 852:	99de                	add	s3,s3,s7
 854:	00098023          	sb	zero,0(s3)
  return buf;
}
 858:	855e                	mv	a0,s7
 85a:	60e6                	ld	ra,88(sp)
 85c:	6446                	ld	s0,80(sp)
 85e:	64a6                	ld	s1,72(sp)
 860:	6906                	ld	s2,64(sp)
 862:	79e2                	ld	s3,56(sp)
 864:	7a42                	ld	s4,48(sp)
 866:	7aa2                	ld	s5,40(sp)
 868:	7b02                	ld	s6,32(sp)
 86a:	6be2                	ld	s7,24(sp)
 86c:	6125                	addi	sp,sp,96
 86e:	8082                	ret

0000000000000870 <stat>:

int
stat(const char *n, struct stat *st)
{
 870:	1101                	addi	sp,sp,-32
 872:	ec06                	sd	ra,24(sp)
 874:	e822                	sd	s0,16(sp)
 876:	e426                	sd	s1,8(sp)
 878:	e04a                	sd	s2,0(sp)
 87a:	1000                	addi	s0,sp,32
 87c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 87e:	4581                	li	a1,0
 880:	00000097          	auipc	ra,0x0
 884:	176080e7          	jalr	374(ra) # 9f6 <open>
  if(fd < 0)
 888:	02054563          	bltz	a0,8b2 <stat+0x42>
 88c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 88e:	85ca                	mv	a1,s2
 890:	00000097          	auipc	ra,0x0
 894:	17e080e7          	jalr	382(ra) # a0e <fstat>
 898:	892a                	mv	s2,a0
  close(fd);
 89a:	8526                	mv	a0,s1
 89c:	00000097          	auipc	ra,0x0
 8a0:	142080e7          	jalr	322(ra) # 9de <close>
  return r;
}
 8a4:	854a                	mv	a0,s2
 8a6:	60e2                	ld	ra,24(sp)
 8a8:	6442                	ld	s0,16(sp)
 8aa:	64a2                	ld	s1,8(sp)
 8ac:	6902                	ld	s2,0(sp)
 8ae:	6105                	addi	sp,sp,32
 8b0:	8082                	ret
    return -1;
 8b2:	597d                	li	s2,-1
 8b4:	bfc5                	j	8a4 <stat+0x34>

00000000000008b6 <atoi>:

int
atoi(const char *s)
{
 8b6:	1141                	addi	sp,sp,-16
 8b8:	e422                	sd	s0,8(sp)
 8ba:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 8bc:	00054603          	lbu	a2,0(a0)
 8c0:	fd06079b          	addiw	a5,a2,-48
 8c4:	0ff7f793          	andi	a5,a5,255
 8c8:	4725                	li	a4,9
 8ca:	02f76963          	bltu	a4,a5,8fc <atoi+0x46>
 8ce:	86aa                	mv	a3,a0
  n = 0;
 8d0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 8d2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 8d4:	0685                	addi	a3,a3,1
 8d6:	0025179b          	slliw	a5,a0,0x2
 8da:	9fa9                	addw	a5,a5,a0
 8dc:	0017979b          	slliw	a5,a5,0x1
 8e0:	9fb1                	addw	a5,a5,a2
 8e2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 8e6:	0006c603          	lbu	a2,0(a3)
 8ea:	fd06071b          	addiw	a4,a2,-48
 8ee:	0ff77713          	andi	a4,a4,255
 8f2:	fee5f1e3          	bgeu	a1,a4,8d4 <atoi+0x1e>
  return n;
}
 8f6:	6422                	ld	s0,8(sp)
 8f8:	0141                	addi	sp,sp,16
 8fa:	8082                	ret
  n = 0;
 8fc:	4501                	li	a0,0
 8fe:	bfe5                	j	8f6 <atoi+0x40>

0000000000000900 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 900:	1141                	addi	sp,sp,-16
 902:	e422                	sd	s0,8(sp)
 904:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 906:	02b57663          	bgeu	a0,a1,932 <memmove+0x32>
    while(n-- > 0)
 90a:	02c05163          	blez	a2,92c <memmove+0x2c>
 90e:	fff6079b          	addiw	a5,a2,-1
 912:	1782                	slli	a5,a5,0x20
 914:	9381                	srli	a5,a5,0x20
 916:	0785                	addi	a5,a5,1
 918:	97aa                	add	a5,a5,a0
  dst = vdst;
 91a:	872a                	mv	a4,a0
      *dst++ = *src++;
 91c:	0585                	addi	a1,a1,1
 91e:	0705                	addi	a4,a4,1
 920:	fff5c683          	lbu	a3,-1(a1)
 924:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 928:	fee79ae3          	bne	a5,a4,91c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 92c:	6422                	ld	s0,8(sp)
 92e:	0141                	addi	sp,sp,16
 930:	8082                	ret
    dst += n;
 932:	00c50733          	add	a4,a0,a2
    src += n;
 936:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 938:	fec05ae3          	blez	a2,92c <memmove+0x2c>
 93c:	fff6079b          	addiw	a5,a2,-1
 940:	1782                	slli	a5,a5,0x20
 942:	9381                	srli	a5,a5,0x20
 944:	fff7c793          	not	a5,a5
 948:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 94a:	15fd                	addi	a1,a1,-1
 94c:	177d                	addi	a4,a4,-1
 94e:	0005c683          	lbu	a3,0(a1)
 952:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 956:	fee79ae3          	bne	a5,a4,94a <memmove+0x4a>
 95a:	bfc9                	j	92c <memmove+0x2c>

000000000000095c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 95c:	1141                	addi	sp,sp,-16
 95e:	e422                	sd	s0,8(sp)
 960:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 962:	ca05                	beqz	a2,992 <memcmp+0x36>
 964:	fff6069b          	addiw	a3,a2,-1
 968:	1682                	slli	a3,a3,0x20
 96a:	9281                	srli	a3,a3,0x20
 96c:	0685                	addi	a3,a3,1
 96e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 970:	00054783          	lbu	a5,0(a0)
 974:	0005c703          	lbu	a4,0(a1)
 978:	00e79863          	bne	a5,a4,988 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 97c:	0505                	addi	a0,a0,1
    p2++;
 97e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 980:	fed518e3          	bne	a0,a3,970 <memcmp+0x14>
  }
  return 0;
 984:	4501                	li	a0,0
 986:	a019                	j	98c <memcmp+0x30>
      return *p1 - *p2;
 988:	40e7853b          	subw	a0,a5,a4
}
 98c:	6422                	ld	s0,8(sp)
 98e:	0141                	addi	sp,sp,16
 990:	8082                	ret
  return 0;
 992:	4501                	li	a0,0
 994:	bfe5                	j	98c <memcmp+0x30>

0000000000000996 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 996:	1141                	addi	sp,sp,-16
 998:	e406                	sd	ra,8(sp)
 99a:	e022                	sd	s0,0(sp)
 99c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 99e:	00000097          	auipc	ra,0x0
 9a2:	f62080e7          	jalr	-158(ra) # 900 <memmove>
}
 9a6:	60a2                	ld	ra,8(sp)
 9a8:	6402                	ld	s0,0(sp)
 9aa:	0141                	addi	sp,sp,16
 9ac:	8082                	ret

00000000000009ae <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 9ae:	4885                	li	a7,1
 ecall
 9b0:	00000073          	ecall
 ret
 9b4:	8082                	ret

00000000000009b6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 9b6:	4889                	li	a7,2
 ecall
 9b8:	00000073          	ecall
 ret
 9bc:	8082                	ret

00000000000009be <wait>:
.global wait
wait:
 li a7, SYS_wait
 9be:	488d                	li	a7,3
 ecall
 9c0:	00000073          	ecall
 ret
 9c4:	8082                	ret

00000000000009c6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 9c6:	4891                	li	a7,4
 ecall
 9c8:	00000073          	ecall
 ret
 9cc:	8082                	ret

00000000000009ce <read>:
.global read
read:
 li a7, SYS_read
 9ce:	4895                	li	a7,5
 ecall
 9d0:	00000073          	ecall
 ret
 9d4:	8082                	ret

00000000000009d6 <write>:
.global write
write:
 li a7, SYS_write
 9d6:	48c1                	li	a7,16
 ecall
 9d8:	00000073          	ecall
 ret
 9dc:	8082                	ret

00000000000009de <close>:
.global close
close:
 li a7, SYS_close
 9de:	48d5                	li	a7,21
 ecall
 9e0:	00000073          	ecall
 ret
 9e4:	8082                	ret

00000000000009e6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 9e6:	4899                	li	a7,6
 ecall
 9e8:	00000073          	ecall
 ret
 9ec:	8082                	ret

00000000000009ee <exec>:
.global exec
exec:
 li a7, SYS_exec
 9ee:	489d                	li	a7,7
 ecall
 9f0:	00000073          	ecall
 ret
 9f4:	8082                	ret

00000000000009f6 <open>:
.global open
open:
 li a7, SYS_open
 9f6:	48bd                	li	a7,15
 ecall
 9f8:	00000073          	ecall
 ret
 9fc:	8082                	ret

00000000000009fe <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 9fe:	48c5                	li	a7,17
 ecall
 a00:	00000073          	ecall
 ret
 a04:	8082                	ret

0000000000000a06 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 a06:	48c9                	li	a7,18
 ecall
 a08:	00000073          	ecall
 ret
 a0c:	8082                	ret

0000000000000a0e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 a0e:	48a1                	li	a7,8
 ecall
 a10:	00000073          	ecall
 ret
 a14:	8082                	ret

0000000000000a16 <link>:
.global link
link:
 li a7, SYS_link
 a16:	48cd                	li	a7,19
 ecall
 a18:	00000073          	ecall
 ret
 a1c:	8082                	ret

0000000000000a1e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 a1e:	48d1                	li	a7,20
 ecall
 a20:	00000073          	ecall
 ret
 a24:	8082                	ret

0000000000000a26 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 a26:	48a5                	li	a7,9
 ecall
 a28:	00000073          	ecall
 ret
 a2c:	8082                	ret

0000000000000a2e <dup>:
.global dup
dup:
 li a7, SYS_dup
 a2e:	48a9                	li	a7,10
 ecall
 a30:	00000073          	ecall
 ret
 a34:	8082                	ret

0000000000000a36 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 a36:	48ad                	li	a7,11
 ecall
 a38:	00000073          	ecall
 ret
 a3c:	8082                	ret

0000000000000a3e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 a3e:	48b1                	li	a7,12
 ecall
 a40:	00000073          	ecall
 ret
 a44:	8082                	ret

0000000000000a46 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 a46:	48b5                	li	a7,13
 ecall
 a48:	00000073          	ecall
 ret
 a4c:	8082                	ret

0000000000000a4e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 a4e:	48b9                	li	a7,14
 ecall
 a50:	00000073          	ecall
 ret
 a54:	8082                	ret

0000000000000a56 <connect>:
.global connect
connect:
 li a7, SYS_connect
 a56:	48d9                	li	a7,22
 ecall
 a58:	00000073          	ecall
 ret
 a5c:	8082                	ret

0000000000000a5e <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 a5e:	48dd                	li	a7,23
 ecall
 a60:	00000073          	ecall
 ret
 a64:	8082                	ret

0000000000000a66 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 a66:	1101                	addi	sp,sp,-32
 a68:	ec06                	sd	ra,24(sp)
 a6a:	e822                	sd	s0,16(sp)
 a6c:	1000                	addi	s0,sp,32
 a6e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 a72:	4605                	li	a2,1
 a74:	fef40593          	addi	a1,s0,-17
 a78:	00000097          	auipc	ra,0x0
 a7c:	f5e080e7          	jalr	-162(ra) # 9d6 <write>
}
 a80:	60e2                	ld	ra,24(sp)
 a82:	6442                	ld	s0,16(sp)
 a84:	6105                	addi	sp,sp,32
 a86:	8082                	ret

0000000000000a88 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 a88:	7139                	addi	sp,sp,-64
 a8a:	fc06                	sd	ra,56(sp)
 a8c:	f822                	sd	s0,48(sp)
 a8e:	f426                	sd	s1,40(sp)
 a90:	f04a                	sd	s2,32(sp)
 a92:	ec4e                	sd	s3,24(sp)
 a94:	0080                	addi	s0,sp,64
 a96:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 a98:	c299                	beqz	a3,a9e <printint+0x16>
 a9a:	0805c863          	bltz	a1,b2a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 a9e:	2581                	sext.w	a1,a1
  neg = 0;
 aa0:	4881                	li	a7,0
 aa2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 aa6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 aa8:	2601                	sext.w	a2,a2
 aaa:	00000517          	auipc	a0,0x0
 aae:	65e50513          	addi	a0,a0,1630 # 1108 <digits>
 ab2:	883a                	mv	a6,a4
 ab4:	2705                	addiw	a4,a4,1
 ab6:	02c5f7bb          	remuw	a5,a1,a2
 aba:	1782                	slli	a5,a5,0x20
 abc:	9381                	srli	a5,a5,0x20
 abe:	97aa                	add	a5,a5,a0
 ac0:	0007c783          	lbu	a5,0(a5)
 ac4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 ac8:	0005879b          	sext.w	a5,a1
 acc:	02c5d5bb          	divuw	a1,a1,a2
 ad0:	0685                	addi	a3,a3,1
 ad2:	fec7f0e3          	bgeu	a5,a2,ab2 <printint+0x2a>
  if(neg)
 ad6:	00088b63          	beqz	a7,aec <printint+0x64>
    buf[i++] = '-';
 ada:	fd040793          	addi	a5,s0,-48
 ade:	973e                	add	a4,a4,a5
 ae0:	02d00793          	li	a5,45
 ae4:	fef70823          	sb	a5,-16(a4)
 ae8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 aec:	02e05863          	blez	a4,b1c <printint+0x94>
 af0:	fc040793          	addi	a5,s0,-64
 af4:	00e78933          	add	s2,a5,a4
 af8:	fff78993          	addi	s3,a5,-1
 afc:	99ba                	add	s3,s3,a4
 afe:	377d                	addiw	a4,a4,-1
 b00:	1702                	slli	a4,a4,0x20
 b02:	9301                	srli	a4,a4,0x20
 b04:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 b08:	fff94583          	lbu	a1,-1(s2)
 b0c:	8526                	mv	a0,s1
 b0e:	00000097          	auipc	ra,0x0
 b12:	f58080e7          	jalr	-168(ra) # a66 <putc>
  while(--i >= 0)
 b16:	197d                	addi	s2,s2,-1
 b18:	ff3918e3          	bne	s2,s3,b08 <printint+0x80>
}
 b1c:	70e2                	ld	ra,56(sp)
 b1e:	7442                	ld	s0,48(sp)
 b20:	74a2                	ld	s1,40(sp)
 b22:	7902                	ld	s2,32(sp)
 b24:	69e2                	ld	s3,24(sp)
 b26:	6121                	addi	sp,sp,64
 b28:	8082                	ret
    x = -xx;
 b2a:	40b005bb          	negw	a1,a1
    neg = 1;
 b2e:	4885                	li	a7,1
    x = -xx;
 b30:	bf8d                	j	aa2 <printint+0x1a>

0000000000000b32 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 b32:	7119                	addi	sp,sp,-128
 b34:	fc86                	sd	ra,120(sp)
 b36:	f8a2                	sd	s0,112(sp)
 b38:	f4a6                	sd	s1,104(sp)
 b3a:	f0ca                	sd	s2,96(sp)
 b3c:	ecce                	sd	s3,88(sp)
 b3e:	e8d2                	sd	s4,80(sp)
 b40:	e4d6                	sd	s5,72(sp)
 b42:	e0da                	sd	s6,64(sp)
 b44:	fc5e                	sd	s7,56(sp)
 b46:	f862                	sd	s8,48(sp)
 b48:	f466                	sd	s9,40(sp)
 b4a:	f06a                	sd	s10,32(sp)
 b4c:	ec6e                	sd	s11,24(sp)
 b4e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 b50:	0005c903          	lbu	s2,0(a1)
 b54:	18090f63          	beqz	s2,cf2 <vprintf+0x1c0>
 b58:	8aaa                	mv	s5,a0
 b5a:	8b32                	mv	s6,a2
 b5c:	00158493          	addi	s1,a1,1
  state = 0;
 b60:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 b62:	02500a13          	li	s4,37
      if(c == 'd'){
 b66:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 b6a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 b6e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 b72:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 b76:	00000b97          	auipc	s7,0x0
 b7a:	592b8b93          	addi	s7,s7,1426 # 1108 <digits>
 b7e:	a839                	j	b9c <vprintf+0x6a>
        putc(fd, c);
 b80:	85ca                	mv	a1,s2
 b82:	8556                	mv	a0,s5
 b84:	00000097          	auipc	ra,0x0
 b88:	ee2080e7          	jalr	-286(ra) # a66 <putc>
 b8c:	a019                	j	b92 <vprintf+0x60>
    } else if(state == '%'){
 b8e:	01498f63          	beq	s3,s4,bac <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 b92:	0485                	addi	s1,s1,1
 b94:	fff4c903          	lbu	s2,-1(s1)
 b98:	14090d63          	beqz	s2,cf2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 b9c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 ba0:	fe0997e3          	bnez	s3,b8e <vprintf+0x5c>
      if(c == '%'){
 ba4:	fd479ee3          	bne	a5,s4,b80 <vprintf+0x4e>
        state = '%';
 ba8:	89be                	mv	s3,a5
 baa:	b7e5                	j	b92 <vprintf+0x60>
      if(c == 'd'){
 bac:	05878063          	beq	a5,s8,bec <vprintf+0xba>
      } else if(c == 'l') {
 bb0:	05978c63          	beq	a5,s9,c08 <vprintf+0xd6>
      } else if(c == 'x') {
 bb4:	07a78863          	beq	a5,s10,c24 <vprintf+0xf2>
      } else if(c == 'p') {
 bb8:	09b78463          	beq	a5,s11,c40 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 bbc:	07300713          	li	a4,115
 bc0:	0ce78663          	beq	a5,a4,c8c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 bc4:	06300713          	li	a4,99
 bc8:	0ee78e63          	beq	a5,a4,cc4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 bcc:	11478863          	beq	a5,s4,cdc <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 bd0:	85d2                	mv	a1,s4
 bd2:	8556                	mv	a0,s5
 bd4:	00000097          	auipc	ra,0x0
 bd8:	e92080e7          	jalr	-366(ra) # a66 <putc>
        putc(fd, c);
 bdc:	85ca                	mv	a1,s2
 bde:	8556                	mv	a0,s5
 be0:	00000097          	auipc	ra,0x0
 be4:	e86080e7          	jalr	-378(ra) # a66 <putc>
      }
      state = 0;
 be8:	4981                	li	s3,0
 bea:	b765                	j	b92 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 bec:	008b0913          	addi	s2,s6,8
 bf0:	4685                	li	a3,1
 bf2:	4629                	li	a2,10
 bf4:	000b2583          	lw	a1,0(s6)
 bf8:	8556                	mv	a0,s5
 bfa:	00000097          	auipc	ra,0x0
 bfe:	e8e080e7          	jalr	-370(ra) # a88 <printint>
 c02:	8b4a                	mv	s6,s2
      state = 0;
 c04:	4981                	li	s3,0
 c06:	b771                	j	b92 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 c08:	008b0913          	addi	s2,s6,8
 c0c:	4681                	li	a3,0
 c0e:	4629                	li	a2,10
 c10:	000b2583          	lw	a1,0(s6)
 c14:	8556                	mv	a0,s5
 c16:	00000097          	auipc	ra,0x0
 c1a:	e72080e7          	jalr	-398(ra) # a88 <printint>
 c1e:	8b4a                	mv	s6,s2
      state = 0;
 c20:	4981                	li	s3,0
 c22:	bf85                	j	b92 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 c24:	008b0913          	addi	s2,s6,8
 c28:	4681                	li	a3,0
 c2a:	4641                	li	a2,16
 c2c:	000b2583          	lw	a1,0(s6)
 c30:	8556                	mv	a0,s5
 c32:	00000097          	auipc	ra,0x0
 c36:	e56080e7          	jalr	-426(ra) # a88 <printint>
 c3a:	8b4a                	mv	s6,s2
      state = 0;
 c3c:	4981                	li	s3,0
 c3e:	bf91                	j	b92 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 c40:	008b0793          	addi	a5,s6,8
 c44:	f8f43423          	sd	a5,-120(s0)
 c48:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 c4c:	03000593          	li	a1,48
 c50:	8556                	mv	a0,s5
 c52:	00000097          	auipc	ra,0x0
 c56:	e14080e7          	jalr	-492(ra) # a66 <putc>
  putc(fd, 'x');
 c5a:	85ea                	mv	a1,s10
 c5c:	8556                	mv	a0,s5
 c5e:	00000097          	auipc	ra,0x0
 c62:	e08080e7          	jalr	-504(ra) # a66 <putc>
 c66:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 c68:	03c9d793          	srli	a5,s3,0x3c
 c6c:	97de                	add	a5,a5,s7
 c6e:	0007c583          	lbu	a1,0(a5)
 c72:	8556                	mv	a0,s5
 c74:	00000097          	auipc	ra,0x0
 c78:	df2080e7          	jalr	-526(ra) # a66 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 c7c:	0992                	slli	s3,s3,0x4
 c7e:	397d                	addiw	s2,s2,-1
 c80:	fe0914e3          	bnez	s2,c68 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 c84:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 c88:	4981                	li	s3,0
 c8a:	b721                	j	b92 <vprintf+0x60>
        s = va_arg(ap, char*);
 c8c:	008b0993          	addi	s3,s6,8
 c90:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 c94:	02090163          	beqz	s2,cb6 <vprintf+0x184>
        while(*s != 0){
 c98:	00094583          	lbu	a1,0(s2)
 c9c:	c9a1                	beqz	a1,cec <vprintf+0x1ba>
          putc(fd, *s);
 c9e:	8556                	mv	a0,s5
 ca0:	00000097          	auipc	ra,0x0
 ca4:	dc6080e7          	jalr	-570(ra) # a66 <putc>
          s++;
 ca8:	0905                	addi	s2,s2,1
        while(*s != 0){
 caa:	00094583          	lbu	a1,0(s2)
 cae:	f9e5                	bnez	a1,c9e <vprintf+0x16c>
        s = va_arg(ap, char*);
 cb0:	8b4e                	mv	s6,s3
      state = 0;
 cb2:	4981                	li	s3,0
 cb4:	bdf9                	j	b92 <vprintf+0x60>
          s = "(null)";
 cb6:	00000917          	auipc	s2,0x0
 cba:	44a90913          	addi	s2,s2,1098 # 1100 <malloc+0x304>
        while(*s != 0){
 cbe:	02800593          	li	a1,40
 cc2:	bff1                	j	c9e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 cc4:	008b0913          	addi	s2,s6,8
 cc8:	000b4583          	lbu	a1,0(s6)
 ccc:	8556                	mv	a0,s5
 cce:	00000097          	auipc	ra,0x0
 cd2:	d98080e7          	jalr	-616(ra) # a66 <putc>
 cd6:	8b4a                	mv	s6,s2
      state = 0;
 cd8:	4981                	li	s3,0
 cda:	bd65                	j	b92 <vprintf+0x60>
        putc(fd, c);
 cdc:	85d2                	mv	a1,s4
 cde:	8556                	mv	a0,s5
 ce0:	00000097          	auipc	ra,0x0
 ce4:	d86080e7          	jalr	-634(ra) # a66 <putc>
      state = 0;
 ce8:	4981                	li	s3,0
 cea:	b565                	j	b92 <vprintf+0x60>
        s = va_arg(ap, char*);
 cec:	8b4e                	mv	s6,s3
      state = 0;
 cee:	4981                	li	s3,0
 cf0:	b54d                	j	b92 <vprintf+0x60>
    }
  }
}
 cf2:	70e6                	ld	ra,120(sp)
 cf4:	7446                	ld	s0,112(sp)
 cf6:	74a6                	ld	s1,104(sp)
 cf8:	7906                	ld	s2,96(sp)
 cfa:	69e6                	ld	s3,88(sp)
 cfc:	6a46                	ld	s4,80(sp)
 cfe:	6aa6                	ld	s5,72(sp)
 d00:	6b06                	ld	s6,64(sp)
 d02:	7be2                	ld	s7,56(sp)
 d04:	7c42                	ld	s8,48(sp)
 d06:	7ca2                	ld	s9,40(sp)
 d08:	7d02                	ld	s10,32(sp)
 d0a:	6de2                	ld	s11,24(sp)
 d0c:	6109                	addi	sp,sp,128
 d0e:	8082                	ret

0000000000000d10 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 d10:	715d                	addi	sp,sp,-80
 d12:	ec06                	sd	ra,24(sp)
 d14:	e822                	sd	s0,16(sp)
 d16:	1000                	addi	s0,sp,32
 d18:	e010                	sd	a2,0(s0)
 d1a:	e414                	sd	a3,8(s0)
 d1c:	e818                	sd	a4,16(s0)
 d1e:	ec1c                	sd	a5,24(s0)
 d20:	03043023          	sd	a6,32(s0)
 d24:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 d28:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 d2c:	8622                	mv	a2,s0
 d2e:	00000097          	auipc	ra,0x0
 d32:	e04080e7          	jalr	-508(ra) # b32 <vprintf>
}
 d36:	60e2                	ld	ra,24(sp)
 d38:	6442                	ld	s0,16(sp)
 d3a:	6161                	addi	sp,sp,80
 d3c:	8082                	ret

0000000000000d3e <printf>:

void
printf(const char *fmt, ...)
{
 d3e:	711d                	addi	sp,sp,-96
 d40:	ec06                	sd	ra,24(sp)
 d42:	e822                	sd	s0,16(sp)
 d44:	1000                	addi	s0,sp,32
 d46:	e40c                	sd	a1,8(s0)
 d48:	e810                	sd	a2,16(s0)
 d4a:	ec14                	sd	a3,24(s0)
 d4c:	f018                	sd	a4,32(s0)
 d4e:	f41c                	sd	a5,40(s0)
 d50:	03043823          	sd	a6,48(s0)
 d54:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 d58:	00840613          	addi	a2,s0,8
 d5c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 d60:	85aa                	mv	a1,a0
 d62:	4505                	li	a0,1
 d64:	00000097          	auipc	ra,0x0
 d68:	dce080e7          	jalr	-562(ra) # b32 <vprintf>
}
 d6c:	60e2                	ld	ra,24(sp)
 d6e:	6442                	ld	s0,16(sp)
 d70:	6125                	addi	sp,sp,96
 d72:	8082                	ret

0000000000000d74 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 d74:	1141                	addi	sp,sp,-16
 d76:	e422                	sd	s0,8(sp)
 d78:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 d7a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d7e:	00000797          	auipc	a5,0x0
 d82:	3a27b783          	ld	a5,930(a5) # 1120 <freep>
 d86:	a805                	j	db6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 d88:	4618                	lw	a4,8(a2)
 d8a:	9db9                	addw	a1,a1,a4
 d8c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 d90:	6398                	ld	a4,0(a5)
 d92:	6318                	ld	a4,0(a4)
 d94:	fee53823          	sd	a4,-16(a0)
 d98:	a091                	j	ddc <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 d9a:	ff852703          	lw	a4,-8(a0)
 d9e:	9e39                	addw	a2,a2,a4
 da0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 da2:	ff053703          	ld	a4,-16(a0)
 da6:	e398                	sd	a4,0(a5)
 da8:	a099                	j	dee <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 daa:	6398                	ld	a4,0(a5)
 dac:	00e7e463          	bltu	a5,a4,db4 <free+0x40>
 db0:	00e6ea63          	bltu	a3,a4,dc4 <free+0x50>
{
 db4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 db6:	fed7fae3          	bgeu	a5,a3,daa <free+0x36>
 dba:	6398                	ld	a4,0(a5)
 dbc:	00e6e463          	bltu	a3,a4,dc4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 dc0:	fee7eae3          	bltu	a5,a4,db4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 dc4:	ff852583          	lw	a1,-8(a0)
 dc8:	6390                	ld	a2,0(a5)
 dca:	02059713          	slli	a4,a1,0x20
 dce:	9301                	srli	a4,a4,0x20
 dd0:	0712                	slli	a4,a4,0x4
 dd2:	9736                	add	a4,a4,a3
 dd4:	fae60ae3          	beq	a2,a4,d88 <free+0x14>
    bp->s.ptr = p->s.ptr;
 dd8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 ddc:	4790                	lw	a2,8(a5)
 dde:	02061713          	slli	a4,a2,0x20
 de2:	9301                	srli	a4,a4,0x20
 de4:	0712                	slli	a4,a4,0x4
 de6:	973e                	add	a4,a4,a5
 de8:	fae689e3          	beq	a3,a4,d9a <free+0x26>
  } else
    p->s.ptr = bp;
 dec:	e394                	sd	a3,0(a5)
  freep = p;
 dee:	00000717          	auipc	a4,0x0
 df2:	32f73923          	sd	a5,818(a4) # 1120 <freep>
}
 df6:	6422                	ld	s0,8(sp)
 df8:	0141                	addi	sp,sp,16
 dfa:	8082                	ret

0000000000000dfc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 dfc:	7139                	addi	sp,sp,-64
 dfe:	fc06                	sd	ra,56(sp)
 e00:	f822                	sd	s0,48(sp)
 e02:	f426                	sd	s1,40(sp)
 e04:	f04a                	sd	s2,32(sp)
 e06:	ec4e                	sd	s3,24(sp)
 e08:	e852                	sd	s4,16(sp)
 e0a:	e456                	sd	s5,8(sp)
 e0c:	e05a                	sd	s6,0(sp)
 e0e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 e10:	02051493          	slli	s1,a0,0x20
 e14:	9081                	srli	s1,s1,0x20
 e16:	04bd                	addi	s1,s1,15
 e18:	8091                	srli	s1,s1,0x4
 e1a:	0014899b          	addiw	s3,s1,1
 e1e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 e20:	00000517          	auipc	a0,0x0
 e24:	30053503          	ld	a0,768(a0) # 1120 <freep>
 e28:	c515                	beqz	a0,e54 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e2a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 e2c:	4798                	lw	a4,8(a5)
 e2e:	02977f63          	bgeu	a4,s1,e6c <malloc+0x70>
 e32:	8a4e                	mv	s4,s3
 e34:	0009871b          	sext.w	a4,s3
 e38:	6685                	lui	a3,0x1
 e3a:	00d77363          	bgeu	a4,a3,e40 <malloc+0x44>
 e3e:	6a05                	lui	s4,0x1
 e40:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 e44:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 e48:	00000917          	auipc	s2,0x0
 e4c:	2d890913          	addi	s2,s2,728 # 1120 <freep>
  if(p == (char*)-1)
 e50:	5afd                	li	s5,-1
 e52:	a88d                	j	ec4 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 e54:	00000797          	auipc	a5,0x0
 e58:	2d478793          	addi	a5,a5,724 # 1128 <base>
 e5c:	00000717          	auipc	a4,0x0
 e60:	2cf73223          	sd	a5,708(a4) # 1120 <freep>
 e64:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 e66:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 e6a:	b7e1                	j	e32 <malloc+0x36>
      if(p->s.size == nunits)
 e6c:	02e48b63          	beq	s1,a4,ea2 <malloc+0xa6>
        p->s.size -= nunits;
 e70:	4137073b          	subw	a4,a4,s3
 e74:	c798                	sw	a4,8(a5)
        p += p->s.size;
 e76:	1702                	slli	a4,a4,0x20
 e78:	9301                	srli	a4,a4,0x20
 e7a:	0712                	slli	a4,a4,0x4
 e7c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 e7e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 e82:	00000717          	auipc	a4,0x0
 e86:	28a73f23          	sd	a0,670(a4) # 1120 <freep>
      return (void*)(p + 1);
 e8a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 e8e:	70e2                	ld	ra,56(sp)
 e90:	7442                	ld	s0,48(sp)
 e92:	74a2                	ld	s1,40(sp)
 e94:	7902                	ld	s2,32(sp)
 e96:	69e2                	ld	s3,24(sp)
 e98:	6a42                	ld	s4,16(sp)
 e9a:	6aa2                	ld	s5,8(sp)
 e9c:	6b02                	ld	s6,0(sp)
 e9e:	6121                	addi	sp,sp,64
 ea0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 ea2:	6398                	ld	a4,0(a5)
 ea4:	e118                	sd	a4,0(a0)
 ea6:	bff1                	j	e82 <malloc+0x86>
  hp->s.size = nu;
 ea8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 eac:	0541                	addi	a0,a0,16
 eae:	00000097          	auipc	ra,0x0
 eb2:	ec6080e7          	jalr	-314(ra) # d74 <free>
  return freep;
 eb6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 eba:	d971                	beqz	a0,e8e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ebc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ebe:	4798                	lw	a4,8(a5)
 ec0:	fa9776e3          	bgeu	a4,s1,e6c <malloc+0x70>
    if(p == freep)
 ec4:	00093703          	ld	a4,0(s2)
 ec8:	853e                	mv	a0,a5
 eca:	fef719e3          	bne	a4,a5,ebc <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 ece:	8552                	mv	a0,s4
 ed0:	00000097          	auipc	ra,0x0
 ed4:	b6e080e7          	jalr	-1170(ra) # a3e <sbrk>
  if(p == (char*)-1)
 ed8:	fd5518e3          	bne	a0,s5,ea8 <malloc+0xac>
        return 0;
 edc:	4501                	li	a0,0
 ede:	bf45                	j	e8e <malloc+0x92>
