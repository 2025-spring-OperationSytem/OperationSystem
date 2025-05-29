
_memtest:     file format elf32-i386


Disassembly of section .text:

00000000 <mem>:
int stdout = 1;
#define TOTAL_MEMORY (1 << 20) + (1 << 18)

void
mem(void)
{
   0:	f3 0f 1e fb          	endbr32
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 ec 28             	sub    $0x28,%esp
	void *m1 = 0, *m2, *start;
   a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	uint cur = 0;
  11:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	uint count = 0;
  18:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	uint total_count;
	int pid;

	printf(1, "mem test\n");
  1f:	83 ec 08             	sub    $0x8,%esp
  22:	68 a4 09 00 00       	push   $0x9a4
  27:	6a 01                	push   $0x1
  29:	e8 99 05 00 00       	call   5c7 <printf>
  2e:	83 c4 10             	add    $0x10,%esp

	m1 = malloc(4096);
  31:	83 ec 0c             	sub    $0xc,%esp
  34:	68 00 10 00 00       	push   $0x1000
  39:	e8 69 08 00 00       	call   8a7 <malloc>
  3e:	83 c4 10             	add    $0x10,%esp
  41:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (m1 == 0)
  44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  48:	0f 84 18 01 00 00    	je     166 <mem+0x166>
		goto failed;
	start = m1;
  4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  51:	89 45 e8             	mov    %eax,-0x18(%ebp)

	while (cur < TOTAL_MEMORY) {
  54:	eb 43                	jmp    99 <mem+0x99>
		m2 = malloc(4096);
  56:	83 ec 0c             	sub    $0xc,%esp
  59:	68 00 10 00 00       	push   $0x1000
  5e:	e8 44 08 00 00       	call   8a7 <malloc>
  63:	83 c4 10             	add    $0x10,%esp
  66:	89 45 dc             	mov    %eax,-0x24(%ebp)
		if (m2 == 0)
  69:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  6d:	0f 84 f6 00 00 00    	je     169 <mem+0x169>
			goto failed;
		*(char**)m1 = m2;
  73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  76:	8b 55 dc             	mov    -0x24(%ebp),%edx
  79:	89 10                	mov    %edx,(%eax)
		((int*)m1)[2] = count++;
  7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  7e:	8d 50 01             	lea    0x1(%eax),%edx
  81:	89 55 ec             	mov    %edx,-0x14(%ebp)
  84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  87:	83 c2 08             	add    $0x8,%edx
  8a:	89 02                	mov    %eax,(%edx)
		m1 = m2;
  8c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
		cur += 4096;
  92:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
	while (cur < TOTAL_MEMORY) {
  99:	81 7d f0 ff ff 13 00 	cmpl   $0x13ffff,-0x10(%ebp)
  a0:	76 b4                	jbe    56 <mem+0x56>
	}
	((int*)m1)[2] = count;
  a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  a5:	8d 50 08             	lea    0x8(%eax),%edx
  a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  ab:	89 02                	mov    %eax,(%edx)
	total_count = count;
  ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	count = 0;
  b3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	m1 = start;
  ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
  bd:	89 45 f4             	mov    %eax,-0xc(%ebp)

	while (count != total_count) {
  c0:	eb 1d                	jmp    df <mem+0xdf>
		if (((int*)m1)[2] != count)
  c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  c5:	83 c0 08             	add    $0x8,%eax
  c8:	8b 00                	mov    (%eax),%eax
  ca:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  cd:	0f 85 99 00 00 00    	jne    16c <mem+0x16c>
			goto failed;
		m1 = *(char**)m1;
  d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  d6:	8b 00                	mov    (%eax),%eax
  d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
		count++;
  db:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
	while (count != total_count) {
  df:	8b 45 ec             	mov    -0x14(%ebp),%eax
  e2:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  e5:	75 db                	jne    c2 <mem+0xc2>
	}

	pid = fork();
  e7:	e8 47 03 00 00       	call   433 <fork>
  ec:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if (pid == 0){
  ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  f3:	75 35                	jne    12a <mem+0x12a>
		count = 0;
  f5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		m1 = start;
  fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
	
		while (count != total_count) {
 102:	eb 19                	jmp    11d <mem+0x11d>
			if (((int*)m1)[2] != count){
 104:	8b 45 f4             	mov    -0xc(%ebp),%eax
 107:	83 c0 08             	add    $0x8,%eax
 10a:	8b 00                	mov    (%eax),%eax
 10c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 10f:	75 5e                	jne    16f <mem+0x16f>
				goto failed;
			}
			m1 = *(char**)m1;
 111:	8b 45 f4             	mov    -0xc(%ebp),%eax
 114:	8b 00                	mov    (%eax),%eax
 116:	89 45 f4             	mov    %eax,-0xc(%ebp)
			count++;
 119:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
		while (count != total_count) {
 11d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 120:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
 123:	75 df                	jne    104 <mem+0x104>
		}
		exit();
 125:	e8 11 03 00 00       	call   43b <exit>
	}
	else if (pid < 0)
 12a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
 12e:	79 14                	jns    144 <mem+0x144>
	{
		printf(1, "fork failed\n");
 130:	83 ec 08             	sub    $0x8,%esp
 133:	68 ae 09 00 00       	push   $0x9ae
 138:	6a 01                	push   $0x1
 13a:	e8 88 04 00 00       	call   5c7 <printf>
 13f:	83 c4 10             	add    $0x10,%esp
 142:	eb 0b                	jmp    14f <mem+0x14f>
	}
	else if (pid > 0)
 144:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
 148:	7e 05                	jle    14f <mem+0x14f>
	{
		wait();
 14a:	e8 f4 02 00 00       	call   443 <wait>
	}

	printf(1, "mem ok\n");
 14f:	83 ec 08             	sub    $0x8,%esp
 152:	68 bb 09 00 00       	push   $0x9bb
 157:	6a 01                	push   $0x1
 159:	e8 69 04 00 00       	call   5c7 <printf>
 15e:	83 c4 10             	add    $0x10,%esp
	exit();
 161:	e8 d5 02 00 00       	call   43b <exit>
		goto failed;
 166:	90                   	nop
 167:	eb 07                	jmp    170 <mem+0x170>
			goto failed;
 169:	90                   	nop
 16a:	eb 04                	jmp    170 <mem+0x170>
			goto failed;
 16c:	90                   	nop
 16d:	eb 01                	jmp    170 <mem+0x170>
				goto failed;
 16f:	90                   	nop
failed:
	printf(1, "test failed!\n");
 170:	83 ec 08             	sub    $0x8,%esp
 173:	68 c3 09 00 00       	push   $0x9c3
 178:	6a 01                	push   $0x1
 17a:	e8 48 04 00 00       	call   5c7 <printf>
 17f:	83 c4 10             	add    $0x10,%esp
	exit();
 182:	e8 b4 02 00 00       	call   43b <exit>

00000187 <main>:
}

int
main(int argc, char *argv[])
{
 187:	f3 0f 1e fb          	endbr32
 18b:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 18f:	83 e4 f0             	and    $0xfffffff0,%esp
 192:	ff 71 fc             	push   -0x4(%ecx)
 195:	55                   	push   %ebp
 196:	89 e5                	mov    %esp,%ebp
 198:	51                   	push   %ecx
 199:	83 ec 04             	sub    $0x4,%esp
	printf(1, "memtest starting\n");
 19c:	83 ec 08             	sub    $0x8,%esp
 19f:	68 d1 09 00 00       	push   $0x9d1
 1a4:	6a 01                	push   $0x1
 1a6:	e8 1c 04 00 00       	call   5c7 <printf>
 1ab:	83 c4 10             	add    $0x10,%esp
	mem();
 1ae:	e8 4d fe ff ff       	call   0 <mem>
	return 0;
 1b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1b8:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 1bb:	c9                   	leave
 1bc:	8d 61 fc             	lea    -0x4(%ecx),%esp
 1bf:	c3                   	ret

000001c0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1c0:	55                   	push   %ebp
 1c1:	89 e5                	mov    %esp,%ebp
 1c3:	57                   	push   %edi
 1c4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1c8:	8b 55 10             	mov    0x10(%ebp),%edx
 1cb:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ce:	89 cb                	mov    %ecx,%ebx
 1d0:	89 df                	mov    %ebx,%edi
 1d2:	89 d1                	mov    %edx,%ecx
 1d4:	fc                   	cld
 1d5:	f3 aa                	rep stos %al,%es:(%edi)
 1d7:	89 ca                	mov    %ecx,%edx
 1d9:	89 fb                	mov    %edi,%ebx
 1db:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1de:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1e1:	90                   	nop
 1e2:	5b                   	pop    %ebx
 1e3:	5f                   	pop    %edi
 1e4:	5d                   	pop    %ebp
 1e5:	c3                   	ret

000001e6 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1e6:	f3 0f 1e fb          	endbr32
 1ea:	55                   	push   %ebp
 1eb:	89 e5                	mov    %esp,%ebp
 1ed:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1f0:	8b 45 08             	mov    0x8(%ebp),%eax
 1f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1f6:	90                   	nop
 1f7:	8b 55 0c             	mov    0xc(%ebp),%edx
 1fa:	8d 42 01             	lea    0x1(%edx),%eax
 1fd:	89 45 0c             	mov    %eax,0xc(%ebp)
 200:	8b 45 08             	mov    0x8(%ebp),%eax
 203:	8d 48 01             	lea    0x1(%eax),%ecx
 206:	89 4d 08             	mov    %ecx,0x8(%ebp)
 209:	0f b6 12             	movzbl (%edx),%edx
 20c:	88 10                	mov    %dl,(%eax)
 20e:	0f b6 00             	movzbl (%eax),%eax
 211:	84 c0                	test   %al,%al
 213:	75 e2                	jne    1f7 <strcpy+0x11>
    ;
  return os;
 215:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 218:	c9                   	leave
 219:	c3                   	ret

0000021a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 21a:	f3 0f 1e fb          	endbr32
 21e:	55                   	push   %ebp
 21f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 221:	eb 08                	jmp    22b <strcmp+0x11>
    p++, q++;
 223:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 227:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 22b:	8b 45 08             	mov    0x8(%ebp),%eax
 22e:	0f b6 00             	movzbl (%eax),%eax
 231:	84 c0                	test   %al,%al
 233:	74 10                	je     245 <strcmp+0x2b>
 235:	8b 45 08             	mov    0x8(%ebp),%eax
 238:	0f b6 10             	movzbl (%eax),%edx
 23b:	8b 45 0c             	mov    0xc(%ebp),%eax
 23e:	0f b6 00             	movzbl (%eax),%eax
 241:	38 c2                	cmp    %al,%dl
 243:	74 de                	je     223 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 245:	8b 45 08             	mov    0x8(%ebp),%eax
 248:	0f b6 00             	movzbl (%eax),%eax
 24b:	0f b6 d0             	movzbl %al,%edx
 24e:	8b 45 0c             	mov    0xc(%ebp),%eax
 251:	0f b6 00             	movzbl (%eax),%eax
 254:	0f b6 c0             	movzbl %al,%eax
 257:	29 c2                	sub    %eax,%edx
 259:	89 d0                	mov    %edx,%eax
}
 25b:	5d                   	pop    %ebp
 25c:	c3                   	ret

0000025d <strlen>:

uint
strlen(char *s)
{
 25d:	f3 0f 1e fb          	endbr32
 261:	55                   	push   %ebp
 262:	89 e5                	mov    %esp,%ebp
 264:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 267:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 26e:	eb 04                	jmp    274 <strlen+0x17>
 270:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 274:	8b 55 fc             	mov    -0x4(%ebp),%edx
 277:	8b 45 08             	mov    0x8(%ebp),%eax
 27a:	01 d0                	add    %edx,%eax
 27c:	0f b6 00             	movzbl (%eax),%eax
 27f:	84 c0                	test   %al,%al
 281:	75 ed                	jne    270 <strlen+0x13>
    ;
  return n;
 283:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 286:	c9                   	leave
 287:	c3                   	ret

00000288 <memset>:

void*
memset(void *dst, int c, uint n)
{
 288:	f3 0f 1e fb          	endbr32
 28c:	55                   	push   %ebp
 28d:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 28f:	8b 45 10             	mov    0x10(%ebp),%eax
 292:	50                   	push   %eax
 293:	ff 75 0c             	push   0xc(%ebp)
 296:	ff 75 08             	push   0x8(%ebp)
 299:	e8 22 ff ff ff       	call   1c0 <stosb>
 29e:	83 c4 0c             	add    $0xc,%esp
  return dst;
 2a1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a4:	c9                   	leave
 2a5:	c3                   	ret

000002a6 <strchr>:

char*
strchr(const char *s, char c)
{
 2a6:	f3 0f 1e fb          	endbr32
 2aa:	55                   	push   %ebp
 2ab:	89 e5                	mov    %esp,%ebp
 2ad:	83 ec 04             	sub    $0x4,%esp
 2b0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b3:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2b6:	eb 14                	jmp    2cc <strchr+0x26>
    if(*s == c)
 2b8:	8b 45 08             	mov    0x8(%ebp),%eax
 2bb:	0f b6 00             	movzbl (%eax),%eax
 2be:	38 45 fc             	cmp    %al,-0x4(%ebp)
 2c1:	75 05                	jne    2c8 <strchr+0x22>
      return (char*)s;
 2c3:	8b 45 08             	mov    0x8(%ebp),%eax
 2c6:	eb 13                	jmp    2db <strchr+0x35>
  for(; *s; s++)
 2c8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2cc:	8b 45 08             	mov    0x8(%ebp),%eax
 2cf:	0f b6 00             	movzbl (%eax),%eax
 2d2:	84 c0                	test   %al,%al
 2d4:	75 e2                	jne    2b8 <strchr+0x12>
  return 0;
 2d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2db:	c9                   	leave
 2dc:	c3                   	ret

000002dd <gets>:

char*
gets(char *buf, int max)
{
 2dd:	f3 0f 1e fb          	endbr32
 2e1:	55                   	push   %ebp
 2e2:	89 e5                	mov    %esp,%ebp
 2e4:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2ee:	eb 42                	jmp    332 <gets+0x55>
    cc = read(0, &c, 1);
 2f0:	83 ec 04             	sub    $0x4,%esp
 2f3:	6a 01                	push   $0x1
 2f5:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2f8:	50                   	push   %eax
 2f9:	6a 00                	push   $0x0
 2fb:	e8 53 01 00 00       	call   453 <read>
 300:	83 c4 10             	add    $0x10,%esp
 303:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 306:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 30a:	7e 33                	jle    33f <gets+0x62>
      break;
    buf[i++] = c;
 30c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 30f:	8d 50 01             	lea    0x1(%eax),%edx
 312:	89 55 f4             	mov    %edx,-0xc(%ebp)
 315:	89 c2                	mov    %eax,%edx
 317:	8b 45 08             	mov    0x8(%ebp),%eax
 31a:	01 c2                	add    %eax,%edx
 31c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 320:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 322:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 326:	3c 0a                	cmp    $0xa,%al
 328:	74 16                	je     340 <gets+0x63>
 32a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 32e:	3c 0d                	cmp    $0xd,%al
 330:	74 0e                	je     340 <gets+0x63>
  for(i=0; i+1 < max; ){
 332:	8b 45 f4             	mov    -0xc(%ebp),%eax
 335:	83 c0 01             	add    $0x1,%eax
 338:	39 45 0c             	cmp    %eax,0xc(%ebp)
 33b:	7f b3                	jg     2f0 <gets+0x13>
 33d:	eb 01                	jmp    340 <gets+0x63>
      break;
 33f:	90                   	nop
      break;
  }
  buf[i] = '\0';
 340:	8b 55 f4             	mov    -0xc(%ebp),%edx
 343:	8b 45 08             	mov    0x8(%ebp),%eax
 346:	01 d0                	add    %edx,%eax
 348:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 34e:	c9                   	leave
 34f:	c3                   	ret

00000350 <stat>:

int
stat(char *n, struct stat *st)
{
 350:	f3 0f 1e fb          	endbr32
 354:	55                   	push   %ebp
 355:	89 e5                	mov    %esp,%ebp
 357:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 35a:	83 ec 08             	sub    $0x8,%esp
 35d:	6a 00                	push   $0x0
 35f:	ff 75 08             	push   0x8(%ebp)
 362:	e8 14 01 00 00       	call   47b <open>
 367:	83 c4 10             	add    $0x10,%esp
 36a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 36d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 371:	79 07                	jns    37a <stat+0x2a>
    return -1;
 373:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 378:	eb 25                	jmp    39f <stat+0x4f>
  r = fstat(fd, st);
 37a:	83 ec 08             	sub    $0x8,%esp
 37d:	ff 75 0c             	push   0xc(%ebp)
 380:	ff 75 f4             	push   -0xc(%ebp)
 383:	e8 0b 01 00 00       	call   493 <fstat>
 388:	83 c4 10             	add    $0x10,%esp
 38b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 38e:	83 ec 0c             	sub    $0xc,%esp
 391:	ff 75 f4             	push   -0xc(%ebp)
 394:	e8 ca 00 00 00       	call   463 <close>
 399:	83 c4 10             	add    $0x10,%esp
  return r;
 39c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 39f:	c9                   	leave
 3a0:	c3                   	ret

000003a1 <atoi>:

int
atoi(const char *s)
{
 3a1:	f3 0f 1e fb          	endbr32
 3a5:	55                   	push   %ebp
 3a6:	89 e5                	mov    %esp,%ebp
 3a8:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3ab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3b2:	eb 25                	jmp    3d9 <atoi+0x38>
    n = n*10 + *s++ - '0';
 3b4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3b7:	89 d0                	mov    %edx,%eax
 3b9:	c1 e0 02             	shl    $0x2,%eax
 3bc:	01 d0                	add    %edx,%eax
 3be:	01 c0                	add    %eax,%eax
 3c0:	89 c1                	mov    %eax,%ecx
 3c2:	8b 45 08             	mov    0x8(%ebp),%eax
 3c5:	8d 50 01             	lea    0x1(%eax),%edx
 3c8:	89 55 08             	mov    %edx,0x8(%ebp)
 3cb:	0f b6 00             	movzbl (%eax),%eax
 3ce:	0f be c0             	movsbl %al,%eax
 3d1:	01 c8                	add    %ecx,%eax
 3d3:	83 e8 30             	sub    $0x30,%eax
 3d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3d9:	8b 45 08             	mov    0x8(%ebp),%eax
 3dc:	0f b6 00             	movzbl (%eax),%eax
 3df:	3c 2f                	cmp    $0x2f,%al
 3e1:	7e 0a                	jle    3ed <atoi+0x4c>
 3e3:	8b 45 08             	mov    0x8(%ebp),%eax
 3e6:	0f b6 00             	movzbl (%eax),%eax
 3e9:	3c 39                	cmp    $0x39,%al
 3eb:	7e c7                	jle    3b4 <atoi+0x13>
  return n;
 3ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3f0:	c9                   	leave
 3f1:	c3                   	ret

000003f2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3f2:	f3 0f 1e fb          	endbr32
 3f6:	55                   	push   %ebp
 3f7:	89 e5                	mov    %esp,%ebp
 3f9:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 3fc:	8b 45 08             	mov    0x8(%ebp),%eax
 3ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 402:	8b 45 0c             	mov    0xc(%ebp),%eax
 405:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 408:	eb 17                	jmp    421 <memmove+0x2f>
    *dst++ = *src++;
 40a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 40d:	8d 42 01             	lea    0x1(%edx),%eax
 410:	89 45 f8             	mov    %eax,-0x8(%ebp)
 413:	8b 45 fc             	mov    -0x4(%ebp),%eax
 416:	8d 48 01             	lea    0x1(%eax),%ecx
 419:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 41c:	0f b6 12             	movzbl (%edx),%edx
 41f:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 421:	8b 45 10             	mov    0x10(%ebp),%eax
 424:	8d 50 ff             	lea    -0x1(%eax),%edx
 427:	89 55 10             	mov    %edx,0x10(%ebp)
 42a:	85 c0                	test   %eax,%eax
 42c:	7f dc                	jg     40a <memmove+0x18>
  return vdst;
 42e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 431:	c9                   	leave
 432:	c3                   	ret

00000433 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 433:	b8 01 00 00 00       	mov    $0x1,%eax
 438:	cd 40                	int    $0x40
 43a:	c3                   	ret

0000043b <exit>:
SYSCALL(exit)
 43b:	b8 02 00 00 00       	mov    $0x2,%eax
 440:	cd 40                	int    $0x40
 442:	c3                   	ret

00000443 <wait>:
SYSCALL(wait)
 443:	b8 03 00 00 00       	mov    $0x3,%eax
 448:	cd 40                	int    $0x40
 44a:	c3                   	ret

0000044b <pipe>:
SYSCALL(pipe)
 44b:	b8 04 00 00 00       	mov    $0x4,%eax
 450:	cd 40                	int    $0x40
 452:	c3                   	ret

00000453 <read>:
SYSCALL(read)
 453:	b8 05 00 00 00       	mov    $0x5,%eax
 458:	cd 40                	int    $0x40
 45a:	c3                   	ret

0000045b <write>:
SYSCALL(write)
 45b:	b8 10 00 00 00       	mov    $0x10,%eax
 460:	cd 40                	int    $0x40
 462:	c3                   	ret

00000463 <close>:
SYSCALL(close)
 463:	b8 15 00 00 00       	mov    $0x15,%eax
 468:	cd 40                	int    $0x40
 46a:	c3                   	ret

0000046b <kill>:
SYSCALL(kill)
 46b:	b8 06 00 00 00       	mov    $0x6,%eax
 470:	cd 40                	int    $0x40
 472:	c3                   	ret

00000473 <exec>:
SYSCALL(exec)
 473:	b8 07 00 00 00       	mov    $0x7,%eax
 478:	cd 40                	int    $0x40
 47a:	c3                   	ret

0000047b <open>:
SYSCALL(open)
 47b:	b8 0f 00 00 00       	mov    $0xf,%eax
 480:	cd 40                	int    $0x40
 482:	c3                   	ret

00000483 <mknod>:
SYSCALL(mknod)
 483:	b8 11 00 00 00       	mov    $0x11,%eax
 488:	cd 40                	int    $0x40
 48a:	c3                   	ret

0000048b <unlink>:
SYSCALL(unlink)
 48b:	b8 12 00 00 00       	mov    $0x12,%eax
 490:	cd 40                	int    $0x40
 492:	c3                   	ret

00000493 <fstat>:
SYSCALL(fstat)
 493:	b8 08 00 00 00       	mov    $0x8,%eax
 498:	cd 40                	int    $0x40
 49a:	c3                   	ret

0000049b <link>:
SYSCALL(link)
 49b:	b8 13 00 00 00       	mov    $0x13,%eax
 4a0:	cd 40                	int    $0x40
 4a2:	c3                   	ret

000004a3 <mkdir>:
SYSCALL(mkdir)
 4a3:	b8 14 00 00 00       	mov    $0x14,%eax
 4a8:	cd 40                	int    $0x40
 4aa:	c3                   	ret

000004ab <chdir>:
SYSCALL(chdir)
 4ab:	b8 09 00 00 00       	mov    $0x9,%eax
 4b0:	cd 40                	int    $0x40
 4b2:	c3                   	ret

000004b3 <dup>:
SYSCALL(dup)
 4b3:	b8 0a 00 00 00       	mov    $0xa,%eax
 4b8:	cd 40                	int    $0x40
 4ba:	c3                   	ret

000004bb <getpid>:
SYSCALL(getpid)
 4bb:	b8 0b 00 00 00       	mov    $0xb,%eax
 4c0:	cd 40                	int    $0x40
 4c2:	c3                   	ret

000004c3 <sbrk>:
SYSCALL(sbrk)
 4c3:	b8 0c 00 00 00       	mov    $0xc,%eax
 4c8:	cd 40                	int    $0x40
 4ca:	c3                   	ret

000004cb <sleep>:
SYSCALL(sleep)
 4cb:	b8 0d 00 00 00       	mov    $0xd,%eax
 4d0:	cd 40                	int    $0x40
 4d2:	c3                   	ret

000004d3 <uptime>:
SYSCALL(uptime)
 4d3:	b8 0e 00 00 00       	mov    $0xe,%eax
 4d8:	cd 40                	int    $0x40
 4da:	c3                   	ret

000004db <uthread_init>:

SYSCALL(uthread_init)
 4db:	b8 16 00 00 00       	mov    $0x16,%eax
 4e0:	cd 40                	int    $0x40
 4e2:	c3                   	ret

000004e3 <printpt>:
 4e3:	b8 17 00 00 00       	mov    $0x17,%eax
 4e8:	cd 40                	int    $0x40
 4ea:	c3                   	ret

000004eb <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4eb:	f3 0f 1e fb          	endbr32
 4ef:	55                   	push   %ebp
 4f0:	89 e5                	mov    %esp,%ebp
 4f2:	83 ec 18             	sub    $0x18,%esp
 4f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f8:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4fb:	83 ec 04             	sub    $0x4,%esp
 4fe:	6a 01                	push   $0x1
 500:	8d 45 f4             	lea    -0xc(%ebp),%eax
 503:	50                   	push   %eax
 504:	ff 75 08             	push   0x8(%ebp)
 507:	e8 4f ff ff ff       	call   45b <write>
 50c:	83 c4 10             	add    $0x10,%esp
}
 50f:	90                   	nop
 510:	c9                   	leave
 511:	c3                   	ret

00000512 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 512:	f3 0f 1e fb          	endbr32
 516:	55                   	push   %ebp
 517:	89 e5                	mov    %esp,%ebp
 519:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 51c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 523:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 527:	74 17                	je     540 <printint+0x2e>
 529:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 52d:	79 11                	jns    540 <printint+0x2e>
    neg = 1;
 52f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 536:	8b 45 0c             	mov    0xc(%ebp),%eax
 539:	f7 d8                	neg    %eax
 53b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 53e:	eb 06                	jmp    546 <printint+0x34>
  } else {
    x = xx;
 540:	8b 45 0c             	mov    0xc(%ebp),%eax
 543:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 546:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 54d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 550:	8b 45 ec             	mov    -0x14(%ebp),%eax
 553:	ba 00 00 00 00       	mov    $0x0,%edx
 558:	f7 f1                	div    %ecx
 55a:	89 d1                	mov    %edx,%ecx
 55c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 55f:	8d 50 01             	lea    0x1(%eax),%edx
 562:	89 55 f4             	mov    %edx,-0xc(%ebp)
 565:	0f b6 91 6c 0c 00 00 	movzbl 0xc6c(%ecx),%edx
 56c:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 570:	8b 4d 10             	mov    0x10(%ebp),%ecx
 573:	8b 45 ec             	mov    -0x14(%ebp),%eax
 576:	ba 00 00 00 00       	mov    $0x0,%edx
 57b:	f7 f1                	div    %ecx
 57d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 580:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 584:	75 c7                	jne    54d <printint+0x3b>
  if(neg)
 586:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 58a:	74 2d                	je     5b9 <printint+0xa7>
    buf[i++] = '-';
 58c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58f:	8d 50 01             	lea    0x1(%eax),%edx
 592:	89 55 f4             	mov    %edx,-0xc(%ebp)
 595:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 59a:	eb 1d                	jmp    5b9 <printint+0xa7>
    putc(fd, buf[i]);
 59c:	8d 55 dc             	lea    -0x24(%ebp),%edx
 59f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a2:	01 d0                	add    %edx,%eax
 5a4:	0f b6 00             	movzbl (%eax),%eax
 5a7:	0f be c0             	movsbl %al,%eax
 5aa:	83 ec 08             	sub    $0x8,%esp
 5ad:	50                   	push   %eax
 5ae:	ff 75 08             	push   0x8(%ebp)
 5b1:	e8 35 ff ff ff       	call   4eb <putc>
 5b6:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 5b9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5c1:	79 d9                	jns    59c <printint+0x8a>
}
 5c3:	90                   	nop
 5c4:	90                   	nop
 5c5:	c9                   	leave
 5c6:	c3                   	ret

000005c7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5c7:	f3 0f 1e fb          	endbr32
 5cb:	55                   	push   %ebp
 5cc:	89 e5                	mov    %esp,%ebp
 5ce:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5d1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5d8:	8d 45 0c             	lea    0xc(%ebp),%eax
 5db:	83 c0 04             	add    $0x4,%eax
 5de:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5e8:	e9 59 01 00 00       	jmp    746 <printf+0x17f>
    c = fmt[i] & 0xff;
 5ed:	8b 55 0c             	mov    0xc(%ebp),%edx
 5f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5f3:	01 d0                	add    %edx,%eax
 5f5:	0f b6 00             	movzbl (%eax),%eax
 5f8:	0f be c0             	movsbl %al,%eax
 5fb:	25 ff 00 00 00       	and    $0xff,%eax
 600:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 603:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 607:	75 2c                	jne    635 <printf+0x6e>
      if(c == '%'){
 609:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 60d:	75 0c                	jne    61b <printf+0x54>
        state = '%';
 60f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 616:	e9 27 01 00 00       	jmp    742 <printf+0x17b>
      } else {
        putc(fd, c);
 61b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 61e:	0f be c0             	movsbl %al,%eax
 621:	83 ec 08             	sub    $0x8,%esp
 624:	50                   	push   %eax
 625:	ff 75 08             	push   0x8(%ebp)
 628:	e8 be fe ff ff       	call   4eb <putc>
 62d:	83 c4 10             	add    $0x10,%esp
 630:	e9 0d 01 00 00       	jmp    742 <printf+0x17b>
      }
    } else if(state == '%'){
 635:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 639:	0f 85 03 01 00 00    	jne    742 <printf+0x17b>
      if(c == 'd'){
 63f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 643:	75 1e                	jne    663 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 645:	8b 45 e8             	mov    -0x18(%ebp),%eax
 648:	8b 00                	mov    (%eax),%eax
 64a:	6a 01                	push   $0x1
 64c:	6a 0a                	push   $0xa
 64e:	50                   	push   %eax
 64f:	ff 75 08             	push   0x8(%ebp)
 652:	e8 bb fe ff ff       	call   512 <printint>
 657:	83 c4 10             	add    $0x10,%esp
        ap++;
 65a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 65e:	e9 d8 00 00 00       	jmp    73b <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 663:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 667:	74 06                	je     66f <printf+0xa8>
 669:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 66d:	75 1e                	jne    68d <printf+0xc6>
        printint(fd, *ap, 16, 0);
 66f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 672:	8b 00                	mov    (%eax),%eax
 674:	6a 00                	push   $0x0
 676:	6a 10                	push   $0x10
 678:	50                   	push   %eax
 679:	ff 75 08             	push   0x8(%ebp)
 67c:	e8 91 fe ff ff       	call   512 <printint>
 681:	83 c4 10             	add    $0x10,%esp
        ap++;
 684:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 688:	e9 ae 00 00 00       	jmp    73b <printf+0x174>
      } else if(c == 's'){
 68d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 691:	75 43                	jne    6d6 <printf+0x10f>
        s = (char*)*ap;
 693:	8b 45 e8             	mov    -0x18(%ebp),%eax
 696:	8b 00                	mov    (%eax),%eax
 698:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 69b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 69f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6a3:	75 25                	jne    6ca <printf+0x103>
          s = "(null)";
 6a5:	c7 45 f4 e3 09 00 00 	movl   $0x9e3,-0xc(%ebp)
        while(*s != 0){
 6ac:	eb 1c                	jmp    6ca <printf+0x103>
          putc(fd, *s);
 6ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b1:	0f b6 00             	movzbl (%eax),%eax
 6b4:	0f be c0             	movsbl %al,%eax
 6b7:	83 ec 08             	sub    $0x8,%esp
 6ba:	50                   	push   %eax
 6bb:	ff 75 08             	push   0x8(%ebp)
 6be:	e8 28 fe ff ff       	call   4eb <putc>
 6c3:	83 c4 10             	add    $0x10,%esp
          s++;
 6c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 6ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6cd:	0f b6 00             	movzbl (%eax),%eax
 6d0:	84 c0                	test   %al,%al
 6d2:	75 da                	jne    6ae <printf+0xe7>
 6d4:	eb 65                	jmp    73b <printf+0x174>
        }
      } else if(c == 'c'){
 6d6:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6da:	75 1d                	jne    6f9 <printf+0x132>
        putc(fd, *ap);
 6dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6df:	8b 00                	mov    (%eax),%eax
 6e1:	0f be c0             	movsbl %al,%eax
 6e4:	83 ec 08             	sub    $0x8,%esp
 6e7:	50                   	push   %eax
 6e8:	ff 75 08             	push   0x8(%ebp)
 6eb:	e8 fb fd ff ff       	call   4eb <putc>
 6f0:	83 c4 10             	add    $0x10,%esp
        ap++;
 6f3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6f7:	eb 42                	jmp    73b <printf+0x174>
      } else if(c == '%'){
 6f9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6fd:	75 17                	jne    716 <printf+0x14f>
        putc(fd, c);
 6ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 702:	0f be c0             	movsbl %al,%eax
 705:	83 ec 08             	sub    $0x8,%esp
 708:	50                   	push   %eax
 709:	ff 75 08             	push   0x8(%ebp)
 70c:	e8 da fd ff ff       	call   4eb <putc>
 711:	83 c4 10             	add    $0x10,%esp
 714:	eb 25                	jmp    73b <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 716:	83 ec 08             	sub    $0x8,%esp
 719:	6a 25                	push   $0x25
 71b:	ff 75 08             	push   0x8(%ebp)
 71e:	e8 c8 fd ff ff       	call   4eb <putc>
 723:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 726:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 729:	0f be c0             	movsbl %al,%eax
 72c:	83 ec 08             	sub    $0x8,%esp
 72f:	50                   	push   %eax
 730:	ff 75 08             	push   0x8(%ebp)
 733:	e8 b3 fd ff ff       	call   4eb <putc>
 738:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 73b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 742:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 746:	8b 55 0c             	mov    0xc(%ebp),%edx
 749:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74c:	01 d0                	add    %edx,%eax
 74e:	0f b6 00             	movzbl (%eax),%eax
 751:	84 c0                	test   %al,%al
 753:	0f 85 94 fe ff ff    	jne    5ed <printf+0x26>
    }
  }
}
 759:	90                   	nop
 75a:	90                   	nop
 75b:	c9                   	leave
 75c:	c3                   	ret

0000075d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 75d:	f3 0f 1e fb          	endbr32
 761:	55                   	push   %ebp
 762:	89 e5                	mov    %esp,%ebp
 764:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 767:	8b 45 08             	mov    0x8(%ebp),%eax
 76a:	83 e8 08             	sub    $0x8,%eax
 76d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 770:	a1 88 0c 00 00       	mov    0xc88,%eax
 775:	89 45 fc             	mov    %eax,-0x4(%ebp)
 778:	eb 24                	jmp    79e <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 77a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77d:	8b 00                	mov    (%eax),%eax
 77f:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 782:	72 12                	jb     796 <free+0x39>
 784:	8b 45 f8             	mov    -0x8(%ebp),%eax
 787:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 78a:	77 24                	ja     7b0 <free+0x53>
 78c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78f:	8b 00                	mov    (%eax),%eax
 791:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 794:	72 1a                	jb     7b0 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 796:	8b 45 fc             	mov    -0x4(%ebp),%eax
 799:	8b 00                	mov    (%eax),%eax
 79b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 79e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7a4:	76 d4                	jbe    77a <free+0x1d>
 7a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a9:	8b 00                	mov    (%eax),%eax
 7ab:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7ae:	73 ca                	jae    77a <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b3:	8b 40 04             	mov    0x4(%eax),%eax
 7b6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c0:	01 c2                	add    %eax,%edx
 7c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c5:	8b 00                	mov    (%eax),%eax
 7c7:	39 c2                	cmp    %eax,%edx
 7c9:	75 24                	jne    7ef <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 7cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ce:	8b 50 04             	mov    0x4(%eax),%edx
 7d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d4:	8b 00                	mov    (%eax),%eax
 7d6:	8b 40 04             	mov    0x4(%eax),%eax
 7d9:	01 c2                	add    %eax,%edx
 7db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7de:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e4:	8b 00                	mov    (%eax),%eax
 7e6:	8b 10                	mov    (%eax),%edx
 7e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7eb:	89 10                	mov    %edx,(%eax)
 7ed:	eb 0a                	jmp    7f9 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 7ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f2:	8b 10                	mov    (%eax),%edx
 7f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f7:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fc:	8b 40 04             	mov    0x4(%eax),%eax
 7ff:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 806:	8b 45 fc             	mov    -0x4(%ebp),%eax
 809:	01 d0                	add    %edx,%eax
 80b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 80e:	75 20                	jne    830 <free+0xd3>
    p->s.size += bp->s.size;
 810:	8b 45 fc             	mov    -0x4(%ebp),%eax
 813:	8b 50 04             	mov    0x4(%eax),%edx
 816:	8b 45 f8             	mov    -0x8(%ebp),%eax
 819:	8b 40 04             	mov    0x4(%eax),%eax
 81c:	01 c2                	add    %eax,%edx
 81e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 821:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 824:	8b 45 f8             	mov    -0x8(%ebp),%eax
 827:	8b 10                	mov    (%eax),%edx
 829:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82c:	89 10                	mov    %edx,(%eax)
 82e:	eb 08                	jmp    838 <free+0xdb>
  } else
    p->s.ptr = bp;
 830:	8b 45 fc             	mov    -0x4(%ebp),%eax
 833:	8b 55 f8             	mov    -0x8(%ebp),%edx
 836:	89 10                	mov    %edx,(%eax)
  freep = p;
 838:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83b:	a3 88 0c 00 00       	mov    %eax,0xc88
}
 840:	90                   	nop
 841:	c9                   	leave
 842:	c3                   	ret

00000843 <morecore>:

static Header*
morecore(uint nu)
{
 843:	f3 0f 1e fb          	endbr32
 847:	55                   	push   %ebp
 848:	89 e5                	mov    %esp,%ebp
 84a:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 84d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 854:	77 07                	ja     85d <morecore+0x1a>
    nu = 4096;
 856:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 85d:	8b 45 08             	mov    0x8(%ebp),%eax
 860:	c1 e0 03             	shl    $0x3,%eax
 863:	83 ec 0c             	sub    $0xc,%esp
 866:	50                   	push   %eax
 867:	e8 57 fc ff ff       	call   4c3 <sbrk>
 86c:	83 c4 10             	add    $0x10,%esp
 86f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 872:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 876:	75 07                	jne    87f <morecore+0x3c>
    return 0;
 878:	b8 00 00 00 00       	mov    $0x0,%eax
 87d:	eb 26                	jmp    8a5 <morecore+0x62>
  hp = (Header*)p;
 87f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 882:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 885:	8b 45 f0             	mov    -0x10(%ebp),%eax
 888:	8b 55 08             	mov    0x8(%ebp),%edx
 88b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 88e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 891:	83 c0 08             	add    $0x8,%eax
 894:	83 ec 0c             	sub    $0xc,%esp
 897:	50                   	push   %eax
 898:	e8 c0 fe ff ff       	call   75d <free>
 89d:	83 c4 10             	add    $0x10,%esp
  return freep;
 8a0:	a1 88 0c 00 00       	mov    0xc88,%eax
}
 8a5:	c9                   	leave
 8a6:	c3                   	ret

000008a7 <malloc>:

void*
malloc(uint nbytes)
{
 8a7:	f3 0f 1e fb          	endbr32
 8ab:	55                   	push   %ebp
 8ac:	89 e5                	mov    %esp,%ebp
 8ae:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b1:	8b 45 08             	mov    0x8(%ebp),%eax
 8b4:	83 c0 07             	add    $0x7,%eax
 8b7:	c1 e8 03             	shr    $0x3,%eax
 8ba:	83 c0 01             	add    $0x1,%eax
 8bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8c0:	a1 88 0c 00 00       	mov    0xc88,%eax
 8c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8cc:	75 23                	jne    8f1 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 8ce:	c7 45 f0 80 0c 00 00 	movl   $0xc80,-0x10(%ebp)
 8d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d8:	a3 88 0c 00 00       	mov    %eax,0xc88
 8dd:	a1 88 0c 00 00       	mov    0xc88,%eax
 8e2:	a3 80 0c 00 00       	mov    %eax,0xc80
    base.s.size = 0;
 8e7:	c7 05 84 0c 00 00 00 	movl   $0x0,0xc84
 8ee:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f4:	8b 00                	mov    (%eax),%eax
 8f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fc:	8b 40 04             	mov    0x4(%eax),%eax
 8ff:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 902:	77 4d                	ja     951 <malloc+0xaa>
      if(p->s.size == nunits)
 904:	8b 45 f4             	mov    -0xc(%ebp),%eax
 907:	8b 40 04             	mov    0x4(%eax),%eax
 90a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 90d:	75 0c                	jne    91b <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 90f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 912:	8b 10                	mov    (%eax),%edx
 914:	8b 45 f0             	mov    -0x10(%ebp),%eax
 917:	89 10                	mov    %edx,(%eax)
 919:	eb 26                	jmp    941 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 91b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91e:	8b 40 04             	mov    0x4(%eax),%eax
 921:	2b 45 ec             	sub    -0x14(%ebp),%eax
 924:	89 c2                	mov    %eax,%edx
 926:	8b 45 f4             	mov    -0xc(%ebp),%eax
 929:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 92c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92f:	8b 40 04             	mov    0x4(%eax),%eax
 932:	c1 e0 03             	shl    $0x3,%eax
 935:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 938:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 93e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 941:	8b 45 f0             	mov    -0x10(%ebp),%eax
 944:	a3 88 0c 00 00       	mov    %eax,0xc88
      return (void*)(p + 1);
 949:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94c:	83 c0 08             	add    $0x8,%eax
 94f:	eb 3b                	jmp    98c <malloc+0xe5>
    }
    if(p == freep)
 951:	a1 88 0c 00 00       	mov    0xc88,%eax
 956:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 959:	75 1e                	jne    979 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 95b:	83 ec 0c             	sub    $0xc,%esp
 95e:	ff 75 ec             	push   -0x14(%ebp)
 961:	e8 dd fe ff ff       	call   843 <morecore>
 966:	83 c4 10             	add    $0x10,%esp
 969:	89 45 f4             	mov    %eax,-0xc(%ebp)
 96c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 970:	75 07                	jne    979 <malloc+0xd2>
        return 0;
 972:	b8 00 00 00 00       	mov    $0x0,%eax
 977:	eb 13                	jmp    98c <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 979:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 97f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 982:	8b 00                	mov    (%eax),%eax
 984:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 987:	e9 6d ff ff ff       	jmp    8f9 <malloc+0x52>
  }
}
 98c:	c9                   	leave
 98d:	c3                   	ret
