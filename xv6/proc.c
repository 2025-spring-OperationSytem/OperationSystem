#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#include "debug.h"
#include "pstat.h"

struct pstat kernel_pstat;
struct proc* mlfq_queues[4][NPROC];

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void run_mlfq(int tracking, int boosting);
void enqueue(struct proc *p, int level);
int get_sched_policy(void);

struct proc* dequeue(int level);

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

// Must be called with interrupts disabled
int
cpuid() {
  return mycpu()-cpus;
}

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
  int apicid, i;
  
  if(readeflags()&FL_IF){
    panic("mycpu called with interrupts enabled\n");
  }

  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid){
      return &cpus[i];
    }
  }
  panic("unknown apicid\n");
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
  c = mycpu();
  p = c->proc;
  popcli();
  return p;
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED){
      goto found;
    }

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid;
  nextpid++;

  int i = p - ptable.proc; // kernel_pstat 인덱스 계산
  kernel_pstat.inuse[i] = 1;
  kernel_pstat.pid[i] = p->pid;
  kernel_pstat.priority[i] = 3; // 기본 우선순위 (Q3)
  memset(kernel_pstat.ticks[i], 0, sizeof(kernel_pstat.ticks[i]));
  memset(kernel_pstat.wait_ticks[i], 0, sizeof(kernel_pstat.wait_ticks[i]));

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    cprintf("[ALLOC ERROR] kstack alloc failed for PID=%d\n", p->pid);
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
  
  initproc = p;
  if((p->pgdir = setupkvm()) == 0){
    panic("userinit: out of memory?");
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);

  p->state = RUNNABLE;
  release(&ptable.lock);
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *curproc = myproc();

  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
  switchuvm(curproc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();

  // Allocate process.
  if ((np = allocproc()) == 0) {
    return -1;
  }

  // Copy process state from proc.
  if ((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0) {
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
  np->parent = curproc;
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for (i = 0; i < NOFILE; i++)
    if (curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));

  pid = np->pid;

  acquire(&ptable.lock);

  np->state = RUNNABLE;

  // MLFQ용 kernel_pstat 등록
  int idx = np - ptable.proc;
  kernel_pstat.inuse[idx] = 1;
  kernel_pstat.pid[idx] = np->pid;
  kernel_pstat.priority[idx] = 3;
  memset(kernel_pstat.ticks[idx], 0, sizeof(kernel_pstat.ticks[idx]));
  memset(kernel_pstat.wait_ticks[idx], 0, sizeof(kernel_pstat.wait_ticks[idx]));

  if (mycpu()->sched_policy > 0)
    enqueue(np, 3);

  release(&ptable.lock);

  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;
  
  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd]){
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(curproc->cwd);
  end_op();
  curproc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curproc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  //kerner_pstat 상태 제거
  int i = curproc - ptable.proc;
  int q;
  q = kernel_pstat.priority[i];
  if (get_sched_policy() > 0)
  {
    dequeue(q);
    cprintf("[PROCESS EXIT] pid: %d\n", curproc->pid);
  }
  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;

  for(;;){
    sti();
    acquire(&ptable.lock);

    if (c->sched_policy == 0) {
      for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
        if(p->state != RUNNABLE)
          continue;
        c->proc = p;
        switchuvm(p);
        p->state = RUNNING;
        swtch(&(c->scheduler), p->context);
        switchkvm();
        c->proc = 0;
      }
      // for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      //   if(p->state == RUNNABLE && p != c->proc){
      //     int i = p - ptable.proc;
      //     kernel_pstat.wait_ticks[i][kernel_pstat.priority[i]]++;
      //   }
      // }
    } else if (c->sched_policy == 1) {
      run_mlfq(1, 1);
    } else if (c->sched_policy == 2) {
      run_mlfq(0, 1);
    } else if (c->sched_policy == 3) {
      run_mlfq(1, 0);
    }
    release(&ptable.lock);
  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = mycpu()->intena;
  swtch(&p->context, mycpu()->scheduler);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  myproc()->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  if(p == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;
  enqueue(chan,3);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan){
      p->state = RUNNABLE;
    }
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}

//현재 커널의 프로세스 상태들을 pstat에 담아서 유저에게 전달해주는 시스템 콜
int getpinfo(struct pstat *pstat) {
  acquire(&ptable.lock);
  for (int i = 0; i < NPROC; i++) {
    pstat->inuse[i] = kernel_pstat.inuse[i];
    pstat->pid[i] = kernel_pstat.pid[i];
    pstat->priority[i] = kernel_pstat.priority[i];
    pstat->state[i] = ptable.proc[i].state; // proc에서 유일하게 읽기 가능

    for (int j = 0; j < 4; j++) {
      pstat->ticks[i][j] = kernel_pstat.ticks[i][j];
      pstat->wait_ticks[i][j] = kernel_pstat.wait_ticks[i][j];
    }
  }
  release(&ptable.lock);
  return 0;
}

void mlfq_enqueue_all_runnable(void) {
  acquire(&ptable.lock);
  for (int i = 0; i < NPROC; i++) {
    if (!kernel_pstat.inuse[i]) continue;
    struct proc *p = &ptable.proc[i];
    if (p->state == RUNNABLE || p->state == RUNNING) {
      int q = kernel_pstat.priority[i];
      enqueue(p, q);
      //cprintf("[AUTO-ENQUEUE] PID %d -> Q%d\n", p->pid, q);
    }
  }
  release(&ptable.lock);
}

int
set_sched_policy(int policy)
{
  if (policy < 0 || policy > 3)
    return -1;

  pushcli(); 
  mycpu()->sched_policy = policy;
  popcli();

  if (policy > 0)
  mlfq_enqueue_all_runnable();

  return 0;
}
int
get_sched_policy(void)
{
  pushcli();  
  int policy = mycpu()->sched_policy;
  popcli();   
  return policy;
}


// 각 우선순위 큐 (Q3: 가장 높은 우선순위 ~ Q0: 가장 낮은 우선순위)
struct proc* mlfq_queues[4][NPROC];
int q_front[4] = {0};
int q_back[4] = {0};

// Enqueue 함수
void
enqueue(struct proc *p, int level) {
  for (int i = 0; i < NPROC; i++)
    if (mlfq_queues[level][i] == p) return;
  for (int i = 0; i < NPROC; i++)
    if (mlfq_queues[level][i] == 0) {
      mlfq_queues[level][i] = p;
      return;
    }
}

struct proc*
dequeue(int level) {
  struct proc* p = 0;
  for (int i = 0; i < NPROC; i++) {
    if (mlfq_queues[level][i]) {
      p = mlfq_queues[level][i];
      for (int j = i; j < NPROC - 1; j++)
        mlfq_queues[level][j] = mlfq_queues[level][j+1];
      mlfq_queues[level][NPROC - 1] = 0;
      break;
    }
  }
  return p;
}

// Boosting 조건 검사
void apply_priority_boosting(void) {
  for (int i = 0; i < NPROC; i++) {
    if (!kernel_pstat.inuse[i]) continue;
    int q = kernel_pstat.priority[i];
    int waited = kernel_pstat.wait_ticks[i][q];

    if (q == 2 && waited >= 80) {
      kernel_pstat.priority[i] = 3;
      kernel_pstat.wait_ticks[i][2] = 0;
      cprintf("[BOOST] PID %d Q2→Q3 (waited=%d)\n", kernel_pstat.pid[i], waited);
      enqueue(&ptable.proc[i], 3);
    } else if (q == 1 && waited >= 160) {
      kernel_pstat.priority[i] = 2;
      kernel_pstat.wait_ticks[i][1] = 0;
      cprintf("[BOOST] PID %d Q1→Q2 (waited=%d)\n", kernel_pstat.pid[i], waited);
      enqueue(&ptable.proc[i], 2);
    } else if (q == 0 && waited >= 250) {
      int pid = kernel_pstat.pid[i];
      int executed_ticks = kernel_pstat.ticks[i][0];
      int wait_ticks = kernel_pstat.wait_ticks[i][0];
    
      kernel_pstat.priority[i] = 1;
      kernel_pstat.wait_ticks[i][0] = 0;
    
      cprintf("[BOOST] PID %d Q0→Q1 (waited=%d, ticks=%d)\n", pid, wait_ticks, executed_ticks);
    
      enqueue(&ptable.proc[i], 1);
    }
  }
}

// Time slice 계산
int get_time_slice(int level) {
  if (level == 3) return 8;
  if (level == 2) return 16;
  if (level == 1) return 32;
  return -1; // FIFO (Q0)
}

void
run_process(struct proc* p, int q, int slice, int tracking) {
  struct cpu *c = mycpu();
  c->proc = p;
  switchuvm(p);
  p->state = RUNNING;
  int i = p - ptable.proc;
  // cprintf("[RUN_PROCESS] PID %d starts at Q%d\n", p->pid, q);
  swtch(&(c->scheduler), p->context);
  switchkvm();
  c->proc = 0;
  if (tracking) kernel_pstat.ticks[i][q]++;
  if (slice != -1 && kernel_pstat.ticks[i][q] >= slice && q > 0) {
    kernel_pstat.priority[i] = q - 1;
    kernel_pstat.ticks[i][q] = 0;
    enqueue(p, q - 1);
  } else if (q == 0) {
  //cprintf("[EXIT_FIFO] PID %d finished Q0 execution (no re-enqueue)\n", p->pid);
  } else {
  //  cprintf("[RE-ENQUEUE] PID %d stays in Q%d\n", p->pid, q);
    enqueue(p, q);
  }
}

// MLFQ 스케줄러 진입점
void
run_mlfq(int tracking, int boosting) {
  if (boosting)
    apply_priority_boosting();

  for (int q = 3; q >= 0; q--) {
    for (int i = 0; i < NPROC; i++) {
      struct proc *p = mlfq_queues[q][i];
      if (p == 0 || p->state != RUNNABLE)
        continue;
      if (q != 0)
        dequeue(q);
      int slice = get_time_slice(q);
      run_process(p, q, slice, tracking);
      goto tick_update;
    }
  }

tick_update:
  if (!tracking) return;
  for (int i = 0; i < NPROC; i++) {
    struct proc* p = &ptable.proc[i];
    if (!kernel_pstat.inuse[i]) continue;
    if (p->state == RUNNABLE && p != mycpu()->proc) {
      int q = kernel_pstat.priority[i];
      kernel_pstat.wait_ticks[i][q]++;
    }
  }
}