
_uthread2:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_schedule>:

const char* state_str[] = { "FREE", "RUNNING", "RUNNABLE", "WAIT" };

static void 
thread_schedule(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  int curr_index = current_thread - all_thread;
   6:	a1 20 0f 00 00       	mov    0xf20,%eax
   b:	2d 40 0f 00 00       	sub    $0xf40,%eax
  10:	c1 f8 03             	sar    $0x3,%eax
  13:	69 c0 01 fc 0f c0    	imul   $0xc00ffc01,%eax,%eax
  19:	89 45 f0             	mov    %eax,-0x10(%ebp)
  next_thread = 0;
  1c:	c7 05 24 0f 00 00 00 	movl   $0x0,0xf24
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
  66:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
  6c:	05 3c 2f 00 00       	add    $0x2f3c,%eax
  71:	8b 00                	mov    (%eax),%eax
  73:	83 f8 02             	cmp    $0x2,%eax
  76:	75 1b                	jne    93 <thread_schedule+0x93>
  78:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  7c:	74 15                	je     93 <thread_schedule+0x93>
      next_thread = &all_thread[i];
  7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  81:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
  87:	05 40 0f 00 00       	add    $0xf40,%eax
  8c:	a3 24 0f 00 00       	mov    %eax,0xf24
      break;
  91:	eb 0a                	jmp    9d <thread_schedule+0x9d>
  for (int count = 1; count <= MAX_THREAD; count++) {
  93:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  97:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
  9b:	7e 92                	jle    2f <thread_schedule+0x2f>
    }
  }

  if (next_thread == 0) {
  9d:	a1 24 0f 00 00       	mov    0xf24,%eax
  a2:	85 c0                	test   %eax,%eax
  a4:	75 17                	jne    bd <thread_schedule+0xbd>
    printf(2, "thread_schedule: no runnable threads\n");
  a6:	83 ec 08             	sub    $0x8,%esp
  a9:	68 ec 0c 00 00       	push   $0xcec
  ae:	6a 02                	push   $0x2
  b0:	e8 62 08 00 00       	call   917 <printf>
  b5:	83 c4 10             	add    $0x10,%esp
    exit();
  b8:	e8 de 06 00 00       	call   79b <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  bd:	8b 15 20 0f 00 00    	mov    0xf20,%edx
  c3:	a1 24 0f 00 00       	mov    0xf24,%eax
  c8:	39 c2                	cmp    %eax,%edx
  ca:	74 34                	je     100 <thread_schedule+0x100>
    next_thread->state = RUNNING;
  cc:	a1 24 0f 00 00       	mov    0xf24,%eax
  d1:	c7 80 fc 1f 00 00 01 	movl   $0x1,0x1ffc(%eax)
  d8:	00 00 00 
    if (current_thread->state != FREE)
  db:	a1 20 0f 00 00       	mov    0xf20,%eax
  e0:	8b 80 fc 1f 00 00    	mov    0x1ffc(%eax),%eax
  e6:	85 c0                	test   %eax,%eax
  e8:	74 0f                	je     f9 <thread_schedule+0xf9>
      current_thread->state = RUNNABLE;
  ea:	a1 20 0f 00 00       	mov    0xf20,%eax
  ef:	c7 80 fc 1f 00 00 02 	movl   $0x2,0x1ffc(%eax)
  f6:	00 00 00 
    thread_switch();
  f9:	e8 26 04 00 00       	call   524 <thread_switch>
  } else
    next_thread = 0;
}
  fe:	eb 0a                	jmp    10a <thread_schedule+0x10a>
    next_thread = 0;
 100:	c7 05 24 0f 00 00 00 	movl   $0x0,0xf24
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
 113:	c7 05 20 0f 00 00 40 	movl   $0xf40,0xf20
 11a:	0f 00 00 
  current_thread->state = RUNNING;
 11d:	a1 20 0f 00 00       	mov    0xf20,%eax
 122:	c7 80 fc 1f 00 00 01 	movl   $0x1,0x1ffc(%eax)
 129:	00 00 00 
  current_thread->tid=0;
 12c:	a1 20 0f 00 00       	mov    0xf20,%eax
 131:	c7 80 00 20 00 00 00 	movl   $0x0,0x2000(%eax)
 138:	00 00 00 
  current_thread->ptid=0;
 13b:	a1 20 0f 00 00       	mov    0xf20,%eax
 140:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 147:	00 00 00 

  uthread_init((int)thread_schedule);
 14a:	b8 00 00 00 00       	mov    $0x0,%eax
 14f:	83 ec 0c             	sub    $0xc,%esp
 152:	50                   	push   %eax
 153:	e8 e3 06 00 00       	call   83b <uthread_init>
 158:	83 c4 10             	add    $0x10,%esp
}
 15b:	90                   	nop
 15c:	c9                   	leave
 15d:	c3                   	ret

0000015e <thread_create>:

void 
thread_create(void (*func)())
{
 15e:	55                   	push   %ebp
 15f:	89 e5                	mov    %esp,%ebp
 161:	53                   	push   %ebx
 162:	83 ec 14             	sub    $0x14,%esp
  printf(1,"thread_create\n");
 165:	83 ec 08             	sub    $0x8,%esp
 168:	68 12 0d 00 00       	push   $0xd12
 16d:	6a 01                	push   $0x1
 16f:	e8 a3 07 00 00       	call   917 <printf>
 174:	83 c4 10             	add    $0x10,%esp
  
  thread_p t;
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 177:	c7 45 f4 40 0f 00 00 	movl   $0xf40,-0xc(%ebp)
 17e:	eb 14                	jmp    194 <thread_create+0x36>
    if (t->state == FREE) break;
 180:	8b 45 f4             	mov    -0xc(%ebp),%eax
 183:	8b 80 fc 1f 00 00    	mov    0x1ffc(%eax),%eax
 189:	85 c0                	test   %eax,%eax
 18b:	74 13                	je     1a0 <thread_create+0x42>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 18d:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
 194:	b8 90 4f 01 00       	mov    $0x14f90,%eax
 199:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 19c:	72 e2                	jb     180 <thread_create+0x22>
 19e:	eb 01                	jmp    1a1 <thread_create+0x43>
    if (t->state == FREE) break;
 1a0:	90                   	nop
  }

  t->sp = (int)(t->stack + STACK_SIZE);
 1a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a4:	83 c0 04             	add    $0x4,%eax
 1a7:	05 f8 1f 00 00       	add    $0x1ff8,%eax
 1ac:	89 c2                	mov    %eax,%edx
 1ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b1:	89 10                	mov    %edx,(%eax)

  t->sp -= 4;
 1b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b6:	8b 00                	mov    (%eax),%eax
 1b8:	8d 50 fc             	lea    -0x4(%eax),%edx
 1bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1be:	89 10                	mov    %edx,(%eax)
  *(int *)(t->sp) = (int)func;  // 올바른 ret 주소 설정
 1c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c3:	8b 00                	mov    (%eax),%eax
 1c5:	89 c2                	mov    %eax,%edx
 1c7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ca:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                  // context는 그 아래
 1cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cf:	8b 00                	mov    (%eax),%eax
 1d1:	8d 50 e0             	lea    -0x20(%eax),%edx
 1d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d7:	89 10                	mov    %edx,(%eax)

  t->tid = t - all_thread;
 1d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1dc:	2d 40 0f 00 00       	sub    $0xf40,%eax
 1e1:	c1 f8 03             	sar    $0x3,%eax
 1e4:	69 c0 01 fc 0f c0    	imul   $0xc00ffc01,%eax,%eax
 1ea:	89 c2                	mov    %eax,%edx
 1ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ef:	89 90 00 20 00 00    	mov    %edx,0x2000(%eax)
  t->ptid = current_thread->tid;
 1f5:	a1 20 0f 00 00       	mov    0xf20,%eax
 1fa:	8b 90 00 20 00 00    	mov    0x2000(%eax),%edx
 200:	8b 45 f4             	mov    -0xc(%ebp),%eax
 203:	89 90 04 20 00 00    	mov    %edx,0x2004(%eax)
  t->state = RUNNABLE;
 209:	8b 45 f4             	mov    -0xc(%ebp),%eax
 20c:	c7 80 fc 1f 00 00 02 	movl   $0x2,0x1ffc(%eax)
 213:	00 00 00 

  printf(1, "[create] tid=%d func=0x%x state=%d (%s)\n", t->tid, (unsigned int)func, t->state, state_str[t->state]);
 216:	8b 45 f4             	mov    -0xc(%ebp),%eax
 219:	8b 80 fc 1f 00 00    	mov    0x1ffc(%eax),%eax
 21f:	8b 1c 85 f0 0e 00 00 	mov    0xef0(,%eax,4),%ebx
 226:	8b 45 f4             	mov    -0xc(%ebp),%eax
 229:	8b 88 fc 1f 00 00    	mov    0x1ffc(%eax),%ecx
 22f:	8b 55 08             	mov    0x8(%ebp),%edx
 232:	8b 45 f4             	mov    -0xc(%ebp),%eax
 235:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 23b:	83 ec 08             	sub    $0x8,%esp
 23e:	53                   	push   %ebx
 23f:	51                   	push   %ecx
 240:	52                   	push   %edx
 241:	50                   	push   %eax
 242:	68 24 0d 00 00       	push   $0xd24
 247:	6a 01                	push   $0x1
 249:	e8 c9 06 00 00       	call   917 <printf>
 24e:	83 c4 20             	add    $0x20,%esp
}
 251:	90                   	nop
 252:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 255:	c9                   	leave
 256:	c3                   	ret

00000257 <thread_join_all>:

static void thread_join_all(void) {
 257:	55                   	push   %ebp
 258:	89 e5                	mov    %esp,%ebp
 25a:	83 ec 18             	sub    $0x18,%esp
  printf(1, "[thread_join_all] tid=%d waiting for children\n", current_thread->tid);
 25d:	a1 20 0f 00 00       	mov    0xf20,%eax
 262:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 268:	83 ec 04             	sub    $0x4,%esp
 26b:	50                   	push   %eax
 26c:	68 50 0d 00 00       	push   $0xd50
 271:	6a 01                	push   $0x1
 273:	e8 9f 06 00 00       	call   917 <printf>
 278:	83 c4 10             	add    $0x10,%esp
  
  // 현재 스레드가 대기 상태로 전환
  current_thread->state = WAIT;
 27b:	a1 20 0f 00 00       	mov    0xf20,%eax
 280:	c7 80 fc 1f 00 00 03 	movl   $0x3,0x1ffc(%eax)
 287:	00 00 00 
  
  while (1) {
    int child_alive = 0;
 28a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    // 자식 스레드 확인
    for (int i = 0; i < MAX_THREAD; i++) {
 291:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 298:	eb 40                	jmp    2da <thread_join_all+0x83>
      if (all_thread[i].state != FREE &&
 29a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 29d:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
 2a3:	05 3c 2f 00 00       	add    $0x2f3c,%eax
 2a8:	8b 00                	mov    (%eax),%eax
 2aa:	85 c0                	test   %eax,%eax
 2ac:	74 28                	je     2d6 <thread_join_all+0x7f>
          all_thread[i].ptid == current_thread->tid) {
 2ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2b1:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
 2b7:	05 44 2f 00 00       	add    $0x2f44,%eax
 2bc:	8b 10                	mov    (%eax),%edx
 2be:	a1 20 0f 00 00       	mov    0xf20,%eax
 2c3:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
      if (all_thread[i].state != FREE &&
 2c9:	39 c2                	cmp    %eax,%edx
 2cb:	75 09                	jne    2d6 <thread_join_all+0x7f>
        child_alive = 1;
 2cd:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        break;
 2d4:	eb 0a                	jmp    2e0 <thread_join_all+0x89>
    for (int i = 0; i < MAX_THREAD; i++) {
 2d6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 2da:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
 2de:	7e ba                	jle    29a <thread_join_all+0x43>
      }
    }

    // 모든 자식 스레드가 종료되면 대기 종료
    if (!child_alive) {
 2e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2e4:	75 11                	jne    2f7 <thread_join_all+0xa0>
      current_thread->state = RUNNABLE;  // 대기 상태에서 실행 가능 상태로 변경
 2e6:	a1 20 0f 00 00       	mov    0xf20,%eax
 2eb:	c7 80 fc 1f 00 00 02 	movl   $0x2,0x1ffc(%eax)
 2f2:	00 00 00 
      break;
 2f5:	eb 6b                	jmp    362 <thread_join_all+0x10b>
    }

    // 실행 가능한 스레드 확인
    int has_runnable = 0;
 2f7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    for (int i = 0; i < MAX_THREAD; i++) {
 2fe:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
 305:	eb 22                	jmp    329 <thread_join_all+0xd2>
      if (all_thread[i].state == RUNNABLE) {
 307:	8b 45 e8             	mov    -0x18(%ebp),%eax
 30a:	69 c0 08 20 00 00    	imul   $0x2008,%eax,%eax
 310:	05 3c 2f 00 00       	add    $0x2f3c,%eax
 315:	8b 00                	mov    (%eax),%eax
 317:	83 f8 02             	cmp    $0x2,%eax
 31a:	75 09                	jne    325 <thread_join_all+0xce>
        has_runnable = 1;
 31c:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
        break;
 323:	eb 0a                	jmp    32f <thread_join_all+0xd8>
    for (int i = 0; i < MAX_THREAD; i++) {
 325:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
 329:	83 7d e8 09          	cmpl   $0x9,-0x18(%ebp)
 32d:	7e d8                	jle    307 <thread_join_all+0xb0>
      }
    }

    // 실행 가능한 스레드가 없으면 종료
    if (!has_runnable) {
 32f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 333:	75 23                	jne    358 <thread_join_all+0x101>
      printf(1, "[join_all] No runnable threads left, exiting loop early\n");
 335:	83 ec 08             	sub    $0x8,%esp
 338:	68 80 0d 00 00       	push   $0xd80
 33d:	6a 01                	push   $0x1
 33f:	e8 d3 05 00 00       	call   917 <printf>
 344:	83 c4 10             	add    $0x10,%esp
      current_thread->state = RUNNABLE;  // 대기 상태에서 실행 가능 상태로 변경
 347:	a1 20 0f 00 00       	mov    0xf20,%eax
 34c:	c7 80 fc 1f 00 00 02 	movl   $0x2,0x1ffc(%eax)
 353:	00 00 00 
      break;
 356:	eb 0a                	jmp    362 <thread_join_all+0x10b>
    }

    // 다른 스레드로 전환
    thread_schedule();
 358:	e8 a3 fc ff ff       	call   0 <thread_schedule>
  while (1) {
 35d:	e9 28 ff ff ff       	jmp    28a <thread_join_all+0x33>
  }
  
  printf(1, "[thread_join_all] tid=%d all children finished\n", current_thread->tid);
 362:	a1 20 0f 00 00       	mov    0xf20,%eax
 367:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 36d:	83 ec 04             	sub    $0x4,%esp
 370:	50                   	push   %eax
 371:	68 bc 0d 00 00       	push   $0xdbc
 376:	6a 01                	push   $0x1
 378:	e8 9a 05 00 00       	call   917 <printf>
 37d:	83 c4 10             	add    $0x10,%esp
}
 380:	90                   	nop
 381:	c9                   	leave
 382:	c3                   	ret

00000383 <child_thread>:

static int global_count = 0;

static void 
child_thread(void)
{
 383:	55                   	push   %ebp
 384:	89 e5                	mov    %esp,%ebp
 386:	83 ec 08             	sub    $0x8,%esp
  printf(1, "[child] started: tid=%d, ptid=%d\n", current_thread->tid, current_thread->ptid);
 389:	a1 20 0f 00 00       	mov    0xf20,%eax
 38e:	8b 90 04 20 00 00    	mov    0x2004(%eax),%edx
 394:	a1 20 0f 00 00       	mov    0xf20,%eax
 399:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 39f:	52                   	push   %edx
 3a0:	50                   	push   %eax
 3a1:	68 ec 0d 00 00       	push   $0xdec
 3a6:	6a 01                	push   $0x1
 3a8:	e8 6a 05 00 00       	call   917 <printf>
 3ad:	83 c4 10             	add    $0x10,%esp
  while (1) {
    if (global_count >= 10) {
 3b0:	a1 90 4f 01 00       	mov    0x14f90,%eax
 3b5:	83 f8 09             	cmp    $0x9,%eax
 3b8:	7e 0a                	jle    3c4 <child_thread+0x41>
      thread_schedule();
 3ba:	e8 41 fc ff ff       	call   0 <thread_schedule>
      continue;
 3bf:	e9 ab 00 00 00       	jmp    46f <child_thread+0xec>
    }
    printf(1, "[child] child thread 0x%x\n", (int) current_thread);
 3c4:	a1 20 0f 00 00       	mov    0xf20,%eax
 3c9:	83 ec 04             	sub    $0x4,%esp
 3cc:	50                   	push   %eax
 3cd:	68 0e 0e 00 00       	push   $0xe0e
 3d2:	6a 01                	push   $0x1
 3d4:	e8 3e 05 00 00       	call   917 <printf>
 3d9:	83 c4 10             	add    $0x10,%esp
    printf(1, "[child] child thread_schedule : tid=%d, ptid=%d\n", current_thread->tid, current_thread->ptid);
 3dc:	a1 20 0f 00 00       	mov    0xf20,%eax
 3e1:	8b 90 04 20 00 00    	mov    0x2004(%eax),%edx
 3e7:	a1 20 0f 00 00       	mov    0xf20,%eax
 3ec:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 3f2:	52                   	push   %edx
 3f3:	50                   	push   %eax
 3f4:	68 2c 0e 00 00       	push   $0xe2c
 3f9:	6a 01                	push   $0x1
 3fb:	e8 17 05 00 00       	call   917 <printf>
 400:	83 c4 10             	add    $0x10,%esp
    global_count++;
 403:	a1 90 4f 01 00       	mov    0x14f90,%eax
 408:	83 c0 01             	add    $0x1,%eax
 40b:	a3 90 4f 01 00       	mov    %eax,0x14f90
    if (global_count >= 10) {
 410:	a1 90 4f 01 00       	mov    0x14f90,%eax
 415:	83 f8 09             	cmp    $0x9,%eax
 418:	7e 50                	jle    46a <child_thread+0xe7>
      current_thread->state = FREE;
 41a:	a1 20 0f 00 00       	mov    0xf20,%eax
 41f:	c7 80 fc 1f 00 00 00 	movl   $0x0,0x1ffc(%eax)
 426:	00 00 00 
      printf(1, "[child] tid=%d marking self FREE\n", current_thread->tid);
 429:	a1 20 0f 00 00       	mov    0xf20,%eax
 42e:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 434:	83 ec 04             	sub    $0x4,%esp
 437:	50                   	push   %eax
 438:	68 60 0e 00 00       	push   $0xe60
 43d:	6a 01                	push   $0x1
 43f:	e8 d3 04 00 00       	call   917 <printf>
 444:	83 c4 10             	add    $0x10,%esp
      printf(1, "[child] child thread: exit\n");
 447:	83 ec 08             	sub    $0x8,%esp
 44a:	68 82 0e 00 00       	push   $0xe82
 44f:	6a 01                	push   $0x1
 451:	e8 c1 04 00 00       	call   917 <printf>
 456:	83 c4 10             	add    $0x10,%esp
      global_count = 0;
 459:	c7 05 90 4f 01 00 00 	movl   $0x0,0x14f90
 460:	00 00 00 
      thread_schedule();
 463:	e8 98 fb ff ff       	call   0 <thread_schedule>
      break;
 468:	eb 0a                	jmp    474 <child_thread+0xf1>
    }

    thread_schedule();
 46a:	e8 91 fb ff ff       	call   0 <thread_schedule>
    if (global_count >= 10) {
 46f:	e9 3c ff ff ff       	jmp    3b0 <child_thread+0x2d>
  }
  
}
 474:	90                   	nop
 475:	c9                   	leave
 476:	c3                   	ret

00000477 <mythread>:

static void 
mythread(void)
{
 477:	55                   	push   %ebp
 478:	89 e5                	mov    %esp,%ebp
 47a:	83 ec 18             	sub    $0x18,%esp
  int i;
  printf(1, "[parent] mythread tid=%d creating children...\n", current_thread->tid);
 47d:	a1 20 0f 00 00       	mov    0xf20,%eax
 482:	8b 80 00 20 00 00    	mov    0x2000(%eax),%eax
 488:	83 ec 04             	sub    $0x4,%esp
 48b:	50                   	push   %eax
 48c:	68 a0 0e 00 00       	push   $0xea0
 491:	6a 01                	push   $0x1
 493:	e8 7f 04 00 00       	call   917 <printf>
 498:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 49b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 4a2:	eb 14                	jmp    4b8 <mythread+0x41>
    thread_create(child_thread);
 4a4:	83 ec 0c             	sub    $0xc,%esp
 4a7:	68 83 03 00 00       	push   $0x383
 4ac:	e8 ad fc ff ff       	call   15e <thread_create>
 4b1:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 5; i++) {
 4b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 4b8:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
 4bc:	7e e6                	jle    4a4 <mythread+0x2d>
  }
  thread_join_all();
 4be:	e8 94 fd ff ff       	call   257 <thread_join_all>
  printf(1, "[parent] mythread done\n");
 4c3:	83 ec 08             	sub    $0x8,%esp
 4c6:	68 cf 0e 00 00       	push   $0xecf
 4cb:	6a 01                	push   $0x1
 4cd:	e8 45 04 00 00       	call   917 <printf>
 4d2:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 4d5:	a1 20 0f 00 00       	mov    0xf20,%eax
 4da:	c7 80 fc 1f 00 00 00 	movl   $0x0,0x1ffc(%eax)
 4e1:	00 00 00 
  thread_schedule();
 4e4:	e8 17 fb ff ff       	call   0 <thread_schedule>
}
 4e9:	90                   	nop
 4ea:	c9                   	leave
 4eb:	c3                   	ret

000004ec <main>:


int 
main(int argc, char *argv[]) 
{
 4ec:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 4f0:	83 e4 f0             	and    $0xfffffff0,%esp
 4f3:	ff 71 fc             	push   -0x4(%ecx)
 4f6:	55                   	push   %ebp
 4f7:	89 e5                	mov    %esp,%ebp
 4f9:	51                   	push   %ecx
 4fa:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 4fd:	e8 0b fc ff ff       	call   10d <thread_init>
  thread_create(mythread);
 502:	83 ec 0c             	sub    $0xc,%esp
 505:	68 77 04 00 00       	push   $0x477
 50a:	e8 4f fc ff ff       	call   15e <thread_create>
 50f:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 512:	e8 e9 fa ff ff       	call   0 <thread_schedule>
  return 0;
 517:	b8 00 00 00 00       	mov    $0x0,%eax
 51c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 51f:	c9                   	leave
 520:	8d 61 fc             	lea    -0x4(%ecx),%esp
 523:	c3                   	ret

00000524 <thread_switch>:
         */
    .text
    .globl thread_switch
thread_switch:

    pushal
 524:	60                   	pusha

    movl current_thread, %eax
 525:	a1 20 0f 00 00       	mov    0xf20,%eax
    movl %esp, (%eax)
 52a:	89 20                	mov    %esp,(%eax)

    movl next_thread, %eax
 52c:	a1 24 0f 00 00       	mov    0xf24,%eax
    movl (%eax), %esp
 531:	8b 20                	mov    (%eax),%esp
    # esp = t1.주소

    movl %eax, current_thread
 533:	a3 20 0f 00 00       	mov    %eax,0xf20

    // 레지스터 복구
    popal
 538:	61                   	popa

    movl $0, next_thread
 539:	c7 05 24 0f 00 00 00 	movl   $0x0,0xf24
 540:	00 00 00 
    
 543:	c3                   	ret

00000544 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 544:	55                   	push   %ebp
 545:	89 e5                	mov    %esp,%ebp
 547:	57                   	push   %edi
 548:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 549:	8b 4d 08             	mov    0x8(%ebp),%ecx
 54c:	8b 55 10             	mov    0x10(%ebp),%edx
 54f:	8b 45 0c             	mov    0xc(%ebp),%eax
 552:	89 cb                	mov    %ecx,%ebx
 554:	89 df                	mov    %ebx,%edi
 556:	89 d1                	mov    %edx,%ecx
 558:	fc                   	cld
 559:	f3 aa                	rep stos %al,%es:(%edi)
 55b:	89 ca                	mov    %ecx,%edx
 55d:	89 fb                	mov    %edi,%ebx
 55f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 562:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 565:	90                   	nop
 566:	5b                   	pop    %ebx
 567:	5f                   	pop    %edi
 568:	5d                   	pop    %ebp
 569:	c3                   	ret

0000056a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 56a:	55                   	push   %ebp
 56b:	89 e5                	mov    %esp,%ebp
 56d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 570:	8b 45 08             	mov    0x8(%ebp),%eax
 573:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 576:	90                   	nop
 577:	8b 55 0c             	mov    0xc(%ebp),%edx
 57a:	8d 42 01             	lea    0x1(%edx),%eax
 57d:	89 45 0c             	mov    %eax,0xc(%ebp)
 580:	8b 45 08             	mov    0x8(%ebp),%eax
 583:	8d 48 01             	lea    0x1(%eax),%ecx
 586:	89 4d 08             	mov    %ecx,0x8(%ebp)
 589:	0f b6 12             	movzbl (%edx),%edx
 58c:	88 10                	mov    %dl,(%eax)
 58e:	0f b6 00             	movzbl (%eax),%eax
 591:	84 c0                	test   %al,%al
 593:	75 e2                	jne    577 <strcpy+0xd>
    ;
  return os;
 595:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 598:	c9                   	leave
 599:	c3                   	ret

0000059a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 59a:	55                   	push   %ebp
 59b:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 59d:	eb 08                	jmp    5a7 <strcmp+0xd>
    p++, q++;
 59f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 5a3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 5a7:	8b 45 08             	mov    0x8(%ebp),%eax
 5aa:	0f b6 00             	movzbl (%eax),%eax
 5ad:	84 c0                	test   %al,%al
 5af:	74 10                	je     5c1 <strcmp+0x27>
 5b1:	8b 45 08             	mov    0x8(%ebp),%eax
 5b4:	0f b6 10             	movzbl (%eax),%edx
 5b7:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ba:	0f b6 00             	movzbl (%eax),%eax
 5bd:	38 c2                	cmp    %al,%dl
 5bf:	74 de                	je     59f <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 5c1:	8b 45 08             	mov    0x8(%ebp),%eax
 5c4:	0f b6 00             	movzbl (%eax),%eax
 5c7:	0f b6 d0             	movzbl %al,%edx
 5ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 5cd:	0f b6 00             	movzbl (%eax),%eax
 5d0:	0f b6 c0             	movzbl %al,%eax
 5d3:	29 c2                	sub    %eax,%edx
 5d5:	89 d0                	mov    %edx,%eax
}
 5d7:	5d                   	pop    %ebp
 5d8:	c3                   	ret

000005d9 <strlen>:

uint
strlen(char *s)
{
 5d9:	55                   	push   %ebp
 5da:	89 e5                	mov    %esp,%ebp
 5dc:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 5df:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 5e6:	eb 04                	jmp    5ec <strlen+0x13>
 5e8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 5ec:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5ef:	8b 45 08             	mov    0x8(%ebp),%eax
 5f2:	01 d0                	add    %edx,%eax
 5f4:	0f b6 00             	movzbl (%eax),%eax
 5f7:	84 c0                	test   %al,%al
 5f9:	75 ed                	jne    5e8 <strlen+0xf>
    ;
  return n;
 5fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 5fe:	c9                   	leave
 5ff:	c3                   	ret

00000600 <memset>:

void*
memset(void *dst, int c, uint n)
{
 600:	55                   	push   %ebp
 601:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 603:	8b 45 10             	mov    0x10(%ebp),%eax
 606:	50                   	push   %eax
 607:	ff 75 0c             	push   0xc(%ebp)
 60a:	ff 75 08             	push   0x8(%ebp)
 60d:	e8 32 ff ff ff       	call   544 <stosb>
 612:	83 c4 0c             	add    $0xc,%esp
  return dst;
 615:	8b 45 08             	mov    0x8(%ebp),%eax
}
 618:	c9                   	leave
 619:	c3                   	ret

0000061a <strchr>:

char*
strchr(const char *s, char c)
{
 61a:	55                   	push   %ebp
 61b:	89 e5                	mov    %esp,%ebp
 61d:	83 ec 04             	sub    $0x4,%esp
 620:	8b 45 0c             	mov    0xc(%ebp),%eax
 623:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 626:	eb 14                	jmp    63c <strchr+0x22>
    if(*s == c)
 628:	8b 45 08             	mov    0x8(%ebp),%eax
 62b:	0f b6 00             	movzbl (%eax),%eax
 62e:	38 45 fc             	cmp    %al,-0x4(%ebp)
 631:	75 05                	jne    638 <strchr+0x1e>
      return (char*)s;
 633:	8b 45 08             	mov    0x8(%ebp),%eax
 636:	eb 13                	jmp    64b <strchr+0x31>
  for(; *s; s++)
 638:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 63c:	8b 45 08             	mov    0x8(%ebp),%eax
 63f:	0f b6 00             	movzbl (%eax),%eax
 642:	84 c0                	test   %al,%al
 644:	75 e2                	jne    628 <strchr+0xe>
  return 0;
 646:	b8 00 00 00 00       	mov    $0x0,%eax
}
 64b:	c9                   	leave
 64c:	c3                   	ret

0000064d <gets>:

char*
gets(char *buf, int max)
{
 64d:	55                   	push   %ebp
 64e:	89 e5                	mov    %esp,%ebp
 650:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 653:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 65a:	eb 42                	jmp    69e <gets+0x51>
    cc = read(0, &c, 1);
 65c:	83 ec 04             	sub    $0x4,%esp
 65f:	6a 01                	push   $0x1
 661:	8d 45 ef             	lea    -0x11(%ebp),%eax
 664:	50                   	push   %eax
 665:	6a 00                	push   $0x0
 667:	e8 47 01 00 00       	call   7b3 <read>
 66c:	83 c4 10             	add    $0x10,%esp
 66f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 672:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 676:	7e 33                	jle    6ab <gets+0x5e>
      break;
    buf[i++] = c;
 678:	8b 45 f4             	mov    -0xc(%ebp),%eax
 67b:	8d 50 01             	lea    0x1(%eax),%edx
 67e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 681:	89 c2                	mov    %eax,%edx
 683:	8b 45 08             	mov    0x8(%ebp),%eax
 686:	01 c2                	add    %eax,%edx
 688:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 68c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 68e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 692:	3c 0a                	cmp    $0xa,%al
 694:	74 16                	je     6ac <gets+0x5f>
 696:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 69a:	3c 0d                	cmp    $0xd,%al
 69c:	74 0e                	je     6ac <gets+0x5f>
  for(i=0; i+1 < max; ){
 69e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6a1:	83 c0 01             	add    $0x1,%eax
 6a4:	39 45 0c             	cmp    %eax,0xc(%ebp)
 6a7:	7f b3                	jg     65c <gets+0xf>
 6a9:	eb 01                	jmp    6ac <gets+0x5f>
      break;
 6ab:	90                   	nop
      break;
  }
  buf[i] = '\0';
 6ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
 6af:	8b 45 08             	mov    0x8(%ebp),%eax
 6b2:	01 d0                	add    %edx,%eax
 6b4:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 6b7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6ba:	c9                   	leave
 6bb:	c3                   	ret

000006bc <stat>:

int
stat(char *n, struct stat *st)
{
 6bc:	55                   	push   %ebp
 6bd:	89 e5                	mov    %esp,%ebp
 6bf:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6c2:	83 ec 08             	sub    $0x8,%esp
 6c5:	6a 00                	push   $0x0
 6c7:	ff 75 08             	push   0x8(%ebp)
 6ca:	e8 0c 01 00 00       	call   7db <open>
 6cf:	83 c4 10             	add    $0x10,%esp
 6d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 6d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6d9:	79 07                	jns    6e2 <stat+0x26>
    return -1;
 6db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 6e0:	eb 25                	jmp    707 <stat+0x4b>
  r = fstat(fd, st);
 6e2:	83 ec 08             	sub    $0x8,%esp
 6e5:	ff 75 0c             	push   0xc(%ebp)
 6e8:	ff 75 f4             	push   -0xc(%ebp)
 6eb:	e8 03 01 00 00       	call   7f3 <fstat>
 6f0:	83 c4 10             	add    $0x10,%esp
 6f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 6f6:	83 ec 0c             	sub    $0xc,%esp
 6f9:	ff 75 f4             	push   -0xc(%ebp)
 6fc:	e8 c2 00 00 00       	call   7c3 <close>
 701:	83 c4 10             	add    $0x10,%esp
  return r;
 704:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 707:	c9                   	leave
 708:	c3                   	ret

00000709 <atoi>:

int
atoi(const char *s)
{
 709:	55                   	push   %ebp
 70a:	89 e5                	mov    %esp,%ebp
 70c:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 70f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 716:	eb 25                	jmp    73d <atoi+0x34>
    n = n*10 + *s++ - '0';
 718:	8b 55 fc             	mov    -0x4(%ebp),%edx
 71b:	89 d0                	mov    %edx,%eax
 71d:	c1 e0 02             	shl    $0x2,%eax
 720:	01 d0                	add    %edx,%eax
 722:	01 c0                	add    %eax,%eax
 724:	89 c1                	mov    %eax,%ecx
 726:	8b 45 08             	mov    0x8(%ebp),%eax
 729:	8d 50 01             	lea    0x1(%eax),%edx
 72c:	89 55 08             	mov    %edx,0x8(%ebp)
 72f:	0f b6 00             	movzbl (%eax),%eax
 732:	0f be c0             	movsbl %al,%eax
 735:	01 c8                	add    %ecx,%eax
 737:	83 e8 30             	sub    $0x30,%eax
 73a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 73d:	8b 45 08             	mov    0x8(%ebp),%eax
 740:	0f b6 00             	movzbl (%eax),%eax
 743:	3c 2f                	cmp    $0x2f,%al
 745:	7e 0a                	jle    751 <atoi+0x48>
 747:	8b 45 08             	mov    0x8(%ebp),%eax
 74a:	0f b6 00             	movzbl (%eax),%eax
 74d:	3c 39                	cmp    $0x39,%al
 74f:	7e c7                	jle    718 <atoi+0xf>
  return n;
 751:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 754:	c9                   	leave
 755:	c3                   	ret

00000756 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 756:	55                   	push   %ebp
 757:	89 e5                	mov    %esp,%ebp
 759:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 75c:	8b 45 08             	mov    0x8(%ebp),%eax
 75f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 762:	8b 45 0c             	mov    0xc(%ebp),%eax
 765:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 768:	eb 17                	jmp    781 <memmove+0x2b>
    *dst++ = *src++;
 76a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 76d:	8d 42 01             	lea    0x1(%edx),%eax
 770:	89 45 f8             	mov    %eax,-0x8(%ebp)
 773:	8b 45 fc             	mov    -0x4(%ebp),%eax
 776:	8d 48 01             	lea    0x1(%eax),%ecx
 779:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 77c:	0f b6 12             	movzbl (%edx),%edx
 77f:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 781:	8b 45 10             	mov    0x10(%ebp),%eax
 784:	8d 50 ff             	lea    -0x1(%eax),%edx
 787:	89 55 10             	mov    %edx,0x10(%ebp)
 78a:	85 c0                	test   %eax,%eax
 78c:	7f dc                	jg     76a <memmove+0x14>
  return vdst;
 78e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 791:	c9                   	leave
 792:	c3                   	ret

00000793 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 793:	b8 01 00 00 00       	mov    $0x1,%eax
 798:	cd 40                	int    $0x40
 79a:	c3                   	ret

0000079b <exit>:
SYSCALL(exit)
 79b:	b8 02 00 00 00       	mov    $0x2,%eax
 7a0:	cd 40                	int    $0x40
 7a2:	c3                   	ret

000007a3 <wait>:
SYSCALL(wait)
 7a3:	b8 03 00 00 00       	mov    $0x3,%eax
 7a8:	cd 40                	int    $0x40
 7aa:	c3                   	ret

000007ab <pipe>:
SYSCALL(pipe)
 7ab:	b8 04 00 00 00       	mov    $0x4,%eax
 7b0:	cd 40                	int    $0x40
 7b2:	c3                   	ret

000007b3 <read>:
SYSCALL(read)
 7b3:	b8 05 00 00 00       	mov    $0x5,%eax
 7b8:	cd 40                	int    $0x40
 7ba:	c3                   	ret

000007bb <write>:
SYSCALL(write)
 7bb:	b8 10 00 00 00       	mov    $0x10,%eax
 7c0:	cd 40                	int    $0x40
 7c2:	c3                   	ret

000007c3 <close>:
SYSCALL(close)
 7c3:	b8 15 00 00 00       	mov    $0x15,%eax
 7c8:	cd 40                	int    $0x40
 7ca:	c3                   	ret

000007cb <kill>:
SYSCALL(kill)
 7cb:	b8 06 00 00 00       	mov    $0x6,%eax
 7d0:	cd 40                	int    $0x40
 7d2:	c3                   	ret

000007d3 <exec>:
SYSCALL(exec)
 7d3:	b8 07 00 00 00       	mov    $0x7,%eax
 7d8:	cd 40                	int    $0x40
 7da:	c3                   	ret

000007db <open>:
SYSCALL(open)
 7db:	b8 0f 00 00 00       	mov    $0xf,%eax
 7e0:	cd 40                	int    $0x40
 7e2:	c3                   	ret

000007e3 <mknod>:
SYSCALL(mknod)
 7e3:	b8 11 00 00 00       	mov    $0x11,%eax
 7e8:	cd 40                	int    $0x40
 7ea:	c3                   	ret

000007eb <unlink>:
SYSCALL(unlink)
 7eb:	b8 12 00 00 00       	mov    $0x12,%eax
 7f0:	cd 40                	int    $0x40
 7f2:	c3                   	ret

000007f3 <fstat>:
SYSCALL(fstat)
 7f3:	b8 08 00 00 00       	mov    $0x8,%eax
 7f8:	cd 40                	int    $0x40
 7fa:	c3                   	ret

000007fb <link>:
SYSCALL(link)
 7fb:	b8 13 00 00 00       	mov    $0x13,%eax
 800:	cd 40                	int    $0x40
 802:	c3                   	ret

00000803 <mkdir>:
SYSCALL(mkdir)
 803:	b8 14 00 00 00       	mov    $0x14,%eax
 808:	cd 40                	int    $0x40
 80a:	c3                   	ret

0000080b <chdir>:
SYSCALL(chdir)
 80b:	b8 09 00 00 00       	mov    $0x9,%eax
 810:	cd 40                	int    $0x40
 812:	c3                   	ret

00000813 <dup>:
SYSCALL(dup)
 813:	b8 0a 00 00 00       	mov    $0xa,%eax
 818:	cd 40                	int    $0x40
 81a:	c3                   	ret

0000081b <getpid>:
SYSCALL(getpid)
 81b:	b8 0b 00 00 00       	mov    $0xb,%eax
 820:	cd 40                	int    $0x40
 822:	c3                   	ret

00000823 <sbrk>:
SYSCALL(sbrk)
 823:	b8 0c 00 00 00       	mov    $0xc,%eax
 828:	cd 40                	int    $0x40
 82a:	c3                   	ret

0000082b <sleep>:
SYSCALL(sleep)
 82b:	b8 0d 00 00 00       	mov    $0xd,%eax
 830:	cd 40                	int    $0x40
 832:	c3                   	ret

00000833 <uptime>:
SYSCALL(uptime)
 833:	b8 0e 00 00 00       	mov    $0xe,%eax
 838:	cd 40                	int    $0x40
 83a:	c3                   	ret

0000083b <uthread_init>:
SYSCALL(uthread_init)
 83b:	b8 16 00 00 00       	mov    $0x16,%eax
 840:	cd 40                	int    $0x40
 842:	c3                   	ret

00000843 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 843:	55                   	push   %ebp
 844:	89 e5                	mov    %esp,%ebp
 846:	83 ec 18             	sub    $0x18,%esp
 849:	8b 45 0c             	mov    0xc(%ebp),%eax
 84c:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 84f:	83 ec 04             	sub    $0x4,%esp
 852:	6a 01                	push   $0x1
 854:	8d 45 f4             	lea    -0xc(%ebp),%eax
 857:	50                   	push   %eax
 858:	ff 75 08             	push   0x8(%ebp)
 85b:	e8 5b ff ff ff       	call   7bb <write>
 860:	83 c4 10             	add    $0x10,%esp
}
 863:	90                   	nop
 864:	c9                   	leave
 865:	c3                   	ret

00000866 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 866:	55                   	push   %ebp
 867:	89 e5                	mov    %esp,%ebp
 869:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 86c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 873:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 877:	74 17                	je     890 <printint+0x2a>
 879:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 87d:	79 11                	jns    890 <printint+0x2a>
    neg = 1;
 87f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 886:	8b 45 0c             	mov    0xc(%ebp),%eax
 889:	f7 d8                	neg    %eax
 88b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 88e:	eb 06                	jmp    896 <printint+0x30>
  } else {
    x = xx;
 890:	8b 45 0c             	mov    0xc(%ebp),%eax
 893:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 896:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 89d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 8a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8a3:	ba 00 00 00 00       	mov    $0x0,%edx
 8a8:	f7 f1                	div    %ecx
 8aa:	89 d1                	mov    %edx,%ecx
 8ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8af:	8d 50 01             	lea    0x1(%eax),%edx
 8b2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8b5:	0f b6 91 00 0f 00 00 	movzbl 0xf00(%ecx),%edx
 8bc:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 8c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
 8c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8c6:	ba 00 00 00 00       	mov    $0x0,%edx
 8cb:	f7 f1                	div    %ecx
 8cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8d0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8d4:	75 c7                	jne    89d <printint+0x37>
  if(neg)
 8d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8da:	74 2d                	je     909 <printint+0xa3>
    buf[i++] = '-';
 8dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8df:	8d 50 01             	lea    0x1(%eax),%edx
 8e2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 8e5:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 8ea:	eb 1d                	jmp    909 <printint+0xa3>
    putc(fd, buf[i]);
 8ec:	8d 55 dc             	lea    -0x24(%ebp),%edx
 8ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f2:	01 d0                	add    %edx,%eax
 8f4:	0f b6 00             	movzbl (%eax),%eax
 8f7:	0f be c0             	movsbl %al,%eax
 8fa:	83 ec 08             	sub    $0x8,%esp
 8fd:	50                   	push   %eax
 8fe:	ff 75 08             	push   0x8(%ebp)
 901:	e8 3d ff ff ff       	call   843 <putc>
 906:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 909:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 90d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 911:	79 d9                	jns    8ec <printint+0x86>
}
 913:	90                   	nop
 914:	90                   	nop
 915:	c9                   	leave
 916:	c3                   	ret

00000917 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 917:	55                   	push   %ebp
 918:	89 e5                	mov    %esp,%ebp
 91a:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 91d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 924:	8d 45 0c             	lea    0xc(%ebp),%eax
 927:	83 c0 04             	add    $0x4,%eax
 92a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 92d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 934:	e9 59 01 00 00       	jmp    a92 <printf+0x17b>
    c = fmt[i] & 0xff;
 939:	8b 55 0c             	mov    0xc(%ebp),%edx
 93c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 93f:	01 d0                	add    %edx,%eax
 941:	0f b6 00             	movzbl (%eax),%eax
 944:	0f be c0             	movsbl %al,%eax
 947:	25 ff 00 00 00       	and    $0xff,%eax
 94c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 94f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 953:	75 2c                	jne    981 <printf+0x6a>
      if(c == '%'){
 955:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 959:	75 0c                	jne    967 <printf+0x50>
        state = '%';
 95b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 962:	e9 27 01 00 00       	jmp    a8e <printf+0x177>
      } else {
        putc(fd, c);
 967:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 96a:	0f be c0             	movsbl %al,%eax
 96d:	83 ec 08             	sub    $0x8,%esp
 970:	50                   	push   %eax
 971:	ff 75 08             	push   0x8(%ebp)
 974:	e8 ca fe ff ff       	call   843 <putc>
 979:	83 c4 10             	add    $0x10,%esp
 97c:	e9 0d 01 00 00       	jmp    a8e <printf+0x177>
      }
    } else if(state == '%'){
 981:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 985:	0f 85 03 01 00 00    	jne    a8e <printf+0x177>
      if(c == 'd'){
 98b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 98f:	75 1e                	jne    9af <printf+0x98>
        printint(fd, *ap, 10, 1);
 991:	8b 45 e8             	mov    -0x18(%ebp),%eax
 994:	8b 00                	mov    (%eax),%eax
 996:	6a 01                	push   $0x1
 998:	6a 0a                	push   $0xa
 99a:	50                   	push   %eax
 99b:	ff 75 08             	push   0x8(%ebp)
 99e:	e8 c3 fe ff ff       	call   866 <printint>
 9a3:	83 c4 10             	add    $0x10,%esp
        ap++;
 9a6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9aa:	e9 d8 00 00 00       	jmp    a87 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 9af:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 9b3:	74 06                	je     9bb <printf+0xa4>
 9b5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 9b9:	75 1e                	jne    9d9 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 9bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9be:	8b 00                	mov    (%eax),%eax
 9c0:	6a 00                	push   $0x0
 9c2:	6a 10                	push   $0x10
 9c4:	50                   	push   %eax
 9c5:	ff 75 08             	push   0x8(%ebp)
 9c8:	e8 99 fe ff ff       	call   866 <printint>
 9cd:	83 c4 10             	add    $0x10,%esp
        ap++;
 9d0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9d4:	e9 ae 00 00 00       	jmp    a87 <printf+0x170>
      } else if(c == 's'){
 9d9:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 9dd:	75 43                	jne    a22 <printf+0x10b>
        s = (char*)*ap;
 9df:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9e2:	8b 00                	mov    (%eax),%eax
 9e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 9e7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 9eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9ef:	75 25                	jne    a16 <printf+0xff>
          s = "(null)";
 9f1:	c7 45 f4 e7 0e 00 00 	movl   $0xee7,-0xc(%ebp)
        while(*s != 0){
 9f8:	eb 1c                	jmp    a16 <printf+0xff>
          putc(fd, *s);
 9fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fd:	0f b6 00             	movzbl (%eax),%eax
 a00:	0f be c0             	movsbl %al,%eax
 a03:	83 ec 08             	sub    $0x8,%esp
 a06:	50                   	push   %eax
 a07:	ff 75 08             	push   0x8(%ebp)
 a0a:	e8 34 fe ff ff       	call   843 <putc>
 a0f:	83 c4 10             	add    $0x10,%esp
          s++;
 a12:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a19:	0f b6 00             	movzbl (%eax),%eax
 a1c:	84 c0                	test   %al,%al
 a1e:	75 da                	jne    9fa <printf+0xe3>
 a20:	eb 65                	jmp    a87 <printf+0x170>
        }
      } else if(c == 'c'){
 a22:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a26:	75 1d                	jne    a45 <printf+0x12e>
        putc(fd, *ap);
 a28:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a2b:	8b 00                	mov    (%eax),%eax
 a2d:	0f be c0             	movsbl %al,%eax
 a30:	83 ec 08             	sub    $0x8,%esp
 a33:	50                   	push   %eax
 a34:	ff 75 08             	push   0x8(%ebp)
 a37:	e8 07 fe ff ff       	call   843 <putc>
 a3c:	83 c4 10             	add    $0x10,%esp
        ap++;
 a3f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a43:	eb 42                	jmp    a87 <printf+0x170>
      } else if(c == '%'){
 a45:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a49:	75 17                	jne    a62 <printf+0x14b>
        putc(fd, c);
 a4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a4e:	0f be c0             	movsbl %al,%eax
 a51:	83 ec 08             	sub    $0x8,%esp
 a54:	50                   	push   %eax
 a55:	ff 75 08             	push   0x8(%ebp)
 a58:	e8 e6 fd ff ff       	call   843 <putc>
 a5d:	83 c4 10             	add    $0x10,%esp
 a60:	eb 25                	jmp    a87 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a62:	83 ec 08             	sub    $0x8,%esp
 a65:	6a 25                	push   $0x25
 a67:	ff 75 08             	push   0x8(%ebp)
 a6a:	e8 d4 fd ff ff       	call   843 <putc>
 a6f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 a72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a75:	0f be c0             	movsbl %al,%eax
 a78:	83 ec 08             	sub    $0x8,%esp
 a7b:	50                   	push   %eax
 a7c:	ff 75 08             	push   0x8(%ebp)
 a7f:	e8 bf fd ff ff       	call   843 <putc>
 a84:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 a87:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 a8e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a92:	8b 55 0c             	mov    0xc(%ebp),%edx
 a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a98:	01 d0                	add    %edx,%eax
 a9a:	0f b6 00             	movzbl (%eax),%eax
 a9d:	84 c0                	test   %al,%al
 a9f:	0f 85 94 fe ff ff    	jne    939 <printf+0x22>
    }
  }
}
 aa5:	90                   	nop
 aa6:	90                   	nop
 aa7:	c9                   	leave
 aa8:	c3                   	ret

00000aa9 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 aa9:	55                   	push   %ebp
 aaa:	89 e5                	mov    %esp,%ebp
 aac:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 aaf:	8b 45 08             	mov    0x8(%ebp),%eax
 ab2:	83 e8 08             	sub    $0x8,%eax
 ab5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ab8:	a1 9c 4f 01 00       	mov    0x14f9c,%eax
 abd:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ac0:	eb 24                	jmp    ae6 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ac2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac5:	8b 00                	mov    (%eax),%eax
 ac7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 aca:	72 12                	jb     ade <free+0x35>
 acc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 acf:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 ad2:	72 24                	jb     af8 <free+0x4f>
 ad4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad7:	8b 00                	mov    (%eax),%eax
 ad9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 adc:	72 1a                	jb     af8 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ade:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae1:	8b 00                	mov    (%eax),%eax
 ae3:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ae6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ae9:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 aec:	73 d4                	jae    ac2 <free+0x19>
 aee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af1:	8b 00                	mov    (%eax),%eax
 af3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 af6:	73 ca                	jae    ac2 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 af8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 afb:	8b 40 04             	mov    0x4(%eax),%eax
 afe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b05:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b08:	01 c2                	add    %eax,%edx
 b0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b0d:	8b 00                	mov    (%eax),%eax
 b0f:	39 c2                	cmp    %eax,%edx
 b11:	75 24                	jne    b37 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 b13:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b16:	8b 50 04             	mov    0x4(%eax),%edx
 b19:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b1c:	8b 00                	mov    (%eax),%eax
 b1e:	8b 40 04             	mov    0x4(%eax),%eax
 b21:	01 c2                	add    %eax,%edx
 b23:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b26:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b29:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b2c:	8b 00                	mov    (%eax),%eax
 b2e:	8b 10                	mov    (%eax),%edx
 b30:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b33:	89 10                	mov    %edx,(%eax)
 b35:	eb 0a                	jmp    b41 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 b37:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b3a:	8b 10                	mov    (%eax),%edx
 b3c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b3f:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b41:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b44:	8b 40 04             	mov    0x4(%eax),%eax
 b47:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b51:	01 d0                	add    %edx,%eax
 b53:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 b56:	75 20                	jne    b78 <free+0xcf>
    p->s.size += bp->s.size;
 b58:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b5b:	8b 50 04             	mov    0x4(%eax),%edx
 b5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b61:	8b 40 04             	mov    0x4(%eax),%eax
 b64:	01 c2                	add    %eax,%edx
 b66:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b69:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b6f:	8b 10                	mov    (%eax),%edx
 b71:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b74:	89 10                	mov    %edx,(%eax)
 b76:	eb 08                	jmp    b80 <free+0xd7>
  } else
    p->s.ptr = bp;
 b78:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b7b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b7e:	89 10                	mov    %edx,(%eax)
  freep = p;
 b80:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b83:	a3 9c 4f 01 00       	mov    %eax,0x14f9c
}
 b88:	90                   	nop
 b89:	c9                   	leave
 b8a:	c3                   	ret

00000b8b <morecore>:

static Header*
morecore(uint nu)
{
 b8b:	55                   	push   %ebp
 b8c:	89 e5                	mov    %esp,%ebp
 b8e:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b91:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b98:	77 07                	ja     ba1 <morecore+0x16>
    nu = 4096;
 b9a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 ba1:	8b 45 08             	mov    0x8(%ebp),%eax
 ba4:	c1 e0 03             	shl    $0x3,%eax
 ba7:	83 ec 0c             	sub    $0xc,%esp
 baa:	50                   	push   %eax
 bab:	e8 73 fc ff ff       	call   823 <sbrk>
 bb0:	83 c4 10             	add    $0x10,%esp
 bb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 bb6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 bba:	75 07                	jne    bc3 <morecore+0x38>
    return 0;
 bbc:	b8 00 00 00 00       	mov    $0x0,%eax
 bc1:	eb 26                	jmp    be9 <morecore+0x5e>
  hp = (Header*)p;
 bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bcc:	8b 55 08             	mov    0x8(%ebp),%edx
 bcf:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bd5:	83 c0 08             	add    $0x8,%eax
 bd8:	83 ec 0c             	sub    $0xc,%esp
 bdb:	50                   	push   %eax
 bdc:	e8 c8 fe ff ff       	call   aa9 <free>
 be1:	83 c4 10             	add    $0x10,%esp
  return freep;
 be4:	a1 9c 4f 01 00       	mov    0x14f9c,%eax
}
 be9:	c9                   	leave
 bea:	c3                   	ret

00000beb <malloc>:

void*
malloc(uint nbytes)
{
 beb:	55                   	push   %ebp
 bec:	89 e5                	mov    %esp,%ebp
 bee:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bf1:	8b 45 08             	mov    0x8(%ebp),%eax
 bf4:	83 c0 07             	add    $0x7,%eax
 bf7:	c1 e8 03             	shr    $0x3,%eax
 bfa:	83 c0 01             	add    $0x1,%eax
 bfd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 c00:	a1 9c 4f 01 00       	mov    0x14f9c,%eax
 c05:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c08:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c0c:	75 23                	jne    c31 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 c0e:	c7 45 f0 94 4f 01 00 	movl   $0x14f94,-0x10(%ebp)
 c15:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c18:	a3 9c 4f 01 00       	mov    %eax,0x14f9c
 c1d:	a1 9c 4f 01 00       	mov    0x14f9c,%eax
 c22:	a3 94 4f 01 00       	mov    %eax,0x14f94
    base.s.size = 0;
 c27:	c7 05 98 4f 01 00 00 	movl   $0x0,0x14f98
 c2e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c31:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c34:	8b 00                	mov    (%eax),%eax
 c36:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c3c:	8b 40 04             	mov    0x4(%eax),%eax
 c3f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c42:	72 4d                	jb     c91 <malloc+0xa6>
      if(p->s.size == nunits)
 c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c47:	8b 40 04             	mov    0x4(%eax),%eax
 c4a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 c4d:	75 0c                	jne    c5b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c52:	8b 10                	mov    (%eax),%edx
 c54:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c57:	89 10                	mov    %edx,(%eax)
 c59:	eb 26                	jmp    c81 <malloc+0x96>
      else {
        p->s.size -= nunits;
 c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c5e:	8b 40 04             	mov    0x4(%eax),%eax
 c61:	2b 45 ec             	sub    -0x14(%ebp),%eax
 c64:	89 c2                	mov    %eax,%edx
 c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c69:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c6f:	8b 40 04             	mov    0x4(%eax),%eax
 c72:	c1 e0 03             	shl    $0x3,%eax
 c75:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c7b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c7e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c81:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c84:	a3 9c 4f 01 00       	mov    %eax,0x14f9c
      return (void*)(p + 1);
 c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c8c:	83 c0 08             	add    $0x8,%eax
 c8f:	eb 3b                	jmp    ccc <malloc+0xe1>
    }
    if(p == freep)
 c91:	a1 9c 4f 01 00       	mov    0x14f9c,%eax
 c96:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c99:	75 1e                	jne    cb9 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 c9b:	83 ec 0c             	sub    $0xc,%esp
 c9e:	ff 75 ec             	push   -0x14(%ebp)
 ca1:	e8 e5 fe ff ff       	call   b8b <morecore>
 ca6:	83 c4 10             	add    $0x10,%esp
 ca9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 cac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 cb0:	75 07                	jne    cb9 <malloc+0xce>
        return 0;
 cb2:	b8 00 00 00 00       	mov    $0x0,%eax
 cb7:	eb 13                	jmp    ccc <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cc2:	8b 00                	mov    (%eax),%eax
 cc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 cc7:	e9 6d ff ff ff       	jmp    c39 <malloc+0x4e>
  }
}
 ccc:	c9                   	leave
 ccd:	c3                   	ret
