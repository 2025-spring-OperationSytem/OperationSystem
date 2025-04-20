
_uthread3:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_init>:
static void thread_schedule(void);
int main();

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
   a:	c7 05 fc 50 01 00 a0 	movl   $0x10a0,0x150fc
  11:	10 00 00 
  current_thread->sp = (int) (current_thread->stack + STACK_SIZE);   // set sp to the top of the stack
  14:	a1 fc 50 01 00       	mov    0x150fc,%eax
  19:	83 c0 04             	add    $0x4,%eax
  1c:	8d 90 fc 1f 00 00    	lea    0x1ffc(%eax),%edx
  22:	a1 fc 50 01 00       	mov    0x150fc,%eax
  27:	89 10                	mov    %edx,(%eax)
  current_thread->sp -= 4;                              // space for return address
  29:	a1 fc 50 01 00       	mov    0x150fc,%eax
  2e:	8b 10                	mov    (%eax),%edx
  30:	a1 fc 50 01 00       	mov    0x150fc,%eax
  35:	83 ea 04             	sub    $0x4,%edx
  38:	89 10                	mov    %edx,(%eax)
  * (int *) (current_thread->sp) = (int)main;           // push return address on stack
  3a:	a1 fc 50 01 00       	mov    0x150fc,%eax
  3f:	8b 00                	mov    (%eax),%eax
  41:	ba ed 03 00 00       	mov    $0x3ed,%edx
  46:	89 10                	mov    %edx,(%eax)
  current_thread->sp -= 32;                             // space for registers that thread_switch expects
  48:	a1 fc 50 01 00       	mov    0x150fc,%eax
  4d:	8b 10                	mov    (%eax),%edx
  4f:	a1 fc 50 01 00       	mov    0x150fc,%eax
  54:	83 ea 20             	sub    $0x20,%edx
  57:	89 10                	mov    %edx,(%eax)
  current_thread->state = RUNNING;
  59:	a1 fc 50 01 00       	mov    0x150fc,%eax
  5e:	c7 80 00 20 00 00 01 	movl   $0x1,0x2000(%eax)
  65:	00 00 00 
  current_thread->tid = 0;
  68:	a1 fc 50 01 00       	mov    0x150fc,%eax
  6d:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
  74:	00 00 00 
  uthread_init((int)thread_schedule);
  77:	b8 8b 00 00 00       	mov    $0x8b,%eax
  7c:	83 ec 0c             	sub    $0xc,%esp
  7f:	50                   	push   %eax
  80:	e8 74 07 00 00       	call   7f9 <uthread_init>
  85:	83 c4 10             	add    $0x10,%esp
}
  88:	90                   	nop
  89:	c9                   	leave
  8a:	c3                   	ret

0000008b <thread_schedule>:

int flag =0;
static void
thread_schedule(void)
{
  8b:	f3 0f 1e fb          	endbr32
  8f:	55                   	push   %ebp
  90:	89 e5                	mov    %esp,%ebp
  92:	83 ec 18             	sub    $0x18,%esp
  
  thread_p t;
  /* Find another runnable thread. */
  next_thread = 0;
  95:	c7 05 00 51 01 00 00 	movl   $0x0,0x15100
  9c:	00 00 00 

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  9f:	c7 45 f4 a0 10 00 00 	movl   $0x10a0,-0xc(%ebp)
  a6:	eb 60                	jmp    108 <thread_schedule+0x7d>
    if(t == &all_thread[0] && t->state == RUNNABLE && flag == 1){
  a8:	81 7d f4 a0 10 00 00 	cmpl   $0x10a0,-0xc(%ebp)
  af:	75 24                	jne    d5 <thread_schedule+0x4a>
  b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  b4:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
  ba:	83 f8 02             	cmp    $0x2,%eax
  bd:	75 16                	jne    d5 <thread_schedule+0x4a>
  bf:	a1 80 10 00 00       	mov    0x1080,%eax
  c4:	83 f8 01             	cmp    $0x1,%eax
  c7:	75 0c                	jne    d5 <thread_schedule+0x4a>
      flag = 0;
  c9:	c7 05 80 10 00 00 00 	movl   $0x0,0x1080
  d0:	00 00 00 
      continue;
  d3:	eb 2c                	jmp    101 <thread_schedule+0x76>
    }
    else {
      flag = 1;
  d5:	c7 05 80 10 00 00 01 	movl   $0x1,0x1080
  dc:	00 00 00 
    }
    // RUNNABLE 상태인 스레드가 있으면 next_thread에 저장
    if (t->state == RUNNABLE && t != current_thread) {
  df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  e2:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
  e8:	83 f8 02             	cmp    $0x2,%eax
  eb:	75 14                	jne    101 <thread_schedule+0x76>
  ed:	a1 fc 50 01 00       	mov    0x150fc,%eax
  f2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  f5:	74 0a                	je     101 <thread_schedule+0x76>
      next_thread = t;
  f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  fa:	a3 00 51 01 00       	mov    %eax,0x15100
      break;
  ff:	eb 11                	jmp    112 <thread_schedule+0x87>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 101:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 108:	b8 f0 50 01 00       	mov    $0x150f0,%eax
 10d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 110:	72 96                	jb     a8 <thread_schedule+0x1d>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
 112:	b8 f0 50 01 00       	mov    $0x150f0,%eax
 117:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 11a:	72 1a                	jb     136 <thread_schedule+0xab>
 11c:	a1 fc 50 01 00       	mov    0x150fc,%eax
 121:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 127:	83 f8 02             	cmp    $0x2,%eax
 12a:	75 0a                	jne    136 <thread_schedule+0xab>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
 12c:	a1 fc 50 01 00       	mov    0x150fc,%eax
 131:	a3 00 51 01 00       	mov    %eax,0x15100
  }
  // runnable thread가 없으면 exit
  if (next_thread == 0) {
 136:	a1 00 51 01 00       	mov    0x15100,%eax
 13b:	85 c0                	test   %eax,%eax
 13d:	75 27                	jne    166 <thread_schedule+0xdb>
    // current_thread가 RUNNING 상태이면 현재 쓰레드가 유일한 쓰레드이므로
    // 스케줄링을 하지 않고 그냥 리턴
    if (current_thread->state == RUNNING) return;
 13f:	a1 fc 50 01 00       	mov    0x150fc,%eax
 144:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 14a:	83 f8 01             	cmp    $0x1,%eax
 14d:	74 67                	je     1b6 <thread_schedule+0x12b>
    // 쓰레드가 없으면 exit
    printf(2, "thread_schedule: no runnable threads\n");
 14f:	83 ec 08             	sub    $0x8,%esp
 152:	68 ac 0c 00 00       	push   $0xcac
 157:	6a 02                	push   $0x2
 159:	e8 87 07 00 00       	call   8e5 <printf>
 15e:	83 c4 10             	add    $0x10,%esp
    exit();
 161:	e8 f3 05 00 00       	call   759 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
 166:	8b 15 fc 50 01 00    	mov    0x150fc,%edx
 16c:	a1 00 51 01 00       	mov    0x15100,%eax
 171:	39 c2                	cmp    %eax,%edx
 173:	74 35                	je     1aa <thread_schedule+0x11f>
    next_thread->state = RUNNING;
 175:	a1 00 51 01 00       	mov    0x15100,%eax
 17a:	c7 80 00 20 00 00 01 	movl   $0x1,0x2000(%eax)
 181:	00 00 00 
    // current_thread가 RUNNING 상태이면 RUNNABLE로 바꿔준다.
    if (current_thread->state == RUNNING) current_thread->state = RUNNABLE;
 184:	a1 fc 50 01 00       	mov    0x150fc,%eax
 189:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 18f:	83 f8 01             	cmp    $0x1,%eax
 192:	75 0f                	jne    1a3 <thread_schedule+0x118>
 194:	a1 fc 50 01 00       	mov    0x150fc,%eax
 199:	c7 80 00 20 00 00 02 	movl   $0x2,0x2000(%eax)
 1a0:	00 00 00 
    // context switch
    thread_switch();
 1a3:	e8 16 03 00 00       	call   4be <thread_switch>
 1a8:	eb 0d                	jmp    1b7 <thread_schedule+0x12c>
  } else
    next_thread = 0;
 1aa:	c7 05 00 51 01 00 00 	movl   $0x0,0x15100
 1b1:	00 00 00 
 1b4:	eb 01                	jmp    1b7 <thread_schedule+0x12c>
    if (current_thread->state == RUNNING) return;
 1b6:	90                   	nop
}
 1b7:	c9                   	leave
 1b8:	c3                   	ret

000001b9 <thread_create>:

int
thread_create(void (*func)())
{
 1b9:	f3 0f 1e fb          	endbr32
 1bd:	55                   	push   %ebp
 1be:	89 e5                	mov    %esp,%ebp
 1c0:	83 ec 18             	sub    $0x18,%esp
  printf(1, "thread_create\n");
 1c3:	83 ec 08             	sub    $0x8,%esp
 1c6:	68 d2 0c 00 00       	push   $0xcd2
 1cb:	6a 01                	push   $0x1
 1cd:	e8 13 07 00 00       	call   8e5 <printf>
 1d2:	83 c4 10             	add    $0x10,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 1d5:	c7 45 f4 a0 10 00 00 	movl   $0x10a0,-0xc(%ebp)
 1dc:	eb 14                	jmp    1f2 <thread_create+0x39>
    if (t->state == FREE) break;
 1de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e1:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 1e7:	85 c0                	test   %eax,%eax
 1e9:	74 13                	je     1fe <thread_create+0x45>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 1eb:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 1f2:	b8 f0 50 01 00       	mov    $0x150f0,%eax
 1f7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 1fa:	72 e2                	jb     1de <thread_create+0x25>
 1fc:	eb 01                	jmp    1ff <thread_create+0x46>
    if (t->state == FREE) break;
 1fe:	90                   	nop
  }
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 1ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 202:	83 c0 04             	add    $0x4,%eax
 205:	05 fc 1f 00 00       	add    $0x1ffc,%eax
 20a:	89 c2                	mov    %eax,%edx
 20c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 20f:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                              // space for return address
 211:	8b 45 f4             	mov    -0xc(%ebp),%eax
 214:	8b 00                	mov    (%eax),%eax
 216:	8d 50 fc             	lea    -0x4(%eax),%edx
 219:	8b 45 f4             	mov    -0xc(%ebp),%eax
 21c:	89 10                	mov    %edx,(%eax)
  * (int *) (t->sp) = (int)func;           // push return address on stack
 21e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 221:	8b 00                	mov    (%eax),%eax
 223:	89 c2                	mov    %eax,%edx
 225:	8b 45 08             	mov    0x8(%ebp),%eax
 228:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                             // space for registers that thread_switch expects
 22a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22d:	8b 00                	mov    (%eax),%eax
 22f:	8d 50 e0             	lea    -0x20(%eax),%edx
 232:	8b 45 f4             	mov    -0xc(%ebp),%eax
 235:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 237:	8b 45 f4             	mov    -0xc(%ebp),%eax
 23a:	c7 80 00 20 00 00 02 	movl   $0x2,0x2000(%eax)
 241:	00 00 00 
  thread_count(1);
 244:	83 ec 0c             	sub    $0xc,%esp
 247:	6a 01                	push   $0x1
 249:	e8 b3 05 00 00       	call   801 <thread_count>
 24e:	83 c4 10             	add    $0x10,%esp
  t->tid = t - all_thread;
 251:	8b 45 f4             	mov    -0xc(%ebp),%eax
 254:	2d a0 10 00 00       	sub    $0x10a0,%eax
 259:	c1 f8 03             	sar    $0x3,%eax
 25c:	69 c0 01 fc 0f c0    	imul   $0xc00ffc01,%eax,%eax
 262:	89 c2                	mov    %eax,%edx
 264:	8b 45 f4             	mov    -0xc(%ebp),%eax
 267:	89 90 04 20 00 00    	mov    %edx,0x2004(%eax)
  return t->tid;
 26d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 270:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
}
 276:	c9                   	leave
 277:	c3                   	ret

00000278 <thread_suspend>:

static void 
thread_suspend(int tid)
{
 278:	f3 0f 1e fb          	endbr32
 27c:	55                   	push   %ebp
 27d:	89 e5                	mov    %esp,%ebp
 27f:	83 ec 18             	sub    $0x18,%esp
  printf(1, "thread_suspend\n");
 282:	83 ec 08             	sub    $0x8,%esp
 285:	68 e1 0c 00 00       	push   $0xce1
 28a:	6a 01                	push   $0x1
 28c:	e8 54 06 00 00       	call   8e5 <printf>
 291:	83 c4 10             	add    $0x10,%esp
  thread_p t = &all_thread[tid];
 294:	8b 45 08             	mov    0x8(%ebp),%eax
 297:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
 29d:	05 a0 10 00 00       	add    $0x10a0,%eax
 2a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  t->state = WAIT;
 2a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a8:	c7 80 00 20 00 00 03 	movl   $0x3,0x2000(%eax)
 2af:	00 00 00 
  thread_schedule();
 2b2:	e8 d4 fd ff ff       	call   8b <thread_schedule>
}
 2b7:	90                   	nop
 2b8:	c9                   	leave
 2b9:	c3                   	ret

000002ba <thread_resume>:

static void 
thread_resume(int tid)
{
 2ba:	f3 0f 1e fb          	endbr32
 2be:	55                   	push   %ebp
 2bf:	89 e5                	mov    %esp,%ebp
 2c1:	83 ec 18             	sub    $0x18,%esp
  printf(1, "thread_resume\n");
 2c4:	83 ec 08             	sub    $0x8,%esp
 2c7:	68 f1 0c 00 00       	push   $0xcf1
 2cc:	6a 01                	push   $0x1
 2ce:	e8 12 06 00 00       	call   8e5 <printf>
 2d3:	83 c4 10             	add    $0x10,%esp
  thread_p t = &all_thread[tid];
 2d6:	8b 45 08             	mov    0x8(%ebp),%eax
 2d9:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
 2df:	05 a0 10 00 00       	add    $0x10a0,%eax
 2e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (t->state == WAIT) {
 2e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ea:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 2f0:	83 f8 03             	cmp    $0x3,%eax
 2f3:	75 0d                	jne    302 <thread_resume+0x48>
    t->state = RUNNABLE;
 2f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f8:	c7 80 00 20 00 00 02 	movl   $0x2,0x2000(%eax)
 2ff:	00 00 00 
  }
  thread_schedule();
 302:	e8 84 fd ff ff       	call   8b <thread_schedule>
}
 307:	90                   	nop
 308:	c9                   	leave
 309:	c3                   	ret

0000030a <mythread>:

static void 
mythread(void)
{
 30a:	f3 0f 1e fb          	endbr32
 30e:	55                   	push   %ebp
 30f:	89 e5                	mov    %esp,%ebp
 311:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "my thread running\n");
 314:	83 ec 08             	sub    $0x8,%esp
 317:	68 00 0d 00 00       	push   $0xd00
 31c:	6a 01                	push   $0x1
 31e:	e8 c2 05 00 00       	call   8e5 <printf>
 323:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 326:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 32d:	eb 22                	jmp    351 <mythread+0x47>
    printf(1, "my thread %d\n", current_thread->tid);
 32f:	a1 fc 50 01 00       	mov    0x150fc,%eax
 334:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 33a:	83 ec 04             	sub    $0x4,%esp
 33d:	50                   	push   %eax
 33e:	68 13 0d 00 00       	push   $0xd13
 343:	6a 01                	push   $0x1
 345:	e8 9b 05 00 00       	call   8e5 <printf>
 34a:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 34d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 351:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 355:	7e d8                	jle    32f <mythread+0x25>
  }
  printf(1, "my thread: exit\n");
 357:	83 ec 08             	sub    $0x8,%esp
 35a:	68 21 0d 00 00       	push   $0xd21
 35f:	6a 01                	push   $0x1
 361:	e8 7f 05 00 00       	call   8e5 <printf>
 366:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 369:	a1 fc 50 01 00       	mov    0x150fc,%eax
 36e:	c7 80 00 20 00 00 00 	movl   $0x0,0x2000(%eax)
 375:	00 00 00 
  thread_count(-1);
 378:	83 ec 0c             	sub    $0xc,%esp
 37b:	6a ff                	push   $0xffffffff
 37d:	e8 7f 04 00 00       	call   801 <thread_count>
 382:	83 c4 10             	add    $0x10,%esp
}
 385:	90                   	nop
 386:	c9                   	leave
 387:	c3                   	ret

00000388 <uthread_sleep>:
void
uthread_sleep(int ticks)
{
 388:	f3 0f 1e fb          	endbr32
 38c:	55                   	push   %ebp
 38d:	89 e5                	mov    %esp,%ebp
 38f:	83 ec 18             	sub    $0x18,%esp
  int i;
  for (i = 0; i < ticks * 10; i++) {
 392:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 399:	eb 3d                	jmp    3d8 <uthread_sleep+0x50>
    if (ticks % 10 == 0) {
 39b:	8b 4d 08             	mov    0x8(%ebp),%ecx
 39e:	ba 67 66 66 66       	mov    $0x66666667,%edx
 3a3:	89 c8                	mov    %ecx,%eax
 3a5:	f7 ea                	imul   %edx
 3a7:	c1 fa 02             	sar    $0x2,%edx
 3aa:	89 c8                	mov    %ecx,%eax
 3ac:	c1 f8 1f             	sar    $0x1f,%eax
 3af:	29 c2                	sub    %eax,%edx
 3b1:	89 d0                	mov    %edx,%eax
 3b3:	c1 e0 02             	shl    $0x2,%eax
 3b6:	01 d0                	add    %edx,%eax
 3b8:	01 c0                	add    %eax,%eax
 3ba:	29 c1                	sub    %eax,%ecx
 3bc:	89 ca                	mov    %ecx,%edx
 3be:	85 d2                	test   %edx,%edx
 3c0:	75 12                	jne    3d4 <uthread_sleep+0x4c>
      printf(1, "");
 3c2:	83 ec 08             	sub    $0x8,%esp
 3c5:	68 32 0d 00 00       	push   $0xd32
 3ca:	6a 01                	push   $0x1
 3cc:	e8 14 05 00 00       	call   8e5 <printf>
 3d1:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < ticks * 10; i++) {
 3d4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3d8:	8b 55 08             	mov    0x8(%ebp),%edx
 3db:	89 d0                	mov    %edx,%eax
 3dd:	c1 e0 02             	shl    $0x2,%eax
 3e0:	01 d0                	add    %edx,%eax
 3e2:	01 c0                	add    %eax,%eax
 3e4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 3e7:	7c b2                	jl     39b <uthread_sleep+0x13>
    }
  }
}
 3e9:	90                   	nop
 3ea:	90                   	nop
 3eb:	c9                   	leave
 3ec:	c3                   	ret

000003ed <main>:

int 
main(int argc, char *argv[]) 
{
 3ed:	f3 0f 1e fb          	endbr32
 3f1:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 3f5:	83 e4 f0             	and    $0xfffffff0,%esp
 3f8:	ff 71 fc             	push   -0x4(%ecx)
 3fb:	55                   	push   %ebp
 3fc:	89 e5                	mov    %esp,%ebp
 3fe:	51                   	push   %ecx
 3ff:	83 ec 14             	sub    $0x14,%esp
  printf(1,"main on \n");
 402:	83 ec 08             	sub    $0x8,%esp
 405:	68 33 0d 00 00       	push   $0xd33
 40a:	6a 01                	push   $0x1
 40c:	e8 d4 04 00 00       	call   8e5 <printf>
 411:	83 c4 10             	add    $0x10,%esp
  int tid1, tid2;
  thread_init();
 414:	e8 e7 fb ff ff       	call   0 <thread_init>
  tid1=thread_create(mythread);
 419:	83 ec 0c             	sub    $0xc,%esp
 41c:	68 0a 03 00 00       	push   $0x30a
 421:	e8 93 fd ff ff       	call   1b9 <thread_create>
 426:	83 c4 10             	add    $0x10,%esp
 429:	89 45 f4             	mov    %eax,-0xc(%ebp)
  tid2=thread_create(mythread);
 42c:	83 ec 0c             	sub    $0xc,%esp
 42f:	68 0a 03 00 00       	push   $0x30a
 434:	e8 80 fd ff ff       	call   1b9 <thread_create>
 439:	83 c4 10             	add    $0x10,%esp
 43c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  thread_schedule();
 43f:	e8 47 fc ff ff       	call   8b <thread_schedule>
  uthread_sleep(300); /* you can adjust the sleep time */
 444:	83 ec 0c             	sub    $0xc,%esp
 447:	68 2c 01 00 00       	push   $0x12c
 44c:	e8 37 ff ff ff       	call   388 <uthread_sleep>
 451:	83 c4 10             	add    $0x10,%esp
  thread_suspend(tid1);
 454:	83 ec 0c             	sub    $0xc,%esp
 457:	ff 75 f4             	push   -0xc(%ebp)
 45a:	e8 19 fe ff ff       	call   278 <thread_suspend>
 45f:	83 c4 10             	add    $0x10,%esp
  uthread_sleep(300);
 462:	83 ec 0c             	sub    $0xc,%esp
 465:	68 2c 01 00 00       	push   $0x12c
 46a:	e8 19 ff ff ff       	call   388 <uthread_sleep>
 46f:	83 c4 10             	add    $0x10,%esp
  thread_suspend(tid2);
 472:	83 ec 0c             	sub    $0xc,%esp
 475:	ff 75 f0             	push   -0x10(%ebp)
 478:	e8 fb fd ff ff       	call   278 <thread_suspend>
 47d:	83 c4 10             	add    $0x10,%esp
  thread_resume(tid1);
 480:	83 ec 0c             	sub    $0xc,%esp
 483:	ff 75 f4             	push   -0xc(%ebp)
 486:	e8 2f fe ff ff       	call   2ba <thread_resume>
 48b:	83 c4 10             	add    $0x10,%esp
  uthread_sleep(300);
 48e:	83 ec 0c             	sub    $0xc,%esp
 491:	68 2c 01 00 00       	push   $0x12c
 496:	e8 ed fe ff ff       	call   388 <uthread_sleep>
 49b:	83 c4 10             	add    $0x10,%esp
  thread_resume(tid2);
 49e:	83 ec 0c             	sub    $0xc,%esp
 4a1:	ff 75 f0             	push   -0x10(%ebp)
 4a4:	e8 11 fe ff ff       	call   2ba <thread_resume>
 4a9:	83 c4 10             	add    $0x10,%esp
  uthread_sleep(10);
 4ac:	83 ec 0c             	sub    $0xc,%esp
 4af:	6a 0a                	push   $0xa
 4b1:	e8 d2 fe ff ff       	call   388 <uthread_sleep>
 4b6:	83 c4 10             	add    $0x10,%esp
  exit();
 4b9:	e8 9b 02 00 00       	call   759 <exit>

000004be <thread_switch>:
         */
    .text
    .globl thread_switch
thread_switch:
    // 레지스터 저장
    pushal
 4be:	60                   	pusha

    // eax에 current_thread 저장
    // esp에 바로 못넘김
    movl current_thread, %eax
 4bf:	a1 fc 50 01 00       	mov    0x150fc,%eax
    // current_thread = esp
    // esp에는 전에 저장해놨던 thread의 주소가 있음
    movl %esp, (%eax)
 4c4:	89 20                	mov    %esp,(%eax)

    // 다음 실행할 쓰레드 저장 eax에 담아서 esp에 저장
    movl next_thread, %eax
 4c6:	a1 00 51 01 00       	mov    0x15100,%eax
    movl (%eax), %esp
 4cb:	8b 20                	mov    (%eax),%esp

    // current_thread = next_thread
    movl %eax, current_thread
 4cd:	a3 fc 50 01 00       	mov    %eax,0x150fc

    // 레지스터 복구
    popal
 4d2:	61                   	popa

    // next_thread = 0
    movl $0, next_thread
 4d3:	c7 05 00 51 01 00 00 	movl   $0x0,0x15100
 4da:	00 00 00 
    
    // 다시 원래 실행하던 곳으로 점프
    // esp에 next_thread주소를 넣고 current_thread와 next_thread를 바꿔놓았기 때문에
    // contextSwitching이 된 상태로 돌아간다.
    ret   
 4dd:	c3                   	ret

000004de <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 4de:	55                   	push   %ebp
 4df:	89 e5                	mov    %esp,%ebp
 4e1:	57                   	push   %edi
 4e2:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 4e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
 4e6:	8b 55 10             	mov    0x10(%ebp),%edx
 4e9:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ec:	89 cb                	mov    %ecx,%ebx
 4ee:	89 df                	mov    %ebx,%edi
 4f0:	89 d1                	mov    %edx,%ecx
 4f2:	fc                   	cld
 4f3:	f3 aa                	rep stos %al,%es:(%edi)
 4f5:	89 ca                	mov    %ecx,%edx
 4f7:	89 fb                	mov    %edi,%ebx
 4f9:	89 5d 08             	mov    %ebx,0x8(%ebp)
 4fc:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 4ff:	90                   	nop
 500:	5b                   	pop    %ebx
 501:	5f                   	pop    %edi
 502:	5d                   	pop    %ebp
 503:	c3                   	ret

00000504 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 504:	f3 0f 1e fb          	endbr32
 508:	55                   	push   %ebp
 509:	89 e5                	mov    %esp,%ebp
 50b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 50e:	8b 45 08             	mov    0x8(%ebp),%eax
 511:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 514:	90                   	nop
 515:	8b 55 0c             	mov    0xc(%ebp),%edx
 518:	8d 42 01             	lea    0x1(%edx),%eax
 51b:	89 45 0c             	mov    %eax,0xc(%ebp)
 51e:	8b 45 08             	mov    0x8(%ebp),%eax
 521:	8d 48 01             	lea    0x1(%eax),%ecx
 524:	89 4d 08             	mov    %ecx,0x8(%ebp)
 527:	0f b6 12             	movzbl (%edx),%edx
 52a:	88 10                	mov    %dl,(%eax)
 52c:	0f b6 00             	movzbl (%eax),%eax
 52f:	84 c0                	test   %al,%al
 531:	75 e2                	jne    515 <strcpy+0x11>
    ;
  return os;
 533:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 536:	c9                   	leave
 537:	c3                   	ret

00000538 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 538:	f3 0f 1e fb          	endbr32
 53c:	55                   	push   %ebp
 53d:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 53f:	eb 08                	jmp    549 <strcmp+0x11>
    p++, q++;
 541:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 545:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 549:	8b 45 08             	mov    0x8(%ebp),%eax
 54c:	0f b6 00             	movzbl (%eax),%eax
 54f:	84 c0                	test   %al,%al
 551:	74 10                	je     563 <strcmp+0x2b>
 553:	8b 45 08             	mov    0x8(%ebp),%eax
 556:	0f b6 10             	movzbl (%eax),%edx
 559:	8b 45 0c             	mov    0xc(%ebp),%eax
 55c:	0f b6 00             	movzbl (%eax),%eax
 55f:	38 c2                	cmp    %al,%dl
 561:	74 de                	je     541 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 563:	8b 45 08             	mov    0x8(%ebp),%eax
 566:	0f b6 00             	movzbl (%eax),%eax
 569:	0f b6 d0             	movzbl %al,%edx
 56c:	8b 45 0c             	mov    0xc(%ebp),%eax
 56f:	0f b6 00             	movzbl (%eax),%eax
 572:	0f b6 c0             	movzbl %al,%eax
 575:	29 c2                	sub    %eax,%edx
 577:	89 d0                	mov    %edx,%eax
}
 579:	5d                   	pop    %ebp
 57a:	c3                   	ret

0000057b <strlen>:

uint
strlen(char *s)
{
 57b:	f3 0f 1e fb          	endbr32
 57f:	55                   	push   %ebp
 580:	89 e5                	mov    %esp,%ebp
 582:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 585:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 58c:	eb 04                	jmp    592 <strlen+0x17>
 58e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 592:	8b 55 fc             	mov    -0x4(%ebp),%edx
 595:	8b 45 08             	mov    0x8(%ebp),%eax
 598:	01 d0                	add    %edx,%eax
 59a:	0f b6 00             	movzbl (%eax),%eax
 59d:	84 c0                	test   %al,%al
 59f:	75 ed                	jne    58e <strlen+0x13>
    ;
  return n;
 5a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5a4:	c9                   	leave
 5a5:	c3                   	ret

000005a6 <memset>:

void*
memset(void *dst, int c, uint n)
{
 5a6:	f3 0f 1e fb          	endbr32
 5aa:	55                   	push   %ebp
 5ab:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 5ad:	8b 45 10             	mov    0x10(%ebp),%eax
 5b0:	50                   	push   %eax
 5b1:	ff 75 0c             	push   0xc(%ebp)
 5b4:	ff 75 08             	push   0x8(%ebp)
 5b7:	e8 22 ff ff ff       	call   4de <stosb>
 5bc:	83 c4 0c             	add    $0xc,%esp
  return dst;
 5bf:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5c2:	c9                   	leave
 5c3:	c3                   	ret

000005c4 <strchr>:

char*
strchr(const char *s, char c)
{
 5c4:	f3 0f 1e fb          	endbr32
 5c8:	55                   	push   %ebp
 5c9:	89 e5                	mov    %esp,%ebp
 5cb:	83 ec 04             	sub    $0x4,%esp
 5ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d1:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 5d4:	eb 14                	jmp    5ea <strchr+0x26>
    if(*s == c)
 5d6:	8b 45 08             	mov    0x8(%ebp),%eax
 5d9:	0f b6 00             	movzbl (%eax),%eax
 5dc:	38 45 fc             	cmp    %al,-0x4(%ebp)
 5df:	75 05                	jne    5e6 <strchr+0x22>
      return (char*)s;
 5e1:	8b 45 08             	mov    0x8(%ebp),%eax
 5e4:	eb 13                	jmp    5f9 <strchr+0x35>
  for(; *s; s++)
 5e6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5ea:	8b 45 08             	mov    0x8(%ebp),%eax
 5ed:	0f b6 00             	movzbl (%eax),%eax
 5f0:	84 c0                	test   %al,%al
 5f2:	75 e2                	jne    5d6 <strchr+0x12>
  return 0;
 5f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
 5f9:	c9                   	leave
 5fa:	c3                   	ret

000005fb <gets>:

char*
gets(char *buf, int max)
{
 5fb:	f3 0f 1e fb          	endbr32
 5ff:	55                   	push   %ebp
 600:	89 e5                	mov    %esp,%ebp
 602:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 605:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 60c:	eb 42                	jmp    650 <gets+0x55>
    cc = read(0, &c, 1);
 60e:	83 ec 04             	sub    $0x4,%esp
 611:	6a 01                	push   $0x1
 613:	8d 45 ef             	lea    -0x11(%ebp),%eax
 616:	50                   	push   %eax
 617:	6a 00                	push   $0x0
 619:	e8 53 01 00 00       	call   771 <read>
 61e:	83 c4 10             	add    $0x10,%esp
 621:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 624:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 628:	7e 33                	jle    65d <gets+0x62>
      break;
    buf[i++] = c;
 62a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 62d:	8d 50 01             	lea    0x1(%eax),%edx
 630:	89 55 f4             	mov    %edx,-0xc(%ebp)
 633:	89 c2                	mov    %eax,%edx
 635:	8b 45 08             	mov    0x8(%ebp),%eax
 638:	01 c2                	add    %eax,%edx
 63a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 63e:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 640:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 644:	3c 0a                	cmp    $0xa,%al
 646:	74 16                	je     65e <gets+0x63>
 648:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 64c:	3c 0d                	cmp    $0xd,%al
 64e:	74 0e                	je     65e <gets+0x63>
  for(i=0; i+1 < max; ){
 650:	8b 45 f4             	mov    -0xc(%ebp),%eax
 653:	83 c0 01             	add    $0x1,%eax
 656:	39 45 0c             	cmp    %eax,0xc(%ebp)
 659:	7f b3                	jg     60e <gets+0x13>
 65b:	eb 01                	jmp    65e <gets+0x63>
      break;
 65d:	90                   	nop
      break;
  }
  buf[i] = '\0';
 65e:	8b 55 f4             	mov    -0xc(%ebp),%edx
 661:	8b 45 08             	mov    0x8(%ebp),%eax
 664:	01 d0                	add    %edx,%eax
 666:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 669:	8b 45 08             	mov    0x8(%ebp),%eax
}
 66c:	c9                   	leave
 66d:	c3                   	ret

0000066e <stat>:

int
stat(char *n, struct stat *st)
{
 66e:	f3 0f 1e fb          	endbr32
 672:	55                   	push   %ebp
 673:	89 e5                	mov    %esp,%ebp
 675:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 678:	83 ec 08             	sub    $0x8,%esp
 67b:	6a 00                	push   $0x0
 67d:	ff 75 08             	push   0x8(%ebp)
 680:	e8 14 01 00 00       	call   799 <open>
 685:	83 c4 10             	add    $0x10,%esp
 688:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 68b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 68f:	79 07                	jns    698 <stat+0x2a>
    return -1;
 691:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 696:	eb 25                	jmp    6bd <stat+0x4f>
  r = fstat(fd, st);
 698:	83 ec 08             	sub    $0x8,%esp
 69b:	ff 75 0c             	push   0xc(%ebp)
 69e:	ff 75 f4             	push   -0xc(%ebp)
 6a1:	e8 0b 01 00 00       	call   7b1 <fstat>
 6a6:	83 c4 10             	add    $0x10,%esp
 6a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 6ac:	83 ec 0c             	sub    $0xc,%esp
 6af:	ff 75 f4             	push   -0xc(%ebp)
 6b2:	e8 ca 00 00 00       	call   781 <close>
 6b7:	83 c4 10             	add    $0x10,%esp
  return r;
 6ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 6bd:	c9                   	leave
 6be:	c3                   	ret

000006bf <atoi>:

int
atoi(const char *s)
{
 6bf:	f3 0f 1e fb          	endbr32
 6c3:	55                   	push   %ebp
 6c4:	89 e5                	mov    %esp,%ebp
 6c6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 6c9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 6d0:	eb 25                	jmp    6f7 <atoi+0x38>
    n = n*10 + *s++ - '0';
 6d2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 6d5:	89 d0                	mov    %edx,%eax
 6d7:	c1 e0 02             	shl    $0x2,%eax
 6da:	01 d0                	add    %edx,%eax
 6dc:	01 c0                	add    %eax,%eax
 6de:	89 c1                	mov    %eax,%ecx
 6e0:	8b 45 08             	mov    0x8(%ebp),%eax
 6e3:	8d 50 01             	lea    0x1(%eax),%edx
 6e6:	89 55 08             	mov    %edx,0x8(%ebp)
 6e9:	0f b6 00             	movzbl (%eax),%eax
 6ec:	0f be c0             	movsbl %al,%eax
 6ef:	01 c8                	add    %ecx,%eax
 6f1:	83 e8 30             	sub    $0x30,%eax
 6f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 6f7:	8b 45 08             	mov    0x8(%ebp),%eax
 6fa:	0f b6 00             	movzbl (%eax),%eax
 6fd:	3c 2f                	cmp    $0x2f,%al
 6ff:	7e 0a                	jle    70b <atoi+0x4c>
 701:	8b 45 08             	mov    0x8(%ebp),%eax
 704:	0f b6 00             	movzbl (%eax),%eax
 707:	3c 39                	cmp    $0x39,%al
 709:	7e c7                	jle    6d2 <atoi+0x13>
  return n;
 70b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 70e:	c9                   	leave
 70f:	c3                   	ret

00000710 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 710:	f3 0f 1e fb          	endbr32
 714:	55                   	push   %ebp
 715:	89 e5                	mov    %esp,%ebp
 717:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 71a:	8b 45 08             	mov    0x8(%ebp),%eax
 71d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 720:	8b 45 0c             	mov    0xc(%ebp),%eax
 723:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 726:	eb 17                	jmp    73f <memmove+0x2f>
    *dst++ = *src++;
 728:	8b 55 f8             	mov    -0x8(%ebp),%edx
 72b:	8d 42 01             	lea    0x1(%edx),%eax
 72e:	89 45 f8             	mov    %eax,-0x8(%ebp)
 731:	8b 45 fc             	mov    -0x4(%ebp),%eax
 734:	8d 48 01             	lea    0x1(%eax),%ecx
 737:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 73a:	0f b6 12             	movzbl (%edx),%edx
 73d:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 73f:	8b 45 10             	mov    0x10(%ebp),%eax
 742:	8d 50 ff             	lea    -0x1(%eax),%edx
 745:	89 55 10             	mov    %edx,0x10(%ebp)
 748:	85 c0                	test   %eax,%eax
 74a:	7f dc                	jg     728 <memmove+0x18>
  return vdst;
 74c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 74f:	c9                   	leave
 750:	c3                   	ret

00000751 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 751:	b8 01 00 00 00       	mov    $0x1,%eax
 756:	cd 40                	int    $0x40
 758:	c3                   	ret

00000759 <exit>:
SYSCALL(exit)
 759:	b8 02 00 00 00       	mov    $0x2,%eax
 75e:	cd 40                	int    $0x40
 760:	c3                   	ret

00000761 <wait>:
SYSCALL(wait)
 761:	b8 03 00 00 00       	mov    $0x3,%eax
 766:	cd 40                	int    $0x40
 768:	c3                   	ret

00000769 <pipe>:
SYSCALL(pipe)
 769:	b8 04 00 00 00       	mov    $0x4,%eax
 76e:	cd 40                	int    $0x40
 770:	c3                   	ret

00000771 <read>:
SYSCALL(read)
 771:	b8 05 00 00 00       	mov    $0x5,%eax
 776:	cd 40                	int    $0x40
 778:	c3                   	ret

00000779 <write>:
SYSCALL(write)
 779:	b8 10 00 00 00       	mov    $0x10,%eax
 77e:	cd 40                	int    $0x40
 780:	c3                   	ret

00000781 <close>:
SYSCALL(close)
 781:	b8 15 00 00 00       	mov    $0x15,%eax
 786:	cd 40                	int    $0x40
 788:	c3                   	ret

00000789 <kill>:
SYSCALL(kill)
 789:	b8 06 00 00 00       	mov    $0x6,%eax
 78e:	cd 40                	int    $0x40
 790:	c3                   	ret

00000791 <exec>:
SYSCALL(exec)
 791:	b8 07 00 00 00       	mov    $0x7,%eax
 796:	cd 40                	int    $0x40
 798:	c3                   	ret

00000799 <open>:
SYSCALL(open)
 799:	b8 0f 00 00 00       	mov    $0xf,%eax
 79e:	cd 40                	int    $0x40
 7a0:	c3                   	ret

000007a1 <mknod>:
SYSCALL(mknod)
 7a1:	b8 11 00 00 00       	mov    $0x11,%eax
 7a6:	cd 40                	int    $0x40
 7a8:	c3                   	ret

000007a9 <unlink>:
SYSCALL(unlink)
 7a9:	b8 12 00 00 00       	mov    $0x12,%eax
 7ae:	cd 40                	int    $0x40
 7b0:	c3                   	ret

000007b1 <fstat>:
SYSCALL(fstat)
 7b1:	b8 08 00 00 00       	mov    $0x8,%eax
 7b6:	cd 40                	int    $0x40
 7b8:	c3                   	ret

000007b9 <link>:
SYSCALL(link)
 7b9:	b8 13 00 00 00       	mov    $0x13,%eax
 7be:	cd 40                	int    $0x40
 7c0:	c3                   	ret

000007c1 <mkdir>:
SYSCALL(mkdir)
 7c1:	b8 14 00 00 00       	mov    $0x14,%eax
 7c6:	cd 40                	int    $0x40
 7c8:	c3                   	ret

000007c9 <chdir>:
SYSCALL(chdir)
 7c9:	b8 09 00 00 00       	mov    $0x9,%eax
 7ce:	cd 40                	int    $0x40
 7d0:	c3                   	ret

000007d1 <dup>:
SYSCALL(dup)
 7d1:	b8 0a 00 00 00       	mov    $0xa,%eax
 7d6:	cd 40                	int    $0x40
 7d8:	c3                   	ret

000007d9 <getpid>:
SYSCALL(getpid)
 7d9:	b8 0b 00 00 00       	mov    $0xb,%eax
 7de:	cd 40                	int    $0x40
 7e0:	c3                   	ret

000007e1 <sbrk>:
SYSCALL(sbrk)
 7e1:	b8 0c 00 00 00       	mov    $0xc,%eax
 7e6:	cd 40                	int    $0x40
 7e8:	c3                   	ret

000007e9 <sleep>:
SYSCALL(sleep)
 7e9:	b8 0d 00 00 00       	mov    $0xd,%eax
 7ee:	cd 40                	int    $0x40
 7f0:	c3                   	ret

000007f1 <uptime>:
SYSCALL(uptime)
 7f1:	b8 0e 00 00 00       	mov    $0xe,%eax
 7f6:	cd 40                	int    $0x40
 7f8:	c3                   	ret

000007f9 <uthread_init>:

SYSCALL(uthread_init)
 7f9:	b8 16 00 00 00       	mov    $0x16,%eax
 7fe:	cd 40                	int    $0x40
 800:	c3                   	ret

00000801 <thread_count>:
SYSCALL(thread_count)
 801:	b8 17 00 00 00       	mov    $0x17,%eax
 806:	cd 40                	int    $0x40
 808:	c3                   	ret

00000809 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 809:	f3 0f 1e fb          	endbr32
 80d:	55                   	push   %ebp
 80e:	89 e5                	mov    %esp,%ebp
 810:	83 ec 18             	sub    $0x18,%esp
 813:	8b 45 0c             	mov    0xc(%ebp),%eax
 816:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 819:	83 ec 04             	sub    $0x4,%esp
 81c:	6a 01                	push   $0x1
 81e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 821:	50                   	push   %eax
 822:	ff 75 08             	push   0x8(%ebp)
 825:	e8 4f ff ff ff       	call   779 <write>
 82a:	83 c4 10             	add    $0x10,%esp
}
 82d:	90                   	nop
 82e:	c9                   	leave
 82f:	c3                   	ret

00000830 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 830:	f3 0f 1e fb          	endbr32
 834:	55                   	push   %ebp
 835:	89 e5                	mov    %esp,%ebp
 837:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 83a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 841:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 845:	74 17                	je     85e <printint+0x2e>
 847:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 84b:	79 11                	jns    85e <printint+0x2e>
    neg = 1;
 84d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 854:	8b 45 0c             	mov    0xc(%ebp),%eax
 857:	f7 d8                	neg    %eax
 859:	89 45 ec             	mov    %eax,-0x14(%ebp)
 85c:	eb 06                	jmp    864 <printint+0x34>
  } else {
    x = xx;
 85e:	8b 45 0c             	mov    0xc(%ebp),%eax
 861:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 864:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 86b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 86e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 871:	ba 00 00 00 00       	mov    $0x0,%edx
 876:	f7 f1                	div    %ecx
 878:	89 d1                	mov    %edx,%ecx
 87a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87d:	8d 50 01             	lea    0x1(%eax),%edx
 880:	89 55 f4             	mov    %edx,-0xc(%ebp)
 883:	0f b6 91 68 10 00 00 	movzbl 0x1068(%ecx),%edx
 88a:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 88e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 891:	8b 45 ec             	mov    -0x14(%ebp),%eax
 894:	ba 00 00 00 00       	mov    $0x0,%edx
 899:	f7 f1                	div    %ecx
 89b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 89e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8a2:	75 c7                	jne    86b <printint+0x3b>
  if(neg)
 8a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8a8:	74 2d                	je     8d7 <printint+0xa7>
    buf[i++] = '-';
 8aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ad:	8d 50 01             	lea    0x1(%eax),%edx
 8b0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8b3:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 8b8:	eb 1d                	jmp    8d7 <printint+0xa7>
    putc(fd, buf[i]);
 8ba:	8d 55 dc             	lea    -0x24(%ebp),%edx
 8bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c0:	01 d0                	add    %edx,%eax
 8c2:	0f b6 00             	movzbl (%eax),%eax
 8c5:	0f be c0             	movsbl %al,%eax
 8c8:	83 ec 08             	sub    $0x8,%esp
 8cb:	50                   	push   %eax
 8cc:	ff 75 08             	push   0x8(%ebp)
 8cf:	e8 35 ff ff ff       	call   809 <putc>
 8d4:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 8d7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 8db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8df:	79 d9                	jns    8ba <printint+0x8a>
}
 8e1:	90                   	nop
 8e2:	90                   	nop
 8e3:	c9                   	leave
 8e4:	c3                   	ret

000008e5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 8e5:	f3 0f 1e fb          	endbr32
 8e9:	55                   	push   %ebp
 8ea:	89 e5                	mov    %esp,%ebp
 8ec:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 8ef:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 8f6:	8d 45 0c             	lea    0xc(%ebp),%eax
 8f9:	83 c0 04             	add    $0x4,%eax
 8fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 8ff:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 906:	e9 59 01 00 00       	jmp    a64 <printf+0x17f>
    c = fmt[i] & 0xff;
 90b:	8b 55 0c             	mov    0xc(%ebp),%edx
 90e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 911:	01 d0                	add    %edx,%eax
 913:	0f b6 00             	movzbl (%eax),%eax
 916:	0f be c0             	movsbl %al,%eax
 919:	25 ff 00 00 00       	and    $0xff,%eax
 91e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 921:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 925:	75 2c                	jne    953 <printf+0x6e>
      if(c == '%'){
 927:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 92b:	75 0c                	jne    939 <printf+0x54>
        state = '%';
 92d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 934:	e9 27 01 00 00       	jmp    a60 <printf+0x17b>
      } else {
        putc(fd, c);
 939:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 93c:	0f be c0             	movsbl %al,%eax
 93f:	83 ec 08             	sub    $0x8,%esp
 942:	50                   	push   %eax
 943:	ff 75 08             	push   0x8(%ebp)
 946:	e8 be fe ff ff       	call   809 <putc>
 94b:	83 c4 10             	add    $0x10,%esp
 94e:	e9 0d 01 00 00       	jmp    a60 <printf+0x17b>
      }
    } else if(state == '%'){
 953:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 957:	0f 85 03 01 00 00    	jne    a60 <printf+0x17b>
      if(c == 'd'){
 95d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 961:	75 1e                	jne    981 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 963:	8b 45 e8             	mov    -0x18(%ebp),%eax
 966:	8b 00                	mov    (%eax),%eax
 968:	6a 01                	push   $0x1
 96a:	6a 0a                	push   $0xa
 96c:	50                   	push   %eax
 96d:	ff 75 08             	push   0x8(%ebp)
 970:	e8 bb fe ff ff       	call   830 <printint>
 975:	83 c4 10             	add    $0x10,%esp
        ap++;
 978:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 97c:	e9 d8 00 00 00       	jmp    a59 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 981:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 985:	74 06                	je     98d <printf+0xa8>
 987:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 98b:	75 1e                	jne    9ab <printf+0xc6>
        printint(fd, *ap, 16, 0);
 98d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 990:	8b 00                	mov    (%eax),%eax
 992:	6a 00                	push   $0x0
 994:	6a 10                	push   $0x10
 996:	50                   	push   %eax
 997:	ff 75 08             	push   0x8(%ebp)
 99a:	e8 91 fe ff ff       	call   830 <printint>
 99f:	83 c4 10             	add    $0x10,%esp
        ap++;
 9a2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9a6:	e9 ae 00 00 00       	jmp    a59 <printf+0x174>
      } else if(c == 's'){
 9ab:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 9af:	75 43                	jne    9f4 <printf+0x10f>
        s = (char*)*ap;
 9b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9b4:	8b 00                	mov    (%eax),%eax
 9b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 9b9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 9bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9c1:	75 25                	jne    9e8 <printf+0x103>
          s = "(null)";
 9c3:	c7 45 f4 3d 0d 00 00 	movl   $0xd3d,-0xc(%ebp)
        while(*s != 0){
 9ca:	eb 1c                	jmp    9e8 <printf+0x103>
          putc(fd, *s);
 9cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cf:	0f b6 00             	movzbl (%eax),%eax
 9d2:	0f be c0             	movsbl %al,%eax
 9d5:	83 ec 08             	sub    $0x8,%esp
 9d8:	50                   	push   %eax
 9d9:	ff 75 08             	push   0x8(%ebp)
 9dc:	e8 28 fe ff ff       	call   809 <putc>
 9e1:	83 c4 10             	add    $0x10,%esp
          s++;
 9e4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 9e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9eb:	0f b6 00             	movzbl (%eax),%eax
 9ee:	84 c0                	test   %al,%al
 9f0:	75 da                	jne    9cc <printf+0xe7>
 9f2:	eb 65                	jmp    a59 <printf+0x174>
        }
      } else if(c == 'c'){
 9f4:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 9f8:	75 1d                	jne    a17 <printf+0x132>
        putc(fd, *ap);
 9fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9fd:	8b 00                	mov    (%eax),%eax
 9ff:	0f be c0             	movsbl %al,%eax
 a02:	83 ec 08             	sub    $0x8,%esp
 a05:	50                   	push   %eax
 a06:	ff 75 08             	push   0x8(%ebp)
 a09:	e8 fb fd ff ff       	call   809 <putc>
 a0e:	83 c4 10             	add    $0x10,%esp
        ap++;
 a11:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a15:	eb 42                	jmp    a59 <printf+0x174>
      } else if(c == '%'){
 a17:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a1b:	75 17                	jne    a34 <printf+0x14f>
        putc(fd, c);
 a1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a20:	0f be c0             	movsbl %al,%eax
 a23:	83 ec 08             	sub    $0x8,%esp
 a26:	50                   	push   %eax
 a27:	ff 75 08             	push   0x8(%ebp)
 a2a:	e8 da fd ff ff       	call   809 <putc>
 a2f:	83 c4 10             	add    $0x10,%esp
 a32:	eb 25                	jmp    a59 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a34:	83 ec 08             	sub    $0x8,%esp
 a37:	6a 25                	push   $0x25
 a39:	ff 75 08             	push   0x8(%ebp)
 a3c:	e8 c8 fd ff ff       	call   809 <putc>
 a41:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 a44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a47:	0f be c0             	movsbl %al,%eax
 a4a:	83 ec 08             	sub    $0x8,%esp
 a4d:	50                   	push   %eax
 a4e:	ff 75 08             	push   0x8(%ebp)
 a51:	e8 b3 fd ff ff       	call   809 <putc>
 a56:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 a59:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 a60:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a64:	8b 55 0c             	mov    0xc(%ebp),%edx
 a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a6a:	01 d0                	add    %edx,%eax
 a6c:	0f b6 00             	movzbl (%eax),%eax
 a6f:	84 c0                	test   %al,%al
 a71:	0f 85 94 fe ff ff    	jne    90b <printf+0x26>
    }
  }
}
 a77:	90                   	nop
 a78:	90                   	nop
 a79:	c9                   	leave
 a7a:	c3                   	ret

00000a7b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a7b:	f3 0f 1e fb          	endbr32
 a7f:	55                   	push   %ebp
 a80:	89 e5                	mov    %esp,%ebp
 a82:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a85:	8b 45 08             	mov    0x8(%ebp),%eax
 a88:	83 e8 08             	sub    $0x8,%eax
 a8b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a8e:	a1 f8 50 01 00       	mov    0x150f8,%eax
 a93:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a96:	eb 24                	jmp    abc <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a98:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a9b:	8b 00                	mov    (%eax),%eax
 a9d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 aa0:	72 12                	jb     ab4 <free+0x39>
 aa2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aa5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 aa8:	77 24                	ja     ace <free+0x53>
 aaa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aad:	8b 00                	mov    (%eax),%eax
 aaf:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 ab2:	72 1a                	jb     ace <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ab4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ab7:	8b 00                	mov    (%eax),%eax
 ab9:	89 45 fc             	mov    %eax,-0x4(%ebp)
 abc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 abf:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ac2:	76 d4                	jbe    a98 <free+0x1d>
 ac4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac7:	8b 00                	mov    (%eax),%eax
 ac9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 acc:	73 ca                	jae    a98 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 ace:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ad1:	8b 40 04             	mov    0x4(%eax),%eax
 ad4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 adb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ade:	01 c2                	add    %eax,%edx
 ae0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae3:	8b 00                	mov    (%eax),%eax
 ae5:	39 c2                	cmp    %eax,%edx
 ae7:	75 24                	jne    b0d <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 ae9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aec:	8b 50 04             	mov    0x4(%eax),%edx
 aef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af2:	8b 00                	mov    (%eax),%eax
 af4:	8b 40 04             	mov    0x4(%eax),%eax
 af7:	01 c2                	add    %eax,%edx
 af9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 afc:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 aff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b02:	8b 00                	mov    (%eax),%eax
 b04:	8b 10                	mov    (%eax),%edx
 b06:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b09:	89 10                	mov    %edx,(%eax)
 b0b:	eb 0a                	jmp    b17 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 b0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b10:	8b 10                	mov    (%eax),%edx
 b12:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b15:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b17:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b1a:	8b 40 04             	mov    0x4(%eax),%eax
 b1d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b24:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b27:	01 d0                	add    %edx,%eax
 b29:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b2c:	75 20                	jne    b4e <free+0xd3>
    p->s.size += bp->s.size;
 b2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b31:	8b 50 04             	mov    0x4(%eax),%edx
 b34:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b37:	8b 40 04             	mov    0x4(%eax),%eax
 b3a:	01 c2                	add    %eax,%edx
 b3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b3f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b42:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b45:	8b 10                	mov    (%eax),%edx
 b47:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b4a:	89 10                	mov    %edx,(%eax)
 b4c:	eb 08                	jmp    b56 <free+0xdb>
  } else
    p->s.ptr = bp;
 b4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b51:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b54:	89 10                	mov    %edx,(%eax)
  freep = p;
 b56:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b59:	a3 f8 50 01 00       	mov    %eax,0x150f8
}
 b5e:	90                   	nop
 b5f:	c9                   	leave
 b60:	c3                   	ret

00000b61 <morecore>:

static Header*
morecore(uint nu)
{
 b61:	f3 0f 1e fb          	endbr32
 b65:	55                   	push   %ebp
 b66:	89 e5                	mov    %esp,%ebp
 b68:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b6b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b72:	77 07                	ja     b7b <morecore+0x1a>
    nu = 4096;
 b74:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 b7b:	8b 45 08             	mov    0x8(%ebp),%eax
 b7e:	c1 e0 03             	shl    $0x3,%eax
 b81:	83 ec 0c             	sub    $0xc,%esp
 b84:	50                   	push   %eax
 b85:	e8 57 fc ff ff       	call   7e1 <sbrk>
 b8a:	83 c4 10             	add    $0x10,%esp
 b8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 b90:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 b94:	75 07                	jne    b9d <morecore+0x3c>
    return 0;
 b96:	b8 00 00 00 00       	mov    $0x0,%eax
 b9b:	eb 26                	jmp    bc3 <morecore+0x62>
  hp = (Header*)p;
 b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ba0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ba6:	8b 55 08             	mov    0x8(%ebp),%edx
 ba9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 bac:	8b 45 f0             	mov    -0x10(%ebp),%eax
 baf:	83 c0 08             	add    $0x8,%eax
 bb2:	83 ec 0c             	sub    $0xc,%esp
 bb5:	50                   	push   %eax
 bb6:	e8 c0 fe ff ff       	call   a7b <free>
 bbb:	83 c4 10             	add    $0x10,%esp
  return freep;
 bbe:	a1 f8 50 01 00       	mov    0x150f8,%eax
}
 bc3:	c9                   	leave
 bc4:	c3                   	ret

00000bc5 <malloc>:

void*
malloc(uint nbytes)
{
 bc5:	f3 0f 1e fb          	endbr32
 bc9:	55                   	push   %ebp
 bca:	89 e5                	mov    %esp,%ebp
 bcc:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bcf:	8b 45 08             	mov    0x8(%ebp),%eax
 bd2:	83 c0 07             	add    $0x7,%eax
 bd5:	c1 e8 03             	shr    $0x3,%eax
 bd8:	83 c0 01             	add    $0x1,%eax
 bdb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 bde:	a1 f8 50 01 00       	mov    0x150f8,%eax
 be3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 be6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 bea:	75 23                	jne    c0f <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 bec:	c7 45 f0 f0 50 01 00 	movl   $0x150f0,-0x10(%ebp)
 bf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bf6:	a3 f8 50 01 00       	mov    %eax,0x150f8
 bfb:	a1 f8 50 01 00       	mov    0x150f8,%eax
 c00:	a3 f0 50 01 00       	mov    %eax,0x150f0
    base.s.size = 0;
 c05:	c7 05 f4 50 01 00 00 	movl   $0x0,0x150f4
 c0c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c12:	8b 00                	mov    (%eax),%eax
 c14:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c1a:	8b 40 04             	mov    0x4(%eax),%eax
 c1d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 c20:	77 4d                	ja     c6f <malloc+0xaa>
      if(p->s.size == nunits)
 c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c25:	8b 40 04             	mov    0x4(%eax),%eax
 c28:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 c2b:	75 0c                	jne    c39 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c30:	8b 10                	mov    (%eax),%edx
 c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c35:	89 10                	mov    %edx,(%eax)
 c37:	eb 26                	jmp    c5f <malloc+0x9a>
      else {
        p->s.size -= nunits;
 c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c3c:	8b 40 04             	mov    0x4(%eax),%eax
 c3f:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c42:	89 c2                	mov    %eax,%edx
 c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c47:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c4d:	8b 40 04             	mov    0x4(%eax),%eax
 c50:	c1 e0 03             	shl    $0x3,%eax
 c53:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c59:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c5c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c62:	a3 f8 50 01 00       	mov    %eax,0x150f8
      return (void*)(p + 1);
 c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c6a:	83 c0 08             	add    $0x8,%eax
 c6d:	eb 3b                	jmp    caa <malloc+0xe5>
    }
    if(p == freep)
 c6f:	a1 f8 50 01 00       	mov    0x150f8,%eax
 c74:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c77:	75 1e                	jne    c97 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 c79:	83 ec 0c             	sub    $0xc,%esp
 c7c:	ff 75 ec             	push   -0x14(%ebp)
 c7f:	e8 dd fe ff ff       	call   b61 <morecore>
 c84:	83 c4 10             	add    $0x10,%esp
 c87:	89 45 f4             	mov    %eax,-0xc(%ebp)
 c8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 c8e:	75 07                	jne    c97 <malloc+0xd2>
        return 0;
 c90:	b8 00 00 00 00       	mov    $0x0,%eax
 c95:	eb 13                	jmp    caa <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ca0:	8b 00                	mov    (%eax),%eax
 ca2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ca5:	e9 6d ff ff ff       	jmp    c17 <malloc+0x52>
  }
}
 caa:	c9                   	leave
 cab:	c3                   	ret
