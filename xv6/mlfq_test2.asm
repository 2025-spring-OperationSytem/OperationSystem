
_mlfq_test2:     file format elf32-i386


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
  18:	eb 6c                	jmp    86 <workload+0x86>
    if (i % 100000 == 0) {
  1a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  1d:	ba 89 b5 f8 14       	mov    $0x14f8b589,%edx
  22:	89 c8                	mov    %ecx,%eax
  24:	f7 ea                	imul   %edx
  26:	c1 fa 0d             	sar    $0xd,%edx
  29:	89 c8                	mov    %ecx,%eax
  2b:	c1 f8 1f             	sar    $0x1f,%eax
  2e:	29 c2                	sub    %eax,%edx
  30:	89 d0                	mov    %edx,%eax
  32:	69 c0 a0 86 01 00    	imul   $0x186a0,%eax,%eax
  38:	29 c1                	sub    %eax,%ecx
  3a:	89 c8                	mov    %ecx,%eax
  3c:	85 c0                	test   %eax,%eax
  3e:	75 35                	jne    75 <workload+0x75>
      printf(1, "[CHEAT] PID %d yielding at i = %d\n", getpid(), i);
  40:	e8 4b 06 00 00       	call   690 <getpid>
  45:	ff 75 f4             	push   -0xc(%ebp)
  48:	50                   	push   %eax
  49:	68 74 0b 00 00       	push   $0xb74
  4e:	6a 01                	push   $0x1
  50:	e8 57 07 00 00       	call   7ac <printf>
  55:	83 c4 10             	add    $0x10,%esp
      yield();
  58:	e8 63 06 00 00       	call   6c0 <yield>
      printf(1, "[CHEAT] PID %d resumed after yield at i = %d\n", getpid(), i);
  5d:	e8 2e 06 00 00       	call   690 <getpid>
  62:	ff 75 f4             	push   -0xc(%ebp)
  65:	50                   	push   %eax
  66:	68 98 0b 00 00       	push   $0xb98
  6b:	6a 01                	push   $0x1
  6d:	e8 3a 07 00 00       	call   7ac <printf>
  72:	83 c4 10             	add    $0x10,%esp
    }
    j += i * j + 1;
  75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  78:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  7c:	83 c0 01             	add    $0x1,%eax
  7f:	01 45 f0             	add    %eax,-0x10(%ebp)
  for (i = 0; i < n; i++) {
  82:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  89:	3b 45 08             	cmp    0x8(%ebp),%eax
  8c:	7c 8c                	jl     1a <workload+0x1a>
  }
  return j;
  8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  91:	c9                   	leave
  92:	c3                   	ret

00000093 <print_stat>:


void print_stat() {
  93:	f3 0f 1e fb          	endbr32
  97:	55                   	push   %ebp
  98:	89 e5                	mov    %esp,%ebp
  9a:	57                   	push   %edi
  9b:	56                   	push   %esi
  9c:	53                   	push   %ebx
  9d:	81 ec 2c 0c 00 00    	sub    $0xc2c,%esp
  struct pstat ps;
  getpinfo(&ps);
  a3:	83 ec 0c             	sub    $0xc,%esp
  a6:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
  ac:	50                   	push   %eax
  ad:	e8 fe 05 00 00       	call   6b0 <getpinfo>
  b2:	83 c4 10             	add    $0x10,%esp

  printf(1, "\n[RESULT] Process Statistics (Policy 2: No Tracking)\n");
  b5:	83 ec 08             	sub    $0x8,%esp
  b8:	68 c8 0b 00 00       	push   $0xbc8
  bd:	6a 01                	push   $0x1
  bf:	e8 e8 06 00 00       	call   7ac <printf>
  c4:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
  c7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  ce:	e9 0b 01 00 00       	jmp    1de <print_stat+0x14b>
    if (ps.inuse[i]) {
  d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  d6:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
  dd:	85 c0                	test   %eax,%eax
  df:	0f 84 f5 00 00 00    	je     1da <print_stat+0x147>
      printf(1, "PID %d | Priority %d | Ticks: [Q3:%d Q2:%d Q1:%d Q0:%d] | Wait: [Q3:%d Q2:%d Q1:%d Q0:%d]\n",
  e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  e8:	83 e8 80             	sub    $0xffffff80,%eax
  eb:	c1 e0 04             	shl    $0x4,%eax
  ee:	8d 55 e8             	lea    -0x18(%ebp),%edx
  f1:	01 d0                	add    %edx,%eax
  f3:	2d 04 0c 00 00       	sub    $0xc04,%eax
  f8:	8b 30                	mov    (%eax),%esi
  fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  fd:	c1 e0 04             	shl    $0x4,%eax
 100:	8d 4d e8             	lea    -0x18(%ebp),%ecx
 103:	01 c8                	add    %ecx,%eax
 105:	2d 00 04 00 00       	sub    $0x400,%eax
 10a:	8b 38                	mov    (%eax),%edi
 10c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 10f:	c1 e0 04             	shl    $0x4,%eax
 112:	8d 5d e8             	lea    -0x18(%ebp),%ebx
 115:	01 d8                	add    %ebx,%eax
 117:	2d fc 03 00 00       	sub    $0x3fc,%eax
 11c:	8b 00                	mov    (%eax),%eax
 11e:	89 85 d4 f3 ff ff    	mov    %eax,-0xc2c(%ebp)
 124:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 127:	c1 e0 04             	shl    $0x4,%eax
 12a:	8d 55 e8             	lea    -0x18(%ebp),%edx
 12d:	01 d0                	add    %edx,%eax
 12f:	2d f8 03 00 00       	sub    $0x3f8,%eax
 134:	8b 08                	mov    (%eax),%ecx
 136:	89 8d d0 f3 ff ff    	mov    %ecx,-0xc30(%ebp)
 13c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 13f:	83 c0 40             	add    $0x40,%eax
 142:	c1 e0 04             	shl    $0x4,%eax
 145:	8d 5d e8             	lea    -0x18(%ebp),%ebx
 148:	01 d8                	add    %ebx,%eax
 14a:	2d 04 0c 00 00       	sub    $0xc04,%eax
 14f:	8b 10                	mov    (%eax),%edx
 151:	89 95 cc f3 ff ff    	mov    %edx,-0xc34(%ebp)
 157:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 15a:	c1 e0 04             	shl    $0x4,%eax
 15d:	8d 5d e8             	lea    -0x18(%ebp),%ebx
 160:	01 d8                	add    %ebx,%eax
 162:	2d 00 08 00 00       	sub    $0x800,%eax
 167:	8b 18                	mov    (%eax),%ebx
 169:	89 9d c8 f3 ff ff    	mov    %ebx,-0xc38(%ebp)
 16f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 172:	c1 e0 04             	shl    $0x4,%eax
 175:	8d 4d e8             	lea    -0x18(%ebp),%ecx
 178:	01 c8                	add    %ecx,%eax
 17a:	2d fc 07 00 00       	sub    $0x7fc,%eax
 17f:	8b 18                	mov    (%eax),%ebx
 181:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 184:	c1 e0 04             	shl    $0x4,%eax
 187:	8d 55 e8             	lea    -0x18(%ebp),%edx
 18a:	01 d0                	add    %edx,%eax
 18c:	2d f8 07 00 00       	sub    $0x7f8,%eax
 191:	8b 08                	mov    (%eax),%ecx
 193:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 196:	83 e8 80             	sub    $0xffffff80,%eax
 199:	8b 94 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%edx
 1a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1a3:	83 c0 40             	add    $0x40,%eax
 1a6:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
 1ad:	56                   	push   %esi
 1ae:	57                   	push   %edi
 1af:	ff b5 d4 f3 ff ff    	push   -0xc2c(%ebp)
 1b5:	ff b5 d0 f3 ff ff    	push   -0xc30(%ebp)
 1bb:	ff b5 cc f3 ff ff    	push   -0xc34(%ebp)
 1c1:	ff b5 c8 f3 ff ff    	push   -0xc38(%ebp)
 1c7:	53                   	push   %ebx
 1c8:	51                   	push   %ecx
 1c9:	52                   	push   %edx
 1ca:	50                   	push   %eax
 1cb:	68 00 0c 00 00       	push   $0xc00
 1d0:	6a 01                	push   $0x1
 1d2:	e8 d5 05 00 00       	call   7ac <printf>
 1d7:	83 c4 30             	add    $0x30,%esp
  for (int i = 0; i < NPROC; i++) {
 1da:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 1de:	83 7d e4 3f          	cmpl   $0x3f,-0x1c(%ebp)
 1e2:	0f 8e eb fe ff ff    	jle    d3 <print_stat+0x40>
        ps.pid[i], ps.priority[i],
        ps.ticks[i][3], ps.ticks[i][2], ps.ticks[i][1], ps.ticks[i][0],
        ps.wait_ticks[i][3], ps.wait_ticks[i][2], ps.wait_ticks[i][1], ps.wait_ticks[i][0]);
    }
  }
}
 1e8:	90                   	nop
 1e9:	90                   	nop
 1ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1ed:	5b                   	pop    %ebx
 1ee:	5e                   	pop    %esi
 1ef:	5f                   	pop    %edi
 1f0:	5d                   	pop    %ebp
 1f1:	c3                   	ret

000001f2 <run_policy_2>:

void run_policy_2() {
 1f2:	f3 0f 1e fb          	endbr32
 1f6:	55                   	push   %ebp
 1f7:	89 e5                	mov    %esp,%ebp
 1f9:	83 ec 18             	sub    $0x18,%esp
  printf(1, "[DEBUG] Entered run_policy_2() - MLFQ without tracking (cheating possible)\n");
 1fc:	83 ec 08             	sub    $0x8,%esp
 1ff:	68 5c 0c 00 00       	push   $0xc5c
 204:	6a 01                	push   $0x1
 206:	e8 a1 05 00 00       	call   7ac <printf>
 20b:	83 c4 10             	add    $0x10,%esp
  sleep(1);
 20e:	83 ec 0c             	sub    $0xc,%esp
 211:	6a 01                	push   $0x1
 213:	e8 88 04 00 00       	call   6a0 <sleep>
 218:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < NPROCS; i++) {
 21b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 222:	e9 9e 00 00 00       	jmp    2c5 <run_policy_2+0xd3>
    int pid = fork();
 227:	e8 dc 03 00 00       	call   608 <fork>
 22c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (pid < 0) {
 22f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 233:	79 22                	jns    257 <run_policy_2+0x65>
      printf(1, "[ERROR] fork failed at i=%d\n", i);
 235:	83 ec 04             	sub    $0x4,%esp
 238:	ff 75 f4             	push   -0xc(%ebp)
 23b:	68 a8 0c 00 00       	push   $0xca8
 240:	6a 01                	push   $0x1
 242:	e8 65 05 00 00       	call   7ac <printf>
 247:	83 c4 10             	add    $0x10,%esp
      sleep(1);
 24a:	83 ec 0c             	sub    $0xc,%esp
 24d:	6a 01                	push   $0x1
 24f:	e8 4c 04 00 00       	call   6a0 <sleep>
 254:	83 c4 10             	add    $0x10,%esp
    }
    if (pid == 0) {
 257:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 25b:	75 42                	jne    29f <run_policy_2+0xad>
      printf(1, "[CHILD] i=%d, PID=%d\n", i, getpid());
 25d:	e8 2e 04 00 00       	call   690 <getpid>
 262:	50                   	push   %eax
 263:	ff 75 f4             	push   -0xc(%ebp)
 266:	68 c5 0c 00 00       	push   $0xcc5
 26b:	6a 01                	push   $0x1
 26d:	e8 3a 05 00 00       	call   7ac <printf>
 272:	83 c4 10             	add    $0x10,%esp
      sleep(1);
 275:	83 ec 0c             	sub    $0xc,%esp
 278:	6a 01                	push   $0x1
 27a:	e8 21 04 00 00       	call   6a0 <sleep>
 27f:	83 c4 10             	add    $0x10,%esp
      workload(50000000 * (i + 1));
 282:	8b 45 f4             	mov    -0xc(%ebp),%eax
 285:	83 c0 01             	add    $0x1,%eax
 288:	69 c0 80 f0 fa 02    	imul   $0x2faf080,%eax,%eax
 28e:	83 ec 0c             	sub    $0xc,%esp
 291:	50                   	push   %eax
 292:	e8 69 fd ff ff       	call   0 <workload>
 297:	83 c4 10             	add    $0x10,%esp
      exit();
 29a:	e8 71 03 00 00       	call   610 <exit>
    } else {
      printf(1, "[PARENT] forked child PID=%d at i=%d\n", pid, i);
 29f:	ff 75 f4             	push   -0xc(%ebp)
 2a2:	ff 75 e8             	push   -0x18(%ebp)
 2a5:	68 dc 0c 00 00       	push   $0xcdc
 2aa:	6a 01                	push   $0x1
 2ac:	e8 fb 04 00 00       	call   7ac <printf>
 2b1:	83 c4 10             	add    $0x10,%esp
      sleep(1);
 2b4:	83 ec 0c             	sub    $0xc,%esp
 2b7:	6a 01                	push   $0x1
 2b9:	e8 e2 03 00 00       	call   6a0 <sleep>
 2be:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROCS; i++) {
 2c1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 2c5:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
 2c9:	0f 8e 58 ff ff ff    	jle    227 <run_policy_2+0x35>
    }
  }

  printf(1, "[DEBUG] Setting sched_policy = 2 (no tracking)\n");
 2cf:	83 ec 08             	sub    $0x8,%esp
 2d2:	68 04 0d 00 00       	push   $0xd04
 2d7:	6a 01                	push   $0x1
 2d9:	e8 ce 04 00 00       	call   7ac <printf>
 2de:	83 c4 10             	add    $0x10,%esp
  setSchedPolicy(2);
 2e1:	83 ec 0c             	sub    $0xc,%esp
 2e4:	6a 02                	push   $0x2
 2e6:	e8 cd 03 00 00       	call   6b8 <setSchedPolicy>
 2eb:	83 c4 10             	add    $0x10,%esp
  sleep(1);
 2ee:	83 ec 0c             	sub    $0xc,%esp
 2f1:	6a 01                	push   $0x1
 2f3:	e8 a8 03 00 00       	call   6a0 <sleep>
 2f8:	83 c4 10             	add    $0x10,%esp

  int policy = getSchedPolicy();
 2fb:	e8 c8 03 00 00       	call   6c8 <getSchedPolicy>
 300:	89 45 ec             	mov    %eax,-0x14(%ebp)
  printf(1, "[DEBUG] Current sched_policy = %d\n", policy);
 303:	83 ec 04             	sub    $0x4,%esp
 306:	ff 75 ec             	push   -0x14(%ebp)
 309:	68 34 0d 00 00       	push   $0xd34
 30e:	6a 01                	push   $0x1
 310:	e8 97 04 00 00       	call   7ac <printf>
 315:	83 c4 10             	add    $0x10,%esp
  sleep(1);
 318:	83 ec 0c             	sub    $0xc,%esp
 31b:	6a 01                	push   $0x1
 31d:	e8 7e 03 00 00       	call   6a0 <sleep>
 322:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < NPROCS; i++) wait();
 325:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 32c:	eb 09                	jmp    337 <run_policy_2+0x145>
 32e:	e8 e5 02 00 00       	call   618 <wait>
 333:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 337:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
 33b:	7e f1                	jle    32e <run_policy_2+0x13c>

  print_stat();
 33d:	e8 51 fd ff ff       	call   93 <print_stat>
}
 342:	90                   	nop
 343:	c9                   	leave
 344:	c3                   	ret

00000345 <main>:

int main(void) {
 345:	f3 0f 1e fb          	endbr32
 349:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 34d:	83 e4 f0             	and    $0xfffffff0,%esp
 350:	ff 71 fc             	push   -0x4(%ecx)
 353:	55                   	push   %ebp
 354:	89 e5                	mov    %esp,%ebp
 356:	51                   	push   %ecx
 357:	83 ec 04             	sub    $0x4,%esp
  printf(1, "\n===== [POLICY 2: MLFQ without tracking (cheating possible)] =====\n");
 35a:	83 ec 08             	sub    $0x8,%esp
 35d:	68 58 0d 00 00       	push   $0xd58
 362:	6a 01                	push   $0x1
 364:	e8 43 04 00 00       	call   7ac <printf>
 369:	83 c4 10             	add    $0x10,%esp
  run_policy_2();
 36c:	e8 81 fe ff ff       	call   1f2 <run_policy_2>
  printf(1, "\n===== [POLICY 2: exit] =====\n");
 371:	83 ec 08             	sub    $0x8,%esp
 374:	68 9c 0d 00 00       	push   $0xd9c
 379:	6a 01                	push   $0x1
 37b:	e8 2c 04 00 00       	call   7ac <printf>
 380:	83 c4 10             	add    $0x10,%esp
  sleep(1);
 383:	83 ec 0c             	sub    $0xc,%esp
 386:	6a 01                	push   $0x1
 388:	e8 13 03 00 00       	call   6a0 <sleep>
 38d:	83 c4 10             	add    $0x10,%esp
  exit();
 390:	e8 7b 02 00 00       	call   610 <exit>

00000395 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 395:	55                   	push   %ebp
 396:	89 e5                	mov    %esp,%ebp
 398:	57                   	push   %edi
 399:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 39a:	8b 4d 08             	mov    0x8(%ebp),%ecx
 39d:	8b 55 10             	mov    0x10(%ebp),%edx
 3a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a3:	89 cb                	mov    %ecx,%ebx
 3a5:	89 df                	mov    %ebx,%edi
 3a7:	89 d1                	mov    %edx,%ecx
 3a9:	fc                   	cld
 3aa:	f3 aa                	rep stos %al,%es:(%edi)
 3ac:	89 ca                	mov    %ecx,%edx
 3ae:	89 fb                	mov    %edi,%ebx
 3b0:	89 5d 08             	mov    %ebx,0x8(%ebp)
 3b3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3b6:	90                   	nop
 3b7:	5b                   	pop    %ebx
 3b8:	5f                   	pop    %edi
 3b9:	5d                   	pop    %ebp
 3ba:	c3                   	ret

000003bb <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 3bb:	f3 0f 1e fb          	endbr32
 3bf:	55                   	push   %ebp
 3c0:	89 e5                	mov    %esp,%ebp
 3c2:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 3c5:	8b 45 08             	mov    0x8(%ebp),%eax
 3c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 3cb:	90                   	nop
 3cc:	8b 55 0c             	mov    0xc(%ebp),%edx
 3cf:	8d 42 01             	lea    0x1(%edx),%eax
 3d2:	89 45 0c             	mov    %eax,0xc(%ebp)
 3d5:	8b 45 08             	mov    0x8(%ebp),%eax
 3d8:	8d 48 01             	lea    0x1(%eax),%ecx
 3db:	89 4d 08             	mov    %ecx,0x8(%ebp)
 3de:	0f b6 12             	movzbl (%edx),%edx
 3e1:	88 10                	mov    %dl,(%eax)
 3e3:	0f b6 00             	movzbl (%eax),%eax
 3e6:	84 c0                	test   %al,%al
 3e8:	75 e2                	jne    3cc <strcpy+0x11>
    ;
  return os;
 3ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3ed:	c9                   	leave
 3ee:	c3                   	ret

000003ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3ef:	f3 0f 1e fb          	endbr32
 3f3:	55                   	push   %ebp
 3f4:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3f6:	eb 08                	jmp    400 <strcmp+0x11>
    p++, q++;
 3f8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3fc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 400:	8b 45 08             	mov    0x8(%ebp),%eax
 403:	0f b6 00             	movzbl (%eax),%eax
 406:	84 c0                	test   %al,%al
 408:	74 10                	je     41a <strcmp+0x2b>
 40a:	8b 45 08             	mov    0x8(%ebp),%eax
 40d:	0f b6 10             	movzbl (%eax),%edx
 410:	8b 45 0c             	mov    0xc(%ebp),%eax
 413:	0f b6 00             	movzbl (%eax),%eax
 416:	38 c2                	cmp    %al,%dl
 418:	74 de                	je     3f8 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 41a:	8b 45 08             	mov    0x8(%ebp),%eax
 41d:	0f b6 00             	movzbl (%eax),%eax
 420:	0f b6 d0             	movzbl %al,%edx
 423:	8b 45 0c             	mov    0xc(%ebp),%eax
 426:	0f b6 00             	movzbl (%eax),%eax
 429:	0f b6 c0             	movzbl %al,%eax
 42c:	29 c2                	sub    %eax,%edx
 42e:	89 d0                	mov    %edx,%eax
}
 430:	5d                   	pop    %ebp
 431:	c3                   	ret

00000432 <strlen>:

uint
strlen(char *s)
{
 432:	f3 0f 1e fb          	endbr32
 436:	55                   	push   %ebp
 437:	89 e5                	mov    %esp,%ebp
 439:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 43c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 443:	eb 04                	jmp    449 <strlen+0x17>
 445:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 449:	8b 55 fc             	mov    -0x4(%ebp),%edx
 44c:	8b 45 08             	mov    0x8(%ebp),%eax
 44f:	01 d0                	add    %edx,%eax
 451:	0f b6 00             	movzbl (%eax),%eax
 454:	84 c0                	test   %al,%al
 456:	75 ed                	jne    445 <strlen+0x13>
    ;
  return n;
 458:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 45b:	c9                   	leave
 45c:	c3                   	ret

0000045d <memset>:

void*
memset(void *dst, int c, uint n)
{
 45d:	f3 0f 1e fb          	endbr32
 461:	55                   	push   %ebp
 462:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 464:	8b 45 10             	mov    0x10(%ebp),%eax
 467:	50                   	push   %eax
 468:	ff 75 0c             	push   0xc(%ebp)
 46b:	ff 75 08             	push   0x8(%ebp)
 46e:	e8 22 ff ff ff       	call   395 <stosb>
 473:	83 c4 0c             	add    $0xc,%esp
  return dst;
 476:	8b 45 08             	mov    0x8(%ebp),%eax
}
 479:	c9                   	leave
 47a:	c3                   	ret

0000047b <strchr>:

char*
strchr(const char *s, char c)
{
 47b:	f3 0f 1e fb          	endbr32
 47f:	55                   	push   %ebp
 480:	89 e5                	mov    %esp,%ebp
 482:	83 ec 04             	sub    $0x4,%esp
 485:	8b 45 0c             	mov    0xc(%ebp),%eax
 488:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 48b:	eb 14                	jmp    4a1 <strchr+0x26>
    if(*s == c)
 48d:	8b 45 08             	mov    0x8(%ebp),%eax
 490:	0f b6 00             	movzbl (%eax),%eax
 493:	38 45 fc             	cmp    %al,-0x4(%ebp)
 496:	75 05                	jne    49d <strchr+0x22>
      return (char*)s;
 498:	8b 45 08             	mov    0x8(%ebp),%eax
 49b:	eb 13                	jmp    4b0 <strchr+0x35>
  for(; *s; s++)
 49d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4a1:	8b 45 08             	mov    0x8(%ebp),%eax
 4a4:	0f b6 00             	movzbl (%eax),%eax
 4a7:	84 c0                	test   %al,%al
 4a9:	75 e2                	jne    48d <strchr+0x12>
  return 0;
 4ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
 4b0:	c9                   	leave
 4b1:	c3                   	ret

000004b2 <gets>:

char*
gets(char *buf, int max)
{
 4b2:	f3 0f 1e fb          	endbr32
 4b6:	55                   	push   %ebp
 4b7:	89 e5                	mov    %esp,%ebp
 4b9:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 4c3:	eb 42                	jmp    507 <gets+0x55>
    cc = read(0, &c, 1);
 4c5:	83 ec 04             	sub    $0x4,%esp
 4c8:	6a 01                	push   $0x1
 4ca:	8d 45 ef             	lea    -0x11(%ebp),%eax
 4cd:	50                   	push   %eax
 4ce:	6a 00                	push   $0x0
 4d0:	e8 53 01 00 00       	call   628 <read>
 4d5:	83 c4 10             	add    $0x10,%esp
 4d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4df:	7e 33                	jle    514 <gets+0x62>
      break;
    buf[i++] = c;
 4e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e4:	8d 50 01             	lea    0x1(%eax),%edx
 4e7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4ea:	89 c2                	mov    %eax,%edx
 4ec:	8b 45 08             	mov    0x8(%ebp),%eax
 4ef:	01 c2                	add    %eax,%edx
 4f1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4f5:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4f7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4fb:	3c 0a                	cmp    $0xa,%al
 4fd:	74 16                	je     515 <gets+0x63>
 4ff:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 503:	3c 0d                	cmp    $0xd,%al
 505:	74 0e                	je     515 <gets+0x63>
  for(i=0; i+1 < max; ){
 507:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50a:	83 c0 01             	add    $0x1,%eax
 50d:	39 45 0c             	cmp    %eax,0xc(%ebp)
 510:	7f b3                	jg     4c5 <gets+0x13>
 512:	eb 01                	jmp    515 <gets+0x63>
      break;
 514:	90                   	nop
      break;
  }
  buf[i] = '\0';
 515:	8b 55 f4             	mov    -0xc(%ebp),%edx
 518:	8b 45 08             	mov    0x8(%ebp),%eax
 51b:	01 d0                	add    %edx,%eax
 51d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 520:	8b 45 08             	mov    0x8(%ebp),%eax
}
 523:	c9                   	leave
 524:	c3                   	ret

00000525 <stat>:

int
stat(char *n, struct stat *st)
{
 525:	f3 0f 1e fb          	endbr32
 529:	55                   	push   %ebp
 52a:	89 e5                	mov    %esp,%ebp
 52c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 52f:	83 ec 08             	sub    $0x8,%esp
 532:	6a 00                	push   $0x0
 534:	ff 75 08             	push   0x8(%ebp)
 537:	e8 14 01 00 00       	call   650 <open>
 53c:	83 c4 10             	add    $0x10,%esp
 53f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 542:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 546:	79 07                	jns    54f <stat+0x2a>
    return -1;
 548:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 54d:	eb 25                	jmp    574 <stat+0x4f>
  r = fstat(fd, st);
 54f:	83 ec 08             	sub    $0x8,%esp
 552:	ff 75 0c             	push   0xc(%ebp)
 555:	ff 75 f4             	push   -0xc(%ebp)
 558:	e8 0b 01 00 00       	call   668 <fstat>
 55d:	83 c4 10             	add    $0x10,%esp
 560:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 563:	83 ec 0c             	sub    $0xc,%esp
 566:	ff 75 f4             	push   -0xc(%ebp)
 569:	e8 ca 00 00 00       	call   638 <close>
 56e:	83 c4 10             	add    $0x10,%esp
  return r;
 571:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 574:	c9                   	leave
 575:	c3                   	ret

00000576 <atoi>:

int
atoi(const char *s)
{
 576:	f3 0f 1e fb          	endbr32
 57a:	55                   	push   %ebp
 57b:	89 e5                	mov    %esp,%ebp
 57d:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 580:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 587:	eb 25                	jmp    5ae <atoi+0x38>
    n = n*10 + *s++ - '0';
 589:	8b 55 fc             	mov    -0x4(%ebp),%edx
 58c:	89 d0                	mov    %edx,%eax
 58e:	c1 e0 02             	shl    $0x2,%eax
 591:	01 d0                	add    %edx,%eax
 593:	01 c0                	add    %eax,%eax
 595:	89 c1                	mov    %eax,%ecx
 597:	8b 45 08             	mov    0x8(%ebp),%eax
 59a:	8d 50 01             	lea    0x1(%eax),%edx
 59d:	89 55 08             	mov    %edx,0x8(%ebp)
 5a0:	0f b6 00             	movzbl (%eax),%eax
 5a3:	0f be c0             	movsbl %al,%eax
 5a6:	01 c8                	add    %ecx,%eax
 5a8:	83 e8 30             	sub    $0x30,%eax
 5ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 5ae:	8b 45 08             	mov    0x8(%ebp),%eax
 5b1:	0f b6 00             	movzbl (%eax),%eax
 5b4:	3c 2f                	cmp    $0x2f,%al
 5b6:	7e 0a                	jle    5c2 <atoi+0x4c>
 5b8:	8b 45 08             	mov    0x8(%ebp),%eax
 5bb:	0f b6 00             	movzbl (%eax),%eax
 5be:	3c 39                	cmp    $0x39,%al
 5c0:	7e c7                	jle    589 <atoi+0x13>
  return n;
 5c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5c5:	c9                   	leave
 5c6:	c3                   	ret

000005c7 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 5c7:	f3 0f 1e fb          	endbr32
 5cb:	55                   	push   %ebp
 5cc:	89 e5                	mov    %esp,%ebp
 5ce:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 5d1:	8b 45 08             	mov    0x8(%ebp),%eax
 5d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 5d7:	8b 45 0c             	mov    0xc(%ebp),%eax
 5da:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5dd:	eb 17                	jmp    5f6 <memmove+0x2f>
    *dst++ = *src++;
 5df:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5e2:	8d 42 01             	lea    0x1(%edx),%eax
 5e5:	89 45 f8             	mov    %eax,-0x8(%ebp)
 5e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5eb:	8d 48 01             	lea    0x1(%eax),%ecx
 5ee:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 5f1:	0f b6 12             	movzbl (%edx),%edx
 5f4:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 5f6:	8b 45 10             	mov    0x10(%ebp),%eax
 5f9:	8d 50 ff             	lea    -0x1(%eax),%edx
 5fc:	89 55 10             	mov    %edx,0x10(%ebp)
 5ff:	85 c0                	test   %eax,%eax
 601:	7f dc                	jg     5df <memmove+0x18>
  return vdst;
 603:	8b 45 08             	mov    0x8(%ebp),%eax
}
 606:	c9                   	leave
 607:	c3                   	ret

00000608 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 608:	b8 01 00 00 00       	mov    $0x1,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret

00000610 <exit>:
SYSCALL(exit)
 610:	b8 02 00 00 00       	mov    $0x2,%eax
 615:	cd 40                	int    $0x40
 617:	c3                   	ret

00000618 <wait>:
SYSCALL(wait)
 618:	b8 03 00 00 00       	mov    $0x3,%eax
 61d:	cd 40                	int    $0x40
 61f:	c3                   	ret

00000620 <pipe>:
SYSCALL(pipe)
 620:	b8 04 00 00 00       	mov    $0x4,%eax
 625:	cd 40                	int    $0x40
 627:	c3                   	ret

00000628 <read>:
SYSCALL(read)
 628:	b8 05 00 00 00       	mov    $0x5,%eax
 62d:	cd 40                	int    $0x40
 62f:	c3                   	ret

00000630 <write>:
SYSCALL(write)
 630:	b8 10 00 00 00       	mov    $0x10,%eax
 635:	cd 40                	int    $0x40
 637:	c3                   	ret

00000638 <close>:
SYSCALL(close)
 638:	b8 15 00 00 00       	mov    $0x15,%eax
 63d:	cd 40                	int    $0x40
 63f:	c3                   	ret

00000640 <kill>:
SYSCALL(kill)
 640:	b8 06 00 00 00       	mov    $0x6,%eax
 645:	cd 40                	int    $0x40
 647:	c3                   	ret

00000648 <exec>:
SYSCALL(exec)
 648:	b8 07 00 00 00       	mov    $0x7,%eax
 64d:	cd 40                	int    $0x40
 64f:	c3                   	ret

00000650 <open>:
SYSCALL(open)
 650:	b8 0f 00 00 00       	mov    $0xf,%eax
 655:	cd 40                	int    $0x40
 657:	c3                   	ret

00000658 <mknod>:
SYSCALL(mknod)
 658:	b8 11 00 00 00       	mov    $0x11,%eax
 65d:	cd 40                	int    $0x40
 65f:	c3                   	ret

00000660 <unlink>:
SYSCALL(unlink)
 660:	b8 12 00 00 00       	mov    $0x12,%eax
 665:	cd 40                	int    $0x40
 667:	c3                   	ret

00000668 <fstat>:
SYSCALL(fstat)
 668:	b8 08 00 00 00       	mov    $0x8,%eax
 66d:	cd 40                	int    $0x40
 66f:	c3                   	ret

00000670 <link>:
SYSCALL(link)
 670:	b8 13 00 00 00       	mov    $0x13,%eax
 675:	cd 40                	int    $0x40
 677:	c3                   	ret

00000678 <mkdir>:
SYSCALL(mkdir)
 678:	b8 14 00 00 00       	mov    $0x14,%eax
 67d:	cd 40                	int    $0x40
 67f:	c3                   	ret

00000680 <chdir>:
SYSCALL(chdir)
 680:	b8 09 00 00 00       	mov    $0x9,%eax
 685:	cd 40                	int    $0x40
 687:	c3                   	ret

00000688 <dup>:
SYSCALL(dup)
 688:	b8 0a 00 00 00       	mov    $0xa,%eax
 68d:	cd 40                	int    $0x40
 68f:	c3                   	ret

00000690 <getpid>:
SYSCALL(getpid)
 690:	b8 0b 00 00 00       	mov    $0xb,%eax
 695:	cd 40                	int    $0x40
 697:	c3                   	ret

00000698 <sbrk>:
SYSCALL(sbrk)
 698:	b8 0c 00 00 00       	mov    $0xc,%eax
 69d:	cd 40                	int    $0x40
 69f:	c3                   	ret

000006a0 <sleep>:
SYSCALL(sleep)
 6a0:	b8 0d 00 00 00       	mov    $0xd,%eax
 6a5:	cd 40                	int    $0x40
 6a7:	c3                   	ret

000006a8 <uptime>:
SYSCALL(uptime)
 6a8:	b8 0e 00 00 00       	mov    $0xe,%eax
 6ad:	cd 40                	int    $0x40
 6af:	c3                   	ret

000006b0 <getpinfo>:

SYSCALL(getpinfo)
 6b0:	b8 16 00 00 00       	mov    $0x16,%eax
 6b5:	cd 40                	int    $0x40
 6b7:	c3                   	ret

000006b8 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 6b8:	b8 17 00 00 00       	mov    $0x17,%eax
 6bd:	cd 40                	int    $0x40
 6bf:	c3                   	ret

000006c0 <yield>:
SYSCALL(yield)
 6c0:	b8 18 00 00 00       	mov    $0x18,%eax
 6c5:	cd 40                	int    $0x40
 6c7:	c3                   	ret

000006c8 <getSchedPolicy>:
 6c8:	b8 19 00 00 00       	mov    $0x19,%eax
 6cd:	cd 40                	int    $0x40
 6cf:	c3                   	ret

000006d0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 6d0:	f3 0f 1e fb          	endbr32
 6d4:	55                   	push   %ebp
 6d5:	89 e5                	mov    %esp,%ebp
 6d7:	83 ec 18             	sub    $0x18,%esp
 6da:	8b 45 0c             	mov    0xc(%ebp),%eax
 6dd:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 6e0:	83 ec 04             	sub    $0x4,%esp
 6e3:	6a 01                	push   $0x1
 6e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6e8:	50                   	push   %eax
 6e9:	ff 75 08             	push   0x8(%ebp)
 6ec:	e8 3f ff ff ff       	call   630 <write>
 6f1:	83 c4 10             	add    $0x10,%esp
}
 6f4:	90                   	nop
 6f5:	c9                   	leave
 6f6:	c3                   	ret

000006f7 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6f7:	f3 0f 1e fb          	endbr32
 6fb:	55                   	push   %ebp
 6fc:	89 e5                	mov    %esp,%ebp
 6fe:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 701:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 708:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 70c:	74 17                	je     725 <printint+0x2e>
 70e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 712:	79 11                	jns    725 <printint+0x2e>
    neg = 1;
 714:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 71b:	8b 45 0c             	mov    0xc(%ebp),%eax
 71e:	f7 d8                	neg    %eax
 720:	89 45 ec             	mov    %eax,-0x14(%ebp)
 723:	eb 06                	jmp    72b <printint+0x34>
  } else {
    x = xx;
 725:	8b 45 0c             	mov    0xc(%ebp),%eax
 728:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 72b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 732:	8b 4d 10             	mov    0x10(%ebp),%ecx
 735:	8b 45 ec             	mov    -0x14(%ebp),%eax
 738:	ba 00 00 00 00       	mov    $0x0,%edx
 73d:	f7 f1                	div    %ecx
 73f:	89 d1                	mov    %edx,%ecx
 741:	8b 45 f4             	mov    -0xc(%ebp),%eax
 744:	8d 50 01             	lea    0x1(%eax),%edx
 747:	89 55 f4             	mov    %edx,-0xc(%ebp)
 74a:	0f b6 91 78 10 00 00 	movzbl 0x1078(%ecx),%edx
 751:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 755:	8b 4d 10             	mov    0x10(%ebp),%ecx
 758:	8b 45 ec             	mov    -0x14(%ebp),%eax
 75b:	ba 00 00 00 00       	mov    $0x0,%edx
 760:	f7 f1                	div    %ecx
 762:	89 45 ec             	mov    %eax,-0x14(%ebp)
 765:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 769:	75 c7                	jne    732 <printint+0x3b>
  if(neg)
 76b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 76f:	74 2d                	je     79e <printint+0xa7>
    buf[i++] = '-';
 771:	8b 45 f4             	mov    -0xc(%ebp),%eax
 774:	8d 50 01             	lea    0x1(%eax),%edx
 777:	89 55 f4             	mov    %edx,-0xc(%ebp)
 77a:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 77f:	eb 1d                	jmp    79e <printint+0xa7>
    putc(fd, buf[i]);
 781:	8d 55 dc             	lea    -0x24(%ebp),%edx
 784:	8b 45 f4             	mov    -0xc(%ebp),%eax
 787:	01 d0                	add    %edx,%eax
 789:	0f b6 00             	movzbl (%eax),%eax
 78c:	0f be c0             	movsbl %al,%eax
 78f:	83 ec 08             	sub    $0x8,%esp
 792:	50                   	push   %eax
 793:	ff 75 08             	push   0x8(%ebp)
 796:	e8 35 ff ff ff       	call   6d0 <putc>
 79b:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 79e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 7a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7a6:	79 d9                	jns    781 <printint+0x8a>
}
 7a8:	90                   	nop
 7a9:	90                   	nop
 7aa:	c9                   	leave
 7ab:	c3                   	ret

000007ac <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 7ac:	f3 0f 1e fb          	endbr32
 7b0:	55                   	push   %ebp
 7b1:	89 e5                	mov    %esp,%ebp
 7b3:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 7b6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 7bd:	8d 45 0c             	lea    0xc(%ebp),%eax
 7c0:	83 c0 04             	add    $0x4,%eax
 7c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 7c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 7cd:	e9 59 01 00 00       	jmp    92b <printf+0x17f>
    c = fmt[i] & 0xff;
 7d2:	8b 55 0c             	mov    0xc(%ebp),%edx
 7d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d8:	01 d0                	add    %edx,%eax
 7da:	0f b6 00             	movzbl (%eax),%eax
 7dd:	0f be c0             	movsbl %al,%eax
 7e0:	25 ff 00 00 00       	and    $0xff,%eax
 7e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7e8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7ec:	75 2c                	jne    81a <printf+0x6e>
      if(c == '%'){
 7ee:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7f2:	75 0c                	jne    800 <printf+0x54>
        state = '%';
 7f4:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7fb:	e9 27 01 00 00       	jmp    927 <printf+0x17b>
      } else {
        putc(fd, c);
 800:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 803:	0f be c0             	movsbl %al,%eax
 806:	83 ec 08             	sub    $0x8,%esp
 809:	50                   	push   %eax
 80a:	ff 75 08             	push   0x8(%ebp)
 80d:	e8 be fe ff ff       	call   6d0 <putc>
 812:	83 c4 10             	add    $0x10,%esp
 815:	e9 0d 01 00 00       	jmp    927 <printf+0x17b>
      }
    } else if(state == '%'){
 81a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 81e:	0f 85 03 01 00 00    	jne    927 <printf+0x17b>
      if(c == 'd'){
 824:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 828:	75 1e                	jne    848 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 82a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 82d:	8b 00                	mov    (%eax),%eax
 82f:	6a 01                	push   $0x1
 831:	6a 0a                	push   $0xa
 833:	50                   	push   %eax
 834:	ff 75 08             	push   0x8(%ebp)
 837:	e8 bb fe ff ff       	call   6f7 <printint>
 83c:	83 c4 10             	add    $0x10,%esp
        ap++;
 83f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 843:	e9 d8 00 00 00       	jmp    920 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 848:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 84c:	74 06                	je     854 <printf+0xa8>
 84e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 852:	75 1e                	jne    872 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 854:	8b 45 e8             	mov    -0x18(%ebp),%eax
 857:	8b 00                	mov    (%eax),%eax
 859:	6a 00                	push   $0x0
 85b:	6a 10                	push   $0x10
 85d:	50                   	push   %eax
 85e:	ff 75 08             	push   0x8(%ebp)
 861:	e8 91 fe ff ff       	call   6f7 <printint>
 866:	83 c4 10             	add    $0x10,%esp
        ap++;
 869:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 86d:	e9 ae 00 00 00       	jmp    920 <printf+0x174>
      } else if(c == 's'){
 872:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 876:	75 43                	jne    8bb <printf+0x10f>
        s = (char*)*ap;
 878:	8b 45 e8             	mov    -0x18(%ebp),%eax
 87b:	8b 00                	mov    (%eax),%eax
 87d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 880:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 884:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 888:	75 25                	jne    8af <printf+0x103>
          s = "(null)";
 88a:	c7 45 f4 bb 0d 00 00 	movl   $0xdbb,-0xc(%ebp)
        while(*s != 0){
 891:	eb 1c                	jmp    8af <printf+0x103>
          putc(fd, *s);
 893:	8b 45 f4             	mov    -0xc(%ebp),%eax
 896:	0f b6 00             	movzbl (%eax),%eax
 899:	0f be c0             	movsbl %al,%eax
 89c:	83 ec 08             	sub    $0x8,%esp
 89f:	50                   	push   %eax
 8a0:	ff 75 08             	push   0x8(%ebp)
 8a3:	e8 28 fe ff ff       	call   6d0 <putc>
 8a8:	83 c4 10             	add    $0x10,%esp
          s++;
 8ab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 8af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b2:	0f b6 00             	movzbl (%eax),%eax
 8b5:	84 c0                	test   %al,%al
 8b7:	75 da                	jne    893 <printf+0xe7>
 8b9:	eb 65                	jmp    920 <printf+0x174>
        }
      } else if(c == 'c'){
 8bb:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 8bf:	75 1d                	jne    8de <printf+0x132>
        putc(fd, *ap);
 8c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8c4:	8b 00                	mov    (%eax),%eax
 8c6:	0f be c0             	movsbl %al,%eax
 8c9:	83 ec 08             	sub    $0x8,%esp
 8cc:	50                   	push   %eax
 8cd:	ff 75 08             	push   0x8(%ebp)
 8d0:	e8 fb fd ff ff       	call   6d0 <putc>
 8d5:	83 c4 10             	add    $0x10,%esp
        ap++;
 8d8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8dc:	eb 42                	jmp    920 <printf+0x174>
      } else if(c == '%'){
 8de:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8e2:	75 17                	jne    8fb <printf+0x14f>
        putc(fd, c);
 8e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8e7:	0f be c0             	movsbl %al,%eax
 8ea:	83 ec 08             	sub    $0x8,%esp
 8ed:	50                   	push   %eax
 8ee:	ff 75 08             	push   0x8(%ebp)
 8f1:	e8 da fd ff ff       	call   6d0 <putc>
 8f6:	83 c4 10             	add    $0x10,%esp
 8f9:	eb 25                	jmp    920 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8fb:	83 ec 08             	sub    $0x8,%esp
 8fe:	6a 25                	push   $0x25
 900:	ff 75 08             	push   0x8(%ebp)
 903:	e8 c8 fd ff ff       	call   6d0 <putc>
 908:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 90b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 90e:	0f be c0             	movsbl %al,%eax
 911:	83 ec 08             	sub    $0x8,%esp
 914:	50                   	push   %eax
 915:	ff 75 08             	push   0x8(%ebp)
 918:	e8 b3 fd ff ff       	call   6d0 <putc>
 91d:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 920:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 927:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 92b:	8b 55 0c             	mov    0xc(%ebp),%edx
 92e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 931:	01 d0                	add    %edx,%eax
 933:	0f b6 00             	movzbl (%eax),%eax
 936:	84 c0                	test   %al,%al
 938:	0f 85 94 fe ff ff    	jne    7d2 <printf+0x26>
    }
  }
}
 93e:	90                   	nop
 93f:	90                   	nop
 940:	c9                   	leave
 941:	c3                   	ret

00000942 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 942:	f3 0f 1e fb          	endbr32
 946:	55                   	push   %ebp
 947:	89 e5                	mov    %esp,%ebp
 949:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 94c:	8b 45 08             	mov    0x8(%ebp),%eax
 94f:	83 e8 08             	sub    $0x8,%eax
 952:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 955:	a1 94 10 00 00       	mov    0x1094,%eax
 95a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 95d:	eb 24                	jmp    983 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 95f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 962:	8b 00                	mov    (%eax),%eax
 964:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 967:	72 12                	jb     97b <free+0x39>
 969:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 96f:	77 24                	ja     995 <free+0x53>
 971:	8b 45 fc             	mov    -0x4(%ebp),%eax
 974:	8b 00                	mov    (%eax),%eax
 976:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 979:	72 1a                	jb     995 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 97b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97e:	8b 00                	mov    (%eax),%eax
 980:	89 45 fc             	mov    %eax,-0x4(%ebp)
 983:	8b 45 f8             	mov    -0x8(%ebp),%eax
 986:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 989:	76 d4                	jbe    95f <free+0x1d>
 98b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98e:	8b 00                	mov    (%eax),%eax
 990:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 993:	73 ca                	jae    95f <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 995:	8b 45 f8             	mov    -0x8(%ebp),%eax
 998:	8b 40 04             	mov    0x4(%eax),%eax
 99b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a5:	01 c2                	add    %eax,%edx
 9a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9aa:	8b 00                	mov    (%eax),%eax
 9ac:	39 c2                	cmp    %eax,%edx
 9ae:	75 24                	jne    9d4 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 9b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b3:	8b 50 04             	mov    0x4(%eax),%edx
 9b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b9:	8b 00                	mov    (%eax),%eax
 9bb:	8b 40 04             	mov    0x4(%eax),%eax
 9be:	01 c2                	add    %eax,%edx
 9c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c3:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c9:	8b 00                	mov    (%eax),%eax
 9cb:	8b 10                	mov    (%eax),%edx
 9cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9d0:	89 10                	mov    %edx,(%eax)
 9d2:	eb 0a                	jmp    9de <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 9d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d7:	8b 10                	mov    (%eax),%edx
 9d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9dc:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9de:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e1:	8b 40 04             	mov    0x4(%eax),%eax
 9e4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ee:	01 d0                	add    %edx,%eax
 9f0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9f3:	75 20                	jne    a15 <free+0xd3>
    p->s.size += bp->s.size;
 9f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f8:	8b 50 04             	mov    0x4(%eax),%edx
 9fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9fe:	8b 40 04             	mov    0x4(%eax),%eax
 a01:	01 c2                	add    %eax,%edx
 a03:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a06:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a09:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a0c:	8b 10                	mov    (%eax),%edx
 a0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a11:	89 10                	mov    %edx,(%eax)
 a13:	eb 08                	jmp    a1d <free+0xdb>
  } else
    p->s.ptr = bp;
 a15:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a18:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a1b:	89 10                	mov    %edx,(%eax)
  freep = p;
 a1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a20:	a3 94 10 00 00       	mov    %eax,0x1094
}
 a25:	90                   	nop
 a26:	c9                   	leave
 a27:	c3                   	ret

00000a28 <morecore>:

static Header*
morecore(uint nu)
{
 a28:	f3 0f 1e fb          	endbr32
 a2c:	55                   	push   %ebp
 a2d:	89 e5                	mov    %esp,%ebp
 a2f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a32:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a39:	77 07                	ja     a42 <morecore+0x1a>
    nu = 4096;
 a3b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a42:	8b 45 08             	mov    0x8(%ebp),%eax
 a45:	c1 e0 03             	shl    $0x3,%eax
 a48:	83 ec 0c             	sub    $0xc,%esp
 a4b:	50                   	push   %eax
 a4c:	e8 47 fc ff ff       	call   698 <sbrk>
 a51:	83 c4 10             	add    $0x10,%esp
 a54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a57:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a5b:	75 07                	jne    a64 <morecore+0x3c>
    return 0;
 a5d:	b8 00 00 00 00       	mov    $0x0,%eax
 a62:	eb 26                	jmp    a8a <morecore+0x62>
  hp = (Header*)p;
 a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a67:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a6d:	8b 55 08             	mov    0x8(%ebp),%edx
 a70:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a76:	83 c0 08             	add    $0x8,%eax
 a79:	83 ec 0c             	sub    $0xc,%esp
 a7c:	50                   	push   %eax
 a7d:	e8 c0 fe ff ff       	call   942 <free>
 a82:	83 c4 10             	add    $0x10,%esp
  return freep;
 a85:	a1 94 10 00 00       	mov    0x1094,%eax
}
 a8a:	c9                   	leave
 a8b:	c3                   	ret

00000a8c <malloc>:

void*
malloc(uint nbytes)
{
 a8c:	f3 0f 1e fb          	endbr32
 a90:	55                   	push   %ebp
 a91:	89 e5                	mov    %esp,%ebp
 a93:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a96:	8b 45 08             	mov    0x8(%ebp),%eax
 a99:	83 c0 07             	add    $0x7,%eax
 a9c:	c1 e8 03             	shr    $0x3,%eax
 a9f:	83 c0 01             	add    $0x1,%eax
 aa2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 aa5:	a1 94 10 00 00       	mov    0x1094,%eax
 aaa:	89 45 f0             	mov    %eax,-0x10(%ebp)
 aad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 ab1:	75 23                	jne    ad6 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 ab3:	c7 45 f0 8c 10 00 00 	movl   $0x108c,-0x10(%ebp)
 aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
 abd:	a3 94 10 00 00       	mov    %eax,0x1094
 ac2:	a1 94 10 00 00       	mov    0x1094,%eax
 ac7:	a3 8c 10 00 00       	mov    %eax,0x108c
    base.s.size = 0;
 acc:	c7 05 90 10 00 00 00 	movl   $0x0,0x1090
 ad3:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ad9:	8b 00                	mov    (%eax),%eax
 adb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae1:	8b 40 04             	mov    0x4(%eax),%eax
 ae4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 ae7:	77 4d                	ja     b36 <malloc+0xaa>
      if(p->s.size == nunits)
 ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aec:	8b 40 04             	mov    0x4(%eax),%eax
 aef:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 af2:	75 0c                	jne    b00 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af7:	8b 10                	mov    (%eax),%edx
 af9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 afc:	89 10                	mov    %edx,(%eax)
 afe:	eb 26                	jmp    b26 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b03:	8b 40 04             	mov    0x4(%eax),%eax
 b06:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b09:	89 c2                	mov    %eax,%edx
 b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b0e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b14:	8b 40 04             	mov    0x4(%eax),%eax
 b17:	c1 e0 03             	shl    $0x3,%eax
 b1a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b20:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b23:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b29:	a3 94 10 00 00       	mov    %eax,0x1094
      return (void*)(p + 1);
 b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b31:	83 c0 08             	add    $0x8,%eax
 b34:	eb 3b                	jmp    b71 <malloc+0xe5>
    }
    if(p == freep)
 b36:	a1 94 10 00 00       	mov    0x1094,%eax
 b3b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b3e:	75 1e                	jne    b5e <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 b40:	83 ec 0c             	sub    $0xc,%esp
 b43:	ff 75 ec             	push   -0x14(%ebp)
 b46:	e8 dd fe ff ff       	call   a28 <morecore>
 b4b:	83 c4 10             	add    $0x10,%esp
 b4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b55:	75 07                	jne    b5e <malloc+0xd2>
        return 0;
 b57:	b8 00 00 00 00       	mov    $0x0,%eax
 b5c:	eb 13                	jmp    b71 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b61:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b67:	8b 00                	mov    (%eax),%eax
 b69:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b6c:	e9 6d ff ff ff       	jmp    ade <malloc+0x52>
  }
}
 b71:	c9                   	leave
 b72:	c3                   	ret
