
_recurse:     file format elf32-i386


Disassembly of section .text:

00000000 <recurse>:
// Prevent this function from being optimized, which might give it closed form
#pragma GCC push_options
#pragma GCC optimize ("O0")

static int recurse(int n)
{
   0:	f3 0f 1e fb          	endbr32
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 ec 08             	sub    $0x8,%esp
  if(n == 0)
   a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
   e:	75 07                	jne    17 <recurse+0x17>
    return 0;
  10:	b8 00 00 00 00       	mov    $0x0,%eax
  15:	eb 17                	jmp    2e <recurse+0x2e>
  return n + recurse(n - 1);
  17:	8b 45 08             	mov    0x8(%ebp),%eax
  1a:	83 e8 01             	sub    $0x1,%eax
  1d:	83 ec 0c             	sub    $0xc,%esp
  20:	50                   	push   %eax
  21:	e8 da ff ff ff       	call   0 <recurse>
  26:	83 c4 10             	add    $0x10,%esp
  29:	8b 55 08             	mov    0x8(%ebp),%edx
  2c:	01 d0                	add    %edx,%eax
}
  2e:	c9                   	leave
  2f:	c3                   	ret

00000030 <main>:
#pragma GCC pop_options

int main(int argc, char *argv[])
{
  30:	f3 0f 1e fb          	endbr32
  34:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  38:	83 e4 f0             	and    $0xfffffff0,%esp
  3b:	ff 71 fc             	push   -0x4(%ecx)
  3e:	55                   	push   %ebp
  3f:	89 e5                	mov    %esp,%ebp
  41:	53                   	push   %ebx
  42:	51                   	push   %ecx
  43:	83 ec 10             	sub    $0x10,%esp
  46:	89 cb                	mov    %ecx,%ebx
  int n, m;

  if(argc != 2){
  48:	83 3b 02             	cmpl   $0x2,(%ebx)
  4b:	74 1d                	je     6a <main+0x3a>
    printf(1, "Usage: %s levels\n", argv[0]);
  4d:	8b 43 04             	mov    0x4(%ebx),%eax
  50:	8b 00                	mov    (%eax),%eax
  52:	83 ec 04             	sub    $0x4,%esp
  55:	50                   	push   %eax
  56:	68 b1 08 00 00       	push   $0x8b1
  5b:	6a 01                	push   $0x1
  5d:	e8 88 04 00 00       	call   4ea <printf>
  62:	83 c4 10             	add    $0x10,%esp
    exit();
  65:	e8 f4 02 00 00       	call   35e <exit>
  }
  printpt(getpid()); // Uncomment for the test.
  6a:	e8 6f 03 00 00       	call   3de <getpid>
  6f:	83 ec 0c             	sub    $0xc,%esp
  72:	50                   	push   %eax
  73:	e8 8e 03 00 00       	call   406 <printpt>
  78:	83 c4 10             	add    $0x10,%esp
  n = atoi(argv[1]);
  7b:	8b 43 04             	mov    0x4(%ebx),%eax
  7e:	83 c0 04             	add    $0x4,%eax
  81:	8b 00                	mov    (%eax),%eax
  83:	83 ec 0c             	sub    $0xc,%esp
  86:	50                   	push   %eax
  87:	e8 38 02 00 00       	call   2c4 <atoi>
  8c:	83 c4 10             	add    $0x10,%esp
  8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  printf(1, "Recursing %d levels\n", n);
  92:	83 ec 04             	sub    $0x4,%esp
  95:	ff 75 f4             	push   -0xc(%ebp)
  98:	68 c3 08 00 00       	push   $0x8c3
  9d:	6a 01                	push   $0x1
  9f:	e8 46 04 00 00       	call   4ea <printf>
  a4:	83 c4 10             	add    $0x10,%esp
  m = recurse(n);
  a7:	83 ec 0c             	sub    $0xc,%esp
  aa:	ff 75 f4             	push   -0xc(%ebp)
  ad:	e8 4e ff ff ff       	call   0 <recurse>
  b2:	83 c4 10             	add    $0x10,%esp
  b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  printf(1, "Yielded a value of %d\n", m);
  b8:	83 ec 04             	sub    $0x4,%esp
  bb:	ff 75 f0             	push   -0x10(%ebp)
  be:	68 d8 08 00 00       	push   $0x8d8
  c3:	6a 01                	push   $0x1
  c5:	e8 20 04 00 00       	call   4ea <printf>
  ca:	83 c4 10             	add    $0x10,%esp
 printpt(getpid()); // Uncomment for the test.
  cd:	e8 0c 03 00 00       	call   3de <getpid>
  d2:	83 ec 0c             	sub    $0xc,%esp
  d5:	50                   	push   %eax
  d6:	e8 2b 03 00 00       	call   406 <printpt>
  db:	83 c4 10             	add    $0x10,%esp
  exit();
  de:	e8 7b 02 00 00       	call   35e <exit>

000000e3 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  e3:	55                   	push   %ebp
  e4:	89 e5                	mov    %esp,%ebp
  e6:	57                   	push   %edi
  e7:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  eb:	8b 55 10             	mov    0x10(%ebp),%edx
  ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  f1:	89 cb                	mov    %ecx,%ebx
  f3:	89 df                	mov    %ebx,%edi
  f5:	89 d1                	mov    %edx,%ecx
  f7:	fc                   	cld
  f8:	f3 aa                	rep stos %al,%es:(%edi)
  fa:	89 ca                	mov    %ecx,%edx
  fc:	89 fb                	mov    %edi,%ebx
  fe:	89 5d 08             	mov    %ebx,0x8(%ebp)
 101:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 104:	90                   	nop
 105:	5b                   	pop    %ebx
 106:	5f                   	pop    %edi
 107:	5d                   	pop    %ebp
 108:	c3                   	ret

00000109 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 109:	f3 0f 1e fb          	endbr32
 10d:	55                   	push   %ebp
 10e:	89 e5                	mov    %esp,%ebp
 110:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 113:	8b 45 08             	mov    0x8(%ebp),%eax
 116:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 119:	90                   	nop
 11a:	8b 55 0c             	mov    0xc(%ebp),%edx
 11d:	8d 42 01             	lea    0x1(%edx),%eax
 120:	89 45 0c             	mov    %eax,0xc(%ebp)
 123:	8b 45 08             	mov    0x8(%ebp),%eax
 126:	8d 48 01             	lea    0x1(%eax),%ecx
 129:	89 4d 08             	mov    %ecx,0x8(%ebp)
 12c:	0f b6 12             	movzbl (%edx),%edx
 12f:	88 10                	mov    %dl,(%eax)
 131:	0f b6 00             	movzbl (%eax),%eax
 134:	84 c0                	test   %al,%al
 136:	75 e2                	jne    11a <strcpy+0x11>
    ;
  return os;
 138:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 13b:	c9                   	leave
 13c:	c3                   	ret

0000013d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 13d:	f3 0f 1e fb          	endbr32
 141:	55                   	push   %ebp
 142:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 144:	eb 08                	jmp    14e <strcmp+0x11>
    p++, q++;
 146:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 14a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 14e:	8b 45 08             	mov    0x8(%ebp),%eax
 151:	0f b6 00             	movzbl (%eax),%eax
 154:	84 c0                	test   %al,%al
 156:	74 10                	je     168 <strcmp+0x2b>
 158:	8b 45 08             	mov    0x8(%ebp),%eax
 15b:	0f b6 10             	movzbl (%eax),%edx
 15e:	8b 45 0c             	mov    0xc(%ebp),%eax
 161:	0f b6 00             	movzbl (%eax),%eax
 164:	38 c2                	cmp    %al,%dl
 166:	74 de                	je     146 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 168:	8b 45 08             	mov    0x8(%ebp),%eax
 16b:	0f b6 00             	movzbl (%eax),%eax
 16e:	0f b6 d0             	movzbl %al,%edx
 171:	8b 45 0c             	mov    0xc(%ebp),%eax
 174:	0f b6 00             	movzbl (%eax),%eax
 177:	0f b6 c0             	movzbl %al,%eax
 17a:	29 c2                	sub    %eax,%edx
 17c:	89 d0                	mov    %edx,%eax
}
 17e:	5d                   	pop    %ebp
 17f:	c3                   	ret

00000180 <strlen>:

uint
strlen(char *s)
{
 180:	f3 0f 1e fb          	endbr32
 184:	55                   	push   %ebp
 185:	89 e5                	mov    %esp,%ebp
 187:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 18a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 191:	eb 04                	jmp    197 <strlen+0x17>
 193:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 197:	8b 55 fc             	mov    -0x4(%ebp),%edx
 19a:	8b 45 08             	mov    0x8(%ebp),%eax
 19d:	01 d0                	add    %edx,%eax
 19f:	0f b6 00             	movzbl (%eax),%eax
 1a2:	84 c0                	test   %al,%al
 1a4:	75 ed                	jne    193 <strlen+0x13>
    ;
  return n;
 1a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1a9:	c9                   	leave
 1aa:	c3                   	ret

000001ab <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ab:	f3 0f 1e fb          	endbr32
 1af:	55                   	push   %ebp
 1b0:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1b2:	8b 45 10             	mov    0x10(%ebp),%eax
 1b5:	50                   	push   %eax
 1b6:	ff 75 0c             	push   0xc(%ebp)
 1b9:	ff 75 08             	push   0x8(%ebp)
 1bc:	e8 22 ff ff ff       	call   e3 <stosb>
 1c1:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1c4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1c7:	c9                   	leave
 1c8:	c3                   	ret

000001c9 <strchr>:

char*
strchr(const char *s, char c)
{
 1c9:	f3 0f 1e fb          	endbr32
 1cd:	55                   	push   %ebp
 1ce:	89 e5                	mov    %esp,%ebp
 1d0:	83 ec 04             	sub    $0x4,%esp
 1d3:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d6:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1d9:	eb 14                	jmp    1ef <strchr+0x26>
    if(*s == c)
 1db:	8b 45 08             	mov    0x8(%ebp),%eax
 1de:	0f b6 00             	movzbl (%eax),%eax
 1e1:	38 45 fc             	cmp    %al,-0x4(%ebp)
 1e4:	75 05                	jne    1eb <strchr+0x22>
      return (char*)s;
 1e6:	8b 45 08             	mov    0x8(%ebp),%eax
 1e9:	eb 13                	jmp    1fe <strchr+0x35>
  for(; *s; s++)
 1eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	0f b6 00             	movzbl (%eax),%eax
 1f5:	84 c0                	test   %al,%al
 1f7:	75 e2                	jne    1db <strchr+0x12>
  return 0;
 1f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1fe:	c9                   	leave
 1ff:	c3                   	ret

00000200 <gets>:

char*
gets(char *buf, int max)
{
 200:	f3 0f 1e fb          	endbr32
 204:	55                   	push   %ebp
 205:	89 e5                	mov    %esp,%ebp
 207:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 211:	eb 42                	jmp    255 <gets+0x55>
    cc = read(0, &c, 1);
 213:	83 ec 04             	sub    $0x4,%esp
 216:	6a 01                	push   $0x1
 218:	8d 45 ef             	lea    -0x11(%ebp),%eax
 21b:	50                   	push   %eax
 21c:	6a 00                	push   $0x0
 21e:	e8 53 01 00 00       	call   376 <read>
 223:	83 c4 10             	add    $0x10,%esp
 226:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 229:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 22d:	7e 33                	jle    262 <gets+0x62>
      break;
    buf[i++] = c;
 22f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 232:	8d 50 01             	lea    0x1(%eax),%edx
 235:	89 55 f4             	mov    %edx,-0xc(%ebp)
 238:	89 c2                	mov    %eax,%edx
 23a:	8b 45 08             	mov    0x8(%ebp),%eax
 23d:	01 c2                	add    %eax,%edx
 23f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 243:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 245:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 249:	3c 0a                	cmp    $0xa,%al
 24b:	74 16                	je     263 <gets+0x63>
 24d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 251:	3c 0d                	cmp    $0xd,%al
 253:	74 0e                	je     263 <gets+0x63>
  for(i=0; i+1 < max; ){
 255:	8b 45 f4             	mov    -0xc(%ebp),%eax
 258:	83 c0 01             	add    $0x1,%eax
 25b:	39 45 0c             	cmp    %eax,0xc(%ebp)
 25e:	7f b3                	jg     213 <gets+0x13>
 260:	eb 01                	jmp    263 <gets+0x63>
      break;
 262:	90                   	nop
      break;
  }
  buf[i] = '\0';
 263:	8b 55 f4             	mov    -0xc(%ebp),%edx
 266:	8b 45 08             	mov    0x8(%ebp),%eax
 269:	01 d0                	add    %edx,%eax
 26b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 26e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 271:	c9                   	leave
 272:	c3                   	ret

00000273 <stat>:

int
stat(char *n, struct stat *st)
{
 273:	f3 0f 1e fb          	endbr32
 277:	55                   	push   %ebp
 278:	89 e5                	mov    %esp,%ebp
 27a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27d:	83 ec 08             	sub    $0x8,%esp
 280:	6a 00                	push   $0x0
 282:	ff 75 08             	push   0x8(%ebp)
 285:	e8 14 01 00 00       	call   39e <open>
 28a:	83 c4 10             	add    $0x10,%esp
 28d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 290:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 294:	79 07                	jns    29d <stat+0x2a>
    return -1;
 296:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 29b:	eb 25                	jmp    2c2 <stat+0x4f>
  r = fstat(fd, st);
 29d:	83 ec 08             	sub    $0x8,%esp
 2a0:	ff 75 0c             	push   0xc(%ebp)
 2a3:	ff 75 f4             	push   -0xc(%ebp)
 2a6:	e8 0b 01 00 00       	call   3b6 <fstat>
 2ab:	83 c4 10             	add    $0x10,%esp
 2ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2b1:	83 ec 0c             	sub    $0xc,%esp
 2b4:	ff 75 f4             	push   -0xc(%ebp)
 2b7:	e8 ca 00 00 00       	call   386 <close>
 2bc:	83 c4 10             	add    $0x10,%esp
  return r;
 2bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2c2:	c9                   	leave
 2c3:	c3                   	ret

000002c4 <atoi>:

int
atoi(const char *s)
{
 2c4:	f3 0f 1e fb          	endbr32
 2c8:	55                   	push   %ebp
 2c9:	89 e5                	mov    %esp,%ebp
 2cb:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2ce:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2d5:	eb 25                	jmp    2fc <atoi+0x38>
    n = n*10 + *s++ - '0';
 2d7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2da:	89 d0                	mov    %edx,%eax
 2dc:	c1 e0 02             	shl    $0x2,%eax
 2df:	01 d0                	add    %edx,%eax
 2e1:	01 c0                	add    %eax,%eax
 2e3:	89 c1                	mov    %eax,%ecx
 2e5:	8b 45 08             	mov    0x8(%ebp),%eax
 2e8:	8d 50 01             	lea    0x1(%eax),%edx
 2eb:	89 55 08             	mov    %edx,0x8(%ebp)
 2ee:	0f b6 00             	movzbl (%eax),%eax
 2f1:	0f be c0             	movsbl %al,%eax
 2f4:	01 c8                	add    %ecx,%eax
 2f6:	83 e8 30             	sub    $0x30,%eax
 2f9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2fc:	8b 45 08             	mov    0x8(%ebp),%eax
 2ff:	0f b6 00             	movzbl (%eax),%eax
 302:	3c 2f                	cmp    $0x2f,%al
 304:	7e 0a                	jle    310 <atoi+0x4c>
 306:	8b 45 08             	mov    0x8(%ebp),%eax
 309:	0f b6 00             	movzbl (%eax),%eax
 30c:	3c 39                	cmp    $0x39,%al
 30e:	7e c7                	jle    2d7 <atoi+0x13>
  return n;
 310:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 313:	c9                   	leave
 314:	c3                   	ret

00000315 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 315:	f3 0f 1e fb          	endbr32
 319:	55                   	push   %ebp
 31a:	89 e5                	mov    %esp,%ebp
 31c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
 322:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 325:	8b 45 0c             	mov    0xc(%ebp),%eax
 328:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 32b:	eb 17                	jmp    344 <memmove+0x2f>
    *dst++ = *src++;
 32d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 330:	8d 42 01             	lea    0x1(%edx),%eax
 333:	89 45 f8             	mov    %eax,-0x8(%ebp)
 336:	8b 45 fc             	mov    -0x4(%ebp),%eax
 339:	8d 48 01             	lea    0x1(%eax),%ecx
 33c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 33f:	0f b6 12             	movzbl (%edx),%edx
 342:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 344:	8b 45 10             	mov    0x10(%ebp),%eax
 347:	8d 50 ff             	lea    -0x1(%eax),%edx
 34a:	89 55 10             	mov    %edx,0x10(%ebp)
 34d:	85 c0                	test   %eax,%eax
 34f:	7f dc                	jg     32d <memmove+0x18>
  return vdst;
 351:	8b 45 08             	mov    0x8(%ebp),%eax
}
 354:	c9                   	leave
 355:	c3                   	ret

00000356 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 356:	b8 01 00 00 00       	mov    $0x1,%eax
 35b:	cd 40                	int    $0x40
 35d:	c3                   	ret

0000035e <exit>:
SYSCALL(exit)
 35e:	b8 02 00 00 00       	mov    $0x2,%eax
 363:	cd 40                	int    $0x40
 365:	c3                   	ret

00000366 <wait>:
SYSCALL(wait)
 366:	b8 03 00 00 00       	mov    $0x3,%eax
 36b:	cd 40                	int    $0x40
 36d:	c3                   	ret

0000036e <pipe>:
SYSCALL(pipe)
 36e:	b8 04 00 00 00       	mov    $0x4,%eax
 373:	cd 40                	int    $0x40
 375:	c3                   	ret

00000376 <read>:
SYSCALL(read)
 376:	b8 05 00 00 00       	mov    $0x5,%eax
 37b:	cd 40                	int    $0x40
 37d:	c3                   	ret

0000037e <write>:
SYSCALL(write)
 37e:	b8 10 00 00 00       	mov    $0x10,%eax
 383:	cd 40                	int    $0x40
 385:	c3                   	ret

00000386 <close>:
SYSCALL(close)
 386:	b8 15 00 00 00       	mov    $0x15,%eax
 38b:	cd 40                	int    $0x40
 38d:	c3                   	ret

0000038e <kill>:
SYSCALL(kill)
 38e:	b8 06 00 00 00       	mov    $0x6,%eax
 393:	cd 40                	int    $0x40
 395:	c3                   	ret

00000396 <exec>:
SYSCALL(exec)
 396:	b8 07 00 00 00       	mov    $0x7,%eax
 39b:	cd 40                	int    $0x40
 39d:	c3                   	ret

0000039e <open>:
SYSCALL(open)
 39e:	b8 0f 00 00 00       	mov    $0xf,%eax
 3a3:	cd 40                	int    $0x40
 3a5:	c3                   	ret

000003a6 <mknod>:
SYSCALL(mknod)
 3a6:	b8 11 00 00 00       	mov    $0x11,%eax
 3ab:	cd 40                	int    $0x40
 3ad:	c3                   	ret

000003ae <unlink>:
SYSCALL(unlink)
 3ae:	b8 12 00 00 00       	mov    $0x12,%eax
 3b3:	cd 40                	int    $0x40
 3b5:	c3                   	ret

000003b6 <fstat>:
SYSCALL(fstat)
 3b6:	b8 08 00 00 00       	mov    $0x8,%eax
 3bb:	cd 40                	int    $0x40
 3bd:	c3                   	ret

000003be <link>:
SYSCALL(link)
 3be:	b8 13 00 00 00       	mov    $0x13,%eax
 3c3:	cd 40                	int    $0x40
 3c5:	c3                   	ret

000003c6 <mkdir>:
SYSCALL(mkdir)
 3c6:	b8 14 00 00 00       	mov    $0x14,%eax
 3cb:	cd 40                	int    $0x40
 3cd:	c3                   	ret

000003ce <chdir>:
SYSCALL(chdir)
 3ce:	b8 09 00 00 00       	mov    $0x9,%eax
 3d3:	cd 40                	int    $0x40
 3d5:	c3                   	ret

000003d6 <dup>:
SYSCALL(dup)
 3d6:	b8 0a 00 00 00       	mov    $0xa,%eax
 3db:	cd 40                	int    $0x40
 3dd:	c3                   	ret

000003de <getpid>:
SYSCALL(getpid)
 3de:	b8 0b 00 00 00       	mov    $0xb,%eax
 3e3:	cd 40                	int    $0x40
 3e5:	c3                   	ret

000003e6 <sbrk>:
SYSCALL(sbrk)
 3e6:	b8 0c 00 00 00       	mov    $0xc,%eax
 3eb:	cd 40                	int    $0x40
 3ed:	c3                   	ret

000003ee <sleep>:
SYSCALL(sleep)
 3ee:	b8 0d 00 00 00       	mov    $0xd,%eax
 3f3:	cd 40                	int    $0x40
 3f5:	c3                   	ret

000003f6 <uptime>:
SYSCALL(uptime)
 3f6:	b8 0e 00 00 00       	mov    $0xe,%eax
 3fb:	cd 40                	int    $0x40
 3fd:	c3                   	ret

000003fe <uthread_init>:

SYSCALL(uthread_init)
 3fe:	b8 16 00 00 00       	mov    $0x16,%eax
 403:	cd 40                	int    $0x40
 405:	c3                   	ret

00000406 <printpt>:
 406:	b8 17 00 00 00       	mov    $0x17,%eax
 40b:	cd 40                	int    $0x40
 40d:	c3                   	ret

0000040e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 40e:	f3 0f 1e fb          	endbr32
 412:	55                   	push   %ebp
 413:	89 e5                	mov    %esp,%ebp
 415:	83 ec 18             	sub    $0x18,%esp
 418:	8b 45 0c             	mov    0xc(%ebp),%eax
 41b:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 41e:	83 ec 04             	sub    $0x4,%esp
 421:	6a 01                	push   $0x1
 423:	8d 45 f4             	lea    -0xc(%ebp),%eax
 426:	50                   	push   %eax
 427:	ff 75 08             	push   0x8(%ebp)
 42a:	e8 4f ff ff ff       	call   37e <write>
 42f:	83 c4 10             	add    $0x10,%esp
}
 432:	90                   	nop
 433:	c9                   	leave
 434:	c3                   	ret

00000435 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 435:	f3 0f 1e fb          	endbr32
 439:	55                   	push   %ebp
 43a:	89 e5                	mov    %esp,%ebp
 43c:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 43f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 446:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 44a:	74 17                	je     463 <printint+0x2e>
 44c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 450:	79 11                	jns    463 <printint+0x2e>
    neg = 1;
 452:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 459:	8b 45 0c             	mov    0xc(%ebp),%eax
 45c:	f7 d8                	neg    %eax
 45e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 461:	eb 06                	jmp    469 <printint+0x34>
  } else {
    x = xx;
 463:	8b 45 0c             	mov    0xc(%ebp),%eax
 466:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 469:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 470:	8b 4d 10             	mov    0x10(%ebp),%ecx
 473:	8b 45 ec             	mov    -0x14(%ebp),%eax
 476:	ba 00 00 00 00       	mov    $0x0,%edx
 47b:	f7 f1                	div    %ecx
 47d:	89 d1                	mov    %edx,%ecx
 47f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 482:	8d 50 01             	lea    0x1(%eax),%edx
 485:	89 55 f4             	mov    %edx,-0xc(%ebp)
 488:	0f b6 91 60 0b 00 00 	movzbl 0xb60(%ecx),%edx
 48f:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 493:	8b 4d 10             	mov    0x10(%ebp),%ecx
 496:	8b 45 ec             	mov    -0x14(%ebp),%eax
 499:	ba 00 00 00 00       	mov    $0x0,%edx
 49e:	f7 f1                	div    %ecx
 4a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4a3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4a7:	75 c7                	jne    470 <printint+0x3b>
  if(neg)
 4a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4ad:	74 2d                	je     4dc <printint+0xa7>
    buf[i++] = '-';
 4af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b2:	8d 50 01             	lea    0x1(%eax),%edx
 4b5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4b8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4bd:	eb 1d                	jmp    4dc <printint+0xa7>
    putc(fd, buf[i]);
 4bf:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c5:	01 d0                	add    %edx,%eax
 4c7:	0f b6 00             	movzbl (%eax),%eax
 4ca:	0f be c0             	movsbl %al,%eax
 4cd:	83 ec 08             	sub    $0x8,%esp
 4d0:	50                   	push   %eax
 4d1:	ff 75 08             	push   0x8(%ebp)
 4d4:	e8 35 ff ff ff       	call   40e <putc>
 4d9:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 4dc:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4e4:	79 d9                	jns    4bf <printint+0x8a>
}
 4e6:	90                   	nop
 4e7:	90                   	nop
 4e8:	c9                   	leave
 4e9:	c3                   	ret

000004ea <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4ea:	f3 0f 1e fb          	endbr32
 4ee:	55                   	push   %ebp
 4ef:	89 e5                	mov    %esp,%ebp
 4f1:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4f4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4fb:	8d 45 0c             	lea    0xc(%ebp),%eax
 4fe:	83 c0 04             	add    $0x4,%eax
 501:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 504:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 50b:	e9 59 01 00 00       	jmp    669 <printf+0x17f>
    c = fmt[i] & 0xff;
 510:	8b 55 0c             	mov    0xc(%ebp),%edx
 513:	8b 45 f0             	mov    -0x10(%ebp),%eax
 516:	01 d0                	add    %edx,%eax
 518:	0f b6 00             	movzbl (%eax),%eax
 51b:	0f be c0             	movsbl %al,%eax
 51e:	25 ff 00 00 00       	and    $0xff,%eax
 523:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 526:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 52a:	75 2c                	jne    558 <printf+0x6e>
      if(c == '%'){
 52c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 530:	75 0c                	jne    53e <printf+0x54>
        state = '%';
 532:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 539:	e9 27 01 00 00       	jmp    665 <printf+0x17b>
      } else {
        putc(fd, c);
 53e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 541:	0f be c0             	movsbl %al,%eax
 544:	83 ec 08             	sub    $0x8,%esp
 547:	50                   	push   %eax
 548:	ff 75 08             	push   0x8(%ebp)
 54b:	e8 be fe ff ff       	call   40e <putc>
 550:	83 c4 10             	add    $0x10,%esp
 553:	e9 0d 01 00 00       	jmp    665 <printf+0x17b>
      }
    } else if(state == '%'){
 558:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 55c:	0f 85 03 01 00 00    	jne    665 <printf+0x17b>
      if(c == 'd'){
 562:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 566:	75 1e                	jne    586 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 568:	8b 45 e8             	mov    -0x18(%ebp),%eax
 56b:	8b 00                	mov    (%eax),%eax
 56d:	6a 01                	push   $0x1
 56f:	6a 0a                	push   $0xa
 571:	50                   	push   %eax
 572:	ff 75 08             	push   0x8(%ebp)
 575:	e8 bb fe ff ff       	call   435 <printint>
 57a:	83 c4 10             	add    $0x10,%esp
        ap++;
 57d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 581:	e9 d8 00 00 00       	jmp    65e <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 586:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 58a:	74 06                	je     592 <printf+0xa8>
 58c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 590:	75 1e                	jne    5b0 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 592:	8b 45 e8             	mov    -0x18(%ebp),%eax
 595:	8b 00                	mov    (%eax),%eax
 597:	6a 00                	push   $0x0
 599:	6a 10                	push   $0x10
 59b:	50                   	push   %eax
 59c:	ff 75 08             	push   0x8(%ebp)
 59f:	e8 91 fe ff ff       	call   435 <printint>
 5a4:	83 c4 10             	add    $0x10,%esp
        ap++;
 5a7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ab:	e9 ae 00 00 00       	jmp    65e <printf+0x174>
      } else if(c == 's'){
 5b0:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5b4:	75 43                	jne    5f9 <printf+0x10f>
        s = (char*)*ap;
 5b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b9:	8b 00                	mov    (%eax),%eax
 5bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5be:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5c6:	75 25                	jne    5ed <printf+0x103>
          s = "(null)";
 5c8:	c7 45 f4 ef 08 00 00 	movl   $0x8ef,-0xc(%ebp)
        while(*s != 0){
 5cf:	eb 1c                	jmp    5ed <printf+0x103>
          putc(fd, *s);
 5d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d4:	0f b6 00             	movzbl (%eax),%eax
 5d7:	0f be c0             	movsbl %al,%eax
 5da:	83 ec 08             	sub    $0x8,%esp
 5dd:	50                   	push   %eax
 5de:	ff 75 08             	push   0x8(%ebp)
 5e1:	e8 28 fe ff ff       	call   40e <putc>
 5e6:	83 c4 10             	add    $0x10,%esp
          s++;
 5e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 5ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f0:	0f b6 00             	movzbl (%eax),%eax
 5f3:	84 c0                	test   %al,%al
 5f5:	75 da                	jne    5d1 <printf+0xe7>
 5f7:	eb 65                	jmp    65e <printf+0x174>
        }
      } else if(c == 'c'){
 5f9:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5fd:	75 1d                	jne    61c <printf+0x132>
        putc(fd, *ap);
 5ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
 602:	8b 00                	mov    (%eax),%eax
 604:	0f be c0             	movsbl %al,%eax
 607:	83 ec 08             	sub    $0x8,%esp
 60a:	50                   	push   %eax
 60b:	ff 75 08             	push   0x8(%ebp)
 60e:	e8 fb fd ff ff       	call   40e <putc>
 613:	83 c4 10             	add    $0x10,%esp
        ap++;
 616:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 61a:	eb 42                	jmp    65e <printf+0x174>
      } else if(c == '%'){
 61c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 620:	75 17                	jne    639 <printf+0x14f>
        putc(fd, c);
 622:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 625:	0f be c0             	movsbl %al,%eax
 628:	83 ec 08             	sub    $0x8,%esp
 62b:	50                   	push   %eax
 62c:	ff 75 08             	push   0x8(%ebp)
 62f:	e8 da fd ff ff       	call   40e <putc>
 634:	83 c4 10             	add    $0x10,%esp
 637:	eb 25                	jmp    65e <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 639:	83 ec 08             	sub    $0x8,%esp
 63c:	6a 25                	push   $0x25
 63e:	ff 75 08             	push   0x8(%ebp)
 641:	e8 c8 fd ff ff       	call   40e <putc>
 646:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 649:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 64c:	0f be c0             	movsbl %al,%eax
 64f:	83 ec 08             	sub    $0x8,%esp
 652:	50                   	push   %eax
 653:	ff 75 08             	push   0x8(%ebp)
 656:	e8 b3 fd ff ff       	call   40e <putc>
 65b:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 65e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 665:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 669:	8b 55 0c             	mov    0xc(%ebp),%edx
 66c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 66f:	01 d0                	add    %edx,%eax
 671:	0f b6 00             	movzbl (%eax),%eax
 674:	84 c0                	test   %al,%al
 676:	0f 85 94 fe ff ff    	jne    510 <printf+0x26>
    }
  }
}
 67c:	90                   	nop
 67d:	90                   	nop
 67e:	c9                   	leave
 67f:	c3                   	ret

00000680 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 680:	f3 0f 1e fb          	endbr32
 684:	55                   	push   %ebp
 685:	89 e5                	mov    %esp,%ebp
 687:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 68a:	8b 45 08             	mov    0x8(%ebp),%eax
 68d:	83 e8 08             	sub    $0x8,%eax
 690:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 693:	a1 7c 0b 00 00       	mov    0xb7c,%eax
 698:	89 45 fc             	mov    %eax,-0x4(%ebp)
 69b:	eb 24                	jmp    6c1 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 69d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a0:	8b 00                	mov    (%eax),%eax
 6a2:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 6a5:	72 12                	jb     6b9 <free+0x39>
 6a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6aa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6ad:	77 24                	ja     6d3 <free+0x53>
 6af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b2:	8b 00                	mov    (%eax),%eax
 6b4:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6b7:	72 1a                	jb     6d3 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bc:	8b 00                	mov    (%eax),%eax
 6be:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6c7:	76 d4                	jbe    69d <free+0x1d>
 6c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cc:	8b 00                	mov    (%eax),%eax
 6ce:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6d1:	73 ca                	jae    69d <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d6:	8b 40 04             	mov    0x4(%eax),%eax
 6d9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e3:	01 c2                	add    %eax,%edx
 6e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e8:	8b 00                	mov    (%eax),%eax
 6ea:	39 c2                	cmp    %eax,%edx
 6ec:	75 24                	jne    712 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 6ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f1:	8b 50 04             	mov    0x4(%eax),%edx
 6f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f7:	8b 00                	mov    (%eax),%eax
 6f9:	8b 40 04             	mov    0x4(%eax),%eax
 6fc:	01 c2                	add    %eax,%edx
 6fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 701:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 704:	8b 45 fc             	mov    -0x4(%ebp),%eax
 707:	8b 00                	mov    (%eax),%eax
 709:	8b 10                	mov    (%eax),%edx
 70b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70e:	89 10                	mov    %edx,(%eax)
 710:	eb 0a                	jmp    71c <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 712:	8b 45 fc             	mov    -0x4(%ebp),%eax
 715:	8b 10                	mov    (%eax),%edx
 717:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 71c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71f:	8b 40 04             	mov    0x4(%eax),%eax
 722:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 729:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72c:	01 d0                	add    %edx,%eax
 72e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 731:	75 20                	jne    753 <free+0xd3>
    p->s.size += bp->s.size;
 733:	8b 45 fc             	mov    -0x4(%ebp),%eax
 736:	8b 50 04             	mov    0x4(%eax),%edx
 739:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73c:	8b 40 04             	mov    0x4(%eax),%eax
 73f:	01 c2                	add    %eax,%edx
 741:	8b 45 fc             	mov    -0x4(%ebp),%eax
 744:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 747:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74a:	8b 10                	mov    (%eax),%edx
 74c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74f:	89 10                	mov    %edx,(%eax)
 751:	eb 08                	jmp    75b <free+0xdb>
  } else
    p->s.ptr = bp;
 753:	8b 45 fc             	mov    -0x4(%ebp),%eax
 756:	8b 55 f8             	mov    -0x8(%ebp),%edx
 759:	89 10                	mov    %edx,(%eax)
  freep = p;
 75b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75e:	a3 7c 0b 00 00       	mov    %eax,0xb7c
}
 763:	90                   	nop
 764:	c9                   	leave
 765:	c3                   	ret

00000766 <morecore>:

static Header*
morecore(uint nu)
{
 766:	f3 0f 1e fb          	endbr32
 76a:	55                   	push   %ebp
 76b:	89 e5                	mov    %esp,%ebp
 76d:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 770:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 777:	77 07                	ja     780 <morecore+0x1a>
    nu = 4096;
 779:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 780:	8b 45 08             	mov    0x8(%ebp),%eax
 783:	c1 e0 03             	shl    $0x3,%eax
 786:	83 ec 0c             	sub    $0xc,%esp
 789:	50                   	push   %eax
 78a:	e8 57 fc ff ff       	call   3e6 <sbrk>
 78f:	83 c4 10             	add    $0x10,%esp
 792:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 795:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 799:	75 07                	jne    7a2 <morecore+0x3c>
    return 0;
 79b:	b8 00 00 00 00       	mov    $0x0,%eax
 7a0:	eb 26                	jmp    7c8 <morecore+0x62>
  hp = (Header*)p;
 7a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ab:	8b 55 08             	mov    0x8(%ebp),%edx
 7ae:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b4:	83 c0 08             	add    $0x8,%eax
 7b7:	83 ec 0c             	sub    $0xc,%esp
 7ba:	50                   	push   %eax
 7bb:	e8 c0 fe ff ff       	call   680 <free>
 7c0:	83 c4 10             	add    $0x10,%esp
  return freep;
 7c3:	a1 7c 0b 00 00       	mov    0xb7c,%eax
}
 7c8:	c9                   	leave
 7c9:	c3                   	ret

000007ca <malloc>:

void*
malloc(uint nbytes)
{
 7ca:	f3 0f 1e fb          	endbr32
 7ce:	55                   	push   %ebp
 7cf:	89 e5                	mov    %esp,%ebp
 7d1:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7d4:	8b 45 08             	mov    0x8(%ebp),%eax
 7d7:	83 c0 07             	add    $0x7,%eax
 7da:	c1 e8 03             	shr    $0x3,%eax
 7dd:	83 c0 01             	add    $0x1,%eax
 7e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7e3:	a1 7c 0b 00 00       	mov    0xb7c,%eax
 7e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7ef:	75 23                	jne    814 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 7f1:	c7 45 f0 74 0b 00 00 	movl   $0xb74,-0x10(%ebp)
 7f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fb:	a3 7c 0b 00 00       	mov    %eax,0xb7c
 800:	a1 7c 0b 00 00       	mov    0xb7c,%eax
 805:	a3 74 0b 00 00       	mov    %eax,0xb74
    base.s.size = 0;
 80a:	c7 05 78 0b 00 00 00 	movl   $0x0,0xb78
 811:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 814:	8b 45 f0             	mov    -0x10(%ebp),%eax
 817:	8b 00                	mov    (%eax),%eax
 819:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 81c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81f:	8b 40 04             	mov    0x4(%eax),%eax
 822:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 825:	77 4d                	ja     874 <malloc+0xaa>
      if(p->s.size == nunits)
 827:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82a:	8b 40 04             	mov    0x4(%eax),%eax
 82d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 830:	75 0c                	jne    83e <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 832:	8b 45 f4             	mov    -0xc(%ebp),%eax
 835:	8b 10                	mov    (%eax),%edx
 837:	8b 45 f0             	mov    -0x10(%ebp),%eax
 83a:	89 10                	mov    %edx,(%eax)
 83c:	eb 26                	jmp    864 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 83e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 841:	8b 40 04             	mov    0x4(%eax),%eax
 844:	2b 45 ec             	sub    -0x14(%ebp),%eax
 847:	89 c2                	mov    %eax,%edx
 849:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 84f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 852:	8b 40 04             	mov    0x4(%eax),%eax
 855:	c1 e0 03             	shl    $0x3,%eax
 858:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 85b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85e:	8b 55 ec             	mov    -0x14(%ebp),%edx
 861:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 864:	8b 45 f0             	mov    -0x10(%ebp),%eax
 867:	a3 7c 0b 00 00       	mov    %eax,0xb7c
      return (void*)(p + 1);
 86c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86f:	83 c0 08             	add    $0x8,%eax
 872:	eb 3b                	jmp    8af <malloc+0xe5>
    }
    if(p == freep)
 874:	a1 7c 0b 00 00       	mov    0xb7c,%eax
 879:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 87c:	75 1e                	jne    89c <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 87e:	83 ec 0c             	sub    $0xc,%esp
 881:	ff 75 ec             	push   -0x14(%ebp)
 884:	e8 dd fe ff ff       	call   766 <morecore>
 889:	83 c4 10             	add    $0x10,%esp
 88c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 88f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 893:	75 07                	jne    89c <malloc+0xd2>
        return 0;
 895:	b8 00 00 00 00       	mov    $0x0,%eax
 89a:	eb 13                	jmp    8af <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a5:	8b 00                	mov    (%eax),%eax
 8a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8aa:	e9 6d ff ff ff       	jmp    81c <malloc+0x52>
  }
}
 8af:	c9                   	leave
 8b0:	c3                   	ret
