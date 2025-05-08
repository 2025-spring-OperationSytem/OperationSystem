
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
  1d:	68 56 08 00 00       	push   $0x856
  22:	6a 02                	push   $0x2
  24:	e8 66 04 00 00       	call   48f <printf>
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
  64:	68 69 08 00 00       	push   $0x869
  69:	6a 02                	push   $0x2
  6b:	e8 1f 04 00 00       	call   48f <printf>
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

00000393 <getpinfo>:

SYSCALL(getpinfo)
 393:	b8 16 00 00 00       	mov    $0x16,%eax
 398:	cd 40                	int    $0x40
 39a:	c3                   	ret

0000039b <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 39b:	b8 17 00 00 00       	mov    $0x17,%eax
 3a0:	cd 40                	int    $0x40
 3a2:	c3                   	ret

000003a3 <yield>:
SYSCALL(yield)
 3a3:	b8 18 00 00 00       	mov    $0x18,%eax
 3a8:	cd 40                	int    $0x40
 3aa:	c3                   	ret

000003ab <getSchedPolicy>:
 3ab:	b8 19 00 00 00       	mov    $0x19,%eax
 3b0:	cd 40                	int    $0x40
 3b2:	c3                   	ret

000003b3 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3b3:	f3 0f 1e fb          	endbr32
 3b7:	55                   	push   %ebp
 3b8:	89 e5                	mov    %esp,%ebp
 3ba:	83 ec 18             	sub    $0x18,%esp
 3bd:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c0:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3c3:	83 ec 04             	sub    $0x4,%esp
 3c6:	6a 01                	push   $0x1
 3c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3cb:	50                   	push   %eax
 3cc:	ff 75 08             	push   0x8(%ebp)
 3cf:	e8 3f ff ff ff       	call   313 <write>
 3d4:	83 c4 10             	add    $0x10,%esp
}
 3d7:	90                   	nop
 3d8:	c9                   	leave
 3d9:	c3                   	ret

000003da <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3da:	f3 0f 1e fb          	endbr32
 3de:	55                   	push   %ebp
 3df:	89 e5                	mov    %esp,%ebp
 3e1:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3eb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3ef:	74 17                	je     408 <printint+0x2e>
 3f1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3f5:	79 11                	jns    408 <printint+0x2e>
    neg = 1;
 3f7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 401:	f7 d8                	neg    %eax
 403:	89 45 ec             	mov    %eax,-0x14(%ebp)
 406:	eb 06                	jmp    40e <printint+0x34>
  } else {
    x = xx;
 408:	8b 45 0c             	mov    0xc(%ebp),%eax
 40b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 40e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 415:	8b 4d 10             	mov    0x10(%ebp),%ecx
 418:	8b 45 ec             	mov    -0x14(%ebp),%eax
 41b:	ba 00 00 00 00       	mov    $0x0,%edx
 420:	f7 f1                	div    %ecx
 422:	89 d1                	mov    %edx,%ecx
 424:	8b 45 f4             	mov    -0xc(%ebp),%eax
 427:	8d 50 01             	lea    0x1(%eax),%edx
 42a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 42d:	0f b6 91 cc 0a 00 00 	movzbl 0xacc(%ecx),%edx
 434:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 438:	8b 4d 10             	mov    0x10(%ebp),%ecx
 43b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 43e:	ba 00 00 00 00       	mov    $0x0,%edx
 443:	f7 f1                	div    %ecx
 445:	89 45 ec             	mov    %eax,-0x14(%ebp)
 448:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 44c:	75 c7                	jne    415 <printint+0x3b>
  if(neg)
 44e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 452:	74 2d                	je     481 <printint+0xa7>
    buf[i++] = '-';
 454:	8b 45 f4             	mov    -0xc(%ebp),%eax
 457:	8d 50 01             	lea    0x1(%eax),%edx
 45a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 45d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 462:	eb 1d                	jmp    481 <printint+0xa7>
    putc(fd, buf[i]);
 464:	8d 55 dc             	lea    -0x24(%ebp),%edx
 467:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46a:	01 d0                	add    %edx,%eax
 46c:	0f b6 00             	movzbl (%eax),%eax
 46f:	0f be c0             	movsbl %al,%eax
 472:	83 ec 08             	sub    $0x8,%esp
 475:	50                   	push   %eax
 476:	ff 75 08             	push   0x8(%ebp)
 479:	e8 35 ff ff ff       	call   3b3 <putc>
 47e:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 481:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 485:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 489:	79 d9                	jns    464 <printint+0x8a>
}
 48b:	90                   	nop
 48c:	90                   	nop
 48d:	c9                   	leave
 48e:	c3                   	ret

0000048f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 48f:	f3 0f 1e fb          	endbr32
 493:	55                   	push   %ebp
 494:	89 e5                	mov    %esp,%ebp
 496:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 499:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4a0:	8d 45 0c             	lea    0xc(%ebp),%eax
 4a3:	83 c0 04             	add    $0x4,%eax
 4a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4b0:	e9 59 01 00 00       	jmp    60e <printf+0x17f>
    c = fmt[i] & 0xff;
 4b5:	8b 55 0c             	mov    0xc(%ebp),%edx
 4b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4bb:	01 d0                	add    %edx,%eax
 4bd:	0f b6 00             	movzbl (%eax),%eax
 4c0:	0f be c0             	movsbl %al,%eax
 4c3:	25 ff 00 00 00       	and    $0xff,%eax
 4c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4cb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4cf:	75 2c                	jne    4fd <printf+0x6e>
      if(c == '%'){
 4d1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4d5:	75 0c                	jne    4e3 <printf+0x54>
        state = '%';
 4d7:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4de:	e9 27 01 00 00       	jmp    60a <printf+0x17b>
      } else {
        putc(fd, c);
 4e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4e6:	0f be c0             	movsbl %al,%eax
 4e9:	83 ec 08             	sub    $0x8,%esp
 4ec:	50                   	push   %eax
 4ed:	ff 75 08             	push   0x8(%ebp)
 4f0:	e8 be fe ff ff       	call   3b3 <putc>
 4f5:	83 c4 10             	add    $0x10,%esp
 4f8:	e9 0d 01 00 00       	jmp    60a <printf+0x17b>
      }
    } else if(state == '%'){
 4fd:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 501:	0f 85 03 01 00 00    	jne    60a <printf+0x17b>
      if(c == 'd'){
 507:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 50b:	75 1e                	jne    52b <printf+0x9c>
        printint(fd, *ap, 10, 1);
 50d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 510:	8b 00                	mov    (%eax),%eax
 512:	6a 01                	push   $0x1
 514:	6a 0a                	push   $0xa
 516:	50                   	push   %eax
 517:	ff 75 08             	push   0x8(%ebp)
 51a:	e8 bb fe ff ff       	call   3da <printint>
 51f:	83 c4 10             	add    $0x10,%esp
        ap++;
 522:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 526:	e9 d8 00 00 00       	jmp    603 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 52b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 52f:	74 06                	je     537 <printf+0xa8>
 531:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 535:	75 1e                	jne    555 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 537:	8b 45 e8             	mov    -0x18(%ebp),%eax
 53a:	8b 00                	mov    (%eax),%eax
 53c:	6a 00                	push   $0x0
 53e:	6a 10                	push   $0x10
 540:	50                   	push   %eax
 541:	ff 75 08             	push   0x8(%ebp)
 544:	e8 91 fe ff ff       	call   3da <printint>
 549:	83 c4 10             	add    $0x10,%esp
        ap++;
 54c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 550:	e9 ae 00 00 00       	jmp    603 <printf+0x174>
      } else if(c == 's'){
 555:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 559:	75 43                	jne    59e <printf+0x10f>
        s = (char*)*ap;
 55b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55e:	8b 00                	mov    (%eax),%eax
 560:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 563:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 567:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 56b:	75 25                	jne    592 <printf+0x103>
          s = "(null)";
 56d:	c7 45 f4 7d 08 00 00 	movl   $0x87d,-0xc(%ebp)
        while(*s != 0){
 574:	eb 1c                	jmp    592 <printf+0x103>
          putc(fd, *s);
 576:	8b 45 f4             	mov    -0xc(%ebp),%eax
 579:	0f b6 00             	movzbl (%eax),%eax
 57c:	0f be c0             	movsbl %al,%eax
 57f:	83 ec 08             	sub    $0x8,%esp
 582:	50                   	push   %eax
 583:	ff 75 08             	push   0x8(%ebp)
 586:	e8 28 fe ff ff       	call   3b3 <putc>
 58b:	83 c4 10             	add    $0x10,%esp
          s++;
 58e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 592:	8b 45 f4             	mov    -0xc(%ebp),%eax
 595:	0f b6 00             	movzbl (%eax),%eax
 598:	84 c0                	test   %al,%al
 59a:	75 da                	jne    576 <printf+0xe7>
 59c:	eb 65                	jmp    603 <printf+0x174>
        }
      } else if(c == 'c'){
 59e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5a2:	75 1d                	jne    5c1 <printf+0x132>
        putc(fd, *ap);
 5a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a7:	8b 00                	mov    (%eax),%eax
 5a9:	0f be c0             	movsbl %al,%eax
 5ac:	83 ec 08             	sub    $0x8,%esp
 5af:	50                   	push   %eax
 5b0:	ff 75 08             	push   0x8(%ebp)
 5b3:	e8 fb fd ff ff       	call   3b3 <putc>
 5b8:	83 c4 10             	add    $0x10,%esp
        ap++;
 5bb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5bf:	eb 42                	jmp    603 <printf+0x174>
      } else if(c == '%'){
 5c1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5c5:	75 17                	jne    5de <printf+0x14f>
        putc(fd, c);
 5c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ca:	0f be c0             	movsbl %al,%eax
 5cd:	83 ec 08             	sub    $0x8,%esp
 5d0:	50                   	push   %eax
 5d1:	ff 75 08             	push   0x8(%ebp)
 5d4:	e8 da fd ff ff       	call   3b3 <putc>
 5d9:	83 c4 10             	add    $0x10,%esp
 5dc:	eb 25                	jmp    603 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5de:	83 ec 08             	sub    $0x8,%esp
 5e1:	6a 25                	push   $0x25
 5e3:	ff 75 08             	push   0x8(%ebp)
 5e6:	e8 c8 fd ff ff       	call   3b3 <putc>
 5eb:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5f1:	0f be c0             	movsbl %al,%eax
 5f4:	83 ec 08             	sub    $0x8,%esp
 5f7:	50                   	push   %eax
 5f8:	ff 75 08             	push   0x8(%ebp)
 5fb:	e8 b3 fd ff ff       	call   3b3 <putc>
 600:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 603:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 60a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 60e:	8b 55 0c             	mov    0xc(%ebp),%edx
 611:	8b 45 f0             	mov    -0x10(%ebp),%eax
 614:	01 d0                	add    %edx,%eax
 616:	0f b6 00             	movzbl (%eax),%eax
 619:	84 c0                	test   %al,%al
 61b:	0f 85 94 fe ff ff    	jne    4b5 <printf+0x26>
    }
  }
}
 621:	90                   	nop
 622:	90                   	nop
 623:	c9                   	leave
 624:	c3                   	ret

00000625 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 625:	f3 0f 1e fb          	endbr32
 629:	55                   	push   %ebp
 62a:	89 e5                	mov    %esp,%ebp
 62c:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 62f:	8b 45 08             	mov    0x8(%ebp),%eax
 632:	83 e8 08             	sub    $0x8,%eax
 635:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 638:	a1 e8 0a 00 00       	mov    0xae8,%eax
 63d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 640:	eb 24                	jmp    666 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 642:	8b 45 fc             	mov    -0x4(%ebp),%eax
 645:	8b 00                	mov    (%eax),%eax
 647:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 64a:	72 12                	jb     65e <free+0x39>
 64c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 652:	77 24                	ja     678 <free+0x53>
 654:	8b 45 fc             	mov    -0x4(%ebp),%eax
 657:	8b 00                	mov    (%eax),%eax
 659:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 65c:	72 1a                	jb     678 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 65e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 661:	8b 00                	mov    (%eax),%eax
 663:	89 45 fc             	mov    %eax,-0x4(%ebp)
 666:	8b 45 f8             	mov    -0x8(%ebp),%eax
 669:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 66c:	76 d4                	jbe    642 <free+0x1d>
 66e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 671:	8b 00                	mov    (%eax),%eax
 673:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 676:	73 ca                	jae    642 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 678:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67b:	8b 40 04             	mov    0x4(%eax),%eax
 67e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 685:	8b 45 f8             	mov    -0x8(%ebp),%eax
 688:	01 c2                	add    %eax,%edx
 68a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68d:	8b 00                	mov    (%eax),%eax
 68f:	39 c2                	cmp    %eax,%edx
 691:	75 24                	jne    6b7 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 693:	8b 45 f8             	mov    -0x8(%ebp),%eax
 696:	8b 50 04             	mov    0x4(%eax),%edx
 699:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69c:	8b 00                	mov    (%eax),%eax
 69e:	8b 40 04             	mov    0x4(%eax),%eax
 6a1:	01 c2                	add    %eax,%edx
 6a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a6:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ac:	8b 00                	mov    (%eax),%eax
 6ae:	8b 10                	mov    (%eax),%edx
 6b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b3:	89 10                	mov    %edx,(%eax)
 6b5:	eb 0a                	jmp    6c1 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 6b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ba:	8b 10                	mov    (%eax),%edx
 6bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6bf:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c4:	8b 40 04             	mov    0x4(%eax),%eax
 6c7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d1:	01 d0                	add    %edx,%eax
 6d3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6d6:	75 20                	jne    6f8 <free+0xd3>
    p->s.size += bp->s.size;
 6d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6db:	8b 50 04             	mov    0x4(%eax),%edx
 6de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e1:	8b 40 04             	mov    0x4(%eax),%eax
 6e4:	01 c2                	add    %eax,%edx
 6e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e9:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ef:	8b 10                	mov    (%eax),%edx
 6f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f4:	89 10                	mov    %edx,(%eax)
 6f6:	eb 08                	jmp    700 <free+0xdb>
  } else
    p->s.ptr = bp;
 6f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fb:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6fe:	89 10                	mov    %edx,(%eax)
  freep = p;
 700:	8b 45 fc             	mov    -0x4(%ebp),%eax
 703:	a3 e8 0a 00 00       	mov    %eax,0xae8
}
 708:	90                   	nop
 709:	c9                   	leave
 70a:	c3                   	ret

0000070b <morecore>:

static Header*
morecore(uint nu)
{
 70b:	f3 0f 1e fb          	endbr32
 70f:	55                   	push   %ebp
 710:	89 e5                	mov    %esp,%ebp
 712:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 715:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 71c:	77 07                	ja     725 <morecore+0x1a>
    nu = 4096;
 71e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 725:	8b 45 08             	mov    0x8(%ebp),%eax
 728:	c1 e0 03             	shl    $0x3,%eax
 72b:	83 ec 0c             	sub    $0xc,%esp
 72e:	50                   	push   %eax
 72f:	e8 47 fc ff ff       	call   37b <sbrk>
 734:	83 c4 10             	add    $0x10,%esp
 737:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 73a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 73e:	75 07                	jne    747 <morecore+0x3c>
    return 0;
 740:	b8 00 00 00 00       	mov    $0x0,%eax
 745:	eb 26                	jmp    76d <morecore+0x62>
  hp = (Header*)p;
 747:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 74d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 750:	8b 55 08             	mov    0x8(%ebp),%edx
 753:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 756:	8b 45 f0             	mov    -0x10(%ebp),%eax
 759:	83 c0 08             	add    $0x8,%eax
 75c:	83 ec 0c             	sub    $0xc,%esp
 75f:	50                   	push   %eax
 760:	e8 c0 fe ff ff       	call   625 <free>
 765:	83 c4 10             	add    $0x10,%esp
  return freep;
 768:	a1 e8 0a 00 00       	mov    0xae8,%eax
}
 76d:	c9                   	leave
 76e:	c3                   	ret

0000076f <malloc>:

void*
malloc(uint nbytes)
{
 76f:	f3 0f 1e fb          	endbr32
 773:	55                   	push   %ebp
 774:	89 e5                	mov    %esp,%ebp
 776:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 779:	8b 45 08             	mov    0x8(%ebp),%eax
 77c:	83 c0 07             	add    $0x7,%eax
 77f:	c1 e8 03             	shr    $0x3,%eax
 782:	83 c0 01             	add    $0x1,%eax
 785:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 788:	a1 e8 0a 00 00       	mov    0xae8,%eax
 78d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 790:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 794:	75 23                	jne    7b9 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 796:	c7 45 f0 e0 0a 00 00 	movl   $0xae0,-0x10(%ebp)
 79d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a0:	a3 e8 0a 00 00       	mov    %eax,0xae8
 7a5:	a1 e8 0a 00 00       	mov    0xae8,%eax
 7aa:	a3 e0 0a 00 00       	mov    %eax,0xae0
    base.s.size = 0;
 7af:	c7 05 e4 0a 00 00 00 	movl   $0x0,0xae4
 7b6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7bc:	8b 00                	mov    (%eax),%eax
 7be:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c4:	8b 40 04             	mov    0x4(%eax),%eax
 7c7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7ca:	77 4d                	ja     819 <malloc+0xaa>
      if(p->s.size == nunits)
 7cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cf:	8b 40 04             	mov    0x4(%eax),%eax
 7d2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7d5:	75 0c                	jne    7e3 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 7d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7da:	8b 10                	mov    (%eax),%edx
 7dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7df:	89 10                	mov    %edx,(%eax)
 7e1:	eb 26                	jmp    809 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 7e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e6:	8b 40 04             	mov    0x4(%eax),%eax
 7e9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7ec:	89 c2                	mov    %eax,%edx
 7ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f7:	8b 40 04             	mov    0x4(%eax),%eax
 7fa:	c1 e0 03             	shl    $0x3,%eax
 7fd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 800:	8b 45 f4             	mov    -0xc(%ebp),%eax
 803:	8b 55 ec             	mov    -0x14(%ebp),%edx
 806:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 809:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80c:	a3 e8 0a 00 00       	mov    %eax,0xae8
      return (void*)(p + 1);
 811:	8b 45 f4             	mov    -0xc(%ebp),%eax
 814:	83 c0 08             	add    $0x8,%eax
 817:	eb 3b                	jmp    854 <malloc+0xe5>
    }
    if(p == freep)
 819:	a1 e8 0a 00 00       	mov    0xae8,%eax
 81e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 821:	75 1e                	jne    841 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 823:	83 ec 0c             	sub    $0xc,%esp
 826:	ff 75 ec             	push   -0x14(%ebp)
 829:	e8 dd fe ff ff       	call   70b <morecore>
 82e:	83 c4 10             	add    $0x10,%esp
 831:	89 45 f4             	mov    %eax,-0xc(%ebp)
 834:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 838:	75 07                	jne    841 <malloc+0xd2>
        return 0;
 83a:	b8 00 00 00 00       	mov    $0x0,%eax
 83f:	eb 13                	jmp    854 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 841:	8b 45 f4             	mov    -0xc(%ebp),%eax
 844:	89 45 f0             	mov    %eax,-0x10(%ebp)
 847:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84a:	8b 00                	mov    (%eax),%eax
 84c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 84f:	e9 6d ff ff ff       	jmp    7c1 <malloc+0x52>
  }
}
 854:	c9                   	leave
 855:	c3                   	ret
