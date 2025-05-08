
_getpinfo_test:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"
#include "pstat.h"

int main(void) {
   0:	f3 0f 1e fb          	endbr32
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	push   -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	51                   	push   %ecx
  12:	81 ec 14 0c 00 00    	sub    $0xc14,%esp
  struct pstat ps;

  // 시스템 콜 호출
  if (getpinfo(&ps) < 0) {
  18:	83 ec 0c             	sub    $0xc,%esp
  1b:	8d 85 f0 f3 ff ff    	lea    -0xc10(%ebp),%eax
  21:	50                   	push   %eax
  22:	e8 3e 04 00 00       	call   465 <getpinfo>
  27:	83 c4 10             	add    $0x10,%esp
  2a:	85 c0                	test   %eax,%eax
  2c:	79 17                	jns    45 <main+0x45>
    printf(1, "getpinfo failed\n");
  2e:	83 ec 08             	sub    $0x8,%esp
  31:	68 28 09 00 00       	push   $0x928
  36:	6a 01                	push   $0x1
  38:	e8 24 05 00 00       	call   561 <printf>
  3d:	83 c4 10             	add    $0x10,%esp
    exit();
  40:	e8 80 03 00 00       	call   3c5 <exit>
  }

  // 모든 프로세스 출력
  for (int i = 0; i < NPROC; i++) {
  45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  4c:	e9 ea 00 00 00       	jmp    13b <main+0x13b>
    if (ps.inuse[i]) {
  51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  54:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
  5b:	85 c0                	test   %eax,%eax
  5d:	0f 84 d4 00 00 00    	je     137 <main+0x137>
      printf(1, "---------------------------------\n");
  63:	83 ec 08             	sub    $0x8,%esp
  66:	68 3c 09 00 00       	push   $0x93c
  6b:	6a 01                	push   $0x1
  6d:	e8 ef 04 00 00       	call   561 <printf>
  72:	83 c4 10             	add    $0x10,%esp
      printf(1, "PID: %d\n", ps.pid[i]);
  75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  78:	83 c0 40             	add    $0x40,%eax
  7b:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
  82:	83 ec 04             	sub    $0x4,%esp
  85:	50                   	push   %eax
  86:	68 5f 09 00 00       	push   $0x95f
  8b:	6a 01                	push   $0x1
  8d:	e8 cf 04 00 00       	call   561 <printf>
  92:	83 c4 10             	add    $0x10,%esp
      printf(1, "State: %d\n", ps.state[i]);       // enum procstate
  95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  98:	05 c0 00 00 00       	add    $0xc0,%eax
  9d:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
  a4:	83 ec 04             	sub    $0x4,%esp
  a7:	50                   	push   %eax
  a8:	68 68 09 00 00       	push   $0x968
  ad:	6a 01                	push   $0x1
  af:	e8 ad 04 00 00       	call   561 <printf>
  b4:	83 c4 10             	add    $0x10,%esp
      printf(1, "Priority: %d\n", ps.priority[i]);
  b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  ba:	83 e8 80             	sub    $0xffffff80,%eax
  bd:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
  c4:	83 ec 04             	sub    $0x4,%esp
  c7:	50                   	push   %eax
  c8:	68 73 09 00 00       	push   $0x973
  cd:	6a 01                	push   $0x1
  cf:	e8 8d 04 00 00       	call   561 <printf>
  d4:	83 c4 10             	add    $0x10,%esp
      for (int q = 0; q < 4; q++) {
  d7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  de:	eb 51                	jmp    131 <main+0x131>
        printf(1, "  Q%d: ticks=%d, wait=%d\n", q,
  e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  e3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  ed:	01 d0                	add    %edx,%eax
  ef:	05 00 02 00 00       	add    $0x200,%eax
  f4:	8b 94 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%edx
  fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  fe:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
 105:	8b 45 f0             	mov    -0x10(%ebp),%eax
 108:	01 c8                	add    %ecx,%eax
 10a:	05 00 01 00 00       	add    $0x100,%eax
 10f:	8b 84 85 f0 f3 ff ff 	mov    -0xc10(%ebp,%eax,4),%eax
 116:	83 ec 0c             	sub    $0xc,%esp
 119:	52                   	push   %edx
 11a:	50                   	push   %eax
 11b:	ff 75 f0             	push   -0x10(%ebp)
 11e:	68 81 09 00 00       	push   $0x981
 123:	6a 01                	push   $0x1
 125:	e8 37 04 00 00       	call   561 <printf>
 12a:	83 c4 20             	add    $0x20,%esp
      for (int q = 0; q < 4; q++) {
 12d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 131:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
 135:	7e a9                	jle    e0 <main+0xe0>
  for (int i = 0; i < NPROC; i++) {
 137:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 13b:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
 13f:	0f 8e 0c ff ff ff    	jle    51 <main+0x51>
               ps.ticks[i][q], ps.wait_ticks[i][q]);
      }
    }
  }

  exit();
 145:	e8 7b 02 00 00       	call   3c5 <exit>

0000014a <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 14a:	55                   	push   %ebp
 14b:	89 e5                	mov    %esp,%ebp
 14d:	57                   	push   %edi
 14e:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 14f:	8b 4d 08             	mov    0x8(%ebp),%ecx
 152:	8b 55 10             	mov    0x10(%ebp),%edx
 155:	8b 45 0c             	mov    0xc(%ebp),%eax
 158:	89 cb                	mov    %ecx,%ebx
 15a:	89 df                	mov    %ebx,%edi
 15c:	89 d1                	mov    %edx,%ecx
 15e:	fc                   	cld
 15f:	f3 aa                	rep stos %al,%es:(%edi)
 161:	89 ca                	mov    %ecx,%edx
 163:	89 fb                	mov    %edi,%ebx
 165:	89 5d 08             	mov    %ebx,0x8(%ebp)
 168:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 16b:	90                   	nop
 16c:	5b                   	pop    %ebx
 16d:	5f                   	pop    %edi
 16e:	5d                   	pop    %ebp
 16f:	c3                   	ret

00000170 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 170:	f3 0f 1e fb          	endbr32
 174:	55                   	push   %ebp
 175:	89 e5                	mov    %esp,%ebp
 177:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 17a:	8b 45 08             	mov    0x8(%ebp),%eax
 17d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 180:	90                   	nop
 181:	8b 55 0c             	mov    0xc(%ebp),%edx
 184:	8d 42 01             	lea    0x1(%edx),%eax
 187:	89 45 0c             	mov    %eax,0xc(%ebp)
 18a:	8b 45 08             	mov    0x8(%ebp),%eax
 18d:	8d 48 01             	lea    0x1(%eax),%ecx
 190:	89 4d 08             	mov    %ecx,0x8(%ebp)
 193:	0f b6 12             	movzbl (%edx),%edx
 196:	88 10                	mov    %dl,(%eax)
 198:	0f b6 00             	movzbl (%eax),%eax
 19b:	84 c0                	test   %al,%al
 19d:	75 e2                	jne    181 <strcpy+0x11>
    ;
  return os;
 19f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1a2:	c9                   	leave
 1a3:	c3                   	ret

000001a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a4:	f3 0f 1e fb          	endbr32
 1a8:	55                   	push   %ebp
 1a9:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1ab:	eb 08                	jmp    1b5 <strcmp+0x11>
    p++, q++;
 1ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1b1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 1b5:	8b 45 08             	mov    0x8(%ebp),%eax
 1b8:	0f b6 00             	movzbl (%eax),%eax
 1bb:	84 c0                	test   %al,%al
 1bd:	74 10                	je     1cf <strcmp+0x2b>
 1bf:	8b 45 08             	mov    0x8(%ebp),%eax
 1c2:	0f b6 10             	movzbl (%eax),%edx
 1c5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c8:	0f b6 00             	movzbl (%eax),%eax
 1cb:	38 c2                	cmp    %al,%dl
 1cd:	74 de                	je     1ad <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 1cf:	8b 45 08             	mov    0x8(%ebp),%eax
 1d2:	0f b6 00             	movzbl (%eax),%eax
 1d5:	0f b6 d0             	movzbl %al,%edx
 1d8:	8b 45 0c             	mov    0xc(%ebp),%eax
 1db:	0f b6 00             	movzbl (%eax),%eax
 1de:	0f b6 c0             	movzbl %al,%eax
 1e1:	29 c2                	sub    %eax,%edx
 1e3:	89 d0                	mov    %edx,%eax
}
 1e5:	5d                   	pop    %ebp
 1e6:	c3                   	ret

000001e7 <strlen>:

uint
strlen(char *s)
{
 1e7:	f3 0f 1e fb          	endbr32
 1eb:	55                   	push   %ebp
 1ec:	89 e5                	mov    %esp,%ebp
 1ee:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1f8:	eb 04                	jmp    1fe <strlen+0x17>
 1fa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
 201:	8b 45 08             	mov    0x8(%ebp),%eax
 204:	01 d0                	add    %edx,%eax
 206:	0f b6 00             	movzbl (%eax),%eax
 209:	84 c0                	test   %al,%al
 20b:	75 ed                	jne    1fa <strlen+0x13>
    ;
  return n;
 20d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 210:	c9                   	leave
 211:	c3                   	ret

00000212 <memset>:

void*
memset(void *dst, int c, uint n)
{
 212:	f3 0f 1e fb          	endbr32
 216:	55                   	push   %ebp
 217:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 219:	8b 45 10             	mov    0x10(%ebp),%eax
 21c:	50                   	push   %eax
 21d:	ff 75 0c             	push   0xc(%ebp)
 220:	ff 75 08             	push   0x8(%ebp)
 223:	e8 22 ff ff ff       	call   14a <stosb>
 228:	83 c4 0c             	add    $0xc,%esp
  return dst;
 22b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 22e:	c9                   	leave
 22f:	c3                   	ret

00000230 <strchr>:

char*
strchr(const char *s, char c)
{
 230:	f3 0f 1e fb          	endbr32
 234:	55                   	push   %ebp
 235:	89 e5                	mov    %esp,%ebp
 237:	83 ec 04             	sub    $0x4,%esp
 23a:	8b 45 0c             	mov    0xc(%ebp),%eax
 23d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 240:	eb 14                	jmp    256 <strchr+0x26>
    if(*s == c)
 242:	8b 45 08             	mov    0x8(%ebp),%eax
 245:	0f b6 00             	movzbl (%eax),%eax
 248:	38 45 fc             	cmp    %al,-0x4(%ebp)
 24b:	75 05                	jne    252 <strchr+0x22>
      return (char*)s;
 24d:	8b 45 08             	mov    0x8(%ebp),%eax
 250:	eb 13                	jmp    265 <strchr+0x35>
  for(; *s; s++)
 252:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 256:	8b 45 08             	mov    0x8(%ebp),%eax
 259:	0f b6 00             	movzbl (%eax),%eax
 25c:	84 c0                	test   %al,%al
 25e:	75 e2                	jne    242 <strchr+0x12>
  return 0;
 260:	b8 00 00 00 00       	mov    $0x0,%eax
}
 265:	c9                   	leave
 266:	c3                   	ret

00000267 <gets>:

char*
gets(char *buf, int max)
{
 267:	f3 0f 1e fb          	endbr32
 26b:	55                   	push   %ebp
 26c:	89 e5                	mov    %esp,%ebp
 26e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 271:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 278:	eb 42                	jmp    2bc <gets+0x55>
    cc = read(0, &c, 1);
 27a:	83 ec 04             	sub    $0x4,%esp
 27d:	6a 01                	push   $0x1
 27f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 282:	50                   	push   %eax
 283:	6a 00                	push   $0x0
 285:	e8 53 01 00 00       	call   3dd <read>
 28a:	83 c4 10             	add    $0x10,%esp
 28d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 290:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 294:	7e 33                	jle    2c9 <gets+0x62>
      break;
    buf[i++] = c;
 296:	8b 45 f4             	mov    -0xc(%ebp),%eax
 299:	8d 50 01             	lea    0x1(%eax),%edx
 29c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 29f:	89 c2                	mov    %eax,%edx
 2a1:	8b 45 08             	mov    0x8(%ebp),%eax
 2a4:	01 c2                	add    %eax,%edx
 2a6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2aa:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2ac:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2b0:	3c 0a                	cmp    $0xa,%al
 2b2:	74 16                	je     2ca <gets+0x63>
 2b4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2b8:	3c 0d                	cmp    $0xd,%al
 2ba:	74 0e                	je     2ca <gets+0x63>
  for(i=0; i+1 < max; ){
 2bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2bf:	83 c0 01             	add    $0x1,%eax
 2c2:	39 45 0c             	cmp    %eax,0xc(%ebp)
 2c5:	7f b3                	jg     27a <gets+0x13>
 2c7:	eb 01                	jmp    2ca <gets+0x63>
      break;
 2c9:	90                   	nop
      break;
  }
  buf[i] = '\0';
 2ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2cd:	8b 45 08             	mov    0x8(%ebp),%eax
 2d0:	01 d0                	add    %edx,%eax
 2d2:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2d5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2d8:	c9                   	leave
 2d9:	c3                   	ret

000002da <stat>:

int
stat(char *n, struct stat *st)
{
 2da:	f3 0f 1e fb          	endbr32
 2de:	55                   	push   %ebp
 2df:	89 e5                	mov    %esp,%ebp
 2e1:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2e4:	83 ec 08             	sub    $0x8,%esp
 2e7:	6a 00                	push   $0x0
 2e9:	ff 75 08             	push   0x8(%ebp)
 2ec:	e8 14 01 00 00       	call   405 <open>
 2f1:	83 c4 10             	add    $0x10,%esp
 2f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2fb:	79 07                	jns    304 <stat+0x2a>
    return -1;
 2fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 302:	eb 25                	jmp    329 <stat+0x4f>
  r = fstat(fd, st);
 304:	83 ec 08             	sub    $0x8,%esp
 307:	ff 75 0c             	push   0xc(%ebp)
 30a:	ff 75 f4             	push   -0xc(%ebp)
 30d:	e8 0b 01 00 00       	call   41d <fstat>
 312:	83 c4 10             	add    $0x10,%esp
 315:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 318:	83 ec 0c             	sub    $0xc,%esp
 31b:	ff 75 f4             	push   -0xc(%ebp)
 31e:	e8 ca 00 00 00       	call   3ed <close>
 323:	83 c4 10             	add    $0x10,%esp
  return r;
 326:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 329:	c9                   	leave
 32a:	c3                   	ret

0000032b <atoi>:

int
atoi(const char *s)
{
 32b:	f3 0f 1e fb          	endbr32
 32f:	55                   	push   %ebp
 330:	89 e5                	mov    %esp,%ebp
 332:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 335:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 33c:	eb 25                	jmp    363 <atoi+0x38>
    n = n*10 + *s++ - '0';
 33e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 341:	89 d0                	mov    %edx,%eax
 343:	c1 e0 02             	shl    $0x2,%eax
 346:	01 d0                	add    %edx,%eax
 348:	01 c0                	add    %eax,%eax
 34a:	89 c1                	mov    %eax,%ecx
 34c:	8b 45 08             	mov    0x8(%ebp),%eax
 34f:	8d 50 01             	lea    0x1(%eax),%edx
 352:	89 55 08             	mov    %edx,0x8(%ebp)
 355:	0f b6 00             	movzbl (%eax),%eax
 358:	0f be c0             	movsbl %al,%eax
 35b:	01 c8                	add    %ecx,%eax
 35d:	83 e8 30             	sub    $0x30,%eax
 360:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 363:	8b 45 08             	mov    0x8(%ebp),%eax
 366:	0f b6 00             	movzbl (%eax),%eax
 369:	3c 2f                	cmp    $0x2f,%al
 36b:	7e 0a                	jle    377 <atoi+0x4c>
 36d:	8b 45 08             	mov    0x8(%ebp),%eax
 370:	0f b6 00             	movzbl (%eax),%eax
 373:	3c 39                	cmp    $0x39,%al
 375:	7e c7                	jle    33e <atoi+0x13>
  return n;
 377:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 37a:	c9                   	leave
 37b:	c3                   	ret

0000037c <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 37c:	f3 0f 1e fb          	endbr32
 380:	55                   	push   %ebp
 381:	89 e5                	mov    %esp,%ebp
 383:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 386:	8b 45 08             	mov    0x8(%ebp),%eax
 389:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 38c:	8b 45 0c             	mov    0xc(%ebp),%eax
 38f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 392:	eb 17                	jmp    3ab <memmove+0x2f>
    *dst++ = *src++;
 394:	8b 55 f8             	mov    -0x8(%ebp),%edx
 397:	8d 42 01             	lea    0x1(%edx),%eax
 39a:	89 45 f8             	mov    %eax,-0x8(%ebp)
 39d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3a0:	8d 48 01             	lea    0x1(%eax),%ecx
 3a3:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 3a6:	0f b6 12             	movzbl (%edx),%edx
 3a9:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 3ab:	8b 45 10             	mov    0x10(%ebp),%eax
 3ae:	8d 50 ff             	lea    -0x1(%eax),%edx
 3b1:	89 55 10             	mov    %edx,0x10(%ebp)
 3b4:	85 c0                	test   %eax,%eax
 3b6:	7f dc                	jg     394 <memmove+0x18>
  return vdst;
 3b8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3bb:	c9                   	leave
 3bc:	c3                   	ret

000003bd <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3bd:	b8 01 00 00 00       	mov    $0x1,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret

000003c5 <exit>:
SYSCALL(exit)
 3c5:	b8 02 00 00 00       	mov    $0x2,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret

000003cd <wait>:
SYSCALL(wait)
 3cd:	b8 03 00 00 00       	mov    $0x3,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret

000003d5 <pipe>:
SYSCALL(pipe)
 3d5:	b8 04 00 00 00       	mov    $0x4,%eax
 3da:	cd 40                	int    $0x40
 3dc:	c3                   	ret

000003dd <read>:
SYSCALL(read)
 3dd:	b8 05 00 00 00       	mov    $0x5,%eax
 3e2:	cd 40                	int    $0x40
 3e4:	c3                   	ret

000003e5 <write>:
SYSCALL(write)
 3e5:	b8 10 00 00 00       	mov    $0x10,%eax
 3ea:	cd 40                	int    $0x40
 3ec:	c3                   	ret

000003ed <close>:
SYSCALL(close)
 3ed:	b8 15 00 00 00       	mov    $0x15,%eax
 3f2:	cd 40                	int    $0x40
 3f4:	c3                   	ret

000003f5 <kill>:
SYSCALL(kill)
 3f5:	b8 06 00 00 00       	mov    $0x6,%eax
 3fa:	cd 40                	int    $0x40
 3fc:	c3                   	ret

000003fd <exec>:
SYSCALL(exec)
 3fd:	b8 07 00 00 00       	mov    $0x7,%eax
 402:	cd 40                	int    $0x40
 404:	c3                   	ret

00000405 <open>:
SYSCALL(open)
 405:	b8 0f 00 00 00       	mov    $0xf,%eax
 40a:	cd 40                	int    $0x40
 40c:	c3                   	ret

0000040d <mknod>:
SYSCALL(mknod)
 40d:	b8 11 00 00 00       	mov    $0x11,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret

00000415 <unlink>:
SYSCALL(unlink)
 415:	b8 12 00 00 00       	mov    $0x12,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret

0000041d <fstat>:
SYSCALL(fstat)
 41d:	b8 08 00 00 00       	mov    $0x8,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret

00000425 <link>:
SYSCALL(link)
 425:	b8 13 00 00 00       	mov    $0x13,%eax
 42a:	cd 40                	int    $0x40
 42c:	c3                   	ret

0000042d <mkdir>:
SYSCALL(mkdir)
 42d:	b8 14 00 00 00       	mov    $0x14,%eax
 432:	cd 40                	int    $0x40
 434:	c3                   	ret

00000435 <chdir>:
SYSCALL(chdir)
 435:	b8 09 00 00 00       	mov    $0x9,%eax
 43a:	cd 40                	int    $0x40
 43c:	c3                   	ret

0000043d <dup>:
SYSCALL(dup)
 43d:	b8 0a 00 00 00       	mov    $0xa,%eax
 442:	cd 40                	int    $0x40
 444:	c3                   	ret

00000445 <getpid>:
SYSCALL(getpid)
 445:	b8 0b 00 00 00       	mov    $0xb,%eax
 44a:	cd 40                	int    $0x40
 44c:	c3                   	ret

0000044d <sbrk>:
SYSCALL(sbrk)
 44d:	b8 0c 00 00 00       	mov    $0xc,%eax
 452:	cd 40                	int    $0x40
 454:	c3                   	ret

00000455 <sleep>:
SYSCALL(sleep)
 455:	b8 0d 00 00 00       	mov    $0xd,%eax
 45a:	cd 40                	int    $0x40
 45c:	c3                   	ret

0000045d <uptime>:
SYSCALL(uptime)
 45d:	b8 0e 00 00 00       	mov    $0xe,%eax
 462:	cd 40                	int    $0x40
 464:	c3                   	ret

00000465 <getpinfo>:

SYSCALL(getpinfo)
 465:	b8 16 00 00 00       	mov    $0x16,%eax
 46a:	cd 40                	int    $0x40
 46c:	c3                   	ret

0000046d <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 46d:	b8 17 00 00 00       	mov    $0x17,%eax
 472:	cd 40                	int    $0x40
 474:	c3                   	ret

00000475 <yield>:
SYSCALL(yield)
 475:	b8 18 00 00 00       	mov    $0x18,%eax
 47a:	cd 40                	int    $0x40
 47c:	c3                   	ret

0000047d <getSchedPolicy>:
 47d:	b8 19 00 00 00       	mov    $0x19,%eax
 482:	cd 40                	int    $0x40
 484:	c3                   	ret

00000485 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 485:	f3 0f 1e fb          	endbr32
 489:	55                   	push   %ebp
 48a:	89 e5                	mov    %esp,%ebp
 48c:	83 ec 18             	sub    $0x18,%esp
 48f:	8b 45 0c             	mov    0xc(%ebp),%eax
 492:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 495:	83 ec 04             	sub    $0x4,%esp
 498:	6a 01                	push   $0x1
 49a:	8d 45 f4             	lea    -0xc(%ebp),%eax
 49d:	50                   	push   %eax
 49e:	ff 75 08             	push   0x8(%ebp)
 4a1:	e8 3f ff ff ff       	call   3e5 <write>
 4a6:	83 c4 10             	add    $0x10,%esp
}
 4a9:	90                   	nop
 4aa:	c9                   	leave
 4ab:	c3                   	ret

000004ac <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4ac:	f3 0f 1e fb          	endbr32
 4b0:	55                   	push   %ebp
 4b1:	89 e5                	mov    %esp,%ebp
 4b3:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4b6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4bd:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4c1:	74 17                	je     4da <printint+0x2e>
 4c3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4c7:	79 11                	jns    4da <printint+0x2e>
    neg = 1;
 4c9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4d0:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d3:	f7 d8                	neg    %eax
 4d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4d8:	eb 06                	jmp    4e0 <printint+0x34>
  } else {
    x = xx;
 4da:	8b 45 0c             	mov    0xc(%ebp),%eax
 4dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4ed:	ba 00 00 00 00       	mov    $0x0,%edx
 4f2:	f7 f1                	div    %ecx
 4f4:	89 d1                	mov    %edx,%ecx
 4f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f9:	8d 50 01             	lea    0x1(%eax),%edx
 4fc:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4ff:	0f b6 91 e8 0b 00 00 	movzbl 0xbe8(%ecx),%edx
 506:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 50a:	8b 4d 10             	mov    0x10(%ebp),%ecx
 50d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 510:	ba 00 00 00 00       	mov    $0x0,%edx
 515:	f7 f1                	div    %ecx
 517:	89 45 ec             	mov    %eax,-0x14(%ebp)
 51a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 51e:	75 c7                	jne    4e7 <printint+0x3b>
  if(neg)
 520:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 524:	74 2d                	je     553 <printint+0xa7>
    buf[i++] = '-';
 526:	8b 45 f4             	mov    -0xc(%ebp),%eax
 529:	8d 50 01             	lea    0x1(%eax),%edx
 52c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 52f:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 534:	eb 1d                	jmp    553 <printint+0xa7>
    putc(fd, buf[i]);
 536:	8d 55 dc             	lea    -0x24(%ebp),%edx
 539:	8b 45 f4             	mov    -0xc(%ebp),%eax
 53c:	01 d0                	add    %edx,%eax
 53e:	0f b6 00             	movzbl (%eax),%eax
 541:	0f be c0             	movsbl %al,%eax
 544:	83 ec 08             	sub    $0x8,%esp
 547:	50                   	push   %eax
 548:	ff 75 08             	push   0x8(%ebp)
 54b:	e8 35 ff ff ff       	call   485 <putc>
 550:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 553:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 557:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 55b:	79 d9                	jns    536 <printint+0x8a>
}
 55d:	90                   	nop
 55e:	90                   	nop
 55f:	c9                   	leave
 560:	c3                   	ret

00000561 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 561:	f3 0f 1e fb          	endbr32
 565:	55                   	push   %ebp
 566:	89 e5                	mov    %esp,%ebp
 568:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 56b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 572:	8d 45 0c             	lea    0xc(%ebp),%eax
 575:	83 c0 04             	add    $0x4,%eax
 578:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 57b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 582:	e9 59 01 00 00       	jmp    6e0 <printf+0x17f>
    c = fmt[i] & 0xff;
 587:	8b 55 0c             	mov    0xc(%ebp),%edx
 58a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 58d:	01 d0                	add    %edx,%eax
 58f:	0f b6 00             	movzbl (%eax),%eax
 592:	0f be c0             	movsbl %al,%eax
 595:	25 ff 00 00 00       	and    $0xff,%eax
 59a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 59d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5a1:	75 2c                	jne    5cf <printf+0x6e>
      if(c == '%'){
 5a3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5a7:	75 0c                	jne    5b5 <printf+0x54>
        state = '%';
 5a9:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5b0:	e9 27 01 00 00       	jmp    6dc <printf+0x17b>
      } else {
        putc(fd, c);
 5b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5b8:	0f be c0             	movsbl %al,%eax
 5bb:	83 ec 08             	sub    $0x8,%esp
 5be:	50                   	push   %eax
 5bf:	ff 75 08             	push   0x8(%ebp)
 5c2:	e8 be fe ff ff       	call   485 <putc>
 5c7:	83 c4 10             	add    $0x10,%esp
 5ca:	e9 0d 01 00 00       	jmp    6dc <printf+0x17b>
      }
    } else if(state == '%'){
 5cf:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5d3:	0f 85 03 01 00 00    	jne    6dc <printf+0x17b>
      if(c == 'd'){
 5d9:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5dd:	75 1e                	jne    5fd <printf+0x9c>
        printint(fd, *ap, 10, 1);
 5df:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5e2:	8b 00                	mov    (%eax),%eax
 5e4:	6a 01                	push   $0x1
 5e6:	6a 0a                	push   $0xa
 5e8:	50                   	push   %eax
 5e9:	ff 75 08             	push   0x8(%ebp)
 5ec:	e8 bb fe ff ff       	call   4ac <printint>
 5f1:	83 c4 10             	add    $0x10,%esp
        ap++;
 5f4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5f8:	e9 d8 00 00 00       	jmp    6d5 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 5fd:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 601:	74 06                	je     609 <printf+0xa8>
 603:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 607:	75 1e                	jne    627 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 609:	8b 45 e8             	mov    -0x18(%ebp),%eax
 60c:	8b 00                	mov    (%eax),%eax
 60e:	6a 00                	push   $0x0
 610:	6a 10                	push   $0x10
 612:	50                   	push   %eax
 613:	ff 75 08             	push   0x8(%ebp)
 616:	e8 91 fe ff ff       	call   4ac <printint>
 61b:	83 c4 10             	add    $0x10,%esp
        ap++;
 61e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 622:	e9 ae 00 00 00       	jmp    6d5 <printf+0x174>
      } else if(c == 's'){
 627:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 62b:	75 43                	jne    670 <printf+0x10f>
        s = (char*)*ap;
 62d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 630:	8b 00                	mov    (%eax),%eax
 632:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 635:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 639:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 63d:	75 25                	jne    664 <printf+0x103>
          s = "(null)";
 63f:	c7 45 f4 9b 09 00 00 	movl   $0x99b,-0xc(%ebp)
        while(*s != 0){
 646:	eb 1c                	jmp    664 <printf+0x103>
          putc(fd, *s);
 648:	8b 45 f4             	mov    -0xc(%ebp),%eax
 64b:	0f b6 00             	movzbl (%eax),%eax
 64e:	0f be c0             	movsbl %al,%eax
 651:	83 ec 08             	sub    $0x8,%esp
 654:	50                   	push   %eax
 655:	ff 75 08             	push   0x8(%ebp)
 658:	e8 28 fe ff ff       	call   485 <putc>
 65d:	83 c4 10             	add    $0x10,%esp
          s++;
 660:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 664:	8b 45 f4             	mov    -0xc(%ebp),%eax
 667:	0f b6 00             	movzbl (%eax),%eax
 66a:	84 c0                	test   %al,%al
 66c:	75 da                	jne    648 <printf+0xe7>
 66e:	eb 65                	jmp    6d5 <printf+0x174>
        }
      } else if(c == 'c'){
 670:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 674:	75 1d                	jne    693 <printf+0x132>
        putc(fd, *ap);
 676:	8b 45 e8             	mov    -0x18(%ebp),%eax
 679:	8b 00                	mov    (%eax),%eax
 67b:	0f be c0             	movsbl %al,%eax
 67e:	83 ec 08             	sub    $0x8,%esp
 681:	50                   	push   %eax
 682:	ff 75 08             	push   0x8(%ebp)
 685:	e8 fb fd ff ff       	call   485 <putc>
 68a:	83 c4 10             	add    $0x10,%esp
        ap++;
 68d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 691:	eb 42                	jmp    6d5 <printf+0x174>
      } else if(c == '%'){
 693:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 697:	75 17                	jne    6b0 <printf+0x14f>
        putc(fd, c);
 699:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 69c:	0f be c0             	movsbl %al,%eax
 69f:	83 ec 08             	sub    $0x8,%esp
 6a2:	50                   	push   %eax
 6a3:	ff 75 08             	push   0x8(%ebp)
 6a6:	e8 da fd ff ff       	call   485 <putc>
 6ab:	83 c4 10             	add    $0x10,%esp
 6ae:	eb 25                	jmp    6d5 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6b0:	83 ec 08             	sub    $0x8,%esp
 6b3:	6a 25                	push   $0x25
 6b5:	ff 75 08             	push   0x8(%ebp)
 6b8:	e8 c8 fd ff ff       	call   485 <putc>
 6bd:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 6c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6c3:	0f be c0             	movsbl %al,%eax
 6c6:	83 ec 08             	sub    $0x8,%esp
 6c9:	50                   	push   %eax
 6ca:	ff 75 08             	push   0x8(%ebp)
 6cd:	e8 b3 fd ff ff       	call   485 <putc>
 6d2:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 6d5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 6dc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6e0:	8b 55 0c             	mov    0xc(%ebp),%edx
 6e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6e6:	01 d0                	add    %edx,%eax
 6e8:	0f b6 00             	movzbl (%eax),%eax
 6eb:	84 c0                	test   %al,%al
 6ed:	0f 85 94 fe ff ff    	jne    587 <printf+0x26>
    }
  }
}
 6f3:	90                   	nop
 6f4:	90                   	nop
 6f5:	c9                   	leave
 6f6:	c3                   	ret

000006f7 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6f7:	f3 0f 1e fb          	endbr32
 6fb:	55                   	push   %ebp
 6fc:	89 e5                	mov    %esp,%ebp
 6fe:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 701:	8b 45 08             	mov    0x8(%ebp),%eax
 704:	83 e8 08             	sub    $0x8,%eax
 707:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 70a:	a1 04 0c 00 00       	mov    0xc04,%eax
 70f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 712:	eb 24                	jmp    738 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 714:	8b 45 fc             	mov    -0x4(%ebp),%eax
 717:	8b 00                	mov    (%eax),%eax
 719:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 71c:	72 12                	jb     730 <free+0x39>
 71e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 721:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 724:	77 24                	ja     74a <free+0x53>
 726:	8b 45 fc             	mov    -0x4(%ebp),%eax
 729:	8b 00                	mov    (%eax),%eax
 72b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 72e:	72 1a                	jb     74a <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 730:	8b 45 fc             	mov    -0x4(%ebp),%eax
 733:	8b 00                	mov    (%eax),%eax
 735:	89 45 fc             	mov    %eax,-0x4(%ebp)
 738:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 73e:	76 d4                	jbe    714 <free+0x1d>
 740:	8b 45 fc             	mov    -0x4(%ebp),%eax
 743:	8b 00                	mov    (%eax),%eax
 745:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 748:	73 ca                	jae    714 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 74a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74d:	8b 40 04             	mov    0x4(%eax),%eax
 750:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 757:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75a:	01 c2                	add    %eax,%edx
 75c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75f:	8b 00                	mov    (%eax),%eax
 761:	39 c2                	cmp    %eax,%edx
 763:	75 24                	jne    789 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 765:	8b 45 f8             	mov    -0x8(%ebp),%eax
 768:	8b 50 04             	mov    0x4(%eax),%edx
 76b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76e:	8b 00                	mov    (%eax),%eax
 770:	8b 40 04             	mov    0x4(%eax),%eax
 773:	01 c2                	add    %eax,%edx
 775:	8b 45 f8             	mov    -0x8(%ebp),%eax
 778:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 77b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77e:	8b 00                	mov    (%eax),%eax
 780:	8b 10                	mov    (%eax),%edx
 782:	8b 45 f8             	mov    -0x8(%ebp),%eax
 785:	89 10                	mov    %edx,(%eax)
 787:	eb 0a                	jmp    793 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 789:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78c:	8b 10                	mov    (%eax),%edx
 78e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 791:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 793:	8b 45 fc             	mov    -0x4(%ebp),%eax
 796:	8b 40 04             	mov    0x4(%eax),%eax
 799:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a3:	01 d0                	add    %edx,%eax
 7a5:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7a8:	75 20                	jne    7ca <free+0xd3>
    p->s.size += bp->s.size;
 7aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ad:	8b 50 04             	mov    0x4(%eax),%edx
 7b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b3:	8b 40 04             	mov    0x4(%eax),%eax
 7b6:	01 c2                	add    %eax,%edx
 7b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bb:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7be:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c1:	8b 10                	mov    (%eax),%edx
 7c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c6:	89 10                	mov    %edx,(%eax)
 7c8:	eb 08                	jmp    7d2 <free+0xdb>
  } else
    p->s.ptr = bp;
 7ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cd:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7d0:	89 10                	mov    %edx,(%eax)
  freep = p;
 7d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d5:	a3 04 0c 00 00       	mov    %eax,0xc04
}
 7da:	90                   	nop
 7db:	c9                   	leave
 7dc:	c3                   	ret

000007dd <morecore>:

static Header*
morecore(uint nu)
{
 7dd:	f3 0f 1e fb          	endbr32
 7e1:	55                   	push   %ebp
 7e2:	89 e5                	mov    %esp,%ebp
 7e4:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7e7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7ee:	77 07                	ja     7f7 <morecore+0x1a>
    nu = 4096;
 7f0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7f7:	8b 45 08             	mov    0x8(%ebp),%eax
 7fa:	c1 e0 03             	shl    $0x3,%eax
 7fd:	83 ec 0c             	sub    $0xc,%esp
 800:	50                   	push   %eax
 801:	e8 47 fc ff ff       	call   44d <sbrk>
 806:	83 c4 10             	add    $0x10,%esp
 809:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 80c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 810:	75 07                	jne    819 <morecore+0x3c>
    return 0;
 812:	b8 00 00 00 00       	mov    $0x0,%eax
 817:	eb 26                	jmp    83f <morecore+0x62>
  hp = (Header*)p;
 819:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 81f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 822:	8b 55 08             	mov    0x8(%ebp),%edx
 825:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 828:	8b 45 f0             	mov    -0x10(%ebp),%eax
 82b:	83 c0 08             	add    $0x8,%eax
 82e:	83 ec 0c             	sub    $0xc,%esp
 831:	50                   	push   %eax
 832:	e8 c0 fe ff ff       	call   6f7 <free>
 837:	83 c4 10             	add    $0x10,%esp
  return freep;
 83a:	a1 04 0c 00 00       	mov    0xc04,%eax
}
 83f:	c9                   	leave
 840:	c3                   	ret

00000841 <malloc>:

void*
malloc(uint nbytes)
{
 841:	f3 0f 1e fb          	endbr32
 845:	55                   	push   %ebp
 846:	89 e5                	mov    %esp,%ebp
 848:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 84b:	8b 45 08             	mov    0x8(%ebp),%eax
 84e:	83 c0 07             	add    $0x7,%eax
 851:	c1 e8 03             	shr    $0x3,%eax
 854:	83 c0 01             	add    $0x1,%eax
 857:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 85a:	a1 04 0c 00 00       	mov    0xc04,%eax
 85f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 862:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 866:	75 23                	jne    88b <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 868:	c7 45 f0 fc 0b 00 00 	movl   $0xbfc,-0x10(%ebp)
 86f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 872:	a3 04 0c 00 00       	mov    %eax,0xc04
 877:	a1 04 0c 00 00       	mov    0xc04,%eax
 87c:	a3 fc 0b 00 00       	mov    %eax,0xbfc
    base.s.size = 0;
 881:	c7 05 00 0c 00 00 00 	movl   $0x0,0xc00
 888:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88e:	8b 00                	mov    (%eax),%eax
 890:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 893:	8b 45 f4             	mov    -0xc(%ebp),%eax
 896:	8b 40 04             	mov    0x4(%eax),%eax
 899:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 89c:	77 4d                	ja     8eb <malloc+0xaa>
      if(p->s.size == nunits)
 89e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a1:	8b 40 04             	mov    0x4(%eax),%eax
 8a4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 8a7:	75 0c                	jne    8b5 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 8a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ac:	8b 10                	mov    (%eax),%edx
 8ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b1:	89 10                	mov    %edx,(%eax)
 8b3:	eb 26                	jmp    8db <malloc+0x9a>
      else {
        p->s.size -= nunits;
 8b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b8:	8b 40 04             	mov    0x4(%eax),%eax
 8bb:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8be:	89 c2                	mov    %eax,%edx
 8c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c3:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c9:	8b 40 04             	mov    0x4(%eax),%eax
 8cc:	c1 e0 03             	shl    $0x3,%eax
 8cf:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d5:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8d8:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8db:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8de:	a3 04 0c 00 00       	mov    %eax,0xc04
      return (void*)(p + 1);
 8e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e6:	83 c0 08             	add    $0x8,%eax
 8e9:	eb 3b                	jmp    926 <malloc+0xe5>
    }
    if(p == freep)
 8eb:	a1 04 0c 00 00       	mov    0xc04,%eax
 8f0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8f3:	75 1e                	jne    913 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 8f5:	83 ec 0c             	sub    $0xc,%esp
 8f8:	ff 75 ec             	push   -0x14(%ebp)
 8fb:	e8 dd fe ff ff       	call   7dd <morecore>
 900:	83 c4 10             	add    $0x10,%esp
 903:	89 45 f4             	mov    %eax,-0xc(%ebp)
 906:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 90a:	75 07                	jne    913 <malloc+0xd2>
        return 0;
 90c:	b8 00 00 00 00       	mov    $0x0,%eax
 911:	eb 13                	jmp    926 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 913:	8b 45 f4             	mov    -0xc(%ebp),%eax
 916:	89 45 f0             	mov    %eax,-0x10(%ebp)
 919:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91c:	8b 00                	mov    (%eax),%eax
 91e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 921:	e9 6d ff ff ff       	jmp    893 <malloc+0x52>
  }
}
 926:	c9                   	leave
 927:	c3                   	ret
