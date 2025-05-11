
_echo:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	f3 0f 1e fb          	endbr32
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	push   -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	53                   	push   %ebx
  12:	51                   	push   %ecx
  13:	83 ec 10             	sub    $0x10,%esp
  16:	89 cb                	mov    %ecx,%ebx
  int i;

  for(i = 1; i < argc; i++)
  18:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  1f:	eb 3c                	jmp    5d <main+0x5d>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  24:	83 c0 01             	add    $0x1,%eax
  27:	39 03                	cmp    %eax,(%ebx)
  29:	7e 07                	jle    32 <main+0x32>
  2b:	b9 47 08 00 00       	mov    $0x847,%ecx
  30:	eb 05                	jmp    37 <main+0x37>
  32:	b9 49 08 00 00       	mov    $0x849,%ecx
  37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  3a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  41:	8b 43 04             	mov    0x4(%ebx),%eax
  44:	01 d0                	add    %edx,%eax
  46:	8b 00                	mov    (%eax),%eax
  48:	51                   	push   %ecx
  49:	50                   	push   %eax
  4a:	68 4b 08 00 00       	push   $0x84b
  4f:	6a 01                	push   $0x1
  51:	e8 2a 04 00 00       	call   480 <printf>
  56:	83 c4 10             	add    $0x10,%esp
  for(i = 1; i < argc; i++)
  59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  60:	3b 03                	cmp    (%ebx),%eax
  62:	7c bd                	jl     21 <main+0x21>
  exit();
  64:	e8 7b 02 00 00       	call   2e4 <exit>

00000069 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  69:	55                   	push   %ebp
  6a:	89 e5                	mov    %esp,%ebp
  6c:	57                   	push   %edi
  6d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  71:	8b 55 10             	mov    0x10(%ebp),%edx
  74:	8b 45 0c             	mov    0xc(%ebp),%eax
  77:	89 cb                	mov    %ecx,%ebx
  79:	89 df                	mov    %ebx,%edi
  7b:	89 d1                	mov    %edx,%ecx
  7d:	fc                   	cld
  7e:	f3 aa                	rep stos %al,%es:(%edi)
  80:	89 ca                	mov    %ecx,%edx
  82:	89 fb                	mov    %edi,%ebx
  84:	89 5d 08             	mov    %ebx,0x8(%ebp)
  87:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  8a:	90                   	nop
  8b:	5b                   	pop    %ebx
  8c:	5f                   	pop    %edi
  8d:	5d                   	pop    %ebp
  8e:	c3                   	ret

0000008f <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  8f:	f3 0f 1e fb          	endbr32
  93:	55                   	push   %ebp
  94:	89 e5                	mov    %esp,%ebp
  96:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  99:	8b 45 08             	mov    0x8(%ebp),%eax
  9c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  9f:	90                   	nop
  a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  a3:	8d 42 01             	lea    0x1(%edx),%eax
  a6:	89 45 0c             	mov    %eax,0xc(%ebp)
  a9:	8b 45 08             	mov    0x8(%ebp),%eax
  ac:	8d 48 01             	lea    0x1(%eax),%ecx
  af:	89 4d 08             	mov    %ecx,0x8(%ebp)
  b2:	0f b6 12             	movzbl (%edx),%edx
  b5:	88 10                	mov    %dl,(%eax)
  b7:	0f b6 00             	movzbl (%eax),%eax
  ba:	84 c0                	test   %al,%al
  bc:	75 e2                	jne    a0 <strcpy+0x11>
    ;
  return os;
  be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  c1:	c9                   	leave
  c2:	c3                   	ret

000000c3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c3:	f3 0f 1e fb          	endbr32
  c7:	55                   	push   %ebp
  c8:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  ca:	eb 08                	jmp    d4 <strcmp+0x11>
    p++, q++;
  cc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  d0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  d4:	8b 45 08             	mov    0x8(%ebp),%eax
  d7:	0f b6 00             	movzbl (%eax),%eax
  da:	84 c0                	test   %al,%al
  dc:	74 10                	je     ee <strcmp+0x2b>
  de:	8b 45 08             	mov    0x8(%ebp),%eax
  e1:	0f b6 10             	movzbl (%eax),%edx
  e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  e7:	0f b6 00             	movzbl (%eax),%eax
  ea:	38 c2                	cmp    %al,%dl
  ec:	74 de                	je     cc <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
  ee:	8b 45 08             	mov    0x8(%ebp),%eax
  f1:	0f b6 00             	movzbl (%eax),%eax
  f4:	0f b6 d0             	movzbl %al,%edx
  f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  fa:	0f b6 00             	movzbl (%eax),%eax
  fd:	0f b6 c0             	movzbl %al,%eax
 100:	29 c2                	sub    %eax,%edx
 102:	89 d0                	mov    %edx,%eax
}
 104:	5d                   	pop    %ebp
 105:	c3                   	ret

00000106 <strlen>:

uint
strlen(char *s)
{
 106:	f3 0f 1e fb          	endbr32
 10a:	55                   	push   %ebp
 10b:	89 e5                	mov    %esp,%ebp
 10d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 110:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 117:	eb 04                	jmp    11d <strlen+0x17>
 119:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 11d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 120:	8b 45 08             	mov    0x8(%ebp),%eax
 123:	01 d0                	add    %edx,%eax
 125:	0f b6 00             	movzbl (%eax),%eax
 128:	84 c0                	test   %al,%al
 12a:	75 ed                	jne    119 <strlen+0x13>
    ;
  return n;
 12c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 12f:	c9                   	leave
 130:	c3                   	ret

00000131 <memset>:

void*
memset(void *dst, int c, uint n)
{
 131:	f3 0f 1e fb          	endbr32
 135:	55                   	push   %ebp
 136:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 138:	8b 45 10             	mov    0x10(%ebp),%eax
 13b:	50                   	push   %eax
 13c:	ff 75 0c             	push   0xc(%ebp)
 13f:	ff 75 08             	push   0x8(%ebp)
 142:	e8 22 ff ff ff       	call   69 <stosb>
 147:	83 c4 0c             	add    $0xc,%esp
  return dst;
 14a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 14d:	c9                   	leave
 14e:	c3                   	ret

0000014f <strchr>:

char*
strchr(const char *s, char c)
{
 14f:	f3 0f 1e fb          	endbr32
 153:	55                   	push   %ebp
 154:	89 e5                	mov    %esp,%ebp
 156:	83 ec 04             	sub    $0x4,%esp
 159:	8b 45 0c             	mov    0xc(%ebp),%eax
 15c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 15f:	eb 14                	jmp    175 <strchr+0x26>
    if(*s == c)
 161:	8b 45 08             	mov    0x8(%ebp),%eax
 164:	0f b6 00             	movzbl (%eax),%eax
 167:	38 45 fc             	cmp    %al,-0x4(%ebp)
 16a:	75 05                	jne    171 <strchr+0x22>
      return (char*)s;
 16c:	8b 45 08             	mov    0x8(%ebp),%eax
 16f:	eb 13                	jmp    184 <strchr+0x35>
  for(; *s; s++)
 171:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 175:	8b 45 08             	mov    0x8(%ebp),%eax
 178:	0f b6 00             	movzbl (%eax),%eax
 17b:	84 c0                	test   %al,%al
 17d:	75 e2                	jne    161 <strchr+0x12>
  return 0;
 17f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 184:	c9                   	leave
 185:	c3                   	ret

00000186 <gets>:

char*
gets(char *buf, int max)
{
 186:	f3 0f 1e fb          	endbr32
 18a:	55                   	push   %ebp
 18b:	89 e5                	mov    %esp,%ebp
 18d:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 190:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 197:	eb 42                	jmp    1db <gets+0x55>
    cc = read(0, &c, 1);
 199:	83 ec 04             	sub    $0x4,%esp
 19c:	6a 01                	push   $0x1
 19e:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1a1:	50                   	push   %eax
 1a2:	6a 00                	push   $0x0
 1a4:	e8 53 01 00 00       	call   2fc <read>
 1a9:	83 c4 10             	add    $0x10,%esp
 1ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1b3:	7e 33                	jle    1e8 <gets+0x62>
      break;
    buf[i++] = c;
 1b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b8:	8d 50 01             	lea    0x1(%eax),%edx
 1bb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1be:	89 c2                	mov    %eax,%edx
 1c0:	8b 45 08             	mov    0x8(%ebp),%eax
 1c3:	01 c2                	add    %eax,%edx
 1c5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c9:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1cb:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1cf:	3c 0a                	cmp    $0xa,%al
 1d1:	74 16                	je     1e9 <gets+0x63>
 1d3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d7:	3c 0d                	cmp    $0xd,%al
 1d9:	74 0e                	je     1e9 <gets+0x63>
  for(i=0; i+1 < max; ){
 1db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1de:	83 c0 01             	add    $0x1,%eax
 1e1:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1e4:	7f b3                	jg     199 <gets+0x13>
 1e6:	eb 01                	jmp    1e9 <gets+0x63>
      break;
 1e8:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
 1ef:	01 d0                	add    %edx,%eax
 1f1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1f4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f7:	c9                   	leave
 1f8:	c3                   	ret

000001f9 <stat>:

int
stat(char *n, struct stat *st)
{
 1f9:	f3 0f 1e fb          	endbr32
 1fd:	55                   	push   %ebp
 1fe:	89 e5                	mov    %esp,%ebp
 200:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 203:	83 ec 08             	sub    $0x8,%esp
 206:	6a 00                	push   $0x0
 208:	ff 75 08             	push   0x8(%ebp)
 20b:	e8 14 01 00 00       	call   324 <open>
 210:	83 c4 10             	add    $0x10,%esp
 213:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 216:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 21a:	79 07                	jns    223 <stat+0x2a>
    return -1;
 21c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 221:	eb 25                	jmp    248 <stat+0x4f>
  r = fstat(fd, st);
 223:	83 ec 08             	sub    $0x8,%esp
 226:	ff 75 0c             	push   0xc(%ebp)
 229:	ff 75 f4             	push   -0xc(%ebp)
 22c:	e8 0b 01 00 00       	call   33c <fstat>
 231:	83 c4 10             	add    $0x10,%esp
 234:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 237:	83 ec 0c             	sub    $0xc,%esp
 23a:	ff 75 f4             	push   -0xc(%ebp)
 23d:	e8 ca 00 00 00       	call   30c <close>
 242:	83 c4 10             	add    $0x10,%esp
  return r;
 245:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 248:	c9                   	leave
 249:	c3                   	ret

0000024a <atoi>:

int
atoi(const char *s)
{
 24a:	f3 0f 1e fb          	endbr32
 24e:	55                   	push   %ebp
 24f:	89 e5                	mov    %esp,%ebp
 251:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 254:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 25b:	eb 25                	jmp    282 <atoi+0x38>
    n = n*10 + *s++ - '0';
 25d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 260:	89 d0                	mov    %edx,%eax
 262:	c1 e0 02             	shl    $0x2,%eax
 265:	01 d0                	add    %edx,%eax
 267:	01 c0                	add    %eax,%eax
 269:	89 c1                	mov    %eax,%ecx
 26b:	8b 45 08             	mov    0x8(%ebp),%eax
 26e:	8d 50 01             	lea    0x1(%eax),%edx
 271:	89 55 08             	mov    %edx,0x8(%ebp)
 274:	0f b6 00             	movzbl (%eax),%eax
 277:	0f be c0             	movsbl %al,%eax
 27a:	01 c8                	add    %ecx,%eax
 27c:	83 e8 30             	sub    $0x30,%eax
 27f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 282:	8b 45 08             	mov    0x8(%ebp),%eax
 285:	0f b6 00             	movzbl (%eax),%eax
 288:	3c 2f                	cmp    $0x2f,%al
 28a:	7e 0a                	jle    296 <atoi+0x4c>
 28c:	8b 45 08             	mov    0x8(%ebp),%eax
 28f:	0f b6 00             	movzbl (%eax),%eax
 292:	3c 39                	cmp    $0x39,%al
 294:	7e c7                	jle    25d <atoi+0x13>
  return n;
 296:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 299:	c9                   	leave
 29a:	c3                   	ret

0000029b <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 29b:	f3 0f 1e fb          	endbr32
 29f:	55                   	push   %ebp
 2a0:	89 e5                	mov    %esp,%ebp
 2a2:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2ab:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ae:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2b1:	eb 17                	jmp    2ca <memmove+0x2f>
    *dst++ = *src++;
 2b3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2b6:	8d 42 01             	lea    0x1(%edx),%eax
 2b9:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2bf:	8d 48 01             	lea    0x1(%eax),%ecx
 2c2:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 2c5:	0f b6 12             	movzbl (%edx),%edx
 2c8:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2ca:	8b 45 10             	mov    0x10(%ebp),%eax
 2cd:	8d 50 ff             	lea    -0x1(%eax),%edx
 2d0:	89 55 10             	mov    %edx,0x10(%ebp)
 2d3:	85 c0                	test   %eax,%eax
 2d5:	7f dc                	jg     2b3 <memmove+0x18>
  return vdst;
 2d7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2da:	c9                   	leave
 2db:	c3                   	ret

000002dc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2dc:	b8 01 00 00 00       	mov    $0x1,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret

000002e4 <exit>:
SYSCALL(exit)
 2e4:	b8 02 00 00 00       	mov    $0x2,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret

000002ec <wait>:
SYSCALL(wait)
 2ec:	b8 03 00 00 00       	mov    $0x3,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret

000002f4 <pipe>:
SYSCALL(pipe)
 2f4:	b8 04 00 00 00       	mov    $0x4,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret

000002fc <read>:
SYSCALL(read)
 2fc:	b8 05 00 00 00       	mov    $0x5,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret

00000304 <write>:
SYSCALL(write)
 304:	b8 10 00 00 00       	mov    $0x10,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret

0000030c <close>:
SYSCALL(close)
 30c:	b8 15 00 00 00       	mov    $0x15,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret

00000314 <kill>:
SYSCALL(kill)
 314:	b8 06 00 00 00       	mov    $0x6,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret

0000031c <exec>:
SYSCALL(exec)
 31c:	b8 07 00 00 00       	mov    $0x7,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret

00000324 <open>:
SYSCALL(open)
 324:	b8 0f 00 00 00       	mov    $0xf,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret

0000032c <mknod>:
SYSCALL(mknod)
 32c:	b8 11 00 00 00       	mov    $0x11,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret

00000334 <unlink>:
SYSCALL(unlink)
 334:	b8 12 00 00 00       	mov    $0x12,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret

0000033c <fstat>:
SYSCALL(fstat)
 33c:	b8 08 00 00 00       	mov    $0x8,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret

00000344 <link>:
SYSCALL(link)
 344:	b8 13 00 00 00       	mov    $0x13,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret

0000034c <mkdir>:
SYSCALL(mkdir)
 34c:	b8 14 00 00 00       	mov    $0x14,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret

00000354 <chdir>:
SYSCALL(chdir)
 354:	b8 09 00 00 00       	mov    $0x9,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret

0000035c <dup>:
SYSCALL(dup)
 35c:	b8 0a 00 00 00       	mov    $0xa,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret

00000364 <getpid>:
SYSCALL(getpid)
 364:	b8 0b 00 00 00       	mov    $0xb,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret

0000036c <sbrk>:
SYSCALL(sbrk)
 36c:	b8 0c 00 00 00       	mov    $0xc,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret

00000374 <sleep>:
SYSCALL(sleep)
 374:	b8 0d 00 00 00       	mov    $0xd,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret

0000037c <uptime>:
SYSCALL(uptime)
 37c:	b8 0e 00 00 00       	mov    $0xe,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret

00000384 <getpinfo>:

SYSCALL(getpinfo)
 384:	b8 16 00 00 00       	mov    $0x16,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret

0000038c <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 38c:	b8 17 00 00 00       	mov    $0x17,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret

00000394 <yield>:
SYSCALL(yield)
 394:	b8 18 00 00 00       	mov    $0x18,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret

0000039c <getSchedPolicy>:
 39c:	b8 19 00 00 00       	mov    $0x19,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret

000003a4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3a4:	f3 0f 1e fb          	endbr32
 3a8:	55                   	push   %ebp
 3a9:	89 e5                	mov    %esp,%ebp
 3ab:	83 ec 18             	sub    $0x18,%esp
 3ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3b4:	83 ec 04             	sub    $0x4,%esp
 3b7:	6a 01                	push   $0x1
 3b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3bc:	50                   	push   %eax
 3bd:	ff 75 08             	push   0x8(%ebp)
 3c0:	e8 3f ff ff ff       	call   304 <write>
 3c5:	83 c4 10             	add    $0x10,%esp
}
 3c8:	90                   	nop
 3c9:	c9                   	leave
 3ca:	c3                   	ret

000003cb <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3cb:	f3 0f 1e fb          	endbr32
 3cf:	55                   	push   %ebp
 3d0:	89 e5                	mov    %esp,%ebp
 3d2:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3d5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3dc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3e0:	74 17                	je     3f9 <printint+0x2e>
 3e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3e6:	79 11                	jns    3f9 <printint+0x2e>
    neg = 1;
 3e8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3ef:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f2:	f7 d8                	neg    %eax
 3f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3f7:	eb 06                	jmp    3ff <printint+0x34>
  } else {
    x = xx;
 3f9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 406:	8b 4d 10             	mov    0x10(%ebp),%ecx
 409:	8b 45 ec             	mov    -0x14(%ebp),%eax
 40c:	ba 00 00 00 00       	mov    $0x0,%edx
 411:	f7 f1                	div    %ecx
 413:	89 d1                	mov    %edx,%ecx
 415:	8b 45 f4             	mov    -0xc(%ebp),%eax
 418:	8d 50 01             	lea    0x1(%eax),%edx
 41b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 41e:	0f b6 91 a0 0a 00 00 	movzbl 0xaa0(%ecx),%edx
 425:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 429:	8b 4d 10             	mov    0x10(%ebp),%ecx
 42c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 42f:	ba 00 00 00 00       	mov    $0x0,%edx
 434:	f7 f1                	div    %ecx
 436:	89 45 ec             	mov    %eax,-0x14(%ebp)
 439:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 43d:	75 c7                	jne    406 <printint+0x3b>
  if(neg)
 43f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 443:	74 2d                	je     472 <printint+0xa7>
    buf[i++] = '-';
 445:	8b 45 f4             	mov    -0xc(%ebp),%eax
 448:	8d 50 01             	lea    0x1(%eax),%edx
 44b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 44e:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 453:	eb 1d                	jmp    472 <printint+0xa7>
    putc(fd, buf[i]);
 455:	8d 55 dc             	lea    -0x24(%ebp),%edx
 458:	8b 45 f4             	mov    -0xc(%ebp),%eax
 45b:	01 d0                	add    %edx,%eax
 45d:	0f b6 00             	movzbl (%eax),%eax
 460:	0f be c0             	movsbl %al,%eax
 463:	83 ec 08             	sub    $0x8,%esp
 466:	50                   	push   %eax
 467:	ff 75 08             	push   0x8(%ebp)
 46a:	e8 35 ff ff ff       	call   3a4 <putc>
 46f:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 472:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 476:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 47a:	79 d9                	jns    455 <printint+0x8a>
}
 47c:	90                   	nop
 47d:	90                   	nop
 47e:	c9                   	leave
 47f:	c3                   	ret

00000480 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 480:	f3 0f 1e fb          	endbr32
 484:	55                   	push   %ebp
 485:	89 e5                	mov    %esp,%ebp
 487:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 48a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 491:	8d 45 0c             	lea    0xc(%ebp),%eax
 494:	83 c0 04             	add    $0x4,%eax
 497:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 49a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4a1:	e9 59 01 00 00       	jmp    5ff <printf+0x17f>
    c = fmt[i] & 0xff;
 4a6:	8b 55 0c             	mov    0xc(%ebp),%edx
 4a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4ac:	01 d0                	add    %edx,%eax
 4ae:	0f b6 00             	movzbl (%eax),%eax
 4b1:	0f be c0             	movsbl %al,%eax
 4b4:	25 ff 00 00 00       	and    $0xff,%eax
 4b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4bc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c0:	75 2c                	jne    4ee <printf+0x6e>
      if(c == '%'){
 4c2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4c6:	75 0c                	jne    4d4 <printf+0x54>
        state = '%';
 4c8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4cf:	e9 27 01 00 00       	jmp    5fb <printf+0x17b>
      } else {
        putc(fd, c);
 4d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4d7:	0f be c0             	movsbl %al,%eax
 4da:	83 ec 08             	sub    $0x8,%esp
 4dd:	50                   	push   %eax
 4de:	ff 75 08             	push   0x8(%ebp)
 4e1:	e8 be fe ff ff       	call   3a4 <putc>
 4e6:	83 c4 10             	add    $0x10,%esp
 4e9:	e9 0d 01 00 00       	jmp    5fb <printf+0x17b>
      }
    } else if(state == '%'){
 4ee:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4f2:	0f 85 03 01 00 00    	jne    5fb <printf+0x17b>
      if(c == 'd'){
 4f8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4fc:	75 1e                	jne    51c <printf+0x9c>
        printint(fd, *ap, 10, 1);
 4fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
 501:	8b 00                	mov    (%eax),%eax
 503:	6a 01                	push   $0x1
 505:	6a 0a                	push   $0xa
 507:	50                   	push   %eax
 508:	ff 75 08             	push   0x8(%ebp)
 50b:	e8 bb fe ff ff       	call   3cb <printint>
 510:	83 c4 10             	add    $0x10,%esp
        ap++;
 513:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 517:	e9 d8 00 00 00       	jmp    5f4 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 51c:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 520:	74 06                	je     528 <printf+0xa8>
 522:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 526:	75 1e                	jne    546 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 528:	8b 45 e8             	mov    -0x18(%ebp),%eax
 52b:	8b 00                	mov    (%eax),%eax
 52d:	6a 00                	push   $0x0
 52f:	6a 10                	push   $0x10
 531:	50                   	push   %eax
 532:	ff 75 08             	push   0x8(%ebp)
 535:	e8 91 fe ff ff       	call   3cb <printint>
 53a:	83 c4 10             	add    $0x10,%esp
        ap++;
 53d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 541:	e9 ae 00 00 00       	jmp    5f4 <printf+0x174>
      } else if(c == 's'){
 546:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 54a:	75 43                	jne    58f <printf+0x10f>
        s = (char*)*ap;
 54c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 54f:	8b 00                	mov    (%eax),%eax
 551:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 554:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 558:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 55c:	75 25                	jne    583 <printf+0x103>
          s = "(null)";
 55e:	c7 45 f4 50 08 00 00 	movl   $0x850,-0xc(%ebp)
        while(*s != 0){
 565:	eb 1c                	jmp    583 <printf+0x103>
          putc(fd, *s);
 567:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56a:	0f b6 00             	movzbl (%eax),%eax
 56d:	0f be c0             	movsbl %al,%eax
 570:	83 ec 08             	sub    $0x8,%esp
 573:	50                   	push   %eax
 574:	ff 75 08             	push   0x8(%ebp)
 577:	e8 28 fe ff ff       	call   3a4 <putc>
 57c:	83 c4 10             	add    $0x10,%esp
          s++;
 57f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 583:	8b 45 f4             	mov    -0xc(%ebp),%eax
 586:	0f b6 00             	movzbl (%eax),%eax
 589:	84 c0                	test   %al,%al
 58b:	75 da                	jne    567 <printf+0xe7>
 58d:	eb 65                	jmp    5f4 <printf+0x174>
        }
      } else if(c == 'c'){
 58f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 593:	75 1d                	jne    5b2 <printf+0x132>
        putc(fd, *ap);
 595:	8b 45 e8             	mov    -0x18(%ebp),%eax
 598:	8b 00                	mov    (%eax),%eax
 59a:	0f be c0             	movsbl %al,%eax
 59d:	83 ec 08             	sub    $0x8,%esp
 5a0:	50                   	push   %eax
 5a1:	ff 75 08             	push   0x8(%ebp)
 5a4:	e8 fb fd ff ff       	call   3a4 <putc>
 5a9:	83 c4 10             	add    $0x10,%esp
        ap++;
 5ac:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5b0:	eb 42                	jmp    5f4 <printf+0x174>
      } else if(c == '%'){
 5b2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5b6:	75 17                	jne    5cf <printf+0x14f>
        putc(fd, c);
 5b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5bb:	0f be c0             	movsbl %al,%eax
 5be:	83 ec 08             	sub    $0x8,%esp
 5c1:	50                   	push   %eax
 5c2:	ff 75 08             	push   0x8(%ebp)
 5c5:	e8 da fd ff ff       	call   3a4 <putc>
 5ca:	83 c4 10             	add    $0x10,%esp
 5cd:	eb 25                	jmp    5f4 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5cf:	83 ec 08             	sub    $0x8,%esp
 5d2:	6a 25                	push   $0x25
 5d4:	ff 75 08             	push   0x8(%ebp)
 5d7:	e8 c8 fd ff ff       	call   3a4 <putc>
 5dc:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5e2:	0f be c0             	movsbl %al,%eax
 5e5:	83 ec 08             	sub    $0x8,%esp
 5e8:	50                   	push   %eax
 5e9:	ff 75 08             	push   0x8(%ebp)
 5ec:	e8 b3 fd ff ff       	call   3a4 <putc>
 5f1:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5f4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5fb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5ff:	8b 55 0c             	mov    0xc(%ebp),%edx
 602:	8b 45 f0             	mov    -0x10(%ebp),%eax
 605:	01 d0                	add    %edx,%eax
 607:	0f b6 00             	movzbl (%eax),%eax
 60a:	84 c0                	test   %al,%al
 60c:	0f 85 94 fe ff ff    	jne    4a6 <printf+0x26>
    }
  }
}
 612:	90                   	nop
 613:	90                   	nop
 614:	c9                   	leave
 615:	c3                   	ret

00000616 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 616:	f3 0f 1e fb          	endbr32
 61a:	55                   	push   %ebp
 61b:	89 e5                	mov    %esp,%ebp
 61d:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 620:	8b 45 08             	mov    0x8(%ebp),%eax
 623:	83 e8 08             	sub    $0x8,%eax
 626:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 629:	a1 bc 0a 00 00       	mov    0xabc,%eax
 62e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 631:	eb 24                	jmp    657 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 633:	8b 45 fc             	mov    -0x4(%ebp),%eax
 636:	8b 00                	mov    (%eax),%eax
 638:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 63b:	72 12                	jb     64f <free+0x39>
 63d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 640:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 643:	77 24                	ja     669 <free+0x53>
 645:	8b 45 fc             	mov    -0x4(%ebp),%eax
 648:	8b 00                	mov    (%eax),%eax
 64a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 64d:	72 1a                	jb     669 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 64f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 652:	8b 00                	mov    (%eax),%eax
 654:	89 45 fc             	mov    %eax,-0x4(%ebp)
 657:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 65d:	76 d4                	jbe    633 <free+0x1d>
 65f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 662:	8b 00                	mov    (%eax),%eax
 664:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 667:	73 ca                	jae    633 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 669:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66c:	8b 40 04             	mov    0x4(%eax),%eax
 66f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 676:	8b 45 f8             	mov    -0x8(%ebp),%eax
 679:	01 c2                	add    %eax,%edx
 67b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67e:	8b 00                	mov    (%eax),%eax
 680:	39 c2                	cmp    %eax,%edx
 682:	75 24                	jne    6a8 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 684:	8b 45 f8             	mov    -0x8(%ebp),%eax
 687:	8b 50 04             	mov    0x4(%eax),%edx
 68a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68d:	8b 00                	mov    (%eax),%eax
 68f:	8b 40 04             	mov    0x4(%eax),%eax
 692:	01 c2                	add    %eax,%edx
 694:	8b 45 f8             	mov    -0x8(%ebp),%eax
 697:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 69a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69d:	8b 00                	mov    (%eax),%eax
 69f:	8b 10                	mov    (%eax),%edx
 6a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a4:	89 10                	mov    %edx,(%eax)
 6a6:	eb 0a                	jmp    6b2 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 6a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ab:	8b 10                	mov    (%eax),%edx
 6ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b0:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b5:	8b 40 04             	mov    0x4(%eax),%eax
 6b8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c2:	01 d0                	add    %edx,%eax
 6c4:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6c7:	75 20                	jne    6e9 <free+0xd3>
    p->s.size += bp->s.size;
 6c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cc:	8b 50 04             	mov    0x4(%eax),%edx
 6cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d2:	8b 40 04             	mov    0x4(%eax),%eax
 6d5:	01 c2                	add    %eax,%edx
 6d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6da:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e0:	8b 10                	mov    (%eax),%edx
 6e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e5:	89 10                	mov    %edx,(%eax)
 6e7:	eb 08                	jmp    6f1 <free+0xdb>
  } else
    p->s.ptr = bp;
 6e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ec:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6ef:	89 10                	mov    %edx,(%eax)
  freep = p;
 6f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f4:	a3 bc 0a 00 00       	mov    %eax,0xabc
}
 6f9:	90                   	nop
 6fa:	c9                   	leave
 6fb:	c3                   	ret

000006fc <morecore>:

static Header*
morecore(uint nu)
{
 6fc:	f3 0f 1e fb          	endbr32
 700:	55                   	push   %ebp
 701:	89 e5                	mov    %esp,%ebp
 703:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 706:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 70d:	77 07                	ja     716 <morecore+0x1a>
    nu = 4096;
 70f:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 716:	8b 45 08             	mov    0x8(%ebp),%eax
 719:	c1 e0 03             	shl    $0x3,%eax
 71c:	83 ec 0c             	sub    $0xc,%esp
 71f:	50                   	push   %eax
 720:	e8 47 fc ff ff       	call   36c <sbrk>
 725:	83 c4 10             	add    $0x10,%esp
 728:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 72b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 72f:	75 07                	jne    738 <morecore+0x3c>
    return 0;
 731:	b8 00 00 00 00       	mov    $0x0,%eax
 736:	eb 26                	jmp    75e <morecore+0x62>
  hp = (Header*)p;
 738:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 73e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 741:	8b 55 08             	mov    0x8(%ebp),%edx
 744:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 747:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74a:	83 c0 08             	add    $0x8,%eax
 74d:	83 ec 0c             	sub    $0xc,%esp
 750:	50                   	push   %eax
 751:	e8 c0 fe ff ff       	call   616 <free>
 756:	83 c4 10             	add    $0x10,%esp
  return freep;
 759:	a1 bc 0a 00 00       	mov    0xabc,%eax
}
 75e:	c9                   	leave
 75f:	c3                   	ret

00000760 <malloc>:

void*
malloc(uint nbytes)
{
 760:	f3 0f 1e fb          	endbr32
 764:	55                   	push   %ebp
 765:	89 e5                	mov    %esp,%ebp
 767:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 76a:	8b 45 08             	mov    0x8(%ebp),%eax
 76d:	83 c0 07             	add    $0x7,%eax
 770:	c1 e8 03             	shr    $0x3,%eax
 773:	83 c0 01             	add    $0x1,%eax
 776:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 779:	a1 bc 0a 00 00       	mov    0xabc,%eax
 77e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 781:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 785:	75 23                	jne    7aa <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 787:	c7 45 f0 b4 0a 00 00 	movl   $0xab4,-0x10(%ebp)
 78e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 791:	a3 bc 0a 00 00       	mov    %eax,0xabc
 796:	a1 bc 0a 00 00       	mov    0xabc,%eax
 79b:	a3 b4 0a 00 00       	mov    %eax,0xab4
    base.s.size = 0;
 7a0:	c7 05 b8 0a 00 00 00 	movl   $0x0,0xab8
 7a7:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ad:	8b 00                	mov    (%eax),%eax
 7af:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b5:	8b 40 04             	mov    0x4(%eax),%eax
 7b8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7bb:	77 4d                	ja     80a <malloc+0xaa>
      if(p->s.size == nunits)
 7bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c0:	8b 40 04             	mov    0x4(%eax),%eax
 7c3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7c6:	75 0c                	jne    7d4 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 7c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cb:	8b 10                	mov    (%eax),%edx
 7cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d0:	89 10                	mov    %edx,(%eax)
 7d2:	eb 26                	jmp    7fa <malloc+0x9a>
      else {
        p->s.size -= nunits;
 7d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d7:	8b 40 04             	mov    0x4(%eax),%eax
 7da:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7dd:	89 c2                	mov    %eax,%edx
 7df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e2:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e8:	8b 40 04             	mov    0x4(%eax),%eax
 7eb:	c1 e0 03             	shl    $0x3,%eax
 7ee:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f4:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7f7:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fd:	a3 bc 0a 00 00       	mov    %eax,0xabc
      return (void*)(p + 1);
 802:	8b 45 f4             	mov    -0xc(%ebp),%eax
 805:	83 c0 08             	add    $0x8,%eax
 808:	eb 3b                	jmp    845 <malloc+0xe5>
    }
    if(p == freep)
 80a:	a1 bc 0a 00 00       	mov    0xabc,%eax
 80f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 812:	75 1e                	jne    832 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 814:	83 ec 0c             	sub    $0xc,%esp
 817:	ff 75 ec             	push   -0x14(%ebp)
 81a:	e8 dd fe ff ff       	call   6fc <morecore>
 81f:	83 c4 10             	add    $0x10,%esp
 822:	89 45 f4             	mov    %eax,-0xc(%ebp)
 825:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 829:	75 07                	jne    832 <malloc+0xd2>
        return 0;
 82b:	b8 00 00 00 00       	mov    $0x0,%eax
 830:	eb 13                	jmp    845 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 832:	8b 45 f4             	mov    -0xc(%ebp),%eax
 835:	89 45 f0             	mov    %eax,-0x10(%ebp)
 838:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83b:	8b 00                	mov    (%eax),%eax
 83d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 840:	e9 6d ff ff ff       	jmp    7b2 <malloc+0x52>
  }
}
 845:	c9                   	leave
 846:	c3                   	ret
