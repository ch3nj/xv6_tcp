
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000c117          	auipc	sp,0xc
    80000004:	80010113          	addi	sp,sp,-2048 # 8000b800 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <junk>:
    8000001a:	a001                	j	8000001a <junk>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	0000b617          	auipc	a2,0xb
    8000004e:	fb660613          	addi	a2,a2,-74 # 8000b000 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	e4478793          	addi	a5,a5,-444 # 80005ea0 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd5433>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e8678793          	addi	a5,a5,-378 # 80000f2c <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(struct file *f, int user_dst, uint64 dst, int n)
{
    800000ec:	7119                	addi	sp,sp,-128
    800000ee:	fc86                	sd	ra,120(sp)
    800000f0:	f8a2                	sd	s0,112(sp)
    800000f2:	f4a6                	sd	s1,104(sp)
    800000f4:	f0ca                	sd	s2,96(sp)
    800000f6:	ecce                	sd	s3,88(sp)
    800000f8:	e8d2                	sd	s4,80(sp)
    800000fa:	e4d6                	sd	s5,72(sp)
    800000fc:	e0da                	sd	s6,64(sp)
    800000fe:	fc5e                	sd	s7,56(sp)
    80000100:	f862                	sd	s8,48(sp)
    80000102:	f466                	sd	s9,40(sp)
    80000104:	f06a                	sd	s10,32(sp)
    80000106:	ec6e                	sd	s11,24(sp)
    80000108:	0100                	addi	s0,sp,128
    8000010a:	8b2e                	mv	s6,a1
    8000010c:	8ab2                	mv	s5,a2
    8000010e:	8a36                	mv	s4,a3
  uint target;
  int c;
  char cbuf;

  target = n;
    80000110:	00068b9b          	sext.w	s7,a3
  acquire(&cons.lock);
    80000114:	00013517          	auipc	a0,0x13
    80000118:	6ec50513          	addi	a0,a0,1772 # 80013800 <cons>
    8000011c:	00001097          	auipc	ra,0x1
    80000120:	990080e7          	jalr	-1648(ra) # 80000aac <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000124:	00013497          	auipc	s1,0x13
    80000128:	6dc48493          	addi	s1,s1,1756 # 80013800 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000012c:	89a6                	mv	s3,s1
    8000012e:	00013917          	auipc	s2,0x13
    80000132:	77290913          	addi	s2,s2,1906 # 800138a0 <cons+0xa0>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    80000136:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000138:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    8000013a:	4da9                	li	s11,10
  while(n > 0){
    8000013c:	07405863          	blez	s4,800001ac <consoleread+0xc0>
    while(cons.r == cons.w){
    80000140:	0a04a783          	lw	a5,160(s1)
    80000144:	0a44a703          	lw	a4,164(s1)
    80000148:	02f71463          	bne	a4,a5,80000170 <consoleread+0x84>
      if(myproc()->killed){
    8000014c:	00002097          	auipc	ra,0x2
    80000150:	956080e7          	jalr	-1706(ra) # 80001aa2 <myproc>
    80000154:	5d1c                	lw	a5,56(a0)
    80000156:	e7b5                	bnez	a5,800001c2 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    80000158:	85ce                	mv	a1,s3
    8000015a:	854a                	mv	a0,s2
    8000015c:	00002097          	auipc	ra,0x2
    80000160:	102080e7          	jalr	258(ra) # 8000225e <sleep>
    while(cons.r == cons.w){
    80000164:	0a04a783          	lw	a5,160(s1)
    80000168:	0a44a703          	lw	a4,164(s1)
    8000016c:	fef700e3          	beq	a4,a5,8000014c <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    80000170:	0017871b          	addiw	a4,a5,1
    80000174:	0ae4a023          	sw	a4,160(s1)
    80000178:	07f7f713          	andi	a4,a5,127
    8000017c:	9726                	add	a4,a4,s1
    8000017e:	02074703          	lbu	a4,32(a4)
    80000182:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000186:	079c0663          	beq	s8,s9,800001f2 <consoleread+0x106>
    cbuf = c;
    8000018a:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000018e:	4685                	li	a3,1
    80000190:	f8f40613          	addi	a2,s0,-113
    80000194:	85d6                	mv	a1,s5
    80000196:	855a                	mv	a0,s6
    80000198:	00002097          	auipc	ra,0x2
    8000019c:	326080e7          	jalr	806(ra) # 800024be <either_copyout>
    800001a0:	01a50663          	beq	a0,s10,800001ac <consoleread+0xc0>
    dst++;
    800001a4:	0a85                	addi	s5,s5,1
    --n;
    800001a6:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    800001a8:	f9bc1ae3          	bne	s8,s11,8000013c <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800001ac:	00013517          	auipc	a0,0x13
    800001b0:	65450513          	addi	a0,a0,1620 # 80013800 <cons>
    800001b4:	00001097          	auipc	ra,0x1
    800001b8:	9c8080e7          	jalr	-1592(ra) # 80000b7c <release>

  return target - n;
    800001bc:	414b853b          	subw	a0,s7,s4
    800001c0:	a811                	j	800001d4 <consoleread+0xe8>
        release(&cons.lock);
    800001c2:	00013517          	auipc	a0,0x13
    800001c6:	63e50513          	addi	a0,a0,1598 # 80013800 <cons>
    800001ca:	00001097          	auipc	ra,0x1
    800001ce:	9b2080e7          	jalr	-1614(ra) # 80000b7c <release>
        return -1;
    800001d2:	557d                	li	a0,-1
}
    800001d4:	70e6                	ld	ra,120(sp)
    800001d6:	7446                	ld	s0,112(sp)
    800001d8:	74a6                	ld	s1,104(sp)
    800001da:	7906                	ld	s2,96(sp)
    800001dc:	69e6                	ld	s3,88(sp)
    800001de:	6a46                	ld	s4,80(sp)
    800001e0:	6aa6                	ld	s5,72(sp)
    800001e2:	6b06                	ld	s6,64(sp)
    800001e4:	7be2                	ld	s7,56(sp)
    800001e6:	7c42                	ld	s8,48(sp)
    800001e8:	7ca2                	ld	s9,40(sp)
    800001ea:	7d02                	ld	s10,32(sp)
    800001ec:	6de2                	ld	s11,24(sp)
    800001ee:	6109                	addi	sp,sp,128
    800001f0:	8082                	ret
      if(n < target){
    800001f2:	000a071b          	sext.w	a4,s4
    800001f6:	fb777be3          	bgeu	a4,s7,800001ac <consoleread+0xc0>
        cons.r--;
    800001fa:	00013717          	auipc	a4,0x13
    800001fe:	6af72323          	sw	a5,1702(a4) # 800138a0 <cons+0xa0>
    80000202:	b76d                	j	800001ac <consoleread+0xc0>

0000000080000204 <consputc>:
  if(panicked){
    80000204:	00029797          	auipc	a5,0x29
    80000208:	17c7a783          	lw	a5,380(a5) # 80029380 <panicked>
    8000020c:	c391                	beqz	a5,80000210 <consputc+0xc>
    for(;;)
    8000020e:	a001                	j	8000020e <consputc+0xa>
{
    80000210:	1141                	addi	sp,sp,-16
    80000212:	e406                	sd	ra,8(sp)
    80000214:	e022                	sd	s0,0(sp)
    80000216:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000218:	10000793          	li	a5,256
    8000021c:	00f50a63          	beq	a0,a5,80000230 <consputc+0x2c>
    uartputc(c);
    80000220:	00000097          	auipc	ra,0x0
    80000224:	5e2080e7          	jalr	1506(ra) # 80000802 <uartputc>
}
    80000228:	60a2                	ld	ra,8(sp)
    8000022a:	6402                	ld	s0,0(sp)
    8000022c:	0141                	addi	sp,sp,16
    8000022e:	8082                	ret
    uartputc('\b'); uartputc(' '); uartputc('\b');
    80000230:	4521                	li	a0,8
    80000232:	00000097          	auipc	ra,0x0
    80000236:	5d0080e7          	jalr	1488(ra) # 80000802 <uartputc>
    8000023a:	02000513          	li	a0,32
    8000023e:	00000097          	auipc	ra,0x0
    80000242:	5c4080e7          	jalr	1476(ra) # 80000802 <uartputc>
    80000246:	4521                	li	a0,8
    80000248:	00000097          	auipc	ra,0x0
    8000024c:	5ba080e7          	jalr	1466(ra) # 80000802 <uartputc>
    80000250:	bfe1                	j	80000228 <consputc+0x24>

0000000080000252 <consolewrite>:
{
    80000252:	715d                	addi	sp,sp,-80
    80000254:	e486                	sd	ra,72(sp)
    80000256:	e0a2                	sd	s0,64(sp)
    80000258:	fc26                	sd	s1,56(sp)
    8000025a:	f84a                	sd	s2,48(sp)
    8000025c:	f44e                	sd	s3,40(sp)
    8000025e:	f052                	sd	s4,32(sp)
    80000260:	ec56                	sd	s5,24(sp)
    80000262:	0880                	addi	s0,sp,80
    80000264:	89ae                	mv	s3,a1
    80000266:	84b2                	mv	s1,a2
    80000268:	8ab6                	mv	s5,a3
  acquire(&cons.lock);
    8000026a:	00013517          	auipc	a0,0x13
    8000026e:	59650513          	addi	a0,a0,1430 # 80013800 <cons>
    80000272:	00001097          	auipc	ra,0x1
    80000276:	83a080e7          	jalr	-1990(ra) # 80000aac <acquire>
  for(i = 0; i < n; i++){
    8000027a:	03505e63          	blez	s5,800002b6 <consolewrite+0x64>
    8000027e:	00148913          	addi	s2,s1,1
    80000282:	fffa879b          	addiw	a5,s5,-1
    80000286:	1782                	slli	a5,a5,0x20
    80000288:	9381                	srli	a5,a5,0x20
    8000028a:	993e                	add	s2,s2,a5
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000028c:	5a7d                	li	s4,-1
    8000028e:	4685                	li	a3,1
    80000290:	8626                	mv	a2,s1
    80000292:	85ce                	mv	a1,s3
    80000294:	fbf40513          	addi	a0,s0,-65
    80000298:	00002097          	auipc	ra,0x2
    8000029c:	27c080e7          	jalr	636(ra) # 80002514 <either_copyin>
    800002a0:	01450b63          	beq	a0,s4,800002b6 <consolewrite+0x64>
    consputc(c);
    800002a4:	fbf44503          	lbu	a0,-65(s0)
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	f5c080e7          	jalr	-164(ra) # 80000204 <consputc>
  for(i = 0; i < n; i++){
    800002b0:	0485                	addi	s1,s1,1
    800002b2:	fd249ee3          	bne	s1,s2,8000028e <consolewrite+0x3c>
  release(&cons.lock);
    800002b6:	00013517          	auipc	a0,0x13
    800002ba:	54a50513          	addi	a0,a0,1354 # 80013800 <cons>
    800002be:	00001097          	auipc	ra,0x1
    800002c2:	8be080e7          	jalr	-1858(ra) # 80000b7c <release>
}
    800002c6:	8556                	mv	a0,s5
    800002c8:	60a6                	ld	ra,72(sp)
    800002ca:	6406                	ld	s0,64(sp)
    800002cc:	74e2                	ld	s1,56(sp)
    800002ce:	7942                	ld	s2,48(sp)
    800002d0:	79a2                	ld	s3,40(sp)
    800002d2:	7a02                	ld	s4,32(sp)
    800002d4:	6ae2                	ld	s5,24(sp)
    800002d6:	6161                	addi	sp,sp,80
    800002d8:	8082                	ret

00000000800002da <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002da:	1101                	addi	sp,sp,-32
    800002dc:	ec06                	sd	ra,24(sp)
    800002de:	e822                	sd	s0,16(sp)
    800002e0:	e426                	sd	s1,8(sp)
    800002e2:	e04a                	sd	s2,0(sp)
    800002e4:	1000                	addi	s0,sp,32
    800002e6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002e8:	00013517          	auipc	a0,0x13
    800002ec:	51850513          	addi	a0,a0,1304 # 80013800 <cons>
    800002f0:	00000097          	auipc	ra,0x0
    800002f4:	7bc080e7          	jalr	1980(ra) # 80000aac <acquire>

  switch(c){
    800002f8:	47d5                	li	a5,21
    800002fa:	0af48663          	beq	s1,a5,800003a6 <consoleintr+0xcc>
    800002fe:	0297ca63          	blt	a5,s1,80000332 <consoleintr+0x58>
    80000302:	47a1                	li	a5,8
    80000304:	0ef48763          	beq	s1,a5,800003f2 <consoleintr+0x118>
    80000308:	47c1                	li	a5,16
    8000030a:	10f49a63          	bne	s1,a5,8000041e <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    8000030e:	00002097          	auipc	ra,0x2
    80000312:	25c080e7          	jalr	604(ra) # 8000256a <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000316:	00013517          	auipc	a0,0x13
    8000031a:	4ea50513          	addi	a0,a0,1258 # 80013800 <cons>
    8000031e:	00001097          	auipc	ra,0x1
    80000322:	85e080e7          	jalr	-1954(ra) # 80000b7c <release>
}
    80000326:	60e2                	ld	ra,24(sp)
    80000328:	6442                	ld	s0,16(sp)
    8000032a:	64a2                	ld	s1,8(sp)
    8000032c:	6902                	ld	s2,0(sp)
    8000032e:	6105                	addi	sp,sp,32
    80000330:	8082                	ret
  switch(c){
    80000332:	07f00793          	li	a5,127
    80000336:	0af48e63          	beq	s1,a5,800003f2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000033a:	00013717          	auipc	a4,0x13
    8000033e:	4c670713          	addi	a4,a4,1222 # 80013800 <cons>
    80000342:	0a872783          	lw	a5,168(a4)
    80000346:	0a072703          	lw	a4,160(a4)
    8000034a:	9f99                	subw	a5,a5,a4
    8000034c:	07f00713          	li	a4,127
    80000350:	fcf763e3          	bltu	a4,a5,80000316 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000354:	47b5                	li	a5,13
    80000356:	0cf48763          	beq	s1,a5,80000424 <consoleintr+0x14a>
      consputc(c);
    8000035a:	8526                	mv	a0,s1
    8000035c:	00000097          	auipc	ra,0x0
    80000360:	ea8080e7          	jalr	-344(ra) # 80000204 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000364:	00013797          	auipc	a5,0x13
    80000368:	49c78793          	addi	a5,a5,1180 # 80013800 <cons>
    8000036c:	0a87a703          	lw	a4,168(a5)
    80000370:	0017069b          	addiw	a3,a4,1
    80000374:	0006861b          	sext.w	a2,a3
    80000378:	0ad7a423          	sw	a3,168(a5)
    8000037c:	07f77713          	andi	a4,a4,127
    80000380:	97ba                	add	a5,a5,a4
    80000382:	02978023          	sb	s1,32(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000386:	47a9                	li	a5,10
    80000388:	0cf48563          	beq	s1,a5,80000452 <consoleintr+0x178>
    8000038c:	4791                	li	a5,4
    8000038e:	0cf48263          	beq	s1,a5,80000452 <consoleintr+0x178>
    80000392:	00013797          	auipc	a5,0x13
    80000396:	50e7a783          	lw	a5,1294(a5) # 800138a0 <cons+0xa0>
    8000039a:	0807879b          	addiw	a5,a5,128
    8000039e:	f6f61ce3          	bne	a2,a5,80000316 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003a2:	863e                	mv	a2,a5
    800003a4:	a07d                	j	80000452 <consoleintr+0x178>
    while(cons.e != cons.w &&
    800003a6:	00013717          	auipc	a4,0x13
    800003aa:	45a70713          	addi	a4,a4,1114 # 80013800 <cons>
    800003ae:	0a872783          	lw	a5,168(a4)
    800003b2:	0a472703          	lw	a4,164(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b6:	00013497          	auipc	s1,0x13
    800003ba:	44a48493          	addi	s1,s1,1098 # 80013800 <cons>
    while(cons.e != cons.w &&
    800003be:	4929                	li	s2,10
    800003c0:	f4f70be3          	beq	a4,a5,80000316 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003c4:	37fd                	addiw	a5,a5,-1
    800003c6:	07f7f713          	andi	a4,a5,127
    800003ca:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003cc:	02074703          	lbu	a4,32(a4)
    800003d0:	f52703e3          	beq	a4,s2,80000316 <consoleintr+0x3c>
      cons.e--;
    800003d4:	0af4a423          	sw	a5,168(s1)
      consputc(BACKSPACE);
    800003d8:	10000513          	li	a0,256
    800003dc:	00000097          	auipc	ra,0x0
    800003e0:	e28080e7          	jalr	-472(ra) # 80000204 <consputc>
    while(cons.e != cons.w &&
    800003e4:	0a84a783          	lw	a5,168(s1)
    800003e8:	0a44a703          	lw	a4,164(s1)
    800003ec:	fcf71ce3          	bne	a4,a5,800003c4 <consoleintr+0xea>
    800003f0:	b71d                	j	80000316 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003f2:	00013717          	auipc	a4,0x13
    800003f6:	40e70713          	addi	a4,a4,1038 # 80013800 <cons>
    800003fa:	0a872783          	lw	a5,168(a4)
    800003fe:	0a472703          	lw	a4,164(a4)
    80000402:	f0f70ae3          	beq	a4,a5,80000316 <consoleintr+0x3c>
      cons.e--;
    80000406:	37fd                	addiw	a5,a5,-1
    80000408:	00013717          	auipc	a4,0x13
    8000040c:	4af72023          	sw	a5,1184(a4) # 800138a8 <cons+0xa8>
      consputc(BACKSPACE);
    80000410:	10000513          	li	a0,256
    80000414:	00000097          	auipc	ra,0x0
    80000418:	df0080e7          	jalr	-528(ra) # 80000204 <consputc>
    8000041c:	bded                	j	80000316 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000041e:	ee048ce3          	beqz	s1,80000316 <consoleintr+0x3c>
    80000422:	bf21                	j	8000033a <consoleintr+0x60>
      consputc(c);
    80000424:	4529                	li	a0,10
    80000426:	00000097          	auipc	ra,0x0
    8000042a:	dde080e7          	jalr	-546(ra) # 80000204 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000042e:	00013797          	auipc	a5,0x13
    80000432:	3d278793          	addi	a5,a5,978 # 80013800 <cons>
    80000436:	0a87a703          	lw	a4,168(a5)
    8000043a:	0017069b          	addiw	a3,a4,1
    8000043e:	0006861b          	sext.w	a2,a3
    80000442:	0ad7a423          	sw	a3,168(a5)
    80000446:	07f77713          	andi	a4,a4,127
    8000044a:	97ba                	add	a5,a5,a4
    8000044c:	4729                	li	a4,10
    8000044e:	02e78023          	sb	a4,32(a5)
        cons.w = cons.e;
    80000452:	00013797          	auipc	a5,0x13
    80000456:	44c7a923          	sw	a2,1106(a5) # 800138a4 <cons+0xa4>
        wakeup(&cons.r);
    8000045a:	00013517          	auipc	a0,0x13
    8000045e:	44650513          	addi	a0,a0,1094 # 800138a0 <cons+0xa0>
    80000462:	00002097          	auipc	ra,0x2
    80000466:	f82080e7          	jalr	-126(ra) # 800023e4 <wakeup>
    8000046a:	b575                	j	80000316 <consoleintr+0x3c>

000000008000046c <consoleinit>:

void
consoleinit(void)
{
    8000046c:	1141                	addi	sp,sp,-16
    8000046e:	e406                	sd	ra,8(sp)
    80000470:	e022                	sd	s0,0(sp)
    80000472:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000474:	00009597          	auipc	a1,0x9
    80000478:	ca458593          	addi	a1,a1,-860 # 80009118 <userret+0x88>
    8000047c:	00013517          	auipc	a0,0x13
    80000480:	38450513          	addi	a0,a0,900 # 80013800 <cons>
    80000484:	00000097          	auipc	ra,0x0
    80000488:	554080e7          	jalr	1364(ra) # 800009d8 <initlock>

  uartinit();
    8000048c:	00000097          	auipc	ra,0x0
    80000490:	340080e7          	jalr	832(ra) # 800007cc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000494:	00021797          	auipc	a5,0x21
    80000498:	bcc78793          	addi	a5,a5,-1076 # 80021060 <devsw>
    8000049c:	00000717          	auipc	a4,0x0
    800004a0:	c5070713          	addi	a4,a4,-944 # 800000ec <consoleread>
    800004a4:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004a6:	00000717          	auipc	a4,0x0
    800004aa:	dac70713          	addi	a4,a4,-596 # 80000252 <consolewrite>
    800004ae:	ef98                	sd	a4,24(a5)
}
    800004b0:	60a2                	ld	ra,8(sp)
    800004b2:	6402                	ld	s0,0(sp)
    800004b4:	0141                	addi	sp,sp,16
    800004b6:	8082                	ret

00000000800004b8 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004b8:	7179                	addi	sp,sp,-48
    800004ba:	f406                	sd	ra,40(sp)
    800004bc:	f022                	sd	s0,32(sp)
    800004be:	ec26                	sd	s1,24(sp)
    800004c0:	e84a                	sd	s2,16(sp)
    800004c2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004c4:	c219                	beqz	a2,800004ca <printint+0x12>
    800004c6:	08054663          	bltz	a0,80000552 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ca:	2501                	sext.w	a0,a0
    800004cc:	4881                	li	a7,0
    800004ce:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004d2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004d4:	2581                	sext.w	a1,a1
    800004d6:	0000a617          	auipc	a2,0xa
    800004da:	8c260613          	addi	a2,a2,-1854 # 80009d98 <digits>
    800004de:	883a                	mv	a6,a4
    800004e0:	2705                	addiw	a4,a4,1
    800004e2:	02b577bb          	remuw	a5,a0,a1
    800004e6:	1782                	slli	a5,a5,0x20
    800004e8:	9381                	srli	a5,a5,0x20
    800004ea:	97b2                	add	a5,a5,a2
    800004ec:	0007c783          	lbu	a5,0(a5)
    800004f0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004f4:	0005079b          	sext.w	a5,a0
    800004f8:	02b5553b          	divuw	a0,a0,a1
    800004fc:	0685                	addi	a3,a3,1
    800004fe:	feb7f0e3          	bgeu	a5,a1,800004de <printint+0x26>

  if(sign)
    80000502:	00088b63          	beqz	a7,80000518 <printint+0x60>
    buf[i++] = '-';
    80000506:	fe040793          	addi	a5,s0,-32
    8000050a:	973e                	add	a4,a4,a5
    8000050c:	02d00793          	li	a5,45
    80000510:	fef70823          	sb	a5,-16(a4)
    80000514:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000518:	02e05763          	blez	a4,80000546 <printint+0x8e>
    8000051c:	fd040793          	addi	a5,s0,-48
    80000520:	00e784b3          	add	s1,a5,a4
    80000524:	fff78913          	addi	s2,a5,-1
    80000528:	993a                	add	s2,s2,a4
    8000052a:	377d                	addiw	a4,a4,-1
    8000052c:	1702                	slli	a4,a4,0x20
    8000052e:	9301                	srli	a4,a4,0x20
    80000530:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000534:	fff4c503          	lbu	a0,-1(s1)
    80000538:	00000097          	auipc	ra,0x0
    8000053c:	ccc080e7          	jalr	-820(ra) # 80000204 <consputc>
  while(--i >= 0)
    80000540:	14fd                	addi	s1,s1,-1
    80000542:	ff2499e3          	bne	s1,s2,80000534 <printint+0x7c>
}
    80000546:	70a2                	ld	ra,40(sp)
    80000548:	7402                	ld	s0,32(sp)
    8000054a:	64e2                	ld	s1,24(sp)
    8000054c:	6942                	ld	s2,16(sp)
    8000054e:	6145                	addi	sp,sp,48
    80000550:	8082                	ret
    x = -xx;
    80000552:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000556:	4885                	li	a7,1
    x = -xx;
    80000558:	bf9d                	j	800004ce <printint+0x16>

000000008000055a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000055a:	1101                	addi	sp,sp,-32
    8000055c:	ec06                	sd	ra,24(sp)
    8000055e:	e822                	sd	s0,16(sp)
    80000560:	e426                	sd	s1,8(sp)
    80000562:	1000                	addi	s0,sp,32
    80000564:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000566:	00013797          	auipc	a5,0x13
    8000056a:	3607a523          	sw	zero,874(a5) # 800138d0 <pr+0x20>
  printf("PANIC: ");
    8000056e:	00009517          	auipc	a0,0x9
    80000572:	bb250513          	addi	a0,a0,-1102 # 80009120 <userret+0x90>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	03e080e7          	jalr	62(ra) # 800005b4 <printf>
  printf(s);
    8000057e:	8526                	mv	a0,s1
    80000580:	00000097          	auipc	ra,0x0
    80000584:	034080e7          	jalr	52(ra) # 800005b4 <printf>
  printf("\n");
    80000588:	00009517          	auipc	a0,0x9
    8000058c:	d0850513          	addi	a0,a0,-760 # 80009290 <userret+0x200>
    80000590:	00000097          	auipc	ra,0x0
    80000594:	024080e7          	jalr	36(ra) # 800005b4 <printf>
  printf("HINT: restart xv6 using 'make qemu-gdb', type 'b panic' (to set breakpoint in panic) in the gdb window, followed by 'c' (continue), and when the kernel hits the breakpoint, type 'bt' to get a backtrace\n");
    80000598:	00009517          	auipc	a0,0x9
    8000059c:	b9050513          	addi	a0,a0,-1136 # 80009128 <userret+0x98>
    800005a0:	00000097          	auipc	ra,0x0
    800005a4:	014080e7          	jalr	20(ra) # 800005b4 <printf>
  panicked = 1; // freeze other CPUs
    800005a8:	4785                	li	a5,1
    800005aa:	00029717          	auipc	a4,0x29
    800005ae:	dcf72b23          	sw	a5,-554(a4) # 80029380 <panicked>
  for(;;)
    800005b2:	a001                	j	800005b2 <panic+0x58>

00000000800005b4 <printf>:
{
    800005b4:	7131                	addi	sp,sp,-192
    800005b6:	fc86                	sd	ra,120(sp)
    800005b8:	f8a2                	sd	s0,112(sp)
    800005ba:	f4a6                	sd	s1,104(sp)
    800005bc:	f0ca                	sd	s2,96(sp)
    800005be:	ecce                	sd	s3,88(sp)
    800005c0:	e8d2                	sd	s4,80(sp)
    800005c2:	e4d6                	sd	s5,72(sp)
    800005c4:	e0da                	sd	s6,64(sp)
    800005c6:	fc5e                	sd	s7,56(sp)
    800005c8:	f862                	sd	s8,48(sp)
    800005ca:	f466                	sd	s9,40(sp)
    800005cc:	f06a                	sd	s10,32(sp)
    800005ce:	ec6e                	sd	s11,24(sp)
    800005d0:	0100                	addi	s0,sp,128
    800005d2:	8a2a                	mv	s4,a0
    800005d4:	e40c                	sd	a1,8(s0)
    800005d6:	e810                	sd	a2,16(s0)
    800005d8:	ec14                	sd	a3,24(s0)
    800005da:	f018                	sd	a4,32(s0)
    800005dc:	f41c                	sd	a5,40(s0)
    800005de:	03043823          	sd	a6,48(s0)
    800005e2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005e6:	00013d97          	auipc	s11,0x13
    800005ea:	2eadad83          	lw	s11,746(s11) # 800138d0 <pr+0x20>
  if(locking)
    800005ee:	020d9b63          	bnez	s11,80000624 <printf+0x70>
  if (fmt == 0)
    800005f2:	040a0263          	beqz	s4,80000636 <printf+0x82>
  va_start(ap, fmt);
    800005f6:	00840793          	addi	a5,s0,8
    800005fa:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005fe:	000a4503          	lbu	a0,0(s4)
    80000602:	16050263          	beqz	a0,80000766 <printf+0x1b2>
    80000606:	4481                	li	s1,0
    if(c != '%'){
    80000608:	02500a93          	li	s5,37
    switch(c){
    8000060c:	07000b13          	li	s6,112
  consputc('x');
    80000610:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000612:	00009b97          	auipc	s7,0x9
    80000616:	786b8b93          	addi	s7,s7,1926 # 80009d98 <digits>
    switch(c){
    8000061a:	07300c93          	li	s9,115
    8000061e:	06400c13          	li	s8,100
    80000622:	a82d                	j	8000065c <printf+0xa8>
    acquire(&pr.lock);
    80000624:	00013517          	auipc	a0,0x13
    80000628:	28c50513          	addi	a0,a0,652 # 800138b0 <pr>
    8000062c:	00000097          	auipc	ra,0x0
    80000630:	480080e7          	jalr	1152(ra) # 80000aac <acquire>
    80000634:	bf7d                	j	800005f2 <printf+0x3e>
    panic("null fmt");
    80000636:	00009517          	auipc	a0,0x9
    8000063a:	bca50513          	addi	a0,a0,-1078 # 80009200 <userret+0x170>
    8000063e:	00000097          	auipc	ra,0x0
    80000642:	f1c080e7          	jalr	-228(ra) # 8000055a <panic>
      consputc(c);
    80000646:	00000097          	auipc	ra,0x0
    8000064a:	bbe080e7          	jalr	-1090(ra) # 80000204 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000064e:	2485                	addiw	s1,s1,1
    80000650:	009a07b3          	add	a5,s4,s1
    80000654:	0007c503          	lbu	a0,0(a5)
    80000658:	10050763          	beqz	a0,80000766 <printf+0x1b2>
    if(c != '%'){
    8000065c:	ff5515e3          	bne	a0,s5,80000646 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000660:	2485                	addiw	s1,s1,1
    80000662:	009a07b3          	add	a5,s4,s1
    80000666:	0007c783          	lbu	a5,0(a5)
    8000066a:	0007891b          	sext.w	s2,a5
    if(c == 0)
    8000066e:	cfe5                	beqz	a5,80000766 <printf+0x1b2>
    switch(c){
    80000670:	05678a63          	beq	a5,s6,800006c4 <printf+0x110>
    80000674:	02fb7663          	bgeu	s6,a5,800006a0 <printf+0xec>
    80000678:	09978963          	beq	a5,s9,8000070a <printf+0x156>
    8000067c:	07800713          	li	a4,120
    80000680:	0ce79863          	bne	a5,a4,80000750 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000684:	f8843783          	ld	a5,-120(s0)
    80000688:	00878713          	addi	a4,a5,8
    8000068c:	f8e43423          	sd	a4,-120(s0)
    80000690:	4605                	li	a2,1
    80000692:	85ea                	mv	a1,s10
    80000694:	4388                	lw	a0,0(a5)
    80000696:	00000097          	auipc	ra,0x0
    8000069a:	e22080e7          	jalr	-478(ra) # 800004b8 <printint>
      break;
    8000069e:	bf45                	j	8000064e <printf+0x9a>
    switch(c){
    800006a0:	0b578263          	beq	a5,s5,80000744 <printf+0x190>
    800006a4:	0b879663          	bne	a5,s8,80000750 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    800006a8:	f8843783          	ld	a5,-120(s0)
    800006ac:	00878713          	addi	a4,a5,8
    800006b0:	f8e43423          	sd	a4,-120(s0)
    800006b4:	4605                	li	a2,1
    800006b6:	45a9                	li	a1,10
    800006b8:	4388                	lw	a0,0(a5)
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	dfe080e7          	jalr	-514(ra) # 800004b8 <printint>
      break;
    800006c2:	b771                	j	8000064e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006c4:	f8843783          	ld	a5,-120(s0)
    800006c8:	00878713          	addi	a4,a5,8
    800006cc:	f8e43423          	sd	a4,-120(s0)
    800006d0:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006d4:	03000513          	li	a0,48
    800006d8:	00000097          	auipc	ra,0x0
    800006dc:	b2c080e7          	jalr	-1236(ra) # 80000204 <consputc>
  consputc('x');
    800006e0:	07800513          	li	a0,120
    800006e4:	00000097          	auipc	ra,0x0
    800006e8:	b20080e7          	jalr	-1248(ra) # 80000204 <consputc>
    800006ec:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ee:	03c9d793          	srli	a5,s3,0x3c
    800006f2:	97de                	add	a5,a5,s7
    800006f4:	0007c503          	lbu	a0,0(a5)
    800006f8:	00000097          	auipc	ra,0x0
    800006fc:	b0c080e7          	jalr	-1268(ra) # 80000204 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000700:	0992                	slli	s3,s3,0x4
    80000702:	397d                	addiw	s2,s2,-1
    80000704:	fe0915e3          	bnez	s2,800006ee <printf+0x13a>
    80000708:	b799                	j	8000064e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    8000070a:	f8843783          	ld	a5,-120(s0)
    8000070e:	00878713          	addi	a4,a5,8
    80000712:	f8e43423          	sd	a4,-120(s0)
    80000716:	0007b903          	ld	s2,0(a5)
    8000071a:	00090e63          	beqz	s2,80000736 <printf+0x182>
      for(; *s; s++)
    8000071e:	00094503          	lbu	a0,0(s2)
    80000722:	d515                	beqz	a0,8000064e <printf+0x9a>
        consputc(*s);
    80000724:	00000097          	auipc	ra,0x0
    80000728:	ae0080e7          	jalr	-1312(ra) # 80000204 <consputc>
      for(; *s; s++)
    8000072c:	0905                	addi	s2,s2,1
    8000072e:	00094503          	lbu	a0,0(s2)
    80000732:	f96d                	bnez	a0,80000724 <printf+0x170>
    80000734:	bf29                	j	8000064e <printf+0x9a>
        s = "(null)";
    80000736:	00009917          	auipc	s2,0x9
    8000073a:	ac290913          	addi	s2,s2,-1342 # 800091f8 <userret+0x168>
      for(; *s; s++)
    8000073e:	02800513          	li	a0,40
    80000742:	b7cd                	j	80000724 <printf+0x170>
      consputc('%');
    80000744:	8556                	mv	a0,s5
    80000746:	00000097          	auipc	ra,0x0
    8000074a:	abe080e7          	jalr	-1346(ra) # 80000204 <consputc>
      break;
    8000074e:	b701                	j	8000064e <printf+0x9a>
      consputc('%');
    80000750:	8556                	mv	a0,s5
    80000752:	00000097          	auipc	ra,0x0
    80000756:	ab2080e7          	jalr	-1358(ra) # 80000204 <consputc>
      consputc(c);
    8000075a:	854a                	mv	a0,s2
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	aa8080e7          	jalr	-1368(ra) # 80000204 <consputc>
      break;
    80000764:	b5ed                	j	8000064e <printf+0x9a>
  if(locking)
    80000766:	020d9163          	bnez	s11,80000788 <printf+0x1d4>
}
    8000076a:	70e6                	ld	ra,120(sp)
    8000076c:	7446                	ld	s0,112(sp)
    8000076e:	74a6                	ld	s1,104(sp)
    80000770:	7906                	ld	s2,96(sp)
    80000772:	69e6                	ld	s3,88(sp)
    80000774:	6a46                	ld	s4,80(sp)
    80000776:	6aa6                	ld	s5,72(sp)
    80000778:	6b06                	ld	s6,64(sp)
    8000077a:	7be2                	ld	s7,56(sp)
    8000077c:	7c42                	ld	s8,48(sp)
    8000077e:	7ca2                	ld	s9,40(sp)
    80000780:	7d02                	ld	s10,32(sp)
    80000782:	6de2                	ld	s11,24(sp)
    80000784:	6129                	addi	sp,sp,192
    80000786:	8082                	ret
    release(&pr.lock);
    80000788:	00013517          	auipc	a0,0x13
    8000078c:	12850513          	addi	a0,a0,296 # 800138b0 <pr>
    80000790:	00000097          	auipc	ra,0x0
    80000794:	3ec080e7          	jalr	1004(ra) # 80000b7c <release>
}
    80000798:	bfc9                	j	8000076a <printf+0x1b6>

000000008000079a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000079a:	1101                	addi	sp,sp,-32
    8000079c:	ec06                	sd	ra,24(sp)
    8000079e:	e822                	sd	s0,16(sp)
    800007a0:	e426                	sd	s1,8(sp)
    800007a2:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007a4:	00013497          	auipc	s1,0x13
    800007a8:	10c48493          	addi	s1,s1,268 # 800138b0 <pr>
    800007ac:	00009597          	auipc	a1,0x9
    800007b0:	a6458593          	addi	a1,a1,-1436 # 80009210 <userret+0x180>
    800007b4:	8526                	mv	a0,s1
    800007b6:	00000097          	auipc	ra,0x0
    800007ba:	222080e7          	jalr	546(ra) # 800009d8 <initlock>
  pr.locking = 1;
    800007be:	4785                	li	a5,1
    800007c0:	d09c                	sw	a5,32(s1)
}
    800007c2:	60e2                	ld	ra,24(sp)
    800007c4:	6442                	ld	s0,16(sp)
    800007c6:	64a2                	ld	s1,8(sp)
    800007c8:	6105                	addi	sp,sp,32
    800007ca:	8082                	ret

00000000800007cc <uartinit>:
#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg, v) (*(Reg(reg)) = (v))

void
uartinit(void)
{
    800007cc:	1141                	addi	sp,sp,-16
    800007ce:	e422                	sd	s0,8(sp)
    800007d0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007d2:	100007b7          	lui	a5,0x10000
    800007d6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, 0x80);
    800007da:	f8000713          	li	a4,-128
    800007de:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007e2:	470d                	li	a4,3
    800007e4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007e8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, 0x03);
    800007ec:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, 0x07);
    800007f0:	471d                	li	a4,7
    800007f2:	00e78123          	sb	a4,2(a5)

  // enable receive interrupts.
  WriteReg(IER, 0x01);
    800007f6:	4705                	li	a4,1
    800007f8:	00e780a3          	sb	a4,1(a5)
}
    800007fc:	6422                	ld	s0,8(sp)
    800007fe:	0141                	addi	sp,sp,16
    80000800:	8082                	ret

0000000080000802 <uartputc>:

// write one output character to the UART.
void
uartputc(int c)
{
    80000802:	1141                	addi	sp,sp,-16
    80000804:	e422                	sd	s0,8(sp)
    80000806:	0800                	addi	s0,sp,16
  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & (1 << 5)) == 0)
    80000808:	10000737          	lui	a4,0x10000
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0ff7f793          	andi	a5,a5,255
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dbf5                	beqz	a5,8000080c <uartputc+0xa>
    ;
  WriteReg(THR, c);
    8000081a:	0ff57513          	andi	a0,a0,255
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    80000826:	6422                	ld	s0,8(sp)
    80000828:	0141                	addi	sp,sp,16
    8000082a:	8082                	ret

000000008000082c <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000082c:	1141                	addi	sp,sp,-16
    8000082e:	e422                	sd	s0,8(sp)
    80000830:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000832:	100007b7          	lui	a5,0x10000
    80000836:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000083a:	8b85                	andi	a5,a5,1
    8000083c:	cb81                	beqz	a5,8000084c <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    8000083e:	100007b7          	lui	a5,0x10000
    80000842:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000846:	6422                	ld	s0,8(sp)
    80000848:	0141                	addi	sp,sp,16
    8000084a:	8082                	ret
    return -1;
    8000084c:	557d                	li	a0,-1
    8000084e:	bfe5                	j	80000846 <uartgetc+0x1a>

0000000080000850 <uartintr>:

// trap.c calls here when the uart interrupts.
void
uartintr(void)
{
    80000850:	1101                	addi	sp,sp,-32
    80000852:	ec06                	sd	ra,24(sp)
    80000854:	e822                	sd	s0,16(sp)
    80000856:	e426                	sd	s1,8(sp)
    80000858:	1000                	addi	s0,sp,32
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000085a:	54fd                	li	s1,-1
    int c = uartgetc();
    8000085c:	00000097          	auipc	ra,0x0
    80000860:	fd0080e7          	jalr	-48(ra) # 8000082c <uartgetc>
    if(c == -1)
    80000864:	00950763          	beq	a0,s1,80000872 <uartintr+0x22>
      break;
    consoleintr(c);
    80000868:	00000097          	auipc	ra,0x0
    8000086c:	a72080e7          	jalr	-1422(ra) # 800002da <consoleintr>
  while(1){
    80000870:	b7f5                	j	8000085c <uartintr+0xc>
  }
}
    80000872:	60e2                	ld	ra,24(sp)
    80000874:	6442                	ld	s0,16(sp)
    80000876:	64a2                	ld	s1,8(sp)
    80000878:	6105                	addi	sp,sp,32
    8000087a:	8082                	ret

000000008000087c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000087c:	1101                	addi	sp,sp,-32
    8000087e:	ec06                	sd	ra,24(sp)
    80000880:	e822                	sd	s0,16(sp)
    80000882:	e426                	sd	s1,8(sp)
    80000884:	e04a                	sd	s2,0(sp)
    80000886:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000888:	03451793          	slli	a5,a0,0x34
    8000088c:	ebb9                	bnez	a5,800008e2 <kfree+0x66>
    8000088e:	84aa                	mv	s1,a0
    80000890:	00029797          	auipc	a5,0x29
    80000894:	b3c78793          	addi	a5,a5,-1220 # 800293cc <end>
    80000898:	04f56563          	bltu	a0,a5,800008e2 <kfree+0x66>
    8000089c:	47c5                	li	a5,17
    8000089e:	07ee                	slli	a5,a5,0x1b
    800008a0:	04f57163          	bgeu	a0,a5,800008e2 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800008a4:	6605                	lui	a2,0x1
    800008a6:	4585                	li	a1,1
    800008a8:	00000097          	auipc	ra,0x0
    800008ac:	4d2080e7          	jalr	1234(ra) # 80000d7a <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    800008b0:	00013917          	auipc	s2,0x13
    800008b4:	02890913          	addi	s2,s2,40 # 800138d8 <kmem>
    800008b8:	854a                	mv	a0,s2
    800008ba:	00000097          	auipc	ra,0x0
    800008be:	1f2080e7          	jalr	498(ra) # 80000aac <acquire>
  r->next = kmem.freelist;
    800008c2:	02093783          	ld	a5,32(s2)
    800008c6:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800008c8:	02993023          	sd	s1,32(s2)
  release(&kmem.lock);
    800008cc:	854a                	mv	a0,s2
    800008ce:	00000097          	auipc	ra,0x0
    800008d2:	2ae080e7          	jalr	686(ra) # 80000b7c <release>
}
    800008d6:	60e2                	ld	ra,24(sp)
    800008d8:	6442                	ld	s0,16(sp)
    800008da:	64a2                	ld	s1,8(sp)
    800008dc:	6902                	ld	s2,0(sp)
    800008de:	6105                	addi	sp,sp,32
    800008e0:	8082                	ret
    panic("kfree");
    800008e2:	00009517          	auipc	a0,0x9
    800008e6:	93650513          	addi	a0,a0,-1738 # 80009218 <userret+0x188>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	c70080e7          	jalr	-912(ra) # 8000055a <panic>

00000000800008f2 <freerange>:
{
    800008f2:	7179                	addi	sp,sp,-48
    800008f4:	f406                	sd	ra,40(sp)
    800008f6:	f022                	sd	s0,32(sp)
    800008f8:	ec26                	sd	s1,24(sp)
    800008fa:	e84a                	sd	s2,16(sp)
    800008fc:	e44e                	sd	s3,8(sp)
    800008fe:	e052                	sd	s4,0(sp)
    80000900:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000902:	6785                	lui	a5,0x1
    80000904:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000908:	94aa                	add	s1,s1,a0
    8000090a:	757d                	lui	a0,0xfffff
    8000090c:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    8000090e:	94be                	add	s1,s1,a5
    80000910:	0095ee63          	bltu	a1,s1,8000092c <freerange+0x3a>
    80000914:	892e                	mv	s2,a1
    kfree(p);
    80000916:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000918:	6985                	lui	s3,0x1
    kfree(p);
    8000091a:	01448533          	add	a0,s1,s4
    8000091e:	00000097          	auipc	ra,0x0
    80000922:	f5e080e7          	jalr	-162(ra) # 8000087c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000926:	94ce                	add	s1,s1,s3
    80000928:	fe9979e3          	bgeu	s2,s1,8000091a <freerange+0x28>
}
    8000092c:	70a2                	ld	ra,40(sp)
    8000092e:	7402                	ld	s0,32(sp)
    80000930:	64e2                	ld	s1,24(sp)
    80000932:	6942                	ld	s2,16(sp)
    80000934:	69a2                	ld	s3,8(sp)
    80000936:	6a02                	ld	s4,0(sp)
    80000938:	6145                	addi	sp,sp,48
    8000093a:	8082                	ret

000000008000093c <kinit>:
{
    8000093c:	1141                	addi	sp,sp,-16
    8000093e:	e406                	sd	ra,8(sp)
    80000940:	e022                	sd	s0,0(sp)
    80000942:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000944:	00009597          	auipc	a1,0x9
    80000948:	8dc58593          	addi	a1,a1,-1828 # 80009220 <userret+0x190>
    8000094c:	00013517          	auipc	a0,0x13
    80000950:	f8c50513          	addi	a0,a0,-116 # 800138d8 <kmem>
    80000954:	00000097          	auipc	ra,0x0
    80000958:	084080e7          	jalr	132(ra) # 800009d8 <initlock>
  freerange(end, (void*)PHYSTOP);
    8000095c:	45c5                	li	a1,17
    8000095e:	05ee                	slli	a1,a1,0x1b
    80000960:	00029517          	auipc	a0,0x29
    80000964:	a6c50513          	addi	a0,a0,-1428 # 800293cc <end>
    80000968:	00000097          	auipc	ra,0x0
    8000096c:	f8a080e7          	jalr	-118(ra) # 800008f2 <freerange>
}
    80000970:	60a2                	ld	ra,8(sp)
    80000972:	6402                	ld	s0,0(sp)
    80000974:	0141                	addi	sp,sp,16
    80000976:	8082                	ret

0000000080000978 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000978:	1101                	addi	sp,sp,-32
    8000097a:	ec06                	sd	ra,24(sp)
    8000097c:	e822                	sd	s0,16(sp)
    8000097e:	e426                	sd	s1,8(sp)
    80000980:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000982:	00013497          	auipc	s1,0x13
    80000986:	f5648493          	addi	s1,s1,-170 # 800138d8 <kmem>
    8000098a:	8526                	mv	a0,s1
    8000098c:	00000097          	auipc	ra,0x0
    80000990:	120080e7          	jalr	288(ra) # 80000aac <acquire>
  r = kmem.freelist;
    80000994:	7084                	ld	s1,32(s1)
  if(r)
    80000996:	c885                	beqz	s1,800009c6 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000998:	609c                	ld	a5,0(s1)
    8000099a:	00013517          	auipc	a0,0x13
    8000099e:	f3e50513          	addi	a0,a0,-194 # 800138d8 <kmem>
    800009a2:	f11c                	sd	a5,32(a0)
  release(&kmem.lock);
    800009a4:	00000097          	auipc	ra,0x0
    800009a8:	1d8080e7          	jalr	472(ra) # 80000b7c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    800009ac:	6605                	lui	a2,0x1
    800009ae:	4595                	li	a1,5
    800009b0:	8526                	mv	a0,s1
    800009b2:	00000097          	auipc	ra,0x0
    800009b6:	3c8080e7          	jalr	968(ra) # 80000d7a <memset>
  return (void*)r;
}
    800009ba:	8526                	mv	a0,s1
    800009bc:	60e2                	ld	ra,24(sp)
    800009be:	6442                	ld	s0,16(sp)
    800009c0:	64a2                	ld	s1,8(sp)
    800009c2:	6105                	addi	sp,sp,32
    800009c4:	8082                	ret
  release(&kmem.lock);
    800009c6:	00013517          	auipc	a0,0x13
    800009ca:	f1250513          	addi	a0,a0,-238 # 800138d8 <kmem>
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	1ae080e7          	jalr	430(ra) # 80000b7c <release>
  if(r)
    800009d6:	b7d5                	j	800009ba <kalloc+0x42>

00000000800009d8 <initlock>:

// assumes locks are not freed
void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
    800009d8:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800009da:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800009de:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    800009e2:	00052e23          	sw	zero,28(a0)
  lk->n = 0;
    800009e6:	00052c23          	sw	zero,24(a0)
  if(nlock >= NLOCK)
    800009ea:	00029797          	auipc	a5,0x29
    800009ee:	99a7a783          	lw	a5,-1638(a5) # 80029384 <nlock>
    800009f2:	3e700713          	li	a4,999
    800009f6:	02f74063          	blt	a4,a5,80000a16 <initlock+0x3e>
    panic("initlock");
  locks[nlock] = lk;
    800009fa:	00379693          	slli	a3,a5,0x3
    800009fe:	00013717          	auipc	a4,0x13
    80000a02:	f0270713          	addi	a4,a4,-254 # 80013900 <locks>
    80000a06:	9736                	add	a4,a4,a3
    80000a08:	e308                	sd	a0,0(a4)
  nlock++;
    80000a0a:	2785                	addiw	a5,a5,1
    80000a0c:	00029717          	auipc	a4,0x29
    80000a10:	96f72c23          	sw	a5,-1672(a4) # 80029384 <nlock>
    80000a14:	8082                	ret
{
    80000a16:	1141                	addi	sp,sp,-16
    80000a18:	e406                	sd	ra,8(sp)
    80000a1a:	e022                	sd	s0,0(sp)
    80000a1c:	0800                	addi	s0,sp,16
    panic("initlock");
    80000a1e:	00009517          	auipc	a0,0x9
    80000a22:	80a50513          	addi	a0,a0,-2038 # 80009228 <userret+0x198>
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	b34080e7          	jalr	-1228(ra) # 8000055a <panic>

0000000080000a2e <holding>:
// Must be called with interrupts off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000a2e:	411c                	lw	a5,0(a0)
    80000a30:	e399                	bnez	a5,80000a36 <holding+0x8>
    80000a32:	4501                	li	a0,0
  return r;
}
    80000a34:	8082                	ret
{
    80000a36:	1101                	addi	sp,sp,-32
    80000a38:	ec06                	sd	ra,24(sp)
    80000a3a:	e822                	sd	s0,16(sp)
    80000a3c:	e426                	sd	s1,8(sp)
    80000a3e:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000a40:	6904                	ld	s1,16(a0)
    80000a42:	00001097          	auipc	ra,0x1
    80000a46:	044080e7          	jalr	68(ra) # 80001a86 <mycpu>
    80000a4a:	40a48533          	sub	a0,s1,a0
    80000a4e:	00153513          	seqz	a0,a0
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret

0000000080000a5c <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000a5c:	1101                	addi	sp,sp,-32
    80000a5e:	ec06                	sd	ra,24(sp)
    80000a60:	e822                	sd	s0,16(sp)
    80000a62:	e426                	sd	s1,8(sp)
    80000a64:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a66:	100024f3          	csrr	s1,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000a6a:	8889                	andi	s1,s1,2
  int old = intr_get();
  if(old)
    80000a6c:	c491                	beqz	s1,80000a78 <push_off+0x1c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a6e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000a72:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000a74:	10079073          	csrw	sstatus,a5
    intr_off();
  if(mycpu()->noff == 0)
    80000a78:	00001097          	auipc	ra,0x1
    80000a7c:	00e080e7          	jalr	14(ra) # 80001a86 <mycpu>
    80000a80:	5d3c                	lw	a5,120(a0)
    80000a82:	cf89                	beqz	a5,80000a9c <push_off+0x40>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000a84:	00001097          	auipc	ra,0x1
    80000a88:	002080e7          	jalr	2(ra) # 80001a86 <mycpu>
    80000a8c:	5d3c                	lw	a5,120(a0)
    80000a8e:	2785                	addiw	a5,a5,1
    80000a90:	dd3c                	sw	a5,120(a0)
}
    80000a92:	60e2                	ld	ra,24(sp)
    80000a94:	6442                	ld	s0,16(sp)
    80000a96:	64a2                	ld	s1,8(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    mycpu()->intena = old;
    80000a9c:	00001097          	auipc	ra,0x1
    80000aa0:	fea080e7          	jalr	-22(ra) # 80001a86 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000aa4:	009034b3          	snez	s1,s1
    80000aa8:	dd64                	sw	s1,124(a0)
    80000aaa:	bfe9                	j	80000a84 <push_off+0x28>

0000000080000aac <acquire>:
{
    80000aac:	1101                	addi	sp,sp,-32
    80000aae:	ec06                	sd	ra,24(sp)
    80000ab0:	e822                	sd	s0,16(sp)
    80000ab2:	e426                	sd	s1,8(sp)
    80000ab4:	1000                	addi	s0,sp,32
    80000ab6:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000ab8:	00000097          	auipc	ra,0x0
    80000abc:	fa4080e7          	jalr	-92(ra) # 80000a5c <push_off>
  if(holding(lk))
    80000ac0:	8526                	mv	a0,s1
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	f6c080e7          	jalr	-148(ra) # 80000a2e <holding>
    80000aca:	e911                	bnez	a0,80000ade <acquire+0x32>
  __sync_fetch_and_add(&(lk->n), 1);
    80000acc:	4785                	li	a5,1
    80000ace:	01848713          	addi	a4,s1,24
    80000ad2:	0f50000f          	fence	iorw,ow
    80000ad6:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000ada:	4705                	li	a4,1
    80000adc:	a839                	j	80000afa <acquire+0x4e>
    panic("acquire");
    80000ade:	00008517          	auipc	a0,0x8
    80000ae2:	75a50513          	addi	a0,a0,1882 # 80009238 <userret+0x1a8>
    80000ae6:	00000097          	auipc	ra,0x0
    80000aea:	a74080e7          	jalr	-1420(ra) # 8000055a <panic>
     __sync_fetch_and_add(&lk->nts, 1);
    80000aee:	01c48793          	addi	a5,s1,28
    80000af2:	0f50000f          	fence	iorw,ow
    80000af6:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000afa:	87ba                	mv	a5,a4
    80000afc:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000b00:	2781                	sext.w	a5,a5
    80000b02:	f7f5                	bnez	a5,80000aee <acquire+0x42>
  __sync_synchronize();
    80000b04:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000b08:	00001097          	auipc	ra,0x1
    80000b0c:	f7e080e7          	jalr	-130(ra) # 80001a86 <mycpu>
    80000b10:	e888                	sd	a0,16(s1)
}
    80000b12:	60e2                	ld	ra,24(sp)
    80000b14:	6442                	ld	s0,16(sp)
    80000b16:	64a2                	ld	s1,8(sp)
    80000b18:	6105                	addi	sp,sp,32
    80000b1a:	8082                	ret

0000000080000b1c <pop_off>:

void
pop_off(void)
{
    80000b1c:	1141                	addi	sp,sp,-16
    80000b1e:	e406                	sd	ra,8(sp)
    80000b20:	e022                	sd	s0,0(sp)
    80000b22:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b24:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000b28:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000b2a:	eb8d                	bnez	a5,80000b5c <pop_off+0x40>
    panic("pop_off - interruptible");
  struct cpu *c = mycpu();
    80000b2c:	00001097          	auipc	ra,0x1
    80000b30:	f5a080e7          	jalr	-166(ra) # 80001a86 <mycpu>
  if(c->noff < 1)
    80000b34:	5d3c                	lw	a5,120(a0)
    80000b36:	02f05b63          	blez	a5,80000b6c <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000b3a:	37fd                	addiw	a5,a5,-1
    80000b3c:	0007871b          	sext.w	a4,a5
    80000b40:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000b42:	eb09                	bnez	a4,80000b54 <pop_off+0x38>
    80000b44:	5d7c                	lw	a5,124(a0)
    80000b46:	c799                	beqz	a5,80000b54 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b48:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000b4c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b50:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000b54:	60a2                	ld	ra,8(sp)
    80000b56:	6402                	ld	s0,0(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret
    panic("pop_off - interruptible");
    80000b5c:	00008517          	auipc	a0,0x8
    80000b60:	6e450513          	addi	a0,a0,1764 # 80009240 <userret+0x1b0>
    80000b64:	00000097          	auipc	ra,0x0
    80000b68:	9f6080e7          	jalr	-1546(ra) # 8000055a <panic>
    panic("pop_off");
    80000b6c:	00008517          	auipc	a0,0x8
    80000b70:	6ec50513          	addi	a0,a0,1772 # 80009258 <userret+0x1c8>
    80000b74:	00000097          	auipc	ra,0x0
    80000b78:	9e6080e7          	jalr	-1562(ra) # 8000055a <panic>

0000000080000b7c <release>:
{
    80000b7c:	1101                	addi	sp,sp,-32
    80000b7e:	ec06                	sd	ra,24(sp)
    80000b80:	e822                	sd	s0,16(sp)
    80000b82:	e426                	sd	s1,8(sp)
    80000b84:	1000                	addi	s0,sp,32
    80000b86:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000b88:	00000097          	auipc	ra,0x0
    80000b8c:	ea6080e7          	jalr	-346(ra) # 80000a2e <holding>
    80000b90:	c115                	beqz	a0,80000bb4 <release+0x38>
  lk->cpu = 0;
    80000b92:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000b96:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000b9a:	0f50000f          	fence	iorw,ow
    80000b9e:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000ba2:	00000097          	auipc	ra,0x0
    80000ba6:	f7a080e7          	jalr	-134(ra) # 80000b1c <pop_off>
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret
    panic("release");
    80000bb4:	00008517          	auipc	a0,0x8
    80000bb8:	6ac50513          	addi	a0,a0,1708 # 80009260 <userret+0x1d0>
    80000bbc:	00000097          	auipc	ra,0x0
    80000bc0:	99e080e7          	jalr	-1634(ra) # 8000055a <panic>

0000000080000bc4 <print_lock>:

void
print_lock(struct spinlock *lk)
{
  if(lk->n > 0) 
    80000bc4:	4d14                	lw	a3,24(a0)
    80000bc6:	e291                	bnez	a3,80000bca <print_lock+0x6>
    80000bc8:	8082                	ret
{
    80000bca:	1141                	addi	sp,sp,-16
    80000bcc:	e406                	sd	ra,8(sp)
    80000bce:	e022                	sd	s0,0(sp)
    80000bd0:	0800                	addi	s0,sp,16
    printf("lock: %s: #test-and-set %d #acquire() %d\n", lk->name, lk->nts, lk->n);
    80000bd2:	4d50                	lw	a2,28(a0)
    80000bd4:	650c                	ld	a1,8(a0)
    80000bd6:	00008517          	auipc	a0,0x8
    80000bda:	69250513          	addi	a0,a0,1682 # 80009268 <userret+0x1d8>
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	9d6080e7          	jalr	-1578(ra) # 800005b4 <printf>
}
    80000be6:	60a2                	ld	ra,8(sp)
    80000be8:	6402                	ld	s0,0(sp)
    80000bea:	0141                	addi	sp,sp,16
    80000bec:	8082                	ret

0000000080000bee <sys_ntas>:

uint64
sys_ntas(void)
{
    80000bee:	711d                	addi	sp,sp,-96
    80000bf0:	ec86                	sd	ra,88(sp)
    80000bf2:	e8a2                	sd	s0,80(sp)
    80000bf4:	e4a6                	sd	s1,72(sp)
    80000bf6:	e0ca                	sd	s2,64(sp)
    80000bf8:	fc4e                	sd	s3,56(sp)
    80000bfa:	f852                	sd	s4,48(sp)
    80000bfc:	f456                	sd	s5,40(sp)
    80000bfe:	f05a                	sd	s6,32(sp)
    80000c00:	ec5e                	sd	s7,24(sp)
    80000c02:	e862                	sd	s8,16(sp)
    80000c04:	1080                	addi	s0,sp,96
  int zero = 0;
    80000c06:	fa042623          	sw	zero,-84(s0)
  int tot = 0;
  
  if (argint(0, &zero) < 0) {
    80000c0a:	fac40593          	addi	a1,s0,-84
    80000c0e:	4501                	li	a0,0
    80000c10:	00002097          	auipc	ra,0x2
    80000c14:	fba080e7          	jalr	-70(ra) # 80002bca <argint>
    80000c18:	14054d63          	bltz	a0,80000d72 <sys_ntas+0x184>
    return -1;
  }
  if(zero == 0) {
    80000c1c:	fac42783          	lw	a5,-84(s0)
    80000c20:	e78d                	bnez	a5,80000c4a <sys_ntas+0x5c>
    80000c22:	00013797          	auipc	a5,0x13
    80000c26:	cde78793          	addi	a5,a5,-802 # 80013900 <locks>
    80000c2a:	00015697          	auipc	a3,0x15
    80000c2e:	c1668693          	addi	a3,a3,-1002 # 80015840 <pid_lock>
    for(int i = 0; i < NLOCK; i++) {
      if(locks[i] == 0)
    80000c32:	6398                	ld	a4,0(a5)
    80000c34:	14070163          	beqz	a4,80000d76 <sys_ntas+0x188>
        break;
      locks[i]->nts = 0;
    80000c38:	00072e23          	sw	zero,28(a4)
      locks[i]->n = 0;
    80000c3c:	00072c23          	sw	zero,24(a4)
    for(int i = 0; i < NLOCK; i++) {
    80000c40:	07a1                	addi	a5,a5,8
    80000c42:	fed798e3          	bne	a5,a3,80000c32 <sys_ntas+0x44>
    }
    return 0;
    80000c46:	4501                	li	a0,0
    80000c48:	aa09                	j	80000d5a <sys_ntas+0x16c>
  }

  printf("=== lock kmem/bcache stats\n");
    80000c4a:	00008517          	auipc	a0,0x8
    80000c4e:	64e50513          	addi	a0,a0,1614 # 80009298 <userret+0x208>
    80000c52:	00000097          	auipc	ra,0x0
    80000c56:	962080e7          	jalr	-1694(ra) # 800005b4 <printf>
  for(int i = 0; i < NLOCK; i++) {
    80000c5a:	00013b17          	auipc	s6,0x13
    80000c5e:	ca6b0b13          	addi	s6,s6,-858 # 80013900 <locks>
    80000c62:	00015b97          	auipc	s7,0x15
    80000c66:	bdeb8b93          	addi	s7,s7,-1058 # 80015840 <pid_lock>
  printf("=== lock kmem/bcache stats\n");
    80000c6a:	84da                	mv	s1,s6
  int tot = 0;
    80000c6c:	4981                	li	s3,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000c6e:	00008a17          	auipc	s4,0x8
    80000c72:	64aa0a13          	addi	s4,s4,1610 # 800092b8 <userret+0x228>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000c76:	00008c17          	auipc	s8,0x8
    80000c7a:	5aac0c13          	addi	s8,s8,1450 # 80009220 <userret+0x190>
    80000c7e:	a829                	j	80000c98 <sys_ntas+0xaa>
      tot += locks[i]->nts;
    80000c80:	00093503          	ld	a0,0(s2)
    80000c84:	4d5c                	lw	a5,28(a0)
    80000c86:	013789bb          	addw	s3,a5,s3
      print_lock(locks[i]);
    80000c8a:	00000097          	auipc	ra,0x0
    80000c8e:	f3a080e7          	jalr	-198(ra) # 80000bc4 <print_lock>
  for(int i = 0; i < NLOCK; i++) {
    80000c92:	04a1                	addi	s1,s1,8
    80000c94:	05748763          	beq	s1,s7,80000ce2 <sys_ntas+0xf4>
    if(locks[i] == 0)
    80000c98:	8926                	mv	s2,s1
    80000c9a:	609c                	ld	a5,0(s1)
    80000c9c:	c3b9                	beqz	a5,80000ce2 <sys_ntas+0xf4>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000c9e:	0087ba83          	ld	s5,8(a5)
    80000ca2:	8552                	mv	a0,s4
    80000ca4:	00000097          	auipc	ra,0x0
    80000ca8:	25e080e7          	jalr	606(ra) # 80000f02 <strlen>
    80000cac:	0005061b          	sext.w	a2,a0
    80000cb0:	85d2                	mv	a1,s4
    80000cb2:	8556                	mv	a0,s5
    80000cb4:	00000097          	auipc	ra,0x0
    80000cb8:	1a2080e7          	jalr	418(ra) # 80000e56 <strncmp>
    80000cbc:	d171                	beqz	a0,80000c80 <sys_ntas+0x92>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000cbe:	609c                	ld	a5,0(s1)
    80000cc0:	0087ba83          	ld	s5,8(a5)
    80000cc4:	8562                	mv	a0,s8
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	23c080e7          	jalr	572(ra) # 80000f02 <strlen>
    80000cce:	0005061b          	sext.w	a2,a0
    80000cd2:	85e2                	mv	a1,s8
    80000cd4:	8556                	mv	a0,s5
    80000cd6:	00000097          	auipc	ra,0x0
    80000cda:	180080e7          	jalr	384(ra) # 80000e56 <strncmp>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000cde:	f955                	bnez	a0,80000c92 <sys_ntas+0xa4>
    80000ce0:	b745                	j	80000c80 <sys_ntas+0x92>
    }
  }

  printf("=== top 5 contended locks:\n");
    80000ce2:	00008517          	auipc	a0,0x8
    80000ce6:	5de50513          	addi	a0,a0,1502 # 800092c0 <userret+0x230>
    80000cea:	00000097          	auipc	ra,0x0
    80000cee:	8ca080e7          	jalr	-1846(ra) # 800005b4 <printf>
    80000cf2:	4a15                	li	s4,5
  int last = 100000000;
    80000cf4:	05f5e537          	lui	a0,0x5f5e
    80000cf8:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t= 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
    80000cfc:	4a81                	li	s5,0
      if(locks[i] == 0)
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000cfe:	00013497          	auipc	s1,0x13
    80000d02:	c0248493          	addi	s1,s1,-1022 # 80013900 <locks>
    for(int i = 0; i < NLOCK; i++) {
    80000d06:	3e800913          	li	s2,1000
    80000d0a:	a091                	j	80000d4e <sys_ntas+0x160>
    80000d0c:	2705                	addiw	a4,a4,1
    80000d0e:	06a1                	addi	a3,a3,8
    80000d10:	03270063          	beq	a4,s2,80000d30 <sys_ntas+0x142>
      if(locks[i] == 0)
    80000d14:	629c                	ld	a5,0(a3)
    80000d16:	cf89                	beqz	a5,80000d30 <sys_ntas+0x142>
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000d18:	4fd0                	lw	a2,28(a5)
    80000d1a:	00359793          	slli	a5,a1,0x3
    80000d1e:	97a6                	add	a5,a5,s1
    80000d20:	639c                	ld	a5,0(a5)
    80000d22:	4fdc                	lw	a5,28(a5)
    80000d24:	fec7f4e3          	bgeu	a5,a2,80000d0c <sys_ntas+0x11e>
    80000d28:	fea672e3          	bgeu	a2,a0,80000d0c <sys_ntas+0x11e>
    80000d2c:	85ba                	mv	a1,a4
    80000d2e:	bff9                	j	80000d0c <sys_ntas+0x11e>
        top = i;
      }
    }
    print_lock(locks[top]);
    80000d30:	058e                	slli	a1,a1,0x3
    80000d32:	00b48bb3          	add	s7,s1,a1
    80000d36:	000bb503          	ld	a0,0(s7)
    80000d3a:	00000097          	auipc	ra,0x0
    80000d3e:	e8a080e7          	jalr	-374(ra) # 80000bc4 <print_lock>
    last = locks[top]->nts;
    80000d42:	000bb783          	ld	a5,0(s7)
    80000d46:	4fc8                	lw	a0,28(a5)
  for(int t= 0; t < 5; t++) {
    80000d48:	3a7d                	addiw	s4,s4,-1
    80000d4a:	000a0763          	beqz	s4,80000d58 <sys_ntas+0x16a>
  int tot = 0;
    80000d4e:	86da                	mv	a3,s6
    for(int i = 0; i < NLOCK; i++) {
    80000d50:	8756                	mv	a4,s5
    int top = 0;
    80000d52:	85d6                	mv	a1,s5
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000d54:	2501                	sext.w	a0,a0
    80000d56:	bf7d                	j	80000d14 <sys_ntas+0x126>
  }
  return tot;
    80000d58:	854e                	mv	a0,s3
}
    80000d5a:	60e6                	ld	ra,88(sp)
    80000d5c:	6446                	ld	s0,80(sp)
    80000d5e:	64a6                	ld	s1,72(sp)
    80000d60:	6906                	ld	s2,64(sp)
    80000d62:	79e2                	ld	s3,56(sp)
    80000d64:	7a42                	ld	s4,48(sp)
    80000d66:	7aa2                	ld	s5,40(sp)
    80000d68:	7b02                	ld	s6,32(sp)
    80000d6a:	6be2                	ld	s7,24(sp)
    80000d6c:	6c42                	ld	s8,16(sp)
    80000d6e:	6125                	addi	sp,sp,96
    80000d70:	8082                	ret
    return -1;
    80000d72:	557d                	li	a0,-1
    80000d74:	b7dd                	j	80000d5a <sys_ntas+0x16c>
    return 0;
    80000d76:	4501                	li	a0,0
    80000d78:	b7cd                	j	80000d5a <sys_ntas+0x16c>

0000000080000d7a <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d7a:	1141                	addi	sp,sp,-16
    80000d7c:	e422                	sd	s0,8(sp)
    80000d7e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d80:	ce09                	beqz	a2,80000d9a <memset+0x20>
    80000d82:	87aa                	mv	a5,a0
    80000d84:	fff6071b          	addiw	a4,a2,-1
    80000d88:	1702                	slli	a4,a4,0x20
    80000d8a:	9301                	srli	a4,a4,0x20
    80000d8c:	0705                	addi	a4,a4,1
    80000d8e:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000d90:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d94:	0785                	addi	a5,a5,1
    80000d96:	fee79de3          	bne	a5,a4,80000d90 <memset+0x16>
  }
  return dst;
}
    80000d9a:	6422                	ld	s0,8(sp)
    80000d9c:	0141                	addi	sp,sp,16
    80000d9e:	8082                	ret

0000000080000da0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000da0:	1141                	addi	sp,sp,-16
    80000da2:	e422                	sd	s0,8(sp)
    80000da4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000da6:	ca05                	beqz	a2,80000dd6 <memcmp+0x36>
    80000da8:	fff6069b          	addiw	a3,a2,-1
    80000dac:	1682                	slli	a3,a3,0x20
    80000dae:	9281                	srli	a3,a3,0x20
    80000db0:	0685                	addi	a3,a3,1
    80000db2:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000db4:	00054783          	lbu	a5,0(a0)
    80000db8:	0005c703          	lbu	a4,0(a1)
    80000dbc:	00e79863          	bne	a5,a4,80000dcc <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000dc0:	0505                	addi	a0,a0,1
    80000dc2:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000dc4:	fed518e3          	bne	a0,a3,80000db4 <memcmp+0x14>
  }

  return 0;
    80000dc8:	4501                	li	a0,0
    80000dca:	a019                	j	80000dd0 <memcmp+0x30>
      return *s1 - *s2;
    80000dcc:	40e7853b          	subw	a0,a5,a4
}
    80000dd0:	6422                	ld	s0,8(sp)
    80000dd2:	0141                	addi	sp,sp,16
    80000dd4:	8082                	ret
  return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	bfe5                	j	80000dd0 <memcmp+0x30>

0000000080000dda <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dda:	1141                	addi	sp,sp,-16
    80000ddc:	e422                	sd	s0,8(sp)
    80000dde:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000de0:	02a5e563          	bltu	a1,a0,80000e0a <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000de4:	fff6069b          	addiw	a3,a2,-1
    80000de8:	ce11                	beqz	a2,80000e04 <memmove+0x2a>
    80000dea:	1682                	slli	a3,a3,0x20
    80000dec:	9281                	srli	a3,a3,0x20
    80000dee:	0685                	addi	a3,a3,1
    80000df0:	96ae                	add	a3,a3,a1
    80000df2:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000df4:	0585                	addi	a1,a1,1
    80000df6:	0785                	addi	a5,a5,1
    80000df8:	fff5c703          	lbu	a4,-1(a1)
    80000dfc:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000e00:	fed59ae3          	bne	a1,a3,80000df4 <memmove+0x1a>

  return dst;
}
    80000e04:	6422                	ld	s0,8(sp)
    80000e06:	0141                	addi	sp,sp,16
    80000e08:	8082                	ret
  if(s < d && s + n > d){
    80000e0a:	02061713          	slli	a4,a2,0x20
    80000e0e:	9301                	srli	a4,a4,0x20
    80000e10:	00e587b3          	add	a5,a1,a4
    80000e14:	fcf578e3          	bgeu	a0,a5,80000de4 <memmove+0xa>
    d += n;
    80000e18:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000e1a:	fff6069b          	addiw	a3,a2,-1
    80000e1e:	d27d                	beqz	a2,80000e04 <memmove+0x2a>
    80000e20:	02069613          	slli	a2,a3,0x20
    80000e24:	9201                	srli	a2,a2,0x20
    80000e26:	fff64613          	not	a2,a2
    80000e2a:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e2c:	17fd                	addi	a5,a5,-1
    80000e2e:	177d                	addi	a4,a4,-1
    80000e30:	0007c683          	lbu	a3,0(a5)
    80000e34:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e38:	fec79ae3          	bne	a5,a2,80000e2c <memmove+0x52>
    80000e3c:	b7e1                	j	80000e04 <memmove+0x2a>

0000000080000e3e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e3e:	1141                	addi	sp,sp,-16
    80000e40:	e406                	sd	ra,8(sp)
    80000e42:	e022                	sd	s0,0(sp)
    80000e44:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e46:	00000097          	auipc	ra,0x0
    80000e4a:	f94080e7          	jalr	-108(ra) # 80000dda <memmove>
}
    80000e4e:	60a2                	ld	ra,8(sp)
    80000e50:	6402                	ld	s0,0(sp)
    80000e52:	0141                	addi	sp,sp,16
    80000e54:	8082                	ret

0000000080000e56 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e56:	1141                	addi	sp,sp,-16
    80000e58:	e422                	sd	s0,8(sp)
    80000e5a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e5c:	ce11                	beqz	a2,80000e78 <strncmp+0x22>
    80000e5e:	00054783          	lbu	a5,0(a0)
    80000e62:	cf89                	beqz	a5,80000e7c <strncmp+0x26>
    80000e64:	0005c703          	lbu	a4,0(a1)
    80000e68:	00f71a63          	bne	a4,a5,80000e7c <strncmp+0x26>
    n--, p++, q++;
    80000e6c:	367d                	addiw	a2,a2,-1
    80000e6e:	0505                	addi	a0,a0,1
    80000e70:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e72:	f675                	bnez	a2,80000e5e <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e74:	4501                	li	a0,0
    80000e76:	a809                	j	80000e88 <strncmp+0x32>
    80000e78:	4501                	li	a0,0
    80000e7a:	a039                	j	80000e88 <strncmp+0x32>
  if(n == 0)
    80000e7c:	ca09                	beqz	a2,80000e8e <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e7e:	00054503          	lbu	a0,0(a0)
    80000e82:	0005c783          	lbu	a5,0(a1)
    80000e86:	9d1d                	subw	a0,a0,a5
}
    80000e88:	6422                	ld	s0,8(sp)
    80000e8a:	0141                	addi	sp,sp,16
    80000e8c:	8082                	ret
    return 0;
    80000e8e:	4501                	li	a0,0
    80000e90:	bfe5                	j	80000e88 <strncmp+0x32>

0000000080000e92 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e92:	1141                	addi	sp,sp,-16
    80000e94:	e422                	sd	s0,8(sp)
    80000e96:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e98:	872a                	mv	a4,a0
    80000e9a:	8832                	mv	a6,a2
    80000e9c:	367d                	addiw	a2,a2,-1
    80000e9e:	01005963          	blez	a6,80000eb0 <strncpy+0x1e>
    80000ea2:	0705                	addi	a4,a4,1
    80000ea4:	0005c783          	lbu	a5,0(a1)
    80000ea8:	fef70fa3          	sb	a5,-1(a4)
    80000eac:	0585                	addi	a1,a1,1
    80000eae:	f7f5                	bnez	a5,80000e9a <strncpy+0x8>
    ;
  while(n-- > 0)
    80000eb0:	86ba                	mv	a3,a4
    80000eb2:	00c05c63          	blez	a2,80000eca <strncpy+0x38>
    *s++ = 0;
    80000eb6:	0685                	addi	a3,a3,1
    80000eb8:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000ebc:	fff6c793          	not	a5,a3
    80000ec0:	9fb9                	addw	a5,a5,a4
    80000ec2:	010787bb          	addw	a5,a5,a6
    80000ec6:	fef048e3          	bgtz	a5,80000eb6 <strncpy+0x24>
  return os;
}
    80000eca:	6422                	ld	s0,8(sp)
    80000ecc:	0141                	addi	sp,sp,16
    80000ece:	8082                	ret

0000000080000ed0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ed0:	1141                	addi	sp,sp,-16
    80000ed2:	e422                	sd	s0,8(sp)
    80000ed4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ed6:	02c05363          	blez	a2,80000efc <safestrcpy+0x2c>
    80000eda:	fff6069b          	addiw	a3,a2,-1
    80000ede:	1682                	slli	a3,a3,0x20
    80000ee0:	9281                	srli	a3,a3,0x20
    80000ee2:	96ae                	add	a3,a3,a1
    80000ee4:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ee6:	00d58963          	beq	a1,a3,80000ef8 <safestrcpy+0x28>
    80000eea:	0585                	addi	a1,a1,1
    80000eec:	0785                	addi	a5,a5,1
    80000eee:	fff5c703          	lbu	a4,-1(a1)
    80000ef2:	fee78fa3          	sb	a4,-1(a5)
    80000ef6:	fb65                	bnez	a4,80000ee6 <safestrcpy+0x16>
    ;
  *s = 0;
    80000ef8:	00078023          	sb	zero,0(a5)
  return os;
}
    80000efc:	6422                	ld	s0,8(sp)
    80000efe:	0141                	addi	sp,sp,16
    80000f00:	8082                	ret

0000000080000f02 <strlen>:

int
strlen(const char *s)
{
    80000f02:	1141                	addi	sp,sp,-16
    80000f04:	e422                	sd	s0,8(sp)
    80000f06:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f08:	00054783          	lbu	a5,0(a0)
    80000f0c:	cf91                	beqz	a5,80000f28 <strlen+0x26>
    80000f0e:	0505                	addi	a0,a0,1
    80000f10:	87aa                	mv	a5,a0
    80000f12:	4685                	li	a3,1
    80000f14:	9e89                	subw	a3,a3,a0
    80000f16:	00f6853b          	addw	a0,a3,a5
    80000f1a:	0785                	addi	a5,a5,1
    80000f1c:	fff7c703          	lbu	a4,-1(a5)
    80000f20:	fb7d                	bnez	a4,80000f16 <strlen+0x14>
    ;
  return n;
}
    80000f22:	6422                	ld	s0,8(sp)
    80000f24:	0141                	addi	sp,sp,16
    80000f26:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f28:	4501                	li	a0,0
    80000f2a:	bfe5                	j	80000f22 <strlen+0x20>

0000000080000f2c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f2c:	1141                	addi	sp,sp,-16
    80000f2e:	e406                	sd	ra,8(sp)
    80000f30:	e022                	sd	s0,0(sp)
    80000f32:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f34:	00001097          	auipc	ra,0x1
    80000f38:	b42080e7          	jalr	-1214(ra) # 80001a76 <cpuid>
    sockinit();
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f3c:	00028717          	auipc	a4,0x28
    80000f40:	44c70713          	addi	a4,a4,1100 # 80029388 <started>
  if(cpuid() == 0){
    80000f44:	c139                	beqz	a0,80000f8a <main+0x5e>
    while(started == 0)
    80000f46:	431c                	lw	a5,0(a4)
    80000f48:	2781                	sext.w	a5,a5
    80000f4a:	dff5                	beqz	a5,80000f46 <main+0x1a>
      ;
    __sync_synchronize();
    80000f4c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f50:	00001097          	auipc	ra,0x1
    80000f54:	b26080e7          	jalr	-1242(ra) # 80001a76 <cpuid>
    80000f58:	85aa                	mv	a1,a0
    80000f5a:	00008517          	auipc	a0,0x8
    80000f5e:	39e50513          	addi	a0,a0,926 # 800092f8 <userret+0x268>
    80000f62:	fffff097          	auipc	ra,0xfffff
    80000f66:	652080e7          	jalr	1618(ra) # 800005b4 <printf>
    kvminithart();    // turn on paging
    80000f6a:	00000097          	auipc	ra,0x0
    80000f6e:	1fa080e7          	jalr	506(ra) # 80001164 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f72:	00001097          	auipc	ra,0x1
    80000f76:	7d2080e7          	jalr	2002(ra) # 80002744 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f7a:	00005097          	auipc	ra,0x5
    80000f7e:	f7a080e7          	jalr	-134(ra) # 80005ef4 <plicinithart>
  }

  scheduler();        
    80000f82:	00001097          	auipc	ra,0x1
    80000f86:	ffa080e7          	jalr	-6(ra) # 80001f7c <scheduler>
    consoleinit();
    80000f8a:	fffff097          	auipc	ra,0xfffff
    80000f8e:	4e2080e7          	jalr	1250(ra) # 8000046c <consoleinit>
    printfinit();
    80000f92:	00000097          	auipc	ra,0x0
    80000f96:	808080e7          	jalr	-2040(ra) # 8000079a <printfinit>
    printf("\n");
    80000f9a:	00008517          	auipc	a0,0x8
    80000f9e:	2f650513          	addi	a0,a0,758 # 80009290 <userret+0x200>
    80000fa2:	fffff097          	auipc	ra,0xfffff
    80000fa6:	612080e7          	jalr	1554(ra) # 800005b4 <printf>
    printf("xv6 kernel is booting\n");
    80000faa:	00008517          	auipc	a0,0x8
    80000fae:	33650513          	addi	a0,a0,822 # 800092e0 <userret+0x250>
    80000fb2:	fffff097          	auipc	ra,0xfffff
    80000fb6:	602080e7          	jalr	1538(ra) # 800005b4 <printf>
    printf("\n");
    80000fba:	00008517          	auipc	a0,0x8
    80000fbe:	2d650513          	addi	a0,a0,726 # 80009290 <userret+0x200>
    80000fc2:	fffff097          	auipc	ra,0xfffff
    80000fc6:	5f2080e7          	jalr	1522(ra) # 800005b4 <printf>
    kinit();         // physical page allocator
    80000fca:	00000097          	auipc	ra,0x0
    80000fce:	972080e7          	jalr	-1678(ra) # 8000093c <kinit>
    kvminit();       // create kernel page table
    80000fd2:	00000097          	auipc	ra,0x0
    80000fd6:	31c080e7          	jalr	796(ra) # 800012ee <kvminit>
    kvminithart();   // turn on paging
    80000fda:	00000097          	auipc	ra,0x0
    80000fde:	18a080e7          	jalr	394(ra) # 80001164 <kvminithart>
    procinit();      // process table
    80000fe2:	00001097          	auipc	ra,0x1
    80000fe6:	9c4080e7          	jalr	-1596(ra) # 800019a6 <procinit>
    trapinit();      // trap vectors
    80000fea:	00001097          	auipc	ra,0x1
    80000fee:	732080e7          	jalr	1842(ra) # 8000271c <trapinit>
    trapinithart();  // install kernel trap vector
    80000ff2:	00001097          	auipc	ra,0x1
    80000ff6:	752080e7          	jalr	1874(ra) # 80002744 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ffa:	00005097          	auipc	ra,0x5
    80000ffe:	ed0080e7          	jalr	-304(ra) # 80005eca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001002:	00005097          	auipc	ra,0x5
    80001006:	ef2080e7          	jalr	-270(ra) # 80005ef4 <plicinithart>
    binit();         // buffer cache
    8000100a:	00002097          	auipc	ra,0x2
    8000100e:	ea2080e7          	jalr	-350(ra) # 80002eac <binit>
    iinit();         // inode cache
    80001012:	00002097          	auipc	ra,0x2
    80001016:	536080e7          	jalr	1334(ra) # 80003548 <iinit>
    fileinit();      // file table
    8000101a:	00003097          	auipc	ra,0x3
    8000101e:	5c0080e7          	jalr	1472(ra) # 800045da <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    80001022:	4501                	li	a0,0
    80001024:	00005097          	auipc	ra,0x5
    80001028:	ff8080e7          	jalr	-8(ra) # 8000601c <virtio_disk_init>
    pci_init();
    8000102c:	00006097          	auipc	ra,0x6
    80001030:	5b2080e7          	jalr	1458(ra) # 800075de <pci_init>
    sockinit();
    80001034:	00006097          	auipc	ra,0x6
    80001038:	166080e7          	jalr	358(ra) # 8000719a <sockinit>
    userinit();      // first user process
    8000103c:	00001097          	auipc	ra,0x1
    80001040:	cda080e7          	jalr	-806(ra) # 80001d16 <userinit>
    __sync_synchronize();
    80001044:	0ff0000f          	fence
    started = 1;
    80001048:	4785                	li	a5,1
    8000104a:	00028717          	auipc	a4,0x28
    8000104e:	32f72f23          	sw	a5,830(a4) # 80029388 <started>
    80001052:	bf05                	j	80000f82 <main+0x56>

0000000080001054 <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001054:	7139                	addi	sp,sp,-64
    80001056:	fc06                	sd	ra,56(sp)
    80001058:	f822                	sd	s0,48(sp)
    8000105a:	f426                	sd	s1,40(sp)
    8000105c:	f04a                	sd	s2,32(sp)
    8000105e:	ec4e                	sd	s3,24(sp)
    80001060:	e852                	sd	s4,16(sp)
    80001062:	e456                	sd	s5,8(sp)
    80001064:	e05a                	sd	s6,0(sp)
    80001066:	0080                	addi	s0,sp,64
    80001068:	84aa                	mv	s1,a0
    8000106a:	89ae                	mv	s3,a1
    8000106c:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000106e:	57fd                	li	a5,-1
    80001070:	83e9                	srli	a5,a5,0x1a
    80001072:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001074:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001076:	04b7f263          	bgeu	a5,a1,800010ba <walk+0x66>
    panic("walk");
    8000107a:	00008517          	auipc	a0,0x8
    8000107e:	29650513          	addi	a0,a0,662 # 80009310 <userret+0x280>
    80001082:	fffff097          	auipc	ra,0xfffff
    80001086:	4d8080e7          	jalr	1240(ra) # 8000055a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000108a:	060a8663          	beqz	s5,800010f6 <walk+0xa2>
    8000108e:	00000097          	auipc	ra,0x0
    80001092:	8ea080e7          	jalr	-1814(ra) # 80000978 <kalloc>
    80001096:	84aa                	mv	s1,a0
    80001098:	c529                	beqz	a0,800010e2 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000109a:	6605                	lui	a2,0x1
    8000109c:	4581                	li	a1,0
    8000109e:	00000097          	auipc	ra,0x0
    800010a2:	cdc080e7          	jalr	-804(ra) # 80000d7a <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010a6:	00c4d793          	srli	a5,s1,0xc
    800010aa:	07aa                	slli	a5,a5,0xa
    800010ac:	0017e793          	ori	a5,a5,1
    800010b0:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800010b4:	3a5d                	addiw	s4,s4,-9
    800010b6:	036a0063          	beq	s4,s6,800010d6 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010ba:	0149d933          	srl	s2,s3,s4
    800010be:	1ff97913          	andi	s2,s2,511
    800010c2:	090e                	slli	s2,s2,0x3
    800010c4:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010c6:	00093483          	ld	s1,0(s2)
    800010ca:	0014f793          	andi	a5,s1,1
    800010ce:	dfd5                	beqz	a5,8000108a <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010d0:	80a9                	srli	s1,s1,0xa
    800010d2:	04b2                	slli	s1,s1,0xc
    800010d4:	b7c5                	j	800010b4 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010d6:	00c9d513          	srli	a0,s3,0xc
    800010da:	1ff57513          	andi	a0,a0,511
    800010de:	050e                	slli	a0,a0,0x3
    800010e0:	9526                	add	a0,a0,s1
}
    800010e2:	70e2                	ld	ra,56(sp)
    800010e4:	7442                	ld	s0,48(sp)
    800010e6:	74a2                	ld	s1,40(sp)
    800010e8:	7902                	ld	s2,32(sp)
    800010ea:	69e2                	ld	s3,24(sp)
    800010ec:	6a42                	ld	s4,16(sp)
    800010ee:	6aa2                	ld	s5,8(sp)
    800010f0:	6b02                	ld	s6,0(sp)
    800010f2:	6121                	addi	sp,sp,64
    800010f4:	8082                	ret
        return 0;
    800010f6:	4501                	li	a0,0
    800010f8:	b7ed                	j	800010e2 <walk+0x8e>

00000000800010fa <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    800010fa:	7179                	addi	sp,sp,-48
    800010fc:	f406                	sd	ra,40(sp)
    800010fe:	f022                	sd	s0,32(sp)
    80001100:	ec26                	sd	s1,24(sp)
    80001102:	e84a                	sd	s2,16(sp)
    80001104:	e44e                	sd	s3,8(sp)
    80001106:	e052                	sd	s4,0(sp)
    80001108:	1800                	addi	s0,sp,48
    8000110a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000110c:	84aa                	mv	s1,a0
    8000110e:	6905                	lui	s2,0x1
    80001110:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001112:	4985                	li	s3,1
    80001114:	a821                	j	8000112c <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001116:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001118:	0532                	slli	a0,a0,0xc
    8000111a:	00000097          	auipc	ra,0x0
    8000111e:	fe0080e7          	jalr	-32(ra) # 800010fa <freewalk>
      pagetable[i] = 0;
    80001122:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001126:	04a1                	addi	s1,s1,8
    80001128:	03248163          	beq	s1,s2,8000114a <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000112c:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000112e:	00f57793          	andi	a5,a0,15
    80001132:	ff3782e3          	beq	a5,s3,80001116 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001136:	8905                	andi	a0,a0,1
    80001138:	d57d                	beqz	a0,80001126 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000113a:	00008517          	auipc	a0,0x8
    8000113e:	1de50513          	addi	a0,a0,478 # 80009318 <userret+0x288>
    80001142:	fffff097          	auipc	ra,0xfffff
    80001146:	418080e7          	jalr	1048(ra) # 8000055a <panic>
    }
  }
  kfree((void*)pagetable);
    8000114a:	8552                	mv	a0,s4
    8000114c:	fffff097          	auipc	ra,0xfffff
    80001150:	730080e7          	jalr	1840(ra) # 8000087c <kfree>
}
    80001154:	70a2                	ld	ra,40(sp)
    80001156:	7402                	ld	s0,32(sp)
    80001158:	64e2                	ld	s1,24(sp)
    8000115a:	6942                	ld	s2,16(sp)
    8000115c:	69a2                	ld	s3,8(sp)
    8000115e:	6a02                	ld	s4,0(sp)
    80001160:	6145                	addi	sp,sp,48
    80001162:	8082                	ret

0000000080001164 <kvminithart>:
{
    80001164:	1141                	addi	sp,sp,-16
    80001166:	e422                	sd	s0,8(sp)
    80001168:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000116a:	00028797          	auipc	a5,0x28
    8000116e:	2267b783          	ld	a5,550(a5) # 80029390 <kernel_pagetable>
    80001172:	83b1                	srli	a5,a5,0xc
    80001174:	577d                	li	a4,-1
    80001176:	177e                	slli	a4,a4,0x3f
    80001178:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000117a:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000117e:	12000073          	sfence.vma
}
    80001182:	6422                	ld	s0,8(sp)
    80001184:	0141                	addi	sp,sp,16
    80001186:	8082                	ret

0000000080001188 <walkaddr>:
  if(va >= MAXVA)
    80001188:	57fd                	li	a5,-1
    8000118a:	83e9                	srli	a5,a5,0x1a
    8000118c:	00b7f463          	bgeu	a5,a1,80001194 <walkaddr+0xc>
    return 0;
    80001190:	4501                	li	a0,0
}
    80001192:	8082                	ret
{
    80001194:	1141                	addi	sp,sp,-16
    80001196:	e406                	sd	ra,8(sp)
    80001198:	e022                	sd	s0,0(sp)
    8000119a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000119c:	4601                	li	a2,0
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	eb6080e7          	jalr	-330(ra) # 80001054 <walk>
  if(pte == 0)
    800011a6:	c105                	beqz	a0,800011c6 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800011a8:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800011aa:	0117f693          	andi	a3,a5,17
    800011ae:	4745                	li	a4,17
    return 0;
    800011b0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800011b2:	00e68663          	beq	a3,a4,800011be <walkaddr+0x36>
}
    800011b6:	60a2                	ld	ra,8(sp)
    800011b8:	6402                	ld	s0,0(sp)
    800011ba:	0141                	addi	sp,sp,16
    800011bc:	8082                	ret
  pa = PTE2PA(*pte);
    800011be:	00a7d513          	srli	a0,a5,0xa
    800011c2:	0532                	slli	a0,a0,0xc
  return pa;
    800011c4:	bfcd                	j	800011b6 <walkaddr+0x2e>
    return 0;
    800011c6:	4501                	li	a0,0
    800011c8:	b7fd                	j	800011b6 <walkaddr+0x2e>

00000000800011ca <kvmpa>:
{
    800011ca:	1101                	addi	sp,sp,-32
    800011cc:	ec06                	sd	ra,24(sp)
    800011ce:	e822                	sd	s0,16(sp)
    800011d0:	e426                	sd	s1,8(sp)
    800011d2:	1000                	addi	s0,sp,32
    800011d4:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800011d6:	03451493          	slli	s1,a0,0x34
  pte = walk(kernel_pagetable, va, 0);
    800011da:	4601                	li	a2,0
    800011dc:	00028517          	auipc	a0,0x28
    800011e0:	1b453503          	ld	a0,436(a0) # 80029390 <kernel_pagetable>
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	e70080e7          	jalr	-400(ra) # 80001054 <walk>
  if(pte == 0)
    800011ec:	cd11                	beqz	a0,80001208 <kvmpa+0x3e>
    800011ee:	90d1                	srli	s1,s1,0x34
  if((*pte & PTE_V) == 0)
    800011f0:	6108                	ld	a0,0(a0)
    800011f2:	00157793          	andi	a5,a0,1
    800011f6:	c38d                	beqz	a5,80001218 <kvmpa+0x4e>
  pa = PTE2PA(*pte);
    800011f8:	8129                	srli	a0,a0,0xa
    800011fa:	0532                	slli	a0,a0,0xc
}
    800011fc:	9526                	add	a0,a0,s1
    800011fe:	60e2                	ld	ra,24(sp)
    80001200:	6442                	ld	s0,16(sp)
    80001202:	64a2                	ld	s1,8(sp)
    80001204:	6105                	addi	sp,sp,32
    80001206:	8082                	ret
    panic("kvmpa");
    80001208:	00008517          	auipc	a0,0x8
    8000120c:	12050513          	addi	a0,a0,288 # 80009328 <userret+0x298>
    80001210:	fffff097          	auipc	ra,0xfffff
    80001214:	34a080e7          	jalr	842(ra) # 8000055a <panic>
    panic("kvmpa");
    80001218:	00008517          	auipc	a0,0x8
    8000121c:	11050513          	addi	a0,a0,272 # 80009328 <userret+0x298>
    80001220:	fffff097          	auipc	ra,0xfffff
    80001224:	33a080e7          	jalr	826(ra) # 8000055a <panic>

0000000080001228 <mappages>:
{
    80001228:	715d                	addi	sp,sp,-80
    8000122a:	e486                	sd	ra,72(sp)
    8000122c:	e0a2                	sd	s0,64(sp)
    8000122e:	fc26                	sd	s1,56(sp)
    80001230:	f84a                	sd	s2,48(sp)
    80001232:	f44e                	sd	s3,40(sp)
    80001234:	f052                	sd	s4,32(sp)
    80001236:	ec56                	sd	s5,24(sp)
    80001238:	e85a                	sd	s6,16(sp)
    8000123a:	e45e                	sd	s7,8(sp)
    8000123c:	0880                	addi	s0,sp,80
    8000123e:	8aaa                	mv	s5,a0
    80001240:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    80001242:	777d                	lui	a4,0xfffff
    80001244:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001248:	167d                	addi	a2,a2,-1
    8000124a:	00b609b3          	add	s3,a2,a1
    8000124e:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001252:	893e                	mv	s2,a5
    80001254:	40f68a33          	sub	s4,a3,a5
    a += PGSIZE;
    80001258:	6b85                	lui	s7,0x1
    8000125a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000125e:	4605                	li	a2,1
    80001260:	85ca                	mv	a1,s2
    80001262:	8556                	mv	a0,s5
    80001264:	00000097          	auipc	ra,0x0
    80001268:	df0080e7          	jalr	-528(ra) # 80001054 <walk>
    8000126c:	c51d                	beqz	a0,8000129a <mappages+0x72>
    if(*pte & PTE_V)
    8000126e:	611c                	ld	a5,0(a0)
    80001270:	8b85                	andi	a5,a5,1
    80001272:	ef81                	bnez	a5,8000128a <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001274:	80b1                	srli	s1,s1,0xc
    80001276:	04aa                	slli	s1,s1,0xa
    80001278:	0164e4b3          	or	s1,s1,s6
    8000127c:	0014e493          	ori	s1,s1,1
    80001280:	e104                	sd	s1,0(a0)
    if(a == last)
    80001282:	03390863          	beq	s2,s3,800012b2 <mappages+0x8a>
    a += PGSIZE;
    80001286:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001288:	bfc9                	j	8000125a <mappages+0x32>
      panic("remap");
    8000128a:	00008517          	auipc	a0,0x8
    8000128e:	0a650513          	addi	a0,a0,166 # 80009330 <userret+0x2a0>
    80001292:	fffff097          	auipc	ra,0xfffff
    80001296:	2c8080e7          	jalr	712(ra) # 8000055a <panic>
      return -1;
    8000129a:	557d                	li	a0,-1
}
    8000129c:	60a6                	ld	ra,72(sp)
    8000129e:	6406                	ld	s0,64(sp)
    800012a0:	74e2                	ld	s1,56(sp)
    800012a2:	7942                	ld	s2,48(sp)
    800012a4:	79a2                	ld	s3,40(sp)
    800012a6:	7a02                	ld	s4,32(sp)
    800012a8:	6ae2                	ld	s5,24(sp)
    800012aa:	6b42                	ld	s6,16(sp)
    800012ac:	6ba2                	ld	s7,8(sp)
    800012ae:	6161                	addi	sp,sp,80
    800012b0:	8082                	ret
  return 0;
    800012b2:	4501                	li	a0,0
    800012b4:	b7e5                	j	8000129c <mappages+0x74>

00000000800012b6 <kvmmap>:
{
    800012b6:	1141                	addi	sp,sp,-16
    800012b8:	e406                	sd	ra,8(sp)
    800012ba:	e022                	sd	s0,0(sp)
    800012bc:	0800                	addi	s0,sp,16
    800012be:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800012c0:	86ae                	mv	a3,a1
    800012c2:	85aa                	mv	a1,a0
    800012c4:	00028517          	auipc	a0,0x28
    800012c8:	0cc53503          	ld	a0,204(a0) # 80029390 <kernel_pagetable>
    800012cc:	00000097          	auipc	ra,0x0
    800012d0:	f5c080e7          	jalr	-164(ra) # 80001228 <mappages>
    800012d4:	e509                	bnez	a0,800012de <kvmmap+0x28>
}
    800012d6:	60a2                	ld	ra,8(sp)
    800012d8:	6402                	ld	s0,0(sp)
    800012da:	0141                	addi	sp,sp,16
    800012dc:	8082                	ret
    panic("kvmmap");
    800012de:	00008517          	auipc	a0,0x8
    800012e2:	05a50513          	addi	a0,a0,90 # 80009338 <userret+0x2a8>
    800012e6:	fffff097          	auipc	ra,0xfffff
    800012ea:	274080e7          	jalr	628(ra) # 8000055a <panic>

00000000800012ee <kvminit>:
{
    800012ee:	1101                	addi	sp,sp,-32
    800012f0:	ec06                	sd	ra,24(sp)
    800012f2:	e822                	sd	s0,16(sp)
    800012f4:	e426                	sd	s1,8(sp)
    800012f6:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800012f8:	fffff097          	auipc	ra,0xfffff
    800012fc:	680080e7          	jalr	1664(ra) # 80000978 <kalloc>
    80001300:	00028797          	auipc	a5,0x28
    80001304:	08a7b823          	sd	a0,144(a5) # 80029390 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001308:	6605                	lui	a2,0x1
    8000130a:	4581                	li	a1,0
    8000130c:	00000097          	auipc	ra,0x0
    80001310:	a6e080e7          	jalr	-1426(ra) # 80000d7a <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001314:	4699                	li	a3,6
    80001316:	6605                	lui	a2,0x1
    80001318:	100005b7          	lui	a1,0x10000
    8000131c:	10000537          	lui	a0,0x10000
    80001320:	00000097          	auipc	ra,0x0
    80001324:	f96080e7          	jalr	-106(ra) # 800012b6 <kvmmap>
  kvmmap(VIRTION(0), VIRTION(0), PGSIZE, PTE_R | PTE_W);
    80001328:	4699                	li	a3,6
    8000132a:	6605                	lui	a2,0x1
    8000132c:	100015b7          	lui	a1,0x10001
    80001330:	10001537          	lui	a0,0x10001
    80001334:	00000097          	auipc	ra,0x0
    80001338:	f82080e7          	jalr	-126(ra) # 800012b6 <kvmmap>
  kvmmap(VIRTION(1), VIRTION(1), PGSIZE, PTE_R | PTE_W);
    8000133c:	4699                	li	a3,6
    8000133e:	6605                	lui	a2,0x1
    80001340:	100025b7          	lui	a1,0x10002
    80001344:	10002537          	lui	a0,0x10002
    80001348:	00000097          	auipc	ra,0x0
    8000134c:	f6e080e7          	jalr	-146(ra) # 800012b6 <kvmmap>
  kvmmap(0x30000000L, 0x30000000L, 0x10000000, PTE_R | PTE_W);
    80001350:	4699                	li	a3,6
    80001352:	10000637          	lui	a2,0x10000
    80001356:	300005b7          	lui	a1,0x30000
    8000135a:	30000537          	lui	a0,0x30000
    8000135e:	00000097          	auipc	ra,0x0
    80001362:	f58080e7          	jalr	-168(ra) # 800012b6 <kvmmap>
  kvmmap(0x40000000L, 0x40000000L, 0x20000, PTE_R | PTE_W);
    80001366:	4699                	li	a3,6
    80001368:	00020637          	lui	a2,0x20
    8000136c:	400005b7          	lui	a1,0x40000
    80001370:	40000537          	lui	a0,0x40000
    80001374:	00000097          	auipc	ra,0x0
    80001378:	f42080e7          	jalr	-190(ra) # 800012b6 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    8000137c:	4699                	li	a3,6
    8000137e:	6641                	lui	a2,0x10
    80001380:	020005b7          	lui	a1,0x2000
    80001384:	02000537          	lui	a0,0x2000
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	f2e080e7          	jalr	-210(ra) # 800012b6 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001390:	4699                	li	a3,6
    80001392:	00400637          	lui	a2,0x400
    80001396:	0c0005b7          	lui	a1,0xc000
    8000139a:	0c000537          	lui	a0,0xc000
    8000139e:	00000097          	auipc	ra,0x0
    800013a2:	f18080e7          	jalr	-232(ra) # 800012b6 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800013a6:	00009497          	auipc	s1,0x9
    800013aa:	c5a48493          	addi	s1,s1,-934 # 8000a000 <initcode>
    800013ae:	46a9                	li	a3,10
    800013b0:	80009617          	auipc	a2,0x80009
    800013b4:	c5060613          	addi	a2,a2,-944 # a000 <_entry-0x7fff6000>
    800013b8:	4585                	li	a1,1
    800013ba:	05fe                	slli	a1,a1,0x1f
    800013bc:	852e                	mv	a0,a1
    800013be:	00000097          	auipc	ra,0x0
    800013c2:	ef8080e7          	jalr	-264(ra) # 800012b6 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800013c6:	4699                	li	a3,6
    800013c8:	4645                	li	a2,17
    800013ca:	066e                	slli	a2,a2,0x1b
    800013cc:	8e05                	sub	a2,a2,s1
    800013ce:	85a6                	mv	a1,s1
    800013d0:	8526                	mv	a0,s1
    800013d2:	00000097          	auipc	ra,0x0
    800013d6:	ee4080e7          	jalr	-284(ra) # 800012b6 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800013da:	46a9                	li	a3,10
    800013dc:	6605                	lui	a2,0x1
    800013de:	00008597          	auipc	a1,0x8
    800013e2:	c2258593          	addi	a1,a1,-990 # 80009000 <trampoline>
    800013e6:	04000537          	lui	a0,0x4000
    800013ea:	157d                	addi	a0,a0,-1
    800013ec:	0532                	slli	a0,a0,0xc
    800013ee:	00000097          	auipc	ra,0x0
    800013f2:	ec8080e7          	jalr	-312(ra) # 800012b6 <kvmmap>
}
    800013f6:	60e2                	ld	ra,24(sp)
    800013f8:	6442                	ld	s0,16(sp)
    800013fa:	64a2                	ld	s1,8(sp)
    800013fc:	6105                	addi	sp,sp,32
    800013fe:	8082                	ret

0000000080001400 <uvmunmap>:
{
    80001400:	715d                	addi	sp,sp,-80
    80001402:	e486                	sd	ra,72(sp)
    80001404:	e0a2                	sd	s0,64(sp)
    80001406:	fc26                	sd	s1,56(sp)
    80001408:	f84a                	sd	s2,48(sp)
    8000140a:	f44e                	sd	s3,40(sp)
    8000140c:	f052                	sd	s4,32(sp)
    8000140e:	ec56                	sd	s5,24(sp)
    80001410:	e85a                	sd	s6,16(sp)
    80001412:	e45e                	sd	s7,8(sp)
    80001414:	0880                	addi	s0,sp,80
    80001416:	8a2a                	mv	s4,a0
    80001418:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    8000141a:	77fd                	lui	a5,0xfffff
    8000141c:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    80001420:	167d                	addi	a2,a2,-1
    80001422:	00b609b3          	add	s3,a2,a1
    80001426:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    8000142a:	4b05                	li	s6,1
    a += PGSIZE;
    8000142c:	6b85                	lui	s7,0x1
    8000142e:	a8b1                	j	8000148a <uvmunmap+0x8a>
      panic("uvmunmap: walk");
    80001430:	00008517          	auipc	a0,0x8
    80001434:	f1050513          	addi	a0,a0,-240 # 80009340 <userret+0x2b0>
    80001438:	fffff097          	auipc	ra,0xfffff
    8000143c:	122080e7          	jalr	290(ra) # 8000055a <panic>
      printf("va=%p pte=%p\n", a, *pte);
    80001440:	862a                	mv	a2,a0
    80001442:	85ca                	mv	a1,s2
    80001444:	00008517          	auipc	a0,0x8
    80001448:	f0c50513          	addi	a0,a0,-244 # 80009350 <userret+0x2c0>
    8000144c:	fffff097          	auipc	ra,0xfffff
    80001450:	168080e7          	jalr	360(ra) # 800005b4 <printf>
      panic("uvmunmap: not mapped");
    80001454:	00008517          	auipc	a0,0x8
    80001458:	f0c50513          	addi	a0,a0,-244 # 80009360 <userret+0x2d0>
    8000145c:	fffff097          	auipc	ra,0xfffff
    80001460:	0fe080e7          	jalr	254(ra) # 8000055a <panic>
      panic("uvmunmap: not a leaf");
    80001464:	00008517          	auipc	a0,0x8
    80001468:	f1450513          	addi	a0,a0,-236 # 80009378 <userret+0x2e8>
    8000146c:	fffff097          	auipc	ra,0xfffff
    80001470:	0ee080e7          	jalr	238(ra) # 8000055a <panic>
      pa = PTE2PA(*pte);
    80001474:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001476:	0532                	slli	a0,a0,0xc
    80001478:	fffff097          	auipc	ra,0xfffff
    8000147c:	404080e7          	jalr	1028(ra) # 8000087c <kfree>
    *pte = 0;
    80001480:	0004b023          	sd	zero,0(s1)
    if(a == last)
    80001484:	03390763          	beq	s2,s3,800014b2 <uvmunmap+0xb2>
    a += PGSIZE;
    80001488:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    8000148a:	4601                	li	a2,0
    8000148c:	85ca                	mv	a1,s2
    8000148e:	8552                	mv	a0,s4
    80001490:	00000097          	auipc	ra,0x0
    80001494:	bc4080e7          	jalr	-1084(ra) # 80001054 <walk>
    80001498:	84aa                	mv	s1,a0
    8000149a:	d959                	beqz	a0,80001430 <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    8000149c:	6108                	ld	a0,0(a0)
    8000149e:	00157793          	andi	a5,a0,1
    800014a2:	dfd9                	beqz	a5,80001440 <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    800014a4:	3ff57793          	andi	a5,a0,1023
    800014a8:	fb678ee3          	beq	a5,s6,80001464 <uvmunmap+0x64>
    if(do_free){
    800014ac:	fc0a8ae3          	beqz	s5,80001480 <uvmunmap+0x80>
    800014b0:	b7d1                	j	80001474 <uvmunmap+0x74>
}
    800014b2:	60a6                	ld	ra,72(sp)
    800014b4:	6406                	ld	s0,64(sp)
    800014b6:	74e2                	ld	s1,56(sp)
    800014b8:	7942                	ld	s2,48(sp)
    800014ba:	79a2                	ld	s3,40(sp)
    800014bc:	7a02                	ld	s4,32(sp)
    800014be:	6ae2                	ld	s5,24(sp)
    800014c0:	6b42                	ld	s6,16(sp)
    800014c2:	6ba2                	ld	s7,8(sp)
    800014c4:	6161                	addi	sp,sp,80
    800014c6:	8082                	ret

00000000800014c8 <uvmcreate>:
{
    800014c8:	1101                	addi	sp,sp,-32
    800014ca:	ec06                	sd	ra,24(sp)
    800014cc:	e822                	sd	s0,16(sp)
    800014ce:	e426                	sd	s1,8(sp)
    800014d0:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    800014d2:	fffff097          	auipc	ra,0xfffff
    800014d6:	4a6080e7          	jalr	1190(ra) # 80000978 <kalloc>
  if(pagetable == 0)
    800014da:	cd11                	beqz	a0,800014f6 <uvmcreate+0x2e>
    800014dc:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    800014de:	6605                	lui	a2,0x1
    800014e0:	4581                	li	a1,0
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	898080e7          	jalr	-1896(ra) # 80000d7a <memset>
}
    800014ea:	8526                	mv	a0,s1
    800014ec:	60e2                	ld	ra,24(sp)
    800014ee:	6442                	ld	s0,16(sp)
    800014f0:	64a2                	ld	s1,8(sp)
    800014f2:	6105                	addi	sp,sp,32
    800014f4:	8082                	ret
    panic("uvmcreate: out of memory");
    800014f6:	00008517          	auipc	a0,0x8
    800014fa:	e9a50513          	addi	a0,a0,-358 # 80009390 <userret+0x300>
    800014fe:	fffff097          	auipc	ra,0xfffff
    80001502:	05c080e7          	jalr	92(ra) # 8000055a <panic>

0000000080001506 <uvminit>:
{
    80001506:	7179                	addi	sp,sp,-48
    80001508:	f406                	sd	ra,40(sp)
    8000150a:	f022                	sd	s0,32(sp)
    8000150c:	ec26                	sd	s1,24(sp)
    8000150e:	e84a                	sd	s2,16(sp)
    80001510:	e44e                	sd	s3,8(sp)
    80001512:	e052                	sd	s4,0(sp)
    80001514:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    80001516:	6785                	lui	a5,0x1
    80001518:	04f67863          	bgeu	a2,a5,80001568 <uvminit+0x62>
    8000151c:	8a2a                	mv	s4,a0
    8000151e:	89ae                	mv	s3,a1
    80001520:	84b2                	mv	s1,a2
  mem = kalloc();
    80001522:	fffff097          	auipc	ra,0xfffff
    80001526:	456080e7          	jalr	1110(ra) # 80000978 <kalloc>
    8000152a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000152c:	6605                	lui	a2,0x1
    8000152e:	4581                	li	a1,0
    80001530:	00000097          	auipc	ra,0x0
    80001534:	84a080e7          	jalr	-1974(ra) # 80000d7a <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001538:	4779                	li	a4,30
    8000153a:	86ca                	mv	a3,s2
    8000153c:	6605                	lui	a2,0x1
    8000153e:	4581                	li	a1,0
    80001540:	8552                	mv	a0,s4
    80001542:	00000097          	auipc	ra,0x0
    80001546:	ce6080e7          	jalr	-794(ra) # 80001228 <mappages>
  memmove(mem, src, sz);
    8000154a:	8626                	mv	a2,s1
    8000154c:	85ce                	mv	a1,s3
    8000154e:	854a                	mv	a0,s2
    80001550:	00000097          	auipc	ra,0x0
    80001554:	88a080e7          	jalr	-1910(ra) # 80000dda <memmove>
}
    80001558:	70a2                	ld	ra,40(sp)
    8000155a:	7402                	ld	s0,32(sp)
    8000155c:	64e2                	ld	s1,24(sp)
    8000155e:	6942                	ld	s2,16(sp)
    80001560:	69a2                	ld	s3,8(sp)
    80001562:	6a02                	ld	s4,0(sp)
    80001564:	6145                	addi	sp,sp,48
    80001566:	8082                	ret
    panic("inituvm: more than a page");
    80001568:	00008517          	auipc	a0,0x8
    8000156c:	e4850513          	addi	a0,a0,-440 # 800093b0 <userret+0x320>
    80001570:	fffff097          	auipc	ra,0xfffff
    80001574:	fea080e7          	jalr	-22(ra) # 8000055a <panic>

0000000080001578 <uvmdealloc>:
{
    80001578:	1101                	addi	sp,sp,-32
    8000157a:	ec06                	sd	ra,24(sp)
    8000157c:	e822                	sd	s0,16(sp)
    8000157e:	e426                	sd	s1,8(sp)
    80001580:	1000                	addi	s0,sp,32
    return oldsz;
    80001582:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001584:	00b67d63          	bgeu	a2,a1,8000159e <uvmdealloc+0x26>
    80001588:	84b2                	mv	s1,a2
  uint64 newup = PGROUNDUP(newsz);
    8000158a:	6785                	lui	a5,0x1
    8000158c:	17fd                	addi	a5,a5,-1
    8000158e:	00f60733          	add	a4,a2,a5
    80001592:	76fd                	lui	a3,0xfffff
    80001594:	8f75                	and	a4,a4,a3
  if(newup < PGROUNDUP(oldsz))
    80001596:	97ae                	add	a5,a5,a1
    80001598:	8ff5                	and	a5,a5,a3
    8000159a:	00f76863          	bltu	a4,a5,800015aa <uvmdealloc+0x32>
}
    8000159e:	8526                	mv	a0,s1
    800015a0:	60e2                	ld	ra,24(sp)
    800015a2:	6442                	ld	s0,16(sp)
    800015a4:	64a2                	ld	s1,8(sp)
    800015a6:	6105                	addi	sp,sp,32
    800015a8:	8082                	ret
    uvmunmap(pagetable, newup, oldsz - newup, 1);
    800015aa:	4685                	li	a3,1
    800015ac:	40e58633          	sub	a2,a1,a4
    800015b0:	85ba                	mv	a1,a4
    800015b2:	00000097          	auipc	ra,0x0
    800015b6:	e4e080e7          	jalr	-434(ra) # 80001400 <uvmunmap>
    800015ba:	b7d5                	j	8000159e <uvmdealloc+0x26>

00000000800015bc <uvmalloc>:
  if(newsz < oldsz)
    800015bc:	0ab66163          	bltu	a2,a1,8000165e <uvmalloc+0xa2>
{
    800015c0:	7139                	addi	sp,sp,-64
    800015c2:	fc06                	sd	ra,56(sp)
    800015c4:	f822                	sd	s0,48(sp)
    800015c6:	f426                	sd	s1,40(sp)
    800015c8:	f04a                	sd	s2,32(sp)
    800015ca:	ec4e                	sd	s3,24(sp)
    800015cc:	e852                	sd	s4,16(sp)
    800015ce:	e456                	sd	s5,8(sp)
    800015d0:	0080                	addi	s0,sp,64
    800015d2:	8aaa                	mv	s5,a0
    800015d4:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800015d6:	6985                	lui	s3,0x1
    800015d8:	19fd                	addi	s3,s3,-1
    800015da:	95ce                	add	a1,a1,s3
    800015dc:	79fd                	lui	s3,0xfffff
    800015de:	0135f9b3          	and	s3,a1,s3
  for(; a < newsz; a += PGSIZE){
    800015e2:	08c9f063          	bgeu	s3,a2,80001662 <uvmalloc+0xa6>
  a = oldsz;
    800015e6:	894e                	mv	s2,s3
    mem = kalloc();
    800015e8:	fffff097          	auipc	ra,0xfffff
    800015ec:	390080e7          	jalr	912(ra) # 80000978 <kalloc>
    800015f0:	84aa                	mv	s1,a0
    if(mem == 0){
    800015f2:	c51d                	beqz	a0,80001620 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800015f4:	6605                	lui	a2,0x1
    800015f6:	4581                	li	a1,0
    800015f8:	fffff097          	auipc	ra,0xfffff
    800015fc:	782080e7          	jalr	1922(ra) # 80000d7a <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001600:	4779                	li	a4,30
    80001602:	86a6                	mv	a3,s1
    80001604:	6605                	lui	a2,0x1
    80001606:	85ca                	mv	a1,s2
    80001608:	8556                	mv	a0,s5
    8000160a:	00000097          	auipc	ra,0x0
    8000160e:	c1e080e7          	jalr	-994(ra) # 80001228 <mappages>
    80001612:	e905                	bnez	a0,80001642 <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    80001614:	6785                	lui	a5,0x1
    80001616:	993e                	add	s2,s2,a5
    80001618:	fd4968e3          	bltu	s2,s4,800015e8 <uvmalloc+0x2c>
  return newsz;
    8000161c:	8552                	mv	a0,s4
    8000161e:	a809                	j	80001630 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001620:	864e                	mv	a2,s3
    80001622:	85ca                	mv	a1,s2
    80001624:	8556                	mv	a0,s5
    80001626:	00000097          	auipc	ra,0x0
    8000162a:	f52080e7          	jalr	-174(ra) # 80001578 <uvmdealloc>
      return 0;
    8000162e:	4501                	li	a0,0
}
    80001630:	70e2                	ld	ra,56(sp)
    80001632:	7442                	ld	s0,48(sp)
    80001634:	74a2                	ld	s1,40(sp)
    80001636:	7902                	ld	s2,32(sp)
    80001638:	69e2                	ld	s3,24(sp)
    8000163a:	6a42                	ld	s4,16(sp)
    8000163c:	6aa2                	ld	s5,8(sp)
    8000163e:	6121                	addi	sp,sp,64
    80001640:	8082                	ret
      kfree(mem);
    80001642:	8526                	mv	a0,s1
    80001644:	fffff097          	auipc	ra,0xfffff
    80001648:	238080e7          	jalr	568(ra) # 8000087c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000164c:	864e                	mv	a2,s3
    8000164e:	85ca                	mv	a1,s2
    80001650:	8556                	mv	a0,s5
    80001652:	00000097          	auipc	ra,0x0
    80001656:	f26080e7          	jalr	-218(ra) # 80001578 <uvmdealloc>
      return 0;
    8000165a:	4501                	li	a0,0
    8000165c:	bfd1                	j	80001630 <uvmalloc+0x74>
    return oldsz;
    8000165e:	852e                	mv	a0,a1
}
    80001660:	8082                	ret
  return newsz;
    80001662:	8532                	mv	a0,a2
    80001664:	b7f1                	j	80001630 <uvmalloc+0x74>

0000000080001666 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001666:	1101                	addi	sp,sp,-32
    80001668:	ec06                	sd	ra,24(sp)
    8000166a:	e822                	sd	s0,16(sp)
    8000166c:	e426                	sd	s1,8(sp)
    8000166e:	1000                	addi	s0,sp,32
    80001670:	84aa                	mv	s1,a0
    80001672:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    80001674:	4685                	li	a3,1
    80001676:	4581                	li	a1,0
    80001678:	00000097          	auipc	ra,0x0
    8000167c:	d88080e7          	jalr	-632(ra) # 80001400 <uvmunmap>
  freewalk(pagetable);
    80001680:	8526                	mv	a0,s1
    80001682:	00000097          	auipc	ra,0x0
    80001686:	a78080e7          	jalr	-1416(ra) # 800010fa <freewalk>
}
    8000168a:	60e2                	ld	ra,24(sp)
    8000168c:	6442                	ld	s0,16(sp)
    8000168e:	64a2                	ld	s1,8(sp)
    80001690:	6105                	addi	sp,sp,32
    80001692:	8082                	ret

0000000080001694 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001694:	c671                	beqz	a2,80001760 <uvmcopy+0xcc>
{
    80001696:	715d                	addi	sp,sp,-80
    80001698:	e486                	sd	ra,72(sp)
    8000169a:	e0a2                	sd	s0,64(sp)
    8000169c:	fc26                	sd	s1,56(sp)
    8000169e:	f84a                	sd	s2,48(sp)
    800016a0:	f44e                	sd	s3,40(sp)
    800016a2:	f052                	sd	s4,32(sp)
    800016a4:	ec56                	sd	s5,24(sp)
    800016a6:	e85a                	sd	s6,16(sp)
    800016a8:	e45e                	sd	s7,8(sp)
    800016aa:	0880                	addi	s0,sp,80
    800016ac:	8b2a                	mv	s6,a0
    800016ae:	8aae                	mv	s5,a1
    800016b0:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800016b2:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800016b4:	4601                	li	a2,0
    800016b6:	85ce                	mv	a1,s3
    800016b8:	855a                	mv	a0,s6
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	99a080e7          	jalr	-1638(ra) # 80001054 <walk>
    800016c2:	c531                	beqz	a0,8000170e <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800016c4:	6118                	ld	a4,0(a0)
    800016c6:	00177793          	andi	a5,a4,1
    800016ca:	cbb1                	beqz	a5,8000171e <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800016cc:	00a75593          	srli	a1,a4,0xa
    800016d0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800016d4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800016d8:	fffff097          	auipc	ra,0xfffff
    800016dc:	2a0080e7          	jalr	672(ra) # 80000978 <kalloc>
    800016e0:	892a                	mv	s2,a0
    800016e2:	c939                	beqz	a0,80001738 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800016e4:	6605                	lui	a2,0x1
    800016e6:	85de                	mv	a1,s7
    800016e8:	fffff097          	auipc	ra,0xfffff
    800016ec:	6f2080e7          	jalr	1778(ra) # 80000dda <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800016f0:	8726                	mv	a4,s1
    800016f2:	86ca                	mv	a3,s2
    800016f4:	6605                	lui	a2,0x1
    800016f6:	85ce                	mv	a1,s3
    800016f8:	8556                	mv	a0,s5
    800016fa:	00000097          	auipc	ra,0x0
    800016fe:	b2e080e7          	jalr	-1234(ra) # 80001228 <mappages>
    80001702:	e515                	bnez	a0,8000172e <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001704:	6785                	lui	a5,0x1
    80001706:	99be                	add	s3,s3,a5
    80001708:	fb49e6e3          	bltu	s3,s4,800016b4 <uvmcopy+0x20>
    8000170c:	a83d                	j	8000174a <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    8000170e:	00008517          	auipc	a0,0x8
    80001712:	cc250513          	addi	a0,a0,-830 # 800093d0 <userret+0x340>
    80001716:	fffff097          	auipc	ra,0xfffff
    8000171a:	e44080e7          	jalr	-444(ra) # 8000055a <panic>
      panic("uvmcopy: page not present");
    8000171e:	00008517          	auipc	a0,0x8
    80001722:	cd250513          	addi	a0,a0,-814 # 800093f0 <userret+0x360>
    80001726:	fffff097          	auipc	ra,0xfffff
    8000172a:	e34080e7          	jalr	-460(ra) # 8000055a <panic>
      kfree(mem);
    8000172e:	854a                	mv	a0,s2
    80001730:	fffff097          	auipc	ra,0xfffff
    80001734:	14c080e7          	jalr	332(ra) # 8000087c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    80001738:	4685                	li	a3,1
    8000173a:	864e                	mv	a2,s3
    8000173c:	4581                	li	a1,0
    8000173e:	8556                	mv	a0,s5
    80001740:	00000097          	auipc	ra,0x0
    80001744:	cc0080e7          	jalr	-832(ra) # 80001400 <uvmunmap>
  return -1;
    80001748:	557d                	li	a0,-1
}
    8000174a:	60a6                	ld	ra,72(sp)
    8000174c:	6406                	ld	s0,64(sp)
    8000174e:	74e2                	ld	s1,56(sp)
    80001750:	7942                	ld	s2,48(sp)
    80001752:	79a2                	ld	s3,40(sp)
    80001754:	7a02                	ld	s4,32(sp)
    80001756:	6ae2                	ld	s5,24(sp)
    80001758:	6b42                	ld	s6,16(sp)
    8000175a:	6ba2                	ld	s7,8(sp)
    8000175c:	6161                	addi	sp,sp,80
    8000175e:	8082                	ret
  return 0;
    80001760:	4501                	li	a0,0
}
    80001762:	8082                	ret

0000000080001764 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001764:	1141                	addi	sp,sp,-16
    80001766:	e406                	sd	ra,8(sp)
    80001768:	e022                	sd	s0,0(sp)
    8000176a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000176c:	4601                	li	a2,0
    8000176e:	00000097          	auipc	ra,0x0
    80001772:	8e6080e7          	jalr	-1818(ra) # 80001054 <walk>
  if(pte == 0)
    80001776:	c901                	beqz	a0,80001786 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001778:	611c                	ld	a5,0(a0)
    8000177a:	9bbd                	andi	a5,a5,-17
    8000177c:	e11c                	sd	a5,0(a0)
}
    8000177e:	60a2                	ld	ra,8(sp)
    80001780:	6402                	ld	s0,0(sp)
    80001782:	0141                	addi	sp,sp,16
    80001784:	8082                	ret
    panic("uvmclear");
    80001786:	00008517          	auipc	a0,0x8
    8000178a:	c8a50513          	addi	a0,a0,-886 # 80009410 <userret+0x380>
    8000178e:	fffff097          	auipc	ra,0xfffff
    80001792:	dcc080e7          	jalr	-564(ra) # 8000055a <panic>

0000000080001796 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001796:	c6bd                	beqz	a3,80001804 <copyout+0x6e>
{
    80001798:	715d                	addi	sp,sp,-80
    8000179a:	e486                	sd	ra,72(sp)
    8000179c:	e0a2                	sd	s0,64(sp)
    8000179e:	fc26                	sd	s1,56(sp)
    800017a0:	f84a                	sd	s2,48(sp)
    800017a2:	f44e                	sd	s3,40(sp)
    800017a4:	f052                	sd	s4,32(sp)
    800017a6:	ec56                	sd	s5,24(sp)
    800017a8:	e85a                	sd	s6,16(sp)
    800017aa:	e45e                	sd	s7,8(sp)
    800017ac:	e062                	sd	s8,0(sp)
    800017ae:	0880                	addi	s0,sp,80
    800017b0:	8b2a                	mv	s6,a0
    800017b2:	8c2e                	mv	s8,a1
    800017b4:	8a32                	mv	s4,a2
    800017b6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800017b8:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800017ba:	6a85                	lui	s5,0x1
    800017bc:	a015                	j	800017e0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017be:	9562                	add	a0,a0,s8
    800017c0:	0004861b          	sext.w	a2,s1
    800017c4:	85d2                	mv	a1,s4
    800017c6:	41250533          	sub	a0,a0,s2
    800017ca:	fffff097          	auipc	ra,0xfffff
    800017ce:	610080e7          	jalr	1552(ra) # 80000dda <memmove>

    len -= n;
    800017d2:	409989b3          	sub	s3,s3,s1
    src += n;
    800017d6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800017d8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017dc:	02098263          	beqz	s3,80001800 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800017e0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017e4:	85ca                	mv	a1,s2
    800017e6:	855a                	mv	a0,s6
    800017e8:	00000097          	auipc	ra,0x0
    800017ec:	9a0080e7          	jalr	-1632(ra) # 80001188 <walkaddr>
    if(pa0 == 0)
    800017f0:	cd01                	beqz	a0,80001808 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800017f2:	418904b3          	sub	s1,s2,s8
    800017f6:	94d6                	add	s1,s1,s5
    if(n > len)
    800017f8:	fc99f3e3          	bgeu	s3,s1,800017be <copyout+0x28>
    800017fc:	84ce                	mv	s1,s3
    800017fe:	b7c1                	j	800017be <copyout+0x28>
  }
  return 0;
    80001800:	4501                	li	a0,0
    80001802:	a021                	j	8000180a <copyout+0x74>
    80001804:	4501                	li	a0,0
}
    80001806:	8082                	ret
      return -1;
    80001808:	557d                	li	a0,-1
}
    8000180a:	60a6                	ld	ra,72(sp)
    8000180c:	6406                	ld	s0,64(sp)
    8000180e:	74e2                	ld	s1,56(sp)
    80001810:	7942                	ld	s2,48(sp)
    80001812:	79a2                	ld	s3,40(sp)
    80001814:	7a02                	ld	s4,32(sp)
    80001816:	6ae2                	ld	s5,24(sp)
    80001818:	6b42                	ld	s6,16(sp)
    8000181a:	6ba2                	ld	s7,8(sp)
    8000181c:	6c02                	ld	s8,0(sp)
    8000181e:	6161                	addi	sp,sp,80
    80001820:	8082                	ret

0000000080001822 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001822:	c6bd                	beqz	a3,80001890 <copyin+0x6e>
{
    80001824:	715d                	addi	sp,sp,-80
    80001826:	e486                	sd	ra,72(sp)
    80001828:	e0a2                	sd	s0,64(sp)
    8000182a:	fc26                	sd	s1,56(sp)
    8000182c:	f84a                	sd	s2,48(sp)
    8000182e:	f44e                	sd	s3,40(sp)
    80001830:	f052                	sd	s4,32(sp)
    80001832:	ec56                	sd	s5,24(sp)
    80001834:	e85a                	sd	s6,16(sp)
    80001836:	e45e                	sd	s7,8(sp)
    80001838:	e062                	sd	s8,0(sp)
    8000183a:	0880                	addi	s0,sp,80
    8000183c:	8b2a                	mv	s6,a0
    8000183e:	8a2e                	mv	s4,a1
    80001840:	8c32                	mv	s8,a2
    80001842:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001844:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001846:	6a85                	lui	s5,0x1
    80001848:	a015                	j	8000186c <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000184a:	9562                	add	a0,a0,s8
    8000184c:	0004861b          	sext.w	a2,s1
    80001850:	412505b3          	sub	a1,a0,s2
    80001854:	8552                	mv	a0,s4
    80001856:	fffff097          	auipc	ra,0xfffff
    8000185a:	584080e7          	jalr	1412(ra) # 80000dda <memmove>

    len -= n;
    8000185e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001862:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001864:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001868:	02098263          	beqz	s3,8000188c <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    8000186c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001870:	85ca                	mv	a1,s2
    80001872:	855a                	mv	a0,s6
    80001874:	00000097          	auipc	ra,0x0
    80001878:	914080e7          	jalr	-1772(ra) # 80001188 <walkaddr>
    if(pa0 == 0)
    8000187c:	cd01                	beqz	a0,80001894 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000187e:	418904b3          	sub	s1,s2,s8
    80001882:	94d6                	add	s1,s1,s5
    if(n > len)
    80001884:	fc99f3e3          	bgeu	s3,s1,8000184a <copyin+0x28>
    80001888:	84ce                	mv	s1,s3
    8000188a:	b7c1                	j	8000184a <copyin+0x28>
  }
  return 0;
    8000188c:	4501                	li	a0,0
    8000188e:	a021                	j	80001896 <copyin+0x74>
    80001890:	4501                	li	a0,0
}
    80001892:	8082                	ret
      return -1;
    80001894:	557d                	li	a0,-1
}
    80001896:	60a6                	ld	ra,72(sp)
    80001898:	6406                	ld	s0,64(sp)
    8000189a:	74e2                	ld	s1,56(sp)
    8000189c:	7942                	ld	s2,48(sp)
    8000189e:	79a2                	ld	s3,40(sp)
    800018a0:	7a02                	ld	s4,32(sp)
    800018a2:	6ae2                	ld	s5,24(sp)
    800018a4:	6b42                	ld	s6,16(sp)
    800018a6:	6ba2                	ld	s7,8(sp)
    800018a8:	6c02                	ld	s8,0(sp)
    800018aa:	6161                	addi	sp,sp,80
    800018ac:	8082                	ret

00000000800018ae <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800018ae:	c6c5                	beqz	a3,80001956 <copyinstr+0xa8>
{
    800018b0:	715d                	addi	sp,sp,-80
    800018b2:	e486                	sd	ra,72(sp)
    800018b4:	e0a2                	sd	s0,64(sp)
    800018b6:	fc26                	sd	s1,56(sp)
    800018b8:	f84a                	sd	s2,48(sp)
    800018ba:	f44e                	sd	s3,40(sp)
    800018bc:	f052                	sd	s4,32(sp)
    800018be:	ec56                	sd	s5,24(sp)
    800018c0:	e85a                	sd	s6,16(sp)
    800018c2:	e45e                	sd	s7,8(sp)
    800018c4:	0880                	addi	s0,sp,80
    800018c6:	8a2a                	mv	s4,a0
    800018c8:	8b2e                	mv	s6,a1
    800018ca:	8bb2                	mv	s7,a2
    800018cc:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800018ce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018d0:	6985                	lui	s3,0x1
    800018d2:	a035                	j	800018fe <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800018d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800018d8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800018da:	0017b793          	seqz	a5,a5
    800018de:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800018e2:	60a6                	ld	ra,72(sp)
    800018e4:	6406                	ld	s0,64(sp)
    800018e6:	74e2                	ld	s1,56(sp)
    800018e8:	7942                	ld	s2,48(sp)
    800018ea:	79a2                	ld	s3,40(sp)
    800018ec:	7a02                	ld	s4,32(sp)
    800018ee:	6ae2                	ld	s5,24(sp)
    800018f0:	6b42                	ld	s6,16(sp)
    800018f2:	6ba2                	ld	s7,8(sp)
    800018f4:	6161                	addi	sp,sp,80
    800018f6:	8082                	ret
    srcva = va0 + PGSIZE;
    800018f8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800018fc:	c8a9                	beqz	s1,8000194e <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800018fe:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001902:	85ca                	mv	a1,s2
    80001904:	8552                	mv	a0,s4
    80001906:	00000097          	auipc	ra,0x0
    8000190a:	882080e7          	jalr	-1918(ra) # 80001188 <walkaddr>
    if(pa0 == 0)
    8000190e:	c131                	beqz	a0,80001952 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001910:	41790833          	sub	a6,s2,s7
    80001914:	984e                	add	a6,a6,s3
    if(n > max)
    80001916:	0104f363          	bgeu	s1,a6,8000191c <copyinstr+0x6e>
    8000191a:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000191c:	955e                	add	a0,a0,s7
    8000191e:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001922:	fc080be3          	beqz	a6,800018f8 <copyinstr+0x4a>
    80001926:	985a                	add	a6,a6,s6
    80001928:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000192a:	41650633          	sub	a2,a0,s6
    8000192e:	14fd                	addi	s1,s1,-1
    80001930:	9b26                	add	s6,s6,s1
    80001932:	00f60733          	add	a4,a2,a5
    80001936:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd5c34>
    8000193a:	df49                	beqz	a4,800018d4 <copyinstr+0x26>
        *dst = *p;
    8000193c:	00e78023          	sb	a4,0(a5)
      --max;
    80001940:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001944:	0785                	addi	a5,a5,1
    while(n > 0){
    80001946:	ff0796e3          	bne	a5,a6,80001932 <copyinstr+0x84>
      dst++;
    8000194a:	8b42                	mv	s6,a6
    8000194c:	b775                	j	800018f8 <copyinstr+0x4a>
    8000194e:	4781                	li	a5,0
    80001950:	b769                	j	800018da <copyinstr+0x2c>
      return -1;
    80001952:	557d                	li	a0,-1
    80001954:	b779                	j	800018e2 <copyinstr+0x34>
  int got_null = 0;
    80001956:	4781                	li	a5,0
  if(got_null){
    80001958:	0017b793          	seqz	a5,a5
    8000195c:	40f00533          	neg	a0,a5
}
    80001960:	8082                	ret

0000000080001962 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001962:	1101                	addi	sp,sp,-32
    80001964:	ec06                	sd	ra,24(sp)
    80001966:	e822                	sd	s0,16(sp)
    80001968:	e426                	sd	s1,8(sp)
    8000196a:	1000                	addi	s0,sp,32
    8000196c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000196e:	fffff097          	auipc	ra,0xfffff
    80001972:	0c0080e7          	jalr	192(ra) # 80000a2e <holding>
    80001976:	c909                	beqz	a0,80001988 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001978:	789c                	ld	a5,48(s1)
    8000197a:	00978f63          	beq	a5,s1,80001998 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    8000197e:	60e2                	ld	ra,24(sp)
    80001980:	6442                	ld	s0,16(sp)
    80001982:	64a2                	ld	s1,8(sp)
    80001984:	6105                	addi	sp,sp,32
    80001986:	8082                	ret
    panic("wakeup1");
    80001988:	00008517          	auipc	a0,0x8
    8000198c:	a9850513          	addi	a0,a0,-1384 # 80009420 <userret+0x390>
    80001990:	fffff097          	auipc	ra,0xfffff
    80001994:	bca080e7          	jalr	-1078(ra) # 8000055a <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001998:	5098                	lw	a4,32(s1)
    8000199a:	4785                	li	a5,1
    8000199c:	fef711e3          	bne	a4,a5,8000197e <wakeup1+0x1c>
    p->state = RUNNABLE;
    800019a0:	4789                	li	a5,2
    800019a2:	d09c                	sw	a5,32(s1)
}
    800019a4:	bfe9                	j	8000197e <wakeup1+0x1c>

00000000800019a6 <procinit>:
{
    800019a6:	715d                	addi	sp,sp,-80
    800019a8:	e486                	sd	ra,72(sp)
    800019aa:	e0a2                	sd	s0,64(sp)
    800019ac:	fc26                	sd	s1,56(sp)
    800019ae:	f84a                	sd	s2,48(sp)
    800019b0:	f44e                	sd	s3,40(sp)
    800019b2:	f052                	sd	s4,32(sp)
    800019b4:	ec56                	sd	s5,24(sp)
    800019b6:	e85a                	sd	s6,16(sp)
    800019b8:	e45e                	sd	s7,8(sp)
    800019ba:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    800019bc:	00008597          	auipc	a1,0x8
    800019c0:	a6c58593          	addi	a1,a1,-1428 # 80009428 <userret+0x398>
    800019c4:	00014517          	auipc	a0,0x14
    800019c8:	e7c50513          	addi	a0,a0,-388 # 80015840 <pid_lock>
    800019cc:	fffff097          	auipc	ra,0xfffff
    800019d0:	00c080e7          	jalr	12(ra) # 800009d8 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019d4:	00014917          	auipc	s2,0x14
    800019d8:	28c90913          	addi	s2,s2,652 # 80015c60 <proc>
      initlock(&p->lock, "proc");
    800019dc:	00008a17          	auipc	s4,0x8
    800019e0:	a54a0a13          	addi	s4,s4,-1452 # 80009430 <userret+0x3a0>
      uint64 va = KSTACK((int) (p - proc));
    800019e4:	8bca                	mv	s7,s2
    800019e6:	00008b17          	auipc	s6,0x8
    800019ea:	5cab0b13          	addi	s6,s6,1482 # 80009fb0 <syscalls+0xc0>
    800019ee:	040009b7          	lui	s3,0x4000
    800019f2:	19fd                	addi	s3,s3,-1
    800019f4:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019f6:	00015a97          	auipc	s5,0x15
    800019fa:	0caa8a93          	addi	s5,s5,202 # 80016ac0 <tickslock>
      initlock(&p->lock, "proc");
    800019fe:	85d2                	mv	a1,s4
    80001a00:	854a                	mv	a0,s2
    80001a02:	fffff097          	auipc	ra,0xfffff
    80001a06:	fd6080e7          	jalr	-42(ra) # 800009d8 <initlock>
      char *pa = kalloc();
    80001a0a:	fffff097          	auipc	ra,0xfffff
    80001a0e:	f6e080e7          	jalr	-146(ra) # 80000978 <kalloc>
    80001a12:	85aa                	mv	a1,a0
      if(pa == 0)
    80001a14:	c929                	beqz	a0,80001a66 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001a16:	417904b3          	sub	s1,s2,s7
    80001a1a:	8491                	srai	s1,s1,0x4
    80001a1c:	000b3783          	ld	a5,0(s6)
    80001a20:	02f484b3          	mul	s1,s1,a5
    80001a24:	2485                	addiw	s1,s1,1
    80001a26:	00d4949b          	slliw	s1,s1,0xd
    80001a2a:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a2e:	4699                	li	a3,6
    80001a30:	6605                	lui	a2,0x1
    80001a32:	8526                	mv	a0,s1
    80001a34:	00000097          	auipc	ra,0x0
    80001a38:	882080e7          	jalr	-1918(ra) # 800012b6 <kvmmap>
      p->kstack = va;
    80001a3c:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a40:	17090913          	addi	s2,s2,368
    80001a44:	fb591de3          	bne	s2,s5,800019fe <procinit+0x58>
  kvminithart();
    80001a48:	fffff097          	auipc	ra,0xfffff
    80001a4c:	71c080e7          	jalr	1820(ra) # 80001164 <kvminithart>
}
    80001a50:	60a6                	ld	ra,72(sp)
    80001a52:	6406                	ld	s0,64(sp)
    80001a54:	74e2                	ld	s1,56(sp)
    80001a56:	7942                	ld	s2,48(sp)
    80001a58:	79a2                	ld	s3,40(sp)
    80001a5a:	7a02                	ld	s4,32(sp)
    80001a5c:	6ae2                	ld	s5,24(sp)
    80001a5e:	6b42                	ld	s6,16(sp)
    80001a60:	6ba2                	ld	s7,8(sp)
    80001a62:	6161                	addi	sp,sp,80
    80001a64:	8082                	ret
        panic("kalloc");
    80001a66:	00008517          	auipc	a0,0x8
    80001a6a:	9d250513          	addi	a0,a0,-1582 # 80009438 <userret+0x3a8>
    80001a6e:	fffff097          	auipc	ra,0xfffff
    80001a72:	aec080e7          	jalr	-1300(ra) # 8000055a <panic>

0000000080001a76 <cpuid>:
{
    80001a76:	1141                	addi	sp,sp,-16
    80001a78:	e422                	sd	s0,8(sp)
    80001a7a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a7c:	8512                	mv	a0,tp
}
    80001a7e:	2501                	sext.w	a0,a0
    80001a80:	6422                	ld	s0,8(sp)
    80001a82:	0141                	addi	sp,sp,16
    80001a84:	8082                	ret

0000000080001a86 <mycpu>:
mycpu(void) {
    80001a86:	1141                	addi	sp,sp,-16
    80001a88:	e422                	sd	s0,8(sp)
    80001a8a:	0800                	addi	s0,sp,16
    80001a8c:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a8e:	2781                	sext.w	a5,a5
    80001a90:	079e                	slli	a5,a5,0x7
}
    80001a92:	00014517          	auipc	a0,0x14
    80001a96:	dce50513          	addi	a0,a0,-562 # 80015860 <cpus>
    80001a9a:	953e                	add	a0,a0,a5
    80001a9c:	6422                	ld	s0,8(sp)
    80001a9e:	0141                	addi	sp,sp,16
    80001aa0:	8082                	ret

0000000080001aa2 <myproc>:
myproc(void) {
    80001aa2:	1101                	addi	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	1000                	addi	s0,sp,32
  push_off();
    80001aac:	fffff097          	auipc	ra,0xfffff
    80001ab0:	fb0080e7          	jalr	-80(ra) # 80000a5c <push_off>
    80001ab4:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001ab6:	2781                	sext.w	a5,a5
    80001ab8:	079e                	slli	a5,a5,0x7
    80001aba:	00014717          	auipc	a4,0x14
    80001abe:	d8670713          	addi	a4,a4,-634 # 80015840 <pid_lock>
    80001ac2:	97ba                	add	a5,a5,a4
    80001ac4:	7384                	ld	s1,32(a5)
  pop_off();
    80001ac6:	fffff097          	auipc	ra,0xfffff
    80001aca:	056080e7          	jalr	86(ra) # 80000b1c <pop_off>
}
    80001ace:	8526                	mv	a0,s1
    80001ad0:	60e2                	ld	ra,24(sp)
    80001ad2:	6442                	ld	s0,16(sp)
    80001ad4:	64a2                	ld	s1,8(sp)
    80001ad6:	6105                	addi	sp,sp,32
    80001ad8:	8082                	ret

0000000080001ada <forkret>:
{
    80001ada:	1141                	addi	sp,sp,-16
    80001adc:	e406                	sd	ra,8(sp)
    80001ade:	e022                	sd	s0,0(sp)
    80001ae0:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001ae2:	00000097          	auipc	ra,0x0
    80001ae6:	fc0080e7          	jalr	-64(ra) # 80001aa2 <myproc>
    80001aea:	fffff097          	auipc	ra,0xfffff
    80001aee:	092080e7          	jalr	146(ra) # 80000b7c <release>
  if (first) {
    80001af2:	00008797          	auipc	a5,0x8
    80001af6:	5467a783          	lw	a5,1350(a5) # 8000a038 <first.1788>
    80001afa:	eb89                	bnez	a5,80001b0c <forkret+0x32>
  usertrapret();
    80001afc:	00001097          	auipc	ra,0x1
    80001b00:	c60080e7          	jalr	-928(ra) # 8000275c <usertrapret>
}
    80001b04:	60a2                	ld	ra,8(sp)
    80001b06:	6402                	ld	s0,0(sp)
    80001b08:	0141                	addi	sp,sp,16
    80001b0a:	8082                	ret
    first = 0;
    80001b0c:	00008797          	auipc	a5,0x8
    80001b10:	5207a623          	sw	zero,1324(a5) # 8000a038 <first.1788>
    fsinit(minor(ROOTDEV));
    80001b14:	4501                	li	a0,0
    80001b16:	00002097          	auipc	ra,0x2
    80001b1a:	9b2080e7          	jalr	-1614(ra) # 800034c8 <fsinit>
    80001b1e:	bff9                	j	80001afc <forkret+0x22>

0000000080001b20 <allocpid>:
allocpid() {
    80001b20:	1101                	addi	sp,sp,-32
    80001b22:	ec06                	sd	ra,24(sp)
    80001b24:	e822                	sd	s0,16(sp)
    80001b26:	e426                	sd	s1,8(sp)
    80001b28:	e04a                	sd	s2,0(sp)
    80001b2a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b2c:	00014917          	auipc	s2,0x14
    80001b30:	d1490913          	addi	s2,s2,-748 # 80015840 <pid_lock>
    80001b34:	854a                	mv	a0,s2
    80001b36:	fffff097          	auipc	ra,0xfffff
    80001b3a:	f76080e7          	jalr	-138(ra) # 80000aac <acquire>
  pid = nextpid;
    80001b3e:	00008797          	auipc	a5,0x8
    80001b42:	4fe78793          	addi	a5,a5,1278 # 8000a03c <nextpid>
    80001b46:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b48:	0014871b          	addiw	a4,s1,1
    80001b4c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b4e:	854a                	mv	a0,s2
    80001b50:	fffff097          	auipc	ra,0xfffff
    80001b54:	02c080e7          	jalr	44(ra) # 80000b7c <release>
}
    80001b58:	8526                	mv	a0,s1
    80001b5a:	60e2                	ld	ra,24(sp)
    80001b5c:	6442                	ld	s0,16(sp)
    80001b5e:	64a2                	ld	s1,8(sp)
    80001b60:	6902                	ld	s2,0(sp)
    80001b62:	6105                	addi	sp,sp,32
    80001b64:	8082                	ret

0000000080001b66 <proc_pagetable>:
{
    80001b66:	1101                	addi	sp,sp,-32
    80001b68:	ec06                	sd	ra,24(sp)
    80001b6a:	e822                	sd	s0,16(sp)
    80001b6c:	e426                	sd	s1,8(sp)
    80001b6e:	e04a                	sd	s2,0(sp)
    80001b70:	1000                	addi	s0,sp,32
    80001b72:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b74:	00000097          	auipc	ra,0x0
    80001b78:	954080e7          	jalr	-1708(ra) # 800014c8 <uvmcreate>
    80001b7c:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b7e:	4729                	li	a4,10
    80001b80:	00007697          	auipc	a3,0x7
    80001b84:	48068693          	addi	a3,a3,1152 # 80009000 <trampoline>
    80001b88:	6605                	lui	a2,0x1
    80001b8a:	040005b7          	lui	a1,0x4000
    80001b8e:	15fd                	addi	a1,a1,-1
    80001b90:	05b2                	slli	a1,a1,0xc
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	696080e7          	jalr	1686(ra) # 80001228 <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b9a:	4719                	li	a4,6
    80001b9c:	06093683          	ld	a3,96(s2)
    80001ba0:	6605                	lui	a2,0x1
    80001ba2:	020005b7          	lui	a1,0x2000
    80001ba6:	15fd                	addi	a1,a1,-1
    80001ba8:	05b6                	slli	a1,a1,0xd
    80001baa:	8526                	mv	a0,s1
    80001bac:	fffff097          	auipc	ra,0xfffff
    80001bb0:	67c080e7          	jalr	1660(ra) # 80001228 <mappages>
}
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	60e2                	ld	ra,24(sp)
    80001bb8:	6442                	ld	s0,16(sp)
    80001bba:	64a2                	ld	s1,8(sp)
    80001bbc:	6902                	ld	s2,0(sp)
    80001bbe:	6105                	addi	sp,sp,32
    80001bc0:	8082                	ret

0000000080001bc2 <allocproc>:
{
    80001bc2:	1101                	addi	sp,sp,-32
    80001bc4:	ec06                	sd	ra,24(sp)
    80001bc6:	e822                	sd	s0,16(sp)
    80001bc8:	e426                	sd	s1,8(sp)
    80001bca:	e04a                	sd	s2,0(sp)
    80001bcc:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bce:	00014497          	auipc	s1,0x14
    80001bd2:	09248493          	addi	s1,s1,146 # 80015c60 <proc>
    80001bd6:	00015917          	auipc	s2,0x15
    80001bda:	eea90913          	addi	s2,s2,-278 # 80016ac0 <tickslock>
    acquire(&p->lock);
    80001bde:	8526                	mv	a0,s1
    80001be0:	fffff097          	auipc	ra,0xfffff
    80001be4:	ecc080e7          	jalr	-308(ra) # 80000aac <acquire>
    if(p->state == UNUSED) {
    80001be8:	509c                	lw	a5,32(s1)
    80001bea:	c395                	beqz	a5,80001c0e <allocproc+0x4c>
      release(&p->lock);
    80001bec:	8526                	mv	a0,s1
    80001bee:	fffff097          	auipc	ra,0xfffff
    80001bf2:	f8e080e7          	jalr	-114(ra) # 80000b7c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bf6:	17048493          	addi	s1,s1,368
    80001bfa:	ff2492e3          	bne	s1,s2,80001bde <allocproc+0x1c>
  return 0;
    80001bfe:	4481                	li	s1,0
}
    80001c00:	8526                	mv	a0,s1
    80001c02:	60e2                	ld	ra,24(sp)
    80001c04:	6442                	ld	s0,16(sp)
    80001c06:	64a2                	ld	s1,8(sp)
    80001c08:	6902                	ld	s2,0(sp)
    80001c0a:	6105                	addi	sp,sp,32
    80001c0c:	8082                	ret
  p->pid = allocpid();
    80001c0e:	00000097          	auipc	ra,0x0
    80001c12:	f12080e7          	jalr	-238(ra) # 80001b20 <allocpid>
    80001c16:	c0a8                	sw	a0,64(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    80001c18:	fffff097          	auipc	ra,0xfffff
    80001c1c:	d60080e7          	jalr	-672(ra) # 80000978 <kalloc>
    80001c20:	892a                	mv	s2,a0
    80001c22:	f0a8                	sd	a0,96(s1)
    80001c24:	c915                	beqz	a0,80001c58 <allocproc+0x96>
  p->pagetable = proc_pagetable(p);
    80001c26:	8526                	mv	a0,s1
    80001c28:	00000097          	auipc	ra,0x0
    80001c2c:	f3e080e7          	jalr	-194(ra) # 80001b66 <proc_pagetable>
    80001c30:	eca8                	sd	a0,88(s1)
  memset(&p->context, 0, sizeof p->context);
    80001c32:	07000613          	li	a2,112
    80001c36:	4581                	li	a1,0
    80001c38:	06848513          	addi	a0,s1,104
    80001c3c:	fffff097          	auipc	ra,0xfffff
    80001c40:	13e080e7          	jalr	318(ra) # 80000d7a <memset>
  p->context.ra = (uint64)forkret;
    80001c44:	00000797          	auipc	a5,0x0
    80001c48:	e9678793          	addi	a5,a5,-362 # 80001ada <forkret>
    80001c4c:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c4e:	64bc                	ld	a5,72(s1)
    80001c50:	6705                	lui	a4,0x1
    80001c52:	97ba                	add	a5,a5,a4
    80001c54:	f8bc                	sd	a5,112(s1)
  return p;
    80001c56:	b76d                	j	80001c00 <allocproc+0x3e>
    release(&p->lock);
    80001c58:	8526                	mv	a0,s1
    80001c5a:	fffff097          	auipc	ra,0xfffff
    80001c5e:	f22080e7          	jalr	-222(ra) # 80000b7c <release>
    return 0;
    80001c62:	84ca                	mv	s1,s2
    80001c64:	bf71                	j	80001c00 <allocproc+0x3e>

0000000080001c66 <proc_freepagetable>:
{
    80001c66:	1101                	addi	sp,sp,-32
    80001c68:	ec06                	sd	ra,24(sp)
    80001c6a:	e822                	sd	s0,16(sp)
    80001c6c:	e426                	sd	s1,8(sp)
    80001c6e:	e04a                	sd	s2,0(sp)
    80001c70:	1000                	addi	s0,sp,32
    80001c72:	84aa                	mv	s1,a0
    80001c74:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001c76:	4681                	li	a3,0
    80001c78:	6605                	lui	a2,0x1
    80001c7a:	040005b7          	lui	a1,0x4000
    80001c7e:	15fd                	addi	a1,a1,-1
    80001c80:	05b2                	slli	a1,a1,0xc
    80001c82:	fffff097          	auipc	ra,0xfffff
    80001c86:	77e080e7          	jalr	1918(ra) # 80001400 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001c8a:	4681                	li	a3,0
    80001c8c:	6605                	lui	a2,0x1
    80001c8e:	020005b7          	lui	a1,0x2000
    80001c92:	15fd                	addi	a1,a1,-1
    80001c94:	05b6                	slli	a1,a1,0xd
    80001c96:	8526                	mv	a0,s1
    80001c98:	fffff097          	auipc	ra,0xfffff
    80001c9c:	768080e7          	jalr	1896(ra) # 80001400 <uvmunmap>
  if(sz > 0)
    80001ca0:	00091863          	bnez	s2,80001cb0 <proc_freepagetable+0x4a>
}
    80001ca4:	60e2                	ld	ra,24(sp)
    80001ca6:	6442                	ld	s0,16(sp)
    80001ca8:	64a2                	ld	s1,8(sp)
    80001caa:	6902                	ld	s2,0(sp)
    80001cac:	6105                	addi	sp,sp,32
    80001cae:	8082                	ret
    uvmfree(pagetable, sz);
    80001cb0:	85ca                	mv	a1,s2
    80001cb2:	8526                	mv	a0,s1
    80001cb4:	00000097          	auipc	ra,0x0
    80001cb8:	9b2080e7          	jalr	-1614(ra) # 80001666 <uvmfree>
}
    80001cbc:	b7e5                	j	80001ca4 <proc_freepagetable+0x3e>

0000000080001cbe <freeproc>:
{
    80001cbe:	1101                	addi	sp,sp,-32
    80001cc0:	ec06                	sd	ra,24(sp)
    80001cc2:	e822                	sd	s0,16(sp)
    80001cc4:	e426                	sd	s1,8(sp)
    80001cc6:	1000                	addi	s0,sp,32
    80001cc8:	84aa                	mv	s1,a0
  if(p->tf)
    80001cca:	7128                	ld	a0,96(a0)
    80001ccc:	c509                	beqz	a0,80001cd6 <freeproc+0x18>
    kfree((void*)p->tf);
    80001cce:	fffff097          	auipc	ra,0xfffff
    80001cd2:	bae080e7          	jalr	-1106(ra) # 8000087c <kfree>
  p->tf = 0;
    80001cd6:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001cda:	6ca8                	ld	a0,88(s1)
    80001cdc:	c511                	beqz	a0,80001ce8 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001cde:	68ac                	ld	a1,80(s1)
    80001ce0:	00000097          	auipc	ra,0x0
    80001ce4:	f86080e7          	jalr	-122(ra) # 80001c66 <proc_freepagetable>
  p->pagetable = 0;
    80001ce8:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001cec:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001cf0:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001cf4:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001cf8:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001cfc:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001d00:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001d04:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001d08:	0204a023          	sw	zero,32(s1)
}
    80001d0c:	60e2                	ld	ra,24(sp)
    80001d0e:	6442                	ld	s0,16(sp)
    80001d10:	64a2                	ld	s1,8(sp)
    80001d12:	6105                	addi	sp,sp,32
    80001d14:	8082                	ret

0000000080001d16 <userinit>:
{
    80001d16:	1101                	addi	sp,sp,-32
    80001d18:	ec06                	sd	ra,24(sp)
    80001d1a:	e822                	sd	s0,16(sp)
    80001d1c:	e426                	sd	s1,8(sp)
    80001d1e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d20:	00000097          	auipc	ra,0x0
    80001d24:	ea2080e7          	jalr	-350(ra) # 80001bc2 <allocproc>
    80001d28:	84aa                	mv	s1,a0
  initproc = p;
    80001d2a:	00027797          	auipc	a5,0x27
    80001d2e:	66a7b723          	sd	a0,1646(a5) # 80029398 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d32:	03300613          	li	a2,51
    80001d36:	00008597          	auipc	a1,0x8
    80001d3a:	2ca58593          	addi	a1,a1,714 # 8000a000 <initcode>
    80001d3e:	6d28                	ld	a0,88(a0)
    80001d40:	fffff097          	auipc	ra,0xfffff
    80001d44:	7c6080e7          	jalr	1990(ra) # 80001506 <uvminit>
  p->sz = PGSIZE;
    80001d48:	6785                	lui	a5,0x1
    80001d4a:	e8bc                	sd	a5,80(s1)
  p->tf->epc = 0;      // user program counter
    80001d4c:	70b8                	ld	a4,96(s1)
    80001d4e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    80001d52:	70b8                	ld	a4,96(s1)
    80001d54:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d56:	4641                	li	a2,16
    80001d58:	00007597          	auipc	a1,0x7
    80001d5c:	6e858593          	addi	a1,a1,1768 # 80009440 <userret+0x3b0>
    80001d60:	16048513          	addi	a0,s1,352
    80001d64:	fffff097          	auipc	ra,0xfffff
    80001d68:	16c080e7          	jalr	364(ra) # 80000ed0 <safestrcpy>
  p->cwd = namei("/");
    80001d6c:	00007517          	auipc	a0,0x7
    80001d70:	6e450513          	addi	a0,a0,1764 # 80009450 <userret+0x3c0>
    80001d74:	00002097          	auipc	ra,0x2
    80001d78:	156080e7          	jalr	342(ra) # 80003eca <namei>
    80001d7c:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001d80:	4789                	li	a5,2
    80001d82:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80001d84:	8526                	mv	a0,s1
    80001d86:	fffff097          	auipc	ra,0xfffff
    80001d8a:	df6080e7          	jalr	-522(ra) # 80000b7c <release>
}
    80001d8e:	60e2                	ld	ra,24(sp)
    80001d90:	6442                	ld	s0,16(sp)
    80001d92:	64a2                	ld	s1,8(sp)
    80001d94:	6105                	addi	sp,sp,32
    80001d96:	8082                	ret

0000000080001d98 <growproc>:
{
    80001d98:	1101                	addi	sp,sp,-32
    80001d9a:	ec06                	sd	ra,24(sp)
    80001d9c:	e822                	sd	s0,16(sp)
    80001d9e:	e426                	sd	s1,8(sp)
    80001da0:	e04a                	sd	s2,0(sp)
    80001da2:	1000                	addi	s0,sp,32
    80001da4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001da6:	00000097          	auipc	ra,0x0
    80001daa:	cfc080e7          	jalr	-772(ra) # 80001aa2 <myproc>
    80001dae:	892a                	mv	s2,a0
  sz = p->sz;
    80001db0:	692c                	ld	a1,80(a0)
    80001db2:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001db6:	00904f63          	bgtz	s1,80001dd4 <growproc+0x3c>
  } else if(n < 0){
    80001dba:	0204cc63          	bltz	s1,80001df2 <growproc+0x5a>
  p->sz = sz;
    80001dbe:	1602                	slli	a2,a2,0x20
    80001dc0:	9201                	srli	a2,a2,0x20
    80001dc2:	04c93823          	sd	a2,80(s2)
  return 0;
    80001dc6:	4501                	li	a0,0
}
    80001dc8:	60e2                	ld	ra,24(sp)
    80001dca:	6442                	ld	s0,16(sp)
    80001dcc:	64a2                	ld	s1,8(sp)
    80001dce:	6902                	ld	s2,0(sp)
    80001dd0:	6105                	addi	sp,sp,32
    80001dd2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dd4:	9e25                	addw	a2,a2,s1
    80001dd6:	1602                	slli	a2,a2,0x20
    80001dd8:	9201                	srli	a2,a2,0x20
    80001dda:	1582                	slli	a1,a1,0x20
    80001ddc:	9181                	srli	a1,a1,0x20
    80001dde:	6d28                	ld	a0,88(a0)
    80001de0:	fffff097          	auipc	ra,0xfffff
    80001de4:	7dc080e7          	jalr	2012(ra) # 800015bc <uvmalloc>
    80001de8:	0005061b          	sext.w	a2,a0
    80001dec:	fa69                	bnez	a2,80001dbe <growproc+0x26>
      return -1;
    80001dee:	557d                	li	a0,-1
    80001df0:	bfe1                	j	80001dc8 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001df2:	9e25                	addw	a2,a2,s1
    80001df4:	1602                	slli	a2,a2,0x20
    80001df6:	9201                	srli	a2,a2,0x20
    80001df8:	1582                	slli	a1,a1,0x20
    80001dfa:	9181                	srli	a1,a1,0x20
    80001dfc:	6d28                	ld	a0,88(a0)
    80001dfe:	fffff097          	auipc	ra,0xfffff
    80001e02:	77a080e7          	jalr	1914(ra) # 80001578 <uvmdealloc>
    80001e06:	0005061b          	sext.w	a2,a0
    80001e0a:	bf55                	j	80001dbe <growproc+0x26>

0000000080001e0c <fork>:
{
    80001e0c:	7179                	addi	sp,sp,-48
    80001e0e:	f406                	sd	ra,40(sp)
    80001e10:	f022                	sd	s0,32(sp)
    80001e12:	ec26                	sd	s1,24(sp)
    80001e14:	e84a                	sd	s2,16(sp)
    80001e16:	e44e                	sd	s3,8(sp)
    80001e18:	e052                	sd	s4,0(sp)
    80001e1a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e1c:	00000097          	auipc	ra,0x0
    80001e20:	c86080e7          	jalr	-890(ra) # 80001aa2 <myproc>
    80001e24:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001e26:	00000097          	auipc	ra,0x0
    80001e2a:	d9c080e7          	jalr	-612(ra) # 80001bc2 <allocproc>
    80001e2e:	c175                	beqz	a0,80001f12 <fork+0x106>
    80001e30:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e32:	05093603          	ld	a2,80(s2)
    80001e36:	6d2c                	ld	a1,88(a0)
    80001e38:	05893503          	ld	a0,88(s2)
    80001e3c:	00000097          	auipc	ra,0x0
    80001e40:	858080e7          	jalr	-1960(ra) # 80001694 <uvmcopy>
    80001e44:	04054863          	bltz	a0,80001e94 <fork+0x88>
  np->sz = p->sz;
    80001e48:	05093783          	ld	a5,80(s2)
    80001e4c:	04f9b823          	sd	a5,80(s3) # 4000050 <_entry-0x7bffffb0>
  np->parent = p;
    80001e50:	0329b423          	sd	s2,40(s3)
  *(np->tf) = *(p->tf);
    80001e54:	06093683          	ld	a3,96(s2)
    80001e58:	87b6                	mv	a5,a3
    80001e5a:	0609b703          	ld	a4,96(s3)
    80001e5e:	12068693          	addi	a3,a3,288
    80001e62:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e66:	6788                	ld	a0,8(a5)
    80001e68:	6b8c                	ld	a1,16(a5)
    80001e6a:	6f90                	ld	a2,24(a5)
    80001e6c:	01073023          	sd	a6,0(a4)
    80001e70:	e708                	sd	a0,8(a4)
    80001e72:	eb0c                	sd	a1,16(a4)
    80001e74:	ef10                	sd	a2,24(a4)
    80001e76:	02078793          	addi	a5,a5,32
    80001e7a:	02070713          	addi	a4,a4,32
    80001e7e:	fed792e3          	bne	a5,a3,80001e62 <fork+0x56>
  np->tf->a0 = 0;
    80001e82:	0609b783          	ld	a5,96(s3)
    80001e86:	0607b823          	sd	zero,112(a5)
    80001e8a:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    80001e8e:	15800a13          	li	s4,344
    80001e92:	a03d                	j	80001ec0 <fork+0xb4>
    freeproc(np);
    80001e94:	854e                	mv	a0,s3
    80001e96:	00000097          	auipc	ra,0x0
    80001e9a:	e28080e7          	jalr	-472(ra) # 80001cbe <freeproc>
    release(&np->lock);
    80001e9e:	854e                	mv	a0,s3
    80001ea0:	fffff097          	auipc	ra,0xfffff
    80001ea4:	cdc080e7          	jalr	-804(ra) # 80000b7c <release>
    return -1;
    80001ea8:	54fd                	li	s1,-1
    80001eaa:	a899                	j	80001f00 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eac:	00002097          	auipc	ra,0x2
    80001eb0:	7c0080e7          	jalr	1984(ra) # 8000466c <filedup>
    80001eb4:	009987b3          	add	a5,s3,s1
    80001eb8:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001eba:	04a1                	addi	s1,s1,8
    80001ebc:	01448763          	beq	s1,s4,80001eca <fork+0xbe>
    if(p->ofile[i])
    80001ec0:	009907b3          	add	a5,s2,s1
    80001ec4:	6388                	ld	a0,0(a5)
    80001ec6:	f17d                	bnez	a0,80001eac <fork+0xa0>
    80001ec8:	bfcd                	j	80001eba <fork+0xae>
  np->cwd = idup(p->cwd);
    80001eca:	15893503          	ld	a0,344(s2)
    80001ece:	00002097          	auipc	ra,0x2
    80001ed2:	834080e7          	jalr	-1996(ra) # 80003702 <idup>
    80001ed6:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001eda:	4641                	li	a2,16
    80001edc:	16090593          	addi	a1,s2,352
    80001ee0:	16098513          	addi	a0,s3,352
    80001ee4:	fffff097          	auipc	ra,0xfffff
    80001ee8:	fec080e7          	jalr	-20(ra) # 80000ed0 <safestrcpy>
  pid = np->pid;
    80001eec:	0409a483          	lw	s1,64(s3)
  np->state = RUNNABLE;
    80001ef0:	4789                	li	a5,2
    80001ef2:	02f9a023          	sw	a5,32(s3)
  release(&np->lock);
    80001ef6:	854e                	mv	a0,s3
    80001ef8:	fffff097          	auipc	ra,0xfffff
    80001efc:	c84080e7          	jalr	-892(ra) # 80000b7c <release>
}
    80001f00:	8526                	mv	a0,s1
    80001f02:	70a2                	ld	ra,40(sp)
    80001f04:	7402                	ld	s0,32(sp)
    80001f06:	64e2                	ld	s1,24(sp)
    80001f08:	6942                	ld	s2,16(sp)
    80001f0a:	69a2                	ld	s3,8(sp)
    80001f0c:	6a02                	ld	s4,0(sp)
    80001f0e:	6145                	addi	sp,sp,48
    80001f10:	8082                	ret
    return -1;
    80001f12:	54fd                	li	s1,-1
    80001f14:	b7f5                	j	80001f00 <fork+0xf4>

0000000080001f16 <reparent>:
{
    80001f16:	7179                	addi	sp,sp,-48
    80001f18:	f406                	sd	ra,40(sp)
    80001f1a:	f022                	sd	s0,32(sp)
    80001f1c:	ec26                	sd	s1,24(sp)
    80001f1e:	e84a                	sd	s2,16(sp)
    80001f20:	e44e                	sd	s3,8(sp)
    80001f22:	e052                	sd	s4,0(sp)
    80001f24:	1800                	addi	s0,sp,48
    80001f26:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f28:	00014497          	auipc	s1,0x14
    80001f2c:	d3848493          	addi	s1,s1,-712 # 80015c60 <proc>
      pp->parent = initproc;
    80001f30:	00027a17          	auipc	s4,0x27
    80001f34:	468a0a13          	addi	s4,s4,1128 # 80029398 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f38:	00015997          	auipc	s3,0x15
    80001f3c:	b8898993          	addi	s3,s3,-1144 # 80016ac0 <tickslock>
    80001f40:	a029                	j	80001f4a <reparent+0x34>
    80001f42:	17048493          	addi	s1,s1,368
    80001f46:	03348363          	beq	s1,s3,80001f6c <reparent+0x56>
    if(pp->parent == p){
    80001f4a:	749c                	ld	a5,40(s1)
    80001f4c:	ff279be3          	bne	a5,s2,80001f42 <reparent+0x2c>
      acquire(&pp->lock);
    80001f50:	8526                	mv	a0,s1
    80001f52:	fffff097          	auipc	ra,0xfffff
    80001f56:	b5a080e7          	jalr	-1190(ra) # 80000aac <acquire>
      pp->parent = initproc;
    80001f5a:	000a3783          	ld	a5,0(s4)
    80001f5e:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    80001f60:	8526                	mv	a0,s1
    80001f62:	fffff097          	auipc	ra,0xfffff
    80001f66:	c1a080e7          	jalr	-998(ra) # 80000b7c <release>
    80001f6a:	bfe1                	j	80001f42 <reparent+0x2c>
}
    80001f6c:	70a2                	ld	ra,40(sp)
    80001f6e:	7402                	ld	s0,32(sp)
    80001f70:	64e2                	ld	s1,24(sp)
    80001f72:	6942                	ld	s2,16(sp)
    80001f74:	69a2                	ld	s3,8(sp)
    80001f76:	6a02                	ld	s4,0(sp)
    80001f78:	6145                	addi	sp,sp,48
    80001f7a:	8082                	ret

0000000080001f7c <scheduler>:
{
    80001f7c:	715d                	addi	sp,sp,-80
    80001f7e:	e486                	sd	ra,72(sp)
    80001f80:	e0a2                	sd	s0,64(sp)
    80001f82:	fc26                	sd	s1,56(sp)
    80001f84:	f84a                	sd	s2,48(sp)
    80001f86:	f44e                	sd	s3,40(sp)
    80001f88:	f052                	sd	s4,32(sp)
    80001f8a:	ec56                	sd	s5,24(sp)
    80001f8c:	e85a                	sd	s6,16(sp)
    80001f8e:	e45e                	sd	s7,8(sp)
    80001f90:	e062                	sd	s8,0(sp)
    80001f92:	0880                	addi	s0,sp,80
    80001f94:	8792                	mv	a5,tp
  int id = r_tp();
    80001f96:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f98:	00779b13          	slli	s6,a5,0x7
    80001f9c:	00014717          	auipc	a4,0x14
    80001fa0:	8a470713          	addi	a4,a4,-1884 # 80015840 <pid_lock>
    80001fa4:	975a                	add	a4,a4,s6
    80001fa6:	02073023          	sd	zero,32(a4)
        swtch(&c->scheduler, &p->context);
    80001faa:	00014717          	auipc	a4,0x14
    80001fae:	8be70713          	addi	a4,a4,-1858 # 80015868 <cpus+0x8>
    80001fb2:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001fb4:	4b8d                	li	s7,3
        c->proc = p;
    80001fb6:	079e                	slli	a5,a5,0x7
    80001fb8:	00014917          	auipc	s2,0x14
    80001fbc:	88890913          	addi	s2,s2,-1912 # 80015840 <pid_lock>
    80001fc0:	993e                	add	s2,s2,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fc2:	00015a17          	auipc	s4,0x15
    80001fc6:	afea0a13          	addi	s4,s4,-1282 # 80016ac0 <tickslock>
    80001fca:	a0b9                	j	80002018 <scheduler+0x9c>
        p->state = RUNNING;
    80001fcc:	0374a023          	sw	s7,32(s1)
        c->proc = p;
    80001fd0:	02993023          	sd	s1,32(s2)
        swtch(&c->scheduler, &p->context);
    80001fd4:	06848593          	addi	a1,s1,104
    80001fd8:	855a                	mv	a0,s6
    80001fda:	00000097          	auipc	ra,0x0
    80001fde:	63e080e7          	jalr	1598(ra) # 80002618 <swtch>
        c->proc = 0;
    80001fe2:	02093023          	sd	zero,32(s2)
        found = 1;
    80001fe6:	8ae2                	mv	s5,s8
      c->intena = 0;
    80001fe8:	08092e23          	sw	zero,156(s2)
      release(&p->lock);
    80001fec:	8526                	mv	a0,s1
    80001fee:	fffff097          	auipc	ra,0xfffff
    80001ff2:	b8e080e7          	jalr	-1138(ra) # 80000b7c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ff6:	17048493          	addi	s1,s1,368
    80001ffa:	01448b63          	beq	s1,s4,80002010 <scheduler+0x94>
      acquire(&p->lock);
    80001ffe:	8526                	mv	a0,s1
    80002000:	fffff097          	auipc	ra,0xfffff
    80002004:	aac080e7          	jalr	-1364(ra) # 80000aac <acquire>
      if(p->state == RUNNABLE) {
    80002008:	509c                	lw	a5,32(s1)
    8000200a:	fd379fe3          	bne	a5,s3,80001fe8 <scheduler+0x6c>
    8000200e:	bf7d                	j	80001fcc <scheduler+0x50>
    if(found == 0){
    80002010:	000a9463          	bnez	s5,80002018 <scheduler+0x9c>
      asm volatile("wfi");
    80002014:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002018:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000201c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002020:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002024:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002028:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000202a:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000202e:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002030:	00014497          	auipc	s1,0x14
    80002034:	c3048493          	addi	s1,s1,-976 # 80015c60 <proc>
      if(p->state == RUNNABLE) {
    80002038:	4989                	li	s3,2
        found = 1;
    8000203a:	4c05                	li	s8,1
    8000203c:	b7c9                	j	80001ffe <scheduler+0x82>

000000008000203e <sched>:
{
    8000203e:	7179                	addi	sp,sp,-48
    80002040:	f406                	sd	ra,40(sp)
    80002042:	f022                	sd	s0,32(sp)
    80002044:	ec26                	sd	s1,24(sp)
    80002046:	e84a                	sd	s2,16(sp)
    80002048:	e44e                	sd	s3,8(sp)
    8000204a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000204c:	00000097          	auipc	ra,0x0
    80002050:	a56080e7          	jalr	-1450(ra) # 80001aa2 <myproc>
    80002054:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002056:	fffff097          	auipc	ra,0xfffff
    8000205a:	9d8080e7          	jalr	-1576(ra) # 80000a2e <holding>
    8000205e:	c93d                	beqz	a0,800020d4 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002060:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002062:	2781                	sext.w	a5,a5
    80002064:	079e                	slli	a5,a5,0x7
    80002066:	00013717          	auipc	a4,0x13
    8000206a:	7da70713          	addi	a4,a4,2010 # 80015840 <pid_lock>
    8000206e:	97ba                	add	a5,a5,a4
    80002070:	0987a703          	lw	a4,152(a5)
    80002074:	4785                	li	a5,1
    80002076:	06f71763          	bne	a4,a5,800020e4 <sched+0xa6>
  if(p->state == RUNNING)
    8000207a:	5098                	lw	a4,32(s1)
    8000207c:	478d                	li	a5,3
    8000207e:	06f70b63          	beq	a4,a5,800020f4 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002082:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002086:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002088:	efb5                	bnez	a5,80002104 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000208a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000208c:	00013917          	auipc	s2,0x13
    80002090:	7b490913          	addi	s2,s2,1972 # 80015840 <pid_lock>
    80002094:	2781                	sext.w	a5,a5
    80002096:	079e                	slli	a5,a5,0x7
    80002098:	97ca                	add	a5,a5,s2
    8000209a:	09c7a983          	lw	s3,156(a5)
    8000209e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    800020a0:	2781                	sext.w	a5,a5
    800020a2:	079e                	slli	a5,a5,0x7
    800020a4:	00013597          	auipc	a1,0x13
    800020a8:	7c458593          	addi	a1,a1,1988 # 80015868 <cpus+0x8>
    800020ac:	95be                	add	a1,a1,a5
    800020ae:	06848513          	addi	a0,s1,104
    800020b2:	00000097          	auipc	ra,0x0
    800020b6:	566080e7          	jalr	1382(ra) # 80002618 <swtch>
    800020ba:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020bc:	2781                	sext.w	a5,a5
    800020be:	079e                	slli	a5,a5,0x7
    800020c0:	97ca                	add	a5,a5,s2
    800020c2:	0937ae23          	sw	s3,156(a5)
}
    800020c6:	70a2                	ld	ra,40(sp)
    800020c8:	7402                	ld	s0,32(sp)
    800020ca:	64e2                	ld	s1,24(sp)
    800020cc:	6942                	ld	s2,16(sp)
    800020ce:	69a2                	ld	s3,8(sp)
    800020d0:	6145                	addi	sp,sp,48
    800020d2:	8082                	ret
    panic("sched p->lock");
    800020d4:	00007517          	auipc	a0,0x7
    800020d8:	38450513          	addi	a0,a0,900 # 80009458 <userret+0x3c8>
    800020dc:	ffffe097          	auipc	ra,0xffffe
    800020e0:	47e080e7          	jalr	1150(ra) # 8000055a <panic>
    panic("sched locks");
    800020e4:	00007517          	auipc	a0,0x7
    800020e8:	38450513          	addi	a0,a0,900 # 80009468 <userret+0x3d8>
    800020ec:	ffffe097          	auipc	ra,0xffffe
    800020f0:	46e080e7          	jalr	1134(ra) # 8000055a <panic>
    panic("sched running");
    800020f4:	00007517          	auipc	a0,0x7
    800020f8:	38450513          	addi	a0,a0,900 # 80009478 <userret+0x3e8>
    800020fc:	ffffe097          	auipc	ra,0xffffe
    80002100:	45e080e7          	jalr	1118(ra) # 8000055a <panic>
    panic("sched interruptible");
    80002104:	00007517          	auipc	a0,0x7
    80002108:	38450513          	addi	a0,a0,900 # 80009488 <userret+0x3f8>
    8000210c:	ffffe097          	auipc	ra,0xffffe
    80002110:	44e080e7          	jalr	1102(ra) # 8000055a <panic>

0000000080002114 <exit>:
{
    80002114:	7179                	addi	sp,sp,-48
    80002116:	f406                	sd	ra,40(sp)
    80002118:	f022                	sd	s0,32(sp)
    8000211a:	ec26                	sd	s1,24(sp)
    8000211c:	e84a                	sd	s2,16(sp)
    8000211e:	e44e                	sd	s3,8(sp)
    80002120:	e052                	sd	s4,0(sp)
    80002122:	1800                	addi	s0,sp,48
    80002124:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002126:	00000097          	auipc	ra,0x0
    8000212a:	97c080e7          	jalr	-1668(ra) # 80001aa2 <myproc>
    8000212e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002130:	00027797          	auipc	a5,0x27
    80002134:	2687b783          	ld	a5,616(a5) # 80029398 <initproc>
    80002138:	0d850493          	addi	s1,a0,216
    8000213c:	15850913          	addi	s2,a0,344
    80002140:	02a79363          	bne	a5,a0,80002166 <exit+0x52>
    panic("init exiting");
    80002144:	00007517          	auipc	a0,0x7
    80002148:	35c50513          	addi	a0,a0,860 # 800094a0 <userret+0x410>
    8000214c:	ffffe097          	auipc	ra,0xffffe
    80002150:	40e080e7          	jalr	1038(ra) # 8000055a <panic>
      fileclose(f);
    80002154:	00002097          	auipc	ra,0x2
    80002158:	56a080e7          	jalr	1386(ra) # 800046be <fileclose>
      p->ofile[fd] = 0;
    8000215c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002160:	04a1                	addi	s1,s1,8
    80002162:	01248563          	beq	s1,s2,8000216c <exit+0x58>
    if(p->ofile[fd]){
    80002166:	6088                	ld	a0,0(s1)
    80002168:	f575                	bnez	a0,80002154 <exit+0x40>
    8000216a:	bfdd                	j	80002160 <exit+0x4c>
  begin_op(ROOTDEV);
    8000216c:	4501                	li	a0,0
    8000216e:	00002097          	auipc	ra,0x2
    80002172:	fb6080e7          	jalr	-74(ra) # 80004124 <begin_op>
  iput(p->cwd);
    80002176:	1589b503          	ld	a0,344(s3)
    8000217a:	00001097          	auipc	ra,0x1
    8000217e:	6d4080e7          	jalr	1748(ra) # 8000384e <iput>
  end_op(ROOTDEV);
    80002182:	4501                	li	a0,0
    80002184:	00002097          	auipc	ra,0x2
    80002188:	04a080e7          	jalr	74(ra) # 800041ce <end_op>
  p->cwd = 0;
    8000218c:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    80002190:	00027497          	auipc	s1,0x27
    80002194:	20848493          	addi	s1,s1,520 # 80029398 <initproc>
    80002198:	6088                	ld	a0,0(s1)
    8000219a:	fffff097          	auipc	ra,0xfffff
    8000219e:	912080e7          	jalr	-1774(ra) # 80000aac <acquire>
  wakeup1(initproc);
    800021a2:	6088                	ld	a0,0(s1)
    800021a4:	fffff097          	auipc	ra,0xfffff
    800021a8:	7be080e7          	jalr	1982(ra) # 80001962 <wakeup1>
  release(&initproc->lock);
    800021ac:	6088                	ld	a0,0(s1)
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	9ce080e7          	jalr	-1586(ra) # 80000b7c <release>
  acquire(&p->lock);
    800021b6:	854e                	mv	a0,s3
    800021b8:	fffff097          	auipc	ra,0xfffff
    800021bc:	8f4080e7          	jalr	-1804(ra) # 80000aac <acquire>
  struct proc *original_parent = p->parent;
    800021c0:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    800021c4:	854e                	mv	a0,s3
    800021c6:	fffff097          	auipc	ra,0xfffff
    800021ca:	9b6080e7          	jalr	-1610(ra) # 80000b7c <release>
  acquire(&original_parent->lock);
    800021ce:	8526                	mv	a0,s1
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	8dc080e7          	jalr	-1828(ra) # 80000aac <acquire>
  acquire(&p->lock);
    800021d8:	854e                	mv	a0,s3
    800021da:	fffff097          	auipc	ra,0xfffff
    800021de:	8d2080e7          	jalr	-1838(ra) # 80000aac <acquire>
  reparent(p);
    800021e2:	854e                	mv	a0,s3
    800021e4:	00000097          	auipc	ra,0x0
    800021e8:	d32080e7          	jalr	-718(ra) # 80001f16 <reparent>
  wakeup1(original_parent);
    800021ec:	8526                	mv	a0,s1
    800021ee:	fffff097          	auipc	ra,0xfffff
    800021f2:	774080e7          	jalr	1908(ra) # 80001962 <wakeup1>
  p->xstate = status;
    800021f6:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    800021fa:	4791                	li	a5,4
    800021fc:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    80002200:	8526                	mv	a0,s1
    80002202:	fffff097          	auipc	ra,0xfffff
    80002206:	97a080e7          	jalr	-1670(ra) # 80000b7c <release>
  sched();
    8000220a:	00000097          	auipc	ra,0x0
    8000220e:	e34080e7          	jalr	-460(ra) # 8000203e <sched>
  panic("zombie exit");
    80002212:	00007517          	auipc	a0,0x7
    80002216:	29e50513          	addi	a0,a0,670 # 800094b0 <userret+0x420>
    8000221a:	ffffe097          	auipc	ra,0xffffe
    8000221e:	340080e7          	jalr	832(ra) # 8000055a <panic>

0000000080002222 <yield>:
{
    80002222:	1101                	addi	sp,sp,-32
    80002224:	ec06                	sd	ra,24(sp)
    80002226:	e822                	sd	s0,16(sp)
    80002228:	e426                	sd	s1,8(sp)
    8000222a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000222c:	00000097          	auipc	ra,0x0
    80002230:	876080e7          	jalr	-1930(ra) # 80001aa2 <myproc>
    80002234:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002236:	fffff097          	auipc	ra,0xfffff
    8000223a:	876080e7          	jalr	-1930(ra) # 80000aac <acquire>
  p->state = RUNNABLE;
    8000223e:	4789                	li	a5,2
    80002240:	d09c                	sw	a5,32(s1)
  sched();
    80002242:	00000097          	auipc	ra,0x0
    80002246:	dfc080e7          	jalr	-516(ra) # 8000203e <sched>
  release(&p->lock);
    8000224a:	8526                	mv	a0,s1
    8000224c:	fffff097          	auipc	ra,0xfffff
    80002250:	930080e7          	jalr	-1744(ra) # 80000b7c <release>
}
    80002254:	60e2                	ld	ra,24(sp)
    80002256:	6442                	ld	s0,16(sp)
    80002258:	64a2                	ld	s1,8(sp)
    8000225a:	6105                	addi	sp,sp,32
    8000225c:	8082                	ret

000000008000225e <sleep>:
{
    8000225e:	7179                	addi	sp,sp,-48
    80002260:	f406                	sd	ra,40(sp)
    80002262:	f022                	sd	s0,32(sp)
    80002264:	ec26                	sd	s1,24(sp)
    80002266:	e84a                	sd	s2,16(sp)
    80002268:	e44e                	sd	s3,8(sp)
    8000226a:	1800                	addi	s0,sp,48
    8000226c:	89aa                	mv	s3,a0
    8000226e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002270:	00000097          	auipc	ra,0x0
    80002274:	832080e7          	jalr	-1998(ra) # 80001aa2 <myproc>
    80002278:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    8000227a:	05250663          	beq	a0,s2,800022c6 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000227e:	fffff097          	auipc	ra,0xfffff
    80002282:	82e080e7          	jalr	-2002(ra) # 80000aac <acquire>
    release(lk);
    80002286:	854a                	mv	a0,s2
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	8f4080e7          	jalr	-1804(ra) # 80000b7c <release>
  p->chan = chan;
    80002290:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    80002294:	4785                	li	a5,1
    80002296:	d09c                	sw	a5,32(s1)
  sched();
    80002298:	00000097          	auipc	ra,0x0
    8000229c:	da6080e7          	jalr	-602(ra) # 8000203e <sched>
  p->chan = 0;
    800022a0:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    800022a4:	8526                	mv	a0,s1
    800022a6:	fffff097          	auipc	ra,0xfffff
    800022aa:	8d6080e7          	jalr	-1834(ra) # 80000b7c <release>
    acquire(lk);
    800022ae:	854a                	mv	a0,s2
    800022b0:	ffffe097          	auipc	ra,0xffffe
    800022b4:	7fc080e7          	jalr	2044(ra) # 80000aac <acquire>
}
    800022b8:	70a2                	ld	ra,40(sp)
    800022ba:	7402                	ld	s0,32(sp)
    800022bc:	64e2                	ld	s1,24(sp)
    800022be:	6942                	ld	s2,16(sp)
    800022c0:	69a2                	ld	s3,8(sp)
    800022c2:	6145                	addi	sp,sp,48
    800022c4:	8082                	ret
  p->chan = chan;
    800022c6:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    800022ca:	4785                	li	a5,1
    800022cc:	d11c                	sw	a5,32(a0)
  sched();
    800022ce:	00000097          	auipc	ra,0x0
    800022d2:	d70080e7          	jalr	-656(ra) # 8000203e <sched>
  p->chan = 0;
    800022d6:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    800022da:	bff9                	j	800022b8 <sleep+0x5a>

00000000800022dc <wait>:
{
    800022dc:	715d                	addi	sp,sp,-80
    800022de:	e486                	sd	ra,72(sp)
    800022e0:	e0a2                	sd	s0,64(sp)
    800022e2:	fc26                	sd	s1,56(sp)
    800022e4:	f84a                	sd	s2,48(sp)
    800022e6:	f44e                	sd	s3,40(sp)
    800022e8:	f052                	sd	s4,32(sp)
    800022ea:	ec56                	sd	s5,24(sp)
    800022ec:	e85a                	sd	s6,16(sp)
    800022ee:	e45e                	sd	s7,8(sp)
    800022f0:	e062                	sd	s8,0(sp)
    800022f2:	0880                	addi	s0,sp,80
    800022f4:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	7ac080e7          	jalr	1964(ra) # 80001aa2 <myproc>
    800022fe:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002300:	8c2a                	mv	s8,a0
    80002302:	ffffe097          	auipc	ra,0xffffe
    80002306:	7aa080e7          	jalr	1962(ra) # 80000aac <acquire>
    havekids = 0;
    8000230a:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000230c:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    8000230e:	00014997          	auipc	s3,0x14
    80002312:	7b298993          	addi	s3,s3,1970 # 80016ac0 <tickslock>
        havekids = 1;
    80002316:	4b05                	li	s6,1
    havekids = 0;
    80002318:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000231a:	00014497          	auipc	s1,0x14
    8000231e:	94648493          	addi	s1,s1,-1722 # 80015c60 <proc>
    80002322:	a08d                	j	80002384 <wait+0xa8>
          pid = np->pid;
    80002324:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002328:	000a8e63          	beqz	s5,80002344 <wait+0x68>
    8000232c:	4691                	li	a3,4
    8000232e:	03c48613          	addi	a2,s1,60
    80002332:	85d6                	mv	a1,s5
    80002334:	05893503          	ld	a0,88(s2)
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	45e080e7          	jalr	1118(ra) # 80001796 <copyout>
    80002340:	02054263          	bltz	a0,80002364 <wait+0x88>
          freeproc(np);
    80002344:	8526                	mv	a0,s1
    80002346:	00000097          	auipc	ra,0x0
    8000234a:	978080e7          	jalr	-1672(ra) # 80001cbe <freeproc>
          release(&np->lock);
    8000234e:	8526                	mv	a0,s1
    80002350:	fffff097          	auipc	ra,0xfffff
    80002354:	82c080e7          	jalr	-2004(ra) # 80000b7c <release>
          release(&p->lock);
    80002358:	854a                	mv	a0,s2
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	822080e7          	jalr	-2014(ra) # 80000b7c <release>
          return pid;
    80002362:	a8a9                	j	800023bc <wait+0xe0>
            release(&np->lock);
    80002364:	8526                	mv	a0,s1
    80002366:	fffff097          	auipc	ra,0xfffff
    8000236a:	816080e7          	jalr	-2026(ra) # 80000b7c <release>
            release(&p->lock);
    8000236e:	854a                	mv	a0,s2
    80002370:	fffff097          	auipc	ra,0xfffff
    80002374:	80c080e7          	jalr	-2036(ra) # 80000b7c <release>
            return -1;
    80002378:	59fd                	li	s3,-1
    8000237a:	a089                	j	800023bc <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    8000237c:	17048493          	addi	s1,s1,368
    80002380:	03348463          	beq	s1,s3,800023a8 <wait+0xcc>
      if(np->parent == p){
    80002384:	749c                	ld	a5,40(s1)
    80002386:	ff279be3          	bne	a5,s2,8000237c <wait+0xa0>
        acquire(&np->lock);
    8000238a:	8526                	mv	a0,s1
    8000238c:	ffffe097          	auipc	ra,0xffffe
    80002390:	720080e7          	jalr	1824(ra) # 80000aac <acquire>
        if(np->state == ZOMBIE){
    80002394:	509c                	lw	a5,32(s1)
    80002396:	f94787e3          	beq	a5,s4,80002324 <wait+0x48>
        release(&np->lock);
    8000239a:	8526                	mv	a0,s1
    8000239c:	ffffe097          	auipc	ra,0xffffe
    800023a0:	7e0080e7          	jalr	2016(ra) # 80000b7c <release>
        havekids = 1;
    800023a4:	875a                	mv	a4,s6
    800023a6:	bfd9                	j	8000237c <wait+0xa0>
    if(!havekids || p->killed){
    800023a8:	c701                	beqz	a4,800023b0 <wait+0xd4>
    800023aa:	03892783          	lw	a5,56(s2)
    800023ae:	c785                	beqz	a5,800023d6 <wait+0xfa>
      release(&p->lock);
    800023b0:	854a                	mv	a0,s2
    800023b2:	ffffe097          	auipc	ra,0xffffe
    800023b6:	7ca080e7          	jalr	1994(ra) # 80000b7c <release>
      return -1;
    800023ba:	59fd                	li	s3,-1
}
    800023bc:	854e                	mv	a0,s3
    800023be:	60a6                	ld	ra,72(sp)
    800023c0:	6406                	ld	s0,64(sp)
    800023c2:	74e2                	ld	s1,56(sp)
    800023c4:	7942                	ld	s2,48(sp)
    800023c6:	79a2                	ld	s3,40(sp)
    800023c8:	7a02                	ld	s4,32(sp)
    800023ca:	6ae2                	ld	s5,24(sp)
    800023cc:	6b42                	ld	s6,16(sp)
    800023ce:	6ba2                	ld	s7,8(sp)
    800023d0:	6c02                	ld	s8,0(sp)
    800023d2:	6161                	addi	sp,sp,80
    800023d4:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800023d6:	85e2                	mv	a1,s8
    800023d8:	854a                	mv	a0,s2
    800023da:	00000097          	auipc	ra,0x0
    800023de:	e84080e7          	jalr	-380(ra) # 8000225e <sleep>
    havekids = 0;
    800023e2:	bf1d                	j	80002318 <wait+0x3c>

00000000800023e4 <wakeup>:
{
    800023e4:	7139                	addi	sp,sp,-64
    800023e6:	fc06                	sd	ra,56(sp)
    800023e8:	f822                	sd	s0,48(sp)
    800023ea:	f426                	sd	s1,40(sp)
    800023ec:	f04a                	sd	s2,32(sp)
    800023ee:	ec4e                	sd	s3,24(sp)
    800023f0:	e852                	sd	s4,16(sp)
    800023f2:	e456                	sd	s5,8(sp)
    800023f4:	0080                	addi	s0,sp,64
    800023f6:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800023f8:	00014497          	auipc	s1,0x14
    800023fc:	86848493          	addi	s1,s1,-1944 # 80015c60 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002400:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002402:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002404:	00014917          	auipc	s2,0x14
    80002408:	6bc90913          	addi	s2,s2,1724 # 80016ac0 <tickslock>
    8000240c:	a821                	j	80002424 <wakeup+0x40>
      p->state = RUNNABLE;
    8000240e:	0354a023          	sw	s5,32(s1)
    release(&p->lock);
    80002412:	8526                	mv	a0,s1
    80002414:	ffffe097          	auipc	ra,0xffffe
    80002418:	768080e7          	jalr	1896(ra) # 80000b7c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000241c:	17048493          	addi	s1,s1,368
    80002420:	01248e63          	beq	s1,s2,8000243c <wakeup+0x58>
    acquire(&p->lock);
    80002424:	8526                	mv	a0,s1
    80002426:	ffffe097          	auipc	ra,0xffffe
    8000242a:	686080e7          	jalr	1670(ra) # 80000aac <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000242e:	509c                	lw	a5,32(s1)
    80002430:	ff3791e3          	bne	a5,s3,80002412 <wakeup+0x2e>
    80002434:	789c                	ld	a5,48(s1)
    80002436:	fd479ee3          	bne	a5,s4,80002412 <wakeup+0x2e>
    8000243a:	bfd1                	j	8000240e <wakeup+0x2a>
}
    8000243c:	70e2                	ld	ra,56(sp)
    8000243e:	7442                	ld	s0,48(sp)
    80002440:	74a2                	ld	s1,40(sp)
    80002442:	7902                	ld	s2,32(sp)
    80002444:	69e2                	ld	s3,24(sp)
    80002446:	6a42                	ld	s4,16(sp)
    80002448:	6aa2                	ld	s5,8(sp)
    8000244a:	6121                	addi	sp,sp,64
    8000244c:	8082                	ret

000000008000244e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000244e:	7179                	addi	sp,sp,-48
    80002450:	f406                	sd	ra,40(sp)
    80002452:	f022                	sd	s0,32(sp)
    80002454:	ec26                	sd	s1,24(sp)
    80002456:	e84a                	sd	s2,16(sp)
    80002458:	e44e                	sd	s3,8(sp)
    8000245a:	1800                	addi	s0,sp,48
    8000245c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000245e:	00014497          	auipc	s1,0x14
    80002462:	80248493          	addi	s1,s1,-2046 # 80015c60 <proc>
    80002466:	00014997          	auipc	s3,0x14
    8000246a:	65a98993          	addi	s3,s3,1626 # 80016ac0 <tickslock>
    acquire(&p->lock);
    8000246e:	8526                	mv	a0,s1
    80002470:	ffffe097          	auipc	ra,0xffffe
    80002474:	63c080e7          	jalr	1596(ra) # 80000aac <acquire>
    if(p->pid == pid){
    80002478:	40bc                	lw	a5,64(s1)
    8000247a:	03278363          	beq	a5,s2,800024a0 <kill+0x52>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000247e:	8526                	mv	a0,s1
    80002480:	ffffe097          	auipc	ra,0xffffe
    80002484:	6fc080e7          	jalr	1788(ra) # 80000b7c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002488:	17048493          	addi	s1,s1,368
    8000248c:	ff3491e3          	bne	s1,s3,8000246e <kill+0x20>
  }
  return -1;
    80002490:	557d                	li	a0,-1
}
    80002492:	70a2                	ld	ra,40(sp)
    80002494:	7402                	ld	s0,32(sp)
    80002496:	64e2                	ld	s1,24(sp)
    80002498:	6942                	ld	s2,16(sp)
    8000249a:	69a2                	ld	s3,8(sp)
    8000249c:	6145                	addi	sp,sp,48
    8000249e:	8082                	ret
      p->killed = 1;
    800024a0:	4785                	li	a5,1
    800024a2:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    800024a4:	5098                	lw	a4,32(s1)
    800024a6:	00f70963          	beq	a4,a5,800024b8 <kill+0x6a>
      release(&p->lock);
    800024aa:	8526                	mv	a0,s1
    800024ac:	ffffe097          	auipc	ra,0xffffe
    800024b0:	6d0080e7          	jalr	1744(ra) # 80000b7c <release>
      return 0;
    800024b4:	4501                	li	a0,0
    800024b6:	bff1                	j	80002492 <kill+0x44>
        p->state = RUNNABLE;
    800024b8:	4789                	li	a5,2
    800024ba:	d09c                	sw	a5,32(s1)
    800024bc:	b7fd                	j	800024aa <kill+0x5c>

00000000800024be <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024be:	7179                	addi	sp,sp,-48
    800024c0:	f406                	sd	ra,40(sp)
    800024c2:	f022                	sd	s0,32(sp)
    800024c4:	ec26                	sd	s1,24(sp)
    800024c6:	e84a                	sd	s2,16(sp)
    800024c8:	e44e                	sd	s3,8(sp)
    800024ca:	e052                	sd	s4,0(sp)
    800024cc:	1800                	addi	s0,sp,48
    800024ce:	84aa                	mv	s1,a0
    800024d0:	892e                	mv	s2,a1
    800024d2:	89b2                	mv	s3,a2
    800024d4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024d6:	fffff097          	auipc	ra,0xfffff
    800024da:	5cc080e7          	jalr	1484(ra) # 80001aa2 <myproc>
  if(user_dst){
    800024de:	c08d                	beqz	s1,80002500 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024e0:	86d2                	mv	a3,s4
    800024e2:	864e                	mv	a2,s3
    800024e4:	85ca                	mv	a1,s2
    800024e6:	6d28                	ld	a0,88(a0)
    800024e8:	fffff097          	auipc	ra,0xfffff
    800024ec:	2ae080e7          	jalr	686(ra) # 80001796 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024f0:	70a2                	ld	ra,40(sp)
    800024f2:	7402                	ld	s0,32(sp)
    800024f4:	64e2                	ld	s1,24(sp)
    800024f6:	6942                	ld	s2,16(sp)
    800024f8:	69a2                	ld	s3,8(sp)
    800024fa:	6a02                	ld	s4,0(sp)
    800024fc:	6145                	addi	sp,sp,48
    800024fe:	8082                	ret
    memmove((char *)dst, src, len);
    80002500:	000a061b          	sext.w	a2,s4
    80002504:	85ce                	mv	a1,s3
    80002506:	854a                	mv	a0,s2
    80002508:	fffff097          	auipc	ra,0xfffff
    8000250c:	8d2080e7          	jalr	-1838(ra) # 80000dda <memmove>
    return 0;
    80002510:	8526                	mv	a0,s1
    80002512:	bff9                	j	800024f0 <either_copyout+0x32>

0000000080002514 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002514:	7179                	addi	sp,sp,-48
    80002516:	f406                	sd	ra,40(sp)
    80002518:	f022                	sd	s0,32(sp)
    8000251a:	ec26                	sd	s1,24(sp)
    8000251c:	e84a                	sd	s2,16(sp)
    8000251e:	e44e                	sd	s3,8(sp)
    80002520:	e052                	sd	s4,0(sp)
    80002522:	1800                	addi	s0,sp,48
    80002524:	892a                	mv	s2,a0
    80002526:	84ae                	mv	s1,a1
    80002528:	89b2                	mv	s3,a2
    8000252a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000252c:	fffff097          	auipc	ra,0xfffff
    80002530:	576080e7          	jalr	1398(ra) # 80001aa2 <myproc>
  if(user_src){
    80002534:	c08d                	beqz	s1,80002556 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002536:	86d2                	mv	a3,s4
    80002538:	864e                	mv	a2,s3
    8000253a:	85ca                	mv	a1,s2
    8000253c:	6d28                	ld	a0,88(a0)
    8000253e:	fffff097          	auipc	ra,0xfffff
    80002542:	2e4080e7          	jalr	740(ra) # 80001822 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002546:	70a2                	ld	ra,40(sp)
    80002548:	7402                	ld	s0,32(sp)
    8000254a:	64e2                	ld	s1,24(sp)
    8000254c:	6942                	ld	s2,16(sp)
    8000254e:	69a2                	ld	s3,8(sp)
    80002550:	6a02                	ld	s4,0(sp)
    80002552:	6145                	addi	sp,sp,48
    80002554:	8082                	ret
    memmove(dst, (char*)src, len);
    80002556:	000a061b          	sext.w	a2,s4
    8000255a:	85ce                	mv	a1,s3
    8000255c:	854a                	mv	a0,s2
    8000255e:	fffff097          	auipc	ra,0xfffff
    80002562:	87c080e7          	jalr	-1924(ra) # 80000dda <memmove>
    return 0;
    80002566:	8526                	mv	a0,s1
    80002568:	bff9                	j	80002546 <either_copyin+0x32>

000000008000256a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000256a:	715d                	addi	sp,sp,-80
    8000256c:	e486                	sd	ra,72(sp)
    8000256e:	e0a2                	sd	s0,64(sp)
    80002570:	fc26                	sd	s1,56(sp)
    80002572:	f84a                	sd	s2,48(sp)
    80002574:	f44e                	sd	s3,40(sp)
    80002576:	f052                	sd	s4,32(sp)
    80002578:	ec56                	sd	s5,24(sp)
    8000257a:	e85a                	sd	s6,16(sp)
    8000257c:	e45e                	sd	s7,8(sp)
    8000257e:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002580:	00007517          	auipc	a0,0x7
    80002584:	d1050513          	addi	a0,a0,-752 # 80009290 <userret+0x200>
    80002588:	ffffe097          	auipc	ra,0xffffe
    8000258c:	02c080e7          	jalr	44(ra) # 800005b4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002590:	00014497          	auipc	s1,0x14
    80002594:	83048493          	addi	s1,s1,-2000 # 80015dc0 <proc+0x160>
    80002598:	00014917          	auipc	s2,0x14
    8000259c:	68890913          	addi	s2,s2,1672 # 80016c20 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a0:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800025a2:	00007997          	auipc	s3,0x7
    800025a6:	f1e98993          	addi	s3,s3,-226 # 800094c0 <userret+0x430>
    printf("%d %s %s", p->pid, state, p->name);
    800025aa:	00007a97          	auipc	s5,0x7
    800025ae:	f1ea8a93          	addi	s5,s5,-226 # 800094c8 <userret+0x438>
    printf("\n");
    800025b2:	00007a17          	auipc	s4,0x7
    800025b6:	cdea0a13          	addi	s4,s4,-802 # 80009290 <userret+0x200>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025ba:	00007b97          	auipc	s7,0x7
    800025be:	7f6b8b93          	addi	s7,s7,2038 # 80009db0 <states.1828>
    800025c2:	a00d                	j	800025e4 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025c4:	ee06a583          	lw	a1,-288(a3)
    800025c8:	8556                	mv	a0,s5
    800025ca:	ffffe097          	auipc	ra,0xffffe
    800025ce:	fea080e7          	jalr	-22(ra) # 800005b4 <printf>
    printf("\n");
    800025d2:	8552                	mv	a0,s4
    800025d4:	ffffe097          	auipc	ra,0xffffe
    800025d8:	fe0080e7          	jalr	-32(ra) # 800005b4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025dc:	17048493          	addi	s1,s1,368
    800025e0:	03248163          	beq	s1,s2,80002602 <procdump+0x98>
    if(p->state == UNUSED)
    800025e4:	86a6                	mv	a3,s1
    800025e6:	ec04a783          	lw	a5,-320(s1)
    800025ea:	dbed                	beqz	a5,800025dc <procdump+0x72>
      state = "???";
    800025ec:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025ee:	fcfb6be3          	bltu	s6,a5,800025c4 <procdump+0x5a>
    800025f2:	1782                	slli	a5,a5,0x20
    800025f4:	9381                	srli	a5,a5,0x20
    800025f6:	078e                	slli	a5,a5,0x3
    800025f8:	97de                	add	a5,a5,s7
    800025fa:	6390                	ld	a2,0(a5)
    800025fc:	f661                	bnez	a2,800025c4 <procdump+0x5a>
      state = "???";
    800025fe:	864e                	mv	a2,s3
    80002600:	b7d1                	j	800025c4 <procdump+0x5a>
  }
}
    80002602:	60a6                	ld	ra,72(sp)
    80002604:	6406                	ld	s0,64(sp)
    80002606:	74e2                	ld	s1,56(sp)
    80002608:	7942                	ld	s2,48(sp)
    8000260a:	79a2                	ld	s3,40(sp)
    8000260c:	7a02                	ld	s4,32(sp)
    8000260e:	6ae2                	ld	s5,24(sp)
    80002610:	6b42                	ld	s6,16(sp)
    80002612:	6ba2                	ld	s7,8(sp)
    80002614:	6161                	addi	sp,sp,80
    80002616:	8082                	ret

0000000080002618 <swtch>:
    80002618:	00153023          	sd	ra,0(a0)
    8000261c:	00253423          	sd	sp,8(a0)
    80002620:	e900                	sd	s0,16(a0)
    80002622:	ed04                	sd	s1,24(a0)
    80002624:	03253023          	sd	s2,32(a0)
    80002628:	03353423          	sd	s3,40(a0)
    8000262c:	03453823          	sd	s4,48(a0)
    80002630:	03553c23          	sd	s5,56(a0)
    80002634:	05653023          	sd	s6,64(a0)
    80002638:	05753423          	sd	s7,72(a0)
    8000263c:	05853823          	sd	s8,80(a0)
    80002640:	05953c23          	sd	s9,88(a0)
    80002644:	07a53023          	sd	s10,96(a0)
    80002648:	07b53423          	sd	s11,104(a0)
    8000264c:	0005b083          	ld	ra,0(a1)
    80002650:	0085b103          	ld	sp,8(a1)
    80002654:	6980                	ld	s0,16(a1)
    80002656:	6d84                	ld	s1,24(a1)
    80002658:	0205b903          	ld	s2,32(a1)
    8000265c:	0285b983          	ld	s3,40(a1)
    80002660:	0305ba03          	ld	s4,48(a1)
    80002664:	0385ba83          	ld	s5,56(a1)
    80002668:	0405bb03          	ld	s6,64(a1)
    8000266c:	0485bb83          	ld	s7,72(a1)
    80002670:	0505bc03          	ld	s8,80(a1)
    80002674:	0585bc83          	ld	s9,88(a1)
    80002678:	0605bd03          	ld	s10,96(a1)
    8000267c:	0685bd83          	ld	s11,104(a1)
    80002680:	8082                	ret

0000000080002682 <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    80002682:	1141                	addi	sp,sp,-16
    80002684:	e422                	sd	s0,8(sp)
    80002686:	0800                	addi	s0,sp,16
    80002688:	87aa                	mv	a5,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    8000268a:	00151713          	slli	a4,a0,0x1
    8000268e:	8305                	srli	a4,a4,0x1
  if (interrupt) {
    80002690:	04054c63          	bltz	a0,800026e8 <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    80002694:	5685                	li	a3,-31
    80002696:	8285                	srli	a3,a3,0x1
    80002698:	8ee9                	and	a3,a3,a0
    8000269a:	caad                	beqz	a3,8000270c <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    8000269c:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    8000269e:	00007517          	auipc	a0,0x7
    800026a2:	e6250513          	addi	a0,a0,-414 # 80009500 <userret+0x470>
    } else if (code <= 23) {
    800026a6:	06e6f063          	bgeu	a3,a4,80002706 <scause_desc+0x84>
    } else if (code <= 31) {
    800026aa:	fc100693          	li	a3,-63
    800026ae:	8285                	srli	a3,a3,0x1
    800026b0:	8efd                	and	a3,a3,a5
      return "<reserved for custom use>";
    800026b2:	00007517          	auipc	a0,0x7
    800026b6:	e7650513          	addi	a0,a0,-394 # 80009528 <userret+0x498>
    } else if (code <= 31) {
    800026ba:	c6b1                	beqz	a3,80002706 <scause_desc+0x84>
    } else if (code <= 47) {
    800026bc:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    800026c0:	00007517          	auipc	a0,0x7
    800026c4:	e4050513          	addi	a0,a0,-448 # 80009500 <userret+0x470>
    } else if (code <= 47) {
    800026c8:	02e6ff63          	bgeu	a3,a4,80002706 <scause_desc+0x84>
    } else if (code <= 63) {
    800026cc:	f8100513          	li	a0,-127
    800026d0:	8105                	srli	a0,a0,0x1
    800026d2:	8fe9                	and	a5,a5,a0
      return "<reserved for custom use>";
    800026d4:	00007517          	auipc	a0,0x7
    800026d8:	e5450513          	addi	a0,a0,-428 # 80009528 <userret+0x498>
    } else if (code <= 63) {
    800026dc:	c78d                	beqz	a5,80002706 <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    800026de:	00007517          	auipc	a0,0x7
    800026e2:	e2250513          	addi	a0,a0,-478 # 80009500 <userret+0x470>
    800026e6:	a005                	j	80002706 <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    800026e8:	5505                	li	a0,-31
    800026ea:	8105                	srli	a0,a0,0x1
    800026ec:	8fe9                	and	a5,a5,a0
      return "<reserved for platform use>";
    800026ee:	00007517          	auipc	a0,0x7
    800026f2:	e5a50513          	addi	a0,a0,-422 # 80009548 <userret+0x4b8>
    if (code < NELEM(intr_desc)) {
    800026f6:	eb81                	bnez	a5,80002706 <scause_desc+0x84>
      return intr_desc[code];
    800026f8:	070e                	slli	a4,a4,0x3
    800026fa:	00007797          	auipc	a5,0x7
    800026fe:	6de78793          	addi	a5,a5,1758 # 80009dd8 <intr_desc.1645>
    80002702:	973e                	add	a4,a4,a5
    80002704:	6308                	ld	a0,0(a4)
    }
  }
}
    80002706:	6422                	ld	s0,8(sp)
    80002708:	0141                	addi	sp,sp,16
    8000270a:	8082                	ret
      return nointr_desc[code];
    8000270c:	070e                	slli	a4,a4,0x3
    8000270e:	00007797          	auipc	a5,0x7
    80002712:	6ca78793          	addi	a5,a5,1738 # 80009dd8 <intr_desc.1645>
    80002716:	973e                	add	a4,a4,a5
    80002718:	6348                	ld	a0,128(a4)
    8000271a:	b7f5                	j	80002706 <scause_desc+0x84>

000000008000271c <trapinit>:
{
    8000271c:	1141                	addi	sp,sp,-16
    8000271e:	e406                	sd	ra,8(sp)
    80002720:	e022                	sd	s0,0(sp)
    80002722:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002724:	00007597          	auipc	a1,0x7
    80002728:	e4458593          	addi	a1,a1,-444 # 80009568 <userret+0x4d8>
    8000272c:	00014517          	auipc	a0,0x14
    80002730:	39450513          	addi	a0,a0,916 # 80016ac0 <tickslock>
    80002734:	ffffe097          	auipc	ra,0xffffe
    80002738:	2a4080e7          	jalr	676(ra) # 800009d8 <initlock>
}
    8000273c:	60a2                	ld	ra,8(sp)
    8000273e:	6402                	ld	s0,0(sp)
    80002740:	0141                	addi	sp,sp,16
    80002742:	8082                	ret

0000000080002744 <trapinithart>:
{
    80002744:	1141                	addi	sp,sp,-16
    80002746:	e422                	sd	s0,8(sp)
    80002748:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000274a:	00003797          	auipc	a5,0x3
    8000274e:	6c678793          	addi	a5,a5,1734 # 80005e10 <kernelvec>
    80002752:	10579073          	csrw	stvec,a5
}
    80002756:	6422                	ld	s0,8(sp)
    80002758:	0141                	addi	sp,sp,16
    8000275a:	8082                	ret

000000008000275c <usertrapret>:
{
    8000275c:	1141                	addi	sp,sp,-16
    8000275e:	e406                	sd	ra,8(sp)
    80002760:	e022                	sd	s0,0(sp)
    80002762:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002764:	fffff097          	auipc	ra,0xfffff
    80002768:	33e080e7          	jalr	830(ra) # 80001aa2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000276c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002770:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002772:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002776:	00007617          	auipc	a2,0x7
    8000277a:	88a60613          	addi	a2,a2,-1910 # 80009000 <trampoline>
    8000277e:	00007697          	auipc	a3,0x7
    80002782:	88268693          	addi	a3,a3,-1918 # 80009000 <trampoline>
    80002786:	8e91                	sub	a3,a3,a2
    80002788:	040007b7          	lui	a5,0x4000
    8000278c:	17fd                	addi	a5,a5,-1
    8000278e:	07b2                	slli	a5,a5,0xc
    80002790:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002792:	10569073          	csrw	stvec,a3
  p->tf->kernel_satp = r_satp();         // kernel page table
    80002796:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002798:	180026f3          	csrr	a3,satp
    8000279c:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000279e:	7138                	ld	a4,96(a0)
    800027a0:	6534                	ld	a3,72(a0)
    800027a2:	6585                	lui	a1,0x1
    800027a4:	96ae                	add	a3,a3,a1
    800027a6:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    800027a8:	7138                	ld	a4,96(a0)
    800027aa:	00000697          	auipc	a3,0x0
    800027ae:	13e68693          	addi	a3,a3,318 # 800028e8 <usertrap>
    800027b2:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    800027b4:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027b6:	8692                	mv	a3,tp
    800027b8:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027ba:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027be:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027c2:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027c6:	10069073          	csrw	sstatus,a3
  w_sepc(p->tf->epc);
    800027ca:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027cc:	6f18                	ld	a4,24(a4)
    800027ce:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    800027d2:	6d2c                	ld	a1,88(a0)
    800027d4:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800027d6:	00007717          	auipc	a4,0x7
    800027da:	8ba70713          	addi	a4,a4,-1862 # 80009090 <userret>
    800027de:	8f11                	sub	a4,a4,a2
    800027e0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800027e2:	577d                	li	a4,-1
    800027e4:	177e                	slli	a4,a4,0x3f
    800027e6:	8dd9                	or	a1,a1,a4
    800027e8:	02000537          	lui	a0,0x2000
    800027ec:	157d                	addi	a0,a0,-1
    800027ee:	0536                	slli	a0,a0,0xd
    800027f0:	9782                	jalr	a5
}
    800027f2:	60a2                	ld	ra,8(sp)
    800027f4:	6402                	ld	s0,0(sp)
    800027f6:	0141                	addi	sp,sp,16
    800027f8:	8082                	ret

00000000800027fa <clockintr>:
{
    800027fa:	1101                	addi	sp,sp,-32
    800027fc:	ec06                	sd	ra,24(sp)
    800027fe:	e822                	sd	s0,16(sp)
    80002800:	e426                	sd	s1,8(sp)
    80002802:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002804:	00014497          	auipc	s1,0x14
    80002808:	2bc48493          	addi	s1,s1,700 # 80016ac0 <tickslock>
    8000280c:	8526                	mv	a0,s1
    8000280e:	ffffe097          	auipc	ra,0xffffe
    80002812:	29e080e7          	jalr	670(ra) # 80000aac <acquire>
  ticks++;
    80002816:	00027517          	auipc	a0,0x27
    8000281a:	b8a50513          	addi	a0,a0,-1142 # 800293a0 <ticks>
    8000281e:	411c                	lw	a5,0(a0)
    80002820:	2785                	addiw	a5,a5,1
    80002822:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002824:	00000097          	auipc	ra,0x0
    80002828:	bc0080e7          	jalr	-1088(ra) # 800023e4 <wakeup>
  release(&tickslock);
    8000282c:	8526                	mv	a0,s1
    8000282e:	ffffe097          	auipc	ra,0xffffe
    80002832:	34e080e7          	jalr	846(ra) # 80000b7c <release>
}
    80002836:	60e2                	ld	ra,24(sp)
    80002838:	6442                	ld	s0,16(sp)
    8000283a:	64a2                	ld	s1,8(sp)
    8000283c:	6105                	addi	sp,sp,32
    8000283e:	8082                	ret

0000000080002840 <devintr>:
{
    80002840:	1101                	addi	sp,sp,-32
    80002842:	ec06                	sd	ra,24(sp)
    80002844:	e822                	sd	s0,16(sp)
    80002846:	e426                	sd	s1,8(sp)
    80002848:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000284a:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    8000284e:	00074d63          	bltz	a4,80002868 <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80002852:	57fd                	li	a5,-1
    80002854:	17fe                	slli	a5,a5,0x3f
    80002856:	0785                	addi	a5,a5,1
    return 0;
    80002858:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000285a:	06f70663          	beq	a4,a5,800028c6 <devintr+0x86>
}
    8000285e:	60e2                	ld	ra,24(sp)
    80002860:	6442                	ld	s0,16(sp)
    80002862:	64a2                	ld	s1,8(sp)
    80002864:	6105                	addi	sp,sp,32
    80002866:	8082                	ret
     (scause & 0xff) == 9){
    80002868:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000286c:	46a5                	li	a3,9
    8000286e:	fed792e3          	bne	a5,a3,80002852 <devintr+0x12>
    int irq = plic_claim();
    80002872:	00003097          	auipc	ra,0x3
    80002876:	6c0080e7          	jalr	1728(ra) # 80005f32 <plic_claim>
    8000287a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000287c:	47a9                	li	a5,10
    8000287e:	00f50e63          	beq	a0,a5,8000289a <devintr+0x5a>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    80002882:	fff5079b          	addiw	a5,a0,-1
    80002886:	4705                	li	a4,1
    80002888:	00f77e63          	bgeu	a4,a5,800028a4 <devintr+0x64>
    } else if(irq == E1000_IRQ){
    8000288c:	02100793          	li	a5,33
    80002890:	02f50663          	beq	a0,a5,800028bc <devintr+0x7c>
    return 1;
    80002894:	4505                	li	a0,1
    if(irq)
    80002896:	d4e1                	beqz	s1,8000285e <devintr+0x1e>
    80002898:	a819                	j	800028ae <devintr+0x6e>
      uartintr();
    8000289a:	ffffe097          	auipc	ra,0xffffe
    8000289e:	fb6080e7          	jalr	-74(ra) # 80000850 <uartintr>
    800028a2:	a031                	j	800028ae <devintr+0x6e>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    800028a4:	853e                	mv	a0,a5
    800028a6:	00004097          	auipc	ra,0x4
    800028aa:	c80080e7          	jalr	-896(ra) # 80006526 <virtio_disk_intr>
      plic_complete(irq);
    800028ae:	8526                	mv	a0,s1
    800028b0:	00003097          	auipc	ra,0x3
    800028b4:	6a6080e7          	jalr	1702(ra) # 80005f56 <plic_complete>
    return 1;
    800028b8:	4505                	li	a0,1
    800028ba:	b755                	j	8000285e <devintr+0x1e>
      e1000_intr();
    800028bc:	00004097          	auipc	ra,0x4
    800028c0:	038080e7          	jalr	56(ra) # 800068f4 <e1000_intr>
    800028c4:	b7ed                	j	800028ae <devintr+0x6e>
    if(cpuid() == 0){
    800028c6:	fffff097          	auipc	ra,0xfffff
    800028ca:	1b0080e7          	jalr	432(ra) # 80001a76 <cpuid>
    800028ce:	c901                	beqz	a0,800028de <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800028d0:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800028d4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800028d6:	14479073          	csrw	sip,a5
    return 2;
    800028da:	4509                	li	a0,2
    800028dc:	b749                	j	8000285e <devintr+0x1e>
      clockintr();
    800028de:	00000097          	auipc	ra,0x0
    800028e2:	f1c080e7          	jalr	-228(ra) # 800027fa <clockintr>
    800028e6:	b7ed                	j	800028d0 <devintr+0x90>

00000000800028e8 <usertrap>:
{
    800028e8:	7179                	addi	sp,sp,-48
    800028ea:	f406                	sd	ra,40(sp)
    800028ec:	f022                	sd	s0,32(sp)
    800028ee:	ec26                	sd	s1,24(sp)
    800028f0:	e84a                	sd	s2,16(sp)
    800028f2:	e44e                	sd	s3,8(sp)
    800028f4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028f6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028fa:	1007f793          	andi	a5,a5,256
    800028fe:	e3b5                	bnez	a5,80002962 <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002900:	00003797          	auipc	a5,0x3
    80002904:	51078793          	addi	a5,a5,1296 # 80005e10 <kernelvec>
    80002908:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000290c:	fffff097          	auipc	ra,0xfffff
    80002910:	196080e7          	jalr	406(ra) # 80001aa2 <myproc>
    80002914:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    80002916:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002918:	14102773          	csrr	a4,sepc
    8000291c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000291e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002922:	47a1                	li	a5,8
    80002924:	04f71d63          	bne	a4,a5,8000297e <usertrap+0x96>
    if(p->killed)
    80002928:	5d1c                	lw	a5,56(a0)
    8000292a:	e7a1                	bnez	a5,80002972 <usertrap+0x8a>
    p->tf->epc += 4;
    8000292c:	70b8                	ld	a4,96(s1)
    8000292e:	6f1c                	ld	a5,24(a4)
    80002930:	0791                	addi	a5,a5,4
    80002932:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002934:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002938:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000293c:	10079073          	csrw	sstatus,a5
    syscall();
    80002940:	00000097          	auipc	ra,0x0
    80002944:	2fe080e7          	jalr	766(ra) # 80002c3e <syscall>
  if(p->killed)
    80002948:	5c9c                	lw	a5,56(s1)
    8000294a:	e3cd                	bnez	a5,800029ec <usertrap+0x104>
  usertrapret();
    8000294c:	00000097          	auipc	ra,0x0
    80002950:	e10080e7          	jalr	-496(ra) # 8000275c <usertrapret>
}
    80002954:	70a2                	ld	ra,40(sp)
    80002956:	7402                	ld	s0,32(sp)
    80002958:	64e2                	ld	s1,24(sp)
    8000295a:	6942                	ld	s2,16(sp)
    8000295c:	69a2                	ld	s3,8(sp)
    8000295e:	6145                	addi	sp,sp,48
    80002960:	8082                	ret
    panic("usertrap: not from user mode");
    80002962:	00007517          	auipc	a0,0x7
    80002966:	c0e50513          	addi	a0,a0,-1010 # 80009570 <userret+0x4e0>
    8000296a:	ffffe097          	auipc	ra,0xffffe
    8000296e:	bf0080e7          	jalr	-1040(ra) # 8000055a <panic>
      exit(-1);
    80002972:	557d                	li	a0,-1
    80002974:	fffff097          	auipc	ra,0xfffff
    80002978:	7a0080e7          	jalr	1952(ra) # 80002114 <exit>
    8000297c:	bf45                	j	8000292c <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    8000297e:	00000097          	auipc	ra,0x0
    80002982:	ec2080e7          	jalr	-318(ra) # 80002840 <devintr>
    80002986:	892a                	mv	s2,a0
    80002988:	c501                	beqz	a0,80002990 <usertrap+0xa8>
  if(p->killed)
    8000298a:	5c9c                	lw	a5,56(s1)
    8000298c:	cba1                	beqz	a5,800029dc <usertrap+0xf4>
    8000298e:	a091                	j	800029d2 <usertrap+0xea>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002990:	142029f3          	csrr	s3,scause
    80002994:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    80002998:	00000097          	auipc	ra,0x0
    8000299c:	cea080e7          	jalr	-790(ra) # 80002682 <scause_desc>
    800029a0:	862a                	mv	a2,a0
    800029a2:	40b4                	lw	a3,64(s1)
    800029a4:	85ce                	mv	a1,s3
    800029a6:	00007517          	auipc	a0,0x7
    800029aa:	bea50513          	addi	a0,a0,-1046 # 80009590 <userret+0x500>
    800029ae:	ffffe097          	auipc	ra,0xffffe
    800029b2:	c06080e7          	jalr	-1018(ra) # 800005b4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029b6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029ba:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029be:	00007517          	auipc	a0,0x7
    800029c2:	c0250513          	addi	a0,a0,-1022 # 800095c0 <userret+0x530>
    800029c6:	ffffe097          	auipc	ra,0xffffe
    800029ca:	bee080e7          	jalr	-1042(ra) # 800005b4 <printf>
    p->killed = 1;
    800029ce:	4785                	li	a5,1
    800029d0:	dc9c                	sw	a5,56(s1)
    exit(-1);
    800029d2:	557d                	li	a0,-1
    800029d4:	fffff097          	auipc	ra,0xfffff
    800029d8:	740080e7          	jalr	1856(ra) # 80002114 <exit>
  if(which_dev == 2)
    800029dc:	4789                	li	a5,2
    800029de:	f6f917e3          	bne	s2,a5,8000294c <usertrap+0x64>
    yield();
    800029e2:	00000097          	auipc	ra,0x0
    800029e6:	840080e7          	jalr	-1984(ra) # 80002222 <yield>
    800029ea:	b78d                	j	8000294c <usertrap+0x64>
  int which_dev = 0;
    800029ec:	4901                	li	s2,0
    800029ee:	b7d5                	j	800029d2 <usertrap+0xea>

00000000800029f0 <kerneltrap>:
{
    800029f0:	7179                	addi	sp,sp,-48
    800029f2:	f406                	sd	ra,40(sp)
    800029f4:	f022                	sd	s0,32(sp)
    800029f6:	ec26                	sd	s1,24(sp)
    800029f8:	e84a                	sd	s2,16(sp)
    800029fa:	e44e                	sd	s3,8(sp)
    800029fc:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029fe:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a02:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a06:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a0a:	1004f793          	andi	a5,s1,256
    80002a0e:	cb85                	beqz	a5,80002a3e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a10:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a14:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a16:	ef85                	bnez	a5,80002a4e <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a18:	00000097          	auipc	ra,0x0
    80002a1c:	e28080e7          	jalr	-472(ra) # 80002840 <devintr>
    80002a20:	cd1d                	beqz	a0,80002a5e <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a22:	4789                	li	a5,2
    80002a24:	08f50063          	beq	a0,a5,80002aa4 <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a28:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a2c:	10049073          	csrw	sstatus,s1
}
    80002a30:	70a2                	ld	ra,40(sp)
    80002a32:	7402                	ld	s0,32(sp)
    80002a34:	64e2                	ld	s1,24(sp)
    80002a36:	6942                	ld	s2,16(sp)
    80002a38:	69a2                	ld	s3,8(sp)
    80002a3a:	6145                	addi	sp,sp,48
    80002a3c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a3e:	00007517          	auipc	a0,0x7
    80002a42:	ba250513          	addi	a0,a0,-1118 # 800095e0 <userret+0x550>
    80002a46:	ffffe097          	auipc	ra,0xffffe
    80002a4a:	b14080e7          	jalr	-1260(ra) # 8000055a <panic>
    panic("kerneltrap: interrupts enabled");
    80002a4e:	00007517          	auipc	a0,0x7
    80002a52:	bba50513          	addi	a0,a0,-1094 # 80009608 <userret+0x578>
    80002a56:	ffffe097          	auipc	ra,0xffffe
    80002a5a:	b04080e7          	jalr	-1276(ra) # 8000055a <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    80002a5e:	854e                	mv	a0,s3
    80002a60:	00000097          	auipc	ra,0x0
    80002a64:	c22080e7          	jalr	-990(ra) # 80002682 <scause_desc>
    80002a68:	862a                	mv	a2,a0
    80002a6a:	85ce                	mv	a1,s3
    80002a6c:	00007517          	auipc	a0,0x7
    80002a70:	bbc50513          	addi	a0,a0,-1092 # 80009628 <userret+0x598>
    80002a74:	ffffe097          	auipc	ra,0xffffe
    80002a78:	b40080e7          	jalr	-1216(ra) # 800005b4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a7c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a80:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a84:	00007517          	auipc	a0,0x7
    80002a88:	bb450513          	addi	a0,a0,-1100 # 80009638 <userret+0x5a8>
    80002a8c:	ffffe097          	auipc	ra,0xffffe
    80002a90:	b28080e7          	jalr	-1240(ra) # 800005b4 <printf>
    panic("kerneltrap");
    80002a94:	00007517          	auipc	a0,0x7
    80002a98:	bbc50513          	addi	a0,a0,-1092 # 80009650 <userret+0x5c0>
    80002a9c:	ffffe097          	auipc	ra,0xffffe
    80002aa0:	abe080e7          	jalr	-1346(ra) # 8000055a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002aa4:	fffff097          	auipc	ra,0xfffff
    80002aa8:	ffe080e7          	jalr	-2(ra) # 80001aa2 <myproc>
    80002aac:	dd35                	beqz	a0,80002a28 <kerneltrap+0x38>
    80002aae:	fffff097          	auipc	ra,0xfffff
    80002ab2:	ff4080e7          	jalr	-12(ra) # 80001aa2 <myproc>
    80002ab6:	5118                	lw	a4,32(a0)
    80002ab8:	478d                	li	a5,3
    80002aba:	f6f717e3          	bne	a4,a5,80002a28 <kerneltrap+0x38>
    yield();
    80002abe:	fffff097          	auipc	ra,0xfffff
    80002ac2:	764080e7          	jalr	1892(ra) # 80002222 <yield>
    80002ac6:	b78d                	j	80002a28 <kerneltrap+0x38>

0000000080002ac8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ac8:	1101                	addi	sp,sp,-32
    80002aca:	ec06                	sd	ra,24(sp)
    80002acc:	e822                	sd	s0,16(sp)
    80002ace:	e426                	sd	s1,8(sp)
    80002ad0:	1000                	addi	s0,sp,32
    80002ad2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ad4:	fffff097          	auipc	ra,0xfffff
    80002ad8:	fce080e7          	jalr	-50(ra) # 80001aa2 <myproc>
  switch (n) {
    80002adc:	4795                	li	a5,5
    80002ade:	0497e163          	bltu	a5,s1,80002b20 <argraw+0x58>
    80002ae2:	048a                	slli	s1,s1,0x2
    80002ae4:	00007717          	auipc	a4,0x7
    80002ae8:	3f470713          	addi	a4,a4,1012 # 80009ed8 <nointr_desc.1646+0x80>
    80002aec:	94ba                	add	s1,s1,a4
    80002aee:	409c                	lw	a5,0(s1)
    80002af0:	97ba                	add	a5,a5,a4
    80002af2:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    80002af4:	713c                	ld	a5,96(a0)
    80002af6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    80002af8:	60e2                	ld	ra,24(sp)
    80002afa:	6442                	ld	s0,16(sp)
    80002afc:	64a2                	ld	s1,8(sp)
    80002afe:	6105                	addi	sp,sp,32
    80002b00:	8082                	ret
    return p->tf->a1;
    80002b02:	713c                	ld	a5,96(a0)
    80002b04:	7fa8                	ld	a0,120(a5)
    80002b06:	bfcd                	j	80002af8 <argraw+0x30>
    return p->tf->a2;
    80002b08:	713c                	ld	a5,96(a0)
    80002b0a:	63c8                	ld	a0,128(a5)
    80002b0c:	b7f5                	j	80002af8 <argraw+0x30>
    return p->tf->a3;
    80002b0e:	713c                	ld	a5,96(a0)
    80002b10:	67c8                	ld	a0,136(a5)
    80002b12:	b7dd                	j	80002af8 <argraw+0x30>
    return p->tf->a4;
    80002b14:	713c                	ld	a5,96(a0)
    80002b16:	6bc8                	ld	a0,144(a5)
    80002b18:	b7c5                	j	80002af8 <argraw+0x30>
    return p->tf->a5;
    80002b1a:	713c                	ld	a5,96(a0)
    80002b1c:	6fc8                	ld	a0,152(a5)
    80002b1e:	bfe9                	j	80002af8 <argraw+0x30>
  panic("argraw");
    80002b20:	00007517          	auipc	a0,0x7
    80002b24:	d3850513          	addi	a0,a0,-712 # 80009858 <userret+0x7c8>
    80002b28:	ffffe097          	auipc	ra,0xffffe
    80002b2c:	a32080e7          	jalr	-1486(ra) # 8000055a <panic>

0000000080002b30 <fetchaddr>:
{
    80002b30:	1101                	addi	sp,sp,-32
    80002b32:	ec06                	sd	ra,24(sp)
    80002b34:	e822                	sd	s0,16(sp)
    80002b36:	e426                	sd	s1,8(sp)
    80002b38:	e04a                	sd	s2,0(sp)
    80002b3a:	1000                	addi	s0,sp,32
    80002b3c:	84aa                	mv	s1,a0
    80002b3e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b40:	fffff097          	auipc	ra,0xfffff
    80002b44:	f62080e7          	jalr	-158(ra) # 80001aa2 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002b48:	693c                	ld	a5,80(a0)
    80002b4a:	02f4f863          	bgeu	s1,a5,80002b7a <fetchaddr+0x4a>
    80002b4e:	00848713          	addi	a4,s1,8
    80002b52:	02e7e663          	bltu	a5,a4,80002b7e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b56:	46a1                	li	a3,8
    80002b58:	8626                	mv	a2,s1
    80002b5a:	85ca                	mv	a1,s2
    80002b5c:	6d28                	ld	a0,88(a0)
    80002b5e:	fffff097          	auipc	ra,0xfffff
    80002b62:	cc4080e7          	jalr	-828(ra) # 80001822 <copyin>
    80002b66:	00a03533          	snez	a0,a0
    80002b6a:	40a00533          	neg	a0,a0
}
    80002b6e:	60e2                	ld	ra,24(sp)
    80002b70:	6442                	ld	s0,16(sp)
    80002b72:	64a2                	ld	s1,8(sp)
    80002b74:	6902                	ld	s2,0(sp)
    80002b76:	6105                	addi	sp,sp,32
    80002b78:	8082                	ret
    return -1;
    80002b7a:	557d                	li	a0,-1
    80002b7c:	bfcd                	j	80002b6e <fetchaddr+0x3e>
    80002b7e:	557d                	li	a0,-1
    80002b80:	b7fd                	j	80002b6e <fetchaddr+0x3e>

0000000080002b82 <fetchstr>:
{
    80002b82:	7179                	addi	sp,sp,-48
    80002b84:	f406                	sd	ra,40(sp)
    80002b86:	f022                	sd	s0,32(sp)
    80002b88:	ec26                	sd	s1,24(sp)
    80002b8a:	e84a                	sd	s2,16(sp)
    80002b8c:	e44e                	sd	s3,8(sp)
    80002b8e:	1800                	addi	s0,sp,48
    80002b90:	892a                	mv	s2,a0
    80002b92:	84ae                	mv	s1,a1
    80002b94:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b96:	fffff097          	auipc	ra,0xfffff
    80002b9a:	f0c080e7          	jalr	-244(ra) # 80001aa2 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002b9e:	86ce                	mv	a3,s3
    80002ba0:	864a                	mv	a2,s2
    80002ba2:	85a6                	mv	a1,s1
    80002ba4:	6d28                	ld	a0,88(a0)
    80002ba6:	fffff097          	auipc	ra,0xfffff
    80002baa:	d08080e7          	jalr	-760(ra) # 800018ae <copyinstr>
  if(err < 0)
    80002bae:	00054763          	bltz	a0,80002bbc <fetchstr+0x3a>
  return strlen(buf);
    80002bb2:	8526                	mv	a0,s1
    80002bb4:	ffffe097          	auipc	ra,0xffffe
    80002bb8:	34e080e7          	jalr	846(ra) # 80000f02 <strlen>
}
    80002bbc:	70a2                	ld	ra,40(sp)
    80002bbe:	7402                	ld	s0,32(sp)
    80002bc0:	64e2                	ld	s1,24(sp)
    80002bc2:	6942                	ld	s2,16(sp)
    80002bc4:	69a2                	ld	s3,8(sp)
    80002bc6:	6145                	addi	sp,sp,48
    80002bc8:	8082                	ret

0000000080002bca <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002bca:	1101                	addi	sp,sp,-32
    80002bcc:	ec06                	sd	ra,24(sp)
    80002bce:	e822                	sd	s0,16(sp)
    80002bd0:	e426                	sd	s1,8(sp)
    80002bd2:	1000                	addi	s0,sp,32
    80002bd4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bd6:	00000097          	auipc	ra,0x0
    80002bda:	ef2080e7          	jalr	-270(ra) # 80002ac8 <argraw>
    80002bde:	c088                	sw	a0,0(s1)
  return 0;
}
    80002be0:	4501                	li	a0,0
    80002be2:	60e2                	ld	ra,24(sp)
    80002be4:	6442                	ld	s0,16(sp)
    80002be6:	64a2                	ld	s1,8(sp)
    80002be8:	6105                	addi	sp,sp,32
    80002bea:	8082                	ret

0000000080002bec <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002bec:	1101                	addi	sp,sp,-32
    80002bee:	ec06                	sd	ra,24(sp)
    80002bf0:	e822                	sd	s0,16(sp)
    80002bf2:	e426                	sd	s1,8(sp)
    80002bf4:	1000                	addi	s0,sp,32
    80002bf6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bf8:	00000097          	auipc	ra,0x0
    80002bfc:	ed0080e7          	jalr	-304(ra) # 80002ac8 <argraw>
    80002c00:	e088                	sd	a0,0(s1)
  return 0;
}
    80002c02:	4501                	li	a0,0
    80002c04:	60e2                	ld	ra,24(sp)
    80002c06:	6442                	ld	s0,16(sp)
    80002c08:	64a2                	ld	s1,8(sp)
    80002c0a:	6105                	addi	sp,sp,32
    80002c0c:	8082                	ret

0000000080002c0e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c0e:	1101                	addi	sp,sp,-32
    80002c10:	ec06                	sd	ra,24(sp)
    80002c12:	e822                	sd	s0,16(sp)
    80002c14:	e426                	sd	s1,8(sp)
    80002c16:	e04a                	sd	s2,0(sp)
    80002c18:	1000                	addi	s0,sp,32
    80002c1a:	84ae                	mv	s1,a1
    80002c1c:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002c1e:	00000097          	auipc	ra,0x0
    80002c22:	eaa080e7          	jalr	-342(ra) # 80002ac8 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002c26:	864a                	mv	a2,s2
    80002c28:	85a6                	mv	a1,s1
    80002c2a:	00000097          	auipc	ra,0x0
    80002c2e:	f58080e7          	jalr	-168(ra) # 80002b82 <fetchstr>
}
    80002c32:	60e2                	ld	ra,24(sp)
    80002c34:	6442                	ld	s0,16(sp)
    80002c36:	64a2                	ld	s1,8(sp)
    80002c38:	6902                	ld	s2,0(sp)
    80002c3a:	6105                	addi	sp,sp,32
    80002c3c:	8082                	ret

0000000080002c3e <syscall>:
[SYS_ntas]    sys_ntas,
};

void
syscall(void)
{
    80002c3e:	1101                	addi	sp,sp,-32
    80002c40:	ec06                	sd	ra,24(sp)
    80002c42:	e822                	sd	s0,16(sp)
    80002c44:	e426                	sd	s1,8(sp)
    80002c46:	e04a                	sd	s2,0(sp)
    80002c48:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c4a:	fffff097          	auipc	ra,0xfffff
    80002c4e:	e58080e7          	jalr	-424(ra) # 80001aa2 <myproc>
    80002c52:	84aa                	mv	s1,a0

  num = p->tf->a7;
    80002c54:	06053903          	ld	s2,96(a0)
    80002c58:	0a893783          	ld	a5,168(s2)
    80002c5c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c60:	37fd                	addiw	a5,a5,-1
    80002c62:	4759                	li	a4,22
    80002c64:	00f76f63          	bltu	a4,a5,80002c82 <syscall+0x44>
    80002c68:	00369713          	slli	a4,a3,0x3
    80002c6c:	00007797          	auipc	a5,0x7
    80002c70:	28478793          	addi	a5,a5,644 # 80009ef0 <syscalls>
    80002c74:	97ba                	add	a5,a5,a4
    80002c76:	639c                	ld	a5,0(a5)
    80002c78:	c789                	beqz	a5,80002c82 <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80002c7a:	9782                	jalr	a5
    80002c7c:	06a93823          	sd	a0,112(s2)
    80002c80:	a839                	j	80002c9e <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c82:	16048613          	addi	a2,s1,352
    80002c86:	40ac                	lw	a1,64(s1)
    80002c88:	00007517          	auipc	a0,0x7
    80002c8c:	bd850513          	addi	a0,a0,-1064 # 80009860 <userret+0x7d0>
    80002c90:	ffffe097          	auipc	ra,0xffffe
    80002c94:	924080e7          	jalr	-1756(ra) # 800005b4 <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80002c98:	70bc                	ld	a5,96(s1)
    80002c9a:	577d                	li	a4,-1
    80002c9c:	fbb8                	sd	a4,112(a5)
  }
}
    80002c9e:	60e2                	ld	ra,24(sp)
    80002ca0:	6442                	ld	s0,16(sp)
    80002ca2:	64a2                	ld	s1,8(sp)
    80002ca4:	6902                	ld	s2,0(sp)
    80002ca6:	6105                	addi	sp,sp,32
    80002ca8:	8082                	ret

0000000080002caa <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002caa:	1101                	addi	sp,sp,-32
    80002cac:	ec06                	sd	ra,24(sp)
    80002cae:	e822                	sd	s0,16(sp)
    80002cb0:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002cb2:	fec40593          	addi	a1,s0,-20
    80002cb6:	4501                	li	a0,0
    80002cb8:	00000097          	auipc	ra,0x0
    80002cbc:	f12080e7          	jalr	-238(ra) # 80002bca <argint>
    return -1;
    80002cc0:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002cc2:	00054963          	bltz	a0,80002cd4 <sys_exit+0x2a>
  exit(n);
    80002cc6:	fec42503          	lw	a0,-20(s0)
    80002cca:	fffff097          	auipc	ra,0xfffff
    80002cce:	44a080e7          	jalr	1098(ra) # 80002114 <exit>
  return 0;  // not reached
    80002cd2:	4781                	li	a5,0
}
    80002cd4:	853e                	mv	a0,a5
    80002cd6:	60e2                	ld	ra,24(sp)
    80002cd8:	6442                	ld	s0,16(sp)
    80002cda:	6105                	addi	sp,sp,32
    80002cdc:	8082                	ret

0000000080002cde <sys_getpid>:

uint64
sys_getpid(void)
{
    80002cde:	1141                	addi	sp,sp,-16
    80002ce0:	e406                	sd	ra,8(sp)
    80002ce2:	e022                	sd	s0,0(sp)
    80002ce4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ce6:	fffff097          	auipc	ra,0xfffff
    80002cea:	dbc080e7          	jalr	-580(ra) # 80001aa2 <myproc>
}
    80002cee:	4128                	lw	a0,64(a0)
    80002cf0:	60a2                	ld	ra,8(sp)
    80002cf2:	6402                	ld	s0,0(sp)
    80002cf4:	0141                	addi	sp,sp,16
    80002cf6:	8082                	ret

0000000080002cf8 <sys_fork>:

uint64
sys_fork(void)
{
    80002cf8:	1141                	addi	sp,sp,-16
    80002cfa:	e406                	sd	ra,8(sp)
    80002cfc:	e022                	sd	s0,0(sp)
    80002cfe:	0800                	addi	s0,sp,16
  return fork();
    80002d00:	fffff097          	auipc	ra,0xfffff
    80002d04:	10c080e7          	jalr	268(ra) # 80001e0c <fork>
}
    80002d08:	60a2                	ld	ra,8(sp)
    80002d0a:	6402                	ld	s0,0(sp)
    80002d0c:	0141                	addi	sp,sp,16
    80002d0e:	8082                	ret

0000000080002d10 <sys_wait>:

uint64
sys_wait(void)
{
    80002d10:	1101                	addi	sp,sp,-32
    80002d12:	ec06                	sd	ra,24(sp)
    80002d14:	e822                	sd	s0,16(sp)
    80002d16:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002d18:	fe840593          	addi	a1,s0,-24
    80002d1c:	4501                	li	a0,0
    80002d1e:	00000097          	auipc	ra,0x0
    80002d22:	ece080e7          	jalr	-306(ra) # 80002bec <argaddr>
    80002d26:	87aa                	mv	a5,a0
    return -1;
    80002d28:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002d2a:	0007c863          	bltz	a5,80002d3a <sys_wait+0x2a>
  return wait(p);
    80002d2e:	fe843503          	ld	a0,-24(s0)
    80002d32:	fffff097          	auipc	ra,0xfffff
    80002d36:	5aa080e7          	jalr	1450(ra) # 800022dc <wait>
}
    80002d3a:	60e2                	ld	ra,24(sp)
    80002d3c:	6442                	ld	s0,16(sp)
    80002d3e:	6105                	addi	sp,sp,32
    80002d40:	8082                	ret

0000000080002d42 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d42:	7179                	addi	sp,sp,-48
    80002d44:	f406                	sd	ra,40(sp)
    80002d46:	f022                	sd	s0,32(sp)
    80002d48:	ec26                	sd	s1,24(sp)
    80002d4a:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002d4c:	fdc40593          	addi	a1,s0,-36
    80002d50:	4501                	li	a0,0
    80002d52:	00000097          	auipc	ra,0x0
    80002d56:	e78080e7          	jalr	-392(ra) # 80002bca <argint>
    80002d5a:	87aa                	mv	a5,a0
    return -1;
    80002d5c:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002d5e:	0207c063          	bltz	a5,80002d7e <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002d62:	fffff097          	auipc	ra,0xfffff
    80002d66:	d40080e7          	jalr	-704(ra) # 80001aa2 <myproc>
    80002d6a:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002d6c:	fdc42503          	lw	a0,-36(s0)
    80002d70:	fffff097          	auipc	ra,0xfffff
    80002d74:	028080e7          	jalr	40(ra) # 80001d98 <growproc>
    80002d78:	00054863          	bltz	a0,80002d88 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002d7c:	8526                	mv	a0,s1
}
    80002d7e:	70a2                	ld	ra,40(sp)
    80002d80:	7402                	ld	s0,32(sp)
    80002d82:	64e2                	ld	s1,24(sp)
    80002d84:	6145                	addi	sp,sp,48
    80002d86:	8082                	ret
    return -1;
    80002d88:	557d                	li	a0,-1
    80002d8a:	bfd5                	j	80002d7e <sys_sbrk+0x3c>

0000000080002d8c <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d8c:	7139                	addi	sp,sp,-64
    80002d8e:	fc06                	sd	ra,56(sp)
    80002d90:	f822                	sd	s0,48(sp)
    80002d92:	f426                	sd	s1,40(sp)
    80002d94:	f04a                	sd	s2,32(sp)
    80002d96:	ec4e                	sd	s3,24(sp)
    80002d98:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002d9a:	fcc40593          	addi	a1,s0,-52
    80002d9e:	4501                	li	a0,0
    80002da0:	00000097          	auipc	ra,0x0
    80002da4:	e2a080e7          	jalr	-470(ra) # 80002bca <argint>
    return -1;
    80002da8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002daa:	06054563          	bltz	a0,80002e14 <sys_sleep+0x88>
  acquire(&tickslock);
    80002dae:	00014517          	auipc	a0,0x14
    80002db2:	d1250513          	addi	a0,a0,-750 # 80016ac0 <tickslock>
    80002db6:	ffffe097          	auipc	ra,0xffffe
    80002dba:	cf6080e7          	jalr	-778(ra) # 80000aac <acquire>
  ticks0 = ticks;
    80002dbe:	00026917          	auipc	s2,0x26
    80002dc2:	5e292903          	lw	s2,1506(s2) # 800293a0 <ticks>
  while(ticks - ticks0 < n){
    80002dc6:	fcc42783          	lw	a5,-52(s0)
    80002dca:	cf85                	beqz	a5,80002e02 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002dcc:	00014997          	auipc	s3,0x14
    80002dd0:	cf498993          	addi	s3,s3,-780 # 80016ac0 <tickslock>
    80002dd4:	00026497          	auipc	s1,0x26
    80002dd8:	5cc48493          	addi	s1,s1,1484 # 800293a0 <ticks>
    if(myproc()->killed){
    80002ddc:	fffff097          	auipc	ra,0xfffff
    80002de0:	cc6080e7          	jalr	-826(ra) # 80001aa2 <myproc>
    80002de4:	5d1c                	lw	a5,56(a0)
    80002de6:	ef9d                	bnez	a5,80002e24 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002de8:	85ce                	mv	a1,s3
    80002dea:	8526                	mv	a0,s1
    80002dec:	fffff097          	auipc	ra,0xfffff
    80002df0:	472080e7          	jalr	1138(ra) # 8000225e <sleep>
  while(ticks - ticks0 < n){
    80002df4:	409c                	lw	a5,0(s1)
    80002df6:	412787bb          	subw	a5,a5,s2
    80002dfa:	fcc42703          	lw	a4,-52(s0)
    80002dfe:	fce7efe3          	bltu	a5,a4,80002ddc <sys_sleep+0x50>
  }
  release(&tickslock);
    80002e02:	00014517          	auipc	a0,0x14
    80002e06:	cbe50513          	addi	a0,a0,-834 # 80016ac0 <tickslock>
    80002e0a:	ffffe097          	auipc	ra,0xffffe
    80002e0e:	d72080e7          	jalr	-654(ra) # 80000b7c <release>
  return 0;
    80002e12:	4781                	li	a5,0
}
    80002e14:	853e                	mv	a0,a5
    80002e16:	70e2                	ld	ra,56(sp)
    80002e18:	7442                	ld	s0,48(sp)
    80002e1a:	74a2                	ld	s1,40(sp)
    80002e1c:	7902                	ld	s2,32(sp)
    80002e1e:	69e2                	ld	s3,24(sp)
    80002e20:	6121                	addi	sp,sp,64
    80002e22:	8082                	ret
      release(&tickslock);
    80002e24:	00014517          	auipc	a0,0x14
    80002e28:	c9c50513          	addi	a0,a0,-868 # 80016ac0 <tickslock>
    80002e2c:	ffffe097          	auipc	ra,0xffffe
    80002e30:	d50080e7          	jalr	-688(ra) # 80000b7c <release>
      return -1;
    80002e34:	57fd                	li	a5,-1
    80002e36:	bff9                	j	80002e14 <sys_sleep+0x88>

0000000080002e38 <sys_kill>:

uint64
sys_kill(void)
{
    80002e38:	1101                	addi	sp,sp,-32
    80002e3a:	ec06                	sd	ra,24(sp)
    80002e3c:	e822                	sd	s0,16(sp)
    80002e3e:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002e40:	fec40593          	addi	a1,s0,-20
    80002e44:	4501                	li	a0,0
    80002e46:	00000097          	auipc	ra,0x0
    80002e4a:	d84080e7          	jalr	-636(ra) # 80002bca <argint>
    80002e4e:	87aa                	mv	a5,a0
    return -1;
    80002e50:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002e52:	0007c863          	bltz	a5,80002e62 <sys_kill+0x2a>
  return kill(pid);
    80002e56:	fec42503          	lw	a0,-20(s0)
    80002e5a:	fffff097          	auipc	ra,0xfffff
    80002e5e:	5f4080e7          	jalr	1524(ra) # 8000244e <kill>
}
    80002e62:	60e2                	ld	ra,24(sp)
    80002e64:	6442                	ld	s0,16(sp)
    80002e66:	6105                	addi	sp,sp,32
    80002e68:	8082                	ret

0000000080002e6a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e6a:	1101                	addi	sp,sp,-32
    80002e6c:	ec06                	sd	ra,24(sp)
    80002e6e:	e822                	sd	s0,16(sp)
    80002e70:	e426                	sd	s1,8(sp)
    80002e72:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e74:	00014517          	auipc	a0,0x14
    80002e78:	c4c50513          	addi	a0,a0,-948 # 80016ac0 <tickslock>
    80002e7c:	ffffe097          	auipc	ra,0xffffe
    80002e80:	c30080e7          	jalr	-976(ra) # 80000aac <acquire>
  xticks = ticks;
    80002e84:	00026497          	auipc	s1,0x26
    80002e88:	51c4a483          	lw	s1,1308(s1) # 800293a0 <ticks>
  release(&tickslock);
    80002e8c:	00014517          	auipc	a0,0x14
    80002e90:	c3450513          	addi	a0,a0,-972 # 80016ac0 <tickslock>
    80002e94:	ffffe097          	auipc	ra,0xffffe
    80002e98:	ce8080e7          	jalr	-792(ra) # 80000b7c <release>
  return xticks;
}
    80002e9c:	02049513          	slli	a0,s1,0x20
    80002ea0:	9101                	srli	a0,a0,0x20
    80002ea2:	60e2                	ld	ra,24(sp)
    80002ea4:	6442                	ld	s0,16(sp)
    80002ea6:	64a2                	ld	s1,8(sp)
    80002ea8:	6105                	addi	sp,sp,32
    80002eaa:	8082                	ret

0000000080002eac <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002eac:	7179                	addi	sp,sp,-48
    80002eae:	f406                	sd	ra,40(sp)
    80002eb0:	f022                	sd	s0,32(sp)
    80002eb2:	ec26                	sd	s1,24(sp)
    80002eb4:	e84a                	sd	s2,16(sp)
    80002eb6:	e44e                	sd	s3,8(sp)
    80002eb8:	e052                	sd	s4,0(sp)
    80002eba:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ebc:	00006597          	auipc	a1,0x6
    80002ec0:	3fc58593          	addi	a1,a1,1020 # 800092b8 <userret+0x228>
    80002ec4:	00014517          	auipc	a0,0x14
    80002ec8:	c1c50513          	addi	a0,a0,-996 # 80016ae0 <bcache>
    80002ecc:	ffffe097          	auipc	ra,0xffffe
    80002ed0:	b0c080e7          	jalr	-1268(ra) # 800009d8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ed4:	0001c797          	auipc	a5,0x1c
    80002ed8:	c0c78793          	addi	a5,a5,-1012 # 8001eae0 <bcache+0x8000>
    80002edc:	0001c717          	auipc	a4,0x1c
    80002ee0:	f6470713          	addi	a4,a4,-156 # 8001ee40 <bcache+0x8360>
    80002ee4:	3ae7b823          	sd	a4,944(a5)
  bcache.head.next = &bcache.head;
    80002ee8:	3ae7bc23          	sd	a4,952(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002eec:	00014497          	auipc	s1,0x14
    80002ef0:	c1448493          	addi	s1,s1,-1004 # 80016b00 <bcache+0x20>
    b->next = bcache.head.next;
    80002ef4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ef6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ef8:	00007a17          	auipc	s4,0x7
    80002efc:	988a0a13          	addi	s4,s4,-1656 # 80009880 <userret+0x7f0>
    b->next = bcache.head.next;
    80002f00:	3b893783          	ld	a5,952(s2)
    80002f04:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    80002f06:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    80002f0a:	85d2                	mv	a1,s4
    80002f0c:	01048513          	addi	a0,s1,16
    80002f10:	00001097          	auipc	ra,0x1
    80002f14:	5a0080e7          	jalr	1440(ra) # 800044b0 <initsleeplock>
    bcache.head.next->prev = b;
    80002f18:	3b893783          	ld	a5,952(s2)
    80002f1c:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    80002f1e:	3a993c23          	sd	s1,952(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f22:	46048493          	addi	s1,s1,1120
    80002f26:	fd349de3          	bne	s1,s3,80002f00 <binit+0x54>
  }
}
    80002f2a:	70a2                	ld	ra,40(sp)
    80002f2c:	7402                	ld	s0,32(sp)
    80002f2e:	64e2                	ld	s1,24(sp)
    80002f30:	6942                	ld	s2,16(sp)
    80002f32:	69a2                	ld	s3,8(sp)
    80002f34:	6a02                	ld	s4,0(sp)
    80002f36:	6145                	addi	sp,sp,48
    80002f38:	8082                	ret

0000000080002f3a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f3a:	7179                	addi	sp,sp,-48
    80002f3c:	f406                	sd	ra,40(sp)
    80002f3e:	f022                	sd	s0,32(sp)
    80002f40:	ec26                	sd	s1,24(sp)
    80002f42:	e84a                	sd	s2,16(sp)
    80002f44:	e44e                	sd	s3,8(sp)
    80002f46:	1800                	addi	s0,sp,48
    80002f48:	89aa                	mv	s3,a0
    80002f4a:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002f4c:	00014517          	auipc	a0,0x14
    80002f50:	b9450513          	addi	a0,a0,-1132 # 80016ae0 <bcache>
    80002f54:	ffffe097          	auipc	ra,0xffffe
    80002f58:	b58080e7          	jalr	-1192(ra) # 80000aac <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f5c:	0001c497          	auipc	s1,0x1c
    80002f60:	f3c4b483          	ld	s1,-196(s1) # 8001ee98 <bcache+0x83b8>
    80002f64:	0001c797          	auipc	a5,0x1c
    80002f68:	edc78793          	addi	a5,a5,-292 # 8001ee40 <bcache+0x8360>
    80002f6c:	02f48f63          	beq	s1,a5,80002faa <bread+0x70>
    80002f70:	873e                	mv	a4,a5
    80002f72:	a021                	j	80002f7a <bread+0x40>
    80002f74:	6ca4                	ld	s1,88(s1)
    80002f76:	02e48a63          	beq	s1,a4,80002faa <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f7a:	449c                	lw	a5,8(s1)
    80002f7c:	ff379ce3          	bne	a5,s3,80002f74 <bread+0x3a>
    80002f80:	44dc                	lw	a5,12(s1)
    80002f82:	ff2799e3          	bne	a5,s2,80002f74 <bread+0x3a>
      b->refcnt++;
    80002f86:	44bc                	lw	a5,72(s1)
    80002f88:	2785                	addiw	a5,a5,1
    80002f8a:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80002f8c:	00014517          	auipc	a0,0x14
    80002f90:	b5450513          	addi	a0,a0,-1196 # 80016ae0 <bcache>
    80002f94:	ffffe097          	auipc	ra,0xffffe
    80002f98:	be8080e7          	jalr	-1048(ra) # 80000b7c <release>
      acquiresleep(&b->lock);
    80002f9c:	01048513          	addi	a0,s1,16
    80002fa0:	00001097          	auipc	ra,0x1
    80002fa4:	54a080e7          	jalr	1354(ra) # 800044ea <acquiresleep>
      return b;
    80002fa8:	a8b9                	j	80003006 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002faa:	0001c497          	auipc	s1,0x1c
    80002fae:	ee64b483          	ld	s1,-282(s1) # 8001ee90 <bcache+0x83b0>
    80002fb2:	0001c797          	auipc	a5,0x1c
    80002fb6:	e8e78793          	addi	a5,a5,-370 # 8001ee40 <bcache+0x8360>
    80002fba:	00f48863          	beq	s1,a5,80002fca <bread+0x90>
    80002fbe:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002fc0:	44bc                	lw	a5,72(s1)
    80002fc2:	cf81                	beqz	a5,80002fda <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fc4:	68a4                	ld	s1,80(s1)
    80002fc6:	fee49de3          	bne	s1,a4,80002fc0 <bread+0x86>
  panic("bget: no buffers");
    80002fca:	00007517          	auipc	a0,0x7
    80002fce:	8be50513          	addi	a0,a0,-1858 # 80009888 <userret+0x7f8>
    80002fd2:	ffffd097          	auipc	ra,0xffffd
    80002fd6:	588080e7          	jalr	1416(ra) # 8000055a <panic>
      b->dev = dev;
    80002fda:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002fde:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002fe2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002fe6:	4785                	li	a5,1
    80002fe8:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80002fea:	00014517          	auipc	a0,0x14
    80002fee:	af650513          	addi	a0,a0,-1290 # 80016ae0 <bcache>
    80002ff2:	ffffe097          	auipc	ra,0xffffe
    80002ff6:	b8a080e7          	jalr	-1142(ra) # 80000b7c <release>
      acquiresleep(&b->lock);
    80002ffa:	01048513          	addi	a0,s1,16
    80002ffe:	00001097          	auipc	ra,0x1
    80003002:	4ec080e7          	jalr	1260(ra) # 800044ea <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003006:	409c                	lw	a5,0(s1)
    80003008:	cb89                	beqz	a5,8000301a <bread+0xe0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    8000300a:	8526                	mv	a0,s1
    8000300c:	70a2                	ld	ra,40(sp)
    8000300e:	7402                	ld	s0,32(sp)
    80003010:	64e2                	ld	s1,24(sp)
    80003012:	6942                	ld	s2,16(sp)
    80003014:	69a2                	ld	s3,8(sp)
    80003016:	6145                	addi	sp,sp,48
    80003018:	8082                	ret
    virtio_disk_rw(b->dev, b, 0);
    8000301a:	4601                	li	a2,0
    8000301c:	85a6                	mv	a1,s1
    8000301e:	4488                	lw	a0,8(s1)
    80003020:	00003097          	auipc	ra,0x3
    80003024:	1e4080e7          	jalr	484(ra) # 80006204 <virtio_disk_rw>
    b->valid = 1;
    80003028:	4785                	li	a5,1
    8000302a:	c09c                	sw	a5,0(s1)
  return b;
    8000302c:	bff9                	j	8000300a <bread+0xd0>

000000008000302e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000302e:	1101                	addi	sp,sp,-32
    80003030:	ec06                	sd	ra,24(sp)
    80003032:	e822                	sd	s0,16(sp)
    80003034:	e426                	sd	s1,8(sp)
    80003036:	1000                	addi	s0,sp,32
    80003038:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000303a:	0541                	addi	a0,a0,16
    8000303c:	00001097          	auipc	ra,0x1
    80003040:	548080e7          	jalr	1352(ra) # 80004584 <holdingsleep>
    80003044:	cd09                	beqz	a0,8000305e <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    80003046:	4605                	li	a2,1
    80003048:	85a6                	mv	a1,s1
    8000304a:	4488                	lw	a0,8(s1)
    8000304c:	00003097          	auipc	ra,0x3
    80003050:	1b8080e7          	jalr	440(ra) # 80006204 <virtio_disk_rw>
}
    80003054:	60e2                	ld	ra,24(sp)
    80003056:	6442                	ld	s0,16(sp)
    80003058:	64a2                	ld	s1,8(sp)
    8000305a:	6105                	addi	sp,sp,32
    8000305c:	8082                	ret
    panic("bwrite");
    8000305e:	00007517          	auipc	a0,0x7
    80003062:	84250513          	addi	a0,a0,-1982 # 800098a0 <userret+0x810>
    80003066:	ffffd097          	auipc	ra,0xffffd
    8000306a:	4f4080e7          	jalr	1268(ra) # 8000055a <panic>

000000008000306e <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    8000306e:	1101                	addi	sp,sp,-32
    80003070:	ec06                	sd	ra,24(sp)
    80003072:	e822                	sd	s0,16(sp)
    80003074:	e426                	sd	s1,8(sp)
    80003076:	e04a                	sd	s2,0(sp)
    80003078:	1000                	addi	s0,sp,32
    8000307a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000307c:	01050913          	addi	s2,a0,16
    80003080:	854a                	mv	a0,s2
    80003082:	00001097          	auipc	ra,0x1
    80003086:	502080e7          	jalr	1282(ra) # 80004584 <holdingsleep>
    8000308a:	c92d                	beqz	a0,800030fc <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000308c:	854a                	mv	a0,s2
    8000308e:	00001097          	auipc	ra,0x1
    80003092:	4b2080e7          	jalr	1202(ra) # 80004540 <releasesleep>

  acquire(&bcache.lock);
    80003096:	00014517          	auipc	a0,0x14
    8000309a:	a4a50513          	addi	a0,a0,-1462 # 80016ae0 <bcache>
    8000309e:	ffffe097          	auipc	ra,0xffffe
    800030a2:	a0e080e7          	jalr	-1522(ra) # 80000aac <acquire>
  b->refcnt--;
    800030a6:	44bc                	lw	a5,72(s1)
    800030a8:	37fd                	addiw	a5,a5,-1
    800030aa:	0007871b          	sext.w	a4,a5
    800030ae:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    800030b0:	eb05                	bnez	a4,800030e0 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030b2:	6cbc                	ld	a5,88(s1)
    800030b4:	68b8                	ld	a4,80(s1)
    800030b6:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    800030b8:	68bc                	ld	a5,80(s1)
    800030ba:	6cb8                	ld	a4,88(s1)
    800030bc:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    800030be:	0001c797          	auipc	a5,0x1c
    800030c2:	a2278793          	addi	a5,a5,-1502 # 8001eae0 <bcache+0x8000>
    800030c6:	3b87b703          	ld	a4,952(a5)
    800030ca:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    800030cc:	0001c717          	auipc	a4,0x1c
    800030d0:	d7470713          	addi	a4,a4,-652 # 8001ee40 <bcache+0x8360>
    800030d4:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    800030d6:	3b87b703          	ld	a4,952(a5)
    800030da:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    800030dc:	3a97bc23          	sd	s1,952(a5)
  }
  
  release(&bcache.lock);
    800030e0:	00014517          	auipc	a0,0x14
    800030e4:	a0050513          	addi	a0,a0,-1536 # 80016ae0 <bcache>
    800030e8:	ffffe097          	auipc	ra,0xffffe
    800030ec:	a94080e7          	jalr	-1388(ra) # 80000b7c <release>
}
    800030f0:	60e2                	ld	ra,24(sp)
    800030f2:	6442                	ld	s0,16(sp)
    800030f4:	64a2                	ld	s1,8(sp)
    800030f6:	6902                	ld	s2,0(sp)
    800030f8:	6105                	addi	sp,sp,32
    800030fa:	8082                	ret
    panic("brelse");
    800030fc:	00006517          	auipc	a0,0x6
    80003100:	7ac50513          	addi	a0,a0,1964 # 800098a8 <userret+0x818>
    80003104:	ffffd097          	auipc	ra,0xffffd
    80003108:	456080e7          	jalr	1110(ra) # 8000055a <panic>

000000008000310c <bpin>:

void
bpin(struct buf *b) {
    8000310c:	1101                	addi	sp,sp,-32
    8000310e:	ec06                	sd	ra,24(sp)
    80003110:	e822                	sd	s0,16(sp)
    80003112:	e426                	sd	s1,8(sp)
    80003114:	1000                	addi	s0,sp,32
    80003116:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003118:	00014517          	auipc	a0,0x14
    8000311c:	9c850513          	addi	a0,a0,-1592 # 80016ae0 <bcache>
    80003120:	ffffe097          	auipc	ra,0xffffe
    80003124:	98c080e7          	jalr	-1652(ra) # 80000aac <acquire>
  b->refcnt++;
    80003128:	44bc                	lw	a5,72(s1)
    8000312a:	2785                	addiw	a5,a5,1
    8000312c:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    8000312e:	00014517          	auipc	a0,0x14
    80003132:	9b250513          	addi	a0,a0,-1614 # 80016ae0 <bcache>
    80003136:	ffffe097          	auipc	ra,0xffffe
    8000313a:	a46080e7          	jalr	-1466(ra) # 80000b7c <release>
}
    8000313e:	60e2                	ld	ra,24(sp)
    80003140:	6442                	ld	s0,16(sp)
    80003142:	64a2                	ld	s1,8(sp)
    80003144:	6105                	addi	sp,sp,32
    80003146:	8082                	ret

0000000080003148 <bunpin>:

void
bunpin(struct buf *b) {
    80003148:	1101                	addi	sp,sp,-32
    8000314a:	ec06                	sd	ra,24(sp)
    8000314c:	e822                	sd	s0,16(sp)
    8000314e:	e426                	sd	s1,8(sp)
    80003150:	1000                	addi	s0,sp,32
    80003152:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003154:	00014517          	auipc	a0,0x14
    80003158:	98c50513          	addi	a0,a0,-1652 # 80016ae0 <bcache>
    8000315c:	ffffe097          	auipc	ra,0xffffe
    80003160:	950080e7          	jalr	-1712(ra) # 80000aac <acquire>
  b->refcnt--;
    80003164:	44bc                	lw	a5,72(s1)
    80003166:	37fd                	addiw	a5,a5,-1
    80003168:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    8000316a:	00014517          	auipc	a0,0x14
    8000316e:	97650513          	addi	a0,a0,-1674 # 80016ae0 <bcache>
    80003172:	ffffe097          	auipc	ra,0xffffe
    80003176:	a0a080e7          	jalr	-1526(ra) # 80000b7c <release>
}
    8000317a:	60e2                	ld	ra,24(sp)
    8000317c:	6442                	ld	s0,16(sp)
    8000317e:	64a2                	ld	s1,8(sp)
    80003180:	6105                	addi	sp,sp,32
    80003182:	8082                	ret

0000000080003184 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003184:	1101                	addi	sp,sp,-32
    80003186:	ec06                	sd	ra,24(sp)
    80003188:	e822                	sd	s0,16(sp)
    8000318a:	e426                	sd	s1,8(sp)
    8000318c:	e04a                	sd	s2,0(sp)
    8000318e:	1000                	addi	s0,sp,32
    80003190:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003192:	00d5d59b          	srliw	a1,a1,0xd
    80003196:	0001c797          	auipc	a5,0x1c
    8000319a:	1267a783          	lw	a5,294(a5) # 8001f2bc <sb+0x1c>
    8000319e:	9dbd                	addw	a1,a1,a5
    800031a0:	00000097          	auipc	ra,0x0
    800031a4:	d9a080e7          	jalr	-614(ra) # 80002f3a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031a8:	0074f713          	andi	a4,s1,7
    800031ac:	4785                	li	a5,1
    800031ae:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031b2:	14ce                	slli	s1,s1,0x33
    800031b4:	90d9                	srli	s1,s1,0x36
    800031b6:	00950733          	add	a4,a0,s1
    800031ba:	06074703          	lbu	a4,96(a4)
    800031be:	00e7f6b3          	and	a3,a5,a4
    800031c2:	c69d                	beqz	a3,800031f0 <bfree+0x6c>
    800031c4:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031c6:	94aa                	add	s1,s1,a0
    800031c8:	fff7c793          	not	a5,a5
    800031cc:	8ff9                	and	a5,a5,a4
    800031ce:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    800031d2:	00001097          	auipc	ra,0x1
    800031d6:	19e080e7          	jalr	414(ra) # 80004370 <log_write>
  brelse(bp);
    800031da:	854a                	mv	a0,s2
    800031dc:	00000097          	auipc	ra,0x0
    800031e0:	e92080e7          	jalr	-366(ra) # 8000306e <brelse>
}
    800031e4:	60e2                	ld	ra,24(sp)
    800031e6:	6442                	ld	s0,16(sp)
    800031e8:	64a2                	ld	s1,8(sp)
    800031ea:	6902                	ld	s2,0(sp)
    800031ec:	6105                	addi	sp,sp,32
    800031ee:	8082                	ret
    panic("freeing free block");
    800031f0:	00006517          	auipc	a0,0x6
    800031f4:	6c050513          	addi	a0,a0,1728 # 800098b0 <userret+0x820>
    800031f8:	ffffd097          	auipc	ra,0xffffd
    800031fc:	362080e7          	jalr	866(ra) # 8000055a <panic>

0000000080003200 <balloc>:
{
    80003200:	711d                	addi	sp,sp,-96
    80003202:	ec86                	sd	ra,88(sp)
    80003204:	e8a2                	sd	s0,80(sp)
    80003206:	e4a6                	sd	s1,72(sp)
    80003208:	e0ca                	sd	s2,64(sp)
    8000320a:	fc4e                	sd	s3,56(sp)
    8000320c:	f852                	sd	s4,48(sp)
    8000320e:	f456                	sd	s5,40(sp)
    80003210:	f05a                	sd	s6,32(sp)
    80003212:	ec5e                	sd	s7,24(sp)
    80003214:	e862                	sd	s8,16(sp)
    80003216:	e466                	sd	s9,8(sp)
    80003218:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000321a:	0001c797          	auipc	a5,0x1c
    8000321e:	08a7a783          	lw	a5,138(a5) # 8001f2a4 <sb+0x4>
    80003222:	cbd1                	beqz	a5,800032b6 <balloc+0xb6>
    80003224:	8baa                	mv	s7,a0
    80003226:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003228:	0001cb17          	auipc	s6,0x1c
    8000322c:	078b0b13          	addi	s6,s6,120 # 8001f2a0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003230:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003232:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003234:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003236:	6c89                	lui	s9,0x2
    80003238:	a831                	j	80003254 <balloc+0x54>
    brelse(bp);
    8000323a:	854a                	mv	a0,s2
    8000323c:	00000097          	auipc	ra,0x0
    80003240:	e32080e7          	jalr	-462(ra) # 8000306e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003244:	015c87bb          	addw	a5,s9,s5
    80003248:	00078a9b          	sext.w	s5,a5
    8000324c:	004b2703          	lw	a4,4(s6)
    80003250:	06eaf363          	bgeu	s5,a4,800032b6 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003254:	41fad79b          	sraiw	a5,s5,0x1f
    80003258:	0137d79b          	srliw	a5,a5,0x13
    8000325c:	015787bb          	addw	a5,a5,s5
    80003260:	40d7d79b          	sraiw	a5,a5,0xd
    80003264:	01cb2583          	lw	a1,28(s6)
    80003268:	9dbd                	addw	a1,a1,a5
    8000326a:	855e                	mv	a0,s7
    8000326c:	00000097          	auipc	ra,0x0
    80003270:	cce080e7          	jalr	-818(ra) # 80002f3a <bread>
    80003274:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003276:	004b2503          	lw	a0,4(s6)
    8000327a:	000a849b          	sext.w	s1,s5
    8000327e:	8662                	mv	a2,s8
    80003280:	faa4fde3          	bgeu	s1,a0,8000323a <balloc+0x3a>
      m = 1 << (bi % 8);
    80003284:	41f6579b          	sraiw	a5,a2,0x1f
    80003288:	01d7d69b          	srliw	a3,a5,0x1d
    8000328c:	00c6873b          	addw	a4,a3,a2
    80003290:	00777793          	andi	a5,a4,7
    80003294:	9f95                	subw	a5,a5,a3
    80003296:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000329a:	4037571b          	sraiw	a4,a4,0x3
    8000329e:	00e906b3          	add	a3,s2,a4
    800032a2:	0606c683          	lbu	a3,96(a3)
    800032a6:	00d7f5b3          	and	a1,a5,a3
    800032aa:	cd91                	beqz	a1,800032c6 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032ac:	2605                	addiw	a2,a2,1
    800032ae:	2485                	addiw	s1,s1,1
    800032b0:	fd4618e3          	bne	a2,s4,80003280 <balloc+0x80>
    800032b4:	b759                	j	8000323a <balloc+0x3a>
  panic("balloc: out of blocks");
    800032b6:	00006517          	auipc	a0,0x6
    800032ba:	61250513          	addi	a0,a0,1554 # 800098c8 <userret+0x838>
    800032be:	ffffd097          	auipc	ra,0xffffd
    800032c2:	29c080e7          	jalr	668(ra) # 8000055a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032c6:	974a                	add	a4,a4,s2
    800032c8:	8fd5                	or	a5,a5,a3
    800032ca:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    800032ce:	854a                	mv	a0,s2
    800032d0:	00001097          	auipc	ra,0x1
    800032d4:	0a0080e7          	jalr	160(ra) # 80004370 <log_write>
        brelse(bp);
    800032d8:	854a                	mv	a0,s2
    800032da:	00000097          	auipc	ra,0x0
    800032de:	d94080e7          	jalr	-620(ra) # 8000306e <brelse>
  bp = bread(dev, bno);
    800032e2:	85a6                	mv	a1,s1
    800032e4:	855e                	mv	a0,s7
    800032e6:	00000097          	auipc	ra,0x0
    800032ea:	c54080e7          	jalr	-940(ra) # 80002f3a <bread>
    800032ee:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032f0:	40000613          	li	a2,1024
    800032f4:	4581                	li	a1,0
    800032f6:	06050513          	addi	a0,a0,96
    800032fa:	ffffe097          	auipc	ra,0xffffe
    800032fe:	a80080e7          	jalr	-1408(ra) # 80000d7a <memset>
  log_write(bp);
    80003302:	854a                	mv	a0,s2
    80003304:	00001097          	auipc	ra,0x1
    80003308:	06c080e7          	jalr	108(ra) # 80004370 <log_write>
  brelse(bp);
    8000330c:	854a                	mv	a0,s2
    8000330e:	00000097          	auipc	ra,0x0
    80003312:	d60080e7          	jalr	-672(ra) # 8000306e <brelse>
}
    80003316:	8526                	mv	a0,s1
    80003318:	60e6                	ld	ra,88(sp)
    8000331a:	6446                	ld	s0,80(sp)
    8000331c:	64a6                	ld	s1,72(sp)
    8000331e:	6906                	ld	s2,64(sp)
    80003320:	79e2                	ld	s3,56(sp)
    80003322:	7a42                	ld	s4,48(sp)
    80003324:	7aa2                	ld	s5,40(sp)
    80003326:	7b02                	ld	s6,32(sp)
    80003328:	6be2                	ld	s7,24(sp)
    8000332a:	6c42                	ld	s8,16(sp)
    8000332c:	6ca2                	ld	s9,8(sp)
    8000332e:	6125                	addi	sp,sp,96
    80003330:	8082                	ret

0000000080003332 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003332:	7179                	addi	sp,sp,-48
    80003334:	f406                	sd	ra,40(sp)
    80003336:	f022                	sd	s0,32(sp)
    80003338:	ec26                	sd	s1,24(sp)
    8000333a:	e84a                	sd	s2,16(sp)
    8000333c:	e44e                	sd	s3,8(sp)
    8000333e:	e052                	sd	s4,0(sp)
    80003340:	1800                	addi	s0,sp,48
    80003342:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003344:	47ad                	li	a5,11
    80003346:	04b7fe63          	bgeu	a5,a1,800033a2 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000334a:	ff45849b          	addiw	s1,a1,-12
    8000334e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003352:	0ff00793          	li	a5,255
    80003356:	0ae7e363          	bltu	a5,a4,800033fc <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000335a:	08852583          	lw	a1,136(a0)
    8000335e:	c5ad                	beqz	a1,800033c8 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003360:	00092503          	lw	a0,0(s2)
    80003364:	00000097          	auipc	ra,0x0
    80003368:	bd6080e7          	jalr	-1066(ra) # 80002f3a <bread>
    8000336c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000336e:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    80003372:	02049593          	slli	a1,s1,0x20
    80003376:	9181                	srli	a1,a1,0x20
    80003378:	058a                	slli	a1,a1,0x2
    8000337a:	00b784b3          	add	s1,a5,a1
    8000337e:	0004a983          	lw	s3,0(s1)
    80003382:	04098d63          	beqz	s3,800033dc <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003386:	8552                	mv	a0,s4
    80003388:	00000097          	auipc	ra,0x0
    8000338c:	ce6080e7          	jalr	-794(ra) # 8000306e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003390:	854e                	mv	a0,s3
    80003392:	70a2                	ld	ra,40(sp)
    80003394:	7402                	ld	s0,32(sp)
    80003396:	64e2                	ld	s1,24(sp)
    80003398:	6942                	ld	s2,16(sp)
    8000339a:	69a2                	ld	s3,8(sp)
    8000339c:	6a02                	ld	s4,0(sp)
    8000339e:	6145                	addi	sp,sp,48
    800033a0:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800033a2:	02059493          	slli	s1,a1,0x20
    800033a6:	9081                	srli	s1,s1,0x20
    800033a8:	048a                	slli	s1,s1,0x2
    800033aa:	94aa                	add	s1,s1,a0
    800033ac:	0584a983          	lw	s3,88(s1)
    800033b0:	fe0990e3          	bnez	s3,80003390 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800033b4:	4108                	lw	a0,0(a0)
    800033b6:	00000097          	auipc	ra,0x0
    800033ba:	e4a080e7          	jalr	-438(ra) # 80003200 <balloc>
    800033be:	0005099b          	sext.w	s3,a0
    800033c2:	0534ac23          	sw	s3,88(s1)
    800033c6:	b7e9                	j	80003390 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800033c8:	4108                	lw	a0,0(a0)
    800033ca:	00000097          	auipc	ra,0x0
    800033ce:	e36080e7          	jalr	-458(ra) # 80003200 <balloc>
    800033d2:	0005059b          	sext.w	a1,a0
    800033d6:	08b92423          	sw	a1,136(s2)
    800033da:	b759                	j	80003360 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800033dc:	00092503          	lw	a0,0(s2)
    800033e0:	00000097          	auipc	ra,0x0
    800033e4:	e20080e7          	jalr	-480(ra) # 80003200 <balloc>
    800033e8:	0005099b          	sext.w	s3,a0
    800033ec:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800033f0:	8552                	mv	a0,s4
    800033f2:	00001097          	auipc	ra,0x1
    800033f6:	f7e080e7          	jalr	-130(ra) # 80004370 <log_write>
    800033fa:	b771                	j	80003386 <bmap+0x54>
  panic("bmap: out of range");
    800033fc:	00006517          	auipc	a0,0x6
    80003400:	4e450513          	addi	a0,a0,1252 # 800098e0 <userret+0x850>
    80003404:	ffffd097          	auipc	ra,0xffffd
    80003408:	156080e7          	jalr	342(ra) # 8000055a <panic>

000000008000340c <iget>:
{
    8000340c:	7179                	addi	sp,sp,-48
    8000340e:	f406                	sd	ra,40(sp)
    80003410:	f022                	sd	s0,32(sp)
    80003412:	ec26                	sd	s1,24(sp)
    80003414:	e84a                	sd	s2,16(sp)
    80003416:	e44e                	sd	s3,8(sp)
    80003418:	e052                	sd	s4,0(sp)
    8000341a:	1800                	addi	s0,sp,48
    8000341c:	89aa                	mv	s3,a0
    8000341e:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003420:	0001c517          	auipc	a0,0x1c
    80003424:	ea050513          	addi	a0,a0,-352 # 8001f2c0 <icache>
    80003428:	ffffd097          	auipc	ra,0xffffd
    8000342c:	684080e7          	jalr	1668(ra) # 80000aac <acquire>
  empty = 0;
    80003430:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003432:	0001c497          	auipc	s1,0x1c
    80003436:	eae48493          	addi	s1,s1,-338 # 8001f2e0 <icache+0x20>
    8000343a:	0001e697          	auipc	a3,0x1e
    8000343e:	ac668693          	addi	a3,a3,-1338 # 80020f00 <log>
    80003442:	a039                	j	80003450 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003444:	02090b63          	beqz	s2,8000347a <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003448:	09048493          	addi	s1,s1,144
    8000344c:	02d48a63          	beq	s1,a3,80003480 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003450:	449c                	lw	a5,8(s1)
    80003452:	fef059e3          	blez	a5,80003444 <iget+0x38>
    80003456:	4098                	lw	a4,0(s1)
    80003458:	ff3716e3          	bne	a4,s3,80003444 <iget+0x38>
    8000345c:	40d8                	lw	a4,4(s1)
    8000345e:	ff4713e3          	bne	a4,s4,80003444 <iget+0x38>
      ip->ref++;
    80003462:	2785                	addiw	a5,a5,1
    80003464:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003466:	0001c517          	auipc	a0,0x1c
    8000346a:	e5a50513          	addi	a0,a0,-422 # 8001f2c0 <icache>
    8000346e:	ffffd097          	auipc	ra,0xffffd
    80003472:	70e080e7          	jalr	1806(ra) # 80000b7c <release>
      return ip;
    80003476:	8926                	mv	s2,s1
    80003478:	a03d                	j	800034a6 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000347a:	f7f9                	bnez	a5,80003448 <iget+0x3c>
    8000347c:	8926                	mv	s2,s1
    8000347e:	b7e9                	j	80003448 <iget+0x3c>
  if(empty == 0)
    80003480:	02090c63          	beqz	s2,800034b8 <iget+0xac>
  ip->dev = dev;
    80003484:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003488:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000348c:	4785                	li	a5,1
    8000348e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003492:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    80003496:	0001c517          	auipc	a0,0x1c
    8000349a:	e2a50513          	addi	a0,a0,-470 # 8001f2c0 <icache>
    8000349e:	ffffd097          	auipc	ra,0xffffd
    800034a2:	6de080e7          	jalr	1758(ra) # 80000b7c <release>
}
    800034a6:	854a                	mv	a0,s2
    800034a8:	70a2                	ld	ra,40(sp)
    800034aa:	7402                	ld	s0,32(sp)
    800034ac:	64e2                	ld	s1,24(sp)
    800034ae:	6942                	ld	s2,16(sp)
    800034b0:	69a2                	ld	s3,8(sp)
    800034b2:	6a02                	ld	s4,0(sp)
    800034b4:	6145                	addi	sp,sp,48
    800034b6:	8082                	ret
    panic("iget: no inodes");
    800034b8:	00006517          	auipc	a0,0x6
    800034bc:	44050513          	addi	a0,a0,1088 # 800098f8 <userret+0x868>
    800034c0:	ffffd097          	auipc	ra,0xffffd
    800034c4:	09a080e7          	jalr	154(ra) # 8000055a <panic>

00000000800034c8 <fsinit>:
fsinit(int dev) {
    800034c8:	7179                	addi	sp,sp,-48
    800034ca:	f406                	sd	ra,40(sp)
    800034cc:	f022                	sd	s0,32(sp)
    800034ce:	ec26                	sd	s1,24(sp)
    800034d0:	e84a                	sd	s2,16(sp)
    800034d2:	e44e                	sd	s3,8(sp)
    800034d4:	1800                	addi	s0,sp,48
    800034d6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800034d8:	4585                	li	a1,1
    800034da:	00000097          	auipc	ra,0x0
    800034de:	a60080e7          	jalr	-1440(ra) # 80002f3a <bread>
    800034e2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034e4:	0001c997          	auipc	s3,0x1c
    800034e8:	dbc98993          	addi	s3,s3,-580 # 8001f2a0 <sb>
    800034ec:	02000613          	li	a2,32
    800034f0:	06050593          	addi	a1,a0,96
    800034f4:	854e                	mv	a0,s3
    800034f6:	ffffe097          	auipc	ra,0xffffe
    800034fa:	8e4080e7          	jalr	-1820(ra) # 80000dda <memmove>
  brelse(bp);
    800034fe:	8526                	mv	a0,s1
    80003500:	00000097          	auipc	ra,0x0
    80003504:	b6e080e7          	jalr	-1170(ra) # 8000306e <brelse>
  if(sb.magic != FSMAGIC)
    80003508:	0009a703          	lw	a4,0(s3)
    8000350c:	102037b7          	lui	a5,0x10203
    80003510:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003514:	02f71263          	bne	a4,a5,80003538 <fsinit+0x70>
  initlog(dev, &sb);
    80003518:	0001c597          	auipc	a1,0x1c
    8000351c:	d8858593          	addi	a1,a1,-632 # 8001f2a0 <sb>
    80003520:	854a                	mv	a0,s2
    80003522:	00001097          	auipc	ra,0x1
    80003526:	b38080e7          	jalr	-1224(ra) # 8000405a <initlog>
}
    8000352a:	70a2                	ld	ra,40(sp)
    8000352c:	7402                	ld	s0,32(sp)
    8000352e:	64e2                	ld	s1,24(sp)
    80003530:	6942                	ld	s2,16(sp)
    80003532:	69a2                	ld	s3,8(sp)
    80003534:	6145                	addi	sp,sp,48
    80003536:	8082                	ret
    panic("invalid file system");
    80003538:	00006517          	auipc	a0,0x6
    8000353c:	3d050513          	addi	a0,a0,976 # 80009908 <userret+0x878>
    80003540:	ffffd097          	auipc	ra,0xffffd
    80003544:	01a080e7          	jalr	26(ra) # 8000055a <panic>

0000000080003548 <iinit>:
{
    80003548:	7179                	addi	sp,sp,-48
    8000354a:	f406                	sd	ra,40(sp)
    8000354c:	f022                	sd	s0,32(sp)
    8000354e:	ec26                	sd	s1,24(sp)
    80003550:	e84a                	sd	s2,16(sp)
    80003552:	e44e                	sd	s3,8(sp)
    80003554:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003556:	00006597          	auipc	a1,0x6
    8000355a:	3ca58593          	addi	a1,a1,970 # 80009920 <userret+0x890>
    8000355e:	0001c517          	auipc	a0,0x1c
    80003562:	d6250513          	addi	a0,a0,-670 # 8001f2c0 <icache>
    80003566:	ffffd097          	auipc	ra,0xffffd
    8000356a:	472080e7          	jalr	1138(ra) # 800009d8 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000356e:	0001c497          	auipc	s1,0x1c
    80003572:	d8248493          	addi	s1,s1,-638 # 8001f2f0 <icache+0x30>
    80003576:	0001e997          	auipc	s3,0x1e
    8000357a:	99a98993          	addi	s3,s3,-1638 # 80020f10 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    8000357e:	00006917          	auipc	s2,0x6
    80003582:	3aa90913          	addi	s2,s2,938 # 80009928 <userret+0x898>
    80003586:	85ca                	mv	a1,s2
    80003588:	8526                	mv	a0,s1
    8000358a:	00001097          	auipc	ra,0x1
    8000358e:	f26080e7          	jalr	-218(ra) # 800044b0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003592:	09048493          	addi	s1,s1,144
    80003596:	ff3498e3          	bne	s1,s3,80003586 <iinit+0x3e>
}
    8000359a:	70a2                	ld	ra,40(sp)
    8000359c:	7402                	ld	s0,32(sp)
    8000359e:	64e2                	ld	s1,24(sp)
    800035a0:	6942                	ld	s2,16(sp)
    800035a2:	69a2                	ld	s3,8(sp)
    800035a4:	6145                	addi	sp,sp,48
    800035a6:	8082                	ret

00000000800035a8 <ialloc>:
{
    800035a8:	715d                	addi	sp,sp,-80
    800035aa:	e486                	sd	ra,72(sp)
    800035ac:	e0a2                	sd	s0,64(sp)
    800035ae:	fc26                	sd	s1,56(sp)
    800035b0:	f84a                	sd	s2,48(sp)
    800035b2:	f44e                	sd	s3,40(sp)
    800035b4:	f052                	sd	s4,32(sp)
    800035b6:	ec56                	sd	s5,24(sp)
    800035b8:	e85a                	sd	s6,16(sp)
    800035ba:	e45e                	sd	s7,8(sp)
    800035bc:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800035be:	0001c717          	auipc	a4,0x1c
    800035c2:	cee72703          	lw	a4,-786(a4) # 8001f2ac <sb+0xc>
    800035c6:	4785                	li	a5,1
    800035c8:	04e7fa63          	bgeu	a5,a4,8000361c <ialloc+0x74>
    800035cc:	8aaa                	mv	s5,a0
    800035ce:	8bae                	mv	s7,a1
    800035d0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800035d2:	0001ca17          	auipc	s4,0x1c
    800035d6:	ccea0a13          	addi	s4,s4,-818 # 8001f2a0 <sb>
    800035da:	00048b1b          	sext.w	s6,s1
    800035de:	0044d593          	srli	a1,s1,0x4
    800035e2:	018a2783          	lw	a5,24(s4)
    800035e6:	9dbd                	addw	a1,a1,a5
    800035e8:	8556                	mv	a0,s5
    800035ea:	00000097          	auipc	ra,0x0
    800035ee:	950080e7          	jalr	-1712(ra) # 80002f3a <bread>
    800035f2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035f4:	06050993          	addi	s3,a0,96
    800035f8:	00f4f793          	andi	a5,s1,15
    800035fc:	079a                	slli	a5,a5,0x6
    800035fe:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003600:	00099783          	lh	a5,0(s3)
    80003604:	c785                	beqz	a5,8000362c <ialloc+0x84>
    brelse(bp);
    80003606:	00000097          	auipc	ra,0x0
    8000360a:	a68080e7          	jalr	-1432(ra) # 8000306e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000360e:	0485                	addi	s1,s1,1
    80003610:	00ca2703          	lw	a4,12(s4)
    80003614:	0004879b          	sext.w	a5,s1
    80003618:	fce7e1e3          	bltu	a5,a4,800035da <ialloc+0x32>
  panic("ialloc: no inodes");
    8000361c:	00006517          	auipc	a0,0x6
    80003620:	31450513          	addi	a0,a0,788 # 80009930 <userret+0x8a0>
    80003624:	ffffd097          	auipc	ra,0xffffd
    80003628:	f36080e7          	jalr	-202(ra) # 8000055a <panic>
      memset(dip, 0, sizeof(*dip));
    8000362c:	04000613          	li	a2,64
    80003630:	4581                	li	a1,0
    80003632:	854e                	mv	a0,s3
    80003634:	ffffd097          	auipc	ra,0xffffd
    80003638:	746080e7          	jalr	1862(ra) # 80000d7a <memset>
      dip->type = type;
    8000363c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003640:	854a                	mv	a0,s2
    80003642:	00001097          	auipc	ra,0x1
    80003646:	d2e080e7          	jalr	-722(ra) # 80004370 <log_write>
      brelse(bp);
    8000364a:	854a                	mv	a0,s2
    8000364c:	00000097          	auipc	ra,0x0
    80003650:	a22080e7          	jalr	-1502(ra) # 8000306e <brelse>
      return iget(dev, inum);
    80003654:	85da                	mv	a1,s6
    80003656:	8556                	mv	a0,s5
    80003658:	00000097          	auipc	ra,0x0
    8000365c:	db4080e7          	jalr	-588(ra) # 8000340c <iget>
}
    80003660:	60a6                	ld	ra,72(sp)
    80003662:	6406                	ld	s0,64(sp)
    80003664:	74e2                	ld	s1,56(sp)
    80003666:	7942                	ld	s2,48(sp)
    80003668:	79a2                	ld	s3,40(sp)
    8000366a:	7a02                	ld	s4,32(sp)
    8000366c:	6ae2                	ld	s5,24(sp)
    8000366e:	6b42                	ld	s6,16(sp)
    80003670:	6ba2                	ld	s7,8(sp)
    80003672:	6161                	addi	sp,sp,80
    80003674:	8082                	ret

0000000080003676 <iupdate>:
{
    80003676:	1101                	addi	sp,sp,-32
    80003678:	ec06                	sd	ra,24(sp)
    8000367a:	e822                	sd	s0,16(sp)
    8000367c:	e426                	sd	s1,8(sp)
    8000367e:	e04a                	sd	s2,0(sp)
    80003680:	1000                	addi	s0,sp,32
    80003682:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003684:	415c                	lw	a5,4(a0)
    80003686:	0047d79b          	srliw	a5,a5,0x4
    8000368a:	0001c597          	auipc	a1,0x1c
    8000368e:	c2e5a583          	lw	a1,-978(a1) # 8001f2b8 <sb+0x18>
    80003692:	9dbd                	addw	a1,a1,a5
    80003694:	4108                	lw	a0,0(a0)
    80003696:	00000097          	auipc	ra,0x0
    8000369a:	8a4080e7          	jalr	-1884(ra) # 80002f3a <bread>
    8000369e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036a0:	06050793          	addi	a5,a0,96
    800036a4:	40c8                	lw	a0,4(s1)
    800036a6:	893d                	andi	a0,a0,15
    800036a8:	051a                	slli	a0,a0,0x6
    800036aa:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800036ac:	04c49703          	lh	a4,76(s1)
    800036b0:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800036b4:	04e49703          	lh	a4,78(s1)
    800036b8:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800036bc:	05049703          	lh	a4,80(s1)
    800036c0:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800036c4:	05249703          	lh	a4,82(s1)
    800036c8:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800036cc:	48f8                	lw	a4,84(s1)
    800036ce:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036d0:	03400613          	li	a2,52
    800036d4:	05848593          	addi	a1,s1,88
    800036d8:	0531                	addi	a0,a0,12
    800036da:	ffffd097          	auipc	ra,0xffffd
    800036de:	700080e7          	jalr	1792(ra) # 80000dda <memmove>
  log_write(bp);
    800036e2:	854a                	mv	a0,s2
    800036e4:	00001097          	auipc	ra,0x1
    800036e8:	c8c080e7          	jalr	-884(ra) # 80004370 <log_write>
  brelse(bp);
    800036ec:	854a                	mv	a0,s2
    800036ee:	00000097          	auipc	ra,0x0
    800036f2:	980080e7          	jalr	-1664(ra) # 8000306e <brelse>
}
    800036f6:	60e2                	ld	ra,24(sp)
    800036f8:	6442                	ld	s0,16(sp)
    800036fa:	64a2                	ld	s1,8(sp)
    800036fc:	6902                	ld	s2,0(sp)
    800036fe:	6105                	addi	sp,sp,32
    80003700:	8082                	ret

0000000080003702 <idup>:
{
    80003702:	1101                	addi	sp,sp,-32
    80003704:	ec06                	sd	ra,24(sp)
    80003706:	e822                	sd	s0,16(sp)
    80003708:	e426                	sd	s1,8(sp)
    8000370a:	1000                	addi	s0,sp,32
    8000370c:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000370e:	0001c517          	auipc	a0,0x1c
    80003712:	bb250513          	addi	a0,a0,-1102 # 8001f2c0 <icache>
    80003716:	ffffd097          	auipc	ra,0xffffd
    8000371a:	396080e7          	jalr	918(ra) # 80000aac <acquire>
  ip->ref++;
    8000371e:	449c                	lw	a5,8(s1)
    80003720:	2785                	addiw	a5,a5,1
    80003722:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003724:	0001c517          	auipc	a0,0x1c
    80003728:	b9c50513          	addi	a0,a0,-1124 # 8001f2c0 <icache>
    8000372c:	ffffd097          	auipc	ra,0xffffd
    80003730:	450080e7          	jalr	1104(ra) # 80000b7c <release>
}
    80003734:	8526                	mv	a0,s1
    80003736:	60e2                	ld	ra,24(sp)
    80003738:	6442                	ld	s0,16(sp)
    8000373a:	64a2                	ld	s1,8(sp)
    8000373c:	6105                	addi	sp,sp,32
    8000373e:	8082                	ret

0000000080003740 <ilock>:
{
    80003740:	1101                	addi	sp,sp,-32
    80003742:	ec06                	sd	ra,24(sp)
    80003744:	e822                	sd	s0,16(sp)
    80003746:	e426                	sd	s1,8(sp)
    80003748:	e04a                	sd	s2,0(sp)
    8000374a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000374c:	c115                	beqz	a0,80003770 <ilock+0x30>
    8000374e:	84aa                	mv	s1,a0
    80003750:	451c                	lw	a5,8(a0)
    80003752:	00f05f63          	blez	a5,80003770 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003756:	0541                	addi	a0,a0,16
    80003758:	00001097          	auipc	ra,0x1
    8000375c:	d92080e7          	jalr	-622(ra) # 800044ea <acquiresleep>
  if(ip->valid == 0){
    80003760:	44bc                	lw	a5,72(s1)
    80003762:	cf99                	beqz	a5,80003780 <ilock+0x40>
}
    80003764:	60e2                	ld	ra,24(sp)
    80003766:	6442                	ld	s0,16(sp)
    80003768:	64a2                	ld	s1,8(sp)
    8000376a:	6902                	ld	s2,0(sp)
    8000376c:	6105                	addi	sp,sp,32
    8000376e:	8082                	ret
    panic("ilock");
    80003770:	00006517          	auipc	a0,0x6
    80003774:	1d850513          	addi	a0,a0,472 # 80009948 <userret+0x8b8>
    80003778:	ffffd097          	auipc	ra,0xffffd
    8000377c:	de2080e7          	jalr	-542(ra) # 8000055a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003780:	40dc                	lw	a5,4(s1)
    80003782:	0047d79b          	srliw	a5,a5,0x4
    80003786:	0001c597          	auipc	a1,0x1c
    8000378a:	b325a583          	lw	a1,-1230(a1) # 8001f2b8 <sb+0x18>
    8000378e:	9dbd                	addw	a1,a1,a5
    80003790:	4088                	lw	a0,0(s1)
    80003792:	fffff097          	auipc	ra,0xfffff
    80003796:	7a8080e7          	jalr	1960(ra) # 80002f3a <bread>
    8000379a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000379c:	06050593          	addi	a1,a0,96
    800037a0:	40dc                	lw	a5,4(s1)
    800037a2:	8bbd                	andi	a5,a5,15
    800037a4:	079a                	slli	a5,a5,0x6
    800037a6:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037a8:	00059783          	lh	a5,0(a1)
    800037ac:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    800037b0:	00259783          	lh	a5,2(a1)
    800037b4:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    800037b8:	00459783          	lh	a5,4(a1)
    800037bc:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    800037c0:	00659783          	lh	a5,6(a1)
    800037c4:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    800037c8:	459c                	lw	a5,8(a1)
    800037ca:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800037cc:	03400613          	li	a2,52
    800037d0:	05b1                	addi	a1,a1,12
    800037d2:	05848513          	addi	a0,s1,88
    800037d6:	ffffd097          	auipc	ra,0xffffd
    800037da:	604080e7          	jalr	1540(ra) # 80000dda <memmove>
    brelse(bp);
    800037de:	854a                	mv	a0,s2
    800037e0:	00000097          	auipc	ra,0x0
    800037e4:	88e080e7          	jalr	-1906(ra) # 8000306e <brelse>
    ip->valid = 1;
    800037e8:	4785                	li	a5,1
    800037ea:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    800037ec:	04c49783          	lh	a5,76(s1)
    800037f0:	fbb5                	bnez	a5,80003764 <ilock+0x24>
      panic("ilock: no type");
    800037f2:	00006517          	auipc	a0,0x6
    800037f6:	15e50513          	addi	a0,a0,350 # 80009950 <userret+0x8c0>
    800037fa:	ffffd097          	auipc	ra,0xffffd
    800037fe:	d60080e7          	jalr	-672(ra) # 8000055a <panic>

0000000080003802 <iunlock>:
{
    80003802:	1101                	addi	sp,sp,-32
    80003804:	ec06                	sd	ra,24(sp)
    80003806:	e822                	sd	s0,16(sp)
    80003808:	e426                	sd	s1,8(sp)
    8000380a:	e04a                	sd	s2,0(sp)
    8000380c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000380e:	c905                	beqz	a0,8000383e <iunlock+0x3c>
    80003810:	84aa                	mv	s1,a0
    80003812:	01050913          	addi	s2,a0,16
    80003816:	854a                	mv	a0,s2
    80003818:	00001097          	auipc	ra,0x1
    8000381c:	d6c080e7          	jalr	-660(ra) # 80004584 <holdingsleep>
    80003820:	cd19                	beqz	a0,8000383e <iunlock+0x3c>
    80003822:	449c                	lw	a5,8(s1)
    80003824:	00f05d63          	blez	a5,8000383e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003828:	854a                	mv	a0,s2
    8000382a:	00001097          	auipc	ra,0x1
    8000382e:	d16080e7          	jalr	-746(ra) # 80004540 <releasesleep>
}
    80003832:	60e2                	ld	ra,24(sp)
    80003834:	6442                	ld	s0,16(sp)
    80003836:	64a2                	ld	s1,8(sp)
    80003838:	6902                	ld	s2,0(sp)
    8000383a:	6105                	addi	sp,sp,32
    8000383c:	8082                	ret
    panic("iunlock");
    8000383e:	00006517          	auipc	a0,0x6
    80003842:	12250513          	addi	a0,a0,290 # 80009960 <userret+0x8d0>
    80003846:	ffffd097          	auipc	ra,0xffffd
    8000384a:	d14080e7          	jalr	-748(ra) # 8000055a <panic>

000000008000384e <iput>:
{
    8000384e:	7139                	addi	sp,sp,-64
    80003850:	fc06                	sd	ra,56(sp)
    80003852:	f822                	sd	s0,48(sp)
    80003854:	f426                	sd	s1,40(sp)
    80003856:	f04a                	sd	s2,32(sp)
    80003858:	ec4e                	sd	s3,24(sp)
    8000385a:	e852                	sd	s4,16(sp)
    8000385c:	e456                	sd	s5,8(sp)
    8000385e:	0080                	addi	s0,sp,64
    80003860:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003862:	0001c517          	auipc	a0,0x1c
    80003866:	a5e50513          	addi	a0,a0,-1442 # 8001f2c0 <icache>
    8000386a:	ffffd097          	auipc	ra,0xffffd
    8000386e:	242080e7          	jalr	578(ra) # 80000aac <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003872:	4498                	lw	a4,8(s1)
    80003874:	4785                	li	a5,1
    80003876:	02f70663          	beq	a4,a5,800038a2 <iput+0x54>
  ip->ref--;
    8000387a:	449c                	lw	a5,8(s1)
    8000387c:	37fd                	addiw	a5,a5,-1
    8000387e:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003880:	0001c517          	auipc	a0,0x1c
    80003884:	a4050513          	addi	a0,a0,-1472 # 8001f2c0 <icache>
    80003888:	ffffd097          	auipc	ra,0xffffd
    8000388c:	2f4080e7          	jalr	756(ra) # 80000b7c <release>
}
    80003890:	70e2                	ld	ra,56(sp)
    80003892:	7442                	ld	s0,48(sp)
    80003894:	74a2                	ld	s1,40(sp)
    80003896:	7902                	ld	s2,32(sp)
    80003898:	69e2                	ld	s3,24(sp)
    8000389a:	6a42                	ld	s4,16(sp)
    8000389c:	6aa2                	ld	s5,8(sp)
    8000389e:	6121                	addi	sp,sp,64
    800038a0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038a2:	44bc                	lw	a5,72(s1)
    800038a4:	dbf9                	beqz	a5,8000387a <iput+0x2c>
    800038a6:	05249783          	lh	a5,82(s1)
    800038aa:	fbe1                	bnez	a5,8000387a <iput+0x2c>
    acquiresleep(&ip->lock);
    800038ac:	01048a13          	addi	s4,s1,16
    800038b0:	8552                	mv	a0,s4
    800038b2:	00001097          	auipc	ra,0x1
    800038b6:	c38080e7          	jalr	-968(ra) # 800044ea <acquiresleep>
    release(&icache.lock);
    800038ba:	0001c517          	auipc	a0,0x1c
    800038be:	a0650513          	addi	a0,a0,-1530 # 8001f2c0 <icache>
    800038c2:	ffffd097          	auipc	ra,0xffffd
    800038c6:	2ba080e7          	jalr	698(ra) # 80000b7c <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038ca:	05848913          	addi	s2,s1,88
    800038ce:	08848993          	addi	s3,s1,136
    800038d2:	a819                	j	800038e8 <iput+0x9a>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    800038d4:	4088                	lw	a0,0(s1)
    800038d6:	00000097          	auipc	ra,0x0
    800038da:	8ae080e7          	jalr	-1874(ra) # 80003184 <bfree>
      ip->addrs[i] = 0;
    800038de:	00092023          	sw	zero,0(s2)
  for(i = 0; i < NDIRECT; i++){
    800038e2:	0911                	addi	s2,s2,4
    800038e4:	01390663          	beq	s2,s3,800038f0 <iput+0xa2>
    if(ip->addrs[i]){
    800038e8:	00092583          	lw	a1,0(s2)
    800038ec:	d9fd                	beqz	a1,800038e2 <iput+0x94>
    800038ee:	b7dd                	j	800038d4 <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038f0:	0884a583          	lw	a1,136(s1)
    800038f4:	ed9d                	bnez	a1,80003932 <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038f6:	0404aa23          	sw	zero,84(s1)
  iupdate(ip);
    800038fa:	8526                	mv	a0,s1
    800038fc:	00000097          	auipc	ra,0x0
    80003900:	d7a080e7          	jalr	-646(ra) # 80003676 <iupdate>
    ip->type = 0;
    80003904:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003908:	8526                	mv	a0,s1
    8000390a:	00000097          	auipc	ra,0x0
    8000390e:	d6c080e7          	jalr	-660(ra) # 80003676 <iupdate>
    ip->valid = 0;
    80003912:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003916:	8552                	mv	a0,s4
    80003918:	00001097          	auipc	ra,0x1
    8000391c:	c28080e7          	jalr	-984(ra) # 80004540 <releasesleep>
    acquire(&icache.lock);
    80003920:	0001c517          	auipc	a0,0x1c
    80003924:	9a050513          	addi	a0,a0,-1632 # 8001f2c0 <icache>
    80003928:	ffffd097          	auipc	ra,0xffffd
    8000392c:	184080e7          	jalr	388(ra) # 80000aac <acquire>
    80003930:	b7a9                	j	8000387a <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003932:	4088                	lw	a0,0(s1)
    80003934:	fffff097          	auipc	ra,0xfffff
    80003938:	606080e7          	jalr	1542(ra) # 80002f3a <bread>
    8000393c:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    8000393e:	06050913          	addi	s2,a0,96
    80003942:	46050993          	addi	s3,a0,1120
    80003946:	a809                	j	80003958 <iput+0x10a>
        bfree(ip->dev, a[j]);
    80003948:	4088                	lw	a0,0(s1)
    8000394a:	00000097          	auipc	ra,0x0
    8000394e:	83a080e7          	jalr	-1990(ra) # 80003184 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003952:	0911                	addi	s2,s2,4
    80003954:	01390663          	beq	s2,s3,80003960 <iput+0x112>
      if(a[j])
    80003958:	00092583          	lw	a1,0(s2)
    8000395c:	d9fd                	beqz	a1,80003952 <iput+0x104>
    8000395e:	b7ed                	j	80003948 <iput+0xfa>
    brelse(bp);
    80003960:	8556                	mv	a0,s5
    80003962:	fffff097          	auipc	ra,0xfffff
    80003966:	70c080e7          	jalr	1804(ra) # 8000306e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000396a:	0884a583          	lw	a1,136(s1)
    8000396e:	4088                	lw	a0,0(s1)
    80003970:	00000097          	auipc	ra,0x0
    80003974:	814080e7          	jalr	-2028(ra) # 80003184 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003978:	0804a423          	sw	zero,136(s1)
    8000397c:	bfad                	j	800038f6 <iput+0xa8>

000000008000397e <iunlockput>:
{
    8000397e:	1101                	addi	sp,sp,-32
    80003980:	ec06                	sd	ra,24(sp)
    80003982:	e822                	sd	s0,16(sp)
    80003984:	e426                	sd	s1,8(sp)
    80003986:	1000                	addi	s0,sp,32
    80003988:	84aa                	mv	s1,a0
  iunlock(ip);
    8000398a:	00000097          	auipc	ra,0x0
    8000398e:	e78080e7          	jalr	-392(ra) # 80003802 <iunlock>
  iput(ip);
    80003992:	8526                	mv	a0,s1
    80003994:	00000097          	auipc	ra,0x0
    80003998:	eba080e7          	jalr	-326(ra) # 8000384e <iput>
}
    8000399c:	60e2                	ld	ra,24(sp)
    8000399e:	6442                	ld	s0,16(sp)
    800039a0:	64a2                	ld	s1,8(sp)
    800039a2:	6105                	addi	sp,sp,32
    800039a4:	8082                	ret

00000000800039a6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800039a6:	1141                	addi	sp,sp,-16
    800039a8:	e422                	sd	s0,8(sp)
    800039aa:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800039ac:	411c                	lw	a5,0(a0)
    800039ae:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800039b0:	415c                	lw	a5,4(a0)
    800039b2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800039b4:	04c51783          	lh	a5,76(a0)
    800039b8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800039bc:	05251783          	lh	a5,82(a0)
    800039c0:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800039c4:	05456783          	lwu	a5,84(a0)
    800039c8:	e99c                	sd	a5,16(a1)
}
    800039ca:	6422                	ld	s0,8(sp)
    800039cc:	0141                	addi	sp,sp,16
    800039ce:	8082                	ret

00000000800039d0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039d0:	497c                	lw	a5,84(a0)
    800039d2:	0ed7e563          	bltu	a5,a3,80003abc <readi+0xec>
{
    800039d6:	7159                	addi	sp,sp,-112
    800039d8:	f486                	sd	ra,104(sp)
    800039da:	f0a2                	sd	s0,96(sp)
    800039dc:	eca6                	sd	s1,88(sp)
    800039de:	e8ca                	sd	s2,80(sp)
    800039e0:	e4ce                	sd	s3,72(sp)
    800039e2:	e0d2                	sd	s4,64(sp)
    800039e4:	fc56                	sd	s5,56(sp)
    800039e6:	f85a                	sd	s6,48(sp)
    800039e8:	f45e                	sd	s7,40(sp)
    800039ea:	f062                	sd	s8,32(sp)
    800039ec:	ec66                	sd	s9,24(sp)
    800039ee:	e86a                	sd	s10,16(sp)
    800039f0:	e46e                	sd	s11,8(sp)
    800039f2:	1880                	addi	s0,sp,112
    800039f4:	8baa                	mv	s7,a0
    800039f6:	8c2e                	mv	s8,a1
    800039f8:	8ab2                	mv	s5,a2
    800039fa:	8936                	mv	s2,a3
    800039fc:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800039fe:	9f35                	addw	a4,a4,a3
    80003a00:	0cd76063          	bltu	a4,a3,80003ac0 <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    80003a04:	00e7f463          	bgeu	a5,a4,80003a0c <readi+0x3c>
    n = ip->size - off;
    80003a08:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a0c:	080b0763          	beqz	s6,80003a9a <readi+0xca>
    80003a10:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a12:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a16:	5cfd                	li	s9,-1
    80003a18:	a82d                	j	80003a52 <readi+0x82>
    80003a1a:	02099d93          	slli	s11,s3,0x20
    80003a1e:	020ddd93          	srli	s11,s11,0x20
    80003a22:	06048613          	addi	a2,s1,96
    80003a26:	86ee                	mv	a3,s11
    80003a28:	963a                	add	a2,a2,a4
    80003a2a:	85d6                	mv	a1,s5
    80003a2c:	8562                	mv	a0,s8
    80003a2e:	fffff097          	auipc	ra,0xfffff
    80003a32:	a90080e7          	jalr	-1392(ra) # 800024be <either_copyout>
    80003a36:	05950d63          	beq	a0,s9,80003a90 <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003a3a:	8526                	mv	a0,s1
    80003a3c:	fffff097          	auipc	ra,0xfffff
    80003a40:	632080e7          	jalr	1586(ra) # 8000306e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a44:	01498a3b          	addw	s4,s3,s4
    80003a48:	0129893b          	addw	s2,s3,s2
    80003a4c:	9aee                	add	s5,s5,s11
    80003a4e:	056a7663          	bgeu	s4,s6,80003a9a <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a52:	000ba483          	lw	s1,0(s7)
    80003a56:	00a9559b          	srliw	a1,s2,0xa
    80003a5a:	855e                	mv	a0,s7
    80003a5c:	00000097          	auipc	ra,0x0
    80003a60:	8d6080e7          	jalr	-1834(ra) # 80003332 <bmap>
    80003a64:	0005059b          	sext.w	a1,a0
    80003a68:	8526                	mv	a0,s1
    80003a6a:	fffff097          	auipc	ra,0xfffff
    80003a6e:	4d0080e7          	jalr	1232(ra) # 80002f3a <bread>
    80003a72:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a74:	3ff97713          	andi	a4,s2,1023
    80003a78:	40ed07bb          	subw	a5,s10,a4
    80003a7c:	414b06bb          	subw	a3,s6,s4
    80003a80:	89be                	mv	s3,a5
    80003a82:	2781                	sext.w	a5,a5
    80003a84:	0006861b          	sext.w	a2,a3
    80003a88:	f8f679e3          	bgeu	a2,a5,80003a1a <readi+0x4a>
    80003a8c:	89b6                	mv	s3,a3
    80003a8e:	b771                	j	80003a1a <readi+0x4a>
      brelse(bp);
    80003a90:	8526                	mv	a0,s1
    80003a92:	fffff097          	auipc	ra,0xfffff
    80003a96:	5dc080e7          	jalr	1500(ra) # 8000306e <brelse>
  }
  return n;
    80003a9a:	000b051b          	sext.w	a0,s6
}
    80003a9e:	70a6                	ld	ra,104(sp)
    80003aa0:	7406                	ld	s0,96(sp)
    80003aa2:	64e6                	ld	s1,88(sp)
    80003aa4:	6946                	ld	s2,80(sp)
    80003aa6:	69a6                	ld	s3,72(sp)
    80003aa8:	6a06                	ld	s4,64(sp)
    80003aaa:	7ae2                	ld	s5,56(sp)
    80003aac:	7b42                	ld	s6,48(sp)
    80003aae:	7ba2                	ld	s7,40(sp)
    80003ab0:	7c02                	ld	s8,32(sp)
    80003ab2:	6ce2                	ld	s9,24(sp)
    80003ab4:	6d42                	ld	s10,16(sp)
    80003ab6:	6da2                	ld	s11,8(sp)
    80003ab8:	6165                	addi	sp,sp,112
    80003aba:	8082                	ret
    return -1;
    80003abc:	557d                	li	a0,-1
}
    80003abe:	8082                	ret
    return -1;
    80003ac0:	557d                	li	a0,-1
    80003ac2:	bff1                	j	80003a9e <readi+0xce>

0000000080003ac4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ac4:	497c                	lw	a5,84(a0)
    80003ac6:	10d7e663          	bltu	a5,a3,80003bd2 <writei+0x10e>
{
    80003aca:	7159                	addi	sp,sp,-112
    80003acc:	f486                	sd	ra,104(sp)
    80003ace:	f0a2                	sd	s0,96(sp)
    80003ad0:	eca6                	sd	s1,88(sp)
    80003ad2:	e8ca                	sd	s2,80(sp)
    80003ad4:	e4ce                	sd	s3,72(sp)
    80003ad6:	e0d2                	sd	s4,64(sp)
    80003ad8:	fc56                	sd	s5,56(sp)
    80003ada:	f85a                	sd	s6,48(sp)
    80003adc:	f45e                	sd	s7,40(sp)
    80003ade:	f062                	sd	s8,32(sp)
    80003ae0:	ec66                	sd	s9,24(sp)
    80003ae2:	e86a                	sd	s10,16(sp)
    80003ae4:	e46e                	sd	s11,8(sp)
    80003ae6:	1880                	addi	s0,sp,112
    80003ae8:	8baa                	mv	s7,a0
    80003aea:	8c2e                	mv	s8,a1
    80003aec:	8ab2                	mv	s5,a2
    80003aee:	8936                	mv	s2,a3
    80003af0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003af2:	00e687bb          	addw	a5,a3,a4
    80003af6:	0ed7e063          	bltu	a5,a3,80003bd6 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003afa:	00043737          	lui	a4,0x43
    80003afe:	0cf76e63          	bltu	a4,a5,80003bda <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b02:	0a0b0763          	beqz	s6,80003bb0 <writei+0xec>
    80003b06:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b08:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b0c:	5cfd                	li	s9,-1
    80003b0e:	a091                	j	80003b52 <writei+0x8e>
    80003b10:	02099d93          	slli	s11,s3,0x20
    80003b14:	020ddd93          	srli	s11,s11,0x20
    80003b18:	06048513          	addi	a0,s1,96
    80003b1c:	86ee                	mv	a3,s11
    80003b1e:	8656                	mv	a2,s5
    80003b20:	85e2                	mv	a1,s8
    80003b22:	953a                	add	a0,a0,a4
    80003b24:	fffff097          	auipc	ra,0xfffff
    80003b28:	9f0080e7          	jalr	-1552(ra) # 80002514 <either_copyin>
    80003b2c:	07950263          	beq	a0,s9,80003b90 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b30:	8526                	mv	a0,s1
    80003b32:	00001097          	auipc	ra,0x1
    80003b36:	83e080e7          	jalr	-1986(ra) # 80004370 <log_write>
    brelse(bp);
    80003b3a:	8526                	mv	a0,s1
    80003b3c:	fffff097          	auipc	ra,0xfffff
    80003b40:	532080e7          	jalr	1330(ra) # 8000306e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b44:	01498a3b          	addw	s4,s3,s4
    80003b48:	0129893b          	addw	s2,s3,s2
    80003b4c:	9aee                	add	s5,s5,s11
    80003b4e:	056a7663          	bgeu	s4,s6,80003b9a <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b52:	000ba483          	lw	s1,0(s7)
    80003b56:	00a9559b          	srliw	a1,s2,0xa
    80003b5a:	855e                	mv	a0,s7
    80003b5c:	fffff097          	auipc	ra,0xfffff
    80003b60:	7d6080e7          	jalr	2006(ra) # 80003332 <bmap>
    80003b64:	0005059b          	sext.w	a1,a0
    80003b68:	8526                	mv	a0,s1
    80003b6a:	fffff097          	auipc	ra,0xfffff
    80003b6e:	3d0080e7          	jalr	976(ra) # 80002f3a <bread>
    80003b72:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b74:	3ff97713          	andi	a4,s2,1023
    80003b78:	40ed07bb          	subw	a5,s10,a4
    80003b7c:	414b06bb          	subw	a3,s6,s4
    80003b80:	89be                	mv	s3,a5
    80003b82:	2781                	sext.w	a5,a5
    80003b84:	0006861b          	sext.w	a2,a3
    80003b88:	f8f674e3          	bgeu	a2,a5,80003b10 <writei+0x4c>
    80003b8c:	89b6                	mv	s3,a3
    80003b8e:	b749                	j	80003b10 <writei+0x4c>
      brelse(bp);
    80003b90:	8526                	mv	a0,s1
    80003b92:	fffff097          	auipc	ra,0xfffff
    80003b96:	4dc080e7          	jalr	1244(ra) # 8000306e <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003b9a:	054ba783          	lw	a5,84(s7)
    80003b9e:	0127f463          	bgeu	a5,s2,80003ba6 <writei+0xe2>
      ip->size = off;
    80003ba2:	052baa23          	sw	s2,84(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003ba6:	855e                	mv	a0,s7
    80003ba8:	00000097          	auipc	ra,0x0
    80003bac:	ace080e7          	jalr	-1330(ra) # 80003676 <iupdate>
  }

  return n;
    80003bb0:	000b051b          	sext.w	a0,s6
}
    80003bb4:	70a6                	ld	ra,104(sp)
    80003bb6:	7406                	ld	s0,96(sp)
    80003bb8:	64e6                	ld	s1,88(sp)
    80003bba:	6946                	ld	s2,80(sp)
    80003bbc:	69a6                	ld	s3,72(sp)
    80003bbe:	6a06                	ld	s4,64(sp)
    80003bc0:	7ae2                	ld	s5,56(sp)
    80003bc2:	7b42                	ld	s6,48(sp)
    80003bc4:	7ba2                	ld	s7,40(sp)
    80003bc6:	7c02                	ld	s8,32(sp)
    80003bc8:	6ce2                	ld	s9,24(sp)
    80003bca:	6d42                	ld	s10,16(sp)
    80003bcc:	6da2                	ld	s11,8(sp)
    80003bce:	6165                	addi	sp,sp,112
    80003bd0:	8082                	ret
    return -1;
    80003bd2:	557d                	li	a0,-1
}
    80003bd4:	8082                	ret
    return -1;
    80003bd6:	557d                	li	a0,-1
    80003bd8:	bff1                	j	80003bb4 <writei+0xf0>
    return -1;
    80003bda:	557d                	li	a0,-1
    80003bdc:	bfe1                	j	80003bb4 <writei+0xf0>

0000000080003bde <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003bde:	1141                	addi	sp,sp,-16
    80003be0:	e406                	sd	ra,8(sp)
    80003be2:	e022                	sd	s0,0(sp)
    80003be4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003be6:	4639                	li	a2,14
    80003be8:	ffffd097          	auipc	ra,0xffffd
    80003bec:	26e080e7          	jalr	622(ra) # 80000e56 <strncmp>
}
    80003bf0:	60a2                	ld	ra,8(sp)
    80003bf2:	6402                	ld	s0,0(sp)
    80003bf4:	0141                	addi	sp,sp,16
    80003bf6:	8082                	ret

0000000080003bf8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003bf8:	7139                	addi	sp,sp,-64
    80003bfa:	fc06                	sd	ra,56(sp)
    80003bfc:	f822                	sd	s0,48(sp)
    80003bfe:	f426                	sd	s1,40(sp)
    80003c00:	f04a                	sd	s2,32(sp)
    80003c02:	ec4e                	sd	s3,24(sp)
    80003c04:	e852                	sd	s4,16(sp)
    80003c06:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c08:	04c51703          	lh	a4,76(a0)
    80003c0c:	4785                	li	a5,1
    80003c0e:	00f71a63          	bne	a4,a5,80003c22 <dirlookup+0x2a>
    80003c12:	892a                	mv	s2,a0
    80003c14:	89ae                	mv	s3,a1
    80003c16:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c18:	497c                	lw	a5,84(a0)
    80003c1a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c1c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c1e:	e79d                	bnez	a5,80003c4c <dirlookup+0x54>
    80003c20:	a8a5                	j	80003c98 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c22:	00006517          	auipc	a0,0x6
    80003c26:	d4650513          	addi	a0,a0,-698 # 80009968 <userret+0x8d8>
    80003c2a:	ffffd097          	auipc	ra,0xffffd
    80003c2e:	930080e7          	jalr	-1744(ra) # 8000055a <panic>
      panic("dirlookup read");
    80003c32:	00006517          	auipc	a0,0x6
    80003c36:	d4e50513          	addi	a0,a0,-690 # 80009980 <userret+0x8f0>
    80003c3a:	ffffd097          	auipc	ra,0xffffd
    80003c3e:	920080e7          	jalr	-1760(ra) # 8000055a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c42:	24c1                	addiw	s1,s1,16
    80003c44:	05492783          	lw	a5,84(s2)
    80003c48:	04f4f763          	bgeu	s1,a5,80003c96 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c4c:	4741                	li	a4,16
    80003c4e:	86a6                	mv	a3,s1
    80003c50:	fc040613          	addi	a2,s0,-64
    80003c54:	4581                	li	a1,0
    80003c56:	854a                	mv	a0,s2
    80003c58:	00000097          	auipc	ra,0x0
    80003c5c:	d78080e7          	jalr	-648(ra) # 800039d0 <readi>
    80003c60:	47c1                	li	a5,16
    80003c62:	fcf518e3          	bne	a0,a5,80003c32 <dirlookup+0x3a>
    if(de.inum == 0)
    80003c66:	fc045783          	lhu	a5,-64(s0)
    80003c6a:	dfe1                	beqz	a5,80003c42 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c6c:	fc240593          	addi	a1,s0,-62
    80003c70:	854e                	mv	a0,s3
    80003c72:	00000097          	auipc	ra,0x0
    80003c76:	f6c080e7          	jalr	-148(ra) # 80003bde <namecmp>
    80003c7a:	f561                	bnez	a0,80003c42 <dirlookup+0x4a>
      if(poff)
    80003c7c:	000a0463          	beqz	s4,80003c84 <dirlookup+0x8c>
        *poff = off;
    80003c80:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c84:	fc045583          	lhu	a1,-64(s0)
    80003c88:	00092503          	lw	a0,0(s2)
    80003c8c:	fffff097          	auipc	ra,0xfffff
    80003c90:	780080e7          	jalr	1920(ra) # 8000340c <iget>
    80003c94:	a011                	j	80003c98 <dirlookup+0xa0>
  return 0;
    80003c96:	4501                	li	a0,0
}
    80003c98:	70e2                	ld	ra,56(sp)
    80003c9a:	7442                	ld	s0,48(sp)
    80003c9c:	74a2                	ld	s1,40(sp)
    80003c9e:	7902                	ld	s2,32(sp)
    80003ca0:	69e2                	ld	s3,24(sp)
    80003ca2:	6a42                	ld	s4,16(sp)
    80003ca4:	6121                	addi	sp,sp,64
    80003ca6:	8082                	ret

0000000080003ca8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003ca8:	711d                	addi	sp,sp,-96
    80003caa:	ec86                	sd	ra,88(sp)
    80003cac:	e8a2                	sd	s0,80(sp)
    80003cae:	e4a6                	sd	s1,72(sp)
    80003cb0:	e0ca                	sd	s2,64(sp)
    80003cb2:	fc4e                	sd	s3,56(sp)
    80003cb4:	f852                	sd	s4,48(sp)
    80003cb6:	f456                	sd	s5,40(sp)
    80003cb8:	f05a                	sd	s6,32(sp)
    80003cba:	ec5e                	sd	s7,24(sp)
    80003cbc:	e862                	sd	s8,16(sp)
    80003cbe:	e466                	sd	s9,8(sp)
    80003cc0:	1080                	addi	s0,sp,96
    80003cc2:	84aa                	mv	s1,a0
    80003cc4:	8b2e                	mv	s6,a1
    80003cc6:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003cc8:	00054703          	lbu	a4,0(a0)
    80003ccc:	02f00793          	li	a5,47
    80003cd0:	02f70363          	beq	a4,a5,80003cf6 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003cd4:	ffffe097          	auipc	ra,0xffffe
    80003cd8:	dce080e7          	jalr	-562(ra) # 80001aa2 <myproc>
    80003cdc:	15853503          	ld	a0,344(a0)
    80003ce0:	00000097          	auipc	ra,0x0
    80003ce4:	a22080e7          	jalr	-1502(ra) # 80003702 <idup>
    80003ce8:	89aa                	mv	s3,a0
  while(*path == '/')
    80003cea:	02f00913          	li	s2,47
  len = path - s;
    80003cee:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003cf0:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003cf2:	4c05                	li	s8,1
    80003cf4:	a865                	j	80003dac <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003cf6:	4585                	li	a1,1
    80003cf8:	4501                	li	a0,0
    80003cfa:	fffff097          	auipc	ra,0xfffff
    80003cfe:	712080e7          	jalr	1810(ra) # 8000340c <iget>
    80003d02:	89aa                	mv	s3,a0
    80003d04:	b7dd                	j	80003cea <namex+0x42>
      iunlockput(ip);
    80003d06:	854e                	mv	a0,s3
    80003d08:	00000097          	auipc	ra,0x0
    80003d0c:	c76080e7          	jalr	-906(ra) # 8000397e <iunlockput>
      return 0;
    80003d10:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d12:	854e                	mv	a0,s3
    80003d14:	60e6                	ld	ra,88(sp)
    80003d16:	6446                	ld	s0,80(sp)
    80003d18:	64a6                	ld	s1,72(sp)
    80003d1a:	6906                	ld	s2,64(sp)
    80003d1c:	79e2                	ld	s3,56(sp)
    80003d1e:	7a42                	ld	s4,48(sp)
    80003d20:	7aa2                	ld	s5,40(sp)
    80003d22:	7b02                	ld	s6,32(sp)
    80003d24:	6be2                	ld	s7,24(sp)
    80003d26:	6c42                	ld	s8,16(sp)
    80003d28:	6ca2                	ld	s9,8(sp)
    80003d2a:	6125                	addi	sp,sp,96
    80003d2c:	8082                	ret
      iunlock(ip);
    80003d2e:	854e                	mv	a0,s3
    80003d30:	00000097          	auipc	ra,0x0
    80003d34:	ad2080e7          	jalr	-1326(ra) # 80003802 <iunlock>
      return ip;
    80003d38:	bfe9                	j	80003d12 <namex+0x6a>
      iunlockput(ip);
    80003d3a:	854e                	mv	a0,s3
    80003d3c:	00000097          	auipc	ra,0x0
    80003d40:	c42080e7          	jalr	-958(ra) # 8000397e <iunlockput>
      return 0;
    80003d44:	89d2                	mv	s3,s4
    80003d46:	b7f1                	j	80003d12 <namex+0x6a>
  len = path - s;
    80003d48:	40b48633          	sub	a2,s1,a1
    80003d4c:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003d50:	094cd463          	bge	s9,s4,80003dd8 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003d54:	4639                	li	a2,14
    80003d56:	8556                	mv	a0,s5
    80003d58:	ffffd097          	auipc	ra,0xffffd
    80003d5c:	082080e7          	jalr	130(ra) # 80000dda <memmove>
  while(*path == '/')
    80003d60:	0004c783          	lbu	a5,0(s1)
    80003d64:	01279763          	bne	a5,s2,80003d72 <namex+0xca>
    path++;
    80003d68:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d6a:	0004c783          	lbu	a5,0(s1)
    80003d6e:	ff278de3          	beq	a5,s2,80003d68 <namex+0xc0>
    ilock(ip);
    80003d72:	854e                	mv	a0,s3
    80003d74:	00000097          	auipc	ra,0x0
    80003d78:	9cc080e7          	jalr	-1588(ra) # 80003740 <ilock>
    if(ip->type != T_DIR){
    80003d7c:	04c99783          	lh	a5,76(s3)
    80003d80:	f98793e3          	bne	a5,s8,80003d06 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003d84:	000b0563          	beqz	s6,80003d8e <namex+0xe6>
    80003d88:	0004c783          	lbu	a5,0(s1)
    80003d8c:	d3cd                	beqz	a5,80003d2e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d8e:	865e                	mv	a2,s7
    80003d90:	85d6                	mv	a1,s5
    80003d92:	854e                	mv	a0,s3
    80003d94:	00000097          	auipc	ra,0x0
    80003d98:	e64080e7          	jalr	-412(ra) # 80003bf8 <dirlookup>
    80003d9c:	8a2a                	mv	s4,a0
    80003d9e:	dd51                	beqz	a0,80003d3a <namex+0x92>
    iunlockput(ip);
    80003da0:	854e                	mv	a0,s3
    80003da2:	00000097          	auipc	ra,0x0
    80003da6:	bdc080e7          	jalr	-1060(ra) # 8000397e <iunlockput>
    ip = next;
    80003daa:	89d2                	mv	s3,s4
  while(*path == '/')
    80003dac:	0004c783          	lbu	a5,0(s1)
    80003db0:	05279763          	bne	a5,s2,80003dfe <namex+0x156>
    path++;
    80003db4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003db6:	0004c783          	lbu	a5,0(s1)
    80003dba:	ff278de3          	beq	a5,s2,80003db4 <namex+0x10c>
  if(*path == 0)
    80003dbe:	c79d                	beqz	a5,80003dec <namex+0x144>
    path++;
    80003dc0:	85a6                	mv	a1,s1
  len = path - s;
    80003dc2:	8a5e                	mv	s4,s7
    80003dc4:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003dc6:	01278963          	beq	a5,s2,80003dd8 <namex+0x130>
    80003dca:	dfbd                	beqz	a5,80003d48 <namex+0xa0>
    path++;
    80003dcc:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003dce:	0004c783          	lbu	a5,0(s1)
    80003dd2:	ff279ce3          	bne	a5,s2,80003dca <namex+0x122>
    80003dd6:	bf8d                	j	80003d48 <namex+0xa0>
    memmove(name, s, len);
    80003dd8:	2601                	sext.w	a2,a2
    80003dda:	8556                	mv	a0,s5
    80003ddc:	ffffd097          	auipc	ra,0xffffd
    80003de0:	ffe080e7          	jalr	-2(ra) # 80000dda <memmove>
    name[len] = 0;
    80003de4:	9a56                	add	s4,s4,s5
    80003de6:	000a0023          	sb	zero,0(s4)
    80003dea:	bf9d                	j	80003d60 <namex+0xb8>
  if(nameiparent){
    80003dec:	f20b03e3          	beqz	s6,80003d12 <namex+0x6a>
    iput(ip);
    80003df0:	854e                	mv	a0,s3
    80003df2:	00000097          	auipc	ra,0x0
    80003df6:	a5c080e7          	jalr	-1444(ra) # 8000384e <iput>
    return 0;
    80003dfa:	4981                	li	s3,0
    80003dfc:	bf19                	j	80003d12 <namex+0x6a>
  if(*path == 0)
    80003dfe:	d7fd                	beqz	a5,80003dec <namex+0x144>
  while(*path != '/' && *path != 0)
    80003e00:	0004c783          	lbu	a5,0(s1)
    80003e04:	85a6                	mv	a1,s1
    80003e06:	b7d1                	j	80003dca <namex+0x122>

0000000080003e08 <dirlink>:
{
    80003e08:	7139                	addi	sp,sp,-64
    80003e0a:	fc06                	sd	ra,56(sp)
    80003e0c:	f822                	sd	s0,48(sp)
    80003e0e:	f426                	sd	s1,40(sp)
    80003e10:	f04a                	sd	s2,32(sp)
    80003e12:	ec4e                	sd	s3,24(sp)
    80003e14:	e852                	sd	s4,16(sp)
    80003e16:	0080                	addi	s0,sp,64
    80003e18:	892a                	mv	s2,a0
    80003e1a:	8a2e                	mv	s4,a1
    80003e1c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e1e:	4601                	li	a2,0
    80003e20:	00000097          	auipc	ra,0x0
    80003e24:	dd8080e7          	jalr	-552(ra) # 80003bf8 <dirlookup>
    80003e28:	e93d                	bnez	a0,80003e9e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e2a:	05492483          	lw	s1,84(s2)
    80003e2e:	c49d                	beqz	s1,80003e5c <dirlink+0x54>
    80003e30:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e32:	4741                	li	a4,16
    80003e34:	86a6                	mv	a3,s1
    80003e36:	fc040613          	addi	a2,s0,-64
    80003e3a:	4581                	li	a1,0
    80003e3c:	854a                	mv	a0,s2
    80003e3e:	00000097          	auipc	ra,0x0
    80003e42:	b92080e7          	jalr	-1134(ra) # 800039d0 <readi>
    80003e46:	47c1                	li	a5,16
    80003e48:	06f51163          	bne	a0,a5,80003eaa <dirlink+0xa2>
    if(de.inum == 0)
    80003e4c:	fc045783          	lhu	a5,-64(s0)
    80003e50:	c791                	beqz	a5,80003e5c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e52:	24c1                	addiw	s1,s1,16
    80003e54:	05492783          	lw	a5,84(s2)
    80003e58:	fcf4ede3          	bltu	s1,a5,80003e32 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e5c:	4639                	li	a2,14
    80003e5e:	85d2                	mv	a1,s4
    80003e60:	fc240513          	addi	a0,s0,-62
    80003e64:	ffffd097          	auipc	ra,0xffffd
    80003e68:	02e080e7          	jalr	46(ra) # 80000e92 <strncpy>
  de.inum = inum;
    80003e6c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e70:	4741                	li	a4,16
    80003e72:	86a6                	mv	a3,s1
    80003e74:	fc040613          	addi	a2,s0,-64
    80003e78:	4581                	li	a1,0
    80003e7a:	854a                	mv	a0,s2
    80003e7c:	00000097          	auipc	ra,0x0
    80003e80:	c48080e7          	jalr	-952(ra) # 80003ac4 <writei>
    80003e84:	872a                	mv	a4,a0
    80003e86:	47c1                	li	a5,16
  return 0;
    80003e88:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e8a:	02f71863          	bne	a4,a5,80003eba <dirlink+0xb2>
}
    80003e8e:	70e2                	ld	ra,56(sp)
    80003e90:	7442                	ld	s0,48(sp)
    80003e92:	74a2                	ld	s1,40(sp)
    80003e94:	7902                	ld	s2,32(sp)
    80003e96:	69e2                	ld	s3,24(sp)
    80003e98:	6a42                	ld	s4,16(sp)
    80003e9a:	6121                	addi	sp,sp,64
    80003e9c:	8082                	ret
    iput(ip);
    80003e9e:	00000097          	auipc	ra,0x0
    80003ea2:	9b0080e7          	jalr	-1616(ra) # 8000384e <iput>
    return -1;
    80003ea6:	557d                	li	a0,-1
    80003ea8:	b7dd                	j	80003e8e <dirlink+0x86>
      panic("dirlink read");
    80003eaa:	00006517          	auipc	a0,0x6
    80003eae:	ae650513          	addi	a0,a0,-1306 # 80009990 <userret+0x900>
    80003eb2:	ffffc097          	auipc	ra,0xffffc
    80003eb6:	6a8080e7          	jalr	1704(ra) # 8000055a <panic>
    panic("dirlink");
    80003eba:	00006517          	auipc	a0,0x6
    80003ebe:	bf650513          	addi	a0,a0,-1034 # 80009ab0 <userret+0xa20>
    80003ec2:	ffffc097          	auipc	ra,0xffffc
    80003ec6:	698080e7          	jalr	1688(ra) # 8000055a <panic>

0000000080003eca <namei>:

struct inode*
namei(char *path)
{
    80003eca:	1101                	addi	sp,sp,-32
    80003ecc:	ec06                	sd	ra,24(sp)
    80003ece:	e822                	sd	s0,16(sp)
    80003ed0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ed2:	fe040613          	addi	a2,s0,-32
    80003ed6:	4581                	li	a1,0
    80003ed8:	00000097          	auipc	ra,0x0
    80003edc:	dd0080e7          	jalr	-560(ra) # 80003ca8 <namex>
}
    80003ee0:	60e2                	ld	ra,24(sp)
    80003ee2:	6442                	ld	s0,16(sp)
    80003ee4:	6105                	addi	sp,sp,32
    80003ee6:	8082                	ret

0000000080003ee8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003ee8:	1141                	addi	sp,sp,-16
    80003eea:	e406                	sd	ra,8(sp)
    80003eec:	e022                	sd	s0,0(sp)
    80003eee:	0800                	addi	s0,sp,16
    80003ef0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ef2:	4585                	li	a1,1
    80003ef4:	00000097          	auipc	ra,0x0
    80003ef8:	db4080e7          	jalr	-588(ra) # 80003ca8 <namex>
}
    80003efc:	60a2                	ld	ra,8(sp)
    80003efe:	6402                	ld	s0,0(sp)
    80003f00:	0141                	addi	sp,sp,16
    80003f02:	8082                	ret

0000000080003f04 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    80003f04:	7179                	addi	sp,sp,-48
    80003f06:	f406                	sd	ra,40(sp)
    80003f08:	f022                	sd	s0,32(sp)
    80003f0a:	ec26                	sd	s1,24(sp)
    80003f0c:	e84a                	sd	s2,16(sp)
    80003f0e:	e44e                	sd	s3,8(sp)
    80003f10:	1800                	addi	s0,sp,48
    80003f12:	84aa                	mv	s1,a0
  struct buf *buf = bread(dev, log[dev].start);
    80003f14:	0b000993          	li	s3,176
    80003f18:	033507b3          	mul	a5,a0,s3
    80003f1c:	0001d997          	auipc	s3,0x1d
    80003f20:	fe498993          	addi	s3,s3,-28 # 80020f00 <log>
    80003f24:	99be                	add	s3,s3,a5
    80003f26:	0209a583          	lw	a1,32(s3)
    80003f2a:	fffff097          	auipc	ra,0xfffff
    80003f2e:	010080e7          	jalr	16(ra) # 80002f3a <bread>
    80003f32:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80003f34:	0349a783          	lw	a5,52(s3)
    80003f38:	d13c                	sw	a5,96(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003f3a:	0349a783          	lw	a5,52(s3)
    80003f3e:	02f05763          	blez	a5,80003f6c <write_head+0x68>
    80003f42:	0b000793          	li	a5,176
    80003f46:	02f487b3          	mul	a5,s1,a5
    80003f4a:	0001d717          	auipc	a4,0x1d
    80003f4e:	fee70713          	addi	a4,a4,-18 # 80020f38 <log+0x38>
    80003f52:	97ba                	add	a5,a5,a4
    80003f54:	06450693          	addi	a3,a0,100
    80003f58:	4701                	li	a4,0
    80003f5a:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    80003f5c:	4390                	lw	a2,0(a5)
    80003f5e:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003f60:	2705                	addiw	a4,a4,1
    80003f62:	0791                	addi	a5,a5,4
    80003f64:	0691                	addi	a3,a3,4
    80003f66:	59d0                	lw	a2,52(a1)
    80003f68:	fec74ae3          	blt	a4,a2,80003f5c <write_head+0x58>
  }
  bwrite(buf);
    80003f6c:	854a                	mv	a0,s2
    80003f6e:	fffff097          	auipc	ra,0xfffff
    80003f72:	0c0080e7          	jalr	192(ra) # 8000302e <bwrite>
  brelse(buf);
    80003f76:	854a                	mv	a0,s2
    80003f78:	fffff097          	auipc	ra,0xfffff
    80003f7c:	0f6080e7          	jalr	246(ra) # 8000306e <brelse>
}
    80003f80:	70a2                	ld	ra,40(sp)
    80003f82:	7402                	ld	s0,32(sp)
    80003f84:	64e2                	ld	s1,24(sp)
    80003f86:	6942                	ld	s2,16(sp)
    80003f88:	69a2                	ld	s3,8(sp)
    80003f8a:	6145                	addi	sp,sp,48
    80003f8c:	8082                	ret

0000000080003f8e <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003f8e:	0b000793          	li	a5,176
    80003f92:	02f50733          	mul	a4,a0,a5
    80003f96:	0001d797          	auipc	a5,0x1d
    80003f9a:	f6a78793          	addi	a5,a5,-150 # 80020f00 <log>
    80003f9e:	97ba                	add	a5,a5,a4
    80003fa0:	5bdc                	lw	a5,52(a5)
    80003fa2:	0af05b63          	blez	a5,80004058 <install_trans+0xca>
{
    80003fa6:	7139                	addi	sp,sp,-64
    80003fa8:	fc06                	sd	ra,56(sp)
    80003faa:	f822                	sd	s0,48(sp)
    80003fac:	f426                	sd	s1,40(sp)
    80003fae:	f04a                	sd	s2,32(sp)
    80003fb0:	ec4e                	sd	s3,24(sp)
    80003fb2:	e852                	sd	s4,16(sp)
    80003fb4:	e456                	sd	s5,8(sp)
    80003fb6:	e05a                	sd	s6,0(sp)
    80003fb8:	0080                	addi	s0,sp,64
    80003fba:	0001d797          	auipc	a5,0x1d
    80003fbe:	f7e78793          	addi	a5,a5,-130 # 80020f38 <log+0x38>
    80003fc2:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003fc6:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    80003fc8:	00050b1b          	sext.w	s6,a0
    80003fcc:	0001da97          	auipc	s5,0x1d
    80003fd0:	f34a8a93          	addi	s5,s5,-204 # 80020f00 <log>
    80003fd4:	9aba                	add	s5,s5,a4
    80003fd6:	020aa583          	lw	a1,32(s5)
    80003fda:	013585bb          	addw	a1,a1,s3
    80003fde:	2585                	addiw	a1,a1,1
    80003fe0:	855a                	mv	a0,s6
    80003fe2:	fffff097          	auipc	ra,0xfffff
    80003fe6:	f58080e7          	jalr	-168(ra) # 80002f3a <bread>
    80003fea:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    80003fec:	000a2583          	lw	a1,0(s4)
    80003ff0:	855a                	mv	a0,s6
    80003ff2:	fffff097          	auipc	ra,0xfffff
    80003ff6:	f48080e7          	jalr	-184(ra) # 80002f3a <bread>
    80003ffa:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003ffc:	40000613          	li	a2,1024
    80004000:	06090593          	addi	a1,s2,96
    80004004:	06050513          	addi	a0,a0,96
    80004008:	ffffd097          	auipc	ra,0xffffd
    8000400c:	dd2080e7          	jalr	-558(ra) # 80000dda <memmove>
    bwrite(dbuf);  // write dst to disk
    80004010:	8526                	mv	a0,s1
    80004012:	fffff097          	auipc	ra,0xfffff
    80004016:	01c080e7          	jalr	28(ra) # 8000302e <bwrite>
    bunpin(dbuf);
    8000401a:	8526                	mv	a0,s1
    8000401c:	fffff097          	auipc	ra,0xfffff
    80004020:	12c080e7          	jalr	300(ra) # 80003148 <bunpin>
    brelse(lbuf);
    80004024:	854a                	mv	a0,s2
    80004026:	fffff097          	auipc	ra,0xfffff
    8000402a:	048080e7          	jalr	72(ra) # 8000306e <brelse>
    brelse(dbuf);
    8000402e:	8526                	mv	a0,s1
    80004030:	fffff097          	auipc	ra,0xfffff
    80004034:	03e080e7          	jalr	62(ra) # 8000306e <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004038:	2985                	addiw	s3,s3,1
    8000403a:	0a11                	addi	s4,s4,4
    8000403c:	034aa783          	lw	a5,52(s5)
    80004040:	f8f9cbe3          	blt	s3,a5,80003fd6 <install_trans+0x48>
}
    80004044:	70e2                	ld	ra,56(sp)
    80004046:	7442                	ld	s0,48(sp)
    80004048:	74a2                	ld	s1,40(sp)
    8000404a:	7902                	ld	s2,32(sp)
    8000404c:	69e2                	ld	s3,24(sp)
    8000404e:	6a42                	ld	s4,16(sp)
    80004050:	6aa2                	ld	s5,8(sp)
    80004052:	6b02                	ld	s6,0(sp)
    80004054:	6121                	addi	sp,sp,64
    80004056:	8082                	ret
    80004058:	8082                	ret

000000008000405a <initlog>:
{
    8000405a:	7179                	addi	sp,sp,-48
    8000405c:	f406                	sd	ra,40(sp)
    8000405e:	f022                	sd	s0,32(sp)
    80004060:	ec26                	sd	s1,24(sp)
    80004062:	e84a                	sd	s2,16(sp)
    80004064:	e44e                	sd	s3,8(sp)
    80004066:	e052                	sd	s4,0(sp)
    80004068:	1800                	addi	s0,sp,48
    8000406a:	84aa                	mv	s1,a0
    8000406c:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    8000406e:	0b000713          	li	a4,176
    80004072:	02e509b3          	mul	s3,a0,a4
    80004076:	0001d917          	auipc	s2,0x1d
    8000407a:	e8a90913          	addi	s2,s2,-374 # 80020f00 <log>
    8000407e:	994e                	add	s2,s2,s3
    80004080:	00006597          	auipc	a1,0x6
    80004084:	92058593          	addi	a1,a1,-1760 # 800099a0 <userret+0x910>
    80004088:	854a                	mv	a0,s2
    8000408a:	ffffd097          	auipc	ra,0xffffd
    8000408e:	94e080e7          	jalr	-1714(ra) # 800009d8 <initlock>
  log[dev].start = sb->logstart;
    80004092:	014a2583          	lw	a1,20(s4)
    80004096:	02b92023          	sw	a1,32(s2)
  log[dev].size = sb->nlog;
    8000409a:	010a2783          	lw	a5,16(s4)
    8000409e:	02f92223          	sw	a5,36(s2)
  log[dev].dev = dev;
    800040a2:	02992823          	sw	s1,48(s2)
  struct buf *buf = bread(dev, log[dev].start);
    800040a6:	8526                	mv	a0,s1
    800040a8:	fffff097          	auipc	ra,0xfffff
    800040ac:	e92080e7          	jalr	-366(ra) # 80002f3a <bread>
  log[dev].lh.n = lh->n;
    800040b0:	513c                	lw	a5,96(a0)
    800040b2:	02f92a23          	sw	a5,52(s2)
  for (i = 0; i < log[dev].lh.n; i++) {
    800040b6:	02f05663          	blez	a5,800040e2 <initlog+0x88>
    800040ba:	06450693          	addi	a3,a0,100
    800040be:	0001d717          	auipc	a4,0x1d
    800040c2:	e7a70713          	addi	a4,a4,-390 # 80020f38 <log+0x38>
    800040c6:	974e                	add	a4,a4,s3
    800040c8:	37fd                	addiw	a5,a5,-1
    800040ca:	1782                	slli	a5,a5,0x20
    800040cc:	9381                	srli	a5,a5,0x20
    800040ce:	078a                	slli	a5,a5,0x2
    800040d0:	06850613          	addi	a2,a0,104
    800040d4:	97b2                	add	a5,a5,a2
    log[dev].lh.block[i] = lh->block[i];
    800040d6:	4290                	lw	a2,0(a3)
    800040d8:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    800040da:	0691                	addi	a3,a3,4
    800040dc:	0711                	addi	a4,a4,4
    800040de:	fef69ce3          	bne	a3,a5,800040d6 <initlog+0x7c>
  brelse(buf);
    800040e2:	fffff097          	auipc	ra,0xfffff
    800040e6:	f8c080e7          	jalr	-116(ra) # 8000306e <brelse>

static void
recover_from_log(int dev)
{
  read_head(dev);
  install_trans(dev); // if committed, copy from log to disk
    800040ea:	8526                	mv	a0,s1
    800040ec:	00000097          	auipc	ra,0x0
    800040f0:	ea2080e7          	jalr	-350(ra) # 80003f8e <install_trans>
  log[dev].lh.n = 0;
    800040f4:	0b000793          	li	a5,176
    800040f8:	02f48733          	mul	a4,s1,a5
    800040fc:	0001d797          	auipc	a5,0x1d
    80004100:	e0478793          	addi	a5,a5,-508 # 80020f00 <log>
    80004104:	97ba                	add	a5,a5,a4
    80004106:	0207aa23          	sw	zero,52(a5)
  write_head(dev); // clear the log
    8000410a:	8526                	mv	a0,s1
    8000410c:	00000097          	auipc	ra,0x0
    80004110:	df8080e7          	jalr	-520(ra) # 80003f04 <write_head>
}
    80004114:	70a2                	ld	ra,40(sp)
    80004116:	7402                	ld	s0,32(sp)
    80004118:	64e2                	ld	s1,24(sp)
    8000411a:	6942                	ld	s2,16(sp)
    8000411c:	69a2                	ld	s3,8(sp)
    8000411e:	6a02                	ld	s4,0(sp)
    80004120:	6145                	addi	sp,sp,48
    80004122:	8082                	ret

0000000080004124 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(int dev)
{
    80004124:	7139                	addi	sp,sp,-64
    80004126:	fc06                	sd	ra,56(sp)
    80004128:	f822                	sd	s0,48(sp)
    8000412a:	f426                	sd	s1,40(sp)
    8000412c:	f04a                	sd	s2,32(sp)
    8000412e:	ec4e                	sd	s3,24(sp)
    80004130:	e852                	sd	s4,16(sp)
    80004132:	e456                	sd	s5,8(sp)
    80004134:	0080                	addi	s0,sp,64
    80004136:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    80004138:	0b000913          	li	s2,176
    8000413c:	032507b3          	mul	a5,a0,s2
    80004140:	0001d917          	auipc	s2,0x1d
    80004144:	dc090913          	addi	s2,s2,-576 # 80020f00 <log>
    80004148:	993e                	add	s2,s2,a5
    8000414a:	854a                	mv	a0,s2
    8000414c:	ffffd097          	auipc	ra,0xffffd
    80004150:	960080e7          	jalr	-1696(ra) # 80000aac <acquire>
  while(1){
    if(log[dev].committing){
    80004154:	0001d997          	auipc	s3,0x1d
    80004158:	dac98993          	addi	s3,s3,-596 # 80020f00 <log>
    8000415c:	84ca                	mv	s1,s2
      sleep(&log, &log[dev].lock);
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000415e:	4a79                	li	s4,30
    80004160:	a039                	j	8000416e <begin_op+0x4a>
      sleep(&log, &log[dev].lock);
    80004162:	85ca                	mv	a1,s2
    80004164:	854e                	mv	a0,s3
    80004166:	ffffe097          	auipc	ra,0xffffe
    8000416a:	0f8080e7          	jalr	248(ra) # 8000225e <sleep>
    if(log[dev].committing){
    8000416e:	54dc                	lw	a5,44(s1)
    80004170:	fbed                	bnez	a5,80004162 <begin_op+0x3e>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004172:	549c                	lw	a5,40(s1)
    80004174:	0017871b          	addiw	a4,a5,1
    80004178:	0007069b          	sext.w	a3,a4
    8000417c:	0027179b          	slliw	a5,a4,0x2
    80004180:	9fb9                	addw	a5,a5,a4
    80004182:	0017979b          	slliw	a5,a5,0x1
    80004186:	58d8                	lw	a4,52(s1)
    80004188:	9fb9                	addw	a5,a5,a4
    8000418a:	00fa5963          	bge	s4,a5,8000419c <begin_op+0x78>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log[dev].lock);
    8000418e:	85ca                	mv	a1,s2
    80004190:	854e                	mv	a0,s3
    80004192:	ffffe097          	auipc	ra,0xffffe
    80004196:	0cc080e7          	jalr	204(ra) # 8000225e <sleep>
    8000419a:	bfd1                	j	8000416e <begin_op+0x4a>
    } else {
      log[dev].outstanding += 1;
    8000419c:	0b000513          	li	a0,176
    800041a0:	02aa8ab3          	mul	s5,s5,a0
    800041a4:	0001d797          	auipc	a5,0x1d
    800041a8:	d5c78793          	addi	a5,a5,-676 # 80020f00 <log>
    800041ac:	9abe                	add	s5,s5,a5
    800041ae:	02daa423          	sw	a3,40(s5)
      release(&log[dev].lock);
    800041b2:	854a                	mv	a0,s2
    800041b4:	ffffd097          	auipc	ra,0xffffd
    800041b8:	9c8080e7          	jalr	-1592(ra) # 80000b7c <release>
      break;
    }
  }
}
    800041bc:	70e2                	ld	ra,56(sp)
    800041be:	7442                	ld	s0,48(sp)
    800041c0:	74a2                	ld	s1,40(sp)
    800041c2:	7902                	ld	s2,32(sp)
    800041c4:	69e2                	ld	s3,24(sp)
    800041c6:	6a42                	ld	s4,16(sp)
    800041c8:	6aa2                	ld	s5,8(sp)
    800041ca:	6121                	addi	sp,sp,64
    800041cc:	8082                	ret

00000000800041ce <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(int dev)
{
    800041ce:	715d                	addi	sp,sp,-80
    800041d0:	e486                	sd	ra,72(sp)
    800041d2:	e0a2                	sd	s0,64(sp)
    800041d4:	fc26                	sd	s1,56(sp)
    800041d6:	f84a                	sd	s2,48(sp)
    800041d8:	f44e                	sd	s3,40(sp)
    800041da:	f052                	sd	s4,32(sp)
    800041dc:	ec56                	sd	s5,24(sp)
    800041de:	e85a                	sd	s6,16(sp)
    800041e0:	e45e                	sd	s7,8(sp)
    800041e2:	e062                	sd	s8,0(sp)
    800041e4:	0880                	addi	s0,sp,80
    800041e6:	8aaa                	mv	s5,a0
  int do_commit = 0;

  acquire(&log[dev].lock);
    800041e8:	0b000913          	li	s2,176
    800041ec:	03250933          	mul	s2,a0,s2
    800041f0:	0001d497          	auipc	s1,0x1d
    800041f4:	d1048493          	addi	s1,s1,-752 # 80020f00 <log>
    800041f8:	94ca                	add	s1,s1,s2
    800041fa:	8526                	mv	a0,s1
    800041fc:	ffffd097          	auipc	ra,0xffffd
    80004200:	8b0080e7          	jalr	-1872(ra) # 80000aac <acquire>
  log[dev].outstanding -= 1;
    80004204:	5498                	lw	a4,40(s1)
    80004206:	377d                	addiw	a4,a4,-1
    80004208:	d498                	sw	a4,40(s1)
  if(log[dev].committing)
    8000420a:	54dc                	lw	a5,44(s1)
    8000420c:	efbd                	bnez	a5,8000428a <end_op+0xbc>
    8000420e:	00070b1b          	sext.w	s6,a4
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    80004212:	080b1463          	bnez	s6,8000429a <end_op+0xcc>
    do_commit = 1;
    log[dev].committing = 1;
    80004216:	0b000993          	li	s3,176
    8000421a:	033a87b3          	mul	a5,s5,s3
    8000421e:	0001d997          	auipc	s3,0x1d
    80004222:	ce298993          	addi	s3,s3,-798 # 80020f00 <log>
    80004226:	99be                	add	s3,s3,a5
    80004228:	4785                	li	a5,1
    8000422a:	02f9a623          	sw	a5,44(s3)
    // begin_op() may be waiting for log space,
    // and decrementing log[dev].outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log[dev].lock);
    8000422e:	8526                	mv	a0,s1
    80004230:	ffffd097          	auipc	ra,0xffffd
    80004234:	94c080e7          	jalr	-1716(ra) # 80000b7c <release>
}

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    80004238:	0349a783          	lw	a5,52(s3)
    8000423c:	06f04d63          	bgtz	a5,800042b6 <end_op+0xe8>
    acquire(&log[dev].lock);
    80004240:	8526                	mv	a0,s1
    80004242:	ffffd097          	auipc	ra,0xffffd
    80004246:	86a080e7          	jalr	-1942(ra) # 80000aac <acquire>
    log[dev].committing = 0;
    8000424a:	0001d517          	auipc	a0,0x1d
    8000424e:	cb650513          	addi	a0,a0,-842 # 80020f00 <log>
    80004252:	0b000793          	li	a5,176
    80004256:	02fa87b3          	mul	a5,s5,a5
    8000425a:	97aa                	add	a5,a5,a0
    8000425c:	0207a623          	sw	zero,44(a5)
    wakeup(&log);
    80004260:	ffffe097          	auipc	ra,0xffffe
    80004264:	184080e7          	jalr	388(ra) # 800023e4 <wakeup>
    release(&log[dev].lock);
    80004268:	8526                	mv	a0,s1
    8000426a:	ffffd097          	auipc	ra,0xffffd
    8000426e:	912080e7          	jalr	-1774(ra) # 80000b7c <release>
}
    80004272:	60a6                	ld	ra,72(sp)
    80004274:	6406                	ld	s0,64(sp)
    80004276:	74e2                	ld	s1,56(sp)
    80004278:	7942                	ld	s2,48(sp)
    8000427a:	79a2                	ld	s3,40(sp)
    8000427c:	7a02                	ld	s4,32(sp)
    8000427e:	6ae2                	ld	s5,24(sp)
    80004280:	6b42                	ld	s6,16(sp)
    80004282:	6ba2                	ld	s7,8(sp)
    80004284:	6c02                	ld	s8,0(sp)
    80004286:	6161                	addi	sp,sp,80
    80004288:	8082                	ret
    panic("log[dev].committing");
    8000428a:	00005517          	auipc	a0,0x5
    8000428e:	71e50513          	addi	a0,a0,1822 # 800099a8 <userret+0x918>
    80004292:	ffffc097          	auipc	ra,0xffffc
    80004296:	2c8080e7          	jalr	712(ra) # 8000055a <panic>
    wakeup(&log);
    8000429a:	0001d517          	auipc	a0,0x1d
    8000429e:	c6650513          	addi	a0,a0,-922 # 80020f00 <log>
    800042a2:	ffffe097          	auipc	ra,0xffffe
    800042a6:	142080e7          	jalr	322(ra) # 800023e4 <wakeup>
  release(&log[dev].lock);
    800042aa:	8526                	mv	a0,s1
    800042ac:	ffffd097          	auipc	ra,0xffffd
    800042b0:	8d0080e7          	jalr	-1840(ra) # 80000b7c <release>
  if(do_commit){
    800042b4:	bf7d                	j	80004272 <end_op+0xa4>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800042b6:	0001d797          	auipc	a5,0x1d
    800042ba:	c8278793          	addi	a5,a5,-894 # 80020f38 <log+0x38>
    800042be:	993e                	add	s2,s2,a5
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    800042c0:	000a8c1b          	sext.w	s8,s5
    800042c4:	0b000b93          	li	s7,176
    800042c8:	037a87b3          	mul	a5,s5,s7
    800042cc:	0001db97          	auipc	s7,0x1d
    800042d0:	c34b8b93          	addi	s7,s7,-972 # 80020f00 <log>
    800042d4:	9bbe                	add	s7,s7,a5
    800042d6:	020ba583          	lw	a1,32(s7)
    800042da:	016585bb          	addw	a1,a1,s6
    800042de:	2585                	addiw	a1,a1,1
    800042e0:	8562                	mv	a0,s8
    800042e2:	fffff097          	auipc	ra,0xfffff
    800042e6:	c58080e7          	jalr	-936(ra) # 80002f3a <bread>
    800042ea:	89aa                	mv	s3,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    800042ec:	00092583          	lw	a1,0(s2)
    800042f0:	8562                	mv	a0,s8
    800042f2:	fffff097          	auipc	ra,0xfffff
    800042f6:	c48080e7          	jalr	-952(ra) # 80002f3a <bread>
    800042fa:	8a2a                	mv	s4,a0
    memmove(to->data, from->data, BSIZE);
    800042fc:	40000613          	li	a2,1024
    80004300:	06050593          	addi	a1,a0,96
    80004304:	06098513          	addi	a0,s3,96
    80004308:	ffffd097          	auipc	ra,0xffffd
    8000430c:	ad2080e7          	jalr	-1326(ra) # 80000dda <memmove>
    bwrite(to);  // write the log
    80004310:	854e                	mv	a0,s3
    80004312:	fffff097          	auipc	ra,0xfffff
    80004316:	d1c080e7          	jalr	-740(ra) # 8000302e <bwrite>
    brelse(from);
    8000431a:	8552                	mv	a0,s4
    8000431c:	fffff097          	auipc	ra,0xfffff
    80004320:	d52080e7          	jalr	-686(ra) # 8000306e <brelse>
    brelse(to);
    80004324:	854e                	mv	a0,s3
    80004326:	fffff097          	auipc	ra,0xfffff
    8000432a:	d48080e7          	jalr	-696(ra) # 8000306e <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    8000432e:	2b05                	addiw	s6,s6,1
    80004330:	0911                	addi	s2,s2,4
    80004332:	034ba783          	lw	a5,52(s7)
    80004336:	fafb40e3          	blt	s6,a5,800042d6 <end_op+0x108>
    write_log(dev);     // Write modified blocks from cache to log
    write_head(dev);    // Write header to disk -- the real commit
    8000433a:	8556                	mv	a0,s5
    8000433c:	00000097          	auipc	ra,0x0
    80004340:	bc8080e7          	jalr	-1080(ra) # 80003f04 <write_head>
    install_trans(dev); // Now install writes to home locations
    80004344:	8556                	mv	a0,s5
    80004346:	00000097          	auipc	ra,0x0
    8000434a:	c48080e7          	jalr	-952(ra) # 80003f8e <install_trans>
    log[dev].lh.n = 0;
    8000434e:	0b000793          	li	a5,176
    80004352:	02fa8733          	mul	a4,s5,a5
    80004356:	0001d797          	auipc	a5,0x1d
    8000435a:	baa78793          	addi	a5,a5,-1110 # 80020f00 <log>
    8000435e:	97ba                	add	a5,a5,a4
    80004360:	0207aa23          	sw	zero,52(a5)
    write_head(dev);    // Erase the transaction from the log
    80004364:	8556                	mv	a0,s5
    80004366:	00000097          	auipc	ra,0x0
    8000436a:	b9e080e7          	jalr	-1122(ra) # 80003f04 <write_head>
    8000436e:	bdc9                	j	80004240 <end_op+0x72>

0000000080004370 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004370:	7179                	addi	sp,sp,-48
    80004372:	f406                	sd	ra,40(sp)
    80004374:	f022                	sd	s0,32(sp)
    80004376:	ec26                	sd	s1,24(sp)
    80004378:	e84a                	sd	s2,16(sp)
    8000437a:	e44e                	sd	s3,8(sp)
    8000437c:	e052                	sd	s4,0(sp)
    8000437e:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    80004380:	00852903          	lw	s2,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    80004384:	0b000793          	li	a5,176
    80004388:	02f90733          	mul	a4,s2,a5
    8000438c:	0001d797          	auipc	a5,0x1d
    80004390:	b7478793          	addi	a5,a5,-1164 # 80020f00 <log>
    80004394:	97ba                	add	a5,a5,a4
    80004396:	5bd4                	lw	a3,52(a5)
    80004398:	47f5                	li	a5,29
    8000439a:	0ad7cc63          	blt	a5,a3,80004452 <log_write+0xe2>
    8000439e:	89aa                	mv	s3,a0
    800043a0:	0001d797          	auipc	a5,0x1d
    800043a4:	b6078793          	addi	a5,a5,-1184 # 80020f00 <log>
    800043a8:	97ba                	add	a5,a5,a4
    800043aa:	53dc                	lw	a5,36(a5)
    800043ac:	37fd                	addiw	a5,a5,-1
    800043ae:	0af6d263          	bge	a3,a5,80004452 <log_write+0xe2>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    800043b2:	0b000793          	li	a5,176
    800043b6:	02f90733          	mul	a4,s2,a5
    800043ba:	0001d797          	auipc	a5,0x1d
    800043be:	b4678793          	addi	a5,a5,-1210 # 80020f00 <log>
    800043c2:	97ba                	add	a5,a5,a4
    800043c4:	579c                	lw	a5,40(a5)
    800043c6:	08f05e63          	blez	a5,80004462 <log_write+0xf2>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    800043ca:	0b000793          	li	a5,176
    800043ce:	02f904b3          	mul	s1,s2,a5
    800043d2:	0001da17          	auipc	s4,0x1d
    800043d6:	b2ea0a13          	addi	s4,s4,-1234 # 80020f00 <log>
    800043da:	9a26                	add	s4,s4,s1
    800043dc:	8552                	mv	a0,s4
    800043de:	ffffc097          	auipc	ra,0xffffc
    800043e2:	6ce080e7          	jalr	1742(ra) # 80000aac <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    800043e6:	034a2603          	lw	a2,52(s4)
    800043ea:	08c05463          	blez	a2,80004472 <log_write+0x102>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    800043ee:	00c9a583          	lw	a1,12(s3)
    800043f2:	0001d797          	auipc	a5,0x1d
    800043f6:	b4678793          	addi	a5,a5,-1210 # 80020f38 <log+0x38>
    800043fa:	97a6                	add	a5,a5,s1
  for (i = 0; i < log[dev].lh.n; i++) {
    800043fc:	4701                	li	a4,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    800043fe:	4394                	lw	a3,0(a5)
    80004400:	06b68a63          	beq	a3,a1,80004474 <log_write+0x104>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004404:	2705                	addiw	a4,a4,1
    80004406:	0791                	addi	a5,a5,4
    80004408:	fec71be3          	bne	a4,a2,800043fe <log_write+0x8e>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    8000440c:	02c00793          	li	a5,44
    80004410:	02f907b3          	mul	a5,s2,a5
    80004414:	97b2                	add	a5,a5,a2
    80004416:	07b1                	addi	a5,a5,12
    80004418:	078a                	slli	a5,a5,0x2
    8000441a:	0001d717          	auipc	a4,0x1d
    8000441e:	ae670713          	addi	a4,a4,-1306 # 80020f00 <log>
    80004422:	97ba                	add	a5,a5,a4
    80004424:	00c9a703          	lw	a4,12(s3)
    80004428:	c798                	sw	a4,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    8000442a:	854e                	mv	a0,s3
    8000442c:	fffff097          	auipc	ra,0xfffff
    80004430:	ce0080e7          	jalr	-800(ra) # 8000310c <bpin>
    log[dev].lh.n++;
    80004434:	0b000793          	li	a5,176
    80004438:	02f90933          	mul	s2,s2,a5
    8000443c:	0001d797          	auipc	a5,0x1d
    80004440:	ac478793          	addi	a5,a5,-1340 # 80020f00 <log>
    80004444:	993e                	add	s2,s2,a5
    80004446:	03492783          	lw	a5,52(s2)
    8000444a:	2785                	addiw	a5,a5,1
    8000444c:	02f92a23          	sw	a5,52(s2)
    80004450:	a099                	j	80004496 <log_write+0x126>
    panic("too big a transaction");
    80004452:	00005517          	auipc	a0,0x5
    80004456:	56e50513          	addi	a0,a0,1390 # 800099c0 <userret+0x930>
    8000445a:	ffffc097          	auipc	ra,0xffffc
    8000445e:	100080e7          	jalr	256(ra) # 8000055a <panic>
    panic("log_write outside of trans");
    80004462:	00005517          	auipc	a0,0x5
    80004466:	57650513          	addi	a0,a0,1398 # 800099d8 <userret+0x948>
    8000446a:	ffffc097          	auipc	ra,0xffffc
    8000446e:	0f0080e7          	jalr	240(ra) # 8000055a <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004472:	4701                	li	a4,0
  log[dev].lh.block[i] = b->blockno;
    80004474:	02c00793          	li	a5,44
    80004478:	02f907b3          	mul	a5,s2,a5
    8000447c:	97ba                	add	a5,a5,a4
    8000447e:	07b1                	addi	a5,a5,12
    80004480:	078a                	slli	a5,a5,0x2
    80004482:	0001d697          	auipc	a3,0x1d
    80004486:	a7e68693          	addi	a3,a3,-1410 # 80020f00 <log>
    8000448a:	97b6                	add	a5,a5,a3
    8000448c:	00c9a683          	lw	a3,12(s3)
    80004490:	c794                	sw	a3,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    80004492:	f8e60ce3          	beq	a2,a4,8000442a <log_write+0xba>
  }
  release(&log[dev].lock);
    80004496:	8552                	mv	a0,s4
    80004498:	ffffc097          	auipc	ra,0xffffc
    8000449c:	6e4080e7          	jalr	1764(ra) # 80000b7c <release>
}
    800044a0:	70a2                	ld	ra,40(sp)
    800044a2:	7402                	ld	s0,32(sp)
    800044a4:	64e2                	ld	s1,24(sp)
    800044a6:	6942                	ld	s2,16(sp)
    800044a8:	69a2                	ld	s3,8(sp)
    800044aa:	6a02                	ld	s4,0(sp)
    800044ac:	6145                	addi	sp,sp,48
    800044ae:	8082                	ret

00000000800044b0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800044b0:	1101                	addi	sp,sp,-32
    800044b2:	ec06                	sd	ra,24(sp)
    800044b4:	e822                	sd	s0,16(sp)
    800044b6:	e426                	sd	s1,8(sp)
    800044b8:	e04a                	sd	s2,0(sp)
    800044ba:	1000                	addi	s0,sp,32
    800044bc:	84aa                	mv	s1,a0
    800044be:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800044c0:	00005597          	auipc	a1,0x5
    800044c4:	53858593          	addi	a1,a1,1336 # 800099f8 <userret+0x968>
    800044c8:	0521                	addi	a0,a0,8
    800044ca:	ffffc097          	auipc	ra,0xffffc
    800044ce:	50e080e7          	jalr	1294(ra) # 800009d8 <initlock>
  lk->name = name;
    800044d2:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    800044d6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044da:	0204a823          	sw	zero,48(s1)
}
    800044de:	60e2                	ld	ra,24(sp)
    800044e0:	6442                	ld	s0,16(sp)
    800044e2:	64a2                	ld	s1,8(sp)
    800044e4:	6902                	ld	s2,0(sp)
    800044e6:	6105                	addi	sp,sp,32
    800044e8:	8082                	ret

00000000800044ea <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800044ea:	1101                	addi	sp,sp,-32
    800044ec:	ec06                	sd	ra,24(sp)
    800044ee:	e822                	sd	s0,16(sp)
    800044f0:	e426                	sd	s1,8(sp)
    800044f2:	e04a                	sd	s2,0(sp)
    800044f4:	1000                	addi	s0,sp,32
    800044f6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044f8:	00850913          	addi	s2,a0,8
    800044fc:	854a                	mv	a0,s2
    800044fe:	ffffc097          	auipc	ra,0xffffc
    80004502:	5ae080e7          	jalr	1454(ra) # 80000aac <acquire>
  while (lk->locked) {
    80004506:	409c                	lw	a5,0(s1)
    80004508:	cb89                	beqz	a5,8000451a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000450a:	85ca                	mv	a1,s2
    8000450c:	8526                	mv	a0,s1
    8000450e:	ffffe097          	auipc	ra,0xffffe
    80004512:	d50080e7          	jalr	-688(ra) # 8000225e <sleep>
  while (lk->locked) {
    80004516:	409c                	lw	a5,0(s1)
    80004518:	fbed                	bnez	a5,8000450a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000451a:	4785                	li	a5,1
    8000451c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000451e:	ffffd097          	auipc	ra,0xffffd
    80004522:	584080e7          	jalr	1412(ra) # 80001aa2 <myproc>
    80004526:	413c                	lw	a5,64(a0)
    80004528:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    8000452a:	854a                	mv	a0,s2
    8000452c:	ffffc097          	auipc	ra,0xffffc
    80004530:	650080e7          	jalr	1616(ra) # 80000b7c <release>
}
    80004534:	60e2                	ld	ra,24(sp)
    80004536:	6442                	ld	s0,16(sp)
    80004538:	64a2                	ld	s1,8(sp)
    8000453a:	6902                	ld	s2,0(sp)
    8000453c:	6105                	addi	sp,sp,32
    8000453e:	8082                	ret

0000000080004540 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004540:	1101                	addi	sp,sp,-32
    80004542:	ec06                	sd	ra,24(sp)
    80004544:	e822                	sd	s0,16(sp)
    80004546:	e426                	sd	s1,8(sp)
    80004548:	e04a                	sd	s2,0(sp)
    8000454a:	1000                	addi	s0,sp,32
    8000454c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000454e:	00850913          	addi	s2,a0,8
    80004552:	854a                	mv	a0,s2
    80004554:	ffffc097          	auipc	ra,0xffffc
    80004558:	558080e7          	jalr	1368(ra) # 80000aac <acquire>
  lk->locked = 0;
    8000455c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004560:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    80004564:	8526                	mv	a0,s1
    80004566:	ffffe097          	auipc	ra,0xffffe
    8000456a:	e7e080e7          	jalr	-386(ra) # 800023e4 <wakeup>
  release(&lk->lk);
    8000456e:	854a                	mv	a0,s2
    80004570:	ffffc097          	auipc	ra,0xffffc
    80004574:	60c080e7          	jalr	1548(ra) # 80000b7c <release>
}
    80004578:	60e2                	ld	ra,24(sp)
    8000457a:	6442                	ld	s0,16(sp)
    8000457c:	64a2                	ld	s1,8(sp)
    8000457e:	6902                	ld	s2,0(sp)
    80004580:	6105                	addi	sp,sp,32
    80004582:	8082                	ret

0000000080004584 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004584:	7179                	addi	sp,sp,-48
    80004586:	f406                	sd	ra,40(sp)
    80004588:	f022                	sd	s0,32(sp)
    8000458a:	ec26                	sd	s1,24(sp)
    8000458c:	e84a                	sd	s2,16(sp)
    8000458e:	e44e                	sd	s3,8(sp)
    80004590:	1800                	addi	s0,sp,48
    80004592:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004594:	00850913          	addi	s2,a0,8
    80004598:	854a                	mv	a0,s2
    8000459a:	ffffc097          	auipc	ra,0xffffc
    8000459e:	512080e7          	jalr	1298(ra) # 80000aac <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800045a2:	409c                	lw	a5,0(s1)
    800045a4:	ef99                	bnez	a5,800045c2 <holdingsleep+0x3e>
    800045a6:	4481                	li	s1,0
  release(&lk->lk);
    800045a8:	854a                	mv	a0,s2
    800045aa:	ffffc097          	auipc	ra,0xffffc
    800045ae:	5d2080e7          	jalr	1490(ra) # 80000b7c <release>
  return r;
}
    800045b2:	8526                	mv	a0,s1
    800045b4:	70a2                	ld	ra,40(sp)
    800045b6:	7402                	ld	s0,32(sp)
    800045b8:	64e2                	ld	s1,24(sp)
    800045ba:	6942                	ld	s2,16(sp)
    800045bc:	69a2                	ld	s3,8(sp)
    800045be:	6145                	addi	sp,sp,48
    800045c0:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800045c2:	0304a983          	lw	s3,48(s1)
    800045c6:	ffffd097          	auipc	ra,0xffffd
    800045ca:	4dc080e7          	jalr	1244(ra) # 80001aa2 <myproc>
    800045ce:	4124                	lw	s1,64(a0)
    800045d0:	413484b3          	sub	s1,s1,s3
    800045d4:	0014b493          	seqz	s1,s1
    800045d8:	bfc1                	j	800045a8 <holdingsleep+0x24>

00000000800045da <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800045da:	1141                	addi	sp,sp,-16
    800045dc:	e406                	sd	ra,8(sp)
    800045de:	e022                	sd	s0,0(sp)
    800045e0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800045e2:	00005597          	auipc	a1,0x5
    800045e6:	42658593          	addi	a1,a1,1062 # 80009a08 <userret+0x978>
    800045ea:	0001d517          	auipc	a0,0x1d
    800045ee:	b1650513          	addi	a0,a0,-1258 # 80021100 <ftable>
    800045f2:	ffffc097          	auipc	ra,0xffffc
    800045f6:	3e6080e7          	jalr	998(ra) # 800009d8 <initlock>
}
    800045fa:	60a2                	ld	ra,8(sp)
    800045fc:	6402                	ld	s0,0(sp)
    800045fe:	0141                	addi	sp,sp,16
    80004600:	8082                	ret

0000000080004602 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004602:	1101                	addi	sp,sp,-32
    80004604:	ec06                	sd	ra,24(sp)
    80004606:	e822                	sd	s0,16(sp)
    80004608:	e426                	sd	s1,8(sp)
    8000460a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000460c:	0001d517          	auipc	a0,0x1d
    80004610:	af450513          	addi	a0,a0,-1292 # 80021100 <ftable>
    80004614:	ffffc097          	auipc	ra,0xffffc
    80004618:	498080e7          	jalr	1176(ra) # 80000aac <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000461c:	0001d497          	auipc	s1,0x1d
    80004620:	b0448493          	addi	s1,s1,-1276 # 80021120 <ftable+0x20>
    80004624:	0001e717          	auipc	a4,0x1e
    80004628:	0dc70713          	addi	a4,a4,220 # 80022700 <ftable+0x1600>
    if(f->ref == 0){
    8000462c:	40dc                	lw	a5,4(s1)
    8000462e:	cf99                	beqz	a5,8000464c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004630:	03848493          	addi	s1,s1,56
    80004634:	fee49ce3          	bne	s1,a4,8000462c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004638:	0001d517          	auipc	a0,0x1d
    8000463c:	ac850513          	addi	a0,a0,-1336 # 80021100 <ftable>
    80004640:	ffffc097          	auipc	ra,0xffffc
    80004644:	53c080e7          	jalr	1340(ra) # 80000b7c <release>
  return 0;
    80004648:	4481                	li	s1,0
    8000464a:	a819                	j	80004660 <filealloc+0x5e>
      f->ref = 1;
    8000464c:	4785                	li	a5,1
    8000464e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004650:	0001d517          	auipc	a0,0x1d
    80004654:	ab050513          	addi	a0,a0,-1360 # 80021100 <ftable>
    80004658:	ffffc097          	auipc	ra,0xffffc
    8000465c:	524080e7          	jalr	1316(ra) # 80000b7c <release>
}
    80004660:	8526                	mv	a0,s1
    80004662:	60e2                	ld	ra,24(sp)
    80004664:	6442                	ld	s0,16(sp)
    80004666:	64a2                	ld	s1,8(sp)
    80004668:	6105                	addi	sp,sp,32
    8000466a:	8082                	ret

000000008000466c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000466c:	1101                	addi	sp,sp,-32
    8000466e:	ec06                	sd	ra,24(sp)
    80004670:	e822                	sd	s0,16(sp)
    80004672:	e426                	sd	s1,8(sp)
    80004674:	1000                	addi	s0,sp,32
    80004676:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004678:	0001d517          	auipc	a0,0x1d
    8000467c:	a8850513          	addi	a0,a0,-1400 # 80021100 <ftable>
    80004680:	ffffc097          	auipc	ra,0xffffc
    80004684:	42c080e7          	jalr	1068(ra) # 80000aac <acquire>
  if(f->ref < 1)
    80004688:	40dc                	lw	a5,4(s1)
    8000468a:	02f05263          	blez	a5,800046ae <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000468e:	2785                	addiw	a5,a5,1
    80004690:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004692:	0001d517          	auipc	a0,0x1d
    80004696:	a6e50513          	addi	a0,a0,-1426 # 80021100 <ftable>
    8000469a:	ffffc097          	auipc	ra,0xffffc
    8000469e:	4e2080e7          	jalr	1250(ra) # 80000b7c <release>
  return f;
}
    800046a2:	8526                	mv	a0,s1
    800046a4:	60e2                	ld	ra,24(sp)
    800046a6:	6442                	ld	s0,16(sp)
    800046a8:	64a2                	ld	s1,8(sp)
    800046aa:	6105                	addi	sp,sp,32
    800046ac:	8082                	ret
    panic("filedup");
    800046ae:	00005517          	auipc	a0,0x5
    800046b2:	36250513          	addi	a0,a0,866 # 80009a10 <userret+0x980>
    800046b6:	ffffc097          	auipc	ra,0xffffc
    800046ba:	ea4080e7          	jalr	-348(ra) # 8000055a <panic>

00000000800046be <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800046be:	7139                	addi	sp,sp,-64
    800046c0:	fc06                	sd	ra,56(sp)
    800046c2:	f822                	sd	s0,48(sp)
    800046c4:	f426                	sd	s1,40(sp)
    800046c6:	f04a                	sd	s2,32(sp)
    800046c8:	ec4e                	sd	s3,24(sp)
    800046ca:	e852                	sd	s4,16(sp)
    800046cc:	e456                	sd	s5,8(sp)
    800046ce:	e05a                	sd	s6,0(sp)
    800046d0:	0080                	addi	s0,sp,64
    800046d2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800046d4:	0001d517          	auipc	a0,0x1d
    800046d8:	a2c50513          	addi	a0,a0,-1492 # 80021100 <ftable>
    800046dc:	ffffc097          	auipc	ra,0xffffc
    800046e0:	3d0080e7          	jalr	976(ra) # 80000aac <acquire>
  if(f->ref < 1)
    800046e4:	40dc                	lw	a5,4(s1)
    800046e6:	06f05a63          	blez	a5,8000475a <fileclose+0x9c>
    panic("fileclose");
  if(--f->ref > 0){
    800046ea:	37fd                	addiw	a5,a5,-1
    800046ec:	0007871b          	sext.w	a4,a5
    800046f0:	c0dc                	sw	a5,4(s1)
    800046f2:	06e04c63          	bgtz	a4,8000476a <fileclose+0xac>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800046f6:	0004a903          	lw	s2,0(s1)
    800046fa:	0094ca03          	lbu	s4,9(s1)
    800046fe:	0184ba83          	ld	s5,24(s1)
    80004702:	0204b983          	ld	s3,32(s1)
    80004706:	0284bb03          	ld	s6,40(s1)
  f->ref = 0;
    8000470a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000470e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004712:	0001d517          	auipc	a0,0x1d
    80004716:	9ee50513          	addi	a0,a0,-1554 # 80021100 <ftable>
    8000471a:	ffffc097          	auipc	ra,0xffffc
    8000471e:	462080e7          	jalr	1122(ra) # 80000b7c <release>

  if(ff.type == FD_PIPE){
    80004722:	4785                	li	a5,1
    80004724:	06f90563          	beq	s2,a5,8000478e <fileclose+0xd0>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_SOCK){
    80004728:	4791                	li	a5,4
    8000472a:	06f90963          	beq	s2,a5,8000479c <fileclose+0xde>
    sockclose(ff.sock, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000472e:	3979                	addiw	s2,s2,-2
    80004730:	4785                	li	a5,1
    80004732:	0527e463          	bltu	a5,s2,8000477a <fileclose+0xbc>
    begin_op(ff.ip->dev);
    80004736:	0009a503          	lw	a0,0(s3)
    8000473a:	00000097          	auipc	ra,0x0
    8000473e:	9ea080e7          	jalr	-1558(ra) # 80004124 <begin_op>
    iput(ff.ip);
    80004742:	854e                	mv	a0,s3
    80004744:	fffff097          	auipc	ra,0xfffff
    80004748:	10a080e7          	jalr	266(ra) # 8000384e <iput>
    end_op(ff.ip->dev);
    8000474c:	0009a503          	lw	a0,0(s3)
    80004750:	00000097          	auipc	ra,0x0
    80004754:	a7e080e7          	jalr	-1410(ra) # 800041ce <end_op>
    80004758:	a00d                	j	8000477a <fileclose+0xbc>
    panic("fileclose");
    8000475a:	00005517          	auipc	a0,0x5
    8000475e:	2be50513          	addi	a0,a0,702 # 80009a18 <userret+0x988>
    80004762:	ffffc097          	auipc	ra,0xffffc
    80004766:	df8080e7          	jalr	-520(ra) # 8000055a <panic>
    release(&ftable.lock);
    8000476a:	0001d517          	auipc	a0,0x1d
    8000476e:	99650513          	addi	a0,a0,-1642 # 80021100 <ftable>
    80004772:	ffffc097          	auipc	ra,0xffffc
    80004776:	40a080e7          	jalr	1034(ra) # 80000b7c <release>
  }
}
    8000477a:	70e2                	ld	ra,56(sp)
    8000477c:	7442                	ld	s0,48(sp)
    8000477e:	74a2                	ld	s1,40(sp)
    80004780:	7902                	ld	s2,32(sp)
    80004782:	69e2                	ld	s3,24(sp)
    80004784:	6a42                	ld	s4,16(sp)
    80004786:	6aa2                	ld	s5,8(sp)
    80004788:	6b02                	ld	s6,0(sp)
    8000478a:	6121                	addi	sp,sp,64
    8000478c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000478e:	85d2                	mv	a1,s4
    80004790:	8556                	mv	a0,s5
    80004792:	00000097          	auipc	ra,0x0
    80004796:	3aa080e7          	jalr	938(ra) # 80004b3c <pipeclose>
    8000479a:	b7c5                	j	8000477a <fileclose+0xbc>
    sockclose(ff.sock, ff.writable);
    8000479c:	85d2                	mv	a1,s4
    8000479e:	855a                	mv	a0,s6
    800047a0:	00003097          	auipc	ra,0x3
    800047a4:	b48080e7          	jalr	-1208(ra) # 800072e8 <sockclose>
    800047a8:	bfc9                	j	8000477a <fileclose+0xbc>

00000000800047aa <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800047aa:	715d                	addi	sp,sp,-80
    800047ac:	e486                	sd	ra,72(sp)
    800047ae:	e0a2                	sd	s0,64(sp)
    800047b0:	fc26                	sd	s1,56(sp)
    800047b2:	f84a                	sd	s2,48(sp)
    800047b4:	f44e                	sd	s3,40(sp)
    800047b6:	0880                	addi	s0,sp,80
    800047b8:	84aa                	mv	s1,a0
    800047ba:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800047bc:	ffffd097          	auipc	ra,0xffffd
    800047c0:	2e6080e7          	jalr	742(ra) # 80001aa2 <myproc>
  struct stat st;

  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800047c4:	409c                	lw	a5,0(s1)
    800047c6:	37f9                	addiw	a5,a5,-2
    800047c8:	4705                	li	a4,1
    800047ca:	04f76763          	bltu	a4,a5,80004818 <filestat+0x6e>
    800047ce:	892a                	mv	s2,a0
    ilock(f->ip);
    800047d0:	7088                	ld	a0,32(s1)
    800047d2:	fffff097          	auipc	ra,0xfffff
    800047d6:	f6e080e7          	jalr	-146(ra) # 80003740 <ilock>
    stati(f->ip, &st);
    800047da:	fb840593          	addi	a1,s0,-72
    800047de:	7088                	ld	a0,32(s1)
    800047e0:	fffff097          	auipc	ra,0xfffff
    800047e4:	1c6080e7          	jalr	454(ra) # 800039a6 <stati>
    iunlock(f->ip);
    800047e8:	7088                	ld	a0,32(s1)
    800047ea:	fffff097          	auipc	ra,0xfffff
    800047ee:	018080e7          	jalr	24(ra) # 80003802 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800047f2:	46e1                	li	a3,24
    800047f4:	fb840613          	addi	a2,s0,-72
    800047f8:	85ce                	mv	a1,s3
    800047fa:	05893503          	ld	a0,88(s2)
    800047fe:	ffffd097          	auipc	ra,0xffffd
    80004802:	f98080e7          	jalr	-104(ra) # 80001796 <copyout>
    80004806:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000480a:	60a6                	ld	ra,72(sp)
    8000480c:	6406                	ld	s0,64(sp)
    8000480e:	74e2                	ld	s1,56(sp)
    80004810:	7942                	ld	s2,48(sp)
    80004812:	79a2                	ld	s3,40(sp)
    80004814:	6161                	addi	sp,sp,80
    80004816:	8082                	ret
  return -1;
    80004818:	557d                	li	a0,-1
    8000481a:	bfc5                	j	8000480a <filestat+0x60>

000000008000481c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000481c:	7179                	addi	sp,sp,-48
    8000481e:	f406                	sd	ra,40(sp)
    80004820:	f022                	sd	s0,32(sp)
    80004822:	ec26                	sd	s1,24(sp)
    80004824:	e84a                	sd	s2,16(sp)
    80004826:	e44e                	sd	s3,8(sp)
    80004828:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000482a:	00854783          	lbu	a5,8(a0)
    8000482e:	cfd5                	beqz	a5,800048ea <fileread+0xce>
    80004830:	84aa                	mv	s1,a0
    80004832:	89ae                	mv	s3,a1
    80004834:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004836:	411c                	lw	a5,0(a0)
    80004838:	4705                	li	a4,1
    8000483a:	04e78c63          	beq	a5,a4,80004892 <fileread+0x76>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_SOCK){
    8000483e:	4711                	li	a4,4
    80004840:	06e78063          	beq	a5,a4,800048a0 <fileread+0x84>
    r = sockread(f->sock, addr, n);
  } else if(f->type == FD_DEVICE){
    80004844:	470d                	li	a4,3
    80004846:	06e78463          	beq	a5,a4,800048ae <fileread+0x92>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    8000484a:	4709                	li	a4,2
    8000484c:	08e79763          	bne	a5,a4,800048da <fileread+0xbe>
    ilock(f->ip);
    80004850:	7108                	ld	a0,32(a0)
    80004852:	fffff097          	auipc	ra,0xfffff
    80004856:	eee080e7          	jalr	-274(ra) # 80003740 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000485a:	874a                	mv	a4,s2
    8000485c:	5894                	lw	a3,48(s1)
    8000485e:	864e                	mv	a2,s3
    80004860:	4585                	li	a1,1
    80004862:	7088                	ld	a0,32(s1)
    80004864:	fffff097          	auipc	ra,0xfffff
    80004868:	16c080e7          	jalr	364(ra) # 800039d0 <readi>
    8000486c:	892a                	mv	s2,a0
    8000486e:	00a05563          	blez	a0,80004878 <fileread+0x5c>
      f->off += r;
    80004872:	589c                	lw	a5,48(s1)
    80004874:	9fa9                	addw	a5,a5,a0
    80004876:	d89c                	sw	a5,48(s1)
    iunlock(f->ip);
    80004878:	7088                	ld	a0,32(s1)
    8000487a:	fffff097          	auipc	ra,0xfffff
    8000487e:	f88080e7          	jalr	-120(ra) # 80003802 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004882:	854a                	mv	a0,s2
    80004884:	70a2                	ld	ra,40(sp)
    80004886:	7402                	ld	s0,32(sp)
    80004888:	64e2                	ld	s1,24(sp)
    8000488a:	6942                	ld	s2,16(sp)
    8000488c:	69a2                	ld	s3,8(sp)
    8000488e:	6145                	addi	sp,sp,48
    80004890:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004892:	6d08                	ld	a0,24(a0)
    80004894:	00000097          	auipc	ra,0x0
    80004898:	42c080e7          	jalr	1068(ra) # 80004cc0 <piperead>
    8000489c:	892a                	mv	s2,a0
    8000489e:	b7d5                	j	80004882 <fileread+0x66>
    r = sockread(f->sock, addr, n);
    800048a0:	7508                	ld	a0,40(a0)
    800048a2:	00003097          	auipc	ra,0x3
    800048a6:	ba0080e7          	jalr	-1120(ra) # 80007442 <sockread>
    800048aa:	892a                	mv	s2,a0
    800048ac:	bfd9                	j	80004882 <fileread+0x66>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048ae:	03451783          	lh	a5,52(a0)
    800048b2:	03079693          	slli	a3,a5,0x30
    800048b6:	92c1                	srli	a3,a3,0x30
    800048b8:	4725                	li	a4,9
    800048ba:	02d76a63          	bltu	a4,a3,800048ee <fileread+0xd2>
    800048be:	0792                	slli	a5,a5,0x4
    800048c0:	0001c717          	auipc	a4,0x1c
    800048c4:	7a070713          	addi	a4,a4,1952 # 80021060 <devsw>
    800048c8:	97ba                	add	a5,a5,a4
    800048ca:	639c                	ld	a5,0(a5)
    800048cc:	c39d                	beqz	a5,800048f2 <fileread+0xd6>
    r = devsw[f->major].read(f, 1, addr, n);
    800048ce:	86b2                	mv	a3,a2
    800048d0:	862e                	mv	a2,a1
    800048d2:	4585                	li	a1,1
    800048d4:	9782                	jalr	a5
    800048d6:	892a                	mv	s2,a0
    800048d8:	b76d                	j	80004882 <fileread+0x66>
    panic("fileread");
    800048da:	00005517          	auipc	a0,0x5
    800048de:	14e50513          	addi	a0,a0,334 # 80009a28 <userret+0x998>
    800048e2:	ffffc097          	auipc	ra,0xffffc
    800048e6:	c78080e7          	jalr	-904(ra) # 8000055a <panic>
    return -1;
    800048ea:	597d                	li	s2,-1
    800048ec:	bf59                	j	80004882 <fileread+0x66>
      return -1;
    800048ee:	597d                	li	s2,-1
    800048f0:	bf49                	j	80004882 <fileread+0x66>
    800048f2:	597d                	li	s2,-1
    800048f4:	b779                	j	80004882 <fileread+0x66>

00000000800048f6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800048f6:	00954783          	lbu	a5,9(a0)
    800048fa:	14078f63          	beqz	a5,80004a58 <filewrite+0x162>
{
    800048fe:	715d                	addi	sp,sp,-80
    80004900:	e486                	sd	ra,72(sp)
    80004902:	e0a2                	sd	s0,64(sp)
    80004904:	fc26                	sd	s1,56(sp)
    80004906:	f84a                	sd	s2,48(sp)
    80004908:	f44e                	sd	s3,40(sp)
    8000490a:	f052                	sd	s4,32(sp)
    8000490c:	ec56                	sd	s5,24(sp)
    8000490e:	e85a                	sd	s6,16(sp)
    80004910:	e45e                	sd	s7,8(sp)
    80004912:	e062                	sd	s8,0(sp)
    80004914:	0880                	addi	s0,sp,80
    80004916:	84aa                	mv	s1,a0
    80004918:	8aae                	mv	s5,a1
    8000491a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000491c:	411c                	lw	a5,0(a0)
    8000491e:	4705                	li	a4,1
    80004920:	02e78563          	beq	a5,a4,8000494a <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_SOCK){
    80004924:	4711                	li	a4,4
    80004926:	02e78863          	beq	a5,a4,80004956 <filewrite+0x60>
    ret = sockwrite(f->sock, addr, n);
  } else if(f->type == FD_DEVICE){
    8000492a:	470d                	li	a4,3
    8000492c:	02e78b63          	beq	a5,a4,80004962 <filewrite+0x6c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004930:	4709                	li	a4,2
    80004932:	10e79b63          	bne	a5,a4,80004a48 <filewrite+0x152>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004936:	10c05563          	blez	a2,80004a40 <filewrite+0x14a>
    int i = 0;
    8000493a:	4981                	li	s3,0
    8000493c:	6b05                	lui	s6,0x1
    8000493e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004942:	6b85                	lui	s7,0x1
    80004944:	c00b8b9b          	addiw	s7,s7,-1024
    80004948:	a045                	j	800049e8 <filewrite+0xf2>
    ret = pipewrite(f->pipe, addr, n);
    8000494a:	6d08                	ld	a0,24(a0)
    8000494c:	00000097          	auipc	ra,0x0
    80004950:	260080e7          	jalr	608(ra) # 80004bac <pipewrite>
    80004954:	a0d1                	j	80004a18 <filewrite+0x122>
    ret = sockwrite(f->sock, addr, n);
    80004956:	7508                	ld	a0,40(a0)
    80004958:	00003097          	auipc	ra,0x3
    8000495c:	a40080e7          	jalr	-1472(ra) # 80007398 <sockwrite>
    80004960:	a865                	j	80004a18 <filewrite+0x122>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004962:	03451783          	lh	a5,52(a0)
    80004966:	03079693          	slli	a3,a5,0x30
    8000496a:	92c1                	srli	a3,a3,0x30
    8000496c:	4725                	li	a4,9
    8000496e:	0ed76763          	bltu	a4,a3,80004a5c <filewrite+0x166>
    80004972:	0792                	slli	a5,a5,0x4
    80004974:	0001c717          	auipc	a4,0x1c
    80004978:	6ec70713          	addi	a4,a4,1772 # 80021060 <devsw>
    8000497c:	97ba                	add	a5,a5,a4
    8000497e:	679c                	ld	a5,8(a5)
    80004980:	c3e5                	beqz	a5,80004a60 <filewrite+0x16a>
    ret = devsw[f->major].write(f, 1, addr, n);
    80004982:	86b2                	mv	a3,a2
    80004984:	862e                	mv	a2,a1
    80004986:	4585                	li	a1,1
    80004988:	9782                	jalr	a5
    8000498a:	a079                	j	80004a18 <filewrite+0x122>
    8000498c:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    80004990:	709c                	ld	a5,32(s1)
    80004992:	4388                	lw	a0,0(a5)
    80004994:	fffff097          	auipc	ra,0xfffff
    80004998:	790080e7          	jalr	1936(ra) # 80004124 <begin_op>
      ilock(f->ip);
    8000499c:	7088                	ld	a0,32(s1)
    8000499e:	fffff097          	auipc	ra,0xfffff
    800049a2:	da2080e7          	jalr	-606(ra) # 80003740 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049a6:	8762                	mv	a4,s8
    800049a8:	5894                	lw	a3,48(s1)
    800049aa:	01598633          	add	a2,s3,s5
    800049ae:	4585                	li	a1,1
    800049b0:	7088                	ld	a0,32(s1)
    800049b2:	fffff097          	auipc	ra,0xfffff
    800049b6:	112080e7          	jalr	274(ra) # 80003ac4 <writei>
    800049ba:	892a                	mv	s2,a0
    800049bc:	02a05e63          	blez	a0,800049f8 <filewrite+0x102>
        f->off += r;
    800049c0:	589c                	lw	a5,48(s1)
    800049c2:	9fa9                	addw	a5,a5,a0
    800049c4:	d89c                	sw	a5,48(s1)
      iunlock(f->ip);
    800049c6:	7088                	ld	a0,32(s1)
    800049c8:	fffff097          	auipc	ra,0xfffff
    800049cc:	e3a080e7          	jalr	-454(ra) # 80003802 <iunlock>
      end_op(f->ip->dev);
    800049d0:	709c                	ld	a5,32(s1)
    800049d2:	4388                	lw	a0,0(a5)
    800049d4:	fffff097          	auipc	ra,0xfffff
    800049d8:	7fa080e7          	jalr	2042(ra) # 800041ce <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800049dc:	052c1a63          	bne	s8,s2,80004a30 <filewrite+0x13a>
        panic("short filewrite");
      i += r;
    800049e0:	013909bb          	addw	s3,s2,s3
    while(i < n){
    800049e4:	0349d763          	bge	s3,s4,80004a12 <filewrite+0x11c>
      int n1 = n - i;
    800049e8:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800049ec:	893e                	mv	s2,a5
    800049ee:	2781                	sext.w	a5,a5
    800049f0:	f8fb5ee3          	bge	s6,a5,8000498c <filewrite+0x96>
    800049f4:	895e                	mv	s2,s7
    800049f6:	bf59                	j	8000498c <filewrite+0x96>
      iunlock(f->ip);
    800049f8:	7088                	ld	a0,32(s1)
    800049fa:	fffff097          	auipc	ra,0xfffff
    800049fe:	e08080e7          	jalr	-504(ra) # 80003802 <iunlock>
      end_op(f->ip->dev);
    80004a02:	709c                	ld	a5,32(s1)
    80004a04:	4388                	lw	a0,0(a5)
    80004a06:	fffff097          	auipc	ra,0xfffff
    80004a0a:	7c8080e7          	jalr	1992(ra) # 800041ce <end_op>
      if(r < 0)
    80004a0e:	fc0957e3          	bgez	s2,800049dc <filewrite+0xe6>
    }
    ret = (i == n ? n : -1);
    80004a12:	8552                	mv	a0,s4
    80004a14:	033a1863          	bne	s4,s3,80004a44 <filewrite+0x14e>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a18:	60a6                	ld	ra,72(sp)
    80004a1a:	6406                	ld	s0,64(sp)
    80004a1c:	74e2                	ld	s1,56(sp)
    80004a1e:	7942                	ld	s2,48(sp)
    80004a20:	79a2                	ld	s3,40(sp)
    80004a22:	7a02                	ld	s4,32(sp)
    80004a24:	6ae2                	ld	s5,24(sp)
    80004a26:	6b42                	ld	s6,16(sp)
    80004a28:	6ba2                	ld	s7,8(sp)
    80004a2a:	6c02                	ld	s8,0(sp)
    80004a2c:	6161                	addi	sp,sp,80
    80004a2e:	8082                	ret
        panic("short filewrite");
    80004a30:	00005517          	auipc	a0,0x5
    80004a34:	00850513          	addi	a0,a0,8 # 80009a38 <userret+0x9a8>
    80004a38:	ffffc097          	auipc	ra,0xffffc
    80004a3c:	b22080e7          	jalr	-1246(ra) # 8000055a <panic>
    int i = 0;
    80004a40:	4981                	li	s3,0
    80004a42:	bfc1                	j	80004a12 <filewrite+0x11c>
    ret = (i == n ? n : -1);
    80004a44:	557d                	li	a0,-1
    80004a46:	bfc9                	j	80004a18 <filewrite+0x122>
    panic("filewrite");
    80004a48:	00005517          	auipc	a0,0x5
    80004a4c:	00050513          	mv	a0,a0
    80004a50:	ffffc097          	auipc	ra,0xffffc
    80004a54:	b0a080e7          	jalr	-1270(ra) # 8000055a <panic>
    return -1;
    80004a58:	557d                	li	a0,-1
}
    80004a5a:	8082                	ret
      return -1;
    80004a5c:	557d                	li	a0,-1
    80004a5e:	bf6d                	j	80004a18 <filewrite+0x122>
    80004a60:	557d                	li	a0,-1
    80004a62:	bf5d                	j	80004a18 <filewrite+0x122>

0000000080004a64 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a64:	7179                	addi	sp,sp,-48
    80004a66:	f406                	sd	ra,40(sp)
    80004a68:	f022                	sd	s0,32(sp)
    80004a6a:	ec26                	sd	s1,24(sp)
    80004a6c:	e84a                	sd	s2,16(sp)
    80004a6e:	e44e                	sd	s3,8(sp)
    80004a70:	e052                	sd	s4,0(sp)
    80004a72:	1800                	addi	s0,sp,48
    80004a74:	84aa                	mv	s1,a0
    80004a76:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a78:	0005b023          	sd	zero,0(a1)
    80004a7c:	00053023          	sd	zero,0(a0) # 80009a48 <userret+0x9b8>
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a80:	00000097          	auipc	ra,0x0
    80004a84:	b82080e7          	jalr	-1150(ra) # 80004602 <filealloc>
    80004a88:	e088                	sd	a0,0(s1)
    80004a8a:	c549                	beqz	a0,80004b14 <pipealloc+0xb0>
    80004a8c:	00000097          	auipc	ra,0x0
    80004a90:	b76080e7          	jalr	-1162(ra) # 80004602 <filealloc>
    80004a94:	00aa3023          	sd	a0,0(s4)
    80004a98:	c925                	beqz	a0,80004b08 <pipealloc+0xa4>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a9a:	ffffc097          	auipc	ra,0xffffc
    80004a9e:	ede080e7          	jalr	-290(ra) # 80000978 <kalloc>
    80004aa2:	892a                	mv	s2,a0
    80004aa4:	cd39                	beqz	a0,80004b02 <pipealloc+0x9e>
    goto bad;
  pi->readopen = 1;
    80004aa6:	4985                	li	s3,1
    80004aa8:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004aac:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004ab0:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004ab4:	22052023          	sw	zero,544(a0)
  memset(&pi->lock, 0, sizeof(pi->lock));
    80004ab8:	02000613          	li	a2,32
    80004abc:	4581                	li	a1,0
    80004abe:	ffffc097          	auipc	ra,0xffffc
    80004ac2:	2bc080e7          	jalr	700(ra) # 80000d7a <memset>
  (*f0)->type = FD_PIPE;
    80004ac6:	609c                	ld	a5,0(s1)
    80004ac8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004acc:	609c                	ld	a5,0(s1)
    80004ace:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ad2:	609c                	ld	a5,0(s1)
    80004ad4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ad8:	609c                	ld	a5,0(s1)
    80004ada:	0127bc23          	sd	s2,24(a5)
  (*f1)->type = FD_PIPE;
    80004ade:	000a3783          	ld	a5,0(s4)
    80004ae2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ae6:	000a3783          	ld	a5,0(s4)
    80004aea:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004aee:	000a3783          	ld	a5,0(s4)
    80004af2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004af6:	000a3783          	ld	a5,0(s4)
    80004afa:	0127bc23          	sd	s2,24(a5)
  return 0;
    80004afe:	4501                	li	a0,0
    80004b00:	a025                	j	80004b28 <pipealloc+0xc4>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b02:	6088                	ld	a0,0(s1)
    80004b04:	e501                	bnez	a0,80004b0c <pipealloc+0xa8>
    80004b06:	a039                	j	80004b14 <pipealloc+0xb0>
    80004b08:	6088                	ld	a0,0(s1)
    80004b0a:	c51d                	beqz	a0,80004b38 <pipealloc+0xd4>
    fileclose(*f0);
    80004b0c:	00000097          	auipc	ra,0x0
    80004b10:	bb2080e7          	jalr	-1102(ra) # 800046be <fileclose>
  if(*f1)
    80004b14:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b18:	557d                	li	a0,-1
  if(*f1)
    80004b1a:	c799                	beqz	a5,80004b28 <pipealloc+0xc4>
    fileclose(*f1);
    80004b1c:	853e                	mv	a0,a5
    80004b1e:	00000097          	auipc	ra,0x0
    80004b22:	ba0080e7          	jalr	-1120(ra) # 800046be <fileclose>
  return -1;
    80004b26:	557d                	li	a0,-1
}
    80004b28:	70a2                	ld	ra,40(sp)
    80004b2a:	7402                	ld	s0,32(sp)
    80004b2c:	64e2                	ld	s1,24(sp)
    80004b2e:	6942                	ld	s2,16(sp)
    80004b30:	69a2                	ld	s3,8(sp)
    80004b32:	6a02                	ld	s4,0(sp)
    80004b34:	6145                	addi	sp,sp,48
    80004b36:	8082                	ret
  return -1;
    80004b38:	557d                	li	a0,-1
    80004b3a:	b7fd                	j	80004b28 <pipealloc+0xc4>

0000000080004b3c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b3c:	1101                	addi	sp,sp,-32
    80004b3e:	ec06                	sd	ra,24(sp)
    80004b40:	e822                	sd	s0,16(sp)
    80004b42:	e426                	sd	s1,8(sp)
    80004b44:	e04a                	sd	s2,0(sp)
    80004b46:	1000                	addi	s0,sp,32
    80004b48:	84aa                	mv	s1,a0
    80004b4a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b4c:	ffffc097          	auipc	ra,0xffffc
    80004b50:	f60080e7          	jalr	-160(ra) # 80000aac <acquire>
  if(writable){
    80004b54:	02090d63          	beqz	s2,80004b8e <pipeclose+0x52>
    pi->writeopen = 0;
    80004b58:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004b5c:	22048513          	addi	a0,s1,544
    80004b60:	ffffe097          	auipc	ra,0xffffe
    80004b64:	884080e7          	jalr	-1916(ra) # 800023e4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b68:	2284b783          	ld	a5,552(s1)
    80004b6c:	eb95                	bnez	a5,80004ba0 <pipeclose+0x64>
    release(&pi->lock);
    80004b6e:	8526                	mv	a0,s1
    80004b70:	ffffc097          	auipc	ra,0xffffc
    80004b74:	00c080e7          	jalr	12(ra) # 80000b7c <release>
    kfree((char*)pi);
    80004b78:	8526                	mv	a0,s1
    80004b7a:	ffffc097          	auipc	ra,0xffffc
    80004b7e:	d02080e7          	jalr	-766(ra) # 8000087c <kfree>
  } else
    release(&pi->lock);
}
    80004b82:	60e2                	ld	ra,24(sp)
    80004b84:	6442                	ld	s0,16(sp)
    80004b86:	64a2                	ld	s1,8(sp)
    80004b88:	6902                	ld	s2,0(sp)
    80004b8a:	6105                	addi	sp,sp,32
    80004b8c:	8082                	ret
    pi->readopen = 0;
    80004b8e:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004b92:	22448513          	addi	a0,s1,548
    80004b96:	ffffe097          	auipc	ra,0xffffe
    80004b9a:	84e080e7          	jalr	-1970(ra) # 800023e4 <wakeup>
    80004b9e:	b7e9                	j	80004b68 <pipeclose+0x2c>
    release(&pi->lock);
    80004ba0:	8526                	mv	a0,s1
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	fda080e7          	jalr	-38(ra) # 80000b7c <release>
}
    80004baa:	bfe1                	j	80004b82 <pipeclose+0x46>

0000000080004bac <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004bac:	7159                	addi	sp,sp,-112
    80004bae:	f486                	sd	ra,104(sp)
    80004bb0:	f0a2                	sd	s0,96(sp)
    80004bb2:	eca6                	sd	s1,88(sp)
    80004bb4:	e8ca                	sd	s2,80(sp)
    80004bb6:	e4ce                	sd	s3,72(sp)
    80004bb8:	e0d2                	sd	s4,64(sp)
    80004bba:	fc56                	sd	s5,56(sp)
    80004bbc:	f85a                	sd	s6,48(sp)
    80004bbe:	f45e                	sd	s7,40(sp)
    80004bc0:	f062                	sd	s8,32(sp)
    80004bc2:	ec66                	sd	s9,24(sp)
    80004bc4:	1880                	addi	s0,sp,112
    80004bc6:	84aa                	mv	s1,a0
    80004bc8:	8b2e                	mv	s6,a1
    80004bca:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004bcc:	ffffd097          	auipc	ra,0xffffd
    80004bd0:	ed6080e7          	jalr	-298(ra) # 80001aa2 <myproc>
    80004bd4:	8c2a                	mv	s8,a0

  acquire(&pi->lock);
    80004bd6:	8526                	mv	a0,s1
    80004bd8:	ffffc097          	auipc	ra,0xffffc
    80004bdc:	ed4080e7          	jalr	-300(ra) # 80000aac <acquire>
  for(i = 0; i < n; i++){
    80004be0:	0b505063          	blez	s5,80004c80 <pipewrite+0xd4>
    80004be4:	8926                	mv	s2,s1
    80004be6:	fffa8b9b          	addiw	s7,s5,-1
    80004bea:	1b82                	slli	s7,s7,0x20
    80004bec:	020bdb93          	srli	s7,s7,0x20
    80004bf0:	001b0793          	addi	a5,s6,1
    80004bf4:	9bbe                	add	s7,s7,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004bf6:	22048a13          	addi	s4,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004bfa:	22448993          	addi	s3,s1,548
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004bfe:	5cfd                	li	s9,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c00:	2204a783          	lw	a5,544(s1)
    80004c04:	2244a703          	lw	a4,548(s1)
    80004c08:	2007879b          	addiw	a5,a5,512
    80004c0c:	02f71e63          	bne	a4,a5,80004c48 <pipewrite+0x9c>
      if(pi->readopen == 0 || myproc()->killed){
    80004c10:	2284a783          	lw	a5,552(s1)
    80004c14:	c3d9                	beqz	a5,80004c9a <pipewrite+0xee>
    80004c16:	ffffd097          	auipc	ra,0xffffd
    80004c1a:	e8c080e7          	jalr	-372(ra) # 80001aa2 <myproc>
    80004c1e:	5d1c                	lw	a5,56(a0)
    80004c20:	efad                	bnez	a5,80004c9a <pipewrite+0xee>
      wakeup(&pi->nread);
    80004c22:	8552                	mv	a0,s4
    80004c24:	ffffd097          	auipc	ra,0xffffd
    80004c28:	7c0080e7          	jalr	1984(ra) # 800023e4 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c2c:	85ca                	mv	a1,s2
    80004c2e:	854e                	mv	a0,s3
    80004c30:	ffffd097          	auipc	ra,0xffffd
    80004c34:	62e080e7          	jalr	1582(ra) # 8000225e <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c38:	2204a783          	lw	a5,544(s1)
    80004c3c:	2244a703          	lw	a4,548(s1)
    80004c40:	2007879b          	addiw	a5,a5,512
    80004c44:	fcf706e3          	beq	a4,a5,80004c10 <pipewrite+0x64>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c48:	4685                	li	a3,1
    80004c4a:	865a                	mv	a2,s6
    80004c4c:	f9f40593          	addi	a1,s0,-97
    80004c50:	058c3503          	ld	a0,88(s8)
    80004c54:	ffffd097          	auipc	ra,0xffffd
    80004c58:	bce080e7          	jalr	-1074(ra) # 80001822 <copyin>
    80004c5c:	03950263          	beq	a0,s9,80004c80 <pipewrite+0xd4>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c60:	2244a783          	lw	a5,548(s1)
    80004c64:	0017871b          	addiw	a4,a5,1
    80004c68:	22e4a223          	sw	a4,548(s1)
    80004c6c:	1ff7f793          	andi	a5,a5,511
    80004c70:	97a6                	add	a5,a5,s1
    80004c72:	f9f44703          	lbu	a4,-97(s0)
    80004c76:	02e78023          	sb	a4,32(a5)
  for(i = 0; i < n; i++){
    80004c7a:	0b05                	addi	s6,s6,1
    80004c7c:	f97b12e3          	bne	s6,s7,80004c00 <pipewrite+0x54>
  }
  wakeup(&pi->nread);
    80004c80:	22048513          	addi	a0,s1,544
    80004c84:	ffffd097          	auipc	ra,0xffffd
    80004c88:	760080e7          	jalr	1888(ra) # 800023e4 <wakeup>
  release(&pi->lock);
    80004c8c:	8526                	mv	a0,s1
    80004c8e:	ffffc097          	auipc	ra,0xffffc
    80004c92:	eee080e7          	jalr	-274(ra) # 80000b7c <release>
  return n;
    80004c96:	8556                	mv	a0,s5
    80004c98:	a039                	j	80004ca6 <pipewrite+0xfa>
        release(&pi->lock);
    80004c9a:	8526                	mv	a0,s1
    80004c9c:	ffffc097          	auipc	ra,0xffffc
    80004ca0:	ee0080e7          	jalr	-288(ra) # 80000b7c <release>
        return -1;
    80004ca4:	557d                	li	a0,-1
}
    80004ca6:	70a6                	ld	ra,104(sp)
    80004ca8:	7406                	ld	s0,96(sp)
    80004caa:	64e6                	ld	s1,88(sp)
    80004cac:	6946                	ld	s2,80(sp)
    80004cae:	69a6                	ld	s3,72(sp)
    80004cb0:	6a06                	ld	s4,64(sp)
    80004cb2:	7ae2                	ld	s5,56(sp)
    80004cb4:	7b42                	ld	s6,48(sp)
    80004cb6:	7ba2                	ld	s7,40(sp)
    80004cb8:	7c02                	ld	s8,32(sp)
    80004cba:	6ce2                	ld	s9,24(sp)
    80004cbc:	6165                	addi	sp,sp,112
    80004cbe:	8082                	ret

0000000080004cc0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004cc0:	715d                	addi	sp,sp,-80
    80004cc2:	e486                	sd	ra,72(sp)
    80004cc4:	e0a2                	sd	s0,64(sp)
    80004cc6:	fc26                	sd	s1,56(sp)
    80004cc8:	f84a                	sd	s2,48(sp)
    80004cca:	f44e                	sd	s3,40(sp)
    80004ccc:	f052                	sd	s4,32(sp)
    80004cce:	ec56                	sd	s5,24(sp)
    80004cd0:	e85a                	sd	s6,16(sp)
    80004cd2:	0880                	addi	s0,sp,80
    80004cd4:	84aa                	mv	s1,a0
    80004cd6:	892e                	mv	s2,a1
    80004cd8:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80004cda:	ffffd097          	auipc	ra,0xffffd
    80004cde:	dc8080e7          	jalr	-568(ra) # 80001aa2 <myproc>
    80004ce2:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    80004ce4:	8b26                	mv	s6,s1
    80004ce6:	8526                	mv	a0,s1
    80004ce8:	ffffc097          	auipc	ra,0xffffc
    80004cec:	dc4080e7          	jalr	-572(ra) # 80000aac <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cf0:	2204a703          	lw	a4,544(s1)
    80004cf4:	2244a783          	lw	a5,548(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cf8:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cfc:	02f71763          	bne	a4,a5,80004d2a <piperead+0x6a>
    80004d00:	22c4a783          	lw	a5,556(s1)
    80004d04:	c39d                	beqz	a5,80004d2a <piperead+0x6a>
    if(myproc()->killed){
    80004d06:	ffffd097          	auipc	ra,0xffffd
    80004d0a:	d9c080e7          	jalr	-612(ra) # 80001aa2 <myproc>
    80004d0e:	5d1c                	lw	a5,56(a0)
    80004d10:	ebc1                	bnez	a5,80004da0 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d12:	85da                	mv	a1,s6
    80004d14:	854e                	mv	a0,s3
    80004d16:	ffffd097          	auipc	ra,0xffffd
    80004d1a:	548080e7          	jalr	1352(ra) # 8000225e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d1e:	2204a703          	lw	a4,544(s1)
    80004d22:	2244a783          	lw	a5,548(s1)
    80004d26:	fcf70de3          	beq	a4,a5,80004d00 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d2a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d2c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d2e:	05405363          	blez	s4,80004d74 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004d32:	2204a783          	lw	a5,544(s1)
    80004d36:	2244a703          	lw	a4,548(s1)
    80004d3a:	02f70d63          	beq	a4,a5,80004d74 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d3e:	0017871b          	addiw	a4,a5,1
    80004d42:	22e4a023          	sw	a4,544(s1)
    80004d46:	1ff7f793          	andi	a5,a5,511
    80004d4a:	97a6                	add	a5,a5,s1
    80004d4c:	0207c783          	lbu	a5,32(a5)
    80004d50:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d54:	4685                	li	a3,1
    80004d56:	fbf40613          	addi	a2,s0,-65
    80004d5a:	85ca                	mv	a1,s2
    80004d5c:	058ab503          	ld	a0,88(s5)
    80004d60:	ffffd097          	auipc	ra,0xffffd
    80004d64:	a36080e7          	jalr	-1482(ra) # 80001796 <copyout>
    80004d68:	01650663          	beq	a0,s6,80004d74 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d6c:	2985                	addiw	s3,s3,1
    80004d6e:	0905                	addi	s2,s2,1
    80004d70:	fd3a11e3          	bne	s4,s3,80004d32 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d74:	22448513          	addi	a0,s1,548
    80004d78:	ffffd097          	auipc	ra,0xffffd
    80004d7c:	66c080e7          	jalr	1644(ra) # 800023e4 <wakeup>
  release(&pi->lock);
    80004d80:	8526                	mv	a0,s1
    80004d82:	ffffc097          	auipc	ra,0xffffc
    80004d86:	dfa080e7          	jalr	-518(ra) # 80000b7c <release>
  return i;
}
    80004d8a:	854e                	mv	a0,s3
    80004d8c:	60a6                	ld	ra,72(sp)
    80004d8e:	6406                	ld	s0,64(sp)
    80004d90:	74e2                	ld	s1,56(sp)
    80004d92:	7942                	ld	s2,48(sp)
    80004d94:	79a2                	ld	s3,40(sp)
    80004d96:	7a02                	ld	s4,32(sp)
    80004d98:	6ae2                	ld	s5,24(sp)
    80004d9a:	6b42                	ld	s6,16(sp)
    80004d9c:	6161                	addi	sp,sp,80
    80004d9e:	8082                	ret
      release(&pi->lock);
    80004da0:	8526                	mv	a0,s1
    80004da2:	ffffc097          	auipc	ra,0xffffc
    80004da6:	dda080e7          	jalr	-550(ra) # 80000b7c <release>
      return -1;
    80004daa:	59fd                	li	s3,-1
    80004dac:	bff9                	j	80004d8a <piperead+0xca>

0000000080004dae <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004dae:	df010113          	addi	sp,sp,-528
    80004db2:	20113423          	sd	ra,520(sp)
    80004db6:	20813023          	sd	s0,512(sp)
    80004dba:	ffa6                	sd	s1,504(sp)
    80004dbc:	fbca                	sd	s2,496(sp)
    80004dbe:	f7ce                	sd	s3,488(sp)
    80004dc0:	f3d2                	sd	s4,480(sp)
    80004dc2:	efd6                	sd	s5,472(sp)
    80004dc4:	ebda                	sd	s6,464(sp)
    80004dc6:	e7de                	sd	s7,456(sp)
    80004dc8:	e3e2                	sd	s8,448(sp)
    80004dca:	ff66                	sd	s9,440(sp)
    80004dcc:	fb6a                	sd	s10,432(sp)
    80004dce:	f76e                	sd	s11,424(sp)
    80004dd0:	0c00                	addi	s0,sp,528
    80004dd2:	84aa                	mv	s1,a0
    80004dd4:	dea43c23          	sd	a0,-520(s0)
    80004dd8:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ddc:	ffffd097          	auipc	ra,0xffffd
    80004de0:	cc6080e7          	jalr	-826(ra) # 80001aa2 <myproc>
    80004de4:	892a                	mv	s2,a0

  begin_op(ROOTDEV);
    80004de6:	4501                	li	a0,0
    80004de8:	fffff097          	auipc	ra,0xfffff
    80004dec:	33c080e7          	jalr	828(ra) # 80004124 <begin_op>

  if((ip = namei(path)) == 0){
    80004df0:	8526                	mv	a0,s1
    80004df2:	fffff097          	auipc	ra,0xfffff
    80004df6:	0d8080e7          	jalr	216(ra) # 80003eca <namei>
    80004dfa:	c935                	beqz	a0,80004e6e <exec+0xc0>
    80004dfc:	84aa                	mv	s1,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80004dfe:	fffff097          	auipc	ra,0xfffff
    80004e02:	942080e7          	jalr	-1726(ra) # 80003740 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e06:	04000713          	li	a4,64
    80004e0a:	4681                	li	a3,0
    80004e0c:	e4840613          	addi	a2,s0,-440
    80004e10:	4581                	li	a1,0
    80004e12:	8526                	mv	a0,s1
    80004e14:	fffff097          	auipc	ra,0xfffff
    80004e18:	bbc080e7          	jalr	-1092(ra) # 800039d0 <readi>
    80004e1c:	04000793          	li	a5,64
    80004e20:	00f51a63          	bne	a0,a5,80004e34 <exec+0x86>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e24:	e4842703          	lw	a4,-440(s0)
    80004e28:	464c47b7          	lui	a5,0x464c4
    80004e2c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e30:	04f70663          	beq	a4,a5,80004e7c <exec+0xce>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e34:	8526                	mv	a0,s1
    80004e36:	fffff097          	auipc	ra,0xfffff
    80004e3a:	b48080e7          	jalr	-1208(ra) # 8000397e <iunlockput>
    end_op(ROOTDEV);
    80004e3e:	4501                	li	a0,0
    80004e40:	fffff097          	auipc	ra,0xfffff
    80004e44:	38e080e7          	jalr	910(ra) # 800041ce <end_op>
  }
  return -1;
    80004e48:	557d                	li	a0,-1
}
    80004e4a:	20813083          	ld	ra,520(sp)
    80004e4e:	20013403          	ld	s0,512(sp)
    80004e52:	74fe                	ld	s1,504(sp)
    80004e54:	795e                	ld	s2,496(sp)
    80004e56:	79be                	ld	s3,488(sp)
    80004e58:	7a1e                	ld	s4,480(sp)
    80004e5a:	6afe                	ld	s5,472(sp)
    80004e5c:	6b5e                	ld	s6,464(sp)
    80004e5e:	6bbe                	ld	s7,456(sp)
    80004e60:	6c1e                	ld	s8,448(sp)
    80004e62:	7cfa                	ld	s9,440(sp)
    80004e64:	7d5a                	ld	s10,432(sp)
    80004e66:	7dba                	ld	s11,424(sp)
    80004e68:	21010113          	addi	sp,sp,528
    80004e6c:	8082                	ret
    end_op(ROOTDEV);
    80004e6e:	4501                	li	a0,0
    80004e70:	fffff097          	auipc	ra,0xfffff
    80004e74:	35e080e7          	jalr	862(ra) # 800041ce <end_op>
    return -1;
    80004e78:	557d                	li	a0,-1
    80004e7a:	bfc1                	j	80004e4a <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e7c:	854a                	mv	a0,s2
    80004e7e:	ffffd097          	auipc	ra,0xffffd
    80004e82:	ce8080e7          	jalr	-792(ra) # 80001b66 <proc_pagetable>
    80004e86:	8c2a                	mv	s8,a0
    80004e88:	d555                	beqz	a0,80004e34 <exec+0x86>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e8a:	e6842983          	lw	s3,-408(s0)
    80004e8e:	e8045783          	lhu	a5,-384(s0)
    80004e92:	c7fd                	beqz	a5,80004f80 <exec+0x1d2>
  sz = 0;
    80004e94:	e0043423          	sd	zero,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e98:	4b81                	li	s7,0
    if(ph.vaddr % PGSIZE != 0)
    80004e9a:	6b05                	lui	s6,0x1
    80004e9c:	fffb0793          	addi	a5,s6,-1 # fff <_entry-0x7ffff001>
    80004ea0:	def43823          	sd	a5,-528(s0)
    80004ea4:	a0a5                	j	80004f0c <exec+0x15e>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004ea6:	00005517          	auipc	a0,0x5
    80004eaa:	bb250513          	addi	a0,a0,-1102 # 80009a58 <userret+0x9c8>
    80004eae:	ffffb097          	auipc	ra,0xffffb
    80004eb2:	6ac080e7          	jalr	1708(ra) # 8000055a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004eb6:	8756                	mv	a4,s5
    80004eb8:	012d86bb          	addw	a3,s11,s2
    80004ebc:	4581                	li	a1,0
    80004ebe:	8526                	mv	a0,s1
    80004ec0:	fffff097          	auipc	ra,0xfffff
    80004ec4:	b10080e7          	jalr	-1264(ra) # 800039d0 <readi>
    80004ec8:	2501                	sext.w	a0,a0
    80004eca:	10aa9263          	bne	s5,a0,80004fce <exec+0x220>
  for(i = 0; i < sz; i += PGSIZE){
    80004ece:	6785                	lui	a5,0x1
    80004ed0:	0127893b          	addw	s2,a5,s2
    80004ed4:	77fd                	lui	a5,0xfffff
    80004ed6:	01478a3b          	addw	s4,a5,s4
    80004eda:	03997263          	bgeu	s2,s9,80004efe <exec+0x150>
    pa = walkaddr(pagetable, va + i);
    80004ede:	02091593          	slli	a1,s2,0x20
    80004ee2:	9181                	srli	a1,a1,0x20
    80004ee4:	95ea                	add	a1,a1,s10
    80004ee6:	8562                	mv	a0,s8
    80004ee8:	ffffc097          	auipc	ra,0xffffc
    80004eec:	2a0080e7          	jalr	672(ra) # 80001188 <walkaddr>
    80004ef0:	862a                	mv	a2,a0
    if(pa == 0)
    80004ef2:	d955                	beqz	a0,80004ea6 <exec+0xf8>
      n = PGSIZE;
    80004ef4:	8ada                	mv	s5,s6
    if(sz - i < PGSIZE)
    80004ef6:	fd6a70e3          	bgeu	s4,s6,80004eb6 <exec+0x108>
      n = sz - i;
    80004efa:	8ad2                	mv	s5,s4
    80004efc:	bf6d                	j	80004eb6 <exec+0x108>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004efe:	2b85                	addiw	s7,s7,1
    80004f00:	0389899b          	addiw	s3,s3,56
    80004f04:	e8045783          	lhu	a5,-384(s0)
    80004f08:	06fbde63          	bge	s7,a5,80004f84 <exec+0x1d6>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f0c:	2981                	sext.w	s3,s3
    80004f0e:	03800713          	li	a4,56
    80004f12:	86ce                	mv	a3,s3
    80004f14:	e1040613          	addi	a2,s0,-496
    80004f18:	4581                	li	a1,0
    80004f1a:	8526                	mv	a0,s1
    80004f1c:	fffff097          	auipc	ra,0xfffff
    80004f20:	ab4080e7          	jalr	-1356(ra) # 800039d0 <readi>
    80004f24:	03800793          	li	a5,56
    80004f28:	0af51363          	bne	a0,a5,80004fce <exec+0x220>
    if(ph.type != ELF_PROG_LOAD)
    80004f2c:	e1042783          	lw	a5,-496(s0)
    80004f30:	4705                	li	a4,1
    80004f32:	fce796e3          	bne	a5,a4,80004efe <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004f36:	e3843603          	ld	a2,-456(s0)
    80004f3a:	e3043783          	ld	a5,-464(s0)
    80004f3e:	08f66863          	bltu	a2,a5,80004fce <exec+0x220>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f42:	e2043783          	ld	a5,-480(s0)
    80004f46:	963e                	add	a2,a2,a5
    80004f48:	08f66363          	bltu	a2,a5,80004fce <exec+0x220>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f4c:	e0843583          	ld	a1,-504(s0)
    80004f50:	8562                	mv	a0,s8
    80004f52:	ffffc097          	auipc	ra,0xffffc
    80004f56:	66a080e7          	jalr	1642(ra) # 800015bc <uvmalloc>
    80004f5a:	e0a43423          	sd	a0,-504(s0)
    80004f5e:	c925                	beqz	a0,80004fce <exec+0x220>
    if(ph.vaddr % PGSIZE != 0)
    80004f60:	e2043d03          	ld	s10,-480(s0)
    80004f64:	df043783          	ld	a5,-528(s0)
    80004f68:	00fd77b3          	and	a5,s10,a5
    80004f6c:	e3ad                	bnez	a5,80004fce <exec+0x220>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f6e:	e1842d83          	lw	s11,-488(s0)
    80004f72:	e3042c83          	lw	s9,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f76:	f80c84e3          	beqz	s9,80004efe <exec+0x150>
    80004f7a:	8a66                	mv	s4,s9
    80004f7c:	4901                	li	s2,0
    80004f7e:	b785                	j	80004ede <exec+0x130>
  sz = 0;
    80004f80:	e0043423          	sd	zero,-504(s0)
  iunlockput(ip);
    80004f84:	8526                	mv	a0,s1
    80004f86:	fffff097          	auipc	ra,0xfffff
    80004f8a:	9f8080e7          	jalr	-1544(ra) # 8000397e <iunlockput>
  end_op(ROOTDEV);
    80004f8e:	4501                	li	a0,0
    80004f90:	fffff097          	auipc	ra,0xfffff
    80004f94:	23e080e7          	jalr	574(ra) # 800041ce <end_op>
  p = myproc();
    80004f98:	ffffd097          	auipc	ra,0xffffd
    80004f9c:	b0a080e7          	jalr	-1270(ra) # 80001aa2 <myproc>
    80004fa0:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004fa2:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80004fa6:	6585                	lui	a1,0x1
    80004fa8:	15fd                	addi	a1,a1,-1
    80004faa:	e0843783          	ld	a5,-504(s0)
    80004fae:	00b78b33          	add	s6,a5,a1
    80004fb2:	75fd                	lui	a1,0xfffff
    80004fb4:	00bb75b3          	and	a1,s6,a1
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fb8:	6609                	lui	a2,0x2
    80004fba:	962e                	add	a2,a2,a1
    80004fbc:	8562                	mv	a0,s8
    80004fbe:	ffffc097          	auipc	ra,0xffffc
    80004fc2:	5fe080e7          	jalr	1534(ra) # 800015bc <uvmalloc>
    80004fc6:	e0a43423          	sd	a0,-504(s0)
  ip = 0;
    80004fca:	4481                	li	s1,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fcc:	ed01                	bnez	a0,80004fe4 <exec+0x236>
    proc_freepagetable(pagetable, sz);
    80004fce:	e0843583          	ld	a1,-504(s0)
    80004fd2:	8562                	mv	a0,s8
    80004fd4:	ffffd097          	auipc	ra,0xffffd
    80004fd8:	c92080e7          	jalr	-878(ra) # 80001c66 <proc_freepagetable>
  if(ip){
    80004fdc:	e4049ce3          	bnez	s1,80004e34 <exec+0x86>
  return -1;
    80004fe0:	557d                	li	a0,-1
    80004fe2:	b5a5                	j	80004e4a <exec+0x9c>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fe4:	75f9                	lui	a1,0xffffe
    80004fe6:	84aa                	mv	s1,a0
    80004fe8:	95aa                	add	a1,a1,a0
    80004fea:	8562                	mv	a0,s8
    80004fec:	ffffc097          	auipc	ra,0xffffc
    80004ff0:	778080e7          	jalr	1912(ra) # 80001764 <uvmclear>
  stackbase = sp - PGSIZE;
    80004ff4:	7afd                	lui	s5,0xfffff
    80004ff6:	9aa6                	add	s5,s5,s1
  for(argc = 0; argv[argc]; argc++) {
    80004ff8:	e0043783          	ld	a5,-512(s0)
    80004ffc:	6388                	ld	a0,0(a5)
    80004ffe:	c135                	beqz	a0,80005062 <exec+0x2b4>
    80005000:	e8840993          	addi	s3,s0,-376
    80005004:	f8840c93          	addi	s9,s0,-120
    80005008:	4901                	li	s2,0
    sp -= strlen(argv[argc]) + 1;
    8000500a:	ffffc097          	auipc	ra,0xffffc
    8000500e:	ef8080e7          	jalr	-264(ra) # 80000f02 <strlen>
    80005012:	2505                	addiw	a0,a0,1
    80005014:	8c89                	sub	s1,s1,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005016:	98c1                	andi	s1,s1,-16
    if(sp < stackbase)
    80005018:	0f54ea63          	bltu	s1,s5,8000510c <exec+0x35e>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000501c:	e0043b03          	ld	s6,-512(s0)
    80005020:	000b3a03          	ld	s4,0(s6)
    80005024:	8552                	mv	a0,s4
    80005026:	ffffc097          	auipc	ra,0xffffc
    8000502a:	edc080e7          	jalr	-292(ra) # 80000f02 <strlen>
    8000502e:	0015069b          	addiw	a3,a0,1
    80005032:	8652                	mv	a2,s4
    80005034:	85a6                	mv	a1,s1
    80005036:	8562                	mv	a0,s8
    80005038:	ffffc097          	auipc	ra,0xffffc
    8000503c:	75e080e7          	jalr	1886(ra) # 80001796 <copyout>
    80005040:	0c054863          	bltz	a0,80005110 <exec+0x362>
    ustack[argc] = sp;
    80005044:	0099b023          	sd	s1,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005048:	0905                	addi	s2,s2,1
    8000504a:	008b0793          	addi	a5,s6,8
    8000504e:	e0f43023          	sd	a5,-512(s0)
    80005052:	008b3503          	ld	a0,8(s6)
    80005056:	c909                	beqz	a0,80005068 <exec+0x2ba>
    if(argc >= MAXARG)
    80005058:	09a1                	addi	s3,s3,8
    8000505a:	fb3c98e3          	bne	s9,s3,8000500a <exec+0x25c>
  ip = 0;
    8000505e:	4481                	li	s1,0
    80005060:	b7bd                	j	80004fce <exec+0x220>
  sp = sz;
    80005062:	e0843483          	ld	s1,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005066:	4901                	li	s2,0
  ustack[argc] = 0;
    80005068:	00391793          	slli	a5,s2,0x3
    8000506c:	f9040713          	addi	a4,s0,-112
    80005070:	97ba                	add	a5,a5,a4
    80005072:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd5b2c>
  sp -= (argc+1) * sizeof(uint64);
    80005076:	00190693          	addi	a3,s2,1
    8000507a:	068e                	slli	a3,a3,0x3
    8000507c:	8c95                	sub	s1,s1,a3
  sp -= sp % 16;
    8000507e:	ff04f993          	andi	s3,s1,-16
  ip = 0;
    80005082:	4481                	li	s1,0
  if(sp < stackbase)
    80005084:	f559e5e3          	bltu	s3,s5,80004fce <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005088:	e8840613          	addi	a2,s0,-376
    8000508c:	85ce                	mv	a1,s3
    8000508e:	8562                	mv	a0,s8
    80005090:	ffffc097          	auipc	ra,0xffffc
    80005094:	706080e7          	jalr	1798(ra) # 80001796 <copyout>
    80005098:	06054e63          	bltz	a0,80005114 <exec+0x366>
  p->tf->a1 = sp;
    8000509c:	060bb783          	ld	a5,96(s7) # 1060 <_entry-0x7fffefa0>
    800050a0:	0737bc23          	sd	s3,120(a5)
  for(last=s=path; *s; s++)
    800050a4:	df843783          	ld	a5,-520(s0)
    800050a8:	0007c703          	lbu	a4,0(a5)
    800050ac:	cf11                	beqz	a4,800050c8 <exec+0x31a>
    800050ae:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050b0:	02f00693          	li	a3,47
    800050b4:	a029                	j	800050be <exec+0x310>
  for(last=s=path; *s; s++)
    800050b6:	0785                	addi	a5,a5,1
    800050b8:	fff7c703          	lbu	a4,-1(a5)
    800050bc:	c711                	beqz	a4,800050c8 <exec+0x31a>
    if(*s == '/')
    800050be:	fed71ce3          	bne	a4,a3,800050b6 <exec+0x308>
      last = s+1;
    800050c2:	def43c23          	sd	a5,-520(s0)
    800050c6:	bfc5                	j	800050b6 <exec+0x308>
  safestrcpy(p->name, last, sizeof(p->name));
    800050c8:	4641                	li	a2,16
    800050ca:	df843583          	ld	a1,-520(s0)
    800050ce:	160b8513          	addi	a0,s7,352
    800050d2:	ffffc097          	auipc	ra,0xffffc
    800050d6:	dfe080e7          	jalr	-514(ra) # 80000ed0 <safestrcpy>
  oldpagetable = p->pagetable;
    800050da:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    800050de:	058bbc23          	sd	s8,88(s7)
  p->sz = sz;
    800050e2:	e0843783          	ld	a5,-504(s0)
    800050e6:	04fbb823          	sd	a5,80(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    800050ea:	060bb783          	ld	a5,96(s7)
    800050ee:	e6043703          	ld	a4,-416(s0)
    800050f2:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    800050f4:	060bb783          	ld	a5,96(s7)
    800050f8:	0337b823          	sd	s3,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050fc:	85ea                	mv	a1,s10
    800050fe:	ffffd097          	auipc	ra,0xffffd
    80005102:	b68080e7          	jalr	-1176(ra) # 80001c66 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005106:	0009051b          	sext.w	a0,s2
    8000510a:	b381                	j	80004e4a <exec+0x9c>
  ip = 0;
    8000510c:	4481                	li	s1,0
    8000510e:	b5c1                	j	80004fce <exec+0x220>
    80005110:	4481                	li	s1,0
    80005112:	bd75                	j	80004fce <exec+0x220>
    80005114:	4481                	li	s1,0
    80005116:	bd65                	j	80004fce <exec+0x220>

0000000080005118 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005118:	1101                	addi	sp,sp,-32
    8000511a:	ec06                	sd	ra,24(sp)
    8000511c:	e822                	sd	s0,16(sp)
    8000511e:	e426                	sd	s1,8(sp)
    80005120:	1000                	addi	s0,sp,32
    80005122:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005124:	ffffd097          	auipc	ra,0xffffd
    80005128:	97e080e7          	jalr	-1666(ra) # 80001aa2 <myproc>
    8000512c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000512e:	0d850793          	addi	a5,a0,216
    80005132:	4501                	li	a0,0
    80005134:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005136:	6398                	ld	a4,0(a5)
    80005138:	cb19                	beqz	a4,8000514e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000513a:	2505                	addiw	a0,a0,1
    8000513c:	07a1                	addi	a5,a5,8
    8000513e:	fed51ce3          	bne	a0,a3,80005136 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005142:	557d                	li	a0,-1
}
    80005144:	60e2                	ld	ra,24(sp)
    80005146:	6442                	ld	s0,16(sp)
    80005148:	64a2                	ld	s1,8(sp)
    8000514a:	6105                	addi	sp,sp,32
    8000514c:	8082                	ret
      p->ofile[fd] = f;
    8000514e:	01a50793          	addi	a5,a0,26
    80005152:	078e                	slli	a5,a5,0x3
    80005154:	963e                	add	a2,a2,a5
    80005156:	e604                	sd	s1,8(a2)
      return fd;
    80005158:	b7f5                	j	80005144 <fdalloc+0x2c>

000000008000515a <argfd>:
{
    8000515a:	7179                	addi	sp,sp,-48
    8000515c:	f406                	sd	ra,40(sp)
    8000515e:	f022                	sd	s0,32(sp)
    80005160:	ec26                	sd	s1,24(sp)
    80005162:	e84a                	sd	s2,16(sp)
    80005164:	1800                	addi	s0,sp,48
    80005166:	892e                	mv	s2,a1
    80005168:	84b2                	mv	s1,a2
  if(argint(n, &fd) < 0)
    8000516a:	fdc40593          	addi	a1,s0,-36
    8000516e:	ffffe097          	auipc	ra,0xffffe
    80005172:	a5c080e7          	jalr	-1444(ra) # 80002bca <argint>
    80005176:	04054063          	bltz	a0,800051b6 <argfd+0x5c>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000517a:	fdc42703          	lw	a4,-36(s0)
    8000517e:	47bd                	li	a5,15
    80005180:	02e7ed63          	bltu	a5,a4,800051ba <argfd+0x60>
    80005184:	ffffd097          	auipc	ra,0xffffd
    80005188:	91e080e7          	jalr	-1762(ra) # 80001aa2 <myproc>
    8000518c:	fdc42703          	lw	a4,-36(s0)
    80005190:	01a70793          	addi	a5,a4,26
    80005194:	078e                	slli	a5,a5,0x3
    80005196:	953e                	add	a0,a0,a5
    80005198:	651c                	ld	a5,8(a0)
    8000519a:	c395                	beqz	a5,800051be <argfd+0x64>
  if(pfd)
    8000519c:	00090463          	beqz	s2,800051a4 <argfd+0x4a>
    *pfd = fd;
    800051a0:	00e92023          	sw	a4,0(s2)
  return 0;
    800051a4:	4501                	li	a0,0
  if(pf)
    800051a6:	c091                	beqz	s1,800051aa <argfd+0x50>
    *pf = f;
    800051a8:	e09c                	sd	a5,0(s1)
}
    800051aa:	70a2                	ld	ra,40(sp)
    800051ac:	7402                	ld	s0,32(sp)
    800051ae:	64e2                	ld	s1,24(sp)
    800051b0:	6942                	ld	s2,16(sp)
    800051b2:	6145                	addi	sp,sp,48
    800051b4:	8082                	ret
    return -1;
    800051b6:	557d                	li	a0,-1
    800051b8:	bfcd                	j	800051aa <argfd+0x50>
    return -1;
    800051ba:	557d                	li	a0,-1
    800051bc:	b7fd                	j	800051aa <argfd+0x50>
    800051be:	557d                	li	a0,-1
    800051c0:	b7ed                	j	800051aa <argfd+0x50>

00000000800051c2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800051c2:	715d                	addi	sp,sp,-80
    800051c4:	e486                	sd	ra,72(sp)
    800051c6:	e0a2                	sd	s0,64(sp)
    800051c8:	fc26                	sd	s1,56(sp)
    800051ca:	f84a                	sd	s2,48(sp)
    800051cc:	f44e                	sd	s3,40(sp)
    800051ce:	f052                	sd	s4,32(sp)
    800051d0:	ec56                	sd	s5,24(sp)
    800051d2:	0880                	addi	s0,sp,80
    800051d4:	89ae                	mv	s3,a1
    800051d6:	8ab2                	mv	s5,a2
    800051d8:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800051da:	fb040593          	addi	a1,s0,-80
    800051de:	fffff097          	auipc	ra,0xfffff
    800051e2:	d0a080e7          	jalr	-758(ra) # 80003ee8 <nameiparent>
    800051e6:	892a                	mv	s2,a0
    800051e8:	12050e63          	beqz	a0,80005324 <create+0x162>
    return 0;

  ilock(dp);
    800051ec:	ffffe097          	auipc	ra,0xffffe
    800051f0:	554080e7          	jalr	1364(ra) # 80003740 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800051f4:	4601                	li	a2,0
    800051f6:	fb040593          	addi	a1,s0,-80
    800051fa:	854a                	mv	a0,s2
    800051fc:	fffff097          	auipc	ra,0xfffff
    80005200:	9fc080e7          	jalr	-1540(ra) # 80003bf8 <dirlookup>
    80005204:	84aa                	mv	s1,a0
    80005206:	c921                	beqz	a0,80005256 <create+0x94>
    iunlockput(dp);
    80005208:	854a                	mv	a0,s2
    8000520a:	ffffe097          	auipc	ra,0xffffe
    8000520e:	774080e7          	jalr	1908(ra) # 8000397e <iunlockput>
    ilock(ip);
    80005212:	8526                	mv	a0,s1
    80005214:	ffffe097          	auipc	ra,0xffffe
    80005218:	52c080e7          	jalr	1324(ra) # 80003740 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000521c:	2981                	sext.w	s3,s3
    8000521e:	4789                	li	a5,2
    80005220:	02f99463          	bne	s3,a5,80005248 <create+0x86>
    80005224:	04c4d783          	lhu	a5,76(s1)
    80005228:	37f9                	addiw	a5,a5,-2
    8000522a:	17c2                	slli	a5,a5,0x30
    8000522c:	93c1                	srli	a5,a5,0x30
    8000522e:	4705                	li	a4,1
    80005230:	00f76c63          	bltu	a4,a5,80005248 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005234:	8526                	mv	a0,s1
    80005236:	60a6                	ld	ra,72(sp)
    80005238:	6406                	ld	s0,64(sp)
    8000523a:	74e2                	ld	s1,56(sp)
    8000523c:	7942                	ld	s2,48(sp)
    8000523e:	79a2                	ld	s3,40(sp)
    80005240:	7a02                	ld	s4,32(sp)
    80005242:	6ae2                	ld	s5,24(sp)
    80005244:	6161                	addi	sp,sp,80
    80005246:	8082                	ret
    iunlockput(ip);
    80005248:	8526                	mv	a0,s1
    8000524a:	ffffe097          	auipc	ra,0xffffe
    8000524e:	734080e7          	jalr	1844(ra) # 8000397e <iunlockput>
    return 0;
    80005252:	4481                	li	s1,0
    80005254:	b7c5                	j	80005234 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005256:	85ce                	mv	a1,s3
    80005258:	00092503          	lw	a0,0(s2)
    8000525c:	ffffe097          	auipc	ra,0xffffe
    80005260:	34c080e7          	jalr	844(ra) # 800035a8 <ialloc>
    80005264:	84aa                	mv	s1,a0
    80005266:	c521                	beqz	a0,800052ae <create+0xec>
  ilock(ip);
    80005268:	ffffe097          	auipc	ra,0xffffe
    8000526c:	4d8080e7          	jalr	1240(ra) # 80003740 <ilock>
  ip->major = major;
    80005270:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    80005274:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    80005278:	4a05                	li	s4,1
    8000527a:	05449923          	sh	s4,82(s1)
  iupdate(ip);
    8000527e:	8526                	mv	a0,s1
    80005280:	ffffe097          	auipc	ra,0xffffe
    80005284:	3f6080e7          	jalr	1014(ra) # 80003676 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005288:	2981                	sext.w	s3,s3
    8000528a:	03498a63          	beq	s3,s4,800052be <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000528e:	40d0                	lw	a2,4(s1)
    80005290:	fb040593          	addi	a1,s0,-80
    80005294:	854a                	mv	a0,s2
    80005296:	fffff097          	auipc	ra,0xfffff
    8000529a:	b72080e7          	jalr	-1166(ra) # 80003e08 <dirlink>
    8000529e:	06054b63          	bltz	a0,80005314 <create+0x152>
  iunlockput(dp);
    800052a2:	854a                	mv	a0,s2
    800052a4:	ffffe097          	auipc	ra,0xffffe
    800052a8:	6da080e7          	jalr	1754(ra) # 8000397e <iunlockput>
  return ip;
    800052ac:	b761                	j	80005234 <create+0x72>
    panic("create: ialloc");
    800052ae:	00004517          	auipc	a0,0x4
    800052b2:	7ca50513          	addi	a0,a0,1994 # 80009a78 <userret+0x9e8>
    800052b6:	ffffb097          	auipc	ra,0xffffb
    800052ba:	2a4080e7          	jalr	676(ra) # 8000055a <panic>
    dp->nlink++;  // for ".."
    800052be:	05295783          	lhu	a5,82(s2)
    800052c2:	2785                	addiw	a5,a5,1
    800052c4:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    800052c8:	854a                	mv	a0,s2
    800052ca:	ffffe097          	auipc	ra,0xffffe
    800052ce:	3ac080e7          	jalr	940(ra) # 80003676 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800052d2:	40d0                	lw	a2,4(s1)
    800052d4:	00004597          	auipc	a1,0x4
    800052d8:	7b458593          	addi	a1,a1,1972 # 80009a88 <userret+0x9f8>
    800052dc:	8526                	mv	a0,s1
    800052de:	fffff097          	auipc	ra,0xfffff
    800052e2:	b2a080e7          	jalr	-1238(ra) # 80003e08 <dirlink>
    800052e6:	00054f63          	bltz	a0,80005304 <create+0x142>
    800052ea:	00492603          	lw	a2,4(s2)
    800052ee:	00004597          	auipc	a1,0x4
    800052f2:	7a258593          	addi	a1,a1,1954 # 80009a90 <userret+0xa00>
    800052f6:	8526                	mv	a0,s1
    800052f8:	fffff097          	auipc	ra,0xfffff
    800052fc:	b10080e7          	jalr	-1264(ra) # 80003e08 <dirlink>
    80005300:	f80557e3          	bgez	a0,8000528e <create+0xcc>
      panic("create dots");
    80005304:	00004517          	auipc	a0,0x4
    80005308:	79450513          	addi	a0,a0,1940 # 80009a98 <userret+0xa08>
    8000530c:	ffffb097          	auipc	ra,0xffffb
    80005310:	24e080e7          	jalr	590(ra) # 8000055a <panic>
    panic("create: dirlink");
    80005314:	00004517          	auipc	a0,0x4
    80005318:	79450513          	addi	a0,a0,1940 # 80009aa8 <userret+0xa18>
    8000531c:	ffffb097          	auipc	ra,0xffffb
    80005320:	23e080e7          	jalr	574(ra) # 8000055a <panic>
    return 0;
    80005324:	84aa                	mv	s1,a0
    80005326:	b739                	j	80005234 <create+0x72>

0000000080005328 <sys_connect>:
{
    80005328:	7179                	addi	sp,sp,-48
    8000532a:	f406                	sd	ra,40(sp)
    8000532c:	f022                	sd	s0,32(sp)
    8000532e:	1800                	addi	s0,sp,48
  if (argint(0, (int*)&raddr) < 0 ||
    80005330:	fe440593          	addi	a1,s0,-28
    80005334:	4501                	li	a0,0
    80005336:	ffffe097          	auipc	ra,0xffffe
    8000533a:	894080e7          	jalr	-1900(ra) # 80002bca <argint>
    return -1;
    8000533e:	57fd                	li	a5,-1
  if (argint(0, (int*)&raddr) < 0 ||
    80005340:	04054e63          	bltz	a0,8000539c <sys_connect+0x74>
      argint(1, (int*)&lport) < 0 ||
    80005344:	fdc40593          	addi	a1,s0,-36
    80005348:	4505                	li	a0,1
    8000534a:	ffffe097          	auipc	ra,0xffffe
    8000534e:	880080e7          	jalr	-1920(ra) # 80002bca <argint>
    return -1;
    80005352:	57fd                	li	a5,-1
  if (argint(0, (int*)&raddr) < 0 ||
    80005354:	04054463          	bltz	a0,8000539c <sys_connect+0x74>
      argint(2, (int*)&rport) < 0) {
    80005358:	fe040593          	addi	a1,s0,-32
    8000535c:	4509                	li	a0,2
    8000535e:	ffffe097          	auipc	ra,0xffffe
    80005362:	86c080e7          	jalr	-1940(ra) # 80002bca <argint>
    return -1;
    80005366:	57fd                	li	a5,-1
      argint(1, (int*)&lport) < 0 ||
    80005368:	02054a63          	bltz	a0,8000539c <sys_connect+0x74>
  if(sockalloc(&f, raddr, lport, rport) < 0)
    8000536c:	fe045683          	lhu	a3,-32(s0)
    80005370:	fdc45603          	lhu	a2,-36(s0)
    80005374:	fe442583          	lw	a1,-28(s0)
    80005378:	fe840513          	addi	a0,s0,-24
    8000537c:	00002097          	auipc	ra,0x2
    80005380:	e46080e7          	jalr	-442(ra) # 800071c2 <sockalloc>
    return -1;
    80005384:	57fd                	li	a5,-1
  if(sockalloc(&f, raddr, lport, rport) < 0)
    80005386:	00054b63          	bltz	a0,8000539c <sys_connect+0x74>
  if((fd=fdalloc(f)) < 0){
    8000538a:	fe843503          	ld	a0,-24(s0)
    8000538e:	00000097          	auipc	ra,0x0
    80005392:	d8a080e7          	jalr	-630(ra) # 80005118 <fdalloc>
  return fd;
    80005396:	87aa                	mv	a5,a0
  if((fd=fdalloc(f)) < 0){
    80005398:	00054763          	bltz	a0,800053a6 <sys_connect+0x7e>
}
    8000539c:	853e                	mv	a0,a5
    8000539e:	70a2                	ld	ra,40(sp)
    800053a0:	7402                	ld	s0,32(sp)
    800053a2:	6145                	addi	sp,sp,48
    800053a4:	8082                	ret
    fileclose(f);
    800053a6:	fe843503          	ld	a0,-24(s0)
    800053aa:	fffff097          	auipc	ra,0xfffff
    800053ae:	314080e7          	jalr	788(ra) # 800046be <fileclose>
    return -1;
    800053b2:	57fd                	li	a5,-1
    800053b4:	b7e5                	j	8000539c <sys_connect+0x74>

00000000800053b6 <sys_dup>:
{
    800053b6:	7179                	addi	sp,sp,-48
    800053b8:	f406                	sd	ra,40(sp)
    800053ba:	f022                	sd	s0,32(sp)
    800053bc:	ec26                	sd	s1,24(sp)
    800053be:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053c0:	fd840613          	addi	a2,s0,-40
    800053c4:	4581                	li	a1,0
    800053c6:	4501                	li	a0,0
    800053c8:	00000097          	auipc	ra,0x0
    800053cc:	d92080e7          	jalr	-622(ra) # 8000515a <argfd>
    return -1;
    800053d0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053d2:	02054363          	bltz	a0,800053f8 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053d6:	fd843503          	ld	a0,-40(s0)
    800053da:	00000097          	auipc	ra,0x0
    800053de:	d3e080e7          	jalr	-706(ra) # 80005118 <fdalloc>
    800053e2:	84aa                	mv	s1,a0
    return -1;
    800053e4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053e6:	00054963          	bltz	a0,800053f8 <sys_dup+0x42>
  filedup(f);
    800053ea:	fd843503          	ld	a0,-40(s0)
    800053ee:	fffff097          	auipc	ra,0xfffff
    800053f2:	27e080e7          	jalr	638(ra) # 8000466c <filedup>
  return fd;
    800053f6:	87a6                	mv	a5,s1
}
    800053f8:	853e                	mv	a0,a5
    800053fa:	70a2                	ld	ra,40(sp)
    800053fc:	7402                	ld	s0,32(sp)
    800053fe:	64e2                	ld	s1,24(sp)
    80005400:	6145                	addi	sp,sp,48
    80005402:	8082                	ret

0000000080005404 <sys_read>:
{
    80005404:	7179                	addi	sp,sp,-48
    80005406:	f406                	sd	ra,40(sp)
    80005408:	f022                	sd	s0,32(sp)
    8000540a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000540c:	fe840613          	addi	a2,s0,-24
    80005410:	4581                	li	a1,0
    80005412:	4501                	li	a0,0
    80005414:	00000097          	auipc	ra,0x0
    80005418:	d46080e7          	jalr	-698(ra) # 8000515a <argfd>
    return -1;
    8000541c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000541e:	04054163          	bltz	a0,80005460 <sys_read+0x5c>
    80005422:	fe440593          	addi	a1,s0,-28
    80005426:	4509                	li	a0,2
    80005428:	ffffd097          	auipc	ra,0xffffd
    8000542c:	7a2080e7          	jalr	1954(ra) # 80002bca <argint>
    return -1;
    80005430:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005432:	02054763          	bltz	a0,80005460 <sys_read+0x5c>
    80005436:	fd840593          	addi	a1,s0,-40
    8000543a:	4505                	li	a0,1
    8000543c:	ffffd097          	auipc	ra,0xffffd
    80005440:	7b0080e7          	jalr	1968(ra) # 80002bec <argaddr>
    return -1;
    80005444:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005446:	00054d63          	bltz	a0,80005460 <sys_read+0x5c>
  return fileread(f, p, n);
    8000544a:	fe442603          	lw	a2,-28(s0)
    8000544e:	fd843583          	ld	a1,-40(s0)
    80005452:	fe843503          	ld	a0,-24(s0)
    80005456:	fffff097          	auipc	ra,0xfffff
    8000545a:	3c6080e7          	jalr	966(ra) # 8000481c <fileread>
    8000545e:	87aa                	mv	a5,a0
}
    80005460:	853e                	mv	a0,a5
    80005462:	70a2                	ld	ra,40(sp)
    80005464:	7402                	ld	s0,32(sp)
    80005466:	6145                	addi	sp,sp,48
    80005468:	8082                	ret

000000008000546a <sys_write>:
{
    8000546a:	7179                	addi	sp,sp,-48
    8000546c:	f406                	sd	ra,40(sp)
    8000546e:	f022                	sd	s0,32(sp)
    80005470:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005472:	fe840613          	addi	a2,s0,-24
    80005476:	4581                	li	a1,0
    80005478:	4501                	li	a0,0
    8000547a:	00000097          	auipc	ra,0x0
    8000547e:	ce0080e7          	jalr	-800(ra) # 8000515a <argfd>
    return -1;
    80005482:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005484:	04054163          	bltz	a0,800054c6 <sys_write+0x5c>
    80005488:	fe440593          	addi	a1,s0,-28
    8000548c:	4509                	li	a0,2
    8000548e:	ffffd097          	auipc	ra,0xffffd
    80005492:	73c080e7          	jalr	1852(ra) # 80002bca <argint>
    return -1;
    80005496:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005498:	02054763          	bltz	a0,800054c6 <sys_write+0x5c>
    8000549c:	fd840593          	addi	a1,s0,-40
    800054a0:	4505                	li	a0,1
    800054a2:	ffffd097          	auipc	ra,0xffffd
    800054a6:	74a080e7          	jalr	1866(ra) # 80002bec <argaddr>
    return -1;
    800054aa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054ac:	00054d63          	bltz	a0,800054c6 <sys_write+0x5c>
  return filewrite(f, p, n);
    800054b0:	fe442603          	lw	a2,-28(s0)
    800054b4:	fd843583          	ld	a1,-40(s0)
    800054b8:	fe843503          	ld	a0,-24(s0)
    800054bc:	fffff097          	auipc	ra,0xfffff
    800054c0:	43a080e7          	jalr	1082(ra) # 800048f6 <filewrite>
    800054c4:	87aa                	mv	a5,a0
}
    800054c6:	853e                	mv	a0,a5
    800054c8:	70a2                	ld	ra,40(sp)
    800054ca:	7402                	ld	s0,32(sp)
    800054cc:	6145                	addi	sp,sp,48
    800054ce:	8082                	ret

00000000800054d0 <sys_close>:
{
    800054d0:	1101                	addi	sp,sp,-32
    800054d2:	ec06                	sd	ra,24(sp)
    800054d4:	e822                	sd	s0,16(sp)
    800054d6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054d8:	fe040613          	addi	a2,s0,-32
    800054dc:	fec40593          	addi	a1,s0,-20
    800054e0:	4501                	li	a0,0
    800054e2:	00000097          	auipc	ra,0x0
    800054e6:	c78080e7          	jalr	-904(ra) # 8000515a <argfd>
    return -1;
    800054ea:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054ec:	02054463          	bltz	a0,80005514 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054f0:	ffffc097          	auipc	ra,0xffffc
    800054f4:	5b2080e7          	jalr	1458(ra) # 80001aa2 <myproc>
    800054f8:	fec42783          	lw	a5,-20(s0)
    800054fc:	07e9                	addi	a5,a5,26
    800054fe:	078e                	slli	a5,a5,0x3
    80005500:	97aa                	add	a5,a5,a0
    80005502:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005506:	fe043503          	ld	a0,-32(s0)
    8000550a:	fffff097          	auipc	ra,0xfffff
    8000550e:	1b4080e7          	jalr	436(ra) # 800046be <fileclose>
  return 0;
    80005512:	4781                	li	a5,0
}
    80005514:	853e                	mv	a0,a5
    80005516:	60e2                	ld	ra,24(sp)
    80005518:	6442                	ld	s0,16(sp)
    8000551a:	6105                	addi	sp,sp,32
    8000551c:	8082                	ret

000000008000551e <sys_fstat>:
{
    8000551e:	1101                	addi	sp,sp,-32
    80005520:	ec06                	sd	ra,24(sp)
    80005522:	e822                	sd	s0,16(sp)
    80005524:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005526:	fe840613          	addi	a2,s0,-24
    8000552a:	4581                	li	a1,0
    8000552c:	4501                	li	a0,0
    8000552e:	00000097          	auipc	ra,0x0
    80005532:	c2c080e7          	jalr	-980(ra) # 8000515a <argfd>
    return -1;
    80005536:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005538:	02054563          	bltz	a0,80005562 <sys_fstat+0x44>
    8000553c:	fe040593          	addi	a1,s0,-32
    80005540:	4505                	li	a0,1
    80005542:	ffffd097          	auipc	ra,0xffffd
    80005546:	6aa080e7          	jalr	1706(ra) # 80002bec <argaddr>
    return -1;
    8000554a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000554c:	00054b63          	bltz	a0,80005562 <sys_fstat+0x44>
  return filestat(f, st);
    80005550:	fe043583          	ld	a1,-32(s0)
    80005554:	fe843503          	ld	a0,-24(s0)
    80005558:	fffff097          	auipc	ra,0xfffff
    8000555c:	252080e7          	jalr	594(ra) # 800047aa <filestat>
    80005560:	87aa                	mv	a5,a0
}
    80005562:	853e                	mv	a0,a5
    80005564:	60e2                	ld	ra,24(sp)
    80005566:	6442                	ld	s0,16(sp)
    80005568:	6105                	addi	sp,sp,32
    8000556a:	8082                	ret

000000008000556c <sys_link>:
{
    8000556c:	7169                	addi	sp,sp,-304
    8000556e:	f606                	sd	ra,296(sp)
    80005570:	f222                	sd	s0,288(sp)
    80005572:	ee26                	sd	s1,280(sp)
    80005574:	ea4a                	sd	s2,272(sp)
    80005576:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005578:	08000613          	li	a2,128
    8000557c:	ed040593          	addi	a1,s0,-304
    80005580:	4501                	li	a0,0
    80005582:	ffffd097          	auipc	ra,0xffffd
    80005586:	68c080e7          	jalr	1676(ra) # 80002c0e <argstr>
    return -1;
    8000558a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000558c:	12054363          	bltz	a0,800056b2 <sys_link+0x146>
    80005590:	08000613          	li	a2,128
    80005594:	f5040593          	addi	a1,s0,-176
    80005598:	4505                	li	a0,1
    8000559a:	ffffd097          	auipc	ra,0xffffd
    8000559e:	674080e7          	jalr	1652(ra) # 80002c0e <argstr>
    return -1;
    800055a2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055a4:	10054763          	bltz	a0,800056b2 <sys_link+0x146>
  begin_op(ROOTDEV);
    800055a8:	4501                	li	a0,0
    800055aa:	fffff097          	auipc	ra,0xfffff
    800055ae:	b7a080e7          	jalr	-1158(ra) # 80004124 <begin_op>
  if((ip = namei(old)) == 0){
    800055b2:	ed040513          	addi	a0,s0,-304
    800055b6:	fffff097          	auipc	ra,0xfffff
    800055ba:	914080e7          	jalr	-1772(ra) # 80003eca <namei>
    800055be:	84aa                	mv	s1,a0
    800055c0:	c559                	beqz	a0,8000564e <sys_link+0xe2>
  ilock(ip);
    800055c2:	ffffe097          	auipc	ra,0xffffe
    800055c6:	17e080e7          	jalr	382(ra) # 80003740 <ilock>
  if(ip->type == T_DIR){
    800055ca:	04c49703          	lh	a4,76(s1)
    800055ce:	4785                	li	a5,1
    800055d0:	08f70663          	beq	a4,a5,8000565c <sys_link+0xf0>
  ip->nlink++;
    800055d4:	0524d783          	lhu	a5,82(s1)
    800055d8:	2785                	addiw	a5,a5,1
    800055da:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800055de:	8526                	mv	a0,s1
    800055e0:	ffffe097          	auipc	ra,0xffffe
    800055e4:	096080e7          	jalr	150(ra) # 80003676 <iupdate>
  iunlock(ip);
    800055e8:	8526                	mv	a0,s1
    800055ea:	ffffe097          	auipc	ra,0xffffe
    800055ee:	218080e7          	jalr	536(ra) # 80003802 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055f2:	fd040593          	addi	a1,s0,-48
    800055f6:	f5040513          	addi	a0,s0,-176
    800055fa:	fffff097          	auipc	ra,0xfffff
    800055fe:	8ee080e7          	jalr	-1810(ra) # 80003ee8 <nameiparent>
    80005602:	892a                	mv	s2,a0
    80005604:	cd2d                	beqz	a0,8000567e <sys_link+0x112>
  ilock(dp);
    80005606:	ffffe097          	auipc	ra,0xffffe
    8000560a:	13a080e7          	jalr	314(ra) # 80003740 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000560e:	00092703          	lw	a4,0(s2)
    80005612:	409c                	lw	a5,0(s1)
    80005614:	06f71063          	bne	a4,a5,80005674 <sys_link+0x108>
    80005618:	40d0                	lw	a2,4(s1)
    8000561a:	fd040593          	addi	a1,s0,-48
    8000561e:	854a                	mv	a0,s2
    80005620:	ffffe097          	auipc	ra,0xffffe
    80005624:	7e8080e7          	jalr	2024(ra) # 80003e08 <dirlink>
    80005628:	04054663          	bltz	a0,80005674 <sys_link+0x108>
  iunlockput(dp);
    8000562c:	854a                	mv	a0,s2
    8000562e:	ffffe097          	auipc	ra,0xffffe
    80005632:	350080e7          	jalr	848(ra) # 8000397e <iunlockput>
  iput(ip);
    80005636:	8526                	mv	a0,s1
    80005638:	ffffe097          	auipc	ra,0xffffe
    8000563c:	216080e7          	jalr	534(ra) # 8000384e <iput>
  end_op(ROOTDEV);
    80005640:	4501                	li	a0,0
    80005642:	fffff097          	auipc	ra,0xfffff
    80005646:	b8c080e7          	jalr	-1140(ra) # 800041ce <end_op>
  return 0;
    8000564a:	4781                	li	a5,0
    8000564c:	a09d                	j	800056b2 <sys_link+0x146>
    end_op(ROOTDEV);
    8000564e:	4501                	li	a0,0
    80005650:	fffff097          	auipc	ra,0xfffff
    80005654:	b7e080e7          	jalr	-1154(ra) # 800041ce <end_op>
    return -1;
    80005658:	57fd                	li	a5,-1
    8000565a:	a8a1                	j	800056b2 <sys_link+0x146>
    iunlockput(ip);
    8000565c:	8526                	mv	a0,s1
    8000565e:	ffffe097          	auipc	ra,0xffffe
    80005662:	320080e7          	jalr	800(ra) # 8000397e <iunlockput>
    end_op(ROOTDEV);
    80005666:	4501                	li	a0,0
    80005668:	fffff097          	auipc	ra,0xfffff
    8000566c:	b66080e7          	jalr	-1178(ra) # 800041ce <end_op>
    return -1;
    80005670:	57fd                	li	a5,-1
    80005672:	a081                	j	800056b2 <sys_link+0x146>
    iunlockput(dp);
    80005674:	854a                	mv	a0,s2
    80005676:	ffffe097          	auipc	ra,0xffffe
    8000567a:	308080e7          	jalr	776(ra) # 8000397e <iunlockput>
  ilock(ip);
    8000567e:	8526                	mv	a0,s1
    80005680:	ffffe097          	auipc	ra,0xffffe
    80005684:	0c0080e7          	jalr	192(ra) # 80003740 <ilock>
  ip->nlink--;
    80005688:	0524d783          	lhu	a5,82(s1)
    8000568c:	37fd                	addiw	a5,a5,-1
    8000568e:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005692:	8526                	mv	a0,s1
    80005694:	ffffe097          	auipc	ra,0xffffe
    80005698:	fe2080e7          	jalr	-30(ra) # 80003676 <iupdate>
  iunlockput(ip);
    8000569c:	8526                	mv	a0,s1
    8000569e:	ffffe097          	auipc	ra,0xffffe
    800056a2:	2e0080e7          	jalr	736(ra) # 8000397e <iunlockput>
  end_op(ROOTDEV);
    800056a6:	4501                	li	a0,0
    800056a8:	fffff097          	auipc	ra,0xfffff
    800056ac:	b26080e7          	jalr	-1242(ra) # 800041ce <end_op>
  return -1;
    800056b0:	57fd                	li	a5,-1
}
    800056b2:	853e                	mv	a0,a5
    800056b4:	70b2                	ld	ra,296(sp)
    800056b6:	7412                	ld	s0,288(sp)
    800056b8:	64f2                	ld	s1,280(sp)
    800056ba:	6952                	ld	s2,272(sp)
    800056bc:	6155                	addi	sp,sp,304
    800056be:	8082                	ret

00000000800056c0 <sys_unlink>:
{
    800056c0:	7151                	addi	sp,sp,-240
    800056c2:	f586                	sd	ra,232(sp)
    800056c4:	f1a2                	sd	s0,224(sp)
    800056c6:	eda6                	sd	s1,216(sp)
    800056c8:	e9ca                	sd	s2,208(sp)
    800056ca:	e5ce                	sd	s3,200(sp)
    800056cc:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056ce:	08000613          	li	a2,128
    800056d2:	f3040593          	addi	a1,s0,-208
    800056d6:	4501                	li	a0,0
    800056d8:	ffffd097          	auipc	ra,0xffffd
    800056dc:	536080e7          	jalr	1334(ra) # 80002c0e <argstr>
    800056e0:	18054463          	bltz	a0,80005868 <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    800056e4:	4501                	li	a0,0
    800056e6:	fffff097          	auipc	ra,0xfffff
    800056ea:	a3e080e7          	jalr	-1474(ra) # 80004124 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056ee:	fb040593          	addi	a1,s0,-80
    800056f2:	f3040513          	addi	a0,s0,-208
    800056f6:	ffffe097          	auipc	ra,0xffffe
    800056fa:	7f2080e7          	jalr	2034(ra) # 80003ee8 <nameiparent>
    800056fe:	84aa                	mv	s1,a0
    80005700:	cd61                	beqz	a0,800057d8 <sys_unlink+0x118>
  ilock(dp);
    80005702:	ffffe097          	auipc	ra,0xffffe
    80005706:	03e080e7          	jalr	62(ra) # 80003740 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000570a:	00004597          	auipc	a1,0x4
    8000570e:	37e58593          	addi	a1,a1,894 # 80009a88 <userret+0x9f8>
    80005712:	fb040513          	addi	a0,s0,-80
    80005716:	ffffe097          	auipc	ra,0xffffe
    8000571a:	4c8080e7          	jalr	1224(ra) # 80003bde <namecmp>
    8000571e:	14050c63          	beqz	a0,80005876 <sys_unlink+0x1b6>
    80005722:	00004597          	auipc	a1,0x4
    80005726:	36e58593          	addi	a1,a1,878 # 80009a90 <userret+0xa00>
    8000572a:	fb040513          	addi	a0,s0,-80
    8000572e:	ffffe097          	auipc	ra,0xffffe
    80005732:	4b0080e7          	jalr	1200(ra) # 80003bde <namecmp>
    80005736:	14050063          	beqz	a0,80005876 <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000573a:	f2c40613          	addi	a2,s0,-212
    8000573e:	fb040593          	addi	a1,s0,-80
    80005742:	8526                	mv	a0,s1
    80005744:	ffffe097          	auipc	ra,0xffffe
    80005748:	4b4080e7          	jalr	1204(ra) # 80003bf8 <dirlookup>
    8000574c:	892a                	mv	s2,a0
    8000574e:	12050463          	beqz	a0,80005876 <sys_unlink+0x1b6>
  ilock(ip);
    80005752:	ffffe097          	auipc	ra,0xffffe
    80005756:	fee080e7          	jalr	-18(ra) # 80003740 <ilock>
  if(ip->nlink < 1)
    8000575a:	05291783          	lh	a5,82(s2)
    8000575e:	08f05463          	blez	a5,800057e6 <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005762:	04c91703          	lh	a4,76(s2)
    80005766:	4785                	li	a5,1
    80005768:	08f70763          	beq	a4,a5,800057f6 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    8000576c:	4641                	li	a2,16
    8000576e:	4581                	li	a1,0
    80005770:	fc040513          	addi	a0,s0,-64
    80005774:	ffffb097          	auipc	ra,0xffffb
    80005778:	606080e7          	jalr	1542(ra) # 80000d7a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000577c:	4741                	li	a4,16
    8000577e:	f2c42683          	lw	a3,-212(s0)
    80005782:	fc040613          	addi	a2,s0,-64
    80005786:	4581                	li	a1,0
    80005788:	8526                	mv	a0,s1
    8000578a:	ffffe097          	auipc	ra,0xffffe
    8000578e:	33a080e7          	jalr	826(ra) # 80003ac4 <writei>
    80005792:	47c1                	li	a5,16
    80005794:	0af51763          	bne	a0,a5,80005842 <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005798:	04c91703          	lh	a4,76(s2)
    8000579c:	4785                	li	a5,1
    8000579e:	0af70a63          	beq	a4,a5,80005852 <sys_unlink+0x192>
  iunlockput(dp);
    800057a2:	8526                	mv	a0,s1
    800057a4:	ffffe097          	auipc	ra,0xffffe
    800057a8:	1da080e7          	jalr	474(ra) # 8000397e <iunlockput>
  ip->nlink--;
    800057ac:	05295783          	lhu	a5,82(s2)
    800057b0:	37fd                	addiw	a5,a5,-1
    800057b2:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    800057b6:	854a                	mv	a0,s2
    800057b8:	ffffe097          	auipc	ra,0xffffe
    800057bc:	ebe080e7          	jalr	-322(ra) # 80003676 <iupdate>
  iunlockput(ip);
    800057c0:	854a                	mv	a0,s2
    800057c2:	ffffe097          	auipc	ra,0xffffe
    800057c6:	1bc080e7          	jalr	444(ra) # 8000397e <iunlockput>
  end_op(ROOTDEV);
    800057ca:	4501                	li	a0,0
    800057cc:	fffff097          	auipc	ra,0xfffff
    800057d0:	a02080e7          	jalr	-1534(ra) # 800041ce <end_op>
  return 0;
    800057d4:	4501                	li	a0,0
    800057d6:	a85d                	j	8000588c <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    800057d8:	4501                	li	a0,0
    800057da:	fffff097          	auipc	ra,0xfffff
    800057de:	9f4080e7          	jalr	-1548(ra) # 800041ce <end_op>
    return -1;
    800057e2:	557d                	li	a0,-1
    800057e4:	a065                	j	8000588c <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    800057e6:	00004517          	auipc	a0,0x4
    800057ea:	2d250513          	addi	a0,a0,722 # 80009ab8 <userret+0xa28>
    800057ee:	ffffb097          	auipc	ra,0xffffb
    800057f2:	d6c080e7          	jalr	-660(ra) # 8000055a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057f6:	05492703          	lw	a4,84(s2)
    800057fa:	02000793          	li	a5,32
    800057fe:	f6e7f7e3          	bgeu	a5,a4,8000576c <sys_unlink+0xac>
    80005802:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005806:	4741                	li	a4,16
    80005808:	86ce                	mv	a3,s3
    8000580a:	f1840613          	addi	a2,s0,-232
    8000580e:	4581                	li	a1,0
    80005810:	854a                	mv	a0,s2
    80005812:	ffffe097          	auipc	ra,0xffffe
    80005816:	1be080e7          	jalr	446(ra) # 800039d0 <readi>
    8000581a:	47c1                	li	a5,16
    8000581c:	00f51b63          	bne	a0,a5,80005832 <sys_unlink+0x172>
    if(de.inum != 0)
    80005820:	f1845783          	lhu	a5,-232(s0)
    80005824:	e7a1                	bnez	a5,8000586c <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005826:	29c1                	addiw	s3,s3,16
    80005828:	05492783          	lw	a5,84(s2)
    8000582c:	fcf9ede3          	bltu	s3,a5,80005806 <sys_unlink+0x146>
    80005830:	bf35                	j	8000576c <sys_unlink+0xac>
      panic("isdirempty: readi");
    80005832:	00004517          	auipc	a0,0x4
    80005836:	29e50513          	addi	a0,a0,670 # 80009ad0 <userret+0xa40>
    8000583a:	ffffb097          	auipc	ra,0xffffb
    8000583e:	d20080e7          	jalr	-736(ra) # 8000055a <panic>
    panic("unlink: writei");
    80005842:	00004517          	auipc	a0,0x4
    80005846:	2a650513          	addi	a0,a0,678 # 80009ae8 <userret+0xa58>
    8000584a:	ffffb097          	auipc	ra,0xffffb
    8000584e:	d10080e7          	jalr	-752(ra) # 8000055a <panic>
    dp->nlink--;
    80005852:	0524d783          	lhu	a5,82(s1)
    80005856:	37fd                	addiw	a5,a5,-1
    80005858:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    8000585c:	8526                	mv	a0,s1
    8000585e:	ffffe097          	auipc	ra,0xffffe
    80005862:	e18080e7          	jalr	-488(ra) # 80003676 <iupdate>
    80005866:	bf35                	j	800057a2 <sys_unlink+0xe2>
    return -1;
    80005868:	557d                	li	a0,-1
    8000586a:	a00d                	j	8000588c <sys_unlink+0x1cc>
    iunlockput(ip);
    8000586c:	854a                	mv	a0,s2
    8000586e:	ffffe097          	auipc	ra,0xffffe
    80005872:	110080e7          	jalr	272(ra) # 8000397e <iunlockput>
  iunlockput(dp);
    80005876:	8526                	mv	a0,s1
    80005878:	ffffe097          	auipc	ra,0xffffe
    8000587c:	106080e7          	jalr	262(ra) # 8000397e <iunlockput>
  end_op(ROOTDEV);
    80005880:	4501                	li	a0,0
    80005882:	fffff097          	auipc	ra,0xfffff
    80005886:	94c080e7          	jalr	-1716(ra) # 800041ce <end_op>
  return -1;
    8000588a:	557d                	li	a0,-1
}
    8000588c:	70ae                	ld	ra,232(sp)
    8000588e:	740e                	ld	s0,224(sp)
    80005890:	64ee                	ld	s1,216(sp)
    80005892:	694e                	ld	s2,208(sp)
    80005894:	69ae                	ld	s3,200(sp)
    80005896:	616d                	addi	sp,sp,240
    80005898:	8082                	ret

000000008000589a <sys_open>:

uint64
sys_open(void)
{
    8000589a:	7131                	addi	sp,sp,-192
    8000589c:	fd06                	sd	ra,184(sp)
    8000589e:	f922                	sd	s0,176(sp)
    800058a0:	f526                	sd	s1,168(sp)
    800058a2:	f14a                	sd	s2,160(sp)
    800058a4:	ed4e                	sd	s3,152(sp)
    800058a6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058a8:	08000613          	li	a2,128
    800058ac:	f5040593          	addi	a1,s0,-176
    800058b0:	4501                	li	a0,0
    800058b2:	ffffd097          	auipc	ra,0xffffd
    800058b6:	35c080e7          	jalr	860(ra) # 80002c0e <argstr>
    return -1;
    800058ba:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058bc:	0a054963          	bltz	a0,8000596e <sys_open+0xd4>
    800058c0:	f4c40593          	addi	a1,s0,-180
    800058c4:	4505                	li	a0,1
    800058c6:	ffffd097          	auipc	ra,0xffffd
    800058ca:	304080e7          	jalr	772(ra) # 80002bca <argint>
    800058ce:	0a054063          	bltz	a0,8000596e <sys_open+0xd4>

  begin_op(ROOTDEV);
    800058d2:	4501                	li	a0,0
    800058d4:	fffff097          	auipc	ra,0xfffff
    800058d8:	850080e7          	jalr	-1968(ra) # 80004124 <begin_op>

  if(omode & O_CREATE){
    800058dc:	f4c42783          	lw	a5,-180(s0)
    800058e0:	2007f793          	andi	a5,a5,512
    800058e4:	c3dd                	beqz	a5,8000598a <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    800058e6:	4681                	li	a3,0
    800058e8:	4601                	li	a2,0
    800058ea:	4589                	li	a1,2
    800058ec:	f5040513          	addi	a0,s0,-176
    800058f0:	00000097          	auipc	ra,0x0
    800058f4:	8d2080e7          	jalr	-1838(ra) # 800051c2 <create>
    800058f8:	892a                	mv	s2,a0
    if(ip == 0){
    800058fa:	c151                	beqz	a0,8000597e <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058fc:	04c91703          	lh	a4,76(s2)
    80005900:	478d                	li	a5,3
    80005902:	00f71763          	bne	a4,a5,80005910 <sys_open+0x76>
    80005906:	04e95703          	lhu	a4,78(s2)
    8000590a:	47a5                	li	a5,9
    8000590c:	0ce7e663          	bltu	a5,a4,800059d8 <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005910:	fffff097          	auipc	ra,0xfffff
    80005914:	cf2080e7          	jalr	-782(ra) # 80004602 <filealloc>
    80005918:	89aa                	mv	s3,a0
    8000591a:	c97d                	beqz	a0,80005a10 <sys_open+0x176>
    8000591c:	fffff097          	auipc	ra,0xfffff
    80005920:	7fc080e7          	jalr	2044(ra) # 80005118 <fdalloc>
    80005924:	84aa                	mv	s1,a0
    80005926:	0e054063          	bltz	a0,80005a06 <sys_open+0x16c>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000592a:	04c91703          	lh	a4,76(s2)
    8000592e:	478d                	li	a5,3
    80005930:	0cf70063          	beq	a4,a5,800059f0 <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    80005934:	4789                	li	a5,2
    80005936:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    8000593a:	0329b023          	sd	s2,32(s3)
  f->off = 0;
    8000593e:	0209a823          	sw	zero,48(s3)
  f->readable = !(omode & O_WRONLY);
    80005942:	f4c42783          	lw	a5,-180(s0)
    80005946:	0017c713          	xori	a4,a5,1
    8000594a:	8b05                	andi	a4,a4,1
    8000594c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005950:	8b8d                	andi	a5,a5,3
    80005952:	00f037b3          	snez	a5,a5
    80005956:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    8000595a:	854a                	mv	a0,s2
    8000595c:	ffffe097          	auipc	ra,0xffffe
    80005960:	ea6080e7          	jalr	-346(ra) # 80003802 <iunlock>
  end_op(ROOTDEV);
    80005964:	4501                	li	a0,0
    80005966:	fffff097          	auipc	ra,0xfffff
    8000596a:	868080e7          	jalr	-1944(ra) # 800041ce <end_op>

  return fd;
}
    8000596e:	8526                	mv	a0,s1
    80005970:	70ea                	ld	ra,184(sp)
    80005972:	744a                	ld	s0,176(sp)
    80005974:	74aa                	ld	s1,168(sp)
    80005976:	790a                	ld	s2,160(sp)
    80005978:	69ea                	ld	s3,152(sp)
    8000597a:	6129                	addi	sp,sp,192
    8000597c:	8082                	ret
      end_op(ROOTDEV);
    8000597e:	4501                	li	a0,0
    80005980:	fffff097          	auipc	ra,0xfffff
    80005984:	84e080e7          	jalr	-1970(ra) # 800041ce <end_op>
      return -1;
    80005988:	b7dd                	j	8000596e <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    8000598a:	f5040513          	addi	a0,s0,-176
    8000598e:	ffffe097          	auipc	ra,0xffffe
    80005992:	53c080e7          	jalr	1340(ra) # 80003eca <namei>
    80005996:	892a                	mv	s2,a0
    80005998:	c90d                	beqz	a0,800059ca <sys_open+0x130>
    ilock(ip);
    8000599a:	ffffe097          	auipc	ra,0xffffe
    8000599e:	da6080e7          	jalr	-602(ra) # 80003740 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059a2:	04c91703          	lh	a4,76(s2)
    800059a6:	4785                	li	a5,1
    800059a8:	f4f71ae3          	bne	a4,a5,800058fc <sys_open+0x62>
    800059ac:	f4c42783          	lw	a5,-180(s0)
    800059b0:	d3a5                	beqz	a5,80005910 <sys_open+0x76>
      iunlockput(ip);
    800059b2:	854a                	mv	a0,s2
    800059b4:	ffffe097          	auipc	ra,0xffffe
    800059b8:	fca080e7          	jalr	-54(ra) # 8000397e <iunlockput>
      end_op(ROOTDEV);
    800059bc:	4501                	li	a0,0
    800059be:	fffff097          	auipc	ra,0xfffff
    800059c2:	810080e7          	jalr	-2032(ra) # 800041ce <end_op>
      return -1;
    800059c6:	54fd                	li	s1,-1
    800059c8:	b75d                	j	8000596e <sys_open+0xd4>
      end_op(ROOTDEV);
    800059ca:	4501                	li	a0,0
    800059cc:	fffff097          	auipc	ra,0xfffff
    800059d0:	802080e7          	jalr	-2046(ra) # 800041ce <end_op>
      return -1;
    800059d4:	54fd                	li	s1,-1
    800059d6:	bf61                	j	8000596e <sys_open+0xd4>
    iunlockput(ip);
    800059d8:	854a                	mv	a0,s2
    800059da:	ffffe097          	auipc	ra,0xffffe
    800059de:	fa4080e7          	jalr	-92(ra) # 8000397e <iunlockput>
    end_op(ROOTDEV);
    800059e2:	4501                	li	a0,0
    800059e4:	ffffe097          	auipc	ra,0xffffe
    800059e8:	7ea080e7          	jalr	2026(ra) # 800041ce <end_op>
    return -1;
    800059ec:	54fd                	li	s1,-1
    800059ee:	b741                	j	8000596e <sys_open+0xd4>
    f->type = FD_DEVICE;
    800059f0:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059f4:	04e91783          	lh	a5,78(s2)
    800059f8:	02f99a23          	sh	a5,52(s3)
    f->minor = ip->minor;
    800059fc:	05091783          	lh	a5,80(s2)
    80005a00:	02f99b23          	sh	a5,54(s3)
    80005a04:	bf1d                	j	8000593a <sys_open+0xa0>
      fileclose(f);
    80005a06:	854e                	mv	a0,s3
    80005a08:	fffff097          	auipc	ra,0xfffff
    80005a0c:	cb6080e7          	jalr	-842(ra) # 800046be <fileclose>
    iunlockput(ip);
    80005a10:	854a                	mv	a0,s2
    80005a12:	ffffe097          	auipc	ra,0xffffe
    80005a16:	f6c080e7          	jalr	-148(ra) # 8000397e <iunlockput>
    end_op(ROOTDEV);
    80005a1a:	4501                	li	a0,0
    80005a1c:	ffffe097          	auipc	ra,0xffffe
    80005a20:	7b2080e7          	jalr	1970(ra) # 800041ce <end_op>
    return -1;
    80005a24:	54fd                	li	s1,-1
    80005a26:	b7a1                	j	8000596e <sys_open+0xd4>

0000000080005a28 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a28:	7175                	addi	sp,sp,-144
    80005a2a:	e506                	sd	ra,136(sp)
    80005a2c:	e122                	sd	s0,128(sp)
    80005a2e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    80005a30:	4501                	li	a0,0
    80005a32:	ffffe097          	auipc	ra,0xffffe
    80005a36:	6f2080e7          	jalr	1778(ra) # 80004124 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a3a:	08000613          	li	a2,128
    80005a3e:	f7040593          	addi	a1,s0,-144
    80005a42:	4501                	li	a0,0
    80005a44:	ffffd097          	auipc	ra,0xffffd
    80005a48:	1ca080e7          	jalr	458(ra) # 80002c0e <argstr>
    80005a4c:	02054a63          	bltz	a0,80005a80 <sys_mkdir+0x58>
    80005a50:	4681                	li	a3,0
    80005a52:	4601                	li	a2,0
    80005a54:	4585                	li	a1,1
    80005a56:	f7040513          	addi	a0,s0,-144
    80005a5a:	fffff097          	auipc	ra,0xfffff
    80005a5e:	768080e7          	jalr	1896(ra) # 800051c2 <create>
    80005a62:	cd19                	beqz	a0,80005a80 <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005a64:	ffffe097          	auipc	ra,0xffffe
    80005a68:	f1a080e7          	jalr	-230(ra) # 8000397e <iunlockput>
  end_op(ROOTDEV);
    80005a6c:	4501                	li	a0,0
    80005a6e:	ffffe097          	auipc	ra,0xffffe
    80005a72:	760080e7          	jalr	1888(ra) # 800041ce <end_op>
  return 0;
    80005a76:	4501                	li	a0,0
}
    80005a78:	60aa                	ld	ra,136(sp)
    80005a7a:	640a                	ld	s0,128(sp)
    80005a7c:	6149                	addi	sp,sp,144
    80005a7e:	8082                	ret
    end_op(ROOTDEV);
    80005a80:	4501                	li	a0,0
    80005a82:	ffffe097          	auipc	ra,0xffffe
    80005a86:	74c080e7          	jalr	1868(ra) # 800041ce <end_op>
    return -1;
    80005a8a:	557d                	li	a0,-1
    80005a8c:	b7f5                	j	80005a78 <sys_mkdir+0x50>

0000000080005a8e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a8e:	7135                	addi	sp,sp,-160
    80005a90:	ed06                	sd	ra,152(sp)
    80005a92:	e922                	sd	s0,144(sp)
    80005a94:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    80005a96:	4501                	li	a0,0
    80005a98:	ffffe097          	auipc	ra,0xffffe
    80005a9c:	68c080e7          	jalr	1676(ra) # 80004124 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005aa0:	08000613          	li	a2,128
    80005aa4:	f7040593          	addi	a1,s0,-144
    80005aa8:	4501                	li	a0,0
    80005aaa:	ffffd097          	auipc	ra,0xffffd
    80005aae:	164080e7          	jalr	356(ra) # 80002c0e <argstr>
    80005ab2:	04054b63          	bltz	a0,80005b08 <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    80005ab6:	f6c40593          	addi	a1,s0,-148
    80005aba:	4505                	li	a0,1
    80005abc:	ffffd097          	auipc	ra,0xffffd
    80005ac0:	10e080e7          	jalr	270(ra) # 80002bca <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ac4:	04054263          	bltz	a0,80005b08 <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    80005ac8:	f6840593          	addi	a1,s0,-152
    80005acc:	4509                	li	a0,2
    80005ace:	ffffd097          	auipc	ra,0xffffd
    80005ad2:	0fc080e7          	jalr	252(ra) # 80002bca <argint>
     argint(1, &major) < 0 ||
    80005ad6:	02054963          	bltz	a0,80005b08 <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ada:	f6841683          	lh	a3,-152(s0)
    80005ade:	f6c41603          	lh	a2,-148(s0)
    80005ae2:	458d                	li	a1,3
    80005ae4:	f7040513          	addi	a0,s0,-144
    80005ae8:	fffff097          	auipc	ra,0xfffff
    80005aec:	6da080e7          	jalr	1754(ra) # 800051c2 <create>
     argint(2, &minor) < 0 ||
    80005af0:	cd01                	beqz	a0,80005b08 <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005af2:	ffffe097          	auipc	ra,0xffffe
    80005af6:	e8c080e7          	jalr	-372(ra) # 8000397e <iunlockput>
  end_op(ROOTDEV);
    80005afa:	4501                	li	a0,0
    80005afc:	ffffe097          	auipc	ra,0xffffe
    80005b00:	6d2080e7          	jalr	1746(ra) # 800041ce <end_op>
  return 0;
    80005b04:	4501                	li	a0,0
    80005b06:	a039                	j	80005b14 <sys_mknod+0x86>
    end_op(ROOTDEV);
    80005b08:	4501                	li	a0,0
    80005b0a:	ffffe097          	auipc	ra,0xffffe
    80005b0e:	6c4080e7          	jalr	1732(ra) # 800041ce <end_op>
    return -1;
    80005b12:	557d                	li	a0,-1
}
    80005b14:	60ea                	ld	ra,152(sp)
    80005b16:	644a                	ld	s0,144(sp)
    80005b18:	610d                	addi	sp,sp,160
    80005b1a:	8082                	ret

0000000080005b1c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b1c:	7135                	addi	sp,sp,-160
    80005b1e:	ed06                	sd	ra,152(sp)
    80005b20:	e922                	sd	s0,144(sp)
    80005b22:	e526                	sd	s1,136(sp)
    80005b24:	e14a                	sd	s2,128(sp)
    80005b26:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b28:	ffffc097          	auipc	ra,0xffffc
    80005b2c:	f7a080e7          	jalr	-134(ra) # 80001aa2 <myproc>
    80005b30:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    80005b32:	4501                	li	a0,0
    80005b34:	ffffe097          	auipc	ra,0xffffe
    80005b38:	5f0080e7          	jalr	1520(ra) # 80004124 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b3c:	08000613          	li	a2,128
    80005b40:	f6040593          	addi	a1,s0,-160
    80005b44:	4501                	li	a0,0
    80005b46:	ffffd097          	auipc	ra,0xffffd
    80005b4a:	0c8080e7          	jalr	200(ra) # 80002c0e <argstr>
    80005b4e:	04054c63          	bltz	a0,80005ba6 <sys_chdir+0x8a>
    80005b52:	f6040513          	addi	a0,s0,-160
    80005b56:	ffffe097          	auipc	ra,0xffffe
    80005b5a:	374080e7          	jalr	884(ra) # 80003eca <namei>
    80005b5e:	84aa                	mv	s1,a0
    80005b60:	c139                	beqz	a0,80005ba6 <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80005b62:	ffffe097          	auipc	ra,0xffffe
    80005b66:	bde080e7          	jalr	-1058(ra) # 80003740 <ilock>
  if(ip->type != T_DIR){
    80005b6a:	04c49703          	lh	a4,76(s1)
    80005b6e:	4785                	li	a5,1
    80005b70:	04f71263          	bne	a4,a5,80005bb4 <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    80005b74:	8526                	mv	a0,s1
    80005b76:	ffffe097          	auipc	ra,0xffffe
    80005b7a:	c8c080e7          	jalr	-884(ra) # 80003802 <iunlock>
  iput(p->cwd);
    80005b7e:	15893503          	ld	a0,344(s2)
    80005b82:	ffffe097          	auipc	ra,0xffffe
    80005b86:	ccc080e7          	jalr	-820(ra) # 8000384e <iput>
  end_op(ROOTDEV);
    80005b8a:	4501                	li	a0,0
    80005b8c:	ffffe097          	auipc	ra,0xffffe
    80005b90:	642080e7          	jalr	1602(ra) # 800041ce <end_op>
  p->cwd = ip;
    80005b94:	14993c23          	sd	s1,344(s2)
  return 0;
    80005b98:	4501                	li	a0,0
}
    80005b9a:	60ea                	ld	ra,152(sp)
    80005b9c:	644a                	ld	s0,144(sp)
    80005b9e:	64aa                	ld	s1,136(sp)
    80005ba0:	690a                	ld	s2,128(sp)
    80005ba2:	610d                	addi	sp,sp,160
    80005ba4:	8082                	ret
    end_op(ROOTDEV);
    80005ba6:	4501                	li	a0,0
    80005ba8:	ffffe097          	auipc	ra,0xffffe
    80005bac:	626080e7          	jalr	1574(ra) # 800041ce <end_op>
    return -1;
    80005bb0:	557d                	li	a0,-1
    80005bb2:	b7e5                	j	80005b9a <sys_chdir+0x7e>
    iunlockput(ip);
    80005bb4:	8526                	mv	a0,s1
    80005bb6:	ffffe097          	auipc	ra,0xffffe
    80005bba:	dc8080e7          	jalr	-568(ra) # 8000397e <iunlockput>
    end_op(ROOTDEV);
    80005bbe:	4501                	li	a0,0
    80005bc0:	ffffe097          	auipc	ra,0xffffe
    80005bc4:	60e080e7          	jalr	1550(ra) # 800041ce <end_op>
    return -1;
    80005bc8:	557d                	li	a0,-1
    80005bca:	bfc1                	j	80005b9a <sys_chdir+0x7e>

0000000080005bcc <sys_exec>:

uint64
sys_exec(void)
{
    80005bcc:	7145                	addi	sp,sp,-464
    80005bce:	e786                	sd	ra,456(sp)
    80005bd0:	e3a2                	sd	s0,448(sp)
    80005bd2:	ff26                	sd	s1,440(sp)
    80005bd4:	fb4a                	sd	s2,432(sp)
    80005bd6:	f74e                	sd	s3,424(sp)
    80005bd8:	f352                	sd	s4,416(sp)
    80005bda:	ef56                	sd	s5,408(sp)
    80005bdc:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bde:	08000613          	li	a2,128
    80005be2:	f4040593          	addi	a1,s0,-192
    80005be6:	4501                	li	a0,0
    80005be8:	ffffd097          	auipc	ra,0xffffd
    80005bec:	026080e7          	jalr	38(ra) # 80002c0e <argstr>
    80005bf0:	0e054663          	bltz	a0,80005cdc <sys_exec+0x110>
    80005bf4:	e3840593          	addi	a1,s0,-456
    80005bf8:	4505                	li	a0,1
    80005bfa:	ffffd097          	auipc	ra,0xffffd
    80005bfe:	ff2080e7          	jalr	-14(ra) # 80002bec <argaddr>
    80005c02:	0e054763          	bltz	a0,80005cf0 <sys_exec+0x124>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80005c06:	10000613          	li	a2,256
    80005c0a:	4581                	li	a1,0
    80005c0c:	e4040513          	addi	a0,s0,-448
    80005c10:	ffffb097          	auipc	ra,0xffffb
    80005c14:	16a080e7          	jalr	362(ra) # 80000d7a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c18:	e4040913          	addi	s2,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c1c:	89ca                	mv	s3,s2
    80005c1e:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005c20:	02000a13          	li	s4,32
    80005c24:	00048a9b          	sext.w	s5,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c28:	00349513          	slli	a0,s1,0x3
    80005c2c:	e3040593          	addi	a1,s0,-464
    80005c30:	e3843783          	ld	a5,-456(s0)
    80005c34:	953e                	add	a0,a0,a5
    80005c36:	ffffd097          	auipc	ra,0xffffd
    80005c3a:	efa080e7          	jalr	-262(ra) # 80002b30 <fetchaddr>
    80005c3e:	02054a63          	bltz	a0,80005c72 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c42:	e3043783          	ld	a5,-464(s0)
    80005c46:	c7a1                	beqz	a5,80005c8e <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c48:	ffffb097          	auipc	ra,0xffffb
    80005c4c:	d30080e7          	jalr	-720(ra) # 80000978 <kalloc>
    80005c50:	85aa                	mv	a1,a0
    80005c52:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c56:	c92d                	beqz	a0,80005cc8 <sys_exec+0xfc>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80005c58:	6605                	lui	a2,0x1
    80005c5a:	e3043503          	ld	a0,-464(s0)
    80005c5e:	ffffd097          	auipc	ra,0xffffd
    80005c62:	f24080e7          	jalr	-220(ra) # 80002b82 <fetchstr>
    80005c66:	00054663          	bltz	a0,80005c72 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c6a:	0485                	addi	s1,s1,1
    80005c6c:	09a1                	addi	s3,s3,8
    80005c6e:	fb449be3          	bne	s1,s4,80005c24 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c72:	10090493          	addi	s1,s2,256
    80005c76:	00093503          	ld	a0,0(s2)
    80005c7a:	cd39                	beqz	a0,80005cd8 <sys_exec+0x10c>
    kfree(argv[i]);
    80005c7c:	ffffb097          	auipc	ra,0xffffb
    80005c80:	c00080e7          	jalr	-1024(ra) # 8000087c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c84:	0921                	addi	s2,s2,8
    80005c86:	fe9918e3          	bne	s2,s1,80005c76 <sys_exec+0xaa>
  return -1;
    80005c8a:	557d                	li	a0,-1
    80005c8c:	a889                	j	80005cde <sys_exec+0x112>
      argv[i] = 0;
    80005c8e:	0a8e                	slli	s5,s5,0x3
    80005c90:	fc040793          	addi	a5,s0,-64
    80005c94:	9abe                	add	s5,s5,a5
    80005c96:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd5ab4>
  int ret = exec(path, argv);
    80005c9a:	e4040593          	addi	a1,s0,-448
    80005c9e:	f4040513          	addi	a0,s0,-192
    80005ca2:	fffff097          	auipc	ra,0xfffff
    80005ca6:	10c080e7          	jalr	268(ra) # 80004dae <exec>
    80005caa:	84aa                	mv	s1,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cac:	10090993          	addi	s3,s2,256
    80005cb0:	00093503          	ld	a0,0(s2)
    80005cb4:	c901                	beqz	a0,80005cc4 <sys_exec+0xf8>
    kfree(argv[i]);
    80005cb6:	ffffb097          	auipc	ra,0xffffb
    80005cba:	bc6080e7          	jalr	-1082(ra) # 8000087c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cbe:	0921                	addi	s2,s2,8
    80005cc0:	ff3918e3          	bne	s2,s3,80005cb0 <sys_exec+0xe4>
  return ret;
    80005cc4:	8526                	mv	a0,s1
    80005cc6:	a821                	j	80005cde <sys_exec+0x112>
      panic("sys_exec kalloc");
    80005cc8:	00004517          	auipc	a0,0x4
    80005ccc:	e3050513          	addi	a0,a0,-464 # 80009af8 <userret+0xa68>
    80005cd0:	ffffb097          	auipc	ra,0xffffb
    80005cd4:	88a080e7          	jalr	-1910(ra) # 8000055a <panic>
  return -1;
    80005cd8:	557d                	li	a0,-1
    80005cda:	a011                	j	80005cde <sys_exec+0x112>
    return -1;
    80005cdc:	557d                	li	a0,-1
}
    80005cde:	60be                	ld	ra,456(sp)
    80005ce0:	641e                	ld	s0,448(sp)
    80005ce2:	74fa                	ld	s1,440(sp)
    80005ce4:	795a                	ld	s2,432(sp)
    80005ce6:	79ba                	ld	s3,424(sp)
    80005ce8:	7a1a                	ld	s4,416(sp)
    80005cea:	6afa                	ld	s5,408(sp)
    80005cec:	6179                	addi	sp,sp,464
    80005cee:	8082                	ret
    return -1;
    80005cf0:	557d                	li	a0,-1
    80005cf2:	b7f5                	j	80005cde <sys_exec+0x112>

0000000080005cf4 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005cf4:	7139                	addi	sp,sp,-64
    80005cf6:	fc06                	sd	ra,56(sp)
    80005cf8:	f822                	sd	s0,48(sp)
    80005cfa:	f426                	sd	s1,40(sp)
    80005cfc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005cfe:	ffffc097          	auipc	ra,0xffffc
    80005d02:	da4080e7          	jalr	-604(ra) # 80001aa2 <myproc>
    80005d06:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d08:	fd840593          	addi	a1,s0,-40
    80005d0c:	4501                	li	a0,0
    80005d0e:	ffffd097          	auipc	ra,0xffffd
    80005d12:	ede080e7          	jalr	-290(ra) # 80002bec <argaddr>
    return -1;
    80005d16:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d18:	0e054063          	bltz	a0,80005df8 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005d1c:	fc840593          	addi	a1,s0,-56
    80005d20:	fd040513          	addi	a0,s0,-48
    80005d24:	fffff097          	auipc	ra,0xfffff
    80005d28:	d40080e7          	jalr	-704(ra) # 80004a64 <pipealloc>
    return -1;
    80005d2c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d2e:	0c054563          	bltz	a0,80005df8 <sys_pipe+0x104>
  fd0 = -1;
    80005d32:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d36:	fd043503          	ld	a0,-48(s0)
    80005d3a:	fffff097          	auipc	ra,0xfffff
    80005d3e:	3de080e7          	jalr	990(ra) # 80005118 <fdalloc>
    80005d42:	fca42223          	sw	a0,-60(s0)
    80005d46:	08054c63          	bltz	a0,80005dde <sys_pipe+0xea>
    80005d4a:	fc843503          	ld	a0,-56(s0)
    80005d4e:	fffff097          	auipc	ra,0xfffff
    80005d52:	3ca080e7          	jalr	970(ra) # 80005118 <fdalloc>
    80005d56:	fca42023          	sw	a0,-64(s0)
    80005d5a:	06054863          	bltz	a0,80005dca <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d5e:	4691                	li	a3,4
    80005d60:	fc440613          	addi	a2,s0,-60
    80005d64:	fd843583          	ld	a1,-40(s0)
    80005d68:	6ca8                	ld	a0,88(s1)
    80005d6a:	ffffc097          	auipc	ra,0xffffc
    80005d6e:	a2c080e7          	jalr	-1492(ra) # 80001796 <copyout>
    80005d72:	02054063          	bltz	a0,80005d92 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d76:	4691                	li	a3,4
    80005d78:	fc040613          	addi	a2,s0,-64
    80005d7c:	fd843583          	ld	a1,-40(s0)
    80005d80:	0591                	addi	a1,a1,4
    80005d82:	6ca8                	ld	a0,88(s1)
    80005d84:	ffffc097          	auipc	ra,0xffffc
    80005d88:	a12080e7          	jalr	-1518(ra) # 80001796 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d8c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d8e:	06055563          	bgez	a0,80005df8 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005d92:	fc442783          	lw	a5,-60(s0)
    80005d96:	07e9                	addi	a5,a5,26
    80005d98:	078e                	slli	a5,a5,0x3
    80005d9a:	97a6                	add	a5,a5,s1
    80005d9c:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005da0:	fc042503          	lw	a0,-64(s0)
    80005da4:	0569                	addi	a0,a0,26
    80005da6:	050e                	slli	a0,a0,0x3
    80005da8:	9526                	add	a0,a0,s1
    80005daa:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005dae:	fd043503          	ld	a0,-48(s0)
    80005db2:	fffff097          	auipc	ra,0xfffff
    80005db6:	90c080e7          	jalr	-1780(ra) # 800046be <fileclose>
    fileclose(wf);
    80005dba:	fc843503          	ld	a0,-56(s0)
    80005dbe:	fffff097          	auipc	ra,0xfffff
    80005dc2:	900080e7          	jalr	-1792(ra) # 800046be <fileclose>
    return -1;
    80005dc6:	57fd                	li	a5,-1
    80005dc8:	a805                	j	80005df8 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005dca:	fc442783          	lw	a5,-60(s0)
    80005dce:	0007c863          	bltz	a5,80005dde <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005dd2:	01a78513          	addi	a0,a5,26
    80005dd6:	050e                	slli	a0,a0,0x3
    80005dd8:	9526                	add	a0,a0,s1
    80005dda:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005dde:	fd043503          	ld	a0,-48(s0)
    80005de2:	fffff097          	auipc	ra,0xfffff
    80005de6:	8dc080e7          	jalr	-1828(ra) # 800046be <fileclose>
    fileclose(wf);
    80005dea:	fc843503          	ld	a0,-56(s0)
    80005dee:	fffff097          	auipc	ra,0xfffff
    80005df2:	8d0080e7          	jalr	-1840(ra) # 800046be <fileclose>
    return -1;
    80005df6:	57fd                	li	a5,-1
}
    80005df8:	853e                	mv	a0,a5
    80005dfa:	70e2                	ld	ra,56(sp)
    80005dfc:	7442                	ld	s0,48(sp)
    80005dfe:	74a2                	ld	s1,40(sp)
    80005e00:	6121                	addi	sp,sp,64
    80005e02:	8082                	ret
	...

0000000080005e10 <kernelvec>:
    80005e10:	7111                	addi	sp,sp,-256
    80005e12:	e006                	sd	ra,0(sp)
    80005e14:	e40a                	sd	sp,8(sp)
    80005e16:	e80e                	sd	gp,16(sp)
    80005e18:	ec12                	sd	tp,24(sp)
    80005e1a:	f016                	sd	t0,32(sp)
    80005e1c:	f41a                	sd	t1,40(sp)
    80005e1e:	f81e                	sd	t2,48(sp)
    80005e20:	fc22                	sd	s0,56(sp)
    80005e22:	e0a6                	sd	s1,64(sp)
    80005e24:	e4aa                	sd	a0,72(sp)
    80005e26:	e8ae                	sd	a1,80(sp)
    80005e28:	ecb2                	sd	a2,88(sp)
    80005e2a:	f0b6                	sd	a3,96(sp)
    80005e2c:	f4ba                	sd	a4,104(sp)
    80005e2e:	f8be                	sd	a5,112(sp)
    80005e30:	fcc2                	sd	a6,120(sp)
    80005e32:	e146                	sd	a7,128(sp)
    80005e34:	e54a                	sd	s2,136(sp)
    80005e36:	e94e                	sd	s3,144(sp)
    80005e38:	ed52                	sd	s4,152(sp)
    80005e3a:	f156                	sd	s5,160(sp)
    80005e3c:	f55a                	sd	s6,168(sp)
    80005e3e:	f95e                	sd	s7,176(sp)
    80005e40:	fd62                	sd	s8,184(sp)
    80005e42:	e1e6                	sd	s9,192(sp)
    80005e44:	e5ea                	sd	s10,200(sp)
    80005e46:	e9ee                	sd	s11,208(sp)
    80005e48:	edf2                	sd	t3,216(sp)
    80005e4a:	f1f6                	sd	t4,224(sp)
    80005e4c:	f5fa                	sd	t5,232(sp)
    80005e4e:	f9fe                	sd	t6,240(sp)
    80005e50:	ba1fc0ef          	jal	ra,800029f0 <kerneltrap>
    80005e54:	6082                	ld	ra,0(sp)
    80005e56:	6122                	ld	sp,8(sp)
    80005e58:	61c2                	ld	gp,16(sp)
    80005e5a:	7282                	ld	t0,32(sp)
    80005e5c:	7322                	ld	t1,40(sp)
    80005e5e:	73c2                	ld	t2,48(sp)
    80005e60:	7462                	ld	s0,56(sp)
    80005e62:	6486                	ld	s1,64(sp)
    80005e64:	6526                	ld	a0,72(sp)
    80005e66:	65c6                	ld	a1,80(sp)
    80005e68:	6666                	ld	a2,88(sp)
    80005e6a:	7686                	ld	a3,96(sp)
    80005e6c:	7726                	ld	a4,104(sp)
    80005e6e:	77c6                	ld	a5,112(sp)
    80005e70:	7866                	ld	a6,120(sp)
    80005e72:	688a                	ld	a7,128(sp)
    80005e74:	692a                	ld	s2,136(sp)
    80005e76:	69ca                	ld	s3,144(sp)
    80005e78:	6a6a                	ld	s4,152(sp)
    80005e7a:	7a8a                	ld	s5,160(sp)
    80005e7c:	7b2a                	ld	s6,168(sp)
    80005e7e:	7bca                	ld	s7,176(sp)
    80005e80:	7c6a                	ld	s8,184(sp)
    80005e82:	6c8e                	ld	s9,192(sp)
    80005e84:	6d2e                	ld	s10,200(sp)
    80005e86:	6dce                	ld	s11,208(sp)
    80005e88:	6e6e                	ld	t3,216(sp)
    80005e8a:	7e8e                	ld	t4,224(sp)
    80005e8c:	7f2e                	ld	t5,232(sp)
    80005e8e:	7fce                	ld	t6,240(sp)
    80005e90:	6111                	addi	sp,sp,256
    80005e92:	10200073          	sret
    80005e96:	00000013          	nop
    80005e9a:	00000013          	nop
    80005e9e:	0001                	nop

0000000080005ea0 <timervec>:
    80005ea0:	34051573          	csrrw	a0,mscratch,a0
    80005ea4:	e10c                	sd	a1,0(a0)
    80005ea6:	e510                	sd	a2,8(a0)
    80005ea8:	e914                	sd	a3,16(a0)
    80005eaa:	710c                	ld	a1,32(a0)
    80005eac:	7510                	ld	a2,40(a0)
    80005eae:	6194                	ld	a3,0(a1)
    80005eb0:	96b2                	add	a3,a3,a2
    80005eb2:	e194                	sd	a3,0(a1)
    80005eb4:	4589                	li	a1,2
    80005eb6:	14459073          	csrw	sip,a1
    80005eba:	6914                	ld	a3,16(a0)
    80005ebc:	6510                	ld	a2,8(a0)
    80005ebe:	610c                	ld	a1,0(a0)
    80005ec0:	34051573          	csrrw	a0,mscratch,a0
    80005ec4:	30200073          	mret
	...

0000000080005eca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eca:	1141                	addi	sp,sp,-16
    80005ecc:	e422                	sd	s0,8(sp)
    80005ece:	0800                	addi	s0,sp,16
  // XXX need a PLIC_PRIORITY(irq) macro
  
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ed0:	0c0007b7          	lui	a5,0xc000
    80005ed4:	4705                	li	a4,1
    80005ed6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ed8:	c3d8                	sw	a4,4(a5)
    80005eda:	0791                	addi	a5,a5,4

  // PCIE IRQs are 32 to 35
  for(int irq = 1; irq < 0x35; irq++){
    *(uint32*)(PLIC + irq*4) = 1;
    80005edc:	4685                	li	a3,1
  for(int irq = 1; irq < 0x35; irq++){
    80005ede:	0c000737          	lui	a4,0xc000
    80005ee2:	0d470713          	addi	a4,a4,212 # c0000d4 <_entry-0x73ffff2c>
    *(uint32*)(PLIC + irq*4) = 1;
    80005ee6:	c394                	sw	a3,0(a5)
  for(int irq = 1; irq < 0x35; irq++){
    80005ee8:	0791                	addi	a5,a5,4
    80005eea:	fee79ee3          	bne	a5,a4,80005ee6 <plicinit+0x1c>
  }
}
    80005eee:	6422                	ld	s0,8(sp)
    80005ef0:	0141                	addi	sp,sp,16
    80005ef2:	8082                	ret

0000000080005ef4 <plicinithart>:

void
plicinithart(void)
{
    80005ef4:	1141                	addi	sp,sp,-16
    80005ef6:	e406                	sd	ra,8(sp)
    80005ef8:	e022                	sd	s0,0(sp)
    80005efa:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005efc:	ffffc097          	auipc	ra,0xffffc
    80005f00:	b7a080e7          	jalr	-1158(ra) # 80001a76 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  uint32 enabled = 0;
  enabled |= (1 << UART0_IRQ);
  enabled |= (1 << VIRTIO0_IRQ);
  *(uint32*)PLIC_SENABLE(hart) = enabled;
    80005f04:	0085171b          	slliw	a4,a0,0x8
    80005f08:	0c0027b7          	lui	a5,0xc002
    80005f0c:	97ba                	add	a5,a5,a4
    80005f0e:	40200713          	li	a4,1026
    80005f12:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // hack to get at next 32 IRQs for e1000
  *(uint32*)(PLIC_SENABLE(hart)+4) = 0xffffffff;
    80005f16:	577d                	li	a4,-1
    80005f18:	08e7a223          	sw	a4,132(a5)

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f1c:	00d5151b          	slliw	a0,a0,0xd
    80005f20:	0c2017b7          	lui	a5,0xc201
    80005f24:	953e                	add	a0,a0,a5
    80005f26:	00052023          	sw	zero,0(a0)
}
    80005f2a:	60a2                	ld	ra,8(sp)
    80005f2c:	6402                	ld	s0,0(sp)
    80005f2e:	0141                	addi	sp,sp,16
    80005f30:	8082                	ret

0000000080005f32 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f32:	1141                	addi	sp,sp,-16
    80005f34:	e406                	sd	ra,8(sp)
    80005f36:	e022                	sd	s0,0(sp)
    80005f38:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f3a:	ffffc097          	auipc	ra,0xffffc
    80005f3e:	b3c080e7          	jalr	-1220(ra) # 80001a76 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f42:	00d5179b          	slliw	a5,a0,0xd
    80005f46:	0c201537          	lui	a0,0xc201
    80005f4a:	953e                	add	a0,a0,a5
  return irq;
}
    80005f4c:	4148                	lw	a0,4(a0)
    80005f4e:	60a2                	ld	ra,8(sp)
    80005f50:	6402                	ld	s0,0(sp)
    80005f52:	0141                	addi	sp,sp,16
    80005f54:	8082                	ret

0000000080005f56 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f56:	1101                	addi	sp,sp,-32
    80005f58:	ec06                	sd	ra,24(sp)
    80005f5a:	e822                	sd	s0,16(sp)
    80005f5c:	e426                	sd	s1,8(sp)
    80005f5e:	1000                	addi	s0,sp,32
    80005f60:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f62:	ffffc097          	auipc	ra,0xffffc
    80005f66:	b14080e7          	jalr	-1260(ra) # 80001a76 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f6a:	00d5151b          	slliw	a0,a0,0xd
    80005f6e:	0c2017b7          	lui	a5,0xc201
    80005f72:	97aa                	add	a5,a5,a0
    80005f74:	c3c4                	sw	s1,4(a5)
}
    80005f76:	60e2                	ld	ra,24(sp)
    80005f78:	6442                	ld	s0,16(sp)
    80005f7a:	64a2                	ld	s1,8(sp)
    80005f7c:	6105                	addi	sp,sp,32
    80005f7e:	8082                	ret

0000000080005f80 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80005f80:	1141                	addi	sp,sp,-16
    80005f82:	e406                	sd	ra,8(sp)
    80005f84:	e022                	sd	s0,0(sp)
    80005f86:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f88:	479d                	li	a5,7
    80005f8a:	06b7c963          	blt	a5,a1,80005ffc <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80005f8e:	00151793          	slli	a5,a0,0x1
    80005f92:	97aa                	add	a5,a5,a0
    80005f94:	00c79713          	slli	a4,a5,0xc
    80005f98:	0001d797          	auipc	a5,0x1d
    80005f9c:	06878793          	addi	a5,a5,104 # 80023000 <disk>
    80005fa0:	97ba                	add	a5,a5,a4
    80005fa2:	97ae                	add	a5,a5,a1
    80005fa4:	6709                	lui	a4,0x2
    80005fa6:	97ba                	add	a5,a5,a4
    80005fa8:	0187c783          	lbu	a5,24(a5)
    80005fac:	e3a5                	bnez	a5,8000600c <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80005fae:	0001d817          	auipc	a6,0x1d
    80005fb2:	05280813          	addi	a6,a6,82 # 80023000 <disk>
    80005fb6:	00151693          	slli	a3,a0,0x1
    80005fba:	00a68733          	add	a4,a3,a0
    80005fbe:	0732                	slli	a4,a4,0xc
    80005fc0:	00e807b3          	add	a5,a6,a4
    80005fc4:	6709                	lui	a4,0x2
    80005fc6:	00f70633          	add	a2,a4,a5
    80005fca:	6210                	ld	a2,0(a2)
    80005fcc:	00459893          	slli	a7,a1,0x4
    80005fd0:	9646                	add	a2,a2,a7
    80005fd2:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    80005fd6:	97ae                	add	a5,a5,a1
    80005fd8:	97ba                	add	a5,a5,a4
    80005fda:	4605                	li	a2,1
    80005fdc:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    80005fe0:	96aa                	add	a3,a3,a0
    80005fe2:	06b2                	slli	a3,a3,0xc
    80005fe4:	0761                	addi	a4,a4,24
    80005fe6:	96ba                	add	a3,a3,a4
    80005fe8:	00d80533          	add	a0,a6,a3
    80005fec:	ffffc097          	auipc	ra,0xffffc
    80005ff0:	3f8080e7          	jalr	1016(ra) # 800023e4 <wakeup>
}
    80005ff4:	60a2                	ld	ra,8(sp)
    80005ff6:	6402                	ld	s0,0(sp)
    80005ff8:	0141                	addi	sp,sp,16
    80005ffa:	8082                	ret
    panic("virtio_disk_intr 1");
    80005ffc:	00004517          	auipc	a0,0x4
    80006000:	b0c50513          	addi	a0,a0,-1268 # 80009b08 <userret+0xa78>
    80006004:	ffffa097          	auipc	ra,0xffffa
    80006008:	556080e7          	jalr	1366(ra) # 8000055a <panic>
    panic("virtio_disk_intr 2");
    8000600c:	00004517          	auipc	a0,0x4
    80006010:	b1450513          	addi	a0,a0,-1260 # 80009b20 <userret+0xa90>
    80006014:	ffffa097          	auipc	ra,0xffffa
    80006018:	546080e7          	jalr	1350(ra) # 8000055a <panic>

000000008000601c <virtio_disk_init>:
  __sync_synchronize();
    8000601c:	0ff0000f          	fence
  if(disk[n].init)
    80006020:	00151793          	slli	a5,a0,0x1
    80006024:	97aa                	add	a5,a5,a0
    80006026:	07b2                	slli	a5,a5,0xc
    80006028:	0001d717          	auipc	a4,0x1d
    8000602c:	fd870713          	addi	a4,a4,-40 # 80023000 <disk>
    80006030:	973e                	add	a4,a4,a5
    80006032:	6789                	lui	a5,0x2
    80006034:	97ba                	add	a5,a5,a4
    80006036:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    8000603a:	c391                	beqz	a5,8000603e <virtio_disk_init+0x22>
    8000603c:	8082                	ret
{
    8000603e:	7139                	addi	sp,sp,-64
    80006040:	fc06                	sd	ra,56(sp)
    80006042:	f822                	sd	s0,48(sp)
    80006044:	f426                	sd	s1,40(sp)
    80006046:	f04a                	sd	s2,32(sp)
    80006048:	ec4e                	sd	s3,24(sp)
    8000604a:	e852                	sd	s4,16(sp)
    8000604c:	e456                	sd	s5,8(sp)
    8000604e:	0080                	addi	s0,sp,64
    80006050:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    80006052:	85aa                	mv	a1,a0
    80006054:	00004517          	auipc	a0,0x4
    80006058:	ae450513          	addi	a0,a0,-1308 # 80009b38 <userret+0xaa8>
    8000605c:	ffffa097          	auipc	ra,0xffffa
    80006060:	558080e7          	jalr	1368(ra) # 800005b4 <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    80006064:	00149993          	slli	s3,s1,0x1
    80006068:	99a6                	add	s3,s3,s1
    8000606a:	09b2                	slli	s3,s3,0xc
    8000606c:	6789                	lui	a5,0x2
    8000606e:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    80006072:	97ce                	add	a5,a5,s3
    80006074:	00004597          	auipc	a1,0x4
    80006078:	adc58593          	addi	a1,a1,-1316 # 80009b50 <userret+0xac0>
    8000607c:	0001d517          	auipc	a0,0x1d
    80006080:	f8450513          	addi	a0,a0,-124 # 80023000 <disk>
    80006084:	953e                	add	a0,a0,a5
    80006086:	ffffb097          	auipc	ra,0xffffb
    8000608a:	952080e7          	jalr	-1710(ra) # 800009d8 <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000608e:	0014891b          	addiw	s2,s1,1
    80006092:	00c9191b          	slliw	s2,s2,0xc
    80006096:	100007b7          	lui	a5,0x10000
    8000609a:	97ca                	add	a5,a5,s2
    8000609c:	4398                	lw	a4,0(a5)
    8000609e:	2701                	sext.w	a4,a4
    800060a0:	747277b7          	lui	a5,0x74727
    800060a4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800060a8:	12f71663          	bne	a4,a5,800061d4 <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    800060ac:	100007b7          	lui	a5,0x10000
    800060b0:	0791                	addi	a5,a5,4
    800060b2:	97ca                	add	a5,a5,s2
    800060b4:	439c                	lw	a5,0(a5)
    800060b6:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060b8:	4705                	li	a4,1
    800060ba:	10e79d63          	bne	a5,a4,800061d4 <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060be:	100007b7          	lui	a5,0x10000
    800060c2:	07a1                	addi	a5,a5,8
    800060c4:	97ca                	add	a5,a5,s2
    800060c6:	439c                	lw	a5,0(a5)
    800060c8:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    800060ca:	4709                	li	a4,2
    800060cc:	10e79463          	bne	a5,a4,800061d4 <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800060d0:	100007b7          	lui	a5,0x10000
    800060d4:	07b1                	addi	a5,a5,12
    800060d6:	97ca                	add	a5,a5,s2
    800060d8:	4398                	lw	a4,0(a5)
    800060da:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060dc:	554d47b7          	lui	a5,0x554d4
    800060e0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060e4:	0ef71863          	bne	a4,a5,800061d4 <virtio_disk_init+0x1b8>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800060e8:	100007b7          	lui	a5,0x10000
    800060ec:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    800060f0:	96ca                	add	a3,a3,s2
    800060f2:	4705                	li	a4,1
    800060f4:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800060f6:	470d                	li	a4,3
    800060f8:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    800060fa:	01078713          	addi	a4,a5,16
    800060fe:	974a                	add	a4,a4,s2
    80006100:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006102:	02078613          	addi	a2,a5,32
    80006106:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006108:	c7ffe737          	lui	a4,0xc7ffe
    8000610c:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd5393>
    80006110:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006112:	2701                	sext.w	a4,a4
    80006114:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80006116:	472d                	li	a4,11
    80006118:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000611a:	473d                	li	a4,15
    8000611c:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000611e:	02878713          	addi	a4,a5,40
    80006122:	974a                	add	a4,a4,s2
    80006124:	6685                	lui	a3,0x1
    80006126:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006128:	03078713          	addi	a4,a5,48
    8000612c:	974a                	add	a4,a4,s2
    8000612e:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006132:	03478793          	addi	a5,a5,52
    80006136:	97ca                	add	a5,a5,s2
    80006138:	439c                	lw	a5,0(a5)
    8000613a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000613c:	c7c5                	beqz	a5,800061e4 <virtio_disk_init+0x1c8>
  if(max < NUM)
    8000613e:	471d                	li	a4,7
    80006140:	0af77a63          	bgeu	a4,a5,800061f4 <virtio_disk_init+0x1d8>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006144:	10000ab7          	lui	s5,0x10000
    80006148:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    8000614c:	97ca                	add	a5,a5,s2
    8000614e:	4721                	li	a4,8
    80006150:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    80006152:	0001da17          	auipc	s4,0x1d
    80006156:	eaea0a13          	addi	s4,s4,-338 # 80023000 <disk>
    8000615a:	99d2                	add	s3,s3,s4
    8000615c:	6609                	lui	a2,0x2
    8000615e:	4581                	li	a1,0
    80006160:	854e                	mv	a0,s3
    80006162:	ffffb097          	auipc	ra,0xffffb
    80006166:	c18080e7          	jalr	-1000(ra) # 80000d7a <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    8000616a:	040a8a93          	addi	s5,s5,64
    8000616e:	9956                	add	s2,s2,s5
    80006170:	00c9d793          	srli	a5,s3,0xc
    80006174:	2781                	sext.w	a5,a5
    80006176:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    8000617a:	00149513          	slli	a0,s1,0x1
    8000617e:	009507b3          	add	a5,a0,s1
    80006182:	07b2                	slli	a5,a5,0xc
    80006184:	97d2                	add	a5,a5,s4
    80006186:	6689                	lui	a3,0x2
    80006188:	97b6                	add	a5,a5,a3
    8000618a:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    8000618e:	08098713          	addi	a4,s3,128
    80006192:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    80006194:	6705                	lui	a4,0x1
    80006196:	99ba                	add	s3,s3,a4
    80006198:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    8000619c:	4705                	li	a4,1
    8000619e:	00e78c23          	sb	a4,24(a5)
    800061a2:	00e78ca3          	sb	a4,25(a5)
    800061a6:	00e78d23          	sb	a4,26(a5)
    800061aa:	00e78da3          	sb	a4,27(a5)
    800061ae:	00e78e23          	sb	a4,28(a5)
    800061b2:	00e78ea3          	sb	a4,29(a5)
    800061b6:	00e78f23          	sb	a4,30(a5)
    800061ba:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    800061be:	0ae7a423          	sw	a4,168(a5)
}
    800061c2:	70e2                	ld	ra,56(sp)
    800061c4:	7442                	ld	s0,48(sp)
    800061c6:	74a2                	ld	s1,40(sp)
    800061c8:	7902                	ld	s2,32(sp)
    800061ca:	69e2                	ld	s3,24(sp)
    800061cc:	6a42                	ld	s4,16(sp)
    800061ce:	6aa2                	ld	s5,8(sp)
    800061d0:	6121                	addi	sp,sp,64
    800061d2:	8082                	ret
    panic("could not find virtio disk");
    800061d4:	00004517          	auipc	a0,0x4
    800061d8:	98c50513          	addi	a0,a0,-1652 # 80009b60 <userret+0xad0>
    800061dc:	ffffa097          	auipc	ra,0xffffa
    800061e0:	37e080e7          	jalr	894(ra) # 8000055a <panic>
    panic("virtio disk has no queue 0");
    800061e4:	00004517          	auipc	a0,0x4
    800061e8:	99c50513          	addi	a0,a0,-1636 # 80009b80 <userret+0xaf0>
    800061ec:	ffffa097          	auipc	ra,0xffffa
    800061f0:	36e080e7          	jalr	878(ra) # 8000055a <panic>
    panic("virtio disk max queue too short");
    800061f4:	00004517          	auipc	a0,0x4
    800061f8:	9ac50513          	addi	a0,a0,-1620 # 80009ba0 <userret+0xb10>
    800061fc:	ffffa097          	auipc	ra,0xffffa
    80006200:	35e080e7          	jalr	862(ra) # 8000055a <panic>

0000000080006204 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    80006204:	7135                	addi	sp,sp,-160
    80006206:	ed06                	sd	ra,152(sp)
    80006208:	e922                	sd	s0,144(sp)
    8000620a:	e526                	sd	s1,136(sp)
    8000620c:	e14a                	sd	s2,128(sp)
    8000620e:	fcce                	sd	s3,120(sp)
    80006210:	f8d2                	sd	s4,112(sp)
    80006212:	f4d6                	sd	s5,104(sp)
    80006214:	f0da                	sd	s6,96(sp)
    80006216:	ecde                	sd	s7,88(sp)
    80006218:	e8e2                	sd	s8,80(sp)
    8000621a:	e4e6                	sd	s9,72(sp)
    8000621c:	e0ea                	sd	s10,64(sp)
    8000621e:	fc6e                	sd	s11,56(sp)
    80006220:	1100                	addi	s0,sp,160
    80006222:	892a                	mv	s2,a0
    80006224:	89ae                	mv	s3,a1
    80006226:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    80006228:	45dc                	lw	a5,12(a1)
    8000622a:	0017979b          	slliw	a5,a5,0x1
    8000622e:	1782                	slli	a5,a5,0x20
    80006230:	9381                	srli	a5,a5,0x20
    80006232:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    80006236:	00151493          	slli	s1,a0,0x1
    8000623a:	94aa                	add	s1,s1,a0
    8000623c:	04b2                	slli	s1,s1,0xc
    8000623e:	6a89                	lui	s5,0x2
    80006240:	0b0a8a13          	addi	s4,s5,176 # 20b0 <_entry-0x7fffdf50>
    80006244:	9a26                	add	s4,s4,s1
    80006246:	0001db97          	auipc	s7,0x1d
    8000624a:	dbab8b93          	addi	s7,s7,-582 # 80023000 <disk>
    8000624e:	9a5e                	add	s4,s4,s7
    80006250:	8552                	mv	a0,s4
    80006252:	ffffb097          	auipc	ra,0xffffb
    80006256:	85a080e7          	jalr	-1958(ra) # 80000aac <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    8000625a:	0ae1                	addi	s5,s5,24
    8000625c:	94d6                	add	s1,s1,s5
    8000625e:	01748ab3          	add	s5,s1,s7
    80006262:	8d56                	mv	s10,s5
  for(int i = 0; i < 3; i++){
    80006264:	4b81                	li	s7,0
  for(int i = 0; i < NUM; i++){
    80006266:	4ca1                	li	s9,8
      disk[n].free[i] = 0;
    80006268:	00191b13          	slli	s6,s2,0x1
    8000626c:	9b4a                	add	s6,s6,s2
    8000626e:	00cb1793          	slli	a5,s6,0xc
    80006272:	0001db17          	auipc	s6,0x1d
    80006276:	d8eb0b13          	addi	s6,s6,-626 # 80023000 <disk>
    8000627a:	9b3e                	add	s6,s6,a5
  for(int i = 0; i < NUM; i++){
    8000627c:	8c5e                	mv	s8,s7
    8000627e:	a8ad                	j	800062f8 <virtio_disk_rw+0xf4>
      disk[n].free[i] = 0;
    80006280:	00fb06b3          	add	a3,s6,a5
    80006284:	96aa                	add	a3,a3,a0
    80006286:	00068c23          	sb	zero,24(a3) # 2018 <_entry-0x7fffdfe8>
    idx[i] = alloc_desc(n);
    8000628a:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000628c:	0207c363          	bltz	a5,800062b2 <virtio_disk_rw+0xae>
  for(int i = 0; i < 3; i++){
    80006290:	2485                	addiw	s1,s1,1
    80006292:	0711                	addi	a4,a4,4
    80006294:	1eb48363          	beq	s1,a1,8000647a <virtio_disk_rw+0x276>
    idx[i] = alloc_desc(n);
    80006298:	863a                	mv	a2,a4
    8000629a:	86ea                	mv	a3,s10
  for(int i = 0; i < NUM; i++){
    8000629c:	87e2                	mv	a5,s8
    if(disk[n].free[i]){
    8000629e:	0006c803          	lbu	a6,0(a3)
    800062a2:	fc081fe3          	bnez	a6,80006280 <virtio_disk_rw+0x7c>
  for(int i = 0; i < NUM; i++){
    800062a6:	2785                	addiw	a5,a5,1
    800062a8:	0685                	addi	a3,a3,1
    800062aa:	ff979ae3          	bne	a5,s9,8000629e <virtio_disk_rw+0x9a>
    idx[i] = alloc_desc(n);
    800062ae:	57fd                	li	a5,-1
    800062b0:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800062b2:	02905d63          	blez	s1,800062ec <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    800062b6:	f8042583          	lw	a1,-128(s0)
    800062ba:	854a                	mv	a0,s2
    800062bc:	00000097          	auipc	ra,0x0
    800062c0:	cc4080e7          	jalr	-828(ra) # 80005f80 <free_desc>
      for(int j = 0; j < i; j++)
    800062c4:	4785                	li	a5,1
    800062c6:	0297d363          	bge	a5,s1,800062ec <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    800062ca:	f8442583          	lw	a1,-124(s0)
    800062ce:	854a                	mv	a0,s2
    800062d0:	00000097          	auipc	ra,0x0
    800062d4:	cb0080e7          	jalr	-848(ra) # 80005f80 <free_desc>
      for(int j = 0; j < i; j++)
    800062d8:	4789                	li	a5,2
    800062da:	0097d963          	bge	a5,s1,800062ec <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    800062de:	f8842583          	lw	a1,-120(s0)
    800062e2:	854a                	mv	a0,s2
    800062e4:	00000097          	auipc	ra,0x0
    800062e8:	c9c080e7          	jalr	-868(ra) # 80005f80 <free_desc>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    800062ec:	85d2                	mv	a1,s4
    800062ee:	8556                	mv	a0,s5
    800062f0:	ffffc097          	auipc	ra,0xffffc
    800062f4:	f6e080e7          	jalr	-146(ra) # 8000225e <sleep>
  for(int i = 0; i < 3; i++){
    800062f8:	f8040713          	addi	a4,s0,-128
    800062fc:	84de                	mv	s1,s7
      disk[n].free[i] = 0;
    800062fe:	6509                	lui	a0,0x2
  for(int i = 0; i < 3; i++){
    80006300:	458d                	li	a1,3
    80006302:	bf59                	j	80006298 <virtio_disk_rw+0x94>
  disk[n].desc[idx[0]].next = idx[1];

  disk[n].desc[idx[1]].addr = (uint64) b->data;
  disk[n].desc[idx[1]].len = BSIZE;
  if(write)
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    80006304:	00191793          	slli	a5,s2,0x1
    80006308:	97ca                	add	a5,a5,s2
    8000630a:	07b2                	slli	a5,a5,0xc
    8000630c:	0001d717          	auipc	a4,0x1d
    80006310:	cf470713          	addi	a4,a4,-780 # 80023000 <disk>
    80006314:	973e                	add	a4,a4,a5
    80006316:	6789                	lui	a5,0x2
    80006318:	97ba                	add	a5,a5,a4
    8000631a:	639c                	ld	a5,0(a5)
    8000631c:	97b6                	add	a5,a5,a3
    8000631e:	00079623          	sh	zero,12(a5) # 200c <_entry-0x7fffdff4>
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006322:	0001d517          	auipc	a0,0x1d
    80006326:	cde50513          	addi	a0,a0,-802 # 80023000 <disk>
    8000632a:	00191793          	slli	a5,s2,0x1
    8000632e:	01278733          	add	a4,a5,s2
    80006332:	0732                	slli	a4,a4,0xc
    80006334:	972a                	add	a4,a4,a0
    80006336:	6609                	lui	a2,0x2
    80006338:	9732                	add	a4,a4,a2
    8000633a:	630c                	ld	a1,0(a4)
    8000633c:	95b6                	add	a1,a1,a3
    8000633e:	00c5d603          	lhu	a2,12(a1)
    80006342:	00166613          	ori	a2,a2,1
    80006346:	00c59623          	sh	a2,12(a1)
  disk[n].desc[idx[1]].next = idx[2];
    8000634a:	f8842603          	lw	a2,-120(s0)
    8000634e:	630c                	ld	a1,0(a4)
    80006350:	96ae                	add	a3,a3,a1
    80006352:	00c69723          	sh	a2,14(a3)

  disk[n].info[idx[0]].status = 0;
    80006356:	97ca                	add	a5,a5,s2
    80006358:	07a2                	slli	a5,a5,0x8
    8000635a:	97a6                	add	a5,a5,s1
    8000635c:	20078793          	addi	a5,a5,512
    80006360:	0792                	slli	a5,a5,0x4
    80006362:	97aa                	add	a5,a5,a0
    80006364:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    80006368:	00461693          	slli	a3,a2,0x4
    8000636c:	00073803          	ld	a6,0(a4)
    80006370:	9836                	add	a6,a6,a3
    80006372:	20348613          	addi	a2,s1,515
    80006376:	00191593          	slli	a1,s2,0x1
    8000637a:	95ca                	add	a1,a1,s2
    8000637c:	05a2                	slli	a1,a1,0x8
    8000637e:	962e                	add	a2,a2,a1
    80006380:	0612                	slli	a2,a2,0x4
    80006382:	962a                	add	a2,a2,a0
    80006384:	00c83023          	sd	a2,0(a6)
  disk[n].desc[idx[2]].len = 1;
    80006388:	630c                	ld	a1,0(a4)
    8000638a:	95b6                	add	a1,a1,a3
    8000638c:	4605                	li	a2,1
    8000638e:	c590                	sw	a2,8(a1)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006390:	630c                	ld	a1,0(a4)
    80006392:	95b6                	add	a1,a1,a3
    80006394:	4509                	li	a0,2
    80006396:	00a59623          	sh	a0,12(a1)
  disk[n].desc[idx[2]].next = 0;
    8000639a:	630c                	ld	a1,0(a4)
    8000639c:	96ae                	add	a3,a3,a1
    8000639e:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800063a2:	00c9a223          	sw	a2,4(s3)
  disk[n].info[idx[0]].b = b;
    800063a6:	0337b423          	sd	s3,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    800063aa:	6714                	ld	a3,8(a4)
    800063ac:	0026d783          	lhu	a5,2(a3)
    800063b0:	8b9d                	andi	a5,a5,7
    800063b2:	0789                	addi	a5,a5,2
    800063b4:	0786                	slli	a5,a5,0x1
    800063b6:	97b6                	add	a5,a5,a3
    800063b8:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    800063bc:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    800063c0:	6718                	ld	a4,8(a4)
    800063c2:	00275783          	lhu	a5,2(a4)
    800063c6:	2785                	addiw	a5,a5,1
    800063c8:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800063cc:	0019079b          	addiw	a5,s2,1
    800063d0:	00c7979b          	slliw	a5,a5,0xc
    800063d4:	10000737          	lui	a4,0x10000
    800063d8:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    800063dc:	97ba                	add	a5,a5,a4
    800063de:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800063e2:	0049a783          	lw	a5,4(s3)
    800063e6:	00c79d63          	bne	a5,a2,80006400 <virtio_disk_rw+0x1fc>
    800063ea:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    800063ec:	85d2                	mv	a1,s4
    800063ee:	854e                	mv	a0,s3
    800063f0:	ffffc097          	auipc	ra,0xffffc
    800063f4:	e6e080e7          	jalr	-402(ra) # 8000225e <sleep>
  while(b->disk == 1) {
    800063f8:	0049a783          	lw	a5,4(s3)
    800063fc:	fe9788e3          	beq	a5,s1,800063ec <virtio_disk_rw+0x1e8>
  }

  disk[n].info[idx[0]].b = 0;
    80006400:	f8042483          	lw	s1,-128(s0)
    80006404:	00191793          	slli	a5,s2,0x1
    80006408:	97ca                	add	a5,a5,s2
    8000640a:	07a2                	slli	a5,a5,0x8
    8000640c:	97a6                	add	a5,a5,s1
    8000640e:	20078793          	addi	a5,a5,512
    80006412:	0792                	slli	a5,a5,0x4
    80006414:	0001d717          	auipc	a4,0x1d
    80006418:	bec70713          	addi	a4,a4,-1044 # 80023000 <disk>
    8000641c:	97ba                	add	a5,a5,a4
    8000641e:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006422:	00191793          	slli	a5,s2,0x1
    80006426:	97ca                	add	a5,a5,s2
    80006428:	07b2                	slli	a5,a5,0xc
    8000642a:	97ba                	add	a5,a5,a4
    8000642c:	6989                	lui	s3,0x2
    8000642e:	99be                	add	s3,s3,a5
    free_desc(n, i);
    80006430:	85a6                	mv	a1,s1
    80006432:	854a                	mv	a0,s2
    80006434:	00000097          	auipc	ra,0x0
    80006438:	b4c080e7          	jalr	-1204(ra) # 80005f80 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    8000643c:	0492                	slli	s1,s1,0x4
    8000643e:	0009b783          	ld	a5,0(s3) # 2000 <_entry-0x7fffe000>
    80006442:	94be                	add	s1,s1,a5
    80006444:	00c4d783          	lhu	a5,12(s1)
    80006448:	8b85                	andi	a5,a5,1
    8000644a:	c781                	beqz	a5,80006452 <virtio_disk_rw+0x24e>
      i = disk[n].desc[i].next;
    8000644c:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    80006450:	b7c5                	j	80006430 <virtio_disk_rw+0x22c>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    80006452:	8552                	mv	a0,s4
    80006454:	ffffa097          	auipc	ra,0xffffa
    80006458:	728080e7          	jalr	1832(ra) # 80000b7c <release>
}
    8000645c:	60ea                	ld	ra,152(sp)
    8000645e:	644a                	ld	s0,144(sp)
    80006460:	64aa                	ld	s1,136(sp)
    80006462:	690a                	ld	s2,128(sp)
    80006464:	79e6                	ld	s3,120(sp)
    80006466:	7a46                	ld	s4,112(sp)
    80006468:	7aa6                	ld	s5,104(sp)
    8000646a:	7b06                	ld	s6,96(sp)
    8000646c:	6be6                	ld	s7,88(sp)
    8000646e:	6c46                	ld	s8,80(sp)
    80006470:	6ca6                	ld	s9,72(sp)
    80006472:	6d06                	ld	s10,64(sp)
    80006474:	7de2                	ld	s11,56(sp)
    80006476:	610d                	addi	sp,sp,160
    80006478:	8082                	ret
  if(write)
    8000647a:	01b037b3          	snez	a5,s11
    8000647e:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006482:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006486:	f6843783          	ld	a5,-152(s0)
    8000648a:	f6f43c23          	sd	a5,-136(s0)
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    8000648e:	f8042483          	lw	s1,-128(s0)
    80006492:	00449b13          	slli	s6,s1,0x4
    80006496:	00191793          	slli	a5,s2,0x1
    8000649a:	97ca                	add	a5,a5,s2
    8000649c:	07b2                	slli	a5,a5,0xc
    8000649e:	0001da97          	auipc	s5,0x1d
    800064a2:	b62a8a93          	addi	s5,s5,-1182 # 80023000 <disk>
    800064a6:	97d6                	add	a5,a5,s5
    800064a8:	6a89                	lui	s5,0x2
    800064aa:	9abe                	add	s5,s5,a5
    800064ac:	000abb83          	ld	s7,0(s5) # 2000 <_entry-0x7fffe000>
    800064b0:	9bda                	add	s7,s7,s6
    800064b2:	f7040513          	addi	a0,s0,-144
    800064b6:	ffffb097          	auipc	ra,0xffffb
    800064ba:	d14080e7          	jalr	-748(ra) # 800011ca <kvmpa>
    800064be:	00abb023          	sd	a0,0(s7)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    800064c2:	000ab783          	ld	a5,0(s5)
    800064c6:	97da                	add	a5,a5,s6
    800064c8:	4741                	li	a4,16
    800064ca:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800064cc:	000ab783          	ld	a5,0(s5)
    800064d0:	97da                	add	a5,a5,s6
    800064d2:	4705                	li	a4,1
    800064d4:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    800064d8:	f8442683          	lw	a3,-124(s0)
    800064dc:	000ab783          	ld	a5,0(s5)
    800064e0:	9b3e                	add	s6,s6,a5
    800064e2:	00db1723          	sh	a3,14(s6)
  disk[n].desc[idx[1]].addr = (uint64) b->data;
    800064e6:	0692                	slli	a3,a3,0x4
    800064e8:	000ab783          	ld	a5,0(s5)
    800064ec:	97b6                	add	a5,a5,a3
    800064ee:	06098713          	addi	a4,s3,96
    800064f2:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    800064f4:	000ab783          	ld	a5,0(s5)
    800064f8:	97b6                	add	a5,a5,a3
    800064fa:	40000713          	li	a4,1024
    800064fe:	c798                	sw	a4,8(a5)
  if(write)
    80006500:	e00d92e3          	bnez	s11,80006304 <virtio_disk_rw+0x100>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006504:	00191793          	slli	a5,s2,0x1
    80006508:	97ca                	add	a5,a5,s2
    8000650a:	07b2                	slli	a5,a5,0xc
    8000650c:	0001d717          	auipc	a4,0x1d
    80006510:	af470713          	addi	a4,a4,-1292 # 80023000 <disk>
    80006514:	973e                	add	a4,a4,a5
    80006516:	6789                	lui	a5,0x2
    80006518:	97ba                	add	a5,a5,a4
    8000651a:	639c                	ld	a5,0(a5)
    8000651c:	97b6                	add	a5,a5,a3
    8000651e:	4709                	li	a4,2
    80006520:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    80006524:	bbfd                	j	80006322 <virtio_disk_rw+0x11e>

0000000080006526 <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    80006526:	7139                	addi	sp,sp,-64
    80006528:	fc06                	sd	ra,56(sp)
    8000652a:	f822                	sd	s0,48(sp)
    8000652c:	f426                	sd	s1,40(sp)
    8000652e:	f04a                	sd	s2,32(sp)
    80006530:	ec4e                	sd	s3,24(sp)
    80006532:	e852                	sd	s4,16(sp)
    80006534:	e456                	sd	s5,8(sp)
    80006536:	0080                	addi	s0,sp,64
    80006538:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    8000653a:	00151913          	slli	s2,a0,0x1
    8000653e:	00a90a33          	add	s4,s2,a0
    80006542:	0a32                	slli	s4,s4,0xc
    80006544:	6989                	lui	s3,0x2
    80006546:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    8000654a:	9a3e                	add	s4,s4,a5
    8000654c:	0001da97          	auipc	s5,0x1d
    80006550:	ab4a8a93          	addi	s5,s5,-1356 # 80023000 <disk>
    80006554:	9a56                	add	s4,s4,s5
    80006556:	8552                	mv	a0,s4
    80006558:	ffffa097          	auipc	ra,0xffffa
    8000655c:	554080e7          	jalr	1364(ra) # 80000aac <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006560:	9926                	add	s2,s2,s1
    80006562:	0932                	slli	s2,s2,0xc
    80006564:	9956                	add	s2,s2,s5
    80006566:	99ca                	add	s3,s3,s2
    80006568:	0209d783          	lhu	a5,32(s3)
    8000656c:	0109b703          	ld	a4,16(s3)
    80006570:	00275683          	lhu	a3,2(a4)
    80006574:	8ebd                	xor	a3,a3,a5
    80006576:	8a9d                	andi	a3,a3,7
    80006578:	c2a5                	beqz	a3,800065d8 <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    8000657a:	8956                	mv	s2,s5
    8000657c:	00149693          	slli	a3,s1,0x1
    80006580:	96a6                	add	a3,a3,s1
    80006582:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006586:	06b2                	slli	a3,a3,0xc
    80006588:	96d6                	add	a3,a3,s5
    8000658a:	6489                	lui	s1,0x2
    8000658c:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    8000658e:	078e                	slli	a5,a5,0x3
    80006590:	97ba                	add	a5,a5,a4
    80006592:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    80006594:	00f98733          	add	a4,s3,a5
    80006598:	20070713          	addi	a4,a4,512
    8000659c:	0712                	slli	a4,a4,0x4
    8000659e:	974a                	add	a4,a4,s2
    800065a0:	03074703          	lbu	a4,48(a4)
    800065a4:	eb21                	bnez	a4,800065f4 <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    800065a6:	97ce                	add	a5,a5,s3
    800065a8:	20078793          	addi	a5,a5,512
    800065ac:	0792                	slli	a5,a5,0x4
    800065ae:	97ca                	add	a5,a5,s2
    800065b0:	7798                	ld	a4,40(a5)
    800065b2:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    800065b6:	7788                	ld	a0,40(a5)
    800065b8:	ffffc097          	auipc	ra,0xffffc
    800065bc:	e2c080e7          	jalr	-468(ra) # 800023e4 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    800065c0:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    800065c4:	2785                	addiw	a5,a5,1
    800065c6:	8b9d                	andi	a5,a5,7
    800065c8:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    800065cc:	6898                	ld	a4,16(s1)
    800065ce:	00275683          	lhu	a3,2(a4)
    800065d2:	8a9d                	andi	a3,a3,7
    800065d4:	faf69de3          	bne	a3,a5,8000658e <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    800065d8:	8552                	mv	a0,s4
    800065da:	ffffa097          	auipc	ra,0xffffa
    800065de:	5a2080e7          	jalr	1442(ra) # 80000b7c <release>
}
    800065e2:	70e2                	ld	ra,56(sp)
    800065e4:	7442                	ld	s0,48(sp)
    800065e6:	74a2                	ld	s1,40(sp)
    800065e8:	7902                	ld	s2,32(sp)
    800065ea:	69e2                	ld	s3,24(sp)
    800065ec:	6a42                	ld	s4,16(sp)
    800065ee:	6aa2                	ld	s5,8(sp)
    800065f0:	6121                	addi	sp,sp,64
    800065f2:	8082                	ret
      panic("virtio_disk_intr status");
    800065f4:	00003517          	auipc	a0,0x3
    800065f8:	5cc50513          	addi	a0,a0,1484 # 80009bc0 <userret+0xb30>
    800065fc:	ffffa097          	auipc	ra,0xffffa
    80006600:	f5e080e7          	jalr	-162(ra) # 8000055a <panic>

0000000080006604 <e1000_init>:
// called by pci_init().
// xregs is the memory address at which the
// e1000's registers are mapped.
void
e1000_init(uint32 *xregs)
{
    80006604:	7179                	addi	sp,sp,-48
    80006606:	f406                	sd	ra,40(sp)
    80006608:	f022                	sd	s0,32(sp)
    8000660a:	ec26                	sd	s1,24(sp)
    8000660c:	e84a                	sd	s2,16(sp)
    8000660e:	e44e                	sd	s3,8(sp)
    80006610:	1800                	addi	s0,sp,48
    80006612:	84aa                	mv	s1,a0
  int i;

  initlock(&e1000_lock_rx, "e1000rx");
    80006614:	00003597          	auipc	a1,0x3
    80006618:	5c458593          	addi	a1,a1,1476 # 80009bd8 <userret+0xb48>
    8000661c:	00023517          	auipc	a0,0x23
    80006620:	9e450513          	addi	a0,a0,-1564 # 80029000 <e1000_lock_rx>
    80006624:	ffffa097          	auipc	ra,0xffffa
    80006628:	3b4080e7          	jalr	948(ra) # 800009d8 <initlock>
  initlock(&e1000_lock_tx, "e1000dx");
    8000662c:	00003597          	auipc	a1,0x3
    80006630:	5b458593          	addi	a1,a1,1460 # 80009be0 <userret+0xb50>
    80006634:	00023517          	auipc	a0,0x23
    80006638:	9ec50513          	addi	a0,a0,-1556 # 80029020 <e1000_lock_tx>
    8000663c:	ffffa097          	auipc	ra,0xffffa
    80006640:	39c080e7          	jalr	924(ra) # 800009d8 <initlock>

  regs = xregs;
    80006644:	00023797          	auipc	a5,0x23
    80006648:	d697b223          	sd	s1,-668(a5) # 800293a8 <regs>

  // Reset the device
  regs[E1000_IMS] = 0; // disable interrupts
    8000664c:	0c04a823          	sw	zero,208(s1)
  regs[E1000_CTL] |= E1000_CTL_RST;
    80006650:	409c                	lw	a5,0(s1)
    80006652:	2781                	sext.w	a5,a5
    80006654:	00400737          	lui	a4,0x400
    80006658:	8fd9                	or	a5,a5,a4
    8000665a:	c09c                	sw	a5,0(s1)
  regs[E1000_IMS] = 0; // redisable interrupts
    8000665c:	0c04a823          	sw	zero,208(s1)
  __sync_synchronize();
    80006660:	0ff0000f          	fence

  // [E1000 14.5] Transmit initialization
  memset(tx_ring, 0, sizeof(tx_ring));
    80006664:	10000613          	li	a2,256
    80006668:	4581                	li	a1,0
    8000666a:	00023517          	auipc	a0,0x23
    8000666e:	9d650513          	addi	a0,a0,-1578 # 80029040 <tx_ring>
    80006672:	ffffa097          	auipc	ra,0xffffa
    80006676:	708080e7          	jalr	1800(ra) # 80000d7a <memset>
  for (i = 0; i < TX_RING_SIZE; i++) {
    8000667a:	00023717          	auipc	a4,0x23
    8000667e:	9d270713          	addi	a4,a4,-1582 # 8002904c <tx_ring+0xc>
    80006682:	00023797          	auipc	a5,0x23
    80006686:	abe78793          	addi	a5,a5,-1346 # 80029140 <tx_mbufs>
    8000668a:	00023617          	auipc	a2,0x23
    8000668e:	b3660613          	addi	a2,a2,-1226 # 800291c0 <rx_ring>
    tx_ring[i].status = E1000_TXD_STAT_DD;
    80006692:	4685                	li	a3,1
    80006694:	00d70023          	sb	a3,0(a4)
    tx_mbufs[i] = 0;
    80006698:	0007b023          	sd	zero,0(a5)
  for (i = 0; i < TX_RING_SIZE; i++) {
    8000669c:	0741                	addi	a4,a4,16
    8000669e:	07a1                	addi	a5,a5,8
    800066a0:	fec79ae3          	bne	a5,a2,80006694 <e1000_init+0x90>
  }
  regs[E1000_TDBAL] = (uint64) tx_ring;
    800066a4:	00023717          	auipc	a4,0x23
    800066a8:	99c70713          	addi	a4,a4,-1636 # 80029040 <tx_ring>
    800066ac:	00023797          	auipc	a5,0x23
    800066b0:	cfc7b783          	ld	a5,-772(a5) # 800293a8 <regs>
    800066b4:	6691                	lui	a3,0x4
    800066b6:	97b6                	add	a5,a5,a3
    800066b8:	80e7a023          	sw	a4,-2048(a5)
  if(sizeof(tx_ring) % 128 != 0)
    panic("e1000");
  regs[E1000_TDLEN] = sizeof(tx_ring);
    800066bc:	10000713          	li	a4,256
    800066c0:	80e7a423          	sw	a4,-2040(a5)
  regs[E1000_TDH] = regs[E1000_TDT] = 0;
    800066c4:	8007ac23          	sw	zero,-2024(a5)
    800066c8:	8007a823          	sw	zero,-2032(a5)

  // [E1000 14.4] Receive initialization
  memset(rx_ring, 0, sizeof(rx_ring));
    800066cc:	00023917          	auipc	s2,0x23
    800066d0:	af490913          	addi	s2,s2,-1292 # 800291c0 <rx_ring>
    800066d4:	10000613          	li	a2,256
    800066d8:	4581                	li	a1,0
    800066da:	854a                	mv	a0,s2
    800066dc:	ffffa097          	auipc	ra,0xffffa
    800066e0:	69e080e7          	jalr	1694(ra) # 80000d7a <memset>
  for (i = 0; i < RX_RING_SIZE; i++) {
    800066e4:	00023497          	auipc	s1,0x23
    800066e8:	bdc48493          	addi	s1,s1,-1060 # 800292c0 <rx_mbufs>
    800066ec:	00023997          	auipc	s3,0x23
    800066f0:	c5498993          	addi	s3,s3,-940 # 80029340 <lock>
    rx_mbufs[i] = mbufalloc(0);
    800066f4:	4501                	li	a0,0
    800066f6:	00000097          	auipc	ra,0x0
    800066fa:	49e080e7          	jalr	1182(ra) # 80006b94 <mbufalloc>
    800066fe:	e088                	sd	a0,0(s1)
    if (!rx_mbufs[i])
    80006700:	c945                	beqz	a0,800067b0 <e1000_init+0x1ac>
      panic("e1000");
    rx_ring[i].addr = (uint64) rx_mbufs[i]->head;
    80006702:	651c                	ld	a5,8(a0)
    80006704:	00f93023          	sd	a5,0(s2)
  for (i = 0; i < RX_RING_SIZE; i++) {
    80006708:	04a1                	addi	s1,s1,8
    8000670a:	0941                	addi	s2,s2,16
    8000670c:	ff3494e3          	bne	s1,s3,800066f4 <e1000_init+0xf0>
  }
  regs[E1000_RDBAL] = (uint64) rx_ring;
    80006710:	00023697          	auipc	a3,0x23
    80006714:	c986b683          	ld	a3,-872(a3) # 800293a8 <regs>
    80006718:	00023717          	auipc	a4,0x23
    8000671c:	aa870713          	addi	a4,a4,-1368 # 800291c0 <rx_ring>
    80006720:	678d                	lui	a5,0x3
    80006722:	97b6                	add	a5,a5,a3
    80006724:	80e7a023          	sw	a4,-2048(a5) # 2800 <_entry-0x7fffd800>
  if(sizeof(rx_ring) % 128 != 0)
    panic("e1000");
  regs[E1000_RDH] = 0;
    80006728:	8007a823          	sw	zero,-2032(a5)
  regs[E1000_RDT] = RX_RING_SIZE - 1;
    8000672c:	473d                	li	a4,15
    8000672e:	80e7ac23          	sw	a4,-2024(a5)
  regs[E1000_RDLEN] = sizeof(rx_ring);
    80006732:	10000713          	li	a4,256
    80006736:	80e7a423          	sw	a4,-2040(a5)

  // filter by qemu's MAC address, 52:54:00:12:34:56
  regs[E1000_RA] = 0x12005452;
    8000673a:	6715                	lui	a4,0x5
    8000673c:	00e68633          	add	a2,a3,a4
    80006740:	120057b7          	lui	a5,0x12005
    80006744:	45278793          	addi	a5,a5,1106 # 12005452 <_entry-0x6dffabae>
    80006748:	40f62023          	sw	a5,1024(a2)
  regs[E1000_RA+1] = 0x5634 | (1<<31);
    8000674c:	800057b7          	lui	a5,0x80005
    80006750:	63478793          	addi	a5,a5,1588 # ffffffff80005634 <end+0xfffffffefffdc268>
    80006754:	40f62223          	sw	a5,1028(a2)
  // multicast table
  for (int i = 0; i < 4096/32; i++)
    80006758:	20070793          	addi	a5,a4,512 # 5200 <_entry-0x7fffae00>
    8000675c:	97b6                	add	a5,a5,a3
    8000675e:	40070713          	addi	a4,a4,1024
    80006762:	9736                	add	a4,a4,a3
    regs[E1000_MTA + i] = 0;
    80006764:	0007a023          	sw	zero,0(a5)
  for (int i = 0; i < 4096/32; i++)
    80006768:	0791                	addi	a5,a5,4
    8000676a:	fee79de3          	bne	a5,a4,80006764 <e1000_init+0x160>

  // transmitter control bits.
  regs[E1000_TCTL] = E1000_TCTL_EN |  // enable
    8000676e:	000407b7          	lui	a5,0x40
    80006772:	10a78793          	addi	a5,a5,266 # 4010a <_entry-0x7ffbfef6>
    80006776:	40f6a023          	sw	a5,1024(a3)
    E1000_TCTL_PSP |                  // pad short packets
    (0x10 << E1000_TCTL_CT_SHIFT) |   // collision stuff
    (0x40 << E1000_TCTL_COLD_SHIFT);
  regs[E1000_TIPG] = 10 | (8<<10) | (6<<20); // inter-pkt gap
    8000677a:	006027b7          	lui	a5,0x602
    8000677e:	07a9                	addi	a5,a5,10
    80006780:	40f6a823          	sw	a5,1040(a3)

  // receiver control bits.
  regs[E1000_RCTL] = E1000_RCTL_EN | // enable receiver
    80006784:	040087b7          	lui	a5,0x4008
    80006788:	0789                	addi	a5,a5,2
    8000678a:	10f6a023          	sw	a5,256(a3)
    E1000_RCTL_BAM |                 // enable broadcast
    E1000_RCTL_SZ_2048 |             // 2048-byte rx buffers
    E1000_RCTL_SECRC;                // strip CRC

  // ask e1000 for receive interrupts.
  regs[E1000_RDTR] = 0; // interrupt after every received packet (no timer)
    8000678e:	678d                	lui	a5,0x3
    80006790:	97b6                	add	a5,a5,a3
    80006792:	8207a023          	sw	zero,-2016(a5) # 2820 <_entry-0x7fffd7e0>
  regs[E1000_RADV] = 0; // interrupt after every packet (no timer)
    80006796:	8207a623          	sw	zero,-2004(a5)
  regs[E1000_IMS] = (1 << 7); // RXDW -- Receiver Descriptor Write Back
    8000679a:	08000793          	li	a5,128
    8000679e:	0cf6a823          	sw	a5,208(a3)
}
    800067a2:	70a2                	ld	ra,40(sp)
    800067a4:	7402                	ld	s0,32(sp)
    800067a6:	64e2                	ld	s1,24(sp)
    800067a8:	6942                	ld	s2,16(sp)
    800067aa:	69a2                	ld	s3,8(sp)
    800067ac:	6145                	addi	sp,sp,48
    800067ae:	8082                	ret
      panic("e1000");
    800067b0:	00003517          	auipc	a0,0x3
    800067b4:	43850513          	addi	a0,a0,1080 # 80009be8 <userret+0xb58>
    800067b8:	ffffa097          	auipc	ra,0xffffa
    800067bc:	da2080e7          	jalr	-606(ra) # 8000055a <panic>

00000000800067c0 <e1000_transmit>:

int
e1000_transmit(struct mbuf *m)
{
    800067c0:	1101                	addi	sp,sp,-32
    800067c2:	ec06                	sd	ra,24(sp)
    800067c4:	e822                	sd	s0,16(sp)
    800067c6:	e426                	sd	s1,8(sp)
    800067c8:	e04a                	sd	s2,0(sp)
    800067ca:	1000                	addi	s0,sp,32
    800067cc:	892a                	mv	s2,a0
  //
  // the mbuf contains an ethernet frame; program it into
  // the TX descriptor ring so that the e1000 sends it. Stash
  // a pointer so that it can be freed after sending.
  //
  printf("T1\n");
    800067ce:	00003517          	auipc	a0,0x3
    800067d2:	42250513          	addi	a0,a0,1058 # 80009bf0 <userret+0xb60>
    800067d6:	ffffa097          	auipc	ra,0xffffa
    800067da:	dde080e7          	jalr	-546(ra) # 800005b4 <printf>
  acquire(&e1000_lock_tx);
    800067de:	00023517          	auipc	a0,0x23
    800067e2:	84250513          	addi	a0,a0,-1982 # 80029020 <e1000_lock_tx>
    800067e6:	ffffa097          	auipc	ra,0xffffa
    800067ea:	2c6080e7          	jalr	710(ra) # 80000aac <acquire>
  int current_position = regs[E1000_TDT];
    800067ee:	00023797          	auipc	a5,0x23
    800067f2:	bba7b783          	ld	a5,-1094(a5) # 800293a8 <regs>
    800067f6:	6711                	lui	a4,0x4
    800067f8:	97ba                	add	a5,a5,a4
    800067fa:	8187a483          	lw	s1,-2024(a5)
    800067fe:	2481                	sext.w	s1,s1
  if ((tx_ring[current_position].status & E1000_TXD_STAT_DD) == 0) {
    80006800:	00449713          	slli	a4,s1,0x4
    80006804:	00022797          	auipc	a5,0x22
    80006808:	7fc78793          	addi	a5,a5,2044 # 80029000 <e1000_lock_rx>
    8000680c:	97ba                	add	a5,a5,a4
    8000680e:	04c7c783          	lbu	a5,76(a5)
    80006812:	8b85                	andi	a5,a5,1
    80006814:	cbdd                	beqz	a5,800068ca <e1000_transmit+0x10a>
  	//previous transmission still in flight
    release(&e1000_lock_tx);
  	return 1;
  }
  //do a conditional check
  if (tx_mbufs[current_position] != 0)
    80006816:	00349713          	slli	a4,s1,0x3
    8000681a:	00022797          	auipc	a5,0x22
    8000681e:	7e678793          	addi	a5,a5,2022 # 80029000 <e1000_lock_rx>
    80006822:	97ba                	add	a5,a5,a4
    80006824:	1407b503          	ld	a0,320(a5)
    80006828:	c509                	beqz	a0,80006832 <e1000_transmit+0x72>
  	mbuffree(tx_mbufs[current_position]);
    8000682a:	00000097          	auipc	ra,0x0
    8000682e:	3c2080e7          	jalr	962(ra) # 80006bec <mbuffree>
  printf("T2\n");
    80006832:	00003517          	auipc	a0,0x3
    80006836:	3c650513          	addi	a0,a0,966 # 80009bf8 <userret+0xb68>
    8000683a:	ffffa097          	auipc	ra,0xffffa
    8000683e:	d7a080e7          	jalr	-646(ra) # 800005b4 <printf>
  tx_ring[current_position].addr = (uint64)m->head;
    80006842:	00449713          	slli	a4,s1,0x4
    80006846:	00022797          	auipc	a5,0x22
    8000684a:	7ba78793          	addi	a5,a5,1978 # 80029000 <e1000_lock_rx>
    8000684e:	97ba                	add	a5,a5,a4
    80006850:	00893703          	ld	a4,8(s2)
    80006854:	e3b8                	sd	a4,64(a5)
  tx_ring[current_position].length = m->len;
    80006856:	01092703          	lw	a4,16(s2)
    8000685a:	04e79423          	sh	a4,72(a5)
  tx_ring[current_position].status = 0;
    8000685e:	04078623          	sb	zero,76(a5)
  tx_ring[current_position].cso =  0;
    80006862:	04078523          	sb	zero,74(a5)
  tx_ring[current_position].cmd = E1000_TXD_CMD_RS;
    80006866:	4721                	li	a4,8
    80006868:	04e785a3          	sb	a4,75(a5)
  tx_ring[current_position].css = 0;
    8000686c:	040786a3          	sb	zero,77(a5)
  tx_ring[current_position].special = 0;
    80006870:	04079723          	sh	zero,78(a5)
  if (m->next == 0) {
    80006874:	00093783          	ld	a5,0(s2)
    80006878:	c3bd                	beqz	a5,800068de <e1000_transmit+0x11e>
  	tx_ring[current_position].cmd |= E1000_TXD_CMD_EOP ;
  }

  tx_mbufs[current_position] = m;
    8000687a:	00349713          	slli	a4,s1,0x3
    8000687e:	00022797          	auipc	a5,0x22
    80006882:	78278793          	addi	a5,a5,1922 # 80029000 <e1000_lock_rx>
    80006886:	97ba                	add	a5,a5,a4
    80006888:	1527b023          	sd	s2,320(a5)

  int next_position = (current_position + 1)%TX_RING_SIZE;
    8000688c:	2485                	addiw	s1,s1,1
    8000688e:	41f4d79b          	sraiw	a5,s1,0x1f
    80006892:	01c7d79b          	srliw	a5,a5,0x1c
    80006896:	9cbd                	addw	s1,s1,a5
    80006898:	88bd                	andi	s1,s1,15
    8000689a:	9c9d                	subw	s1,s1,a5
  regs[E1000_TDT] = next_position;
    8000689c:	00023797          	auipc	a5,0x23
    800068a0:	b0c7b783          	ld	a5,-1268(a5) # 800293a8 <regs>
    800068a4:	6711                	lui	a4,0x4
    800068a6:	97ba                	add	a5,a5,a4
    800068a8:	8097ac23          	sw	s1,-2024(a5)
  release(&e1000_lock_tx);
    800068ac:	00022517          	auipc	a0,0x22
    800068b0:	77450513          	addi	a0,a0,1908 # 80029020 <e1000_lock_tx>
    800068b4:	ffffa097          	auipc	ra,0xffffa
    800068b8:	2c8080e7          	jalr	712(ra) # 80000b7c <release>
  return 0;
    800068bc:	4501                	li	a0,0
}
    800068be:	60e2                	ld	ra,24(sp)
    800068c0:	6442                	ld	s0,16(sp)
    800068c2:	64a2                	ld	s1,8(sp)
    800068c4:	6902                	ld	s2,0(sp)
    800068c6:	6105                	addi	sp,sp,32
    800068c8:	8082                	ret
    release(&e1000_lock_tx);
    800068ca:	00022517          	auipc	a0,0x22
    800068ce:	75650513          	addi	a0,a0,1878 # 80029020 <e1000_lock_tx>
    800068d2:	ffffa097          	auipc	ra,0xffffa
    800068d6:	2aa080e7          	jalr	682(ra) # 80000b7c <release>
  	return 1;
    800068da:	4505                	li	a0,1
    800068dc:	b7cd                	j	800068be <e1000_transmit+0xfe>
  	tx_ring[current_position].cmd |= E1000_TXD_CMD_EOP ;
    800068de:	00449713          	slli	a4,s1,0x4
    800068e2:	00022797          	auipc	a5,0x22
    800068e6:	71e78793          	addi	a5,a5,1822 # 80029000 <e1000_lock_rx>
    800068ea:	97ba                	add	a5,a5,a4
    800068ec:	4725                	li	a4,9
    800068ee:	04e785a3          	sb	a4,75(a5)
    800068f2:	b761                	j	8000687a <e1000_transmit+0xba>

00000000800068f4 <e1000_intr>:
  return;
}

void
e1000_intr(void)
{
    800068f4:	7139                	addi	sp,sp,-64
    800068f6:	fc06                	sd	ra,56(sp)
    800068f8:	f822                	sd	s0,48(sp)
    800068fa:	f426                	sd	s1,40(sp)
    800068fc:	f04a                	sd	s2,32(sp)
    800068fe:	ec4e                	sd	s3,24(sp)
    80006900:	e852                	sd	s4,16(sp)
    80006902:	e456                	sd	s5,8(sp)
    80006904:	0080                	addi	s0,sp,64
  acquire(&e1000_lock_rx);
    80006906:	00022917          	auipc	s2,0x22
    8000690a:	6fa90913          	addi	s2,s2,1786 # 80029000 <e1000_lock_rx>
    8000690e:	854a                	mv	a0,s2
    80006910:	ffffa097          	auipc	ra,0xffffa
    80006914:	19c080e7          	jalr	412(ra) # 80000aac <acquire>
  int next_position = (regs[E1000_RDT] + 1)%RX_RING_SIZE;
    80006918:	00023797          	auipc	a5,0x23
    8000691c:	a907b783          	ld	a5,-1392(a5) # 800293a8 <regs>
    80006920:	670d                	lui	a4,0x3
    80006922:	97ba                	add	a5,a5,a4
    80006924:	8187a483          	lw	s1,-2024(a5)
    80006928:	2485                	addiw	s1,s1,1
    8000692a:	88bd                	andi	s1,s1,15
  if ((rx_ring[next_position].status & E1000_RXD_STAT_DD) == 0) {
    8000692c:	00449793          	slli	a5,s1,0x4
    80006930:	993e                	add	s2,s2,a5
    80006932:	1cc94783          	lbu	a5,460(s2)
    80006936:	8b85                	andi	a5,a5,1
    80006938:	c3dd                	beqz	a5,800069de <e1000_intr+0xea>
  printf("REC\n");
    8000693a:	00003517          	auipc	a0,0x3
    8000693e:	2c650513          	addi	a0,a0,710 # 80009c00 <userret+0xb70>
    80006942:	ffffa097          	auipc	ra,0xffffa
    80006946:	c72080e7          	jalr	-910(ra) # 800005b4 <printf>
  struct mbuf *next_mbuf = rx_mbufs[next_position];
    8000694a:	00022a17          	auipc	s4,0x22
    8000694e:	6b6a0a13          	addi	s4,s4,1718 # 80029000 <e1000_lock_rx>
    80006952:	00349993          	slli	s3,s1,0x3
    80006956:	99d2                	add	s3,s3,s4
    80006958:	2c09ba83          	ld	s5,704(s3)
  mbufput(next_mbuf, rx_ring[next_position].length);
    8000695c:	00449913          	slli	s2,s1,0x4
    80006960:	9952                	add	s2,s2,s4
    80006962:	1c895583          	lhu	a1,456(s2)
    80006966:	8556                	mv	a0,s5
    80006968:	00000097          	auipc	ra,0x0
    8000696c:	1d0080e7          	jalr	464(ra) # 80006b38 <mbufput>
  net_rx(next_mbuf);
    80006970:	8556                	mv	a0,s5
    80006972:	00000097          	auipc	ra,0x0
    80006976:	3ee080e7          	jalr	1006(ra) # 80006d60 <net_rx>
  struct mbuf *m = mbufalloc(rx_ring[next_position].length);
    8000697a:	1c895503          	lhu	a0,456(s2)
    8000697e:	00000097          	auipc	ra,0x0
    80006982:	216080e7          	jalr	534(ra) # 80006b94 <mbufalloc>
	rx_ring[next_position].addr = (uint64)m->head;
    80006986:	651c                	ld	a5,8(a0)
    80006988:	1cf93023          	sd	a5,448(s2)
  rx_ring[next_position].length = 0;
    8000698c:	1c091423          	sh	zero,456(s2)
  rx_ring[next_position].csum = 0;
    80006990:	1c091523          	sh	zero,458(s2)
  rx_ring[next_position].status = 0;
    80006994:	1c090623          	sb	zero,460(s2)
  rx_ring[next_position].errors = 0;
    80006998:	1c0906a3          	sb	zero,461(s2)
  rx_ring[next_position].special = 0;
    8000699c:	1c091723          	sh	zero,462(s2)
  rx_mbufs[next_position] = m;
    800069a0:	2ca9b023          	sd	a0,704(s3)
  regs[E1000_RDT] = next_position;
    800069a4:	2481                	sext.w	s1,s1
    800069a6:	00023797          	auipc	a5,0x23
    800069aa:	a027b783          	ld	a5,-1534(a5) # 800293a8 <regs>
    800069ae:	670d                	lui	a4,0x3
    800069b0:	97ba                	add	a5,a5,a4
    800069b2:	8097ac23          	sw	s1,-2024(a5)
  release(&e1000_lock_rx);
    800069b6:	8552                	mv	a0,s4
    800069b8:	ffffa097          	auipc	ra,0xffffa
    800069bc:	1c4080e7          	jalr	452(ra) # 80000b7c <release>
  e1000_recv();
  // tell the e1000 we've seen this interrupt;
  // without this the e1000 won't raise any
  // further interrupts.
  regs[E1000_ICR];
    800069c0:	00023797          	auipc	a5,0x23
    800069c4:	9e87b783          	ld	a5,-1560(a5) # 800293a8 <regs>
    800069c8:	0c07a783          	lw	a5,192(a5)
}
    800069cc:	70e2                	ld	ra,56(sp)
    800069ce:	7442                	ld	s0,48(sp)
    800069d0:	74a2                	ld	s1,40(sp)
    800069d2:	7902                	ld	s2,32(sp)
    800069d4:	69e2                	ld	s3,24(sp)
    800069d6:	6a42                	ld	s4,16(sp)
    800069d8:	6aa2                	ld	s5,8(sp)
    800069da:	6121                	addi	sp,sp,64
    800069dc:	8082                	ret
    release(&e1000_lock_rx);
    800069de:	00022517          	auipc	a0,0x22
    800069e2:	62250513          	addi	a0,a0,1570 # 80029000 <e1000_lock_rx>
    800069e6:	ffffa097          	auipc	ra,0xffffa
    800069ea:	196080e7          	jalr	406(ra) # 80000b7c <release>
  	return;
    800069ee:	bfc9                	j	800069c0 <e1000_intr+0xcc>

00000000800069f0 <in_cksum>:

// This code is lifted from FreeBSD's ping.c, and is copyright by the Regents
// of the University of California.
static unsigned short
in_cksum(const unsigned char *addr, int len)
{
    800069f0:	1101                	addi	sp,sp,-32
    800069f2:	ec22                	sd	s0,24(sp)
    800069f4:	1000                	addi	s0,sp,32
  int nleft = len;
  const unsigned short *w = (const unsigned short *)addr;
  unsigned int sum = 0;
  unsigned short answer = 0;
    800069f6:	fe041723          	sh	zero,-18(s0)
  /*
   * Our algorithm is simple, using a 32 bit accumulator (sum), we add
   * sequential 16 bit words to it, and at the end, fold back all the
   * carry bits from the top 16 bits into the lower 16 bits.
   */
  while (nleft > 1)  {
    800069fa:	4785                	li	a5,1
    800069fc:	04b7d963          	bge	a5,a1,80006a4e <in_cksum+0x5e>
    80006a00:	ffe5879b          	addiw	a5,a1,-2
    80006a04:	0017d61b          	srliw	a2,a5,0x1
    80006a08:	0017d71b          	srliw	a4,a5,0x1
    80006a0c:	0705                	addi	a4,a4,1
    80006a0e:	0706                	slli	a4,a4,0x1
    80006a10:	972a                	add	a4,a4,a0
  unsigned int sum = 0;
    80006a12:	4781                	li	a5,0
    sum += *w++;
    80006a14:	0509                	addi	a0,a0,2
    80006a16:	ffe55683          	lhu	a3,-2(a0)
    80006a1a:	9fb5                	addw	a5,a5,a3
  while (nleft > 1)  {
    80006a1c:	fee51ce3          	bne	a0,a4,80006a14 <in_cksum+0x24>
    80006a20:	35f9                	addiw	a1,a1,-2
    80006a22:	0016169b          	slliw	a3,a2,0x1
    80006a26:	9d95                	subw	a1,a1,a3
    nleft -= 2;
  }

  /* mop up an odd byte, if necessary */
  if (nleft == 1) {
    80006a28:	4685                	li	a3,1
    80006a2a:	02d58563          	beq	a1,a3,80006a54 <in_cksum+0x64>
    *(unsigned char *)(&answer) = *(const unsigned char *)w;
    sum += answer;
  }

  /* add back carry outs from top 16 bits to low 16 bits */
  sum = (sum & 0xffff) + (sum >> 16);
    80006a2e:	03079513          	slli	a0,a5,0x30
    80006a32:	9141                	srli	a0,a0,0x30
    80006a34:	0107d79b          	srliw	a5,a5,0x10
    80006a38:	9fa9                	addw	a5,a5,a0
  sum += (sum >> 16);
    80006a3a:	0107d51b          	srliw	a0,a5,0x10
  /* guaranteed now that the lower 16 bits of sum are correct */

  answer = ~sum; /* truncate to 16 bits */
    80006a3e:	9d3d                	addw	a0,a0,a5
    80006a40:	fff54513          	not	a0,a0
  return answer;
}
    80006a44:	1542                	slli	a0,a0,0x30
    80006a46:	9141                	srli	a0,a0,0x30
    80006a48:	6462                	ld	s0,24(sp)
    80006a4a:	6105                	addi	sp,sp,32
    80006a4c:	8082                	ret
  const unsigned short *w = (const unsigned short *)addr;
    80006a4e:	872a                	mv	a4,a0
  unsigned int sum = 0;
    80006a50:	4781                	li	a5,0
    80006a52:	bfd9                	j	80006a28 <in_cksum+0x38>
    *(unsigned char *)(&answer) = *(const unsigned char *)w;
    80006a54:	00074703          	lbu	a4,0(a4) # 3000 <_entry-0x7fffd000>
    80006a58:	fee40723          	sb	a4,-18(s0)
    sum += answer;
    80006a5c:	fee45703          	lhu	a4,-18(s0)
    80006a60:	9fb9                	addw	a5,a5,a4
    80006a62:	b7f1                	j	80006a2e <in_cksum+0x3e>

0000000080006a64 <mbufpull>:
{
    80006a64:	1141                	addi	sp,sp,-16
    80006a66:	e422                	sd	s0,8(sp)
    80006a68:	0800                	addi	s0,sp,16
    80006a6a:	87aa                	mv	a5,a0
  char *tmp = m->head;
    80006a6c:	6508                	ld	a0,8(a0)
  if (m->len < len)
    80006a6e:	4b98                	lw	a4,16(a5)
    80006a70:	00b76b63          	bltu	a4,a1,80006a86 <mbufpull+0x22>
  m->len -= len;
    80006a74:	9f0d                	subw	a4,a4,a1
    80006a76:	cb98                	sw	a4,16(a5)
  m->head += len;
    80006a78:	1582                	slli	a1,a1,0x20
    80006a7a:	9181                	srli	a1,a1,0x20
    80006a7c:	95aa                	add	a1,a1,a0
    80006a7e:	e78c                	sd	a1,8(a5)
}
    80006a80:	6422                	ld	s0,8(sp)
    80006a82:	0141                	addi	sp,sp,16
    80006a84:	8082                	ret
    return 0;
    80006a86:	4501                	li	a0,0
    80006a88:	bfe5                	j	80006a80 <mbufpull+0x1c>

0000000080006a8a <mbufpush>:
{
    80006a8a:	87aa                	mv	a5,a0
  m->head -= len;
    80006a8c:	02059713          	slli	a4,a1,0x20
    80006a90:	9301                	srli	a4,a4,0x20
    80006a92:	6508                	ld	a0,8(a0)
    80006a94:	8d19                	sub	a0,a0,a4
    80006a96:	e788                	sd	a0,8(a5)
  if (m->head < m->buf)
    80006a98:	01478713          	addi	a4,a5,20
    80006a9c:	00e56663          	bltu	a0,a4,80006aa8 <mbufpush+0x1e>
  m->len += len;
    80006aa0:	4b98                	lw	a4,16(a5)
    80006aa2:	9db9                	addw	a1,a1,a4
    80006aa4:	cb8c                	sw	a1,16(a5)
}
    80006aa6:	8082                	ret
{
    80006aa8:	1141                	addi	sp,sp,-16
    80006aaa:	e406                	sd	ra,8(sp)
    80006aac:	e022                	sd	s0,0(sp)
    80006aae:	0800                	addi	s0,sp,16
    panic("mbufpush");
    80006ab0:	00003517          	auipc	a0,0x3
    80006ab4:	15850513          	addi	a0,a0,344 # 80009c08 <userret+0xb78>
    80006ab8:	ffffa097          	auipc	ra,0xffffa
    80006abc:	aa2080e7          	jalr	-1374(ra) # 8000055a <panic>

0000000080006ac0 <net_tx_eth>:

// sends an ethernet packet
static void
net_tx_eth(struct mbuf *m, uint16 ethtype)
{
    80006ac0:	7179                	addi	sp,sp,-48
    80006ac2:	f406                	sd	ra,40(sp)
    80006ac4:	f022                	sd	s0,32(sp)
    80006ac6:	ec26                	sd	s1,24(sp)
    80006ac8:	e84a                	sd	s2,16(sp)
    80006aca:	e44e                	sd	s3,8(sp)
    80006acc:	1800                	addi	s0,sp,48
    80006ace:	89aa                	mv	s3,a0
    80006ad0:	892e                	mv	s2,a1
  struct eth *ethhdr;

  ethhdr = mbufpushhdr(m, *ethhdr);
    80006ad2:	45b9                	li	a1,14
    80006ad4:	00000097          	auipc	ra,0x0
    80006ad8:	fb6080e7          	jalr	-74(ra) # 80006a8a <mbufpush>
    80006adc:	84aa                	mv	s1,a0
  memmove(ethhdr->shost, local_mac, ETHADDR_LEN);
    80006ade:	4619                	li	a2,6
    80006ae0:	00003597          	auipc	a1,0x3
    80006ae4:	56858593          	addi	a1,a1,1384 # 8000a048 <local_mac>
    80006ae8:	0519                	addi	a0,a0,6
    80006aea:	ffffa097          	auipc	ra,0xffffa
    80006aee:	2f0080e7          	jalr	752(ra) # 80000dda <memmove>
  // In a real networking stack, dhost would be set to the address discovered
  // through ARP. Because we don't support enough of the ARP protocol, set it
  // to broadcast instead.
  memmove(ethhdr->dhost, broadcast_mac, ETHADDR_LEN);
    80006af2:	4619                	li	a2,6
    80006af4:	00003597          	auipc	a1,0x3
    80006af8:	54c58593          	addi	a1,a1,1356 # 8000a040 <broadcast_mac>
    80006afc:	8526                	mv	a0,s1
    80006afe:	ffffa097          	auipc	ra,0xffffa
    80006b02:	2dc080e7          	jalr	732(ra) # 80000dda <memmove>
// endianness support
//

static inline uint16 bswaps(uint16 val)
{
  return (((val & 0x00ffU) << 8) |
    80006b06:	0089579b          	srliw	a5,s2,0x8
  ethhdr->type = htons(ethtype);
    80006b0a:	00f48623          	sb	a5,12(s1)
    80006b0e:	012486a3          	sb	s2,13(s1)
  if (e1000_transmit(m)) {
    80006b12:	854e                	mv	a0,s3
    80006b14:	00000097          	auipc	ra,0x0
    80006b18:	cac080e7          	jalr	-852(ra) # 800067c0 <e1000_transmit>
    80006b1c:	e901                	bnez	a0,80006b2c <net_tx_eth+0x6c>
    mbuffree(m);
  }
}
    80006b1e:	70a2                	ld	ra,40(sp)
    80006b20:	7402                	ld	s0,32(sp)
    80006b22:	64e2                	ld	s1,24(sp)
    80006b24:	6942                	ld	s2,16(sp)
    80006b26:	69a2                	ld	s3,8(sp)
    80006b28:	6145                	addi	sp,sp,48
    80006b2a:	8082                	ret
  kfree(m);
    80006b2c:	854e                	mv	a0,s3
    80006b2e:	ffffa097          	auipc	ra,0xffffa
    80006b32:	d4e080e7          	jalr	-690(ra) # 8000087c <kfree>
}
    80006b36:	b7e5                	j	80006b1e <net_tx_eth+0x5e>

0000000080006b38 <mbufput>:
{
    80006b38:	87aa                	mv	a5,a0
  char *tmp = m->head + m->len;
    80006b3a:	4918                	lw	a4,16(a0)
    80006b3c:	02071693          	slli	a3,a4,0x20
    80006b40:	9281                	srli	a3,a3,0x20
    80006b42:	6508                	ld	a0,8(a0)
    80006b44:	9536                	add	a0,a0,a3
  m->len += len;
    80006b46:	9f2d                	addw	a4,a4,a1
    80006b48:	0007069b          	sext.w	a3,a4
    80006b4c:	cb98                	sw	a4,16(a5)
  if (m->len > MBUF_SIZE)
    80006b4e:	6785                	lui	a5,0x1
    80006b50:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    80006b54:	00d7e363          	bltu	a5,a3,80006b5a <mbufput+0x22>
}
    80006b58:	8082                	ret
{
    80006b5a:	1141                	addi	sp,sp,-16
    80006b5c:	e406                	sd	ra,8(sp)
    80006b5e:	e022                	sd	s0,0(sp)
    80006b60:	0800                	addi	s0,sp,16
    panic("mbufput");
    80006b62:	00003517          	auipc	a0,0x3
    80006b66:	0b650513          	addi	a0,a0,182 # 80009c18 <userret+0xb88>
    80006b6a:	ffffa097          	auipc	ra,0xffffa
    80006b6e:	9f0080e7          	jalr	-1552(ra) # 8000055a <panic>

0000000080006b72 <mbuftrim>:
{
    80006b72:	1141                	addi	sp,sp,-16
    80006b74:	e422                	sd	s0,8(sp)
    80006b76:	0800                	addi	s0,sp,16
  if (len > m->len)
    80006b78:	491c                	lw	a5,16(a0)
    80006b7a:	00b7eb63          	bltu	a5,a1,80006b90 <mbuftrim+0x1e>
  m->len -= len;
    80006b7e:	9f8d                	subw	a5,a5,a1
    80006b80:	c91c                	sw	a5,16(a0)
  return m->head + m->len;
    80006b82:	1782                	slli	a5,a5,0x20
    80006b84:	9381                	srli	a5,a5,0x20
    80006b86:	6508                	ld	a0,8(a0)
    80006b88:	953e                	add	a0,a0,a5
}
    80006b8a:	6422                	ld	s0,8(sp)
    80006b8c:	0141                	addi	sp,sp,16
    80006b8e:	8082                	ret
    return 0;
    80006b90:	4501                	li	a0,0
    80006b92:	bfe5                	j	80006b8a <mbuftrim+0x18>

0000000080006b94 <mbufalloc>:
{
    80006b94:	1101                	addi	sp,sp,-32
    80006b96:	ec06                	sd	ra,24(sp)
    80006b98:	e822                	sd	s0,16(sp)
    80006b9a:	e426                	sd	s1,8(sp)
    80006b9c:	e04a                	sd	s2,0(sp)
    80006b9e:	1000                	addi	s0,sp,32
  if (headroom > MBUF_SIZE)
    80006ba0:	6785                	lui	a5,0x1
    80006ba2:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    return 0;
    80006ba6:	4901                	li	s2,0
  if (headroom > MBUF_SIZE)
    80006ba8:	02a7eb63          	bltu	a5,a0,80006bde <mbufalloc+0x4a>
    80006bac:	84aa                	mv	s1,a0
  m = kalloc();
    80006bae:	ffffa097          	auipc	ra,0xffffa
    80006bb2:	dca080e7          	jalr	-566(ra) # 80000978 <kalloc>
    80006bb6:	892a                	mv	s2,a0
  if (m == 0)
    80006bb8:	c11d                	beqz	a0,80006bde <mbufalloc+0x4a>
  m->next = 0;
    80006bba:	00053023          	sd	zero,0(a0)
  m->head = (char *)m->buf + headroom;
    80006bbe:	0551                	addi	a0,a0,20
    80006bc0:	1482                	slli	s1,s1,0x20
    80006bc2:	9081                	srli	s1,s1,0x20
    80006bc4:	94aa                	add	s1,s1,a0
    80006bc6:	00993423          	sd	s1,8(s2)
  m->len = 0;
    80006bca:	00092823          	sw	zero,16(s2)
  memset(m->buf, 0, sizeof(m->buf));
    80006bce:	6605                	lui	a2,0x1
    80006bd0:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    80006bd4:	4581                	li	a1,0
    80006bd6:	ffffa097          	auipc	ra,0xffffa
    80006bda:	1a4080e7          	jalr	420(ra) # 80000d7a <memset>
}
    80006bde:	854a                	mv	a0,s2
    80006be0:	60e2                	ld	ra,24(sp)
    80006be2:	6442                	ld	s0,16(sp)
    80006be4:	64a2                	ld	s1,8(sp)
    80006be6:	6902                	ld	s2,0(sp)
    80006be8:	6105                	addi	sp,sp,32
    80006bea:	8082                	ret

0000000080006bec <mbuffree>:
{
    80006bec:	1141                	addi	sp,sp,-16
    80006bee:	e406                	sd	ra,8(sp)
    80006bf0:	e022                	sd	s0,0(sp)
    80006bf2:	0800                	addi	s0,sp,16
  kfree(m);
    80006bf4:	ffffa097          	auipc	ra,0xffffa
    80006bf8:	c88080e7          	jalr	-888(ra) # 8000087c <kfree>
}
    80006bfc:	60a2                	ld	ra,8(sp)
    80006bfe:	6402                	ld	s0,0(sp)
    80006c00:	0141                	addi	sp,sp,16
    80006c02:	8082                	ret

0000000080006c04 <mbufq_pushtail>:
{
    80006c04:	1141                	addi	sp,sp,-16
    80006c06:	e422                	sd	s0,8(sp)
    80006c08:	0800                	addi	s0,sp,16
  m->next = 0;
    80006c0a:	0005b023          	sd	zero,0(a1)
  if (!q->head){
    80006c0e:	611c                	ld	a5,0(a0)
    80006c10:	c799                	beqz	a5,80006c1e <mbufq_pushtail+0x1a>
  q->tail->next = m;
    80006c12:	651c                	ld	a5,8(a0)
    80006c14:	e38c                	sd	a1,0(a5)
  q->tail = m;
    80006c16:	e50c                	sd	a1,8(a0)
}
    80006c18:	6422                	ld	s0,8(sp)
    80006c1a:	0141                	addi	sp,sp,16
    80006c1c:	8082                	ret
    q->head = q->tail = m;
    80006c1e:	e50c                	sd	a1,8(a0)
    80006c20:	e10c                	sd	a1,0(a0)
    return;
    80006c22:	bfdd                	j	80006c18 <mbufq_pushtail+0x14>

0000000080006c24 <mbufq_pophead>:
{
    80006c24:	1141                	addi	sp,sp,-16
    80006c26:	e422                	sd	s0,8(sp)
    80006c28:	0800                	addi	s0,sp,16
    80006c2a:	87aa                	mv	a5,a0
  struct mbuf *head = q->head;
    80006c2c:	6108                	ld	a0,0(a0)
  if (!head)
    80006c2e:	c119                	beqz	a0,80006c34 <mbufq_pophead+0x10>
  q->head = head->next;
    80006c30:	6118                	ld	a4,0(a0)
    80006c32:	e398                	sd	a4,0(a5)
}
    80006c34:	6422                	ld	s0,8(sp)
    80006c36:	0141                	addi	sp,sp,16
    80006c38:	8082                	ret

0000000080006c3a <mbufq_empty>:
{
    80006c3a:	1141                	addi	sp,sp,-16
    80006c3c:	e422                	sd	s0,8(sp)
    80006c3e:	0800                	addi	s0,sp,16
  return q->head == 0;
    80006c40:	6108                	ld	a0,0(a0)
}
    80006c42:	00153513          	seqz	a0,a0
    80006c46:	6422                	ld	s0,8(sp)
    80006c48:	0141                	addi	sp,sp,16
    80006c4a:	8082                	ret

0000000080006c4c <mbufq_init>:
{
    80006c4c:	1141                	addi	sp,sp,-16
    80006c4e:	e422                	sd	s0,8(sp)
    80006c50:	0800                	addi	s0,sp,16
  q->head = 0;
    80006c52:	00053023          	sd	zero,0(a0)
}
    80006c56:	6422                	ld	s0,8(sp)
    80006c58:	0141                	addi	sp,sp,16
    80006c5a:	8082                	ret

0000000080006c5c <net_tx_udp>:

// sends a UDP packet
void
net_tx_udp(struct mbuf *m, uint32 dip,
           uint16 sport, uint16 dport)
{
    80006c5c:	7179                	addi	sp,sp,-48
    80006c5e:	f406                	sd	ra,40(sp)
    80006c60:	f022                	sd	s0,32(sp)
    80006c62:	ec26                	sd	s1,24(sp)
    80006c64:	e84a                	sd	s2,16(sp)
    80006c66:	e44e                	sd	s3,8(sp)
    80006c68:	e052                	sd	s4,0(sp)
    80006c6a:	1800                	addi	s0,sp,48
    80006c6c:	8a2a                	mv	s4,a0
    80006c6e:	892e                	mv	s2,a1
    80006c70:	89b2                	mv	s3,a2
    80006c72:	84b6                	mv	s1,a3
  struct udp *udphdr;

  // put the UDP header
  udphdr = mbufpushhdr(m, *udphdr);
    80006c74:	45a1                	li	a1,8
    80006c76:	00000097          	auipc	ra,0x0
    80006c7a:	e14080e7          	jalr	-492(ra) # 80006a8a <mbufpush>
    80006c7e:	0089d61b          	srliw	a2,s3,0x8
    80006c82:	0089999b          	slliw	s3,s3,0x8
    80006c86:	00c9e9b3          	or	s3,s3,a2
  udphdr->sport = htons(sport);
    80006c8a:	01351023          	sh	s3,0(a0)
    80006c8e:	0084d69b          	srliw	a3,s1,0x8
    80006c92:	0084949b          	slliw	s1,s1,0x8
    80006c96:	8cd5                	or	s1,s1,a3
  udphdr->dport = htons(dport);
    80006c98:	00951123          	sh	s1,2(a0)
  udphdr->ulen = htons(m->len);
    80006c9c:	010a2783          	lw	a5,16(s4)
    80006ca0:	0087d713          	srli	a4,a5,0x8
    80006ca4:	0087979b          	slliw	a5,a5,0x8
    80006ca8:	0ff77713          	andi	a4,a4,255
    80006cac:	8fd9                	or	a5,a5,a4
    80006cae:	00f51223          	sh	a5,4(a0)
  udphdr->sum = 0; // zero means no checksum is provided
    80006cb2:	00051323          	sh	zero,6(a0)
  iphdr = mbufpushhdr(m, *iphdr);
    80006cb6:	45d1                	li	a1,20
    80006cb8:	8552                	mv	a0,s4
    80006cba:	00000097          	auipc	ra,0x0
    80006cbe:	dd0080e7          	jalr	-560(ra) # 80006a8a <mbufpush>
    80006cc2:	84aa                	mv	s1,a0
  memset(iphdr, 0, sizeof(*iphdr));
    80006cc4:	4651                	li	a2,20
    80006cc6:	4581                	li	a1,0
    80006cc8:	ffffa097          	auipc	ra,0xffffa
    80006ccc:	0b2080e7          	jalr	178(ra) # 80000d7a <memset>
  iphdr->ip_vhl = (4 << 4) | (20 >> 2);
    80006cd0:	04500793          	li	a5,69
    80006cd4:	00f48023          	sb	a5,0(s1)
  iphdr->ip_p = proto;
    80006cd8:	47c5                	li	a5,17
    80006cda:	00f484a3          	sb	a5,9(s1)
  iphdr->ip_src = htonl(local_ip);
    80006cde:	0f0207b7          	lui	a5,0xf020
    80006ce2:	07a9                	addi	a5,a5,10
    80006ce4:	c4dc                	sw	a5,12(s1)
          ((val & 0xff00U) >> 8));
}

static inline uint32 bswapl(uint32 val)
{
  return (((val & 0x000000ffUL) << 24) |
    80006ce6:	0189179b          	slliw	a5,s2,0x18
          ((val & 0x0000ff00UL) << 8) |
          ((val & 0x00ff0000UL) >> 8) |
          ((val & 0xff000000UL) >> 24));
    80006cea:	0189571b          	srliw	a4,s2,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006cee:	8fd9                	or	a5,a5,a4
          ((val & 0x0000ff00UL) << 8) |
    80006cf0:	0089171b          	slliw	a4,s2,0x8
    80006cf4:	00ff06b7          	lui	a3,0xff0
    80006cf8:	8f75                	and	a4,a4,a3
          ((val & 0x00ff0000UL) >> 8) |
    80006cfa:	8fd9                	or	a5,a5,a4
    80006cfc:	0089591b          	srliw	s2,s2,0x8
    80006d00:	65c1                	lui	a1,0x10
    80006d02:	f0058593          	addi	a1,a1,-256 # ff00 <_entry-0x7fff0100>
    80006d06:	00b97933          	and	s2,s2,a1
    80006d0a:	0127e933          	or	s2,a5,s2
  iphdr->ip_dst = htonl(dip);
    80006d0e:	0124a823          	sw	s2,16(s1)
  iphdr->ip_len = htons(m->len);
    80006d12:	010a2783          	lw	a5,16(s4)
  return (((val & 0x00ffU) << 8) |
    80006d16:	0087d713          	srli	a4,a5,0x8
    80006d1a:	0087979b          	slliw	a5,a5,0x8
    80006d1e:	0ff77713          	andi	a4,a4,255
    80006d22:	8fd9                	or	a5,a5,a4
    80006d24:	00f49123          	sh	a5,2(s1)
  iphdr->ip_ttl = 100;
    80006d28:	06400793          	li	a5,100
    80006d2c:	00f48423          	sb	a5,8(s1)
  iphdr->ip_sum = in_cksum((unsigned char *)iphdr, sizeof(*iphdr));
    80006d30:	45d1                	li	a1,20
    80006d32:	8526                	mv	a0,s1
    80006d34:	00000097          	auipc	ra,0x0
    80006d38:	cbc080e7          	jalr	-836(ra) # 800069f0 <in_cksum>
    80006d3c:	00a49523          	sh	a0,10(s1)
  net_tx_eth(m, ETHTYPE_IP);
    80006d40:	6585                	lui	a1,0x1
    80006d42:	80058593          	addi	a1,a1,-2048 # 800 <_entry-0x7ffff800>
    80006d46:	8552                	mv	a0,s4
    80006d48:	00000097          	auipc	ra,0x0
    80006d4c:	d78080e7          	jalr	-648(ra) # 80006ac0 <net_tx_eth>

  // now on to the IP layer
  net_tx_ip(m, IPPROTO_UDP, dip);
}
    80006d50:	70a2                	ld	ra,40(sp)
    80006d52:	7402                	ld	s0,32(sp)
    80006d54:	64e2                	ld	s1,24(sp)
    80006d56:	6942                	ld	s2,16(sp)
    80006d58:	69a2                	ld	s3,8(sp)
    80006d5a:	6a02                	ld	s4,0(sp)
    80006d5c:	6145                	addi	sp,sp,48
    80006d5e:	8082                	ret

0000000080006d60 <net_rx>:
}

// called by e1000 driver's interrupt handler to deliver a packet to the
// networking stack
void net_rx(struct mbuf *m)
{
    80006d60:	715d                	addi	sp,sp,-80
    80006d62:	e486                	sd	ra,72(sp)
    80006d64:	e0a2                	sd	s0,64(sp)
    80006d66:	fc26                	sd	s1,56(sp)
    80006d68:	f84a                	sd	s2,48(sp)
    80006d6a:	f44e                	sd	s3,40(sp)
    80006d6c:	f052                	sd	s4,32(sp)
    80006d6e:	ec56                	sd	s5,24(sp)
    80006d70:	0880                	addi	s0,sp,80
    80006d72:	892a                	mv	s2,a0
  struct eth *ethhdr;
  uint16 type;

  ethhdr = mbufpullhdr(m, *ethhdr);
    80006d74:	45b9                	li	a1,14
    80006d76:	00000097          	auipc	ra,0x0
    80006d7a:	cee080e7          	jalr	-786(ra) # 80006a64 <mbufpull>
  if (!ethhdr) {
    80006d7e:	c535                	beqz	a0,80006dea <net_rx+0x8a>
    mbuffree(m);
    return;
  }

  type = ntohs(ethhdr->type);
    80006d80:	00c54483          	lbu	s1,12(a0)
    80006d84:	00d54783          	lbu	a5,13(a0)
    80006d88:	07a2                	slli	a5,a5,0x8
    80006d8a:	8cdd                	or	s1,s1,a5
    80006d8c:	0084949b          	slliw	s1,s1,0x8
    80006d90:	83a1                	srli	a5,a5,0x8
    80006d92:	8cdd                	or	s1,s1,a5
    80006d94:	14c2                	slli	s1,s1,0x30
    80006d96:	90c1                	srli	s1,s1,0x30
  if (type == ETHTYPE_IP) {
    80006d98:	8004879b          	addiw	a5,s1,-2048
    80006d9c:	cfa9                	beqz	a5,80006df6 <net_rx+0x96>
    printf("IP\n");
    net_rx_ip(m);
  }
  else if (type == ETHTYPE_ARP) {
    80006d9e:	0004871b          	sext.w	a4,s1
    80006da2:	6785                	lui	a5,0x1
    80006da4:	80678793          	addi	a5,a5,-2042 # 806 <_entry-0x7ffff7fa>
    80006da8:	1cf70463          	beq	a4,a5,80006f70 <net_rx+0x210>
    printf("ARP\n");
    net_rx_arp(m);
  }
  else {
    printf("WTF\n");
    80006dac:	00003517          	auipc	a0,0x3
    80006db0:	e9450513          	addi	a0,a0,-364 # 80009c40 <userret+0xbb0>
    80006db4:	ffffa097          	auipc	ra,0xffffa
    80006db8:	800080e7          	jalr	-2048(ra) # 800005b4 <printf>
    printf("%d", type);
    80006dbc:	85a6                	mv	a1,s1
    80006dbe:	00003517          	auipc	a0,0x3
    80006dc2:	e8a50513          	addi	a0,a0,-374 # 80009c48 <userret+0xbb8>
    80006dc6:	ffff9097          	auipc	ra,0xffff9
    80006dca:	7ee080e7          	jalr	2030(ra) # 800005b4 <printf>
  kfree(m);
    80006dce:	854a                	mv	a0,s2
    80006dd0:	ffffa097          	auipc	ra,0xffffa
    80006dd4:	aac080e7          	jalr	-1364(ra) # 8000087c <kfree>
    mbuffree(m);
  }
}
    80006dd8:	60a6                	ld	ra,72(sp)
    80006dda:	6406                	ld	s0,64(sp)
    80006ddc:	74e2                	ld	s1,56(sp)
    80006dde:	7942                	ld	s2,48(sp)
    80006de0:	79a2                	ld	s3,40(sp)
    80006de2:	7a02                	ld	s4,32(sp)
    80006de4:	6ae2                	ld	s5,24(sp)
    80006de6:	6161                	addi	sp,sp,80
    80006de8:	8082                	ret
  kfree(m);
    80006dea:	854a                	mv	a0,s2
    80006dec:	ffffa097          	auipc	ra,0xffffa
    80006df0:	a90080e7          	jalr	-1392(ra) # 8000087c <kfree>
}
    80006df4:	b7d5                	j	80006dd8 <net_rx+0x78>
    printf("IP\n");
    80006df6:	00003517          	auipc	a0,0x3
    80006dfa:	e2a50513          	addi	a0,a0,-470 # 80009c20 <userret+0xb90>
    80006dfe:	ffff9097          	auipc	ra,0xffff9
    80006e02:	7b6080e7          	jalr	1974(ra) # 800005b4 <printf>
  iphdr = mbufpullhdr(m, *iphdr);
    80006e06:	45d1                	li	a1,20
    80006e08:	854a                	mv	a0,s2
    80006e0a:	00000097          	auipc	ra,0x0
    80006e0e:	c5a080e7          	jalr	-934(ra) # 80006a64 <mbufpull>
    80006e12:	84aa                	mv	s1,a0
  if (!iphdr)
    80006e14:	c519                	beqz	a0,80006e22 <net_rx+0xc2>
  if (iphdr->ip_vhl != ((4 << 4) | (20 >> 2)))
    80006e16:	00054703          	lbu	a4,0(a0)
    80006e1a:	04500793          	li	a5,69
    80006e1e:	00f70863          	beq	a4,a5,80006e2e <net_rx+0xce>
  kfree(m);
    80006e22:	854a                	mv	a0,s2
    80006e24:	ffffa097          	auipc	ra,0xffffa
    80006e28:	a58080e7          	jalr	-1448(ra) # 8000087c <kfree>
}
    80006e2c:	b775                	j	80006dd8 <net_rx+0x78>
  if (in_cksum((unsigned char *)iphdr, sizeof(*iphdr)))
    80006e2e:	45d1                	li	a1,20
    80006e30:	00000097          	auipc	ra,0x0
    80006e34:	bc0080e7          	jalr	-1088(ra) # 800069f0 <in_cksum>
    80006e38:	f56d                	bnez	a0,80006e22 <net_rx+0xc2>
    80006e3a:	0064d783          	lhu	a5,6(s1)
    80006e3e:	0087d71b          	srliw	a4,a5,0x8
    80006e42:	0087979b          	slliw	a5,a5,0x8
    80006e46:	8fd9                	or	a5,a5,a4
  if (htons(iphdr->ip_off) != 0)
    80006e48:	17c2                	slli	a5,a5,0x30
    80006e4a:	93c1                	srli	a5,a5,0x30
    80006e4c:	fbf9                	bnez	a5,80006e22 <net_rx+0xc2>
  if (htonl(iphdr->ip_dst) != local_ip)
    80006e4e:	4898                	lw	a4,16(s1)
  return (((val & 0x000000ffUL) << 24) |
    80006e50:	0187179b          	slliw	a5,a4,0x18
          ((val & 0xff000000UL) >> 24));
    80006e54:	0187569b          	srliw	a3,a4,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006e58:	8fd5                	or	a5,a5,a3
          ((val & 0x0000ff00UL) << 8) |
    80006e5a:	0087169b          	slliw	a3,a4,0x8
    80006e5e:	00ff0637          	lui	a2,0xff0
    80006e62:	8ef1                	and	a3,a3,a2
          ((val & 0x00ff0000UL) >> 8) |
    80006e64:	8fd5                	or	a5,a5,a3
    80006e66:	0087571b          	srliw	a4,a4,0x8
    80006e6a:	66c1                	lui	a3,0x10
    80006e6c:	f0068693          	addi	a3,a3,-256 # ff00 <_entry-0x7fff0100>
    80006e70:	8f75                	and	a4,a4,a3
    80006e72:	8fd9                	or	a5,a5,a4
    80006e74:	2781                	sext.w	a5,a5
    80006e76:	0a000737          	lui	a4,0xa000
    80006e7a:	20f70713          	addi	a4,a4,527 # a00020f <_entry-0x75fffdf1>
    80006e7e:	fae792e3          	bne	a5,a4,80006e22 <net_rx+0xc2>
  if (iphdr->ip_p != IPPROTO_UDP)
    80006e82:	0094c703          	lbu	a4,9(s1)
    80006e86:	47c5                	li	a5,17
    80006e88:	f8f71de3          	bne	a4,a5,80006e22 <net_rx+0xc2>
  return (((val & 0x00ffU) << 8) |
    80006e8c:	0024d783          	lhu	a5,2(s1)
    80006e90:	0087d71b          	srliw	a4,a5,0x8
    80006e94:	0087999b          	slliw	s3,a5,0x8
    80006e98:	00e9e9b3          	or	s3,s3,a4
    80006e9c:	19c2                	slli	s3,s3,0x30
    80006e9e:	0309d993          	srli	s3,s3,0x30
  len = ntohs(iphdr->ip_len) - sizeof(*iphdr);
    80006ea2:	fec9879b          	addiw	a5,s3,-20
    80006ea6:	03079a13          	slli	s4,a5,0x30
    80006eaa:	030a5a13          	srli	s4,s4,0x30
  printf("r udp\n");
    80006eae:	00003517          	auipc	a0,0x3
    80006eb2:	d7a50513          	addi	a0,a0,-646 # 80009c28 <userret+0xb98>
    80006eb6:	ffff9097          	auipc	ra,0xffff9
    80006eba:	6fe080e7          	jalr	1790(ra) # 800005b4 <printf>
  udphdr = mbufpullhdr(m, *udphdr);
    80006ebe:	45a1                	li	a1,8
    80006ec0:	854a                	mv	a0,s2
    80006ec2:	00000097          	auipc	ra,0x0
    80006ec6:	ba2080e7          	jalr	-1118(ra) # 80006a64 <mbufpull>
    80006eca:	8aaa                	mv	s5,a0
  if (!udphdr)
    80006ecc:	c90d                	beqz	a0,80006efe <net_rx+0x19e>
    80006ece:	00455783          	lhu	a5,4(a0)
    80006ed2:	0087d71b          	srliw	a4,a5,0x8
    80006ed6:	0087979b          	slliw	a5,a5,0x8
    80006eda:	8fd9                	or	a5,a5,a4
  if (ntohs(udphdr->ulen) != len)
    80006edc:	2a01                	sext.w	s4,s4
    80006ede:	17c2                	slli	a5,a5,0x30
    80006ee0:	93c1                	srli	a5,a5,0x30
    80006ee2:	00fa1e63          	bne	s4,a5,80006efe <net_rx+0x19e>
  len -= sizeof(*udphdr);
    80006ee6:	fe49879b          	addiw	a5,s3,-28
  if (len > m->len)
    80006eea:	0107979b          	slliw	a5,a5,0x10
    80006eee:	0107d79b          	srliw	a5,a5,0x10
    80006ef2:	0007871b          	sext.w	a4,a5
    80006ef6:	01092583          	lw	a1,16(s2)
    80006efa:	00e5f863          	bgeu	a1,a4,80006f0a <net_rx+0x1aa>
  kfree(m);
    80006efe:	854a                	mv	a0,s2
    80006f00:	ffffa097          	auipc	ra,0xffffa
    80006f04:	97c080e7          	jalr	-1668(ra) # 8000087c <kfree>
}
    80006f08:	bdc1                	j	80006dd8 <net_rx+0x78>
  mbuftrim(m, m->len - len);
    80006f0a:	9d9d                	subw	a1,a1,a5
    80006f0c:	854a                	mv	a0,s2
    80006f0e:	00000097          	auipc	ra,0x0
    80006f12:	c64080e7          	jalr	-924(ra) # 80006b72 <mbuftrim>
  sip = ntohl(iphdr->ip_src);
    80006f16:	44dc                	lw	a5,12(s1)
    80006f18:	000ad703          	lhu	a4,0(s5)
    80006f1c:	0087569b          	srliw	a3,a4,0x8
    80006f20:	0087171b          	slliw	a4,a4,0x8
    80006f24:	8ed9                	or	a3,a3,a4
    80006f26:	002ad703          	lhu	a4,2(s5)
    80006f2a:	0087561b          	srliw	a2,a4,0x8
    80006f2e:	0087171b          	slliw	a4,a4,0x8
    80006f32:	8e59                	or	a2,a2,a4
  return (((val & 0x000000ffUL) << 24) |
    80006f34:	0187971b          	slliw	a4,a5,0x18
          ((val & 0xff000000UL) >> 24));
    80006f38:	0187d59b          	srliw	a1,a5,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006f3c:	8f4d                	or	a4,a4,a1
          ((val & 0x0000ff00UL) << 8) |
    80006f3e:	0087959b          	slliw	a1,a5,0x8
    80006f42:	00ff0537          	lui	a0,0xff0
    80006f46:	8de9                	and	a1,a1,a0
          ((val & 0x00ff0000UL) >> 8) |
    80006f48:	8f4d                	or	a4,a4,a1
    80006f4a:	0087d79b          	srliw	a5,a5,0x8
    80006f4e:	65c1                	lui	a1,0x10
    80006f50:	f0058593          	addi	a1,a1,-256 # ff00 <_entry-0x7fff0100>
    80006f54:	8fed                	and	a5,a5,a1
    80006f56:	8fd9                	or	a5,a5,a4
  sockrecvudp(m, sip, dport, sport);
    80006f58:	16c2                	slli	a3,a3,0x30
    80006f5a:	92c1                	srli	a3,a3,0x30
    80006f5c:	1642                	slli	a2,a2,0x30
    80006f5e:	9241                	srli	a2,a2,0x30
    80006f60:	0007859b          	sext.w	a1,a5
    80006f64:	854a                	mv	a0,s2
    80006f66:	00000097          	auipc	ra,0x0
    80006f6a:	5b0080e7          	jalr	1456(ra) # 80007516 <sockrecvudp>
  return;
    80006f6e:	b5ad                	j	80006dd8 <net_rx+0x78>
    printf("ARP\n");
    80006f70:	00003517          	auipc	a0,0x3
    80006f74:	cc050513          	addi	a0,a0,-832 # 80009c30 <userret+0xba0>
    80006f78:	ffff9097          	auipc	ra,0xffff9
    80006f7c:	63c080e7          	jalr	1596(ra) # 800005b4 <printf>
  printf("r arp\n");
    80006f80:	00003517          	auipc	a0,0x3
    80006f84:	cb850513          	addi	a0,a0,-840 # 80009c38 <userret+0xba8>
    80006f88:	ffff9097          	auipc	ra,0xffff9
    80006f8c:	62c080e7          	jalr	1580(ra) # 800005b4 <printf>
  arphdr = mbufpullhdr(m, *arphdr);
    80006f90:	45f1                	li	a1,28
    80006f92:	854a                	mv	a0,s2
    80006f94:	00000097          	auipc	ra,0x0
    80006f98:	ad0080e7          	jalr	-1328(ra) # 80006a64 <mbufpull>
    80006f9c:	84aa                	mv	s1,a0
  if (!arphdr)
    80006f9e:	c179                	beqz	a0,80007064 <net_rx+0x304>
  if (ntohs(arphdr->hrd) != ARP_HRD_ETHER ||
    80006fa0:	00054783          	lbu	a5,0(a0)
    80006fa4:	00154703          	lbu	a4,1(a0)
    80006fa8:	0722                	slli	a4,a4,0x8
    80006faa:	8fd9                	or	a5,a5,a4
  return (((val & 0x00ffU) << 8) |
    80006fac:	0087979b          	slliw	a5,a5,0x8
    80006fb0:	8321                	srli	a4,a4,0x8
    80006fb2:	8fd9                	or	a5,a5,a4
    80006fb4:	17c2                	slli	a5,a5,0x30
    80006fb6:	93c1                	srli	a5,a5,0x30
    80006fb8:	4705                	li	a4,1
    80006fba:	0ae79563          	bne	a5,a4,80007064 <net_rx+0x304>
      ntohs(arphdr->pro) != ETHTYPE_IP ||
    80006fbe:	00254783          	lbu	a5,2(a0)
    80006fc2:	00354703          	lbu	a4,3(a0)
    80006fc6:	0722                	slli	a4,a4,0x8
    80006fc8:	8fd9                	or	a5,a5,a4
    80006fca:	0087979b          	slliw	a5,a5,0x8
    80006fce:	8321                	srli	a4,a4,0x8
    80006fd0:	8fd9                	or	a5,a5,a4
  if (ntohs(arphdr->hrd) != ARP_HRD_ETHER ||
    80006fd2:	0107979b          	slliw	a5,a5,0x10
    80006fd6:	0107d79b          	srliw	a5,a5,0x10
    80006fda:	8007879b          	addiw	a5,a5,-2048
    80006fde:	e3d9                	bnez	a5,80007064 <net_rx+0x304>
      ntohs(arphdr->pro) != ETHTYPE_IP ||
    80006fe0:	00454703          	lbu	a4,4(a0)
    80006fe4:	4799                	li	a5,6
    80006fe6:	06f71f63          	bne	a4,a5,80007064 <net_rx+0x304>
      arphdr->hln != ETHADDR_LEN ||
    80006fea:	00554703          	lbu	a4,5(a0)
    80006fee:	4791                	li	a5,4
    80006ff0:	06f71a63          	bne	a4,a5,80007064 <net_rx+0x304>
  if (ntohs(arphdr->op) != ARP_OP_REQUEST || tip != local_ip)
    80006ff4:	00654783          	lbu	a5,6(a0)
    80006ff8:	00754703          	lbu	a4,7(a0)
    80006ffc:	0722                	slli	a4,a4,0x8
    80006ffe:	8fd9                	or	a5,a5,a4
    80007000:	0087979b          	slliw	a5,a5,0x8
    80007004:	8321                	srli	a4,a4,0x8
    80007006:	8fd9                	or	a5,a5,a4
    80007008:	17c2                	slli	a5,a5,0x30
    8000700a:	93c1                	srli	a5,a5,0x30
    8000700c:	4705                	li	a4,1
    8000700e:	04e79b63          	bne	a5,a4,80007064 <net_rx+0x304>
  tip = ntohl(arphdr->tip); // target IP address
    80007012:	01854783          	lbu	a5,24(a0)
    80007016:	01954703          	lbu	a4,25(a0)
    8000701a:	0722                	slli	a4,a4,0x8
    8000701c:	8f5d                	or	a4,a4,a5
    8000701e:	01a54783          	lbu	a5,26(a0)
    80007022:	07c2                	slli	a5,a5,0x10
    80007024:	8f5d                	or	a4,a4,a5
    80007026:	01b54783          	lbu	a5,27(a0)
    8000702a:	07e2                	slli	a5,a5,0x18
    8000702c:	8fd9                	or	a5,a5,a4
    8000702e:	0007871b          	sext.w	a4,a5
  return (((val & 0x000000ffUL) << 24) |
    80007032:	0187979b          	slliw	a5,a5,0x18
          ((val & 0xff000000UL) >> 24));
    80007036:	0187569b          	srliw	a3,a4,0x18
          ((val & 0x00ff0000UL) >> 8) |
    8000703a:	8fd5                	or	a5,a5,a3
          ((val & 0x0000ff00UL) << 8) |
    8000703c:	0087169b          	slliw	a3,a4,0x8
    80007040:	00ff0637          	lui	a2,0xff0
    80007044:	8ef1                	and	a3,a3,a2
          ((val & 0x00ff0000UL) >> 8) |
    80007046:	8fd5                	or	a5,a5,a3
    80007048:	0087571b          	srliw	a4,a4,0x8
    8000704c:	66c1                	lui	a3,0x10
    8000704e:	f0068693          	addi	a3,a3,-256 # ff00 <_entry-0x7fff0100>
    80007052:	8f75                	and	a4,a4,a3
    80007054:	8fd9                	or	a5,a5,a4
  if (ntohs(arphdr->op) != ARP_OP_REQUEST || tip != local_ip)
    80007056:	2781                	sext.w	a5,a5
    80007058:	0a000737          	lui	a4,0xa000
    8000705c:	20f70713          	addi	a4,a4,527 # a00020f <_entry-0x75fffdf1>
    80007060:	00e78863          	beq	a5,a4,80007070 <net_rx+0x310>
  kfree(m);
    80007064:	854a                	mv	a0,s2
    80007066:	ffffa097          	auipc	ra,0xffffa
    8000706a:	816080e7          	jalr	-2026(ra) # 8000087c <kfree>
}
    8000706e:	b3ad                	j	80006dd8 <net_rx+0x78>
  memmove(smac, arphdr->sha, ETHADDR_LEN); // sender's ethernet address
    80007070:	4619                	li	a2,6
    80007072:	00850593          	addi	a1,a0,8
    80007076:	fb840513          	addi	a0,s0,-72
    8000707a:	ffffa097          	auipc	ra,0xffffa
    8000707e:	d60080e7          	jalr	-672(ra) # 80000dda <memmove>
  sip = ntohl(arphdr->sip); // sender's IP address (qemu's slirp)
    80007082:	00e4c783          	lbu	a5,14(s1)
    80007086:	00f4c703          	lbu	a4,15(s1)
    8000708a:	0722                	slli	a4,a4,0x8
    8000708c:	8f5d                	or	a4,a4,a5
    8000708e:	0104c783          	lbu	a5,16(s1)
    80007092:	07c2                	slli	a5,a5,0x10
    80007094:	8f5d                	or	a4,a4,a5
    80007096:	0114c783          	lbu	a5,17(s1)
    8000709a:	07e2                	slli	a5,a5,0x18
    8000709c:	8fd9                	or	a5,a5,a4
    8000709e:	0007871b          	sext.w	a4,a5
  return (((val & 0x000000ffUL) << 24) |
    800070a2:	0187949b          	slliw	s1,a5,0x18
          ((val & 0xff000000UL) >> 24));
    800070a6:	0187579b          	srliw	a5,a4,0x18
          ((val & 0x00ff0000UL) >> 8) |
    800070aa:	8cdd                	or	s1,s1,a5
          ((val & 0x0000ff00UL) << 8) |
    800070ac:	0087179b          	slliw	a5,a4,0x8
    800070b0:	00ff06b7          	lui	a3,0xff0
    800070b4:	8ff5                	and	a5,a5,a3
          ((val & 0x00ff0000UL) >> 8) |
    800070b6:	8cdd                	or	s1,s1,a5
    800070b8:	0087579b          	srliw	a5,a4,0x8
    800070bc:	6741                	lui	a4,0x10
    800070be:	f0070713          	addi	a4,a4,-256 # ff00 <_entry-0x7fff0100>
    800070c2:	8ff9                	and	a5,a5,a4
    800070c4:	8cdd                	or	s1,s1,a5
    800070c6:	2481                	sext.w	s1,s1
  m = mbufalloc(MBUF_DEFAULT_HEADROOM);
    800070c8:	08000513          	li	a0,128
    800070cc:	00000097          	auipc	ra,0x0
    800070d0:	ac8080e7          	jalr	-1336(ra) # 80006b94 <mbufalloc>
    800070d4:	8a2a                	mv	s4,a0
  if (!m)
    800070d6:	d559                	beqz	a0,80007064 <net_rx+0x304>
  arphdr = mbufputhdr(m, *arphdr);
    800070d8:	45f1                	li	a1,28
    800070da:	00000097          	auipc	ra,0x0
    800070de:	a5e080e7          	jalr	-1442(ra) # 80006b38 <mbufput>
    800070e2:	89aa                	mv	s3,a0
  arphdr->hrd = htons(ARP_HRD_ETHER);
    800070e4:	00050023          	sb	zero,0(a0)
    800070e8:	4785                	li	a5,1
    800070ea:	00f500a3          	sb	a5,1(a0)
  arphdr->pro = htons(ETHTYPE_IP);
    800070ee:	47a1                	li	a5,8
    800070f0:	00f50123          	sb	a5,2(a0)
    800070f4:	000501a3          	sb	zero,3(a0)
  arphdr->hln = ETHADDR_LEN;
    800070f8:	4799                	li	a5,6
    800070fa:	00f50223          	sb	a5,4(a0)
  arphdr->pln = sizeof(uint32);
    800070fe:	4791                	li	a5,4
    80007100:	00f502a3          	sb	a5,5(a0)
  arphdr->op = htons(op);
    80007104:	00050323          	sb	zero,6(a0)
    80007108:	4a89                	li	s5,2
    8000710a:	015503a3          	sb	s5,7(a0)
  memmove(arphdr->sha, local_mac, ETHADDR_LEN);
    8000710e:	4619                	li	a2,6
    80007110:	00003597          	auipc	a1,0x3
    80007114:	f3858593          	addi	a1,a1,-200 # 8000a048 <local_mac>
    80007118:	0521                	addi	a0,a0,8
    8000711a:	ffffa097          	auipc	ra,0xffffa
    8000711e:	cc0080e7          	jalr	-832(ra) # 80000dda <memmove>
  arphdr->sip = htonl(local_ip);
    80007122:	47a9                	li	a5,10
    80007124:	00f98723          	sb	a5,14(s3)
    80007128:	000987a3          	sb	zero,15(s3)
    8000712c:	01598823          	sb	s5,16(s3)
    80007130:	47bd                	li	a5,15
    80007132:	00f988a3          	sb	a5,17(s3)
  memmove(arphdr->tha, dmac, ETHADDR_LEN);
    80007136:	4619                	li	a2,6
    80007138:	fb840593          	addi	a1,s0,-72
    8000713c:	01298513          	addi	a0,s3,18
    80007140:	ffffa097          	auipc	ra,0xffffa
    80007144:	c9a080e7          	jalr	-870(ra) # 80000dda <memmove>
  return (((val & 0x000000ffUL) << 24) |
    80007148:	0184971b          	slliw	a4,s1,0x18
          ((val & 0xff000000UL) >> 24));
    8000714c:	0184d79b          	srliw	a5,s1,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80007150:	8f5d                	or	a4,a4,a5
          ((val & 0x0000ff00UL) << 8) |
    80007152:	0084979b          	slliw	a5,s1,0x8
    80007156:	00ff06b7          	lui	a3,0xff0
    8000715a:	8ff5                	and	a5,a5,a3
          ((val & 0x00ff0000UL) >> 8) |
    8000715c:	8f5d                	or	a4,a4,a5
    8000715e:	0084d79b          	srliw	a5,s1,0x8
    80007162:	66c1                	lui	a3,0x10
    80007164:	f0068693          	addi	a3,a3,-256 # ff00 <_entry-0x7fff0100>
    80007168:	8ff5                	and	a5,a5,a3
    8000716a:	8fd9                	or	a5,a5,a4
  arphdr->tip = htonl(dip);
    8000716c:	00e98c23          	sb	a4,24(s3)
    80007170:	0087d71b          	srliw	a4,a5,0x8
    80007174:	00e98ca3          	sb	a4,25(s3)
    80007178:	0107d71b          	srliw	a4,a5,0x10
    8000717c:	00e98d23          	sb	a4,26(s3)
    80007180:	0187d79b          	srliw	a5,a5,0x18
    80007184:	00f98da3          	sb	a5,27(s3)
  net_tx_eth(m, ETHTYPE_ARP);
    80007188:	6585                	lui	a1,0x1
    8000718a:	80658593          	addi	a1,a1,-2042 # 806 <_entry-0x7ffff7fa>
    8000718e:	8552                	mv	a0,s4
    80007190:	00000097          	auipc	ra,0x0
    80007194:	930080e7          	jalr	-1744(ra) # 80006ac0 <net_tx_eth>
  return 0;
    80007198:	b5f1                	j	80007064 <net_rx+0x304>

000000008000719a <sockinit>:
static struct spinlock lock;
static struct sock *sockets;

void
sockinit(void)
{
    8000719a:	1141                	addi	sp,sp,-16
    8000719c:	e406                	sd	ra,8(sp)
    8000719e:	e022                	sd	s0,0(sp)
    800071a0:	0800                	addi	s0,sp,16
  initlock(&lock, "socktbl");
    800071a2:	00003597          	auipc	a1,0x3
    800071a6:	aae58593          	addi	a1,a1,-1362 # 80009c50 <userret+0xbc0>
    800071aa:	00022517          	auipc	a0,0x22
    800071ae:	19650513          	addi	a0,a0,406 # 80029340 <lock>
    800071b2:	ffffa097          	auipc	ra,0xffffa
    800071b6:	826080e7          	jalr	-2010(ra) # 800009d8 <initlock>
}
    800071ba:	60a2                	ld	ra,8(sp)
    800071bc:	6402                	ld	s0,0(sp)
    800071be:	0141                	addi	sp,sp,16
    800071c0:	8082                	ret

00000000800071c2 <sockalloc>:

int
sockalloc(struct file **f, uint32 raddr, uint16 lport, uint16 rport)
{
    800071c2:	7139                	addi	sp,sp,-64
    800071c4:	fc06                	sd	ra,56(sp)
    800071c6:	f822                	sd	s0,48(sp)
    800071c8:	f426                	sd	s1,40(sp)
    800071ca:	f04a                	sd	s2,32(sp)
    800071cc:	ec4e                	sd	s3,24(sp)
    800071ce:	e852                	sd	s4,16(sp)
    800071d0:	e456                	sd	s5,8(sp)
    800071d2:	0080                	addi	s0,sp,64
    800071d4:	892a                	mv	s2,a0
    800071d6:	84ae                	mv	s1,a1
    800071d8:	8a32                	mv	s4,a2
    800071da:	89b6                	mv	s3,a3
  struct sock *si, *pos;

  si = 0;
  *f = 0;
    800071dc:	00053023          	sd	zero,0(a0)
  if ((*f = filealloc()) == 0)
    800071e0:	ffffd097          	auipc	ra,0xffffd
    800071e4:	422080e7          	jalr	1058(ra) # 80004602 <filealloc>
    800071e8:	00a93023          	sd	a0,0(s2)
    800071ec:	c975                	beqz	a0,800072e0 <sockalloc+0x11e>
    goto bad;
  if ((si = (struct sock*)kalloc()) == 0)
    800071ee:	ffff9097          	auipc	ra,0xffff9
    800071f2:	78a080e7          	jalr	1930(ra) # 80000978 <kalloc>
    800071f6:	8aaa                	mv	s5,a0
    800071f8:	c15d                	beqz	a0,8000729e <sockalloc+0xdc>
    goto bad;

  // initialize objects
  si->raddr = raddr;
    800071fa:	c504                	sw	s1,8(a0)
  si->lport = lport;
    800071fc:	01451623          	sh	s4,12(a0)
  si->rport = rport;
    80007200:	01351723          	sh	s3,14(a0)
  initlock(&si->lock, "sock");
    80007204:	00003597          	auipc	a1,0x3
    80007208:	a5458593          	addi	a1,a1,-1452 # 80009c58 <userret+0xbc8>
    8000720c:	0541                	addi	a0,a0,16
    8000720e:	ffff9097          	auipc	ra,0xffff9
    80007212:	7ca080e7          	jalr	1994(ra) # 800009d8 <initlock>
  mbufq_init(&si->rxq);
    80007216:	030a8513          	addi	a0,s5,48
    8000721a:	00000097          	auipc	ra,0x0
    8000721e:	a32080e7          	jalr	-1486(ra) # 80006c4c <mbufq_init>
  (*f)->type = FD_SOCK;
    80007222:	00093783          	ld	a5,0(s2)
    80007226:	4711                	li	a4,4
    80007228:	c398                	sw	a4,0(a5)
  (*f)->readable = 1;
    8000722a:	00093703          	ld	a4,0(s2)
    8000722e:	4785                	li	a5,1
    80007230:	00f70423          	sb	a5,8(a4)
  (*f)->writable = 1;
    80007234:	00093703          	ld	a4,0(s2)
    80007238:	00f704a3          	sb	a5,9(a4)
  (*f)->sock = si;
    8000723c:	00093783          	ld	a5,0(s2)
    80007240:	0357b423          	sd	s5,40(a5)

  // add to list of sockets
  acquire(&lock);
    80007244:	00022517          	auipc	a0,0x22
    80007248:	0fc50513          	addi	a0,a0,252 # 80029340 <lock>
    8000724c:	ffffa097          	auipc	ra,0xffffa
    80007250:	860080e7          	jalr	-1952(ra) # 80000aac <acquire>
  pos = sockets;
    80007254:	00022597          	auipc	a1,0x22
    80007258:	15c5b583          	ld	a1,348(a1) # 800293b0 <sockets>
  while (pos) {
    8000725c:	c9b1                	beqz	a1,800072b0 <sockalloc+0xee>
  pos = sockets;
    8000725e:	87ae                	mv	a5,a1
    if (pos->raddr == raddr &&
    80007260:	000a061b          	sext.w	a2,s4
        pos->lport == lport &&
    80007264:	0009869b          	sext.w	a3,s3
    80007268:	a019                	j	8000726e <sockalloc+0xac>
	pos->rport == rport) {
      release(&lock);
      goto bad;
    }
    pos = pos->next;
    8000726a:	639c                	ld	a5,0(a5)
  while (pos) {
    8000726c:	c3b1                	beqz	a5,800072b0 <sockalloc+0xee>
    if (pos->raddr == raddr &&
    8000726e:	4798                	lw	a4,8(a5)
    80007270:	fe971de3          	bne	a4,s1,8000726a <sockalloc+0xa8>
    80007274:	00c7d703          	lhu	a4,12(a5)
    80007278:	fec719e3          	bne	a4,a2,8000726a <sockalloc+0xa8>
        pos->lport == lport &&
    8000727c:	00e7d703          	lhu	a4,14(a5)
    80007280:	fed715e3          	bne	a4,a3,8000726a <sockalloc+0xa8>
      release(&lock);
    80007284:	00022517          	auipc	a0,0x22
    80007288:	0bc50513          	addi	a0,a0,188 # 80029340 <lock>
    8000728c:	ffffa097          	auipc	ra,0xffffa
    80007290:	8f0080e7          	jalr	-1808(ra) # 80000b7c <release>
  release(&lock);
  return 0;

bad:
  if (si)
    kfree((char*)si);
    80007294:	8556                	mv	a0,s5
    80007296:	ffff9097          	auipc	ra,0xffff9
    8000729a:	5e6080e7          	jalr	1510(ra) # 8000087c <kfree>
  if (*f)
    8000729e:	00093503          	ld	a0,0(s2)
    800072a2:	c129                	beqz	a0,800072e4 <sockalloc+0x122>
    fileclose(*f);
    800072a4:	ffffd097          	auipc	ra,0xffffd
    800072a8:	41a080e7          	jalr	1050(ra) # 800046be <fileclose>
  return -1;
    800072ac:	557d                	li	a0,-1
    800072ae:	a005                	j	800072ce <sockalloc+0x10c>
  si->next = sockets;
    800072b0:	00bab023          	sd	a1,0(s5)
  sockets = si;
    800072b4:	00022797          	auipc	a5,0x22
    800072b8:	0f57be23          	sd	s5,252(a5) # 800293b0 <sockets>
  release(&lock);
    800072bc:	00022517          	auipc	a0,0x22
    800072c0:	08450513          	addi	a0,a0,132 # 80029340 <lock>
    800072c4:	ffffa097          	auipc	ra,0xffffa
    800072c8:	8b8080e7          	jalr	-1864(ra) # 80000b7c <release>
  return 0;
    800072cc:	4501                	li	a0,0
}
    800072ce:	70e2                	ld	ra,56(sp)
    800072d0:	7442                	ld	s0,48(sp)
    800072d2:	74a2                	ld	s1,40(sp)
    800072d4:	7902                	ld	s2,32(sp)
    800072d6:	69e2                	ld	s3,24(sp)
    800072d8:	6a42                	ld	s4,16(sp)
    800072da:	6aa2                	ld	s5,8(sp)
    800072dc:	6121                	addi	sp,sp,64
    800072de:	8082                	ret
  return -1;
    800072e0:	557d                	li	a0,-1
    800072e2:	b7f5                	j	800072ce <sockalloc+0x10c>
    800072e4:	557d                	li	a0,-1
    800072e6:	b7e5                	j	800072ce <sockalloc+0x10c>

00000000800072e8 <sockclose>:
// Add and wire in methods to handle closing, reading,
// and writing for network sockets.
//

void
sockclose(struct sock *si, int writable) {
    800072e8:	7179                	addi	sp,sp,-48
    800072ea:	f406                	sd	ra,40(sp)
    800072ec:	f022                	sd	s0,32(sp)
    800072ee:	ec26                	sd	s1,24(sp)
    800072f0:	e84a                	sd	s2,16(sp)
    800072f2:	e44e                	sd	s3,8(sp)
    800072f4:	1800                	addi	s0,sp,48
    800072f6:	892a                	mv	s2,a0
  struct sock *pos, *next;
  acquire(&lock);
    800072f8:	00022517          	auipc	a0,0x22
    800072fc:	04850513          	addi	a0,a0,72 # 80029340 <lock>
    80007300:	ffff9097          	auipc	ra,0xffff9
    80007304:	7ac080e7          	jalr	1964(ra) # 80000aac <acquire>
  acquire(&si->lock);
    80007308:	01090993          	addi	s3,s2,16
    8000730c:	854e                	mv	a0,s3
    8000730e:	ffff9097          	auipc	ra,0xffff9
    80007312:	79e080e7          	jalr	1950(ra) # 80000aac <acquire>

  // free outstanding mbufs
  while(!mbufq_empty(&si->rxq)) {
    80007316:	03090493          	addi	s1,s2,48
    8000731a:	8526                	mv	a0,s1
    8000731c:	00000097          	auipc	ra,0x0
    80007320:	91e080e7          	jalr	-1762(ra) # 80006c3a <mbufq_empty>
    80007324:	e919                	bnez	a0,8000733a <sockclose+0x52>
    mbuffree(mbufq_pophead(&si->rxq));
    80007326:	8526                	mv	a0,s1
    80007328:	00000097          	auipc	ra,0x0
    8000732c:	8fc080e7          	jalr	-1796(ra) # 80006c24 <mbufq_pophead>
    80007330:	00000097          	auipc	ra,0x0
    80007334:	8bc080e7          	jalr	-1860(ra) # 80006bec <mbuffree>
    80007338:	b7cd                	j	8000731a <sockclose+0x32>
  }

  // remove from sockets
  
  pos = sockets;
    8000733a:	00022617          	auipc	a2,0x22
    8000733e:	07663603          	ld	a2,118(a2) # 800293b0 <sockets>
  if (pos->raddr == si->raddr &&
      pos->lport == si->lport &&
    80007342:	00893683          	ld	a3,8(s2)
  if (pos->raddr == si->raddr &&
    80007346:	661c                	ld	a5,8(a2)
    80007348:	00d78a63          	beq	a5,a3,8000735c <sockclose+0x74>
  pos->rport == si->rport) {
    sockets = pos->next;
  } else {
    while(pos->next) {
    8000734c:	621c                	ld	a5,0(a2)
    8000734e:	cf81                	beqz	a5,80007366 <sockclose+0x7e>
      next = pos->next;
      if (next->raddr == si->raddr &&
    80007350:	6798                	ld	a4,8(a5)
    80007352:	fee69ee3          	bne	a3,a4,8000734e <sockclose+0x66>
          next->lport == si->lport &&
      next->rport == si->rport) {
        pos->next = next->next;
    80007356:	639c                	ld	a5,0(a5)
    80007358:	e21c                	sd	a5,0(a2)
        break;
    8000735a:	a031                	j	80007366 <sockclose+0x7e>
    sockets = pos->next;
    8000735c:	621c                	ld	a5,0(a2)
    8000735e:	00022717          	auipc	a4,0x22
    80007362:	04f73923          	sd	a5,82(a4) # 800293b0 <sockets>
      }
    }
  }
  release(&lock);
    80007366:	00022517          	auipc	a0,0x22
    8000736a:	fda50513          	addi	a0,a0,-38 # 80029340 <lock>
    8000736e:	ffffa097          	auipc	ra,0xffffa
    80007372:	80e080e7          	jalr	-2034(ra) # 80000b7c <release>

  // clean up
  release(&si->lock);
    80007376:	854e                	mv	a0,s3
    80007378:	ffffa097          	auipc	ra,0xffffa
    8000737c:	804080e7          	jalr	-2044(ra) # 80000b7c <release>
  kfree((char*)si);
    80007380:	854a                	mv	a0,s2
    80007382:	ffff9097          	auipc	ra,0xffff9
    80007386:	4fa080e7          	jalr	1274(ra) # 8000087c <kfree>
}
    8000738a:	70a2                	ld	ra,40(sp)
    8000738c:	7402                	ld	s0,32(sp)
    8000738e:	64e2                	ld	s1,24(sp)
    80007390:	6942                	ld	s2,16(sp)
    80007392:	69a2                	ld	s3,8(sp)
    80007394:	6145                	addi	sp,sp,48
    80007396:	8082                	ret

0000000080007398 <sockwrite>:

int
sockwrite(struct sock *si, uint64 addr, int n) {
    80007398:	7139                	addi	sp,sp,-64
    8000739a:	fc06                	sd	ra,56(sp)
    8000739c:	f822                	sd	s0,48(sp)
    8000739e:	f426                	sd	s1,40(sp)
    800073a0:	f04a                	sd	s2,32(sp)
    800073a2:	ec4e                	sd	s3,24(sp)
    800073a4:	e852                	sd	s4,16(sp)
    800073a6:	e456                	sd	s5,8(sp)
    800073a8:	e05a                	sd	s6,0(sp)
    800073aa:	0080                	addi	s0,sp,64
    800073ac:	84aa                	mv	s1,a0
    800073ae:	892e                	mv	s2,a1
    800073b0:	89b2                	mv	s3,a2
  struct mbuf *m;
  struct proc *pr = myproc();
    800073b2:	ffffa097          	auipc	ra,0xffffa
    800073b6:	6f0080e7          	jalr	1776(ra) # 80001aa2 <myproc>
    800073ba:	8aaa                	mv	s5,a0

  m = mbufalloc(MBUF_DEFAULT_HEADROOM);
    800073bc:	08000513          	li	a0,128
    800073c0:	fffff097          	auipc	ra,0xfffff
    800073c4:	7d4080e7          	jalr	2004(ra) # 80006b94 <mbufalloc>
    800073c8:	8a2a                	mv	s4,a0

  acquire(&si->lock);
    800073ca:	01048b13          	addi	s6,s1,16
    800073ce:	855a                	mv	a0,s6
    800073d0:	ffff9097          	auipc	ra,0xffff9
    800073d4:	6dc080e7          	jalr	1756(ra) # 80000aac <acquire>
  if (copyin(pr->pagetable, mbufput(m, n), addr, n) == -1) {
    800073d8:	058aba83          	ld	s5,88(s5)
    800073dc:	85ce                	mv	a1,s3
    800073de:	8552                	mv	a0,s4
    800073e0:	fffff097          	auipc	ra,0xfffff
    800073e4:	758080e7          	jalr	1880(ra) # 80006b38 <mbufput>
    800073e8:	85aa                	mv	a1,a0
    800073ea:	86ce                	mv	a3,s3
    800073ec:	864a                	mv	a2,s2
    800073ee:	8556                	mv	a0,s5
    800073f0:	ffffa097          	auipc	ra,0xffffa
    800073f4:	432080e7          	jalr	1074(ra) # 80001822 <copyin>
    800073f8:	57fd                	li	a5,-1
    800073fa:	02f50d63          	beq	a0,a5,80007434 <sockwrite+0x9c>
    release(&si->lock);
    return -1;
  }
  net_tx_udp(m, si->raddr ,si->lport, si->rport);
    800073fe:	00e4d683          	lhu	a3,14(s1)
    80007402:	00c4d603          	lhu	a2,12(s1)
    80007406:	448c                	lw	a1,8(s1)
    80007408:	8552                	mv	a0,s4
    8000740a:	00000097          	auipc	ra,0x0
    8000740e:	852080e7          	jalr	-1966(ra) # 80006c5c <net_tx_udp>
  release(&si->lock);
    80007412:	855a                	mv	a0,s6
    80007414:	ffff9097          	auipc	ra,0xffff9
    80007418:	768080e7          	jalr	1896(ra) # 80000b7c <release>

  return n;
    8000741c:	894e                	mv	s2,s3
}
    8000741e:	854a                	mv	a0,s2
    80007420:	70e2                	ld	ra,56(sp)
    80007422:	7442                	ld	s0,48(sp)
    80007424:	74a2                	ld	s1,40(sp)
    80007426:	7902                	ld	s2,32(sp)
    80007428:	69e2                	ld	s3,24(sp)
    8000742a:	6a42                	ld	s4,16(sp)
    8000742c:	6aa2                	ld	s5,8(sp)
    8000742e:	6b02                	ld	s6,0(sp)
    80007430:	6121                	addi	sp,sp,64
    80007432:	8082                	ret
    80007434:	892a                	mv	s2,a0
    release(&si->lock);
    80007436:	855a                	mv	a0,s6
    80007438:	ffff9097          	auipc	ra,0xffff9
    8000743c:	744080e7          	jalr	1860(ra) # 80000b7c <release>
    return -1;
    80007440:	bff9                	j	8000741e <sockwrite+0x86>

0000000080007442 <sockread>:

int
sockread(struct sock *si, uint64 addr, int n) {
    80007442:	715d                	addi	sp,sp,-80
    80007444:	e486                	sd	ra,72(sp)
    80007446:	e0a2                	sd	s0,64(sp)
    80007448:	fc26                	sd	s1,56(sp)
    8000744a:	f84a                	sd	s2,48(sp)
    8000744c:	f44e                	sd	s3,40(sp)
    8000744e:	f052                	sd	s4,32(sp)
    80007450:	ec56                	sd	s5,24(sp)
    80007452:	e85a                	sd	s6,16(sp)
    80007454:	e45e                	sd	s7,8(sp)
    80007456:	0880                	addi	s0,sp,80
    80007458:	892a                	mv	s2,a0
    8000745a:	89ae                	mv	s3,a1
    8000745c:	8ab2                	mv	s5,a2
  struct mbuf *m;
  struct proc *pr = myproc();
    8000745e:	ffffa097          	auipc	ra,0xffffa
    80007462:	644080e7          	jalr	1604(ra) # 80001aa2 <myproc>
    80007466:	8b2a                	mv	s6,a0
  int i;

  acquire(&si->lock);
    80007468:	01090a13          	addi	s4,s2,16
    8000746c:	8552                	mv	a0,s4
    8000746e:	ffff9097          	auipc	ra,0xffff9
    80007472:	63e080e7          	jalr	1598(ra) # 80000aac <acquire>
  while(mbufq_empty(&si->rxq)) {
    80007476:	03090913          	addi	s2,s2,48
    8000747a:	854a                	mv	a0,s2
    8000747c:	fffff097          	auipc	ra,0xfffff
    80007480:	7be080e7          	jalr	1982(ra) # 80006c3a <mbufq_empty>
    80007484:	84aa                	mv	s1,a0
    80007486:	c50d                	beqz	a0,800074b0 <sockread+0x6e>
    if(myproc()->killed){
    80007488:	ffffa097          	auipc	ra,0xffffa
    8000748c:	61a080e7          	jalr	1562(ra) # 80001aa2 <myproc>
    80007490:	5d1c                	lw	a5,56(a0)
    80007492:	eb81                	bnez	a5,800074a2 <sockread+0x60>
      release(&si->lock);
      return -1;
    }
    sleep(&si->rxq, &si->lock);
    80007494:	85d2                	mv	a1,s4
    80007496:	854a                	mv	a0,s2
    80007498:	ffffb097          	auipc	ra,0xffffb
    8000749c:	dc6080e7          	jalr	-570(ra) # 8000225e <sleep>
    800074a0:	bfe9                	j	8000747a <sockread+0x38>
      release(&si->lock);
    800074a2:	8552                	mv	a0,s4
    800074a4:	ffff9097          	auipc	ra,0xffff9
    800074a8:	6d8080e7          	jalr	1752(ra) # 80000b7c <release>
      return -1;
    800074ac:	54fd                	li	s1,-1
    800074ae:	a881                	j	800074fe <sockread+0xbc>
  }
  m = mbufq_pophead(&si->rxq);
    800074b0:	854a                	mv	a0,s2
    800074b2:	fffff097          	auipc	ra,0xfffff
    800074b6:	772080e7          	jalr	1906(ra) # 80006c24 <mbufq_pophead>
    800074ba:	892a                	mv	s2,a0
  for(i = 0; i < n; i++){
    800074bc:	03505c63          	blez	s5,800074f4 <sockread+0xb2>
    if(m->len == 0 || copyout(pr->pagetable, addr + i, m->head, 1) == -1)
    800074c0:	5bfd                	li	s7,-1
    800074c2:	01092783          	lw	a5,16(s2)
    800074c6:	c79d                	beqz	a5,800074f4 <sockread+0xb2>
    800074c8:	4685                	li	a3,1
    800074ca:	00893603          	ld	a2,8(s2)
    800074ce:	85ce                	mv	a1,s3
    800074d0:	058b3503          	ld	a0,88(s6)
    800074d4:	ffffa097          	auipc	ra,0xffffa
    800074d8:	2c2080e7          	jalr	706(ra) # 80001796 <copyout>
    800074dc:	01750c63          	beq	a0,s7,800074f4 <sockread+0xb2>
      break;
    mbufpull(m, 1);
    800074e0:	4585                	li	a1,1
    800074e2:	854a                	mv	a0,s2
    800074e4:	fffff097          	auipc	ra,0xfffff
    800074e8:	580080e7          	jalr	1408(ra) # 80006a64 <mbufpull>
  for(i = 0; i < n; i++){
    800074ec:	2485                	addiw	s1,s1,1
    800074ee:	0985                	addi	s3,s3,1
    800074f0:	fc9a99e3          	bne	s5,s1,800074c2 <sockread+0x80>
  }
  release(&si->lock);
    800074f4:	8552                	mv	a0,s4
    800074f6:	ffff9097          	auipc	ra,0xffff9
    800074fa:	686080e7          	jalr	1670(ra) # 80000b7c <release>
  return i;
}
    800074fe:	8526                	mv	a0,s1
    80007500:	60a6                	ld	ra,72(sp)
    80007502:	6406                	ld	s0,64(sp)
    80007504:	74e2                	ld	s1,56(sp)
    80007506:	7942                	ld	s2,48(sp)
    80007508:	79a2                	ld	s3,40(sp)
    8000750a:	7a02                	ld	s4,32(sp)
    8000750c:	6ae2                	ld	s5,24(sp)
    8000750e:	6b42                	ld	s6,16(sp)
    80007510:	6ba2                	ld	s7,8(sp)
    80007512:	6161                	addi	sp,sp,80
    80007514:	8082                	ret

0000000080007516 <sockrecvudp>:

// called by protocol handler layer to deliver UDP packets
void
sockrecvudp(struct mbuf *m, uint32 raddr, uint16 lport, uint16 rport)
{
    80007516:	7139                	addi	sp,sp,-64
    80007518:	fc06                	sd	ra,56(sp)
    8000751a:	f822                	sd	s0,48(sp)
    8000751c:	f426                	sd	s1,40(sp)
    8000751e:	f04a                	sd	s2,32(sp)
    80007520:	ec4e                	sd	s3,24(sp)
    80007522:	e852                	sd	s4,16(sp)
    80007524:	e456                	sd	s5,8(sp)
    80007526:	0080                	addi	s0,sp,64
    80007528:	8a2a                	mv	s4,a0
    8000752a:	892e                	mv	s2,a1
    8000752c:	89b2                	mv	s3,a2
    8000752e:	8ab6                	mv	s5,a3
  // Find the socket that handles this mbuf and deliver it, waking
  // any sleeping reader. Free the mbuf if there are no sockets
  // registered to handle it.
  //
  struct sock *si;
  acquire(&lock);
    80007530:	00022517          	auipc	a0,0x22
    80007534:	e1050513          	addi	a0,a0,-496 # 80029340 <lock>
    80007538:	ffff9097          	auipc	ra,0xffff9
    8000753c:	574080e7          	jalr	1396(ra) # 80000aac <acquire>
  si = sockets;
    80007540:	00022497          	auipc	s1,0x22
    80007544:	e704b483          	ld	s1,-400(s1) # 800293b0 <sockets>
  while(si) {
    80007548:	ccad                	beqz	s1,800075c2 <sockrecvudp+0xac>
    if (si->raddr == raddr &&
    8000754a:	0009871b          	sext.w	a4,s3
        si->lport == lport &&
    8000754e:	000a869b          	sext.w	a3,s5
    80007552:	a019                	j	80007558 <sockrecvudp+0x42>
	si->rport == rport) {
      release(&lock);
      break;
    }
    si = si->next;
    80007554:	6084                	ld	s1,0(s1)
  while(si) {
    80007556:	c4b5                	beqz	s1,800075c2 <sockrecvudp+0xac>
    if (si->raddr == raddr &&
    80007558:	449c                	lw	a5,8(s1)
    8000755a:	ff279de3          	bne	a5,s2,80007554 <sockrecvudp+0x3e>
    8000755e:	00c4d783          	lhu	a5,12(s1)
    80007562:	fee799e3          	bne	a5,a4,80007554 <sockrecvudp+0x3e>
        si->lport == lport &&
    80007566:	00e4d783          	lhu	a5,14(s1)
    8000756a:	fed795e3          	bne	a5,a3,80007554 <sockrecvudp+0x3e>
      release(&lock);
    8000756e:	00022517          	auipc	a0,0x22
    80007572:	dd250513          	addi	a0,a0,-558 # 80029340 <lock>
    80007576:	ffff9097          	auipc	ra,0xffff9
    8000757a:	606080e7          	jalr	1542(ra) # 80000b7c <release>
  }
  if (!si) {
    release(&lock);
  }
  if (si) {
    acquire(&si->lock);
    8000757e:	01048913          	addi	s2,s1,16
    80007582:	854a                	mv	a0,s2
    80007584:	ffff9097          	auipc	ra,0xffff9
    80007588:	528080e7          	jalr	1320(ra) # 80000aac <acquire>
    mbufq_pushtail(&si->rxq, m);
    8000758c:	03048493          	addi	s1,s1,48
    80007590:	85d2                	mv	a1,s4
    80007592:	8526                	mv	a0,s1
    80007594:	fffff097          	auipc	ra,0xfffff
    80007598:	670080e7          	jalr	1648(ra) # 80006c04 <mbufq_pushtail>
    release(&si->lock);
    8000759c:	854a                	mv	a0,s2
    8000759e:	ffff9097          	auipc	ra,0xffff9
    800075a2:	5de080e7          	jalr	1502(ra) # 80000b7c <release>
    wakeup(&si->rxq);
    800075a6:	8526                	mv	a0,s1
    800075a8:	ffffb097          	auipc	ra,0xffffb
    800075ac:	e3c080e7          	jalr	-452(ra) # 800023e4 <wakeup>
  } else {
    mbuffree(m);
  }
}
    800075b0:	70e2                	ld	ra,56(sp)
    800075b2:	7442                	ld	s0,48(sp)
    800075b4:	74a2                	ld	s1,40(sp)
    800075b6:	7902                	ld	s2,32(sp)
    800075b8:	69e2                	ld	s3,24(sp)
    800075ba:	6a42                	ld	s4,16(sp)
    800075bc:	6aa2                	ld	s5,8(sp)
    800075be:	6121                	addi	sp,sp,64
    800075c0:	8082                	ret
    release(&lock);
    800075c2:	00022517          	auipc	a0,0x22
    800075c6:	d7e50513          	addi	a0,a0,-642 # 80029340 <lock>
    800075ca:	ffff9097          	auipc	ra,0xffff9
    800075ce:	5b2080e7          	jalr	1458(ra) # 80000b7c <release>
    mbuffree(m);
    800075d2:	8552                	mv	a0,s4
    800075d4:	fffff097          	auipc	ra,0xfffff
    800075d8:	618080e7          	jalr	1560(ra) # 80006bec <mbuffree>
    800075dc:	bfd1                	j	800075b0 <sockrecvudp+0x9a>

00000000800075de <pci_init>:
#include "proc.h"
#include "defs.h"

void
pci_init()
{
    800075de:	715d                	addi	sp,sp,-80
    800075e0:	e486                	sd	ra,72(sp)
    800075e2:	e0a2                	sd	s0,64(sp)
    800075e4:	fc26                	sd	s1,56(sp)
    800075e6:	f84a                	sd	s2,48(sp)
    800075e8:	f44e                	sd	s3,40(sp)
    800075ea:	f052                	sd	s4,32(sp)
    800075ec:	ec56                	sd	s5,24(sp)
    800075ee:	e85a                	sd	s6,16(sp)
    800075f0:	e45e                	sd	s7,8(sp)
    800075f2:	0880                	addi	s0,sp,80
    800075f4:	300004b7          	lui	s1,0x30000
    uint32 off = (bus << 16) | (dev << 11) | (func << 8) | (offset);
    volatile uint32 *base = ecam + off;
    uint32 id = base[0];
    
    // 100e:8086 is an e1000
    if(id == 0x100e8086){
    800075f8:	100e8937          	lui	s2,0x100e8
    800075fc:	08690913          	addi	s2,s2,134 # 100e8086 <_entry-0x6ff17f7a>
      // command and status register.
      // bit 0 : I/O access enable
      // bit 1 : memory access enable
      // bit 2 : enable mastering
      base[1] = 7;
    80007600:	4b9d                	li	s7,7
      for(int i = 0; i < 6; i++){
        uint32 old = base[4+i];

        // writing all 1's to the BAR causes it to be
        // replaced with its size.
        base[4+i] = 0xffffffff;
    80007602:	5afd                	li	s5,-1
        base[4+i] = old;
      }

      // tell the e1000 to reveal its registers at
      // physical address 0x40000000.
      base[4+0] = e1000_regs;
    80007604:	40000b37          	lui	s6,0x40000
    80007608:	6a09                	lui	s4,0x2
  for(int dev = 0; dev < 32; dev++){
    8000760a:	300409b7          	lui	s3,0x30040
    8000760e:	a819                	j	80007624 <pci_init+0x46>
      base[4+0] = e1000_regs;
    80007610:	0166a823          	sw	s6,16(a3)

      e1000_init((uint32*)e1000_regs);
    80007614:	855a                	mv	a0,s6
    80007616:	fffff097          	auipc	ra,0xfffff
    8000761a:	fee080e7          	jalr	-18(ra) # 80006604 <e1000_init>
  for(int dev = 0; dev < 32; dev++){
    8000761e:	94d2                	add	s1,s1,s4
    80007620:	03348a63          	beq	s1,s3,80007654 <pci_init+0x76>
    volatile uint32 *base = ecam + off;
    80007624:	86a6                	mv	a3,s1
    uint32 id = base[0];
    80007626:	409c                	lw	a5,0(s1)
    80007628:	2781                	sext.w	a5,a5
    if(id == 0x100e8086){
    8000762a:	ff279ae3          	bne	a5,s2,8000761e <pci_init+0x40>
      base[1] = 7;
    8000762e:	0174a223          	sw	s7,4(s1) # 30000004 <_entry-0x4ffffffc>
      __sync_synchronize();
    80007632:	0ff0000f          	fence
      for(int i = 0; i < 6; i++){
    80007636:	01048793          	addi	a5,s1,16
    8000763a:	02848613          	addi	a2,s1,40
        uint32 old = base[4+i];
    8000763e:	4398                	lw	a4,0(a5)
    80007640:	2701                	sext.w	a4,a4
        base[4+i] = 0xffffffff;
    80007642:	0157a023          	sw	s5,0(a5)
        __sync_synchronize();
    80007646:	0ff0000f          	fence
        base[4+i] = old;
    8000764a:	c398                	sw	a4,0(a5)
      for(int i = 0; i < 6; i++){
    8000764c:	0791                	addi	a5,a5,4
    8000764e:	fec798e3          	bne	a5,a2,8000763e <pci_init+0x60>
    80007652:	bf7d                	j	80007610 <pci_init+0x32>
    }
  }
}
    80007654:	60a6                	ld	ra,72(sp)
    80007656:	6406                	ld	s0,64(sp)
    80007658:	74e2                	ld	s1,56(sp)
    8000765a:	7942                	ld	s2,48(sp)
    8000765c:	79a2                	ld	s3,40(sp)
    8000765e:	7a02                	ld	s4,32(sp)
    80007660:	6ae2                	ld	s5,24(sp)
    80007662:	6b42                	ld	s6,16(sp)
    80007664:	6ba2                	ld	s7,8(sp)
    80007666:	6161                	addi	sp,sp,80
    80007668:	8082                	ret

000000008000766a <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    8000766a:	1141                	addi	sp,sp,-16
    8000766c:	e422                	sd	s0,8(sp)
    8000766e:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    80007670:	41f5d79b          	sraiw	a5,a1,0x1f
    80007674:	01d7d79b          	srliw	a5,a5,0x1d
    80007678:	9dbd                	addw	a1,a1,a5
    8000767a:	0075f713          	andi	a4,a1,7
    8000767e:	9f1d                	subw	a4,a4,a5
    80007680:	4785                	li	a5,1
    80007682:	00e797bb          	sllw	a5,a5,a4
  char b = array[index/8];
    80007686:	4035d59b          	sraiw	a1,a1,0x3
    8000768a:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    8000768c:	0005c503          	lbu	a0,0(a1)
    80007690:	8d7d                	and	a0,a0,a5
    80007692:	0ff7f793          	andi	a5,a5,255
    80007696:	8d1d                	sub	a0,a0,a5
}
    80007698:	00153513          	seqz	a0,a0
    8000769c:	6422                	ld	s0,8(sp)
    8000769e:	0141                	addi	sp,sp,16
    800076a0:	8082                	ret

00000000800076a2 <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    800076a2:	1141                	addi	sp,sp,-16
    800076a4:	e422                	sd	s0,8(sp)
    800076a6:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800076a8:	41f5d79b          	sraiw	a5,a1,0x1f
    800076ac:	01d7d79b          	srliw	a5,a5,0x1d
    800076b0:	9dbd                	addw	a1,a1,a5
    800076b2:	4035d71b          	sraiw	a4,a1,0x3
    800076b6:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800076b8:	899d                	andi	a1,a1,7
    800076ba:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b | m);
    800076bc:	4785                	li	a5,1
    800076be:	00b795bb          	sllw	a1,a5,a1
    800076c2:	00054783          	lbu	a5,0(a0)
    800076c6:	8ddd                	or	a1,a1,a5
    800076c8:	00b50023          	sb	a1,0(a0)
}
    800076cc:	6422                	ld	s0,8(sp)
    800076ce:	0141                	addi	sp,sp,16
    800076d0:	8082                	ret

00000000800076d2 <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    800076d2:	1141                	addi	sp,sp,-16
    800076d4:	e422                	sd	s0,8(sp)
    800076d6:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800076d8:	41f5d79b          	sraiw	a5,a1,0x1f
    800076dc:	01d7d79b          	srliw	a5,a5,0x1d
    800076e0:	9dbd                	addw	a1,a1,a5
    800076e2:	4035d71b          	sraiw	a4,a1,0x3
    800076e6:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800076e8:	899d                	andi	a1,a1,7
    800076ea:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b & ~m);
    800076ec:	4785                	li	a5,1
    800076ee:	00b795bb          	sllw	a1,a5,a1
    800076f2:	fff5c593          	not	a1,a1
    800076f6:	00054783          	lbu	a5,0(a0)
    800076fa:	8dfd                	and	a1,a1,a5
    800076fc:	00b50023          	sb	a1,0(a0)
}
    80007700:	6422                	ld	s0,8(sp)
    80007702:	0141                	addi	sp,sp,16
    80007704:	8082                	ret

0000000080007706 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80007706:	715d                	addi	sp,sp,-80
    80007708:	e486                	sd	ra,72(sp)
    8000770a:	e0a2                	sd	s0,64(sp)
    8000770c:	fc26                	sd	s1,56(sp)
    8000770e:	f84a                	sd	s2,48(sp)
    80007710:	f44e                	sd	s3,40(sp)
    80007712:	f052                	sd	s4,32(sp)
    80007714:	ec56                	sd	s5,24(sp)
    80007716:	e85a                	sd	s6,16(sp)
    80007718:	e45e                	sd	s7,8(sp)
    8000771a:	0880                	addi	s0,sp,80
    8000771c:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    8000771e:	08b05b63          	blez	a1,800077b4 <bd_print_vector+0xae>
    80007722:	89aa                	mv	s3,a0
    80007724:	4481                	li	s1,0
  lb = 0;
    80007726:	4a81                	li	s5,0
  last = 1;
    80007728:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    8000772a:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    8000772c:	00002b97          	auipc	s7,0x2
    80007730:	534b8b93          	addi	s7,s7,1332 # 80009c60 <userret+0xbd0>
    80007734:	a01d                	j	8000775a <bd_print_vector+0x54>
    80007736:	8626                	mv	a2,s1
    80007738:	85d6                	mv	a1,s5
    8000773a:	855e                	mv	a0,s7
    8000773c:	ffff9097          	auipc	ra,0xffff9
    80007740:	e78080e7          	jalr	-392(ra) # 800005b4 <printf>
    lb = b;
    last = bit_isset(vector, b);
    80007744:	85a6                	mv	a1,s1
    80007746:	854e                	mv	a0,s3
    80007748:	00000097          	auipc	ra,0x0
    8000774c:	f22080e7          	jalr	-222(ra) # 8000766a <bit_isset>
    80007750:	892a                	mv	s2,a0
    80007752:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80007754:	2485                	addiw	s1,s1,1
    80007756:	009a0d63          	beq	s4,s1,80007770 <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    8000775a:	85a6                	mv	a1,s1
    8000775c:	854e                	mv	a0,s3
    8000775e:	00000097          	auipc	ra,0x0
    80007762:	f0c080e7          	jalr	-244(ra) # 8000766a <bit_isset>
    80007766:	ff2507e3          	beq	a0,s2,80007754 <bd_print_vector+0x4e>
    if(last == 1)
    8000776a:	fd691de3          	bne	s2,s6,80007744 <bd_print_vector+0x3e>
    8000776e:	b7e1                	j	80007736 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    80007770:	000a8563          	beqz	s5,8000777a <bd_print_vector+0x74>
    80007774:	4785                	li	a5,1
    80007776:	00f91c63          	bne	s2,a5,8000778e <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    8000777a:	8652                	mv	a2,s4
    8000777c:	85d6                	mv	a1,s5
    8000777e:	00002517          	auipc	a0,0x2
    80007782:	4e250513          	addi	a0,a0,1250 # 80009c60 <userret+0xbd0>
    80007786:	ffff9097          	auipc	ra,0xffff9
    8000778a:	e2e080e7          	jalr	-466(ra) # 800005b4 <printf>
  }
  printf("\n");
    8000778e:	00002517          	auipc	a0,0x2
    80007792:	b0250513          	addi	a0,a0,-1278 # 80009290 <userret+0x200>
    80007796:	ffff9097          	auipc	ra,0xffff9
    8000779a:	e1e080e7          	jalr	-482(ra) # 800005b4 <printf>
}
    8000779e:	60a6                	ld	ra,72(sp)
    800077a0:	6406                	ld	s0,64(sp)
    800077a2:	74e2                	ld	s1,56(sp)
    800077a4:	7942                	ld	s2,48(sp)
    800077a6:	79a2                	ld	s3,40(sp)
    800077a8:	7a02                	ld	s4,32(sp)
    800077aa:	6ae2                	ld	s5,24(sp)
    800077ac:	6b42                	ld	s6,16(sp)
    800077ae:	6ba2                	ld	s7,8(sp)
    800077b0:	6161                	addi	sp,sp,80
    800077b2:	8082                	ret
  lb = 0;
    800077b4:	4a81                	li	s5,0
    800077b6:	b7d1                	j	8000777a <bd_print_vector+0x74>

00000000800077b8 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    800077b8:	00022697          	auipc	a3,0x22
    800077bc:	c106a683          	lw	a3,-1008(a3) # 800293c8 <nsizes>
    800077c0:	10d05063          	blez	a3,800078c0 <bd_print+0x108>
bd_print() {
    800077c4:	711d                	addi	sp,sp,-96
    800077c6:	ec86                	sd	ra,88(sp)
    800077c8:	e8a2                	sd	s0,80(sp)
    800077ca:	e4a6                	sd	s1,72(sp)
    800077cc:	e0ca                	sd	s2,64(sp)
    800077ce:	fc4e                	sd	s3,56(sp)
    800077d0:	f852                	sd	s4,48(sp)
    800077d2:	f456                	sd	s5,40(sp)
    800077d4:	f05a                	sd	s6,32(sp)
    800077d6:	ec5e                	sd	s7,24(sp)
    800077d8:	e862                	sd	s8,16(sp)
    800077da:	e466                	sd	s9,8(sp)
    800077dc:	e06a                	sd	s10,0(sp)
    800077de:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    800077e0:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    800077e2:	4a85                	li	s5,1
    800077e4:	4c41                	li	s8,16
    800077e6:	00002b97          	auipc	s7,0x2
    800077ea:	48ab8b93          	addi	s7,s7,1162 # 80009c70 <userret+0xbe0>
    lst_print(&bd_sizes[k].free);
    800077ee:	00022a17          	auipc	s4,0x22
    800077f2:	bd2a0a13          	addi	s4,s4,-1070 # 800293c0 <bd_sizes>
    printf("  alloc:");
    800077f6:	00002b17          	auipc	s6,0x2
    800077fa:	4a2b0b13          	addi	s6,s6,1186 # 80009c98 <userret+0xc08>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    800077fe:	00022997          	auipc	s3,0x22
    80007802:	bca98993          	addi	s3,s3,-1078 # 800293c8 <nsizes>
    if(k > 0) {
      printf("  split:");
    80007806:	00002c97          	auipc	s9,0x2
    8000780a:	4a2c8c93          	addi	s9,s9,1186 # 80009ca8 <userret+0xc18>
    8000780e:	a801                	j	8000781e <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    80007810:	0009a683          	lw	a3,0(s3)
    80007814:	0485                	addi	s1,s1,1
    80007816:	0004879b          	sext.w	a5,s1
    8000781a:	08d7d563          	bge	a5,a3,800078a4 <bd_print+0xec>
    8000781e:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80007822:	36fd                	addiw	a3,a3,-1
    80007824:	9e85                	subw	a3,a3,s1
    80007826:	00da96bb          	sllw	a3,s5,a3
    8000782a:	009c1633          	sll	a2,s8,s1
    8000782e:	85ca                	mv	a1,s2
    80007830:	855e                	mv	a0,s7
    80007832:	ffff9097          	auipc	ra,0xffff9
    80007836:	d82080e7          	jalr	-638(ra) # 800005b4 <printf>
    lst_print(&bd_sizes[k].free);
    8000783a:	00549d13          	slli	s10,s1,0x5
    8000783e:	000a3503          	ld	a0,0(s4)
    80007842:	956a                	add	a0,a0,s10
    80007844:	00001097          	auipc	ra,0x1
    80007848:	a4e080e7          	jalr	-1458(ra) # 80008292 <lst_print>
    printf("  alloc:");
    8000784c:	855a                	mv	a0,s6
    8000784e:	ffff9097          	auipc	ra,0xffff9
    80007852:	d66080e7          	jalr	-666(ra) # 800005b4 <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80007856:	0009a583          	lw	a1,0(s3)
    8000785a:	35fd                	addiw	a1,a1,-1
    8000785c:	412585bb          	subw	a1,a1,s2
    80007860:	000a3783          	ld	a5,0(s4)
    80007864:	97ea                	add	a5,a5,s10
    80007866:	00ba95bb          	sllw	a1,s5,a1
    8000786a:	6b88                	ld	a0,16(a5)
    8000786c:	00000097          	auipc	ra,0x0
    80007870:	e9a080e7          	jalr	-358(ra) # 80007706 <bd_print_vector>
    if(k > 0) {
    80007874:	f9205ee3          	blez	s2,80007810 <bd_print+0x58>
      printf("  split:");
    80007878:	8566                	mv	a0,s9
    8000787a:	ffff9097          	auipc	ra,0xffff9
    8000787e:	d3a080e7          	jalr	-710(ra) # 800005b4 <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    80007882:	0009a583          	lw	a1,0(s3)
    80007886:	35fd                	addiw	a1,a1,-1
    80007888:	412585bb          	subw	a1,a1,s2
    8000788c:	000a3783          	ld	a5,0(s4)
    80007890:	9d3e                	add	s10,s10,a5
    80007892:	00ba95bb          	sllw	a1,s5,a1
    80007896:	018d3503          	ld	a0,24(s10)
    8000789a:	00000097          	auipc	ra,0x0
    8000789e:	e6c080e7          	jalr	-404(ra) # 80007706 <bd_print_vector>
    800078a2:	b7bd                	j	80007810 <bd_print+0x58>
    }
  }
}
    800078a4:	60e6                	ld	ra,88(sp)
    800078a6:	6446                	ld	s0,80(sp)
    800078a8:	64a6                	ld	s1,72(sp)
    800078aa:	6906                	ld	s2,64(sp)
    800078ac:	79e2                	ld	s3,56(sp)
    800078ae:	7a42                	ld	s4,48(sp)
    800078b0:	7aa2                	ld	s5,40(sp)
    800078b2:	7b02                	ld	s6,32(sp)
    800078b4:	6be2                	ld	s7,24(sp)
    800078b6:	6c42                	ld	s8,16(sp)
    800078b8:	6ca2                	ld	s9,8(sp)
    800078ba:	6d02                	ld	s10,0(sp)
    800078bc:	6125                	addi	sp,sp,96
    800078be:	8082                	ret
    800078c0:	8082                	ret

00000000800078c2 <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    800078c2:	1141                	addi	sp,sp,-16
    800078c4:	e422                	sd	s0,8(sp)
    800078c6:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    800078c8:	47c1                	li	a5,16
    800078ca:	00a7fb63          	bgeu	a5,a0,800078e0 <firstk+0x1e>
    800078ce:	872a                	mv	a4,a0
  int k = 0;
    800078d0:	4501                	li	a0,0
    k++;
    800078d2:	2505                	addiw	a0,a0,1
    size *= 2;
    800078d4:	0786                	slli	a5,a5,0x1
  while (size < n) {
    800078d6:	fee7eee3          	bltu	a5,a4,800078d2 <firstk+0x10>
  }
  return k;
}
    800078da:	6422                	ld	s0,8(sp)
    800078dc:	0141                	addi	sp,sp,16
    800078de:	8082                	ret
  int k = 0;
    800078e0:	4501                	li	a0,0
    800078e2:	bfe5                	j	800078da <firstk+0x18>

00000000800078e4 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    800078e4:	1141                	addi	sp,sp,-16
    800078e6:	e422                	sd	s0,8(sp)
    800078e8:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    800078ea:	00022797          	auipc	a5,0x22
    800078ee:	ace7b783          	ld	a5,-1330(a5) # 800293b8 <bd_base>
    800078f2:	9d9d                	subw	a1,a1,a5
    800078f4:	47c1                	li	a5,16
    800078f6:	00a79533          	sll	a0,a5,a0
    800078fa:	02a5c533          	div	a0,a1,a0
}
    800078fe:	2501                	sext.w	a0,a0
    80007900:	6422                	ld	s0,8(sp)
    80007902:	0141                	addi	sp,sp,16
    80007904:	8082                	ret

0000000080007906 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80007906:	1141                	addi	sp,sp,-16
    80007908:	e422                	sd	s0,8(sp)
    8000790a:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    8000790c:	47c1                	li	a5,16
    8000790e:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    80007912:	02b787bb          	mulw	a5,a5,a1
}
    80007916:	00022517          	auipc	a0,0x22
    8000791a:	aa253503          	ld	a0,-1374(a0) # 800293b8 <bd_base>
    8000791e:	953e                	add	a0,a0,a5
    80007920:	6422                	ld	s0,8(sp)
    80007922:	0141                	addi	sp,sp,16
    80007924:	8082                	ret

0000000080007926 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80007926:	7159                	addi	sp,sp,-112
    80007928:	f486                	sd	ra,104(sp)
    8000792a:	f0a2                	sd	s0,96(sp)
    8000792c:	eca6                	sd	s1,88(sp)
    8000792e:	e8ca                	sd	s2,80(sp)
    80007930:	e4ce                	sd	s3,72(sp)
    80007932:	e0d2                	sd	s4,64(sp)
    80007934:	fc56                	sd	s5,56(sp)
    80007936:	f85a                	sd	s6,48(sp)
    80007938:	f45e                	sd	s7,40(sp)
    8000793a:	f062                	sd	s8,32(sp)
    8000793c:	ec66                	sd	s9,24(sp)
    8000793e:	e86a                	sd	s10,16(sp)
    80007940:	e46e                	sd	s11,8(sp)
    80007942:	1880                	addi	s0,sp,112
    80007944:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80007946:	00022517          	auipc	a0,0x22
    8000794a:	a1a50513          	addi	a0,a0,-1510 # 80029360 <lock>
    8000794e:	ffff9097          	auipc	ra,0xffff9
    80007952:	15e080e7          	jalr	350(ra) # 80000aac <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80007956:	8526                	mv	a0,s1
    80007958:	00000097          	auipc	ra,0x0
    8000795c:	f6a080e7          	jalr	-150(ra) # 800078c2 <firstk>
  for (k = fk; k < nsizes; k++) {
    80007960:	00022797          	auipc	a5,0x22
    80007964:	a687a783          	lw	a5,-1432(a5) # 800293c8 <nsizes>
    80007968:	02f55d63          	bge	a0,a5,800079a2 <bd_malloc+0x7c>
    8000796c:	8c2a                	mv	s8,a0
    8000796e:	00551913          	slli	s2,a0,0x5
    80007972:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80007974:	00022997          	auipc	s3,0x22
    80007978:	a4c98993          	addi	s3,s3,-1460 # 800293c0 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    8000797c:	00022a17          	auipc	s4,0x22
    80007980:	a4ca0a13          	addi	s4,s4,-1460 # 800293c8 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80007984:	0009b503          	ld	a0,0(s3)
    80007988:	954a                	add	a0,a0,s2
    8000798a:	00001097          	auipc	ra,0x1
    8000798e:	88e080e7          	jalr	-1906(ra) # 80008218 <lst_empty>
    80007992:	c115                	beqz	a0,800079b6 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80007994:	2485                	addiw	s1,s1,1
    80007996:	02090913          	addi	s2,s2,32
    8000799a:	000a2783          	lw	a5,0(s4)
    8000799e:	fef4c3e3          	blt	s1,a5,80007984 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    800079a2:	00022517          	auipc	a0,0x22
    800079a6:	9be50513          	addi	a0,a0,-1602 # 80029360 <lock>
    800079aa:	ffff9097          	auipc	ra,0xffff9
    800079ae:	1d2080e7          	jalr	466(ra) # 80000b7c <release>
    return 0;
    800079b2:	4b01                	li	s6,0
    800079b4:	a0e1                	j	80007a7c <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    800079b6:	00022797          	auipc	a5,0x22
    800079ba:	a127a783          	lw	a5,-1518(a5) # 800293c8 <nsizes>
    800079be:	fef4d2e3          	bge	s1,a5,800079a2 <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    800079c2:	00549993          	slli	s3,s1,0x5
    800079c6:	00022917          	auipc	s2,0x22
    800079ca:	9fa90913          	addi	s2,s2,-1542 # 800293c0 <bd_sizes>
    800079ce:	00093503          	ld	a0,0(s2)
    800079d2:	954e                	add	a0,a0,s3
    800079d4:	00001097          	auipc	ra,0x1
    800079d8:	870080e7          	jalr	-1936(ra) # 80008244 <lst_pop>
    800079dc:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    800079de:	00022597          	auipc	a1,0x22
    800079e2:	9da5b583          	ld	a1,-1574(a1) # 800293b8 <bd_base>
    800079e6:	40b505bb          	subw	a1,a0,a1
    800079ea:	47c1                	li	a5,16
    800079ec:	009797b3          	sll	a5,a5,s1
    800079f0:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    800079f4:	00093783          	ld	a5,0(s2)
    800079f8:	97ce                	add	a5,a5,s3
    800079fa:	2581                	sext.w	a1,a1
    800079fc:	6b88                	ld	a0,16(a5)
    800079fe:	00000097          	auipc	ra,0x0
    80007a02:	ca4080e7          	jalr	-860(ra) # 800076a2 <bit_set>
  for(; k > fk; k--) {
    80007a06:	069c5363          	bge	s8,s1,80007a6c <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80007a0a:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80007a0c:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    80007a0e:	00022d17          	auipc	s10,0x22
    80007a12:	9aad0d13          	addi	s10,s10,-1622 # 800293b8 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80007a16:	85a6                	mv	a1,s1
    80007a18:	34fd                	addiw	s1,s1,-1
    80007a1a:	009b9ab3          	sll	s5,s7,s1
    80007a1e:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80007a22:	000dba03          	ld	s4,0(s11)
  int n = p - (char *) bd_base;
    80007a26:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    80007a2a:	412b093b          	subw	s2,s6,s2
    80007a2e:	00bb95b3          	sll	a1,s7,a1
    80007a32:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80007a36:	013a07b3          	add	a5,s4,s3
    80007a3a:	2581                	sext.w	a1,a1
    80007a3c:	6f88                	ld	a0,24(a5)
    80007a3e:	00000097          	auipc	ra,0x0
    80007a42:	c64080e7          	jalr	-924(ra) # 800076a2 <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80007a46:	1981                	addi	s3,s3,-32
    80007a48:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    80007a4a:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80007a4e:	2581                	sext.w	a1,a1
    80007a50:	010a3503          	ld	a0,16(s4)
    80007a54:	00000097          	auipc	ra,0x0
    80007a58:	c4e080e7          	jalr	-946(ra) # 800076a2 <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    80007a5c:	85e6                	mv	a1,s9
    80007a5e:	8552                	mv	a0,s4
    80007a60:	00001097          	auipc	ra,0x1
    80007a64:	81a080e7          	jalr	-2022(ra) # 8000827a <lst_push>
  for(; k > fk; k--) {
    80007a68:	fb8497e3          	bne	s1,s8,80007a16 <bd_malloc+0xf0>
  }
  release(&lock);
    80007a6c:	00022517          	auipc	a0,0x22
    80007a70:	8f450513          	addi	a0,a0,-1804 # 80029360 <lock>
    80007a74:	ffff9097          	auipc	ra,0xffff9
    80007a78:	108080e7          	jalr	264(ra) # 80000b7c <release>

  return p;
}
    80007a7c:	855a                	mv	a0,s6
    80007a7e:	70a6                	ld	ra,104(sp)
    80007a80:	7406                	ld	s0,96(sp)
    80007a82:	64e6                	ld	s1,88(sp)
    80007a84:	6946                	ld	s2,80(sp)
    80007a86:	69a6                	ld	s3,72(sp)
    80007a88:	6a06                	ld	s4,64(sp)
    80007a8a:	7ae2                	ld	s5,56(sp)
    80007a8c:	7b42                	ld	s6,48(sp)
    80007a8e:	7ba2                	ld	s7,40(sp)
    80007a90:	7c02                	ld	s8,32(sp)
    80007a92:	6ce2                	ld	s9,24(sp)
    80007a94:	6d42                	ld	s10,16(sp)
    80007a96:	6da2                	ld	s11,8(sp)
    80007a98:	6165                	addi	sp,sp,112
    80007a9a:	8082                	ret

0000000080007a9c <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    80007a9c:	7139                	addi	sp,sp,-64
    80007a9e:	fc06                	sd	ra,56(sp)
    80007aa0:	f822                	sd	s0,48(sp)
    80007aa2:	f426                	sd	s1,40(sp)
    80007aa4:	f04a                	sd	s2,32(sp)
    80007aa6:	ec4e                	sd	s3,24(sp)
    80007aa8:	e852                	sd	s4,16(sp)
    80007aaa:	e456                	sd	s5,8(sp)
    80007aac:	e05a                	sd	s6,0(sp)
    80007aae:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80007ab0:	00022a97          	auipc	s5,0x22
    80007ab4:	918aaa83          	lw	s5,-1768(s5) # 800293c8 <nsizes>
  return n / BLK_SIZE(k);
    80007ab8:	00022a17          	auipc	s4,0x22
    80007abc:	900a3a03          	ld	s4,-1792(s4) # 800293b8 <bd_base>
    80007ac0:	41450a3b          	subw	s4,a0,s4
    80007ac4:	00022497          	auipc	s1,0x22
    80007ac8:	8fc4b483          	ld	s1,-1796(s1) # 800293c0 <bd_sizes>
    80007acc:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    80007ad0:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    80007ad2:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80007ad4:	03595363          	bge	s2,s5,80007afa <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80007ad8:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80007adc:	013b15b3          	sll	a1,s6,s3
    80007ae0:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80007ae4:	2581                	sext.w	a1,a1
    80007ae6:	6088                	ld	a0,0(s1)
    80007ae8:	00000097          	auipc	ra,0x0
    80007aec:	b82080e7          	jalr	-1150(ra) # 8000766a <bit_isset>
    80007af0:	02048493          	addi	s1,s1,32
    80007af4:	e501                	bnez	a0,80007afc <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    80007af6:	894e                	mv	s2,s3
    80007af8:	bff1                	j	80007ad4 <size+0x38>
      return k;
    }
  }
  return 0;
    80007afa:	4901                	li	s2,0
}
    80007afc:	854a                	mv	a0,s2
    80007afe:	70e2                	ld	ra,56(sp)
    80007b00:	7442                	ld	s0,48(sp)
    80007b02:	74a2                	ld	s1,40(sp)
    80007b04:	7902                	ld	s2,32(sp)
    80007b06:	69e2                	ld	s3,24(sp)
    80007b08:	6a42                	ld	s4,16(sp)
    80007b0a:	6aa2                	ld	s5,8(sp)
    80007b0c:	6b02                	ld	s6,0(sp)
    80007b0e:	6121                	addi	sp,sp,64
    80007b10:	8082                	ret

0000000080007b12 <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    80007b12:	7159                	addi	sp,sp,-112
    80007b14:	f486                	sd	ra,104(sp)
    80007b16:	f0a2                	sd	s0,96(sp)
    80007b18:	eca6                	sd	s1,88(sp)
    80007b1a:	e8ca                	sd	s2,80(sp)
    80007b1c:	e4ce                	sd	s3,72(sp)
    80007b1e:	e0d2                	sd	s4,64(sp)
    80007b20:	fc56                	sd	s5,56(sp)
    80007b22:	f85a                	sd	s6,48(sp)
    80007b24:	f45e                	sd	s7,40(sp)
    80007b26:	f062                	sd	s8,32(sp)
    80007b28:	ec66                	sd	s9,24(sp)
    80007b2a:	e86a                	sd	s10,16(sp)
    80007b2c:	e46e                	sd	s11,8(sp)
    80007b2e:	1880                	addi	s0,sp,112
    80007b30:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    80007b32:	00022517          	auipc	a0,0x22
    80007b36:	82e50513          	addi	a0,a0,-2002 # 80029360 <lock>
    80007b3a:	ffff9097          	auipc	ra,0xffff9
    80007b3e:	f72080e7          	jalr	-142(ra) # 80000aac <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    80007b42:	8556                	mv	a0,s5
    80007b44:	00000097          	auipc	ra,0x0
    80007b48:	f58080e7          	jalr	-168(ra) # 80007a9c <size>
    80007b4c:	84aa                	mv	s1,a0
    80007b4e:	00022797          	auipc	a5,0x22
    80007b52:	87a7a783          	lw	a5,-1926(a5) # 800293c8 <nsizes>
    80007b56:	37fd                	addiw	a5,a5,-1
    80007b58:	0af55d63          	bge	a0,a5,80007c12 <bd_free+0x100>
    80007b5c:	00551a13          	slli	s4,a0,0x5
  int n = p - (char *) bd_base;
    80007b60:	00022c17          	auipc	s8,0x22
    80007b64:	858c0c13          	addi	s8,s8,-1960 # 800293b8 <bd_base>
  return n / BLK_SIZE(k);
    80007b68:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80007b6a:	00022b17          	auipc	s6,0x22
    80007b6e:	856b0b13          	addi	s6,s6,-1962 # 800293c0 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    80007b72:	00022c97          	auipc	s9,0x22
    80007b76:	856c8c93          	addi	s9,s9,-1962 # 800293c8 <nsizes>
    80007b7a:	a82d                	j	80007bb4 <bd_free+0xa2>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007b7c:	fff58d9b          	addiw	s11,a1,-1
    80007b80:	a881                	j	80007bd0 <bd_free+0xbe>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80007b82:	020a0a13          	addi	s4,s4,32
    80007b86:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    80007b88:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    80007b8c:	40ba85bb          	subw	a1,s5,a1
    80007b90:	009b97b3          	sll	a5,s7,s1
    80007b94:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80007b98:	000b3783          	ld	a5,0(s6)
    80007b9c:	97d2                	add	a5,a5,s4
    80007b9e:	2581                	sext.w	a1,a1
    80007ba0:	6f88                	ld	a0,24(a5)
    80007ba2:	00000097          	auipc	ra,0x0
    80007ba6:	b30080e7          	jalr	-1232(ra) # 800076d2 <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80007baa:	000ca783          	lw	a5,0(s9)
    80007bae:	37fd                	addiw	a5,a5,-1
    80007bb0:	06f4d163          	bge	s1,a5,80007c12 <bd_free+0x100>
  int n = p - (char *) bd_base;
    80007bb4:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80007bb8:	009b99b3          	sll	s3,s7,s1
    80007bbc:	412a87bb          	subw	a5,s5,s2
    80007bc0:	0337c7b3          	div	a5,a5,s3
    80007bc4:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007bc8:	8b85                	andi	a5,a5,1
    80007bca:	fbcd                	bnez	a5,80007b7c <bd_free+0x6a>
    80007bcc:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80007bd0:	000b3d03          	ld	s10,0(s6)
    80007bd4:	9d52                	add	s10,s10,s4
    80007bd6:	010d3503          	ld	a0,16(s10)
    80007bda:	00000097          	auipc	ra,0x0
    80007bde:	af8080e7          	jalr	-1288(ra) # 800076d2 <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    80007be2:	85ee                	mv	a1,s11
    80007be4:	010d3503          	ld	a0,16(s10)
    80007be8:	00000097          	auipc	ra,0x0
    80007bec:	a82080e7          	jalr	-1406(ra) # 8000766a <bit_isset>
    80007bf0:	e10d                	bnez	a0,80007c12 <bd_free+0x100>
  int n = bi * BLK_SIZE(k);
    80007bf2:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80007bf6:	03b989bb          	mulw	s3,s3,s11
    80007bfa:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80007bfc:	854a                	mv	a0,s2
    80007bfe:	00000097          	auipc	ra,0x0
    80007c02:	630080e7          	jalr	1584(ra) # 8000822e <lst_remove>
    if(buddy % 2 == 0) {
    80007c06:	001d7d13          	andi	s10,s10,1
    80007c0a:	f60d1ce3          	bnez	s10,80007b82 <bd_free+0x70>
      p = q;
    80007c0e:	8aca                	mv	s5,s2
    80007c10:	bf8d                	j	80007b82 <bd_free+0x70>
  }
  lst_push(&bd_sizes[k].free, p);
    80007c12:	0496                	slli	s1,s1,0x5
    80007c14:	85d6                	mv	a1,s5
    80007c16:	00021517          	auipc	a0,0x21
    80007c1a:	7aa53503          	ld	a0,1962(a0) # 800293c0 <bd_sizes>
    80007c1e:	9526                	add	a0,a0,s1
    80007c20:	00000097          	auipc	ra,0x0
    80007c24:	65a080e7          	jalr	1626(ra) # 8000827a <lst_push>
  release(&lock);
    80007c28:	00021517          	auipc	a0,0x21
    80007c2c:	73850513          	addi	a0,a0,1848 # 80029360 <lock>
    80007c30:	ffff9097          	auipc	ra,0xffff9
    80007c34:	f4c080e7          	jalr	-180(ra) # 80000b7c <release>
}
    80007c38:	70a6                	ld	ra,104(sp)
    80007c3a:	7406                	ld	s0,96(sp)
    80007c3c:	64e6                	ld	s1,88(sp)
    80007c3e:	6946                	ld	s2,80(sp)
    80007c40:	69a6                	ld	s3,72(sp)
    80007c42:	6a06                	ld	s4,64(sp)
    80007c44:	7ae2                	ld	s5,56(sp)
    80007c46:	7b42                	ld	s6,48(sp)
    80007c48:	7ba2                	ld	s7,40(sp)
    80007c4a:	7c02                	ld	s8,32(sp)
    80007c4c:	6ce2                	ld	s9,24(sp)
    80007c4e:	6d42                	ld	s10,16(sp)
    80007c50:	6da2                	ld	s11,8(sp)
    80007c52:	6165                	addi	sp,sp,112
    80007c54:	8082                	ret

0000000080007c56 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80007c56:	1141                	addi	sp,sp,-16
    80007c58:	e422                	sd	s0,8(sp)
    80007c5a:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80007c5c:	00021797          	auipc	a5,0x21
    80007c60:	75c7b783          	ld	a5,1884(a5) # 800293b8 <bd_base>
    80007c64:	8d9d                	sub	a1,a1,a5
    80007c66:	47c1                	li	a5,16
    80007c68:	00a797b3          	sll	a5,a5,a0
    80007c6c:	02f5c533          	div	a0,a1,a5
    80007c70:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80007c72:	02f5e5b3          	rem	a1,a1,a5
    80007c76:	c191                	beqz	a1,80007c7a <blk_index_next+0x24>
      n++;
    80007c78:	2505                	addiw	a0,a0,1
  return n ;
}
    80007c7a:	6422                	ld	s0,8(sp)
    80007c7c:	0141                	addi	sp,sp,16
    80007c7e:	8082                	ret

0000000080007c80 <log2>:

int
log2(uint64 n) {
    80007c80:	1141                	addi	sp,sp,-16
    80007c82:	e422                	sd	s0,8(sp)
    80007c84:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80007c86:	4705                	li	a4,1
    80007c88:	00a77b63          	bgeu	a4,a0,80007c9e <log2+0x1e>
    80007c8c:	87aa                	mv	a5,a0
  int k = 0;
    80007c8e:	4501                	li	a0,0
    k++;
    80007c90:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80007c92:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80007c94:	fef76ee3          	bltu	a4,a5,80007c90 <log2+0x10>
  }
  return k;
}
    80007c98:	6422                	ld	s0,8(sp)
    80007c9a:	0141                	addi	sp,sp,16
    80007c9c:	8082                	ret
  int k = 0;
    80007c9e:	4501                	li	a0,0
    80007ca0:	bfe5                	j	80007c98 <log2+0x18>

0000000080007ca2 <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80007ca2:	711d                	addi	sp,sp,-96
    80007ca4:	ec86                	sd	ra,88(sp)
    80007ca6:	e8a2                	sd	s0,80(sp)
    80007ca8:	e4a6                	sd	s1,72(sp)
    80007caa:	e0ca                	sd	s2,64(sp)
    80007cac:	fc4e                	sd	s3,56(sp)
    80007cae:	f852                	sd	s4,48(sp)
    80007cb0:	f456                	sd	s5,40(sp)
    80007cb2:	f05a                	sd	s6,32(sp)
    80007cb4:	ec5e                	sd	s7,24(sp)
    80007cb6:	e862                	sd	s8,16(sp)
    80007cb8:	e466                	sd	s9,8(sp)
    80007cba:	e06a                	sd	s10,0(sp)
    80007cbc:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80007cbe:	00b56933          	or	s2,a0,a1
    80007cc2:	00f97913          	andi	s2,s2,15
    80007cc6:	04091263          	bnez	s2,80007d0a <bd_mark+0x68>
    80007cca:	8b2a                	mv	s6,a0
    80007ccc:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80007cce:	00021c17          	auipc	s8,0x21
    80007cd2:	6fac2c03          	lw	s8,1786(s8) # 800293c8 <nsizes>
    80007cd6:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80007cd8:	00021d17          	auipc	s10,0x21
    80007cdc:	6e0d0d13          	addi	s10,s10,1760 # 800293b8 <bd_base>
  return n / BLK_SIZE(k);
    80007ce0:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    80007ce2:	00021a97          	auipc	s5,0x21
    80007ce6:	6dea8a93          	addi	s5,s5,1758 # 800293c0 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80007cea:	07804563          	bgtz	s8,80007d54 <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80007cee:	60e6                	ld	ra,88(sp)
    80007cf0:	6446                	ld	s0,80(sp)
    80007cf2:	64a6                	ld	s1,72(sp)
    80007cf4:	6906                	ld	s2,64(sp)
    80007cf6:	79e2                	ld	s3,56(sp)
    80007cf8:	7a42                	ld	s4,48(sp)
    80007cfa:	7aa2                	ld	s5,40(sp)
    80007cfc:	7b02                	ld	s6,32(sp)
    80007cfe:	6be2                	ld	s7,24(sp)
    80007d00:	6c42                	ld	s8,16(sp)
    80007d02:	6ca2                	ld	s9,8(sp)
    80007d04:	6d02                	ld	s10,0(sp)
    80007d06:	6125                	addi	sp,sp,96
    80007d08:	8082                	ret
    panic("bd_mark");
    80007d0a:	00002517          	auipc	a0,0x2
    80007d0e:	fae50513          	addi	a0,a0,-82 # 80009cb8 <userret+0xc28>
    80007d12:	ffff9097          	auipc	ra,0xffff9
    80007d16:	848080e7          	jalr	-1976(ra) # 8000055a <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80007d1a:	000ab783          	ld	a5,0(s5)
    80007d1e:	97ca                	add	a5,a5,s2
    80007d20:	85a6                	mv	a1,s1
    80007d22:	6b88                	ld	a0,16(a5)
    80007d24:	00000097          	auipc	ra,0x0
    80007d28:	97e080e7          	jalr	-1666(ra) # 800076a2 <bit_set>
    for(; bi < bj; bi++) {
    80007d2c:	2485                	addiw	s1,s1,1
    80007d2e:	009a0e63          	beq	s4,s1,80007d4a <bd_mark+0xa8>
      if(k > 0) {
    80007d32:	ff3054e3          	blez	s3,80007d1a <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80007d36:	000ab783          	ld	a5,0(s5)
    80007d3a:	97ca                	add	a5,a5,s2
    80007d3c:	85a6                	mv	a1,s1
    80007d3e:	6f88                	ld	a0,24(a5)
    80007d40:	00000097          	auipc	ra,0x0
    80007d44:	962080e7          	jalr	-1694(ra) # 800076a2 <bit_set>
    80007d48:	bfc9                	j	80007d1a <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80007d4a:	2985                	addiw	s3,s3,1
    80007d4c:	02090913          	addi	s2,s2,32
    80007d50:	f9898fe3          	beq	s3,s8,80007cee <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80007d54:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80007d58:	409b04bb          	subw	s1,s6,s1
    80007d5c:	013c97b3          	sll	a5,s9,s3
    80007d60:	02f4c4b3          	div	s1,s1,a5
    80007d64:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80007d66:	85de                	mv	a1,s7
    80007d68:	854e                	mv	a0,s3
    80007d6a:	00000097          	auipc	ra,0x0
    80007d6e:	eec080e7          	jalr	-276(ra) # 80007c56 <blk_index_next>
    80007d72:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80007d74:	faa4cfe3          	blt	s1,a0,80007d32 <bd_mark+0x90>
    80007d78:	bfc9                	j	80007d4a <bd_mark+0xa8>

0000000080007d7a <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80007d7a:	7139                	addi	sp,sp,-64
    80007d7c:	fc06                	sd	ra,56(sp)
    80007d7e:	f822                	sd	s0,48(sp)
    80007d80:	f426                	sd	s1,40(sp)
    80007d82:	f04a                	sd	s2,32(sp)
    80007d84:	ec4e                	sd	s3,24(sp)
    80007d86:	e852                	sd	s4,16(sp)
    80007d88:	e456                	sd	s5,8(sp)
    80007d8a:	e05a                	sd	s6,0(sp)
    80007d8c:	0080                	addi	s0,sp,64
    80007d8e:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007d90:	00058a9b          	sext.w	s5,a1
    80007d94:	0015f793          	andi	a5,a1,1
    80007d98:	ebad                	bnez	a5,80007e0a <bd_initfree_pair+0x90>
    80007d9a:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80007d9e:	00599493          	slli	s1,s3,0x5
    80007da2:	00021797          	auipc	a5,0x21
    80007da6:	61e7b783          	ld	a5,1566(a5) # 800293c0 <bd_sizes>
    80007daa:	94be                	add	s1,s1,a5
    80007dac:	0104bb03          	ld	s6,16(s1)
    80007db0:	855a                	mv	a0,s6
    80007db2:	00000097          	auipc	ra,0x0
    80007db6:	8b8080e7          	jalr	-1864(ra) # 8000766a <bit_isset>
    80007dba:	892a                	mv	s2,a0
    80007dbc:	85d2                	mv	a1,s4
    80007dbe:	855a                	mv	a0,s6
    80007dc0:	00000097          	auipc	ra,0x0
    80007dc4:	8aa080e7          	jalr	-1878(ra) # 8000766a <bit_isset>
  int free = 0;
    80007dc8:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80007dca:	02a90563          	beq	s2,a0,80007df4 <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80007dce:	45c1                	li	a1,16
    80007dd0:	013599b3          	sll	s3,a1,s3
    80007dd4:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80007dd8:	02090c63          	beqz	s2,80007e10 <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80007ddc:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80007de0:	00021597          	auipc	a1,0x21
    80007de4:	5d85b583          	ld	a1,1496(a1) # 800293b8 <bd_base>
    80007de8:	95ce                	add	a1,a1,s3
    80007dea:	8526                	mv	a0,s1
    80007dec:	00000097          	auipc	ra,0x0
    80007df0:	48e080e7          	jalr	1166(ra) # 8000827a <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80007df4:	855a                	mv	a0,s6
    80007df6:	70e2                	ld	ra,56(sp)
    80007df8:	7442                	ld	s0,48(sp)
    80007dfa:	74a2                	ld	s1,40(sp)
    80007dfc:	7902                	ld	s2,32(sp)
    80007dfe:	69e2                	ld	s3,24(sp)
    80007e00:	6a42                	ld	s4,16(sp)
    80007e02:	6aa2                	ld	s5,8(sp)
    80007e04:	6b02                	ld	s6,0(sp)
    80007e06:	6121                	addi	sp,sp,64
    80007e08:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007e0a:	fff58a1b          	addiw	s4,a1,-1
    80007e0e:	bf41                	j	80007d9e <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80007e10:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80007e14:	00021597          	auipc	a1,0x21
    80007e18:	5a45b583          	ld	a1,1444(a1) # 800293b8 <bd_base>
    80007e1c:	95ce                	add	a1,a1,s3
    80007e1e:	8526                	mv	a0,s1
    80007e20:	00000097          	auipc	ra,0x0
    80007e24:	45a080e7          	jalr	1114(ra) # 8000827a <lst_push>
    80007e28:	b7f1                	j	80007df4 <bd_initfree_pair+0x7a>

0000000080007e2a <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80007e2a:	711d                	addi	sp,sp,-96
    80007e2c:	ec86                	sd	ra,88(sp)
    80007e2e:	e8a2                	sd	s0,80(sp)
    80007e30:	e4a6                	sd	s1,72(sp)
    80007e32:	e0ca                	sd	s2,64(sp)
    80007e34:	fc4e                	sd	s3,56(sp)
    80007e36:	f852                	sd	s4,48(sp)
    80007e38:	f456                	sd	s5,40(sp)
    80007e3a:	f05a                	sd	s6,32(sp)
    80007e3c:	ec5e                	sd	s7,24(sp)
    80007e3e:	e862                	sd	s8,16(sp)
    80007e40:	e466                	sd	s9,8(sp)
    80007e42:	e06a                	sd	s10,0(sp)
    80007e44:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80007e46:	00021717          	auipc	a4,0x21
    80007e4a:	58272703          	lw	a4,1410(a4) # 800293c8 <nsizes>
    80007e4e:	4785                	li	a5,1
    80007e50:	06e7db63          	bge	a5,a4,80007ec6 <bd_initfree+0x9c>
    80007e54:	8aaa                	mv	s5,a0
    80007e56:	8b2e                	mv	s6,a1
    80007e58:	4901                	li	s2,0
  int free = 0;
    80007e5a:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80007e5c:	00021c97          	auipc	s9,0x21
    80007e60:	55cc8c93          	addi	s9,s9,1372 # 800293b8 <bd_base>
  return n / BLK_SIZE(k);
    80007e64:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80007e66:	00021b97          	auipc	s7,0x21
    80007e6a:	562b8b93          	addi	s7,s7,1378 # 800293c8 <nsizes>
    80007e6e:	a039                	j	80007e7c <bd_initfree+0x52>
    80007e70:	2905                	addiw	s2,s2,1
    80007e72:	000ba783          	lw	a5,0(s7)
    80007e76:	37fd                	addiw	a5,a5,-1
    80007e78:	04f95863          	bge	s2,a5,80007ec8 <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80007e7c:	85d6                	mv	a1,s5
    80007e7e:	854a                	mv	a0,s2
    80007e80:	00000097          	auipc	ra,0x0
    80007e84:	dd6080e7          	jalr	-554(ra) # 80007c56 <blk_index_next>
    80007e88:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80007e8a:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80007e8e:	409b04bb          	subw	s1,s6,s1
    80007e92:	012c17b3          	sll	a5,s8,s2
    80007e96:	02f4c4b3          	div	s1,s1,a5
    80007e9a:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80007e9c:	85aa                	mv	a1,a0
    80007e9e:	854a                	mv	a0,s2
    80007ea0:	00000097          	auipc	ra,0x0
    80007ea4:	eda080e7          	jalr	-294(ra) # 80007d7a <bd_initfree_pair>
    80007ea8:	01450d3b          	addw	s10,a0,s4
    80007eac:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80007eb0:	fc99d0e3          	bge	s3,s1,80007e70 <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80007eb4:	85a6                	mv	a1,s1
    80007eb6:	854a                	mv	a0,s2
    80007eb8:	00000097          	auipc	ra,0x0
    80007ebc:	ec2080e7          	jalr	-318(ra) # 80007d7a <bd_initfree_pair>
    80007ec0:	00ad0a3b          	addw	s4,s10,a0
    80007ec4:	b775                	j	80007e70 <bd_initfree+0x46>
  int free = 0;
    80007ec6:	4a01                	li	s4,0
  }
  return free;
}
    80007ec8:	8552                	mv	a0,s4
    80007eca:	60e6                	ld	ra,88(sp)
    80007ecc:	6446                	ld	s0,80(sp)
    80007ece:	64a6                	ld	s1,72(sp)
    80007ed0:	6906                	ld	s2,64(sp)
    80007ed2:	79e2                	ld	s3,56(sp)
    80007ed4:	7a42                	ld	s4,48(sp)
    80007ed6:	7aa2                	ld	s5,40(sp)
    80007ed8:	7b02                	ld	s6,32(sp)
    80007eda:	6be2                	ld	s7,24(sp)
    80007edc:	6c42                	ld	s8,16(sp)
    80007ede:	6ca2                	ld	s9,8(sp)
    80007ee0:	6d02                	ld	s10,0(sp)
    80007ee2:	6125                	addi	sp,sp,96
    80007ee4:	8082                	ret

0000000080007ee6 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80007ee6:	7179                	addi	sp,sp,-48
    80007ee8:	f406                	sd	ra,40(sp)
    80007eea:	f022                	sd	s0,32(sp)
    80007eec:	ec26                	sd	s1,24(sp)
    80007eee:	e84a                	sd	s2,16(sp)
    80007ef0:	e44e                	sd	s3,8(sp)
    80007ef2:	1800                	addi	s0,sp,48
    80007ef4:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80007ef6:	00021997          	auipc	s3,0x21
    80007efa:	4c298993          	addi	s3,s3,1218 # 800293b8 <bd_base>
    80007efe:	0009b483          	ld	s1,0(s3)
    80007f02:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80007f06:	00021797          	auipc	a5,0x21
    80007f0a:	4c27a783          	lw	a5,1218(a5) # 800293c8 <nsizes>
    80007f0e:	37fd                	addiw	a5,a5,-1
    80007f10:	4641                	li	a2,16
    80007f12:	00f61633          	sll	a2,a2,a5
    80007f16:	85a6                	mv	a1,s1
    80007f18:	00002517          	auipc	a0,0x2
    80007f1c:	da850513          	addi	a0,a0,-600 # 80009cc0 <userret+0xc30>
    80007f20:	ffff8097          	auipc	ra,0xffff8
    80007f24:	694080e7          	jalr	1684(ra) # 800005b4 <printf>
  bd_mark(bd_base, p);
    80007f28:	85ca                	mv	a1,s2
    80007f2a:	0009b503          	ld	a0,0(s3)
    80007f2e:	00000097          	auipc	ra,0x0
    80007f32:	d74080e7          	jalr	-652(ra) # 80007ca2 <bd_mark>
  return meta;
}
    80007f36:	8526                	mv	a0,s1
    80007f38:	70a2                	ld	ra,40(sp)
    80007f3a:	7402                	ld	s0,32(sp)
    80007f3c:	64e2                	ld	s1,24(sp)
    80007f3e:	6942                	ld	s2,16(sp)
    80007f40:	69a2                	ld	s3,8(sp)
    80007f42:	6145                	addi	sp,sp,48
    80007f44:	8082                	ret

0000000080007f46 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80007f46:	1101                	addi	sp,sp,-32
    80007f48:	ec06                	sd	ra,24(sp)
    80007f4a:	e822                	sd	s0,16(sp)
    80007f4c:	e426                	sd	s1,8(sp)
    80007f4e:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80007f50:	00021497          	auipc	s1,0x21
    80007f54:	4784a483          	lw	s1,1144(s1) # 800293c8 <nsizes>
    80007f58:	fff4879b          	addiw	a5,s1,-1
    80007f5c:	44c1                	li	s1,16
    80007f5e:	00f494b3          	sll	s1,s1,a5
    80007f62:	00021797          	auipc	a5,0x21
    80007f66:	4567b783          	ld	a5,1110(a5) # 800293b8 <bd_base>
    80007f6a:	8d1d                	sub	a0,a0,a5
    80007f6c:	40a4853b          	subw	a0,s1,a0
    80007f70:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80007f74:	00905a63          	blez	s1,80007f88 <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80007f78:	357d                	addiw	a0,a0,-1
    80007f7a:	41f5549b          	sraiw	s1,a0,0x1f
    80007f7e:	01c4d49b          	srliw	s1,s1,0x1c
    80007f82:	9ca9                	addw	s1,s1,a0
    80007f84:	98c1                	andi	s1,s1,-16
    80007f86:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80007f88:	85a6                	mv	a1,s1
    80007f8a:	00002517          	auipc	a0,0x2
    80007f8e:	d6e50513          	addi	a0,a0,-658 # 80009cf8 <userret+0xc68>
    80007f92:	ffff8097          	auipc	ra,0xffff8
    80007f96:	622080e7          	jalr	1570(ra) # 800005b4 <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80007f9a:	00021717          	auipc	a4,0x21
    80007f9e:	41e73703          	ld	a4,1054(a4) # 800293b8 <bd_base>
    80007fa2:	00021597          	auipc	a1,0x21
    80007fa6:	4265a583          	lw	a1,1062(a1) # 800293c8 <nsizes>
    80007faa:	fff5879b          	addiw	a5,a1,-1
    80007fae:	45c1                	li	a1,16
    80007fb0:	00f595b3          	sll	a1,a1,a5
    80007fb4:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80007fb8:	95ba                	add	a1,a1,a4
    80007fba:	953a                	add	a0,a0,a4
    80007fbc:	00000097          	auipc	ra,0x0
    80007fc0:	ce6080e7          	jalr	-794(ra) # 80007ca2 <bd_mark>
  return unavailable;
}
    80007fc4:	8526                	mv	a0,s1
    80007fc6:	60e2                	ld	ra,24(sp)
    80007fc8:	6442                	ld	s0,16(sp)
    80007fca:	64a2                	ld	s1,8(sp)
    80007fcc:	6105                	addi	sp,sp,32
    80007fce:	8082                	ret

0000000080007fd0 <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80007fd0:	715d                	addi	sp,sp,-80
    80007fd2:	e486                	sd	ra,72(sp)
    80007fd4:	e0a2                	sd	s0,64(sp)
    80007fd6:	fc26                	sd	s1,56(sp)
    80007fd8:	f84a                	sd	s2,48(sp)
    80007fda:	f44e                	sd	s3,40(sp)
    80007fdc:	f052                	sd	s4,32(sp)
    80007fde:	ec56                	sd	s5,24(sp)
    80007fe0:	e85a                	sd	s6,16(sp)
    80007fe2:	e45e                	sd	s7,8(sp)
    80007fe4:	e062                	sd	s8,0(sp)
    80007fe6:	0880                	addi	s0,sp,80
    80007fe8:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    80007fea:	fff50493          	addi	s1,a0,-1
    80007fee:	98c1                	andi	s1,s1,-16
    80007ff0:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80007ff2:	00002597          	auipc	a1,0x2
    80007ff6:	d2658593          	addi	a1,a1,-730 # 80009d18 <userret+0xc88>
    80007ffa:	00021517          	auipc	a0,0x21
    80007ffe:	36650513          	addi	a0,a0,870 # 80029360 <lock>
    80008002:	ffff9097          	auipc	ra,0xffff9
    80008006:	9d6080e7          	jalr	-1578(ra) # 800009d8 <initlock>
  bd_base = (void *) p;
    8000800a:	00021797          	auipc	a5,0x21
    8000800e:	3a97b723          	sd	s1,942(a5) # 800293b8 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80008012:	409c0933          	sub	s2,s8,s1
    80008016:	43f95513          	srai	a0,s2,0x3f
    8000801a:	893d                	andi	a0,a0,15
    8000801c:	954a                	add	a0,a0,s2
    8000801e:	8511                	srai	a0,a0,0x4
    80008020:	00000097          	auipc	ra,0x0
    80008024:	c60080e7          	jalr	-928(ra) # 80007c80 <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    80008028:	47c1                	li	a5,16
    8000802a:	00a797b3          	sll	a5,a5,a0
    8000802e:	1b27c663          	blt	a5,s2,800081da <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80008032:	2505                	addiw	a0,a0,1
    80008034:	00021797          	auipc	a5,0x21
    80008038:	38a7aa23          	sw	a0,916(a5) # 800293c8 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    8000803c:	00021997          	auipc	s3,0x21
    80008040:	38c98993          	addi	s3,s3,908 # 800293c8 <nsizes>
    80008044:	0009a603          	lw	a2,0(s3)
    80008048:	85ca                	mv	a1,s2
    8000804a:	00002517          	auipc	a0,0x2
    8000804e:	cd650513          	addi	a0,a0,-810 # 80009d20 <userret+0xc90>
    80008052:	ffff8097          	auipc	ra,0xffff8
    80008056:	562080e7          	jalr	1378(ra) # 800005b4 <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    8000805a:	00021797          	auipc	a5,0x21
    8000805e:	3697b323          	sd	s1,870(a5) # 800293c0 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80008062:	0009a603          	lw	a2,0(s3)
    80008066:	00561913          	slli	s2,a2,0x5
    8000806a:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    8000806c:	0056161b          	slliw	a2,a2,0x5
    80008070:	4581                	li	a1,0
    80008072:	8526                	mv	a0,s1
    80008074:	ffff9097          	auipc	ra,0xffff9
    80008078:	d06080e7          	jalr	-762(ra) # 80000d7a <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    8000807c:	0009a783          	lw	a5,0(s3)
    80008080:	06f05a63          	blez	a5,800080f4 <bd_init+0x124>
    80008084:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80008086:	00021a97          	auipc	s5,0x21
    8000808a:	33aa8a93          	addi	s5,s5,826 # 800293c0 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    8000808e:	00021a17          	auipc	s4,0x21
    80008092:	33aa0a13          	addi	s4,s4,826 # 800293c8 <nsizes>
    80008096:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80008098:	00599b93          	slli	s7,s3,0x5
    8000809c:	000ab503          	ld	a0,0(s5)
    800080a0:	955e                	add	a0,a0,s7
    800080a2:	00000097          	auipc	ra,0x0
    800080a6:	166080e7          	jalr	358(ra) # 80008208 <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    800080aa:	000a2483          	lw	s1,0(s4)
    800080ae:	34fd                	addiw	s1,s1,-1
    800080b0:	413484bb          	subw	s1,s1,s3
    800080b4:	009b14bb          	sllw	s1,s6,s1
    800080b8:	fff4879b          	addiw	a5,s1,-1
    800080bc:	41f7d49b          	sraiw	s1,a5,0x1f
    800080c0:	01d4d49b          	srliw	s1,s1,0x1d
    800080c4:	9cbd                	addw	s1,s1,a5
    800080c6:	98e1                	andi	s1,s1,-8
    800080c8:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    800080ca:	000ab783          	ld	a5,0(s5)
    800080ce:	9bbe                	add	s7,s7,a5
    800080d0:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    800080d4:	848d                	srai	s1,s1,0x3
    800080d6:	8626                	mv	a2,s1
    800080d8:	4581                	li	a1,0
    800080da:	854a                	mv	a0,s2
    800080dc:	ffff9097          	auipc	ra,0xffff9
    800080e0:	c9e080e7          	jalr	-866(ra) # 80000d7a <memset>
    p += sz;
    800080e4:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    800080e6:	0985                	addi	s3,s3,1
    800080e8:	000a2703          	lw	a4,0(s4)
    800080ec:	0009879b          	sext.w	a5,s3
    800080f0:	fae7c4e3          	blt	a5,a4,80008098 <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    800080f4:	00021797          	auipc	a5,0x21
    800080f8:	2d47a783          	lw	a5,724(a5) # 800293c8 <nsizes>
    800080fc:	4705                	li	a4,1
    800080fe:	06f75163          	bge	a4,a5,80008160 <bd_init+0x190>
    80008102:	02000a13          	li	s4,32
    80008106:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80008108:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    8000810a:	00021b17          	auipc	s6,0x21
    8000810e:	2b6b0b13          	addi	s6,s6,694 # 800293c0 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80008112:	00021a97          	auipc	s5,0x21
    80008116:	2b6a8a93          	addi	s5,s5,694 # 800293c8 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    8000811a:	37fd                	addiw	a5,a5,-1
    8000811c:	413787bb          	subw	a5,a5,s3
    80008120:	00fb94bb          	sllw	s1,s7,a5
    80008124:	fff4879b          	addiw	a5,s1,-1
    80008128:	41f7d49b          	sraiw	s1,a5,0x1f
    8000812c:	01d4d49b          	srliw	s1,s1,0x1d
    80008130:	9cbd                	addw	s1,s1,a5
    80008132:	98e1                	andi	s1,s1,-8
    80008134:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80008136:	000b3783          	ld	a5,0(s6)
    8000813a:	97d2                	add	a5,a5,s4
    8000813c:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80008140:	848d                	srai	s1,s1,0x3
    80008142:	8626                	mv	a2,s1
    80008144:	4581                	li	a1,0
    80008146:	854a                	mv	a0,s2
    80008148:	ffff9097          	auipc	ra,0xffff9
    8000814c:	c32080e7          	jalr	-974(ra) # 80000d7a <memset>
    p += sz;
    80008150:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80008152:	2985                	addiw	s3,s3,1
    80008154:	000aa783          	lw	a5,0(s5)
    80008158:	020a0a13          	addi	s4,s4,32
    8000815c:	faf9cfe3          	blt	s3,a5,8000811a <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80008160:	197d                	addi	s2,s2,-1
    80008162:	ff097913          	andi	s2,s2,-16
    80008166:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    80008168:	854a                	mv	a0,s2
    8000816a:	00000097          	auipc	ra,0x0
    8000816e:	d7c080e7          	jalr	-644(ra) # 80007ee6 <bd_mark_data_structures>
    80008172:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    80008174:	85ca                	mv	a1,s2
    80008176:	8562                	mv	a0,s8
    80008178:	00000097          	auipc	ra,0x0
    8000817c:	dce080e7          	jalr	-562(ra) # 80007f46 <bd_mark_unavailable>
    80008180:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80008182:	00021a97          	auipc	s5,0x21
    80008186:	246a8a93          	addi	s5,s5,582 # 800293c8 <nsizes>
    8000818a:	000aa783          	lw	a5,0(s5)
    8000818e:	37fd                	addiw	a5,a5,-1
    80008190:	44c1                	li	s1,16
    80008192:	00f497b3          	sll	a5,s1,a5
    80008196:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    80008198:	00021597          	auipc	a1,0x21
    8000819c:	2205b583          	ld	a1,544(a1) # 800293b8 <bd_base>
    800081a0:	95be                	add	a1,a1,a5
    800081a2:	854a                	mv	a0,s2
    800081a4:	00000097          	auipc	ra,0x0
    800081a8:	c86080e7          	jalr	-890(ra) # 80007e2a <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    800081ac:	000aa603          	lw	a2,0(s5)
    800081b0:	367d                	addiw	a2,a2,-1
    800081b2:	00c49633          	sll	a2,s1,a2
    800081b6:	41460633          	sub	a2,a2,s4
    800081ba:	41360633          	sub	a2,a2,s3
    800081be:	02c51463          	bne	a0,a2,800081e6 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    800081c2:	60a6                	ld	ra,72(sp)
    800081c4:	6406                	ld	s0,64(sp)
    800081c6:	74e2                	ld	s1,56(sp)
    800081c8:	7942                	ld	s2,48(sp)
    800081ca:	79a2                	ld	s3,40(sp)
    800081cc:	7a02                	ld	s4,32(sp)
    800081ce:	6ae2                	ld	s5,24(sp)
    800081d0:	6b42                	ld	s6,16(sp)
    800081d2:	6ba2                	ld	s7,8(sp)
    800081d4:	6c02                	ld	s8,0(sp)
    800081d6:	6161                	addi	sp,sp,80
    800081d8:	8082                	ret
    nsizes++;  // round up to the next power of 2
    800081da:	2509                	addiw	a0,a0,2
    800081dc:	00021797          	auipc	a5,0x21
    800081e0:	1ea7a623          	sw	a0,492(a5) # 800293c8 <nsizes>
    800081e4:	bda1                	j	8000803c <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    800081e6:	85aa                	mv	a1,a0
    800081e8:	00002517          	auipc	a0,0x2
    800081ec:	b7850513          	addi	a0,a0,-1160 # 80009d60 <userret+0xcd0>
    800081f0:	ffff8097          	auipc	ra,0xffff8
    800081f4:	3c4080e7          	jalr	964(ra) # 800005b4 <printf>
    panic("bd_init: free mem");
    800081f8:	00002517          	auipc	a0,0x2
    800081fc:	b7850513          	addi	a0,a0,-1160 # 80009d70 <userret+0xce0>
    80008200:	ffff8097          	auipc	ra,0xffff8
    80008204:	35a080e7          	jalr	858(ra) # 8000055a <panic>

0000000080008208 <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    80008208:	1141                	addi	sp,sp,-16
    8000820a:	e422                	sd	s0,8(sp)
    8000820c:	0800                	addi	s0,sp,16
  lst->next = lst;
    8000820e:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    80008210:	e508                	sd	a0,8(a0)
}
    80008212:	6422                	ld	s0,8(sp)
    80008214:	0141                	addi	sp,sp,16
    80008216:	8082                	ret

0000000080008218 <lst_empty>:

int
lst_empty(struct list *lst) {
    80008218:	1141                	addi	sp,sp,-16
    8000821a:	e422                	sd	s0,8(sp)
    8000821c:	0800                	addi	s0,sp,16
  return lst->next == lst;
    8000821e:	611c                	ld	a5,0(a0)
    80008220:	40a78533          	sub	a0,a5,a0
}
    80008224:	00153513          	seqz	a0,a0
    80008228:	6422                	ld	s0,8(sp)
    8000822a:	0141                	addi	sp,sp,16
    8000822c:	8082                	ret

000000008000822e <lst_remove>:

void
lst_remove(struct list *e) {
    8000822e:	1141                	addi	sp,sp,-16
    80008230:	e422                	sd	s0,8(sp)
    80008232:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80008234:	6518                	ld	a4,8(a0)
    80008236:	611c                	ld	a5,0(a0)
    80008238:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    8000823a:	6518                	ld	a4,8(a0)
    8000823c:	e798                	sd	a4,8(a5)
}
    8000823e:	6422                	ld	s0,8(sp)
    80008240:	0141                	addi	sp,sp,16
    80008242:	8082                	ret

0000000080008244 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80008244:	1101                	addi	sp,sp,-32
    80008246:	ec06                	sd	ra,24(sp)
    80008248:	e822                	sd	s0,16(sp)
    8000824a:	e426                	sd	s1,8(sp)
    8000824c:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    8000824e:	6104                	ld	s1,0(a0)
    80008250:	00a48d63          	beq	s1,a0,8000826a <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80008254:	8526                	mv	a0,s1
    80008256:	00000097          	auipc	ra,0x0
    8000825a:	fd8080e7          	jalr	-40(ra) # 8000822e <lst_remove>
  return (void *)p;
}
    8000825e:	8526                	mv	a0,s1
    80008260:	60e2                	ld	ra,24(sp)
    80008262:	6442                	ld	s0,16(sp)
    80008264:	64a2                	ld	s1,8(sp)
    80008266:	6105                	addi	sp,sp,32
    80008268:	8082                	ret
    panic("lst_pop");
    8000826a:	00002517          	auipc	a0,0x2
    8000826e:	b1e50513          	addi	a0,a0,-1250 # 80009d88 <userret+0xcf8>
    80008272:	ffff8097          	auipc	ra,0xffff8
    80008276:	2e8080e7          	jalr	744(ra) # 8000055a <panic>

000000008000827a <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    8000827a:	1141                	addi	sp,sp,-16
    8000827c:	e422                	sd	s0,8(sp)
    8000827e:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    80008280:	611c                	ld	a5,0(a0)
    80008282:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    80008284:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    80008286:	611c                	ld	a5,0(a0)
    80008288:	e78c                	sd	a1,8(a5)
  lst->next = e;
    8000828a:	e10c                	sd	a1,0(a0)
}
    8000828c:	6422                	ld	s0,8(sp)
    8000828e:	0141                	addi	sp,sp,16
    80008290:	8082                	ret

0000000080008292 <lst_print>:

void
lst_print(struct list *lst)
{
    80008292:	7179                	addi	sp,sp,-48
    80008294:	f406                	sd	ra,40(sp)
    80008296:	f022                	sd	s0,32(sp)
    80008298:	ec26                	sd	s1,24(sp)
    8000829a:	e84a                	sd	s2,16(sp)
    8000829c:	e44e                	sd	s3,8(sp)
    8000829e:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800082a0:	6104                	ld	s1,0(a0)
    800082a2:	02950063          	beq	a0,s1,800082c2 <lst_print+0x30>
    800082a6:	892a                	mv	s2,a0
    printf(" %p", p);
    800082a8:	00002997          	auipc	s3,0x2
    800082ac:	ae898993          	addi	s3,s3,-1304 # 80009d90 <userret+0xd00>
    800082b0:	85a6                	mv	a1,s1
    800082b2:	854e                	mv	a0,s3
    800082b4:	ffff8097          	auipc	ra,0xffff8
    800082b8:	300080e7          	jalr	768(ra) # 800005b4 <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800082bc:	6084                	ld	s1,0(s1)
    800082be:	fe9919e3          	bne	s2,s1,800082b0 <lst_print+0x1e>
  }
  printf("\n");
    800082c2:	00001517          	auipc	a0,0x1
    800082c6:	fce50513          	addi	a0,a0,-50 # 80009290 <userret+0x200>
    800082ca:	ffff8097          	auipc	ra,0xffff8
    800082ce:	2ea080e7          	jalr	746(ra) # 800005b4 <printf>
}
    800082d2:	70a2                	ld	ra,40(sp)
    800082d4:	7402                	ld	s0,32(sp)
    800082d6:	64e2                	ld	s1,24(sp)
    800082d8:	6942                	ld	s2,16(sp)
    800082da:	69a2                	ld	s3,8(sp)
    800082dc:	6145                	addi	sp,sp,48
    800082de:	8082                	ret
	...

0000000080009000 <trampoline>:
    80009000:	14051573          	csrrw	a0,sscratch,a0
    80009004:	02153423          	sd	ra,40(a0)
    80009008:	02253823          	sd	sp,48(a0)
    8000900c:	02353c23          	sd	gp,56(a0)
    80009010:	04453023          	sd	tp,64(a0)
    80009014:	04553423          	sd	t0,72(a0)
    80009018:	04653823          	sd	t1,80(a0)
    8000901c:	04753c23          	sd	t2,88(a0)
    80009020:	f120                	sd	s0,96(a0)
    80009022:	f524                	sd	s1,104(a0)
    80009024:	fd2c                	sd	a1,120(a0)
    80009026:	e150                	sd	a2,128(a0)
    80009028:	e554                	sd	a3,136(a0)
    8000902a:	e958                	sd	a4,144(a0)
    8000902c:	ed5c                	sd	a5,152(a0)
    8000902e:	0b053023          	sd	a6,160(a0)
    80009032:	0b153423          	sd	a7,168(a0)
    80009036:	0b253823          	sd	s2,176(a0)
    8000903a:	0b353c23          	sd	s3,184(a0)
    8000903e:	0d453023          	sd	s4,192(a0)
    80009042:	0d553423          	sd	s5,200(a0)
    80009046:	0d653823          	sd	s6,208(a0)
    8000904a:	0d753c23          	sd	s7,216(a0)
    8000904e:	0f853023          	sd	s8,224(a0)
    80009052:	0f953423          	sd	s9,232(a0)
    80009056:	0fa53823          	sd	s10,240(a0)
    8000905a:	0fb53c23          	sd	s11,248(a0)
    8000905e:	11c53023          	sd	t3,256(a0)
    80009062:	11d53423          	sd	t4,264(a0)
    80009066:	11e53823          	sd	t5,272(a0)
    8000906a:	11f53c23          	sd	t6,280(a0)
    8000906e:	140022f3          	csrr	t0,sscratch
    80009072:	06553823          	sd	t0,112(a0)
    80009076:	00853103          	ld	sp,8(a0)
    8000907a:	02053203          	ld	tp,32(a0)
    8000907e:	01053283          	ld	t0,16(a0)
    80009082:	00053303          	ld	t1,0(a0)
    80009086:	18031073          	csrw	satp,t1
    8000908a:	12000073          	sfence.vma
    8000908e:	8282                	jr	t0

0000000080009090 <userret>:
    80009090:	18059073          	csrw	satp,a1
    80009094:	12000073          	sfence.vma
    80009098:	07053283          	ld	t0,112(a0)
    8000909c:	14029073          	csrw	sscratch,t0
    800090a0:	02853083          	ld	ra,40(a0)
    800090a4:	03053103          	ld	sp,48(a0)
    800090a8:	03853183          	ld	gp,56(a0)
    800090ac:	04053203          	ld	tp,64(a0)
    800090b0:	04853283          	ld	t0,72(a0)
    800090b4:	05053303          	ld	t1,80(a0)
    800090b8:	05853383          	ld	t2,88(a0)
    800090bc:	7120                	ld	s0,96(a0)
    800090be:	7524                	ld	s1,104(a0)
    800090c0:	7d2c                	ld	a1,120(a0)
    800090c2:	6150                	ld	a2,128(a0)
    800090c4:	6554                	ld	a3,136(a0)
    800090c6:	6958                	ld	a4,144(a0)
    800090c8:	6d5c                	ld	a5,152(a0)
    800090ca:	0a053803          	ld	a6,160(a0)
    800090ce:	0a853883          	ld	a7,168(a0)
    800090d2:	0b053903          	ld	s2,176(a0)
    800090d6:	0b853983          	ld	s3,184(a0)
    800090da:	0c053a03          	ld	s4,192(a0)
    800090de:	0c853a83          	ld	s5,200(a0)
    800090e2:	0d053b03          	ld	s6,208(a0)
    800090e6:	0d853b83          	ld	s7,216(a0)
    800090ea:	0e053c03          	ld	s8,224(a0)
    800090ee:	0e853c83          	ld	s9,232(a0)
    800090f2:	0f053d03          	ld	s10,240(a0)
    800090f6:	0f853d83          	ld	s11,248(a0)
    800090fa:	10053e03          	ld	t3,256(a0)
    800090fe:	10853e83          	ld	t4,264(a0)
    80009102:	11053f03          	ld	t5,272(a0)
    80009106:	11853f83          	ld	t6,280(a0)
    8000910a:	14051573          	csrrw	a0,sscratch,a0
    8000910e:	10200073          	sret
