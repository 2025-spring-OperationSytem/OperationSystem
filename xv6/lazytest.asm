
_lazytest:     file format elf32-i386


Disassembly of section .text:

00000000 <sparse_memory>:
// 0x40000000
#define REGION_SZ (1024 * 1024 * 1024)

void
sparse_memory(char *s)  
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  // sbrk가 미리 할당을 하지 않고 pagefault가 발생하면 
  // 할당하는 방식으로 lazytest를 구현해야 한다.

  // sbrk는 sbrk로 값을 늘리기 전의 sz를 반환하기 때문에 조건에 걸리지 않고 지나간다.
  // prev_end에는 메모리 할당 전의 유저공간의 끝 주소가 담긴다. 
  prev_end = sbrk(REGION_SZ);
   6:	83 ec 0c             	sub    $0xc,%esp
   9:	68 00 00 00 40       	push   $0x40000000
   e:	e8 f5 05 00 00       	call   608 <sbrk>
  13:	83 c4 10             	add    $0x10,%esp
  16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (prev_end == (char*)0xffffffffffffffffL) {
  19:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
  1d:	75 17                	jne    36 <sparse_memory+0x36>
    printf(1,"sbrk() failed\n");
  1f:	83 ec 08             	sub    $0x8,%esp
  22:	68 bc 0a 00 00       	push   $0xabc
  27:	6a 01                	push   $0x1
  29:	e8 d6 06 00 00       	call   704 <printf>
  2e:	83 c4 10             	add    $0x10,%esp
    exit();
  31:	e8 4a 05 00 00       	call   580 <exit>
  }
  new_end = prev_end + REGION_SZ;
  36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  39:	05 00 00 00 40       	add    $0x40000000,%eax
  3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  // i를 page size 만큼씩 키워 0x40000000 공간에 각각 할당하여
  // pagefault를 발생시켜 메모리 할당이 제대로 되는지 확인한다.
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
  41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  44:	05 00 10 00 00       	add    $0x1000,%eax
  49:	89 45 f4             	mov    %eax,-0xc(%ebp)
  4c:	eb 0f                	jmp    5d <sparse_memory+0x5d>
    *(char **)i = i;
  4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  54:	89 10                	mov    %edx,(%eax)
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
  56:	81 45 f4 00 00 04 00 	addl   $0x40000,-0xc(%ebp)
  5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  60:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  63:	72 e9                	jb     4e <sparse_memory+0x4e>

  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
  65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  68:	05 00 10 00 00       	add    $0x1000,%eax
  6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  70:	eb 28                	jmp    9a <sparse_memory+0x9a>
    if (*(char **)i != i) {
  72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  75:	8b 00                	mov    (%eax),%eax
  77:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  7a:	74 17                	je     93 <sparse_memory+0x93>
      printf(1,"failed to read value from memory\n");
  7c:	83 ec 08             	sub    $0x8,%esp
  7f:	68 cc 0a 00 00       	push   $0xacc
  84:	6a 01                	push   $0x1
  86:	e8 79 06 00 00       	call   704 <printf>
  8b:	83 c4 10             	add    $0x10,%esp
      exit();
  8e:	e8 ed 04 00 00       	call   580 <exit>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
  93:	81 45 f4 00 00 04 00 	addl   $0x40000,-0xc(%ebp)
  9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  9d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  a0:	72 d0                	jb     72 <sparse_memory+0x72>
    }
  }

  exit();
  a2:	e8 d9 04 00 00       	call   580 <exit>

000000a7 <sparse_memory_unmap>:
}

void
sparse_memory_unmap(char *s)
{
  a7:	55                   	push   %ebp
  a8:	89 e5                	mov    %esp,%ebp
  aa:	83 ec 18             	sub    $0x18,%esp
  int pid;
  char *i, *prev_end, *new_end;

  prev_end = sbrk(REGION_SZ);
  ad:	83 ec 0c             	sub    $0xc,%esp
  b0:	68 00 00 00 40       	push   $0x40000000
  b5:	e8 4e 05 00 00       	call   608 <sbrk>
  ba:	83 c4 10             	add    $0x10,%esp
  bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (prev_end == (char*)0xffffffffffffffffL) {
  c0:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
  c4:	75 17                	jne    dd <sparse_memory_unmap+0x36>
    printf(1,"sbrk() failed\n");
  c6:	83 ec 08             	sub    $0x8,%esp
  c9:	68 bc 0a 00 00       	push   $0xabc
  ce:	6a 01                	push   $0x1
  d0:	e8 2f 06 00 00       	call   704 <printf>
  d5:	83 c4 10             	add    $0x10,%esp
    exit();
  d8:	e8 a3 04 00 00       	call   580 <exit>
  }
  new_end = prev_end + REGION_SZ;
  dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  e0:	05 00 00 00 40       	add    $0x40000000,%eax
  e5:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
  e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  eb:	05 00 10 00 00       	add    $0x1000,%eax
  f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f3:	eb 0f                	jmp    104 <sparse_memory_unmap+0x5d>
    *(char **)i = i;
  f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  fb:	89 10                	mov    %edx,(%eax)
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
  fd:	81 45 f4 00 00 00 01 	addl   $0x1000000,-0xc(%ebp)
 104:	8b 45 f4             	mov    -0xc(%ebp),%eax
 107:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 10a:	72 e9                	jb     f5 <sparse_memory_unmap+0x4e>

  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
 10c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 10f:	05 00 10 00 00       	add    $0x1000,%eax
 114:	89 45 f4             	mov    %eax,-0xc(%ebp)
 117:	90                   	nop
 118:	8b 45 f4             	mov    -0xc(%ebp),%eax
 11b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 11e:	73 64                	jae    184 <sparse_memory_unmap+0xdd>
    // 자식 프로세스를 생성하여 unmap이 제대로 실행되는지 확인
    pid = fork();
 120:	e8 53 04 00 00       	call   578 <fork>
 125:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (pid < 0) {
 128:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 12c:	79 17                	jns    145 <sparse_memory_unmap+0x9e>
      printf(1,"error forking\n");
 12e:	83 ec 08             	sub    $0x8,%esp
 131:	68 ee 0a 00 00       	push   $0xaee
 136:	6a 01                	push   $0x1
 138:	e8 c7 05 00 00       	call   704 <printf>
 13d:	83 c4 10             	add    $0x10,%esp
      exit();
 140:	e8 3b 04 00 00       	call   580 <exit>
    } else if (pid == 0) {
 145:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
 149:	75 1d                	jne    168 <sparse_memory_unmap+0xc1>
      sbrk(-1L * REGION_SZ);
 14b:	83 ec 0c             	sub    $0xc,%esp
 14e:	68 00 00 00 c0       	push   $0xc0000000
 153:	e8 b0 04 00 00       	call   608 <sbrk>
 158:	83 c4 10             	add    $0x10,%esp
      *(char **)i = i;
 15b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 15e:	8b 55 f4             	mov    -0xc(%ebp),%edx
 161:	89 10                	mov    %edx,(%eax)
      exit();
 163:	e8 18 04 00 00       	call   580 <exit>
    } else {
      wait();
 168:	e8 1b 04 00 00       	call   588 <wait>
      printf(1,"memory not unmapped\n");
 16d:	83 ec 08             	sub    $0x8,%esp
 170:	68 fd 0a 00 00       	push   $0xafd
 175:	6a 01                	push   $0x1
 177:	e8 88 05 00 00       	call   704 <printf>
 17c:	83 c4 10             	add    $0x10,%esp
      exit();
 17f:	e8 fc 03 00 00       	call   580 <exit>
    }
  }
  exit();
 184:	e8 f7 03 00 00       	call   580 <exit>

00000189 <oom>:
}

void
oom(char *s)
{
 189:	55                   	push   %ebp
 18a:	89 e5                	mov    %esp,%ebp
 18c:	83 ec 18             	sub    $0x18,%esp
  void *m1, *m2;
  int pid;

  // out of memory를 테스트하는 함수
  if((pid = fork()) == 0){
 18f:	e8 e4 03 00 00       	call   578 <fork>
 194:	89 45 f0             	mov    %eax,-0x10(%ebp)
 197:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 19b:	75 35                	jne    1d2 <oom+0x49>
    m1 = 0;
 19d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    // m2에 16MB 만큼의 메모리를 계속 할당
    // 메모리가 가득 차면 루프 탈출
    while((m2 = malloc(4096*4096)) != 0){
 1a4:	eb 0e                	jmp    1b4 <oom+0x2b>
      *(char**)m2 = m1;
 1a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1ac:	89 10                	mov    %edx,(%eax)
      m1 = m2;
 1ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
 1b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while((m2 = malloc(4096*4096)) != 0){
 1b4:	83 ec 0c             	sub    $0xc,%esp
 1b7:	68 00 00 00 01       	push   $0x1000000
 1bc:	e8 17 08 00 00       	call   9d8 <malloc>
 1c1:	83 c4 10             	add    $0x10,%esp
 1c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 1c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 1cb:	75 d9                	jne    1a6 <oom+0x1d>
    }
    exit();
 1cd:	e8 ae 03 00 00       	call   580 <exit>
  } else {
    wait();
 1d2:	e8 b1 03 00 00       	call   588 <wait>
    printf(1,"oomtest end\n");
 1d7:	83 ec 08             	sub    $0x8,%esp
 1da:	68 12 0b 00 00       	push   $0xb12
 1df:	6a 01                	push   $0x1
 1e1:	e8 1e 05 00 00       	call   704 <printf>
 1e6:	83 c4 10             	add    $0x10,%esp
    exit();
 1e9:	e8 92 03 00 00       	call   580 <exit>

000001ee <run>:
}

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
 1ee:	55                   	push   %ebp
 1ef:	89 e5                	mov    %esp,%ebp
 1f1:	83 ec 18             	sub    $0x18,%esp
  int pid;
  
  printf(1,"running test %s\n", s);
 1f4:	83 ec 04             	sub    $0x4,%esp
 1f7:	ff 75 0c             	push   0xc(%ebp)
 1fa:	68 1f 0b 00 00       	push   $0xb1f
 1ff:	6a 01                	push   $0x1
 201:	e8 fe 04 00 00       	call   704 <printf>
 206:	83 c4 10             	add    $0x10,%esp
  if((pid = fork()) < 0) {
 209:	e8 6a 03 00 00       	call   578 <fork>
 20e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 211:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 215:	79 17                	jns    22e <run+0x40>
    printf(1,"runtest: fork error\n");
 217:	83 ec 08             	sub    $0x8,%esp
 21a:	68 30 0b 00 00       	push   $0xb30
 21f:	6a 01                	push   $0x1
 221:	e8 de 04 00 00       	call   704 <printf>
 226:	83 c4 10             	add    $0x10,%esp
    exit();
 229:	e8 52 03 00 00       	call   580 <exit>
  }
  if(pid == 0) {
 22e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 232:	75 13                	jne    247 <run+0x59>
    f(s);
 234:	83 ec 0c             	sub    $0xc,%esp
 237:	ff 75 0c             	push   0xc(%ebp)
 23a:	8b 45 08             	mov    0x8(%ebp),%eax
 23d:	ff d0                	call   *%eax
 23f:	83 c4 10             	add    $0x10,%esp
    exit();
 242:	e8 39 03 00 00       	call   580 <exit>
  } else {
    wait();
 247:	e8 3c 03 00 00       	call   588 <wait>
    return 1;
 24c:	b8 01 00 00 00       	mov    $0x1,%eax
  }
}
 251:	c9                   	leave
 252:	c3                   	ret

00000253 <main>:

int
main(int argc, char *argv[])
{
 253:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 257:	83 e4 f0             	and    $0xfffffff0,%esp
 25a:	ff 71 fc             	push   -0x4(%ecx)
 25d:	55                   	push   %ebp
 25e:	89 e5                	mov    %esp,%ebp
 260:	51                   	push   %ecx
 261:	83 ec 34             	sub    $0x34,%esp
 264:	89 c8                	mov    %ecx,%eax
  char *n = 0;
 266:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(argc > 1) {
 26d:	83 38 01             	cmpl   $0x1,(%eax)
 270:	7e 09                	jle    27b <main+0x28>
    n = argv[1];
 272:	8b 40 04             	mov    0x4(%eax),%eax
 275:	8b 40 04             	mov    0x4(%eax),%eax
 278:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
 27b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
 282:	c7 45 d4 45 0b 00 00 	movl   $0xb45,-0x2c(%ebp)
 289:	c7 45 d8 a7 00 00 00 	movl   $0xa7,-0x28(%ebp)
 290:	c7 45 dc 50 0b 00 00 	movl   $0xb50,-0x24(%ebp)
 297:	c7 45 e0 89 01 00 00 	movl   $0x189,-0x20(%ebp)
 29e:	c7 45 e4 5b 0b 00 00 	movl   $0xb5b,-0x1c(%ebp)
 2a5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
 2ac:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    { sparse_memory_unmap, "lazy unmap"},
    { oom, "out of memory"},
    { 0, 0},
  };
    
  printf(1,"lazytests starting\n");
 2b3:	83 ec 08             	sub    $0x8,%esp
 2b6:	68 69 0b 00 00       	push   $0xb69
 2bb:	6a 01                	push   $0x1
 2bd:	e8 42 04 00 00       	call   704 <printf>
 2c2:	83 c4 10             	add    $0x10,%esp
  // 위 함수들을 한 번씩 실행시킨다.
  for (struct test *t = tests; t->s != 0; t++) {
 2c5:	8d 45 d0             	lea    -0x30(%ebp),%eax
 2c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 2cb:	eb 3b                	jmp    308 <main+0xb5>
    if((n == 0) || strcmp(t->s, n) == 0) {
 2cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2d1:	74 19                	je     2ec <main+0x99>
 2d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2d6:	8b 40 04             	mov    0x4(%eax),%eax
 2d9:	83 ec 08             	sub    $0x8,%esp
 2dc:	ff 75 f4             	push   -0xc(%ebp)
 2df:	50                   	push   %eax
 2e0:	e8 9a 00 00 00       	call   37f <strcmp>
 2e5:	83 c4 10             	add    $0x10,%esp
 2e8:	85 c0                	test   %eax,%eax
 2ea:	75 18                	jne    304 <main+0xb1>
      run(t->f, t->s);
 2ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2ef:	8b 50 04             	mov    0x4(%eax),%edx
 2f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 2f5:	8b 00                	mov    (%eax),%eax
 2f7:	83 ec 08             	sub    $0x8,%esp
 2fa:	52                   	push   %edx
 2fb:	50                   	push   %eax
 2fc:	e8 ed fe ff ff       	call   1ee <run>
 301:	83 c4 10             	add    $0x10,%esp
  for (struct test *t = tests; t->s != 0; t++) {
 304:	83 45 f0 08          	addl   $0x8,-0x10(%ebp)
 308:	8b 45 f0             	mov    -0x10(%ebp),%eax
 30b:	8b 40 04             	mov    0x4(%eax),%eax
 30e:	85 c0                	test   %eax,%eax
 310:	75 bb                	jne    2cd <main+0x7a>
    }
  }
  printf(1,"ALL TESTS ENDED\n");
 312:	83 ec 08             	sub    $0x8,%esp
 315:	68 7d 0b 00 00       	push   $0xb7d
 31a:	6a 01                	push   $0x1
 31c:	e8 e3 03 00 00       	call   704 <printf>
 321:	83 c4 10             	add    $0x10,%esp
  exit();   // not reached.
 324:	e8 57 02 00 00       	call   580 <exit>

00000329 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 329:	55                   	push   %ebp
 32a:	89 e5                	mov    %esp,%ebp
 32c:	57                   	push   %edi
 32d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 32e:	8b 4d 08             	mov    0x8(%ebp),%ecx
 331:	8b 55 10             	mov    0x10(%ebp),%edx
 334:	8b 45 0c             	mov    0xc(%ebp),%eax
 337:	89 cb                	mov    %ecx,%ebx
 339:	89 df                	mov    %ebx,%edi
 33b:	89 d1                	mov    %edx,%ecx
 33d:	fc                   	cld
 33e:	f3 aa                	rep stos %al,%es:(%edi)
 340:	89 ca                	mov    %ecx,%edx
 342:	89 fb                	mov    %edi,%ebx
 344:	89 5d 08             	mov    %ebx,0x8(%ebp)
 347:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 34a:	90                   	nop
 34b:	5b                   	pop    %ebx
 34c:	5f                   	pop    %edi
 34d:	5d                   	pop    %ebp
 34e:	c3                   	ret

0000034f <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 34f:	55                   	push   %ebp
 350:	89 e5                	mov    %esp,%ebp
 352:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 355:	8b 45 08             	mov    0x8(%ebp),%eax
 358:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 35b:	90                   	nop
 35c:	8b 55 0c             	mov    0xc(%ebp),%edx
 35f:	8d 42 01             	lea    0x1(%edx),%eax
 362:	89 45 0c             	mov    %eax,0xc(%ebp)
 365:	8b 45 08             	mov    0x8(%ebp),%eax
 368:	8d 48 01             	lea    0x1(%eax),%ecx
 36b:	89 4d 08             	mov    %ecx,0x8(%ebp)
 36e:	0f b6 12             	movzbl (%edx),%edx
 371:	88 10                	mov    %dl,(%eax)
 373:	0f b6 00             	movzbl (%eax),%eax
 376:	84 c0                	test   %al,%al
 378:	75 e2                	jne    35c <strcpy+0xd>
    ;
  return os;
 37a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 37d:	c9                   	leave
 37e:	c3                   	ret

0000037f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 37f:	55                   	push   %ebp
 380:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 382:	eb 08                	jmp    38c <strcmp+0xd>
    p++, q++;
 384:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 388:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 38c:	8b 45 08             	mov    0x8(%ebp),%eax
 38f:	0f b6 00             	movzbl (%eax),%eax
 392:	84 c0                	test   %al,%al
 394:	74 10                	je     3a6 <strcmp+0x27>
 396:	8b 45 08             	mov    0x8(%ebp),%eax
 399:	0f b6 10             	movzbl (%eax),%edx
 39c:	8b 45 0c             	mov    0xc(%ebp),%eax
 39f:	0f b6 00             	movzbl (%eax),%eax
 3a2:	38 c2                	cmp    %al,%dl
 3a4:	74 de                	je     384 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 3a6:	8b 45 08             	mov    0x8(%ebp),%eax
 3a9:	0f b6 00             	movzbl (%eax),%eax
 3ac:	0f b6 d0             	movzbl %al,%edx
 3af:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b2:	0f b6 00             	movzbl (%eax),%eax
 3b5:	0f b6 c0             	movzbl %al,%eax
 3b8:	29 c2                	sub    %eax,%edx
 3ba:	89 d0                	mov    %edx,%eax
}
 3bc:	5d                   	pop    %ebp
 3bd:	c3                   	ret

000003be <strlen>:

uint
strlen(char *s)
{
 3be:	55                   	push   %ebp
 3bf:	89 e5                	mov    %esp,%ebp
 3c1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3cb:	eb 04                	jmp    3d1 <strlen+0x13>
 3cd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3d1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3d4:	8b 45 08             	mov    0x8(%ebp),%eax
 3d7:	01 d0                	add    %edx,%eax
 3d9:	0f b6 00             	movzbl (%eax),%eax
 3dc:	84 c0                	test   %al,%al
 3de:	75 ed                	jne    3cd <strlen+0xf>
    ;
  return n;
 3e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3e3:	c9                   	leave
 3e4:	c3                   	ret

000003e5 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3e5:	55                   	push   %ebp
 3e6:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 3e8:	8b 45 10             	mov    0x10(%ebp),%eax
 3eb:	50                   	push   %eax
 3ec:	ff 75 0c             	push   0xc(%ebp)
 3ef:	ff 75 08             	push   0x8(%ebp)
 3f2:	e8 32 ff ff ff       	call   329 <stosb>
 3f7:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3fa:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3fd:	c9                   	leave
 3fe:	c3                   	ret

000003ff <strchr>:

char*
strchr(const char *s, char c)
{
 3ff:	55                   	push   %ebp
 400:	89 e5                	mov    %esp,%ebp
 402:	83 ec 04             	sub    $0x4,%esp
 405:	8b 45 0c             	mov    0xc(%ebp),%eax
 408:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 40b:	eb 14                	jmp    421 <strchr+0x22>
    if(*s == c)
 40d:	8b 45 08             	mov    0x8(%ebp),%eax
 410:	0f b6 00             	movzbl (%eax),%eax
 413:	38 45 fc             	cmp    %al,-0x4(%ebp)
 416:	75 05                	jne    41d <strchr+0x1e>
      return (char*)s;
 418:	8b 45 08             	mov    0x8(%ebp),%eax
 41b:	eb 13                	jmp    430 <strchr+0x31>
  for(; *s; s++)
 41d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 421:	8b 45 08             	mov    0x8(%ebp),%eax
 424:	0f b6 00             	movzbl (%eax),%eax
 427:	84 c0                	test   %al,%al
 429:	75 e2                	jne    40d <strchr+0xe>
  return 0;
 42b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 430:	c9                   	leave
 431:	c3                   	ret

00000432 <gets>:

char*
gets(char *buf, int max)
{
 432:	55                   	push   %ebp
 433:	89 e5                	mov    %esp,%ebp
 435:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 438:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 43f:	eb 42                	jmp    483 <gets+0x51>
    cc = read(0, &c, 1);
 441:	83 ec 04             	sub    $0x4,%esp
 444:	6a 01                	push   $0x1
 446:	8d 45 ef             	lea    -0x11(%ebp),%eax
 449:	50                   	push   %eax
 44a:	6a 00                	push   $0x0
 44c:	e8 47 01 00 00       	call   598 <read>
 451:	83 c4 10             	add    $0x10,%esp
 454:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 457:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 45b:	7e 33                	jle    490 <gets+0x5e>
      break;
    buf[i++] = c;
 45d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 460:	8d 50 01             	lea    0x1(%eax),%edx
 463:	89 55 f4             	mov    %edx,-0xc(%ebp)
 466:	89 c2                	mov    %eax,%edx
 468:	8b 45 08             	mov    0x8(%ebp),%eax
 46b:	01 c2                	add    %eax,%edx
 46d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 471:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 473:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 477:	3c 0a                	cmp    $0xa,%al
 479:	74 16                	je     491 <gets+0x5f>
 47b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 47f:	3c 0d                	cmp    $0xd,%al
 481:	74 0e                	je     491 <gets+0x5f>
  for(i=0; i+1 < max; ){
 483:	8b 45 f4             	mov    -0xc(%ebp),%eax
 486:	83 c0 01             	add    $0x1,%eax
 489:	39 45 0c             	cmp    %eax,0xc(%ebp)
 48c:	7f b3                	jg     441 <gets+0xf>
 48e:	eb 01                	jmp    491 <gets+0x5f>
      break;
 490:	90                   	nop
      break;
  }
  buf[i] = '\0';
 491:	8b 55 f4             	mov    -0xc(%ebp),%edx
 494:	8b 45 08             	mov    0x8(%ebp),%eax
 497:	01 d0                	add    %edx,%eax
 499:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 49c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 49f:	c9                   	leave
 4a0:	c3                   	ret

000004a1 <stat>:

int
stat(char *n, struct stat *st)
{
 4a1:	55                   	push   %ebp
 4a2:	89 e5                	mov    %esp,%ebp
 4a4:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4a7:	83 ec 08             	sub    $0x8,%esp
 4aa:	6a 00                	push   $0x0
 4ac:	ff 75 08             	push   0x8(%ebp)
 4af:	e8 0c 01 00 00       	call   5c0 <open>
 4b4:	83 c4 10             	add    $0x10,%esp
 4b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4be:	79 07                	jns    4c7 <stat+0x26>
    return -1;
 4c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4c5:	eb 25                	jmp    4ec <stat+0x4b>
  r = fstat(fd, st);
 4c7:	83 ec 08             	sub    $0x8,%esp
 4ca:	ff 75 0c             	push   0xc(%ebp)
 4cd:	ff 75 f4             	push   -0xc(%ebp)
 4d0:	e8 03 01 00 00       	call   5d8 <fstat>
 4d5:	83 c4 10             	add    $0x10,%esp
 4d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4db:	83 ec 0c             	sub    $0xc,%esp
 4de:	ff 75 f4             	push   -0xc(%ebp)
 4e1:	e8 c2 00 00 00       	call   5a8 <close>
 4e6:	83 c4 10             	add    $0x10,%esp
  return r;
 4e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4ec:	c9                   	leave
 4ed:	c3                   	ret

000004ee <atoi>:

int
atoi(const char *s)
{
 4ee:	55                   	push   %ebp
 4ef:	89 e5                	mov    %esp,%ebp
 4f1:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4f4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4fb:	eb 25                	jmp    522 <atoi+0x34>
    n = n*10 + *s++ - '0';
 4fd:	8b 55 fc             	mov    -0x4(%ebp),%edx
 500:	89 d0                	mov    %edx,%eax
 502:	c1 e0 02             	shl    $0x2,%eax
 505:	01 d0                	add    %edx,%eax
 507:	01 c0                	add    %eax,%eax
 509:	89 c1                	mov    %eax,%ecx
 50b:	8b 45 08             	mov    0x8(%ebp),%eax
 50e:	8d 50 01             	lea    0x1(%eax),%edx
 511:	89 55 08             	mov    %edx,0x8(%ebp)
 514:	0f b6 00             	movzbl (%eax),%eax
 517:	0f be c0             	movsbl %al,%eax
 51a:	01 c8                	add    %ecx,%eax
 51c:	83 e8 30             	sub    $0x30,%eax
 51f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 522:	8b 45 08             	mov    0x8(%ebp),%eax
 525:	0f b6 00             	movzbl (%eax),%eax
 528:	3c 2f                	cmp    $0x2f,%al
 52a:	7e 0a                	jle    536 <atoi+0x48>
 52c:	8b 45 08             	mov    0x8(%ebp),%eax
 52f:	0f b6 00             	movzbl (%eax),%eax
 532:	3c 39                	cmp    $0x39,%al
 534:	7e c7                	jle    4fd <atoi+0xf>
  return n;
 536:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 539:	c9                   	leave
 53a:	c3                   	ret

0000053b <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 53b:	55                   	push   %ebp
 53c:	89 e5                	mov    %esp,%ebp
 53e:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 541:	8b 45 08             	mov    0x8(%ebp),%eax
 544:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 547:	8b 45 0c             	mov    0xc(%ebp),%eax
 54a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 54d:	eb 17                	jmp    566 <memmove+0x2b>
    *dst++ = *src++;
 54f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 552:	8d 42 01             	lea    0x1(%edx),%eax
 555:	89 45 f8             	mov    %eax,-0x8(%ebp)
 558:	8b 45 fc             	mov    -0x4(%ebp),%eax
 55b:	8d 48 01             	lea    0x1(%eax),%ecx
 55e:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 561:	0f b6 12             	movzbl (%edx),%edx
 564:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 566:	8b 45 10             	mov    0x10(%ebp),%eax
 569:	8d 50 ff             	lea    -0x1(%eax),%edx
 56c:	89 55 10             	mov    %edx,0x10(%ebp)
 56f:	85 c0                	test   %eax,%eax
 571:	7f dc                	jg     54f <memmove+0x14>
  return vdst;
 573:	8b 45 08             	mov    0x8(%ebp),%eax
}
 576:	c9                   	leave
 577:	c3                   	ret

00000578 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 578:	b8 01 00 00 00       	mov    $0x1,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret

00000580 <exit>:
SYSCALL(exit)
 580:	b8 02 00 00 00       	mov    $0x2,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret

00000588 <wait>:
SYSCALL(wait)
 588:	b8 03 00 00 00       	mov    $0x3,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret

00000590 <pipe>:
SYSCALL(pipe)
 590:	b8 04 00 00 00       	mov    $0x4,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret

00000598 <read>:
SYSCALL(read)
 598:	b8 05 00 00 00       	mov    $0x5,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret

000005a0 <write>:
SYSCALL(write)
 5a0:	b8 10 00 00 00       	mov    $0x10,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret

000005a8 <close>:
SYSCALL(close)
 5a8:	b8 15 00 00 00       	mov    $0x15,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret

000005b0 <kill>:
SYSCALL(kill)
 5b0:	b8 06 00 00 00       	mov    $0x6,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret

000005b8 <exec>:
SYSCALL(exec)
 5b8:	b8 07 00 00 00       	mov    $0x7,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret

000005c0 <open>:
SYSCALL(open)
 5c0:	b8 0f 00 00 00       	mov    $0xf,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret

000005c8 <mknod>:
SYSCALL(mknod)
 5c8:	b8 11 00 00 00       	mov    $0x11,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret

000005d0 <unlink>:
SYSCALL(unlink)
 5d0:	b8 12 00 00 00       	mov    $0x12,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret

000005d8 <fstat>:
SYSCALL(fstat)
 5d8:	b8 08 00 00 00       	mov    $0x8,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret

000005e0 <link>:
SYSCALL(link)
 5e0:	b8 13 00 00 00       	mov    $0x13,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret

000005e8 <mkdir>:
SYSCALL(mkdir)
 5e8:	b8 14 00 00 00       	mov    $0x14,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret

000005f0 <chdir>:
SYSCALL(chdir)
 5f0:	b8 09 00 00 00       	mov    $0x9,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret

000005f8 <dup>:
SYSCALL(dup)
 5f8:	b8 0a 00 00 00       	mov    $0xa,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret

00000600 <getpid>:
SYSCALL(getpid)
 600:	b8 0b 00 00 00       	mov    $0xb,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret

00000608 <sbrk>:
SYSCALL(sbrk)
 608:	b8 0c 00 00 00       	mov    $0xc,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret

00000610 <sleep>:
SYSCALL(sleep)
 610:	b8 0d 00 00 00       	mov    $0xd,%eax
 615:	cd 40                	int    $0x40
 617:	c3                   	ret

00000618 <uptime>:
SYSCALL(uptime)
 618:	b8 0e 00 00 00       	mov    $0xe,%eax
 61d:	cd 40                	int    $0x40
 61f:	c3                   	ret

00000620 <uthread_init>:
SYSCALL(uthread_init)
 620:	b8 16 00 00 00       	mov    $0x16,%eax
 625:	cd 40                	int    $0x40
 627:	c3                   	ret

00000628 <printpt>:

SYSCALL(printpt)
 628:	b8 17 00 00 00       	mov    $0x17,%eax
 62d:	cd 40                	int    $0x40
 62f:	c3                   	ret

00000630 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 630:	55                   	push   %ebp
 631:	89 e5                	mov    %esp,%ebp
 633:	83 ec 18             	sub    $0x18,%esp
 636:	8b 45 0c             	mov    0xc(%ebp),%eax
 639:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 63c:	83 ec 04             	sub    $0x4,%esp
 63f:	6a 01                	push   $0x1
 641:	8d 45 f4             	lea    -0xc(%ebp),%eax
 644:	50                   	push   %eax
 645:	ff 75 08             	push   0x8(%ebp)
 648:	e8 53 ff ff ff       	call   5a0 <write>
 64d:	83 c4 10             	add    $0x10,%esp
}
 650:	90                   	nop
 651:	c9                   	leave
 652:	c3                   	ret

00000653 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 653:	55                   	push   %ebp
 654:	89 e5                	mov    %esp,%ebp
 656:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 659:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 660:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 664:	74 17                	je     67d <printint+0x2a>
 666:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 66a:	79 11                	jns    67d <printint+0x2a>
    neg = 1;
 66c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 673:	8b 45 0c             	mov    0xc(%ebp),%eax
 676:	f7 d8                	neg    %eax
 678:	89 45 ec             	mov    %eax,-0x14(%ebp)
 67b:	eb 06                	jmp    683 <printint+0x30>
  } else {
    x = xx;
 67d:	8b 45 0c             	mov    0xc(%ebp),%eax
 680:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 683:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 68a:	8b 4d 10             	mov    0x10(%ebp),%ecx
 68d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 690:	ba 00 00 00 00       	mov    $0x0,%edx
 695:	f7 f1                	div    %ecx
 697:	89 d1                	mov    %edx,%ecx
 699:	8b 45 f4             	mov    -0xc(%ebp),%eax
 69c:	8d 50 01             	lea    0x1(%eax),%edx
 69f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6a2:	0f b6 91 98 0b 00 00 	movzbl 0xb98(%ecx),%edx
 6a9:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6b3:	ba 00 00 00 00       	mov    $0x0,%edx
 6b8:	f7 f1                	div    %ecx
 6ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6bd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6c1:	75 c7                	jne    68a <printint+0x37>
  if(neg)
 6c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6c7:	74 2d                	je     6f6 <printint+0xa3>
    buf[i++] = '-';
 6c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6cc:	8d 50 01             	lea    0x1(%eax),%edx
 6cf:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6d2:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6d7:	eb 1d                	jmp    6f6 <printint+0xa3>
    putc(fd, buf[i]);
 6d9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6df:	01 d0                	add    %edx,%eax
 6e1:	0f b6 00             	movzbl (%eax),%eax
 6e4:	0f be c0             	movsbl %al,%eax
 6e7:	83 ec 08             	sub    $0x8,%esp
 6ea:	50                   	push   %eax
 6eb:	ff 75 08             	push   0x8(%ebp)
 6ee:	e8 3d ff ff ff       	call   630 <putc>
 6f3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 6f6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6fe:	79 d9                	jns    6d9 <printint+0x86>
}
 700:	90                   	nop
 701:	90                   	nop
 702:	c9                   	leave
 703:	c3                   	ret

00000704 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 704:	55                   	push   %ebp
 705:	89 e5                	mov    %esp,%ebp
 707:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 70a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 711:	8d 45 0c             	lea    0xc(%ebp),%eax
 714:	83 c0 04             	add    $0x4,%eax
 717:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 71a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 721:	e9 59 01 00 00       	jmp    87f <printf+0x17b>
    c = fmt[i] & 0xff;
 726:	8b 55 0c             	mov    0xc(%ebp),%edx
 729:	8b 45 f0             	mov    -0x10(%ebp),%eax
 72c:	01 d0                	add    %edx,%eax
 72e:	0f b6 00             	movzbl (%eax),%eax
 731:	0f be c0             	movsbl %al,%eax
 734:	25 ff 00 00 00       	and    $0xff,%eax
 739:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 73c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 740:	75 2c                	jne    76e <printf+0x6a>
      if(c == '%'){
 742:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 746:	75 0c                	jne    754 <printf+0x50>
        state = '%';
 748:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 74f:	e9 27 01 00 00       	jmp    87b <printf+0x177>
      } else {
        putc(fd, c);
 754:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 757:	0f be c0             	movsbl %al,%eax
 75a:	83 ec 08             	sub    $0x8,%esp
 75d:	50                   	push   %eax
 75e:	ff 75 08             	push   0x8(%ebp)
 761:	e8 ca fe ff ff       	call   630 <putc>
 766:	83 c4 10             	add    $0x10,%esp
 769:	e9 0d 01 00 00       	jmp    87b <printf+0x177>
      }
    } else if(state == '%'){
 76e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 772:	0f 85 03 01 00 00    	jne    87b <printf+0x177>
      if(c == 'd'){
 778:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 77c:	75 1e                	jne    79c <printf+0x98>
        printint(fd, *ap, 10, 1);
 77e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 781:	8b 00                	mov    (%eax),%eax
 783:	6a 01                	push   $0x1
 785:	6a 0a                	push   $0xa
 787:	50                   	push   %eax
 788:	ff 75 08             	push   0x8(%ebp)
 78b:	e8 c3 fe ff ff       	call   653 <printint>
 790:	83 c4 10             	add    $0x10,%esp
        ap++;
 793:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 797:	e9 d8 00 00 00       	jmp    874 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 79c:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7a0:	74 06                	je     7a8 <printf+0xa4>
 7a2:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7a6:	75 1e                	jne    7c6 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ab:	8b 00                	mov    (%eax),%eax
 7ad:	6a 00                	push   $0x0
 7af:	6a 10                	push   $0x10
 7b1:	50                   	push   %eax
 7b2:	ff 75 08             	push   0x8(%ebp)
 7b5:	e8 99 fe ff ff       	call   653 <printint>
 7ba:	83 c4 10             	add    $0x10,%esp
        ap++;
 7bd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7c1:	e9 ae 00 00 00       	jmp    874 <printf+0x170>
      } else if(c == 's'){
 7c6:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7ca:	75 43                	jne    80f <printf+0x10b>
        s = (char*)*ap;
 7cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7cf:	8b 00                	mov    (%eax),%eax
 7d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7d4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7dc:	75 25                	jne    803 <printf+0xff>
          s = "(null)";
 7de:	c7 45 f4 8e 0b 00 00 	movl   $0xb8e,-0xc(%ebp)
        while(*s != 0){
 7e5:	eb 1c                	jmp    803 <printf+0xff>
          putc(fd, *s);
 7e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ea:	0f b6 00             	movzbl (%eax),%eax
 7ed:	0f be c0             	movsbl %al,%eax
 7f0:	83 ec 08             	sub    $0x8,%esp
 7f3:	50                   	push   %eax
 7f4:	ff 75 08             	push   0x8(%ebp)
 7f7:	e8 34 fe ff ff       	call   630 <putc>
 7fc:	83 c4 10             	add    $0x10,%esp
          s++;
 7ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 803:	8b 45 f4             	mov    -0xc(%ebp),%eax
 806:	0f b6 00             	movzbl (%eax),%eax
 809:	84 c0                	test   %al,%al
 80b:	75 da                	jne    7e7 <printf+0xe3>
 80d:	eb 65                	jmp    874 <printf+0x170>
        }
      } else if(c == 'c'){
 80f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 813:	75 1d                	jne    832 <printf+0x12e>
        putc(fd, *ap);
 815:	8b 45 e8             	mov    -0x18(%ebp),%eax
 818:	8b 00                	mov    (%eax),%eax
 81a:	0f be c0             	movsbl %al,%eax
 81d:	83 ec 08             	sub    $0x8,%esp
 820:	50                   	push   %eax
 821:	ff 75 08             	push   0x8(%ebp)
 824:	e8 07 fe ff ff       	call   630 <putc>
 829:	83 c4 10             	add    $0x10,%esp
        ap++;
 82c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 830:	eb 42                	jmp    874 <printf+0x170>
      } else if(c == '%'){
 832:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 836:	75 17                	jne    84f <printf+0x14b>
        putc(fd, c);
 838:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 83b:	0f be c0             	movsbl %al,%eax
 83e:	83 ec 08             	sub    $0x8,%esp
 841:	50                   	push   %eax
 842:	ff 75 08             	push   0x8(%ebp)
 845:	e8 e6 fd ff ff       	call   630 <putc>
 84a:	83 c4 10             	add    $0x10,%esp
 84d:	eb 25                	jmp    874 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 84f:	83 ec 08             	sub    $0x8,%esp
 852:	6a 25                	push   $0x25
 854:	ff 75 08             	push   0x8(%ebp)
 857:	e8 d4 fd ff ff       	call   630 <putc>
 85c:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 85f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 862:	0f be c0             	movsbl %al,%eax
 865:	83 ec 08             	sub    $0x8,%esp
 868:	50                   	push   %eax
 869:	ff 75 08             	push   0x8(%ebp)
 86c:	e8 bf fd ff ff       	call   630 <putc>
 871:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 874:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 87b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 87f:	8b 55 0c             	mov    0xc(%ebp),%edx
 882:	8b 45 f0             	mov    -0x10(%ebp),%eax
 885:	01 d0                	add    %edx,%eax
 887:	0f b6 00             	movzbl (%eax),%eax
 88a:	84 c0                	test   %al,%al
 88c:	0f 85 94 fe ff ff    	jne    726 <printf+0x22>
    }
  }
}
 892:	90                   	nop
 893:	90                   	nop
 894:	c9                   	leave
 895:	c3                   	ret

00000896 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 896:	55                   	push   %ebp
 897:	89 e5                	mov    %esp,%ebp
 899:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 89c:	8b 45 08             	mov    0x8(%ebp),%eax
 89f:	83 e8 08             	sub    $0x8,%eax
 8a2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a5:	a1 b4 0b 00 00       	mov    0xbb4,%eax
 8aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8ad:	eb 24                	jmp    8d3 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b2:	8b 00                	mov    (%eax),%eax
 8b4:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8b7:	72 12                	jb     8cb <free+0x35>
 8b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8bc:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8bf:	72 24                	jb     8e5 <free+0x4f>
 8c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c4:	8b 00                	mov    (%eax),%eax
 8c6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8c9:	72 1a                	jb     8e5 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ce:	8b 00                	mov    (%eax),%eax
 8d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d6:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 8d9:	73 d4                	jae    8af <free+0x19>
 8db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8de:	8b 00                	mov    (%eax),%eax
 8e0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8e3:	73 ca                	jae    8af <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e8:	8b 40 04             	mov    0x4(%eax),%eax
 8eb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f5:	01 c2                	add    %eax,%edx
 8f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fa:	8b 00                	mov    (%eax),%eax
 8fc:	39 c2                	cmp    %eax,%edx
 8fe:	75 24                	jne    924 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 900:	8b 45 f8             	mov    -0x8(%ebp),%eax
 903:	8b 50 04             	mov    0x4(%eax),%edx
 906:	8b 45 fc             	mov    -0x4(%ebp),%eax
 909:	8b 00                	mov    (%eax),%eax
 90b:	8b 40 04             	mov    0x4(%eax),%eax
 90e:	01 c2                	add    %eax,%edx
 910:	8b 45 f8             	mov    -0x8(%ebp),%eax
 913:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 916:	8b 45 fc             	mov    -0x4(%ebp),%eax
 919:	8b 00                	mov    (%eax),%eax
 91b:	8b 10                	mov    (%eax),%edx
 91d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 920:	89 10                	mov    %edx,(%eax)
 922:	eb 0a                	jmp    92e <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 924:	8b 45 fc             	mov    -0x4(%ebp),%eax
 927:	8b 10                	mov    (%eax),%edx
 929:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92c:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 92e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 931:	8b 40 04             	mov    0x4(%eax),%eax
 934:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 93b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93e:	01 d0                	add    %edx,%eax
 940:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 943:	75 20                	jne    965 <free+0xcf>
    p->s.size += bp->s.size;
 945:	8b 45 fc             	mov    -0x4(%ebp),%eax
 948:	8b 50 04             	mov    0x4(%eax),%edx
 94b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94e:	8b 40 04             	mov    0x4(%eax),%eax
 951:	01 c2                	add    %eax,%edx
 953:	8b 45 fc             	mov    -0x4(%ebp),%eax
 956:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 959:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95c:	8b 10                	mov    (%eax),%edx
 95e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 961:	89 10                	mov    %edx,(%eax)
 963:	eb 08                	jmp    96d <free+0xd7>
  } else
    p->s.ptr = bp;
 965:	8b 45 fc             	mov    -0x4(%ebp),%eax
 968:	8b 55 f8             	mov    -0x8(%ebp),%edx
 96b:	89 10                	mov    %edx,(%eax)
  freep = p;
 96d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 970:	a3 b4 0b 00 00       	mov    %eax,0xbb4
}
 975:	90                   	nop
 976:	c9                   	leave
 977:	c3                   	ret

00000978 <morecore>:

static Header*
morecore(uint nu)
{
 978:	55                   	push   %ebp
 979:	89 e5                	mov    %esp,%ebp
 97b:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 97e:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 985:	77 07                	ja     98e <morecore+0x16>
    nu = 4096;
 987:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 98e:	8b 45 08             	mov    0x8(%ebp),%eax
 991:	c1 e0 03             	shl    $0x3,%eax
 994:	83 ec 0c             	sub    $0xc,%esp
 997:	50                   	push   %eax
 998:	e8 6b fc ff ff       	call   608 <sbrk>
 99d:	83 c4 10             	add    $0x10,%esp
 9a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9a3:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9a7:	75 07                	jne    9b0 <morecore+0x38>
    return 0;
 9a9:	b8 00 00 00 00       	mov    $0x0,%eax
 9ae:	eb 26                	jmp    9d6 <morecore+0x5e>
  hp = (Header*)p;
 9b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b9:	8b 55 08             	mov    0x8(%ebp),%edx
 9bc:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c2:	83 c0 08             	add    $0x8,%eax
 9c5:	83 ec 0c             	sub    $0xc,%esp
 9c8:	50                   	push   %eax
 9c9:	e8 c8 fe ff ff       	call   896 <free>
 9ce:	83 c4 10             	add    $0x10,%esp
  return freep;
 9d1:	a1 b4 0b 00 00       	mov    0xbb4,%eax
}
 9d6:	c9                   	leave
 9d7:	c3                   	ret

000009d8 <malloc>:

void*
malloc(uint nbytes)
{
 9d8:	55                   	push   %ebp
 9d9:	89 e5                	mov    %esp,%ebp
 9db:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9de:	8b 45 08             	mov    0x8(%ebp),%eax
 9e1:	83 c0 07             	add    $0x7,%eax
 9e4:	c1 e8 03             	shr    $0x3,%eax
 9e7:	83 c0 01             	add    $0x1,%eax
 9ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9ed:	a1 b4 0b 00 00       	mov    0xbb4,%eax
 9f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9f5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9f9:	75 23                	jne    a1e <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9fb:	c7 45 f0 ac 0b 00 00 	movl   $0xbac,-0x10(%ebp)
 a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a05:	a3 b4 0b 00 00       	mov    %eax,0xbb4
 a0a:	a1 b4 0b 00 00       	mov    0xbb4,%eax
 a0f:	a3 ac 0b 00 00       	mov    %eax,0xbac
    base.s.size = 0;
 a14:	c7 05 b0 0b 00 00 00 	movl   $0x0,0xbb0
 a1b:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a21:	8b 00                	mov    (%eax),%eax
 a23:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a29:	8b 40 04             	mov    0x4(%eax),%eax
 a2c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a2f:	72 4d                	jb     a7e <malloc+0xa6>
      if(p->s.size == nunits)
 a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a34:	8b 40 04             	mov    0x4(%eax),%eax
 a37:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a3a:	75 0c                	jne    a48 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3f:	8b 10                	mov    (%eax),%edx
 a41:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a44:	89 10                	mov    %edx,(%eax)
 a46:	eb 26                	jmp    a6e <malloc+0x96>
      else {
        p->s.size -= nunits;
 a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4b:	8b 40 04             	mov    0x4(%eax),%eax
 a4e:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a51:	89 c2                	mov    %eax,%edx
 a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a56:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5c:	8b 40 04             	mov    0x4(%eax),%eax
 a5f:	c1 e0 03             	shl    $0x3,%eax
 a62:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a68:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a6b:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a71:	a3 b4 0b 00 00       	mov    %eax,0xbb4
      return (void*)(p + 1);
 a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a79:	83 c0 08             	add    $0x8,%eax
 a7c:	eb 3b                	jmp    ab9 <malloc+0xe1>
    }
    if(p == freep)
 a7e:	a1 b4 0b 00 00       	mov    0xbb4,%eax
 a83:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a86:	75 1e                	jne    aa6 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a88:	83 ec 0c             	sub    $0xc,%esp
 a8b:	ff 75 ec             	push   -0x14(%ebp)
 a8e:	e8 e5 fe ff ff       	call   978 <morecore>
 a93:	83 c4 10             	add    $0x10,%esp
 a96:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a9d:	75 07                	jne    aa6 <malloc+0xce>
        return 0;
 a9f:	b8 00 00 00 00       	mov    $0x0,%eax
 aa4:	eb 13                	jmp    ab9 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aaf:	8b 00                	mov    (%eax),%eax
 ab1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ab4:	e9 6d ff ff ff       	jmp    a26 <malloc+0x4e>
  }
}
 ab9:	c9                   	leave
 aba:	c3                   	ret
