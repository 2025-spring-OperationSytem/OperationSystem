
_stressfs:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	f3 0f 1e fb          	endbr32
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	push   -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	51                   	push   %ecx
  12:	81 ec 24 02 00 00    	sub    $0x224,%esp
  int fd, i;
  char path[] = "stressfs0";
  18:	c7 45 e6 73 74 72 65 	movl   $0x65727473,-0x1a(%ebp)
  1f:	c7 45 ea 73 73 66 73 	movl   $0x73667373,-0x16(%ebp)
  26:	66 c7 45 ee 30 00    	movw   $0x30,-0x12(%ebp)
  char data[512];

  printf(1, "stressfs starting\n");
  2c:	83 ec 08             	sub    $0x8,%esp
  2f:	68 34 09 00 00       	push   $0x934
  34:	6a 01                	push   $0x1
  36:	e8 32 05 00 00       	call   56d <printf>
  3b:	83 c4 10             	add    $0x10,%esp
  memset(data, 'a', sizeof(data));
  3e:	83 ec 04             	sub    $0x4,%esp
  41:	68 00 02 00 00       	push   $0x200
  46:	6a 61                	push   $0x61
  48:	8d 85 e6 fd ff ff    	lea    -0x21a(%ebp),%eax
  4e:	50                   	push   %eax
  4f:	e8 ca 01 00 00       	call   21e <memset>
  54:	83 c4 10             	add    $0x10,%esp

  for(i = 0; i < 4; i++)
  57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  5e:	eb 0d                	jmp    6d <main+0x6d>
    if(fork() > 0)
  60:	e8 64 03 00 00       	call   3c9 <fork>
  65:	85 c0                	test   %eax,%eax
  67:	7f 0c                	jg     75 <main+0x75>
  for(i = 0; i < 4; i++)
  69:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  6d:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
  71:	7e ed                	jle    60 <main+0x60>
  73:	eb 01                	jmp    76 <main+0x76>
      break;
  75:	90                   	nop

  printf(1, "write %d\n", i);
  76:	83 ec 04             	sub    $0x4,%esp
  79:	ff 75 f4             	push   -0xc(%ebp)
  7c:	68 47 09 00 00       	push   $0x947
  81:	6a 01                	push   $0x1
  83:	e8 e5 04 00 00       	call   56d <printf>
  88:	83 c4 10             	add    $0x10,%esp

  path[8] += i;
  8b:	0f b6 45 ee          	movzbl -0x12(%ebp),%eax
  8f:	89 c2                	mov    %eax,%edx
  91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  94:	01 d0                	add    %edx,%eax
  96:	88 45 ee             	mov    %al,-0x12(%ebp)
  fd = open(path, O_CREATE | O_RDWR);
  99:	83 ec 08             	sub    $0x8,%esp
  9c:	68 02 02 00 00       	push   $0x202
  a1:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  a4:	50                   	push   %eax
  a5:	e8 67 03 00 00       	call   411 <open>
  aa:	83 c4 10             	add    $0x10,%esp
  ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; i < 20; i++)
  b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  b7:	eb 1e                	jmp    d7 <main+0xd7>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  b9:	83 ec 04             	sub    $0x4,%esp
  bc:	68 00 02 00 00       	push   $0x200
  c1:	8d 85 e6 fd ff ff    	lea    -0x21a(%ebp),%eax
  c7:	50                   	push   %eax
  c8:	ff 75 f0             	push   -0x10(%ebp)
  cb:	e8 21 03 00 00       	call   3f1 <write>
  d0:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 20; i++)
  d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  d7:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
  db:	7e dc                	jle    b9 <main+0xb9>
  close(fd);
  dd:	83 ec 0c             	sub    $0xc,%esp
  e0:	ff 75 f0             	push   -0x10(%ebp)
  e3:	e8 11 03 00 00       	call   3f9 <close>
  e8:	83 c4 10             	add    $0x10,%esp

  printf(1, "read\n");
  eb:	83 ec 08             	sub    $0x8,%esp
  ee:	68 51 09 00 00       	push   $0x951
  f3:	6a 01                	push   $0x1
  f5:	e8 73 04 00 00       	call   56d <printf>
  fa:	83 c4 10             	add    $0x10,%esp

  fd = open(path, O_RDONLY);
  fd:	83 ec 08             	sub    $0x8,%esp
 100:	6a 00                	push   $0x0
 102:	8d 45 e6             	lea    -0x1a(%ebp),%eax
 105:	50                   	push   %eax
 106:	e8 06 03 00 00       	call   411 <open>
 10b:	83 c4 10             	add    $0x10,%esp
 10e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for (i = 0; i < 20; i++)
 111:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 118:	eb 1e                	jmp    138 <main+0x138>
    read(fd, data, sizeof(data));
 11a:	83 ec 04             	sub    $0x4,%esp
 11d:	68 00 02 00 00       	push   $0x200
 122:	8d 85 e6 fd ff ff    	lea    -0x21a(%ebp),%eax
 128:	50                   	push   %eax
 129:	ff 75 f0             	push   -0x10(%ebp)
 12c:	e8 b8 02 00 00       	call   3e9 <read>
 131:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 20; i++)
 134:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 138:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
 13c:	7e dc                	jle    11a <main+0x11a>
  close(fd);
 13e:	83 ec 0c             	sub    $0xc,%esp
 141:	ff 75 f0             	push   -0x10(%ebp)
 144:	e8 b0 02 00 00       	call   3f9 <close>
 149:	83 c4 10             	add    $0x10,%esp

  wait();
 14c:	e8 88 02 00 00       	call   3d9 <wait>

  exit();
 151:	e8 7b 02 00 00       	call   3d1 <exit>

00000156 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 156:	55                   	push   %ebp
 157:	89 e5                	mov    %esp,%ebp
 159:	57                   	push   %edi
 15a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 15b:	8b 4d 08             	mov    0x8(%ebp),%ecx
 15e:	8b 55 10             	mov    0x10(%ebp),%edx
 161:	8b 45 0c             	mov    0xc(%ebp),%eax
 164:	89 cb                	mov    %ecx,%ebx
 166:	89 df                	mov    %ebx,%edi
 168:	89 d1                	mov    %edx,%ecx
 16a:	fc                   	cld
 16b:	f3 aa                	rep stos %al,%es:(%edi)
 16d:	89 ca                	mov    %ecx,%edx
 16f:	89 fb                	mov    %edi,%ebx
 171:	89 5d 08             	mov    %ebx,0x8(%ebp)
 174:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 177:	90                   	nop
 178:	5b                   	pop    %ebx
 179:	5f                   	pop    %edi
 17a:	5d                   	pop    %ebp
 17b:	c3                   	ret

0000017c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 17c:	f3 0f 1e fb          	endbr32
 180:	55                   	push   %ebp
 181:	89 e5                	mov    %esp,%ebp
 183:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 186:	8b 45 08             	mov    0x8(%ebp),%eax
 189:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 18c:	90                   	nop
 18d:	8b 55 0c             	mov    0xc(%ebp),%edx
 190:	8d 42 01             	lea    0x1(%edx),%eax
 193:	89 45 0c             	mov    %eax,0xc(%ebp)
 196:	8b 45 08             	mov    0x8(%ebp),%eax
 199:	8d 48 01             	lea    0x1(%eax),%ecx
 19c:	89 4d 08             	mov    %ecx,0x8(%ebp)
 19f:	0f b6 12             	movzbl (%edx),%edx
 1a2:	88 10                	mov    %dl,(%eax)
 1a4:	0f b6 00             	movzbl (%eax),%eax
 1a7:	84 c0                	test   %al,%al
 1a9:	75 e2                	jne    18d <strcpy+0x11>
    ;
  return os;
 1ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1ae:	c9                   	leave
 1af:	c3                   	ret

000001b0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b0:	f3 0f 1e fb          	endbr32
 1b4:	55                   	push   %ebp
 1b5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1b7:	eb 08                	jmp    1c1 <strcmp+0x11>
    p++, q++;
 1b9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1bd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 1c1:	8b 45 08             	mov    0x8(%ebp),%eax
 1c4:	0f b6 00             	movzbl (%eax),%eax
 1c7:	84 c0                	test   %al,%al
 1c9:	74 10                	je     1db <strcmp+0x2b>
 1cb:	8b 45 08             	mov    0x8(%ebp),%eax
 1ce:	0f b6 10             	movzbl (%eax),%edx
 1d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d4:	0f b6 00             	movzbl (%eax),%eax
 1d7:	38 c2                	cmp    %al,%dl
 1d9:	74 de                	je     1b9 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 1db:	8b 45 08             	mov    0x8(%ebp),%eax
 1de:	0f b6 00             	movzbl (%eax),%eax
 1e1:	0f b6 d0             	movzbl %al,%edx
 1e4:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e7:	0f b6 00             	movzbl (%eax),%eax
 1ea:	0f b6 c0             	movzbl %al,%eax
 1ed:	29 c2                	sub    %eax,%edx
 1ef:	89 d0                	mov    %edx,%eax
}
 1f1:	5d                   	pop    %ebp
 1f2:	c3                   	ret

000001f3 <strlen>:

uint
strlen(char *s)
{
 1f3:	f3 0f 1e fb          	endbr32
 1f7:	55                   	push   %ebp
 1f8:	89 e5                	mov    %esp,%ebp
 1fa:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 204:	eb 04                	jmp    20a <strlen+0x17>
 206:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 20a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 20d:	8b 45 08             	mov    0x8(%ebp),%eax
 210:	01 d0                	add    %edx,%eax
 212:	0f b6 00             	movzbl (%eax),%eax
 215:	84 c0                	test   %al,%al
 217:	75 ed                	jne    206 <strlen+0x13>
    ;
  return n;
 219:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 21c:	c9                   	leave
 21d:	c3                   	ret

0000021e <memset>:

void*
memset(void *dst, int c, uint n)
{
 21e:	f3 0f 1e fb          	endbr32
 222:	55                   	push   %ebp
 223:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 225:	8b 45 10             	mov    0x10(%ebp),%eax
 228:	50                   	push   %eax
 229:	ff 75 0c             	push   0xc(%ebp)
 22c:	ff 75 08             	push   0x8(%ebp)
 22f:	e8 22 ff ff ff       	call   156 <stosb>
 234:	83 c4 0c             	add    $0xc,%esp
  return dst;
 237:	8b 45 08             	mov    0x8(%ebp),%eax
}
 23a:	c9                   	leave
 23b:	c3                   	ret

0000023c <strchr>:

char*
strchr(const char *s, char c)
{
 23c:	f3 0f 1e fb          	endbr32
 240:	55                   	push   %ebp
 241:	89 e5                	mov    %esp,%ebp
 243:	83 ec 04             	sub    $0x4,%esp
 246:	8b 45 0c             	mov    0xc(%ebp),%eax
 249:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 24c:	eb 14                	jmp    262 <strchr+0x26>
    if(*s == c)
 24e:	8b 45 08             	mov    0x8(%ebp),%eax
 251:	0f b6 00             	movzbl (%eax),%eax
 254:	38 45 fc             	cmp    %al,-0x4(%ebp)
 257:	75 05                	jne    25e <strchr+0x22>
      return (char*)s;
 259:	8b 45 08             	mov    0x8(%ebp),%eax
 25c:	eb 13                	jmp    271 <strchr+0x35>
  for(; *s; s++)
 25e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 262:	8b 45 08             	mov    0x8(%ebp),%eax
 265:	0f b6 00             	movzbl (%eax),%eax
 268:	84 c0                	test   %al,%al
 26a:	75 e2                	jne    24e <strchr+0x12>
  return 0;
 26c:	b8 00 00 00 00       	mov    $0x0,%eax
}
 271:	c9                   	leave
 272:	c3                   	ret

00000273 <gets>:

char*
gets(char *buf, int max)
{
 273:	f3 0f 1e fb          	endbr32
 277:	55                   	push   %ebp
 278:	89 e5                	mov    %esp,%ebp
 27a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 284:	eb 42                	jmp    2c8 <gets+0x55>
    cc = read(0, &c, 1);
 286:	83 ec 04             	sub    $0x4,%esp
 289:	6a 01                	push   $0x1
 28b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 28e:	50                   	push   %eax
 28f:	6a 00                	push   $0x0
 291:	e8 53 01 00 00       	call   3e9 <read>
 296:	83 c4 10             	add    $0x10,%esp
 299:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 29c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2a0:	7e 33                	jle    2d5 <gets+0x62>
      break;
    buf[i++] = c;
 2a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a5:	8d 50 01             	lea    0x1(%eax),%edx
 2a8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2ab:	89 c2                	mov    %eax,%edx
 2ad:	8b 45 08             	mov    0x8(%ebp),%eax
 2b0:	01 c2                	add    %eax,%edx
 2b2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2b6:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2b8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2bc:	3c 0a                	cmp    $0xa,%al
 2be:	74 16                	je     2d6 <gets+0x63>
 2c0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2c4:	3c 0d                	cmp    $0xd,%al
 2c6:	74 0e                	je     2d6 <gets+0x63>
  for(i=0; i+1 < max; ){
 2c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2cb:	83 c0 01             	add    $0x1,%eax
 2ce:	39 45 0c             	cmp    %eax,0xc(%ebp)
 2d1:	7f b3                	jg     286 <gets+0x13>
 2d3:	eb 01                	jmp    2d6 <gets+0x63>
      break;
 2d5:	90                   	nop
      break;
  }
  buf[i] = '\0';
 2d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2d9:	8b 45 08             	mov    0x8(%ebp),%eax
 2dc:	01 d0                	add    %edx,%eax
 2de:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2e1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2e4:	c9                   	leave
 2e5:	c3                   	ret

000002e6 <stat>:

int
stat(char *n, struct stat *st)
{
 2e6:	f3 0f 1e fb          	endbr32
 2ea:	55                   	push   %ebp
 2eb:	89 e5                	mov    %esp,%ebp
 2ed:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2f0:	83 ec 08             	sub    $0x8,%esp
 2f3:	6a 00                	push   $0x0
 2f5:	ff 75 08             	push   0x8(%ebp)
 2f8:	e8 14 01 00 00       	call   411 <open>
 2fd:	83 c4 10             	add    $0x10,%esp
 300:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 303:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 307:	79 07                	jns    310 <stat+0x2a>
    return -1;
 309:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 30e:	eb 25                	jmp    335 <stat+0x4f>
  r = fstat(fd, st);
 310:	83 ec 08             	sub    $0x8,%esp
 313:	ff 75 0c             	push   0xc(%ebp)
 316:	ff 75 f4             	push   -0xc(%ebp)
 319:	e8 0b 01 00 00       	call   429 <fstat>
 31e:	83 c4 10             	add    $0x10,%esp
 321:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 324:	83 ec 0c             	sub    $0xc,%esp
 327:	ff 75 f4             	push   -0xc(%ebp)
 32a:	e8 ca 00 00 00       	call   3f9 <close>
 32f:	83 c4 10             	add    $0x10,%esp
  return r;
 332:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 335:	c9                   	leave
 336:	c3                   	ret

00000337 <atoi>:

int
atoi(const char *s)
{
 337:	f3 0f 1e fb          	endbr32
 33b:	55                   	push   %ebp
 33c:	89 e5                	mov    %esp,%ebp
 33e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 341:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 348:	eb 25                	jmp    36f <atoi+0x38>
    n = n*10 + *s++ - '0';
 34a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 34d:	89 d0                	mov    %edx,%eax
 34f:	c1 e0 02             	shl    $0x2,%eax
 352:	01 d0                	add    %edx,%eax
 354:	01 c0                	add    %eax,%eax
 356:	89 c1                	mov    %eax,%ecx
 358:	8b 45 08             	mov    0x8(%ebp),%eax
 35b:	8d 50 01             	lea    0x1(%eax),%edx
 35e:	89 55 08             	mov    %edx,0x8(%ebp)
 361:	0f b6 00             	movzbl (%eax),%eax
 364:	0f be c0             	movsbl %al,%eax
 367:	01 c8                	add    %ecx,%eax
 369:	83 e8 30             	sub    $0x30,%eax
 36c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 36f:	8b 45 08             	mov    0x8(%ebp),%eax
 372:	0f b6 00             	movzbl (%eax),%eax
 375:	3c 2f                	cmp    $0x2f,%al
 377:	7e 0a                	jle    383 <atoi+0x4c>
 379:	8b 45 08             	mov    0x8(%ebp),%eax
 37c:	0f b6 00             	movzbl (%eax),%eax
 37f:	3c 39                	cmp    $0x39,%al
 381:	7e c7                	jle    34a <atoi+0x13>
  return n;
 383:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 386:	c9                   	leave
 387:	c3                   	ret

00000388 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 388:	f3 0f 1e fb          	endbr32
 38c:	55                   	push   %ebp
 38d:	89 e5                	mov    %esp,%ebp
 38f:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 392:	8b 45 08             	mov    0x8(%ebp),%eax
 395:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 398:	8b 45 0c             	mov    0xc(%ebp),%eax
 39b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 39e:	eb 17                	jmp    3b7 <memmove+0x2f>
    *dst++ = *src++;
 3a0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3a3:	8d 42 01             	lea    0x1(%edx),%eax
 3a6:	89 45 f8             	mov    %eax,-0x8(%ebp)
 3a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3ac:	8d 48 01             	lea    0x1(%eax),%ecx
 3af:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 3b2:	0f b6 12             	movzbl (%edx),%edx
 3b5:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 3b7:	8b 45 10             	mov    0x10(%ebp),%eax
 3ba:	8d 50 ff             	lea    -0x1(%eax),%edx
 3bd:	89 55 10             	mov    %edx,0x10(%ebp)
 3c0:	85 c0                	test   %eax,%eax
 3c2:	7f dc                	jg     3a0 <memmove+0x18>
  return vdst;
 3c4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3c7:	c9                   	leave
 3c8:	c3                   	ret

000003c9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3c9:	b8 01 00 00 00       	mov    $0x1,%eax
 3ce:	cd 40                	int    $0x40
 3d0:	c3                   	ret

000003d1 <exit>:
SYSCALL(exit)
 3d1:	b8 02 00 00 00       	mov    $0x2,%eax
 3d6:	cd 40                	int    $0x40
 3d8:	c3                   	ret

000003d9 <wait>:
SYSCALL(wait)
 3d9:	b8 03 00 00 00       	mov    $0x3,%eax
 3de:	cd 40                	int    $0x40
 3e0:	c3                   	ret

000003e1 <pipe>:
SYSCALL(pipe)
 3e1:	b8 04 00 00 00       	mov    $0x4,%eax
 3e6:	cd 40                	int    $0x40
 3e8:	c3                   	ret

000003e9 <read>:
SYSCALL(read)
 3e9:	b8 05 00 00 00       	mov    $0x5,%eax
 3ee:	cd 40                	int    $0x40
 3f0:	c3                   	ret

000003f1 <write>:
SYSCALL(write)
 3f1:	b8 10 00 00 00       	mov    $0x10,%eax
 3f6:	cd 40                	int    $0x40
 3f8:	c3                   	ret

000003f9 <close>:
SYSCALL(close)
 3f9:	b8 15 00 00 00       	mov    $0x15,%eax
 3fe:	cd 40                	int    $0x40
 400:	c3                   	ret

00000401 <kill>:
SYSCALL(kill)
 401:	b8 06 00 00 00       	mov    $0x6,%eax
 406:	cd 40                	int    $0x40
 408:	c3                   	ret

00000409 <exec>:
SYSCALL(exec)
 409:	b8 07 00 00 00       	mov    $0x7,%eax
 40e:	cd 40                	int    $0x40
 410:	c3                   	ret

00000411 <open>:
SYSCALL(open)
 411:	b8 0f 00 00 00       	mov    $0xf,%eax
 416:	cd 40                	int    $0x40
 418:	c3                   	ret

00000419 <mknod>:
SYSCALL(mknod)
 419:	b8 11 00 00 00       	mov    $0x11,%eax
 41e:	cd 40                	int    $0x40
 420:	c3                   	ret

00000421 <unlink>:
SYSCALL(unlink)
 421:	b8 12 00 00 00       	mov    $0x12,%eax
 426:	cd 40                	int    $0x40
 428:	c3                   	ret

00000429 <fstat>:
SYSCALL(fstat)
 429:	b8 08 00 00 00       	mov    $0x8,%eax
 42e:	cd 40                	int    $0x40
 430:	c3                   	ret

00000431 <link>:
SYSCALL(link)
 431:	b8 13 00 00 00       	mov    $0x13,%eax
 436:	cd 40                	int    $0x40
 438:	c3                   	ret

00000439 <mkdir>:
SYSCALL(mkdir)
 439:	b8 14 00 00 00       	mov    $0x14,%eax
 43e:	cd 40                	int    $0x40
 440:	c3                   	ret

00000441 <chdir>:
SYSCALL(chdir)
 441:	b8 09 00 00 00       	mov    $0x9,%eax
 446:	cd 40                	int    $0x40
 448:	c3                   	ret

00000449 <dup>:
SYSCALL(dup)
 449:	b8 0a 00 00 00       	mov    $0xa,%eax
 44e:	cd 40                	int    $0x40
 450:	c3                   	ret

00000451 <getpid>:
SYSCALL(getpid)
 451:	b8 0b 00 00 00       	mov    $0xb,%eax
 456:	cd 40                	int    $0x40
 458:	c3                   	ret

00000459 <sbrk>:
SYSCALL(sbrk)
 459:	b8 0c 00 00 00       	mov    $0xc,%eax
 45e:	cd 40                	int    $0x40
 460:	c3                   	ret

00000461 <sleep>:
SYSCALL(sleep)
 461:	b8 0d 00 00 00       	mov    $0xd,%eax
 466:	cd 40                	int    $0x40
 468:	c3                   	ret

00000469 <uptime>:
SYSCALL(uptime)
 469:	b8 0e 00 00 00       	mov    $0xe,%eax
 46e:	cd 40                	int    $0x40
 470:	c3                   	ret

00000471 <getpinfo>:

SYSCALL(getpinfo)
 471:	b8 16 00 00 00       	mov    $0x16,%eax
 476:	cd 40                	int    $0x40
 478:	c3                   	ret

00000479 <setSchedPolicy>:
SYSCALL(setSchedPolicy)
 479:	b8 17 00 00 00       	mov    $0x17,%eax
 47e:	cd 40                	int    $0x40
 480:	c3                   	ret

00000481 <yield>:
SYSCALL(yield)
 481:	b8 18 00 00 00       	mov    $0x18,%eax
 486:	cd 40                	int    $0x40
 488:	c3                   	ret

00000489 <getSchedPolicy>:
 489:	b8 19 00 00 00       	mov    $0x19,%eax
 48e:	cd 40                	int    $0x40
 490:	c3                   	ret

00000491 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 491:	f3 0f 1e fb          	endbr32
 495:	55                   	push   %ebp
 496:	89 e5                	mov    %esp,%ebp
 498:	83 ec 18             	sub    $0x18,%esp
 49b:	8b 45 0c             	mov    0xc(%ebp),%eax
 49e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4a1:	83 ec 04             	sub    $0x4,%esp
 4a4:	6a 01                	push   $0x1
 4a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4a9:	50                   	push   %eax
 4aa:	ff 75 08             	push   0x8(%ebp)
 4ad:	e8 3f ff ff ff       	call   3f1 <write>
 4b2:	83 c4 10             	add    $0x10,%esp
}
 4b5:	90                   	nop
 4b6:	c9                   	leave
 4b7:	c3                   	ret

000004b8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4b8:	f3 0f 1e fb          	endbr32
 4bc:	55                   	push   %ebp
 4bd:	89 e5                	mov    %esp,%ebp
 4bf:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4c2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4c9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4cd:	74 17                	je     4e6 <printint+0x2e>
 4cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4d3:	79 11                	jns    4e6 <printint+0x2e>
    neg = 1;
 4d5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 4df:	f7 d8                	neg    %eax
 4e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4e4:	eb 06                	jmp    4ec <printint+0x34>
  } else {
    x = xx;
 4e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4f9:	ba 00 00 00 00       	mov    $0x0,%edx
 4fe:	f7 f1                	div    %ecx
 500:	89 d1                	mov    %edx,%ecx
 502:	8b 45 f4             	mov    -0xc(%ebp),%eax
 505:	8d 50 01             	lea    0x1(%eax),%edx
 508:	89 55 f4             	mov    %edx,-0xc(%ebp)
 50b:	0f b6 91 a4 0b 00 00 	movzbl 0xba4(%ecx),%edx
 512:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 516:	8b 4d 10             	mov    0x10(%ebp),%ecx
 519:	8b 45 ec             	mov    -0x14(%ebp),%eax
 51c:	ba 00 00 00 00       	mov    $0x0,%edx
 521:	f7 f1                	div    %ecx
 523:	89 45 ec             	mov    %eax,-0x14(%ebp)
 526:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 52a:	75 c7                	jne    4f3 <printint+0x3b>
  if(neg)
 52c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 530:	74 2d                	je     55f <printint+0xa7>
    buf[i++] = '-';
 532:	8b 45 f4             	mov    -0xc(%ebp),%eax
 535:	8d 50 01             	lea    0x1(%eax),%edx
 538:	89 55 f4             	mov    %edx,-0xc(%ebp)
 53b:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 540:	eb 1d                	jmp    55f <printint+0xa7>
    putc(fd, buf[i]);
 542:	8d 55 dc             	lea    -0x24(%ebp),%edx
 545:	8b 45 f4             	mov    -0xc(%ebp),%eax
 548:	01 d0                	add    %edx,%eax
 54a:	0f b6 00             	movzbl (%eax),%eax
 54d:	0f be c0             	movsbl %al,%eax
 550:	83 ec 08             	sub    $0x8,%esp
 553:	50                   	push   %eax
 554:	ff 75 08             	push   0x8(%ebp)
 557:	e8 35 ff ff ff       	call   491 <putc>
 55c:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 55f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 563:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 567:	79 d9                	jns    542 <printint+0x8a>
}
 569:	90                   	nop
 56a:	90                   	nop
 56b:	c9                   	leave
 56c:	c3                   	ret

0000056d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 56d:	f3 0f 1e fb          	endbr32
 571:	55                   	push   %ebp
 572:	89 e5                	mov    %esp,%ebp
 574:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 577:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 57e:	8d 45 0c             	lea    0xc(%ebp),%eax
 581:	83 c0 04             	add    $0x4,%eax
 584:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 587:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 58e:	e9 59 01 00 00       	jmp    6ec <printf+0x17f>
    c = fmt[i] & 0xff;
 593:	8b 55 0c             	mov    0xc(%ebp),%edx
 596:	8b 45 f0             	mov    -0x10(%ebp),%eax
 599:	01 d0                	add    %edx,%eax
 59b:	0f b6 00             	movzbl (%eax),%eax
 59e:	0f be c0             	movsbl %al,%eax
 5a1:	25 ff 00 00 00       	and    $0xff,%eax
 5a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5ad:	75 2c                	jne    5db <printf+0x6e>
      if(c == '%'){
 5af:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5b3:	75 0c                	jne    5c1 <printf+0x54>
        state = '%';
 5b5:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5bc:	e9 27 01 00 00       	jmp    6e8 <printf+0x17b>
      } else {
        putc(fd, c);
 5c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c4:	0f be c0             	movsbl %al,%eax
 5c7:	83 ec 08             	sub    $0x8,%esp
 5ca:	50                   	push   %eax
 5cb:	ff 75 08             	push   0x8(%ebp)
 5ce:	e8 be fe ff ff       	call   491 <putc>
 5d3:	83 c4 10             	add    $0x10,%esp
 5d6:	e9 0d 01 00 00       	jmp    6e8 <printf+0x17b>
      }
    } else if(state == '%'){
 5db:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5df:	0f 85 03 01 00 00    	jne    6e8 <printf+0x17b>
      if(c == 'd'){
 5e5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5e9:	75 1e                	jne    609 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 5eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ee:	8b 00                	mov    (%eax),%eax
 5f0:	6a 01                	push   $0x1
 5f2:	6a 0a                	push   $0xa
 5f4:	50                   	push   %eax
 5f5:	ff 75 08             	push   0x8(%ebp)
 5f8:	e8 bb fe ff ff       	call   4b8 <printint>
 5fd:	83 c4 10             	add    $0x10,%esp
        ap++;
 600:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 604:	e9 d8 00 00 00       	jmp    6e1 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 609:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 60d:	74 06                	je     615 <printf+0xa8>
 60f:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 613:	75 1e                	jne    633 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 615:	8b 45 e8             	mov    -0x18(%ebp),%eax
 618:	8b 00                	mov    (%eax),%eax
 61a:	6a 00                	push   $0x0
 61c:	6a 10                	push   $0x10
 61e:	50                   	push   %eax
 61f:	ff 75 08             	push   0x8(%ebp)
 622:	e8 91 fe ff ff       	call   4b8 <printint>
 627:	83 c4 10             	add    $0x10,%esp
        ap++;
 62a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 62e:	e9 ae 00 00 00       	jmp    6e1 <printf+0x174>
      } else if(c == 's'){
 633:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 637:	75 43                	jne    67c <printf+0x10f>
        s = (char*)*ap;
 639:	8b 45 e8             	mov    -0x18(%ebp),%eax
 63c:	8b 00                	mov    (%eax),%eax
 63e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 641:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 645:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 649:	75 25                	jne    670 <printf+0x103>
          s = "(null)";
 64b:	c7 45 f4 57 09 00 00 	movl   $0x957,-0xc(%ebp)
        while(*s != 0){
 652:	eb 1c                	jmp    670 <printf+0x103>
          putc(fd, *s);
 654:	8b 45 f4             	mov    -0xc(%ebp),%eax
 657:	0f b6 00             	movzbl (%eax),%eax
 65a:	0f be c0             	movsbl %al,%eax
 65d:	83 ec 08             	sub    $0x8,%esp
 660:	50                   	push   %eax
 661:	ff 75 08             	push   0x8(%ebp)
 664:	e8 28 fe ff ff       	call   491 <putc>
 669:	83 c4 10             	add    $0x10,%esp
          s++;
 66c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 670:	8b 45 f4             	mov    -0xc(%ebp),%eax
 673:	0f b6 00             	movzbl (%eax),%eax
 676:	84 c0                	test   %al,%al
 678:	75 da                	jne    654 <printf+0xe7>
 67a:	eb 65                	jmp    6e1 <printf+0x174>
        }
      } else if(c == 'c'){
 67c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 680:	75 1d                	jne    69f <printf+0x132>
        putc(fd, *ap);
 682:	8b 45 e8             	mov    -0x18(%ebp),%eax
 685:	8b 00                	mov    (%eax),%eax
 687:	0f be c0             	movsbl %al,%eax
 68a:	83 ec 08             	sub    $0x8,%esp
 68d:	50                   	push   %eax
 68e:	ff 75 08             	push   0x8(%ebp)
 691:	e8 fb fd ff ff       	call   491 <putc>
 696:	83 c4 10             	add    $0x10,%esp
        ap++;
 699:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 69d:	eb 42                	jmp    6e1 <printf+0x174>
      } else if(c == '%'){
 69f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6a3:	75 17                	jne    6bc <printf+0x14f>
        putc(fd, c);
 6a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6a8:	0f be c0             	movsbl %al,%eax
 6ab:	83 ec 08             	sub    $0x8,%esp
 6ae:	50                   	push   %eax
 6af:	ff 75 08             	push   0x8(%ebp)
 6b2:	e8 da fd ff ff       	call   491 <putc>
 6b7:	83 c4 10             	add    $0x10,%esp
 6ba:	eb 25                	jmp    6e1 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6bc:	83 ec 08             	sub    $0x8,%esp
 6bf:	6a 25                	push   $0x25
 6c1:	ff 75 08             	push   0x8(%ebp)
 6c4:	e8 c8 fd ff ff       	call   491 <putc>
 6c9:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 6cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6cf:	0f be c0             	movsbl %al,%eax
 6d2:	83 ec 08             	sub    $0x8,%esp
 6d5:	50                   	push   %eax
 6d6:	ff 75 08             	push   0x8(%ebp)
 6d9:	e8 b3 fd ff ff       	call   491 <putc>
 6de:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 6e1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 6e8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6ec:	8b 55 0c             	mov    0xc(%ebp),%edx
 6ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f2:	01 d0                	add    %edx,%eax
 6f4:	0f b6 00             	movzbl (%eax),%eax
 6f7:	84 c0                	test   %al,%al
 6f9:	0f 85 94 fe ff ff    	jne    593 <printf+0x26>
    }
  }
}
 6ff:	90                   	nop
 700:	90                   	nop
 701:	c9                   	leave
 702:	c3                   	ret

00000703 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 703:	f3 0f 1e fb          	endbr32
 707:	55                   	push   %ebp
 708:	89 e5                	mov    %esp,%ebp
 70a:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 70d:	8b 45 08             	mov    0x8(%ebp),%eax
 710:	83 e8 08             	sub    $0x8,%eax
 713:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 716:	a1 c0 0b 00 00       	mov    0xbc0,%eax
 71b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 71e:	eb 24                	jmp    744 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 720:	8b 45 fc             	mov    -0x4(%ebp),%eax
 723:	8b 00                	mov    (%eax),%eax
 725:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 728:	72 12                	jb     73c <free+0x39>
 72a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 730:	77 24                	ja     756 <free+0x53>
 732:	8b 45 fc             	mov    -0x4(%ebp),%eax
 735:	8b 00                	mov    (%eax),%eax
 737:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 73a:	72 1a                	jb     756 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 73c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73f:	8b 00                	mov    (%eax),%eax
 741:	89 45 fc             	mov    %eax,-0x4(%ebp)
 744:	8b 45 f8             	mov    -0x8(%ebp),%eax
 747:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 74a:	76 d4                	jbe    720 <free+0x1d>
 74c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74f:	8b 00                	mov    (%eax),%eax
 751:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 754:	73 ca                	jae    720 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 756:	8b 45 f8             	mov    -0x8(%ebp),%eax
 759:	8b 40 04             	mov    0x4(%eax),%eax
 75c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 763:	8b 45 f8             	mov    -0x8(%ebp),%eax
 766:	01 c2                	add    %eax,%edx
 768:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76b:	8b 00                	mov    (%eax),%eax
 76d:	39 c2                	cmp    %eax,%edx
 76f:	75 24                	jne    795 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 771:	8b 45 f8             	mov    -0x8(%ebp),%eax
 774:	8b 50 04             	mov    0x4(%eax),%edx
 777:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77a:	8b 00                	mov    (%eax),%eax
 77c:	8b 40 04             	mov    0x4(%eax),%eax
 77f:	01 c2                	add    %eax,%edx
 781:	8b 45 f8             	mov    -0x8(%ebp),%eax
 784:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 787:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78a:	8b 00                	mov    (%eax),%eax
 78c:	8b 10                	mov    (%eax),%edx
 78e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 791:	89 10                	mov    %edx,(%eax)
 793:	eb 0a                	jmp    79f <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 795:	8b 45 fc             	mov    -0x4(%ebp),%eax
 798:	8b 10                	mov    (%eax),%edx
 79a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 79f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a2:	8b 40 04             	mov    0x4(%eax),%eax
 7a5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7af:	01 d0                	add    %edx,%eax
 7b1:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7b4:	75 20                	jne    7d6 <free+0xd3>
    p->s.size += bp->s.size;
 7b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b9:	8b 50 04             	mov    0x4(%eax),%edx
 7bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7bf:	8b 40 04             	mov    0x4(%eax),%eax
 7c2:	01 c2                	add    %eax,%edx
 7c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c7:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7cd:	8b 10                	mov    (%eax),%edx
 7cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d2:	89 10                	mov    %edx,(%eax)
 7d4:	eb 08                	jmp    7de <free+0xdb>
  } else
    p->s.ptr = bp;
 7d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7dc:	89 10                	mov    %edx,(%eax)
  freep = p;
 7de:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e1:	a3 c0 0b 00 00       	mov    %eax,0xbc0
}
 7e6:	90                   	nop
 7e7:	c9                   	leave
 7e8:	c3                   	ret

000007e9 <morecore>:

static Header*
morecore(uint nu)
{
 7e9:	f3 0f 1e fb          	endbr32
 7ed:	55                   	push   %ebp
 7ee:	89 e5                	mov    %esp,%ebp
 7f0:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7f3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7fa:	77 07                	ja     803 <morecore+0x1a>
    nu = 4096;
 7fc:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 803:	8b 45 08             	mov    0x8(%ebp),%eax
 806:	c1 e0 03             	shl    $0x3,%eax
 809:	83 ec 0c             	sub    $0xc,%esp
 80c:	50                   	push   %eax
 80d:	e8 47 fc ff ff       	call   459 <sbrk>
 812:	83 c4 10             	add    $0x10,%esp
 815:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 818:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 81c:	75 07                	jne    825 <morecore+0x3c>
    return 0;
 81e:	b8 00 00 00 00       	mov    $0x0,%eax
 823:	eb 26                	jmp    84b <morecore+0x62>
  hp = (Header*)p;
 825:	8b 45 f4             	mov    -0xc(%ebp),%eax
 828:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 82b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 82e:	8b 55 08             	mov    0x8(%ebp),%edx
 831:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 834:	8b 45 f0             	mov    -0x10(%ebp),%eax
 837:	83 c0 08             	add    $0x8,%eax
 83a:	83 ec 0c             	sub    $0xc,%esp
 83d:	50                   	push   %eax
 83e:	e8 c0 fe ff ff       	call   703 <free>
 843:	83 c4 10             	add    $0x10,%esp
  return freep;
 846:	a1 c0 0b 00 00       	mov    0xbc0,%eax
}
 84b:	c9                   	leave
 84c:	c3                   	ret

0000084d <malloc>:

void*
malloc(uint nbytes)
{
 84d:	f3 0f 1e fb          	endbr32
 851:	55                   	push   %ebp
 852:	89 e5                	mov    %esp,%ebp
 854:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 857:	8b 45 08             	mov    0x8(%ebp),%eax
 85a:	83 c0 07             	add    $0x7,%eax
 85d:	c1 e8 03             	shr    $0x3,%eax
 860:	83 c0 01             	add    $0x1,%eax
 863:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 866:	a1 c0 0b 00 00       	mov    0xbc0,%eax
 86b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 86e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 872:	75 23                	jne    897 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 874:	c7 45 f0 b8 0b 00 00 	movl   $0xbb8,-0x10(%ebp)
 87b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87e:	a3 c0 0b 00 00       	mov    %eax,0xbc0
 883:	a1 c0 0b 00 00       	mov    0xbc0,%eax
 888:	a3 b8 0b 00 00       	mov    %eax,0xbb8
    base.s.size = 0;
 88d:	c7 05 bc 0b 00 00 00 	movl   $0x0,0xbbc
 894:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 897:	8b 45 f0             	mov    -0x10(%ebp),%eax
 89a:	8b 00                	mov    (%eax),%eax
 89c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 89f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a2:	8b 40 04             	mov    0x4(%eax),%eax
 8a5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 8a8:	77 4d                	ja     8f7 <malloc+0xaa>
      if(p->s.size == nunits)
 8aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ad:	8b 40 04             	mov    0x4(%eax),%eax
 8b0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 8b3:	75 0c                	jne    8c1 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 8b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b8:	8b 10                	mov    (%eax),%edx
 8ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8bd:	89 10                	mov    %edx,(%eax)
 8bf:	eb 26                	jmp    8e7 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 8c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c4:	8b 40 04             	mov    0x4(%eax),%eax
 8c7:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8ca:	89 c2                	mov    %eax,%edx
 8cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cf:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d5:	8b 40 04             	mov    0x4(%eax),%eax
 8d8:	c1 e0 03             	shl    $0x3,%eax
 8db:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8e4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ea:	a3 c0 0b 00 00       	mov    %eax,0xbc0
      return (void*)(p + 1);
 8ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f2:	83 c0 08             	add    $0x8,%eax
 8f5:	eb 3b                	jmp    932 <malloc+0xe5>
    }
    if(p == freep)
 8f7:	a1 c0 0b 00 00       	mov    0xbc0,%eax
 8fc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8ff:	75 1e                	jne    91f <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 901:	83 ec 0c             	sub    $0xc,%esp
 904:	ff 75 ec             	push   -0x14(%ebp)
 907:	e8 dd fe ff ff       	call   7e9 <morecore>
 90c:	83 c4 10             	add    $0x10,%esp
 90f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 912:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 916:	75 07                	jne    91f <malloc+0xd2>
        return 0;
 918:	b8 00 00 00 00       	mov    $0x0,%eax
 91d:	eb 13                	jmp    932 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 91f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 922:	89 45 f0             	mov    %eax,-0x10(%ebp)
 925:	8b 45 f4             	mov    -0xc(%ebp),%eax
 928:	8b 00                	mov    (%eax),%eax
 92a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 92d:	e9 6d ff ff ff       	jmp    89f <malloc+0x52>
  }
}
 932:	c9                   	leave
 933:	c3                   	ret
