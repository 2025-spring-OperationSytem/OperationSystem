
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
   6:	c7 05 c4 0f 00 00 00 	movl   $0x0,0xfc4
   d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 e0 0f 00 00 	movl   $0xfe0,-0xc(%ebp)
  17:	eb 29                	jmp    42 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  22:	83 f8 02             	cmp    $0x2,%eax
  25:	75 14                	jne    3b <thread_schedule+0x3b>
  27:	a1 c0 0f 00 00       	mov    0xfc0,%eax
  2c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  2f:	74 0a                	je     3b <thread_schedule+0x3b>
      next_thread = t;
  31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  34:	a3 c4 0f 00 00       	mov    %eax,0xfc4
      break;
  39:	eb 11                	jmp    4c <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  3b:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
  42:	b8 80 50 01 00       	mov    $0x15080,%eax
  47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4a:	72 cd                	jb     19 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  4c:	b8 80 50 01 00       	mov    $0x15080,%eax
  51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  54:	72 1a                	jb     70 <thread_schedule+0x70>
  56:	a1 c0 0f 00 00       	mov    0xfc0,%eax
  5b:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  61:	83 f8 02             	cmp    $0x2,%eax
  64:	75 0a                	jne    70 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  66:	a1 c0 0f 00 00       	mov    0xfc0,%eax
  6b:	a3 c4 0f 00 00       	mov    %eax,0xfc4
  }

  if (next_thread == 0) {
  70:	a1 c4 0f 00 00       	mov    0xfc4,%eax
  75:	85 c0                	test   %eax,%eax
  77:	75 17                	jne    90 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 04 0d 00 00       	push   $0xd04
  81:	6a 02                	push   $0x2
  83:	e8 c3 08 00 00       	call   94b <printf>
  88:	83 c4 10             	add    $0x10,%esp
    exit();
  8b:	e8 3f 07 00 00       	call   7cf <exit>
  }

  if (current_thread != next_thread) {
  90:	8b 15 c0 0f 00 00    	mov    0xfc0,%edx
  96:	a1 c4 0f 00 00       	mov    0xfc4,%eax
  9b:	39 c2                	cmp    %eax,%edx
  9d:	74 5b                	je     fa <thread_schedule+0xfa>
    next_thread->state = RUNNING;
  9f:	a1 c4 0f 00 00       	mov    0xfc4,%eax
  a4:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  ab:	00 00 00 
    if (current_thread->state != FREE) {
  ae:	a1 c0 0f 00 00       	mov    0xfc0,%eax
  b3:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  b9:	85 c0                	test   %eax,%eax
  bb:	74 0f                	je     cc <thread_schedule+0xcc>
      current_thread->state = RUNNABLE;
  bd:	a1 c0 0f 00 00       	mov    0xfc0,%eax
  c2:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
  c9:	00 00 00 
    }
  
    printf(1, "[sched] switch from tid=%d to tid=%d\n", current_thread->tid, next_thread->tid);
  cc:	a1 c4 0f 00 00       	mov    0xfc4,%eax
  d1:	8b 90 08 20 00 00    	mov    0x2008(%eax),%edx
  d7:	a1 c0 0f 00 00       	mov    0xfc0,%eax
  dc:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
  e2:	52                   	push   %edx
  e3:	50                   	push   %eax
  e4:	68 2c 0d 00 00       	push   $0xd2c
  e9:	6a 01                	push   $0x1
  eb:	e8 5b 08 00 00       	call   94b <printf>
  f0:	83 c4 10             	add    $0x10,%esp
    thread_switch();
  f3:	e8 60 04 00 00       	call   558 <thread_switch>
  } else
    next_thread = 0;
}
  f8:	eb 0a                	jmp    104 <thread_schedule+0x104>
    next_thread = 0;
  fa:	c7 05 c4 0f 00 00 00 	movl   $0x0,0xfc4
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
 10d:	c7 05 c0 0f 00 00 e0 	movl   $0xfe0,0xfc0
 114:	0f 00 00 
  current_thread->state = RUNNING;
 117:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 11c:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 123:	00 00 00 
  current_thread->tid=0;
 126:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 12b:	c7 80 08 20 00 00 00 	movl   $0x0,0x2008(%eax)
 132:	00 00 00 
  current_thread->ptid=0;
 135:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 13a:	c7 80 0c 20 00 00 00 	movl   $0x0,0x200c(%eax)
 141:	00 00 00 

  uthread_init((int)thread_schedule);
 144:	b8 00 00 00 00       	mov    $0x0,%eax
 149:	83 ec 0c             	sub    $0xc,%esp
 14c:	50                   	push   %eax
 14d:	e8 1d 07 00 00       	call   86f <uthread_init>
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
 161:	68 52 0d 00 00       	push   $0xd52
 166:	6a 01                	push   $0x1
 168:	e8 de 07 00 00       	call   94b <printf>
 16d:	83 c4 10             	add    $0x10,%esp
  
  thread_p t;
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 170:	c7 45 f4 e0 0f 00 00 	movl   $0xfe0,-0xc(%ebp)
 177:	eb 14                	jmp    18d <thread_create+0x35>
    if (t->state == FREE) break;
 179:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 182:	85 c0                	test   %eax,%eax
 184:	74 13                	je     199 <thread_create+0x41>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 186:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
 18d:	b8 80 50 01 00       	mov    $0x15080,%eax
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
 1d5:	2d e0 0f 00 00       	sub    $0xfe0,%eax
 1da:	c1 f8 04             	sar    $0x4,%eax
 1dd:	69 c0 01 fe 03 f8    	imul   $0xf803fe01,%eax,%eax
 1e3:	89 c2                	mov    %eax,%edx
 1e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e8:	89 90 08 20 00 00    	mov    %edx,0x2008(%eax)
  t->ptid = current_thread->tid;
 1ee:	a1 c0 0f 00 00       	mov    0xfc0,%eax
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
 21c:	68 64 0d 00 00       	push   $0xd64
 221:	6a 01                	push   $0x1
 223:	e8 23 07 00 00       	call   94b <printf>
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
 24e:	68 8c 0d 00 00       	push   $0xd8c
 253:	6a 01                	push   $0x1
 255:	e8 f1 06 00 00       	call   94b <printf>
 25a:	83 c4 10             	add    $0x10,%esp
    return -1;
 25d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 262:	e9 3c 01 00 00       	jmp    3a3 <thread_join+0x16d>
  }

  thread_p target = &all_thread[tid];
 267:	8b 45 08             	mov    0x8(%ebp),%eax
 26a:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 270:	05 e0 0f 00 00       	add    $0xfe0,%eax
 275:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // 유효한 자식인지 확인
  if (target->ptid != current_thread->tid) {
 278:	8b 45 ec             	mov    -0x14(%ebp),%eax
 27b:	8b 90 0c 20 00 00    	mov    0x200c(%eax),%edx
 281:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 286:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 28c:	39 c2                	cmp    %eax,%edx
 28e:	74 28                	je     2b8 <thread_join+0x82>
    printf(1, "[thread_join] tid=%d is not a child of current thread=%d\n", tid, current_thread->tid);
 290:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 295:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 29b:	50                   	push   %eax
 29c:	ff 75 08             	push   0x8(%ebp)
 29f:	68 b4 0d 00 00       	push   $0xdb4
 2a4:	6a 01                	push   $0x1
 2a6:	e8 a0 06 00 00       	call   94b <printf>
 2ab:	83 c4 10             	add    $0x10,%esp
    return -1;
 2ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2b3:	e9 eb 00 00 00       	jmp    3a3 <thread_join+0x16d>
  }

  printf(1, "[thread_join] current=%d waiting for child=%d\n", current_thread->tid, tid);
 2b8:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 2bd:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 2c3:	ff 75 08             	push   0x8(%ebp)
 2c6:	50                   	push   %eax
 2c7:	68 f0 0d 00 00       	push   $0xdf0
 2cc:	6a 01                	push   $0x1
 2ce:	e8 78 06 00 00       	call   94b <printf>
 2d3:	83 c4 10             	add    $0x10,%esp

  while (1) {
    if (target->state == FREE) {
 2d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 2d9:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 2df:	85 c0                	test   %eax,%eax
 2e1:	75 14                	jne    2f7 <thread_join+0xc1>
      // 자식 종료되었으면 실행 가능 상태로 복귀
      current_thread->state = RUNNABLE;
 2e3:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 2e8:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 2ef:	00 00 00 
      break;
 2f2:	e9 92 00 00 00       	jmp    389 <thread_join+0x153>
    }

    // WAIT으로 변경
    current_thread->state = WAIT;
 2f7:	a1 c0 0f 00 00       	mov    0xfc0,%eax
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
 31f:	8d 90 e0 0f 00 00    	lea    0xfe0(%eax),%edx
 325:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 32a:	39 c2                	cmp    %eax,%edx
 32c:	74 1e                	je     34c <thread_join+0x116>
 32e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 331:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 337:	05 e4 2f 00 00       	add    $0x2fe4,%eax
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
 35f:	68 20 0e 00 00       	push   $0xe20
 364:	6a 01                	push   $0x1
 366:	e8 e0 05 00 00       	call   94b <printf>
 36b:	83 c4 10             	add    $0x10,%esp
      current_thread->state = RUNNABLE;
 36e:	a1 c0 0f 00 00       	mov    0xfc0,%eax
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
 38f:	68 58 0e 00 00       	push   $0xe58
 394:	6a 01                	push   $0x1
 396:	e8 b0 05 00 00       	call   94b <printf>
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
 3ab:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 3b0:	8b 90 0c 20 00 00    	mov    0x200c(%eax),%edx
 3b6:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 3bb:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 3c1:	52                   	push   %edx
 3c2:	50                   	push   %eax
 3c3:	68 80 0e 00 00       	push   $0xe80
 3c8:	6a 01                	push   $0x1
 3ca:	e8 7c 05 00 00       	call   94b <printf>
 3cf:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 10; i++) {
 3d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3d9:	eb 1c                	jmp    3f7 <child_thread+0x52>
    printf(1, "[child] child thread 0x%x running iteration %d\n", (int)current_thread, i);
 3db:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 3e0:	ff 75 f4             	push   -0xc(%ebp)
 3e3:	50                   	push   %eax
 3e4:	68 a4 0e 00 00       	push   $0xea4
 3e9:	6a 01                	push   $0x1
 3eb:	e8 5b 05 00 00       	call   94b <printf>
 3f0:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 10; i++) {
 3f3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3f7:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
 3fb:	7e de                	jle    3db <child_thread+0x36>
  }
  printf(1, "child thread: exit\n");
 3fd:	83 ec 08             	sub    $0x8,%esp
 400:	68 d4 0e 00 00       	push   $0xed4
 405:	6a 01                	push   $0x1
 407:	e8 3f 05 00 00       	call   94b <printf>
 40c:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 40f:	a1 c0 0f 00 00       	mov    0xfc0,%eax
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
 42c:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 431:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 437:	83 ec 04             	sub    $0x4,%esp
 43a:	50                   	push   %eax
 43b:	68 e8 0e 00 00       	push   $0xee8
 440:	6a 01                	push   $0x1
 442:	e8 04 05 00 00       	call   94b <printf>
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
 475:	68 18 0f 00 00       	push   $0xf18
 47a:	6a 01                	push   $0x1
 47c:	e8 ca 04 00 00       	call   94b <printf>
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
 4a2:	68 3c 0f 00 00       	push   $0xf3c
 4a7:	6a 01                	push   $0x1
 4a9:	e8 9d 04 00 00       	call   94b <printf>
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
 4cf:	68 5b 0f 00 00       	push   $0xf5b
 4d4:	6a 01                	push   $0x1
 4d6:	e8 70 04 00 00       	call   94b <printf>
 4db:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 4de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 4e2:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 4e6:	7e af                	jle    497 <mythread+0x71>
  }
    
  printf(1, "[parent] mythread done\n");
 4e8:	83 ec 08             	sub    $0x8,%esp
 4eb:	68 79 0f 00 00       	push   $0xf79
 4f0:	6a 01                	push   $0x1
 4f2:	e8 54 04 00 00       	call   94b <printf>
 4f7:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 4fa:	a1 c0 0f 00 00       	mov    0xfc0,%eax
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
  current_thread->state = FREE;
 537:	a1 c0 0f 00 00       	mov    0xfc0,%eax
 53c:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 543:	00 00 00 
  thread_schedule(); 
 546:	e8 b5 fa ff ff       	call   0 <thread_schedule>
  return 0;
 54b:	b8 00 00 00 00       	mov    $0x0,%eax
 550:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 553:	c9                   	leave
 554:	8d 61 fc             	lea    -0x4(%ecx),%esp
 557:	c3                   	ret

00000558 <thread_switch>:
         */
    .text
    .globl thread_switch
thread_switch:

    pushal
 558:	60                   	pusha

    movl current_thread, %eax
 559:	a1 c0 0f 00 00       	mov    0xfc0,%eax
    movl %esp, (%eax)
 55e:	89 20                	mov    %esp,(%eax)

    movl next_thread, %eax
 560:	a1 c4 0f 00 00       	mov    0xfc4,%eax
    movl (%eax), %esp
 565:	8b 20                	mov    (%eax),%esp
    # esp = t1.주소

    movl %eax, current_thread
 567:	a3 c0 0f 00 00       	mov    %eax,0xfc0

    // 레지스터 복구
    popal
 56c:	61                   	popa

    movl $0, next_thread
 56d:	c7 05 c4 0f 00 00 00 	movl   $0x0,0xfc4
 574:	00 00 00 
    
 577:	c3                   	ret

00000578 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 578:	55                   	push   %ebp
 579:	89 e5                	mov    %esp,%ebp
 57b:	57                   	push   %edi
 57c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 57d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 580:	8b 55 10             	mov    0x10(%ebp),%edx
 583:	8b 45 0c             	mov    0xc(%ebp),%eax
 586:	89 cb                	mov    %ecx,%ebx
 588:	89 df                	mov    %ebx,%edi
 58a:	89 d1                	mov    %edx,%ecx
 58c:	fc                   	cld
 58d:	f3 aa                	rep stos %al,%es:(%edi)
 58f:	89 ca                	mov    %ecx,%edx
 591:	89 fb                	mov    %edi,%ebx
 593:	89 5d 08             	mov    %ebx,0x8(%ebp)
 596:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 599:	90                   	nop
 59a:	5b                   	pop    %ebx
 59b:	5f                   	pop    %edi
 59c:	5d                   	pop    %ebp
 59d:	c3                   	ret

0000059e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 59e:	55                   	push   %ebp
 59f:	89 e5                	mov    %esp,%ebp
 5a1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 5a4:	8b 45 08             	mov    0x8(%ebp),%eax
 5a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 5aa:	90                   	nop
 5ab:	8b 55 0c             	mov    0xc(%ebp),%edx
 5ae:	8d 42 01             	lea    0x1(%edx),%eax
 5b1:	89 45 0c             	mov    %eax,0xc(%ebp)
 5b4:	8b 45 08             	mov    0x8(%ebp),%eax
 5b7:	8d 48 01             	lea    0x1(%eax),%ecx
 5ba:	89 4d 08             	mov    %ecx,0x8(%ebp)
 5bd:	0f b6 12             	movzbl (%edx),%edx
 5c0:	88 10                	mov    %dl,(%eax)
 5c2:	0f b6 00             	movzbl (%eax),%eax
 5c5:	84 c0                	test   %al,%al
 5c7:	75 e2                	jne    5ab <strcpy+0xd>
    ;
  return os;
 5c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5cc:	c9                   	leave
 5cd:	c3                   	ret

000005ce <strcmp>:

int
strcmp(const char *p, const char *q)
{
 5ce:	55                   	push   %ebp
 5cf:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 5d1:	eb 08                	jmp    5db <strcmp+0xd>
    p++, q++;
 5d3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5d7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 5db:	8b 45 08             	mov    0x8(%ebp),%eax
 5de:	0f b6 00             	movzbl (%eax),%eax
 5e1:	84 c0                	test   %al,%al
 5e3:	74 10                	je     5f5 <strcmp+0x27>
 5e5:	8b 45 08             	mov    0x8(%ebp),%eax
 5e8:	0f b6 10             	movzbl (%eax),%edx
 5eb:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ee:	0f b6 00             	movzbl (%eax),%eax
 5f1:	38 c2                	cmp    %al,%dl
 5f3:	74 de                	je     5d3 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 5f5:	8b 45 08             	mov    0x8(%ebp),%eax
 5f8:	0f b6 00             	movzbl (%eax),%eax
 5fb:	0f b6 d0             	movzbl %al,%edx
 5fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 601:	0f b6 00             	movzbl (%eax),%eax
 604:	0f b6 c0             	movzbl %al,%eax
 607:	29 c2                	sub    %eax,%edx
 609:	89 d0                	mov    %edx,%eax
}
 60b:	5d                   	pop    %ebp
 60c:	c3                   	ret

0000060d <strlen>:

uint
strlen(char *s)
{
 60d:	55                   	push   %ebp
 60e:	89 e5                	mov    %esp,%ebp
 610:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 613:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 61a:	eb 04                	jmp    620 <strlen+0x13>
 61c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 620:	8b 55 fc             	mov    -0x4(%ebp),%edx
 623:	8b 45 08             	mov    0x8(%ebp),%eax
 626:	01 d0                	add    %edx,%eax
 628:	0f b6 00             	movzbl (%eax),%eax
 62b:	84 c0                	test   %al,%al
 62d:	75 ed                	jne    61c <strlen+0xf>
    ;
  return n;
 62f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 632:	c9                   	leave
 633:	c3                   	ret

00000634 <memset>:

void*
memset(void *dst, int c, uint n)
{
 634:	55                   	push   %ebp
 635:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 637:	8b 45 10             	mov    0x10(%ebp),%eax
 63a:	50                   	push   %eax
 63b:	ff 75 0c             	push   0xc(%ebp)
 63e:	ff 75 08             	push   0x8(%ebp)
 641:	e8 32 ff ff ff       	call   578 <stosb>
 646:	83 c4 0c             	add    $0xc,%esp
  return dst;
 649:	8b 45 08             	mov    0x8(%ebp),%eax
}
 64c:	c9                   	leave
 64d:	c3                   	ret

0000064e <strchr>:

char*
strchr(const char *s, char c)
{
 64e:	55                   	push   %ebp
 64f:	89 e5                	mov    %esp,%ebp
 651:	83 ec 04             	sub    $0x4,%esp
 654:	8b 45 0c             	mov    0xc(%ebp),%eax
 657:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 65a:	eb 14                	jmp    670 <strchr+0x22>
    if(*s == c)
 65c:	8b 45 08             	mov    0x8(%ebp),%eax
 65f:	0f b6 00             	movzbl (%eax),%eax
 662:	38 45 fc             	cmp    %al,-0x4(%ebp)
 665:	75 05                	jne    66c <strchr+0x1e>
      return (char*)s;
 667:	8b 45 08             	mov    0x8(%ebp),%eax
 66a:	eb 13                	jmp    67f <strchr+0x31>
  for(; *s; s++)
 66c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 670:	8b 45 08             	mov    0x8(%ebp),%eax
 673:	0f b6 00             	movzbl (%eax),%eax
 676:	84 c0                	test   %al,%al
 678:	75 e2                	jne    65c <strchr+0xe>
  return 0;
 67a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 67f:	c9                   	leave
 680:	c3                   	ret

00000681 <gets>:

char*
gets(char *buf, int max)
{
 681:	55                   	push   %ebp
 682:	89 e5                	mov    %esp,%ebp
 684:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 687:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 68e:	eb 42                	jmp    6d2 <gets+0x51>
    cc = read(0, &c, 1);
 690:	83 ec 04             	sub    $0x4,%esp
 693:	6a 01                	push   $0x1
 695:	8d 45 ef             	lea    -0x11(%ebp),%eax
 698:	50                   	push   %eax
 699:	6a 00                	push   $0x0
 69b:	e8 47 01 00 00       	call   7e7 <read>
 6a0:	83 c4 10             	add    $0x10,%esp
 6a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 6a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6aa:	7e 33                	jle    6df <gets+0x5e>
      break;
    buf[i++] = c;
 6ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6af:	8d 50 01             	lea    0x1(%eax),%edx
 6b2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6b5:	89 c2                	mov    %eax,%edx
 6b7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ba:	01 c2                	add    %eax,%edx
 6bc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6c0:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 6c2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6c6:	3c 0a                	cmp    $0xa,%al
 6c8:	74 16                	je     6e0 <gets+0x5f>
 6ca:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6ce:	3c 0d                	cmp    $0xd,%al
 6d0:	74 0e                	je     6e0 <gets+0x5f>
  for(i=0; i+1 < max; ){
 6d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d5:	83 c0 01             	add    $0x1,%eax
 6d8:	39 45 0c             	cmp    %eax,0xc(%ebp)
 6db:	7f b3                	jg     690 <gets+0xf>
 6dd:	eb 01                	jmp    6e0 <gets+0x5f>
      break;
 6df:	90                   	nop
      break;
  }
  buf[i] = '\0';
 6e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
 6e3:	8b 45 08             	mov    0x8(%ebp),%eax
 6e6:	01 d0                	add    %edx,%eax
 6e8:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 6eb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6ee:	c9                   	leave
 6ef:	c3                   	ret

000006f0 <stat>:

int
stat(char *n, struct stat *st)
{
 6f0:	55                   	push   %ebp
 6f1:	89 e5                	mov    %esp,%ebp
 6f3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6f6:	83 ec 08             	sub    $0x8,%esp
 6f9:	6a 00                	push   $0x0
 6fb:	ff 75 08             	push   0x8(%ebp)
 6fe:	e8 0c 01 00 00       	call   80f <open>
 703:	83 c4 10             	add    $0x10,%esp
 706:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 709:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 70d:	79 07                	jns    716 <stat+0x26>
    return -1;
 70f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 714:	eb 25                	jmp    73b <stat+0x4b>
  r = fstat(fd, st);
 716:	83 ec 08             	sub    $0x8,%esp
 719:	ff 75 0c             	push   0xc(%ebp)
 71c:	ff 75 f4             	push   -0xc(%ebp)
 71f:	e8 03 01 00 00       	call   827 <fstat>
 724:	83 c4 10             	add    $0x10,%esp
 727:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 72a:	83 ec 0c             	sub    $0xc,%esp
 72d:	ff 75 f4             	push   -0xc(%ebp)
 730:	e8 c2 00 00 00       	call   7f7 <close>
 735:	83 c4 10             	add    $0x10,%esp
  return r;
 738:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 73b:	c9                   	leave
 73c:	c3                   	ret

0000073d <atoi>:

int
atoi(const char *s)
{
 73d:	55                   	push   %ebp
 73e:	89 e5                	mov    %esp,%ebp
 740:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 743:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 74a:	eb 25                	jmp    771 <atoi+0x34>
    n = n*10 + *s++ - '0';
 74c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 74f:	89 d0                	mov    %edx,%eax
 751:	c1 e0 02             	shl    $0x2,%eax
 754:	01 d0                	add    %edx,%eax
 756:	01 c0                	add    %eax,%eax
 758:	89 c1                	mov    %eax,%ecx
 75a:	8b 45 08             	mov    0x8(%ebp),%eax
 75d:	8d 50 01             	lea    0x1(%eax),%edx
 760:	89 55 08             	mov    %edx,0x8(%ebp)
 763:	0f b6 00             	movzbl (%eax),%eax
 766:	0f be c0             	movsbl %al,%eax
 769:	01 c8                	add    %ecx,%eax
 76b:	83 e8 30             	sub    $0x30,%eax
 76e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 771:	8b 45 08             	mov    0x8(%ebp),%eax
 774:	0f b6 00             	movzbl (%eax),%eax
 777:	3c 2f                	cmp    $0x2f,%al
 779:	7e 0a                	jle    785 <atoi+0x48>
 77b:	8b 45 08             	mov    0x8(%ebp),%eax
 77e:	0f b6 00             	movzbl (%eax),%eax
 781:	3c 39                	cmp    $0x39,%al
 783:	7e c7                	jle    74c <atoi+0xf>
  return n;
 785:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 788:	c9                   	leave
 789:	c3                   	ret

0000078a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 78a:	55                   	push   %ebp
 78b:	89 e5                	mov    %esp,%ebp
 78d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 790:	8b 45 08             	mov    0x8(%ebp),%eax
 793:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 796:	8b 45 0c             	mov    0xc(%ebp),%eax
 799:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 79c:	eb 17                	jmp    7b5 <memmove+0x2b>
    *dst++ = *src++;
 79e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7a1:	8d 42 01             	lea    0x1(%edx),%eax
 7a4:	89 45 f8             	mov    %eax,-0x8(%ebp)
 7a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7aa:	8d 48 01             	lea    0x1(%eax),%ecx
 7ad:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 7b0:	0f b6 12             	movzbl (%edx),%edx
 7b3:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 7b5:	8b 45 10             	mov    0x10(%ebp),%eax
 7b8:	8d 50 ff             	lea    -0x1(%eax),%edx
 7bb:	89 55 10             	mov    %edx,0x10(%ebp)
 7be:	85 c0                	test   %eax,%eax
 7c0:	7f dc                	jg     79e <memmove+0x14>
  return vdst;
 7c2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 7c5:	c9                   	leave
 7c6:	c3                   	ret

000007c7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 7c7:	b8 01 00 00 00       	mov    $0x1,%eax
 7cc:	cd 40                	int    $0x40
 7ce:	c3                   	ret

000007cf <exit>:
SYSCALL(exit)
 7cf:	b8 02 00 00 00       	mov    $0x2,%eax
 7d4:	cd 40                	int    $0x40
 7d6:	c3                   	ret

000007d7 <wait>:
SYSCALL(wait)
 7d7:	b8 03 00 00 00       	mov    $0x3,%eax
 7dc:	cd 40                	int    $0x40
 7de:	c3                   	ret

000007df <pipe>:
SYSCALL(pipe)
 7df:	b8 04 00 00 00       	mov    $0x4,%eax
 7e4:	cd 40                	int    $0x40
 7e6:	c3                   	ret

000007e7 <read>:
SYSCALL(read)
 7e7:	b8 05 00 00 00       	mov    $0x5,%eax
 7ec:	cd 40                	int    $0x40
 7ee:	c3                   	ret

000007ef <write>:
SYSCALL(write)
 7ef:	b8 10 00 00 00       	mov    $0x10,%eax
 7f4:	cd 40                	int    $0x40
 7f6:	c3                   	ret

000007f7 <close>:
SYSCALL(close)
 7f7:	b8 15 00 00 00       	mov    $0x15,%eax
 7fc:	cd 40                	int    $0x40
 7fe:	c3                   	ret

000007ff <kill>:
SYSCALL(kill)
 7ff:	b8 06 00 00 00       	mov    $0x6,%eax
 804:	cd 40                	int    $0x40
 806:	c3                   	ret

00000807 <exec>:
SYSCALL(exec)
 807:	b8 07 00 00 00       	mov    $0x7,%eax
 80c:	cd 40                	int    $0x40
 80e:	c3                   	ret

0000080f <open>:
SYSCALL(open)
 80f:	b8 0f 00 00 00       	mov    $0xf,%eax
 814:	cd 40                	int    $0x40
 816:	c3                   	ret

00000817 <mknod>:
SYSCALL(mknod)
 817:	b8 11 00 00 00       	mov    $0x11,%eax
 81c:	cd 40                	int    $0x40
 81e:	c3                   	ret

0000081f <unlink>:
SYSCALL(unlink)
 81f:	b8 12 00 00 00       	mov    $0x12,%eax
 824:	cd 40                	int    $0x40
 826:	c3                   	ret

00000827 <fstat>:
SYSCALL(fstat)
 827:	b8 08 00 00 00       	mov    $0x8,%eax
 82c:	cd 40                	int    $0x40
 82e:	c3                   	ret

0000082f <link>:
SYSCALL(link)
 82f:	b8 13 00 00 00       	mov    $0x13,%eax
 834:	cd 40                	int    $0x40
 836:	c3                   	ret

00000837 <mkdir>:
SYSCALL(mkdir)
 837:	b8 14 00 00 00       	mov    $0x14,%eax
 83c:	cd 40                	int    $0x40
 83e:	c3                   	ret

0000083f <chdir>:
SYSCALL(chdir)
 83f:	b8 09 00 00 00       	mov    $0x9,%eax
 844:	cd 40                	int    $0x40
 846:	c3                   	ret

00000847 <dup>:
SYSCALL(dup)
 847:	b8 0a 00 00 00       	mov    $0xa,%eax
 84c:	cd 40                	int    $0x40
 84e:	c3                   	ret

0000084f <getpid>:
SYSCALL(getpid)
 84f:	b8 0b 00 00 00       	mov    $0xb,%eax
 854:	cd 40                	int    $0x40
 856:	c3                   	ret

00000857 <sbrk>:
SYSCALL(sbrk)
 857:	b8 0c 00 00 00       	mov    $0xc,%eax
 85c:	cd 40                	int    $0x40
 85e:	c3                   	ret

0000085f <sleep>:
SYSCALL(sleep)
 85f:	b8 0d 00 00 00       	mov    $0xd,%eax
 864:	cd 40                	int    $0x40
 866:	c3                   	ret

00000867 <uptime>:
SYSCALL(uptime)
 867:	b8 0e 00 00 00       	mov    $0xe,%eax
 86c:	cd 40                	int    $0x40
 86e:	c3                   	ret

0000086f <uthread_init>:
SYSCALL(uthread_init)
 86f:	b8 16 00 00 00       	mov    $0x16,%eax
 874:	cd 40                	int    $0x40
 876:	c3                   	ret

00000877 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 877:	55                   	push   %ebp
 878:	89 e5                	mov    %esp,%ebp
 87a:	83 ec 18             	sub    $0x18,%esp
 87d:	8b 45 0c             	mov    0xc(%ebp),%eax
 880:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 883:	83 ec 04             	sub    $0x4,%esp
 886:	6a 01                	push   $0x1
 888:	8d 45 f4             	lea    -0xc(%ebp),%eax
 88b:	50                   	push   %eax
 88c:	ff 75 08             	push   0x8(%ebp)
 88f:	e8 5b ff ff ff       	call   7ef <write>
 894:	83 c4 10             	add    $0x10,%esp
}
 897:	90                   	nop
 898:	c9                   	leave
 899:	c3                   	ret

0000089a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 89a:	55                   	push   %ebp
 89b:	89 e5                	mov    %esp,%ebp
 89d:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 8a0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 8a7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 8ab:	74 17                	je     8c4 <printint+0x2a>
 8ad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 8b1:	79 11                	jns    8c4 <printint+0x2a>
    neg = 1;
 8b3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 8ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 8bd:	f7 d8                	neg    %eax
 8bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8c2:	eb 06                	jmp    8ca <printint+0x30>
  } else {
    x = xx;
 8c4:	8b 45 0c             	mov    0xc(%ebp),%eax
 8c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 8ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 8d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
 8d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8d7:	ba 00 00 00 00       	mov    $0x0,%edx
 8dc:	f7 f1                	div    %ecx
 8de:	89 d1                	mov    %edx,%ecx
 8e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e3:	8d 50 01             	lea    0x1(%eax),%edx
 8e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8e9:	0f b6 91 98 0f 00 00 	movzbl 0xf98(%ecx),%edx
 8f0:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 8f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
 8f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8fa:	ba 00 00 00 00       	mov    $0x0,%edx
 8ff:	f7 f1                	div    %ecx
 901:	89 45 ec             	mov    %eax,-0x14(%ebp)
 904:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 908:	75 c7                	jne    8d1 <printint+0x37>
  if(neg)
 90a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 90e:	74 2d                	je     93d <printint+0xa3>
    buf[i++] = '-';
 910:	8b 45 f4             	mov    -0xc(%ebp),%eax
 913:	8d 50 01             	lea    0x1(%eax),%edx
 916:	89 55 f4             	mov    %edx,-0xc(%ebp)
 919:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 91e:	eb 1d                	jmp    93d <printint+0xa3>
    putc(fd, buf[i]);
 920:	8d 55 dc             	lea    -0x24(%ebp),%edx
 923:	8b 45 f4             	mov    -0xc(%ebp),%eax
 926:	01 d0                	add    %edx,%eax
 928:	0f b6 00             	movzbl (%eax),%eax
 92b:	0f be c0             	movsbl %al,%eax
 92e:	83 ec 08             	sub    $0x8,%esp
 931:	50                   	push   %eax
 932:	ff 75 08             	push   0x8(%ebp)
 935:	e8 3d ff ff ff       	call   877 <putc>
 93a:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 93d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 941:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 945:	79 d9                	jns    920 <printint+0x86>
}
 947:	90                   	nop
 948:	90                   	nop
 949:	c9                   	leave
 94a:	c3                   	ret

0000094b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 94b:	55                   	push   %ebp
 94c:	89 e5                	mov    %esp,%ebp
 94e:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 951:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 958:	8d 45 0c             	lea    0xc(%ebp),%eax
 95b:	83 c0 04             	add    $0x4,%eax
 95e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 961:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 968:	e9 59 01 00 00       	jmp    ac6 <printf+0x17b>
    c = fmt[i] & 0xff;
 96d:	8b 55 0c             	mov    0xc(%ebp),%edx
 970:	8b 45 f0             	mov    -0x10(%ebp),%eax
 973:	01 d0                	add    %edx,%eax
 975:	0f b6 00             	movzbl (%eax),%eax
 978:	0f be c0             	movsbl %al,%eax
 97b:	25 ff 00 00 00       	and    $0xff,%eax
 980:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 983:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 987:	75 2c                	jne    9b5 <printf+0x6a>
      if(c == '%'){
 989:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 98d:	75 0c                	jne    99b <printf+0x50>
        state = '%';
 98f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 996:	e9 27 01 00 00       	jmp    ac2 <printf+0x177>
      } else {
        putc(fd, c);
 99b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 99e:	0f be c0             	movsbl %al,%eax
 9a1:	83 ec 08             	sub    $0x8,%esp
 9a4:	50                   	push   %eax
 9a5:	ff 75 08             	push   0x8(%ebp)
 9a8:	e8 ca fe ff ff       	call   877 <putc>
 9ad:	83 c4 10             	add    $0x10,%esp
 9b0:	e9 0d 01 00 00       	jmp    ac2 <printf+0x177>
      }
    } else if(state == '%'){
 9b5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 9b9:	0f 85 03 01 00 00    	jne    ac2 <printf+0x177>
      if(c == 'd'){
 9bf:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 9c3:	75 1e                	jne    9e3 <printf+0x98>
        printint(fd, *ap, 10, 1);
 9c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9c8:	8b 00                	mov    (%eax),%eax
 9ca:	6a 01                	push   $0x1
 9cc:	6a 0a                	push   $0xa
 9ce:	50                   	push   %eax
 9cf:	ff 75 08             	push   0x8(%ebp)
 9d2:	e8 c3 fe ff ff       	call   89a <printint>
 9d7:	83 c4 10             	add    $0x10,%esp
        ap++;
 9da:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9de:	e9 d8 00 00 00       	jmp    abb <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 9e3:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 9e7:	74 06                	je     9ef <printf+0xa4>
 9e9:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 9ed:	75 1e                	jne    a0d <printf+0xc2>
        printint(fd, *ap, 16, 0);
 9ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9f2:	8b 00                	mov    (%eax),%eax
 9f4:	6a 00                	push   $0x0
 9f6:	6a 10                	push   $0x10
 9f8:	50                   	push   %eax
 9f9:	ff 75 08             	push   0x8(%ebp)
 9fc:	e8 99 fe ff ff       	call   89a <printint>
 a01:	83 c4 10             	add    $0x10,%esp
        ap++;
 a04:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a08:	e9 ae 00 00 00       	jmp    abb <printf+0x170>
      } else if(c == 's'){
 a0d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 a11:	75 43                	jne    a56 <printf+0x10b>
        s = (char*)*ap;
 a13:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a16:	8b 00                	mov    (%eax),%eax
 a18:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 a1b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 a1f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a23:	75 25                	jne    a4a <printf+0xff>
          s = "(null)";
 a25:	c7 45 f4 91 0f 00 00 	movl   $0xf91,-0xc(%ebp)
        while(*s != 0){
 a2c:	eb 1c                	jmp    a4a <printf+0xff>
          putc(fd, *s);
 a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a31:	0f b6 00             	movzbl (%eax),%eax
 a34:	0f be c0             	movsbl %al,%eax
 a37:	83 ec 08             	sub    $0x8,%esp
 a3a:	50                   	push   %eax
 a3b:	ff 75 08             	push   0x8(%ebp)
 a3e:	e8 34 fe ff ff       	call   877 <putc>
 a43:	83 c4 10             	add    $0x10,%esp
          s++;
 a46:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4d:	0f b6 00             	movzbl (%eax),%eax
 a50:	84 c0                	test   %al,%al
 a52:	75 da                	jne    a2e <printf+0xe3>
 a54:	eb 65                	jmp    abb <printf+0x170>
        }
      } else if(c == 'c'){
 a56:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a5a:	75 1d                	jne    a79 <printf+0x12e>
        putc(fd, *ap);
 a5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a5f:	8b 00                	mov    (%eax),%eax
 a61:	0f be c0             	movsbl %al,%eax
 a64:	83 ec 08             	sub    $0x8,%esp
 a67:	50                   	push   %eax
 a68:	ff 75 08             	push   0x8(%ebp)
 a6b:	e8 07 fe ff ff       	call   877 <putc>
 a70:	83 c4 10             	add    $0x10,%esp
        ap++;
 a73:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a77:	eb 42                	jmp    abb <printf+0x170>
      } else if(c == '%'){
 a79:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a7d:	75 17                	jne    a96 <printf+0x14b>
        putc(fd, c);
 a7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a82:	0f be c0             	movsbl %al,%eax
 a85:	83 ec 08             	sub    $0x8,%esp
 a88:	50                   	push   %eax
 a89:	ff 75 08             	push   0x8(%ebp)
 a8c:	e8 e6 fd ff ff       	call   877 <putc>
 a91:	83 c4 10             	add    $0x10,%esp
 a94:	eb 25                	jmp    abb <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a96:	83 ec 08             	sub    $0x8,%esp
 a99:	6a 25                	push   $0x25
 a9b:	ff 75 08             	push   0x8(%ebp)
 a9e:	e8 d4 fd ff ff       	call   877 <putc>
 aa3:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 aa6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 aa9:	0f be c0             	movsbl %al,%eax
 aac:	83 ec 08             	sub    $0x8,%esp
 aaf:	50                   	push   %eax
 ab0:	ff 75 08             	push   0x8(%ebp)
 ab3:	e8 bf fd ff ff       	call   877 <putc>
 ab8:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 abb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 ac2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 ac6:	8b 55 0c             	mov    0xc(%ebp),%edx
 ac9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 acc:	01 d0                	add    %edx,%eax
 ace:	0f b6 00             	movzbl (%eax),%eax
 ad1:	84 c0                	test   %al,%al
 ad3:	0f 85 94 fe ff ff    	jne    96d <printf+0x22>
    }
  }
}
 ad9:	90                   	nop
 ada:	90                   	nop
 adb:	c9                   	leave
 adc:	c3                   	ret

00000add <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 add:	55                   	push   %ebp
 ade:	89 e5                	mov    %esp,%ebp
 ae0:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ae3:	8b 45 08             	mov    0x8(%ebp),%eax
 ae6:	83 e8 08             	sub    $0x8,%eax
 ae9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 aec:	a1 88 50 01 00       	mov    0x15088,%eax
 af1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 af4:	eb 24                	jmp    b1a <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 af6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af9:	8b 00                	mov    (%eax),%eax
 afb:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 afe:	72 12                	jb     b12 <free+0x35>
 b00:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b03:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 b06:	72 24                	jb     b2c <free+0x4f>
 b08:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b0b:	8b 00                	mov    (%eax),%eax
 b0d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b10:	72 1a                	jb     b2c <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b12:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b15:	8b 00                	mov    (%eax),%eax
 b17:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b1a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b1d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 b20:	73 d4                	jae    af6 <free+0x19>
 b22:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b25:	8b 00                	mov    (%eax),%eax
 b27:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b2a:	73 ca                	jae    af6 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 b2c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b2f:	8b 40 04             	mov    0x4(%eax),%eax
 b32:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b39:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b3c:	01 c2                	add    %eax,%edx
 b3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b41:	8b 00                	mov    (%eax),%eax
 b43:	39 c2                	cmp    %eax,%edx
 b45:	75 24                	jne    b6b <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 b47:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b4a:	8b 50 04             	mov    0x4(%eax),%edx
 b4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b50:	8b 00                	mov    (%eax),%eax
 b52:	8b 40 04             	mov    0x4(%eax),%eax
 b55:	01 c2                	add    %eax,%edx
 b57:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b5a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b60:	8b 00                	mov    (%eax),%eax
 b62:	8b 10                	mov    (%eax),%edx
 b64:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b67:	89 10                	mov    %edx,(%eax)
 b69:	eb 0a                	jmp    b75 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 b6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b6e:	8b 10                	mov    (%eax),%edx
 b70:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b73:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b75:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b78:	8b 40 04             	mov    0x4(%eax),%eax
 b7b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b82:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b85:	01 d0                	add    %edx,%eax
 b87:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b8a:	75 20                	jne    bac <free+0xcf>
    p->s.size += bp->s.size;
 b8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b8f:	8b 50 04             	mov    0x4(%eax),%edx
 b92:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b95:	8b 40 04             	mov    0x4(%eax),%eax
 b98:	01 c2                	add    %eax,%edx
 b9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b9d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 ba0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ba3:	8b 10                	mov    (%eax),%edx
 ba5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ba8:	89 10                	mov    %edx,(%eax)
 baa:	eb 08                	jmp    bb4 <free+0xd7>
  } else
    p->s.ptr = bp;
 bac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 baf:	8b 55 f8             	mov    -0x8(%ebp),%edx
 bb2:	89 10                	mov    %edx,(%eax)
  freep = p;
 bb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bb7:	a3 88 50 01 00       	mov    %eax,0x15088
}
 bbc:	90                   	nop
 bbd:	c9                   	leave
 bbe:	c3                   	ret

00000bbf <morecore>:

static Header*
morecore(uint nu)
{
 bbf:	55                   	push   %ebp
 bc0:	89 e5                	mov    %esp,%ebp
 bc2:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 bc5:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 bcc:	77 07                	ja     bd5 <morecore+0x16>
    nu = 4096;
 bce:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 bd5:	8b 45 08             	mov    0x8(%ebp),%eax
 bd8:	c1 e0 03             	shl    $0x3,%eax
 bdb:	83 ec 0c             	sub    $0xc,%esp
 bde:	50                   	push   %eax
 bdf:	e8 73 fc ff ff       	call   857 <sbrk>
 be4:	83 c4 10             	add    $0x10,%esp
 be7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 bea:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 bee:	75 07                	jne    bf7 <morecore+0x38>
    return 0;
 bf0:	b8 00 00 00 00       	mov    $0x0,%eax
 bf5:	eb 26                	jmp    c1d <morecore+0x5e>
  hp = (Header*)p;
 bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 bfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c00:	8b 55 08             	mov    0x8(%ebp),%edx
 c03:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c09:	83 c0 08             	add    $0x8,%eax
 c0c:	83 ec 0c             	sub    $0xc,%esp
 c0f:	50                   	push   %eax
 c10:	e8 c8 fe ff ff       	call   add <free>
 c15:	83 c4 10             	add    $0x10,%esp
  return freep;
 c18:	a1 88 50 01 00       	mov    0x15088,%eax
}
 c1d:	c9                   	leave
 c1e:	c3                   	ret

00000c1f <malloc>:

void*
malloc(uint nbytes)
{
 c1f:	55                   	push   %ebp
 c20:	89 e5                	mov    %esp,%ebp
 c22:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c25:	8b 45 08             	mov    0x8(%ebp),%eax
 c28:	83 c0 07             	add    $0x7,%eax
 c2b:	c1 e8 03             	shr    $0x3,%eax
 c2e:	83 c0 01             	add    $0x1,%eax
 c31:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 c34:	a1 88 50 01 00       	mov    0x15088,%eax
 c39:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c3c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c40:	75 23                	jne    c65 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 c42:	c7 45 f0 80 50 01 00 	movl   $0x15080,-0x10(%ebp)
 c49:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c4c:	a3 88 50 01 00       	mov    %eax,0x15088
 c51:	a1 88 50 01 00       	mov    0x15088,%eax
 c56:	a3 80 50 01 00       	mov    %eax,0x15080
    base.s.size = 0;
 c5b:	c7 05 84 50 01 00 00 	movl   $0x0,0x15084
 c62:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c65:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c68:	8b 00                	mov    (%eax),%eax
 c6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c70:	8b 40 04             	mov    0x4(%eax),%eax
 c73:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c76:	72 4d                	jb     cc5 <malloc+0xa6>
      if(p->s.size == nunits)
 c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c7b:	8b 40 04             	mov    0x4(%eax),%eax
 c7e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 c81:	75 0c                	jne    c8f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c86:	8b 10                	mov    (%eax),%edx
 c88:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c8b:	89 10                	mov    %edx,(%eax)
 c8d:	eb 26                	jmp    cb5 <malloc+0x96>
      else {
        p->s.size -= nunits;
 c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c92:	8b 40 04             	mov    0x4(%eax),%eax
 c95:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c98:	89 c2                	mov    %eax,%edx
 c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c9d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ca3:	8b 40 04             	mov    0x4(%eax),%eax
 ca6:	c1 e0 03             	shl    $0x3,%eax
 ca9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 caf:	8b 55 ec             	mov    -0x14(%ebp),%edx
 cb2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cb8:	a3 88 50 01 00       	mov    %eax,0x15088
      return (void*)(p + 1);
 cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cc0:	83 c0 08             	add    $0x8,%eax
 cc3:	eb 3b                	jmp    d00 <malloc+0xe1>
    }
    if(p == freep)
 cc5:	a1 88 50 01 00       	mov    0x15088,%eax
 cca:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ccd:	75 1e                	jne    ced <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 ccf:	83 ec 0c             	sub    $0xc,%esp
 cd2:	ff 75 ec             	push   -0x14(%ebp)
 cd5:	e8 e5 fe ff ff       	call   bbf <morecore>
 cda:	83 c4 10             	add    $0x10,%esp
 cdd:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ce0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ce4:	75 07                	jne    ced <malloc+0xce>
        return 0;
 ce6:	b8 00 00 00 00       	mov    $0x0,%eax
 ceb:	eb 13                	jmp    d00 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cf6:	8b 00                	mov    (%eax),%eax
 cf8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 cfb:	e9 6d ff ff ff       	jmp    c6d <malloc+0x4e>
  }
}
 d00:	c9                   	leave
 d01:	c3                   	ret
