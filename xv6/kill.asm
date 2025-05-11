
_kill:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
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

  if(argc < 2){
  18:	83 3b 01             	cmpl   $0x1,(%ebx)
  1b:	7f 17                	jg     34 <main+0x34>
    printf(2, "usage: kill pid...\n");
  1d:	83 ec 08             	sub    $0x8,%esp
  20:	68 54 08 00 00       	push   $0x854
  25:	6a 02                	push   $0x2
  27:	e8 61 04 00 00       	call   48d <printf>
  2c:	83 c4 10             	add    $0x10,%esp
    exit();
  2f:	e8 bd 02 00 00       	call   2f1 <exit>
  }
  for(i=1; i<argc; i++)
  34:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  3b:	eb 2d                	jmp    6a <main+0x6a>
    kill(atoi(argv[i]));
  3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  40:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  47:	8b 43 04             	mov    0x4(%ebx),%eax
  4a:	01 d0                	add    %edx,%eax
  4c:	8b 00                	mov    (%eax),%eax
  4e:	83 ec 0c             	sub    $0xc,%esp
  51:	50                   	push   %eax
  52:	e8 00 02 00 00       	call   257 <atoi>
  57:	83 c4 10             	add    $0x10,%esp
  5a:	83 ec 0c             	sub    $0xc,%esp
  5d:	50                   	push   %eax
  5e:	e8 be 02 00 00       	call   321 <kill>
  63:	83 c4 10             	add    $0x10,%esp
  for(i=1; i<argc; i++)
  66:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6d:	3b 03                	cmp    (%ebx),%eax
  6f:	7c cc                	jl     3d <main+0x3d>
  exit();
  71:	e8 7b 02 00 00       	call   2f1 <exit>

00000076 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  76:	55                   	push   %ebp
  77:	89 e5                	mov    %esp,%ebp
  79:	57                   	push   %edi
  7a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  7e:	8b 55 10             	mov    0x10(%ebp),%edx
  81:	8b 45 0c             	mov    0xc(%ebp),%eax
  84:	89 cb                	mov    %ecx,%ebx
  86:	89 df                	mov    %ebx,%edi
  88:	89 d1                	mov    %edx,%ecx
  8a:	fc                   	cld
  8b:	f3 aa                	rep stos %al,%es:(%edi)
  8d:	89 ca                	mov    %ecx,%edx
  8f:	89 fb                	mov    %edi,%ebx
  91:	89 5d 08             	mov    %ebx,0x8(%ebp)
  94:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  97:	90                   	nop
  98:	5b                   	pop    %ebx
  99:	5f                   	pop    %edi
  9a:	5d                   	pop    %ebp
  9b:	c3                   	ret

0000009c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  9c:	f3 0f 1e fb          	endbr32
  a0:	55                   	push   %ebp
  a1:	89 e5                	mov    %esp,%ebp
  a3:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  a6:	8b 45 08             	mov    0x8(%ebp),%eax
  a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  ac:	90                   	nop
  ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  b0:	8d 42 01             	lea    0x1(%edx),%eax
  b3:	89 45 0c             	mov    %eax,0xc(%ebp)
  b6:	8b 45 08             	mov    0x8(%ebp),%eax
  b9:	8d 48 01             	lea    0x1(%eax),%ecx
  bc:	89 4d 08             	mov    %ecx,0x8(%ebp)
  bf:	0f b6 12             	movzbl (%edx),%edx
  c2:	88 10                	mov    %dl,(%eax)
  c4:	0f b6 00             	movzbl (%eax),%eax
  c7:	84 c0                	test   %al,%al
  c9:	75 e2                	jne    ad <strcpy+0x11>
    ;
  return os;
  cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  ce:	c9                   	leave
  cf:	c3                   	ret

000000d0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d0:	f3 0f 1e fb          	endbr32
  d4:	55                   	push   %ebp
  d5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  d7:	eb 08                	jmp    e1 <strcmp+0x11>
    p++, q++;
  d9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  dd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  e1:	8b 45 08             	mov    0x8(%ebp),%eax
  e4:	0f b6 00             	movzbl (%eax),%eax
  e7:	84 c0                	test   %al,%al
  e9:	74 10                	je     fb <strcmp+0x2b>
  eb:	8b 45 08             	mov    0x8(%ebp),%eax
  ee:	0f b6 10             	movzbl (%eax),%edx
  f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  f4:	0f b6 00             	movzbl (%eax),%eax
  f7:	38 c2                	cmp    %al,%dl
  f9:	74 de                	je     d9 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
  fb:	8b 45 08             	mov    0x8(%ebp),%eax
  fe:	0f b6 00             	movzbl (%eax),%eax
 101:	0f b6 d0             	movzbl %al,%edx
 104:	8b 45 0c             	mov    0xc(%ebp),%eax
 107:	0f b6 00             	movzbl (%eax),%eax
 10a:	0f b6 c0             	movzbl %al,%eax
 10d:	29 c2                	sub    %eax,%edx
 10f:	89 d0                	mov    %edx,%eax
}
 111:	5d                   	pop    %ebp
 112:	c3                   	ret

00000113 <strlen>:

uint
strlen(char *s)
{
 113:	f3 0f 1e fb          	endbr32
 117:	55                   	push   %ebp
 118:	89 e5                	mov    %esp,%ebp
 11a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 11d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 124:	eb 04                	jmp    12a <strlen+0x17>
 126:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 12a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 12d:	8b 45 08             	mov    0x8(%ebp),%eax
 130:	01 d0                	add    %edx,%eax
 132:	0f b6 00             	movzbl (%eax),%eax
 135:	84 c0                	test   %al,%al
 137:	75 ed                	jne    126 <strlen+0x13>
    ;
  return n;
 139:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 13c:	c9                   	leave
 13d:	c3                   	ret

0000013e <memset>:

void*
memset(void *dst, int c, uint n)
{
 13e:	f3 0f 1e fb          	endbr32
 142:	55                   	push   %ebp
 143:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 145:	8b 45 10             	mov    0x10(%ebp),%eax
 148:	50                   	push   %eax
 149:	ff 75 0c             	push   0xc(%ebp)
 14c:	ff 75 08             	push   0x8(%ebp)
 14f:	e8 22 ff ff ff       	call   76 <stosb>
 154:	83 c4 0c             	add    $0xc,%esp
  return dst;
 157:	8b 45 08             	mov    0x8(%ebp),%eax
}
 15a:	c9                   	leave
 15b:	c3                   	ret

0000015c <strchr>:

char*
strchr(const char *s, char c)
{
 15c:	f3 0f 1e fb          	endbr32
 160:	55                   	push   %ebp
 161:	89 e5                	mov    %esp,%ebp
 163:	83 ec 04             	sub    $0x4,%esp
 166:	8b 45 0c             	mov    0xc(%ebp),%eax
 169:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 16c:	eb 14                	jmp    182 <strchr+0x26>
    if(*s == c)
 16e:	8b 45 08             	mov    0x8(%ebp),%eax
 171:	0f b6 00             	movzbl (%eax),%eax
 174:	38 45 fc             	cmp    %al,-0x4(%ebp)
 177:	75 05                	jne    17e <strchr+0x22>
      return (char*)s;
 179:	8b 45 08             	mov    0x8(%ebp),%eax
 17c:	eb 13                	jmp    191 <strchr+0x35>
  for(; *s; s++)
 17e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 182:	8b 45 08             	mov    0x8(%ebp),%eax
 185:	0f b6 00             	movzbl (%eax),%eax
 188:	84 c0                	test   %al,%al
 18a:	75 e2                	jne    16e <strchr+0x12>
  return 0;
 18c:	b8 00 00 00 00       	mov    $0x0,%eax
}
 191:	c9                   	leave
 192:	c3                   	ret

00000193 <gets>:

char*
gets(char *buf, int max)
{
 193:	f3 0f 1e fb          	endbr32
 197:	55                   	push   %ebp
 198:	89 e5                	mov    %esp,%ebp
 19a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1a4:	eb 42                	jmp    1e8 <gets+0x55>
    cc = read(0, &c, 1);
 1a6:	83 ec 04             	sub    $0x4,%esp
 1a9:	6a 01                	push   $0x1
 1ab:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1ae:	50                   	push   %eax
 1af:	6a 00                	push   $0x0
 1b1:	e8 53 01 00 00       	call   309 <read>
 1b6:	83 c4 10             	add    $0x10,%esp
 1b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1c0:	7e 33                	jle    1f5 <gets+0x62>
      break;
    buf[i++] = c;
 1c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c5:	8d 50 01             	lea    0x1(%eax),%edx
 1c8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1cb:	89 c2                	mov    %eax,%edx
 1cd:	8b 45 08             	mov    0x8(%ebp),%eax
 1d0:	01 c2                	add    %eax,%edx
 1d2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d6:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1d8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1dc:	3c 0a                	cmp    $0xa,%al
 1de:	74 16                	je     1f6 <gets+0x63>
 1e0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e4:	3c 0d                	cmp    $0xd,%al
 1e6:	74 0e                	je     1f6 <gets+0x63>
  for(i=0; i+1 < max; ){
 1e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1eb:	83 c0 01             	add    $0x1,%eax
 1ee:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1f1:	7f b3                	jg     1a6 <gets+0x13>
 1f3:	eb 01                	jmp    1f6 <gets+0x63>
      break;
 1f5:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1f9:	8b 45 08             	mov    0x8(%ebp),%eax
 1fc:	01 d0                	add    %edx,%eax
 1fe:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 201:	8b 45 08             	mov    0x8(%ebp),%eax
}
 204:	c9                   	leave
 205:	c3                   	ret

00000206 <stat>:

int
stat(char *n, struct stat *st)
{
 206:	f3 0f 1e fb          	endbr32
 20a:	55                   	push   %ebp
 20b:	89 e5                	mov    %esp,%ebp
 20d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 210:	83 ec 08             	sub    $0x8,%esp
 213:	6a 00                	push   $0x0
 215:	ff 75 08             	push   0x8(%ebp)
 218:	e8 14 01 00 00       	call   331 <open>
 21d:	83 c4 10             	add    $0x10,%esp
 220:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 223:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 227:	79 07                	jns    230 <stat+0x2a>
    return -1;
 229:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 22e:	eb 25                	jmp    255 <stat+0x4f>
  r = fstat(fd, st);
 230:	83 ec 08             	sub    $0x8,%esp
 233:	ff 75 0c             	push   0xc(%ebp)
 236:	ff 75 f4             	push   -0xc(%ebp)
 239:	e8 0b 01 00 00       	call   349 <fstat>
 23e:	83 c4 10             	add    $0x10,%esp
 241:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 244:	83 ec 0c             	sub    $0xc,%esp
 247:	ff 75 f4             	push   -0xc(%ebp)
 24a:	e8 ca 00 00 00       	call   319 <close>
 24f:	83 c4 10             	add    $0x10,%esp
  return r;
 252:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 255:	c9                   	leave
 256:	c3                   	ret

00000257 <atoi>:

int
atoi(const char *s)
{
 257:	f3 0f 1e fb          	endbr32
 25b:	55                   	push   %ebp
 25c:	89 e5                	mov    %esp,%ebp
 25e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 261:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 268:	eb 25                	jmp    28f <atoi+0x38>
    n = n*10 + *s++ - '0';
 26a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 26d:	89 d0                	mov    %edx,%eax
 26f:	c1 e0 02             	shl    $0x2,%eax
 272:	01 d0                	add    %edx,%eax
 274:	01 c0                	add    %eax,%eax
 276:	89 c1                	mov    %eax,%ecx
 278:	8b 45 08             	mov    0x8(%ebp),%eax
 27b:	8d 50 01             	lea    0x1(%eax),%edx
 27e:	89 55 08             	mov    %edx,0x8(%ebp)
 281:	0f b6 00             	movzbl (%eax),%eax
 284:	0f be c0             	movsbl %al,%eax
 287:	01 c8                	add    %ecx,%eax
 289:	83 e8 30             	sub    $0x30,%eax
 28c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 28f:	8b 45 08             	mov    0x8(%ebp),%eax
 292:	0f b6 00             	movzbl (%eax),%eax
 295:	3c 2f                	cmp    $0x2f,%al
 297:	7e 0a                	jle    2a3 <atoi+0x4c>
 299:	8b 45 08             	mov    0x8(%ebp),%eax
 29c:	0f b6 00             	movzbl (%eax),%eax
 29f:	3c 39                	cmp    $0x39,%al
 2a1:	7e c7                	jle    26a <atoi+0x13>
  return n;
 2a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2a6:	c9                   	leave
 2a7:	c3                   	ret

000002a8 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2a8:	f3 0f 1e fb          	endbr32
 2ac:	55                   	push   %ebp
 2ad:	89 e5                	mov    %esp,%ebp
 2af:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2b2:	8b 45 08             	mov    0x8(%ebp),%eax
 2b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2b8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2bb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2be:	eb 17                	jmp    2d7 <memmove+0x2f>
    *dst++ = *src++;
 2c0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2c3:	8d 42 01             	lea    0x1(%edx),%eax
 2c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2cc:	8d 48 01             	lea    0x1(%eax),%ecx
 2cf:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 2d2:	0f b6 12             	movzbl (%edx),%edx
 2d5:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2d7:	8b 45 10             	mov    0x10(%ebp),%eax
 2da:	8d 50 ff             	lea    -0x1(%eax),%edx
 2dd:	89 55 10             	mov    %edx,0x10(%ebp)
 2e0:	85 c0                	test   %eax,%eax
 2e2:	7f dc                	jg     2c0 <memmove+0x18>
  return vdst;
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2e7:	c9                   	leave
 2e8:	c3                   	ret

000002e9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2e9:	b8 01 00 00 00       	mov    $0x1,%eax
 2ee:	cd 40                	int    $0x40
 2f0:	c3                   	ret

000002f1 <exit>:
SYSCALL(exit)
 2f1:	b8 02 00 00 00       	mov    $0x2,%eax
 2f6:	cd 40                	int    $0x40
 2f8:	c3                   	ret

000002f9 <wait>:
SYSCALL(wait)
 2f9:	b8 03 00 00 00       	mov    $0x3,%eax
 2fe:	cd 40                	int    $0x40
 300:	c3                   	ret

00000301 <pipe>:
SYSCALL(pipe)
 301:	b8 04 00 00 00       	mov    $0x4,%eax
 306:	cd 40                	int    $0x40
 308:	c3                   	ret

00000309 <read>:
SYSCALL(read)
 309:	b8 05 00 00 00       	mov    $0x5,%eax
 30e:	cd 40                	int    $0x40
 310:	c3                   	ret

00000311 <write>:
SYSCALL(write)
 311:	b8 10 00 00 00       	mov    $0x10,%eax
 316:	cd 40                	int    $0x40
 318:	c3                   	ret

00000319 <close>:
SYSCALL(close)
 319:	b8 15 00 00 00       	mov    $0x15,%eax
 31e:	cd 40                	int    $0x40
 320:	c3                   	ret

00000321 <kill>:
SYSCALL(kill)
 321:	b8 06 00 00 00       	mov    $0x6,%eax
 326:	cd 40                	int    $0x40
 328:	c3                   	ret

00000329 <exec>:
SYSCALL(exec)
 329:	b8 07 00 00 00       	mov    $0x7,%eax
 32e:	cd 40                	int    $0x40
 330:	c3                   	ret

00000331 <open>:
SYSCALL(open)
 331:	b8 0f 00 00 00       	mov    $0xf,%eax
 336:	cd 40                	int    $0x40
 338:	c3                   	ret

00000339 <mknod>:
SYSCALL(mknod)
 339:	b8 11 00 00 00       	mov    $0x11,%eax
 33e:	cd 40                	int    $0x40
 340:	c3                   	ret

00000341 <unlink>:
SYSCALL(unlink)
 341:	b8 12 00 00 00       	mov    $0x12,%eax
 346:	cd 40                	int    $0x40
 348:	c3                   	ret

00000349 <fstat>:
SYSCALL(fstat)
 349:	b8 08 00 00 00       	mov    $0x8,%eax
 34e:	cd 40                	int    $0x40
 350:	c3                   	ret

00000351 <link>:
SYSCALL(link)
 351:	b8 13 00 00 00       	mov    $0x13,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret

00000359 <mkdir>:
SYSCALL(mkdir)
 359:	b8 14 00 00 00       	mov    $0x14,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret

00000361 <chdir>:
SYSCALL(chdir)
 361:	b8 09 00 00 00       	mov    $0x9,%eax
 366:	cd 40                	int    $0x40
 368:	c3                   	ret

00000369 <dup>:
SYSCALL(dup)
 369:	b8 0a 00 00 00       	mov    $0xa,%eax
 36e:	cd 40                	int    $0x40
 370:	c3                   	ret

00000371 <getpid>:
SYSCALL(getpid)
 371:	b8 0b 00 00 00       	mov    $0xb,%eax
 376:	cd 40                	int    $0x40
 378:	c3                   	ret

00000379 <sbrk>:
SYSCALL(sbrk)
 379:	b8 0c 00 00 00       	mov    $0xc,%eax
 37e:	cd 40                	int    $0x40
 380:	c3                   	ret

00000381 <sleep>:
SYSCALL(sleep)
 381:	b8 0d 00 00 00       	mov    $0xd,%eax
 386:	cd 40                	int    $0x40
 388:	c3                   	ret

00000389 <uptime>:
SYSCALL(uptime)
 389:	b8 0e 00 00 00       	mov    $0xe,%eax
 38e:	cd 40                	int    $0x40
 390:	c3                   	ret

00000391 <getpinfo>:

SYSCALL(getpinfo)
 391:	b8 16 00 00 00       	mov    $0x16,%eax
 396:	cd 40                	int    $0x40
 398:	c3                   	ret

00000399 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 399:	b8 17 00 00 00       	mov    $0x17,%eax
 39e:	cd 40                	int    $0x40
 3a0:	c3                   	ret

000003a1 <yield>:
SYSCALL(yield)
 3a1:	b8 18 00 00 00       	mov    $0x18,%eax
 3a6:	cd 40                	int    $0x40
 3a8:	c3                   	ret

000003a9 <getSchedPolicy>:
 3a9:	b8 19 00 00 00       	mov    $0x19,%eax
 3ae:	cd 40                	int    $0x40
 3b0:	c3                   	ret

000003b1 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3b1:	f3 0f 1e fb          	endbr32
 3b5:	55                   	push   %ebp
 3b6:	89 e5                	mov    %esp,%ebp
 3b8:	83 ec 18             	sub    $0x18,%esp
 3bb:	8b 45 0c             	mov    0xc(%ebp),%eax
 3be:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3c1:	83 ec 04             	sub    $0x4,%esp
 3c4:	6a 01                	push   $0x1
 3c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3c9:	50                   	push   %eax
 3ca:	ff 75 08             	push   0x8(%ebp)
 3cd:	e8 3f ff ff ff       	call   311 <write>
 3d2:	83 c4 10             	add    $0x10,%esp
}
 3d5:	90                   	nop
 3d6:	c9                   	leave
 3d7:	c3                   	ret

000003d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d8:	f3 0f 1e fb          	endbr32
 3dc:	55                   	push   %ebp
 3dd:	89 e5                	mov    %esp,%ebp
 3df:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3e2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3e9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3ed:	74 17                	je     406 <printint+0x2e>
 3ef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3f3:	79 11                	jns    406 <printint+0x2e>
    neg = 1;
 3f5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3fc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ff:	f7 d8                	neg    %eax
 401:	89 45 ec             	mov    %eax,-0x14(%ebp)
 404:	eb 06                	jmp    40c <printint+0x34>
  } else {
    x = xx;
 406:	8b 45 0c             	mov    0xc(%ebp),%eax
 409:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 40c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 413:	8b 4d 10             	mov    0x10(%ebp),%ecx
 416:	8b 45 ec             	mov    -0x14(%ebp),%eax
 419:	ba 00 00 00 00       	mov    $0x0,%edx
 41e:	f7 f1                	div    %ecx
 420:	89 d1                	mov    %edx,%ecx
 422:	8b 45 f4             	mov    -0xc(%ebp),%eax
 425:	8d 50 01             	lea    0x1(%eax),%edx
 428:	89 55 f4             	mov    %edx,-0xc(%ebp)
 42b:	0f b6 91 b8 0a 00 00 	movzbl 0xab8(%ecx),%edx
 432:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 436:	8b 4d 10             	mov    0x10(%ebp),%ecx
 439:	8b 45 ec             	mov    -0x14(%ebp),%eax
 43c:	ba 00 00 00 00       	mov    $0x0,%edx
 441:	f7 f1                	div    %ecx
 443:	89 45 ec             	mov    %eax,-0x14(%ebp)
 446:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 44a:	75 c7                	jne    413 <printint+0x3b>
  if(neg)
 44c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 450:	74 2d                	je     47f <printint+0xa7>
    buf[i++] = '-';
 452:	8b 45 f4             	mov    -0xc(%ebp),%eax
 455:	8d 50 01             	lea    0x1(%eax),%edx
 458:	89 55 f4             	mov    %edx,-0xc(%ebp)
 45b:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 460:	eb 1d                	jmp    47f <printint+0xa7>
    putc(fd, buf[i]);
 462:	8d 55 dc             	lea    -0x24(%ebp),%edx
 465:	8b 45 f4             	mov    -0xc(%ebp),%eax
 468:	01 d0                	add    %edx,%eax
 46a:	0f b6 00             	movzbl (%eax),%eax
 46d:	0f be c0             	movsbl %al,%eax
 470:	83 ec 08             	sub    $0x8,%esp
 473:	50                   	push   %eax
 474:	ff 75 08             	push   0x8(%ebp)
 477:	e8 35 ff ff ff       	call   3b1 <putc>
 47c:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 47f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 483:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 487:	79 d9                	jns    462 <printint+0x8a>
}
 489:	90                   	nop
 48a:	90                   	nop
 48b:	c9                   	leave
 48c:	c3                   	ret

0000048d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 48d:	f3 0f 1e fb          	endbr32
 491:	55                   	push   %ebp
 492:	89 e5                	mov    %esp,%ebp
 494:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 497:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 49e:	8d 45 0c             	lea    0xc(%ebp),%eax
 4a1:	83 c0 04             	add    $0x4,%eax
 4a4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4a7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4ae:	e9 59 01 00 00       	jmp    60c <printf+0x17f>
    c = fmt[i] & 0xff;
 4b3:	8b 55 0c             	mov    0xc(%ebp),%edx
 4b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4b9:	01 d0                	add    %edx,%eax
 4bb:	0f b6 00             	movzbl (%eax),%eax
 4be:	0f be c0             	movsbl %al,%eax
 4c1:	25 ff 00 00 00       	and    $0xff,%eax
 4c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4cd:	75 2c                	jne    4fb <printf+0x6e>
      if(c == '%'){
 4cf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4d3:	75 0c                	jne    4e1 <printf+0x54>
        state = '%';
 4d5:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4dc:	e9 27 01 00 00       	jmp    608 <printf+0x17b>
      } else {
        putc(fd, c);
 4e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4e4:	0f be c0             	movsbl %al,%eax
 4e7:	83 ec 08             	sub    $0x8,%esp
 4ea:	50                   	push   %eax
 4eb:	ff 75 08             	push   0x8(%ebp)
 4ee:	e8 be fe ff ff       	call   3b1 <putc>
 4f3:	83 c4 10             	add    $0x10,%esp
 4f6:	e9 0d 01 00 00       	jmp    608 <printf+0x17b>
      }
    } else if(state == '%'){
 4fb:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4ff:	0f 85 03 01 00 00    	jne    608 <printf+0x17b>
      if(c == 'd'){
 505:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 509:	75 1e                	jne    529 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 50b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 50e:	8b 00                	mov    (%eax),%eax
 510:	6a 01                	push   $0x1
 512:	6a 0a                	push   $0xa
 514:	50                   	push   %eax
 515:	ff 75 08             	push   0x8(%ebp)
 518:	e8 bb fe ff ff       	call   3d8 <printint>
 51d:	83 c4 10             	add    $0x10,%esp
        ap++;
 520:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 524:	e9 d8 00 00 00       	jmp    601 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 529:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 52d:	74 06                	je     535 <printf+0xa8>
 52f:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 533:	75 1e                	jne    553 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 535:	8b 45 e8             	mov    -0x18(%ebp),%eax
 538:	8b 00                	mov    (%eax),%eax
 53a:	6a 00                	push   $0x0
 53c:	6a 10                	push   $0x10
 53e:	50                   	push   %eax
 53f:	ff 75 08             	push   0x8(%ebp)
 542:	e8 91 fe ff ff       	call   3d8 <printint>
 547:	83 c4 10             	add    $0x10,%esp
        ap++;
 54a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 54e:	e9 ae 00 00 00       	jmp    601 <printf+0x174>
      } else if(c == 's'){
 553:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 557:	75 43                	jne    59c <printf+0x10f>
        s = (char*)*ap;
 559:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55c:	8b 00                	mov    (%eax),%eax
 55e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 561:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 565:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 569:	75 25                	jne    590 <printf+0x103>
          s = "(null)";
 56b:	c7 45 f4 68 08 00 00 	movl   $0x868,-0xc(%ebp)
        while(*s != 0){
 572:	eb 1c                	jmp    590 <printf+0x103>
          putc(fd, *s);
 574:	8b 45 f4             	mov    -0xc(%ebp),%eax
 577:	0f b6 00             	movzbl (%eax),%eax
 57a:	0f be c0             	movsbl %al,%eax
 57d:	83 ec 08             	sub    $0x8,%esp
 580:	50                   	push   %eax
 581:	ff 75 08             	push   0x8(%ebp)
 584:	e8 28 fe ff ff       	call   3b1 <putc>
 589:	83 c4 10             	add    $0x10,%esp
          s++;
 58c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 590:	8b 45 f4             	mov    -0xc(%ebp),%eax
 593:	0f b6 00             	movzbl (%eax),%eax
 596:	84 c0                	test   %al,%al
 598:	75 da                	jne    574 <printf+0xe7>
 59a:	eb 65                	jmp    601 <printf+0x174>
        }
      } else if(c == 'c'){
 59c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5a0:	75 1d                	jne    5bf <printf+0x132>
        putc(fd, *ap);
 5a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a5:	8b 00                	mov    (%eax),%eax
 5a7:	0f be c0             	movsbl %al,%eax
 5aa:	83 ec 08             	sub    $0x8,%esp
 5ad:	50                   	push   %eax
 5ae:	ff 75 08             	push   0x8(%ebp)
 5b1:	e8 fb fd ff ff       	call   3b1 <putc>
 5b6:	83 c4 10             	add    $0x10,%esp
        ap++;
 5b9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5bd:	eb 42                	jmp    601 <printf+0x174>
      } else if(c == '%'){
 5bf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5c3:	75 17                	jne    5dc <printf+0x14f>
        putc(fd, c);
 5c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c8:	0f be c0             	movsbl %al,%eax
 5cb:	83 ec 08             	sub    $0x8,%esp
 5ce:	50                   	push   %eax
 5cf:	ff 75 08             	push   0x8(%ebp)
 5d2:	e8 da fd ff ff       	call   3b1 <putc>
 5d7:	83 c4 10             	add    $0x10,%esp
 5da:	eb 25                	jmp    601 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5dc:	83 ec 08             	sub    $0x8,%esp
 5df:	6a 25                	push   $0x25
 5e1:	ff 75 08             	push   0x8(%ebp)
 5e4:	e8 c8 fd ff ff       	call   3b1 <putc>
 5e9:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ef:	0f be c0             	movsbl %al,%eax
 5f2:	83 ec 08             	sub    $0x8,%esp
 5f5:	50                   	push   %eax
 5f6:	ff 75 08             	push   0x8(%ebp)
 5f9:	e8 b3 fd ff ff       	call   3b1 <putc>
 5fe:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 601:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 608:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 60c:	8b 55 0c             	mov    0xc(%ebp),%edx
 60f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 612:	01 d0                	add    %edx,%eax
 614:	0f b6 00             	movzbl (%eax),%eax
 617:	84 c0                	test   %al,%al
 619:	0f 85 94 fe ff ff    	jne    4b3 <printf+0x26>
    }
  }
}
 61f:	90                   	nop
 620:	90                   	nop
 621:	c9                   	leave
 622:	c3                   	ret

00000623 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 623:	f3 0f 1e fb          	endbr32
 627:	55                   	push   %ebp
 628:	89 e5                	mov    %esp,%ebp
 62a:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 62d:	8b 45 08             	mov    0x8(%ebp),%eax
 630:	83 e8 08             	sub    $0x8,%eax
 633:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 636:	a1 d4 0a 00 00       	mov    0xad4,%eax
 63b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 63e:	eb 24                	jmp    664 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 640:	8b 45 fc             	mov    -0x4(%ebp),%eax
 643:	8b 00                	mov    (%eax),%eax
 645:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 648:	72 12                	jb     65c <free+0x39>
 64a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 650:	77 24                	ja     676 <free+0x53>
 652:	8b 45 fc             	mov    -0x4(%ebp),%eax
 655:	8b 00                	mov    (%eax),%eax
 657:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 65a:	72 1a                	jb     676 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 65c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65f:	8b 00                	mov    (%eax),%eax
 661:	89 45 fc             	mov    %eax,-0x4(%ebp)
 664:	8b 45 f8             	mov    -0x8(%ebp),%eax
 667:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 66a:	76 d4                	jbe    640 <free+0x1d>
 66c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66f:	8b 00                	mov    (%eax),%eax
 671:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 674:	73 ca                	jae    640 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 676:	8b 45 f8             	mov    -0x8(%ebp),%eax
 679:	8b 40 04             	mov    0x4(%eax),%eax
 67c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 683:	8b 45 f8             	mov    -0x8(%ebp),%eax
 686:	01 c2                	add    %eax,%edx
 688:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68b:	8b 00                	mov    (%eax),%eax
 68d:	39 c2                	cmp    %eax,%edx
 68f:	75 24                	jne    6b5 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 691:	8b 45 f8             	mov    -0x8(%ebp),%eax
 694:	8b 50 04             	mov    0x4(%eax),%edx
 697:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69a:	8b 00                	mov    (%eax),%eax
 69c:	8b 40 04             	mov    0x4(%eax),%eax
 69f:	01 c2                	add    %eax,%edx
 6a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a4:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6aa:	8b 00                	mov    (%eax),%eax
 6ac:	8b 10                	mov    (%eax),%edx
 6ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b1:	89 10                	mov    %edx,(%eax)
 6b3:	eb 0a                	jmp    6bf <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 6b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b8:	8b 10                	mov    (%eax),%edx
 6ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6bd:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c2:	8b 40 04             	mov    0x4(%eax),%eax
 6c5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cf:	01 d0                	add    %edx,%eax
 6d1:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6d4:	75 20                	jne    6f6 <free+0xd3>
    p->s.size += bp->s.size;
 6d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d9:	8b 50 04             	mov    0x4(%eax),%edx
 6dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6df:	8b 40 04             	mov    0x4(%eax),%eax
 6e2:	01 c2                	add    %eax,%edx
 6e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e7:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ed:	8b 10                	mov    (%eax),%edx
 6ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f2:	89 10                	mov    %edx,(%eax)
 6f4:	eb 08                	jmp    6fe <free+0xdb>
  } else
    p->s.ptr = bp;
 6f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6fc:	89 10                	mov    %edx,(%eax)
  freep = p;
 6fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 701:	a3 d4 0a 00 00       	mov    %eax,0xad4
}
 706:	90                   	nop
 707:	c9                   	leave
 708:	c3                   	ret

00000709 <morecore>:

static Header*
morecore(uint nu)
{
 709:	f3 0f 1e fb          	endbr32
 70d:	55                   	push   %ebp
 70e:	89 e5                	mov    %esp,%ebp
 710:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 713:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 71a:	77 07                	ja     723 <morecore+0x1a>
    nu = 4096;
 71c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 723:	8b 45 08             	mov    0x8(%ebp),%eax
 726:	c1 e0 03             	shl    $0x3,%eax
 729:	83 ec 0c             	sub    $0xc,%esp
 72c:	50                   	push   %eax
 72d:	e8 47 fc ff ff       	call   379 <sbrk>
 732:	83 c4 10             	add    $0x10,%esp
 735:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 738:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 73c:	75 07                	jne    745 <morecore+0x3c>
    return 0;
 73e:	b8 00 00 00 00       	mov    $0x0,%eax
 743:	eb 26                	jmp    76b <morecore+0x62>
  hp = (Header*)p;
 745:	8b 45 f4             	mov    -0xc(%ebp),%eax
 748:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 74b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74e:	8b 55 08             	mov    0x8(%ebp),%edx
 751:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 754:	8b 45 f0             	mov    -0x10(%ebp),%eax
 757:	83 c0 08             	add    $0x8,%eax
 75a:	83 ec 0c             	sub    $0xc,%esp
 75d:	50                   	push   %eax
 75e:	e8 c0 fe ff ff       	call   623 <free>
 763:	83 c4 10             	add    $0x10,%esp
  return freep;
 766:	a1 d4 0a 00 00       	mov    0xad4,%eax
}
 76b:	c9                   	leave
 76c:	c3                   	ret

0000076d <malloc>:

void*
malloc(uint nbytes)
{
 76d:	f3 0f 1e fb          	endbr32
 771:	55                   	push   %ebp
 772:	89 e5                	mov    %esp,%ebp
 774:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 777:	8b 45 08             	mov    0x8(%ebp),%eax
 77a:	83 c0 07             	add    $0x7,%eax
 77d:	c1 e8 03             	shr    $0x3,%eax
 780:	83 c0 01             	add    $0x1,%eax
 783:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 786:	a1 d4 0a 00 00       	mov    0xad4,%eax
 78b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 78e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 792:	75 23                	jne    7b7 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 794:	c7 45 f0 cc 0a 00 00 	movl   $0xacc,-0x10(%ebp)
 79b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79e:	a3 d4 0a 00 00       	mov    %eax,0xad4
 7a3:	a1 d4 0a 00 00       	mov    0xad4,%eax
 7a8:	a3 cc 0a 00 00       	mov    %eax,0xacc
    base.s.size = 0;
 7ad:	c7 05 d0 0a 00 00 00 	movl   $0x0,0xad0
 7b4:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ba:	8b 00                	mov    (%eax),%eax
 7bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c2:	8b 40 04             	mov    0x4(%eax),%eax
 7c5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7c8:	77 4d                	ja     817 <malloc+0xaa>
      if(p->s.size == nunits)
 7ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cd:	8b 40 04             	mov    0x4(%eax),%eax
 7d0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7d3:	75 0c                	jne    7e1 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 7d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d8:	8b 10                	mov    (%eax),%edx
 7da:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7dd:	89 10                	mov    %edx,(%eax)
 7df:	eb 26                	jmp    807 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 7e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e4:	8b 40 04             	mov    0x4(%eax),%eax
 7e7:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7ea:	89 c2                	mov    %eax,%edx
 7ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ef:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f5:	8b 40 04             	mov    0x4(%eax),%eax
 7f8:	c1 e0 03             	shl    $0x3,%eax
 7fb:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 801:	8b 55 ec             	mov    -0x14(%ebp),%edx
 804:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 807:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80a:	a3 d4 0a 00 00       	mov    %eax,0xad4
      return (void*)(p + 1);
 80f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 812:	83 c0 08             	add    $0x8,%eax
 815:	eb 3b                	jmp    852 <malloc+0xe5>
    }
    if(p == freep)
 817:	a1 d4 0a 00 00       	mov    0xad4,%eax
 81c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 81f:	75 1e                	jne    83f <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 821:	83 ec 0c             	sub    $0xc,%esp
 824:	ff 75 ec             	push   -0x14(%ebp)
 827:	e8 dd fe ff ff       	call   709 <morecore>
 82c:	83 c4 10             	add    $0x10,%esp
 82f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 832:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 836:	75 07                	jne    83f <malloc+0xd2>
        return 0;
 838:	b8 00 00 00 00       	mov    $0x0,%eax
 83d:	eb 13                	jmp    852 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 842:	89 45 f0             	mov    %eax,-0x10(%ebp)
 845:	8b 45 f4             	mov    -0xc(%ebp),%eax
 848:	8b 00                	mov    (%eax),%eax
 84a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 84d:	e9 6d ff ff ff       	jmp    7bf <malloc+0x52>
  }
}
 852:	c9                   	leave
 853:	c3                   	ret
