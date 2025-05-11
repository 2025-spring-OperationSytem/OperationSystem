
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
   7:	83 ec 18             	sub    $0x18,%esp
  int i, j = 0;
   a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for (i = 0; i < n; i++) {
  11:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  18:	eb 4c                	jmp    66 <workload+0x66>
    j += i * j + 1;
  1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1d:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  21:	83 c0 01             	add    $0x1,%eax
  24:	01 45 f0             	add    %eax,-0x10(%ebp)
    if (i % 1000000 == 0)
  27:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  2a:	ba 83 de 1b 43       	mov    $0x431bde83,%edx
  2f:	89 c8                	mov    %ecx,%eax
  31:	f7 ea                	imul   %edx
  33:	c1 fa 12             	sar    $0x12,%edx
  36:	89 c8                	mov    %ecx,%eax
  38:	c1 f8 1f             	sar    $0x1f,%eax
  3b:	29 c2                	sub    %eax,%edx
  3d:	89 d0                	mov    %edx,%eax
  3f:	69 c0 40 42 0f 00    	imul   $0xf4240,%eax,%eax
  45:	29 c1                	sub    %eax,%ecx
  47:	89 c8                	mov    %ecx,%eax
  49:	85 c0                	test   %eax,%eax
  4b:	75 15                	jne    62 <workload+0x62>
    {
      printf(1,"[WORRKLOAD] i = %d\n",i);
  4d:	83 ec 04             	sub    $0x4,%esp
  50:	ff 75 f4             	push   -0xc(%ebp)
  53:	68 cc 0a 00 00       	push   $0xacc
  58:	6a 01                	push   $0x1
  5a:	e8 a3 06 00 00       	call   702 <printf>
  5f:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < n; i++) {
  62:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  69:	3b 45 08             	cmp    0x8(%ebp),%eax
  6c:	7c ac                	jl     1a <workload+0x1a>
    }
  };
  return j;
  6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  71:	c9                   	leave
  72:	c3                   	ret

00000073 <print_stat>:

void print_stat() {
  73:	f3 0f 1e fb          	endbr32
  77:	55                   	push   %ebp
  78:	89 e5                	mov    %esp,%ebp
  7a:	57                   	push   %edi
  7b:	56                   	push   %esi
  7c:	53                   	push   %ebx
  7d:	81 ec 2c 0c 00 00    	sub    $0xc2c,%esp
  struct pstat ps;
  getpinfo(&ps);
  83:	83 ec 0c             	sub    $0xc,%esp
  86:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
  8c:	50                   	push   %eax
  8d:	e8 74 05 00 00       	call   606 <getpinfo>
  92:	83 c4 10             	add    $0x10,%esp
  printf(1, "\n[RESULT] Process Statistics\n");
  95:	83 ec 08             	sub    $0x8,%esp
  98:	68 e0 0a 00 00       	push   $0xae0
  9d:	6a 01                	push   $0x1
  9f:	e8 5e 06 00 00       	call   702 <printf>
  a4:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
  a7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  ae:	e9 0b 01 00 00       	jmp    1be <print_stat+0x14b>
    if (ps.inuse[i]) {
  b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  b6:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
  bd:	85 c0                	test   %eax,%eax
  bf:	0f 84 f5 00 00 00    	je     1ba <print_stat+0x147>
      printf(1, "PID %d | Priority %d | Ticks: [Q3:%d Q2:%d Q1:%d Q0:%d] | Wait: [Q3:%d Q2:%d Q1:%d Q0:%d]\n",
  c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  c8:	83 e8 80             	sub    $0xffffff80,%eax
  cb:	c1 e0 04             	shl    $0x4,%eax
  ce:	8d 55 e8             	lea    -0x18(%ebp),%edx
  d1:	01 d0                	add    %edx,%eax
  d3:	2d 04 0c 00 00       	sub    $0xc04,%eax
  d8:	8b 30                	mov    (%eax),%esi
  da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  dd:	c1 e0 04             	shl    $0x4,%eax
  e0:	8d 4d e8             	lea    -0x18(%ebp),%ecx
  e3:	01 c8                	add    %ecx,%eax
  e5:	2d 00 04 00 00       	sub    $0x400,%eax
  ea:	8b 38                	mov    (%eax),%edi
  ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  ef:	c1 e0 04             	shl    $0x4,%eax
  f2:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  f5:	01 d8                	add    %ebx,%eax
  f7:	2d fc 03 00 00       	sub    $0x3fc,%eax
  fc:	8b 00                	mov    (%eax),%eax
  fe:	89 85 d4 f3 ff ff    	mov    %eax,-0xc2c(%ebp)
 104:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 107:	c1 e0 04             	shl    $0x4,%eax
 10a:	8d 55 e8             	lea    -0x18(%ebp),%edx
 10d:	01 d0                	add    %edx,%eax
 10f:	2d f8 03 00 00       	sub    $0x3f8,%eax
 114:	8b 08                	mov    (%eax),%ecx
 116:	89 8d d0 f3 ff ff    	mov    %ecx,-0xc30(%ebp)
 11c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 11f:	83 c0 40             	add    $0x40,%eax
 122:	c1 e0 04             	shl    $0x4,%eax
 125:	8d 5d e8             	lea    -0x18(%ebp),%ebx
 128:	01 d8                	add    %ebx,%eax
 12a:	2d 04 0c 00 00       	sub    $0xc04,%eax
 12f:	8b 10                	mov    (%eax),%edx
 131:	89 95 cc f3 ff ff    	mov    %edx,-0xc34(%ebp)
 137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 13a:	c1 e0 04             	shl    $0x4,%eax
 13d:	8d 5d e8             	lea    -0x18(%ebp),%ebx
 140:	01 d8                	add    %ebx,%eax
 142:	2d 00 08 00 00       	sub    $0x800,%eax
 147:	8b 18                	mov    (%eax),%ebx
 149:	89 9d c8 f3 ff ff    	mov    %ebx,-0xc38(%ebp)
 14f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 152:	c1 e0 04             	shl    $0x4,%eax
 155:	8d 4d e8             	lea    -0x18(%ebp),%ecx
 158:	01 c8                	add    %ecx,%eax
 15a:	2d fc 07 00 00       	sub    $0x7fc,%eax
 15f:	8b 18                	mov    (%eax),%ebx
 161:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 164:	c1 e0 04             	shl    $0x4,%eax
 167:	8d 55 e8             	lea    -0x18(%ebp),%edx
 16a:	01 d0                	add    %edx,%eax
 16c:	2d f8 07 00 00       	sub    $0x7f8,%eax
 171:	8b 08                	mov    (%eax),%ecx
 173:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 176:	83 e8 80             	sub    $0xffffff80,%eax
 179:	8b 94 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%edx
 180:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 183:	83 c0 40             	add    $0x40,%eax
 186:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
 18d:	56                   	push   %esi
 18e:	57                   	push   %edi
 18f:	ff b5 d4 f3 ff ff    	push   -0xc2c(%ebp)
 195:	ff b5 d0 f3 ff ff    	push   -0xc30(%ebp)
 19b:	ff b5 cc f3 ff ff    	push   -0xc34(%ebp)
 1a1:	ff b5 c8 f3 ff ff    	push   -0xc38(%ebp)
 1a7:	53                   	push   %ebx
 1a8:	51                   	push   %ecx
 1a9:	52                   	push   %edx
 1aa:	50                   	push   %eax
 1ab:	68 00 0b 00 00       	push   $0xb00
 1b0:	6a 01                	push   $0x1
 1b2:	e8 4b 05 00 00       	call   702 <printf>
 1b7:	83 c4 30             	add    $0x30,%esp
  for (int i = 0; i < NPROC; i++) {
 1ba:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 1be:	83 7d e4 3f          	cmpl   $0x3f,-0x1c(%ebp)
 1c2:	0f 8e eb fe ff ff    	jle    b3 <print_stat+0x40>
        ps.pid[i], ps.priority[i],
        ps.ticks[i][3], ps.ticks[i][2], ps.ticks[i][1], ps.ticks[i][0],
        ps.wait_ticks[i][3], ps.wait_ticks[i][2], ps.wait_ticks[i][1], ps.wait_ticks[i][0]);
    }
  }
}
 1c8:	90                   	nop
 1c9:	90                   	nop
 1ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1cd:	5b                   	pop    %ebx
 1ce:	5e                   	pop    %esi
 1cf:	5f                   	pop    %edi
 1d0:	5d                   	pop    %ebp
 1d1:	c3                   	ret

000001d2 <run_policy_1>:

void run_policy_1() {
 1d2:	f3 0f 1e fb          	endbr32
 1d6:	55                   	push   %ebp
 1d7:	89 e5                	mov    %esp,%ebp
 1d9:	83 ec 18             	sub    $0x18,%esp
  printf(1, "[DEBUG] Entered run_policy_1()\n");
 1dc:	83 ec 08             	sub    $0x8,%esp
 1df:	68 5c 0b 00 00       	push   $0xb5c
 1e4:	6a 01                	push   $0x1
 1e6:	e8 17 05 00 00       	call   702 <printf>
 1eb:	83 c4 10             	add    $0x10,%esp
  sleep(1);  
 1ee:	83 ec 0c             	sub    $0xc,%esp
 1f1:	6a 01                	push   $0x1
 1f3:	e8 fe 03 00 00       	call   5f6 <sleep>
 1f8:	83 c4 10             	add    $0x10,%esp
  setSchedPolicy(1);
 1fb:	83 ec 0c             	sub    $0xc,%esp
 1fe:	6a 01                	push   $0x1
 200:	e8 09 04 00 00       	call   60e <setSchedPolicy>
 205:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROCS; i++) {
 208:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 20f:	eb 76                	jmp    287 <run_policy_1+0xb5>
    int pid = fork();
 211:	e8 48 03 00 00       	call   55e <fork>
 216:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid == 0) {
 219:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 21d:	75 42                	jne    261 <run_policy_1+0x8f>
      printf(1, "[CHILD] i=%d, PID=%d\n", i, getpid());
 21f:	e8 c2 03 00 00       	call   5e6 <getpid>
 224:	50                   	push   %eax
 225:	ff 75 f4             	push   -0xc(%ebp)
 228:	68 7c 0b 00 00       	push   $0xb7c
 22d:	6a 01                	push   $0x1
 22f:	e8 ce 04 00 00       	call   702 <printf>
 234:	83 c4 10             	add    $0x10,%esp
      sleep(1);
 237:	83 ec 0c             	sub    $0xc,%esp
 23a:	6a 01                	push   $0x1
 23c:	e8 b5 03 00 00       	call   5f6 <sleep>
 241:	83 c4 10             	add    $0x10,%esp
      workload(10000000 * (i + 1));
 244:	8b 45 f4             	mov    -0xc(%ebp),%eax
 247:	83 c0 01             	add    $0x1,%eax
 24a:	69 c0 80 96 98 00    	imul   $0x989680,%eax,%eax
 250:	83 ec 0c             	sub    $0xc,%esp
 253:	50                   	push   %eax
 254:	e8 a7 fd ff ff       	call   0 <workload>
 259:	83 c4 10             	add    $0x10,%esp
      exit();
 25c:	e8 05 03 00 00       	call   566 <exit>
    } else {
      printf(1, "[PARENT] forked child PID=%d at i=%d\n", pid, i);
 261:	ff 75 f4             	push   -0xc(%ebp)
 264:	ff 75 ec             	push   -0x14(%ebp)
 267:	68 94 0b 00 00       	push   $0xb94
 26c:	6a 01                	push   $0x1
 26e:	e8 8f 04 00 00       	call   702 <printf>
 273:	83 c4 10             	add    $0x10,%esp
      sleep(1);
 276:	83 ec 0c             	sub    $0xc,%esp
 279:	6a 01                	push   $0x1
 27b:	e8 76 03 00 00       	call   5f6 <sleep>
 280:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROCS; i++) {
 283:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 287:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
 28b:	7e 84                	jle    211 <run_policy_1+0x3f>
    }
  }
  sleep(1);
 28d:	83 ec 0c             	sub    $0xc,%esp
 290:	6a 01                	push   $0x1
 292:	e8 5f 03 00 00       	call   5f6 <sleep>
 297:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROCS; i++) wait();
 29a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 2a1:	eb 09                	jmp    2ac <run_policy_1+0xda>
 2a3:	e8 c6 02 00 00       	call   56e <wait>
 2a8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 2ac:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
 2b0:	7e f1                	jle    2a3 <run_policy_1+0xd1>
  print_stat();
 2b2:	e8 bc fd ff ff       	call   73 <print_stat>
}
 2b7:	90                   	nop
 2b8:	c9                   	leave
 2b9:	c3                   	ret

000002ba <main>:

int main(void) {
 2ba:	f3 0f 1e fb          	endbr32
 2be:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 2c2:	83 e4 f0             	and    $0xfffffff0,%esp
 2c5:	ff 71 fc             	push   -0x4(%ecx)
 2c8:	55                   	push   %ebp
 2c9:	89 e5                	mov    %esp,%ebp
 2cb:	51                   	push   %ecx
 2cc:	83 ec 04             	sub    $0x4,%esp
  printf(1, "\n===== [POLICY 1: tracking + boosting] =====\n");
 2cf:	83 ec 08             	sub    $0x8,%esp
 2d2:	68 bc 0b 00 00       	push   $0xbbc
 2d7:	6a 01                	push   $0x1
 2d9:	e8 24 04 00 00       	call   702 <printf>
 2de:	83 c4 10             	add    $0x10,%esp
  run_policy_1();
 2e1:	e8 ec fe ff ff       	call   1d2 <run_policy_1>
  exit();
 2e6:	e8 7b 02 00 00       	call   566 <exit>

000002eb <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2eb:	55                   	push   %ebp
 2ec:	89 e5                	mov    %esp,%ebp
 2ee:	57                   	push   %edi
 2ef:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2f3:	8b 55 10             	mov    0x10(%ebp),%edx
 2f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f9:	89 cb                	mov    %ecx,%ebx
 2fb:	89 df                	mov    %ebx,%edi
 2fd:	89 d1                	mov    %edx,%ecx
 2ff:	fc                   	cld
 300:	f3 aa                	rep stos %al,%es:(%edi)
 302:	89 ca                	mov    %ecx,%edx
 304:	89 fb                	mov    %edi,%ebx
 306:	89 5d 08             	mov    %ebx,0x8(%ebp)
 309:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 30c:	90                   	nop
 30d:	5b                   	pop    %ebx
 30e:	5f                   	pop    %edi
 30f:	5d                   	pop    %ebp
 310:	c3                   	ret

00000311 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 311:	f3 0f 1e fb          	endbr32
 315:	55                   	push   %ebp
 316:	89 e5                	mov    %esp,%ebp
 318:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 31b:	8b 45 08             	mov    0x8(%ebp),%eax
 31e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 321:	90                   	nop
 322:	8b 55 0c             	mov    0xc(%ebp),%edx
 325:	8d 42 01             	lea    0x1(%edx),%eax
 328:	89 45 0c             	mov    %eax,0xc(%ebp)
 32b:	8b 45 08             	mov    0x8(%ebp),%eax
 32e:	8d 48 01             	lea    0x1(%eax),%ecx
 331:	89 4d 08             	mov    %ecx,0x8(%ebp)
 334:	0f b6 12             	movzbl (%edx),%edx
 337:	88 10                	mov    %dl,(%eax)
 339:	0f b6 00             	movzbl (%eax),%eax
 33c:	84 c0                	test   %al,%al
 33e:	75 e2                	jne    322 <strcpy+0x11>
    ;
  return os;
 340:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 343:	c9                   	leave
 344:	c3                   	ret

00000345 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 345:	f3 0f 1e fb          	endbr32
 349:	55                   	push   %ebp
 34a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 34c:	eb 08                	jmp    356 <strcmp+0x11>
    p++, q++;
 34e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 352:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 356:	8b 45 08             	mov    0x8(%ebp),%eax
 359:	0f b6 00             	movzbl (%eax),%eax
 35c:	84 c0                	test   %al,%al
 35e:	74 10                	je     370 <strcmp+0x2b>
 360:	8b 45 08             	mov    0x8(%ebp),%eax
 363:	0f b6 10             	movzbl (%eax),%edx
 366:	8b 45 0c             	mov    0xc(%ebp),%eax
 369:	0f b6 00             	movzbl (%eax),%eax
 36c:	38 c2                	cmp    %al,%dl
 36e:	74 de                	je     34e <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 370:	8b 45 08             	mov    0x8(%ebp),%eax
 373:	0f b6 00             	movzbl (%eax),%eax
 376:	0f b6 d0             	movzbl %al,%edx
 379:	8b 45 0c             	mov    0xc(%ebp),%eax
 37c:	0f b6 00             	movzbl (%eax),%eax
 37f:	0f b6 c0             	movzbl %al,%eax
 382:	29 c2                	sub    %eax,%edx
 384:	89 d0                	mov    %edx,%eax
}
 386:	5d                   	pop    %ebp
 387:	c3                   	ret

00000388 <strlen>:

uint
strlen(char *s)
{
 388:	f3 0f 1e fb          	endbr32
 38c:	55                   	push   %ebp
 38d:	89 e5                	mov    %esp,%ebp
 38f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 392:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 399:	eb 04                	jmp    39f <strlen+0x17>
 39b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 39f:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3a2:	8b 45 08             	mov    0x8(%ebp),%eax
 3a5:	01 d0                	add    %edx,%eax
 3a7:	0f b6 00             	movzbl (%eax),%eax
 3aa:	84 c0                	test   %al,%al
 3ac:	75 ed                	jne    39b <strlen+0x13>
    ;
  return n;
 3ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3b1:	c9                   	leave
 3b2:	c3                   	ret

000003b3 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3b3:	f3 0f 1e fb          	endbr32
 3b7:	55                   	push   %ebp
 3b8:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3ba:	8b 45 10             	mov    0x10(%ebp),%eax
 3bd:	50                   	push   %eax
 3be:	ff 75 0c             	push   0xc(%ebp)
 3c1:	ff 75 08             	push   0x8(%ebp)
 3c4:	e8 22 ff ff ff       	call   2eb <stosb>
 3c9:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3cc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3cf:	c9                   	leave
 3d0:	c3                   	ret

000003d1 <strchr>:

char*
strchr(const char *s, char c)
{
 3d1:	f3 0f 1e fb          	endbr32
 3d5:	55                   	push   %ebp
 3d6:	89 e5                	mov    %esp,%ebp
 3d8:	83 ec 04             	sub    $0x4,%esp
 3db:	8b 45 0c             	mov    0xc(%ebp),%eax
 3de:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3e1:	eb 14                	jmp    3f7 <strchr+0x26>
    if(*s == c)
 3e3:	8b 45 08             	mov    0x8(%ebp),%eax
 3e6:	0f b6 00             	movzbl (%eax),%eax
 3e9:	38 45 fc             	cmp    %al,-0x4(%ebp)
 3ec:	75 05                	jne    3f3 <strchr+0x22>
      return (char*)s;
 3ee:	8b 45 08             	mov    0x8(%ebp),%eax
 3f1:	eb 13                	jmp    406 <strchr+0x35>
  for(; *s; s++)
 3f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3f7:	8b 45 08             	mov    0x8(%ebp),%eax
 3fa:	0f b6 00             	movzbl (%eax),%eax
 3fd:	84 c0                	test   %al,%al
 3ff:	75 e2                	jne    3e3 <strchr+0x12>
  return 0;
 401:	b8 00 00 00 00       	mov    $0x0,%eax
}
 406:	c9                   	leave
 407:	c3                   	ret

00000408 <gets>:

char*
gets(char *buf, int max)
{
 408:	f3 0f 1e fb          	endbr32
 40c:	55                   	push   %ebp
 40d:	89 e5                	mov    %esp,%ebp
 40f:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 412:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 419:	eb 42                	jmp    45d <gets+0x55>
    cc = read(0, &c, 1);
 41b:	83 ec 04             	sub    $0x4,%esp
 41e:	6a 01                	push   $0x1
 420:	8d 45 ef             	lea    -0x11(%ebp),%eax
 423:	50                   	push   %eax
 424:	6a 00                	push   $0x0
 426:	e8 53 01 00 00       	call   57e <read>
 42b:	83 c4 10             	add    $0x10,%esp
 42e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 431:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 435:	7e 33                	jle    46a <gets+0x62>
      break;
    buf[i++] = c;
 437:	8b 45 f4             	mov    -0xc(%ebp),%eax
 43a:	8d 50 01             	lea    0x1(%eax),%edx
 43d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 440:	89 c2                	mov    %eax,%edx
 442:	8b 45 08             	mov    0x8(%ebp),%eax
 445:	01 c2                	add    %eax,%edx
 447:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 44b:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 44d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 451:	3c 0a                	cmp    $0xa,%al
 453:	74 16                	je     46b <gets+0x63>
 455:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 459:	3c 0d                	cmp    $0xd,%al
 45b:	74 0e                	je     46b <gets+0x63>
  for(i=0; i+1 < max; ){
 45d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 460:	83 c0 01             	add    $0x1,%eax
 463:	39 45 0c             	cmp    %eax,0xc(%ebp)
 466:	7f b3                	jg     41b <gets+0x13>
 468:	eb 01                	jmp    46b <gets+0x63>
      break;
 46a:	90                   	nop
      break;
  }
  buf[i] = '\0';
 46b:	8b 55 f4             	mov    -0xc(%ebp),%edx
 46e:	8b 45 08             	mov    0x8(%ebp),%eax
 471:	01 d0                	add    %edx,%eax
 473:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 476:	8b 45 08             	mov    0x8(%ebp),%eax
}
 479:	c9                   	leave
 47a:	c3                   	ret

0000047b <stat>:

int
stat(char *n, struct stat *st)
{
 47b:	f3 0f 1e fb          	endbr32
 47f:	55                   	push   %ebp
 480:	89 e5                	mov    %esp,%ebp
 482:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 485:	83 ec 08             	sub    $0x8,%esp
 488:	6a 00                	push   $0x0
 48a:	ff 75 08             	push   0x8(%ebp)
 48d:	e8 14 01 00 00       	call   5a6 <open>
 492:	83 c4 10             	add    $0x10,%esp
 495:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 498:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 49c:	79 07                	jns    4a5 <stat+0x2a>
    return -1;
 49e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4a3:	eb 25                	jmp    4ca <stat+0x4f>
  r = fstat(fd, st);
 4a5:	83 ec 08             	sub    $0x8,%esp
 4a8:	ff 75 0c             	push   0xc(%ebp)
 4ab:	ff 75 f4             	push   -0xc(%ebp)
 4ae:	e8 0b 01 00 00       	call   5be <fstat>
 4b3:	83 c4 10             	add    $0x10,%esp
 4b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4b9:	83 ec 0c             	sub    $0xc,%esp
 4bc:	ff 75 f4             	push   -0xc(%ebp)
 4bf:	e8 ca 00 00 00       	call   58e <close>
 4c4:	83 c4 10             	add    $0x10,%esp
  return r;
 4c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4ca:	c9                   	leave
 4cb:	c3                   	ret

000004cc <atoi>:

int
atoi(const char *s)
{
 4cc:	f3 0f 1e fb          	endbr32
 4d0:	55                   	push   %ebp
 4d1:	89 e5                	mov    %esp,%ebp
 4d3:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4d6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4dd:	eb 25                	jmp    504 <atoi+0x38>
    n = n*10 + *s++ - '0';
 4df:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4e2:	89 d0                	mov    %edx,%eax
 4e4:	c1 e0 02             	shl    $0x2,%eax
 4e7:	01 d0                	add    %edx,%eax
 4e9:	01 c0                	add    %eax,%eax
 4eb:	89 c1                	mov    %eax,%ecx
 4ed:	8b 45 08             	mov    0x8(%ebp),%eax
 4f0:	8d 50 01             	lea    0x1(%eax),%edx
 4f3:	89 55 08             	mov    %edx,0x8(%ebp)
 4f6:	0f b6 00             	movzbl (%eax),%eax
 4f9:	0f be c0             	movsbl %al,%eax
 4fc:	01 c8                	add    %ecx,%eax
 4fe:	83 e8 30             	sub    $0x30,%eax
 501:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 504:	8b 45 08             	mov    0x8(%ebp),%eax
 507:	0f b6 00             	movzbl (%eax),%eax
 50a:	3c 2f                	cmp    $0x2f,%al
 50c:	7e 0a                	jle    518 <atoi+0x4c>
 50e:	8b 45 08             	mov    0x8(%ebp),%eax
 511:	0f b6 00             	movzbl (%eax),%eax
 514:	3c 39                	cmp    $0x39,%al
 516:	7e c7                	jle    4df <atoi+0x13>
  return n;
 518:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 51b:	c9                   	leave
 51c:	c3                   	ret

0000051d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 51d:	f3 0f 1e fb          	endbr32
 521:	55                   	push   %ebp
 522:	89 e5                	mov    %esp,%ebp
 524:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 527:	8b 45 08             	mov    0x8(%ebp),%eax
 52a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 52d:	8b 45 0c             	mov    0xc(%ebp),%eax
 530:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 533:	eb 17                	jmp    54c <memmove+0x2f>
    *dst++ = *src++;
 535:	8b 55 f8             	mov    -0x8(%ebp),%edx
 538:	8d 42 01             	lea    0x1(%edx),%eax
 53b:	89 45 f8             	mov    %eax,-0x8(%ebp)
 53e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 541:	8d 48 01             	lea    0x1(%eax),%ecx
 544:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 547:	0f b6 12             	movzbl (%edx),%edx
 54a:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 54c:	8b 45 10             	mov    0x10(%ebp),%eax
 54f:	8d 50 ff             	lea    -0x1(%eax),%edx
 552:	89 55 10             	mov    %edx,0x10(%ebp)
 555:	85 c0                	test   %eax,%eax
 557:	7f dc                	jg     535 <memmove+0x18>
  return vdst;
 559:	8b 45 08             	mov    0x8(%ebp),%eax
}
 55c:	c9                   	leave
 55d:	c3                   	ret

0000055e <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 55e:	b8 01 00 00 00       	mov    $0x1,%eax
 563:	cd 40                	int    $0x40
 565:	c3                   	ret

00000566 <exit>:
SYSCALL(exit)
 566:	b8 02 00 00 00       	mov    $0x2,%eax
 56b:	cd 40                	int    $0x40
 56d:	c3                   	ret

0000056e <wait>:
SYSCALL(wait)
 56e:	b8 03 00 00 00       	mov    $0x3,%eax
 573:	cd 40                	int    $0x40
 575:	c3                   	ret

00000576 <pipe>:
SYSCALL(pipe)
 576:	b8 04 00 00 00       	mov    $0x4,%eax
 57b:	cd 40                	int    $0x40
 57d:	c3                   	ret

0000057e <read>:
SYSCALL(read)
 57e:	b8 05 00 00 00       	mov    $0x5,%eax
 583:	cd 40                	int    $0x40
 585:	c3                   	ret

00000586 <write>:
SYSCALL(write)
 586:	b8 10 00 00 00       	mov    $0x10,%eax
 58b:	cd 40                	int    $0x40
 58d:	c3                   	ret

0000058e <close>:
SYSCALL(close)
 58e:	b8 15 00 00 00       	mov    $0x15,%eax
 593:	cd 40                	int    $0x40
 595:	c3                   	ret

00000596 <kill>:
SYSCALL(kill)
 596:	b8 06 00 00 00       	mov    $0x6,%eax
 59b:	cd 40                	int    $0x40
 59d:	c3                   	ret

0000059e <exec>:
SYSCALL(exec)
 59e:	b8 07 00 00 00       	mov    $0x7,%eax
 5a3:	cd 40                	int    $0x40
 5a5:	c3                   	ret

000005a6 <open>:
SYSCALL(open)
 5a6:	b8 0f 00 00 00       	mov    $0xf,%eax
 5ab:	cd 40                	int    $0x40
 5ad:	c3                   	ret

000005ae <mknod>:
SYSCALL(mknod)
 5ae:	b8 11 00 00 00       	mov    $0x11,%eax
 5b3:	cd 40                	int    $0x40
 5b5:	c3                   	ret

000005b6 <unlink>:
SYSCALL(unlink)
 5b6:	b8 12 00 00 00       	mov    $0x12,%eax
 5bb:	cd 40                	int    $0x40
 5bd:	c3                   	ret

000005be <fstat>:
SYSCALL(fstat)
 5be:	b8 08 00 00 00       	mov    $0x8,%eax
 5c3:	cd 40                	int    $0x40
 5c5:	c3                   	ret

000005c6 <link>:
SYSCALL(link)
 5c6:	b8 13 00 00 00       	mov    $0x13,%eax
 5cb:	cd 40                	int    $0x40
 5cd:	c3                   	ret

000005ce <mkdir>:
SYSCALL(mkdir)
 5ce:	b8 14 00 00 00       	mov    $0x14,%eax
 5d3:	cd 40                	int    $0x40
 5d5:	c3                   	ret

000005d6 <chdir>:
SYSCALL(chdir)
 5d6:	b8 09 00 00 00       	mov    $0x9,%eax
 5db:	cd 40                	int    $0x40
 5dd:	c3                   	ret

000005de <dup>:
SYSCALL(dup)
 5de:	b8 0a 00 00 00       	mov    $0xa,%eax
 5e3:	cd 40                	int    $0x40
 5e5:	c3                   	ret

000005e6 <getpid>:
SYSCALL(getpid)
 5e6:	b8 0b 00 00 00       	mov    $0xb,%eax
 5eb:	cd 40                	int    $0x40
 5ed:	c3                   	ret

000005ee <sbrk>:
SYSCALL(sbrk)
 5ee:	b8 0c 00 00 00       	mov    $0xc,%eax
 5f3:	cd 40                	int    $0x40
 5f5:	c3                   	ret

000005f6 <sleep>:
SYSCALL(sleep)
 5f6:	b8 0d 00 00 00       	mov    $0xd,%eax
 5fb:	cd 40                	int    $0x40
 5fd:	c3                   	ret

000005fe <uptime>:
SYSCALL(uptime)
 5fe:	b8 0e 00 00 00       	mov    $0xe,%eax
 603:	cd 40                	int    $0x40
 605:	c3                   	ret

00000606 <getpinfo>:

SYSCALL(getpinfo)
 606:	b8 16 00 00 00       	mov    $0x16,%eax
 60b:	cd 40                	int    $0x40
 60d:	c3                   	ret

0000060e <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 60e:	b8 17 00 00 00       	mov    $0x17,%eax
 613:	cd 40                	int    $0x40
 615:	c3                   	ret

00000616 <yield>:
SYSCALL(yield)
 616:	b8 18 00 00 00       	mov    $0x18,%eax
 61b:	cd 40                	int    $0x40
 61d:	c3                   	ret

0000061e <getSchedPolicy>:
 61e:	b8 19 00 00 00       	mov    $0x19,%eax
 623:	cd 40                	int    $0x40
 625:	c3                   	ret

00000626 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 626:	f3 0f 1e fb          	endbr32
 62a:	55                   	push   %ebp
 62b:	89 e5                	mov    %esp,%ebp
 62d:	83 ec 18             	sub    $0x18,%esp
 630:	8b 45 0c             	mov    0xc(%ebp),%eax
 633:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 636:	83 ec 04             	sub    $0x4,%esp
 639:	6a 01                	push   $0x1
 63b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 63e:	50                   	push   %eax
 63f:	ff 75 08             	push   0x8(%ebp)
 642:	e8 3f ff ff ff       	call   586 <write>
 647:	83 c4 10             	add    $0x10,%esp
}
 64a:	90                   	nop
 64b:	c9                   	leave
 64c:	c3                   	ret

0000064d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 64d:	f3 0f 1e fb          	endbr32
 651:	55                   	push   %ebp
 652:	89 e5                	mov    %esp,%ebp
 654:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 657:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 65e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 662:	74 17                	je     67b <printint+0x2e>
 664:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 668:	79 11                	jns    67b <printint+0x2e>
    neg = 1;
 66a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 671:	8b 45 0c             	mov    0xc(%ebp),%eax
 674:	f7 d8                	neg    %eax
 676:	89 45 ec             	mov    %eax,-0x14(%ebp)
 679:	eb 06                	jmp    681 <printint+0x34>
  } else {
    x = xx;
 67b:	8b 45 0c             	mov    0xc(%ebp),%eax
 67e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 681:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 688:	8b 4d 10             	mov    0x10(%ebp),%ecx
 68b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 68e:	ba 00 00 00 00       	mov    $0x0,%edx
 693:	f7 f1                	div    %ecx
 695:	89 d1                	mov    %edx,%ecx
 697:	8b 45 f4             	mov    -0xc(%ebp),%eax
 69a:	8d 50 01             	lea    0x1(%eax),%edx
 69d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6a0:	0f b6 91 a8 0e 00 00 	movzbl 0xea8(%ecx),%edx
 6a7:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6b1:	ba 00 00 00 00       	mov    $0x0,%edx
 6b6:	f7 f1                	div    %ecx
 6b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6bb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6bf:	75 c7                	jne    688 <printint+0x3b>
  if(neg)
 6c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6c5:	74 2d                	je     6f4 <printint+0xa7>
    buf[i++] = '-';
 6c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ca:	8d 50 01             	lea    0x1(%eax),%edx
 6cd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6d0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6d5:	eb 1d                	jmp    6f4 <printint+0xa7>
    putc(fd, buf[i]);
 6d7:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6dd:	01 d0                	add    %edx,%eax
 6df:	0f b6 00             	movzbl (%eax),%eax
 6e2:	0f be c0             	movsbl %al,%eax
 6e5:	83 ec 08             	sub    $0x8,%esp
 6e8:	50                   	push   %eax
 6e9:	ff 75 08             	push   0x8(%ebp)
 6ec:	e8 35 ff ff ff       	call   626 <putc>
 6f1:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6f4:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6fc:	79 d9                	jns    6d7 <printint+0x8a>
}
 6fe:	90                   	nop
 6ff:	90                   	nop
 700:	c9                   	leave
 701:	c3                   	ret

00000702 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 702:	f3 0f 1e fb          	endbr32
 706:	55                   	push   %ebp
 707:	89 e5                	mov    %esp,%ebp
 709:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 70c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 713:	8d 45 0c             	lea    0xc(%ebp),%eax
 716:	83 c0 04             	add    $0x4,%eax
 719:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 71c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 723:	e9 59 01 00 00       	jmp    881 <printf+0x17f>
    c = fmt[i] & 0xff;
 728:	8b 55 0c             	mov    0xc(%ebp),%edx
 72b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 72e:	01 d0                	add    %edx,%eax
 730:	0f b6 00             	movzbl (%eax),%eax
 733:	0f be c0             	movsbl %al,%eax
 736:	25 ff 00 00 00       	and    $0xff,%eax
 73b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 73e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 742:	75 2c                	jne    770 <printf+0x6e>
      if(c == '%'){
 744:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 748:	75 0c                	jne    756 <printf+0x54>
        state = '%';
 74a:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 751:	e9 27 01 00 00       	jmp    87d <printf+0x17b>
      } else {
        putc(fd, c);
 756:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 759:	0f be c0             	movsbl %al,%eax
 75c:	83 ec 08             	sub    $0x8,%esp
 75f:	50                   	push   %eax
 760:	ff 75 08             	push   0x8(%ebp)
 763:	e8 be fe ff ff       	call   626 <putc>
 768:	83 c4 10             	add    $0x10,%esp
 76b:	e9 0d 01 00 00       	jmp    87d <printf+0x17b>
      }
    } else if(state == '%'){
 770:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 774:	0f 85 03 01 00 00    	jne    87d <printf+0x17b>
      if(c == 'd'){
 77a:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 77e:	75 1e                	jne    79e <printf+0x9c>
        printint(fd, *ap, 10, 1);
 780:	8b 45 e8             	mov    -0x18(%ebp),%eax
 783:	8b 00                	mov    (%eax),%eax
 785:	6a 01                	push   $0x1
 787:	6a 0a                	push   $0xa
 789:	50                   	push   %eax
 78a:	ff 75 08             	push   0x8(%ebp)
 78d:	e8 bb fe ff ff       	call   64d <printint>
 792:	83 c4 10             	add    $0x10,%esp
        ap++;
 795:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 799:	e9 d8 00 00 00       	jmp    876 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 79e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7a2:	74 06                	je     7aa <printf+0xa8>
 7a4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7a8:	75 1e                	jne    7c8 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 7aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ad:	8b 00                	mov    (%eax),%eax
 7af:	6a 00                	push   $0x0
 7b1:	6a 10                	push   $0x10
 7b3:	50                   	push   %eax
 7b4:	ff 75 08             	push   0x8(%ebp)
 7b7:	e8 91 fe ff ff       	call   64d <printint>
 7bc:	83 c4 10             	add    $0x10,%esp
        ap++;
 7bf:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7c3:	e9 ae 00 00 00       	jmp    876 <printf+0x174>
      } else if(c == 's'){
 7c8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7cc:	75 43                	jne    811 <printf+0x10f>
        s = (char*)*ap;
 7ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d1:	8b 00                	mov    (%eax),%eax
 7d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7d6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7de:	75 25                	jne    805 <printf+0x103>
          s = "(null)";
 7e0:	c7 45 f4 ea 0b 00 00 	movl   $0xbea,-0xc(%ebp)
        while(*s != 0){
 7e7:	eb 1c                	jmp    805 <printf+0x103>
          putc(fd, *s);
 7e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ec:	0f b6 00             	movzbl (%eax),%eax
 7ef:	0f be c0             	movsbl %al,%eax
 7f2:	83 ec 08             	sub    $0x8,%esp
 7f5:	50                   	push   %eax
 7f6:	ff 75 08             	push   0x8(%ebp)
 7f9:	e8 28 fe ff ff       	call   626 <putc>
 7fe:	83 c4 10             	add    $0x10,%esp
          s++;
 801:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 805:	8b 45 f4             	mov    -0xc(%ebp),%eax
 808:	0f b6 00             	movzbl (%eax),%eax
 80b:	84 c0                	test   %al,%al
 80d:	75 da                	jne    7e9 <printf+0xe7>
 80f:	eb 65                	jmp    876 <printf+0x174>
        }
      } else if(c == 'c'){
 811:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 815:	75 1d                	jne    834 <printf+0x132>
        putc(fd, *ap);
 817:	8b 45 e8             	mov    -0x18(%ebp),%eax
 81a:	8b 00                	mov    (%eax),%eax
 81c:	0f be c0             	movsbl %al,%eax
 81f:	83 ec 08             	sub    $0x8,%esp
 822:	50                   	push   %eax
 823:	ff 75 08             	push   0x8(%ebp)
 826:	e8 fb fd ff ff       	call   626 <putc>
 82b:	83 c4 10             	add    $0x10,%esp
        ap++;
 82e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 832:	eb 42                	jmp    876 <printf+0x174>
      } else if(c == '%'){
 834:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 838:	75 17                	jne    851 <printf+0x14f>
        putc(fd, c);
 83a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 83d:	0f be c0             	movsbl %al,%eax
 840:	83 ec 08             	sub    $0x8,%esp
 843:	50                   	push   %eax
 844:	ff 75 08             	push   0x8(%ebp)
 847:	e8 da fd ff ff       	call   626 <putc>
 84c:	83 c4 10             	add    $0x10,%esp
 84f:	eb 25                	jmp    876 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 851:	83 ec 08             	sub    $0x8,%esp
 854:	6a 25                	push   $0x25
 856:	ff 75 08             	push   0x8(%ebp)
 859:	e8 c8 fd ff ff       	call   626 <putc>
 85e:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 861:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 864:	0f be c0             	movsbl %al,%eax
 867:	83 ec 08             	sub    $0x8,%esp
 86a:	50                   	push   %eax
 86b:	ff 75 08             	push   0x8(%ebp)
 86e:	e8 b3 fd ff ff       	call   626 <putc>
 873:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 876:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 87d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 881:	8b 55 0c             	mov    0xc(%ebp),%edx
 884:	8b 45 f0             	mov    -0x10(%ebp),%eax
 887:	01 d0                	add    %edx,%eax
 889:	0f b6 00             	movzbl (%eax),%eax
 88c:	84 c0                	test   %al,%al
 88e:	0f 85 94 fe ff ff    	jne    728 <printf+0x26>
    }
  }
}
 894:	90                   	nop
 895:	90                   	nop
 896:	c9                   	leave
 897:	c3                   	ret

00000898 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 898:	f3 0f 1e fb          	endbr32
 89c:	55                   	push   %ebp
 89d:	89 e5                	mov    %esp,%ebp
 89f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8a2:	8b 45 08             	mov    0x8(%ebp),%eax
 8a5:	83 e8 08             	sub    $0x8,%eax
 8a8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ab:	a1 c4 0e 00 00       	mov    0xec4,%eax
 8b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8b3:	eb 24                	jmp    8d9 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b8:	8b 00                	mov    (%eax),%eax
 8ba:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8bd:	72 12                	jb     8d1 <free+0x39>
 8bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8c5:	77 24                	ja     8eb <free+0x53>
 8c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ca:	8b 00                	mov    (%eax),%eax
 8cc:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8cf:	72 1a                	jb     8eb <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d4:	8b 00                	mov    (%eax),%eax
 8d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8dc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8df:	76 d4                	jbe    8b5 <free+0x1d>
 8e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e4:	8b 00                	mov    (%eax),%eax
 8e6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8e9:	73 ca                	jae    8b5 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ee:	8b 40 04             	mov    0x4(%eax),%eax
 8f1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fb:	01 c2                	add    %eax,%edx
 8fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 900:	8b 00                	mov    (%eax),%eax
 902:	39 c2                	cmp    %eax,%edx
 904:	75 24                	jne    92a <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 906:	8b 45 f8             	mov    -0x8(%ebp),%eax
 909:	8b 50 04             	mov    0x4(%eax),%edx
 90c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90f:	8b 00                	mov    (%eax),%eax
 911:	8b 40 04             	mov    0x4(%eax),%eax
 914:	01 c2                	add    %eax,%edx
 916:	8b 45 f8             	mov    -0x8(%ebp),%eax
 919:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 91c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91f:	8b 00                	mov    (%eax),%eax
 921:	8b 10                	mov    (%eax),%edx
 923:	8b 45 f8             	mov    -0x8(%ebp),%eax
 926:	89 10                	mov    %edx,(%eax)
 928:	eb 0a                	jmp    934 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 92a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92d:	8b 10                	mov    (%eax),%edx
 92f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 932:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 934:	8b 45 fc             	mov    -0x4(%ebp),%eax
 937:	8b 40 04             	mov    0x4(%eax),%eax
 93a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 941:	8b 45 fc             	mov    -0x4(%ebp),%eax
 944:	01 d0                	add    %edx,%eax
 946:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 949:	75 20                	jne    96b <free+0xd3>
    p->s.size += bp->s.size;
 94b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94e:	8b 50 04             	mov    0x4(%eax),%edx
 951:	8b 45 f8             	mov    -0x8(%ebp),%eax
 954:	8b 40 04             	mov    0x4(%eax),%eax
 957:	01 c2                	add    %eax,%edx
 959:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 95f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 962:	8b 10                	mov    (%eax),%edx
 964:	8b 45 fc             	mov    -0x4(%ebp),%eax
 967:	89 10                	mov    %edx,(%eax)
 969:	eb 08                	jmp    973 <free+0xdb>
  } else
    p->s.ptr = bp;
 96b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 971:	89 10                	mov    %edx,(%eax)
  freep = p;
 973:	8b 45 fc             	mov    -0x4(%ebp),%eax
 976:	a3 c4 0e 00 00       	mov    %eax,0xec4
}
 97b:	90                   	nop
 97c:	c9                   	leave
 97d:	c3                   	ret

0000097e <morecore>:

static Header*
morecore(uint nu)
{
 97e:	f3 0f 1e fb          	endbr32
 982:	55                   	push   %ebp
 983:	89 e5                	mov    %esp,%ebp
 985:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 988:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 98f:	77 07                	ja     998 <morecore+0x1a>
    nu = 4096;
 991:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 998:	8b 45 08             	mov    0x8(%ebp),%eax
 99b:	c1 e0 03             	shl    $0x3,%eax
 99e:	83 ec 0c             	sub    $0xc,%esp
 9a1:	50                   	push   %eax
 9a2:	e8 47 fc ff ff       	call   5ee <sbrk>
 9a7:	83 c4 10             	add    $0x10,%esp
 9aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9ad:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9b1:	75 07                	jne    9ba <morecore+0x3c>
    return 0;
 9b3:	b8 00 00 00 00       	mov    $0x0,%eax
 9b8:	eb 26                	jmp    9e0 <morecore+0x62>
  hp = (Header*)p;
 9ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c3:	8b 55 08             	mov    0x8(%ebp),%edx
 9c6:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9cc:	83 c0 08             	add    $0x8,%eax
 9cf:	83 ec 0c             	sub    $0xc,%esp
 9d2:	50                   	push   %eax
 9d3:	e8 c0 fe ff ff       	call   898 <free>
 9d8:	83 c4 10             	add    $0x10,%esp
  return freep;
 9db:	a1 c4 0e 00 00       	mov    0xec4,%eax
}
 9e0:	c9                   	leave
 9e1:	c3                   	ret

000009e2 <malloc>:

void*
malloc(uint nbytes)
{
 9e2:	f3 0f 1e fb          	endbr32
 9e6:	55                   	push   %ebp
 9e7:	89 e5                	mov    %esp,%ebp
 9e9:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9ec:	8b 45 08             	mov    0x8(%ebp),%eax
 9ef:	83 c0 07             	add    $0x7,%eax
 9f2:	c1 e8 03             	shr    $0x3,%eax
 9f5:	83 c0 01             	add    $0x1,%eax
 9f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9fb:	a1 c4 0e 00 00       	mov    0xec4,%eax
 a00:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a03:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a07:	75 23                	jne    a2c <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 a09:	c7 45 f0 bc 0e 00 00 	movl   $0xebc,-0x10(%ebp)
 a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a13:	a3 c4 0e 00 00       	mov    %eax,0xec4
 a18:	a1 c4 0e 00 00       	mov    0xec4,%eax
 a1d:	a3 bc 0e 00 00       	mov    %eax,0xebc
    base.s.size = 0;
 a22:	c7 05 c0 0e 00 00 00 	movl   $0x0,0xec0
 a29:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2f:	8b 00                	mov    (%eax),%eax
 a31:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a37:	8b 40 04             	mov    0x4(%eax),%eax
 a3a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a3d:	77 4d                	ja     a8c <malloc+0xaa>
      if(p->s.size == nunits)
 a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a42:	8b 40 04             	mov    0x4(%eax),%eax
 a45:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a48:	75 0c                	jne    a56 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4d:	8b 10                	mov    (%eax),%edx
 a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a52:	89 10                	mov    %edx,(%eax)
 a54:	eb 26                	jmp    a7c <malloc+0x9a>
      else {
        p->s.size -= nunits;
 a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a59:	8b 40 04             	mov    0x4(%eax),%eax
 a5c:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a5f:	89 c2                	mov    %eax,%edx
 a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a64:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6a:	8b 40 04             	mov    0x4(%eax),%eax
 a6d:	c1 e0 03             	shl    $0x3,%eax
 a70:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a76:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a79:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a7f:	a3 c4 0e 00 00       	mov    %eax,0xec4
      return (void*)(p + 1);
 a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a87:	83 c0 08             	add    $0x8,%eax
 a8a:	eb 3b                	jmp    ac7 <malloc+0xe5>
    }
    if(p == freep)
 a8c:	a1 c4 0e 00 00       	mov    0xec4,%eax
 a91:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a94:	75 1e                	jne    ab4 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 a96:	83 ec 0c             	sub    $0xc,%esp
 a99:	ff 75 ec             	push   -0x14(%ebp)
 a9c:	e8 dd fe ff ff       	call   97e <morecore>
 aa1:	83 c4 10             	add    $0x10,%esp
 aa4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 aa7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 aab:	75 07                	jne    ab4 <malloc+0xd2>
        return 0;
 aad:	b8 00 00 00 00       	mov    $0x0,%eax
 ab2:	eb 13                	jmp    ac7 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab7:	89 45 f0             	mov    %eax,-0x10(%ebp)
 aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abd:	8b 00                	mov    (%eax),%eax
 abf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ac2:	e9 6d ff ff ff       	jmp    a34 <malloc+0x52>
  }
}
 ac7:	c9                   	leave
 ac8:	c3                   	ret
