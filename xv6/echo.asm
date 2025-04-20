
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
  2b:	b9 37 08 00 00       	mov    $0x837,%ecx
  30:	eb 05                	jmp    37 <main+0x37>
  32:	b9 39 08 00 00       	mov    $0x839,%ecx
  37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  3a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  41:	8b 43 04             	mov    0x4(%ebx),%eax
  44:	01 d0                	add    %edx,%eax
  46:	8b 00                	mov    (%eax),%eax
  48:	51                   	push   %ecx
  49:	50                   	push   %eax
  4a:	68 3b 08 00 00       	push   $0x83b
  4f:	6a 01                	push   $0x1
  51:	e8 1a 04 00 00       	call   470 <printf>
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

00000384 <uthread_init>:

SYSCALL(uthread_init)
 384:	b8 16 00 00 00       	mov    $0x16,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret

0000038c <thread_count>:
SYSCALL(thread_count)
 38c:	b8 17 00 00 00       	mov    $0x17,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret

00000394 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 394:	f3 0f 1e fb          	endbr32
 398:	55                   	push   %ebp
 399:	89 e5                	mov    %esp,%ebp
 39b:	83 ec 18             	sub    $0x18,%esp
 39e:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3a4:	83 ec 04             	sub    $0x4,%esp
 3a7:	6a 01                	push   $0x1
 3a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3ac:	50                   	push   %eax
 3ad:	ff 75 08             	push   0x8(%ebp)
 3b0:	e8 4f ff ff ff       	call   304 <write>
 3b5:	83 c4 10             	add    $0x10,%esp
}
 3b8:	90                   	nop
 3b9:	c9                   	leave
 3ba:	c3                   	ret

000003bb <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3bb:	f3 0f 1e fb          	endbr32
 3bf:	55                   	push   %ebp
 3c0:	89 e5                	mov    %esp,%ebp
 3c2:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3c5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3cc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3d0:	74 17                	je     3e9 <printint+0x2e>
 3d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3d6:	79 11                	jns    3e9 <printint+0x2e>
    neg = 1;
 3d8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3df:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e2:	f7 d8                	neg    %eax
 3e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3e7:	eb 06                	jmp    3ef <printint+0x34>
  } else {
    x = xx;
 3e9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3fc:	ba 00 00 00 00       	mov    $0x0,%edx
 401:	f7 f1                	div    %ecx
 403:	89 d1                	mov    %edx,%ecx
 405:	8b 45 f4             	mov    -0xc(%ebp),%eax
 408:	8d 50 01             	lea    0x1(%eax),%edx
 40b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 40e:	0f b6 91 90 0a 00 00 	movzbl 0xa90(%ecx),%edx
 415:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 419:	8b 4d 10             	mov    0x10(%ebp),%ecx
 41c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 41f:	ba 00 00 00 00       	mov    $0x0,%edx
 424:	f7 f1                	div    %ecx
 426:	89 45 ec             	mov    %eax,-0x14(%ebp)
 429:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 42d:	75 c7                	jne    3f6 <printint+0x3b>
  if(neg)
 42f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 433:	74 2d                	je     462 <printint+0xa7>
    buf[i++] = '-';
 435:	8b 45 f4             	mov    -0xc(%ebp),%eax
 438:	8d 50 01             	lea    0x1(%eax),%edx
 43b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 43e:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 443:	eb 1d                	jmp    462 <printint+0xa7>
    putc(fd, buf[i]);
 445:	8d 55 dc             	lea    -0x24(%ebp),%edx
 448:	8b 45 f4             	mov    -0xc(%ebp),%eax
 44b:	01 d0                	add    %edx,%eax
 44d:	0f b6 00             	movzbl (%eax),%eax
 450:	0f be c0             	movsbl %al,%eax
 453:	83 ec 08             	sub    $0x8,%esp
 456:	50                   	push   %eax
 457:	ff 75 08             	push   0x8(%ebp)
 45a:	e8 35 ff ff ff       	call   394 <putc>
 45f:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 462:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 466:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 46a:	79 d9                	jns    445 <printint+0x8a>
}
 46c:	90                   	nop
 46d:	90                   	nop
 46e:	c9                   	leave
 46f:	c3                   	ret

00000470 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 470:	f3 0f 1e fb          	endbr32
 474:	55                   	push   %ebp
 475:	89 e5                	mov    %esp,%ebp
 477:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 47a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 481:	8d 45 0c             	lea    0xc(%ebp),%eax
 484:	83 c0 04             	add    $0x4,%eax
 487:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 48a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 491:	e9 59 01 00 00       	jmp    5ef <printf+0x17f>
    c = fmt[i] & 0xff;
 496:	8b 55 0c             	mov    0xc(%ebp),%edx
 499:	8b 45 f0             	mov    -0x10(%ebp),%eax
 49c:	01 d0                	add    %edx,%eax
 49e:	0f b6 00             	movzbl (%eax),%eax
 4a1:	0f be c0             	movsbl %al,%eax
 4a4:	25 ff 00 00 00       	and    $0xff,%eax
 4a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4ac:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4b0:	75 2c                	jne    4de <printf+0x6e>
      if(c == '%'){
 4b2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4b6:	75 0c                	jne    4c4 <printf+0x54>
        state = '%';
 4b8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4bf:	e9 27 01 00 00       	jmp    5eb <printf+0x17b>
      } else {
        putc(fd, c);
 4c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4c7:	0f be c0             	movsbl %al,%eax
 4ca:	83 ec 08             	sub    $0x8,%esp
 4cd:	50                   	push   %eax
 4ce:	ff 75 08             	push   0x8(%ebp)
 4d1:	e8 be fe ff ff       	call   394 <putc>
 4d6:	83 c4 10             	add    $0x10,%esp
 4d9:	e9 0d 01 00 00       	jmp    5eb <printf+0x17b>
      }
    } else if(state == '%'){
 4de:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4e2:	0f 85 03 01 00 00    	jne    5eb <printf+0x17b>
      if(c == 'd'){
 4e8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4ec:	75 1e                	jne    50c <printf+0x9c>
        printint(fd, *ap, 10, 1);
 4ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4f1:	8b 00                	mov    (%eax),%eax
 4f3:	6a 01                	push   $0x1
 4f5:	6a 0a                	push   $0xa
 4f7:	50                   	push   %eax
 4f8:	ff 75 08             	push   0x8(%ebp)
 4fb:	e8 bb fe ff ff       	call   3bb <printint>
 500:	83 c4 10             	add    $0x10,%esp
        ap++;
 503:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 507:	e9 d8 00 00 00       	jmp    5e4 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 50c:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 510:	74 06                	je     518 <printf+0xa8>
 512:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 516:	75 1e                	jne    536 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 518:	8b 45 e8             	mov    -0x18(%ebp),%eax
 51b:	8b 00                	mov    (%eax),%eax
 51d:	6a 00                	push   $0x0
 51f:	6a 10                	push   $0x10
 521:	50                   	push   %eax
 522:	ff 75 08             	push   0x8(%ebp)
 525:	e8 91 fe ff ff       	call   3bb <printint>
 52a:	83 c4 10             	add    $0x10,%esp
        ap++;
 52d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 531:	e9 ae 00 00 00       	jmp    5e4 <printf+0x174>
      } else if(c == 's'){
 536:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 53a:	75 43                	jne    57f <printf+0x10f>
        s = (char*)*ap;
 53c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 53f:	8b 00                	mov    (%eax),%eax
 541:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 544:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 548:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 54c:	75 25                	jne    573 <printf+0x103>
          s = "(null)";
 54e:	c7 45 f4 40 08 00 00 	movl   $0x840,-0xc(%ebp)
        while(*s != 0){
 555:	eb 1c                	jmp    573 <printf+0x103>
          putc(fd, *s);
 557:	8b 45 f4             	mov    -0xc(%ebp),%eax
 55a:	0f b6 00             	movzbl (%eax),%eax
 55d:	0f be c0             	movsbl %al,%eax
 560:	83 ec 08             	sub    $0x8,%esp
 563:	50                   	push   %eax
 564:	ff 75 08             	push   0x8(%ebp)
 567:	e8 28 fe ff ff       	call   394 <putc>
 56c:	83 c4 10             	add    $0x10,%esp
          s++;
 56f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 573:	8b 45 f4             	mov    -0xc(%ebp),%eax
 576:	0f b6 00             	movzbl (%eax),%eax
 579:	84 c0                	test   %al,%al
 57b:	75 da                	jne    557 <printf+0xe7>
 57d:	eb 65                	jmp    5e4 <printf+0x174>
        }
      } else if(c == 'c'){
 57f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 583:	75 1d                	jne    5a2 <printf+0x132>
        putc(fd, *ap);
 585:	8b 45 e8             	mov    -0x18(%ebp),%eax
 588:	8b 00                	mov    (%eax),%eax
 58a:	0f be c0             	movsbl %al,%eax
 58d:	83 ec 08             	sub    $0x8,%esp
 590:	50                   	push   %eax
 591:	ff 75 08             	push   0x8(%ebp)
 594:	e8 fb fd ff ff       	call   394 <putc>
 599:	83 c4 10             	add    $0x10,%esp
        ap++;
 59c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a0:	eb 42                	jmp    5e4 <printf+0x174>
      } else if(c == '%'){
 5a2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5a6:	75 17                	jne    5bf <printf+0x14f>
        putc(fd, c);
 5a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ab:	0f be c0             	movsbl %al,%eax
 5ae:	83 ec 08             	sub    $0x8,%esp
 5b1:	50                   	push   %eax
 5b2:	ff 75 08             	push   0x8(%ebp)
 5b5:	e8 da fd ff ff       	call   394 <putc>
 5ba:	83 c4 10             	add    $0x10,%esp
 5bd:	eb 25                	jmp    5e4 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5bf:	83 ec 08             	sub    $0x8,%esp
 5c2:	6a 25                	push   $0x25
 5c4:	ff 75 08             	push   0x8(%ebp)
 5c7:	e8 c8 fd ff ff       	call   394 <putc>
 5cc:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5d2:	0f be c0             	movsbl %al,%eax
 5d5:	83 ec 08             	sub    $0x8,%esp
 5d8:	50                   	push   %eax
 5d9:	ff 75 08             	push   0x8(%ebp)
 5dc:	e8 b3 fd ff ff       	call   394 <putc>
 5e1:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5e4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5eb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5ef:	8b 55 0c             	mov    0xc(%ebp),%edx
 5f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5f5:	01 d0                	add    %edx,%eax
 5f7:	0f b6 00             	movzbl (%eax),%eax
 5fa:	84 c0                	test   %al,%al
 5fc:	0f 85 94 fe ff ff    	jne    496 <printf+0x26>
    }
  }
}
 602:	90                   	nop
 603:	90                   	nop
 604:	c9                   	leave
 605:	c3                   	ret

00000606 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 606:	f3 0f 1e fb          	endbr32
 60a:	55                   	push   %ebp
 60b:	89 e5                	mov    %esp,%ebp
 60d:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 610:	8b 45 08             	mov    0x8(%ebp),%eax
 613:	83 e8 08             	sub    $0x8,%eax
 616:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 619:	a1 ac 0a 00 00       	mov    0xaac,%eax
 61e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 621:	eb 24                	jmp    647 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 623:	8b 45 fc             	mov    -0x4(%ebp),%eax
 626:	8b 00                	mov    (%eax),%eax
 628:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 62b:	72 12                	jb     63f <free+0x39>
 62d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 630:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 633:	77 24                	ja     659 <free+0x53>
 635:	8b 45 fc             	mov    -0x4(%ebp),%eax
 638:	8b 00                	mov    (%eax),%eax
 63a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 63d:	72 1a                	jb     659 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 63f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 642:	8b 00                	mov    (%eax),%eax
 644:	89 45 fc             	mov    %eax,-0x4(%ebp)
 647:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 64d:	76 d4                	jbe    623 <free+0x1d>
 64f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 652:	8b 00                	mov    (%eax),%eax
 654:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 657:	73 ca                	jae    623 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 659:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65c:	8b 40 04             	mov    0x4(%eax),%eax
 65f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 666:	8b 45 f8             	mov    -0x8(%ebp),%eax
 669:	01 c2                	add    %eax,%edx
 66b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66e:	8b 00                	mov    (%eax),%eax
 670:	39 c2                	cmp    %eax,%edx
 672:	75 24                	jne    698 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 674:	8b 45 f8             	mov    -0x8(%ebp),%eax
 677:	8b 50 04             	mov    0x4(%eax),%edx
 67a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67d:	8b 00                	mov    (%eax),%eax
 67f:	8b 40 04             	mov    0x4(%eax),%eax
 682:	01 c2                	add    %eax,%edx
 684:	8b 45 f8             	mov    -0x8(%ebp),%eax
 687:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 68a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68d:	8b 00                	mov    (%eax),%eax
 68f:	8b 10                	mov    (%eax),%edx
 691:	8b 45 f8             	mov    -0x8(%ebp),%eax
 694:	89 10                	mov    %edx,(%eax)
 696:	eb 0a                	jmp    6a2 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 698:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69b:	8b 10                	mov    (%eax),%edx
 69d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a0:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a5:	8b 40 04             	mov    0x4(%eax),%eax
 6a8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b2:	01 d0                	add    %edx,%eax
 6b4:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6b7:	75 20                	jne    6d9 <free+0xd3>
    p->s.size += bp->s.size;
 6b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bc:	8b 50 04             	mov    0x4(%eax),%edx
 6bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c2:	8b 40 04             	mov    0x4(%eax),%eax
 6c5:	01 c2                	add    %eax,%edx
 6c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ca:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d0:	8b 10                	mov    (%eax),%edx
 6d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d5:	89 10                	mov    %edx,(%eax)
 6d7:	eb 08                	jmp    6e1 <free+0xdb>
  } else
    p->s.ptr = bp;
 6d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6df:	89 10                	mov    %edx,(%eax)
  freep = p;
 6e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e4:	a3 ac 0a 00 00       	mov    %eax,0xaac
}
 6e9:	90                   	nop
 6ea:	c9                   	leave
 6eb:	c3                   	ret

000006ec <morecore>:

static Header*
morecore(uint nu)
{
 6ec:	f3 0f 1e fb          	endbr32
 6f0:	55                   	push   %ebp
 6f1:	89 e5                	mov    %esp,%ebp
 6f3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6f6:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6fd:	77 07                	ja     706 <morecore+0x1a>
    nu = 4096;
 6ff:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 706:	8b 45 08             	mov    0x8(%ebp),%eax
 709:	c1 e0 03             	shl    $0x3,%eax
 70c:	83 ec 0c             	sub    $0xc,%esp
 70f:	50                   	push   %eax
 710:	e8 57 fc ff ff       	call   36c <sbrk>
 715:	83 c4 10             	add    $0x10,%esp
 718:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 71b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 71f:	75 07                	jne    728 <morecore+0x3c>
    return 0;
 721:	b8 00 00 00 00       	mov    $0x0,%eax
 726:	eb 26                	jmp    74e <morecore+0x62>
  hp = (Header*)p;
 728:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 72e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 731:	8b 55 08             	mov    0x8(%ebp),%edx
 734:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 737:	8b 45 f0             	mov    -0x10(%ebp),%eax
 73a:	83 c0 08             	add    $0x8,%eax
 73d:	83 ec 0c             	sub    $0xc,%esp
 740:	50                   	push   %eax
 741:	e8 c0 fe ff ff       	call   606 <free>
 746:	83 c4 10             	add    $0x10,%esp
  return freep;
 749:	a1 ac 0a 00 00       	mov    0xaac,%eax
}
 74e:	c9                   	leave
 74f:	c3                   	ret

00000750 <malloc>:

void*
malloc(uint nbytes)
{
 750:	f3 0f 1e fb          	endbr32
 754:	55                   	push   %ebp
 755:	89 e5                	mov    %esp,%ebp
 757:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 75a:	8b 45 08             	mov    0x8(%ebp),%eax
 75d:	83 c0 07             	add    $0x7,%eax
 760:	c1 e8 03             	shr    $0x3,%eax
 763:	83 c0 01             	add    $0x1,%eax
 766:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 769:	a1 ac 0a 00 00       	mov    0xaac,%eax
 76e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 771:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 775:	75 23                	jne    79a <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 777:	c7 45 f0 a4 0a 00 00 	movl   $0xaa4,-0x10(%ebp)
 77e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 781:	a3 ac 0a 00 00       	mov    %eax,0xaac
 786:	a1 ac 0a 00 00       	mov    0xaac,%eax
 78b:	a3 a4 0a 00 00       	mov    %eax,0xaa4
    base.s.size = 0;
 790:	c7 05 a8 0a 00 00 00 	movl   $0x0,0xaa8
 797:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 79a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79d:	8b 00                	mov    (%eax),%eax
 79f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a5:	8b 40 04             	mov    0x4(%eax),%eax
 7a8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7ab:	77 4d                	ja     7fa <malloc+0xaa>
      if(p->s.size == nunits)
 7ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b0:	8b 40 04             	mov    0x4(%eax),%eax
 7b3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7b6:	75 0c                	jne    7c4 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 7b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bb:	8b 10                	mov    (%eax),%edx
 7bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c0:	89 10                	mov    %edx,(%eax)
 7c2:	eb 26                	jmp    7ea <malloc+0x9a>
      else {
        p->s.size -= nunits;
 7c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c7:	8b 40 04             	mov    0x4(%eax),%eax
 7ca:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7cd:	89 c2                	mov    %eax,%edx
 7cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d2:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d8:	8b 40 04             	mov    0x4(%eax),%eax
 7db:	c1 e0 03             	shl    $0x3,%eax
 7de:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e4:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7e7:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ed:	a3 ac 0a 00 00       	mov    %eax,0xaac
      return (void*)(p + 1);
 7f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f5:	83 c0 08             	add    $0x8,%eax
 7f8:	eb 3b                	jmp    835 <malloc+0xe5>
    }
    if(p == freep)
 7fa:	a1 ac 0a 00 00       	mov    0xaac,%eax
 7ff:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 802:	75 1e                	jne    822 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 804:	83 ec 0c             	sub    $0xc,%esp
 807:	ff 75 ec             	push   -0x14(%ebp)
 80a:	e8 dd fe ff ff       	call   6ec <morecore>
 80f:	83 c4 10             	add    $0x10,%esp
 812:	89 45 f4             	mov    %eax,-0xc(%ebp)
 815:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 819:	75 07                	jne    822 <malloc+0xd2>
        return 0;
 81b:	b8 00 00 00 00       	mov    $0x0,%eax
 820:	eb 13                	jmp    835 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 822:	8b 45 f4             	mov    -0xc(%ebp),%eax
 825:	89 45 f0             	mov    %eax,-0x10(%ebp)
 828:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82b:	8b 00                	mov    (%eax),%eax
 82d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 830:	e9 6d ff ff ff       	jmp    7a2 <malloc+0x52>
  }
}
 835:	c9                   	leave
 836:	c3                   	ret
