
_uthread1:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_init>:

static void thread_schedule(void);

void 
thread_init(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
   6:	c7 05 a0 0a 00 00 c0 	movl   $0xac0,0xaa0
   d:	0a 00 00 
  current_thread->state = RUNNING;
  10:	a1 a0 0a 00 00       	mov    0xaa0,%eax
  15:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  1c:	00 00 00 
  uthread_init((int)thread_schedule);
  1f:	b8 33 00 00 00       	mov    $0x33,%eax
  24:	83 ec 0c             	sub    $0xc,%esp
  27:	50                   	push   %eax
  28:	e8 53 05 00 00       	call   580 <uthread_init>
  2d:	83 c4 10             	add    $0x10,%esp
}
  30:	90                   	nop
  31:	c9                   	leave
  32:	c3                   	ret

00000033 <thread_schedule>:

static void
thread_schedule(void)
{ 
  33:	55                   	push   %ebp
  34:	89 e5                	mov    %esp,%ebp
  36:	83 ec 18             	sub    $0x18,%esp
  thread_p t;
  /* Find another runnable thread. */
  next_thread = 0;
  39:	c7 05 a4 0a 00 00 00 	movl   $0x0,0xaa4
  40:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  43:	c7 45 f4 c0 0a 00 00 	movl   $0xac0,-0xc(%ebp)
  4a:	eb 41                	jmp    8d <thread_schedule+0x5a>
    //printf(1,"t: %x, state %x \n", t, t->state);
    if(t == &all_thread[0] && t->state == RUNNABLE){
  4c:	81 7d f4 c0 0a 00 00 	cmpl   $0xac0,-0xc(%ebp)
  53:	75 0e                	jne    63 <thread_schedule+0x30>
  55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  58:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  5e:	83 f8 02             	cmp    $0x2,%eax
  61:	74 22                	je     85 <thread_schedule+0x52>
      continue;
    }
    if (t->state == RUNNABLE && t != current_thread) {
  63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  66:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  6c:	83 f8 02             	cmp    $0x2,%eax
  6f:	75 15                	jne    86 <thread_schedule+0x53>
  71:	a1 a0 0a 00 00       	mov    0xaa0,%eax
  76:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  79:	74 0b                	je     86 <thread_schedule+0x53>
      next_thread = t;
  7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  7e:	a3 a4 0a 00 00       	mov    %eax,0xaa4
      break;
  83:	eb 12                	jmp    97 <thread_schedule+0x64>
      continue;
  85:	90                   	nop
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  86:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  8d:	b8 e0 8a 00 00       	mov    $0x8ae0,%eax
  92:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  95:	72 b5                	jb     4c <thread_schedule+0x19>
    }
  }
  // printf(1,"next_thread %x ,state %x \n",next_thread, next_thread->state);
  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  97:	b8 e0 8a 00 00       	mov    $0x8ae0,%eax
  9c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  9f:	72 1a                	jb     bb <thread_schedule+0x88>
  a1:	a1 a0 0a 00 00       	mov    0xaa0,%eax
  a6:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  ac:	83 f8 02             	cmp    $0x2,%eax
  af:	75 0a                	jne    bb <thread_schedule+0x88>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  b1:	a1 a0 0a 00 00       	mov    0xaa0,%eax
  b6:	a3 a4 0a 00 00       	mov    %eax,0xaa4
  }

  if (next_thread == 0) {
  bb:	a1 a4 0a 00 00       	mov    0xaa4,%eax
  c0:	85 c0                	test   %eax,%eax
  c2:	75 17                	jne    db <thread_schedule+0xa8>
    printf(2, "thread_schedule: no runnable threads\n");
  c4:	83 ec 08             	sub    $0x8,%esp
  c7:	68 14 0a 00 00       	push   $0xa14
  cc:	6a 02                	push   $0x2
  ce:	e8 89 05 00 00       	call   65c <printf>
  d3:	83 c4 10             	add    $0x10,%esp
    exit();
  d6:	e8 05 04 00 00       	call   4e0 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  db:	8b 15 a0 0a 00 00    	mov    0xaa0,%edx
  e1:	a1 a4 0a 00 00       	mov    0xaa4,%eax
  e6:	39 c2                	cmp    %eax,%edx
  e8:	74 34                	je     11e <thread_schedule+0xeb>
    next_thread->state = RUNNING;
  ea:	a1 a4 0a 00 00       	mov    0xaa4,%eax
  ef:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  f6:	00 00 00 
    if (current_thread->state != FREE) current_thread->state = RUNNABLE;
  f9:	a1 a0 0a 00 00       	mov    0xaa0,%eax
  fe:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 104:	85 c0                	test   %eax,%eax
 106:	74 0f                	je     117 <thread_schedule+0xe4>
 108:	a1 a0 0a 00 00       	mov    0xaa0,%eax
 10d:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 114:	00 00 00 
    thread_switch();
 117:	e8 4d 01 00 00       	call   269 <thread_switch>
  } else
    next_thread = 0;
}
 11c:	eb 0a                	jmp    128 <thread_schedule+0xf5>
    next_thread = 0;
 11e:	c7 05 a4 0a 00 00 00 	movl   $0x0,0xaa4
 125:	00 00 00 
}
 128:	90                   	nop
 129:	c9                   	leave
 12a:	c3                   	ret

0000012b <thread_create>:

void 
thread_create(void (*func)())
{
 12b:	55                   	push   %ebp
 12c:	89 e5                	mov    %esp,%ebp
 12e:	83 ec 18             	sub    $0x18,%esp
  printf(1,"thread_create\n");
 131:	83 ec 08             	sub    $0x8,%esp
 134:	68 3a 0a 00 00       	push   $0xa3a
 139:	6a 01                	push   $0x1
 13b:	e8 1c 05 00 00       	call   65c <printf>
 140:	83 c4 10             	add    $0x10,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 143:	c7 45 f4 c0 0a 00 00 	movl   $0xac0,-0xc(%ebp)
 14a:	eb 14                	jmp    160 <thread_create+0x35>
    if (t->state == FREE) break;
 14c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 14f:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 155:	85 c0                	test   %eax,%eax
 157:	74 13                	je     16c <thread_create+0x41>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 159:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 160:	b8 e0 8a 00 00       	mov    $0x8ae0,%eax
 165:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 168:	72 e2                	jb     14c <thread_create+0x21>
 16a:	eb 01                	jmp    16d <thread_create+0x42>
    if (t->state == FREE) break;
 16c:	90                   	nop
  }
  // 스택 포인터 = 스택의 top f rame
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 16d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 170:	83 c0 04             	add    $0x4,%eax
 173:	05 00 20 00 00       	add    $0x2000,%eax
 178:	89 c2                	mov    %eax,%edx
 17a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17d:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                              // space for return address
 17f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 182:	8b 00                	mov    (%eax),%eax
 184:	8d 50 fc             	lea    -0x4(%eax),%edx
 187:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18a:	89 10                	mov    %edx,(%eax)
  * (int *) (t->sp) = (int)func;           // push return address on stack
 18c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18f:	8b 00                	mov    (%eax),%eax
 191:	89 c2                	mov    %eax,%edx
 193:	8b 45 08             	mov    0x8(%ebp),%eax
 196:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                             // space for registers that thread_switch expects
 198:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19b:	8b 00                	mov    (%eax),%eax
 19d:	8d 50 e0             	lea    -0x20(%eax),%edx
 1a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a3:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 1a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a8:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1af:	00 00 00 
}
 1b2:	90                   	nop
 1b3:	c9                   	leave
 1b4:	c3                   	ret

000001b5 <mythread>:

static void 
mythread(void)
{
 1b5:	55                   	push   %ebp
 1b6:	89 e5                	mov    %esp,%ebp
 1b8:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 1bb:	83 ec 08             	sub    $0x8,%esp
 1be:	68 49 0a 00 00       	push   $0xa49
 1c3:	6a 01                	push   $0x1
 1c5:	e8 92 04 00 00       	call   65c <printf>
 1ca:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 10; i++) {
 1cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1d4:	eb 1c                	jmp    1f2 <mythread+0x3d>
    printf(1, "my thread 0x%x\n", (int) current_thread);
 1d6:	a1 a0 0a 00 00       	mov    0xaa0,%eax
 1db:	83 ec 04             	sub    $0x4,%esp
 1de:	50                   	push   %eax
 1df:	68 5c 0a 00 00       	push   $0xa5c
 1e4:	6a 01                	push   $0x1
 1e6:	e8 71 04 00 00       	call   65c <printf>
 1eb:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 10; i++) {
 1ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1f2:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
 1f6:	7e de                	jle    1d6 <mythread+0x21>
  }
  printf(1, "my thread: exit\n");
 1f8:	83 ec 08             	sub    $0x8,%esp
 1fb:	68 6c 0a 00 00       	push   $0xa6c
 200:	6a 01                	push   $0x1
 202:	e8 55 04 00 00       	call   65c <printf>
 207:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 20a:	a1 a0 0a 00 00       	mov    0xaa0,%eax
 20f:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 216:	00 00 00 
  thread_schedule();
 219:	e8 15 fe ff ff       	call   33 <thread_schedule>
}
 21e:	90                   	nop
 21f:	c9                   	leave
 220:	c3                   	ret

00000221 <main>:


int 
main(int argc, char *argv[]) 
{
 221:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 225:	83 e4 f0             	and    $0xfffffff0,%esp
 228:	ff 71 fc             	push   -0x4(%ecx)
 22b:	55                   	push   %ebp
 22c:	89 e5                	mov    %esp,%ebp
 22e:	51                   	push   %ecx
 22f:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 232:	e8 c9 fd ff ff       	call   0 <thread_init>
  thread_create(mythread);
 237:	83 ec 0c             	sub    $0xc,%esp
 23a:	68 b5 01 00 00       	push   $0x1b5
 23f:	e8 e7 fe ff ff       	call   12b <thread_create>
 244:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 247:	83 ec 0c             	sub    $0xc,%esp
 24a:	68 b5 01 00 00       	push   $0x1b5
 24f:	e8 d7 fe ff ff       	call   12b <thread_create>
 254:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 257:	e8 d7 fd ff ff       	call   33 <thread_schedule>
  return 0;
 25c:	b8 00 00 00 00       	mov    $0x0,%eax
 261:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 264:	c9                   	leave
 265:	8d 61 fc             	lea    -0x4(%ecx),%esp
 268:	c3                   	ret

00000269 <thread_switch>:
         */
    .text
    .globl thread_switch
thread_switch:

    pushal
 269:	60                   	pusha

    movl current_thread, %eax
 26a:	a1 a0 0a 00 00       	mov    0xaa0,%eax
    movl %esp, (%eax)
 26f:	89 20                	mov    %esp,(%eax)

    movl next_thread, %eax
 271:	a1 a4 0a 00 00       	mov    0xaa4,%eax
    movl (%eax), %esp
 276:	8b 20                	mov    (%eax),%esp
    # esp = t1.주소

    movl %eax, current_thread
 278:	a3 a0 0a 00 00       	mov    %eax,0xaa0

    // 레지스터 복구
    popal
 27d:	61                   	popa

    movl $0, next_thread
 27e:	c7 05 a4 0a 00 00 00 	movl   $0x0,0xaa4
 285:	00 00 00 
    
 288:	c3                   	ret

00000289 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 289:	55                   	push   %ebp
 28a:	89 e5                	mov    %esp,%ebp
 28c:	57                   	push   %edi
 28d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 28e:	8b 4d 08             	mov    0x8(%ebp),%ecx
 291:	8b 55 10             	mov    0x10(%ebp),%edx
 294:	8b 45 0c             	mov    0xc(%ebp),%eax
 297:	89 cb                	mov    %ecx,%ebx
 299:	89 df                	mov    %ebx,%edi
 29b:	89 d1                	mov    %edx,%ecx
 29d:	fc                   	cld
 29e:	f3 aa                	rep stos %al,%es:(%edi)
 2a0:	89 ca                	mov    %ecx,%edx
 2a2:	89 fb                	mov    %edi,%ebx
 2a4:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2a7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2aa:	90                   	nop
 2ab:	5b                   	pop    %ebx
 2ac:	5f                   	pop    %edi
 2ad:	5d                   	pop    %ebp
 2ae:	c3                   	ret

000002af <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2af:	55                   	push   %ebp
 2b0:	89 e5                	mov    %esp,%ebp
 2b2:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2b5:	8b 45 08             	mov    0x8(%ebp),%eax
 2b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2bb:	90                   	nop
 2bc:	8b 55 0c             	mov    0xc(%ebp),%edx
 2bf:	8d 42 01             	lea    0x1(%edx),%eax
 2c2:	89 45 0c             	mov    %eax,0xc(%ebp)
 2c5:	8b 45 08             	mov    0x8(%ebp),%eax
 2c8:	8d 48 01             	lea    0x1(%eax),%ecx
 2cb:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2ce:	0f b6 12             	movzbl (%edx),%edx
 2d1:	88 10                	mov    %dl,(%eax)
 2d3:	0f b6 00             	movzbl (%eax),%eax
 2d6:	84 c0                	test   %al,%al
 2d8:	75 e2                	jne    2bc <strcpy+0xd>
    ;
  return os;
 2da:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2dd:	c9                   	leave
 2de:	c3                   	ret

000002df <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2df:	55                   	push   %ebp
 2e0:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2e2:	eb 08                	jmp    2ec <strcmp+0xd>
    p++, q++;
 2e4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2e8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 2ec:	8b 45 08             	mov    0x8(%ebp),%eax
 2ef:	0f b6 00             	movzbl (%eax),%eax
 2f2:	84 c0                	test   %al,%al
 2f4:	74 10                	je     306 <strcmp+0x27>
 2f6:	8b 45 08             	mov    0x8(%ebp),%eax
 2f9:	0f b6 10             	movzbl (%eax),%edx
 2fc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ff:	0f b6 00             	movzbl (%eax),%eax
 302:	38 c2                	cmp    %al,%dl
 304:	74 de                	je     2e4 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 306:	8b 45 08             	mov    0x8(%ebp),%eax
 309:	0f b6 00             	movzbl (%eax),%eax
 30c:	0f b6 d0             	movzbl %al,%edx
 30f:	8b 45 0c             	mov    0xc(%ebp),%eax
 312:	0f b6 00             	movzbl (%eax),%eax
 315:	0f b6 c0             	movzbl %al,%eax
 318:	29 c2                	sub    %eax,%edx
 31a:	89 d0                	mov    %edx,%eax
}
 31c:	5d                   	pop    %ebp
 31d:	c3                   	ret

0000031e <strlen>:

uint
strlen(char *s)
{
 31e:	55                   	push   %ebp
 31f:	89 e5                	mov    %esp,%ebp
 321:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 324:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 32b:	eb 04                	jmp    331 <strlen+0x13>
 32d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 331:	8b 55 fc             	mov    -0x4(%ebp),%edx
 334:	8b 45 08             	mov    0x8(%ebp),%eax
 337:	01 d0                	add    %edx,%eax
 339:	0f b6 00             	movzbl (%eax),%eax
 33c:	84 c0                	test   %al,%al
 33e:	75 ed                	jne    32d <strlen+0xf>
    ;
  return n;
 340:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 343:	c9                   	leave
 344:	c3                   	ret

00000345 <memset>:

void*
memset(void *dst, int c, uint n)
{
 345:	55                   	push   %ebp
 346:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 348:	8b 45 10             	mov    0x10(%ebp),%eax
 34b:	50                   	push   %eax
 34c:	ff 75 0c             	push   0xc(%ebp)
 34f:	ff 75 08             	push   0x8(%ebp)
 352:	e8 32 ff ff ff       	call   289 <stosb>
 357:	83 c4 0c             	add    $0xc,%esp
  return dst;
 35a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 35d:	c9                   	leave
 35e:	c3                   	ret

0000035f <strchr>:

char*
strchr(const char *s, char c)
{
 35f:	55                   	push   %ebp
 360:	89 e5                	mov    %esp,%ebp
 362:	83 ec 04             	sub    $0x4,%esp
 365:	8b 45 0c             	mov    0xc(%ebp),%eax
 368:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 36b:	eb 14                	jmp    381 <strchr+0x22>
    if(*s == c)
 36d:	8b 45 08             	mov    0x8(%ebp),%eax
 370:	0f b6 00             	movzbl (%eax),%eax
 373:	38 45 fc             	cmp    %al,-0x4(%ebp)
 376:	75 05                	jne    37d <strchr+0x1e>
      return (char*)s;
 378:	8b 45 08             	mov    0x8(%ebp),%eax
 37b:	eb 13                	jmp    390 <strchr+0x31>
  for(; *s; s++)
 37d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 381:	8b 45 08             	mov    0x8(%ebp),%eax
 384:	0f b6 00             	movzbl (%eax),%eax
 387:	84 c0                	test   %al,%al
 389:	75 e2                	jne    36d <strchr+0xe>
  return 0;
 38b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 390:	c9                   	leave
 391:	c3                   	ret

00000392 <gets>:

char*
gets(char *buf, int max)
{
 392:	55                   	push   %ebp
 393:	89 e5                	mov    %esp,%ebp
 395:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 398:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 39f:	eb 42                	jmp    3e3 <gets+0x51>
    cc = read(0, &c, 1);
 3a1:	83 ec 04             	sub    $0x4,%esp
 3a4:	6a 01                	push   $0x1
 3a6:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3a9:	50                   	push   %eax
 3aa:	6a 00                	push   $0x0
 3ac:	e8 47 01 00 00       	call   4f8 <read>
 3b1:	83 c4 10             	add    $0x10,%esp
 3b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3bb:	7e 33                	jle    3f0 <gets+0x5e>
      break;
    buf[i++] = c;
 3bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3c0:	8d 50 01             	lea    0x1(%eax),%edx
 3c3:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3c6:	89 c2                	mov    %eax,%edx
 3c8:	8b 45 08             	mov    0x8(%ebp),%eax
 3cb:	01 c2                	add    %eax,%edx
 3cd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3d1:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3d3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3d7:	3c 0a                	cmp    $0xa,%al
 3d9:	74 16                	je     3f1 <gets+0x5f>
 3db:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3df:	3c 0d                	cmp    $0xd,%al
 3e1:	74 0e                	je     3f1 <gets+0x5f>
  for(i=0; i+1 < max; ){
 3e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3e6:	83 c0 01             	add    $0x1,%eax
 3e9:	39 45 0c             	cmp    %eax,0xc(%ebp)
 3ec:	7f b3                	jg     3a1 <gets+0xf>
 3ee:	eb 01                	jmp    3f1 <gets+0x5f>
      break;
 3f0:	90                   	nop
      break;
  }
  buf[i] = '\0';
 3f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3f4:	8b 45 08             	mov    0x8(%ebp),%eax
 3f7:	01 d0                	add    %edx,%eax
 3f9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3fc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3ff:	c9                   	leave
 400:	c3                   	ret

00000401 <stat>:

int
stat(char *n, struct stat *st)
{
 401:	55                   	push   %ebp
 402:	89 e5                	mov    %esp,%ebp
 404:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 407:	83 ec 08             	sub    $0x8,%esp
 40a:	6a 00                	push   $0x0
 40c:	ff 75 08             	push   0x8(%ebp)
 40f:	e8 0c 01 00 00       	call   520 <open>
 414:	83 c4 10             	add    $0x10,%esp
 417:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 41a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 41e:	79 07                	jns    427 <stat+0x26>
    return -1;
 420:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 425:	eb 25                	jmp    44c <stat+0x4b>
  r = fstat(fd, st);
 427:	83 ec 08             	sub    $0x8,%esp
 42a:	ff 75 0c             	push   0xc(%ebp)
 42d:	ff 75 f4             	push   -0xc(%ebp)
 430:	e8 03 01 00 00       	call   538 <fstat>
 435:	83 c4 10             	add    $0x10,%esp
 438:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 43b:	83 ec 0c             	sub    $0xc,%esp
 43e:	ff 75 f4             	push   -0xc(%ebp)
 441:	e8 c2 00 00 00       	call   508 <close>
 446:	83 c4 10             	add    $0x10,%esp
  return r;
 449:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 44c:	c9                   	leave
 44d:	c3                   	ret

0000044e <atoi>:

int
atoi(const char *s)
{
 44e:	55                   	push   %ebp
 44f:	89 e5                	mov    %esp,%ebp
 451:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 454:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 45b:	eb 25                	jmp    482 <atoi+0x34>
    n = n*10 + *s++ - '0';
 45d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 460:	89 d0                	mov    %edx,%eax
 462:	c1 e0 02             	shl    $0x2,%eax
 465:	01 d0                	add    %edx,%eax
 467:	01 c0                	add    %eax,%eax
 469:	89 c1                	mov    %eax,%ecx
 46b:	8b 45 08             	mov    0x8(%ebp),%eax
 46e:	8d 50 01             	lea    0x1(%eax),%edx
 471:	89 55 08             	mov    %edx,0x8(%ebp)
 474:	0f b6 00             	movzbl (%eax),%eax
 477:	0f be c0             	movsbl %al,%eax
 47a:	01 c8                	add    %ecx,%eax
 47c:	83 e8 30             	sub    $0x30,%eax
 47f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 482:	8b 45 08             	mov    0x8(%ebp),%eax
 485:	0f b6 00             	movzbl (%eax),%eax
 488:	3c 2f                	cmp    $0x2f,%al
 48a:	7e 0a                	jle    496 <atoi+0x48>
 48c:	8b 45 08             	mov    0x8(%ebp),%eax
 48f:	0f b6 00             	movzbl (%eax),%eax
 492:	3c 39                	cmp    $0x39,%al
 494:	7e c7                	jle    45d <atoi+0xf>
  return n;
 496:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 499:	c9                   	leave
 49a:	c3                   	ret

0000049b <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 49b:	55                   	push   %ebp
 49c:	89 e5                	mov    %esp,%ebp
 49e:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 4a1:	8b 45 08             	mov    0x8(%ebp),%eax
 4a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4a7:	8b 45 0c             	mov    0xc(%ebp),%eax
 4aa:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4ad:	eb 17                	jmp    4c6 <memmove+0x2b>
    *dst++ = *src++;
 4af:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4b2:	8d 42 01             	lea    0x1(%edx),%eax
 4b5:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4bb:	8d 48 01             	lea    0x1(%eax),%ecx
 4be:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4c1:	0f b6 12             	movzbl (%edx),%edx
 4c4:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4c6:	8b 45 10             	mov    0x10(%ebp),%eax
 4c9:	8d 50 ff             	lea    -0x1(%eax),%edx
 4cc:	89 55 10             	mov    %edx,0x10(%ebp)
 4cf:	85 c0                	test   %eax,%eax
 4d1:	7f dc                	jg     4af <memmove+0x14>
  return vdst;
 4d3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4d6:	c9                   	leave
 4d7:	c3                   	ret

000004d8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4d8:	b8 01 00 00 00       	mov    $0x1,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret

000004e0 <exit>:
SYSCALL(exit)
 4e0:	b8 02 00 00 00       	mov    $0x2,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret

000004e8 <wait>:
SYSCALL(wait)
 4e8:	b8 03 00 00 00       	mov    $0x3,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret

000004f0 <pipe>:
SYSCALL(pipe)
 4f0:	b8 04 00 00 00       	mov    $0x4,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret

000004f8 <read>:
SYSCALL(read)
 4f8:	b8 05 00 00 00       	mov    $0x5,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret

00000500 <write>:
SYSCALL(write)
 500:	b8 10 00 00 00       	mov    $0x10,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret

00000508 <close>:
SYSCALL(close)
 508:	b8 15 00 00 00       	mov    $0x15,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret

00000510 <kill>:
SYSCALL(kill)
 510:	b8 06 00 00 00       	mov    $0x6,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret

00000518 <exec>:
SYSCALL(exec)
 518:	b8 07 00 00 00       	mov    $0x7,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret

00000520 <open>:
SYSCALL(open)
 520:	b8 0f 00 00 00       	mov    $0xf,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret

00000528 <mknod>:
SYSCALL(mknod)
 528:	b8 11 00 00 00       	mov    $0x11,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret

00000530 <unlink>:
SYSCALL(unlink)
 530:	b8 12 00 00 00       	mov    $0x12,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret

00000538 <fstat>:
SYSCALL(fstat)
 538:	b8 08 00 00 00       	mov    $0x8,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret

00000540 <link>:
SYSCALL(link)
 540:	b8 13 00 00 00       	mov    $0x13,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret

00000548 <mkdir>:
SYSCALL(mkdir)
 548:	b8 14 00 00 00       	mov    $0x14,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret

00000550 <chdir>:
SYSCALL(chdir)
 550:	b8 09 00 00 00       	mov    $0x9,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret

00000558 <dup>:
SYSCALL(dup)
 558:	b8 0a 00 00 00       	mov    $0xa,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret

00000560 <getpid>:
SYSCALL(getpid)
 560:	b8 0b 00 00 00       	mov    $0xb,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret

00000568 <sbrk>:
SYSCALL(sbrk)
 568:	b8 0c 00 00 00       	mov    $0xc,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret

00000570 <sleep>:
SYSCALL(sleep)
 570:	b8 0d 00 00 00       	mov    $0xd,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret

00000578 <uptime>:
SYSCALL(uptime)
 578:	b8 0e 00 00 00       	mov    $0xe,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret

00000580 <uthread_init>:
SYSCALL(uthread_init)
 580:	b8 16 00 00 00       	mov    $0x16,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret

00000588 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 588:	55                   	push   %ebp
 589:	89 e5                	mov    %esp,%ebp
 58b:	83 ec 18             	sub    $0x18,%esp
 58e:	8b 45 0c             	mov    0xc(%ebp),%eax
 591:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 594:	83 ec 04             	sub    $0x4,%esp
 597:	6a 01                	push   $0x1
 599:	8d 45 f4             	lea    -0xc(%ebp),%eax
 59c:	50                   	push   %eax
 59d:	ff 75 08             	push   0x8(%ebp)
 5a0:	e8 5b ff ff ff       	call   500 <write>
 5a5:	83 c4 10             	add    $0x10,%esp
}
 5a8:	90                   	nop
 5a9:	c9                   	leave
 5aa:	c3                   	ret

000005ab <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5ab:	55                   	push   %ebp
 5ac:	89 e5                	mov    %esp,%ebp
 5ae:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5b1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5b8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5bc:	74 17                	je     5d5 <printint+0x2a>
 5be:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5c2:	79 11                	jns    5d5 <printint+0x2a>
    neg = 1;
 5c4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5cb:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ce:	f7 d8                	neg    %eax
 5d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5d3:	eb 06                	jmp    5db <printint+0x30>
  } else {
    x = xx;
 5d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5e8:	ba 00 00 00 00       	mov    $0x0,%edx
 5ed:	f7 f1                	div    %ecx
 5ef:	89 d1                	mov    %edx,%ecx
 5f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f4:	8d 50 01             	lea    0x1(%eax),%edx
 5f7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5fa:	0f b6 91 84 0a 00 00 	movzbl 0xa84(%ecx),%edx
 601:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 605:	8b 4d 10             	mov    0x10(%ebp),%ecx
 608:	8b 45 ec             	mov    -0x14(%ebp),%eax
 60b:	ba 00 00 00 00       	mov    $0x0,%edx
 610:	f7 f1                	div    %ecx
 612:	89 45 ec             	mov    %eax,-0x14(%ebp)
 615:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 619:	75 c7                	jne    5e2 <printint+0x37>
  if(neg)
 61b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 61f:	74 2d                	je     64e <printint+0xa3>
    buf[i++] = '-';
 621:	8b 45 f4             	mov    -0xc(%ebp),%eax
 624:	8d 50 01             	lea    0x1(%eax),%edx
 627:	89 55 f4             	mov    %edx,-0xc(%ebp)
 62a:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 62f:	eb 1d                	jmp    64e <printint+0xa3>
    putc(fd, buf[i]);
 631:	8d 55 dc             	lea    -0x24(%ebp),%edx
 634:	8b 45 f4             	mov    -0xc(%ebp),%eax
 637:	01 d0                	add    %edx,%eax
 639:	0f b6 00             	movzbl (%eax),%eax
 63c:	0f be c0             	movsbl %al,%eax
 63f:	83 ec 08             	sub    $0x8,%esp
 642:	50                   	push   %eax
 643:	ff 75 08             	push   0x8(%ebp)
 646:	e8 3d ff ff ff       	call   588 <putc>
 64b:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 64e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 652:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 656:	79 d9                	jns    631 <printint+0x86>
}
 658:	90                   	nop
 659:	90                   	nop
 65a:	c9                   	leave
 65b:	c3                   	ret

0000065c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 65c:	55                   	push   %ebp
 65d:	89 e5                	mov    %esp,%ebp
 65f:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 662:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 669:	8d 45 0c             	lea    0xc(%ebp),%eax
 66c:	83 c0 04             	add    $0x4,%eax
 66f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 672:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 679:	e9 59 01 00 00       	jmp    7d7 <printf+0x17b>
    c = fmt[i] & 0xff;
 67e:	8b 55 0c             	mov    0xc(%ebp),%edx
 681:	8b 45 f0             	mov    -0x10(%ebp),%eax
 684:	01 d0                	add    %edx,%eax
 686:	0f b6 00             	movzbl (%eax),%eax
 689:	0f be c0             	movsbl %al,%eax
 68c:	25 ff 00 00 00       	and    $0xff,%eax
 691:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 694:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 698:	75 2c                	jne    6c6 <printf+0x6a>
      if(c == '%'){
 69a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 69e:	75 0c                	jne    6ac <printf+0x50>
        state = '%';
 6a0:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6a7:	e9 27 01 00 00       	jmp    7d3 <printf+0x177>
      } else {
        putc(fd, c);
 6ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6af:	0f be c0             	movsbl %al,%eax
 6b2:	83 ec 08             	sub    $0x8,%esp
 6b5:	50                   	push   %eax
 6b6:	ff 75 08             	push   0x8(%ebp)
 6b9:	e8 ca fe ff ff       	call   588 <putc>
 6be:	83 c4 10             	add    $0x10,%esp
 6c1:	e9 0d 01 00 00       	jmp    7d3 <printf+0x177>
      }
    } else if(state == '%'){
 6c6:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6ca:	0f 85 03 01 00 00    	jne    7d3 <printf+0x177>
      if(c == 'd'){
 6d0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6d4:	75 1e                	jne    6f4 <printf+0x98>
        printint(fd, *ap, 10, 1);
 6d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6d9:	8b 00                	mov    (%eax),%eax
 6db:	6a 01                	push   $0x1
 6dd:	6a 0a                	push   $0xa
 6df:	50                   	push   %eax
 6e0:	ff 75 08             	push   0x8(%ebp)
 6e3:	e8 c3 fe ff ff       	call   5ab <printint>
 6e8:	83 c4 10             	add    $0x10,%esp
        ap++;
 6eb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ef:	e9 d8 00 00 00       	jmp    7cc <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6f4:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6f8:	74 06                	je     700 <printf+0xa4>
 6fa:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6fe:	75 1e                	jne    71e <printf+0xc2>
        printint(fd, *ap, 16, 0);
 700:	8b 45 e8             	mov    -0x18(%ebp),%eax
 703:	8b 00                	mov    (%eax),%eax
 705:	6a 00                	push   $0x0
 707:	6a 10                	push   $0x10
 709:	50                   	push   %eax
 70a:	ff 75 08             	push   0x8(%ebp)
 70d:	e8 99 fe ff ff       	call   5ab <printint>
 712:	83 c4 10             	add    $0x10,%esp
        ap++;
 715:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 719:	e9 ae 00 00 00       	jmp    7cc <printf+0x170>
      } else if(c == 's'){
 71e:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 722:	75 43                	jne    767 <printf+0x10b>
        s = (char*)*ap;
 724:	8b 45 e8             	mov    -0x18(%ebp),%eax
 727:	8b 00                	mov    (%eax),%eax
 729:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 72c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 730:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 734:	75 25                	jne    75b <printf+0xff>
          s = "(null)";
 736:	c7 45 f4 7d 0a 00 00 	movl   $0xa7d,-0xc(%ebp)
        while(*s != 0){
 73d:	eb 1c                	jmp    75b <printf+0xff>
          putc(fd, *s);
 73f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 742:	0f b6 00             	movzbl (%eax),%eax
 745:	0f be c0             	movsbl %al,%eax
 748:	83 ec 08             	sub    $0x8,%esp
 74b:	50                   	push   %eax
 74c:	ff 75 08             	push   0x8(%ebp)
 74f:	e8 34 fe ff ff       	call   588 <putc>
 754:	83 c4 10             	add    $0x10,%esp
          s++;
 757:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 75b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75e:	0f b6 00             	movzbl (%eax),%eax
 761:	84 c0                	test   %al,%al
 763:	75 da                	jne    73f <printf+0xe3>
 765:	eb 65                	jmp    7cc <printf+0x170>
        }
      } else if(c == 'c'){
 767:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 76b:	75 1d                	jne    78a <printf+0x12e>
        putc(fd, *ap);
 76d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 770:	8b 00                	mov    (%eax),%eax
 772:	0f be c0             	movsbl %al,%eax
 775:	83 ec 08             	sub    $0x8,%esp
 778:	50                   	push   %eax
 779:	ff 75 08             	push   0x8(%ebp)
 77c:	e8 07 fe ff ff       	call   588 <putc>
 781:	83 c4 10             	add    $0x10,%esp
        ap++;
 784:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 788:	eb 42                	jmp    7cc <printf+0x170>
      } else if(c == '%'){
 78a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 78e:	75 17                	jne    7a7 <printf+0x14b>
        putc(fd, c);
 790:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 793:	0f be c0             	movsbl %al,%eax
 796:	83 ec 08             	sub    $0x8,%esp
 799:	50                   	push   %eax
 79a:	ff 75 08             	push   0x8(%ebp)
 79d:	e8 e6 fd ff ff       	call   588 <putc>
 7a2:	83 c4 10             	add    $0x10,%esp
 7a5:	eb 25                	jmp    7cc <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7a7:	83 ec 08             	sub    $0x8,%esp
 7aa:	6a 25                	push   $0x25
 7ac:	ff 75 08             	push   0x8(%ebp)
 7af:	e8 d4 fd ff ff       	call   588 <putc>
 7b4:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7ba:	0f be c0             	movsbl %al,%eax
 7bd:	83 ec 08             	sub    $0x8,%esp
 7c0:	50                   	push   %eax
 7c1:	ff 75 08             	push   0x8(%ebp)
 7c4:	e8 bf fd ff ff       	call   588 <putc>
 7c9:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7cc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 7d3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7d7:	8b 55 0c             	mov    0xc(%ebp),%edx
 7da:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7dd:	01 d0                	add    %edx,%eax
 7df:	0f b6 00             	movzbl (%eax),%eax
 7e2:	84 c0                	test   %al,%al
 7e4:	0f 85 94 fe ff ff    	jne    67e <printf+0x22>
    }
  }
}
 7ea:	90                   	nop
 7eb:	90                   	nop
 7ec:	c9                   	leave
 7ed:	c3                   	ret

000007ee <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ee:	55                   	push   %ebp
 7ef:	89 e5                	mov    %esp,%ebp
 7f1:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f4:	8b 45 08             	mov    0x8(%ebp),%eax
 7f7:	83 e8 08             	sub    $0x8,%eax
 7fa:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fd:	a1 e8 8a 00 00       	mov    0x8ae8,%eax
 802:	89 45 fc             	mov    %eax,-0x4(%ebp)
 805:	eb 24                	jmp    82b <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 807:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80a:	8b 00                	mov    (%eax),%eax
 80c:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 80f:	72 12                	jb     823 <free+0x35>
 811:	8b 45 f8             	mov    -0x8(%ebp),%eax
 814:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 817:	72 24                	jb     83d <free+0x4f>
 819:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81c:	8b 00                	mov    (%eax),%eax
 81e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 821:	72 1a                	jb     83d <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 823:	8b 45 fc             	mov    -0x4(%ebp),%eax
 826:	8b 00                	mov    (%eax),%eax
 828:	89 45 fc             	mov    %eax,-0x4(%ebp)
 82b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82e:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 831:	73 d4                	jae    807 <free+0x19>
 833:	8b 45 fc             	mov    -0x4(%ebp),%eax
 836:	8b 00                	mov    (%eax),%eax
 838:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 83b:	73 ca                	jae    807 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 83d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 840:	8b 40 04             	mov    0x4(%eax),%eax
 843:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 84a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84d:	01 c2                	add    %eax,%edx
 84f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 852:	8b 00                	mov    (%eax),%eax
 854:	39 c2                	cmp    %eax,%edx
 856:	75 24                	jne    87c <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 858:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85b:	8b 50 04             	mov    0x4(%eax),%edx
 85e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 861:	8b 00                	mov    (%eax),%eax
 863:	8b 40 04             	mov    0x4(%eax),%eax
 866:	01 c2                	add    %eax,%edx
 868:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86b:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 86e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 871:	8b 00                	mov    (%eax),%eax
 873:	8b 10                	mov    (%eax),%edx
 875:	8b 45 f8             	mov    -0x8(%ebp),%eax
 878:	89 10                	mov    %edx,(%eax)
 87a:	eb 0a                	jmp    886 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 87c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87f:	8b 10                	mov    (%eax),%edx
 881:	8b 45 f8             	mov    -0x8(%ebp),%eax
 884:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 886:	8b 45 fc             	mov    -0x4(%ebp),%eax
 889:	8b 40 04             	mov    0x4(%eax),%eax
 88c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 893:	8b 45 fc             	mov    -0x4(%ebp),%eax
 896:	01 d0                	add    %edx,%eax
 898:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 89b:	75 20                	jne    8bd <free+0xcf>
    p->s.size += bp->s.size;
 89d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a0:	8b 50 04             	mov    0x4(%eax),%edx
 8a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a6:	8b 40 04             	mov    0x4(%eax),%eax
 8a9:	01 c2                	add    %eax,%edx
 8ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ae:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b4:	8b 10                	mov    (%eax),%edx
 8b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b9:	89 10                	mov    %edx,(%eax)
 8bb:	eb 08                	jmp    8c5 <free+0xd7>
  } else
    p->s.ptr = bp;
 8bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8c3:	89 10                	mov    %edx,(%eax)
  freep = p;
 8c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c8:	a3 e8 8a 00 00       	mov    %eax,0x8ae8
}
 8cd:	90                   	nop
 8ce:	c9                   	leave
 8cf:	c3                   	ret

000008d0 <morecore>:

static Header*
morecore(uint nu)
{
 8d0:	55                   	push   %ebp
 8d1:	89 e5                	mov    %esp,%ebp
 8d3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8d6:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8dd:	77 07                	ja     8e6 <morecore+0x16>
    nu = 4096;
 8df:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8e6:	8b 45 08             	mov    0x8(%ebp),%eax
 8e9:	c1 e0 03             	shl    $0x3,%eax
 8ec:	83 ec 0c             	sub    $0xc,%esp
 8ef:	50                   	push   %eax
 8f0:	e8 73 fc ff ff       	call   568 <sbrk>
 8f5:	83 c4 10             	add    $0x10,%esp
 8f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8fb:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8ff:	75 07                	jne    908 <morecore+0x38>
    return 0;
 901:	b8 00 00 00 00       	mov    $0x0,%eax
 906:	eb 26                	jmp    92e <morecore+0x5e>
  hp = (Header*)p;
 908:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 90e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 911:	8b 55 08             	mov    0x8(%ebp),%edx
 914:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 917:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91a:	83 c0 08             	add    $0x8,%eax
 91d:	83 ec 0c             	sub    $0xc,%esp
 920:	50                   	push   %eax
 921:	e8 c8 fe ff ff       	call   7ee <free>
 926:	83 c4 10             	add    $0x10,%esp
  return freep;
 929:	a1 e8 8a 00 00       	mov    0x8ae8,%eax
}
 92e:	c9                   	leave
 92f:	c3                   	ret

00000930 <malloc>:

void*
malloc(uint nbytes)
{
 930:	55                   	push   %ebp
 931:	89 e5                	mov    %esp,%ebp
 933:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 936:	8b 45 08             	mov    0x8(%ebp),%eax
 939:	83 c0 07             	add    $0x7,%eax
 93c:	c1 e8 03             	shr    $0x3,%eax
 93f:	83 c0 01             	add    $0x1,%eax
 942:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 945:	a1 e8 8a 00 00       	mov    0x8ae8,%eax
 94a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 94d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 951:	75 23                	jne    976 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 953:	c7 45 f0 e0 8a 00 00 	movl   $0x8ae0,-0x10(%ebp)
 95a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95d:	a3 e8 8a 00 00       	mov    %eax,0x8ae8
 962:	a1 e8 8a 00 00       	mov    0x8ae8,%eax
 967:	a3 e0 8a 00 00       	mov    %eax,0x8ae0
    base.s.size = 0;
 96c:	c7 05 e4 8a 00 00 00 	movl   $0x0,0x8ae4
 973:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 976:	8b 45 f0             	mov    -0x10(%ebp),%eax
 979:	8b 00                	mov    (%eax),%eax
 97b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 97e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 981:	8b 40 04             	mov    0x4(%eax),%eax
 984:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 987:	72 4d                	jb     9d6 <malloc+0xa6>
      if(p->s.size == nunits)
 989:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98c:	8b 40 04             	mov    0x4(%eax),%eax
 98f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 992:	75 0c                	jne    9a0 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 994:	8b 45 f4             	mov    -0xc(%ebp),%eax
 997:	8b 10                	mov    (%eax),%edx
 999:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99c:	89 10                	mov    %edx,(%eax)
 99e:	eb 26                	jmp    9c6 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a3:	8b 40 04             	mov    0x4(%eax),%eax
 9a6:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9a9:	89 c2                	mov    %eax,%edx
 9ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ae:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b4:	8b 40 04             	mov    0x4(%eax),%eax
 9b7:	c1 e0 03             	shl    $0x3,%eax
 9ba:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c0:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9c3:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c9:	a3 e8 8a 00 00       	mov    %eax,0x8ae8
      return (void*)(p + 1);
 9ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d1:	83 c0 08             	add    $0x8,%eax
 9d4:	eb 3b                	jmp    a11 <malloc+0xe1>
    }
    if(p == freep)
 9d6:	a1 e8 8a 00 00       	mov    0x8ae8,%eax
 9db:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9de:	75 1e                	jne    9fe <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 9e0:	83 ec 0c             	sub    $0xc,%esp
 9e3:	ff 75 ec             	push   -0x14(%ebp)
 9e6:	e8 e5 fe ff ff       	call   8d0 <morecore>
 9eb:	83 c4 10             	add    $0x10,%esp
 9ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9f5:	75 07                	jne    9fe <malloc+0xce>
        return 0;
 9f7:	b8 00 00 00 00       	mov    $0x0,%eax
 9fc:	eb 13                	jmp    a11 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a01:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a07:	8b 00                	mov    (%eax),%eax
 a09:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a0c:	e9 6d ff ff ff       	jmp    97e <malloc+0x4e>
  }
}
 a11:	c9                   	leave
 a12:	c3                   	ret
