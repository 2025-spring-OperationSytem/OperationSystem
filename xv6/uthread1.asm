
_uthread1:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_schedule>:
thread_p  next_thread;
extern void thread_switch(void);

static void 
thread_schedule(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  /* Find another runnable thread. */
  next_thread = 0;
   6:	c7 05 44 0a 00 00 00 	movl   $0x0,0xa44
   d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 60 0a 00 00 	movl   $0xa60,-0xc(%ebp)
  17:	eb 29                	jmp    42 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  22:	83 f8 02             	cmp    $0x2,%eax
  25:	75 14                	jne    3b <thread_schedule+0x3b>
  27:	a1 40 0a 00 00       	mov    0xa40,%eax
  2c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  2f:	74 0a                	je     3b <thread_schedule+0x3b>
      next_thread = t;
  31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  34:	a3 44 0a 00 00       	mov    %eax,0xa44
      break;
  39:	eb 11                	jmp    4c <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  3b:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  42:	b8 80 8a 00 00       	mov    $0x8a80,%eax
  47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4a:	72 cd                	jb     19 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  4c:	b8 80 8a 00 00       	mov    $0x8a80,%eax
  51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  54:	72 1a                	jb     70 <thread_schedule+0x70>
  56:	a1 40 0a 00 00       	mov    0xa40,%eax
  5b:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  61:	83 f8 02             	cmp    $0x2,%eax
  64:	75 0a                	jne    70 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  66:	a1 40 0a 00 00       	mov    0xa40,%eax
  6b:	a3 44 0a 00 00       	mov    %eax,0xa44
  }

  if (next_thread == 0) {
  70:	a1 44 0a 00 00       	mov    0xa44,%eax
  75:	85 c0                	test   %eax,%eax
  77:	75 17                	jne    90 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 b8 09 00 00       	push   $0x9b8
  81:	6a 02                	push   $0x2
  83:	e8 76 05 00 00       	call   5fe <printf>
  88:	83 c4 10             	add    $0x10,%esp
    exit();
  8b:	e8 f2 03 00 00       	call   482 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  90:	8b 15 40 0a 00 00    	mov    0xa40,%edx
  96:	a1 44 0a 00 00       	mov    0xa44,%eax
  9b:	39 c2                	cmp    %eax,%edx
  9d:	74 25                	je     c4 <thread_schedule+0xc4>
    next_thread->state = RUNNING;
  9f:	a1 44 0a 00 00       	mov    0xa44,%eax
  a4:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  ab:	00 00 00 
    current_thread->state = RUNNABLE;
  ae:	a1 40 0a 00 00       	mov    0xa40,%eax
  b3:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
  ba:	00 00 00 
    thread_switch();
  bd:	e8 68 01 00 00       	call   22a <thread_switch>
  } else
    next_thread = 0;
}
  c2:	eb 0a                	jmp    ce <thread_schedule+0xce>
    next_thread = 0;
  c4:	c7 05 44 0a 00 00 00 	movl   $0x0,0xa44
  cb:	00 00 00 
}
  ce:	90                   	nop
  cf:	c9                   	leave
  d0:	c3                   	ret

000000d1 <thread_init>:

void 
thread_init(void)
{
  d1:	55                   	push   %ebp
  d2:	89 e5                	mov    %esp,%ebp
  d4:	83 ec 08             	sub    $0x8,%esp
  uthread_init(thread_schedule);
  d7:	83 ec 0c             	sub    $0xc,%esp
  da:	68 00 00 00 00       	push   $0x0
  df:	e8 3e 04 00 00       	call   522 <uthread_init>
  e4:	83 c4 10             	add    $0x10,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  e7:	c7 05 40 0a 00 00 60 	movl   $0xa60,0xa40
  ee:	0a 00 00 
  current_thread->state = RUNNING;
  f1:	a1 40 0a 00 00       	mov    0xa40,%eax
  f6:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  fd:	00 00 00 
}
 100:	90                   	nop
 101:	c9                   	leave
 102:	c3                   	ret

00000103 <thread_create>:

void 
thread_create(void (*func)())
{
 103:	55                   	push   %ebp
 104:	89 e5                	mov    %esp,%ebp
 106:	83 ec 10             	sub    $0x10,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 109:	c7 45 fc 60 0a 00 00 	movl   $0xa60,-0x4(%ebp)
 110:	eb 14                	jmp    126 <thread_create+0x23>
    if (t->state == FREE) break;
 112:	8b 45 fc             	mov    -0x4(%ebp),%eax
 115:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 11b:	85 c0                	test   %eax,%eax
 11d:	74 13                	je     132 <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 11f:	81 45 fc 08 20 00 00 	addl   $0x2008,-0x4(%ebp)
 126:	b8 80 8a 00 00       	mov    $0x8a80,%eax
 12b:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 12e:	72 e2                	jb     112 <thread_create+0xf>
 130:	eb 01                	jmp    133 <thread_create+0x30>
    if (t->state == FREE) break;
 132:	90                   	nop
  }
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 133:	8b 45 fc             	mov    -0x4(%ebp),%eax
 136:	83 c0 04             	add    $0x4,%eax
 139:	05 00 20 00 00       	add    $0x2000,%eax
 13e:	89 c2                	mov    %eax,%edx
 140:	8b 45 fc             	mov    -0x4(%ebp),%eax
 143:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                              // space for return address
 145:	8b 45 fc             	mov    -0x4(%ebp),%eax
 148:	8b 00                	mov    (%eax),%eax
 14a:	8d 50 fc             	lea    -0x4(%eax),%edx
 14d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 150:	89 10                	mov    %edx,(%eax)
  * (int *) (t->sp) = (int)func;           // push return address on stack
 152:	8b 45 fc             	mov    -0x4(%ebp),%eax
 155:	8b 00                	mov    (%eax),%eax
 157:	89 c2                	mov    %eax,%edx
 159:	8b 45 08             	mov    0x8(%ebp),%eax
 15c:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                             // space for registers that thread_switch expects
 15e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 161:	8b 00                	mov    (%eax),%eax
 163:	8d 50 e0             	lea    -0x20(%eax),%edx
 166:	8b 45 fc             	mov    -0x4(%ebp),%eax
 169:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 16b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 16e:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 175:	00 00 00 
}
 178:	90                   	nop
 179:	c9                   	leave
 17a:	c3                   	ret

0000017b <mythread>:

static void 
mythread(void)
{
 17b:	55                   	push   %ebp
 17c:	89 e5                	mov    %esp,%ebp
 17e:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 181:	83 ec 08             	sub    $0x8,%esp
 184:	68 de 09 00 00       	push   $0x9de
 189:	6a 01                	push   $0x1
 18b:	e8 6e 04 00 00       	call   5fe <printf>
 190:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 193:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 19a:	eb 1c                	jmp    1b8 <mythread+0x3d>
    printf(1, "my thread 0x%x\n", (int) current_thread);
 19c:	a1 40 0a 00 00       	mov    0xa40,%eax
 1a1:	83 ec 04             	sub    $0x4,%esp
 1a4:	50                   	push   %eax
 1a5:	68 f1 09 00 00       	push   $0x9f1
 1aa:	6a 01                	push   $0x1
 1ac:	e8 4d 04 00 00       	call   5fe <printf>
 1b1:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1b8:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 1bc:	7e de                	jle    19c <mythread+0x21>
  }
  printf(1, "my thread: exit\n");
 1be:	83 ec 08             	sub    $0x8,%esp
 1c1:	68 01 0a 00 00       	push   $0xa01
 1c6:	6a 01                	push   $0x1
 1c8:	e8 31 04 00 00       	call   5fe <printf>
 1cd:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 1d0:	a1 40 0a 00 00       	mov    0xa40,%eax
 1d5:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 1dc:	00 00 00 
}
 1df:	90                   	nop
 1e0:	c9                   	leave
 1e1:	c3                   	ret

000001e2 <main>:


int 
main(int argc, char *argv[]) 
{
 1e2:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 1e6:	83 e4 f0             	and    $0xfffffff0,%esp
 1e9:	ff 71 fc             	push   -0x4(%ecx)
 1ec:	55                   	push   %ebp
 1ed:	89 e5                	mov    %esp,%ebp
 1ef:	51                   	push   %ecx
 1f0:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 1f3:	e8 d9 fe ff ff       	call   d1 <thread_init>
  thread_create(mythread);
 1f8:	83 ec 0c             	sub    $0xc,%esp
 1fb:	68 7b 01 00 00       	push   $0x17b
 200:	e8 fe fe ff ff       	call   103 <thread_create>
 205:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 208:	83 ec 0c             	sub    $0xc,%esp
 20b:	68 7b 01 00 00       	push   $0x17b
 210:	e8 ee fe ff ff       	call   103 <thread_create>
 215:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 218:	e8 e3 fd ff ff       	call   0 <thread_schedule>
  return 0;
 21d:	b8 00 00 00 00       	mov    $0x0,%eax
 222:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 225:	c9                   	leave
 226:	8d 61 fc             	lea    -0x4(%ecx),%esp
 229:	c3                   	ret

0000022a <thread_switch>:

	.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */

	ret    /* return to ra */
 22a:	c3                   	ret

0000022b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 22b:	55                   	push   %ebp
 22c:	89 e5                	mov    %esp,%ebp
 22e:	57                   	push   %edi
 22f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 230:	8b 4d 08             	mov    0x8(%ebp),%ecx
 233:	8b 55 10             	mov    0x10(%ebp),%edx
 236:	8b 45 0c             	mov    0xc(%ebp),%eax
 239:	89 cb                	mov    %ecx,%ebx
 23b:	89 df                	mov    %ebx,%edi
 23d:	89 d1                	mov    %edx,%ecx
 23f:	fc                   	cld
 240:	f3 aa                	rep stos %al,%es:(%edi)
 242:	89 ca                	mov    %ecx,%edx
 244:	89 fb                	mov    %edi,%ebx
 246:	89 5d 08             	mov    %ebx,0x8(%ebp)
 249:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 24c:	90                   	nop
 24d:	5b                   	pop    %ebx
 24e:	5f                   	pop    %edi
 24f:	5d                   	pop    %ebp
 250:	c3                   	ret

00000251 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 251:	55                   	push   %ebp
 252:	89 e5                	mov    %esp,%ebp
 254:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 257:	8b 45 08             	mov    0x8(%ebp),%eax
 25a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 25d:	90                   	nop
 25e:	8b 55 0c             	mov    0xc(%ebp),%edx
 261:	8d 42 01             	lea    0x1(%edx),%eax
 264:	89 45 0c             	mov    %eax,0xc(%ebp)
 267:	8b 45 08             	mov    0x8(%ebp),%eax
 26a:	8d 48 01             	lea    0x1(%eax),%ecx
 26d:	89 4d 08             	mov    %ecx,0x8(%ebp)
 270:	0f b6 12             	movzbl (%edx),%edx
 273:	88 10                	mov    %dl,(%eax)
 275:	0f b6 00             	movzbl (%eax),%eax
 278:	84 c0                	test   %al,%al
 27a:	75 e2                	jne    25e <strcpy+0xd>
    ;
  return os;
 27c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 27f:	c9                   	leave
 280:	c3                   	ret

00000281 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 281:	55                   	push   %ebp
 282:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 284:	eb 08                	jmp    28e <strcmp+0xd>
    p++, q++;
 286:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 28a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 28e:	8b 45 08             	mov    0x8(%ebp),%eax
 291:	0f b6 00             	movzbl (%eax),%eax
 294:	84 c0                	test   %al,%al
 296:	74 10                	je     2a8 <strcmp+0x27>
 298:	8b 45 08             	mov    0x8(%ebp),%eax
 29b:	0f b6 10             	movzbl (%eax),%edx
 29e:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a1:	0f b6 00             	movzbl (%eax),%eax
 2a4:	38 c2                	cmp    %al,%dl
 2a6:	74 de                	je     286 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 2a8:	8b 45 08             	mov    0x8(%ebp),%eax
 2ab:	0f b6 00             	movzbl (%eax),%eax
 2ae:	0f b6 d0             	movzbl %al,%edx
 2b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b4:	0f b6 00             	movzbl (%eax),%eax
 2b7:	0f b6 c0             	movzbl %al,%eax
 2ba:	29 c2                	sub    %eax,%edx
 2bc:	89 d0                	mov    %edx,%eax
}
 2be:	5d                   	pop    %ebp
 2bf:	c3                   	ret

000002c0 <strlen>:

uint
strlen(char *s)
{
 2c0:	55                   	push   %ebp
 2c1:	89 e5                	mov    %esp,%ebp
 2c3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2c6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2cd:	eb 04                	jmp    2d3 <strlen+0x13>
 2cf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2d3:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2d6:	8b 45 08             	mov    0x8(%ebp),%eax
 2d9:	01 d0                	add    %edx,%eax
 2db:	0f b6 00             	movzbl (%eax),%eax
 2de:	84 c0                	test   %al,%al
 2e0:	75 ed                	jne    2cf <strlen+0xf>
    ;
  return n;
 2e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2e5:	c9                   	leave
 2e6:	c3                   	ret

000002e7 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2e7:	55                   	push   %ebp
 2e8:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 2ea:	8b 45 10             	mov    0x10(%ebp),%eax
 2ed:	50                   	push   %eax
 2ee:	ff 75 0c             	push   0xc(%ebp)
 2f1:	ff 75 08             	push   0x8(%ebp)
 2f4:	e8 32 ff ff ff       	call   22b <stosb>
 2f9:	83 c4 0c             	add    $0xc,%esp
  return dst;
 2fc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ff:	c9                   	leave
 300:	c3                   	ret

00000301 <strchr>:

char*
strchr(const char *s, char c)
{
 301:	55                   	push   %ebp
 302:	89 e5                	mov    %esp,%ebp
 304:	83 ec 04             	sub    $0x4,%esp
 307:	8b 45 0c             	mov    0xc(%ebp),%eax
 30a:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 30d:	eb 14                	jmp    323 <strchr+0x22>
    if(*s == c)
 30f:	8b 45 08             	mov    0x8(%ebp),%eax
 312:	0f b6 00             	movzbl (%eax),%eax
 315:	38 45 fc             	cmp    %al,-0x4(%ebp)
 318:	75 05                	jne    31f <strchr+0x1e>
      return (char*)s;
 31a:	8b 45 08             	mov    0x8(%ebp),%eax
 31d:	eb 13                	jmp    332 <strchr+0x31>
  for(; *s; s++)
 31f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	0f b6 00             	movzbl (%eax),%eax
 329:	84 c0                	test   %al,%al
 32b:	75 e2                	jne    30f <strchr+0xe>
  return 0;
 32d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 332:	c9                   	leave
 333:	c3                   	ret

00000334 <gets>:

char*
gets(char *buf, int max)
{
 334:	55                   	push   %ebp
 335:	89 e5                	mov    %esp,%ebp
 337:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 33a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 341:	eb 42                	jmp    385 <gets+0x51>
    cc = read(0, &c, 1);
 343:	83 ec 04             	sub    $0x4,%esp
 346:	6a 01                	push   $0x1
 348:	8d 45 ef             	lea    -0x11(%ebp),%eax
 34b:	50                   	push   %eax
 34c:	6a 00                	push   $0x0
 34e:	e8 47 01 00 00       	call   49a <read>
 353:	83 c4 10             	add    $0x10,%esp
 356:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 359:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 35d:	7e 33                	jle    392 <gets+0x5e>
      break;
    buf[i++] = c;
 35f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 362:	8d 50 01             	lea    0x1(%eax),%edx
 365:	89 55 f4             	mov    %edx,-0xc(%ebp)
 368:	89 c2                	mov    %eax,%edx
 36a:	8b 45 08             	mov    0x8(%ebp),%eax
 36d:	01 c2                	add    %eax,%edx
 36f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 373:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 375:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 379:	3c 0a                	cmp    $0xa,%al
 37b:	74 16                	je     393 <gets+0x5f>
 37d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 381:	3c 0d                	cmp    $0xd,%al
 383:	74 0e                	je     393 <gets+0x5f>
  for(i=0; i+1 < max; ){
 385:	8b 45 f4             	mov    -0xc(%ebp),%eax
 388:	83 c0 01             	add    $0x1,%eax
 38b:	39 45 0c             	cmp    %eax,0xc(%ebp)
 38e:	7f b3                	jg     343 <gets+0xf>
 390:	eb 01                	jmp    393 <gets+0x5f>
      break;
 392:	90                   	nop
      break;
  }
  buf[i] = '\0';
 393:	8b 55 f4             	mov    -0xc(%ebp),%edx
 396:	8b 45 08             	mov    0x8(%ebp),%eax
 399:	01 d0                	add    %edx,%eax
 39b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 39e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3a1:	c9                   	leave
 3a2:	c3                   	ret

000003a3 <stat>:

int
stat(char *n, struct stat *st)
{
 3a3:	55                   	push   %ebp
 3a4:	89 e5                	mov    %esp,%ebp
 3a6:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3a9:	83 ec 08             	sub    $0x8,%esp
 3ac:	6a 00                	push   $0x0
 3ae:	ff 75 08             	push   0x8(%ebp)
 3b1:	e8 0c 01 00 00       	call   4c2 <open>
 3b6:	83 c4 10             	add    $0x10,%esp
 3b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3c0:	79 07                	jns    3c9 <stat+0x26>
    return -1;
 3c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3c7:	eb 25                	jmp    3ee <stat+0x4b>
  r = fstat(fd, st);
 3c9:	83 ec 08             	sub    $0x8,%esp
 3cc:	ff 75 0c             	push   0xc(%ebp)
 3cf:	ff 75 f4             	push   -0xc(%ebp)
 3d2:	e8 03 01 00 00       	call   4da <fstat>
 3d7:	83 c4 10             	add    $0x10,%esp
 3da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3dd:	83 ec 0c             	sub    $0xc,%esp
 3e0:	ff 75 f4             	push   -0xc(%ebp)
 3e3:	e8 c2 00 00 00       	call   4aa <close>
 3e8:	83 c4 10             	add    $0x10,%esp
  return r;
 3eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3ee:	c9                   	leave
 3ef:	c3                   	ret

000003f0 <atoi>:

int
atoi(const char *s)
{
 3f0:	55                   	push   %ebp
 3f1:	89 e5                	mov    %esp,%ebp
 3f3:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3f6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3fd:	eb 25                	jmp    424 <atoi+0x34>
    n = n*10 + *s++ - '0';
 3ff:	8b 55 fc             	mov    -0x4(%ebp),%edx
 402:	89 d0                	mov    %edx,%eax
 404:	c1 e0 02             	shl    $0x2,%eax
 407:	01 d0                	add    %edx,%eax
 409:	01 c0                	add    %eax,%eax
 40b:	89 c1                	mov    %eax,%ecx
 40d:	8b 45 08             	mov    0x8(%ebp),%eax
 410:	8d 50 01             	lea    0x1(%eax),%edx
 413:	89 55 08             	mov    %edx,0x8(%ebp)
 416:	0f b6 00             	movzbl (%eax),%eax
 419:	0f be c0             	movsbl %al,%eax
 41c:	01 c8                	add    %ecx,%eax
 41e:	83 e8 30             	sub    $0x30,%eax
 421:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 424:	8b 45 08             	mov    0x8(%ebp),%eax
 427:	0f b6 00             	movzbl (%eax),%eax
 42a:	3c 2f                	cmp    $0x2f,%al
 42c:	7e 0a                	jle    438 <atoi+0x48>
 42e:	8b 45 08             	mov    0x8(%ebp),%eax
 431:	0f b6 00             	movzbl (%eax),%eax
 434:	3c 39                	cmp    $0x39,%al
 436:	7e c7                	jle    3ff <atoi+0xf>
  return n;
 438:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 43b:	c9                   	leave
 43c:	c3                   	ret

0000043d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 43d:	55                   	push   %ebp
 43e:	89 e5                	mov    %esp,%ebp
 440:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 443:	8b 45 08             	mov    0x8(%ebp),%eax
 446:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 449:	8b 45 0c             	mov    0xc(%ebp),%eax
 44c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 44f:	eb 17                	jmp    468 <memmove+0x2b>
    *dst++ = *src++;
 451:	8b 55 f8             	mov    -0x8(%ebp),%edx
 454:	8d 42 01             	lea    0x1(%edx),%eax
 457:	89 45 f8             	mov    %eax,-0x8(%ebp)
 45a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 45d:	8d 48 01             	lea    0x1(%eax),%ecx
 460:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 463:	0f b6 12             	movzbl (%edx),%edx
 466:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 468:	8b 45 10             	mov    0x10(%ebp),%eax
 46b:	8d 50 ff             	lea    -0x1(%eax),%edx
 46e:	89 55 10             	mov    %edx,0x10(%ebp)
 471:	85 c0                	test   %eax,%eax
 473:	7f dc                	jg     451 <memmove+0x14>
  return vdst;
 475:	8b 45 08             	mov    0x8(%ebp),%eax
}
 478:	c9                   	leave
 479:	c3                   	ret

0000047a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 47a:	b8 01 00 00 00       	mov    $0x1,%eax
 47f:	cd 40                	int    $0x40
 481:	c3                   	ret

00000482 <exit>:
SYSCALL(exit)
 482:	b8 02 00 00 00       	mov    $0x2,%eax
 487:	cd 40                	int    $0x40
 489:	c3                   	ret

0000048a <wait>:
SYSCALL(wait)
 48a:	b8 03 00 00 00       	mov    $0x3,%eax
 48f:	cd 40                	int    $0x40
 491:	c3                   	ret

00000492 <pipe>:
SYSCALL(pipe)
 492:	b8 04 00 00 00       	mov    $0x4,%eax
 497:	cd 40                	int    $0x40
 499:	c3                   	ret

0000049a <read>:
SYSCALL(read)
 49a:	b8 05 00 00 00       	mov    $0x5,%eax
 49f:	cd 40                	int    $0x40
 4a1:	c3                   	ret

000004a2 <write>:
SYSCALL(write)
 4a2:	b8 10 00 00 00       	mov    $0x10,%eax
 4a7:	cd 40                	int    $0x40
 4a9:	c3                   	ret

000004aa <close>:
SYSCALL(close)
 4aa:	b8 15 00 00 00       	mov    $0x15,%eax
 4af:	cd 40                	int    $0x40
 4b1:	c3                   	ret

000004b2 <kill>:
SYSCALL(kill)
 4b2:	b8 06 00 00 00       	mov    $0x6,%eax
 4b7:	cd 40                	int    $0x40
 4b9:	c3                   	ret

000004ba <exec>:
SYSCALL(exec)
 4ba:	b8 07 00 00 00       	mov    $0x7,%eax
 4bf:	cd 40                	int    $0x40
 4c1:	c3                   	ret

000004c2 <open>:
SYSCALL(open)
 4c2:	b8 0f 00 00 00       	mov    $0xf,%eax
 4c7:	cd 40                	int    $0x40
 4c9:	c3                   	ret

000004ca <mknod>:
SYSCALL(mknod)
 4ca:	b8 11 00 00 00       	mov    $0x11,%eax
 4cf:	cd 40                	int    $0x40
 4d1:	c3                   	ret

000004d2 <unlink>:
SYSCALL(unlink)
 4d2:	b8 12 00 00 00       	mov    $0x12,%eax
 4d7:	cd 40                	int    $0x40
 4d9:	c3                   	ret

000004da <fstat>:
SYSCALL(fstat)
 4da:	b8 08 00 00 00       	mov    $0x8,%eax
 4df:	cd 40                	int    $0x40
 4e1:	c3                   	ret

000004e2 <link>:
SYSCALL(link)
 4e2:	b8 13 00 00 00       	mov    $0x13,%eax
 4e7:	cd 40                	int    $0x40
 4e9:	c3                   	ret

000004ea <mkdir>:
SYSCALL(mkdir)
 4ea:	b8 14 00 00 00       	mov    $0x14,%eax
 4ef:	cd 40                	int    $0x40
 4f1:	c3                   	ret

000004f2 <chdir>:
SYSCALL(chdir)
 4f2:	b8 09 00 00 00       	mov    $0x9,%eax
 4f7:	cd 40                	int    $0x40
 4f9:	c3                   	ret

000004fa <dup>:
SYSCALL(dup)
 4fa:	b8 0a 00 00 00       	mov    $0xa,%eax
 4ff:	cd 40                	int    $0x40
 501:	c3                   	ret

00000502 <getpid>:
SYSCALL(getpid)
 502:	b8 0b 00 00 00       	mov    $0xb,%eax
 507:	cd 40                	int    $0x40
 509:	c3                   	ret

0000050a <sbrk>:
SYSCALL(sbrk)
 50a:	b8 0c 00 00 00       	mov    $0xc,%eax
 50f:	cd 40                	int    $0x40
 511:	c3                   	ret

00000512 <sleep>:
SYSCALL(sleep)
 512:	b8 0d 00 00 00       	mov    $0xd,%eax
 517:	cd 40                	int    $0x40
 519:	c3                   	ret

0000051a <uptime>:
SYSCALL(uptime)
 51a:	b8 0e 00 00 00       	mov    $0xe,%eax
 51f:	cd 40                	int    $0x40
 521:	c3                   	ret

00000522 <uthread_init>:
SYSCALL(uthread_init)
 522:	b8 16 00 00 00       	mov    $0x16,%eax
 527:	cd 40                	int    $0x40
 529:	c3                   	ret

0000052a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 52a:	55                   	push   %ebp
 52b:	89 e5                	mov    %esp,%ebp
 52d:	83 ec 18             	sub    $0x18,%esp
 530:	8b 45 0c             	mov    0xc(%ebp),%eax
 533:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 536:	83 ec 04             	sub    $0x4,%esp
 539:	6a 01                	push   $0x1
 53b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 53e:	50                   	push   %eax
 53f:	ff 75 08             	push   0x8(%ebp)
 542:	e8 5b ff ff ff       	call   4a2 <write>
 547:	83 c4 10             	add    $0x10,%esp
}
 54a:	90                   	nop
 54b:	c9                   	leave
 54c:	c3                   	ret

0000054d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 54d:	55                   	push   %ebp
 54e:	89 e5                	mov    %esp,%ebp
 550:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 553:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 55a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 55e:	74 17                	je     577 <printint+0x2a>
 560:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 564:	79 11                	jns    577 <printint+0x2a>
    neg = 1;
 566:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 56d:	8b 45 0c             	mov    0xc(%ebp),%eax
 570:	f7 d8                	neg    %eax
 572:	89 45 ec             	mov    %eax,-0x14(%ebp)
 575:	eb 06                	jmp    57d <printint+0x30>
  } else {
    x = xx;
 577:	8b 45 0c             	mov    0xc(%ebp),%eax
 57a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 57d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 584:	8b 4d 10             	mov    0x10(%ebp),%ecx
 587:	8b 45 ec             	mov    -0x14(%ebp),%eax
 58a:	ba 00 00 00 00       	mov    $0x0,%edx
 58f:	f7 f1                	div    %ecx
 591:	89 d1                	mov    %edx,%ecx
 593:	8b 45 f4             	mov    -0xc(%ebp),%eax
 596:	8d 50 01             	lea    0x1(%eax),%edx
 599:	89 55 f4             	mov    %edx,-0xc(%ebp)
 59c:	0f b6 91 1c 0a 00 00 	movzbl 0xa1c(%ecx),%edx
 5a3:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 5a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5ad:	ba 00 00 00 00       	mov    $0x0,%edx
 5b2:	f7 f1                	div    %ecx
 5b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5b7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5bb:	75 c7                	jne    584 <printint+0x37>
  if(neg)
 5bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5c1:	74 2d                	je     5f0 <printint+0xa3>
    buf[i++] = '-';
 5c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c6:	8d 50 01             	lea    0x1(%eax),%edx
 5c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5cc:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5d1:	eb 1d                	jmp    5f0 <printint+0xa3>
    putc(fd, buf[i]);
 5d3:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d9:	01 d0                	add    %edx,%eax
 5db:	0f b6 00             	movzbl (%eax),%eax
 5de:	0f be c0             	movsbl %al,%eax
 5e1:	83 ec 08             	sub    $0x8,%esp
 5e4:	50                   	push   %eax
 5e5:	ff 75 08             	push   0x8(%ebp)
 5e8:	e8 3d ff ff ff       	call   52a <putc>
 5ed:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 5f0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5f8:	79 d9                	jns    5d3 <printint+0x86>
}
 5fa:	90                   	nop
 5fb:	90                   	nop
 5fc:	c9                   	leave
 5fd:	c3                   	ret

000005fe <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5fe:	55                   	push   %ebp
 5ff:	89 e5                	mov    %esp,%ebp
 601:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 604:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 60b:	8d 45 0c             	lea    0xc(%ebp),%eax
 60e:	83 c0 04             	add    $0x4,%eax
 611:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 614:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 61b:	e9 59 01 00 00       	jmp    779 <printf+0x17b>
    c = fmt[i] & 0xff;
 620:	8b 55 0c             	mov    0xc(%ebp),%edx
 623:	8b 45 f0             	mov    -0x10(%ebp),%eax
 626:	01 d0                	add    %edx,%eax
 628:	0f b6 00             	movzbl (%eax),%eax
 62b:	0f be c0             	movsbl %al,%eax
 62e:	25 ff 00 00 00       	and    $0xff,%eax
 633:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 636:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 63a:	75 2c                	jne    668 <printf+0x6a>
      if(c == '%'){
 63c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 640:	75 0c                	jne    64e <printf+0x50>
        state = '%';
 642:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 649:	e9 27 01 00 00       	jmp    775 <printf+0x177>
      } else {
        putc(fd, c);
 64e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 651:	0f be c0             	movsbl %al,%eax
 654:	83 ec 08             	sub    $0x8,%esp
 657:	50                   	push   %eax
 658:	ff 75 08             	push   0x8(%ebp)
 65b:	e8 ca fe ff ff       	call   52a <putc>
 660:	83 c4 10             	add    $0x10,%esp
 663:	e9 0d 01 00 00       	jmp    775 <printf+0x177>
      }
    } else if(state == '%'){
 668:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 66c:	0f 85 03 01 00 00    	jne    775 <printf+0x177>
      if(c == 'd'){
 672:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 676:	75 1e                	jne    696 <printf+0x98>
        printint(fd, *ap, 10, 1);
 678:	8b 45 e8             	mov    -0x18(%ebp),%eax
 67b:	8b 00                	mov    (%eax),%eax
 67d:	6a 01                	push   $0x1
 67f:	6a 0a                	push   $0xa
 681:	50                   	push   %eax
 682:	ff 75 08             	push   0x8(%ebp)
 685:	e8 c3 fe ff ff       	call   54d <printint>
 68a:	83 c4 10             	add    $0x10,%esp
        ap++;
 68d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 691:	e9 d8 00 00 00       	jmp    76e <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 696:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 69a:	74 06                	je     6a2 <printf+0xa4>
 69c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6a0:	75 1e                	jne    6c0 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 6a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6a5:	8b 00                	mov    (%eax),%eax
 6a7:	6a 00                	push   $0x0
 6a9:	6a 10                	push   $0x10
 6ab:	50                   	push   %eax
 6ac:	ff 75 08             	push   0x8(%ebp)
 6af:	e8 99 fe ff ff       	call   54d <printint>
 6b4:	83 c4 10             	add    $0x10,%esp
        ap++;
 6b7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6bb:	e9 ae 00 00 00       	jmp    76e <printf+0x170>
      } else if(c == 's'){
 6c0:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6c4:	75 43                	jne    709 <printf+0x10b>
        s = (char*)*ap;
 6c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c9:	8b 00                	mov    (%eax),%eax
 6cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6ce:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6d6:	75 25                	jne    6fd <printf+0xff>
          s = "(null)";
 6d8:	c7 45 f4 12 0a 00 00 	movl   $0xa12,-0xc(%ebp)
        while(*s != 0){
 6df:	eb 1c                	jmp    6fd <printf+0xff>
          putc(fd, *s);
 6e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e4:	0f b6 00             	movzbl (%eax),%eax
 6e7:	0f be c0             	movsbl %al,%eax
 6ea:	83 ec 08             	sub    $0x8,%esp
 6ed:	50                   	push   %eax
 6ee:	ff 75 08             	push   0x8(%ebp)
 6f1:	e8 34 fe ff ff       	call   52a <putc>
 6f6:	83 c4 10             	add    $0x10,%esp
          s++;
 6f9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 6fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 700:	0f b6 00             	movzbl (%eax),%eax
 703:	84 c0                	test   %al,%al
 705:	75 da                	jne    6e1 <printf+0xe3>
 707:	eb 65                	jmp    76e <printf+0x170>
        }
      } else if(c == 'c'){
 709:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 70d:	75 1d                	jne    72c <printf+0x12e>
        putc(fd, *ap);
 70f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 712:	8b 00                	mov    (%eax),%eax
 714:	0f be c0             	movsbl %al,%eax
 717:	83 ec 08             	sub    $0x8,%esp
 71a:	50                   	push   %eax
 71b:	ff 75 08             	push   0x8(%ebp)
 71e:	e8 07 fe ff ff       	call   52a <putc>
 723:	83 c4 10             	add    $0x10,%esp
        ap++;
 726:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 72a:	eb 42                	jmp    76e <printf+0x170>
      } else if(c == '%'){
 72c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 730:	75 17                	jne    749 <printf+0x14b>
        putc(fd, c);
 732:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 735:	0f be c0             	movsbl %al,%eax
 738:	83 ec 08             	sub    $0x8,%esp
 73b:	50                   	push   %eax
 73c:	ff 75 08             	push   0x8(%ebp)
 73f:	e8 e6 fd ff ff       	call   52a <putc>
 744:	83 c4 10             	add    $0x10,%esp
 747:	eb 25                	jmp    76e <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 749:	83 ec 08             	sub    $0x8,%esp
 74c:	6a 25                	push   $0x25
 74e:	ff 75 08             	push   0x8(%ebp)
 751:	e8 d4 fd ff ff       	call   52a <putc>
 756:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 759:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 75c:	0f be c0             	movsbl %al,%eax
 75f:	83 ec 08             	sub    $0x8,%esp
 762:	50                   	push   %eax
 763:	ff 75 08             	push   0x8(%ebp)
 766:	e8 bf fd ff ff       	call   52a <putc>
 76b:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 76e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 775:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 779:	8b 55 0c             	mov    0xc(%ebp),%edx
 77c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77f:	01 d0                	add    %edx,%eax
 781:	0f b6 00             	movzbl (%eax),%eax
 784:	84 c0                	test   %al,%al
 786:	0f 85 94 fe ff ff    	jne    620 <printf+0x22>
    }
  }
}
 78c:	90                   	nop
 78d:	90                   	nop
 78e:	c9                   	leave
 78f:	c3                   	ret

00000790 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 790:	55                   	push   %ebp
 791:	89 e5                	mov    %esp,%ebp
 793:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 796:	8b 45 08             	mov    0x8(%ebp),%eax
 799:	83 e8 08             	sub    $0x8,%eax
 79c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79f:	a1 88 8a 00 00       	mov    0x8a88,%eax
 7a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7a7:	eb 24                	jmp    7cd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ac:	8b 00                	mov    (%eax),%eax
 7ae:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 7b1:	72 12                	jb     7c5 <free+0x35>
 7b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b6:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 7b9:	72 24                	jb     7df <free+0x4f>
 7bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7be:	8b 00                	mov    (%eax),%eax
 7c0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7c3:	72 1a                	jb     7df <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c8:	8b 00                	mov    (%eax),%eax
 7ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d0:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 7d3:	73 d4                	jae    7a9 <free+0x19>
 7d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d8:	8b 00                	mov    (%eax),%eax
 7da:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7dd:	73 ca                	jae    7a9 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e2:	8b 40 04             	mov    0x4(%eax),%eax
 7e5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ef:	01 c2                	add    %eax,%edx
 7f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f4:	8b 00                	mov    (%eax),%eax
 7f6:	39 c2                	cmp    %eax,%edx
 7f8:	75 24                	jne    81e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fd:	8b 50 04             	mov    0x4(%eax),%edx
 800:	8b 45 fc             	mov    -0x4(%ebp),%eax
 803:	8b 00                	mov    (%eax),%eax
 805:	8b 40 04             	mov    0x4(%eax),%eax
 808:	01 c2                	add    %eax,%edx
 80a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 810:	8b 45 fc             	mov    -0x4(%ebp),%eax
 813:	8b 00                	mov    (%eax),%eax
 815:	8b 10                	mov    (%eax),%edx
 817:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81a:	89 10                	mov    %edx,(%eax)
 81c:	eb 0a                	jmp    828 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 81e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 821:	8b 10                	mov    (%eax),%edx
 823:	8b 45 f8             	mov    -0x8(%ebp),%eax
 826:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 828:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82b:	8b 40 04             	mov    0x4(%eax),%eax
 82e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 835:	8b 45 fc             	mov    -0x4(%ebp),%eax
 838:	01 d0                	add    %edx,%eax
 83a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 83d:	75 20                	jne    85f <free+0xcf>
    p->s.size += bp->s.size;
 83f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 842:	8b 50 04             	mov    0x4(%eax),%edx
 845:	8b 45 f8             	mov    -0x8(%ebp),%eax
 848:	8b 40 04             	mov    0x4(%eax),%eax
 84b:	01 c2                	add    %eax,%edx
 84d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 850:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 853:	8b 45 f8             	mov    -0x8(%ebp),%eax
 856:	8b 10                	mov    (%eax),%edx
 858:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85b:	89 10                	mov    %edx,(%eax)
 85d:	eb 08                	jmp    867 <free+0xd7>
  } else
    p->s.ptr = bp;
 85f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 862:	8b 55 f8             	mov    -0x8(%ebp),%edx
 865:	89 10                	mov    %edx,(%eax)
  freep = p;
 867:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86a:	a3 88 8a 00 00       	mov    %eax,0x8a88
}
 86f:	90                   	nop
 870:	c9                   	leave
 871:	c3                   	ret

00000872 <morecore>:

static Header*
morecore(uint nu)
{
 872:	55                   	push   %ebp
 873:	89 e5                	mov    %esp,%ebp
 875:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 878:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 87f:	77 07                	ja     888 <morecore+0x16>
    nu = 4096;
 881:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 888:	8b 45 08             	mov    0x8(%ebp),%eax
 88b:	c1 e0 03             	shl    $0x3,%eax
 88e:	83 ec 0c             	sub    $0xc,%esp
 891:	50                   	push   %eax
 892:	e8 73 fc ff ff       	call   50a <sbrk>
 897:	83 c4 10             	add    $0x10,%esp
 89a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 89d:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8a1:	75 07                	jne    8aa <morecore+0x38>
    return 0;
 8a3:	b8 00 00 00 00       	mov    $0x0,%eax
 8a8:	eb 26                	jmp    8d0 <morecore+0x5e>
  hp = (Header*)p;
 8aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b3:	8b 55 08             	mov    0x8(%ebp),%edx
 8b6:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8bc:	83 c0 08             	add    $0x8,%eax
 8bf:	83 ec 0c             	sub    $0xc,%esp
 8c2:	50                   	push   %eax
 8c3:	e8 c8 fe ff ff       	call   790 <free>
 8c8:	83 c4 10             	add    $0x10,%esp
  return freep;
 8cb:	a1 88 8a 00 00       	mov    0x8a88,%eax
}
 8d0:	c9                   	leave
 8d1:	c3                   	ret

000008d2 <malloc>:

void*
malloc(uint nbytes)
{
 8d2:	55                   	push   %ebp
 8d3:	89 e5                	mov    %esp,%ebp
 8d5:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d8:	8b 45 08             	mov    0x8(%ebp),%eax
 8db:	83 c0 07             	add    $0x7,%eax
 8de:	c1 e8 03             	shr    $0x3,%eax
 8e1:	83 c0 01             	add    $0x1,%eax
 8e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8e7:	a1 88 8a 00 00       	mov    0x8a88,%eax
 8ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8f3:	75 23                	jne    918 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8f5:	c7 45 f0 80 8a 00 00 	movl   $0x8a80,-0x10(%ebp)
 8fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ff:	a3 88 8a 00 00       	mov    %eax,0x8a88
 904:	a1 88 8a 00 00       	mov    0x8a88,%eax
 909:	a3 80 8a 00 00       	mov    %eax,0x8a80
    base.s.size = 0;
 90e:	c7 05 84 8a 00 00 00 	movl   $0x0,0x8a84
 915:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 918:	8b 45 f0             	mov    -0x10(%ebp),%eax
 91b:	8b 00                	mov    (%eax),%eax
 91d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 920:	8b 45 f4             	mov    -0xc(%ebp),%eax
 923:	8b 40 04             	mov    0x4(%eax),%eax
 926:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 929:	72 4d                	jb     978 <malloc+0xa6>
      if(p->s.size == nunits)
 92b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92e:	8b 40 04             	mov    0x4(%eax),%eax
 931:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 934:	75 0c                	jne    942 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 936:	8b 45 f4             	mov    -0xc(%ebp),%eax
 939:	8b 10                	mov    (%eax),%edx
 93b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93e:	89 10                	mov    %edx,(%eax)
 940:	eb 26                	jmp    968 <malloc+0x96>
      else {
        p->s.size -= nunits;
 942:	8b 45 f4             	mov    -0xc(%ebp),%eax
 945:	8b 40 04             	mov    0x4(%eax),%eax
 948:	2b 45 ec             	sub    -0x14(%ebp),%eax
 94b:	89 c2                	mov    %eax,%edx
 94d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 950:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 953:	8b 45 f4             	mov    -0xc(%ebp),%eax
 956:	8b 40 04             	mov    0x4(%eax),%eax
 959:	c1 e0 03             	shl    $0x3,%eax
 95c:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 95f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 962:	8b 55 ec             	mov    -0x14(%ebp),%edx
 965:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 968:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96b:	a3 88 8a 00 00       	mov    %eax,0x8a88
      return (void*)(p + 1);
 970:	8b 45 f4             	mov    -0xc(%ebp),%eax
 973:	83 c0 08             	add    $0x8,%eax
 976:	eb 3b                	jmp    9b3 <malloc+0xe1>
    }
    if(p == freep)
 978:	a1 88 8a 00 00       	mov    0x8a88,%eax
 97d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 980:	75 1e                	jne    9a0 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 982:	83 ec 0c             	sub    $0xc,%esp
 985:	ff 75 ec             	push   -0x14(%ebp)
 988:	e8 e5 fe ff ff       	call   872 <morecore>
 98d:	83 c4 10             	add    $0x10,%esp
 990:	89 45 f4             	mov    %eax,-0xc(%ebp)
 993:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 997:	75 07                	jne    9a0 <malloc+0xce>
        return 0;
 999:	b8 00 00 00 00       	mov    $0x0,%eax
 99e:	eb 13                	jmp    9b3 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a9:	8b 00                	mov    (%eax),%eax
 9ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9ae:	e9 6d ff ff ff       	jmp    920 <malloc+0x4e>
  }
}
 9b3:	c9                   	leave
 9b4:	c3                   	ret
