
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

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
  12:	83 ec 14             	sub    $0x14,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
  15:	83 ec 08             	sub    $0x8,%esp
  18:	6a 02                	push   $0x2
  1a:	68 d6 08 00 00       	push   $0x8d6
  1f:	e8 9c 03 00 00       	call   3c0 <open>
  24:	83 c4 10             	add    $0x10,%esp
  27:	85 c0                	test   %eax,%eax
  29:	79 26                	jns    51 <main+0x51>
    mknod("console", 1, 1);
  2b:	83 ec 04             	sub    $0x4,%esp
  2e:	6a 01                	push   $0x1
  30:	6a 01                	push   $0x1
  32:	68 d6 08 00 00       	push   $0x8d6
  37:	e8 8c 03 00 00       	call   3c8 <mknod>
  3c:	83 c4 10             	add    $0x10,%esp
    open("console", O_RDWR);
  3f:	83 ec 08             	sub    $0x8,%esp
  42:	6a 02                	push   $0x2
  44:	68 d6 08 00 00       	push   $0x8d6
  49:	e8 72 03 00 00       	call   3c0 <open>
  4e:	83 c4 10             	add    $0x10,%esp
  }
  dup(0);  // stdout
  51:	83 ec 0c             	sub    $0xc,%esp
  54:	6a 00                	push   $0x0
  56:	e8 9d 03 00 00       	call   3f8 <dup>
  5b:	83 c4 10             	add    $0x10,%esp
  dup(0);  // stderr
  5e:	83 ec 0c             	sub    $0xc,%esp
  61:	6a 00                	push   $0x0
  63:	e8 90 03 00 00       	call   3f8 <dup>
  68:	83 c4 10             	add    $0x10,%esp

  for(;;){
    printf(1, "init: starting sh\n");
  6b:	83 ec 08             	sub    $0x8,%esp
  6e:	68 de 08 00 00       	push   $0x8de
  73:	6a 01                	push   $0x1
  75:	e8 92 04 00 00       	call   50c <printf>
  7a:	83 c4 10             	add    $0x10,%esp
    pid = fork();
  7d:	e8 f6 02 00 00       	call   378 <fork>
  82:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(pid < 0){
  85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  89:	79 17                	jns    a2 <main+0xa2>
      printf(1, "init: fork failed\n");
  8b:	83 ec 08             	sub    $0x8,%esp
  8e:	68 f1 08 00 00       	push   $0x8f1
  93:	6a 01                	push   $0x1
  95:	e8 72 04 00 00       	call   50c <printf>
  9a:	83 c4 10             	add    $0x10,%esp
      exit();
  9d:	e8 de 02 00 00       	call   380 <exit>
    }
    if(pid == 0){
  a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a6:	75 3e                	jne    e6 <main+0xe6>
      exec("sh", argv);
  a8:	83 ec 08             	sub    $0x8,%esp
  ab:	68 70 0b 00 00       	push   $0xb70
  b0:	68 d3 08 00 00       	push   $0x8d3
  b5:	e8 fe 02 00 00       	call   3b8 <exec>
  ba:	83 c4 10             	add    $0x10,%esp
      printf(1, "init: exec sh failed\n");
  bd:	83 ec 08             	sub    $0x8,%esp
  c0:	68 04 09 00 00       	push   $0x904
  c5:	6a 01                	push   $0x1
  c7:	e8 40 04 00 00       	call   50c <printf>
  cc:	83 c4 10             	add    $0x10,%esp
      exit();
  cf:	e8 ac 02 00 00       	call   380 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  d4:	83 ec 08             	sub    $0x8,%esp
  d7:	68 1a 09 00 00       	push   $0x91a
  dc:	6a 01                	push   $0x1
  de:	e8 29 04 00 00       	call   50c <printf>
  e3:	83 c4 10             	add    $0x10,%esp
    while((wpid=wait()) >= 0 && wpid != pid)
  e6:	e8 9d 02 00 00       	call   388 <wait>
  eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  f2:	0f 88 73 ff ff ff    	js     6b <main+0x6b>
  f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  fb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  fe:	75 d4                	jne    d4 <main+0xd4>
    printf(1, "init: starting sh\n");
 100:	e9 66 ff ff ff       	jmp    6b <main+0x6b>

00000105 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 105:	55                   	push   %ebp
 106:	89 e5                	mov    %esp,%ebp
 108:	57                   	push   %edi
 109:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 10a:	8b 4d 08             	mov    0x8(%ebp),%ecx
 10d:	8b 55 10             	mov    0x10(%ebp),%edx
 110:	8b 45 0c             	mov    0xc(%ebp),%eax
 113:	89 cb                	mov    %ecx,%ebx
 115:	89 df                	mov    %ebx,%edi
 117:	89 d1                	mov    %edx,%ecx
 119:	fc                   	cld
 11a:	f3 aa                	rep stos %al,%es:(%edi)
 11c:	89 ca                	mov    %ecx,%edx
 11e:	89 fb                	mov    %edi,%ebx
 120:	89 5d 08             	mov    %ebx,0x8(%ebp)
 123:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 126:	90                   	nop
 127:	5b                   	pop    %ebx
 128:	5f                   	pop    %edi
 129:	5d                   	pop    %ebp
 12a:	c3                   	ret

0000012b <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 12b:	f3 0f 1e fb          	endbr32
 12f:	55                   	push   %ebp
 130:	89 e5                	mov    %esp,%ebp
 132:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 135:	8b 45 08             	mov    0x8(%ebp),%eax
 138:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 13b:	90                   	nop
 13c:	8b 55 0c             	mov    0xc(%ebp),%edx
 13f:	8d 42 01             	lea    0x1(%edx),%eax
 142:	89 45 0c             	mov    %eax,0xc(%ebp)
 145:	8b 45 08             	mov    0x8(%ebp),%eax
 148:	8d 48 01             	lea    0x1(%eax),%ecx
 14b:	89 4d 08             	mov    %ecx,0x8(%ebp)
 14e:	0f b6 12             	movzbl (%edx),%edx
 151:	88 10                	mov    %dl,(%eax)
 153:	0f b6 00             	movzbl (%eax),%eax
 156:	84 c0                	test   %al,%al
 158:	75 e2                	jne    13c <strcpy+0x11>
    ;
  return os;
 15a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 15d:	c9                   	leave
 15e:	c3                   	ret

0000015f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 15f:	f3 0f 1e fb          	endbr32
 163:	55                   	push   %ebp
 164:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 166:	eb 08                	jmp    170 <strcmp+0x11>
    p++, q++;
 168:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 170:	8b 45 08             	mov    0x8(%ebp),%eax
 173:	0f b6 00             	movzbl (%eax),%eax
 176:	84 c0                	test   %al,%al
 178:	74 10                	je     18a <strcmp+0x2b>
 17a:	8b 45 08             	mov    0x8(%ebp),%eax
 17d:	0f b6 10             	movzbl (%eax),%edx
 180:	8b 45 0c             	mov    0xc(%ebp),%eax
 183:	0f b6 00             	movzbl (%eax),%eax
 186:	38 c2                	cmp    %al,%dl
 188:	74 de                	je     168 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 18a:	8b 45 08             	mov    0x8(%ebp),%eax
 18d:	0f b6 00             	movzbl (%eax),%eax
 190:	0f b6 d0             	movzbl %al,%edx
 193:	8b 45 0c             	mov    0xc(%ebp),%eax
 196:	0f b6 00             	movzbl (%eax),%eax
 199:	0f b6 c0             	movzbl %al,%eax
 19c:	29 c2                	sub    %eax,%edx
 19e:	89 d0                	mov    %edx,%eax
}
 1a0:	5d                   	pop    %ebp
 1a1:	c3                   	ret

000001a2 <strlen>:

uint
strlen(char *s)
{
 1a2:	f3 0f 1e fb          	endbr32
 1a6:	55                   	push   %ebp
 1a7:	89 e5                	mov    %esp,%ebp
 1a9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1ac:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1b3:	eb 04                	jmp    1b9 <strlen+0x17>
 1b5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1b9:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1bc:	8b 45 08             	mov    0x8(%ebp),%eax
 1bf:	01 d0                	add    %edx,%eax
 1c1:	0f b6 00             	movzbl (%eax),%eax
 1c4:	84 c0                	test   %al,%al
 1c6:	75 ed                	jne    1b5 <strlen+0x13>
    ;
  return n;
 1c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1cb:	c9                   	leave
 1cc:	c3                   	ret

000001cd <memset>:

void*
memset(void *dst, int c, uint n)
{
 1cd:	f3 0f 1e fb          	endbr32
 1d1:	55                   	push   %ebp
 1d2:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1d4:	8b 45 10             	mov    0x10(%ebp),%eax
 1d7:	50                   	push   %eax
 1d8:	ff 75 0c             	push   0xc(%ebp)
 1db:	ff 75 08             	push   0x8(%ebp)
 1de:	e8 22 ff ff ff       	call   105 <stosb>
 1e3:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1e6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e9:	c9                   	leave
 1ea:	c3                   	ret

000001eb <strchr>:

char*
strchr(const char *s, char c)
{
 1eb:	f3 0f 1e fb          	endbr32
 1ef:	55                   	push   %ebp
 1f0:	89 e5                	mov    %esp,%ebp
 1f2:	83 ec 04             	sub    $0x4,%esp
 1f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f8:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1fb:	eb 14                	jmp    211 <strchr+0x26>
    if(*s == c)
 1fd:	8b 45 08             	mov    0x8(%ebp),%eax
 200:	0f b6 00             	movzbl (%eax),%eax
 203:	38 45 fc             	cmp    %al,-0x4(%ebp)
 206:	75 05                	jne    20d <strchr+0x22>
      return (char*)s;
 208:	8b 45 08             	mov    0x8(%ebp),%eax
 20b:	eb 13                	jmp    220 <strchr+0x35>
  for(; *s; s++)
 20d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 211:	8b 45 08             	mov    0x8(%ebp),%eax
 214:	0f b6 00             	movzbl (%eax),%eax
 217:	84 c0                	test   %al,%al
 219:	75 e2                	jne    1fd <strchr+0x12>
  return 0;
 21b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 220:	c9                   	leave
 221:	c3                   	ret

00000222 <gets>:

char*
gets(char *buf, int max)
{
 222:	f3 0f 1e fb          	endbr32
 226:	55                   	push   %ebp
 227:	89 e5                	mov    %esp,%ebp
 229:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 22c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 233:	eb 42                	jmp    277 <gets+0x55>
    cc = read(0, &c, 1);
 235:	83 ec 04             	sub    $0x4,%esp
 238:	6a 01                	push   $0x1
 23a:	8d 45 ef             	lea    -0x11(%ebp),%eax
 23d:	50                   	push   %eax
 23e:	6a 00                	push   $0x0
 240:	e8 53 01 00 00       	call   398 <read>
 245:	83 c4 10             	add    $0x10,%esp
 248:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 24b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 24f:	7e 33                	jle    284 <gets+0x62>
      break;
    buf[i++] = c;
 251:	8b 45 f4             	mov    -0xc(%ebp),%eax
 254:	8d 50 01             	lea    0x1(%eax),%edx
 257:	89 55 f4             	mov    %edx,-0xc(%ebp)
 25a:	89 c2                	mov    %eax,%edx
 25c:	8b 45 08             	mov    0x8(%ebp),%eax
 25f:	01 c2                	add    %eax,%edx
 261:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 265:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 267:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 26b:	3c 0a                	cmp    $0xa,%al
 26d:	74 16                	je     285 <gets+0x63>
 26f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 273:	3c 0d                	cmp    $0xd,%al
 275:	74 0e                	je     285 <gets+0x63>
  for(i=0; i+1 < max; ){
 277:	8b 45 f4             	mov    -0xc(%ebp),%eax
 27a:	83 c0 01             	add    $0x1,%eax
 27d:	39 45 0c             	cmp    %eax,0xc(%ebp)
 280:	7f b3                	jg     235 <gets+0x13>
 282:	eb 01                	jmp    285 <gets+0x63>
      break;
 284:	90                   	nop
      break;
  }
  buf[i] = '\0';
 285:	8b 55 f4             	mov    -0xc(%ebp),%edx
 288:	8b 45 08             	mov    0x8(%ebp),%eax
 28b:	01 d0                	add    %edx,%eax
 28d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 290:	8b 45 08             	mov    0x8(%ebp),%eax
}
 293:	c9                   	leave
 294:	c3                   	ret

00000295 <stat>:

int
stat(char *n, struct stat *st)
{
 295:	f3 0f 1e fb          	endbr32
 299:	55                   	push   %ebp
 29a:	89 e5                	mov    %esp,%ebp
 29c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29f:	83 ec 08             	sub    $0x8,%esp
 2a2:	6a 00                	push   $0x0
 2a4:	ff 75 08             	push   0x8(%ebp)
 2a7:	e8 14 01 00 00       	call   3c0 <open>
 2ac:	83 c4 10             	add    $0x10,%esp
 2af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b6:	79 07                	jns    2bf <stat+0x2a>
    return -1;
 2b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2bd:	eb 25                	jmp    2e4 <stat+0x4f>
  r = fstat(fd, st);
 2bf:	83 ec 08             	sub    $0x8,%esp
 2c2:	ff 75 0c             	push   0xc(%ebp)
 2c5:	ff 75 f4             	push   -0xc(%ebp)
 2c8:	e8 0b 01 00 00       	call   3d8 <fstat>
 2cd:	83 c4 10             	add    $0x10,%esp
 2d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d3:	83 ec 0c             	sub    $0xc,%esp
 2d6:	ff 75 f4             	push   -0xc(%ebp)
 2d9:	e8 ca 00 00 00       	call   3a8 <close>
 2de:	83 c4 10             	add    $0x10,%esp
  return r;
 2e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e4:	c9                   	leave
 2e5:	c3                   	ret

000002e6 <atoi>:

int
atoi(const char *s)
{
 2e6:	f3 0f 1e fb          	endbr32
 2ea:	55                   	push   %ebp
 2eb:	89 e5                	mov    %esp,%ebp
 2ed:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2f0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f7:	eb 25                	jmp    31e <atoi+0x38>
    n = n*10 + *s++ - '0';
 2f9:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2fc:	89 d0                	mov    %edx,%eax
 2fe:	c1 e0 02             	shl    $0x2,%eax
 301:	01 d0                	add    %edx,%eax
 303:	01 c0                	add    %eax,%eax
 305:	89 c1                	mov    %eax,%ecx
 307:	8b 45 08             	mov    0x8(%ebp),%eax
 30a:	8d 50 01             	lea    0x1(%eax),%edx
 30d:	89 55 08             	mov    %edx,0x8(%ebp)
 310:	0f b6 00             	movzbl (%eax),%eax
 313:	0f be c0             	movsbl %al,%eax
 316:	01 c8                	add    %ecx,%eax
 318:	83 e8 30             	sub    $0x30,%eax
 31b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 31e:	8b 45 08             	mov    0x8(%ebp),%eax
 321:	0f b6 00             	movzbl (%eax),%eax
 324:	3c 2f                	cmp    $0x2f,%al
 326:	7e 0a                	jle    332 <atoi+0x4c>
 328:	8b 45 08             	mov    0x8(%ebp),%eax
 32b:	0f b6 00             	movzbl (%eax),%eax
 32e:	3c 39                	cmp    $0x39,%al
 330:	7e c7                	jle    2f9 <atoi+0x13>
  return n;
 332:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 335:	c9                   	leave
 336:	c3                   	ret

00000337 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 337:	f3 0f 1e fb          	endbr32
 33b:	55                   	push   %ebp
 33c:	89 e5                	mov    %esp,%ebp
 33e:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 341:	8b 45 08             	mov    0x8(%ebp),%eax
 344:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 347:	8b 45 0c             	mov    0xc(%ebp),%eax
 34a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 34d:	eb 17                	jmp    366 <memmove+0x2f>
    *dst++ = *src++;
 34f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 352:	8d 42 01             	lea    0x1(%edx),%eax
 355:	89 45 f8             	mov    %eax,-0x8(%ebp)
 358:	8b 45 fc             	mov    -0x4(%ebp),%eax
 35b:	8d 48 01             	lea    0x1(%eax),%ecx
 35e:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 361:	0f b6 12             	movzbl (%edx),%edx
 364:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 366:	8b 45 10             	mov    0x10(%ebp),%eax
 369:	8d 50 ff             	lea    -0x1(%eax),%edx
 36c:	89 55 10             	mov    %edx,0x10(%ebp)
 36f:	85 c0                	test   %eax,%eax
 371:	7f dc                	jg     34f <memmove+0x18>
  return vdst;
 373:	8b 45 08             	mov    0x8(%ebp),%eax
}
 376:	c9                   	leave
 377:	c3                   	ret

00000378 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 378:	b8 01 00 00 00       	mov    $0x1,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret

00000380 <exit>:
SYSCALL(exit)
 380:	b8 02 00 00 00       	mov    $0x2,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret

00000388 <wait>:
SYSCALL(wait)
 388:	b8 03 00 00 00       	mov    $0x3,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret

00000390 <pipe>:
SYSCALL(pipe)
 390:	b8 04 00 00 00       	mov    $0x4,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret

00000398 <read>:
SYSCALL(read)
 398:	b8 05 00 00 00       	mov    $0x5,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret

000003a0 <write>:
SYSCALL(write)
 3a0:	b8 10 00 00 00       	mov    $0x10,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret

000003a8 <close>:
SYSCALL(close)
 3a8:	b8 15 00 00 00       	mov    $0x15,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret

000003b0 <kill>:
SYSCALL(kill)
 3b0:	b8 06 00 00 00       	mov    $0x6,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret

000003b8 <exec>:
SYSCALL(exec)
 3b8:	b8 07 00 00 00       	mov    $0x7,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret

000003c0 <open>:
SYSCALL(open)
 3c0:	b8 0f 00 00 00       	mov    $0xf,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret

000003c8 <mknod>:
SYSCALL(mknod)
 3c8:	b8 11 00 00 00       	mov    $0x11,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret

000003d0 <unlink>:
SYSCALL(unlink)
 3d0:	b8 12 00 00 00       	mov    $0x12,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret

000003d8 <fstat>:
SYSCALL(fstat)
 3d8:	b8 08 00 00 00       	mov    $0x8,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret

000003e0 <link>:
SYSCALL(link)
 3e0:	b8 13 00 00 00       	mov    $0x13,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret

000003e8 <mkdir>:
SYSCALL(mkdir)
 3e8:	b8 14 00 00 00       	mov    $0x14,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret

000003f0 <chdir>:
SYSCALL(chdir)
 3f0:	b8 09 00 00 00       	mov    $0x9,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret

000003f8 <dup>:
SYSCALL(dup)
 3f8:	b8 0a 00 00 00       	mov    $0xa,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret

00000400 <getpid>:
SYSCALL(getpid)
 400:	b8 0b 00 00 00       	mov    $0xb,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret

00000408 <sbrk>:
SYSCALL(sbrk)
 408:	b8 0c 00 00 00       	mov    $0xc,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret

00000410 <sleep>:
SYSCALL(sleep)
 410:	b8 0d 00 00 00       	mov    $0xd,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret

00000418 <uptime>:
SYSCALL(uptime)
 418:	b8 0e 00 00 00       	mov    $0xe,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret

00000420 <uthread_init>:

SYSCALL(uthread_init)
 420:	b8 16 00 00 00       	mov    $0x16,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret

00000428 <printpt>:
 428:	b8 17 00 00 00       	mov    $0x17,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret

00000430 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 430:	f3 0f 1e fb          	endbr32
 434:	55                   	push   %ebp
 435:	89 e5                	mov    %esp,%ebp
 437:	83 ec 18             	sub    $0x18,%esp
 43a:	8b 45 0c             	mov    0xc(%ebp),%eax
 43d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 440:	83 ec 04             	sub    $0x4,%esp
 443:	6a 01                	push   $0x1
 445:	8d 45 f4             	lea    -0xc(%ebp),%eax
 448:	50                   	push   %eax
 449:	ff 75 08             	push   0x8(%ebp)
 44c:	e8 4f ff ff ff       	call   3a0 <write>
 451:	83 c4 10             	add    $0x10,%esp
}
 454:	90                   	nop
 455:	c9                   	leave
 456:	c3                   	ret

00000457 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 457:	f3 0f 1e fb          	endbr32
 45b:	55                   	push   %ebp
 45c:	89 e5                	mov    %esp,%ebp
 45e:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 461:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 468:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 46c:	74 17                	je     485 <printint+0x2e>
 46e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 472:	79 11                	jns    485 <printint+0x2e>
    neg = 1;
 474:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 47b:	8b 45 0c             	mov    0xc(%ebp),%eax
 47e:	f7 d8                	neg    %eax
 480:	89 45 ec             	mov    %eax,-0x14(%ebp)
 483:	eb 06                	jmp    48b <printint+0x34>
  } else {
    x = xx;
 485:	8b 45 0c             	mov    0xc(%ebp),%eax
 488:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 48b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 492:	8b 4d 10             	mov    0x10(%ebp),%ecx
 495:	8b 45 ec             	mov    -0x14(%ebp),%eax
 498:	ba 00 00 00 00       	mov    $0x0,%edx
 49d:	f7 f1                	div    %ecx
 49f:	89 d1                	mov    %edx,%ecx
 4a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a4:	8d 50 01             	lea    0x1(%eax),%edx
 4a7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4aa:	0f b6 91 78 0b 00 00 	movzbl 0xb78(%ecx),%edx
 4b1:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 4b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4bb:	ba 00 00 00 00       	mov    $0x0,%edx
 4c0:	f7 f1                	div    %ecx
 4c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c9:	75 c7                	jne    492 <printint+0x3b>
  if(neg)
 4cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4cf:	74 2d                	je     4fe <printint+0xa7>
    buf[i++] = '-';
 4d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d4:	8d 50 01             	lea    0x1(%eax),%edx
 4d7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4da:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4df:	eb 1d                	jmp    4fe <printint+0xa7>
    putc(fd, buf[i]);
 4e1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e7:	01 d0                	add    %edx,%eax
 4e9:	0f b6 00             	movzbl (%eax),%eax
 4ec:	0f be c0             	movsbl %al,%eax
 4ef:	83 ec 08             	sub    $0x8,%esp
 4f2:	50                   	push   %eax
 4f3:	ff 75 08             	push   0x8(%ebp)
 4f6:	e8 35 ff ff ff       	call   430 <putc>
 4fb:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 4fe:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 502:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 506:	79 d9                	jns    4e1 <printint+0x8a>
}
 508:	90                   	nop
 509:	90                   	nop
 50a:	c9                   	leave
 50b:	c3                   	ret

0000050c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 50c:	f3 0f 1e fb          	endbr32
 510:	55                   	push   %ebp
 511:	89 e5                	mov    %esp,%ebp
 513:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 516:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 51d:	8d 45 0c             	lea    0xc(%ebp),%eax
 520:	83 c0 04             	add    $0x4,%eax
 523:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 526:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 52d:	e9 59 01 00 00       	jmp    68b <printf+0x17f>
    c = fmt[i] & 0xff;
 532:	8b 55 0c             	mov    0xc(%ebp),%edx
 535:	8b 45 f0             	mov    -0x10(%ebp),%eax
 538:	01 d0                	add    %edx,%eax
 53a:	0f b6 00             	movzbl (%eax),%eax
 53d:	0f be c0             	movsbl %al,%eax
 540:	25 ff 00 00 00       	and    $0xff,%eax
 545:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 548:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 54c:	75 2c                	jne    57a <printf+0x6e>
      if(c == '%'){
 54e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 552:	75 0c                	jne    560 <printf+0x54>
        state = '%';
 554:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 55b:	e9 27 01 00 00       	jmp    687 <printf+0x17b>
      } else {
        putc(fd, c);
 560:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 563:	0f be c0             	movsbl %al,%eax
 566:	83 ec 08             	sub    $0x8,%esp
 569:	50                   	push   %eax
 56a:	ff 75 08             	push   0x8(%ebp)
 56d:	e8 be fe ff ff       	call   430 <putc>
 572:	83 c4 10             	add    $0x10,%esp
 575:	e9 0d 01 00 00       	jmp    687 <printf+0x17b>
      }
    } else if(state == '%'){
 57a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 57e:	0f 85 03 01 00 00    	jne    687 <printf+0x17b>
      if(c == 'd'){
 584:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 588:	75 1e                	jne    5a8 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 58a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 58d:	8b 00                	mov    (%eax),%eax
 58f:	6a 01                	push   $0x1
 591:	6a 0a                	push   $0xa
 593:	50                   	push   %eax
 594:	ff 75 08             	push   0x8(%ebp)
 597:	e8 bb fe ff ff       	call   457 <printint>
 59c:	83 c4 10             	add    $0x10,%esp
        ap++;
 59f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a3:	e9 d8 00 00 00       	jmp    680 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 5a8:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5ac:	74 06                	je     5b4 <printf+0xa8>
 5ae:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5b2:	75 1e                	jne    5d2 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 5b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b7:	8b 00                	mov    (%eax),%eax
 5b9:	6a 00                	push   $0x0
 5bb:	6a 10                	push   $0x10
 5bd:	50                   	push   %eax
 5be:	ff 75 08             	push   0x8(%ebp)
 5c1:	e8 91 fe ff ff       	call   457 <printint>
 5c6:	83 c4 10             	add    $0x10,%esp
        ap++;
 5c9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5cd:	e9 ae 00 00 00       	jmp    680 <printf+0x174>
      } else if(c == 's'){
 5d2:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5d6:	75 43                	jne    61b <printf+0x10f>
        s = (char*)*ap;
 5d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5db:	8b 00                	mov    (%eax),%eax
 5dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5e0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5e8:	75 25                	jne    60f <printf+0x103>
          s = "(null)";
 5ea:	c7 45 f4 23 09 00 00 	movl   $0x923,-0xc(%ebp)
        while(*s != 0){
 5f1:	eb 1c                	jmp    60f <printf+0x103>
          putc(fd, *s);
 5f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f6:	0f b6 00             	movzbl (%eax),%eax
 5f9:	0f be c0             	movsbl %al,%eax
 5fc:	83 ec 08             	sub    $0x8,%esp
 5ff:	50                   	push   %eax
 600:	ff 75 08             	push   0x8(%ebp)
 603:	e8 28 fe ff ff       	call   430 <putc>
 608:	83 c4 10             	add    $0x10,%esp
          s++;
 60b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 60f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 612:	0f b6 00             	movzbl (%eax),%eax
 615:	84 c0                	test   %al,%al
 617:	75 da                	jne    5f3 <printf+0xe7>
 619:	eb 65                	jmp    680 <printf+0x174>
        }
      } else if(c == 'c'){
 61b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 61f:	75 1d                	jne    63e <printf+0x132>
        putc(fd, *ap);
 621:	8b 45 e8             	mov    -0x18(%ebp),%eax
 624:	8b 00                	mov    (%eax),%eax
 626:	0f be c0             	movsbl %al,%eax
 629:	83 ec 08             	sub    $0x8,%esp
 62c:	50                   	push   %eax
 62d:	ff 75 08             	push   0x8(%ebp)
 630:	e8 fb fd ff ff       	call   430 <putc>
 635:	83 c4 10             	add    $0x10,%esp
        ap++;
 638:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 63c:	eb 42                	jmp    680 <printf+0x174>
      } else if(c == '%'){
 63e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 642:	75 17                	jne    65b <printf+0x14f>
        putc(fd, c);
 644:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 647:	0f be c0             	movsbl %al,%eax
 64a:	83 ec 08             	sub    $0x8,%esp
 64d:	50                   	push   %eax
 64e:	ff 75 08             	push   0x8(%ebp)
 651:	e8 da fd ff ff       	call   430 <putc>
 656:	83 c4 10             	add    $0x10,%esp
 659:	eb 25                	jmp    680 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 65b:	83 ec 08             	sub    $0x8,%esp
 65e:	6a 25                	push   $0x25
 660:	ff 75 08             	push   0x8(%ebp)
 663:	e8 c8 fd ff ff       	call   430 <putc>
 668:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 66b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 66e:	0f be c0             	movsbl %al,%eax
 671:	83 ec 08             	sub    $0x8,%esp
 674:	50                   	push   %eax
 675:	ff 75 08             	push   0x8(%ebp)
 678:	e8 b3 fd ff ff       	call   430 <putc>
 67d:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 680:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 687:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 68b:	8b 55 0c             	mov    0xc(%ebp),%edx
 68e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 691:	01 d0                	add    %edx,%eax
 693:	0f b6 00             	movzbl (%eax),%eax
 696:	84 c0                	test   %al,%al
 698:	0f 85 94 fe ff ff    	jne    532 <printf+0x26>
    }
  }
}
 69e:	90                   	nop
 69f:	90                   	nop
 6a0:	c9                   	leave
 6a1:	c3                   	ret

000006a2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6a2:	f3 0f 1e fb          	endbr32
 6a6:	55                   	push   %ebp
 6a7:	89 e5                	mov    %esp,%ebp
 6a9:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ac:	8b 45 08             	mov    0x8(%ebp),%eax
 6af:	83 e8 08             	sub    $0x8,%eax
 6b2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b5:	a1 94 0b 00 00       	mov    0xb94,%eax
 6ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6bd:	eb 24                	jmp    6e3 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c2:	8b 00                	mov    (%eax),%eax
 6c4:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 6c7:	72 12                	jb     6db <free+0x39>
 6c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6cc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6cf:	77 24                	ja     6f5 <free+0x53>
 6d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d4:	8b 00                	mov    (%eax),%eax
 6d6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6d9:	72 1a                	jb     6f5 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6de:	8b 00                	mov    (%eax),%eax
 6e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e9:	76 d4                	jbe    6bf <free+0x1d>
 6eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ee:	8b 00                	mov    (%eax),%eax
 6f0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6f3:	73 ca                	jae    6bf <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f8:	8b 40 04             	mov    0x4(%eax),%eax
 6fb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 702:	8b 45 f8             	mov    -0x8(%ebp),%eax
 705:	01 c2                	add    %eax,%edx
 707:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70a:	8b 00                	mov    (%eax),%eax
 70c:	39 c2                	cmp    %eax,%edx
 70e:	75 24                	jne    734 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 710:	8b 45 f8             	mov    -0x8(%ebp),%eax
 713:	8b 50 04             	mov    0x4(%eax),%edx
 716:	8b 45 fc             	mov    -0x4(%ebp),%eax
 719:	8b 00                	mov    (%eax),%eax
 71b:	8b 40 04             	mov    0x4(%eax),%eax
 71e:	01 c2                	add    %eax,%edx
 720:	8b 45 f8             	mov    -0x8(%ebp),%eax
 723:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 726:	8b 45 fc             	mov    -0x4(%ebp),%eax
 729:	8b 00                	mov    (%eax),%eax
 72b:	8b 10                	mov    (%eax),%edx
 72d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 730:	89 10                	mov    %edx,(%eax)
 732:	eb 0a                	jmp    73e <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 734:	8b 45 fc             	mov    -0x4(%ebp),%eax
 737:	8b 10                	mov    (%eax),%edx
 739:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73c:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 73e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 741:	8b 40 04             	mov    0x4(%eax),%eax
 744:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 74b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74e:	01 d0                	add    %edx,%eax
 750:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 753:	75 20                	jne    775 <free+0xd3>
    p->s.size += bp->s.size;
 755:	8b 45 fc             	mov    -0x4(%ebp),%eax
 758:	8b 50 04             	mov    0x4(%eax),%edx
 75b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75e:	8b 40 04             	mov    0x4(%eax),%eax
 761:	01 c2                	add    %eax,%edx
 763:	8b 45 fc             	mov    -0x4(%ebp),%eax
 766:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 769:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76c:	8b 10                	mov    (%eax),%edx
 76e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 771:	89 10                	mov    %edx,(%eax)
 773:	eb 08                	jmp    77d <free+0xdb>
  } else
    p->s.ptr = bp;
 775:	8b 45 fc             	mov    -0x4(%ebp),%eax
 778:	8b 55 f8             	mov    -0x8(%ebp),%edx
 77b:	89 10                	mov    %edx,(%eax)
  freep = p;
 77d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 780:	a3 94 0b 00 00       	mov    %eax,0xb94
}
 785:	90                   	nop
 786:	c9                   	leave
 787:	c3                   	ret

00000788 <morecore>:

static Header*
morecore(uint nu)
{
 788:	f3 0f 1e fb          	endbr32
 78c:	55                   	push   %ebp
 78d:	89 e5                	mov    %esp,%ebp
 78f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 792:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 799:	77 07                	ja     7a2 <morecore+0x1a>
    nu = 4096;
 79b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7a2:	8b 45 08             	mov    0x8(%ebp),%eax
 7a5:	c1 e0 03             	shl    $0x3,%eax
 7a8:	83 ec 0c             	sub    $0xc,%esp
 7ab:	50                   	push   %eax
 7ac:	e8 57 fc ff ff       	call   408 <sbrk>
 7b1:	83 c4 10             	add    $0x10,%esp
 7b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7b7:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7bb:	75 07                	jne    7c4 <morecore+0x3c>
    return 0;
 7bd:	b8 00 00 00 00       	mov    $0x0,%eax
 7c2:	eb 26                	jmp    7ea <morecore+0x62>
  hp = (Header*)p;
 7c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cd:	8b 55 08             	mov    0x8(%ebp),%edx
 7d0:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d6:	83 c0 08             	add    $0x8,%eax
 7d9:	83 ec 0c             	sub    $0xc,%esp
 7dc:	50                   	push   %eax
 7dd:	e8 c0 fe ff ff       	call   6a2 <free>
 7e2:	83 c4 10             	add    $0x10,%esp
  return freep;
 7e5:	a1 94 0b 00 00       	mov    0xb94,%eax
}
 7ea:	c9                   	leave
 7eb:	c3                   	ret

000007ec <malloc>:

void*
malloc(uint nbytes)
{
 7ec:	f3 0f 1e fb          	endbr32
 7f0:	55                   	push   %ebp
 7f1:	89 e5                	mov    %esp,%ebp
 7f3:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f6:	8b 45 08             	mov    0x8(%ebp),%eax
 7f9:	83 c0 07             	add    $0x7,%eax
 7fc:	c1 e8 03             	shr    $0x3,%eax
 7ff:	83 c0 01             	add    $0x1,%eax
 802:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 805:	a1 94 0b 00 00       	mov    0xb94,%eax
 80a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 80d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 811:	75 23                	jne    836 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 813:	c7 45 f0 8c 0b 00 00 	movl   $0xb8c,-0x10(%ebp)
 81a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81d:	a3 94 0b 00 00       	mov    %eax,0xb94
 822:	a1 94 0b 00 00       	mov    0xb94,%eax
 827:	a3 8c 0b 00 00       	mov    %eax,0xb8c
    base.s.size = 0;
 82c:	c7 05 90 0b 00 00 00 	movl   $0x0,0xb90
 833:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 836:	8b 45 f0             	mov    -0x10(%ebp),%eax
 839:	8b 00                	mov    (%eax),%eax
 83b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 83e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 841:	8b 40 04             	mov    0x4(%eax),%eax
 844:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 847:	77 4d                	ja     896 <malloc+0xaa>
      if(p->s.size == nunits)
 849:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84c:	8b 40 04             	mov    0x4(%eax),%eax
 84f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 852:	75 0c                	jne    860 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 854:	8b 45 f4             	mov    -0xc(%ebp),%eax
 857:	8b 10                	mov    (%eax),%edx
 859:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85c:	89 10                	mov    %edx,(%eax)
 85e:	eb 26                	jmp    886 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 860:	8b 45 f4             	mov    -0xc(%ebp),%eax
 863:	8b 40 04             	mov    0x4(%eax),%eax
 866:	2b 45 ec             	sub    -0x14(%ebp),%eax
 869:	89 c2                	mov    %eax,%edx
 86b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86e:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 871:	8b 45 f4             	mov    -0xc(%ebp),%eax
 874:	8b 40 04             	mov    0x4(%eax),%eax
 877:	c1 e0 03             	shl    $0x3,%eax
 87a:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 87d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 880:	8b 55 ec             	mov    -0x14(%ebp),%edx
 883:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 886:	8b 45 f0             	mov    -0x10(%ebp),%eax
 889:	a3 94 0b 00 00       	mov    %eax,0xb94
      return (void*)(p + 1);
 88e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 891:	83 c0 08             	add    $0x8,%eax
 894:	eb 3b                	jmp    8d1 <malloc+0xe5>
    }
    if(p == freep)
 896:	a1 94 0b 00 00       	mov    0xb94,%eax
 89b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 89e:	75 1e                	jne    8be <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 8a0:	83 ec 0c             	sub    $0xc,%esp
 8a3:	ff 75 ec             	push   -0x14(%ebp)
 8a6:	e8 dd fe ff ff       	call   788 <morecore>
 8ab:	83 c4 10             	add    $0x10,%esp
 8ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8b5:	75 07                	jne    8be <malloc+0xd2>
        return 0;
 8b7:	b8 00 00 00 00       	mov    $0x0,%eax
 8bc:	eb 13                	jmp    8d1 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c7:	8b 00                	mov    (%eax),%eax
 8c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8cc:	e9 6d ff ff ff       	jmp    83e <malloc+0x52>
  }
}
 8d1:	c9                   	leave
 8d2:	c3                   	ret
