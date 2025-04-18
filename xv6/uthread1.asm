
_uthread1:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_init>:

static void thread_schedule(void);

void 
thread_init(void)
{
   0:	f3 0f 1e fb          	endbr32
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 ec 08             	sub    $0x8,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
   a:	c7 05 4c 8e 00 00 20 	movl   $0xe20,0x8e4c
  11:	0e 00 00 
  current_thread->state = RUNNING;
  14:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
  19:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  20:	00 00 00 
  uthread_init((int)thread_schedule);
  23:	b8 37 00 00 00       	mov    $0x37,%eax
  28:	83 ec 0c             	sub    $0xc,%esp
  2b:	50                   	push   %eax
  2c:	e8 c4 05 00 00       	call   5f5 <uthread_init>
  31:	83 c4 10             	add    $0x10,%esp
}
  34:	90                   	nop
  35:	c9                   	leave
  36:	c3                   	ret

00000037 <thread_schedule>:

static void
thread_schedule(void)
{ 
  37:	f3 0f 1e fb          	endbr32
  3b:	55                   	push   %ebp
  3c:	89 e5                	mov    %esp,%ebp
  3e:	83 ec 18             	sub    $0x18,%esp
  thread_p t;
  /* Find another runnable thread. */
  next_thread = 0;
  41:	c7 05 50 8e 00 00 00 	movl   $0x0,0x8e50
  48:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  4b:	c7 45 f4 20 0e 00 00 	movl   $0xe20,-0xc(%ebp)
  52:	eb 5d                	jmp    b1 <thread_schedule+0x7a>
    printf(1,"t: %x, state %x \n", t, t->state);
  54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  57:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  5d:	50                   	push   %eax
  5e:	ff 75 f4             	push   -0xc(%ebp)
  61:	68 a0 0a 00 00       	push   $0xaa0
  66:	6a 01                	push   $0x1
  68:	e8 6c 06 00 00       	call   6d9 <printf>
  6d:	83 c4 10             	add    $0x10,%esp
    if(t == &all_thread[0] && t->state == RUNNABLE){
  70:	81 7d f4 20 0e 00 00 	cmpl   $0xe20,-0xc(%ebp)
  77:	75 0e                	jne    87 <thread_schedule+0x50>
  79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  7c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  82:	83 f8 02             	cmp    $0x2,%eax
  85:	74 22                	je     a9 <thread_schedule+0x72>
      continue;
    }
    if (t->state == RUNNABLE && t != current_thread) {
  87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8a:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  90:	83 f8 02             	cmp    $0x2,%eax
  93:	75 15                	jne    aa <thread_schedule+0x73>
  95:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
  9a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  9d:	74 0b                	je     aa <thread_schedule+0x73>
      next_thread = t;
  9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  a2:	a3 50 8e 00 00       	mov    %eax,0x8e50
      break;
  a7:	eb 12                	jmp    bb <thread_schedule+0x84>
      continue;
  a9:	90                   	nop
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  aa:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  b1:	b8 40 8e 00 00       	mov    $0x8e40,%eax
  b6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  b9:	72 99                	jb     54 <thread_schedule+0x1d>
    }
  }
  printf(1,"next_thread %x ,state %x \n",next_thread, next_thread->state);
  bb:	a1 50 8e 00 00       	mov    0x8e50,%eax
  c0:	8b 90 04 20 00 00    	mov    0x2004(%eax),%edx
  c6:	a1 50 8e 00 00       	mov    0x8e50,%eax
  cb:	52                   	push   %edx
  cc:	50                   	push   %eax
  cd:	68 b2 0a 00 00       	push   $0xab2
  d2:	6a 01                	push   $0x1
  d4:	e8 00 06 00 00       	call   6d9 <printf>
  d9:	83 c4 10             	add    $0x10,%esp
  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  dc:	b8 40 8e 00 00       	mov    $0x8e40,%eax
  e1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  e4:	72 1a                	jb     100 <thread_schedule+0xc9>
  e6:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
  eb:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  f1:	83 f8 02             	cmp    $0x2,%eax
  f4:	75 0a                	jne    100 <thread_schedule+0xc9>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  f6:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
  fb:	a3 50 8e 00 00       	mov    %eax,0x8e50
  }

  if (next_thread == 0) {
 100:	a1 50 8e 00 00       	mov    0x8e50,%eax
 105:	85 c0                	test   %eax,%eax
 107:	75 17                	jne    120 <thread_schedule+0xe9>
    printf(2, "thread_schedule: no runnable threads\n");
 109:	83 ec 08             	sub    $0x8,%esp
 10c:	68 d0 0a 00 00       	push   $0xad0
 111:	6a 02                	push   $0x2
 113:	e8 c1 05 00 00       	call   6d9 <printf>
 118:	83 c4 10             	add    $0x10,%esp
    exit();
 11b:	e8 35 04 00 00       	call   555 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
 120:	8b 15 4c 8e 00 00    	mov    0x8e4c,%edx
 126:	a1 50 8e 00 00       	mov    0x8e50,%eax
 12b:	39 c2                	cmp    %eax,%edx
 12d:	74 34                	je     163 <thread_schedule+0x12c>
    next_thread->state = RUNNING;
 12f:	a1 50 8e 00 00       	mov    0x8e50,%eax
 134:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 13b:	00 00 00 
    if (current_thread->state != FREE) current_thread->state = RUNNABLE;
 13e:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
 143:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 149:	85 c0                	test   %eax,%eax
 14b:	74 0f                	je     15c <thread_schedule+0x125>
 14d:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
 152:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 159:	00 00 00 
    thread_switch();
 15c:	e8 59 01 00 00       	call   2ba <thread_switch>
  } else
    next_thread = 0;
}
 161:	eb 0a                	jmp    16d <thread_schedule+0x136>
    next_thread = 0;
 163:	c7 05 50 8e 00 00 00 	movl   $0x0,0x8e50
 16a:	00 00 00 
}
 16d:	90                   	nop
 16e:	c9                   	leave
 16f:	c3                   	ret

00000170 <thread_create>:

void 
thread_create(void (*func)())
{
 170:	f3 0f 1e fb          	endbr32
 174:	55                   	push   %ebp
 175:	89 e5                	mov    %esp,%ebp
 177:	83 ec 18             	sub    $0x18,%esp
  printf(1,"thread_create\n");
 17a:	83 ec 08             	sub    $0x8,%esp
 17d:	68 f6 0a 00 00       	push   $0xaf6
 182:	6a 01                	push   $0x1
 184:	e8 50 05 00 00       	call   6d9 <printf>
 189:	83 c4 10             	add    $0x10,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 18c:	c7 45 f4 20 0e 00 00 	movl   $0xe20,-0xc(%ebp)
 193:	eb 14                	jmp    1a9 <thread_create+0x39>
    if (t->state == FREE) break;
 195:	8b 45 f4             	mov    -0xc(%ebp),%eax
 198:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 19e:	85 c0                	test   %eax,%eax
 1a0:	74 13                	je     1b5 <thread_create+0x45>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 1a2:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 1a9:	b8 40 8e 00 00       	mov    $0x8e40,%eax
 1ae:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 1b1:	72 e2                	jb     195 <thread_create+0x25>
 1b3:	eb 01                	jmp    1b6 <thread_create+0x46>
    if (t->state == FREE) break;
 1b5:	90                   	nop
  }
  // 스택 포인터 = 스택의 top f rame
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 1b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b9:	83 c0 04             	add    $0x4,%eax
 1bc:	05 00 20 00 00       	add    $0x2000,%eax
 1c1:	89 c2                	mov    %eax,%edx
 1c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c6:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                              // space for return address
 1c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cb:	8b 00                	mov    (%eax),%eax
 1cd:	8d 50 fc             	lea    -0x4(%eax),%edx
 1d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d3:	89 10                	mov    %edx,(%eax)
  * (int *) (t->sp) = (int)func;           // push return address on stack
 1d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d8:	8b 00                	mov    (%eax),%eax
 1da:	89 c2                	mov    %eax,%edx
 1dc:	8b 45 08             	mov    0x8(%ebp),%eax
 1df:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                             // space for registers that thread_switch expects
 1e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e4:	8b 00                	mov    (%eax),%eax
 1e6:	8d 50 e0             	lea    -0x20(%eax),%edx
 1e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ec:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 1ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f1:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1f8:	00 00 00 
}
 1fb:	90                   	nop
 1fc:	c9                   	leave
 1fd:	c3                   	ret

000001fe <mythread>:

static void 
mythread(void)
{
 1fe:	f3 0f 1e fb          	endbr32
 202:	55                   	push   %ebp
 203:	89 e5                	mov    %esp,%ebp
 205:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 208:	83 ec 08             	sub    $0x8,%esp
 20b:	68 05 0b 00 00       	push   $0xb05
 210:	6a 01                	push   $0x1
 212:	e8 c2 04 00 00       	call   6d9 <printf>
 217:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 21a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 221:	eb 1c                	jmp    23f <mythread+0x41>
    printf(1, "my thread 0x%x\n", (int) current_thread);
 223:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
 228:	83 ec 04             	sub    $0x4,%esp
 22b:	50                   	push   %eax
 22c:	68 18 0b 00 00       	push   $0xb18
 231:	6a 01                	push   $0x1
 233:	e8 a1 04 00 00       	call   6d9 <printf>
 238:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 23b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 23f:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 243:	7e de                	jle    223 <mythread+0x25>
  }
  printf(1, "my thread: exit\n");
 245:	83 ec 08             	sub    $0x8,%esp
 248:	68 28 0b 00 00       	push   $0xb28
 24d:	6a 01                	push   $0x1
 24f:	e8 85 04 00 00       	call   6d9 <printf>
 254:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 257:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
 25c:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 263:	00 00 00 
  thread_schedule();
 266:	e8 cc fd ff ff       	call   37 <thread_schedule>
}
 26b:	90                   	nop
 26c:	c9                   	leave
 26d:	c3                   	ret

0000026e <main>:


int 
main(int argc, char *argv[]) 
{
 26e:	f3 0f 1e fb          	endbr32
 272:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 276:	83 e4 f0             	and    $0xfffffff0,%esp
 279:	ff 71 fc             	push   -0x4(%ecx)
 27c:	55                   	push   %ebp
 27d:	89 e5                	mov    %esp,%ebp
 27f:	51                   	push   %ecx
 280:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 283:	e8 78 fd ff ff       	call   0 <thread_init>
  thread_create(mythread);
 288:	83 ec 0c             	sub    $0xc,%esp
 28b:	68 fe 01 00 00       	push   $0x1fe
 290:	e8 db fe ff ff       	call   170 <thread_create>
 295:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 298:	83 ec 0c             	sub    $0xc,%esp
 29b:	68 fe 01 00 00       	push   $0x1fe
 2a0:	e8 cb fe ff ff       	call   170 <thread_create>
 2a5:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 2a8:	e8 8a fd ff ff       	call   37 <thread_schedule>
  return 0;
 2ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2b2:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 2b5:	c9                   	leave
 2b6:	8d 61 fc             	lea    -0x4(%ecx),%esp
 2b9:	c3                   	ret

000002ba <thread_switch>:
         */
    .text
    .globl thread_switch
thread_switch:

    pushal
 2ba:	60                   	pusha

    movl current_thread, %eax
 2bb:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
    movl %esp, (%eax)
 2c0:	89 20                	mov    %esp,(%eax)

    movl next_thread, %eax
 2c2:	a1 50 8e 00 00       	mov    0x8e50,%eax
    movl (%eax), %esp
 2c7:	8b 20                	mov    (%eax),%esp
    # esp = t1.주소

    movl %eax, current_thread
 2c9:	a3 4c 8e 00 00       	mov    %eax,0x8e4c

    // 레지스터 복구
    popal
 2ce:	61                   	popa

    movl $0, next_thread
 2cf:	c7 05 50 8e 00 00 00 	movl   $0x0,0x8e50
 2d6:	00 00 00 
    
    ret   # 스택 상의 리턴 주소(=스레드 진입 지점)로 점프
 2d9:	c3                   	ret

000002da <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2da:	55                   	push   %ebp
 2db:	89 e5                	mov    %esp,%ebp
 2dd:	57                   	push   %edi
 2de:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2df:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2e2:	8b 55 10             	mov    0x10(%ebp),%edx
 2e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2e8:	89 cb                	mov    %ecx,%ebx
 2ea:	89 df                	mov    %ebx,%edi
 2ec:	89 d1                	mov    %edx,%ecx
 2ee:	fc                   	cld
 2ef:	f3 aa                	rep stos %al,%es:(%edi)
 2f1:	89 ca                	mov    %ecx,%edx
 2f3:	89 fb                	mov    %edi,%ebx
 2f5:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2f8:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2fb:	90                   	nop
 2fc:	5b                   	pop    %ebx
 2fd:	5f                   	pop    %edi
 2fe:	5d                   	pop    %ebp
 2ff:	c3                   	ret

00000300 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 300:	f3 0f 1e fb          	endbr32
 304:	55                   	push   %ebp
 305:	89 e5                	mov    %esp,%ebp
 307:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 30a:	8b 45 08             	mov    0x8(%ebp),%eax
 30d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 310:	90                   	nop
 311:	8b 55 0c             	mov    0xc(%ebp),%edx
 314:	8d 42 01             	lea    0x1(%edx),%eax
 317:	89 45 0c             	mov    %eax,0xc(%ebp)
 31a:	8b 45 08             	mov    0x8(%ebp),%eax
 31d:	8d 48 01             	lea    0x1(%eax),%ecx
 320:	89 4d 08             	mov    %ecx,0x8(%ebp)
 323:	0f b6 12             	movzbl (%edx),%edx
 326:	88 10                	mov    %dl,(%eax)
 328:	0f b6 00             	movzbl (%eax),%eax
 32b:	84 c0                	test   %al,%al
 32d:	75 e2                	jne    311 <strcpy+0x11>
    ;
  return os;
 32f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 332:	c9                   	leave
 333:	c3                   	ret

00000334 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 334:	f3 0f 1e fb          	endbr32
 338:	55                   	push   %ebp
 339:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 33b:	eb 08                	jmp    345 <strcmp+0x11>
    p++, q++;
 33d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 341:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 345:	8b 45 08             	mov    0x8(%ebp),%eax
 348:	0f b6 00             	movzbl (%eax),%eax
 34b:	84 c0                	test   %al,%al
 34d:	74 10                	je     35f <strcmp+0x2b>
 34f:	8b 45 08             	mov    0x8(%ebp),%eax
 352:	0f b6 10             	movzbl (%eax),%edx
 355:	8b 45 0c             	mov    0xc(%ebp),%eax
 358:	0f b6 00             	movzbl (%eax),%eax
 35b:	38 c2                	cmp    %al,%dl
 35d:	74 de                	je     33d <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 35f:	8b 45 08             	mov    0x8(%ebp),%eax
 362:	0f b6 00             	movzbl (%eax),%eax
 365:	0f b6 d0             	movzbl %al,%edx
 368:	8b 45 0c             	mov    0xc(%ebp),%eax
 36b:	0f b6 00             	movzbl (%eax),%eax
 36e:	0f b6 c0             	movzbl %al,%eax
 371:	29 c2                	sub    %eax,%edx
 373:	89 d0                	mov    %edx,%eax
}
 375:	5d                   	pop    %ebp
 376:	c3                   	ret

00000377 <strlen>:

uint
strlen(char *s)
{
 377:	f3 0f 1e fb          	endbr32
 37b:	55                   	push   %ebp
 37c:	89 e5                	mov    %esp,%ebp
 37e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 381:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 388:	eb 04                	jmp    38e <strlen+0x17>
 38a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 38e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 391:	8b 45 08             	mov    0x8(%ebp),%eax
 394:	01 d0                	add    %edx,%eax
 396:	0f b6 00             	movzbl (%eax),%eax
 399:	84 c0                	test   %al,%al
 39b:	75 ed                	jne    38a <strlen+0x13>
    ;
  return n;
 39d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3a0:	c9                   	leave
 3a1:	c3                   	ret

000003a2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3a2:	f3 0f 1e fb          	endbr32
 3a6:	55                   	push   %ebp
 3a7:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3a9:	8b 45 10             	mov    0x10(%ebp),%eax
 3ac:	50                   	push   %eax
 3ad:	ff 75 0c             	push   0xc(%ebp)
 3b0:	ff 75 08             	push   0x8(%ebp)
 3b3:	e8 22 ff ff ff       	call   2da <stosb>
 3b8:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3bb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3be:	c9                   	leave
 3bf:	c3                   	ret

000003c0 <strchr>:

char*
strchr(const char *s, char c)
{
 3c0:	f3 0f 1e fb          	endbr32
 3c4:	55                   	push   %ebp
 3c5:	89 e5                	mov    %esp,%ebp
 3c7:	83 ec 04             	sub    $0x4,%esp
 3ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cd:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3d0:	eb 14                	jmp    3e6 <strchr+0x26>
    if(*s == c)
 3d2:	8b 45 08             	mov    0x8(%ebp),%eax
 3d5:	0f b6 00             	movzbl (%eax),%eax
 3d8:	38 45 fc             	cmp    %al,-0x4(%ebp)
 3db:	75 05                	jne    3e2 <strchr+0x22>
      return (char*)s;
 3dd:	8b 45 08             	mov    0x8(%ebp),%eax
 3e0:	eb 13                	jmp    3f5 <strchr+0x35>
  for(; *s; s++)
 3e2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3e6:	8b 45 08             	mov    0x8(%ebp),%eax
 3e9:	0f b6 00             	movzbl (%eax),%eax
 3ec:	84 c0                	test   %al,%al
 3ee:	75 e2                	jne    3d2 <strchr+0x12>
  return 0;
 3f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3f5:	c9                   	leave
 3f6:	c3                   	ret

000003f7 <gets>:

char*
gets(char *buf, int max)
{
 3f7:	f3 0f 1e fb          	endbr32
 3fb:	55                   	push   %ebp
 3fc:	89 e5                	mov    %esp,%ebp
 3fe:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 401:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 408:	eb 42                	jmp    44c <gets+0x55>
    cc = read(0, &c, 1);
 40a:	83 ec 04             	sub    $0x4,%esp
 40d:	6a 01                	push   $0x1
 40f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 412:	50                   	push   %eax
 413:	6a 00                	push   $0x0
 415:	e8 53 01 00 00       	call   56d <read>
 41a:	83 c4 10             	add    $0x10,%esp
 41d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 420:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 424:	7e 33                	jle    459 <gets+0x62>
      break;
    buf[i++] = c;
 426:	8b 45 f4             	mov    -0xc(%ebp),%eax
 429:	8d 50 01             	lea    0x1(%eax),%edx
 42c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 42f:	89 c2                	mov    %eax,%edx
 431:	8b 45 08             	mov    0x8(%ebp),%eax
 434:	01 c2                	add    %eax,%edx
 436:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 43a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 43c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 440:	3c 0a                	cmp    $0xa,%al
 442:	74 16                	je     45a <gets+0x63>
 444:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 448:	3c 0d                	cmp    $0xd,%al
 44a:	74 0e                	je     45a <gets+0x63>
  for(i=0; i+1 < max; ){
 44c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 44f:	83 c0 01             	add    $0x1,%eax
 452:	39 45 0c             	cmp    %eax,0xc(%ebp)
 455:	7f b3                	jg     40a <gets+0x13>
 457:	eb 01                	jmp    45a <gets+0x63>
      break;
 459:	90                   	nop
      break;
  }
  buf[i] = '\0';
 45a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 45d:	8b 45 08             	mov    0x8(%ebp),%eax
 460:	01 d0                	add    %edx,%eax
 462:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 465:	8b 45 08             	mov    0x8(%ebp),%eax
}
 468:	c9                   	leave
 469:	c3                   	ret

0000046a <stat>:

int
stat(char *n, struct stat *st)
{
 46a:	f3 0f 1e fb          	endbr32
 46e:	55                   	push   %ebp
 46f:	89 e5                	mov    %esp,%ebp
 471:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 474:	83 ec 08             	sub    $0x8,%esp
 477:	6a 00                	push   $0x0
 479:	ff 75 08             	push   0x8(%ebp)
 47c:	e8 14 01 00 00       	call   595 <open>
 481:	83 c4 10             	add    $0x10,%esp
 484:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 487:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 48b:	79 07                	jns    494 <stat+0x2a>
    return -1;
 48d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 492:	eb 25                	jmp    4b9 <stat+0x4f>
  r = fstat(fd, st);
 494:	83 ec 08             	sub    $0x8,%esp
 497:	ff 75 0c             	push   0xc(%ebp)
 49a:	ff 75 f4             	push   -0xc(%ebp)
 49d:	e8 0b 01 00 00       	call   5ad <fstat>
 4a2:	83 c4 10             	add    $0x10,%esp
 4a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4a8:	83 ec 0c             	sub    $0xc,%esp
 4ab:	ff 75 f4             	push   -0xc(%ebp)
 4ae:	e8 ca 00 00 00       	call   57d <close>
 4b3:	83 c4 10             	add    $0x10,%esp
  return r;
 4b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4b9:	c9                   	leave
 4ba:	c3                   	ret

000004bb <atoi>:

int
atoi(const char *s)
{
 4bb:	f3 0f 1e fb          	endbr32
 4bf:	55                   	push   %ebp
 4c0:	89 e5                	mov    %esp,%ebp
 4c2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4cc:	eb 25                	jmp    4f3 <atoi+0x38>
    n = n*10 + *s++ - '0';
 4ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4d1:	89 d0                	mov    %edx,%eax
 4d3:	c1 e0 02             	shl    $0x2,%eax
 4d6:	01 d0                	add    %edx,%eax
 4d8:	01 c0                	add    %eax,%eax
 4da:	89 c1                	mov    %eax,%ecx
 4dc:	8b 45 08             	mov    0x8(%ebp),%eax
 4df:	8d 50 01             	lea    0x1(%eax),%edx
 4e2:	89 55 08             	mov    %edx,0x8(%ebp)
 4e5:	0f b6 00             	movzbl (%eax),%eax
 4e8:	0f be c0             	movsbl %al,%eax
 4eb:	01 c8                	add    %ecx,%eax
 4ed:	83 e8 30             	sub    $0x30,%eax
 4f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4f3:	8b 45 08             	mov    0x8(%ebp),%eax
 4f6:	0f b6 00             	movzbl (%eax),%eax
 4f9:	3c 2f                	cmp    $0x2f,%al
 4fb:	7e 0a                	jle    507 <atoi+0x4c>
 4fd:	8b 45 08             	mov    0x8(%ebp),%eax
 500:	0f b6 00             	movzbl (%eax),%eax
 503:	3c 39                	cmp    $0x39,%al
 505:	7e c7                	jle    4ce <atoi+0x13>
  return n;
 507:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 50a:	c9                   	leave
 50b:	c3                   	ret

0000050c <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 50c:	f3 0f 1e fb          	endbr32
 510:	55                   	push   %ebp
 511:	89 e5                	mov    %esp,%ebp
 513:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 516:	8b 45 08             	mov    0x8(%ebp),%eax
 519:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 51c:	8b 45 0c             	mov    0xc(%ebp),%eax
 51f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 522:	eb 17                	jmp    53b <memmove+0x2f>
    *dst++ = *src++;
 524:	8b 55 f8             	mov    -0x8(%ebp),%edx
 527:	8d 42 01             	lea    0x1(%edx),%eax
 52a:	89 45 f8             	mov    %eax,-0x8(%ebp)
 52d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 530:	8d 48 01             	lea    0x1(%eax),%ecx
 533:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 536:	0f b6 12             	movzbl (%edx),%edx
 539:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 53b:	8b 45 10             	mov    0x10(%ebp),%eax
 53e:	8d 50 ff             	lea    -0x1(%eax),%edx
 541:	89 55 10             	mov    %edx,0x10(%ebp)
 544:	85 c0                	test   %eax,%eax
 546:	7f dc                	jg     524 <memmove+0x18>
  return vdst;
 548:	8b 45 08             	mov    0x8(%ebp),%eax
}
 54b:	c9                   	leave
 54c:	c3                   	ret

0000054d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 54d:	b8 01 00 00 00       	mov    $0x1,%eax
 552:	cd 40                	int    $0x40
 554:	c3                   	ret

00000555 <exit>:
SYSCALL(exit)
 555:	b8 02 00 00 00       	mov    $0x2,%eax
 55a:	cd 40                	int    $0x40
 55c:	c3                   	ret

0000055d <wait>:
SYSCALL(wait)
 55d:	b8 03 00 00 00       	mov    $0x3,%eax
 562:	cd 40                	int    $0x40
 564:	c3                   	ret

00000565 <pipe>:
SYSCALL(pipe)
 565:	b8 04 00 00 00       	mov    $0x4,%eax
 56a:	cd 40                	int    $0x40
 56c:	c3                   	ret

0000056d <read>:
SYSCALL(read)
 56d:	b8 05 00 00 00       	mov    $0x5,%eax
 572:	cd 40                	int    $0x40
 574:	c3                   	ret

00000575 <write>:
SYSCALL(write)
 575:	b8 10 00 00 00       	mov    $0x10,%eax
 57a:	cd 40                	int    $0x40
 57c:	c3                   	ret

0000057d <close>:
SYSCALL(close)
 57d:	b8 15 00 00 00       	mov    $0x15,%eax
 582:	cd 40                	int    $0x40
 584:	c3                   	ret

00000585 <kill>:
SYSCALL(kill)
 585:	b8 06 00 00 00       	mov    $0x6,%eax
 58a:	cd 40                	int    $0x40
 58c:	c3                   	ret

0000058d <exec>:
SYSCALL(exec)
 58d:	b8 07 00 00 00       	mov    $0x7,%eax
 592:	cd 40                	int    $0x40
 594:	c3                   	ret

00000595 <open>:
SYSCALL(open)
 595:	b8 0f 00 00 00       	mov    $0xf,%eax
 59a:	cd 40                	int    $0x40
 59c:	c3                   	ret

0000059d <mknod>:
SYSCALL(mknod)
 59d:	b8 11 00 00 00       	mov    $0x11,%eax
 5a2:	cd 40                	int    $0x40
 5a4:	c3                   	ret

000005a5 <unlink>:
SYSCALL(unlink)
 5a5:	b8 12 00 00 00       	mov    $0x12,%eax
 5aa:	cd 40                	int    $0x40
 5ac:	c3                   	ret

000005ad <fstat>:
SYSCALL(fstat)
 5ad:	b8 08 00 00 00       	mov    $0x8,%eax
 5b2:	cd 40                	int    $0x40
 5b4:	c3                   	ret

000005b5 <link>:
SYSCALL(link)
 5b5:	b8 13 00 00 00       	mov    $0x13,%eax
 5ba:	cd 40                	int    $0x40
 5bc:	c3                   	ret

000005bd <mkdir>:
SYSCALL(mkdir)
 5bd:	b8 14 00 00 00       	mov    $0x14,%eax
 5c2:	cd 40                	int    $0x40
 5c4:	c3                   	ret

000005c5 <chdir>:
SYSCALL(chdir)
 5c5:	b8 09 00 00 00       	mov    $0x9,%eax
 5ca:	cd 40                	int    $0x40
 5cc:	c3                   	ret

000005cd <dup>:
SYSCALL(dup)
 5cd:	b8 0a 00 00 00       	mov    $0xa,%eax
 5d2:	cd 40                	int    $0x40
 5d4:	c3                   	ret

000005d5 <getpid>:
SYSCALL(getpid)
 5d5:	b8 0b 00 00 00       	mov    $0xb,%eax
 5da:	cd 40                	int    $0x40
 5dc:	c3                   	ret

000005dd <sbrk>:
SYSCALL(sbrk)
 5dd:	b8 0c 00 00 00       	mov    $0xc,%eax
 5e2:	cd 40                	int    $0x40
 5e4:	c3                   	ret

000005e5 <sleep>:
SYSCALL(sleep)
 5e5:	b8 0d 00 00 00       	mov    $0xd,%eax
 5ea:	cd 40                	int    $0x40
 5ec:	c3                   	ret

000005ed <uptime>:
SYSCALL(uptime)
 5ed:	b8 0e 00 00 00       	mov    $0xe,%eax
 5f2:	cd 40                	int    $0x40
 5f4:	c3                   	ret

000005f5 <uthread_init>:
SYSCALL(uthread_init)
 5f5:	b8 16 00 00 00       	mov    $0x16,%eax
 5fa:	cd 40                	int    $0x40
 5fc:	c3                   	ret

000005fd <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5fd:	f3 0f 1e fb          	endbr32
 601:	55                   	push   %ebp
 602:	89 e5                	mov    %esp,%ebp
 604:	83 ec 18             	sub    $0x18,%esp
 607:	8b 45 0c             	mov    0xc(%ebp),%eax
 60a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 60d:	83 ec 04             	sub    $0x4,%esp
 610:	6a 01                	push   $0x1
 612:	8d 45 f4             	lea    -0xc(%ebp),%eax
 615:	50                   	push   %eax
 616:	ff 75 08             	push   0x8(%ebp)
 619:	e8 57 ff ff ff       	call   575 <write>
 61e:	83 c4 10             	add    $0x10,%esp
}
 621:	90                   	nop
 622:	c9                   	leave
 623:	c3                   	ret

00000624 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 624:	f3 0f 1e fb          	endbr32
 628:	55                   	push   %ebp
 629:	89 e5                	mov    %esp,%ebp
 62b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 62e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 635:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 639:	74 17                	je     652 <printint+0x2e>
 63b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 63f:	79 11                	jns    652 <printint+0x2e>
    neg = 1;
 641:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 648:	8b 45 0c             	mov    0xc(%ebp),%eax
 64b:	f7 d8                	neg    %eax
 64d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 650:	eb 06                	jmp    658 <printint+0x34>
  } else {
    x = xx;
 652:	8b 45 0c             	mov    0xc(%ebp),%eax
 655:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 658:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 65f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 662:	8b 45 ec             	mov    -0x14(%ebp),%eax
 665:	ba 00 00 00 00       	mov    $0x0,%edx
 66a:	f7 f1                	div    %ecx
 66c:	89 d1                	mov    %edx,%ecx
 66e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 671:	8d 50 01             	lea    0x1(%eax),%edx
 674:	89 55 f4             	mov    %edx,-0xc(%ebp)
 677:	0f b6 91 0c 0e 00 00 	movzbl 0xe0c(%ecx),%edx
 67e:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 682:	8b 4d 10             	mov    0x10(%ebp),%ecx
 685:	8b 45 ec             	mov    -0x14(%ebp),%eax
 688:	ba 00 00 00 00       	mov    $0x0,%edx
 68d:	f7 f1                	div    %ecx
 68f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 692:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 696:	75 c7                	jne    65f <printint+0x3b>
  if(neg)
 698:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 69c:	74 2d                	je     6cb <printint+0xa7>
    buf[i++] = '-';
 69e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6a1:	8d 50 01             	lea    0x1(%eax),%edx
 6a4:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6a7:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6ac:	eb 1d                	jmp    6cb <printint+0xa7>
    putc(fd, buf[i]);
 6ae:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b4:	01 d0                	add    %edx,%eax
 6b6:	0f b6 00             	movzbl (%eax),%eax
 6b9:	0f be c0             	movsbl %al,%eax
 6bc:	83 ec 08             	sub    $0x8,%esp
 6bf:	50                   	push   %eax
 6c0:	ff 75 08             	push   0x8(%ebp)
 6c3:	e8 35 ff ff ff       	call   5fd <putc>
 6c8:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6cb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6d3:	79 d9                	jns    6ae <printint+0x8a>
}
 6d5:	90                   	nop
 6d6:	90                   	nop
 6d7:	c9                   	leave
 6d8:	c3                   	ret

000006d9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6d9:	f3 0f 1e fb          	endbr32
 6dd:	55                   	push   %ebp
 6de:	89 e5                	mov    %esp,%ebp
 6e0:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6e3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6ea:	8d 45 0c             	lea    0xc(%ebp),%eax
 6ed:	83 c0 04             	add    $0x4,%eax
 6f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6fa:	e9 59 01 00 00       	jmp    858 <printf+0x17f>
    c = fmt[i] & 0xff;
 6ff:	8b 55 0c             	mov    0xc(%ebp),%edx
 702:	8b 45 f0             	mov    -0x10(%ebp),%eax
 705:	01 d0                	add    %edx,%eax
 707:	0f b6 00             	movzbl (%eax),%eax
 70a:	0f be c0             	movsbl %al,%eax
 70d:	25 ff 00 00 00       	and    $0xff,%eax
 712:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 715:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 719:	75 2c                	jne    747 <printf+0x6e>
      if(c == '%'){
 71b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 71f:	75 0c                	jne    72d <printf+0x54>
        state = '%';
 721:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 728:	e9 27 01 00 00       	jmp    854 <printf+0x17b>
      } else {
        putc(fd, c);
 72d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 730:	0f be c0             	movsbl %al,%eax
 733:	83 ec 08             	sub    $0x8,%esp
 736:	50                   	push   %eax
 737:	ff 75 08             	push   0x8(%ebp)
 73a:	e8 be fe ff ff       	call   5fd <putc>
 73f:	83 c4 10             	add    $0x10,%esp
 742:	e9 0d 01 00 00       	jmp    854 <printf+0x17b>
      }
    } else if(state == '%'){
 747:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 74b:	0f 85 03 01 00 00    	jne    854 <printf+0x17b>
      if(c == 'd'){
 751:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 755:	75 1e                	jne    775 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 757:	8b 45 e8             	mov    -0x18(%ebp),%eax
 75a:	8b 00                	mov    (%eax),%eax
 75c:	6a 01                	push   $0x1
 75e:	6a 0a                	push   $0xa
 760:	50                   	push   %eax
 761:	ff 75 08             	push   0x8(%ebp)
 764:	e8 bb fe ff ff       	call   624 <printint>
 769:	83 c4 10             	add    $0x10,%esp
        ap++;
 76c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 770:	e9 d8 00 00 00       	jmp    84d <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 775:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 779:	74 06                	je     781 <printf+0xa8>
 77b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 77f:	75 1e                	jne    79f <printf+0xc6>
        printint(fd, *ap, 16, 0);
 781:	8b 45 e8             	mov    -0x18(%ebp),%eax
 784:	8b 00                	mov    (%eax),%eax
 786:	6a 00                	push   $0x0
 788:	6a 10                	push   $0x10
 78a:	50                   	push   %eax
 78b:	ff 75 08             	push   0x8(%ebp)
 78e:	e8 91 fe ff ff       	call   624 <printint>
 793:	83 c4 10             	add    $0x10,%esp
        ap++;
 796:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 79a:	e9 ae 00 00 00       	jmp    84d <printf+0x174>
      } else if(c == 's'){
 79f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7a3:	75 43                	jne    7e8 <printf+0x10f>
        s = (char*)*ap;
 7a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7a8:	8b 00                	mov    (%eax),%eax
 7aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7ad:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7b5:	75 25                	jne    7dc <printf+0x103>
          s = "(null)";
 7b7:	c7 45 f4 39 0b 00 00 	movl   $0xb39,-0xc(%ebp)
        while(*s != 0){
 7be:	eb 1c                	jmp    7dc <printf+0x103>
          putc(fd, *s);
 7c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c3:	0f b6 00             	movzbl (%eax),%eax
 7c6:	0f be c0             	movsbl %al,%eax
 7c9:	83 ec 08             	sub    $0x8,%esp
 7cc:	50                   	push   %eax
 7cd:	ff 75 08             	push   0x8(%ebp)
 7d0:	e8 28 fe ff ff       	call   5fd <putc>
 7d5:	83 c4 10             	add    $0x10,%esp
          s++;
 7d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 7dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7df:	0f b6 00             	movzbl (%eax),%eax
 7e2:	84 c0                	test   %al,%al
 7e4:	75 da                	jne    7c0 <printf+0xe7>
 7e6:	eb 65                	jmp    84d <printf+0x174>
        }
      } else if(c == 'c'){
 7e8:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7ec:	75 1d                	jne    80b <printf+0x132>
        putc(fd, *ap);
 7ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7f1:	8b 00                	mov    (%eax),%eax
 7f3:	0f be c0             	movsbl %al,%eax
 7f6:	83 ec 08             	sub    $0x8,%esp
 7f9:	50                   	push   %eax
 7fa:	ff 75 08             	push   0x8(%ebp)
 7fd:	e8 fb fd ff ff       	call   5fd <putc>
 802:	83 c4 10             	add    $0x10,%esp
        ap++;
 805:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 809:	eb 42                	jmp    84d <printf+0x174>
      } else if(c == '%'){
 80b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 80f:	75 17                	jne    828 <printf+0x14f>
        putc(fd, c);
 811:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 814:	0f be c0             	movsbl %al,%eax
 817:	83 ec 08             	sub    $0x8,%esp
 81a:	50                   	push   %eax
 81b:	ff 75 08             	push   0x8(%ebp)
 81e:	e8 da fd ff ff       	call   5fd <putc>
 823:	83 c4 10             	add    $0x10,%esp
 826:	eb 25                	jmp    84d <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 828:	83 ec 08             	sub    $0x8,%esp
 82b:	6a 25                	push   $0x25
 82d:	ff 75 08             	push   0x8(%ebp)
 830:	e8 c8 fd ff ff       	call   5fd <putc>
 835:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 838:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 83b:	0f be c0             	movsbl %al,%eax
 83e:	83 ec 08             	sub    $0x8,%esp
 841:	50                   	push   %eax
 842:	ff 75 08             	push   0x8(%ebp)
 845:	e8 b3 fd ff ff       	call   5fd <putc>
 84a:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 84d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 854:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 858:	8b 55 0c             	mov    0xc(%ebp),%edx
 85b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85e:	01 d0                	add    %edx,%eax
 860:	0f b6 00             	movzbl (%eax),%eax
 863:	84 c0                	test   %al,%al
 865:	0f 85 94 fe ff ff    	jne    6ff <printf+0x26>
    }
  }
}
 86b:	90                   	nop
 86c:	90                   	nop
 86d:	c9                   	leave
 86e:	c3                   	ret

0000086f <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 86f:	f3 0f 1e fb          	endbr32
 873:	55                   	push   %ebp
 874:	89 e5                	mov    %esp,%ebp
 876:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 879:	8b 45 08             	mov    0x8(%ebp),%eax
 87c:	83 e8 08             	sub    $0x8,%eax
 87f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 882:	a1 48 8e 00 00       	mov    0x8e48,%eax
 887:	89 45 fc             	mov    %eax,-0x4(%ebp)
 88a:	eb 24                	jmp    8b0 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 88c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88f:	8b 00                	mov    (%eax),%eax
 891:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 894:	72 12                	jb     8a8 <free+0x39>
 896:	8b 45 f8             	mov    -0x8(%ebp),%eax
 899:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 89c:	77 24                	ja     8c2 <free+0x53>
 89e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a1:	8b 00                	mov    (%eax),%eax
 8a3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8a6:	72 1a                	jb     8c2 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ab:	8b 00                	mov    (%eax),%eax
 8ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8b6:	76 d4                	jbe    88c <free+0x1d>
 8b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bb:	8b 00                	mov    (%eax),%eax
 8bd:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8c0:	73 ca                	jae    88c <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c5:	8b 40 04             	mov    0x4(%eax),%eax
 8c8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d2:	01 c2                	add    %eax,%edx
 8d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d7:	8b 00                	mov    (%eax),%eax
 8d9:	39 c2                	cmp    %eax,%edx
 8db:	75 24                	jne    901 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 8dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e0:	8b 50 04             	mov    0x4(%eax),%edx
 8e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e6:	8b 00                	mov    (%eax),%eax
 8e8:	8b 40 04             	mov    0x4(%eax),%eax
 8eb:	01 c2                	add    %eax,%edx
 8ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f0:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f6:	8b 00                	mov    (%eax),%eax
 8f8:	8b 10                	mov    (%eax),%edx
 8fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fd:	89 10                	mov    %edx,(%eax)
 8ff:	eb 0a                	jmp    90b <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 901:	8b 45 fc             	mov    -0x4(%ebp),%eax
 904:	8b 10                	mov    (%eax),%edx
 906:	8b 45 f8             	mov    -0x8(%ebp),%eax
 909:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 90b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90e:	8b 40 04             	mov    0x4(%eax),%eax
 911:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 918:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91b:	01 d0                	add    %edx,%eax
 91d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 920:	75 20                	jne    942 <free+0xd3>
    p->s.size += bp->s.size;
 922:	8b 45 fc             	mov    -0x4(%ebp),%eax
 925:	8b 50 04             	mov    0x4(%eax),%edx
 928:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92b:	8b 40 04             	mov    0x4(%eax),%eax
 92e:	01 c2                	add    %eax,%edx
 930:	8b 45 fc             	mov    -0x4(%ebp),%eax
 933:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 936:	8b 45 f8             	mov    -0x8(%ebp),%eax
 939:	8b 10                	mov    (%eax),%edx
 93b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93e:	89 10                	mov    %edx,(%eax)
 940:	eb 08                	jmp    94a <free+0xdb>
  } else
    p->s.ptr = bp;
 942:	8b 45 fc             	mov    -0x4(%ebp),%eax
 945:	8b 55 f8             	mov    -0x8(%ebp),%edx
 948:	89 10                	mov    %edx,(%eax)
  freep = p;
 94a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94d:	a3 48 8e 00 00       	mov    %eax,0x8e48
}
 952:	90                   	nop
 953:	c9                   	leave
 954:	c3                   	ret

00000955 <morecore>:

static Header*
morecore(uint nu)
{
 955:	f3 0f 1e fb          	endbr32
 959:	55                   	push   %ebp
 95a:	89 e5                	mov    %esp,%ebp
 95c:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 95f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 966:	77 07                	ja     96f <morecore+0x1a>
    nu = 4096;
 968:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 96f:	8b 45 08             	mov    0x8(%ebp),%eax
 972:	c1 e0 03             	shl    $0x3,%eax
 975:	83 ec 0c             	sub    $0xc,%esp
 978:	50                   	push   %eax
 979:	e8 5f fc ff ff       	call   5dd <sbrk>
 97e:	83 c4 10             	add    $0x10,%esp
 981:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 984:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 988:	75 07                	jne    991 <morecore+0x3c>
    return 0;
 98a:	b8 00 00 00 00       	mov    $0x0,%eax
 98f:	eb 26                	jmp    9b7 <morecore+0x62>
  hp = (Header*)p;
 991:	8b 45 f4             	mov    -0xc(%ebp),%eax
 994:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 997:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99a:	8b 55 08             	mov    0x8(%ebp),%edx
 99d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a3:	83 c0 08             	add    $0x8,%eax
 9a6:	83 ec 0c             	sub    $0xc,%esp
 9a9:	50                   	push   %eax
 9aa:	e8 c0 fe ff ff       	call   86f <free>
 9af:	83 c4 10             	add    $0x10,%esp
  return freep;
 9b2:	a1 48 8e 00 00       	mov    0x8e48,%eax
}
 9b7:	c9                   	leave
 9b8:	c3                   	ret

000009b9 <malloc>:

void*
malloc(uint nbytes)
{
 9b9:	f3 0f 1e fb          	endbr32
 9bd:	55                   	push   %ebp
 9be:	89 e5                	mov    %esp,%ebp
 9c0:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9c3:	8b 45 08             	mov    0x8(%ebp),%eax
 9c6:	83 c0 07             	add    $0x7,%eax
 9c9:	c1 e8 03             	shr    $0x3,%eax
 9cc:	83 c0 01             	add    $0x1,%eax
 9cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9d2:	a1 48 8e 00 00       	mov    0x8e48,%eax
 9d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9de:	75 23                	jne    a03 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 9e0:	c7 45 f0 40 8e 00 00 	movl   $0x8e40,-0x10(%ebp)
 9e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ea:	a3 48 8e 00 00       	mov    %eax,0x8e48
 9ef:	a1 48 8e 00 00       	mov    0x8e48,%eax
 9f4:	a3 40 8e 00 00       	mov    %eax,0x8e40
    base.s.size = 0;
 9f9:	c7 05 44 8e 00 00 00 	movl   $0x0,0x8e44
 a00:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a03:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a06:	8b 00                	mov    (%eax),%eax
 a08:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0e:	8b 40 04             	mov    0x4(%eax),%eax
 a11:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a14:	77 4d                	ja     a63 <malloc+0xaa>
      if(p->s.size == nunits)
 a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a19:	8b 40 04             	mov    0x4(%eax),%eax
 a1c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a1f:	75 0c                	jne    a2d <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a24:	8b 10                	mov    (%eax),%edx
 a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a29:	89 10                	mov    %edx,(%eax)
 a2b:	eb 26                	jmp    a53 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a30:	8b 40 04             	mov    0x4(%eax),%eax
 a33:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a36:	89 c2                	mov    %eax,%edx
 a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a41:	8b 40 04             	mov    0x4(%eax),%eax
 a44:	c1 e0 03             	shl    $0x3,%eax
 a47:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4d:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a50:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a56:	a3 48 8e 00 00       	mov    %eax,0x8e48
      return (void*)(p + 1);
 a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5e:	83 c0 08             	add    $0x8,%eax
 a61:	eb 3b                	jmp    a9e <malloc+0xe5>
    }
    if(p == freep)
 a63:	a1 48 8e 00 00       	mov    0x8e48,%eax
 a68:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a6b:	75 1e                	jne    a8b <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 a6d:	83 ec 0c             	sub    $0xc,%esp
 a70:	ff 75 ec             	push   -0x14(%ebp)
 a73:	e8 dd fe ff ff       	call   955 <morecore>
 a78:	83 c4 10             	add    $0x10,%esp
 a7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a7e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a82:	75 07                	jne    a8b <malloc+0xd2>
        return 0;
 a84:	b8 00 00 00 00       	mov    $0x0,%eax
 a89:	eb 13                	jmp    a9e <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a94:	8b 00                	mov    (%eax),%eax
 a96:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a99:	e9 6d ff ff ff       	jmp    a0b <malloc+0x52>
  }
}
 a9e:	c9                   	leave
 a9f:	c3                   	ret
