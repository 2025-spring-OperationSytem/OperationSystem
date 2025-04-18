
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
   6:	c7 05 24 0d 00 00 00 	movl   $0x0,0xd24
   d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 40 0d 00 00 	movl   $0xd40,-0xc(%ebp)
  17:	eb 41                	jmp    5a <thread_schedule+0x5a>
    //printf(1,"t: %x, state %x \n", t, t->state);
    if(t == &all_thread[0] && t->state == RUNNABLE){
  19:	81 7d f4 40 0d 00 00 	cmpl   $0xd40,-0xc(%ebp)
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
  3e:	a1 20 0d 00 00       	mov    0xd20,%eax
  43:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  46:	74 0b                	je     53 <thread_schedule+0x53>
      next_thread = t;
  48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4b:	a3 24 0d 00 00       	mov    %eax,0xd24
      break;
  50:	eb 12                	jmp    64 <thread_schedule+0x64>
      continue;
  52:	90                   	nop
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  53:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  5a:	b8 90 4d 01 00       	mov    $0x14d90,%eax
  5f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  62:	72 b5                	jb     19 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  64:	b8 90 4d 01 00       	mov    $0x14d90,%eax
  69:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  6c:	72 1a                	jb     88 <thread_schedule+0x88>
  6e:	a1 20 0d 00 00       	mov    0xd20,%eax
  73:	8b 80 fc 1f 00 00    	mov    0x1ffc(%eax),%eax
  79:	83 f8 02             	cmp    $0x2,%eax
  7c:	75 0a                	jne    88 <thread_schedule+0x88>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  7e:	a1 20 0d 00 00       	mov    0xd20,%eax
  83:	a3 24 0d 00 00       	mov    %eax,0xd24
  }

  if (next_thread == 0) {
  88:	a1 24 0d 00 00       	mov    0xd24,%eax
  8d:	85 c0                	test   %eax,%eax
  8f:	75 17                	jne    a8 <thread_schedule+0xa8>
    printf(2, "thread_schedule: no runnable threads\n");
  91:	83 ec 08             	sub    $0x8,%esp
  94:	68 b8 0b 00 00       	push   $0xbb8
  99:	6a 02                	push   $0x2
  9b:	e8 61 07 00 00       	call   801 <printf>
  a0:	83 c4 10             	add    $0x10,%esp
    exit();
  a3:	e8 dd 05 00 00       	call   685 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  a8:	8b 15 20 0d 00 00    	mov    0xd20,%edx
  ae:	a1 24 0d 00 00       	mov    0xd24,%eax
  b3:	39 c2                	cmp    %eax,%edx
  b5:	74 25                	je     dc <thread_schedule+0xdc>
    next_thread->state = RUNNING;
  b7:	a1 24 0d 00 00       	mov    0xd24,%eax
  bc:	c7 80 fc 1f 00 00 01 	movl   $0x1,0x1ffc(%eax)
  c3:	00 00 00 
    current_thread->state = RUNNABLE;
  c6:	a1 20 0d 00 00       	mov    0xd20,%eax
  cb:	c7 80 fc 1f 00 00 02 	movl   $0x2,0x1ffc(%eax)
  d2:	00 00 00 
    thread_switch();
  d5:	e8 34 03 00 00       	call   40e <thread_switch>
  } else
    next_thread = 0;
}
  da:	eb 0a                	jmp    e6 <thread_schedule+0xe6>
    next_thread = 0;
  dc:	c7 05 24 0d 00 00 00 	movl   $0x0,0xd24
  e3:	00 00 00 
}
  e6:	90                   	nop
  e7:	c9                   	leave
  e8:	c3                   	ret

000000e9 <thread_init>:

void 
thread_init(void)
{
  e9:	55                   	push   %ebp
  ea:	89 e5                	mov    %esp,%ebp
  ec:	83 ec 08             	sub    $0x8,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  ef:	c7 05 20 0d 00 00 40 	movl   $0xd40,0xd20
  f6:	0d 00 00 
  current_thread->state = RUNNING;
  f9:	a1 20 0d 00 00       	mov    0xd20,%eax
  fe:	c7 80 fc 1f 00 00 01 	movl   $0x1,0x1ffc(%eax)
 105:	00 00 00 
  current_thread->tid=0;
 108:	a1 20 0d 00 00       	mov    0xd20,%eax
 10d:	c7 80 00 20 00 00 00 	movl   $0x0,0x2000(%eax)
 114:	00 00 00 
  current_thread->ptid=0;
 117:	a1 20 0d 00 00       	mov    0xd20,%eax
 11c:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 123:	00 00 00 

  uthread_init((int)thread_schedule);
 126:	b8 00 00 00 00       	mov    $0x0,%eax
 12b:	83 ec 0c             	sub    $0xc,%esp
 12e:	50                   	push   %eax
 12f:	e8 f1 05 00 00       	call   725 <uthread_init>
 134:	83 c4 10             	add    $0x10,%esp
}
 137:	90                   	nop
 138:	c9                   	leave
 139:	c3                   	ret

0000013a <thread_create>:

void 
thread_create(void (*func)())
{
 13a:	55                   	push   %ebp
 13b:	89 e5                	mov    %esp,%ebp
 13d:	83 ec 18             	sub    $0x18,%esp
  printf(1,"thread_create\n");
 140:	83 ec 08             	sub    $0x8,%esp
 143:	68 de 0b 00 00       	push   $0xbde
 148:	6a 01                	push   $0x1
 14a:	e8 b2 06 00 00       	call   801 <printf>
 14f:	83 c4 10             	add    $0x10,%esp
  printf(1, "[create] func address = 0x%x\n", func);
 152:	83 ec 04             	sub    $0x4,%esp
 155:	ff 75 08             	push   0x8(%ebp)
 158:	68 ed 0b 00 00       	push   $0xbed
 15d:	6a 01                	push   $0x1
 15f:	e8 9d 06 00 00       	call   801 <printf>
 164:	83 c4 10             	add    $0x10,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 167:	c7 45 f4 40 0d 00 00 	movl   $0xd40,-0xc(%ebp)
 16e:	eb 14                	jmp    184 <thread_create+0x4a>
    if (t->state == FREE) break;
 170:	8b 45 f4             	mov    -0xc(%ebp),%eax
 173:	8b 80 fc 1f 00 00    	mov    0x1ffc(%eax),%eax
 179:	85 c0                	test   %eax,%eax
 17b:	74 13                	je     190 <thread_create+0x56>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 17d:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 184:	b8 90 4d 01 00       	mov    $0x14d90,%eax
 189:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 18c:	72 e2                	jb     170 <thread_create+0x36>
 18e:	eb 01                	jmp    191 <thread_create+0x57>
    if (t->state == FREE) break;
 190:	90                   	nop
  }

  t->sp = (int)(t->stack + STACK_SIZE);
 191:	8b 45 f4             	mov    -0xc(%ebp),%eax
 194:	05 f8 1f 00 00       	add    $0x1ff8,%eax
 199:	89 c2                	mov    %eax,%edx
 19b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 19e:	89 90 f8 1f 00 00    	mov    %edx,0x1ff8(%eax)

  t->sp -= 4;
 1a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a7:	8b 80 f8 1f 00 00    	mov    0x1ff8(%eax),%eax
 1ad:	8d 50 fc             	lea    -0x4(%eax),%edx
 1b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b3:	89 90 f8 1f 00 00    	mov    %edx,0x1ff8(%eax)
  *(int *)(t->sp) = (int)func;  // 올바른 ret 주소 설정
 1b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1bc:	8b 80 f8 1f 00 00    	mov    0x1ff8(%eax),%eax
 1c2:	89 c2                	mov    %eax,%edx
 1c4:	8b 45 08             	mov    0x8(%ebp),%eax
 1c7:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                  // context는 그 아래
 1c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cc:	8b 80 f8 1f 00 00    	mov    0x1ff8(%eax),%eax
 1d2:	8d 50 e0             	lea    -0x20(%eax),%edx
 1d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d8:	89 90 f8 1f 00 00    	mov    %edx,0x1ff8(%eax)

  t->tid = t - all_thread;
 1de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e1:	2d 40 0d 00 00       	sub    $0xd40,%eax
 1e6:	c1 f8 03             	sar    $0x3,%eax
 1e9:	69 c0 01 fc 0f c0    	imul   $0xc00ffc01,%eax,%eax
 1ef:	89 c2                	mov    %eax,%edx
 1f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f4:	89 90 00 20 00 00    	mov    %edx,0x2000(%eax)
  t->ptid = current_thread->tid;
 1fa:	a1 20 0d 00 00       	mov    0xd20,%eax
 1ff:	8b 90 00 20 00 00    	mov    0x2000(%eax),%edx
 205:	8b 45 f4             	mov    -0xc(%ebp),%eax
 208:	89 90 04 20 00 00    	mov    %edx,0x2004(%eax)
  t->state = RUNNABLE;
 20e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 211:	c7 80 fc 1f 00 00 02 	movl   $0x2,0x1ffc(%eax)
 218:	00 00 00 
}
 21b:	90                   	nop
 21c:	c9                   	leave
 21d:	c3                   	ret

0000021e <thread_join_all>:

static void thread_join_all(void) {
 21e:	55                   	push   %ebp
 21f:	89 e5                	mov    %esp,%ebp
 221:	83 ec 18             	sub    $0x18,%esp
  while (1) {
    int child_alive = 0;
 224:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    for (int i = 0; i < MAX_THREAD; i++) {
 22b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 232:	eb 40                	jmp    274 <thread_join_all+0x56>
      if (all_thread[i].state != FREE &&
 234:	8b 45 f0             	mov    -0x10(%ebp),%eax
 237:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
 23d:	05 3c 2d 00 00       	add    $0x2d3c,%eax
 242:	8b 00                	mov    (%eax),%eax
 244:	85 c0                	test   %eax,%eax
 246:	74 28                	je     270 <thread_join_all+0x52>
          all_thread[i].ptid == current_thread->tid) {
 248:	8b 45 f0             	mov    -0x10(%ebp),%eax
 24b:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
 251:	05 44 2d 00 00       	add    $0x2d44,%eax
 256:	8b 10                	mov    (%eax),%edx
 258:	a1 20 0d 00 00       	mov    0xd20,%eax
 25d:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
      if (all_thread[i].state != FREE &&
 263:	39 c2                	cmp    %eax,%edx
 265:	75 09                	jne    270 <thread_join_all+0x52>
        child_alive = 1;
 267:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        break;
 26e:	eb 0a                	jmp    27a <thread_join_all+0x5c>
    for (int i = 0; i < MAX_THREAD; i++) {
 270:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 274:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
 278:	7e ba                	jle    234 <thread_join_all+0x16>
      }
    }

    if (!child_alive)
 27a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 27e:	74 5c                	je     2dc <thread_join_all+0xbe>
      break;

    // 현재 RUNNABLE 스레드가 있는 경우에만 스케줄
    int has_runnable = 0;
 280:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    for (int i = 0; i < MAX_THREAD; i++) {
 287:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
 28e:	eb 22                	jmp    2b2 <thread_join_all+0x94>
      if (all_thread[i].state == RUNNABLE) {
 290:	8b 45 e8             	mov    -0x18(%ebp),%eax
 293:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
 299:	05 3c 2d 00 00       	add    $0x2d3c,%eax
 29e:	8b 00                	mov    (%eax),%eax
 2a0:	83 f8 02             	cmp    $0x2,%eax
 2a3:	75 09                	jne    2ae <thread_join_all+0x90>
        has_runnable = 1;
 2a5:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
        break;
 2ac:	eb 0a                	jmp    2b8 <thread_join_all+0x9a>
    for (int i = 0; i < MAX_THREAD; i++) {
 2ae:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
 2b2:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 2b6:	7e d8                	jle    290 <thread_join_all+0x72>
      }
    }

    if (!has_runnable) {
 2b8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 2bc:	75 14                	jne    2d2 <thread_join_all+0xb4>
      printf(1, "[join_all] No runnable threads left, exiting loop early\n");
 2be:	83 ec 08             	sub    $0x8,%esp
 2c1:	68 0c 0c 00 00       	push   $0xc0c
 2c6:	6a 01                	push   $0x1
 2c8:	e8 34 05 00 00       	call   801 <printf>
 2cd:	83 c4 10             	add    $0x10,%esp
      break;
 2d0:	eb 0b                	jmp    2dd <thread_join_all+0xbf>
    }

    thread_schedule();
 2d2:	e8 29 fd ff ff       	call   0 <thread_schedule>
  while (1) {
 2d7:	e9 48 ff ff ff       	jmp    224 <thread_join_all+0x6>
      break;
 2dc:	90                   	nop
  }
}
 2dd:	90                   	nop
 2de:	c9                   	leave
 2df:	c3                   	ret

000002e0 <child_thread>:

static void 
child_thread(void)
{
 2e0:	55                   	push   %ebp
 2e1:	89 e5                	mov    %esp,%ebp
 2e3:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "[child] started: tid=%d, ptid=%d\n", current_thread->tid, current_thread->ptid);
 2e6:	a1 20 0d 00 00       	mov    0xd20,%eax
 2eb:	8b 90 04 20 00 00    	mov    0x2004(%eax),%edx
 2f1:	a1 20 0d 00 00       	mov    0xd20,%eax
 2f6:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 2fc:	52                   	push   %edx
 2fd:	50                   	push   %eax
 2fe:	68 48 0c 00 00       	push   $0xc48
 303:	6a 01                	push   $0x1
 305:	e8 f7 04 00 00       	call   801 <printf>
 30a:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 10; i++) {
 30d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 314:	eb 1c                	jmp    332 <child_thread+0x52>
    printf(1, "[child] child thread 0x%x\n", (int) current_thread);
 316:	a1 20 0d 00 00       	mov    0xd20,%eax
 31b:	83 ec 04             	sub    $0x4,%esp
 31e:	50                   	push   %eax
 31f:	68 6a 0c 00 00       	push   $0xc6a
 324:	6a 01                	push   $0x1
 326:	e8 d6 04 00 00       	call   801 <printf>
 32b:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 10; i++) {
 32e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 332:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
 336:	7e de                	jle    316 <child_thread+0x36>
  }
  printf(1, "[child] child thread: exit\n");
 338:	83 ec 08             	sub    $0x8,%esp
 33b:	68 85 0c 00 00       	push   $0xc85
 340:	6a 01                	push   $0x1
 342:	e8 ba 04 00 00       	call   801 <printf>
 347:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 34a:	a1 20 0d 00 00       	mov    0xd20,%eax
 34f:	c7 80 fc 1f 00 00 00 	movl   $0x0,0x1ffc(%eax)
 356:	00 00 00 
}
 359:	90                   	nop
 35a:	c9                   	leave
 35b:	c3                   	ret

0000035c <mythread>:

static void 
mythread(void)
{
 35c:	55                   	push   %ebp
 35d:	89 e5                	mov    %esp,%ebp
 35f:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "[parent] mythread tid=%d creating children...\n", current_thread->tid);
 362:	a1 20 0d 00 00       	mov    0xd20,%eax
 367:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 36d:	83 ec 04             	sub    $0x4,%esp
 370:	50                   	push   %eax
 371:	68 a4 0c 00 00       	push   $0xca4
 376:	6a 01                	push   $0x1
 378:	e8 84 04 00 00       	call   801 <printf>
 37d:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 380:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 387:	eb 19                	jmp    3a2 <mythread+0x46>
    thread_create(child_thread);
 389:	83 ec 0c             	sub    $0xc,%esp
 38c:	68 e0 02 00 00       	push   $0x2e0
 391:	e8 a4 fd ff ff       	call   13a <thread_create>
 396:	83 c4 10             	add    $0x10,%esp
    thread_schedule();
 399:	e8 62 fc ff ff       	call   0 <thread_schedule>
  for (i = 0; i < 5; i++) {
 39e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3a2:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 3a6:	7e e1                	jle    389 <mythread+0x2d>
  }
  thread_join_all();
 3a8:	e8 71 fe ff ff       	call   21e <thread_join_all>
  printf(1, "[parent] mythread done\n");
 3ad:	83 ec 08             	sub    $0x8,%esp
 3b0:	68 d3 0c 00 00       	push   $0xcd3
 3b5:	6a 01                	push   $0x1
 3b7:	e8 45 04 00 00       	call   801 <printf>
 3bc:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 3bf:	a1 20 0d 00 00       	mov    0xd20,%eax
 3c4:	c7 80 fc 1f 00 00 00 	movl   $0x0,0x1ffc(%eax)
 3cb:	00 00 00 
  thread_schedule();
 3ce:	e8 2d fc ff ff       	call   0 <thread_schedule>
}
 3d3:	90                   	nop
 3d4:	c9                   	leave
 3d5:	c3                   	ret

000003d6 <main>:


int 
main(int argc, char *argv[]) 
{
 3d6:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 3da:	83 e4 f0             	and    $0xfffffff0,%esp
 3dd:	ff 71 fc             	push   -0x4(%ecx)
 3e0:	55                   	push   %ebp
 3e1:	89 e5                	mov    %esp,%ebp
 3e3:	51                   	push   %ecx
 3e4:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 3e7:	e8 fd fc ff ff       	call   e9 <thread_init>
  thread_create(mythread);
 3ec:	83 ec 0c             	sub    $0xc,%esp
 3ef:	68 5c 03 00 00       	push   $0x35c
 3f4:	e8 41 fd ff ff       	call   13a <thread_create>
 3f9:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 3fc:	e8 ff fb ff ff       	call   0 <thread_schedule>
  //thread_join_all();
  return 0;
 401:	b8 00 00 00 00       	mov    $0x0,%eax
 406:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 409:	c9                   	leave
 40a:	8d 61 fc             	lea    -0x4(%ecx),%esp
 40d:	c3                   	ret

0000040e <thread_switch>:
         */
    .text
    .globl thread_switch
thread_switch:

    pushal
 40e:	60                   	pusha

    movl current_thread, %eax
 40f:	a1 20 0d 00 00       	mov    0xd20,%eax
    movl %esp, (%eax)
 414:	89 20                	mov    %esp,(%eax)

    movl next_thread, %eax
 416:	a1 24 0d 00 00       	mov    0xd24,%eax
    movl (%eax), %esp
 41b:	8b 20                	mov    (%eax),%esp
    # esp = t1.주소

    movl %eax, current_thread
 41d:	a3 20 0d 00 00       	mov    %eax,0xd20

    // 레지스터 복구
    popal
 422:	61                   	popa

    movl $0, next_thread
 423:	c7 05 24 0d 00 00 00 	movl   $0x0,0xd24
 42a:	00 00 00 
    
 42d:	c3                   	ret

0000042e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 42e:	55                   	push   %ebp
 42f:	89 e5                	mov    %esp,%ebp
 431:	57                   	push   %edi
 432:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 433:	8b 4d 08             	mov    0x8(%ebp),%ecx
 436:	8b 55 10             	mov    0x10(%ebp),%edx
 439:	8b 45 0c             	mov    0xc(%ebp),%eax
 43c:	89 cb                	mov    %ecx,%ebx
 43e:	89 df                	mov    %ebx,%edi
 440:	89 d1                	mov    %edx,%ecx
 442:	fc                   	cld
 443:	f3 aa                	rep stos %al,%es:(%edi)
 445:	89 ca                	mov    %ecx,%edx
 447:	89 fb                	mov    %edi,%ebx
 449:	89 5d 08             	mov    %ebx,0x8(%ebp)
 44c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 44f:	90                   	nop
 450:	5b                   	pop    %ebx
 451:	5f                   	pop    %edi
 452:	5d                   	pop    %ebp
 453:	c3                   	ret

00000454 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 454:	55                   	push   %ebp
 455:	89 e5                	mov    %esp,%ebp
 457:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 45a:	8b 45 08             	mov    0x8(%ebp),%eax
 45d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 460:	90                   	nop
 461:	8b 55 0c             	mov    0xc(%ebp),%edx
 464:	8d 42 01             	lea    0x1(%edx),%eax
 467:	89 45 0c             	mov    %eax,0xc(%ebp)
 46a:	8b 45 08             	mov    0x8(%ebp),%eax
 46d:	8d 48 01             	lea    0x1(%eax),%ecx
 470:	89 4d 08             	mov    %ecx,0x8(%ebp)
 473:	0f b6 12             	movzbl (%edx),%edx
 476:	88 10                	mov    %dl,(%eax)
 478:	0f b6 00             	movzbl (%eax),%eax
 47b:	84 c0                	test   %al,%al
 47d:	75 e2                	jne    461 <strcpy+0xd>
    ;
  return os;
 47f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 482:	c9                   	leave
 483:	c3                   	ret

00000484 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 484:	55                   	push   %ebp
 485:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 487:	eb 08                	jmp    491 <strcmp+0xd>
    p++, q++;
 489:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 48d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 491:	8b 45 08             	mov    0x8(%ebp),%eax
 494:	0f b6 00             	movzbl (%eax),%eax
 497:	84 c0                	test   %al,%al
 499:	74 10                	je     4ab <strcmp+0x27>
 49b:	8b 45 08             	mov    0x8(%ebp),%eax
 49e:	0f b6 10             	movzbl (%eax),%edx
 4a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a4:	0f b6 00             	movzbl (%eax),%eax
 4a7:	38 c2                	cmp    %al,%dl
 4a9:	74 de                	je     489 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 4ab:	8b 45 08             	mov    0x8(%ebp),%eax
 4ae:	0f b6 00             	movzbl (%eax),%eax
 4b1:	0f b6 d0             	movzbl %al,%edx
 4b4:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b7:	0f b6 00             	movzbl (%eax),%eax
 4ba:	0f b6 c0             	movzbl %al,%eax
 4bd:	29 c2                	sub    %eax,%edx
 4bf:	89 d0                	mov    %edx,%eax
}
 4c1:	5d                   	pop    %ebp
 4c2:	c3                   	ret

000004c3 <strlen>:

uint
strlen(char *s)
{
 4c3:	55                   	push   %ebp
 4c4:	89 e5                	mov    %esp,%ebp
 4c6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 4c9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 4d0:	eb 04                	jmp    4d6 <strlen+0x13>
 4d2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 4d6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4d9:	8b 45 08             	mov    0x8(%ebp),%eax
 4dc:	01 d0                	add    %edx,%eax
 4de:	0f b6 00             	movzbl (%eax),%eax
 4e1:	84 c0                	test   %al,%al
 4e3:	75 ed                	jne    4d2 <strlen+0xf>
    ;
  return n;
 4e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4e8:	c9                   	leave
 4e9:	c3                   	ret

000004ea <memset>:

void*
memset(void *dst, int c, uint n)
{
 4ea:	55                   	push   %ebp
 4eb:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 4ed:	8b 45 10             	mov    0x10(%ebp),%eax
 4f0:	50                   	push   %eax
 4f1:	ff 75 0c             	push   0xc(%ebp)
 4f4:	ff 75 08             	push   0x8(%ebp)
 4f7:	e8 32 ff ff ff       	call   42e <stosb>
 4fc:	83 c4 0c             	add    $0xc,%esp
  return dst;
 4ff:	8b 45 08             	mov    0x8(%ebp),%eax
}
 502:	c9                   	leave
 503:	c3                   	ret

00000504 <strchr>:

char*
strchr(const char *s, char c)
{
 504:	55                   	push   %ebp
 505:	89 e5                	mov    %esp,%ebp
 507:	83 ec 04             	sub    $0x4,%esp
 50a:	8b 45 0c             	mov    0xc(%ebp),%eax
 50d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 510:	eb 14                	jmp    526 <strchr+0x22>
    if(*s == c)
 512:	8b 45 08             	mov    0x8(%ebp),%eax
 515:	0f b6 00             	movzbl (%eax),%eax
 518:	38 45 fc             	cmp    %al,-0x4(%ebp)
 51b:	75 05                	jne    522 <strchr+0x1e>
      return (char*)s;
 51d:	8b 45 08             	mov    0x8(%ebp),%eax
 520:	eb 13                	jmp    535 <strchr+0x31>
  for(; *s; s++)
 522:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 526:	8b 45 08             	mov    0x8(%ebp),%eax
 529:	0f b6 00             	movzbl (%eax),%eax
 52c:	84 c0                	test   %al,%al
 52e:	75 e2                	jne    512 <strchr+0xe>
  return 0;
 530:	b8 00 00 00 00       	mov    $0x0,%eax
}
 535:	c9                   	leave
 536:	c3                   	ret

00000537 <gets>:

char*
gets(char *buf, int max)
{
 537:	55                   	push   %ebp
 538:	89 e5                	mov    %esp,%ebp
 53a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 53d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 544:	eb 42                	jmp    588 <gets+0x51>
    cc = read(0, &c, 1);
 546:	83 ec 04             	sub    $0x4,%esp
 549:	6a 01                	push   $0x1
 54b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 54e:	50                   	push   %eax
 54f:	6a 00                	push   $0x0
 551:	e8 47 01 00 00       	call   69d <read>
 556:	83 c4 10             	add    $0x10,%esp
 559:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 55c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 560:	7e 33                	jle    595 <gets+0x5e>
      break;
    buf[i++] = c;
 562:	8b 45 f4             	mov    -0xc(%ebp),%eax
 565:	8d 50 01             	lea    0x1(%eax),%edx
 568:	89 55 f4             	mov    %edx,-0xc(%ebp)
 56b:	89 c2                	mov    %eax,%edx
 56d:	8b 45 08             	mov    0x8(%ebp),%eax
 570:	01 c2                	add    %eax,%edx
 572:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 576:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 578:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 57c:	3c 0a                	cmp    $0xa,%al
 57e:	74 16                	je     596 <gets+0x5f>
 580:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 584:	3c 0d                	cmp    $0xd,%al
 586:	74 0e                	je     596 <gets+0x5f>
  for(i=0; i+1 < max; ){
 588:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58b:	83 c0 01             	add    $0x1,%eax
 58e:	39 45 0c             	cmp    %eax,0xc(%ebp)
 591:	7f b3                	jg     546 <gets+0xf>
 593:	eb 01                	jmp    596 <gets+0x5f>
      break;
 595:	90                   	nop
      break;
  }
  buf[i] = '\0';
 596:	8b 55 f4             	mov    -0xc(%ebp),%edx
 599:	8b 45 08             	mov    0x8(%ebp),%eax
 59c:	01 d0                	add    %edx,%eax
 59e:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 5a1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5a4:	c9                   	leave
 5a5:	c3                   	ret

000005a6 <stat>:

int
stat(char *n, struct stat *st)
{
 5a6:	55                   	push   %ebp
 5a7:	89 e5                	mov    %esp,%ebp
 5a9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5ac:	83 ec 08             	sub    $0x8,%esp
 5af:	6a 00                	push   $0x0
 5b1:	ff 75 08             	push   0x8(%ebp)
 5b4:	e8 0c 01 00 00       	call   6c5 <open>
 5b9:	83 c4 10             	add    $0x10,%esp
 5bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 5bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5c3:	79 07                	jns    5cc <stat+0x26>
    return -1;
 5c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 5ca:	eb 25                	jmp    5f1 <stat+0x4b>
  r = fstat(fd, st);
 5cc:	83 ec 08             	sub    $0x8,%esp
 5cf:	ff 75 0c             	push   0xc(%ebp)
 5d2:	ff 75 f4             	push   -0xc(%ebp)
 5d5:	e8 03 01 00 00       	call   6dd <fstat>
 5da:	83 c4 10             	add    $0x10,%esp
 5dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 5e0:	83 ec 0c             	sub    $0xc,%esp
 5e3:	ff 75 f4             	push   -0xc(%ebp)
 5e6:	e8 c2 00 00 00       	call   6ad <close>
 5eb:	83 c4 10             	add    $0x10,%esp
  return r;
 5ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 5f1:	c9                   	leave
 5f2:	c3                   	ret

000005f3 <atoi>:

int
atoi(const char *s)
{
 5f3:	55                   	push   %ebp
 5f4:	89 e5                	mov    %esp,%ebp
 5f6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 5f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 600:	eb 25                	jmp    627 <atoi+0x34>
    n = n*10 + *s++ - '0';
 602:	8b 55 fc             	mov    -0x4(%ebp),%edx
 605:	89 d0                	mov    %edx,%eax
 607:	c1 e0 02             	shl    $0x2,%eax
 60a:	01 d0                	add    %edx,%eax
 60c:	01 c0                	add    %eax,%eax
 60e:	89 c1                	mov    %eax,%ecx
 610:	8b 45 08             	mov    0x8(%ebp),%eax
 613:	8d 50 01             	lea    0x1(%eax),%edx
 616:	89 55 08             	mov    %edx,0x8(%ebp)
 619:	0f b6 00             	movzbl (%eax),%eax
 61c:	0f be c0             	movsbl %al,%eax
 61f:	01 c8                	add    %ecx,%eax
 621:	83 e8 30             	sub    $0x30,%eax
 624:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 627:	8b 45 08             	mov    0x8(%ebp),%eax
 62a:	0f b6 00             	movzbl (%eax),%eax
 62d:	3c 2f                	cmp    $0x2f,%al
 62f:	7e 0a                	jle    63b <atoi+0x48>
 631:	8b 45 08             	mov    0x8(%ebp),%eax
 634:	0f b6 00             	movzbl (%eax),%eax
 637:	3c 39                	cmp    $0x39,%al
 639:	7e c7                	jle    602 <atoi+0xf>
  return n;
 63b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 63e:	c9                   	leave
 63f:	c3                   	ret

00000640 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 640:	55                   	push   %ebp
 641:	89 e5                	mov    %esp,%ebp
 643:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 646:	8b 45 08             	mov    0x8(%ebp),%eax
 649:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 64c:	8b 45 0c             	mov    0xc(%ebp),%eax
 64f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 652:	eb 17                	jmp    66b <memmove+0x2b>
    *dst++ = *src++;
 654:	8b 55 f8             	mov    -0x8(%ebp),%edx
 657:	8d 42 01             	lea    0x1(%edx),%eax
 65a:	89 45 f8             	mov    %eax,-0x8(%ebp)
 65d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 660:	8d 48 01             	lea    0x1(%eax),%ecx
 663:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 666:	0f b6 12             	movzbl (%edx),%edx
 669:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 66b:	8b 45 10             	mov    0x10(%ebp),%eax
 66e:	8d 50 ff             	lea    -0x1(%eax),%edx
 671:	89 55 10             	mov    %edx,0x10(%ebp)
 674:	85 c0                	test   %eax,%eax
 676:	7f dc                	jg     654 <memmove+0x14>
  return vdst;
 678:	8b 45 08             	mov    0x8(%ebp),%eax
}
 67b:	c9                   	leave
 67c:	c3                   	ret

0000067d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 67d:	b8 01 00 00 00       	mov    $0x1,%eax
 682:	cd 40                	int    $0x40
 684:	c3                   	ret

00000685 <exit>:
SYSCALL(exit)
 685:	b8 02 00 00 00       	mov    $0x2,%eax
 68a:	cd 40                	int    $0x40
 68c:	c3                   	ret

0000068d <wait>:
SYSCALL(wait)
 68d:	b8 03 00 00 00       	mov    $0x3,%eax
 692:	cd 40                	int    $0x40
 694:	c3                   	ret

00000695 <pipe>:
SYSCALL(pipe)
 695:	b8 04 00 00 00       	mov    $0x4,%eax
 69a:	cd 40                	int    $0x40
 69c:	c3                   	ret

0000069d <read>:
SYSCALL(read)
 69d:	b8 05 00 00 00       	mov    $0x5,%eax
 6a2:	cd 40                	int    $0x40
 6a4:	c3                   	ret

000006a5 <write>:
SYSCALL(write)
 6a5:	b8 10 00 00 00       	mov    $0x10,%eax
 6aa:	cd 40                	int    $0x40
 6ac:	c3                   	ret

000006ad <close>:
SYSCALL(close)
 6ad:	b8 15 00 00 00       	mov    $0x15,%eax
 6b2:	cd 40                	int    $0x40
 6b4:	c3                   	ret

000006b5 <kill>:
SYSCALL(kill)
 6b5:	b8 06 00 00 00       	mov    $0x6,%eax
 6ba:	cd 40                	int    $0x40
 6bc:	c3                   	ret

000006bd <exec>:
SYSCALL(exec)
 6bd:	b8 07 00 00 00       	mov    $0x7,%eax
 6c2:	cd 40                	int    $0x40
 6c4:	c3                   	ret

000006c5 <open>:
SYSCALL(open)
 6c5:	b8 0f 00 00 00       	mov    $0xf,%eax
 6ca:	cd 40                	int    $0x40
 6cc:	c3                   	ret

000006cd <mknod>:
SYSCALL(mknod)
 6cd:	b8 11 00 00 00       	mov    $0x11,%eax
 6d2:	cd 40                	int    $0x40
 6d4:	c3                   	ret

000006d5 <unlink>:
SYSCALL(unlink)
 6d5:	b8 12 00 00 00       	mov    $0x12,%eax
 6da:	cd 40                	int    $0x40
 6dc:	c3                   	ret

000006dd <fstat>:
SYSCALL(fstat)
 6dd:	b8 08 00 00 00       	mov    $0x8,%eax
 6e2:	cd 40                	int    $0x40
 6e4:	c3                   	ret

000006e5 <link>:
SYSCALL(link)
 6e5:	b8 13 00 00 00       	mov    $0x13,%eax
 6ea:	cd 40                	int    $0x40
 6ec:	c3                   	ret

000006ed <mkdir>:
SYSCALL(mkdir)
 6ed:	b8 14 00 00 00       	mov    $0x14,%eax
 6f2:	cd 40                	int    $0x40
 6f4:	c3                   	ret

000006f5 <chdir>:
SYSCALL(chdir)
 6f5:	b8 09 00 00 00       	mov    $0x9,%eax
 6fa:	cd 40                	int    $0x40
 6fc:	c3                   	ret

000006fd <dup>:
SYSCALL(dup)
 6fd:	b8 0a 00 00 00       	mov    $0xa,%eax
 702:	cd 40                	int    $0x40
 704:	c3                   	ret

00000705 <getpid>:
SYSCALL(getpid)
 705:	b8 0b 00 00 00       	mov    $0xb,%eax
 70a:	cd 40                	int    $0x40
 70c:	c3                   	ret

0000070d <sbrk>:
SYSCALL(sbrk)
 70d:	b8 0c 00 00 00       	mov    $0xc,%eax
 712:	cd 40                	int    $0x40
 714:	c3                   	ret

00000715 <sleep>:
SYSCALL(sleep)
 715:	b8 0d 00 00 00       	mov    $0xd,%eax
 71a:	cd 40                	int    $0x40
 71c:	c3                   	ret

0000071d <uptime>:
SYSCALL(uptime)
 71d:	b8 0e 00 00 00       	mov    $0xe,%eax
 722:	cd 40                	int    $0x40
 724:	c3                   	ret

00000725 <uthread_init>:
SYSCALL(uthread_init)
 725:	b8 16 00 00 00       	mov    $0x16,%eax
 72a:	cd 40                	int    $0x40
 72c:	c3                   	ret

0000072d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 72d:	55                   	push   %ebp
 72e:	89 e5                	mov    %esp,%ebp
 730:	83 ec 18             	sub    $0x18,%esp
 733:	8b 45 0c             	mov    0xc(%ebp),%eax
 736:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 739:	83 ec 04             	sub    $0x4,%esp
 73c:	6a 01                	push   $0x1
 73e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 741:	50                   	push   %eax
 742:	ff 75 08             	push   0x8(%ebp)
 745:	e8 5b ff ff ff       	call   6a5 <write>
 74a:	83 c4 10             	add    $0x10,%esp
}
 74d:	90                   	nop
 74e:	c9                   	leave
 74f:	c3                   	ret

00000750 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 750:	55                   	push   %ebp
 751:	89 e5                	mov    %esp,%ebp
 753:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 756:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 75d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 761:	74 17                	je     77a <printint+0x2a>
 763:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 767:	79 11                	jns    77a <printint+0x2a>
    neg = 1;
 769:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 770:	8b 45 0c             	mov    0xc(%ebp),%eax
 773:	f7 d8                	neg    %eax
 775:	89 45 ec             	mov    %eax,-0x14(%ebp)
 778:	eb 06                	jmp    780 <printint+0x30>
  } else {
    x = xx;
 77a:	8b 45 0c             	mov    0xc(%ebp),%eax
 77d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 787:	8b 4d 10             	mov    0x10(%ebp),%ecx
 78a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 78d:	ba 00 00 00 00       	mov    $0x0,%edx
 792:	f7 f1                	div    %ecx
 794:	89 d1                	mov    %edx,%ecx
 796:	8b 45 f4             	mov    -0xc(%ebp),%eax
 799:	8d 50 01             	lea    0x1(%eax),%edx
 79c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 79f:	0f b6 91 f4 0c 00 00 	movzbl 0xcf4(%ecx),%edx
 7a6:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 7aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
 7ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7b0:	ba 00 00 00 00       	mov    $0x0,%edx
 7b5:	f7 f1                	div    %ecx
 7b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7ba:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7be:	75 c7                	jne    787 <printint+0x37>
  if(neg)
 7c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7c4:	74 2d                	je     7f3 <printint+0xa3>
    buf[i++] = '-';
 7c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c9:	8d 50 01             	lea    0x1(%eax),%edx
 7cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
 7cf:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 7d4:	eb 1d                	jmp    7f3 <printint+0xa3>
    putc(fd, buf[i]);
 7d6:	8d 55 dc             	lea    -0x24(%ebp),%edx
 7d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7dc:	01 d0                	add    %edx,%eax
 7de:	0f b6 00             	movzbl (%eax),%eax
 7e1:	0f be c0             	movsbl %al,%eax
 7e4:	83 ec 08             	sub    $0x8,%esp
 7e7:	50                   	push   %eax
 7e8:	ff 75 08             	push   0x8(%ebp)
 7eb:	e8 3d ff ff ff       	call   72d <putc>
 7f0:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 7f3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 7f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7fb:	79 d9                	jns    7d6 <printint+0x86>
}
 7fd:	90                   	nop
 7fe:	90                   	nop
 7ff:	c9                   	leave
 800:	c3                   	ret

00000801 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 801:	55                   	push   %ebp
 802:	89 e5                	mov    %esp,%ebp
 804:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 807:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 80e:	8d 45 0c             	lea    0xc(%ebp),%eax
 811:	83 c0 04             	add    $0x4,%eax
 814:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 817:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 81e:	e9 59 01 00 00       	jmp    97c <printf+0x17b>
    c = fmt[i] & 0xff;
 823:	8b 55 0c             	mov    0xc(%ebp),%edx
 826:	8b 45 f0             	mov    -0x10(%ebp),%eax
 829:	01 d0                	add    %edx,%eax
 82b:	0f b6 00             	movzbl (%eax),%eax
 82e:	0f be c0             	movsbl %al,%eax
 831:	25 ff 00 00 00       	and    $0xff,%eax
 836:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 839:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 83d:	75 2c                	jne    86b <printf+0x6a>
      if(c == '%'){
 83f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 843:	75 0c                	jne    851 <printf+0x50>
        state = '%';
 845:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 84c:	e9 27 01 00 00       	jmp    978 <printf+0x177>
      } else {
        putc(fd, c);
 851:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 854:	0f be c0             	movsbl %al,%eax
 857:	83 ec 08             	sub    $0x8,%esp
 85a:	50                   	push   %eax
 85b:	ff 75 08             	push   0x8(%ebp)
 85e:	e8 ca fe ff ff       	call   72d <putc>
 863:	83 c4 10             	add    $0x10,%esp
 866:	e9 0d 01 00 00       	jmp    978 <printf+0x177>
      }
    } else if(state == '%'){
 86b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 86f:	0f 85 03 01 00 00    	jne    978 <printf+0x177>
      if(c == 'd'){
 875:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 879:	75 1e                	jne    899 <printf+0x98>
        printint(fd, *ap, 10, 1);
 87b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 87e:	8b 00                	mov    (%eax),%eax
 880:	6a 01                	push   $0x1
 882:	6a 0a                	push   $0xa
 884:	50                   	push   %eax
 885:	ff 75 08             	push   0x8(%ebp)
 888:	e8 c3 fe ff ff       	call   750 <printint>
 88d:	83 c4 10             	add    $0x10,%esp
        ap++;
 890:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 894:	e9 d8 00 00 00       	jmp    971 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 899:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 89d:	74 06                	je     8a5 <printf+0xa4>
 89f:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 8a3:	75 1e                	jne    8c3 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 8a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8a8:	8b 00                	mov    (%eax),%eax
 8aa:	6a 00                	push   $0x0
 8ac:	6a 10                	push   $0x10
 8ae:	50                   	push   %eax
 8af:	ff 75 08             	push   0x8(%ebp)
 8b2:	e8 99 fe ff ff       	call   750 <printint>
 8b7:	83 c4 10             	add    $0x10,%esp
        ap++;
 8ba:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8be:	e9 ae 00 00 00       	jmp    971 <printf+0x170>
      } else if(c == 's'){
 8c3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 8c7:	75 43                	jne    90c <printf+0x10b>
        s = (char*)*ap;
 8c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8cc:	8b 00                	mov    (%eax),%eax
 8ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 8d1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 8d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8d9:	75 25                	jne    900 <printf+0xff>
          s = "(null)";
 8db:	c7 45 f4 eb 0c 00 00 	movl   $0xceb,-0xc(%ebp)
        while(*s != 0){
 8e2:	eb 1c                	jmp    900 <printf+0xff>
          putc(fd, *s);
 8e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e7:	0f b6 00             	movzbl (%eax),%eax
 8ea:	0f be c0             	movsbl %al,%eax
 8ed:	83 ec 08             	sub    $0x8,%esp
 8f0:	50                   	push   %eax
 8f1:	ff 75 08             	push   0x8(%ebp)
 8f4:	e8 34 fe ff ff       	call   72d <putc>
 8f9:	83 c4 10             	add    $0x10,%esp
          s++;
 8fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 900:	8b 45 f4             	mov    -0xc(%ebp),%eax
 903:	0f b6 00             	movzbl (%eax),%eax
 906:	84 c0                	test   %al,%al
 908:	75 da                	jne    8e4 <printf+0xe3>
 90a:	eb 65                	jmp    971 <printf+0x170>
        }
      } else if(c == 'c'){
 90c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 910:	75 1d                	jne    92f <printf+0x12e>
        putc(fd, *ap);
 912:	8b 45 e8             	mov    -0x18(%ebp),%eax
 915:	8b 00                	mov    (%eax),%eax
 917:	0f be c0             	movsbl %al,%eax
 91a:	83 ec 08             	sub    $0x8,%esp
 91d:	50                   	push   %eax
 91e:	ff 75 08             	push   0x8(%ebp)
 921:	e8 07 fe ff ff       	call   72d <putc>
 926:	83 c4 10             	add    $0x10,%esp
        ap++;
 929:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 92d:	eb 42                	jmp    971 <printf+0x170>
      } else if(c == '%'){
 92f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 933:	75 17                	jne    94c <printf+0x14b>
        putc(fd, c);
 935:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 938:	0f be c0             	movsbl %al,%eax
 93b:	83 ec 08             	sub    $0x8,%esp
 93e:	50                   	push   %eax
 93f:	ff 75 08             	push   0x8(%ebp)
 942:	e8 e6 fd ff ff       	call   72d <putc>
 947:	83 c4 10             	add    $0x10,%esp
 94a:	eb 25                	jmp    971 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 94c:	83 ec 08             	sub    $0x8,%esp
 94f:	6a 25                	push   $0x25
 951:	ff 75 08             	push   0x8(%ebp)
 954:	e8 d4 fd ff ff       	call   72d <putc>
 959:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 95c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 95f:	0f be c0             	movsbl %al,%eax
 962:	83 ec 08             	sub    $0x8,%esp
 965:	50                   	push   %eax
 966:	ff 75 08             	push   0x8(%ebp)
 969:	e8 bf fd ff ff       	call   72d <putc>
 96e:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 971:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 978:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 97c:	8b 55 0c             	mov    0xc(%ebp),%edx
 97f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 982:	01 d0                	add    %edx,%eax
 984:	0f b6 00             	movzbl (%eax),%eax
 987:	84 c0                	test   %al,%al
 989:	0f 85 94 fe ff ff    	jne    823 <printf+0x22>
    }
  }
}
 98f:	90                   	nop
 990:	90                   	nop
 991:	c9                   	leave
 992:	c3                   	ret

00000993 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 993:	55                   	push   %ebp
 994:	89 e5                	mov    %esp,%ebp
 996:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 999:	8b 45 08             	mov    0x8(%ebp),%eax
 99c:	83 e8 08             	sub    $0x8,%eax
 99f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9a2:	a1 98 4d 01 00       	mov    0x14d98,%eax
 9a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9aa:	eb 24                	jmp    9d0 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9af:	8b 00                	mov    (%eax),%eax
 9b1:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 9b4:	72 12                	jb     9c8 <free+0x35>
 9b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b9:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 9bc:	72 24                	jb     9e2 <free+0x4f>
 9be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c1:	8b 00                	mov    (%eax),%eax
 9c3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9c6:	72 1a                	jb     9e2 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cb:	8b 00                	mov    (%eax),%eax
 9cd:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9d3:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 9d6:	73 d4                	jae    9ac <free+0x19>
 9d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9db:	8b 00                	mov    (%eax),%eax
 9dd:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9e0:	73 ca                	jae    9ac <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 9e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9e5:	8b 40 04             	mov    0x4(%eax),%eax
 9e8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9f2:	01 c2                	add    %eax,%edx
 9f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f7:	8b 00                	mov    (%eax),%eax
 9f9:	39 c2                	cmp    %eax,%edx
 9fb:	75 24                	jne    a21 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 9fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a00:	8b 50 04             	mov    0x4(%eax),%edx
 a03:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a06:	8b 00                	mov    (%eax),%eax
 a08:	8b 40 04             	mov    0x4(%eax),%eax
 a0b:	01 c2                	add    %eax,%edx
 a0d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a10:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a13:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a16:	8b 00                	mov    (%eax),%eax
 a18:	8b 10                	mov    (%eax),%edx
 a1a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a1d:	89 10                	mov    %edx,(%eax)
 a1f:	eb 0a                	jmp    a2b <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 a21:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a24:	8b 10                	mov    (%eax),%edx
 a26:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a29:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a2e:	8b 40 04             	mov    0x4(%eax),%eax
 a31:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a38:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a3b:	01 d0                	add    %edx,%eax
 a3d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a40:	75 20                	jne    a62 <free+0xcf>
    p->s.size += bp->s.size;
 a42:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a45:	8b 50 04             	mov    0x4(%eax),%edx
 a48:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a4b:	8b 40 04             	mov    0x4(%eax),%eax
 a4e:	01 c2                	add    %eax,%edx
 a50:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a53:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a56:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a59:	8b 10                	mov    (%eax),%edx
 a5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a5e:	89 10                	mov    %edx,(%eax)
 a60:	eb 08                	jmp    a6a <free+0xd7>
  } else
    p->s.ptr = bp;
 a62:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a65:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a68:	89 10                	mov    %edx,(%eax)
  freep = p;
 a6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a6d:	a3 98 4d 01 00       	mov    %eax,0x14d98
}
 a72:	90                   	nop
 a73:	c9                   	leave
 a74:	c3                   	ret

00000a75 <morecore>:

static Header*
morecore(uint nu)
{
 a75:	55                   	push   %ebp
 a76:	89 e5                	mov    %esp,%ebp
 a78:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a7b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a82:	77 07                	ja     a8b <morecore+0x16>
    nu = 4096;
 a84:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a8b:	8b 45 08             	mov    0x8(%ebp),%eax
 a8e:	c1 e0 03             	shl    $0x3,%eax
 a91:	83 ec 0c             	sub    $0xc,%esp
 a94:	50                   	push   %eax
 a95:	e8 73 fc ff ff       	call   70d <sbrk>
 a9a:	83 c4 10             	add    $0x10,%esp
 a9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 aa0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 aa4:	75 07                	jne    aad <morecore+0x38>
    return 0;
 aa6:	b8 00 00 00 00       	mov    $0x0,%eax
 aab:	eb 26                	jmp    ad3 <morecore+0x5e>
  hp = (Header*)p;
 aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab6:	8b 55 08             	mov    0x8(%ebp),%edx
 ab9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 abc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 abf:	83 c0 08             	add    $0x8,%eax
 ac2:	83 ec 0c             	sub    $0xc,%esp
 ac5:	50                   	push   %eax
 ac6:	e8 c8 fe ff ff       	call   993 <free>
 acb:	83 c4 10             	add    $0x10,%esp
  return freep;
 ace:	a1 98 4d 01 00       	mov    0x14d98,%eax
}
 ad3:	c9                   	leave
 ad4:	c3                   	ret

00000ad5 <malloc>:

void*
malloc(uint nbytes)
{
 ad5:	55                   	push   %ebp
 ad6:	89 e5                	mov    %esp,%ebp
 ad8:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 adb:	8b 45 08             	mov    0x8(%ebp),%eax
 ade:	83 c0 07             	add    $0x7,%eax
 ae1:	c1 e8 03             	shr    $0x3,%eax
 ae4:	83 c0 01             	add    $0x1,%eax
 ae7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 aea:	a1 98 4d 01 00       	mov    0x14d98,%eax
 aef:	89 45 f0             	mov    %eax,-0x10(%ebp)
 af2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 af6:	75 23                	jne    b1b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 af8:	c7 45 f0 90 4d 01 00 	movl   $0x14d90,-0x10(%ebp)
 aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b02:	a3 98 4d 01 00       	mov    %eax,0x14d98
 b07:	a1 98 4d 01 00       	mov    0x14d98,%eax
 b0c:	a3 90 4d 01 00       	mov    %eax,0x14d90
    base.s.size = 0;
 b11:	c7 05 94 4d 01 00 00 	movl   $0x0,0x14d94
 b18:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b1e:	8b 00                	mov    (%eax),%eax
 b20:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b26:	8b 40 04             	mov    0x4(%eax),%eax
 b29:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b2c:	72 4d                	jb     b7b <malloc+0xa6>
      if(p->s.size == nunits)
 b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b31:	8b 40 04             	mov    0x4(%eax),%eax
 b34:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 b37:	75 0c                	jne    b45 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b3c:	8b 10                	mov    (%eax),%edx
 b3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b41:	89 10                	mov    %edx,(%eax)
 b43:	eb 26                	jmp    b6b <malloc+0x96>
      else {
        p->s.size -= nunits;
 b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b48:	8b 40 04             	mov    0x4(%eax),%eax
 b4b:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b4e:	89 c2                	mov    %eax,%edx
 b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b53:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b59:	8b 40 04             	mov    0x4(%eax),%eax
 b5c:	c1 e0 03             	shl    $0x3,%eax
 b5f:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b65:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b68:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b6e:	a3 98 4d 01 00       	mov    %eax,0x14d98
      return (void*)(p + 1);
 b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b76:	83 c0 08             	add    $0x8,%eax
 b79:	eb 3b                	jmp    bb6 <malloc+0xe1>
    }
    if(p == freep)
 b7b:	a1 98 4d 01 00       	mov    0x14d98,%eax
 b80:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b83:	75 1e                	jne    ba3 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 b85:	83 ec 0c             	sub    $0xc,%esp
 b88:	ff 75 ec             	push   -0x14(%ebp)
 b8b:	e8 e5 fe ff ff       	call   a75 <morecore>
 b90:	83 c4 10             	add    $0x10,%esp
 b93:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b96:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b9a:	75 07                	jne    ba3 <malloc+0xce>
        return 0;
 b9c:	b8 00 00 00 00       	mov    $0x0,%eax
 ba1:	eb 13                	jmp    bb6 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ba6:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bac:	8b 00                	mov    (%eax),%eax
 bae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 bb1:	e9 6d ff ff ff       	jmp    b23 <malloc+0x4e>
  }
}
 bb6:	c9                   	leave
 bb7:	c3                   	ret
