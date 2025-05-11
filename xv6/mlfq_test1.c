// mlfq_test1.c : POLICY 1 - tracking + boosting
#include "types.h"
#include "user.h"
#include "pstat.h"

#define NPROCS 3

int workload(int n) {
  int i, j = 0;
  for (i = 0; i < n; i++) {
    j += i * j + 1;
    if (i % 1000000 == 0)
    {
      printf(1,"[WORRKLOAD] i = %d\n",i);
    }
  };
  return j;
}

void print_stat() {
  struct pstat ps;
  getpinfo(&ps);
  printf(1, "\n[RESULT] Process Statistics\n");
  for (int i = 0; i < NPROC; i++) {
    if (ps.inuse[i]) {
      printf(1, "PID %d | Priority %d | Ticks: [Q3:%d Q2:%d Q1:%d Q0:%d] | Wait: [Q3:%d Q2:%d Q1:%d Q0:%d]\n",
        ps.pid[i], ps.priority[i],
        ps.ticks[i][3], ps.ticks[i][2], ps.ticks[i][1], ps.ticks[i][0],
        ps.wait_ticks[i][3], ps.wait_ticks[i][2], ps.wait_ticks[i][1], ps.wait_ticks[i][0]);
    }
  }
}

void run_policy_1() {
  printf(1, "[DEBUG] Entered run_policy_1()\n");
  sleep(1);  
  for (int i = 0; i < NPROCS; i++) {
    int pid = fork();
    if (pid == 0) {
      printf(1, "[CHILD] i=%d, PID=%d\n", i, getpid());
      sleep(1);
      workload(10000000 * (i + 1));
      exit();
    } else {
      printf(1, "[PARENT] forked child PID=%d at i=%d\n", pid, i);
      sleep(1);
    }
  }
  setSchedPolicy(1);
  sleep(1);
  for (int i = 0; i < NPROCS; i++) wait();
  print_stat();
}

int main(void) {
  printf(1, "\n===== [POLICY 1: tracking + boosting] =====\n");
  run_policy_1();
  exit();
}
