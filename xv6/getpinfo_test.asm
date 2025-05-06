
_getpinfo_test:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"
#include "pstat.h"

int main(void) {
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	81 ec 14 0c 00 00    	sub    $0xc14,%esp
  struct pstat ps;

  // 시스템 콜 호출
  if (getpinfo(&ps) < 0) {
  14:	83 ec 0c             	sub    $0xc,%esp
  17:	8d 85 f0 f3 ff ff    	lea    -0xc10(%ebp),%eax
  1d:	50                   	push   %eax
  1e:	e8 1a 04 00 00       	call   43d <getpinfo>
  23:	83 c4 10             	add    $0x10,%esp
  26:	85 c0                	test   %eax,%eax
  28:	79 17                	jns    41 <main+0x41>
    printf(1, "getpinfo failed\n");
  2a:	83 ec 08             	sub    $0x8,%esp
  2d:	68 e8 08 00 00       	push   $0x8e8
  32:	6a 01                	push   $0x1
  34:	e8 f8 04 00 00       	call   531 <printf>
  39:	83 c4 10             	add    $0x10,%esp
    exit();
  3c:	e8 5c 03 00 00       	call   39d <exit>
  }

  // 모든 프로세스 출력
  for (int i = 0; i < NPROC; i++) {
  41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  48:	e9 ea 00 00 00       	jmp    137 <main+0x137>
    if (ps.inuse[i]) {
  4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  50:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
  57:	85 c0                	test   %eax,%eax
  59:	0f 84 d4 00 00 00    	je     133 <main+0x133>
      printf(1, "---------------------------------\n");
  5f:	83 ec 08             	sub    $0x8,%esp
  62:	68 fc 08 00 00       	push   $0x8fc
  67:	6a 01                	push   $0x1
  69:	e8 c3 04 00 00       	call   531 <printf>
  6e:	83 c4 10             	add    $0x10,%esp
      printf(1, "PID: %d\n", ps.pid[i]);
  71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  74:	83 c0 40             	add    $0x40,%eax
  77:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
  7e:	83 ec 04             	sub    $0x4,%esp
  81:	50                   	push   %eax
  82:	68 1f 09 00 00       	push   $0x91f
  87:	6a 01                	push   $0x1
  89:	e8 a3 04 00 00       	call   531 <printf>
  8e:	83 c4 10             	add    $0x10,%esp
      printf(1, "State: %d\n", ps.state[i]);       // enum procstate
  91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  94:	05 c0 00 00 00       	add    $0xc0,%eax
  99:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
  a0:	83 ec 04             	sub    $0x4,%esp
  a3:	50                   	push   %eax
  a4:	68 28 09 00 00       	push   $0x928
  a9:	6a 01                	push   $0x1
  ab:	e8 81 04 00 00       	call   531 <printf>
  b0:	83 c4 10             	add    $0x10,%esp
      printf(1, "Priority: %d\n", ps.priority[i]);
  b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  b6:	83 e8 80             	sub    $0xffffff80,%eax
  b9:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
  c0:	83 ec 04             	sub    $0x4,%esp
  c3:	50                   	push   %eax
  c4:	68 33 09 00 00       	push   $0x933
  c9:	6a 01                	push   $0x1
  cb:	e8 61 04 00 00       	call   531 <printf>
  d0:	83 c4 10             	add    $0x10,%esp
      for (int q = 0; q < 4; q++) {
  d3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  da:	eb 51                	jmp    12d <main+0x12d>
        printf(1, "  Q%d: ticks=%d, wait=%d\n", q,
  dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  df:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  e9:	01 d0                	add    %edx,%eax
  eb:	05 00 02 00 00       	add    $0x200,%eax
  f0:	8b 94 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%edx
  f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  fa:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
 101:	8b 45 f0             	mov    -0x10(%ebp),%eax
 104:	01 c8                	add    %ecx,%eax
 106:	05 00 01 00 00       	add    $0x100,%eax
 10b:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
 112:	83 ec 0c             	sub    $0xc,%esp
 115:	52                   	push   %edx
 116:	50                   	push   %eax
 117:	ff 75 f0             	push   -0x10(%ebp)
 11a:	68 41 09 00 00       	push   $0x941
 11f:	6a 01                	push   $0x1
 121:	e8 0b 04 00 00       	call   531 <printf>
 126:	83 c4 20             	add    $0x20,%esp
      for (int q = 0; q < 4; q++) {
 129:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 12d:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
 131:	7e a9                	jle    dc <main+0xdc>
  for (int i = 0; i < NPROC; i++) {
 133:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 137:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
 13b:	0f 8e 0c ff ff ff    	jle    4d <main+0x4d>
               ps.ticks[i][q], ps.wait_ticks[i][q]);
      }
    }
  }

  exit();
 141:	e8 57 02 00 00       	call   39d <exit>

00000146 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 146:	55                   	push   %ebp
 147:	89 e5                	mov    %esp,%ebp
 149:	57                   	push   %edi
 14a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 14b:	8b 4d 08             	mov    0x8(%ebp),%ecx
 14e:	8b 55 10             	mov    0x10(%ebp),%edx
 151:	8b 45 0c             	mov    0xc(%ebp),%eax
 154:	89 cb                	mov    %ecx,%ebx
 156:	89 df                	mov    %ebx,%edi
 158:	89 d1                	mov    %edx,%ecx
 15a:	fc                   	cld
 15b:	f3 aa                	rep stos %al,%es:(%edi)
 15d:	89 ca                	mov    %ecx,%edx
 15f:	89 fb                	mov    %edi,%ebx
 161:	89 5d 08             	mov    %ebx,0x8(%ebp)
 164:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 167:	90                   	nop
 168:	5b                   	pop    %ebx
 169:	5f                   	pop    %edi
 16a:	5d                   	pop    %ebp
 16b:	c3                   	ret

0000016c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 16c:	55                   	push   %ebp
 16d:	89 e5                	mov    %esp,%ebp
 16f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 172:	8b 45 08             	mov    0x8(%ebp),%eax
 175:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 178:	90                   	nop
 179:	8b 55 0c             	mov    0xc(%ebp),%edx
 17c:	8d 42 01             	lea    0x1(%edx),%eax
 17f:	89 45 0c             	mov    %eax,0xc(%ebp)
 182:	8b 45 08             	mov    0x8(%ebp),%eax
 185:	8d 48 01             	lea    0x1(%eax),%ecx
 188:	89 4d 08             	mov    %ecx,0x8(%ebp)
 18b:	0f b6 12             	movzbl (%edx),%edx
 18e:	88 10                	mov    %dl,(%eax)
 190:	0f b6 00             	movzbl (%eax),%eax
 193:	84 c0                	test   %al,%al
 195:	75 e2                	jne    179 <strcpy+0xd>
    ;
  return os;
 197:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 19a:	c9                   	leave
 19b:	c3                   	ret

0000019c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 19c:	55                   	push   %ebp
 19d:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 19f:	eb 08                	jmp    1a9 <strcmp+0xd>
    p++, q++;
 1a1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1a5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 1a9:	8b 45 08             	mov    0x8(%ebp),%eax
 1ac:	0f b6 00             	movzbl (%eax),%eax
 1af:	84 c0                	test   %al,%al
 1b1:	74 10                	je     1c3 <strcmp+0x27>
 1b3:	8b 45 08             	mov    0x8(%ebp),%eax
 1b6:	0f b6 10             	movzbl (%eax),%edx
 1b9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1bc:	0f b6 00             	movzbl (%eax),%eax
 1bf:	38 c2                	cmp    %al,%dl
 1c1:	74 de                	je     1a1 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 1c3:	8b 45 08             	mov    0x8(%ebp),%eax
 1c6:	0f b6 00             	movzbl (%eax),%eax
 1c9:	0f b6 d0             	movzbl %al,%edx
 1cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 1cf:	0f b6 00             	movzbl (%eax),%eax
 1d2:	0f b6 c0             	movzbl %al,%eax
 1d5:	29 c2                	sub    %eax,%edx
 1d7:	89 d0                	mov    %edx,%eax
}
 1d9:	5d                   	pop    %ebp
 1da:	c3                   	ret

000001db <strlen>:

uint
strlen(char *s)
{
 1db:	55                   	push   %ebp
 1dc:	89 e5                	mov    %esp,%ebp
 1de:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1e1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1e8:	eb 04                	jmp    1ee <strlen+0x13>
 1ea:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1ee:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1f1:	8b 45 08             	mov    0x8(%ebp),%eax
 1f4:	01 d0                	add    %edx,%eax
 1f6:	0f b6 00             	movzbl (%eax),%eax
 1f9:	84 c0                	test   %al,%al
 1fb:	75 ed                	jne    1ea <strlen+0xf>
    ;
  return n;
 1fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 200:	c9                   	leave
 201:	c3                   	ret

00000202 <memset>:

void*
memset(void *dst, int c, uint n)
{
 202:	55                   	push   %ebp
 203:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 205:	8b 45 10             	mov    0x10(%ebp),%eax
 208:	50                   	push   %eax
 209:	ff 75 0c             	push   0xc(%ebp)
 20c:	ff 75 08             	push   0x8(%ebp)
 20f:	e8 32 ff ff ff       	call   146 <stosb>
 214:	83 c4 0c             	add    $0xc,%esp
  return dst;
 217:	8b 45 08             	mov    0x8(%ebp),%eax
}
 21a:	c9                   	leave
 21b:	c3                   	ret

0000021c <strchr>:

char*
strchr(const char *s, char c)
{
 21c:	55                   	push   %ebp
 21d:	89 e5                	mov    %esp,%ebp
 21f:	83 ec 04             	sub    $0x4,%esp
 222:	8b 45 0c             	mov    0xc(%ebp),%eax
 225:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 228:	eb 14                	jmp    23e <strchr+0x22>
    if(*s == c)
 22a:	8b 45 08             	mov    0x8(%ebp),%eax
 22d:	0f b6 00             	movzbl (%eax),%eax
 230:	38 45 fc             	cmp    %al,-0x4(%ebp)
 233:	75 05                	jne    23a <strchr+0x1e>
      return (char*)s;
 235:	8b 45 08             	mov    0x8(%ebp),%eax
 238:	eb 13                	jmp    24d <strchr+0x31>
  for(; *s; s++)
 23a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 23e:	8b 45 08             	mov    0x8(%ebp),%eax
 241:	0f b6 00             	movzbl (%eax),%eax
 244:	84 c0                	test   %al,%al
 246:	75 e2                	jne    22a <strchr+0xe>
  return 0;
 248:	b8 00 00 00 00       	mov    $0x0,%eax
}
 24d:	c9                   	leave
 24e:	c3                   	ret

0000024f <gets>:

char*
gets(char *buf, int max)
{
 24f:	55                   	push   %ebp
 250:	89 e5                	mov    %esp,%ebp
 252:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 255:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 25c:	eb 42                	jmp    2a0 <gets+0x51>
    cc = read(0, &c, 1);
 25e:	83 ec 04             	sub    $0x4,%esp
 261:	6a 01                	push   $0x1
 263:	8d 45 ef             	lea    -0x11(%ebp),%eax
 266:	50                   	push   %eax
 267:	6a 00                	push   $0x0
 269:	e8 47 01 00 00       	call   3b5 <read>
 26e:	83 c4 10             	add    $0x10,%esp
 271:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 274:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 278:	7e 33                	jle    2ad <gets+0x5e>
      break;
    buf[i++] = c;
 27a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27d:	8d 50 01             	lea    0x1(%eax),%edx
 280:	89 55 f4             	mov    %edx,-0xc(%ebp)
 283:	89 c2                	mov    %eax,%edx
 285:	8b 45 08             	mov    0x8(%ebp),%eax
 288:	01 c2                	add    %eax,%edx
 28a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 28e:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 290:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 294:	3c 0a                	cmp    $0xa,%al
 296:	74 16                	je     2ae <gets+0x5f>
 298:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 29c:	3c 0d                	cmp    $0xd,%al
 29e:	74 0e                	je     2ae <gets+0x5f>
  for(i=0; i+1 < max; ){
 2a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a3:	83 c0 01             	add    $0x1,%eax
 2a6:	39 45 0c             	cmp    %eax,0xc(%ebp)
 2a9:	7f b3                	jg     25e <gets+0xf>
 2ab:	eb 01                	jmp    2ae <gets+0x5f>
      break;
 2ad:	90                   	nop
      break;
  }
  buf[i] = '\0';
 2ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2b1:	8b 45 08             	mov    0x8(%ebp),%eax
 2b4:	01 d0                	add    %edx,%eax
 2b6:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2b9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2bc:	c9                   	leave
 2bd:	c3                   	ret

000002be <stat>:

int
stat(char *n, struct stat *st)
{
 2be:	55                   	push   %ebp
 2bf:	89 e5                	mov    %esp,%ebp
 2c1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2c4:	83 ec 08             	sub    $0x8,%esp
 2c7:	6a 00                	push   $0x0
 2c9:	ff 75 08             	push   0x8(%ebp)
 2cc:	e8 0c 01 00 00       	call   3dd <open>
 2d1:	83 c4 10             	add    $0x10,%esp
 2d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2db:	79 07                	jns    2e4 <stat+0x26>
    return -1;
 2dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2e2:	eb 25                	jmp    309 <stat+0x4b>
  r = fstat(fd, st);
 2e4:	83 ec 08             	sub    $0x8,%esp
 2e7:	ff 75 0c             	push   0xc(%ebp)
 2ea:	ff 75 f4             	push   -0xc(%ebp)
 2ed:	e8 03 01 00 00       	call   3f5 <fstat>
 2f2:	83 c4 10             	add    $0x10,%esp
 2f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2f8:	83 ec 0c             	sub    $0xc,%esp
 2fb:	ff 75 f4             	push   -0xc(%ebp)
 2fe:	e8 c2 00 00 00       	call   3c5 <close>
 303:	83 c4 10             	add    $0x10,%esp
  return r;
 306:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 309:	c9                   	leave
 30a:	c3                   	ret

0000030b <atoi>:

int
atoi(const char *s)
{
 30b:	55                   	push   %ebp
 30c:	89 e5                	mov    %esp,%ebp
 30e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 311:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 318:	eb 25                	jmp    33f <atoi+0x34>
    n = n*10 + *s++ - '0';
 31a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 31d:	89 d0                	mov    %edx,%eax
 31f:	c1 e0 02             	shl    $0x2,%eax
 322:	01 d0                	add    %edx,%eax
 324:	01 c0                	add    %eax,%eax
 326:	89 c1                	mov    %eax,%ecx
 328:	8b 45 08             	mov    0x8(%ebp),%eax
 32b:	8d 50 01             	lea    0x1(%eax),%edx
 32e:	89 55 08             	mov    %edx,0x8(%ebp)
 331:	0f b6 00             	movzbl (%eax),%eax
 334:	0f be c0             	movsbl %al,%eax
 337:	01 c8                	add    %ecx,%eax
 339:	83 e8 30             	sub    $0x30,%eax
 33c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 33f:	8b 45 08             	mov    0x8(%ebp),%eax
 342:	0f b6 00             	movzbl (%eax),%eax
 345:	3c 2f                	cmp    $0x2f,%al
 347:	7e 0a                	jle    353 <atoi+0x48>
 349:	8b 45 08             	mov    0x8(%ebp),%eax
 34c:	0f b6 00             	movzbl (%eax),%eax
 34f:	3c 39                	cmp    $0x39,%al
 351:	7e c7                	jle    31a <atoi+0xf>
  return n;
 353:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 356:	c9                   	leave
 357:	c3                   	ret

00000358 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 358:	55                   	push   %ebp
 359:	89 e5                	mov    %esp,%ebp
 35b:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 35e:	8b 45 08             	mov    0x8(%ebp),%eax
 361:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 364:	8b 45 0c             	mov    0xc(%ebp),%eax
 367:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 36a:	eb 17                	jmp    383 <memmove+0x2b>
    *dst++ = *src++;
 36c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 36f:	8d 42 01             	lea    0x1(%edx),%eax
 372:	89 45 f8             	mov    %eax,-0x8(%ebp)
 375:	8b 45 fc             	mov    -0x4(%ebp),%eax
 378:	8d 48 01             	lea    0x1(%eax),%ecx
 37b:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 37e:	0f b6 12             	movzbl (%edx),%edx
 381:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 383:	8b 45 10             	mov    0x10(%ebp),%eax
 386:	8d 50 ff             	lea    -0x1(%eax),%edx
 389:	89 55 10             	mov    %edx,0x10(%ebp)
 38c:	85 c0                	test   %eax,%eax
 38e:	7f dc                	jg     36c <memmove+0x14>
  return vdst;
 390:	8b 45 08             	mov    0x8(%ebp),%eax
}
 393:	c9                   	leave
 394:	c3                   	ret

00000395 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 395:	b8 01 00 00 00       	mov    $0x1,%eax
 39a:	cd 40                	int    $0x40
 39c:	c3                   	ret

0000039d <exit>:
SYSCALL(exit)
 39d:	b8 02 00 00 00       	mov    $0x2,%eax
 3a2:	cd 40                	int    $0x40
 3a4:	c3                   	ret

000003a5 <wait>:
SYSCALL(wait)
 3a5:	b8 03 00 00 00       	mov    $0x3,%eax
 3aa:	cd 40                	int    $0x40
 3ac:	c3                   	ret

000003ad <pipe>:
SYSCALL(pipe)
 3ad:	b8 04 00 00 00       	mov    $0x4,%eax
 3b2:	cd 40                	int    $0x40
 3b4:	c3                   	ret

000003b5 <read>:
SYSCALL(read)
 3b5:	b8 05 00 00 00       	mov    $0x5,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret

000003bd <write>:
SYSCALL(write)
 3bd:	b8 10 00 00 00       	mov    $0x10,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret

000003c5 <close>:
SYSCALL(close)
 3c5:	b8 15 00 00 00       	mov    $0x15,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret

000003cd <kill>:
SYSCALL(kill)
 3cd:	b8 06 00 00 00       	mov    $0x6,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret

000003d5 <exec>:
SYSCALL(exec)
 3d5:	b8 07 00 00 00       	mov    $0x7,%eax
 3da:	cd 40                	int    $0x40
 3dc:	c3                   	ret

000003dd <open>:
SYSCALL(open)
 3dd:	b8 0f 00 00 00       	mov    $0xf,%eax
 3e2:	cd 40                	int    $0x40
 3e4:	c3                   	ret

000003e5 <mknod>:
SYSCALL(mknod)
 3e5:	b8 11 00 00 00       	mov    $0x11,%eax
 3ea:	cd 40                	int    $0x40
 3ec:	c3                   	ret

000003ed <unlink>:
SYSCALL(unlink)
 3ed:	b8 12 00 00 00       	mov    $0x12,%eax
 3f2:	cd 40                	int    $0x40
 3f4:	c3                   	ret

000003f5 <fstat>:
SYSCALL(fstat)
 3f5:	b8 08 00 00 00       	mov    $0x8,%eax
 3fa:	cd 40                	int    $0x40
 3fc:	c3                   	ret

000003fd <link>:
SYSCALL(link)
 3fd:	b8 13 00 00 00       	mov    $0x13,%eax
 402:	cd 40                	int    $0x40
 404:	c3                   	ret

00000405 <mkdir>:
SYSCALL(mkdir)
 405:	b8 14 00 00 00       	mov    $0x14,%eax
 40a:	cd 40                	int    $0x40
 40c:	c3                   	ret

0000040d <chdir>:
SYSCALL(chdir)
 40d:	b8 09 00 00 00       	mov    $0x9,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret

00000415 <dup>:
SYSCALL(dup)
 415:	b8 0a 00 00 00       	mov    $0xa,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret

0000041d <getpid>:
SYSCALL(getpid)
 41d:	b8 0b 00 00 00       	mov    $0xb,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret

00000425 <sbrk>:
SYSCALL(sbrk)
 425:	b8 0c 00 00 00       	mov    $0xc,%eax
 42a:	cd 40                	int    $0x40
 42c:	c3                   	ret

0000042d <sleep>:
SYSCALL(sleep)
 42d:	b8 0d 00 00 00       	mov    $0xd,%eax
 432:	cd 40                	int    $0x40
 434:	c3                   	ret

00000435 <uptime>:
SYSCALL(uptime)
 435:	b8 0e 00 00 00       	mov    $0xe,%eax
 43a:	cd 40                	int    $0x40
 43c:	c3                   	ret

0000043d <getpinfo>:

SYSCALL(getpinfo)
 43d:	b8 16 00 00 00       	mov    $0x16,%eax
 442:	cd 40                	int    $0x40
 444:	c3                   	ret

00000445 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 445:	b8 17 00 00 00       	mov    $0x17,%eax
 44a:	cd 40                	int    $0x40
 44c:	c3                   	ret

0000044d <yield>:
SYSCALL(yield)
 44d:	b8 18 00 00 00       	mov    $0x18,%eax
 452:	cd 40                	int    $0x40
 454:	c3                   	ret

00000455 <getSchedPolicy>:
 455:	b8 19 00 00 00       	mov    $0x19,%eax
 45a:	cd 40                	int    $0x40
 45c:	c3                   	ret

0000045d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 45d:	55                   	push   %ebp
 45e:	89 e5                	mov    %esp,%ebp
 460:	83 ec 18             	sub    $0x18,%esp
 463:	8b 45 0c             	mov    0xc(%ebp),%eax
 466:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 469:	83 ec 04             	sub    $0x4,%esp
 46c:	6a 01                	push   $0x1
 46e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 471:	50                   	push   %eax
 472:	ff 75 08             	push   0x8(%ebp)
 475:	e8 43 ff ff ff       	call   3bd <write>
 47a:	83 c4 10             	add    $0x10,%esp
}
 47d:	90                   	nop
 47e:	c9                   	leave
 47f:	c3                   	ret

00000480 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 480:	55                   	push   %ebp
 481:	89 e5                	mov    %esp,%ebp
 483:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 486:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 48d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 491:	74 17                	je     4aa <printint+0x2a>
 493:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 497:	79 11                	jns    4aa <printint+0x2a>
    neg = 1;
 499:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a3:	f7 d8                	neg    %eax
 4a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a8:	eb 06                	jmp    4b0 <printint+0x30>
  } else {
    x = xx;
 4aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4bd:	ba 00 00 00 00       	mov    $0x0,%edx
 4c2:	f7 f1                	div    %ecx
 4c4:	89 d1                	mov    %edx,%ecx
 4c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c9:	8d 50 01             	lea    0x1(%eax),%edx
 4cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4cf:	0f b6 91 64 09 00 00 	movzbl 0x964(%ecx),%edx
 4d6:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 4da:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4e0:	ba 00 00 00 00       	mov    $0x0,%edx
 4e5:	f7 f1                	div    %ecx
 4e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4ea:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ee:	75 c7                	jne    4b7 <printint+0x37>
  if(neg)
 4f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4f4:	74 2d                	je     523 <printint+0xa3>
    buf[i++] = '-';
 4f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f9:	8d 50 01             	lea    0x1(%eax),%edx
 4fc:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4ff:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 504:	eb 1d                	jmp    523 <printint+0xa3>
    putc(fd, buf[i]);
 506:	8d 55 dc             	lea    -0x24(%ebp),%edx
 509:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50c:	01 d0                	add    %edx,%eax
 50e:	0f b6 00             	movzbl (%eax),%eax
 511:	0f be c0             	movsbl %al,%eax
 514:	83 ec 08             	sub    $0x8,%esp
 517:	50                   	push   %eax
 518:	ff 75 08             	push   0x8(%ebp)
 51b:	e8 3d ff ff ff       	call   45d <putc>
 520:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 523:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 527:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 52b:	79 d9                	jns    506 <printint+0x86>
}
 52d:	90                   	nop
 52e:	90                   	nop
 52f:	c9                   	leave
 530:	c3                   	ret

00000531 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 531:	55                   	push   %ebp
 532:	89 e5                	mov    %esp,%ebp
 534:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 537:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 53e:	8d 45 0c             	lea    0xc(%ebp),%eax
 541:	83 c0 04             	add    $0x4,%eax
 544:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 547:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 54e:	e9 59 01 00 00       	jmp    6ac <printf+0x17b>
    c = fmt[i] & 0xff;
 553:	8b 55 0c             	mov    0xc(%ebp),%edx
 556:	8b 45 f0             	mov    -0x10(%ebp),%eax
 559:	01 d0                	add    %edx,%eax
 55b:	0f b6 00             	movzbl (%eax),%eax
 55e:	0f be c0             	movsbl %al,%eax
 561:	25 ff 00 00 00       	and    $0xff,%eax
 566:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 569:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 56d:	75 2c                	jne    59b <printf+0x6a>
      if(c == '%'){
 56f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 573:	75 0c                	jne    581 <printf+0x50>
        state = '%';
 575:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 57c:	e9 27 01 00 00       	jmp    6a8 <printf+0x177>
      } else {
        putc(fd, c);
 581:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 584:	0f be c0             	movsbl %al,%eax
 587:	83 ec 08             	sub    $0x8,%esp
 58a:	50                   	push   %eax
 58b:	ff 75 08             	push   0x8(%ebp)
 58e:	e8 ca fe ff ff       	call   45d <putc>
 593:	83 c4 10             	add    $0x10,%esp
 596:	e9 0d 01 00 00       	jmp    6a8 <printf+0x177>
      }
    } else if(state == '%'){
 59b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 59f:	0f 85 03 01 00 00    	jne    6a8 <printf+0x177>
      if(c == 'd'){
 5a5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5a9:	75 1e                	jne    5c9 <printf+0x98>
        printint(fd, *ap, 10, 1);
 5ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ae:	8b 00                	mov    (%eax),%eax
 5b0:	6a 01                	push   $0x1
 5b2:	6a 0a                	push   $0xa
 5b4:	50                   	push   %eax
 5b5:	ff 75 08             	push   0x8(%ebp)
 5b8:	e8 c3 fe ff ff       	call   480 <printint>
 5bd:	83 c4 10             	add    $0x10,%esp
        ap++;
 5c0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5c4:	e9 d8 00 00 00       	jmp    6a1 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 5c9:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5cd:	74 06                	je     5d5 <printf+0xa4>
 5cf:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5d3:	75 1e                	jne    5f3 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 5d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5d8:	8b 00                	mov    (%eax),%eax
 5da:	6a 00                	push   $0x0
 5dc:	6a 10                	push   $0x10
 5de:	50                   	push   %eax
 5df:	ff 75 08             	push   0x8(%ebp)
 5e2:	e8 99 fe ff ff       	call   480 <printint>
 5e7:	83 c4 10             	add    $0x10,%esp
        ap++;
 5ea:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ee:	e9 ae 00 00 00       	jmp    6a1 <printf+0x170>
      } else if(c == 's'){
 5f3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5f7:	75 43                	jne    63c <printf+0x10b>
        s = (char*)*ap;
 5f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5fc:	8b 00                	mov    (%eax),%eax
 5fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 601:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 605:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 609:	75 25                	jne    630 <printf+0xff>
          s = "(null)";
 60b:	c7 45 f4 5b 09 00 00 	movl   $0x95b,-0xc(%ebp)
        while(*s != 0){
 612:	eb 1c                	jmp    630 <printf+0xff>
          putc(fd, *s);
 614:	8b 45 f4             	mov    -0xc(%ebp),%eax
 617:	0f b6 00             	movzbl (%eax),%eax
 61a:	0f be c0             	movsbl %al,%eax
 61d:	83 ec 08             	sub    $0x8,%esp
 620:	50                   	push   %eax
 621:	ff 75 08             	push   0x8(%ebp)
 624:	e8 34 fe ff ff       	call   45d <putc>
 629:	83 c4 10             	add    $0x10,%esp
          s++;
 62c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 630:	8b 45 f4             	mov    -0xc(%ebp),%eax
 633:	0f b6 00             	movzbl (%eax),%eax
 636:	84 c0                	test   %al,%al
 638:	75 da                	jne    614 <printf+0xe3>
 63a:	eb 65                	jmp    6a1 <printf+0x170>
        }
      } else if(c == 'c'){
 63c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 640:	75 1d                	jne    65f <printf+0x12e>
        putc(fd, *ap);
 642:	8b 45 e8             	mov    -0x18(%ebp),%eax
 645:	8b 00                	mov    (%eax),%eax
 647:	0f be c0             	movsbl %al,%eax
 64a:	83 ec 08             	sub    $0x8,%esp
 64d:	50                   	push   %eax
 64e:	ff 75 08             	push   0x8(%ebp)
 651:	e8 07 fe ff ff       	call   45d <putc>
 656:	83 c4 10             	add    $0x10,%esp
        ap++;
 659:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 65d:	eb 42                	jmp    6a1 <printf+0x170>
      } else if(c == '%'){
 65f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 663:	75 17                	jne    67c <printf+0x14b>
        putc(fd, c);
 665:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 668:	0f be c0             	movsbl %al,%eax
 66b:	83 ec 08             	sub    $0x8,%esp
 66e:	50                   	push   %eax
 66f:	ff 75 08             	push   0x8(%ebp)
 672:	e8 e6 fd ff ff       	call   45d <putc>
 677:	83 c4 10             	add    $0x10,%esp
 67a:	eb 25                	jmp    6a1 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 67c:	83 ec 08             	sub    $0x8,%esp
 67f:	6a 25                	push   $0x25
 681:	ff 75 08             	push   0x8(%ebp)
 684:	e8 d4 fd ff ff       	call   45d <putc>
 689:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 68c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68f:	0f be c0             	movsbl %al,%eax
 692:	83 ec 08             	sub    $0x8,%esp
 695:	50                   	push   %eax
 696:	ff 75 08             	push   0x8(%ebp)
 699:	e8 bf fd ff ff       	call   45d <putc>
 69e:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 6a1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 6a8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6ac:	8b 55 0c             	mov    0xc(%ebp),%edx
 6af:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b2:	01 d0                	add    %edx,%eax
 6b4:	0f b6 00             	movzbl (%eax),%eax
 6b7:	84 c0                	test   %al,%al
 6b9:	0f 85 94 fe ff ff    	jne    553 <printf+0x22>
    }
  }
}
 6bf:	90                   	nop
 6c0:	90                   	nop
 6c1:	c9                   	leave
 6c2:	c3                   	ret

000006c3 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6c3:	55                   	push   %ebp
 6c4:	89 e5                	mov    %esp,%ebp
 6c6:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6c9:	8b 45 08             	mov    0x8(%ebp),%eax
 6cc:	83 e8 08             	sub    $0x8,%eax
 6cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d2:	a1 80 09 00 00       	mov    0x980,%eax
 6d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6da:	eb 24                	jmp    700 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6df:	8b 00                	mov    (%eax),%eax
 6e1:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 6e4:	72 12                	jb     6f8 <free+0x35>
 6e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e9:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 6ec:	72 24                	jb     712 <free+0x4f>
 6ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f1:	8b 00                	mov    (%eax),%eax
 6f3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6f6:	72 1a                	jb     712 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fb:	8b 00                	mov    (%eax),%eax
 6fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
 700:	8b 45 f8             	mov    -0x8(%ebp),%eax
 703:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 706:	73 d4                	jae    6dc <free+0x19>
 708:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70b:	8b 00                	mov    (%eax),%eax
 70d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 710:	73 ca                	jae    6dc <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 712:	8b 45 f8             	mov    -0x8(%ebp),%eax
 715:	8b 40 04             	mov    0x4(%eax),%eax
 718:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 71f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 722:	01 c2                	add    %eax,%edx
 724:	8b 45 fc             	mov    -0x4(%ebp),%eax
 727:	8b 00                	mov    (%eax),%eax
 729:	39 c2                	cmp    %eax,%edx
 72b:	75 24                	jne    751 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 72d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 730:	8b 50 04             	mov    0x4(%eax),%edx
 733:	8b 45 fc             	mov    -0x4(%ebp),%eax
 736:	8b 00                	mov    (%eax),%eax
 738:	8b 40 04             	mov    0x4(%eax),%eax
 73b:	01 c2                	add    %eax,%edx
 73d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 740:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 743:	8b 45 fc             	mov    -0x4(%ebp),%eax
 746:	8b 00                	mov    (%eax),%eax
 748:	8b 10                	mov    (%eax),%edx
 74a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74d:	89 10                	mov    %edx,(%eax)
 74f:	eb 0a                	jmp    75b <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 751:	8b 45 fc             	mov    -0x4(%ebp),%eax
 754:	8b 10                	mov    (%eax),%edx
 756:	8b 45 f8             	mov    -0x8(%ebp),%eax
 759:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 75b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75e:	8b 40 04             	mov    0x4(%eax),%eax
 761:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 768:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76b:	01 d0                	add    %edx,%eax
 76d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 770:	75 20                	jne    792 <free+0xcf>
    p->s.size += bp->s.size;
 772:	8b 45 fc             	mov    -0x4(%ebp),%eax
 775:	8b 50 04             	mov    0x4(%eax),%edx
 778:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77b:	8b 40 04             	mov    0x4(%eax),%eax
 77e:	01 c2                	add    %eax,%edx
 780:	8b 45 fc             	mov    -0x4(%ebp),%eax
 783:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 786:	8b 45 f8             	mov    -0x8(%ebp),%eax
 789:	8b 10                	mov    (%eax),%edx
 78b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78e:	89 10                	mov    %edx,(%eax)
 790:	eb 08                	jmp    79a <free+0xd7>
  } else
    p->s.ptr = bp;
 792:	8b 45 fc             	mov    -0x4(%ebp),%eax
 795:	8b 55 f8             	mov    -0x8(%ebp),%edx
 798:	89 10                	mov    %edx,(%eax)
  freep = p;
 79a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79d:	a3 80 09 00 00       	mov    %eax,0x980
}
 7a2:	90                   	nop
 7a3:	c9                   	leave
 7a4:	c3                   	ret

000007a5 <morecore>:

static Header*
morecore(uint nu)
{
 7a5:	55                   	push   %ebp
 7a6:	89 e5                	mov    %esp,%ebp
 7a8:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7ab:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7b2:	77 07                	ja     7bb <morecore+0x16>
    nu = 4096;
 7b4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7bb:	8b 45 08             	mov    0x8(%ebp),%eax
 7be:	c1 e0 03             	shl    $0x3,%eax
 7c1:	83 ec 0c             	sub    $0xc,%esp
 7c4:	50                   	push   %eax
 7c5:	e8 5b fc ff ff       	call   425 <sbrk>
 7ca:	83 c4 10             	add    $0x10,%esp
 7cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7d0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7d4:	75 07                	jne    7dd <morecore+0x38>
    return 0;
 7d6:	b8 00 00 00 00       	mov    $0x0,%eax
 7db:	eb 26                	jmp    803 <morecore+0x5e>
  hp = (Header*)p;
 7dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e6:	8b 55 08             	mov    0x8(%ebp),%edx
 7e9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ef:	83 c0 08             	add    $0x8,%eax
 7f2:	83 ec 0c             	sub    $0xc,%esp
 7f5:	50                   	push   %eax
 7f6:	e8 c8 fe ff ff       	call   6c3 <free>
 7fb:	83 c4 10             	add    $0x10,%esp
  return freep;
 7fe:	a1 80 09 00 00       	mov    0x980,%eax
}
 803:	c9                   	leave
 804:	c3                   	ret

00000805 <malloc>:

void*
malloc(uint nbytes)
{
 805:	55                   	push   %ebp
 806:	89 e5                	mov    %esp,%ebp
 808:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 80b:	8b 45 08             	mov    0x8(%ebp),%eax
 80e:	83 c0 07             	add    $0x7,%eax
 811:	c1 e8 03             	shr    $0x3,%eax
 814:	83 c0 01             	add    $0x1,%eax
 817:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 81a:	a1 80 09 00 00       	mov    0x980,%eax
 81f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 822:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 826:	75 23                	jne    84b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 828:	c7 45 f0 78 09 00 00 	movl   $0x978,-0x10(%ebp)
 82f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 832:	a3 80 09 00 00       	mov    %eax,0x980
 837:	a1 80 09 00 00       	mov    0x980,%eax
 83c:	a3 78 09 00 00       	mov    %eax,0x978
    base.s.size = 0;
 841:	c7 05 7c 09 00 00 00 	movl   $0x0,0x97c
 848:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84e:	8b 00                	mov    (%eax),%eax
 850:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 853:	8b 45 f4             	mov    -0xc(%ebp),%eax
 856:	8b 40 04             	mov    0x4(%eax),%eax
 859:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 85c:	72 4d                	jb     8ab <malloc+0xa6>
      if(p->s.size == nunits)
 85e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 861:	8b 40 04             	mov    0x4(%eax),%eax
 864:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 867:	75 0c                	jne    875 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 869:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86c:	8b 10                	mov    (%eax),%edx
 86e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 871:	89 10                	mov    %edx,(%eax)
 873:	eb 26                	jmp    89b <malloc+0x96>
      else {
        p->s.size -= nunits;
 875:	8b 45 f4             	mov    -0xc(%ebp),%eax
 878:	8b 40 04             	mov    0x4(%eax),%eax
 87b:	2b 45 ec             	sub    -0x14(%ebp),%eax
 87e:	89 c2                	mov    %eax,%edx
 880:	8b 45 f4             	mov    -0xc(%ebp),%eax
 883:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 886:	8b 45 f4             	mov    -0xc(%ebp),%eax
 889:	8b 40 04             	mov    0x4(%eax),%eax
 88c:	c1 e0 03             	shl    $0x3,%eax
 88f:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 892:	8b 45 f4             	mov    -0xc(%ebp),%eax
 895:	8b 55 ec             	mov    -0x14(%ebp),%edx
 898:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 89b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 89e:	a3 80 09 00 00       	mov    %eax,0x980
      return (void*)(p + 1);
 8a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a6:	83 c0 08             	add    $0x8,%eax
 8a9:	eb 3b                	jmp    8e6 <malloc+0xe1>
    }
    if(p == freep)
 8ab:	a1 80 09 00 00       	mov    0x980,%eax
 8b0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8b3:	75 1e                	jne    8d3 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 8b5:	83 ec 0c             	sub    $0xc,%esp
 8b8:	ff 75 ec             	push   -0x14(%ebp)
 8bb:	e8 e5 fe ff ff       	call   7a5 <morecore>
 8c0:	83 c4 10             	add    $0x10,%esp
 8c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8ca:	75 07                	jne    8d3 <malloc+0xce>
        return 0;
 8cc:	b8 00 00 00 00       	mov    $0x0,%eax
 8d1:	eb 13                	jmp    8e6 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8dc:	8b 00                	mov    (%eax),%eax
 8de:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8e1:	e9 6d ff ff ff       	jmp    853 <malloc+0x4e>
  }
}
 8e6:	c9                   	leave
 8e7:	c3                   	ret
