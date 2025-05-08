
_hello:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "user.h"

int main(int argc, char *argv[]) {
   0:	f3 0f 1e fb          	endbr32
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	push   -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	51                   	push   %ecx
  12:	83 ec 04             	sub    $0x4,%esp
 printf(1,"Hello world!\n");
  15:	83 ec 08             	sub    $0x8,%esp
  18:	68 1c 08 00 00       	push   $0x81c
  1d:	6a 01                	push   $0x1
  1f:	e8 31 04 00 00       	call   455 <printf>
  24:	83 c4 10             	add    $0x10,%esp
 printf(1, "My student # is 202001567\n");
  27:	83 ec 08             	sub    $0x8,%esp
  2a:	68 2a 08 00 00       	push   $0x82a
  2f:	6a 01                	push   $0x1
  31:	e8 1f 04 00 00       	call   455 <printf>
  36:	83 c4 10             	add    $0x10,%esp
 exit();
  39:	e8 7b 02 00 00       	call   2b9 <exit>

0000003e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  3e:	55                   	push   %ebp
  3f:	89 e5                	mov    %esp,%ebp
  41:	57                   	push   %edi
  42:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  46:	8b 55 10             	mov    0x10(%ebp),%edx
  49:	8b 45 0c             	mov    0xc(%ebp),%eax
  4c:	89 cb                	mov    %ecx,%ebx
  4e:	89 df                	mov    %ebx,%edi
  50:	89 d1                	mov    %edx,%ecx
  52:	fc                   	cld
  53:	f3 aa                	rep stos %al,%es:(%edi)
  55:	89 ca                	mov    %ecx,%edx
  57:	89 fb                	mov    %edi,%ebx
  59:	89 5d 08             	mov    %ebx,0x8(%ebp)
  5c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  5f:	90                   	nop
  60:	5b                   	pop    %ebx
  61:	5f                   	pop    %edi
  62:	5d                   	pop    %ebp
  63:	c3                   	ret

00000064 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  64:	f3 0f 1e fb          	endbr32
  68:	55                   	push   %ebp
  69:	89 e5                	mov    %esp,%ebp
  6b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  6e:	8b 45 08             	mov    0x8(%ebp),%eax
  71:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  74:	90                   	nop
  75:	8b 55 0c             	mov    0xc(%ebp),%edx
  78:	8d 42 01             	lea    0x1(%edx),%eax
  7b:	89 45 0c             	mov    %eax,0xc(%ebp)
  7e:	8b 45 08             	mov    0x8(%ebp),%eax
  81:	8d 48 01             	lea    0x1(%eax),%ecx
  84:	89 4d 08             	mov    %ecx,0x8(%ebp)
  87:	0f b6 12             	movzbl (%edx),%edx
  8a:	88 10                	mov    %dl,(%eax)
  8c:	0f b6 00             	movzbl (%eax),%eax
  8f:	84 c0                	test   %al,%al
  91:	75 e2                	jne    75 <strcpy+0x11>
    ;
  return os;
  93:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  96:	c9                   	leave
  97:	c3                   	ret

00000098 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  98:	f3 0f 1e fb          	endbr32
  9c:	55                   	push   %ebp
  9d:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  9f:	eb 08                	jmp    a9 <strcmp+0x11>
    p++, q++;
  a1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  a5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  a9:	8b 45 08             	mov    0x8(%ebp),%eax
  ac:	0f b6 00             	movzbl (%eax),%eax
  af:	84 c0                	test   %al,%al
  b1:	74 10                	je     c3 <strcmp+0x2b>
  b3:	8b 45 08             	mov    0x8(%ebp),%eax
  b6:	0f b6 10             	movzbl (%eax),%edx
  b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  bc:	0f b6 00             	movzbl (%eax),%eax
  bf:	38 c2                	cmp    %al,%dl
  c1:	74 de                	je     a1 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
  c3:	8b 45 08             	mov    0x8(%ebp),%eax
  c6:	0f b6 00             	movzbl (%eax),%eax
  c9:	0f b6 d0             	movzbl %al,%edx
  cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  cf:	0f b6 00             	movzbl (%eax),%eax
  d2:	0f b6 c0             	movzbl %al,%eax
  d5:	29 c2                	sub    %eax,%edx
  d7:	89 d0                	mov    %edx,%eax
}
  d9:	5d                   	pop    %ebp
  da:	c3                   	ret

000000db <strlen>:

uint
strlen(char *s)
{
  db:	f3 0f 1e fb          	endbr32
  df:	55                   	push   %ebp
  e0:	89 e5                	mov    %esp,%ebp
  e2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  e5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  ec:	eb 04                	jmp    f2 <strlen+0x17>
  ee:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
  f5:	8b 45 08             	mov    0x8(%ebp),%eax
  f8:	01 d0                	add    %edx,%eax
  fa:	0f b6 00             	movzbl (%eax),%eax
  fd:	84 c0                	test   %al,%al
  ff:	75 ed                	jne    ee <strlen+0x13>
    ;
  return n;
 101:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 104:	c9                   	leave
 105:	c3                   	ret

00000106 <memset>:

void*
memset(void *dst, int c, uint n)
{
 106:	f3 0f 1e fb          	endbr32
 10a:	55                   	push   %ebp
 10b:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 10d:	8b 45 10             	mov    0x10(%ebp),%eax
 110:	50                   	push   %eax
 111:	ff 75 0c             	push   0xc(%ebp)
 114:	ff 75 08             	push   0x8(%ebp)
 117:	e8 22 ff ff ff       	call   3e <stosb>
 11c:	83 c4 0c             	add    $0xc,%esp
  return dst;
 11f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 122:	c9                   	leave
 123:	c3                   	ret

00000124 <strchr>:

char*
strchr(const char *s, char c)
{
 124:	f3 0f 1e fb          	endbr32
 128:	55                   	push   %ebp
 129:	89 e5                	mov    %esp,%ebp
 12b:	83 ec 04             	sub    $0x4,%esp
 12e:	8b 45 0c             	mov    0xc(%ebp),%eax
 131:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 134:	eb 14                	jmp    14a <strchr+0x26>
    if(*s == c)
 136:	8b 45 08             	mov    0x8(%ebp),%eax
 139:	0f b6 00             	movzbl (%eax),%eax
 13c:	38 45 fc             	cmp    %al,-0x4(%ebp)
 13f:	75 05                	jne    146 <strchr+0x22>
      return (char*)s;
 141:	8b 45 08             	mov    0x8(%ebp),%eax
 144:	eb 13                	jmp    159 <strchr+0x35>
  for(; *s; s++)
 146:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 14a:	8b 45 08             	mov    0x8(%ebp),%eax
 14d:	0f b6 00             	movzbl (%eax),%eax
 150:	84 c0                	test   %al,%al
 152:	75 e2                	jne    136 <strchr+0x12>
  return 0;
 154:	b8 00 00 00 00       	mov    $0x0,%eax
}
 159:	c9                   	leave
 15a:	c3                   	ret

0000015b <gets>:

char*
gets(char *buf, int max)
{
 15b:	f3 0f 1e fb          	endbr32
 15f:	55                   	push   %ebp
 160:	89 e5                	mov    %esp,%ebp
 162:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 165:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 16c:	eb 42                	jmp    1b0 <gets+0x55>
    cc = read(0, &c, 1);
 16e:	83 ec 04             	sub    $0x4,%esp
 171:	6a 01                	push   $0x1
 173:	8d 45 ef             	lea    -0x11(%ebp),%eax
 176:	50                   	push   %eax
 177:	6a 00                	push   $0x0
 179:	e8 53 01 00 00       	call   2d1 <read>
 17e:	83 c4 10             	add    $0x10,%esp
 181:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 184:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 188:	7e 33                	jle    1bd <gets+0x62>
      break;
    buf[i++] = c;
 18a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18d:	8d 50 01             	lea    0x1(%eax),%edx
 190:	89 55 f4             	mov    %edx,-0xc(%ebp)
 193:	89 c2                	mov    %eax,%edx
 195:	8b 45 08             	mov    0x8(%ebp),%eax
 198:	01 c2                	add    %eax,%edx
 19a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 19e:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1a0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1a4:	3c 0a                	cmp    $0xa,%al
 1a6:	74 16                	je     1be <gets+0x63>
 1a8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ac:	3c 0d                	cmp    $0xd,%al
 1ae:	74 0e                	je     1be <gets+0x63>
  for(i=0; i+1 < max; ){
 1b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b3:	83 c0 01             	add    $0x1,%eax
 1b6:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1b9:	7f b3                	jg     16e <gets+0x13>
 1bb:	eb 01                	jmp    1be <gets+0x63>
      break;
 1bd:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1be:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1c1:	8b 45 08             	mov    0x8(%ebp),%eax
 1c4:	01 d0                	add    %edx,%eax
 1c6:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1c9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1cc:	c9                   	leave
 1cd:	c3                   	ret

000001ce <stat>:

int
stat(char *n, struct stat *st)
{
 1ce:	f3 0f 1e fb          	endbr32
 1d2:	55                   	push   %ebp
 1d3:	89 e5                	mov    %esp,%ebp
 1d5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1d8:	83 ec 08             	sub    $0x8,%esp
 1db:	6a 00                	push   $0x0
 1dd:	ff 75 08             	push   0x8(%ebp)
 1e0:	e8 14 01 00 00       	call   2f9 <open>
 1e5:	83 c4 10             	add    $0x10,%esp
 1e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1ef:	79 07                	jns    1f8 <stat+0x2a>
    return -1;
 1f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1f6:	eb 25                	jmp    21d <stat+0x4f>
  r = fstat(fd, st);
 1f8:	83 ec 08             	sub    $0x8,%esp
 1fb:	ff 75 0c             	push   0xc(%ebp)
 1fe:	ff 75 f4             	push   -0xc(%ebp)
 201:	e8 0b 01 00 00       	call   311 <fstat>
 206:	83 c4 10             	add    $0x10,%esp
 209:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 20c:	83 ec 0c             	sub    $0xc,%esp
 20f:	ff 75 f4             	push   -0xc(%ebp)
 212:	e8 ca 00 00 00       	call   2e1 <close>
 217:	83 c4 10             	add    $0x10,%esp
  return r;
 21a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 21d:	c9                   	leave
 21e:	c3                   	ret

0000021f <atoi>:

int
atoi(const char *s)
{
 21f:	f3 0f 1e fb          	endbr32
 223:	55                   	push   %ebp
 224:	89 e5                	mov    %esp,%ebp
 226:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 229:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 230:	eb 25                	jmp    257 <atoi+0x38>
    n = n*10 + *s++ - '0';
 232:	8b 55 fc             	mov    -0x4(%ebp),%edx
 235:	89 d0                	mov    %edx,%eax
 237:	c1 e0 02             	shl    $0x2,%eax
 23a:	01 d0                	add    %edx,%eax
 23c:	01 c0                	add    %eax,%eax
 23e:	89 c1                	mov    %eax,%ecx
 240:	8b 45 08             	mov    0x8(%ebp),%eax
 243:	8d 50 01             	lea    0x1(%eax),%edx
 246:	89 55 08             	mov    %edx,0x8(%ebp)
 249:	0f b6 00             	movzbl (%eax),%eax
 24c:	0f be c0             	movsbl %al,%eax
 24f:	01 c8                	add    %ecx,%eax
 251:	83 e8 30             	sub    $0x30,%eax
 254:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 257:	8b 45 08             	mov    0x8(%ebp),%eax
 25a:	0f b6 00             	movzbl (%eax),%eax
 25d:	3c 2f                	cmp    $0x2f,%al
 25f:	7e 0a                	jle    26b <atoi+0x4c>
 261:	8b 45 08             	mov    0x8(%ebp),%eax
 264:	0f b6 00             	movzbl (%eax),%eax
 267:	3c 39                	cmp    $0x39,%al
 269:	7e c7                	jle    232 <atoi+0x13>
  return n;
 26b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 26e:	c9                   	leave
 26f:	c3                   	ret

00000270 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 270:	f3 0f 1e fb          	endbr32
 274:	55                   	push   %ebp
 275:	89 e5                	mov    %esp,%ebp
 277:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 27a:	8b 45 08             	mov    0x8(%ebp),%eax
 27d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 280:	8b 45 0c             	mov    0xc(%ebp),%eax
 283:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 286:	eb 17                	jmp    29f <memmove+0x2f>
    *dst++ = *src++;
 288:	8b 55 f8             	mov    -0x8(%ebp),%edx
 28b:	8d 42 01             	lea    0x1(%edx),%eax
 28e:	89 45 f8             	mov    %eax,-0x8(%ebp)
 291:	8b 45 fc             	mov    -0x4(%ebp),%eax
 294:	8d 48 01             	lea    0x1(%eax),%ecx
 297:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 29a:	0f b6 12             	movzbl (%edx),%edx
 29d:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 29f:	8b 45 10             	mov    0x10(%ebp),%eax
 2a2:	8d 50 ff             	lea    -0x1(%eax),%edx
 2a5:	89 55 10             	mov    %edx,0x10(%ebp)
 2a8:	85 c0                	test   %eax,%eax
 2aa:	7f dc                	jg     288 <memmove+0x18>
  return vdst;
 2ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2af:	c9                   	leave
 2b0:	c3                   	ret

000002b1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2b1:	b8 01 00 00 00       	mov    $0x1,%eax
 2b6:	cd 40                	int    $0x40
 2b8:	c3                   	ret

000002b9 <exit>:
SYSCALL(exit)
 2b9:	b8 02 00 00 00       	mov    $0x2,%eax
 2be:	cd 40                	int    $0x40
 2c0:	c3                   	ret

000002c1 <wait>:
SYSCALL(wait)
 2c1:	b8 03 00 00 00       	mov    $0x3,%eax
 2c6:	cd 40                	int    $0x40
 2c8:	c3                   	ret

000002c9 <pipe>:
SYSCALL(pipe)
 2c9:	b8 04 00 00 00       	mov    $0x4,%eax
 2ce:	cd 40                	int    $0x40
 2d0:	c3                   	ret

000002d1 <read>:
SYSCALL(read)
 2d1:	b8 05 00 00 00       	mov    $0x5,%eax
 2d6:	cd 40                	int    $0x40
 2d8:	c3                   	ret

000002d9 <write>:
SYSCALL(write)
 2d9:	b8 10 00 00 00       	mov    $0x10,%eax
 2de:	cd 40                	int    $0x40
 2e0:	c3                   	ret

000002e1 <close>:
SYSCALL(close)
 2e1:	b8 15 00 00 00       	mov    $0x15,%eax
 2e6:	cd 40                	int    $0x40
 2e8:	c3                   	ret

000002e9 <kill>:
SYSCALL(kill)
 2e9:	b8 06 00 00 00       	mov    $0x6,%eax
 2ee:	cd 40                	int    $0x40
 2f0:	c3                   	ret

000002f1 <exec>:
SYSCALL(exec)
 2f1:	b8 07 00 00 00       	mov    $0x7,%eax
 2f6:	cd 40                	int    $0x40
 2f8:	c3                   	ret

000002f9 <open>:
SYSCALL(open)
 2f9:	b8 0f 00 00 00       	mov    $0xf,%eax
 2fe:	cd 40                	int    $0x40
 300:	c3                   	ret

00000301 <mknod>:
SYSCALL(mknod)
 301:	b8 11 00 00 00       	mov    $0x11,%eax
 306:	cd 40                	int    $0x40
 308:	c3                   	ret

00000309 <unlink>:
SYSCALL(unlink)
 309:	b8 12 00 00 00       	mov    $0x12,%eax
 30e:	cd 40                	int    $0x40
 310:	c3                   	ret

00000311 <fstat>:
SYSCALL(fstat)
 311:	b8 08 00 00 00       	mov    $0x8,%eax
 316:	cd 40                	int    $0x40
 318:	c3                   	ret

00000319 <link>:
SYSCALL(link)
 319:	b8 13 00 00 00       	mov    $0x13,%eax
 31e:	cd 40                	int    $0x40
 320:	c3                   	ret

00000321 <mkdir>:
SYSCALL(mkdir)
 321:	b8 14 00 00 00       	mov    $0x14,%eax
 326:	cd 40                	int    $0x40
 328:	c3                   	ret

00000329 <chdir>:
SYSCALL(chdir)
 329:	b8 09 00 00 00       	mov    $0x9,%eax
 32e:	cd 40                	int    $0x40
 330:	c3                   	ret

00000331 <dup>:
SYSCALL(dup)
 331:	b8 0a 00 00 00       	mov    $0xa,%eax
 336:	cd 40                	int    $0x40
 338:	c3                   	ret

00000339 <getpid>:
SYSCALL(getpid)
 339:	b8 0b 00 00 00       	mov    $0xb,%eax
 33e:	cd 40                	int    $0x40
 340:	c3                   	ret

00000341 <sbrk>:
SYSCALL(sbrk)
 341:	b8 0c 00 00 00       	mov    $0xc,%eax
 346:	cd 40                	int    $0x40
 348:	c3                   	ret

00000349 <sleep>:
SYSCALL(sleep)
 349:	b8 0d 00 00 00       	mov    $0xd,%eax
 34e:	cd 40                	int    $0x40
 350:	c3                   	ret

00000351 <uptime>:
SYSCALL(uptime)
 351:	b8 0e 00 00 00       	mov    $0xe,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret

00000359 <getpinfo>:

SYSCALL(getpinfo)
 359:	b8 16 00 00 00       	mov    $0x16,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret

00000361 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 361:	b8 17 00 00 00       	mov    $0x17,%eax
 366:	cd 40                	int    $0x40
 368:	c3                   	ret

00000369 <yield>:
SYSCALL(yield)
 369:	b8 18 00 00 00       	mov    $0x18,%eax
 36e:	cd 40                	int    $0x40
 370:	c3                   	ret

00000371 <getSchedPolicy>:
 371:	b8 19 00 00 00       	mov    $0x19,%eax
 376:	cd 40                	int    $0x40
 378:	c3                   	ret

00000379 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 379:	f3 0f 1e fb          	endbr32
 37d:	55                   	push   %ebp
 37e:	89 e5                	mov    %esp,%ebp
 380:	83 ec 18             	sub    $0x18,%esp
 383:	8b 45 0c             	mov    0xc(%ebp),%eax
 386:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 389:	83 ec 04             	sub    $0x4,%esp
 38c:	6a 01                	push   $0x1
 38e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 391:	50                   	push   %eax
 392:	ff 75 08             	push   0x8(%ebp)
 395:	e8 3f ff ff ff       	call   2d9 <write>
 39a:	83 c4 10             	add    $0x10,%esp
}
 39d:	90                   	nop
 39e:	c9                   	leave
 39f:	c3                   	ret

000003a0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3a0:	f3 0f 1e fb          	endbr32
 3a4:	55                   	push   %ebp
 3a5:	89 e5                	mov    %esp,%ebp
 3a7:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3b1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3b5:	74 17                	je     3ce <printint+0x2e>
 3b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3bb:	79 11                	jns    3ce <printint+0x2e>
    neg = 1;
 3bd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3c4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c7:	f7 d8                	neg    %eax
 3c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3cc:	eb 06                	jmp    3d4 <printint+0x34>
  } else {
    x = xx;
 3ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3db:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3de:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3e1:	ba 00 00 00 00       	mov    $0x0,%edx
 3e6:	f7 f1                	div    %ecx
 3e8:	89 d1                	mov    %edx,%ecx
 3ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ed:	8d 50 01             	lea    0x1(%eax),%edx
 3f0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3f3:	0f b6 91 90 0a 00 00 	movzbl 0xa90(%ecx),%edx
 3fa:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 3fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
 401:	8b 45 ec             	mov    -0x14(%ebp),%eax
 404:	ba 00 00 00 00       	mov    $0x0,%edx
 409:	f7 f1                	div    %ecx
 40b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 40e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 412:	75 c7                	jne    3db <printint+0x3b>
  if(neg)
 414:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 418:	74 2d                	je     447 <printint+0xa7>
    buf[i++] = '-';
 41a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 41d:	8d 50 01             	lea    0x1(%eax),%edx
 420:	89 55 f4             	mov    %edx,-0xc(%ebp)
 423:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 428:	eb 1d                	jmp    447 <printint+0xa7>
    putc(fd, buf[i]);
 42a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 42d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 430:	01 d0                	add    %edx,%eax
 432:	0f b6 00             	movzbl (%eax),%eax
 435:	0f be c0             	movsbl %al,%eax
 438:	83 ec 08             	sub    $0x8,%esp
 43b:	50                   	push   %eax
 43c:	ff 75 08             	push   0x8(%ebp)
 43f:	e8 35 ff ff ff       	call   379 <putc>
 444:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 447:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 44b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 44f:	79 d9                	jns    42a <printint+0x8a>
}
 451:	90                   	nop
 452:	90                   	nop
 453:	c9                   	leave
 454:	c3                   	ret

00000455 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 455:	f3 0f 1e fb          	endbr32
 459:	55                   	push   %ebp
 45a:	89 e5                	mov    %esp,%ebp
 45c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 45f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 466:	8d 45 0c             	lea    0xc(%ebp),%eax
 469:	83 c0 04             	add    $0x4,%eax
 46c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 46f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 476:	e9 59 01 00 00       	jmp    5d4 <printf+0x17f>
    c = fmt[i] & 0xff;
 47b:	8b 55 0c             	mov    0xc(%ebp),%edx
 47e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 481:	01 d0                	add    %edx,%eax
 483:	0f b6 00             	movzbl (%eax),%eax
 486:	0f be c0             	movsbl %al,%eax
 489:	25 ff 00 00 00       	and    $0xff,%eax
 48e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 491:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 495:	75 2c                	jne    4c3 <printf+0x6e>
      if(c == '%'){
 497:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 49b:	75 0c                	jne    4a9 <printf+0x54>
        state = '%';
 49d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4a4:	e9 27 01 00 00       	jmp    5d0 <printf+0x17b>
      } else {
        putc(fd, c);
 4a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4ac:	0f be c0             	movsbl %al,%eax
 4af:	83 ec 08             	sub    $0x8,%esp
 4b2:	50                   	push   %eax
 4b3:	ff 75 08             	push   0x8(%ebp)
 4b6:	e8 be fe ff ff       	call   379 <putc>
 4bb:	83 c4 10             	add    $0x10,%esp
 4be:	e9 0d 01 00 00       	jmp    5d0 <printf+0x17b>
      }
    } else if(state == '%'){
 4c3:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4c7:	0f 85 03 01 00 00    	jne    5d0 <printf+0x17b>
      if(c == 'd'){
 4cd:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4d1:	75 1e                	jne    4f1 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 4d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4d6:	8b 00                	mov    (%eax),%eax
 4d8:	6a 01                	push   $0x1
 4da:	6a 0a                	push   $0xa
 4dc:	50                   	push   %eax
 4dd:	ff 75 08             	push   0x8(%ebp)
 4e0:	e8 bb fe ff ff       	call   3a0 <printint>
 4e5:	83 c4 10             	add    $0x10,%esp
        ap++;
 4e8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4ec:	e9 d8 00 00 00       	jmp    5c9 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 4f1:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4f5:	74 06                	je     4fd <printf+0xa8>
 4f7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4fb:	75 1e                	jne    51b <printf+0xc6>
        printint(fd, *ap, 16, 0);
 4fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 500:	8b 00                	mov    (%eax),%eax
 502:	6a 00                	push   $0x0
 504:	6a 10                	push   $0x10
 506:	50                   	push   %eax
 507:	ff 75 08             	push   0x8(%ebp)
 50a:	e8 91 fe ff ff       	call   3a0 <printint>
 50f:	83 c4 10             	add    $0x10,%esp
        ap++;
 512:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 516:	e9 ae 00 00 00       	jmp    5c9 <printf+0x174>
      } else if(c == 's'){
 51b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 51f:	75 43                	jne    564 <printf+0x10f>
        s = (char*)*ap;
 521:	8b 45 e8             	mov    -0x18(%ebp),%eax
 524:	8b 00                	mov    (%eax),%eax
 526:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 529:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 52d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 531:	75 25                	jne    558 <printf+0x103>
          s = "(null)";
 533:	c7 45 f4 45 08 00 00 	movl   $0x845,-0xc(%ebp)
        while(*s != 0){
 53a:	eb 1c                	jmp    558 <printf+0x103>
          putc(fd, *s);
 53c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 53f:	0f b6 00             	movzbl (%eax),%eax
 542:	0f be c0             	movsbl %al,%eax
 545:	83 ec 08             	sub    $0x8,%esp
 548:	50                   	push   %eax
 549:	ff 75 08             	push   0x8(%ebp)
 54c:	e8 28 fe ff ff       	call   379 <putc>
 551:	83 c4 10             	add    $0x10,%esp
          s++;
 554:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 558:	8b 45 f4             	mov    -0xc(%ebp),%eax
 55b:	0f b6 00             	movzbl (%eax),%eax
 55e:	84 c0                	test   %al,%al
 560:	75 da                	jne    53c <printf+0xe7>
 562:	eb 65                	jmp    5c9 <printf+0x174>
        }
      } else if(c == 'c'){
 564:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 568:	75 1d                	jne    587 <printf+0x132>
        putc(fd, *ap);
 56a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 56d:	8b 00                	mov    (%eax),%eax
 56f:	0f be c0             	movsbl %al,%eax
 572:	83 ec 08             	sub    $0x8,%esp
 575:	50                   	push   %eax
 576:	ff 75 08             	push   0x8(%ebp)
 579:	e8 fb fd ff ff       	call   379 <putc>
 57e:	83 c4 10             	add    $0x10,%esp
        ap++;
 581:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 585:	eb 42                	jmp    5c9 <printf+0x174>
      } else if(c == '%'){
 587:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 58b:	75 17                	jne    5a4 <printf+0x14f>
        putc(fd, c);
 58d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 590:	0f be c0             	movsbl %al,%eax
 593:	83 ec 08             	sub    $0x8,%esp
 596:	50                   	push   %eax
 597:	ff 75 08             	push   0x8(%ebp)
 59a:	e8 da fd ff ff       	call   379 <putc>
 59f:	83 c4 10             	add    $0x10,%esp
 5a2:	eb 25                	jmp    5c9 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5a4:	83 ec 08             	sub    $0x8,%esp
 5a7:	6a 25                	push   $0x25
 5a9:	ff 75 08             	push   0x8(%ebp)
 5ac:	e8 c8 fd ff ff       	call   379 <putc>
 5b1:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5b7:	0f be c0             	movsbl %al,%eax
 5ba:	83 ec 08             	sub    $0x8,%esp
 5bd:	50                   	push   %eax
 5be:	ff 75 08             	push   0x8(%ebp)
 5c1:	e8 b3 fd ff ff       	call   379 <putc>
 5c6:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5c9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5d0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5d4:	8b 55 0c             	mov    0xc(%ebp),%edx
 5d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5da:	01 d0                	add    %edx,%eax
 5dc:	0f b6 00             	movzbl (%eax),%eax
 5df:	84 c0                	test   %al,%al
 5e1:	0f 85 94 fe ff ff    	jne    47b <printf+0x26>
    }
  }
}
 5e7:	90                   	nop
 5e8:	90                   	nop
 5e9:	c9                   	leave
 5ea:	c3                   	ret

000005eb <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5eb:	f3 0f 1e fb          	endbr32
 5ef:	55                   	push   %ebp
 5f0:	89 e5                	mov    %esp,%ebp
 5f2:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5f5:	8b 45 08             	mov    0x8(%ebp),%eax
 5f8:	83 e8 08             	sub    $0x8,%eax
 5fb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5fe:	a1 ac 0a 00 00       	mov    0xaac,%eax
 603:	89 45 fc             	mov    %eax,-0x4(%ebp)
 606:	eb 24                	jmp    62c <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 608:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60b:	8b 00                	mov    (%eax),%eax
 60d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 610:	72 12                	jb     624 <free+0x39>
 612:	8b 45 f8             	mov    -0x8(%ebp),%eax
 615:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 618:	77 24                	ja     63e <free+0x53>
 61a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61d:	8b 00                	mov    (%eax),%eax
 61f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 622:	72 1a                	jb     63e <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 624:	8b 45 fc             	mov    -0x4(%ebp),%eax
 627:	8b 00                	mov    (%eax),%eax
 629:	89 45 fc             	mov    %eax,-0x4(%ebp)
 62c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 632:	76 d4                	jbe    608 <free+0x1d>
 634:	8b 45 fc             	mov    -0x4(%ebp),%eax
 637:	8b 00                	mov    (%eax),%eax
 639:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 63c:	73 ca                	jae    608 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 63e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 641:	8b 40 04             	mov    0x4(%eax),%eax
 644:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 64b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64e:	01 c2                	add    %eax,%edx
 650:	8b 45 fc             	mov    -0x4(%ebp),%eax
 653:	8b 00                	mov    (%eax),%eax
 655:	39 c2                	cmp    %eax,%edx
 657:	75 24                	jne    67d <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 659:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65c:	8b 50 04             	mov    0x4(%eax),%edx
 65f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 662:	8b 00                	mov    (%eax),%eax
 664:	8b 40 04             	mov    0x4(%eax),%eax
 667:	01 c2                	add    %eax,%edx
 669:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 66f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 672:	8b 00                	mov    (%eax),%eax
 674:	8b 10                	mov    (%eax),%edx
 676:	8b 45 f8             	mov    -0x8(%ebp),%eax
 679:	89 10                	mov    %edx,(%eax)
 67b:	eb 0a                	jmp    687 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 67d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 680:	8b 10                	mov    (%eax),%edx
 682:	8b 45 f8             	mov    -0x8(%ebp),%eax
 685:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 687:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68a:	8b 40 04             	mov    0x4(%eax),%eax
 68d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 694:	8b 45 fc             	mov    -0x4(%ebp),%eax
 697:	01 d0                	add    %edx,%eax
 699:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 69c:	75 20                	jne    6be <free+0xd3>
    p->s.size += bp->s.size;
 69e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a1:	8b 50 04             	mov    0x4(%eax),%edx
 6a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a7:	8b 40 04             	mov    0x4(%eax),%eax
 6aa:	01 c2                	add    %eax,%edx
 6ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6af:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b5:	8b 10                	mov    (%eax),%edx
 6b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ba:	89 10                	mov    %edx,(%eax)
 6bc:	eb 08                	jmp    6c6 <free+0xdb>
  } else
    p->s.ptr = bp;
 6be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c1:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6c4:	89 10                	mov    %edx,(%eax)
  freep = p;
 6c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c9:	a3 ac 0a 00 00       	mov    %eax,0xaac
}
 6ce:	90                   	nop
 6cf:	c9                   	leave
 6d0:	c3                   	ret

000006d1 <morecore>:

static Header*
morecore(uint nu)
{
 6d1:	f3 0f 1e fb          	endbr32
 6d5:	55                   	push   %ebp
 6d6:	89 e5                	mov    %esp,%ebp
 6d8:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6db:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6e2:	77 07                	ja     6eb <morecore+0x1a>
    nu = 4096;
 6e4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6eb:	8b 45 08             	mov    0x8(%ebp),%eax
 6ee:	c1 e0 03             	shl    $0x3,%eax
 6f1:	83 ec 0c             	sub    $0xc,%esp
 6f4:	50                   	push   %eax
 6f5:	e8 47 fc ff ff       	call   341 <sbrk>
 6fa:	83 c4 10             	add    $0x10,%esp
 6fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 700:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 704:	75 07                	jne    70d <morecore+0x3c>
    return 0;
 706:	b8 00 00 00 00       	mov    $0x0,%eax
 70b:	eb 26                	jmp    733 <morecore+0x62>
  hp = (Header*)p;
 70d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 710:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 713:	8b 45 f0             	mov    -0x10(%ebp),%eax
 716:	8b 55 08             	mov    0x8(%ebp),%edx
 719:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 71c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 71f:	83 c0 08             	add    $0x8,%eax
 722:	83 ec 0c             	sub    $0xc,%esp
 725:	50                   	push   %eax
 726:	e8 c0 fe ff ff       	call   5eb <free>
 72b:	83 c4 10             	add    $0x10,%esp
  return freep;
 72e:	a1 ac 0a 00 00       	mov    0xaac,%eax
}
 733:	c9                   	leave
 734:	c3                   	ret

00000735 <malloc>:

void*
malloc(uint nbytes)
{
 735:	f3 0f 1e fb          	endbr32
 739:	55                   	push   %ebp
 73a:	89 e5                	mov    %esp,%ebp
 73c:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 73f:	8b 45 08             	mov    0x8(%ebp),%eax
 742:	83 c0 07             	add    $0x7,%eax
 745:	c1 e8 03             	shr    $0x3,%eax
 748:	83 c0 01             	add    $0x1,%eax
 74b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 74e:	a1 ac 0a 00 00       	mov    0xaac,%eax
 753:	89 45 f0             	mov    %eax,-0x10(%ebp)
 756:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 75a:	75 23                	jne    77f <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 75c:	c7 45 f0 a4 0a 00 00 	movl   $0xaa4,-0x10(%ebp)
 763:	8b 45 f0             	mov    -0x10(%ebp),%eax
 766:	a3 ac 0a 00 00       	mov    %eax,0xaac
 76b:	a1 ac 0a 00 00       	mov    0xaac,%eax
 770:	a3 a4 0a 00 00       	mov    %eax,0xaa4
    base.s.size = 0;
 775:	c7 05 a8 0a 00 00 00 	movl   $0x0,0xaa8
 77c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 77f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 782:	8b 00                	mov    (%eax),%eax
 784:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 787:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78a:	8b 40 04             	mov    0x4(%eax),%eax
 78d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 790:	77 4d                	ja     7df <malloc+0xaa>
      if(p->s.size == nunits)
 792:	8b 45 f4             	mov    -0xc(%ebp),%eax
 795:	8b 40 04             	mov    0x4(%eax),%eax
 798:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 79b:	75 0c                	jne    7a9 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 79d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a0:	8b 10                	mov    (%eax),%edx
 7a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a5:	89 10                	mov    %edx,(%eax)
 7a7:	eb 26                	jmp    7cf <malloc+0x9a>
      else {
        p->s.size -= nunits;
 7a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ac:	8b 40 04             	mov    0x4(%eax),%eax
 7af:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7b2:	89 c2                	mov    %eax,%edx
 7b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bd:	8b 40 04             	mov    0x4(%eax),%eax
 7c0:	c1 e0 03             	shl    $0x3,%eax
 7c3:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7cc:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d2:	a3 ac 0a 00 00       	mov    %eax,0xaac
      return (void*)(p + 1);
 7d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7da:	83 c0 08             	add    $0x8,%eax
 7dd:	eb 3b                	jmp    81a <malloc+0xe5>
    }
    if(p == freep)
 7df:	a1 ac 0a 00 00       	mov    0xaac,%eax
 7e4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7e7:	75 1e                	jne    807 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 7e9:	83 ec 0c             	sub    $0xc,%esp
 7ec:	ff 75 ec             	push   -0x14(%ebp)
 7ef:	e8 dd fe ff ff       	call   6d1 <morecore>
 7f4:	83 c4 10             	add    $0x10,%esp
 7f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7fe:	75 07                	jne    807 <malloc+0xd2>
        return 0;
 800:	b8 00 00 00 00       	mov    $0x0,%eax
 805:	eb 13                	jmp    81a <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 807:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 80d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 810:	8b 00                	mov    (%eax),%eax
 812:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 815:	e9 6d ff ff ff       	jmp    787 <malloc+0x52>
  }
}
 81a:	c9                   	leave
 81b:	c3                   	ret
