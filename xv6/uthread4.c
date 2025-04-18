#include "types.h"
#include "stat.h"
#include "user.h"

/* Possible states of a thread; */
#define FREE        0x0
#define RUNNING     0x1
#define RUNNABLE    0x2
#define WAIT        0x3

#define STACK_SIZE  8192
#define MAX_THREAD  10

typedef struct thread thread_t, *thread_p;
typedef struct mutex mutex_t, *mutex_p;

struct thread {
  int        sp;                /* saved stack pointer */
  char stack[STACK_SIZE];       /* the thread's stack */
  int        state;             /* FREE, RUNNING, RUNNABLE, WAIT */
  int        tid;    /* thread id */
  int        ptid;  /* parent thread id */
};
static thread_t all_thread[MAX_THREAD];
thread_p  current_thread;
thread_p  next_thread;
extern void thread_switch(void);

static void 
thread_schedule(void)
{
  thread_p t;

  /* Find another runnable thread. */
  next_thread = 0;
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == RUNNABLE && t != current_thread) {
      next_thread = t;
      break;
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  }

  if (next_thread == 0) {
    printf(2, "thread_schedule: no runnable threads\n");
    exit();
  }

  if (current_thread != next_thread) {
    next_thread->state = RUNNING;
    if (current_thread->state != FREE) {
      current_thread->state = RUNNABLE;
    }
  
    printf(1, "[sched] switch from tid=%d to tid=%d\n", current_thread->tid, next_thread->tid);
    thread_switch();
  } else
    next_thread = 0;
}
void 
thread_init(void)
{

  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  current_thread->state = RUNNING;
  current_thread->tid=0;
  current_thread->ptid=0;

  uthread_init((int)thread_schedule);
}

int 
thread_create(void (*func)())
{
  printf(1,"thread_create\n");
  
  thread_p t;
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == FREE) break;
  }

  t->sp = (int)(t->stack + STACK_SIZE);
  t->sp -= 4;
  *(int *)(t->sp) = (int)func;  // ret 주소
  t->sp -= 32;

  t->tid = t - all_thread;
  t->ptid = current_thread->tid;
  t->state = RUNNABLE;

  printf(1, "[create] tid=%d func address = 0x%x\n", t->tid, func);
  return t->tid;
}

// thread_join 함수 구현
int thread_join(int tid) {
  if (tid < 0 || tid >= MAX_THREAD) {
    printf(1, "[thread_join] Invalid thread ID: %d\n", tid);
    return -1;
  }

  thread_p target = &all_thread[tid];

  // 유효한 자식인지 확인
  if (target->ptid != current_thread->tid) {
    printf(1, "[thread_join] tid=%d is not a child of current thread=%d\n", tid, current_thread->tid);
    return -1;
  }

  printf(1, "[thread_join] current=%d waiting for child=%d\n", current_thread->tid, tid);

  while (1) {
    if (target->state == FREE) {
      // 자식 종료되었으면 실행 가능 상태로 복귀
      current_thread->state = RUNNABLE;
      break;
    }

    // WAIT으로 변경
    current_thread->state = WAIT;

    // 다른 RUNNABLE 스레드가 있는지 확인
    int has_runnable = 0;
    for (int i = 0; i < MAX_THREAD; i++) {
      if (&all_thread[i] != current_thread && all_thread[i].state == RUNNABLE) {
        has_runnable = 1;
        break;
      }
    }

    if (!has_runnable) {
      // 깨울 수 있는 다른 스레드가 없다면 스스로 다시 실행 가능하게 변경
      printf(1, "[thread_join] no RUNNABLE threads left, waking self\n");
      current_thread->state = RUNNABLE;
      break;
    }

    // 스케줄링
    thread_schedule();
  }

  printf(1, "[thread_join] child tid=%d finished\n", tid);
  return 0;
}

static void 
child_thread(void)
{
  int i;
  printf(1, "[child] started: tid=%d, ptid=%d\n", current_thread->tid, current_thread->ptid);
  for (i = 0; i < 10; i++) {
    printf(1, "[child] child thread 0x%x running iteration %d\n", (int)current_thread, i);
  }
  printf(1, "child thread: exit\n");
  current_thread->state = FREE;
  thread_schedule(); 
}

static void 
mythread(void)
{
  int i;
  int tid[5];

  printf(1, "[parent] mythread tid=%d creating children...\n", current_thread->tid);

  // 자식 스레드 생성하고 tid 저장
  for (i = 0; i < 5; i++) {
    tid[i] = thread_create(child_thread);
    printf(1, "[parent] created child with tid=%d\n", tid[i]);
  }
  
  // 각 자식 스레드를 개별적으로 join
  for (i = 0; i < 5; i++) {
    printf(1, "[parent] joining child tid=%d\n", tid[i]);
    thread_join(tid[i]);
    printf(1, "[parent] child tid=%d joined\n", tid[i]);
  }
    
  printf(1, "[parent] mythread done\n");
  current_thread->state = FREE;
  thread_schedule();
}

int 
main(int argc, char *argv[]) 
{
  thread_init();
  thread_create(mythread);
  // main thread는 아무 역할이 없으므로 바로 FREE로 설정
  current_thread->state = FREE;
  thread_schedule(); 
  return 0;
}