
_uthread2:     file format elf32-i386


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
   6:	c7 05 44 0e 00 00 00 	movl   $0x0,0xe44
   d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 60 0e 00 00 	movl   $0xe60,-0xc(%ebp)
  17:	eb 41                	jmp    5a <thread_schedule+0x5a>
    //printf(1,"t: %x, state %x \n", t, t->state);
    if(t == &all_thread[0] && t->state == RUNNABLE){
  19:	81 7d f4 60 0e 00 00 	cmpl   $0xe60,-0xc(%ebp)
  20:	75 0e                	jne    30 <thread_schedule+0x30>
  22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  25:	8b 80 fc 1f 00 00    	mov    0x1ffc(%eax),%eax
  2b:	83 f8 02             	cmp    $0x2,%eax
  2e:	74 22                	je     52 <thread_schedule+0x52>
      continue;
    }
    if (t->state == RUNNABLE && t != current_thread) {
  30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  33:	8b 80 fc 1f 00 00    	mov    0x1ffc(%eax),%eax
  39:	83 f8 02             	cmp    $0x2,%eax
  3c:	75 15                	jne    53 <thread_schedule+0x53>
  3e:	a1 40 0e 00 00       	mov    0xe40,%eax
  43:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  46:	74 0b                	je     53 <thread_schedule+0x53>
      next_thread = t;
  48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4b:	a3 44 0e 00 00       	mov    %eax,0xe44
      break;
  50:	eb 12                	jmp    64 <thread_schedule+0x64>
      continue;
  52:	90                   	nop
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  53:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  5a:	b8 b0 4e 01 00       	mov    $0x14eb0,%eax
  5f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  62:	72 b5                	jb     19 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  64:	b8 b0 4e 01 00       	mov    $0x14eb0,%eax
  69:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  6c:	72 1a                	jb     88 <thread_schedule+0x88>
  6e:	a1 40 0e 00 00       	mov    0xe40,%eax
  73:	8b 80 fc 1f 00 00    	mov    0x1ffc(%eax),%eax
  79:	83 f8 02             	cmp    $0x2,%eax
  7c:	75 0a                	jne    88 <thread_schedule+0x88>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  7e:	a1 40 0e 00 00       	mov    0xe40,%eax
  83:	a3 44 0e 00 00       	mov    %eax,0xe44
  }

  if (next_thread == 0) {
  88:	a1 44 0e 00 00       	mov    0xe44,%eax
  8d:	85 c0                	test   %eax,%eax
  8f:	75 17                	jne    a8 <thread_schedule+0xa8>
    printf(2, "thread_schedule: no runnable threads\n");
  91:	83 ec 08             	sub    $0x8,%esp
  94:	68 44 0c 00 00       	push   $0xc44
  99:	6a 02                	push   $0x2
  9b:	e8 ea 07 00 00       	call   88a <printf>
  a0:	83 c4 10             	add    $0x10,%esp
    exit();
  a3:	e8 66 06 00 00       	call   70e <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  a8:	8b 15 40 0e 00 00    	mov    0xe40,%edx
  ae:	a1 44 0e 00 00       	mov    0xe44,%eax
  b3:	39 c2                	cmp    %eax,%edx
  b5:	74 34                	je     eb <thread_schedule+0xeb>
    next_thread->state = RUNNING;
  b7:	a1 44 0e 00 00       	mov    0xe44,%eax
  bc:	c7 80 fc 1f 00 00 01 	movl   $0x1,0x1ffc(%eax)
  c3:	00 00 00 
    if (current_thread->state != FREE)
  c6:	a1 40 0e 00 00       	mov    0xe40,%eax
  cb:	8b 80 fc 1f 00 00    	mov    0x1ffc(%eax),%eax
  d1:	85 c0                	test   %eax,%eax
  d3:	74 0f                	je     e4 <thread_schedule+0xe4>
      current_thread->state = RUNNABLE;
  d5:	a1 40 0e 00 00       	mov    0xe40,%eax
  da:	c7 80 fc 1f 00 00 02 	movl   $0x2,0x1ffc(%eax)
  e1:	00 00 00 
    thread_switch();
  e4:	e8 ae 03 00 00       	call   497 <thread_switch>
  } else
    next_thread = 0;
}
  e9:	eb 0a                	jmp    f5 <thread_schedule+0xf5>
    next_thread = 0;
  eb:	c7 05 44 0e 00 00 00 	movl   $0x0,0xe44
  f2:	00 00 00 
}
  f5:	90                   	nop
  f6:	c9                   	leave
  f7:	c3                   	ret

000000f8 <thread_init>:

void 
thread_init(void)
{
  f8:	55                   	push   %ebp
  f9:	89 e5                	mov    %esp,%ebp
  fb:	83 ec 08             	sub    $0x8,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  fe:	c7 05 40 0e 00 00 60 	movl   $0xe60,0xe40
 105:	0e 00 00 
  current_thread->state = RUNNING;
 108:	a1 40 0e 00 00       	mov    0xe40,%eax
 10d:	c7 80 fc 1f 00 00 01 	movl   $0x1,0x1ffc(%eax)
 114:	00 00 00 
  current_thread->tid=0;
 117:	a1 40 0e 00 00       	mov    0xe40,%eax
 11c:	c7 80 00 20 00 00 00 	movl   $0x0,0x2000(%eax)
 123:	00 00 00 
  current_thread->ptid=0;
 126:	a1 40 0e 00 00       	mov    0xe40,%eax
 12b:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 132:	00 00 00 

  uthread_init((int)thread_schedule);
 135:	b8 00 00 00 00       	mov    $0x0,%eax
 13a:	83 ec 0c             	sub    $0xc,%esp
 13d:	50                   	push   %eax
 13e:	e8 6b 06 00 00       	call   7ae <uthread_init>
 143:	83 c4 10             	add    $0x10,%esp
}
 146:	90                   	nop
 147:	c9                   	leave
 148:	c3                   	ret

00000149 <thread_create>:

void 
thread_create(void (*func)())
{
 149:	55                   	push   %ebp
 14a:	89 e5                	mov    %esp,%ebp
 14c:	83 ec 18             	sub    $0x18,%esp
  printf(1,"thread_create\n");
 14f:	83 ec 08             	sub    $0x8,%esp
 152:	68 6a 0c 00 00       	push   $0xc6a
 157:	6a 01                	push   $0x1
 159:	e8 2c 07 00 00       	call   88a <printf>
 15e:	83 c4 10             	add    $0x10,%esp
  
  thread_p t;
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 161:	c7 45 f4 60 0e 00 00 	movl   $0xe60,-0xc(%ebp)
 168:	eb 14                	jmp    17e <thread_create+0x35>
    if (t->state == FREE) break;
 16a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 16d:	8b 80 fc 1f 00 00    	mov    0x1ffc(%eax),%eax
 173:	85 c0                	test   %eax,%eax
 175:	74 13                	je     18a <thread_create+0x41>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 177:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 17e:	b8 b0 4e 01 00       	mov    $0x14eb0,%eax
 183:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 186:	72 e2                	jb     16a <thread_create+0x21>
 188:	eb 01                	jmp    18b <thread_create+0x42>
    if (t->state == FREE) break;
 18a:	90                   	nop
  }

  t->sp = (int)(t->stack + STACK_SIZE);
 18b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18e:	83 c0 04             	add    $0x4,%eax
 191:	05 f8 1f 00 00       	add    $0x1ff8,%eax
 196:	89 c2                	mov    %eax,%edx
 198:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19b:	89 10                	mov    %edx,(%eax)

  t->sp -= 4;
 19d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a0:	8b 00                	mov    (%eax),%eax
 1a2:	8d 50 fc             	lea    -0x4(%eax),%edx
 1a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a8:	89 10                	mov    %edx,(%eax)
  *(int *)(t->sp) = (int)func;  // 올바른 ret 주소 설정
 1aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ad:	8b 00                	mov    (%eax),%eax
 1af:	89 c2                	mov    %eax,%edx
 1b1:	8b 45 08             	mov    0x8(%ebp),%eax
 1b4:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                  // context는 그 아래
 1b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b9:	8b 00                	mov    (%eax),%eax
 1bb:	8d 50 e0             	lea    -0x20(%eax),%edx
 1be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c1:	89 10                	mov    %edx,(%eax)

  t->tid = t - all_thread;
 1c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c6:	2d 60 0e 00 00       	sub    $0xe60,%eax
 1cb:	c1 f8 03             	sar    $0x3,%eax
 1ce:	69 c0 01 fc 0f c0    	imul   $0xc00ffc01,%eax,%eax
 1d4:	89 c2                	mov    %eax,%edx
 1d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d9:	89 90 00 20 00 00    	mov    %edx,0x2000(%eax)
  t->ptid = current_thread->tid;
 1df:	a1 40 0e 00 00       	mov    0xe40,%eax
 1e4:	8b 90 00 20 00 00    	mov    0x2000(%eax),%edx
 1ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ed:	89 90 04 20 00 00    	mov    %edx,0x2004(%eax)
  t->state = RUNNABLE;
 1f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f6:	c7 80 fc 1f 00 00 02 	movl   $0x2,0x1ffc(%eax)
 1fd:	00 00 00 

  printf(1, "[create] tid=%d func address = 0x%x\n", t->tid, func);
 200:	8b 45 f4             	mov    -0xc(%ebp),%eax
 203:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 209:	ff 75 08             	push   0x8(%ebp)
 20c:	50                   	push   %eax
 20d:	68 7c 0c 00 00       	push   $0xc7c
 212:	6a 01                	push   $0x1
 214:	e8 71 06 00 00       	call   88a <printf>
 219:	83 c4 10             	add    $0x10,%esp
}
 21c:	90                   	nop
 21d:	c9                   	leave
 21e:	c3                   	ret

0000021f <thread_join_all>:

static void thread_join_all(void) {
 21f:	55                   	push   %ebp
 220:	89 e5                	mov    %esp,%ebp
 222:	83 ec 18             	sub    $0x18,%esp
  printf(1, "[thread_join_all] tid=%d waiting for children\n", current_thread->tid);
 225:	a1 40 0e 00 00       	mov    0xe40,%eax
 22a:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 230:	83 ec 04             	sub    $0x4,%esp
 233:	50                   	push   %eax
 234:	68 a4 0c 00 00       	push   $0xca4
 239:	6a 01                	push   $0x1
 23b:	e8 4a 06 00 00       	call   88a <printf>
 240:	83 c4 10             	add    $0x10,%esp
  
  // 현재 스레드가 대기 상태로 전환
  current_thread->state = WAIT;
 243:	a1 40 0e 00 00       	mov    0xe40,%eax
 248:	c7 80 fc 1f 00 00 03 	movl   $0x3,0x1ffc(%eax)
 24f:	00 00 00 
  
  while (1) {
    int child_alive = 0;
 252:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    // 자식 스레드 확인
    for (int i = 0; i < MAX_THREAD; i++) {
 259:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 260:	eb 40                	jmp    2a2 <thread_join_all+0x83>
      if (all_thread[i].state != FREE &&
 262:	8b 45 f0             	mov    -0x10(%ebp),%eax
 265:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
 26b:	05 5c 2e 00 00       	add    $0x2e5c,%eax
 270:	8b 00                	mov    (%eax),%eax
 272:	85 c0                	test   %eax,%eax
 274:	74 28                	je     29e <thread_join_all+0x7f>
          all_thread[i].ptid == current_thread->tid) {
 276:	8b 45 f0             	mov    -0x10(%ebp),%eax
 279:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
 27f:	05 64 2e 00 00       	add    $0x2e64,%eax
 284:	8b 10                	mov    (%eax),%edx
 286:	a1 40 0e 00 00       	mov    0xe40,%eax
 28b:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
      if (all_thread[i].state != FREE &&
 291:	39 c2                	cmp    %eax,%edx
 293:	75 09                	jne    29e <thread_join_all+0x7f>
        child_alive = 1;
 295:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        break;
 29c:	eb 0a                	jmp    2a8 <thread_join_all+0x89>
    for (int i = 0; i < MAX_THREAD; i++) {
 29e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 2a2:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
 2a6:	7e ba                	jle    262 <thread_join_all+0x43>
      }
    }

    // 모든 자식 스레드가 종료되면 대기 종료
    if (!child_alive) {
 2a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2ac:	75 11                	jne    2bf <thread_join_all+0xa0>
      current_thread->state = RUNNABLE;  // 대기 상태에서 실행 가능 상태로 변경
 2ae:	a1 40 0e 00 00       	mov    0xe40,%eax
 2b3:	c7 80 fc 1f 00 00 02 	movl   $0x2,0x1ffc(%eax)
 2ba:	00 00 00 
      break;
 2bd:	eb 6b                	jmp    32a <thread_join_all+0x10b>
    }

    // 실행 가능한 스레드 확인
    int has_runnable = 0;
 2bf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    for (int i = 0; i < MAX_THREAD; i++) {
 2c6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
 2cd:	eb 22                	jmp    2f1 <thread_join_all+0xd2>
      if (all_thread[i].state == RUNNABLE) {
 2cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
 2d2:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
 2d8:	05 5c 2e 00 00       	add    $0x2e5c,%eax
 2dd:	8b 00                	mov    (%eax),%eax
 2df:	83 f8 02             	cmp    $0x2,%eax
 2e2:	75 09                	jne    2ed <thread_join_all+0xce>
        has_runnable = 1;
 2e4:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
        break;
 2eb:	eb 0a                	jmp    2f7 <thread_join_all+0xd8>
    for (int i = 0; i < MAX_THREAD; i++) {
 2ed:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
 2f1:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 2f5:	7e d8                	jle    2cf <thread_join_all+0xb0>
      }
    }

    // 실행 가능한 스레드가 없으면 종료
    if (!has_runnable) {
 2f7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 2fb:	75 23                	jne    320 <thread_join_all+0x101>
      printf(1, "[join_all] No runnable threads left, exiting loop early\n");
 2fd:	83 ec 08             	sub    $0x8,%esp
 300:	68 d4 0c 00 00       	push   $0xcd4
 305:	6a 01                	push   $0x1
 307:	e8 7e 05 00 00       	call   88a <printf>
 30c:	83 c4 10             	add    $0x10,%esp
      current_thread->state = RUNNABLE;  // 대기 상태에서 실행 가능 상태로 변경
 30f:	a1 40 0e 00 00       	mov    0xe40,%eax
 314:	c7 80 fc 1f 00 00 02 	movl   $0x2,0x1ffc(%eax)
 31b:	00 00 00 
      break;
 31e:	eb 0a                	jmp    32a <thread_join_all+0x10b>
    }

    // 다른 스레드로 전환
    thread_schedule();
 320:	e8 db fc ff ff       	call   0 <thread_schedule>
  while (1) {
 325:	e9 28 ff ff ff       	jmp    252 <thread_join_all+0x33>
  }
  
  printf(1, "[thread_join_all] tid=%d all children finished\n", current_thread->tid);
 32a:	a1 40 0e 00 00       	mov    0xe40,%eax
 32f:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 335:	83 ec 04             	sub    $0x4,%esp
 338:	50                   	push   %eax
 339:	68 10 0d 00 00       	push   $0xd10
 33e:	6a 01                	push   $0x1
 340:	e8 45 05 00 00       	call   88a <printf>
 345:	83 c4 10             	add    $0x10,%esp
}
 348:	90                   	nop
 349:	c9                   	leave
 34a:	c3                   	ret

0000034b <child_thread>:

static void 
child_thread(void)
{
 34b:	55                   	push   %ebp
 34c:	89 e5                	mov    %esp,%ebp
 34e:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "[child] started: tid=%d, ptid=%d\n", current_thread->tid, current_thread->ptid);
 351:	a1 40 0e 00 00       	mov    0xe40,%eax
 356:	8b 90 04 20 00 00    	mov    0x2004(%eax),%edx
 35c:	a1 40 0e 00 00       	mov    0xe40,%eax
 361:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 367:	52                   	push   %edx
 368:	50                   	push   %eax
 369:	68 40 0d 00 00       	push   $0xd40
 36e:	6a 01                	push   $0x1
 370:	e8 15 05 00 00       	call   88a <printf>
 375:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 10; i++) {
 378:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 37f:	eb 1c                	jmp    39d <child_thread+0x52>
    printf(1, "[child] child thread 0x%x\n", (int) current_thread);
 381:	a1 40 0e 00 00       	mov    0xe40,%eax
 386:	83 ec 04             	sub    $0x4,%esp
 389:	50                   	push   %eax
 38a:	68 62 0d 00 00       	push   $0xd62
 38f:	6a 01                	push   $0x1
 391:	e8 f4 04 00 00       	call   88a <printf>
 396:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 10; i++) {
 399:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 39d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
 3a1:	7e de                	jle    381 <child_thread+0x36>
  }
  current_thread->state = FREE;
 3a3:	a1 40 0e 00 00       	mov    0xe40,%eax
 3a8:	c7 80 fc 1f 00 00 00 	movl   $0x0,0x1ffc(%eax)
 3af:	00 00 00 
  printf(1, "[child] tid=%d marking self FREE\n", current_thread->tid);
 3b2:	a1 40 0e 00 00       	mov    0xe40,%eax
 3b7:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 3bd:	83 ec 04             	sub    $0x4,%esp
 3c0:	50                   	push   %eax
 3c1:	68 80 0d 00 00       	push   $0xd80
 3c6:	6a 01                	push   $0x1
 3c8:	e8 bd 04 00 00       	call   88a <printf>
 3cd:	83 c4 10             	add    $0x10,%esp
  thread_schedule(); 
 3d0:	e8 2b fc ff ff       	call   0 <thread_schedule>
  printf(1, "[child] child thread: exit\n");
 3d5:	83 ec 08             	sub    $0x8,%esp
 3d8:	68 a2 0d 00 00       	push   $0xda2
 3dd:	6a 01                	push   $0x1
 3df:	e8 a6 04 00 00       	call   88a <printf>
 3e4:	83 c4 10             	add    $0x10,%esp
}
 3e7:	90                   	nop
 3e8:	c9                   	leave
 3e9:	c3                   	ret

000003ea <mythread>:

static void 
mythread(void)
{
 3ea:	55                   	push   %ebp
 3eb:	89 e5                	mov    %esp,%ebp
 3ed:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "[parent] mythread tid=%d creating children...\n", current_thread->tid);
 3f0:	a1 40 0e 00 00       	mov    0xe40,%eax
 3f5:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 3fb:	83 ec 04             	sub    $0x4,%esp
 3fe:	50                   	push   %eax
 3ff:	68 c0 0d 00 00       	push   $0xdc0
 404:	6a 01                	push   $0x1
 406:	e8 7f 04 00 00       	call   88a <printf>
 40b:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 40e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 415:	eb 14                	jmp    42b <mythread+0x41>
    thread_create(child_thread);
 417:	83 ec 0c             	sub    $0xc,%esp
 41a:	68 4b 03 00 00       	push   $0x34b
 41f:	e8 25 fd ff ff       	call   149 <thread_create>
 424:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 427:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 42b:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 42f:	7e e6                	jle    417 <mythread+0x2d>
  }
  thread_join_all();
 431:	e8 e9 fd ff ff       	call   21f <thread_join_all>
  printf(1, "[parent] mythread done\n");
 436:	83 ec 08             	sub    $0x8,%esp
 439:	68 ef 0d 00 00       	push   $0xdef
 43e:	6a 01                	push   $0x1
 440:	e8 45 04 00 00       	call   88a <printf>
 445:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 448:	a1 40 0e 00 00       	mov    0xe40,%eax
 44d:	c7 80 fc 1f 00 00 00 	movl   $0x0,0x1ffc(%eax)
 454:	00 00 00 
  thread_schedule();
 457:	e8 a4 fb ff ff       	call   0 <thread_schedule>
}
 45c:	90                   	nop
 45d:	c9                   	leave
 45e:	c3                   	ret

0000045f <main>:


int 
main(int argc, char *argv[]) 
{
 45f:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 463:	83 e4 f0             	and    $0xfffffff0,%esp
 466:	ff 71 fc             	push   -0x4(%ecx)
 469:	55                   	push   %ebp
 46a:	89 e5                	mov    %esp,%ebp
 46c:	51                   	push   %ecx
 46d:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 470:	e8 83 fc ff ff       	call   f8 <thread_init>
  thread_create(mythread);
 475:	83 ec 0c             	sub    $0xc,%esp
 478:	68 ea 03 00 00       	push   $0x3ea
 47d:	e8 c7 fc ff ff       	call   149 <thread_create>
 482:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 485:	e8 76 fb ff ff       	call   0 <thread_schedule>
  return 0;
 48a:	b8 00 00 00 00       	mov    $0x0,%eax
 48f:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 492:	c9                   	leave
 493:	8d 61 fc             	lea    -0x4(%ecx),%esp
 496:	c3                   	ret

00000497 <thread_switch>:
         */
    .text
    .globl thread_switch
thread_switch:

    pushal
 497:	60                   	pusha

    movl current_thread, %eax
 498:	a1 40 0e 00 00       	mov    0xe40,%eax
    movl %esp, (%eax)
 49d:	89 20                	mov    %esp,(%eax)

    movl next_thread, %eax
 49f:	a1 44 0e 00 00       	mov    0xe44,%eax
    movl (%eax), %esp
 4a4:	8b 20                	mov    (%eax),%esp
    # esp = t1.주소

    movl %eax, current_thread
 4a6:	a3 40 0e 00 00       	mov    %eax,0xe40

    // 레지스터 복구
    popal
 4ab:	61                   	popa

    movl $0, next_thread
 4ac:	c7 05 44 0e 00 00 00 	movl   $0x0,0xe44
 4b3:	00 00 00 
    
 4b6:	c3                   	ret

000004b7 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 4b7:	55                   	push   %ebp
 4b8:	89 e5                	mov    %esp,%ebp
 4ba:	57                   	push   %edi
 4bb:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 4bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
 4bf:	8b 55 10             	mov    0x10(%ebp),%edx
 4c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c5:	89 cb                	mov    %ecx,%ebx
 4c7:	89 df                	mov    %ebx,%edi
 4c9:	89 d1                	mov    %edx,%ecx
 4cb:	fc                   	cld
 4cc:	f3 aa                	rep stos %al,%es:(%edi)
 4ce:	89 ca                	mov    %ecx,%edx
 4d0:	89 fb                	mov    %edi,%ebx
 4d2:	89 5d 08             	mov    %ebx,0x8(%ebp)
 4d5:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 4d8:	90                   	nop
 4d9:	5b                   	pop    %ebx
 4da:	5f                   	pop    %edi
 4db:	5d                   	pop    %ebp
 4dc:	c3                   	ret

000004dd <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 4dd:	55                   	push   %ebp
 4de:	89 e5                	mov    %esp,%ebp
 4e0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 4e3:	8b 45 08             	mov    0x8(%ebp),%eax
 4e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 4e9:	90                   	nop
 4ea:	8b 55 0c             	mov    0xc(%ebp),%edx
 4ed:	8d 42 01             	lea    0x1(%edx),%eax
 4f0:	89 45 0c             	mov    %eax,0xc(%ebp)
 4f3:	8b 45 08             	mov    0x8(%ebp),%eax
 4f6:	8d 48 01             	lea    0x1(%eax),%ecx
 4f9:	89 4d 08             	mov    %ecx,0x8(%ebp)
 4fc:	0f b6 12             	movzbl (%edx),%edx
 4ff:	88 10                	mov    %dl,(%eax)
 501:	0f b6 00             	movzbl (%eax),%eax
 504:	84 c0                	test   %al,%al
 506:	75 e2                	jne    4ea <strcpy+0xd>
    ;
  return os;
 508:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 50b:	c9                   	leave
 50c:	c3                   	ret

0000050d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 50d:	55                   	push   %ebp
 50e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 510:	eb 08                	jmp    51a <strcmp+0xd>
    p++, q++;
 512:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 516:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 51a:	8b 45 08             	mov    0x8(%ebp),%eax
 51d:	0f b6 00             	movzbl (%eax),%eax
 520:	84 c0                	test   %al,%al
 522:	74 10                	je     534 <strcmp+0x27>
 524:	8b 45 08             	mov    0x8(%ebp),%eax
 527:	0f b6 10             	movzbl (%eax),%edx
 52a:	8b 45 0c             	mov    0xc(%ebp),%eax
 52d:	0f b6 00             	movzbl (%eax),%eax
 530:	38 c2                	cmp    %al,%dl
 532:	74 de                	je     512 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 534:	8b 45 08             	mov    0x8(%ebp),%eax
 537:	0f b6 00             	movzbl (%eax),%eax
 53a:	0f b6 d0             	movzbl %al,%edx
 53d:	8b 45 0c             	mov    0xc(%ebp),%eax
 540:	0f b6 00             	movzbl (%eax),%eax
 543:	0f b6 c0             	movzbl %al,%eax
 546:	29 c2                	sub    %eax,%edx
 548:	89 d0                	mov    %edx,%eax
}
 54a:	5d                   	pop    %ebp
 54b:	c3                   	ret

0000054c <strlen>:

uint
strlen(char *s)
{
 54c:	55                   	push   %ebp
 54d:	89 e5                	mov    %esp,%ebp
 54f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 552:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 559:	eb 04                	jmp    55f <strlen+0x13>
 55b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 55f:	8b 55 fc             	mov    -0x4(%ebp),%edx
 562:	8b 45 08             	mov    0x8(%ebp),%eax
 565:	01 d0                	add    %edx,%eax
 567:	0f b6 00             	movzbl (%eax),%eax
 56a:	84 c0                	test   %al,%al
 56c:	75 ed                	jne    55b <strlen+0xf>
    ;
  return n;
 56e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 571:	c9                   	leave
 572:	c3                   	ret

00000573 <memset>:

void*
memset(void *dst, int c, uint n)
{
 573:	55                   	push   %ebp
 574:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 576:	8b 45 10             	mov    0x10(%ebp),%eax
 579:	50                   	push   %eax
 57a:	ff 75 0c             	push   0xc(%ebp)
 57d:	ff 75 08             	push   0x8(%ebp)
 580:	e8 32 ff ff ff       	call   4b7 <stosb>
 585:	83 c4 0c             	add    $0xc,%esp
  return dst;
 588:	8b 45 08             	mov    0x8(%ebp),%eax
}
 58b:	c9                   	leave
 58c:	c3                   	ret

0000058d <strchr>:

char*
strchr(const char *s, char c)
{
 58d:	55                   	push   %ebp
 58e:	89 e5                	mov    %esp,%ebp
 590:	83 ec 04             	sub    $0x4,%esp
 593:	8b 45 0c             	mov    0xc(%ebp),%eax
 596:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 599:	eb 14                	jmp    5af <strchr+0x22>
    if(*s == c)
 59b:	8b 45 08             	mov    0x8(%ebp),%eax
 59e:	0f b6 00             	movzbl (%eax),%eax
 5a1:	38 45 fc             	cmp    %al,-0x4(%ebp)
 5a4:	75 05                	jne    5ab <strchr+0x1e>
      return (char*)s;
 5a6:	8b 45 08             	mov    0x8(%ebp),%eax
 5a9:	eb 13                	jmp    5be <strchr+0x31>
  for(; *s; s++)
 5ab:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5af:	8b 45 08             	mov    0x8(%ebp),%eax
 5b2:	0f b6 00             	movzbl (%eax),%eax
 5b5:	84 c0                	test   %al,%al
 5b7:	75 e2                	jne    59b <strchr+0xe>
  return 0;
 5b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 5be:	c9                   	leave
 5bf:	c3                   	ret

000005c0 <gets>:

char*
gets(char *buf, int max)
{
 5c0:	55                   	push   %ebp
 5c1:	89 e5                	mov    %esp,%ebp
 5c3:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 5cd:	eb 42                	jmp    611 <gets+0x51>
    cc = read(0, &c, 1);
 5cf:	83 ec 04             	sub    $0x4,%esp
 5d2:	6a 01                	push   $0x1
 5d4:	8d 45 ef             	lea    -0x11(%ebp),%eax
 5d7:	50                   	push   %eax
 5d8:	6a 00                	push   $0x0
 5da:	e8 47 01 00 00       	call   726 <read>
 5df:	83 c4 10             	add    $0x10,%esp
 5e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 5e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5e9:	7e 33                	jle    61e <gets+0x5e>
      break;
    buf[i++] = c;
 5eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ee:	8d 50 01             	lea    0x1(%eax),%edx
 5f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5f4:	89 c2                	mov    %eax,%edx
 5f6:	8b 45 08             	mov    0x8(%ebp),%eax
 5f9:	01 c2                	add    %eax,%edx
 5fb:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5ff:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 601:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 605:	3c 0a                	cmp    $0xa,%al
 607:	74 16                	je     61f <gets+0x5f>
 609:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 60d:	3c 0d                	cmp    $0xd,%al
 60f:	74 0e                	je     61f <gets+0x5f>
  for(i=0; i+1 < max; ){
 611:	8b 45 f4             	mov    -0xc(%ebp),%eax
 614:	83 c0 01             	add    $0x1,%eax
 617:	39 45 0c             	cmp    %eax,0xc(%ebp)
 61a:	7f b3                	jg     5cf <gets+0xf>
 61c:	eb 01                	jmp    61f <gets+0x5f>
      break;
 61e:	90                   	nop
      break;
  }
  buf[i] = '\0';
 61f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 622:	8b 45 08             	mov    0x8(%ebp),%eax
 625:	01 d0                	add    %edx,%eax
 627:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 62a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 62d:	c9                   	leave
 62e:	c3                   	ret

0000062f <stat>:

int
stat(char *n, struct stat *st)
{
 62f:	55                   	push   %ebp
 630:	89 e5                	mov    %esp,%ebp
 632:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 635:	83 ec 08             	sub    $0x8,%esp
 638:	6a 00                	push   $0x0
 63a:	ff 75 08             	push   0x8(%ebp)
 63d:	e8 0c 01 00 00       	call   74e <open>
 642:	83 c4 10             	add    $0x10,%esp
 645:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 648:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 64c:	79 07                	jns    655 <stat+0x26>
    return -1;
 64e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 653:	eb 25                	jmp    67a <stat+0x4b>
  r = fstat(fd, st);
 655:	83 ec 08             	sub    $0x8,%esp
 658:	ff 75 0c             	push   0xc(%ebp)
 65b:	ff 75 f4             	push   -0xc(%ebp)
 65e:	e8 03 01 00 00       	call   766 <fstat>
 663:	83 c4 10             	add    $0x10,%esp
 666:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 669:	83 ec 0c             	sub    $0xc,%esp
 66c:	ff 75 f4             	push   -0xc(%ebp)
 66f:	e8 c2 00 00 00       	call   736 <close>
 674:	83 c4 10             	add    $0x10,%esp
  return r;
 677:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 67a:	c9                   	leave
 67b:	c3                   	ret

0000067c <atoi>:

int
atoi(const char *s)
{
 67c:	55                   	push   %ebp
 67d:	89 e5                	mov    %esp,%ebp
 67f:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 682:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 689:	eb 25                	jmp    6b0 <atoi+0x34>
    n = n*10 + *s++ - '0';
 68b:	8b 55 fc             	mov    -0x4(%ebp),%edx
 68e:	89 d0                	mov    %edx,%eax
 690:	c1 e0 02             	shl    $0x2,%eax
 693:	01 d0                	add    %edx,%eax
 695:	01 c0                	add    %eax,%eax
 697:	89 c1                	mov    %eax,%ecx
 699:	8b 45 08             	mov    0x8(%ebp),%eax
 69c:	8d 50 01             	lea    0x1(%eax),%edx
 69f:	89 55 08             	mov    %edx,0x8(%ebp)
 6a2:	0f b6 00             	movzbl (%eax),%eax
 6a5:	0f be c0             	movsbl %al,%eax
 6a8:	01 c8                	add    %ecx,%eax
 6aa:	83 e8 30             	sub    $0x30,%eax
 6ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 6b0:	8b 45 08             	mov    0x8(%ebp),%eax
 6b3:	0f b6 00             	movzbl (%eax),%eax
 6b6:	3c 2f                	cmp    $0x2f,%al
 6b8:	7e 0a                	jle    6c4 <atoi+0x48>
 6ba:	8b 45 08             	mov    0x8(%ebp),%eax
 6bd:	0f b6 00             	movzbl (%eax),%eax
 6c0:	3c 39                	cmp    $0x39,%al
 6c2:	7e c7                	jle    68b <atoi+0xf>
  return n;
 6c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6c7:	c9                   	leave
 6c8:	c3                   	ret

000006c9 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 6c9:	55                   	push   %ebp
 6ca:	89 e5                	mov    %esp,%ebp
 6cc:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 6cf:	8b 45 08             	mov    0x8(%ebp),%eax
 6d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 6d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 6d8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 6db:	eb 17                	jmp    6f4 <memmove+0x2b>
    *dst++ = *src++;
 6dd:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6e0:	8d 42 01             	lea    0x1(%edx),%eax
 6e3:	89 45 f8             	mov    %eax,-0x8(%ebp)
 6e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e9:	8d 48 01             	lea    0x1(%eax),%ecx
 6ec:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 6ef:	0f b6 12             	movzbl (%edx),%edx
 6f2:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 6f4:	8b 45 10             	mov    0x10(%ebp),%eax
 6f7:	8d 50 ff             	lea    -0x1(%eax),%edx
 6fa:	89 55 10             	mov    %edx,0x10(%ebp)
 6fd:	85 c0                	test   %eax,%eax
 6ff:	7f dc                	jg     6dd <memmove+0x14>
  return vdst;
 701:	8b 45 08             	mov    0x8(%ebp),%eax
}
 704:	c9                   	leave
 705:	c3                   	ret

00000706 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 706:	b8 01 00 00 00       	mov    $0x1,%eax
 70b:	cd 40                	int    $0x40
 70d:	c3                   	ret

0000070e <exit>:
SYSCALL(exit)
 70e:	b8 02 00 00 00       	mov    $0x2,%eax
 713:	cd 40                	int    $0x40
 715:	c3                   	ret

00000716 <wait>:
SYSCALL(wait)
 716:	b8 03 00 00 00       	mov    $0x3,%eax
 71b:	cd 40                	int    $0x40
 71d:	c3                   	ret

0000071e <pipe>:
SYSCALL(pipe)
 71e:	b8 04 00 00 00       	mov    $0x4,%eax
 723:	cd 40                	int    $0x40
 725:	c3                   	ret

00000726 <read>:
SYSCALL(read)
 726:	b8 05 00 00 00       	mov    $0x5,%eax
 72b:	cd 40                	int    $0x40
 72d:	c3                   	ret

0000072e <write>:
SYSCALL(write)
 72e:	b8 10 00 00 00       	mov    $0x10,%eax
 733:	cd 40                	int    $0x40
 735:	c3                   	ret

00000736 <close>:
SYSCALL(close)
 736:	b8 15 00 00 00       	mov    $0x15,%eax
 73b:	cd 40                	int    $0x40
 73d:	c3                   	ret

0000073e <kill>:
SYSCALL(kill)
 73e:	b8 06 00 00 00       	mov    $0x6,%eax
 743:	cd 40                	int    $0x40
 745:	c3                   	ret

00000746 <exec>:
SYSCALL(exec)
 746:	b8 07 00 00 00       	mov    $0x7,%eax
 74b:	cd 40                	int    $0x40
 74d:	c3                   	ret

0000074e <open>:
SYSCALL(open)
 74e:	b8 0f 00 00 00       	mov    $0xf,%eax
 753:	cd 40                	int    $0x40
 755:	c3                   	ret

00000756 <mknod>:
SYSCALL(mknod)
 756:	b8 11 00 00 00       	mov    $0x11,%eax
 75b:	cd 40                	int    $0x40
 75d:	c3                   	ret

0000075e <unlink>:
SYSCALL(unlink)
 75e:	b8 12 00 00 00       	mov    $0x12,%eax
 763:	cd 40                	int    $0x40
 765:	c3                   	ret

00000766 <fstat>:
SYSCALL(fstat)
 766:	b8 08 00 00 00       	mov    $0x8,%eax
 76b:	cd 40                	int    $0x40
 76d:	c3                   	ret

0000076e <link>:
SYSCALL(link)
 76e:	b8 13 00 00 00       	mov    $0x13,%eax
 773:	cd 40                	int    $0x40
 775:	c3                   	ret

00000776 <mkdir>:
SYSCALL(mkdir)
 776:	b8 14 00 00 00       	mov    $0x14,%eax
 77b:	cd 40                	int    $0x40
 77d:	c3                   	ret

0000077e <chdir>:
SYSCALL(chdir)
 77e:	b8 09 00 00 00       	mov    $0x9,%eax
 783:	cd 40                	int    $0x40
 785:	c3                   	ret

00000786 <dup>:
SYSCALL(dup)
 786:	b8 0a 00 00 00       	mov    $0xa,%eax
 78b:	cd 40                	int    $0x40
 78d:	c3                   	ret

0000078e <getpid>:
SYSCALL(getpid)
 78e:	b8 0b 00 00 00       	mov    $0xb,%eax
 793:	cd 40                	int    $0x40
 795:	c3                   	ret

00000796 <sbrk>:
SYSCALL(sbrk)
 796:	b8 0c 00 00 00       	mov    $0xc,%eax
 79b:	cd 40                	int    $0x40
 79d:	c3                   	ret

0000079e <sleep>:
SYSCALL(sleep)
 79e:	b8 0d 00 00 00       	mov    $0xd,%eax
 7a3:	cd 40                	int    $0x40
 7a5:	c3                   	ret

000007a6 <uptime>:
SYSCALL(uptime)
 7a6:	b8 0e 00 00 00       	mov    $0xe,%eax
 7ab:	cd 40                	int    $0x40
 7ad:	c3                   	ret

000007ae <uthread_init>:
SYSCALL(uthread_init)
 7ae:	b8 16 00 00 00       	mov    $0x16,%eax
 7b3:	cd 40                	int    $0x40
 7b5:	c3                   	ret

000007b6 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 7b6:	55                   	push   %ebp
 7b7:	89 e5                	mov    %esp,%ebp
 7b9:	83 ec 18             	sub    $0x18,%esp
 7bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 7bf:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 7c2:	83 ec 04             	sub    $0x4,%esp
 7c5:	6a 01                	push   $0x1
 7c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
 7ca:	50                   	push   %eax
 7cb:	ff 75 08             	push   0x8(%ebp)
 7ce:	e8 5b ff ff ff       	call   72e <write>
 7d3:	83 c4 10             	add    $0x10,%esp
}
 7d6:	90                   	nop
 7d7:	c9                   	leave
 7d8:	c3                   	ret

000007d9 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7d9:	55                   	push   %ebp
 7da:	89 e5                	mov    %esp,%ebp
 7dc:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 7df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 7e6:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 7ea:	74 17                	je     803 <printint+0x2a>
 7ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 7f0:	79 11                	jns    803 <printint+0x2a>
    neg = 1;
 7f2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 7f9:	8b 45 0c             	mov    0xc(%ebp),%eax
 7fc:	f7 d8                	neg    %eax
 7fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
 801:	eb 06                	jmp    809 <printint+0x30>
  } else {
    x = xx;
 803:	8b 45 0c             	mov    0xc(%ebp),%eax
 806:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 809:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 810:	8b 4d 10             	mov    0x10(%ebp),%ecx
 813:	8b 45 ec             	mov    -0x14(%ebp),%eax
 816:	ba 00 00 00 00       	mov    $0x0,%edx
 81b:	f7 f1                	div    %ecx
 81d:	89 d1                	mov    %edx,%ecx
 81f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 822:	8d 50 01             	lea    0x1(%eax),%edx
 825:	89 55 f4             	mov    %edx,-0xc(%ebp)
 828:	0f b6 91 10 0e 00 00 	movzbl 0xe10(%ecx),%edx
 82f:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 833:	8b 4d 10             	mov    0x10(%ebp),%ecx
 836:	8b 45 ec             	mov    -0x14(%ebp),%eax
 839:	ba 00 00 00 00       	mov    $0x0,%edx
 83e:	f7 f1                	div    %ecx
 840:	89 45 ec             	mov    %eax,-0x14(%ebp)
 843:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 847:	75 c7                	jne    810 <printint+0x37>
  if(neg)
 849:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 84d:	74 2d                	je     87c <printint+0xa3>
    buf[i++] = '-';
 84f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 852:	8d 50 01             	lea    0x1(%eax),%edx
 855:	89 55 f4             	mov    %edx,-0xc(%ebp)
 858:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 85d:	eb 1d                	jmp    87c <printint+0xa3>
    putc(fd, buf[i]);
 85f:	8d 55 dc             	lea    -0x24(%ebp),%edx
 862:	8b 45 f4             	mov    -0xc(%ebp),%eax
 865:	01 d0                	add    %edx,%eax
 867:	0f b6 00             	movzbl (%eax),%eax
 86a:	0f be c0             	movsbl %al,%eax
 86d:	83 ec 08             	sub    $0x8,%esp
 870:	50                   	push   %eax
 871:	ff 75 08             	push   0x8(%ebp)
 874:	e8 3d ff ff ff       	call   7b6 <putc>
 879:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 87c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 880:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 884:	79 d9                	jns    85f <printint+0x86>
}
 886:	90                   	nop
 887:	90                   	nop
 888:	c9                   	leave
 889:	c3                   	ret

0000088a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 88a:	55                   	push   %ebp
 88b:	89 e5                	mov    %esp,%ebp
 88d:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 890:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 897:	8d 45 0c             	lea    0xc(%ebp),%eax
 89a:	83 c0 04             	add    $0x4,%eax
 89d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 8a0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 8a7:	e9 59 01 00 00       	jmp    a05 <printf+0x17b>
    c = fmt[i] & 0xff;
 8ac:	8b 55 0c             	mov    0xc(%ebp),%edx
 8af:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b2:	01 d0                	add    %edx,%eax
 8b4:	0f b6 00             	movzbl (%eax),%eax
 8b7:	0f be c0             	movsbl %al,%eax
 8ba:	25 ff 00 00 00       	and    $0xff,%eax
 8bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 8c2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8c6:	75 2c                	jne    8f4 <printf+0x6a>
      if(c == '%'){
 8c8:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8cc:	75 0c                	jne    8da <printf+0x50>
        state = '%';
 8ce:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 8d5:	e9 27 01 00 00       	jmp    a01 <printf+0x177>
      } else {
        putc(fd, c);
 8da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8dd:	0f be c0             	movsbl %al,%eax
 8e0:	83 ec 08             	sub    $0x8,%esp
 8e3:	50                   	push   %eax
 8e4:	ff 75 08             	push   0x8(%ebp)
 8e7:	e8 ca fe ff ff       	call   7b6 <putc>
 8ec:	83 c4 10             	add    $0x10,%esp
 8ef:	e9 0d 01 00 00       	jmp    a01 <printf+0x177>
      }
    } else if(state == '%'){
 8f4:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 8f8:	0f 85 03 01 00 00    	jne    a01 <printf+0x177>
      if(c == 'd'){
 8fe:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 902:	75 1e                	jne    922 <printf+0x98>
        printint(fd, *ap, 10, 1);
 904:	8b 45 e8             	mov    -0x18(%ebp),%eax
 907:	8b 00                	mov    (%eax),%eax
 909:	6a 01                	push   $0x1
 90b:	6a 0a                	push   $0xa
 90d:	50                   	push   %eax
 90e:	ff 75 08             	push   0x8(%ebp)
 911:	e8 c3 fe ff ff       	call   7d9 <printint>
 916:	83 c4 10             	add    $0x10,%esp
        ap++;
 919:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 91d:	e9 d8 00 00 00       	jmp    9fa <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 922:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 926:	74 06                	je     92e <printf+0xa4>
 928:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 92c:	75 1e                	jne    94c <printf+0xc2>
        printint(fd, *ap, 16, 0);
 92e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 931:	8b 00                	mov    (%eax),%eax
 933:	6a 00                	push   $0x0
 935:	6a 10                	push   $0x10
 937:	50                   	push   %eax
 938:	ff 75 08             	push   0x8(%ebp)
 93b:	e8 99 fe ff ff       	call   7d9 <printint>
 940:	83 c4 10             	add    $0x10,%esp
        ap++;
 943:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 947:	e9 ae 00 00 00       	jmp    9fa <printf+0x170>
      } else if(c == 's'){
 94c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 950:	75 43                	jne    995 <printf+0x10b>
        s = (char*)*ap;
 952:	8b 45 e8             	mov    -0x18(%ebp),%eax
 955:	8b 00                	mov    (%eax),%eax
 957:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 95a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 95e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 962:	75 25                	jne    989 <printf+0xff>
          s = "(null)";
 964:	c7 45 f4 07 0e 00 00 	movl   $0xe07,-0xc(%ebp)
        while(*s != 0){
 96b:	eb 1c                	jmp    989 <printf+0xff>
          putc(fd, *s);
 96d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 970:	0f b6 00             	movzbl (%eax),%eax
 973:	0f be c0             	movsbl %al,%eax
 976:	83 ec 08             	sub    $0x8,%esp
 979:	50                   	push   %eax
 97a:	ff 75 08             	push   0x8(%ebp)
 97d:	e8 34 fe ff ff       	call   7b6 <putc>
 982:	83 c4 10             	add    $0x10,%esp
          s++;
 985:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 989:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98c:	0f b6 00             	movzbl (%eax),%eax
 98f:	84 c0                	test   %al,%al
 991:	75 da                	jne    96d <printf+0xe3>
 993:	eb 65                	jmp    9fa <printf+0x170>
        }
      } else if(c == 'c'){
 995:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 999:	75 1d                	jne    9b8 <printf+0x12e>
        putc(fd, *ap);
 99b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 99e:	8b 00                	mov    (%eax),%eax
 9a0:	0f be c0             	movsbl %al,%eax
 9a3:	83 ec 08             	sub    $0x8,%esp
 9a6:	50                   	push   %eax
 9a7:	ff 75 08             	push   0x8(%ebp)
 9aa:	e8 07 fe ff ff       	call   7b6 <putc>
 9af:	83 c4 10             	add    $0x10,%esp
        ap++;
 9b2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9b6:	eb 42                	jmp    9fa <printf+0x170>
      } else if(c == '%'){
 9b8:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 9bc:	75 17                	jne    9d5 <printf+0x14b>
        putc(fd, c);
 9be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9c1:	0f be c0             	movsbl %al,%eax
 9c4:	83 ec 08             	sub    $0x8,%esp
 9c7:	50                   	push   %eax
 9c8:	ff 75 08             	push   0x8(%ebp)
 9cb:	e8 e6 fd ff ff       	call   7b6 <putc>
 9d0:	83 c4 10             	add    $0x10,%esp
 9d3:	eb 25                	jmp    9fa <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 9d5:	83 ec 08             	sub    $0x8,%esp
 9d8:	6a 25                	push   $0x25
 9da:	ff 75 08             	push   0x8(%ebp)
 9dd:	e8 d4 fd ff ff       	call   7b6 <putc>
 9e2:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 9e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 9e8:	0f be c0             	movsbl %al,%eax
 9eb:	83 ec 08             	sub    $0x8,%esp
 9ee:	50                   	push   %eax
 9ef:	ff 75 08             	push   0x8(%ebp)
 9f2:	e8 bf fd ff ff       	call   7b6 <putc>
 9f7:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 9fa:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 a01:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a05:	8b 55 0c             	mov    0xc(%ebp),%edx
 a08:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a0b:	01 d0                	add    %edx,%eax
 a0d:	0f b6 00             	movzbl (%eax),%eax
 a10:	84 c0                	test   %al,%al
 a12:	0f 85 94 fe ff ff    	jne    8ac <printf+0x22>
    }
  }
}
 a18:	90                   	nop
 a19:	90                   	nop
 a1a:	c9                   	leave
 a1b:	c3                   	ret

00000a1c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a1c:	55                   	push   %ebp
 a1d:	89 e5                	mov    %esp,%ebp
 a1f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a22:	8b 45 08             	mov    0x8(%ebp),%eax
 a25:	83 e8 08             	sub    $0x8,%eax
 a28:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a2b:	a1 b8 4e 01 00       	mov    0x14eb8,%eax
 a30:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a33:	eb 24                	jmp    a59 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a35:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a38:	8b 00                	mov    (%eax),%eax
 a3a:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 a3d:	72 12                	jb     a51 <free+0x35>
 a3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a42:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 a45:	72 24                	jb     a6b <free+0x4f>
 a47:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a4a:	8b 00                	mov    (%eax),%eax
 a4c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a4f:	72 1a                	jb     a6b <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a51:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a54:	8b 00                	mov    (%eax),%eax
 a56:	89 45 fc             	mov    %eax,-0x4(%ebp)
 a59:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a5c:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 a5f:	73 d4                	jae    a35 <free+0x19>
 a61:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a64:	8b 00                	mov    (%eax),%eax
 a66:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a69:	73 ca                	jae    a35 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 a6b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a6e:	8b 40 04             	mov    0x4(%eax),%eax
 a71:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a78:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a7b:	01 c2                	add    %eax,%edx
 a7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a80:	8b 00                	mov    (%eax),%eax
 a82:	39 c2                	cmp    %eax,%edx
 a84:	75 24                	jne    aaa <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 a86:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a89:	8b 50 04             	mov    0x4(%eax),%edx
 a8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a8f:	8b 00                	mov    (%eax),%eax
 a91:	8b 40 04             	mov    0x4(%eax),%eax
 a94:	01 c2                	add    %eax,%edx
 a96:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a99:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a9f:	8b 00                	mov    (%eax),%eax
 aa1:	8b 10                	mov    (%eax),%edx
 aa3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 aa6:	89 10                	mov    %edx,(%eax)
 aa8:	eb 0a                	jmp    ab4 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 aaa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aad:	8b 10                	mov    (%eax),%edx
 aaf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ab2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 ab4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ab7:	8b 40 04             	mov    0x4(%eax),%eax
 aba:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 ac1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac4:	01 d0                	add    %edx,%eax
 ac6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 ac9:	75 20                	jne    aeb <free+0xcf>
    p->s.size += bp->s.size;
 acb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ace:	8b 50 04             	mov    0x4(%eax),%edx
 ad1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ad4:	8b 40 04             	mov    0x4(%eax),%eax
 ad7:	01 c2                	add    %eax,%edx
 ad9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 adc:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 adf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ae2:	8b 10                	mov    (%eax),%edx
 ae4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae7:	89 10                	mov    %edx,(%eax)
 ae9:	eb 08                	jmp    af3 <free+0xd7>
  } else
    p->s.ptr = bp;
 aeb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aee:	8b 55 f8             	mov    -0x8(%ebp),%edx
 af1:	89 10                	mov    %edx,(%eax)
  freep = p;
 af3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af6:	a3 b8 4e 01 00       	mov    %eax,0x14eb8
}
 afb:	90                   	nop
 afc:	c9                   	leave
 afd:	c3                   	ret

00000afe <morecore>:

static Header*
morecore(uint nu)
{
 afe:	55                   	push   %ebp
 aff:	89 e5                	mov    %esp,%ebp
 b01:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b04:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b0b:	77 07                	ja     b14 <morecore+0x16>
    nu = 4096;
 b0d:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 b14:	8b 45 08             	mov    0x8(%ebp),%eax
 b17:	c1 e0 03             	shl    $0x3,%eax
 b1a:	83 ec 0c             	sub    $0xc,%esp
 b1d:	50                   	push   %eax
 b1e:	e8 73 fc ff ff       	call   796 <sbrk>
 b23:	83 c4 10             	add    $0x10,%esp
 b26:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 b29:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 b2d:	75 07                	jne    b36 <morecore+0x38>
    return 0;
 b2f:	b8 00 00 00 00       	mov    $0x0,%eax
 b34:	eb 26                	jmp    b5c <morecore+0x5e>
  hp = (Header*)p;
 b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b39:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b3f:	8b 55 08             	mov    0x8(%ebp),%edx
 b42:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b48:	83 c0 08             	add    $0x8,%eax
 b4b:	83 ec 0c             	sub    $0xc,%esp
 b4e:	50                   	push   %eax
 b4f:	e8 c8 fe ff ff       	call   a1c <free>
 b54:	83 c4 10             	add    $0x10,%esp
  return freep;
 b57:	a1 b8 4e 01 00       	mov    0x14eb8,%eax
}
 b5c:	c9                   	leave
 b5d:	c3                   	ret

00000b5e <malloc>:

void*
malloc(uint nbytes)
{
 b5e:	55                   	push   %ebp
 b5f:	89 e5                	mov    %esp,%ebp
 b61:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b64:	8b 45 08             	mov    0x8(%ebp),%eax
 b67:	83 c0 07             	add    $0x7,%eax
 b6a:	c1 e8 03             	shr    $0x3,%eax
 b6d:	83 c0 01             	add    $0x1,%eax
 b70:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 b73:	a1 b8 4e 01 00       	mov    0x14eb8,%eax
 b78:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b7f:	75 23                	jne    ba4 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 b81:	c7 45 f0 b0 4e 01 00 	movl   $0x14eb0,-0x10(%ebp)
 b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b8b:	a3 b8 4e 01 00       	mov    %eax,0x14eb8
 b90:	a1 b8 4e 01 00       	mov    0x14eb8,%eax
 b95:	a3 b0 4e 01 00       	mov    %eax,0x14eb0
    base.s.size = 0;
 b9a:	c7 05 b4 4e 01 00 00 	movl   $0x0,0x14eb4
 ba1:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ba4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ba7:	8b 00                	mov    (%eax),%eax
 ba9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 baf:	8b 40 04             	mov    0x4(%eax),%eax
 bb2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 bb5:	72 4d                	jb     c04 <malloc+0xa6>
      if(p->s.size == nunits)
 bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bba:	8b 40 04             	mov    0x4(%eax),%eax
 bbd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 bc0:	75 0c                	jne    bce <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc5:	8b 10                	mov    (%eax),%edx
 bc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bca:	89 10                	mov    %edx,(%eax)
 bcc:	eb 26                	jmp    bf4 <malloc+0x96>
      else {
        p->s.size -= nunits;
 bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd1:	8b 40 04             	mov    0x4(%eax),%eax
 bd4:	2b 45 ec             	sub    -0x14(%ebp),%eax
 bd7:	89 c2                	mov    %eax,%edx
 bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bdc:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 be2:	8b 40 04             	mov    0x4(%eax),%eax
 be5:	c1 e0 03             	shl    $0x3,%eax
 be8:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bee:	8b 55 ec             	mov    -0x14(%ebp),%edx
 bf1:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 bf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bf7:	a3 b8 4e 01 00       	mov    %eax,0x14eb8
      return (void*)(p + 1);
 bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bff:	83 c0 08             	add    $0x8,%eax
 c02:	eb 3b                	jmp    c3f <malloc+0xe1>
    }
    if(p == freep)
 c04:	a1 b8 4e 01 00       	mov    0x14eb8,%eax
 c09:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c0c:	75 1e                	jne    c2c <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 c0e:	83 ec 0c             	sub    $0xc,%esp
 c11:	ff 75 ec             	push   -0x14(%ebp)
 c14:	e8 e5 fe ff ff       	call   afe <morecore>
 c19:	83 c4 10             	add    $0x10,%esp
 c1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 c1f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 c23:	75 07                	jne    c2c <malloc+0xce>
        return 0;
 c25:	b8 00 00 00 00       	mov    $0x0,%eax
 c2a:	eb 13                	jmp    c3f <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c35:	8b 00                	mov    (%eax),%eax
 c37:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c3a:	e9 6d ff ff ff       	jmp    bac <malloc+0x4e>
  }
}
 c3f:	c9                   	leave
 c40:	c3                   	ret
