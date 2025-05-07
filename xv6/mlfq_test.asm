
_mlfq_test:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#include "user.h"
#include "pstat.h"

#define NPROCS 3

int workload(int n) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 10             	sub    $0x10,%esp
  int i, j = 0;
   6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for (i = 0; i < n; i++){
   d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  14:	eb 11                	jmp    27 <workload+0x27>
    j += i * j + 1;
  16:	8b 45 fc             	mov    -0x4(%ebp),%eax
  19:	0f af 45 f8          	imul   -0x8(%ebp),%eax
  1d:	83 c0 01             	add    $0x1,%eax
  20:	01 45 f8             	add    %eax,-0x8(%ebp)
  for (i = 0; i < n; i++){
  23:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  27:	8b 45 fc             	mov    -0x4(%ebp),%eax
  2a:	3b 45 08             	cmp    0x8(%ebp),%eax
  2d:	7c e7                	jl     16 <workload+0x16>
    //if (i % 1000000 == 0) yield(); // 주기적으로 CPU 양보
  }
  return j;
  2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  32:	c9                   	leave
  33:	c3                   	ret

00000034 <print_stat>:

void print_stat() {
  34:	55                   	push   %ebp
  35:	89 e5                	mov    %esp,%ebp
  37:	57                   	push   %edi
  38:	56                   	push   %esi
  39:	53                   	push   %ebx
  3a:	81 ec 2c 0c 00 00    	sub    $0xc2c,%esp
  struct pstat ps;
  getpinfo(&ps);
  40:	83 ec 0c             	sub    $0xc,%esp
  43:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
  49:	50                   	push   %eax
  4a:	e8 d5 05 00 00       	call   624 <getpinfo>
  4f:	83 c4 10             	add    $0x10,%esp

  printf(1, "\n[RESULT] Process Statistics\n");
  52:	83 ec 08             	sub    $0x8,%esp
  55:	68 d0 0a 00 00       	push   $0xad0
  5a:	6a 01                	push   $0x1
  5c:	e8 b7 06 00 00       	call   718 <printf>
  61:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
  64:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  6b:	e9 0e 01 00 00       	jmp    17e <print_stat+0x14a>
    if (ps.inuse[i]) {
  70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  73:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
  7a:	85 c0                	test   %eax,%eax
  7c:	0f 84 f8 00 00 00    	je     17a <print_stat+0x146>
      printf(1, "PID %d | Priority %d | Ticks: [Q3:%d Q2:%d Q1:%d Q0:%d] | Wait: [Q3:%d Q2:%d Q1:%d Q0:%d]\n",
  82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  85:	83 e8 80             	sub    $0xffffff80,%eax
  88:	c1 e0 04             	shl    $0x4,%eax
  8b:	8d 40 e8             	lea    -0x18(%eax),%eax
  8e:	01 e8                	add    %ebp,%eax
  90:	2d 04 0c 00 00       	sub    $0xc04,%eax
  95:	8b 30                	mov    (%eax),%esi
  97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  9a:	c1 e0 04             	shl    $0x4,%eax
  9d:	8d 40 e8             	lea    -0x18(%eax),%eax
  a0:	01 e8                	add    %ebp,%eax
  a2:	2d 00 04 00 00       	sub    $0x400,%eax
  a7:	8b 38                	mov    (%eax),%edi
  a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  ac:	c1 e0 04             	shl    $0x4,%eax
  af:	8d 40 e8             	lea    -0x18(%eax),%eax
  b2:	01 e8                	add    %ebp,%eax
  b4:	2d fc 03 00 00       	sub    $0x3fc,%eax
  b9:	8b 00                	mov    (%eax),%eax
  bb:	89 85 d4 f3 ff ff    	mov    %eax,-0xc2c(%ebp)
  c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  c4:	c1 e0 04             	shl    $0x4,%eax
  c7:	8d 50 e8             	lea    -0x18(%eax),%edx
  ca:	8d 04 2a             	lea    (%edx,%ebp,1),%eax
  cd:	2d f8 03 00 00       	sub    $0x3f8,%eax
  d2:	8b 08                	mov    (%eax),%ecx
  d4:	89 8d d0 f3 ff ff    	mov    %ecx,-0xc30(%ebp)
  da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  dd:	83 c0 40             	add    $0x40,%eax
  e0:	c1 e0 04             	shl    $0x4,%eax
  e3:	8d 58 e8             	lea    -0x18(%eax),%ebx
  e6:	8d 04 2b             	lea    (%ebx,%ebp,1),%eax
  e9:	2d 04 0c 00 00       	sub    $0xc04,%eax
  ee:	8b 10                	mov    (%eax),%edx
  f0:	89 95 cc f3 ff ff    	mov    %edx,-0xc34(%ebp)
  f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  f9:	c1 e0 04             	shl    $0x4,%eax
  fc:	8d 58 e8             	lea    -0x18(%eax),%ebx
  ff:	8d 04 2b             	lea    (%ebx,%ebp,1),%eax
 102:	2d 00 08 00 00       	sub    $0x800,%eax
 107:	8b 18                	mov    (%eax),%ebx
 109:	89 9d c8 f3 ff ff    	mov    %ebx,-0xc38(%ebp)
 10f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 112:	c1 e0 04             	shl    $0x4,%eax
 115:	8d 40 e8             	lea    -0x18(%eax),%eax
 118:	01 e8                	add    %ebp,%eax
 11a:	2d fc 07 00 00       	sub    $0x7fc,%eax
 11f:	8b 18                	mov    (%eax),%ebx
 121:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 124:	c1 e0 04             	shl    $0x4,%eax
 127:	8d 40 e8             	lea    -0x18(%eax),%eax
 12a:	01 e8                	add    %ebp,%eax
 12c:	2d f8 07 00 00       	sub    $0x7f8,%eax
 131:	8b 08                	mov    (%eax),%ecx
 133:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 136:	83 e8 80             	sub    $0xffffff80,%eax
 139:	8b 94 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%edx
 140:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 143:	83 c0 40             	add    $0x40,%eax
 146:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
 14d:	56                   	push   %esi
 14e:	57                   	push   %edi
 14f:	ff b5 d4 f3 ff ff    	push   -0xc2c(%ebp)
 155:	ff b5 d0 f3 ff ff    	push   -0xc30(%ebp)
 15b:	ff b5 cc f3 ff ff    	push   -0xc34(%ebp)
 161:	ff b5 c8 f3 ff ff    	push   -0xc38(%ebp)
 167:	53                   	push   %ebx
 168:	51                   	push   %ecx
 169:	52                   	push   %edx
 16a:	50                   	push   %eax
 16b:	68 f0 0a 00 00       	push   $0xaf0
 170:	6a 01                	push   $0x1
 172:	e8 a1 05 00 00       	call   718 <printf>
 177:	83 c4 30             	add    $0x30,%esp
  for (int i = 0; i < NPROC; i++) {
 17a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 17e:	83 7d e4 3f          	cmpl   $0x3f,-0x1c(%ebp)
 182:	0f 8e e8 fe ff ff    	jle    70 <print_stat+0x3c>
        ps.pid[i], ps.priority[i],
        ps.ticks[i][3], ps.ticks[i][2], ps.ticks[i][1], ps.ticks[i][0],
        ps.wait_ticks[i][3], ps.wait_ticks[i][2], ps.wait_ticks[i][1], ps.wait_ticks[i][0]);
    }
  }
}
 188:	90                   	nop
 189:	90                   	nop
 18a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 18d:	5b                   	pop    %ebx
 18e:	5e                   	pop    %esi
 18f:	5f                   	pop    %edi
 190:	5d                   	pop    %ebp
 191:	c3                   	ret

00000192 <run_mlfq_with_tracking_and_boosting>:

void run_mlfq_with_tracking_and_boosting() {
 192:	55                   	push   %ebp
 193:	89 e5                	mov    %esp,%ebp
 195:	83 ec 18             	sub    $0x18,%esp
  printf(1, "[DEBUG] Entered run_mlfq_with_tracking_and_boosting()\n");
 198:	83 ec 08             	sub    $0x8,%esp
 19b:	68 4c 0b 00 00       	push   $0xb4c
 1a0:	6a 01                	push   $0x1
 1a2:	e8 71 05 00 00       	call   718 <printf>
 1a7:	83 c4 10             	add    $0x10,%esp
  sleep(1); 
 1aa:	83 ec 0c             	sub    $0xc,%esp
 1ad:	6a 01                	push   $0x1
 1af:	e8 60 04 00 00       	call   614 <sleep>
 1b4:	83 c4 10             	add    $0x10,%esp
  
  for (int i = 0; i < 3; i++) {
 1b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1be:	e9 9e 00 00 00       	jmp    261 <run_mlfq_with_tracking_and_boosting+0xcf>
    int pid = fork();
 1c3:	e8 b4 03 00 00       	call   57c <fork>
 1c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (pid < 0) {
 1cb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 1cf:	79 22                	jns    1f3 <run_mlfq_with_tracking_and_boosting+0x61>
      printf(1, "[ERROR] fork failed at i=%d\n", i);
 1d1:	83 ec 04             	sub    $0x4,%esp
 1d4:	ff 75 f4             	push   -0xc(%ebp)
 1d7:	68 83 0b 00 00       	push   $0xb83
 1dc:	6a 01                	push   $0x1
 1de:	e8 35 05 00 00       	call   718 <printf>
 1e3:	83 c4 10             	add    $0x10,%esp
      sleep(1);
 1e6:	83 ec 0c             	sub    $0xc,%esp
 1e9:	6a 01                	push   $0x1
 1eb:	e8 24 04 00 00       	call   614 <sleep>
 1f0:	83 c4 10             	add    $0x10,%esp
    }
    if (pid == 0) {
 1f3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 1f7:	75 42                	jne    23b <run_mlfq_with_tracking_and_boosting+0xa9>
      printf(1, "[CHILD] i=%d, PID=%d\n", i, getpid());
 1f9:	e8 06 04 00 00       	call   604 <getpid>
 1fe:	50                   	push   %eax
 1ff:	ff 75 f4             	push   -0xc(%ebp)
 202:	68 a0 0b 00 00       	push   $0xba0
 207:	6a 01                	push   $0x1
 209:	e8 0a 05 00 00       	call   718 <printf>
 20e:	83 c4 10             	add    $0x10,%esp
      sleep(1);
 211:	83 ec 0c             	sub    $0xc,%esp
 214:	6a 01                	push   $0x1
 216:	e8 f9 03 00 00       	call   614 <sleep>
 21b:	83 c4 10             	add    $0x10,%esp
      workload(10000000 * (i+1));
 21e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 221:	83 c0 01             	add    $0x1,%eax
 224:	69 c0 80 96 98 00    	imul   $0x989680,%eax,%eax
 22a:	83 ec 0c             	sub    $0xc,%esp
 22d:	50                   	push   %eax
 22e:	e8 cd fd ff ff       	call   0 <workload>
 233:	83 c4 10             	add    $0x10,%esp
      exit();
 236:	e8 49 03 00 00       	call   584 <exit>
    } else {
      printf(1, "[PARENT] forked child PID=%d at i=%d\n", pid, i);
 23b:	ff 75 f4             	push   -0xc(%ebp)
 23e:	ff 75 e8             	push   -0x18(%ebp)
 241:	68 b8 0b 00 00       	push   $0xbb8
 246:	6a 01                	push   $0x1
 248:	e8 cb 04 00 00       	call   718 <printf>
 24d:	83 c4 10             	add    $0x10,%esp
      sleep(1);
 250:	83 ec 0c             	sub    $0xc,%esp
 253:	6a 01                	push   $0x1
 255:	e8 ba 03 00 00       	call   614 <sleep>
 25a:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < 3; i++) {
 25d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 261:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
 265:	0f 8e 58 ff ff ff    	jle    1c3 <run_mlfq_with_tracking_and_boosting+0x31>
    }
  }

  // 자식 다 만든 이후에 정책 변경
  printf(1, "[DEBUG] Setting MLFQ policy now...\n");
 26b:	83 ec 08             	sub    $0x8,%esp
 26e:	68 e0 0b 00 00       	push   $0xbe0
 273:	6a 01                	push   $0x1
 275:	e8 9e 04 00 00       	call   718 <printf>
 27a:	83 c4 10             	add    $0x10,%esp
  setSchedPolicy(1);
 27d:	83 ec 0c             	sub    $0xc,%esp
 280:	6a 01                	push   $0x1
 282:	e8 a5 03 00 00       	call   62c <setSchedPolicy>
 287:	83 c4 10             	add    $0x10,%esp
  sleep(1);
 28a:	83 ec 0c             	sub    $0xc,%esp
 28d:	6a 01                	push   $0x1
 28f:	e8 80 03 00 00       	call   614 <sleep>
 294:	83 c4 10             	add    $0x10,%esp

  int sched = getSchedPolicy();
 297:	e8 a0 03 00 00       	call   63c <getSchedPolicy>
 29c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  printf(1, "[DEBUG] Current sched_policy = %d\n", sched);
 29f:	83 ec 04             	sub    $0x4,%esp
 2a2:	ff 75 ec             	push   -0x14(%ebp)
 2a5:	68 04 0c 00 00       	push   $0xc04
 2aa:	6a 01                	push   $0x1
 2ac:	e8 67 04 00 00       	call   718 <printf>
 2b1:	83 c4 10             	add    $0x10,%esp
  sleep(1);
 2b4:	83 ec 0c             	sub    $0xc,%esp
 2b7:	6a 01                	push   $0x1
 2b9:	e8 56 03 00 00       	call   614 <sleep>
 2be:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < 3; i++) wait();
 2c1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 2c8:	eb 09                	jmp    2d3 <run_mlfq_with_tracking_and_boosting+0x141>
 2ca:	e8 bd 02 00 00       	call   58c <wait>
 2cf:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 2d3:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
 2d7:	7e f1                	jle    2ca <run_mlfq_with_tracking_and_boosting+0x138>

  print_stat();
 2d9:	e8 56 fd ff ff       	call   34 <print_stat>
}
 2de:	90                   	nop
 2df:	c9                   	leave
 2e0:	c3                   	ret

000002e1 <main>:

int main(void) {
 2e1:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 2e5:	83 e4 f0             	and    $0xfffffff0,%esp
 2e8:	ff 71 fc             	push   -0x4(%ecx)
 2eb:	55                   	push   %ebp
 2ec:	89 e5                	mov    %esp,%ebp
 2ee:	51                   	push   %ecx
 2ef:	83 ec 04             	sub    $0x4,%esp
  printf(1, "\n===== [POLICY 1: MLFQ with tracking & boosting] =====\n");
 2f2:	83 ec 08             	sub    $0x8,%esp
 2f5:	68 28 0c 00 00       	push   $0xc28
 2fa:	6a 01                	push   $0x1
 2fc:	e8 17 04 00 00       	call   718 <printf>
 301:	83 c4 10             	add    $0x10,%esp
  run_mlfq_with_tracking_and_boosting();
 304:	e8 89 fe ff ff       	call   192 <run_mlfq_with_tracking_and_boosting>

  printf(1, "\n===== [POLICY 1: exit] =====\n");
 309:	83 ec 08             	sub    $0x8,%esp
 30c:	68 60 0c 00 00       	push   $0xc60
 311:	6a 01                	push   $0x1
 313:	e8 00 04 00 00       	call   718 <printf>
 318:	83 c4 10             	add    $0x10,%esp
  sleep(1);
 31b:	83 ec 0c             	sub    $0xc,%esp
 31e:	6a 01                	push   $0x1
 320:	e8 ef 02 00 00       	call   614 <sleep>
 325:	83 c4 10             	add    $0x10,%esp
  exit();
 328:	e8 57 02 00 00       	call   584 <exit>

0000032d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 32d:	55                   	push   %ebp
 32e:	89 e5                	mov    %esp,%ebp
 330:	57                   	push   %edi
 331:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 332:	8b 4d 08             	mov    0x8(%ebp),%ecx
 335:	8b 55 10             	mov    0x10(%ebp),%edx
 338:	8b 45 0c             	mov    0xc(%ebp),%eax
 33b:	89 cb                	mov    %ecx,%ebx
 33d:	89 df                	mov    %ebx,%edi
 33f:	89 d1                	mov    %edx,%ecx
 341:	fc                   	cld
 342:	f3 aa                	rep stos %al,%es:(%edi)
 344:	89 ca                	mov    %ecx,%edx
 346:	89 fb                	mov    %edi,%ebx
 348:	89 5d 08             	mov    %ebx,0x8(%ebp)
 34b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 34e:	90                   	nop
 34f:	5b                   	pop    %ebx
 350:	5f                   	pop    %edi
 351:	5d                   	pop    %ebp
 352:	c3                   	ret

00000353 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 353:	55                   	push   %ebp
 354:	89 e5                	mov    %esp,%ebp
 356:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 359:	8b 45 08             	mov    0x8(%ebp),%eax
 35c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 35f:	90                   	nop
 360:	8b 55 0c             	mov    0xc(%ebp),%edx
 363:	8d 42 01             	lea    0x1(%edx),%eax
 366:	89 45 0c             	mov    %eax,0xc(%ebp)
 369:	8b 45 08             	mov    0x8(%ebp),%eax
 36c:	8d 48 01             	lea    0x1(%eax),%ecx
 36f:	89 4d 08             	mov    %ecx,0x8(%ebp)
 372:	0f b6 12             	movzbl (%edx),%edx
 375:	88 10                	mov    %dl,(%eax)
 377:	0f b6 00             	movzbl (%eax),%eax
 37a:	84 c0                	test   %al,%al
 37c:	75 e2                	jne    360 <strcpy+0xd>
    ;
  return os;
 37e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 381:	c9                   	leave
 382:	c3                   	ret

00000383 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 383:	55                   	push   %ebp
 384:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 386:	eb 08                	jmp    390 <strcmp+0xd>
    p++, q++;
 388:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 38c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 390:	8b 45 08             	mov    0x8(%ebp),%eax
 393:	0f b6 00             	movzbl (%eax),%eax
 396:	84 c0                	test   %al,%al
 398:	74 10                	je     3aa <strcmp+0x27>
 39a:	8b 45 08             	mov    0x8(%ebp),%eax
 39d:	0f b6 10             	movzbl (%eax),%edx
 3a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a3:	0f b6 00             	movzbl (%eax),%eax
 3a6:	38 c2                	cmp    %al,%dl
 3a8:	74 de                	je     388 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 3aa:	8b 45 08             	mov    0x8(%ebp),%eax
 3ad:	0f b6 00             	movzbl (%eax),%eax
 3b0:	0f b6 d0             	movzbl %al,%edx
 3b3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b6:	0f b6 00             	movzbl (%eax),%eax
 3b9:	0f b6 c0             	movzbl %al,%eax
 3bc:	29 c2                	sub    %eax,%edx
 3be:	89 d0                	mov    %edx,%eax
}
 3c0:	5d                   	pop    %ebp
 3c1:	c3                   	ret

000003c2 <strlen>:

uint
strlen(char *s)
{
 3c2:	55                   	push   %ebp
 3c3:	89 e5                	mov    %esp,%ebp
 3c5:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3c8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3cf:	eb 04                	jmp    3d5 <strlen+0x13>
 3d1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3d5:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3d8:	8b 45 08             	mov    0x8(%ebp),%eax
 3db:	01 d0                	add    %edx,%eax
 3dd:	0f b6 00             	movzbl (%eax),%eax
 3e0:	84 c0                	test   %al,%al
 3e2:	75 ed                	jne    3d1 <strlen+0xf>
    ;
  return n;
 3e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3e7:	c9                   	leave
 3e8:	c3                   	ret

000003e9 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3e9:	55                   	push   %ebp
 3ea:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3ec:	8b 45 10             	mov    0x10(%ebp),%eax
 3ef:	50                   	push   %eax
 3f0:	ff 75 0c             	push   0xc(%ebp)
 3f3:	ff 75 08             	push   0x8(%ebp)
 3f6:	e8 32 ff ff ff       	call   32d <stosb>
 3fb:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3fe:	8b 45 08             	mov    0x8(%ebp),%eax
}
 401:	c9                   	leave
 402:	c3                   	ret

00000403 <strchr>:

char*
strchr(const char *s, char c)
{
 403:	55                   	push   %ebp
 404:	89 e5                	mov    %esp,%ebp
 406:	83 ec 04             	sub    $0x4,%esp
 409:	8b 45 0c             	mov    0xc(%ebp),%eax
 40c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 40f:	eb 14                	jmp    425 <strchr+0x22>
    if(*s == c)
 411:	8b 45 08             	mov    0x8(%ebp),%eax
 414:	0f b6 00             	movzbl (%eax),%eax
 417:	38 45 fc             	cmp    %al,-0x4(%ebp)
 41a:	75 05                	jne    421 <strchr+0x1e>
      return (char*)s;
 41c:	8b 45 08             	mov    0x8(%ebp),%eax
 41f:	eb 13                	jmp    434 <strchr+0x31>
  for(; *s; s++)
 421:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 425:	8b 45 08             	mov    0x8(%ebp),%eax
 428:	0f b6 00             	movzbl (%eax),%eax
 42b:	84 c0                	test   %al,%al
 42d:	75 e2                	jne    411 <strchr+0xe>
  return 0;
 42f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 434:	c9                   	leave
 435:	c3                   	ret

00000436 <gets>:

char*
gets(char *buf, int max)
{
 436:	55                   	push   %ebp
 437:	89 e5                	mov    %esp,%ebp
 439:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 43c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 443:	eb 42                	jmp    487 <gets+0x51>
    cc = read(0, &c, 1);
 445:	83 ec 04             	sub    $0x4,%esp
 448:	6a 01                	push   $0x1
 44a:	8d 45 ef             	lea    -0x11(%ebp),%eax
 44d:	50                   	push   %eax
 44e:	6a 00                	push   $0x0
 450:	e8 47 01 00 00       	call   59c <read>
 455:	83 c4 10             	add    $0x10,%esp
 458:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 45b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 45f:	7e 33                	jle    494 <gets+0x5e>
      break;
    buf[i++] = c;
 461:	8b 45 f4             	mov    -0xc(%ebp),%eax
 464:	8d 50 01             	lea    0x1(%eax),%edx
 467:	89 55 f4             	mov    %edx,-0xc(%ebp)
 46a:	89 c2                	mov    %eax,%edx
 46c:	8b 45 08             	mov    0x8(%ebp),%eax
 46f:	01 c2                	add    %eax,%edx
 471:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 475:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 477:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 47b:	3c 0a                	cmp    $0xa,%al
 47d:	74 16                	je     495 <gets+0x5f>
 47f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 483:	3c 0d                	cmp    $0xd,%al
 485:	74 0e                	je     495 <gets+0x5f>
  for(i=0; i+1 < max; ){
 487:	8b 45 f4             	mov    -0xc(%ebp),%eax
 48a:	83 c0 01             	add    $0x1,%eax
 48d:	39 45 0c             	cmp    %eax,0xc(%ebp)
 490:	7f b3                	jg     445 <gets+0xf>
 492:	eb 01                	jmp    495 <gets+0x5f>
      break;
 494:	90                   	nop
      break;
  }
  buf[i] = '\0';
 495:	8b 55 f4             	mov    -0xc(%ebp),%edx
 498:	8b 45 08             	mov    0x8(%ebp),%eax
 49b:	01 d0                	add    %edx,%eax
 49d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4a3:	c9                   	leave
 4a4:	c3                   	ret

000004a5 <stat>:

int
stat(char *n, struct stat *st)
{
 4a5:	55                   	push   %ebp
 4a6:	89 e5                	mov    %esp,%ebp
 4a8:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4ab:	83 ec 08             	sub    $0x8,%esp
 4ae:	6a 00                	push   $0x0
 4b0:	ff 75 08             	push   0x8(%ebp)
 4b3:	e8 0c 01 00 00       	call   5c4 <open>
 4b8:	83 c4 10             	add    $0x10,%esp
 4bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4c2:	79 07                	jns    4cb <stat+0x26>
    return -1;
 4c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4c9:	eb 25                	jmp    4f0 <stat+0x4b>
  r = fstat(fd, st);
 4cb:	83 ec 08             	sub    $0x8,%esp
 4ce:	ff 75 0c             	push   0xc(%ebp)
 4d1:	ff 75 f4             	push   -0xc(%ebp)
 4d4:	e8 03 01 00 00       	call   5dc <fstat>
 4d9:	83 c4 10             	add    $0x10,%esp
 4dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4df:	83 ec 0c             	sub    $0xc,%esp
 4e2:	ff 75 f4             	push   -0xc(%ebp)
 4e5:	e8 c2 00 00 00       	call   5ac <close>
 4ea:	83 c4 10             	add    $0x10,%esp
  return r;
 4ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4f0:	c9                   	leave
 4f1:	c3                   	ret

000004f2 <atoi>:

int
atoi(const char *s)
{
 4f2:	55                   	push   %ebp
 4f3:	89 e5                	mov    %esp,%ebp
 4f5:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4f8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4ff:	eb 25                	jmp    526 <atoi+0x34>
    n = n*10 + *s++ - '0';
 501:	8b 55 fc             	mov    -0x4(%ebp),%edx
 504:	89 d0                	mov    %edx,%eax
 506:	c1 e0 02             	shl    $0x2,%eax
 509:	01 d0                	add    %edx,%eax
 50b:	01 c0                	add    %eax,%eax
 50d:	89 c1                	mov    %eax,%ecx
 50f:	8b 45 08             	mov    0x8(%ebp),%eax
 512:	8d 50 01             	lea    0x1(%eax),%edx
 515:	89 55 08             	mov    %edx,0x8(%ebp)
 518:	0f b6 00             	movzbl (%eax),%eax
 51b:	0f be c0             	movsbl %al,%eax
 51e:	01 c8                	add    %ecx,%eax
 520:	83 e8 30             	sub    $0x30,%eax
 523:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 526:	8b 45 08             	mov    0x8(%ebp),%eax
 529:	0f b6 00             	movzbl (%eax),%eax
 52c:	3c 2f                	cmp    $0x2f,%al
 52e:	7e 0a                	jle    53a <atoi+0x48>
 530:	8b 45 08             	mov    0x8(%ebp),%eax
 533:	0f b6 00             	movzbl (%eax),%eax
 536:	3c 39                	cmp    $0x39,%al
 538:	7e c7                	jle    501 <atoi+0xf>
  return n;
 53a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 53d:	c9                   	leave
 53e:	c3                   	ret

0000053f <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 53f:	55                   	push   %ebp
 540:	89 e5                	mov    %esp,%ebp
 542:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 545:	8b 45 08             	mov    0x8(%ebp),%eax
 548:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 54b:	8b 45 0c             	mov    0xc(%ebp),%eax
 54e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 551:	eb 17                	jmp    56a <memmove+0x2b>
    *dst++ = *src++;
 553:	8b 55 f8             	mov    -0x8(%ebp),%edx
 556:	8d 42 01             	lea    0x1(%edx),%eax
 559:	89 45 f8             	mov    %eax,-0x8(%ebp)
 55c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 55f:	8d 48 01             	lea    0x1(%eax),%ecx
 562:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 565:	0f b6 12             	movzbl (%edx),%edx
 568:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 56a:	8b 45 10             	mov    0x10(%ebp),%eax
 56d:	8d 50 ff             	lea    -0x1(%eax),%edx
 570:	89 55 10             	mov    %edx,0x10(%ebp)
 573:	85 c0                	test   %eax,%eax
 575:	7f dc                	jg     553 <memmove+0x14>
  return vdst;
 577:	8b 45 08             	mov    0x8(%ebp),%eax
}
 57a:	c9                   	leave
 57b:	c3                   	ret

0000057c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 57c:	b8 01 00 00 00       	mov    $0x1,%eax
 581:	cd 40                	int    $0x40
 583:	c3                   	ret

00000584 <exit>:
SYSCALL(exit)
 584:	b8 02 00 00 00       	mov    $0x2,%eax
 589:	cd 40                	int    $0x40
 58b:	c3                   	ret

0000058c <wait>:
SYSCALL(wait)
 58c:	b8 03 00 00 00       	mov    $0x3,%eax
 591:	cd 40                	int    $0x40
 593:	c3                   	ret

00000594 <pipe>:
SYSCALL(pipe)
 594:	b8 04 00 00 00       	mov    $0x4,%eax
 599:	cd 40                	int    $0x40
 59b:	c3                   	ret

0000059c <read>:
SYSCALL(read)
 59c:	b8 05 00 00 00       	mov    $0x5,%eax
 5a1:	cd 40                	int    $0x40
 5a3:	c3                   	ret

000005a4 <write>:
SYSCALL(write)
 5a4:	b8 10 00 00 00       	mov    $0x10,%eax
 5a9:	cd 40                	int    $0x40
 5ab:	c3                   	ret

000005ac <close>:
SYSCALL(close)
 5ac:	b8 15 00 00 00       	mov    $0x15,%eax
 5b1:	cd 40                	int    $0x40
 5b3:	c3                   	ret

000005b4 <kill>:
SYSCALL(kill)
 5b4:	b8 06 00 00 00       	mov    $0x6,%eax
 5b9:	cd 40                	int    $0x40
 5bb:	c3                   	ret

000005bc <exec>:
SYSCALL(exec)
 5bc:	b8 07 00 00 00       	mov    $0x7,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret

000005c4 <open>:
SYSCALL(open)
 5c4:	b8 0f 00 00 00       	mov    $0xf,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret

000005cc <mknod>:
SYSCALL(mknod)
 5cc:	b8 11 00 00 00       	mov    $0x11,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret

000005d4 <unlink>:
SYSCALL(unlink)
 5d4:	b8 12 00 00 00       	mov    $0x12,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret

000005dc <fstat>:
SYSCALL(fstat)
 5dc:	b8 08 00 00 00       	mov    $0x8,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret

000005e4 <link>:
SYSCALL(link)
 5e4:	b8 13 00 00 00       	mov    $0x13,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret

000005ec <mkdir>:
SYSCALL(mkdir)
 5ec:	b8 14 00 00 00       	mov    $0x14,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret

000005f4 <chdir>:
SYSCALL(chdir)
 5f4:	b8 09 00 00 00       	mov    $0x9,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret

000005fc <dup>:
SYSCALL(dup)
 5fc:	b8 0a 00 00 00       	mov    $0xa,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret

00000604 <getpid>:
SYSCALL(getpid)
 604:	b8 0b 00 00 00       	mov    $0xb,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret

0000060c <sbrk>:
SYSCALL(sbrk)
 60c:	b8 0c 00 00 00       	mov    $0xc,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret

00000614 <sleep>:
SYSCALL(sleep)
 614:	b8 0d 00 00 00       	mov    $0xd,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret

0000061c <uptime>:
SYSCALL(uptime)
 61c:	b8 0e 00 00 00       	mov    $0xe,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret

00000624 <getpinfo>:

SYSCALL(getpinfo)
 624:	b8 16 00 00 00       	mov    $0x16,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret

0000062c <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 62c:	b8 17 00 00 00       	mov    $0x17,%eax
 631:	cd 40                	int    $0x40
 633:	c3                   	ret

00000634 <yield>:
SYSCALL(yield)
 634:	b8 18 00 00 00       	mov    $0x18,%eax
 639:	cd 40                	int    $0x40
 63b:	c3                   	ret

0000063c <getSchedPolicy>:
 63c:	b8 19 00 00 00       	mov    $0x19,%eax
 641:	cd 40                	int    $0x40
 643:	c3                   	ret

00000644 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 644:	55                   	push   %ebp
 645:	89 e5                	mov    %esp,%ebp
 647:	83 ec 18             	sub    $0x18,%esp
 64a:	8b 45 0c             	mov    0xc(%ebp),%eax
 64d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 650:	83 ec 04             	sub    $0x4,%esp
 653:	6a 01                	push   $0x1
 655:	8d 45 f4             	lea    -0xc(%ebp),%eax
 658:	50                   	push   %eax
 659:	ff 75 08             	push   0x8(%ebp)
 65c:	e8 43 ff ff ff       	call   5a4 <write>
 661:	83 c4 10             	add    $0x10,%esp
}
 664:	90                   	nop
 665:	c9                   	leave
 666:	c3                   	ret

00000667 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 667:	55                   	push   %ebp
 668:	89 e5                	mov    %esp,%ebp
 66a:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 66d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 674:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 678:	74 17                	je     691 <printint+0x2a>
 67a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 67e:	79 11                	jns    691 <printint+0x2a>
    neg = 1;
 680:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 687:	8b 45 0c             	mov    0xc(%ebp),%eax
 68a:	f7 d8                	neg    %eax
 68c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 68f:	eb 06                	jmp    697 <printint+0x30>
  } else {
    x = xx;
 691:	8b 45 0c             	mov    0xc(%ebp),%eax
 694:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 697:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 69e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6a4:	ba 00 00 00 00       	mov    $0x0,%edx
 6a9:	f7 f1                	div    %ecx
 6ab:	89 d1                	mov    %edx,%ecx
 6ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b0:	8d 50 01             	lea    0x1(%eax),%edx
 6b3:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6b6:	0f b6 91 88 0c 00 00 	movzbl 0xc88(%ecx),%edx
 6bd:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6c7:	ba 00 00 00 00       	mov    $0x0,%edx
 6cc:	f7 f1                	div    %ecx
 6ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6d1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6d5:	75 c7                	jne    69e <printint+0x37>
  if(neg)
 6d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6db:	74 2d                	je     70a <printint+0xa3>
    buf[i++] = '-';
 6dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e0:	8d 50 01             	lea    0x1(%eax),%edx
 6e3:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6e6:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6eb:	eb 1d                	jmp    70a <printint+0xa3>
    putc(fd, buf[i]);
 6ed:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f3:	01 d0                	add    %edx,%eax
 6f5:	0f b6 00             	movzbl (%eax),%eax
 6f8:	0f be c0             	movsbl %al,%eax
 6fb:	83 ec 08             	sub    $0x8,%esp
 6fe:	50                   	push   %eax
 6ff:	ff 75 08             	push   0x8(%ebp)
 702:	e8 3d ff ff ff       	call   644 <putc>
 707:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 70a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 70e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 712:	79 d9                	jns    6ed <printint+0x86>
}
 714:	90                   	nop
 715:	90                   	nop
 716:	c9                   	leave
 717:	c3                   	ret

00000718 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 718:	55                   	push   %ebp
 719:	89 e5                	mov    %esp,%ebp
 71b:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 71e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 725:	8d 45 0c             	lea    0xc(%ebp),%eax
 728:	83 c0 04             	add    $0x4,%eax
 72b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 72e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 735:	e9 59 01 00 00       	jmp    893 <printf+0x17b>
    c = fmt[i] & 0xff;
 73a:	8b 55 0c             	mov    0xc(%ebp),%edx
 73d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 740:	01 d0                	add    %edx,%eax
 742:	0f b6 00             	movzbl (%eax),%eax
 745:	0f be c0             	movsbl %al,%eax
 748:	25 ff 00 00 00       	and    $0xff,%eax
 74d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 750:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 754:	75 2c                	jne    782 <printf+0x6a>
      if(c == '%'){
 756:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 75a:	75 0c                	jne    768 <printf+0x50>
        state = '%';
 75c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 763:	e9 27 01 00 00       	jmp    88f <printf+0x177>
      } else {
        putc(fd, c);
 768:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 76b:	0f be c0             	movsbl %al,%eax
 76e:	83 ec 08             	sub    $0x8,%esp
 771:	50                   	push   %eax
 772:	ff 75 08             	push   0x8(%ebp)
 775:	e8 ca fe ff ff       	call   644 <putc>
 77a:	83 c4 10             	add    $0x10,%esp
 77d:	e9 0d 01 00 00       	jmp    88f <printf+0x177>
      }
    } else if(state == '%'){
 782:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 786:	0f 85 03 01 00 00    	jne    88f <printf+0x177>
      if(c == 'd'){
 78c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 790:	75 1e                	jne    7b0 <printf+0x98>
        printint(fd, *ap, 10, 1);
 792:	8b 45 e8             	mov    -0x18(%ebp),%eax
 795:	8b 00                	mov    (%eax),%eax
 797:	6a 01                	push   $0x1
 799:	6a 0a                	push   $0xa
 79b:	50                   	push   %eax
 79c:	ff 75 08             	push   0x8(%ebp)
 79f:	e8 c3 fe ff ff       	call   667 <printint>
 7a4:	83 c4 10             	add    $0x10,%esp
        ap++;
 7a7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ab:	e9 d8 00 00 00       	jmp    888 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7b0:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7b4:	74 06                	je     7bc <printf+0xa4>
 7b6:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7ba:	75 1e                	jne    7da <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7bf:	8b 00                	mov    (%eax),%eax
 7c1:	6a 00                	push   $0x0
 7c3:	6a 10                	push   $0x10
 7c5:	50                   	push   %eax
 7c6:	ff 75 08             	push   0x8(%ebp)
 7c9:	e8 99 fe ff ff       	call   667 <printint>
 7ce:	83 c4 10             	add    $0x10,%esp
        ap++;
 7d1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7d5:	e9 ae 00 00 00       	jmp    888 <printf+0x170>
      } else if(c == 's'){
 7da:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7de:	75 43                	jne    823 <printf+0x10b>
        s = (char*)*ap;
 7e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7e3:	8b 00                	mov    (%eax),%eax
 7e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7e8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7f0:	75 25                	jne    817 <printf+0xff>
          s = "(null)";
 7f2:	c7 45 f4 7f 0c 00 00 	movl   $0xc7f,-0xc(%ebp)
        while(*s != 0){
 7f9:	eb 1c                	jmp    817 <printf+0xff>
          putc(fd, *s);
 7fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fe:	0f b6 00             	movzbl (%eax),%eax
 801:	0f be c0             	movsbl %al,%eax
 804:	83 ec 08             	sub    $0x8,%esp
 807:	50                   	push   %eax
 808:	ff 75 08             	push   0x8(%ebp)
 80b:	e8 34 fe ff ff       	call   644 <putc>
 810:	83 c4 10             	add    $0x10,%esp
          s++;
 813:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 817:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81a:	0f b6 00             	movzbl (%eax),%eax
 81d:	84 c0                	test   %al,%al
 81f:	75 da                	jne    7fb <printf+0xe3>
 821:	eb 65                	jmp    888 <printf+0x170>
        }
      } else if(c == 'c'){
 823:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 827:	75 1d                	jne    846 <printf+0x12e>
        putc(fd, *ap);
 829:	8b 45 e8             	mov    -0x18(%ebp),%eax
 82c:	8b 00                	mov    (%eax),%eax
 82e:	0f be c0             	movsbl %al,%eax
 831:	83 ec 08             	sub    $0x8,%esp
 834:	50                   	push   %eax
 835:	ff 75 08             	push   0x8(%ebp)
 838:	e8 07 fe ff ff       	call   644 <putc>
 83d:	83 c4 10             	add    $0x10,%esp
        ap++;
 840:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 844:	eb 42                	jmp    888 <printf+0x170>
      } else if(c == '%'){
 846:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 84a:	75 17                	jne    863 <printf+0x14b>
        putc(fd, c);
 84c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 84f:	0f be c0             	movsbl %al,%eax
 852:	83 ec 08             	sub    $0x8,%esp
 855:	50                   	push   %eax
 856:	ff 75 08             	push   0x8(%ebp)
 859:	e8 e6 fd ff ff       	call   644 <putc>
 85e:	83 c4 10             	add    $0x10,%esp
 861:	eb 25                	jmp    888 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 863:	83 ec 08             	sub    $0x8,%esp
 866:	6a 25                	push   $0x25
 868:	ff 75 08             	push   0x8(%ebp)
 86b:	e8 d4 fd ff ff       	call   644 <putc>
 870:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 873:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 876:	0f be c0             	movsbl %al,%eax
 879:	83 ec 08             	sub    $0x8,%esp
 87c:	50                   	push   %eax
 87d:	ff 75 08             	push   0x8(%ebp)
 880:	e8 bf fd ff ff       	call   644 <putc>
 885:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 888:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 88f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 893:	8b 55 0c             	mov    0xc(%ebp),%edx
 896:	8b 45 f0             	mov    -0x10(%ebp),%eax
 899:	01 d0                	add    %edx,%eax
 89b:	0f b6 00             	movzbl (%eax),%eax
 89e:	84 c0                	test   %al,%al
 8a0:	0f 85 94 fe ff ff    	jne    73a <printf+0x22>
    }
  }
}
 8a6:	90                   	nop
 8a7:	90                   	nop
 8a8:	c9                   	leave
 8a9:	c3                   	ret

000008aa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8aa:	55                   	push   %ebp
 8ab:	89 e5                	mov    %esp,%ebp
 8ad:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8b0:	8b 45 08             	mov    0x8(%ebp),%eax
 8b3:	83 e8 08             	sub    $0x8,%eax
 8b6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b9:	a1 a4 0c 00 00       	mov    0xca4,%eax
 8be:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8c1:	eb 24                	jmp    8e7 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c6:	8b 00                	mov    (%eax),%eax
 8c8:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8cb:	72 12                	jb     8df <free+0x35>
 8cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d0:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8d3:	72 24                	jb     8f9 <free+0x4f>
 8d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d8:	8b 00                	mov    (%eax),%eax
 8da:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8dd:	72 1a                	jb     8f9 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e2:	8b 00                	mov    (%eax),%eax
 8e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ea:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8ed:	73 d4                	jae    8c3 <free+0x19>
 8ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f2:	8b 00                	mov    (%eax),%eax
 8f4:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8f7:	73 ca                	jae    8c3 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fc:	8b 40 04             	mov    0x4(%eax),%eax
 8ff:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 906:	8b 45 f8             	mov    -0x8(%ebp),%eax
 909:	01 c2                	add    %eax,%edx
 90b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90e:	8b 00                	mov    (%eax),%eax
 910:	39 c2                	cmp    %eax,%edx
 912:	75 24                	jne    938 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 914:	8b 45 f8             	mov    -0x8(%ebp),%eax
 917:	8b 50 04             	mov    0x4(%eax),%edx
 91a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91d:	8b 00                	mov    (%eax),%eax
 91f:	8b 40 04             	mov    0x4(%eax),%eax
 922:	01 c2                	add    %eax,%edx
 924:	8b 45 f8             	mov    -0x8(%ebp),%eax
 927:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 92a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92d:	8b 00                	mov    (%eax),%eax
 92f:	8b 10                	mov    (%eax),%edx
 931:	8b 45 f8             	mov    -0x8(%ebp),%eax
 934:	89 10                	mov    %edx,(%eax)
 936:	eb 0a                	jmp    942 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 938:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93b:	8b 10                	mov    (%eax),%edx
 93d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 940:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 942:	8b 45 fc             	mov    -0x4(%ebp),%eax
 945:	8b 40 04             	mov    0x4(%eax),%eax
 948:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 94f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 952:	01 d0                	add    %edx,%eax
 954:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 957:	75 20                	jne    979 <free+0xcf>
    p->s.size += bp->s.size;
 959:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95c:	8b 50 04             	mov    0x4(%eax),%edx
 95f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 962:	8b 40 04             	mov    0x4(%eax),%eax
 965:	01 c2                	add    %eax,%edx
 967:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 96d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 970:	8b 10                	mov    (%eax),%edx
 972:	8b 45 fc             	mov    -0x4(%ebp),%eax
 975:	89 10                	mov    %edx,(%eax)
 977:	eb 08                	jmp    981 <free+0xd7>
  } else
    p->s.ptr = bp;
 979:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 97f:	89 10                	mov    %edx,(%eax)
  freep = p;
 981:	8b 45 fc             	mov    -0x4(%ebp),%eax
 984:	a3 a4 0c 00 00       	mov    %eax,0xca4
}
 989:	90                   	nop
 98a:	c9                   	leave
 98b:	c3                   	ret

0000098c <morecore>:

static Header*
morecore(uint nu)
{
 98c:	55                   	push   %ebp
 98d:	89 e5                	mov    %esp,%ebp
 98f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 992:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 999:	77 07                	ja     9a2 <morecore+0x16>
    nu = 4096;
 99b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9a2:	8b 45 08             	mov    0x8(%ebp),%eax
 9a5:	c1 e0 03             	shl    $0x3,%eax
 9a8:	83 ec 0c             	sub    $0xc,%esp
 9ab:	50                   	push   %eax
 9ac:	e8 5b fc ff ff       	call   60c <sbrk>
 9b1:	83 c4 10             	add    $0x10,%esp
 9b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9b7:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9bb:	75 07                	jne    9c4 <morecore+0x38>
    return 0;
 9bd:	b8 00 00 00 00       	mov    $0x0,%eax
 9c2:	eb 26                	jmp    9ea <morecore+0x5e>
  hp = (Header*)p;
 9c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9cd:	8b 55 08             	mov    0x8(%ebp),%edx
 9d0:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d6:	83 c0 08             	add    $0x8,%eax
 9d9:	83 ec 0c             	sub    $0xc,%esp
 9dc:	50                   	push   %eax
 9dd:	e8 c8 fe ff ff       	call   8aa <free>
 9e2:	83 c4 10             	add    $0x10,%esp
  return freep;
 9e5:	a1 a4 0c 00 00       	mov    0xca4,%eax
}
 9ea:	c9                   	leave
 9eb:	c3                   	ret

000009ec <malloc>:

void*
malloc(uint nbytes)
{
 9ec:	55                   	push   %ebp
 9ed:	89 e5                	mov    %esp,%ebp
 9ef:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9f2:	8b 45 08             	mov    0x8(%ebp),%eax
 9f5:	83 c0 07             	add    $0x7,%eax
 9f8:	c1 e8 03             	shr    $0x3,%eax
 9fb:	83 c0 01             	add    $0x1,%eax
 9fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a01:	a1 a4 0c 00 00       	mov    0xca4,%eax
 a06:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a09:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a0d:	75 23                	jne    a32 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a0f:	c7 45 f0 9c 0c 00 00 	movl   $0xc9c,-0x10(%ebp)
 a16:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a19:	a3 a4 0c 00 00       	mov    %eax,0xca4
 a1e:	a1 a4 0c 00 00       	mov    0xca4,%eax
 a23:	a3 9c 0c 00 00       	mov    %eax,0xc9c
    base.s.size = 0;
 a28:	c7 05 a0 0c 00 00 00 	movl   $0x0,0xca0
 a2f:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a35:	8b 00                	mov    (%eax),%eax
 a37:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3d:	8b 40 04             	mov    0x4(%eax),%eax
 a40:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a43:	72 4d                	jb     a92 <malloc+0xa6>
      if(p->s.size == nunits)
 a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a48:	8b 40 04             	mov    0x4(%eax),%eax
 a4b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a4e:	75 0c                	jne    a5c <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a53:	8b 10                	mov    (%eax),%edx
 a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a58:	89 10                	mov    %edx,(%eax)
 a5a:	eb 26                	jmp    a82 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5f:	8b 40 04             	mov    0x4(%eax),%eax
 a62:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a65:	89 c2                	mov    %eax,%edx
 a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a70:	8b 40 04             	mov    0x4(%eax),%eax
 a73:	c1 e0 03             	shl    $0x3,%eax
 a76:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7c:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a7f:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a85:	a3 a4 0c 00 00       	mov    %eax,0xca4
      return (void*)(p + 1);
 a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8d:	83 c0 08             	add    $0x8,%eax
 a90:	eb 3b                	jmp    acd <malloc+0xe1>
    }
    if(p == freep)
 a92:	a1 a4 0c 00 00       	mov    0xca4,%eax
 a97:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a9a:	75 1e                	jne    aba <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a9c:	83 ec 0c             	sub    $0xc,%esp
 a9f:	ff 75 ec             	push   -0x14(%ebp)
 aa2:	e8 e5 fe ff ff       	call   98c <morecore>
 aa7:	83 c4 10             	add    $0x10,%esp
 aaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
 aad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ab1:	75 07                	jne    aba <malloc+0xce>
        return 0;
 ab3:	b8 00 00 00 00       	mov    $0x0,%eax
 ab8:	eb 13                	jmp    acd <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac3:	8b 00                	mov    (%eax),%eax
 ac5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ac8:	e9 6d ff ff ff       	jmp    a3a <malloc+0x4e>
  }
}
 acd:	c9                   	leave
 ace:	c3                   	ret
