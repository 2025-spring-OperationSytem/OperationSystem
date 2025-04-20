
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
  20:	68 44 08 00 00       	push   $0x844
  25:	6a 02                	push   $0x2
  27:	e8 51 04 00 00       	call   47d <printf>
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

00000391 <uthread_init>:

SYSCALL(uthread_init)
 391:	b8 16 00 00 00       	mov    $0x16,%eax
 396:	cd 40                	int    $0x40
 398:	c3                   	ret

00000399 <thread_count>:
SYSCALL(thread_count)
 399:	b8 17 00 00 00       	mov    $0x17,%eax
 39e:	cd 40                	int    $0x40
 3a0:	c3                   	ret

000003a1 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3a1:	f3 0f 1e fb          	endbr32
 3a5:	55                   	push   %ebp
 3a6:	89 e5                	mov    %esp,%ebp
 3a8:	83 ec 18             	sub    $0x18,%esp
 3ab:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ae:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3b1:	83 ec 04             	sub    $0x4,%esp
 3b4:	6a 01                	push   $0x1
 3b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3b9:	50                   	push   %eax
 3ba:	ff 75 08             	push   0x8(%ebp)
 3bd:	e8 4f ff ff ff       	call   311 <write>
 3c2:	83 c4 10             	add    $0x10,%esp
}
 3c5:	90                   	nop
 3c6:	c9                   	leave
 3c7:	c3                   	ret

000003c8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3c8:	f3 0f 1e fb          	endbr32
 3cc:	55                   	push   %ebp
 3cd:	89 e5                	mov    %esp,%ebp
 3cf:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3d2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3d9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3dd:	74 17                	je     3f6 <printint+0x2e>
 3df:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3e3:	79 11                	jns    3f6 <printint+0x2e>
    neg = 1;
 3e5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3ec:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ef:	f7 d8                	neg    %eax
 3f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3f4:	eb 06                	jmp    3fc <printint+0x34>
  } else {
    x = xx;
 3f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 403:	8b 4d 10             	mov    0x10(%ebp),%ecx
 406:	8b 45 ec             	mov    -0x14(%ebp),%eax
 409:	ba 00 00 00 00       	mov    $0x0,%edx
 40e:	f7 f1                	div    %ecx
 410:	89 d1                	mov    %edx,%ecx
 412:	8b 45 f4             	mov    -0xc(%ebp),%eax
 415:	8d 50 01             	lea    0x1(%eax),%edx
 418:	89 55 f4             	mov    %edx,-0xc(%ebp)
 41b:	0f b6 91 a8 0a 00 00 	movzbl 0xaa8(%ecx),%edx
 422:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 426:	8b 4d 10             	mov    0x10(%ebp),%ecx
 429:	8b 45 ec             	mov    -0x14(%ebp),%eax
 42c:	ba 00 00 00 00       	mov    $0x0,%edx
 431:	f7 f1                	div    %ecx
 433:	89 45 ec             	mov    %eax,-0x14(%ebp)
 436:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 43a:	75 c7                	jne    403 <printint+0x3b>
  if(neg)
 43c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 440:	74 2d                	je     46f <printint+0xa7>
    buf[i++] = '-';
 442:	8b 45 f4             	mov    -0xc(%ebp),%eax
 445:	8d 50 01             	lea    0x1(%eax),%edx
 448:	89 55 f4             	mov    %edx,-0xc(%ebp)
 44b:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 450:	eb 1d                	jmp    46f <printint+0xa7>
    putc(fd, buf[i]);
 452:	8d 55 dc             	lea    -0x24(%ebp),%edx
 455:	8b 45 f4             	mov    -0xc(%ebp),%eax
 458:	01 d0                	add    %edx,%eax
 45a:	0f b6 00             	movzbl (%eax),%eax
 45d:	0f be c0             	movsbl %al,%eax
 460:	83 ec 08             	sub    $0x8,%esp
 463:	50                   	push   %eax
 464:	ff 75 08             	push   0x8(%ebp)
 467:	e8 35 ff ff ff       	call   3a1 <putc>
 46c:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 46f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 473:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 477:	79 d9                	jns    452 <printint+0x8a>
}
 479:	90                   	nop
 47a:	90                   	nop
 47b:	c9                   	leave
 47c:	c3                   	ret

0000047d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 47d:	f3 0f 1e fb          	endbr32
 481:	55                   	push   %ebp
 482:	89 e5                	mov    %esp,%ebp
 484:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 487:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 48e:	8d 45 0c             	lea    0xc(%ebp),%eax
 491:	83 c0 04             	add    $0x4,%eax
 494:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 497:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 49e:	e9 59 01 00 00       	jmp    5fc <printf+0x17f>
    c = fmt[i] & 0xff;
 4a3:	8b 55 0c             	mov    0xc(%ebp),%edx
 4a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4a9:	01 d0                	add    %edx,%eax
 4ab:	0f b6 00             	movzbl (%eax),%eax
 4ae:	0f be c0             	movsbl %al,%eax
 4b1:	25 ff 00 00 00       	and    $0xff,%eax
 4b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4b9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4bd:	75 2c                	jne    4eb <printf+0x6e>
      if(c == '%'){
 4bf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4c3:	75 0c                	jne    4d1 <printf+0x54>
        state = '%';
 4c5:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4cc:	e9 27 01 00 00       	jmp    5f8 <printf+0x17b>
      } else {
        putc(fd, c);
 4d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4d4:	0f be c0             	movsbl %al,%eax
 4d7:	83 ec 08             	sub    $0x8,%esp
 4da:	50                   	push   %eax
 4db:	ff 75 08             	push   0x8(%ebp)
 4de:	e8 be fe ff ff       	call   3a1 <putc>
 4e3:	83 c4 10             	add    $0x10,%esp
 4e6:	e9 0d 01 00 00       	jmp    5f8 <printf+0x17b>
      }
    } else if(state == '%'){
 4eb:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4ef:	0f 85 03 01 00 00    	jne    5f8 <printf+0x17b>
      if(c == 'd'){
 4f5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4f9:	75 1e                	jne    519 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 4fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4fe:	8b 00                	mov    (%eax),%eax
 500:	6a 01                	push   $0x1
 502:	6a 0a                	push   $0xa
 504:	50                   	push   %eax
 505:	ff 75 08             	push   0x8(%ebp)
 508:	e8 bb fe ff ff       	call   3c8 <printint>
 50d:	83 c4 10             	add    $0x10,%esp
        ap++;
 510:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 514:	e9 d8 00 00 00       	jmp    5f1 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 519:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 51d:	74 06                	je     525 <printf+0xa8>
 51f:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 523:	75 1e                	jne    543 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 525:	8b 45 e8             	mov    -0x18(%ebp),%eax
 528:	8b 00                	mov    (%eax),%eax
 52a:	6a 00                	push   $0x0
 52c:	6a 10                	push   $0x10
 52e:	50                   	push   %eax
 52f:	ff 75 08             	push   0x8(%ebp)
 532:	e8 91 fe ff ff       	call   3c8 <printint>
 537:	83 c4 10             	add    $0x10,%esp
        ap++;
 53a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 53e:	e9 ae 00 00 00       	jmp    5f1 <printf+0x174>
      } else if(c == 's'){
 543:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 547:	75 43                	jne    58c <printf+0x10f>
        s = (char*)*ap;
 549:	8b 45 e8             	mov    -0x18(%ebp),%eax
 54c:	8b 00                	mov    (%eax),%eax
 54e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 551:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 555:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 559:	75 25                	jne    580 <printf+0x103>
          s = "(null)";
 55b:	c7 45 f4 58 08 00 00 	movl   $0x858,-0xc(%ebp)
        while(*s != 0){
 562:	eb 1c                	jmp    580 <printf+0x103>
          putc(fd, *s);
 564:	8b 45 f4             	mov    -0xc(%ebp),%eax
 567:	0f b6 00             	movzbl (%eax),%eax
 56a:	0f be c0             	movsbl %al,%eax
 56d:	83 ec 08             	sub    $0x8,%esp
 570:	50                   	push   %eax
 571:	ff 75 08             	push   0x8(%ebp)
 574:	e8 28 fe ff ff       	call   3a1 <putc>
 579:	83 c4 10             	add    $0x10,%esp
          s++;
 57c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 580:	8b 45 f4             	mov    -0xc(%ebp),%eax
 583:	0f b6 00             	movzbl (%eax),%eax
 586:	84 c0                	test   %al,%al
 588:	75 da                	jne    564 <printf+0xe7>
 58a:	eb 65                	jmp    5f1 <printf+0x174>
        }
      } else if(c == 'c'){
 58c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 590:	75 1d                	jne    5af <printf+0x132>
        putc(fd, *ap);
 592:	8b 45 e8             	mov    -0x18(%ebp),%eax
 595:	8b 00                	mov    (%eax),%eax
 597:	0f be c0             	movsbl %al,%eax
 59a:	83 ec 08             	sub    $0x8,%esp
 59d:	50                   	push   %eax
 59e:	ff 75 08             	push   0x8(%ebp)
 5a1:	e8 fb fd ff ff       	call   3a1 <putc>
 5a6:	83 c4 10             	add    $0x10,%esp
        ap++;
 5a9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ad:	eb 42                	jmp    5f1 <printf+0x174>
      } else if(c == '%'){
 5af:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5b3:	75 17                	jne    5cc <printf+0x14f>
        putc(fd, c);
 5b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5b8:	0f be c0             	movsbl %al,%eax
 5bb:	83 ec 08             	sub    $0x8,%esp
 5be:	50                   	push   %eax
 5bf:	ff 75 08             	push   0x8(%ebp)
 5c2:	e8 da fd ff ff       	call   3a1 <putc>
 5c7:	83 c4 10             	add    $0x10,%esp
 5ca:	eb 25                	jmp    5f1 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5cc:	83 ec 08             	sub    $0x8,%esp
 5cf:	6a 25                	push   $0x25
 5d1:	ff 75 08             	push   0x8(%ebp)
 5d4:	e8 c8 fd ff ff       	call   3a1 <putc>
 5d9:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5df:	0f be c0             	movsbl %al,%eax
 5e2:	83 ec 08             	sub    $0x8,%esp
 5e5:	50                   	push   %eax
 5e6:	ff 75 08             	push   0x8(%ebp)
 5e9:	e8 b3 fd ff ff       	call   3a1 <putc>
 5ee:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5f1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5f8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5fc:	8b 55 0c             	mov    0xc(%ebp),%edx
 5ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
 602:	01 d0                	add    %edx,%eax
 604:	0f b6 00             	movzbl (%eax),%eax
 607:	84 c0                	test   %al,%al
 609:	0f 85 94 fe ff ff    	jne    4a3 <printf+0x26>
    }
  }
}
 60f:	90                   	nop
 610:	90                   	nop
 611:	c9                   	leave
 612:	c3                   	ret

00000613 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 613:	f3 0f 1e fb          	endbr32
 617:	55                   	push   %ebp
 618:	89 e5                	mov    %esp,%ebp
 61a:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 61d:	8b 45 08             	mov    0x8(%ebp),%eax
 620:	83 e8 08             	sub    $0x8,%eax
 623:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 626:	a1 c4 0a 00 00       	mov    0xac4,%eax
 62b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 62e:	eb 24                	jmp    654 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 630:	8b 45 fc             	mov    -0x4(%ebp),%eax
 633:	8b 00                	mov    (%eax),%eax
 635:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 638:	72 12                	jb     64c <free+0x39>
 63a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 640:	77 24                	ja     666 <free+0x53>
 642:	8b 45 fc             	mov    -0x4(%ebp),%eax
 645:	8b 00                	mov    (%eax),%eax
 647:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 64a:	72 1a                	jb     666 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 64c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64f:	8b 00                	mov    (%eax),%eax
 651:	89 45 fc             	mov    %eax,-0x4(%ebp)
 654:	8b 45 f8             	mov    -0x8(%ebp),%eax
 657:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 65a:	76 d4                	jbe    630 <free+0x1d>
 65c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65f:	8b 00                	mov    (%eax),%eax
 661:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 664:	73 ca                	jae    630 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 666:	8b 45 f8             	mov    -0x8(%ebp),%eax
 669:	8b 40 04             	mov    0x4(%eax),%eax
 66c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 673:	8b 45 f8             	mov    -0x8(%ebp),%eax
 676:	01 c2                	add    %eax,%edx
 678:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67b:	8b 00                	mov    (%eax),%eax
 67d:	39 c2                	cmp    %eax,%edx
 67f:	75 24                	jne    6a5 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 681:	8b 45 f8             	mov    -0x8(%ebp),%eax
 684:	8b 50 04             	mov    0x4(%eax),%edx
 687:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68a:	8b 00                	mov    (%eax),%eax
 68c:	8b 40 04             	mov    0x4(%eax),%eax
 68f:	01 c2                	add    %eax,%edx
 691:	8b 45 f8             	mov    -0x8(%ebp),%eax
 694:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 697:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69a:	8b 00                	mov    (%eax),%eax
 69c:	8b 10                	mov    (%eax),%edx
 69e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a1:	89 10                	mov    %edx,(%eax)
 6a3:	eb 0a                	jmp    6af <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 6a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a8:	8b 10                	mov    (%eax),%edx
 6aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ad:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b2:	8b 40 04             	mov    0x4(%eax),%eax
 6b5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bf:	01 d0                	add    %edx,%eax
 6c1:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6c4:	75 20                	jne    6e6 <free+0xd3>
    p->s.size += bp->s.size;
 6c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c9:	8b 50 04             	mov    0x4(%eax),%edx
 6cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6cf:	8b 40 04             	mov    0x4(%eax),%eax
 6d2:	01 c2                	add    %eax,%edx
 6d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d7:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6dd:	8b 10                	mov    (%eax),%edx
 6df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e2:	89 10                	mov    %edx,(%eax)
 6e4:	eb 08                	jmp    6ee <free+0xdb>
  } else
    p->s.ptr = bp;
 6e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6ec:	89 10                	mov    %edx,(%eax)
  freep = p;
 6ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f1:	a3 c4 0a 00 00       	mov    %eax,0xac4
}
 6f6:	90                   	nop
 6f7:	c9                   	leave
 6f8:	c3                   	ret

000006f9 <morecore>:

static Header*
morecore(uint nu)
{
 6f9:	f3 0f 1e fb          	endbr32
 6fd:	55                   	push   %ebp
 6fe:	89 e5                	mov    %esp,%ebp
 700:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 703:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 70a:	77 07                	ja     713 <morecore+0x1a>
    nu = 4096;
 70c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 713:	8b 45 08             	mov    0x8(%ebp),%eax
 716:	c1 e0 03             	shl    $0x3,%eax
 719:	83 ec 0c             	sub    $0xc,%esp
 71c:	50                   	push   %eax
 71d:	e8 57 fc ff ff       	call   379 <sbrk>
 722:	83 c4 10             	add    $0x10,%esp
 725:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 728:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 72c:	75 07                	jne    735 <morecore+0x3c>
    return 0;
 72e:	b8 00 00 00 00       	mov    $0x0,%eax
 733:	eb 26                	jmp    75b <morecore+0x62>
  hp = (Header*)p;
 735:	8b 45 f4             	mov    -0xc(%ebp),%eax
 738:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 73b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 73e:	8b 55 08             	mov    0x8(%ebp),%edx
 741:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 744:	8b 45 f0             	mov    -0x10(%ebp),%eax
 747:	83 c0 08             	add    $0x8,%eax
 74a:	83 ec 0c             	sub    $0xc,%esp
 74d:	50                   	push   %eax
 74e:	e8 c0 fe ff ff       	call   613 <free>
 753:	83 c4 10             	add    $0x10,%esp
  return freep;
 756:	a1 c4 0a 00 00       	mov    0xac4,%eax
}
 75b:	c9                   	leave
 75c:	c3                   	ret

0000075d <malloc>:

void*
malloc(uint nbytes)
{
 75d:	f3 0f 1e fb          	endbr32
 761:	55                   	push   %ebp
 762:	89 e5                	mov    %esp,%ebp
 764:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 767:	8b 45 08             	mov    0x8(%ebp),%eax
 76a:	83 c0 07             	add    $0x7,%eax
 76d:	c1 e8 03             	shr    $0x3,%eax
 770:	83 c0 01             	add    $0x1,%eax
 773:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 776:	a1 c4 0a 00 00       	mov    0xac4,%eax
 77b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 77e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 782:	75 23                	jne    7a7 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 784:	c7 45 f0 bc 0a 00 00 	movl   $0xabc,-0x10(%ebp)
 78b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78e:	a3 c4 0a 00 00       	mov    %eax,0xac4
 793:	a1 c4 0a 00 00       	mov    0xac4,%eax
 798:	a3 bc 0a 00 00       	mov    %eax,0xabc
    base.s.size = 0;
 79d:	c7 05 c0 0a 00 00 00 	movl   $0x0,0xac0
 7a4:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7aa:	8b 00                	mov    (%eax),%eax
 7ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b2:	8b 40 04             	mov    0x4(%eax),%eax
 7b5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7b8:	77 4d                	ja     807 <malloc+0xaa>
      if(p->s.size == nunits)
 7ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bd:	8b 40 04             	mov    0x4(%eax),%eax
 7c0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7c3:	75 0c                	jne    7d1 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 7c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c8:	8b 10                	mov    (%eax),%edx
 7ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cd:	89 10                	mov    %edx,(%eax)
 7cf:	eb 26                	jmp    7f7 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 7d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d4:	8b 40 04             	mov    0x4(%eax),%eax
 7d7:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7da:	89 c2                	mov    %eax,%edx
 7dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7df:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e5:	8b 40 04             	mov    0x4(%eax),%eax
 7e8:	c1 e0 03             	shl    $0x3,%eax
 7eb:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7f4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fa:	a3 c4 0a 00 00       	mov    %eax,0xac4
      return (void*)(p + 1);
 7ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 802:	83 c0 08             	add    $0x8,%eax
 805:	eb 3b                	jmp    842 <malloc+0xe5>
    }
    if(p == freep)
 807:	a1 c4 0a 00 00       	mov    0xac4,%eax
 80c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 80f:	75 1e                	jne    82f <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 811:	83 ec 0c             	sub    $0xc,%esp
 814:	ff 75 ec             	push   -0x14(%ebp)
 817:	e8 dd fe ff ff       	call   6f9 <morecore>
 81c:	83 c4 10             	add    $0x10,%esp
 81f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 822:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 826:	75 07                	jne    82f <malloc+0xd2>
        return 0;
 828:	b8 00 00 00 00       	mov    $0x0,%eax
 82d:	eb 13                	jmp    842 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 832:	89 45 f0             	mov    %eax,-0x10(%ebp)
 835:	8b 45 f4             	mov    -0xc(%ebp),%eax
 838:	8b 00                	mov    (%eax),%eax
 83a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 83d:	e9 6d ff ff ff       	jmp    7af <malloc+0x52>
  }
}
 842:	c9                   	leave
 843:	c3                   	ret
