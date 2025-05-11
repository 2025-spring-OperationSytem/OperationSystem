
_mlfq_test2:     file format elf32-i386


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
  for (i = 0; i < n; i++) {
   d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  14:	eb 6c                	jmp    82 <workload+0x82>
    if (i % 100000 == 0) {
  16:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  19:	ba 89 b5 f8 14       	mov    $0x14f8b589,%edx
  1e:	89 c8                	mov    %ecx,%eax
  20:	f7 ea                	imul   %edx
  22:	89 d0                	mov    %edx,%eax
  24:	c1 f8 0d             	sar    $0xd,%eax
  27:	89 ca                	mov    %ecx,%edx
  29:	c1 fa 1f             	sar    $0x1f,%edx
  2c:	29 d0                	sub    %edx,%eax
  2e:	69 d0 a0 86 01 00    	imul   $0x186a0,%eax,%edx
  34:	89 c8                	mov    %ecx,%eax
  36:	29 d0                	sub    %edx,%eax
  38:	85 c0                	test   %eax,%eax
  3a:	75 35                	jne    71 <workload+0x71>
      printf(1, "[CHEAT] PID %d yielding at i = %d\n", getpid(), i);
  3c:	e8 1e 06 00 00       	call   65f <getpid>
  41:	ff 75 f4             	push   -0xc(%ebp)
  44:	50                   	push   %eax
  45:	68 2c 0b 00 00       	push   $0xb2c
  4a:	6a 01                	push   $0x1
  4c:	e8 22 07 00 00       	call   773 <printf>
  51:	83 c4 10             	add    $0x10,%esp
      yield();
  54:	e8 36 06 00 00       	call   68f <yield>
      printf(1, "[CHEAT] PID %d resumed after yield at i = %d\n", getpid(), i);
  59:	e8 01 06 00 00       	call   65f <getpid>
  5e:	ff 75 f4             	push   -0xc(%ebp)
  61:	50                   	push   %eax
  62:	68 50 0b 00 00       	push   $0xb50
  67:	6a 01                	push   $0x1
  69:	e8 05 07 00 00       	call   773 <printf>
  6e:	83 c4 10             	add    $0x10,%esp
    }
    j += i * j + 1;
  71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  74:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  78:	83 c0 01             	add    $0x1,%eax
  7b:	01 45 f0             	add    %eax,-0x10(%ebp)
  for (i = 0; i < n; i++) {
  7e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  85:	3b 45 08             	cmp    0x8(%ebp),%eax
  88:	7c 8c                	jl     16 <workload+0x16>
  }
  return j;
  8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8d:	c9                   	leave
  8e:	c3                   	ret

0000008f <print_stat>:


void print_stat() {
  8f:	55                   	push   %ebp
  90:	89 e5                	mov    %esp,%ebp
  92:	57                   	push   %edi
  93:	56                   	push   %esi
  94:	53                   	push   %ebx
  95:	81 ec 2c 0c 00 00    	sub    $0xc2c,%esp
  struct pstat ps;
  getpinfo(&ps);
  9b:	83 ec 0c             	sub    $0xc,%esp
  9e:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
  a4:	50                   	push   %eax
  a5:	e8 d5 05 00 00       	call   67f <getpinfo>
  aa:	83 c4 10             	add    $0x10,%esp

  printf(1, "\n[RESULT] Process Statistics (Policy 2: No Tracking)\n");
  ad:	83 ec 08             	sub    $0x8,%esp
  b0:	68 80 0b 00 00       	push   $0xb80
  b5:	6a 01                	push   $0x1
  b7:	e8 b7 06 00 00       	call   773 <printf>
  bc:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROC; i++) {
  bf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  c6:	e9 0e 01 00 00       	jmp    1d9 <print_stat+0x14a>
    if (ps.inuse[i]) {
  cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  ce:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
  d5:	85 c0                	test   %eax,%eax
  d7:	0f 84 f8 00 00 00    	je     1d5 <print_stat+0x146>
      printf(1, "PID %d | Priority %d | Ticks: [Q3:%d Q2:%d Q1:%d Q0:%d] | Wait: [Q3:%d Q2:%d Q1:%d Q0:%d]\n",
  dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  e0:	83 e8 80             	sub    $0xffffff80,%eax
  e3:	c1 e0 04             	shl    $0x4,%eax
  e6:	8d 40 e8             	lea    -0x18(%eax),%eax
  e9:	01 e8                	add    %ebp,%eax
  eb:	2d 04 0c 00 00       	sub    $0xc04,%eax
  f0:	8b 30                	mov    (%eax),%esi
  f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  f5:	c1 e0 04             	shl    $0x4,%eax
  f8:	8d 40 e8             	lea    -0x18(%eax),%eax
  fb:	01 e8                	add    %ebp,%eax
  fd:	2d 00 04 00 00       	sub    $0x400,%eax
 102:	8b 38                	mov    (%eax),%edi
 104:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 107:	c1 e0 04             	shl    $0x4,%eax
 10a:	8d 40 e8             	lea    -0x18(%eax),%eax
 10d:	01 e8                	add    %ebp,%eax
 10f:	2d fc 03 00 00       	sub    $0x3fc,%eax
 114:	8b 00                	mov    (%eax),%eax
 116:	89 85 d4 f3 ff ff    	mov    %eax,-0xc2c(%ebp)
 11c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 11f:	c1 e0 04             	shl    $0x4,%eax
 122:	8d 50 e8             	lea    -0x18(%eax),%edx
 125:	8d 04 2a             	lea    (%edx,%ebp,1),%eax
 128:	2d f8 03 00 00       	sub    $0x3f8,%eax
 12d:	8b 08                	mov    (%eax),%ecx
 12f:	89 8d d0 f3 ff ff    	mov    %ecx,-0xc30(%ebp)
 135:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 138:	83 c0 40             	add    $0x40,%eax
 13b:	c1 e0 04             	shl    $0x4,%eax
 13e:	8d 58 e8             	lea    -0x18(%eax),%ebx
 141:	8d 04 2b             	lea    (%ebx,%ebp,1),%eax
 144:	2d 04 0c 00 00       	sub    $0xc04,%eax
 149:	8b 10                	mov    (%eax),%edx
 14b:	89 95 cc f3 ff ff    	mov    %edx,-0xc34(%ebp)
 151:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 154:	c1 e0 04             	shl    $0x4,%eax
 157:	8d 58 e8             	lea    -0x18(%eax),%ebx
 15a:	8d 04 2b             	lea    (%ebx,%ebp,1),%eax
 15d:	2d 00 08 00 00       	sub    $0x800,%eax
 162:	8b 18                	mov    (%eax),%ebx
 164:	89 9d c8 f3 ff ff    	mov    %ebx,-0xc38(%ebp)
 16a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 16d:	c1 e0 04             	shl    $0x4,%eax
 170:	8d 40 e8             	lea    -0x18(%eax),%eax
 173:	01 e8                	add    %ebp,%eax
 175:	2d fc 07 00 00       	sub    $0x7fc,%eax
 17a:	8b 18                	mov    (%eax),%ebx
 17c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 17f:	c1 e0 04             	shl    $0x4,%eax
 182:	8d 40 e8             	lea    -0x18(%eax),%eax
 185:	01 e8                	add    %ebp,%eax
 187:	2d f8 07 00 00       	sub    $0x7f8,%eax
 18c:	8b 08                	mov    (%eax),%ecx
 18e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 191:	83 e8 80             	sub    $0xffffff80,%eax
 194:	8b 94 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%edx
 19b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 19e:	83 c0 40             	add    $0x40,%eax
 1a1:	8b 84 85 e4 f3 ff ff 	mov    -0xc1c(%ebp,%eax,4),%eax
 1a8:	56                   	push   %esi
 1a9:	57                   	push   %edi
 1aa:	ff b5 d4 f3 ff ff    	push   -0xc2c(%ebp)
 1b0:	ff b5 d0 f3 ff ff    	push   -0xc30(%ebp)
 1b6:	ff b5 cc f3 ff ff    	push   -0xc34(%ebp)
 1bc:	ff b5 c8 f3 ff ff    	push   -0xc38(%ebp)
 1c2:	53                   	push   %ebx
 1c3:	51                   	push   %ecx
 1c4:	52                   	push   %edx
 1c5:	50                   	push   %eax
 1c6:	68 b8 0b 00 00       	push   $0xbb8
 1cb:	6a 01                	push   $0x1
 1cd:	e8 a1 05 00 00       	call   773 <printf>
 1d2:	83 c4 30             	add    $0x30,%esp
  for (int i = 0; i < NPROC; i++) {
 1d5:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 1d9:	83 7d e4 3f          	cmpl   $0x3f,-0x1c(%ebp)
 1dd:	0f 8e e8 fe ff ff    	jle    cb <print_stat+0x3c>
        ps.pid[i], ps.priority[i],
        ps.ticks[i][3], ps.ticks[i][2], ps.ticks[i][1], ps.ticks[i][0],
        ps.wait_ticks[i][3], ps.wait_ticks[i][2], ps.wait_ticks[i][1], ps.wait_ticks[i][0]);
    }
  }
}
 1e3:	90                   	nop
 1e4:	90                   	nop
 1e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1e8:	5b                   	pop    %ebx
 1e9:	5e                   	pop    %esi
 1ea:	5f                   	pop    %edi
 1eb:	5d                   	pop    %ebp
 1ec:	c3                   	ret

000001ed <run_policy_2>:

void run_policy_2() {
 1ed:	55                   	push   %ebp
 1ee:	89 e5                	mov    %esp,%ebp
 1f0:	83 ec 18             	sub    $0x18,%esp
  printf(1, "[DEBUG] Entered run_policy_2() - MLFQ without tracking (cheating possible)\n");
 1f3:	83 ec 08             	sub    $0x8,%esp
 1f6:	68 14 0c 00 00       	push   $0xc14
 1fb:	6a 01                	push   $0x1
 1fd:	e8 71 05 00 00       	call   773 <printf>
 202:	83 c4 10             	add    $0x10,%esp
  sleep(1);
 205:	83 ec 0c             	sub    $0xc,%esp
 208:	6a 01                	push   $0x1
 20a:	e8 60 04 00 00       	call   66f <sleep>
 20f:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < NPROCS; i++) {
 212:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 219:	e9 9e 00 00 00       	jmp    2bc <run_policy_2+0xcf>
    int pid = fork();
 21e:	e8 b4 03 00 00       	call   5d7 <fork>
 223:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (pid < 0) {
 226:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 22a:	79 22                	jns    24e <run_policy_2+0x61>
      printf(1, "[ERROR] fork failed at i=%d\n", i);
 22c:	83 ec 04             	sub    $0x4,%esp
 22f:	ff 75 f4             	push   -0xc(%ebp)
 232:	68 60 0c 00 00       	push   $0xc60
 237:	6a 01                	push   $0x1
 239:	e8 35 05 00 00       	call   773 <printf>
 23e:	83 c4 10             	add    $0x10,%esp
      sleep(1);
 241:	83 ec 0c             	sub    $0xc,%esp
 244:	6a 01                	push   $0x1
 246:	e8 24 04 00 00       	call   66f <sleep>
 24b:	83 c4 10             	add    $0x10,%esp
    }
    if (pid == 0) {
 24e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 252:	75 42                	jne    296 <run_policy_2+0xa9>
      printf(1, "[CHILD] i=%d, PID=%d\n", i, getpid());
 254:	e8 06 04 00 00       	call   65f <getpid>
 259:	50                   	push   %eax
 25a:	ff 75 f4             	push   -0xc(%ebp)
 25d:	68 7d 0c 00 00       	push   $0xc7d
 262:	6a 01                	push   $0x1
 264:	e8 0a 05 00 00       	call   773 <printf>
 269:	83 c4 10             	add    $0x10,%esp
      sleep(1);
 26c:	83 ec 0c             	sub    $0xc,%esp
 26f:	6a 01                	push   $0x1
 271:	e8 f9 03 00 00       	call   66f <sleep>
 276:	83 c4 10             	add    $0x10,%esp
      workload(50000000 * (i + 1));
 279:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27c:	83 c0 01             	add    $0x1,%eax
 27f:	69 c0 80 f0 fa 02    	imul   $0x2faf080,%eax,%eax
 285:	83 ec 0c             	sub    $0xc,%esp
 288:	50                   	push   %eax
 289:	e8 72 fd ff ff       	call   0 <workload>
 28e:	83 c4 10             	add    $0x10,%esp
      exit();
 291:	e8 49 03 00 00       	call   5df <exit>
    } else {
      printf(1, "[PARENT] forked child PID=%d at i=%d\n", pid, i);
 296:	ff 75 f4             	push   -0xc(%ebp)
 299:	ff 75 e8             	push   -0x18(%ebp)
 29c:	68 94 0c 00 00       	push   $0xc94
 2a1:	6a 01                	push   $0x1
 2a3:	e8 cb 04 00 00       	call   773 <printf>
 2a8:	83 c4 10             	add    $0x10,%esp
      sleep(1);
 2ab:	83 ec 0c             	sub    $0xc,%esp
 2ae:	6a 01                	push   $0x1
 2b0:	e8 ba 03 00 00       	call   66f <sleep>
 2b5:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROCS; i++) {
 2b8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 2bc:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
 2c0:	0f 8e 58 ff ff ff    	jle    21e <run_policy_2+0x31>
    }
  }

  printf(1, "[DEBUG] Setting sched_policy = 2 (no tracking)\n");
 2c6:	83 ec 08             	sub    $0x8,%esp
 2c9:	68 bc 0c 00 00       	push   $0xcbc
 2ce:	6a 01                	push   $0x1
 2d0:	e8 9e 04 00 00       	call   773 <printf>
 2d5:	83 c4 10             	add    $0x10,%esp
  setSchedPolicy(2);
 2d8:	83 ec 0c             	sub    $0xc,%esp
 2db:	6a 02                	push   $0x2
 2dd:	e8 a5 03 00 00       	call   687 <setSchedPolicy>
 2e2:	83 c4 10             	add    $0x10,%esp
  sleep(1);
 2e5:	83 ec 0c             	sub    $0xc,%esp
 2e8:	6a 01                	push   $0x1
 2ea:	e8 80 03 00 00       	call   66f <sleep>
 2ef:	83 c4 10             	add    $0x10,%esp

  int policy = getSchedPolicy();
 2f2:	e8 a0 03 00 00       	call   697 <getSchedPolicy>
 2f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  printf(1, "[DEBUG] Current sched_policy = %d\n", policy);
 2fa:	83 ec 04             	sub    $0x4,%esp
 2fd:	ff 75 ec             	push   -0x14(%ebp)
 300:	68 ec 0c 00 00       	push   $0xcec
 305:	6a 01                	push   $0x1
 307:	e8 67 04 00 00       	call   773 <printf>
 30c:	83 c4 10             	add    $0x10,%esp
  sleep(1);
 30f:	83 ec 0c             	sub    $0xc,%esp
 312:	6a 01                	push   $0x1
 314:	e8 56 03 00 00       	call   66f <sleep>
 319:	83 c4 10             	add    $0x10,%esp

  for (int i = 0; i < NPROCS; i++) wait();
 31c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 323:	eb 09                	jmp    32e <run_policy_2+0x141>
 325:	e8 bd 02 00 00       	call   5e7 <wait>
 32a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 32e:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
 332:	7e f1                	jle    325 <run_policy_2+0x138>

  print_stat();
 334:	e8 56 fd ff ff       	call   8f <print_stat>
}
 339:	90                   	nop
 33a:	c9                   	leave
 33b:	c3                   	ret

0000033c <main>:

int main(void) {
 33c:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 340:	83 e4 f0             	and    $0xfffffff0,%esp
 343:	ff 71 fc             	push   -0x4(%ecx)
 346:	55                   	push   %ebp
 347:	89 e5                	mov    %esp,%ebp
 349:	51                   	push   %ecx
 34a:	83 ec 04             	sub    $0x4,%esp
  printf(1, "\n===== [POLICY 2: MLFQ without tracking (cheating possible)] =====\n");
 34d:	83 ec 08             	sub    $0x8,%esp
 350:	68 10 0d 00 00       	push   $0xd10
 355:	6a 01                	push   $0x1
 357:	e8 17 04 00 00       	call   773 <printf>
 35c:	83 c4 10             	add    $0x10,%esp
  run_policy_2();
 35f:	e8 89 fe ff ff       	call   1ed <run_policy_2>
  printf(1, "\n===== [POLICY 2: exit] =====\n");
 364:	83 ec 08             	sub    $0x8,%esp
 367:	68 54 0d 00 00       	push   $0xd54
 36c:	6a 01                	push   $0x1
 36e:	e8 00 04 00 00       	call   773 <printf>
 373:	83 c4 10             	add    $0x10,%esp
  sleep(1);
 376:	83 ec 0c             	sub    $0xc,%esp
 379:	6a 01                	push   $0x1
 37b:	e8 ef 02 00 00       	call   66f <sleep>
 380:	83 c4 10             	add    $0x10,%esp
  exit();
 383:	e8 57 02 00 00       	call   5df <exit>

00000388 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 388:	55                   	push   %ebp
 389:	89 e5                	mov    %esp,%ebp
 38b:	57                   	push   %edi
 38c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 38d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 390:	8b 55 10             	mov    0x10(%ebp),%edx
 393:	8b 45 0c             	mov    0xc(%ebp),%eax
 396:	89 cb                	mov    %ecx,%ebx
 398:	89 df                	mov    %ebx,%edi
 39a:	89 d1                	mov    %edx,%ecx
 39c:	fc                   	cld
 39d:	f3 aa                	rep stos %al,%es:(%edi)
 39f:	89 ca                	mov    %ecx,%edx
 3a1:	89 fb                	mov    %edi,%ebx
 3a3:	89 5d 08             	mov    %ebx,0x8(%ebp)
 3a6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 3a9:	90                   	nop
 3aa:	5b                   	pop    %ebx
 3ab:	5f                   	pop    %edi
 3ac:	5d                   	pop    %ebp
 3ad:	c3                   	ret

000003ae <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 3ae:	55                   	push   %ebp
 3af:	89 e5                	mov    %esp,%ebp
 3b1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 3b4:	8b 45 08             	mov    0x8(%ebp),%eax
 3b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 3ba:	90                   	nop
 3bb:	8b 55 0c             	mov    0xc(%ebp),%edx
 3be:	8d 42 01             	lea    0x1(%edx),%eax
 3c1:	89 45 0c             	mov    %eax,0xc(%ebp)
 3c4:	8b 45 08             	mov    0x8(%ebp),%eax
 3c7:	8d 48 01             	lea    0x1(%eax),%ecx
 3ca:	89 4d 08             	mov    %ecx,0x8(%ebp)
 3cd:	0f b6 12             	movzbl (%edx),%edx
 3d0:	88 10                	mov    %dl,(%eax)
 3d2:	0f b6 00             	movzbl (%eax),%eax
 3d5:	84 c0                	test   %al,%al
 3d7:	75 e2                	jne    3bb <strcpy+0xd>
    ;
  return os;
 3d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3dc:	c9                   	leave
 3dd:	c3                   	ret

000003de <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3de:	55                   	push   %ebp
 3df:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3e1:	eb 08                	jmp    3eb <strcmp+0xd>
    p++, q++;
 3e3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3e7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 3eb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ee:	0f b6 00             	movzbl (%eax),%eax
 3f1:	84 c0                	test   %al,%al
 3f3:	74 10                	je     405 <strcmp+0x27>
 3f5:	8b 45 08             	mov    0x8(%ebp),%eax
 3f8:	0f b6 10             	movzbl (%eax),%edx
 3fb:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fe:	0f b6 00             	movzbl (%eax),%eax
 401:	38 c2                	cmp    %al,%dl
 403:	74 de                	je     3e3 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 405:	8b 45 08             	mov    0x8(%ebp),%eax
 408:	0f b6 00             	movzbl (%eax),%eax
 40b:	0f b6 d0             	movzbl %al,%edx
 40e:	8b 45 0c             	mov    0xc(%ebp),%eax
 411:	0f b6 00             	movzbl (%eax),%eax
 414:	0f b6 c0             	movzbl %al,%eax
 417:	29 c2                	sub    %eax,%edx
 419:	89 d0                	mov    %edx,%eax
}
 41b:	5d                   	pop    %ebp
 41c:	c3                   	ret

0000041d <strlen>:

uint
strlen(char *s)
{
 41d:	55                   	push   %ebp
 41e:	89 e5                	mov    %esp,%ebp
 420:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 423:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 42a:	eb 04                	jmp    430 <strlen+0x13>
 42c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 430:	8b 55 fc             	mov    -0x4(%ebp),%edx
 433:	8b 45 08             	mov    0x8(%ebp),%eax
 436:	01 d0                	add    %edx,%eax
 438:	0f b6 00             	movzbl (%eax),%eax
 43b:	84 c0                	test   %al,%al
 43d:	75 ed                	jne    42c <strlen+0xf>
    ;
  return n;
 43f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 442:	c9                   	leave
 443:	c3                   	ret

00000444 <memset>:

void*
memset(void *dst, int c, uint n)
{
 444:	55                   	push   %ebp
 445:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 447:	8b 45 10             	mov    0x10(%ebp),%eax
 44a:	50                   	push   %eax
 44b:	ff 75 0c             	push   0xc(%ebp)
 44e:	ff 75 08             	push   0x8(%ebp)
 451:	e8 32 ff ff ff       	call   388 <stosb>
 456:	83 c4 0c             	add    $0xc,%esp
  return dst;
 459:	8b 45 08             	mov    0x8(%ebp),%eax
}
 45c:	c9                   	leave
 45d:	c3                   	ret

0000045e <strchr>:

char*
strchr(const char *s, char c)
{
 45e:	55                   	push   %ebp
 45f:	89 e5                	mov    %esp,%ebp
 461:	83 ec 04             	sub    $0x4,%esp
 464:	8b 45 0c             	mov    0xc(%ebp),%eax
 467:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 46a:	eb 14                	jmp    480 <strchr+0x22>
    if(*s == c)
 46c:	8b 45 08             	mov    0x8(%ebp),%eax
 46f:	0f b6 00             	movzbl (%eax),%eax
 472:	38 45 fc             	cmp    %al,-0x4(%ebp)
 475:	75 05                	jne    47c <strchr+0x1e>
      return (char*)s;
 477:	8b 45 08             	mov    0x8(%ebp),%eax
 47a:	eb 13                	jmp    48f <strchr+0x31>
  for(; *s; s++)
 47c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 480:	8b 45 08             	mov    0x8(%ebp),%eax
 483:	0f b6 00             	movzbl (%eax),%eax
 486:	84 c0                	test   %al,%al
 488:	75 e2                	jne    46c <strchr+0xe>
  return 0;
 48a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 48f:	c9                   	leave
 490:	c3                   	ret

00000491 <gets>:

char*
gets(char *buf, int max)
{
 491:	55                   	push   %ebp
 492:	89 e5                	mov    %esp,%ebp
 494:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 497:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 49e:	eb 42                	jmp    4e2 <gets+0x51>
    cc = read(0, &c, 1);
 4a0:	83 ec 04             	sub    $0x4,%esp
 4a3:	6a 01                	push   $0x1
 4a5:	8d 45 ef             	lea    -0x11(%ebp),%eax
 4a8:	50                   	push   %eax
 4a9:	6a 00                	push   $0x0
 4ab:	e8 47 01 00 00       	call   5f7 <read>
 4b0:	83 c4 10             	add    $0x10,%esp
 4b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4ba:	7e 33                	jle    4ef <gets+0x5e>
      break;
    buf[i++] = c;
 4bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4bf:	8d 50 01             	lea    0x1(%eax),%edx
 4c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4c5:	89 c2                	mov    %eax,%edx
 4c7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ca:	01 c2                	add    %eax,%edx
 4cc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4d0:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4d2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4d6:	3c 0a                	cmp    $0xa,%al
 4d8:	74 16                	je     4f0 <gets+0x5f>
 4da:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4de:	3c 0d                	cmp    $0xd,%al
 4e0:	74 0e                	je     4f0 <gets+0x5f>
  for(i=0; i+1 < max; ){
 4e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e5:	83 c0 01             	add    $0x1,%eax
 4e8:	39 45 0c             	cmp    %eax,0xc(%ebp)
 4eb:	7f b3                	jg     4a0 <gets+0xf>
 4ed:	eb 01                	jmp    4f0 <gets+0x5f>
      break;
 4ef:	90                   	nop
      break;
  }
  buf[i] = '\0';
 4f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4f3:	8b 45 08             	mov    0x8(%ebp),%eax
 4f6:	01 d0                	add    %edx,%eax
 4f8:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4fb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4fe:	c9                   	leave
 4ff:	c3                   	ret

00000500 <stat>:

int
stat(char *n, struct stat *st)
{
 500:	55                   	push   %ebp
 501:	89 e5                	mov    %esp,%ebp
 503:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 506:	83 ec 08             	sub    $0x8,%esp
 509:	6a 00                	push   $0x0
 50b:	ff 75 08             	push   0x8(%ebp)
 50e:	e8 0c 01 00 00       	call   61f <open>
 513:	83 c4 10             	add    $0x10,%esp
 516:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 519:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 51d:	79 07                	jns    526 <stat+0x26>
    return -1;
 51f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 524:	eb 25                	jmp    54b <stat+0x4b>
  r = fstat(fd, st);
 526:	83 ec 08             	sub    $0x8,%esp
 529:	ff 75 0c             	push   0xc(%ebp)
 52c:	ff 75 f4             	push   -0xc(%ebp)
 52f:	e8 03 01 00 00       	call   637 <fstat>
 534:	83 c4 10             	add    $0x10,%esp
 537:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 53a:	83 ec 0c             	sub    $0xc,%esp
 53d:	ff 75 f4             	push   -0xc(%ebp)
 540:	e8 c2 00 00 00       	call   607 <close>
 545:	83 c4 10             	add    $0x10,%esp
  return r;
 548:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 54b:	c9                   	leave
 54c:	c3                   	ret

0000054d <atoi>:

int
atoi(const char *s)
{
 54d:	55                   	push   %ebp
 54e:	89 e5                	mov    %esp,%ebp
 550:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 553:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 55a:	eb 25                	jmp    581 <atoi+0x34>
    n = n*10 + *s++ - '0';
 55c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 55f:	89 d0                	mov    %edx,%eax
 561:	c1 e0 02             	shl    $0x2,%eax
 564:	01 d0                	add    %edx,%eax
 566:	01 c0                	add    %eax,%eax
 568:	89 c1                	mov    %eax,%ecx
 56a:	8b 45 08             	mov    0x8(%ebp),%eax
 56d:	8d 50 01             	lea    0x1(%eax),%edx
 570:	89 55 08             	mov    %edx,0x8(%ebp)
 573:	0f b6 00             	movzbl (%eax),%eax
 576:	0f be c0             	movsbl %al,%eax
 579:	01 c8                	add    %ecx,%eax
 57b:	83 e8 30             	sub    $0x30,%eax
 57e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 581:	8b 45 08             	mov    0x8(%ebp),%eax
 584:	0f b6 00             	movzbl (%eax),%eax
 587:	3c 2f                	cmp    $0x2f,%al
 589:	7e 0a                	jle    595 <atoi+0x48>
 58b:	8b 45 08             	mov    0x8(%ebp),%eax
 58e:	0f b6 00             	movzbl (%eax),%eax
 591:	3c 39                	cmp    $0x39,%al
 593:	7e c7                	jle    55c <atoi+0xf>
  return n;
 595:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 598:	c9                   	leave
 599:	c3                   	ret

0000059a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 59a:	55                   	push   %ebp
 59b:	89 e5                	mov    %esp,%ebp
 59d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 5a0:	8b 45 08             	mov    0x8(%ebp),%eax
 5a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 5a6:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5ac:	eb 17                	jmp    5c5 <memmove+0x2b>
    *dst++ = *src++;
 5ae:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5b1:	8d 42 01             	lea    0x1(%edx),%eax
 5b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
 5b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5ba:	8d 48 01             	lea    0x1(%eax),%ecx
 5bd:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 5c0:	0f b6 12             	movzbl (%edx),%edx
 5c3:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 5c5:	8b 45 10             	mov    0x10(%ebp),%eax
 5c8:	8d 50 ff             	lea    -0x1(%eax),%edx
 5cb:	89 55 10             	mov    %edx,0x10(%ebp)
 5ce:	85 c0                	test   %eax,%eax
 5d0:	7f dc                	jg     5ae <memmove+0x14>
  return vdst;
 5d2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5d5:	c9                   	leave
 5d6:	c3                   	ret

000005d7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5d7:	b8 01 00 00 00       	mov    $0x1,%eax
 5dc:	cd 40                	int    $0x40
 5de:	c3                   	ret

000005df <exit>:
SYSCALL(exit)
 5df:	b8 02 00 00 00       	mov    $0x2,%eax
 5e4:	cd 40                	int    $0x40
 5e6:	c3                   	ret

000005e7 <wait>:
SYSCALL(wait)
 5e7:	b8 03 00 00 00       	mov    $0x3,%eax
 5ec:	cd 40                	int    $0x40
 5ee:	c3                   	ret

000005ef <pipe>:
SYSCALL(pipe)
 5ef:	b8 04 00 00 00       	mov    $0x4,%eax
 5f4:	cd 40                	int    $0x40
 5f6:	c3                   	ret

000005f7 <read>:
SYSCALL(read)
 5f7:	b8 05 00 00 00       	mov    $0x5,%eax
 5fc:	cd 40                	int    $0x40
 5fe:	c3                   	ret

000005ff <write>:
SYSCALL(write)
 5ff:	b8 10 00 00 00       	mov    $0x10,%eax
 604:	cd 40                	int    $0x40
 606:	c3                   	ret

00000607 <close>:
SYSCALL(close)
 607:	b8 15 00 00 00       	mov    $0x15,%eax
 60c:	cd 40                	int    $0x40
 60e:	c3                   	ret

0000060f <kill>:
SYSCALL(kill)
 60f:	b8 06 00 00 00       	mov    $0x6,%eax
 614:	cd 40                	int    $0x40
 616:	c3                   	ret

00000617 <exec>:
SYSCALL(exec)
 617:	b8 07 00 00 00       	mov    $0x7,%eax
 61c:	cd 40                	int    $0x40
 61e:	c3                   	ret

0000061f <open>:
SYSCALL(open)
 61f:	b8 0f 00 00 00       	mov    $0xf,%eax
 624:	cd 40                	int    $0x40
 626:	c3                   	ret

00000627 <mknod>:
SYSCALL(mknod)
 627:	b8 11 00 00 00       	mov    $0x11,%eax
 62c:	cd 40                	int    $0x40
 62e:	c3                   	ret

0000062f <unlink>:
SYSCALL(unlink)
 62f:	b8 12 00 00 00       	mov    $0x12,%eax
 634:	cd 40                	int    $0x40
 636:	c3                   	ret

00000637 <fstat>:
SYSCALL(fstat)
 637:	b8 08 00 00 00       	mov    $0x8,%eax
 63c:	cd 40                	int    $0x40
 63e:	c3                   	ret

0000063f <link>:
SYSCALL(link)
 63f:	b8 13 00 00 00       	mov    $0x13,%eax
 644:	cd 40                	int    $0x40
 646:	c3                   	ret

00000647 <mkdir>:
SYSCALL(mkdir)
 647:	b8 14 00 00 00       	mov    $0x14,%eax
 64c:	cd 40                	int    $0x40
 64e:	c3                   	ret

0000064f <chdir>:
SYSCALL(chdir)
 64f:	b8 09 00 00 00       	mov    $0x9,%eax
 654:	cd 40                	int    $0x40
 656:	c3                   	ret

00000657 <dup>:
SYSCALL(dup)
 657:	b8 0a 00 00 00       	mov    $0xa,%eax
 65c:	cd 40                	int    $0x40
 65e:	c3                   	ret

0000065f <getpid>:
SYSCALL(getpid)
 65f:	b8 0b 00 00 00       	mov    $0xb,%eax
 664:	cd 40                	int    $0x40
 666:	c3                   	ret

00000667 <sbrk>:
SYSCALL(sbrk)
 667:	b8 0c 00 00 00       	mov    $0xc,%eax
 66c:	cd 40                	int    $0x40
 66e:	c3                   	ret

0000066f <sleep>:
SYSCALL(sleep)
 66f:	b8 0d 00 00 00       	mov    $0xd,%eax
 674:	cd 40                	int    $0x40
 676:	c3                   	ret

00000677 <uptime>:
SYSCALL(uptime)
 677:	b8 0e 00 00 00       	mov    $0xe,%eax
 67c:	cd 40                	int    $0x40
 67e:	c3                   	ret

0000067f <getpinfo>:

SYSCALL(getpinfo)
 67f:	b8 16 00 00 00       	mov    $0x16,%eax
 684:	cd 40                	int    $0x40
 686:	c3                   	ret

00000687 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 687:	b8 17 00 00 00       	mov    $0x17,%eax
 68c:	cd 40                	int    $0x40
 68e:	c3                   	ret

0000068f <yield>:
SYSCALL(yield)
 68f:	b8 18 00 00 00       	mov    $0x18,%eax
 694:	cd 40                	int    $0x40
 696:	c3                   	ret

00000697 <getSchedPolicy>:
 697:	b8 19 00 00 00       	mov    $0x19,%eax
 69c:	cd 40                	int    $0x40
 69e:	c3                   	ret

0000069f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 69f:	55                   	push   %ebp
 6a0:	89 e5                	mov    %esp,%ebp
 6a2:	83 ec 18             	sub    $0x18,%esp
 6a5:	8b 45 0c             	mov    0xc(%ebp),%eax
 6a8:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 6ab:	83 ec 04             	sub    $0x4,%esp
 6ae:	6a 01                	push   $0x1
 6b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6b3:	50                   	push   %eax
 6b4:	ff 75 08             	push   0x8(%ebp)
 6b7:	e8 43 ff ff ff       	call   5ff <write>
 6bc:	83 c4 10             	add    $0x10,%esp
}
 6bf:	90                   	nop
 6c0:	c9                   	leave
 6c1:	c3                   	ret

000006c2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6c2:	55                   	push   %ebp
 6c3:	89 e5                	mov    %esp,%ebp
 6c5:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6c8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6cf:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6d3:	74 17                	je     6ec <printint+0x2a>
 6d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6d9:	79 11                	jns    6ec <printint+0x2a>
    neg = 1;
 6db:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 6e5:	f7 d8                	neg    %eax
 6e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6ea:	eb 06                	jmp    6f2 <printint+0x30>
  } else {
    x = xx;
 6ec:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6ff:	ba 00 00 00 00       	mov    $0x0,%edx
 704:	f7 f1                	div    %ecx
 706:	89 d1                	mov    %edx,%ecx
 708:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70b:	8d 50 01             	lea    0x1(%eax),%edx
 70e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 711:	0f b6 91 30 10 00 00 	movzbl 0x1030(%ecx),%edx
 718:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 71c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 71f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 722:	ba 00 00 00 00       	mov    $0x0,%edx
 727:	f7 f1                	div    %ecx
 729:	89 45 ec             	mov    %eax,-0x14(%ebp)
 72c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 730:	75 c7                	jne    6f9 <printint+0x37>
  if(neg)
 732:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 736:	74 2d                	je     765 <printint+0xa3>
    buf[i++] = '-';
 738:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73b:	8d 50 01             	lea    0x1(%eax),%edx
 73e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 741:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 746:	eb 1d                	jmp    765 <printint+0xa3>
    putc(fd, buf[i]);
 748:	8d 55 dc             	lea    -0x24(%ebp),%edx
 74b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74e:	01 d0                	add    %edx,%eax
 750:	0f b6 00             	movzbl (%eax),%eax
 753:	0f be c0             	movsbl %al,%eax
 756:	83 ec 08             	sub    $0x8,%esp
 759:	50                   	push   %eax
 75a:	ff 75 08             	push   0x8(%ebp)
 75d:	e8 3d ff ff ff       	call   69f <putc>
 762:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 765:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 769:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 76d:	79 d9                	jns    748 <printint+0x86>
}
 76f:	90                   	nop
 770:	90                   	nop
 771:	c9                   	leave
 772:	c3                   	ret

00000773 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 773:	55                   	push   %ebp
 774:	89 e5                	mov    %esp,%ebp
 776:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 779:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 780:	8d 45 0c             	lea    0xc(%ebp),%eax
 783:	83 c0 04             	add    $0x4,%eax
 786:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 789:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 790:	e9 59 01 00 00       	jmp    8ee <printf+0x17b>
    c = fmt[i] & 0xff;
 795:	8b 55 0c             	mov    0xc(%ebp),%edx
 798:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79b:	01 d0                	add    %edx,%eax
 79d:	0f b6 00             	movzbl (%eax),%eax
 7a0:	0f be c0             	movsbl %al,%eax
 7a3:	25 ff 00 00 00       	and    $0xff,%eax
 7a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7ab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7af:	75 2c                	jne    7dd <printf+0x6a>
      if(c == '%'){
 7b1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7b5:	75 0c                	jne    7c3 <printf+0x50>
        state = '%';
 7b7:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7be:	e9 27 01 00 00       	jmp    8ea <printf+0x177>
      } else {
        putc(fd, c);
 7c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7c6:	0f be c0             	movsbl %al,%eax
 7c9:	83 ec 08             	sub    $0x8,%esp
 7cc:	50                   	push   %eax
 7cd:	ff 75 08             	push   0x8(%ebp)
 7d0:	e8 ca fe ff ff       	call   69f <putc>
 7d5:	83 c4 10             	add    $0x10,%esp
 7d8:	e9 0d 01 00 00       	jmp    8ea <printf+0x177>
      }
    } else if(state == '%'){
 7dd:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7e1:	0f 85 03 01 00 00    	jne    8ea <printf+0x177>
      if(c == 'd'){
 7e7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7eb:	75 1e                	jne    80b <printf+0x98>
        printint(fd, *ap, 10, 1);
 7ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f0:	8b 00                	mov    (%eax),%eax
 7f2:	6a 01                	push   $0x1
 7f4:	6a 0a                	push   $0xa
 7f6:	50                   	push   %eax
 7f7:	ff 75 08             	push   0x8(%ebp)
 7fa:	e8 c3 fe ff ff       	call   6c2 <printint>
 7ff:	83 c4 10             	add    $0x10,%esp
        ap++;
 802:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 806:	e9 d8 00 00 00       	jmp    8e3 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 80b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 80f:	74 06                	je     817 <printf+0xa4>
 811:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 815:	75 1e                	jne    835 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 817:	8b 45 e8             	mov    -0x18(%ebp),%eax
 81a:	8b 00                	mov    (%eax),%eax
 81c:	6a 00                	push   $0x0
 81e:	6a 10                	push   $0x10
 820:	50                   	push   %eax
 821:	ff 75 08             	push   0x8(%ebp)
 824:	e8 99 fe ff ff       	call   6c2 <printint>
 829:	83 c4 10             	add    $0x10,%esp
        ap++;
 82c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 830:	e9 ae 00 00 00       	jmp    8e3 <printf+0x170>
      } else if(c == 's'){
 835:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 839:	75 43                	jne    87e <printf+0x10b>
        s = (char*)*ap;
 83b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 83e:	8b 00                	mov    (%eax),%eax
 840:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 843:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 847:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 84b:	75 25                	jne    872 <printf+0xff>
          s = "(null)";
 84d:	c7 45 f4 73 0d 00 00 	movl   $0xd73,-0xc(%ebp)
        while(*s != 0){
 854:	eb 1c                	jmp    872 <printf+0xff>
          putc(fd, *s);
 856:	8b 45 f4             	mov    -0xc(%ebp),%eax
 859:	0f b6 00             	movzbl (%eax),%eax
 85c:	0f be c0             	movsbl %al,%eax
 85f:	83 ec 08             	sub    $0x8,%esp
 862:	50                   	push   %eax
 863:	ff 75 08             	push   0x8(%ebp)
 866:	e8 34 fe ff ff       	call   69f <putc>
 86b:	83 c4 10             	add    $0x10,%esp
          s++;
 86e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 872:	8b 45 f4             	mov    -0xc(%ebp),%eax
 875:	0f b6 00             	movzbl (%eax),%eax
 878:	84 c0                	test   %al,%al
 87a:	75 da                	jne    856 <printf+0xe3>
 87c:	eb 65                	jmp    8e3 <printf+0x170>
        }
      } else if(c == 'c'){
 87e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 882:	75 1d                	jne    8a1 <printf+0x12e>
        putc(fd, *ap);
 884:	8b 45 e8             	mov    -0x18(%ebp),%eax
 887:	8b 00                	mov    (%eax),%eax
 889:	0f be c0             	movsbl %al,%eax
 88c:	83 ec 08             	sub    $0x8,%esp
 88f:	50                   	push   %eax
 890:	ff 75 08             	push   0x8(%ebp)
 893:	e8 07 fe ff ff       	call   69f <putc>
 898:	83 c4 10             	add    $0x10,%esp
        ap++;
 89b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 89f:	eb 42                	jmp    8e3 <printf+0x170>
      } else if(c == '%'){
 8a1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8a5:	75 17                	jne    8be <printf+0x14b>
        putc(fd, c);
 8a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8aa:	0f be c0             	movsbl %al,%eax
 8ad:	83 ec 08             	sub    $0x8,%esp
 8b0:	50                   	push   %eax
 8b1:	ff 75 08             	push   0x8(%ebp)
 8b4:	e8 e6 fd ff ff       	call   69f <putc>
 8b9:	83 c4 10             	add    $0x10,%esp
 8bc:	eb 25                	jmp    8e3 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8be:	83 ec 08             	sub    $0x8,%esp
 8c1:	6a 25                	push   $0x25
 8c3:	ff 75 08             	push   0x8(%ebp)
 8c6:	e8 d4 fd ff ff       	call   69f <putc>
 8cb:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8d1:	0f be c0             	movsbl %al,%eax
 8d4:	83 ec 08             	sub    $0x8,%esp
 8d7:	50                   	push   %eax
 8d8:	ff 75 08             	push   0x8(%ebp)
 8db:	e8 bf fd ff ff       	call   69f <putc>
 8e0:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8e3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 8ea:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8ee:	8b 55 0c             	mov    0xc(%ebp),%edx
 8f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f4:	01 d0                	add    %edx,%eax
 8f6:	0f b6 00             	movzbl (%eax),%eax
 8f9:	84 c0                	test   %al,%al
 8fb:	0f 85 94 fe ff ff    	jne    795 <printf+0x22>
    }
  }
}
 901:	90                   	nop
 902:	90                   	nop
 903:	c9                   	leave
 904:	c3                   	ret

00000905 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 905:	55                   	push   %ebp
 906:	89 e5                	mov    %esp,%ebp
 908:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 90b:	8b 45 08             	mov    0x8(%ebp),%eax
 90e:	83 e8 08             	sub    $0x8,%eax
 911:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 914:	a1 4c 10 00 00       	mov    0x104c,%eax
 919:	89 45 fc             	mov    %eax,-0x4(%ebp)
 91c:	eb 24                	jmp    942 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 91e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 921:	8b 00                	mov    (%eax),%eax
 923:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 926:	72 12                	jb     93a <free+0x35>
 928:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92b:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 92e:	72 24                	jb     954 <free+0x4f>
 930:	8b 45 fc             	mov    -0x4(%ebp),%eax
 933:	8b 00                	mov    (%eax),%eax
 935:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 938:	72 1a                	jb     954 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 93a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93d:	8b 00                	mov    (%eax),%eax
 93f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 942:	8b 45 f8             	mov    -0x8(%ebp),%eax
 945:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 948:	73 d4                	jae    91e <free+0x19>
 94a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94d:	8b 00                	mov    (%eax),%eax
 94f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 952:	73 ca                	jae    91e <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 954:	8b 45 f8             	mov    -0x8(%ebp),%eax
 957:	8b 40 04             	mov    0x4(%eax),%eax
 95a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 961:	8b 45 f8             	mov    -0x8(%ebp),%eax
 964:	01 c2                	add    %eax,%edx
 966:	8b 45 fc             	mov    -0x4(%ebp),%eax
 969:	8b 00                	mov    (%eax),%eax
 96b:	39 c2                	cmp    %eax,%edx
 96d:	75 24                	jne    993 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 96f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 972:	8b 50 04             	mov    0x4(%eax),%edx
 975:	8b 45 fc             	mov    -0x4(%ebp),%eax
 978:	8b 00                	mov    (%eax),%eax
 97a:	8b 40 04             	mov    0x4(%eax),%eax
 97d:	01 c2                	add    %eax,%edx
 97f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 982:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 985:	8b 45 fc             	mov    -0x4(%ebp),%eax
 988:	8b 00                	mov    (%eax),%eax
 98a:	8b 10                	mov    (%eax),%edx
 98c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 98f:	89 10                	mov    %edx,(%eax)
 991:	eb 0a                	jmp    99d <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 993:	8b 45 fc             	mov    -0x4(%ebp),%eax
 996:	8b 10                	mov    (%eax),%edx
 998:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99b:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 99d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a0:	8b 40 04             	mov    0x4(%eax),%eax
 9a3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ad:	01 d0                	add    %edx,%eax
 9af:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9b2:	75 20                	jne    9d4 <free+0xcf>
    p->s.size += bp->s.size;
 9b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b7:	8b 50 04             	mov    0x4(%eax),%edx
 9ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9bd:	8b 40 04             	mov    0x4(%eax),%eax
 9c0:	01 c2                	add    %eax,%edx
 9c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c5:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9cb:	8b 10                	mov    (%eax),%edx
 9cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d0:	89 10                	mov    %edx,(%eax)
 9d2:	eb 08                	jmp    9dc <free+0xd7>
  } else
    p->s.ptr = bp;
 9d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9da:	89 10                	mov    %edx,(%eax)
  freep = p;
 9dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9df:	a3 4c 10 00 00       	mov    %eax,0x104c
}
 9e4:	90                   	nop
 9e5:	c9                   	leave
 9e6:	c3                   	ret

000009e7 <morecore>:

static Header*
morecore(uint nu)
{
 9e7:	55                   	push   %ebp
 9e8:	89 e5                	mov    %esp,%ebp
 9ea:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9ed:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9f4:	77 07                	ja     9fd <morecore+0x16>
    nu = 4096;
 9f6:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9fd:	8b 45 08             	mov    0x8(%ebp),%eax
 a00:	c1 e0 03             	shl    $0x3,%eax
 a03:	83 ec 0c             	sub    $0xc,%esp
 a06:	50                   	push   %eax
 a07:	e8 5b fc ff ff       	call   667 <sbrk>
 a0c:	83 c4 10             	add    $0x10,%esp
 a0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a12:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a16:	75 07                	jne    a1f <morecore+0x38>
    return 0;
 a18:	b8 00 00 00 00       	mov    $0x0,%eax
 a1d:	eb 26                	jmp    a45 <morecore+0x5e>
  hp = (Header*)p;
 a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a22:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a25:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a28:	8b 55 08             	mov    0x8(%ebp),%edx
 a2b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a31:	83 c0 08             	add    $0x8,%eax
 a34:	83 ec 0c             	sub    $0xc,%esp
 a37:	50                   	push   %eax
 a38:	e8 c8 fe ff ff       	call   905 <free>
 a3d:	83 c4 10             	add    $0x10,%esp
  return freep;
 a40:	a1 4c 10 00 00       	mov    0x104c,%eax
}
 a45:	c9                   	leave
 a46:	c3                   	ret

00000a47 <malloc>:

void*
malloc(uint nbytes)
{
 a47:	55                   	push   %ebp
 a48:	89 e5                	mov    %esp,%ebp
 a4a:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a4d:	8b 45 08             	mov    0x8(%ebp),%eax
 a50:	83 c0 07             	add    $0x7,%eax
 a53:	c1 e8 03             	shr    $0x3,%eax
 a56:	83 c0 01             	add    $0x1,%eax
 a59:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a5c:	a1 4c 10 00 00       	mov    0x104c,%eax
 a61:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a64:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a68:	75 23                	jne    a8d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a6a:	c7 45 f0 44 10 00 00 	movl   $0x1044,-0x10(%ebp)
 a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a74:	a3 4c 10 00 00       	mov    %eax,0x104c
 a79:	a1 4c 10 00 00       	mov    0x104c,%eax
 a7e:	a3 44 10 00 00       	mov    %eax,0x1044
    base.s.size = 0;
 a83:	c7 05 48 10 00 00 00 	movl   $0x0,0x1048
 a8a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a90:	8b 00                	mov    (%eax),%eax
 a92:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a98:	8b 40 04             	mov    0x4(%eax),%eax
 a9b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a9e:	72 4d                	jb     aed <malloc+0xa6>
      if(p->s.size == nunits)
 aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa3:	8b 40 04             	mov    0x4(%eax),%eax
 aa6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 aa9:	75 0c                	jne    ab7 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aae:	8b 10                	mov    (%eax),%edx
 ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab3:	89 10                	mov    %edx,(%eax)
 ab5:	eb 26                	jmp    add <malloc+0x96>
      else {
        p->s.size -= nunits;
 ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aba:	8b 40 04             	mov    0x4(%eax),%eax
 abd:	2b 45 ec             	sub    -0x14(%ebp),%eax
 ac0:	89 c2                	mov    %eax,%edx
 ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 acb:	8b 40 04             	mov    0x4(%eax),%eax
 ace:	c1 e0 03             	shl    $0x3,%eax
 ad1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ada:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 add:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ae0:	a3 4c 10 00 00       	mov    %eax,0x104c
      return (void*)(p + 1);
 ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae8:	83 c0 08             	add    $0x8,%eax
 aeb:	eb 3b                	jmp    b28 <malloc+0xe1>
    }
    if(p == freep)
 aed:	a1 4c 10 00 00       	mov    0x104c,%eax
 af2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 af5:	75 1e                	jne    b15 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 af7:	83 ec 0c             	sub    $0xc,%esp
 afa:	ff 75 ec             	push   -0x14(%ebp)
 afd:	e8 e5 fe ff ff       	call   9e7 <morecore>
 b02:	83 c4 10             	add    $0x10,%esp
 b05:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b0c:	75 07                	jne    b15 <malloc+0xce>
        return 0;
 b0e:	b8 00 00 00 00       	mov    $0x0,%eax
 b13:	eb 13                	jmp    b28 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b18:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b1e:	8b 00                	mov    (%eax),%eax
 b20:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b23:	e9 6d ff ff ff       	jmp    a95 <malloc+0x4e>
  }
}
 b28:	c9                   	leave
 b29:	c3                   	ret
