
user/_testsh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <rand>:

// return a random integer.
// from Wikipedia, linear congruential generator, glibc's constants.
unsigned int
rand()
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
  unsigned int a = 1103515245;
  unsigned int c = 12345;
  unsigned int m = (1 << 31);
  seed = (a * seed + c) % m;
       6:	00002717          	auipc	a4,0x2
       a:	88670713          	addi	a4,a4,-1914 # 188c <seed>
       e:	4308                	lw	a0,0(a4)
      10:	41c657b7          	lui	a5,0x41c65
      14:	e6d7879b          	addiw	a5,a5,-403
      18:	02f5053b          	mulw	a0,a0,a5
      1c:	678d                	lui	a5,0x3
      1e:	0397879b          	addiw	a5,a5,57
      22:	9d3d                	addw	a0,a0,a5
      24:	1506                	slli	a0,a0,0x21
      26:	9105                	srli	a0,a0,0x21
      28:	c308                	sw	a0,0(a4)
  return seed;
}
      2a:	6422                	ld	s0,8(sp)
      2c:	0141                	addi	sp,sp,16
      2e:	8082                	ret

0000000000000030 <randstring>:

// generate a random string of the indicated length.
char *
randstring(char *buf, int n)
{
      30:	7139                	addi	sp,sp,-64
      32:	fc06                	sd	ra,56(sp)
      34:	f822                	sd	s0,48(sp)
      36:	f426                	sd	s1,40(sp)
      38:	f04a                	sd	s2,32(sp)
      3a:	ec4e                	sd	s3,24(sp)
      3c:	e852                	sd	s4,16(sp)
      3e:	e456                	sd	s5,8(sp)
      40:	e05a                	sd	s6,0(sp)
      42:	0080                	addi	s0,sp,64
      44:	8aaa                	mv	s5,a0
      46:	8a2e                	mv	s4,a1
  for(int i = 0; i < n-1; i++)
      48:	4785                	li	a5,1
      4a:	02b7dd63          	bge	a5,a1,84 <randstring+0x54>
      4e:	84aa                	mv	s1,a0
      50:	00150913          	addi	s2,a0,1
      54:	ffe5879b          	addiw	a5,a1,-2
      58:	1782                	slli	a5,a5,0x20
      5a:	9381                	srli	a5,a5,0x20
      5c:	993e                	add	s2,s2,a5
    buf[i] = "abcdefghijklmnopqrstuvwxyz"[rand() % 26];
      5e:	00001b17          	auipc	s6,0x1
      62:	3fab0b13          	addi	s6,s6,1018 # 1458 <malloc+0xe8>
      66:	49e9                	li	s3,26
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <rand>
      70:	033577bb          	remuw	a5,a0,s3
      74:	97da                	add	a5,a5,s6
      76:	0007c783          	lbu	a5,0(a5) # 3000 <__global_pointer$+0xf77>
      7a:	00f48023          	sb	a5,0(s1)
  for(int i = 0; i < n-1; i++)
      7e:	0485                	addi	s1,s1,1
      80:	ff2494e3          	bne	s1,s2,68 <randstring+0x38>
  buf[n-1] = '\0';
      84:	9a56                	add	s4,s4,s5
      86:	fe0a0fa3          	sb	zero,-1(s4)
  return buf;
}
      8a:	8556                	mv	a0,s5
      8c:	70e2                	ld	ra,56(sp)
      8e:	7442                	ld	s0,48(sp)
      90:	74a2                	ld	s1,40(sp)
      92:	7902                	ld	s2,32(sp)
      94:	69e2                	ld	s3,24(sp)
      96:	6a42                	ld	s4,16(sp)
      98:	6aa2                	ld	s5,8(sp)
      9a:	6b02                	ld	s6,0(sp)
      9c:	6121                	addi	sp,sp,64
      9e:	8082                	ret

00000000000000a0 <writefile>:

// create a file with the indicated content.
void
writefile(char *name, char *data)
{
      a0:	7179                	addi	sp,sp,-48
      a2:	f406                	sd	ra,40(sp)
      a4:	f022                	sd	s0,32(sp)
      a6:	ec26                	sd	s1,24(sp)
      a8:	e84a                	sd	s2,16(sp)
      aa:	e44e                	sd	s3,8(sp)
      ac:	1800                	addi	s0,sp,48
      ae:	89aa                	mv	s3,a0
      b0:	892e                	mv	s2,a1
  unlink(name); // since no truncation
      b2:	00001097          	auipc	ra,0x1
      b6:	ec8080e7          	jalr	-312(ra) # f7a <unlink>
  int fd = open(name, O_CREATE|O_WRONLY);
      ba:	20100593          	li	a1,513
      be:	854e                	mv	a0,s3
      c0:	00001097          	auipc	ra,0x1
      c4:	eaa080e7          	jalr	-342(ra) # f6a <open>
  if(fd < 0){
      c8:	04054663          	bltz	a0,114 <writefile+0x74>
      cc:	84aa                	mv	s1,a0
    fprintf(2, "testsh: could not write %s\n", name);
    exit(-1);
  }
  if(write(fd, data, strlen(data)) != strlen(data)){
      ce:	854a                	mv	a0,s2
      d0:	00001097          	auipc	ra,0x1
      d4:	c2c080e7          	jalr	-980(ra) # cfc <strlen>
      d8:	0005061b          	sext.w	a2,a0
      dc:	85ca                	mv	a1,s2
      de:	8526                	mv	a0,s1
      e0:	00001097          	auipc	ra,0x1
      e4:	e6a080e7          	jalr	-406(ra) # f4a <write>
      e8:	89aa                	mv	s3,a0
      ea:	854a                	mv	a0,s2
      ec:	00001097          	auipc	ra,0x1
      f0:	c10080e7          	jalr	-1008(ra) # cfc <strlen>
      f4:	2501                	sext.w	a0,a0
      f6:	2981                	sext.w	s3,s3
      f8:	02a99d63          	bne	s3,a0,132 <writefile+0x92>
    fprintf(2, "testsh: write failed\n");
    exit(-1);
  }
  close(fd);
      fc:	8526                	mv	a0,s1
      fe:	00001097          	auipc	ra,0x1
     102:	e54080e7          	jalr	-428(ra) # f52 <close>
}
     106:	70a2                	ld	ra,40(sp)
     108:	7402                	ld	s0,32(sp)
     10a:	64e2                	ld	s1,24(sp)
     10c:	6942                	ld	s2,16(sp)
     10e:	69a2                	ld	s3,8(sp)
     110:	6145                	addi	sp,sp,48
     112:	8082                	ret
    fprintf(2, "testsh: could not write %s\n", name);
     114:	864e                	mv	a2,s3
     116:	00001597          	auipc	a1,0x1
     11a:	36258593          	addi	a1,a1,866 # 1478 <malloc+0x108>
     11e:	4509                	li	a0,2
     120:	00001097          	auipc	ra,0x1
     124:	164080e7          	jalr	356(ra) # 1284 <fprintf>
    exit(-1);
     128:	557d                	li	a0,-1
     12a:	00001097          	auipc	ra,0x1
     12e:	e00080e7          	jalr	-512(ra) # f2a <exit>
    fprintf(2, "testsh: write failed\n");
     132:	00001597          	auipc	a1,0x1
     136:	36658593          	addi	a1,a1,870 # 1498 <malloc+0x128>
     13a:	4509                	li	a0,2
     13c:	00001097          	auipc	ra,0x1
     140:	148080e7          	jalr	328(ra) # 1284 <fprintf>
    exit(-1);
     144:	557d                	li	a0,-1
     146:	00001097          	auipc	ra,0x1
     14a:	de4080e7          	jalr	-540(ra) # f2a <exit>

000000000000014e <readfile>:

// return the content of a file.
void
readfile(char *name, char *data, int max)
{
     14e:	7179                	addi	sp,sp,-48
     150:	f406                	sd	ra,40(sp)
     152:	f022                	sd	s0,32(sp)
     154:	ec26                	sd	s1,24(sp)
     156:	e84a                	sd	s2,16(sp)
     158:	e44e                	sd	s3,8(sp)
     15a:	e052                	sd	s4,0(sp)
     15c:	1800                	addi	s0,sp,48
     15e:	8a2a                	mv	s4,a0
     160:	84ae                	mv	s1,a1
     162:	89b2                	mv	s3,a2
  data[0] = '\0';
     164:	00058023          	sb	zero,0(a1)
  int fd = open(name, 0);
     168:	4581                	li	a1,0
     16a:	00001097          	auipc	ra,0x1
     16e:	e00080e7          	jalr	-512(ra) # f6a <open>
  if(fd < 0){
     172:	02054d63          	bltz	a0,1ac <readfile+0x5e>
     176:	892a                	mv	s2,a0
    fprintf(2, "testsh: open %s failed\n", name);
    return;
  }
  int n = read(fd, data, max-1);
     178:	fff9861b          	addiw	a2,s3,-1
     17c:	85a6                	mv	a1,s1
     17e:	00001097          	auipc	ra,0x1
     182:	dc4080e7          	jalr	-572(ra) # f42 <read>
     186:	89aa                	mv	s3,a0
  close(fd);
     188:	854a                	mv	a0,s2
     18a:	00001097          	auipc	ra,0x1
     18e:	dc8080e7          	jalr	-568(ra) # f52 <close>
  if(n < 0){
     192:	0209c863          	bltz	s3,1c2 <readfile+0x74>
    fprintf(2, "testsh: read %s failed\n", name);
    return;
  }
  data[n] = '\0';
     196:	94ce                	add	s1,s1,s3
     198:	00048023          	sb	zero,0(s1)
}
     19c:	70a2                	ld	ra,40(sp)
     19e:	7402                	ld	s0,32(sp)
     1a0:	64e2                	ld	s1,24(sp)
     1a2:	6942                	ld	s2,16(sp)
     1a4:	69a2                	ld	s3,8(sp)
     1a6:	6a02                	ld	s4,0(sp)
     1a8:	6145                	addi	sp,sp,48
     1aa:	8082                	ret
    fprintf(2, "testsh: open %s failed\n", name);
     1ac:	8652                	mv	a2,s4
     1ae:	00001597          	auipc	a1,0x1
     1b2:	30258593          	addi	a1,a1,770 # 14b0 <malloc+0x140>
     1b6:	4509                	li	a0,2
     1b8:	00001097          	auipc	ra,0x1
     1bc:	0cc080e7          	jalr	204(ra) # 1284 <fprintf>
    return;
     1c0:	bff1                	j	19c <readfile+0x4e>
    fprintf(2, "testsh: read %s failed\n", name);
     1c2:	8652                	mv	a2,s4
     1c4:	00001597          	auipc	a1,0x1
     1c8:	30458593          	addi	a1,a1,772 # 14c8 <malloc+0x158>
     1cc:	4509                	li	a0,2
     1ce:	00001097          	auipc	ra,0x1
     1d2:	0b6080e7          	jalr	182(ra) # 1284 <fprintf>
    return;
     1d6:	b7d9                	j	19c <readfile+0x4e>

00000000000001d8 <strstr>:

// look for the small string in the big string;
// return the address in the big string, or 0.
char *
strstr(char *big, char *small)
{
     1d8:	1141                	addi	sp,sp,-16
     1da:	e422                	sd	s0,8(sp)
     1dc:	0800                	addi	s0,sp,16
  if(small[0] == '\0')
     1de:	0005c883          	lbu	a7,0(a1)
     1e2:	02088b63          	beqz	a7,218 <strstr+0x40>
    return big;
  for(int i = 0; big[i]; i++){
     1e6:	00054783          	lbu	a5,0(a0)
     1ea:	eb89                	bnez	a5,1fc <strstr+0x24>
    }
    if(small[j] == '\0'){
      return big + i;
    }
  }
  return 0;
     1ec:	4501                	li	a0,0
     1ee:	a02d                	j	218 <strstr+0x40>
    if(small[j] == '\0'){
     1f0:	c785                	beqz	a5,218 <strstr+0x40>
  for(int i = 0; big[i]; i++){
     1f2:	00180513          	addi	a0,a6,1
     1f6:	00184783          	lbu	a5,1(a6)
     1fa:	c395                	beqz	a5,21e <strstr+0x46>
    for(j = 0; small[j]; j++){
     1fc:	882a                	mv	a6,a0
     1fe:	00158693          	addi	a3,a1,1
{
     202:	872a                	mv	a4,a0
    for(j = 0; small[j]; j++){
     204:	87c6                	mv	a5,a7
      if(big[i+j] != small[j]){
     206:	00074603          	lbu	a2,0(a4)
     20a:	fef613e3          	bne	a2,a5,1f0 <strstr+0x18>
    for(j = 0; small[j]; j++){
     20e:	0006c783          	lbu	a5,0(a3)
     212:	0705                	addi	a4,a4,1
     214:	0685                	addi	a3,a3,1
     216:	fbe5                	bnez	a5,206 <strstr+0x2e>
}
     218:	6422                	ld	s0,8(sp)
     21a:	0141                	addi	sp,sp,16
     21c:	8082                	ret
  return 0;
     21e:	4501                	li	a0,0
     220:	bfe5                	j	218 <strstr+0x40>

0000000000000222 <one>:
// its input, collect the output, check that the
// output includes the expect argument.
// if tight = 1, don't allow much extraneous output.
int
one(char *cmd, char *expect, int tight)
{
     222:	710d                	addi	sp,sp,-352
     224:	ee86                	sd	ra,344(sp)
     226:	eaa2                	sd	s0,336(sp)
     228:	e6a6                	sd	s1,328(sp)
     22a:	e2ca                	sd	s2,320(sp)
     22c:	fe4e                	sd	s3,312(sp)
     22e:	1280                	addi	s0,sp,352
     230:	84aa                	mv	s1,a0
     232:	892e                	mv	s2,a1
     234:	89b2                	mv	s3,a2
  char infile[12], outfile[12];

  randstring(infile, sizeof(infile));
     236:	45b1                	li	a1,12
     238:	fc040513          	addi	a0,s0,-64
     23c:	00000097          	auipc	ra,0x0
     240:	df4080e7          	jalr	-524(ra) # 30 <randstring>
  randstring(outfile, sizeof(outfile));
     244:	45b1                	li	a1,12
     246:	fb040513          	addi	a0,s0,-80
     24a:	00000097          	auipc	ra,0x0
     24e:	de6080e7          	jalr	-538(ra) # 30 <randstring>

  writefile(infile, cmd);
     252:	85a6                	mv	a1,s1
     254:	fc040513          	addi	a0,s0,-64
     258:	00000097          	auipc	ra,0x0
     25c:	e48080e7          	jalr	-440(ra) # a0 <writefile>
  unlink(outfile);
     260:	fb040513          	addi	a0,s0,-80
     264:	00001097          	auipc	ra,0x1
     268:	d16080e7          	jalr	-746(ra) # f7a <unlink>

  int pid = fork();
     26c:	00001097          	auipc	ra,0x1
     270:	cb6080e7          	jalr	-842(ra) # f22 <fork>
  if(pid < 0){
     274:	04054f63          	bltz	a0,2d2 <one+0xb0>
     278:	84aa                	mv	s1,a0
    fprintf(2, "testsh: fork() failed\n");
    exit(-1);
  }

  if(pid == 0){
     27a:	e571                	bnez	a0,346 <one+0x124>
    close(0);
     27c:	4501                	li	a0,0
     27e:	00001097          	auipc	ra,0x1
     282:	cd4080e7          	jalr	-812(ra) # f52 <close>
    if(open(infile, 0) != 0){
     286:	4581                	li	a1,0
     288:	fc040513          	addi	a0,s0,-64
     28c:	00001097          	auipc	ra,0x1
     290:	cde080e7          	jalr	-802(ra) # f6a <open>
     294:	ed29                	bnez	a0,2ee <one+0xcc>
      fprintf(2, "testsh: child open != 0\n");
      exit(-1);
    }
    close(1);
     296:	4505                	li	a0,1
     298:	00001097          	auipc	ra,0x1
     29c:	cba080e7          	jalr	-838(ra) # f52 <close>
    if(open(outfile, O_CREATE|O_WRONLY) != 1){
     2a0:	20100593          	li	a1,513
     2a4:	fb040513          	addi	a0,s0,-80
     2a8:	00001097          	auipc	ra,0x1
     2ac:	cc2080e7          	jalr	-830(ra) # f6a <open>
     2b0:	4785                	li	a5,1
     2b2:	04f50c63          	beq	a0,a5,30a <one+0xe8>
      fprintf(2, "testsh: child open != 1\n");
     2b6:	00001597          	auipc	a1,0x1
     2ba:	26258593          	addi	a1,a1,610 # 1518 <malloc+0x1a8>
     2be:	4509                	li	a0,2
     2c0:	00001097          	auipc	ra,0x1
     2c4:	fc4080e7          	jalr	-60(ra) # 1284 <fprintf>
      exit(-1);
     2c8:	557d                	li	a0,-1
     2ca:	00001097          	auipc	ra,0x1
     2ce:	c60080e7          	jalr	-928(ra) # f2a <exit>
    fprintf(2, "testsh: fork() failed\n");
     2d2:	00001597          	auipc	a1,0x1
     2d6:	20e58593          	addi	a1,a1,526 # 14e0 <malloc+0x170>
     2da:	4509                	li	a0,2
     2dc:	00001097          	auipc	ra,0x1
     2e0:	fa8080e7          	jalr	-88(ra) # 1284 <fprintf>
    exit(-1);
     2e4:	557d                	li	a0,-1
     2e6:	00001097          	auipc	ra,0x1
     2ea:	c44080e7          	jalr	-956(ra) # f2a <exit>
      fprintf(2, "testsh: child open != 0\n");
     2ee:	00001597          	auipc	a1,0x1
     2f2:	20a58593          	addi	a1,a1,522 # 14f8 <malloc+0x188>
     2f6:	4509                	li	a0,2
     2f8:	00001097          	auipc	ra,0x1
     2fc:	f8c080e7          	jalr	-116(ra) # 1284 <fprintf>
      exit(-1);
     300:	557d                	li	a0,-1
     302:	00001097          	auipc	ra,0x1
     306:	c28080e7          	jalr	-984(ra) # f2a <exit>
    }
    char *argv[2];
    argv[0] = shname;
     30a:	00001497          	auipc	s1,0x1
     30e:	58648493          	addi	s1,s1,1414 # 1890 <_edata>
     312:	6088                	ld	a0,0(s1)
     314:	eaa43023          	sd	a0,-352(s0)
    argv[1] = 0;
     318:	ea043423          	sd	zero,-344(s0)
    exec(shname, argv);
     31c:	ea040593          	addi	a1,s0,-352
     320:	00001097          	auipc	ra,0x1
     324:	c42080e7          	jalr	-958(ra) # f62 <exec>
    fprintf(2, "testsh: exec %s failed\n", shname);
     328:	6090                	ld	a2,0(s1)
     32a:	00001597          	auipc	a1,0x1
     32e:	20e58593          	addi	a1,a1,526 # 1538 <malloc+0x1c8>
     332:	4509                	li	a0,2
     334:	00001097          	auipc	ra,0x1
     338:	f50080e7          	jalr	-176(ra) # 1284 <fprintf>
    exit(-1);
     33c:	557d                	li	a0,-1
     33e:	00001097          	auipc	ra,0x1
     342:	bec080e7          	jalr	-1044(ra) # f2a <exit>
  }

  if(wait(0) != pid){
     346:	4501                	li	a0,0
     348:	00001097          	auipc	ra,0x1
     34c:	bea080e7          	jalr	-1046(ra) # f32 <wait>
     350:	04951c63          	bne	a0,s1,3a8 <one+0x186>
    fprintf(2, "testsh: unexpected wait() return\n");
    exit(-1);
  }
  unlink(infile);
     354:	fc040513          	addi	a0,s0,-64
     358:	00001097          	auipc	ra,0x1
     35c:	c22080e7          	jalr	-990(ra) # f7a <unlink>

  char out[256];
  readfile(outfile, out, sizeof(out));
     360:	10000613          	li	a2,256
     364:	eb040593          	addi	a1,s0,-336
     368:	fb040513          	addi	a0,s0,-80
     36c:	00000097          	auipc	ra,0x0
     370:	de2080e7          	jalr	-542(ra) # 14e <readfile>
  unlink(outfile);
     374:	fb040513          	addi	a0,s0,-80
     378:	00001097          	auipc	ra,0x1
     37c:	c02080e7          	jalr	-1022(ra) # f7a <unlink>

  if(strstr(out, expect) != 0){
     380:	85ca                	mv	a1,s2
     382:	eb040513          	addi	a0,s0,-336
     386:	00000097          	auipc	ra,0x0
     38a:	e52080e7          	jalr	-430(ra) # 1d8 <strstr>
      fprintf(2, "testsh: saw expected output, but too much else as well\n");
      return 0; // fail
    }
    return 1; // pass
  }
  return 0; // fail
     38e:	4781                	li	a5,0
  if(strstr(out, expect) != 0){
     390:	c501                	beqz	a0,398 <one+0x176>
    return 1; // pass
     392:	4785                	li	a5,1
    if(tight && strlen(out) > strlen(expect) + 10){
     394:	02099863          	bnez	s3,3c4 <one+0x1a2>
}
     398:	853e                	mv	a0,a5
     39a:	60f6                	ld	ra,344(sp)
     39c:	6456                	ld	s0,336(sp)
     39e:	64b6                	ld	s1,328(sp)
     3a0:	6916                	ld	s2,320(sp)
     3a2:	79f2                	ld	s3,312(sp)
     3a4:	6135                	addi	sp,sp,352
     3a6:	8082                	ret
    fprintf(2, "testsh: unexpected wait() return\n");
     3a8:	00001597          	auipc	a1,0x1
     3ac:	1a858593          	addi	a1,a1,424 # 1550 <malloc+0x1e0>
     3b0:	4509                	li	a0,2
     3b2:	00001097          	auipc	ra,0x1
     3b6:	ed2080e7          	jalr	-302(ra) # 1284 <fprintf>
    exit(-1);
     3ba:	557d                	li	a0,-1
     3bc:	00001097          	auipc	ra,0x1
     3c0:	b6e080e7          	jalr	-1170(ra) # f2a <exit>
    if(tight && strlen(out) > strlen(expect) + 10){
     3c4:	eb040513          	addi	a0,s0,-336
     3c8:	00001097          	auipc	ra,0x1
     3cc:	934080e7          	jalr	-1740(ra) # cfc <strlen>
     3d0:	0005049b          	sext.w	s1,a0
     3d4:	854a                	mv	a0,s2
     3d6:	00001097          	auipc	ra,0x1
     3da:	926080e7          	jalr	-1754(ra) # cfc <strlen>
     3de:	2529                	addiw	a0,a0,10
    return 1; // pass
     3e0:	4785                	li	a5,1
    if(tight && strlen(out) > strlen(expect) + 10){
     3e2:	fa957be3          	bgeu	a0,s1,398 <one+0x176>
      fprintf(2, "testsh: saw expected output, but too much else as well\n");
     3e6:	00001597          	auipc	a1,0x1
     3ea:	19258593          	addi	a1,a1,402 # 1578 <malloc+0x208>
     3ee:	4509                	li	a0,2
     3f0:	00001097          	auipc	ra,0x1
     3f4:	e94080e7          	jalr	-364(ra) # 1284 <fprintf>
      return 0; // fail
     3f8:	4781                	li	a5,0
     3fa:	bf79                	j	398 <one+0x176>

00000000000003fc <t1>:

// test a command with arguments.
void
t1(int *ok)
{
     3fc:	1101                	addi	sp,sp,-32
     3fe:	ec06                	sd	ra,24(sp)
     400:	e822                	sd	s0,16(sp)
     402:	e426                	sd	s1,8(sp)
     404:	1000                	addi	s0,sp,32
     406:	84aa                	mv	s1,a0
  printf("simple echo: ");
     408:	00001517          	auipc	a0,0x1
     40c:	1a850513          	addi	a0,a0,424 # 15b0 <malloc+0x240>
     410:	00001097          	auipc	ra,0x1
     414:	ea2080e7          	jalr	-350(ra) # 12b2 <printf>
  if(one("echo hello goodbye\n", "hello goodbye", 1) == 0){
     418:	4605                	li	a2,1
     41a:	00001597          	auipc	a1,0x1
     41e:	1a658593          	addi	a1,a1,422 # 15c0 <malloc+0x250>
     422:	00001517          	auipc	a0,0x1
     426:	1ae50513          	addi	a0,a0,430 # 15d0 <malloc+0x260>
     42a:	00000097          	auipc	ra,0x0
     42e:	df8080e7          	jalr	-520(ra) # 222 <one>
     432:	e105                	bnez	a0,452 <t1+0x56>
    printf("FAIL\n");
     434:	00001517          	auipc	a0,0x1
     438:	1b450513          	addi	a0,a0,436 # 15e8 <malloc+0x278>
     43c:	00001097          	auipc	ra,0x1
     440:	e76080e7          	jalr	-394(ra) # 12b2 <printf>
    *ok = 0;
     444:	0004a023          	sw	zero,0(s1)
  } else {
    printf("PASS\n");
  }
}
     448:	60e2                	ld	ra,24(sp)
     44a:	6442                	ld	s0,16(sp)
     44c:	64a2                	ld	s1,8(sp)
     44e:	6105                	addi	sp,sp,32
     450:	8082                	ret
    printf("PASS\n");
     452:	00001517          	auipc	a0,0x1
     456:	19e50513          	addi	a0,a0,414 # 15f0 <malloc+0x280>
     45a:	00001097          	auipc	ra,0x1
     45e:	e58080e7          	jalr	-424(ra) # 12b2 <printf>
}
     462:	b7dd                	j	448 <t1+0x4c>

0000000000000464 <t2>:

// test a command with arguments.
void
t2(int *ok)
{
     464:	1101                	addi	sp,sp,-32
     466:	ec06                	sd	ra,24(sp)
     468:	e822                	sd	s0,16(sp)
     46a:	e426                	sd	s1,8(sp)
     46c:	1000                	addi	s0,sp,32
     46e:	84aa                	mv	s1,a0
  printf("simple grep: ");
     470:	00001517          	auipc	a0,0x1
     474:	18850513          	addi	a0,a0,392 # 15f8 <malloc+0x288>
     478:	00001097          	auipc	ra,0x1
     47c:	e3a080e7          	jalr	-454(ra) # 12b2 <printf>
  if(one("grep constitute README\n", "The code in the files that constitute xv6 is", 1) == 0){
     480:	4605                	li	a2,1
     482:	00001597          	auipc	a1,0x1
     486:	18658593          	addi	a1,a1,390 # 1608 <malloc+0x298>
     48a:	00001517          	auipc	a0,0x1
     48e:	1ae50513          	addi	a0,a0,430 # 1638 <malloc+0x2c8>
     492:	00000097          	auipc	ra,0x0
     496:	d90080e7          	jalr	-624(ra) # 222 <one>
     49a:	e105                	bnez	a0,4ba <t2+0x56>
    printf("FAIL\n");
     49c:	00001517          	auipc	a0,0x1
     4a0:	14c50513          	addi	a0,a0,332 # 15e8 <malloc+0x278>
     4a4:	00001097          	auipc	ra,0x1
     4a8:	e0e080e7          	jalr	-498(ra) # 12b2 <printf>
    *ok = 0;
     4ac:	0004a023          	sw	zero,0(s1)
  } else {
    printf("PASS\n");
  }
}
     4b0:	60e2                	ld	ra,24(sp)
     4b2:	6442                	ld	s0,16(sp)
     4b4:	64a2                	ld	s1,8(sp)
     4b6:	6105                	addi	sp,sp,32
     4b8:	8082                	ret
    printf("PASS\n");
     4ba:	00001517          	auipc	a0,0x1
     4be:	13650513          	addi	a0,a0,310 # 15f0 <malloc+0x280>
     4c2:	00001097          	auipc	ra,0x1
     4c6:	df0080e7          	jalr	-528(ra) # 12b2 <printf>
}
     4ca:	b7dd                	j	4b0 <t2+0x4c>

00000000000004cc <t3>:

// test a command, then a newline, then another command.
void
t3(int *ok)
{
     4cc:	1101                	addi	sp,sp,-32
     4ce:	ec06                	sd	ra,24(sp)
     4d0:	e822                	sd	s0,16(sp)
     4d2:	e426                	sd	s1,8(sp)
     4d4:	1000                	addi	s0,sp,32
     4d6:	84aa                	mv	s1,a0
  printf("two commands: ");
     4d8:	00001517          	auipc	a0,0x1
     4dc:	17850513          	addi	a0,a0,376 # 1650 <malloc+0x2e0>
     4e0:	00001097          	auipc	ra,0x1
     4e4:	dd2080e7          	jalr	-558(ra) # 12b2 <printf>
  if(one("echo x\necho goodbye\n", "goodbye", 1) == 0){
     4e8:	4605                	li	a2,1
     4ea:	00001597          	auipc	a1,0x1
     4ee:	17658593          	addi	a1,a1,374 # 1660 <malloc+0x2f0>
     4f2:	00001517          	auipc	a0,0x1
     4f6:	17650513          	addi	a0,a0,374 # 1668 <malloc+0x2f8>
     4fa:	00000097          	auipc	ra,0x0
     4fe:	d28080e7          	jalr	-728(ra) # 222 <one>
     502:	e105                	bnez	a0,522 <t3+0x56>
    printf("FAIL\n");
     504:	00001517          	auipc	a0,0x1
     508:	0e450513          	addi	a0,a0,228 # 15e8 <malloc+0x278>
     50c:	00001097          	auipc	ra,0x1
     510:	da6080e7          	jalr	-602(ra) # 12b2 <printf>
    *ok = 0;
     514:	0004a023          	sw	zero,0(s1)
  } else {
    printf("PASS\n");
  }
}
     518:	60e2                	ld	ra,24(sp)
     51a:	6442                	ld	s0,16(sp)
     51c:	64a2                	ld	s1,8(sp)
     51e:	6105                	addi	sp,sp,32
     520:	8082                	ret
    printf("PASS\n");
     522:	00001517          	auipc	a0,0x1
     526:	0ce50513          	addi	a0,a0,206 # 15f0 <malloc+0x280>
     52a:	00001097          	auipc	ra,0x1
     52e:	d88080e7          	jalr	-632(ra) # 12b2 <printf>
}
     532:	b7dd                	j	518 <t3+0x4c>

0000000000000534 <t4>:

// test output redirection: echo xxx > file
void
t4(int *ok)
{
     534:	7131                	addi	sp,sp,-192
     536:	fd06                	sd	ra,184(sp)
     538:	f922                	sd	s0,176(sp)
     53a:	f526                	sd	s1,168(sp)
     53c:	0180                	addi	s0,sp,192
     53e:	84aa                	mv	s1,a0
  printf("output redirection: ");
     540:	00001517          	auipc	a0,0x1
     544:	14050513          	addi	a0,a0,320 # 1680 <malloc+0x310>
     548:	00001097          	auipc	ra,0x1
     54c:	d6a080e7          	jalr	-662(ra) # 12b2 <printf>

  char file[16];
  randstring(file, 12);
     550:	45b1                	li	a1,12
     552:	fd040513          	addi	a0,s0,-48
     556:	00000097          	auipc	ra,0x0
     55a:	ada080e7          	jalr	-1318(ra) # 30 <randstring>

  char data[16];
  randstring(data, 12);
     55e:	45b1                	li	a1,12
     560:	fc040513          	addi	a0,s0,-64
     564:	00000097          	auipc	ra,0x0
     568:	acc080e7          	jalr	-1332(ra) # 30 <randstring>

  char cmd[64];
  strcpy(cmd, "echo ");
     56c:	00001597          	auipc	a1,0x1
     570:	12c58593          	addi	a1,a1,300 # 1698 <malloc+0x328>
     574:	f8040513          	addi	a0,s0,-128
     578:	00000097          	auipc	ra,0x0
     57c:	73c080e7          	jalr	1852(ra) # cb4 <strcpy>
  strcpy(cmd+strlen(cmd), data);
     580:	f8040513          	addi	a0,s0,-128
     584:	00000097          	auipc	ra,0x0
     588:	778080e7          	jalr	1912(ra) # cfc <strlen>
     58c:	1502                	slli	a0,a0,0x20
     58e:	9101                	srli	a0,a0,0x20
     590:	fc040593          	addi	a1,s0,-64
     594:	f8040793          	addi	a5,s0,-128
     598:	953e                	add	a0,a0,a5
     59a:	00000097          	auipc	ra,0x0
     59e:	71a080e7          	jalr	1818(ra) # cb4 <strcpy>
  strcpy(cmd+strlen(cmd), " > ");
     5a2:	f8040513          	addi	a0,s0,-128
     5a6:	00000097          	auipc	ra,0x0
     5aa:	756080e7          	jalr	1878(ra) # cfc <strlen>
     5ae:	1502                	slli	a0,a0,0x20
     5b0:	9101                	srli	a0,a0,0x20
     5b2:	00001597          	auipc	a1,0x1
     5b6:	0ee58593          	addi	a1,a1,238 # 16a0 <malloc+0x330>
     5ba:	f8040793          	addi	a5,s0,-128
     5be:	953e                	add	a0,a0,a5
     5c0:	00000097          	auipc	ra,0x0
     5c4:	6f4080e7          	jalr	1780(ra) # cb4 <strcpy>
  strcpy(cmd+strlen(cmd), file);
     5c8:	f8040513          	addi	a0,s0,-128
     5cc:	00000097          	auipc	ra,0x0
     5d0:	730080e7          	jalr	1840(ra) # cfc <strlen>
     5d4:	1502                	slli	a0,a0,0x20
     5d6:	9101                	srli	a0,a0,0x20
     5d8:	fd040593          	addi	a1,s0,-48
     5dc:	f8040793          	addi	a5,s0,-128
     5e0:	953e                	add	a0,a0,a5
     5e2:	00000097          	auipc	ra,0x0
     5e6:	6d2080e7          	jalr	1746(ra) # cb4 <strcpy>
  strcpy(cmd+strlen(cmd), "\n");
     5ea:	f8040513          	addi	a0,s0,-128
     5ee:	00000097          	auipc	ra,0x0
     5f2:	70e080e7          	jalr	1806(ra) # cfc <strlen>
     5f6:	1502                	slli	a0,a0,0x20
     5f8:	9101                	srli	a0,a0,0x20
     5fa:	00001597          	auipc	a1,0x1
     5fe:	f7658593          	addi	a1,a1,-138 # 1570 <malloc+0x200>
     602:	f8040793          	addi	a5,s0,-128
     606:	953e                	add	a0,a0,a5
     608:	00000097          	auipc	ra,0x0
     60c:	6ac080e7          	jalr	1708(ra) # cb4 <strcpy>

  if(one(cmd, "", 1) == 0){
     610:	4605                	li	a2,1
     612:	00001597          	auipc	a1,0x1
     616:	efe58593          	addi	a1,a1,-258 # 1510 <malloc+0x1a0>
     61a:	f8040513          	addi	a0,s0,-128
     61e:	00000097          	auipc	ra,0x0
     622:	c04080e7          	jalr	-1020(ra) # 222 <one>
     626:	e515                	bnez	a0,652 <t4+0x11e>
    printf("FAIL\n");
     628:	00001517          	auipc	a0,0x1
     62c:	fc050513          	addi	a0,a0,-64 # 15e8 <malloc+0x278>
     630:	00001097          	auipc	ra,0x1
     634:	c82080e7          	jalr	-894(ra) # 12b2 <printf>
    *ok = 0;
     638:	0004a023          	sw	zero,0(s1)
    } else {
      printf("PASS\n");
    }
  }

  unlink(file);
     63c:	fd040513          	addi	a0,s0,-48
     640:	00001097          	auipc	ra,0x1
     644:	93a080e7          	jalr	-1734(ra) # f7a <unlink>
}
     648:	70ea                	ld	ra,184(sp)
     64a:	744a                	ld	s0,176(sp)
     64c:	74aa                	ld	s1,168(sp)
     64e:	6129                	addi	sp,sp,192
     650:	8082                	ret
    readfile(file, buf, sizeof(buf));
     652:	04000613          	li	a2,64
     656:	f4040593          	addi	a1,s0,-192
     65a:	fd040513          	addi	a0,s0,-48
     65e:	00000097          	auipc	ra,0x0
     662:	af0080e7          	jalr	-1296(ra) # 14e <readfile>
    if(strstr(buf, data) == 0){
     666:	fc040593          	addi	a1,s0,-64
     66a:	f4040513          	addi	a0,s0,-192
     66e:	00000097          	auipc	ra,0x0
     672:	b6a080e7          	jalr	-1174(ra) # 1d8 <strstr>
     676:	c911                	beqz	a0,68a <t4+0x156>
      printf("PASS\n");
     678:	00001517          	auipc	a0,0x1
     67c:	f7850513          	addi	a0,a0,-136 # 15f0 <malloc+0x280>
     680:	00001097          	auipc	ra,0x1
     684:	c32080e7          	jalr	-974(ra) # 12b2 <printf>
     688:	bf55                	j	63c <t4+0x108>
      printf("FAIL\n");
     68a:	00001517          	auipc	a0,0x1
     68e:	f5e50513          	addi	a0,a0,-162 # 15e8 <malloc+0x278>
     692:	00001097          	auipc	ra,0x1
     696:	c20080e7          	jalr	-992(ra) # 12b2 <printf>
      *ok = 0;
     69a:	0004a023          	sw	zero,0(s1)
     69e:	bf79                	j	63c <t4+0x108>

00000000000006a0 <t5>:

// test input redirection: cat < file
void
t5(int *ok)
{
     6a0:	7119                	addi	sp,sp,-128
     6a2:	fc86                	sd	ra,120(sp)
     6a4:	f8a2                	sd	s0,112(sp)
     6a6:	f4a6                	sd	s1,104(sp)
     6a8:	0100                	addi	s0,sp,128
     6aa:	84aa                	mv	s1,a0
  printf("input redirection: ");
     6ac:	00001517          	auipc	a0,0x1
     6b0:	ffc50513          	addi	a0,a0,-4 # 16a8 <malloc+0x338>
     6b4:	00001097          	auipc	ra,0x1
     6b8:	bfe080e7          	jalr	-1026(ra) # 12b2 <printf>

  char file[32];
  randstring(file, 12);
     6bc:	45b1                	li	a1,12
     6be:	fc040513          	addi	a0,s0,-64
     6c2:	00000097          	auipc	ra,0x0
     6c6:	96e080e7          	jalr	-1682(ra) # 30 <randstring>

  char data[32];
  randstring(data, 12);
     6ca:	45b1                	li	a1,12
     6cc:	fa040513          	addi	a0,s0,-96
     6d0:	00000097          	auipc	ra,0x0
     6d4:	960080e7          	jalr	-1696(ra) # 30 <randstring>
  writefile(file, data);
     6d8:	fa040593          	addi	a1,s0,-96
     6dc:	fc040513          	addi	a0,s0,-64
     6e0:	00000097          	auipc	ra,0x0
     6e4:	9c0080e7          	jalr	-1600(ra) # a0 <writefile>

  char cmd[32];
  strcpy(cmd, "cat < ");
     6e8:	00001597          	auipc	a1,0x1
     6ec:	fd858593          	addi	a1,a1,-40 # 16c0 <malloc+0x350>
     6f0:	f8040513          	addi	a0,s0,-128
     6f4:	00000097          	auipc	ra,0x0
     6f8:	5c0080e7          	jalr	1472(ra) # cb4 <strcpy>
  strcpy(cmd+strlen(cmd), file);
     6fc:	f8040513          	addi	a0,s0,-128
     700:	00000097          	auipc	ra,0x0
     704:	5fc080e7          	jalr	1532(ra) # cfc <strlen>
     708:	1502                	slli	a0,a0,0x20
     70a:	9101                	srli	a0,a0,0x20
     70c:	fc040593          	addi	a1,s0,-64
     710:	f8040793          	addi	a5,s0,-128
     714:	953e                	add	a0,a0,a5
     716:	00000097          	auipc	ra,0x0
     71a:	59e080e7          	jalr	1438(ra) # cb4 <strcpy>
  strcpy(cmd+strlen(cmd), "\n");
     71e:	f8040513          	addi	a0,s0,-128
     722:	00000097          	auipc	ra,0x0
     726:	5da080e7          	jalr	1498(ra) # cfc <strlen>
     72a:	1502                	slli	a0,a0,0x20
     72c:	9101                	srli	a0,a0,0x20
     72e:	00001597          	auipc	a1,0x1
     732:	e4258593          	addi	a1,a1,-446 # 1570 <malloc+0x200>
     736:	f8040793          	addi	a5,s0,-128
     73a:	953e                	add	a0,a0,a5
     73c:	00000097          	auipc	ra,0x0
     740:	578080e7          	jalr	1400(ra) # cb4 <strcpy>

  if(one(cmd, data, 1) == 0){
     744:	4605                	li	a2,1
     746:	fa040593          	addi	a1,s0,-96
     74a:	f8040513          	addi	a0,s0,-128
     74e:	00000097          	auipc	ra,0x0
     752:	ad4080e7          	jalr	-1324(ra) # 222 <one>
     756:	e515                	bnez	a0,782 <t5+0xe2>
    printf("FAIL\n");
     758:	00001517          	auipc	a0,0x1
     75c:	e9050513          	addi	a0,a0,-368 # 15e8 <malloc+0x278>
     760:	00001097          	auipc	ra,0x1
     764:	b52080e7          	jalr	-1198(ra) # 12b2 <printf>
    *ok = 0;
     768:	0004a023          	sw	zero,0(s1)
  } else {
    printf("PASS\n");
  }

  unlink(file);
     76c:	fc040513          	addi	a0,s0,-64
     770:	00001097          	auipc	ra,0x1
     774:	80a080e7          	jalr	-2038(ra) # f7a <unlink>
}
     778:	70e6                	ld	ra,120(sp)
     77a:	7446                	ld	s0,112(sp)
     77c:	74a6                	ld	s1,104(sp)
     77e:	6109                	addi	sp,sp,128
     780:	8082                	ret
    printf("PASS\n");
     782:	00001517          	auipc	a0,0x1
     786:	e6e50513          	addi	a0,a0,-402 # 15f0 <malloc+0x280>
     78a:	00001097          	auipc	ra,0x1
     78e:	b28080e7          	jalr	-1240(ra) # 12b2 <printf>
     792:	bfe9                	j	76c <t5+0xcc>

0000000000000794 <t6>:

// test a command with both input and output redirection.
void
t6(int *ok)
{
     794:	711d                	addi	sp,sp,-96
     796:	ec86                	sd	ra,88(sp)
     798:	e8a2                	sd	s0,80(sp)
     79a:	e4a6                	sd	s1,72(sp)
     79c:	1080                	addi	s0,sp,96
     79e:	84aa                	mv	s1,a0
  printf("both redirections: ");
     7a0:	00001517          	auipc	a0,0x1
     7a4:	f2850513          	addi	a0,a0,-216 # 16c8 <malloc+0x358>
     7a8:	00001097          	auipc	ra,0x1
     7ac:	b0a080e7          	jalr	-1270(ra) # 12b2 <printf>
  unlink("testsh.out");
     7b0:	00001517          	auipc	a0,0x1
     7b4:	f3050513          	addi	a0,a0,-208 # 16e0 <malloc+0x370>
     7b8:	00000097          	auipc	ra,0x0
     7bc:	7c2080e7          	jalr	1986(ra) # f7a <unlink>
  if(one("grep pointers < README > testsh.out\n", "", 1) == 0){
     7c0:	4605                	li	a2,1
     7c2:	00001597          	auipc	a1,0x1
     7c6:	d4e58593          	addi	a1,a1,-690 # 1510 <malloc+0x1a0>
     7ca:	00001517          	auipc	a0,0x1
     7ce:	f2650513          	addi	a0,a0,-218 # 16f0 <malloc+0x380>
     7d2:	00000097          	auipc	ra,0x0
     7d6:	a50080e7          	jalr	-1456(ra) # 222 <one>
     7da:	e905                	bnez	a0,80a <t6+0x76>
    printf("FAIL\n");
     7dc:	00001517          	auipc	a0,0x1
     7e0:	e0c50513          	addi	a0,a0,-500 # 15e8 <malloc+0x278>
     7e4:	00001097          	auipc	ra,0x1
     7e8:	ace080e7          	jalr	-1330(ra) # 12b2 <printf>
    *ok = 0;
     7ec:	0004a023          	sw	zero,0(s1)
      *ok = 0;
    } else {
      printf("PASS\n");
    }
  }
  unlink("testsh.out");
     7f0:	00001517          	auipc	a0,0x1
     7f4:	ef050513          	addi	a0,a0,-272 # 16e0 <malloc+0x370>
     7f8:	00000097          	auipc	ra,0x0
     7fc:	782080e7          	jalr	1922(ra) # f7a <unlink>
}
     800:	60e6                	ld	ra,88(sp)
     802:	6446                	ld	s0,80(sp)
     804:	64a6                	ld	s1,72(sp)
     806:	6125                	addi	sp,sp,96
     808:	8082                	ret
    readfile("testsh.out", buf, sizeof(buf));
     80a:	04000613          	li	a2,64
     80e:	fa040593          	addi	a1,s0,-96
     812:	00001517          	auipc	a0,0x1
     816:	ece50513          	addi	a0,a0,-306 # 16e0 <malloc+0x370>
     81a:	00000097          	auipc	ra,0x0
     81e:	934080e7          	jalr	-1740(ra) # 14e <readfile>
    if(strstr(buf, "provides pointers to on-line resources") == 0){
     822:	00001597          	auipc	a1,0x1
     826:	ef658593          	addi	a1,a1,-266 # 1718 <malloc+0x3a8>
     82a:	fa040513          	addi	a0,s0,-96
     82e:	00000097          	auipc	ra,0x0
     832:	9aa080e7          	jalr	-1622(ra) # 1d8 <strstr>
     836:	c911                	beqz	a0,84a <t6+0xb6>
      printf("PASS\n");
     838:	00001517          	auipc	a0,0x1
     83c:	db850513          	addi	a0,a0,-584 # 15f0 <malloc+0x280>
     840:	00001097          	auipc	ra,0x1
     844:	a72080e7          	jalr	-1422(ra) # 12b2 <printf>
     848:	b765                	j	7f0 <t6+0x5c>
      printf("FAIL\n");
     84a:	00001517          	auipc	a0,0x1
     84e:	d9e50513          	addi	a0,a0,-610 # 15e8 <malloc+0x278>
     852:	00001097          	auipc	ra,0x1
     856:	a60080e7          	jalr	-1440(ra) # 12b2 <printf>
      *ok = 0;
     85a:	0004a023          	sw	zero,0(s1)
     85e:	bf49                	j	7f0 <t6+0x5c>

0000000000000860 <t7>:

// test a pipe with cat filename | cat.
void
t7(int *ok)
{
     860:	7135                	addi	sp,sp,-160
     862:	ed06                	sd	ra,152(sp)
     864:	e922                	sd	s0,144(sp)
     866:	e526                	sd	s1,136(sp)
     868:	1100                	addi	s0,sp,160
     86a:	84aa                	mv	s1,a0
  printf("simple pipe: ");
     86c:	00001517          	auipc	a0,0x1
     870:	ed450513          	addi	a0,a0,-300 # 1740 <malloc+0x3d0>
     874:	00001097          	auipc	ra,0x1
     878:	a3e080e7          	jalr	-1474(ra) # 12b2 <printf>

  char name[32], data[32];
  randstring(name, 12);
     87c:	45b1                	li	a1,12
     87e:	fc040513          	addi	a0,s0,-64
     882:	fffff097          	auipc	ra,0xfffff
     886:	7ae080e7          	jalr	1966(ra) # 30 <randstring>
  randstring(data, 12);
     88a:	45b1                	li	a1,12
     88c:	fa040513          	addi	a0,s0,-96
     890:	fffff097          	auipc	ra,0xfffff
     894:	7a0080e7          	jalr	1952(ra) # 30 <randstring>
  writefile(name, data);
     898:	fa040593          	addi	a1,s0,-96
     89c:	fc040513          	addi	a0,s0,-64
     8a0:	00000097          	auipc	ra,0x0
     8a4:	800080e7          	jalr	-2048(ra) # a0 <writefile>

  char cmd[64];
  strcpy(cmd, "cat ");
     8a8:	00001597          	auipc	a1,0x1
     8ac:	ea858593          	addi	a1,a1,-344 # 1750 <malloc+0x3e0>
     8b0:	f6040513          	addi	a0,s0,-160
     8b4:	00000097          	auipc	ra,0x0
     8b8:	400080e7          	jalr	1024(ra) # cb4 <strcpy>
  strcpy(cmd + strlen(cmd), name);
     8bc:	f6040513          	addi	a0,s0,-160
     8c0:	00000097          	auipc	ra,0x0
     8c4:	43c080e7          	jalr	1084(ra) # cfc <strlen>
     8c8:	1502                	slli	a0,a0,0x20
     8ca:	9101                	srli	a0,a0,0x20
     8cc:	fc040593          	addi	a1,s0,-64
     8d0:	f6040793          	addi	a5,s0,-160
     8d4:	953e                	add	a0,a0,a5
     8d6:	00000097          	auipc	ra,0x0
     8da:	3de080e7          	jalr	990(ra) # cb4 <strcpy>
  strcpy(cmd + strlen(cmd), " | cat\n");
     8de:	f6040513          	addi	a0,s0,-160
     8e2:	00000097          	auipc	ra,0x0
     8e6:	41a080e7          	jalr	1050(ra) # cfc <strlen>
     8ea:	1502                	slli	a0,a0,0x20
     8ec:	9101                	srli	a0,a0,0x20
     8ee:	00001597          	auipc	a1,0x1
     8f2:	e6a58593          	addi	a1,a1,-406 # 1758 <malloc+0x3e8>
     8f6:	f6040793          	addi	a5,s0,-160
     8fa:	953e                	add	a0,a0,a5
     8fc:	00000097          	auipc	ra,0x0
     900:	3b8080e7          	jalr	952(ra) # cb4 <strcpy>
  
  if(one(cmd, data, 1) == 0){
     904:	4605                	li	a2,1
     906:	fa040593          	addi	a1,s0,-96
     90a:	f6040513          	addi	a0,s0,-160
     90e:	00000097          	auipc	ra,0x0
     912:	914080e7          	jalr	-1772(ra) # 222 <one>
     916:	e515                	bnez	a0,942 <t7+0xe2>
    printf("FAIL\n");
     918:	00001517          	auipc	a0,0x1
     91c:	cd050513          	addi	a0,a0,-816 # 15e8 <malloc+0x278>
     920:	00001097          	auipc	ra,0x1
     924:	992080e7          	jalr	-1646(ra) # 12b2 <printf>
    *ok = 0;
     928:	0004a023          	sw	zero,0(s1)
  } else {
    printf("PASS\n");
  }

  unlink(name);
     92c:	fc040513          	addi	a0,s0,-64
     930:	00000097          	auipc	ra,0x0
     934:	64a080e7          	jalr	1610(ra) # f7a <unlink>
}
     938:	60ea                	ld	ra,152(sp)
     93a:	644a                	ld	s0,144(sp)
     93c:	64aa                	ld	s1,136(sp)
     93e:	610d                	addi	sp,sp,160
     940:	8082                	ret
    printf("PASS\n");
     942:	00001517          	auipc	a0,0x1
     946:	cae50513          	addi	a0,a0,-850 # 15f0 <malloc+0x280>
     94a:	00001097          	auipc	ra,0x1
     94e:	968080e7          	jalr	-1688(ra) # 12b2 <printf>
     952:	bfe9                	j	92c <t7+0xcc>

0000000000000954 <t8>:

// test a pipeline that has both redirection and a pipe.
void
t8(int *ok)
{
     954:	711d                	addi	sp,sp,-96
     956:	ec86                	sd	ra,88(sp)
     958:	e8a2                	sd	s0,80(sp)
     95a:	e4a6                	sd	s1,72(sp)
     95c:	1080                	addi	s0,sp,96
     95e:	84aa                	mv	s1,a0
  printf("pipe and redirects: ");
     960:	00001517          	auipc	a0,0x1
     964:	e0050513          	addi	a0,a0,-512 # 1760 <malloc+0x3f0>
     968:	00001097          	auipc	ra,0x1
     96c:	94a080e7          	jalr	-1718(ra) # 12b2 <printf>
  
  if(one("grep suggestions < README | wc > testsh.out\n", "", 1) == 0){
     970:	4605                	li	a2,1
     972:	00001597          	auipc	a1,0x1
     976:	b9e58593          	addi	a1,a1,-1122 # 1510 <malloc+0x1a0>
     97a:	00001517          	auipc	a0,0x1
     97e:	dfe50513          	addi	a0,a0,-514 # 1778 <malloc+0x408>
     982:	00000097          	auipc	ra,0x0
     986:	8a0080e7          	jalr	-1888(ra) # 222 <one>
     98a:	e905                	bnez	a0,9ba <t8+0x66>
    printf("FAIL\n");
     98c:	00001517          	auipc	a0,0x1
     990:	c5c50513          	addi	a0,a0,-932 # 15e8 <malloc+0x278>
     994:	00001097          	auipc	ra,0x1
     998:	91e080e7          	jalr	-1762(ra) # 12b2 <printf>
    *ok = 0;
     99c:	0004a023          	sw	zero,0(s1)
    } else {
      printf("PASS\n");
    }
  }

  unlink("testsh.out");
     9a0:	00001517          	auipc	a0,0x1
     9a4:	d4050513          	addi	a0,a0,-704 # 16e0 <malloc+0x370>
     9a8:	00000097          	auipc	ra,0x0
     9ac:	5d2080e7          	jalr	1490(ra) # f7a <unlink>
}
     9b0:	60e6                	ld	ra,88(sp)
     9b2:	6446                	ld	s0,80(sp)
     9b4:	64a6                	ld	s1,72(sp)
     9b6:	6125                	addi	sp,sp,96
     9b8:	8082                	ret
    readfile("testsh.out", buf, sizeof(buf));
     9ba:	04000613          	li	a2,64
     9be:	fa040593          	addi	a1,s0,-96
     9c2:	00001517          	auipc	a0,0x1
     9c6:	d1e50513          	addi	a0,a0,-738 # 16e0 <malloc+0x370>
     9ca:	fffff097          	auipc	ra,0xfffff
     9ce:	784080e7          	jalr	1924(ra) # 14e <readfile>
    if(strstr(buf, "1 11 71") == 0){
     9d2:	00001597          	auipc	a1,0x1
     9d6:	dd658593          	addi	a1,a1,-554 # 17a8 <malloc+0x438>
     9da:	fa040513          	addi	a0,s0,-96
     9de:	fffff097          	auipc	ra,0xfffff
     9e2:	7fa080e7          	jalr	2042(ra) # 1d8 <strstr>
     9e6:	c911                	beqz	a0,9fa <t8+0xa6>
      printf("PASS\n");
     9e8:	00001517          	auipc	a0,0x1
     9ec:	c0850513          	addi	a0,a0,-1016 # 15f0 <malloc+0x280>
     9f0:	00001097          	auipc	ra,0x1
     9f4:	8c2080e7          	jalr	-1854(ra) # 12b2 <printf>
     9f8:	b765                	j	9a0 <t8+0x4c>
      printf("FAIL\n");
     9fa:	00001517          	auipc	a0,0x1
     9fe:	bee50513          	addi	a0,a0,-1042 # 15e8 <malloc+0x278>
     a02:	00001097          	auipc	ra,0x1
     a06:	8b0080e7          	jalr	-1872(ra) # 12b2 <printf>
      *ok = 0;
     a0a:	0004a023          	sw	zero,0(s1)
     a0e:	bf49                	j	9a0 <t8+0x4c>

0000000000000a10 <t9>:

// ask the shell to execute many commands, to check
// if it leaks file descriptors.
void
t9(int *ok)
{
     a10:	7159                	addi	sp,sp,-112
     a12:	f486                	sd	ra,104(sp)
     a14:	f0a2                	sd	s0,96(sp)
     a16:	eca6                	sd	s1,88(sp)
     a18:	e8ca                	sd	s2,80(sp)
     a1a:	e4ce                	sd	s3,72(sp)
     a1c:	e0d2                	sd	s4,64(sp)
     a1e:	fc56                	sd	s5,56(sp)
     a20:	f85a                	sd	s6,48(sp)
     a22:	f45e                	sd	s7,40(sp)
     a24:	1880                	addi	s0,sp,112
     a26:	8baa                	mv	s7,a0
  printf("lots of commands: ");
     a28:	00001517          	auipc	a0,0x1
     a2c:	d8850513          	addi	a0,a0,-632 # 17b0 <malloc+0x440>
     a30:	00001097          	auipc	ra,0x1
     a34:	882080e7          	jalr	-1918(ra) # 12b2 <printf>

  char term[32];
  randstring(term, 12);
     a38:	45b1                	li	a1,12
     a3a:	f9040513          	addi	a0,s0,-112
     a3e:	fffff097          	auipc	ra,0xfffff
     a42:	5f2080e7          	jalr	1522(ra) # 30 <randstring>
  
  char *cmd = malloc(25 * 36 + 100);
     a46:	3e800513          	li	a0,1000
     a4a:	00001097          	auipc	ra,0x1
     a4e:	926080e7          	jalr	-1754(ra) # 1370 <malloc>
  if(cmd == 0){
     a52:	14050363          	beqz	a0,b98 <t9+0x188>
     a56:	84aa                	mv	s1,a0
    fprintf(2, "testsh: malloc failed\n");
    exit(-1);
  }

  cmd[0] = '\0';
     a58:	00050023          	sb	zero,0(a0)
  for(int i = 0; i < 17+(rand()%6); i++){
     a5c:	fffff097          	auipc	ra,0xfffff
     a60:	5a4080e7          	jalr	1444(ra) # 0 <rand>
     a64:	4981                	li	s3,0
    strcpy(cmd + strlen(cmd), "echo x < README > tso\n");
     a66:	00001b17          	auipc	s6,0x1
     a6a:	d7ab0b13          	addi	s6,s6,-646 # 17e0 <malloc+0x470>
    strcpy(cmd + strlen(cmd), "echo x | echo\n");
     a6e:	00001a97          	auipc	s5,0x1
     a72:	d8aa8a93          	addi	s5,s5,-630 # 17f8 <malloc+0x488>
  for(int i = 0; i < 17+(rand()%6); i++){
     a76:	4a19                	li	s4,6
    strcpy(cmd + strlen(cmd), "echo x < README > tso\n");
     a78:	8526                	mv	a0,s1
     a7a:	00000097          	auipc	ra,0x0
     a7e:	282080e7          	jalr	642(ra) # cfc <strlen>
     a82:	1502                	slli	a0,a0,0x20
     a84:	9101                	srli	a0,a0,0x20
     a86:	85da                	mv	a1,s6
     a88:	9526                	add	a0,a0,s1
     a8a:	00000097          	auipc	ra,0x0
     a8e:	22a080e7          	jalr	554(ra) # cb4 <strcpy>
    strcpy(cmd + strlen(cmd), "echo x | echo\n");
     a92:	8526                	mv	a0,s1
     a94:	00000097          	auipc	ra,0x0
     a98:	268080e7          	jalr	616(ra) # cfc <strlen>
     a9c:	1502                	slli	a0,a0,0x20
     a9e:	9101                	srli	a0,a0,0x20
     aa0:	85d6                	mv	a1,s5
     aa2:	9526                	add	a0,a0,s1
     aa4:	00000097          	auipc	ra,0x0
     aa8:	210080e7          	jalr	528(ra) # cb4 <strcpy>
  for(int i = 0; i < 17+(rand()%6); i++){
     aac:	0019891b          	addiw	s2,s3,1
     ab0:	0009099b          	sext.w	s3,s2
     ab4:	fffff097          	auipc	ra,0xfffff
     ab8:	54c080e7          	jalr	1356(ra) # 0 <rand>
     abc:	034577bb          	remuw	a5,a0,s4
     ac0:	07c5                	addi	a5,a5,17
     ac2:	faf9ebe3          	bltu	s3,a5,a78 <t9+0x68>
  }
  strcpy(cmd + strlen(cmd), "echo ");
     ac6:	8526                	mv	a0,s1
     ac8:	00000097          	auipc	ra,0x0
     acc:	234080e7          	jalr	564(ra) # cfc <strlen>
     ad0:	1502                	slli	a0,a0,0x20
     ad2:	9101                	srli	a0,a0,0x20
     ad4:	00001597          	auipc	a1,0x1
     ad8:	bc458593          	addi	a1,a1,-1084 # 1698 <malloc+0x328>
     adc:	9526                	add	a0,a0,s1
     ade:	00000097          	auipc	ra,0x0
     ae2:	1d6080e7          	jalr	470(ra) # cb4 <strcpy>
  strcpy(cmd + strlen(cmd), term);
     ae6:	8526                	mv	a0,s1
     ae8:	00000097          	auipc	ra,0x0
     aec:	214080e7          	jalr	532(ra) # cfc <strlen>
     af0:	1502                	slli	a0,a0,0x20
     af2:	9101                	srli	a0,a0,0x20
     af4:	f9040593          	addi	a1,s0,-112
     af8:	9526                	add	a0,a0,s1
     afa:	00000097          	auipc	ra,0x0
     afe:	1ba080e7          	jalr	442(ra) # cb4 <strcpy>
  strcpy(cmd + strlen(cmd), " > tso\n");
     b02:	8526                	mv	a0,s1
     b04:	00000097          	auipc	ra,0x0
     b08:	1f8080e7          	jalr	504(ra) # cfc <strlen>
     b0c:	1502                	slli	a0,a0,0x20
     b0e:	9101                	srli	a0,a0,0x20
     b10:	00001597          	auipc	a1,0x1
     b14:	cf858593          	addi	a1,a1,-776 # 1808 <malloc+0x498>
     b18:	9526                	add	a0,a0,s1
     b1a:	00000097          	auipc	ra,0x0
     b1e:	19a080e7          	jalr	410(ra) # cb4 <strcpy>
  strcpy(cmd + strlen(cmd), "cat < tso\n");
     b22:	8526                	mv	a0,s1
     b24:	00000097          	auipc	ra,0x0
     b28:	1d8080e7          	jalr	472(ra) # cfc <strlen>
     b2c:	1502                	slli	a0,a0,0x20
     b2e:	9101                	srli	a0,a0,0x20
     b30:	00001597          	auipc	a1,0x1
     b34:	ce058593          	addi	a1,a1,-800 # 1810 <malloc+0x4a0>
     b38:	9526                	add	a0,a0,s1
     b3a:	00000097          	auipc	ra,0x0
     b3e:	17a080e7          	jalr	378(ra) # cb4 <strcpy>

  if(one(cmd, term, 0) == 0){
     b42:	4601                	li	a2,0
     b44:	f9040593          	addi	a1,s0,-112
     b48:	8526                	mv	a0,s1
     b4a:	fffff097          	auipc	ra,0xfffff
     b4e:	6d8080e7          	jalr	1752(ra) # 222 <one>
     b52:	e12d                	bnez	a0,bb4 <t9+0x1a4>
    printf("FAIL\n");
     b54:	00001517          	auipc	a0,0x1
     b58:	a9450513          	addi	a0,a0,-1388 # 15e8 <malloc+0x278>
     b5c:	00000097          	auipc	ra,0x0
     b60:	756080e7          	jalr	1878(ra) # 12b2 <printf>
    *ok = 0;
     b64:	000ba023          	sw	zero,0(s7)
  } else {
    printf("PASS\n");
  }

  unlink("tso");
     b68:	00001517          	auipc	a0,0x1
     b6c:	cb850513          	addi	a0,a0,-840 # 1820 <malloc+0x4b0>
     b70:	00000097          	auipc	ra,0x0
     b74:	40a080e7          	jalr	1034(ra) # f7a <unlink>
  free(cmd);
     b78:	8526                	mv	a0,s1
     b7a:	00000097          	auipc	ra,0x0
     b7e:	76e080e7          	jalr	1902(ra) # 12e8 <free>
}
     b82:	70a6                	ld	ra,104(sp)
     b84:	7406                	ld	s0,96(sp)
     b86:	64e6                	ld	s1,88(sp)
     b88:	6946                	ld	s2,80(sp)
     b8a:	69a6                	ld	s3,72(sp)
     b8c:	6a06                	ld	s4,64(sp)
     b8e:	7ae2                	ld	s5,56(sp)
     b90:	7b42                	ld	s6,48(sp)
     b92:	7ba2                	ld	s7,40(sp)
     b94:	6165                	addi	sp,sp,112
     b96:	8082                	ret
    fprintf(2, "testsh: malloc failed\n");
     b98:	00001597          	auipc	a1,0x1
     b9c:	c3058593          	addi	a1,a1,-976 # 17c8 <malloc+0x458>
     ba0:	4509                	li	a0,2
     ba2:	00000097          	auipc	ra,0x0
     ba6:	6e2080e7          	jalr	1762(ra) # 1284 <fprintf>
    exit(-1);
     baa:	557d                	li	a0,-1
     bac:	00000097          	auipc	ra,0x0
     bb0:	37e080e7          	jalr	894(ra) # f2a <exit>
    printf("PASS\n");
     bb4:	00001517          	auipc	a0,0x1
     bb8:	a3c50513          	addi	a0,a0,-1476 # 15f0 <malloc+0x280>
     bbc:	00000097          	auipc	ra,0x0
     bc0:	6f6080e7          	jalr	1782(ra) # 12b2 <printf>
     bc4:	b755                	j	b68 <t9+0x158>

0000000000000bc6 <main>:

int
main(int argc, char *argv[])
{
     bc6:	1101                	addi	sp,sp,-32
     bc8:	ec06                	sd	ra,24(sp)
     bca:	e822                	sd	s0,16(sp)
     bcc:	1000                	addi	s0,sp,32
  if(argc != 2){
     bce:	4789                	li	a5,2
     bd0:	02f50063          	beq	a0,a5,bf0 <main+0x2a>
    fprintf(2, "Usage: testsh nsh\n");
     bd4:	00001597          	auipc	a1,0x1
     bd8:	c5458593          	addi	a1,a1,-940 # 1828 <malloc+0x4b8>
     bdc:	4509                	li	a0,2
     bde:	00000097          	auipc	ra,0x0
     be2:	6a6080e7          	jalr	1702(ra) # 1284 <fprintf>
    exit(-1);
     be6:	557d                	li	a0,-1
     be8:	00000097          	auipc	ra,0x0
     bec:	342080e7          	jalr	834(ra) # f2a <exit>
  }
  shname = argv[1];
     bf0:	659c                	ld	a5,8(a1)
     bf2:	00001717          	auipc	a4,0x1
     bf6:	c8f73f23          	sd	a5,-866(a4) # 1890 <_edata>
  
  seed += getpid();
     bfa:	00000097          	auipc	ra,0x0
     bfe:	3b0080e7          	jalr	944(ra) # faa <getpid>
     c02:	00001717          	auipc	a4,0x1
     c06:	c8a70713          	addi	a4,a4,-886 # 188c <seed>
     c0a:	431c                	lw	a5,0(a4)
     c0c:	9fa9                	addw	a5,a5,a0
     c0e:	c31c                	sw	a5,0(a4)

  int ok = 1;
     c10:	4785                	li	a5,1
     c12:	fef42623          	sw	a5,-20(s0)

  t1(&ok);
     c16:	fec40513          	addi	a0,s0,-20
     c1a:	fffff097          	auipc	ra,0xfffff
     c1e:	7e2080e7          	jalr	2018(ra) # 3fc <t1>
  t2(&ok);
     c22:	fec40513          	addi	a0,s0,-20
     c26:	00000097          	auipc	ra,0x0
     c2a:	83e080e7          	jalr	-1986(ra) # 464 <t2>
  t3(&ok);
     c2e:	fec40513          	addi	a0,s0,-20
     c32:	00000097          	auipc	ra,0x0
     c36:	89a080e7          	jalr	-1894(ra) # 4cc <t3>
  t4(&ok);
     c3a:	fec40513          	addi	a0,s0,-20
     c3e:	00000097          	auipc	ra,0x0
     c42:	8f6080e7          	jalr	-1802(ra) # 534 <t4>
  t5(&ok);
     c46:	fec40513          	addi	a0,s0,-20
     c4a:	00000097          	auipc	ra,0x0
     c4e:	a56080e7          	jalr	-1450(ra) # 6a0 <t5>
  t6(&ok);
     c52:	fec40513          	addi	a0,s0,-20
     c56:	00000097          	auipc	ra,0x0
     c5a:	b3e080e7          	jalr	-1218(ra) # 794 <t6>
  t7(&ok);
     c5e:	fec40513          	addi	a0,s0,-20
     c62:	00000097          	auipc	ra,0x0
     c66:	bfe080e7          	jalr	-1026(ra) # 860 <t7>
  t8(&ok);
     c6a:	fec40513          	addi	a0,s0,-20
     c6e:	00000097          	auipc	ra,0x0
     c72:	ce6080e7          	jalr	-794(ra) # 954 <t8>
  t9(&ok);
     c76:	fec40513          	addi	a0,s0,-20
     c7a:	00000097          	auipc	ra,0x0
     c7e:	d96080e7          	jalr	-618(ra) # a10 <t9>

  if(ok){
     c82:	fec42783          	lw	a5,-20(s0)
     c86:	cf91                	beqz	a5,ca2 <main+0xdc>
    printf("passed all tests\n");
     c88:	00001517          	auipc	a0,0x1
     c8c:	bb850513          	addi	a0,a0,-1096 # 1840 <malloc+0x4d0>
     c90:	00000097          	auipc	ra,0x0
     c94:	622080e7          	jalr	1570(ra) # 12b2 <printf>
  } else {
    printf("failed some tests\n");
  }
  
  exit(0);
     c98:	4501                	li	a0,0
     c9a:	00000097          	auipc	ra,0x0
     c9e:	290080e7          	jalr	656(ra) # f2a <exit>
    printf("failed some tests\n");
     ca2:	00001517          	auipc	a0,0x1
     ca6:	bb650513          	addi	a0,a0,-1098 # 1858 <malloc+0x4e8>
     caa:	00000097          	auipc	ra,0x0
     cae:	608080e7          	jalr	1544(ra) # 12b2 <printf>
     cb2:	b7dd                	j	c98 <main+0xd2>

0000000000000cb4 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     cb4:	1141                	addi	sp,sp,-16
     cb6:	e422                	sd	s0,8(sp)
     cb8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     cba:	87aa                	mv	a5,a0
     cbc:	0585                	addi	a1,a1,1
     cbe:	0785                	addi	a5,a5,1
     cc0:	fff5c703          	lbu	a4,-1(a1)
     cc4:	fee78fa3          	sb	a4,-1(a5)
     cc8:	fb75                	bnez	a4,cbc <strcpy+0x8>
    ;
  return os;
}
     cca:	6422                	ld	s0,8(sp)
     ccc:	0141                	addi	sp,sp,16
     cce:	8082                	ret

0000000000000cd0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     cd0:	1141                	addi	sp,sp,-16
     cd2:	e422                	sd	s0,8(sp)
     cd4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     cd6:	00054783          	lbu	a5,0(a0)
     cda:	cb91                	beqz	a5,cee <strcmp+0x1e>
     cdc:	0005c703          	lbu	a4,0(a1)
     ce0:	00f71763          	bne	a4,a5,cee <strcmp+0x1e>
    p++, q++;
     ce4:	0505                	addi	a0,a0,1
     ce6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     ce8:	00054783          	lbu	a5,0(a0)
     cec:	fbe5                	bnez	a5,cdc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     cee:	0005c503          	lbu	a0,0(a1)
}
     cf2:	40a7853b          	subw	a0,a5,a0
     cf6:	6422                	ld	s0,8(sp)
     cf8:	0141                	addi	sp,sp,16
     cfa:	8082                	ret

0000000000000cfc <strlen>:

uint
strlen(const char *s)
{
     cfc:	1141                	addi	sp,sp,-16
     cfe:	e422                	sd	s0,8(sp)
     d00:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     d02:	00054783          	lbu	a5,0(a0)
     d06:	cf91                	beqz	a5,d22 <strlen+0x26>
     d08:	0505                	addi	a0,a0,1
     d0a:	87aa                	mv	a5,a0
     d0c:	4685                	li	a3,1
     d0e:	9e89                	subw	a3,a3,a0
     d10:	00f6853b          	addw	a0,a3,a5
     d14:	0785                	addi	a5,a5,1
     d16:	fff7c703          	lbu	a4,-1(a5)
     d1a:	fb7d                	bnez	a4,d10 <strlen+0x14>
    ;
  return n;
}
     d1c:	6422                	ld	s0,8(sp)
     d1e:	0141                	addi	sp,sp,16
     d20:	8082                	ret
  for(n = 0; s[n]; n++)
     d22:	4501                	li	a0,0
     d24:	bfe5                	j	d1c <strlen+0x20>

0000000000000d26 <memset>:

void*
memset(void *dst, int c, uint n)
{
     d26:	1141                	addi	sp,sp,-16
     d28:	e422                	sd	s0,8(sp)
     d2a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     d2c:	ce09                	beqz	a2,d46 <memset+0x20>
     d2e:	87aa                	mv	a5,a0
     d30:	fff6071b          	addiw	a4,a2,-1
     d34:	1702                	slli	a4,a4,0x20
     d36:	9301                	srli	a4,a4,0x20
     d38:	0705                	addi	a4,a4,1
     d3a:	972a                	add	a4,a4,a0
    cdst[i] = c;
     d3c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     d40:	0785                	addi	a5,a5,1
     d42:	fee79de3          	bne	a5,a4,d3c <memset+0x16>
  }
  return dst;
}
     d46:	6422                	ld	s0,8(sp)
     d48:	0141                	addi	sp,sp,16
     d4a:	8082                	ret

0000000000000d4c <strchr>:

char*
strchr(const char *s, char c)
{
     d4c:	1141                	addi	sp,sp,-16
     d4e:	e422                	sd	s0,8(sp)
     d50:	0800                	addi	s0,sp,16
  for(; *s; s++)
     d52:	00054783          	lbu	a5,0(a0)
     d56:	cb99                	beqz	a5,d6c <strchr+0x20>
    if(*s == c)
     d58:	00f58763          	beq	a1,a5,d66 <strchr+0x1a>
  for(; *s; s++)
     d5c:	0505                	addi	a0,a0,1
     d5e:	00054783          	lbu	a5,0(a0)
     d62:	fbfd                	bnez	a5,d58 <strchr+0xc>
      return (char*)s;
  return 0;
     d64:	4501                	li	a0,0
}
     d66:	6422                	ld	s0,8(sp)
     d68:	0141                	addi	sp,sp,16
     d6a:	8082                	ret
  return 0;
     d6c:	4501                	li	a0,0
     d6e:	bfe5                	j	d66 <strchr+0x1a>

0000000000000d70 <gets>:

char*
gets(char *buf, int max)
{
     d70:	711d                	addi	sp,sp,-96
     d72:	ec86                	sd	ra,88(sp)
     d74:	e8a2                	sd	s0,80(sp)
     d76:	e4a6                	sd	s1,72(sp)
     d78:	e0ca                	sd	s2,64(sp)
     d7a:	fc4e                	sd	s3,56(sp)
     d7c:	f852                	sd	s4,48(sp)
     d7e:	f456                	sd	s5,40(sp)
     d80:	f05a                	sd	s6,32(sp)
     d82:	ec5e                	sd	s7,24(sp)
     d84:	1080                	addi	s0,sp,96
     d86:	8baa                	mv	s7,a0
     d88:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     d8a:	892a                	mv	s2,a0
     d8c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     d8e:	4aa9                	li	s5,10
     d90:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     d92:	89a6                	mv	s3,s1
     d94:	2485                	addiw	s1,s1,1
     d96:	0344d863          	bge	s1,s4,dc6 <gets+0x56>
    cc = read(0, &c, 1);
     d9a:	4605                	li	a2,1
     d9c:	faf40593          	addi	a1,s0,-81
     da0:	4501                	li	a0,0
     da2:	00000097          	auipc	ra,0x0
     da6:	1a0080e7          	jalr	416(ra) # f42 <read>
    if(cc < 1)
     daa:	00a05e63          	blez	a0,dc6 <gets+0x56>
    buf[i++] = c;
     dae:	faf44783          	lbu	a5,-81(s0)
     db2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     db6:	01578763          	beq	a5,s5,dc4 <gets+0x54>
     dba:	0905                	addi	s2,s2,1
     dbc:	fd679be3          	bne	a5,s6,d92 <gets+0x22>
  for(i=0; i+1 < max; ){
     dc0:	89a6                	mv	s3,s1
     dc2:	a011                	j	dc6 <gets+0x56>
     dc4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     dc6:	99de                	add	s3,s3,s7
     dc8:	00098023          	sb	zero,0(s3)
  return buf;
}
     dcc:	855e                	mv	a0,s7
     dce:	60e6                	ld	ra,88(sp)
     dd0:	6446                	ld	s0,80(sp)
     dd2:	64a6                	ld	s1,72(sp)
     dd4:	6906                	ld	s2,64(sp)
     dd6:	79e2                	ld	s3,56(sp)
     dd8:	7a42                	ld	s4,48(sp)
     dda:	7aa2                	ld	s5,40(sp)
     ddc:	7b02                	ld	s6,32(sp)
     dde:	6be2                	ld	s7,24(sp)
     de0:	6125                	addi	sp,sp,96
     de2:	8082                	ret

0000000000000de4 <stat>:

int
stat(const char *n, struct stat *st)
{
     de4:	1101                	addi	sp,sp,-32
     de6:	ec06                	sd	ra,24(sp)
     de8:	e822                	sd	s0,16(sp)
     dea:	e426                	sd	s1,8(sp)
     dec:	e04a                	sd	s2,0(sp)
     dee:	1000                	addi	s0,sp,32
     df0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     df2:	4581                	li	a1,0
     df4:	00000097          	auipc	ra,0x0
     df8:	176080e7          	jalr	374(ra) # f6a <open>
  if(fd < 0)
     dfc:	02054563          	bltz	a0,e26 <stat+0x42>
     e00:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     e02:	85ca                	mv	a1,s2
     e04:	00000097          	auipc	ra,0x0
     e08:	17e080e7          	jalr	382(ra) # f82 <fstat>
     e0c:	892a                	mv	s2,a0
  close(fd);
     e0e:	8526                	mv	a0,s1
     e10:	00000097          	auipc	ra,0x0
     e14:	142080e7          	jalr	322(ra) # f52 <close>
  return r;
}
     e18:	854a                	mv	a0,s2
     e1a:	60e2                	ld	ra,24(sp)
     e1c:	6442                	ld	s0,16(sp)
     e1e:	64a2                	ld	s1,8(sp)
     e20:	6902                	ld	s2,0(sp)
     e22:	6105                	addi	sp,sp,32
     e24:	8082                	ret
    return -1;
     e26:	597d                	li	s2,-1
     e28:	bfc5                	j	e18 <stat+0x34>

0000000000000e2a <atoi>:

int
atoi(const char *s)
{
     e2a:	1141                	addi	sp,sp,-16
     e2c:	e422                	sd	s0,8(sp)
     e2e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     e30:	00054603          	lbu	a2,0(a0)
     e34:	fd06079b          	addiw	a5,a2,-48
     e38:	0ff7f793          	andi	a5,a5,255
     e3c:	4725                	li	a4,9
     e3e:	02f76963          	bltu	a4,a5,e70 <atoi+0x46>
     e42:	86aa                	mv	a3,a0
  n = 0;
     e44:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     e46:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     e48:	0685                	addi	a3,a3,1
     e4a:	0025179b          	slliw	a5,a0,0x2
     e4e:	9fa9                	addw	a5,a5,a0
     e50:	0017979b          	slliw	a5,a5,0x1
     e54:	9fb1                	addw	a5,a5,a2
     e56:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     e5a:	0006c603          	lbu	a2,0(a3)
     e5e:	fd06071b          	addiw	a4,a2,-48
     e62:	0ff77713          	andi	a4,a4,255
     e66:	fee5f1e3          	bgeu	a1,a4,e48 <atoi+0x1e>
  return n;
}
     e6a:	6422                	ld	s0,8(sp)
     e6c:	0141                	addi	sp,sp,16
     e6e:	8082                	ret
  n = 0;
     e70:	4501                	li	a0,0
     e72:	bfe5                	j	e6a <atoi+0x40>

0000000000000e74 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     e74:	1141                	addi	sp,sp,-16
     e76:	e422                	sd	s0,8(sp)
     e78:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     e7a:	02b57663          	bgeu	a0,a1,ea6 <memmove+0x32>
    while(n-- > 0)
     e7e:	02c05163          	blez	a2,ea0 <memmove+0x2c>
     e82:	fff6079b          	addiw	a5,a2,-1
     e86:	1782                	slli	a5,a5,0x20
     e88:	9381                	srli	a5,a5,0x20
     e8a:	0785                	addi	a5,a5,1
     e8c:	97aa                	add	a5,a5,a0
  dst = vdst;
     e8e:	872a                	mv	a4,a0
      *dst++ = *src++;
     e90:	0585                	addi	a1,a1,1
     e92:	0705                	addi	a4,a4,1
     e94:	fff5c683          	lbu	a3,-1(a1)
     e98:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     e9c:	fee79ae3          	bne	a5,a4,e90 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     ea0:	6422                	ld	s0,8(sp)
     ea2:	0141                	addi	sp,sp,16
     ea4:	8082                	ret
    dst += n;
     ea6:	00c50733          	add	a4,a0,a2
    src += n;
     eaa:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     eac:	fec05ae3          	blez	a2,ea0 <memmove+0x2c>
     eb0:	fff6079b          	addiw	a5,a2,-1
     eb4:	1782                	slli	a5,a5,0x20
     eb6:	9381                	srli	a5,a5,0x20
     eb8:	fff7c793          	not	a5,a5
     ebc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     ebe:	15fd                	addi	a1,a1,-1
     ec0:	177d                	addi	a4,a4,-1
     ec2:	0005c683          	lbu	a3,0(a1)
     ec6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     eca:	fee79ae3          	bne	a5,a4,ebe <memmove+0x4a>
     ece:	bfc9                	j	ea0 <memmove+0x2c>

0000000000000ed0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     ed0:	1141                	addi	sp,sp,-16
     ed2:	e422                	sd	s0,8(sp)
     ed4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     ed6:	ca05                	beqz	a2,f06 <memcmp+0x36>
     ed8:	fff6069b          	addiw	a3,a2,-1
     edc:	1682                	slli	a3,a3,0x20
     ede:	9281                	srli	a3,a3,0x20
     ee0:	0685                	addi	a3,a3,1
     ee2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     ee4:	00054783          	lbu	a5,0(a0)
     ee8:	0005c703          	lbu	a4,0(a1)
     eec:	00e79863          	bne	a5,a4,efc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     ef0:	0505                	addi	a0,a0,1
    p2++;
     ef2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     ef4:	fed518e3          	bne	a0,a3,ee4 <memcmp+0x14>
  }
  return 0;
     ef8:	4501                	li	a0,0
     efa:	a019                	j	f00 <memcmp+0x30>
      return *p1 - *p2;
     efc:	40e7853b          	subw	a0,a5,a4
}
     f00:	6422                	ld	s0,8(sp)
     f02:	0141                	addi	sp,sp,16
     f04:	8082                	ret
  return 0;
     f06:	4501                	li	a0,0
     f08:	bfe5                	j	f00 <memcmp+0x30>

0000000000000f0a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     f0a:	1141                	addi	sp,sp,-16
     f0c:	e406                	sd	ra,8(sp)
     f0e:	e022                	sd	s0,0(sp)
     f10:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     f12:	00000097          	auipc	ra,0x0
     f16:	f62080e7          	jalr	-158(ra) # e74 <memmove>
}
     f1a:	60a2                	ld	ra,8(sp)
     f1c:	6402                	ld	s0,0(sp)
     f1e:	0141                	addi	sp,sp,16
     f20:	8082                	ret

0000000000000f22 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     f22:	4885                	li	a7,1
 ecall
     f24:	00000073          	ecall
 ret
     f28:	8082                	ret

0000000000000f2a <exit>:
.global exit
exit:
 li a7, SYS_exit
     f2a:	4889                	li	a7,2
 ecall
     f2c:	00000073          	ecall
 ret
     f30:	8082                	ret

0000000000000f32 <wait>:
.global wait
wait:
 li a7, SYS_wait
     f32:	488d                	li	a7,3
 ecall
     f34:	00000073          	ecall
 ret
     f38:	8082                	ret

0000000000000f3a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     f3a:	4891                	li	a7,4
 ecall
     f3c:	00000073          	ecall
 ret
     f40:	8082                	ret

0000000000000f42 <read>:
.global read
read:
 li a7, SYS_read
     f42:	4895                	li	a7,5
 ecall
     f44:	00000073          	ecall
 ret
     f48:	8082                	ret

0000000000000f4a <write>:
.global write
write:
 li a7, SYS_write
     f4a:	48c1                	li	a7,16
 ecall
     f4c:	00000073          	ecall
 ret
     f50:	8082                	ret

0000000000000f52 <close>:
.global close
close:
 li a7, SYS_close
     f52:	48d5                	li	a7,21
 ecall
     f54:	00000073          	ecall
 ret
     f58:	8082                	ret

0000000000000f5a <kill>:
.global kill
kill:
 li a7, SYS_kill
     f5a:	4899                	li	a7,6
 ecall
     f5c:	00000073          	ecall
 ret
     f60:	8082                	ret

0000000000000f62 <exec>:
.global exec
exec:
 li a7, SYS_exec
     f62:	489d                	li	a7,7
 ecall
     f64:	00000073          	ecall
 ret
     f68:	8082                	ret

0000000000000f6a <open>:
.global open
open:
 li a7, SYS_open
     f6a:	48bd                	li	a7,15
 ecall
     f6c:	00000073          	ecall
 ret
     f70:	8082                	ret

0000000000000f72 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     f72:	48c5                	li	a7,17
 ecall
     f74:	00000073          	ecall
 ret
     f78:	8082                	ret

0000000000000f7a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     f7a:	48c9                	li	a7,18
 ecall
     f7c:	00000073          	ecall
 ret
     f80:	8082                	ret

0000000000000f82 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     f82:	48a1                	li	a7,8
 ecall
     f84:	00000073          	ecall
 ret
     f88:	8082                	ret

0000000000000f8a <link>:
.global link
link:
 li a7, SYS_link
     f8a:	48cd                	li	a7,19
 ecall
     f8c:	00000073          	ecall
 ret
     f90:	8082                	ret

0000000000000f92 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f92:	48d1                	li	a7,20
 ecall
     f94:	00000073          	ecall
 ret
     f98:	8082                	ret

0000000000000f9a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f9a:	48a5                	li	a7,9
 ecall
     f9c:	00000073          	ecall
 ret
     fa0:	8082                	ret

0000000000000fa2 <dup>:
.global dup
dup:
 li a7, SYS_dup
     fa2:	48a9                	li	a7,10
 ecall
     fa4:	00000073          	ecall
 ret
     fa8:	8082                	ret

0000000000000faa <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     faa:	48ad                	li	a7,11
 ecall
     fac:	00000073          	ecall
 ret
     fb0:	8082                	ret

0000000000000fb2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     fb2:	48b1                	li	a7,12
 ecall
     fb4:	00000073          	ecall
 ret
     fb8:	8082                	ret

0000000000000fba <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     fba:	48b5                	li	a7,13
 ecall
     fbc:	00000073          	ecall
 ret
     fc0:	8082                	ret

0000000000000fc2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     fc2:	48b9                	li	a7,14
 ecall
     fc4:	00000073          	ecall
 ret
     fc8:	8082                	ret

0000000000000fca <connect>:
.global connect
connect:
 li a7, SYS_connect
     fca:	48d9                	li	a7,22
 ecall
     fcc:	00000073          	ecall
 ret
     fd0:	8082                	ret

0000000000000fd2 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
     fd2:	48dd                	li	a7,23
 ecall
     fd4:	00000073          	ecall
 ret
     fd8:	8082                	ret

0000000000000fda <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     fda:	1101                	addi	sp,sp,-32
     fdc:	ec06                	sd	ra,24(sp)
     fde:	e822                	sd	s0,16(sp)
     fe0:	1000                	addi	s0,sp,32
     fe2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     fe6:	4605                	li	a2,1
     fe8:	fef40593          	addi	a1,s0,-17
     fec:	00000097          	auipc	ra,0x0
     ff0:	f5e080e7          	jalr	-162(ra) # f4a <write>
}
     ff4:	60e2                	ld	ra,24(sp)
     ff6:	6442                	ld	s0,16(sp)
     ff8:	6105                	addi	sp,sp,32
     ffa:	8082                	ret

0000000000000ffc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     ffc:	7139                	addi	sp,sp,-64
     ffe:	fc06                	sd	ra,56(sp)
    1000:	f822                	sd	s0,48(sp)
    1002:	f426                	sd	s1,40(sp)
    1004:	f04a                	sd	s2,32(sp)
    1006:	ec4e                	sd	s3,24(sp)
    1008:	0080                	addi	s0,sp,64
    100a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    100c:	c299                	beqz	a3,1012 <printint+0x16>
    100e:	0805c863          	bltz	a1,109e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    1012:	2581                	sext.w	a1,a1
  neg = 0;
    1014:	4881                	li	a7,0
    1016:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    101a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    101c:	2601                	sext.w	a2,a2
    101e:	00001517          	auipc	a0,0x1
    1022:	85a50513          	addi	a0,a0,-1958 # 1878 <digits>
    1026:	883a                	mv	a6,a4
    1028:	2705                	addiw	a4,a4,1
    102a:	02c5f7bb          	remuw	a5,a1,a2
    102e:	1782                	slli	a5,a5,0x20
    1030:	9381                	srli	a5,a5,0x20
    1032:	97aa                	add	a5,a5,a0
    1034:	0007c783          	lbu	a5,0(a5)
    1038:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    103c:	0005879b          	sext.w	a5,a1
    1040:	02c5d5bb          	divuw	a1,a1,a2
    1044:	0685                	addi	a3,a3,1
    1046:	fec7f0e3          	bgeu	a5,a2,1026 <printint+0x2a>
  if(neg)
    104a:	00088b63          	beqz	a7,1060 <printint+0x64>
    buf[i++] = '-';
    104e:	fd040793          	addi	a5,s0,-48
    1052:	973e                	add	a4,a4,a5
    1054:	02d00793          	li	a5,45
    1058:	fef70823          	sb	a5,-16(a4)
    105c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    1060:	02e05863          	blez	a4,1090 <printint+0x94>
    1064:	fc040793          	addi	a5,s0,-64
    1068:	00e78933          	add	s2,a5,a4
    106c:	fff78993          	addi	s3,a5,-1
    1070:	99ba                	add	s3,s3,a4
    1072:	377d                	addiw	a4,a4,-1
    1074:	1702                	slli	a4,a4,0x20
    1076:	9301                	srli	a4,a4,0x20
    1078:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    107c:	fff94583          	lbu	a1,-1(s2)
    1080:	8526                	mv	a0,s1
    1082:	00000097          	auipc	ra,0x0
    1086:	f58080e7          	jalr	-168(ra) # fda <putc>
  while(--i >= 0)
    108a:	197d                	addi	s2,s2,-1
    108c:	ff3918e3          	bne	s2,s3,107c <printint+0x80>
}
    1090:	70e2                	ld	ra,56(sp)
    1092:	7442                	ld	s0,48(sp)
    1094:	74a2                	ld	s1,40(sp)
    1096:	7902                	ld	s2,32(sp)
    1098:	69e2                	ld	s3,24(sp)
    109a:	6121                	addi	sp,sp,64
    109c:	8082                	ret
    x = -xx;
    109e:	40b005bb          	negw	a1,a1
    neg = 1;
    10a2:	4885                	li	a7,1
    x = -xx;
    10a4:	bf8d                	j	1016 <printint+0x1a>

00000000000010a6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    10a6:	7119                	addi	sp,sp,-128
    10a8:	fc86                	sd	ra,120(sp)
    10aa:	f8a2                	sd	s0,112(sp)
    10ac:	f4a6                	sd	s1,104(sp)
    10ae:	f0ca                	sd	s2,96(sp)
    10b0:	ecce                	sd	s3,88(sp)
    10b2:	e8d2                	sd	s4,80(sp)
    10b4:	e4d6                	sd	s5,72(sp)
    10b6:	e0da                	sd	s6,64(sp)
    10b8:	fc5e                	sd	s7,56(sp)
    10ba:	f862                	sd	s8,48(sp)
    10bc:	f466                	sd	s9,40(sp)
    10be:	f06a                	sd	s10,32(sp)
    10c0:	ec6e                	sd	s11,24(sp)
    10c2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    10c4:	0005c903          	lbu	s2,0(a1)
    10c8:	18090f63          	beqz	s2,1266 <vprintf+0x1c0>
    10cc:	8aaa                	mv	s5,a0
    10ce:	8b32                	mv	s6,a2
    10d0:	00158493          	addi	s1,a1,1
  state = 0;
    10d4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    10d6:	02500a13          	li	s4,37
      if(c == 'd'){
    10da:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    10de:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    10e2:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    10e6:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    10ea:	00000b97          	auipc	s7,0x0
    10ee:	78eb8b93          	addi	s7,s7,1934 # 1878 <digits>
    10f2:	a839                	j	1110 <vprintf+0x6a>
        putc(fd, c);
    10f4:	85ca                	mv	a1,s2
    10f6:	8556                	mv	a0,s5
    10f8:	00000097          	auipc	ra,0x0
    10fc:	ee2080e7          	jalr	-286(ra) # fda <putc>
    1100:	a019                	j	1106 <vprintf+0x60>
    } else if(state == '%'){
    1102:	01498f63          	beq	s3,s4,1120 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    1106:	0485                	addi	s1,s1,1
    1108:	fff4c903          	lbu	s2,-1(s1)
    110c:	14090d63          	beqz	s2,1266 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    1110:	0009079b          	sext.w	a5,s2
    if(state == 0){
    1114:	fe0997e3          	bnez	s3,1102 <vprintf+0x5c>
      if(c == '%'){
    1118:	fd479ee3          	bne	a5,s4,10f4 <vprintf+0x4e>
        state = '%';
    111c:	89be                	mv	s3,a5
    111e:	b7e5                	j	1106 <vprintf+0x60>
      if(c == 'd'){
    1120:	05878063          	beq	a5,s8,1160 <vprintf+0xba>
      } else if(c == 'l') {
    1124:	05978c63          	beq	a5,s9,117c <vprintf+0xd6>
      } else if(c == 'x') {
    1128:	07a78863          	beq	a5,s10,1198 <vprintf+0xf2>
      } else if(c == 'p') {
    112c:	09b78463          	beq	a5,s11,11b4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    1130:	07300713          	li	a4,115
    1134:	0ce78663          	beq	a5,a4,1200 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1138:	06300713          	li	a4,99
    113c:	0ee78e63          	beq	a5,a4,1238 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    1140:	11478863          	beq	a5,s4,1250 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1144:	85d2                	mv	a1,s4
    1146:	8556                	mv	a0,s5
    1148:	00000097          	auipc	ra,0x0
    114c:	e92080e7          	jalr	-366(ra) # fda <putc>
        putc(fd, c);
    1150:	85ca                	mv	a1,s2
    1152:	8556                	mv	a0,s5
    1154:	00000097          	auipc	ra,0x0
    1158:	e86080e7          	jalr	-378(ra) # fda <putc>
      }
      state = 0;
    115c:	4981                	li	s3,0
    115e:	b765                	j	1106 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    1160:	008b0913          	addi	s2,s6,8
    1164:	4685                	li	a3,1
    1166:	4629                	li	a2,10
    1168:	000b2583          	lw	a1,0(s6)
    116c:	8556                	mv	a0,s5
    116e:	00000097          	auipc	ra,0x0
    1172:	e8e080e7          	jalr	-370(ra) # ffc <printint>
    1176:	8b4a                	mv	s6,s2
      state = 0;
    1178:	4981                	li	s3,0
    117a:	b771                	j	1106 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    117c:	008b0913          	addi	s2,s6,8
    1180:	4681                	li	a3,0
    1182:	4629                	li	a2,10
    1184:	000b2583          	lw	a1,0(s6)
    1188:	8556                	mv	a0,s5
    118a:	00000097          	auipc	ra,0x0
    118e:	e72080e7          	jalr	-398(ra) # ffc <printint>
    1192:	8b4a                	mv	s6,s2
      state = 0;
    1194:	4981                	li	s3,0
    1196:	bf85                	j	1106 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    1198:	008b0913          	addi	s2,s6,8
    119c:	4681                	li	a3,0
    119e:	4641                	li	a2,16
    11a0:	000b2583          	lw	a1,0(s6)
    11a4:	8556                	mv	a0,s5
    11a6:	00000097          	auipc	ra,0x0
    11aa:	e56080e7          	jalr	-426(ra) # ffc <printint>
    11ae:	8b4a                	mv	s6,s2
      state = 0;
    11b0:	4981                	li	s3,0
    11b2:	bf91                	j	1106 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    11b4:	008b0793          	addi	a5,s6,8
    11b8:	f8f43423          	sd	a5,-120(s0)
    11bc:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    11c0:	03000593          	li	a1,48
    11c4:	8556                	mv	a0,s5
    11c6:	00000097          	auipc	ra,0x0
    11ca:	e14080e7          	jalr	-492(ra) # fda <putc>
  putc(fd, 'x');
    11ce:	85ea                	mv	a1,s10
    11d0:	8556                	mv	a0,s5
    11d2:	00000097          	auipc	ra,0x0
    11d6:	e08080e7          	jalr	-504(ra) # fda <putc>
    11da:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    11dc:	03c9d793          	srli	a5,s3,0x3c
    11e0:	97de                	add	a5,a5,s7
    11e2:	0007c583          	lbu	a1,0(a5)
    11e6:	8556                	mv	a0,s5
    11e8:	00000097          	auipc	ra,0x0
    11ec:	df2080e7          	jalr	-526(ra) # fda <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    11f0:	0992                	slli	s3,s3,0x4
    11f2:	397d                	addiw	s2,s2,-1
    11f4:	fe0914e3          	bnez	s2,11dc <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    11f8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    11fc:	4981                	li	s3,0
    11fe:	b721                	j	1106 <vprintf+0x60>
        s = va_arg(ap, char*);
    1200:	008b0993          	addi	s3,s6,8
    1204:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    1208:	02090163          	beqz	s2,122a <vprintf+0x184>
        while(*s != 0){
    120c:	00094583          	lbu	a1,0(s2)
    1210:	c9a1                	beqz	a1,1260 <vprintf+0x1ba>
          putc(fd, *s);
    1212:	8556                	mv	a0,s5
    1214:	00000097          	auipc	ra,0x0
    1218:	dc6080e7          	jalr	-570(ra) # fda <putc>
          s++;
    121c:	0905                	addi	s2,s2,1
        while(*s != 0){
    121e:	00094583          	lbu	a1,0(s2)
    1222:	f9e5                	bnez	a1,1212 <vprintf+0x16c>
        s = va_arg(ap, char*);
    1224:	8b4e                	mv	s6,s3
      state = 0;
    1226:	4981                	li	s3,0
    1228:	bdf9                	j	1106 <vprintf+0x60>
          s = "(null)";
    122a:	00000917          	auipc	s2,0x0
    122e:	64690913          	addi	s2,s2,1606 # 1870 <malloc+0x500>
        while(*s != 0){
    1232:	02800593          	li	a1,40
    1236:	bff1                	j	1212 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    1238:	008b0913          	addi	s2,s6,8
    123c:	000b4583          	lbu	a1,0(s6)
    1240:	8556                	mv	a0,s5
    1242:	00000097          	auipc	ra,0x0
    1246:	d98080e7          	jalr	-616(ra) # fda <putc>
    124a:	8b4a                	mv	s6,s2
      state = 0;
    124c:	4981                	li	s3,0
    124e:	bd65                	j	1106 <vprintf+0x60>
        putc(fd, c);
    1250:	85d2                	mv	a1,s4
    1252:	8556                	mv	a0,s5
    1254:	00000097          	auipc	ra,0x0
    1258:	d86080e7          	jalr	-634(ra) # fda <putc>
      state = 0;
    125c:	4981                	li	s3,0
    125e:	b565                	j	1106 <vprintf+0x60>
        s = va_arg(ap, char*);
    1260:	8b4e                	mv	s6,s3
      state = 0;
    1262:	4981                	li	s3,0
    1264:	b54d                	j	1106 <vprintf+0x60>
    }
  }
}
    1266:	70e6                	ld	ra,120(sp)
    1268:	7446                	ld	s0,112(sp)
    126a:	74a6                	ld	s1,104(sp)
    126c:	7906                	ld	s2,96(sp)
    126e:	69e6                	ld	s3,88(sp)
    1270:	6a46                	ld	s4,80(sp)
    1272:	6aa6                	ld	s5,72(sp)
    1274:	6b06                	ld	s6,64(sp)
    1276:	7be2                	ld	s7,56(sp)
    1278:	7c42                	ld	s8,48(sp)
    127a:	7ca2                	ld	s9,40(sp)
    127c:	7d02                	ld	s10,32(sp)
    127e:	6de2                	ld	s11,24(sp)
    1280:	6109                	addi	sp,sp,128
    1282:	8082                	ret

0000000000001284 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1284:	715d                	addi	sp,sp,-80
    1286:	ec06                	sd	ra,24(sp)
    1288:	e822                	sd	s0,16(sp)
    128a:	1000                	addi	s0,sp,32
    128c:	e010                	sd	a2,0(s0)
    128e:	e414                	sd	a3,8(s0)
    1290:	e818                	sd	a4,16(s0)
    1292:	ec1c                	sd	a5,24(s0)
    1294:	03043023          	sd	a6,32(s0)
    1298:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    129c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    12a0:	8622                	mv	a2,s0
    12a2:	00000097          	auipc	ra,0x0
    12a6:	e04080e7          	jalr	-508(ra) # 10a6 <vprintf>
}
    12aa:	60e2                	ld	ra,24(sp)
    12ac:	6442                	ld	s0,16(sp)
    12ae:	6161                	addi	sp,sp,80
    12b0:	8082                	ret

00000000000012b2 <printf>:

void
printf(const char *fmt, ...)
{
    12b2:	711d                	addi	sp,sp,-96
    12b4:	ec06                	sd	ra,24(sp)
    12b6:	e822                	sd	s0,16(sp)
    12b8:	1000                	addi	s0,sp,32
    12ba:	e40c                	sd	a1,8(s0)
    12bc:	e810                	sd	a2,16(s0)
    12be:	ec14                	sd	a3,24(s0)
    12c0:	f018                	sd	a4,32(s0)
    12c2:	f41c                	sd	a5,40(s0)
    12c4:	03043823          	sd	a6,48(s0)
    12c8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    12cc:	00840613          	addi	a2,s0,8
    12d0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    12d4:	85aa                	mv	a1,a0
    12d6:	4505                	li	a0,1
    12d8:	00000097          	auipc	ra,0x0
    12dc:	dce080e7          	jalr	-562(ra) # 10a6 <vprintf>
}
    12e0:	60e2                	ld	ra,24(sp)
    12e2:	6442                	ld	s0,16(sp)
    12e4:	6125                	addi	sp,sp,96
    12e6:	8082                	ret

00000000000012e8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    12e8:	1141                	addi	sp,sp,-16
    12ea:	e422                	sd	s0,8(sp)
    12ec:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    12ee:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12f2:	00000797          	auipc	a5,0x0
    12f6:	5a67b783          	ld	a5,1446(a5) # 1898 <freep>
    12fa:	a805                	j	132a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    12fc:	4618                	lw	a4,8(a2)
    12fe:	9db9                	addw	a1,a1,a4
    1300:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1304:	6398                	ld	a4,0(a5)
    1306:	6318                	ld	a4,0(a4)
    1308:	fee53823          	sd	a4,-16(a0)
    130c:	a091                	j	1350 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    130e:	ff852703          	lw	a4,-8(a0)
    1312:	9e39                	addw	a2,a2,a4
    1314:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    1316:	ff053703          	ld	a4,-16(a0)
    131a:	e398                	sd	a4,0(a5)
    131c:	a099                	j	1362 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    131e:	6398                	ld	a4,0(a5)
    1320:	00e7e463          	bltu	a5,a4,1328 <free+0x40>
    1324:	00e6ea63          	bltu	a3,a4,1338 <free+0x50>
{
    1328:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    132a:	fed7fae3          	bgeu	a5,a3,131e <free+0x36>
    132e:	6398                	ld	a4,0(a5)
    1330:	00e6e463          	bltu	a3,a4,1338 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1334:	fee7eae3          	bltu	a5,a4,1328 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    1338:	ff852583          	lw	a1,-8(a0)
    133c:	6390                	ld	a2,0(a5)
    133e:	02059713          	slli	a4,a1,0x20
    1342:	9301                	srli	a4,a4,0x20
    1344:	0712                	slli	a4,a4,0x4
    1346:	9736                	add	a4,a4,a3
    1348:	fae60ae3          	beq	a2,a4,12fc <free+0x14>
    bp->s.ptr = p->s.ptr;
    134c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1350:	4790                	lw	a2,8(a5)
    1352:	02061713          	slli	a4,a2,0x20
    1356:	9301                	srli	a4,a4,0x20
    1358:	0712                	slli	a4,a4,0x4
    135a:	973e                	add	a4,a4,a5
    135c:	fae689e3          	beq	a3,a4,130e <free+0x26>
  } else
    p->s.ptr = bp;
    1360:	e394                	sd	a3,0(a5)
  freep = p;
    1362:	00000717          	auipc	a4,0x0
    1366:	52f73b23          	sd	a5,1334(a4) # 1898 <freep>
}
    136a:	6422                	ld	s0,8(sp)
    136c:	0141                	addi	sp,sp,16
    136e:	8082                	ret

0000000000001370 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1370:	7139                	addi	sp,sp,-64
    1372:	fc06                	sd	ra,56(sp)
    1374:	f822                	sd	s0,48(sp)
    1376:	f426                	sd	s1,40(sp)
    1378:	f04a                	sd	s2,32(sp)
    137a:	ec4e                	sd	s3,24(sp)
    137c:	e852                	sd	s4,16(sp)
    137e:	e456                	sd	s5,8(sp)
    1380:	e05a                	sd	s6,0(sp)
    1382:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1384:	02051493          	slli	s1,a0,0x20
    1388:	9081                	srli	s1,s1,0x20
    138a:	04bd                	addi	s1,s1,15
    138c:	8091                	srli	s1,s1,0x4
    138e:	0014899b          	addiw	s3,s1,1
    1392:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1394:	00000517          	auipc	a0,0x0
    1398:	50453503          	ld	a0,1284(a0) # 1898 <freep>
    139c:	c515                	beqz	a0,13c8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    139e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    13a0:	4798                	lw	a4,8(a5)
    13a2:	02977f63          	bgeu	a4,s1,13e0 <malloc+0x70>
    13a6:	8a4e                	mv	s4,s3
    13a8:	0009871b          	sext.w	a4,s3
    13ac:	6685                	lui	a3,0x1
    13ae:	00d77363          	bgeu	a4,a3,13b4 <malloc+0x44>
    13b2:	6a05                	lui	s4,0x1
    13b4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    13b8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    13bc:	00000917          	auipc	s2,0x0
    13c0:	4dc90913          	addi	s2,s2,1244 # 1898 <freep>
  if(p == (char*)-1)
    13c4:	5afd                	li	s5,-1
    13c6:	a88d                	j	1438 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    13c8:	00000797          	auipc	a5,0x0
    13cc:	4d878793          	addi	a5,a5,1240 # 18a0 <base>
    13d0:	00000717          	auipc	a4,0x0
    13d4:	4cf73423          	sd	a5,1224(a4) # 1898 <freep>
    13d8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    13da:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    13de:	b7e1                	j	13a6 <malloc+0x36>
      if(p->s.size == nunits)
    13e0:	02e48b63          	beq	s1,a4,1416 <malloc+0xa6>
        p->s.size -= nunits;
    13e4:	4137073b          	subw	a4,a4,s3
    13e8:	c798                	sw	a4,8(a5)
        p += p->s.size;
    13ea:	1702                	slli	a4,a4,0x20
    13ec:	9301                	srli	a4,a4,0x20
    13ee:	0712                	slli	a4,a4,0x4
    13f0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    13f2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    13f6:	00000717          	auipc	a4,0x0
    13fa:	4aa73123          	sd	a0,1186(a4) # 1898 <freep>
      return (void*)(p + 1);
    13fe:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1402:	70e2                	ld	ra,56(sp)
    1404:	7442                	ld	s0,48(sp)
    1406:	74a2                	ld	s1,40(sp)
    1408:	7902                	ld	s2,32(sp)
    140a:	69e2                	ld	s3,24(sp)
    140c:	6a42                	ld	s4,16(sp)
    140e:	6aa2                	ld	s5,8(sp)
    1410:	6b02                	ld	s6,0(sp)
    1412:	6121                	addi	sp,sp,64
    1414:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1416:	6398                	ld	a4,0(a5)
    1418:	e118                	sd	a4,0(a0)
    141a:	bff1                	j	13f6 <malloc+0x86>
  hp->s.size = nu;
    141c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1420:	0541                	addi	a0,a0,16
    1422:	00000097          	auipc	ra,0x0
    1426:	ec6080e7          	jalr	-314(ra) # 12e8 <free>
  return freep;
    142a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    142e:	d971                	beqz	a0,1402 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1430:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1432:	4798                	lw	a4,8(a5)
    1434:	fa9776e3          	bgeu	a4,s1,13e0 <malloc+0x70>
    if(p == freep)
    1438:	00093703          	ld	a4,0(s2)
    143c:	853e                	mv	a0,a5
    143e:	fef719e3          	bne	a4,a5,1430 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    1442:	8552                	mv	a0,s4
    1444:	00000097          	auipc	ra,0x0
    1448:	b6e080e7          	jalr	-1170(ra) # fb2 <sbrk>
  if(p == (char*)-1)
    144c:	fd5518e3          	bne	a0,s5,141c <malloc+0xac>
        return 0;
    1450:	4501                	li	a0,0
    1452:	bf45                	j	1402 <malloc+0x92>
