
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	f3 0f 1e fb          	endbr32
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	push   -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	51                   	push   %ecx
  12:	83 ec 04             	sub    $0x4,%esp
  if(fork() > 0)
  15:	e8 89 02 00 00       	call   2a3 <fork>
  1a:	85 c0                	test   %eax,%eax
  1c:	7e 0d                	jle    2b <main+0x2b>
    sleep(5);  // Let child exit before parent.
  1e:	83 ec 0c             	sub    $0xc,%esp
  21:	6a 05                	push   $0x5
  23:	e8 13 03 00 00       	call   33b <sleep>
  28:	83 c4 10             	add    $0x10,%esp
  exit();
  2b:	e8 7b 02 00 00       	call   2ab <exit>

00000030 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  30:	55                   	push   %ebp
  31:	89 e5                	mov    %esp,%ebp
  33:	57                   	push   %edi
  34:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  38:	8b 55 10             	mov    0x10(%ebp),%edx
  3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  3e:	89 cb                	mov    %ecx,%ebx
  40:	89 df                	mov    %ebx,%edi
  42:	89 d1                	mov    %edx,%ecx
  44:	fc                   	cld
  45:	f3 aa                	rep stos %al,%es:(%edi)
  47:	89 ca                	mov    %ecx,%edx
  49:	89 fb                	mov    %edi,%ebx
  4b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  4e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  51:	90                   	nop
  52:	5b                   	pop    %ebx
  53:	5f                   	pop    %edi
  54:	5d                   	pop    %ebp
  55:	c3                   	ret

00000056 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  56:	f3 0f 1e fb          	endbr32
  5a:	55                   	push   %ebp
  5b:	89 e5                	mov    %esp,%ebp
  5d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  60:	8b 45 08             	mov    0x8(%ebp),%eax
  63:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  66:	90                   	nop
  67:	8b 55 0c             	mov    0xc(%ebp),%edx
  6a:	8d 42 01             	lea    0x1(%edx),%eax
  6d:	89 45 0c             	mov    %eax,0xc(%ebp)
  70:	8b 45 08             	mov    0x8(%ebp),%eax
  73:	8d 48 01             	lea    0x1(%eax),%ecx
  76:	89 4d 08             	mov    %ecx,0x8(%ebp)
  79:	0f b6 12             	movzbl (%edx),%edx
  7c:	88 10                	mov    %dl,(%eax)
  7e:	0f b6 00             	movzbl (%eax),%eax
  81:	84 c0                	test   %al,%al
  83:	75 e2                	jne    67 <strcpy+0x11>
    ;
  return os;
  85:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  88:	c9                   	leave
  89:	c3                   	ret

0000008a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8a:	f3 0f 1e fb          	endbr32
  8e:	55                   	push   %ebp
  8f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  91:	eb 08                	jmp    9b <strcmp+0x11>
    p++, q++;
  93:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  97:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  9b:	8b 45 08             	mov    0x8(%ebp),%eax
  9e:	0f b6 00             	movzbl (%eax),%eax
  a1:	84 c0                	test   %al,%al
  a3:	74 10                	je     b5 <strcmp+0x2b>
  a5:	8b 45 08             	mov    0x8(%ebp),%eax
  a8:	0f b6 10             	movzbl (%eax),%edx
  ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  ae:	0f b6 00             	movzbl (%eax),%eax
  b1:	38 c2                	cmp    %al,%dl
  b3:	74 de                	je     93 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
  b5:	8b 45 08             	mov    0x8(%ebp),%eax
  b8:	0f b6 00             	movzbl (%eax),%eax
  bb:	0f b6 d0             	movzbl %al,%edx
  be:	8b 45 0c             	mov    0xc(%ebp),%eax
  c1:	0f b6 00             	movzbl (%eax),%eax
  c4:	0f b6 c0             	movzbl %al,%eax
  c7:	29 c2                	sub    %eax,%edx
  c9:	89 d0                	mov    %edx,%eax
}
  cb:	5d                   	pop    %ebp
  cc:	c3                   	ret

000000cd <strlen>:

uint
strlen(char *s)
{
  cd:	f3 0f 1e fb          	endbr32
  d1:	55                   	push   %ebp
  d2:	89 e5                	mov    %esp,%ebp
  d4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  d7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  de:	eb 04                	jmp    e4 <strlen+0x17>
  e0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  e4:	8b 55 fc             	mov    -0x4(%ebp),%edx
  e7:	8b 45 08             	mov    0x8(%ebp),%eax
  ea:	01 d0                	add    %edx,%eax
  ec:	0f b6 00             	movzbl (%eax),%eax
  ef:	84 c0                	test   %al,%al
  f1:	75 ed                	jne    e0 <strlen+0x13>
    ;
  return n;
  f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  f6:	c9                   	leave
  f7:	c3                   	ret

000000f8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f8:	f3 0f 1e fb          	endbr32
  fc:	55                   	push   %ebp
  fd:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
  ff:	8b 45 10             	mov    0x10(%ebp),%eax
 102:	50                   	push   %eax
 103:	ff 75 0c             	push   0xc(%ebp)
 106:	ff 75 08             	push   0x8(%ebp)
 109:	e8 22 ff ff ff       	call   30 <stosb>
 10e:	83 c4 0c             	add    $0xc,%esp
  return dst;
 111:	8b 45 08             	mov    0x8(%ebp),%eax
}
 114:	c9                   	leave
 115:	c3                   	ret

00000116 <strchr>:

char*
strchr(const char *s, char c)
{
 116:	f3 0f 1e fb          	endbr32
 11a:	55                   	push   %ebp
 11b:	89 e5                	mov    %esp,%ebp
 11d:	83 ec 04             	sub    $0x4,%esp
 120:	8b 45 0c             	mov    0xc(%ebp),%eax
 123:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 126:	eb 14                	jmp    13c <strchr+0x26>
    if(*s == c)
 128:	8b 45 08             	mov    0x8(%ebp),%eax
 12b:	0f b6 00             	movzbl (%eax),%eax
 12e:	38 45 fc             	cmp    %al,-0x4(%ebp)
 131:	75 05                	jne    138 <strchr+0x22>
      return (char*)s;
 133:	8b 45 08             	mov    0x8(%ebp),%eax
 136:	eb 13                	jmp    14b <strchr+0x35>
  for(; *s; s++)
 138:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 13c:	8b 45 08             	mov    0x8(%ebp),%eax
 13f:	0f b6 00             	movzbl (%eax),%eax
 142:	84 c0                	test   %al,%al
 144:	75 e2                	jne    128 <strchr+0x12>
  return 0;
 146:	b8 00 00 00 00       	mov    $0x0,%eax
}
 14b:	c9                   	leave
 14c:	c3                   	ret

0000014d <gets>:

char*
gets(char *buf, int max)
{
 14d:	f3 0f 1e fb          	endbr32
 151:	55                   	push   %ebp
 152:	89 e5                	mov    %esp,%ebp
 154:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 157:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 15e:	eb 42                	jmp    1a2 <gets+0x55>
    cc = read(0, &c, 1);
 160:	83 ec 04             	sub    $0x4,%esp
 163:	6a 01                	push   $0x1
 165:	8d 45 ef             	lea    -0x11(%ebp),%eax
 168:	50                   	push   %eax
 169:	6a 00                	push   $0x0
 16b:	e8 53 01 00 00       	call   2c3 <read>
 170:	83 c4 10             	add    $0x10,%esp
 173:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 176:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 17a:	7e 33                	jle    1af <gets+0x62>
      break;
    buf[i++] = c;
 17c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17f:	8d 50 01             	lea    0x1(%eax),%edx
 182:	89 55 f4             	mov    %edx,-0xc(%ebp)
 185:	89 c2                	mov    %eax,%edx
 187:	8b 45 08             	mov    0x8(%ebp),%eax
 18a:	01 c2                	add    %eax,%edx
 18c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 190:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 192:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 196:	3c 0a                	cmp    $0xa,%al
 198:	74 16                	je     1b0 <gets+0x63>
 19a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 19e:	3c 0d                	cmp    $0xd,%al
 1a0:	74 0e                	je     1b0 <gets+0x63>
  for(i=0; i+1 < max; ){
 1a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a5:	83 c0 01             	add    $0x1,%eax
 1a8:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1ab:	7f b3                	jg     160 <gets+0x13>
 1ad:	eb 01                	jmp    1b0 <gets+0x63>
      break;
 1af:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1b3:	8b 45 08             	mov    0x8(%ebp),%eax
 1b6:	01 d0                	add    %edx,%eax
 1b8:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1bb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1be:	c9                   	leave
 1bf:	c3                   	ret

000001c0 <stat>:

int
stat(char *n, struct stat *st)
{
 1c0:	f3 0f 1e fb          	endbr32
 1c4:	55                   	push   %ebp
 1c5:	89 e5                	mov    %esp,%ebp
 1c7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ca:	83 ec 08             	sub    $0x8,%esp
 1cd:	6a 00                	push   $0x0
 1cf:	ff 75 08             	push   0x8(%ebp)
 1d2:	e8 14 01 00 00       	call   2eb <open>
 1d7:	83 c4 10             	add    $0x10,%esp
 1da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1e1:	79 07                	jns    1ea <stat+0x2a>
    return -1;
 1e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1e8:	eb 25                	jmp    20f <stat+0x4f>
  r = fstat(fd, st);
 1ea:	83 ec 08             	sub    $0x8,%esp
 1ed:	ff 75 0c             	push   0xc(%ebp)
 1f0:	ff 75 f4             	push   -0xc(%ebp)
 1f3:	e8 0b 01 00 00       	call   303 <fstat>
 1f8:	83 c4 10             	add    $0x10,%esp
 1fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1fe:	83 ec 0c             	sub    $0xc,%esp
 201:	ff 75 f4             	push   -0xc(%ebp)
 204:	e8 ca 00 00 00       	call   2d3 <close>
 209:	83 c4 10             	add    $0x10,%esp
  return r;
 20c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 20f:	c9                   	leave
 210:	c3                   	ret

00000211 <atoi>:

int
atoi(const char *s)
{
 211:	f3 0f 1e fb          	endbr32
 215:	55                   	push   %ebp
 216:	89 e5                	mov    %esp,%ebp
 218:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 21b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 222:	eb 25                	jmp    249 <atoi+0x38>
    n = n*10 + *s++ - '0';
 224:	8b 55 fc             	mov    -0x4(%ebp),%edx
 227:	89 d0                	mov    %edx,%eax
 229:	c1 e0 02             	shl    $0x2,%eax
 22c:	01 d0                	add    %edx,%eax
 22e:	01 c0                	add    %eax,%eax
 230:	89 c1                	mov    %eax,%ecx
 232:	8b 45 08             	mov    0x8(%ebp),%eax
 235:	8d 50 01             	lea    0x1(%eax),%edx
 238:	89 55 08             	mov    %edx,0x8(%ebp)
 23b:	0f b6 00             	movzbl (%eax),%eax
 23e:	0f be c0             	movsbl %al,%eax
 241:	01 c8                	add    %ecx,%eax
 243:	83 e8 30             	sub    $0x30,%eax
 246:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 249:	8b 45 08             	mov    0x8(%ebp),%eax
 24c:	0f b6 00             	movzbl (%eax),%eax
 24f:	3c 2f                	cmp    $0x2f,%al
 251:	7e 0a                	jle    25d <atoi+0x4c>
 253:	8b 45 08             	mov    0x8(%ebp),%eax
 256:	0f b6 00             	movzbl (%eax),%eax
 259:	3c 39                	cmp    $0x39,%al
 25b:	7e c7                	jle    224 <atoi+0x13>
  return n;
 25d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 260:	c9                   	leave
 261:	c3                   	ret

00000262 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 262:	f3 0f 1e fb          	endbr32
 266:	55                   	push   %ebp
 267:	89 e5                	mov    %esp,%ebp
 269:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 26c:	8b 45 08             	mov    0x8(%ebp),%eax
 26f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 272:	8b 45 0c             	mov    0xc(%ebp),%eax
 275:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 278:	eb 17                	jmp    291 <memmove+0x2f>
    *dst++ = *src++;
 27a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 27d:	8d 42 01             	lea    0x1(%edx),%eax
 280:	89 45 f8             	mov    %eax,-0x8(%ebp)
 283:	8b 45 fc             	mov    -0x4(%ebp),%eax
 286:	8d 48 01             	lea    0x1(%eax),%ecx
 289:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 28c:	0f b6 12             	movzbl (%edx),%edx
 28f:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 291:	8b 45 10             	mov    0x10(%ebp),%eax
 294:	8d 50 ff             	lea    -0x1(%eax),%edx
 297:	89 55 10             	mov    %edx,0x10(%ebp)
 29a:	85 c0                	test   %eax,%eax
 29c:	7f dc                	jg     27a <memmove+0x18>
  return vdst;
 29e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a1:	c9                   	leave
 2a2:	c3                   	ret

000002a3 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2a3:	b8 01 00 00 00       	mov    $0x1,%eax
 2a8:	cd 40                	int    $0x40
 2aa:	c3                   	ret

000002ab <exit>:
SYSCALL(exit)
 2ab:	b8 02 00 00 00       	mov    $0x2,%eax
 2b0:	cd 40                	int    $0x40
 2b2:	c3                   	ret

000002b3 <wait>:
SYSCALL(wait)
 2b3:	b8 03 00 00 00       	mov    $0x3,%eax
 2b8:	cd 40                	int    $0x40
 2ba:	c3                   	ret

000002bb <pipe>:
SYSCALL(pipe)
 2bb:	b8 04 00 00 00       	mov    $0x4,%eax
 2c0:	cd 40                	int    $0x40
 2c2:	c3                   	ret

000002c3 <read>:
SYSCALL(read)
 2c3:	b8 05 00 00 00       	mov    $0x5,%eax
 2c8:	cd 40                	int    $0x40
 2ca:	c3                   	ret

000002cb <write>:
SYSCALL(write)
 2cb:	b8 10 00 00 00       	mov    $0x10,%eax
 2d0:	cd 40                	int    $0x40
 2d2:	c3                   	ret

000002d3 <close>:
SYSCALL(close)
 2d3:	b8 15 00 00 00       	mov    $0x15,%eax
 2d8:	cd 40                	int    $0x40
 2da:	c3                   	ret

000002db <kill>:
SYSCALL(kill)
 2db:	b8 06 00 00 00       	mov    $0x6,%eax
 2e0:	cd 40                	int    $0x40
 2e2:	c3                   	ret

000002e3 <exec>:
SYSCALL(exec)
 2e3:	b8 07 00 00 00       	mov    $0x7,%eax
 2e8:	cd 40                	int    $0x40
 2ea:	c3                   	ret

000002eb <open>:
SYSCALL(open)
 2eb:	b8 0f 00 00 00       	mov    $0xf,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret

000002f3 <mknod>:
SYSCALL(mknod)
 2f3:	b8 11 00 00 00       	mov    $0x11,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret

000002fb <unlink>:
SYSCALL(unlink)
 2fb:	b8 12 00 00 00       	mov    $0x12,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret

00000303 <fstat>:
SYSCALL(fstat)
 303:	b8 08 00 00 00       	mov    $0x8,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret

0000030b <link>:
SYSCALL(link)
 30b:	b8 13 00 00 00       	mov    $0x13,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret

00000313 <mkdir>:
SYSCALL(mkdir)
 313:	b8 14 00 00 00       	mov    $0x14,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret

0000031b <chdir>:
SYSCALL(chdir)
 31b:	b8 09 00 00 00       	mov    $0x9,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret

00000323 <dup>:
SYSCALL(dup)
 323:	b8 0a 00 00 00       	mov    $0xa,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret

0000032b <getpid>:
SYSCALL(getpid)
 32b:	b8 0b 00 00 00       	mov    $0xb,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret

00000333 <sbrk>:
SYSCALL(sbrk)
 333:	b8 0c 00 00 00       	mov    $0xc,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret

0000033b <sleep>:
SYSCALL(sleep)
 33b:	b8 0d 00 00 00       	mov    $0xd,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret

00000343 <uptime>:
SYSCALL(uptime)
 343:	b8 0e 00 00 00       	mov    $0xe,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret

0000034b <getpinfo>:

SYSCALL(getpinfo)
 34b:	b8 16 00 00 00       	mov    $0x16,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret

00000353 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 353:	b8 17 00 00 00       	mov    $0x17,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret

0000035b <yield>:
SYSCALL(yield)
 35b:	b8 18 00 00 00       	mov    $0x18,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	ret

00000363 <getSchedPolicy>:
 363:	b8 19 00 00 00       	mov    $0x19,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	ret

0000036b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 36b:	f3 0f 1e fb          	endbr32
 36f:	55                   	push   %ebp
 370:	89 e5                	mov    %esp,%ebp
 372:	83 ec 18             	sub    $0x18,%esp
 375:	8b 45 0c             	mov    0xc(%ebp),%eax
 378:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 37b:	83 ec 04             	sub    $0x4,%esp
 37e:	6a 01                	push   $0x1
 380:	8d 45 f4             	lea    -0xc(%ebp),%eax
 383:	50                   	push   %eax
 384:	ff 75 08             	push   0x8(%ebp)
 387:	e8 3f ff ff ff       	call   2cb <write>
 38c:	83 c4 10             	add    $0x10,%esp
}
 38f:	90                   	nop
 390:	c9                   	leave
 391:	c3                   	ret

00000392 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 392:	f3 0f 1e fb          	endbr32
 396:	55                   	push   %ebp
 397:	89 e5                	mov    %esp,%ebp
 399:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 39c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3a3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3a7:	74 17                	je     3c0 <printint+0x2e>
 3a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3ad:	79 11                	jns    3c0 <printint+0x2e>
    neg = 1;
 3af:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b9:	f7 d8                	neg    %eax
 3bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3be:	eb 06                	jmp    3c6 <printint+0x34>
  } else {
    x = xx;
 3c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3d3:	ba 00 00 00 00       	mov    $0x0,%edx
 3d8:	f7 f1                	div    %ecx
 3da:	89 d1                	mov    %edx,%ecx
 3dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3df:	8d 50 01             	lea    0x1(%eax),%edx
 3e2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3e5:	0f b6 91 5c 0a 00 00 	movzbl 0xa5c(%ecx),%edx
 3ec:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 3f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3f6:	ba 00 00 00 00       	mov    $0x0,%edx
 3fb:	f7 f1                	div    %ecx
 3fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
 400:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 404:	75 c7                	jne    3cd <printint+0x3b>
  if(neg)
 406:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 40a:	74 2d                	je     439 <printint+0xa7>
    buf[i++] = '-';
 40c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 40f:	8d 50 01             	lea    0x1(%eax),%edx
 412:	89 55 f4             	mov    %edx,-0xc(%ebp)
 415:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 41a:	eb 1d                	jmp    439 <printint+0xa7>
    putc(fd, buf[i]);
 41c:	8d 55 dc             	lea    -0x24(%ebp),%edx
 41f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 422:	01 d0                	add    %edx,%eax
 424:	0f b6 00             	movzbl (%eax),%eax
 427:	0f be c0             	movsbl %al,%eax
 42a:	83 ec 08             	sub    $0x8,%esp
 42d:	50                   	push   %eax
 42e:	ff 75 08             	push   0x8(%ebp)
 431:	e8 35 ff ff ff       	call   36b <putc>
 436:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 439:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 43d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 441:	79 d9                	jns    41c <printint+0x8a>
}
 443:	90                   	nop
 444:	90                   	nop
 445:	c9                   	leave
 446:	c3                   	ret

00000447 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 447:	f3 0f 1e fb          	endbr32
 44b:	55                   	push   %ebp
 44c:	89 e5                	mov    %esp,%ebp
 44e:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 451:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 458:	8d 45 0c             	lea    0xc(%ebp),%eax
 45b:	83 c0 04             	add    $0x4,%eax
 45e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 461:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 468:	e9 59 01 00 00       	jmp    5c6 <printf+0x17f>
    c = fmt[i] & 0xff;
 46d:	8b 55 0c             	mov    0xc(%ebp),%edx
 470:	8b 45 f0             	mov    -0x10(%ebp),%eax
 473:	01 d0                	add    %edx,%eax
 475:	0f b6 00             	movzbl (%eax),%eax
 478:	0f be c0             	movsbl %al,%eax
 47b:	25 ff 00 00 00       	and    $0xff,%eax
 480:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 483:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 487:	75 2c                	jne    4b5 <printf+0x6e>
      if(c == '%'){
 489:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 48d:	75 0c                	jne    49b <printf+0x54>
        state = '%';
 48f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 496:	e9 27 01 00 00       	jmp    5c2 <printf+0x17b>
      } else {
        putc(fd, c);
 49b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 49e:	0f be c0             	movsbl %al,%eax
 4a1:	83 ec 08             	sub    $0x8,%esp
 4a4:	50                   	push   %eax
 4a5:	ff 75 08             	push   0x8(%ebp)
 4a8:	e8 be fe ff ff       	call   36b <putc>
 4ad:	83 c4 10             	add    $0x10,%esp
 4b0:	e9 0d 01 00 00       	jmp    5c2 <printf+0x17b>
      }
    } else if(state == '%'){
 4b5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4b9:	0f 85 03 01 00 00    	jne    5c2 <printf+0x17b>
      if(c == 'd'){
 4bf:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4c3:	75 1e                	jne    4e3 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 4c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4c8:	8b 00                	mov    (%eax),%eax
 4ca:	6a 01                	push   $0x1
 4cc:	6a 0a                	push   $0xa
 4ce:	50                   	push   %eax
 4cf:	ff 75 08             	push   0x8(%ebp)
 4d2:	e8 bb fe ff ff       	call   392 <printint>
 4d7:	83 c4 10             	add    $0x10,%esp
        ap++;
 4da:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4de:	e9 d8 00 00 00       	jmp    5bb <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 4e3:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4e7:	74 06                	je     4ef <printf+0xa8>
 4e9:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4ed:	75 1e                	jne    50d <printf+0xc6>
        printint(fd, *ap, 16, 0);
 4ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4f2:	8b 00                	mov    (%eax),%eax
 4f4:	6a 00                	push   $0x0
 4f6:	6a 10                	push   $0x10
 4f8:	50                   	push   %eax
 4f9:	ff 75 08             	push   0x8(%ebp)
 4fc:	e8 91 fe ff ff       	call   392 <printint>
 501:	83 c4 10             	add    $0x10,%esp
        ap++;
 504:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 508:	e9 ae 00 00 00       	jmp    5bb <printf+0x174>
      } else if(c == 's'){
 50d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 511:	75 43                	jne    556 <printf+0x10f>
        s = (char*)*ap;
 513:	8b 45 e8             	mov    -0x18(%ebp),%eax
 516:	8b 00                	mov    (%eax),%eax
 518:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 51b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 51f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 523:	75 25                	jne    54a <printf+0x103>
          s = "(null)";
 525:	c7 45 f4 0e 08 00 00 	movl   $0x80e,-0xc(%ebp)
        while(*s != 0){
 52c:	eb 1c                	jmp    54a <printf+0x103>
          putc(fd, *s);
 52e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 531:	0f b6 00             	movzbl (%eax),%eax
 534:	0f be c0             	movsbl %al,%eax
 537:	83 ec 08             	sub    $0x8,%esp
 53a:	50                   	push   %eax
 53b:	ff 75 08             	push   0x8(%ebp)
 53e:	e8 28 fe ff ff       	call   36b <putc>
 543:	83 c4 10             	add    $0x10,%esp
          s++;
 546:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 54a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54d:	0f b6 00             	movzbl (%eax),%eax
 550:	84 c0                	test   %al,%al
 552:	75 da                	jne    52e <printf+0xe7>
 554:	eb 65                	jmp    5bb <printf+0x174>
        }
      } else if(c == 'c'){
 556:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 55a:	75 1d                	jne    579 <printf+0x132>
        putc(fd, *ap);
 55c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55f:	8b 00                	mov    (%eax),%eax
 561:	0f be c0             	movsbl %al,%eax
 564:	83 ec 08             	sub    $0x8,%esp
 567:	50                   	push   %eax
 568:	ff 75 08             	push   0x8(%ebp)
 56b:	e8 fb fd ff ff       	call   36b <putc>
 570:	83 c4 10             	add    $0x10,%esp
        ap++;
 573:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 577:	eb 42                	jmp    5bb <printf+0x174>
      } else if(c == '%'){
 579:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 57d:	75 17                	jne    596 <printf+0x14f>
        putc(fd, c);
 57f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 582:	0f be c0             	movsbl %al,%eax
 585:	83 ec 08             	sub    $0x8,%esp
 588:	50                   	push   %eax
 589:	ff 75 08             	push   0x8(%ebp)
 58c:	e8 da fd ff ff       	call   36b <putc>
 591:	83 c4 10             	add    $0x10,%esp
 594:	eb 25                	jmp    5bb <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 596:	83 ec 08             	sub    $0x8,%esp
 599:	6a 25                	push   $0x25
 59b:	ff 75 08             	push   0x8(%ebp)
 59e:	e8 c8 fd ff ff       	call   36b <putc>
 5a3:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5a9:	0f be c0             	movsbl %al,%eax
 5ac:	83 ec 08             	sub    $0x8,%esp
 5af:	50                   	push   %eax
 5b0:	ff 75 08             	push   0x8(%ebp)
 5b3:	e8 b3 fd ff ff       	call   36b <putc>
 5b8:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5bb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5c2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5c6:	8b 55 0c             	mov    0xc(%ebp),%edx
 5c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5cc:	01 d0                	add    %edx,%eax
 5ce:	0f b6 00             	movzbl (%eax),%eax
 5d1:	84 c0                	test   %al,%al
 5d3:	0f 85 94 fe ff ff    	jne    46d <printf+0x26>
    }
  }
}
 5d9:	90                   	nop
 5da:	90                   	nop
 5db:	c9                   	leave
 5dc:	c3                   	ret

000005dd <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5dd:	f3 0f 1e fb          	endbr32
 5e1:	55                   	push   %ebp
 5e2:	89 e5                	mov    %esp,%ebp
 5e4:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5e7:	8b 45 08             	mov    0x8(%ebp),%eax
 5ea:	83 e8 08             	sub    $0x8,%eax
 5ed:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5f0:	a1 78 0a 00 00       	mov    0xa78,%eax
 5f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5f8:	eb 24                	jmp    61e <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5fd:	8b 00                	mov    (%eax),%eax
 5ff:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 602:	72 12                	jb     616 <free+0x39>
 604:	8b 45 f8             	mov    -0x8(%ebp),%eax
 607:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 60a:	77 24                	ja     630 <free+0x53>
 60c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60f:	8b 00                	mov    (%eax),%eax
 611:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 614:	72 1a                	jb     630 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 616:	8b 45 fc             	mov    -0x4(%ebp),%eax
 619:	8b 00                	mov    (%eax),%eax
 61b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 61e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 621:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 624:	76 d4                	jbe    5fa <free+0x1d>
 626:	8b 45 fc             	mov    -0x4(%ebp),%eax
 629:	8b 00                	mov    (%eax),%eax
 62b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 62e:	73 ca                	jae    5fa <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 630:	8b 45 f8             	mov    -0x8(%ebp),%eax
 633:	8b 40 04             	mov    0x4(%eax),%eax
 636:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 63d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 640:	01 c2                	add    %eax,%edx
 642:	8b 45 fc             	mov    -0x4(%ebp),%eax
 645:	8b 00                	mov    (%eax),%eax
 647:	39 c2                	cmp    %eax,%edx
 649:	75 24                	jne    66f <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 64b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64e:	8b 50 04             	mov    0x4(%eax),%edx
 651:	8b 45 fc             	mov    -0x4(%ebp),%eax
 654:	8b 00                	mov    (%eax),%eax
 656:	8b 40 04             	mov    0x4(%eax),%eax
 659:	01 c2                	add    %eax,%edx
 65b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65e:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 661:	8b 45 fc             	mov    -0x4(%ebp),%eax
 664:	8b 00                	mov    (%eax),%eax
 666:	8b 10                	mov    (%eax),%edx
 668:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66b:	89 10                	mov    %edx,(%eax)
 66d:	eb 0a                	jmp    679 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 66f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 672:	8b 10                	mov    (%eax),%edx
 674:	8b 45 f8             	mov    -0x8(%ebp),%eax
 677:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 679:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67c:	8b 40 04             	mov    0x4(%eax),%eax
 67f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 686:	8b 45 fc             	mov    -0x4(%ebp),%eax
 689:	01 d0                	add    %edx,%eax
 68b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 68e:	75 20                	jne    6b0 <free+0xd3>
    p->s.size += bp->s.size;
 690:	8b 45 fc             	mov    -0x4(%ebp),%eax
 693:	8b 50 04             	mov    0x4(%eax),%edx
 696:	8b 45 f8             	mov    -0x8(%ebp),%eax
 699:	8b 40 04             	mov    0x4(%eax),%eax
 69c:	01 c2                	add    %eax,%edx
 69e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a7:	8b 10                	mov    (%eax),%edx
 6a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ac:	89 10                	mov    %edx,(%eax)
 6ae:	eb 08                	jmp    6b8 <free+0xdb>
  } else
    p->s.ptr = bp;
 6b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6b6:	89 10                	mov    %edx,(%eax)
  freep = p;
 6b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bb:	a3 78 0a 00 00       	mov    %eax,0xa78
}
 6c0:	90                   	nop
 6c1:	c9                   	leave
 6c2:	c3                   	ret

000006c3 <morecore>:

static Header*
morecore(uint nu)
{
 6c3:	f3 0f 1e fb          	endbr32
 6c7:	55                   	push   %ebp
 6c8:	89 e5                	mov    %esp,%ebp
 6ca:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6cd:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6d4:	77 07                	ja     6dd <morecore+0x1a>
    nu = 4096;
 6d6:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6dd:	8b 45 08             	mov    0x8(%ebp),%eax
 6e0:	c1 e0 03             	shl    $0x3,%eax
 6e3:	83 ec 0c             	sub    $0xc,%esp
 6e6:	50                   	push   %eax
 6e7:	e8 47 fc ff ff       	call   333 <sbrk>
 6ec:	83 c4 10             	add    $0x10,%esp
 6ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6f2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6f6:	75 07                	jne    6ff <morecore+0x3c>
    return 0;
 6f8:	b8 00 00 00 00       	mov    $0x0,%eax
 6fd:	eb 26                	jmp    725 <morecore+0x62>
  hp = (Header*)p;
 6ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 702:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 705:	8b 45 f0             	mov    -0x10(%ebp),%eax
 708:	8b 55 08             	mov    0x8(%ebp),%edx
 70b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 70e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 711:	83 c0 08             	add    $0x8,%eax
 714:	83 ec 0c             	sub    $0xc,%esp
 717:	50                   	push   %eax
 718:	e8 c0 fe ff ff       	call   5dd <free>
 71d:	83 c4 10             	add    $0x10,%esp
  return freep;
 720:	a1 78 0a 00 00       	mov    0xa78,%eax
}
 725:	c9                   	leave
 726:	c3                   	ret

00000727 <malloc>:

void*
malloc(uint nbytes)
{
 727:	f3 0f 1e fb          	endbr32
 72b:	55                   	push   %ebp
 72c:	89 e5                	mov    %esp,%ebp
 72e:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 731:	8b 45 08             	mov    0x8(%ebp),%eax
 734:	83 c0 07             	add    $0x7,%eax
 737:	c1 e8 03             	shr    $0x3,%eax
 73a:	83 c0 01             	add    $0x1,%eax
 73d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 740:	a1 78 0a 00 00       	mov    0xa78,%eax
 745:	89 45 f0             	mov    %eax,-0x10(%ebp)
 748:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 74c:	75 23                	jne    771 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 74e:	c7 45 f0 70 0a 00 00 	movl   $0xa70,-0x10(%ebp)
 755:	8b 45 f0             	mov    -0x10(%ebp),%eax
 758:	a3 78 0a 00 00       	mov    %eax,0xa78
 75d:	a1 78 0a 00 00       	mov    0xa78,%eax
 762:	a3 70 0a 00 00       	mov    %eax,0xa70
    base.s.size = 0;
 767:	c7 05 74 0a 00 00 00 	movl   $0x0,0xa74
 76e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 771:	8b 45 f0             	mov    -0x10(%ebp),%eax
 774:	8b 00                	mov    (%eax),%eax
 776:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 779:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77c:	8b 40 04             	mov    0x4(%eax),%eax
 77f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 782:	77 4d                	ja     7d1 <malloc+0xaa>
      if(p->s.size == nunits)
 784:	8b 45 f4             	mov    -0xc(%ebp),%eax
 787:	8b 40 04             	mov    0x4(%eax),%eax
 78a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 78d:	75 0c                	jne    79b <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 78f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 792:	8b 10                	mov    (%eax),%edx
 794:	8b 45 f0             	mov    -0x10(%ebp),%eax
 797:	89 10                	mov    %edx,(%eax)
 799:	eb 26                	jmp    7c1 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 79b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79e:	8b 40 04             	mov    0x4(%eax),%eax
 7a1:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7a4:	89 c2                	mov    %eax,%edx
 7a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7af:	8b 40 04             	mov    0x4(%eax),%eax
 7b2:	c1 e0 03             	shl    $0x3,%eax
 7b5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7be:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c4:	a3 78 0a 00 00       	mov    %eax,0xa78
      return (void*)(p + 1);
 7c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cc:	83 c0 08             	add    $0x8,%eax
 7cf:	eb 3b                	jmp    80c <malloc+0xe5>
    }
    if(p == freep)
 7d1:	a1 78 0a 00 00       	mov    0xa78,%eax
 7d6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7d9:	75 1e                	jne    7f9 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 7db:	83 ec 0c             	sub    $0xc,%esp
 7de:	ff 75 ec             	push   -0x14(%ebp)
 7e1:	e8 dd fe ff ff       	call   6c3 <morecore>
 7e6:	83 c4 10             	add    $0x10,%esp
 7e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7f0:	75 07                	jne    7f9 <malloc+0xd2>
        return 0;
 7f2:	b8 00 00 00 00       	mov    $0x0,%eax
 7f7:	eb 13                	jmp    80c <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 802:	8b 00                	mov    (%eax),%eax
 804:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 807:	e9 6d ff ff ff       	jmp    779 <malloc+0x52>
  }
}
 80c:	c9                   	leave
 80d:	c3                   	ret
