
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
   a:	c7 05 4c 8e 00 00 20 	movl   $0xe20,0x8e4c
  11:	0e 00 00 
  current_thread->state = RUNNING;
  14:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
  19:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  20:	00 00 00 
  // System call
  // uthread_init()을 통해서 thread_schedule의 주소를 넘겨준다.
  // uthread_init()은 syscall.c에 정의되어 있다.
  uthread_init((int)thread_schedule);
  23:	b8 37 00 00 00       	mov    $0x37,%eax
  28:	83 ec 0c             	sub    $0xc,%esp
  2b:	50                   	push   %eax
  2c:	e8 d0 05 00 00       	call   601 <uthread_init>
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
  // 쓰레드가 없으면 exit
  if (thread_count == 0) exit();
  41:	a1 00 0e 00 00       	mov    0xe00,%eax
  46:	85 c0                	test   %eax,%eax
  48:	75 05                	jne    4f <thread_schedule+0x18>
  4a:	e8 12 05 00 00       	call   561 <exit>

  thread_p t;
  /* Find another runnable thread. */
  next_thread = 0;
  4f:	c7 05 50 8e 00 00 00 	movl   $0x0,0x8e50
  56:	00 00 00 

  
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  59:	c7 45 f4 20 0e 00 00 	movl   $0xe20,-0xc(%ebp)
  60:	eb 41                	jmp    a3 <thread_schedule+0x6c>
    // all_thread[0]은 main()이기 때문에 한 번 switch를 했으면 건너 뜀.
    if(t == &all_thread[0] && t->state == RUNNABLE){
  62:	81 7d f4 20 0e 00 00 	cmpl   $0xe20,-0xc(%ebp)
  69:	75 0e                	jne    79 <thread_schedule+0x42>
  6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6e:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  74:	83 f8 02             	cmp    $0x2,%eax
  77:	74 22                	je     9b <thread_schedule+0x64>
      continue;
    }
    // RUNNABLE 상태인 스레드가 있으면 next_thread에 저장
    if (t->state == RUNNABLE && t != current_thread) {
  79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  7c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  82:	83 f8 02             	cmp    $0x2,%eax
  85:	75 15                	jne    9c <thread_schedule+0x65>
  87:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
  8c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  8f:	74 0b                	je     9c <thread_schedule+0x65>
      next_thread = t;
  91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  94:	a3 50 8e 00 00       	mov    %eax,0x8e50
      break;
  99:	eb 12                	jmp    ad <thread_schedule+0x76>
      continue;
  9b:	90                   	nop
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  9c:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  a3:	b8 40 8e 00 00       	mov    $0x8e40,%eax
  a8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  ab:	72 b5                	jb     62 <thread_schedule+0x2b>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  ad:	b8 40 8e 00 00       	mov    $0x8e40,%eax
  b2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  b5:	72 1a                	jb     d1 <thread_schedule+0x9a>
  b7:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
  bc:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  c2:	83 f8 02             	cmp    $0x2,%eax
  c5:	75 0a                	jne    d1 <thread_schedule+0x9a>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  c7:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
  cc:	a3 50 8e 00 00       	mov    %eax,0x8e50
  }

  // runnable thread가 없으면 exit
  if (next_thread == 0) {
  d1:	a1 50 8e 00 00       	mov    0x8e50,%eax
  d6:	85 c0                	test   %eax,%eax
  d8:	75 27                	jne    101 <thread_schedule+0xca>
    // current_thread가 RUNNING 상태이면 현재 쓰레드가 유일한 쓰레드이므로
    // 스케줄링을 하지 않고 그냥 리턴
    if (current_thread->state == RUNNING) return;
  da:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
  df:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  e5:	83 f8 01             	cmp    $0x1,%eax
  e8:	74 67                	je     151 <thread_schedule+0x11a>
    // 쓰레드가 없으면 exit
    printf(2, "thread_schedule: no runnable threads\n");
  ea:	83 ec 08             	sub    $0x8,%esp
  ed:	68 ac 0a 00 00       	push   $0xaac
  f2:	6a 02                	push   $0x2
  f4:	e8 ec 05 00 00       	call   6e5 <printf>
  f9:	83 c4 10             	add    $0x10,%esp
    exit();
  fc:	e8 60 04 00 00       	call   561 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
 101:	8b 15 4c 8e 00 00    	mov    0x8e4c,%edx
 107:	a1 50 8e 00 00       	mov    0x8e50,%eax
 10c:	39 c2                	cmp    %eax,%edx
 10e:	74 35                	je     145 <thread_schedule+0x10e>
    next_thread->state = RUNNING;
 110:	a1 50 8e 00 00       	mov    0x8e50,%eax
 115:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 11c:	00 00 00 
    // current_thread가 RUNNING 상태이면 RUNNABLE로 바꿔준다.
    if (current_thread->state == RUNNING) current_thread->state = RUNNABLE;
 11f:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
 124:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 12a:	83 f8 01             	cmp    $0x1,%eax
 12d:	75 0f                	jne    13e <thread_schedule+0x107>
 12f:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
 134:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 13b:	00 00 00 
    // context switch
    thread_switch();
 13e:	e8 83 01 00 00       	call   2c6 <thread_switch>
 143:	eb 0d                	jmp    152 <thread_schedule+0x11b>
  } else
    next_thread = 0;
 145:	c7 05 50 8e 00 00 00 	movl   $0x0,0x8e50
 14c:	00 00 00 
 14f:	eb 01                	jmp    152 <thread_schedule+0x11b>
    if (current_thread->state == RUNNING) return;
 151:	90                   	nop
}
 152:	c9                   	leave
 153:	c3                   	ret

00000154 <thread_create>:

// thread_create: 스레드 생성 함수
void 
thread_create(void (*func)())
{
 154:	f3 0f 1e fb          	endbr32
 158:	55                   	push   %ebp
 159:	89 e5                	mov    %esp,%ebp
 15b:	83 ec 10             	sub    $0x10,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 15e:	c7 45 fc 20 0e 00 00 	movl   $0xe20,-0x4(%ebp)
 165:	eb 14                	jmp    17b <thread_create+0x27>
    if (t->state == FREE) break;
 167:	8b 45 fc             	mov    -0x4(%ebp),%eax
 16a:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 170:	85 c0                	test   %eax,%eax
 172:	74 13                	je     187 <thread_create+0x33>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 174:	81 45 fc 08 20 00 00 	addl   $0x2008,-0x4(%ebp)
 17b:	b8 40 8e 00 00       	mov    $0x8e40,%eax
 180:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 183:	72 e2                	jb     167 <thread_create+0x13>
 185:	eb 01                	jmp    188 <thread_create+0x34>
    if (t->state == FREE) break;
 187:	90                   	nop
  }
  // 스택 포인터 = 스택의 top frame
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 188:	8b 45 fc             	mov    -0x4(%ebp),%eax
 18b:	83 c0 04             	add    $0x4,%eax
 18e:	05 00 20 00 00       	add    $0x2000,%eax
 193:	89 c2                	mov    %eax,%edx
 195:	8b 45 fc             	mov    -0x4(%ebp),%eax
 198:	89 10                	mov    %edx,(%eax)
  // 스택 포인터를 4byte 만큼 줄여서 리턴 주소를 저장할 공간을 만든다.
  t->sp -= 4;                              // space for return address
 19a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 19d:	8b 00                	mov    (%eax),%eax
 19f:	8d 50 fc             	lea    -0x4(%eax),%edx
 1a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1a5:	89 10                	mov    %edx,(%eax)
  // mythread 함수를 리턴 주소로 저장
  * (int *) (t->sp) = (int)func;           // push return address on stack
 1a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1aa:	8b 00                	mov    (%eax),%eax
 1ac:	89 c2                	mov    %eax,%edx
 1ae:	8b 45 08             	mov    0x8(%ebp),%eax
 1b1:	89 02                	mov    %eax,(%edx)
  // 레지스터를 위한 공간
  t->sp -= 32;                             // space for registers that thread_switch expects
 1b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1b6:	8b 00                	mov    (%eax),%eax
 1b8:	8d 50 e0             	lea    -0x20(%eax),%edx
 1bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1be:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 1c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1c3:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1ca:	00 00 00 
  thread_count++;
 1cd:	a1 00 0e 00 00       	mov    0xe00,%eax
 1d2:	83 c0 01             	add    $0x1,%eax
 1d5:	a3 00 0e 00 00       	mov    %eax,0xe00
}
 1da:	90                   	nop
 1db:	c9                   	leave
 1dc:	c3                   	ret

000001dd <mythread>:

static void 
mythread(void)
{
 1dd:	f3 0f 1e fb          	endbr32
 1e1:	55                   	push   %ebp
 1e2:	89 e5                	mov    %esp,%ebp
 1e4:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 1e7:	83 ec 08             	sub    $0x8,%esp
 1ea:	68 d2 0a 00 00       	push   $0xad2
 1ef:	6a 01                	push   $0x1
 1f1:	e8 ef 04 00 00       	call   6e5 <printf>
 1f6:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 200:	eb 1c                	jmp    21e <mythread+0x41>
    printf(1, "i:%d, my thread 0x%x\n", i, (int) current_thread);
 202:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
 207:	50                   	push   %eax
 208:	ff 75 f4             	push   -0xc(%ebp)
 20b:	68 e5 0a 00 00       	push   $0xae5
 210:	6a 01                	push   $0x1
 212:	e8 ce 04 00 00       	call   6e5 <printf>
 217:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 21a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 21e:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 222:	7e de                	jle    202 <mythread+0x25>
  }
  printf(1, "my thread: exit\n");
 224:	83 ec 08             	sub    $0x8,%esp
 227:	68 fb 0a 00 00       	push   $0xafb
 22c:	6a 01                	push   $0x1
 22e:	e8 b2 04 00 00       	call   6e5 <printf>
 233:	83 c4 10             	add    $0x10,%esp
  // 쓰레드가 종료되면 쓰레드 상태를 FREE로 바꿔준다.
  current_thread->state = FREE;
 236:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
 23b:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 242:	00 00 00 
  thread_count--;
 245:	a1 00 0e 00 00       	mov    0xe00,%eax
 24a:	83 e8 01             	sub    $0x1,%eax
 24d:	a3 00 0e 00 00       	mov    %eax,0xe00
  if (thread_count == 0) {
 252:	a1 00 0e 00 00       	mov    0xe00,%eax
 257:	85 c0                	test   %eax,%eax
 259:	75 17                	jne    272 <mythread+0x95>
    // 모든 쓰레드가 종료되면 exit
    printf(2, "thread_schedule: no runnable threads\n");
 25b:	83 ec 08             	sub    $0x8,%esp
 25e:	68 ac 0a 00 00       	push   $0xaac
 263:	6a 02                	push   $0x2
 265:	e8 7b 04 00 00       	call   6e5 <printf>
 26a:	83 c4 10             	add    $0x10,%esp
    exit();
 26d:	e8 ef 02 00 00       	call   561 <exit>
  }
    
  // 현재 쓰레드가 종료 되었기 때문에 스케줄링
  thread_schedule();
 272:	e8 c0 fd ff ff       	call   37 <thread_schedule>
}
 277:	90                   	nop
 278:	c9                   	leave
 279:	c3                   	ret

0000027a <main>:


int 
main(int argc, char *argv[]) 
{
 27a:	f3 0f 1e fb          	endbr32
 27e:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 282:	83 e4 f0             	and    $0xfffffff0,%esp
 285:	ff 71 fc             	push   -0x4(%ecx)
 288:	55                   	push   %ebp
 289:	89 e5                	mov    %esp,%ebp
 28b:	51                   	push   %ecx
 28c:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 28f:	e8 6c fd ff ff       	call   0 <thread_init>
  thread_create(mythread);
 294:	83 ec 0c             	sub    $0xc,%esp
 297:	68 dd 01 00 00       	push   $0x1dd
 29c:	e8 b3 fe ff ff       	call   154 <thread_create>
 2a1:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 2a4:	83 ec 0c             	sub    $0xc,%esp
 2a7:	68 dd 01 00 00       	push   $0x1dd
 2ac:	e8 a3 fe ff ff       	call   154 <thread_create>
 2b1:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 2b4:	e8 7e fd ff ff       	call   37 <thread_schedule>
  return 0;
 2b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2be:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 2c1:	c9                   	leave
 2c2:	8d 61 fc             	lea    -0x4(%ecx),%esp
 2c5:	c3                   	ret

000002c6 <thread_switch>:
         */
    .text
    .globl thread_switch
thread_switch:
    // 레지스터 저장
    pushal
 2c6:	60                   	pusha

    // eax에 current_thread 저장
    // esp에 바로 못넘김
    movl current_thread, %eax
 2c7:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
    // current_thread = esp
    // esp에는 전에 저장해놨던 thread의 주소가 있음
    movl %esp, (%eax)
 2cc:	89 20                	mov    %esp,(%eax)

    // 다음 실행할 쓰레드 저장 eax에 담아서 esp에 저장
    movl next_thread, %eax
 2ce:	a1 50 8e 00 00       	mov    0x8e50,%eax
    movl (%eax), %esp
 2d3:	8b 20                	mov    (%eax),%esp

    // current_thread = next_thread
    movl %eax, current_thread
 2d5:	a3 4c 8e 00 00       	mov    %eax,0x8e4c

    // 레지스터 복구
    popal
 2da:	61                   	popa

    // next_thread = 0
    movl $0, next_thread
 2db:	c7 05 50 8e 00 00 00 	movl   $0x0,0x8e50
 2e2:	00 00 00 
    
    // 다시 원래 실행하던 곳으로 점프
    // esp에 next_thread주소를 넣고 current_thread와 next_thread를 바꿔놓았기 때문에
    // contextSwitching이 된 상태로 돌아간다.
    ret   
 2e5:	c3                   	ret

000002e6 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2e6:	55                   	push   %ebp
 2e7:	89 e5                	mov    %esp,%ebp
 2e9:	57                   	push   %edi
 2ea:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2ee:	8b 55 10             	mov    0x10(%ebp),%edx
 2f1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f4:	89 cb                	mov    %ecx,%ebx
 2f6:	89 df                	mov    %ebx,%edi
 2f8:	89 d1                	mov    %edx,%ecx
 2fa:	fc                   	cld
 2fb:	f3 aa                	rep stos %al,%es:(%edi)
 2fd:	89 ca                	mov    %ecx,%edx
 2ff:	89 fb                	mov    %edi,%ebx
 301:	89 5d 08             	mov    %ebx,0x8(%ebp)
 304:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 307:	90                   	nop
 308:	5b                   	pop    %ebx
 309:	5f                   	pop    %edi
 30a:	5d                   	pop    %ebp
 30b:	c3                   	ret

0000030c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 30c:	f3 0f 1e fb          	endbr32
 310:	55                   	push   %ebp
 311:	89 e5                	mov    %esp,%ebp
 313:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 316:	8b 45 08             	mov    0x8(%ebp),%eax
 319:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 31c:	90                   	nop
 31d:	8b 55 0c             	mov    0xc(%ebp),%edx
 320:	8d 42 01             	lea    0x1(%edx),%eax
 323:	89 45 0c             	mov    %eax,0xc(%ebp)
 326:	8b 45 08             	mov    0x8(%ebp),%eax
 329:	8d 48 01             	lea    0x1(%eax),%ecx
 32c:	89 4d 08             	mov    %ecx,0x8(%ebp)
 32f:	0f b6 12             	movzbl (%edx),%edx
 332:	88 10                	mov    %dl,(%eax)
 334:	0f b6 00             	movzbl (%eax),%eax
 337:	84 c0                	test   %al,%al
 339:	75 e2                	jne    31d <strcpy+0x11>
    ;
  return os;
 33b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 33e:	c9                   	leave
 33f:	c3                   	ret

00000340 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 340:	f3 0f 1e fb          	endbr32
 344:	55                   	push   %ebp
 345:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 347:	eb 08                	jmp    351 <strcmp+0x11>
    p++, q++;
 349:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 34d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 351:	8b 45 08             	mov    0x8(%ebp),%eax
 354:	0f b6 00             	movzbl (%eax),%eax
 357:	84 c0                	test   %al,%al
 359:	74 10                	je     36b <strcmp+0x2b>
 35b:	8b 45 08             	mov    0x8(%ebp),%eax
 35e:	0f b6 10             	movzbl (%eax),%edx
 361:	8b 45 0c             	mov    0xc(%ebp),%eax
 364:	0f b6 00             	movzbl (%eax),%eax
 367:	38 c2                	cmp    %al,%dl
 369:	74 de                	je     349 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 36b:	8b 45 08             	mov    0x8(%ebp),%eax
 36e:	0f b6 00             	movzbl (%eax),%eax
 371:	0f b6 d0             	movzbl %al,%edx
 374:	8b 45 0c             	mov    0xc(%ebp),%eax
 377:	0f b6 00             	movzbl (%eax),%eax
 37a:	0f b6 c0             	movzbl %al,%eax
 37d:	29 c2                	sub    %eax,%edx
 37f:	89 d0                	mov    %edx,%eax
}
 381:	5d                   	pop    %ebp
 382:	c3                   	ret

00000383 <strlen>:

uint
strlen(char *s)
{
 383:	f3 0f 1e fb          	endbr32
 387:	55                   	push   %ebp
 388:	89 e5                	mov    %esp,%ebp
 38a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 38d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 394:	eb 04                	jmp    39a <strlen+0x17>
 396:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 39a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 39d:	8b 45 08             	mov    0x8(%ebp),%eax
 3a0:	01 d0                	add    %edx,%eax
 3a2:	0f b6 00             	movzbl (%eax),%eax
 3a5:	84 c0                	test   %al,%al
 3a7:	75 ed                	jne    396 <strlen+0x13>
    ;
  return n;
 3a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3ac:	c9                   	leave
 3ad:	c3                   	ret

000003ae <memset>:

void*
memset(void *dst, int c, uint n)
{
 3ae:	f3 0f 1e fb          	endbr32
 3b2:	55                   	push   %ebp
 3b3:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3b5:	8b 45 10             	mov    0x10(%ebp),%eax
 3b8:	50                   	push   %eax
 3b9:	ff 75 0c             	push   0xc(%ebp)
 3bc:	ff 75 08             	push   0x8(%ebp)
 3bf:	e8 22 ff ff ff       	call   2e6 <stosb>
 3c4:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3c7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3ca:	c9                   	leave
 3cb:	c3                   	ret

000003cc <strchr>:

char*
strchr(const char *s, char c)
{
 3cc:	f3 0f 1e fb          	endbr32
 3d0:	55                   	push   %ebp
 3d1:	89 e5                	mov    %esp,%ebp
 3d3:	83 ec 04             	sub    $0x4,%esp
 3d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d9:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3dc:	eb 14                	jmp    3f2 <strchr+0x26>
    if(*s == c)
 3de:	8b 45 08             	mov    0x8(%ebp),%eax
 3e1:	0f b6 00             	movzbl (%eax),%eax
 3e4:	38 45 fc             	cmp    %al,-0x4(%ebp)
 3e7:	75 05                	jne    3ee <strchr+0x22>
      return (char*)s;
 3e9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ec:	eb 13                	jmp    401 <strchr+0x35>
  for(; *s; s++)
 3ee:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3f2:	8b 45 08             	mov    0x8(%ebp),%eax
 3f5:	0f b6 00             	movzbl (%eax),%eax
 3f8:	84 c0                	test   %al,%al
 3fa:	75 e2                	jne    3de <strchr+0x12>
  return 0;
 3fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
 401:	c9                   	leave
 402:	c3                   	ret

00000403 <gets>:

char*
gets(char *buf, int max)
{
 403:	f3 0f 1e fb          	endbr32
 407:	55                   	push   %ebp
 408:	89 e5                	mov    %esp,%ebp
 40a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 40d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 414:	eb 42                	jmp    458 <gets+0x55>
    cc = read(0, &c, 1);
 416:	83 ec 04             	sub    $0x4,%esp
 419:	6a 01                	push   $0x1
 41b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 41e:	50                   	push   %eax
 41f:	6a 00                	push   $0x0
 421:	e8 53 01 00 00       	call   579 <read>
 426:	83 c4 10             	add    $0x10,%esp
 429:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 42c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 430:	7e 33                	jle    465 <gets+0x62>
      break;
    buf[i++] = c;
 432:	8b 45 f4             	mov    -0xc(%ebp),%eax
 435:	8d 50 01             	lea    0x1(%eax),%edx
 438:	89 55 f4             	mov    %edx,-0xc(%ebp)
 43b:	89 c2                	mov    %eax,%edx
 43d:	8b 45 08             	mov    0x8(%ebp),%eax
 440:	01 c2                	add    %eax,%edx
 442:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 446:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 448:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 44c:	3c 0a                	cmp    $0xa,%al
 44e:	74 16                	je     466 <gets+0x63>
 450:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 454:	3c 0d                	cmp    $0xd,%al
 456:	74 0e                	je     466 <gets+0x63>
  for(i=0; i+1 < max; ){
 458:	8b 45 f4             	mov    -0xc(%ebp),%eax
 45b:	83 c0 01             	add    $0x1,%eax
 45e:	39 45 0c             	cmp    %eax,0xc(%ebp)
 461:	7f b3                	jg     416 <gets+0x13>
 463:	eb 01                	jmp    466 <gets+0x63>
      break;
 465:	90                   	nop
      break;
  }
  buf[i] = '\0';
 466:	8b 55 f4             	mov    -0xc(%ebp),%edx
 469:	8b 45 08             	mov    0x8(%ebp),%eax
 46c:	01 d0                	add    %edx,%eax
 46e:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 471:	8b 45 08             	mov    0x8(%ebp),%eax
}
 474:	c9                   	leave
 475:	c3                   	ret

00000476 <stat>:

int
stat(char *n, struct stat *st)
{
 476:	f3 0f 1e fb          	endbr32
 47a:	55                   	push   %ebp
 47b:	89 e5                	mov    %esp,%ebp
 47d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 480:	83 ec 08             	sub    $0x8,%esp
 483:	6a 00                	push   $0x0
 485:	ff 75 08             	push   0x8(%ebp)
 488:	e8 14 01 00 00       	call   5a1 <open>
 48d:	83 c4 10             	add    $0x10,%esp
 490:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 493:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 497:	79 07                	jns    4a0 <stat+0x2a>
    return -1;
 499:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 49e:	eb 25                	jmp    4c5 <stat+0x4f>
  r = fstat(fd, st);
 4a0:	83 ec 08             	sub    $0x8,%esp
 4a3:	ff 75 0c             	push   0xc(%ebp)
 4a6:	ff 75 f4             	push   -0xc(%ebp)
 4a9:	e8 0b 01 00 00       	call   5b9 <fstat>
 4ae:	83 c4 10             	add    $0x10,%esp
 4b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4b4:	83 ec 0c             	sub    $0xc,%esp
 4b7:	ff 75 f4             	push   -0xc(%ebp)
 4ba:	e8 ca 00 00 00       	call   589 <close>
 4bf:	83 c4 10             	add    $0x10,%esp
  return r;
 4c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4c5:	c9                   	leave
 4c6:	c3                   	ret

000004c7 <atoi>:

int
atoi(const char *s)
{
 4c7:	f3 0f 1e fb          	endbr32
 4cb:	55                   	push   %ebp
 4cc:	89 e5                	mov    %esp,%ebp
 4ce:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4d1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4d8:	eb 25                	jmp    4ff <atoi+0x38>
    n = n*10 + *s++ - '0';
 4da:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4dd:	89 d0                	mov    %edx,%eax
 4df:	c1 e0 02             	shl    $0x2,%eax
 4e2:	01 d0                	add    %edx,%eax
 4e4:	01 c0                	add    %eax,%eax
 4e6:	89 c1                	mov    %eax,%ecx
 4e8:	8b 45 08             	mov    0x8(%ebp),%eax
 4eb:	8d 50 01             	lea    0x1(%eax),%edx
 4ee:	89 55 08             	mov    %edx,0x8(%ebp)
 4f1:	0f b6 00             	movzbl (%eax),%eax
 4f4:	0f be c0             	movsbl %al,%eax
 4f7:	01 c8                	add    %ecx,%eax
 4f9:	83 e8 30             	sub    $0x30,%eax
 4fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4ff:	8b 45 08             	mov    0x8(%ebp),%eax
 502:	0f b6 00             	movzbl (%eax),%eax
 505:	3c 2f                	cmp    $0x2f,%al
 507:	7e 0a                	jle    513 <atoi+0x4c>
 509:	8b 45 08             	mov    0x8(%ebp),%eax
 50c:	0f b6 00             	movzbl (%eax),%eax
 50f:	3c 39                	cmp    $0x39,%al
 511:	7e c7                	jle    4da <atoi+0x13>
  return n;
 513:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 516:	c9                   	leave
 517:	c3                   	ret

00000518 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 518:	f3 0f 1e fb          	endbr32
 51c:	55                   	push   %ebp
 51d:	89 e5                	mov    %esp,%ebp
 51f:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 522:	8b 45 08             	mov    0x8(%ebp),%eax
 525:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 528:	8b 45 0c             	mov    0xc(%ebp),%eax
 52b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 52e:	eb 17                	jmp    547 <memmove+0x2f>
    *dst++ = *src++;
 530:	8b 55 f8             	mov    -0x8(%ebp),%edx
 533:	8d 42 01             	lea    0x1(%edx),%eax
 536:	89 45 f8             	mov    %eax,-0x8(%ebp)
 539:	8b 45 fc             	mov    -0x4(%ebp),%eax
 53c:	8d 48 01             	lea    0x1(%eax),%ecx
 53f:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 542:	0f b6 12             	movzbl (%edx),%edx
 545:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 547:	8b 45 10             	mov    0x10(%ebp),%eax
 54a:	8d 50 ff             	lea    -0x1(%eax),%edx
 54d:	89 55 10             	mov    %edx,0x10(%ebp)
 550:	85 c0                	test   %eax,%eax
 552:	7f dc                	jg     530 <memmove+0x18>
  return vdst;
 554:	8b 45 08             	mov    0x8(%ebp),%eax
}
 557:	c9                   	leave
 558:	c3                   	ret

00000559 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 559:	b8 01 00 00 00       	mov    $0x1,%eax
 55e:	cd 40                	int    $0x40
 560:	c3                   	ret

00000561 <exit>:
SYSCALL(exit)
 561:	b8 02 00 00 00       	mov    $0x2,%eax
 566:	cd 40                	int    $0x40
 568:	c3                   	ret

00000569 <wait>:
SYSCALL(wait)
 569:	b8 03 00 00 00       	mov    $0x3,%eax
 56e:	cd 40                	int    $0x40
 570:	c3                   	ret

00000571 <pipe>:
SYSCALL(pipe)
 571:	b8 04 00 00 00       	mov    $0x4,%eax
 576:	cd 40                	int    $0x40
 578:	c3                   	ret

00000579 <read>:
SYSCALL(read)
 579:	b8 05 00 00 00       	mov    $0x5,%eax
 57e:	cd 40                	int    $0x40
 580:	c3                   	ret

00000581 <write>:
SYSCALL(write)
 581:	b8 10 00 00 00       	mov    $0x10,%eax
 586:	cd 40                	int    $0x40
 588:	c3                   	ret

00000589 <close>:
SYSCALL(close)
 589:	b8 15 00 00 00       	mov    $0x15,%eax
 58e:	cd 40                	int    $0x40
 590:	c3                   	ret

00000591 <kill>:
SYSCALL(kill)
 591:	b8 06 00 00 00       	mov    $0x6,%eax
 596:	cd 40                	int    $0x40
 598:	c3                   	ret

00000599 <exec>:
SYSCALL(exec)
 599:	b8 07 00 00 00       	mov    $0x7,%eax
 59e:	cd 40                	int    $0x40
 5a0:	c3                   	ret

000005a1 <open>:
SYSCALL(open)
 5a1:	b8 0f 00 00 00       	mov    $0xf,%eax
 5a6:	cd 40                	int    $0x40
 5a8:	c3                   	ret

000005a9 <mknod>:
SYSCALL(mknod)
 5a9:	b8 11 00 00 00       	mov    $0x11,%eax
 5ae:	cd 40                	int    $0x40
 5b0:	c3                   	ret

000005b1 <unlink>:
SYSCALL(unlink)
 5b1:	b8 12 00 00 00       	mov    $0x12,%eax
 5b6:	cd 40                	int    $0x40
 5b8:	c3                   	ret

000005b9 <fstat>:
SYSCALL(fstat)
 5b9:	b8 08 00 00 00       	mov    $0x8,%eax
 5be:	cd 40                	int    $0x40
 5c0:	c3                   	ret

000005c1 <link>:
SYSCALL(link)
 5c1:	b8 13 00 00 00       	mov    $0x13,%eax
 5c6:	cd 40                	int    $0x40
 5c8:	c3                   	ret

000005c9 <mkdir>:
SYSCALL(mkdir)
 5c9:	b8 14 00 00 00       	mov    $0x14,%eax
 5ce:	cd 40                	int    $0x40
 5d0:	c3                   	ret

000005d1 <chdir>:
SYSCALL(chdir)
 5d1:	b8 09 00 00 00       	mov    $0x9,%eax
 5d6:	cd 40                	int    $0x40
 5d8:	c3                   	ret

000005d9 <dup>:
SYSCALL(dup)
 5d9:	b8 0a 00 00 00       	mov    $0xa,%eax
 5de:	cd 40                	int    $0x40
 5e0:	c3                   	ret

000005e1 <getpid>:
SYSCALL(getpid)
 5e1:	b8 0b 00 00 00       	mov    $0xb,%eax
 5e6:	cd 40                	int    $0x40
 5e8:	c3                   	ret

000005e9 <sbrk>:
SYSCALL(sbrk)
 5e9:	b8 0c 00 00 00       	mov    $0xc,%eax
 5ee:	cd 40                	int    $0x40
 5f0:	c3                   	ret

000005f1 <sleep>:
SYSCALL(sleep)
 5f1:	b8 0d 00 00 00       	mov    $0xd,%eax
 5f6:	cd 40                	int    $0x40
 5f8:	c3                   	ret

000005f9 <uptime>:
SYSCALL(uptime)
 5f9:	b8 0e 00 00 00       	mov    $0xe,%eax
 5fe:	cd 40                	int    $0x40
 600:	c3                   	ret

00000601 <uthread_init>:

SYSCALL(uthread_init)
 601:	b8 16 00 00 00       	mov    $0x16,%eax
 606:	cd 40                	int    $0x40
 608:	c3                   	ret

00000609 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 609:	f3 0f 1e fb          	endbr32
 60d:	55                   	push   %ebp
 60e:	89 e5                	mov    %esp,%ebp
 610:	83 ec 18             	sub    $0x18,%esp
 613:	8b 45 0c             	mov    0xc(%ebp),%eax
 616:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 619:	83 ec 04             	sub    $0x4,%esp
 61c:	6a 01                	push   $0x1
 61e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 621:	50                   	push   %eax
 622:	ff 75 08             	push   0x8(%ebp)
 625:	e8 57 ff ff ff       	call   581 <write>
 62a:	83 c4 10             	add    $0x10,%esp
}
 62d:	90                   	nop
 62e:	c9                   	leave
 62f:	c3                   	ret

00000630 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 630:	f3 0f 1e fb          	endbr32
 634:	55                   	push   %ebp
 635:	89 e5                	mov    %esp,%ebp
 637:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 63a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 641:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 645:	74 17                	je     65e <printint+0x2e>
 647:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 64b:	79 11                	jns    65e <printint+0x2e>
    neg = 1;
 64d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 654:	8b 45 0c             	mov    0xc(%ebp),%eax
 657:	f7 d8                	neg    %eax
 659:	89 45 ec             	mov    %eax,-0x14(%ebp)
 65c:	eb 06                	jmp    664 <printint+0x34>
  } else {
    x = xx;
 65e:	8b 45 0c             	mov    0xc(%ebp),%eax
 661:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 664:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 66b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 66e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 671:	ba 00 00 00 00       	mov    $0x0,%edx
 676:	f7 f1                	div    %ecx
 678:	89 d1                	mov    %edx,%ecx
 67a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 67d:	8d 50 01             	lea    0x1(%eax),%edx
 680:	89 55 f4             	mov    %edx,-0xc(%ebp)
 683:	0f b6 91 e0 0d 00 00 	movzbl 0xde0(%ecx),%edx
 68a:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 68e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 691:	8b 45 ec             	mov    -0x14(%ebp),%eax
 694:	ba 00 00 00 00       	mov    $0x0,%edx
 699:	f7 f1                	div    %ecx
 69b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 69e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6a2:	75 c7                	jne    66b <printint+0x3b>
  if(neg)
 6a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6a8:	74 2d                	je     6d7 <printint+0xa7>
    buf[i++] = '-';
 6aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ad:	8d 50 01             	lea    0x1(%eax),%edx
 6b0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6b3:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6b8:	eb 1d                	jmp    6d7 <printint+0xa7>
    putc(fd, buf[i]);
 6ba:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c0:	01 d0                	add    %edx,%eax
 6c2:	0f b6 00             	movzbl (%eax),%eax
 6c5:	0f be c0             	movsbl %al,%eax
 6c8:	83 ec 08             	sub    $0x8,%esp
 6cb:	50                   	push   %eax
 6cc:	ff 75 08             	push   0x8(%ebp)
 6cf:	e8 35 ff ff ff       	call   609 <putc>
 6d4:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6d7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6df:	79 d9                	jns    6ba <printint+0x8a>
}
 6e1:	90                   	nop
 6e2:	90                   	nop
 6e3:	c9                   	leave
 6e4:	c3                   	ret

000006e5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6e5:	f3 0f 1e fb          	endbr32
 6e9:	55                   	push   %ebp
 6ea:	89 e5                	mov    %esp,%ebp
 6ec:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6ef:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6f6:	8d 45 0c             	lea    0xc(%ebp),%eax
 6f9:	83 c0 04             	add    $0x4,%eax
 6fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6ff:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 706:	e9 59 01 00 00       	jmp    864 <printf+0x17f>
    c = fmt[i] & 0xff;
 70b:	8b 55 0c             	mov    0xc(%ebp),%edx
 70e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 711:	01 d0                	add    %edx,%eax
 713:	0f b6 00             	movzbl (%eax),%eax
 716:	0f be c0             	movsbl %al,%eax
 719:	25 ff 00 00 00       	and    $0xff,%eax
 71e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 721:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 725:	75 2c                	jne    753 <printf+0x6e>
      if(c == '%'){
 727:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 72b:	75 0c                	jne    739 <printf+0x54>
        state = '%';
 72d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 734:	e9 27 01 00 00       	jmp    860 <printf+0x17b>
      } else {
        putc(fd, c);
 739:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 73c:	0f be c0             	movsbl %al,%eax
 73f:	83 ec 08             	sub    $0x8,%esp
 742:	50                   	push   %eax
 743:	ff 75 08             	push   0x8(%ebp)
 746:	e8 be fe ff ff       	call   609 <putc>
 74b:	83 c4 10             	add    $0x10,%esp
 74e:	e9 0d 01 00 00       	jmp    860 <printf+0x17b>
      }
    } else if(state == '%'){
 753:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 757:	0f 85 03 01 00 00    	jne    860 <printf+0x17b>
      if(c == 'd'){
 75d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 761:	75 1e                	jne    781 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 763:	8b 45 e8             	mov    -0x18(%ebp),%eax
 766:	8b 00                	mov    (%eax),%eax
 768:	6a 01                	push   $0x1
 76a:	6a 0a                	push   $0xa
 76c:	50                   	push   %eax
 76d:	ff 75 08             	push   0x8(%ebp)
 770:	e8 bb fe ff ff       	call   630 <printint>
 775:	83 c4 10             	add    $0x10,%esp
        ap++;
 778:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 77c:	e9 d8 00 00 00       	jmp    859 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 781:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 785:	74 06                	je     78d <printf+0xa8>
 787:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 78b:	75 1e                	jne    7ab <printf+0xc6>
        printint(fd, *ap, 16, 0);
 78d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 790:	8b 00                	mov    (%eax),%eax
 792:	6a 00                	push   $0x0
 794:	6a 10                	push   $0x10
 796:	50                   	push   %eax
 797:	ff 75 08             	push   0x8(%ebp)
 79a:	e8 91 fe ff ff       	call   630 <printint>
 79f:	83 c4 10             	add    $0x10,%esp
        ap++;
 7a2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7a6:	e9 ae 00 00 00       	jmp    859 <printf+0x174>
      } else if(c == 's'){
 7ab:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7af:	75 43                	jne    7f4 <printf+0x10f>
        s = (char*)*ap;
 7b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b4:	8b 00                	mov    (%eax),%eax
 7b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7b9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7c1:	75 25                	jne    7e8 <printf+0x103>
          s = "(null)";
 7c3:	c7 45 f4 0c 0b 00 00 	movl   $0xb0c,-0xc(%ebp)
        while(*s != 0){
 7ca:	eb 1c                	jmp    7e8 <printf+0x103>
          putc(fd, *s);
 7cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cf:	0f b6 00             	movzbl (%eax),%eax
 7d2:	0f be c0             	movsbl %al,%eax
 7d5:	83 ec 08             	sub    $0x8,%esp
 7d8:	50                   	push   %eax
 7d9:	ff 75 08             	push   0x8(%ebp)
 7dc:	e8 28 fe ff ff       	call   609 <putc>
 7e1:	83 c4 10             	add    $0x10,%esp
          s++;
 7e4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 7e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7eb:	0f b6 00             	movzbl (%eax),%eax
 7ee:	84 c0                	test   %al,%al
 7f0:	75 da                	jne    7cc <printf+0xe7>
 7f2:	eb 65                	jmp    859 <printf+0x174>
        }
      } else if(c == 'c'){
 7f4:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7f8:	75 1d                	jne    817 <printf+0x132>
        putc(fd, *ap);
 7fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7fd:	8b 00                	mov    (%eax),%eax
 7ff:	0f be c0             	movsbl %al,%eax
 802:	83 ec 08             	sub    $0x8,%esp
 805:	50                   	push   %eax
 806:	ff 75 08             	push   0x8(%ebp)
 809:	e8 fb fd ff ff       	call   609 <putc>
 80e:	83 c4 10             	add    $0x10,%esp
        ap++;
 811:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 815:	eb 42                	jmp    859 <printf+0x174>
      } else if(c == '%'){
 817:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 81b:	75 17                	jne    834 <printf+0x14f>
        putc(fd, c);
 81d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 820:	0f be c0             	movsbl %al,%eax
 823:	83 ec 08             	sub    $0x8,%esp
 826:	50                   	push   %eax
 827:	ff 75 08             	push   0x8(%ebp)
 82a:	e8 da fd ff ff       	call   609 <putc>
 82f:	83 c4 10             	add    $0x10,%esp
 832:	eb 25                	jmp    859 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 834:	83 ec 08             	sub    $0x8,%esp
 837:	6a 25                	push   $0x25
 839:	ff 75 08             	push   0x8(%ebp)
 83c:	e8 c8 fd ff ff       	call   609 <putc>
 841:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 844:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 847:	0f be c0             	movsbl %al,%eax
 84a:	83 ec 08             	sub    $0x8,%esp
 84d:	50                   	push   %eax
 84e:	ff 75 08             	push   0x8(%ebp)
 851:	e8 b3 fd ff ff       	call   609 <putc>
 856:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 859:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 860:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 864:	8b 55 0c             	mov    0xc(%ebp),%edx
 867:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86a:	01 d0                	add    %edx,%eax
 86c:	0f b6 00             	movzbl (%eax),%eax
 86f:	84 c0                	test   %al,%al
 871:	0f 85 94 fe ff ff    	jne    70b <printf+0x26>
    }
  }
}
 877:	90                   	nop
 878:	90                   	nop
 879:	c9                   	leave
 87a:	c3                   	ret

0000087b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 87b:	f3 0f 1e fb          	endbr32
 87f:	55                   	push   %ebp
 880:	89 e5                	mov    %esp,%ebp
 882:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 885:	8b 45 08             	mov    0x8(%ebp),%eax
 888:	83 e8 08             	sub    $0x8,%eax
 88b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88e:	a1 48 8e 00 00       	mov    0x8e48,%eax
 893:	89 45 fc             	mov    %eax,-0x4(%ebp)
 896:	eb 24                	jmp    8bc <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 898:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89b:	8b 00                	mov    (%eax),%eax
 89d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8a0:	72 12                	jb     8b4 <free+0x39>
 8a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8a8:	77 24                	ja     8ce <free+0x53>
 8aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ad:	8b 00                	mov    (%eax),%eax
 8af:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8b2:	72 1a                	jb     8ce <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b7:	8b 00                	mov    (%eax),%eax
 8b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8bf:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8c2:	76 d4                	jbe    898 <free+0x1d>
 8c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c7:	8b 00                	mov    (%eax),%eax
 8c9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8cc:	73 ca                	jae    898 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d1:	8b 40 04             	mov    0x4(%eax),%eax
 8d4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8de:	01 c2                	add    %eax,%edx
 8e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e3:	8b 00                	mov    (%eax),%eax
 8e5:	39 c2                	cmp    %eax,%edx
 8e7:	75 24                	jne    90d <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 8e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ec:	8b 50 04             	mov    0x4(%eax),%edx
 8ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f2:	8b 00                	mov    (%eax),%eax
 8f4:	8b 40 04             	mov    0x4(%eax),%eax
 8f7:	01 c2                	add    %eax,%edx
 8f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8fc:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 902:	8b 00                	mov    (%eax),%eax
 904:	8b 10                	mov    (%eax),%edx
 906:	8b 45 f8             	mov    -0x8(%ebp),%eax
 909:	89 10                	mov    %edx,(%eax)
 90b:	eb 0a                	jmp    917 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 90d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 910:	8b 10                	mov    (%eax),%edx
 912:	8b 45 f8             	mov    -0x8(%ebp),%eax
 915:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 917:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91a:	8b 40 04             	mov    0x4(%eax),%eax
 91d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 924:	8b 45 fc             	mov    -0x4(%ebp),%eax
 927:	01 d0                	add    %edx,%eax
 929:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 92c:	75 20                	jne    94e <free+0xd3>
    p->s.size += bp->s.size;
 92e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 931:	8b 50 04             	mov    0x4(%eax),%edx
 934:	8b 45 f8             	mov    -0x8(%ebp),%eax
 937:	8b 40 04             	mov    0x4(%eax),%eax
 93a:	01 c2                	add    %eax,%edx
 93c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 942:	8b 45 f8             	mov    -0x8(%ebp),%eax
 945:	8b 10                	mov    (%eax),%edx
 947:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94a:	89 10                	mov    %edx,(%eax)
 94c:	eb 08                	jmp    956 <free+0xdb>
  } else
    p->s.ptr = bp;
 94e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 951:	8b 55 f8             	mov    -0x8(%ebp),%edx
 954:	89 10                	mov    %edx,(%eax)
  freep = p;
 956:	8b 45 fc             	mov    -0x4(%ebp),%eax
 959:	a3 48 8e 00 00       	mov    %eax,0x8e48
}
 95e:	90                   	nop
 95f:	c9                   	leave
 960:	c3                   	ret

00000961 <morecore>:

static Header*
morecore(uint nu)
{
 961:	f3 0f 1e fb          	endbr32
 965:	55                   	push   %ebp
 966:	89 e5                	mov    %esp,%ebp
 968:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 96b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 972:	77 07                	ja     97b <morecore+0x1a>
    nu = 4096;
 974:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 97b:	8b 45 08             	mov    0x8(%ebp),%eax
 97e:	c1 e0 03             	shl    $0x3,%eax
 981:	83 ec 0c             	sub    $0xc,%esp
 984:	50                   	push   %eax
 985:	e8 5f fc ff ff       	call   5e9 <sbrk>
 98a:	83 c4 10             	add    $0x10,%esp
 98d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 990:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 994:	75 07                	jne    99d <morecore+0x3c>
    return 0;
 996:	b8 00 00 00 00       	mov    $0x0,%eax
 99b:	eb 26                	jmp    9c3 <morecore+0x62>
  hp = (Header*)p;
 99d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a6:	8b 55 08             	mov    0x8(%ebp),%edx
 9a9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9af:	83 c0 08             	add    $0x8,%eax
 9b2:	83 ec 0c             	sub    $0xc,%esp
 9b5:	50                   	push   %eax
 9b6:	e8 c0 fe ff ff       	call   87b <free>
 9bb:	83 c4 10             	add    $0x10,%esp
  return freep;
 9be:	a1 48 8e 00 00       	mov    0x8e48,%eax
}
 9c3:	c9                   	leave
 9c4:	c3                   	ret

000009c5 <malloc>:

void*
malloc(uint nbytes)
{
 9c5:	f3 0f 1e fb          	endbr32
 9c9:	55                   	push   %ebp
 9ca:	89 e5                	mov    %esp,%ebp
 9cc:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9cf:	8b 45 08             	mov    0x8(%ebp),%eax
 9d2:	83 c0 07             	add    $0x7,%eax
 9d5:	c1 e8 03             	shr    $0x3,%eax
 9d8:	83 c0 01             	add    $0x1,%eax
 9db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9de:	a1 48 8e 00 00       	mov    0x8e48,%eax
 9e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9ea:	75 23                	jne    a0f <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 9ec:	c7 45 f0 40 8e 00 00 	movl   $0x8e40,-0x10(%ebp)
 9f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f6:	a3 48 8e 00 00       	mov    %eax,0x8e48
 9fb:	a1 48 8e 00 00       	mov    0x8e48,%eax
 a00:	a3 40 8e 00 00       	mov    %eax,0x8e40
    base.s.size = 0;
 a05:	c7 05 44 8e 00 00 00 	movl   $0x0,0x8e44
 a0c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a12:	8b 00                	mov    (%eax),%eax
 a14:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1a:	8b 40 04             	mov    0x4(%eax),%eax
 a1d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a20:	77 4d                	ja     a6f <malloc+0xaa>
      if(p->s.size == nunits)
 a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a25:	8b 40 04             	mov    0x4(%eax),%eax
 a28:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a2b:	75 0c                	jne    a39 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a30:	8b 10                	mov    (%eax),%edx
 a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a35:	89 10                	mov    %edx,(%eax)
 a37:	eb 26                	jmp    a5f <malloc+0x9a>
      else {
        p->s.size -= nunits;
 a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3c:	8b 40 04             	mov    0x4(%eax),%eax
 a3f:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a42:	89 c2                	mov    %eax,%edx
 a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a47:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4d:	8b 40 04             	mov    0x4(%eax),%eax
 a50:	c1 e0 03             	shl    $0x3,%eax
 a53:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a59:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a5c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a62:	a3 48 8e 00 00       	mov    %eax,0x8e48
      return (void*)(p + 1);
 a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6a:	83 c0 08             	add    $0x8,%eax
 a6d:	eb 3b                	jmp    aaa <malloc+0xe5>
    }
    if(p == freep)
 a6f:	a1 48 8e 00 00       	mov    0x8e48,%eax
 a74:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a77:	75 1e                	jne    a97 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 a79:	83 ec 0c             	sub    $0xc,%esp
 a7c:	ff 75 ec             	push   -0x14(%ebp)
 a7f:	e8 dd fe ff ff       	call   961 <morecore>
 a84:	83 c4 10             	add    $0x10,%esp
 a87:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a8e:	75 07                	jne    a97 <malloc+0xd2>
        return 0;
 a90:	b8 00 00 00 00       	mov    $0x0,%eax
 a95:	eb 13                	jmp    aaa <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa0:	8b 00                	mov    (%eax),%eax
 aa2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 aa5:	e9 6d ff ff ff       	jmp    a17 <malloc+0x52>
  }
}
 aaa:	c9                   	leave
 aab:	c3                   	ret
