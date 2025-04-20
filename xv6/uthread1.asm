
_uthread1:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_init>:
static void thread_schedule(void);

// thread_init: 스레드 초기화 함수
void 
thread_init(void)
{
   0:	f3 0f 1e fb          	endbr32
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 ec 08             	sub    $0x8,%esp
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  // main()으로 쓰기 때문에 미리 쓰레드 0을 RUNNING 상태로 만들어 놓는다.
  current_thread = &all_thread[0];
   a:	c7 05 0c 8e 00 00 e0 	movl   $0xde0,0x8e0c
  11:	0d 00 00 
  current_thread->state = RUNNING;
  14:	a1 0c 8e 00 00       	mov    0x8e0c,%eax
  19:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  20:	00 00 00 

  // System call
  // uthread_init()을 통해서 thread_schedule의 주소를 넘겨준다.
  // uthread_init()은 syscall.c에 정의되어 있다.
  uthread_init((int)thread_schedule);
  23:	b8 37 00 00 00       	mov    $0x37,%eax
  28:	83 ec 0c             	sub    $0xc,%esp
  2b:	50                   	push   %eax
  2c:	e8 a2 05 00 00       	call   5d3 <uthread_init>
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
  41:	c7 05 10 8e 00 00 00 	movl   $0x0,0x8e10
  48:	00 00 00 

  
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  4b:	c7 45 f4 e0 0d 00 00 	movl   $0xde0,-0xc(%ebp)
  52:	eb 41                	jmp    95 <thread_schedule+0x5e>
    // all_thread[0]은 main()이기 때문에 한 번 switch를 했으면 건너 뜀.
    if(t == &all_thread[0] && t->state == RUNNABLE){
  54:	81 7d f4 e0 0d 00 00 	cmpl   $0xde0,-0xc(%ebp)
  5b:	75 0e                	jne    6b <thread_schedule+0x34>
  5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  60:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  66:	83 f8 02             	cmp    $0x2,%eax
  69:	74 22                	je     8d <thread_schedule+0x56>
      continue;
    }
    // RUNNABLE 상태인 스레드가 있으면 next_thread에 저장
    if (t->state == RUNNABLE && t != current_thread) {
  6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6e:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  74:	83 f8 02             	cmp    $0x2,%eax
  77:	75 15                	jne    8e <thread_schedule+0x57>
  79:	a1 0c 8e 00 00       	mov    0x8e0c,%eax
  7e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  81:	74 0b                	je     8e <thread_schedule+0x57>
      next_thread = t;
  83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  86:	a3 10 8e 00 00       	mov    %eax,0x8e10
      break;
  8b:	eb 12                	jmp    9f <thread_schedule+0x68>
      continue;
  8d:	90                   	nop
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  8e:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  95:	b8 00 8e 00 00       	mov    $0x8e00,%eax
  9a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  9d:	72 b5                	jb     54 <thread_schedule+0x1d>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  9f:	b8 00 8e 00 00       	mov    $0x8e00,%eax
  a4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  a7:	72 1a                	jb     c3 <thread_schedule+0x8c>
  a9:	a1 0c 8e 00 00       	mov    0x8e0c,%eax
  ae:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  b4:	83 f8 02             	cmp    $0x2,%eax
  b7:	75 0a                	jne    c3 <thread_schedule+0x8c>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  b9:	a1 0c 8e 00 00       	mov    0x8e0c,%eax
  be:	a3 10 8e 00 00       	mov    %eax,0x8e10
  }

  // runnable thread가 없으면 exit
  if (next_thread == 0) {
  c3:	a1 10 8e 00 00       	mov    0x8e10,%eax
  c8:	85 c0                	test   %eax,%eax
  ca:	75 27                	jne    f3 <thread_schedule+0xbc>
    // current_thread가 RUNNING 상태이면 현재 쓰레드가 유일한 쓰레드이므로
    // 스케줄링을 하지 않고 그냥 리턴
    if (current_thread->state == RUNNING) return;
  cc:	a1 0c 8e 00 00       	mov    0x8e0c,%eax
  d1:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  d7:	83 f8 01             	cmp    $0x1,%eax
  da:	74 67                	je     143 <thread_schedule+0x10c>
    // 쓰레드가 없으면 exit
    printf(2, "thread_schedule: no runnable threads\n");
  dc:	83 ec 08             	sub    $0x8,%esp
  df:	68 88 0a 00 00       	push   $0xa88
  e4:	6a 02                	push   $0x2
  e6:	e8 d4 05 00 00       	call   6bf <printf>
  eb:	83 c4 10             	add    $0x10,%esp
    exit();
  ee:	e8 40 04 00 00       	call   533 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  f3:	8b 15 0c 8e 00 00    	mov    0x8e0c,%edx
  f9:	a1 10 8e 00 00       	mov    0x8e10,%eax
  fe:	39 c2                	cmp    %eax,%edx
 100:	74 35                	je     137 <thread_schedule+0x100>
    next_thread->state = RUNNING;
 102:	a1 10 8e 00 00       	mov    0x8e10,%eax
 107:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 10e:	00 00 00 
    // current_thread가 RUNNING 상태이면 RUNNABLE로 바꿔준다.
    if (current_thread->state == RUNNING) current_thread->state = RUNNABLE;
 111:	a1 0c 8e 00 00       	mov    0x8e0c,%eax
 116:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 11c:	83 f8 01             	cmp    $0x1,%eax
 11f:	75 0f                	jne    130 <thread_schedule+0xf9>
 121:	a1 0c 8e 00 00       	mov    0x8e0c,%eax
 126:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 12d:	00 00 00 
    // context switch
    thread_switch();
 130:	e8 63 01 00 00       	call   298 <thread_switch>
 135:	eb 0d                	jmp    144 <thread_schedule+0x10d>
  } else
    next_thread = 0;
 137:	c7 05 10 8e 00 00 00 	movl   $0x0,0x8e10
 13e:	00 00 00 
 141:	eb 01                	jmp    144 <thread_schedule+0x10d>
    if (current_thread->state == RUNNING) return;
 143:	90                   	nop
}
 144:	c9                   	leave
 145:	c3                   	ret

00000146 <thread_create>:

// thread_create: 스레드 생성 함수
void 
thread_create(void (*func)())
{
 146:	f3 0f 1e fb          	endbr32
 14a:	55                   	push   %ebp
 14b:	89 e5                	mov    %esp,%ebp
 14d:	83 ec 18             	sub    $0x18,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 150:	c7 45 f4 e0 0d 00 00 	movl   $0xde0,-0xc(%ebp)
 157:	eb 14                	jmp    16d <thread_create+0x27>
    if (t->state == FREE) break;
 159:	8b 45 f4             	mov    -0xc(%ebp),%eax
 15c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 162:	85 c0                	test   %eax,%eax
 164:	74 13                	je     179 <thread_create+0x33>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 166:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 16d:	b8 00 8e 00 00       	mov    $0x8e00,%eax
 172:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 175:	72 e2                	jb     159 <thread_create+0x13>
 177:	eb 01                	jmp    17a <thread_create+0x34>
    if (t->state == FREE) break;
 179:	90                   	nop
  }
  // 스택 포인터 = 스택의 top frame
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 17a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17d:	83 c0 04             	add    $0x4,%eax
 180:	05 00 20 00 00       	add    $0x2000,%eax
 185:	89 c2                	mov    %eax,%edx
 187:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18a:	89 10                	mov    %edx,(%eax)
  // 스택 포인터를 4byte 만큼 줄여서 리턴 주소를 저장할 공간을 만든다.
  t->sp -= 4;                              // space for return address
 18c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18f:	8b 00                	mov    (%eax),%eax
 191:	8d 50 fc             	lea    -0x4(%eax),%edx
 194:	8b 45 f4             	mov    -0xc(%ebp),%eax
 197:	89 10                	mov    %edx,(%eax)
  // mythread 함수를 리턴 주소로 저장
  * (int *) (t->sp) = (int)func;           // push return address on stack
 199:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19c:	8b 00                	mov    (%eax),%eax
 19e:	89 c2                	mov    %eax,%edx
 1a0:	8b 45 08             	mov    0x8(%ebp),%eax
 1a3:	89 02                	mov    %eax,(%edx)
  // 레지스터를 위한 공간
  t->sp -= 32;                             // space for registers that thread_switch expects
 1a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a8:	8b 00                	mov    (%eax),%eax
 1aa:	8d 50 e0             	lea    -0x20(%eax),%edx
 1ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b0:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 1b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b5:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1bc:	00 00 00 
  thread_count(1);
 1bf:	83 ec 0c             	sub    $0xc,%esp
 1c2:	6a 01                	push   $0x1
 1c4:	e8 12 04 00 00       	call   5db <thread_count>
 1c9:	83 c4 10             	add    $0x10,%esp
}
 1cc:	90                   	nop
 1cd:	c9                   	leave
 1ce:	c3                   	ret

000001cf <mythread>:

static void 
mythread(void)
{
 1cf:	f3 0f 1e fb          	endbr32
 1d3:	55                   	push   %ebp
 1d4:	89 e5                	mov    %esp,%ebp
 1d6:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 1d9:	83 ec 08             	sub    $0x8,%esp
 1dc:	68 ae 0a 00 00       	push   $0xaae
 1e1:	6a 01                	push   $0x1
 1e3:	e8 d7 04 00 00       	call   6bf <printf>
 1e8:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1f2:	eb 1c                	jmp    210 <mythread+0x41>
    printf(1, "i:%d, my thread 0x%x\n", i, (int) current_thread);
 1f4:	a1 0c 8e 00 00       	mov    0x8e0c,%eax
 1f9:	50                   	push   %eax
 1fa:	ff 75 f4             	push   -0xc(%ebp)
 1fd:	68 c1 0a 00 00       	push   $0xac1
 202:	6a 01                	push   $0x1
 204:	e8 b6 04 00 00       	call   6bf <printf>
 209:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 20c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 210:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 214:	7e de                	jle    1f4 <mythread+0x25>
  }
  printf(1, "my thread: exit\n");
 216:	83 ec 08             	sub    $0x8,%esp
 219:	68 d7 0a 00 00       	push   $0xad7
 21e:	6a 01                	push   $0x1
 220:	e8 9a 04 00 00       	call   6bf <printf>
 225:	83 c4 10             	add    $0x10,%esp
  // 쓰레드가 종료되면 쓰레드 상태를 FREE로 바꿔준다.
  current_thread->state = FREE;
 228:	a1 0c 8e 00 00       	mov    0x8e0c,%eax
 22d:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 234:	00 00 00 
  thread_count(-1);
 237:	83 ec 0c             	sub    $0xc,%esp
 23a:	6a ff                	push   $0xffffffff
 23c:	e8 9a 03 00 00       	call   5db <thread_count>
 241:	83 c4 10             	add    $0x10,%esp
    
  // 현재 쓰레드가 종료 되었기 때문에 스케줄링
  thread_schedule();
 244:	e8 ee fd ff ff       	call   37 <thread_schedule>
}
 249:	90                   	nop
 24a:	c9                   	leave
 24b:	c3                   	ret

0000024c <main>:


int 
main(int argc, char *argv[]) 
{
 24c:	f3 0f 1e fb          	endbr32
 250:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 254:	83 e4 f0             	and    $0xfffffff0,%esp
 257:	ff 71 fc             	push   -0x4(%ecx)
 25a:	55                   	push   %ebp
 25b:	89 e5                	mov    %esp,%ebp
 25d:	51                   	push   %ecx
 25e:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 261:	e8 9a fd ff ff       	call   0 <thread_init>
  thread_create(mythread);
 266:	83 ec 0c             	sub    $0xc,%esp
 269:	68 cf 01 00 00       	push   $0x1cf
 26e:	e8 d3 fe ff ff       	call   146 <thread_create>
 273:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 276:	83 ec 0c             	sub    $0xc,%esp
 279:	68 cf 01 00 00       	push   $0x1cf
 27e:	e8 c3 fe ff ff       	call   146 <thread_create>
 283:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 286:	e8 ac fd ff ff       	call   37 <thread_schedule>
  return 0;
 28b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 290:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 293:	c9                   	leave
 294:	8d 61 fc             	lea    -0x4(%ecx),%esp
 297:	c3                   	ret

00000298 <thread_switch>:
         */
    .text
    .globl thread_switch
thread_switch:
    // 레지스터 저장
    pushal
 298:	60                   	pusha

    // eax에 current_thread 저장
    // esp에 바로 못넘김
    movl current_thread, %eax
 299:	a1 0c 8e 00 00       	mov    0x8e0c,%eax
    // current_thread = esp
    // esp에는 전에 저장해놨던 thread의 주소가 있음
    movl %esp, (%eax)
 29e:	89 20                	mov    %esp,(%eax)

    // 다음 실행할 쓰레드 저장 eax에 담아서 esp에 저장
    movl next_thread, %eax
 2a0:	a1 10 8e 00 00       	mov    0x8e10,%eax
    movl (%eax), %esp
 2a5:	8b 20                	mov    (%eax),%esp

    // current_thread = next_thread
    movl %eax, current_thread
 2a7:	a3 0c 8e 00 00       	mov    %eax,0x8e0c

    // 레지스터 복구
    popal
 2ac:	61                   	popa

    // next_thread = 0
    movl $0, next_thread
 2ad:	c7 05 10 8e 00 00 00 	movl   $0x0,0x8e10
 2b4:	00 00 00 
    
    // 다시 원래 실행하던 곳으로 점프
    // esp에 next_thread주소를 넣고 current_thread와 next_thread를 바꿔놓았기 때문에
    // contextSwitching이 된 상태로 돌아간다.
    ret   
 2b7:	c3                   	ret

000002b8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2b8:	55                   	push   %ebp
 2b9:	89 e5                	mov    %esp,%ebp
 2bb:	57                   	push   %edi
 2bc:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2c0:	8b 55 10             	mov    0x10(%ebp),%edx
 2c3:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c6:	89 cb                	mov    %ecx,%ebx
 2c8:	89 df                	mov    %ebx,%edi
 2ca:	89 d1                	mov    %edx,%ecx
 2cc:	fc                   	cld
 2cd:	f3 aa                	rep stos %al,%es:(%edi)
 2cf:	89 ca                	mov    %ecx,%edx
 2d1:	89 fb                	mov    %edi,%ebx
 2d3:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2d6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2d9:	90                   	nop
 2da:	5b                   	pop    %ebx
 2db:	5f                   	pop    %edi
 2dc:	5d                   	pop    %ebp
 2dd:	c3                   	ret

000002de <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2de:	f3 0f 1e fb          	endbr32
 2e2:	55                   	push   %ebp
 2e3:	89 e5                	mov    %esp,%ebp
 2e5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2e8:	8b 45 08             	mov    0x8(%ebp),%eax
 2eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2ee:	90                   	nop
 2ef:	8b 55 0c             	mov    0xc(%ebp),%edx
 2f2:	8d 42 01             	lea    0x1(%edx),%eax
 2f5:	89 45 0c             	mov    %eax,0xc(%ebp)
 2f8:	8b 45 08             	mov    0x8(%ebp),%eax
 2fb:	8d 48 01             	lea    0x1(%eax),%ecx
 2fe:	89 4d 08             	mov    %ecx,0x8(%ebp)
 301:	0f b6 12             	movzbl (%edx),%edx
 304:	88 10                	mov    %dl,(%eax)
 306:	0f b6 00             	movzbl (%eax),%eax
 309:	84 c0                	test   %al,%al
 30b:	75 e2                	jne    2ef <strcpy+0x11>
    ;
  return os;
 30d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 310:	c9                   	leave
 311:	c3                   	ret

00000312 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 312:	f3 0f 1e fb          	endbr32
 316:	55                   	push   %ebp
 317:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 319:	eb 08                	jmp    323 <strcmp+0x11>
    p++, q++;
 31b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 31f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	0f b6 00             	movzbl (%eax),%eax
 329:	84 c0                	test   %al,%al
 32b:	74 10                	je     33d <strcmp+0x2b>
 32d:	8b 45 08             	mov    0x8(%ebp),%eax
 330:	0f b6 10             	movzbl (%eax),%edx
 333:	8b 45 0c             	mov    0xc(%ebp),%eax
 336:	0f b6 00             	movzbl (%eax),%eax
 339:	38 c2                	cmp    %al,%dl
 33b:	74 de                	je     31b <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 33d:	8b 45 08             	mov    0x8(%ebp),%eax
 340:	0f b6 00             	movzbl (%eax),%eax
 343:	0f b6 d0             	movzbl %al,%edx
 346:	8b 45 0c             	mov    0xc(%ebp),%eax
 349:	0f b6 00             	movzbl (%eax),%eax
 34c:	0f b6 c0             	movzbl %al,%eax
 34f:	29 c2                	sub    %eax,%edx
 351:	89 d0                	mov    %edx,%eax
}
 353:	5d                   	pop    %ebp
 354:	c3                   	ret

00000355 <strlen>:

uint
strlen(char *s)
{
 355:	f3 0f 1e fb          	endbr32
 359:	55                   	push   %ebp
 35a:	89 e5                	mov    %esp,%ebp
 35c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 35f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 366:	eb 04                	jmp    36c <strlen+0x17>
 368:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 36c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 36f:	8b 45 08             	mov    0x8(%ebp),%eax
 372:	01 d0                	add    %edx,%eax
 374:	0f b6 00             	movzbl (%eax),%eax
 377:	84 c0                	test   %al,%al
 379:	75 ed                	jne    368 <strlen+0x13>
    ;
  return n;
 37b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 37e:	c9                   	leave
 37f:	c3                   	ret

00000380 <memset>:

void*
memset(void *dst, int c, uint n)
{
 380:	f3 0f 1e fb          	endbr32
 384:	55                   	push   %ebp
 385:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 387:	8b 45 10             	mov    0x10(%ebp),%eax
 38a:	50                   	push   %eax
 38b:	ff 75 0c             	push   0xc(%ebp)
 38e:	ff 75 08             	push   0x8(%ebp)
 391:	e8 22 ff ff ff       	call   2b8 <stosb>
 396:	83 c4 0c             	add    $0xc,%esp
  return dst;
 399:	8b 45 08             	mov    0x8(%ebp),%eax
}
 39c:	c9                   	leave
 39d:	c3                   	ret

0000039e <strchr>:

char*
strchr(const char *s, char c)
{
 39e:	f3 0f 1e fb          	endbr32
 3a2:	55                   	push   %ebp
 3a3:	89 e5                	mov    %esp,%ebp
 3a5:	83 ec 04             	sub    $0x4,%esp
 3a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ab:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3ae:	eb 14                	jmp    3c4 <strchr+0x26>
    if(*s == c)
 3b0:	8b 45 08             	mov    0x8(%ebp),%eax
 3b3:	0f b6 00             	movzbl (%eax),%eax
 3b6:	38 45 fc             	cmp    %al,-0x4(%ebp)
 3b9:	75 05                	jne    3c0 <strchr+0x22>
      return (char*)s;
 3bb:	8b 45 08             	mov    0x8(%ebp),%eax
 3be:	eb 13                	jmp    3d3 <strchr+0x35>
  for(; *s; s++)
 3c0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3c4:	8b 45 08             	mov    0x8(%ebp),%eax
 3c7:	0f b6 00             	movzbl (%eax),%eax
 3ca:	84 c0                	test   %al,%al
 3cc:	75 e2                	jne    3b0 <strchr+0x12>
  return 0;
 3ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3d3:	c9                   	leave
 3d4:	c3                   	ret

000003d5 <gets>:

char*
gets(char *buf, int max)
{
 3d5:	f3 0f 1e fb          	endbr32
 3d9:	55                   	push   %ebp
 3da:	89 e5                	mov    %esp,%ebp
 3dc:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3e6:	eb 42                	jmp    42a <gets+0x55>
    cc = read(0, &c, 1);
 3e8:	83 ec 04             	sub    $0x4,%esp
 3eb:	6a 01                	push   $0x1
 3ed:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3f0:	50                   	push   %eax
 3f1:	6a 00                	push   $0x0
 3f3:	e8 53 01 00 00       	call   54b <read>
 3f8:	83 c4 10             	add    $0x10,%esp
 3fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 402:	7e 33                	jle    437 <gets+0x62>
      break;
    buf[i++] = c;
 404:	8b 45 f4             	mov    -0xc(%ebp),%eax
 407:	8d 50 01             	lea    0x1(%eax),%edx
 40a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 40d:	89 c2                	mov    %eax,%edx
 40f:	8b 45 08             	mov    0x8(%ebp),%eax
 412:	01 c2                	add    %eax,%edx
 414:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 418:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 41a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 41e:	3c 0a                	cmp    $0xa,%al
 420:	74 16                	je     438 <gets+0x63>
 422:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 426:	3c 0d                	cmp    $0xd,%al
 428:	74 0e                	je     438 <gets+0x63>
  for(i=0; i+1 < max; ){
 42a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 42d:	83 c0 01             	add    $0x1,%eax
 430:	39 45 0c             	cmp    %eax,0xc(%ebp)
 433:	7f b3                	jg     3e8 <gets+0x13>
 435:	eb 01                	jmp    438 <gets+0x63>
      break;
 437:	90                   	nop
      break;
  }
  buf[i] = '\0';
 438:	8b 55 f4             	mov    -0xc(%ebp),%edx
 43b:	8b 45 08             	mov    0x8(%ebp),%eax
 43e:	01 d0                	add    %edx,%eax
 440:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 443:	8b 45 08             	mov    0x8(%ebp),%eax
}
 446:	c9                   	leave
 447:	c3                   	ret

00000448 <stat>:

int
stat(char *n, struct stat *st)
{
 448:	f3 0f 1e fb          	endbr32
 44c:	55                   	push   %ebp
 44d:	89 e5                	mov    %esp,%ebp
 44f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 452:	83 ec 08             	sub    $0x8,%esp
 455:	6a 00                	push   $0x0
 457:	ff 75 08             	push   0x8(%ebp)
 45a:	e8 14 01 00 00       	call   573 <open>
 45f:	83 c4 10             	add    $0x10,%esp
 462:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 465:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 469:	79 07                	jns    472 <stat+0x2a>
    return -1;
 46b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 470:	eb 25                	jmp    497 <stat+0x4f>
  r = fstat(fd, st);
 472:	83 ec 08             	sub    $0x8,%esp
 475:	ff 75 0c             	push   0xc(%ebp)
 478:	ff 75 f4             	push   -0xc(%ebp)
 47b:	e8 0b 01 00 00       	call   58b <fstat>
 480:	83 c4 10             	add    $0x10,%esp
 483:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 486:	83 ec 0c             	sub    $0xc,%esp
 489:	ff 75 f4             	push   -0xc(%ebp)
 48c:	e8 ca 00 00 00       	call   55b <close>
 491:	83 c4 10             	add    $0x10,%esp
  return r;
 494:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 497:	c9                   	leave
 498:	c3                   	ret

00000499 <atoi>:

int
atoi(const char *s)
{
 499:	f3 0f 1e fb          	endbr32
 49d:	55                   	push   %ebp
 49e:	89 e5                	mov    %esp,%ebp
 4a0:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4a3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4aa:	eb 25                	jmp    4d1 <atoi+0x38>
    n = n*10 + *s++ - '0';
 4ac:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4af:	89 d0                	mov    %edx,%eax
 4b1:	c1 e0 02             	shl    $0x2,%eax
 4b4:	01 d0                	add    %edx,%eax
 4b6:	01 c0                	add    %eax,%eax
 4b8:	89 c1                	mov    %eax,%ecx
 4ba:	8b 45 08             	mov    0x8(%ebp),%eax
 4bd:	8d 50 01             	lea    0x1(%eax),%edx
 4c0:	89 55 08             	mov    %edx,0x8(%ebp)
 4c3:	0f b6 00             	movzbl (%eax),%eax
 4c6:	0f be c0             	movsbl %al,%eax
 4c9:	01 c8                	add    %ecx,%eax
 4cb:	83 e8 30             	sub    $0x30,%eax
 4ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4d1:	8b 45 08             	mov    0x8(%ebp),%eax
 4d4:	0f b6 00             	movzbl (%eax),%eax
 4d7:	3c 2f                	cmp    $0x2f,%al
 4d9:	7e 0a                	jle    4e5 <atoi+0x4c>
 4db:	8b 45 08             	mov    0x8(%ebp),%eax
 4de:	0f b6 00             	movzbl (%eax),%eax
 4e1:	3c 39                	cmp    $0x39,%al
 4e3:	7e c7                	jle    4ac <atoi+0x13>
  return n;
 4e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4e8:	c9                   	leave
 4e9:	c3                   	ret

000004ea <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4ea:	f3 0f 1e fb          	endbr32
 4ee:	55                   	push   %ebp
 4ef:	89 e5                	mov    %esp,%ebp
 4f1:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 4f4:	8b 45 08             	mov    0x8(%ebp),%eax
 4f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 4fd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 500:	eb 17                	jmp    519 <memmove+0x2f>
    *dst++ = *src++;
 502:	8b 55 f8             	mov    -0x8(%ebp),%edx
 505:	8d 42 01             	lea    0x1(%edx),%eax
 508:	89 45 f8             	mov    %eax,-0x8(%ebp)
 50b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 50e:	8d 48 01             	lea    0x1(%eax),%ecx
 511:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 514:	0f b6 12             	movzbl (%edx),%edx
 517:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 519:	8b 45 10             	mov    0x10(%ebp),%eax
 51c:	8d 50 ff             	lea    -0x1(%eax),%edx
 51f:	89 55 10             	mov    %edx,0x10(%ebp)
 522:	85 c0                	test   %eax,%eax
 524:	7f dc                	jg     502 <memmove+0x18>
  return vdst;
 526:	8b 45 08             	mov    0x8(%ebp),%eax
}
 529:	c9                   	leave
 52a:	c3                   	ret

0000052b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 52b:	b8 01 00 00 00       	mov    $0x1,%eax
 530:	cd 40                	int    $0x40
 532:	c3                   	ret

00000533 <exit>:
SYSCALL(exit)
 533:	b8 02 00 00 00       	mov    $0x2,%eax
 538:	cd 40                	int    $0x40
 53a:	c3                   	ret

0000053b <wait>:
SYSCALL(wait)
 53b:	b8 03 00 00 00       	mov    $0x3,%eax
 540:	cd 40                	int    $0x40
 542:	c3                   	ret

00000543 <pipe>:
SYSCALL(pipe)
 543:	b8 04 00 00 00       	mov    $0x4,%eax
 548:	cd 40                	int    $0x40
 54a:	c3                   	ret

0000054b <read>:
SYSCALL(read)
 54b:	b8 05 00 00 00       	mov    $0x5,%eax
 550:	cd 40                	int    $0x40
 552:	c3                   	ret

00000553 <write>:
SYSCALL(write)
 553:	b8 10 00 00 00       	mov    $0x10,%eax
 558:	cd 40                	int    $0x40
 55a:	c3                   	ret

0000055b <close>:
SYSCALL(close)
 55b:	b8 15 00 00 00       	mov    $0x15,%eax
 560:	cd 40                	int    $0x40
 562:	c3                   	ret

00000563 <kill>:
SYSCALL(kill)
 563:	b8 06 00 00 00       	mov    $0x6,%eax
 568:	cd 40                	int    $0x40
 56a:	c3                   	ret

0000056b <exec>:
SYSCALL(exec)
 56b:	b8 07 00 00 00       	mov    $0x7,%eax
 570:	cd 40                	int    $0x40
 572:	c3                   	ret

00000573 <open>:
SYSCALL(open)
 573:	b8 0f 00 00 00       	mov    $0xf,%eax
 578:	cd 40                	int    $0x40
 57a:	c3                   	ret

0000057b <mknod>:
SYSCALL(mknod)
 57b:	b8 11 00 00 00       	mov    $0x11,%eax
 580:	cd 40                	int    $0x40
 582:	c3                   	ret

00000583 <unlink>:
SYSCALL(unlink)
 583:	b8 12 00 00 00       	mov    $0x12,%eax
 588:	cd 40                	int    $0x40
 58a:	c3                   	ret

0000058b <fstat>:
SYSCALL(fstat)
 58b:	b8 08 00 00 00       	mov    $0x8,%eax
 590:	cd 40                	int    $0x40
 592:	c3                   	ret

00000593 <link>:
SYSCALL(link)
 593:	b8 13 00 00 00       	mov    $0x13,%eax
 598:	cd 40                	int    $0x40
 59a:	c3                   	ret

0000059b <mkdir>:
SYSCALL(mkdir)
 59b:	b8 14 00 00 00       	mov    $0x14,%eax
 5a0:	cd 40                	int    $0x40
 5a2:	c3                   	ret

000005a3 <chdir>:
SYSCALL(chdir)
 5a3:	b8 09 00 00 00       	mov    $0x9,%eax
 5a8:	cd 40                	int    $0x40
 5aa:	c3                   	ret

000005ab <dup>:
SYSCALL(dup)
 5ab:	b8 0a 00 00 00       	mov    $0xa,%eax
 5b0:	cd 40                	int    $0x40
 5b2:	c3                   	ret

000005b3 <getpid>:
SYSCALL(getpid)
 5b3:	b8 0b 00 00 00       	mov    $0xb,%eax
 5b8:	cd 40                	int    $0x40
 5ba:	c3                   	ret

000005bb <sbrk>:
SYSCALL(sbrk)
 5bb:	b8 0c 00 00 00       	mov    $0xc,%eax
 5c0:	cd 40                	int    $0x40
 5c2:	c3                   	ret

000005c3 <sleep>:
SYSCALL(sleep)
 5c3:	b8 0d 00 00 00       	mov    $0xd,%eax
 5c8:	cd 40                	int    $0x40
 5ca:	c3                   	ret

000005cb <uptime>:
SYSCALL(uptime)
 5cb:	b8 0e 00 00 00       	mov    $0xe,%eax
 5d0:	cd 40                	int    $0x40
 5d2:	c3                   	ret

000005d3 <uthread_init>:

SYSCALL(uthread_init)
 5d3:	b8 16 00 00 00       	mov    $0x16,%eax
 5d8:	cd 40                	int    $0x40
 5da:	c3                   	ret

000005db <thread_count>:
SYSCALL(thread_count)
 5db:	b8 17 00 00 00       	mov    $0x17,%eax
 5e0:	cd 40                	int    $0x40
 5e2:	c3                   	ret

000005e3 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5e3:	f3 0f 1e fb          	endbr32
 5e7:	55                   	push   %ebp
 5e8:	89 e5                	mov    %esp,%ebp
 5ea:	83 ec 18             	sub    $0x18,%esp
 5ed:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f0:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5f3:	83 ec 04             	sub    $0x4,%esp
 5f6:	6a 01                	push   $0x1
 5f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5fb:	50                   	push   %eax
 5fc:	ff 75 08             	push   0x8(%ebp)
 5ff:	e8 4f ff ff ff       	call   553 <write>
 604:	83 c4 10             	add    $0x10,%esp
}
 607:	90                   	nop
 608:	c9                   	leave
 609:	c3                   	ret

0000060a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 60a:	f3 0f 1e fb          	endbr32
 60e:	55                   	push   %ebp
 60f:	89 e5                	mov    %esp,%ebp
 611:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 614:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 61b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 61f:	74 17                	je     638 <printint+0x2e>
 621:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 625:	79 11                	jns    638 <printint+0x2e>
    neg = 1;
 627:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 62e:	8b 45 0c             	mov    0xc(%ebp),%eax
 631:	f7 d8                	neg    %eax
 633:	89 45 ec             	mov    %eax,-0x14(%ebp)
 636:	eb 06                	jmp    63e <printint+0x34>
  } else {
    x = xx;
 638:	8b 45 0c             	mov    0xc(%ebp),%eax
 63b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 63e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 645:	8b 4d 10             	mov    0x10(%ebp),%ecx
 648:	8b 45 ec             	mov    -0x14(%ebp),%eax
 64b:	ba 00 00 00 00       	mov    $0x0,%edx
 650:	f7 f1                	div    %ecx
 652:	89 d1                	mov    %edx,%ecx
 654:	8b 45 f4             	mov    -0xc(%ebp),%eax
 657:	8d 50 01             	lea    0x1(%eax),%edx
 65a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 65d:	0f b6 91 bc 0d 00 00 	movzbl 0xdbc(%ecx),%edx
 664:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 668:	8b 4d 10             	mov    0x10(%ebp),%ecx
 66b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 66e:	ba 00 00 00 00       	mov    $0x0,%edx
 673:	f7 f1                	div    %ecx
 675:	89 45 ec             	mov    %eax,-0x14(%ebp)
 678:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 67c:	75 c7                	jne    645 <printint+0x3b>
  if(neg)
 67e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 682:	74 2d                	je     6b1 <printint+0xa7>
    buf[i++] = '-';
 684:	8b 45 f4             	mov    -0xc(%ebp),%eax
 687:	8d 50 01             	lea    0x1(%eax),%edx
 68a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 68d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 692:	eb 1d                	jmp    6b1 <printint+0xa7>
    putc(fd, buf[i]);
 694:	8d 55 dc             	lea    -0x24(%ebp),%edx
 697:	8b 45 f4             	mov    -0xc(%ebp),%eax
 69a:	01 d0                	add    %edx,%eax
 69c:	0f b6 00             	movzbl (%eax),%eax
 69f:	0f be c0             	movsbl %al,%eax
 6a2:	83 ec 08             	sub    $0x8,%esp
 6a5:	50                   	push   %eax
 6a6:	ff 75 08             	push   0x8(%ebp)
 6a9:	e8 35 ff ff ff       	call   5e3 <putc>
 6ae:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6b1:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6b9:	79 d9                	jns    694 <printint+0x8a>
}
 6bb:	90                   	nop
 6bc:	90                   	nop
 6bd:	c9                   	leave
 6be:	c3                   	ret

000006bf <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6bf:	f3 0f 1e fb          	endbr32
 6c3:	55                   	push   %ebp
 6c4:	89 e5                	mov    %esp,%ebp
 6c6:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6c9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6d0:	8d 45 0c             	lea    0xc(%ebp),%eax
 6d3:	83 c0 04             	add    $0x4,%eax
 6d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6d9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6e0:	e9 59 01 00 00       	jmp    83e <printf+0x17f>
    c = fmt[i] & 0xff;
 6e5:	8b 55 0c             	mov    0xc(%ebp),%edx
 6e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6eb:	01 d0                	add    %edx,%eax
 6ed:	0f b6 00             	movzbl (%eax),%eax
 6f0:	0f be c0             	movsbl %al,%eax
 6f3:	25 ff 00 00 00       	and    $0xff,%eax
 6f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6ff:	75 2c                	jne    72d <printf+0x6e>
      if(c == '%'){
 701:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 705:	75 0c                	jne    713 <printf+0x54>
        state = '%';
 707:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 70e:	e9 27 01 00 00       	jmp    83a <printf+0x17b>
      } else {
        putc(fd, c);
 713:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 716:	0f be c0             	movsbl %al,%eax
 719:	83 ec 08             	sub    $0x8,%esp
 71c:	50                   	push   %eax
 71d:	ff 75 08             	push   0x8(%ebp)
 720:	e8 be fe ff ff       	call   5e3 <putc>
 725:	83 c4 10             	add    $0x10,%esp
 728:	e9 0d 01 00 00       	jmp    83a <printf+0x17b>
      }
    } else if(state == '%'){
 72d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 731:	0f 85 03 01 00 00    	jne    83a <printf+0x17b>
      if(c == 'd'){
 737:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 73b:	75 1e                	jne    75b <printf+0x9c>
        printint(fd, *ap, 10, 1);
 73d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 740:	8b 00                	mov    (%eax),%eax
 742:	6a 01                	push   $0x1
 744:	6a 0a                	push   $0xa
 746:	50                   	push   %eax
 747:	ff 75 08             	push   0x8(%ebp)
 74a:	e8 bb fe ff ff       	call   60a <printint>
 74f:	83 c4 10             	add    $0x10,%esp
        ap++;
 752:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 756:	e9 d8 00 00 00       	jmp    833 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 75b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 75f:	74 06                	je     767 <printf+0xa8>
 761:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 765:	75 1e                	jne    785 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 767:	8b 45 e8             	mov    -0x18(%ebp),%eax
 76a:	8b 00                	mov    (%eax),%eax
 76c:	6a 00                	push   $0x0
 76e:	6a 10                	push   $0x10
 770:	50                   	push   %eax
 771:	ff 75 08             	push   0x8(%ebp)
 774:	e8 91 fe ff ff       	call   60a <printint>
 779:	83 c4 10             	add    $0x10,%esp
        ap++;
 77c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 780:	e9 ae 00 00 00       	jmp    833 <printf+0x174>
      } else if(c == 's'){
 785:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 789:	75 43                	jne    7ce <printf+0x10f>
        s = (char*)*ap;
 78b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 78e:	8b 00                	mov    (%eax),%eax
 790:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 793:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 797:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 79b:	75 25                	jne    7c2 <printf+0x103>
          s = "(null)";
 79d:	c7 45 f4 e8 0a 00 00 	movl   $0xae8,-0xc(%ebp)
        while(*s != 0){
 7a4:	eb 1c                	jmp    7c2 <printf+0x103>
          putc(fd, *s);
 7a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a9:	0f b6 00             	movzbl (%eax),%eax
 7ac:	0f be c0             	movsbl %al,%eax
 7af:	83 ec 08             	sub    $0x8,%esp
 7b2:	50                   	push   %eax
 7b3:	ff 75 08             	push   0x8(%ebp)
 7b6:	e8 28 fe ff ff       	call   5e3 <putc>
 7bb:	83 c4 10             	add    $0x10,%esp
          s++;
 7be:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 7c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c5:	0f b6 00             	movzbl (%eax),%eax
 7c8:	84 c0                	test   %al,%al
 7ca:	75 da                	jne    7a6 <printf+0xe7>
 7cc:	eb 65                	jmp    833 <printf+0x174>
        }
      } else if(c == 'c'){
 7ce:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7d2:	75 1d                	jne    7f1 <printf+0x132>
        putc(fd, *ap);
 7d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d7:	8b 00                	mov    (%eax),%eax
 7d9:	0f be c0             	movsbl %al,%eax
 7dc:	83 ec 08             	sub    $0x8,%esp
 7df:	50                   	push   %eax
 7e0:	ff 75 08             	push   0x8(%ebp)
 7e3:	e8 fb fd ff ff       	call   5e3 <putc>
 7e8:	83 c4 10             	add    $0x10,%esp
        ap++;
 7eb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ef:	eb 42                	jmp    833 <printf+0x174>
      } else if(c == '%'){
 7f1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7f5:	75 17                	jne    80e <printf+0x14f>
        putc(fd, c);
 7f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7fa:	0f be c0             	movsbl %al,%eax
 7fd:	83 ec 08             	sub    $0x8,%esp
 800:	50                   	push   %eax
 801:	ff 75 08             	push   0x8(%ebp)
 804:	e8 da fd ff ff       	call   5e3 <putc>
 809:	83 c4 10             	add    $0x10,%esp
 80c:	eb 25                	jmp    833 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 80e:	83 ec 08             	sub    $0x8,%esp
 811:	6a 25                	push   $0x25
 813:	ff 75 08             	push   0x8(%ebp)
 816:	e8 c8 fd ff ff       	call   5e3 <putc>
 81b:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 81e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 821:	0f be c0             	movsbl %al,%eax
 824:	83 ec 08             	sub    $0x8,%esp
 827:	50                   	push   %eax
 828:	ff 75 08             	push   0x8(%ebp)
 82b:	e8 b3 fd ff ff       	call   5e3 <putc>
 830:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 833:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 83a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 83e:	8b 55 0c             	mov    0xc(%ebp),%edx
 841:	8b 45 f0             	mov    -0x10(%ebp),%eax
 844:	01 d0                	add    %edx,%eax
 846:	0f b6 00             	movzbl (%eax),%eax
 849:	84 c0                	test   %al,%al
 84b:	0f 85 94 fe ff ff    	jne    6e5 <printf+0x26>
    }
  }
}
 851:	90                   	nop
 852:	90                   	nop
 853:	c9                   	leave
 854:	c3                   	ret

00000855 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 855:	f3 0f 1e fb          	endbr32
 859:	55                   	push   %ebp
 85a:	89 e5                	mov    %esp,%ebp
 85c:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 85f:	8b 45 08             	mov    0x8(%ebp),%eax
 862:	83 e8 08             	sub    $0x8,%eax
 865:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 868:	a1 08 8e 00 00       	mov    0x8e08,%eax
 86d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 870:	eb 24                	jmp    896 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 872:	8b 45 fc             	mov    -0x4(%ebp),%eax
 875:	8b 00                	mov    (%eax),%eax
 877:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 87a:	72 12                	jb     88e <free+0x39>
 87c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 882:	77 24                	ja     8a8 <free+0x53>
 884:	8b 45 fc             	mov    -0x4(%ebp),%eax
 887:	8b 00                	mov    (%eax),%eax
 889:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 88c:	72 1a                	jb     8a8 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 891:	8b 00                	mov    (%eax),%eax
 893:	89 45 fc             	mov    %eax,-0x4(%ebp)
 896:	8b 45 f8             	mov    -0x8(%ebp),%eax
 899:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 89c:	76 d4                	jbe    872 <free+0x1d>
 89e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a1:	8b 00                	mov    (%eax),%eax
 8a3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8a6:	73 ca                	jae    872 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ab:	8b 40 04             	mov    0x4(%eax),%eax
 8ae:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b8:	01 c2                	add    %eax,%edx
 8ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bd:	8b 00                	mov    (%eax),%eax
 8bf:	39 c2                	cmp    %eax,%edx
 8c1:	75 24                	jne    8e7 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 8c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c6:	8b 50 04             	mov    0x4(%eax),%edx
 8c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cc:	8b 00                	mov    (%eax),%eax
 8ce:	8b 40 04             	mov    0x4(%eax),%eax
 8d1:	01 c2                	add    %eax,%edx
 8d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d6:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8dc:	8b 00                	mov    (%eax),%eax
 8de:	8b 10                	mov    (%eax),%edx
 8e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e3:	89 10                	mov    %edx,(%eax)
 8e5:	eb 0a                	jmp    8f1 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 8e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ea:	8b 10                	mov    (%eax),%edx
 8ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ef:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f4:	8b 40 04             	mov    0x4(%eax),%eax
 8f7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 901:	01 d0                	add    %edx,%eax
 903:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 906:	75 20                	jne    928 <free+0xd3>
    p->s.size += bp->s.size;
 908:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90b:	8b 50 04             	mov    0x4(%eax),%edx
 90e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 911:	8b 40 04             	mov    0x4(%eax),%eax
 914:	01 c2                	add    %eax,%edx
 916:	8b 45 fc             	mov    -0x4(%ebp),%eax
 919:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 91c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91f:	8b 10                	mov    (%eax),%edx
 921:	8b 45 fc             	mov    -0x4(%ebp),%eax
 924:	89 10                	mov    %edx,(%eax)
 926:	eb 08                	jmp    930 <free+0xdb>
  } else
    p->s.ptr = bp;
 928:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 92e:	89 10                	mov    %edx,(%eax)
  freep = p;
 930:	8b 45 fc             	mov    -0x4(%ebp),%eax
 933:	a3 08 8e 00 00       	mov    %eax,0x8e08
}
 938:	90                   	nop
 939:	c9                   	leave
 93a:	c3                   	ret

0000093b <morecore>:

static Header*
morecore(uint nu)
{
 93b:	f3 0f 1e fb          	endbr32
 93f:	55                   	push   %ebp
 940:	89 e5                	mov    %esp,%ebp
 942:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 945:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 94c:	77 07                	ja     955 <morecore+0x1a>
    nu = 4096;
 94e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 955:	8b 45 08             	mov    0x8(%ebp),%eax
 958:	c1 e0 03             	shl    $0x3,%eax
 95b:	83 ec 0c             	sub    $0xc,%esp
 95e:	50                   	push   %eax
 95f:	e8 57 fc ff ff       	call   5bb <sbrk>
 964:	83 c4 10             	add    $0x10,%esp
 967:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 96a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 96e:	75 07                	jne    977 <morecore+0x3c>
    return 0;
 970:	b8 00 00 00 00       	mov    $0x0,%eax
 975:	eb 26                	jmp    99d <morecore+0x62>
  hp = (Header*)p;
 977:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 97d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 980:	8b 55 08             	mov    0x8(%ebp),%edx
 983:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 986:	8b 45 f0             	mov    -0x10(%ebp),%eax
 989:	83 c0 08             	add    $0x8,%eax
 98c:	83 ec 0c             	sub    $0xc,%esp
 98f:	50                   	push   %eax
 990:	e8 c0 fe ff ff       	call   855 <free>
 995:	83 c4 10             	add    $0x10,%esp
  return freep;
 998:	a1 08 8e 00 00       	mov    0x8e08,%eax
}
 99d:	c9                   	leave
 99e:	c3                   	ret

0000099f <malloc>:

void*
malloc(uint nbytes)
{
 99f:	f3 0f 1e fb          	endbr32
 9a3:	55                   	push   %ebp
 9a4:	89 e5                	mov    %esp,%ebp
 9a6:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9a9:	8b 45 08             	mov    0x8(%ebp),%eax
 9ac:	83 c0 07             	add    $0x7,%eax
 9af:	c1 e8 03             	shr    $0x3,%eax
 9b2:	83 c0 01             	add    $0x1,%eax
 9b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9b8:	a1 08 8e 00 00       	mov    0x8e08,%eax
 9bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9c4:	75 23                	jne    9e9 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 9c6:	c7 45 f0 00 8e 00 00 	movl   $0x8e00,-0x10(%ebp)
 9cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d0:	a3 08 8e 00 00       	mov    %eax,0x8e08
 9d5:	a1 08 8e 00 00       	mov    0x8e08,%eax
 9da:	a3 00 8e 00 00       	mov    %eax,0x8e00
    base.s.size = 0;
 9df:	c7 05 04 8e 00 00 00 	movl   $0x0,0x8e04
 9e6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ec:	8b 00                	mov    (%eax),%eax
 9ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f4:	8b 40 04             	mov    0x4(%eax),%eax
 9f7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9fa:	77 4d                	ja     a49 <malloc+0xaa>
      if(p->s.size == nunits)
 9fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ff:	8b 40 04             	mov    0x4(%eax),%eax
 a02:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a05:	75 0c                	jne    a13 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0a:	8b 10                	mov    (%eax),%edx
 a0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a0f:	89 10                	mov    %edx,(%eax)
 a11:	eb 26                	jmp    a39 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a16:	8b 40 04             	mov    0x4(%eax),%eax
 a19:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a1c:	89 c2                	mov    %eax,%edx
 a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a21:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a27:	8b 40 04             	mov    0x4(%eax),%eax
 a2a:	c1 e0 03             	shl    $0x3,%eax
 a2d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a33:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a36:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a3c:	a3 08 8e 00 00       	mov    %eax,0x8e08
      return (void*)(p + 1);
 a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a44:	83 c0 08             	add    $0x8,%eax
 a47:	eb 3b                	jmp    a84 <malloc+0xe5>
    }
    if(p == freep)
 a49:	a1 08 8e 00 00       	mov    0x8e08,%eax
 a4e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a51:	75 1e                	jne    a71 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 a53:	83 ec 0c             	sub    $0xc,%esp
 a56:	ff 75 ec             	push   -0x14(%ebp)
 a59:	e8 dd fe ff ff       	call   93b <morecore>
 a5e:	83 c4 10             	add    $0x10,%esp
 a61:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a68:	75 07                	jne    a71 <malloc+0xd2>
        return 0;
 a6a:	b8 00 00 00 00       	mov    $0x0,%eax
 a6f:	eb 13                	jmp    a84 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a74:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7a:	8b 00                	mov    (%eax),%eax
 a7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a7f:	e9 6d ff ff ff       	jmp    9f1 <malloc+0x52>
  }
}
 a84:	c9                   	leave
 a85:	c3                   	ret
