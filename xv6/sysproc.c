#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_printpt(void)
{
  int pid;
  if (argint(0, &pid) < 0)
        return -1;
  return printpt(pid);
}

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}
int
sys_uthread_init(void)
{
    // 시스템콜의 인자값을 받아온다.
    int address;
    if (argint(0, &address) < 0)
        return -1;
    // proc.c의 uthread_init() 함수 호출
    return uthread_init(address);
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;
  struct proc* p = myproc();
  if(argint(0, &n) < 0)
    return -1;
  // addr = 메모리를 늘리기 전 주소
  addr = p->sz;
  if (n > 0)
  { 
    if (PGROUNDUP(p->sz + n) >= p->tf->esp){
      kill(p->pid);
      return -1;
    }
    else{
      uint oldsz = PGROUNDUP(p->sz);
      uint newsz = p->sz + n;
      p->sz = newsz;
      for(; oldsz < newsz; oldsz += PGSIZE){
      pte_t *pte = walkpgdir(p->pgdir, (void*)oldsz, 1);
      if (pte == 0)
        return -1;
      // cprintf("pgtab %x\n",*pte);
      }
      switchuvm(p);
    }
  }
  // 메모리 할당을 해제할 때는 바로 해제
  else if (n<0)
  {
    cprintf("[sbrk] sz %x \n",p->sz);
    if(growproc(n) < 0)
      return -1;
    cprintf("[sbrk] sz %x \n",p->sz);
    cprintf("[sbrk] addr %x \n", addr);
    cprintf("[sbrk] esp %x eip %x \n",p->tf->esp, p->tf->eip);
  }
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}
