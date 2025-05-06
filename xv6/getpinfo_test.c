#include "types.h"
#include "stat.h"
#include "user.h"
#include "pstat.h"

int main(void) {
  struct pstat ps;

  // 시스템 콜 호출
  if (getpinfo(&ps) < 0) {
    printf(1, "getpinfo failed\n");
    exit();
  }

  // 모든 프로세스 출력
  for (int i = 0; i < NPROC; i++) {
    if (ps.inuse[i]) {
      printf(1, "---------------------------------\n");
      printf(1, "PID: %d\n", ps.pid[i]);
      printf(1, "State: %d\n", ps.state[i]);       // enum procstate
      printf(1, "Priority: %d\n", ps.priority[i]);
      for (int q = 0; q < 4; q++) {
        printf(1, "  Q%d: ticks=%d, wait=%d\n", q,
               ps.ticks[i][q], ps.wait_ticks[i][q]);
      }
    }
  }

  exit();
}