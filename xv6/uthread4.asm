
_uthread4:     file format elf32-i386


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
   6:	c7 05 a4 0f 00 00 00 	movl   $0x0,0xfa4
   d:	00 00 00 
  for (t = all_thread+1; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 d0 2f 00 00 	movl   $0x2fd0,-0xc(%ebp)
  17:	eb 29                	jmp    42 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  22:	83 f8 02             	cmp    $0x2,%eax
  25:	75 14                	jne    3b <thread_schedule+0x3b>
  27:	a1 a0 0f 00 00       	mov    0xfa0,%eax
  2c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  2f:	74 0a                	je     3b <thread_schedule+0x3b>
      next_thread = t;
  31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  34:	a3 a4 0f 00 00       	mov    %eax,0xfa4
      break;
  39:	eb 11                	jmp    4c <thread_schedule+0x4c>
  for (t = all_thread+1; t < all_thread + MAX_THREAD; t++) {
  3b:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
  42:	b8 60 50 01 00       	mov    $0x15060,%eax
  47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4a:	72 cd                	jb     19 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  4c:	b8 60 50 01 00       	mov    $0x15060,%eax
  51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  54:	72 1a                	jb     70 <thread_schedule+0x70>
  56:	a1 a0 0f 00 00       	mov    0xfa0,%eax
  5b:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  61:	83 f8 02             	cmp    $0x2,%eax
  64:	75 0a                	jne    70 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  66:	a1 a0 0f 00 00       	mov    0xfa0,%eax
  6b:	a3 a4 0f 00 00       	mov    %eax,0xfa4
  }

  if (next_thread == 0) {
  70:	a1 a4 0f 00 00       	mov    0xfa4,%eax
  75:	85 c0                	test   %eax,%eax
  77:	75 17                	jne    90 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 f4 0c 00 00       	push   $0xcf4
  81:	6a 02                	push   $0x2
  83:	e8 b4 08 00 00       	call   93c <printf>
  88:	83 c4 10             	add    $0x10,%esp
    exit();
  8b:	e8 30 07 00 00       	call   7c0 <exit>
  }

  if (current_thread != next_thread) {
  90:	8b 15 a0 0f 00 00    	mov    0xfa0,%edx
  96:	a1 a4 0f 00 00       	mov    0xfa4,%eax
  9b:	39 c2                	cmp    %eax,%edx
  9d:	74 5b                	je     fa <thread_schedule+0xfa>
    next_thread->state = RUNNING;
  9f:	a1 a4 0f 00 00       	mov    0xfa4,%eax
  a4:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  ab:	00 00 00 
    if (current_thread->state != FREE) {
  ae:	a1 a0 0f 00 00       	mov    0xfa0,%eax
  b3:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  b9:	85 c0                	test   %eax,%eax
  bb:	74 0f                	je     cc <thread_schedule+0xcc>
      current_thread->state = RUNNABLE;
  bd:	a1 a0 0f 00 00       	mov    0xfa0,%eax
  c2:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
  c9:	00 00 00 
    }
  
    printf(1, "[sched] switch from tid=%d to tid=%d\n", current_thread->tid, next_thread->tid);
  cc:	a1 a4 0f 00 00       	mov    0xfa4,%eax
  d1:	8b 90 08 20 00 00    	mov    0x2008(%eax),%edx
  d7:	a1 a0 0f 00 00       	mov    0xfa0,%eax
  dc:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
  e2:	52                   	push   %edx
  e3:	50                   	push   %eax
  e4:	68 1c 0d 00 00       	push   $0xd1c
  e9:	6a 01                	push   $0x1
  eb:	e8 4c 08 00 00       	call   93c <printf>
  f0:	83 c4 10             	add    $0x10,%esp
    thread_switch();
  f3:	e8 51 04 00 00       	call   549 <thread_switch>
  } else
    next_thread = 0;
}
  f8:	eb 0a                	jmp    104 <thread_schedule+0x104>
    next_thread = 0;
  fa:	c7 05 a4 0f 00 00 00 	movl   $0x0,0xfa4
 101:	00 00 00 
}
 104:	90                   	nop
 105:	c9                   	leave
 106:	c3                   	ret

00000107 <thread_init>:
void 
thread_init(void)
{
 107:	55                   	push   %ebp
 108:	89 e5                	mov    %esp,%ebp
 10a:	83 ec 08             	sub    $0x8,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
 10d:	c7 05 a0 0f 00 00 c0 	movl   $0xfc0,0xfa0
 114:	0f 00 00 
  current_thread->state = RUNNING;
 117:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 11c:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 123:	00 00 00 
  current_thread->tid=0;
 126:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 12b:	c7 80 08 20 00 00 00 	movl   $0x0,0x2008(%eax)
 132:	00 00 00 
  current_thread->ptid=0;
 135:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 13a:	c7 80 0c 20 00 00 00 	movl   $0x0,0x200c(%eax)
 141:	00 00 00 

  uthread_init((int)thread_schedule);
 144:	b8 00 00 00 00       	mov    $0x0,%eax
 149:	83 ec 0c             	sub    $0xc,%esp
 14c:	50                   	push   %eax
 14d:	e8 0e 07 00 00       	call   860 <uthread_init>
 152:	83 c4 10             	add    $0x10,%esp
}
 155:	90                   	nop
 156:	c9                   	leave
 157:	c3                   	ret

00000158 <thread_create>:

int 
thread_create(void (*func)())
{
 158:	55                   	push   %ebp
 159:	89 e5                	mov    %esp,%ebp
 15b:	83 ec 18             	sub    $0x18,%esp
  printf(1,"thread_create\n");
 15e:	83 ec 08             	sub    $0x8,%esp
 161:	68 42 0d 00 00       	push   $0xd42
 166:	6a 01                	push   $0x1
 168:	e8 cf 07 00 00       	call   93c <printf>
 16d:	83 c4 10             	add    $0x10,%esp
  
  thread_p t;
  for (t = all_thread +1 ; t < all_thread + MAX_THREAD; t++) {
 170:	c7 45 f4 d0 2f 00 00 	movl   $0x2fd0,-0xc(%ebp)
 177:	eb 14                	jmp    18d <thread_create+0x35>
    if (t->state == FREE) break;
 179:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 182:	85 c0                	test   %eax,%eax
 184:	74 13                	je     199 <thread_create+0x41>
  for (t = all_thread +1 ; t < all_thread + MAX_THREAD; t++) {
 186:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
 18d:	b8 60 50 01 00       	mov    $0x15060,%eax
 192:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 195:	72 e2                	jb     179 <thread_create+0x21>
 197:	eb 01                	jmp    19a <thread_create+0x42>
    if (t->state == FREE) break;
 199:	90                   	nop
  }

  t->sp = (int)(t->stack + STACK_SIZE);
 19a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19d:	83 c0 04             	add    $0x4,%eax
 1a0:	05 00 20 00 00       	add    $0x2000,%eax
 1a5:	89 c2                	mov    %eax,%edx
 1a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1aa:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;
 1ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1af:	8b 00                	mov    (%eax),%eax
 1b1:	8d 50 fc             	lea    -0x4(%eax),%edx
 1b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b7:	89 10                	mov    %edx,(%eax)
  *(int *)(t->sp) = (int)func;  // ret 주소
 1b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1bc:	8b 00                	mov    (%eax),%eax
 1be:	89 c2                	mov    %eax,%edx
 1c0:	8b 45 08             	mov    0x8(%ebp),%eax
 1c3:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;
 1c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c8:	8b 00                	mov    (%eax),%eax
 1ca:	8d 50 e0             	lea    -0x20(%eax),%edx
 1cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d0:	89 10                	mov    %edx,(%eax)

  t->tid = t - all_thread;
 1d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d5:	2d c0 0f 00 00       	sub    $0xfc0,%eax
 1da:	c1 f8 04             	sar    $0x4,%eax
 1dd:	69 c0 01 fe 03 f8    	imul   $0xf803fe01,%eax,%eax
 1e3:	89 c2                	mov    %eax,%edx
 1e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e8:	89 90 08 20 00 00    	mov    %edx,0x2008(%eax)
  t->ptid = current_thread->tid;
 1ee:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 1f3:	8b 90 08 20 00 00    	mov    0x2008(%eax),%edx
 1f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1fc:	89 90 0c 20 00 00    	mov    %edx,0x200c(%eax)
  t->state = RUNNABLE;
 202:	8b 45 f4             	mov    -0xc(%ebp),%eax
 205:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 20c:	00 00 00 

  printf(1, "[create] tid=%d func address = 0x%x\n", t->tid, func);
 20f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 212:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 218:	ff 75 08             	push   0x8(%ebp)
 21b:	50                   	push   %eax
 21c:	68 54 0d 00 00       	push   $0xd54
 221:	6a 01                	push   $0x1
 223:	e8 14 07 00 00       	call   93c <printf>
 228:	83 c4 10             	add    $0x10,%esp
  return t->tid;
 22b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22e:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
}
 234:	c9                   	leave
 235:	c3                   	ret

00000236 <thread_join>:

// thread_join 함수 구현
int thread_join(int tid) {
 236:	55                   	push   %ebp
 237:	89 e5                	mov    %esp,%ebp
 239:	83 ec 18             	sub    $0x18,%esp
  if (tid < 0 || tid >= MAX_THREAD) {
 23c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 240:	78 06                	js     248 <thread_join+0x12>
 242:	83 7d 08 09          	cmpl   $0x9,0x8(%ebp)
 246:	7e 1f                	jle    267 <thread_join+0x31>
    printf(1, "[thread_join] Invalid thread ID: %d\n", tid);
 248:	83 ec 04             	sub    $0x4,%esp
 24b:	ff 75 08             	push   0x8(%ebp)
 24e:	68 7c 0d 00 00       	push   $0xd7c
 253:	6a 01                	push   $0x1
 255:	e8 e2 06 00 00       	call   93c <printf>
 25a:	83 c4 10             	add    $0x10,%esp
    return -1;
 25d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 262:	e9 3c 01 00 00       	jmp    3a3 <thread_join+0x16d>
  }

  thread_p target = &all_thread[tid];
 267:	8b 45 08             	mov    0x8(%ebp),%eax
 26a:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 270:	05 c0 0f 00 00       	add    $0xfc0,%eax
 275:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // 유효한 자식인지 확인
  if (target->ptid != current_thread->tid) {
 278:	8b 45 ec             	mov    -0x14(%ebp),%eax
 27b:	8b 90 0c 20 00 00    	mov    0x200c(%eax),%edx
 281:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 286:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 28c:	39 c2                	cmp    %eax,%edx
 28e:	74 28                	je     2b8 <thread_join+0x82>
    printf(1, "[thread_join] tid=%d is not a child of current thread=%d\n", tid, current_thread->tid);
 290:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 295:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 29b:	50                   	push   %eax
 29c:	ff 75 08             	push   0x8(%ebp)
 29f:	68 a4 0d 00 00       	push   $0xda4
 2a4:	6a 01                	push   $0x1
 2a6:	e8 91 06 00 00       	call   93c <printf>
 2ab:	83 c4 10             	add    $0x10,%esp
    return -1;
 2ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2b3:	e9 eb 00 00 00       	jmp    3a3 <thread_join+0x16d>
  }

  printf(1, "[thread_join] current=%d waiting for child=%d\n", current_thread->tid, tid);
 2b8:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 2bd:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 2c3:	ff 75 08             	push   0x8(%ebp)
 2c6:	50                   	push   %eax
 2c7:	68 e0 0d 00 00       	push   $0xde0
 2cc:	6a 01                	push   $0x1
 2ce:	e8 69 06 00 00       	call   93c <printf>
 2d3:	83 c4 10             	add    $0x10,%esp

  while (1) {
    if (target->state == FREE) {
 2d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 2d9:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 2df:	85 c0                	test   %eax,%eax
 2e1:	75 14                	jne    2f7 <thread_join+0xc1>
      // 자식 종료되었으면 실행 가능 상태로 복귀
      current_thread->state = RUNNABLE;
 2e3:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 2e8:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 2ef:	00 00 00 
      break;
 2f2:	e9 92 00 00 00       	jmp    389 <thread_join+0x153>
    }

    // WAIT으로 변경
    current_thread->state = WAIT;
 2f7:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 2fc:	c7 80 04 20 00 00 03 	movl   $0x3,0x2004(%eax)
 303:	00 00 00 

    // 다른 RUNNABLE 스레드가 있는지 확인
    int has_runnable = 0;
 306:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (int i = 0; i < MAX_THREAD; i++) {
 30d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 314:	eb 3a                	jmp    350 <thread_join+0x11a>
      if (&all_thread[i] != current_thread && all_thread[i].state == RUNNABLE) {
 316:	8b 45 f0             	mov    -0x10(%ebp),%eax
 319:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 31f:	8d 90 c0 0f 00 00    	lea    0xfc0(%eax),%edx
 325:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 32a:	39 c2                	cmp    %eax,%edx
 32c:	74 1e                	je     34c <thread_join+0x116>
 32e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 331:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 337:	05 c4 2f 00 00       	add    $0x2fc4,%eax
 33c:	8b 00                	mov    (%eax),%eax
 33e:	83 f8 02             	cmp    $0x2,%eax
 341:	75 09                	jne    34c <thread_join+0x116>
        has_runnable = 1;
 343:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        break;
 34a:	eb 0a                	jmp    356 <thread_join+0x120>
    for (int i = 0; i < MAX_THREAD; i++) {
 34c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 350:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
 354:	7e c0                	jle    316 <thread_join+0xe0>
      }
    }

    if (!has_runnable) {
 356:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 35a:	75 23                	jne    37f <thread_join+0x149>
      // 깨울 수 있는 다른 스레드가 없다면 스스로 다시 실행 가능하게 변경
      printf(1, "[thread_join] no RUNNABLE threads left, waking self\n");
 35c:	83 ec 08             	sub    $0x8,%esp
 35f:	68 10 0e 00 00       	push   $0xe10
 364:	6a 01                	push   $0x1
 366:	e8 d1 05 00 00       	call   93c <printf>
 36b:	83 c4 10             	add    $0x10,%esp
      current_thread->state = RUNNABLE;
 36e:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 373:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 37a:	00 00 00 
      break;
 37d:	eb 0a                	jmp    389 <thread_join+0x153>
    }

    // 스케줄링
    thread_schedule();
 37f:	e8 7c fc ff ff       	call   0 <thread_schedule>
  while (1) {
 384:	e9 4d ff ff ff       	jmp    2d6 <thread_join+0xa0>
  }

  printf(1, "[thread_join] child tid=%d finished\n", tid);
 389:	83 ec 04             	sub    $0x4,%esp
 38c:	ff 75 08             	push   0x8(%ebp)
 38f:	68 48 0e 00 00       	push   $0xe48
 394:	6a 01                	push   $0x1
 396:	e8 a1 05 00 00       	call   93c <printf>
 39b:	83 c4 10             	add    $0x10,%esp
  return 0;
 39e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3a3:	c9                   	leave
 3a4:	c3                   	ret

000003a5 <child_thread>:

static void 
child_thread(void)
{
 3a5:	55                   	push   %ebp
 3a6:	89 e5                	mov    %esp,%ebp
 3a8:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "[child] started: tid=%d, ptid=%d\n", current_thread->tid, current_thread->ptid);
 3ab:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 3b0:	8b 90 0c 20 00 00    	mov    0x200c(%eax),%edx
 3b6:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 3bb:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 3c1:	52                   	push   %edx
 3c2:	50                   	push   %eax
 3c3:	68 70 0e 00 00       	push   $0xe70
 3c8:	6a 01                	push   $0x1
 3ca:	e8 6d 05 00 00       	call   93c <printf>
 3cf:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 10; i++) {
 3d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3d9:	eb 1c                	jmp    3f7 <child_thread+0x52>
    printf(1, "[child] child thread 0x%x running iteration %d\n", (int)current_thread, i);
 3db:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 3e0:	ff 75 f4             	push   -0xc(%ebp)
 3e3:	50                   	push   %eax
 3e4:	68 94 0e 00 00       	push   $0xe94
 3e9:	6a 01                	push   $0x1
 3eb:	e8 4c 05 00 00       	call   93c <printf>
 3f0:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 10; i++) {
 3f3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3f7:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
 3fb:	7e de                	jle    3db <child_thread+0x36>
  }
  printf(1, "child thread: exit\n");
 3fd:	83 ec 08             	sub    $0x8,%esp
 400:	68 c4 0e 00 00       	push   $0xec4
 405:	6a 01                	push   $0x1
 407:	e8 30 05 00 00       	call   93c <printf>
 40c:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 40f:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 414:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 41b:	00 00 00 
  thread_schedule(); 
 41e:	e8 dd fb ff ff       	call   0 <thread_schedule>
}
 423:	90                   	nop
 424:	c9                   	leave
 425:	c3                   	ret

00000426 <mythread>:

static void 
mythread(void)
{
 426:	55                   	push   %ebp
 427:	89 e5                	mov    %esp,%ebp
 429:	83 ec 28             	sub    $0x28,%esp
  int i;
  int tid[5];

  printf(1, "[parent] mythread tid=%d creating children...\n", current_thread->tid);
 42c:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 431:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 437:	83 ec 04             	sub    $0x4,%esp
 43a:	50                   	push   %eax
 43b:	68 d8 0e 00 00       	push   $0xed8
 440:	6a 01                	push   $0x1
 442:	e8 f5 04 00 00       	call   93c <printf>
 447:	83 c4 10             	add    $0x10,%esp

  // 자식 스레드 생성하고 tid 저장
  for (i = 0; i < 5; i++) {
 44a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 451:	eb 35                	jmp    488 <mythread+0x62>
    tid[i] = thread_create(child_thread);
 453:	83 ec 0c             	sub    $0xc,%esp
 456:	68 a5 03 00 00       	push   $0x3a5
 45b:	e8 f8 fc ff ff       	call   158 <thread_create>
 460:	83 c4 10             	add    $0x10,%esp
 463:	8b 55 f4             	mov    -0xc(%ebp),%edx
 466:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
    printf(1, "[parent] created child with tid=%d\n", tid[i]);
 46a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46d:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
 471:	83 ec 04             	sub    $0x4,%esp
 474:	50                   	push   %eax
 475:	68 08 0f 00 00       	push   $0xf08
 47a:	6a 01                	push   $0x1
 47c:	e8 bb 04 00 00       	call   93c <printf>
 481:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 484:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 488:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 48c:	7e c5                	jle    453 <mythread+0x2d>
  }
  
  // 각 자식 스레드를 개별적으로 join
  for (i = 0; i < 5; i++) {
 48e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 495:	eb 4b                	jmp    4e2 <mythread+0xbc>
    printf(1, "[parent] joining child tid=%d\n", tid[i]);
 497:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49a:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
 49e:	83 ec 04             	sub    $0x4,%esp
 4a1:	50                   	push   %eax
 4a2:	68 2c 0f 00 00       	push   $0xf2c
 4a7:	6a 01                	push   $0x1
 4a9:	e8 8e 04 00 00       	call   93c <printf>
 4ae:	83 c4 10             	add    $0x10,%esp
    thread_join(tid[i]);
 4b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b4:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
 4b8:	83 ec 0c             	sub    $0xc,%esp
 4bb:	50                   	push   %eax
 4bc:	e8 75 fd ff ff       	call   236 <thread_join>
 4c1:	83 c4 10             	add    $0x10,%esp
    printf(1, "[parent] child tid=%d joined\n", tid[i]);
 4c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c7:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
 4cb:	83 ec 04             	sub    $0x4,%esp
 4ce:	50                   	push   %eax
 4cf:	68 4b 0f 00 00       	push   $0xf4b
 4d4:	6a 01                	push   $0x1
 4d6:	e8 61 04 00 00       	call   93c <printf>
 4db:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 4de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 4e2:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 4e6:	7e af                	jle    497 <mythread+0x71>
  }
    
  printf(1, "[parent] mythread done\n");
 4e8:	83 ec 08             	sub    $0x8,%esp
 4eb:	68 69 0f 00 00       	push   $0xf69
 4f0:	6a 01                	push   $0x1
 4f2:	e8 45 04 00 00       	call   93c <printf>
 4f7:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 4fa:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 4ff:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 506:	00 00 00 
  thread_schedule();
 509:	e8 f2 fa ff ff       	call   0 <thread_schedule>
}
 50e:	90                   	nop
 50f:	c9                   	leave
 510:	c3                   	ret

00000511 <main>:

int 
main(int argc, char *argv[]) 
{
 511:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 515:	83 e4 f0             	and    $0xfffffff0,%esp
 518:	ff 71 fc             	push   -0x4(%ecx)
 51b:	55                   	push   %ebp
 51c:	89 e5                	mov    %esp,%ebp
 51e:	51                   	push   %ecx
 51f:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 522:	e8 e0 fb ff ff       	call   107 <thread_init>
  thread_create(mythread);
 527:	83 ec 0c             	sub    $0xc,%esp
 52a:	68 26 04 00 00       	push   $0x426
 52f:	e8 24 fc ff ff       	call   158 <thread_create>
 534:	83 c4 10             	add    $0x10,%esp
  // main thread는 아무 역할이 없으므로 바로 FREE로 설정
  //current_thread->state = FREE;
  thread_schedule(); 
 537:	e8 c4 fa ff ff       	call   0 <thread_schedule>
  return 0;
 53c:	b8 00 00 00 00       	mov    $0x0,%eax
 541:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 544:	c9                   	leave
 545:	8d 61 fc             	lea    -0x4(%ecx),%esp
 548:	c3                   	ret

00000549 <thread_switch>:
         */
    .text
    .globl thread_switch
thread_switch:

    pushal
 549:	60                   	pusha

    movl current_thread, %eax
 54a:	a1 a0 0f 00 00       	mov    0xfa0,%eax
    movl %esp, (%eax)
 54f:	89 20                	mov    %esp,(%eax)

    movl next_thread, %eax
 551:	a1 a4 0f 00 00       	mov    0xfa4,%eax
    movl (%eax), %esp
 556:	8b 20                	mov    (%eax),%esp
    # esp = t1.주소

    movl %eax, current_thread
 558:	a3 a0 0f 00 00       	mov    %eax,0xfa0

    // 레지스터 복구
    popal
 55d:	61                   	popa

    movl $0, next_thread
 55e:	c7 05 a4 0f 00 00 00 	movl   $0x0,0xfa4
 565:	00 00 00 
    
 568:	c3                   	ret

00000569 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 569:	55                   	push   %ebp
 56a:	89 e5                	mov    %esp,%ebp
 56c:	57                   	push   %edi
 56d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 56e:	8b 4d 08             	mov    0x8(%ebp),%ecx
 571:	8b 55 10             	mov    0x10(%ebp),%edx
 574:	8b 45 0c             	mov    0xc(%ebp),%eax
 577:	89 cb                	mov    %ecx,%ebx
 579:	89 df                	mov    %ebx,%edi
 57b:	89 d1                	mov    %edx,%ecx
 57d:	fc                   	cld
 57e:	f3 aa                	rep stos %al,%es:(%edi)
 580:	89 ca                	mov    %ecx,%edx
 582:	89 fb                	mov    %edi,%ebx
 584:	89 5d 08             	mov    %ebx,0x8(%ebp)
 587:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 58a:	90                   	nop
 58b:	5b                   	pop    %ebx
 58c:	5f                   	pop    %edi
 58d:	5d                   	pop    %ebp
 58e:	c3                   	ret

0000058f <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 58f:	55                   	push   %ebp
 590:	89 e5                	mov    %esp,%ebp
 592:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 595:	8b 45 08             	mov    0x8(%ebp),%eax
 598:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 59b:	90                   	nop
 59c:	8b 55 0c             	mov    0xc(%ebp),%edx
 59f:	8d 42 01             	lea    0x1(%edx),%eax
 5a2:	89 45 0c             	mov    %eax,0xc(%ebp)
 5a5:	8b 45 08             	mov    0x8(%ebp),%eax
 5a8:	8d 48 01             	lea    0x1(%eax),%ecx
 5ab:	89 4d 08             	mov    %ecx,0x8(%ebp)
 5ae:	0f b6 12             	movzbl (%edx),%edx
 5b1:	88 10                	mov    %dl,(%eax)
 5b3:	0f b6 00             	movzbl (%eax),%eax
 5b6:	84 c0                	test   %al,%al
 5b8:	75 e2                	jne    59c <strcpy+0xd>
    ;
  return os;
 5ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5bd:	c9                   	leave
 5be:	c3                   	ret

000005bf <strcmp>:

int
strcmp(const char *p, const char *q)
{
 5bf:	55                   	push   %ebp
 5c0:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 5c2:	eb 08                	jmp    5cc <strcmp+0xd>
    p++, q++;
 5c4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5c8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 5cc:	8b 45 08             	mov    0x8(%ebp),%eax
 5cf:	0f b6 00             	movzbl (%eax),%eax
 5d2:	84 c0                	test   %al,%al
 5d4:	74 10                	je     5e6 <strcmp+0x27>
 5d6:	8b 45 08             	mov    0x8(%ebp),%eax
 5d9:	0f b6 10             	movzbl (%eax),%edx
 5dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 5df:	0f b6 00             	movzbl (%eax),%eax
 5e2:	38 c2                	cmp    %al,%dl
 5e4:	74 de                	je     5c4 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 5e6:	8b 45 08             	mov    0x8(%ebp),%eax
 5e9:	0f b6 00             	movzbl (%eax),%eax
 5ec:	0f b6 d0             	movzbl %al,%edx
 5ef:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f2:	0f b6 00             	movzbl (%eax),%eax
 5f5:	0f b6 c0             	movzbl %al,%eax
 5f8:	29 c2                	sub    %eax,%edx
 5fa:	89 d0                	mov    %edx,%eax
}
 5fc:	5d                   	pop    %ebp
 5fd:	c3                   	ret

000005fe <strlen>:

uint
strlen(char *s)
{
 5fe:	55                   	push   %ebp
 5ff:	89 e5                	mov    %esp,%ebp
 601:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 604:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 60b:	eb 04                	jmp    611 <strlen+0x13>
 60d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 611:	8b 55 fc             	mov    -0x4(%ebp),%edx
 614:	8b 45 08             	mov    0x8(%ebp),%eax
 617:	01 d0                	add    %edx,%eax
 619:	0f b6 00             	movzbl (%eax),%eax
 61c:	84 c0                	test   %al,%al
 61e:	75 ed                	jne    60d <strlen+0xf>
    ;
  return n;
 620:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 623:	c9                   	leave
 624:	c3                   	ret

00000625 <memset>:

void*
memset(void *dst, int c, uint n)
{
 625:	55                   	push   %ebp
 626:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 628:	8b 45 10             	mov    0x10(%ebp),%eax
 62b:	50                   	push   %eax
 62c:	ff 75 0c             	push   0xc(%ebp)
 62f:	ff 75 08             	push   0x8(%ebp)
 632:	e8 32 ff ff ff       	call   569 <stosb>
 637:	83 c4 0c             	add    $0xc,%esp
  return dst;
 63a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 63d:	c9                   	leave
 63e:	c3                   	ret

0000063f <strchr>:

char*
strchr(const char *s, char c)
{
 63f:	55                   	push   %ebp
 640:	89 e5                	mov    %esp,%ebp
 642:	83 ec 04             	sub    $0x4,%esp
 645:	8b 45 0c             	mov    0xc(%ebp),%eax
 648:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 64b:	eb 14                	jmp    661 <strchr+0x22>
    if(*s == c)
 64d:	8b 45 08             	mov    0x8(%ebp),%eax
 650:	0f b6 00             	movzbl (%eax),%eax
 653:	38 45 fc             	cmp    %al,-0x4(%ebp)
 656:	75 05                	jne    65d <strchr+0x1e>
      return (char*)s;
 658:	8b 45 08             	mov    0x8(%ebp),%eax
 65b:	eb 13                	jmp    670 <strchr+0x31>
  for(; *s; s++)
 65d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 661:	8b 45 08             	mov    0x8(%ebp),%eax
 664:	0f b6 00             	movzbl (%eax),%eax
 667:	84 c0                	test   %al,%al
 669:	75 e2                	jne    64d <strchr+0xe>
  return 0;
 66b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 670:	c9                   	leave
 671:	c3                   	ret

00000672 <gets>:

char*
gets(char *buf, int max)
{
 672:	55                   	push   %ebp
 673:	89 e5                	mov    %esp,%ebp
 675:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 678:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 67f:	eb 42                	jmp    6c3 <gets+0x51>
    cc = read(0, &c, 1);
 681:	83 ec 04             	sub    $0x4,%esp
 684:	6a 01                	push   $0x1
 686:	8d 45 ef             	lea    -0x11(%ebp),%eax
 689:	50                   	push   %eax
 68a:	6a 00                	push   $0x0
 68c:	e8 47 01 00 00       	call   7d8 <read>
 691:	83 c4 10             	add    $0x10,%esp
 694:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 697:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 69b:	7e 33                	jle    6d0 <gets+0x5e>
      break;
    buf[i++] = c;
 69d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6a0:	8d 50 01             	lea    0x1(%eax),%edx
 6a3:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6a6:	89 c2                	mov    %eax,%edx
 6a8:	8b 45 08             	mov    0x8(%ebp),%eax
 6ab:	01 c2                	add    %eax,%edx
 6ad:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6b1:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 6b3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6b7:	3c 0a                	cmp    $0xa,%al
 6b9:	74 16                	je     6d1 <gets+0x5f>
 6bb:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6bf:	3c 0d                	cmp    $0xd,%al
 6c1:	74 0e                	je     6d1 <gets+0x5f>
  for(i=0; i+1 < max; ){
 6c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c6:	83 c0 01             	add    $0x1,%eax
 6c9:	39 45 0c             	cmp    %eax,0xc(%ebp)
 6cc:	7f b3                	jg     681 <gets+0xf>
 6ce:	eb 01                	jmp    6d1 <gets+0x5f>
      break;
 6d0:	90                   	nop
      break;
  }
  buf[i] = '\0';
 6d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 6d4:	8b 45 08             	mov    0x8(%ebp),%eax
 6d7:	01 d0                	add    %edx,%eax
 6d9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 6dc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6df:	c9                   	leave
 6e0:	c3                   	ret

000006e1 <stat>:

int
stat(char *n, struct stat *st)
{
 6e1:	55                   	push   %ebp
 6e2:	89 e5                	mov    %esp,%ebp
 6e4:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6e7:	83 ec 08             	sub    $0x8,%esp
 6ea:	6a 00                	push   $0x0
 6ec:	ff 75 08             	push   0x8(%ebp)
 6ef:	e8 0c 01 00 00       	call   800 <open>
 6f4:	83 c4 10             	add    $0x10,%esp
 6f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 6fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6fe:	79 07                	jns    707 <stat+0x26>
    return -1;
 700:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 705:	eb 25                	jmp    72c <stat+0x4b>
  r = fstat(fd, st);
 707:	83 ec 08             	sub    $0x8,%esp
 70a:	ff 75 0c             	push   0xc(%ebp)
 70d:	ff 75 f4             	push   -0xc(%ebp)
 710:	e8 03 01 00 00       	call   818 <fstat>
 715:	83 c4 10             	add    $0x10,%esp
 718:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 71b:	83 ec 0c             	sub    $0xc,%esp
 71e:	ff 75 f4             	push   -0xc(%ebp)
 721:	e8 c2 00 00 00       	call   7e8 <close>
 726:	83 c4 10             	add    $0x10,%esp
  return r;
 729:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 72c:	c9                   	leave
 72d:	c3                   	ret

0000072e <atoi>:

int
atoi(const char *s)
{
 72e:	55                   	push   %ebp
 72f:	89 e5                	mov    %esp,%ebp
 731:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 734:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 73b:	eb 25                	jmp    762 <atoi+0x34>
    n = n*10 + *s++ - '0';
 73d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 740:	89 d0                	mov    %edx,%eax
 742:	c1 e0 02             	shl    $0x2,%eax
 745:	01 d0                	add    %edx,%eax
 747:	01 c0                	add    %eax,%eax
 749:	89 c1                	mov    %eax,%ecx
 74b:	8b 45 08             	mov    0x8(%ebp),%eax
 74e:	8d 50 01             	lea    0x1(%eax),%edx
 751:	89 55 08             	mov    %edx,0x8(%ebp)
 754:	0f b6 00             	movzbl (%eax),%eax
 757:	0f be c0             	movsbl %al,%eax
 75a:	01 c8                	add    %ecx,%eax
 75c:	83 e8 30             	sub    $0x30,%eax
 75f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 762:	8b 45 08             	mov    0x8(%ebp),%eax
 765:	0f b6 00             	movzbl (%eax),%eax
 768:	3c 2f                	cmp    $0x2f,%al
 76a:	7e 0a                	jle    776 <atoi+0x48>
 76c:	8b 45 08             	mov    0x8(%ebp),%eax
 76f:	0f b6 00             	movzbl (%eax),%eax
 772:	3c 39                	cmp    $0x39,%al
 774:	7e c7                	jle    73d <atoi+0xf>
  return n;
 776:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 779:	c9                   	leave
 77a:	c3                   	ret

0000077b <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 77b:	55                   	push   %ebp
 77c:	89 e5                	mov    %esp,%ebp
 77e:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 781:	8b 45 08             	mov    0x8(%ebp),%eax
 784:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 787:	8b 45 0c             	mov    0xc(%ebp),%eax
 78a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 78d:	eb 17                	jmp    7a6 <memmove+0x2b>
    *dst++ = *src++;
 78f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 792:	8d 42 01             	lea    0x1(%edx),%eax
 795:	89 45 f8             	mov    %eax,-0x8(%ebp)
 798:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79b:	8d 48 01             	lea    0x1(%eax),%ecx
 79e:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 7a1:	0f b6 12             	movzbl (%edx),%edx
 7a4:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 7a6:	8b 45 10             	mov    0x10(%ebp),%eax
 7a9:	8d 50 ff             	lea    -0x1(%eax),%edx
 7ac:	89 55 10             	mov    %edx,0x10(%ebp)
 7af:	85 c0                	test   %eax,%eax
 7b1:	7f dc                	jg     78f <memmove+0x14>
  return vdst;
 7b3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 7b6:	c9                   	leave
 7b7:	c3                   	ret

000007b8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 7b8:	b8 01 00 00 00       	mov    $0x1,%eax
 7bd:	cd 40                	int    $0x40
 7bf:	c3                   	ret

000007c0 <exit>:
SYSCALL(exit)
 7c0:	b8 02 00 00 00       	mov    $0x2,%eax
 7c5:	cd 40                	int    $0x40
 7c7:	c3                   	ret

000007c8 <wait>:
SYSCALL(wait)
 7c8:	b8 03 00 00 00       	mov    $0x3,%eax
 7cd:	cd 40                	int    $0x40
 7cf:	c3                   	ret

000007d0 <pipe>:
SYSCALL(pipe)
 7d0:	b8 04 00 00 00       	mov    $0x4,%eax
 7d5:	cd 40                	int    $0x40
 7d7:	c3                   	ret

000007d8 <read>:
SYSCALL(read)
 7d8:	b8 05 00 00 00       	mov    $0x5,%eax
 7dd:	cd 40                	int    $0x40
 7df:	c3                   	ret

000007e0 <write>:
SYSCALL(write)
 7e0:	b8 10 00 00 00       	mov    $0x10,%eax
 7e5:	cd 40                	int    $0x40
 7e7:	c3                   	ret

000007e8 <close>:
SYSCALL(close)
 7e8:	b8 15 00 00 00       	mov    $0x15,%eax
 7ed:	cd 40                	int    $0x40
 7ef:	c3                   	ret

000007f0 <kill>:
SYSCALL(kill)
 7f0:	b8 06 00 00 00       	mov    $0x6,%eax
 7f5:	cd 40                	int    $0x40
 7f7:	c3                   	ret

000007f8 <exec>:
SYSCALL(exec)
 7f8:	b8 07 00 00 00       	mov    $0x7,%eax
 7fd:	cd 40                	int    $0x40
 7ff:	c3                   	ret

00000800 <open>:
SYSCALL(open)
 800:	b8 0f 00 00 00       	mov    $0xf,%eax
 805:	cd 40                	int    $0x40
 807:	c3                   	ret

00000808 <mknod>:
SYSCALL(mknod)
 808:	b8 11 00 00 00       	mov    $0x11,%eax
 80d:	cd 40                	int    $0x40
 80f:	c3                   	ret

00000810 <unlink>:
SYSCALL(unlink)
 810:	b8 12 00 00 00       	mov    $0x12,%eax
 815:	cd 40                	int    $0x40
 817:	c3                   	ret

00000818 <fstat>:
SYSCALL(fstat)
 818:	b8 08 00 00 00       	mov    $0x8,%eax
 81d:	cd 40                	int    $0x40
 81f:	c3                   	ret

00000820 <link>:
SYSCALL(link)
 820:	b8 13 00 00 00       	mov    $0x13,%eax
 825:	cd 40                	int    $0x40
 827:	c3                   	ret

00000828 <mkdir>:
SYSCALL(mkdir)
 828:	b8 14 00 00 00       	mov    $0x14,%eax
 82d:	cd 40                	int    $0x40
 82f:	c3                   	ret

00000830 <chdir>:
SYSCALL(chdir)
 830:	b8 09 00 00 00       	mov    $0x9,%eax
 835:	cd 40                	int    $0x40
 837:	c3                   	ret

00000838 <dup>:
SYSCALL(dup)
 838:	b8 0a 00 00 00       	mov    $0xa,%eax
 83d:	cd 40                	int    $0x40
 83f:	c3                   	ret

00000840 <getpid>:
SYSCALL(getpid)
 840:	b8 0b 00 00 00       	mov    $0xb,%eax
 845:	cd 40                	int    $0x40
 847:	c3                   	ret

00000848 <sbrk>:
SYSCALL(sbrk)
 848:	b8 0c 00 00 00       	mov    $0xc,%eax
 84d:	cd 40                	int    $0x40
 84f:	c3                   	ret

00000850 <sleep>:
SYSCALL(sleep)
 850:	b8 0d 00 00 00       	mov    $0xd,%eax
 855:	cd 40                	int    $0x40
 857:	c3                   	ret

00000858 <uptime>:
SYSCALL(uptime)
 858:	b8 0e 00 00 00       	mov    $0xe,%eax
 85d:	cd 40                	int    $0x40
 85f:	c3                   	ret

00000860 <uthread_init>:
SYSCALL(uthread_init)
 860:	b8 16 00 00 00       	mov    $0x16,%eax
 865:	cd 40                	int    $0x40
 867:	c3                   	ret

00000868 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 868:	55                   	push   %ebp
 869:	89 e5                	mov    %esp,%ebp
 86b:	83 ec 18             	sub    $0x18,%esp
 86e:	8b 45 0c             	mov    0xc(%ebp),%eax
 871:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 874:	83 ec 04             	sub    $0x4,%esp
 877:	6a 01                	push   $0x1
 879:	8d 45 f4             	lea    -0xc(%ebp),%eax
 87c:	50                   	push   %eax
 87d:	ff 75 08             	push   0x8(%ebp)
 880:	e8 5b ff ff ff       	call   7e0 <write>
 885:	83 c4 10             	add    $0x10,%esp
}
 888:	90                   	nop
 889:	c9                   	leave
 88a:	c3                   	ret

0000088b <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 88b:	55                   	push   %ebp
 88c:	89 e5                	mov    %esp,%ebp
 88e:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 891:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 898:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 89c:	74 17                	je     8b5 <printint+0x2a>
 89e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 8a2:	79 11                	jns    8b5 <printint+0x2a>
    neg = 1;
 8a4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 8ab:	8b 45 0c             	mov    0xc(%ebp),%eax
 8ae:	f7 d8                	neg    %eax
 8b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8b3:	eb 06                	jmp    8bb <printint+0x30>
  } else {
    x = xx;
 8b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 8b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 8bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 8c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
 8c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8c8:	ba 00 00 00 00       	mov    $0x0,%edx
 8cd:	f7 f1                	div    %ecx
 8cf:	89 d1                	mov    %edx,%ecx
 8d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d4:	8d 50 01             	lea    0x1(%eax),%edx
 8d7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8da:	0f b6 91 88 0f 00 00 	movzbl 0xf88(%ecx),%edx
 8e1:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 8e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
 8e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8eb:	ba 00 00 00 00       	mov    $0x0,%edx
 8f0:	f7 f1                	div    %ecx
 8f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8f5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8f9:	75 c7                	jne    8c2 <printint+0x37>
  if(neg)
 8fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8ff:	74 2d                	je     92e <printint+0xa3>
    buf[i++] = '-';
 901:	8b 45 f4             	mov    -0xc(%ebp),%eax
 904:	8d 50 01             	lea    0x1(%eax),%edx
 907:	89 55 f4             	mov    %edx,-0xc(%ebp)
 90a:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 90f:	eb 1d                	jmp    92e <printint+0xa3>
    putc(fd, buf[i]);
 911:	8d 55 dc             	lea    -0x24(%ebp),%edx
 914:	8b 45 f4             	mov    -0xc(%ebp),%eax
 917:	01 d0                	add    %edx,%eax
 919:	0f b6 00             	movzbl (%eax),%eax
 91c:	0f be c0             	movsbl %al,%eax
 91f:	83 ec 08             	sub    $0x8,%esp
 922:	50                   	push   %eax
 923:	ff 75 08             	push   0x8(%ebp)
 926:	e8 3d ff ff ff       	call   868 <putc>
 92b:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 92e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 932:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 936:	79 d9                	jns    911 <printint+0x86>
}
 938:	90                   	nop
 939:	90                   	nop
 93a:	c9                   	leave
 93b:	c3                   	ret

0000093c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 93c:	55                   	push   %ebp
 93d:	89 e5                	mov    %esp,%ebp
 93f:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 942:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 949:	8d 45 0c             	lea    0xc(%ebp),%eax
 94c:	83 c0 04             	add    $0x4,%eax
 94f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 952:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 959:	e9 59 01 00 00       	jmp    ab7 <printf+0x17b>
    c = fmt[i] & 0xff;
 95e:	8b 55 0c             	mov    0xc(%ebp),%edx
 961:	8b 45 f0             	mov    -0x10(%ebp),%eax
 964:	01 d0                	add    %edx,%eax
 966:	0f b6 00             	movzbl (%eax),%eax
 969:	0f be c0             	movsbl %al,%eax
 96c:	25 ff 00 00 00       	and    $0xff,%eax
 971:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 974:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 978:	75 2c                	jne    9a6 <printf+0x6a>
      if(c == '%'){
 97a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 97e:	75 0c                	jne    98c <printf+0x50>
        state = '%';
 980:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 987:	e9 27 01 00 00       	jmp    ab3 <printf+0x177>
      } else {
        putc(fd, c);
 98c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 98f:	0f be c0             	movsbl %al,%eax
 992:	83 ec 08             	sub    $0x8,%esp
 995:	50                   	push   %eax
 996:	ff 75 08             	push   0x8(%ebp)
 999:	e8 ca fe ff ff       	call   868 <putc>
 99e:	83 c4 10             	add    $0x10,%esp
 9a1:	e9 0d 01 00 00       	jmp    ab3 <printf+0x177>
      }
    } else if(state == '%'){
 9a6:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 9aa:	0f 85 03 01 00 00    	jne    ab3 <printf+0x177>
      if(c == 'd'){
 9b0:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 9b4:	75 1e                	jne    9d4 <printf+0x98>
        printint(fd, *ap, 10, 1);
 9b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9b9:	8b 00                	mov    (%eax),%eax
 9bb:	6a 01                	push   $0x1
 9bd:	6a 0a                	push   $0xa
 9bf:	50                   	push   %eax
 9c0:	ff 75 08             	push   0x8(%ebp)
 9c3:	e8 c3 fe ff ff       	call   88b <printint>
 9c8:	83 c4 10             	add    $0x10,%esp
        ap++;
 9cb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9cf:	e9 d8 00 00 00       	jmp    aac <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 9d4:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 9d8:	74 06                	je     9e0 <printf+0xa4>
 9da:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 9de:	75 1e                	jne    9fe <printf+0xc2>
        printint(fd, *ap, 16, 0);
 9e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9e3:	8b 00                	mov    (%eax),%eax
 9e5:	6a 00                	push   $0x0
 9e7:	6a 10                	push   $0x10
 9e9:	50                   	push   %eax
 9ea:	ff 75 08             	push   0x8(%ebp)
 9ed:	e8 99 fe ff ff       	call   88b <printint>
 9f2:	83 c4 10             	add    $0x10,%esp
        ap++;
 9f5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9f9:	e9 ae 00 00 00       	jmp    aac <printf+0x170>
      } else if(c == 's'){
 9fe:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 a02:	75 43                	jne    a47 <printf+0x10b>
        s = (char*)*ap;
 a04:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a07:	8b 00                	mov    (%eax),%eax
 a09:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 a0c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 a10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a14:	75 25                	jne    a3b <printf+0xff>
          s = "(null)";
 a16:	c7 45 f4 81 0f 00 00 	movl   $0xf81,-0xc(%ebp)
        while(*s != 0){
 a1d:	eb 1c                	jmp    a3b <printf+0xff>
          putc(fd, *s);
 a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a22:	0f b6 00             	movzbl (%eax),%eax
 a25:	0f be c0             	movsbl %al,%eax
 a28:	83 ec 08             	sub    $0x8,%esp
 a2b:	50                   	push   %eax
 a2c:	ff 75 08             	push   0x8(%ebp)
 a2f:	e8 34 fe ff ff       	call   868 <putc>
 a34:	83 c4 10             	add    $0x10,%esp
          s++;
 a37:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3e:	0f b6 00             	movzbl (%eax),%eax
 a41:	84 c0                	test   %al,%al
 a43:	75 da                	jne    a1f <printf+0xe3>
 a45:	eb 65                	jmp    aac <printf+0x170>
        }
      } else if(c == 'c'){
 a47:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a4b:	75 1d                	jne    a6a <printf+0x12e>
        putc(fd, *ap);
 a4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a50:	8b 00                	mov    (%eax),%eax
 a52:	0f be c0             	movsbl %al,%eax
 a55:	83 ec 08             	sub    $0x8,%esp
 a58:	50                   	push   %eax
 a59:	ff 75 08             	push   0x8(%ebp)
 a5c:	e8 07 fe ff ff       	call   868 <putc>
 a61:	83 c4 10             	add    $0x10,%esp
        ap++;
 a64:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a68:	eb 42                	jmp    aac <printf+0x170>
      } else if(c == '%'){
 a6a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a6e:	75 17                	jne    a87 <printf+0x14b>
        putc(fd, c);
 a70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a73:	0f be c0             	movsbl %al,%eax
 a76:	83 ec 08             	sub    $0x8,%esp
 a79:	50                   	push   %eax
 a7a:	ff 75 08             	push   0x8(%ebp)
 a7d:	e8 e6 fd ff ff       	call   868 <putc>
 a82:	83 c4 10             	add    $0x10,%esp
 a85:	eb 25                	jmp    aac <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a87:	83 ec 08             	sub    $0x8,%esp
 a8a:	6a 25                	push   $0x25
 a8c:	ff 75 08             	push   0x8(%ebp)
 a8f:	e8 d4 fd ff ff       	call   868 <putc>
 a94:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 a97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a9a:	0f be c0             	movsbl %al,%eax
 a9d:	83 ec 08             	sub    $0x8,%esp
 aa0:	50                   	push   %eax
 aa1:	ff 75 08             	push   0x8(%ebp)
 aa4:	e8 bf fd ff ff       	call   868 <putc>
 aa9:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 aac:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 ab3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 ab7:	8b 55 0c             	mov    0xc(%ebp),%edx
 aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
 abd:	01 d0                	add    %edx,%eax
 abf:	0f b6 00             	movzbl (%eax),%eax
 ac2:	84 c0                	test   %al,%al
 ac4:	0f 85 94 fe ff ff    	jne    95e <printf+0x22>
    }
  }
}
 aca:	90                   	nop
 acb:	90                   	nop
 acc:	c9                   	leave
 acd:	c3                   	ret

00000ace <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ace:	55                   	push   %ebp
 acf:	89 e5                	mov    %esp,%ebp
 ad1:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ad4:	8b 45 08             	mov    0x8(%ebp),%eax
 ad7:	83 e8 08             	sub    $0x8,%eax
 ada:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 add:	a1 68 50 01 00       	mov    0x15068,%eax
 ae2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ae5:	eb 24                	jmp    b0b <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ae7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aea:	8b 00                	mov    (%eax),%eax
 aec:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 aef:	72 12                	jb     b03 <free+0x35>
 af1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 af4:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 af7:	72 24                	jb     b1d <free+0x4f>
 af9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 afc:	8b 00                	mov    (%eax),%eax
 afe:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b01:	72 1a                	jb     b1d <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b03:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b06:	8b 00                	mov    (%eax),%eax
 b08:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b0e:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 b11:	73 d4                	jae    ae7 <free+0x19>
 b13:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b16:	8b 00                	mov    (%eax),%eax
 b18:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b1b:	73 ca                	jae    ae7 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 b1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b20:	8b 40 04             	mov    0x4(%eax),%eax
 b23:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b2d:	01 c2                	add    %eax,%edx
 b2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b32:	8b 00                	mov    (%eax),%eax
 b34:	39 c2                	cmp    %eax,%edx
 b36:	75 24                	jne    b5c <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 b38:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b3b:	8b 50 04             	mov    0x4(%eax),%edx
 b3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b41:	8b 00                	mov    (%eax),%eax
 b43:	8b 40 04             	mov    0x4(%eax),%eax
 b46:	01 c2                	add    %eax,%edx
 b48:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b4b:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b51:	8b 00                	mov    (%eax),%eax
 b53:	8b 10                	mov    (%eax),%edx
 b55:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b58:	89 10                	mov    %edx,(%eax)
 b5a:	eb 0a                	jmp    b66 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 b5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b5f:	8b 10                	mov    (%eax),%edx
 b61:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b64:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b66:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b69:	8b 40 04             	mov    0x4(%eax),%eax
 b6c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b73:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b76:	01 d0                	add    %edx,%eax
 b78:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b7b:	75 20                	jne    b9d <free+0xcf>
    p->s.size += bp->s.size;
 b7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b80:	8b 50 04             	mov    0x4(%eax),%edx
 b83:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b86:	8b 40 04             	mov    0x4(%eax),%eax
 b89:	01 c2                	add    %eax,%edx
 b8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b8e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b91:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b94:	8b 10                	mov    (%eax),%edx
 b96:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b99:	89 10                	mov    %edx,(%eax)
 b9b:	eb 08                	jmp    ba5 <free+0xd7>
  } else
    p->s.ptr = bp;
 b9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ba0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 ba3:	89 10                	mov    %edx,(%eax)
  freep = p;
 ba5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ba8:	a3 68 50 01 00       	mov    %eax,0x15068
}
 bad:	90                   	nop
 bae:	c9                   	leave
 baf:	c3                   	ret

00000bb0 <morecore>:

static Header*
morecore(uint nu)
{
 bb0:	55                   	push   %ebp
 bb1:	89 e5                	mov    %esp,%ebp
 bb3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 bb6:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 bbd:	77 07                	ja     bc6 <morecore+0x16>
    nu = 4096;
 bbf:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 bc6:	8b 45 08             	mov    0x8(%ebp),%eax
 bc9:	c1 e0 03             	shl    $0x3,%eax
 bcc:	83 ec 0c             	sub    $0xc,%esp
 bcf:	50                   	push   %eax
 bd0:	e8 73 fc ff ff       	call   848 <sbrk>
 bd5:	83 c4 10             	add    $0x10,%esp
 bd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 bdb:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 bdf:	75 07                	jne    be8 <morecore+0x38>
    return 0;
 be1:	b8 00 00 00 00       	mov    $0x0,%eax
 be6:	eb 26                	jmp    c0e <morecore+0x5e>
  hp = (Header*)p;
 be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 beb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 bee:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bf1:	8b 55 08             	mov    0x8(%ebp),%edx
 bf4:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 bf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bfa:	83 c0 08             	add    $0x8,%eax
 bfd:	83 ec 0c             	sub    $0xc,%esp
 c00:	50                   	push   %eax
 c01:	e8 c8 fe ff ff       	call   ace <free>
 c06:	83 c4 10             	add    $0x10,%esp
  return freep;
 c09:	a1 68 50 01 00       	mov    0x15068,%eax
}
 c0e:	c9                   	leave
 c0f:	c3                   	ret

00000c10 <malloc>:

void*
malloc(uint nbytes)
{
 c10:	55                   	push   %ebp
 c11:	89 e5                	mov    %esp,%ebp
 c13:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c16:	8b 45 08             	mov    0x8(%ebp),%eax
 c19:	83 c0 07             	add    $0x7,%eax
 c1c:	c1 e8 03             	shr    $0x3,%eax
 c1f:	83 c0 01             	add    $0x1,%eax
 c22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 c25:	a1 68 50 01 00       	mov    0x15068,%eax
 c2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c2d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c31:	75 23                	jne    c56 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 c33:	c7 45 f0 60 50 01 00 	movl   $0x15060,-0x10(%ebp)
 c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c3d:	a3 68 50 01 00       	mov    %eax,0x15068
 c42:	a1 68 50 01 00       	mov    0x15068,%eax
 c47:	a3 60 50 01 00       	mov    %eax,0x15060
    base.s.size = 0;
 c4c:	c7 05 64 50 01 00 00 	movl   $0x0,0x15064
 c53:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c56:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c59:	8b 00                	mov    (%eax),%eax
 c5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c61:	8b 40 04             	mov    0x4(%eax),%eax
 c64:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c67:	72 4d                	jb     cb6 <malloc+0xa6>
      if(p->s.size == nunits)
 c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c6c:	8b 40 04             	mov    0x4(%eax),%eax
 c6f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 c72:	75 0c                	jne    c80 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c77:	8b 10                	mov    (%eax),%edx
 c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c7c:	89 10                	mov    %edx,(%eax)
 c7e:	eb 26                	jmp    ca6 <malloc+0x96>
      else {
        p->s.size -= nunits;
 c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c83:	8b 40 04             	mov    0x4(%eax),%eax
 c86:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c89:	89 c2                	mov    %eax,%edx
 c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c8e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c94:	8b 40 04             	mov    0x4(%eax),%eax
 c97:	c1 e0 03             	shl    $0x3,%eax
 c9a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ca0:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ca3:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ca9:	a3 68 50 01 00       	mov    %eax,0x15068
      return (void*)(p + 1);
 cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cb1:	83 c0 08             	add    $0x8,%eax
 cb4:	eb 3b                	jmp    cf1 <malloc+0xe1>
    }
    if(p == freep)
 cb6:	a1 68 50 01 00       	mov    0x15068,%eax
 cbb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 cbe:	75 1e                	jne    cde <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 cc0:	83 ec 0c             	sub    $0xc,%esp
 cc3:	ff 75 ec             	push   -0x14(%ebp)
 cc6:	e8 e5 fe ff ff       	call   bb0 <morecore>
 ccb:	83 c4 10             	add    $0x10,%esp
 cce:	89 45 f4             	mov    %eax,-0xc(%ebp)
 cd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 cd5:	75 07                	jne    cde <malloc+0xce>
        return 0;
 cd7:	b8 00 00 00 00       	mov    $0x0,%eax
 cdc:	eb 13                	jmp    cf1 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ce1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ce7:	8b 00                	mov    (%eax),%eax
 ce9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 cec:	e9 6d ff ff ff       	jmp    c5e <malloc+0x4e>
  }
}
 cf1:	c9                   	leave
 cf2:	c3                   	ret
