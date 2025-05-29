
_ln:     file format elf32-i386


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
  13:	89 cb                	mov    %ecx,%ebx
  if(argc != 3){
  15:	83 3b 03             	cmpl   $0x3,(%ebx)
  18:	74 17                	je     31 <main+0x31>
    printf(2, "Usage: ln old new\n");
  1a:	83 ec 08             	sub    $0x8,%esp
  1d:	68 46 08 00 00       	push   $0x846
  22:	6a 02                	push   $0x2
  24:	e8 56 04 00 00       	call   47f <printf>
  29:	83 c4 10             	add    $0x10,%esp
    exit();
  2c:	e8 c2 02 00 00       	call   2f3 <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  31:	8b 43 04             	mov    0x4(%ebx),%eax
  34:	83 c0 08             	add    $0x8,%eax
  37:	8b 10                	mov    (%eax),%edx
  39:	8b 43 04             	mov    0x4(%ebx),%eax
  3c:	83 c0 04             	add    $0x4,%eax
  3f:	8b 00                	mov    (%eax),%eax
  41:	83 ec 08             	sub    $0x8,%esp
  44:	52                   	push   %edx
  45:	50                   	push   %eax
  46:	e8 08 03 00 00       	call   353 <link>
  4b:	83 c4 10             	add    $0x10,%esp
  4e:	85 c0                	test   %eax,%eax
  50:	79 21                	jns    73 <main+0x73>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  52:	8b 43 04             	mov    0x4(%ebx),%eax
  55:	83 c0 08             	add    $0x8,%eax
  58:	8b 10                	mov    (%eax),%edx
  5a:	8b 43 04             	mov    0x4(%ebx),%eax
  5d:	83 c0 04             	add    $0x4,%eax
  60:	8b 00                	mov    (%eax),%eax
  62:	52                   	push   %edx
  63:	50                   	push   %eax
  64:	68 59 08 00 00       	push   $0x859
  69:	6a 02                	push   $0x2
  6b:	e8 0f 04 00 00       	call   47f <printf>
  70:	83 c4 10             	add    $0x10,%esp
  exit();
  73:	e8 7b 02 00 00       	call   2f3 <exit>

00000078 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  78:	55                   	push   %ebp
  79:	89 e5                	mov    %esp,%ebp
  7b:	57                   	push   %edi
  7c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80:	8b 55 10             	mov    0x10(%ebp),%edx
  83:	8b 45 0c             	mov    0xc(%ebp),%eax
  86:	89 cb                	mov    %ecx,%ebx
  88:	89 df                	mov    %ebx,%edi
  8a:	89 d1                	mov    %edx,%ecx
  8c:	fc                   	cld
  8d:	f3 aa                	rep stos %al,%es:(%edi)
  8f:	89 ca                	mov    %ecx,%edx
  91:	89 fb                	mov    %edi,%ebx
  93:	89 5d 08             	mov    %ebx,0x8(%ebp)
  96:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  99:	90                   	nop
  9a:	5b                   	pop    %ebx
  9b:	5f                   	pop    %edi
  9c:	5d                   	pop    %ebp
  9d:	c3                   	ret

0000009e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  9e:	f3 0f 1e fb          	endbr32
  a2:	55                   	push   %ebp
  a3:	89 e5                	mov    %esp,%ebp
  a5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  a8:	8b 45 08             	mov    0x8(%ebp),%eax
  ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  ae:	90                   	nop
  af:	8b 55 0c             	mov    0xc(%ebp),%edx
  b2:	8d 42 01             	lea    0x1(%edx),%eax
  b5:	89 45 0c             	mov    %eax,0xc(%ebp)
  b8:	8b 45 08             	mov    0x8(%ebp),%eax
  bb:	8d 48 01             	lea    0x1(%eax),%ecx
  be:	89 4d 08             	mov    %ecx,0x8(%ebp)
  c1:	0f b6 12             	movzbl (%edx),%edx
  c4:	88 10                	mov    %dl,(%eax)
  c6:	0f b6 00             	movzbl (%eax),%eax
  c9:	84 c0                	test   %al,%al
  cb:	75 e2                	jne    af <strcpy+0x11>
    ;
  return os;
  cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  d0:	c9                   	leave
  d1:	c3                   	ret

000000d2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d2:	f3 0f 1e fb          	endbr32
  d6:	55                   	push   %ebp
  d7:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  d9:	eb 08                	jmp    e3 <strcmp+0x11>
    p++, q++;
  db:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  df:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  e3:	8b 45 08             	mov    0x8(%ebp),%eax
  e6:	0f b6 00             	movzbl (%eax),%eax
  e9:	84 c0                	test   %al,%al
  eb:	74 10                	je     fd <strcmp+0x2b>
  ed:	8b 45 08             	mov    0x8(%ebp),%eax
  f0:	0f b6 10             	movzbl (%eax),%edx
  f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  f6:	0f b6 00             	movzbl (%eax),%eax
  f9:	38 c2                	cmp    %al,%dl
  fb:	74 de                	je     db <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
  fd:	8b 45 08             	mov    0x8(%ebp),%eax
 100:	0f b6 00             	movzbl (%eax),%eax
 103:	0f b6 d0             	movzbl %al,%edx
 106:	8b 45 0c             	mov    0xc(%ebp),%eax
 109:	0f b6 00             	movzbl (%eax),%eax
 10c:	0f b6 c0             	movzbl %al,%eax
 10f:	29 c2                	sub    %eax,%edx
 111:	89 d0                	mov    %edx,%eax
}
 113:	5d                   	pop    %ebp
 114:	c3                   	ret

00000115 <strlen>:

uint
strlen(char *s)
{
 115:	f3 0f 1e fb          	endbr32
 119:	55                   	push   %ebp
 11a:	89 e5                	mov    %esp,%ebp
 11c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 11f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 126:	eb 04                	jmp    12c <strlen+0x17>
 128:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 12c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 12f:	8b 45 08             	mov    0x8(%ebp),%eax
 132:	01 d0                	add    %edx,%eax
 134:	0f b6 00             	movzbl (%eax),%eax
 137:	84 c0                	test   %al,%al
 139:	75 ed                	jne    128 <strlen+0x13>
    ;
  return n;
 13b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 13e:	c9                   	leave
 13f:	c3                   	ret

00000140 <memset>:

void*
memset(void *dst, int c, uint n)
{
 140:	f3 0f 1e fb          	endbr32
 144:	55                   	push   %ebp
 145:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 147:	8b 45 10             	mov    0x10(%ebp),%eax
 14a:	50                   	push   %eax
 14b:	ff 75 0c             	push   0xc(%ebp)
 14e:	ff 75 08             	push   0x8(%ebp)
 151:	e8 22 ff ff ff       	call   78 <stosb>
 156:	83 c4 0c             	add    $0xc,%esp
  return dst;
 159:	8b 45 08             	mov    0x8(%ebp),%eax
}
 15c:	c9                   	leave
 15d:	c3                   	ret

0000015e <strchr>:

char*
strchr(const char *s, char c)
{
 15e:	f3 0f 1e fb          	endbr32
 162:	55                   	push   %ebp
 163:	89 e5                	mov    %esp,%ebp
 165:	83 ec 04             	sub    $0x4,%esp
 168:	8b 45 0c             	mov    0xc(%ebp),%eax
 16b:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 16e:	eb 14                	jmp    184 <strchr+0x26>
    if(*s == c)
 170:	8b 45 08             	mov    0x8(%ebp),%eax
 173:	0f b6 00             	movzbl (%eax),%eax
 176:	38 45 fc             	cmp    %al,-0x4(%ebp)
 179:	75 05                	jne    180 <strchr+0x22>
      return (char*)s;
 17b:	8b 45 08             	mov    0x8(%ebp),%eax
 17e:	eb 13                	jmp    193 <strchr+0x35>
  for(; *s; s++)
 180:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 184:	8b 45 08             	mov    0x8(%ebp),%eax
 187:	0f b6 00             	movzbl (%eax),%eax
 18a:	84 c0                	test   %al,%al
 18c:	75 e2                	jne    170 <strchr+0x12>
  return 0;
 18e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 193:	c9                   	leave
 194:	c3                   	ret

00000195 <gets>:

char*
gets(char *buf, int max)
{
 195:	f3 0f 1e fb          	endbr32
 199:	55                   	push   %ebp
 19a:	89 e5                	mov    %esp,%ebp
 19c:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1a6:	eb 42                	jmp    1ea <gets+0x55>
    cc = read(0, &c, 1);
 1a8:	83 ec 04             	sub    $0x4,%esp
 1ab:	6a 01                	push   $0x1
 1ad:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1b0:	50                   	push   %eax
 1b1:	6a 00                	push   $0x0
 1b3:	e8 53 01 00 00       	call   30b <read>
 1b8:	83 c4 10             	add    $0x10,%esp
 1bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1c2:	7e 33                	jle    1f7 <gets+0x62>
      break;
    buf[i++] = c;
 1c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c7:	8d 50 01             	lea    0x1(%eax),%edx
 1ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1cd:	89 c2                	mov    %eax,%edx
 1cf:	8b 45 08             	mov    0x8(%ebp),%eax
 1d2:	01 c2                	add    %eax,%edx
 1d4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1da:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1de:	3c 0a                	cmp    $0xa,%al
 1e0:	74 16                	je     1f8 <gets+0x63>
 1e2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e6:	3c 0d                	cmp    $0xd,%al
 1e8:	74 0e                	je     1f8 <gets+0x63>
  for(i=0; i+1 < max; ){
 1ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ed:	83 c0 01             	add    $0x1,%eax
 1f0:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1f3:	7f b3                	jg     1a8 <gets+0x13>
 1f5:	eb 01                	jmp    1f8 <gets+0x63>
      break;
 1f7:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1fb:	8b 45 08             	mov    0x8(%ebp),%eax
 1fe:	01 d0                	add    %edx,%eax
 200:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 203:	8b 45 08             	mov    0x8(%ebp),%eax
}
 206:	c9                   	leave
 207:	c3                   	ret

00000208 <stat>:

int
stat(char *n, struct stat *st)
{
 208:	f3 0f 1e fb          	endbr32
 20c:	55                   	push   %ebp
 20d:	89 e5                	mov    %esp,%ebp
 20f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 212:	83 ec 08             	sub    $0x8,%esp
 215:	6a 00                	push   $0x0
 217:	ff 75 08             	push   0x8(%ebp)
 21a:	e8 14 01 00 00       	call   333 <open>
 21f:	83 c4 10             	add    $0x10,%esp
 222:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 225:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 229:	79 07                	jns    232 <stat+0x2a>
    return -1;
 22b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 230:	eb 25                	jmp    257 <stat+0x4f>
  r = fstat(fd, st);
 232:	83 ec 08             	sub    $0x8,%esp
 235:	ff 75 0c             	push   0xc(%ebp)
 238:	ff 75 f4             	push   -0xc(%ebp)
 23b:	e8 0b 01 00 00       	call   34b <fstat>
 240:	83 c4 10             	add    $0x10,%esp
 243:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 246:	83 ec 0c             	sub    $0xc,%esp
 249:	ff 75 f4             	push   -0xc(%ebp)
 24c:	e8 ca 00 00 00       	call   31b <close>
 251:	83 c4 10             	add    $0x10,%esp
  return r;
 254:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 257:	c9                   	leave
 258:	c3                   	ret

00000259 <atoi>:

int
atoi(const char *s)
{
 259:	f3 0f 1e fb          	endbr32
 25d:	55                   	push   %ebp
 25e:	89 e5                	mov    %esp,%ebp
 260:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 263:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 26a:	eb 25                	jmp    291 <atoi+0x38>
    n = n*10 + *s++ - '0';
 26c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 26f:	89 d0                	mov    %edx,%eax
 271:	c1 e0 02             	shl    $0x2,%eax
 274:	01 d0                	add    %edx,%eax
 276:	01 c0                	add    %eax,%eax
 278:	89 c1                	mov    %eax,%ecx
 27a:	8b 45 08             	mov    0x8(%ebp),%eax
 27d:	8d 50 01             	lea    0x1(%eax),%edx
 280:	89 55 08             	mov    %edx,0x8(%ebp)
 283:	0f b6 00             	movzbl (%eax),%eax
 286:	0f be c0             	movsbl %al,%eax
 289:	01 c8                	add    %ecx,%eax
 28b:	83 e8 30             	sub    $0x30,%eax
 28e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 291:	8b 45 08             	mov    0x8(%ebp),%eax
 294:	0f b6 00             	movzbl (%eax),%eax
 297:	3c 2f                	cmp    $0x2f,%al
 299:	7e 0a                	jle    2a5 <atoi+0x4c>
 29b:	8b 45 08             	mov    0x8(%ebp),%eax
 29e:	0f b6 00             	movzbl (%eax),%eax
 2a1:	3c 39                	cmp    $0x39,%al
 2a3:	7e c7                	jle    26c <atoi+0x13>
  return n;
 2a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2a8:	c9                   	leave
 2a9:	c3                   	ret

000002aa <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2aa:	f3 0f 1e fb          	endbr32
 2ae:	55                   	push   %ebp
 2af:	89 e5                	mov    %esp,%ebp
 2b1:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2b4:	8b 45 08             	mov    0x8(%ebp),%eax
 2b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 2bd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2c0:	eb 17                	jmp    2d9 <memmove+0x2f>
    *dst++ = *src++;
 2c2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2c5:	8d 42 01             	lea    0x1(%edx),%eax
 2c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2ce:	8d 48 01             	lea    0x1(%eax),%ecx
 2d1:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 2d4:	0f b6 12             	movzbl (%edx),%edx
 2d7:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2d9:	8b 45 10             	mov    0x10(%ebp),%eax
 2dc:	8d 50 ff             	lea    -0x1(%eax),%edx
 2df:	89 55 10             	mov    %edx,0x10(%ebp)
 2e2:	85 c0                	test   %eax,%eax
 2e4:	7f dc                	jg     2c2 <memmove+0x18>
  return vdst;
 2e6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2e9:	c9                   	leave
 2ea:	c3                   	ret

000002eb <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2eb:	b8 01 00 00 00       	mov    $0x1,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret

000002f3 <exit>:
SYSCALL(exit)
 2f3:	b8 02 00 00 00       	mov    $0x2,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret

000002fb <wait>:
SYSCALL(wait)
 2fb:	b8 03 00 00 00       	mov    $0x3,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret

00000303 <pipe>:
SYSCALL(pipe)
 303:	b8 04 00 00 00       	mov    $0x4,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret

0000030b <read>:
SYSCALL(read)
 30b:	b8 05 00 00 00       	mov    $0x5,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret

00000313 <write>:
SYSCALL(write)
 313:	b8 10 00 00 00       	mov    $0x10,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret

0000031b <close>:
SYSCALL(close)
 31b:	b8 15 00 00 00       	mov    $0x15,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret

00000323 <kill>:
SYSCALL(kill)
 323:	b8 06 00 00 00       	mov    $0x6,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret

0000032b <exec>:
SYSCALL(exec)
 32b:	b8 07 00 00 00       	mov    $0x7,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret

00000333 <open>:
SYSCALL(open)
 333:	b8 0f 00 00 00       	mov    $0xf,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret

0000033b <mknod>:
SYSCALL(mknod)
 33b:	b8 11 00 00 00       	mov    $0x11,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret

00000343 <unlink>:
SYSCALL(unlink)
 343:	b8 12 00 00 00       	mov    $0x12,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret

0000034b <fstat>:
SYSCALL(fstat)
 34b:	b8 08 00 00 00       	mov    $0x8,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret

00000353 <link>:
SYSCALL(link)
 353:	b8 13 00 00 00       	mov    $0x13,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret

0000035b <mkdir>:
SYSCALL(mkdir)
 35b:	b8 14 00 00 00       	mov    $0x14,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	ret

00000363 <chdir>:
SYSCALL(chdir)
 363:	b8 09 00 00 00       	mov    $0x9,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	ret

0000036b <dup>:
SYSCALL(dup)
 36b:	b8 0a 00 00 00       	mov    $0xa,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	ret

00000373 <getpid>:
SYSCALL(getpid)
 373:	b8 0b 00 00 00       	mov    $0xb,%eax
 378:	cd 40                	int    $0x40
 37a:	c3                   	ret

0000037b <sbrk>:
SYSCALL(sbrk)
 37b:	b8 0c 00 00 00       	mov    $0xc,%eax
 380:	cd 40                	int    $0x40
 382:	c3                   	ret

00000383 <sleep>:
SYSCALL(sleep)
 383:	b8 0d 00 00 00       	mov    $0xd,%eax
 388:	cd 40                	int    $0x40
 38a:	c3                   	ret

0000038b <uptime>:
SYSCALL(uptime)
 38b:	b8 0e 00 00 00       	mov    $0xe,%eax
 390:	cd 40                	int    $0x40
 392:	c3                   	ret

00000393 <uthread_init>:

SYSCALL(uthread_init)
 393:	b8 16 00 00 00       	mov    $0x16,%eax
 398:	cd 40                	int    $0x40
 39a:	c3                   	ret

0000039b <printpt>:
 39b:	b8 17 00 00 00       	mov    $0x17,%eax
 3a0:	cd 40                	int    $0x40
 3a2:	c3                   	ret

000003a3 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3a3:	f3 0f 1e fb          	endbr32
 3a7:	55                   	push   %ebp
 3a8:	89 e5                	mov    %esp,%ebp
 3aa:	83 ec 18             	sub    $0x18,%esp
 3ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b0:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3b3:	83 ec 04             	sub    $0x4,%esp
 3b6:	6a 01                	push   $0x1
 3b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3bb:	50                   	push   %eax
 3bc:	ff 75 08             	push   0x8(%ebp)
 3bf:	e8 4f ff ff ff       	call   313 <write>
 3c4:	83 c4 10             	add    $0x10,%esp
}
 3c7:	90                   	nop
 3c8:	c9                   	leave
 3c9:	c3                   	ret

000003ca <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ca:	f3 0f 1e fb          	endbr32
 3ce:	55                   	push   %ebp
 3cf:	89 e5                	mov    %esp,%ebp
 3d1:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3d4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3db:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3df:	74 17                	je     3f8 <printint+0x2e>
 3e1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3e5:	79 11                	jns    3f8 <printint+0x2e>
    neg = 1;
 3e7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f1:	f7 d8                	neg    %eax
 3f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3f6:	eb 06                	jmp    3fe <printint+0x34>
  } else {
    x = xx;
 3f8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 405:	8b 4d 10             	mov    0x10(%ebp),%ecx
 408:	8b 45 ec             	mov    -0x14(%ebp),%eax
 40b:	ba 00 00 00 00       	mov    $0x0,%edx
 410:	f7 f1                	div    %ecx
 412:	89 d1                	mov    %edx,%ecx
 414:	8b 45 f4             	mov    -0xc(%ebp),%eax
 417:	8d 50 01             	lea    0x1(%eax),%edx
 41a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 41d:	0f b6 91 bc 0a 00 00 	movzbl 0xabc(%ecx),%edx
 424:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 428:	8b 4d 10             	mov    0x10(%ebp),%ecx
 42b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 42e:	ba 00 00 00 00       	mov    $0x0,%edx
 433:	f7 f1                	div    %ecx
 435:	89 45 ec             	mov    %eax,-0x14(%ebp)
 438:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 43c:	75 c7                	jne    405 <printint+0x3b>
  if(neg)
 43e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 442:	74 2d                	je     471 <printint+0xa7>
    buf[i++] = '-';
 444:	8b 45 f4             	mov    -0xc(%ebp),%eax
 447:	8d 50 01             	lea    0x1(%eax),%edx
 44a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 44d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 452:	eb 1d                	jmp    471 <printint+0xa7>
    putc(fd, buf[i]);
 454:	8d 55 dc             	lea    -0x24(%ebp),%edx
 457:	8b 45 f4             	mov    -0xc(%ebp),%eax
 45a:	01 d0                	add    %edx,%eax
 45c:	0f b6 00             	movzbl (%eax),%eax
 45f:	0f be c0             	movsbl %al,%eax
 462:	83 ec 08             	sub    $0x8,%esp
 465:	50                   	push   %eax
 466:	ff 75 08             	push   0x8(%ebp)
 469:	e8 35 ff ff ff       	call   3a3 <putc>
 46e:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 471:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 475:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 479:	79 d9                	jns    454 <printint+0x8a>
}
 47b:	90                   	nop
 47c:	90                   	nop
 47d:	c9                   	leave
 47e:	c3                   	ret

0000047f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 47f:	f3 0f 1e fb          	endbr32
 483:	55                   	push   %ebp
 484:	89 e5                	mov    %esp,%ebp
 486:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 489:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 490:	8d 45 0c             	lea    0xc(%ebp),%eax
 493:	83 c0 04             	add    $0x4,%eax
 496:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 499:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4a0:	e9 59 01 00 00       	jmp    5fe <printf+0x17f>
    c = fmt[i] & 0xff;
 4a5:	8b 55 0c             	mov    0xc(%ebp),%edx
 4a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4ab:	01 d0                	add    %edx,%eax
 4ad:	0f b6 00             	movzbl (%eax),%eax
 4b0:	0f be c0             	movsbl %al,%eax
 4b3:	25 ff 00 00 00       	and    $0xff,%eax
 4b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4bb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4bf:	75 2c                	jne    4ed <printf+0x6e>
      if(c == '%'){
 4c1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4c5:	75 0c                	jne    4d3 <printf+0x54>
        state = '%';
 4c7:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4ce:	e9 27 01 00 00       	jmp    5fa <printf+0x17b>
      } else {
        putc(fd, c);
 4d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4d6:	0f be c0             	movsbl %al,%eax
 4d9:	83 ec 08             	sub    $0x8,%esp
 4dc:	50                   	push   %eax
 4dd:	ff 75 08             	push   0x8(%ebp)
 4e0:	e8 be fe ff ff       	call   3a3 <putc>
 4e5:	83 c4 10             	add    $0x10,%esp
 4e8:	e9 0d 01 00 00       	jmp    5fa <printf+0x17b>
      }
    } else if(state == '%'){
 4ed:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4f1:	0f 85 03 01 00 00    	jne    5fa <printf+0x17b>
      if(c == 'd'){
 4f7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4fb:	75 1e                	jne    51b <printf+0x9c>
        printint(fd, *ap, 10, 1);
 4fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 500:	8b 00                	mov    (%eax),%eax
 502:	6a 01                	push   $0x1
 504:	6a 0a                	push   $0xa
 506:	50                   	push   %eax
 507:	ff 75 08             	push   0x8(%ebp)
 50a:	e8 bb fe ff ff       	call   3ca <printint>
 50f:	83 c4 10             	add    $0x10,%esp
        ap++;
 512:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 516:	e9 d8 00 00 00       	jmp    5f3 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 51b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 51f:	74 06                	je     527 <printf+0xa8>
 521:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 525:	75 1e                	jne    545 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 527:	8b 45 e8             	mov    -0x18(%ebp),%eax
 52a:	8b 00                	mov    (%eax),%eax
 52c:	6a 00                	push   $0x0
 52e:	6a 10                	push   $0x10
 530:	50                   	push   %eax
 531:	ff 75 08             	push   0x8(%ebp)
 534:	e8 91 fe ff ff       	call   3ca <printint>
 539:	83 c4 10             	add    $0x10,%esp
        ap++;
 53c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 540:	e9 ae 00 00 00       	jmp    5f3 <printf+0x174>
      } else if(c == 's'){
 545:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 549:	75 43                	jne    58e <printf+0x10f>
        s = (char*)*ap;
 54b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 54e:	8b 00                	mov    (%eax),%eax
 550:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 553:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 557:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 55b:	75 25                	jne    582 <printf+0x103>
          s = "(null)";
 55d:	c7 45 f4 6d 08 00 00 	movl   $0x86d,-0xc(%ebp)
        while(*s != 0){
 564:	eb 1c                	jmp    582 <printf+0x103>
          putc(fd, *s);
 566:	8b 45 f4             	mov    -0xc(%ebp),%eax
 569:	0f b6 00             	movzbl (%eax),%eax
 56c:	0f be c0             	movsbl %al,%eax
 56f:	83 ec 08             	sub    $0x8,%esp
 572:	50                   	push   %eax
 573:	ff 75 08             	push   0x8(%ebp)
 576:	e8 28 fe ff ff       	call   3a3 <putc>
 57b:	83 c4 10             	add    $0x10,%esp
          s++;
 57e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 582:	8b 45 f4             	mov    -0xc(%ebp),%eax
 585:	0f b6 00             	movzbl (%eax),%eax
 588:	84 c0                	test   %al,%al
 58a:	75 da                	jne    566 <printf+0xe7>
 58c:	eb 65                	jmp    5f3 <printf+0x174>
        }
      } else if(c == 'c'){
 58e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 592:	75 1d                	jne    5b1 <printf+0x132>
        putc(fd, *ap);
 594:	8b 45 e8             	mov    -0x18(%ebp),%eax
 597:	8b 00                	mov    (%eax),%eax
 599:	0f be c0             	movsbl %al,%eax
 59c:	83 ec 08             	sub    $0x8,%esp
 59f:	50                   	push   %eax
 5a0:	ff 75 08             	push   0x8(%ebp)
 5a3:	e8 fb fd ff ff       	call   3a3 <putc>
 5a8:	83 c4 10             	add    $0x10,%esp
        ap++;
 5ab:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5af:	eb 42                	jmp    5f3 <printf+0x174>
      } else if(c == '%'){
 5b1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5b5:	75 17                	jne    5ce <printf+0x14f>
        putc(fd, c);
 5b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ba:	0f be c0             	movsbl %al,%eax
 5bd:	83 ec 08             	sub    $0x8,%esp
 5c0:	50                   	push   %eax
 5c1:	ff 75 08             	push   0x8(%ebp)
 5c4:	e8 da fd ff ff       	call   3a3 <putc>
 5c9:	83 c4 10             	add    $0x10,%esp
 5cc:	eb 25                	jmp    5f3 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ce:	83 ec 08             	sub    $0x8,%esp
 5d1:	6a 25                	push   $0x25
 5d3:	ff 75 08             	push   0x8(%ebp)
 5d6:	e8 c8 fd ff ff       	call   3a3 <putc>
 5db:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5e1:	0f be c0             	movsbl %al,%eax
 5e4:	83 ec 08             	sub    $0x8,%esp
 5e7:	50                   	push   %eax
 5e8:	ff 75 08             	push   0x8(%ebp)
 5eb:	e8 b3 fd ff ff       	call   3a3 <putc>
 5f0:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5f3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5fa:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5fe:	8b 55 0c             	mov    0xc(%ebp),%edx
 601:	8b 45 f0             	mov    -0x10(%ebp),%eax
 604:	01 d0                	add    %edx,%eax
 606:	0f b6 00             	movzbl (%eax),%eax
 609:	84 c0                	test   %al,%al
 60b:	0f 85 94 fe ff ff    	jne    4a5 <printf+0x26>
    }
  }
}
 611:	90                   	nop
 612:	90                   	nop
 613:	c9                   	leave
 614:	c3                   	ret

00000615 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 615:	f3 0f 1e fb          	endbr32
 619:	55                   	push   %ebp
 61a:	89 e5                	mov    %esp,%ebp
 61c:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 61f:	8b 45 08             	mov    0x8(%ebp),%eax
 622:	83 e8 08             	sub    $0x8,%eax
 625:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 628:	a1 d8 0a 00 00       	mov    0xad8,%eax
 62d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 630:	eb 24                	jmp    656 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 632:	8b 45 fc             	mov    -0x4(%ebp),%eax
 635:	8b 00                	mov    (%eax),%eax
 637:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 63a:	72 12                	jb     64e <free+0x39>
 63c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 642:	77 24                	ja     668 <free+0x53>
 644:	8b 45 fc             	mov    -0x4(%ebp),%eax
 647:	8b 00                	mov    (%eax),%eax
 649:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 64c:	72 1a                	jb     668 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 64e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 651:	8b 00                	mov    (%eax),%eax
 653:	89 45 fc             	mov    %eax,-0x4(%ebp)
 656:	8b 45 f8             	mov    -0x8(%ebp),%eax
 659:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 65c:	76 d4                	jbe    632 <free+0x1d>
 65e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 661:	8b 00                	mov    (%eax),%eax
 663:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 666:	73 ca                	jae    632 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 668:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66b:	8b 40 04             	mov    0x4(%eax),%eax
 66e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 675:	8b 45 f8             	mov    -0x8(%ebp),%eax
 678:	01 c2                	add    %eax,%edx
 67a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67d:	8b 00                	mov    (%eax),%eax
 67f:	39 c2                	cmp    %eax,%edx
 681:	75 24                	jne    6a7 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 683:	8b 45 f8             	mov    -0x8(%ebp),%eax
 686:	8b 50 04             	mov    0x4(%eax),%edx
 689:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68c:	8b 00                	mov    (%eax),%eax
 68e:	8b 40 04             	mov    0x4(%eax),%eax
 691:	01 c2                	add    %eax,%edx
 693:	8b 45 f8             	mov    -0x8(%ebp),%eax
 696:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 699:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69c:	8b 00                	mov    (%eax),%eax
 69e:	8b 10                	mov    (%eax),%edx
 6a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a3:	89 10                	mov    %edx,(%eax)
 6a5:	eb 0a                	jmp    6b1 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 6a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6aa:	8b 10                	mov    (%eax),%edx
 6ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6af:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b4:	8b 40 04             	mov    0x4(%eax),%eax
 6b7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c1:	01 d0                	add    %edx,%eax
 6c3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6c6:	75 20                	jne    6e8 <free+0xd3>
    p->s.size += bp->s.size;
 6c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cb:	8b 50 04             	mov    0x4(%eax),%edx
 6ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d1:	8b 40 04             	mov    0x4(%eax),%eax
 6d4:	01 c2                	add    %eax,%edx
 6d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d9:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6df:	8b 10                	mov    (%eax),%edx
 6e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e4:	89 10                	mov    %edx,(%eax)
 6e6:	eb 08                	jmp    6f0 <free+0xdb>
  } else
    p->s.ptr = bp;
 6e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6eb:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6ee:	89 10                	mov    %edx,(%eax)
  freep = p;
 6f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f3:	a3 d8 0a 00 00       	mov    %eax,0xad8
}
 6f8:	90                   	nop
 6f9:	c9                   	leave
 6fa:	c3                   	ret

000006fb <morecore>:

static Header*
morecore(uint nu)
{
 6fb:	f3 0f 1e fb          	endbr32
 6ff:	55                   	push   %ebp
 700:	89 e5                	mov    %esp,%ebp
 702:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 705:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 70c:	77 07                	ja     715 <morecore+0x1a>
    nu = 4096;
 70e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 715:	8b 45 08             	mov    0x8(%ebp),%eax
 718:	c1 e0 03             	shl    $0x3,%eax
 71b:	83 ec 0c             	sub    $0xc,%esp
 71e:	50                   	push   %eax
 71f:	e8 57 fc ff ff       	call   37b <sbrk>
 724:	83 c4 10             	add    $0x10,%esp
 727:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 72a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 72e:	75 07                	jne    737 <morecore+0x3c>
    return 0;
 730:	b8 00 00 00 00       	mov    $0x0,%eax
 735:	eb 26                	jmp    75d <morecore+0x62>
  hp = (Header*)p;
 737:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 73d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 740:	8b 55 08             	mov    0x8(%ebp),%edx
 743:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 746:	8b 45 f0             	mov    -0x10(%ebp),%eax
 749:	83 c0 08             	add    $0x8,%eax
 74c:	83 ec 0c             	sub    $0xc,%esp
 74f:	50                   	push   %eax
 750:	e8 c0 fe ff ff       	call   615 <free>
 755:	83 c4 10             	add    $0x10,%esp
  return freep;
 758:	a1 d8 0a 00 00       	mov    0xad8,%eax
}
 75d:	c9                   	leave
 75e:	c3                   	ret

0000075f <malloc>:

void*
malloc(uint nbytes)
{
 75f:	f3 0f 1e fb          	endbr32
 763:	55                   	push   %ebp
 764:	89 e5                	mov    %esp,%ebp
 766:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 769:	8b 45 08             	mov    0x8(%ebp),%eax
 76c:	83 c0 07             	add    $0x7,%eax
 76f:	c1 e8 03             	shr    $0x3,%eax
 772:	83 c0 01             	add    $0x1,%eax
 775:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 778:	a1 d8 0a 00 00       	mov    0xad8,%eax
 77d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 780:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 784:	75 23                	jne    7a9 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 786:	c7 45 f0 d0 0a 00 00 	movl   $0xad0,-0x10(%ebp)
 78d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 790:	a3 d8 0a 00 00       	mov    %eax,0xad8
 795:	a1 d8 0a 00 00       	mov    0xad8,%eax
 79a:	a3 d0 0a 00 00       	mov    %eax,0xad0
    base.s.size = 0;
 79f:	c7 05 d4 0a 00 00 00 	movl   $0x0,0xad4
 7a6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ac:	8b 00                	mov    (%eax),%eax
 7ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b4:	8b 40 04             	mov    0x4(%eax),%eax
 7b7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7ba:	77 4d                	ja     809 <malloc+0xaa>
      if(p->s.size == nunits)
 7bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bf:	8b 40 04             	mov    0x4(%eax),%eax
 7c2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7c5:	75 0c                	jne    7d3 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 7c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ca:	8b 10                	mov    (%eax),%edx
 7cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cf:	89 10                	mov    %edx,(%eax)
 7d1:	eb 26                	jmp    7f9 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 7d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d6:	8b 40 04             	mov    0x4(%eax),%eax
 7d9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7dc:	89 c2                	mov    %eax,%edx
 7de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e7:	8b 40 04             	mov    0x4(%eax),%eax
 7ea:	c1 e0 03             	shl    $0x3,%eax
 7ed:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7f6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fc:	a3 d8 0a 00 00       	mov    %eax,0xad8
      return (void*)(p + 1);
 801:	8b 45 f4             	mov    -0xc(%ebp),%eax
 804:	83 c0 08             	add    $0x8,%eax
 807:	eb 3b                	jmp    844 <malloc+0xe5>
    }
    if(p == freep)
 809:	a1 d8 0a 00 00       	mov    0xad8,%eax
 80e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 811:	75 1e                	jne    831 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 813:	83 ec 0c             	sub    $0xc,%esp
 816:	ff 75 ec             	push   -0x14(%ebp)
 819:	e8 dd fe ff ff       	call   6fb <morecore>
 81e:	83 c4 10             	add    $0x10,%esp
 821:	89 45 f4             	mov    %eax,-0xc(%ebp)
 824:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 828:	75 07                	jne    831 <malloc+0xd2>
        return 0;
 82a:	b8 00 00 00 00       	mov    $0x0,%eax
 82f:	eb 13                	jmp    844 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 831:	8b 45 f4             	mov    -0xc(%ebp),%eax
 834:	89 45 f0             	mov    %eax,-0x10(%ebp)
 837:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83a:	8b 00                	mov    (%eax),%eax
 83c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 83f:	e9 6d ff ff ff       	jmp    7b1 <malloc+0x52>
  }
}
 844:	c9                   	leave
 845:	c3                   	ret
