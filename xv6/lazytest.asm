
_lazytest:     file format elf32-i386


Disassembly of section .text:

00000000 <sparse_memory>:
// 0x40000000
#define REGION_SZ (1024 * 1024 * 1024)

void
sparse_memory(char *s)  
{
   0:	f3 0f 1e fb          	endbr32
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 ec 18             	sub    $0x18,%esp
  // sbrk가 미리 할당을 하지 않고 pagefault가 발생하면 
  // 할당하는 방식으로 lazytest를 구현해야 한다.

  // sbrk는 sbrk로 값을 늘리기 전의 sz를 반환하기 때문에 조건에 걸리지 않고 지나간다.
  // prev_end에는 메모리 할당 전의 유저공간의 끝 주소가 담긴다. 
  prev_end = sbrk(REGION_SZ);
   a:	83 ec 0c             	sub    $0xc,%esp
   d:	68 00 00 00 40       	push   $0x40000000
  12:	e8 28 06 00 00       	call   63f <sbrk>
  17:	83 c4 10             	add    $0x10,%esp
  1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (prev_end == (char*)0xffffffffffffffffL) {
  1d:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
  21:	75 17                	jne    3a <sparse_memory+0x3a>
    printf(1,"sbrk() failed\n");
  23:	83 ec 08             	sub    $0x8,%esp
  26:	68 0c 0b 00 00       	push   $0xb0c
  2b:	6a 01                	push   $0x1
  2d:	e8 11 07 00 00       	call   743 <printf>
  32:	83 c4 10             	add    $0x10,%esp
    exit();
  35:	e8 7d 05 00 00       	call   5b7 <exit>
  }
  new_end = prev_end + REGION_SZ;
  3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  3d:	05 00 00 00 40       	add    $0x40000000,%eax
  42:	89 45 ec             	mov    %eax,-0x14(%ebp)
  // i를 page size 만큼씩 키워 0x40000000 공간에 각각 할당하여
  // pagefault를 발생시켜 메모리 할당이 제대로 되는지 확인한다.
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
  45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  48:	05 00 10 00 00       	add    $0x1000,%eax
  4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  50:	eb 0f                	jmp    61 <sparse_memory+0x61>
    *(char **)i = i;
  52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  55:	8b 55 f4             	mov    -0xc(%ebp),%edx
  58:	89 10                	mov    %edx,(%eax)
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
  5a:	81 45 f4 00 00 04 00 	addl   $0x40000,-0xc(%ebp)
  61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  64:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  67:	72 e9                	jb     52 <sparse_memory+0x52>

  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
  69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  6c:	05 00 10 00 00       	add    $0x1000,%eax
  71:	89 45 f4             	mov    %eax,-0xc(%ebp)
  74:	eb 28                	jmp    9e <sparse_memory+0x9e>
    if (*(char **)i != i) {
  76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  79:	8b 00                	mov    (%eax),%eax
  7b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  7e:	74 17                	je     97 <sparse_memory+0x97>
      printf(1,"failed to read value from memory\n");
  80:	83 ec 08             	sub    $0x8,%esp
  83:	68 1c 0b 00 00       	push   $0xb1c
  88:	6a 01                	push   $0x1
  8a:	e8 b4 06 00 00       	call   743 <printf>
  8f:	83 c4 10             	add    $0x10,%esp
      exit();
  92:	e8 20 05 00 00       	call   5b7 <exit>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
  97:	81 45 f4 00 00 04 00 	addl   $0x40000,-0xc(%ebp)
  9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  a1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  a4:	72 d0                	jb     76 <sparse_memory+0x76>
    }
  }

  exit();
  a6:	e8 0c 05 00 00       	call   5b7 <exit>

000000ab <sparse_memory_unmap>:
}

void
sparse_memory_unmap(char *s)
{
  ab:	f3 0f 1e fb          	endbr32
  af:	55                   	push   %ebp
  b0:	89 e5                	mov    %esp,%ebp
  b2:	83 ec 18             	sub    $0x18,%esp
  int pid;
  char *i, *prev_end, *new_end;

  prev_end = sbrk(REGION_SZ);
  b5:	83 ec 0c             	sub    $0xc,%esp
  b8:	68 00 00 00 40       	push   $0x40000000
  bd:	e8 7d 05 00 00       	call   63f <sbrk>
  c2:	83 c4 10             	add    $0x10,%esp
  c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (prev_end == (char*)0xffffffffffffffffL) {
  c8:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
  cc:	75 17                	jne    e5 <sparse_memory_unmap+0x3a>
    printf(1,"sbrk() failed\n");
  ce:	83 ec 08             	sub    $0x8,%esp
  d1:	68 0c 0b 00 00       	push   $0xb0c
  d6:	6a 01                	push   $0x1
  d8:	e8 66 06 00 00       	call   743 <printf>
  dd:	83 c4 10             	add    $0x10,%esp
    exit();
  e0:	e8 d2 04 00 00       	call   5b7 <exit>
  }
  new_end = prev_end + REGION_SZ;
  e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  e8:	05 00 00 00 40       	add    $0x40000000,%eax
  ed:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
  f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  f3:	05 00 10 00 00       	add    $0x1000,%eax
  f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  fb:	eb 0f                	jmp    10c <sparse_memory_unmap+0x61>
    *(char **)i = i;
  fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 100:	8b 55 f4             	mov    -0xc(%ebp),%edx
 103:	89 10                	mov    %edx,(%eax)
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
 105:	81 45 f4 00 00 00 01 	addl   $0x1000000,-0xc(%ebp)
 10c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 10f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 112:	72 e9                	jb     fd <sparse_memory_unmap+0x52>

  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
 114:	8b 45 f0             	mov    -0x10(%ebp),%eax
 117:	05 00 10 00 00       	add    $0x1000,%eax
 11c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 11f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 122:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 125:	73 64                	jae    18b <sparse_memory_unmap+0xe0>
    // 자식 프로세스를 생성하여 unmap이 제대로 실행되는지 확인
    pid = fork();
 127:	e8 83 04 00 00       	call   5af <fork>
 12c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (pid < 0) {
 12f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 133:	79 17                	jns    14c <sparse_memory_unmap+0xa1>
      printf(1,"error forking\n");
 135:	83 ec 08             	sub    $0x8,%esp
 138:	68 3e 0b 00 00       	push   $0xb3e
 13d:	6a 01                	push   $0x1
 13f:	e8 ff 05 00 00       	call   743 <printf>
 144:	83 c4 10             	add    $0x10,%esp
      exit();
 147:	e8 6b 04 00 00       	call   5b7 <exit>
    } else if (pid == 0) {
 14c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 150:	75 1d                	jne    16f <sparse_memory_unmap+0xc4>
      sbrk(-1L * REGION_SZ);
 152:	83 ec 0c             	sub    $0xc,%esp
 155:	68 00 00 00 c0       	push   $0xc0000000
 15a:	e8 e0 04 00 00       	call   63f <sbrk>
 15f:	83 c4 10             	add    $0x10,%esp
      *(char **)i = i;
 162:	8b 45 f4             	mov    -0xc(%ebp),%eax
 165:	8b 55 f4             	mov    -0xc(%ebp),%edx
 168:	89 10                	mov    %edx,(%eax)
      exit();
 16a:	e8 48 04 00 00       	call   5b7 <exit>
    } else {
      wait();
 16f:	e8 4b 04 00 00       	call   5bf <wait>
      printf(1,"memory not unmapped\n");
 174:	83 ec 08             	sub    $0x8,%esp
 177:	68 4d 0b 00 00       	push   $0xb4d
 17c:	6a 01                	push   $0x1
 17e:	e8 c0 05 00 00       	call   743 <printf>
 183:	83 c4 10             	add    $0x10,%esp
      exit();
 186:	e8 2c 04 00 00       	call   5b7 <exit>
    }
  }
  exit();
 18b:	e8 27 04 00 00       	call   5b7 <exit>

00000190 <oom>:
}

void
oom(char *s)
{
 190:	f3 0f 1e fb          	endbr32
 194:	55                   	push   %ebp
 195:	89 e5                	mov    %esp,%ebp
 197:	83 ec 18             	sub    $0x18,%esp
  void *m1, *m2;
  int pid;

  // out of memory를 테스트하는 함수
  if((pid = fork()) == 0){
 19a:	e8 10 04 00 00       	call   5af <fork>
 19f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 1a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1a6:	75 35                	jne    1dd <oom+0x4d>
    m1 = 0;
 1a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    // m2에 16MB 만큼의 메모리를 계속 할당
    // 메모리가 가득 차면 루프 탈출
    while((m2 = malloc(4096*4096)) != 0){
 1af:	eb 0e                	jmp    1bf <oom+0x2f>
      *(char**)m2 = m1;
 1b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1b7:	89 10                	mov    %edx,(%eax)
      m1 = m2;
 1b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while((m2 = malloc(4096*4096)) != 0){
 1bf:	83 ec 0c             	sub    $0xc,%esp
 1c2:	68 00 00 00 01       	push   $0x1000000
 1c7:	e8 57 08 00 00       	call   a23 <malloc>
 1cc:	83 c4 10             	add    $0x10,%esp
 1cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
 1d2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 1d6:	75 d9                	jne    1b1 <oom+0x21>
    }
    exit();
 1d8:	e8 da 03 00 00       	call   5b7 <exit>
  } else {
    wait();
 1dd:	e8 dd 03 00 00       	call   5bf <wait>
    printf(1,"oomtest end\n");
 1e2:	83 ec 08             	sub    $0x8,%esp
 1e5:	68 62 0b 00 00       	push   $0xb62
 1ea:	6a 01                	push   $0x1
 1ec:	e8 52 05 00 00       	call   743 <printf>
 1f1:	83 c4 10             	add    $0x10,%esp
    exit();
 1f4:	e8 be 03 00 00       	call   5b7 <exit>

000001f9 <run>:
}

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
 1f9:	f3 0f 1e fb          	endbr32
 1fd:	55                   	push   %ebp
 1fe:	89 e5                	mov    %esp,%ebp
 200:	83 ec 18             	sub    $0x18,%esp
  int pid;
  
  printf(1,"running test %s\n", s);
 203:	83 ec 04             	sub    $0x4,%esp
 206:	ff 75 0c             	push   0xc(%ebp)
 209:	68 6f 0b 00 00       	push   $0xb6f
 20e:	6a 01                	push   $0x1
 210:	e8 2e 05 00 00       	call   743 <printf>
 215:	83 c4 10             	add    $0x10,%esp
  if((pid = fork()) < 0) {
 218:	e8 92 03 00 00       	call   5af <fork>
 21d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 220:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 224:	79 17                	jns    23d <run+0x44>
    printf(1,"runtest: fork error\n");
 226:	83 ec 08             	sub    $0x8,%esp
 229:	68 80 0b 00 00       	push   $0xb80
 22e:	6a 01                	push   $0x1
 230:	e8 0e 05 00 00       	call   743 <printf>
 235:	83 c4 10             	add    $0x10,%esp
    exit();
 238:	e8 7a 03 00 00       	call   5b7 <exit>
  }
  if(pid == 0) {
 23d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 241:	75 13                	jne    256 <run+0x5d>
    f(s);
 243:	83 ec 0c             	sub    $0xc,%esp
 246:	ff 75 0c             	push   0xc(%ebp)
 249:	8b 45 08             	mov    0x8(%ebp),%eax
 24c:	ff d0                	call   *%eax
 24e:	83 c4 10             	add    $0x10,%esp
    exit();
 251:	e8 61 03 00 00       	call   5b7 <exit>
  } else {
    wait();
 256:	e8 64 03 00 00       	call   5bf <wait>
    return 1;
 25b:	b8 01 00 00 00       	mov    $0x1,%eax
  }
}
 260:	c9                   	leave
 261:	c3                   	ret

00000262 <main>:

int
main(int argc, char *argv[])
{
 262:	f3 0f 1e fb          	endbr32
 266:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 26a:	83 e4 f0             	and    $0xfffffff0,%esp
 26d:	ff 71 fc             	push   -0x4(%ecx)
 270:	55                   	push   %ebp
 271:	89 e5                	mov    %esp,%ebp
 273:	51                   	push   %ecx
 274:	83 ec 34             	sub    $0x34,%esp
 277:	89 c8                	mov    %ecx,%eax
  char *n = 0;
 279:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(argc > 1) {
 280:	83 38 01             	cmpl   $0x1,(%eax)
 283:	7e 09                	jle    28e <main+0x2c>
    n = argv[1];
 285:	8b 40 04             	mov    0x4(%eax),%eax
 288:	8b 40 04             	mov    0x4(%eax),%eax
 28b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
 28e:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
 295:	c7 45 d4 95 0b 00 00 	movl   $0xb95,-0x2c(%ebp)
 29c:	c7 45 d8 ab 00 00 00 	movl   $0xab,-0x28(%ebp)
 2a3:	c7 45 dc a0 0b 00 00 	movl   $0xba0,-0x24(%ebp)
 2aa:	c7 45 e0 90 01 00 00 	movl   $0x190,-0x20(%ebp)
 2b1:	c7 45 e4 ab 0b 00 00 	movl   $0xbab,-0x1c(%ebp)
 2b8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
 2bf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    { sparse_memory_unmap, "lazy unmap"},
    { oom, "out of memory"},
    { 0, 0},
  };
    
  printf(1,"lazytests starting\n");
 2c6:	83 ec 08             	sub    $0x8,%esp
 2c9:	68 b9 0b 00 00       	push   $0xbb9
 2ce:	6a 01                	push   $0x1
 2d0:	e8 6e 04 00 00       	call   743 <printf>
 2d5:	83 c4 10             	add    $0x10,%esp
  // 위 함수들을 한 번씩 실행시킨다.
  for (struct test *t = tests; t->s != 0; t++) {
 2d8:	8d 45 d0             	lea    -0x30(%ebp),%eax
 2db:	89 45 f0             	mov    %eax,-0x10(%ebp)
 2de:	eb 3b                	jmp    31b <main+0xb9>
    if((n == 0) || strcmp(t->s, n) == 0) {
 2e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2e4:	74 19                	je     2ff <main+0x9d>
 2e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2e9:	8b 40 04             	mov    0x4(%eax),%eax
 2ec:	83 ec 08             	sub    $0x8,%esp
 2ef:	ff 75 f4             	push   -0xc(%ebp)
 2f2:	50                   	push   %eax
 2f3:	e8 9e 00 00 00       	call   396 <strcmp>
 2f8:	83 c4 10             	add    $0x10,%esp
 2fb:	85 c0                	test   %eax,%eax
 2fd:	75 18                	jne    317 <main+0xb5>
      run(t->f, t->s);
 2ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
 302:	8b 50 04             	mov    0x4(%eax),%edx
 305:	8b 45 f0             	mov    -0x10(%ebp),%eax
 308:	8b 00                	mov    (%eax),%eax
 30a:	83 ec 08             	sub    $0x8,%esp
 30d:	52                   	push   %edx
 30e:	50                   	push   %eax
 30f:	e8 e5 fe ff ff       	call   1f9 <run>
 314:	83 c4 10             	add    $0x10,%esp
  for (struct test *t = tests; t->s != 0; t++) {
 317:	83 45 f0 08          	addl   $0x8,-0x10(%ebp)
 31b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 31e:	8b 40 04             	mov    0x4(%eax),%eax
 321:	85 c0                	test   %eax,%eax
 323:	75 bb                	jne    2e0 <main+0x7e>
    }
  }
  printf(1,"ALL TESTS ENDED\n");
 325:	83 ec 08             	sub    $0x8,%esp
 328:	68 cd 0b 00 00       	push   $0xbcd
 32d:	6a 01                	push   $0x1
 32f:	e8 0f 04 00 00       	call   743 <printf>
 334:	83 c4 10             	add    $0x10,%esp
  exit();   // not reached.
 337:	e8 7b 02 00 00       	call   5b7 <exit>

0000033c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 33c:	55                   	push   %ebp
 33d:	89 e5                	mov    %esp,%ebp
 33f:	57                   	push   %edi
 340:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 341:	8b 4d 08             	mov    0x8(%ebp),%ecx
 344:	8b 55 10             	mov    0x10(%ebp),%edx
 347:	8b 45 0c             	mov    0xc(%ebp),%eax
 34a:	89 cb                	mov    %ecx,%ebx
 34c:	89 df                	mov    %ebx,%edi
 34e:	89 d1                	mov    %edx,%ecx
 350:	fc                   	cld
 351:	f3 aa                	rep stos %al,%es:(%edi)
 353:	89 ca                	mov    %ecx,%edx
 355:	89 fb                	mov    %edi,%ebx
 357:	89 5d 08             	mov    %ebx,0x8(%ebp)
 35a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 35d:	90                   	nop
 35e:	5b                   	pop    %ebx
 35f:	5f                   	pop    %edi
 360:	5d                   	pop    %ebp
 361:	c3                   	ret

00000362 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 362:	f3 0f 1e fb          	endbr32
 366:	55                   	push   %ebp
 367:	89 e5                	mov    %esp,%ebp
 369:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 36c:	8b 45 08             	mov    0x8(%ebp),%eax
 36f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 372:	90                   	nop
 373:	8b 55 0c             	mov    0xc(%ebp),%edx
 376:	8d 42 01             	lea    0x1(%edx),%eax
 379:	89 45 0c             	mov    %eax,0xc(%ebp)
 37c:	8b 45 08             	mov    0x8(%ebp),%eax
 37f:	8d 48 01             	lea    0x1(%eax),%ecx
 382:	89 4d 08             	mov    %ecx,0x8(%ebp)
 385:	0f b6 12             	movzbl (%edx),%edx
 388:	88 10                	mov    %dl,(%eax)
 38a:	0f b6 00             	movzbl (%eax),%eax
 38d:	84 c0                	test   %al,%al
 38f:	75 e2                	jne    373 <strcpy+0x11>
    ;
  return os;
 391:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 394:	c9                   	leave
 395:	c3                   	ret

00000396 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 396:	f3 0f 1e fb          	endbr32
 39a:	55                   	push   %ebp
 39b:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 39d:	eb 08                	jmp    3a7 <strcmp+0x11>
    p++, q++;
 39f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 3a7:	8b 45 08             	mov    0x8(%ebp),%eax
 3aa:	0f b6 00             	movzbl (%eax),%eax
 3ad:	84 c0                	test   %al,%al
 3af:	74 10                	je     3c1 <strcmp+0x2b>
 3b1:	8b 45 08             	mov    0x8(%ebp),%eax
 3b4:	0f b6 10             	movzbl (%eax),%edx
 3b7:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ba:	0f b6 00             	movzbl (%eax),%eax
 3bd:	38 c2                	cmp    %al,%dl
 3bf:	74 de                	je     39f <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 3c1:	8b 45 08             	mov    0x8(%ebp),%eax
 3c4:	0f b6 00             	movzbl (%eax),%eax
 3c7:	0f b6 d0             	movzbl %al,%edx
 3ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cd:	0f b6 00             	movzbl (%eax),%eax
 3d0:	0f b6 c0             	movzbl %al,%eax
 3d3:	29 c2                	sub    %eax,%edx
 3d5:	89 d0                	mov    %edx,%eax
}
 3d7:	5d                   	pop    %ebp
 3d8:	c3                   	ret

000003d9 <strlen>:

uint
strlen(char *s)
{
 3d9:	f3 0f 1e fb          	endbr32
 3dd:	55                   	push   %ebp
 3de:	89 e5                	mov    %esp,%ebp
 3e0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3e3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3ea:	eb 04                	jmp    3f0 <strlen+0x17>
 3ec:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3f0:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3f3:	8b 45 08             	mov    0x8(%ebp),%eax
 3f6:	01 d0                	add    %edx,%eax
 3f8:	0f b6 00             	movzbl (%eax),%eax
 3fb:	84 c0                	test   %al,%al
 3fd:	75 ed                	jne    3ec <strlen+0x13>
    ;
  return n;
 3ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 402:	c9                   	leave
 403:	c3                   	ret

00000404 <memset>:

void*
memset(void *dst, int c, uint n)
{
 404:	f3 0f 1e fb          	endbr32
 408:	55                   	push   %ebp
 409:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 40b:	8b 45 10             	mov    0x10(%ebp),%eax
 40e:	50                   	push   %eax
 40f:	ff 75 0c             	push   0xc(%ebp)
 412:	ff 75 08             	push   0x8(%ebp)
 415:	e8 22 ff ff ff       	call   33c <stosb>
 41a:	83 c4 0c             	add    $0xc,%esp
  return dst;
 41d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 420:	c9                   	leave
 421:	c3                   	ret

00000422 <strchr>:

char*
strchr(const char *s, char c)
{
 422:	f3 0f 1e fb          	endbr32
 426:	55                   	push   %ebp
 427:	89 e5                	mov    %esp,%ebp
 429:	83 ec 04             	sub    $0x4,%esp
 42c:	8b 45 0c             	mov    0xc(%ebp),%eax
 42f:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 432:	eb 14                	jmp    448 <strchr+0x26>
    if(*s == c)
 434:	8b 45 08             	mov    0x8(%ebp),%eax
 437:	0f b6 00             	movzbl (%eax),%eax
 43a:	38 45 fc             	cmp    %al,-0x4(%ebp)
 43d:	75 05                	jne    444 <strchr+0x22>
      return (char*)s;
 43f:	8b 45 08             	mov    0x8(%ebp),%eax
 442:	eb 13                	jmp    457 <strchr+0x35>
  for(; *s; s++)
 444:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 448:	8b 45 08             	mov    0x8(%ebp),%eax
 44b:	0f b6 00             	movzbl (%eax),%eax
 44e:	84 c0                	test   %al,%al
 450:	75 e2                	jne    434 <strchr+0x12>
  return 0;
 452:	b8 00 00 00 00       	mov    $0x0,%eax
}
 457:	c9                   	leave
 458:	c3                   	ret

00000459 <gets>:

char*
gets(char *buf, int max)
{
 459:	f3 0f 1e fb          	endbr32
 45d:	55                   	push   %ebp
 45e:	89 e5                	mov    %esp,%ebp
 460:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 463:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 46a:	eb 42                	jmp    4ae <gets+0x55>
    cc = read(0, &c, 1);
 46c:	83 ec 04             	sub    $0x4,%esp
 46f:	6a 01                	push   $0x1
 471:	8d 45 ef             	lea    -0x11(%ebp),%eax
 474:	50                   	push   %eax
 475:	6a 00                	push   $0x0
 477:	e8 53 01 00 00       	call   5cf <read>
 47c:	83 c4 10             	add    $0x10,%esp
 47f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 482:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 486:	7e 33                	jle    4bb <gets+0x62>
      break;
    buf[i++] = c;
 488:	8b 45 f4             	mov    -0xc(%ebp),%eax
 48b:	8d 50 01             	lea    0x1(%eax),%edx
 48e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 491:	89 c2                	mov    %eax,%edx
 493:	8b 45 08             	mov    0x8(%ebp),%eax
 496:	01 c2                	add    %eax,%edx
 498:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 49c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 49e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4a2:	3c 0a                	cmp    $0xa,%al
 4a4:	74 16                	je     4bc <gets+0x63>
 4a6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4aa:	3c 0d                	cmp    $0xd,%al
 4ac:	74 0e                	je     4bc <gets+0x63>
  for(i=0; i+1 < max; ){
 4ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b1:	83 c0 01             	add    $0x1,%eax
 4b4:	39 45 0c             	cmp    %eax,0xc(%ebp)
 4b7:	7f b3                	jg     46c <gets+0x13>
 4b9:	eb 01                	jmp    4bc <gets+0x63>
      break;
 4bb:	90                   	nop
      break;
  }
  buf[i] = '\0';
 4bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4bf:	8b 45 08             	mov    0x8(%ebp),%eax
 4c2:	01 d0                	add    %edx,%eax
 4c4:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4c7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4ca:	c9                   	leave
 4cb:	c3                   	ret

000004cc <stat>:

int
stat(char *n, struct stat *st)
{
 4cc:	f3 0f 1e fb          	endbr32
 4d0:	55                   	push   %ebp
 4d1:	89 e5                	mov    %esp,%ebp
 4d3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4d6:	83 ec 08             	sub    $0x8,%esp
 4d9:	6a 00                	push   $0x0
 4db:	ff 75 08             	push   0x8(%ebp)
 4de:	e8 14 01 00 00       	call   5f7 <open>
 4e3:	83 c4 10             	add    $0x10,%esp
 4e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4ed:	79 07                	jns    4f6 <stat+0x2a>
    return -1;
 4ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4f4:	eb 25                	jmp    51b <stat+0x4f>
  r = fstat(fd, st);
 4f6:	83 ec 08             	sub    $0x8,%esp
 4f9:	ff 75 0c             	push   0xc(%ebp)
 4fc:	ff 75 f4             	push   -0xc(%ebp)
 4ff:	e8 0b 01 00 00       	call   60f <fstat>
 504:	83 c4 10             	add    $0x10,%esp
 507:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 50a:	83 ec 0c             	sub    $0xc,%esp
 50d:	ff 75 f4             	push   -0xc(%ebp)
 510:	e8 ca 00 00 00       	call   5df <close>
 515:	83 c4 10             	add    $0x10,%esp
  return r;
 518:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 51b:	c9                   	leave
 51c:	c3                   	ret

0000051d <atoi>:

int
atoi(const char *s)
{
 51d:	f3 0f 1e fb          	endbr32
 521:	55                   	push   %ebp
 522:	89 e5                	mov    %esp,%ebp
 524:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 527:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 52e:	eb 25                	jmp    555 <atoi+0x38>
    n = n*10 + *s++ - '0';
 530:	8b 55 fc             	mov    -0x4(%ebp),%edx
 533:	89 d0                	mov    %edx,%eax
 535:	c1 e0 02             	shl    $0x2,%eax
 538:	01 d0                	add    %edx,%eax
 53a:	01 c0                	add    %eax,%eax
 53c:	89 c1                	mov    %eax,%ecx
 53e:	8b 45 08             	mov    0x8(%ebp),%eax
 541:	8d 50 01             	lea    0x1(%eax),%edx
 544:	89 55 08             	mov    %edx,0x8(%ebp)
 547:	0f b6 00             	movzbl (%eax),%eax
 54a:	0f be c0             	movsbl %al,%eax
 54d:	01 c8                	add    %ecx,%eax
 54f:	83 e8 30             	sub    $0x30,%eax
 552:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 555:	8b 45 08             	mov    0x8(%ebp),%eax
 558:	0f b6 00             	movzbl (%eax),%eax
 55b:	3c 2f                	cmp    $0x2f,%al
 55d:	7e 0a                	jle    569 <atoi+0x4c>
 55f:	8b 45 08             	mov    0x8(%ebp),%eax
 562:	0f b6 00             	movzbl (%eax),%eax
 565:	3c 39                	cmp    $0x39,%al
 567:	7e c7                	jle    530 <atoi+0x13>
  return n;
 569:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 56c:	c9                   	leave
 56d:	c3                   	ret

0000056e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 56e:	f3 0f 1e fb          	endbr32
 572:	55                   	push   %ebp
 573:	89 e5                	mov    %esp,%ebp
 575:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 578:	8b 45 08             	mov    0x8(%ebp),%eax
 57b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 57e:	8b 45 0c             	mov    0xc(%ebp),%eax
 581:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 584:	eb 17                	jmp    59d <memmove+0x2f>
    *dst++ = *src++;
 586:	8b 55 f8             	mov    -0x8(%ebp),%edx
 589:	8d 42 01             	lea    0x1(%edx),%eax
 58c:	89 45 f8             	mov    %eax,-0x8(%ebp)
 58f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 592:	8d 48 01             	lea    0x1(%eax),%ecx
 595:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 598:	0f b6 12             	movzbl (%edx),%edx
 59b:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 59d:	8b 45 10             	mov    0x10(%ebp),%eax
 5a0:	8d 50 ff             	lea    -0x1(%eax),%edx
 5a3:	89 55 10             	mov    %edx,0x10(%ebp)
 5a6:	85 c0                	test   %eax,%eax
 5a8:	7f dc                	jg     586 <memmove+0x18>
  return vdst;
 5aa:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5ad:	c9                   	leave
 5ae:	c3                   	ret

000005af <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5af:	b8 01 00 00 00       	mov    $0x1,%eax
 5b4:	cd 40                	int    $0x40
 5b6:	c3                   	ret

000005b7 <exit>:
SYSCALL(exit)
 5b7:	b8 02 00 00 00       	mov    $0x2,%eax
 5bc:	cd 40                	int    $0x40
 5be:	c3                   	ret

000005bf <wait>:
SYSCALL(wait)
 5bf:	b8 03 00 00 00       	mov    $0x3,%eax
 5c4:	cd 40                	int    $0x40
 5c6:	c3                   	ret

000005c7 <pipe>:
SYSCALL(pipe)
 5c7:	b8 04 00 00 00       	mov    $0x4,%eax
 5cc:	cd 40                	int    $0x40
 5ce:	c3                   	ret

000005cf <read>:
SYSCALL(read)
 5cf:	b8 05 00 00 00       	mov    $0x5,%eax
 5d4:	cd 40                	int    $0x40
 5d6:	c3                   	ret

000005d7 <write>:
SYSCALL(write)
 5d7:	b8 10 00 00 00       	mov    $0x10,%eax
 5dc:	cd 40                	int    $0x40
 5de:	c3                   	ret

000005df <close>:
SYSCALL(close)
 5df:	b8 15 00 00 00       	mov    $0x15,%eax
 5e4:	cd 40                	int    $0x40
 5e6:	c3                   	ret

000005e7 <kill>:
SYSCALL(kill)
 5e7:	b8 06 00 00 00       	mov    $0x6,%eax
 5ec:	cd 40                	int    $0x40
 5ee:	c3                   	ret

000005ef <exec>:
SYSCALL(exec)
 5ef:	b8 07 00 00 00       	mov    $0x7,%eax
 5f4:	cd 40                	int    $0x40
 5f6:	c3                   	ret

000005f7 <open>:
SYSCALL(open)
 5f7:	b8 0f 00 00 00       	mov    $0xf,%eax
 5fc:	cd 40                	int    $0x40
 5fe:	c3                   	ret

000005ff <mknod>:
SYSCALL(mknod)
 5ff:	b8 11 00 00 00       	mov    $0x11,%eax
 604:	cd 40                	int    $0x40
 606:	c3                   	ret

00000607 <unlink>:
SYSCALL(unlink)
 607:	b8 12 00 00 00       	mov    $0x12,%eax
 60c:	cd 40                	int    $0x40
 60e:	c3                   	ret

0000060f <fstat>:
SYSCALL(fstat)
 60f:	b8 08 00 00 00       	mov    $0x8,%eax
 614:	cd 40                	int    $0x40
 616:	c3                   	ret

00000617 <link>:
SYSCALL(link)
 617:	b8 13 00 00 00       	mov    $0x13,%eax
 61c:	cd 40                	int    $0x40
 61e:	c3                   	ret

0000061f <mkdir>:
SYSCALL(mkdir)
 61f:	b8 14 00 00 00       	mov    $0x14,%eax
 624:	cd 40                	int    $0x40
 626:	c3                   	ret

00000627 <chdir>:
SYSCALL(chdir)
 627:	b8 09 00 00 00       	mov    $0x9,%eax
 62c:	cd 40                	int    $0x40
 62e:	c3                   	ret

0000062f <dup>:
SYSCALL(dup)
 62f:	b8 0a 00 00 00       	mov    $0xa,%eax
 634:	cd 40                	int    $0x40
 636:	c3                   	ret

00000637 <getpid>:
SYSCALL(getpid)
 637:	b8 0b 00 00 00       	mov    $0xb,%eax
 63c:	cd 40                	int    $0x40
 63e:	c3                   	ret

0000063f <sbrk>:
SYSCALL(sbrk)
 63f:	b8 0c 00 00 00       	mov    $0xc,%eax
 644:	cd 40                	int    $0x40
 646:	c3                   	ret

00000647 <sleep>:
SYSCALL(sleep)
 647:	b8 0d 00 00 00       	mov    $0xd,%eax
 64c:	cd 40                	int    $0x40
 64e:	c3                   	ret

0000064f <uptime>:
SYSCALL(uptime)
 64f:	b8 0e 00 00 00       	mov    $0xe,%eax
 654:	cd 40                	int    $0x40
 656:	c3                   	ret

00000657 <uthread_init>:

SYSCALL(uthread_init)
 657:	b8 16 00 00 00       	mov    $0x16,%eax
 65c:	cd 40                	int    $0x40
 65e:	c3                   	ret

0000065f <printpt>:
 65f:	b8 17 00 00 00       	mov    $0x17,%eax
 664:	cd 40                	int    $0x40
 666:	c3                   	ret

00000667 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 667:	f3 0f 1e fb          	endbr32
 66b:	55                   	push   %ebp
 66c:	89 e5                	mov    %esp,%ebp
 66e:	83 ec 18             	sub    $0x18,%esp
 671:	8b 45 0c             	mov    0xc(%ebp),%eax
 674:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 677:	83 ec 04             	sub    $0x4,%esp
 67a:	6a 01                	push   $0x1
 67c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 67f:	50                   	push   %eax
 680:	ff 75 08             	push   0x8(%ebp)
 683:	e8 4f ff ff ff       	call   5d7 <write>
 688:	83 c4 10             	add    $0x10,%esp
}
 68b:	90                   	nop
 68c:	c9                   	leave
 68d:	c3                   	ret

0000068e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 68e:	f3 0f 1e fb          	endbr32
 692:	55                   	push   %ebp
 693:	89 e5                	mov    %esp,%ebp
 695:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 698:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 69f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6a3:	74 17                	je     6bc <printint+0x2e>
 6a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6a9:	79 11                	jns    6bc <printint+0x2e>
    neg = 1;
 6ab:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b5:	f7 d8                	neg    %eax
 6b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6ba:	eb 06                	jmp    6c2 <printint+0x34>
  } else {
    x = xx;
 6bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 6bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6cf:	ba 00 00 00 00       	mov    $0x0,%edx
 6d4:	f7 f1                	div    %ecx
 6d6:	89 d1                	mov    %edx,%ecx
 6d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6db:	8d 50 01             	lea    0x1(%eax),%edx
 6de:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6e1:	0f b6 91 a0 0e 00 00 	movzbl 0xea0(%ecx),%edx
 6e8:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6f2:	ba 00 00 00 00       	mov    $0x0,%edx
 6f7:	f7 f1                	div    %ecx
 6f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6fc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 700:	75 c7                	jne    6c9 <printint+0x3b>
  if(neg)
 702:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 706:	74 2d                	je     735 <printint+0xa7>
    buf[i++] = '-';
 708:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70b:	8d 50 01             	lea    0x1(%eax),%edx
 70e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 711:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 716:	eb 1d                	jmp    735 <printint+0xa7>
    putc(fd, buf[i]);
 718:	8d 55 dc             	lea    -0x24(%ebp),%edx
 71b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71e:	01 d0                	add    %edx,%eax
 720:	0f b6 00             	movzbl (%eax),%eax
 723:	0f be c0             	movsbl %al,%eax
 726:	83 ec 08             	sub    $0x8,%esp
 729:	50                   	push   %eax
 72a:	ff 75 08             	push   0x8(%ebp)
 72d:	e8 35 ff ff ff       	call   667 <putc>
 732:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 735:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 739:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 73d:	79 d9                	jns    718 <printint+0x8a>
}
 73f:	90                   	nop
 740:	90                   	nop
 741:	c9                   	leave
 742:	c3                   	ret

00000743 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 743:	f3 0f 1e fb          	endbr32
 747:	55                   	push   %ebp
 748:	89 e5                	mov    %esp,%ebp
 74a:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 74d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 754:	8d 45 0c             	lea    0xc(%ebp),%eax
 757:	83 c0 04             	add    $0x4,%eax
 75a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 75d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 764:	e9 59 01 00 00       	jmp    8c2 <printf+0x17f>
    c = fmt[i] & 0xff;
 769:	8b 55 0c             	mov    0xc(%ebp),%edx
 76c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76f:	01 d0                	add    %edx,%eax
 771:	0f b6 00             	movzbl (%eax),%eax
 774:	0f be c0             	movsbl %al,%eax
 777:	25 ff 00 00 00       	and    $0xff,%eax
 77c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 77f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 783:	75 2c                	jne    7b1 <printf+0x6e>
      if(c == '%'){
 785:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 789:	75 0c                	jne    797 <printf+0x54>
        state = '%';
 78b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 792:	e9 27 01 00 00       	jmp    8be <printf+0x17b>
      } else {
        putc(fd, c);
 797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 79a:	0f be c0             	movsbl %al,%eax
 79d:	83 ec 08             	sub    $0x8,%esp
 7a0:	50                   	push   %eax
 7a1:	ff 75 08             	push   0x8(%ebp)
 7a4:	e8 be fe ff ff       	call   667 <putc>
 7a9:	83 c4 10             	add    $0x10,%esp
 7ac:	e9 0d 01 00 00       	jmp    8be <printf+0x17b>
      }
    } else if(state == '%'){
 7b1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7b5:	0f 85 03 01 00 00    	jne    8be <printf+0x17b>
      if(c == 'd'){
 7bb:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7bf:	75 1e                	jne    7df <printf+0x9c>
        printint(fd, *ap, 10, 1);
 7c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c4:	8b 00                	mov    (%eax),%eax
 7c6:	6a 01                	push   $0x1
 7c8:	6a 0a                	push   $0xa
 7ca:	50                   	push   %eax
 7cb:	ff 75 08             	push   0x8(%ebp)
 7ce:	e8 bb fe ff ff       	call   68e <printint>
 7d3:	83 c4 10             	add    $0x10,%esp
        ap++;
 7d6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7da:	e9 d8 00 00 00       	jmp    8b7 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 7df:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7e3:	74 06                	je     7eb <printf+0xa8>
 7e5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7e9:	75 1e                	jne    809 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 7eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ee:	8b 00                	mov    (%eax),%eax
 7f0:	6a 00                	push   $0x0
 7f2:	6a 10                	push   $0x10
 7f4:	50                   	push   %eax
 7f5:	ff 75 08             	push   0x8(%ebp)
 7f8:	e8 91 fe ff ff       	call   68e <printint>
 7fd:	83 c4 10             	add    $0x10,%esp
        ap++;
 800:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 804:	e9 ae 00 00 00       	jmp    8b7 <printf+0x174>
      } else if(c == 's'){
 809:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 80d:	75 43                	jne    852 <printf+0x10f>
        s = (char*)*ap;
 80f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 812:	8b 00                	mov    (%eax),%eax
 814:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 817:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 81b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 81f:	75 25                	jne    846 <printf+0x103>
          s = "(null)";
 821:	c7 45 f4 de 0b 00 00 	movl   $0xbde,-0xc(%ebp)
        while(*s != 0){
 828:	eb 1c                	jmp    846 <printf+0x103>
          putc(fd, *s);
 82a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82d:	0f b6 00             	movzbl (%eax),%eax
 830:	0f be c0             	movsbl %al,%eax
 833:	83 ec 08             	sub    $0x8,%esp
 836:	50                   	push   %eax
 837:	ff 75 08             	push   0x8(%ebp)
 83a:	e8 28 fe ff ff       	call   667 <putc>
 83f:	83 c4 10             	add    $0x10,%esp
          s++;
 842:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 846:	8b 45 f4             	mov    -0xc(%ebp),%eax
 849:	0f b6 00             	movzbl (%eax),%eax
 84c:	84 c0                	test   %al,%al
 84e:	75 da                	jne    82a <printf+0xe7>
 850:	eb 65                	jmp    8b7 <printf+0x174>
        }
      } else if(c == 'c'){
 852:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 856:	75 1d                	jne    875 <printf+0x132>
        putc(fd, *ap);
 858:	8b 45 e8             	mov    -0x18(%ebp),%eax
 85b:	8b 00                	mov    (%eax),%eax
 85d:	0f be c0             	movsbl %al,%eax
 860:	83 ec 08             	sub    $0x8,%esp
 863:	50                   	push   %eax
 864:	ff 75 08             	push   0x8(%ebp)
 867:	e8 fb fd ff ff       	call   667 <putc>
 86c:	83 c4 10             	add    $0x10,%esp
        ap++;
 86f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 873:	eb 42                	jmp    8b7 <printf+0x174>
      } else if(c == '%'){
 875:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 879:	75 17                	jne    892 <printf+0x14f>
        putc(fd, c);
 87b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 87e:	0f be c0             	movsbl %al,%eax
 881:	83 ec 08             	sub    $0x8,%esp
 884:	50                   	push   %eax
 885:	ff 75 08             	push   0x8(%ebp)
 888:	e8 da fd ff ff       	call   667 <putc>
 88d:	83 c4 10             	add    $0x10,%esp
 890:	eb 25                	jmp    8b7 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 892:	83 ec 08             	sub    $0x8,%esp
 895:	6a 25                	push   $0x25
 897:	ff 75 08             	push   0x8(%ebp)
 89a:	e8 c8 fd ff ff       	call   667 <putc>
 89f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8a5:	0f be c0             	movsbl %al,%eax
 8a8:	83 ec 08             	sub    $0x8,%esp
 8ab:	50                   	push   %eax
 8ac:	ff 75 08             	push   0x8(%ebp)
 8af:	e8 b3 fd ff ff       	call   667 <putc>
 8b4:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8b7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 8be:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8c2:	8b 55 0c             	mov    0xc(%ebp),%edx
 8c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c8:	01 d0                	add    %edx,%eax
 8ca:	0f b6 00             	movzbl (%eax),%eax
 8cd:	84 c0                	test   %al,%al
 8cf:	0f 85 94 fe ff ff    	jne    769 <printf+0x26>
    }
  }
}
 8d5:	90                   	nop
 8d6:	90                   	nop
 8d7:	c9                   	leave
 8d8:	c3                   	ret

000008d9 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8d9:	f3 0f 1e fb          	endbr32
 8dd:	55                   	push   %ebp
 8de:	89 e5                	mov    %esp,%ebp
 8e0:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8e3:	8b 45 08             	mov    0x8(%ebp),%eax
 8e6:	83 e8 08             	sub    $0x8,%eax
 8e9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ec:	a1 bc 0e 00 00       	mov    0xebc,%eax
 8f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8f4:	eb 24                	jmp    91a <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f9:	8b 00                	mov    (%eax),%eax
 8fb:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8fe:	72 12                	jb     912 <free+0x39>
 900:	8b 45 f8             	mov    -0x8(%ebp),%eax
 903:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 906:	77 24                	ja     92c <free+0x53>
 908:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90b:	8b 00                	mov    (%eax),%eax
 90d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 910:	72 1a                	jb     92c <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 912:	8b 45 fc             	mov    -0x4(%ebp),%eax
 915:	8b 00                	mov    (%eax),%eax
 917:	89 45 fc             	mov    %eax,-0x4(%ebp)
 91a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 920:	76 d4                	jbe    8f6 <free+0x1d>
 922:	8b 45 fc             	mov    -0x4(%ebp),%eax
 925:	8b 00                	mov    (%eax),%eax
 927:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 92a:	73 ca                	jae    8f6 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 92c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92f:	8b 40 04             	mov    0x4(%eax),%eax
 932:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 939:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93c:	01 c2                	add    %eax,%edx
 93e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 941:	8b 00                	mov    (%eax),%eax
 943:	39 c2                	cmp    %eax,%edx
 945:	75 24                	jne    96b <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 947:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94a:	8b 50 04             	mov    0x4(%eax),%edx
 94d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 950:	8b 00                	mov    (%eax),%eax
 952:	8b 40 04             	mov    0x4(%eax),%eax
 955:	01 c2                	add    %eax,%edx
 957:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 95d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 960:	8b 00                	mov    (%eax),%eax
 962:	8b 10                	mov    (%eax),%edx
 964:	8b 45 f8             	mov    -0x8(%ebp),%eax
 967:	89 10                	mov    %edx,(%eax)
 969:	eb 0a                	jmp    975 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 96b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96e:	8b 10                	mov    (%eax),%edx
 970:	8b 45 f8             	mov    -0x8(%ebp),%eax
 973:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 975:	8b 45 fc             	mov    -0x4(%ebp),%eax
 978:	8b 40 04             	mov    0x4(%eax),%eax
 97b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 982:	8b 45 fc             	mov    -0x4(%ebp),%eax
 985:	01 d0                	add    %edx,%eax
 987:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 98a:	75 20                	jne    9ac <free+0xd3>
    p->s.size += bp->s.size;
 98c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98f:	8b 50 04             	mov    0x4(%eax),%edx
 992:	8b 45 f8             	mov    -0x8(%ebp),%eax
 995:	8b 40 04             	mov    0x4(%eax),%eax
 998:	01 c2                	add    %eax,%edx
 99a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a3:	8b 10                	mov    (%eax),%edx
 9a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a8:	89 10                	mov    %edx,(%eax)
 9aa:	eb 08                	jmp    9b4 <free+0xdb>
  } else
    p->s.ptr = bp;
 9ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9af:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9b2:	89 10                	mov    %edx,(%eax)
  freep = p;
 9b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b7:	a3 bc 0e 00 00       	mov    %eax,0xebc
}
 9bc:	90                   	nop
 9bd:	c9                   	leave
 9be:	c3                   	ret

000009bf <morecore>:

static Header*
morecore(uint nu)
{
 9bf:	f3 0f 1e fb          	endbr32
 9c3:	55                   	push   %ebp
 9c4:	89 e5                	mov    %esp,%ebp
 9c6:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9c9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9d0:	77 07                	ja     9d9 <morecore+0x1a>
    nu = 4096;
 9d2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9d9:	8b 45 08             	mov    0x8(%ebp),%eax
 9dc:	c1 e0 03             	shl    $0x3,%eax
 9df:	83 ec 0c             	sub    $0xc,%esp
 9e2:	50                   	push   %eax
 9e3:	e8 57 fc ff ff       	call   63f <sbrk>
 9e8:	83 c4 10             	add    $0x10,%esp
 9eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9ee:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9f2:	75 07                	jne    9fb <morecore+0x3c>
    return 0;
 9f4:	b8 00 00 00 00       	mov    $0x0,%eax
 9f9:	eb 26                	jmp    a21 <morecore+0x62>
  hp = (Header*)p;
 9fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a04:	8b 55 08             	mov    0x8(%ebp),%edx
 a07:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a0d:	83 c0 08             	add    $0x8,%eax
 a10:	83 ec 0c             	sub    $0xc,%esp
 a13:	50                   	push   %eax
 a14:	e8 c0 fe ff ff       	call   8d9 <free>
 a19:	83 c4 10             	add    $0x10,%esp
  return freep;
 a1c:	a1 bc 0e 00 00       	mov    0xebc,%eax
}
 a21:	c9                   	leave
 a22:	c3                   	ret

00000a23 <malloc>:

void*
malloc(uint nbytes)
{
 a23:	f3 0f 1e fb          	endbr32
 a27:	55                   	push   %ebp
 a28:	89 e5                	mov    %esp,%ebp
 a2a:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a2d:	8b 45 08             	mov    0x8(%ebp),%eax
 a30:	83 c0 07             	add    $0x7,%eax
 a33:	c1 e8 03             	shr    $0x3,%eax
 a36:	83 c0 01             	add    $0x1,%eax
 a39:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a3c:	a1 bc 0e 00 00       	mov    0xebc,%eax
 a41:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a44:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a48:	75 23                	jne    a6d <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 a4a:	c7 45 f0 b4 0e 00 00 	movl   $0xeb4,-0x10(%ebp)
 a51:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a54:	a3 bc 0e 00 00       	mov    %eax,0xebc
 a59:	a1 bc 0e 00 00       	mov    0xebc,%eax
 a5e:	a3 b4 0e 00 00       	mov    %eax,0xeb4
    base.s.size = 0;
 a63:	c7 05 b8 0e 00 00 00 	movl   $0x0,0xeb8
 a6a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a70:	8b 00                	mov    (%eax),%eax
 a72:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a78:	8b 40 04             	mov    0x4(%eax),%eax
 a7b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a7e:	77 4d                	ja     acd <malloc+0xaa>
      if(p->s.size == nunits)
 a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a83:	8b 40 04             	mov    0x4(%eax),%eax
 a86:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a89:	75 0c                	jne    a97 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8e:	8b 10                	mov    (%eax),%edx
 a90:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a93:	89 10                	mov    %edx,(%eax)
 a95:	eb 26                	jmp    abd <malloc+0x9a>
      else {
        p->s.size -= nunits;
 a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9a:	8b 40 04             	mov    0x4(%eax),%eax
 a9d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 aa0:	89 c2                	mov    %eax,%edx
 aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aab:	8b 40 04             	mov    0x4(%eax),%eax
 aae:	c1 e0 03             	shl    $0x3,%eax
 ab1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 aba:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 abd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ac0:	a3 bc 0e 00 00       	mov    %eax,0xebc
      return (void*)(p + 1);
 ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac8:	83 c0 08             	add    $0x8,%eax
 acb:	eb 3b                	jmp    b08 <malloc+0xe5>
    }
    if(p == freep)
 acd:	a1 bc 0e 00 00       	mov    0xebc,%eax
 ad2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ad5:	75 1e                	jne    af5 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 ad7:	83 ec 0c             	sub    $0xc,%esp
 ada:	ff 75 ec             	push   -0x14(%ebp)
 add:	e8 dd fe ff ff       	call   9bf <morecore>
 ae2:	83 c4 10             	add    $0x10,%esp
 ae5:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ae8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 aec:	75 07                	jne    af5 <malloc+0xd2>
        return 0;
 aee:	b8 00 00 00 00       	mov    $0x0,%eax
 af3:	eb 13                	jmp    b08 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afe:	8b 00                	mov    (%eax),%eax
 b00:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b03:	e9 6d ff ff ff       	jmp    a75 <malloc+0x52>
  }
}
 b08:	c9                   	leave
 b09:	c3                   	ret
