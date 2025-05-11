
_mlfq_test1:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#include "user.h"
#include "pstat.h"

#define NPROCS 3

int workload(int n) {
   0:	f3 0f 1e fb          	endbr32
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 ec 10             	sub    $0x10,%esp
  int i, j = 0;
   a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for (i = 0; i < n; i++) {
  11:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  18:	eb 11                	jmp    2b <workload+0x2b>
    j += i * j + 1;
  1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1d:	0f af 45 f8          	imul   -0x8(%ebp),%eax
  21:	83 c0 01             	add    $0x1,%eax
  24:	01 45 f8             	add    %eax,-0x8(%ebp)
  for (i = 0; i < n; i++) {
  27:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  2e:	3b 45 08             	cmp    0x8(%ebp),%eax
  31:	7c e7                	jl     1a <workload+0x1a>
  };
  return j;
  33:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  36:	c9                   	leave
  37:	c3                   	ret

00000038 <print_stat>:

void print_stat() {
  38:	f3 0f 1e fb          	endbr32
  3c:	55                   	push   %ebp
  3d:	89 e5                	mov    %esp,%ebp
  3f:	57                   	push   %edi
  40:	56                   	push   %esi
  41:	53                   	push   %ebx
  42:	81 ec 2c 0c 00 00    	sub    $0xc2c,%esp
  struct pstat ps;
  getpinfo(&ps);
  48:	83 ec 0c             	sub    $0xc,%esp
  4b:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
  51:	50                   	push   %eax
  52:	e8 25 05 00 00       	call   57c <getpinfo>
  57:	83 c4 10             	add    $0x10,%esp
  printf(1, "\n[RESULT] Process Statistics\n");
  5a:	83 ec 08             	sub    $0x8,%esp
  5d:	68 40 0a 00 00       	push   $0xa40
  62:	6a 01                	push   $0x1
  64:	e8 0f 06 00 00       	call   678 <printf>
  69:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
  6c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  73:	e9 0b 01 00 00       	jmp    183 <print_stat+0x14b>
    if (ps.inuse[i]) {
  78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  7b:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
  82:	85 c0                	test   %eax,%eax
  84:	0f 84 f5 00 00 00    	je     17f <print_stat+0x147>
      printf(1, "PID %d | Priority %d | Ticks: [Q3:%d Q2:%d Q1:%d Q0:%d] | Wait: [Q3:%d Q2:%d Q1:%d Q0:%d]\n",
  8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8d:	83 e8 80             	sub    $0xffffff80,%eax
  90:	c1 e0 04             	shl    $0x4,%eax
  93:	8d 55 e8             	lea    -0x18(%ebp),%edx
  96:	01 d0                	add    %edx,%eax
  98:	2d 04 0c 00 00       	sub    $0xc04,%eax
  9d:	8b 30                	mov    (%eax),%esi
  9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  a2:	c1 e0 04             	shl    $0x4,%eax
  a5:	8d 4d e8             	lea    -0x18(%ebp),%ecx
  a8:	01 c8                	add    %ecx,%eax
  aa:	2d 00 04 00 00       	sub    $0x400,%eax
  af:	8b 38                	mov    (%eax),%edi
  b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  b4:	c1 e0 04             	shl    $0x4,%eax
  b7:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  ba:	01 d8                	add    %ebx,%eax
  bc:	2d fc 03 00 00       	sub    $0x3fc,%eax
  c1:	8b 00                	mov    (%eax),%eax
  c3:	89 85 d4 f3 ff ff    	mov    %eax,-0xc2c(%ebp)
  c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  cc:	c1 e0 04             	shl    $0x4,%eax
  cf:	8d 55 e8             	lea    -0x18(%ebp),%edx
  d2:	01 d0                	add    %edx,%eax
  d4:	2d f8 03 00 00       	sub    $0x3f8,%eax
  d9:	8b 08                	mov    (%eax),%ecx
  db:	89 8d d0 f3 ff ff    	mov    %ecx,-0xc30(%ebp)
  e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  e4:	83 c0 40             	add    $0x40,%eax
  e7:	c1 e0 04             	shl    $0x4,%eax
  ea:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  ed:	01 d8                	add    %ebx,%eax
  ef:	2d 04 0c 00 00       	sub    $0xc04,%eax
  f4:	8b 10                	mov    (%eax),%edx
  f6:	89 95 cc f3 ff ff    	mov    %edx,-0xc34(%ebp)
  fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  ff:	c1 e0 04             	shl    $0x4,%eax
 102:	8d 5d e8             	lea    -0x18(%ebp),%ebx
 105:	01 d8                	add    %ebx,%eax
 107:	2d 00 08 00 00       	sub    $0x800,%eax
 10c:	8b 18                	mov    (%eax),%ebx
 10e:	89 9d c8 f3 ff ff    	mov    %ebx,-0xc38(%ebp)
 114:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 117:	c1 e0 04             	shl    $0x4,%eax
 11a:	8d 4d e8             	lea    -0x18(%ebp),%ecx
 11d:	01 c8                	add    %ecx,%eax
 11f:	2d fc 07 00 00       	sub    $0x7fc,%eax
 124:	8b 18                	mov    (%eax),%ebx
 126:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 129:	c1 e0 04             	shl    $0x4,%eax
 12c:	8d 55 e8             	lea    -0x18(%ebp),%edx
 12f:	01 d0                	add    %edx,%eax
 131:	2d f8 07 00 00       	sub    $0x7f8,%eax
 136:	8b 08                	mov    (%eax),%ecx
 138:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 13b:	83 e8 80             	sub    $0xffffff80,%eax
 13e:	8b 94 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%edx
 145:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 148:	83 c0 40             	add    $0x40,%eax
 14b:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
 152:	56                   	push   %esi
 153:	57                   	push   %edi
 154:	ff b5 d4 f3 ff ff    	push   -0xc2c(%ebp)
 15a:	ff b5 d0 f3 ff ff    	push   -0xc30(%ebp)
 160:	ff b5 cc f3 ff ff    	push   -0xc34(%ebp)
 166:	ff b5 c8 f3 ff ff    	push   -0xc38(%ebp)
 16c:	53                   	push   %ebx
 16d:	51                   	push   %ecx
 16e:	52                   	push   %edx
 16f:	50                   	push   %eax
 170:	68 60 0a 00 00       	push   $0xa60
 175:	6a 01                	push   $0x1
 177:	e8 fc 04 00 00       	call   678 <printf>
 17c:	83 c4 30             	add    $0x30,%esp
  for (int i = 0; i < NPROC; i++) {
 17f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 183:	83 7d e4 3f          	cmpl   $0x3f,-0x1c(%ebp)
 187:	0f 8e eb fe ff ff    	jle    78 <print_stat+0x40>
        ps.pid[i], ps.priority[i],
        ps.ticks[i][3], ps.ticks[i][2], ps.ticks[i][1], ps.ticks[i][0],
        ps.wait_ticks[i][3], ps.wait_ticks[i][2], ps.wait_ticks[i][1], ps.wait_ticks[i][0]);
    }
  }
}
 18d:	90                   	nop
 18e:	90                   	nop
 18f:	8d 65 f4             	lea    -0xc(%ebp),%esp
 192:	5b                   	pop    %ebx
 193:	5e                   	pop    %esi
 194:	5f                   	pop    %edi
 195:	5d                   	pop    %ebp
 196:	c3                   	ret

00000197 <run_policy_1>:

void run_policy_1() {
 197:	f3 0f 1e fb          	endbr32
 19b:	55                   	push   %ebp
 19c:	89 e5                	mov    %esp,%ebp
 19e:	83 ec 18             	sub    $0x18,%esp
  printf(1, "[DEBUG] Entered run_policy_1()\n");
 1a1:	83 ec 08             	sub    $0x8,%esp
 1a4:	68 bc 0a 00 00       	push   $0xabc
 1a9:	6a 01                	push   $0x1
 1ab:	e8 c8 04 00 00       	call   678 <printf>
 1b0:	83 c4 10             	add    $0x10,%esp
  setSchedPolicy(1);
 1b3:	83 ec 0c             	sub    $0xc,%esp
 1b6:	6a 01                	push   $0x1
 1b8:	e8 c7 03 00 00       	call   584 <setSchedPolicy>
 1bd:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROCS; i++) {
 1c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1c7:	eb 2f                	jmp    1f8 <run_policy_1+0x61>
    int pid = fork();
 1c9:	e8 06 03 00 00       	call   4d4 <fork>
 1ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid == 0) {
 1d1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 1d5:	75 1d                	jne    1f4 <run_policy_1+0x5d>
      workload(200000000 * (i + 1));      
 1d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1da:	83 c0 01             	add    $0x1,%eax
 1dd:	69 c0 00 c2 eb 0b    	imul   $0xbebc200,%eax,%eax
 1e3:	83 ec 0c             	sub    $0xc,%esp
 1e6:	50                   	push   %eax
 1e7:	e8 14 fe ff ff       	call   0 <workload>
 1ec:	83 c4 10             	add    $0x10,%esp
      exit();
 1ef:	e8 e8 02 00 00       	call   4dc <exit>
  for (int i = 0; i < NPROCS; i++) {
 1f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1f8:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
 1fc:	7e cb                	jle    1c9 <run_policy_1+0x32>
    }
  }
  printf(1, "praents process wait\n");
 1fe:	83 ec 08             	sub    $0x8,%esp
 201:	68 dc 0a 00 00       	push   $0xadc
 206:	6a 01                	push   $0x1
 208:	e8 6b 04 00 00       	call   678 <printf>
 20d:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROCS; i++) wait();
 210:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 217:	eb 09                	jmp    222 <run_policy_1+0x8b>
 219:	e8 c6 02 00 00       	call   4e4 <wait>
 21e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 222:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
 226:	7e f1                	jle    219 <run_policy_1+0x82>
  print_stat();
 228:	e8 0b fe ff ff       	call   38 <print_stat>
}
 22d:	90                   	nop
 22e:	c9                   	leave
 22f:	c3                   	ret

00000230 <main>:

int main(void) {
 230:	f3 0f 1e fb          	endbr32
 234:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 238:	83 e4 f0             	and    $0xfffffff0,%esp
 23b:	ff 71 fc             	push   -0x4(%ecx)
 23e:	55                   	push   %ebp
 23f:	89 e5                	mov    %esp,%ebp
 241:	51                   	push   %ecx
 242:	83 ec 04             	sub    $0x4,%esp
  printf(1, "\n===== [POLICY 1: tracking + boosting] =====\n");
 245:	83 ec 08             	sub    $0x8,%esp
 248:	68 f4 0a 00 00       	push   $0xaf4
 24d:	6a 01                	push   $0x1
 24f:	e8 24 04 00 00       	call   678 <printf>
 254:	83 c4 10             	add    $0x10,%esp
  run_policy_1();
 257:	e8 3b ff ff ff       	call   197 <run_policy_1>
  exit();
 25c:	e8 7b 02 00 00       	call   4dc <exit>

00000261 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 261:	55                   	push   %ebp
 262:	89 e5                	mov    %esp,%ebp
 264:	57                   	push   %edi
 265:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 266:	8b 4d 08             	mov    0x8(%ebp),%ecx
 269:	8b 55 10             	mov    0x10(%ebp),%edx
 26c:	8b 45 0c             	mov    0xc(%ebp),%eax
 26f:	89 cb                	mov    %ecx,%ebx
 271:	89 df                	mov    %ebx,%edi
 273:	89 d1                	mov    %edx,%ecx
 275:	fc                   	cld
 276:	f3 aa                	rep stos %al,%es:(%edi)
 278:	89 ca                	mov    %ecx,%edx
 27a:	89 fb                	mov    %edi,%ebx
 27c:	89 5d 08             	mov    %ebx,0x8(%ebp)
 27f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 282:	90                   	nop
 283:	5b                   	pop    %ebx
 284:	5f                   	pop    %edi
 285:	5d                   	pop    %ebp
 286:	c3                   	ret

00000287 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 287:	f3 0f 1e fb          	endbr32
 28b:	55                   	push   %ebp
 28c:	89 e5                	mov    %esp,%ebp
 28e:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 291:	8b 45 08             	mov    0x8(%ebp),%eax
 294:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 297:	90                   	nop
 298:	8b 55 0c             	mov    0xc(%ebp),%edx
 29b:	8d 42 01             	lea    0x1(%edx),%eax
 29e:	89 45 0c             	mov    %eax,0xc(%ebp)
 2a1:	8b 45 08             	mov    0x8(%ebp),%eax
 2a4:	8d 48 01             	lea    0x1(%eax),%ecx
 2a7:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2aa:	0f b6 12             	movzbl (%edx),%edx
 2ad:	88 10                	mov    %dl,(%eax)
 2af:	0f b6 00             	movzbl (%eax),%eax
 2b2:	84 c0                	test   %al,%al
 2b4:	75 e2                	jne    298 <strcpy+0x11>
    ;
  return os;
 2b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2b9:	c9                   	leave
 2ba:	c3                   	ret

000002bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2bb:	f3 0f 1e fb          	endbr32
 2bf:	55                   	push   %ebp
 2c0:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2c2:	eb 08                	jmp    2cc <strcmp+0x11>
    p++, q++;
 2c4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2c8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 2cc:	8b 45 08             	mov    0x8(%ebp),%eax
 2cf:	0f b6 00             	movzbl (%eax),%eax
 2d2:	84 c0                	test   %al,%al
 2d4:	74 10                	je     2e6 <strcmp+0x2b>
 2d6:	8b 45 08             	mov    0x8(%ebp),%eax
 2d9:	0f b6 10             	movzbl (%eax),%edx
 2dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2df:	0f b6 00             	movzbl (%eax),%eax
 2e2:	38 c2                	cmp    %al,%dl
 2e4:	74 de                	je     2c4 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 2e6:	8b 45 08             	mov    0x8(%ebp),%eax
 2e9:	0f b6 00             	movzbl (%eax),%eax
 2ec:	0f b6 d0             	movzbl %al,%edx
 2ef:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f2:	0f b6 00             	movzbl (%eax),%eax
 2f5:	0f b6 c0             	movzbl %al,%eax
 2f8:	29 c2                	sub    %eax,%edx
 2fa:	89 d0                	mov    %edx,%eax
}
 2fc:	5d                   	pop    %ebp
 2fd:	c3                   	ret

000002fe <strlen>:

uint
strlen(char *s)
{
 2fe:	f3 0f 1e fb          	endbr32
 302:	55                   	push   %ebp
 303:	89 e5                	mov    %esp,%ebp
 305:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 308:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 30f:	eb 04                	jmp    315 <strlen+0x17>
 311:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 315:	8b 55 fc             	mov    -0x4(%ebp),%edx
 318:	8b 45 08             	mov    0x8(%ebp),%eax
 31b:	01 d0                	add    %edx,%eax
 31d:	0f b6 00             	movzbl (%eax),%eax
 320:	84 c0                	test   %al,%al
 322:	75 ed                	jne    311 <strlen+0x13>
    ;
  return n;
 324:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 327:	c9                   	leave
 328:	c3                   	ret

00000329 <memset>:

void*
memset(void *dst, int c, uint n)
{
 329:	f3 0f 1e fb          	endbr32
 32d:	55                   	push   %ebp
 32e:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 330:	8b 45 10             	mov    0x10(%ebp),%eax
 333:	50                   	push   %eax
 334:	ff 75 0c             	push   0xc(%ebp)
 337:	ff 75 08             	push   0x8(%ebp)
 33a:	e8 22 ff ff ff       	call   261 <stosb>
 33f:	83 c4 0c             	add    $0xc,%esp
  return dst;
 342:	8b 45 08             	mov    0x8(%ebp),%eax
}
 345:	c9                   	leave
 346:	c3                   	ret

00000347 <strchr>:

char*
strchr(const char *s, char c)
{
 347:	f3 0f 1e fb          	endbr32
 34b:	55                   	push   %ebp
 34c:	89 e5                	mov    %esp,%ebp
 34e:	83 ec 04             	sub    $0x4,%esp
 351:	8b 45 0c             	mov    0xc(%ebp),%eax
 354:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 357:	eb 14                	jmp    36d <strchr+0x26>
    if(*s == c)
 359:	8b 45 08             	mov    0x8(%ebp),%eax
 35c:	0f b6 00             	movzbl (%eax),%eax
 35f:	38 45 fc             	cmp    %al,-0x4(%ebp)
 362:	75 05                	jne    369 <strchr+0x22>
      return (char*)s;
 364:	8b 45 08             	mov    0x8(%ebp),%eax
 367:	eb 13                	jmp    37c <strchr+0x35>
  for(; *s; s++)
 369:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 36d:	8b 45 08             	mov    0x8(%ebp),%eax
 370:	0f b6 00             	movzbl (%eax),%eax
 373:	84 c0                	test   %al,%al
 375:	75 e2                	jne    359 <strchr+0x12>
  return 0;
 377:	b8 00 00 00 00       	mov    $0x0,%eax
}
 37c:	c9                   	leave
 37d:	c3                   	ret

0000037e <gets>:

char*
gets(char *buf, int max)
{
 37e:	f3 0f 1e fb          	endbr32
 382:	55                   	push   %ebp
 383:	89 e5                	mov    %esp,%ebp
 385:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 388:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 38f:	eb 42                	jmp    3d3 <gets+0x55>
    cc = read(0, &c, 1);
 391:	83 ec 04             	sub    $0x4,%esp
 394:	6a 01                	push   $0x1
 396:	8d 45 ef             	lea    -0x11(%ebp),%eax
 399:	50                   	push   %eax
 39a:	6a 00                	push   $0x0
 39c:	e8 53 01 00 00       	call   4f4 <read>
 3a1:	83 c4 10             	add    $0x10,%esp
 3a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3ab:	7e 33                	jle    3e0 <gets+0x62>
      break;
    buf[i++] = c;
 3ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3b0:	8d 50 01             	lea    0x1(%eax),%edx
 3b3:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3b6:	89 c2                	mov    %eax,%edx
 3b8:	8b 45 08             	mov    0x8(%ebp),%eax
 3bb:	01 c2                	add    %eax,%edx
 3bd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3c1:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3c3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3c7:	3c 0a                	cmp    $0xa,%al
 3c9:	74 16                	je     3e1 <gets+0x63>
 3cb:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3cf:	3c 0d                	cmp    $0xd,%al
 3d1:	74 0e                	je     3e1 <gets+0x63>
  for(i=0; i+1 < max; ){
 3d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d6:	83 c0 01             	add    $0x1,%eax
 3d9:	39 45 0c             	cmp    %eax,0xc(%ebp)
 3dc:	7f b3                	jg     391 <gets+0x13>
 3de:	eb 01                	jmp    3e1 <gets+0x63>
      break;
 3e0:	90                   	nop
      break;
  }
  buf[i] = '\0';
 3e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3e4:	8b 45 08             	mov    0x8(%ebp),%eax
 3e7:	01 d0                	add    %edx,%eax
 3e9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3ec:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3ef:	c9                   	leave
 3f0:	c3                   	ret

000003f1 <stat>:

int
stat(char *n, struct stat *st)
{
 3f1:	f3 0f 1e fb          	endbr32
 3f5:	55                   	push   %ebp
 3f6:	89 e5                	mov    %esp,%ebp
 3f8:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3fb:	83 ec 08             	sub    $0x8,%esp
 3fe:	6a 00                	push   $0x0
 400:	ff 75 08             	push   0x8(%ebp)
 403:	e8 14 01 00 00       	call   51c <open>
 408:	83 c4 10             	add    $0x10,%esp
 40b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 40e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 412:	79 07                	jns    41b <stat+0x2a>
    return -1;
 414:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 419:	eb 25                	jmp    440 <stat+0x4f>
  r = fstat(fd, st);
 41b:	83 ec 08             	sub    $0x8,%esp
 41e:	ff 75 0c             	push   0xc(%ebp)
 421:	ff 75 f4             	push   -0xc(%ebp)
 424:	e8 0b 01 00 00       	call   534 <fstat>
 429:	83 c4 10             	add    $0x10,%esp
 42c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 42f:	83 ec 0c             	sub    $0xc,%esp
 432:	ff 75 f4             	push   -0xc(%ebp)
 435:	e8 ca 00 00 00       	call   504 <close>
 43a:	83 c4 10             	add    $0x10,%esp
  return r;
 43d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 440:	c9                   	leave
 441:	c3                   	ret

00000442 <atoi>:

int
atoi(const char *s)
{
 442:	f3 0f 1e fb          	endbr32
 446:	55                   	push   %ebp
 447:	89 e5                	mov    %esp,%ebp
 449:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 44c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 453:	eb 25                	jmp    47a <atoi+0x38>
    n = n*10 + *s++ - '0';
 455:	8b 55 fc             	mov    -0x4(%ebp),%edx
 458:	89 d0                	mov    %edx,%eax
 45a:	c1 e0 02             	shl    $0x2,%eax
 45d:	01 d0                	add    %edx,%eax
 45f:	01 c0                	add    %eax,%eax
 461:	89 c1                	mov    %eax,%ecx
 463:	8b 45 08             	mov    0x8(%ebp),%eax
 466:	8d 50 01             	lea    0x1(%eax),%edx
 469:	89 55 08             	mov    %edx,0x8(%ebp)
 46c:	0f b6 00             	movzbl (%eax),%eax
 46f:	0f be c0             	movsbl %al,%eax
 472:	01 c8                	add    %ecx,%eax
 474:	83 e8 30             	sub    $0x30,%eax
 477:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 47a:	8b 45 08             	mov    0x8(%ebp),%eax
 47d:	0f b6 00             	movzbl (%eax),%eax
 480:	3c 2f                	cmp    $0x2f,%al
 482:	7e 0a                	jle    48e <atoi+0x4c>
 484:	8b 45 08             	mov    0x8(%ebp),%eax
 487:	0f b6 00             	movzbl (%eax),%eax
 48a:	3c 39                	cmp    $0x39,%al
 48c:	7e c7                	jle    455 <atoi+0x13>
  return n;
 48e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 491:	c9                   	leave
 492:	c3                   	ret

00000493 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 493:	f3 0f 1e fb          	endbr32
 497:	55                   	push   %ebp
 498:	89 e5                	mov    %esp,%ebp
 49a:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 49d:	8b 45 08             	mov    0x8(%ebp),%eax
 4a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4a3:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4a9:	eb 17                	jmp    4c2 <memmove+0x2f>
    *dst++ = *src++;
 4ab:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4ae:	8d 42 01             	lea    0x1(%edx),%eax
 4b1:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4b7:	8d 48 01             	lea    0x1(%eax),%ecx
 4ba:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4bd:	0f b6 12             	movzbl (%edx),%edx
 4c0:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4c2:	8b 45 10             	mov    0x10(%ebp),%eax
 4c5:	8d 50 ff             	lea    -0x1(%eax),%edx
 4c8:	89 55 10             	mov    %edx,0x10(%ebp)
 4cb:	85 c0                	test   %eax,%eax
 4cd:	7f dc                	jg     4ab <memmove+0x18>
  return vdst;
 4cf:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4d2:	c9                   	leave
 4d3:	c3                   	ret

000004d4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4d4:	b8 01 00 00 00       	mov    $0x1,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret

000004dc <exit>:
SYSCALL(exit)
 4dc:	b8 02 00 00 00       	mov    $0x2,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret

000004e4 <wait>:
SYSCALL(wait)
 4e4:	b8 03 00 00 00       	mov    $0x3,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret

000004ec <pipe>:
SYSCALL(pipe)
 4ec:	b8 04 00 00 00       	mov    $0x4,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret

000004f4 <read>:
SYSCALL(read)
 4f4:	b8 05 00 00 00       	mov    $0x5,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret

000004fc <write>:
SYSCALL(write)
 4fc:	b8 10 00 00 00       	mov    $0x10,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret

00000504 <close>:
SYSCALL(close)
 504:	b8 15 00 00 00       	mov    $0x15,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret

0000050c <kill>:
SYSCALL(kill)
 50c:	b8 06 00 00 00       	mov    $0x6,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret

00000514 <exec>:
SYSCALL(exec)
 514:	b8 07 00 00 00       	mov    $0x7,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret

0000051c <open>:
SYSCALL(open)
 51c:	b8 0f 00 00 00       	mov    $0xf,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret

00000524 <mknod>:
SYSCALL(mknod)
 524:	b8 11 00 00 00       	mov    $0x11,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret

0000052c <unlink>:
SYSCALL(unlink)
 52c:	b8 12 00 00 00       	mov    $0x12,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret

00000534 <fstat>:
SYSCALL(fstat)
 534:	b8 08 00 00 00       	mov    $0x8,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret

0000053c <link>:
SYSCALL(link)
 53c:	b8 13 00 00 00       	mov    $0x13,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret

00000544 <mkdir>:
SYSCALL(mkdir)
 544:	b8 14 00 00 00       	mov    $0x14,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret

0000054c <chdir>:
SYSCALL(chdir)
 54c:	b8 09 00 00 00       	mov    $0x9,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret

00000554 <dup>:
SYSCALL(dup)
 554:	b8 0a 00 00 00       	mov    $0xa,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret

0000055c <getpid>:
SYSCALL(getpid)
 55c:	b8 0b 00 00 00       	mov    $0xb,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret

00000564 <sbrk>:
SYSCALL(sbrk)
 564:	b8 0c 00 00 00       	mov    $0xc,%eax
 569:	cd 40                	int    $0x40
 56b:	c3                   	ret

0000056c <sleep>:
SYSCALL(sleep)
 56c:	b8 0d 00 00 00       	mov    $0xd,%eax
 571:	cd 40                	int    $0x40
 573:	c3                   	ret

00000574 <uptime>:
SYSCALL(uptime)
 574:	b8 0e 00 00 00       	mov    $0xe,%eax
 579:	cd 40                	int    $0x40
 57b:	c3                   	ret

0000057c <getpinfo>:

SYSCALL(getpinfo)
 57c:	b8 16 00 00 00       	mov    $0x16,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret

00000584 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 584:	b8 17 00 00 00       	mov    $0x17,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret

0000058c <yield>:
SYSCALL(yield)
 58c:	b8 18 00 00 00       	mov    $0x18,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret

00000594 <getSchedPolicy>:
 594:	b8 19 00 00 00       	mov    $0x19,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret

0000059c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 59c:	f3 0f 1e fb          	endbr32
 5a0:	55                   	push   %ebp
 5a1:	89 e5                	mov    %esp,%ebp
 5a3:	83 ec 18             	sub    $0x18,%esp
 5a6:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5ac:	83 ec 04             	sub    $0x4,%esp
 5af:	6a 01                	push   $0x1
 5b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5b4:	50                   	push   %eax
 5b5:	ff 75 08             	push   0x8(%ebp)
 5b8:	e8 3f ff ff ff       	call   4fc <write>
 5bd:	83 c4 10             	add    $0x10,%esp
}
 5c0:	90                   	nop
 5c1:	c9                   	leave
 5c2:	c3                   	ret

000005c3 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5c3:	f3 0f 1e fb          	endbr32
 5c7:	55                   	push   %ebp
 5c8:	89 e5                	mov    %esp,%ebp
 5ca:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5cd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5d4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5d8:	74 17                	je     5f1 <printint+0x2e>
 5da:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5de:	79 11                	jns    5f1 <printint+0x2e>
    neg = 1;
 5e0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5e7:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ea:	f7 d8                	neg    %eax
 5ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5ef:	eb 06                	jmp    5f7 <printint+0x34>
  } else {
    x = xx;
 5f1:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
 601:	8b 45 ec             	mov    -0x14(%ebp),%eax
 604:	ba 00 00 00 00       	mov    $0x0,%edx
 609:	f7 f1                	div    %ecx
 60b:	89 d1                	mov    %edx,%ecx
 60d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 610:	8d 50 01             	lea    0x1(%eax),%edx
 613:	89 55 f4             	mov    %edx,-0xc(%ebp)
 616:	0f b6 91 e0 0d 00 00 	movzbl 0xde0(%ecx),%edx
 61d:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 621:	8b 4d 10             	mov    0x10(%ebp),%ecx
 624:	8b 45 ec             	mov    -0x14(%ebp),%eax
 627:	ba 00 00 00 00       	mov    $0x0,%edx
 62c:	f7 f1                	div    %ecx
 62e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 631:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 635:	75 c7                	jne    5fe <printint+0x3b>
  if(neg)
 637:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 63b:	74 2d                	je     66a <printint+0xa7>
    buf[i++] = '-';
 63d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 640:	8d 50 01             	lea    0x1(%eax),%edx
 643:	89 55 f4             	mov    %edx,-0xc(%ebp)
 646:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 64b:	eb 1d                	jmp    66a <printint+0xa7>
    putc(fd, buf[i]);
 64d:	8d 55 dc             	lea    -0x24(%ebp),%edx
 650:	8b 45 f4             	mov    -0xc(%ebp),%eax
 653:	01 d0                	add    %edx,%eax
 655:	0f b6 00             	movzbl (%eax),%eax
 658:	0f be c0             	movsbl %al,%eax
 65b:	83 ec 08             	sub    $0x8,%esp
 65e:	50                   	push   %eax
 65f:	ff 75 08             	push   0x8(%ebp)
 662:	e8 35 ff ff ff       	call   59c <putc>
 667:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 66a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 66e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 672:	79 d9                	jns    64d <printint+0x8a>
}
 674:	90                   	nop
 675:	90                   	nop
 676:	c9                   	leave
 677:	c3                   	ret

00000678 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 678:	f3 0f 1e fb          	endbr32
 67c:	55                   	push   %ebp
 67d:	89 e5                	mov    %esp,%ebp
 67f:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 682:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 689:	8d 45 0c             	lea    0xc(%ebp),%eax
 68c:	83 c0 04             	add    $0x4,%eax
 68f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 692:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 699:	e9 59 01 00 00       	jmp    7f7 <printf+0x17f>
    c = fmt[i] & 0xff;
 69e:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a4:	01 d0                	add    %edx,%eax
 6a6:	0f b6 00             	movzbl (%eax),%eax
 6a9:	0f be c0             	movsbl %al,%eax
 6ac:	25 ff 00 00 00       	and    $0xff,%eax
 6b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6b4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6b8:	75 2c                	jne    6e6 <printf+0x6e>
      if(c == '%'){
 6ba:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6be:	75 0c                	jne    6cc <printf+0x54>
        state = '%';
 6c0:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6c7:	e9 27 01 00 00       	jmp    7f3 <printf+0x17b>
      } else {
        putc(fd, c);
 6cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6cf:	0f be c0             	movsbl %al,%eax
 6d2:	83 ec 08             	sub    $0x8,%esp
 6d5:	50                   	push   %eax
 6d6:	ff 75 08             	push   0x8(%ebp)
 6d9:	e8 be fe ff ff       	call   59c <putc>
 6de:	83 c4 10             	add    $0x10,%esp
 6e1:	e9 0d 01 00 00       	jmp    7f3 <printf+0x17b>
      }
    } else if(state == '%'){
 6e6:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6ea:	0f 85 03 01 00 00    	jne    7f3 <printf+0x17b>
      if(c == 'd'){
 6f0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6f4:	75 1e                	jne    714 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 6f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f9:	8b 00                	mov    (%eax),%eax
 6fb:	6a 01                	push   $0x1
 6fd:	6a 0a                	push   $0xa
 6ff:	50                   	push   %eax
 700:	ff 75 08             	push   0x8(%ebp)
 703:	e8 bb fe ff ff       	call   5c3 <printint>
 708:	83 c4 10             	add    $0x10,%esp
        ap++;
 70b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 70f:	e9 d8 00 00 00       	jmp    7ec <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 714:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 718:	74 06                	je     720 <printf+0xa8>
 71a:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 71e:	75 1e                	jne    73e <printf+0xc6>
        printint(fd, *ap, 16, 0);
 720:	8b 45 e8             	mov    -0x18(%ebp),%eax
 723:	8b 00                	mov    (%eax),%eax
 725:	6a 00                	push   $0x0
 727:	6a 10                	push   $0x10
 729:	50                   	push   %eax
 72a:	ff 75 08             	push   0x8(%ebp)
 72d:	e8 91 fe ff ff       	call   5c3 <printint>
 732:	83 c4 10             	add    $0x10,%esp
        ap++;
 735:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 739:	e9 ae 00 00 00       	jmp    7ec <printf+0x174>
      } else if(c == 's'){
 73e:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 742:	75 43                	jne    787 <printf+0x10f>
        s = (char*)*ap;
 744:	8b 45 e8             	mov    -0x18(%ebp),%eax
 747:	8b 00                	mov    (%eax),%eax
 749:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 74c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 750:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 754:	75 25                	jne    77b <printf+0x103>
          s = "(null)";
 756:	c7 45 f4 22 0b 00 00 	movl   $0xb22,-0xc(%ebp)
        while(*s != 0){
 75d:	eb 1c                	jmp    77b <printf+0x103>
          putc(fd, *s);
 75f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 762:	0f b6 00             	movzbl (%eax),%eax
 765:	0f be c0             	movsbl %al,%eax
 768:	83 ec 08             	sub    $0x8,%esp
 76b:	50                   	push   %eax
 76c:	ff 75 08             	push   0x8(%ebp)
 76f:	e8 28 fe ff ff       	call   59c <putc>
 774:	83 c4 10             	add    $0x10,%esp
          s++;
 777:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 77b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77e:	0f b6 00             	movzbl (%eax),%eax
 781:	84 c0                	test   %al,%al
 783:	75 da                	jne    75f <printf+0xe7>
 785:	eb 65                	jmp    7ec <printf+0x174>
        }
      } else if(c == 'c'){
 787:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 78b:	75 1d                	jne    7aa <printf+0x132>
        putc(fd, *ap);
 78d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 790:	8b 00                	mov    (%eax),%eax
 792:	0f be c0             	movsbl %al,%eax
 795:	83 ec 08             	sub    $0x8,%esp
 798:	50                   	push   %eax
 799:	ff 75 08             	push   0x8(%ebp)
 79c:	e8 fb fd ff ff       	call   59c <putc>
 7a1:	83 c4 10             	add    $0x10,%esp
        ap++;
 7a4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7a8:	eb 42                	jmp    7ec <printf+0x174>
      } else if(c == '%'){
 7aa:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7ae:	75 17                	jne    7c7 <printf+0x14f>
        putc(fd, c);
 7b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b3:	0f be c0             	movsbl %al,%eax
 7b6:	83 ec 08             	sub    $0x8,%esp
 7b9:	50                   	push   %eax
 7ba:	ff 75 08             	push   0x8(%ebp)
 7bd:	e8 da fd ff ff       	call   59c <putc>
 7c2:	83 c4 10             	add    $0x10,%esp
 7c5:	eb 25                	jmp    7ec <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7c7:	83 ec 08             	sub    $0x8,%esp
 7ca:	6a 25                	push   $0x25
 7cc:	ff 75 08             	push   0x8(%ebp)
 7cf:	e8 c8 fd ff ff       	call   59c <putc>
 7d4:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7da:	0f be c0             	movsbl %al,%eax
 7dd:	83 ec 08             	sub    $0x8,%esp
 7e0:	50                   	push   %eax
 7e1:	ff 75 08             	push   0x8(%ebp)
 7e4:	e8 b3 fd ff ff       	call   59c <putc>
 7e9:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7ec:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 7f3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7f7:	8b 55 0c             	mov    0xc(%ebp),%edx
 7fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fd:	01 d0                	add    %edx,%eax
 7ff:	0f b6 00             	movzbl (%eax),%eax
 802:	84 c0                	test   %al,%al
 804:	0f 85 94 fe ff ff    	jne    69e <printf+0x26>
    }
  }
}
 80a:	90                   	nop
 80b:	90                   	nop
 80c:	c9                   	leave
 80d:	c3                   	ret

0000080e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 80e:	f3 0f 1e fb          	endbr32
 812:	55                   	push   %ebp
 813:	89 e5                	mov    %esp,%ebp
 815:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 818:	8b 45 08             	mov    0x8(%ebp),%eax
 81b:	83 e8 08             	sub    $0x8,%eax
 81e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 821:	a1 fc 0d 00 00       	mov    0xdfc,%eax
 826:	89 45 fc             	mov    %eax,-0x4(%ebp)
 829:	eb 24                	jmp    84f <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82e:	8b 00                	mov    (%eax),%eax
 830:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 833:	72 12                	jb     847 <free+0x39>
 835:	8b 45 f8             	mov    -0x8(%ebp),%eax
 838:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 83b:	77 24                	ja     861 <free+0x53>
 83d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 840:	8b 00                	mov    (%eax),%eax
 842:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 845:	72 1a                	jb     861 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 847:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84a:	8b 00                	mov    (%eax),%eax
 84c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 84f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 852:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 855:	76 d4                	jbe    82b <free+0x1d>
 857:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85a:	8b 00                	mov    (%eax),%eax
 85c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 85f:	73 ca                	jae    82b <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 861:	8b 45 f8             	mov    -0x8(%ebp),%eax
 864:	8b 40 04             	mov    0x4(%eax),%eax
 867:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 86e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 871:	01 c2                	add    %eax,%edx
 873:	8b 45 fc             	mov    -0x4(%ebp),%eax
 876:	8b 00                	mov    (%eax),%eax
 878:	39 c2                	cmp    %eax,%edx
 87a:	75 24                	jne    8a0 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 87c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87f:	8b 50 04             	mov    0x4(%eax),%edx
 882:	8b 45 fc             	mov    -0x4(%ebp),%eax
 885:	8b 00                	mov    (%eax),%eax
 887:	8b 40 04             	mov    0x4(%eax),%eax
 88a:	01 c2                	add    %eax,%edx
 88c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88f:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 892:	8b 45 fc             	mov    -0x4(%ebp),%eax
 895:	8b 00                	mov    (%eax),%eax
 897:	8b 10                	mov    (%eax),%edx
 899:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89c:	89 10                	mov    %edx,(%eax)
 89e:	eb 0a                	jmp    8aa <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 8a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a3:	8b 10                	mov    (%eax),%edx
 8a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a8:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ad:	8b 40 04             	mov    0x4(%eax),%eax
 8b0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ba:	01 d0                	add    %edx,%eax
 8bc:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8bf:	75 20                	jne    8e1 <free+0xd3>
    p->s.size += bp->s.size;
 8c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c4:	8b 50 04             	mov    0x4(%eax),%edx
 8c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ca:	8b 40 04             	mov    0x4(%eax),%eax
 8cd:	01 c2                	add    %eax,%edx
 8cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d8:	8b 10                	mov    (%eax),%edx
 8da:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8dd:	89 10                	mov    %edx,(%eax)
 8df:	eb 08                	jmp    8e9 <free+0xdb>
  } else
    p->s.ptr = bp;
 8e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8e7:	89 10                	mov    %edx,(%eax)
  freep = p;
 8e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ec:	a3 fc 0d 00 00       	mov    %eax,0xdfc
}
 8f1:	90                   	nop
 8f2:	c9                   	leave
 8f3:	c3                   	ret

000008f4 <morecore>:

static Header*
morecore(uint nu)
{
 8f4:	f3 0f 1e fb          	endbr32
 8f8:	55                   	push   %ebp
 8f9:	89 e5                	mov    %esp,%ebp
 8fb:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8fe:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 905:	77 07                	ja     90e <morecore+0x1a>
    nu = 4096;
 907:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 90e:	8b 45 08             	mov    0x8(%ebp),%eax
 911:	c1 e0 03             	shl    $0x3,%eax
 914:	83 ec 0c             	sub    $0xc,%esp
 917:	50                   	push   %eax
 918:	e8 47 fc ff ff       	call   564 <sbrk>
 91d:	83 c4 10             	add    $0x10,%esp
 920:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 923:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 927:	75 07                	jne    930 <morecore+0x3c>
    return 0;
 929:	b8 00 00 00 00       	mov    $0x0,%eax
 92e:	eb 26                	jmp    956 <morecore+0x62>
  hp = (Header*)p;
 930:	8b 45 f4             	mov    -0xc(%ebp),%eax
 933:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 936:	8b 45 f0             	mov    -0x10(%ebp),%eax
 939:	8b 55 08             	mov    0x8(%ebp),%edx
 93c:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 93f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 942:	83 c0 08             	add    $0x8,%eax
 945:	83 ec 0c             	sub    $0xc,%esp
 948:	50                   	push   %eax
 949:	e8 c0 fe ff ff       	call   80e <free>
 94e:	83 c4 10             	add    $0x10,%esp
  return freep;
 951:	a1 fc 0d 00 00       	mov    0xdfc,%eax
}
 956:	c9                   	leave
 957:	c3                   	ret

00000958 <malloc>:

void*
malloc(uint nbytes)
{
 958:	f3 0f 1e fb          	endbr32
 95c:	55                   	push   %ebp
 95d:	89 e5                	mov    %esp,%ebp
 95f:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 962:	8b 45 08             	mov    0x8(%ebp),%eax
 965:	83 c0 07             	add    $0x7,%eax
 968:	c1 e8 03             	shr    $0x3,%eax
 96b:	83 c0 01             	add    $0x1,%eax
 96e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 971:	a1 fc 0d 00 00       	mov    0xdfc,%eax
 976:	89 45 f0             	mov    %eax,-0x10(%ebp)
 979:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 97d:	75 23                	jne    9a2 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 97f:	c7 45 f0 f4 0d 00 00 	movl   $0xdf4,-0x10(%ebp)
 986:	8b 45 f0             	mov    -0x10(%ebp),%eax
 989:	a3 fc 0d 00 00       	mov    %eax,0xdfc
 98e:	a1 fc 0d 00 00       	mov    0xdfc,%eax
 993:	a3 f4 0d 00 00       	mov    %eax,0xdf4
    base.s.size = 0;
 998:	c7 05 f8 0d 00 00 00 	movl   $0x0,0xdf8
 99f:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a5:	8b 00                	mov    (%eax),%eax
 9a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ad:	8b 40 04             	mov    0x4(%eax),%eax
 9b0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9b3:	77 4d                	ja     a02 <malloc+0xaa>
      if(p->s.size == nunits)
 9b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b8:	8b 40 04             	mov    0x4(%eax),%eax
 9bb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9be:	75 0c                	jne    9cc <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 9c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c3:	8b 10                	mov    (%eax),%edx
 9c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c8:	89 10                	mov    %edx,(%eax)
 9ca:	eb 26                	jmp    9f2 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 9cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cf:	8b 40 04             	mov    0x4(%eax),%eax
 9d2:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9d5:	89 c2                	mov    %eax,%edx
 9d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9da:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e0:	8b 40 04             	mov    0x4(%eax),%eax
 9e3:	c1 e0 03             	shl    $0x3,%eax
 9e6:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ec:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9ef:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f5:	a3 fc 0d 00 00       	mov    %eax,0xdfc
      return (void*)(p + 1);
 9fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fd:	83 c0 08             	add    $0x8,%eax
 a00:	eb 3b                	jmp    a3d <malloc+0xe5>
    }
    if(p == freep)
 a02:	a1 fc 0d 00 00       	mov    0xdfc,%eax
 a07:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a0a:	75 1e                	jne    a2a <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 a0c:	83 ec 0c             	sub    $0xc,%esp
 a0f:	ff 75 ec             	push   -0x14(%ebp)
 a12:	e8 dd fe ff ff       	call   8f4 <morecore>
 a17:	83 c4 10             	add    $0x10,%esp
 a1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a21:	75 07                	jne    a2a <malloc+0xd2>
        return 0;
 a23:	b8 00 00 00 00       	mov    $0x0,%eax
 a28:	eb 13                	jmp    a3d <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a33:	8b 00                	mov    (%eax),%eax
 a35:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a38:	e9 6d ff ff ff       	jmp    9aa <malloc+0x52>
  }
}
 a3d:	c9                   	leave
 a3e:	c3                   	ret
