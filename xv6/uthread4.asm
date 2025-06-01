
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
  int curr_index = current_thread - all_thread;
   6:	a1 60 0f 00 00       	mov    0xf60,%eax
   b:	2d 80 0f 00 00       	sub    $0xf80,%eax
  10:	c1 f8 04             	sar    $0x4,%eax
  13:	69 c0 01 fe 03 f8    	imul   $0xf803fe01,%eax,%eax
  19:	89 45 f0             	mov    %eax,-0x10(%ebp)
  next_thread = 0;
  1c:	c7 05 64 0f 00 00 00 	movl   $0x0,0xf64
  23:	00 00 00 


  for (int count = 1; count <= MAX_THREAD; count++) {
  26:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  2d:	eb 68                	jmp    97 <thread_schedule+0x97>
    int i = (curr_index + count) % MAX_THREAD;;
  2f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  35:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
  38:	ba 67 66 66 66       	mov    $0x66666667,%edx
  3d:	89 c8                	mov    %ecx,%eax
  3f:	f7 ea                	imul   %edx
  41:	89 d0                	mov    %edx,%eax
  43:	c1 f8 02             	sar    $0x2,%eax
  46:	89 ca                	mov    %ecx,%edx
  48:	c1 fa 1f             	sar    $0x1f,%edx
  4b:	29 d0                	sub    %edx,%eax
  4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  50:	8b 55 ec             	mov    -0x14(%ebp),%edx
  53:	89 d0                	mov    %edx,%eax
  55:	c1 e0 02             	shl    $0x2,%eax
  58:	01 d0                	add    %edx,%eax
  5a:	01 c0                	add    %eax,%eax
  5c:	29 c1                	sub    %eax,%ecx
  5e:	89 ca                	mov    %ecx,%edx
  60:	89 55 ec             	mov    %edx,-0x14(%ebp)

    if (all_thread[i].state == RUNNABLE && i != 0) {
  63:	8b 45 ec             	mov    -0x14(%ebp),%eax
  66:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
  6c:	05 84 2f 00 00       	add    $0x2f84,%eax
  71:	8b 00                	mov    (%eax),%eax
  73:	83 f8 02             	cmp    $0x2,%eax
  76:	75 1b                	jne    93 <thread_schedule+0x93>
  78:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  7c:	74 15                	je     93 <thread_schedule+0x93>
      next_thread = &all_thread[i];
  7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  81:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
  87:	05 80 0f 00 00       	add    $0xf80,%eax
  8c:	a3 64 0f 00 00       	mov    %eax,0xf64
      break;
  91:	eb 0a                	jmp    9d <thread_schedule+0x9d>
  for (int count = 1; count <= MAX_THREAD; count++) {
  93:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  97:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
  9b:	7e 92                	jle    2f <thread_schedule+0x2f>
    }
  }

  if (next_thread == 0) {
  9d:	a1 64 0f 00 00       	mov    0xf64,%eax
  a2:	85 c0                	test   %eax,%eax
  a4:	75 17                	jne    bd <thread_schedule+0xbd>
    printf(2, "thread_schedule: no runnable threads\n");
  a6:	83 ec 08             	sub    $0x8,%esp
  a9:	68 fc 0c 00 00       	push   $0xcfc
  ae:	6a 02                	push   $0x2
  b0:	e8 8e 08 00 00       	call   943 <printf>
  b5:	83 c4 10             	add    $0x10,%esp
    exit();
  b8:	e8 02 07 00 00       	call   7bf <exit>
  }

  if (current_thread != next_thread) {
  bd:	8b 15 60 0f 00 00    	mov    0xf60,%edx
  c3:	a1 64 0f 00 00       	mov    0xf64,%eax
  c8:	39 c2                	cmp    %eax,%edx
  ca:	74 34                	je     100 <thread_schedule+0x100>
    next_thread->state = RUNNING;
  cc:	a1 64 0f 00 00       	mov    0xf64,%eax
  d1:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  d8:	00 00 00 
    if (current_thread->state != FREE) {
  db:	a1 60 0f 00 00       	mov    0xf60,%eax
  e0:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  e6:	85 c0                	test   %eax,%eax
  e8:	74 0f                	je     f9 <thread_schedule+0xf9>
      current_thread->state = RUNNABLE;
  ea:	a1 60 0f 00 00       	mov    0xf60,%eax
  ef:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
  f6:	00 00 00 
    }
    thread_switch();
  f9:	e8 4a 04 00 00       	call   548 <thread_switch>
  } else
    next_thread = 0;
}
  fe:	eb 0a                	jmp    10a <thread_schedule+0x10a>
    next_thread = 0;
 100:	c7 05 64 0f 00 00 00 	movl   $0x0,0xf64
 107:	00 00 00 
}
 10a:	90                   	nop
 10b:	c9                   	leave
 10c:	c3                   	ret

0000010d <thread_init>:
void 
thread_init(void)
{
 10d:	55                   	push   %ebp
 10e:	89 e5                	mov    %esp,%ebp
 110:	83 ec 08             	sub    $0x8,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
 113:	c7 05 60 0f 00 00 80 	movl   $0xf80,0xf60
 11a:	0f 00 00 
  current_thread->state = RUNNING;
 11d:	a1 60 0f 00 00       	mov    0xf60,%eax
 122:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
 129:	00 00 00 
  current_thread->tid=0;
 12c:	a1 60 0f 00 00       	mov    0xf60,%eax
 131:	c7 80 08 20 00 00 00 	movl   $0x0,0x2008(%eax)
 138:	00 00 00 
  current_thread->ptid=0;
 13b:	a1 60 0f 00 00       	mov    0xf60,%eax
 140:	c7 80 0c 20 00 00 00 	movl   $0x0,0x200c(%eax)
 147:	00 00 00 

  uthread_init((int)thread_schedule);
 14a:	b8 00 00 00 00       	mov    $0x0,%eax
 14f:	83 ec 0c             	sub    $0xc,%esp
 152:	50                   	push   %eax
 153:	e8 07 07 00 00       	call   85f <uthread_init>
 158:	83 c4 10             	add    $0x10,%esp
}
 15b:	90                   	nop
 15c:	c9                   	leave
 15d:	c3                   	ret

0000015e <thread_create>:

int 
thread_create(void (*func)())
{
 15e:	55                   	push   %ebp
 15f:	89 e5                	mov    %esp,%ebp
 161:	83 ec 18             	sub    $0x18,%esp
  printf(1,"thread_create\n");
 164:	83 ec 08             	sub    $0x8,%esp
 167:	68 22 0d 00 00       	push   $0xd22
 16c:	6a 01                	push   $0x1
 16e:	e8 d0 07 00 00       	call   943 <printf>
 173:	83 c4 10             	add    $0x10,%esp
  
  thread_p t;
  for (t = all_thread +1 ; t < all_thread + MAX_THREAD; t++) {
 176:	c7 45 f4 90 2f 00 00 	movl   $0x2f90,-0xc(%ebp)
 17d:	eb 14                	jmp    193 <thread_create+0x35>
    if (t->state == FREE) break;
 17f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 182:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 188:	85 c0                	test   %eax,%eax
 18a:	74 13                	je     19f <thread_create+0x41>
  for (t = all_thread +1 ; t < all_thread + MAX_THREAD; t++) {
 18c:	81 45 f4 10 20 00 00 	addl   $0x2010,-0xc(%ebp)
 193:	b8 20 50 01 00       	mov    $0x15020,%eax
 198:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 19b:	72 e2                	jb     17f <thread_create+0x21>
 19d:	eb 01                	jmp    1a0 <thread_create+0x42>
    if (t->state == FREE) break;
 19f:	90                   	nop
  }

  t->sp = (int)(t->stack + STACK_SIZE);
 1a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a3:	83 c0 04             	add    $0x4,%eax
 1a6:	05 00 20 00 00       	add    $0x2000,%eax
 1ab:	89 c2                	mov    %eax,%edx
 1ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b0:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;
 1b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b5:	8b 00                	mov    (%eax),%eax
 1b7:	8d 50 fc             	lea    -0x4(%eax),%edx
 1ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1bd:	89 10                	mov    %edx,(%eax)
  *(int *)(t->sp) = (int)func;  // ret 주소
 1bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c2:	8b 00                	mov    (%eax),%eax
 1c4:	89 c2                	mov    %eax,%edx
 1c6:	8b 45 08             	mov    0x8(%ebp),%eax
 1c9:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;
 1cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ce:	8b 00                	mov    (%eax),%eax
 1d0:	8d 50 e0             	lea    -0x20(%eax),%edx
 1d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d6:	89 10                	mov    %edx,(%eax)

  t->tid = t - all_thread;
 1d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1db:	2d 80 0f 00 00       	sub    $0xf80,%eax
 1e0:	c1 f8 04             	sar    $0x4,%eax
 1e3:	69 c0 01 fe 03 f8    	imul   $0xf803fe01,%eax,%eax
 1e9:	89 c2                	mov    %eax,%edx
 1eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ee:	89 90 08 20 00 00    	mov    %edx,0x2008(%eax)
  t->ptid = current_thread->tid;
 1f4:	a1 60 0f 00 00       	mov    0xf60,%eax
 1f9:	8b 90 08 20 00 00    	mov    0x2008(%eax),%edx
 1ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 202:	89 90 0c 20 00 00    	mov    %edx,0x200c(%eax)
  t->state = RUNNABLE;
 208:	8b 45 f4             	mov    -0xc(%ebp),%eax
 20b:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 212:	00 00 00 

  printf(1, "[create] tid=%d func address = 0x%x\n", t->tid, func);
 215:	8b 45 f4             	mov    -0xc(%ebp),%eax
 218:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 21e:	ff 75 08             	push   0x8(%ebp)
 221:	50                   	push   %eax
 222:	68 34 0d 00 00       	push   $0xd34
 227:	6a 01                	push   $0x1
 229:	e8 15 07 00 00       	call   943 <printf>
 22e:	83 c4 10             	add    $0x10,%esp
  return t->tid;
 231:	8b 45 f4             	mov    -0xc(%ebp),%eax
 234:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
}
 23a:	c9                   	leave
 23b:	c3                   	ret

0000023c <thread_join>:

// thread_join 함수 구현
int thread_join(int tid) {
 23c:	55                   	push   %ebp
 23d:	89 e5                	mov    %esp,%ebp
 23f:	83 ec 18             	sub    $0x18,%esp
  if (tid < 0 || tid >= MAX_THREAD) {
 242:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 246:	78 06                	js     24e <thread_join+0x12>
 248:	83 7d 08 09          	cmpl   $0x9,0x8(%ebp)
 24c:	7e 1f                	jle    26d <thread_join+0x31>
    printf(1, "[thread_join] Invalid thread ID: %d\n", tid);
 24e:	83 ec 04             	sub    $0x4,%esp
 251:	ff 75 08             	push   0x8(%ebp)
 254:	68 5c 0d 00 00       	push   $0xd5c
 259:	6a 01                	push   $0x1
 25b:	e8 e3 06 00 00       	call   943 <printf>
 260:	83 c4 10             	add    $0x10,%esp
    return -1;
 263:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 268:	e9 3c 01 00 00       	jmp    3a9 <thread_join+0x16d>
  }

  thread_p target = &all_thread[tid];
 26d:	8b 45 08             	mov    0x8(%ebp),%eax
 270:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 276:	05 80 0f 00 00       	add    $0xf80,%eax
 27b:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // 유효한 자식인지 확인
  if (target->ptid != current_thread->tid) {
 27e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 281:	8b 90 0c 20 00 00    	mov    0x200c(%eax),%edx
 287:	a1 60 0f 00 00       	mov    0xf60,%eax
 28c:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 292:	39 c2                	cmp    %eax,%edx
 294:	74 28                	je     2be <thread_join+0x82>
    printf(1, "[thread_join] tid=%d is not a child of current thread=%d\n", tid, current_thread->tid);
 296:	a1 60 0f 00 00       	mov    0xf60,%eax
 29b:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 2a1:	50                   	push   %eax
 2a2:	ff 75 08             	push   0x8(%ebp)
 2a5:	68 84 0d 00 00       	push   $0xd84
 2aa:	6a 01                	push   $0x1
 2ac:	e8 92 06 00 00       	call   943 <printf>
 2b1:	83 c4 10             	add    $0x10,%esp
    return -1;
 2b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2b9:	e9 eb 00 00 00       	jmp    3a9 <thread_join+0x16d>
  }

  printf(1, "[thread_join] current=%d waiting for child=%d\n", current_thread->tid, tid);
 2be:	a1 60 0f 00 00       	mov    0xf60,%eax
 2c3:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 2c9:	ff 75 08             	push   0x8(%ebp)
 2cc:	50                   	push   %eax
 2cd:	68 c0 0d 00 00       	push   $0xdc0
 2d2:	6a 01                	push   $0x1
 2d4:	e8 6a 06 00 00       	call   943 <printf>
 2d9:	83 c4 10             	add    $0x10,%esp

  while (1) {
    if (target->state == FREE) {
 2dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 2df:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 2e5:	85 c0                	test   %eax,%eax
 2e7:	75 14                	jne    2fd <thread_join+0xc1>
      // 자식 종료되었으면 실행 가능 상태로 복귀
      current_thread->state = RUNNABLE;
 2e9:	a1 60 0f 00 00       	mov    0xf60,%eax
 2ee:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 2f5:	00 00 00 
      break;
 2f8:	e9 92 00 00 00       	jmp    38f <thread_join+0x153>
    }

    // WAIT으로 변경
    current_thread->state = WAIT;
 2fd:	a1 60 0f 00 00       	mov    0xf60,%eax
 302:	c7 80 04 20 00 00 03 	movl   $0x3,0x2004(%eax)
 309:	00 00 00 

    // 다른 RUNNABLE 스레드가 있는지 확인
    int has_runnable = 0;
 30c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (int i = 0; i < MAX_THREAD; i++) {
 313:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 31a:	eb 3a                	jmp    356 <thread_join+0x11a>
      if (&all_thread[i] != current_thread && all_thread[i].state == RUNNABLE) {
 31c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 31f:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 325:	8d 90 80 0f 00 00    	lea    0xf80(%eax),%edx
 32b:	a1 60 0f 00 00       	mov    0xf60,%eax
 330:	39 c2                	cmp    %eax,%edx
 332:	74 1e                	je     352 <thread_join+0x116>
 334:	8b 45 f0             	mov    -0x10(%ebp),%eax
 337:	69 c0 10 20 00 00    	imul   $0x2010,%eax,%eax
 33d:	05 84 2f 00 00       	add    $0x2f84,%eax
 342:	8b 00                	mov    (%eax),%eax
 344:	83 f8 02             	cmp    $0x2,%eax
 347:	75 09                	jne    352 <thread_join+0x116>
        has_runnable = 1;
 349:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        break;
 350:	eb 0a                	jmp    35c <thread_join+0x120>
    for (int i = 0; i < MAX_THREAD; i++) {
 352:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 356:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
 35a:	7e c0                	jle    31c <thread_join+0xe0>
      }
    }

    if (!has_runnable) {
 35c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 360:	75 23                	jne    385 <thread_join+0x149>
      // 깨울 수 있는 다른 스레드가 없다면 스스로 다시 실행 가능하게 변경
      printf(1, "[thread_join] no RUNNABLE threads left, waking self\n");
 362:	83 ec 08             	sub    $0x8,%esp
 365:	68 f0 0d 00 00       	push   $0xdf0
 36a:	6a 01                	push   $0x1
 36c:	e8 d2 05 00 00       	call   943 <printf>
 371:	83 c4 10             	add    $0x10,%esp
      current_thread->state = RUNNABLE;
 374:	a1 60 0f 00 00       	mov    0xf60,%eax
 379:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 380:	00 00 00 
      break;
 383:	eb 0a                	jmp    38f <thread_join+0x153>
    }
    
    // 스케줄링
    thread_schedule();
 385:	e8 76 fc ff ff       	call   0 <thread_schedule>
  while (1) {
 38a:	e9 4d ff ff ff       	jmp    2dc <thread_join+0xa0>
  }

  printf(1, "[thread_join] child tid=%d finished\n", tid);
 38f:	83 ec 04             	sub    $0x4,%esp
 392:	ff 75 08             	push   0x8(%ebp)
 395:	68 28 0e 00 00       	push   $0xe28
 39a:	6a 01                	push   $0x1
 39c:	e8 a2 05 00 00       	call   943 <printf>
 3a1:	83 c4 10             	add    $0x10,%esp
  return 0;
 3a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3a9:	c9                   	leave
 3aa:	c3                   	ret

000003ab <child_thread>:

static void 
child_thread(void)
{
 3ab:	55                   	push   %ebp
 3ac:	89 e5                	mov    %esp,%ebp
 3ae:	83 ec 18             	sub    $0x18,%esp
  // tid별 작업량 차이 -> 종료시간 다르게해서 join 이전 Child_Thread 종료 방지
  int limit = 10 + current_thread->tid * 2; 
 3b1:	a1 60 0f 00 00       	mov    0xf60,%eax
 3b6:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 3bc:	83 c0 05             	add    $0x5,%eax
 3bf:	01 c0                	add    %eax,%eax
 3c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for (int i = 0; i < limit; i++) {
 3c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3cb:	eb 27                	jmp    3f4 <child_thread+0x49>
    printf(1, "[child] tid=%d running iteration %d\n", current_thread->tid, i);
 3cd:	a1 60 0f 00 00       	mov    0xf60,%eax
 3d2:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 3d8:	ff 75 f4             	push   -0xc(%ebp)
 3db:	50                   	push   %eax
 3dc:	68 50 0e 00 00       	push   $0xe50
 3e1:	6a 01                	push   $0x1
 3e3:	e8 5b 05 00 00       	call   943 <printf>
 3e8:	83 c4 10             	add    $0x10,%esp
    thread_schedule();
 3eb:	e8 10 fc ff ff       	call   0 <thread_schedule>
  for (int i = 0; i < limit; i++) {
 3f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3f7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
 3fa:	7c d1                	jl     3cd <child_thread+0x22>
  }
  printf(1, "child thread: exit\n");
 3fc:	83 ec 08             	sub    $0x8,%esp
 3ff:	68 75 0e 00 00       	push   $0xe75
 404:	6a 01                	push   $0x1
 406:	e8 38 05 00 00       	call   943 <printf>
 40b:	83 c4 10             	add    $0x10,%esp


  current_thread->state = FREE;
 40e:	a1 60 0f 00 00       	mov    0xf60,%eax
 413:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 41a:	00 00 00 
  thread_schedule(); 
 41d:	e8 de fb ff ff       	call   0 <thread_schedule>
}
 422:	90                   	nop
 423:	c9                   	leave
 424:	c3                   	ret

00000425 <mythread>:

static void 
mythread(void)
{
 425:	55                   	push   %ebp
 426:	89 e5                	mov    %esp,%ebp
 428:	83 ec 28             	sub    $0x28,%esp
  int i;
  int tid[5];

  printf(1, "[parent] mythread tid=%d creating children...\n", current_thread->tid);
 42b:	a1 60 0f 00 00       	mov    0xf60,%eax
 430:	8b 80 08 20 00 00    	mov    0x2008(%eax),%eax
 436:	83 ec 04             	sub    $0x4,%esp
 439:	50                   	push   %eax
 43a:	68 8c 0e 00 00       	push   $0xe8c
 43f:	6a 01                	push   $0x1
 441:	e8 fd 04 00 00       	call   943 <printf>
 446:	83 c4 10             	add    $0x10,%esp

  // 자식 스레드 생성하고 tid 저장
  for (i = 0; i < 5; i++) {
 449:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 450:	eb 35                	jmp    487 <mythread+0x62>
    tid[i] = thread_create(child_thread);
 452:	83 ec 0c             	sub    $0xc,%esp
 455:	68 ab 03 00 00       	push   $0x3ab
 45a:	e8 ff fc ff ff       	call   15e <thread_create>
 45f:	83 c4 10             	add    $0x10,%esp
 462:	8b 55 f4             	mov    -0xc(%ebp),%edx
 465:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
    printf(1, "[parent] created child with tid=%d\n", tid[i]);
 469:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46c:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
 470:	83 ec 04             	sub    $0x4,%esp
 473:	50                   	push   %eax
 474:	68 bc 0e 00 00       	push   $0xebc
 479:	6a 01                	push   $0x1
 47b:	e8 c3 04 00 00       	call   943 <printf>
 480:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 483:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 487:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 48b:	7e c5                	jle    452 <mythread+0x2d>
  }
  
  // 각 자식 스레드를 개별적으로 join
  for (i = 0; i < 5; i++) {
 48d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 494:	eb 4b                	jmp    4e1 <mythread+0xbc>
    printf(1, "[parent] joining child tid=%d\n", tid[i]);
 496:	8b 45 f4             	mov    -0xc(%ebp),%eax
 499:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
 49d:	83 ec 04             	sub    $0x4,%esp
 4a0:	50                   	push   %eax
 4a1:	68 e0 0e 00 00       	push   $0xee0
 4a6:	6a 01                	push   $0x1
 4a8:	e8 96 04 00 00       	call   943 <printf>
 4ad:	83 c4 10             	add    $0x10,%esp
    thread_join(tid[i]);
 4b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b3:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
 4b7:	83 ec 0c             	sub    $0xc,%esp
 4ba:	50                   	push   %eax
 4bb:	e8 7c fd ff ff       	call   23c <thread_join>
 4c0:	83 c4 10             	add    $0x10,%esp
    printf(1, "[parent] child tid=%d joined\n", tid[i]);
 4c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c6:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
 4ca:	83 ec 04             	sub    $0x4,%esp
 4cd:	50                   	push   %eax
 4ce:	68 ff 0e 00 00       	push   $0xeff
 4d3:	6a 01                	push   $0x1
 4d5:	e8 69 04 00 00       	call   943 <printf>
 4da:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 4dd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 4e1:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 4e5:	7e af                	jle    496 <mythread+0x71>
  }
    
  printf(1, "[parent] mythread done\n");
 4e7:	83 ec 08             	sub    $0x8,%esp
 4ea:	68 1d 0f 00 00       	push   $0xf1d
 4ef:	6a 01                	push   $0x1
 4f1:	e8 4d 04 00 00       	call   943 <printf>
 4f6:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 4f9:	a1 60 0f 00 00       	mov    0xf60,%eax
 4fe:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 505:	00 00 00 
  thread_schedule();
 508:	e8 f3 fa ff ff       	call   0 <thread_schedule>
}
 50d:	90                   	nop
 50e:	c9                   	leave
 50f:	c3                   	ret

00000510 <main>:

int 
main(int argc, char *argv[]) 
{
 510:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 514:	83 e4 f0             	and    $0xfffffff0,%esp
 517:	ff 71 fc             	push   -0x4(%ecx)
 51a:	55                   	push   %ebp
 51b:	89 e5                	mov    %esp,%ebp
 51d:	51                   	push   %ecx
 51e:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 521:	e8 e7 fb ff ff       	call   10d <thread_init>
  thread_create(mythread);
 526:	83 ec 0c             	sub    $0xc,%esp
 529:	68 25 04 00 00       	push   $0x425
 52e:	e8 2b fc ff ff       	call   15e <thread_create>
 533:	83 c4 10             	add    $0x10,%esp
  thread_schedule(); 
 536:	e8 c5 fa ff ff       	call   0 <thread_schedule>
  return 0;
 53b:	b8 00 00 00 00       	mov    $0x0,%eax
 540:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 543:	c9                   	leave
 544:	8d 61 fc             	lea    -0x4(%ecx),%esp
 547:	c3                   	ret

00000548 <thread_switch>:
         */
    .text
    .globl thread_switch
thread_switch:

    pushal
 548:	60                   	pusha

    movl current_thread, %eax
 549:	a1 60 0f 00 00       	mov    0xf60,%eax
    movl %esp, (%eax)
 54e:	89 20                	mov    %esp,(%eax)

    movl next_thread, %eax
 550:	a1 64 0f 00 00       	mov    0xf64,%eax
    movl (%eax), %esp
 555:	8b 20                	mov    (%eax),%esp
    # esp = t1.주소

    movl %eax, current_thread
 557:	a3 60 0f 00 00       	mov    %eax,0xf60

    // 레지스터 복구
    popal
 55c:	61                   	popa

    movl $0, next_thread
 55d:	c7 05 64 0f 00 00 00 	movl   $0x0,0xf64
 564:	00 00 00 
    
 567:	c3                   	ret

00000568 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 568:	55                   	push   %ebp
 569:	89 e5                	mov    %esp,%ebp
 56b:	57                   	push   %edi
 56c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 56d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 570:	8b 55 10             	mov    0x10(%ebp),%edx
 573:	8b 45 0c             	mov    0xc(%ebp),%eax
 576:	89 cb                	mov    %ecx,%ebx
 578:	89 df                	mov    %ebx,%edi
 57a:	89 d1                	mov    %edx,%ecx
 57c:	fc                   	cld
 57d:	f3 aa                	rep stos %al,%es:(%edi)
 57f:	89 ca                	mov    %ecx,%edx
 581:	89 fb                	mov    %edi,%ebx
 583:	89 5d 08             	mov    %ebx,0x8(%ebp)
 586:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 589:	90                   	nop
 58a:	5b                   	pop    %ebx
 58b:	5f                   	pop    %edi
 58c:	5d                   	pop    %ebp
 58d:	c3                   	ret

0000058e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 58e:	55                   	push   %ebp
 58f:	89 e5                	mov    %esp,%ebp
 591:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 594:	8b 45 08             	mov    0x8(%ebp),%eax
 597:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 59a:	90                   	nop
 59b:	8b 55 0c             	mov    0xc(%ebp),%edx
 59e:	8d 42 01             	lea    0x1(%edx),%eax
 5a1:	89 45 0c             	mov    %eax,0xc(%ebp)
 5a4:	8b 45 08             	mov    0x8(%ebp),%eax
 5a7:	8d 48 01             	lea    0x1(%eax),%ecx
 5aa:	89 4d 08             	mov    %ecx,0x8(%ebp)
 5ad:	0f b6 12             	movzbl (%edx),%edx
 5b0:	88 10                	mov    %dl,(%eax)
 5b2:	0f b6 00             	movzbl (%eax),%eax
 5b5:	84 c0                	test   %al,%al
 5b7:	75 e2                	jne    59b <strcpy+0xd>
    ;
  return os;
 5b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5bc:	c9                   	leave
 5bd:	c3                   	ret

000005be <strcmp>:

int
strcmp(const char *p, const char *q)
{
 5be:	55                   	push   %ebp
 5bf:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 5c1:	eb 08                	jmp    5cb <strcmp+0xd>
    p++, q++;
 5c3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5c7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 5cb:	8b 45 08             	mov    0x8(%ebp),%eax
 5ce:	0f b6 00             	movzbl (%eax),%eax
 5d1:	84 c0                	test   %al,%al
 5d3:	74 10                	je     5e5 <strcmp+0x27>
 5d5:	8b 45 08             	mov    0x8(%ebp),%eax
 5d8:	0f b6 10             	movzbl (%eax),%edx
 5db:	8b 45 0c             	mov    0xc(%ebp),%eax
 5de:	0f b6 00             	movzbl (%eax),%eax
 5e1:	38 c2                	cmp    %al,%dl
 5e3:	74 de                	je     5c3 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 5e5:	8b 45 08             	mov    0x8(%ebp),%eax
 5e8:	0f b6 00             	movzbl (%eax),%eax
 5eb:	0f b6 d0             	movzbl %al,%edx
 5ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f1:	0f b6 00             	movzbl (%eax),%eax
 5f4:	0f b6 c0             	movzbl %al,%eax
 5f7:	29 c2                	sub    %eax,%edx
 5f9:	89 d0                	mov    %edx,%eax
}
 5fb:	5d                   	pop    %ebp
 5fc:	c3                   	ret

000005fd <strlen>:

uint
strlen(char *s)
{
 5fd:	55                   	push   %ebp
 5fe:	89 e5                	mov    %esp,%ebp
 600:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 603:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 60a:	eb 04                	jmp    610 <strlen+0x13>
 60c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 610:	8b 55 fc             	mov    -0x4(%ebp),%edx
 613:	8b 45 08             	mov    0x8(%ebp),%eax
 616:	01 d0                	add    %edx,%eax
 618:	0f b6 00             	movzbl (%eax),%eax
 61b:	84 c0                	test   %al,%al
 61d:	75 ed                	jne    60c <strlen+0xf>
    ;
  return n;
 61f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 622:	c9                   	leave
 623:	c3                   	ret

00000624 <memset>:

void*
memset(void *dst, int c, uint n)
{
 624:	55                   	push   %ebp
 625:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 627:	8b 45 10             	mov    0x10(%ebp),%eax
 62a:	50                   	push   %eax
 62b:	ff 75 0c             	push   0xc(%ebp)
 62e:	ff 75 08             	push   0x8(%ebp)
 631:	e8 32 ff ff ff       	call   568 <stosb>
 636:	83 c4 0c             	add    $0xc,%esp
  return dst;
 639:	8b 45 08             	mov    0x8(%ebp),%eax
}
 63c:	c9                   	leave
 63d:	c3                   	ret

0000063e <strchr>:

char*
strchr(const char *s, char c)
{
 63e:	55                   	push   %ebp
 63f:	89 e5                	mov    %esp,%ebp
 641:	83 ec 04             	sub    $0x4,%esp
 644:	8b 45 0c             	mov    0xc(%ebp),%eax
 647:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 64a:	eb 14                	jmp    660 <strchr+0x22>
    if(*s == c)
 64c:	8b 45 08             	mov    0x8(%ebp),%eax
 64f:	0f b6 00             	movzbl (%eax),%eax
 652:	38 45 fc             	cmp    %al,-0x4(%ebp)
 655:	75 05                	jne    65c <strchr+0x1e>
      return (char*)s;
 657:	8b 45 08             	mov    0x8(%ebp),%eax
 65a:	eb 13                	jmp    66f <strchr+0x31>
  for(; *s; s++)
 65c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 660:	8b 45 08             	mov    0x8(%ebp),%eax
 663:	0f b6 00             	movzbl (%eax),%eax
 666:	84 c0                	test   %al,%al
 668:	75 e2                	jne    64c <strchr+0xe>
  return 0;
 66a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 66f:	c9                   	leave
 670:	c3                   	ret

00000671 <gets>:

char*
gets(char *buf, int max)
{
 671:	55                   	push   %ebp
 672:	89 e5                	mov    %esp,%ebp
 674:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 677:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 67e:	eb 42                	jmp    6c2 <gets+0x51>
    cc = read(0, &c, 1);
 680:	83 ec 04             	sub    $0x4,%esp
 683:	6a 01                	push   $0x1
 685:	8d 45 ef             	lea    -0x11(%ebp),%eax
 688:	50                   	push   %eax
 689:	6a 00                	push   $0x0
 68b:	e8 47 01 00 00       	call   7d7 <read>
 690:	83 c4 10             	add    $0x10,%esp
 693:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 696:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 69a:	7e 33                	jle    6cf <gets+0x5e>
      break;
    buf[i++] = c;
 69c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 69f:	8d 50 01             	lea    0x1(%eax),%edx
 6a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6a5:	89 c2                	mov    %eax,%edx
 6a7:	8b 45 08             	mov    0x8(%ebp),%eax
 6aa:	01 c2                	add    %eax,%edx
 6ac:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6b0:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 6b2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6b6:	3c 0a                	cmp    $0xa,%al
 6b8:	74 16                	je     6d0 <gets+0x5f>
 6ba:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 6be:	3c 0d                	cmp    $0xd,%al
 6c0:	74 0e                	je     6d0 <gets+0x5f>
  for(i=0; i+1 < max; ){
 6c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c5:	83 c0 01             	add    $0x1,%eax
 6c8:	39 45 0c             	cmp    %eax,0xc(%ebp)
 6cb:	7f b3                	jg     680 <gets+0xf>
 6cd:	eb 01                	jmp    6d0 <gets+0x5f>
      break;
 6cf:	90                   	nop
      break;
  }
  buf[i] = '\0';
 6d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
 6d3:	8b 45 08             	mov    0x8(%ebp),%eax
 6d6:	01 d0                	add    %edx,%eax
 6d8:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 6db:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6de:	c9                   	leave
 6df:	c3                   	ret

000006e0 <stat>:

int
stat(char *n, struct stat *st)
{
 6e0:	55                   	push   %ebp
 6e1:	89 e5                	mov    %esp,%ebp
 6e3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6e6:	83 ec 08             	sub    $0x8,%esp
 6e9:	6a 00                	push   $0x0
 6eb:	ff 75 08             	push   0x8(%ebp)
 6ee:	e8 0c 01 00 00       	call   7ff <open>
 6f3:	83 c4 10             	add    $0x10,%esp
 6f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 6f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6fd:	79 07                	jns    706 <stat+0x26>
    return -1;
 6ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 704:	eb 25                	jmp    72b <stat+0x4b>
  r = fstat(fd, st);
 706:	83 ec 08             	sub    $0x8,%esp
 709:	ff 75 0c             	push   0xc(%ebp)
 70c:	ff 75 f4             	push   -0xc(%ebp)
 70f:	e8 03 01 00 00       	call   817 <fstat>
 714:	83 c4 10             	add    $0x10,%esp
 717:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 71a:	83 ec 0c             	sub    $0xc,%esp
 71d:	ff 75 f4             	push   -0xc(%ebp)
 720:	e8 c2 00 00 00       	call   7e7 <close>
 725:	83 c4 10             	add    $0x10,%esp
  return r;
 728:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 72b:	c9                   	leave
 72c:	c3                   	ret

0000072d <atoi>:

int
atoi(const char *s)
{
 72d:	55                   	push   %ebp
 72e:	89 e5                	mov    %esp,%ebp
 730:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 733:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 73a:	eb 25                	jmp    761 <atoi+0x34>
    n = n*10 + *s++ - '0';
 73c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 73f:	89 d0                	mov    %edx,%eax
 741:	c1 e0 02             	shl    $0x2,%eax
 744:	01 d0                	add    %edx,%eax
 746:	01 c0                	add    %eax,%eax
 748:	89 c1                	mov    %eax,%ecx
 74a:	8b 45 08             	mov    0x8(%ebp),%eax
 74d:	8d 50 01             	lea    0x1(%eax),%edx
 750:	89 55 08             	mov    %edx,0x8(%ebp)
 753:	0f b6 00             	movzbl (%eax),%eax
 756:	0f be c0             	movsbl %al,%eax
 759:	01 c8                	add    %ecx,%eax
 75b:	83 e8 30             	sub    $0x30,%eax
 75e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 761:	8b 45 08             	mov    0x8(%ebp),%eax
 764:	0f b6 00             	movzbl (%eax),%eax
 767:	3c 2f                	cmp    $0x2f,%al
 769:	7e 0a                	jle    775 <atoi+0x48>
 76b:	8b 45 08             	mov    0x8(%ebp),%eax
 76e:	0f b6 00             	movzbl (%eax),%eax
 771:	3c 39                	cmp    $0x39,%al
 773:	7e c7                	jle    73c <atoi+0xf>
  return n;
 775:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 778:	c9                   	leave
 779:	c3                   	ret

0000077a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 77a:	55                   	push   %ebp
 77b:	89 e5                	mov    %esp,%ebp
 77d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 780:	8b 45 08             	mov    0x8(%ebp),%eax
 783:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 786:	8b 45 0c             	mov    0xc(%ebp),%eax
 789:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 78c:	eb 17                	jmp    7a5 <memmove+0x2b>
    *dst++ = *src++;
 78e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 791:	8d 42 01             	lea    0x1(%edx),%eax
 794:	89 45 f8             	mov    %eax,-0x8(%ebp)
 797:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79a:	8d 48 01             	lea    0x1(%eax),%ecx
 79d:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 7a0:	0f b6 12             	movzbl (%edx),%edx
 7a3:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 7a5:	8b 45 10             	mov    0x10(%ebp),%eax
 7a8:	8d 50 ff             	lea    -0x1(%eax),%edx
 7ab:	89 55 10             	mov    %edx,0x10(%ebp)
 7ae:	85 c0                	test   %eax,%eax
 7b0:	7f dc                	jg     78e <memmove+0x14>
  return vdst;
 7b2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 7b5:	c9                   	leave
 7b6:	c3                   	ret

000007b7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 7b7:	b8 01 00 00 00       	mov    $0x1,%eax
 7bc:	cd 40                	int    $0x40
 7be:	c3                   	ret

000007bf <exit>:
SYSCALL(exit)
 7bf:	b8 02 00 00 00       	mov    $0x2,%eax
 7c4:	cd 40                	int    $0x40
 7c6:	c3                   	ret

000007c7 <wait>:
SYSCALL(wait)
 7c7:	b8 03 00 00 00       	mov    $0x3,%eax
 7cc:	cd 40                	int    $0x40
 7ce:	c3                   	ret

000007cf <pipe>:
SYSCALL(pipe)
 7cf:	b8 04 00 00 00       	mov    $0x4,%eax
 7d4:	cd 40                	int    $0x40
 7d6:	c3                   	ret

000007d7 <read>:
SYSCALL(read)
 7d7:	b8 05 00 00 00       	mov    $0x5,%eax
 7dc:	cd 40                	int    $0x40
 7de:	c3                   	ret

000007df <write>:
SYSCALL(write)
 7df:	b8 10 00 00 00       	mov    $0x10,%eax
 7e4:	cd 40                	int    $0x40
 7e6:	c3                   	ret

000007e7 <close>:
SYSCALL(close)
 7e7:	b8 15 00 00 00       	mov    $0x15,%eax
 7ec:	cd 40                	int    $0x40
 7ee:	c3                   	ret

000007ef <kill>:
SYSCALL(kill)
 7ef:	b8 06 00 00 00       	mov    $0x6,%eax
 7f4:	cd 40                	int    $0x40
 7f6:	c3                   	ret

000007f7 <exec>:
SYSCALL(exec)
 7f7:	b8 07 00 00 00       	mov    $0x7,%eax
 7fc:	cd 40                	int    $0x40
 7fe:	c3                   	ret

000007ff <open>:
SYSCALL(open)
 7ff:	b8 0f 00 00 00       	mov    $0xf,%eax
 804:	cd 40                	int    $0x40
 806:	c3                   	ret

00000807 <mknod>:
SYSCALL(mknod)
 807:	b8 11 00 00 00       	mov    $0x11,%eax
 80c:	cd 40                	int    $0x40
 80e:	c3                   	ret

0000080f <unlink>:
SYSCALL(unlink)
 80f:	b8 12 00 00 00       	mov    $0x12,%eax
 814:	cd 40                	int    $0x40
 816:	c3                   	ret

00000817 <fstat>:
SYSCALL(fstat)
 817:	b8 08 00 00 00       	mov    $0x8,%eax
 81c:	cd 40                	int    $0x40
 81e:	c3                   	ret

0000081f <link>:
SYSCALL(link)
 81f:	b8 13 00 00 00       	mov    $0x13,%eax
 824:	cd 40                	int    $0x40
 826:	c3                   	ret

00000827 <mkdir>:
SYSCALL(mkdir)
 827:	b8 14 00 00 00       	mov    $0x14,%eax
 82c:	cd 40                	int    $0x40
 82e:	c3                   	ret

0000082f <chdir>:
SYSCALL(chdir)
 82f:	b8 09 00 00 00       	mov    $0x9,%eax
 834:	cd 40                	int    $0x40
 836:	c3                   	ret

00000837 <dup>:
SYSCALL(dup)
 837:	b8 0a 00 00 00       	mov    $0xa,%eax
 83c:	cd 40                	int    $0x40
 83e:	c3                   	ret

0000083f <getpid>:
SYSCALL(getpid)
 83f:	b8 0b 00 00 00       	mov    $0xb,%eax
 844:	cd 40                	int    $0x40
 846:	c3                   	ret

00000847 <sbrk>:
SYSCALL(sbrk)
 847:	b8 0c 00 00 00       	mov    $0xc,%eax
 84c:	cd 40                	int    $0x40
 84e:	c3                   	ret

0000084f <sleep>:
SYSCALL(sleep)
 84f:	b8 0d 00 00 00       	mov    $0xd,%eax
 854:	cd 40                	int    $0x40
 856:	c3                   	ret

00000857 <uptime>:
SYSCALL(uptime)
 857:	b8 0e 00 00 00       	mov    $0xe,%eax
 85c:	cd 40                	int    $0x40
 85e:	c3                   	ret

0000085f <uthread_init>:
SYSCALL(uthread_init)
 85f:	b8 16 00 00 00       	mov    $0x16,%eax
 864:	cd 40                	int    $0x40
 866:	c3                   	ret

00000867 <printpt>:

SYSCALL(printpt)
 867:	b8 17 00 00 00       	mov    $0x17,%eax
 86c:	cd 40                	int    $0x40
 86e:	c3                   	ret

0000086f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 86f:	55                   	push   %ebp
 870:	89 e5                	mov    %esp,%ebp
 872:	83 ec 18             	sub    $0x18,%esp
 875:	8b 45 0c             	mov    0xc(%ebp),%eax
 878:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 87b:	83 ec 04             	sub    $0x4,%esp
 87e:	6a 01                	push   $0x1
 880:	8d 45 f4             	lea    -0xc(%ebp),%eax
 883:	50                   	push   %eax
 884:	ff 75 08             	push   0x8(%ebp)
 887:	e8 53 ff ff ff       	call   7df <write>
 88c:	83 c4 10             	add    $0x10,%esp
}
 88f:	90                   	nop
 890:	c9                   	leave
 891:	c3                   	ret

00000892 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 892:	55                   	push   %ebp
 893:	89 e5                	mov    %esp,%ebp
 895:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 898:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 89f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 8a3:	74 17                	je     8bc <printint+0x2a>
 8a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 8a9:	79 11                	jns    8bc <printint+0x2a>
    neg = 1;
 8ab:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 8b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 8b5:	f7 d8                	neg    %eax
 8b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8ba:	eb 06                	jmp    8c2 <printint+0x30>
  } else {
    x = xx;
 8bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 8bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 8c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 8c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
 8cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8cf:	ba 00 00 00 00       	mov    $0x0,%edx
 8d4:	f7 f1                	div    %ecx
 8d6:	89 d1                	mov    %edx,%ecx
 8d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8db:	8d 50 01             	lea    0x1(%eax),%edx
 8de:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8e1:	0f b6 91 3c 0f 00 00 	movzbl 0xf3c(%ecx),%edx
 8e8:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 8ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
 8ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8f2:	ba 00 00 00 00       	mov    $0x0,%edx
 8f7:	f7 f1                	div    %ecx
 8f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8fc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 900:	75 c7                	jne    8c9 <printint+0x37>
  if(neg)
 902:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 906:	74 2d                	je     935 <printint+0xa3>
    buf[i++] = '-';
 908:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90b:	8d 50 01             	lea    0x1(%eax),%edx
 90e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 911:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 916:	eb 1d                	jmp    935 <printint+0xa3>
    putc(fd, buf[i]);
 918:	8d 55 dc             	lea    -0x24(%ebp),%edx
 91b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91e:	01 d0                	add    %edx,%eax
 920:	0f b6 00             	movzbl (%eax),%eax
 923:	0f be c0             	movsbl %al,%eax
 926:	83 ec 08             	sub    $0x8,%esp
 929:	50                   	push   %eax
 92a:	ff 75 08             	push   0x8(%ebp)
 92d:	e8 3d ff ff ff       	call   86f <putc>
 932:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 935:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 939:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 93d:	79 d9                	jns    918 <printint+0x86>
}
 93f:	90                   	nop
 940:	90                   	nop
 941:	c9                   	leave
 942:	c3                   	ret

00000943 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 943:	55                   	push   %ebp
 944:	89 e5                	mov    %esp,%ebp
 946:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 949:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 950:	8d 45 0c             	lea    0xc(%ebp),%eax
 953:	83 c0 04             	add    $0x4,%eax
 956:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 959:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 960:	e9 59 01 00 00       	jmp    abe <printf+0x17b>
    c = fmt[i] & 0xff;
 965:	8b 55 0c             	mov    0xc(%ebp),%edx
 968:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96b:	01 d0                	add    %edx,%eax
 96d:	0f b6 00             	movzbl (%eax),%eax
 970:	0f be c0             	movsbl %al,%eax
 973:	25 ff 00 00 00       	and    $0xff,%eax
 978:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 97b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 97f:	75 2c                	jne    9ad <printf+0x6a>
      if(c == '%'){
 981:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 985:	75 0c                	jne    993 <printf+0x50>
        state = '%';
 987:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 98e:	e9 27 01 00 00       	jmp    aba <printf+0x177>
      } else {
        putc(fd, c);
 993:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 996:	0f be c0             	movsbl %al,%eax
 999:	83 ec 08             	sub    $0x8,%esp
 99c:	50                   	push   %eax
 99d:	ff 75 08             	push   0x8(%ebp)
 9a0:	e8 ca fe ff ff       	call   86f <putc>
 9a5:	83 c4 10             	add    $0x10,%esp
 9a8:	e9 0d 01 00 00       	jmp    aba <printf+0x177>
      }
    } else if(state == '%'){
 9ad:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 9b1:	0f 85 03 01 00 00    	jne    aba <printf+0x177>
      if(c == 'd'){
 9b7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 9bb:	75 1e                	jne    9db <printf+0x98>
        printint(fd, *ap, 10, 1);
 9bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9c0:	8b 00                	mov    (%eax),%eax
 9c2:	6a 01                	push   $0x1
 9c4:	6a 0a                	push   $0xa
 9c6:	50                   	push   %eax
 9c7:	ff 75 08             	push   0x8(%ebp)
 9ca:	e8 c3 fe ff ff       	call   892 <printint>
 9cf:	83 c4 10             	add    $0x10,%esp
        ap++;
 9d2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9d6:	e9 d8 00 00 00       	jmp    ab3 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 9db:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 9df:	74 06                	je     9e7 <printf+0xa4>
 9e1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 9e5:	75 1e                	jne    a05 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 9e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9ea:	8b 00                	mov    (%eax),%eax
 9ec:	6a 00                	push   $0x0
 9ee:	6a 10                	push   $0x10
 9f0:	50                   	push   %eax
 9f1:	ff 75 08             	push   0x8(%ebp)
 9f4:	e8 99 fe ff ff       	call   892 <printint>
 9f9:	83 c4 10             	add    $0x10,%esp
        ap++;
 9fc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a00:	e9 ae 00 00 00       	jmp    ab3 <printf+0x170>
      } else if(c == 's'){
 a05:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 a09:	75 43                	jne    a4e <printf+0x10b>
        s = (char*)*ap;
 a0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a0e:	8b 00                	mov    (%eax),%eax
 a10:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 a13:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 a17:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a1b:	75 25                	jne    a42 <printf+0xff>
          s = "(null)";
 a1d:	c7 45 f4 35 0f 00 00 	movl   $0xf35,-0xc(%ebp)
        while(*s != 0){
 a24:	eb 1c                	jmp    a42 <printf+0xff>
          putc(fd, *s);
 a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a29:	0f b6 00             	movzbl (%eax),%eax
 a2c:	0f be c0             	movsbl %al,%eax
 a2f:	83 ec 08             	sub    $0x8,%esp
 a32:	50                   	push   %eax
 a33:	ff 75 08             	push   0x8(%ebp)
 a36:	e8 34 fe ff ff       	call   86f <putc>
 a3b:	83 c4 10             	add    $0x10,%esp
          s++;
 a3e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a45:	0f b6 00             	movzbl (%eax),%eax
 a48:	84 c0                	test   %al,%al
 a4a:	75 da                	jne    a26 <printf+0xe3>
 a4c:	eb 65                	jmp    ab3 <printf+0x170>
        }
      } else if(c == 'c'){
 a4e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a52:	75 1d                	jne    a71 <printf+0x12e>
        putc(fd, *ap);
 a54:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a57:	8b 00                	mov    (%eax),%eax
 a59:	0f be c0             	movsbl %al,%eax
 a5c:	83 ec 08             	sub    $0x8,%esp
 a5f:	50                   	push   %eax
 a60:	ff 75 08             	push   0x8(%ebp)
 a63:	e8 07 fe ff ff       	call   86f <putc>
 a68:	83 c4 10             	add    $0x10,%esp
        ap++;
 a6b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a6f:	eb 42                	jmp    ab3 <printf+0x170>
      } else if(c == '%'){
 a71:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a75:	75 17                	jne    a8e <printf+0x14b>
        putc(fd, c);
 a77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a7a:	0f be c0             	movsbl %al,%eax
 a7d:	83 ec 08             	sub    $0x8,%esp
 a80:	50                   	push   %eax
 a81:	ff 75 08             	push   0x8(%ebp)
 a84:	e8 e6 fd ff ff       	call   86f <putc>
 a89:	83 c4 10             	add    $0x10,%esp
 a8c:	eb 25                	jmp    ab3 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a8e:	83 ec 08             	sub    $0x8,%esp
 a91:	6a 25                	push   $0x25
 a93:	ff 75 08             	push   0x8(%ebp)
 a96:	e8 d4 fd ff ff       	call   86f <putc>
 a9b:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 a9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 aa1:	0f be c0             	movsbl %al,%eax
 aa4:	83 ec 08             	sub    $0x8,%esp
 aa7:	50                   	push   %eax
 aa8:	ff 75 08             	push   0x8(%ebp)
 aab:	e8 bf fd ff ff       	call   86f <putc>
 ab0:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 ab3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 aba:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 abe:	8b 55 0c             	mov    0xc(%ebp),%edx
 ac1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac4:	01 d0                	add    %edx,%eax
 ac6:	0f b6 00             	movzbl (%eax),%eax
 ac9:	84 c0                	test   %al,%al
 acb:	0f 85 94 fe ff ff    	jne    965 <printf+0x22>
    }
  }
}
 ad1:	90                   	nop
 ad2:	90                   	nop
 ad3:	c9                   	leave
 ad4:	c3                   	ret

00000ad5 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ad5:	55                   	push   %ebp
 ad6:	89 e5                	mov    %esp,%ebp
 ad8:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 adb:	8b 45 08             	mov    0x8(%ebp),%eax
 ade:	83 e8 08             	sub    $0x8,%eax
 ae1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ae4:	a1 28 50 01 00       	mov    0x15028,%eax
 ae9:	89 45 fc             	mov    %eax,-0x4(%ebp)
 aec:	eb 24                	jmp    b12 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 aee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af1:	8b 00                	mov    (%eax),%eax
 af3:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 af6:	72 12                	jb     b0a <free+0x35>
 af8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 afb:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 afe:	72 24                	jb     b24 <free+0x4f>
 b00:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b03:	8b 00                	mov    (%eax),%eax
 b05:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b08:	72 1a                	jb     b24 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b0d:	8b 00                	mov    (%eax),%eax
 b0f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 b12:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b15:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 b18:	73 d4                	jae    aee <free+0x19>
 b1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b1d:	8b 00                	mov    (%eax),%eax
 b1f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b22:	73 ca                	jae    aee <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 b24:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b27:	8b 40 04             	mov    0x4(%eax),%eax
 b2a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b31:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b34:	01 c2                	add    %eax,%edx
 b36:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b39:	8b 00                	mov    (%eax),%eax
 b3b:	39 c2                	cmp    %eax,%edx
 b3d:	75 24                	jne    b63 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 b3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b42:	8b 50 04             	mov    0x4(%eax),%edx
 b45:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b48:	8b 00                	mov    (%eax),%eax
 b4a:	8b 40 04             	mov    0x4(%eax),%eax
 b4d:	01 c2                	add    %eax,%edx
 b4f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b52:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b55:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b58:	8b 00                	mov    (%eax),%eax
 b5a:	8b 10                	mov    (%eax),%edx
 b5c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b5f:	89 10                	mov    %edx,(%eax)
 b61:	eb 0a                	jmp    b6d <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 b63:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b66:	8b 10                	mov    (%eax),%edx
 b68:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b6b:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b70:	8b 40 04             	mov    0x4(%eax),%eax
 b73:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b7d:	01 d0                	add    %edx,%eax
 b7f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b82:	75 20                	jne    ba4 <free+0xcf>
    p->s.size += bp->s.size;
 b84:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b87:	8b 50 04             	mov    0x4(%eax),%edx
 b8a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b8d:	8b 40 04             	mov    0x4(%eax),%eax
 b90:	01 c2                	add    %eax,%edx
 b92:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b95:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b98:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b9b:	8b 10                	mov    (%eax),%edx
 b9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ba0:	89 10                	mov    %edx,(%eax)
 ba2:	eb 08                	jmp    bac <free+0xd7>
  } else
    p->s.ptr = bp;
 ba4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ba7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 baa:	89 10                	mov    %edx,(%eax)
  freep = p;
 bac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 baf:	a3 28 50 01 00       	mov    %eax,0x15028
}
 bb4:	90                   	nop
 bb5:	c9                   	leave
 bb6:	c3                   	ret

00000bb7 <morecore>:

static Header*
morecore(uint nu)
{
 bb7:	55                   	push   %ebp
 bb8:	89 e5                	mov    %esp,%ebp
 bba:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 bbd:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 bc4:	77 07                	ja     bcd <morecore+0x16>
    nu = 4096;
 bc6:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 bcd:	8b 45 08             	mov    0x8(%ebp),%eax
 bd0:	c1 e0 03             	shl    $0x3,%eax
 bd3:	83 ec 0c             	sub    $0xc,%esp
 bd6:	50                   	push   %eax
 bd7:	e8 6b fc ff ff       	call   847 <sbrk>
 bdc:	83 c4 10             	add    $0x10,%esp
 bdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 be2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 be6:	75 07                	jne    bef <morecore+0x38>
    return 0;
 be8:	b8 00 00 00 00       	mov    $0x0,%eax
 bed:	eb 26                	jmp    c15 <morecore+0x5e>
  hp = (Header*)p;
 bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bf2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bf8:	8b 55 08             	mov    0x8(%ebp),%edx
 bfb:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c01:	83 c0 08             	add    $0x8,%eax
 c04:	83 ec 0c             	sub    $0xc,%esp
 c07:	50                   	push   %eax
 c08:	e8 c8 fe ff ff       	call   ad5 <free>
 c0d:	83 c4 10             	add    $0x10,%esp
  return freep;
 c10:	a1 28 50 01 00       	mov    0x15028,%eax
}
 c15:	c9                   	leave
 c16:	c3                   	ret

00000c17 <malloc>:

void*
malloc(uint nbytes)
{
 c17:	55                   	push   %ebp
 c18:	89 e5                	mov    %esp,%ebp
 c1a:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c1d:	8b 45 08             	mov    0x8(%ebp),%eax
 c20:	83 c0 07             	add    $0x7,%eax
 c23:	c1 e8 03             	shr    $0x3,%eax
 c26:	83 c0 01             	add    $0x1,%eax
 c29:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 c2c:	a1 28 50 01 00       	mov    0x15028,%eax
 c31:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c34:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c38:	75 23                	jne    c5d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 c3a:	c7 45 f0 20 50 01 00 	movl   $0x15020,-0x10(%ebp)
 c41:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c44:	a3 28 50 01 00       	mov    %eax,0x15028
 c49:	a1 28 50 01 00       	mov    0x15028,%eax
 c4e:	a3 20 50 01 00       	mov    %eax,0x15020
    base.s.size = 0;
 c53:	c7 05 24 50 01 00 00 	movl   $0x0,0x15024
 c5a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c60:	8b 00                	mov    (%eax),%eax
 c62:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c68:	8b 40 04             	mov    0x4(%eax),%eax
 c6b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c6e:	72 4d                	jb     cbd <malloc+0xa6>
      if(p->s.size == nunits)
 c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c73:	8b 40 04             	mov    0x4(%eax),%eax
 c76:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 c79:	75 0c                	jne    c87 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c7e:	8b 10                	mov    (%eax),%edx
 c80:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c83:	89 10                	mov    %edx,(%eax)
 c85:	eb 26                	jmp    cad <malloc+0x96>
      else {
        p->s.size -= nunits;
 c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c8a:	8b 40 04             	mov    0x4(%eax),%eax
 c8d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c90:	89 c2                	mov    %eax,%edx
 c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c95:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c9b:	8b 40 04             	mov    0x4(%eax),%eax
 c9e:	c1 e0 03             	shl    $0x3,%eax
 ca1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ca7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 caa:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cb0:	a3 28 50 01 00       	mov    %eax,0x15028
      return (void*)(p + 1);
 cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cb8:	83 c0 08             	add    $0x8,%eax
 cbb:	eb 3b                	jmp    cf8 <malloc+0xe1>
    }
    if(p == freep)
 cbd:	a1 28 50 01 00       	mov    0x15028,%eax
 cc2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 cc5:	75 1e                	jne    ce5 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 cc7:	83 ec 0c             	sub    $0xc,%esp
 cca:	ff 75 ec             	push   -0x14(%ebp)
 ccd:	e8 e5 fe ff ff       	call   bb7 <morecore>
 cd2:	83 c4 10             	add    $0x10,%esp
 cd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
 cd8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 cdc:	75 07                	jne    ce5 <malloc+0xce>
        return 0;
 cde:	b8 00 00 00 00       	mov    $0x0,%eax
 ce3:	eb 13                	jmp    cf8 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ce8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cee:	8b 00                	mov    (%eax),%eax
 cf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 cf3:	e9 6d ff ff ff       	jmp    c65 <malloc+0x4e>
  }
}
 cf8:	c9                   	leave
 cf9:	c3                   	ret
