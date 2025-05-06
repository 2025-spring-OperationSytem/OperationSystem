#include "types.h"
#include "user.h"
#include "pstat.h"

#define NPROCS 3

int workload(int n) {
  int i, j = 0;
  for (i = 0; i < n; i++){
    j += i * j + 1;
    if (i % 1000000 == 0) yield(); // 주기적으로 CPU 양보
  }
  return j;
}


// 결과 출력
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

void run_mlfq_with_tracking_and_boosting() {
  for (int i = 0; i < 3; i++) {
    if (fork() == 0) {
      if (i == 0) {
        printf(1, "[Process %d] Short workload\n", i);
        workload(8000000); // Q3 유지
      } else if (i == 1) {
        printf(1, "[Process %d] Medium workload\n", i);
        workload(40000000); // Q3→Q2→Q1
      } else {
        printf(1, "[Process %d] Long workload\n", i);
        workload(100000000); // Q3→Q2→Q1→Q0
      }
      exit();
    }
  }

  for (int i = 0; i < 3; i++) wait();

  print_stat(); // 결과 확인
}

int main(void) {
  printf(1, "\n===== [POLICY 1: MLFQ with tracking & boosting] =====\n");
  setSchedPolicy(1);
  printf(1, "[FORKED] sched_policy = %d (child)\n", getSchedPolicy());

  if (fork() == 0) {
    printf(1, "[FORKED] sched_policy = %d (child)\n", getSchedPolicy());
    run_mlfq_with_tracking_and_boosting();
    exit();
  }
  wait();
  exit();
}