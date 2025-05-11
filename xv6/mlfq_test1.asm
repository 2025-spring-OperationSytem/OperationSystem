
_mlfq_test1:     file format elf32-i386


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
  for (i = 0; i < n; i++) j += i * j + 1;
   d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  14:	eb 11                	jmp    27 <workload+0x27>
  16:	8b 45 fc             	mov    -0x4(%ebp),%eax
  19:	0f af 45 f8          	imul   -0x8(%ebp),%eax
  1d:	83 c0 01             	add    $0x1,%eax
  20:	01 45 f8             	add    %eax,-0x8(%ebp)
  23:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  27:	8b 45 fc             	mov    -0x4(%ebp),%eax
  2a:	3b 45 08             	cmp    0x8(%ebp),%eax
  2d:	7c e7                	jl     16 <workload+0x16>
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
  4a:	e8 4b 05 00 00       	call   59a <getpinfo>
  4f:	83 c4 10             	add    $0x10,%esp
  printf(1, "\n[RESULT] Process Statistics\n");
  52:	83 ec 08             	sub    $0x8,%esp
  55:	68 48 0a 00 00       	push   $0xa48
  5a:	6a 01                	push   $0x1
  5c:	e8 2d 06 00 00       	call   68e <printf>
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
 16b:	68 68 0a 00 00       	push   $0xa68
 170:	6a 01                	push   $0x1
 172:	e8 17 05 00 00       	call   68e <printf>
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

00000192 <run_policy_1>:

void run_policy_1() {
 192:	55                   	push   %ebp
 193:	89 e5                	mov    %esp,%ebp
 195:	83 ec 18             	sub    $0x18,%esp
  printf(1, "[DEBUG] Entered run_policy_1()\n");
 198:	83 ec 08             	sub    $0x8,%esp
 19b:	68 c4 0a 00 00       	push   $0xac4
 1a0:	6a 01                	push   $0x1
 1a2:	e8 e7 04 00 00       	call   68e <printf>
 1a7:	83 c4 10             	add    $0x10,%esp
  sleep(1);  
 1aa:	83 ec 0c             	sub    $0xc,%esp
 1ad:	6a 01                	push   $0x1
 1af:	e8 d6 03 00 00       	call   58a <sleep>
 1b4:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROCS; i++) {
 1b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1be:	eb 76                	jmp    236 <run_policy_1+0xa4>
    int pid = fork();
 1c0:	e8 2d 03 00 00       	call   4f2 <fork>
 1c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid == 0) {
 1c8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 1cc:	75 42                	jne    210 <run_policy_1+0x7e>
      printf(1, "[CHILD] i=%d, PID=%d\n", i, getpid());
 1ce:	e8 a7 03 00 00       	call   57a <getpid>
 1d3:	50                   	push   %eax
 1d4:	ff 75 f4             	push   -0xc(%ebp)
 1d7:	68 e4 0a 00 00       	push   $0xae4
 1dc:	6a 01                	push   $0x1
 1de:	e8 ab 04 00 00       	call   68e <printf>
 1e3:	83 c4 10             	add    $0x10,%esp
      sleep(1);
 1e6:	83 ec 0c             	sub    $0xc,%esp
 1e9:	6a 01                	push   $0x1
 1eb:	e8 9a 03 00 00       	call   58a <sleep>
 1f0:	83 c4 10             	add    $0x10,%esp
      workload(10000000 * (i + 1));
 1f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f6:	83 c0 01             	add    $0x1,%eax
 1f9:	69 c0 80 96 98 00    	imul   $0x989680,%eax,%eax
 1ff:	83 ec 0c             	sub    $0xc,%esp
 202:	50                   	push   %eax
 203:	e8 f8 fd ff ff       	call   0 <workload>
 208:	83 c4 10             	add    $0x10,%esp
      exit();
 20b:	e8 ea 02 00 00       	call   4fa <exit>
    } else {
      printf(1, "[PARENT] forked child PID=%d at i=%d\n", pid, i);
 210:	ff 75 f4             	push   -0xc(%ebp)
 213:	ff 75 ec             	push   -0x14(%ebp)
 216:	68 fc 0a 00 00       	push   $0xafc
 21b:	6a 01                	push   $0x1
 21d:	e8 6c 04 00 00       	call   68e <printf>
 222:	83 c4 10             	add    $0x10,%esp
      sleep(1);
 225:	83 ec 0c             	sub    $0xc,%esp
 228:	6a 01                	push   $0x1
 22a:	e8 5b 03 00 00       	call   58a <sleep>
 22f:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROCS; i++) {
 232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 236:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
 23a:	7e 84                	jle    1c0 <run_policy_1+0x2e>
    }
  }
  setSchedPolicy(1);
 23c:	83 ec 0c             	sub    $0xc,%esp
 23f:	6a 01                	push   $0x1
 241:	e8 5c 03 00 00       	call   5a2 <setSchedPolicy>
 246:	83 c4 10             	add    $0x10,%esp
  sleep(1);
 249:	83 ec 0c             	sub    $0xc,%esp
 24c:	6a 01                	push   $0x1
 24e:	e8 37 03 00 00       	call   58a <sleep>
 253:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < NPROCS; i++) wait();
 256:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 25d:	eb 09                	jmp    268 <run_policy_1+0xd6>
 25f:	e8 9e 02 00 00       	call   502 <wait>
 264:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 268:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
 26c:	7e f1                	jle    25f <run_policy_1+0xcd>
  print_stat();
 26e:	e8 c1 fd ff ff       	call   34 <print_stat>
}
 273:	90                   	nop
 274:	c9                   	leave
 275:	c3                   	ret

00000276 <main>:

int main(void) {
 276:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 27a:	83 e4 f0             	and    $0xfffffff0,%esp
 27d:	ff 71 fc             	push   -0x4(%ecx)
 280:	55                   	push   %ebp
 281:	89 e5                	mov    %esp,%ebp
 283:	51                   	push   %ecx
 284:	83 ec 04             	sub    $0x4,%esp
  printf(1, "\n===== [POLICY 1: tracking + boosting] =====\n");
 287:	83 ec 08             	sub    $0x8,%esp
 28a:	68 24 0b 00 00       	push   $0xb24
 28f:	6a 01                	push   $0x1
 291:	e8 f8 03 00 00       	call   68e <printf>
 296:	83 c4 10             	add    $0x10,%esp
  run_policy_1();
 299:	e8 f4 fe ff ff       	call   192 <run_policy_1>
  exit();
 29e:	e8 57 02 00 00       	call   4fa <exit>

000002a3 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2a3:	55                   	push   %ebp
 2a4:	89 e5                	mov    %esp,%ebp
 2a6:	57                   	push   %edi
 2a7:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2ab:	8b 55 10             	mov    0x10(%ebp),%edx
 2ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b1:	89 cb                	mov    %ecx,%ebx
 2b3:	89 df                	mov    %ebx,%edi
 2b5:	89 d1                	mov    %edx,%ecx
 2b7:	fc                   	cld
 2b8:	f3 aa                	rep stos %al,%es:(%edi)
 2ba:	89 ca                	mov    %ecx,%edx
 2bc:	89 fb                	mov    %edi,%ebx
 2be:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2c1:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2c4:	90                   	nop
 2c5:	5b                   	pop    %ebx
 2c6:	5f                   	pop    %edi
 2c7:	5d                   	pop    %ebp
 2c8:	c3                   	ret

000002c9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2c9:	55                   	push   %ebp
 2ca:	89 e5                	mov    %esp,%ebp
 2cc:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2cf:	8b 45 08             	mov    0x8(%ebp),%eax
 2d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2d5:	90                   	nop
 2d6:	8b 55 0c             	mov    0xc(%ebp),%edx
 2d9:	8d 42 01             	lea    0x1(%edx),%eax
 2dc:	89 45 0c             	mov    %eax,0xc(%ebp)
 2df:	8b 45 08             	mov    0x8(%ebp),%eax
 2e2:	8d 48 01             	lea    0x1(%eax),%ecx
 2e5:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2e8:	0f b6 12             	movzbl (%edx),%edx
 2eb:	88 10                	mov    %dl,(%eax)
 2ed:	0f b6 00             	movzbl (%eax),%eax
 2f0:	84 c0                	test   %al,%al
 2f2:	75 e2                	jne    2d6 <strcpy+0xd>
    ;
  return os;
 2f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2f7:	c9                   	leave
 2f8:	c3                   	ret

000002f9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2f9:	55                   	push   %ebp
 2fa:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2fc:	eb 08                	jmp    306 <strcmp+0xd>
    p++, q++;
 2fe:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 302:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 306:	8b 45 08             	mov    0x8(%ebp),%eax
 309:	0f b6 00             	movzbl (%eax),%eax
 30c:	84 c0                	test   %al,%al
 30e:	74 10                	je     320 <strcmp+0x27>
 310:	8b 45 08             	mov    0x8(%ebp),%eax
 313:	0f b6 10             	movzbl (%eax),%edx
 316:	8b 45 0c             	mov    0xc(%ebp),%eax
 319:	0f b6 00             	movzbl (%eax),%eax
 31c:	38 c2                	cmp    %al,%dl
 31e:	74 de                	je     2fe <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 320:	8b 45 08             	mov    0x8(%ebp),%eax
 323:	0f b6 00             	movzbl (%eax),%eax
 326:	0f b6 d0             	movzbl %al,%edx
 329:	8b 45 0c             	mov    0xc(%ebp),%eax
 32c:	0f b6 00             	movzbl (%eax),%eax
 32f:	0f b6 c0             	movzbl %al,%eax
 332:	29 c2                	sub    %eax,%edx
 334:	89 d0                	mov    %edx,%eax
}
 336:	5d                   	pop    %ebp
 337:	c3                   	ret

00000338 <strlen>:

uint
strlen(char *s)
{
 338:	55                   	push   %ebp
 339:	89 e5                	mov    %esp,%ebp
 33b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 33e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 345:	eb 04                	jmp    34b <strlen+0x13>
 347:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 34b:	8b 55 fc             	mov    -0x4(%ebp),%edx
 34e:	8b 45 08             	mov    0x8(%ebp),%eax
 351:	01 d0                	add    %edx,%eax
 353:	0f b6 00             	movzbl (%eax),%eax
 356:	84 c0                	test   %al,%al
 358:	75 ed                	jne    347 <strlen+0xf>
    ;
  return n;
 35a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 35d:	c9                   	leave
 35e:	c3                   	ret

0000035f <memset>:

void*
memset(void *dst, int c, uint n)
{
 35f:	55                   	push   %ebp
 360:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 362:	8b 45 10             	mov    0x10(%ebp),%eax
 365:	50                   	push   %eax
 366:	ff 75 0c             	push   0xc(%ebp)
 369:	ff 75 08             	push   0x8(%ebp)
 36c:	e8 32 ff ff ff       	call   2a3 <stosb>
 371:	83 c4 0c             	add    $0xc,%esp
  return dst;
 374:	8b 45 08             	mov    0x8(%ebp),%eax
}
 377:	c9                   	leave
 378:	c3                   	ret

00000379 <strchr>:

char*
strchr(const char *s, char c)
{
 379:	55                   	push   %ebp
 37a:	89 e5                	mov    %esp,%ebp
 37c:	83 ec 04             	sub    $0x4,%esp
 37f:	8b 45 0c             	mov    0xc(%ebp),%eax
 382:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 385:	eb 14                	jmp    39b <strchr+0x22>
    if(*s == c)
 387:	8b 45 08             	mov    0x8(%ebp),%eax
 38a:	0f b6 00             	movzbl (%eax),%eax
 38d:	38 45 fc             	cmp    %al,-0x4(%ebp)
 390:	75 05                	jne    397 <strchr+0x1e>
      return (char*)s;
 392:	8b 45 08             	mov    0x8(%ebp),%eax
 395:	eb 13                	jmp    3aa <strchr+0x31>
  for(; *s; s++)
 397:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 39b:	8b 45 08             	mov    0x8(%ebp),%eax
 39e:	0f b6 00             	movzbl (%eax),%eax
 3a1:	84 c0                	test   %al,%al
 3a3:	75 e2                	jne    387 <strchr+0xe>
  return 0;
 3a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3aa:	c9                   	leave
 3ab:	c3                   	ret

000003ac <gets>:

char*
gets(char *buf, int max)
{
 3ac:	55                   	push   %ebp
 3ad:	89 e5                	mov    %esp,%ebp
 3af:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3b9:	eb 42                	jmp    3fd <gets+0x51>
    cc = read(0, &c, 1);
 3bb:	83 ec 04             	sub    $0x4,%esp
 3be:	6a 01                	push   $0x1
 3c0:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3c3:	50                   	push   %eax
 3c4:	6a 00                	push   $0x0
 3c6:	e8 47 01 00 00       	call   512 <read>
 3cb:	83 c4 10             	add    $0x10,%esp
 3ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3d5:	7e 33                	jle    40a <gets+0x5e>
      break;
    buf[i++] = c;
 3d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3da:	8d 50 01             	lea    0x1(%eax),%edx
 3dd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3e0:	89 c2                	mov    %eax,%edx
 3e2:	8b 45 08             	mov    0x8(%ebp),%eax
 3e5:	01 c2                	add    %eax,%edx
 3e7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3eb:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3ed:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3f1:	3c 0a                	cmp    $0xa,%al
 3f3:	74 16                	je     40b <gets+0x5f>
 3f5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3f9:	3c 0d                	cmp    $0xd,%al
 3fb:	74 0e                	je     40b <gets+0x5f>
  for(i=0; i+1 < max; ){
 3fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 400:	83 c0 01             	add    $0x1,%eax
 403:	39 45 0c             	cmp    %eax,0xc(%ebp)
 406:	7f b3                	jg     3bb <gets+0xf>
 408:	eb 01                	jmp    40b <gets+0x5f>
      break;
 40a:	90                   	nop
      break;
  }
  buf[i] = '\0';
 40b:	8b 55 f4             	mov    -0xc(%ebp),%edx
 40e:	8b 45 08             	mov    0x8(%ebp),%eax
 411:	01 d0                	add    %edx,%eax
 413:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 416:	8b 45 08             	mov    0x8(%ebp),%eax
}
 419:	c9                   	leave
 41a:	c3                   	ret

0000041b <stat>:

int
stat(char *n, struct stat *st)
{
 41b:	55                   	push   %ebp
 41c:	89 e5                	mov    %esp,%ebp
 41e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 421:	83 ec 08             	sub    $0x8,%esp
 424:	6a 00                	push   $0x0
 426:	ff 75 08             	push   0x8(%ebp)
 429:	e8 0c 01 00 00       	call   53a <open>
 42e:	83 c4 10             	add    $0x10,%esp
 431:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 434:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 438:	79 07                	jns    441 <stat+0x26>
    return -1;
 43a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 43f:	eb 25                	jmp    466 <stat+0x4b>
  r = fstat(fd, st);
 441:	83 ec 08             	sub    $0x8,%esp
 444:	ff 75 0c             	push   0xc(%ebp)
 447:	ff 75 f4             	push   -0xc(%ebp)
 44a:	e8 03 01 00 00       	call   552 <fstat>
 44f:	83 c4 10             	add    $0x10,%esp
 452:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 455:	83 ec 0c             	sub    $0xc,%esp
 458:	ff 75 f4             	push   -0xc(%ebp)
 45b:	e8 c2 00 00 00       	call   522 <close>
 460:	83 c4 10             	add    $0x10,%esp
  return r;
 463:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 466:	c9                   	leave
 467:	c3                   	ret

00000468 <atoi>:

int
atoi(const char *s)
{
 468:	55                   	push   %ebp
 469:	89 e5                	mov    %esp,%ebp
 46b:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 46e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 475:	eb 25                	jmp    49c <atoi+0x34>
    n = n*10 + *s++ - '0';
 477:	8b 55 fc             	mov    -0x4(%ebp),%edx
 47a:	89 d0                	mov    %edx,%eax
 47c:	c1 e0 02             	shl    $0x2,%eax
 47f:	01 d0                	add    %edx,%eax
 481:	01 c0                	add    %eax,%eax
 483:	89 c1                	mov    %eax,%ecx
 485:	8b 45 08             	mov    0x8(%ebp),%eax
 488:	8d 50 01             	lea    0x1(%eax),%edx
 48b:	89 55 08             	mov    %edx,0x8(%ebp)
 48e:	0f b6 00             	movzbl (%eax),%eax
 491:	0f be c0             	movsbl %al,%eax
 494:	01 c8                	add    %ecx,%eax
 496:	83 e8 30             	sub    $0x30,%eax
 499:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 49c:	8b 45 08             	mov    0x8(%ebp),%eax
 49f:	0f b6 00             	movzbl (%eax),%eax
 4a2:	3c 2f                	cmp    $0x2f,%al
 4a4:	7e 0a                	jle    4b0 <atoi+0x48>
 4a6:	8b 45 08             	mov    0x8(%ebp),%eax
 4a9:	0f b6 00             	movzbl (%eax),%eax
 4ac:	3c 39                	cmp    $0x39,%al
 4ae:	7e c7                	jle    477 <atoi+0xf>
  return n;
 4b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4b3:	c9                   	leave
 4b4:	c3                   	ret

000004b5 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4b5:	55                   	push   %ebp
 4b6:	89 e5                	mov    %esp,%ebp
 4b8:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 4bb:	8b 45 08             	mov    0x8(%ebp),%eax
 4be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4c7:	eb 17                	jmp    4e0 <memmove+0x2b>
    *dst++ = *src++;
 4c9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4cc:	8d 42 01             	lea    0x1(%edx),%eax
 4cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4d5:	8d 48 01             	lea    0x1(%eax),%ecx
 4d8:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4db:	0f b6 12             	movzbl (%edx),%edx
 4de:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4e0:	8b 45 10             	mov    0x10(%ebp),%eax
 4e3:	8d 50 ff             	lea    -0x1(%eax),%edx
 4e6:	89 55 10             	mov    %edx,0x10(%ebp)
 4e9:	85 c0                	test   %eax,%eax
 4eb:	7f dc                	jg     4c9 <memmove+0x14>
  return vdst;
 4ed:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4f0:	c9                   	leave
 4f1:	c3                   	ret

000004f2 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4f2:	b8 01 00 00 00       	mov    $0x1,%eax
 4f7:	cd 40                	int    $0x40
 4f9:	c3                   	ret

000004fa <exit>:
SYSCALL(exit)
 4fa:	b8 02 00 00 00       	mov    $0x2,%eax
 4ff:	cd 40                	int    $0x40
 501:	c3                   	ret

00000502 <wait>:
SYSCALL(wait)
 502:	b8 03 00 00 00       	mov    $0x3,%eax
 507:	cd 40                	int    $0x40
 509:	c3                   	ret

0000050a <pipe>:
SYSCALL(pipe)
 50a:	b8 04 00 00 00       	mov    $0x4,%eax
 50f:	cd 40                	int    $0x40
 511:	c3                   	ret

00000512 <read>:
SYSCALL(read)
 512:	b8 05 00 00 00       	mov    $0x5,%eax
 517:	cd 40                	int    $0x40
 519:	c3                   	ret

0000051a <write>:
SYSCALL(write)
 51a:	b8 10 00 00 00       	mov    $0x10,%eax
 51f:	cd 40                	int    $0x40
 521:	c3                   	ret

00000522 <close>:
SYSCALL(close)
 522:	b8 15 00 00 00       	mov    $0x15,%eax
 527:	cd 40                	int    $0x40
 529:	c3                   	ret

0000052a <kill>:
SYSCALL(kill)
 52a:	b8 06 00 00 00       	mov    $0x6,%eax
 52f:	cd 40                	int    $0x40
 531:	c3                   	ret

00000532 <exec>:
SYSCALL(exec)
 532:	b8 07 00 00 00       	mov    $0x7,%eax
 537:	cd 40                	int    $0x40
 539:	c3                   	ret

0000053a <open>:
SYSCALL(open)
 53a:	b8 0f 00 00 00       	mov    $0xf,%eax
 53f:	cd 40                	int    $0x40
 541:	c3                   	ret

00000542 <mknod>:
SYSCALL(mknod)
 542:	b8 11 00 00 00       	mov    $0x11,%eax
 547:	cd 40                	int    $0x40
 549:	c3                   	ret

0000054a <unlink>:
SYSCALL(unlink)
 54a:	b8 12 00 00 00       	mov    $0x12,%eax
 54f:	cd 40                	int    $0x40
 551:	c3                   	ret

00000552 <fstat>:
SYSCALL(fstat)
 552:	b8 08 00 00 00       	mov    $0x8,%eax
 557:	cd 40                	int    $0x40
 559:	c3                   	ret

0000055a <link>:
SYSCALL(link)
 55a:	b8 13 00 00 00       	mov    $0x13,%eax
 55f:	cd 40                	int    $0x40
 561:	c3                   	ret

00000562 <mkdir>:
SYSCALL(mkdir)
 562:	b8 14 00 00 00       	mov    $0x14,%eax
 567:	cd 40                	int    $0x40
 569:	c3                   	ret

0000056a <chdir>:
SYSCALL(chdir)
 56a:	b8 09 00 00 00       	mov    $0x9,%eax
 56f:	cd 40                	int    $0x40
 571:	c3                   	ret

00000572 <dup>:
SYSCALL(dup)
 572:	b8 0a 00 00 00       	mov    $0xa,%eax
 577:	cd 40                	int    $0x40
 579:	c3                   	ret

0000057a <getpid>:
SYSCALL(getpid)
 57a:	b8 0b 00 00 00       	mov    $0xb,%eax
 57f:	cd 40                	int    $0x40
 581:	c3                   	ret

00000582 <sbrk>:
SYSCALL(sbrk)
 582:	b8 0c 00 00 00       	mov    $0xc,%eax
 587:	cd 40                	int    $0x40
 589:	c3                   	ret

0000058a <sleep>:
SYSCALL(sleep)
 58a:	b8 0d 00 00 00       	mov    $0xd,%eax
 58f:	cd 40                	int    $0x40
 591:	c3                   	ret

00000592 <uptime>:
SYSCALL(uptime)
 592:	b8 0e 00 00 00       	mov    $0xe,%eax
 597:	cd 40                	int    $0x40
 599:	c3                   	ret

0000059a <getpinfo>:

SYSCALL(getpinfo)
 59a:	b8 16 00 00 00       	mov    $0x16,%eax
 59f:	cd 40                	int    $0x40
 5a1:	c3                   	ret

000005a2 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 5a2:	b8 17 00 00 00       	mov    $0x17,%eax
 5a7:	cd 40                	int    $0x40
 5a9:	c3                   	ret

000005aa <yield>:
SYSCALL(yield)
 5aa:	b8 18 00 00 00       	mov    $0x18,%eax
 5af:	cd 40                	int    $0x40
 5b1:	c3                   	ret

000005b2 <getSchedPolicy>:
 5b2:	b8 19 00 00 00       	mov    $0x19,%eax
 5b7:	cd 40                	int    $0x40
 5b9:	c3                   	ret

000005ba <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5ba:	55                   	push   %ebp
 5bb:	89 e5                	mov    %esp,%ebp
 5bd:	83 ec 18             	sub    $0x18,%esp
 5c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c3:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5c6:	83 ec 04             	sub    $0x4,%esp
 5c9:	6a 01                	push   $0x1
 5cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5ce:	50                   	push   %eax
 5cf:	ff 75 08             	push   0x8(%ebp)
 5d2:	e8 43 ff ff ff       	call   51a <write>
 5d7:	83 c4 10             	add    $0x10,%esp
}
 5da:	90                   	nop
 5db:	c9                   	leave
 5dc:	c3                   	ret

000005dd <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5dd:	55                   	push   %ebp
 5de:	89 e5                	mov    %esp,%ebp
 5e0:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5e3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5ea:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5ee:	74 17                	je     607 <printint+0x2a>
 5f0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5f4:	79 11                	jns    607 <printint+0x2a>
    neg = 1;
 5f6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5fd:	8b 45 0c             	mov    0xc(%ebp),%eax
 600:	f7 d8                	neg    %eax
 602:	89 45 ec             	mov    %eax,-0x14(%ebp)
 605:	eb 06                	jmp    60d <printint+0x30>
  } else {
    x = xx;
 607:	8b 45 0c             	mov    0xc(%ebp),%eax
 60a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 60d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 614:	8b 4d 10             	mov    0x10(%ebp),%ecx
 617:	8b 45 ec             	mov    -0x14(%ebp),%eax
 61a:	ba 00 00 00 00       	mov    $0x0,%edx
 61f:	f7 f1                	div    %ecx
 621:	89 d1                	mov    %edx,%ecx
 623:	8b 45 f4             	mov    -0xc(%ebp),%eax
 626:	8d 50 01             	lea    0x1(%eax),%edx
 629:	89 55 f4             	mov    %edx,-0xc(%ebp)
 62c:	0f b6 91 10 0e 00 00 	movzbl 0xe10(%ecx),%edx
 633:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 637:	8b 4d 10             	mov    0x10(%ebp),%ecx
 63a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 63d:	ba 00 00 00 00       	mov    $0x0,%edx
 642:	f7 f1                	div    %ecx
 644:	89 45 ec             	mov    %eax,-0x14(%ebp)
 647:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 64b:	75 c7                	jne    614 <printint+0x37>
  if(neg)
 64d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 651:	74 2d                	je     680 <printint+0xa3>
    buf[i++] = '-';
 653:	8b 45 f4             	mov    -0xc(%ebp),%eax
 656:	8d 50 01             	lea    0x1(%eax),%edx
 659:	89 55 f4             	mov    %edx,-0xc(%ebp)
 65c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 661:	eb 1d                	jmp    680 <printint+0xa3>
    putc(fd, buf[i]);
 663:	8d 55 dc             	lea    -0x24(%ebp),%edx
 666:	8b 45 f4             	mov    -0xc(%ebp),%eax
 669:	01 d0                	add    %edx,%eax
 66b:	0f b6 00             	movzbl (%eax),%eax
 66e:	0f be c0             	movsbl %al,%eax
 671:	83 ec 08             	sub    $0x8,%esp
 674:	50                   	push   %eax
 675:	ff 75 08             	push   0x8(%ebp)
 678:	e8 3d ff ff ff       	call   5ba <putc>
 67d:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 680:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 684:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 688:	79 d9                	jns    663 <printint+0x86>
}
 68a:	90                   	nop
 68b:	90                   	nop
 68c:	c9                   	leave
 68d:	c3                   	ret

0000068e <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 68e:	55                   	push   %ebp
 68f:	89 e5                	mov    %esp,%ebp
 691:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 694:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 69b:	8d 45 0c             	lea    0xc(%ebp),%eax
 69e:	83 c0 04             	add    $0x4,%eax
 6a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6a4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6ab:	e9 59 01 00 00       	jmp    809 <printf+0x17b>
    c = fmt[i] & 0xff;
 6b0:	8b 55 0c             	mov    0xc(%ebp),%edx
 6b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b6:	01 d0                	add    %edx,%eax
 6b8:	0f b6 00             	movzbl (%eax),%eax
 6bb:	0f be c0             	movsbl %al,%eax
 6be:	25 ff 00 00 00       	and    $0xff,%eax
 6c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6c6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6ca:	75 2c                	jne    6f8 <printf+0x6a>
      if(c == '%'){
 6cc:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6d0:	75 0c                	jne    6de <printf+0x50>
        state = '%';
 6d2:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6d9:	e9 27 01 00 00       	jmp    805 <printf+0x177>
      } else {
        putc(fd, c);
 6de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e1:	0f be c0             	movsbl %al,%eax
 6e4:	83 ec 08             	sub    $0x8,%esp
 6e7:	50                   	push   %eax
 6e8:	ff 75 08             	push   0x8(%ebp)
 6eb:	e8 ca fe ff ff       	call   5ba <putc>
 6f0:	83 c4 10             	add    $0x10,%esp
 6f3:	e9 0d 01 00 00       	jmp    805 <printf+0x177>
      }
    } else if(state == '%'){
 6f8:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6fc:	0f 85 03 01 00 00    	jne    805 <printf+0x177>
      if(c == 'd'){
 702:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 706:	75 1e                	jne    726 <printf+0x98>
        printint(fd, *ap, 10, 1);
 708:	8b 45 e8             	mov    -0x18(%ebp),%eax
 70b:	8b 00                	mov    (%eax),%eax
 70d:	6a 01                	push   $0x1
 70f:	6a 0a                	push   $0xa
 711:	50                   	push   %eax
 712:	ff 75 08             	push   0x8(%ebp)
 715:	e8 c3 fe ff ff       	call   5dd <printint>
 71a:	83 c4 10             	add    $0x10,%esp
        ap++;
 71d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 721:	e9 d8 00 00 00       	jmp    7fe <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 726:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 72a:	74 06                	je     732 <printf+0xa4>
 72c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 730:	75 1e                	jne    750 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 732:	8b 45 e8             	mov    -0x18(%ebp),%eax
 735:	8b 00                	mov    (%eax),%eax
 737:	6a 00                	push   $0x0
 739:	6a 10                	push   $0x10
 73b:	50                   	push   %eax
 73c:	ff 75 08             	push   0x8(%ebp)
 73f:	e8 99 fe ff ff       	call   5dd <printint>
 744:	83 c4 10             	add    $0x10,%esp
        ap++;
 747:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 74b:	e9 ae 00 00 00       	jmp    7fe <printf+0x170>
      } else if(c == 's'){
 750:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 754:	75 43                	jne    799 <printf+0x10b>
        s = (char*)*ap;
 756:	8b 45 e8             	mov    -0x18(%ebp),%eax
 759:	8b 00                	mov    (%eax),%eax
 75b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 75e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 762:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 766:	75 25                	jne    78d <printf+0xff>
          s = "(null)";
 768:	c7 45 f4 52 0b 00 00 	movl   $0xb52,-0xc(%ebp)
        while(*s != 0){
 76f:	eb 1c                	jmp    78d <printf+0xff>
          putc(fd, *s);
 771:	8b 45 f4             	mov    -0xc(%ebp),%eax
 774:	0f b6 00             	movzbl (%eax),%eax
 777:	0f be c0             	movsbl %al,%eax
 77a:	83 ec 08             	sub    $0x8,%esp
 77d:	50                   	push   %eax
 77e:	ff 75 08             	push   0x8(%ebp)
 781:	e8 34 fe ff ff       	call   5ba <putc>
 786:	83 c4 10             	add    $0x10,%esp
          s++;
 789:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 78d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 790:	0f b6 00             	movzbl (%eax),%eax
 793:	84 c0                	test   %al,%al
 795:	75 da                	jne    771 <printf+0xe3>
 797:	eb 65                	jmp    7fe <printf+0x170>
        }
      } else if(c == 'c'){
 799:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 79d:	75 1d                	jne    7bc <printf+0x12e>
        putc(fd, *ap);
 79f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7a2:	8b 00                	mov    (%eax),%eax
 7a4:	0f be c0             	movsbl %al,%eax
 7a7:	83 ec 08             	sub    $0x8,%esp
 7aa:	50                   	push   %eax
 7ab:	ff 75 08             	push   0x8(%ebp)
 7ae:	e8 07 fe ff ff       	call   5ba <putc>
 7b3:	83 c4 10             	add    $0x10,%esp
        ap++;
 7b6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ba:	eb 42                	jmp    7fe <printf+0x170>
      } else if(c == '%'){
 7bc:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7c0:	75 17                	jne    7d9 <printf+0x14b>
        putc(fd, c);
 7c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7c5:	0f be c0             	movsbl %al,%eax
 7c8:	83 ec 08             	sub    $0x8,%esp
 7cb:	50                   	push   %eax
 7cc:	ff 75 08             	push   0x8(%ebp)
 7cf:	e8 e6 fd ff ff       	call   5ba <putc>
 7d4:	83 c4 10             	add    $0x10,%esp
 7d7:	eb 25                	jmp    7fe <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7d9:	83 ec 08             	sub    $0x8,%esp
 7dc:	6a 25                	push   $0x25
 7de:	ff 75 08             	push   0x8(%ebp)
 7e1:	e8 d4 fd ff ff       	call   5ba <putc>
 7e6:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7ec:	0f be c0             	movsbl %al,%eax
 7ef:	83 ec 08             	sub    $0x8,%esp
 7f2:	50                   	push   %eax
 7f3:	ff 75 08             	push   0x8(%ebp)
 7f6:	e8 bf fd ff ff       	call   5ba <putc>
 7fb:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7fe:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 805:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 809:	8b 55 0c             	mov    0xc(%ebp),%edx
 80c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80f:	01 d0                	add    %edx,%eax
 811:	0f b6 00             	movzbl (%eax),%eax
 814:	84 c0                	test   %al,%al
 816:	0f 85 94 fe ff ff    	jne    6b0 <printf+0x22>
    }
  }
}
 81c:	90                   	nop
 81d:	90                   	nop
 81e:	c9                   	leave
 81f:	c3                   	ret

00000820 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 820:	55                   	push   %ebp
 821:	89 e5                	mov    %esp,%ebp
 823:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 826:	8b 45 08             	mov    0x8(%ebp),%eax
 829:	83 e8 08             	sub    $0x8,%eax
 82c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82f:	a1 2c 0e 00 00       	mov    0xe2c,%eax
 834:	89 45 fc             	mov    %eax,-0x4(%ebp)
 837:	eb 24                	jmp    85d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 839:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83c:	8b 00                	mov    (%eax),%eax
 83e:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 841:	72 12                	jb     855 <free+0x35>
 843:	8b 45 f8             	mov    -0x8(%ebp),%eax
 846:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 849:	72 24                	jb     86f <free+0x4f>
 84b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84e:	8b 00                	mov    (%eax),%eax
 850:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 853:	72 1a                	jb     86f <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 855:	8b 45 fc             	mov    -0x4(%ebp),%eax
 858:	8b 00                	mov    (%eax),%eax
 85a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 85d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 860:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 863:	73 d4                	jae    839 <free+0x19>
 865:	8b 45 fc             	mov    -0x4(%ebp),%eax
 868:	8b 00                	mov    (%eax),%eax
 86a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 86d:	73 ca                	jae    839 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 86f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 872:	8b 40 04             	mov    0x4(%eax),%eax
 875:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 87c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87f:	01 c2                	add    %eax,%edx
 881:	8b 45 fc             	mov    -0x4(%ebp),%eax
 884:	8b 00                	mov    (%eax),%eax
 886:	39 c2                	cmp    %eax,%edx
 888:	75 24                	jne    8ae <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 88a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88d:	8b 50 04             	mov    0x4(%eax),%edx
 890:	8b 45 fc             	mov    -0x4(%ebp),%eax
 893:	8b 00                	mov    (%eax),%eax
 895:	8b 40 04             	mov    0x4(%eax),%eax
 898:	01 c2                	add    %eax,%edx
 89a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a3:	8b 00                	mov    (%eax),%eax
 8a5:	8b 10                	mov    (%eax),%edx
 8a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8aa:	89 10                	mov    %edx,(%eax)
 8ac:	eb 0a                	jmp    8b8 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b1:	8b 10                	mov    (%eax),%edx
 8b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bb:	8b 40 04             	mov    0x4(%eax),%eax
 8be:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c8:	01 d0                	add    %edx,%eax
 8ca:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8cd:	75 20                	jne    8ef <free+0xcf>
    p->s.size += bp->s.size;
 8cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d2:	8b 50 04             	mov    0x4(%eax),%edx
 8d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d8:	8b 40 04             	mov    0x4(%eax),%eax
 8db:	01 c2                	add    %eax,%edx
 8dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e6:	8b 10                	mov    (%eax),%edx
 8e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8eb:	89 10                	mov    %edx,(%eax)
 8ed:	eb 08                	jmp    8f7 <free+0xd7>
  } else
    p->s.ptr = bp;
 8ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8f5:	89 10                	mov    %edx,(%eax)
  freep = p;
 8f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fa:	a3 2c 0e 00 00       	mov    %eax,0xe2c
}
 8ff:	90                   	nop
 900:	c9                   	leave
 901:	c3                   	ret

00000902 <morecore>:

static Header*
morecore(uint nu)
{
 902:	55                   	push   %ebp
 903:	89 e5                	mov    %esp,%ebp
 905:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 908:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 90f:	77 07                	ja     918 <morecore+0x16>
    nu = 4096;
 911:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 918:	8b 45 08             	mov    0x8(%ebp),%eax
 91b:	c1 e0 03             	shl    $0x3,%eax
 91e:	83 ec 0c             	sub    $0xc,%esp
 921:	50                   	push   %eax
 922:	e8 5b fc ff ff       	call   582 <sbrk>
 927:	83 c4 10             	add    $0x10,%esp
 92a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 92d:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 931:	75 07                	jne    93a <morecore+0x38>
    return 0;
 933:	b8 00 00 00 00       	mov    $0x0,%eax
 938:	eb 26                	jmp    960 <morecore+0x5e>
  hp = (Header*)p;
 93a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 940:	8b 45 f0             	mov    -0x10(%ebp),%eax
 943:	8b 55 08             	mov    0x8(%ebp),%edx
 946:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 949:	8b 45 f0             	mov    -0x10(%ebp),%eax
 94c:	83 c0 08             	add    $0x8,%eax
 94f:	83 ec 0c             	sub    $0xc,%esp
 952:	50                   	push   %eax
 953:	e8 c8 fe ff ff       	call   820 <free>
 958:	83 c4 10             	add    $0x10,%esp
  return freep;
 95b:	a1 2c 0e 00 00       	mov    0xe2c,%eax
}
 960:	c9                   	leave
 961:	c3                   	ret

00000962 <malloc>:

void*
malloc(uint nbytes)
{
 962:	55                   	push   %ebp
 963:	89 e5                	mov    %esp,%ebp
 965:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 968:	8b 45 08             	mov    0x8(%ebp),%eax
 96b:	83 c0 07             	add    $0x7,%eax
 96e:	c1 e8 03             	shr    $0x3,%eax
 971:	83 c0 01             	add    $0x1,%eax
 974:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 977:	a1 2c 0e 00 00       	mov    0xe2c,%eax
 97c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 97f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 983:	75 23                	jne    9a8 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 985:	c7 45 f0 24 0e 00 00 	movl   $0xe24,-0x10(%ebp)
 98c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 98f:	a3 2c 0e 00 00       	mov    %eax,0xe2c
 994:	a1 2c 0e 00 00       	mov    0xe2c,%eax
 999:	a3 24 0e 00 00       	mov    %eax,0xe24
    base.s.size = 0;
 99e:	c7 05 28 0e 00 00 00 	movl   $0x0,0xe28
 9a5:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ab:	8b 00                	mov    (%eax),%eax
 9ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b3:	8b 40 04             	mov    0x4(%eax),%eax
 9b6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9b9:	72 4d                	jb     a08 <malloc+0xa6>
      if(p->s.size == nunits)
 9bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9be:	8b 40 04             	mov    0x4(%eax),%eax
 9c1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9c4:	75 0c                	jne    9d2 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c9:	8b 10                	mov    (%eax),%edx
 9cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ce:	89 10                	mov    %edx,(%eax)
 9d0:	eb 26                	jmp    9f8 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d5:	8b 40 04             	mov    0x4(%eax),%eax
 9d8:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9db:	89 c2                	mov    %eax,%edx
 9dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e0:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e6:	8b 40 04             	mov    0x4(%eax),%eax
 9e9:	c1 e0 03             	shl    $0x3,%eax
 9ec:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f2:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9f5:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9fb:	a3 2c 0e 00 00       	mov    %eax,0xe2c
      return (void*)(p + 1);
 a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a03:	83 c0 08             	add    $0x8,%eax
 a06:	eb 3b                	jmp    a43 <malloc+0xe1>
    }
    if(p == freep)
 a08:	a1 2c 0e 00 00       	mov    0xe2c,%eax
 a0d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a10:	75 1e                	jne    a30 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a12:	83 ec 0c             	sub    $0xc,%esp
 a15:	ff 75 ec             	push   -0x14(%ebp)
 a18:	e8 e5 fe ff ff       	call   902 <morecore>
 a1d:	83 c4 10             	add    $0x10,%esp
 a20:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a27:	75 07                	jne    a30 <malloc+0xce>
        return 0;
 a29:	b8 00 00 00 00       	mov    $0x0,%eax
 a2e:	eb 13                	jmp    a43 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a33:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a39:	8b 00                	mov    (%eax),%eax
 a3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a3e:	e9 6d ff ff ff       	jmp    9b0 <malloc+0x4e>
  }
}
 a43:	c9                   	leave
 a44:	c3                   	ret
