
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
  28:	e8 56 05 00 00       	call   583 <uthread_init>
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
  8d:	b8 10 4b 01 00       	mov    $0x14b10,%eax
  92:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  95:	72 b5                	jb     4c <thread_schedule+0x19>
    }
  }
  
  // printf(1,"next_thread %x ,state %x \n",next_thread, next_thread->state);
  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  97:	b8 10 4b 01 00       	mov    $0x14b10,%eax
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
  c7:	68 18 0a 00 00       	push   $0xa18
  cc:	6a 02                	push   $0x2
  ce:	e8 8c 05 00 00       	call   65f <printf>
  d3:	83 c4 10             	add    $0x10,%esp
    exit();
  d6:	e8 08 04 00 00       	call   4e3 <exit>
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
 117:	e8 50 01 00 00       	call   26c <thread_switch>
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
 134:	68 3e 0a 00 00       	push   $0xa3e
 139:	6a 01                	push   $0x1
 13b:	e8 1f 05 00 00       	call   65f <printf>
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
 160:	b8 10 4b 01 00       	mov    $0x14b10,%eax
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
 1be:	68 4d 0a 00 00       	push   $0xa4d
 1c3:	6a 01                	push   $0x1
 1c5:	e8 95 04 00 00       	call   65f <printf>
 1ca:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 10; i++) {
 1cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1d4:	eb 1c                	jmp    1f2 <mythread+0x3d>
    printf(1, "my thread 0x%x\n", (int) current_thread);
 1d6:	a1 a0 0a 00 00       	mov    0xaa0,%eax
 1db:	83 ec 04             	sub    $0x4,%esp
 1de:	50                   	push   %eax
 1df:	68 60 0a 00 00       	push   $0xa60
 1e4:	6a 01                	push   $0x1
 1e6:	e8 74 04 00 00       	call   65f <printf>
 1eb:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 10; i++) {
 1ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1f2:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
 1f6:	7e de                	jle    1d6 <mythread+0x21>
  }
  printf(1, "my thread: exit\n");
 1f8:	83 ec 08             	sub    $0x8,%esp
 1fb:	68 70 0a 00 00       	push   $0xa70
 200:	6a 01                	push   $0x1
 202:	e8 58 04 00 00       	call   65f <printf>
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
 22f:	83 ec 14             	sub    $0x14,%esp
  thread_init();
 232:	e8 c9 fd ff ff       	call   0 <thread_init>
  for (int i = 0; i < MAX_THREAD; i++) {
 237:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 23e:	eb 14                	jmp    254 <main+0x33>
    thread_create(mythread);
 240:	83 ec 0c             	sub    $0xc,%esp
 243:	68 b5 01 00 00       	push   $0x1b5
 248:	e8 de fe ff ff       	call   12b <thread_create>
 24d:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < MAX_THREAD; i++) {
 250:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 254:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
 258:	7e e6                	jle    240 <main+0x1f>
  }
  thread_schedule();
 25a:	e8 d4 fd ff ff       	call   33 <thread_schedule>
  return 0;
 25f:	b8 00 00 00 00       	mov    $0x0,%eax
 264:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 267:	c9                   	leave
 268:	8d 61 fc             	lea    -0x4(%ecx),%esp
 26b:	c3                   	ret

0000026c <thread_switch>:
         */
    .text
    .globl thread_switch
thread_switch:

    pushal
 26c:	60                   	pusha

    movl current_thread, %eax
 26d:	a1 a0 0a 00 00       	mov    0xaa0,%eax
    movl %esp, (%eax)
 272:	89 20                	mov    %esp,(%eax)

    movl next_thread, %eax
 274:	a1 a4 0a 00 00       	mov    0xaa4,%eax
    movl (%eax), %esp
 279:	8b 20                	mov    (%eax),%esp
    # esp = t1.주소

    movl %eax, current_thread
 27b:	a3 a0 0a 00 00       	mov    %eax,0xaa0

    // 레지스터 복구
    popal
 280:	61                   	popa

    movl $0, next_thread
 281:	c7 05 a4 0a 00 00 00 	movl   $0x0,0xaa4
 288:	00 00 00 
    
 28b:	c3                   	ret

0000028c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 28c:	55                   	push   %ebp
 28d:	89 e5                	mov    %esp,%ebp
 28f:	57                   	push   %edi
 290:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 291:	8b 4d 08             	mov    0x8(%ebp),%ecx
 294:	8b 55 10             	mov    0x10(%ebp),%edx
 297:	8b 45 0c             	mov    0xc(%ebp),%eax
 29a:	89 cb                	mov    %ecx,%ebx
 29c:	89 df                	mov    %ebx,%edi
 29e:	89 d1                	mov    %edx,%ecx
 2a0:	fc                   	cld
 2a1:	f3 aa                	rep stos %al,%es:(%edi)
 2a3:	89 ca                	mov    %ecx,%edx
 2a5:	89 fb                	mov    %edi,%ebx
 2a7:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2aa:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2ad:	90                   	nop
 2ae:	5b                   	pop    %ebx
 2af:	5f                   	pop    %edi
 2b0:	5d                   	pop    %ebp
 2b1:	c3                   	ret

000002b2 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2b2:	55                   	push   %ebp
 2b3:	89 e5                	mov    %esp,%ebp
 2b5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2b8:	8b 45 08             	mov    0x8(%ebp),%eax
 2bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2be:	90                   	nop
 2bf:	8b 55 0c             	mov    0xc(%ebp),%edx
 2c2:	8d 42 01             	lea    0x1(%edx),%eax
 2c5:	89 45 0c             	mov    %eax,0xc(%ebp)
 2c8:	8b 45 08             	mov    0x8(%ebp),%eax
 2cb:	8d 48 01             	lea    0x1(%eax),%ecx
 2ce:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2d1:	0f b6 12             	movzbl (%edx),%edx
 2d4:	88 10                	mov    %dl,(%eax)
 2d6:	0f b6 00             	movzbl (%eax),%eax
 2d9:	84 c0                	test   %al,%al
 2db:	75 e2                	jne    2bf <strcpy+0xd>
    ;
  return os;
 2dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2e0:	c9                   	leave
 2e1:	c3                   	ret

000002e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2e2:	55                   	push   %ebp
 2e3:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2e5:	eb 08                	jmp    2ef <strcmp+0xd>
    p++, q++;
 2e7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2eb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 2ef:	8b 45 08             	mov    0x8(%ebp),%eax
 2f2:	0f b6 00             	movzbl (%eax),%eax
 2f5:	84 c0                	test   %al,%al
 2f7:	74 10                	je     309 <strcmp+0x27>
 2f9:	8b 45 08             	mov    0x8(%ebp),%eax
 2fc:	0f b6 10             	movzbl (%eax),%edx
 2ff:	8b 45 0c             	mov    0xc(%ebp),%eax
 302:	0f b6 00             	movzbl (%eax),%eax
 305:	38 c2                	cmp    %al,%dl
 307:	74 de                	je     2e7 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 309:	8b 45 08             	mov    0x8(%ebp),%eax
 30c:	0f b6 00             	movzbl (%eax),%eax
 30f:	0f b6 d0             	movzbl %al,%edx
 312:	8b 45 0c             	mov    0xc(%ebp),%eax
 315:	0f b6 00             	movzbl (%eax),%eax
 318:	0f b6 c0             	movzbl %al,%eax
 31b:	29 c2                	sub    %eax,%edx
 31d:	89 d0                	mov    %edx,%eax
}
 31f:	5d                   	pop    %ebp
 320:	c3                   	ret

00000321 <strlen>:

uint
strlen(char *s)
{
 321:	55                   	push   %ebp
 322:	89 e5                	mov    %esp,%ebp
 324:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 327:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 32e:	eb 04                	jmp    334 <strlen+0x13>
 330:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 334:	8b 55 fc             	mov    -0x4(%ebp),%edx
 337:	8b 45 08             	mov    0x8(%ebp),%eax
 33a:	01 d0                	add    %edx,%eax
 33c:	0f b6 00             	movzbl (%eax),%eax
 33f:	84 c0                	test   %al,%al
 341:	75 ed                	jne    330 <strlen+0xf>
    ;
  return n;
 343:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 346:	c9                   	leave
 347:	c3                   	ret

00000348 <memset>:

void*
memset(void *dst, int c, uint n)
{
 348:	55                   	push   %ebp
 349:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 34b:	8b 45 10             	mov    0x10(%ebp),%eax
 34e:	50                   	push   %eax
 34f:	ff 75 0c             	push   0xc(%ebp)
 352:	ff 75 08             	push   0x8(%ebp)
 355:	e8 32 ff ff ff       	call   28c <stosb>
 35a:	83 c4 0c             	add    $0xc,%esp
  return dst;
 35d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 360:	c9                   	leave
 361:	c3                   	ret

00000362 <strchr>:

char*
strchr(const char *s, char c)
{
 362:	55                   	push   %ebp
 363:	89 e5                	mov    %esp,%ebp
 365:	83 ec 04             	sub    $0x4,%esp
 368:	8b 45 0c             	mov    0xc(%ebp),%eax
 36b:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 36e:	eb 14                	jmp    384 <strchr+0x22>
    if(*s == c)
 370:	8b 45 08             	mov    0x8(%ebp),%eax
 373:	0f b6 00             	movzbl (%eax),%eax
 376:	38 45 fc             	cmp    %al,-0x4(%ebp)
 379:	75 05                	jne    380 <strchr+0x1e>
      return (char*)s;
 37b:	8b 45 08             	mov    0x8(%ebp),%eax
 37e:	eb 13                	jmp    393 <strchr+0x31>
  for(; *s; s++)
 380:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 384:	8b 45 08             	mov    0x8(%ebp),%eax
 387:	0f b6 00             	movzbl (%eax),%eax
 38a:	84 c0                	test   %al,%al
 38c:	75 e2                	jne    370 <strchr+0xe>
  return 0;
 38e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 393:	c9                   	leave
 394:	c3                   	ret

00000395 <gets>:

char*
gets(char *buf, int max)
{
 395:	55                   	push   %ebp
 396:	89 e5                	mov    %esp,%ebp
 398:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 39b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3a2:	eb 42                	jmp    3e6 <gets+0x51>
    cc = read(0, &c, 1);
 3a4:	83 ec 04             	sub    $0x4,%esp
 3a7:	6a 01                	push   $0x1
 3a9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3ac:	50                   	push   %eax
 3ad:	6a 00                	push   $0x0
 3af:	e8 47 01 00 00       	call   4fb <read>
 3b4:	83 c4 10             	add    $0x10,%esp
 3b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3be:	7e 33                	jle    3f3 <gets+0x5e>
      break;
    buf[i++] = c;
 3c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3c3:	8d 50 01             	lea    0x1(%eax),%edx
 3c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3c9:	89 c2                	mov    %eax,%edx
 3cb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ce:	01 c2                	add    %eax,%edx
 3d0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3d4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3d6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3da:	3c 0a                	cmp    $0xa,%al
 3dc:	74 16                	je     3f4 <gets+0x5f>
 3de:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3e2:	3c 0d                	cmp    $0xd,%al
 3e4:	74 0e                	je     3f4 <gets+0x5f>
  for(i=0; i+1 < max; ){
 3e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3e9:	83 c0 01             	add    $0x1,%eax
 3ec:	39 45 0c             	cmp    %eax,0xc(%ebp)
 3ef:	7f b3                	jg     3a4 <gets+0xf>
 3f1:	eb 01                	jmp    3f4 <gets+0x5f>
      break;
 3f3:	90                   	nop
      break;
  }
  buf[i] = '\0';
 3f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3f7:	8b 45 08             	mov    0x8(%ebp),%eax
 3fa:	01 d0                	add    %edx,%eax
 3fc:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3ff:	8b 45 08             	mov    0x8(%ebp),%eax
}
 402:	c9                   	leave
 403:	c3                   	ret

00000404 <stat>:

int
stat(char *n, struct stat *st)
{
 404:	55                   	push   %ebp
 405:	89 e5                	mov    %esp,%ebp
 407:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 40a:	83 ec 08             	sub    $0x8,%esp
 40d:	6a 00                	push   $0x0
 40f:	ff 75 08             	push   0x8(%ebp)
 412:	e8 0c 01 00 00       	call   523 <open>
 417:	83 c4 10             	add    $0x10,%esp
 41a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 41d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 421:	79 07                	jns    42a <stat+0x26>
    return -1;
 423:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 428:	eb 25                	jmp    44f <stat+0x4b>
  r = fstat(fd, st);
 42a:	83 ec 08             	sub    $0x8,%esp
 42d:	ff 75 0c             	push   0xc(%ebp)
 430:	ff 75 f4             	push   -0xc(%ebp)
 433:	e8 03 01 00 00       	call   53b <fstat>
 438:	83 c4 10             	add    $0x10,%esp
 43b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 43e:	83 ec 0c             	sub    $0xc,%esp
 441:	ff 75 f4             	push   -0xc(%ebp)
 444:	e8 c2 00 00 00       	call   50b <close>
 449:	83 c4 10             	add    $0x10,%esp
  return r;
 44c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 44f:	c9                   	leave
 450:	c3                   	ret

00000451 <atoi>:

int
atoi(const char *s)
{
 451:	55                   	push   %ebp
 452:	89 e5                	mov    %esp,%ebp
 454:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 457:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 45e:	eb 25                	jmp    485 <atoi+0x34>
    n = n*10 + *s++ - '0';
 460:	8b 55 fc             	mov    -0x4(%ebp),%edx
 463:	89 d0                	mov    %edx,%eax
 465:	c1 e0 02             	shl    $0x2,%eax
 468:	01 d0                	add    %edx,%eax
 46a:	01 c0                	add    %eax,%eax
 46c:	89 c1                	mov    %eax,%ecx
 46e:	8b 45 08             	mov    0x8(%ebp),%eax
 471:	8d 50 01             	lea    0x1(%eax),%edx
 474:	89 55 08             	mov    %edx,0x8(%ebp)
 477:	0f b6 00             	movzbl (%eax),%eax
 47a:	0f be c0             	movsbl %al,%eax
 47d:	01 c8                	add    %ecx,%eax
 47f:	83 e8 30             	sub    $0x30,%eax
 482:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 485:	8b 45 08             	mov    0x8(%ebp),%eax
 488:	0f b6 00             	movzbl (%eax),%eax
 48b:	3c 2f                	cmp    $0x2f,%al
 48d:	7e 0a                	jle    499 <atoi+0x48>
 48f:	8b 45 08             	mov    0x8(%ebp),%eax
 492:	0f b6 00             	movzbl (%eax),%eax
 495:	3c 39                	cmp    $0x39,%al
 497:	7e c7                	jle    460 <atoi+0xf>
  return n;
 499:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 49c:	c9                   	leave
 49d:	c3                   	ret

0000049e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 49e:	55                   	push   %ebp
 49f:	89 e5                	mov    %esp,%ebp
 4a1:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 4a4:	8b 45 08             	mov    0x8(%ebp),%eax
 4a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ad:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4b0:	eb 17                	jmp    4c9 <memmove+0x2b>
    *dst++ = *src++;
 4b2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4b5:	8d 42 01             	lea    0x1(%edx),%eax
 4b8:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4be:	8d 48 01             	lea    0x1(%eax),%ecx
 4c1:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4c4:	0f b6 12             	movzbl (%edx),%edx
 4c7:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4c9:	8b 45 10             	mov    0x10(%ebp),%eax
 4cc:	8d 50 ff             	lea    -0x1(%eax),%edx
 4cf:	89 55 10             	mov    %edx,0x10(%ebp)
 4d2:	85 c0                	test   %eax,%eax
 4d4:	7f dc                	jg     4b2 <memmove+0x14>
  return vdst;
 4d6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4d9:	c9                   	leave
 4da:	c3                   	ret

000004db <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4db:	b8 01 00 00 00       	mov    $0x1,%eax
 4e0:	cd 40                	int    $0x40
 4e2:	c3                   	ret

000004e3 <exit>:
SYSCALL(exit)
 4e3:	b8 02 00 00 00       	mov    $0x2,%eax
 4e8:	cd 40                	int    $0x40
 4ea:	c3                   	ret

000004eb <wait>:
SYSCALL(wait)
 4eb:	b8 03 00 00 00       	mov    $0x3,%eax
 4f0:	cd 40                	int    $0x40
 4f2:	c3                   	ret

000004f3 <pipe>:
SYSCALL(pipe)
 4f3:	b8 04 00 00 00       	mov    $0x4,%eax
 4f8:	cd 40                	int    $0x40
 4fa:	c3                   	ret

000004fb <read>:
SYSCALL(read)
 4fb:	b8 05 00 00 00       	mov    $0x5,%eax
 500:	cd 40                	int    $0x40
 502:	c3                   	ret

00000503 <write>:
SYSCALL(write)
 503:	b8 10 00 00 00       	mov    $0x10,%eax
 508:	cd 40                	int    $0x40
 50a:	c3                   	ret

0000050b <close>:
SYSCALL(close)
 50b:	b8 15 00 00 00       	mov    $0x15,%eax
 510:	cd 40                	int    $0x40
 512:	c3                   	ret

00000513 <kill>:
SYSCALL(kill)
 513:	b8 06 00 00 00       	mov    $0x6,%eax
 518:	cd 40                	int    $0x40
 51a:	c3                   	ret

0000051b <exec>:
SYSCALL(exec)
 51b:	b8 07 00 00 00       	mov    $0x7,%eax
 520:	cd 40                	int    $0x40
 522:	c3                   	ret

00000523 <open>:
SYSCALL(open)
 523:	b8 0f 00 00 00       	mov    $0xf,%eax
 528:	cd 40                	int    $0x40
 52a:	c3                   	ret

0000052b <mknod>:
SYSCALL(mknod)
 52b:	b8 11 00 00 00       	mov    $0x11,%eax
 530:	cd 40                	int    $0x40
 532:	c3                   	ret

00000533 <unlink>:
SYSCALL(unlink)
 533:	b8 12 00 00 00       	mov    $0x12,%eax
 538:	cd 40                	int    $0x40
 53a:	c3                   	ret

0000053b <fstat>:
SYSCALL(fstat)
 53b:	b8 08 00 00 00       	mov    $0x8,%eax
 540:	cd 40                	int    $0x40
 542:	c3                   	ret

00000543 <link>:
SYSCALL(link)
 543:	b8 13 00 00 00       	mov    $0x13,%eax
 548:	cd 40                	int    $0x40
 54a:	c3                   	ret

0000054b <mkdir>:
SYSCALL(mkdir)
 54b:	b8 14 00 00 00       	mov    $0x14,%eax
 550:	cd 40                	int    $0x40
 552:	c3                   	ret

00000553 <chdir>:
SYSCALL(chdir)
 553:	b8 09 00 00 00       	mov    $0x9,%eax
 558:	cd 40                	int    $0x40
 55a:	c3                   	ret

0000055b <dup>:
SYSCALL(dup)
 55b:	b8 0a 00 00 00       	mov    $0xa,%eax
 560:	cd 40                	int    $0x40
 562:	c3                   	ret

00000563 <getpid>:
SYSCALL(getpid)
 563:	b8 0b 00 00 00       	mov    $0xb,%eax
 568:	cd 40                	int    $0x40
 56a:	c3                   	ret

0000056b <sbrk>:
SYSCALL(sbrk)
 56b:	b8 0c 00 00 00       	mov    $0xc,%eax
 570:	cd 40                	int    $0x40
 572:	c3                   	ret

00000573 <sleep>:
SYSCALL(sleep)
 573:	b8 0d 00 00 00       	mov    $0xd,%eax
 578:	cd 40                	int    $0x40
 57a:	c3                   	ret

0000057b <uptime>:
SYSCALL(uptime)
 57b:	b8 0e 00 00 00       	mov    $0xe,%eax
 580:	cd 40                	int    $0x40
 582:	c3                   	ret

00000583 <uthread_init>:
SYSCALL(uthread_init)
 583:	b8 16 00 00 00       	mov    $0x16,%eax
 588:	cd 40                	int    $0x40
 58a:	c3                   	ret

0000058b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 58b:	55                   	push   %ebp
 58c:	89 e5                	mov    %esp,%ebp
 58e:	83 ec 18             	sub    $0x18,%esp
 591:	8b 45 0c             	mov    0xc(%ebp),%eax
 594:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 597:	83 ec 04             	sub    $0x4,%esp
 59a:	6a 01                	push   $0x1
 59c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 59f:	50                   	push   %eax
 5a0:	ff 75 08             	push   0x8(%ebp)
 5a3:	e8 5b ff ff ff       	call   503 <write>
 5a8:	83 c4 10             	add    $0x10,%esp
}
 5ab:	90                   	nop
 5ac:	c9                   	leave
 5ad:	c3                   	ret

000005ae <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5ae:	55                   	push   %ebp
 5af:	89 e5                	mov    %esp,%ebp
 5b1:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5b4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5bb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5bf:	74 17                	je     5d8 <printint+0x2a>
 5c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5c5:	79 11                	jns    5d8 <printint+0x2a>
    neg = 1;
 5c7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d1:	f7 d8                	neg    %eax
 5d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5d6:	eb 06                	jmp    5de <printint+0x30>
  } else {
    x = xx;
 5d8:	8b 45 0c             	mov    0xc(%ebp),%eax
 5db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5eb:	ba 00 00 00 00       	mov    $0x0,%edx
 5f0:	f7 f1                	div    %ecx
 5f2:	89 d1                	mov    %edx,%ecx
 5f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f7:	8d 50 01             	lea    0x1(%eax),%edx
 5fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5fd:	0f b6 91 88 0a 00 00 	movzbl 0xa88(%ecx),%edx
 604:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 608:	8b 4d 10             	mov    0x10(%ebp),%ecx
 60b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 60e:	ba 00 00 00 00       	mov    $0x0,%edx
 613:	f7 f1                	div    %ecx
 615:	89 45 ec             	mov    %eax,-0x14(%ebp)
 618:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 61c:	75 c7                	jne    5e5 <printint+0x37>
  if(neg)
 61e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 622:	74 2d                	je     651 <printint+0xa3>
    buf[i++] = '-';
 624:	8b 45 f4             	mov    -0xc(%ebp),%eax
 627:	8d 50 01             	lea    0x1(%eax),%edx
 62a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 62d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 632:	eb 1d                	jmp    651 <printint+0xa3>
    putc(fd, buf[i]);
 634:	8d 55 dc             	lea    -0x24(%ebp),%edx
 637:	8b 45 f4             	mov    -0xc(%ebp),%eax
 63a:	01 d0                	add    %edx,%eax
 63c:	0f b6 00             	movzbl (%eax),%eax
 63f:	0f be c0             	movsbl %al,%eax
 642:	83 ec 08             	sub    $0x8,%esp
 645:	50                   	push   %eax
 646:	ff 75 08             	push   0x8(%ebp)
 649:	e8 3d ff ff ff       	call   58b <putc>
 64e:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 651:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 655:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 659:	79 d9                	jns    634 <printint+0x86>
}
 65b:	90                   	nop
 65c:	90                   	nop
 65d:	c9                   	leave
 65e:	c3                   	ret

0000065f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 65f:	55                   	push   %ebp
 660:	89 e5                	mov    %esp,%ebp
 662:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 665:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 66c:	8d 45 0c             	lea    0xc(%ebp),%eax
 66f:	83 c0 04             	add    $0x4,%eax
 672:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 675:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 67c:	e9 59 01 00 00       	jmp    7da <printf+0x17b>
    c = fmt[i] & 0xff;
 681:	8b 55 0c             	mov    0xc(%ebp),%edx
 684:	8b 45 f0             	mov    -0x10(%ebp),%eax
 687:	01 d0                	add    %edx,%eax
 689:	0f b6 00             	movzbl (%eax),%eax
 68c:	0f be c0             	movsbl %al,%eax
 68f:	25 ff 00 00 00       	and    $0xff,%eax
 694:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 697:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 69b:	75 2c                	jne    6c9 <printf+0x6a>
      if(c == '%'){
 69d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6a1:	75 0c                	jne    6af <printf+0x50>
        state = '%';
 6a3:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6aa:	e9 27 01 00 00       	jmp    7d6 <printf+0x177>
      } else {
        putc(fd, c);
 6af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6b2:	0f be c0             	movsbl %al,%eax
 6b5:	83 ec 08             	sub    $0x8,%esp
 6b8:	50                   	push   %eax
 6b9:	ff 75 08             	push   0x8(%ebp)
 6bc:	e8 ca fe ff ff       	call   58b <putc>
 6c1:	83 c4 10             	add    $0x10,%esp
 6c4:	e9 0d 01 00 00       	jmp    7d6 <printf+0x177>
      }
    } else if(state == '%'){
 6c9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6cd:	0f 85 03 01 00 00    	jne    7d6 <printf+0x177>
      if(c == 'd'){
 6d3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6d7:	75 1e                	jne    6f7 <printf+0x98>
        printint(fd, *ap, 10, 1);
 6d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6dc:	8b 00                	mov    (%eax),%eax
 6de:	6a 01                	push   $0x1
 6e0:	6a 0a                	push   $0xa
 6e2:	50                   	push   %eax
 6e3:	ff 75 08             	push   0x8(%ebp)
 6e6:	e8 c3 fe ff ff       	call   5ae <printint>
 6eb:	83 c4 10             	add    $0x10,%esp
        ap++;
 6ee:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6f2:	e9 d8 00 00 00       	jmp    7cf <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6f7:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6fb:	74 06                	je     703 <printf+0xa4>
 6fd:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 701:	75 1e                	jne    721 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 703:	8b 45 e8             	mov    -0x18(%ebp),%eax
 706:	8b 00                	mov    (%eax),%eax
 708:	6a 00                	push   $0x0
 70a:	6a 10                	push   $0x10
 70c:	50                   	push   %eax
 70d:	ff 75 08             	push   0x8(%ebp)
 710:	e8 99 fe ff ff       	call   5ae <printint>
 715:	83 c4 10             	add    $0x10,%esp
        ap++;
 718:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 71c:	e9 ae 00 00 00       	jmp    7cf <printf+0x170>
      } else if(c == 's'){
 721:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 725:	75 43                	jne    76a <printf+0x10b>
        s = (char*)*ap;
 727:	8b 45 e8             	mov    -0x18(%ebp),%eax
 72a:	8b 00                	mov    (%eax),%eax
 72c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 72f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 733:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 737:	75 25                	jne    75e <printf+0xff>
          s = "(null)";
 739:	c7 45 f4 81 0a 00 00 	movl   $0xa81,-0xc(%ebp)
        while(*s != 0){
 740:	eb 1c                	jmp    75e <printf+0xff>
          putc(fd, *s);
 742:	8b 45 f4             	mov    -0xc(%ebp),%eax
 745:	0f b6 00             	movzbl (%eax),%eax
 748:	0f be c0             	movsbl %al,%eax
 74b:	83 ec 08             	sub    $0x8,%esp
 74e:	50                   	push   %eax
 74f:	ff 75 08             	push   0x8(%ebp)
 752:	e8 34 fe ff ff       	call   58b <putc>
 757:	83 c4 10             	add    $0x10,%esp
          s++;
 75a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 75e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 761:	0f b6 00             	movzbl (%eax),%eax
 764:	84 c0                	test   %al,%al
 766:	75 da                	jne    742 <printf+0xe3>
 768:	eb 65                	jmp    7cf <printf+0x170>
        }
      } else if(c == 'c'){
 76a:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 76e:	75 1d                	jne    78d <printf+0x12e>
        putc(fd, *ap);
 770:	8b 45 e8             	mov    -0x18(%ebp),%eax
 773:	8b 00                	mov    (%eax),%eax
 775:	0f be c0             	movsbl %al,%eax
 778:	83 ec 08             	sub    $0x8,%esp
 77b:	50                   	push   %eax
 77c:	ff 75 08             	push   0x8(%ebp)
 77f:	e8 07 fe ff ff       	call   58b <putc>
 784:	83 c4 10             	add    $0x10,%esp
        ap++;
 787:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 78b:	eb 42                	jmp    7cf <printf+0x170>
      } else if(c == '%'){
 78d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 791:	75 17                	jne    7aa <printf+0x14b>
        putc(fd, c);
 793:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 796:	0f be c0             	movsbl %al,%eax
 799:	83 ec 08             	sub    $0x8,%esp
 79c:	50                   	push   %eax
 79d:	ff 75 08             	push   0x8(%ebp)
 7a0:	e8 e6 fd ff ff       	call   58b <putc>
 7a5:	83 c4 10             	add    $0x10,%esp
 7a8:	eb 25                	jmp    7cf <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7aa:	83 ec 08             	sub    $0x8,%esp
 7ad:	6a 25                	push   $0x25
 7af:	ff 75 08             	push   0x8(%ebp)
 7b2:	e8 d4 fd ff ff       	call   58b <putc>
 7b7:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7bd:	0f be c0             	movsbl %al,%eax
 7c0:	83 ec 08             	sub    $0x8,%esp
 7c3:	50                   	push   %eax
 7c4:	ff 75 08             	push   0x8(%ebp)
 7c7:	e8 bf fd ff ff       	call   58b <putc>
 7cc:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7cf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 7d6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7da:	8b 55 0c             	mov    0xc(%ebp),%edx
 7dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e0:	01 d0                	add    %edx,%eax
 7e2:	0f b6 00             	movzbl (%eax),%eax
 7e5:	84 c0                	test   %al,%al
 7e7:	0f 85 94 fe ff ff    	jne    681 <printf+0x22>
    }
  }
}
 7ed:	90                   	nop
 7ee:	90                   	nop
 7ef:	c9                   	leave
 7f0:	c3                   	ret

000007f1 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f1:	55                   	push   %ebp
 7f2:	89 e5                	mov    %esp,%ebp
 7f4:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f7:	8b 45 08             	mov    0x8(%ebp),%eax
 7fa:	83 e8 08             	sub    $0x8,%eax
 7fd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 800:	a1 18 4b 01 00       	mov    0x14b18,%eax
 805:	89 45 fc             	mov    %eax,-0x4(%ebp)
 808:	eb 24                	jmp    82e <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80d:	8b 00                	mov    (%eax),%eax
 80f:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 812:	72 12                	jb     826 <free+0x35>
 814:	8b 45 f8             	mov    -0x8(%ebp),%eax
 817:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 81a:	72 24                	jb     840 <free+0x4f>
 81c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81f:	8b 00                	mov    (%eax),%eax
 821:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 824:	72 1a                	jb     840 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 826:	8b 45 fc             	mov    -0x4(%ebp),%eax
 829:	8b 00                	mov    (%eax),%eax
 82b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 82e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 831:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 834:	73 d4                	jae    80a <free+0x19>
 836:	8b 45 fc             	mov    -0x4(%ebp),%eax
 839:	8b 00                	mov    (%eax),%eax
 83b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 83e:	73 ca                	jae    80a <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 840:	8b 45 f8             	mov    -0x8(%ebp),%eax
 843:	8b 40 04             	mov    0x4(%eax),%eax
 846:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 84d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 850:	01 c2                	add    %eax,%edx
 852:	8b 45 fc             	mov    -0x4(%ebp),%eax
 855:	8b 00                	mov    (%eax),%eax
 857:	39 c2                	cmp    %eax,%edx
 859:	75 24                	jne    87f <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 85b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 85e:	8b 50 04             	mov    0x4(%eax),%edx
 861:	8b 45 fc             	mov    -0x4(%ebp),%eax
 864:	8b 00                	mov    (%eax),%eax
 866:	8b 40 04             	mov    0x4(%eax),%eax
 869:	01 c2                	add    %eax,%edx
 86b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 86e:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 871:	8b 45 fc             	mov    -0x4(%ebp),%eax
 874:	8b 00                	mov    (%eax),%eax
 876:	8b 10                	mov    (%eax),%edx
 878:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87b:	89 10                	mov    %edx,(%eax)
 87d:	eb 0a                	jmp    889 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 87f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 882:	8b 10                	mov    (%eax),%edx
 884:	8b 45 f8             	mov    -0x8(%ebp),%eax
 887:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 889:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88c:	8b 40 04             	mov    0x4(%eax),%eax
 88f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 896:	8b 45 fc             	mov    -0x4(%ebp),%eax
 899:	01 d0                	add    %edx,%eax
 89b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 89e:	75 20                	jne    8c0 <free+0xcf>
    p->s.size += bp->s.size;
 8a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a3:	8b 50 04             	mov    0x4(%eax),%edx
 8a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a9:	8b 40 04             	mov    0x4(%eax),%eax
 8ac:	01 c2                	add    %eax,%edx
 8ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b7:	8b 10                	mov    (%eax),%edx
 8b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bc:	89 10                	mov    %edx,(%eax)
 8be:	eb 08                	jmp    8c8 <free+0xd7>
  } else
    p->s.ptr = bp;
 8c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8c6:	89 10                	mov    %edx,(%eax)
  freep = p;
 8c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cb:	a3 18 4b 01 00       	mov    %eax,0x14b18
}
 8d0:	90                   	nop
 8d1:	c9                   	leave
 8d2:	c3                   	ret

000008d3 <morecore>:

static Header*
morecore(uint nu)
{
 8d3:	55                   	push   %ebp
 8d4:	89 e5                	mov    %esp,%ebp
 8d6:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8d9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8e0:	77 07                	ja     8e9 <morecore+0x16>
    nu = 4096;
 8e2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8e9:	8b 45 08             	mov    0x8(%ebp),%eax
 8ec:	c1 e0 03             	shl    $0x3,%eax
 8ef:	83 ec 0c             	sub    $0xc,%esp
 8f2:	50                   	push   %eax
 8f3:	e8 73 fc ff ff       	call   56b <sbrk>
 8f8:	83 c4 10             	add    $0x10,%esp
 8fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8fe:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 902:	75 07                	jne    90b <morecore+0x38>
    return 0;
 904:	b8 00 00 00 00       	mov    $0x0,%eax
 909:	eb 26                	jmp    931 <morecore+0x5e>
  hp = (Header*)p;
 90b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 911:	8b 45 f0             	mov    -0x10(%ebp),%eax
 914:	8b 55 08             	mov    0x8(%ebp),%edx
 917:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 91a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91d:	83 c0 08             	add    $0x8,%eax
 920:	83 ec 0c             	sub    $0xc,%esp
 923:	50                   	push   %eax
 924:	e8 c8 fe ff ff       	call   7f1 <free>
 929:	83 c4 10             	add    $0x10,%esp
  return freep;
 92c:	a1 18 4b 01 00       	mov    0x14b18,%eax
}
 931:	c9                   	leave
 932:	c3                   	ret

00000933 <malloc>:

void*
malloc(uint nbytes)
{
 933:	55                   	push   %ebp
 934:	89 e5                	mov    %esp,%ebp
 936:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 939:	8b 45 08             	mov    0x8(%ebp),%eax
 93c:	83 c0 07             	add    $0x7,%eax
 93f:	c1 e8 03             	shr    $0x3,%eax
 942:	83 c0 01             	add    $0x1,%eax
 945:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 948:	a1 18 4b 01 00       	mov    0x14b18,%eax
 94d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 950:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 954:	75 23                	jne    979 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 956:	c7 45 f0 10 4b 01 00 	movl   $0x14b10,-0x10(%ebp)
 95d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 960:	a3 18 4b 01 00       	mov    %eax,0x14b18
 965:	a1 18 4b 01 00       	mov    0x14b18,%eax
 96a:	a3 10 4b 01 00       	mov    %eax,0x14b10
    base.s.size = 0;
 96f:	c7 05 14 4b 01 00 00 	movl   $0x0,0x14b14
 976:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 979:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97c:	8b 00                	mov    (%eax),%eax
 97e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 981:	8b 45 f4             	mov    -0xc(%ebp),%eax
 984:	8b 40 04             	mov    0x4(%eax),%eax
 987:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 98a:	72 4d                	jb     9d9 <malloc+0xa6>
      if(p->s.size == nunits)
 98c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98f:	8b 40 04             	mov    0x4(%eax),%eax
 992:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 995:	75 0c                	jne    9a3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 997:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99a:	8b 10                	mov    (%eax),%edx
 99c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99f:	89 10                	mov    %edx,(%eax)
 9a1:	eb 26                	jmp    9c9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a6:	8b 40 04             	mov    0x4(%eax),%eax
 9a9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9ac:	89 c2                	mov    %eax,%edx
 9ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b7:	8b 40 04             	mov    0x4(%eax),%eax
 9ba:	c1 e0 03             	shl    $0x3,%eax
 9bd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9c6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9cc:	a3 18 4b 01 00       	mov    %eax,0x14b18
      return (void*)(p + 1);
 9d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d4:	83 c0 08             	add    $0x8,%eax
 9d7:	eb 3b                	jmp    a14 <malloc+0xe1>
    }
    if(p == freep)
 9d9:	a1 18 4b 01 00       	mov    0x14b18,%eax
 9de:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9e1:	75 1e                	jne    a01 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 9e3:	83 ec 0c             	sub    $0xc,%esp
 9e6:	ff 75 ec             	push   -0x14(%ebp)
 9e9:	e8 e5 fe ff ff       	call   8d3 <morecore>
 9ee:	83 c4 10             	add    $0x10,%esp
 9f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9f8:	75 07                	jne    a01 <malloc+0xce>
        return 0;
 9fa:	b8 00 00 00 00       	mov    $0x0,%eax
 9ff:	eb 13                	jmp    a14 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a04:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0a:	8b 00                	mov    (%eax),%eax
 a0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a0f:	e9 6d ff ff ff       	jmp    981 <malloc+0x4e>
  }
}
 a14:	c9                   	leave
 a15:	c3                   	ret
