#include "types.h"
#include "user.h"
#include "pstat.h"

#define NPROCS 3

int workload(int n) {
  int i, j = 0;
  for (i = 0; i < n; i++) {
    j += i * j + 1;
    // Boosting이 없기 때문에 한번 떨어지면 다시는 안 올라감
  }
  return j;
}

void print_stat() {
  struct pstat ps;
  getpinfo(&ps);

  printf(1, "\n[RESULT] Process Statistics (Policy 3: No Boosting)\n");
  for (int i = 0; i < NPROC; i++) {
    if (ps.inuse[i]) {
      printf(1, "PID %d | Priority %d | Ticks: [Q3:%d Q2:%d Q1:%d Q0:%d] | Wait: [Q3:%d Q2:%d Q1:%d Q0:%d]\n",
        ps.pid[i], ps.priority[i],
        ps.ticks[i][3], ps.ticks[i][2], ps.ticks[i][1], ps.ticks[i][0],
        ps.wait_ticks[i][3], ps.wait_ticks[i][2], ps.wait_ticks[i][1], ps.wait_ticks[i][0]);
    }
  }
}

void run_policy_3() {
  printf(1, "[DEBUG] Entered run_policy_3() - MLFQ without boosting\n");
  sleep(1);

  for (int i = 0; i < NPROCS; i++) {
    int pid = fork();
    if (pid < 0) {
      printf(1, "[ERROR] fork failed at i=%d\n", i);
      sleep(1);
    }
    if (pid == 0) {
      printf(1, "[CHILD] i=%d, PID=%d\n", i, getpid());
      sleep(1);
      workload(10000000 * (i + 1));
      sleep(100);
      exit();
    } else {
      printf(1, "[PARENT] forked child PID=%d at i=%d\n", pid, i);
      sleep(1);
    }
  }

  printf(1, "[DEBUG] Setting sched_policy = 3 (no boosting)\n");
  setSchedPolicy(3);
  sleep(1);

  int policy = getSchedPolicy();
  printf(1, "[DEBUG] Current sched_policy = %d\n", policy);
  sleep(1);

  for (int i = 0; i < NPROCS; i++) wait();

  print_stat();
}

int main(void) {
  printf(1, "\n===== [POLICY 3: MLFQ without boosting] =====\n");
  run_policy_3();
  printf(1, "\n===== [POLICY 3: exit] =====\n");
  sleep(1);
  exit();
}
