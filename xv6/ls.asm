
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	f3 0f 1e fb          	endbr32
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	53                   	push   %ebx
   8:	83 ec 14             	sub    $0x14,%esp
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   b:	83 ec 0c             	sub    $0xc,%esp
   e:	ff 75 08             	push   0x8(%ebp)
  11:	e8 d5 03 00 00       	call   3eb <strlen>
  16:	83 c4 10             	add    $0x10,%esp
  19:	8b 55 08             	mov    0x8(%ebp),%edx
  1c:	01 d0                	add    %edx,%eax
  1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  21:	eb 04                	jmp    27 <fmtname+0x27>
  23:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  2a:	3b 45 08             	cmp    0x8(%ebp),%eax
  2d:	72 0a                	jb     39 <fmtname+0x39>
  2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  32:	0f b6 00             	movzbl (%eax),%eax
  35:	3c 2f                	cmp    $0x2f,%al
  37:	75 ea                	jne    23 <fmtname+0x23>
    ;
  p++;
  39:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3d:	83 ec 0c             	sub    $0xc,%esp
  40:	ff 75 f4             	push   -0xc(%ebp)
  43:	e8 a3 03 00 00       	call   3eb <strlen>
  48:	83 c4 10             	add    $0x10,%esp
  4b:	83 f8 0d             	cmp    $0xd,%eax
  4e:	76 05                	jbe    55 <fmtname+0x55>
    return p;
  50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  53:	eb 60                	jmp    b5 <fmtname+0xb5>
  memmove(buf, p, strlen(p));
  55:	83 ec 0c             	sub    $0xc,%esp
  58:	ff 75 f4             	push   -0xc(%ebp)
  5b:	e8 8b 03 00 00       	call   3eb <strlen>
  60:	83 c4 10             	add    $0x10,%esp
  63:	83 ec 04             	sub    $0x4,%esp
  66:	50                   	push   %eax
  67:	ff 75 f4             	push   -0xc(%ebp)
  6a:	68 20 0e 00 00       	push   $0xe20
  6f:	e8 0c 05 00 00       	call   580 <memmove>
  74:	83 c4 10             	add    $0x10,%esp
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  77:	83 ec 0c             	sub    $0xc,%esp
  7a:	ff 75 f4             	push   -0xc(%ebp)
  7d:	e8 69 03 00 00       	call   3eb <strlen>
  82:	83 c4 10             	add    $0x10,%esp
  85:	ba 0e 00 00 00       	mov    $0xe,%edx
  8a:	89 d3                	mov    %edx,%ebx
  8c:	29 c3                	sub    %eax,%ebx
  8e:	83 ec 0c             	sub    $0xc,%esp
  91:	ff 75 f4             	push   -0xc(%ebp)
  94:	e8 52 03 00 00       	call   3eb <strlen>
  99:	83 c4 10             	add    $0x10,%esp
  9c:	05 20 0e 00 00       	add    $0xe20,%eax
  a1:	83 ec 04             	sub    $0x4,%esp
  a4:	53                   	push   %ebx
  a5:	6a 20                	push   $0x20
  a7:	50                   	push   %eax
  a8:	e8 69 03 00 00       	call   416 <memset>
  ad:	83 c4 10             	add    $0x10,%esp
  return buf;
  b0:	b8 20 0e 00 00       	mov    $0xe20,%eax
}
  b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  b8:	c9                   	leave
  b9:	c3                   	ret

000000ba <ls>:

void
ls(char *path)
{
  ba:	f3 0f 1e fb          	endbr32
  be:	55                   	push   %ebp
  bf:	89 e5                	mov    %esp,%ebp
  c1:	57                   	push   %edi
  c2:	56                   	push   %esi
  c3:	53                   	push   %ebx
  c4:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  ca:	83 ec 08             	sub    $0x8,%esp
  cd:	6a 00                	push   $0x0
  cf:	ff 75 08             	push   0x8(%ebp)
  d2:	e8 32 05 00 00       	call   609 <open>
  d7:	83 c4 10             	add    $0x10,%esp
  da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  dd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  e1:	79 1a                	jns    fd <ls+0x43>
    printf(2, "ls: cannot open %s\n", path);
  e3:	83 ec 04             	sub    $0x4,%esp
  e6:	ff 75 08             	push   0x8(%ebp)
  e9:	68 1c 0b 00 00       	push   $0xb1c
  ee:	6a 02                	push   $0x2
  f0:	e8 60 06 00 00       	call   755 <printf>
  f5:	83 c4 10             	add    $0x10,%esp
    return;
  f8:	e9 e1 01 00 00       	jmp    2de <ls+0x224>
  }

  if(fstat(fd, &st) < 0){
  fd:	83 ec 08             	sub    $0x8,%esp
 100:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 106:	50                   	push   %eax
 107:	ff 75 e4             	push   -0x1c(%ebp)
 10a:	e8 12 05 00 00       	call   621 <fstat>
 10f:	83 c4 10             	add    $0x10,%esp
 112:	85 c0                	test   %eax,%eax
 114:	79 28                	jns    13e <ls+0x84>
    printf(2, "ls: cannot stat %s\n", path);
 116:	83 ec 04             	sub    $0x4,%esp
 119:	ff 75 08             	push   0x8(%ebp)
 11c:	68 30 0b 00 00       	push   $0xb30
 121:	6a 02                	push   $0x2
 123:	e8 2d 06 00 00       	call   755 <printf>
 128:	83 c4 10             	add    $0x10,%esp
    close(fd);
 12b:	83 ec 0c             	sub    $0xc,%esp
 12e:	ff 75 e4             	push   -0x1c(%ebp)
 131:	e8 bb 04 00 00       	call   5f1 <close>
 136:	83 c4 10             	add    $0x10,%esp
    return;
 139:	e9 a0 01 00 00       	jmp    2de <ls+0x224>
  }

  switch(st.type){
 13e:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 145:	98                   	cwtl
 146:	83 f8 01             	cmp    $0x1,%eax
 149:	74 48                	je     193 <ls+0xd9>
 14b:	83 f8 02             	cmp    $0x2,%eax
 14e:	0f 85 7c 01 00 00    	jne    2d0 <ls+0x216>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 154:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 15a:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 160:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 167:	0f bf d8             	movswl %ax,%ebx
 16a:	83 ec 0c             	sub    $0xc,%esp
 16d:	ff 75 08             	push   0x8(%ebp)
 170:	e8 8b fe ff ff       	call   0 <fmtname>
 175:	83 c4 10             	add    $0x10,%esp
 178:	83 ec 08             	sub    $0x8,%esp
 17b:	57                   	push   %edi
 17c:	56                   	push   %esi
 17d:	53                   	push   %ebx
 17e:	50                   	push   %eax
 17f:	68 44 0b 00 00       	push   $0xb44
 184:	6a 01                	push   $0x1
 186:	e8 ca 05 00 00       	call   755 <printf>
 18b:	83 c4 20             	add    $0x20,%esp
    break;
 18e:	e9 3d 01 00 00       	jmp    2d0 <ls+0x216>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 193:	83 ec 0c             	sub    $0xc,%esp
 196:	ff 75 08             	push   0x8(%ebp)
 199:	e8 4d 02 00 00       	call   3eb <strlen>
 19e:	83 c4 10             	add    $0x10,%esp
 1a1:	83 c0 10             	add    $0x10,%eax
 1a4:	3d 00 02 00 00       	cmp    $0x200,%eax
 1a9:	76 17                	jbe    1c2 <ls+0x108>
      printf(1, "ls: path too long\n");
 1ab:	83 ec 08             	sub    $0x8,%esp
 1ae:	68 51 0b 00 00       	push   $0xb51
 1b3:	6a 01                	push   $0x1
 1b5:	e8 9b 05 00 00       	call   755 <printf>
 1ba:	83 c4 10             	add    $0x10,%esp
      break;
 1bd:	e9 0e 01 00 00       	jmp    2d0 <ls+0x216>
    }
    strcpy(buf, path);
 1c2:	83 ec 08             	sub    $0x8,%esp
 1c5:	ff 75 08             	push   0x8(%ebp)
 1c8:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1ce:	50                   	push   %eax
 1cf:	e8 a0 01 00 00       	call   374 <strcpy>
 1d4:	83 c4 10             	add    $0x10,%esp
    p = buf+strlen(buf);
 1d7:	83 ec 0c             	sub    $0xc,%esp
 1da:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1e0:	50                   	push   %eax
 1e1:	e8 05 02 00 00       	call   3eb <strlen>
 1e6:	83 c4 10             	add    $0x10,%esp
 1e9:	8d 95 e0 fd ff ff    	lea    -0x220(%ebp),%edx
 1ef:	01 d0                	add    %edx,%eax
 1f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
 1f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1f7:	8d 50 01             	lea    0x1(%eax),%edx
 1fa:	89 55 e0             	mov    %edx,-0x20(%ebp)
 1fd:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 200:	e9 aa 00 00 00       	jmp    2af <ls+0x1f5>
      if(de.inum == 0)
 205:	0f b7 85 d0 fd ff ff 	movzwl -0x230(%ebp),%eax
 20c:	66 85 c0             	test   %ax,%ax
 20f:	75 05                	jne    216 <ls+0x15c>
        continue;
 211:	e9 99 00 00 00       	jmp    2af <ls+0x1f5>
      memmove(p, de.name, DIRSIZ);
 216:	83 ec 04             	sub    $0x4,%esp
 219:	6a 0e                	push   $0xe
 21b:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 221:	83 c0 02             	add    $0x2,%eax
 224:	50                   	push   %eax
 225:	ff 75 e0             	push   -0x20(%ebp)
 228:	e8 53 03 00 00       	call   580 <memmove>
 22d:	83 c4 10             	add    $0x10,%esp
      p[DIRSIZ] = 0;
 230:	8b 45 e0             	mov    -0x20(%ebp),%eax
 233:	83 c0 0e             	add    $0xe,%eax
 236:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
 239:	83 ec 08             	sub    $0x8,%esp
 23c:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 242:	50                   	push   %eax
 243:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 249:	50                   	push   %eax
 24a:	e8 8f 02 00 00       	call   4de <stat>
 24f:	83 c4 10             	add    $0x10,%esp
 252:	85 c0                	test   %eax,%eax
 254:	79 1b                	jns    271 <ls+0x1b7>
        printf(1, "ls: cannot stat %s\n", buf);
 256:	83 ec 04             	sub    $0x4,%esp
 259:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 25f:	50                   	push   %eax
 260:	68 30 0b 00 00       	push   $0xb30
 265:	6a 01                	push   $0x1
 267:	e8 e9 04 00 00       	call   755 <printf>
 26c:	83 c4 10             	add    $0x10,%esp
        continue;
 26f:	eb 3e                	jmp    2af <ls+0x1f5>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 271:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 277:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 27d:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 284:	0f bf d8             	movswl %ax,%ebx
 287:	83 ec 0c             	sub    $0xc,%esp
 28a:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 290:	50                   	push   %eax
 291:	e8 6a fd ff ff       	call   0 <fmtname>
 296:	83 c4 10             	add    $0x10,%esp
 299:	83 ec 08             	sub    $0x8,%esp
 29c:	57                   	push   %edi
 29d:	56                   	push   %esi
 29e:	53                   	push   %ebx
 29f:	50                   	push   %eax
 2a0:	68 44 0b 00 00       	push   $0xb44
 2a5:	6a 01                	push   $0x1
 2a7:	e8 a9 04 00 00       	call   755 <printf>
 2ac:	83 c4 20             	add    $0x20,%esp
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 2af:	83 ec 04             	sub    $0x4,%esp
 2b2:	6a 10                	push   $0x10
 2b4:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 2ba:	50                   	push   %eax
 2bb:	ff 75 e4             	push   -0x1c(%ebp)
 2be:	e8 1e 03 00 00       	call   5e1 <read>
 2c3:	83 c4 10             	add    $0x10,%esp
 2c6:	83 f8 10             	cmp    $0x10,%eax
 2c9:	0f 84 36 ff ff ff    	je     205 <ls+0x14b>
    }
    break;
 2cf:	90                   	nop
  }
  close(fd);
 2d0:	83 ec 0c             	sub    $0xc,%esp
 2d3:	ff 75 e4             	push   -0x1c(%ebp)
 2d6:	e8 16 03 00 00       	call   5f1 <close>
 2db:	83 c4 10             	add    $0x10,%esp
}
 2de:	8d 65 f4             	lea    -0xc(%ebp),%esp
 2e1:	5b                   	pop    %ebx
 2e2:	5e                   	pop    %esi
 2e3:	5f                   	pop    %edi
 2e4:	5d                   	pop    %ebp
 2e5:	c3                   	ret

000002e6 <main>:

int
main(int argc, char *argv[])
{
 2e6:	f3 0f 1e fb          	endbr32
 2ea:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 2ee:	83 e4 f0             	and    $0xfffffff0,%esp
 2f1:	ff 71 fc             	push   -0x4(%ecx)
 2f4:	55                   	push   %ebp
 2f5:	89 e5                	mov    %esp,%ebp
 2f7:	53                   	push   %ebx
 2f8:	51                   	push   %ecx
 2f9:	83 ec 10             	sub    $0x10,%esp
 2fc:	89 cb                	mov    %ecx,%ebx
  int i;

  if(argc < 2){
 2fe:	83 3b 01             	cmpl   $0x1,(%ebx)
 301:	7f 15                	jg     318 <main+0x32>
    ls(".");
 303:	83 ec 0c             	sub    $0xc,%esp
 306:	68 64 0b 00 00       	push   $0xb64
 30b:	e8 aa fd ff ff       	call   ba <ls>
 310:	83 c4 10             	add    $0x10,%esp
    exit();
 313:	e8 b1 02 00 00       	call   5c9 <exit>
  }
  for(i=1; i<argc; i++)
 318:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
 31f:	eb 21                	jmp    342 <main+0x5c>
    ls(argv[i]);
 321:	8b 45 f4             	mov    -0xc(%ebp),%eax
 324:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 32b:	8b 43 04             	mov    0x4(%ebx),%eax
 32e:	01 d0                	add    %edx,%eax
 330:	8b 00                	mov    (%eax),%eax
 332:	83 ec 0c             	sub    $0xc,%esp
 335:	50                   	push   %eax
 336:	e8 7f fd ff ff       	call   ba <ls>
 33b:	83 c4 10             	add    $0x10,%esp
  for(i=1; i<argc; i++)
 33e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 342:	8b 45 f4             	mov    -0xc(%ebp),%eax
 345:	3b 03                	cmp    (%ebx),%eax
 347:	7c d8                	jl     321 <main+0x3b>
  exit();
 349:	e8 7b 02 00 00       	call   5c9 <exit>

0000034e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 34e:	55                   	push   %ebp
 34f:	89 e5                	mov    %esp,%ebp
 351:	57                   	push   %edi
 352:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 353:	8b 4d 08             	mov    0x8(%ebp),%ecx
 356:	8b 55 10             	mov    0x10(%ebp),%edx
 359:	8b 45 0c             	mov    0xc(%ebp),%eax
 35c:	89 cb                	mov    %ecx,%ebx
 35e:	89 df                	mov    %ebx,%edi
 360:	89 d1                	mov    %edx,%ecx
 362:	fc                   	cld
 363:	f3 aa                	rep stos %al,%es:(%edi)
 365:	89 ca                	mov    %ecx,%edx
 367:	89 fb                	mov    %edi,%ebx
 369:	89 5d 08             	mov    %ebx,0x8(%ebp)
 36c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 36f:	90                   	nop
 370:	5b                   	pop    %ebx
 371:	5f                   	pop    %edi
 372:	5d                   	pop    %ebp
 373:	c3                   	ret

00000374 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 374:	f3 0f 1e fb          	endbr32
 378:	55                   	push   %ebp
 379:	89 e5                	mov    %esp,%ebp
 37b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 37e:	8b 45 08             	mov    0x8(%ebp),%eax
 381:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 384:	90                   	nop
 385:	8b 55 0c             	mov    0xc(%ebp),%edx
 388:	8d 42 01             	lea    0x1(%edx),%eax
 38b:	89 45 0c             	mov    %eax,0xc(%ebp)
 38e:	8b 45 08             	mov    0x8(%ebp),%eax
 391:	8d 48 01             	lea    0x1(%eax),%ecx
 394:	89 4d 08             	mov    %ecx,0x8(%ebp)
 397:	0f b6 12             	movzbl (%edx),%edx
 39a:	88 10                	mov    %dl,(%eax)
 39c:	0f b6 00             	movzbl (%eax),%eax
 39f:	84 c0                	test   %al,%al
 3a1:	75 e2                	jne    385 <strcpy+0x11>
    ;
  return os;
 3a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3a6:	c9                   	leave
 3a7:	c3                   	ret

000003a8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3a8:	f3 0f 1e fb          	endbr32
 3ac:	55                   	push   %ebp
 3ad:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3af:	eb 08                	jmp    3b9 <strcmp+0x11>
    p++, q++;
 3b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 3b9:	8b 45 08             	mov    0x8(%ebp),%eax
 3bc:	0f b6 00             	movzbl (%eax),%eax
 3bf:	84 c0                	test   %al,%al
 3c1:	74 10                	je     3d3 <strcmp+0x2b>
 3c3:	8b 45 08             	mov    0x8(%ebp),%eax
 3c6:	0f b6 10             	movzbl (%eax),%edx
 3c9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cc:	0f b6 00             	movzbl (%eax),%eax
 3cf:	38 c2                	cmp    %al,%dl
 3d1:	74 de                	je     3b1 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	0f b6 00             	movzbl (%eax),%eax
 3d9:	0f b6 d0             	movzbl %al,%edx
 3dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3df:	0f b6 00             	movzbl (%eax),%eax
 3e2:	0f b6 c0             	movzbl %al,%eax
 3e5:	29 c2                	sub    %eax,%edx
 3e7:	89 d0                	mov    %edx,%eax
}
 3e9:	5d                   	pop    %ebp
 3ea:	c3                   	ret

000003eb <strlen>:

uint
strlen(char *s)
{
 3eb:	f3 0f 1e fb          	endbr32
 3ef:	55                   	push   %ebp
 3f0:	89 e5                	mov    %esp,%ebp
 3f2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3f5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3fc:	eb 04                	jmp    402 <strlen+0x17>
 3fe:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 402:	8b 55 fc             	mov    -0x4(%ebp),%edx
 405:	8b 45 08             	mov    0x8(%ebp),%eax
 408:	01 d0                	add    %edx,%eax
 40a:	0f b6 00             	movzbl (%eax),%eax
 40d:	84 c0                	test   %al,%al
 40f:	75 ed                	jne    3fe <strlen+0x13>
    ;
  return n;
 411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 414:	c9                   	leave
 415:	c3                   	ret

00000416 <memset>:

void*
memset(void *dst, int c, uint n)
{
 416:	f3 0f 1e fb          	endbr32
 41a:	55                   	push   %ebp
 41b:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 41d:	8b 45 10             	mov    0x10(%ebp),%eax
 420:	50                   	push   %eax
 421:	ff 75 0c             	push   0xc(%ebp)
 424:	ff 75 08             	push   0x8(%ebp)
 427:	e8 22 ff ff ff       	call   34e <stosb>
 42c:	83 c4 0c             	add    $0xc,%esp
  return dst;
 42f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 432:	c9                   	leave
 433:	c3                   	ret

00000434 <strchr>:

char*
strchr(const char *s, char c)
{
 434:	f3 0f 1e fb          	endbr32
 438:	55                   	push   %ebp
 439:	89 e5                	mov    %esp,%ebp
 43b:	83 ec 04             	sub    $0x4,%esp
 43e:	8b 45 0c             	mov    0xc(%ebp),%eax
 441:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 444:	eb 14                	jmp    45a <strchr+0x26>
    if(*s == c)
 446:	8b 45 08             	mov    0x8(%ebp),%eax
 449:	0f b6 00             	movzbl (%eax),%eax
 44c:	38 45 fc             	cmp    %al,-0x4(%ebp)
 44f:	75 05                	jne    456 <strchr+0x22>
      return (char*)s;
 451:	8b 45 08             	mov    0x8(%ebp),%eax
 454:	eb 13                	jmp    469 <strchr+0x35>
  for(; *s; s++)
 456:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 45a:	8b 45 08             	mov    0x8(%ebp),%eax
 45d:	0f b6 00             	movzbl (%eax),%eax
 460:	84 c0                	test   %al,%al
 462:	75 e2                	jne    446 <strchr+0x12>
  return 0;
 464:	b8 00 00 00 00       	mov    $0x0,%eax
}
 469:	c9                   	leave
 46a:	c3                   	ret

0000046b <gets>:

char*
gets(char *buf, int max)
{
 46b:	f3 0f 1e fb          	endbr32
 46f:	55                   	push   %ebp
 470:	89 e5                	mov    %esp,%ebp
 472:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 475:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 47c:	eb 42                	jmp    4c0 <gets+0x55>
    cc = read(0, &c, 1);
 47e:	83 ec 04             	sub    $0x4,%esp
 481:	6a 01                	push   $0x1
 483:	8d 45 ef             	lea    -0x11(%ebp),%eax
 486:	50                   	push   %eax
 487:	6a 00                	push   $0x0
 489:	e8 53 01 00 00       	call   5e1 <read>
 48e:	83 c4 10             	add    $0x10,%esp
 491:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 494:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 498:	7e 33                	jle    4cd <gets+0x62>
      break;
    buf[i++] = c;
 49a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49d:	8d 50 01             	lea    0x1(%eax),%edx
 4a0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4a3:	89 c2                	mov    %eax,%edx
 4a5:	8b 45 08             	mov    0x8(%ebp),%eax
 4a8:	01 c2                	add    %eax,%edx
 4aa:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4ae:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4b0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4b4:	3c 0a                	cmp    $0xa,%al
 4b6:	74 16                	je     4ce <gets+0x63>
 4b8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4bc:	3c 0d                	cmp    $0xd,%al
 4be:	74 0e                	je     4ce <gets+0x63>
  for(i=0; i+1 < max; ){
 4c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c3:	83 c0 01             	add    $0x1,%eax
 4c6:	39 45 0c             	cmp    %eax,0xc(%ebp)
 4c9:	7f b3                	jg     47e <gets+0x13>
 4cb:	eb 01                	jmp    4ce <gets+0x63>
      break;
 4cd:	90                   	nop
      break;
  }
  buf[i] = '\0';
 4ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4d1:	8b 45 08             	mov    0x8(%ebp),%eax
 4d4:	01 d0                	add    %edx,%eax
 4d6:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4d9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4dc:	c9                   	leave
 4dd:	c3                   	ret

000004de <stat>:

int
stat(char *n, struct stat *st)
{
 4de:	f3 0f 1e fb          	endbr32
 4e2:	55                   	push   %ebp
 4e3:	89 e5                	mov    %esp,%ebp
 4e5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4e8:	83 ec 08             	sub    $0x8,%esp
 4eb:	6a 00                	push   $0x0
 4ed:	ff 75 08             	push   0x8(%ebp)
 4f0:	e8 14 01 00 00       	call   609 <open>
 4f5:	83 c4 10             	add    $0x10,%esp
 4f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4ff:	79 07                	jns    508 <stat+0x2a>
    return -1;
 501:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 506:	eb 25                	jmp    52d <stat+0x4f>
  r = fstat(fd, st);
 508:	83 ec 08             	sub    $0x8,%esp
 50b:	ff 75 0c             	push   0xc(%ebp)
 50e:	ff 75 f4             	push   -0xc(%ebp)
 511:	e8 0b 01 00 00       	call   621 <fstat>
 516:	83 c4 10             	add    $0x10,%esp
 519:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 51c:	83 ec 0c             	sub    $0xc,%esp
 51f:	ff 75 f4             	push   -0xc(%ebp)
 522:	e8 ca 00 00 00       	call   5f1 <close>
 527:	83 c4 10             	add    $0x10,%esp
  return r;
 52a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 52d:	c9                   	leave
 52e:	c3                   	ret

0000052f <atoi>:

int
atoi(const char *s)
{
 52f:	f3 0f 1e fb          	endbr32
 533:	55                   	push   %ebp
 534:	89 e5                	mov    %esp,%ebp
 536:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 539:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 540:	eb 25                	jmp    567 <atoi+0x38>
    n = n*10 + *s++ - '0';
 542:	8b 55 fc             	mov    -0x4(%ebp),%edx
 545:	89 d0                	mov    %edx,%eax
 547:	c1 e0 02             	shl    $0x2,%eax
 54a:	01 d0                	add    %edx,%eax
 54c:	01 c0                	add    %eax,%eax
 54e:	89 c1                	mov    %eax,%ecx
 550:	8b 45 08             	mov    0x8(%ebp),%eax
 553:	8d 50 01             	lea    0x1(%eax),%edx
 556:	89 55 08             	mov    %edx,0x8(%ebp)
 559:	0f b6 00             	movzbl (%eax),%eax
 55c:	0f be c0             	movsbl %al,%eax
 55f:	01 c8                	add    %ecx,%eax
 561:	83 e8 30             	sub    $0x30,%eax
 564:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 567:	8b 45 08             	mov    0x8(%ebp),%eax
 56a:	0f b6 00             	movzbl (%eax),%eax
 56d:	3c 2f                	cmp    $0x2f,%al
 56f:	7e 0a                	jle    57b <atoi+0x4c>
 571:	8b 45 08             	mov    0x8(%ebp),%eax
 574:	0f b6 00             	movzbl (%eax),%eax
 577:	3c 39                	cmp    $0x39,%al
 579:	7e c7                	jle    542 <atoi+0x13>
  return n;
 57b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 57e:	c9                   	leave
 57f:	c3                   	ret

00000580 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 580:	f3 0f 1e fb          	endbr32
 584:	55                   	push   %ebp
 585:	89 e5                	mov    %esp,%ebp
 587:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 58a:	8b 45 08             	mov    0x8(%ebp),%eax
 58d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 590:	8b 45 0c             	mov    0xc(%ebp),%eax
 593:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 596:	eb 17                	jmp    5af <memmove+0x2f>
    *dst++ = *src++;
 598:	8b 55 f8             	mov    -0x8(%ebp),%edx
 59b:	8d 42 01             	lea    0x1(%edx),%eax
 59e:	89 45 f8             	mov    %eax,-0x8(%ebp)
 5a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5a4:	8d 48 01             	lea    0x1(%eax),%ecx
 5a7:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 5aa:	0f b6 12             	movzbl (%edx),%edx
 5ad:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 5af:	8b 45 10             	mov    0x10(%ebp),%eax
 5b2:	8d 50 ff             	lea    -0x1(%eax),%edx
 5b5:	89 55 10             	mov    %edx,0x10(%ebp)
 5b8:	85 c0                	test   %eax,%eax
 5ba:	7f dc                	jg     598 <memmove+0x18>
  return vdst;
 5bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5bf:	c9                   	leave
 5c0:	c3                   	ret

000005c1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5c1:	b8 01 00 00 00       	mov    $0x1,%eax
 5c6:	cd 40                	int    $0x40
 5c8:	c3                   	ret

000005c9 <exit>:
SYSCALL(exit)
 5c9:	b8 02 00 00 00       	mov    $0x2,%eax
 5ce:	cd 40                	int    $0x40
 5d0:	c3                   	ret

000005d1 <wait>:
SYSCALL(wait)
 5d1:	b8 03 00 00 00       	mov    $0x3,%eax
 5d6:	cd 40                	int    $0x40
 5d8:	c3                   	ret

000005d9 <pipe>:
SYSCALL(pipe)
 5d9:	b8 04 00 00 00       	mov    $0x4,%eax
 5de:	cd 40                	int    $0x40
 5e0:	c3                   	ret

000005e1 <read>:
SYSCALL(read)
 5e1:	b8 05 00 00 00       	mov    $0x5,%eax
 5e6:	cd 40                	int    $0x40
 5e8:	c3                   	ret

000005e9 <write>:
SYSCALL(write)
 5e9:	b8 10 00 00 00       	mov    $0x10,%eax
 5ee:	cd 40                	int    $0x40
 5f0:	c3                   	ret

000005f1 <close>:
SYSCALL(close)
 5f1:	b8 15 00 00 00       	mov    $0x15,%eax
 5f6:	cd 40                	int    $0x40
 5f8:	c3                   	ret

000005f9 <kill>:
SYSCALL(kill)
 5f9:	b8 06 00 00 00       	mov    $0x6,%eax
 5fe:	cd 40                	int    $0x40
 600:	c3                   	ret

00000601 <exec>:
SYSCALL(exec)
 601:	b8 07 00 00 00       	mov    $0x7,%eax
 606:	cd 40                	int    $0x40
 608:	c3                   	ret

00000609 <open>:
SYSCALL(open)
 609:	b8 0f 00 00 00       	mov    $0xf,%eax
 60e:	cd 40                	int    $0x40
 610:	c3                   	ret

00000611 <mknod>:
SYSCALL(mknod)
 611:	b8 11 00 00 00       	mov    $0x11,%eax
 616:	cd 40                	int    $0x40
 618:	c3                   	ret

00000619 <unlink>:
SYSCALL(unlink)
 619:	b8 12 00 00 00       	mov    $0x12,%eax
 61e:	cd 40                	int    $0x40
 620:	c3                   	ret

00000621 <fstat>:
SYSCALL(fstat)
 621:	b8 08 00 00 00       	mov    $0x8,%eax
 626:	cd 40                	int    $0x40
 628:	c3                   	ret

00000629 <link>:
SYSCALL(link)
 629:	b8 13 00 00 00       	mov    $0x13,%eax
 62e:	cd 40                	int    $0x40
 630:	c3                   	ret

00000631 <mkdir>:
SYSCALL(mkdir)
 631:	b8 14 00 00 00       	mov    $0x14,%eax
 636:	cd 40                	int    $0x40
 638:	c3                   	ret

00000639 <chdir>:
SYSCALL(chdir)
 639:	b8 09 00 00 00       	mov    $0x9,%eax
 63e:	cd 40                	int    $0x40
 640:	c3                   	ret

00000641 <dup>:
SYSCALL(dup)
 641:	b8 0a 00 00 00       	mov    $0xa,%eax
 646:	cd 40                	int    $0x40
 648:	c3                   	ret

00000649 <getpid>:
SYSCALL(getpid)
 649:	b8 0b 00 00 00       	mov    $0xb,%eax
 64e:	cd 40                	int    $0x40
 650:	c3                   	ret

00000651 <sbrk>:
SYSCALL(sbrk)
 651:	b8 0c 00 00 00       	mov    $0xc,%eax
 656:	cd 40                	int    $0x40
 658:	c3                   	ret

00000659 <sleep>:
SYSCALL(sleep)
 659:	b8 0d 00 00 00       	mov    $0xd,%eax
 65e:	cd 40                	int    $0x40
 660:	c3                   	ret

00000661 <uptime>:
SYSCALL(uptime)
 661:	b8 0e 00 00 00       	mov    $0xe,%eax
 666:	cd 40                	int    $0x40
 668:	c3                   	ret

00000669 <uthread_init>:

SYSCALL(uthread_init)
 669:	b8 16 00 00 00       	mov    $0x16,%eax
 66e:	cd 40                	int    $0x40
 670:	c3                   	ret

00000671 <printpt>:
 671:	b8 17 00 00 00       	mov    $0x17,%eax
 676:	cd 40                	int    $0x40
 678:	c3                   	ret

00000679 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 679:	f3 0f 1e fb          	endbr32
 67d:	55                   	push   %ebp
 67e:	89 e5                	mov    %esp,%ebp
 680:	83 ec 18             	sub    $0x18,%esp
 683:	8b 45 0c             	mov    0xc(%ebp),%eax
 686:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 689:	83 ec 04             	sub    $0x4,%esp
 68c:	6a 01                	push   $0x1
 68e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 691:	50                   	push   %eax
 692:	ff 75 08             	push   0x8(%ebp)
 695:	e8 4f ff ff ff       	call   5e9 <write>
 69a:	83 c4 10             	add    $0x10,%esp
}
 69d:	90                   	nop
 69e:	c9                   	leave
 69f:	c3                   	ret

000006a0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6a0:	f3 0f 1e fb          	endbr32
 6a4:	55                   	push   %ebp
 6a5:	89 e5                	mov    %esp,%ebp
 6a7:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6b1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6b5:	74 17                	je     6ce <printint+0x2e>
 6b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6bb:	79 11                	jns    6ce <printint+0x2e>
    neg = 1;
 6bd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6c4:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c7:	f7 d8                	neg    %eax
 6c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6cc:	eb 06                	jmp    6d4 <printint+0x34>
  } else {
    x = xx;
 6ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 6d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6db:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6de:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6e1:	ba 00 00 00 00       	mov    $0x0,%edx
 6e6:	f7 f1                	div    %ecx
 6e8:	89 d1                	mov    %edx,%ecx
 6ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ed:	8d 50 01             	lea    0x1(%eax),%edx
 6f0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6f3:	0f b6 91 0c 0e 00 00 	movzbl 0xe0c(%ecx),%edx
 6fa:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 6fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
 701:	8b 45 ec             	mov    -0x14(%ebp),%eax
 704:	ba 00 00 00 00       	mov    $0x0,%edx
 709:	f7 f1                	div    %ecx
 70b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 70e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 712:	75 c7                	jne    6db <printint+0x3b>
  if(neg)
 714:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 718:	74 2d                	je     747 <printint+0xa7>
    buf[i++] = '-';
 71a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71d:	8d 50 01             	lea    0x1(%eax),%edx
 720:	89 55 f4             	mov    %edx,-0xc(%ebp)
 723:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 728:	eb 1d                	jmp    747 <printint+0xa7>
    putc(fd, buf[i]);
 72a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 72d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 730:	01 d0                	add    %edx,%eax
 732:	0f b6 00             	movzbl (%eax),%eax
 735:	0f be c0             	movsbl %al,%eax
 738:	83 ec 08             	sub    $0x8,%esp
 73b:	50                   	push   %eax
 73c:	ff 75 08             	push   0x8(%ebp)
 73f:	e8 35 ff ff ff       	call   679 <putc>
 744:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 747:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 74b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 74f:	79 d9                	jns    72a <printint+0x8a>
}
 751:	90                   	nop
 752:	90                   	nop
 753:	c9                   	leave
 754:	c3                   	ret

00000755 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 755:	f3 0f 1e fb          	endbr32
 759:	55                   	push   %ebp
 75a:	89 e5                	mov    %esp,%ebp
 75c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 75f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 766:	8d 45 0c             	lea    0xc(%ebp),%eax
 769:	83 c0 04             	add    $0x4,%eax
 76c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 76f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 776:	e9 59 01 00 00       	jmp    8d4 <printf+0x17f>
    c = fmt[i] & 0xff;
 77b:	8b 55 0c             	mov    0xc(%ebp),%edx
 77e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 781:	01 d0                	add    %edx,%eax
 783:	0f b6 00             	movzbl (%eax),%eax
 786:	0f be c0             	movsbl %al,%eax
 789:	25 ff 00 00 00       	and    $0xff,%eax
 78e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 791:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 795:	75 2c                	jne    7c3 <printf+0x6e>
      if(c == '%'){
 797:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 79b:	75 0c                	jne    7a9 <printf+0x54>
        state = '%';
 79d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7a4:	e9 27 01 00 00       	jmp    8d0 <printf+0x17b>
      } else {
        putc(fd, c);
 7a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7ac:	0f be c0             	movsbl %al,%eax
 7af:	83 ec 08             	sub    $0x8,%esp
 7b2:	50                   	push   %eax
 7b3:	ff 75 08             	push   0x8(%ebp)
 7b6:	e8 be fe ff ff       	call   679 <putc>
 7bb:	83 c4 10             	add    $0x10,%esp
 7be:	e9 0d 01 00 00       	jmp    8d0 <printf+0x17b>
      }
    } else if(state == '%'){
 7c3:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7c7:	0f 85 03 01 00 00    	jne    8d0 <printf+0x17b>
      if(c == 'd'){
 7cd:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7d1:	75 1e                	jne    7f1 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 7d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d6:	8b 00                	mov    (%eax),%eax
 7d8:	6a 01                	push   $0x1
 7da:	6a 0a                	push   $0xa
 7dc:	50                   	push   %eax
 7dd:	ff 75 08             	push   0x8(%ebp)
 7e0:	e8 bb fe ff ff       	call   6a0 <printint>
 7e5:	83 c4 10             	add    $0x10,%esp
        ap++;
 7e8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ec:	e9 d8 00 00 00       	jmp    8c9 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 7f1:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7f5:	74 06                	je     7fd <printf+0xa8>
 7f7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7fb:	75 1e                	jne    81b <printf+0xc6>
        printint(fd, *ap, 16, 0);
 7fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 800:	8b 00                	mov    (%eax),%eax
 802:	6a 00                	push   $0x0
 804:	6a 10                	push   $0x10
 806:	50                   	push   %eax
 807:	ff 75 08             	push   0x8(%ebp)
 80a:	e8 91 fe ff ff       	call   6a0 <printint>
 80f:	83 c4 10             	add    $0x10,%esp
        ap++;
 812:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 816:	e9 ae 00 00 00       	jmp    8c9 <printf+0x174>
      } else if(c == 's'){
 81b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 81f:	75 43                	jne    864 <printf+0x10f>
        s = (char*)*ap;
 821:	8b 45 e8             	mov    -0x18(%ebp),%eax
 824:	8b 00                	mov    (%eax),%eax
 826:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 829:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 82d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 831:	75 25                	jne    858 <printf+0x103>
          s = "(null)";
 833:	c7 45 f4 66 0b 00 00 	movl   $0xb66,-0xc(%ebp)
        while(*s != 0){
 83a:	eb 1c                	jmp    858 <printf+0x103>
          putc(fd, *s);
 83c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83f:	0f b6 00             	movzbl (%eax),%eax
 842:	0f be c0             	movsbl %al,%eax
 845:	83 ec 08             	sub    $0x8,%esp
 848:	50                   	push   %eax
 849:	ff 75 08             	push   0x8(%ebp)
 84c:	e8 28 fe ff ff       	call   679 <putc>
 851:	83 c4 10             	add    $0x10,%esp
          s++;
 854:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 858:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85b:	0f b6 00             	movzbl (%eax),%eax
 85e:	84 c0                	test   %al,%al
 860:	75 da                	jne    83c <printf+0xe7>
 862:	eb 65                	jmp    8c9 <printf+0x174>
        }
      } else if(c == 'c'){
 864:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 868:	75 1d                	jne    887 <printf+0x132>
        putc(fd, *ap);
 86a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 86d:	8b 00                	mov    (%eax),%eax
 86f:	0f be c0             	movsbl %al,%eax
 872:	83 ec 08             	sub    $0x8,%esp
 875:	50                   	push   %eax
 876:	ff 75 08             	push   0x8(%ebp)
 879:	e8 fb fd ff ff       	call   679 <putc>
 87e:	83 c4 10             	add    $0x10,%esp
        ap++;
 881:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 885:	eb 42                	jmp    8c9 <printf+0x174>
      } else if(c == '%'){
 887:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 88b:	75 17                	jne    8a4 <printf+0x14f>
        putc(fd, c);
 88d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 890:	0f be c0             	movsbl %al,%eax
 893:	83 ec 08             	sub    $0x8,%esp
 896:	50                   	push   %eax
 897:	ff 75 08             	push   0x8(%ebp)
 89a:	e8 da fd ff ff       	call   679 <putc>
 89f:	83 c4 10             	add    $0x10,%esp
 8a2:	eb 25                	jmp    8c9 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8a4:	83 ec 08             	sub    $0x8,%esp
 8a7:	6a 25                	push   $0x25
 8a9:	ff 75 08             	push   0x8(%ebp)
 8ac:	e8 c8 fd ff ff       	call   679 <putc>
 8b1:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8b7:	0f be c0             	movsbl %al,%eax
 8ba:	83 ec 08             	sub    $0x8,%esp
 8bd:	50                   	push   %eax
 8be:	ff 75 08             	push   0x8(%ebp)
 8c1:	e8 b3 fd ff ff       	call   679 <putc>
 8c6:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8c9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 8d0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8d4:	8b 55 0c             	mov    0xc(%ebp),%edx
 8d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8da:	01 d0                	add    %edx,%eax
 8dc:	0f b6 00             	movzbl (%eax),%eax
 8df:	84 c0                	test   %al,%al
 8e1:	0f 85 94 fe ff ff    	jne    77b <printf+0x26>
    }
  }
}
 8e7:	90                   	nop
 8e8:	90                   	nop
 8e9:	c9                   	leave
 8ea:	c3                   	ret

000008eb <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8eb:	f3 0f 1e fb          	endbr32
 8ef:	55                   	push   %ebp
 8f0:	89 e5                	mov    %esp,%ebp
 8f2:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8f5:	8b 45 08             	mov    0x8(%ebp),%eax
 8f8:	83 e8 08             	sub    $0x8,%eax
 8fb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8fe:	a1 38 0e 00 00       	mov    0xe38,%eax
 903:	89 45 fc             	mov    %eax,-0x4(%ebp)
 906:	eb 24                	jmp    92c <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 908:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90b:	8b 00                	mov    (%eax),%eax
 90d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 910:	72 12                	jb     924 <free+0x39>
 912:	8b 45 f8             	mov    -0x8(%ebp),%eax
 915:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 918:	77 24                	ja     93e <free+0x53>
 91a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91d:	8b 00                	mov    (%eax),%eax
 91f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 922:	72 1a                	jb     93e <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 924:	8b 45 fc             	mov    -0x4(%ebp),%eax
 927:	8b 00                	mov    (%eax),%eax
 929:	89 45 fc             	mov    %eax,-0x4(%ebp)
 92c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 932:	76 d4                	jbe    908 <free+0x1d>
 934:	8b 45 fc             	mov    -0x4(%ebp),%eax
 937:	8b 00                	mov    (%eax),%eax
 939:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 93c:	73 ca                	jae    908 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 93e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 941:	8b 40 04             	mov    0x4(%eax),%eax
 944:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 94b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94e:	01 c2                	add    %eax,%edx
 950:	8b 45 fc             	mov    -0x4(%ebp),%eax
 953:	8b 00                	mov    (%eax),%eax
 955:	39 c2                	cmp    %eax,%edx
 957:	75 24                	jne    97d <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 959:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95c:	8b 50 04             	mov    0x4(%eax),%edx
 95f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 962:	8b 00                	mov    (%eax),%eax
 964:	8b 40 04             	mov    0x4(%eax),%eax
 967:	01 c2                	add    %eax,%edx
 969:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 96f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 972:	8b 00                	mov    (%eax),%eax
 974:	8b 10                	mov    (%eax),%edx
 976:	8b 45 f8             	mov    -0x8(%ebp),%eax
 979:	89 10                	mov    %edx,(%eax)
 97b:	eb 0a                	jmp    987 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 97d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 980:	8b 10                	mov    (%eax),%edx
 982:	8b 45 f8             	mov    -0x8(%ebp),%eax
 985:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 987:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98a:	8b 40 04             	mov    0x4(%eax),%eax
 98d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 994:	8b 45 fc             	mov    -0x4(%ebp),%eax
 997:	01 d0                	add    %edx,%eax
 999:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 99c:	75 20                	jne    9be <free+0xd3>
    p->s.size += bp->s.size;
 99e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a1:	8b 50 04             	mov    0x4(%eax),%edx
 9a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a7:	8b 40 04             	mov    0x4(%eax),%eax
 9aa:	01 c2                	add    %eax,%edx
 9ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9af:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b5:	8b 10                	mov    (%eax),%edx
 9b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ba:	89 10                	mov    %edx,(%eax)
 9bc:	eb 08                	jmp    9c6 <free+0xdb>
  } else
    p->s.ptr = bp;
 9be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c1:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9c4:	89 10                	mov    %edx,(%eax)
  freep = p;
 9c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c9:	a3 38 0e 00 00       	mov    %eax,0xe38
}
 9ce:	90                   	nop
 9cf:	c9                   	leave
 9d0:	c3                   	ret

000009d1 <morecore>:

static Header*
morecore(uint nu)
{
 9d1:	f3 0f 1e fb          	endbr32
 9d5:	55                   	push   %ebp
 9d6:	89 e5                	mov    %esp,%ebp
 9d8:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9db:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9e2:	77 07                	ja     9eb <morecore+0x1a>
    nu = 4096;
 9e4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9eb:	8b 45 08             	mov    0x8(%ebp),%eax
 9ee:	c1 e0 03             	shl    $0x3,%eax
 9f1:	83 ec 0c             	sub    $0xc,%esp
 9f4:	50                   	push   %eax
 9f5:	e8 57 fc ff ff       	call   651 <sbrk>
 9fa:	83 c4 10             	add    $0x10,%esp
 9fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a00:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a04:	75 07                	jne    a0d <morecore+0x3c>
    return 0;
 a06:	b8 00 00 00 00       	mov    $0x0,%eax
 a0b:	eb 26                	jmp    a33 <morecore+0x62>
  hp = (Header*)p;
 a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a10:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a13:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a16:	8b 55 08             	mov    0x8(%ebp),%edx
 a19:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a1f:	83 c0 08             	add    $0x8,%eax
 a22:	83 ec 0c             	sub    $0xc,%esp
 a25:	50                   	push   %eax
 a26:	e8 c0 fe ff ff       	call   8eb <free>
 a2b:	83 c4 10             	add    $0x10,%esp
  return freep;
 a2e:	a1 38 0e 00 00       	mov    0xe38,%eax
}
 a33:	c9                   	leave
 a34:	c3                   	ret

00000a35 <malloc>:

void*
malloc(uint nbytes)
{
 a35:	f3 0f 1e fb          	endbr32
 a39:	55                   	push   %ebp
 a3a:	89 e5                	mov    %esp,%ebp
 a3c:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a3f:	8b 45 08             	mov    0x8(%ebp),%eax
 a42:	83 c0 07             	add    $0x7,%eax
 a45:	c1 e8 03             	shr    $0x3,%eax
 a48:	83 c0 01             	add    $0x1,%eax
 a4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a4e:	a1 38 0e 00 00       	mov    0xe38,%eax
 a53:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a56:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a5a:	75 23                	jne    a7f <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 a5c:	c7 45 f0 30 0e 00 00 	movl   $0xe30,-0x10(%ebp)
 a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a66:	a3 38 0e 00 00       	mov    %eax,0xe38
 a6b:	a1 38 0e 00 00       	mov    0xe38,%eax
 a70:	a3 30 0e 00 00       	mov    %eax,0xe30
    base.s.size = 0;
 a75:	c7 05 34 0e 00 00 00 	movl   $0x0,0xe34
 a7c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a82:	8b 00                	mov    (%eax),%eax
 a84:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8a:	8b 40 04             	mov    0x4(%eax),%eax
 a8d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a90:	77 4d                	ja     adf <malloc+0xaa>
      if(p->s.size == nunits)
 a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a95:	8b 40 04             	mov    0x4(%eax),%eax
 a98:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 a9b:	75 0c                	jne    aa9 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa0:	8b 10                	mov    (%eax),%edx
 aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa5:	89 10                	mov    %edx,(%eax)
 aa7:	eb 26                	jmp    acf <malloc+0x9a>
      else {
        p->s.size -= nunits;
 aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aac:	8b 40 04             	mov    0x4(%eax),%eax
 aaf:	2b 45 ec             	sub    -0x14(%ebp),%eax
 ab2:	89 c2                	mov    %eax,%edx
 ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abd:	8b 40 04             	mov    0x4(%eax),%eax
 ac0:	c1 e0 03             	shl    $0x3,%eax
 ac3:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac9:	8b 55 ec             	mov    -0x14(%ebp),%edx
 acc:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 acf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ad2:	a3 38 0e 00 00       	mov    %eax,0xe38
      return (void*)(p + 1);
 ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ada:	83 c0 08             	add    $0x8,%eax
 add:	eb 3b                	jmp    b1a <malloc+0xe5>
    }
    if(p == freep)
 adf:	a1 38 0e 00 00       	mov    0xe38,%eax
 ae4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ae7:	75 1e                	jne    b07 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 ae9:	83 ec 0c             	sub    $0xc,%esp
 aec:	ff 75 ec             	push   -0x14(%ebp)
 aef:	e8 dd fe ff ff       	call   9d1 <morecore>
 af4:	83 c4 10             	add    $0x10,%esp
 af7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 afa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 afe:	75 07                	jne    b07 <malloc+0xd2>
        return 0;
 b00:	b8 00 00 00 00       	mov    $0x0,%eax
 b05:	eb 13                	jmp    b1a <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b10:	8b 00                	mov    (%eax),%eax
 b12:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b15:	e9 6d ff ff ff       	jmp    a87 <malloc+0x52>
  }
}
 b1a:	c9                   	leave
 b1b:	c3                   	ret
