// pstat.h (new file)
#ifndef _PSTAT_H_
#define _PSTAT_H_

#include "param.h" // for NPROC

//process statistics
// 각 프로세스들의 상태 및 스케줄링 관련 정보를 모아두는 구조체
struct pstat {
  // whether this slot of the process table is in use (1 or 0)
  int inuse[NPROC]; 
  // PID of each process
  int pid[NPROC];   
  // current priority level of each process (0-3)
  int priority[NPROC];  
  // current state (e.g., SLEEPING or RUNNABLE) of each process
  // see enum procstate
  int state[NPROC];  
  // number of ticks each process has accumulated 
  // RUNNING/SCHEDULED at each of 4 priorities
  int ticks[NPROC][4];  
  // number of ticks each process has waited before being scheduled
  int wait_ticks[NPROC][4]; 
};

extern struct pstat kernel_pstat;  // 커널 내부 상태 추적용

#endif // _PSTAT_H_