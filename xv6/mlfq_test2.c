#include "types.h"
#include "user.h"
#include "pstat.h"

#define NPROCS 3

int workload(int n) {
  int i, j = 0;
  for (i = 0; i < n; i++) {
    if (i % 1000 *(getpid()-3) * 8 == 0) {
      yield();
    }
    j += i * j + 1;
  }
  return j;
}


void print_stat() {
  struct pstat ps;
  getpinfo(&ps);

  printf(1, "\n[RESULT] Process Statistics (Policy 2: No Tracking)\n");
  for (int i = 0; i < NPROC; i++) {
    if (ps.inuse[i]) {
      printf(1, "PID %d | Priority %d | Ticks: [Q3:%d Q2:%d Q1:%d Q0:%d] | Wait: [Q3:%d Q2:%d Q1:%d Q0:%d]\n",
        ps.pid[i], ps.priority[i],
        ps.ticks[i][3], ps.ticks[i][2], ps.ticks[i][1], ps.ticks[i][0],
        ps.wait_ticks[i][3], ps.wait_ticks[i][2], ps.wait_ticks[i][1], ps.wait_ticks[i][0]);
    }
  }
}

void run_policy_2() {
  printf(1, "[DEBUG] Entered run_policy_1()\n");
  setSchedPolicy(1);
  for (int i = 0; i < NPROCS; i++) {
    int pid = fork();
    if (pid == 0) {
      workload(100000 * (i + 1));      
      exit();
    }
  }
  printf(1, "praents process wait\n");
  for (int i = 0; i < NPROCS; i++) wait();
  print_stat();
}

int main(void) {
  printf(1, "\n===== [POLICY 2: MLFQ without tracking (cheating possible)] =====\n");
  run_policy_2();
  printf(1, "\n===== [POLICY 2: exit] =====\n");
  sleep(1);
  exit();
}
