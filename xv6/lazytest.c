#include "param.h"
#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "syscall.h"
#include "memlayout.h"
#include "x86.h"
#include "mmu.h"

// 0x40000000
#define REGION_SZ (1024 * 1024 * 1024)

void
sparse_memory(char *s)  
{
  char *i, *prev_end, *new_end;
  // 문제 요구사항 
  // sbrk가 미리 할당을 하지 않고 pagefault가 발생하면 
  // 할당하는 방식으로 lazytest를 구현해야 한다.

  // sbrk는 sbrk로 값을 늘리기 전의 sz를 반환하기 때문에 조건에 걸리지 않고 지나간다.
  // prev_end에는 메모리 할당 전의 유저공간의 끝 주소가 담긴다. 
  prev_end = sbrk(REGION_SZ);
  if (prev_end == (char*)0xffffffffffffffffL) {
    printf(1,"sbrk() failed\n");
    exit();
  }
  new_end = prev_end + REGION_SZ;
  // i를 page size 만큼씩 키워 0x40000000 공간에 각각 할당하여
  // pagefault를 발생시켜 메모리 할당이 제대로 되는지 확인한다.
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
    *(char **)i = i;

  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
    if (*(char **)i != i) {
      printf(1,"failed to read value from memory\n");
      exit();
    }
  }

  exit();
}

void
sparse_memory_unmap(char *s)
{
  int pid;
  char *i, *prev_end, *new_end;

  prev_end = sbrk(REGION_SZ);
  if (prev_end == (char*)0xffffffffffffffffL) {
    printf(1,"sbrk() failed\n");
    exit();
  }
  new_end = prev_end + REGION_SZ;

  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
    *(char **)i = i;

  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
    // 자식 프로세스를 생성하여 unmap이 제대로 실행되는지 확인
    pid = fork();
    if (pid < 0) {
      printf(1,"error forking\n");
      exit();
    } else if (pid == 0) {
      sbrk(-1L * REGION_SZ);
      *(char **)i = i;
      exit();
    } else {
      wait();
      printf(1,"memory not unmapped\n");
      exit();
    }
  }
  exit();
}

void
oom(char *s)
{
  void *m1, *m2;
  int pid;

  // out of memory를 테스트하는 함수
  if((pid = fork()) == 0){
    m1 = 0;
    // m2에 16MB 만큼의 메모리를 계속 할당
    // 메모리가 가득 차면 루프 탈출
    while((m2 = malloc(4096*4096)) != 0){
      *(char**)m2 = m1;
      m1 = m2;
    }
    exit();
  } else {
    wait();
    printf(1,"oomtest end\n");
    exit();
  }
}

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
  int pid;
  
  printf(1,"running test %s\n", s);
  if((pid = fork()) < 0) {
    printf(1,"runtest: fork error\n");
    exit();
  }
  if(pid == 0) {
    f(s);
    exit();
  } else {
    wait();
    return 1;
  }
}

int
main(int argc, char *argv[])
{
  char *n = 0;
  if(argc > 1) {
    n = argv[1];
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    { sparse_memory, "lazy alloc"},
    { sparse_memory_unmap, "lazy unmap"},
    { oom, "out of memory"},
    { 0, 0},
  };
    
  printf(1,"lazytests starting\n");
  // 위 함수들을 한 번씩 실행시킨다.
  for (struct test *t = tests; t->s != 0; t++) {
    if((n == 0) || strcmp(t->s, n) == 0) {
      run(t->f, t->s);
    }
  }
  printf(1,"ALL TESTS ENDED\n");
  exit();   // not reached.
}
