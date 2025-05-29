
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
  ed:	68 b4 0a 00 00       	push   $0xab4
  f2:	6a 02                	push   $0x2
  f4:	e8 f4 05 00 00       	call   6ed <printf>
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
 1ea:	68 da 0a 00 00       	push   $0xada
 1ef:	6a 01                	push   $0x1
 1f1:	e8 f7 04 00 00       	call   6ed <printf>
 1f6:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 1f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 200:	eb 1c                	jmp    21e <mythread+0x41>
    printf(1, "i:%d, my thread 0x%x\n", i, (int) current_thread);
 202:	a1 4c 8e 00 00       	mov    0x8e4c,%eax
 207:	50                   	push   %eax
 208:	ff 75 f4             	push   -0xc(%ebp)
 20b:	68 ed 0a 00 00       	push   $0xaed
 210:	6a 01                	push   $0x1
 212:	e8 d6 04 00 00       	call   6ed <printf>
 217:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 21a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 21e:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 222:	7e de                	jle    202 <mythread+0x25>
  }
  printf(1, "my thread: exit\n");
 224:	83 ec 08             	sub    $0x8,%esp
 227:	68 03 0b 00 00       	push   $0xb03
 22c:	6a 01                	push   $0x1
 22e:	e8 ba 04 00 00       	call   6ed <printf>
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
 25e:	68 b4 0a 00 00       	push   $0xab4
 263:	6a 02                	push   $0x2
 265:	e8 83 04 00 00       	call   6ed <printf>
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

00000609 <printpt>:
 609:	b8 17 00 00 00       	mov    $0x17,%eax
 60e:	cd 40                	int    $0x40
 610:	c3                   	ret

00000611 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 611:	f3 0f 1e fb          	endbr32
 615:	55                   	push   %ebp
 616:	89 e5                	mov    %esp,%ebp
 618:	83 ec 18             	sub    $0x18,%esp
 61b:	8b 45 0c             	mov    0xc(%ebp),%eax
 61e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 621:	83 ec 04             	sub    $0x4,%esp
 624:	6a 01                	push   $0x1
 626:	8d 45 f4             	lea    -0xc(%ebp),%eax
 629:	50                   	push   %eax
 62a:	ff 75 08             	push   0x8(%ebp)
 62d:	e8 4f ff ff ff       	call   581 <write>
 632:	83 c4 10             	add    $0x10,%esp
}
 635:	90                   	nop
 636:	c9                   	leave
 637:	c3                   	ret

00000638 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 638:	f3 0f 1e fb          	endbr32
 63c:	55                   	push   %ebp
 63d:	89 e5                	mov    %esp,%ebp
 63f:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 642:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 649:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 64d:	74 17                	je     666 <printint+0x2e>
 64f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 653:	79 11                	jns    666 <printint+0x2e>
    neg = 1;
 655:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 65c:	8b 45 0c             	mov    0xc(%ebp),%eax
 65f:	f7 d8                	neg    %eax
 661:	89 45 ec             	mov    %eax,-0x14(%ebp)
 664:	eb 06                	jmp    66c <printint+0x34>
  } else {
    x = xx;
 666:	8b 45 0c             	mov    0xc(%ebp),%eax
 669:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 66c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 673:	8b 4d 10             	mov    0x10(%ebp),%ecx
 676:	8b 45 ec             	mov    -0x14(%ebp),%eax
 679:	ba 00 00 00 00       	mov    $0x0,%edx
 67e:	f7 f1                	div    %ecx
 680:	89 d1                	mov    %edx,%ecx
 682:	8b 45 f4             	mov    -0xc(%ebp),%eax
 685:	8d 50 01             	lea    0x1(%eax),%edx
 688:	89 55 f4             	mov    %edx,-0xc(%ebp)
 68b:	0f b6 91 e8 0d 00 00 	movzbl 0xde8(%ecx),%edx
 692:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 696:	8b 4d 10             	mov    0x10(%ebp),%ecx
 699:	8b 45 ec             	mov    -0x14(%ebp),%eax
 69c:	ba 00 00 00 00       	mov    $0x0,%edx
 6a1:	f7 f1                	div    %ecx
 6a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6a6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6aa:	75 c7                	jne    673 <printint+0x3b>
  if(neg)
 6ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6b0:	74 2d                	je     6df <printint+0xa7>
    buf[i++] = '-';
 6b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b5:	8d 50 01             	lea    0x1(%eax),%edx
 6b8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6bb:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6c0:	eb 1d                	jmp    6df <printint+0xa7>
    putc(fd, buf[i]);
 6c2:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c8:	01 d0                	add    %edx,%eax
 6ca:	0f b6 00             	movzbl (%eax),%eax
 6cd:	0f be c0             	movsbl %al,%eax
 6d0:	83 ec 08             	sub    $0x8,%esp
 6d3:	50                   	push   %eax
 6d4:	ff 75 08             	push   0x8(%ebp)
 6d7:	e8 35 ff ff ff       	call   611 <putc>
 6dc:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6df:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6e7:	79 d9                	jns    6c2 <printint+0x8a>
}
 6e9:	90                   	nop
 6ea:	90                   	nop
 6eb:	c9                   	leave
 6ec:	c3                   	ret

000006ed <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6ed:	f3 0f 1e fb          	endbr32
 6f1:	55                   	push   %ebp
 6f2:	89 e5                	mov    %esp,%ebp
 6f4:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6f7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6fe:	8d 45 0c             	lea    0xc(%ebp),%eax
 701:	83 c0 04             	add    $0x4,%eax
 704:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 707:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 70e:	e9 59 01 00 00       	jmp    86c <printf+0x17f>
    c = fmt[i] & 0xff;
 713:	8b 55 0c             	mov    0xc(%ebp),%edx
 716:	8b 45 f0             	mov    -0x10(%ebp),%eax
 719:	01 d0                	add    %edx,%eax
 71b:	0f b6 00             	movzbl (%eax),%eax
 71e:	0f be c0             	movsbl %al,%eax
 721:	25 ff 00 00 00       	and    $0xff,%eax
 726:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 729:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 72d:	75 2c                	jne    75b <printf+0x6e>
      if(c == '%'){
 72f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 733:	75 0c                	jne    741 <printf+0x54>
        state = '%';
 735:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 73c:	e9 27 01 00 00       	jmp    868 <printf+0x17b>
      } else {
        putc(fd, c);
 741:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 744:	0f be c0             	movsbl %al,%eax
 747:	83 ec 08             	sub    $0x8,%esp
 74a:	50                   	push   %eax
 74b:	ff 75 08             	push   0x8(%ebp)
 74e:	e8 be fe ff ff       	call   611 <putc>
 753:	83 c4 10             	add    $0x10,%esp
 756:	e9 0d 01 00 00       	jmp    868 <printf+0x17b>
      }
    } else if(state == '%'){
 75b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 75f:	0f 85 03 01 00 00    	jne    868 <printf+0x17b>
      if(c == 'd'){
 765:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 769:	75 1e                	jne    789 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 76b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 76e:	8b 00                	mov    (%eax),%eax
 770:	6a 01                	push   $0x1
 772:	6a 0a                	push   $0xa
 774:	50                   	push   %eax
 775:	ff 75 08             	push   0x8(%ebp)
 778:	e8 bb fe ff ff       	call   638 <printint>
 77d:	83 c4 10             	add    $0x10,%esp
        ap++;
 780:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 784:	e9 d8 00 00 00       	jmp    861 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 789:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 78d:	74 06                	je     795 <printf+0xa8>
 78f:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 793:	75 1e                	jne    7b3 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 795:	8b 45 e8             	mov    -0x18(%ebp),%eax
 798:	8b 00                	mov    (%eax),%eax
 79a:	6a 00                	push   $0x0
 79c:	6a 10                	push   $0x10
 79e:	50                   	push   %eax
 79f:	ff 75 08             	push   0x8(%ebp)
 7a2:	e8 91 fe ff ff       	call   638 <printint>
 7a7:	83 c4 10             	add    $0x10,%esp
        ap++;
 7aa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ae:	e9 ae 00 00 00       	jmp    861 <printf+0x174>
      } else if(c == 's'){
 7b3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7b7:	75 43                	jne    7fc <printf+0x10f>
        s = (char*)*ap;
 7b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7bc:	8b 00                	mov    (%eax),%eax
 7be:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7c1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7c9:	75 25                	jne    7f0 <printf+0x103>
          s = "(null)";
 7cb:	c7 45 f4 14 0b 00 00 	movl   $0xb14,-0xc(%ebp)
        while(*s != 0){
 7d2:	eb 1c                	jmp    7f0 <printf+0x103>
          putc(fd, *s);
 7d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d7:	0f b6 00             	movzbl (%eax),%eax
 7da:	0f be c0             	movsbl %al,%eax
 7dd:	83 ec 08             	sub    $0x8,%esp
 7e0:	50                   	push   %eax
 7e1:	ff 75 08             	push   0x8(%ebp)
 7e4:	e8 28 fe ff ff       	call   611 <putc>
 7e9:	83 c4 10             	add    $0x10,%esp
          s++;
 7ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 7f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f3:	0f b6 00             	movzbl (%eax),%eax
 7f6:	84 c0                	test   %al,%al
 7f8:	75 da                	jne    7d4 <printf+0xe7>
 7fa:	eb 65                	jmp    861 <printf+0x174>
        }
      } else if(c == 'c'){
 7fc:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 800:	75 1d                	jne    81f <printf+0x132>
        putc(fd, *ap);
 802:	8b 45 e8             	mov    -0x18(%ebp),%eax
 805:	8b 00                	mov    (%eax),%eax
 807:	0f be c0             	movsbl %al,%eax
 80a:	83 ec 08             	sub    $0x8,%esp
 80d:	50                   	push   %eax
 80e:	ff 75 08             	push   0x8(%ebp)
 811:	e8 fb fd ff ff       	call   611 <putc>
 816:	83 c4 10             	add    $0x10,%esp
        ap++;
 819:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 81d:	eb 42                	jmp    861 <printf+0x174>
      } else if(c == '%'){
 81f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 823:	75 17                	jne    83c <printf+0x14f>
        putc(fd, c);
 825:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 828:	0f be c0             	movsbl %al,%eax
 82b:	83 ec 08             	sub    $0x8,%esp
 82e:	50                   	push   %eax
 82f:	ff 75 08             	push   0x8(%ebp)
 832:	e8 da fd ff ff       	call   611 <putc>
 837:	83 c4 10             	add    $0x10,%esp
 83a:	eb 25                	jmp    861 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 83c:	83 ec 08             	sub    $0x8,%esp
 83f:	6a 25                	push   $0x25
 841:	ff 75 08             	push   0x8(%ebp)
 844:	e8 c8 fd ff ff       	call   611 <putc>
 849:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 84c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 84f:	0f be c0             	movsbl %al,%eax
 852:	83 ec 08             	sub    $0x8,%esp
 855:	50                   	push   %eax
 856:	ff 75 08             	push   0x8(%ebp)
 859:	e8 b3 fd ff ff       	call   611 <putc>
 85e:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 861:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 868:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 86c:	8b 55 0c             	mov    0xc(%ebp),%edx
 86f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 872:	01 d0                	add    %edx,%eax
 874:	0f b6 00             	movzbl (%eax),%eax
 877:	84 c0                	test   %al,%al
 879:	0f 85 94 fe ff ff    	jne    713 <printf+0x26>
    }
  }
}
 87f:	90                   	nop
 880:	90                   	nop
 881:	c9                   	leave
 882:	c3                   	ret

00000883 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 883:	f3 0f 1e fb          	endbr32
 887:	55                   	push   %ebp
 888:	89 e5                	mov    %esp,%ebp
 88a:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 88d:	8b 45 08             	mov    0x8(%ebp),%eax
 890:	83 e8 08             	sub    $0x8,%eax
 893:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 896:	a1 48 8e 00 00       	mov    0x8e48,%eax
 89b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 89e:	eb 24                	jmp    8c4 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a3:	8b 00                	mov    (%eax),%eax
 8a5:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8a8:	72 12                	jb     8bc <free+0x39>
 8aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ad:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8b0:	77 24                	ja     8d6 <free+0x53>
 8b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b5:	8b 00                	mov    (%eax),%eax
 8b7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8ba:	72 1a                	jb     8d6 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bf:	8b 00                	mov    (%eax),%eax
 8c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8ca:	76 d4                	jbe    8a0 <free+0x1d>
 8cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cf:	8b 00                	mov    (%eax),%eax
 8d1:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8d4:	73 ca                	jae    8a0 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d9:	8b 40 04             	mov    0x4(%eax),%eax
 8dc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e6:	01 c2                	add    %eax,%edx
 8e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8eb:	8b 00                	mov    (%eax),%eax
 8ed:	39 c2                	cmp    %eax,%edx
 8ef:	75 24                	jne    915 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 8f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f4:	8b 50 04             	mov    0x4(%eax),%edx
 8f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fa:	8b 00                	mov    (%eax),%eax
 8fc:	8b 40 04             	mov    0x4(%eax),%eax
 8ff:	01 c2                	add    %eax,%edx
 901:	8b 45 f8             	mov    -0x8(%ebp),%eax
 904:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 907:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90a:	8b 00                	mov    (%eax),%eax
 90c:	8b 10                	mov    (%eax),%edx
 90e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 911:	89 10                	mov    %edx,(%eax)
 913:	eb 0a                	jmp    91f <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 915:	8b 45 fc             	mov    -0x4(%ebp),%eax
 918:	8b 10                	mov    (%eax),%edx
 91a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 91f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 922:	8b 40 04             	mov    0x4(%eax),%eax
 925:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 92c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92f:	01 d0                	add    %edx,%eax
 931:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 934:	75 20                	jne    956 <free+0xd3>
    p->s.size += bp->s.size;
 936:	8b 45 fc             	mov    -0x4(%ebp),%eax
 939:	8b 50 04             	mov    0x4(%eax),%edx
 93c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93f:	8b 40 04             	mov    0x4(%eax),%eax
 942:	01 c2                	add    %eax,%edx
 944:	8b 45 fc             	mov    -0x4(%ebp),%eax
 947:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 94a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94d:	8b 10                	mov    (%eax),%edx
 94f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 952:	89 10                	mov    %edx,(%eax)
 954:	eb 08                	jmp    95e <free+0xdb>
  } else
    p->s.ptr = bp;
 956:	8b 45 fc             	mov    -0x4(%ebp),%eax
 959:	8b 55 f8             	mov    -0x8(%ebp),%edx
 95c:	89 10                	mov    %edx,(%eax)
  freep = p;
 95e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 961:	a3 48 8e 00 00       	mov    %eax,0x8e48
}
 966:	90                   	nop
 967:	c9                   	leave
 968:	c3                   	ret

00000969 <morecore>:

static Header*
morecore(uint nu)
{
 969:	f3 0f 1e fb          	endbr32
 96d:	55                   	push   %ebp
 96e:	89 e5                	mov    %esp,%ebp
 970:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 973:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 97a:	77 07                	ja     983 <morecore+0x1a>
    nu = 4096;
 97c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 983:	8b 45 08             	mov    0x8(%ebp),%eax
 986:	c1 e0 03             	shl    $0x3,%eax
 989:	83 ec 0c             	sub    $0xc,%esp
 98c:	50                   	push   %eax
 98d:	e8 57 fc ff ff       	call   5e9 <sbrk>
 992:	83 c4 10             	add    $0x10,%esp
 995:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 998:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 99c:	75 07                	jne    9a5 <morecore+0x3c>
    return 0;
 99e:	b8 00 00 00 00       	mov    $0x0,%eax
 9a3:	eb 26                	jmp    9cb <morecore+0x62>
  hp = (Header*)p;
 9a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ae:	8b 55 08             	mov    0x8(%ebp),%edx
 9b1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b7:	83 c0 08             	add    $0x8,%eax
 9ba:	83 ec 0c             	sub    $0xc,%esp
 9bd:	50                   	push   %eax
 9be:	e8 c0 fe ff ff       	call   883 <free>
 9c3:	83 c4 10             	add    $0x10,%esp
  return freep;
 9c6:	a1 48 8e 00 00       	mov    0x8e48,%eax
}
 9cb:	c9                   	leave
 9cc:	c3                   	ret

000009cd <malloc>:

void*
malloc(uint nbytes)
{
 9cd:	f3 0f 1e fb          	endbr32
 9d1:	55                   	push   %ebp
 9d2:	89 e5                	mov    %esp,%ebp
 9d4:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9d7:	8b 45 08             	mov    0x8(%ebp),%eax
 9da:	83 c0 07             	add    $0x7,%eax
 9dd:	c1 e8 03             	shr    $0x3,%eax
 9e0:	83 c0 01             	add    $0x1,%eax
 9e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9e6:	a1 48 8e 00 00       	mov    0x8e48,%eax
 9eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9ee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9f2:	75 23                	jne    a17 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 9f4:	c7 45 f0 40 8e 00 00 	movl   $0x8e40,-0x10(%ebp)
 9fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9fe:	a3 48 8e 00 00       	mov    %eax,0x8e48
 a03:	a1 48 8e 00 00       	mov    0x8e48,%eax
 a08:	a3 40 8e 00 00       	mov    %eax,0x8e40
    base.s.size = 0;
 a0d:	c7 05 44 8e 00 00 00 	movl   $0x0,0x8e44
 a14:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a1a:	8b 00                	mov    (%eax),%eax
 a1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a22:	8b 40 04             	mov    0x4(%eax),%eax
 a25:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a28:	77 4d                	ja     a77 <malloc+0xaa>
      if(p->s.size == nunits)
 a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2d:	8b 40 04             	mov    0x4(%eax),%eax
 a30:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a33:	75 0c                	jne    a41 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a38:	8b 10                	mov    (%eax),%edx
 a3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a3d:	89 10                	mov    %edx,(%eax)
 a3f:	eb 26                	jmp    a67 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a44:	8b 40 04             	mov    0x4(%eax),%eax
 a47:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a4a:	89 c2                	mov    %eax,%edx
 a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a55:	8b 40 04             	mov    0x4(%eax),%eax
 a58:	c1 e0 03             	shl    $0x3,%eax
 a5b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a61:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a64:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a6a:	a3 48 8e 00 00       	mov    %eax,0x8e48
      return (void*)(p + 1);
 a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a72:	83 c0 08             	add    $0x8,%eax
 a75:	eb 3b                	jmp    ab2 <malloc+0xe5>
    }
    if(p == freep)
 a77:	a1 48 8e 00 00       	mov    0x8e48,%eax
 a7c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a7f:	75 1e                	jne    a9f <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 a81:	83 ec 0c             	sub    $0xc,%esp
 a84:	ff 75 ec             	push   -0x14(%ebp)
 a87:	e8 dd fe ff ff       	call   969 <morecore>
 a8c:	83 c4 10             	add    $0x10,%esp
 a8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a96:	75 07                	jne    a9f <malloc+0xd2>
        return 0;
 a98:	b8 00 00 00 00       	mov    $0x0,%eax
 a9d:	eb 13                	jmp    ab2 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa8:	8b 00                	mov    (%eax),%eax
 aaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 aad:	e9 6d ff ff ff       	jmp    a1f <malloc+0x52>
  }
}
 ab2:	c9                   	leave
 ab3:	c3                   	ret
