
_mlfq_test:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#include "user.h"
#include "pstat.h"

#define NPROCS 3

int workload(int n) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  int i, j = 0;
   6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for (i = 0; i < n; i++){
   d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  14:	eb 3c                	jmp    52 <workload+0x52>
    j += i * j + 1;
  16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  19:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  1d:	83 c0 01             	add    $0x1,%eax
  20:	01 45 f0             	add    %eax,-0x10(%ebp)
    if (i % 1000000 == 0) yield(); // 주기적으로 CPU 양보
  23:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  26:	ba 83 de 1b 43       	mov    $0x431bde83,%edx
  2b:	89 c8                	mov    %ecx,%eax
  2d:	f7 ea                	imul   %edx
  2f:	89 d0                	mov    %edx,%eax
  31:	c1 f8 12             	sar    $0x12,%eax
  34:	89 ca                	mov    %ecx,%edx
  36:	c1 fa 1f             	sar    $0x1f,%edx
  39:	29 d0                	sub    %edx,%eax
  3b:	69 d0 40 42 0f 00    	imul   $0xf4240,%eax,%edx
  41:	89 c8                	mov    %ecx,%eax
  43:	29 d0                	sub    %edx,%eax
  45:	85 c0                	test   %eax,%eax
  47:	75 05                	jne    4e <workload+0x4e>
  49:	e8 c4 05 00 00       	call   612 <yield>
  for (i = 0; i < n; i++){
  4e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  55:	3b 45 08             	cmp    0x8(%ebp),%eax
  58:	7c bc                	jl     16 <workload+0x16>
  }
  return j;
  5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  5d:	c9                   	leave
  5e:	c3                   	ret

0000005f <print_stat>:


// 결과 출력
void print_stat() {
  5f:	55                   	push   %ebp
  60:	89 e5                	mov    %esp,%ebp
  62:	57                   	push   %edi
  63:	56                   	push   %esi
  64:	53                   	push   %ebx
  65:	81 ec 2c 0c 00 00    	sub    $0xc2c,%esp
  struct pstat ps;
  getpinfo(&ps);
  6b:	83 ec 0c             	sub    $0xc,%esp
  6e:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
  74:	50                   	push   %eax
  75:	e8 88 05 00 00       	call   602 <getpinfo>
  7a:	83 c4 10             	add    $0x10,%esp

  printf(1, "\n[RESULT] Process Statistics\n");
  7d:	83 ec 08             	sub    $0x8,%esp
  80:	68 b0 0a 00 00       	push   $0xab0
  85:	6a 01                	push   $0x1
  87:	e8 6a 06 00 00       	call   6f6 <printf>
  8c:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
  8f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  96:	e9 0e 01 00 00       	jmp    1a9 <print_stat+0x14a>
    if (ps.inuse[i]) {
  9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  9e:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
  a5:	85 c0                	test   %eax,%eax
  a7:	0f 84 f8 00 00 00    	je     1a5 <print_stat+0x146>
      printf(1, "PID %d | Priority %d | Ticks: [Q3:%d Q2:%d Q1:%d Q0:%d] | Wait: [Q3:%d Q2:%d Q1:%d Q0:%d]\n",
  ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  b0:	83 e8 80             	sub    $0xffffff80,%eax
  b3:	c1 e0 04             	shl    $0x4,%eax
  b6:	8d 40 e8             	lea    -0x18(%eax),%eax
  b9:	01 e8                	add    %ebp,%eax
  bb:	2d 04 0c 00 00       	sub    $0xc04,%eax
  c0:	8b 30                	mov    (%eax),%esi
  c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  c5:	c1 e0 04             	shl    $0x4,%eax
  c8:	8d 40 e8             	lea    -0x18(%eax),%eax
  cb:	01 e8                	add    %ebp,%eax
  cd:	2d 00 04 00 00       	sub    $0x400,%eax
  d2:	8b 38                	mov    (%eax),%edi
  d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  d7:	c1 e0 04             	shl    $0x4,%eax
  da:	8d 40 e8             	lea    -0x18(%eax),%eax
  dd:	01 e8                	add    %ebp,%eax
  df:	2d fc 03 00 00       	sub    $0x3fc,%eax
  e4:	8b 00                	mov    (%eax),%eax
  e6:	89 85 d4 f3 ff ff    	mov    %eax,-0xc2c(%ebp)
  ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  ef:	c1 e0 04             	shl    $0x4,%eax
  f2:	8d 50 e8             	lea    -0x18(%eax),%edx
  f5:	8d 04 2a             	lea    (%edx,%ebp,1),%eax
  f8:	2d f8 03 00 00       	sub    $0x3f8,%eax
  fd:	8b 08                	mov    (%eax),%ecx
  ff:	89 8d d0 f3 ff ff    	mov    %ecx,-0xc30(%ebp)
 105:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 108:	83 c0 40             	add    $0x40,%eax
 10b:	c1 e0 04             	shl    $0x4,%eax
 10e:	8d 58 e8             	lea    -0x18(%eax),%ebx
 111:	8d 04 2b             	lea    (%ebx,%ebp,1),%eax
 114:	2d 04 0c 00 00       	sub    $0xc04,%eax
 119:	8b 10                	mov    (%eax),%edx
 11b:	89 95 cc f3 ff ff    	mov    %edx,-0xc34(%ebp)
 121:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 124:	c1 e0 04             	shl    $0x4,%eax
 127:	8d 58 e8             	lea    -0x18(%eax),%ebx
 12a:	8d 04 2b             	lea    (%ebx,%ebp,1),%eax
 12d:	2d 00 08 00 00       	sub    $0x800,%eax
 132:	8b 18                	mov    (%eax),%ebx
 134:	89 9d c8 f3 ff ff    	mov    %ebx,-0xc38(%ebp)
 13a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 13d:	c1 e0 04             	shl    $0x4,%eax
 140:	8d 40 e8             	lea    -0x18(%eax),%eax
 143:	01 e8                	add    %ebp,%eax
 145:	2d fc 07 00 00       	sub    $0x7fc,%eax
 14a:	8b 18                	mov    (%eax),%ebx
 14c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 14f:	c1 e0 04             	shl    $0x4,%eax
 152:	8d 40 e8             	lea    -0x18(%eax),%eax
 155:	01 e8                	add    %ebp,%eax
 157:	2d f8 07 00 00       	sub    $0x7f8,%eax
 15c:	8b 08                	mov    (%eax),%ecx
 15e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 161:	83 e8 80             	sub    $0xffffff80,%eax
 164:	8b 94 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%edx
 16b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 16e:	83 c0 40             	add    $0x40,%eax
 171:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
 178:	56                   	push   %esi
 179:	57                   	push   %edi
 17a:	ff b5 d4 f3 ff ff    	push   -0xc2c(%ebp)
 180:	ff b5 d0 f3 ff ff    	push   -0xc30(%ebp)
 186:	ff b5 cc f3 ff ff    	push   -0xc34(%ebp)
 18c:	ff b5 c8 f3 ff ff    	push   -0xc38(%ebp)
 192:	53                   	push   %ebx
 193:	51                   	push   %ecx
 194:	52                   	push   %edx
 195:	50                   	push   %eax
 196:	68 d0 0a 00 00       	push   $0xad0
 19b:	6a 01                	push   $0x1
 19d:	e8 54 05 00 00       	call   6f6 <printf>
 1a2:	83 c4 30             	add    $0x30,%esp
  for (int i = 0; i < NPROC; i++) {
 1a5:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 1a9:	83 7d e4 3f          	cmpl   $0x3f,-0x1c(%ebp)
 1ad:	0f 8e e8 fe ff ff    	jle    9b <print_stat+0x3c>
        ps.pid[i], ps.priority[i],
        ps.ticks[i][3], ps.ticks[i][2], ps.ticks[i][1], ps.ticks[i][0],
        ps.wait_ticks[i][3], ps.wait_ticks[i][2], ps.wait_ticks[i][1], ps.wait_ticks[i][0]);
    }
  }
}
 1b3:	90                   	nop
 1b4:	90                   	nop
 1b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1b8:	5b                   	pop    %ebx
 1b9:	5e                   	pop    %esi
 1ba:	5f                   	pop    %edi
 1bb:	5d                   	pop    %ebp
 1bc:	c3                   	ret

000001bd <run_mlfq_with_tracking_and_boosting>:

void run_mlfq_with_tracking_and_boosting() {
 1bd:	55                   	push   %ebp
 1be:	89 e5                	mov    %esp,%ebp
 1c0:	83 ec 18             	sub    $0x18,%esp
  for (int i = 0; i < 3; i++) {
 1c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1ca:	e9 95 00 00 00       	jmp    264 <run_mlfq_with_tracking_and_boosting+0xa7>
    if (fork() == 0) {
 1cf:	e8 86 03 00 00       	call   55a <fork>
 1d4:	85 c0                	test   %eax,%eax
 1d6:	0f 85 84 00 00 00    	jne    260 <run_mlfq_with_tracking_and_boosting+0xa3>
      if (i == 0) {
 1dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1e0:	75 27                	jne    209 <run_mlfq_with_tracking_and_boosting+0x4c>
        printf(1, "[Process %d] Short workload\n", i);
 1e2:	83 ec 04             	sub    $0x4,%esp
 1e5:	ff 75 f4             	push   -0xc(%ebp)
 1e8:	68 2b 0b 00 00       	push   $0xb2b
 1ed:	6a 01                	push   $0x1
 1ef:	e8 02 05 00 00       	call   6f6 <printf>
 1f4:	83 c4 10             	add    $0x10,%esp
        workload(8000000); // Q3 유지
 1f7:	83 ec 0c             	sub    $0xc,%esp
 1fa:	68 00 12 7a 00       	push   $0x7a1200
 1ff:	e8 fc fd ff ff       	call   0 <workload>
 204:	83 c4 10             	add    $0x10,%esp
 207:	eb 52                	jmp    25b <run_mlfq_with_tracking_and_boosting+0x9e>
      } else if (i == 1) {
 209:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
 20d:	75 27                	jne    236 <run_mlfq_with_tracking_and_boosting+0x79>
        printf(1, "[Process %d] Medium workload\n", i);
 20f:	83 ec 04             	sub    $0x4,%esp
 212:	ff 75 f4             	push   -0xc(%ebp)
 215:	68 48 0b 00 00       	push   $0xb48
 21a:	6a 01                	push   $0x1
 21c:	e8 d5 04 00 00       	call   6f6 <printf>
 221:	83 c4 10             	add    $0x10,%esp
        workload(40000000); // Q3→Q2→Q1
 224:	83 ec 0c             	sub    $0xc,%esp
 227:	68 00 5a 62 02       	push   $0x2625a00
 22c:	e8 cf fd ff ff       	call   0 <workload>
 231:	83 c4 10             	add    $0x10,%esp
 234:	eb 25                	jmp    25b <run_mlfq_with_tracking_and_boosting+0x9e>
      } else {
        printf(1, "[Process %d] Long workload\n", i);
 236:	83 ec 04             	sub    $0x4,%esp
 239:	ff 75 f4             	push   -0xc(%ebp)
 23c:	68 66 0b 00 00       	push   $0xb66
 241:	6a 01                	push   $0x1
 243:	e8 ae 04 00 00       	call   6f6 <printf>
 248:	83 c4 10             	add    $0x10,%esp
        workload(100000000); // Q3→Q2→Q1→Q0
 24b:	83 ec 0c             	sub    $0xc,%esp
 24e:	68 00 e1 f5 05       	push   $0x5f5e100
 253:	e8 a8 fd ff ff       	call   0 <workload>
 258:	83 c4 10             	add    $0x10,%esp
      }
      exit();
 25b:	e8 02 03 00 00       	call   562 <exit>
  for (int i = 0; i < 3; i++) {
 260:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 264:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
 268:	0f 8e 61 ff ff ff    	jle    1cf <run_mlfq_with_tracking_and_boosting+0x12>
    }
  }

  for (int i = 0; i < 3; i++) wait();
 26e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 275:	eb 09                	jmp    280 <run_mlfq_with_tracking_and_boosting+0xc3>
 277:	e8 ee 02 00 00       	call   56a <wait>
 27c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 280:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
 284:	7e f1                	jle    277 <run_mlfq_with_tracking_and_boosting+0xba>

  print_stat(); // 결과 확인
 286:	e8 d4 fd ff ff       	call   5f <print_stat>
}
 28b:	90                   	nop
 28c:	c9                   	leave
 28d:	c3                   	ret

0000028e <main>:

int main(void) {
 28e:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 292:	83 e4 f0             	and    $0xfffffff0,%esp
 295:	ff 71 fc             	push   -0x4(%ecx)
 298:	55                   	push   %ebp
 299:	89 e5                	mov    %esp,%ebp
 29b:	51                   	push   %ecx
 29c:	83 ec 04             	sub    $0x4,%esp
  printf(1, "\n===== [POLICY 1: MLFQ with tracking & boosting] =====\n");
 29f:	83 ec 08             	sub    $0x8,%esp
 2a2:	68 84 0b 00 00       	push   $0xb84
 2a7:	6a 01                	push   $0x1
 2a9:	e8 48 04 00 00       	call   6f6 <printf>
 2ae:	83 c4 10             	add    $0x10,%esp
  setSchedPolicy(1);
 2b1:	83 ec 0c             	sub    $0xc,%esp
 2b4:	6a 01                	push   $0x1
 2b6:	e8 4f 03 00 00       	call   60a <setSchedPolicy>
 2bb:	83 c4 10             	add    $0x10,%esp
  printf(1, "[FORKED] sched_policy = %d (child)\n", getSchedPolicy());
 2be:	e8 57 03 00 00       	call   61a <getSchedPolicy>
 2c3:	83 ec 04             	sub    $0x4,%esp
 2c6:	50                   	push   %eax
 2c7:	68 bc 0b 00 00       	push   $0xbbc
 2cc:	6a 01                	push   $0x1
 2ce:	e8 23 04 00 00       	call   6f6 <printf>
 2d3:	83 c4 10             	add    $0x10,%esp

  if (fork() == 0) {
 2d6:	e8 7f 02 00 00       	call   55a <fork>
 2db:	85 c0                	test   %eax,%eax
 2dd:	75 22                	jne    301 <main+0x73>
    printf(1, "[FORKED] sched_policy = %d (child)\n", getSchedPolicy());
 2df:	e8 36 03 00 00       	call   61a <getSchedPolicy>
 2e4:	83 ec 04             	sub    $0x4,%esp
 2e7:	50                   	push   %eax
 2e8:	68 bc 0b 00 00       	push   $0xbbc
 2ed:	6a 01                	push   $0x1
 2ef:	e8 02 04 00 00       	call   6f6 <printf>
 2f4:	83 c4 10             	add    $0x10,%esp
    run_mlfq_with_tracking_and_boosting();
 2f7:	e8 c1 fe ff ff       	call   1bd <run_mlfq_with_tracking_and_boosting>
    exit();
 2fc:	e8 61 02 00 00       	call   562 <exit>
  }
  wait();
 301:	e8 64 02 00 00       	call   56a <wait>
  exit();
 306:	e8 57 02 00 00       	call   562 <exit>

0000030b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 30b:	55                   	push   %ebp
 30c:	89 e5                	mov    %esp,%ebp
 30e:	57                   	push   %edi
 30f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 310:	8b 4d 08             	mov    0x8(%ebp),%ecx
 313:	8b 55 10             	mov    0x10(%ebp),%edx
 316:	8b 45 0c             	mov    0xc(%ebp),%eax
 319:	89 cb                	mov    %ecx,%ebx
 31b:	89 df                	mov    %ebx,%edi
 31d:	89 d1                	mov    %edx,%ecx
 31f:	fc                   	cld
 320:	f3 aa                	rep stos %al,%es:(%edi)
 322:	89 ca                	mov    %ecx,%edx
 324:	89 fb                	mov    %edi,%ebx
 326:	89 5d 08             	mov    %ebx,0x8(%ebp)
 329:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 32c:	90                   	nop
 32d:	5b                   	pop    %ebx
 32e:	5f                   	pop    %edi
 32f:	5d                   	pop    %ebp
 330:	c3                   	ret

00000331 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 331:	55                   	push   %ebp
 332:	89 e5                	mov    %esp,%ebp
 334:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 337:	8b 45 08             	mov    0x8(%ebp),%eax
 33a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 33d:	90                   	nop
 33e:	8b 55 0c             	mov    0xc(%ebp),%edx
 341:	8d 42 01             	lea    0x1(%edx),%eax
 344:	89 45 0c             	mov    %eax,0xc(%ebp)
 347:	8b 45 08             	mov    0x8(%ebp),%eax
 34a:	8d 48 01             	lea    0x1(%eax),%ecx
 34d:	89 4d 08             	mov    %ecx,0x8(%ebp)
 350:	0f b6 12             	movzbl (%edx),%edx
 353:	88 10                	mov    %dl,(%eax)
 355:	0f b6 00             	movzbl (%eax),%eax
 358:	84 c0                	test   %al,%al
 35a:	75 e2                	jne    33e <strcpy+0xd>
    ;
  return os;
 35c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 35f:	c9                   	leave
 360:	c3                   	ret

00000361 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 361:	55                   	push   %ebp
 362:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 364:	eb 08                	jmp    36e <strcmp+0xd>
    p++, q++;
 366:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 36a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 36e:	8b 45 08             	mov    0x8(%ebp),%eax
 371:	0f b6 00             	movzbl (%eax),%eax
 374:	84 c0                	test   %al,%al
 376:	74 10                	je     388 <strcmp+0x27>
 378:	8b 45 08             	mov    0x8(%ebp),%eax
 37b:	0f b6 10             	movzbl (%eax),%edx
 37e:	8b 45 0c             	mov    0xc(%ebp),%eax
 381:	0f b6 00             	movzbl (%eax),%eax
 384:	38 c2                	cmp    %al,%dl
 386:	74 de                	je     366 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 388:	8b 45 08             	mov    0x8(%ebp),%eax
 38b:	0f b6 00             	movzbl (%eax),%eax
 38e:	0f b6 d0             	movzbl %al,%edx
 391:	8b 45 0c             	mov    0xc(%ebp),%eax
 394:	0f b6 00             	movzbl (%eax),%eax
 397:	0f b6 c0             	movzbl %al,%eax
 39a:	29 c2                	sub    %eax,%edx
 39c:	89 d0                	mov    %edx,%eax
}
 39e:	5d                   	pop    %ebp
 39f:	c3                   	ret

000003a0 <strlen>:

uint
strlen(char *s)
{
 3a0:	55                   	push   %ebp
 3a1:	89 e5                	mov    %esp,%ebp
 3a3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3a6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3ad:	eb 04                	jmp    3b3 <strlen+0x13>
 3af:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3b3:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3b6:	8b 45 08             	mov    0x8(%ebp),%eax
 3b9:	01 d0                	add    %edx,%eax
 3bb:	0f b6 00             	movzbl (%eax),%eax
 3be:	84 c0                	test   %al,%al
 3c0:	75 ed                	jne    3af <strlen+0xf>
    ;
  return n;
 3c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3c5:	c9                   	leave
 3c6:	c3                   	ret

000003c7 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3c7:	55                   	push   %ebp
 3c8:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3ca:	8b 45 10             	mov    0x10(%ebp),%eax
 3cd:	50                   	push   %eax
 3ce:	ff 75 0c             	push   0xc(%ebp)
 3d1:	ff 75 08             	push   0x8(%ebp)
 3d4:	e8 32 ff ff ff       	call   30b <stosb>
 3d9:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3dc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3df:	c9                   	leave
 3e0:	c3                   	ret

000003e1 <strchr>:

char*
strchr(const char *s, char c)
{
 3e1:	55                   	push   %ebp
 3e2:	89 e5                	mov    %esp,%ebp
 3e4:	83 ec 04             	sub    $0x4,%esp
 3e7:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ea:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3ed:	eb 14                	jmp    403 <strchr+0x22>
    if(*s == c)
 3ef:	8b 45 08             	mov    0x8(%ebp),%eax
 3f2:	0f b6 00             	movzbl (%eax),%eax
 3f5:	38 45 fc             	cmp    %al,-0x4(%ebp)
 3f8:	75 05                	jne    3ff <strchr+0x1e>
      return (char*)s;
 3fa:	8b 45 08             	mov    0x8(%ebp),%eax
 3fd:	eb 13                	jmp    412 <strchr+0x31>
  for(; *s; s++)
 3ff:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 403:	8b 45 08             	mov    0x8(%ebp),%eax
 406:	0f b6 00             	movzbl (%eax),%eax
 409:	84 c0                	test   %al,%al
 40b:	75 e2                	jne    3ef <strchr+0xe>
  return 0;
 40d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 412:	c9                   	leave
 413:	c3                   	ret

00000414 <gets>:

char*
gets(char *buf, int max)
{
 414:	55                   	push   %ebp
 415:	89 e5                	mov    %esp,%ebp
 417:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 41a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 421:	eb 42                	jmp    465 <gets+0x51>
    cc = read(0, &c, 1);
 423:	83 ec 04             	sub    $0x4,%esp
 426:	6a 01                	push   $0x1
 428:	8d 45 ef             	lea    -0x11(%ebp),%eax
 42b:	50                   	push   %eax
 42c:	6a 00                	push   $0x0
 42e:	e8 47 01 00 00       	call   57a <read>
 433:	83 c4 10             	add    $0x10,%esp
 436:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 439:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 43d:	7e 33                	jle    472 <gets+0x5e>
      break;
    buf[i++] = c;
 43f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 442:	8d 50 01             	lea    0x1(%eax),%edx
 445:	89 55 f4             	mov    %edx,-0xc(%ebp)
 448:	89 c2                	mov    %eax,%edx
 44a:	8b 45 08             	mov    0x8(%ebp),%eax
 44d:	01 c2                	add    %eax,%edx
 44f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 453:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 455:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 459:	3c 0a                	cmp    $0xa,%al
 45b:	74 16                	je     473 <gets+0x5f>
 45d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 461:	3c 0d                	cmp    $0xd,%al
 463:	74 0e                	je     473 <gets+0x5f>
  for(i=0; i+1 < max; ){
 465:	8b 45 f4             	mov    -0xc(%ebp),%eax
 468:	83 c0 01             	add    $0x1,%eax
 46b:	39 45 0c             	cmp    %eax,0xc(%ebp)
 46e:	7f b3                	jg     423 <gets+0xf>
 470:	eb 01                	jmp    473 <gets+0x5f>
      break;
 472:	90                   	nop
      break;
  }
  buf[i] = '\0';
 473:	8b 55 f4             	mov    -0xc(%ebp),%edx
 476:	8b 45 08             	mov    0x8(%ebp),%eax
 479:	01 d0                	add    %edx,%eax
 47b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 47e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 481:	c9                   	leave
 482:	c3                   	ret

00000483 <stat>:

int
stat(char *n, struct stat *st)
{
 483:	55                   	push   %ebp
 484:	89 e5                	mov    %esp,%ebp
 486:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 489:	83 ec 08             	sub    $0x8,%esp
 48c:	6a 00                	push   $0x0
 48e:	ff 75 08             	push   0x8(%ebp)
 491:	e8 0c 01 00 00       	call   5a2 <open>
 496:	83 c4 10             	add    $0x10,%esp
 499:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 49c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4a0:	79 07                	jns    4a9 <stat+0x26>
    return -1;
 4a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4a7:	eb 25                	jmp    4ce <stat+0x4b>
  r = fstat(fd, st);
 4a9:	83 ec 08             	sub    $0x8,%esp
 4ac:	ff 75 0c             	push   0xc(%ebp)
 4af:	ff 75 f4             	push   -0xc(%ebp)
 4b2:	e8 03 01 00 00       	call   5ba <fstat>
 4b7:	83 c4 10             	add    $0x10,%esp
 4ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4bd:	83 ec 0c             	sub    $0xc,%esp
 4c0:	ff 75 f4             	push   -0xc(%ebp)
 4c3:	e8 c2 00 00 00       	call   58a <close>
 4c8:	83 c4 10             	add    $0x10,%esp
  return r;
 4cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4ce:	c9                   	leave
 4cf:	c3                   	ret

000004d0 <atoi>:

int
atoi(const char *s)
{
 4d0:	55                   	push   %ebp
 4d1:	89 e5                	mov    %esp,%ebp
 4d3:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4d6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4dd:	eb 25                	jmp    504 <atoi+0x34>
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
 50c:	7e 0a                	jle    518 <atoi+0x48>
 50e:	8b 45 08             	mov    0x8(%ebp),%eax
 511:	0f b6 00             	movzbl (%eax),%eax
 514:	3c 39                	cmp    $0x39,%al
 516:	7e c7                	jle    4df <atoi+0xf>
  return n;
 518:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 51b:	c9                   	leave
 51c:	c3                   	ret

0000051d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 51d:	55                   	push   %ebp
 51e:	89 e5                	mov    %esp,%ebp
 520:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 523:	8b 45 08             	mov    0x8(%ebp),%eax
 526:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 529:	8b 45 0c             	mov    0xc(%ebp),%eax
 52c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 52f:	eb 17                	jmp    548 <memmove+0x2b>
    *dst++ = *src++;
 531:	8b 55 f8             	mov    -0x8(%ebp),%edx
 534:	8d 42 01             	lea    0x1(%edx),%eax
 537:	89 45 f8             	mov    %eax,-0x8(%ebp)
 53a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 53d:	8d 48 01             	lea    0x1(%eax),%ecx
 540:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 543:	0f b6 12             	movzbl (%edx),%edx
 546:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 548:	8b 45 10             	mov    0x10(%ebp),%eax
 54b:	8d 50 ff             	lea    -0x1(%eax),%edx
 54e:	89 55 10             	mov    %edx,0x10(%ebp)
 551:	85 c0                	test   %eax,%eax
 553:	7f dc                	jg     531 <memmove+0x14>
  return vdst;
 555:	8b 45 08             	mov    0x8(%ebp),%eax
}
 558:	c9                   	leave
 559:	c3                   	ret

0000055a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 55a:	b8 01 00 00 00       	mov    $0x1,%eax
 55f:	cd 40                	int    $0x40
 561:	c3                   	ret

00000562 <exit>:
SYSCALL(exit)
 562:	b8 02 00 00 00       	mov    $0x2,%eax
 567:	cd 40                	int    $0x40
 569:	c3                   	ret

0000056a <wait>:
SYSCALL(wait)
 56a:	b8 03 00 00 00       	mov    $0x3,%eax
 56f:	cd 40                	int    $0x40
 571:	c3                   	ret

00000572 <pipe>:
SYSCALL(pipe)
 572:	b8 04 00 00 00       	mov    $0x4,%eax
 577:	cd 40                	int    $0x40
 579:	c3                   	ret

0000057a <read>:
SYSCALL(read)
 57a:	b8 05 00 00 00       	mov    $0x5,%eax
 57f:	cd 40                	int    $0x40
 581:	c3                   	ret

00000582 <write>:
SYSCALL(write)
 582:	b8 10 00 00 00       	mov    $0x10,%eax
 587:	cd 40                	int    $0x40
 589:	c3                   	ret

0000058a <close>:
SYSCALL(close)
 58a:	b8 15 00 00 00       	mov    $0x15,%eax
 58f:	cd 40                	int    $0x40
 591:	c3                   	ret

00000592 <kill>:
SYSCALL(kill)
 592:	b8 06 00 00 00       	mov    $0x6,%eax
 597:	cd 40                	int    $0x40
 599:	c3                   	ret

0000059a <exec>:
SYSCALL(exec)
 59a:	b8 07 00 00 00       	mov    $0x7,%eax
 59f:	cd 40                	int    $0x40
 5a1:	c3                   	ret

000005a2 <open>:
SYSCALL(open)
 5a2:	b8 0f 00 00 00       	mov    $0xf,%eax
 5a7:	cd 40                	int    $0x40
 5a9:	c3                   	ret

000005aa <mknod>:
SYSCALL(mknod)
 5aa:	b8 11 00 00 00       	mov    $0x11,%eax
 5af:	cd 40                	int    $0x40
 5b1:	c3                   	ret

000005b2 <unlink>:
SYSCALL(unlink)
 5b2:	b8 12 00 00 00       	mov    $0x12,%eax
 5b7:	cd 40                	int    $0x40
 5b9:	c3                   	ret

000005ba <fstat>:
SYSCALL(fstat)
 5ba:	b8 08 00 00 00       	mov    $0x8,%eax
 5bf:	cd 40                	int    $0x40
 5c1:	c3                   	ret

000005c2 <link>:
SYSCALL(link)
 5c2:	b8 13 00 00 00       	mov    $0x13,%eax
 5c7:	cd 40                	int    $0x40
 5c9:	c3                   	ret

000005ca <mkdir>:
SYSCALL(mkdir)
 5ca:	b8 14 00 00 00       	mov    $0x14,%eax
 5cf:	cd 40                	int    $0x40
 5d1:	c3                   	ret

000005d2 <chdir>:
SYSCALL(chdir)
 5d2:	b8 09 00 00 00       	mov    $0x9,%eax
 5d7:	cd 40                	int    $0x40
 5d9:	c3                   	ret

000005da <dup>:
SYSCALL(dup)
 5da:	b8 0a 00 00 00       	mov    $0xa,%eax
 5df:	cd 40                	int    $0x40
 5e1:	c3                   	ret

000005e2 <getpid>:
SYSCALL(getpid)
 5e2:	b8 0b 00 00 00       	mov    $0xb,%eax
 5e7:	cd 40                	int    $0x40
 5e9:	c3                   	ret

000005ea <sbrk>:
SYSCALL(sbrk)
 5ea:	b8 0c 00 00 00       	mov    $0xc,%eax
 5ef:	cd 40                	int    $0x40
 5f1:	c3                   	ret

000005f2 <sleep>:
SYSCALL(sleep)
 5f2:	b8 0d 00 00 00       	mov    $0xd,%eax
 5f7:	cd 40                	int    $0x40
 5f9:	c3                   	ret

000005fa <uptime>:
SYSCALL(uptime)
 5fa:	b8 0e 00 00 00       	mov    $0xe,%eax
 5ff:	cd 40                	int    $0x40
 601:	c3                   	ret

00000602 <getpinfo>:

SYSCALL(getpinfo)
 602:	b8 16 00 00 00       	mov    $0x16,%eax
 607:	cd 40                	int    $0x40
 609:	c3                   	ret

0000060a <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 60a:	b8 17 00 00 00       	mov    $0x17,%eax
 60f:	cd 40                	int    $0x40
 611:	c3                   	ret

00000612 <yield>:
SYSCALL(yield)
 612:	b8 18 00 00 00       	mov    $0x18,%eax
 617:	cd 40                	int    $0x40
 619:	c3                   	ret

0000061a <getSchedPolicy>:
 61a:	b8 19 00 00 00       	mov    $0x19,%eax
 61f:	cd 40                	int    $0x40
 621:	c3                   	ret

00000622 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 622:	55                   	push   %ebp
 623:	89 e5                	mov    %esp,%ebp
 625:	83 ec 18             	sub    $0x18,%esp
 628:	8b 45 0c             	mov    0xc(%ebp),%eax
 62b:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 62e:	83 ec 04             	sub    $0x4,%esp
 631:	6a 01                	push   $0x1
 633:	8d 45 f4             	lea    -0xc(%ebp),%eax
 636:	50                   	push   %eax
 637:	ff 75 08             	push   0x8(%ebp)
 63a:	e8 43 ff ff ff       	call   582 <write>
 63f:	83 c4 10             	add    $0x10,%esp
}
 642:	90                   	nop
 643:	c9                   	leave
 644:	c3                   	ret

00000645 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 645:	55                   	push   %ebp
 646:	89 e5                	mov    %esp,%ebp
 648:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 64b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 652:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 656:	74 17                	je     66f <printint+0x2a>
 658:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 65c:	79 11                	jns    66f <printint+0x2a>
    neg = 1;
 65e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 665:	8b 45 0c             	mov    0xc(%ebp),%eax
 668:	f7 d8                	neg    %eax
 66a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 66d:	eb 06                	jmp    675 <printint+0x30>
  } else {
    x = xx;
 66f:	8b 45 0c             	mov    0xc(%ebp),%eax
 672:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 675:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 67c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 67f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 682:	ba 00 00 00 00       	mov    $0x0,%edx
 687:	f7 f1                	div    %ecx
 689:	89 d1                	mov    %edx,%ecx
 68b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 68e:	8d 50 01             	lea    0x1(%eax),%edx
 691:	89 55 f4             	mov    %edx,-0xc(%ebp)
 694:	0f b6 91 e8 0b 00 00 	movzbl 0xbe8(%ecx),%edx
 69b:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 69f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6a5:	ba 00 00 00 00       	mov    $0x0,%edx
 6aa:	f7 f1                	div    %ecx
 6ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6af:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6b3:	75 c7                	jne    67c <printint+0x37>
  if(neg)
 6b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6b9:	74 2d                	je     6e8 <printint+0xa3>
    buf[i++] = '-';
 6bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6be:	8d 50 01             	lea    0x1(%eax),%edx
 6c1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6c4:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6c9:	eb 1d                	jmp    6e8 <printint+0xa3>
    putc(fd, buf[i]);
 6cb:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d1:	01 d0                	add    %edx,%eax
 6d3:	0f b6 00             	movzbl (%eax),%eax
 6d6:	0f be c0             	movsbl %al,%eax
 6d9:	83 ec 08             	sub    $0x8,%esp
 6dc:	50                   	push   %eax
 6dd:	ff 75 08             	push   0x8(%ebp)
 6e0:	e8 3d ff ff ff       	call   622 <putc>
 6e5:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6e8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6f0:	79 d9                	jns    6cb <printint+0x86>
}
 6f2:	90                   	nop
 6f3:	90                   	nop
 6f4:	c9                   	leave
 6f5:	c3                   	ret

000006f6 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6f6:	55                   	push   %ebp
 6f7:	89 e5                	mov    %esp,%ebp
 6f9:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6fc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 703:	8d 45 0c             	lea    0xc(%ebp),%eax
 706:	83 c0 04             	add    $0x4,%eax
 709:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 70c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 713:	e9 59 01 00 00       	jmp    871 <printf+0x17b>
    c = fmt[i] & 0xff;
 718:	8b 55 0c             	mov    0xc(%ebp),%edx
 71b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 71e:	01 d0                	add    %edx,%eax
 720:	0f b6 00             	movzbl (%eax),%eax
 723:	0f be c0             	movsbl %al,%eax
 726:	25 ff 00 00 00       	and    $0xff,%eax
 72b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 72e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 732:	75 2c                	jne    760 <printf+0x6a>
      if(c == '%'){
 734:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 738:	75 0c                	jne    746 <printf+0x50>
        state = '%';
 73a:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 741:	e9 27 01 00 00       	jmp    86d <printf+0x177>
      } else {
        putc(fd, c);
 746:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 749:	0f be c0             	movsbl %al,%eax
 74c:	83 ec 08             	sub    $0x8,%esp
 74f:	50                   	push   %eax
 750:	ff 75 08             	push   0x8(%ebp)
 753:	e8 ca fe ff ff       	call   622 <putc>
 758:	83 c4 10             	add    $0x10,%esp
 75b:	e9 0d 01 00 00       	jmp    86d <printf+0x177>
      }
    } else if(state == '%'){
 760:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 764:	0f 85 03 01 00 00    	jne    86d <printf+0x177>
      if(c == 'd'){
 76a:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 76e:	75 1e                	jne    78e <printf+0x98>
        printint(fd, *ap, 10, 1);
 770:	8b 45 e8             	mov    -0x18(%ebp),%eax
 773:	8b 00                	mov    (%eax),%eax
 775:	6a 01                	push   $0x1
 777:	6a 0a                	push   $0xa
 779:	50                   	push   %eax
 77a:	ff 75 08             	push   0x8(%ebp)
 77d:	e8 c3 fe ff ff       	call   645 <printint>
 782:	83 c4 10             	add    $0x10,%esp
        ap++;
 785:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 789:	e9 d8 00 00 00       	jmp    866 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 78e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 792:	74 06                	je     79a <printf+0xa4>
 794:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 798:	75 1e                	jne    7b8 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 79a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 79d:	8b 00                	mov    (%eax),%eax
 79f:	6a 00                	push   $0x0
 7a1:	6a 10                	push   $0x10
 7a3:	50                   	push   %eax
 7a4:	ff 75 08             	push   0x8(%ebp)
 7a7:	e8 99 fe ff ff       	call   645 <printint>
 7ac:	83 c4 10             	add    $0x10,%esp
        ap++;
 7af:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7b3:	e9 ae 00 00 00       	jmp    866 <printf+0x170>
      } else if(c == 's'){
 7b8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7bc:	75 43                	jne    801 <printf+0x10b>
        s = (char*)*ap;
 7be:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c1:	8b 00                	mov    (%eax),%eax
 7c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7c6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7ce:	75 25                	jne    7f5 <printf+0xff>
          s = "(null)";
 7d0:	c7 45 f4 e0 0b 00 00 	movl   $0xbe0,-0xc(%ebp)
        while(*s != 0){
 7d7:	eb 1c                	jmp    7f5 <printf+0xff>
          putc(fd, *s);
 7d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7dc:	0f b6 00             	movzbl (%eax),%eax
 7df:	0f be c0             	movsbl %al,%eax
 7e2:	83 ec 08             	sub    $0x8,%esp
 7e5:	50                   	push   %eax
 7e6:	ff 75 08             	push   0x8(%ebp)
 7e9:	e8 34 fe ff ff       	call   622 <putc>
 7ee:	83 c4 10             	add    $0x10,%esp
          s++;
 7f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 7f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f8:	0f b6 00             	movzbl (%eax),%eax
 7fb:	84 c0                	test   %al,%al
 7fd:	75 da                	jne    7d9 <printf+0xe3>
 7ff:	eb 65                	jmp    866 <printf+0x170>
        }
      } else if(c == 'c'){
 801:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 805:	75 1d                	jne    824 <printf+0x12e>
        putc(fd, *ap);
 807:	8b 45 e8             	mov    -0x18(%ebp),%eax
 80a:	8b 00                	mov    (%eax),%eax
 80c:	0f be c0             	movsbl %al,%eax
 80f:	83 ec 08             	sub    $0x8,%esp
 812:	50                   	push   %eax
 813:	ff 75 08             	push   0x8(%ebp)
 816:	e8 07 fe ff ff       	call   622 <putc>
 81b:	83 c4 10             	add    $0x10,%esp
        ap++;
 81e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 822:	eb 42                	jmp    866 <printf+0x170>
      } else if(c == '%'){
 824:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 828:	75 17                	jne    841 <printf+0x14b>
        putc(fd, c);
 82a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 82d:	0f be c0             	movsbl %al,%eax
 830:	83 ec 08             	sub    $0x8,%esp
 833:	50                   	push   %eax
 834:	ff 75 08             	push   0x8(%ebp)
 837:	e8 e6 fd ff ff       	call   622 <putc>
 83c:	83 c4 10             	add    $0x10,%esp
 83f:	eb 25                	jmp    866 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 841:	83 ec 08             	sub    $0x8,%esp
 844:	6a 25                	push   $0x25
 846:	ff 75 08             	push   0x8(%ebp)
 849:	e8 d4 fd ff ff       	call   622 <putc>
 84e:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 851:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 854:	0f be c0             	movsbl %al,%eax
 857:	83 ec 08             	sub    $0x8,%esp
 85a:	50                   	push   %eax
 85b:	ff 75 08             	push   0x8(%ebp)
 85e:	e8 bf fd ff ff       	call   622 <putc>
 863:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 866:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 86d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 871:	8b 55 0c             	mov    0xc(%ebp),%edx
 874:	8b 45 f0             	mov    -0x10(%ebp),%eax
 877:	01 d0                	add    %edx,%eax
 879:	0f b6 00             	movzbl (%eax),%eax
 87c:	84 c0                	test   %al,%al
 87e:	0f 85 94 fe ff ff    	jne    718 <printf+0x22>
    }
  }
}
 884:	90                   	nop
 885:	90                   	nop
 886:	c9                   	leave
 887:	c3                   	ret

00000888 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 888:	55                   	push   %ebp
 889:	89 e5                	mov    %esp,%ebp
 88b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 88e:	8b 45 08             	mov    0x8(%ebp),%eax
 891:	83 e8 08             	sub    $0x8,%eax
 894:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 897:	a1 04 0c 00 00       	mov    0xc04,%eax
 89c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 89f:	eb 24                	jmp    8c5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a4:	8b 00                	mov    (%eax),%eax
 8a6:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8a9:	72 12                	jb     8bd <free+0x35>
 8ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ae:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8b1:	72 24                	jb     8d7 <free+0x4f>
 8b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b6:	8b 00                	mov    (%eax),%eax
 8b8:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8bb:	72 1a                	jb     8d7 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c0:	8b 00                	mov    (%eax),%eax
 8c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c8:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8cb:	73 d4                	jae    8a1 <free+0x19>
 8cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d0:	8b 00                	mov    (%eax),%eax
 8d2:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8d5:	73 ca                	jae    8a1 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8da:	8b 40 04             	mov    0x4(%eax),%eax
 8dd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e7:	01 c2                	add    %eax,%edx
 8e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ec:	8b 00                	mov    (%eax),%eax
 8ee:	39 c2                	cmp    %eax,%edx
 8f0:	75 24                	jne    916 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f5:	8b 50 04             	mov    0x4(%eax),%edx
 8f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fb:	8b 00                	mov    (%eax),%eax
 8fd:	8b 40 04             	mov    0x4(%eax),%eax
 900:	01 c2                	add    %eax,%edx
 902:	8b 45 f8             	mov    -0x8(%ebp),%eax
 905:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 908:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90b:	8b 00                	mov    (%eax),%eax
 90d:	8b 10                	mov    (%eax),%edx
 90f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 912:	89 10                	mov    %edx,(%eax)
 914:	eb 0a                	jmp    920 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 916:	8b 45 fc             	mov    -0x4(%ebp),%eax
 919:	8b 10                	mov    (%eax),%edx
 91b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 920:	8b 45 fc             	mov    -0x4(%ebp),%eax
 923:	8b 40 04             	mov    0x4(%eax),%eax
 926:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 92d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 930:	01 d0                	add    %edx,%eax
 932:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 935:	75 20                	jne    957 <free+0xcf>
    p->s.size += bp->s.size;
 937:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93a:	8b 50 04             	mov    0x4(%eax),%edx
 93d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 940:	8b 40 04             	mov    0x4(%eax),%eax
 943:	01 c2                	add    %eax,%edx
 945:	8b 45 fc             	mov    -0x4(%ebp),%eax
 948:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 94b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94e:	8b 10                	mov    (%eax),%edx
 950:	8b 45 fc             	mov    -0x4(%ebp),%eax
 953:	89 10                	mov    %edx,(%eax)
 955:	eb 08                	jmp    95f <free+0xd7>
  } else
    p->s.ptr = bp;
 957:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 95d:	89 10                	mov    %edx,(%eax)
  freep = p;
 95f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 962:	a3 04 0c 00 00       	mov    %eax,0xc04
}
 967:	90                   	nop
 968:	c9                   	leave
 969:	c3                   	ret

0000096a <morecore>:

static Header*
morecore(uint nu)
{
 96a:	55                   	push   %ebp
 96b:	89 e5                	mov    %esp,%ebp
 96d:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 970:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 977:	77 07                	ja     980 <morecore+0x16>
    nu = 4096;
 979:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 980:	8b 45 08             	mov    0x8(%ebp),%eax
 983:	c1 e0 03             	shl    $0x3,%eax
 986:	83 ec 0c             	sub    $0xc,%esp
 989:	50                   	push   %eax
 98a:	e8 5b fc ff ff       	call   5ea <sbrk>
 98f:	83 c4 10             	add    $0x10,%esp
 992:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 995:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 999:	75 07                	jne    9a2 <morecore+0x38>
    return 0;
 99b:	b8 00 00 00 00       	mov    $0x0,%eax
 9a0:	eb 26                	jmp    9c8 <morecore+0x5e>
  hp = (Header*)p;
 9a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ab:	8b 55 08             	mov    0x8(%ebp),%edx
 9ae:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b4:	83 c0 08             	add    $0x8,%eax
 9b7:	83 ec 0c             	sub    $0xc,%esp
 9ba:	50                   	push   %eax
 9bb:	e8 c8 fe ff ff       	call   888 <free>
 9c0:	83 c4 10             	add    $0x10,%esp
  return freep;
 9c3:	a1 04 0c 00 00       	mov    0xc04,%eax
}
 9c8:	c9                   	leave
 9c9:	c3                   	ret

000009ca <malloc>:

void*
malloc(uint nbytes)
{
 9ca:	55                   	push   %ebp
 9cb:	89 e5                	mov    %esp,%ebp
 9cd:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9d0:	8b 45 08             	mov    0x8(%ebp),%eax
 9d3:	83 c0 07             	add    $0x7,%eax
 9d6:	c1 e8 03             	shr    $0x3,%eax
 9d9:	83 c0 01             	add    $0x1,%eax
 9dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9df:	a1 04 0c 00 00       	mov    0xc04,%eax
 9e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9eb:	75 23                	jne    a10 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9ed:	c7 45 f0 fc 0b 00 00 	movl   $0xbfc,-0x10(%ebp)
 9f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f7:	a3 04 0c 00 00       	mov    %eax,0xc04
 9fc:	a1 04 0c 00 00       	mov    0xc04,%eax
 a01:	a3 fc 0b 00 00       	mov    %eax,0xbfc
    base.s.size = 0;
 a06:	c7 05 00 0c 00 00 00 	movl   $0x0,0xc00
 a0d:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a13:	8b 00                	mov    (%eax),%eax
 a15:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1b:	8b 40 04             	mov    0x4(%eax),%eax
 a1e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a21:	72 4d                	jb     a70 <malloc+0xa6>
      if(p->s.size == nunits)
 a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a26:	8b 40 04             	mov    0x4(%eax),%eax
 a29:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a2c:	75 0c                	jne    a3a <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a31:	8b 10                	mov    (%eax),%edx
 a33:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a36:	89 10                	mov    %edx,(%eax)
 a38:	eb 26                	jmp    a60 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3d:	8b 40 04             	mov    0x4(%eax),%eax
 a40:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a43:	89 c2                	mov    %eax,%edx
 a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a48:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4e:	8b 40 04             	mov    0x4(%eax),%eax
 a51:	c1 e0 03             	shl    $0x3,%eax
 a54:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5a:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a5d:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a63:	a3 04 0c 00 00       	mov    %eax,0xc04
      return (void*)(p + 1);
 a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6b:	83 c0 08             	add    $0x8,%eax
 a6e:	eb 3b                	jmp    aab <malloc+0xe1>
    }
    if(p == freep)
 a70:	a1 04 0c 00 00       	mov    0xc04,%eax
 a75:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a78:	75 1e                	jne    a98 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a7a:	83 ec 0c             	sub    $0xc,%esp
 a7d:	ff 75 ec             	push   -0x14(%ebp)
 a80:	e8 e5 fe ff ff       	call   96a <morecore>
 a85:	83 c4 10             	add    $0x10,%esp
 a88:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a8b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a8f:	75 07                	jne    a98 <malloc+0xce>
        return 0;
 a91:	b8 00 00 00 00       	mov    $0x0,%eax
 a96:	eb 13                	jmp    aab <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa1:	8b 00                	mov    (%eax),%eax
 aa3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 aa6:	e9 6d ff ff ff       	jmp    a18 <malloc+0x4e>
  }
}
 aab:	c9                   	leave
 aac:	c3                   	ret
