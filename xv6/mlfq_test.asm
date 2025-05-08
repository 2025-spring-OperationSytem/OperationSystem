
_mlfq_test:     file format elf32-i386


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
  for (i = 0; i < n; i++){
  11:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  18:	eb 11                	jmp    2b <workload+0x2b>
    j += i * j + 1;
  1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1d:	0f af 45 f8          	imul   -0x8(%ebp),%eax
  21:	83 c0 01             	add    $0x1,%eax
  24:	01 45 f8             	add    %eax,-0x8(%ebp)
  for (i = 0; i < n; i++){
  27:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  2e:	3b 45 08             	cmp    0x8(%ebp),%eax
  31:	7c e7                	jl     1a <workload+0x1a>
    //if (i % 1000000 == 0) yield(); // 주기적으로 CPU 양보
  }
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
  52:	e8 fe 05 00 00       	call   655 <getpinfo>
  57:	83 c4 10             	add    $0x10,%esp

  printf(1, "\n[RESULT] Process Statistics\n");
  5a:	83 ec 08             	sub    $0x8,%esp
  5d:	68 18 0b 00 00       	push   $0xb18
  62:	6a 01                	push   $0x1
  64:	e8 e8 06 00 00       	call   751 <printf>
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
 170:	68 38 0b 00 00       	push   $0xb38
 175:	6a 01                	push   $0x1
 177:	e8 d5 05 00 00       	call   751 <printf>
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

00000197 <run_mlfq_with_tracking_and_boosting>:

void run_mlfq_with_tracking_and_boosting() {
 197:	f3 0f 1e fb          	endbr32
 19b:	55                   	push   %ebp
 19c:	89 e5                	mov    %esp,%ebp
 19e:	83 ec 18             	sub    $0x18,%esp
  printf(1, "[DEBUG] Entered run_mlfq_with_tracking_and_boosting()\n");
 1a1:	83 ec 08             	sub    $0x8,%esp
 1a4:	68 94 0b 00 00       	push   $0xb94
 1a9:	6a 01                	push   $0x1
 1ab:	e8 a1 05 00 00       	call   751 <printf>
 1b0:	83 c4 10             	add    $0x10,%esp
  sleep(1); 
 1b3:	83 ec 0c             	sub    $0xc,%esp
 1b6:	6a 01                	push   $0x1
 1b8:	e8 88 04 00 00       	call   645 <sleep>
 1bd:	83 c4 10             	add    $0x10,%esp
  
  for (int i = 0; i < 3; i++) {
 1c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1c7:	e9 9e 00 00 00       	jmp    26a <run_mlfq_with_tracking_and_boosting+0xd3>
    int pid = fork();
 1cc:	e8 dc 03 00 00       	call   5ad <fork>
 1d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (pid < 0) {
 1d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 1d8:	79 22                	jns    1fc <run_mlfq_with_tracking_and_boosting+0x65>
      printf(1, "[ERROR] fork failed at i=%d\n", i);
 1da:	83 ec 04             	sub    $0x4,%esp
 1dd:	ff 75 f4             	push   -0xc(%ebp)
 1e0:	68 cb 0b 00 00       	push   $0xbcb
 1e5:	6a 01                	push   $0x1
 1e7:	e8 65 05 00 00       	call   751 <printf>
 1ec:	83 c4 10             	add    $0x10,%esp
      sleep(1);
 1ef:	83 ec 0c             	sub    $0xc,%esp
 1f2:	6a 01                	push   $0x1
 1f4:	e8 4c 04 00 00       	call   645 <sleep>
 1f9:	83 c4 10             	add    $0x10,%esp
    }
    if (pid == 0) {
 1fc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 200:	75 42                	jne    244 <run_mlfq_with_tracking_and_boosting+0xad>
      printf(1, "[CHILD] i=%d, PID=%d\n", i, getpid());
 202:	e8 2e 04 00 00       	call   635 <getpid>
 207:	50                   	push   %eax
 208:	ff 75 f4             	push   -0xc(%ebp)
 20b:	68 e8 0b 00 00       	push   $0xbe8
 210:	6a 01                	push   $0x1
 212:	e8 3a 05 00 00       	call   751 <printf>
 217:	83 c4 10             	add    $0x10,%esp
      sleep(1);
 21a:	83 ec 0c             	sub    $0xc,%esp
 21d:	6a 01                	push   $0x1
 21f:	e8 21 04 00 00       	call   645 <sleep>
 224:	83 c4 10             	add    $0x10,%esp
      workload(10000000 * (i+1));
 227:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22a:	83 c0 01             	add    $0x1,%eax
 22d:	69 c0 80 96 98 00    	imul   $0x989680,%eax,%eax
 233:	83 ec 0c             	sub    $0xc,%esp
 236:	50                   	push   %eax
 237:	e8 c4 fd ff ff       	call   0 <workload>
 23c:	83 c4 10             	add    $0x10,%esp
      exit();
 23f:	e8 71 03 00 00       	call   5b5 <exit>
    } else {
      printf(1, "[PARENT] forked child PID=%d at i=%d\n", pid, i);
 244:	ff 75 f4             	push   -0xc(%ebp)
 247:	ff 75 e8             	push   -0x18(%ebp)
 24a:	68 00 0c 00 00       	push   $0xc00
 24f:	6a 01                	push   $0x1
 251:	e8 fb 04 00 00       	call   751 <printf>
 256:	83 c4 10             	add    $0x10,%esp
      sleep(1);
 259:	83 ec 0c             	sub    $0xc,%esp
 25c:	6a 01                	push   $0x1
 25e:	e8 e2 03 00 00       	call   645 <sleep>
 263:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < 3; i++) {
 266:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 26a:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
 26e:	0f 8e 58 ff ff ff    	jle    1cc <run_mlfq_with_tracking_and_boosting+0x35>
    }
  }

  // 자식 다 만든 이후에 정책 변경
  printf(1, "[DEBUG] Setting MLFQ policy now...\n");
 274:	83 ec 08             	sub    $0x8,%esp
 277:	68 28 0c 00 00       	push   $0xc28
 27c:	6a 01                	push   $0x1
 27e:	e8 ce 04 00 00       	call   751 <printf>
 283:	83 c4 10             	add    $0x10,%esp
  setSchedPolicy(1);
 286:	83 ec 0c             	sub    $0xc,%esp
 289:	6a 01                	push   $0x1
 28b:	e8 cd 03 00 00       	call   65d <setSchedPolicy>
 290:	83 c4 10             	add    $0x10,%esp
  sleep(1);
 293:	83 ec 0c             	sub    $0xc,%esp
 296:	6a 01                	push   $0x1
 298:	e8 a8 03 00 00       	call   645 <sleep>
 29d:	83 c4 10             	add    $0x10,%esp

  int sched = getSchedPolicy();
 2a0:	e8 c8 03 00 00       	call   66d <getSchedPolicy>
 2a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  printf(1, "[DEBUG] Current sched_policy = %d\n", sched);
 2a8:	83 ec 04             	sub    $0x4,%esp
 2ab:	ff 75 ec             	push   -0x14(%ebp)
 2ae:	68 4c 0c 00 00       	push   $0xc4c
 2b3:	6a 01                	push   $0x1
 2b5:	e8 97 04 00 00       	call   751 <printf>
 2ba:	83 c4 10             	add    $0x10,%esp
  sleep(1);
 2bd:	83 ec 0c             	sub    $0xc,%esp
 2c0:	6a 01                	push   $0x1
 2c2:	e8 7e 03 00 00       	call   645 <sleep>
 2c7:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < 3; i++) wait();
 2ca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 2d1:	eb 09                	jmp    2dc <run_mlfq_with_tracking_and_boosting+0x145>
 2d3:	e8 e5 02 00 00       	call   5bd <wait>
 2d8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 2dc:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
 2e0:	7e f1                	jle    2d3 <run_mlfq_with_tracking_and_boosting+0x13c>

  print_stat();
 2e2:	e8 51 fd ff ff       	call   38 <print_stat>
}
 2e7:	90                   	nop
 2e8:	c9                   	leave
 2e9:	c3                   	ret

000002ea <main>:

int main(void) {
 2ea:	f3 0f 1e fb          	endbr32
 2ee:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 2f2:	83 e4 f0             	and    $0xfffffff0,%esp
 2f5:	ff 71 fc             	push   -0x4(%ecx)
 2f8:	55                   	push   %ebp
 2f9:	89 e5                	mov    %esp,%ebp
 2fb:	51                   	push   %ecx
 2fc:	83 ec 04             	sub    $0x4,%esp
  printf(1, "\n===== [POLICY 1: MLFQ with tracking & boosting] =====\n");
 2ff:	83 ec 08             	sub    $0x8,%esp
 302:	68 70 0c 00 00       	push   $0xc70
 307:	6a 01                	push   $0x1
 309:	e8 43 04 00 00       	call   751 <printf>
 30e:	83 c4 10             	add    $0x10,%esp
  run_mlfq_with_tracking_and_boosting();
 311:	e8 81 fe ff ff       	call   197 <run_mlfq_with_tracking_and_boosting>

  printf(1, "\n===== [POLICY 1: exit] =====\n");
 316:	83 ec 08             	sub    $0x8,%esp
 319:	68 a8 0c 00 00       	push   $0xca8
 31e:	6a 01                	push   $0x1
 320:	e8 2c 04 00 00       	call   751 <printf>
 325:	83 c4 10             	add    $0x10,%esp
  sleep(1);
 328:	83 ec 0c             	sub    $0xc,%esp
 32b:	6a 01                	push   $0x1
 32d:	e8 13 03 00 00       	call   645 <sleep>
 332:	83 c4 10             	add    $0x10,%esp
  exit();
 335:	e8 7b 02 00 00       	call   5b5 <exit>

0000033a <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 33a:	55                   	push   %ebp
 33b:	89 e5                	mov    %esp,%ebp
 33d:	57                   	push   %edi
 33e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 33f:	8b 4d 08             	mov    0x8(%ebp),%ecx
 342:	8b 55 10             	mov    0x10(%ebp),%edx
 345:	8b 45 0c             	mov    0xc(%ebp),%eax
 348:	89 cb                	mov    %ecx,%ebx
 34a:	89 df                	mov    %ebx,%edi
 34c:	89 d1                	mov    %edx,%ecx
 34e:	fc                   	cld
 34f:	f3 aa                	rep stos %al,%es:(%edi)
 351:	89 ca                	mov    %ecx,%edx
 353:	89 fb                	mov    %edi,%ebx
 355:	89 5d 08             	mov    %ebx,0x8(%ebp)
 358:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 35b:	90                   	nop
 35c:	5b                   	pop    %ebx
 35d:	5f                   	pop    %edi
 35e:	5d                   	pop    %ebp
 35f:	c3                   	ret

00000360 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 360:	f3 0f 1e fb          	endbr32
 364:	55                   	push   %ebp
 365:	89 e5                	mov    %esp,%ebp
 367:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 36a:	8b 45 08             	mov    0x8(%ebp),%eax
 36d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 370:	90                   	nop
 371:	8b 55 0c             	mov    0xc(%ebp),%edx
 374:	8d 42 01             	lea    0x1(%edx),%eax
 377:	89 45 0c             	mov    %eax,0xc(%ebp)
 37a:	8b 45 08             	mov    0x8(%ebp),%eax
 37d:	8d 48 01             	lea    0x1(%eax),%ecx
 380:	89 4d 08             	mov    %ecx,0x8(%ebp)
 383:	0f b6 12             	movzbl (%edx),%edx
 386:	88 10                	mov    %dl,(%eax)
 388:	0f b6 00             	movzbl (%eax),%eax
 38b:	84 c0                	test   %al,%al
 38d:	75 e2                	jne    371 <strcpy+0x11>
    ;
  return os;
 38f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 392:	c9                   	leave
 393:	c3                   	ret

00000394 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 394:	f3 0f 1e fb          	endbr32
 398:	55                   	push   %ebp
 399:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 39b:	eb 08                	jmp    3a5 <strcmp+0x11>
    p++, q++;
 39d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 3a5:	8b 45 08             	mov    0x8(%ebp),%eax
 3a8:	0f b6 00             	movzbl (%eax),%eax
 3ab:	84 c0                	test   %al,%al
 3ad:	74 10                	je     3bf <strcmp+0x2b>
 3af:	8b 45 08             	mov    0x8(%ebp),%eax
 3b2:	0f b6 10             	movzbl (%eax),%edx
 3b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b8:	0f b6 00             	movzbl (%eax),%eax
 3bb:	38 c2                	cmp    %al,%dl
 3bd:	74 de                	je     39d <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 3bf:	8b 45 08             	mov    0x8(%ebp),%eax
 3c2:	0f b6 00             	movzbl (%eax),%eax
 3c5:	0f b6 d0             	movzbl %al,%edx
 3c8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cb:	0f b6 00             	movzbl (%eax),%eax
 3ce:	0f b6 c0             	movzbl %al,%eax
 3d1:	29 c2                	sub    %eax,%edx
 3d3:	89 d0                	mov    %edx,%eax
}
 3d5:	5d                   	pop    %ebp
 3d6:	c3                   	ret

000003d7 <strlen>:

uint
strlen(char *s)
{
 3d7:	f3 0f 1e fb          	endbr32
 3db:	55                   	push   %ebp
 3dc:	89 e5                	mov    %esp,%ebp
 3de:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3e1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3e8:	eb 04                	jmp    3ee <strlen+0x17>
 3ea:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3ee:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3f1:	8b 45 08             	mov    0x8(%ebp),%eax
 3f4:	01 d0                	add    %edx,%eax
 3f6:	0f b6 00             	movzbl (%eax),%eax
 3f9:	84 c0                	test   %al,%al
 3fb:	75 ed                	jne    3ea <strlen+0x13>
    ;
  return n;
 3fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 400:	c9                   	leave
 401:	c3                   	ret

00000402 <memset>:

void*
memset(void *dst, int c, uint n)
{
 402:	f3 0f 1e fb          	endbr32
 406:	55                   	push   %ebp
 407:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 409:	8b 45 10             	mov    0x10(%ebp),%eax
 40c:	50                   	push   %eax
 40d:	ff 75 0c             	push   0xc(%ebp)
 410:	ff 75 08             	push   0x8(%ebp)
 413:	e8 22 ff ff ff       	call   33a <stosb>
 418:	83 c4 0c             	add    $0xc,%esp
  return dst;
 41b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 41e:	c9                   	leave
 41f:	c3                   	ret

00000420 <strchr>:

char*
strchr(const char *s, char c)
{
 420:	f3 0f 1e fb          	endbr32
 424:	55                   	push   %ebp
 425:	89 e5                	mov    %esp,%ebp
 427:	83 ec 04             	sub    $0x4,%esp
 42a:	8b 45 0c             	mov    0xc(%ebp),%eax
 42d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 430:	eb 14                	jmp    446 <strchr+0x26>
    if(*s == c)
 432:	8b 45 08             	mov    0x8(%ebp),%eax
 435:	0f b6 00             	movzbl (%eax),%eax
 438:	38 45 fc             	cmp    %al,-0x4(%ebp)
 43b:	75 05                	jne    442 <strchr+0x22>
      return (char*)s;
 43d:	8b 45 08             	mov    0x8(%ebp),%eax
 440:	eb 13                	jmp    455 <strchr+0x35>
  for(; *s; s++)
 442:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 446:	8b 45 08             	mov    0x8(%ebp),%eax
 449:	0f b6 00             	movzbl (%eax),%eax
 44c:	84 c0                	test   %al,%al
 44e:	75 e2                	jne    432 <strchr+0x12>
  return 0;
 450:	b8 00 00 00 00       	mov    $0x0,%eax
}
 455:	c9                   	leave
 456:	c3                   	ret

00000457 <gets>:

char*
gets(char *buf, int max)
{
 457:	f3 0f 1e fb          	endbr32
 45b:	55                   	push   %ebp
 45c:	89 e5                	mov    %esp,%ebp
 45e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 461:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 468:	eb 42                	jmp    4ac <gets+0x55>
    cc = read(0, &c, 1);
 46a:	83 ec 04             	sub    $0x4,%esp
 46d:	6a 01                	push   $0x1
 46f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 472:	50                   	push   %eax
 473:	6a 00                	push   $0x0
 475:	e8 53 01 00 00       	call   5cd <read>
 47a:	83 c4 10             	add    $0x10,%esp
 47d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 480:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 484:	7e 33                	jle    4b9 <gets+0x62>
      break;
    buf[i++] = c;
 486:	8b 45 f4             	mov    -0xc(%ebp),%eax
 489:	8d 50 01             	lea    0x1(%eax),%edx
 48c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 48f:	89 c2                	mov    %eax,%edx
 491:	8b 45 08             	mov    0x8(%ebp),%eax
 494:	01 c2                	add    %eax,%edx
 496:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 49a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 49c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4a0:	3c 0a                	cmp    $0xa,%al
 4a2:	74 16                	je     4ba <gets+0x63>
 4a4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4a8:	3c 0d                	cmp    $0xd,%al
 4aa:	74 0e                	je     4ba <gets+0x63>
  for(i=0; i+1 < max; ){
 4ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4af:	83 c0 01             	add    $0x1,%eax
 4b2:	39 45 0c             	cmp    %eax,0xc(%ebp)
 4b5:	7f b3                	jg     46a <gets+0x13>
 4b7:	eb 01                	jmp    4ba <gets+0x63>
      break;
 4b9:	90                   	nop
      break;
  }
  buf[i] = '\0';
 4ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4bd:	8b 45 08             	mov    0x8(%ebp),%eax
 4c0:	01 d0                	add    %edx,%eax
 4c2:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4c5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4c8:	c9                   	leave
 4c9:	c3                   	ret

000004ca <stat>:

int
stat(char *n, struct stat *st)
{
 4ca:	f3 0f 1e fb          	endbr32
 4ce:	55                   	push   %ebp
 4cf:	89 e5                	mov    %esp,%ebp
 4d1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4d4:	83 ec 08             	sub    $0x8,%esp
 4d7:	6a 00                	push   $0x0
 4d9:	ff 75 08             	push   0x8(%ebp)
 4dc:	e8 14 01 00 00       	call   5f5 <open>
 4e1:	83 c4 10             	add    $0x10,%esp
 4e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4eb:	79 07                	jns    4f4 <stat+0x2a>
    return -1;
 4ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4f2:	eb 25                	jmp    519 <stat+0x4f>
  r = fstat(fd, st);
 4f4:	83 ec 08             	sub    $0x8,%esp
 4f7:	ff 75 0c             	push   0xc(%ebp)
 4fa:	ff 75 f4             	push   -0xc(%ebp)
 4fd:	e8 0b 01 00 00       	call   60d <fstat>
 502:	83 c4 10             	add    $0x10,%esp
 505:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 508:	83 ec 0c             	sub    $0xc,%esp
 50b:	ff 75 f4             	push   -0xc(%ebp)
 50e:	e8 ca 00 00 00       	call   5dd <close>
 513:	83 c4 10             	add    $0x10,%esp
  return r;
 516:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 519:	c9                   	leave
 51a:	c3                   	ret

0000051b <atoi>:

int
atoi(const char *s)
{
 51b:	f3 0f 1e fb          	endbr32
 51f:	55                   	push   %ebp
 520:	89 e5                	mov    %esp,%ebp
 522:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 525:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 52c:	eb 25                	jmp    553 <atoi+0x38>
    n = n*10 + *s++ - '0';
 52e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 531:	89 d0                	mov    %edx,%eax
 533:	c1 e0 02             	shl    $0x2,%eax
 536:	01 d0                	add    %edx,%eax
 538:	01 c0                	add    %eax,%eax
 53a:	89 c1                	mov    %eax,%ecx
 53c:	8b 45 08             	mov    0x8(%ebp),%eax
 53f:	8d 50 01             	lea    0x1(%eax),%edx
 542:	89 55 08             	mov    %edx,0x8(%ebp)
 545:	0f b6 00             	movzbl (%eax),%eax
 548:	0f be c0             	movsbl %al,%eax
 54b:	01 c8                	add    %ecx,%eax
 54d:	83 e8 30             	sub    $0x30,%eax
 550:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 553:	8b 45 08             	mov    0x8(%ebp),%eax
 556:	0f b6 00             	movzbl (%eax),%eax
 559:	3c 2f                	cmp    $0x2f,%al
 55b:	7e 0a                	jle    567 <atoi+0x4c>
 55d:	8b 45 08             	mov    0x8(%ebp),%eax
 560:	0f b6 00             	movzbl (%eax),%eax
 563:	3c 39                	cmp    $0x39,%al
 565:	7e c7                	jle    52e <atoi+0x13>
  return n;
 567:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 56a:	c9                   	leave
 56b:	c3                   	ret

0000056c <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 56c:	f3 0f 1e fb          	endbr32
 570:	55                   	push   %ebp
 571:	89 e5                	mov    %esp,%ebp
 573:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 576:	8b 45 08             	mov    0x8(%ebp),%eax
 579:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 57c:	8b 45 0c             	mov    0xc(%ebp),%eax
 57f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 582:	eb 17                	jmp    59b <memmove+0x2f>
    *dst++ = *src++;
 584:	8b 55 f8             	mov    -0x8(%ebp),%edx
 587:	8d 42 01             	lea    0x1(%edx),%eax
 58a:	89 45 f8             	mov    %eax,-0x8(%ebp)
 58d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 590:	8d 48 01             	lea    0x1(%eax),%ecx
 593:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 596:	0f b6 12             	movzbl (%edx),%edx
 599:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 59b:	8b 45 10             	mov    0x10(%ebp),%eax
 59e:	8d 50 ff             	lea    -0x1(%eax),%edx
 5a1:	89 55 10             	mov    %edx,0x10(%ebp)
 5a4:	85 c0                	test   %eax,%eax
 5a6:	7f dc                	jg     584 <memmove+0x18>
  return vdst;
 5a8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5ab:	c9                   	leave
 5ac:	c3                   	ret

000005ad <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5ad:	b8 01 00 00 00       	mov    $0x1,%eax
 5b2:	cd 40                	int    $0x40
 5b4:	c3                   	ret

000005b5 <exit>:
SYSCALL(exit)
 5b5:	b8 02 00 00 00       	mov    $0x2,%eax
 5ba:	cd 40                	int    $0x40
 5bc:	c3                   	ret

000005bd <wait>:
SYSCALL(wait)
 5bd:	b8 03 00 00 00       	mov    $0x3,%eax
 5c2:	cd 40                	int    $0x40
 5c4:	c3                   	ret

000005c5 <pipe>:
SYSCALL(pipe)
 5c5:	b8 04 00 00 00       	mov    $0x4,%eax
 5ca:	cd 40                	int    $0x40
 5cc:	c3                   	ret

000005cd <read>:
SYSCALL(read)
 5cd:	b8 05 00 00 00       	mov    $0x5,%eax
 5d2:	cd 40                	int    $0x40
 5d4:	c3                   	ret

000005d5 <write>:
SYSCALL(write)
 5d5:	b8 10 00 00 00       	mov    $0x10,%eax
 5da:	cd 40                	int    $0x40
 5dc:	c3                   	ret

000005dd <close>:
SYSCALL(close)
 5dd:	b8 15 00 00 00       	mov    $0x15,%eax
 5e2:	cd 40                	int    $0x40
 5e4:	c3                   	ret

000005e5 <kill>:
SYSCALL(kill)
 5e5:	b8 06 00 00 00       	mov    $0x6,%eax
 5ea:	cd 40                	int    $0x40
 5ec:	c3                   	ret

000005ed <exec>:
SYSCALL(exec)
 5ed:	b8 07 00 00 00       	mov    $0x7,%eax
 5f2:	cd 40                	int    $0x40
 5f4:	c3                   	ret

000005f5 <open>:
SYSCALL(open)
 5f5:	b8 0f 00 00 00       	mov    $0xf,%eax
 5fa:	cd 40                	int    $0x40
 5fc:	c3                   	ret

000005fd <mknod>:
SYSCALL(mknod)
 5fd:	b8 11 00 00 00       	mov    $0x11,%eax
 602:	cd 40                	int    $0x40
 604:	c3                   	ret

00000605 <unlink>:
SYSCALL(unlink)
 605:	b8 12 00 00 00       	mov    $0x12,%eax
 60a:	cd 40                	int    $0x40
 60c:	c3                   	ret

0000060d <fstat>:
SYSCALL(fstat)
 60d:	b8 08 00 00 00       	mov    $0x8,%eax
 612:	cd 40                	int    $0x40
 614:	c3                   	ret

00000615 <link>:
SYSCALL(link)
 615:	b8 13 00 00 00       	mov    $0x13,%eax
 61a:	cd 40                	int    $0x40
 61c:	c3                   	ret

0000061d <mkdir>:
SYSCALL(mkdir)
 61d:	b8 14 00 00 00       	mov    $0x14,%eax
 622:	cd 40                	int    $0x40
 624:	c3                   	ret

00000625 <chdir>:
SYSCALL(chdir)
 625:	b8 09 00 00 00       	mov    $0x9,%eax
 62a:	cd 40                	int    $0x40
 62c:	c3                   	ret

0000062d <dup>:
SYSCALL(dup)
 62d:	b8 0a 00 00 00       	mov    $0xa,%eax
 632:	cd 40                	int    $0x40
 634:	c3                   	ret

00000635 <getpid>:
SYSCALL(getpid)
 635:	b8 0b 00 00 00       	mov    $0xb,%eax
 63a:	cd 40                	int    $0x40
 63c:	c3                   	ret

0000063d <sbrk>:
SYSCALL(sbrk)
 63d:	b8 0c 00 00 00       	mov    $0xc,%eax
 642:	cd 40                	int    $0x40
 644:	c3                   	ret

00000645 <sleep>:
SYSCALL(sleep)
 645:	b8 0d 00 00 00       	mov    $0xd,%eax
 64a:	cd 40                	int    $0x40
 64c:	c3                   	ret

0000064d <uptime>:
SYSCALL(uptime)
 64d:	b8 0e 00 00 00       	mov    $0xe,%eax
 652:	cd 40                	int    $0x40
 654:	c3                   	ret

00000655 <getpinfo>:

SYSCALL(getpinfo)
 655:	b8 16 00 00 00       	mov    $0x16,%eax
 65a:	cd 40                	int    $0x40
 65c:	c3                   	ret

0000065d <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 65d:	b8 17 00 00 00       	mov    $0x17,%eax
 662:	cd 40                	int    $0x40
 664:	c3                   	ret

00000665 <yield>:
SYSCALL(yield)
 665:	b8 18 00 00 00       	mov    $0x18,%eax
 66a:	cd 40                	int    $0x40
 66c:	c3                   	ret

0000066d <getSchedPolicy>:
 66d:	b8 19 00 00 00       	mov    $0x19,%eax
 672:	cd 40                	int    $0x40
 674:	c3                   	ret

00000675 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 675:	f3 0f 1e fb          	endbr32
 679:	55                   	push   %ebp
 67a:	89 e5                	mov    %esp,%ebp
 67c:	83 ec 18             	sub    $0x18,%esp
 67f:	8b 45 0c             	mov    0xc(%ebp),%eax
 682:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 685:	83 ec 04             	sub    $0x4,%esp
 688:	6a 01                	push   $0x1
 68a:	8d 45 f4             	lea    -0xc(%ebp),%eax
 68d:	50                   	push   %eax
 68e:	ff 75 08             	push   0x8(%ebp)
 691:	e8 3f ff ff ff       	call   5d5 <write>
 696:	83 c4 10             	add    $0x10,%esp
}
 699:	90                   	nop
 69a:	c9                   	leave
 69b:	c3                   	ret

0000069c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 69c:	f3 0f 1e fb          	endbr32
 6a0:	55                   	push   %ebp
 6a1:	89 e5                	mov    %esp,%ebp
 6a3:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6ad:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6b1:	74 17                	je     6ca <printint+0x2e>
 6b3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6b7:	79 11                	jns    6ca <printint+0x2e>
    neg = 1;
 6b9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c3:	f7 d8                	neg    %eax
 6c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6c8:	eb 06                	jmp    6d0 <printint+0x34>
  } else {
    x = xx;
 6ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 6cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6da:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6dd:	ba 00 00 00 00       	mov    $0x0,%edx
 6e2:	f7 f1                	div    %ecx
 6e4:	89 d1                	mov    %edx,%ecx
 6e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e9:	8d 50 01             	lea    0x1(%eax),%edx
 6ec:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6ef:	0f b6 91 84 0f 00 00 	movzbl 0xf84(%ecx),%edx
 6f6:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 700:	ba 00 00 00 00       	mov    $0x0,%edx
 705:	f7 f1                	div    %ecx
 707:	89 45 ec             	mov    %eax,-0x14(%ebp)
 70a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 70e:	75 c7                	jne    6d7 <printint+0x3b>
  if(neg)
 710:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 714:	74 2d                	je     743 <printint+0xa7>
    buf[i++] = '-';
 716:	8b 45 f4             	mov    -0xc(%ebp),%eax
 719:	8d 50 01             	lea    0x1(%eax),%edx
 71c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 71f:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 724:	eb 1d                	jmp    743 <printint+0xa7>
    putc(fd, buf[i]);
 726:	8d 55 dc             	lea    -0x24(%ebp),%edx
 729:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72c:	01 d0                	add    %edx,%eax
 72e:	0f b6 00             	movzbl (%eax),%eax
 731:	0f be c0             	movsbl %al,%eax
 734:	83 ec 08             	sub    $0x8,%esp
 737:	50                   	push   %eax
 738:	ff 75 08             	push   0x8(%ebp)
 73b:	e8 35 ff ff ff       	call   675 <putc>
 740:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 743:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 747:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 74b:	79 d9                	jns    726 <printint+0x8a>
}
 74d:	90                   	nop
 74e:	90                   	nop
 74f:	c9                   	leave
 750:	c3                   	ret

00000751 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 751:	f3 0f 1e fb          	endbr32
 755:	55                   	push   %ebp
 756:	89 e5                	mov    %esp,%ebp
 758:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 75b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 762:	8d 45 0c             	lea    0xc(%ebp),%eax
 765:	83 c0 04             	add    $0x4,%eax
 768:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 76b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 772:	e9 59 01 00 00       	jmp    8d0 <printf+0x17f>
    c = fmt[i] & 0xff;
 777:	8b 55 0c             	mov    0xc(%ebp),%edx
 77a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77d:	01 d0                	add    %edx,%eax
 77f:	0f b6 00             	movzbl (%eax),%eax
 782:	0f be c0             	movsbl %al,%eax
 785:	25 ff 00 00 00       	and    $0xff,%eax
 78a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 78d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 791:	75 2c                	jne    7bf <printf+0x6e>
      if(c == '%'){
 793:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 797:	75 0c                	jne    7a5 <printf+0x54>
        state = '%';
 799:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7a0:	e9 27 01 00 00       	jmp    8cc <printf+0x17b>
      } else {
        putc(fd, c);
 7a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7a8:	0f be c0             	movsbl %al,%eax
 7ab:	83 ec 08             	sub    $0x8,%esp
 7ae:	50                   	push   %eax
 7af:	ff 75 08             	push   0x8(%ebp)
 7b2:	e8 be fe ff ff       	call   675 <putc>
 7b7:	83 c4 10             	add    $0x10,%esp
 7ba:	e9 0d 01 00 00       	jmp    8cc <printf+0x17b>
      }
    } else if(state == '%'){
 7bf:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7c3:	0f 85 03 01 00 00    	jne    8cc <printf+0x17b>
      if(c == 'd'){
 7c9:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7cd:	75 1e                	jne    7ed <printf+0x9c>
        printint(fd, *ap, 10, 1);
 7cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d2:	8b 00                	mov    (%eax),%eax
 7d4:	6a 01                	push   $0x1
 7d6:	6a 0a                	push   $0xa
 7d8:	50                   	push   %eax
 7d9:	ff 75 08             	push   0x8(%ebp)
 7dc:	e8 bb fe ff ff       	call   69c <printint>
 7e1:	83 c4 10             	add    $0x10,%esp
        ap++;
 7e4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e8:	e9 d8 00 00 00       	jmp    8c5 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 7ed:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7f1:	74 06                	je     7f9 <printf+0xa8>
 7f3:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7f7:	75 1e                	jne    817 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 7f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7fc:	8b 00                	mov    (%eax),%eax
 7fe:	6a 00                	push   $0x0
 800:	6a 10                	push   $0x10
 802:	50                   	push   %eax
 803:	ff 75 08             	push   0x8(%ebp)
 806:	e8 91 fe ff ff       	call   69c <printint>
 80b:	83 c4 10             	add    $0x10,%esp
        ap++;
 80e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 812:	e9 ae 00 00 00       	jmp    8c5 <printf+0x174>
      } else if(c == 's'){
 817:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 81b:	75 43                	jne    860 <printf+0x10f>
        s = (char*)*ap;
 81d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 820:	8b 00                	mov    (%eax),%eax
 822:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 825:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 829:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 82d:	75 25                	jne    854 <printf+0x103>
          s = "(null)";
 82f:	c7 45 f4 c7 0c 00 00 	movl   $0xcc7,-0xc(%ebp)
        while(*s != 0){
 836:	eb 1c                	jmp    854 <printf+0x103>
          putc(fd, *s);
 838:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83b:	0f b6 00             	movzbl (%eax),%eax
 83e:	0f be c0             	movsbl %al,%eax
 841:	83 ec 08             	sub    $0x8,%esp
 844:	50                   	push   %eax
 845:	ff 75 08             	push   0x8(%ebp)
 848:	e8 28 fe ff ff       	call   675 <putc>
 84d:	83 c4 10             	add    $0x10,%esp
          s++;
 850:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 854:	8b 45 f4             	mov    -0xc(%ebp),%eax
 857:	0f b6 00             	movzbl (%eax),%eax
 85a:	84 c0                	test   %al,%al
 85c:	75 da                	jne    838 <printf+0xe7>
 85e:	eb 65                	jmp    8c5 <printf+0x174>
        }
      } else if(c == 'c'){
 860:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 864:	75 1d                	jne    883 <printf+0x132>
        putc(fd, *ap);
 866:	8b 45 e8             	mov    -0x18(%ebp),%eax
 869:	8b 00                	mov    (%eax),%eax
 86b:	0f be c0             	movsbl %al,%eax
 86e:	83 ec 08             	sub    $0x8,%esp
 871:	50                   	push   %eax
 872:	ff 75 08             	push   0x8(%ebp)
 875:	e8 fb fd ff ff       	call   675 <putc>
 87a:	83 c4 10             	add    $0x10,%esp
        ap++;
 87d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 881:	eb 42                	jmp    8c5 <printf+0x174>
      } else if(c == '%'){
 883:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 887:	75 17                	jne    8a0 <printf+0x14f>
        putc(fd, c);
 889:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 88c:	0f be c0             	movsbl %al,%eax
 88f:	83 ec 08             	sub    $0x8,%esp
 892:	50                   	push   %eax
 893:	ff 75 08             	push   0x8(%ebp)
 896:	e8 da fd ff ff       	call   675 <putc>
 89b:	83 c4 10             	add    $0x10,%esp
 89e:	eb 25                	jmp    8c5 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8a0:	83 ec 08             	sub    $0x8,%esp
 8a3:	6a 25                	push   $0x25
 8a5:	ff 75 08             	push   0x8(%ebp)
 8a8:	e8 c8 fd ff ff       	call   675 <putc>
 8ad:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8b3:	0f be c0             	movsbl %al,%eax
 8b6:	83 ec 08             	sub    $0x8,%esp
 8b9:	50                   	push   %eax
 8ba:	ff 75 08             	push   0x8(%ebp)
 8bd:	e8 b3 fd ff ff       	call   675 <putc>
 8c2:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8c5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 8cc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8d0:	8b 55 0c             	mov    0xc(%ebp),%edx
 8d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d6:	01 d0                	add    %edx,%eax
 8d8:	0f b6 00             	movzbl (%eax),%eax
 8db:	84 c0                	test   %al,%al
 8dd:	0f 85 94 fe ff ff    	jne    777 <printf+0x26>
    }
  }
}
 8e3:	90                   	nop
 8e4:	90                   	nop
 8e5:	c9                   	leave
 8e6:	c3                   	ret

000008e7 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8e7:	f3 0f 1e fb          	endbr32
 8eb:	55                   	push   %ebp
 8ec:	89 e5                	mov    %esp,%ebp
 8ee:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8f1:	8b 45 08             	mov    0x8(%ebp),%eax
 8f4:	83 e8 08             	sub    $0x8,%eax
 8f7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8fa:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 8ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
 902:	eb 24                	jmp    928 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 904:	8b 45 fc             	mov    -0x4(%ebp),%eax
 907:	8b 00                	mov    (%eax),%eax
 909:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 90c:	72 12                	jb     920 <free+0x39>
 90e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 911:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 914:	77 24                	ja     93a <free+0x53>
 916:	8b 45 fc             	mov    -0x4(%ebp),%eax
 919:	8b 00                	mov    (%eax),%eax
 91b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 91e:	72 1a                	jb     93a <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 920:	8b 45 fc             	mov    -0x4(%ebp),%eax
 923:	8b 00                	mov    (%eax),%eax
 925:	89 45 fc             	mov    %eax,-0x4(%ebp)
 928:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 92e:	76 d4                	jbe    904 <free+0x1d>
 930:	8b 45 fc             	mov    -0x4(%ebp),%eax
 933:	8b 00                	mov    (%eax),%eax
 935:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 938:	73 ca                	jae    904 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 93a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93d:	8b 40 04             	mov    0x4(%eax),%eax
 940:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 947:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94a:	01 c2                	add    %eax,%edx
 94c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94f:	8b 00                	mov    (%eax),%eax
 951:	39 c2                	cmp    %eax,%edx
 953:	75 24                	jne    979 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 955:	8b 45 f8             	mov    -0x8(%ebp),%eax
 958:	8b 50 04             	mov    0x4(%eax),%edx
 95b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95e:	8b 00                	mov    (%eax),%eax
 960:	8b 40 04             	mov    0x4(%eax),%eax
 963:	01 c2                	add    %eax,%edx
 965:	8b 45 f8             	mov    -0x8(%ebp),%eax
 968:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 96b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96e:	8b 00                	mov    (%eax),%eax
 970:	8b 10                	mov    (%eax),%edx
 972:	8b 45 f8             	mov    -0x8(%ebp),%eax
 975:	89 10                	mov    %edx,(%eax)
 977:	eb 0a                	jmp    983 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 979:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97c:	8b 10                	mov    (%eax),%edx
 97e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 981:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 983:	8b 45 fc             	mov    -0x4(%ebp),%eax
 986:	8b 40 04             	mov    0x4(%eax),%eax
 989:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 990:	8b 45 fc             	mov    -0x4(%ebp),%eax
 993:	01 d0                	add    %edx,%eax
 995:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 998:	75 20                	jne    9ba <free+0xd3>
    p->s.size += bp->s.size;
 99a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99d:	8b 50 04             	mov    0x4(%eax),%edx
 9a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a3:	8b 40 04             	mov    0x4(%eax),%eax
 9a6:	01 c2                	add    %eax,%edx
 9a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ab:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b1:	8b 10                	mov    (%eax),%edx
 9b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b6:	89 10                	mov    %edx,(%eax)
 9b8:	eb 08                	jmp    9c2 <free+0xdb>
  } else
    p->s.ptr = bp;
 9ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bd:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9c0:	89 10                	mov    %edx,(%eax)
  freep = p;
 9c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c5:	a3 a0 0f 00 00       	mov    %eax,0xfa0
}
 9ca:	90                   	nop
 9cb:	c9                   	leave
 9cc:	c3                   	ret

000009cd <morecore>:

static Header*
morecore(uint nu)
{
 9cd:	f3 0f 1e fb          	endbr32
 9d1:	55                   	push   %ebp
 9d2:	89 e5                	mov    %esp,%ebp
 9d4:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9d7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9de:	77 07                	ja     9e7 <morecore+0x1a>
    nu = 4096;
 9e0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9e7:	8b 45 08             	mov    0x8(%ebp),%eax
 9ea:	c1 e0 03             	shl    $0x3,%eax
 9ed:	83 ec 0c             	sub    $0xc,%esp
 9f0:	50                   	push   %eax
 9f1:	e8 47 fc ff ff       	call   63d <sbrk>
 9f6:	83 c4 10             	add    $0x10,%esp
 9f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9fc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a00:	75 07                	jne    a09 <morecore+0x3c>
    return 0;
 a02:	b8 00 00 00 00       	mov    $0x0,%eax
 a07:	eb 26                	jmp    a2f <morecore+0x62>
  hp = (Header*)p;
 a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a12:	8b 55 08             	mov    0x8(%ebp),%edx
 a15:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a1b:	83 c0 08             	add    $0x8,%eax
 a1e:	83 ec 0c             	sub    $0xc,%esp
 a21:	50                   	push   %eax
 a22:	e8 c0 fe ff ff       	call   8e7 <free>
 a27:	83 c4 10             	add    $0x10,%esp
  return freep;
 a2a:	a1 a0 0f 00 00       	mov    0xfa0,%eax
}
 a2f:	c9                   	leave
 a30:	c3                   	ret

00000a31 <malloc>:

void*
malloc(uint nbytes)
{
 a31:	f3 0f 1e fb          	endbr32
 a35:	55                   	push   %ebp
 a36:	89 e5                	mov    %esp,%ebp
 a38:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a3b:	8b 45 08             	mov    0x8(%ebp),%eax
 a3e:	83 c0 07             	add    $0x7,%eax
 a41:	c1 e8 03             	shr    $0x3,%eax
 a44:	83 c0 01             	add    $0x1,%eax
 a47:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a4a:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 a4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a52:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a56:	75 23                	jne    a7b <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 a58:	c7 45 f0 98 0f 00 00 	movl   $0xf98,-0x10(%ebp)
 a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a62:	a3 a0 0f 00 00       	mov    %eax,0xfa0
 a67:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 a6c:	a3 98 0f 00 00       	mov    %eax,0xf98
    base.s.size = 0;
 a71:	c7 05 9c 0f 00 00 00 	movl   $0x0,0xf9c
 a78:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a7e:	8b 00                	mov    (%eax),%eax
 a80:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a86:	8b 40 04             	mov    0x4(%eax),%eax
 a89:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a8c:	77 4d                	ja     adb <malloc+0xaa>
      if(p->s.size == nunits)
 a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a91:	8b 40 04             	mov    0x4(%eax),%eax
 a94:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a97:	75 0c                	jne    aa5 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9c:	8b 10                	mov    (%eax),%edx
 a9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa1:	89 10                	mov    %edx,(%eax)
 aa3:	eb 26                	jmp    acb <malloc+0x9a>
      else {
        p->s.size -= nunits;
 aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa8:	8b 40 04             	mov    0x4(%eax),%eax
 aab:	2b 45 ec             	sub    -0x14(%ebp),%eax
 aae:	89 c2                	mov    %eax,%edx
 ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab3:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab9:	8b 40 04             	mov    0x4(%eax),%eax
 abc:	c1 e0 03             	shl    $0x3,%eax
 abf:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac5:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ac8:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 acb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ace:	a3 a0 0f 00 00       	mov    %eax,0xfa0
      return (void*)(p + 1);
 ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad6:	83 c0 08             	add    $0x8,%eax
 ad9:	eb 3b                	jmp    b16 <malloc+0xe5>
    }
    if(p == freep)
 adb:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 ae0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ae3:	75 1e                	jne    b03 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 ae5:	83 ec 0c             	sub    $0xc,%esp
 ae8:	ff 75 ec             	push   -0x14(%ebp)
 aeb:	e8 dd fe ff ff       	call   9cd <morecore>
 af0:	83 c4 10             	add    $0x10,%esp
 af3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 af6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 afa:	75 07                	jne    b03 <malloc+0xd2>
        return 0;
 afc:	b8 00 00 00 00       	mov    $0x0,%eax
 b01:	eb 13                	jmp    b16 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b06:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b0c:	8b 00                	mov    (%eax),%eax
 b0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b11:	e9 6d ff ff ff       	jmp    a83 <malloc+0x52>
  }
}
 b16:	c9                   	leave
 b17:	c3                   	ret
