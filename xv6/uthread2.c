#include "types.h"
#include "stat.h"
#include "user.h"

/* Possible states of a thread; */
#define FREE        0x0
#define RUNNING     0x1
#define RUNNABLE    0x2
#define WAIT        0x3

#define STACK_SIZE  8184
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
    //printf(1,"t: %x, state %x \n", t, t->state);
    if(t == &all_thread[0] && t->state == RUNNABLE){
      continue;
    }
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

  if (current_thread != next_thread) {         /* switch threads?  */
    next_thread->state = RUNNING;
    current_thread->state = RUNNABLE;
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

void 
thread_create(void (*func)())
{
  printf(1,"thread_create\n");
  printf(1, "[create] func address = 0x%x\n", func);
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == FREE) break;
  }

  t->sp = (int)(t->stack + STACK_SIZE);

  t->sp -= 4;
  *(int *)(t->sp) = (int)func;  // 올바른 ret 주소 설정
  t->sp -= 32;                  // context는 그 아래

  t->tid = t - all_thread;
  t->ptid = current_thread->tid;
  t->state = RUNNABLE;
}

static void thread_join_all(void) {
  while (1) {
    int child_alive = 0;

    for (int i = 0; i < MAX_THREAD; i++) {
      if (all_thread[i].state != FREE &&
          all_thread[i].ptid == current_thread->tid) {
        child_alive = 1;
        break;
      }
    }

    if (!child_alive)
      break;

    // 현재 RUNNABLE 스레드가 있는 경우에만 스케줄
    int has_runnable = 0;
    for (int i = 0; i < MAX_THREAD; i++) {
      if (all_thread[i].state == RUNNABLE) {
        has_runnable = 1;
        break;
      }
    }

    if (!has_runnable) {
      printf(1, "[join_all] No runnable threads left, exiting loop early\n");
      break;
    }

    thread_schedule();
  }
}

static void 
child_thread(void)
{
  int i;
  printf(1, "[child] started: tid=%d, ptid=%d\n", current_thread->tid, current_thread->ptid);
  for (i = 0; i < 10; i++) {
    printf(1, "[child] child thread 0x%x\n", (int) current_thread);
  }
  printf(1, "[child] child thread: exit\n");
  current_thread->state = FREE;
}

static void 
mythread(void)
{
  int i;
  printf(1, "[parent] mythread tid=%d creating children...\n", current_thread->tid);
  for (i = 0; i < 5; i++) {
    thread_create(child_thread);
    thread_schedule();
  }
  thread_join_all();
  printf(1, "[parent] mythread done\n");
  current_thread->state = FREE;
  thread_schedule();
}


int 
main(int argc, char *argv[]) 
{
  thread_init();
  thread_create(mythread);
  thread_schedule();
  //thread_join_all();
  return 0;
}