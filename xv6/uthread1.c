#include "types.h"
#include "stat.h"
#include "user.h"

/* Possible states of a thread; */

// 쓰레드 상태
#define FREE        0x0
#define RUNNING     0x1
#define RUNNABLE    0x2

// 쓰레드 스택 크기
// 쓰레드 개수
#define STACK_SIZE  8192
#define MAX_THREAD  4

// 쓰레드 구조체, 스레드 포인터
typedef struct thread thread_t, *thread_p;
typedef struct mutex mutex_t, *mutex_p;

// 쓰레드 구조체 선언부
struct thread {
  int        sp;                /* saved stack pointer */
  char stack[STACK_SIZE];       /* the thread's stack */
  int        state;             /* FREE, RUNNING, RUNNABLE */
};
// 쓰레드 배열
static thread_t all_thread[MAX_THREAD];
// current_thread: 현재 실행중인 쓰레드, next_thread: 다음 실행할 쓰레드
thread_p  current_thread;
thread_p  next_thread;

// context switch를 위한 함수 assembly어로 작성하기 때문에 extern으로 선언
extern void thread_switch(void);

// thread_schedule: 스레드 스케줄링을 위한 함수 thread_init()에서 함수 포인터로 사용하기 위해
// thread_init 위에 선언
static void thread_schedule(void);

// thread_init: 스레드 초기화 함수
void 
thread_init(void)
{
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  // main()으로 쓰기 때문에 미리 쓰레드 0을 RUNNING 상태로 만들어 놓는다.
  current_thread = &all_thread[0];
  current_thread->state = RUNNING;

  // System call
  // uthread_init()을 통해서 thread_schedule의 주소를 넘겨준다.
  // uthread_init()은 syscall.c에 정의되어 있다.
  uthread_init((int)thread_schedule);
}

static void
thread_schedule(void)
{ 

  thread_p t;
  /* Find another runnable thread. */
  next_thread = 0;

  
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    // all_thread[0]은 main()이기 때문에 한 번 switch를 했으면 건너 뜀.
    if(t == &all_thread[0] && t->state == RUNNABLE){
      continue;
    }
    // RUNNABLE 상태인 스레드가 있으면 next_thread에 저장
    if (t->state == RUNNABLE && t != current_thread) {
      next_thread = t;
      break;
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  }

  // runnable thread가 없으면 exit
  if (next_thread == 0) {
    // current_thread가 RUNNING 상태이면 현재 쓰레드가 유일한 쓰레드이므로
    // 스케줄링을 하지 않고 그냥 리턴
    if (current_thread->state == RUNNING) return;
    // 쓰레드가 없으면 exit
    printf(2, "thread_schedule: no runnable threads\n");
    exit();
  }

  if (current_thread != next_thread) {         /* switch threads?  */
    next_thread->state = RUNNING;
    // current_thread가 RUNNING 상태이면 RUNNABLE로 바꿔준다.
    if (current_thread->state == RUNNING) current_thread->state = RUNNABLE;
    // context switch
    thread_switch();
  } else
    next_thread = 0;
}

// thread_create: 스레드 생성 함수
void 
thread_create(void (*func)())
{
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == FREE) break;
  }
  // 스택 포인터 = 스택의 top frame
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
  // 스택 포인터를 4byte 만큼 줄여서 리턴 주소를 저장할 공간을 만든다.
  t->sp -= 4;                              // space for return address
  // mythread 함수를 리턴 주소로 저장
  * (int *) (t->sp) = (int)func;           // push return address on stack
  // 레지스터를 위한 공간
  t->sp -= 32;                             // space for registers that thread_switch expects
  t->state = RUNNABLE;
  thread_count(1);
}

static void 
mythread(void)
{
  int i;
  printf(1, "my thread running\n");
  for (i = 0; i < 100; i++) {
    printf(1, "i:%d, my thread 0x%x\n", i, (int) current_thread);
  }
  printf(1, "my thread: exit\n");
  // 쓰레드가 종료되면 쓰레드 상태를 FREE로 바꿔준다.
  current_thread->state = FREE;
  thread_count(-1);
    
  // 현재 쓰레드가 종료 되었기 때문에 스케줄링
  thread_schedule();
}


int 
main(int argc, char *argv[]) 
{
  thread_init();
  thread_create(mythread);
  thread_create(mythread);
  thread_schedule();
  return 0;
}
