#include "types.h"
#include "stat.h"
#include "user.h"

/* Possible states of a thread */
#define FREE        0x0
#define RUNNING     0x1
#define RUNNABLE    0x2
#define WAIT        0x3

#define STACK_SIZE  8192
#define MAX_THREAD  10

typedef struct thread thread_t, *thread_p;
struct thread {
  int        sp;
  char       stack[STACK_SIZE];
  int        state;
  int        tid;
};

static thread_t all_thread[MAX_THREAD];
thread_p       current_thread;
thread_p       next_thread;
extern void    thread_switch(void);

// Round‑Robin Scheduler 
static void
thread_schedule(void) {
  int curr = current_thread - all_thread;
  for (int i = 1; i < MAX_THREAD; i++) {
    int idx = (curr + i) % MAX_THREAD;
    if (all_thread[idx].state == RUNNABLE) {
      next_thread = &all_thread[idx];
      goto _switch;
    }
  }
  if (current_thread->state == RUNNABLE || current_thread->state == RUNNING) {
    next_thread = current_thread;
    return;
  }
  printf(2, "thread_schedule: no runnable threads\n");
  exit();

_switch:
  if (next_thread != current_thread) {
    next_thread->state = RUNNING;
    if (current_thread->state != WAIT && current_thread->state != FREE)
      current_thread->state = RUNNABLE;
    thread_switch();
  }
}

void
thread_init(void) {
  uthread_init((int)thread_schedule);
  current_thread = &all_thread[0];
  current_thread->state = RUNNING;
  current_thread->tid   = 0;
}

int
thread_create(void (*func)()) {
  thread_p t;
  for (t = all_thread + 1; t < all_thread + MAX_THREAD; t++)
    if (t->state == FREE) break;
  if (t == all_thread + MAX_THREAD) return -1;

  t->sp = (int)(t->stack + STACK_SIZE);
  t->sp -= 4;             
  *(int*)(t->sp) = (int)func;
  t->sp -= 32;            

  t->state = RUNNABLE;
  t->tid   = t - all_thread;
  printf(1, "[create] tid=%d created and set RUNNABLE\n", t->tid);
  return t->tid;
}

void
thread_suspend(int tid) {
  if (tid <= 0 || tid >= MAX_THREAD) return;
  thread_p t = &all_thread[tid];
  if (t->state == RUNNABLE || t->state == RUNNING) {
    t->state = WAIT;
    printf(1, "[suspend] tid=%d set to WAIT\n", tid);
    if (t == current_thread) thread_schedule();
  }
}

void
thread_resume(int tid) {
  if (tid <= 0 || tid >= MAX_THREAD) return;
  thread_p t = &all_thread[tid];
  if (t->state == WAIT) {
    t->state = RUNNABLE;
    printf(1, "[resume] tid=%d set to RUNNABLE\n", tid);
  }
}

// 유저 레벨 “sleep” 구현 
static void
uthread_sleep(int ticks) {
  for (int i = 0; i < ticks; i++)
    thread_schedule();
}


static void
mythread(void) {
  printf(1, "[thread] tid=%d started\n", current_thread->tid);
  for (int i = 0; i < 20; i++) {
    printf(1, "[thread] tid=%d iter %d\n", current_thread->tid, i);
    thread_schedule();
  }
  printf(1, "[thread] tid=%d exiting\n", current_thread->tid);
  current_thread->state = FREE;
  thread_schedule();
}

int
main(int argc, char *argv[]) {
  int tid1, tid2;

  thread_init();
  tid1 = thread_create(mythread);
  tid2 = thread_create(mythread);

  uthread_sleep(5);

  // tid1 suspend → tid2 만 실행 
  thread_suspend(tid1);
  uthread_sleep(5);

  //tid2 suspend → 멈춤
  thread_suspend(tid2);
  uthread_sleep(3);

  //tid1 resume → tid1 만 실행
  thread_resume(tid1);
  uthread_sleep(5);

  // tid2 resume → 둘 다 실행 
  thread_resume(tid2);

  // 이후 남은 스레드들 모두 소진
  while (1) {
    thread_schedule();
  }

  return 0;
}