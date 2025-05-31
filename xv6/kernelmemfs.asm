
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc 60 e3 18 80       	mov    $0x8018e360,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba be 34 10 80       	mov    $0x801034be,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	f3 0f 1e fb          	endbr32
8010006a:	55                   	push   %ebp
8010006b:	89 e5                	mov    %esp,%ebp
8010006d:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
80100070:	83 ec 08             	sub    $0x8,%esp
80100073:	68 c0 a5 10 80       	push   $0x8010a5c0
80100078:	68 60 e3 18 80       	push   $0x8018e360
8010007d:	e8 95 49 00 00       	call   80104a17 <initlock>
80100082:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100085:	c7 05 ac 2a 19 80 5c 	movl   $0x80192a5c,0x80192aac
8010008c:	2a 19 80 
  bcache.head.next = &bcache.head;
8010008f:	c7 05 b0 2a 19 80 5c 	movl   $0x80192a5c,0x80192ab0
80100096:	2a 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100099:	c7 45 f4 94 e3 18 80 	movl   $0x8018e394,-0xc(%ebp)
801000a0:	eb 47                	jmp    801000e9 <binit+0x83>
    b->next = bcache.head.next;
801000a2:	8b 15 b0 2a 19 80    	mov    0x80192ab0,%edx
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b1:	c7 40 50 5c 2a 19 80 	movl   $0x80192a5c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000bb:	83 c0 0c             	add    $0xc,%eax
801000be:	83 ec 08             	sub    $0x8,%esp
801000c1:	68 c7 a5 10 80       	push   $0x8010a5c7
801000c6:	50                   	push   %eax
801000c7:	e8 de 47 00 00       	call   801048aa <initsleeplock>
801000cc:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cf:	a1 b0 2a 19 80       	mov    0x80192ab0,%eax
801000d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d7:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000dd:	a3 b0 2a 19 80       	mov    %eax,0x80192ab0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000e2:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e9:	b8 5c 2a 19 80       	mov    $0x80192a5c,%eax
801000ee:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000f1:	72 af                	jb     801000a2 <binit+0x3c>
  }
}
801000f3:	90                   	nop
801000f4:	90                   	nop
801000f5:	c9                   	leave
801000f6:	c3                   	ret

801000f7 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f7:	f3 0f 1e fb          	endbr32
801000fb:	55                   	push   %ebp
801000fc:	89 e5                	mov    %esp,%ebp
801000fe:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
80100101:	83 ec 0c             	sub    $0xc,%esp
80100104:	68 60 e3 18 80       	push   $0x8018e360
80100109:	e8 2f 49 00 00       	call   80104a3d <acquire>
8010010e:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100111:	a1 b0 2a 19 80       	mov    0x80192ab0,%eax
80100116:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100119:	eb 58                	jmp    80100173 <bget+0x7c>
    if(b->dev == dev && b->blockno == blockno){
8010011b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011e:	8b 40 04             	mov    0x4(%eax),%eax
80100121:	39 45 08             	cmp    %eax,0x8(%ebp)
80100124:	75 44                	jne    8010016a <bget+0x73>
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 08             	mov    0x8(%eax),%eax
8010012c:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010012f:	75 39                	jne    8010016a <bget+0x73>
      b->refcnt++;
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 4c             	mov    0x4c(%eax),%eax
80100137:	8d 50 01             	lea    0x1(%eax),%edx
8010013a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013d:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100140:	83 ec 0c             	sub    $0xc,%esp
80100143:	68 60 e3 18 80       	push   $0x8018e360
80100148:	e8 62 49 00 00       	call   80104aaf <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 8b 47 00 00       	call   801048ea <acquiresleep>
8010015f:	83 c4 10             	add    $0x10,%esp
      return b;
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	e9 9d 00 00 00       	jmp    80100207 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 40 54             	mov    0x54(%eax),%eax
80100170:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100173:	81 7d f4 5c 2a 19 80 	cmpl   $0x80192a5c,-0xc(%ebp)
8010017a:	75 9f                	jne    8010011b <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010017c:	a1 ac 2a 19 80       	mov    0x80192aac,%eax
80100181:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100184:	eb 6b                	jmp    801001f1 <bget+0xfa>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 4c             	mov    0x4c(%eax),%eax
8010018c:	85 c0                	test   %eax,%eax
8010018e:	75 58                	jne    801001e8 <bget+0xf1>
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	8b 00                	mov    (%eax),%eax
80100195:	83 e0 04             	and    $0x4,%eax
80100198:	85 c0                	test   %eax,%eax
8010019a:	75 4c                	jne    801001e8 <bget+0xf1>
      b->dev = dev;
8010019c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010019f:	8b 55 08             	mov    0x8(%ebp),%edx
801001a2:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
801001a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801001ab:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ba:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001c1:	83 ec 0c             	sub    $0xc,%esp
801001c4:	68 60 e3 18 80       	push   $0x8018e360
801001c9:	e8 e1 48 00 00       	call   80104aaf <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 0a 47 00 00       	call   801048ea <acquiresleep>
801001e0:	83 c4 10             	add    $0x10,%esp
      return b;
801001e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e6:	eb 1f                	jmp    80100207 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001eb:	8b 40 50             	mov    0x50(%eax),%eax
801001ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001f1:	81 7d f4 5c 2a 19 80 	cmpl   $0x80192a5c,-0xc(%ebp)
801001f8:	75 8c                	jne    80100186 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001fa:	83 ec 0c             	sub    $0xc,%esp
801001fd:	68 ce a5 10 80       	push   $0x8010a5ce
80100202:	e8 d7 03 00 00       	call   801005de <panic>
}
80100207:	c9                   	leave
80100208:	c3                   	ret

80100209 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100209:	f3 0f 1e fb          	endbr32
8010020d:	55                   	push   %ebp
8010020e:	89 e5                	mov    %esp,%ebp
80100210:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100213:	83 ec 08             	sub    $0x8,%esp
80100216:	ff 75 0c             	push   0xc(%ebp)
80100219:	ff 75 08             	push   0x8(%ebp)
8010021c:	e8 d6 fe ff ff       	call   801000f7 <bget>
80100221:	83 c4 10             	add    $0x10,%esp
80100224:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
80100227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010022a:	8b 00                	mov    (%eax),%eax
8010022c:	83 e0 02             	and    $0x2,%eax
8010022f:	85 c0                	test   %eax,%eax
80100231:	75 0e                	jne    80100241 <bread+0x38>
    iderw(b);
80100233:	83 ec 0c             	sub    $0xc,%esp
80100236:	ff 75 f4             	push   -0xc(%ebp)
80100239:	e8 8a a2 00 00       	call   8010a4c8 <iderw>
8010023e:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100241:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100244:	c9                   	leave
80100245:	c3                   	ret

80100246 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100246:	f3 0f 1e fb          	endbr32
8010024a:	55                   	push   %ebp
8010024b:	89 e5                	mov    %esp,%ebp
8010024d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	50                   	push   %eax
8010025a:	e8 45 47 00 00       	call   801049a4 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 df a5 10 80       	push   $0x8010a5df
8010026e:	e8 6b 03 00 00       	call   801005de <panic>
  b->flags |= B_DIRTY;
80100273:	8b 45 08             	mov    0x8(%ebp),%eax
80100276:	8b 00                	mov    (%eax),%eax
80100278:	83 c8 04             	or     $0x4,%eax
8010027b:	89 c2                	mov    %eax,%edx
8010027d:	8b 45 08             	mov    0x8(%ebp),%eax
80100280:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100282:	83 ec 0c             	sub    $0xc,%esp
80100285:	ff 75 08             	push   0x8(%ebp)
80100288:	e8 3b a2 00 00       	call   8010a4c8 <iderw>
8010028d:	83 c4 10             	add    $0x10,%esp
}
80100290:	90                   	nop
80100291:	c9                   	leave
80100292:	c3                   	ret

80100293 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100293:	f3 0f 1e fb          	endbr32
80100297:	55                   	push   %ebp
80100298:	89 e5                	mov    %esp,%ebp
8010029a:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010029d:	8b 45 08             	mov    0x8(%ebp),%eax
801002a0:	83 c0 0c             	add    $0xc,%eax
801002a3:	83 ec 0c             	sub    $0xc,%esp
801002a6:	50                   	push   %eax
801002a7:	e8 f8 46 00 00       	call   801049a4 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 e6 a5 10 80       	push   $0x8010a5e6
801002bb:	e8 1e 03 00 00       	call   801005de <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 83 46 00 00       	call   80104952 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 5e 47 00 00       	call   80104a3d <acquire>
801002df:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002e2:	8b 45 08             	mov    0x8(%ebp),%eax
801002e5:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e8:	8d 50 ff             	lea    -0x1(%eax),%edx
801002eb:	8b 45 08             	mov    0x8(%ebp),%eax
801002ee:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002f1:	8b 45 08             	mov    0x8(%ebp),%eax
801002f4:	8b 40 4c             	mov    0x4c(%eax),%eax
801002f7:	85 c0                	test   %eax,%eax
801002f9:	75 47                	jne    80100342 <brelse+0xaf>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002fb:	8b 45 08             	mov    0x8(%ebp),%eax
801002fe:	8b 40 54             	mov    0x54(%eax),%eax
80100301:	8b 55 08             	mov    0x8(%ebp),%edx
80100304:	8b 52 50             	mov    0x50(%edx),%edx
80100307:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	8b 40 50             	mov    0x50(%eax),%eax
80100310:	8b 55 08             	mov    0x8(%ebp),%edx
80100313:	8b 52 54             	mov    0x54(%edx),%edx
80100316:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100319:	8b 15 b0 2a 19 80    	mov    0x80192ab0,%edx
8010031f:	8b 45 08             	mov    0x8(%ebp),%eax
80100322:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100325:	8b 45 08             	mov    0x8(%ebp),%eax
80100328:	c7 40 50 5c 2a 19 80 	movl   $0x80192a5c,0x50(%eax)
    bcache.head.next->prev = b;
8010032f:	a1 b0 2a 19 80       	mov    0x80192ab0,%eax
80100334:	8b 55 08             	mov    0x8(%ebp),%edx
80100337:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
8010033a:	8b 45 08             	mov    0x8(%ebp),%eax
8010033d:	a3 b0 2a 19 80       	mov    %eax,0x80192ab0
  }
  
  release(&bcache.lock);
80100342:	83 ec 0c             	sub    $0xc,%esp
80100345:	68 60 e3 18 80       	push   $0x8018e360
8010034a:	e8 60 47 00 00       	call   80104aaf <release>
8010034f:	83 c4 10             	add    $0x10,%esp
}
80100352:	90                   	nop
80100353:	c9                   	leave
80100354:	c3                   	ret

80100355 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100355:	55                   	push   %ebp
80100356:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100358:	fa                   	cli
}
80100359:	90                   	nop
8010035a:	5d                   	pop    %ebp
8010035b:	c3                   	ret

8010035c <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
8010035c:	f3 0f 1e fb          	endbr32
80100360:	55                   	push   %ebp
80100361:	89 e5                	mov    %esp,%ebp
80100363:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100366:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010036a:	74 1c                	je     80100388 <printint+0x2c>
8010036c:	8b 45 08             	mov    0x8(%ebp),%eax
8010036f:	c1 e8 1f             	shr    $0x1f,%eax
80100372:	0f b6 c0             	movzbl %al,%eax
80100375:	89 45 10             	mov    %eax,0x10(%ebp)
80100378:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010037c:	74 0a                	je     80100388 <printint+0x2c>
    x = -xx;
8010037e:	8b 45 08             	mov    0x8(%ebp),%eax
80100381:	f7 d8                	neg    %eax
80100383:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100386:	eb 06                	jmp    8010038e <printint+0x32>
  else
    x = xx;
80100388:	8b 45 08             	mov    0x8(%ebp),%eax
8010038b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010038e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100395:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100398:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010039b:	ba 00 00 00 00       	mov    $0x0,%edx
801003a0:	f7 f1                	div    %ecx
801003a2:	89 d1                	mov    %edx,%ecx
801003a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a7:	8d 50 01             	lea    0x1(%eax),%edx
801003aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003ad:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
801003b4:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003be:	ba 00 00 00 00       	mov    $0x0,%edx
801003c3:	f7 f1                	div    %ecx
801003c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003cc:	75 c7                	jne    80100395 <printint+0x39>

  if(sign)
801003ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003d2:	74 2a                	je     801003fe <printint+0xa2>
    buf[i++] = '-';
801003d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d7:	8d 50 01             	lea    0x1(%eax),%edx
801003da:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003dd:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003e2:	eb 1a                	jmp    801003fe <printint+0xa2>
    consputc(buf[i]);
801003e4:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003ea:	01 d0                	add    %edx,%eax
801003ec:	0f b6 00             	movzbl (%eax),%eax
801003ef:	0f be c0             	movsbl %al,%eax
801003f2:	83 ec 0c             	sub    $0xc,%esp
801003f5:	50                   	push   %eax
801003f6:	e8 b3 03 00 00       	call   801007ae <consputc>
801003fb:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003fe:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100402:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100406:	79 dc                	jns    801003e4 <printint+0x88>
}
80100408:	90                   	nop
80100409:	90                   	nop
8010040a:	c9                   	leave
8010040b:	c3                   	ret

8010040c <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
8010040c:	f3 0f 1e fb          	endbr32
80100410:	55                   	push   %ebp
80100411:	89 e5                	mov    %esp,%ebp
80100413:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100416:	a1 54 d0 18 80       	mov    0x8018d054,%eax
8010041b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010041e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100422:	74 10                	je     80100434 <cprintf+0x28>
    acquire(&cons.lock);
80100424:	83 ec 0c             	sub    $0xc,%esp
80100427:	68 20 d0 18 80       	push   $0x8018d020
8010042c:	e8 0c 46 00 00       	call   80104a3d <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 f0 a5 10 80       	push   $0x8010a5f0
80100443:	e8 96 01 00 00       	call   801005de <panic>


  argp = (uint*)(void*)(&fmt + 1);
80100448:	8d 45 0c             	lea    0xc(%ebp),%eax
8010044b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010044e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100455:	e9 48 01 00 00       	jmp    801005a2 <cprintf+0x196>
    if(c != '%'){
8010045a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010045e:	74 13                	je     80100473 <cprintf+0x67>
      consputc(c);
80100460:	83 ec 0c             	sub    $0xc,%esp
80100463:	ff 75 e4             	push   -0x1c(%ebp)
80100466:	e8 43 03 00 00       	call   801007ae <consputc>
8010046b:	83 c4 10             	add    $0x10,%esp
      continue;
8010046e:	e9 2b 01 00 00       	jmp    8010059e <cprintf+0x192>
    }
    c = fmt[++i] & 0xff;
80100473:	8b 55 08             	mov    0x8(%ebp),%edx
80100476:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010047a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010047d:	01 d0                	add    %edx,%eax
8010047f:	0f b6 00             	movzbl (%eax),%eax
80100482:	0f be c0             	movsbl %al,%eax
80100485:	25 ff 00 00 00       	and    $0xff,%eax
8010048a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010048d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100491:	0f 84 2d 01 00 00    	je     801005c4 <cprintf+0x1b8>
      break;
    switch(c){
80100497:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010049b:	0f 84 d2 00 00 00    	je     80100573 <cprintf+0x167>
801004a1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004a5:	0f 8c d7 00 00 00    	jl     80100582 <cprintf+0x176>
801004ab:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
801004af:	0f 8f cd 00 00 00    	jg     80100582 <cprintf+0x176>
801004b5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
801004b9:	0f 8c c3 00 00 00    	jl     80100582 <cprintf+0x176>
801004bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004c2:	83 e8 63             	sub    $0x63,%eax
801004c5:	83 f8 15             	cmp    $0x15,%eax
801004c8:	0f 87 b4 00 00 00    	ja     80100582 <cprintf+0x176>
801004ce:	8b 04 85 00 a6 10 80 	mov    -0x7fef5a00(,%eax,4),%eax
801004d5:	3e ff e0             	notrack jmp *%eax
    case 'd':
      printint(*argp++, 10, 1);
801004d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004db:	8d 50 04             	lea    0x4(%eax),%edx
801004de:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e1:	8b 00                	mov    (%eax),%eax
801004e3:	83 ec 04             	sub    $0x4,%esp
801004e6:	6a 01                	push   $0x1
801004e8:	6a 0a                	push   $0xa
801004ea:	50                   	push   %eax
801004eb:	e8 6c fe ff ff       	call   8010035c <printint>
801004f0:	83 c4 10             	add    $0x10,%esp
      break;
801004f3:	e9 a6 00 00 00       	jmp    8010059e <cprintf+0x192>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004fb:	8d 50 04             	lea    0x4(%eax),%edx
801004fe:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100501:	8b 00                	mov    (%eax),%eax
80100503:	83 ec 04             	sub    $0x4,%esp
80100506:	6a 00                	push   $0x0
80100508:	6a 10                	push   $0x10
8010050a:	50                   	push   %eax
8010050b:	e8 4c fe ff ff       	call   8010035c <printint>
80100510:	83 c4 10             	add    $0x10,%esp
      break;
80100513:	e9 86 00 00 00       	jmp    8010059e <cprintf+0x192>
    case 's':
      if((s = (char*)*argp++) == 0)
80100518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010051b:	8d 50 04             	lea    0x4(%eax),%edx
8010051e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100521:	8b 00                	mov    (%eax),%eax
80100523:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100526:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010052a:	75 22                	jne    8010054e <cprintf+0x142>
        s = "(null)";
8010052c:	c7 45 ec f9 a5 10 80 	movl   $0x8010a5f9,-0x14(%ebp)
      for(; *s; s++)
80100533:	eb 19                	jmp    8010054e <cprintf+0x142>
        consputc(*s);
80100535:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100538:	0f b6 00             	movzbl (%eax),%eax
8010053b:	0f be c0             	movsbl %al,%eax
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	50                   	push   %eax
80100542:	e8 67 02 00 00       	call   801007ae <consputc>
80100547:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010054a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010054e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100551:	0f b6 00             	movzbl (%eax),%eax
80100554:	84 c0                	test   %al,%al
80100556:	75 dd                	jne    80100535 <cprintf+0x129>
      break;
80100558:	eb 44                	jmp    8010059e <cprintf+0x192>
    // %c 출력
    case 'c':
      consputc(*argp++);
8010055a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010055d:	8d 50 04             	lea    0x4(%eax),%edx
80100560:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100563:	8b 00                	mov    (%eax),%eax
80100565:	83 ec 0c             	sub    $0xc,%esp
80100568:	50                   	push   %eax
80100569:	e8 40 02 00 00       	call   801007ae <consputc>
8010056e:	83 c4 10             	add    $0x10,%esp
      break;
80100571:	eb 2b                	jmp    8010059e <cprintf+0x192>
    case '%':
      consputc('%');
80100573:	83 ec 0c             	sub    $0xc,%esp
80100576:	6a 25                	push   $0x25
80100578:	e8 31 02 00 00       	call   801007ae <consputc>
8010057d:	83 c4 10             	add    $0x10,%esp
      break;
80100580:	eb 1c                	jmp    8010059e <cprintf+0x192>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100582:	83 ec 0c             	sub    $0xc,%esp
80100585:	6a 25                	push   $0x25
80100587:	e8 22 02 00 00       	call   801007ae <consputc>
8010058c:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010058f:	83 ec 0c             	sub    $0xc,%esp
80100592:	ff 75 e4             	push   -0x1c(%ebp)
80100595:	e8 14 02 00 00       	call   801007ae <consputc>
8010059a:	83 c4 10             	add    $0x10,%esp
      break;
8010059d:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010059e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005a2:	8b 55 08             	mov    0x8(%ebp),%edx
801005a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a8:	01 d0                	add    %edx,%eax
801005aa:	0f b6 00             	movzbl (%eax),%eax
801005ad:	0f be c0             	movsbl %al,%eax
801005b0:	25 ff 00 00 00       	and    $0xff,%eax
801005b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801005b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005bc:	0f 85 98 fe ff ff    	jne    8010045a <cprintf+0x4e>
801005c2:	eb 01                	jmp    801005c5 <cprintf+0x1b9>
      break;
801005c4:	90                   	nop
    }
  }

  if(locking)
801005c5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005c9:	74 10                	je     801005db <cprintf+0x1cf>
    release(&cons.lock);
801005cb:	83 ec 0c             	sub    $0xc,%esp
801005ce:	68 20 d0 18 80       	push   $0x8018d020
801005d3:	e8 d7 44 00 00       	call   80104aaf <release>
801005d8:	83 c4 10             	add    $0x10,%esp
}
801005db:	90                   	nop
801005dc:	c9                   	leave
801005dd:	c3                   	ret

801005de <panic>:

void
panic(char *s)
{
801005de:	f3 0f 1e fb          	endbr32
801005e2:	55                   	push   %ebp
801005e3:	89 e5                	mov    %esp,%ebp
801005e5:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005e8:	e8 68 fd ff ff       	call   80100355 <cli>
  cons.locking = 0;
801005ed:	c7 05 54 d0 18 80 00 	movl   $0x0,0x8018d054
801005f4:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005f7:	e8 13 26 00 00       	call   80102c0f <lapicid>
801005fc:	83 ec 08             	sub    $0x8,%esp
801005ff:	50                   	push   %eax
80100600:	68 58 a6 10 80       	push   $0x8010a658
80100605:	e8 02 fe ff ff       	call   8010040c <cprintf>
8010060a:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
8010060d:	8b 45 08             	mov    0x8(%ebp),%eax
80100610:	83 ec 0c             	sub    $0xc,%esp
80100613:	50                   	push   %eax
80100614:	e8 f3 fd ff ff       	call   8010040c <cprintf>
80100619:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010061c:	83 ec 0c             	sub    $0xc,%esp
8010061f:	68 6c a6 10 80       	push   $0x8010a66c
80100624:	e8 e3 fd ff ff       	call   8010040c <cprintf>
80100629:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
8010062c:	83 ec 08             	sub    $0x8,%esp
8010062f:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100632:	50                   	push   %eax
80100633:	8d 45 08             	lea    0x8(%ebp),%eax
80100636:	50                   	push   %eax
80100637:	e8 c9 44 00 00       	call   80104b05 <getcallerpcs>
8010063c:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010063f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100646:	eb 1c                	jmp    80100664 <panic+0x86>
    cprintf(" %p", pcs[i]);
80100648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010064b:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010064f:	83 ec 08             	sub    $0x8,%esp
80100652:	50                   	push   %eax
80100653:	68 6e a6 10 80       	push   $0x8010a66e
80100658:	e8 af fd ff ff       	call   8010040c <cprintf>
8010065d:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100660:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100664:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100668:	7e de                	jle    80100648 <panic+0x6a>
  panicked = 1; // freeze other CPU
8010066a:	c7 05 00 d0 18 80 01 	movl   $0x1,0x8018d000
80100671:	00 00 00 
  for(;;)
80100674:	eb fe                	jmp    80100674 <panic+0x96>

80100676 <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
80100676:	f3 0f 1e fb          	endbr32
8010067a:	55                   	push   %ebp
8010067b:	89 e5                	mov    %esp,%ebp
8010067d:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100680:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100684:	75 64                	jne    801006ea <graphic_putc+0x74>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
80100686:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010068c:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100691:	89 c8                	mov    %ecx,%eax
80100693:	f7 ea                	imul   %edx
80100695:	c1 fa 04             	sar    $0x4,%edx
80100698:	89 c8                	mov    %ecx,%eax
8010069a:	c1 f8 1f             	sar    $0x1f,%eax
8010069d:	29 c2                	sub    %eax,%edx
8010069f:	89 d0                	mov    %edx,%eax
801006a1:	6b c0 35             	imul   $0x35,%eax,%eax
801006a4:	29 c1                	sub    %eax,%ecx
801006a6:	89 c8                	mov    %ecx,%eax
801006a8:	ba 35 00 00 00       	mov    $0x35,%edx
801006ad:	29 c2                	sub    %eax,%edx
801006af:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006b4:	01 d0                	add    %edx,%eax
801006b6:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006bb:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c0:	3d 23 04 00 00       	cmp    $0x423,%eax
801006c5:	0f 8e e0 00 00 00    	jle    801007ab <graphic_putc+0x135>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006cb:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006d0:	83 e8 35             	sub    $0x35,%eax
801006d3:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006d8:	83 ec 0c             	sub    $0xc,%esp
801006db:	6a 1e                	push   $0x1e
801006dd:	e8 7a 7c 00 00       	call   8010835c <graphic_scroll_up>
801006e2:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006e5:	e9 c1 00 00 00       	jmp    801007ab <graphic_putc+0x135>
  }else if(c == BACKSPACE){
801006ea:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006f1:	75 1f                	jne    80100712 <graphic_putc+0x9c>
    if(console_pos>0) --console_pos;
801006f3:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006f8:	85 c0                	test   %eax,%eax
801006fa:	0f 8e ab 00 00 00    	jle    801007ab <graphic_putc+0x135>
80100700:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100705:	83 e8 01             	sub    $0x1,%eax
80100708:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010070d:	e9 99 00 00 00       	jmp    801007ab <graphic_putc+0x135>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
80100712:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100717:	3d 23 04 00 00       	cmp    $0x423,%eax
8010071c:	7e 1a                	jle    80100738 <graphic_putc+0xc2>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010071e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100723:	83 e8 35             	sub    $0x35,%eax
80100726:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010072b:	83 ec 0c             	sub    $0xc,%esp
8010072e:	6a 1e                	push   $0x1e
80100730:	e8 27 7c 00 00       	call   8010835c <graphic_scroll_up>
80100735:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
80100738:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010073e:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100743:	89 c8                	mov    %ecx,%eax
80100745:	f7 ea                	imul   %edx
80100747:	c1 fa 04             	sar    $0x4,%edx
8010074a:	89 c8                	mov    %ecx,%eax
8010074c:	c1 f8 1f             	sar    $0x1f,%eax
8010074f:	29 c2                	sub    %eax,%edx
80100751:	89 d0                	mov    %edx,%eax
80100753:	6b c0 35             	imul   $0x35,%eax,%eax
80100756:	29 c1                	sub    %eax,%ecx
80100758:	89 c8                	mov    %ecx,%eax
8010075a:	89 c2                	mov    %eax,%edx
8010075c:	c1 e2 04             	shl    $0x4,%edx
8010075f:	29 c2                	sub    %eax,%edx
80100761:	89 d0                	mov    %edx,%eax
80100763:	83 c0 02             	add    $0x2,%eax
80100766:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
80100769:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010076f:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100774:	89 c8                	mov    %ecx,%eax
80100776:	f7 ea                	imul   %edx
80100778:	c1 fa 04             	sar    $0x4,%edx
8010077b:	89 c8                	mov    %ecx,%eax
8010077d:	c1 f8 1f             	sar    $0x1f,%eax
80100780:	29 c2                	sub    %eax,%edx
80100782:	89 d0                	mov    %edx,%eax
80100784:	6b c0 1e             	imul   $0x1e,%eax,%eax
80100787:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010078a:	83 ec 04             	sub    $0x4,%esp
8010078d:	ff 75 08             	push   0x8(%ebp)
80100790:	ff 75 f0             	push   -0x10(%ebp)
80100793:	ff 75 f4             	push   -0xc(%ebp)
80100796:	e8 35 7c 00 00       	call   801083d0 <font_render>
8010079b:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010079e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801007a3:	83 c0 01             	add    $0x1,%eax
801007a6:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801007ab:	90                   	nop
801007ac:	c9                   	leave
801007ad:	c3                   	ret

801007ae <consputc>:


void
consputc(int c)
{
801007ae:	f3 0f 1e fb          	endbr32
801007b2:	55                   	push   %ebp
801007b3:	89 e5                	mov    %esp,%ebp
801007b5:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
801007b8:	a1 00 d0 18 80       	mov    0x8018d000,%eax
801007bd:	85 c0                	test   %eax,%eax
801007bf:	74 07                	je     801007c8 <consputc+0x1a>
    cli();
801007c1:	e8 8f fb ff ff       	call   80100355 <cli>
    for(;;)
801007c6:	eb fe                	jmp    801007c6 <consputc+0x18>
      ;
  }

  if(c == BACKSPACE){
801007c8:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007cf:	75 29                	jne    801007fa <consputc+0x4c>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007d1:	83 ec 0c             	sub    $0xc,%esp
801007d4:	6a 08                	push   $0x8
801007d6:	e8 aa 5f 00 00       	call   80106785 <uartputc>
801007db:	83 c4 10             	add    $0x10,%esp
801007de:	83 ec 0c             	sub    $0xc,%esp
801007e1:	6a 20                	push   $0x20
801007e3:	e8 9d 5f 00 00       	call   80106785 <uartputc>
801007e8:	83 c4 10             	add    $0x10,%esp
801007eb:	83 ec 0c             	sub    $0xc,%esp
801007ee:	6a 08                	push   $0x8
801007f0:	e8 90 5f 00 00       	call   80106785 <uartputc>
801007f5:	83 c4 10             	add    $0x10,%esp
801007f8:	eb 0e                	jmp    80100808 <consputc+0x5a>
  } else {
    uartputc(c);
801007fa:	83 ec 0c             	sub    $0xc,%esp
801007fd:	ff 75 08             	push   0x8(%ebp)
80100800:	e8 80 5f 00 00       	call   80106785 <uartputc>
80100805:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
80100808:	83 ec 0c             	sub    $0xc,%esp
8010080b:	ff 75 08             	push   0x8(%ebp)
8010080e:	e8 63 fe ff ff       	call   80100676 <graphic_putc>
80100813:	83 c4 10             	add    $0x10,%esp
}
80100816:	90                   	nop
80100817:	c9                   	leave
80100818:	c3                   	ret

80100819 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100819:	f3 0f 1e fb          	endbr32
8010081d:	55                   	push   %ebp
8010081e:	89 e5                	mov    %esp,%ebp
80100820:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
80100823:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
8010082a:	83 ec 0c             	sub    $0xc,%esp
8010082d:	68 20 d0 18 80       	push   $0x8018d020
80100832:	e8 06 42 00 00       	call   80104a3d <acquire>
80100837:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
8010083a:	e9 52 01 00 00       	jmp    80100991 <consoleintr+0x178>
    switch(c){
8010083f:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100843:	0f 84 81 00 00 00    	je     801008ca <consoleintr+0xb1>
80100849:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010084d:	0f 8f ac 00 00 00    	jg     801008ff <consoleintr+0xe6>
80100853:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100857:	74 43                	je     8010089c <consoleintr+0x83>
80100859:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010085d:	0f 8f 9c 00 00 00    	jg     801008ff <consoleintr+0xe6>
80100863:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100867:	74 61                	je     801008ca <consoleintr+0xb1>
80100869:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
8010086d:	0f 85 8c 00 00 00    	jne    801008ff <consoleintr+0xe6>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100873:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
8010087a:	e9 12 01 00 00       	jmp    80100991 <consoleintr+0x178>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010087f:	a1 48 2d 19 80       	mov    0x80192d48,%eax
80100884:	83 e8 01             	sub    $0x1,%eax
80100887:	a3 48 2d 19 80       	mov    %eax,0x80192d48
        consputc(BACKSPACE);
8010088c:	83 ec 0c             	sub    $0xc,%esp
8010088f:	68 00 01 00 00       	push   $0x100
80100894:	e8 15 ff ff ff       	call   801007ae <consputc>
80100899:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
8010089c:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
801008a2:	a1 44 2d 19 80       	mov    0x80192d44,%eax
801008a7:	39 c2                	cmp    %eax,%edx
801008a9:	0f 84 e2 00 00 00    	je     80100991 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008af:	a1 48 2d 19 80       	mov    0x80192d48,%eax
801008b4:	83 e8 01             	sub    $0x1,%eax
801008b7:	83 e0 7f             	and    $0x7f,%eax
801008ba:	0f b6 80 c0 2c 19 80 	movzbl -0x7fe6d340(%eax),%eax
      while(input.e != input.w &&
801008c1:	3c 0a                	cmp    $0xa,%al
801008c3:	75 ba                	jne    8010087f <consoleintr+0x66>
      }
      break;
801008c5:	e9 c7 00 00 00       	jmp    80100991 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008ca:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
801008d0:	a1 44 2d 19 80       	mov    0x80192d44,%eax
801008d5:	39 c2                	cmp    %eax,%edx
801008d7:	0f 84 b4 00 00 00    	je     80100991 <consoleintr+0x178>
        input.e--;
801008dd:	a1 48 2d 19 80       	mov    0x80192d48,%eax
801008e2:	83 e8 01             	sub    $0x1,%eax
801008e5:	a3 48 2d 19 80       	mov    %eax,0x80192d48
        consputc(BACKSPACE);
801008ea:	83 ec 0c             	sub    $0xc,%esp
801008ed:	68 00 01 00 00       	push   $0x100
801008f2:	e8 b7 fe ff ff       	call   801007ae <consputc>
801008f7:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008fa:	e9 92 00 00 00       	jmp    80100991 <consoleintr+0x178>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100903:	0f 84 87 00 00 00    	je     80100990 <consoleintr+0x177>
80100909:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
8010090f:	a1 40 2d 19 80       	mov    0x80192d40,%eax
80100914:	29 c2                	sub    %eax,%edx
80100916:	89 d0                	mov    %edx,%eax
80100918:	83 f8 7f             	cmp    $0x7f,%eax
8010091b:	77 73                	ja     80100990 <consoleintr+0x177>
        c = (c == '\r') ? '\n' : c;
8010091d:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100921:	74 05                	je     80100928 <consoleintr+0x10f>
80100923:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100926:	eb 05                	jmp    8010092d <consoleintr+0x114>
80100928:	b8 0a 00 00 00       	mov    $0xa,%eax
8010092d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100930:	a1 48 2d 19 80       	mov    0x80192d48,%eax
80100935:	8d 50 01             	lea    0x1(%eax),%edx
80100938:	89 15 48 2d 19 80    	mov    %edx,0x80192d48
8010093e:	83 e0 7f             	and    $0x7f,%eax
80100941:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100944:	88 90 c0 2c 19 80    	mov    %dl,-0x7fe6d340(%eax)
        consputc(c);
8010094a:	83 ec 0c             	sub    $0xc,%esp
8010094d:	ff 75 f0             	push   -0x10(%ebp)
80100950:	e8 59 fe ff ff       	call   801007ae <consputc>
80100955:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100958:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010095c:	74 18                	je     80100976 <consoleintr+0x15d>
8010095e:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100962:	74 12                	je     80100976 <consoleintr+0x15d>
80100964:	a1 48 2d 19 80       	mov    0x80192d48,%eax
80100969:	8b 15 40 2d 19 80    	mov    0x80192d40,%edx
8010096f:	83 ea 80             	sub    $0xffffff80,%edx
80100972:	39 d0                	cmp    %edx,%eax
80100974:	75 1a                	jne    80100990 <consoleintr+0x177>
          input.w = input.e;
80100976:	a1 48 2d 19 80       	mov    0x80192d48,%eax
8010097b:	a3 44 2d 19 80       	mov    %eax,0x80192d44
          wakeup(&input.r);
80100980:	83 ec 0c             	sub    $0xc,%esp
80100983:	68 40 2d 19 80       	push   $0x80192d40
80100988:	e8 26 3c 00 00       	call   801045b3 <wakeup>
8010098d:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100990:	90                   	nop
  while((c = getc()) >= 0){
80100991:	8b 45 08             	mov    0x8(%ebp),%eax
80100994:	ff d0                	call   *%eax
80100996:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100999:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010099d:	0f 89 9c fe ff ff    	jns    8010083f <consoleintr+0x26>
    }
  }
  release(&cons.lock);
801009a3:	83 ec 0c             	sub    $0xc,%esp
801009a6:	68 20 d0 18 80       	push   $0x8018d020
801009ab:	e8 ff 40 00 00       	call   80104aaf <release>
801009b0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b7:	74 05                	je     801009be <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009b9:	e8 b8 3c 00 00       	call   80104676 <procdump>
  }
}
801009be:	90                   	nop
801009bf:	c9                   	leave
801009c0:	c3                   	ret

801009c1 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009c1:	f3 0f 1e fb          	endbr32
801009c5:	55                   	push   %ebp
801009c6:	89 e5                	mov    %esp,%ebp
801009c8:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	ff 75 08             	push   0x8(%ebp)
801009d1:	e8 cd 11 00 00       	call   80101ba3 <iunlock>
801009d6:	83 c4 10             	add    $0x10,%esp
  target = n;
801009d9:	8b 45 10             	mov    0x10(%ebp),%eax
801009dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009df:	83 ec 0c             	sub    $0xc,%esp
801009e2:	68 20 d0 18 80       	push   $0x8018d020
801009e7:	e8 51 40 00 00       	call   80104a3d <acquire>
801009ec:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009ef:	e9 ab 00 00 00       	jmp    80100a9f <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
801009f4:	e8 c0 31 00 00       	call   80103bb9 <myproc>
801009f9:	8b 40 24             	mov    0x24(%eax),%eax
801009fc:	85 c0                	test   %eax,%eax
801009fe:	74 28                	je     80100a28 <consoleread+0x67>
        release(&cons.lock);
80100a00:	83 ec 0c             	sub    $0xc,%esp
80100a03:	68 20 d0 18 80       	push   $0x8018d020
80100a08:	e8 a2 40 00 00       	call   80104aaf <release>
80100a0d:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a10:	83 ec 0c             	sub    $0xc,%esp
80100a13:	ff 75 08             	push   0x8(%ebp)
80100a16:	e8 71 10 00 00       	call   80101a8c <ilock>
80100a1b:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a23:	e9 ab 00 00 00       	jmp    80100ad3 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100a28:	83 ec 08             	sub    $0x8,%esp
80100a2b:	68 20 d0 18 80       	push   $0x8018d020
80100a30:	68 40 2d 19 80       	push   $0x80192d40
80100a35:	e8 8a 3a 00 00       	call   801044c4 <sleep>
80100a3a:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a3d:	8b 15 40 2d 19 80    	mov    0x80192d40,%edx
80100a43:	a1 44 2d 19 80       	mov    0x80192d44,%eax
80100a48:	39 c2                	cmp    %eax,%edx
80100a4a:	74 a8                	je     801009f4 <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a4c:	a1 40 2d 19 80       	mov    0x80192d40,%eax
80100a51:	8d 50 01             	lea    0x1(%eax),%edx
80100a54:	89 15 40 2d 19 80    	mov    %edx,0x80192d40
80100a5a:	83 e0 7f             	and    $0x7f,%eax
80100a5d:	0f b6 80 c0 2c 19 80 	movzbl -0x7fe6d340(%eax),%eax
80100a64:	0f be c0             	movsbl %al,%eax
80100a67:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a6a:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a6e:	75 17                	jne    80100a87 <consoleread+0xc6>
      if(n < target){
80100a70:	8b 45 10             	mov    0x10(%ebp),%eax
80100a73:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a76:	76 2f                	jbe    80100aa7 <consoleread+0xe6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a78:	a1 40 2d 19 80       	mov    0x80192d40,%eax
80100a7d:	83 e8 01             	sub    $0x1,%eax
80100a80:	a3 40 2d 19 80       	mov    %eax,0x80192d40
      }
      break;
80100a85:	eb 20                	jmp    80100aa7 <consoleread+0xe6>
    }
    *dst++ = c;
80100a87:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a8a:	8d 50 01             	lea    0x1(%eax),%edx
80100a8d:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a90:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a93:	88 10                	mov    %dl,(%eax)
    --n;
80100a95:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a99:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a9d:	74 0b                	je     80100aaa <consoleread+0xe9>
  while(n > 0){
80100a9f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100aa3:	7f 98                	jg     80100a3d <consoleread+0x7c>
80100aa5:	eb 04                	jmp    80100aab <consoleread+0xea>
      break;
80100aa7:	90                   	nop
80100aa8:	eb 01                	jmp    80100aab <consoleread+0xea>
      break;
80100aaa:	90                   	nop
  }
  release(&cons.lock);
80100aab:	83 ec 0c             	sub    $0xc,%esp
80100aae:	68 20 d0 18 80       	push   $0x8018d020
80100ab3:	e8 f7 3f 00 00       	call   80104aaf <release>
80100ab8:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100abb:	83 ec 0c             	sub    $0xc,%esp
80100abe:	ff 75 08             	push   0x8(%ebp)
80100ac1:	e8 c6 0f 00 00       	call   80101a8c <ilock>
80100ac6:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100ac9:	8b 45 10             	mov    0x10(%ebp),%eax
80100acc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100acf:	29 c2                	sub    %eax,%edx
80100ad1:	89 d0                	mov    %edx,%eax
}
80100ad3:	c9                   	leave
80100ad4:	c3                   	ret

80100ad5 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100ad5:	f3 0f 1e fb          	endbr32
80100ad9:	55                   	push   %ebp
80100ada:	89 e5                	mov    %esp,%ebp
80100adc:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100adf:	83 ec 0c             	sub    $0xc,%esp
80100ae2:	ff 75 08             	push   0x8(%ebp)
80100ae5:	e8 b9 10 00 00       	call   80101ba3 <iunlock>
80100aea:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100aed:	83 ec 0c             	sub    $0xc,%esp
80100af0:	68 20 d0 18 80       	push   $0x8018d020
80100af5:	e8 43 3f 00 00       	call   80104a3d <acquire>
80100afa:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100afd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b04:	eb 21                	jmp    80100b27 <consolewrite+0x52>
    consputc(buf[i] & 0xff);
80100b06:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b09:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b0c:	01 d0                	add    %edx,%eax
80100b0e:	0f b6 00             	movzbl (%eax),%eax
80100b11:	0f be c0             	movsbl %al,%eax
80100b14:	0f b6 c0             	movzbl %al,%eax
80100b17:	83 ec 0c             	sub    $0xc,%esp
80100b1a:	50                   	push   %eax
80100b1b:	e8 8e fc ff ff       	call   801007ae <consputc>
80100b20:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b23:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b2a:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b2d:	7c d7                	jl     80100b06 <consolewrite+0x31>
  release(&cons.lock);
80100b2f:	83 ec 0c             	sub    $0xc,%esp
80100b32:	68 20 d0 18 80       	push   $0x8018d020
80100b37:	e8 73 3f 00 00       	call   80104aaf <release>
80100b3c:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b3f:	83 ec 0c             	sub    $0xc,%esp
80100b42:	ff 75 08             	push   0x8(%ebp)
80100b45:	e8 42 0f 00 00       	call   80101a8c <ilock>
80100b4a:	83 c4 10             	add    $0x10,%esp

  return n;
80100b4d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b50:	c9                   	leave
80100b51:	c3                   	ret

80100b52 <consoleinit>:

void
consoleinit(void)
{
80100b52:	f3 0f 1e fb          	endbr32
80100b56:	55                   	push   %ebp
80100b57:	89 e5                	mov    %esp,%ebp
80100b59:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b5c:	c7 05 00 d0 18 80 00 	movl   $0x0,0x8018d000
80100b63:	00 00 00 
  initlock(&cons.lock, "console");
80100b66:	83 ec 08             	sub    $0x8,%esp
80100b69:	68 72 a6 10 80       	push   $0x8010a672
80100b6e:	68 20 d0 18 80       	push   $0x8018d020
80100b73:	e8 9f 3e 00 00       	call   80104a17 <initlock>
80100b78:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b7b:	c7 05 0c 37 19 80 d5 	movl   $0x80100ad5,0x8019370c
80100b82:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b85:	c7 05 08 37 19 80 c1 	movl   $0x801009c1,0x80193708
80100b8c:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b8f:	c7 45 f4 7a a6 10 80 	movl   $0x8010a67a,-0xc(%ebp)
80100b96:	eb 19                	jmp    80100bb1 <consoleinit+0x5f>
    graphic_putc(*p);
80100b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b9b:	0f b6 00             	movzbl (%eax),%eax
80100b9e:	0f be c0             	movsbl %al,%eax
80100ba1:	83 ec 0c             	sub    $0xc,%esp
80100ba4:	50                   	push   %eax
80100ba5:	e8 cc fa ff ff       	call   80100676 <graphic_putc>
80100baa:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100bad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100bb4:	0f b6 00             	movzbl (%eax),%eax
80100bb7:	84 c0                	test   %al,%al
80100bb9:	75 dd                	jne    80100b98 <consoleinit+0x46>
  
  cons.locking = 1;
80100bbb:	c7 05 54 d0 18 80 01 	movl   $0x1,0x8018d054
80100bc2:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100bc5:	83 ec 08             	sub    $0x8,%esp
80100bc8:	6a 00                	push   $0x0
80100bca:	6a 01                	push   $0x1
80100bcc:	e8 4b 1b 00 00       	call   8010271c <ioapicenable>
80100bd1:	83 c4 10             	add    $0x10,%esp
}
80100bd4:	90                   	nop
80100bd5:	c9                   	leave
80100bd6:	c3                   	ret

80100bd7 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100bd7:	f3 0f 1e fb          	endbr32
80100bdb:	55                   	push   %ebp
80100bdc:	89 e5                	mov    %esp,%ebp
80100bde:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100be4:	e8 d0 2f 00 00       	call   80103bb9 <myproc>
80100be9:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bec:	e8 90 25 00 00       	call   80103181 <begin_op>

  if((ip = namei(path)) == 0){
80100bf1:	83 ec 0c             	sub    $0xc,%esp
80100bf4:	ff 75 08             	push   0x8(%ebp)
80100bf7:	e8 fb 19 00 00       	call   801025f7 <namei>
80100bfc:	83 c4 10             	add    $0x10,%esp
80100bff:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c02:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c06:	75 1f                	jne    80100c27 <exec+0x50>
    end_op();
80100c08:	e8 04 26 00 00       	call   80103211 <end_op>
    cprintf("exec: fail\n");
80100c0d:	83 ec 0c             	sub    $0xc,%esp
80100c10:	68 90 a6 10 80       	push   $0x8010a690
80100c15:	e8 f2 f7 ff ff       	call   8010040c <cprintf>
80100c1a:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c22:	e9 e8 03 00 00       	jmp    8010100f <exec+0x438>
  }
  ilock(ip);
80100c27:	83 ec 0c             	sub    $0xc,%esp
80100c2a:	ff 75 d8             	push   -0x28(%ebp)
80100c2d:	e8 5a 0e 00 00       	call   80101a8c <ilock>
80100c32:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c35:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c3c:	6a 34                	push   $0x34
80100c3e:	6a 00                	push   $0x0
80100c40:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c46:	50                   	push   %eax
80100c47:	ff 75 d8             	push   -0x28(%ebp)
80100c4a:	e8 45 13 00 00       	call   80101f94 <readi>
80100c4f:	83 c4 10             	add    $0x10,%esp
80100c52:	83 f8 34             	cmp    $0x34,%eax
80100c55:	0f 85 4d 03 00 00    	jne    80100fa8 <exec+0x3d1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c5b:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c61:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c66:	0f 85 3f 03 00 00    	jne    80100fab <exec+0x3d4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c6c:	e8 28 6b 00 00       	call   80107799 <setupkvm>
80100c71:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c74:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c78:	0f 84 30 03 00 00    	je     80100fae <exec+0x3d7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c7e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c85:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c8c:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c92:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c95:	e9 de 00 00 00       	jmp    80100d78 <exec+0x1a1>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c9d:	6a 20                	push   $0x20
80100c9f:	50                   	push   %eax
80100ca0:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100ca6:	50                   	push   %eax
80100ca7:	ff 75 d8             	push   -0x28(%ebp)
80100caa:	e8 e5 12 00 00       	call   80101f94 <readi>
80100caf:	83 c4 10             	add    $0x10,%esp
80100cb2:	83 f8 20             	cmp    $0x20,%eax
80100cb5:	0f 85 f6 02 00 00    	jne    80100fb1 <exec+0x3da>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100cbb:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100cc1:	83 f8 01             	cmp    $0x1,%eax
80100cc4:	0f 85 a0 00 00 00    	jne    80100d6a <exec+0x193>
      continue;
    if(ph.memsz < ph.filesz)
80100cca:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cd0:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100cd6:	39 c2                	cmp    %eax,%edx
80100cd8:	0f 82 d6 02 00 00    	jb     80100fb4 <exec+0x3dd>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cde:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ce4:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cea:	01 c2                	add    %eax,%edx
80100cec:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cf2:	39 c2                	cmp    %eax,%edx
80100cf4:	0f 82 bd 02 00 00    	jb     80100fb7 <exec+0x3e0>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cfa:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d00:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d06:	01 d0                	add    %edx,%eax
80100d08:	83 ec 04             	sub    $0x4,%esp
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 e0             	push   -0x20(%ebp)
80100d0f:	ff 75 d4             	push   -0x2c(%ebp)
80100d12:	e8 94 6e 00 00       	call   80107bab <allocuvm>
80100d17:	83 c4 10             	add    $0x10,%esp
80100d1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d21:	0f 84 93 02 00 00    	je     80100fba <exec+0x3e3>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d27:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d2d:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d32:	85 c0                	test   %eax,%eax
80100d34:	0f 85 83 02 00 00    	jne    80100fbd <exec+0x3e6>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d3a:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d40:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d46:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d4c:	83 ec 0c             	sub    $0xc,%esp
80100d4f:	52                   	push   %edx
80100d50:	50                   	push   %eax
80100d51:	ff 75 d8             	push   -0x28(%ebp)
80100d54:	51                   	push   %ecx
80100d55:	ff 75 d4             	push   -0x2c(%ebp)
80100d58:	e8 7d 6d 00 00       	call   80107ada <loaduvm>
80100d5d:	83 c4 20             	add    $0x20,%esp
80100d60:	85 c0                	test   %eax,%eax
80100d62:	0f 88 58 02 00 00    	js     80100fc0 <exec+0x3e9>
80100d68:	eb 01                	jmp    80100d6b <exec+0x194>
      continue;
80100d6a:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d6b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d72:	83 c0 20             	add    $0x20,%eax
80100d75:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d78:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d7f:	0f b7 c0             	movzwl %ax,%eax
80100d82:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d85:	0f 8c 0f ff ff ff    	jl     80100c9a <exec+0xc3>
      goto bad;
  }
  iunlockput(ip);
80100d8b:	83 ec 0c             	sub    $0xc,%esp
80100d8e:	ff 75 d8             	push   -0x28(%ebp)
80100d91:	e8 33 0f 00 00       	call   80101cc9 <iunlockput>
80100d96:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d99:	e8 73 24 00 00       	call   80103211 <end_op>
  ip = 0;
80100d9e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  // sz를 커널 베이스로 이동 페이지를 할당해야 하기 때문에 그 크기만큼 빼줌
  // 2*PGSIZE로 하면 페이지의 끝 주소가 커널 베이스가 되기 때문에 한단계 더 내린다.
  sz = PGROUNDDOWN(KERNBASE - 2*PGSIZE);
80100da5:	c7 45 e0 00 e0 ff 7f 	movl   $0x7fffe000,-0x20(%ebp)
  // 커널 베이스에서 PGSIZE만큼 할당
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
80100dac:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100daf:	05 00 10 00 00       	add    $0x1000,%eax
80100db4:	83 ec 04             	sub    $0x4,%esp
80100db7:	50                   	push   %eax
80100db8:	ff 75 e0             	push   -0x20(%ebp)
80100dbb:	ff 75 d4             	push   -0x2c(%ebp)
80100dbe:	e8 e8 6d 00 00       	call   80107bab <allocuvm>
80100dc3:	83 c4 10             	add    $0x10,%esp
80100dc6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dc9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dcd:	0f 84 f0 01 00 00    	je     80100fc3 <exec+0x3ec>
    goto bad;
  // 스택 포인터를 sz로
  sp = sz;
80100dd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dd6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  // 0xb98은 text, data영역의 윗 부분
  // sz는 사용 중인 유저 공간을 나타내주는데 스택을 kernbase로 옮겨서
  // 스택 외의 코드까지만 sz로 변경
  sz = PGROUNDUP(0xb98)+1;
80100dd9:	c7 45 e0 01 10 00 00 	movl   $0x1001,-0x20(%ebp)


  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100de7:	e9 96 00 00 00       	jmp    80100e82 <exec+0x2ab>
    if(argc >= MAXARG)
80100dec:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100df0:	0f 87 d0 01 00 00    	ja     80100fc6 <exec+0x3ef>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e00:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e03:	01 d0                	add    %edx,%eax
80100e05:	8b 00                	mov    (%eax),%eax
80100e07:	83 ec 0c             	sub    $0xc,%esp
80100e0a:	50                   	push   %eax
80100e0b:	e8 25 41 00 00       	call   80104f35 <strlen>
80100e10:	83 c4 10             	add    $0x10,%esp
80100e13:	89 c2                	mov    %eax,%edx
80100e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e18:	29 d0                	sub    %edx,%eax
80100e1a:	83 e8 01             	sub    $0x1,%eax
80100e1d:	83 e0 fc             	and    $0xfffffffc,%eax
80100e20:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e26:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e30:	01 d0                	add    %edx,%eax
80100e32:	8b 00                	mov    (%eax),%eax
80100e34:	83 ec 0c             	sub    $0xc,%esp
80100e37:	50                   	push   %eax
80100e38:	e8 f8 40 00 00       	call   80104f35 <strlen>
80100e3d:	83 c4 10             	add    $0x10,%esp
80100e40:	83 c0 01             	add    $0x1,%eax
80100e43:	89 c1                	mov    %eax,%ecx
80100e45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e48:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e52:	01 d0                	add    %edx,%eax
80100e54:	8b 00                	mov    (%eax),%eax
80100e56:	51                   	push   %ecx
80100e57:	50                   	push   %eax
80100e58:	ff 75 dc             	push   -0x24(%ebp)
80100e5b:	ff 75 d4             	push   -0x2c(%ebp)
80100e5e:	e8 4c 71 00 00       	call   80107faf <copyout>
80100e63:	83 c4 10             	add    $0x10,%esp
80100e66:	85 c0                	test   %eax,%eax
80100e68:	0f 88 5b 01 00 00    	js     80100fc9 <exec+0x3f2>
      goto bad;
    ustack[3+argc] = sp;
80100e6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e71:	8d 50 03             	lea    0x3(%eax),%edx
80100e74:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e77:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e7e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e85:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e8f:	01 d0                	add    %edx,%eax
80100e91:	8b 00                	mov    (%eax),%eax
80100e93:	85 c0                	test   %eax,%eax
80100e95:	0f 85 51 ff ff ff    	jne    80100dec <exec+0x215>
  }
  ustack[3+argc] = 0;
80100e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9e:	83 c0 03             	add    $0x3,%eax
80100ea1:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100ea8:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100eac:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100eb3:	ff ff ff 
  ustack[1] = argc;
80100eb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb9:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ebf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec2:	83 c0 01             	add    $0x1,%eax
80100ec5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ecc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ecf:	29 d0                	sub    %edx,%eax
80100ed1:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100ed7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eda:	83 c0 04             	add    $0x4,%eax
80100edd:	c1 e0 02             	shl    $0x2,%eax
80100ee0:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ee3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee6:	83 c0 04             	add    $0x4,%eax
80100ee9:	c1 e0 02             	shl    $0x2,%eax
80100eec:	50                   	push   %eax
80100eed:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ef3:	50                   	push   %eax
80100ef4:	ff 75 dc             	push   -0x24(%ebp)
80100ef7:	ff 75 d4             	push   -0x2c(%ebp)
80100efa:	e8 b0 70 00 00       	call   80107faf <copyout>
80100eff:	83 c4 10             	add    $0x10,%esp
80100f02:	85 c0                	test   %eax,%eax
80100f04:	0f 88 c2 00 00 00    	js     80100fcc <exec+0x3f5>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80100f0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f13:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f16:	eb 17                	jmp    80100f2f <exec+0x358>
    if(*s == '/')
80100f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f1b:	0f b6 00             	movzbl (%eax),%eax
80100f1e:	3c 2f                	cmp    $0x2f,%al
80100f20:	75 09                	jne    80100f2b <exec+0x354>
      last = s+1;
80100f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f25:	83 c0 01             	add    $0x1,%eax
80100f28:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f2b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f32:	0f b6 00             	movzbl (%eax),%eax
80100f35:	84 c0                	test   %al,%al
80100f37:	75 df                	jne    80100f18 <exec+0x341>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f39:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3c:	83 c0 6c             	add    $0x6c,%eax
80100f3f:	83 ec 04             	sub    $0x4,%esp
80100f42:	6a 10                	push   $0x10
80100f44:	ff 75 f0             	push   -0x10(%ebp)
80100f47:	50                   	push   %eax
80100f48:	e8 9a 3f 00 00       	call   80104ee7 <safestrcpy>
80100f4d:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f50:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f53:	8b 40 04             	mov    0x4(%eax),%eax
80100f56:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f59:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f5c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f5f:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f62:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f65:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f68:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f6a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f6d:	8b 40 18             	mov    0x18(%eax),%eax
80100f70:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f76:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f79:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f7c:	8b 40 18             	mov    0x18(%eax),%eax
80100f7f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f82:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f85:	83 ec 0c             	sub    $0xc,%esp
80100f88:	ff 75 d0             	push   -0x30(%ebp)
80100f8b:	e8 33 69 00 00       	call   801078c3 <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	push   -0x34(%ebp)
80100f99:	e8 de 6d 00 00       	call   80107d7c <freevm>
80100f9e:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fa1:	b8 00 00 00 00       	mov    $0x0,%eax
80100fa6:	eb 67                	jmp    8010100f <exec+0x438>
    goto bad;
80100fa8:	90                   	nop
80100fa9:	eb 22                	jmp    80100fcd <exec+0x3f6>
    goto bad;
80100fab:	90                   	nop
80100fac:	eb 1f                	jmp    80100fcd <exec+0x3f6>
    goto bad;
80100fae:	90                   	nop
80100faf:	eb 1c                	jmp    80100fcd <exec+0x3f6>
      goto bad;
80100fb1:	90                   	nop
80100fb2:	eb 19                	jmp    80100fcd <exec+0x3f6>
      goto bad;
80100fb4:	90                   	nop
80100fb5:	eb 16                	jmp    80100fcd <exec+0x3f6>
      goto bad;
80100fb7:	90                   	nop
80100fb8:	eb 13                	jmp    80100fcd <exec+0x3f6>
      goto bad;
80100fba:	90                   	nop
80100fbb:	eb 10                	jmp    80100fcd <exec+0x3f6>
      goto bad;
80100fbd:	90                   	nop
80100fbe:	eb 0d                	jmp    80100fcd <exec+0x3f6>
      goto bad;
80100fc0:	90                   	nop
80100fc1:	eb 0a                	jmp    80100fcd <exec+0x3f6>
    goto bad;
80100fc3:	90                   	nop
80100fc4:	eb 07                	jmp    80100fcd <exec+0x3f6>
      goto bad;
80100fc6:	90                   	nop
80100fc7:	eb 04                	jmp    80100fcd <exec+0x3f6>
      goto bad;
80100fc9:	90                   	nop
80100fca:	eb 01                	jmp    80100fcd <exec+0x3f6>
    goto bad;
80100fcc:	90                   	nop

 bad:
  cprintf("bad \n");
80100fcd:	83 ec 0c             	sub    $0xc,%esp
80100fd0:	68 9c a6 10 80       	push   $0x8010a69c
80100fd5:	e8 32 f4 ff ff       	call   8010040c <cprintf>
80100fda:	83 c4 10             	add    $0x10,%esp
  if(pgdir)
80100fdd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fe1:	74 0e                	je     80100ff1 <exec+0x41a>
    freevm(pgdir);
80100fe3:	83 ec 0c             	sub    $0xc,%esp
80100fe6:	ff 75 d4             	push   -0x2c(%ebp)
80100fe9:	e8 8e 6d 00 00       	call   80107d7c <freevm>
80100fee:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100ff1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ff5:	74 13                	je     8010100a <exec+0x433>
    iunlockput(ip);
80100ff7:	83 ec 0c             	sub    $0xc,%esp
80100ffa:	ff 75 d8             	push   -0x28(%ebp)
80100ffd:	e8 c7 0c 00 00       	call   80101cc9 <iunlockput>
80101002:	83 c4 10             	add    $0x10,%esp
    end_op();
80101005:	e8 07 22 00 00       	call   80103211 <end_op>
  }
  return -1;
8010100a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010100f:	c9                   	leave
80101010:	c3                   	ret

80101011 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101011:	f3 0f 1e fb          	endbr32
80101015:	55                   	push   %ebp
80101016:	89 e5                	mov    %esp,%ebp
80101018:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010101b:	83 ec 08             	sub    $0x8,%esp
8010101e:	68 a2 a6 10 80       	push   $0x8010a6a2
80101023:	68 60 2d 19 80       	push   $0x80192d60
80101028:	e8 ea 39 00 00       	call   80104a17 <initlock>
8010102d:	83 c4 10             	add    $0x10,%esp
}
80101030:	90                   	nop
80101031:	c9                   	leave
80101032:	c3                   	ret

80101033 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101033:	f3 0f 1e fb          	endbr32
80101037:	55                   	push   %ebp
80101038:	89 e5                	mov    %esp,%ebp
8010103a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010103d:	83 ec 0c             	sub    $0xc,%esp
80101040:	68 60 2d 19 80       	push   $0x80192d60
80101045:	e8 f3 39 00 00       	call   80104a3d <acquire>
8010104a:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010104d:	c7 45 f4 94 2d 19 80 	movl   $0x80192d94,-0xc(%ebp)
80101054:	eb 2d                	jmp    80101083 <filealloc+0x50>
    if(f->ref == 0){
80101056:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101059:	8b 40 04             	mov    0x4(%eax),%eax
8010105c:	85 c0                	test   %eax,%eax
8010105e:	75 1f                	jne    8010107f <filealloc+0x4c>
      f->ref = 1;
80101060:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101063:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 60 2d 19 80       	push   $0x80192d60
80101072:	e8 38 3a 00 00       	call   80104aaf <release>
80101077:	83 c4 10             	add    $0x10,%esp
      return f;
8010107a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010107d:	eb 23                	jmp    801010a2 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010107f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101083:	b8 f4 36 19 80       	mov    $0x801936f4,%eax
80101088:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010108b:	72 c9                	jb     80101056 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010108d:	83 ec 0c             	sub    $0xc,%esp
80101090:	68 60 2d 19 80       	push   $0x80192d60
80101095:	e8 15 3a 00 00       	call   80104aaf <release>
8010109a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010109d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801010a2:	c9                   	leave
801010a3:	c3                   	ret

801010a4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801010a4:	f3 0f 1e fb          	endbr32
801010a8:	55                   	push   %ebp
801010a9:	89 e5                	mov    %esp,%ebp
801010ab:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801010ae:	83 ec 0c             	sub    $0xc,%esp
801010b1:	68 60 2d 19 80       	push   $0x80192d60
801010b6:	e8 82 39 00 00       	call   80104a3d <acquire>
801010bb:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010be:	8b 45 08             	mov    0x8(%ebp),%eax
801010c1:	8b 40 04             	mov    0x4(%eax),%eax
801010c4:	85 c0                	test   %eax,%eax
801010c6:	7f 0d                	jg     801010d5 <filedup+0x31>
    panic("filedup");
801010c8:	83 ec 0c             	sub    $0xc,%esp
801010cb:	68 a9 a6 10 80       	push   $0x8010a6a9
801010d0:	e8 09 f5 ff ff       	call   801005de <panic>
  f->ref++;
801010d5:	8b 45 08             	mov    0x8(%ebp),%eax
801010d8:	8b 40 04             	mov    0x4(%eax),%eax
801010db:	8d 50 01             	lea    0x1(%eax),%edx
801010de:	8b 45 08             	mov    0x8(%ebp),%eax
801010e1:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010e4:	83 ec 0c             	sub    $0xc,%esp
801010e7:	68 60 2d 19 80       	push   $0x80192d60
801010ec:	e8 be 39 00 00       	call   80104aaf <release>
801010f1:	83 c4 10             	add    $0x10,%esp
  return f;
801010f4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010f7:	c9                   	leave
801010f8:	c3                   	ret

801010f9 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010f9:	f3 0f 1e fb          	endbr32
801010fd:	55                   	push   %ebp
801010fe:	89 e5                	mov    %esp,%ebp
80101100:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101103:	83 ec 0c             	sub    $0xc,%esp
80101106:	68 60 2d 19 80       	push   $0x80192d60
8010110b:	e8 2d 39 00 00       	call   80104a3d <acquire>
80101110:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101113:	8b 45 08             	mov    0x8(%ebp),%eax
80101116:	8b 40 04             	mov    0x4(%eax),%eax
80101119:	85 c0                	test   %eax,%eax
8010111b:	7f 0d                	jg     8010112a <fileclose+0x31>
    panic("fileclose");
8010111d:	83 ec 0c             	sub    $0xc,%esp
80101120:	68 b1 a6 10 80       	push   $0x8010a6b1
80101125:	e8 b4 f4 ff ff       	call   801005de <panic>
  if(--f->ref > 0){
8010112a:	8b 45 08             	mov    0x8(%ebp),%eax
8010112d:	8b 40 04             	mov    0x4(%eax),%eax
80101130:	8d 50 ff             	lea    -0x1(%eax),%edx
80101133:	8b 45 08             	mov    0x8(%ebp),%eax
80101136:	89 50 04             	mov    %edx,0x4(%eax)
80101139:	8b 45 08             	mov    0x8(%ebp),%eax
8010113c:	8b 40 04             	mov    0x4(%eax),%eax
8010113f:	85 c0                	test   %eax,%eax
80101141:	7e 15                	jle    80101158 <fileclose+0x5f>
    release(&ftable.lock);
80101143:	83 ec 0c             	sub    $0xc,%esp
80101146:	68 60 2d 19 80       	push   $0x80192d60
8010114b:	e8 5f 39 00 00       	call   80104aaf <release>
80101150:	83 c4 10             	add    $0x10,%esp
80101153:	e9 8b 00 00 00       	jmp    801011e3 <fileclose+0xea>
    return;
  }
  ff = *f;
80101158:	8b 45 08             	mov    0x8(%ebp),%eax
8010115b:	8b 10                	mov    (%eax),%edx
8010115d:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101160:	8b 50 04             	mov    0x4(%eax),%edx
80101163:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101166:	8b 50 08             	mov    0x8(%eax),%edx
80101169:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010116c:	8b 50 0c             	mov    0xc(%eax),%edx
8010116f:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101172:	8b 50 10             	mov    0x10(%eax),%edx
80101175:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101178:	8b 40 14             	mov    0x14(%eax),%eax
8010117b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010117e:	8b 45 08             	mov    0x8(%ebp),%eax
80101181:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101188:	8b 45 08             	mov    0x8(%ebp),%eax
8010118b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101191:	83 ec 0c             	sub    $0xc,%esp
80101194:	68 60 2d 19 80       	push   $0x80192d60
80101199:	e8 11 39 00 00       	call   80104aaf <release>
8010119e:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
801011a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011a4:	83 f8 01             	cmp    $0x1,%eax
801011a7:	75 19                	jne    801011c2 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
801011a9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801011ad:	0f be d0             	movsbl %al,%edx
801011b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011b3:	83 ec 08             	sub    $0x8,%esp
801011b6:	52                   	push   %edx
801011b7:	50                   	push   %eax
801011b8:	e8 73 26 00 00       	call   80103830 <pipeclose>
801011bd:	83 c4 10             	add    $0x10,%esp
801011c0:	eb 21                	jmp    801011e3 <fileclose+0xea>
  else if(ff.type == FD_INODE){
801011c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011c5:	83 f8 02             	cmp    $0x2,%eax
801011c8:	75 19                	jne    801011e3 <fileclose+0xea>
    begin_op();
801011ca:	e8 b2 1f 00 00       	call   80103181 <begin_op>
    iput(ff.ip);
801011cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011d2:	83 ec 0c             	sub    $0xc,%esp
801011d5:	50                   	push   %eax
801011d6:	e8 1a 0a 00 00       	call   80101bf5 <iput>
801011db:	83 c4 10             	add    $0x10,%esp
    end_op();
801011de:	e8 2e 20 00 00       	call   80103211 <end_op>
  }
}
801011e3:	c9                   	leave
801011e4:	c3                   	ret

801011e5 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011e5:	f3 0f 1e fb          	endbr32
801011e9:	55                   	push   %ebp
801011ea:	89 e5                	mov    %esp,%ebp
801011ec:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011ef:	8b 45 08             	mov    0x8(%ebp),%eax
801011f2:	8b 00                	mov    (%eax),%eax
801011f4:	83 f8 02             	cmp    $0x2,%eax
801011f7:	75 40                	jne    80101239 <filestat+0x54>
    ilock(f->ip);
801011f9:	8b 45 08             	mov    0x8(%ebp),%eax
801011fc:	8b 40 10             	mov    0x10(%eax),%eax
801011ff:	83 ec 0c             	sub    $0xc,%esp
80101202:	50                   	push   %eax
80101203:	e8 84 08 00 00       	call   80101a8c <ilock>
80101208:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010120b:	8b 45 08             	mov    0x8(%ebp),%eax
8010120e:	8b 40 10             	mov    0x10(%eax),%eax
80101211:	83 ec 08             	sub    $0x8,%esp
80101214:	ff 75 0c             	push   0xc(%ebp)
80101217:	50                   	push   %eax
80101218:	e8 2d 0d 00 00       	call   80101f4a <stati>
8010121d:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101220:	8b 45 08             	mov    0x8(%ebp),%eax
80101223:	8b 40 10             	mov    0x10(%eax),%eax
80101226:	83 ec 0c             	sub    $0xc,%esp
80101229:	50                   	push   %eax
8010122a:	e8 74 09 00 00       	call   80101ba3 <iunlock>
8010122f:	83 c4 10             	add    $0x10,%esp
    return 0;
80101232:	b8 00 00 00 00       	mov    $0x0,%eax
80101237:	eb 05                	jmp    8010123e <filestat+0x59>
  }
  return -1;
80101239:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010123e:	c9                   	leave
8010123f:	c3                   	ret

80101240 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101240:	f3 0f 1e fb          	endbr32
80101244:	55                   	push   %ebp
80101245:	89 e5                	mov    %esp,%ebp
80101247:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010124a:	8b 45 08             	mov    0x8(%ebp),%eax
8010124d:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101251:	84 c0                	test   %al,%al
80101253:	75 0a                	jne    8010125f <fileread+0x1f>
    return -1;
80101255:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010125a:	e9 9b 00 00 00       	jmp    801012fa <fileread+0xba>
  if(f->type == FD_PIPE)
8010125f:	8b 45 08             	mov    0x8(%ebp),%eax
80101262:	8b 00                	mov    (%eax),%eax
80101264:	83 f8 01             	cmp    $0x1,%eax
80101267:	75 1a                	jne    80101283 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101269:	8b 45 08             	mov    0x8(%ebp),%eax
8010126c:	8b 40 0c             	mov    0xc(%eax),%eax
8010126f:	83 ec 04             	sub    $0x4,%esp
80101272:	ff 75 10             	push   0x10(%ebp)
80101275:	ff 75 0c             	push   0xc(%ebp)
80101278:	50                   	push   %eax
80101279:	e8 67 27 00 00       	call   801039e5 <piperead>
8010127e:	83 c4 10             	add    $0x10,%esp
80101281:	eb 77                	jmp    801012fa <fileread+0xba>
  if(f->type == FD_INODE){
80101283:	8b 45 08             	mov    0x8(%ebp),%eax
80101286:	8b 00                	mov    (%eax),%eax
80101288:	83 f8 02             	cmp    $0x2,%eax
8010128b:	75 60                	jne    801012ed <fileread+0xad>
    ilock(f->ip);
8010128d:	8b 45 08             	mov    0x8(%ebp),%eax
80101290:	8b 40 10             	mov    0x10(%eax),%eax
80101293:	83 ec 0c             	sub    $0xc,%esp
80101296:	50                   	push   %eax
80101297:	e8 f0 07 00 00       	call   80101a8c <ilock>
8010129c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010129f:	8b 4d 10             	mov    0x10(%ebp),%ecx
801012a2:	8b 45 08             	mov    0x8(%ebp),%eax
801012a5:	8b 50 14             	mov    0x14(%eax),%edx
801012a8:	8b 45 08             	mov    0x8(%ebp),%eax
801012ab:	8b 40 10             	mov    0x10(%eax),%eax
801012ae:	51                   	push   %ecx
801012af:	52                   	push   %edx
801012b0:	ff 75 0c             	push   0xc(%ebp)
801012b3:	50                   	push   %eax
801012b4:	e8 db 0c 00 00       	call   80101f94 <readi>
801012b9:	83 c4 10             	add    $0x10,%esp
801012bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012c3:	7e 11                	jle    801012d6 <fileread+0x96>
      f->off += r;
801012c5:	8b 45 08             	mov    0x8(%ebp),%eax
801012c8:	8b 50 14             	mov    0x14(%eax),%edx
801012cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ce:	01 c2                	add    %eax,%edx
801012d0:	8b 45 08             	mov    0x8(%ebp),%eax
801012d3:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012d6:	8b 45 08             	mov    0x8(%ebp),%eax
801012d9:	8b 40 10             	mov    0x10(%eax),%eax
801012dc:	83 ec 0c             	sub    $0xc,%esp
801012df:	50                   	push   %eax
801012e0:	e8 be 08 00 00       	call   80101ba3 <iunlock>
801012e5:	83 c4 10             	add    $0x10,%esp
    return r;
801012e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012eb:	eb 0d                	jmp    801012fa <fileread+0xba>
  }
  panic("fileread");
801012ed:	83 ec 0c             	sub    $0xc,%esp
801012f0:	68 bb a6 10 80       	push   $0x8010a6bb
801012f5:	e8 e4 f2 ff ff       	call   801005de <panic>
}
801012fa:	c9                   	leave
801012fb:	c3                   	ret

801012fc <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012fc:	f3 0f 1e fb          	endbr32
80101300:	55                   	push   %ebp
80101301:	89 e5                	mov    %esp,%ebp
80101303:	53                   	push   %ebx
80101304:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101307:	8b 45 08             	mov    0x8(%ebp),%eax
8010130a:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010130e:	84 c0                	test   %al,%al
80101310:	75 0a                	jne    8010131c <filewrite+0x20>
    return -1;
80101312:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101317:	e9 1b 01 00 00       	jmp    80101437 <filewrite+0x13b>
  if(f->type == FD_PIPE)
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	8b 00                	mov    (%eax),%eax
80101321:	83 f8 01             	cmp    $0x1,%eax
80101324:	75 1d                	jne    80101343 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101326:	8b 45 08             	mov    0x8(%ebp),%eax
80101329:	8b 40 0c             	mov    0xc(%eax),%eax
8010132c:	83 ec 04             	sub    $0x4,%esp
8010132f:	ff 75 10             	push   0x10(%ebp)
80101332:	ff 75 0c             	push   0xc(%ebp)
80101335:	50                   	push   %eax
80101336:	e8 a4 25 00 00       	call   801038df <pipewrite>
8010133b:	83 c4 10             	add    $0x10,%esp
8010133e:	e9 f4 00 00 00       	jmp    80101437 <filewrite+0x13b>
  if(f->type == FD_INODE){
80101343:	8b 45 08             	mov    0x8(%ebp),%eax
80101346:	8b 00                	mov    (%eax),%eax
80101348:	83 f8 02             	cmp    $0x2,%eax
8010134b:	0f 85 d9 00 00 00    	jne    8010142a <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
80101351:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101358:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010135f:	e9 a3 00 00 00       	jmp    80101407 <filewrite+0x10b>
      int n1 = n - i;
80101364:	8b 45 10             	mov    0x10(%ebp),%eax
80101367:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010136a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010136d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101370:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101373:	7e 06                	jle    8010137b <filewrite+0x7f>
        n1 = max;
80101375:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101378:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010137b:	e8 01 1e 00 00       	call   80103181 <begin_op>
      ilock(f->ip);
80101380:	8b 45 08             	mov    0x8(%ebp),%eax
80101383:	8b 40 10             	mov    0x10(%eax),%eax
80101386:	83 ec 0c             	sub    $0xc,%esp
80101389:	50                   	push   %eax
8010138a:	e8 fd 06 00 00       	call   80101a8c <ilock>
8010138f:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101392:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101395:	8b 45 08             	mov    0x8(%ebp),%eax
80101398:	8b 50 14             	mov    0x14(%eax),%edx
8010139b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010139e:	8b 45 0c             	mov    0xc(%ebp),%eax
801013a1:	01 c3                	add    %eax,%ebx
801013a3:	8b 45 08             	mov    0x8(%ebp),%eax
801013a6:	8b 40 10             	mov    0x10(%eax),%eax
801013a9:	51                   	push   %ecx
801013aa:	52                   	push   %edx
801013ab:	53                   	push   %ebx
801013ac:	50                   	push   %eax
801013ad:	e8 3b 0d 00 00       	call   801020ed <writei>
801013b2:	83 c4 10             	add    $0x10,%esp
801013b5:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013bc:	7e 11                	jle    801013cf <filewrite+0xd3>
        f->off += r;
801013be:	8b 45 08             	mov    0x8(%ebp),%eax
801013c1:	8b 50 14             	mov    0x14(%eax),%edx
801013c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013c7:	01 c2                	add    %eax,%edx
801013c9:	8b 45 08             	mov    0x8(%ebp),%eax
801013cc:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013cf:	8b 45 08             	mov    0x8(%ebp),%eax
801013d2:	8b 40 10             	mov    0x10(%eax),%eax
801013d5:	83 ec 0c             	sub    $0xc,%esp
801013d8:	50                   	push   %eax
801013d9:	e8 c5 07 00 00       	call   80101ba3 <iunlock>
801013de:	83 c4 10             	add    $0x10,%esp
      end_op();
801013e1:	e8 2b 1e 00 00       	call   80103211 <end_op>

      if(r < 0)
801013e6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013ea:	78 29                	js     80101415 <filewrite+0x119>
        break;
      if(r != n1)
801013ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013ef:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013f2:	74 0d                	je     80101401 <filewrite+0x105>
        panic("short filewrite");
801013f4:	83 ec 0c             	sub    $0xc,%esp
801013f7:	68 c4 a6 10 80       	push   $0x8010a6c4
801013fc:	e8 dd f1 ff ff       	call   801005de <panic>
      i += r;
80101401:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101404:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010140a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010140d:	0f 8c 51 ff ff ff    	jl     80101364 <filewrite+0x68>
80101413:	eb 01                	jmp    80101416 <filewrite+0x11a>
        break;
80101415:	90                   	nop
    }
    return i == n ? n : -1;
80101416:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101419:	3b 45 10             	cmp    0x10(%ebp),%eax
8010141c:	75 05                	jne    80101423 <filewrite+0x127>
8010141e:	8b 45 10             	mov    0x10(%ebp),%eax
80101421:	eb 14                	jmp    80101437 <filewrite+0x13b>
80101423:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101428:	eb 0d                	jmp    80101437 <filewrite+0x13b>
  }
  panic("filewrite");
8010142a:	83 ec 0c             	sub    $0xc,%esp
8010142d:	68 d4 a6 10 80       	push   $0x8010a6d4
80101432:	e8 a7 f1 ff ff       	call   801005de <panic>
}
80101437:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010143a:	c9                   	leave
8010143b:	c3                   	ret

8010143c <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010143c:	f3 0f 1e fb          	endbr32
80101440:	55                   	push   %ebp
80101441:	89 e5                	mov    %esp,%ebp
80101443:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101446:	8b 45 08             	mov    0x8(%ebp),%eax
80101449:	83 ec 08             	sub    $0x8,%esp
8010144c:	6a 01                	push   $0x1
8010144e:	50                   	push   %eax
8010144f:	e8 b5 ed ff ff       	call   80100209 <bread>
80101454:	83 c4 10             	add    $0x10,%esp
80101457:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010145a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010145d:	83 c0 5c             	add    $0x5c,%eax
80101460:	83 ec 04             	sub    $0x4,%esp
80101463:	6a 1c                	push   $0x1c
80101465:	50                   	push   %eax
80101466:	ff 75 0c             	push   0xc(%ebp)
80101469:	e8 25 39 00 00       	call   80104d93 <memmove>
8010146e:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101471:	83 ec 0c             	sub    $0xc,%esp
80101474:	ff 75 f4             	push   -0xc(%ebp)
80101477:	e8 17 ee ff ff       	call   80100293 <brelse>
8010147c:	83 c4 10             	add    $0x10,%esp
}
8010147f:	90                   	nop
80101480:	c9                   	leave
80101481:	c3                   	ret

80101482 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101482:	f3 0f 1e fb          	endbr32
80101486:	55                   	push   %ebp
80101487:	89 e5                	mov    %esp,%ebp
80101489:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010148c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010148f:	8b 45 08             	mov    0x8(%ebp),%eax
80101492:	83 ec 08             	sub    $0x8,%esp
80101495:	52                   	push   %edx
80101496:	50                   	push   %eax
80101497:	e8 6d ed ff ff       	call   80100209 <bread>
8010149c:	83 c4 10             	add    $0x10,%esp
8010149f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801014a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014a5:	83 c0 5c             	add    $0x5c,%eax
801014a8:	83 ec 04             	sub    $0x4,%esp
801014ab:	68 00 02 00 00       	push   $0x200
801014b0:	6a 00                	push   $0x0
801014b2:	50                   	push   %eax
801014b3:	e8 14 38 00 00       	call   80104ccc <memset>
801014b8:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014bb:	83 ec 0c             	sub    $0xc,%esp
801014be:	ff 75 f4             	push   -0xc(%ebp)
801014c1:	e8 04 1f 00 00       	call   801033ca <log_write>
801014c6:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014c9:	83 ec 0c             	sub    $0xc,%esp
801014cc:	ff 75 f4             	push   -0xc(%ebp)
801014cf:	e8 bf ed ff ff       	call   80100293 <brelse>
801014d4:	83 c4 10             	add    $0x10,%esp
}
801014d7:	90                   	nop
801014d8:	c9                   	leave
801014d9:	c3                   	ret

801014da <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014da:	f3 0f 1e fb          	endbr32
801014de:	55                   	push   %ebp
801014df:	89 e5                	mov    %esp,%ebp
801014e1:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014e4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014f2:	e9 13 01 00 00       	jmp    8010160a <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801014f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014fa:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101500:	85 c0                	test   %eax,%eax
80101502:	0f 48 c2             	cmovs  %edx,%eax
80101505:	c1 f8 0c             	sar    $0xc,%eax
80101508:	89 c2                	mov    %eax,%edx
8010150a:	a1 78 37 19 80       	mov    0x80193778,%eax
8010150f:	01 d0                	add    %edx,%eax
80101511:	83 ec 08             	sub    $0x8,%esp
80101514:	50                   	push   %eax
80101515:	ff 75 08             	push   0x8(%ebp)
80101518:	e8 ec ec ff ff       	call   80100209 <bread>
8010151d:	83 c4 10             	add    $0x10,%esp
80101520:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101523:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010152a:	e9 a6 00 00 00       	jmp    801015d5 <balloc+0xfb>
      m = 1 << (bi % 8);
8010152f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101532:	99                   	cltd
80101533:	c1 ea 1d             	shr    $0x1d,%edx
80101536:	01 d0                	add    %edx,%eax
80101538:	83 e0 07             	and    $0x7,%eax
8010153b:	29 d0                	sub    %edx,%eax
8010153d:	ba 01 00 00 00       	mov    $0x1,%edx
80101542:	89 c1                	mov    %eax,%ecx
80101544:	d3 e2                	shl    %cl,%edx
80101546:	89 d0                	mov    %edx,%eax
80101548:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010154b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154e:	8d 50 07             	lea    0x7(%eax),%edx
80101551:	85 c0                	test   %eax,%eax
80101553:	0f 48 c2             	cmovs  %edx,%eax
80101556:	c1 f8 03             	sar    $0x3,%eax
80101559:	89 c2                	mov    %eax,%edx
8010155b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010155e:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101563:	0f b6 c0             	movzbl %al,%eax
80101566:	23 45 e8             	and    -0x18(%ebp),%eax
80101569:	85 c0                	test   %eax,%eax
8010156b:	75 64                	jne    801015d1 <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
8010156d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101570:	8d 50 07             	lea    0x7(%eax),%edx
80101573:	85 c0                	test   %eax,%eax
80101575:	0f 48 c2             	cmovs  %edx,%eax
80101578:	c1 f8 03             	sar    $0x3,%eax
8010157b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010157e:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101583:	89 d1                	mov    %edx,%ecx
80101585:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101588:	09 ca                	or     %ecx,%edx
8010158a:	89 d1                	mov    %edx,%ecx
8010158c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010158f:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101593:	83 ec 0c             	sub    $0xc,%esp
80101596:	ff 75 ec             	push   -0x14(%ebp)
80101599:	e8 2c 1e 00 00       	call   801033ca <log_write>
8010159e:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801015a1:	83 ec 0c             	sub    $0xc,%esp
801015a4:	ff 75 ec             	push   -0x14(%ebp)
801015a7:	e8 e7 ec ff ff       	call   80100293 <brelse>
801015ac:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801015af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b5:	01 c2                	add    %eax,%edx
801015b7:	8b 45 08             	mov    0x8(%ebp),%eax
801015ba:	83 ec 08             	sub    $0x8,%esp
801015bd:	52                   	push   %edx
801015be:	50                   	push   %eax
801015bf:	e8 be fe ff ff       	call   80101482 <bzero>
801015c4:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015cd:	01 d0                	add    %edx,%eax
801015cf:	eb 57                	jmp    80101628 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015d1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015d5:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015dc:	7f 17                	jg     801015f5 <balloc+0x11b>
801015de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e4:	01 d0                	add    %edx,%eax
801015e6:	89 c2                	mov    %eax,%edx
801015e8:	a1 60 37 19 80       	mov    0x80193760,%eax
801015ed:	39 c2                	cmp    %eax,%edx
801015ef:	0f 82 3a ff ff ff    	jb     8010152f <balloc+0x55>
      }
    }
    brelse(bp);
801015f5:	83 ec 0c             	sub    $0xc,%esp
801015f8:	ff 75 ec             	push   -0x14(%ebp)
801015fb:	e8 93 ec ff ff       	call   80100293 <brelse>
80101600:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101603:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010160a:	8b 15 60 37 19 80    	mov    0x80193760,%edx
80101610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101613:	39 c2                	cmp    %eax,%edx
80101615:	0f 87 dc fe ff ff    	ja     801014f7 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
8010161b:	83 ec 0c             	sub    $0xc,%esp
8010161e:	68 e0 a6 10 80       	push   $0x8010a6e0
80101623:	e8 b6 ef ff ff       	call   801005de <panic>
}
80101628:	c9                   	leave
80101629:	c3                   	ret

8010162a <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010162a:	f3 0f 1e fb          	endbr32
8010162e:	55                   	push   %ebp
8010162f:	89 e5                	mov    %esp,%ebp
80101631:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101634:	83 ec 08             	sub    $0x8,%esp
80101637:	68 60 37 19 80       	push   $0x80193760
8010163c:	ff 75 08             	push   0x8(%ebp)
8010163f:	e8 f8 fd ff ff       	call   8010143c <readsb>
80101644:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101647:	8b 45 0c             	mov    0xc(%ebp),%eax
8010164a:	c1 e8 0c             	shr    $0xc,%eax
8010164d:	89 c2                	mov    %eax,%edx
8010164f:	a1 78 37 19 80       	mov    0x80193778,%eax
80101654:	01 c2                	add    %eax,%edx
80101656:	8b 45 08             	mov    0x8(%ebp),%eax
80101659:	83 ec 08             	sub    $0x8,%esp
8010165c:	52                   	push   %edx
8010165d:	50                   	push   %eax
8010165e:	e8 a6 eb ff ff       	call   80100209 <bread>
80101663:	83 c4 10             	add    $0x10,%esp
80101666:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101669:	8b 45 0c             	mov    0xc(%ebp),%eax
8010166c:	25 ff 0f 00 00       	and    $0xfff,%eax
80101671:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101674:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101677:	99                   	cltd
80101678:	c1 ea 1d             	shr    $0x1d,%edx
8010167b:	01 d0                	add    %edx,%eax
8010167d:	83 e0 07             	and    $0x7,%eax
80101680:	29 d0                	sub    %edx,%eax
80101682:	ba 01 00 00 00       	mov    $0x1,%edx
80101687:	89 c1                	mov    %eax,%ecx
80101689:	d3 e2                	shl    %cl,%edx
8010168b:	89 d0                	mov    %edx,%eax
8010168d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101690:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101693:	8d 50 07             	lea    0x7(%eax),%edx
80101696:	85 c0                	test   %eax,%eax
80101698:	0f 48 c2             	cmovs  %edx,%eax
8010169b:	c1 f8 03             	sar    $0x3,%eax
8010169e:	89 c2                	mov    %eax,%edx
801016a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016a3:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801016a8:	0f b6 c0             	movzbl %al,%eax
801016ab:	23 45 ec             	and    -0x14(%ebp),%eax
801016ae:	85 c0                	test   %eax,%eax
801016b0:	75 0d                	jne    801016bf <bfree+0x95>
    panic("freeing free block");
801016b2:	83 ec 0c             	sub    $0xc,%esp
801016b5:	68 f6 a6 10 80       	push   $0x8010a6f6
801016ba:	e8 1f ef ff ff       	call   801005de <panic>
  bp->data[bi/8] &= ~m;
801016bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c2:	8d 50 07             	lea    0x7(%eax),%edx
801016c5:	85 c0                	test   %eax,%eax
801016c7:	0f 48 c2             	cmovs  %edx,%eax
801016ca:	c1 f8 03             	sar    $0x3,%eax
801016cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016d0:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801016d5:	89 d1                	mov    %edx,%ecx
801016d7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016da:	f7 d2                	not    %edx
801016dc:	21 ca                	and    %ecx,%edx
801016de:	89 d1                	mov    %edx,%ecx
801016e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016e3:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801016e7:	83 ec 0c             	sub    $0xc,%esp
801016ea:	ff 75 f4             	push   -0xc(%ebp)
801016ed:	e8 d8 1c 00 00       	call   801033ca <log_write>
801016f2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016f5:	83 ec 0c             	sub    $0xc,%esp
801016f8:	ff 75 f4             	push   -0xc(%ebp)
801016fb:	e8 93 eb ff ff       	call   80100293 <brelse>
80101700:	83 c4 10             	add    $0x10,%esp
}
80101703:	90                   	nop
80101704:	c9                   	leave
80101705:	c3                   	ret

80101706 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101706:	f3 0f 1e fb          	endbr32
8010170a:	55                   	push   %ebp
8010170b:	89 e5                	mov    %esp,%ebp
8010170d:	57                   	push   %edi
8010170e:	56                   	push   %esi
8010170f:	53                   	push   %ebx
80101710:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101713:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
8010171a:	83 ec 08             	sub    $0x8,%esp
8010171d:	68 09 a7 10 80       	push   $0x8010a709
80101722:	68 80 37 19 80       	push   $0x80193780
80101727:	e8 eb 32 00 00       	call   80104a17 <initlock>
8010172c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010172f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101736:	eb 2d                	jmp    80101765 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
80101738:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010173b:	89 d0                	mov    %edx,%eax
8010173d:	c1 e0 03             	shl    $0x3,%eax
80101740:	01 d0                	add    %edx,%eax
80101742:	c1 e0 04             	shl    $0x4,%eax
80101745:	83 c0 30             	add    $0x30,%eax
80101748:	05 80 37 19 80       	add    $0x80193780,%eax
8010174d:	83 c0 10             	add    $0x10,%eax
80101750:	83 ec 08             	sub    $0x8,%esp
80101753:	68 10 a7 10 80       	push   $0x8010a710
80101758:	50                   	push   %eax
80101759:	e8 4c 31 00 00       	call   801048aa <initsleeplock>
8010175e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101761:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101765:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101769:	7e cd                	jle    80101738 <iinit+0x32>
  }

  readsb(dev, &sb);
8010176b:	83 ec 08             	sub    $0x8,%esp
8010176e:	68 60 37 19 80       	push   $0x80193760
80101773:	ff 75 08             	push   0x8(%ebp)
80101776:	e8 c1 fc ff ff       	call   8010143c <readsb>
8010177b:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010177e:	a1 78 37 19 80       	mov    0x80193778,%eax
80101783:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101786:	8b 3d 74 37 19 80    	mov    0x80193774,%edi
8010178c:	8b 35 70 37 19 80    	mov    0x80193770,%esi
80101792:	8b 1d 6c 37 19 80    	mov    0x8019376c,%ebx
80101798:	8b 0d 68 37 19 80    	mov    0x80193768,%ecx
8010179e:	8b 15 64 37 19 80    	mov    0x80193764,%edx
801017a4:	a1 60 37 19 80       	mov    0x80193760,%eax
801017a9:	ff 75 d4             	push   -0x2c(%ebp)
801017ac:	57                   	push   %edi
801017ad:	56                   	push   %esi
801017ae:	53                   	push   %ebx
801017af:	51                   	push   %ecx
801017b0:	52                   	push   %edx
801017b1:	50                   	push   %eax
801017b2:	68 18 a7 10 80       	push   $0x8010a718
801017b7:	e8 50 ec ff ff       	call   8010040c <cprintf>
801017bc:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801017bf:	90                   	nop
801017c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017c3:	5b                   	pop    %ebx
801017c4:	5e                   	pop    %esi
801017c5:	5f                   	pop    %edi
801017c6:	5d                   	pop    %ebp
801017c7:	c3                   	ret

801017c8 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801017c8:	f3 0f 1e fb          	endbr32
801017cc:	55                   	push   %ebp
801017cd:	89 e5                	mov    %esp,%ebp
801017cf:	83 ec 28             	sub    $0x28,%esp
801017d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801017d5:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017d9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017e0:	e9 9e 00 00 00       	jmp    80101883 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
801017e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e8:	c1 e8 03             	shr    $0x3,%eax
801017eb:	89 c2                	mov    %eax,%edx
801017ed:	a1 74 37 19 80       	mov    0x80193774,%eax
801017f2:	01 d0                	add    %edx,%eax
801017f4:	83 ec 08             	sub    $0x8,%esp
801017f7:	50                   	push   %eax
801017f8:	ff 75 08             	push   0x8(%ebp)
801017fb:	e8 09 ea ff ff       	call   80100209 <bread>
80101800:	83 c4 10             	add    $0x10,%esp
80101803:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101806:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101809:	8d 50 5c             	lea    0x5c(%eax),%edx
8010180c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180f:	83 e0 07             	and    $0x7,%eax
80101812:	c1 e0 06             	shl    $0x6,%eax
80101815:	01 d0                	add    %edx,%eax
80101817:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010181a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010181d:	0f b7 00             	movzwl (%eax),%eax
80101820:	66 85 c0             	test   %ax,%ax
80101823:	75 4c                	jne    80101871 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
80101825:	83 ec 04             	sub    $0x4,%esp
80101828:	6a 40                	push   $0x40
8010182a:	6a 00                	push   $0x0
8010182c:	ff 75 ec             	push   -0x14(%ebp)
8010182f:	e8 98 34 00 00       	call   80104ccc <memset>
80101834:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101837:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010183a:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010183e:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101841:	83 ec 0c             	sub    $0xc,%esp
80101844:	ff 75 f0             	push   -0x10(%ebp)
80101847:	e8 7e 1b 00 00       	call   801033ca <log_write>
8010184c:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010184f:	83 ec 0c             	sub    $0xc,%esp
80101852:	ff 75 f0             	push   -0x10(%ebp)
80101855:	e8 39 ea ff ff       	call   80100293 <brelse>
8010185a:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010185d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101860:	83 ec 08             	sub    $0x8,%esp
80101863:	50                   	push   %eax
80101864:	ff 75 08             	push   0x8(%ebp)
80101867:	e8 fc 00 00 00       	call   80101968 <iget>
8010186c:	83 c4 10             	add    $0x10,%esp
8010186f:	eb 30                	jmp    801018a1 <ialloc+0xd9>
    }
    brelse(bp);
80101871:	83 ec 0c             	sub    $0xc,%esp
80101874:	ff 75 f0             	push   -0x10(%ebp)
80101877:	e8 17 ea ff ff       	call   80100293 <brelse>
8010187c:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
8010187f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101883:	8b 15 68 37 19 80    	mov    0x80193768,%edx
80101889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188c:	39 c2                	cmp    %eax,%edx
8010188e:	0f 87 51 ff ff ff    	ja     801017e5 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101894:	83 ec 0c             	sub    $0xc,%esp
80101897:	68 6b a7 10 80       	push   $0x8010a76b
8010189c:	e8 3d ed ff ff       	call   801005de <panic>
}
801018a1:	c9                   	leave
801018a2:	c3                   	ret

801018a3 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801018a3:	f3 0f 1e fb          	endbr32
801018a7:	55                   	push   %ebp
801018a8:	89 e5                	mov    %esp,%ebp
801018aa:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018ad:	8b 45 08             	mov    0x8(%ebp),%eax
801018b0:	8b 40 04             	mov    0x4(%eax),%eax
801018b3:	c1 e8 03             	shr    $0x3,%eax
801018b6:	89 c2                	mov    %eax,%edx
801018b8:	a1 74 37 19 80       	mov    0x80193774,%eax
801018bd:	01 c2                	add    %eax,%edx
801018bf:	8b 45 08             	mov    0x8(%ebp),%eax
801018c2:	8b 00                	mov    (%eax),%eax
801018c4:	83 ec 08             	sub    $0x8,%esp
801018c7:	52                   	push   %edx
801018c8:	50                   	push   %eax
801018c9:	e8 3b e9 ff ff       	call   80100209 <bread>
801018ce:	83 c4 10             	add    $0x10,%esp
801018d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801018d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d7:	8d 50 5c             	lea    0x5c(%eax),%edx
801018da:	8b 45 08             	mov    0x8(%ebp),%eax
801018dd:	8b 40 04             	mov    0x4(%eax),%eax
801018e0:	83 e0 07             	and    $0x7,%eax
801018e3:	c1 e0 06             	shl    $0x6,%eax
801018e6:	01 d0                	add    %edx,%eax
801018e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801018eb:	8b 45 08             	mov    0x8(%ebp),%eax
801018ee:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801018f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f5:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801018f8:	8b 45 08             	mov    0x8(%ebp),%eax
801018fb:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801018ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101902:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101906:	8b 45 08             	mov    0x8(%ebp),%eax
80101909:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010190d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101910:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101914:	8b 45 08             	mov    0x8(%ebp),%eax
80101917:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010191b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010191e:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101922:	8b 45 08             	mov    0x8(%ebp),%eax
80101925:	8b 50 58             	mov    0x58(%eax),%edx
80101928:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010192b:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010192e:	8b 45 08             	mov    0x8(%ebp),%eax
80101931:	8d 50 5c             	lea    0x5c(%eax),%edx
80101934:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101937:	83 c0 0c             	add    $0xc,%eax
8010193a:	83 ec 04             	sub    $0x4,%esp
8010193d:	6a 34                	push   $0x34
8010193f:	52                   	push   %edx
80101940:	50                   	push   %eax
80101941:	e8 4d 34 00 00       	call   80104d93 <memmove>
80101946:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101949:	83 ec 0c             	sub    $0xc,%esp
8010194c:	ff 75 f4             	push   -0xc(%ebp)
8010194f:	e8 76 1a 00 00       	call   801033ca <log_write>
80101954:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101957:	83 ec 0c             	sub    $0xc,%esp
8010195a:	ff 75 f4             	push   -0xc(%ebp)
8010195d:	e8 31 e9 ff ff       	call   80100293 <brelse>
80101962:	83 c4 10             	add    $0x10,%esp
}
80101965:	90                   	nop
80101966:	c9                   	leave
80101967:	c3                   	ret

80101968 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101968:	f3 0f 1e fb          	endbr32
8010196c:	55                   	push   %ebp
8010196d:	89 e5                	mov    %esp,%ebp
8010196f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101972:	83 ec 0c             	sub    $0xc,%esp
80101975:	68 80 37 19 80       	push   $0x80193780
8010197a:	e8 be 30 00 00       	call   80104a3d <acquire>
8010197f:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101982:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101989:	c7 45 f4 b4 37 19 80 	movl   $0x801937b4,-0xc(%ebp)
80101990:	eb 60                	jmp    801019f2 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101995:	8b 40 08             	mov    0x8(%eax),%eax
80101998:	85 c0                	test   %eax,%eax
8010199a:	7e 39                	jle    801019d5 <iget+0x6d>
8010199c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199f:	8b 00                	mov    (%eax),%eax
801019a1:	39 45 08             	cmp    %eax,0x8(%ebp)
801019a4:	75 2f                	jne    801019d5 <iget+0x6d>
801019a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a9:	8b 40 04             	mov    0x4(%eax),%eax
801019ac:	39 45 0c             	cmp    %eax,0xc(%ebp)
801019af:	75 24                	jne    801019d5 <iget+0x6d>
      ip->ref++;
801019b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b4:	8b 40 08             	mov    0x8(%eax),%eax
801019b7:	8d 50 01             	lea    0x1(%eax),%edx
801019ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019bd:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801019c0:	83 ec 0c             	sub    $0xc,%esp
801019c3:	68 80 37 19 80       	push   $0x80193780
801019c8:	e8 e2 30 00 00       	call   80104aaf <release>
801019cd:	83 c4 10             	add    $0x10,%esp
      return ip;
801019d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d3:	eb 77                	jmp    80101a4c <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801019d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019d9:	75 10                	jne    801019eb <iget+0x83>
801019db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019de:	8b 40 08             	mov    0x8(%eax),%eax
801019e1:	85 c0                	test   %eax,%eax
801019e3:	75 06                	jne    801019eb <iget+0x83>
      empty = ip;
801019e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019eb:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801019f2:	81 7d f4 d4 53 19 80 	cmpl   $0x801953d4,-0xc(%ebp)
801019f9:	72 97                	jb     80101992 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019ff:	75 0d                	jne    80101a0e <iget+0xa6>
    panic("iget: no inodes");
80101a01:	83 ec 0c             	sub    $0xc,%esp
80101a04:	68 7d a7 10 80       	push   $0x8010a77d
80101a09:	e8 d0 eb ff ff       	call   801005de <panic>

  ip = empty;
80101a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a17:	8b 55 08             	mov    0x8(%ebp),%edx
80101a1a:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a22:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a28:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a32:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a39:	83 ec 0c             	sub    $0xc,%esp
80101a3c:	68 80 37 19 80       	push   $0x80193780
80101a41:	e8 69 30 00 00       	call   80104aaf <release>
80101a46:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a4c:	c9                   	leave
80101a4d:	c3                   	ret

80101a4e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a4e:	f3 0f 1e fb          	endbr32
80101a52:	55                   	push   %ebp
80101a53:	89 e5                	mov    %esp,%ebp
80101a55:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a58:	83 ec 0c             	sub    $0xc,%esp
80101a5b:	68 80 37 19 80       	push   $0x80193780
80101a60:	e8 d8 2f 00 00       	call   80104a3d <acquire>
80101a65:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a68:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6b:	8b 40 08             	mov    0x8(%eax),%eax
80101a6e:	8d 50 01             	lea    0x1(%eax),%edx
80101a71:	8b 45 08             	mov    0x8(%ebp),%eax
80101a74:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a77:	83 ec 0c             	sub    $0xc,%esp
80101a7a:	68 80 37 19 80       	push   $0x80193780
80101a7f:	e8 2b 30 00 00       	call   80104aaf <release>
80101a84:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a87:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a8a:	c9                   	leave
80101a8b:	c3                   	ret

80101a8c <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a8c:	f3 0f 1e fb          	endbr32
80101a90:	55                   	push   %ebp
80101a91:	89 e5                	mov    %esp,%ebp
80101a93:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a96:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a9a:	74 0a                	je     80101aa6 <ilock+0x1a>
80101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9f:	8b 40 08             	mov    0x8(%eax),%eax
80101aa2:	85 c0                	test   %eax,%eax
80101aa4:	7f 0d                	jg     80101ab3 <ilock+0x27>
    panic("ilock");
80101aa6:	83 ec 0c             	sub    $0xc,%esp
80101aa9:	68 8d a7 10 80       	push   $0x8010a78d
80101aae:	e8 2b eb ff ff       	call   801005de <panic>

  acquiresleep(&ip->lock);
80101ab3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab6:	83 c0 0c             	add    $0xc,%eax
80101ab9:	83 ec 0c             	sub    $0xc,%esp
80101abc:	50                   	push   %eax
80101abd:	e8 28 2e 00 00       	call   801048ea <acquiresleep>
80101ac2:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101ac5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac8:	8b 40 4c             	mov    0x4c(%eax),%eax
80101acb:	85 c0                	test   %eax,%eax
80101acd:	0f 85 cd 00 00 00    	jne    80101ba0 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad6:	8b 40 04             	mov    0x4(%eax),%eax
80101ad9:	c1 e8 03             	shr    $0x3,%eax
80101adc:	89 c2                	mov    %eax,%edx
80101ade:	a1 74 37 19 80       	mov    0x80193774,%eax
80101ae3:	01 c2                	add    %eax,%edx
80101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae8:	8b 00                	mov    (%eax),%eax
80101aea:	83 ec 08             	sub    $0x8,%esp
80101aed:	52                   	push   %edx
80101aee:	50                   	push   %eax
80101aef:	e8 15 e7 ff ff       	call   80100209 <bread>
80101af4:	83 c4 10             	add    $0x10,%esp
80101af7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101afd:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b00:	8b 45 08             	mov    0x8(%ebp),%eax
80101b03:	8b 40 04             	mov    0x4(%eax),%eax
80101b06:	83 e0 07             	and    $0x7,%eax
80101b09:	c1 e0 06             	shl    $0x6,%eax
80101b0c:	01 d0                	add    %edx,%eax
80101b0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b14:	0f b7 10             	movzwl (%eax),%edx
80101b17:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1a:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b21:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b25:	8b 45 08             	mov    0x8(%ebp),%eax
80101b28:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b2f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b33:	8b 45 08             	mov    0x8(%ebp),%eax
80101b36:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b3d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b41:	8b 45 08             	mov    0x8(%ebp),%eax
80101b44:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b4b:	8b 50 08             	mov    0x8(%eax),%edx
80101b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b51:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b57:	8d 50 0c             	lea    0xc(%eax),%edx
80101b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5d:	83 c0 5c             	add    $0x5c,%eax
80101b60:	83 ec 04             	sub    $0x4,%esp
80101b63:	6a 34                	push   $0x34
80101b65:	52                   	push   %edx
80101b66:	50                   	push   %eax
80101b67:	e8 27 32 00 00       	call   80104d93 <memmove>
80101b6c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b6f:	83 ec 0c             	sub    $0xc,%esp
80101b72:	ff 75 f4             	push   -0xc(%ebp)
80101b75:	e8 19 e7 ff ff       	call   80100293 <brelse>
80101b7a:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b80:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b87:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101b8e:	66 85 c0             	test   %ax,%ax
80101b91:	75 0d                	jne    80101ba0 <ilock+0x114>
      panic("ilock: no type");
80101b93:	83 ec 0c             	sub    $0xc,%esp
80101b96:	68 93 a7 10 80       	push   $0x8010a793
80101b9b:	e8 3e ea ff ff       	call   801005de <panic>
  }
}
80101ba0:	90                   	nop
80101ba1:	c9                   	leave
80101ba2:	c3                   	ret

80101ba3 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ba3:	f3 0f 1e fb          	endbr32
80101ba7:	55                   	push   %ebp
80101ba8:	89 e5                	mov    %esp,%ebp
80101baa:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101bad:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bb1:	74 20                	je     80101bd3 <iunlock+0x30>
80101bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb6:	83 c0 0c             	add    $0xc,%eax
80101bb9:	83 ec 0c             	sub    $0xc,%esp
80101bbc:	50                   	push   %eax
80101bbd:	e8 e2 2d 00 00       	call   801049a4 <holdingsleep>
80101bc2:	83 c4 10             	add    $0x10,%esp
80101bc5:	85 c0                	test   %eax,%eax
80101bc7:	74 0a                	je     80101bd3 <iunlock+0x30>
80101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcc:	8b 40 08             	mov    0x8(%eax),%eax
80101bcf:	85 c0                	test   %eax,%eax
80101bd1:	7f 0d                	jg     80101be0 <iunlock+0x3d>
    panic("iunlock");
80101bd3:	83 ec 0c             	sub    $0xc,%esp
80101bd6:	68 a2 a7 10 80       	push   $0x8010a7a2
80101bdb:	e8 fe e9 ff ff       	call   801005de <panic>

  releasesleep(&ip->lock);
80101be0:	8b 45 08             	mov    0x8(%ebp),%eax
80101be3:	83 c0 0c             	add    $0xc,%eax
80101be6:	83 ec 0c             	sub    $0xc,%esp
80101be9:	50                   	push   %eax
80101bea:	e8 63 2d 00 00       	call   80104952 <releasesleep>
80101bef:	83 c4 10             	add    $0x10,%esp
}
80101bf2:	90                   	nop
80101bf3:	c9                   	leave
80101bf4:	c3                   	ret

80101bf5 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101bf5:	f3 0f 1e fb          	endbr32
80101bf9:	55                   	push   %ebp
80101bfa:	89 e5                	mov    %esp,%ebp
80101bfc:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101bff:	8b 45 08             	mov    0x8(%ebp),%eax
80101c02:	83 c0 0c             	add    $0xc,%eax
80101c05:	83 ec 0c             	sub    $0xc,%esp
80101c08:	50                   	push   %eax
80101c09:	e8 dc 2c 00 00       	call   801048ea <acquiresleep>
80101c0e:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c11:	8b 45 08             	mov    0x8(%ebp),%eax
80101c14:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c17:	85 c0                	test   %eax,%eax
80101c19:	74 6a                	je     80101c85 <iput+0x90>
80101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c22:	66 85 c0             	test   %ax,%ax
80101c25:	75 5e                	jne    80101c85 <iput+0x90>
    acquire(&icache.lock);
80101c27:	83 ec 0c             	sub    $0xc,%esp
80101c2a:	68 80 37 19 80       	push   $0x80193780
80101c2f:	e8 09 2e 00 00       	call   80104a3d <acquire>
80101c34:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c37:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3a:	8b 40 08             	mov    0x8(%eax),%eax
80101c3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c40:	83 ec 0c             	sub    $0xc,%esp
80101c43:	68 80 37 19 80       	push   $0x80193780
80101c48:	e8 62 2e 00 00       	call   80104aaf <release>
80101c4d:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c50:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c54:	75 2f                	jne    80101c85 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c56:	83 ec 0c             	sub    $0xc,%esp
80101c59:	ff 75 08             	push   0x8(%ebp)
80101c5c:	e8 b5 01 00 00       	call   80101e16 <itrunc>
80101c61:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101c64:	8b 45 08             	mov    0x8(%ebp),%eax
80101c67:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c6d:	83 ec 0c             	sub    $0xc,%esp
80101c70:	ff 75 08             	push   0x8(%ebp)
80101c73:	e8 2b fc ff ff       	call   801018a3 <iupdate>
80101c78:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c85:	8b 45 08             	mov    0x8(%ebp),%eax
80101c88:	83 c0 0c             	add    $0xc,%eax
80101c8b:	83 ec 0c             	sub    $0xc,%esp
80101c8e:	50                   	push   %eax
80101c8f:	e8 be 2c 00 00       	call   80104952 <releasesleep>
80101c94:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c97:	83 ec 0c             	sub    $0xc,%esp
80101c9a:	68 80 37 19 80       	push   $0x80193780
80101c9f:	e8 99 2d 00 00       	call   80104a3d <acquire>
80101ca4:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101ca7:	8b 45 08             	mov    0x8(%ebp),%eax
80101caa:	8b 40 08             	mov    0x8(%eax),%eax
80101cad:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cb6:	83 ec 0c             	sub    $0xc,%esp
80101cb9:	68 80 37 19 80       	push   $0x80193780
80101cbe:	e8 ec 2d 00 00       	call   80104aaf <release>
80101cc3:	83 c4 10             	add    $0x10,%esp
}
80101cc6:	90                   	nop
80101cc7:	c9                   	leave
80101cc8:	c3                   	ret

80101cc9 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cc9:	f3 0f 1e fb          	endbr32
80101ccd:	55                   	push   %ebp
80101cce:	89 e5                	mov    %esp,%ebp
80101cd0:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101cd3:	83 ec 0c             	sub    $0xc,%esp
80101cd6:	ff 75 08             	push   0x8(%ebp)
80101cd9:	e8 c5 fe ff ff       	call   80101ba3 <iunlock>
80101cde:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101ce1:	83 ec 0c             	sub    $0xc,%esp
80101ce4:	ff 75 08             	push   0x8(%ebp)
80101ce7:	e8 09 ff ff ff       	call   80101bf5 <iput>
80101cec:	83 c4 10             	add    $0x10,%esp
}
80101cef:	90                   	nop
80101cf0:	c9                   	leave
80101cf1:	c3                   	ret

80101cf2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101cf2:	f3 0f 1e fb          	endbr32
80101cf6:	55                   	push   %ebp
80101cf7:	89 e5                	mov    %esp,%ebp
80101cf9:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cfc:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d00:	77 42                	ja     80101d44 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101d02:	8b 45 08             	mov    0x8(%ebp),%eax
80101d05:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d08:	83 c2 14             	add    $0x14,%edx
80101d0b:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d16:	75 24                	jne    80101d3c <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d18:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1b:	8b 00                	mov    (%eax),%eax
80101d1d:	83 ec 0c             	sub    $0xc,%esp
80101d20:	50                   	push   %eax
80101d21:	e8 b4 f7 ff ff       	call   801014da <balloc>
80101d26:	83 c4 10             	add    $0x10,%esp
80101d29:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d32:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d35:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d38:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d3f:	e9 d0 00 00 00       	jmp    80101e14 <bmap+0x122>
  }
  bn -= NDIRECT;
80101d44:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d48:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d4c:	0f 87 b5 00 00 00    	ja     80101e07 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d52:	8b 45 08             	mov    0x8(%ebp),%eax
80101d55:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d5e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d62:	75 20                	jne    80101d84 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d64:	8b 45 08             	mov    0x8(%ebp),%eax
80101d67:	8b 00                	mov    (%eax),%eax
80101d69:	83 ec 0c             	sub    $0xc,%esp
80101d6c:	50                   	push   %eax
80101d6d:	e8 68 f7 ff ff       	call   801014da <balloc>
80101d72:	83 c4 10             	add    $0x10,%esp
80101d75:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d78:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d7e:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d84:	8b 45 08             	mov    0x8(%ebp),%eax
80101d87:	8b 00                	mov    (%eax),%eax
80101d89:	83 ec 08             	sub    $0x8,%esp
80101d8c:	ff 75 f4             	push   -0xc(%ebp)
80101d8f:	50                   	push   %eax
80101d90:	e8 74 e4 ff ff       	call   80100209 <bread>
80101d95:	83 c4 10             	add    $0x10,%esp
80101d98:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d9e:	83 c0 5c             	add    $0x5c,%eax
80101da1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101da4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101da7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101db1:	01 d0                	add    %edx,%eax
80101db3:	8b 00                	mov    (%eax),%eax
80101db5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101db8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dbc:	75 36                	jne    80101df4 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc1:	8b 00                	mov    (%eax),%eax
80101dc3:	83 ec 0c             	sub    $0xc,%esp
80101dc6:	50                   	push   %eax
80101dc7:	e8 0e f7 ff ff       	call   801014da <balloc>
80101dcc:	83 c4 10             	add    $0x10,%esp
80101dcf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dd5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ddc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ddf:	01 c2                	add    %eax,%edx
80101de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101de4:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101de6:	83 ec 0c             	sub    $0xc,%esp
80101de9:	ff 75 f0             	push   -0x10(%ebp)
80101dec:	e8 d9 15 00 00       	call   801033ca <log_write>
80101df1:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101df4:	83 ec 0c             	sub    $0xc,%esp
80101df7:	ff 75 f0             	push   -0x10(%ebp)
80101dfa:	e8 94 e4 ff ff       	call   80100293 <brelse>
80101dff:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e05:	eb 0d                	jmp    80101e14 <bmap+0x122>
  }

  panic("bmap: out of range");
80101e07:	83 ec 0c             	sub    $0xc,%esp
80101e0a:	68 aa a7 10 80       	push   $0x8010a7aa
80101e0f:	e8 ca e7 ff ff       	call   801005de <panic>
}
80101e14:	c9                   	leave
80101e15:	c3                   	ret

80101e16 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e16:	f3 0f 1e fb          	endbr32
80101e1a:	55                   	push   %ebp
80101e1b:	89 e5                	mov    %esp,%ebp
80101e1d:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e27:	eb 45                	jmp    80101e6e <itrunc+0x58>
    if(ip->addrs[i]){
80101e29:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e2f:	83 c2 14             	add    $0x14,%edx
80101e32:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e36:	85 c0                	test   %eax,%eax
80101e38:	74 30                	je     80101e6a <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101e3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e40:	83 c2 14             	add    $0x14,%edx
80101e43:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e47:	8b 55 08             	mov    0x8(%ebp),%edx
80101e4a:	8b 12                	mov    (%edx),%edx
80101e4c:	83 ec 08             	sub    $0x8,%esp
80101e4f:	50                   	push   %eax
80101e50:	52                   	push   %edx
80101e51:	e8 d4 f7 ff ff       	call   8010162a <bfree>
80101e56:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e59:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e5f:	83 c2 14             	add    $0x14,%edx
80101e62:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e69:	00 
  for(i = 0; i < NDIRECT; i++){
80101e6a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e6e:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e72:	7e b5                	jle    80101e29 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101e74:	8b 45 08             	mov    0x8(%ebp),%eax
80101e77:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e7d:	85 c0                	test   %eax,%eax
80101e7f:	0f 84 aa 00 00 00    	je     80101f2f <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e85:	8b 45 08             	mov    0x8(%ebp),%eax
80101e88:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e91:	8b 00                	mov    (%eax),%eax
80101e93:	83 ec 08             	sub    $0x8,%esp
80101e96:	52                   	push   %edx
80101e97:	50                   	push   %eax
80101e98:	e8 6c e3 ff ff       	call   80100209 <bread>
80101e9d:	83 c4 10             	add    $0x10,%esp
80101ea0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101ea3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ea6:	83 c0 5c             	add    $0x5c,%eax
80101ea9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101eac:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101eb3:	eb 3c                	jmp    80101ef1 <itrunc+0xdb>
      if(a[j])
80101eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eb8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ebf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ec2:	01 d0                	add    %edx,%eax
80101ec4:	8b 00                	mov    (%eax),%eax
80101ec6:	85 c0                	test   %eax,%eax
80101ec8:	74 23                	je     80101eed <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101eca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ecd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ed4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ed7:	01 d0                	add    %edx,%eax
80101ed9:	8b 00                	mov    (%eax),%eax
80101edb:	8b 55 08             	mov    0x8(%ebp),%edx
80101ede:	8b 12                	mov    (%edx),%edx
80101ee0:	83 ec 08             	sub    $0x8,%esp
80101ee3:	50                   	push   %eax
80101ee4:	52                   	push   %edx
80101ee5:	e8 40 f7 ff ff       	call   8010162a <bfree>
80101eea:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101eed:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ef1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ef4:	83 f8 7f             	cmp    $0x7f,%eax
80101ef7:	76 bc                	jbe    80101eb5 <itrunc+0x9f>
    }
    brelse(bp);
80101ef9:	83 ec 0c             	sub    $0xc,%esp
80101efc:	ff 75 ec             	push   -0x14(%ebp)
80101eff:	e8 8f e3 ff ff       	call   80100293 <brelse>
80101f04:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f07:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0a:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f10:	8b 55 08             	mov    0x8(%ebp),%edx
80101f13:	8b 12                	mov    (%edx),%edx
80101f15:	83 ec 08             	sub    $0x8,%esp
80101f18:	50                   	push   %eax
80101f19:	52                   	push   %edx
80101f1a:	e8 0b f7 ff ff       	call   8010162a <bfree>
80101f1f:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f22:	8b 45 08             	mov    0x8(%ebp),%eax
80101f25:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f2c:	00 00 00 
  }

  ip->size = 0;
80101f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f32:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f39:	83 ec 0c             	sub    $0xc,%esp
80101f3c:	ff 75 08             	push   0x8(%ebp)
80101f3f:	e8 5f f9 ff ff       	call   801018a3 <iupdate>
80101f44:	83 c4 10             	add    $0x10,%esp
}
80101f47:	90                   	nop
80101f48:	c9                   	leave
80101f49:	c3                   	ret

80101f4a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f4a:	f3 0f 1e fb          	endbr32
80101f4e:	55                   	push   %ebp
80101f4f:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f51:	8b 45 08             	mov    0x8(%ebp),%eax
80101f54:	8b 00                	mov    (%eax),%eax
80101f56:	89 c2                	mov    %eax,%edx
80101f58:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f5b:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f61:	8b 50 04             	mov    0x4(%eax),%edx
80101f64:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f67:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6d:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101f71:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f74:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f77:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7a:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101f7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f81:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f85:	8b 45 08             	mov    0x8(%ebp),%eax
80101f88:	8b 50 58             	mov    0x58(%eax),%edx
80101f8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f8e:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f91:	90                   	nop
80101f92:	5d                   	pop    %ebp
80101f93:	c3                   	ret

80101f94 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f94:	f3 0f 1e fb          	endbr32
80101f98:	55                   	push   %ebp
80101f99:	89 e5                	mov    %esp,%ebp
80101f9b:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101fa5:	66 83 f8 03          	cmp    $0x3,%ax
80101fa9:	75 5c                	jne    80102007 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101fab:	8b 45 08             	mov    0x8(%ebp),%eax
80101fae:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fb2:	66 85 c0             	test   %ax,%ax
80101fb5:	78 20                	js     80101fd7 <readi+0x43>
80101fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80101fba:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fbe:	66 83 f8 09          	cmp    $0x9,%ax
80101fc2:	7f 13                	jg     80101fd7 <readi+0x43>
80101fc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fcb:	98                   	cwtl
80101fcc:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80101fd3:	85 c0                	test   %eax,%eax
80101fd5:	75 0a                	jne    80101fe1 <readi+0x4d>
      return -1;
80101fd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fdc:	e9 0a 01 00 00       	jmp    801020eb <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80101fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fe8:	98                   	cwtl
80101fe9:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80101ff0:	8b 55 14             	mov    0x14(%ebp),%edx
80101ff3:	83 ec 04             	sub    $0x4,%esp
80101ff6:	52                   	push   %edx
80101ff7:	ff 75 0c             	push   0xc(%ebp)
80101ffa:	ff 75 08             	push   0x8(%ebp)
80101ffd:	ff d0                	call   *%eax
80101fff:	83 c4 10             	add    $0x10,%esp
80102002:	e9 e4 00 00 00       	jmp    801020eb <readi+0x157>
  }

  if(off > ip->size || off + n < off)
80102007:	8b 45 08             	mov    0x8(%ebp),%eax
8010200a:	8b 40 58             	mov    0x58(%eax),%eax
8010200d:	39 45 10             	cmp    %eax,0x10(%ebp)
80102010:	77 0d                	ja     8010201f <readi+0x8b>
80102012:	8b 55 10             	mov    0x10(%ebp),%edx
80102015:	8b 45 14             	mov    0x14(%ebp),%eax
80102018:	01 d0                	add    %edx,%eax
8010201a:	39 45 10             	cmp    %eax,0x10(%ebp)
8010201d:	76 0a                	jbe    80102029 <readi+0x95>
    return -1;
8010201f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102024:	e9 c2 00 00 00       	jmp    801020eb <readi+0x157>
  if(off + n > ip->size)
80102029:	8b 55 10             	mov    0x10(%ebp),%edx
8010202c:	8b 45 14             	mov    0x14(%ebp),%eax
8010202f:	01 c2                	add    %eax,%edx
80102031:	8b 45 08             	mov    0x8(%ebp),%eax
80102034:	8b 40 58             	mov    0x58(%eax),%eax
80102037:	39 c2                	cmp    %eax,%edx
80102039:	76 0c                	jbe    80102047 <readi+0xb3>
    n = ip->size - off;
8010203b:	8b 45 08             	mov    0x8(%ebp),%eax
8010203e:	8b 40 58             	mov    0x58(%eax),%eax
80102041:	2b 45 10             	sub    0x10(%ebp),%eax
80102044:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102047:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010204e:	e9 89 00 00 00       	jmp    801020dc <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102053:	8b 45 10             	mov    0x10(%ebp),%eax
80102056:	c1 e8 09             	shr    $0x9,%eax
80102059:	83 ec 08             	sub    $0x8,%esp
8010205c:	50                   	push   %eax
8010205d:	ff 75 08             	push   0x8(%ebp)
80102060:	e8 8d fc ff ff       	call   80101cf2 <bmap>
80102065:	83 c4 10             	add    $0x10,%esp
80102068:	8b 55 08             	mov    0x8(%ebp),%edx
8010206b:	8b 12                	mov    (%edx),%edx
8010206d:	83 ec 08             	sub    $0x8,%esp
80102070:	50                   	push   %eax
80102071:	52                   	push   %edx
80102072:	e8 92 e1 ff ff       	call   80100209 <bread>
80102077:	83 c4 10             	add    $0x10,%esp
8010207a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010207d:	8b 45 10             	mov    0x10(%ebp),%eax
80102080:	25 ff 01 00 00       	and    $0x1ff,%eax
80102085:	ba 00 02 00 00       	mov    $0x200,%edx
8010208a:	29 c2                	sub    %eax,%edx
8010208c:	8b 45 14             	mov    0x14(%ebp),%eax
8010208f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102092:	39 c2                	cmp    %eax,%edx
80102094:	0f 46 c2             	cmovbe %edx,%eax
80102097:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010209a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010209d:	8d 50 5c             	lea    0x5c(%eax),%edx
801020a0:	8b 45 10             	mov    0x10(%ebp),%eax
801020a3:	25 ff 01 00 00       	and    $0x1ff,%eax
801020a8:	01 d0                	add    %edx,%eax
801020aa:	83 ec 04             	sub    $0x4,%esp
801020ad:	ff 75 ec             	push   -0x14(%ebp)
801020b0:	50                   	push   %eax
801020b1:	ff 75 0c             	push   0xc(%ebp)
801020b4:	e8 da 2c 00 00       	call   80104d93 <memmove>
801020b9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020bc:	83 ec 0c             	sub    $0xc,%esp
801020bf:	ff 75 f0             	push   -0x10(%ebp)
801020c2:	e8 cc e1 ff ff       	call   80100293 <brelse>
801020c7:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020cd:	01 45 f4             	add    %eax,-0xc(%ebp)
801020d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020d3:	01 45 10             	add    %eax,0x10(%ebp)
801020d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020d9:	01 45 0c             	add    %eax,0xc(%ebp)
801020dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020df:	3b 45 14             	cmp    0x14(%ebp),%eax
801020e2:	0f 82 6b ff ff ff    	jb     80102053 <readi+0xbf>
  }
  return n;
801020e8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020eb:	c9                   	leave
801020ec:	c3                   	ret

801020ed <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020ed:	f3 0f 1e fb          	endbr32
801020f1:	55                   	push   %ebp
801020f2:	89 e5                	mov    %esp,%ebp
801020f4:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020f7:	8b 45 08             	mov    0x8(%ebp),%eax
801020fa:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801020fe:	66 83 f8 03          	cmp    $0x3,%ax
80102102:	75 5c                	jne    80102160 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102104:	8b 45 08             	mov    0x8(%ebp),%eax
80102107:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010210b:	66 85 c0             	test   %ax,%ax
8010210e:	78 20                	js     80102130 <writei+0x43>
80102110:	8b 45 08             	mov    0x8(%ebp),%eax
80102113:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102117:	66 83 f8 09          	cmp    $0x9,%ax
8010211b:	7f 13                	jg     80102130 <writei+0x43>
8010211d:	8b 45 08             	mov    0x8(%ebp),%eax
80102120:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102124:	98                   	cwtl
80102125:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
8010212c:	85 c0                	test   %eax,%eax
8010212e:	75 0a                	jne    8010213a <writei+0x4d>
      return -1;
80102130:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102135:	e9 3b 01 00 00       	jmp    80102275 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
8010213a:	8b 45 08             	mov    0x8(%ebp),%eax
8010213d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102141:	98                   	cwtl
80102142:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
80102149:	8b 55 14             	mov    0x14(%ebp),%edx
8010214c:	83 ec 04             	sub    $0x4,%esp
8010214f:	52                   	push   %edx
80102150:	ff 75 0c             	push   0xc(%ebp)
80102153:	ff 75 08             	push   0x8(%ebp)
80102156:	ff d0                	call   *%eax
80102158:	83 c4 10             	add    $0x10,%esp
8010215b:	e9 15 01 00 00       	jmp    80102275 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
80102160:	8b 45 08             	mov    0x8(%ebp),%eax
80102163:	8b 40 58             	mov    0x58(%eax),%eax
80102166:	39 45 10             	cmp    %eax,0x10(%ebp)
80102169:	77 0d                	ja     80102178 <writei+0x8b>
8010216b:	8b 55 10             	mov    0x10(%ebp),%edx
8010216e:	8b 45 14             	mov    0x14(%ebp),%eax
80102171:	01 d0                	add    %edx,%eax
80102173:	39 45 10             	cmp    %eax,0x10(%ebp)
80102176:	76 0a                	jbe    80102182 <writei+0x95>
    return -1;
80102178:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010217d:	e9 f3 00 00 00       	jmp    80102275 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102182:	8b 55 10             	mov    0x10(%ebp),%edx
80102185:	8b 45 14             	mov    0x14(%ebp),%eax
80102188:	01 d0                	add    %edx,%eax
8010218a:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010218f:	76 0a                	jbe    8010219b <writei+0xae>
    return -1;
80102191:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102196:	e9 da 00 00 00       	jmp    80102275 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010219b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021a2:	e9 97 00 00 00       	jmp    8010223e <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801021a7:	8b 45 10             	mov    0x10(%ebp),%eax
801021aa:	c1 e8 09             	shr    $0x9,%eax
801021ad:	83 ec 08             	sub    $0x8,%esp
801021b0:	50                   	push   %eax
801021b1:	ff 75 08             	push   0x8(%ebp)
801021b4:	e8 39 fb ff ff       	call   80101cf2 <bmap>
801021b9:	83 c4 10             	add    $0x10,%esp
801021bc:	8b 55 08             	mov    0x8(%ebp),%edx
801021bf:	8b 12                	mov    (%edx),%edx
801021c1:	83 ec 08             	sub    $0x8,%esp
801021c4:	50                   	push   %eax
801021c5:	52                   	push   %edx
801021c6:	e8 3e e0 ff ff       	call   80100209 <bread>
801021cb:	83 c4 10             	add    $0x10,%esp
801021ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021d1:	8b 45 10             	mov    0x10(%ebp),%eax
801021d4:	25 ff 01 00 00       	and    $0x1ff,%eax
801021d9:	ba 00 02 00 00       	mov    $0x200,%edx
801021de:	29 c2                	sub    %eax,%edx
801021e0:	8b 45 14             	mov    0x14(%ebp),%eax
801021e3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021e6:	39 c2                	cmp    %eax,%edx
801021e8:	0f 46 c2             	cmovbe %edx,%eax
801021eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021f1:	8d 50 5c             	lea    0x5c(%eax),%edx
801021f4:	8b 45 10             	mov    0x10(%ebp),%eax
801021f7:	25 ff 01 00 00       	and    $0x1ff,%eax
801021fc:	01 d0                	add    %edx,%eax
801021fe:	83 ec 04             	sub    $0x4,%esp
80102201:	ff 75 ec             	push   -0x14(%ebp)
80102204:	ff 75 0c             	push   0xc(%ebp)
80102207:	50                   	push   %eax
80102208:	e8 86 2b 00 00       	call   80104d93 <memmove>
8010220d:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102210:	83 ec 0c             	sub    $0xc,%esp
80102213:	ff 75 f0             	push   -0x10(%ebp)
80102216:	e8 af 11 00 00       	call   801033ca <log_write>
8010221b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010221e:	83 ec 0c             	sub    $0xc,%esp
80102221:	ff 75 f0             	push   -0x10(%ebp)
80102224:	e8 6a e0 ff ff       	call   80100293 <brelse>
80102229:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010222c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010222f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102232:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102235:	01 45 10             	add    %eax,0x10(%ebp)
80102238:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010223b:	01 45 0c             	add    %eax,0xc(%ebp)
8010223e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102241:	3b 45 14             	cmp    0x14(%ebp),%eax
80102244:	0f 82 5d ff ff ff    	jb     801021a7 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
8010224a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010224e:	74 22                	je     80102272 <writei+0x185>
80102250:	8b 45 08             	mov    0x8(%ebp),%eax
80102253:	8b 40 58             	mov    0x58(%eax),%eax
80102256:	39 45 10             	cmp    %eax,0x10(%ebp)
80102259:	76 17                	jbe    80102272 <writei+0x185>
    ip->size = off;
8010225b:	8b 45 08             	mov    0x8(%ebp),%eax
8010225e:	8b 55 10             	mov    0x10(%ebp),%edx
80102261:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102264:	83 ec 0c             	sub    $0xc,%esp
80102267:	ff 75 08             	push   0x8(%ebp)
8010226a:	e8 34 f6 ff ff       	call   801018a3 <iupdate>
8010226f:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102272:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102275:	c9                   	leave
80102276:	c3                   	ret

80102277 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102277:	f3 0f 1e fb          	endbr32
8010227b:	55                   	push   %ebp
8010227c:	89 e5                	mov    %esp,%ebp
8010227e:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102281:	83 ec 04             	sub    $0x4,%esp
80102284:	6a 0e                	push   $0xe
80102286:	ff 75 0c             	push   0xc(%ebp)
80102289:	ff 75 08             	push   0x8(%ebp)
8010228c:	e8 a0 2b 00 00       	call   80104e31 <strncmp>
80102291:	83 c4 10             	add    $0x10,%esp
}
80102294:	c9                   	leave
80102295:	c3                   	ret

80102296 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102296:	f3 0f 1e fb          	endbr32
8010229a:	55                   	push   %ebp
8010229b:	89 e5                	mov    %esp,%ebp
8010229d:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801022a0:	8b 45 08             	mov    0x8(%ebp),%eax
801022a3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801022a7:	66 83 f8 01          	cmp    $0x1,%ax
801022ab:	74 0d                	je     801022ba <dirlookup+0x24>
    panic("dirlookup not DIR");
801022ad:	83 ec 0c             	sub    $0xc,%esp
801022b0:	68 bd a7 10 80       	push   $0x8010a7bd
801022b5:	e8 24 e3 ff ff       	call   801005de <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c1:	eb 7b                	jmp    8010233e <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022c3:	6a 10                	push   $0x10
801022c5:	ff 75 f4             	push   -0xc(%ebp)
801022c8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022cb:	50                   	push   %eax
801022cc:	ff 75 08             	push   0x8(%ebp)
801022cf:	e8 c0 fc ff ff       	call   80101f94 <readi>
801022d4:	83 c4 10             	add    $0x10,%esp
801022d7:	83 f8 10             	cmp    $0x10,%eax
801022da:	74 0d                	je     801022e9 <dirlookup+0x53>
      panic("dirlookup read");
801022dc:	83 ec 0c             	sub    $0xc,%esp
801022df:	68 cf a7 10 80       	push   $0x8010a7cf
801022e4:	e8 f5 e2 ff ff       	call   801005de <panic>
    if(de.inum == 0)
801022e9:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022ed:	66 85 c0             	test   %ax,%ax
801022f0:	74 47                	je     80102339 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
801022f2:	83 ec 08             	sub    $0x8,%esp
801022f5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022f8:	83 c0 02             	add    $0x2,%eax
801022fb:	50                   	push   %eax
801022fc:	ff 75 0c             	push   0xc(%ebp)
801022ff:	e8 73 ff ff ff       	call   80102277 <namecmp>
80102304:	83 c4 10             	add    $0x10,%esp
80102307:	85 c0                	test   %eax,%eax
80102309:	75 2f                	jne    8010233a <dirlookup+0xa4>
      // entry matches path element
      if(poff)
8010230b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010230f:	74 08                	je     80102319 <dirlookup+0x83>
        *poff = off;
80102311:	8b 45 10             	mov    0x10(%ebp),%eax
80102314:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102317:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102319:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010231d:	0f b7 c0             	movzwl %ax,%eax
80102320:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102323:	8b 45 08             	mov    0x8(%ebp),%eax
80102326:	8b 00                	mov    (%eax),%eax
80102328:	83 ec 08             	sub    $0x8,%esp
8010232b:	ff 75 f0             	push   -0x10(%ebp)
8010232e:	50                   	push   %eax
8010232f:	e8 34 f6 ff ff       	call   80101968 <iget>
80102334:	83 c4 10             	add    $0x10,%esp
80102337:	eb 19                	jmp    80102352 <dirlookup+0xbc>
      continue;
80102339:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010233a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010233e:	8b 45 08             	mov    0x8(%ebp),%eax
80102341:	8b 40 58             	mov    0x58(%eax),%eax
80102344:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102347:	0f 82 76 ff ff ff    	jb     801022c3 <dirlookup+0x2d>
    }
  }

  return 0;
8010234d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102352:	c9                   	leave
80102353:	c3                   	ret

80102354 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102354:	f3 0f 1e fb          	endbr32
80102358:	55                   	push   %ebp
80102359:	89 e5                	mov    %esp,%ebp
8010235b:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010235e:	83 ec 04             	sub    $0x4,%esp
80102361:	6a 00                	push   $0x0
80102363:	ff 75 0c             	push   0xc(%ebp)
80102366:	ff 75 08             	push   0x8(%ebp)
80102369:	e8 28 ff ff ff       	call   80102296 <dirlookup>
8010236e:	83 c4 10             	add    $0x10,%esp
80102371:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102374:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102378:	74 18                	je     80102392 <dirlink+0x3e>
    iput(ip);
8010237a:	83 ec 0c             	sub    $0xc,%esp
8010237d:	ff 75 f0             	push   -0x10(%ebp)
80102380:	e8 70 f8 ff ff       	call   80101bf5 <iput>
80102385:	83 c4 10             	add    $0x10,%esp
    return -1;
80102388:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010238d:	e9 9c 00 00 00       	jmp    8010242e <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102392:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102399:	eb 39                	jmp    801023d4 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010239b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010239e:	6a 10                	push   $0x10
801023a0:	50                   	push   %eax
801023a1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023a4:	50                   	push   %eax
801023a5:	ff 75 08             	push   0x8(%ebp)
801023a8:	e8 e7 fb ff ff       	call   80101f94 <readi>
801023ad:	83 c4 10             	add    $0x10,%esp
801023b0:	83 f8 10             	cmp    $0x10,%eax
801023b3:	74 0d                	je     801023c2 <dirlink+0x6e>
      panic("dirlink read");
801023b5:	83 ec 0c             	sub    $0xc,%esp
801023b8:	68 de a7 10 80       	push   $0x8010a7de
801023bd:	e8 1c e2 ff ff       	call   801005de <panic>
    if(de.inum == 0)
801023c2:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023c6:	66 85 c0             	test   %ax,%ax
801023c9:	74 18                	je     801023e3 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
801023cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ce:	83 c0 10             	add    $0x10,%eax
801023d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023d4:	8b 45 08             	mov    0x8(%ebp),%eax
801023d7:	8b 50 58             	mov    0x58(%eax),%edx
801023da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023dd:	39 c2                	cmp    %eax,%edx
801023df:	77 ba                	ja     8010239b <dirlink+0x47>
801023e1:	eb 01                	jmp    801023e4 <dirlink+0x90>
      break;
801023e3:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023e4:	83 ec 04             	sub    $0x4,%esp
801023e7:	6a 0e                	push   $0xe
801023e9:	ff 75 0c             	push   0xc(%ebp)
801023ec:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023ef:	83 c0 02             	add    $0x2,%eax
801023f2:	50                   	push   %eax
801023f3:	e8 93 2a 00 00       	call   80104e8b <strncpy>
801023f8:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023fb:	8b 45 10             	mov    0x10(%ebp),%eax
801023fe:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102405:	6a 10                	push   $0x10
80102407:	50                   	push   %eax
80102408:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010240b:	50                   	push   %eax
8010240c:	ff 75 08             	push   0x8(%ebp)
8010240f:	e8 d9 fc ff ff       	call   801020ed <writei>
80102414:	83 c4 10             	add    $0x10,%esp
80102417:	83 f8 10             	cmp    $0x10,%eax
8010241a:	74 0d                	je     80102429 <dirlink+0xd5>
    panic("dirlink");
8010241c:	83 ec 0c             	sub    $0xc,%esp
8010241f:	68 eb a7 10 80       	push   $0x8010a7eb
80102424:	e8 b5 e1 ff ff       	call   801005de <panic>

  return 0;
80102429:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010242e:	c9                   	leave
8010242f:	c3                   	ret

80102430 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102430:	f3 0f 1e fb          	endbr32
80102434:	55                   	push   %ebp
80102435:	89 e5                	mov    %esp,%ebp
80102437:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010243a:	eb 04                	jmp    80102440 <skipelem+0x10>
    path++;
8010243c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102440:	8b 45 08             	mov    0x8(%ebp),%eax
80102443:	0f b6 00             	movzbl (%eax),%eax
80102446:	3c 2f                	cmp    $0x2f,%al
80102448:	74 f2                	je     8010243c <skipelem+0xc>
  if(*path == 0)
8010244a:	8b 45 08             	mov    0x8(%ebp),%eax
8010244d:	0f b6 00             	movzbl (%eax),%eax
80102450:	84 c0                	test   %al,%al
80102452:	75 07                	jne    8010245b <skipelem+0x2b>
    return 0;
80102454:	b8 00 00 00 00       	mov    $0x0,%eax
80102459:	eb 77                	jmp    801024d2 <skipelem+0xa2>
  s = path;
8010245b:	8b 45 08             	mov    0x8(%ebp),%eax
8010245e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102461:	eb 04                	jmp    80102467 <skipelem+0x37>
    path++;
80102463:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102467:	8b 45 08             	mov    0x8(%ebp),%eax
8010246a:	0f b6 00             	movzbl (%eax),%eax
8010246d:	3c 2f                	cmp    $0x2f,%al
8010246f:	74 0a                	je     8010247b <skipelem+0x4b>
80102471:	8b 45 08             	mov    0x8(%ebp),%eax
80102474:	0f b6 00             	movzbl (%eax),%eax
80102477:	84 c0                	test   %al,%al
80102479:	75 e8                	jne    80102463 <skipelem+0x33>
  len = path - s;
8010247b:	8b 45 08             	mov    0x8(%ebp),%eax
8010247e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102481:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102484:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102488:	7e 15                	jle    8010249f <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010248a:	83 ec 04             	sub    $0x4,%esp
8010248d:	6a 0e                	push   $0xe
8010248f:	ff 75 f4             	push   -0xc(%ebp)
80102492:	ff 75 0c             	push   0xc(%ebp)
80102495:	e8 f9 28 00 00       	call   80104d93 <memmove>
8010249a:	83 c4 10             	add    $0x10,%esp
8010249d:	eb 26                	jmp    801024c5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010249f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024a2:	83 ec 04             	sub    $0x4,%esp
801024a5:	50                   	push   %eax
801024a6:	ff 75 f4             	push   -0xc(%ebp)
801024a9:	ff 75 0c             	push   0xc(%ebp)
801024ac:	e8 e2 28 00 00       	call   80104d93 <memmove>
801024b1:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801024b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801024ba:	01 d0                	add    %edx,%eax
801024bc:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024bf:	eb 04                	jmp    801024c5 <skipelem+0x95>
    path++;
801024c1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024c5:	8b 45 08             	mov    0x8(%ebp),%eax
801024c8:	0f b6 00             	movzbl (%eax),%eax
801024cb:	3c 2f                	cmp    $0x2f,%al
801024cd:	74 f2                	je     801024c1 <skipelem+0x91>
  return path;
801024cf:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024d2:	c9                   	leave
801024d3:	c3                   	ret

801024d4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024d4:	f3 0f 1e fb          	endbr32
801024d8:	55                   	push   %ebp
801024d9:	89 e5                	mov    %esp,%ebp
801024db:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024de:	8b 45 08             	mov    0x8(%ebp),%eax
801024e1:	0f b6 00             	movzbl (%eax),%eax
801024e4:	3c 2f                	cmp    $0x2f,%al
801024e6:	75 17                	jne    801024ff <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801024e8:	83 ec 08             	sub    $0x8,%esp
801024eb:	6a 01                	push   $0x1
801024ed:	6a 01                	push   $0x1
801024ef:	e8 74 f4 ff ff       	call   80101968 <iget>
801024f4:	83 c4 10             	add    $0x10,%esp
801024f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024fa:	e9 ba 00 00 00       	jmp    801025b9 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
801024ff:	e8 b5 16 00 00       	call   80103bb9 <myproc>
80102504:	8b 40 68             	mov    0x68(%eax),%eax
80102507:	83 ec 0c             	sub    $0xc,%esp
8010250a:	50                   	push   %eax
8010250b:	e8 3e f5 ff ff       	call   80101a4e <idup>
80102510:	83 c4 10             	add    $0x10,%esp
80102513:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102516:	e9 9e 00 00 00       	jmp    801025b9 <namex+0xe5>
    ilock(ip);
8010251b:	83 ec 0c             	sub    $0xc,%esp
8010251e:	ff 75 f4             	push   -0xc(%ebp)
80102521:	e8 66 f5 ff ff       	call   80101a8c <ilock>
80102526:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010252c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102530:	66 83 f8 01          	cmp    $0x1,%ax
80102534:	74 18                	je     8010254e <namex+0x7a>
      iunlockput(ip);
80102536:	83 ec 0c             	sub    $0xc,%esp
80102539:	ff 75 f4             	push   -0xc(%ebp)
8010253c:	e8 88 f7 ff ff       	call   80101cc9 <iunlockput>
80102541:	83 c4 10             	add    $0x10,%esp
      return 0;
80102544:	b8 00 00 00 00       	mov    $0x0,%eax
80102549:	e9 a7 00 00 00       	jmp    801025f5 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
8010254e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102552:	74 20                	je     80102574 <namex+0xa0>
80102554:	8b 45 08             	mov    0x8(%ebp),%eax
80102557:	0f b6 00             	movzbl (%eax),%eax
8010255a:	84 c0                	test   %al,%al
8010255c:	75 16                	jne    80102574 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
8010255e:	83 ec 0c             	sub    $0xc,%esp
80102561:	ff 75 f4             	push   -0xc(%ebp)
80102564:	e8 3a f6 ff ff       	call   80101ba3 <iunlock>
80102569:	83 c4 10             	add    $0x10,%esp
      return ip;
8010256c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010256f:	e9 81 00 00 00       	jmp    801025f5 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102574:	83 ec 04             	sub    $0x4,%esp
80102577:	6a 00                	push   $0x0
80102579:	ff 75 10             	push   0x10(%ebp)
8010257c:	ff 75 f4             	push   -0xc(%ebp)
8010257f:	e8 12 fd ff ff       	call   80102296 <dirlookup>
80102584:	83 c4 10             	add    $0x10,%esp
80102587:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010258a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010258e:	75 15                	jne    801025a5 <namex+0xd1>
      iunlockput(ip);
80102590:	83 ec 0c             	sub    $0xc,%esp
80102593:	ff 75 f4             	push   -0xc(%ebp)
80102596:	e8 2e f7 ff ff       	call   80101cc9 <iunlockput>
8010259b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010259e:	b8 00 00 00 00       	mov    $0x0,%eax
801025a3:	eb 50                	jmp    801025f5 <namex+0x121>
    }
    iunlockput(ip);
801025a5:	83 ec 0c             	sub    $0xc,%esp
801025a8:	ff 75 f4             	push   -0xc(%ebp)
801025ab:	e8 19 f7 ff ff       	call   80101cc9 <iunlockput>
801025b0:	83 c4 10             	add    $0x10,%esp
    ip = next;
801025b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801025b9:	83 ec 08             	sub    $0x8,%esp
801025bc:	ff 75 10             	push   0x10(%ebp)
801025bf:	ff 75 08             	push   0x8(%ebp)
801025c2:	e8 69 fe ff ff       	call   80102430 <skipelem>
801025c7:	83 c4 10             	add    $0x10,%esp
801025ca:	89 45 08             	mov    %eax,0x8(%ebp)
801025cd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025d1:	0f 85 44 ff ff ff    	jne    8010251b <namex+0x47>
  }
  if(nameiparent){
801025d7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025db:	74 15                	je     801025f2 <namex+0x11e>
    iput(ip);
801025dd:	83 ec 0c             	sub    $0xc,%esp
801025e0:	ff 75 f4             	push   -0xc(%ebp)
801025e3:	e8 0d f6 ff ff       	call   80101bf5 <iput>
801025e8:	83 c4 10             	add    $0x10,%esp
    return 0;
801025eb:	b8 00 00 00 00       	mov    $0x0,%eax
801025f0:	eb 03                	jmp    801025f5 <namex+0x121>
  }
  return ip;
801025f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025f5:	c9                   	leave
801025f6:	c3                   	ret

801025f7 <namei>:

struct inode*
namei(char *path)
{
801025f7:	f3 0f 1e fb          	endbr32
801025fb:	55                   	push   %ebp
801025fc:	89 e5                	mov    %esp,%ebp
801025fe:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102601:	83 ec 04             	sub    $0x4,%esp
80102604:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102607:	50                   	push   %eax
80102608:	6a 00                	push   $0x0
8010260a:	ff 75 08             	push   0x8(%ebp)
8010260d:	e8 c2 fe ff ff       	call   801024d4 <namex>
80102612:	83 c4 10             	add    $0x10,%esp
}
80102615:	c9                   	leave
80102616:	c3                   	ret

80102617 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102617:	f3 0f 1e fb          	endbr32
8010261b:	55                   	push   %ebp
8010261c:	89 e5                	mov    %esp,%ebp
8010261e:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102621:	83 ec 04             	sub    $0x4,%esp
80102624:	ff 75 0c             	push   0xc(%ebp)
80102627:	6a 01                	push   $0x1
80102629:	ff 75 08             	push   0x8(%ebp)
8010262c:	e8 a3 fe ff ff       	call   801024d4 <namex>
80102631:	83 c4 10             	add    $0x10,%esp
}
80102634:	c9                   	leave
80102635:	c3                   	ret

80102636 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102636:	f3 0f 1e fb          	endbr32
8010263a:	55                   	push   %ebp
8010263b:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010263d:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102642:	8b 55 08             	mov    0x8(%ebp),%edx
80102645:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102647:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010264c:	8b 40 10             	mov    0x10(%eax),%eax
}
8010264f:	5d                   	pop    %ebp
80102650:	c3                   	ret

80102651 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102651:	f3 0f 1e fb          	endbr32
80102655:	55                   	push   %ebp
80102656:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102658:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010265d:	8b 55 08             	mov    0x8(%ebp),%edx
80102660:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102662:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102667:	8b 55 0c             	mov    0xc(%ebp),%edx
8010266a:	89 50 10             	mov    %edx,0x10(%eax)
}
8010266d:	90                   	nop
8010266e:	5d                   	pop    %ebp
8010266f:	c3                   	ret

80102670 <ioapicinit>:

void
ioapicinit(void)
{
80102670:	f3 0f 1e fb          	endbr32
80102674:	55                   	push   %ebp
80102675:	89 e5                	mov    %esp,%ebp
80102677:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010267a:	c7 05 d4 53 19 80 00 	movl   $0xfec00000,0x801953d4
80102681:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102684:	6a 01                	push   $0x1
80102686:	e8 ab ff ff ff       	call   80102636 <ioapicread>
8010268b:	83 c4 04             	add    $0x4,%esp
8010268e:	c1 e8 10             	shr    $0x10,%eax
80102691:	25 ff 00 00 00       	and    $0xff,%eax
80102696:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102699:	6a 00                	push   $0x0
8010269b:	e8 96 ff ff ff       	call   80102636 <ioapicread>
801026a0:	83 c4 04             	add    $0x4,%esp
801026a3:	c1 e8 18             	shr    $0x18,%eax
801026a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801026a9:	0f b6 05 a0 7d 19 80 	movzbl 0x80197da0,%eax
801026b0:	0f b6 c0             	movzbl %al,%eax
801026b3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801026b6:	74 10                	je     801026c8 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801026b8:	83 ec 0c             	sub    $0xc,%esp
801026bb:	68 f4 a7 10 80       	push   $0x8010a7f4
801026c0:	e8 47 dd ff ff       	call   8010040c <cprintf>
801026c5:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801026c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026cf:	eb 3f                	jmp    80102710 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801026d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d4:	83 c0 20             	add    $0x20,%eax
801026d7:	0d 00 00 01 00       	or     $0x10000,%eax
801026dc:	89 c2                	mov    %eax,%edx
801026de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e1:	83 c0 08             	add    $0x8,%eax
801026e4:	01 c0                	add    %eax,%eax
801026e6:	83 ec 08             	sub    $0x8,%esp
801026e9:	52                   	push   %edx
801026ea:	50                   	push   %eax
801026eb:	e8 61 ff ff ff       	call   80102651 <ioapicwrite>
801026f0:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801026f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f6:	83 c0 08             	add    $0x8,%eax
801026f9:	01 c0                	add    %eax,%eax
801026fb:	83 c0 01             	add    $0x1,%eax
801026fe:	83 ec 08             	sub    $0x8,%esp
80102701:	6a 00                	push   $0x0
80102703:	50                   	push   %eax
80102704:	e8 48 ff ff ff       	call   80102651 <ioapicwrite>
80102709:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
8010270c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102710:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102713:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102716:	7e b9                	jle    801026d1 <ioapicinit+0x61>
  }
}
80102718:	90                   	nop
80102719:	90                   	nop
8010271a:	c9                   	leave
8010271b:	c3                   	ret

8010271c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010271c:	f3 0f 1e fb          	endbr32
80102720:	55                   	push   %ebp
80102721:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102723:	8b 45 08             	mov    0x8(%ebp),%eax
80102726:	83 c0 20             	add    $0x20,%eax
80102729:	89 c2                	mov    %eax,%edx
8010272b:	8b 45 08             	mov    0x8(%ebp),%eax
8010272e:	83 c0 08             	add    $0x8,%eax
80102731:	01 c0                	add    %eax,%eax
80102733:	52                   	push   %edx
80102734:	50                   	push   %eax
80102735:	e8 17 ff ff ff       	call   80102651 <ioapicwrite>
8010273a:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010273d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102740:	c1 e0 18             	shl    $0x18,%eax
80102743:	89 c2                	mov    %eax,%edx
80102745:	8b 45 08             	mov    0x8(%ebp),%eax
80102748:	83 c0 08             	add    $0x8,%eax
8010274b:	01 c0                	add    %eax,%eax
8010274d:	83 c0 01             	add    $0x1,%eax
80102750:	52                   	push   %edx
80102751:	50                   	push   %eax
80102752:	e8 fa fe ff ff       	call   80102651 <ioapicwrite>
80102757:	83 c4 08             	add    $0x8,%esp
}
8010275a:	90                   	nop
8010275b:	c9                   	leave
8010275c:	c3                   	ret

8010275d <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010275d:	f3 0f 1e fb          	endbr32
80102761:	55                   	push   %ebp
80102762:	89 e5                	mov    %esp,%ebp
80102764:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102767:	83 ec 08             	sub    $0x8,%esp
8010276a:	68 26 a8 10 80       	push   $0x8010a826
8010276f:	68 e0 53 19 80       	push   $0x801953e0
80102774:	e8 9e 22 00 00       	call   80104a17 <initlock>
80102779:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010277c:	c7 05 14 54 19 80 00 	movl   $0x0,0x80195414
80102783:	00 00 00 
  freerange(vstart, vend);
80102786:	83 ec 08             	sub    $0x8,%esp
80102789:	ff 75 0c             	push   0xc(%ebp)
8010278c:	ff 75 08             	push   0x8(%ebp)
8010278f:	e8 2e 00 00 00       	call   801027c2 <freerange>
80102794:	83 c4 10             	add    $0x10,%esp
}
80102797:	90                   	nop
80102798:	c9                   	leave
80102799:	c3                   	ret

8010279a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010279a:	f3 0f 1e fb          	endbr32
8010279e:	55                   	push   %ebp
8010279f:	89 e5                	mov    %esp,%ebp
801027a1:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801027a4:	83 ec 08             	sub    $0x8,%esp
801027a7:	ff 75 0c             	push   0xc(%ebp)
801027aa:	ff 75 08             	push   0x8(%ebp)
801027ad:	e8 10 00 00 00       	call   801027c2 <freerange>
801027b2:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801027b5:	c7 05 14 54 19 80 01 	movl   $0x1,0x80195414
801027bc:	00 00 00 
}
801027bf:	90                   	nop
801027c0:	c9                   	leave
801027c1:	c3                   	ret

801027c2 <freerange>:

void
freerange(void *vstart, void *vend)
{
801027c2:	f3 0f 1e fb          	endbr32
801027c6:	55                   	push   %ebp
801027c7:	89 e5                	mov    %esp,%ebp
801027c9:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801027cc:	8b 45 08             	mov    0x8(%ebp),%eax
801027cf:	05 ff 0f 00 00       	add    $0xfff,%eax
801027d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801027d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027dc:	eb 15                	jmp    801027f3 <freerange+0x31>
    kfree(p);
801027de:	83 ec 0c             	sub    $0xc,%esp
801027e1:	ff 75 f4             	push   -0xc(%ebp)
801027e4:	e8 1b 00 00 00       	call   80102804 <kfree>
801027e9:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027ec:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801027f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027f6:	05 00 10 00 00       	add    $0x1000,%eax
801027fb:	39 45 0c             	cmp    %eax,0xc(%ebp)
801027fe:	73 de                	jae    801027de <freerange+0x1c>
}
80102800:	90                   	nop
80102801:	90                   	nop
80102802:	c9                   	leave
80102803:	c3                   	ret

80102804 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102804:	f3 0f 1e fb          	endbr32
80102808:	55                   	push   %ebp
80102809:	89 e5                	mov    %esp,%ebp
8010280b:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010280e:	8b 45 08             	mov    0x8(%ebp),%eax
80102811:	25 ff 0f 00 00       	and    $0xfff,%eax
80102816:	85 c0                	test   %eax,%eax
80102818:	75 18                	jne    80102832 <kfree+0x2e>
8010281a:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
80102821:	72 0f                	jb     80102832 <kfree+0x2e>
80102823:	8b 45 08             	mov    0x8(%ebp),%eax
80102826:	05 00 00 00 80       	add    $0x80000000,%eax
8010282b:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102830:	76 0d                	jbe    8010283f <kfree+0x3b>
    panic("kfree");
80102832:	83 ec 0c             	sub    $0xc,%esp
80102835:	68 2b a8 10 80       	push   $0x8010a82b
8010283a:	e8 9f dd ff ff       	call   801005de <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010283f:	83 ec 04             	sub    $0x4,%esp
80102842:	68 00 10 00 00       	push   $0x1000
80102847:	6a 01                	push   $0x1
80102849:	ff 75 08             	push   0x8(%ebp)
8010284c:	e8 7b 24 00 00       	call   80104ccc <memset>
80102851:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102854:	a1 14 54 19 80       	mov    0x80195414,%eax
80102859:	85 c0                	test   %eax,%eax
8010285b:	74 10                	je     8010286d <kfree+0x69>
    acquire(&kmem.lock);
8010285d:	83 ec 0c             	sub    $0xc,%esp
80102860:	68 e0 53 19 80       	push   $0x801953e0
80102865:	e8 d3 21 00 00       	call   80104a3d <acquire>
8010286a:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010286d:	8b 45 08             	mov    0x8(%ebp),%eax
80102870:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102873:	8b 15 18 54 19 80    	mov    0x80195418,%edx
80102879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010287c:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010287e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102881:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
80102886:	a1 14 54 19 80       	mov    0x80195414,%eax
8010288b:	85 c0                	test   %eax,%eax
8010288d:	74 10                	je     8010289f <kfree+0x9b>
    release(&kmem.lock);
8010288f:	83 ec 0c             	sub    $0xc,%esp
80102892:	68 e0 53 19 80       	push   $0x801953e0
80102897:	e8 13 22 00 00       	call   80104aaf <release>
8010289c:	83 c4 10             	add    $0x10,%esp
}
8010289f:	90                   	nop
801028a0:	c9                   	leave
801028a1:	c3                   	ret

801028a2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801028a2:	f3 0f 1e fb          	endbr32
801028a6:	55                   	push   %ebp
801028a7:	89 e5                	mov    %esp,%ebp
801028a9:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801028ac:	a1 14 54 19 80       	mov    0x80195414,%eax
801028b1:	85 c0                	test   %eax,%eax
801028b3:	74 10                	je     801028c5 <kalloc+0x23>
    acquire(&kmem.lock);
801028b5:	83 ec 0c             	sub    $0xc,%esp
801028b8:	68 e0 53 19 80       	push   $0x801953e0
801028bd:	e8 7b 21 00 00       	call   80104a3d <acquire>
801028c2:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801028c5:	a1 18 54 19 80       	mov    0x80195418,%eax
801028ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801028cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028d1:	74 0a                	je     801028dd <kalloc+0x3b>
    kmem.freelist = r->next;
801028d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d6:	8b 00                	mov    (%eax),%eax
801028d8:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
801028dd:	a1 14 54 19 80       	mov    0x80195414,%eax
801028e2:	85 c0                	test   %eax,%eax
801028e4:	74 10                	je     801028f6 <kalloc+0x54>
    release(&kmem.lock);
801028e6:	83 ec 0c             	sub    $0xc,%esp
801028e9:	68 e0 53 19 80       	push   $0x801953e0
801028ee:	e8 bc 21 00 00       	call   80104aaf <release>
801028f3:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801028f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801028f9:	c9                   	leave
801028fa:	c3                   	ret

801028fb <inb>:
{
801028fb:	55                   	push   %ebp
801028fc:	89 e5                	mov    %esp,%ebp
801028fe:	83 ec 14             	sub    $0x14,%esp
80102901:	8b 45 08             	mov    0x8(%ebp),%eax
80102904:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102908:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010290c:	89 c2                	mov    %eax,%edx
8010290e:	ec                   	in     (%dx),%al
8010290f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102912:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102916:	c9                   	leave
80102917:	c3                   	ret

80102918 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102918:	f3 0f 1e fb          	endbr32
8010291c:	55                   	push   %ebp
8010291d:	89 e5                	mov    %esp,%ebp
8010291f:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102922:	6a 64                	push   $0x64
80102924:	e8 d2 ff ff ff       	call   801028fb <inb>
80102929:	83 c4 04             	add    $0x4,%esp
8010292c:	0f b6 c0             	movzbl %al,%eax
8010292f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102935:	83 e0 01             	and    $0x1,%eax
80102938:	85 c0                	test   %eax,%eax
8010293a:	75 0a                	jne    80102946 <kbdgetc+0x2e>
    return -1;
8010293c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102941:	e9 23 01 00 00       	jmp    80102a69 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102946:	6a 60                	push   $0x60
80102948:	e8 ae ff ff ff       	call   801028fb <inb>
8010294d:	83 c4 04             	add    $0x4,%esp
80102950:	0f b6 c0             	movzbl %al,%eax
80102953:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102956:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010295d:	75 17                	jne    80102976 <kbdgetc+0x5e>
    shift |= E0ESC;
8010295f:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102964:	83 c8 40             	or     $0x40,%eax
80102967:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
8010296c:	b8 00 00 00 00       	mov    $0x0,%eax
80102971:	e9 f3 00 00 00       	jmp    80102a69 <kbdgetc+0x151>
  } else if(data & 0x80){
80102976:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102979:	25 80 00 00 00       	and    $0x80,%eax
8010297e:	85 c0                	test   %eax,%eax
80102980:	74 45                	je     801029c7 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102982:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102987:	83 e0 40             	and    $0x40,%eax
8010298a:	85 c0                	test   %eax,%eax
8010298c:	75 08                	jne    80102996 <kbdgetc+0x7e>
8010298e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102991:	83 e0 7f             	and    $0x7f,%eax
80102994:	eb 03                	jmp    80102999 <kbdgetc+0x81>
80102996:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102999:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010299c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010299f:	05 20 d0 10 80       	add    $0x8010d020,%eax
801029a4:	0f b6 00             	movzbl (%eax),%eax
801029a7:	83 c8 40             	or     $0x40,%eax
801029aa:	0f b6 c0             	movzbl %al,%eax
801029ad:	f7 d0                	not    %eax
801029af:	89 c2                	mov    %eax,%edx
801029b1:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029b6:	21 d0                	and    %edx,%eax
801029b8:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
801029bd:	b8 00 00 00 00       	mov    $0x0,%eax
801029c2:	e9 a2 00 00 00       	jmp    80102a69 <kbdgetc+0x151>
  } else if(shift & E0ESC){
801029c7:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029cc:	83 e0 40             	and    $0x40,%eax
801029cf:	85 c0                	test   %eax,%eax
801029d1:	74 14                	je     801029e7 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801029d3:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801029da:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029df:	83 e0 bf             	and    $0xffffffbf,%eax
801029e2:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  }

  shift |= shiftcode[data];
801029e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029ea:	05 20 d0 10 80       	add    $0x8010d020,%eax
801029ef:	0f b6 00             	movzbl (%eax),%eax
801029f2:	0f b6 d0             	movzbl %al,%edx
801029f5:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029fa:	09 d0                	or     %edx,%eax
801029fc:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  shift ^= togglecode[data];
80102a01:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a04:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102a09:	0f b6 00             	movzbl (%eax),%eax
80102a0c:	0f b6 d0             	movzbl %al,%edx
80102a0f:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a14:	31 d0                	xor    %edx,%eax
80102a16:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  c = charcode[shift & (CTL | SHIFT)][data];
80102a1b:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a20:	83 e0 03             	and    $0x3,%eax
80102a23:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102a2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a2d:	01 d0                	add    %edx,%eax
80102a2f:	0f b6 00             	movzbl (%eax),%eax
80102a32:	0f b6 c0             	movzbl %al,%eax
80102a35:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102a38:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a3d:	83 e0 08             	and    $0x8,%eax
80102a40:	85 c0                	test   %eax,%eax
80102a42:	74 22                	je     80102a66 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102a44:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102a48:	76 0c                	jbe    80102a56 <kbdgetc+0x13e>
80102a4a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102a4e:	77 06                	ja     80102a56 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102a50:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102a54:	eb 10                	jmp    80102a66 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102a56:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102a5a:	76 0a                	jbe    80102a66 <kbdgetc+0x14e>
80102a5c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102a60:	77 04                	ja     80102a66 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102a62:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102a66:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102a69:	c9                   	leave
80102a6a:	c3                   	ret

80102a6b <kbdintr>:

void
kbdintr(void)
{
80102a6b:	f3 0f 1e fb          	endbr32
80102a6f:	55                   	push   %ebp
80102a70:	89 e5                	mov    %esp,%ebp
80102a72:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102a75:	83 ec 0c             	sub    $0xc,%esp
80102a78:	68 18 29 10 80       	push   $0x80102918
80102a7d:	e8 97 dd ff ff       	call   80100819 <consoleintr>
80102a82:	83 c4 10             	add    $0x10,%esp
}
80102a85:	90                   	nop
80102a86:	c9                   	leave
80102a87:	c3                   	ret

80102a88 <inb>:
{
80102a88:	55                   	push   %ebp
80102a89:	89 e5                	mov    %esp,%ebp
80102a8b:	83 ec 14             	sub    $0x14,%esp
80102a8e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a91:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a95:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102a99:	89 c2                	mov    %eax,%edx
80102a9b:	ec                   	in     (%dx),%al
80102a9c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102a9f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102aa3:	c9                   	leave
80102aa4:	c3                   	ret

80102aa5 <outb>:
{
80102aa5:	55                   	push   %ebp
80102aa6:	89 e5                	mov    %esp,%ebp
80102aa8:	83 ec 08             	sub    $0x8,%esp
80102aab:	8b 45 08             	mov    0x8(%ebp),%eax
80102aae:	8b 55 0c             	mov    0xc(%ebp),%edx
80102ab1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102ab5:	89 d0                	mov    %edx,%eax
80102ab7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102aba:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102abe:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ac2:	ee                   	out    %al,(%dx)
}
80102ac3:	90                   	nop
80102ac4:	c9                   	leave
80102ac5:	c3                   	ret

80102ac6 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102ac6:	f3 0f 1e fb          	endbr32
80102aca:	55                   	push   %ebp
80102acb:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102acd:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ad2:	8b 55 08             	mov    0x8(%ebp),%edx
80102ad5:	c1 e2 02             	shl    $0x2,%edx
80102ad8:	01 c2                	add    %eax,%edx
80102ada:	8b 45 0c             	mov    0xc(%ebp),%eax
80102add:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102adf:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ae4:	83 c0 20             	add    $0x20,%eax
80102ae7:	8b 00                	mov    (%eax),%eax
}
80102ae9:	90                   	nop
80102aea:	5d                   	pop    %ebp
80102aeb:	c3                   	ret

80102aec <lapicinit>:

void
lapicinit(void)
{
80102aec:	f3 0f 1e fb          	endbr32
80102af0:	55                   	push   %ebp
80102af1:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102af3:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102af8:	85 c0                	test   %eax,%eax
80102afa:	0f 84 0c 01 00 00    	je     80102c0c <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102b00:	68 3f 01 00 00       	push   $0x13f
80102b05:	6a 3c                	push   $0x3c
80102b07:	e8 ba ff ff ff       	call   80102ac6 <lapicw>
80102b0c:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102b0f:	6a 0b                	push   $0xb
80102b11:	68 f8 00 00 00       	push   $0xf8
80102b16:	e8 ab ff ff ff       	call   80102ac6 <lapicw>
80102b1b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102b1e:	68 20 00 02 00       	push   $0x20020
80102b23:	68 c8 00 00 00       	push   $0xc8
80102b28:	e8 99 ff ff ff       	call   80102ac6 <lapicw>
80102b2d:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102b30:	68 80 96 98 00       	push   $0x989680
80102b35:	68 e0 00 00 00       	push   $0xe0
80102b3a:	e8 87 ff ff ff       	call   80102ac6 <lapicw>
80102b3f:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102b42:	68 00 00 01 00       	push   $0x10000
80102b47:	68 d4 00 00 00       	push   $0xd4
80102b4c:	e8 75 ff ff ff       	call   80102ac6 <lapicw>
80102b51:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102b54:	68 00 00 01 00       	push   $0x10000
80102b59:	68 d8 00 00 00       	push   $0xd8
80102b5e:	e8 63 ff ff ff       	call   80102ac6 <lapicw>
80102b63:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102b66:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b6b:	83 c0 30             	add    $0x30,%eax
80102b6e:	8b 00                	mov    (%eax),%eax
80102b70:	c1 e8 10             	shr    $0x10,%eax
80102b73:	25 fc 00 00 00       	and    $0xfc,%eax
80102b78:	85 c0                	test   %eax,%eax
80102b7a:	74 12                	je     80102b8e <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80102b7c:	68 00 00 01 00       	push   $0x10000
80102b81:	68 d0 00 00 00       	push   $0xd0
80102b86:	e8 3b ff ff ff       	call   80102ac6 <lapicw>
80102b8b:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102b8e:	6a 33                	push   $0x33
80102b90:	68 dc 00 00 00       	push   $0xdc
80102b95:	e8 2c ff ff ff       	call   80102ac6 <lapicw>
80102b9a:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102b9d:	6a 00                	push   $0x0
80102b9f:	68 a0 00 00 00       	push   $0xa0
80102ba4:	e8 1d ff ff ff       	call   80102ac6 <lapicw>
80102ba9:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102bac:	6a 00                	push   $0x0
80102bae:	68 a0 00 00 00       	push   $0xa0
80102bb3:	e8 0e ff ff ff       	call   80102ac6 <lapicw>
80102bb8:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102bbb:	6a 00                	push   $0x0
80102bbd:	6a 2c                	push   $0x2c
80102bbf:	e8 02 ff ff ff       	call   80102ac6 <lapicw>
80102bc4:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102bc7:	6a 00                	push   $0x0
80102bc9:	68 c4 00 00 00       	push   $0xc4
80102bce:	e8 f3 fe ff ff       	call   80102ac6 <lapicw>
80102bd3:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102bd6:	68 00 85 08 00       	push   $0x88500
80102bdb:	68 c0 00 00 00       	push   $0xc0
80102be0:	e8 e1 fe ff ff       	call   80102ac6 <lapicw>
80102be5:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102be8:	90                   	nop
80102be9:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102bee:	05 00 03 00 00       	add    $0x300,%eax
80102bf3:	8b 00                	mov    (%eax),%eax
80102bf5:	25 00 10 00 00       	and    $0x1000,%eax
80102bfa:	85 c0                	test   %eax,%eax
80102bfc:	75 eb                	jne    80102be9 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102bfe:	6a 00                	push   $0x0
80102c00:	6a 20                	push   $0x20
80102c02:	e8 bf fe ff ff       	call   80102ac6 <lapicw>
80102c07:	83 c4 08             	add    $0x8,%esp
80102c0a:	eb 01                	jmp    80102c0d <lapicinit+0x121>
    return;
80102c0c:	90                   	nop
}
80102c0d:	c9                   	leave
80102c0e:	c3                   	ret

80102c0f <lapicid>:

int
lapicid(void)
{
80102c0f:	f3 0f 1e fb          	endbr32
80102c13:	55                   	push   %ebp
80102c14:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102c16:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c1b:	85 c0                	test   %eax,%eax
80102c1d:	75 07                	jne    80102c26 <lapicid+0x17>
    return 0;
80102c1f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c24:	eb 0d                	jmp    80102c33 <lapicid+0x24>
  }
  return lapic[ID] >> 24;
80102c26:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c2b:	83 c0 20             	add    $0x20,%eax
80102c2e:	8b 00                	mov    (%eax),%eax
80102c30:	c1 e8 18             	shr    $0x18,%eax
}
80102c33:	5d                   	pop    %ebp
80102c34:	c3                   	ret

80102c35 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102c35:	f3 0f 1e fb          	endbr32
80102c39:	55                   	push   %ebp
80102c3a:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102c3c:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c41:	85 c0                	test   %eax,%eax
80102c43:	74 0c                	je     80102c51 <lapiceoi+0x1c>
    lapicw(EOI, 0);
80102c45:	6a 00                	push   $0x0
80102c47:	6a 2c                	push   $0x2c
80102c49:	e8 78 fe ff ff       	call   80102ac6 <lapicw>
80102c4e:	83 c4 08             	add    $0x8,%esp
}
80102c51:	90                   	nop
80102c52:	c9                   	leave
80102c53:	c3                   	ret

80102c54 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102c54:	f3 0f 1e fb          	endbr32
80102c58:	55                   	push   %ebp
80102c59:	89 e5                	mov    %esp,%ebp
}
80102c5b:	90                   	nop
80102c5c:	5d                   	pop    %ebp
80102c5d:	c3                   	ret

80102c5e <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102c5e:	f3 0f 1e fb          	endbr32
80102c62:	55                   	push   %ebp
80102c63:	89 e5                	mov    %esp,%ebp
80102c65:	83 ec 14             	sub    $0x14,%esp
80102c68:	8b 45 08             	mov    0x8(%ebp),%eax
80102c6b:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102c6e:	6a 0f                	push   $0xf
80102c70:	6a 70                	push   $0x70
80102c72:	e8 2e fe ff ff       	call   80102aa5 <outb>
80102c77:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102c7a:	6a 0a                	push   $0xa
80102c7c:	6a 71                	push   $0x71
80102c7e:	e8 22 fe ff ff       	call   80102aa5 <outb>
80102c83:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102c86:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102c8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102c90:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102c95:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c98:	c1 e8 04             	shr    $0x4,%eax
80102c9b:	89 c2                	mov    %eax,%edx
80102c9d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102ca0:	83 c0 02             	add    $0x2,%eax
80102ca3:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102ca6:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102caa:	c1 e0 18             	shl    $0x18,%eax
80102cad:	50                   	push   %eax
80102cae:	68 c4 00 00 00       	push   $0xc4
80102cb3:	e8 0e fe ff ff       	call   80102ac6 <lapicw>
80102cb8:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102cbb:	68 00 c5 00 00       	push   $0xc500
80102cc0:	68 c0 00 00 00       	push   $0xc0
80102cc5:	e8 fc fd ff ff       	call   80102ac6 <lapicw>
80102cca:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102ccd:	68 c8 00 00 00       	push   $0xc8
80102cd2:	e8 7d ff ff ff       	call   80102c54 <microdelay>
80102cd7:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102cda:	68 00 85 00 00       	push   $0x8500
80102cdf:	68 c0 00 00 00       	push   $0xc0
80102ce4:	e8 dd fd ff ff       	call   80102ac6 <lapicw>
80102ce9:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102cec:	6a 64                	push   $0x64
80102cee:	e8 61 ff ff ff       	call   80102c54 <microdelay>
80102cf3:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102cf6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102cfd:	eb 3d                	jmp    80102d3c <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
80102cff:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102d03:	c1 e0 18             	shl    $0x18,%eax
80102d06:	50                   	push   %eax
80102d07:	68 c4 00 00 00       	push   $0xc4
80102d0c:	e8 b5 fd ff ff       	call   80102ac6 <lapicw>
80102d11:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102d14:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d17:	c1 e8 0c             	shr    $0xc,%eax
80102d1a:	80 cc 06             	or     $0x6,%ah
80102d1d:	50                   	push   %eax
80102d1e:	68 c0 00 00 00       	push   $0xc0
80102d23:	e8 9e fd ff ff       	call   80102ac6 <lapicw>
80102d28:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102d2b:	68 c8 00 00 00       	push   $0xc8
80102d30:	e8 1f ff ff ff       	call   80102c54 <microdelay>
80102d35:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102d38:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102d3c:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102d40:	7e bd                	jle    80102cff <lapicstartap+0xa1>
  }
}
80102d42:	90                   	nop
80102d43:	90                   	nop
80102d44:	c9                   	leave
80102d45:	c3                   	ret

80102d46 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102d46:	f3 0f 1e fb          	endbr32
80102d4a:	55                   	push   %ebp
80102d4b:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102d4d:	8b 45 08             	mov    0x8(%ebp),%eax
80102d50:	0f b6 c0             	movzbl %al,%eax
80102d53:	50                   	push   %eax
80102d54:	6a 70                	push   $0x70
80102d56:	e8 4a fd ff ff       	call   80102aa5 <outb>
80102d5b:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102d5e:	68 c8 00 00 00       	push   $0xc8
80102d63:	e8 ec fe ff ff       	call   80102c54 <microdelay>
80102d68:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102d6b:	6a 71                	push   $0x71
80102d6d:	e8 16 fd ff ff       	call   80102a88 <inb>
80102d72:	83 c4 04             	add    $0x4,%esp
80102d75:	0f b6 c0             	movzbl %al,%eax
}
80102d78:	c9                   	leave
80102d79:	c3                   	ret

80102d7a <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102d7a:	f3 0f 1e fb          	endbr32
80102d7e:	55                   	push   %ebp
80102d7f:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102d81:	6a 00                	push   $0x0
80102d83:	e8 be ff ff ff       	call   80102d46 <cmos_read>
80102d88:	83 c4 04             	add    $0x4,%esp
80102d8b:	8b 55 08             	mov    0x8(%ebp),%edx
80102d8e:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102d90:	6a 02                	push   $0x2
80102d92:	e8 af ff ff ff       	call   80102d46 <cmos_read>
80102d97:	83 c4 04             	add    $0x4,%esp
80102d9a:	8b 55 08             	mov    0x8(%ebp),%edx
80102d9d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102da0:	6a 04                	push   $0x4
80102da2:	e8 9f ff ff ff       	call   80102d46 <cmos_read>
80102da7:	83 c4 04             	add    $0x4,%esp
80102daa:	8b 55 08             	mov    0x8(%ebp),%edx
80102dad:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102db0:	6a 07                	push   $0x7
80102db2:	e8 8f ff ff ff       	call   80102d46 <cmos_read>
80102db7:	83 c4 04             	add    $0x4,%esp
80102dba:	8b 55 08             	mov    0x8(%ebp),%edx
80102dbd:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102dc0:	6a 08                	push   $0x8
80102dc2:	e8 7f ff ff ff       	call   80102d46 <cmos_read>
80102dc7:	83 c4 04             	add    $0x4,%esp
80102dca:	8b 55 08             	mov    0x8(%ebp),%edx
80102dcd:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102dd0:	6a 09                	push   $0x9
80102dd2:	e8 6f ff ff ff       	call   80102d46 <cmos_read>
80102dd7:	83 c4 04             	add    $0x4,%esp
80102dda:	8b 55 08             	mov    0x8(%ebp),%edx
80102ddd:	89 42 14             	mov    %eax,0x14(%edx)
}
80102de0:	90                   	nop
80102de1:	c9                   	leave
80102de2:	c3                   	ret

80102de3 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102de3:	f3 0f 1e fb          	endbr32
80102de7:	55                   	push   %ebp
80102de8:	89 e5                	mov    %esp,%ebp
80102dea:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102ded:	6a 0b                	push   $0xb
80102def:	e8 52 ff ff ff       	call   80102d46 <cmos_read>
80102df4:	83 c4 04             	add    $0x4,%esp
80102df7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dfd:	83 e0 04             	and    $0x4,%eax
80102e00:	85 c0                	test   %eax,%eax
80102e02:	0f 94 c0             	sete   %al
80102e05:	0f b6 c0             	movzbl %al,%eax
80102e08:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102e0b:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e0e:	50                   	push   %eax
80102e0f:	e8 66 ff ff ff       	call   80102d7a <fill_rtcdate>
80102e14:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102e17:	6a 0a                	push   $0xa
80102e19:	e8 28 ff ff ff       	call   80102d46 <cmos_read>
80102e1e:	83 c4 04             	add    $0x4,%esp
80102e21:	25 80 00 00 00       	and    $0x80,%eax
80102e26:	85 c0                	test   %eax,%eax
80102e28:	75 27                	jne    80102e51 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80102e2a:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e2d:	50                   	push   %eax
80102e2e:	e8 47 ff ff ff       	call   80102d7a <fill_rtcdate>
80102e33:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102e36:	83 ec 04             	sub    $0x4,%esp
80102e39:	6a 18                	push   $0x18
80102e3b:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e3e:	50                   	push   %eax
80102e3f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e42:	50                   	push   %eax
80102e43:	e8 ef 1e 00 00       	call   80104d37 <memcmp>
80102e48:	83 c4 10             	add    $0x10,%esp
80102e4b:	85 c0                	test   %eax,%eax
80102e4d:	74 05                	je     80102e54 <cmostime+0x71>
80102e4f:	eb ba                	jmp    80102e0b <cmostime+0x28>
        continue;
80102e51:	90                   	nop
    fill_rtcdate(&t1);
80102e52:	eb b7                	jmp    80102e0b <cmostime+0x28>
      break;
80102e54:	90                   	nop
  }

  // convert
  if(bcd) {
80102e55:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102e59:	0f 84 b4 00 00 00    	je     80102f13 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102e5f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102e62:	c1 e8 04             	shr    $0x4,%eax
80102e65:	89 c2                	mov    %eax,%edx
80102e67:	89 d0                	mov    %edx,%eax
80102e69:	c1 e0 02             	shl    $0x2,%eax
80102e6c:	01 d0                	add    %edx,%eax
80102e6e:	01 c0                	add    %eax,%eax
80102e70:	89 c2                	mov    %eax,%edx
80102e72:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102e75:	83 e0 0f             	and    $0xf,%eax
80102e78:	01 d0                	add    %edx,%eax
80102e7a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102e7d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102e80:	c1 e8 04             	shr    $0x4,%eax
80102e83:	89 c2                	mov    %eax,%edx
80102e85:	89 d0                	mov    %edx,%eax
80102e87:	c1 e0 02             	shl    $0x2,%eax
80102e8a:	01 d0                	add    %edx,%eax
80102e8c:	01 c0                	add    %eax,%eax
80102e8e:	89 c2                	mov    %eax,%edx
80102e90:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102e93:	83 e0 0f             	and    $0xf,%eax
80102e96:	01 d0                	add    %edx,%eax
80102e98:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102e9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102e9e:	c1 e8 04             	shr    $0x4,%eax
80102ea1:	89 c2                	mov    %eax,%edx
80102ea3:	89 d0                	mov    %edx,%eax
80102ea5:	c1 e0 02             	shl    $0x2,%eax
80102ea8:	01 d0                	add    %edx,%eax
80102eaa:	01 c0                	add    %eax,%eax
80102eac:	89 c2                	mov    %eax,%edx
80102eae:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102eb1:	83 e0 0f             	and    $0xf,%eax
80102eb4:	01 d0                	add    %edx,%eax
80102eb6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102eb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102ebc:	c1 e8 04             	shr    $0x4,%eax
80102ebf:	89 c2                	mov    %eax,%edx
80102ec1:	89 d0                	mov    %edx,%eax
80102ec3:	c1 e0 02             	shl    $0x2,%eax
80102ec6:	01 d0                	add    %edx,%eax
80102ec8:	01 c0                	add    %eax,%eax
80102eca:	89 c2                	mov    %eax,%edx
80102ecc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102ecf:	83 e0 0f             	and    $0xf,%eax
80102ed2:	01 d0                	add    %edx,%eax
80102ed4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102ed7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102eda:	c1 e8 04             	shr    $0x4,%eax
80102edd:	89 c2                	mov    %eax,%edx
80102edf:	89 d0                	mov    %edx,%eax
80102ee1:	c1 e0 02             	shl    $0x2,%eax
80102ee4:	01 d0                	add    %edx,%eax
80102ee6:	01 c0                	add    %eax,%eax
80102ee8:	89 c2                	mov    %eax,%edx
80102eea:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102eed:	83 e0 0f             	and    $0xf,%eax
80102ef0:	01 d0                	add    %edx,%eax
80102ef2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102ef5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ef8:	c1 e8 04             	shr    $0x4,%eax
80102efb:	89 c2                	mov    %eax,%edx
80102efd:	89 d0                	mov    %edx,%eax
80102eff:	c1 e0 02             	shl    $0x2,%eax
80102f02:	01 d0                	add    %edx,%eax
80102f04:	01 c0                	add    %eax,%eax
80102f06:	89 c2                	mov    %eax,%edx
80102f08:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f0b:	83 e0 0f             	and    $0xf,%eax
80102f0e:	01 d0                	add    %edx,%eax
80102f10:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102f13:	8b 45 08             	mov    0x8(%ebp),%eax
80102f16:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102f19:	89 10                	mov    %edx,(%eax)
80102f1b:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102f1e:	89 50 04             	mov    %edx,0x4(%eax)
80102f21:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102f24:	89 50 08             	mov    %edx,0x8(%eax)
80102f27:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102f2a:	89 50 0c             	mov    %edx,0xc(%eax)
80102f2d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102f30:	89 50 10             	mov    %edx,0x10(%eax)
80102f33:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102f36:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102f39:	8b 45 08             	mov    0x8(%ebp),%eax
80102f3c:	8b 40 14             	mov    0x14(%eax),%eax
80102f3f:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102f45:	8b 45 08             	mov    0x8(%ebp),%eax
80102f48:	89 50 14             	mov    %edx,0x14(%eax)
}
80102f4b:	90                   	nop
80102f4c:	c9                   	leave
80102f4d:	c3                   	ret

80102f4e <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102f4e:	f3 0f 1e fb          	endbr32
80102f52:	55                   	push   %ebp
80102f53:	89 e5                	mov    %esp,%ebp
80102f55:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102f58:	83 ec 08             	sub    $0x8,%esp
80102f5b:	68 31 a8 10 80       	push   $0x8010a831
80102f60:	68 20 54 19 80       	push   $0x80195420
80102f65:	e8 ad 1a 00 00       	call   80104a17 <initlock>
80102f6a:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102f6d:	83 ec 08             	sub    $0x8,%esp
80102f70:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102f73:	50                   	push   %eax
80102f74:	ff 75 08             	push   0x8(%ebp)
80102f77:	e8 c0 e4 ff ff       	call   8010143c <readsb>
80102f7c:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102f7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f82:	a3 54 54 19 80       	mov    %eax,0x80195454
  log.size = sb.nlog;
80102f87:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f8a:	a3 58 54 19 80       	mov    %eax,0x80195458
  log.dev = dev;
80102f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80102f92:	a3 64 54 19 80       	mov    %eax,0x80195464
  recover_from_log();
80102f97:	e8 bf 01 00 00       	call   8010315b <recover_from_log>
}
80102f9c:	90                   	nop
80102f9d:	c9                   	leave
80102f9e:	c3                   	ret

80102f9f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102f9f:	f3 0f 1e fb          	endbr32
80102fa3:	55                   	push   %ebp
80102fa4:	89 e5                	mov    %esp,%ebp
80102fa6:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102fa9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fb0:	e9 95 00 00 00       	jmp    8010304a <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102fb5:	8b 15 54 54 19 80    	mov    0x80195454,%edx
80102fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fbe:	01 d0                	add    %edx,%eax
80102fc0:	83 c0 01             	add    $0x1,%eax
80102fc3:	89 c2                	mov    %eax,%edx
80102fc5:	a1 64 54 19 80       	mov    0x80195464,%eax
80102fca:	83 ec 08             	sub    $0x8,%esp
80102fcd:	52                   	push   %edx
80102fce:	50                   	push   %eax
80102fcf:	e8 35 d2 ff ff       	call   80100209 <bread>
80102fd4:	83 c4 10             	add    $0x10,%esp
80102fd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fdd:	83 c0 10             	add    $0x10,%eax
80102fe0:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80102fe7:	89 c2                	mov    %eax,%edx
80102fe9:	a1 64 54 19 80       	mov    0x80195464,%eax
80102fee:	83 ec 08             	sub    $0x8,%esp
80102ff1:	52                   	push   %edx
80102ff2:	50                   	push   %eax
80102ff3:	e8 11 d2 ff ff       	call   80100209 <bread>
80102ff8:	83 c4 10             	add    $0x10,%esp
80102ffb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ffe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103001:	8d 50 5c             	lea    0x5c(%eax),%edx
80103004:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103007:	83 c0 5c             	add    $0x5c,%eax
8010300a:	83 ec 04             	sub    $0x4,%esp
8010300d:	68 00 02 00 00       	push   $0x200
80103012:	52                   	push   %edx
80103013:	50                   	push   %eax
80103014:	e8 7a 1d 00 00       	call   80104d93 <memmove>
80103019:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010301c:	83 ec 0c             	sub    $0xc,%esp
8010301f:	ff 75 ec             	push   -0x14(%ebp)
80103022:	e8 1f d2 ff ff       	call   80100246 <bwrite>
80103027:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
8010302a:	83 ec 0c             	sub    $0xc,%esp
8010302d:	ff 75 f0             	push   -0x10(%ebp)
80103030:	e8 5e d2 ff ff       	call   80100293 <brelse>
80103035:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103038:	83 ec 0c             	sub    $0xc,%esp
8010303b:	ff 75 ec             	push   -0x14(%ebp)
8010303e:	e8 50 d2 ff ff       	call   80100293 <brelse>
80103043:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103046:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010304a:	a1 68 54 19 80       	mov    0x80195468,%eax
8010304f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103052:	0f 8c 5d ff ff ff    	jl     80102fb5 <install_trans+0x16>
  }
}
80103058:	90                   	nop
80103059:	90                   	nop
8010305a:	c9                   	leave
8010305b:	c3                   	ret

8010305c <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010305c:	f3 0f 1e fb          	endbr32
80103060:	55                   	push   %ebp
80103061:	89 e5                	mov    %esp,%ebp
80103063:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103066:	a1 54 54 19 80       	mov    0x80195454,%eax
8010306b:	89 c2                	mov    %eax,%edx
8010306d:	a1 64 54 19 80       	mov    0x80195464,%eax
80103072:	83 ec 08             	sub    $0x8,%esp
80103075:	52                   	push   %edx
80103076:	50                   	push   %eax
80103077:	e8 8d d1 ff ff       	call   80100209 <bread>
8010307c:	83 c4 10             	add    $0x10,%esp
8010307f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103082:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103085:	83 c0 5c             	add    $0x5c,%eax
80103088:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010308b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010308e:	8b 00                	mov    (%eax),%eax
80103090:	a3 68 54 19 80       	mov    %eax,0x80195468
  for (i = 0; i < log.lh.n; i++) {
80103095:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010309c:	eb 1b                	jmp    801030b9 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
8010309e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801030a4:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801030a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801030ab:	83 c2 10             	add    $0x10,%edx
801030ae:	89 04 95 2c 54 19 80 	mov    %eax,-0x7fe6abd4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801030b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801030b9:	a1 68 54 19 80       	mov    0x80195468,%eax
801030be:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801030c1:	7c db                	jl     8010309e <read_head+0x42>
  }
  brelse(buf);
801030c3:	83 ec 0c             	sub    $0xc,%esp
801030c6:	ff 75 f0             	push   -0x10(%ebp)
801030c9:	e8 c5 d1 ff ff       	call   80100293 <brelse>
801030ce:	83 c4 10             	add    $0x10,%esp
}
801030d1:	90                   	nop
801030d2:	c9                   	leave
801030d3:	c3                   	ret

801030d4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801030d4:	f3 0f 1e fb          	endbr32
801030d8:	55                   	push   %ebp
801030d9:	89 e5                	mov    %esp,%ebp
801030db:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801030de:	a1 54 54 19 80       	mov    0x80195454,%eax
801030e3:	89 c2                	mov    %eax,%edx
801030e5:	a1 64 54 19 80       	mov    0x80195464,%eax
801030ea:	83 ec 08             	sub    $0x8,%esp
801030ed:	52                   	push   %edx
801030ee:	50                   	push   %eax
801030ef:	e8 15 d1 ff ff       	call   80100209 <bread>
801030f4:	83 c4 10             	add    $0x10,%esp
801030f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801030fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030fd:	83 c0 5c             	add    $0x5c,%eax
80103100:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103103:	8b 15 68 54 19 80    	mov    0x80195468,%edx
80103109:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010310c:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010310e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103115:	eb 1b                	jmp    80103132 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010311a:	83 c0 10             	add    $0x10,%eax
8010311d:	8b 0c 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%ecx
80103124:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103127:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010312a:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010312e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103132:	a1 68 54 19 80       	mov    0x80195468,%eax
80103137:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010313a:	7c db                	jl     80103117 <write_head+0x43>
  }
  bwrite(buf);
8010313c:	83 ec 0c             	sub    $0xc,%esp
8010313f:	ff 75 f0             	push   -0x10(%ebp)
80103142:	e8 ff d0 ff ff       	call   80100246 <bwrite>
80103147:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010314a:	83 ec 0c             	sub    $0xc,%esp
8010314d:	ff 75 f0             	push   -0x10(%ebp)
80103150:	e8 3e d1 ff ff       	call   80100293 <brelse>
80103155:	83 c4 10             	add    $0x10,%esp
}
80103158:	90                   	nop
80103159:	c9                   	leave
8010315a:	c3                   	ret

8010315b <recover_from_log>:

static void
recover_from_log(void)
{
8010315b:	f3 0f 1e fb          	endbr32
8010315f:	55                   	push   %ebp
80103160:	89 e5                	mov    %esp,%ebp
80103162:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103165:	e8 f2 fe ff ff       	call   8010305c <read_head>
  install_trans(); // if committed, copy from log to disk
8010316a:	e8 30 fe ff ff       	call   80102f9f <install_trans>
  log.lh.n = 0;
8010316f:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
80103176:	00 00 00 
  write_head(); // clear the log
80103179:	e8 56 ff ff ff       	call   801030d4 <write_head>
}
8010317e:	90                   	nop
8010317f:	c9                   	leave
80103180:	c3                   	ret

80103181 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103181:	f3 0f 1e fb          	endbr32
80103185:	55                   	push   %ebp
80103186:	89 e5                	mov    %esp,%ebp
80103188:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010318b:	83 ec 0c             	sub    $0xc,%esp
8010318e:	68 20 54 19 80       	push   $0x80195420
80103193:	e8 a5 18 00 00       	call   80104a3d <acquire>
80103198:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010319b:	a1 60 54 19 80       	mov    0x80195460,%eax
801031a0:	85 c0                	test   %eax,%eax
801031a2:	74 17                	je     801031bb <begin_op+0x3a>
      sleep(&log, &log.lock);
801031a4:	83 ec 08             	sub    $0x8,%esp
801031a7:	68 20 54 19 80       	push   $0x80195420
801031ac:	68 20 54 19 80       	push   $0x80195420
801031b1:	e8 0e 13 00 00       	call   801044c4 <sleep>
801031b6:	83 c4 10             	add    $0x10,%esp
801031b9:	eb e0                	jmp    8010319b <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801031bb:	8b 0d 68 54 19 80    	mov    0x80195468,%ecx
801031c1:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801031c6:	8d 50 01             	lea    0x1(%eax),%edx
801031c9:	89 d0                	mov    %edx,%eax
801031cb:	c1 e0 02             	shl    $0x2,%eax
801031ce:	01 d0                	add    %edx,%eax
801031d0:	01 c0                	add    %eax,%eax
801031d2:	01 c8                	add    %ecx,%eax
801031d4:	83 f8 1e             	cmp    $0x1e,%eax
801031d7:	7e 17                	jle    801031f0 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801031d9:	83 ec 08             	sub    $0x8,%esp
801031dc:	68 20 54 19 80       	push   $0x80195420
801031e1:	68 20 54 19 80       	push   $0x80195420
801031e6:	e8 d9 12 00 00       	call   801044c4 <sleep>
801031eb:	83 c4 10             	add    $0x10,%esp
801031ee:	eb ab                	jmp    8010319b <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801031f0:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801031f5:	83 c0 01             	add    $0x1,%eax
801031f8:	a3 5c 54 19 80       	mov    %eax,0x8019545c
      release(&log.lock);
801031fd:	83 ec 0c             	sub    $0xc,%esp
80103200:	68 20 54 19 80       	push   $0x80195420
80103205:	e8 a5 18 00 00       	call   80104aaf <release>
8010320a:	83 c4 10             	add    $0x10,%esp
      break;
8010320d:	90                   	nop
    }
  }
}
8010320e:	90                   	nop
8010320f:	c9                   	leave
80103210:	c3                   	ret

80103211 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103211:	f3 0f 1e fb          	endbr32
80103215:	55                   	push   %ebp
80103216:	89 e5                	mov    %esp,%ebp
80103218:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010321b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103222:	83 ec 0c             	sub    $0xc,%esp
80103225:	68 20 54 19 80       	push   $0x80195420
8010322a:	e8 0e 18 00 00       	call   80104a3d <acquire>
8010322f:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103232:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103237:	83 e8 01             	sub    $0x1,%eax
8010323a:	a3 5c 54 19 80       	mov    %eax,0x8019545c
  if(log.committing)
8010323f:	a1 60 54 19 80       	mov    0x80195460,%eax
80103244:	85 c0                	test   %eax,%eax
80103246:	74 0d                	je     80103255 <end_op+0x44>
    panic("log.committing");
80103248:	83 ec 0c             	sub    $0xc,%esp
8010324b:	68 35 a8 10 80       	push   $0x8010a835
80103250:	e8 89 d3 ff ff       	call   801005de <panic>
  if(log.outstanding == 0){
80103255:	a1 5c 54 19 80       	mov    0x8019545c,%eax
8010325a:	85 c0                	test   %eax,%eax
8010325c:	75 13                	jne    80103271 <end_op+0x60>
    do_commit = 1;
8010325e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103265:	c7 05 60 54 19 80 01 	movl   $0x1,0x80195460
8010326c:	00 00 00 
8010326f:	eb 10                	jmp    80103281 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103271:	83 ec 0c             	sub    $0xc,%esp
80103274:	68 20 54 19 80       	push   $0x80195420
80103279:	e8 35 13 00 00       	call   801045b3 <wakeup>
8010327e:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103281:	83 ec 0c             	sub    $0xc,%esp
80103284:	68 20 54 19 80       	push   $0x80195420
80103289:	e8 21 18 00 00       	call   80104aaf <release>
8010328e:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103291:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103295:	74 3f                	je     801032d6 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103297:	e8 fa 00 00 00       	call   80103396 <commit>
    acquire(&log.lock);
8010329c:	83 ec 0c             	sub    $0xc,%esp
8010329f:	68 20 54 19 80       	push   $0x80195420
801032a4:	e8 94 17 00 00       	call   80104a3d <acquire>
801032a9:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
801032ac:	c7 05 60 54 19 80 00 	movl   $0x0,0x80195460
801032b3:	00 00 00 
    wakeup(&log);
801032b6:	83 ec 0c             	sub    $0xc,%esp
801032b9:	68 20 54 19 80       	push   $0x80195420
801032be:	e8 f0 12 00 00       	call   801045b3 <wakeup>
801032c3:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801032c6:	83 ec 0c             	sub    $0xc,%esp
801032c9:	68 20 54 19 80       	push   $0x80195420
801032ce:	e8 dc 17 00 00       	call   80104aaf <release>
801032d3:	83 c4 10             	add    $0x10,%esp
  }
}
801032d6:	90                   	nop
801032d7:	c9                   	leave
801032d8:	c3                   	ret

801032d9 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801032d9:	f3 0f 1e fb          	endbr32
801032dd:	55                   	push   %ebp
801032de:	89 e5                	mov    %esp,%ebp
801032e0:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032ea:	e9 95 00 00 00       	jmp    80103384 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801032ef:	8b 15 54 54 19 80    	mov    0x80195454,%edx
801032f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032f8:	01 d0                	add    %edx,%eax
801032fa:	83 c0 01             	add    $0x1,%eax
801032fd:	89 c2                	mov    %eax,%edx
801032ff:	a1 64 54 19 80       	mov    0x80195464,%eax
80103304:	83 ec 08             	sub    $0x8,%esp
80103307:	52                   	push   %edx
80103308:	50                   	push   %eax
80103309:	e8 fb ce ff ff       	call   80100209 <bread>
8010330e:	83 c4 10             	add    $0x10,%esp
80103311:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103317:	83 c0 10             	add    $0x10,%eax
8010331a:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103321:	89 c2                	mov    %eax,%edx
80103323:	a1 64 54 19 80       	mov    0x80195464,%eax
80103328:	83 ec 08             	sub    $0x8,%esp
8010332b:	52                   	push   %edx
8010332c:	50                   	push   %eax
8010332d:	e8 d7 ce ff ff       	call   80100209 <bread>
80103332:	83 c4 10             	add    $0x10,%esp
80103335:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103338:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010333b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010333e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103341:	83 c0 5c             	add    $0x5c,%eax
80103344:	83 ec 04             	sub    $0x4,%esp
80103347:	68 00 02 00 00       	push   $0x200
8010334c:	52                   	push   %edx
8010334d:	50                   	push   %eax
8010334e:	e8 40 1a 00 00       	call   80104d93 <memmove>
80103353:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103356:	83 ec 0c             	sub    $0xc,%esp
80103359:	ff 75 f0             	push   -0x10(%ebp)
8010335c:	e8 e5 ce ff ff       	call   80100246 <bwrite>
80103361:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103364:	83 ec 0c             	sub    $0xc,%esp
80103367:	ff 75 ec             	push   -0x14(%ebp)
8010336a:	e8 24 cf ff ff       	call   80100293 <brelse>
8010336f:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103372:	83 ec 0c             	sub    $0xc,%esp
80103375:	ff 75 f0             	push   -0x10(%ebp)
80103378:	e8 16 cf ff ff       	call   80100293 <brelse>
8010337d:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103380:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103384:	a1 68 54 19 80       	mov    0x80195468,%eax
80103389:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010338c:	0f 8c 5d ff ff ff    	jl     801032ef <write_log+0x16>
  }
}
80103392:	90                   	nop
80103393:	90                   	nop
80103394:	c9                   	leave
80103395:	c3                   	ret

80103396 <commit>:

static void
commit()
{
80103396:	f3 0f 1e fb          	endbr32
8010339a:	55                   	push   %ebp
8010339b:	89 e5                	mov    %esp,%ebp
8010339d:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801033a0:	a1 68 54 19 80       	mov    0x80195468,%eax
801033a5:	85 c0                	test   %eax,%eax
801033a7:	7e 1e                	jle    801033c7 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
801033a9:	e8 2b ff ff ff       	call   801032d9 <write_log>
    write_head();    // Write header to disk -- the real commit
801033ae:	e8 21 fd ff ff       	call   801030d4 <write_head>
    install_trans(); // Now install writes to home locations
801033b3:	e8 e7 fb ff ff       	call   80102f9f <install_trans>
    log.lh.n = 0;
801033b8:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
801033bf:	00 00 00 
    write_head();    // Erase the transaction from the log
801033c2:	e8 0d fd ff ff       	call   801030d4 <write_head>
  }
}
801033c7:	90                   	nop
801033c8:	c9                   	leave
801033c9:	c3                   	ret

801033ca <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801033ca:	f3 0f 1e fb          	endbr32
801033ce:	55                   	push   %ebp
801033cf:	89 e5                	mov    %esp,%ebp
801033d1:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801033d4:	a1 68 54 19 80       	mov    0x80195468,%eax
801033d9:	83 f8 1d             	cmp    $0x1d,%eax
801033dc:	7f 12                	jg     801033f0 <log_write+0x26>
801033de:	a1 68 54 19 80       	mov    0x80195468,%eax
801033e3:	8b 15 58 54 19 80    	mov    0x80195458,%edx
801033e9:	83 ea 01             	sub    $0x1,%edx
801033ec:	39 d0                	cmp    %edx,%eax
801033ee:	7c 0d                	jl     801033fd <log_write+0x33>
    panic("too big a transaction");
801033f0:	83 ec 0c             	sub    $0xc,%esp
801033f3:	68 44 a8 10 80       	push   $0x8010a844
801033f8:	e8 e1 d1 ff ff       	call   801005de <panic>
  if (log.outstanding < 1)
801033fd:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103402:	85 c0                	test   %eax,%eax
80103404:	7f 0d                	jg     80103413 <log_write+0x49>
    panic("log_write outside of trans");
80103406:	83 ec 0c             	sub    $0xc,%esp
80103409:	68 5a a8 10 80       	push   $0x8010a85a
8010340e:	e8 cb d1 ff ff       	call   801005de <panic>

  acquire(&log.lock);
80103413:	83 ec 0c             	sub    $0xc,%esp
80103416:	68 20 54 19 80       	push   $0x80195420
8010341b:	e8 1d 16 00 00       	call   80104a3d <acquire>
80103420:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103423:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010342a:	eb 1d                	jmp    80103449 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010342c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010342f:	83 c0 10             	add    $0x10,%eax
80103432:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103439:	89 c2                	mov    %eax,%edx
8010343b:	8b 45 08             	mov    0x8(%ebp),%eax
8010343e:	8b 40 08             	mov    0x8(%eax),%eax
80103441:	39 c2                	cmp    %eax,%edx
80103443:	74 10                	je     80103455 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103445:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103449:	a1 68 54 19 80       	mov    0x80195468,%eax
8010344e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103451:	7c d9                	jl     8010342c <log_write+0x62>
80103453:	eb 01                	jmp    80103456 <log_write+0x8c>
      break;
80103455:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103456:	8b 45 08             	mov    0x8(%ebp),%eax
80103459:	8b 40 08             	mov    0x8(%eax),%eax
8010345c:	89 c2                	mov    %eax,%edx
8010345e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103461:	83 c0 10             	add    $0x10,%eax
80103464:	89 14 85 2c 54 19 80 	mov    %edx,-0x7fe6abd4(,%eax,4)
  if (i == log.lh.n)
8010346b:	a1 68 54 19 80       	mov    0x80195468,%eax
80103470:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103473:	75 0d                	jne    80103482 <log_write+0xb8>
    log.lh.n++;
80103475:	a1 68 54 19 80       	mov    0x80195468,%eax
8010347a:	83 c0 01             	add    $0x1,%eax
8010347d:	a3 68 54 19 80       	mov    %eax,0x80195468
  b->flags |= B_DIRTY; // prevent eviction
80103482:	8b 45 08             	mov    0x8(%ebp),%eax
80103485:	8b 00                	mov    (%eax),%eax
80103487:	83 c8 04             	or     $0x4,%eax
8010348a:	89 c2                	mov    %eax,%edx
8010348c:	8b 45 08             	mov    0x8(%ebp),%eax
8010348f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103491:	83 ec 0c             	sub    $0xc,%esp
80103494:	68 20 54 19 80       	push   $0x80195420
80103499:	e8 11 16 00 00       	call   80104aaf <release>
8010349e:	83 c4 10             	add    $0x10,%esp
}
801034a1:	90                   	nop
801034a2:	c9                   	leave
801034a3:	c3                   	ret

801034a4 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801034a4:	55                   	push   %ebp
801034a5:	89 e5                	mov    %esp,%ebp
801034a7:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801034aa:	8b 55 08             	mov    0x8(%ebp),%edx
801034ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801034b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
801034b3:	f0 87 02             	lock xchg %eax,(%edx)
801034b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801034b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801034bc:	c9                   	leave
801034bd:	c3                   	ret

801034be <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801034be:	f3 0f 1e fb          	endbr32
801034c2:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801034c6:	83 e4 f0             	and    $0xfffffff0,%esp
801034c9:	ff 71 fc             	push   -0x4(%ecx)
801034cc:	55                   	push   %ebp
801034cd:	89 e5                	mov    %esp,%ebp
801034cf:	51                   	push   %ecx
801034d0:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
801034d3:	e8 c0 4d 00 00       	call   80108298 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801034d8:	83 ec 08             	sub    $0x8,%esp
801034db:	68 00 00 40 80       	push   $0x80400000
801034e0:	68 00 90 19 80       	push   $0x80199000
801034e5:	e8 73 f2 ff ff       	call   8010275d <kinit1>
801034ea:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034ed:	e8 98 43 00 00       	call   8010788a <kvmalloc>
  mpinit_uefi();
801034f2:	e8 5a 4b 00 00       	call   80108051 <mpinit_uefi>
  lapicinit();     // interrupt controller
801034f7:	e8 f0 f5 ff ff       	call   80102aec <lapicinit>
  seginit();       // segment descriptors
801034fc:	e8 10 3e 00 00       	call   80107311 <seginit>
  picinit();    // disable pic
80103501:	e8 a9 01 00 00       	call   801036af <picinit>
  ioapicinit();    // another interrupt controller
80103506:	e8 65 f1 ff ff       	call   80102670 <ioapicinit>
  consoleinit();   // console hardware
8010350b:	e8 42 d6 ff ff       	call   80100b52 <consoleinit>
  uartinit();      // serial port
80103510:	e8 85 31 00 00       	call   8010669a <uartinit>
  pinit();         // process table
80103515:	e8 e2 05 00 00       	call   80103afc <pinit>
  tvinit();        // trap vectors
8010351a:	e8 a5 2c 00 00       	call   801061c4 <tvinit>
  binit();         // buffer cache
8010351f:	e8 42 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103524:	e8 e8 da ff ff       	call   80101011 <fileinit>
  ideinit();       // disk 
80103529:	e8 6f 6f 00 00       	call   8010a49d <ideinit>
  startothers();   // start other processors
8010352e:	e8 92 00 00 00       	call   801035c5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103533:	83 ec 08             	sub    $0x8,%esp
80103536:	68 00 00 00 a0       	push   $0xa0000000
8010353b:	68 00 00 40 80       	push   $0x80400000
80103540:	e8 55 f2 ff ff       	call   8010279a <kinit2>
80103545:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103548:	e8 be 4f 00 00       	call   8010850b <pci_init>
  arp_scan();
8010354d:	e8 37 5d 00 00       	call   80109289 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
80103552:	e8 9b 07 00 00       	call   80103cf2 <userinit>
  mpmain();        // finish this processor's setup
80103557:	e8 1e 00 00 00       	call   8010357a <mpmain>

8010355c <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010355c:	f3 0f 1e fb          	endbr32
80103560:	55                   	push   %ebp
80103561:	89 e5                	mov    %esp,%ebp
80103563:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103566:	e8 3b 43 00 00       	call   801078a6 <switchkvm>
  seginit();
8010356b:	e8 a1 3d 00 00       	call   80107311 <seginit>
  lapicinit();
80103570:	e8 77 f5 ff ff       	call   80102aec <lapicinit>
  mpmain();
80103575:	e8 00 00 00 00       	call   8010357a <mpmain>

8010357a <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010357a:	f3 0f 1e fb          	endbr32
8010357e:	55                   	push   %ebp
8010357f:	89 e5                	mov    %esp,%ebp
80103581:	53                   	push   %ebx
80103582:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103585:	e8 94 05 00 00       	call   80103b1e <cpuid>
8010358a:	89 c3                	mov    %eax,%ebx
8010358c:	e8 8d 05 00 00       	call   80103b1e <cpuid>
80103591:	83 ec 04             	sub    $0x4,%esp
80103594:	53                   	push   %ebx
80103595:	50                   	push   %eax
80103596:	68 75 a8 10 80       	push   $0x8010a875
8010359b:	e8 6c ce ff ff       	call   8010040c <cprintf>
801035a0:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801035a3:	e8 96 2d 00 00       	call   8010633e <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801035a8:	e8 90 05 00 00       	call   80103b3d <mycpu>
801035ad:	05 a0 00 00 00       	add    $0xa0,%eax
801035b2:	83 ec 08             	sub    $0x8,%esp
801035b5:	6a 01                	push   $0x1
801035b7:	50                   	push   %eax
801035b8:	e8 e7 fe ff ff       	call   801034a4 <xchg>
801035bd:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801035c0:	e8 dc 0c 00 00       	call   801042a1 <scheduler>

801035c5 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801035c5:	f3 0f 1e fb          	endbr32
801035c9:	55                   	push   %ebp
801035ca:	89 e5                	mov    %esp,%ebp
801035cc:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801035cf:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801035d6:	b8 8a 00 00 00       	mov    $0x8a,%eax
801035db:	83 ec 04             	sub    $0x4,%esp
801035de:	50                   	push   %eax
801035df:	68 18 f5 10 80       	push   $0x8010f518
801035e4:	ff 75 f0             	push   -0x10(%ebp)
801035e7:	e8 a7 17 00 00       	call   80104d93 <memmove>
801035ec:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801035ef:	c7 45 f4 c0 7d 19 80 	movl   $0x80197dc0,-0xc(%ebp)
801035f6:	eb 79                	jmp    80103671 <startothers+0xac>
    if(c == mycpu()){  // We've started already.
801035f8:	e8 40 05 00 00       	call   80103b3d <mycpu>
801035fd:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103600:	74 67                	je     80103669 <startothers+0xa4>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103602:	e8 9b f2 ff ff       	call   801028a2 <kalloc>
80103607:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010360a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010360d:	83 e8 04             	sub    $0x4,%eax
80103610:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103613:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103619:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010361b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010361e:	83 e8 08             	sub    $0x8,%eax
80103621:	c7 00 5c 35 10 80    	movl   $0x8010355c,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103627:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
8010362c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103632:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103635:	83 e8 0c             	sub    $0xc,%eax
80103638:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
8010363a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010363d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103646:	0f b6 00             	movzbl (%eax),%eax
80103649:	0f b6 c0             	movzbl %al,%eax
8010364c:	83 ec 08             	sub    $0x8,%esp
8010364f:	52                   	push   %edx
80103650:	50                   	push   %eax
80103651:	e8 08 f6 ff ff       	call   80102c5e <lapicstartap>
80103656:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103659:	90                   	nop
8010365a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010365d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103663:	85 c0                	test   %eax,%eax
80103665:	74 f3                	je     8010365a <startothers+0x95>
80103667:	eb 01                	jmp    8010366a <startothers+0xa5>
      continue;
80103669:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
8010366a:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103671:	a1 80 80 19 80       	mov    0x80198080,%eax
80103676:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010367c:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103681:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103684:	0f 82 6e ff ff ff    	jb     801035f8 <startothers+0x33>
      ;
  }
}
8010368a:	90                   	nop
8010368b:	90                   	nop
8010368c:	c9                   	leave
8010368d:	c3                   	ret

8010368e <outb>:
{
8010368e:	55                   	push   %ebp
8010368f:	89 e5                	mov    %esp,%ebp
80103691:	83 ec 08             	sub    $0x8,%esp
80103694:	8b 45 08             	mov    0x8(%ebp),%eax
80103697:	8b 55 0c             	mov    0xc(%ebp),%edx
8010369a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010369e:	89 d0                	mov    %edx,%eax
801036a0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801036a3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801036a7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801036ab:	ee                   	out    %al,(%dx)
}
801036ac:	90                   	nop
801036ad:	c9                   	leave
801036ae:	c3                   	ret

801036af <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
801036af:	f3 0f 1e fb          	endbr32
801036b3:	55                   	push   %ebp
801036b4:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801036b6:	68 ff 00 00 00       	push   $0xff
801036bb:	6a 21                	push   $0x21
801036bd:	e8 cc ff ff ff       	call   8010368e <outb>
801036c2:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
801036c5:	68 ff 00 00 00       	push   $0xff
801036ca:	68 a1 00 00 00       	push   $0xa1
801036cf:	e8 ba ff ff ff       	call   8010368e <outb>
801036d4:	83 c4 08             	add    $0x8,%esp
}
801036d7:	90                   	nop
801036d8:	c9                   	leave
801036d9:	c3                   	ret

801036da <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801036da:	f3 0f 1e fb          	endbr32
801036de:	55                   	push   %ebp
801036df:	89 e5                	mov    %esp,%ebp
801036e1:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801036e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801036eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801036ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801036f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801036f7:	8b 10                	mov    (%eax),%edx
801036f9:	8b 45 08             	mov    0x8(%ebp),%eax
801036fc:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801036fe:	e8 30 d9 ff ff       	call   80101033 <filealloc>
80103703:	8b 55 08             	mov    0x8(%ebp),%edx
80103706:	89 02                	mov    %eax,(%edx)
80103708:	8b 45 08             	mov    0x8(%ebp),%eax
8010370b:	8b 00                	mov    (%eax),%eax
8010370d:	85 c0                	test   %eax,%eax
8010370f:	0f 84 c8 00 00 00    	je     801037dd <pipealloc+0x103>
80103715:	e8 19 d9 ff ff       	call   80101033 <filealloc>
8010371a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010371d:	89 02                	mov    %eax,(%edx)
8010371f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103722:	8b 00                	mov    (%eax),%eax
80103724:	85 c0                	test   %eax,%eax
80103726:	0f 84 b1 00 00 00    	je     801037dd <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010372c:	e8 71 f1 ff ff       	call   801028a2 <kalloc>
80103731:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103734:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103738:	0f 84 a2 00 00 00    	je     801037e0 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
8010373e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103741:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103748:	00 00 00 
  p->writeopen = 1;
8010374b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010374e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103755:	00 00 00 
  p->nwrite = 0;
80103758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010375b:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103762:	00 00 00 
  p->nread = 0;
80103765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103768:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010376f:	00 00 00 
  initlock(&p->lock, "pipe");
80103772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103775:	83 ec 08             	sub    $0x8,%esp
80103778:	68 89 a8 10 80       	push   $0x8010a889
8010377d:	50                   	push   %eax
8010377e:	e8 94 12 00 00       	call   80104a17 <initlock>
80103783:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103786:	8b 45 08             	mov    0x8(%ebp),%eax
80103789:	8b 00                	mov    (%eax),%eax
8010378b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103791:	8b 45 08             	mov    0x8(%ebp),%eax
80103794:	8b 00                	mov    (%eax),%eax
80103796:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010379a:	8b 45 08             	mov    0x8(%ebp),%eax
8010379d:	8b 00                	mov    (%eax),%eax
8010379f:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801037a3:	8b 45 08             	mov    0x8(%ebp),%eax
801037a6:	8b 00                	mov    (%eax),%eax
801037a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037ab:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801037ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801037b1:	8b 00                	mov    (%eax),%eax
801037b3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801037b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801037bc:	8b 00                	mov    (%eax),%eax
801037be:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801037c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801037c5:	8b 00                	mov    (%eax),%eax
801037c7:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801037cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801037ce:	8b 00                	mov    (%eax),%eax
801037d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037d3:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801037d6:	b8 00 00 00 00       	mov    $0x0,%eax
801037db:	eb 51                	jmp    8010382e <pipealloc+0x154>
    goto bad;
801037dd:	90                   	nop
801037de:	eb 01                	jmp    801037e1 <pipealloc+0x107>
    goto bad;
801037e0:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
801037e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037e5:	74 0e                	je     801037f5 <pipealloc+0x11b>
    kfree((char*)p);
801037e7:	83 ec 0c             	sub    $0xc,%esp
801037ea:	ff 75 f4             	push   -0xc(%ebp)
801037ed:	e8 12 f0 ff ff       	call   80102804 <kfree>
801037f2:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801037f5:	8b 45 08             	mov    0x8(%ebp),%eax
801037f8:	8b 00                	mov    (%eax),%eax
801037fa:	85 c0                	test   %eax,%eax
801037fc:	74 11                	je     8010380f <pipealloc+0x135>
    fileclose(*f0);
801037fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103801:	8b 00                	mov    (%eax),%eax
80103803:	83 ec 0c             	sub    $0xc,%esp
80103806:	50                   	push   %eax
80103807:	e8 ed d8 ff ff       	call   801010f9 <fileclose>
8010380c:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010380f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103812:	8b 00                	mov    (%eax),%eax
80103814:	85 c0                	test   %eax,%eax
80103816:	74 11                	je     80103829 <pipealloc+0x14f>
    fileclose(*f1);
80103818:	8b 45 0c             	mov    0xc(%ebp),%eax
8010381b:	8b 00                	mov    (%eax),%eax
8010381d:	83 ec 0c             	sub    $0xc,%esp
80103820:	50                   	push   %eax
80103821:	e8 d3 d8 ff ff       	call   801010f9 <fileclose>
80103826:	83 c4 10             	add    $0x10,%esp
  return -1;
80103829:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010382e:	c9                   	leave
8010382f:	c3                   	ret

80103830 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103830:	f3 0f 1e fb          	endbr32
80103834:	55                   	push   %ebp
80103835:	89 e5                	mov    %esp,%ebp
80103837:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010383a:	8b 45 08             	mov    0x8(%ebp),%eax
8010383d:	83 ec 0c             	sub    $0xc,%esp
80103840:	50                   	push   %eax
80103841:	e8 f7 11 00 00       	call   80104a3d <acquire>
80103846:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103849:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010384d:	74 23                	je     80103872 <pipeclose+0x42>
    p->writeopen = 0;
8010384f:	8b 45 08             	mov    0x8(%ebp),%eax
80103852:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103859:	00 00 00 
    wakeup(&p->nread);
8010385c:	8b 45 08             	mov    0x8(%ebp),%eax
8010385f:	05 34 02 00 00       	add    $0x234,%eax
80103864:	83 ec 0c             	sub    $0xc,%esp
80103867:	50                   	push   %eax
80103868:	e8 46 0d 00 00       	call   801045b3 <wakeup>
8010386d:	83 c4 10             	add    $0x10,%esp
80103870:	eb 21                	jmp    80103893 <pipeclose+0x63>
  } else {
    p->readopen = 0;
80103872:	8b 45 08             	mov    0x8(%ebp),%eax
80103875:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010387c:	00 00 00 
    wakeup(&p->nwrite);
8010387f:	8b 45 08             	mov    0x8(%ebp),%eax
80103882:	05 38 02 00 00       	add    $0x238,%eax
80103887:	83 ec 0c             	sub    $0xc,%esp
8010388a:	50                   	push   %eax
8010388b:	e8 23 0d 00 00       	call   801045b3 <wakeup>
80103890:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103893:	8b 45 08             	mov    0x8(%ebp),%eax
80103896:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010389c:	85 c0                	test   %eax,%eax
8010389e:	75 2c                	jne    801038cc <pipeclose+0x9c>
801038a0:	8b 45 08             	mov    0x8(%ebp),%eax
801038a3:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038a9:	85 c0                	test   %eax,%eax
801038ab:	75 1f                	jne    801038cc <pipeclose+0x9c>
    release(&p->lock);
801038ad:	8b 45 08             	mov    0x8(%ebp),%eax
801038b0:	83 ec 0c             	sub    $0xc,%esp
801038b3:	50                   	push   %eax
801038b4:	e8 f6 11 00 00       	call   80104aaf <release>
801038b9:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801038bc:	83 ec 0c             	sub    $0xc,%esp
801038bf:	ff 75 08             	push   0x8(%ebp)
801038c2:	e8 3d ef ff ff       	call   80102804 <kfree>
801038c7:	83 c4 10             	add    $0x10,%esp
801038ca:	eb 10                	jmp    801038dc <pipeclose+0xac>
  } else
    release(&p->lock);
801038cc:	8b 45 08             	mov    0x8(%ebp),%eax
801038cf:	83 ec 0c             	sub    $0xc,%esp
801038d2:	50                   	push   %eax
801038d3:	e8 d7 11 00 00       	call   80104aaf <release>
801038d8:	83 c4 10             	add    $0x10,%esp
}
801038db:	90                   	nop
801038dc:	90                   	nop
801038dd:	c9                   	leave
801038de:	c3                   	ret

801038df <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801038df:	f3 0f 1e fb          	endbr32
801038e3:	55                   	push   %ebp
801038e4:	89 e5                	mov    %esp,%ebp
801038e6:	53                   	push   %ebx
801038e7:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801038ea:	8b 45 08             	mov    0x8(%ebp),%eax
801038ed:	83 ec 0c             	sub    $0xc,%esp
801038f0:	50                   	push   %eax
801038f1:	e8 47 11 00 00       	call   80104a3d <acquire>
801038f6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801038f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103900:	e9 ad 00 00 00       	jmp    801039b2 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103905:	8b 45 08             	mov    0x8(%ebp),%eax
80103908:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010390e:	85 c0                	test   %eax,%eax
80103910:	74 0c                	je     8010391e <pipewrite+0x3f>
80103912:	e8 a2 02 00 00       	call   80103bb9 <myproc>
80103917:	8b 40 24             	mov    0x24(%eax),%eax
8010391a:	85 c0                	test   %eax,%eax
8010391c:	74 19                	je     80103937 <pipewrite+0x58>
        release(&p->lock);
8010391e:	8b 45 08             	mov    0x8(%ebp),%eax
80103921:	83 ec 0c             	sub    $0xc,%esp
80103924:	50                   	push   %eax
80103925:	e8 85 11 00 00       	call   80104aaf <release>
8010392a:	83 c4 10             	add    $0x10,%esp
        return -1;
8010392d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103932:	e9 a9 00 00 00       	jmp    801039e0 <pipewrite+0x101>
      }
      wakeup(&p->nread);
80103937:	8b 45 08             	mov    0x8(%ebp),%eax
8010393a:	05 34 02 00 00       	add    $0x234,%eax
8010393f:	83 ec 0c             	sub    $0xc,%esp
80103942:	50                   	push   %eax
80103943:	e8 6b 0c 00 00       	call   801045b3 <wakeup>
80103948:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010394b:	8b 45 08             	mov    0x8(%ebp),%eax
8010394e:	8b 55 08             	mov    0x8(%ebp),%edx
80103951:	81 c2 38 02 00 00    	add    $0x238,%edx
80103957:	83 ec 08             	sub    $0x8,%esp
8010395a:	50                   	push   %eax
8010395b:	52                   	push   %edx
8010395c:	e8 63 0b 00 00       	call   801044c4 <sleep>
80103961:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103964:	8b 45 08             	mov    0x8(%ebp),%eax
80103967:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010396d:	8b 45 08             	mov    0x8(%ebp),%eax
80103970:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103976:	05 00 02 00 00       	add    $0x200,%eax
8010397b:	39 c2                	cmp    %eax,%edx
8010397d:	74 86                	je     80103905 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010397f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103982:	8b 45 0c             	mov    0xc(%ebp),%eax
80103985:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103988:	8b 45 08             	mov    0x8(%ebp),%eax
8010398b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103991:	8d 48 01             	lea    0x1(%eax),%ecx
80103994:	8b 55 08             	mov    0x8(%ebp),%edx
80103997:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010399d:	25 ff 01 00 00       	and    $0x1ff,%eax
801039a2:	89 c1                	mov    %eax,%ecx
801039a4:	0f b6 13             	movzbl (%ebx),%edx
801039a7:	8b 45 08             	mov    0x8(%ebp),%eax
801039aa:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
801039ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801039b8:	7c aa                	jl     80103964 <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801039ba:	8b 45 08             	mov    0x8(%ebp),%eax
801039bd:	05 34 02 00 00       	add    $0x234,%eax
801039c2:	83 ec 0c             	sub    $0xc,%esp
801039c5:	50                   	push   %eax
801039c6:	e8 e8 0b 00 00       	call   801045b3 <wakeup>
801039cb:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801039ce:	8b 45 08             	mov    0x8(%ebp),%eax
801039d1:	83 ec 0c             	sub    $0xc,%esp
801039d4:	50                   	push   %eax
801039d5:	e8 d5 10 00 00       	call   80104aaf <release>
801039da:	83 c4 10             	add    $0x10,%esp
  return n;
801039dd:	8b 45 10             	mov    0x10(%ebp),%eax
}
801039e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039e3:	c9                   	leave
801039e4:	c3                   	ret

801039e5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801039e5:	f3 0f 1e fb          	endbr32
801039e9:	55                   	push   %ebp
801039ea:	89 e5                	mov    %esp,%ebp
801039ec:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801039ef:	8b 45 08             	mov    0x8(%ebp),%eax
801039f2:	83 ec 0c             	sub    $0xc,%esp
801039f5:	50                   	push   %eax
801039f6:	e8 42 10 00 00       	call   80104a3d <acquire>
801039fb:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801039fe:	eb 3e                	jmp    80103a3e <piperead+0x59>
    if(myproc()->killed){
80103a00:	e8 b4 01 00 00       	call   80103bb9 <myproc>
80103a05:	8b 40 24             	mov    0x24(%eax),%eax
80103a08:	85 c0                	test   %eax,%eax
80103a0a:	74 19                	je     80103a25 <piperead+0x40>
      release(&p->lock);
80103a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a0f:	83 ec 0c             	sub    $0xc,%esp
80103a12:	50                   	push   %eax
80103a13:	e8 97 10 00 00       	call   80104aaf <release>
80103a18:	83 c4 10             	add    $0x10,%esp
      return -1;
80103a1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a20:	e9 be 00 00 00       	jmp    80103ae3 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103a25:	8b 45 08             	mov    0x8(%ebp),%eax
80103a28:	8b 55 08             	mov    0x8(%ebp),%edx
80103a2b:	81 c2 34 02 00 00    	add    $0x234,%edx
80103a31:	83 ec 08             	sub    $0x8,%esp
80103a34:	50                   	push   %eax
80103a35:	52                   	push   %edx
80103a36:	e8 89 0a 00 00       	call   801044c4 <sleep>
80103a3b:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a3e:	8b 45 08             	mov    0x8(%ebp),%eax
80103a41:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a47:	8b 45 08             	mov    0x8(%ebp),%eax
80103a4a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a50:	39 c2                	cmp    %eax,%edx
80103a52:	75 0d                	jne    80103a61 <piperead+0x7c>
80103a54:	8b 45 08             	mov    0x8(%ebp),%eax
80103a57:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103a5d:	85 c0                	test   %eax,%eax
80103a5f:	75 9f                	jne    80103a00 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a68:	eb 48                	jmp    80103ab2 <piperead+0xcd>
    if(p->nread == p->nwrite)
80103a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a6d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a73:	8b 45 08             	mov    0x8(%ebp),%eax
80103a76:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a7c:	39 c2                	cmp    %eax,%edx
80103a7e:	74 3c                	je     80103abc <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103a80:	8b 45 08             	mov    0x8(%ebp),%eax
80103a83:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103a89:	8d 48 01             	lea    0x1(%eax),%ecx
80103a8c:	8b 55 08             	mov    0x8(%ebp),%edx
80103a8f:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103a95:	25 ff 01 00 00       	and    $0x1ff,%eax
80103a9a:	89 c1                	mov    %eax,%ecx
80103a9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103aa2:	01 c2                	add    %eax,%edx
80103aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80103aa7:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103aac:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103aae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab5:	3b 45 10             	cmp    0x10(%ebp),%eax
80103ab8:	7c b0                	jl     80103a6a <piperead+0x85>
80103aba:	eb 01                	jmp    80103abd <piperead+0xd8>
      break;
80103abc:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103abd:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac0:	05 38 02 00 00       	add    $0x238,%eax
80103ac5:	83 ec 0c             	sub    $0xc,%esp
80103ac8:	50                   	push   %eax
80103ac9:	e8 e5 0a 00 00       	call   801045b3 <wakeup>
80103ace:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ad1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ad4:	83 ec 0c             	sub    $0xc,%esp
80103ad7:	50                   	push   %eax
80103ad8:	e8 d2 0f 00 00       	call   80104aaf <release>
80103add:	83 c4 10             	add    $0x10,%esp
  return i;
80103ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103ae3:	c9                   	leave
80103ae4:	c3                   	ret

80103ae5 <readeflags>:
{
80103ae5:	55                   	push   %ebp
80103ae6:	89 e5                	mov    %esp,%ebp
80103ae8:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103aeb:	9c                   	pushf
80103aec:	58                   	pop    %eax
80103aed:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103af0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103af3:	c9                   	leave
80103af4:	c3                   	ret

80103af5 <sti>:
{
80103af5:	55                   	push   %ebp
80103af6:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103af8:	fb                   	sti
}
80103af9:	90                   	nop
80103afa:	5d                   	pop    %ebp
80103afb:	c3                   	ret

80103afc <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103afc:	f3 0f 1e fb          	endbr32
80103b00:	55                   	push   %ebp
80103b01:	89 e5                	mov    %esp,%ebp
80103b03:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103b06:	83 ec 08             	sub    $0x8,%esp
80103b09:	68 90 a8 10 80       	push   $0x8010a890
80103b0e:	68 00 55 19 80       	push   $0x80195500
80103b13:	e8 ff 0e 00 00       	call   80104a17 <initlock>
80103b18:	83 c4 10             	add    $0x10,%esp
}
80103b1b:	90                   	nop
80103b1c:	c9                   	leave
80103b1d:	c3                   	ret

80103b1e <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103b1e:	f3 0f 1e fb          	endbr32
80103b22:	55                   	push   %ebp
80103b23:	89 e5                	mov    %esp,%ebp
80103b25:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103b28:	e8 10 00 00 00       	call   80103b3d <mycpu>
80103b2d:	2d c0 7d 19 80       	sub    $0x80197dc0,%eax
80103b32:	c1 f8 04             	sar    $0x4,%eax
80103b35:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103b3b:	c9                   	leave
80103b3c:	c3                   	ret

80103b3d <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103b3d:	f3 0f 1e fb          	endbr32
80103b41:	55                   	push   %ebp
80103b42:	89 e5                	mov    %esp,%ebp
80103b44:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103b47:	e8 99 ff ff ff       	call   80103ae5 <readeflags>
80103b4c:	25 00 02 00 00       	and    $0x200,%eax
80103b51:	85 c0                	test   %eax,%eax
80103b53:	74 0d                	je     80103b62 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80103b55:	83 ec 0c             	sub    $0xc,%esp
80103b58:	68 98 a8 10 80       	push   $0x8010a898
80103b5d:	e8 7c ca ff ff       	call   801005de <panic>
  }

  apicid = lapicid();
80103b62:	e8 a8 f0 ff ff       	call   80102c0f <lapicid>
80103b67:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103b6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b71:	eb 2d                	jmp    80103ba0 <mycpu+0x63>
    if (cpus[i].apicid == apicid){
80103b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b76:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b7c:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103b81:	0f b6 00             	movzbl (%eax),%eax
80103b84:	0f b6 c0             	movzbl %al,%eax
80103b87:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103b8a:	75 10                	jne    80103b9c <mycpu+0x5f>
      return &cpus[i];
80103b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b95:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103b9a:	eb 1b                	jmp    80103bb7 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80103b9c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ba0:	a1 80 80 19 80       	mov    0x80198080,%eax
80103ba5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103ba8:	7c c9                	jl     80103b73 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80103baa:	83 ec 0c             	sub    $0xc,%esp
80103bad:	68 be a8 10 80       	push   $0x8010a8be
80103bb2:	e8 27 ca ff ff       	call   801005de <panic>
}
80103bb7:	c9                   	leave
80103bb8:	c3                   	ret

80103bb9 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103bb9:	f3 0f 1e fb          	endbr32
80103bbd:	55                   	push   %ebp
80103bbe:	89 e5                	mov    %esp,%ebp
80103bc0:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103bc3:	e8 f1 0f 00 00       	call   80104bb9 <pushcli>
  c = mycpu();
80103bc8:	e8 70 ff ff ff       	call   80103b3d <mycpu>
80103bcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103bd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103bdc:	e8 29 10 00 00       	call   80104c0a <popcli>
  return p;
80103be1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103be4:	c9                   	leave
80103be5:	c3                   	ret

80103be6 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103be6:	f3 0f 1e fb          	endbr32
80103bea:	55                   	push   %ebp
80103beb:	89 e5                	mov    %esp,%ebp
80103bed:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;
  acquire(&ptable.lock);
80103bf0:	83 ec 0c             	sub    $0xc,%esp
80103bf3:	68 00 55 19 80       	push   $0x80195500
80103bf8:	e8 40 0e 00 00       	call   80104a3d <acquire>
80103bfd:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c00:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80103c07:	eb 0e                	jmp    80103c17 <allocproc+0x31>
    if(p->state == UNUSED){
80103c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0c:	8b 40 0c             	mov    0xc(%eax),%eax
80103c0f:	85 c0                	test   %eax,%eax
80103c11:	74 27                	je     80103c3a <allocproc+0x54>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c13:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103c17:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80103c1e:	72 e9                	jb     80103c09 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
80103c20:	83 ec 0c             	sub    $0xc,%esp
80103c23:	68 00 55 19 80       	push   $0x80195500
80103c28:	e8 82 0e 00 00       	call   80104aaf <release>
80103c2d:	83 c4 10             	add    $0x10,%esp
  return 0;
80103c30:	b8 00 00 00 00       	mov    $0x0,%eax
80103c35:	e9 b6 00 00 00       	jmp    80103cf0 <allocproc+0x10a>
      goto found;
80103c3a:	90                   	nop
80103c3b:	f3 0f 1e fb          	endbr32

found:
  p->state = EMBRYO;
80103c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c42:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103c49:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103c4e:	8d 50 01             	lea    0x1(%eax),%edx
80103c51:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103c57:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c5a:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103c5d:	83 ec 0c             	sub    $0xc,%esp
80103c60:	68 00 55 19 80       	push   $0x80195500
80103c65:	e8 45 0e 00 00       	call   80104aaf <release>
80103c6a:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103c6d:	e8 30 ec ff ff       	call   801028a2 <kalloc>
80103c72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c75:	89 42 08             	mov    %eax,0x8(%edx)
80103c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7b:	8b 40 08             	mov    0x8(%eax),%eax
80103c7e:	85 c0                	test   %eax,%eax
80103c80:	75 11                	jne    80103c93 <allocproc+0xad>
    p->state = UNUSED;
80103c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c85:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103c8c:	b8 00 00 00 00       	mov    $0x0,%eax
80103c91:	eb 5d                	jmp    80103cf0 <allocproc+0x10a>
  }
  sp = p->kstack + KSTACKSIZE;
80103c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c96:	8b 40 08             	mov    0x8(%eax),%eax
80103c99:	05 00 10 00 00       	add    $0x1000,%eax
80103c9e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103ca1:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103cab:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103cae:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103cb2:	ba 7e 61 10 80       	mov    $0x8010617e,%edx
80103cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cba:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103cbc:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103cc6:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ccc:	8b 40 1c             	mov    0x1c(%eax),%eax
80103ccf:	83 ec 04             	sub    $0x4,%esp
80103cd2:	6a 14                	push   $0x14
80103cd4:	6a 00                	push   $0x0
80103cd6:	50                   	push   %eax
80103cd7:	e8 f0 0f 00 00       	call   80104ccc <memset>
80103cdc:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce2:	8b 40 1c             	mov    0x1c(%eax),%eax
80103ce5:	ba 7a 44 10 80       	mov    $0x8010447a,%edx
80103cea:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103cf0:	c9                   	leave
80103cf1:	c3                   	ret

80103cf2 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103cf2:	f3 0f 1e fb          	endbr32
80103cf6:	55                   	push   %ebp
80103cf7:	89 e5                	mov    %esp,%ebp
80103cf9:	83 ec 18             	sub    $0x18,%esp
  cprintf("[userinit] in \n");
80103cfc:	83 ec 0c             	sub    $0xc,%esp
80103cff:	68 ce a8 10 80       	push   $0x8010a8ce
80103d04:	e8 03 c7 ff ff       	call   8010040c <cprintf>
80103d09:	83 c4 10             	add    $0x10,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103d0c:	e8 d5 fe ff ff       	call   80103be6 <allocproc>
80103d11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d17:	a3 5c d0 18 80       	mov    %eax,0x8018d05c
  if((p->pgdir = setupkvm()) == 0){
80103d1c:	e8 78 3a 00 00       	call   80107799 <setupkvm>
80103d21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d24:	89 42 04             	mov    %eax,0x4(%edx)
80103d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d2a:	8b 40 04             	mov    0x4(%eax),%eax
80103d2d:	85 c0                	test   %eax,%eax
80103d2f:	75 0d                	jne    80103d3e <userinit+0x4c>
    panic("userinit: out of memory?");
80103d31:	83 ec 0c             	sub    $0xc,%esp
80103d34:	68 de a8 10 80       	push   $0x8010a8de
80103d39:	e8 a0 c8 ff ff       	call   801005de <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103d3e:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d46:	8b 40 04             	mov    0x4(%eax),%eax
80103d49:	83 ec 04             	sub    $0x4,%esp
80103d4c:	52                   	push   %edx
80103d4d:	68 ec f4 10 80       	push   $0x8010f4ec
80103d52:	50                   	push   %eax
80103d53:	e8 0e 3d 00 00       	call   80107a66 <inituvm>
80103d58:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d5e:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d67:	8b 40 18             	mov    0x18(%eax),%eax
80103d6a:	83 ec 04             	sub    $0x4,%esp
80103d6d:	6a 4c                	push   $0x4c
80103d6f:	6a 00                	push   $0x0
80103d71:	50                   	push   %eax
80103d72:	e8 55 0f 00 00       	call   80104ccc <memset>
80103d77:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d7d:	8b 40 18             	mov    0x18(%eax),%eax
80103d80:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d89:	8b 40 18             	mov    0x18(%eax),%eax
80103d8c:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d95:	8b 50 18             	mov    0x18(%eax),%edx
80103d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d9b:	8b 40 18             	mov    0x18(%eax),%eax
80103d9e:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103da2:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da9:	8b 50 18             	mov    0x18(%eax),%edx
80103dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103daf:	8b 40 18             	mov    0x18(%eax),%eax
80103db2:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103db6:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dbd:	8b 40 18             	mov    0x18(%eax),%eax
80103dc0:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dca:	8b 40 18             	mov    0x18(%eax),%eax
80103dcd:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd7:	8b 40 18             	mov    0x18(%eax),%eax
80103dda:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103de4:	83 c0 6c             	add    $0x6c,%eax
80103de7:	83 ec 04             	sub    $0x4,%esp
80103dea:	6a 10                	push   $0x10
80103dec:	68 f7 a8 10 80       	push   $0x8010a8f7
80103df1:	50                   	push   %eax
80103df2:	e8 f0 10 00 00       	call   80104ee7 <safestrcpy>
80103df7:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103dfa:	83 ec 0c             	sub    $0xc,%esp
80103dfd:	68 00 a9 10 80       	push   $0x8010a900
80103e02:	e8 f0 e7 ff ff       	call   801025f7 <namei>
80103e07:	83 c4 10             	add    $0x10,%esp
80103e0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e0d:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103e10:	83 ec 0c             	sub    $0xc,%esp
80103e13:	68 00 55 19 80       	push   $0x80195500
80103e18:	e8 20 0c 00 00       	call   80104a3d <acquire>
80103e1d:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e23:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e2a:	83 ec 0c             	sub    $0xc,%esp
80103e2d:	68 00 55 19 80       	push   $0x80195500
80103e32:	e8 78 0c 00 00       	call   80104aaf <release>
80103e37:	83 c4 10             	add    $0x10,%esp
}
80103e3a:	90                   	nop
80103e3b:	c9                   	leave
80103e3c:	c3                   	ret

80103e3d <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103e3d:	f3 0f 1e fb          	endbr32
80103e41:	55                   	push   %ebp
80103e42:	89 e5                	mov    %esp,%ebp
80103e44:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103e47:	e8 6d fd ff ff       	call   80103bb9 <myproc>
80103e4c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103e4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e52:	8b 00                	mov    (%eax),%eax
80103e54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103e57:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103e5b:	7e 2e                	jle    80103e8b <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e5d:	8b 55 08             	mov    0x8(%ebp),%edx
80103e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e63:	01 c2                	add    %eax,%edx
80103e65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e68:	8b 40 04             	mov    0x4(%eax),%eax
80103e6b:	83 ec 04             	sub    $0x4,%esp
80103e6e:	52                   	push   %edx
80103e6f:	ff 75 f4             	push   -0xc(%ebp)
80103e72:	50                   	push   %eax
80103e73:	e8 33 3d 00 00       	call   80107bab <allocuvm>
80103e78:	83 c4 10             	add    $0x10,%esp
80103e7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e7e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e82:	75 3b                	jne    80103ebf <growproc+0x82>
      return -1;
80103e84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e89:	eb 4f                	jmp    80103eda <growproc+0x9d>
  } else if(n < 0){
80103e8b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103e8f:	79 2e                	jns    80103ebf <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e91:	8b 55 08             	mov    0x8(%ebp),%edx
80103e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e97:	01 c2                	add    %eax,%edx
80103e99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e9c:	8b 40 04             	mov    0x4(%eax),%eax
80103e9f:	83 ec 04             	sub    $0x4,%esp
80103ea2:	52                   	push   %edx
80103ea3:	ff 75 f4             	push   -0xc(%ebp)
80103ea6:	50                   	push   %eax
80103ea7:	e8 08 3e 00 00       	call   80107cb4 <deallocuvm>
80103eac:	83 c4 10             	add    $0x10,%esp
80103eaf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103eb2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103eb6:	75 07                	jne    80103ebf <growproc+0x82>
      return -1;
80103eb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ebd:	eb 1b                	jmp    80103eda <growproc+0x9d>
  }
  curproc->sz = sz;
80103ebf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ec2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ec5:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103ec7:	83 ec 0c             	sub    $0xc,%esp
80103eca:	ff 75 f0             	push   -0x10(%ebp)
80103ecd:	e8 f1 39 00 00       	call   801078c3 <switchuvm>
80103ed2:	83 c4 10             	add    $0x10,%esp
  return 0;
80103ed5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103eda:	c9                   	leave
80103edb:	c3                   	ret

80103edc <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103edc:	f3 0f 1e fb          	endbr32
80103ee0:	55                   	push   %ebp
80103ee1:	89 e5                	mov    %esp,%ebp
80103ee3:	57                   	push   %edi
80103ee4:	56                   	push   %esi
80103ee5:	53                   	push   %ebx
80103ee6:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103ee9:	e8 cb fc ff ff       	call   80103bb9 <myproc>
80103eee:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103ef1:	e8 f0 fc ff ff       	call   80103be6 <allocproc>
80103ef6:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103ef9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103efd:	75 0a                	jne    80103f09 <fork+0x2d>
    return -1;
80103eff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f04:	e9 48 01 00 00       	jmp    80104051 <fork+0x175>
  } 
  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103f09:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f0c:	8b 10                	mov    (%eax),%edx
80103f0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f11:	8b 40 04             	mov    0x4(%eax),%eax
80103f14:	83 ec 08             	sub    $0x8,%esp
80103f17:	52                   	push   %edx
80103f18:	50                   	push   %eax
80103f19:	e8 40 3f 00 00       	call   80107e5e <copyuvm>
80103f1e:	83 c4 10             	add    $0x10,%esp
80103f21:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f24:	89 42 04             	mov    %eax,0x4(%edx)
80103f27:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f2a:	8b 40 04             	mov    0x4(%eax),%eax
80103f2d:	85 c0                	test   %eax,%eax
80103f2f:	75 30                	jne    80103f61 <fork+0x85>
    kfree(np->kstack);
80103f31:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f34:	8b 40 08             	mov    0x8(%eax),%eax
80103f37:	83 ec 0c             	sub    $0xc,%esp
80103f3a:	50                   	push   %eax
80103f3b:	e8 c4 e8 ff ff       	call   80102804 <kfree>
80103f40:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103f43:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f46:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103f4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f50:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103f57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f5c:	e9 f0 00 00 00       	jmp    80104051 <fork+0x175>
  }
  np->sz = curproc->sz;
80103f61:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f64:	8b 10                	mov    (%eax),%edx
80103f66:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f69:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103f6b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f6e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103f71:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103f74:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f77:	8b 48 18             	mov    0x18(%eax),%ecx
80103f7a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f7d:	8b 40 18             	mov    0x18(%eax),%eax
80103f80:	89 c2                	mov    %eax,%edx
80103f82:	89 cb                	mov    %ecx,%ebx
80103f84:	b8 13 00 00 00       	mov    $0x13,%eax
80103f89:	89 d7                	mov    %edx,%edi
80103f8b:	89 de                	mov    %ebx,%esi
80103f8d:	89 c1                	mov    %eax,%ecx
80103f8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103f91:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f94:	8b 40 18             	mov    0x18(%eax),%eax
80103f97:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103f9e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103fa5:	eb 3b                	jmp    80103fe2 <fork+0x106>
    if(curproc->ofile[i])
80103fa7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103faa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103fad:	83 c2 08             	add    $0x8,%edx
80103fb0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fb4:	85 c0                	test   %eax,%eax
80103fb6:	74 26                	je     80103fde <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103fb8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fbb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103fbe:	83 c2 08             	add    $0x8,%edx
80103fc1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fc5:	83 ec 0c             	sub    $0xc,%esp
80103fc8:	50                   	push   %eax
80103fc9:	e8 d6 d0 ff ff       	call   801010a4 <filedup>
80103fce:	83 c4 10             	add    $0x10,%esp
80103fd1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fd4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103fd7:	83 c1 08             	add    $0x8,%ecx
80103fda:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103fde:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103fe2:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103fe6:	7e bf                	jle    80103fa7 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80103fe8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103feb:	8b 40 68             	mov    0x68(%eax),%eax
80103fee:	83 ec 0c             	sub    $0xc,%esp
80103ff1:	50                   	push   %eax
80103ff2:	e8 57 da ff ff       	call   80101a4e <idup>
80103ff7:	83 c4 10             	add    $0x10,%esp
80103ffa:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103ffd:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104000:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104003:	8d 50 6c             	lea    0x6c(%eax),%edx
80104006:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104009:	83 c0 6c             	add    $0x6c,%eax
8010400c:	83 ec 04             	sub    $0x4,%esp
8010400f:	6a 10                	push   $0x10
80104011:	52                   	push   %edx
80104012:	50                   	push   %eax
80104013:	e8 cf 0e 00 00       	call   80104ee7 <safestrcpy>
80104018:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
8010401b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010401e:	8b 40 10             	mov    0x10(%eax),%eax
80104021:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104024:	83 ec 0c             	sub    $0xc,%esp
80104027:	68 00 55 19 80       	push   $0x80195500
8010402c:	e8 0c 0a 00 00       	call   80104a3d <acquire>
80104031:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104034:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104037:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010403e:	83 ec 0c             	sub    $0xc,%esp
80104041:	68 00 55 19 80       	push   $0x80195500
80104046:	e8 64 0a 00 00       	call   80104aaf <release>
8010404b:	83 c4 10             	add    $0x10,%esp
  return pid;
8010404e:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104051:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104054:	5b                   	pop    %ebx
80104055:	5e                   	pop    %esi
80104056:	5f                   	pop    %edi
80104057:	5d                   	pop    %ebp
80104058:	c3                   	ret

80104059 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104059:	f3 0f 1e fb          	endbr32
8010405d:	55                   	push   %ebp
8010405e:	89 e5                	mov    %esp,%ebp
80104060:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104063:	e8 51 fb ff ff       	call   80103bb9 <myproc>
80104068:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010406b:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104070:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104073:	75 0d                	jne    80104082 <exit+0x29>
    panic("init exiting");
80104075:	83 ec 0c             	sub    $0xc,%esp
80104078:	68 02 a9 10 80       	push   $0x8010a902
8010407d:	e8 5c c5 ff ff       	call   801005de <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104082:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104089:	eb 3f                	jmp    801040ca <exit+0x71>
    if(curproc->ofile[fd]){
8010408b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010408e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104091:	83 c2 08             	add    $0x8,%edx
80104094:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104098:	85 c0                	test   %eax,%eax
8010409a:	74 2a                	je     801040c6 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
8010409c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010409f:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040a2:	83 c2 08             	add    $0x8,%edx
801040a5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801040a9:	83 ec 0c             	sub    $0xc,%esp
801040ac:	50                   	push   %eax
801040ad:	e8 47 d0 ff ff       	call   801010f9 <fileclose>
801040b2:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801040b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040bb:	83 c2 08             	add    $0x8,%edx
801040be:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801040c5:	00 
  for(fd = 0; fd < NOFILE; fd++){
801040c6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801040ca:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801040ce:	7e bb                	jle    8010408b <exit+0x32>
    }
  }

  begin_op();
801040d0:	e8 ac f0 ff ff       	call   80103181 <begin_op>
  iput(curproc->cwd);
801040d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040d8:	8b 40 68             	mov    0x68(%eax),%eax
801040db:	83 ec 0c             	sub    $0xc,%esp
801040de:	50                   	push   %eax
801040df:	e8 11 db ff ff       	call   80101bf5 <iput>
801040e4:	83 c4 10             	add    $0x10,%esp
  end_op();
801040e7:	e8 25 f1 ff ff       	call   80103211 <end_op>
  curproc->cwd = 0;
801040ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040ef:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801040f6:	83 ec 0c             	sub    $0xc,%esp
801040f9:	68 00 55 19 80       	push   $0x80195500
801040fe:	e8 3a 09 00 00       	call   80104a3d <acquire>
80104103:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104106:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104109:	8b 40 14             	mov    0x14(%eax),%eax
8010410c:	83 ec 0c             	sub    $0xc,%esp
8010410f:	50                   	push   %eax
80104110:	e8 5a 04 00 00       	call   8010456f <wakeup1>
80104115:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104118:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010411f:	eb 37                	jmp    80104158 <exit+0xff>
    if(p->parent == curproc){
80104121:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104124:	8b 40 14             	mov    0x14(%eax),%eax
80104127:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010412a:	75 28                	jne    80104154 <exit+0xfb>
      p->parent = initproc;
8010412c:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
80104132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104135:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413b:	8b 40 0c             	mov    0xc(%eax),%eax
8010413e:	83 f8 05             	cmp    $0x5,%eax
80104141:	75 11                	jne    80104154 <exit+0xfb>
        wakeup1(initproc);
80104143:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104148:	83 ec 0c             	sub    $0xc,%esp
8010414b:	50                   	push   %eax
8010414c:	e8 1e 04 00 00       	call   8010456f <wakeup1>
80104151:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104154:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104158:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
8010415f:	72 c0                	jb     80104121 <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104161:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104164:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010416b:	e8 0f 02 00 00       	call   8010437f <sched>
  panic("zombie exit");
80104170:	83 ec 0c             	sub    $0xc,%esp
80104173:	68 0f a9 10 80       	push   $0x8010a90f
80104178:	e8 61 c4 ff ff       	call   801005de <panic>

8010417d <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010417d:	f3 0f 1e fb          	endbr32
80104181:	55                   	push   %ebp
80104182:	89 e5                	mov    %esp,%ebp
80104184:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104187:	e8 2d fa ff ff       	call   80103bb9 <myproc>
8010418c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
8010418f:	83 ec 0c             	sub    $0xc,%esp
80104192:	68 00 55 19 80       	push   $0x80195500
80104197:	e8 a1 08 00 00       	call   80104a3d <acquire>
8010419c:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
8010419f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041a6:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801041ad:	e9 a1 00 00 00       	jmp    80104253 <wait+0xd6>
      if(p->parent != curproc)
801041b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b5:	8b 40 14             	mov    0x14(%eax),%eax
801041b8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801041bb:	0f 85 8d 00 00 00    	jne    8010424e <wait+0xd1>
        continue;
      havekids = 1;
801041c1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801041c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041cb:	8b 40 0c             	mov    0xc(%eax),%eax
801041ce:	83 f8 05             	cmp    $0x5,%eax
801041d1:	75 7c                	jne    8010424f <wait+0xd2>
        // Found one.
        pid = p->pid;
801041d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d6:	8b 40 10             	mov    0x10(%eax),%eax
801041d9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801041dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041df:	8b 40 08             	mov    0x8(%eax),%eax
801041e2:	83 ec 0c             	sub    $0xc,%esp
801041e5:	50                   	push   %eax
801041e6:	e8 19 e6 ff ff       	call   80102804 <kfree>
801041eb:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801041ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801041f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041fb:	8b 40 04             	mov    0x4(%eax),%eax
801041fe:	83 ec 0c             	sub    $0xc,%esp
80104201:	50                   	push   %eax
80104202:	e8 75 3b 00 00       	call   80107d7c <freevm>
80104207:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010420a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010420d:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104217:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010421e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104221:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104228:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010422f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104232:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104239:	83 ec 0c             	sub    $0xc,%esp
8010423c:	68 00 55 19 80       	push   $0x80195500
80104241:	e8 69 08 00 00       	call   80104aaf <release>
80104246:	83 c4 10             	add    $0x10,%esp
        return pid;
80104249:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010424c:	eb 51                	jmp    8010429f <wait+0x122>
        continue;
8010424e:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010424f:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104253:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
8010425a:	0f 82 52 ff ff ff    	jb     801041b2 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104260:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104264:	74 0a                	je     80104270 <wait+0xf3>
80104266:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104269:	8b 40 24             	mov    0x24(%eax),%eax
8010426c:	85 c0                	test   %eax,%eax
8010426e:	74 17                	je     80104287 <wait+0x10a>
      release(&ptable.lock);
80104270:	83 ec 0c             	sub    $0xc,%esp
80104273:	68 00 55 19 80       	push   $0x80195500
80104278:	e8 32 08 00 00       	call   80104aaf <release>
8010427d:	83 c4 10             	add    $0x10,%esp
      return -1;
80104280:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104285:	eb 18                	jmp    8010429f <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104287:	83 ec 08             	sub    $0x8,%esp
8010428a:	68 00 55 19 80       	push   $0x80195500
8010428f:	ff 75 ec             	push   -0x14(%ebp)
80104292:	e8 2d 02 00 00       	call   801044c4 <sleep>
80104297:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010429a:	e9 00 ff ff ff       	jmp    8010419f <wait+0x22>
  }
}
8010429f:	c9                   	leave
801042a0:	c3                   	ret

801042a1 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801042a1:	f3 0f 1e fb          	endbr32
801042a5:	55                   	push   %ebp
801042a6:	89 e5                	mov    %esp,%ebp
801042a8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801042ab:	e8 8d f8 ff ff       	call   80103b3d <mycpu>
801042b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801042b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042b6:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801042bd:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801042c0:	e8 30 f8 ff ff       	call   80103af5 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801042c5:	83 ec 0c             	sub    $0xc,%esp
801042c8:	68 00 55 19 80       	push   $0x80195500
801042cd:	e8 6b 07 00 00       	call   80104a3d <acquire>
801042d2:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042d5:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801042dc:	eb 61                	jmp    8010433f <scheduler+0x9e>
      if(p->state != RUNNABLE)
801042de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e1:	8b 40 0c             	mov    0xc(%eax),%eax
801042e4:	83 f8 03             	cmp    $0x3,%eax
801042e7:	75 51                	jne    8010433a <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
801042e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042ef:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
801042f5:	83 ec 0c             	sub    $0xc,%esp
801042f8:	ff 75 f4             	push   -0xc(%ebp)
801042fb:	e8 c3 35 00 00       	call   801078c3 <switchuvm>
80104300:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104306:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&(c->scheduler), p->context);
8010430d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104310:	8b 40 1c             	mov    0x1c(%eax),%eax
80104313:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104316:	83 c2 04             	add    $0x4,%edx
80104319:	83 ec 08             	sub    $0x8,%esp
8010431c:	50                   	push   %eax
8010431d:	52                   	push   %edx
8010431e:	e8 3d 0c 00 00       	call   80104f60 <swtch>
80104323:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104326:	e8 7b 35 00 00       	call   801078a6 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
8010432b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010432e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104335:	00 00 00 
80104338:	eb 01                	jmp    8010433b <scheduler+0x9a>
        continue;
8010433a:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010433b:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010433f:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80104346:	72 96                	jb     801042de <scheduler+0x3d>
    }
    release(&ptable.lock);
80104348:	83 ec 0c             	sub    $0xc,%esp
8010434b:	68 00 55 19 80       	push   $0x80195500
80104350:	e8 5a 07 00 00       	call   80104aaf <release>
80104355:	83 c4 10             	add    $0x10,%esp
    sti();
80104358:	e9 63 ff ff ff       	jmp    801042c0 <scheduler+0x1f>

8010435d <uthread_init>:
// uthread_init: 유저 레벨 쓰레드의 스케줄러의 주소를 커널의 proccess에 넘겨준다.
// 이 함수를 시스템콜에서 호출하여 uthread의 스케줄러의 주소를 가져오고 
// 커널에서 인터럽트가 발생할 때 uthread의 스케줄러를 실행할 수 있게 된다.
int 
uthread_init(int address)
{
8010435d:	f3 0f 1e fb          	endbr32
80104361:	55                   	push   %ebp
80104362:	89 e5                	mov    %esp,%ebp
80104364:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104367:	e8 4d f8 ff ff       	call   80103bb9 <myproc>
8010436c:	89 45 f4             	mov    %eax,-0xc(%ebp)
//  p->trapflag = 1;
  curproc->scheduler = (uint)address;
8010436f:	8b 55 08             	mov    0x8(%ebp),%edx
80104372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104375:	89 50 7c             	mov    %edx,0x7c(%eax)
  //cprintf("address: %d", address);
  return 0;
80104378:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010437d:	c9                   	leave
8010437e:	c3                   	ret

8010437f <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
8010437f:	f3 0f 1e fb          	endbr32
80104383:	55                   	push   %ebp
80104384:	89 e5                	mov    %esp,%ebp
80104386:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104389:	e8 2b f8 ff ff       	call   80103bb9 <myproc>
8010438e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104391:	83 ec 0c             	sub    $0xc,%esp
80104394:	68 00 55 19 80       	push   $0x80195500
80104399:	e8 e6 07 00 00       	call   80104b84 <holding>
8010439e:	83 c4 10             	add    $0x10,%esp
801043a1:	85 c0                	test   %eax,%eax
801043a3:	75 0d                	jne    801043b2 <sched+0x33>
    panic("sched ptable.lock");
801043a5:	83 ec 0c             	sub    $0xc,%esp
801043a8:	68 1b a9 10 80       	push   $0x8010a91b
801043ad:	e8 2c c2 ff ff       	call   801005de <panic>
  if(mycpu()->ncli != 1)
801043b2:	e8 86 f7 ff ff       	call   80103b3d <mycpu>
801043b7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801043bd:	83 f8 01             	cmp    $0x1,%eax
801043c0:	74 0d                	je     801043cf <sched+0x50>
    panic("sched locks");
801043c2:	83 ec 0c             	sub    $0xc,%esp
801043c5:	68 2d a9 10 80       	push   $0x8010a92d
801043ca:	e8 0f c2 ff ff       	call   801005de <panic>
  if(p->state == RUNNING)
801043cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d2:	8b 40 0c             	mov    0xc(%eax),%eax
801043d5:	83 f8 04             	cmp    $0x4,%eax
801043d8:	75 0d                	jne    801043e7 <sched+0x68>
    panic("sched running");
801043da:	83 ec 0c             	sub    $0xc,%esp
801043dd:	68 39 a9 10 80       	push   $0x8010a939
801043e2:	e8 f7 c1 ff ff       	call   801005de <panic>
  if(readeflags()&FL_IF)
801043e7:	e8 f9 f6 ff ff       	call   80103ae5 <readeflags>
801043ec:	25 00 02 00 00       	and    $0x200,%eax
801043f1:	85 c0                	test   %eax,%eax
801043f3:	74 0d                	je     80104402 <sched+0x83>
    panic("sched interruptible");
801043f5:	83 ec 0c             	sub    $0xc,%esp
801043f8:	68 47 a9 10 80       	push   $0x8010a947
801043fd:	e8 dc c1 ff ff       	call   801005de <panic>
  intena = mycpu()->intena;
80104402:	e8 36 f7 ff ff       	call   80103b3d <mycpu>
80104407:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010440d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104410:	e8 28 f7 ff ff       	call   80103b3d <mycpu>
80104415:	8b 40 04             	mov    0x4(%eax),%eax
80104418:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010441b:	83 c2 1c             	add    $0x1c,%edx
8010441e:	83 ec 08             	sub    $0x8,%esp
80104421:	50                   	push   %eax
80104422:	52                   	push   %edx
80104423:	e8 38 0b 00 00       	call   80104f60 <swtch>
80104428:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
8010442b:	e8 0d f7 ff ff       	call   80103b3d <mycpu>
80104430:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104433:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104439:	90                   	nop
8010443a:	c9                   	leave
8010443b:	c3                   	ret

8010443c <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010443c:	f3 0f 1e fb          	endbr32
80104440:	55                   	push   %ebp
80104441:	89 e5                	mov    %esp,%ebp
80104443:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104446:	83 ec 0c             	sub    $0xc,%esp
80104449:	68 00 55 19 80       	push   $0x80195500
8010444e:	e8 ea 05 00 00       	call   80104a3d <acquire>
80104453:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104456:	e8 5e f7 ff ff       	call   80103bb9 <myproc>
8010445b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104462:	e8 18 ff ff ff       	call   8010437f <sched>
  release(&ptable.lock);
80104467:	83 ec 0c             	sub    $0xc,%esp
8010446a:	68 00 55 19 80       	push   $0x80195500
8010446f:	e8 3b 06 00 00       	call   80104aaf <release>
80104474:	83 c4 10             	add    $0x10,%esp
}
80104477:	90                   	nop
80104478:	c9                   	leave
80104479:	c3                   	ret

8010447a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010447a:	f3 0f 1e fb          	endbr32
8010447e:	55                   	push   %ebp
8010447f:	89 e5                	mov    %esp,%ebp
80104481:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104484:	83 ec 0c             	sub    $0xc,%esp
80104487:	68 00 55 19 80       	push   $0x80195500
8010448c:	e8 1e 06 00 00       	call   80104aaf <release>
80104491:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104494:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104499:	85 c0                	test   %eax,%eax
8010449b:	74 24                	je     801044c1 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010449d:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801044a4:	00 00 00 
    iinit(ROOTDEV);
801044a7:	83 ec 0c             	sub    $0xc,%esp
801044aa:	6a 01                	push   $0x1
801044ac:	e8 55 d2 ff ff       	call   80101706 <iinit>
801044b1:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801044b4:	83 ec 0c             	sub    $0xc,%esp
801044b7:	6a 01                	push   $0x1
801044b9:	e8 90 ea ff ff       	call   80102f4e <initlog>
801044be:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801044c1:	90                   	nop
801044c2:	c9                   	leave
801044c3:	c3                   	ret

801044c4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801044c4:	f3 0f 1e fb          	endbr32
801044c8:	55                   	push   %ebp
801044c9:	89 e5                	mov    %esp,%ebp
801044cb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801044ce:	e8 e6 f6 ff ff       	call   80103bb9 <myproc>
801044d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801044d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801044da:	75 0d                	jne    801044e9 <sleep+0x25>
    panic("sleep");
801044dc:	83 ec 0c             	sub    $0xc,%esp
801044df:	68 5b a9 10 80       	push   $0x8010a95b
801044e4:	e8 f5 c0 ff ff       	call   801005de <panic>

  if(lk == 0)
801044e9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801044ed:	75 0d                	jne    801044fc <sleep+0x38>
    panic("sleep without lk");
801044ef:	83 ec 0c             	sub    $0xc,%esp
801044f2:	68 61 a9 10 80       	push   $0x8010a961
801044f7:	e8 e2 c0 ff ff       	call   801005de <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801044fc:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
80104503:	74 1e                	je     80104523 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104505:	83 ec 0c             	sub    $0xc,%esp
80104508:	68 00 55 19 80       	push   $0x80195500
8010450d:	e8 2b 05 00 00       	call   80104a3d <acquire>
80104512:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104515:	83 ec 0c             	sub    $0xc,%esp
80104518:	ff 75 0c             	push   0xc(%ebp)
8010451b:	e8 8f 05 00 00       	call   80104aaf <release>
80104520:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104523:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104526:	8b 55 08             	mov    0x8(%ebp),%edx
80104529:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010452c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452f:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104536:	e8 44 fe ff ff       	call   8010437f <sched>

  // Tidy up.
  p->chan = 0;
8010453b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453e:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104545:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
8010454c:	74 1e                	je     8010456c <sleep+0xa8>
    release(&ptable.lock);
8010454e:	83 ec 0c             	sub    $0xc,%esp
80104551:	68 00 55 19 80       	push   $0x80195500
80104556:	e8 54 05 00 00       	call   80104aaf <release>
8010455b:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010455e:	83 ec 0c             	sub    $0xc,%esp
80104561:	ff 75 0c             	push   0xc(%ebp)
80104564:	e8 d4 04 00 00       	call   80104a3d <acquire>
80104569:	83 c4 10             	add    $0x10,%esp
  }
}
8010456c:	90                   	nop
8010456d:	c9                   	leave
8010456e:	c3                   	ret

8010456f <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010456f:	f3 0f 1e fb          	endbr32
80104573:	55                   	push   %ebp
80104574:	89 e5                	mov    %esp,%ebp
80104576:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104579:	c7 45 fc 34 55 19 80 	movl   $0x80195534,-0x4(%ebp)
80104580:	eb 24                	jmp    801045a6 <wakeup1+0x37>
    if(p->state == SLEEPING && p->chan == chan)
80104582:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104585:	8b 40 0c             	mov    0xc(%eax),%eax
80104588:	83 f8 02             	cmp    $0x2,%eax
8010458b:	75 15                	jne    801045a2 <wakeup1+0x33>
8010458d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104590:	8b 40 20             	mov    0x20(%eax),%eax
80104593:	39 45 08             	cmp    %eax,0x8(%ebp)
80104596:	75 0a                	jne    801045a2 <wakeup1+0x33>
      p->state = RUNNABLE;
80104598:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010459b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045a2:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
801045a6:	81 7d fc 34 75 19 80 	cmpl   $0x80197534,-0x4(%ebp)
801045ad:	72 d3                	jb     80104582 <wakeup1+0x13>
}
801045af:	90                   	nop
801045b0:	90                   	nop
801045b1:	c9                   	leave
801045b2:	c3                   	ret

801045b3 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801045b3:	f3 0f 1e fb          	endbr32
801045b7:	55                   	push   %ebp
801045b8:	89 e5                	mov    %esp,%ebp
801045ba:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801045bd:	83 ec 0c             	sub    $0xc,%esp
801045c0:	68 00 55 19 80       	push   $0x80195500
801045c5:	e8 73 04 00 00       	call   80104a3d <acquire>
801045ca:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801045cd:	83 ec 0c             	sub    $0xc,%esp
801045d0:	ff 75 08             	push   0x8(%ebp)
801045d3:	e8 97 ff ff ff       	call   8010456f <wakeup1>
801045d8:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801045db:	83 ec 0c             	sub    $0xc,%esp
801045de:	68 00 55 19 80       	push   $0x80195500
801045e3:	e8 c7 04 00 00       	call   80104aaf <release>
801045e8:	83 c4 10             	add    $0x10,%esp
}
801045eb:	90                   	nop
801045ec:	c9                   	leave
801045ed:	c3                   	ret

801045ee <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801045ee:	f3 0f 1e fb          	endbr32
801045f2:	55                   	push   %ebp
801045f3:	89 e5                	mov    %esp,%ebp
801045f5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801045f8:	83 ec 0c             	sub    $0xc,%esp
801045fb:	68 00 55 19 80       	push   $0x80195500
80104600:	e8 38 04 00 00       	call   80104a3d <acquire>
80104605:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104608:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010460f:	eb 45                	jmp    80104656 <kill+0x68>
    if(p->pid == pid){
80104611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104614:	8b 40 10             	mov    0x10(%eax),%eax
80104617:	39 45 08             	cmp    %eax,0x8(%ebp)
8010461a:	75 36                	jne    80104652 <kill+0x64>
      p->killed = 1;
8010461c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104626:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104629:	8b 40 0c             	mov    0xc(%eax),%eax
8010462c:	83 f8 02             	cmp    $0x2,%eax
8010462f:	75 0a                	jne    8010463b <kill+0x4d>
        p->state = RUNNABLE;
80104631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104634:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010463b:	83 ec 0c             	sub    $0xc,%esp
8010463e:	68 00 55 19 80       	push   $0x80195500
80104643:	e8 67 04 00 00       	call   80104aaf <release>
80104648:	83 c4 10             	add    $0x10,%esp
      return 0;
8010464b:	b8 00 00 00 00       	mov    $0x0,%eax
80104650:	eb 22                	jmp    80104674 <kill+0x86>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104652:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104656:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
8010465d:	72 b2                	jb     80104611 <kill+0x23>
    }
  }
  release(&ptable.lock);
8010465f:	83 ec 0c             	sub    $0xc,%esp
80104662:	68 00 55 19 80       	push   $0x80195500
80104667:	e8 43 04 00 00       	call   80104aaf <release>
8010466c:	83 c4 10             	add    $0x10,%esp
  return -1;
8010466f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104674:	c9                   	leave
80104675:	c3                   	ret

80104676 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104676:	f3 0f 1e fb          	endbr32
8010467a:	55                   	push   %ebp
8010467b:	89 e5                	mov    %esp,%ebp
8010467d:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104680:	c7 45 f0 34 55 19 80 	movl   $0x80195534,-0x10(%ebp)
80104687:	e9 d7 00 00 00       	jmp    80104763 <procdump+0xed>
    if(p->state == UNUSED)
8010468c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010468f:	8b 40 0c             	mov    0xc(%eax),%eax
80104692:	85 c0                	test   %eax,%eax
80104694:	0f 84 c4 00 00 00    	je     8010475e <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010469a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010469d:	8b 40 0c             	mov    0xc(%eax),%eax
801046a0:	83 f8 05             	cmp    $0x5,%eax
801046a3:	77 23                	ja     801046c8 <procdump+0x52>
801046a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046a8:	8b 40 0c             	mov    0xc(%eax),%eax
801046ab:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801046b2:	85 c0                	test   %eax,%eax
801046b4:	74 12                	je     801046c8 <procdump+0x52>
      state = states[p->state];
801046b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046b9:	8b 40 0c             	mov    0xc(%eax),%eax
801046bc:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801046c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801046c6:	eb 07                	jmp    801046cf <procdump+0x59>
    else
      state = "???";
801046c8:	c7 45 ec 72 a9 10 80 	movl   $0x8010a972,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801046cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046d2:	8d 50 6c             	lea    0x6c(%eax),%edx
801046d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046d8:	8b 40 10             	mov    0x10(%eax),%eax
801046db:	52                   	push   %edx
801046dc:	ff 75 ec             	push   -0x14(%ebp)
801046df:	50                   	push   %eax
801046e0:	68 76 a9 10 80       	push   $0x8010a976
801046e5:	e8 22 bd ff ff       	call   8010040c <cprintf>
801046ea:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801046ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046f0:	8b 40 0c             	mov    0xc(%eax),%eax
801046f3:	83 f8 02             	cmp    $0x2,%eax
801046f6:	75 54                	jne    8010474c <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801046f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046fb:	8b 40 1c             	mov    0x1c(%eax),%eax
801046fe:	8b 40 0c             	mov    0xc(%eax),%eax
80104701:	83 c0 08             	add    $0x8,%eax
80104704:	89 c2                	mov    %eax,%edx
80104706:	83 ec 08             	sub    $0x8,%esp
80104709:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010470c:	50                   	push   %eax
8010470d:	52                   	push   %edx
8010470e:	e8 f2 03 00 00       	call   80104b05 <getcallerpcs>
80104713:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104716:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010471d:	eb 1c                	jmp    8010473b <procdump+0xc5>
        cprintf(" %p", pc[i]);
8010471f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104722:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104726:	83 ec 08             	sub    $0x8,%esp
80104729:	50                   	push   %eax
8010472a:	68 7f a9 10 80       	push   $0x8010a97f
8010472f:	e8 d8 bc ff ff       	call   8010040c <cprintf>
80104734:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104737:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010473b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010473f:	7f 0b                	jg     8010474c <procdump+0xd6>
80104741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104744:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104748:	85 c0                	test   %eax,%eax
8010474a:	75 d3                	jne    8010471f <procdump+0xa9>
    }
    cprintf("\n");
8010474c:	83 ec 0c             	sub    $0xc,%esp
8010474f:	68 83 a9 10 80       	push   $0x8010a983
80104754:	e8 b3 bc ff ff       	call   8010040c <cprintf>
80104759:	83 c4 10             	add    $0x10,%esp
8010475c:	eb 01                	jmp    8010475f <procdump+0xe9>
      continue;
8010475e:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010475f:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104763:	81 7d f0 34 75 19 80 	cmpl   $0x80197534,-0x10(%ebp)
8010476a:	0f 82 1c ff ff ff    	jb     8010468c <procdump+0x16>
  }
}
80104770:	90                   	nop
80104771:	90                   	nop
80104772:	c9                   	leave
80104773:	c3                   	ret

80104774 <printpt>:

// 페이지 테이블 출력
int printpt(int pid){
80104774:	f3 0f 1e fb          	endbr32
80104778:	55                   	push   %ebp
80104779:	89 e5                	mov    %esp,%ebp
8010477b:	53                   	push   %ebx
8010477c:	83 ec 14             	sub    $0x14,%esp
  struct proc* p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010477f:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104786:	eb 0f                	jmp    80104797 <printpt+0x23>
    if (p->pid == pid)
80104788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478b:	8b 40 10             	mov    0x10(%eax),%eax
8010478e:	39 45 08             	cmp    %eax,0x8(%ebp)
80104791:	74 0f                	je     801047a2 <printpt+0x2e>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104793:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104797:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
8010479e:	72 e8                	jb     80104788 <printpt+0x14>
801047a0:	eb 01                	jmp    801047a3 <printpt+0x2f>
      break;
801047a2:	90                   	nop
  }
  if (p == 0){
801047a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047a7:	75 1a                	jne    801047c3 <printpt+0x4f>
    cprintf("[printpt] invaild proccess\n");
801047a9:	83 ec 0c             	sub    $0xc,%esp
801047ac:	68 85 a9 10 80       	push   $0x8010a985
801047b1:	e8 56 bc ff ff       	call   8010040c <cprintf>
801047b6:	83 c4 10             	add    $0x10,%esp
    return -1;
801047b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047be:	e9 e2 00 00 00       	jmp    801048a5 <printpt+0x131>
  }
  
  pde_t* pgdir = p->pgdir;
801047c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c6:	8b 40 04             	mov    0x4(%eax),%eax
801047c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint va;
  // walkpgdir은 pgdir에서 va(가상주소)가 위치한 페이지 테이블 엔트리를 반환한다.
  cprintf("START PAGE TABLE (pid %d) \n", pid);
801047cc:	83 ec 08             	sub    $0x8,%esp
801047cf:	ff 75 08             	push   0x8(%ebp)
801047d2:	68 a1 a9 10 80       	push   $0x8010a9a1
801047d7:	e8 30 bc ff ff       	call   8010040c <cprintf>
801047dc:	83 c4 10             	add    $0x10,%esp
  // 페이지 테이블 엔트리를 한 줄씩 출력
  // xv6에서는 pagesize를 4KB로 설정 PGSIZE == 4096 임
  for (va = 0; va < KERNBASE; va += PGSIZE)
801047df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047e6:	e9 9a 00 00 00       	jmp    80104885 <printpt+0x111>
  {
    // va가 속한 페이지 테이블 엔트리
    pte_t* pte = walkpgdir(pgdir, (void*) va, 0);
801047eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047ee:	83 ec 04             	sub    $0x4,%esp
801047f1:	6a 00                	push   $0x0
801047f3:	50                   	push   %eax
801047f4:	ff 75 ec             	push   -0x14(%ebp)
801047f7:	e8 6f 2e 00 00       	call   8010766b <walkpgdir>
801047fc:	83 c4 10             	add    $0x10,%esp
801047ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
    // pte가 유효하지 않으면 패스
    if (!(*pte & PTE_P) || pte == 0) continue;
80104802:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104805:	8b 00                	mov    (%eax),%eax
80104807:	83 e0 01             	and    $0x1,%eax
8010480a:	85 c0                	test   %eax,%eax
8010480c:	74 6f                	je     8010487d <printpt+0x109>
8010480e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104812:	74 69                	je     8010487d <printpt+0x109>
    cprintf("pte: %x\n",pte);
80104814:	83 ec 08             	sub    $0x8,%esp
80104817:	ff 75 e8             	push   -0x18(%ebp)
8010481a:	68 bd a9 10 80       	push   $0x8010a9bd
8010481f:	e8 e8 bb ff ff       	call   8010040c <cprintf>
80104824:	83 c4 10             	add    $0x10,%esp
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
      (*pte & PTE_W)?'W':'-', PTE_ADDR(*pte) >> 12); 
80104827:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010482a:	8b 00                	mov    (%eax),%eax
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
8010482c:	c1 e8 0c             	shr    $0xc,%eax
8010482f:	89 c2                	mov    %eax,%edx
      (*pte & PTE_W)?'W':'-', PTE_ADDR(*pte) >> 12); 
80104831:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104834:	8b 00                	mov    (%eax),%eax
80104836:	83 e0 02             	and    $0x2,%eax
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
80104839:	85 c0                	test   %eax,%eax
8010483b:	74 07                	je     80104844 <printpt+0xd0>
8010483d:	bb 57 00 00 00       	mov    $0x57,%ebx
80104842:	eb 05                	jmp    80104849 <printpt+0xd5>
80104844:	bb 2d 00 00 00       	mov    $0x2d,%ebx
80104849:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010484c:	8b 00                	mov    (%eax),%eax
8010484e:	83 e0 04             	and    $0x4,%eax
80104851:	85 c0                	test   %eax,%eax
80104853:	74 07                	je     8010485c <printpt+0xe8>
80104855:	b9 55 00 00 00       	mov    $0x55,%ecx
8010485a:	eb 05                	jmp    80104861 <printpt+0xed>
8010485c:	b9 4b 00 00 00       	mov    $0x4b,%ecx
80104861:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104864:	c1 e8 0c             	shr    $0xc,%eax
80104867:	83 ec 0c             	sub    $0xc,%esp
8010486a:	52                   	push   %edx
8010486b:	53                   	push   %ebx
8010486c:	51                   	push   %ecx
8010486d:	50                   	push   %eax
8010486e:	68 c6 a9 10 80       	push   $0x8010a9c6
80104873:	e8 94 bb ff ff       	call   8010040c <cprintf>
80104878:	83 c4 20             	add    $0x20,%esp
8010487b:	eb 01                	jmp    8010487e <printpt+0x10a>
    if (!(*pte & PTE_P) || pte == 0) continue;
8010487d:	90                   	nop
  for (va = 0; va < KERNBASE; va += PGSIZE)
8010487e:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
80104885:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104888:	85 c0                	test   %eax,%eax
8010488a:	0f 89 5b ff ff ff    	jns    801047eb <printpt+0x77>
  }
  cprintf("END PAGE TABLE\n");
80104890:	83 ec 0c             	sub    $0xc,%esp
80104893:	68 d5 a9 10 80       	push   $0x8010a9d5
80104898:	e8 6f bb ff ff       	call   8010040c <cprintf>
8010489d:	83 c4 10             	add    $0x10,%esp
  return 0;
801048a0:	b8 00 00 00 00       	mov    $0x0,%eax
801048a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048a8:	c9                   	leave
801048a9:	c3                   	ret

801048aa <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801048aa:	f3 0f 1e fb          	endbr32
801048ae:	55                   	push   %ebp
801048af:	89 e5                	mov    %esp,%ebp
801048b1:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801048b4:	8b 45 08             	mov    0x8(%ebp),%eax
801048b7:	83 c0 04             	add    $0x4,%eax
801048ba:	83 ec 08             	sub    $0x8,%esp
801048bd:	68 0f aa 10 80       	push   $0x8010aa0f
801048c2:	50                   	push   %eax
801048c3:	e8 4f 01 00 00       	call   80104a17 <initlock>
801048c8:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801048cb:	8b 45 08             	mov    0x8(%ebp),%eax
801048ce:	8b 55 0c             	mov    0xc(%ebp),%edx
801048d1:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801048d4:	8b 45 08             	mov    0x8(%ebp),%eax
801048d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801048dd:	8b 45 08             	mov    0x8(%ebp),%eax
801048e0:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801048e7:	90                   	nop
801048e8:	c9                   	leave
801048e9:	c3                   	ret

801048ea <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801048ea:	f3 0f 1e fb          	endbr32
801048ee:	55                   	push   %ebp
801048ef:	89 e5                	mov    %esp,%ebp
801048f1:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801048f4:	8b 45 08             	mov    0x8(%ebp),%eax
801048f7:	83 c0 04             	add    $0x4,%eax
801048fa:	83 ec 0c             	sub    $0xc,%esp
801048fd:	50                   	push   %eax
801048fe:	e8 3a 01 00 00       	call   80104a3d <acquire>
80104903:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104906:	eb 15                	jmp    8010491d <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80104908:	8b 45 08             	mov    0x8(%ebp),%eax
8010490b:	83 c0 04             	add    $0x4,%eax
8010490e:	83 ec 08             	sub    $0x8,%esp
80104911:	50                   	push   %eax
80104912:	ff 75 08             	push   0x8(%ebp)
80104915:	e8 aa fb ff ff       	call   801044c4 <sleep>
8010491a:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010491d:	8b 45 08             	mov    0x8(%ebp),%eax
80104920:	8b 00                	mov    (%eax),%eax
80104922:	85 c0                	test   %eax,%eax
80104924:	75 e2                	jne    80104908 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80104926:	8b 45 08             	mov    0x8(%ebp),%eax
80104929:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010492f:	e8 85 f2 ff ff       	call   80103bb9 <myproc>
80104934:	8b 50 10             	mov    0x10(%eax),%edx
80104937:	8b 45 08             	mov    0x8(%ebp),%eax
8010493a:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010493d:	8b 45 08             	mov    0x8(%ebp),%eax
80104940:	83 c0 04             	add    $0x4,%eax
80104943:	83 ec 0c             	sub    $0xc,%esp
80104946:	50                   	push   %eax
80104947:	e8 63 01 00 00       	call   80104aaf <release>
8010494c:	83 c4 10             	add    $0x10,%esp
}
8010494f:	90                   	nop
80104950:	c9                   	leave
80104951:	c3                   	ret

80104952 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104952:	f3 0f 1e fb          	endbr32
80104956:	55                   	push   %ebp
80104957:	89 e5                	mov    %esp,%ebp
80104959:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010495c:	8b 45 08             	mov    0x8(%ebp),%eax
8010495f:	83 c0 04             	add    $0x4,%eax
80104962:	83 ec 0c             	sub    $0xc,%esp
80104965:	50                   	push   %eax
80104966:	e8 d2 00 00 00       	call   80104a3d <acquire>
8010496b:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
8010496e:	8b 45 08             	mov    0x8(%ebp),%eax
80104971:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104977:	8b 45 08             	mov    0x8(%ebp),%eax
8010497a:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104981:	83 ec 0c             	sub    $0xc,%esp
80104984:	ff 75 08             	push   0x8(%ebp)
80104987:	e8 27 fc ff ff       	call   801045b3 <wakeup>
8010498c:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
8010498f:	8b 45 08             	mov    0x8(%ebp),%eax
80104992:	83 c0 04             	add    $0x4,%eax
80104995:	83 ec 0c             	sub    $0xc,%esp
80104998:	50                   	push   %eax
80104999:	e8 11 01 00 00       	call   80104aaf <release>
8010499e:	83 c4 10             	add    $0x10,%esp
}
801049a1:	90                   	nop
801049a2:	c9                   	leave
801049a3:	c3                   	ret

801049a4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801049a4:	f3 0f 1e fb          	endbr32
801049a8:	55                   	push   %ebp
801049a9:	89 e5                	mov    %esp,%ebp
801049ab:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
801049ae:	8b 45 08             	mov    0x8(%ebp),%eax
801049b1:	83 c0 04             	add    $0x4,%eax
801049b4:	83 ec 0c             	sub    $0xc,%esp
801049b7:	50                   	push   %eax
801049b8:	e8 80 00 00 00       	call   80104a3d <acquire>
801049bd:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801049c0:	8b 45 08             	mov    0x8(%ebp),%eax
801049c3:	8b 00                	mov    (%eax),%eax
801049c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801049c8:	8b 45 08             	mov    0x8(%ebp),%eax
801049cb:	83 c0 04             	add    $0x4,%eax
801049ce:	83 ec 0c             	sub    $0xc,%esp
801049d1:	50                   	push   %eax
801049d2:	e8 d8 00 00 00       	call   80104aaf <release>
801049d7:	83 c4 10             	add    $0x10,%esp
  return r;
801049da:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801049dd:	c9                   	leave
801049de:	c3                   	ret

801049df <readeflags>:
{
801049df:	55                   	push   %ebp
801049e0:	89 e5                	mov    %esp,%ebp
801049e2:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801049e5:	9c                   	pushf
801049e6:	58                   	pop    %eax
801049e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801049ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801049ed:	c9                   	leave
801049ee:	c3                   	ret

801049ef <cli>:
{
801049ef:	55                   	push   %ebp
801049f0:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801049f2:	fa                   	cli
}
801049f3:	90                   	nop
801049f4:	5d                   	pop    %ebp
801049f5:	c3                   	ret

801049f6 <sti>:
{
801049f6:	55                   	push   %ebp
801049f7:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801049f9:	fb                   	sti
}
801049fa:	90                   	nop
801049fb:	5d                   	pop    %ebp
801049fc:	c3                   	ret

801049fd <xchg>:
{
801049fd:	55                   	push   %ebp
801049fe:	89 e5                	mov    %esp,%ebp
80104a00:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104a03:	8b 55 08             	mov    0x8(%ebp),%edx
80104a06:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a09:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a0c:	f0 87 02             	lock xchg %eax,(%edx)
80104a0f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104a12:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a15:	c9                   	leave
80104a16:	c3                   	ret

80104a17 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104a17:	f3 0f 1e fb          	endbr32
80104a1b:	55                   	push   %ebp
80104a1c:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a21:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a24:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104a27:	8b 45 08             	mov    0x8(%ebp),%eax
80104a2a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104a30:	8b 45 08             	mov    0x8(%ebp),%eax
80104a33:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104a3a:	90                   	nop
80104a3b:	5d                   	pop    %ebp
80104a3c:	c3                   	ret

80104a3d <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104a3d:	f3 0f 1e fb          	endbr32
80104a41:	55                   	push   %ebp
80104a42:	89 e5                	mov    %esp,%ebp
80104a44:	53                   	push   %ebx
80104a45:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104a48:	e8 6c 01 00 00       	call   80104bb9 <pushcli>
  if(holding(lk)){
80104a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a50:	83 ec 0c             	sub    $0xc,%esp
80104a53:	50                   	push   %eax
80104a54:	e8 2b 01 00 00       	call   80104b84 <holding>
80104a59:	83 c4 10             	add    $0x10,%esp
80104a5c:	85 c0                	test   %eax,%eax
80104a5e:	74 0d                	je     80104a6d <acquire+0x30>
    panic("acquire");
80104a60:	83 ec 0c             	sub    $0xc,%esp
80104a63:	68 1a aa 10 80       	push   $0x8010aa1a
80104a68:	e8 71 bb ff ff       	call   801005de <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104a6d:	90                   	nop
80104a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a71:	83 ec 08             	sub    $0x8,%esp
80104a74:	6a 01                	push   $0x1
80104a76:	50                   	push   %eax
80104a77:	e8 81 ff ff ff       	call   801049fd <xchg>
80104a7c:	83 c4 10             	add    $0x10,%esp
80104a7f:	85 c0                	test   %eax,%eax
80104a81:	75 eb                	jne    80104a6e <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104a83:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104a88:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104a8b:	e8 ad f0 ff ff       	call   80103b3d <mycpu>
80104a90:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104a93:	8b 45 08             	mov    0x8(%ebp),%eax
80104a96:	83 c0 0c             	add    $0xc,%eax
80104a99:	83 ec 08             	sub    $0x8,%esp
80104a9c:	50                   	push   %eax
80104a9d:	8d 45 08             	lea    0x8(%ebp),%eax
80104aa0:	50                   	push   %eax
80104aa1:	e8 5f 00 00 00       	call   80104b05 <getcallerpcs>
80104aa6:	83 c4 10             	add    $0x10,%esp
}
80104aa9:	90                   	nop
80104aaa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104aad:	c9                   	leave
80104aae:	c3                   	ret

80104aaf <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104aaf:	f3 0f 1e fb          	endbr32
80104ab3:	55                   	push   %ebp
80104ab4:	89 e5                	mov    %esp,%ebp
80104ab6:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104ab9:	83 ec 0c             	sub    $0xc,%esp
80104abc:	ff 75 08             	push   0x8(%ebp)
80104abf:	e8 c0 00 00 00       	call   80104b84 <holding>
80104ac4:	83 c4 10             	add    $0x10,%esp
80104ac7:	85 c0                	test   %eax,%eax
80104ac9:	75 0d                	jne    80104ad8 <release+0x29>
    panic("release");
80104acb:	83 ec 0c             	sub    $0xc,%esp
80104ace:	68 22 aa 10 80       	push   $0x8010aa22
80104ad3:	e8 06 bb ff ff       	call   801005de <panic>

  lk->pcs[0] = 0;
80104ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80104adb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104aec:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104af1:	8b 45 08             	mov    0x8(%ebp),%eax
80104af4:	8b 55 08             	mov    0x8(%ebp),%edx
80104af7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104afd:	e8 08 01 00 00       	call   80104c0a <popcli>
}
80104b02:	90                   	nop
80104b03:	c9                   	leave
80104b04:	c3                   	ret

80104b05 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104b05:	f3 0f 1e fb          	endbr32
80104b09:	55                   	push   %ebp
80104b0a:	89 e5                	mov    %esp,%ebp
80104b0c:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104b0f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b12:	83 e8 08             	sub    $0x8,%eax
80104b15:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104b18:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104b1f:	eb 38                	jmp    80104b59 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104b21:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104b25:	74 53                	je     80104b7a <getcallerpcs+0x75>
80104b27:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104b2e:	76 4a                	jbe    80104b7a <getcallerpcs+0x75>
80104b30:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104b34:	74 44                	je     80104b7a <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104b36:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b39:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104b40:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b43:	01 c2                	add    %eax,%edx
80104b45:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b48:	8b 40 04             	mov    0x4(%eax),%eax
80104b4b:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104b4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b50:	8b 00                	mov    (%eax),%eax
80104b52:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104b55:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104b59:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104b5d:	7e c2                	jle    80104b21 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80104b5f:	eb 19                	jmp    80104b7a <getcallerpcs+0x75>
    pcs[i] = 0;
80104b61:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b64:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b6e:	01 d0                	add    %edx,%eax
80104b70:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104b76:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104b7a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104b7e:	7e e1                	jle    80104b61 <getcallerpcs+0x5c>
}
80104b80:	90                   	nop
80104b81:	90                   	nop
80104b82:	c9                   	leave
80104b83:	c3                   	ret

80104b84 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104b84:	f3 0f 1e fb          	endbr32
80104b88:	55                   	push   %ebp
80104b89:	89 e5                	mov    %esp,%ebp
80104b8b:	53                   	push   %ebx
80104b8c:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b92:	8b 00                	mov    (%eax),%eax
80104b94:	85 c0                	test   %eax,%eax
80104b96:	74 16                	je     80104bae <holding+0x2a>
80104b98:	8b 45 08             	mov    0x8(%ebp),%eax
80104b9b:	8b 58 08             	mov    0x8(%eax),%ebx
80104b9e:	e8 9a ef ff ff       	call   80103b3d <mycpu>
80104ba3:	39 c3                	cmp    %eax,%ebx
80104ba5:	75 07                	jne    80104bae <holding+0x2a>
80104ba7:	b8 01 00 00 00       	mov    $0x1,%eax
80104bac:	eb 05                	jmp    80104bb3 <holding+0x2f>
80104bae:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104bb3:	83 c4 04             	add    $0x4,%esp
80104bb6:	5b                   	pop    %ebx
80104bb7:	5d                   	pop    %ebp
80104bb8:	c3                   	ret

80104bb9 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104bb9:	f3 0f 1e fb          	endbr32
80104bbd:	55                   	push   %ebp
80104bbe:	89 e5                	mov    %esp,%ebp
80104bc0:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104bc3:	e8 17 fe ff ff       	call   801049df <readeflags>
80104bc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104bcb:	e8 1f fe ff ff       	call   801049ef <cli>
  if(mycpu()->ncli == 0)
80104bd0:	e8 68 ef ff ff       	call   80103b3d <mycpu>
80104bd5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104bdb:	85 c0                	test   %eax,%eax
80104bdd:	75 14                	jne    80104bf3 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104bdf:	e8 59 ef ff ff       	call   80103b3d <mycpu>
80104be4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104be7:	81 e2 00 02 00 00    	and    $0x200,%edx
80104bed:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104bf3:	e8 45 ef ff ff       	call   80103b3d <mycpu>
80104bf8:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104bfe:	83 c2 01             	add    $0x1,%edx
80104c01:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104c07:	90                   	nop
80104c08:	c9                   	leave
80104c09:	c3                   	ret

80104c0a <popcli>:

void
popcli(void)
{
80104c0a:	f3 0f 1e fb          	endbr32
80104c0e:	55                   	push   %ebp
80104c0f:	89 e5                	mov    %esp,%ebp
80104c11:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104c14:	e8 c6 fd ff ff       	call   801049df <readeflags>
80104c19:	25 00 02 00 00       	and    $0x200,%eax
80104c1e:	85 c0                	test   %eax,%eax
80104c20:	74 0d                	je     80104c2f <popcli+0x25>
    panic("popcli - interruptible");
80104c22:	83 ec 0c             	sub    $0xc,%esp
80104c25:	68 2a aa 10 80       	push   $0x8010aa2a
80104c2a:	e8 af b9 ff ff       	call   801005de <panic>
  if(--mycpu()->ncli < 0)
80104c2f:	e8 09 ef ff ff       	call   80103b3d <mycpu>
80104c34:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104c3a:	83 ea 01             	sub    $0x1,%edx
80104c3d:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104c43:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104c49:	85 c0                	test   %eax,%eax
80104c4b:	79 0d                	jns    80104c5a <popcli+0x50>
    panic("popcli");
80104c4d:	83 ec 0c             	sub    $0xc,%esp
80104c50:	68 41 aa 10 80       	push   $0x8010aa41
80104c55:	e8 84 b9 ff ff       	call   801005de <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104c5a:	e8 de ee ff ff       	call   80103b3d <mycpu>
80104c5f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104c65:	85 c0                	test   %eax,%eax
80104c67:	75 14                	jne    80104c7d <popcli+0x73>
80104c69:	e8 cf ee ff ff       	call   80103b3d <mycpu>
80104c6e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104c74:	85 c0                	test   %eax,%eax
80104c76:	74 05                	je     80104c7d <popcli+0x73>
    sti();
80104c78:	e8 79 fd ff ff       	call   801049f6 <sti>
}
80104c7d:	90                   	nop
80104c7e:	c9                   	leave
80104c7f:	c3                   	ret

80104c80 <stosb>:
{
80104c80:	55                   	push   %ebp
80104c81:	89 e5                	mov    %esp,%ebp
80104c83:	57                   	push   %edi
80104c84:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104c85:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104c88:	8b 55 10             	mov    0x10(%ebp),%edx
80104c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c8e:	89 cb                	mov    %ecx,%ebx
80104c90:	89 df                	mov    %ebx,%edi
80104c92:	89 d1                	mov    %edx,%ecx
80104c94:	fc                   	cld
80104c95:	f3 aa                	rep stos %al,%es:(%edi)
80104c97:	89 ca                	mov    %ecx,%edx
80104c99:	89 fb                	mov    %edi,%ebx
80104c9b:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104c9e:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104ca1:	90                   	nop
80104ca2:	5b                   	pop    %ebx
80104ca3:	5f                   	pop    %edi
80104ca4:	5d                   	pop    %ebp
80104ca5:	c3                   	ret

80104ca6 <stosl>:
{
80104ca6:	55                   	push   %ebp
80104ca7:	89 e5                	mov    %esp,%ebp
80104ca9:	57                   	push   %edi
80104caa:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104cab:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104cae:	8b 55 10             	mov    0x10(%ebp),%edx
80104cb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cb4:	89 cb                	mov    %ecx,%ebx
80104cb6:	89 df                	mov    %ebx,%edi
80104cb8:	89 d1                	mov    %edx,%ecx
80104cba:	fc                   	cld
80104cbb:	f3 ab                	rep stos %eax,%es:(%edi)
80104cbd:	89 ca                	mov    %ecx,%edx
80104cbf:	89 fb                	mov    %edi,%ebx
80104cc1:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104cc4:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104cc7:	90                   	nop
80104cc8:	5b                   	pop    %ebx
80104cc9:	5f                   	pop    %edi
80104cca:	5d                   	pop    %ebp
80104ccb:	c3                   	ret

80104ccc <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104ccc:	f3 0f 1e fb          	endbr32
80104cd0:	55                   	push   %ebp
80104cd1:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd6:	83 e0 03             	and    $0x3,%eax
80104cd9:	85 c0                	test   %eax,%eax
80104cdb:	75 43                	jne    80104d20 <memset+0x54>
80104cdd:	8b 45 10             	mov    0x10(%ebp),%eax
80104ce0:	83 e0 03             	and    $0x3,%eax
80104ce3:	85 c0                	test   %eax,%eax
80104ce5:	75 39                	jne    80104d20 <memset+0x54>
    c &= 0xFF;
80104ce7:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104cee:	8b 45 10             	mov    0x10(%ebp),%eax
80104cf1:	c1 e8 02             	shr    $0x2,%eax
80104cf4:	89 c1                	mov    %eax,%ecx
80104cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cf9:	c1 e0 18             	shl    $0x18,%eax
80104cfc:	89 c2                	mov    %eax,%edx
80104cfe:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d01:	c1 e0 10             	shl    $0x10,%eax
80104d04:	09 c2                	or     %eax,%edx
80104d06:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d09:	c1 e0 08             	shl    $0x8,%eax
80104d0c:	09 d0                	or     %edx,%eax
80104d0e:	0b 45 0c             	or     0xc(%ebp),%eax
80104d11:	51                   	push   %ecx
80104d12:	50                   	push   %eax
80104d13:	ff 75 08             	push   0x8(%ebp)
80104d16:	e8 8b ff ff ff       	call   80104ca6 <stosl>
80104d1b:	83 c4 0c             	add    $0xc,%esp
80104d1e:	eb 12                	jmp    80104d32 <memset+0x66>
  } else
    stosb(dst, c, n);
80104d20:	8b 45 10             	mov    0x10(%ebp),%eax
80104d23:	50                   	push   %eax
80104d24:	ff 75 0c             	push   0xc(%ebp)
80104d27:	ff 75 08             	push   0x8(%ebp)
80104d2a:	e8 51 ff ff ff       	call   80104c80 <stosb>
80104d2f:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104d32:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104d35:	c9                   	leave
80104d36:	c3                   	ret

80104d37 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104d37:	f3 0f 1e fb          	endbr32
80104d3b:	55                   	push   %ebp
80104d3c:	89 e5                	mov    %esp,%ebp
80104d3e:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104d41:	8b 45 08             	mov    0x8(%ebp),%eax
80104d44:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104d47:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d4a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104d4d:	eb 30                	jmp    80104d7f <memcmp+0x48>
    if(*s1 != *s2)
80104d4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d52:	0f b6 10             	movzbl (%eax),%edx
80104d55:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104d58:	0f b6 00             	movzbl (%eax),%eax
80104d5b:	38 c2                	cmp    %al,%dl
80104d5d:	74 18                	je     80104d77 <memcmp+0x40>
      return *s1 - *s2;
80104d5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d62:	0f b6 00             	movzbl (%eax),%eax
80104d65:	0f b6 d0             	movzbl %al,%edx
80104d68:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104d6b:	0f b6 00             	movzbl (%eax),%eax
80104d6e:	0f b6 c0             	movzbl %al,%eax
80104d71:	29 c2                	sub    %eax,%edx
80104d73:	89 d0                	mov    %edx,%eax
80104d75:	eb 1a                	jmp    80104d91 <memcmp+0x5a>
    s1++, s2++;
80104d77:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104d7b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104d7f:	8b 45 10             	mov    0x10(%ebp),%eax
80104d82:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d85:	89 55 10             	mov    %edx,0x10(%ebp)
80104d88:	85 c0                	test   %eax,%eax
80104d8a:	75 c3                	jne    80104d4f <memcmp+0x18>
  }

  return 0;
80104d8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d91:	c9                   	leave
80104d92:	c3                   	ret

80104d93 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104d93:	f3 0f 1e fb          	endbr32
80104d97:	55                   	push   %ebp
80104d98:	89 e5                	mov    %esp,%ebp
80104d9a:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104d9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104da0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104da3:	8b 45 08             	mov    0x8(%ebp),%eax
80104da6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104da9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dac:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104daf:	73 54                	jae    80104e05 <memmove+0x72>
80104db1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104db4:	8b 45 10             	mov    0x10(%ebp),%eax
80104db7:	01 d0                	add    %edx,%eax
80104db9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104dbc:	73 47                	jae    80104e05 <memmove+0x72>
    s += n;
80104dbe:	8b 45 10             	mov    0x10(%ebp),%eax
80104dc1:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104dc4:	8b 45 10             	mov    0x10(%ebp),%eax
80104dc7:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104dca:	eb 13                	jmp    80104ddf <memmove+0x4c>
      *--d = *--s;
80104dcc:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104dd0:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104dd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dd7:	0f b6 10             	movzbl (%eax),%edx
80104dda:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ddd:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104ddf:	8b 45 10             	mov    0x10(%ebp),%eax
80104de2:	8d 50 ff             	lea    -0x1(%eax),%edx
80104de5:	89 55 10             	mov    %edx,0x10(%ebp)
80104de8:	85 c0                	test   %eax,%eax
80104dea:	75 e0                	jne    80104dcc <memmove+0x39>
  if(s < d && s + n > d){
80104dec:	eb 24                	jmp    80104e12 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104dee:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104df1:	8d 42 01             	lea    0x1(%edx),%eax
80104df4:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104df7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104dfa:	8d 48 01             	lea    0x1(%eax),%ecx
80104dfd:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104e00:	0f b6 12             	movzbl (%edx),%edx
80104e03:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104e05:	8b 45 10             	mov    0x10(%ebp),%eax
80104e08:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e0b:	89 55 10             	mov    %edx,0x10(%ebp)
80104e0e:	85 c0                	test   %eax,%eax
80104e10:	75 dc                	jne    80104dee <memmove+0x5b>

  return dst;
80104e12:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e15:	c9                   	leave
80104e16:	c3                   	ret

80104e17 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104e17:	f3 0f 1e fb          	endbr32
80104e1b:	55                   	push   %ebp
80104e1c:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104e1e:	ff 75 10             	push   0x10(%ebp)
80104e21:	ff 75 0c             	push   0xc(%ebp)
80104e24:	ff 75 08             	push   0x8(%ebp)
80104e27:	e8 67 ff ff ff       	call   80104d93 <memmove>
80104e2c:	83 c4 0c             	add    $0xc,%esp
}
80104e2f:	c9                   	leave
80104e30:	c3                   	ret

80104e31 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104e31:	f3 0f 1e fb          	endbr32
80104e35:	55                   	push   %ebp
80104e36:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104e38:	eb 0c                	jmp    80104e46 <strncmp+0x15>
    n--, p++, q++;
80104e3a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104e3e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104e42:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104e46:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e4a:	74 1a                	je     80104e66 <strncmp+0x35>
80104e4c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e4f:	0f b6 00             	movzbl (%eax),%eax
80104e52:	84 c0                	test   %al,%al
80104e54:	74 10                	je     80104e66 <strncmp+0x35>
80104e56:	8b 45 08             	mov    0x8(%ebp),%eax
80104e59:	0f b6 10             	movzbl (%eax),%edx
80104e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e5f:	0f b6 00             	movzbl (%eax),%eax
80104e62:	38 c2                	cmp    %al,%dl
80104e64:	74 d4                	je     80104e3a <strncmp+0x9>
  if(n == 0)
80104e66:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e6a:	75 07                	jne    80104e73 <strncmp+0x42>
    return 0;
80104e6c:	b8 00 00 00 00       	mov    $0x0,%eax
80104e71:	eb 16                	jmp    80104e89 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80104e73:	8b 45 08             	mov    0x8(%ebp),%eax
80104e76:	0f b6 00             	movzbl (%eax),%eax
80104e79:	0f b6 d0             	movzbl %al,%edx
80104e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e7f:	0f b6 00             	movzbl (%eax),%eax
80104e82:	0f b6 c0             	movzbl %al,%eax
80104e85:	29 c2                	sub    %eax,%edx
80104e87:	89 d0                	mov    %edx,%eax
}
80104e89:	5d                   	pop    %ebp
80104e8a:	c3                   	ret

80104e8b <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104e8b:	f3 0f 1e fb          	endbr32
80104e8f:	55                   	push   %ebp
80104e90:	89 e5                	mov    %esp,%ebp
80104e92:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104e95:	8b 45 08             	mov    0x8(%ebp),%eax
80104e98:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104e9b:	90                   	nop
80104e9c:	8b 45 10             	mov    0x10(%ebp),%eax
80104e9f:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ea2:	89 55 10             	mov    %edx,0x10(%ebp)
80104ea5:	85 c0                	test   %eax,%eax
80104ea7:	7e 2c                	jle    80104ed5 <strncpy+0x4a>
80104ea9:	8b 55 0c             	mov    0xc(%ebp),%edx
80104eac:	8d 42 01             	lea    0x1(%edx),%eax
80104eaf:	89 45 0c             	mov    %eax,0xc(%ebp)
80104eb2:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb5:	8d 48 01             	lea    0x1(%eax),%ecx
80104eb8:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104ebb:	0f b6 12             	movzbl (%edx),%edx
80104ebe:	88 10                	mov    %dl,(%eax)
80104ec0:	0f b6 00             	movzbl (%eax),%eax
80104ec3:	84 c0                	test   %al,%al
80104ec5:	75 d5                	jne    80104e9c <strncpy+0x11>
    ;
  while(n-- > 0)
80104ec7:	eb 0c                	jmp    80104ed5 <strncpy+0x4a>
    *s++ = 0;
80104ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80104ecc:	8d 50 01             	lea    0x1(%eax),%edx
80104ecf:	89 55 08             	mov    %edx,0x8(%ebp)
80104ed2:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104ed5:	8b 45 10             	mov    0x10(%ebp),%eax
80104ed8:	8d 50 ff             	lea    -0x1(%eax),%edx
80104edb:	89 55 10             	mov    %edx,0x10(%ebp)
80104ede:	85 c0                	test   %eax,%eax
80104ee0:	7f e7                	jg     80104ec9 <strncpy+0x3e>
  return os;
80104ee2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ee5:	c9                   	leave
80104ee6:	c3                   	ret

80104ee7 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104ee7:	f3 0f 1e fb          	endbr32
80104eeb:	55                   	push   %ebp
80104eec:	89 e5                	mov    %esp,%ebp
80104eee:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104ef7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104efb:	7f 05                	jg     80104f02 <safestrcpy+0x1b>
    return os;
80104efd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f00:	eb 31                	jmp    80104f33 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80104f02:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f0a:	7e 1e                	jle    80104f2a <safestrcpy+0x43>
80104f0c:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f0f:	8d 42 01             	lea    0x1(%edx),%eax
80104f12:	89 45 0c             	mov    %eax,0xc(%ebp)
80104f15:	8b 45 08             	mov    0x8(%ebp),%eax
80104f18:	8d 48 01             	lea    0x1(%eax),%ecx
80104f1b:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104f1e:	0f b6 12             	movzbl (%edx),%edx
80104f21:	88 10                	mov    %dl,(%eax)
80104f23:	0f b6 00             	movzbl (%eax),%eax
80104f26:	84 c0                	test   %al,%al
80104f28:	75 d8                	jne    80104f02 <safestrcpy+0x1b>
    ;
  *s = 0;
80104f2a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2d:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104f30:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f33:	c9                   	leave
80104f34:	c3                   	ret

80104f35 <strlen>:

int
strlen(const char *s)
{
80104f35:	f3 0f 1e fb          	endbr32
80104f39:	55                   	push   %ebp
80104f3a:	89 e5                	mov    %esp,%ebp
80104f3c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104f3f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104f46:	eb 04                	jmp    80104f4c <strlen+0x17>
80104f48:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104f4c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f52:	01 d0                	add    %edx,%eax
80104f54:	0f b6 00             	movzbl (%eax),%eax
80104f57:	84 c0                	test   %al,%al
80104f59:	75 ed                	jne    80104f48 <strlen+0x13>
    ;
  return n;
80104f5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f5e:	c9                   	leave
80104f5f:	c3                   	ret

80104f60 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104f60:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104f64:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104f68:	55                   	push   %ebp
  pushl %ebx
80104f69:	53                   	push   %ebx
  pushl %esi
80104f6a:	56                   	push   %esi
  pushl %edi
80104f6b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104f6c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104f6e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104f70:	5f                   	pop    %edi
  popl %esi
80104f71:	5e                   	pop    %esi
  popl %ebx
80104f72:	5b                   	pop    %ebx
  popl %ebp
80104f73:	5d                   	pop    %ebp
  ret
80104f74:	c3                   	ret

80104f75 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104f75:	f3 0f 1e fb          	endbr32
80104f79:	55                   	push   %ebp
80104f7a:	89 e5                	mov    %esp,%ebp
  // sz가 stack영역은 포함하지 않게 설정되었기 때문에 kernbase로 변경
  // fetchstr, argptr도 동일
  if(addr >= KERNBASE || addr+4 >= KERNBASE)
80104f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7f:	85 c0                	test   %eax,%eax
80104f81:	78 0a                	js     80104f8d <fetchint+0x18>
80104f83:	8b 45 08             	mov    0x8(%ebp),%eax
80104f86:	83 c0 04             	add    $0x4,%eax
80104f89:	85 c0                	test   %eax,%eax
80104f8b:	79 07                	jns    80104f94 <fetchint+0x1f>
    return -1;
80104f8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f92:	eb 0f                	jmp    80104fa3 <fetchint+0x2e>
  *ip = *(int*)(addr);
80104f94:	8b 45 08             	mov    0x8(%ebp),%eax
80104f97:	8b 10                	mov    (%eax),%edx
80104f99:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f9c:	89 10                	mov    %edx,(%eax)
  return 0;
80104f9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fa3:	5d                   	pop    %ebp
80104fa4:	c3                   	ret

80104fa5 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104fa5:	f3 0f 1e fb          	endbr32
80104fa9:	55                   	push   %ebp
80104faa:	89 e5                	mov    %esp,%ebp
80104fac:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= KERNBASE)
80104faf:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb2:	85 c0                	test   %eax,%eax
80104fb4:	79 07                	jns    80104fbd <fetchstr+0x18>
    return -1;
80104fb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fbb:	eb 42                	jmp    80104fff <fetchstr+0x5a>
  *pp = (char*)addr;
80104fbd:	8b 55 08             	mov    0x8(%ebp),%edx
80104fc0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fc3:	89 10                	mov    %edx,(%eax)
  ep = (char*)(KERNBASE-1);
80104fc5:	c7 45 f8 ff ff ff 7f 	movl   $0x7fffffff,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
80104fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fcf:	8b 00                	mov    (%eax),%eax
80104fd1:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104fd4:	eb 1c                	jmp    80104ff2 <fetchstr+0x4d>
    if(*s == 0)
80104fd6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fd9:	0f b6 00             	movzbl (%eax),%eax
80104fdc:	84 c0                	test   %al,%al
80104fde:	75 0e                	jne    80104fee <fetchstr+0x49>
      return s - *pp;
80104fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fe3:	8b 00                	mov    (%eax),%eax
80104fe5:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104fe8:	29 c2                	sub    %eax,%edx
80104fea:	89 d0                	mov    %edx,%eax
80104fec:	eb 11                	jmp    80104fff <fetchstr+0x5a>
  for(s = *pp; s < ep; s++){
80104fee:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104ff2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ff5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104ff8:	72 dc                	jb     80104fd6 <fetchstr+0x31>
  }
  return -1;
80104ffa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104fff:	c9                   	leave
80105000:	c3                   	ret

80105001 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105001:	f3 0f 1e fb          	endbr32
80105005:	55                   	push   %ebp
80105006:	89 e5                	mov    %esp,%ebp
80105008:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010500b:	e8 a9 eb ff ff       	call   80103bb9 <myproc>
80105010:	8b 40 18             	mov    0x18(%eax),%eax
80105013:	8b 40 44             	mov    0x44(%eax),%eax
80105016:	8b 55 08             	mov    0x8(%ebp),%edx
80105019:	c1 e2 02             	shl    $0x2,%edx
8010501c:	01 d0                	add    %edx,%eax
8010501e:	83 c0 04             	add    $0x4,%eax
80105021:	83 ec 08             	sub    $0x8,%esp
80105024:	ff 75 0c             	push   0xc(%ebp)
80105027:	50                   	push   %eax
80105028:	e8 48 ff ff ff       	call   80104f75 <fetchint>
8010502d:	83 c4 10             	add    $0x10,%esp
}
80105030:	c9                   	leave
80105031:	c3                   	ret

80105032 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105032:	f3 0f 1e fb          	endbr32
80105036:	55                   	push   %ebp
80105037:	89 e5                	mov    %esp,%ebp
80105039:	83 ec 18             	sub    $0x18,%esp
  int i;
 
  if(argint(n, &i) < 0)
8010503c:	83 ec 08             	sub    $0x8,%esp
8010503f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105042:	50                   	push   %eax
80105043:	ff 75 08             	push   0x8(%ebp)
80105046:	e8 b6 ff ff ff       	call   80105001 <argint>
8010504b:	83 c4 10             	add    $0x10,%esp
8010504e:	85 c0                	test   %eax,%eax
80105050:	79 07                	jns    80105059 <argptr+0x27>
    return -1;
80105052:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105057:	eb 34                	jmp    8010508d <argptr+0x5b>
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
80105059:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010505d:	78 18                	js     80105077 <argptr+0x45>
8010505f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105062:	85 c0                	test   %eax,%eax
80105064:	78 11                	js     80105077 <argptr+0x45>
80105066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105069:	89 c2                	mov    %eax,%edx
8010506b:	8b 45 10             	mov    0x10(%ebp),%eax
8010506e:	01 d0                	add    %edx,%eax
80105070:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80105075:	76 07                	jbe    8010507e <argptr+0x4c>
    return -1;
80105077:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010507c:	eb 0f                	jmp    8010508d <argptr+0x5b>
  *pp = (char*)i;
8010507e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105081:	89 c2                	mov    %eax,%edx
80105083:	8b 45 0c             	mov    0xc(%ebp),%eax
80105086:	89 10                	mov    %edx,(%eax)
  return 0;
80105088:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010508d:	c9                   	leave
8010508e:	c3                   	ret

8010508f <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010508f:	f3 0f 1e fb          	endbr32
80105093:	55                   	push   %ebp
80105094:	89 e5                	mov    %esp,%ebp
80105096:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105099:	83 ec 08             	sub    $0x8,%esp
8010509c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010509f:	50                   	push   %eax
801050a0:	ff 75 08             	push   0x8(%ebp)
801050a3:	e8 59 ff ff ff       	call   80105001 <argint>
801050a8:	83 c4 10             	add    $0x10,%esp
801050ab:	85 c0                	test   %eax,%eax
801050ad:	79 07                	jns    801050b6 <argstr+0x27>
    return -1;
801050af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050b4:	eb 12                	jmp    801050c8 <argstr+0x39>
  return fetchstr(addr, pp);
801050b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b9:	83 ec 08             	sub    $0x8,%esp
801050bc:	ff 75 0c             	push   0xc(%ebp)
801050bf:	50                   	push   %eax
801050c0:	e8 e0 fe ff ff       	call   80104fa5 <fetchstr>
801050c5:	83 c4 10             	add    $0x10,%esp
}
801050c8:	c9                   	leave
801050c9:	c3                   	ret

801050ca <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
801050ca:	f3 0f 1e fb          	endbr32
801050ce:	55                   	push   %ebp
801050cf:	89 e5                	mov    %esp,%ebp
801050d1:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801050d4:	e8 e0 ea ff ff       	call   80103bb9 <myproc>
801050d9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801050dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050df:	8b 40 18             	mov    0x18(%eax),%eax
801050e2:	8b 40 1c             	mov    0x1c(%eax),%eax
801050e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801050e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801050ec:	7e 2f                	jle    8010511d <syscall+0x53>
801050ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050f1:	83 f8 17             	cmp    $0x17,%eax
801050f4:	77 27                	ja     8010511d <syscall+0x53>
801050f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050f9:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105100:	85 c0                	test   %eax,%eax
80105102:	74 19                	je     8010511d <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105104:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105107:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010510e:	ff d0                	call   *%eax
80105110:	89 c2                	mov    %eax,%edx
80105112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105115:	8b 40 18             	mov    0x18(%eax),%eax
80105118:	89 50 1c             	mov    %edx,0x1c(%eax)
8010511b:	eb 2c                	jmp    80105149 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010511d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105120:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105126:	8b 40 10             	mov    0x10(%eax),%eax
80105129:	ff 75 f0             	push   -0x10(%ebp)
8010512c:	52                   	push   %edx
8010512d:	50                   	push   %eax
8010512e:	68 48 aa 10 80       	push   $0x8010aa48
80105133:	e8 d4 b2 ff ff       	call   8010040c <cprintf>
80105138:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
8010513b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513e:	8b 40 18             	mov    0x18(%eax),%eax
80105141:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105148:	90                   	nop
80105149:	90                   	nop
8010514a:	c9                   	leave
8010514b:	c3                   	ret

8010514c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010514c:	f3 0f 1e fb          	endbr32
80105150:	55                   	push   %ebp
80105151:	89 e5                	mov    %esp,%ebp
80105153:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105156:	83 ec 08             	sub    $0x8,%esp
80105159:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010515c:	50                   	push   %eax
8010515d:	ff 75 08             	push   0x8(%ebp)
80105160:	e8 9c fe ff ff       	call   80105001 <argint>
80105165:	83 c4 10             	add    $0x10,%esp
80105168:	85 c0                	test   %eax,%eax
8010516a:	79 07                	jns    80105173 <argfd+0x27>
    return -1;
8010516c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105171:	eb 4f                	jmp    801051c2 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105173:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105176:	85 c0                	test   %eax,%eax
80105178:	78 20                	js     8010519a <argfd+0x4e>
8010517a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010517d:	83 f8 0f             	cmp    $0xf,%eax
80105180:	7f 18                	jg     8010519a <argfd+0x4e>
80105182:	e8 32 ea ff ff       	call   80103bb9 <myproc>
80105187:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010518a:	83 c2 08             	add    $0x8,%edx
8010518d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105191:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105194:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105198:	75 07                	jne    801051a1 <argfd+0x55>
    return -1;
8010519a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010519f:	eb 21                	jmp    801051c2 <argfd+0x76>
  if(pfd)
801051a1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801051a5:	74 08                	je     801051af <argfd+0x63>
    *pfd = fd;
801051a7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801051ad:	89 10                	mov    %edx,(%eax)
  if(pf)
801051af:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051b3:	74 08                	je     801051bd <argfd+0x71>
    *pf = f;
801051b5:	8b 45 10             	mov    0x10(%ebp),%eax
801051b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801051bb:	89 10                	mov    %edx,(%eax)
  return 0;
801051bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051c2:	c9                   	leave
801051c3:	c3                   	ret

801051c4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801051c4:	f3 0f 1e fb          	endbr32
801051c8:	55                   	push   %ebp
801051c9:	89 e5                	mov    %esp,%ebp
801051cb:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801051ce:	e8 e6 e9 ff ff       	call   80103bb9 <myproc>
801051d3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801051d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801051dd:	eb 2a                	jmp    80105209 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
801051df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801051e5:	83 c2 08             	add    $0x8,%edx
801051e8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801051ec:	85 c0                	test   %eax,%eax
801051ee:	75 15                	jne    80105205 <fdalloc+0x41>
      curproc->ofile[fd] = f;
801051f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801051f6:	8d 4a 08             	lea    0x8(%edx),%ecx
801051f9:	8b 55 08             	mov    0x8(%ebp),%edx
801051fc:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105203:	eb 0f                	jmp    80105214 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105205:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105209:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010520d:	7e d0                	jle    801051df <fdalloc+0x1b>
    }
  }
  return -1;
8010520f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105214:	c9                   	leave
80105215:	c3                   	ret

80105216 <sys_dup>:

int
sys_dup(void)
{
80105216:	f3 0f 1e fb          	endbr32
8010521a:	55                   	push   %ebp
8010521b:	89 e5                	mov    %esp,%ebp
8010521d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105220:	83 ec 04             	sub    $0x4,%esp
80105223:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105226:	50                   	push   %eax
80105227:	6a 00                	push   $0x0
80105229:	6a 00                	push   $0x0
8010522b:	e8 1c ff ff ff       	call   8010514c <argfd>
80105230:	83 c4 10             	add    $0x10,%esp
80105233:	85 c0                	test   %eax,%eax
80105235:	79 07                	jns    8010523e <sys_dup+0x28>
    return -1;
80105237:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010523c:	eb 31                	jmp    8010526f <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
8010523e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105241:	83 ec 0c             	sub    $0xc,%esp
80105244:	50                   	push   %eax
80105245:	e8 7a ff ff ff       	call   801051c4 <fdalloc>
8010524a:	83 c4 10             	add    $0x10,%esp
8010524d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105250:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105254:	79 07                	jns    8010525d <sys_dup+0x47>
    return -1;
80105256:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010525b:	eb 12                	jmp    8010526f <sys_dup+0x59>
  filedup(f);
8010525d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105260:	83 ec 0c             	sub    $0xc,%esp
80105263:	50                   	push   %eax
80105264:	e8 3b be ff ff       	call   801010a4 <filedup>
80105269:	83 c4 10             	add    $0x10,%esp
  return fd;
8010526c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010526f:	c9                   	leave
80105270:	c3                   	ret

80105271 <sys_read>:

int
sys_read(void)
{
80105271:	f3 0f 1e fb          	endbr32
80105275:	55                   	push   %ebp
80105276:	89 e5                	mov    %esp,%ebp
80105278:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010527b:	83 ec 04             	sub    $0x4,%esp
8010527e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105281:	50                   	push   %eax
80105282:	6a 00                	push   $0x0
80105284:	6a 00                	push   $0x0
80105286:	e8 c1 fe ff ff       	call   8010514c <argfd>
8010528b:	83 c4 10             	add    $0x10,%esp
8010528e:	85 c0                	test   %eax,%eax
80105290:	78 2e                	js     801052c0 <sys_read+0x4f>
80105292:	83 ec 08             	sub    $0x8,%esp
80105295:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105298:	50                   	push   %eax
80105299:	6a 02                	push   $0x2
8010529b:	e8 61 fd ff ff       	call   80105001 <argint>
801052a0:	83 c4 10             	add    $0x10,%esp
801052a3:	85 c0                	test   %eax,%eax
801052a5:	78 19                	js     801052c0 <sys_read+0x4f>
801052a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052aa:	83 ec 04             	sub    $0x4,%esp
801052ad:	50                   	push   %eax
801052ae:	8d 45 ec             	lea    -0x14(%ebp),%eax
801052b1:	50                   	push   %eax
801052b2:	6a 01                	push   $0x1
801052b4:	e8 79 fd ff ff       	call   80105032 <argptr>
801052b9:	83 c4 10             	add    $0x10,%esp
801052bc:	85 c0                	test   %eax,%eax
801052be:	79 07                	jns    801052c7 <sys_read+0x56>
    return -1;
801052c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052c5:	eb 17                	jmp    801052de <sys_read+0x6d>
  return fileread(f, p, n);
801052c7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801052ca:	8b 55 ec             	mov    -0x14(%ebp),%edx
801052cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052d0:	83 ec 04             	sub    $0x4,%esp
801052d3:	51                   	push   %ecx
801052d4:	52                   	push   %edx
801052d5:	50                   	push   %eax
801052d6:	e8 65 bf ff ff       	call   80101240 <fileread>
801052db:	83 c4 10             	add    $0x10,%esp
}
801052de:	c9                   	leave
801052df:	c3                   	ret

801052e0 <sys_write>:

int
sys_write(void)
{
801052e0:	f3 0f 1e fb          	endbr32
801052e4:	55                   	push   %ebp
801052e5:	89 e5                	mov    %esp,%ebp
801052e7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801052ea:	83 ec 04             	sub    $0x4,%esp
801052ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052f0:	50                   	push   %eax
801052f1:	6a 00                	push   $0x0
801052f3:	6a 00                	push   $0x0
801052f5:	e8 52 fe ff ff       	call   8010514c <argfd>
801052fa:	83 c4 10             	add    $0x10,%esp
801052fd:	85 c0                	test   %eax,%eax
801052ff:	78 2e                	js     8010532f <sys_write+0x4f>
80105301:	83 ec 08             	sub    $0x8,%esp
80105304:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105307:	50                   	push   %eax
80105308:	6a 02                	push   $0x2
8010530a:	e8 f2 fc ff ff       	call   80105001 <argint>
8010530f:	83 c4 10             	add    $0x10,%esp
80105312:	85 c0                	test   %eax,%eax
80105314:	78 19                	js     8010532f <sys_write+0x4f>
80105316:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105319:	83 ec 04             	sub    $0x4,%esp
8010531c:	50                   	push   %eax
8010531d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105320:	50                   	push   %eax
80105321:	6a 01                	push   $0x1
80105323:	e8 0a fd ff ff       	call   80105032 <argptr>
80105328:	83 c4 10             	add    $0x10,%esp
8010532b:	85 c0                	test   %eax,%eax
8010532d:	79 07                	jns    80105336 <sys_write+0x56>
    return -1;
8010532f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105334:	eb 17                	jmp    8010534d <sys_write+0x6d>
  return filewrite(f, p, n);
80105336:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105339:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010533c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010533f:	83 ec 04             	sub    $0x4,%esp
80105342:	51                   	push   %ecx
80105343:	52                   	push   %edx
80105344:	50                   	push   %eax
80105345:	e8 b2 bf ff ff       	call   801012fc <filewrite>
8010534a:	83 c4 10             	add    $0x10,%esp
}
8010534d:	c9                   	leave
8010534e:	c3                   	ret

8010534f <sys_close>:

int
sys_close(void)
{
8010534f:	f3 0f 1e fb          	endbr32
80105353:	55                   	push   %ebp
80105354:	89 e5                	mov    %esp,%ebp
80105356:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105359:	83 ec 04             	sub    $0x4,%esp
8010535c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010535f:	50                   	push   %eax
80105360:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105363:	50                   	push   %eax
80105364:	6a 00                	push   $0x0
80105366:	e8 e1 fd ff ff       	call   8010514c <argfd>
8010536b:	83 c4 10             	add    $0x10,%esp
8010536e:	85 c0                	test   %eax,%eax
80105370:	79 07                	jns    80105379 <sys_close+0x2a>
    return -1;
80105372:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105377:	eb 27                	jmp    801053a0 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105379:	e8 3b e8 ff ff       	call   80103bb9 <myproc>
8010537e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105381:	83 c2 08             	add    $0x8,%edx
80105384:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010538b:	00 
  fileclose(f);
8010538c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010538f:	83 ec 0c             	sub    $0xc,%esp
80105392:	50                   	push   %eax
80105393:	e8 61 bd ff ff       	call   801010f9 <fileclose>
80105398:	83 c4 10             	add    $0x10,%esp
  return 0;
8010539b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053a0:	c9                   	leave
801053a1:	c3                   	ret

801053a2 <sys_fstat>:

int
sys_fstat(void)
{
801053a2:	f3 0f 1e fb          	endbr32
801053a6:	55                   	push   %ebp
801053a7:	89 e5                	mov    %esp,%ebp
801053a9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801053ac:	83 ec 04             	sub    $0x4,%esp
801053af:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053b2:	50                   	push   %eax
801053b3:	6a 00                	push   $0x0
801053b5:	6a 00                	push   $0x0
801053b7:	e8 90 fd ff ff       	call   8010514c <argfd>
801053bc:	83 c4 10             	add    $0x10,%esp
801053bf:	85 c0                	test   %eax,%eax
801053c1:	78 17                	js     801053da <sys_fstat+0x38>
801053c3:	83 ec 04             	sub    $0x4,%esp
801053c6:	6a 14                	push   $0x14
801053c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053cb:	50                   	push   %eax
801053cc:	6a 01                	push   $0x1
801053ce:	e8 5f fc ff ff       	call   80105032 <argptr>
801053d3:	83 c4 10             	add    $0x10,%esp
801053d6:	85 c0                	test   %eax,%eax
801053d8:	79 07                	jns    801053e1 <sys_fstat+0x3f>
    return -1;
801053da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053df:	eb 13                	jmp    801053f4 <sys_fstat+0x52>
  return filestat(f, st);
801053e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801053e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053e7:	83 ec 08             	sub    $0x8,%esp
801053ea:	52                   	push   %edx
801053eb:	50                   	push   %eax
801053ec:	e8 f4 bd ff ff       	call   801011e5 <filestat>
801053f1:	83 c4 10             	add    $0x10,%esp
}
801053f4:	c9                   	leave
801053f5:	c3                   	ret

801053f6 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801053f6:	f3 0f 1e fb          	endbr32
801053fa:	55                   	push   %ebp
801053fb:	89 e5                	mov    %esp,%ebp
801053fd:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105400:	83 ec 08             	sub    $0x8,%esp
80105403:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105406:	50                   	push   %eax
80105407:	6a 00                	push   $0x0
80105409:	e8 81 fc ff ff       	call   8010508f <argstr>
8010540e:	83 c4 10             	add    $0x10,%esp
80105411:	85 c0                	test   %eax,%eax
80105413:	78 15                	js     8010542a <sys_link+0x34>
80105415:	83 ec 08             	sub    $0x8,%esp
80105418:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010541b:	50                   	push   %eax
8010541c:	6a 01                	push   $0x1
8010541e:	e8 6c fc ff ff       	call   8010508f <argstr>
80105423:	83 c4 10             	add    $0x10,%esp
80105426:	85 c0                	test   %eax,%eax
80105428:	79 0a                	jns    80105434 <sys_link+0x3e>
    return -1;
8010542a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010542f:	e9 68 01 00 00       	jmp    8010559c <sys_link+0x1a6>

  begin_op();
80105434:	e8 48 dd ff ff       	call   80103181 <begin_op>
  if((ip = namei(old)) == 0){
80105439:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010543c:	83 ec 0c             	sub    $0xc,%esp
8010543f:	50                   	push   %eax
80105440:	e8 b2 d1 ff ff       	call   801025f7 <namei>
80105445:	83 c4 10             	add    $0x10,%esp
80105448:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010544b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010544f:	75 0f                	jne    80105460 <sys_link+0x6a>
    end_op();
80105451:	e8 bb dd ff ff       	call   80103211 <end_op>
    return -1;
80105456:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010545b:	e9 3c 01 00 00       	jmp    8010559c <sys_link+0x1a6>
  }

  ilock(ip);
80105460:	83 ec 0c             	sub    $0xc,%esp
80105463:	ff 75 f4             	push   -0xc(%ebp)
80105466:	e8 21 c6 ff ff       	call   80101a8c <ilock>
8010546b:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010546e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105471:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105475:	66 83 f8 01          	cmp    $0x1,%ax
80105479:	75 1d                	jne    80105498 <sys_link+0xa2>
    iunlockput(ip);
8010547b:	83 ec 0c             	sub    $0xc,%esp
8010547e:	ff 75 f4             	push   -0xc(%ebp)
80105481:	e8 43 c8 ff ff       	call   80101cc9 <iunlockput>
80105486:	83 c4 10             	add    $0x10,%esp
    end_op();
80105489:	e8 83 dd ff ff       	call   80103211 <end_op>
    return -1;
8010548e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105493:	e9 04 01 00 00       	jmp    8010559c <sys_link+0x1a6>
  }

  ip->nlink++;
80105498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010549b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010549f:	83 c0 01             	add    $0x1,%eax
801054a2:	89 c2                	mov    %eax,%edx
801054a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054a7:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801054ab:	83 ec 0c             	sub    $0xc,%esp
801054ae:	ff 75 f4             	push   -0xc(%ebp)
801054b1:	e8 ed c3 ff ff       	call   801018a3 <iupdate>
801054b6:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801054b9:	83 ec 0c             	sub    $0xc,%esp
801054bc:	ff 75 f4             	push   -0xc(%ebp)
801054bf:	e8 df c6 ff ff       	call   80101ba3 <iunlock>
801054c4:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801054c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801054ca:	83 ec 08             	sub    $0x8,%esp
801054cd:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801054d0:	52                   	push   %edx
801054d1:	50                   	push   %eax
801054d2:	e8 40 d1 ff ff       	call   80102617 <nameiparent>
801054d7:	83 c4 10             	add    $0x10,%esp
801054da:	89 45 f0             	mov    %eax,-0x10(%ebp)
801054dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054e1:	74 71                	je     80105554 <sys_link+0x15e>
    goto bad;
  ilock(dp);
801054e3:	83 ec 0c             	sub    $0xc,%esp
801054e6:	ff 75 f0             	push   -0x10(%ebp)
801054e9:	e8 9e c5 ff ff       	call   80101a8c <ilock>
801054ee:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801054f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054f4:	8b 10                	mov    (%eax),%edx
801054f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f9:	8b 00                	mov    (%eax),%eax
801054fb:	39 c2                	cmp    %eax,%edx
801054fd:	75 1d                	jne    8010551c <sys_link+0x126>
801054ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105502:	8b 40 04             	mov    0x4(%eax),%eax
80105505:	83 ec 04             	sub    $0x4,%esp
80105508:	50                   	push   %eax
80105509:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010550c:	50                   	push   %eax
8010550d:	ff 75 f0             	push   -0x10(%ebp)
80105510:	e8 3f ce ff ff       	call   80102354 <dirlink>
80105515:	83 c4 10             	add    $0x10,%esp
80105518:	85 c0                	test   %eax,%eax
8010551a:	79 10                	jns    8010552c <sys_link+0x136>
    iunlockput(dp);
8010551c:	83 ec 0c             	sub    $0xc,%esp
8010551f:	ff 75 f0             	push   -0x10(%ebp)
80105522:	e8 a2 c7 ff ff       	call   80101cc9 <iunlockput>
80105527:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010552a:	eb 29                	jmp    80105555 <sys_link+0x15f>
  }
  iunlockput(dp);
8010552c:	83 ec 0c             	sub    $0xc,%esp
8010552f:	ff 75 f0             	push   -0x10(%ebp)
80105532:	e8 92 c7 ff ff       	call   80101cc9 <iunlockput>
80105537:	83 c4 10             	add    $0x10,%esp
  iput(ip);
8010553a:	83 ec 0c             	sub    $0xc,%esp
8010553d:	ff 75 f4             	push   -0xc(%ebp)
80105540:	e8 b0 c6 ff ff       	call   80101bf5 <iput>
80105545:	83 c4 10             	add    $0x10,%esp

  end_op();
80105548:	e8 c4 dc ff ff       	call   80103211 <end_op>

  return 0;
8010554d:	b8 00 00 00 00       	mov    $0x0,%eax
80105552:	eb 48                	jmp    8010559c <sys_link+0x1a6>
    goto bad;
80105554:	90                   	nop

bad:
  ilock(ip);
80105555:	83 ec 0c             	sub    $0xc,%esp
80105558:	ff 75 f4             	push   -0xc(%ebp)
8010555b:	e8 2c c5 ff ff       	call   80101a8c <ilock>
80105560:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105566:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010556a:	83 e8 01             	sub    $0x1,%eax
8010556d:	89 c2                	mov    %eax,%edx
8010556f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105572:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105576:	83 ec 0c             	sub    $0xc,%esp
80105579:	ff 75 f4             	push   -0xc(%ebp)
8010557c:	e8 22 c3 ff ff       	call   801018a3 <iupdate>
80105581:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105584:	83 ec 0c             	sub    $0xc,%esp
80105587:	ff 75 f4             	push   -0xc(%ebp)
8010558a:	e8 3a c7 ff ff       	call   80101cc9 <iunlockput>
8010558f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105592:	e8 7a dc ff ff       	call   80103211 <end_op>
  return -1;
80105597:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010559c:	c9                   	leave
8010559d:	c3                   	ret

8010559e <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010559e:	f3 0f 1e fb          	endbr32
801055a2:	55                   	push   %ebp
801055a3:	89 e5                	mov    %esp,%ebp
801055a5:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801055a8:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801055af:	eb 40                	jmp    801055f1 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801055b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b4:	6a 10                	push   $0x10
801055b6:	50                   	push   %eax
801055b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801055ba:	50                   	push   %eax
801055bb:	ff 75 08             	push   0x8(%ebp)
801055be:	e8 d1 c9 ff ff       	call   80101f94 <readi>
801055c3:	83 c4 10             	add    $0x10,%esp
801055c6:	83 f8 10             	cmp    $0x10,%eax
801055c9:	74 0d                	je     801055d8 <isdirempty+0x3a>
      panic("isdirempty: readi");
801055cb:	83 ec 0c             	sub    $0xc,%esp
801055ce:	68 64 aa 10 80       	push   $0x8010aa64
801055d3:	e8 06 b0 ff ff       	call   801005de <panic>
    if(de.inum != 0)
801055d8:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801055dc:	66 85 c0             	test   %ax,%ax
801055df:	74 07                	je     801055e8 <isdirempty+0x4a>
      return 0;
801055e1:	b8 00 00 00 00       	mov    $0x0,%eax
801055e6:	eb 1b                	jmp    80105603 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801055e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055eb:	83 c0 10             	add    $0x10,%eax
801055ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055f1:	8b 45 08             	mov    0x8(%ebp),%eax
801055f4:	8b 50 58             	mov    0x58(%eax),%edx
801055f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055fa:	39 c2                	cmp    %eax,%edx
801055fc:	77 b3                	ja     801055b1 <isdirempty+0x13>
  }
  return 1;
801055fe:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105603:	c9                   	leave
80105604:	c3                   	ret

80105605 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105605:	f3 0f 1e fb          	endbr32
80105609:	55                   	push   %ebp
8010560a:	89 e5                	mov    %esp,%ebp
8010560c:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010560f:	83 ec 08             	sub    $0x8,%esp
80105612:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105615:	50                   	push   %eax
80105616:	6a 00                	push   $0x0
80105618:	e8 72 fa ff ff       	call   8010508f <argstr>
8010561d:	83 c4 10             	add    $0x10,%esp
80105620:	85 c0                	test   %eax,%eax
80105622:	79 0a                	jns    8010562e <sys_unlink+0x29>
    return -1;
80105624:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105629:	e9 bf 01 00 00       	jmp    801057ed <sys_unlink+0x1e8>

  begin_op();
8010562e:	e8 4e db ff ff       	call   80103181 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105633:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105636:	83 ec 08             	sub    $0x8,%esp
80105639:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010563c:	52                   	push   %edx
8010563d:	50                   	push   %eax
8010563e:	e8 d4 cf ff ff       	call   80102617 <nameiparent>
80105643:	83 c4 10             	add    $0x10,%esp
80105646:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105649:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010564d:	75 0f                	jne    8010565e <sys_unlink+0x59>
    end_op();
8010564f:	e8 bd db ff ff       	call   80103211 <end_op>
    return -1;
80105654:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105659:	e9 8f 01 00 00       	jmp    801057ed <sys_unlink+0x1e8>
  }

  ilock(dp);
8010565e:	83 ec 0c             	sub    $0xc,%esp
80105661:	ff 75 f4             	push   -0xc(%ebp)
80105664:	e8 23 c4 ff ff       	call   80101a8c <ilock>
80105669:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010566c:	83 ec 08             	sub    $0x8,%esp
8010566f:	68 76 aa 10 80       	push   $0x8010aa76
80105674:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105677:	50                   	push   %eax
80105678:	e8 fa cb ff ff       	call   80102277 <namecmp>
8010567d:	83 c4 10             	add    $0x10,%esp
80105680:	85 c0                	test   %eax,%eax
80105682:	0f 84 49 01 00 00    	je     801057d1 <sys_unlink+0x1cc>
80105688:	83 ec 08             	sub    $0x8,%esp
8010568b:	68 78 aa 10 80       	push   $0x8010aa78
80105690:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105693:	50                   	push   %eax
80105694:	e8 de cb ff ff       	call   80102277 <namecmp>
80105699:	83 c4 10             	add    $0x10,%esp
8010569c:	85 c0                	test   %eax,%eax
8010569e:	0f 84 2d 01 00 00    	je     801057d1 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801056a4:	83 ec 04             	sub    $0x4,%esp
801056a7:	8d 45 c8             	lea    -0x38(%ebp),%eax
801056aa:	50                   	push   %eax
801056ab:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801056ae:	50                   	push   %eax
801056af:	ff 75 f4             	push   -0xc(%ebp)
801056b2:	e8 df cb ff ff       	call   80102296 <dirlookup>
801056b7:	83 c4 10             	add    $0x10,%esp
801056ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
801056bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801056c1:	0f 84 0d 01 00 00    	je     801057d4 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
801056c7:	83 ec 0c             	sub    $0xc,%esp
801056ca:	ff 75 f0             	push   -0x10(%ebp)
801056cd:	e8 ba c3 ff ff       	call   80101a8c <ilock>
801056d2:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801056d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d8:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056dc:	66 85 c0             	test   %ax,%ax
801056df:	7f 0d                	jg     801056ee <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
801056e1:	83 ec 0c             	sub    $0xc,%esp
801056e4:	68 7b aa 10 80       	push   $0x8010aa7b
801056e9:	e8 f0 ae ff ff       	call   801005de <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801056ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056f1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801056f5:	66 83 f8 01          	cmp    $0x1,%ax
801056f9:	75 25                	jne    80105720 <sys_unlink+0x11b>
801056fb:	83 ec 0c             	sub    $0xc,%esp
801056fe:	ff 75 f0             	push   -0x10(%ebp)
80105701:	e8 98 fe ff ff       	call   8010559e <isdirempty>
80105706:	83 c4 10             	add    $0x10,%esp
80105709:	85 c0                	test   %eax,%eax
8010570b:	75 13                	jne    80105720 <sys_unlink+0x11b>
    iunlockput(ip);
8010570d:	83 ec 0c             	sub    $0xc,%esp
80105710:	ff 75 f0             	push   -0x10(%ebp)
80105713:	e8 b1 c5 ff ff       	call   80101cc9 <iunlockput>
80105718:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010571b:	e9 b5 00 00 00       	jmp    801057d5 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105720:	83 ec 04             	sub    $0x4,%esp
80105723:	6a 10                	push   $0x10
80105725:	6a 00                	push   $0x0
80105727:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010572a:	50                   	push   %eax
8010572b:	e8 9c f5 ff ff       	call   80104ccc <memset>
80105730:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105733:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105736:	6a 10                	push   $0x10
80105738:	50                   	push   %eax
80105739:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010573c:	50                   	push   %eax
8010573d:	ff 75 f4             	push   -0xc(%ebp)
80105740:	e8 a8 c9 ff ff       	call   801020ed <writei>
80105745:	83 c4 10             	add    $0x10,%esp
80105748:	83 f8 10             	cmp    $0x10,%eax
8010574b:	74 0d                	je     8010575a <sys_unlink+0x155>
    panic("unlink: writei");
8010574d:	83 ec 0c             	sub    $0xc,%esp
80105750:	68 8d aa 10 80       	push   $0x8010aa8d
80105755:	e8 84 ae ff ff       	call   801005de <panic>
  if(ip->type == T_DIR){
8010575a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010575d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105761:	66 83 f8 01          	cmp    $0x1,%ax
80105765:	75 21                	jne    80105788 <sys_unlink+0x183>
    dp->nlink--;
80105767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010576a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010576e:	83 e8 01             	sub    $0x1,%eax
80105771:	89 c2                	mov    %eax,%edx
80105773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105776:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010577a:	83 ec 0c             	sub    $0xc,%esp
8010577d:	ff 75 f4             	push   -0xc(%ebp)
80105780:	e8 1e c1 ff ff       	call   801018a3 <iupdate>
80105785:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105788:	83 ec 0c             	sub    $0xc,%esp
8010578b:	ff 75 f4             	push   -0xc(%ebp)
8010578e:	e8 36 c5 ff ff       	call   80101cc9 <iunlockput>
80105793:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105796:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105799:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010579d:	83 e8 01             	sub    $0x1,%eax
801057a0:	89 c2                	mov    %eax,%edx
801057a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a5:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801057a9:	83 ec 0c             	sub    $0xc,%esp
801057ac:	ff 75 f0             	push   -0x10(%ebp)
801057af:	e8 ef c0 ff ff       	call   801018a3 <iupdate>
801057b4:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801057b7:	83 ec 0c             	sub    $0xc,%esp
801057ba:	ff 75 f0             	push   -0x10(%ebp)
801057bd:	e8 07 c5 ff ff       	call   80101cc9 <iunlockput>
801057c2:	83 c4 10             	add    $0x10,%esp

  end_op();
801057c5:	e8 47 da ff ff       	call   80103211 <end_op>

  return 0;
801057ca:	b8 00 00 00 00       	mov    $0x0,%eax
801057cf:	eb 1c                	jmp    801057ed <sys_unlink+0x1e8>
    goto bad;
801057d1:	90                   	nop
801057d2:	eb 01                	jmp    801057d5 <sys_unlink+0x1d0>
    goto bad;
801057d4:	90                   	nop

bad:
  iunlockput(dp);
801057d5:	83 ec 0c             	sub    $0xc,%esp
801057d8:	ff 75 f4             	push   -0xc(%ebp)
801057db:	e8 e9 c4 ff ff       	call   80101cc9 <iunlockput>
801057e0:	83 c4 10             	add    $0x10,%esp
  end_op();
801057e3:	e8 29 da ff ff       	call   80103211 <end_op>
  return -1;
801057e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057ed:	c9                   	leave
801057ee:	c3                   	ret

801057ef <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801057ef:	f3 0f 1e fb          	endbr32
801057f3:	55                   	push   %ebp
801057f4:	89 e5                	mov    %esp,%ebp
801057f6:	83 ec 38             	sub    $0x38,%esp
801057f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801057fc:	8b 55 10             	mov    0x10(%ebp),%edx
801057ff:	8b 45 14             	mov    0x14(%ebp),%eax
80105802:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105806:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010580a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010580e:	83 ec 08             	sub    $0x8,%esp
80105811:	8d 45 de             	lea    -0x22(%ebp),%eax
80105814:	50                   	push   %eax
80105815:	ff 75 08             	push   0x8(%ebp)
80105818:	e8 fa cd ff ff       	call   80102617 <nameiparent>
8010581d:	83 c4 10             	add    $0x10,%esp
80105820:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105823:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105827:	75 0a                	jne    80105833 <create+0x44>
    return 0;
80105829:	b8 00 00 00 00       	mov    $0x0,%eax
8010582e:	e9 90 01 00 00       	jmp    801059c3 <create+0x1d4>
  ilock(dp);
80105833:	83 ec 0c             	sub    $0xc,%esp
80105836:	ff 75 f4             	push   -0xc(%ebp)
80105839:	e8 4e c2 ff ff       	call   80101a8c <ilock>
8010583e:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105841:	83 ec 04             	sub    $0x4,%esp
80105844:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105847:	50                   	push   %eax
80105848:	8d 45 de             	lea    -0x22(%ebp),%eax
8010584b:	50                   	push   %eax
8010584c:	ff 75 f4             	push   -0xc(%ebp)
8010584f:	e8 42 ca ff ff       	call   80102296 <dirlookup>
80105854:	83 c4 10             	add    $0x10,%esp
80105857:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010585a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010585e:	74 50                	je     801058b0 <create+0xc1>
    iunlockput(dp);
80105860:	83 ec 0c             	sub    $0xc,%esp
80105863:	ff 75 f4             	push   -0xc(%ebp)
80105866:	e8 5e c4 ff ff       	call   80101cc9 <iunlockput>
8010586b:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010586e:	83 ec 0c             	sub    $0xc,%esp
80105871:	ff 75 f0             	push   -0x10(%ebp)
80105874:	e8 13 c2 ff ff       	call   80101a8c <ilock>
80105879:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010587c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105881:	75 15                	jne    80105898 <create+0xa9>
80105883:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105886:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010588a:	66 83 f8 02          	cmp    $0x2,%ax
8010588e:	75 08                	jne    80105898 <create+0xa9>
      return ip;
80105890:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105893:	e9 2b 01 00 00       	jmp    801059c3 <create+0x1d4>
    iunlockput(ip);
80105898:	83 ec 0c             	sub    $0xc,%esp
8010589b:	ff 75 f0             	push   -0x10(%ebp)
8010589e:	e8 26 c4 ff ff       	call   80101cc9 <iunlockput>
801058a3:	83 c4 10             	add    $0x10,%esp
    return 0;
801058a6:	b8 00 00 00 00       	mov    $0x0,%eax
801058ab:	e9 13 01 00 00       	jmp    801059c3 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801058b0:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801058b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b7:	8b 00                	mov    (%eax),%eax
801058b9:	83 ec 08             	sub    $0x8,%esp
801058bc:	52                   	push   %edx
801058bd:	50                   	push   %eax
801058be:	e8 05 bf ff ff       	call   801017c8 <ialloc>
801058c3:	83 c4 10             	add    $0x10,%esp
801058c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801058c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058cd:	75 0d                	jne    801058dc <create+0xed>
    panic("create: ialloc");
801058cf:	83 ec 0c             	sub    $0xc,%esp
801058d2:	68 9c aa 10 80       	push   $0x8010aa9c
801058d7:	e8 02 ad ff ff       	call   801005de <panic>

  ilock(ip);
801058dc:	83 ec 0c             	sub    $0xc,%esp
801058df:	ff 75 f0             	push   -0x10(%ebp)
801058e2:	e8 a5 c1 ff ff       	call   80101a8c <ilock>
801058e7:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801058ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ed:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801058f1:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801058f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f8:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801058fc:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105900:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105903:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105909:	83 ec 0c             	sub    $0xc,%esp
8010590c:	ff 75 f0             	push   -0x10(%ebp)
8010590f:	e8 8f bf ff ff       	call   801018a3 <iupdate>
80105914:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105917:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010591c:	75 6a                	jne    80105988 <create+0x199>
    dp->nlink++;  // for ".."
8010591e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105921:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105925:	83 c0 01             	add    $0x1,%eax
80105928:	89 c2                	mov    %eax,%edx
8010592a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010592d:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105931:	83 ec 0c             	sub    $0xc,%esp
80105934:	ff 75 f4             	push   -0xc(%ebp)
80105937:	e8 67 bf ff ff       	call   801018a3 <iupdate>
8010593c:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010593f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105942:	8b 40 04             	mov    0x4(%eax),%eax
80105945:	83 ec 04             	sub    $0x4,%esp
80105948:	50                   	push   %eax
80105949:	68 76 aa 10 80       	push   $0x8010aa76
8010594e:	ff 75 f0             	push   -0x10(%ebp)
80105951:	e8 fe c9 ff ff       	call   80102354 <dirlink>
80105956:	83 c4 10             	add    $0x10,%esp
80105959:	85 c0                	test   %eax,%eax
8010595b:	78 1e                	js     8010597b <create+0x18c>
8010595d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105960:	8b 40 04             	mov    0x4(%eax),%eax
80105963:	83 ec 04             	sub    $0x4,%esp
80105966:	50                   	push   %eax
80105967:	68 78 aa 10 80       	push   $0x8010aa78
8010596c:	ff 75 f0             	push   -0x10(%ebp)
8010596f:	e8 e0 c9 ff ff       	call   80102354 <dirlink>
80105974:	83 c4 10             	add    $0x10,%esp
80105977:	85 c0                	test   %eax,%eax
80105979:	79 0d                	jns    80105988 <create+0x199>
      panic("create dots");
8010597b:	83 ec 0c             	sub    $0xc,%esp
8010597e:	68 ab aa 10 80       	push   $0x8010aaab
80105983:	e8 56 ac ff ff       	call   801005de <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105988:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010598b:	8b 40 04             	mov    0x4(%eax),%eax
8010598e:	83 ec 04             	sub    $0x4,%esp
80105991:	50                   	push   %eax
80105992:	8d 45 de             	lea    -0x22(%ebp),%eax
80105995:	50                   	push   %eax
80105996:	ff 75 f4             	push   -0xc(%ebp)
80105999:	e8 b6 c9 ff ff       	call   80102354 <dirlink>
8010599e:	83 c4 10             	add    $0x10,%esp
801059a1:	85 c0                	test   %eax,%eax
801059a3:	79 0d                	jns    801059b2 <create+0x1c3>
    panic("create: dirlink");
801059a5:	83 ec 0c             	sub    $0xc,%esp
801059a8:	68 b7 aa 10 80       	push   $0x8010aab7
801059ad:	e8 2c ac ff ff       	call   801005de <panic>

  iunlockput(dp);
801059b2:	83 ec 0c             	sub    $0xc,%esp
801059b5:	ff 75 f4             	push   -0xc(%ebp)
801059b8:	e8 0c c3 ff ff       	call   80101cc9 <iunlockput>
801059bd:	83 c4 10             	add    $0x10,%esp

  return ip;
801059c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801059c3:	c9                   	leave
801059c4:	c3                   	ret

801059c5 <sys_open>:

int
sys_open(void)
{
801059c5:	f3 0f 1e fb          	endbr32
801059c9:	55                   	push   %ebp
801059ca:	89 e5                	mov    %esp,%ebp
801059cc:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801059cf:	83 ec 08             	sub    $0x8,%esp
801059d2:	8d 45 e8             	lea    -0x18(%ebp),%eax
801059d5:	50                   	push   %eax
801059d6:	6a 00                	push   $0x0
801059d8:	e8 b2 f6 ff ff       	call   8010508f <argstr>
801059dd:	83 c4 10             	add    $0x10,%esp
801059e0:	85 c0                	test   %eax,%eax
801059e2:	78 15                	js     801059f9 <sys_open+0x34>
801059e4:	83 ec 08             	sub    $0x8,%esp
801059e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801059ea:	50                   	push   %eax
801059eb:	6a 01                	push   $0x1
801059ed:	e8 0f f6 ff ff       	call   80105001 <argint>
801059f2:	83 c4 10             	add    $0x10,%esp
801059f5:	85 c0                	test   %eax,%eax
801059f7:	79 0a                	jns    80105a03 <sys_open+0x3e>
    return -1;
801059f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059fe:	e9 61 01 00 00       	jmp    80105b64 <sys_open+0x19f>

  begin_op();
80105a03:	e8 79 d7 ff ff       	call   80103181 <begin_op>

  if(omode & O_CREATE){
80105a08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a0b:	25 00 02 00 00       	and    $0x200,%eax
80105a10:	85 c0                	test   %eax,%eax
80105a12:	74 2a                	je     80105a3e <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80105a14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a17:	6a 00                	push   $0x0
80105a19:	6a 00                	push   $0x0
80105a1b:	6a 02                	push   $0x2
80105a1d:	50                   	push   %eax
80105a1e:	e8 cc fd ff ff       	call   801057ef <create>
80105a23:	83 c4 10             	add    $0x10,%esp
80105a26:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105a29:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a2d:	75 75                	jne    80105aa4 <sys_open+0xdf>
      end_op();
80105a2f:	e8 dd d7 ff ff       	call   80103211 <end_op>
      return -1;
80105a34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a39:	e9 26 01 00 00       	jmp    80105b64 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80105a3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a41:	83 ec 0c             	sub    $0xc,%esp
80105a44:	50                   	push   %eax
80105a45:	e8 ad cb ff ff       	call   801025f7 <namei>
80105a4a:	83 c4 10             	add    $0x10,%esp
80105a4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a50:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a54:	75 0f                	jne    80105a65 <sys_open+0xa0>
      end_op();
80105a56:	e8 b6 d7 ff ff       	call   80103211 <end_op>
      return -1;
80105a5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a60:	e9 ff 00 00 00       	jmp    80105b64 <sys_open+0x19f>
    }
    ilock(ip);
80105a65:	83 ec 0c             	sub    $0xc,%esp
80105a68:	ff 75 f4             	push   -0xc(%ebp)
80105a6b:	e8 1c c0 ff ff       	call   80101a8c <ilock>
80105a70:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a76:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a7a:	66 83 f8 01          	cmp    $0x1,%ax
80105a7e:	75 24                	jne    80105aa4 <sys_open+0xdf>
80105a80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a83:	85 c0                	test   %eax,%eax
80105a85:	74 1d                	je     80105aa4 <sys_open+0xdf>
      iunlockput(ip);
80105a87:	83 ec 0c             	sub    $0xc,%esp
80105a8a:	ff 75 f4             	push   -0xc(%ebp)
80105a8d:	e8 37 c2 ff ff       	call   80101cc9 <iunlockput>
80105a92:	83 c4 10             	add    $0x10,%esp
      end_op();
80105a95:	e8 77 d7 ff ff       	call   80103211 <end_op>
      return -1;
80105a9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a9f:	e9 c0 00 00 00       	jmp    80105b64 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105aa4:	e8 8a b5 ff ff       	call   80101033 <filealloc>
80105aa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105aac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ab0:	74 17                	je     80105ac9 <sys_open+0x104>
80105ab2:	83 ec 0c             	sub    $0xc,%esp
80105ab5:	ff 75 f0             	push   -0x10(%ebp)
80105ab8:	e8 07 f7 ff ff       	call   801051c4 <fdalloc>
80105abd:	83 c4 10             	add    $0x10,%esp
80105ac0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105ac3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105ac7:	79 2e                	jns    80105af7 <sys_open+0x132>
    if(f)
80105ac9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105acd:	74 0e                	je     80105add <sys_open+0x118>
      fileclose(f);
80105acf:	83 ec 0c             	sub    $0xc,%esp
80105ad2:	ff 75 f0             	push   -0x10(%ebp)
80105ad5:	e8 1f b6 ff ff       	call   801010f9 <fileclose>
80105ada:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105add:	83 ec 0c             	sub    $0xc,%esp
80105ae0:	ff 75 f4             	push   -0xc(%ebp)
80105ae3:	e8 e1 c1 ff ff       	call   80101cc9 <iunlockput>
80105ae8:	83 c4 10             	add    $0x10,%esp
    end_op();
80105aeb:	e8 21 d7 ff ff       	call   80103211 <end_op>
    return -1;
80105af0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af5:	eb 6d                	jmp    80105b64 <sys_open+0x19f>
  }
  iunlock(ip);
80105af7:	83 ec 0c             	sub    $0xc,%esp
80105afa:	ff 75 f4             	push   -0xc(%ebp)
80105afd:	e8 a1 c0 ff ff       	call   80101ba3 <iunlock>
80105b02:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b05:	e8 07 d7 ff ff       	call   80103211 <end_op>

  f->type = FD_INODE;
80105b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b0d:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b19:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105b1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b1f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105b26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b29:	83 e0 01             	and    $0x1,%eax
80105b2c:	85 c0                	test   %eax,%eax
80105b2e:	0f 94 c0             	sete   %al
80105b31:	89 c2                	mov    %eax,%edx
80105b33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b36:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105b39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b3c:	83 e0 01             	and    $0x1,%eax
80105b3f:	85 c0                	test   %eax,%eax
80105b41:	75 0a                	jne    80105b4d <sys_open+0x188>
80105b43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b46:	83 e0 02             	and    $0x2,%eax
80105b49:	85 c0                	test   %eax,%eax
80105b4b:	74 07                	je     80105b54 <sys_open+0x18f>
80105b4d:	b8 01 00 00 00       	mov    $0x1,%eax
80105b52:	eb 05                	jmp    80105b59 <sys_open+0x194>
80105b54:	b8 00 00 00 00       	mov    $0x0,%eax
80105b59:	89 c2                	mov    %eax,%edx
80105b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b5e:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105b61:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105b64:	c9                   	leave
80105b65:	c3                   	ret

80105b66 <sys_mkdir>:

int
sys_mkdir(void)
{
80105b66:	f3 0f 1e fb          	endbr32
80105b6a:	55                   	push   %ebp
80105b6b:	89 e5                	mov    %esp,%ebp
80105b6d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105b70:	e8 0c d6 ff ff       	call   80103181 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105b75:	83 ec 08             	sub    $0x8,%esp
80105b78:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b7b:	50                   	push   %eax
80105b7c:	6a 00                	push   $0x0
80105b7e:	e8 0c f5 ff ff       	call   8010508f <argstr>
80105b83:	83 c4 10             	add    $0x10,%esp
80105b86:	85 c0                	test   %eax,%eax
80105b88:	78 1b                	js     80105ba5 <sys_mkdir+0x3f>
80105b8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b8d:	6a 00                	push   $0x0
80105b8f:	6a 00                	push   $0x0
80105b91:	6a 01                	push   $0x1
80105b93:	50                   	push   %eax
80105b94:	e8 56 fc ff ff       	call   801057ef <create>
80105b99:	83 c4 10             	add    $0x10,%esp
80105b9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ba3:	75 0c                	jne    80105bb1 <sys_mkdir+0x4b>
    end_op();
80105ba5:	e8 67 d6 ff ff       	call   80103211 <end_op>
    return -1;
80105baa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105baf:	eb 18                	jmp    80105bc9 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105bb1:	83 ec 0c             	sub    $0xc,%esp
80105bb4:	ff 75 f4             	push   -0xc(%ebp)
80105bb7:	e8 0d c1 ff ff       	call   80101cc9 <iunlockput>
80105bbc:	83 c4 10             	add    $0x10,%esp
  end_op();
80105bbf:	e8 4d d6 ff ff       	call   80103211 <end_op>
  return 0;
80105bc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105bc9:	c9                   	leave
80105bca:	c3                   	ret

80105bcb <sys_mknod>:

int
sys_mknod(void)
{
80105bcb:	f3 0f 1e fb          	endbr32
80105bcf:	55                   	push   %ebp
80105bd0:	89 e5                	mov    %esp,%ebp
80105bd2:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105bd5:	e8 a7 d5 ff ff       	call   80103181 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105bda:	83 ec 08             	sub    $0x8,%esp
80105bdd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105be0:	50                   	push   %eax
80105be1:	6a 00                	push   $0x0
80105be3:	e8 a7 f4 ff ff       	call   8010508f <argstr>
80105be8:	83 c4 10             	add    $0x10,%esp
80105beb:	85 c0                	test   %eax,%eax
80105bed:	78 4f                	js     80105c3e <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105bef:	83 ec 08             	sub    $0x8,%esp
80105bf2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bf5:	50                   	push   %eax
80105bf6:	6a 01                	push   $0x1
80105bf8:	e8 04 f4 ff ff       	call   80105001 <argint>
80105bfd:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105c00:	85 c0                	test   %eax,%eax
80105c02:	78 3a                	js     80105c3e <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105c04:	83 ec 08             	sub    $0x8,%esp
80105c07:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c0a:	50                   	push   %eax
80105c0b:	6a 02                	push   $0x2
80105c0d:	e8 ef f3 ff ff       	call   80105001 <argint>
80105c12:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105c15:	85 c0                	test   %eax,%eax
80105c17:	78 25                	js     80105c3e <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105c19:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c1c:	0f bf c8             	movswl %ax,%ecx
80105c1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c22:	0f bf d0             	movswl %ax,%edx
80105c25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c28:	51                   	push   %ecx
80105c29:	52                   	push   %edx
80105c2a:	6a 03                	push   $0x3
80105c2c:	50                   	push   %eax
80105c2d:	e8 bd fb ff ff       	call   801057ef <create>
80105c32:	83 c4 10             	add    $0x10,%esp
80105c35:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105c38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c3c:	75 0c                	jne    80105c4a <sys_mknod+0x7f>
    end_op();
80105c3e:	e8 ce d5 ff ff       	call   80103211 <end_op>
    return -1;
80105c43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c48:	eb 18                	jmp    80105c62 <sys_mknod+0x97>
  }
  iunlockput(ip);
80105c4a:	83 ec 0c             	sub    $0xc,%esp
80105c4d:	ff 75 f4             	push   -0xc(%ebp)
80105c50:	e8 74 c0 ff ff       	call   80101cc9 <iunlockput>
80105c55:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c58:	e8 b4 d5 ff ff       	call   80103211 <end_op>
  return 0;
80105c5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c62:	c9                   	leave
80105c63:	c3                   	ret

80105c64 <sys_chdir>:

int
sys_chdir(void)
{
80105c64:	f3 0f 1e fb          	endbr32
80105c68:	55                   	push   %ebp
80105c69:	89 e5                	mov    %esp,%ebp
80105c6b:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105c6e:	e8 46 df ff ff       	call   80103bb9 <myproc>
80105c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105c76:	e8 06 d5 ff ff       	call   80103181 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105c7b:	83 ec 08             	sub    $0x8,%esp
80105c7e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c81:	50                   	push   %eax
80105c82:	6a 00                	push   $0x0
80105c84:	e8 06 f4 ff ff       	call   8010508f <argstr>
80105c89:	83 c4 10             	add    $0x10,%esp
80105c8c:	85 c0                	test   %eax,%eax
80105c8e:	78 18                	js     80105ca8 <sys_chdir+0x44>
80105c90:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c93:	83 ec 0c             	sub    $0xc,%esp
80105c96:	50                   	push   %eax
80105c97:	e8 5b c9 ff ff       	call   801025f7 <namei>
80105c9c:	83 c4 10             	add    $0x10,%esp
80105c9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ca2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ca6:	75 0c                	jne    80105cb4 <sys_chdir+0x50>
    end_op();
80105ca8:	e8 64 d5 ff ff       	call   80103211 <end_op>
    return -1;
80105cad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb2:	eb 68                	jmp    80105d1c <sys_chdir+0xb8>
  }
  ilock(ip);
80105cb4:	83 ec 0c             	sub    $0xc,%esp
80105cb7:	ff 75 f0             	push   -0x10(%ebp)
80105cba:	e8 cd bd ff ff       	call   80101a8c <ilock>
80105cbf:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105cc9:	66 83 f8 01          	cmp    $0x1,%ax
80105ccd:	74 1a                	je     80105ce9 <sys_chdir+0x85>
    iunlockput(ip);
80105ccf:	83 ec 0c             	sub    $0xc,%esp
80105cd2:	ff 75 f0             	push   -0x10(%ebp)
80105cd5:	e8 ef bf ff ff       	call   80101cc9 <iunlockput>
80105cda:	83 c4 10             	add    $0x10,%esp
    end_op();
80105cdd:	e8 2f d5 ff ff       	call   80103211 <end_op>
    return -1;
80105ce2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ce7:	eb 33                	jmp    80105d1c <sys_chdir+0xb8>
  }
  iunlock(ip);
80105ce9:	83 ec 0c             	sub    $0xc,%esp
80105cec:	ff 75 f0             	push   -0x10(%ebp)
80105cef:	e8 af be ff ff       	call   80101ba3 <iunlock>
80105cf4:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cfa:	8b 40 68             	mov    0x68(%eax),%eax
80105cfd:	83 ec 0c             	sub    $0xc,%esp
80105d00:	50                   	push   %eax
80105d01:	e8 ef be ff ff       	call   80101bf5 <iput>
80105d06:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d09:	e8 03 d5 ff ff       	call   80103211 <end_op>
  curproc->cwd = ip;
80105d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d11:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d14:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105d17:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d1c:	c9                   	leave
80105d1d:	c3                   	ret

80105d1e <sys_exec>:

int
sys_exec(void)
{
80105d1e:	f3 0f 1e fb          	endbr32
80105d22:	55                   	push   %ebp
80105d23:	89 e5                	mov    %esp,%ebp
80105d25:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105d2b:	83 ec 08             	sub    $0x8,%esp
80105d2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d31:	50                   	push   %eax
80105d32:	6a 00                	push   $0x0
80105d34:	e8 56 f3 ff ff       	call   8010508f <argstr>
80105d39:	83 c4 10             	add    $0x10,%esp
80105d3c:	85 c0                	test   %eax,%eax
80105d3e:	78 18                	js     80105d58 <sys_exec+0x3a>
80105d40:	83 ec 08             	sub    $0x8,%esp
80105d43:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105d49:	50                   	push   %eax
80105d4a:	6a 01                	push   $0x1
80105d4c:	e8 b0 f2 ff ff       	call   80105001 <argint>
80105d51:	83 c4 10             	add    $0x10,%esp
80105d54:	85 c0                	test   %eax,%eax
80105d56:	79 0a                	jns    80105d62 <sys_exec+0x44>
    return -1;
80105d58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d5d:	e9 c6 00 00 00       	jmp    80105e28 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80105d62:	83 ec 04             	sub    $0x4,%esp
80105d65:	68 80 00 00 00       	push   $0x80
80105d6a:	6a 00                	push   $0x0
80105d6c:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105d72:	50                   	push   %eax
80105d73:	e8 54 ef ff ff       	call   80104ccc <memset>
80105d78:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105d7b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d85:	83 f8 1f             	cmp    $0x1f,%eax
80105d88:	76 0a                	jbe    80105d94 <sys_exec+0x76>
      return -1;
80105d8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d8f:	e9 94 00 00 00       	jmp    80105e28 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d97:	c1 e0 02             	shl    $0x2,%eax
80105d9a:	89 c2                	mov    %eax,%edx
80105d9c:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105da2:	01 c2                	add    %eax,%edx
80105da4:	83 ec 08             	sub    $0x8,%esp
80105da7:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105dad:	50                   	push   %eax
80105dae:	52                   	push   %edx
80105daf:	e8 c1 f1 ff ff       	call   80104f75 <fetchint>
80105db4:	83 c4 10             	add    $0x10,%esp
80105db7:	85 c0                	test   %eax,%eax
80105db9:	79 07                	jns    80105dc2 <sys_exec+0xa4>
      return -1;
80105dbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dc0:	eb 66                	jmp    80105e28 <sys_exec+0x10a>
    if(uarg == 0){
80105dc2:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105dc8:	85 c0                	test   %eax,%eax
80105dca:	75 27                	jne    80105df3 <sys_exec+0xd5>
      argv[i] = 0;
80105dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dcf:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105dd6:	00 00 00 00 
      break;
80105dda:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dde:	83 ec 08             	sub    $0x8,%esp
80105de1:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105de7:	52                   	push   %edx
80105de8:	50                   	push   %eax
80105de9:	e8 e9 ad ff ff       	call   80100bd7 <exec>
80105dee:	83 c4 10             	add    $0x10,%esp
80105df1:	eb 35                	jmp    80105e28 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80105df3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105df9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105dfc:	c1 e2 02             	shl    $0x2,%edx
80105dff:	01 c2                	add    %eax,%edx
80105e01:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e07:	83 ec 08             	sub    $0x8,%esp
80105e0a:	52                   	push   %edx
80105e0b:	50                   	push   %eax
80105e0c:	e8 94 f1 ff ff       	call   80104fa5 <fetchstr>
80105e11:	83 c4 10             	add    $0x10,%esp
80105e14:	85 c0                	test   %eax,%eax
80105e16:	79 07                	jns    80105e1f <sys_exec+0x101>
      return -1;
80105e18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e1d:	eb 09                	jmp    80105e28 <sys_exec+0x10a>
  for(i=0;; i++){
80105e1f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e23:	e9 5a ff ff ff       	jmp    80105d82 <sys_exec+0x64>
}
80105e28:	c9                   	leave
80105e29:	c3                   	ret

80105e2a <sys_pipe>:

int
sys_pipe(void)
{
80105e2a:	f3 0f 1e fb          	endbr32
80105e2e:	55                   	push   %ebp
80105e2f:	89 e5                	mov    %esp,%ebp
80105e31:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105e34:	83 ec 04             	sub    $0x4,%esp
80105e37:	6a 08                	push   $0x8
80105e39:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e3c:	50                   	push   %eax
80105e3d:	6a 00                	push   $0x0
80105e3f:	e8 ee f1 ff ff       	call   80105032 <argptr>
80105e44:	83 c4 10             	add    $0x10,%esp
80105e47:	85 c0                	test   %eax,%eax
80105e49:	79 0a                	jns    80105e55 <sys_pipe+0x2b>
    return -1;
80105e4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e50:	e9 ae 00 00 00       	jmp    80105f03 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80105e55:	83 ec 08             	sub    $0x8,%esp
80105e58:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e5b:	50                   	push   %eax
80105e5c:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105e5f:	50                   	push   %eax
80105e60:	e8 75 d8 ff ff       	call   801036da <pipealloc>
80105e65:	83 c4 10             	add    $0x10,%esp
80105e68:	85 c0                	test   %eax,%eax
80105e6a:	79 0a                	jns    80105e76 <sys_pipe+0x4c>
    return -1;
80105e6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e71:	e9 8d 00 00 00       	jmp    80105f03 <sys_pipe+0xd9>
  fd0 = -1;
80105e76:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105e7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e80:	83 ec 0c             	sub    $0xc,%esp
80105e83:	50                   	push   %eax
80105e84:	e8 3b f3 ff ff       	call   801051c4 <fdalloc>
80105e89:	83 c4 10             	add    $0x10,%esp
80105e8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e93:	78 18                	js     80105ead <sys_pipe+0x83>
80105e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e98:	83 ec 0c             	sub    $0xc,%esp
80105e9b:	50                   	push   %eax
80105e9c:	e8 23 f3 ff ff       	call   801051c4 <fdalloc>
80105ea1:	83 c4 10             	add    $0x10,%esp
80105ea4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ea7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105eab:	79 3e                	jns    80105eeb <sys_pipe+0xc1>
    if(fd0 >= 0)
80105ead:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105eb1:	78 13                	js     80105ec6 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80105eb3:	e8 01 dd ff ff       	call   80103bb9 <myproc>
80105eb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ebb:	83 c2 08             	add    $0x8,%edx
80105ebe:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105ec5:	00 
    fileclose(rf);
80105ec6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ec9:	83 ec 0c             	sub    $0xc,%esp
80105ecc:	50                   	push   %eax
80105ecd:	e8 27 b2 ff ff       	call   801010f9 <fileclose>
80105ed2:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105ed5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ed8:	83 ec 0c             	sub    $0xc,%esp
80105edb:	50                   	push   %eax
80105edc:	e8 18 b2 ff ff       	call   801010f9 <fileclose>
80105ee1:	83 c4 10             	add    $0x10,%esp
    return -1;
80105ee4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ee9:	eb 18                	jmp    80105f03 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80105eeb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105eee:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ef1:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105ef3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ef6:	8d 50 04             	lea    0x4(%eax),%edx
80105ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efc:	89 02                	mov    %eax,(%edx)
  return 0;
80105efe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f03:	c9                   	leave
80105f04:	c3                   	ret

80105f05 <sys_printpt>:
#include "mmu.h"
#include "proc.h"

int
sys_printpt(void)
{
80105f05:	f3 0f 1e fb          	endbr32
80105f09:	55                   	push   %ebp
80105f0a:	89 e5                	mov    %esp,%ebp
80105f0c:	83 ec 18             	sub    $0x18,%esp
  int pid;
  if (argint(0, &pid) < 0)
80105f0f:	83 ec 08             	sub    $0x8,%esp
80105f12:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f15:	50                   	push   %eax
80105f16:	6a 00                	push   $0x0
80105f18:	e8 e4 f0 ff ff       	call   80105001 <argint>
80105f1d:	83 c4 10             	add    $0x10,%esp
80105f20:	85 c0                	test   %eax,%eax
80105f22:	79 07                	jns    80105f2b <sys_printpt+0x26>
        return -1;
80105f24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f29:	eb 0f                	jmp    80105f3a <sys_printpt+0x35>
  return printpt(pid);
80105f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2e:	83 ec 0c             	sub    $0xc,%esp
80105f31:	50                   	push   %eax
80105f32:	e8 3d e8 ff ff       	call   80104774 <printpt>
80105f37:	83 c4 10             	add    $0x10,%esp
}
80105f3a:	c9                   	leave
80105f3b:	c3                   	ret

80105f3c <sys_fork>:

int
sys_fork(void)
{
80105f3c:	f3 0f 1e fb          	endbr32
80105f40:	55                   	push   %ebp
80105f41:	89 e5                	mov    %esp,%ebp
80105f43:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105f46:	e8 91 df ff ff       	call   80103edc <fork>
}
80105f4b:	c9                   	leave
80105f4c:	c3                   	ret

80105f4d <sys_exit>:

int
sys_exit(void)
{
80105f4d:	f3 0f 1e fb          	endbr32
80105f51:	55                   	push   %ebp
80105f52:	89 e5                	mov    %esp,%ebp
80105f54:	83 ec 08             	sub    $0x8,%esp
  exit();
80105f57:	e8 fd e0 ff ff       	call   80104059 <exit>
  return 0;  // not reached
80105f5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f61:	c9                   	leave
80105f62:	c3                   	ret

80105f63 <sys_wait>:

int
sys_wait(void)
{
80105f63:	f3 0f 1e fb          	endbr32
80105f67:	55                   	push   %ebp
80105f68:	89 e5                	mov    %esp,%ebp
80105f6a:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105f6d:	e8 0b e2 ff ff       	call   8010417d <wait>
}
80105f72:	c9                   	leave
80105f73:	c3                   	ret

80105f74 <sys_uthread_init>:
int
sys_uthread_init(void)
{
80105f74:	f3 0f 1e fb          	endbr32
80105f78:	55                   	push   %ebp
80105f79:	89 e5                	mov    %esp,%ebp
80105f7b:	83 ec 18             	sub    $0x18,%esp
    // 시스템콜의 인자값을 받아온다.
    int address;
    if (argint(0, &address) < 0)
80105f7e:	83 ec 08             	sub    $0x8,%esp
80105f81:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f84:	50                   	push   %eax
80105f85:	6a 00                	push   $0x0
80105f87:	e8 75 f0 ff ff       	call   80105001 <argint>
80105f8c:	83 c4 10             	add    $0x10,%esp
80105f8f:	85 c0                	test   %eax,%eax
80105f91:	79 07                	jns    80105f9a <sys_uthread_init+0x26>
        return -1;
80105f93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f98:	eb 0f                	jmp    80105fa9 <sys_uthread_init+0x35>
    // proc.c의 uthread_init() 함수 호출
    return uthread_init(address);
80105f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f9d:	83 ec 0c             	sub    $0xc,%esp
80105fa0:	50                   	push   %eax
80105fa1:	e8 b7 e3 ff ff       	call   8010435d <uthread_init>
80105fa6:	83 c4 10             	add    $0x10,%esp
}
80105fa9:	c9                   	leave
80105faa:	c3                   	ret

80105fab <sys_kill>:

int
sys_kill(void)
{
80105fab:	f3 0f 1e fb          	endbr32
80105faf:	55                   	push   %ebp
80105fb0:	89 e5                	mov    %esp,%ebp
80105fb2:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105fb5:	83 ec 08             	sub    $0x8,%esp
80105fb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fbb:	50                   	push   %eax
80105fbc:	6a 00                	push   $0x0
80105fbe:	e8 3e f0 ff ff       	call   80105001 <argint>
80105fc3:	83 c4 10             	add    $0x10,%esp
80105fc6:	85 c0                	test   %eax,%eax
80105fc8:	79 07                	jns    80105fd1 <sys_kill+0x26>
    return -1;
80105fca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fcf:	eb 0f                	jmp    80105fe0 <sys_kill+0x35>
  return kill(pid);
80105fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd4:	83 ec 0c             	sub    $0xc,%esp
80105fd7:	50                   	push   %eax
80105fd8:	e8 11 e6 ff ff       	call   801045ee <kill>
80105fdd:	83 c4 10             	add    $0x10,%esp
}
80105fe0:	c9                   	leave
80105fe1:	c3                   	ret

80105fe2 <sys_getpid>:

int
sys_getpid(void)
{
80105fe2:	f3 0f 1e fb          	endbr32
80105fe6:	55                   	push   %ebp
80105fe7:	89 e5                	mov    %esp,%ebp
80105fe9:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105fec:	e8 c8 db ff ff       	call   80103bb9 <myproc>
80105ff1:	8b 40 10             	mov    0x10(%eax),%eax
}
80105ff4:	c9                   	leave
80105ff5:	c3                   	ret

80105ff6 <sys_sbrk>:

int
sys_sbrk(void)
{
80105ff6:	f3 0f 1e fb          	endbr32
80105ffa:	55                   	push   %ebp
80105ffb:	89 e5                	mov    %esp,%ebp
80105ffd:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;
  struct proc* p = myproc();
80106000:	e8 b4 db ff ff       	call   80103bb9 <myproc>
80106005:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(argint(0, &n) < 0)
80106008:	83 ec 08             	sub    $0x8,%esp
8010600b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010600e:	50                   	push   %eax
8010600f:	6a 00                	push   $0x0
80106011:	e8 eb ef ff ff       	call   80105001 <argint>
80106016:	83 c4 10             	add    $0x10,%esp
80106019:	85 c0                	test   %eax,%eax
8010601b:	79 07                	jns    80106024 <sys_sbrk+0x2e>
    return -1;
8010601d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106022:	eb 6b                	jmp    8010608f <sys_sbrk+0x99>
  // addr = 메모리를 늘리기 전 주소
  addr = p->sz;
80106024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106027:	8b 00                	mov    (%eax),%eax
80106029:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // 메모리를 할당할 때는 lazy allocation을 위해 sz만 올림
  if (n > 0)
8010602c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010602f:	85 c0                	test   %eax,%eax
80106031:	7e 38                	jle    8010606b <sys_sbrk+0x75>
  { 
    if ((p->sz + n) >= KERNBASE){
80106033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106036:	8b 00                	mov    (%eax),%eax
80106038:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010603b:	01 d0                	add    %edx,%eax
8010603d:	85 c0                	test   %eax,%eax
8010603f:	79 19                	jns    8010605a <sys_sbrk+0x64>
      kill(p->pid);
80106041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106044:	8b 40 10             	mov    0x10(%eax),%eax
80106047:	83 ec 0c             	sub    $0xc,%esp
8010604a:	50                   	push   %eax
8010604b:	e8 9e e5 ff ff       	call   801045ee <kill>
80106050:	83 c4 10             	add    $0x10,%esp
      return -1;
80106053:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106058:	eb 35                	jmp    8010608f <sys_sbrk+0x99>
    }
    else
      p->sz += n;
8010605a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010605d:	8b 00                	mov    (%eax),%eax
8010605f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106062:	01 c2                	add    %eax,%edx
80106064:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106067:	89 10                	mov    %edx,(%eax)
80106069:	eb 21                	jmp    8010608c <sys_sbrk+0x96>
  }
  // 메모리 할당을 해제할 때는 바로 해제
  else if (n<0)
8010606b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010606e:	85 c0                	test   %eax,%eax
80106070:	79 1a                	jns    8010608c <sys_sbrk+0x96>
  {
    if(growproc(n) < 0)
80106072:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106075:	83 ec 0c             	sub    $0xc,%esp
80106078:	50                   	push   %eax
80106079:	e8 bf dd ff ff       	call   80103e3d <growproc>
8010607e:	83 c4 10             	add    $0x10,%esp
80106081:	85 c0                	test   %eax,%eax
80106083:	79 07                	jns    8010608c <sys_sbrk+0x96>
      return -1;
80106085:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010608a:	eb 03                	jmp    8010608f <sys_sbrk+0x99>
  }
  
  return addr;
8010608c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010608f:	c9                   	leave
80106090:	c3                   	ret

80106091 <sys_sleep>:

int
sys_sleep(void)
{
80106091:	f3 0f 1e fb          	endbr32
80106095:	55                   	push   %ebp
80106096:	89 e5                	mov    %esp,%ebp
80106098:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010609b:	83 ec 08             	sub    $0x8,%esp
8010609e:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060a1:	50                   	push   %eax
801060a2:	6a 00                	push   $0x0
801060a4:	e8 58 ef ff ff       	call   80105001 <argint>
801060a9:	83 c4 10             	add    $0x10,%esp
801060ac:	85 c0                	test   %eax,%eax
801060ae:	79 07                	jns    801060b7 <sys_sleep+0x26>
    return -1;
801060b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b5:	eb 76                	jmp    8010612d <sys_sleep+0x9c>
  acquire(&tickslock);
801060b7:	83 ec 0c             	sub    $0xc,%esp
801060ba:	68 40 75 19 80       	push   $0x80197540
801060bf:	e8 79 e9 ff ff       	call   80104a3d <acquire>
801060c4:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801060c7:	a1 80 7d 19 80       	mov    0x80197d80,%eax
801060cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801060cf:	eb 38                	jmp    80106109 <sys_sleep+0x78>
    if(myproc()->killed){
801060d1:	e8 e3 da ff ff       	call   80103bb9 <myproc>
801060d6:	8b 40 24             	mov    0x24(%eax),%eax
801060d9:	85 c0                	test   %eax,%eax
801060db:	74 17                	je     801060f4 <sys_sleep+0x63>
      release(&tickslock);
801060dd:	83 ec 0c             	sub    $0xc,%esp
801060e0:	68 40 75 19 80       	push   $0x80197540
801060e5:	e8 c5 e9 ff ff       	call   80104aaf <release>
801060ea:	83 c4 10             	add    $0x10,%esp
      return -1;
801060ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060f2:	eb 39                	jmp    8010612d <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
801060f4:	83 ec 08             	sub    $0x8,%esp
801060f7:	68 40 75 19 80       	push   $0x80197540
801060fc:	68 80 7d 19 80       	push   $0x80197d80
80106101:	e8 be e3 ff ff       	call   801044c4 <sleep>
80106106:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106109:	a1 80 7d 19 80       	mov    0x80197d80,%eax
8010610e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106111:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106114:	39 d0                	cmp    %edx,%eax
80106116:	72 b9                	jb     801060d1 <sys_sleep+0x40>
  }
  release(&tickslock);
80106118:	83 ec 0c             	sub    $0xc,%esp
8010611b:	68 40 75 19 80       	push   $0x80197540
80106120:	e8 8a e9 ff ff       	call   80104aaf <release>
80106125:	83 c4 10             	add    $0x10,%esp
  return 0;
80106128:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010612d:	c9                   	leave
8010612e:	c3                   	ret

8010612f <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010612f:	f3 0f 1e fb          	endbr32
80106133:	55                   	push   %ebp
80106134:	89 e5                	mov    %esp,%ebp
80106136:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106139:	83 ec 0c             	sub    $0xc,%esp
8010613c:	68 40 75 19 80       	push   $0x80197540
80106141:	e8 f7 e8 ff ff       	call   80104a3d <acquire>
80106146:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106149:	a1 80 7d 19 80       	mov    0x80197d80,%eax
8010614e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106151:	83 ec 0c             	sub    $0xc,%esp
80106154:	68 40 75 19 80       	push   $0x80197540
80106159:	e8 51 e9 ff ff       	call   80104aaf <release>
8010615e:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106161:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106164:	c9                   	leave
80106165:	c3                   	ret

80106166 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106166:	1e                   	push   %ds
  pushl %es
80106167:	06                   	push   %es
  pushl %fs
80106168:	0f a0                	push   %fs
  pushl %gs
8010616a:	0f a8                	push   %gs
  pushal
8010616c:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010616d:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106171:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106173:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106175:	54                   	push   %esp
  call trap
80106176:	e8 df 01 00 00       	call   8010635a <trap>
  addl $4, %esp
8010617b:	83 c4 04             	add    $0x4,%esp

8010617e <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010617e:	61                   	popa
  popl %gs
8010617f:	0f a9                	pop    %gs
  popl %fs
80106181:	0f a1                	pop    %fs
  popl %es
80106183:	07                   	pop    %es
  popl %ds
80106184:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106185:	83 c4 08             	add    $0x8,%esp
  iret
80106188:	cf                   	iret

80106189 <lidt>:
{
80106189:	55                   	push   %ebp
8010618a:	89 e5                	mov    %esp,%ebp
8010618c:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010618f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106192:	83 e8 01             	sub    $0x1,%eax
80106195:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106199:	8b 45 08             	mov    0x8(%ebp),%eax
8010619c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801061a0:	8b 45 08             	mov    0x8(%ebp),%eax
801061a3:	c1 e8 10             	shr    $0x10,%eax
801061a6:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801061aa:	8d 45 fa             	lea    -0x6(%ebp),%eax
801061ad:	0f 01 18             	lidtl  (%eax)
}
801061b0:	90                   	nop
801061b1:	c9                   	leave
801061b2:	c3                   	ret

801061b3 <rcr2>:

static inline uint
rcr2(void)
{
801061b3:	55                   	push   %ebp
801061b4:	89 e5                	mov    %esp,%ebp
801061b6:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801061b9:	0f 20 d0             	mov    %cr2,%eax
801061bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801061bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801061c2:	c9                   	leave
801061c3:	c3                   	ret

801061c4 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801061c4:	f3 0f 1e fb          	endbr32
801061c8:	55                   	push   %ebp
801061c9:	89 e5                	mov    %esp,%ebp
801061cb:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801061ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801061d5:	e9 c3 00 00 00       	jmp    8010629d <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801061da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061dd:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801061e4:	89 c2                	mov    %eax,%edx
801061e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e9:	66 89 14 c5 80 75 19 	mov    %dx,-0x7fe68a80(,%eax,8)
801061f0:	80 
801061f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f4:	66 c7 04 c5 82 75 19 	movw   $0x8,-0x7fe68a7e(,%eax,8)
801061fb:	80 08 00 
801061fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106201:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
80106208:	80 
80106209:	83 e2 e0             	and    $0xffffffe0,%edx
8010620c:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
80106213:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106216:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
8010621d:	80 
8010621e:	83 e2 1f             	and    $0x1f,%edx
80106221:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
80106228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622b:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
80106232:	80 
80106233:	83 e2 f0             	and    $0xfffffff0,%edx
80106236:	83 ca 0e             	or     $0xe,%edx
80106239:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
80106240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106243:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
8010624a:	80 
8010624b:	83 e2 ef             	and    $0xffffffef,%edx
8010624e:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
80106255:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106258:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
8010625f:	80 
80106260:	83 e2 9f             	and    $0xffffff9f,%edx
80106263:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
8010626a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010626d:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
80106274:	80 
80106275:	83 ca 80             	or     $0xffffff80,%edx
80106278:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
8010627f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106282:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80106289:	c1 e8 10             	shr    $0x10,%eax
8010628c:	89 c2                	mov    %eax,%edx
8010628e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106291:	66 89 14 c5 86 75 19 	mov    %dx,-0x7fe68a7a(,%eax,8)
80106298:	80 
  for(i = 0; i < 256; i++)
80106299:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010629d:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801062a4:	0f 8e 30 ff ff ff    	jle    801061da <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801062aa:	a1 80 f1 10 80       	mov    0x8010f180,%eax
801062af:	66 a3 80 77 19 80    	mov    %ax,0x80197780
801062b5:	66 c7 05 82 77 19 80 	movw   $0x8,0x80197782
801062bc:	08 00 
801062be:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
801062c5:	83 e0 e0             	and    $0xffffffe0,%eax
801062c8:	a2 84 77 19 80       	mov    %al,0x80197784
801062cd:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
801062d4:	83 e0 1f             	and    $0x1f,%eax
801062d7:	a2 84 77 19 80       	mov    %al,0x80197784
801062dc:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
801062e3:	83 c8 0f             	or     $0xf,%eax
801062e6:	a2 85 77 19 80       	mov    %al,0x80197785
801062eb:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
801062f2:	83 e0 ef             	and    $0xffffffef,%eax
801062f5:	a2 85 77 19 80       	mov    %al,0x80197785
801062fa:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106301:	83 c8 60             	or     $0x60,%eax
80106304:	a2 85 77 19 80       	mov    %al,0x80197785
80106309:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106310:	83 c8 80             	or     $0xffffff80,%eax
80106313:	a2 85 77 19 80       	mov    %al,0x80197785
80106318:	a1 80 f1 10 80       	mov    0x8010f180,%eax
8010631d:	c1 e8 10             	shr    $0x10,%eax
80106320:	66 a3 86 77 19 80    	mov    %ax,0x80197786

  initlock(&tickslock, "time");
80106326:	83 ec 08             	sub    $0x8,%esp
80106329:	68 c8 aa 10 80       	push   $0x8010aac8
8010632e:	68 40 75 19 80       	push   $0x80197540
80106333:	e8 df e6 ff ff       	call   80104a17 <initlock>
80106338:	83 c4 10             	add    $0x10,%esp
}
8010633b:	90                   	nop
8010633c:	c9                   	leave
8010633d:	c3                   	ret

8010633e <idtinit>:

void
idtinit(void)
{
8010633e:	f3 0f 1e fb          	endbr32
80106342:	55                   	push   %ebp
80106343:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106345:	68 00 08 00 00       	push   $0x800
8010634a:	68 80 75 19 80       	push   $0x80197580
8010634f:	e8 35 fe ff ff       	call   80106189 <lidt>
80106354:	83 c4 08             	add    $0x8,%esp
}
80106357:	90                   	nop
80106358:	c9                   	leave
80106359:	c3                   	ret

8010635a <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010635a:	f3 0f 1e fb          	endbr32
8010635e:	55                   	push   %ebp
8010635f:	89 e5                	mov    %esp,%ebp
80106361:	57                   	push   %edi
80106362:	56                   	push   %esi
80106363:	53                   	push   %ebx
80106364:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106367:	8b 45 08             	mov    0x8(%ebp),%eax
8010636a:	8b 40 30             	mov    0x30(%eax),%eax
8010636d:	83 f8 40             	cmp    $0x40,%eax
80106370:	75 3b                	jne    801063ad <trap+0x53>
    if(myproc()->killed)
80106372:	e8 42 d8 ff ff       	call   80103bb9 <myproc>
80106377:	8b 40 24             	mov    0x24(%eax),%eax
8010637a:	85 c0                	test   %eax,%eax
8010637c:	74 05                	je     80106383 <trap+0x29>
      exit();
8010637e:	e8 d6 dc ff ff       	call   80104059 <exit>
    myproc()->tf = tf;
80106383:	e8 31 d8 ff ff       	call   80103bb9 <myproc>
80106388:	8b 55 08             	mov    0x8(%ebp),%edx
8010638b:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010638e:	e8 37 ed ff ff       	call   801050ca <syscall>
    if(myproc()->killed)
80106393:	e8 21 d8 ff ff       	call   80103bb9 <myproc>
80106398:	8b 40 24             	mov    0x24(%eax),%eax
8010639b:	85 c0                	test   %eax,%eax
8010639d:	0f 84 b0 02 00 00    	je     80106653 <trap+0x2f9>
      exit();
801063a3:	e8 b1 dc ff ff       	call   80104059 <exit>
    return;
801063a8:	e9 a6 02 00 00       	jmp    80106653 <trap+0x2f9>
  }

  switch(tf->trapno){
801063ad:	8b 45 08             	mov    0x8(%ebp),%eax
801063b0:	8b 40 30             	mov    0x30(%eax),%eax
801063b3:	83 e8 0e             	sub    $0xe,%eax
801063b6:	83 f8 31             	cmp    $0x31,%eax
801063b9:	0f 87 5f 01 00 00    	ja     8010651e <trap+0x1c4>
801063bf:	8b 04 85 70 ab 10 80 	mov    -0x7fef5490(,%eax,4),%eax
801063c6:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801063c9:	e8 50 d7 ff ff       	call   80103b1e <cpuid>
801063ce:	85 c0                	test   %eax,%eax
801063d0:	75 3d                	jne    8010640f <trap+0xb5>
      acquire(&tickslock);
801063d2:	83 ec 0c             	sub    $0xc,%esp
801063d5:	68 40 75 19 80       	push   $0x80197540
801063da:	e8 5e e6 ff ff       	call   80104a3d <acquire>
801063df:	83 c4 10             	add    $0x10,%esp
      ticks++;
801063e2:	a1 80 7d 19 80       	mov    0x80197d80,%eax
801063e7:	83 c0 01             	add    $0x1,%eax
801063ea:	a3 80 7d 19 80       	mov    %eax,0x80197d80
      wakeup(&ticks);
801063ef:	83 ec 0c             	sub    $0xc,%esp
801063f2:	68 80 7d 19 80       	push   $0x80197d80
801063f7:	e8 b7 e1 ff ff       	call   801045b3 <wakeup>
801063fc:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801063ff:	83 ec 0c             	sub    $0xc,%esp
80106402:	68 40 75 19 80       	push   $0x80197540
80106407:	e8 a3 e6 ff ff       	call   80104aaf <release>
8010640c:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010640f:	e8 21 c8 ff ff       	call   80102c35 <lapiceoi>


    break;
80106414:	e9 ba 01 00 00       	jmp    801065d3 <trap+0x279>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106419:	e8 a0 40 00 00       	call   8010a4be <ideintr>
    lapiceoi();
8010641e:	e8 12 c8 ff ff       	call   80102c35 <lapiceoi>
    break;
80106423:	e9 ab 01 00 00       	jmp    801065d3 <trap+0x279>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106428:	e8 3e c6 ff ff       	call   80102a6b <kbdintr>
    lapiceoi();
8010642d:	e8 03 c8 ff ff       	call   80102c35 <lapiceoi>
    break;
80106432:	e9 9c 01 00 00       	jmp    801065d3 <trap+0x279>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106437:	e8 f9 03 00 00       	call   80106835 <uartintr>
    lapiceoi();
8010643c:	e8 f4 c7 ff ff       	call   80102c35 <lapiceoi>
    break;
80106441:	e9 8d 01 00 00       	jmp    801065d3 <trap+0x279>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106446:	e8 b2 2c 00 00       	call   801090fd <i8254_intr>
    lapiceoi();
8010644b:	e8 e5 c7 ff ff       	call   80102c35 <lapiceoi>
    break;
80106450:	e9 7e 01 00 00       	jmp    801065d3 <trap+0x279>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106455:	8b 45 08             	mov    0x8(%ebp),%eax
80106458:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010645b:	8b 45 08             	mov    0x8(%ebp),%eax
8010645e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106462:	0f b7 d8             	movzwl %ax,%ebx
80106465:	e8 b4 d6 ff ff       	call   80103b1e <cpuid>
8010646a:	56                   	push   %esi
8010646b:	53                   	push   %ebx
8010646c:	50                   	push   %eax
8010646d:	68 d0 aa 10 80       	push   $0x8010aad0
80106472:	e8 95 9f ff ff       	call   8010040c <cprintf>
80106477:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010647a:	e8 b6 c7 ff ff       	call   80102c35 <lapiceoi>
    break;
8010647f:	e9 4f 01 00 00       	jmp    801065d3 <trap+0x279>
  
    // page fault 발생 시 이 블록 실행
  case T_PGFLT:
    if(myproc()->killed)
80106484:	e8 30 d7 ff ff       	call   80103bb9 <myproc>
80106489:	8b 40 24             	mov    0x24(%eax),%eax
8010648c:	85 c0                	test   %eax,%eax
8010648e:	74 05                	je     80106495 <trap+0x13b>
      exit();
80106490:	e8 c4 db ff ff       	call   80104059 <exit>
    pde_t* pgdir;
    uint va;
    struct proc* p;
    char *mem;
    p = myproc();
80106495:	e8 1f d7 ff ff       	call   80103bb9 <myproc>
8010649a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // va = 페이지 폴트가 난 가상 주소의 페이지 시작 주소
    va = PGROUNDDOWN(rcr2());
8010649d:	e8 11 fd ff ff       	call   801061b3 <rcr2>
801064a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801064a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    
    pgdir = p->pgdir;
801064aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064ad:	8b 40 04             	mov    0x4(%eax),%eax
801064b0:	89 45 dc             	mov    %eax,-0x24(%ebp)

    // 새 페이지를 할당할 물리 주소 할당
    if ((mem = kalloc()) == 0)
801064b3:	e8 ea c3 ff ff       	call   801028a2 <kalloc>
801064b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
801064bb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801064bf:	75 12                	jne    801064d3 <trap+0x179>
      kill(p->pid);
801064c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064c4:	8b 40 10             	mov    0x10(%eax),%eax
801064c7:	83 ec 0c             	sub    $0xc,%esp
801064ca:	50                   	push   %eax
801064cb:	e8 1e e1 ff ff       	call   801045ee <kill>
801064d0:	83 c4 10             	add    $0x10,%esp
    
    memset(mem, 0, PGSIZE);
801064d3:	83 ec 04             	sub    $0x4,%esp
801064d6:	68 00 10 00 00       	push   $0x1000
801064db:	6a 00                	push   $0x0
801064dd:	ff 75 d8             	push   -0x28(%ebp)
801064e0:	e8 e7 e7 ff ff       	call   80104ccc <memset>
801064e5:	83 c4 10             	add    $0x10,%esp

    // va 페이지 테이블에 매핑
    // 페이지 테이블 관련 처리는 mappages 안에서 자동으로 처리해줌
    mappages(pgdir, (void*)va, PGSIZE, V2P(mem), PTE_W|PTE_U|PTE_P);
801064e8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801064eb:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801064f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801064f4:	83 ec 0c             	sub    $0xc,%esp
801064f7:	6a 07                	push   $0x7
801064f9:	52                   	push   %edx
801064fa:	68 00 10 00 00       	push   $0x1000
801064ff:	50                   	push   %eax
80106500:	ff 75 dc             	push   -0x24(%ebp)
80106503:	e8 fd 11 00 00       	call   80107705 <mappages>
80106508:	83 c4 20             	add    $0x20,%esp

    // flush
    switchuvm(p);
8010650b:	83 ec 0c             	sub    $0xc,%esp
8010650e:	ff 75 e4             	push   -0x1c(%ebp)
80106511:	e8 ad 13 00 00       	call   801078c3 <switchuvm>
80106516:	83 c4 10             	add    $0x10,%esp
    break;
80106519:	e9 b5 00 00 00       	jmp    801065d3 <trap+0x279>


  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010651e:	e8 96 d6 ff ff       	call   80103bb9 <myproc>
80106523:	85 c0                	test   %eax,%eax
80106525:	74 11                	je     80106538 <trap+0x1de>
80106527:	8b 45 08             	mov    0x8(%ebp),%eax
8010652a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010652e:	0f b7 c0             	movzwl %ax,%eax
80106531:	83 e0 03             	and    $0x3,%eax
80106534:	85 c0                	test   %eax,%eax
80106536:	75 39                	jne    80106571 <trap+0x217>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106538:	e8 76 fc ff ff       	call   801061b3 <rcr2>
8010653d:	89 c3                	mov    %eax,%ebx
8010653f:	8b 45 08             	mov    0x8(%ebp),%eax
80106542:	8b 70 38             	mov    0x38(%eax),%esi
80106545:	e8 d4 d5 ff ff       	call   80103b1e <cpuid>
8010654a:	8b 55 08             	mov    0x8(%ebp),%edx
8010654d:	8b 52 30             	mov    0x30(%edx),%edx
80106550:	83 ec 0c             	sub    $0xc,%esp
80106553:	53                   	push   %ebx
80106554:	56                   	push   %esi
80106555:	50                   	push   %eax
80106556:	52                   	push   %edx
80106557:	68 f4 aa 10 80       	push   $0x8010aaf4
8010655c:	e8 ab 9e ff ff       	call   8010040c <cprintf>
80106561:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106564:	83 ec 0c             	sub    $0xc,%esp
80106567:	68 26 ab 10 80       	push   $0x8010ab26
8010656c:	e8 6d a0 ff ff       	call   801005de <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106571:	e8 3d fc ff ff       	call   801061b3 <rcr2>
80106576:	89 c6                	mov    %eax,%esi
80106578:	8b 45 08             	mov    0x8(%ebp),%eax
8010657b:	8b 40 38             	mov    0x38(%eax),%eax
8010657e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106581:	e8 98 d5 ff ff       	call   80103b1e <cpuid>
80106586:	89 c3                	mov    %eax,%ebx
80106588:	8b 45 08             	mov    0x8(%ebp),%eax
8010658b:	8b 48 34             	mov    0x34(%eax),%ecx
8010658e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106591:	8b 45 08             	mov    0x8(%ebp),%eax
80106594:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106597:	e8 1d d6 ff ff       	call   80103bb9 <myproc>
8010659c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010659f:	89 55 cc             	mov    %edx,-0x34(%ebp)
801065a2:	e8 12 d6 ff ff       	call   80103bb9 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065a7:	8b 40 10             	mov    0x10(%eax),%eax
801065aa:	56                   	push   %esi
801065ab:	ff 75 d4             	push   -0x2c(%ebp)
801065ae:	53                   	push   %ebx
801065af:	ff 75 d0             	push   -0x30(%ebp)
801065b2:	57                   	push   %edi
801065b3:	ff 75 cc             	push   -0x34(%ebp)
801065b6:	50                   	push   %eax
801065b7:	68 2c ab 10 80       	push   $0x8010ab2c
801065bc:	e8 4b 9e ff ff       	call   8010040c <cprintf>
801065c1:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801065c4:	e8 f0 d5 ff ff       	call   80103bb9 <myproc>
801065c9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801065d0:	eb 01                	jmp    801065d3 <trap+0x279>
    break;
801065d2:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801065d3:	e8 e1 d5 ff ff       	call   80103bb9 <myproc>
801065d8:	85 c0                	test   %eax,%eax
801065da:	74 23                	je     801065ff <trap+0x2a5>
801065dc:	e8 d8 d5 ff ff       	call   80103bb9 <myproc>
801065e1:	8b 40 24             	mov    0x24(%eax),%eax
801065e4:	85 c0                	test   %eax,%eax
801065e6:	74 17                	je     801065ff <trap+0x2a5>
801065e8:	8b 45 08             	mov    0x8(%ebp),%eax
801065eb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801065ef:	0f b7 c0             	movzwl %ax,%eax
801065f2:	83 e0 03             	and    $0x3,%eax
801065f5:	83 f8 03             	cmp    $0x3,%eax
801065f8:	75 05                	jne    801065ff <trap+0x2a5>
    exit();
801065fa:	e8 5a da ff ff       	call   80104059 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801065ff:	e8 b5 d5 ff ff       	call   80103bb9 <myproc>
80106604:	85 c0                	test   %eax,%eax
80106606:	74 1d                	je     80106625 <trap+0x2cb>
80106608:	e8 ac d5 ff ff       	call   80103bb9 <myproc>
8010660d:	8b 40 0c             	mov    0xc(%eax),%eax
80106610:	83 f8 04             	cmp    $0x4,%eax
80106613:	75 10                	jne    80106625 <trap+0x2cb>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106615:	8b 45 08             	mov    0x8(%ebp),%eax
80106618:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
8010661b:	83 f8 20             	cmp    $0x20,%eax
8010661e:	75 05                	jne    80106625 <trap+0x2cb>
    yield();
80106620:	e8 17 de ff ff       	call   8010443c <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106625:	e8 8f d5 ff ff       	call   80103bb9 <myproc>
8010662a:	85 c0                	test   %eax,%eax
8010662c:	74 26                	je     80106654 <trap+0x2fa>
8010662e:	e8 86 d5 ff ff       	call   80103bb9 <myproc>
80106633:	8b 40 24             	mov    0x24(%eax),%eax
80106636:	85 c0                	test   %eax,%eax
80106638:	74 1a                	je     80106654 <trap+0x2fa>
8010663a:	8b 45 08             	mov    0x8(%ebp),%eax
8010663d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106641:	0f b7 c0             	movzwl %ax,%eax
80106644:	83 e0 03             	and    $0x3,%eax
80106647:	83 f8 03             	cmp    $0x3,%eax
8010664a:	75 08                	jne    80106654 <trap+0x2fa>
    exit();
8010664c:	e8 08 da ff ff       	call   80104059 <exit>
80106651:	eb 01                	jmp    80106654 <trap+0x2fa>
    return;
80106653:	90                   	nop
}
80106654:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106657:	5b                   	pop    %ebx
80106658:	5e                   	pop    %esi
80106659:	5f                   	pop    %edi
8010665a:	5d                   	pop    %ebp
8010665b:	c3                   	ret

8010665c <inb>:
{
8010665c:	55                   	push   %ebp
8010665d:	89 e5                	mov    %esp,%ebp
8010665f:	83 ec 14             	sub    $0x14,%esp
80106662:	8b 45 08             	mov    0x8(%ebp),%eax
80106665:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106669:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010666d:	89 c2                	mov    %eax,%edx
8010666f:	ec                   	in     (%dx),%al
80106670:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106673:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106677:	c9                   	leave
80106678:	c3                   	ret

80106679 <outb>:
{
80106679:	55                   	push   %ebp
8010667a:	89 e5                	mov    %esp,%ebp
8010667c:	83 ec 08             	sub    $0x8,%esp
8010667f:	8b 45 08             	mov    0x8(%ebp),%eax
80106682:	8b 55 0c             	mov    0xc(%ebp),%edx
80106685:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106689:	89 d0                	mov    %edx,%eax
8010668b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010668e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106692:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106696:	ee                   	out    %al,(%dx)
}
80106697:	90                   	nop
80106698:	c9                   	leave
80106699:	c3                   	ret

8010669a <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010669a:	f3 0f 1e fb          	endbr32
8010669e:	55                   	push   %ebp
8010669f:	89 e5                	mov    %esp,%ebp
801066a1:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801066a4:	6a 00                	push   $0x0
801066a6:	68 fa 03 00 00       	push   $0x3fa
801066ab:	e8 c9 ff ff ff       	call   80106679 <outb>
801066b0:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801066b3:	68 80 00 00 00       	push   $0x80
801066b8:	68 fb 03 00 00       	push   $0x3fb
801066bd:	e8 b7 ff ff ff       	call   80106679 <outb>
801066c2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801066c5:	6a 0c                	push   $0xc
801066c7:	68 f8 03 00 00       	push   $0x3f8
801066cc:	e8 a8 ff ff ff       	call   80106679 <outb>
801066d1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801066d4:	6a 00                	push   $0x0
801066d6:	68 f9 03 00 00       	push   $0x3f9
801066db:	e8 99 ff ff ff       	call   80106679 <outb>
801066e0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801066e3:	6a 03                	push   $0x3
801066e5:	68 fb 03 00 00       	push   $0x3fb
801066ea:	e8 8a ff ff ff       	call   80106679 <outb>
801066ef:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801066f2:	6a 00                	push   $0x0
801066f4:	68 fc 03 00 00       	push   $0x3fc
801066f9:	e8 7b ff ff ff       	call   80106679 <outb>
801066fe:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106701:	6a 01                	push   $0x1
80106703:	68 f9 03 00 00       	push   $0x3f9
80106708:	e8 6c ff ff ff       	call   80106679 <outb>
8010670d:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106710:	68 fd 03 00 00       	push   $0x3fd
80106715:	e8 42 ff ff ff       	call   8010665c <inb>
8010671a:	83 c4 04             	add    $0x4,%esp
8010671d:	3c ff                	cmp    $0xff,%al
8010671f:	74 61                	je     80106782 <uartinit+0xe8>
    return;
  uart = 1;
80106721:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
80106728:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010672b:	68 fa 03 00 00       	push   $0x3fa
80106730:	e8 27 ff ff ff       	call   8010665c <inb>
80106735:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106738:	68 f8 03 00 00       	push   $0x3f8
8010673d:	e8 1a ff ff ff       	call   8010665c <inb>
80106742:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106745:	83 ec 08             	sub    $0x8,%esp
80106748:	6a 00                	push   $0x0
8010674a:	6a 04                	push   $0x4
8010674c:	e8 cb bf ff ff       	call   8010271c <ioapicenable>
80106751:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106754:	c7 45 f4 38 ac 10 80 	movl   $0x8010ac38,-0xc(%ebp)
8010675b:	eb 19                	jmp    80106776 <uartinit+0xdc>
    uartputc(*p);
8010675d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106760:	0f b6 00             	movzbl (%eax),%eax
80106763:	0f be c0             	movsbl %al,%eax
80106766:	83 ec 0c             	sub    $0xc,%esp
80106769:	50                   	push   %eax
8010676a:	e8 16 00 00 00       	call   80106785 <uartputc>
8010676f:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106772:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106779:	0f b6 00             	movzbl (%eax),%eax
8010677c:	84 c0                	test   %al,%al
8010677e:	75 dd                	jne    8010675d <uartinit+0xc3>
80106780:	eb 01                	jmp    80106783 <uartinit+0xe9>
    return;
80106782:	90                   	nop
}
80106783:	c9                   	leave
80106784:	c3                   	ret

80106785 <uartputc>:

void
uartputc(int c)
{
80106785:	f3 0f 1e fb          	endbr32
80106789:	55                   	push   %ebp
8010678a:	89 e5                	mov    %esp,%ebp
8010678c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010678f:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106794:	85 c0                	test   %eax,%eax
80106796:	74 53                	je     801067eb <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106798:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010679f:	eb 11                	jmp    801067b2 <uartputc+0x2d>
    microdelay(10);
801067a1:	83 ec 0c             	sub    $0xc,%esp
801067a4:	6a 0a                	push   $0xa
801067a6:	e8 a9 c4 ff ff       	call   80102c54 <microdelay>
801067ab:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067b2:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801067b6:	7f 1a                	jg     801067d2 <uartputc+0x4d>
801067b8:	83 ec 0c             	sub    $0xc,%esp
801067bb:	68 fd 03 00 00       	push   $0x3fd
801067c0:	e8 97 fe ff ff       	call   8010665c <inb>
801067c5:	83 c4 10             	add    $0x10,%esp
801067c8:	0f b6 c0             	movzbl %al,%eax
801067cb:	83 e0 20             	and    $0x20,%eax
801067ce:	85 c0                	test   %eax,%eax
801067d0:	74 cf                	je     801067a1 <uartputc+0x1c>
  outb(COM1+0, c);
801067d2:	8b 45 08             	mov    0x8(%ebp),%eax
801067d5:	0f b6 c0             	movzbl %al,%eax
801067d8:	83 ec 08             	sub    $0x8,%esp
801067db:	50                   	push   %eax
801067dc:	68 f8 03 00 00       	push   $0x3f8
801067e1:	e8 93 fe ff ff       	call   80106679 <outb>
801067e6:	83 c4 10             	add    $0x10,%esp
801067e9:	eb 01                	jmp    801067ec <uartputc+0x67>
    return;
801067eb:	90                   	nop
}
801067ec:	c9                   	leave
801067ed:	c3                   	ret

801067ee <uartgetc>:

static int
uartgetc(void)
{
801067ee:	f3 0f 1e fb          	endbr32
801067f2:	55                   	push   %ebp
801067f3:	89 e5                	mov    %esp,%ebp
  if(!uart)
801067f5:	a1 60 d0 18 80       	mov    0x8018d060,%eax
801067fa:	85 c0                	test   %eax,%eax
801067fc:	75 07                	jne    80106805 <uartgetc+0x17>
    return -1;
801067fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106803:	eb 2e                	jmp    80106833 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80106805:	68 fd 03 00 00       	push   $0x3fd
8010680a:	e8 4d fe ff ff       	call   8010665c <inb>
8010680f:	83 c4 04             	add    $0x4,%esp
80106812:	0f b6 c0             	movzbl %al,%eax
80106815:	83 e0 01             	and    $0x1,%eax
80106818:	85 c0                	test   %eax,%eax
8010681a:	75 07                	jne    80106823 <uartgetc+0x35>
    return -1;
8010681c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106821:	eb 10                	jmp    80106833 <uartgetc+0x45>
  return inb(COM1+0);
80106823:	68 f8 03 00 00       	push   $0x3f8
80106828:	e8 2f fe ff ff       	call   8010665c <inb>
8010682d:	83 c4 04             	add    $0x4,%esp
80106830:	0f b6 c0             	movzbl %al,%eax
}
80106833:	c9                   	leave
80106834:	c3                   	ret

80106835 <uartintr>:

void
uartintr(void)
{
80106835:	f3 0f 1e fb          	endbr32
80106839:	55                   	push   %ebp
8010683a:	89 e5                	mov    %esp,%ebp
8010683c:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010683f:	83 ec 0c             	sub    $0xc,%esp
80106842:	68 ee 67 10 80       	push   $0x801067ee
80106847:	e8 cd 9f ff ff       	call   80100819 <consoleintr>
8010684c:	83 c4 10             	add    $0x10,%esp
}
8010684f:	90                   	nop
80106850:	c9                   	leave
80106851:	c3                   	ret

80106852 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106852:	6a 00                	push   $0x0
  pushl $0
80106854:	6a 00                	push   $0x0
  jmp alltraps
80106856:	e9 0b f9 ff ff       	jmp    80106166 <alltraps>

8010685b <vector1>:
.globl vector1
vector1:
  pushl $0
8010685b:	6a 00                	push   $0x0
  pushl $1
8010685d:	6a 01                	push   $0x1
  jmp alltraps
8010685f:	e9 02 f9 ff ff       	jmp    80106166 <alltraps>

80106864 <vector2>:
.globl vector2
vector2:
  pushl $0
80106864:	6a 00                	push   $0x0
  pushl $2
80106866:	6a 02                	push   $0x2
  jmp alltraps
80106868:	e9 f9 f8 ff ff       	jmp    80106166 <alltraps>

8010686d <vector3>:
.globl vector3
vector3:
  pushl $0
8010686d:	6a 00                	push   $0x0
  pushl $3
8010686f:	6a 03                	push   $0x3
  jmp alltraps
80106871:	e9 f0 f8 ff ff       	jmp    80106166 <alltraps>

80106876 <vector4>:
.globl vector4
vector4:
  pushl $0
80106876:	6a 00                	push   $0x0
  pushl $4
80106878:	6a 04                	push   $0x4
  jmp alltraps
8010687a:	e9 e7 f8 ff ff       	jmp    80106166 <alltraps>

8010687f <vector5>:
.globl vector5
vector5:
  pushl $0
8010687f:	6a 00                	push   $0x0
  pushl $5
80106881:	6a 05                	push   $0x5
  jmp alltraps
80106883:	e9 de f8 ff ff       	jmp    80106166 <alltraps>

80106888 <vector6>:
.globl vector6
vector6:
  pushl $0
80106888:	6a 00                	push   $0x0
  pushl $6
8010688a:	6a 06                	push   $0x6
  jmp alltraps
8010688c:	e9 d5 f8 ff ff       	jmp    80106166 <alltraps>

80106891 <vector7>:
.globl vector7
vector7:
  pushl $0
80106891:	6a 00                	push   $0x0
  pushl $7
80106893:	6a 07                	push   $0x7
  jmp alltraps
80106895:	e9 cc f8 ff ff       	jmp    80106166 <alltraps>

8010689a <vector8>:
.globl vector8
vector8:
  pushl $8
8010689a:	6a 08                	push   $0x8
  jmp alltraps
8010689c:	e9 c5 f8 ff ff       	jmp    80106166 <alltraps>

801068a1 <vector9>:
.globl vector9
vector9:
  pushl $0
801068a1:	6a 00                	push   $0x0
  pushl $9
801068a3:	6a 09                	push   $0x9
  jmp alltraps
801068a5:	e9 bc f8 ff ff       	jmp    80106166 <alltraps>

801068aa <vector10>:
.globl vector10
vector10:
  pushl $10
801068aa:	6a 0a                	push   $0xa
  jmp alltraps
801068ac:	e9 b5 f8 ff ff       	jmp    80106166 <alltraps>

801068b1 <vector11>:
.globl vector11
vector11:
  pushl $11
801068b1:	6a 0b                	push   $0xb
  jmp alltraps
801068b3:	e9 ae f8 ff ff       	jmp    80106166 <alltraps>

801068b8 <vector12>:
.globl vector12
vector12:
  pushl $12
801068b8:	6a 0c                	push   $0xc
  jmp alltraps
801068ba:	e9 a7 f8 ff ff       	jmp    80106166 <alltraps>

801068bf <vector13>:
.globl vector13
vector13:
  pushl $13
801068bf:	6a 0d                	push   $0xd
  jmp alltraps
801068c1:	e9 a0 f8 ff ff       	jmp    80106166 <alltraps>

801068c6 <vector14>:
.globl vector14
vector14:
  pushl $14
801068c6:	6a 0e                	push   $0xe
  jmp alltraps
801068c8:	e9 99 f8 ff ff       	jmp    80106166 <alltraps>

801068cd <vector15>:
.globl vector15
vector15:
  pushl $0
801068cd:	6a 00                	push   $0x0
  pushl $15
801068cf:	6a 0f                	push   $0xf
  jmp alltraps
801068d1:	e9 90 f8 ff ff       	jmp    80106166 <alltraps>

801068d6 <vector16>:
.globl vector16
vector16:
  pushl $0
801068d6:	6a 00                	push   $0x0
  pushl $16
801068d8:	6a 10                	push   $0x10
  jmp alltraps
801068da:	e9 87 f8 ff ff       	jmp    80106166 <alltraps>

801068df <vector17>:
.globl vector17
vector17:
  pushl $17
801068df:	6a 11                	push   $0x11
  jmp alltraps
801068e1:	e9 80 f8 ff ff       	jmp    80106166 <alltraps>

801068e6 <vector18>:
.globl vector18
vector18:
  pushl $0
801068e6:	6a 00                	push   $0x0
  pushl $18
801068e8:	6a 12                	push   $0x12
  jmp alltraps
801068ea:	e9 77 f8 ff ff       	jmp    80106166 <alltraps>

801068ef <vector19>:
.globl vector19
vector19:
  pushl $0
801068ef:	6a 00                	push   $0x0
  pushl $19
801068f1:	6a 13                	push   $0x13
  jmp alltraps
801068f3:	e9 6e f8 ff ff       	jmp    80106166 <alltraps>

801068f8 <vector20>:
.globl vector20
vector20:
  pushl $0
801068f8:	6a 00                	push   $0x0
  pushl $20
801068fa:	6a 14                	push   $0x14
  jmp alltraps
801068fc:	e9 65 f8 ff ff       	jmp    80106166 <alltraps>

80106901 <vector21>:
.globl vector21
vector21:
  pushl $0
80106901:	6a 00                	push   $0x0
  pushl $21
80106903:	6a 15                	push   $0x15
  jmp alltraps
80106905:	e9 5c f8 ff ff       	jmp    80106166 <alltraps>

8010690a <vector22>:
.globl vector22
vector22:
  pushl $0
8010690a:	6a 00                	push   $0x0
  pushl $22
8010690c:	6a 16                	push   $0x16
  jmp alltraps
8010690e:	e9 53 f8 ff ff       	jmp    80106166 <alltraps>

80106913 <vector23>:
.globl vector23
vector23:
  pushl $0
80106913:	6a 00                	push   $0x0
  pushl $23
80106915:	6a 17                	push   $0x17
  jmp alltraps
80106917:	e9 4a f8 ff ff       	jmp    80106166 <alltraps>

8010691c <vector24>:
.globl vector24
vector24:
  pushl $0
8010691c:	6a 00                	push   $0x0
  pushl $24
8010691e:	6a 18                	push   $0x18
  jmp alltraps
80106920:	e9 41 f8 ff ff       	jmp    80106166 <alltraps>

80106925 <vector25>:
.globl vector25
vector25:
  pushl $0
80106925:	6a 00                	push   $0x0
  pushl $25
80106927:	6a 19                	push   $0x19
  jmp alltraps
80106929:	e9 38 f8 ff ff       	jmp    80106166 <alltraps>

8010692e <vector26>:
.globl vector26
vector26:
  pushl $0
8010692e:	6a 00                	push   $0x0
  pushl $26
80106930:	6a 1a                	push   $0x1a
  jmp alltraps
80106932:	e9 2f f8 ff ff       	jmp    80106166 <alltraps>

80106937 <vector27>:
.globl vector27
vector27:
  pushl $0
80106937:	6a 00                	push   $0x0
  pushl $27
80106939:	6a 1b                	push   $0x1b
  jmp alltraps
8010693b:	e9 26 f8 ff ff       	jmp    80106166 <alltraps>

80106940 <vector28>:
.globl vector28
vector28:
  pushl $0
80106940:	6a 00                	push   $0x0
  pushl $28
80106942:	6a 1c                	push   $0x1c
  jmp alltraps
80106944:	e9 1d f8 ff ff       	jmp    80106166 <alltraps>

80106949 <vector29>:
.globl vector29
vector29:
  pushl $0
80106949:	6a 00                	push   $0x0
  pushl $29
8010694b:	6a 1d                	push   $0x1d
  jmp alltraps
8010694d:	e9 14 f8 ff ff       	jmp    80106166 <alltraps>

80106952 <vector30>:
.globl vector30
vector30:
  pushl $0
80106952:	6a 00                	push   $0x0
  pushl $30
80106954:	6a 1e                	push   $0x1e
  jmp alltraps
80106956:	e9 0b f8 ff ff       	jmp    80106166 <alltraps>

8010695b <vector31>:
.globl vector31
vector31:
  pushl $0
8010695b:	6a 00                	push   $0x0
  pushl $31
8010695d:	6a 1f                	push   $0x1f
  jmp alltraps
8010695f:	e9 02 f8 ff ff       	jmp    80106166 <alltraps>

80106964 <vector32>:
.globl vector32
vector32:
  pushl $0
80106964:	6a 00                	push   $0x0
  pushl $32
80106966:	6a 20                	push   $0x20
  jmp alltraps
80106968:	e9 f9 f7 ff ff       	jmp    80106166 <alltraps>

8010696d <vector33>:
.globl vector33
vector33:
  pushl $0
8010696d:	6a 00                	push   $0x0
  pushl $33
8010696f:	6a 21                	push   $0x21
  jmp alltraps
80106971:	e9 f0 f7 ff ff       	jmp    80106166 <alltraps>

80106976 <vector34>:
.globl vector34
vector34:
  pushl $0
80106976:	6a 00                	push   $0x0
  pushl $34
80106978:	6a 22                	push   $0x22
  jmp alltraps
8010697a:	e9 e7 f7 ff ff       	jmp    80106166 <alltraps>

8010697f <vector35>:
.globl vector35
vector35:
  pushl $0
8010697f:	6a 00                	push   $0x0
  pushl $35
80106981:	6a 23                	push   $0x23
  jmp alltraps
80106983:	e9 de f7 ff ff       	jmp    80106166 <alltraps>

80106988 <vector36>:
.globl vector36
vector36:
  pushl $0
80106988:	6a 00                	push   $0x0
  pushl $36
8010698a:	6a 24                	push   $0x24
  jmp alltraps
8010698c:	e9 d5 f7 ff ff       	jmp    80106166 <alltraps>

80106991 <vector37>:
.globl vector37
vector37:
  pushl $0
80106991:	6a 00                	push   $0x0
  pushl $37
80106993:	6a 25                	push   $0x25
  jmp alltraps
80106995:	e9 cc f7 ff ff       	jmp    80106166 <alltraps>

8010699a <vector38>:
.globl vector38
vector38:
  pushl $0
8010699a:	6a 00                	push   $0x0
  pushl $38
8010699c:	6a 26                	push   $0x26
  jmp alltraps
8010699e:	e9 c3 f7 ff ff       	jmp    80106166 <alltraps>

801069a3 <vector39>:
.globl vector39
vector39:
  pushl $0
801069a3:	6a 00                	push   $0x0
  pushl $39
801069a5:	6a 27                	push   $0x27
  jmp alltraps
801069a7:	e9 ba f7 ff ff       	jmp    80106166 <alltraps>

801069ac <vector40>:
.globl vector40
vector40:
  pushl $0
801069ac:	6a 00                	push   $0x0
  pushl $40
801069ae:	6a 28                	push   $0x28
  jmp alltraps
801069b0:	e9 b1 f7 ff ff       	jmp    80106166 <alltraps>

801069b5 <vector41>:
.globl vector41
vector41:
  pushl $0
801069b5:	6a 00                	push   $0x0
  pushl $41
801069b7:	6a 29                	push   $0x29
  jmp alltraps
801069b9:	e9 a8 f7 ff ff       	jmp    80106166 <alltraps>

801069be <vector42>:
.globl vector42
vector42:
  pushl $0
801069be:	6a 00                	push   $0x0
  pushl $42
801069c0:	6a 2a                	push   $0x2a
  jmp alltraps
801069c2:	e9 9f f7 ff ff       	jmp    80106166 <alltraps>

801069c7 <vector43>:
.globl vector43
vector43:
  pushl $0
801069c7:	6a 00                	push   $0x0
  pushl $43
801069c9:	6a 2b                	push   $0x2b
  jmp alltraps
801069cb:	e9 96 f7 ff ff       	jmp    80106166 <alltraps>

801069d0 <vector44>:
.globl vector44
vector44:
  pushl $0
801069d0:	6a 00                	push   $0x0
  pushl $44
801069d2:	6a 2c                	push   $0x2c
  jmp alltraps
801069d4:	e9 8d f7 ff ff       	jmp    80106166 <alltraps>

801069d9 <vector45>:
.globl vector45
vector45:
  pushl $0
801069d9:	6a 00                	push   $0x0
  pushl $45
801069db:	6a 2d                	push   $0x2d
  jmp alltraps
801069dd:	e9 84 f7 ff ff       	jmp    80106166 <alltraps>

801069e2 <vector46>:
.globl vector46
vector46:
  pushl $0
801069e2:	6a 00                	push   $0x0
  pushl $46
801069e4:	6a 2e                	push   $0x2e
  jmp alltraps
801069e6:	e9 7b f7 ff ff       	jmp    80106166 <alltraps>

801069eb <vector47>:
.globl vector47
vector47:
  pushl $0
801069eb:	6a 00                	push   $0x0
  pushl $47
801069ed:	6a 2f                	push   $0x2f
  jmp alltraps
801069ef:	e9 72 f7 ff ff       	jmp    80106166 <alltraps>

801069f4 <vector48>:
.globl vector48
vector48:
  pushl $0
801069f4:	6a 00                	push   $0x0
  pushl $48
801069f6:	6a 30                	push   $0x30
  jmp alltraps
801069f8:	e9 69 f7 ff ff       	jmp    80106166 <alltraps>

801069fd <vector49>:
.globl vector49
vector49:
  pushl $0
801069fd:	6a 00                	push   $0x0
  pushl $49
801069ff:	6a 31                	push   $0x31
  jmp alltraps
80106a01:	e9 60 f7 ff ff       	jmp    80106166 <alltraps>

80106a06 <vector50>:
.globl vector50
vector50:
  pushl $0
80106a06:	6a 00                	push   $0x0
  pushl $50
80106a08:	6a 32                	push   $0x32
  jmp alltraps
80106a0a:	e9 57 f7 ff ff       	jmp    80106166 <alltraps>

80106a0f <vector51>:
.globl vector51
vector51:
  pushl $0
80106a0f:	6a 00                	push   $0x0
  pushl $51
80106a11:	6a 33                	push   $0x33
  jmp alltraps
80106a13:	e9 4e f7 ff ff       	jmp    80106166 <alltraps>

80106a18 <vector52>:
.globl vector52
vector52:
  pushl $0
80106a18:	6a 00                	push   $0x0
  pushl $52
80106a1a:	6a 34                	push   $0x34
  jmp alltraps
80106a1c:	e9 45 f7 ff ff       	jmp    80106166 <alltraps>

80106a21 <vector53>:
.globl vector53
vector53:
  pushl $0
80106a21:	6a 00                	push   $0x0
  pushl $53
80106a23:	6a 35                	push   $0x35
  jmp alltraps
80106a25:	e9 3c f7 ff ff       	jmp    80106166 <alltraps>

80106a2a <vector54>:
.globl vector54
vector54:
  pushl $0
80106a2a:	6a 00                	push   $0x0
  pushl $54
80106a2c:	6a 36                	push   $0x36
  jmp alltraps
80106a2e:	e9 33 f7 ff ff       	jmp    80106166 <alltraps>

80106a33 <vector55>:
.globl vector55
vector55:
  pushl $0
80106a33:	6a 00                	push   $0x0
  pushl $55
80106a35:	6a 37                	push   $0x37
  jmp alltraps
80106a37:	e9 2a f7 ff ff       	jmp    80106166 <alltraps>

80106a3c <vector56>:
.globl vector56
vector56:
  pushl $0
80106a3c:	6a 00                	push   $0x0
  pushl $56
80106a3e:	6a 38                	push   $0x38
  jmp alltraps
80106a40:	e9 21 f7 ff ff       	jmp    80106166 <alltraps>

80106a45 <vector57>:
.globl vector57
vector57:
  pushl $0
80106a45:	6a 00                	push   $0x0
  pushl $57
80106a47:	6a 39                	push   $0x39
  jmp alltraps
80106a49:	e9 18 f7 ff ff       	jmp    80106166 <alltraps>

80106a4e <vector58>:
.globl vector58
vector58:
  pushl $0
80106a4e:	6a 00                	push   $0x0
  pushl $58
80106a50:	6a 3a                	push   $0x3a
  jmp alltraps
80106a52:	e9 0f f7 ff ff       	jmp    80106166 <alltraps>

80106a57 <vector59>:
.globl vector59
vector59:
  pushl $0
80106a57:	6a 00                	push   $0x0
  pushl $59
80106a59:	6a 3b                	push   $0x3b
  jmp alltraps
80106a5b:	e9 06 f7 ff ff       	jmp    80106166 <alltraps>

80106a60 <vector60>:
.globl vector60
vector60:
  pushl $0
80106a60:	6a 00                	push   $0x0
  pushl $60
80106a62:	6a 3c                	push   $0x3c
  jmp alltraps
80106a64:	e9 fd f6 ff ff       	jmp    80106166 <alltraps>

80106a69 <vector61>:
.globl vector61
vector61:
  pushl $0
80106a69:	6a 00                	push   $0x0
  pushl $61
80106a6b:	6a 3d                	push   $0x3d
  jmp alltraps
80106a6d:	e9 f4 f6 ff ff       	jmp    80106166 <alltraps>

80106a72 <vector62>:
.globl vector62
vector62:
  pushl $0
80106a72:	6a 00                	push   $0x0
  pushl $62
80106a74:	6a 3e                	push   $0x3e
  jmp alltraps
80106a76:	e9 eb f6 ff ff       	jmp    80106166 <alltraps>

80106a7b <vector63>:
.globl vector63
vector63:
  pushl $0
80106a7b:	6a 00                	push   $0x0
  pushl $63
80106a7d:	6a 3f                	push   $0x3f
  jmp alltraps
80106a7f:	e9 e2 f6 ff ff       	jmp    80106166 <alltraps>

80106a84 <vector64>:
.globl vector64
vector64:
  pushl $0
80106a84:	6a 00                	push   $0x0
  pushl $64
80106a86:	6a 40                	push   $0x40
  jmp alltraps
80106a88:	e9 d9 f6 ff ff       	jmp    80106166 <alltraps>

80106a8d <vector65>:
.globl vector65
vector65:
  pushl $0
80106a8d:	6a 00                	push   $0x0
  pushl $65
80106a8f:	6a 41                	push   $0x41
  jmp alltraps
80106a91:	e9 d0 f6 ff ff       	jmp    80106166 <alltraps>

80106a96 <vector66>:
.globl vector66
vector66:
  pushl $0
80106a96:	6a 00                	push   $0x0
  pushl $66
80106a98:	6a 42                	push   $0x42
  jmp alltraps
80106a9a:	e9 c7 f6 ff ff       	jmp    80106166 <alltraps>

80106a9f <vector67>:
.globl vector67
vector67:
  pushl $0
80106a9f:	6a 00                	push   $0x0
  pushl $67
80106aa1:	6a 43                	push   $0x43
  jmp alltraps
80106aa3:	e9 be f6 ff ff       	jmp    80106166 <alltraps>

80106aa8 <vector68>:
.globl vector68
vector68:
  pushl $0
80106aa8:	6a 00                	push   $0x0
  pushl $68
80106aaa:	6a 44                	push   $0x44
  jmp alltraps
80106aac:	e9 b5 f6 ff ff       	jmp    80106166 <alltraps>

80106ab1 <vector69>:
.globl vector69
vector69:
  pushl $0
80106ab1:	6a 00                	push   $0x0
  pushl $69
80106ab3:	6a 45                	push   $0x45
  jmp alltraps
80106ab5:	e9 ac f6 ff ff       	jmp    80106166 <alltraps>

80106aba <vector70>:
.globl vector70
vector70:
  pushl $0
80106aba:	6a 00                	push   $0x0
  pushl $70
80106abc:	6a 46                	push   $0x46
  jmp alltraps
80106abe:	e9 a3 f6 ff ff       	jmp    80106166 <alltraps>

80106ac3 <vector71>:
.globl vector71
vector71:
  pushl $0
80106ac3:	6a 00                	push   $0x0
  pushl $71
80106ac5:	6a 47                	push   $0x47
  jmp alltraps
80106ac7:	e9 9a f6 ff ff       	jmp    80106166 <alltraps>

80106acc <vector72>:
.globl vector72
vector72:
  pushl $0
80106acc:	6a 00                	push   $0x0
  pushl $72
80106ace:	6a 48                	push   $0x48
  jmp alltraps
80106ad0:	e9 91 f6 ff ff       	jmp    80106166 <alltraps>

80106ad5 <vector73>:
.globl vector73
vector73:
  pushl $0
80106ad5:	6a 00                	push   $0x0
  pushl $73
80106ad7:	6a 49                	push   $0x49
  jmp alltraps
80106ad9:	e9 88 f6 ff ff       	jmp    80106166 <alltraps>

80106ade <vector74>:
.globl vector74
vector74:
  pushl $0
80106ade:	6a 00                	push   $0x0
  pushl $74
80106ae0:	6a 4a                	push   $0x4a
  jmp alltraps
80106ae2:	e9 7f f6 ff ff       	jmp    80106166 <alltraps>

80106ae7 <vector75>:
.globl vector75
vector75:
  pushl $0
80106ae7:	6a 00                	push   $0x0
  pushl $75
80106ae9:	6a 4b                	push   $0x4b
  jmp alltraps
80106aeb:	e9 76 f6 ff ff       	jmp    80106166 <alltraps>

80106af0 <vector76>:
.globl vector76
vector76:
  pushl $0
80106af0:	6a 00                	push   $0x0
  pushl $76
80106af2:	6a 4c                	push   $0x4c
  jmp alltraps
80106af4:	e9 6d f6 ff ff       	jmp    80106166 <alltraps>

80106af9 <vector77>:
.globl vector77
vector77:
  pushl $0
80106af9:	6a 00                	push   $0x0
  pushl $77
80106afb:	6a 4d                	push   $0x4d
  jmp alltraps
80106afd:	e9 64 f6 ff ff       	jmp    80106166 <alltraps>

80106b02 <vector78>:
.globl vector78
vector78:
  pushl $0
80106b02:	6a 00                	push   $0x0
  pushl $78
80106b04:	6a 4e                	push   $0x4e
  jmp alltraps
80106b06:	e9 5b f6 ff ff       	jmp    80106166 <alltraps>

80106b0b <vector79>:
.globl vector79
vector79:
  pushl $0
80106b0b:	6a 00                	push   $0x0
  pushl $79
80106b0d:	6a 4f                	push   $0x4f
  jmp alltraps
80106b0f:	e9 52 f6 ff ff       	jmp    80106166 <alltraps>

80106b14 <vector80>:
.globl vector80
vector80:
  pushl $0
80106b14:	6a 00                	push   $0x0
  pushl $80
80106b16:	6a 50                	push   $0x50
  jmp alltraps
80106b18:	e9 49 f6 ff ff       	jmp    80106166 <alltraps>

80106b1d <vector81>:
.globl vector81
vector81:
  pushl $0
80106b1d:	6a 00                	push   $0x0
  pushl $81
80106b1f:	6a 51                	push   $0x51
  jmp alltraps
80106b21:	e9 40 f6 ff ff       	jmp    80106166 <alltraps>

80106b26 <vector82>:
.globl vector82
vector82:
  pushl $0
80106b26:	6a 00                	push   $0x0
  pushl $82
80106b28:	6a 52                	push   $0x52
  jmp alltraps
80106b2a:	e9 37 f6 ff ff       	jmp    80106166 <alltraps>

80106b2f <vector83>:
.globl vector83
vector83:
  pushl $0
80106b2f:	6a 00                	push   $0x0
  pushl $83
80106b31:	6a 53                	push   $0x53
  jmp alltraps
80106b33:	e9 2e f6 ff ff       	jmp    80106166 <alltraps>

80106b38 <vector84>:
.globl vector84
vector84:
  pushl $0
80106b38:	6a 00                	push   $0x0
  pushl $84
80106b3a:	6a 54                	push   $0x54
  jmp alltraps
80106b3c:	e9 25 f6 ff ff       	jmp    80106166 <alltraps>

80106b41 <vector85>:
.globl vector85
vector85:
  pushl $0
80106b41:	6a 00                	push   $0x0
  pushl $85
80106b43:	6a 55                	push   $0x55
  jmp alltraps
80106b45:	e9 1c f6 ff ff       	jmp    80106166 <alltraps>

80106b4a <vector86>:
.globl vector86
vector86:
  pushl $0
80106b4a:	6a 00                	push   $0x0
  pushl $86
80106b4c:	6a 56                	push   $0x56
  jmp alltraps
80106b4e:	e9 13 f6 ff ff       	jmp    80106166 <alltraps>

80106b53 <vector87>:
.globl vector87
vector87:
  pushl $0
80106b53:	6a 00                	push   $0x0
  pushl $87
80106b55:	6a 57                	push   $0x57
  jmp alltraps
80106b57:	e9 0a f6 ff ff       	jmp    80106166 <alltraps>

80106b5c <vector88>:
.globl vector88
vector88:
  pushl $0
80106b5c:	6a 00                	push   $0x0
  pushl $88
80106b5e:	6a 58                	push   $0x58
  jmp alltraps
80106b60:	e9 01 f6 ff ff       	jmp    80106166 <alltraps>

80106b65 <vector89>:
.globl vector89
vector89:
  pushl $0
80106b65:	6a 00                	push   $0x0
  pushl $89
80106b67:	6a 59                	push   $0x59
  jmp alltraps
80106b69:	e9 f8 f5 ff ff       	jmp    80106166 <alltraps>

80106b6e <vector90>:
.globl vector90
vector90:
  pushl $0
80106b6e:	6a 00                	push   $0x0
  pushl $90
80106b70:	6a 5a                	push   $0x5a
  jmp alltraps
80106b72:	e9 ef f5 ff ff       	jmp    80106166 <alltraps>

80106b77 <vector91>:
.globl vector91
vector91:
  pushl $0
80106b77:	6a 00                	push   $0x0
  pushl $91
80106b79:	6a 5b                	push   $0x5b
  jmp alltraps
80106b7b:	e9 e6 f5 ff ff       	jmp    80106166 <alltraps>

80106b80 <vector92>:
.globl vector92
vector92:
  pushl $0
80106b80:	6a 00                	push   $0x0
  pushl $92
80106b82:	6a 5c                	push   $0x5c
  jmp alltraps
80106b84:	e9 dd f5 ff ff       	jmp    80106166 <alltraps>

80106b89 <vector93>:
.globl vector93
vector93:
  pushl $0
80106b89:	6a 00                	push   $0x0
  pushl $93
80106b8b:	6a 5d                	push   $0x5d
  jmp alltraps
80106b8d:	e9 d4 f5 ff ff       	jmp    80106166 <alltraps>

80106b92 <vector94>:
.globl vector94
vector94:
  pushl $0
80106b92:	6a 00                	push   $0x0
  pushl $94
80106b94:	6a 5e                	push   $0x5e
  jmp alltraps
80106b96:	e9 cb f5 ff ff       	jmp    80106166 <alltraps>

80106b9b <vector95>:
.globl vector95
vector95:
  pushl $0
80106b9b:	6a 00                	push   $0x0
  pushl $95
80106b9d:	6a 5f                	push   $0x5f
  jmp alltraps
80106b9f:	e9 c2 f5 ff ff       	jmp    80106166 <alltraps>

80106ba4 <vector96>:
.globl vector96
vector96:
  pushl $0
80106ba4:	6a 00                	push   $0x0
  pushl $96
80106ba6:	6a 60                	push   $0x60
  jmp alltraps
80106ba8:	e9 b9 f5 ff ff       	jmp    80106166 <alltraps>

80106bad <vector97>:
.globl vector97
vector97:
  pushl $0
80106bad:	6a 00                	push   $0x0
  pushl $97
80106baf:	6a 61                	push   $0x61
  jmp alltraps
80106bb1:	e9 b0 f5 ff ff       	jmp    80106166 <alltraps>

80106bb6 <vector98>:
.globl vector98
vector98:
  pushl $0
80106bb6:	6a 00                	push   $0x0
  pushl $98
80106bb8:	6a 62                	push   $0x62
  jmp alltraps
80106bba:	e9 a7 f5 ff ff       	jmp    80106166 <alltraps>

80106bbf <vector99>:
.globl vector99
vector99:
  pushl $0
80106bbf:	6a 00                	push   $0x0
  pushl $99
80106bc1:	6a 63                	push   $0x63
  jmp alltraps
80106bc3:	e9 9e f5 ff ff       	jmp    80106166 <alltraps>

80106bc8 <vector100>:
.globl vector100
vector100:
  pushl $0
80106bc8:	6a 00                	push   $0x0
  pushl $100
80106bca:	6a 64                	push   $0x64
  jmp alltraps
80106bcc:	e9 95 f5 ff ff       	jmp    80106166 <alltraps>

80106bd1 <vector101>:
.globl vector101
vector101:
  pushl $0
80106bd1:	6a 00                	push   $0x0
  pushl $101
80106bd3:	6a 65                	push   $0x65
  jmp alltraps
80106bd5:	e9 8c f5 ff ff       	jmp    80106166 <alltraps>

80106bda <vector102>:
.globl vector102
vector102:
  pushl $0
80106bda:	6a 00                	push   $0x0
  pushl $102
80106bdc:	6a 66                	push   $0x66
  jmp alltraps
80106bde:	e9 83 f5 ff ff       	jmp    80106166 <alltraps>

80106be3 <vector103>:
.globl vector103
vector103:
  pushl $0
80106be3:	6a 00                	push   $0x0
  pushl $103
80106be5:	6a 67                	push   $0x67
  jmp alltraps
80106be7:	e9 7a f5 ff ff       	jmp    80106166 <alltraps>

80106bec <vector104>:
.globl vector104
vector104:
  pushl $0
80106bec:	6a 00                	push   $0x0
  pushl $104
80106bee:	6a 68                	push   $0x68
  jmp alltraps
80106bf0:	e9 71 f5 ff ff       	jmp    80106166 <alltraps>

80106bf5 <vector105>:
.globl vector105
vector105:
  pushl $0
80106bf5:	6a 00                	push   $0x0
  pushl $105
80106bf7:	6a 69                	push   $0x69
  jmp alltraps
80106bf9:	e9 68 f5 ff ff       	jmp    80106166 <alltraps>

80106bfe <vector106>:
.globl vector106
vector106:
  pushl $0
80106bfe:	6a 00                	push   $0x0
  pushl $106
80106c00:	6a 6a                	push   $0x6a
  jmp alltraps
80106c02:	e9 5f f5 ff ff       	jmp    80106166 <alltraps>

80106c07 <vector107>:
.globl vector107
vector107:
  pushl $0
80106c07:	6a 00                	push   $0x0
  pushl $107
80106c09:	6a 6b                	push   $0x6b
  jmp alltraps
80106c0b:	e9 56 f5 ff ff       	jmp    80106166 <alltraps>

80106c10 <vector108>:
.globl vector108
vector108:
  pushl $0
80106c10:	6a 00                	push   $0x0
  pushl $108
80106c12:	6a 6c                	push   $0x6c
  jmp alltraps
80106c14:	e9 4d f5 ff ff       	jmp    80106166 <alltraps>

80106c19 <vector109>:
.globl vector109
vector109:
  pushl $0
80106c19:	6a 00                	push   $0x0
  pushl $109
80106c1b:	6a 6d                	push   $0x6d
  jmp alltraps
80106c1d:	e9 44 f5 ff ff       	jmp    80106166 <alltraps>

80106c22 <vector110>:
.globl vector110
vector110:
  pushl $0
80106c22:	6a 00                	push   $0x0
  pushl $110
80106c24:	6a 6e                	push   $0x6e
  jmp alltraps
80106c26:	e9 3b f5 ff ff       	jmp    80106166 <alltraps>

80106c2b <vector111>:
.globl vector111
vector111:
  pushl $0
80106c2b:	6a 00                	push   $0x0
  pushl $111
80106c2d:	6a 6f                	push   $0x6f
  jmp alltraps
80106c2f:	e9 32 f5 ff ff       	jmp    80106166 <alltraps>

80106c34 <vector112>:
.globl vector112
vector112:
  pushl $0
80106c34:	6a 00                	push   $0x0
  pushl $112
80106c36:	6a 70                	push   $0x70
  jmp alltraps
80106c38:	e9 29 f5 ff ff       	jmp    80106166 <alltraps>

80106c3d <vector113>:
.globl vector113
vector113:
  pushl $0
80106c3d:	6a 00                	push   $0x0
  pushl $113
80106c3f:	6a 71                	push   $0x71
  jmp alltraps
80106c41:	e9 20 f5 ff ff       	jmp    80106166 <alltraps>

80106c46 <vector114>:
.globl vector114
vector114:
  pushl $0
80106c46:	6a 00                	push   $0x0
  pushl $114
80106c48:	6a 72                	push   $0x72
  jmp alltraps
80106c4a:	e9 17 f5 ff ff       	jmp    80106166 <alltraps>

80106c4f <vector115>:
.globl vector115
vector115:
  pushl $0
80106c4f:	6a 00                	push   $0x0
  pushl $115
80106c51:	6a 73                	push   $0x73
  jmp alltraps
80106c53:	e9 0e f5 ff ff       	jmp    80106166 <alltraps>

80106c58 <vector116>:
.globl vector116
vector116:
  pushl $0
80106c58:	6a 00                	push   $0x0
  pushl $116
80106c5a:	6a 74                	push   $0x74
  jmp alltraps
80106c5c:	e9 05 f5 ff ff       	jmp    80106166 <alltraps>

80106c61 <vector117>:
.globl vector117
vector117:
  pushl $0
80106c61:	6a 00                	push   $0x0
  pushl $117
80106c63:	6a 75                	push   $0x75
  jmp alltraps
80106c65:	e9 fc f4 ff ff       	jmp    80106166 <alltraps>

80106c6a <vector118>:
.globl vector118
vector118:
  pushl $0
80106c6a:	6a 00                	push   $0x0
  pushl $118
80106c6c:	6a 76                	push   $0x76
  jmp alltraps
80106c6e:	e9 f3 f4 ff ff       	jmp    80106166 <alltraps>

80106c73 <vector119>:
.globl vector119
vector119:
  pushl $0
80106c73:	6a 00                	push   $0x0
  pushl $119
80106c75:	6a 77                	push   $0x77
  jmp alltraps
80106c77:	e9 ea f4 ff ff       	jmp    80106166 <alltraps>

80106c7c <vector120>:
.globl vector120
vector120:
  pushl $0
80106c7c:	6a 00                	push   $0x0
  pushl $120
80106c7e:	6a 78                	push   $0x78
  jmp alltraps
80106c80:	e9 e1 f4 ff ff       	jmp    80106166 <alltraps>

80106c85 <vector121>:
.globl vector121
vector121:
  pushl $0
80106c85:	6a 00                	push   $0x0
  pushl $121
80106c87:	6a 79                	push   $0x79
  jmp alltraps
80106c89:	e9 d8 f4 ff ff       	jmp    80106166 <alltraps>

80106c8e <vector122>:
.globl vector122
vector122:
  pushl $0
80106c8e:	6a 00                	push   $0x0
  pushl $122
80106c90:	6a 7a                	push   $0x7a
  jmp alltraps
80106c92:	e9 cf f4 ff ff       	jmp    80106166 <alltraps>

80106c97 <vector123>:
.globl vector123
vector123:
  pushl $0
80106c97:	6a 00                	push   $0x0
  pushl $123
80106c99:	6a 7b                	push   $0x7b
  jmp alltraps
80106c9b:	e9 c6 f4 ff ff       	jmp    80106166 <alltraps>

80106ca0 <vector124>:
.globl vector124
vector124:
  pushl $0
80106ca0:	6a 00                	push   $0x0
  pushl $124
80106ca2:	6a 7c                	push   $0x7c
  jmp alltraps
80106ca4:	e9 bd f4 ff ff       	jmp    80106166 <alltraps>

80106ca9 <vector125>:
.globl vector125
vector125:
  pushl $0
80106ca9:	6a 00                	push   $0x0
  pushl $125
80106cab:	6a 7d                	push   $0x7d
  jmp alltraps
80106cad:	e9 b4 f4 ff ff       	jmp    80106166 <alltraps>

80106cb2 <vector126>:
.globl vector126
vector126:
  pushl $0
80106cb2:	6a 00                	push   $0x0
  pushl $126
80106cb4:	6a 7e                	push   $0x7e
  jmp alltraps
80106cb6:	e9 ab f4 ff ff       	jmp    80106166 <alltraps>

80106cbb <vector127>:
.globl vector127
vector127:
  pushl $0
80106cbb:	6a 00                	push   $0x0
  pushl $127
80106cbd:	6a 7f                	push   $0x7f
  jmp alltraps
80106cbf:	e9 a2 f4 ff ff       	jmp    80106166 <alltraps>

80106cc4 <vector128>:
.globl vector128
vector128:
  pushl $0
80106cc4:	6a 00                	push   $0x0
  pushl $128
80106cc6:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106ccb:	e9 96 f4 ff ff       	jmp    80106166 <alltraps>

80106cd0 <vector129>:
.globl vector129
vector129:
  pushl $0
80106cd0:	6a 00                	push   $0x0
  pushl $129
80106cd2:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106cd7:	e9 8a f4 ff ff       	jmp    80106166 <alltraps>

80106cdc <vector130>:
.globl vector130
vector130:
  pushl $0
80106cdc:	6a 00                	push   $0x0
  pushl $130
80106cde:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106ce3:	e9 7e f4 ff ff       	jmp    80106166 <alltraps>

80106ce8 <vector131>:
.globl vector131
vector131:
  pushl $0
80106ce8:	6a 00                	push   $0x0
  pushl $131
80106cea:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106cef:	e9 72 f4 ff ff       	jmp    80106166 <alltraps>

80106cf4 <vector132>:
.globl vector132
vector132:
  pushl $0
80106cf4:	6a 00                	push   $0x0
  pushl $132
80106cf6:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106cfb:	e9 66 f4 ff ff       	jmp    80106166 <alltraps>

80106d00 <vector133>:
.globl vector133
vector133:
  pushl $0
80106d00:	6a 00                	push   $0x0
  pushl $133
80106d02:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106d07:	e9 5a f4 ff ff       	jmp    80106166 <alltraps>

80106d0c <vector134>:
.globl vector134
vector134:
  pushl $0
80106d0c:	6a 00                	push   $0x0
  pushl $134
80106d0e:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106d13:	e9 4e f4 ff ff       	jmp    80106166 <alltraps>

80106d18 <vector135>:
.globl vector135
vector135:
  pushl $0
80106d18:	6a 00                	push   $0x0
  pushl $135
80106d1a:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106d1f:	e9 42 f4 ff ff       	jmp    80106166 <alltraps>

80106d24 <vector136>:
.globl vector136
vector136:
  pushl $0
80106d24:	6a 00                	push   $0x0
  pushl $136
80106d26:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106d2b:	e9 36 f4 ff ff       	jmp    80106166 <alltraps>

80106d30 <vector137>:
.globl vector137
vector137:
  pushl $0
80106d30:	6a 00                	push   $0x0
  pushl $137
80106d32:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106d37:	e9 2a f4 ff ff       	jmp    80106166 <alltraps>

80106d3c <vector138>:
.globl vector138
vector138:
  pushl $0
80106d3c:	6a 00                	push   $0x0
  pushl $138
80106d3e:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106d43:	e9 1e f4 ff ff       	jmp    80106166 <alltraps>

80106d48 <vector139>:
.globl vector139
vector139:
  pushl $0
80106d48:	6a 00                	push   $0x0
  pushl $139
80106d4a:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106d4f:	e9 12 f4 ff ff       	jmp    80106166 <alltraps>

80106d54 <vector140>:
.globl vector140
vector140:
  pushl $0
80106d54:	6a 00                	push   $0x0
  pushl $140
80106d56:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106d5b:	e9 06 f4 ff ff       	jmp    80106166 <alltraps>

80106d60 <vector141>:
.globl vector141
vector141:
  pushl $0
80106d60:	6a 00                	push   $0x0
  pushl $141
80106d62:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106d67:	e9 fa f3 ff ff       	jmp    80106166 <alltraps>

80106d6c <vector142>:
.globl vector142
vector142:
  pushl $0
80106d6c:	6a 00                	push   $0x0
  pushl $142
80106d6e:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106d73:	e9 ee f3 ff ff       	jmp    80106166 <alltraps>

80106d78 <vector143>:
.globl vector143
vector143:
  pushl $0
80106d78:	6a 00                	push   $0x0
  pushl $143
80106d7a:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106d7f:	e9 e2 f3 ff ff       	jmp    80106166 <alltraps>

80106d84 <vector144>:
.globl vector144
vector144:
  pushl $0
80106d84:	6a 00                	push   $0x0
  pushl $144
80106d86:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106d8b:	e9 d6 f3 ff ff       	jmp    80106166 <alltraps>

80106d90 <vector145>:
.globl vector145
vector145:
  pushl $0
80106d90:	6a 00                	push   $0x0
  pushl $145
80106d92:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106d97:	e9 ca f3 ff ff       	jmp    80106166 <alltraps>

80106d9c <vector146>:
.globl vector146
vector146:
  pushl $0
80106d9c:	6a 00                	push   $0x0
  pushl $146
80106d9e:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106da3:	e9 be f3 ff ff       	jmp    80106166 <alltraps>

80106da8 <vector147>:
.globl vector147
vector147:
  pushl $0
80106da8:	6a 00                	push   $0x0
  pushl $147
80106daa:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106daf:	e9 b2 f3 ff ff       	jmp    80106166 <alltraps>

80106db4 <vector148>:
.globl vector148
vector148:
  pushl $0
80106db4:	6a 00                	push   $0x0
  pushl $148
80106db6:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106dbb:	e9 a6 f3 ff ff       	jmp    80106166 <alltraps>

80106dc0 <vector149>:
.globl vector149
vector149:
  pushl $0
80106dc0:	6a 00                	push   $0x0
  pushl $149
80106dc2:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106dc7:	e9 9a f3 ff ff       	jmp    80106166 <alltraps>

80106dcc <vector150>:
.globl vector150
vector150:
  pushl $0
80106dcc:	6a 00                	push   $0x0
  pushl $150
80106dce:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106dd3:	e9 8e f3 ff ff       	jmp    80106166 <alltraps>

80106dd8 <vector151>:
.globl vector151
vector151:
  pushl $0
80106dd8:	6a 00                	push   $0x0
  pushl $151
80106dda:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106ddf:	e9 82 f3 ff ff       	jmp    80106166 <alltraps>

80106de4 <vector152>:
.globl vector152
vector152:
  pushl $0
80106de4:	6a 00                	push   $0x0
  pushl $152
80106de6:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106deb:	e9 76 f3 ff ff       	jmp    80106166 <alltraps>

80106df0 <vector153>:
.globl vector153
vector153:
  pushl $0
80106df0:	6a 00                	push   $0x0
  pushl $153
80106df2:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106df7:	e9 6a f3 ff ff       	jmp    80106166 <alltraps>

80106dfc <vector154>:
.globl vector154
vector154:
  pushl $0
80106dfc:	6a 00                	push   $0x0
  pushl $154
80106dfe:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106e03:	e9 5e f3 ff ff       	jmp    80106166 <alltraps>

80106e08 <vector155>:
.globl vector155
vector155:
  pushl $0
80106e08:	6a 00                	push   $0x0
  pushl $155
80106e0a:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106e0f:	e9 52 f3 ff ff       	jmp    80106166 <alltraps>

80106e14 <vector156>:
.globl vector156
vector156:
  pushl $0
80106e14:	6a 00                	push   $0x0
  pushl $156
80106e16:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106e1b:	e9 46 f3 ff ff       	jmp    80106166 <alltraps>

80106e20 <vector157>:
.globl vector157
vector157:
  pushl $0
80106e20:	6a 00                	push   $0x0
  pushl $157
80106e22:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106e27:	e9 3a f3 ff ff       	jmp    80106166 <alltraps>

80106e2c <vector158>:
.globl vector158
vector158:
  pushl $0
80106e2c:	6a 00                	push   $0x0
  pushl $158
80106e2e:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106e33:	e9 2e f3 ff ff       	jmp    80106166 <alltraps>

80106e38 <vector159>:
.globl vector159
vector159:
  pushl $0
80106e38:	6a 00                	push   $0x0
  pushl $159
80106e3a:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106e3f:	e9 22 f3 ff ff       	jmp    80106166 <alltraps>

80106e44 <vector160>:
.globl vector160
vector160:
  pushl $0
80106e44:	6a 00                	push   $0x0
  pushl $160
80106e46:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106e4b:	e9 16 f3 ff ff       	jmp    80106166 <alltraps>

80106e50 <vector161>:
.globl vector161
vector161:
  pushl $0
80106e50:	6a 00                	push   $0x0
  pushl $161
80106e52:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106e57:	e9 0a f3 ff ff       	jmp    80106166 <alltraps>

80106e5c <vector162>:
.globl vector162
vector162:
  pushl $0
80106e5c:	6a 00                	push   $0x0
  pushl $162
80106e5e:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106e63:	e9 fe f2 ff ff       	jmp    80106166 <alltraps>

80106e68 <vector163>:
.globl vector163
vector163:
  pushl $0
80106e68:	6a 00                	push   $0x0
  pushl $163
80106e6a:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106e6f:	e9 f2 f2 ff ff       	jmp    80106166 <alltraps>

80106e74 <vector164>:
.globl vector164
vector164:
  pushl $0
80106e74:	6a 00                	push   $0x0
  pushl $164
80106e76:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106e7b:	e9 e6 f2 ff ff       	jmp    80106166 <alltraps>

80106e80 <vector165>:
.globl vector165
vector165:
  pushl $0
80106e80:	6a 00                	push   $0x0
  pushl $165
80106e82:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106e87:	e9 da f2 ff ff       	jmp    80106166 <alltraps>

80106e8c <vector166>:
.globl vector166
vector166:
  pushl $0
80106e8c:	6a 00                	push   $0x0
  pushl $166
80106e8e:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106e93:	e9 ce f2 ff ff       	jmp    80106166 <alltraps>

80106e98 <vector167>:
.globl vector167
vector167:
  pushl $0
80106e98:	6a 00                	push   $0x0
  pushl $167
80106e9a:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106e9f:	e9 c2 f2 ff ff       	jmp    80106166 <alltraps>

80106ea4 <vector168>:
.globl vector168
vector168:
  pushl $0
80106ea4:	6a 00                	push   $0x0
  pushl $168
80106ea6:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106eab:	e9 b6 f2 ff ff       	jmp    80106166 <alltraps>

80106eb0 <vector169>:
.globl vector169
vector169:
  pushl $0
80106eb0:	6a 00                	push   $0x0
  pushl $169
80106eb2:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106eb7:	e9 aa f2 ff ff       	jmp    80106166 <alltraps>

80106ebc <vector170>:
.globl vector170
vector170:
  pushl $0
80106ebc:	6a 00                	push   $0x0
  pushl $170
80106ebe:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106ec3:	e9 9e f2 ff ff       	jmp    80106166 <alltraps>

80106ec8 <vector171>:
.globl vector171
vector171:
  pushl $0
80106ec8:	6a 00                	push   $0x0
  pushl $171
80106eca:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106ecf:	e9 92 f2 ff ff       	jmp    80106166 <alltraps>

80106ed4 <vector172>:
.globl vector172
vector172:
  pushl $0
80106ed4:	6a 00                	push   $0x0
  pushl $172
80106ed6:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106edb:	e9 86 f2 ff ff       	jmp    80106166 <alltraps>

80106ee0 <vector173>:
.globl vector173
vector173:
  pushl $0
80106ee0:	6a 00                	push   $0x0
  pushl $173
80106ee2:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106ee7:	e9 7a f2 ff ff       	jmp    80106166 <alltraps>

80106eec <vector174>:
.globl vector174
vector174:
  pushl $0
80106eec:	6a 00                	push   $0x0
  pushl $174
80106eee:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106ef3:	e9 6e f2 ff ff       	jmp    80106166 <alltraps>

80106ef8 <vector175>:
.globl vector175
vector175:
  pushl $0
80106ef8:	6a 00                	push   $0x0
  pushl $175
80106efa:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106eff:	e9 62 f2 ff ff       	jmp    80106166 <alltraps>

80106f04 <vector176>:
.globl vector176
vector176:
  pushl $0
80106f04:	6a 00                	push   $0x0
  pushl $176
80106f06:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106f0b:	e9 56 f2 ff ff       	jmp    80106166 <alltraps>

80106f10 <vector177>:
.globl vector177
vector177:
  pushl $0
80106f10:	6a 00                	push   $0x0
  pushl $177
80106f12:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106f17:	e9 4a f2 ff ff       	jmp    80106166 <alltraps>

80106f1c <vector178>:
.globl vector178
vector178:
  pushl $0
80106f1c:	6a 00                	push   $0x0
  pushl $178
80106f1e:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106f23:	e9 3e f2 ff ff       	jmp    80106166 <alltraps>

80106f28 <vector179>:
.globl vector179
vector179:
  pushl $0
80106f28:	6a 00                	push   $0x0
  pushl $179
80106f2a:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106f2f:	e9 32 f2 ff ff       	jmp    80106166 <alltraps>

80106f34 <vector180>:
.globl vector180
vector180:
  pushl $0
80106f34:	6a 00                	push   $0x0
  pushl $180
80106f36:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106f3b:	e9 26 f2 ff ff       	jmp    80106166 <alltraps>

80106f40 <vector181>:
.globl vector181
vector181:
  pushl $0
80106f40:	6a 00                	push   $0x0
  pushl $181
80106f42:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106f47:	e9 1a f2 ff ff       	jmp    80106166 <alltraps>

80106f4c <vector182>:
.globl vector182
vector182:
  pushl $0
80106f4c:	6a 00                	push   $0x0
  pushl $182
80106f4e:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106f53:	e9 0e f2 ff ff       	jmp    80106166 <alltraps>

80106f58 <vector183>:
.globl vector183
vector183:
  pushl $0
80106f58:	6a 00                	push   $0x0
  pushl $183
80106f5a:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106f5f:	e9 02 f2 ff ff       	jmp    80106166 <alltraps>

80106f64 <vector184>:
.globl vector184
vector184:
  pushl $0
80106f64:	6a 00                	push   $0x0
  pushl $184
80106f66:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106f6b:	e9 f6 f1 ff ff       	jmp    80106166 <alltraps>

80106f70 <vector185>:
.globl vector185
vector185:
  pushl $0
80106f70:	6a 00                	push   $0x0
  pushl $185
80106f72:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106f77:	e9 ea f1 ff ff       	jmp    80106166 <alltraps>

80106f7c <vector186>:
.globl vector186
vector186:
  pushl $0
80106f7c:	6a 00                	push   $0x0
  pushl $186
80106f7e:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106f83:	e9 de f1 ff ff       	jmp    80106166 <alltraps>

80106f88 <vector187>:
.globl vector187
vector187:
  pushl $0
80106f88:	6a 00                	push   $0x0
  pushl $187
80106f8a:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106f8f:	e9 d2 f1 ff ff       	jmp    80106166 <alltraps>

80106f94 <vector188>:
.globl vector188
vector188:
  pushl $0
80106f94:	6a 00                	push   $0x0
  pushl $188
80106f96:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106f9b:	e9 c6 f1 ff ff       	jmp    80106166 <alltraps>

80106fa0 <vector189>:
.globl vector189
vector189:
  pushl $0
80106fa0:	6a 00                	push   $0x0
  pushl $189
80106fa2:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106fa7:	e9 ba f1 ff ff       	jmp    80106166 <alltraps>

80106fac <vector190>:
.globl vector190
vector190:
  pushl $0
80106fac:	6a 00                	push   $0x0
  pushl $190
80106fae:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106fb3:	e9 ae f1 ff ff       	jmp    80106166 <alltraps>

80106fb8 <vector191>:
.globl vector191
vector191:
  pushl $0
80106fb8:	6a 00                	push   $0x0
  pushl $191
80106fba:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106fbf:	e9 a2 f1 ff ff       	jmp    80106166 <alltraps>

80106fc4 <vector192>:
.globl vector192
vector192:
  pushl $0
80106fc4:	6a 00                	push   $0x0
  pushl $192
80106fc6:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106fcb:	e9 96 f1 ff ff       	jmp    80106166 <alltraps>

80106fd0 <vector193>:
.globl vector193
vector193:
  pushl $0
80106fd0:	6a 00                	push   $0x0
  pushl $193
80106fd2:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106fd7:	e9 8a f1 ff ff       	jmp    80106166 <alltraps>

80106fdc <vector194>:
.globl vector194
vector194:
  pushl $0
80106fdc:	6a 00                	push   $0x0
  pushl $194
80106fde:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106fe3:	e9 7e f1 ff ff       	jmp    80106166 <alltraps>

80106fe8 <vector195>:
.globl vector195
vector195:
  pushl $0
80106fe8:	6a 00                	push   $0x0
  pushl $195
80106fea:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106fef:	e9 72 f1 ff ff       	jmp    80106166 <alltraps>

80106ff4 <vector196>:
.globl vector196
vector196:
  pushl $0
80106ff4:	6a 00                	push   $0x0
  pushl $196
80106ff6:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106ffb:	e9 66 f1 ff ff       	jmp    80106166 <alltraps>

80107000 <vector197>:
.globl vector197
vector197:
  pushl $0
80107000:	6a 00                	push   $0x0
  pushl $197
80107002:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107007:	e9 5a f1 ff ff       	jmp    80106166 <alltraps>

8010700c <vector198>:
.globl vector198
vector198:
  pushl $0
8010700c:	6a 00                	push   $0x0
  pushl $198
8010700e:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107013:	e9 4e f1 ff ff       	jmp    80106166 <alltraps>

80107018 <vector199>:
.globl vector199
vector199:
  pushl $0
80107018:	6a 00                	push   $0x0
  pushl $199
8010701a:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010701f:	e9 42 f1 ff ff       	jmp    80106166 <alltraps>

80107024 <vector200>:
.globl vector200
vector200:
  pushl $0
80107024:	6a 00                	push   $0x0
  pushl $200
80107026:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010702b:	e9 36 f1 ff ff       	jmp    80106166 <alltraps>

80107030 <vector201>:
.globl vector201
vector201:
  pushl $0
80107030:	6a 00                	push   $0x0
  pushl $201
80107032:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107037:	e9 2a f1 ff ff       	jmp    80106166 <alltraps>

8010703c <vector202>:
.globl vector202
vector202:
  pushl $0
8010703c:	6a 00                	push   $0x0
  pushl $202
8010703e:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107043:	e9 1e f1 ff ff       	jmp    80106166 <alltraps>

80107048 <vector203>:
.globl vector203
vector203:
  pushl $0
80107048:	6a 00                	push   $0x0
  pushl $203
8010704a:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010704f:	e9 12 f1 ff ff       	jmp    80106166 <alltraps>

80107054 <vector204>:
.globl vector204
vector204:
  pushl $0
80107054:	6a 00                	push   $0x0
  pushl $204
80107056:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010705b:	e9 06 f1 ff ff       	jmp    80106166 <alltraps>

80107060 <vector205>:
.globl vector205
vector205:
  pushl $0
80107060:	6a 00                	push   $0x0
  pushl $205
80107062:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107067:	e9 fa f0 ff ff       	jmp    80106166 <alltraps>

8010706c <vector206>:
.globl vector206
vector206:
  pushl $0
8010706c:	6a 00                	push   $0x0
  pushl $206
8010706e:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107073:	e9 ee f0 ff ff       	jmp    80106166 <alltraps>

80107078 <vector207>:
.globl vector207
vector207:
  pushl $0
80107078:	6a 00                	push   $0x0
  pushl $207
8010707a:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010707f:	e9 e2 f0 ff ff       	jmp    80106166 <alltraps>

80107084 <vector208>:
.globl vector208
vector208:
  pushl $0
80107084:	6a 00                	push   $0x0
  pushl $208
80107086:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010708b:	e9 d6 f0 ff ff       	jmp    80106166 <alltraps>

80107090 <vector209>:
.globl vector209
vector209:
  pushl $0
80107090:	6a 00                	push   $0x0
  pushl $209
80107092:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107097:	e9 ca f0 ff ff       	jmp    80106166 <alltraps>

8010709c <vector210>:
.globl vector210
vector210:
  pushl $0
8010709c:	6a 00                	push   $0x0
  pushl $210
8010709e:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801070a3:	e9 be f0 ff ff       	jmp    80106166 <alltraps>

801070a8 <vector211>:
.globl vector211
vector211:
  pushl $0
801070a8:	6a 00                	push   $0x0
  pushl $211
801070aa:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801070af:	e9 b2 f0 ff ff       	jmp    80106166 <alltraps>

801070b4 <vector212>:
.globl vector212
vector212:
  pushl $0
801070b4:	6a 00                	push   $0x0
  pushl $212
801070b6:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801070bb:	e9 a6 f0 ff ff       	jmp    80106166 <alltraps>

801070c0 <vector213>:
.globl vector213
vector213:
  pushl $0
801070c0:	6a 00                	push   $0x0
  pushl $213
801070c2:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801070c7:	e9 9a f0 ff ff       	jmp    80106166 <alltraps>

801070cc <vector214>:
.globl vector214
vector214:
  pushl $0
801070cc:	6a 00                	push   $0x0
  pushl $214
801070ce:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801070d3:	e9 8e f0 ff ff       	jmp    80106166 <alltraps>

801070d8 <vector215>:
.globl vector215
vector215:
  pushl $0
801070d8:	6a 00                	push   $0x0
  pushl $215
801070da:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801070df:	e9 82 f0 ff ff       	jmp    80106166 <alltraps>

801070e4 <vector216>:
.globl vector216
vector216:
  pushl $0
801070e4:	6a 00                	push   $0x0
  pushl $216
801070e6:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801070eb:	e9 76 f0 ff ff       	jmp    80106166 <alltraps>

801070f0 <vector217>:
.globl vector217
vector217:
  pushl $0
801070f0:	6a 00                	push   $0x0
  pushl $217
801070f2:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801070f7:	e9 6a f0 ff ff       	jmp    80106166 <alltraps>

801070fc <vector218>:
.globl vector218
vector218:
  pushl $0
801070fc:	6a 00                	push   $0x0
  pushl $218
801070fe:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107103:	e9 5e f0 ff ff       	jmp    80106166 <alltraps>

80107108 <vector219>:
.globl vector219
vector219:
  pushl $0
80107108:	6a 00                	push   $0x0
  pushl $219
8010710a:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010710f:	e9 52 f0 ff ff       	jmp    80106166 <alltraps>

80107114 <vector220>:
.globl vector220
vector220:
  pushl $0
80107114:	6a 00                	push   $0x0
  pushl $220
80107116:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010711b:	e9 46 f0 ff ff       	jmp    80106166 <alltraps>

80107120 <vector221>:
.globl vector221
vector221:
  pushl $0
80107120:	6a 00                	push   $0x0
  pushl $221
80107122:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107127:	e9 3a f0 ff ff       	jmp    80106166 <alltraps>

8010712c <vector222>:
.globl vector222
vector222:
  pushl $0
8010712c:	6a 00                	push   $0x0
  pushl $222
8010712e:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107133:	e9 2e f0 ff ff       	jmp    80106166 <alltraps>

80107138 <vector223>:
.globl vector223
vector223:
  pushl $0
80107138:	6a 00                	push   $0x0
  pushl $223
8010713a:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010713f:	e9 22 f0 ff ff       	jmp    80106166 <alltraps>

80107144 <vector224>:
.globl vector224
vector224:
  pushl $0
80107144:	6a 00                	push   $0x0
  pushl $224
80107146:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010714b:	e9 16 f0 ff ff       	jmp    80106166 <alltraps>

80107150 <vector225>:
.globl vector225
vector225:
  pushl $0
80107150:	6a 00                	push   $0x0
  pushl $225
80107152:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107157:	e9 0a f0 ff ff       	jmp    80106166 <alltraps>

8010715c <vector226>:
.globl vector226
vector226:
  pushl $0
8010715c:	6a 00                	push   $0x0
  pushl $226
8010715e:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107163:	e9 fe ef ff ff       	jmp    80106166 <alltraps>

80107168 <vector227>:
.globl vector227
vector227:
  pushl $0
80107168:	6a 00                	push   $0x0
  pushl $227
8010716a:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010716f:	e9 f2 ef ff ff       	jmp    80106166 <alltraps>

80107174 <vector228>:
.globl vector228
vector228:
  pushl $0
80107174:	6a 00                	push   $0x0
  pushl $228
80107176:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010717b:	e9 e6 ef ff ff       	jmp    80106166 <alltraps>

80107180 <vector229>:
.globl vector229
vector229:
  pushl $0
80107180:	6a 00                	push   $0x0
  pushl $229
80107182:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107187:	e9 da ef ff ff       	jmp    80106166 <alltraps>

8010718c <vector230>:
.globl vector230
vector230:
  pushl $0
8010718c:	6a 00                	push   $0x0
  pushl $230
8010718e:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107193:	e9 ce ef ff ff       	jmp    80106166 <alltraps>

80107198 <vector231>:
.globl vector231
vector231:
  pushl $0
80107198:	6a 00                	push   $0x0
  pushl $231
8010719a:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010719f:	e9 c2 ef ff ff       	jmp    80106166 <alltraps>

801071a4 <vector232>:
.globl vector232
vector232:
  pushl $0
801071a4:	6a 00                	push   $0x0
  pushl $232
801071a6:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801071ab:	e9 b6 ef ff ff       	jmp    80106166 <alltraps>

801071b0 <vector233>:
.globl vector233
vector233:
  pushl $0
801071b0:	6a 00                	push   $0x0
  pushl $233
801071b2:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801071b7:	e9 aa ef ff ff       	jmp    80106166 <alltraps>

801071bc <vector234>:
.globl vector234
vector234:
  pushl $0
801071bc:	6a 00                	push   $0x0
  pushl $234
801071be:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801071c3:	e9 9e ef ff ff       	jmp    80106166 <alltraps>

801071c8 <vector235>:
.globl vector235
vector235:
  pushl $0
801071c8:	6a 00                	push   $0x0
  pushl $235
801071ca:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801071cf:	e9 92 ef ff ff       	jmp    80106166 <alltraps>

801071d4 <vector236>:
.globl vector236
vector236:
  pushl $0
801071d4:	6a 00                	push   $0x0
  pushl $236
801071d6:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801071db:	e9 86 ef ff ff       	jmp    80106166 <alltraps>

801071e0 <vector237>:
.globl vector237
vector237:
  pushl $0
801071e0:	6a 00                	push   $0x0
  pushl $237
801071e2:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801071e7:	e9 7a ef ff ff       	jmp    80106166 <alltraps>

801071ec <vector238>:
.globl vector238
vector238:
  pushl $0
801071ec:	6a 00                	push   $0x0
  pushl $238
801071ee:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801071f3:	e9 6e ef ff ff       	jmp    80106166 <alltraps>

801071f8 <vector239>:
.globl vector239
vector239:
  pushl $0
801071f8:	6a 00                	push   $0x0
  pushl $239
801071fa:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801071ff:	e9 62 ef ff ff       	jmp    80106166 <alltraps>

80107204 <vector240>:
.globl vector240
vector240:
  pushl $0
80107204:	6a 00                	push   $0x0
  pushl $240
80107206:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010720b:	e9 56 ef ff ff       	jmp    80106166 <alltraps>

80107210 <vector241>:
.globl vector241
vector241:
  pushl $0
80107210:	6a 00                	push   $0x0
  pushl $241
80107212:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107217:	e9 4a ef ff ff       	jmp    80106166 <alltraps>

8010721c <vector242>:
.globl vector242
vector242:
  pushl $0
8010721c:	6a 00                	push   $0x0
  pushl $242
8010721e:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107223:	e9 3e ef ff ff       	jmp    80106166 <alltraps>

80107228 <vector243>:
.globl vector243
vector243:
  pushl $0
80107228:	6a 00                	push   $0x0
  pushl $243
8010722a:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010722f:	e9 32 ef ff ff       	jmp    80106166 <alltraps>

80107234 <vector244>:
.globl vector244
vector244:
  pushl $0
80107234:	6a 00                	push   $0x0
  pushl $244
80107236:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010723b:	e9 26 ef ff ff       	jmp    80106166 <alltraps>

80107240 <vector245>:
.globl vector245
vector245:
  pushl $0
80107240:	6a 00                	push   $0x0
  pushl $245
80107242:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107247:	e9 1a ef ff ff       	jmp    80106166 <alltraps>

8010724c <vector246>:
.globl vector246
vector246:
  pushl $0
8010724c:	6a 00                	push   $0x0
  pushl $246
8010724e:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107253:	e9 0e ef ff ff       	jmp    80106166 <alltraps>

80107258 <vector247>:
.globl vector247
vector247:
  pushl $0
80107258:	6a 00                	push   $0x0
  pushl $247
8010725a:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010725f:	e9 02 ef ff ff       	jmp    80106166 <alltraps>

80107264 <vector248>:
.globl vector248
vector248:
  pushl $0
80107264:	6a 00                	push   $0x0
  pushl $248
80107266:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010726b:	e9 f6 ee ff ff       	jmp    80106166 <alltraps>

80107270 <vector249>:
.globl vector249
vector249:
  pushl $0
80107270:	6a 00                	push   $0x0
  pushl $249
80107272:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107277:	e9 ea ee ff ff       	jmp    80106166 <alltraps>

8010727c <vector250>:
.globl vector250
vector250:
  pushl $0
8010727c:	6a 00                	push   $0x0
  pushl $250
8010727e:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107283:	e9 de ee ff ff       	jmp    80106166 <alltraps>

80107288 <vector251>:
.globl vector251
vector251:
  pushl $0
80107288:	6a 00                	push   $0x0
  pushl $251
8010728a:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010728f:	e9 d2 ee ff ff       	jmp    80106166 <alltraps>

80107294 <vector252>:
.globl vector252
vector252:
  pushl $0
80107294:	6a 00                	push   $0x0
  pushl $252
80107296:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010729b:	e9 c6 ee ff ff       	jmp    80106166 <alltraps>

801072a0 <vector253>:
.globl vector253
vector253:
  pushl $0
801072a0:	6a 00                	push   $0x0
  pushl $253
801072a2:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801072a7:	e9 ba ee ff ff       	jmp    80106166 <alltraps>

801072ac <vector254>:
.globl vector254
vector254:
  pushl $0
801072ac:	6a 00                	push   $0x0
  pushl $254
801072ae:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801072b3:	e9 ae ee ff ff       	jmp    80106166 <alltraps>

801072b8 <vector255>:
.globl vector255
vector255:
  pushl $0
801072b8:	6a 00                	push   $0x0
  pushl $255
801072ba:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801072bf:	e9 a2 ee ff ff       	jmp    80106166 <alltraps>

801072c4 <lgdt>:
{
801072c4:	55                   	push   %ebp
801072c5:	89 e5                	mov    %esp,%ebp
801072c7:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801072ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801072cd:	83 e8 01             	sub    $0x1,%eax
801072d0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801072d4:	8b 45 08             	mov    0x8(%ebp),%eax
801072d7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801072db:	8b 45 08             	mov    0x8(%ebp),%eax
801072de:	c1 e8 10             	shr    $0x10,%eax
801072e1:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801072e5:	8d 45 fa             	lea    -0x6(%ebp),%eax
801072e8:	0f 01 10             	lgdtl  (%eax)
}
801072eb:	90                   	nop
801072ec:	c9                   	leave
801072ed:	c3                   	ret

801072ee <ltr>:
{
801072ee:	55                   	push   %ebp
801072ef:	89 e5                	mov    %esp,%ebp
801072f1:	83 ec 04             	sub    $0x4,%esp
801072f4:	8b 45 08             	mov    0x8(%ebp),%eax
801072f7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801072fb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801072ff:	0f 00 d8             	ltr    %eax
}
80107302:	90                   	nop
80107303:	c9                   	leave
80107304:	c3                   	ret

80107305 <lcr3>:

static inline void
lcr3(uint val)
{
80107305:	55                   	push   %ebp
80107306:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107308:	8b 45 08             	mov    0x8(%ebp),%eax
8010730b:	0f 22 d8             	mov    %eax,%cr3
}
8010730e:	90                   	nop
8010730f:	5d                   	pop    %ebp
80107310:	c3                   	ret

80107311 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107311:	f3 0f 1e fb          	endbr32
80107315:	55                   	push   %ebp
80107316:	89 e5                	mov    %esp,%ebp
80107318:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010731b:	e8 fe c7 ff ff       	call   80103b1e <cpuid>
80107320:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107326:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
8010732b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010732e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107331:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107337:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010733a:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107343:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107347:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010734a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010734e:	83 e2 f0             	and    $0xfffffff0,%edx
80107351:	83 ca 0a             	or     $0xa,%edx
80107354:	88 50 7d             	mov    %dl,0x7d(%eax)
80107357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010735e:	83 ca 10             	or     $0x10,%edx
80107361:	88 50 7d             	mov    %dl,0x7d(%eax)
80107364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107367:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010736b:	83 e2 9f             	and    $0xffffff9f,%edx
8010736e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107374:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107378:	83 ca 80             	or     $0xffffff80,%edx
8010737b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010737e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107381:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107385:	83 ca 0f             	or     $0xf,%edx
80107388:	88 50 7e             	mov    %dl,0x7e(%eax)
8010738b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010738e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107392:	83 e2 ef             	and    $0xffffffef,%edx
80107395:	88 50 7e             	mov    %dl,0x7e(%eax)
80107398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010739f:	83 e2 df             	and    $0xffffffdf,%edx
801073a2:	88 50 7e             	mov    %dl,0x7e(%eax)
801073a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073ac:	83 ca 40             	or     $0x40,%edx
801073af:	88 50 7e             	mov    %dl,0x7e(%eax)
801073b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073b9:	83 ca 80             	or     $0xffffff80,%edx
801073bc:	88 50 7e             	mov    %dl,0x7e(%eax)
801073bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c2:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801073c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c9:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801073d0:	ff ff 
801073d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d5:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801073dc:	00 00 
801073de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e1:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801073e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073eb:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801073f2:	83 e2 f0             	and    $0xfffffff0,%edx
801073f5:	83 ca 02             	or     $0x2,%edx
801073f8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801073fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107401:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107408:	83 ca 10             	or     $0x10,%edx
8010740b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107411:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107414:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010741b:	83 e2 9f             	and    $0xffffff9f,%edx
8010741e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107427:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010742e:	83 ca 80             	or     $0xffffff80,%edx
80107431:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107441:	83 ca 0f             	or     $0xf,%edx
80107444:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010744a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010744d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107454:	83 e2 ef             	and    $0xffffffef,%edx
80107457:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010745d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107460:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107467:	83 e2 df             	and    $0xffffffdf,%edx
8010746a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107473:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010747a:	83 ca 40             	or     $0x40,%edx
8010747d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107486:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010748d:	83 ca 80             	or     $0xffffff80,%edx
80107490:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107499:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801074a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a3:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801074aa:	ff ff 
801074ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074af:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801074b6:	00 00 
801074b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074bb:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801074c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801074cc:	83 e2 f0             	and    $0xfffffff0,%edx
801074cf:	83 ca 0a             	or     $0xa,%edx
801074d2:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801074d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074db:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801074e2:	83 ca 10             	or     $0x10,%edx
801074e5:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801074eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ee:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801074f5:	83 ca 60             	or     $0x60,%edx
801074f8:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801074fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107501:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107508:	83 ca 80             	or     $0xffffff80,%edx
8010750b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107514:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010751b:	83 ca 0f             	or     $0xf,%edx
8010751e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107527:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010752e:	83 e2 ef             	and    $0xffffffef,%edx
80107531:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107541:	83 e2 df             	and    $0xffffffdf,%edx
80107544:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010754a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010754d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107554:	83 ca 40             	or     $0x40,%edx
80107557:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010755d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107560:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107567:	83 ca 80             	or     $0xffffff80,%edx
8010756a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107573:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010757a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010757d:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107584:	ff ff 
80107586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107589:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107590:	00 00 
80107592:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107595:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010759c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075a6:	83 e2 f0             	and    $0xfffffff0,%edx
801075a9:	83 ca 02             	or     $0x2,%edx
801075ac:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b5:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075bc:	83 ca 10             	or     $0x10,%edx
801075bf:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075cf:	83 ca 60             	or     $0x60,%edx
801075d2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075db:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075e2:	83 ca 80             	or     $0xffffff80,%edx
801075e5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ee:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801075f5:	83 ca 0f             	or     $0xf,%edx
801075f8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801075fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107601:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107608:	83 e2 ef             	and    $0xffffffef,%edx
8010760b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107614:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010761b:	83 e2 df             	and    $0xffffffdf,%edx
8010761e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107627:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010762e:	83 ca 40             	or     $0x40,%edx
80107631:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107641:	83 ca 80             	or     $0xffffff80,%edx
80107644:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010764a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764d:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107654:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107657:	83 c0 70             	add    $0x70,%eax
8010765a:	83 ec 08             	sub    $0x8,%esp
8010765d:	6a 30                	push   $0x30
8010765f:	50                   	push   %eax
80107660:	e8 5f fc ff ff       	call   801072c4 <lgdt>
80107665:	83 c4 10             	add    $0x10,%esp
}
80107668:	90                   	nop
80107669:	c9                   	leave
8010766a:	c3                   	ret

8010766b <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
/*static 전역에서 사용해야 함*/ pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010766b:	f3 0f 1e fb          	endbr32
8010766f:	55                   	push   %ebp
80107670:	89 e5                	mov    %esp,%ebp
80107672:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107675:	8b 45 0c             	mov    0xc(%ebp),%eax
80107678:	c1 e8 16             	shr    $0x16,%eax
8010767b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107682:	8b 45 08             	mov    0x8(%ebp),%eax
80107685:	01 d0                	add    %edx,%eax
80107687:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010768a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010768d:	8b 00                	mov    (%eax),%eax
8010768f:	83 e0 01             	and    $0x1,%eax
80107692:	85 c0                	test   %eax,%eax
80107694:	74 14                	je     801076aa <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107696:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107699:	8b 00                	mov    (%eax),%eax
8010769b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076a0:	05 00 00 00 80       	add    $0x80000000,%eax
801076a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801076a8:	eb 42                	jmp    801076ec <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801076aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801076ae:	74 0e                	je     801076be <walkpgdir+0x53>
801076b0:	e8 ed b1 ff ff       	call   801028a2 <kalloc>
801076b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801076b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801076bc:	75 07                	jne    801076c5 <walkpgdir+0x5a>
      return 0;
801076be:	b8 00 00 00 00       	mov    $0x0,%eax
801076c3:	eb 3e                	jmp    80107703 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801076c5:	83 ec 04             	sub    $0x4,%esp
801076c8:	68 00 10 00 00       	push   $0x1000
801076cd:	6a 00                	push   $0x0
801076cf:	ff 75 f4             	push   -0xc(%ebp)
801076d2:	e8 f5 d5 ff ff       	call   80104ccc <memset>
801076d7:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801076da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076dd:	05 00 00 00 80       	add    $0x80000000,%eax
801076e2:	83 c8 07             	or     $0x7,%eax
801076e5:	89 c2                	mov    %eax,%edx
801076e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076ea:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801076ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801076ef:	c1 e8 0c             	shr    $0xc,%eax
801076f2:	25 ff 03 00 00       	and    $0x3ff,%eax
801076f7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801076fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107701:	01 d0                	add    %edx,%eax
}
80107703:	c9                   	leave
80107704:	c3                   	ret

80107705 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
/*static 전역에서 사용해야 함*/ int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107705:	f3 0f 1e fb          	endbr32
80107709:	55                   	push   %ebp
8010770a:	89 e5                	mov    %esp,%ebp
8010770c:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010770f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107712:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107717:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010771a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010771d:	8b 45 10             	mov    0x10(%ebp),%eax
80107720:	01 d0                	add    %edx,%eax
80107722:	83 e8 01             	sub    $0x1,%eax
80107725:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010772a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010772d:	83 ec 04             	sub    $0x4,%esp
80107730:	6a 01                	push   $0x1
80107732:	ff 75 f4             	push   -0xc(%ebp)
80107735:	ff 75 08             	push   0x8(%ebp)
80107738:	e8 2e ff ff ff       	call   8010766b <walkpgdir>
8010773d:	83 c4 10             	add    $0x10,%esp
80107740:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107743:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107747:	75 07                	jne    80107750 <mappages+0x4b>
      return -1;
80107749:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010774e:	eb 47                	jmp    80107797 <mappages+0x92>
    if(*pte & PTE_P)
80107750:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107753:	8b 00                	mov    (%eax),%eax
80107755:	83 e0 01             	and    $0x1,%eax
80107758:	85 c0                	test   %eax,%eax
8010775a:	74 0d                	je     80107769 <mappages+0x64>
      panic("remap");
8010775c:	83 ec 0c             	sub    $0xc,%esp
8010775f:	68 40 ac 10 80       	push   $0x8010ac40
80107764:	e8 75 8e ff ff       	call   801005de <panic>
    *pte = pa | perm | PTE_P;
80107769:	8b 45 18             	mov    0x18(%ebp),%eax
8010776c:	0b 45 14             	or     0x14(%ebp),%eax
8010776f:	83 c8 01             	or     $0x1,%eax
80107772:	89 c2                	mov    %eax,%edx
80107774:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107777:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010777f:	74 10                	je     80107791 <mappages+0x8c>
      break;
    a += PGSIZE;
80107781:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107788:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010778f:	eb 9c                	jmp    8010772d <mappages+0x28>
      break;
80107791:	90                   	nop
  }
  return 0;
80107792:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107797:	c9                   	leave
80107798:	c3                   	ret

80107799 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107799:	f3 0f 1e fb          	endbr32
8010779d:	55                   	push   %ebp
8010779e:	89 e5                	mov    %esp,%ebp
801077a0:	53                   	push   %ebx
801077a1:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801077a4:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801077ab:	a1 8c 80 19 80       	mov    0x8019808c,%eax
801077b0:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801077b5:	29 c2                	sub    %eax,%edx
801077b7:	89 d0                	mov    %edx,%eax
801077b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
801077bc:	a1 84 80 19 80       	mov    0x80198084,%eax
801077c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801077c4:	8b 15 84 80 19 80    	mov    0x80198084,%edx
801077ca:	a1 8c 80 19 80       	mov    0x8019808c,%eax
801077cf:	01 d0                	add    %edx,%eax
801077d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
801077d4:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
801077db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077de:	83 c0 30             	add    $0x30,%eax
801077e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801077e4:	89 10                	mov    %edx,(%eax)
801077e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801077e9:	89 50 04             	mov    %edx,0x4(%eax)
801077ec:	8b 55 e8             	mov    -0x18(%ebp),%edx
801077ef:	89 50 08             	mov    %edx,0x8(%eax)
801077f2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801077f5:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
801077f8:	e8 a5 b0 ff ff       	call   801028a2 <kalloc>
801077fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107800:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107804:	75 07                	jne    8010780d <setupkvm+0x74>
    return 0;
80107806:	b8 00 00 00 00       	mov    $0x0,%eax
8010780b:	eb 78                	jmp    80107885 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
8010780d:	83 ec 04             	sub    $0x4,%esp
80107810:	68 00 10 00 00       	push   $0x1000
80107815:	6a 00                	push   $0x0
80107817:	ff 75 f0             	push   -0x10(%ebp)
8010781a:	e8 ad d4 ff ff       	call   80104ccc <memset>
8010781f:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107822:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107829:	eb 4e                	jmp    80107879 <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010782b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782e:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107834:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783a:	8b 58 08             	mov    0x8(%eax),%ebx
8010783d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107840:	8b 40 04             	mov    0x4(%eax),%eax
80107843:	29 c3                	sub    %eax,%ebx
80107845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107848:	8b 00                	mov    (%eax),%eax
8010784a:	83 ec 0c             	sub    $0xc,%esp
8010784d:	51                   	push   %ecx
8010784e:	52                   	push   %edx
8010784f:	53                   	push   %ebx
80107850:	50                   	push   %eax
80107851:	ff 75 f0             	push   -0x10(%ebp)
80107854:	e8 ac fe ff ff       	call   80107705 <mappages>
80107859:	83 c4 20             	add    $0x20,%esp
8010785c:	85 c0                	test   %eax,%eax
8010785e:	79 15                	jns    80107875 <setupkvm+0xdc>
      freevm(pgdir);
80107860:	83 ec 0c             	sub    $0xc,%esp
80107863:	ff 75 f0             	push   -0x10(%ebp)
80107866:	e8 11 05 00 00       	call   80107d7c <freevm>
8010786b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010786e:	b8 00 00 00 00       	mov    $0x0,%eax
80107873:	eb 10                	jmp    80107885 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107875:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107879:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107880:	72 a9                	jb     8010782b <setupkvm+0x92>
    }
  return pgdir;
80107882:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107885:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107888:	c9                   	leave
80107889:	c3                   	ret

8010788a <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010788a:	f3 0f 1e fb          	endbr32
8010788e:	55                   	push   %ebp
8010788f:	89 e5                	mov    %esp,%ebp
80107891:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107894:	e8 00 ff ff ff       	call   80107799 <setupkvm>
80107899:	a3 84 7d 19 80       	mov    %eax,0x80197d84
  switchkvm();
8010789e:	e8 03 00 00 00       	call   801078a6 <switchkvm>
}
801078a3:	90                   	nop
801078a4:	c9                   	leave
801078a5:	c3                   	ret

801078a6 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801078a6:	f3 0f 1e fb          	endbr32
801078aa:	55                   	push   %ebp
801078ab:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801078ad:	a1 84 7d 19 80       	mov    0x80197d84,%eax
801078b2:	05 00 00 00 80       	add    $0x80000000,%eax
801078b7:	50                   	push   %eax
801078b8:	e8 48 fa ff ff       	call   80107305 <lcr3>
801078bd:	83 c4 04             	add    $0x4,%esp
}
801078c0:	90                   	nop
801078c1:	c9                   	leave
801078c2:	c3                   	ret

801078c3 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801078c3:	f3 0f 1e fb          	endbr32
801078c7:	55                   	push   %ebp
801078c8:	89 e5                	mov    %esp,%ebp
801078ca:	56                   	push   %esi
801078cb:	53                   	push   %ebx
801078cc:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801078cf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801078d3:	75 0d                	jne    801078e2 <switchuvm+0x1f>
    panic("switchuvm: no process");
801078d5:	83 ec 0c             	sub    $0xc,%esp
801078d8:	68 46 ac 10 80       	push   $0x8010ac46
801078dd:	e8 fc 8c ff ff       	call   801005de <panic>
  if(p->kstack == 0)
801078e2:	8b 45 08             	mov    0x8(%ebp),%eax
801078e5:	8b 40 08             	mov    0x8(%eax),%eax
801078e8:	85 c0                	test   %eax,%eax
801078ea:	75 0d                	jne    801078f9 <switchuvm+0x36>
    panic("switchuvm: no kstack");
801078ec:	83 ec 0c             	sub    $0xc,%esp
801078ef:	68 5c ac 10 80       	push   $0x8010ac5c
801078f4:	e8 e5 8c ff ff       	call   801005de <panic>
  if(p->pgdir == 0)
801078f9:	8b 45 08             	mov    0x8(%ebp),%eax
801078fc:	8b 40 04             	mov    0x4(%eax),%eax
801078ff:	85 c0                	test   %eax,%eax
80107901:	75 0d                	jne    80107910 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
80107903:	83 ec 0c             	sub    $0xc,%esp
80107906:	68 71 ac 10 80       	push   $0x8010ac71
8010790b:	e8 ce 8c ff ff       	call   801005de <panic>

  pushcli();
80107910:	e8 a4 d2 ff ff       	call   80104bb9 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107915:	e8 23 c2 ff ff       	call   80103b3d <mycpu>
8010791a:	89 c3                	mov    %eax,%ebx
8010791c:	e8 1c c2 ff ff       	call   80103b3d <mycpu>
80107921:	83 c0 08             	add    $0x8,%eax
80107924:	89 c6                	mov    %eax,%esi
80107926:	e8 12 c2 ff ff       	call   80103b3d <mycpu>
8010792b:	83 c0 08             	add    $0x8,%eax
8010792e:	c1 e8 10             	shr    $0x10,%eax
80107931:	88 45 f7             	mov    %al,-0x9(%ebp)
80107934:	e8 04 c2 ff ff       	call   80103b3d <mycpu>
80107939:	83 c0 08             	add    $0x8,%eax
8010793c:	c1 e8 18             	shr    $0x18,%eax
8010793f:	89 c2                	mov    %eax,%edx
80107941:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107948:	67 00 
8010794a:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107951:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107955:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010795b:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107962:	83 e0 f0             	and    $0xfffffff0,%eax
80107965:	83 c8 09             	or     $0x9,%eax
80107968:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010796e:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107975:	83 c8 10             	or     $0x10,%eax
80107978:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010797e:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107985:	83 e0 9f             	and    $0xffffff9f,%eax
80107988:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010798e:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107995:	83 c8 80             	or     $0xffffff80,%eax
80107998:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010799e:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079a5:	83 e0 f0             	and    $0xfffffff0,%eax
801079a8:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079ae:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079b5:	83 e0 ef             	and    $0xffffffef,%eax
801079b8:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079be:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079c5:	83 e0 df             	and    $0xffffffdf,%eax
801079c8:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079ce:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079d5:	83 c8 40             	or     $0x40,%eax
801079d8:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079de:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079e5:	83 e0 7f             	and    $0x7f,%eax
801079e8:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079ee:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801079f4:	e8 44 c1 ff ff       	call   80103b3d <mycpu>
801079f9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a00:	83 e2 ef             	and    $0xffffffef,%edx
80107a03:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107a09:	e8 2f c1 ff ff       	call   80103b3d <mycpu>
80107a0e:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107a14:	8b 45 08             	mov    0x8(%ebp),%eax
80107a17:	8b 40 08             	mov    0x8(%eax),%eax
80107a1a:	89 c3                	mov    %eax,%ebx
80107a1c:	e8 1c c1 ff ff       	call   80103b3d <mycpu>
80107a21:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107a27:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107a2a:	e8 0e c1 ff ff       	call   80103b3d <mycpu>
80107a2f:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107a35:	83 ec 0c             	sub    $0xc,%esp
80107a38:	6a 28                	push   $0x28
80107a3a:	e8 af f8 ff ff       	call   801072ee <ltr>
80107a3f:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107a42:	8b 45 08             	mov    0x8(%ebp),%eax
80107a45:	8b 40 04             	mov    0x4(%eax),%eax
80107a48:	05 00 00 00 80       	add    $0x80000000,%eax
80107a4d:	83 ec 0c             	sub    $0xc,%esp
80107a50:	50                   	push   %eax
80107a51:	e8 af f8 ff ff       	call   80107305 <lcr3>
80107a56:	83 c4 10             	add    $0x10,%esp
  popcli();
80107a59:	e8 ac d1 ff ff       	call   80104c0a <popcli>
}
80107a5e:	90                   	nop
80107a5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107a62:	5b                   	pop    %ebx
80107a63:	5e                   	pop    %esi
80107a64:	5d                   	pop    %ebp
80107a65:	c3                   	ret

80107a66 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107a66:	f3 0f 1e fb          	endbr32
80107a6a:	55                   	push   %ebp
80107a6b:	89 e5                	mov    %esp,%ebp
80107a6d:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107a70:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107a77:	76 0d                	jbe    80107a86 <inituvm+0x20>
    panic("inituvm: more than a page");
80107a79:	83 ec 0c             	sub    $0xc,%esp
80107a7c:	68 85 ac 10 80       	push   $0x8010ac85
80107a81:	e8 58 8b ff ff       	call   801005de <panic>
  mem = kalloc();
80107a86:	e8 17 ae ff ff       	call   801028a2 <kalloc>
80107a8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107a8e:	83 ec 04             	sub    $0x4,%esp
80107a91:	68 00 10 00 00       	push   $0x1000
80107a96:	6a 00                	push   $0x0
80107a98:	ff 75 f4             	push   -0xc(%ebp)
80107a9b:	e8 2c d2 ff ff       	call   80104ccc <memset>
80107aa0:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa6:	05 00 00 00 80       	add    $0x80000000,%eax
80107aab:	83 ec 0c             	sub    $0xc,%esp
80107aae:	6a 06                	push   $0x6
80107ab0:	50                   	push   %eax
80107ab1:	68 00 10 00 00       	push   $0x1000
80107ab6:	6a 00                	push   $0x0
80107ab8:	ff 75 08             	push   0x8(%ebp)
80107abb:	e8 45 fc ff ff       	call   80107705 <mappages>
80107ac0:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107ac3:	83 ec 04             	sub    $0x4,%esp
80107ac6:	ff 75 10             	push   0x10(%ebp)
80107ac9:	ff 75 0c             	push   0xc(%ebp)
80107acc:	ff 75 f4             	push   -0xc(%ebp)
80107acf:	e8 bf d2 ff ff       	call   80104d93 <memmove>
80107ad4:	83 c4 10             	add    $0x10,%esp
}
80107ad7:	90                   	nop
80107ad8:	c9                   	leave
80107ad9:	c3                   	ret

80107ada <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107ada:	f3 0f 1e fb          	endbr32
80107ade:	55                   	push   %ebp
80107adf:	89 e5                	mov    %esp,%ebp
80107ae1:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107ae4:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ae7:	25 ff 0f 00 00       	and    $0xfff,%eax
80107aec:	85 c0                	test   %eax,%eax
80107aee:	74 0d                	je     80107afd <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80107af0:	83 ec 0c             	sub    $0xc,%esp
80107af3:	68 a0 ac 10 80       	push   $0x8010aca0
80107af8:	e8 e1 8a ff ff       	call   801005de <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107afd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b04:	e9 8f 00 00 00       	jmp    80107b98 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107b09:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0f:	01 d0                	add    %edx,%eax
80107b11:	83 ec 04             	sub    $0x4,%esp
80107b14:	6a 00                	push   $0x0
80107b16:	50                   	push   %eax
80107b17:	ff 75 08             	push   0x8(%ebp)
80107b1a:	e8 4c fb ff ff       	call   8010766b <walkpgdir>
80107b1f:	83 c4 10             	add    $0x10,%esp
80107b22:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b25:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b29:	75 0d                	jne    80107b38 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107b2b:	83 ec 0c             	sub    $0xc,%esp
80107b2e:	68 c3 ac 10 80       	push   $0x8010acc3
80107b33:	e8 a6 8a ff ff       	call   801005de <panic>
    pa = PTE_ADDR(*pte);
80107b38:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b3b:	8b 00                	mov    (%eax),%eax
80107b3d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b42:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107b45:	8b 45 18             	mov    0x18(%ebp),%eax
80107b48:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b4b:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107b50:	77 0b                	ja     80107b5d <loaduvm+0x83>
      n = sz - i;
80107b52:	8b 45 18             	mov    0x18(%ebp),%eax
80107b55:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b58:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b5b:	eb 07                	jmp    80107b64 <loaduvm+0x8a>
    else
      n = PGSIZE;
80107b5d:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107b64:	8b 55 14             	mov    0x14(%ebp),%edx
80107b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6a:	01 d0                	add    %edx,%eax
80107b6c:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107b6f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107b75:	ff 75 f0             	push   -0x10(%ebp)
80107b78:	50                   	push   %eax
80107b79:	52                   	push   %edx
80107b7a:	ff 75 10             	push   0x10(%ebp)
80107b7d:	e8 12 a4 ff ff       	call   80101f94 <readi>
80107b82:	83 c4 10             	add    $0x10,%esp
80107b85:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107b88:	74 07                	je     80107b91 <loaduvm+0xb7>
      return -1;
80107b8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b8f:	eb 18                	jmp    80107ba9 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80107b91:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9b:	3b 45 18             	cmp    0x18(%ebp),%eax
80107b9e:	0f 82 65 ff ff ff    	jb     80107b09 <loaduvm+0x2f>
  }
  return 0;
80107ba4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ba9:	c9                   	leave
80107baa:	c3                   	ret

80107bab <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107bab:	f3 0f 1e fb          	endbr32
80107baf:	55                   	push   %ebp
80107bb0:	89 e5                	mov    %esp,%ebp
80107bb2:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107bb5:	8b 45 10             	mov    0x10(%ebp),%eax
80107bb8:	85 c0                	test   %eax,%eax
80107bba:	79 0a                	jns    80107bc6 <allocuvm+0x1b>
    return 0;
80107bbc:	b8 00 00 00 00       	mov    $0x0,%eax
80107bc1:	e9 ec 00 00 00       	jmp    80107cb2 <allocuvm+0x107>
  if(newsz < oldsz)
80107bc6:	8b 45 10             	mov    0x10(%ebp),%eax
80107bc9:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107bcc:	73 08                	jae    80107bd6 <allocuvm+0x2b>
    return oldsz;
80107bce:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bd1:	e9 dc 00 00 00       	jmp    80107cb2 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80107bd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bd9:	05 ff 0f 00 00       	add    $0xfff,%eax
80107bde:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107be3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107be6:	e9 b8 00 00 00       	jmp    80107ca3 <allocuvm+0xf8>
    mem = kalloc();
80107beb:	e8 b2 ac ff ff       	call   801028a2 <kalloc>
80107bf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107bf3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107bf7:	75 2e                	jne    80107c27 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80107bf9:	83 ec 0c             	sub    $0xc,%esp
80107bfc:	68 e1 ac 10 80       	push   $0x8010ace1
80107c01:	e8 06 88 ff ff       	call   8010040c <cprintf>
80107c06:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107c09:	83 ec 04             	sub    $0x4,%esp
80107c0c:	ff 75 0c             	push   0xc(%ebp)
80107c0f:	ff 75 10             	push   0x10(%ebp)
80107c12:	ff 75 08             	push   0x8(%ebp)
80107c15:	e8 9a 00 00 00       	call   80107cb4 <deallocuvm>
80107c1a:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c1d:	b8 00 00 00 00       	mov    $0x0,%eax
80107c22:	e9 8b 00 00 00       	jmp    80107cb2 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80107c27:	83 ec 04             	sub    $0x4,%esp
80107c2a:	68 00 10 00 00       	push   $0x1000
80107c2f:	6a 00                	push   $0x0
80107c31:	ff 75 f0             	push   -0x10(%ebp)
80107c34:	e8 93 d0 ff ff       	call   80104ccc <memset>
80107c39:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c3f:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c48:	83 ec 0c             	sub    $0xc,%esp
80107c4b:	6a 06                	push   $0x6
80107c4d:	52                   	push   %edx
80107c4e:	68 00 10 00 00       	push   $0x1000
80107c53:	50                   	push   %eax
80107c54:	ff 75 08             	push   0x8(%ebp)
80107c57:	e8 a9 fa ff ff       	call   80107705 <mappages>
80107c5c:	83 c4 20             	add    $0x20,%esp
80107c5f:	85 c0                	test   %eax,%eax
80107c61:	79 39                	jns    80107c9c <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80107c63:	83 ec 0c             	sub    $0xc,%esp
80107c66:	68 f9 ac 10 80       	push   $0x8010acf9
80107c6b:	e8 9c 87 ff ff       	call   8010040c <cprintf>
80107c70:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107c73:	83 ec 04             	sub    $0x4,%esp
80107c76:	ff 75 0c             	push   0xc(%ebp)
80107c79:	ff 75 10             	push   0x10(%ebp)
80107c7c:	ff 75 08             	push   0x8(%ebp)
80107c7f:	e8 30 00 00 00       	call   80107cb4 <deallocuvm>
80107c84:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107c87:	83 ec 0c             	sub    $0xc,%esp
80107c8a:	ff 75 f0             	push   -0x10(%ebp)
80107c8d:	e8 72 ab ff ff       	call   80102804 <kfree>
80107c92:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c95:	b8 00 00 00 00       	mov    $0x0,%eax
80107c9a:	eb 16                	jmp    80107cb2 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80107c9c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca6:	3b 45 10             	cmp    0x10(%ebp),%eax
80107ca9:	0f 82 3c ff ff ff    	jb     80107beb <allocuvm+0x40>
    }
  }
  return newsz;
80107caf:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107cb2:	c9                   	leave
80107cb3:	c3                   	ret

80107cb4 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107cb4:	f3 0f 1e fb          	endbr32
80107cb8:	55                   	push   %ebp
80107cb9:	89 e5                	mov    %esp,%ebp
80107cbb:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107cbe:	8b 45 10             	mov    0x10(%ebp),%eax
80107cc1:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107cc4:	72 08                	jb     80107cce <deallocuvm+0x1a>
    return oldsz;
80107cc6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cc9:	e9 ac 00 00 00       	jmp    80107d7a <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80107cce:	8b 45 10             	mov    0x10(%ebp),%eax
80107cd1:	05 ff 0f 00 00       	add    $0xfff,%eax
80107cd6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107cde:	e9 88 00 00 00       	jmp    80107d6b <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce6:	83 ec 04             	sub    $0x4,%esp
80107ce9:	6a 00                	push   $0x0
80107ceb:	50                   	push   %eax
80107cec:	ff 75 08             	push   0x8(%ebp)
80107cef:	e8 77 f9 ff ff       	call   8010766b <walkpgdir>
80107cf4:	83 c4 10             	add    $0x10,%esp
80107cf7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107cfa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107cfe:	75 16                	jne    80107d16 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d03:	c1 e8 16             	shr    $0x16,%eax
80107d06:	83 c0 01             	add    $0x1,%eax
80107d09:	c1 e0 16             	shl    $0x16,%eax
80107d0c:	2d 00 10 00 00       	sub    $0x1000,%eax
80107d11:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d14:	eb 4e                	jmp    80107d64 <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80107d16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d19:	8b 00                	mov    (%eax),%eax
80107d1b:	83 e0 01             	and    $0x1,%eax
80107d1e:	85 c0                	test   %eax,%eax
80107d20:	74 42                	je     80107d64 <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80107d22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d25:	8b 00                	mov    (%eax),%eax
80107d27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107d2f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d33:	75 0d                	jne    80107d42 <deallocuvm+0x8e>
        panic("kfree");
80107d35:	83 ec 0c             	sub    $0xc,%esp
80107d38:	68 15 ad 10 80       	push   $0x8010ad15
80107d3d:	e8 9c 88 ff ff       	call   801005de <panic>
      char *v = P2V(pa);
80107d42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d45:	05 00 00 00 80       	add    $0x80000000,%eax
80107d4a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107d4d:	83 ec 0c             	sub    $0xc,%esp
80107d50:	ff 75 e8             	push   -0x18(%ebp)
80107d53:	e8 ac aa ff ff       	call   80102804 <kfree>
80107d58:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d5e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107d64:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d71:	0f 82 6c ff ff ff    	jb     80107ce3 <deallocuvm+0x2f>
    }
  }
  return newsz;
80107d77:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107d7a:	c9                   	leave
80107d7b:	c3                   	ret

80107d7c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107d7c:	f3 0f 1e fb          	endbr32
80107d80:	55                   	push   %ebp
80107d81:	89 e5                	mov    %esp,%ebp
80107d83:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107d86:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107d8a:	75 0d                	jne    80107d99 <freevm+0x1d>
    panic("freevm: no pgdir");
80107d8c:	83 ec 0c             	sub    $0xc,%esp
80107d8f:	68 1b ad 10 80       	push   $0x8010ad1b
80107d94:	e8 45 88 ff ff       	call   801005de <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107d99:	83 ec 04             	sub    $0x4,%esp
80107d9c:	6a 00                	push   $0x0
80107d9e:	68 00 00 00 80       	push   $0x80000000
80107da3:	ff 75 08             	push   0x8(%ebp)
80107da6:	e8 09 ff ff ff       	call   80107cb4 <deallocuvm>
80107dab:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107dae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107db5:	eb 48                	jmp    80107dff <freevm+0x83>
    if(pgdir[i] & PTE_P){
80107db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80107dc4:	01 d0                	add    %edx,%eax
80107dc6:	8b 00                	mov    (%eax),%eax
80107dc8:	83 e0 01             	and    $0x1,%eax
80107dcb:	85 c0                	test   %eax,%eax
80107dcd:	74 2c                	je     80107dfb <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80107ddc:	01 d0                	add    %edx,%eax
80107dde:	8b 00                	mov    (%eax),%eax
80107de0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107de5:	05 00 00 00 80       	add    $0x80000000,%eax
80107dea:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107ded:	83 ec 0c             	sub    $0xc,%esp
80107df0:	ff 75 f0             	push   -0x10(%ebp)
80107df3:	e8 0c aa ff ff       	call   80102804 <kfree>
80107df8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107dfb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107dff:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107e06:	76 af                	jbe    80107db7 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80107e08:	83 ec 0c             	sub    $0xc,%esp
80107e0b:	ff 75 08             	push   0x8(%ebp)
80107e0e:	e8 f1 a9 ff ff       	call   80102804 <kfree>
80107e13:	83 c4 10             	add    $0x10,%esp
}
80107e16:	90                   	nop
80107e17:	c9                   	leave
80107e18:	c3                   	ret

80107e19 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107e19:	f3 0f 1e fb          	endbr32
80107e1d:	55                   	push   %ebp
80107e1e:	89 e5                	mov    %esp,%ebp
80107e20:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107e23:	83 ec 04             	sub    $0x4,%esp
80107e26:	6a 00                	push   $0x0
80107e28:	ff 75 0c             	push   0xc(%ebp)
80107e2b:	ff 75 08             	push   0x8(%ebp)
80107e2e:	e8 38 f8 ff ff       	call   8010766b <walkpgdir>
80107e33:	83 c4 10             	add    $0x10,%esp
80107e36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107e39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e3d:	75 0d                	jne    80107e4c <clearpteu+0x33>
    panic("clearpteu");
80107e3f:	83 ec 0c             	sub    $0xc,%esp
80107e42:	68 2c ad 10 80       	push   $0x8010ad2c
80107e47:	e8 92 87 ff ff       	call   801005de <panic>
  *pte &= ~PTE_U;
80107e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4f:	8b 00                	mov    (%eax),%eax
80107e51:	83 e0 fb             	and    $0xfffffffb,%eax
80107e54:	89 c2                	mov    %eax,%edx
80107e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e59:	89 10                	mov    %edx,(%eax)
}
80107e5b:	90                   	nop
80107e5c:	c9                   	leave
80107e5d:	c3                   	ret

80107e5e <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107e5e:	f3 0f 1e fb          	endbr32
80107e62:	55                   	push   %ebp
80107e63:	89 e5                	mov    %esp,%ebp
80107e65:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;
  
  if((d = setupkvm()) == 0)
80107e68:	e8 2c f9 ff ff       	call   80107799 <setupkvm>
80107e6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e70:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e74:	75 0a                	jne    80107e80 <copyuvm+0x22>
    return 0;
80107e76:	b8 00 00 00 00       	mov    $0x0,%eax
80107e7b:	e9 d6 00 00 00       	jmp    80107f56 <copyuvm+0xf8>
    // 스택을 힙 영역으로 옮겼으니 힙 영역까지의 페이지 복사
    // text, data 영역 0xb98까지 stack 영역 0xb98+ 2*PGSIZE까지
    // heap 영역 stack영역 위부터 kernbase까지
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107e80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e87:	e9 a3 00 00 00       	jmp    80107f2f <copyuvm+0xd1>
    
    // 스택을 힙 영역의 맨 위에 할당했기 때문에 kernbase까지 복사를 해야하는데
    // 할당되지 않은 페이지, 유효하지 않은 페이지는 복사하지 않고 지나감
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8f:	83 ec 04             	sub    $0x4,%esp
80107e92:	6a 00                	push   $0x0
80107e94:	50                   	push   %eax
80107e95:	ff 75 08             	push   0x8(%ebp)
80107e98:	e8 ce f7 ff ff       	call   8010766b <walkpgdir>
80107e9d:	83 c4 10             	add    $0x10,%esp
80107ea0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ea3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ea7:	74 7b                	je     80107f24 <copyuvm+0xc6>
      continue;
    if(!(*pte & PTE_P)){
80107ea9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107eac:	8b 00                	mov    (%eax),%eax
80107eae:	83 e0 01             	and    $0x1,%eax
80107eb1:	85 c0                	test   %eax,%eax
80107eb3:	74 72                	je     80107f27 <copyuvm+0xc9>
      continue;
    }
    // PTE_ADDR 페이지 테이블 엔트리에서 물리 주소 부분
    // PTE_FLAGS flag 부분 추출
    pa = PTE_ADDR(*pte);
80107eb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107eb8:	8b 00                	mov    (%eax),%eax
80107eba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ebf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107ec2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ec5:	8b 00                	mov    (%eax),%eax
80107ec7:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ecc:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 페이지를 복사할 물리 주소 할당
    if((mem = kalloc()) == 0)
80107ecf:	e8 ce a9 ff ff       	call   801028a2 <kalloc>
80107ed4:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107ed7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107edb:	74 62                	je     80107f3f <copyuvm+0xe1>
      goto bad;
    // 현재 페이지의 물리 주소인 pa를  mem에 복사
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107edd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ee0:	05 00 00 00 80       	add    $0x80000000,%eax
80107ee5:	83 ec 04             	sub    $0x4,%esp
80107ee8:	68 00 10 00 00       	push   $0x1000
80107eed:	50                   	push   %eax
80107eee:	ff 75 e0             	push   -0x20(%ebp)
80107ef1:	e8 9d ce ff ff       	call   80104d93 <memmove>
80107ef6:	83 c4 10             	add    $0x10,%esp
    // 현재 가상주소에 복사받은 mem을 매핑
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107ef9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107efc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107eff:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f08:	83 ec 0c             	sub    $0xc,%esp
80107f0b:	52                   	push   %edx
80107f0c:	51                   	push   %ecx
80107f0d:	68 00 10 00 00       	push   $0x1000
80107f12:	50                   	push   %eax
80107f13:	ff 75 f0             	push   -0x10(%ebp)
80107f16:	e8 ea f7 ff ff       	call   80107705 <mappages>
80107f1b:	83 c4 20             	add    $0x20,%esp
80107f1e:	85 c0                	test   %eax,%eax
80107f20:	78 20                	js     80107f42 <copyuvm+0xe4>
80107f22:	eb 04                	jmp    80107f28 <copyuvm+0xca>
      continue;
80107f24:	90                   	nop
80107f25:	eb 01                	jmp    80107f28 <copyuvm+0xca>
      continue;
80107f27:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107f28:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f32:	85 c0                	test   %eax,%eax
80107f34:	0f 89 52 ff ff ff    	jns    80107e8c <copyuvm+0x2e>
      goto bad;
  }  
  return d;
80107f3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f3d:	eb 17                	jmp    80107f56 <copyuvm+0xf8>
      goto bad;
80107f3f:	90                   	nop
80107f40:	eb 01                	jmp    80107f43 <copyuvm+0xe5>
      goto bad;
80107f42:	90                   	nop

bad:
  freevm(d);
80107f43:	83 ec 0c             	sub    $0xc,%esp
80107f46:	ff 75 f0             	push   -0x10(%ebp)
80107f49:	e8 2e fe ff ff       	call   80107d7c <freevm>
80107f4e:	83 c4 10             	add    $0x10,%esp
  return 0;
80107f51:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f56:	c9                   	leave
80107f57:	c3                   	ret

80107f58 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107f58:	f3 0f 1e fb          	endbr32
80107f5c:	55                   	push   %ebp
80107f5d:	89 e5                	mov    %esp,%ebp
80107f5f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107f62:	83 ec 04             	sub    $0x4,%esp
80107f65:	6a 00                	push   $0x0
80107f67:	ff 75 0c             	push   0xc(%ebp)
80107f6a:	ff 75 08             	push   0x8(%ebp)
80107f6d:	e8 f9 f6 ff ff       	call   8010766b <walkpgdir>
80107f72:	83 c4 10             	add    $0x10,%esp
80107f75:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7b:	8b 00                	mov    (%eax),%eax
80107f7d:	83 e0 01             	and    $0x1,%eax
80107f80:	85 c0                	test   %eax,%eax
80107f82:	75 07                	jne    80107f8b <uva2ka+0x33>
    return 0;
80107f84:	b8 00 00 00 00       	mov    $0x0,%eax
80107f89:	eb 22                	jmp    80107fad <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
80107f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8e:	8b 00                	mov    (%eax),%eax
80107f90:	83 e0 04             	and    $0x4,%eax
80107f93:	85 c0                	test   %eax,%eax
80107f95:	75 07                	jne    80107f9e <uva2ka+0x46>
    return 0;
80107f97:	b8 00 00 00 00       	mov    $0x0,%eax
80107f9c:	eb 0f                	jmp    80107fad <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
80107f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa1:	8b 00                	mov    (%eax),%eax
80107fa3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fa8:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107fad:	c9                   	leave
80107fae:	c3                   	ret

80107faf <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107faf:	f3 0f 1e fb          	endbr32
80107fb3:	55                   	push   %ebp
80107fb4:	89 e5                	mov    %esp,%ebp
80107fb6:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107fb9:	8b 45 10             	mov    0x10(%ebp),%eax
80107fbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107fbf:	eb 7f                	jmp    80108040 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80107fc1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fc4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fc9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107fcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fcf:	83 ec 08             	sub    $0x8,%esp
80107fd2:	50                   	push   %eax
80107fd3:	ff 75 08             	push   0x8(%ebp)
80107fd6:	e8 7d ff ff ff       	call   80107f58 <uva2ka>
80107fdb:	83 c4 10             	add    $0x10,%esp
80107fde:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107fe1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107fe5:	75 07                	jne    80107fee <copyout+0x3f>
      return -1;
80107fe7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fec:	eb 61                	jmp    8010804f <copyout+0xa0>
    n = PGSIZE - (va - va0);
80107fee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ff1:	2b 45 0c             	sub    0xc(%ebp),%eax
80107ff4:	05 00 10 00 00       	add    $0x1000,%eax
80107ff9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fff:	3b 45 14             	cmp    0x14(%ebp),%eax
80108002:	76 06                	jbe    8010800a <copyout+0x5b>
      n = len;
80108004:	8b 45 14             	mov    0x14(%ebp),%eax
80108007:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010800a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010800d:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108010:	89 c2                	mov    %eax,%edx
80108012:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108015:	01 d0                	add    %edx,%eax
80108017:	83 ec 04             	sub    $0x4,%esp
8010801a:	ff 75 f0             	push   -0x10(%ebp)
8010801d:	ff 75 f4             	push   -0xc(%ebp)
80108020:	50                   	push   %eax
80108021:	e8 6d cd ff ff       	call   80104d93 <memmove>
80108026:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108029:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010802c:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010802f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108032:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108035:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108038:	05 00 10 00 00       	add    $0x1000,%eax
8010803d:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108040:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108044:	0f 85 77 ff ff ff    	jne    80107fc1 <copyout+0x12>
  }
  return 0;
8010804a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010804f:	c9                   	leave
80108050:	c3                   	ret

80108051 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108051:	f3 0f 1e fb          	endbr32
80108055:	55                   	push   %ebp
80108056:	89 e5                	mov    %esp,%ebp
80108058:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010805b:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108062:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108065:	8b 40 08             	mov    0x8(%eax),%eax
80108068:	05 00 00 00 80       	add    $0x80000000,%eax
8010806d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108070:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010807a:	8b 40 24             	mov    0x24(%eax),%eax
8010807d:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
80108082:	c7 05 80 80 19 80 00 	movl   $0x0,0x80198080
80108089:	00 00 00 

  while(i<madt->len){
8010808c:	90                   	nop
8010808d:	e9 be 00 00 00       	jmp    80108150 <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
80108092:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108095:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108098:	01 d0                	add    %edx,%eax
8010809a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
8010809d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080a0:	0f b6 00             	movzbl (%eax),%eax
801080a3:	0f b6 c0             	movzbl %al,%eax
801080a6:	83 f8 05             	cmp    $0x5,%eax
801080a9:	0f 87 a1 00 00 00    	ja     80108150 <mpinit_uefi+0xff>
801080af:	8b 04 85 38 ad 10 80 	mov    -0x7fef52c8(,%eax,4),%eax
801080b6:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801080b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801080bf:	a1 80 80 19 80       	mov    0x80198080,%eax
801080c4:	83 f8 03             	cmp    $0x3,%eax
801080c7:	7f 28                	jg     801080f1 <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801080c9:	8b 15 80 80 19 80    	mov    0x80198080,%edx
801080cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080d2:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801080d6:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
801080dc:	81 c2 c0 7d 19 80    	add    $0x80197dc0,%edx
801080e2:	88 02                	mov    %al,(%edx)
          ncpu++;
801080e4:	a1 80 80 19 80       	mov    0x80198080,%eax
801080e9:	83 c0 01             	add    $0x1,%eax
801080ec:	a3 80 80 19 80       	mov    %eax,0x80198080
        }
        i += lapic_entry->record_len;
801080f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801080f4:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801080f8:	0f b6 c0             	movzbl %al,%eax
801080fb:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801080fe:	eb 50                	jmp    80108150 <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108100:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108103:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108106:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108109:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010810d:	a2 a0 7d 19 80       	mov    %al,0x80197da0
        i += ioapic->record_len;
80108112:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108115:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108119:	0f b6 c0             	movzbl %al,%eax
8010811c:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010811f:	eb 2f                	jmp    80108150 <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108121:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108124:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108127:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010812a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010812e:	0f b6 c0             	movzbl %al,%eax
80108131:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108134:	eb 1a                	jmp    80108150 <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108139:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
8010813c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010813f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108143:	0f b6 c0             	movzbl %al,%eax
80108146:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108149:	eb 05                	jmp    80108150 <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
8010814b:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
8010814f:	90                   	nop
  while(i<madt->len){
80108150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108153:	8b 40 04             	mov    0x4(%eax),%eax
80108156:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108159:	0f 82 33 ff ff ff    	jb     80108092 <mpinit_uefi+0x41>
    }
  }

}
8010815f:	90                   	nop
80108160:	90                   	nop
80108161:	c9                   	leave
80108162:	c3                   	ret

80108163 <inb>:
{
80108163:	55                   	push   %ebp
80108164:	89 e5                	mov    %esp,%ebp
80108166:	83 ec 14             	sub    $0x14,%esp
80108169:	8b 45 08             	mov    0x8(%ebp),%eax
8010816c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108170:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108174:	89 c2                	mov    %eax,%edx
80108176:	ec                   	in     (%dx),%al
80108177:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010817a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010817e:	c9                   	leave
8010817f:	c3                   	ret

80108180 <outb>:
{
80108180:	55                   	push   %ebp
80108181:	89 e5                	mov    %esp,%ebp
80108183:	83 ec 08             	sub    $0x8,%esp
80108186:	8b 45 08             	mov    0x8(%ebp),%eax
80108189:	8b 55 0c             	mov    0xc(%ebp),%edx
8010818c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108190:	89 d0                	mov    %edx,%eax
80108192:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108195:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108199:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010819d:	ee                   	out    %al,(%dx)
}
8010819e:	90                   	nop
8010819f:	c9                   	leave
801081a0:	c3                   	ret

801081a1 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801081a1:	f3 0f 1e fb          	endbr32
801081a5:	55                   	push   %ebp
801081a6:	89 e5                	mov    %esp,%ebp
801081a8:	83 ec 28             	sub    $0x28,%esp
801081ab:	8b 45 08             	mov    0x8(%ebp),%eax
801081ae:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801081b1:	6a 00                	push   $0x0
801081b3:	68 fa 03 00 00       	push   $0x3fa
801081b8:	e8 c3 ff ff ff       	call   80108180 <outb>
801081bd:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801081c0:	68 80 00 00 00       	push   $0x80
801081c5:	68 fb 03 00 00       	push   $0x3fb
801081ca:	e8 b1 ff ff ff       	call   80108180 <outb>
801081cf:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801081d2:	6a 0c                	push   $0xc
801081d4:	68 f8 03 00 00       	push   $0x3f8
801081d9:	e8 a2 ff ff ff       	call   80108180 <outb>
801081de:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801081e1:	6a 00                	push   $0x0
801081e3:	68 f9 03 00 00       	push   $0x3f9
801081e8:	e8 93 ff ff ff       	call   80108180 <outb>
801081ed:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801081f0:	6a 03                	push   $0x3
801081f2:	68 fb 03 00 00       	push   $0x3fb
801081f7:	e8 84 ff ff ff       	call   80108180 <outb>
801081fc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801081ff:	6a 00                	push   $0x0
80108201:	68 fc 03 00 00       	push   $0x3fc
80108206:	e8 75 ff ff ff       	call   80108180 <outb>
8010820b:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010820e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108215:	eb 11                	jmp    80108228 <uart_debug+0x87>
80108217:	83 ec 0c             	sub    $0xc,%esp
8010821a:	6a 0a                	push   $0xa
8010821c:	e8 33 aa ff ff       	call   80102c54 <microdelay>
80108221:	83 c4 10             	add    $0x10,%esp
80108224:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108228:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010822c:	7f 1a                	jg     80108248 <uart_debug+0xa7>
8010822e:	83 ec 0c             	sub    $0xc,%esp
80108231:	68 fd 03 00 00       	push   $0x3fd
80108236:	e8 28 ff ff ff       	call   80108163 <inb>
8010823b:	83 c4 10             	add    $0x10,%esp
8010823e:	0f b6 c0             	movzbl %al,%eax
80108241:	83 e0 20             	and    $0x20,%eax
80108244:	85 c0                	test   %eax,%eax
80108246:	74 cf                	je     80108217 <uart_debug+0x76>
  outb(COM1+0, p);
80108248:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010824c:	0f b6 c0             	movzbl %al,%eax
8010824f:	83 ec 08             	sub    $0x8,%esp
80108252:	50                   	push   %eax
80108253:	68 f8 03 00 00       	push   $0x3f8
80108258:	e8 23 ff ff ff       	call   80108180 <outb>
8010825d:	83 c4 10             	add    $0x10,%esp
}
80108260:	90                   	nop
80108261:	c9                   	leave
80108262:	c3                   	ret

80108263 <uart_debugs>:

void uart_debugs(char *p){
80108263:	f3 0f 1e fb          	endbr32
80108267:	55                   	push   %ebp
80108268:	89 e5                	mov    %esp,%ebp
8010826a:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010826d:	eb 1b                	jmp    8010828a <uart_debugs+0x27>
    uart_debug(*p++);
8010826f:	8b 45 08             	mov    0x8(%ebp),%eax
80108272:	8d 50 01             	lea    0x1(%eax),%edx
80108275:	89 55 08             	mov    %edx,0x8(%ebp)
80108278:	0f b6 00             	movzbl (%eax),%eax
8010827b:	0f be c0             	movsbl %al,%eax
8010827e:	83 ec 0c             	sub    $0xc,%esp
80108281:	50                   	push   %eax
80108282:	e8 1a ff ff ff       	call   801081a1 <uart_debug>
80108287:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010828a:	8b 45 08             	mov    0x8(%ebp),%eax
8010828d:	0f b6 00             	movzbl (%eax),%eax
80108290:	84 c0                	test   %al,%al
80108292:	75 db                	jne    8010826f <uart_debugs+0xc>
  }
}
80108294:	90                   	nop
80108295:	90                   	nop
80108296:	c9                   	leave
80108297:	c3                   	ret

80108298 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108298:	f3 0f 1e fb          	endbr32
8010829c:	55                   	push   %ebp
8010829d:	89 e5                	mov    %esp,%ebp
8010829f:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801082a2:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801082a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082ac:	8b 50 14             	mov    0x14(%eax),%edx
801082af:	8b 40 10             	mov    0x10(%eax),%eax
801082b2:	a3 84 80 19 80       	mov    %eax,0x80198084
  gpu.vram_size = boot_param->graphic_config.frame_size;
801082b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082ba:	8b 50 1c             	mov    0x1c(%eax),%edx
801082bd:	8b 40 18             	mov    0x18(%eax),%eax
801082c0:	a3 8c 80 19 80       	mov    %eax,0x8019808c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801082c5:	a1 8c 80 19 80       	mov    0x8019808c,%eax
801082ca:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801082cf:	29 c2                	sub    %eax,%edx
801082d1:	89 d0                	mov    %edx,%eax
801082d3:	a3 88 80 19 80       	mov    %eax,0x80198088
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801082d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082db:	8b 50 24             	mov    0x24(%eax),%edx
801082de:	8b 40 20             	mov    0x20(%eax),%eax
801082e1:	a3 90 80 19 80       	mov    %eax,0x80198090
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801082e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082e9:	8b 50 2c             	mov    0x2c(%eax),%edx
801082ec:	8b 40 28             	mov    0x28(%eax),%eax
801082ef:	a3 94 80 19 80       	mov    %eax,0x80198094
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801082f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082f7:	8b 50 34             	mov    0x34(%eax),%edx
801082fa:	8b 40 30             	mov    0x30(%eax),%eax
801082fd:	a3 98 80 19 80       	mov    %eax,0x80198098
}
80108302:	90                   	nop
80108303:	c9                   	leave
80108304:	c3                   	ret

80108305 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108305:	f3 0f 1e fb          	endbr32
80108309:	55                   	push   %ebp
8010830a:	89 e5                	mov    %esp,%ebp
8010830c:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
8010830f:	8b 15 98 80 19 80    	mov    0x80198098,%edx
80108315:	8b 45 0c             	mov    0xc(%ebp),%eax
80108318:	0f af d0             	imul   %eax,%edx
8010831b:	8b 45 08             	mov    0x8(%ebp),%eax
8010831e:	01 d0                	add    %edx,%eax
80108320:	c1 e0 02             	shl    $0x2,%eax
80108323:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108326:	8b 15 88 80 19 80    	mov    0x80198088,%edx
8010832c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010832f:	01 d0                	add    %edx,%eax
80108331:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108334:	8b 45 10             	mov    0x10(%ebp),%eax
80108337:	0f b6 10             	movzbl (%eax),%edx
8010833a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010833d:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
8010833f:	8b 45 10             	mov    0x10(%ebp),%eax
80108342:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108346:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108349:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010834c:	8b 45 10             	mov    0x10(%ebp),%eax
8010834f:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108353:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108356:	88 50 02             	mov    %dl,0x2(%eax)
}
80108359:	90                   	nop
8010835a:	c9                   	leave
8010835b:	c3                   	ret

8010835c <graphic_scroll_up>:

void graphic_scroll_up(int height){
8010835c:	f3 0f 1e fb          	endbr32
80108360:	55                   	push   %ebp
80108361:	89 e5                	mov    %esp,%ebp
80108363:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108366:	8b 15 98 80 19 80    	mov    0x80198098,%edx
8010836c:	8b 45 08             	mov    0x8(%ebp),%eax
8010836f:	0f af c2             	imul   %edx,%eax
80108372:	c1 e0 02             	shl    $0x2,%eax
80108375:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108378:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
8010837e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108381:	29 c2                	sub    %eax,%edx
80108383:	89 d0                	mov    %edx,%eax
80108385:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
8010838b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010838e:	01 ca                	add    %ecx,%edx
80108390:	89 d1                	mov    %edx,%ecx
80108392:	8b 15 88 80 19 80    	mov    0x80198088,%edx
80108398:	83 ec 04             	sub    $0x4,%esp
8010839b:	50                   	push   %eax
8010839c:	51                   	push   %ecx
8010839d:	52                   	push   %edx
8010839e:	e8 f0 c9 ff ff       	call   80104d93 <memmove>
801083a3:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801083a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a9:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
801083af:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
801083b5:	01 d1                	add    %edx,%ecx
801083b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083ba:	29 d1                	sub    %edx,%ecx
801083bc:	89 ca                	mov    %ecx,%edx
801083be:	83 ec 04             	sub    $0x4,%esp
801083c1:	50                   	push   %eax
801083c2:	6a 00                	push   $0x0
801083c4:	52                   	push   %edx
801083c5:	e8 02 c9 ff ff       	call   80104ccc <memset>
801083ca:	83 c4 10             	add    $0x10,%esp
}
801083cd:	90                   	nop
801083ce:	c9                   	leave
801083cf:	c3                   	ret

801083d0 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801083d0:	f3 0f 1e fb          	endbr32
801083d4:	55                   	push   %ebp
801083d5:	89 e5                	mov    %esp,%ebp
801083d7:	53                   	push   %ebx
801083d8:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801083db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083e2:	e9 b1 00 00 00       	jmp    80108498 <font_render+0xc8>
    for(int j=14;j>-1;j--){
801083e7:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801083ee:	e9 97 00 00 00       	jmp    8010848a <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
801083f3:	8b 45 10             	mov    0x10(%ebp),%eax
801083f6:	83 e8 20             	sub    $0x20,%eax
801083f9:	6b d0 1e             	imul   $0x1e,%eax,%edx
801083fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ff:	01 d0                	add    %edx,%eax
80108401:	0f b7 84 00 60 ad 10 	movzwl -0x7fef52a0(%eax,%eax,1),%eax
80108408:	80 
80108409:	0f b7 d0             	movzwl %ax,%edx
8010840c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010840f:	bb 01 00 00 00       	mov    $0x1,%ebx
80108414:	89 c1                	mov    %eax,%ecx
80108416:	d3 e3                	shl    %cl,%ebx
80108418:	89 d8                	mov    %ebx,%eax
8010841a:	21 d0                	and    %edx,%eax
8010841c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
8010841f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108422:	ba 01 00 00 00       	mov    $0x1,%edx
80108427:	89 c1                	mov    %eax,%ecx
80108429:	d3 e2                	shl    %cl,%edx
8010842b:	89 d0                	mov    %edx,%eax
8010842d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108430:	75 2b                	jne    8010845d <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108432:	8b 55 0c             	mov    0xc(%ebp),%edx
80108435:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108438:	01 c2                	add    %eax,%edx
8010843a:	b8 0e 00 00 00       	mov    $0xe,%eax
8010843f:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108442:	89 c1                	mov    %eax,%ecx
80108444:	8b 45 08             	mov    0x8(%ebp),%eax
80108447:	01 c8                	add    %ecx,%eax
80108449:	83 ec 04             	sub    $0x4,%esp
8010844c:	68 e0 f4 10 80       	push   $0x8010f4e0
80108451:	52                   	push   %edx
80108452:	50                   	push   %eax
80108453:	e8 ad fe ff ff       	call   80108305 <graphic_draw_pixel>
80108458:	83 c4 10             	add    $0x10,%esp
8010845b:	eb 29                	jmp    80108486 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010845d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108463:	01 c2                	add    %eax,%edx
80108465:	b8 0e 00 00 00       	mov    $0xe,%eax
8010846a:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010846d:	89 c1                	mov    %eax,%ecx
8010846f:	8b 45 08             	mov    0x8(%ebp),%eax
80108472:	01 c8                	add    %ecx,%eax
80108474:	83 ec 04             	sub    $0x4,%esp
80108477:	68 64 d0 18 80       	push   $0x8018d064
8010847c:	52                   	push   %edx
8010847d:	50                   	push   %eax
8010847e:	e8 82 fe ff ff       	call   80108305 <graphic_draw_pixel>
80108483:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108486:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010848a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010848e:	0f 89 5f ff ff ff    	jns    801083f3 <font_render+0x23>
  for(int i=0;i<30;i++){
80108494:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108498:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010849c:	0f 8e 45 ff ff ff    	jle    801083e7 <font_render+0x17>
      }
    }
  }
}
801084a2:	90                   	nop
801084a3:	90                   	nop
801084a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084a7:	c9                   	leave
801084a8:	c3                   	ret

801084a9 <font_render_string>:

void font_render_string(char *string,int row){
801084a9:	f3 0f 1e fb          	endbr32
801084ad:	55                   	push   %ebp
801084ae:	89 e5                	mov    %esp,%ebp
801084b0:	53                   	push   %ebx
801084b1:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801084b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801084bb:	eb 33                	jmp    801084f0 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
801084bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084c0:	8b 45 08             	mov    0x8(%ebp),%eax
801084c3:	01 d0                	add    %edx,%eax
801084c5:	0f b6 00             	movzbl (%eax),%eax
801084c8:	0f be d8             	movsbl %al,%ebx
801084cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801084ce:	6b c8 1e             	imul   $0x1e,%eax,%ecx
801084d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084d4:	89 d0                	mov    %edx,%eax
801084d6:	c1 e0 04             	shl    $0x4,%eax
801084d9:	29 d0                	sub    %edx,%eax
801084db:	83 c0 02             	add    $0x2,%eax
801084de:	83 ec 04             	sub    $0x4,%esp
801084e1:	53                   	push   %ebx
801084e2:	51                   	push   %ecx
801084e3:	50                   	push   %eax
801084e4:	e8 e7 fe ff ff       	call   801083d0 <font_render>
801084e9:	83 c4 10             	add    $0x10,%esp
    i++;
801084ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801084f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084f3:	8b 45 08             	mov    0x8(%ebp),%eax
801084f6:	01 d0                	add    %edx,%eax
801084f8:	0f b6 00             	movzbl (%eax),%eax
801084fb:	84 c0                	test   %al,%al
801084fd:	74 06                	je     80108505 <font_render_string+0x5c>
801084ff:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108503:	7e b8                	jle    801084bd <font_render_string+0x14>
  }
}
80108505:	90                   	nop
80108506:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108509:	c9                   	leave
8010850a:	c3                   	ret

8010850b <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010850b:	f3 0f 1e fb          	endbr32
8010850f:	55                   	push   %ebp
80108510:	89 e5                	mov    %esp,%ebp
80108512:	53                   	push   %ebx
80108513:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108516:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010851d:	eb 6b                	jmp    8010858a <pci_init+0x7f>
    for(int j=0;j<32;j++){
8010851f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108526:	eb 58                	jmp    80108580 <pci_init+0x75>
      for(int k=0;k<8;k++){
80108528:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010852f:	eb 45                	jmp    80108576 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
80108531:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108534:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853a:	83 ec 0c             	sub    $0xc,%esp
8010853d:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108540:	53                   	push   %ebx
80108541:	6a 00                	push   $0x0
80108543:	51                   	push   %ecx
80108544:	52                   	push   %edx
80108545:	50                   	push   %eax
80108546:	e8 c0 00 00 00       	call   8010860b <pci_access_config>
8010854b:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010854e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108551:	0f b7 c0             	movzwl %ax,%eax
80108554:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108559:	74 17                	je     80108572 <pci_init+0x67>
        pci_init_device(i,j,k);
8010855b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010855e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108564:	83 ec 04             	sub    $0x4,%esp
80108567:	51                   	push   %ecx
80108568:	52                   	push   %edx
80108569:	50                   	push   %eax
8010856a:	e8 4f 01 00 00       	call   801086be <pci_init_device>
8010856f:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108572:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108576:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010857a:	7e b5                	jle    80108531 <pci_init+0x26>
    for(int j=0;j<32;j++){
8010857c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108580:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108584:	7e a2                	jle    80108528 <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108586:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010858a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108591:	7e 8c                	jle    8010851f <pci_init+0x14>
      }
      }
    }
  }
}
80108593:	90                   	nop
80108594:	90                   	nop
80108595:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108598:	c9                   	leave
80108599:	c3                   	ret

8010859a <pci_write_config>:

void pci_write_config(uint config){
8010859a:	f3 0f 1e fb          	endbr32
8010859e:	55                   	push   %ebp
8010859f:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801085a1:	8b 45 08             	mov    0x8(%ebp),%eax
801085a4:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801085a9:	89 c0                	mov    %eax,%eax
801085ab:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801085ac:	90                   	nop
801085ad:	5d                   	pop    %ebp
801085ae:	c3                   	ret

801085af <pci_write_data>:

void pci_write_data(uint config){
801085af:	f3 0f 1e fb          	endbr32
801085b3:	55                   	push   %ebp
801085b4:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801085b6:	8b 45 08             	mov    0x8(%ebp),%eax
801085b9:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801085be:	89 c0                	mov    %eax,%eax
801085c0:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801085c1:	90                   	nop
801085c2:	5d                   	pop    %ebp
801085c3:	c3                   	ret

801085c4 <pci_read_config>:
uint pci_read_config(){
801085c4:	f3 0f 1e fb          	endbr32
801085c8:	55                   	push   %ebp
801085c9:	89 e5                	mov    %esp,%ebp
801085cb:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801085ce:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801085d3:	ed                   	in     (%dx),%eax
801085d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801085d7:	83 ec 0c             	sub    $0xc,%esp
801085da:	68 c8 00 00 00       	push   $0xc8
801085df:	e8 70 a6 ff ff       	call   80102c54 <microdelay>
801085e4:	83 c4 10             	add    $0x10,%esp
  return data;
801085e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801085ea:	c9                   	leave
801085eb:	c3                   	ret

801085ec <pci_test>:


void pci_test(){
801085ec:	f3 0f 1e fb          	endbr32
801085f0:	55                   	push   %ebp
801085f1:	89 e5                	mov    %esp,%ebp
801085f3:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801085f6:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801085fd:	ff 75 fc             	push   -0x4(%ebp)
80108600:	e8 95 ff ff ff       	call   8010859a <pci_write_config>
80108605:	83 c4 04             	add    $0x4,%esp
}
80108608:	90                   	nop
80108609:	c9                   	leave
8010860a:	c3                   	ret

8010860b <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
8010860b:	f3 0f 1e fb          	endbr32
8010860f:	55                   	push   %ebp
80108610:	89 e5                	mov    %esp,%ebp
80108612:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108615:	8b 45 08             	mov    0x8(%ebp),%eax
80108618:	c1 e0 10             	shl    $0x10,%eax
8010861b:	25 00 00 ff 00       	and    $0xff0000,%eax
80108620:	89 c2                	mov    %eax,%edx
80108622:	8b 45 0c             	mov    0xc(%ebp),%eax
80108625:	c1 e0 0b             	shl    $0xb,%eax
80108628:	0f b7 c0             	movzwl %ax,%eax
8010862b:	09 c2                	or     %eax,%edx
8010862d:	8b 45 10             	mov    0x10(%ebp),%eax
80108630:	c1 e0 08             	shl    $0x8,%eax
80108633:	25 00 07 00 00       	and    $0x700,%eax
80108638:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010863a:	8b 45 14             	mov    0x14(%ebp),%eax
8010863d:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108642:	09 d0                	or     %edx,%eax
80108644:	0d 00 00 00 80       	or     $0x80000000,%eax
80108649:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
8010864c:	ff 75 f4             	push   -0xc(%ebp)
8010864f:	e8 46 ff ff ff       	call   8010859a <pci_write_config>
80108654:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108657:	e8 68 ff ff ff       	call   801085c4 <pci_read_config>
8010865c:	8b 55 18             	mov    0x18(%ebp),%edx
8010865f:	89 02                	mov    %eax,(%edx)
}
80108661:	90                   	nop
80108662:	c9                   	leave
80108663:	c3                   	ret

80108664 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108664:	f3 0f 1e fb          	endbr32
80108668:	55                   	push   %ebp
80108669:	89 e5                	mov    %esp,%ebp
8010866b:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010866e:	8b 45 08             	mov    0x8(%ebp),%eax
80108671:	c1 e0 10             	shl    $0x10,%eax
80108674:	25 00 00 ff 00       	and    $0xff0000,%eax
80108679:	89 c2                	mov    %eax,%edx
8010867b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010867e:	c1 e0 0b             	shl    $0xb,%eax
80108681:	0f b7 c0             	movzwl %ax,%eax
80108684:	09 c2                	or     %eax,%edx
80108686:	8b 45 10             	mov    0x10(%ebp),%eax
80108689:	c1 e0 08             	shl    $0x8,%eax
8010868c:	25 00 07 00 00       	and    $0x700,%eax
80108691:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108693:	8b 45 14             	mov    0x14(%ebp),%eax
80108696:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010869b:	09 d0                	or     %edx,%eax
8010869d:	0d 00 00 00 80       	or     $0x80000000,%eax
801086a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801086a5:	ff 75 fc             	push   -0x4(%ebp)
801086a8:	e8 ed fe ff ff       	call   8010859a <pci_write_config>
801086ad:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801086b0:	ff 75 18             	push   0x18(%ebp)
801086b3:	e8 f7 fe ff ff       	call   801085af <pci_write_data>
801086b8:	83 c4 04             	add    $0x4,%esp
}
801086bb:	90                   	nop
801086bc:	c9                   	leave
801086bd:	c3                   	ret

801086be <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801086be:	f3 0f 1e fb          	endbr32
801086c2:	55                   	push   %ebp
801086c3:	89 e5                	mov    %esp,%ebp
801086c5:	53                   	push   %ebx
801086c6:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801086c9:	8b 45 08             	mov    0x8(%ebp),%eax
801086cc:	a2 9c 80 19 80       	mov    %al,0x8019809c
  dev.device_num = device_num;
801086d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801086d4:	a2 9d 80 19 80       	mov    %al,0x8019809d
  dev.function_num = function_num;
801086d9:	8b 45 10             	mov    0x10(%ebp),%eax
801086dc:	a2 9e 80 19 80       	mov    %al,0x8019809e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801086e1:	ff 75 10             	push   0x10(%ebp)
801086e4:	ff 75 0c             	push   0xc(%ebp)
801086e7:	ff 75 08             	push   0x8(%ebp)
801086ea:	68 a4 c3 10 80       	push   $0x8010c3a4
801086ef:	e8 18 7d ff ff       	call   8010040c <cprintf>
801086f4:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801086f7:	83 ec 0c             	sub    $0xc,%esp
801086fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
801086fd:	50                   	push   %eax
801086fe:	6a 00                	push   $0x0
80108700:	ff 75 10             	push   0x10(%ebp)
80108703:	ff 75 0c             	push   0xc(%ebp)
80108706:	ff 75 08             	push   0x8(%ebp)
80108709:	e8 fd fe ff ff       	call   8010860b <pci_access_config>
8010870e:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108711:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108714:	c1 e8 10             	shr    $0x10,%eax
80108717:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
8010871a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010871d:	25 ff ff 00 00       	and    $0xffff,%eax
80108722:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108728:	a3 a0 80 19 80       	mov    %eax,0x801980a0
  dev.vendor_id = vendor_id;
8010872d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108730:	a3 a4 80 19 80       	mov    %eax,0x801980a4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108735:	83 ec 04             	sub    $0x4,%esp
80108738:	ff 75 f0             	push   -0x10(%ebp)
8010873b:	ff 75 f4             	push   -0xc(%ebp)
8010873e:	68 d8 c3 10 80       	push   $0x8010c3d8
80108743:	e8 c4 7c ff ff       	call   8010040c <cprintf>
80108748:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010874b:	83 ec 0c             	sub    $0xc,%esp
8010874e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108751:	50                   	push   %eax
80108752:	6a 08                	push   $0x8
80108754:	ff 75 10             	push   0x10(%ebp)
80108757:	ff 75 0c             	push   0xc(%ebp)
8010875a:	ff 75 08             	push   0x8(%ebp)
8010875d:	e8 a9 fe ff ff       	call   8010860b <pci_access_config>
80108762:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108765:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108768:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010876b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010876e:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108771:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108774:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108777:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010877a:	0f b6 c0             	movzbl %al,%eax
8010877d:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108780:	c1 eb 18             	shr    $0x18,%ebx
80108783:	83 ec 0c             	sub    $0xc,%esp
80108786:	51                   	push   %ecx
80108787:	52                   	push   %edx
80108788:	50                   	push   %eax
80108789:	53                   	push   %ebx
8010878a:	68 fc c3 10 80       	push   $0x8010c3fc
8010878f:	e8 78 7c ff ff       	call   8010040c <cprintf>
80108794:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108797:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010879a:	c1 e8 18             	shr    $0x18,%eax
8010879d:	a2 a8 80 19 80       	mov    %al,0x801980a8
  dev.sub_class = (data>>16)&0xFF;
801087a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087a5:	c1 e8 10             	shr    $0x10,%eax
801087a8:	a2 a9 80 19 80       	mov    %al,0x801980a9
  dev.interface = (data>>8)&0xFF;
801087ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087b0:	c1 e8 08             	shr    $0x8,%eax
801087b3:	a2 aa 80 19 80       	mov    %al,0x801980aa
  dev.revision_id = data&0xFF;
801087b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087bb:	a2 ab 80 19 80       	mov    %al,0x801980ab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801087c0:	83 ec 0c             	sub    $0xc,%esp
801087c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087c6:	50                   	push   %eax
801087c7:	6a 10                	push   $0x10
801087c9:	ff 75 10             	push   0x10(%ebp)
801087cc:	ff 75 0c             	push   0xc(%ebp)
801087cf:	ff 75 08             	push   0x8(%ebp)
801087d2:	e8 34 fe ff ff       	call   8010860b <pci_access_config>
801087d7:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801087da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087dd:	a3 ac 80 19 80       	mov    %eax,0x801980ac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801087e2:	83 ec 0c             	sub    $0xc,%esp
801087e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087e8:	50                   	push   %eax
801087e9:	6a 14                	push   $0x14
801087eb:	ff 75 10             	push   0x10(%ebp)
801087ee:	ff 75 0c             	push   0xc(%ebp)
801087f1:	ff 75 08             	push   0x8(%ebp)
801087f4:	e8 12 fe ff ff       	call   8010860b <pci_access_config>
801087f9:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801087fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087ff:	a3 b0 80 19 80       	mov    %eax,0x801980b0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108804:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
8010880b:	75 5a                	jne    80108867 <pci_init_device+0x1a9>
8010880d:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108814:	75 51                	jne    80108867 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
80108816:	83 ec 0c             	sub    $0xc,%esp
80108819:	68 41 c4 10 80       	push   $0x8010c441
8010881e:	e8 e9 7b ff ff       	call   8010040c <cprintf>
80108823:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108826:	83 ec 0c             	sub    $0xc,%esp
80108829:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010882c:	50                   	push   %eax
8010882d:	68 f0 00 00 00       	push   $0xf0
80108832:	ff 75 10             	push   0x10(%ebp)
80108835:	ff 75 0c             	push   0xc(%ebp)
80108838:	ff 75 08             	push   0x8(%ebp)
8010883b:	e8 cb fd ff ff       	call   8010860b <pci_access_config>
80108840:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108843:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108846:	83 ec 08             	sub    $0x8,%esp
80108849:	50                   	push   %eax
8010884a:	68 5b c4 10 80       	push   $0x8010c45b
8010884f:	e8 b8 7b ff ff       	call   8010040c <cprintf>
80108854:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108857:	83 ec 0c             	sub    $0xc,%esp
8010885a:	68 9c 80 19 80       	push   $0x8019809c
8010885f:	e8 09 00 00 00       	call   8010886d <i8254_init>
80108864:	83 c4 10             	add    $0x10,%esp
  }
}
80108867:	90                   	nop
80108868:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010886b:	c9                   	leave
8010886c:	c3                   	ret

8010886d <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
8010886d:	f3 0f 1e fb          	endbr32
80108871:	55                   	push   %ebp
80108872:	89 e5                	mov    %esp,%ebp
80108874:	53                   	push   %ebx
80108875:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108878:	8b 45 08             	mov    0x8(%ebp),%eax
8010887b:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010887f:	0f b6 c8             	movzbl %al,%ecx
80108882:	8b 45 08             	mov    0x8(%ebp),%eax
80108885:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108889:	0f b6 d0             	movzbl %al,%edx
8010888c:	8b 45 08             	mov    0x8(%ebp),%eax
8010888f:	0f b6 00             	movzbl (%eax),%eax
80108892:	0f b6 c0             	movzbl %al,%eax
80108895:	83 ec 0c             	sub    $0xc,%esp
80108898:	8d 5d ec             	lea    -0x14(%ebp),%ebx
8010889b:	53                   	push   %ebx
8010889c:	6a 04                	push   $0x4
8010889e:	51                   	push   %ecx
8010889f:	52                   	push   %edx
801088a0:	50                   	push   %eax
801088a1:	e8 65 fd ff ff       	call   8010860b <pci_access_config>
801088a6:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801088a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088ac:	83 c8 04             	or     $0x4,%eax
801088af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
801088b2:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801088b5:	8b 45 08             	mov    0x8(%ebp),%eax
801088b8:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801088bc:	0f b6 c8             	movzbl %al,%ecx
801088bf:	8b 45 08             	mov    0x8(%ebp),%eax
801088c2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801088c6:	0f b6 d0             	movzbl %al,%edx
801088c9:	8b 45 08             	mov    0x8(%ebp),%eax
801088cc:	0f b6 00             	movzbl (%eax),%eax
801088cf:	0f b6 c0             	movzbl %al,%eax
801088d2:	83 ec 0c             	sub    $0xc,%esp
801088d5:	53                   	push   %ebx
801088d6:	6a 04                	push   $0x4
801088d8:	51                   	push   %ecx
801088d9:	52                   	push   %edx
801088da:	50                   	push   %eax
801088db:	e8 84 fd ff ff       	call   80108664 <pci_write_config_register>
801088e0:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801088e3:	8b 45 08             	mov    0x8(%ebp),%eax
801088e6:	8b 40 10             	mov    0x10(%eax),%eax
801088e9:	05 00 00 00 40       	add    $0x40000000,%eax
801088ee:	a3 b4 80 19 80       	mov    %eax,0x801980b4
  uint *ctrl = (uint *)base_addr;
801088f3:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801088f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801088fb:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108900:	05 d8 00 00 00       	add    $0xd8,%eax
80108905:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108908:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010890b:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108914:	8b 00                	mov    (%eax),%eax
80108916:	0d 00 00 00 04       	or     $0x4000000,%eax
8010891b:	89 c2                	mov    %eax,%edx
8010891d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108920:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108922:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108925:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
8010892b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010892e:	8b 00                	mov    (%eax),%eax
80108930:	83 c8 40             	or     $0x40,%eax
80108933:	89 c2                	mov    %eax,%edx
80108935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108938:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
8010893a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893d:	8b 10                	mov    (%eax),%edx
8010893f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108942:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108944:	83 ec 0c             	sub    $0xc,%esp
80108947:	68 70 c4 10 80       	push   $0x8010c470
8010894c:	e8 bb 7a ff ff       	call   8010040c <cprintf>
80108951:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108954:	e8 49 9f ff ff       	call   801028a2 <kalloc>
80108959:	a3 b8 80 19 80       	mov    %eax,0x801980b8
  *intr_addr = 0;
8010895e:	a1 b8 80 19 80       	mov    0x801980b8,%eax
80108963:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108969:	a1 b8 80 19 80       	mov    0x801980b8,%eax
8010896e:	83 ec 08             	sub    $0x8,%esp
80108971:	50                   	push   %eax
80108972:	68 92 c4 10 80       	push   $0x8010c492
80108977:	e8 90 7a ff ff       	call   8010040c <cprintf>
8010897c:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
8010897f:	e8 50 00 00 00       	call   801089d4 <i8254_init_recv>
  i8254_init_send();
80108984:	e8 6d 03 00 00       	call   80108cf6 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108989:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108990:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108993:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010899a:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
8010899d:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801089a4:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
801089a7:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801089ae:	0f b6 c0             	movzbl %al,%eax
801089b1:	83 ec 0c             	sub    $0xc,%esp
801089b4:	53                   	push   %ebx
801089b5:	51                   	push   %ecx
801089b6:	52                   	push   %edx
801089b7:	50                   	push   %eax
801089b8:	68 a0 c4 10 80       	push   $0x8010c4a0
801089bd:	e8 4a 7a ff ff       	call   8010040c <cprintf>
801089c2:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801089c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089c8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801089ce:	90                   	nop
801089cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801089d2:	c9                   	leave
801089d3:	c3                   	ret

801089d4 <i8254_init_recv>:

void i8254_init_recv(){
801089d4:	f3 0f 1e fb          	endbr32
801089d8:	55                   	push   %ebp
801089d9:	89 e5                	mov    %esp,%ebp
801089db:	57                   	push   %edi
801089dc:	56                   	push   %esi
801089dd:	53                   	push   %ebx
801089de:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801089e1:	83 ec 0c             	sub    $0xc,%esp
801089e4:	6a 00                	push   $0x0
801089e6:	e8 ec 04 00 00       	call   80108ed7 <i8254_read_eeprom>
801089eb:	83 c4 10             	add    $0x10,%esp
801089ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801089f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
801089f4:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
801089f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801089fc:	c1 e8 08             	shr    $0x8,%eax
801089ff:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
80108a04:	83 ec 0c             	sub    $0xc,%esp
80108a07:	6a 01                	push   $0x1
80108a09:	e8 c9 04 00 00       	call   80108ed7 <i8254_read_eeprom>
80108a0e:	83 c4 10             	add    $0x10,%esp
80108a11:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108a14:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a17:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
80108a1c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a1f:	c1 e8 08             	shr    $0x8,%eax
80108a22:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
80108a27:	83 ec 0c             	sub    $0xc,%esp
80108a2a:	6a 02                	push   $0x2
80108a2c:	e8 a6 04 00 00       	call   80108ed7 <i8254_read_eeprom>
80108a31:	83 c4 10             	add    $0x10,%esp
80108a34:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108a37:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a3a:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
80108a3f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a42:	c1 e8 08             	shr    $0x8,%eax
80108a45:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108a4a:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a51:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108a54:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a5b:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108a5e:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a65:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108a68:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a6f:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108a72:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a79:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108a7c:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a83:	0f b6 c0             	movzbl %al,%eax
80108a86:	83 ec 04             	sub    $0x4,%esp
80108a89:	57                   	push   %edi
80108a8a:	56                   	push   %esi
80108a8b:	53                   	push   %ebx
80108a8c:	51                   	push   %ecx
80108a8d:	52                   	push   %edx
80108a8e:	50                   	push   %eax
80108a8f:	68 b8 c4 10 80       	push   $0x8010c4b8
80108a94:	e8 73 79 ff ff       	call   8010040c <cprintf>
80108a99:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108a9c:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108aa1:	05 00 54 00 00       	add    $0x5400,%eax
80108aa6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108aa9:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108aae:	05 04 54 00 00       	add    $0x5404,%eax
80108ab3:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108ab6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108ab9:	c1 e0 10             	shl    $0x10,%eax
80108abc:	0b 45 d8             	or     -0x28(%ebp),%eax
80108abf:	89 c2                	mov    %eax,%edx
80108ac1:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108ac4:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108ac6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ac9:	0d 00 00 00 80       	or     $0x80000000,%eax
80108ace:	89 c2                	mov    %eax,%edx
80108ad0:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108ad3:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108ad5:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ada:	05 00 52 00 00       	add    $0x5200,%eax
80108adf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108ae2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108ae9:	eb 19                	jmp    80108b04 <i8254_init_recv+0x130>
    mta[i] = 0;
80108aeb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108aee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108af5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108af8:	01 d0                	add    %edx,%eax
80108afa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108b00:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108b04:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108b08:	7e e1                	jle    80108aeb <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108b0a:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b0f:	05 d0 00 00 00       	add    $0xd0,%eax
80108b14:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108b17:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108b1a:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108b20:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b25:	05 c8 00 00 00       	add    $0xc8,%eax
80108b2a:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108b2d:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108b30:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108b36:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b3b:	05 28 28 00 00       	add    $0x2828,%eax
80108b40:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108b43:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108b46:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108b4c:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b51:	05 00 01 00 00       	add    $0x100,%eax
80108b56:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108b59:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108b5c:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108b62:	e8 3b 9d ff ff       	call   801028a2 <kalloc>
80108b67:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108b6a:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b6f:	05 00 28 00 00       	add    $0x2800,%eax
80108b74:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108b77:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b7c:	05 04 28 00 00       	add    $0x2804,%eax
80108b81:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108b84:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b89:	05 08 28 00 00       	add    $0x2808,%eax
80108b8e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108b91:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b96:	05 10 28 00 00       	add    $0x2810,%eax
80108b9b:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108b9e:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ba3:	05 18 28 00 00       	add    $0x2818,%eax
80108ba8:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108bab:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108bae:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108bb4:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108bb7:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108bb9:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108bbc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108bc2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108bc5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108bcb:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108bce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108bd4:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108bd7:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108bdd:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108be0:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108be3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108bea:	eb 73                	jmp    80108c5f <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108bec:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bef:	c1 e0 04             	shl    $0x4,%eax
80108bf2:	89 c2                	mov    %eax,%edx
80108bf4:	8b 45 98             	mov    -0x68(%ebp),%eax
80108bf7:	01 d0                	add    %edx,%eax
80108bf9:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108c00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c03:	c1 e0 04             	shl    $0x4,%eax
80108c06:	89 c2                	mov    %eax,%edx
80108c08:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c0b:	01 d0                	add    %edx,%eax
80108c0d:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108c13:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c16:	c1 e0 04             	shl    $0x4,%eax
80108c19:	89 c2                	mov    %eax,%edx
80108c1b:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c1e:	01 d0                	add    %edx,%eax
80108c20:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108c26:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c29:	c1 e0 04             	shl    $0x4,%eax
80108c2c:	89 c2                	mov    %eax,%edx
80108c2e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c31:	01 d0                	add    %edx,%eax
80108c33:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108c37:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c3a:	c1 e0 04             	shl    $0x4,%eax
80108c3d:	89 c2                	mov    %eax,%edx
80108c3f:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c42:	01 d0                	add    %edx,%eax
80108c44:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108c48:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c4b:	c1 e0 04             	shl    $0x4,%eax
80108c4e:	89 c2                	mov    %eax,%edx
80108c50:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c53:	01 d0                	add    %edx,%eax
80108c55:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108c5b:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108c5f:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108c66:	7e 84                	jle    80108bec <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108c68:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108c6f:	eb 57                	jmp    80108cc8 <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80108c71:	e8 2c 9c ff ff       	call   801028a2 <kalloc>
80108c76:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108c79:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108c7d:	75 12                	jne    80108c91 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80108c7f:	83 ec 0c             	sub    $0xc,%esp
80108c82:	68 d8 c4 10 80       	push   $0x8010c4d8
80108c87:	e8 80 77 ff ff       	call   8010040c <cprintf>
80108c8c:	83 c4 10             	add    $0x10,%esp
      break;
80108c8f:	eb 3d                	jmp    80108cce <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108c91:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c94:	c1 e0 04             	shl    $0x4,%eax
80108c97:	89 c2                	mov    %eax,%edx
80108c99:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c9c:	01 d0                	add    %edx,%eax
80108c9e:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108ca1:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108ca7:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108ca9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108cac:	83 c0 01             	add    $0x1,%eax
80108caf:	c1 e0 04             	shl    $0x4,%eax
80108cb2:	89 c2                	mov    %eax,%edx
80108cb4:	8b 45 98             	mov    -0x68(%ebp),%eax
80108cb7:	01 d0                	add    %edx,%eax
80108cb9:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108cbc:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108cc2:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108cc4:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108cc8:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108ccc:	7e a3                	jle    80108c71 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80108cce:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108cd1:	8b 00                	mov    (%eax),%eax
80108cd3:	83 c8 02             	or     $0x2,%eax
80108cd6:	89 c2                	mov    %eax,%edx
80108cd8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108cdb:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108cdd:	83 ec 0c             	sub    $0xc,%esp
80108ce0:	68 f8 c4 10 80       	push   $0x8010c4f8
80108ce5:	e8 22 77 ff ff       	call   8010040c <cprintf>
80108cea:	83 c4 10             	add    $0x10,%esp
}
80108ced:	90                   	nop
80108cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108cf1:	5b                   	pop    %ebx
80108cf2:	5e                   	pop    %esi
80108cf3:	5f                   	pop    %edi
80108cf4:	5d                   	pop    %ebp
80108cf5:	c3                   	ret

80108cf6 <i8254_init_send>:

void i8254_init_send(){
80108cf6:	f3 0f 1e fb          	endbr32
80108cfa:	55                   	push   %ebp
80108cfb:	89 e5                	mov    %esp,%ebp
80108cfd:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108d00:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d05:	05 28 38 00 00       	add    $0x3828,%eax
80108d0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108d0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d10:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108d16:	e8 87 9b ff ff       	call   801028a2 <kalloc>
80108d1b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108d1e:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d23:	05 00 38 00 00       	add    $0x3800,%eax
80108d28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108d2b:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d30:	05 04 38 00 00       	add    $0x3804,%eax
80108d35:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108d38:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d3d:	05 08 38 00 00       	add    $0x3808,%eax
80108d42:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108d45:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d48:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108d4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d51:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108d53:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d56:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108d5c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108d5f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108d65:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d6a:	05 10 38 00 00       	add    $0x3810,%eax
80108d6f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108d72:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d77:	05 18 38 00 00       	add    $0x3818,%eax
80108d7c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108d7f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108d82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108d88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d8b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108d91:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d94:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108d97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d9e:	e9 82 00 00 00       	jmp    80108e25 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80108da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da6:	c1 e0 04             	shl    $0x4,%eax
80108da9:	89 c2                	mov    %eax,%edx
80108dab:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dae:	01 d0                	add    %edx,%eax
80108db0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dba:	c1 e0 04             	shl    $0x4,%eax
80108dbd:	89 c2                	mov    %eax,%edx
80108dbf:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dc2:	01 d0                	add    %edx,%eax
80108dc4:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dcd:	c1 e0 04             	shl    $0x4,%eax
80108dd0:	89 c2                	mov    %eax,%edx
80108dd2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dd5:	01 d0                	add    %edx,%eax
80108dd7:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dde:	c1 e0 04             	shl    $0x4,%eax
80108de1:	89 c2                	mov    %eax,%edx
80108de3:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108de6:	01 d0                	add    %edx,%eax
80108de8:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108def:	c1 e0 04             	shl    $0x4,%eax
80108df2:	89 c2                	mov    %eax,%edx
80108df4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108df7:	01 d0                	add    %edx,%eax
80108df9:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e00:	c1 e0 04             	shl    $0x4,%eax
80108e03:	89 c2                	mov    %eax,%edx
80108e05:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e08:	01 d0                	add    %edx,%eax
80108e0a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e11:	c1 e0 04             	shl    $0x4,%eax
80108e14:	89 c2                	mov    %eax,%edx
80108e16:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e19:	01 d0                	add    %edx,%eax
80108e1b:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108e21:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108e25:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108e2c:	0f 8e 71 ff ff ff    	jle    80108da3 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108e32:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108e39:	eb 57                	jmp    80108e92 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80108e3b:	e8 62 9a ff ff       	call   801028a2 <kalloc>
80108e40:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108e43:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108e47:	75 12                	jne    80108e5b <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80108e49:	83 ec 0c             	sub    $0xc,%esp
80108e4c:	68 d8 c4 10 80       	push   $0x8010c4d8
80108e51:	e8 b6 75 ff ff       	call   8010040c <cprintf>
80108e56:	83 c4 10             	add    $0x10,%esp
      break;
80108e59:	eb 3d                	jmp    80108e98 <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108e5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e5e:	c1 e0 04             	shl    $0x4,%eax
80108e61:	89 c2                	mov    %eax,%edx
80108e63:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e66:	01 d0                	add    %edx,%eax
80108e68:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108e6b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108e71:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108e73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e76:	83 c0 01             	add    $0x1,%eax
80108e79:	c1 e0 04             	shl    $0x4,%eax
80108e7c:	89 c2                	mov    %eax,%edx
80108e7e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e81:	01 d0                	add    %edx,%eax
80108e83:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108e86:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108e8c:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108e8e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108e92:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108e96:	7e a3                	jle    80108e3b <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108e98:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108e9d:	05 00 04 00 00       	add    $0x400,%eax
80108ea2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108ea5:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108ea8:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108eae:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108eb3:	05 10 04 00 00       	add    $0x410,%eax
80108eb8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108ebb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108ebe:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108ec4:	83 ec 0c             	sub    $0xc,%esp
80108ec7:	68 18 c5 10 80       	push   $0x8010c518
80108ecc:	e8 3b 75 ff ff       	call   8010040c <cprintf>
80108ed1:	83 c4 10             	add    $0x10,%esp

}
80108ed4:	90                   	nop
80108ed5:	c9                   	leave
80108ed6:	c3                   	ret

80108ed7 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108ed7:	f3 0f 1e fb          	endbr32
80108edb:	55                   	push   %ebp
80108edc:	89 e5                	mov    %esp,%ebp
80108ede:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108ee1:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ee6:	83 c0 14             	add    $0x14,%eax
80108ee9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108eec:	8b 45 08             	mov    0x8(%ebp),%eax
80108eef:	c1 e0 08             	shl    $0x8,%eax
80108ef2:	0f b7 c0             	movzwl %ax,%eax
80108ef5:	83 c8 01             	or     $0x1,%eax
80108ef8:	89 c2                	mov    %eax,%edx
80108efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108efd:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108eff:	83 ec 0c             	sub    $0xc,%esp
80108f02:	68 38 c5 10 80       	push   $0x8010c538
80108f07:	e8 00 75 ff ff       	call   8010040c <cprintf>
80108f0c:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f12:	8b 00                	mov    (%eax),%eax
80108f14:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108f17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f1a:	83 e0 10             	and    $0x10,%eax
80108f1d:	85 c0                	test   %eax,%eax
80108f1f:	75 02                	jne    80108f23 <i8254_read_eeprom+0x4c>
  while(1){
80108f21:	eb dc                	jmp    80108eff <i8254_read_eeprom+0x28>
      break;
80108f23:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f27:	8b 00                	mov    (%eax),%eax
80108f29:	c1 e8 10             	shr    $0x10,%eax
}
80108f2c:	c9                   	leave
80108f2d:	c3                   	ret

80108f2e <i8254_recv>:
void i8254_recv(){
80108f2e:	f3 0f 1e fb          	endbr32
80108f32:	55                   	push   %ebp
80108f33:	89 e5                	mov    %esp,%ebp
80108f35:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108f38:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f3d:	05 10 28 00 00       	add    $0x2810,%eax
80108f42:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108f45:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f4a:	05 18 28 00 00       	add    $0x2818,%eax
80108f4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108f52:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f57:	05 00 28 00 00       	add    $0x2800,%eax
80108f5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108f5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f62:	8b 00                	mov    (%eax),%eax
80108f64:	05 00 00 00 80       	add    $0x80000000,%eax
80108f69:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f6f:	8b 10                	mov    (%eax),%edx
80108f71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f74:	8b 00                	mov    (%eax),%eax
80108f76:	29 c2                	sub    %eax,%edx
80108f78:	89 d0                	mov    %edx,%eax
80108f7a:	25 ff 00 00 00       	and    $0xff,%eax
80108f7f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108f82:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108f86:	7e 37                	jle    80108fbf <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108f88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f8b:	8b 00                	mov    (%eax),%eax
80108f8d:	c1 e0 04             	shl    $0x4,%eax
80108f90:	89 c2                	mov    %eax,%edx
80108f92:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f95:	01 d0                	add    %edx,%eax
80108f97:	8b 00                	mov    (%eax),%eax
80108f99:	05 00 00 00 80       	add    $0x80000000,%eax
80108f9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fa4:	8b 00                	mov    (%eax),%eax
80108fa6:	83 c0 01             	add    $0x1,%eax
80108fa9:	0f b6 d0             	movzbl %al,%edx
80108fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108faf:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108fb1:	83 ec 0c             	sub    $0xc,%esp
80108fb4:	ff 75 e0             	push   -0x20(%ebp)
80108fb7:	e8 47 09 00 00       	call   80109903 <eth_proc>
80108fbc:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108fbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fc2:	8b 10                	mov    (%eax),%edx
80108fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fc7:	8b 00                	mov    (%eax),%eax
80108fc9:	39 c2                	cmp    %eax,%edx
80108fcb:	75 9f                	jne    80108f6c <i8254_recv+0x3e>
      (*rdt)--;
80108fcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fd0:	8b 00                	mov    (%eax),%eax
80108fd2:	8d 50 ff             	lea    -0x1(%eax),%edx
80108fd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fd8:	89 10                	mov    %edx,(%eax)
  while(1){
80108fda:	eb 90                	jmp    80108f6c <i8254_recv+0x3e>

80108fdc <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108fdc:	f3 0f 1e fb          	endbr32
80108fe0:	55                   	push   %ebp
80108fe1:	89 e5                	mov    %esp,%ebp
80108fe3:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108fe6:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108feb:	05 10 38 00 00       	add    $0x3810,%eax
80108ff0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108ff3:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ff8:	05 18 38 00 00       	add    $0x3818,%eax
80108ffd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109000:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80109005:	05 00 38 00 00       	add    $0x3800,%eax
8010900a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
8010900d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109010:	8b 00                	mov    (%eax),%eax
80109012:	05 00 00 00 80       	add    $0x80000000,%eax
80109017:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
8010901a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010901d:	8b 10                	mov    (%eax),%edx
8010901f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109022:	8b 00                	mov    (%eax),%eax
80109024:	29 c2                	sub    %eax,%edx
80109026:	89 d0                	mov    %edx,%eax
80109028:	0f b6 c0             	movzbl %al,%eax
8010902b:	ba 00 01 00 00       	mov    $0x100,%edx
80109030:	29 c2                	sub    %eax,%edx
80109032:	89 d0                	mov    %edx,%eax
80109034:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80109037:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010903a:	8b 00                	mov    (%eax),%eax
8010903c:	25 ff 00 00 00       	and    $0xff,%eax
80109041:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80109044:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109048:	0f 8e a8 00 00 00    	jle    801090f6 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
8010904e:	8b 45 08             	mov    0x8(%ebp),%eax
80109051:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109054:	89 d1                	mov    %edx,%ecx
80109056:	c1 e1 04             	shl    $0x4,%ecx
80109059:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010905c:	01 ca                	add    %ecx,%edx
8010905e:	8b 12                	mov    (%edx),%edx
80109060:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109066:	83 ec 04             	sub    $0x4,%esp
80109069:	ff 75 0c             	push   0xc(%ebp)
8010906c:	50                   	push   %eax
8010906d:	52                   	push   %edx
8010906e:	e8 20 bd ff ff       	call   80104d93 <memmove>
80109073:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109076:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109079:	c1 e0 04             	shl    $0x4,%eax
8010907c:	89 c2                	mov    %eax,%edx
8010907e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109081:	01 d0                	add    %edx,%eax
80109083:	8b 55 0c             	mov    0xc(%ebp),%edx
80109086:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
8010908a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010908d:	c1 e0 04             	shl    $0x4,%eax
80109090:	89 c2                	mov    %eax,%edx
80109092:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109095:	01 d0                	add    %edx,%eax
80109097:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
8010909b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010909e:	c1 e0 04             	shl    $0x4,%eax
801090a1:	89 c2                	mov    %eax,%edx
801090a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090a6:	01 d0                	add    %edx,%eax
801090a8:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801090ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090af:	c1 e0 04             	shl    $0x4,%eax
801090b2:	89 c2                	mov    %eax,%edx
801090b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090b7:	01 d0                	add    %edx,%eax
801090b9:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801090bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090c0:	c1 e0 04             	shl    $0x4,%eax
801090c3:	89 c2                	mov    %eax,%edx
801090c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090c8:	01 d0                	add    %edx,%eax
801090ca:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
801090d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090d3:	c1 e0 04             	shl    $0x4,%eax
801090d6:	89 c2                	mov    %eax,%edx
801090d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090db:	01 d0                	add    %edx,%eax
801090dd:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
801090e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090e4:	8b 00                	mov    (%eax),%eax
801090e6:	83 c0 01             	add    $0x1,%eax
801090e9:	0f b6 d0             	movzbl %al,%edx
801090ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090ef:	89 10                	mov    %edx,(%eax)
    return len;
801090f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801090f4:	eb 05                	jmp    801090fb <i8254_send+0x11f>
  }else{
    return -1;
801090f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801090fb:	c9                   	leave
801090fc:	c3                   	ret

801090fd <i8254_intr>:

void i8254_intr(){
801090fd:	f3 0f 1e fb          	endbr32
80109101:	55                   	push   %ebp
80109102:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109104:	a1 b8 80 19 80       	mov    0x801980b8,%eax
80109109:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
8010910f:	90                   	nop
80109110:	5d                   	pop    %ebp
80109111:	c3                   	ret

80109112 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109112:	f3 0f 1e fb          	endbr32
80109116:	55                   	push   %ebp
80109117:	89 e5                	mov    %esp,%ebp
80109119:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
8010911c:	8b 45 08             	mov    0x8(%ebp),%eax
8010911f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109125:	0f b7 00             	movzwl (%eax),%eax
80109128:	66 3d 00 01          	cmp    $0x100,%ax
8010912c:	74 0a                	je     80109138 <arp_proc+0x26>
8010912e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109133:	e9 4f 01 00 00       	jmp    80109287 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010913b:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010913f:	66 83 f8 08          	cmp    $0x8,%ax
80109143:	74 0a                	je     8010914f <arp_proc+0x3d>
80109145:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010914a:	e9 38 01 00 00       	jmp    80109287 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
8010914f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109152:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109156:	3c 06                	cmp    $0x6,%al
80109158:	74 0a                	je     80109164 <arp_proc+0x52>
8010915a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010915f:	e9 23 01 00 00       	jmp    80109287 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80109164:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109167:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010916b:	3c 04                	cmp    $0x4,%al
8010916d:	74 0a                	je     80109179 <arp_proc+0x67>
8010916f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109174:	e9 0e 01 00 00       	jmp    80109287 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010917c:	83 c0 18             	add    $0x18,%eax
8010917f:	83 ec 04             	sub    $0x4,%esp
80109182:	6a 04                	push   $0x4
80109184:	50                   	push   %eax
80109185:	68 e4 f4 10 80       	push   $0x8010f4e4
8010918a:	e8 a8 bb ff ff       	call   80104d37 <memcmp>
8010918f:	83 c4 10             	add    $0x10,%esp
80109192:	85 c0                	test   %eax,%eax
80109194:	74 27                	je     801091bd <arp_proc+0xab>
80109196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109199:	83 c0 0e             	add    $0xe,%eax
8010919c:	83 ec 04             	sub    $0x4,%esp
8010919f:	6a 04                	push   $0x4
801091a1:	50                   	push   %eax
801091a2:	68 e4 f4 10 80       	push   $0x8010f4e4
801091a7:	e8 8b bb ff ff       	call   80104d37 <memcmp>
801091ac:	83 c4 10             	add    $0x10,%esp
801091af:	85 c0                	test   %eax,%eax
801091b1:	74 0a                	je     801091bd <arp_proc+0xab>
801091b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091b8:	e9 ca 00 00 00       	jmp    80109287 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801091bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c0:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801091c4:	66 3d 00 01          	cmp    $0x100,%ax
801091c8:	75 69                	jne    80109233 <arp_proc+0x121>
801091ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091cd:	83 c0 18             	add    $0x18,%eax
801091d0:	83 ec 04             	sub    $0x4,%esp
801091d3:	6a 04                	push   $0x4
801091d5:	50                   	push   %eax
801091d6:	68 e4 f4 10 80       	push   $0x8010f4e4
801091db:	e8 57 bb ff ff       	call   80104d37 <memcmp>
801091e0:	83 c4 10             	add    $0x10,%esp
801091e3:	85 c0                	test   %eax,%eax
801091e5:	75 4c                	jne    80109233 <arp_proc+0x121>
    uint send = (uint)kalloc();
801091e7:	e8 b6 96 ff ff       	call   801028a2 <kalloc>
801091ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801091ef:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801091f6:	83 ec 04             	sub    $0x4,%esp
801091f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801091fc:	50                   	push   %eax
801091fd:	ff 75 f0             	push   -0x10(%ebp)
80109200:	ff 75 f4             	push   -0xc(%ebp)
80109203:	e8 33 04 00 00       	call   8010963b <arp_reply_pkt_create>
80109208:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
8010920b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010920e:	83 ec 08             	sub    $0x8,%esp
80109211:	50                   	push   %eax
80109212:	ff 75 f0             	push   -0x10(%ebp)
80109215:	e8 c2 fd ff ff       	call   80108fdc <i8254_send>
8010921a:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
8010921d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109220:	83 ec 0c             	sub    $0xc,%esp
80109223:	50                   	push   %eax
80109224:	e8 db 95 ff ff       	call   80102804 <kfree>
80109229:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010922c:	b8 02 00 00 00       	mov    $0x2,%eax
80109231:	eb 54                	jmp    80109287 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109233:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109236:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010923a:	66 3d 00 02          	cmp    $0x200,%ax
8010923e:	75 42                	jne    80109282 <arp_proc+0x170>
80109240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109243:	83 c0 18             	add    $0x18,%eax
80109246:	83 ec 04             	sub    $0x4,%esp
80109249:	6a 04                	push   $0x4
8010924b:	50                   	push   %eax
8010924c:	68 e4 f4 10 80       	push   $0x8010f4e4
80109251:	e8 e1 ba ff ff       	call   80104d37 <memcmp>
80109256:	83 c4 10             	add    $0x10,%esp
80109259:	85 c0                	test   %eax,%eax
8010925b:	75 25                	jne    80109282 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
8010925d:	83 ec 0c             	sub    $0xc,%esp
80109260:	68 3c c5 10 80       	push   $0x8010c53c
80109265:	e8 a2 71 ff ff       	call   8010040c <cprintf>
8010926a:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010926d:	83 ec 0c             	sub    $0xc,%esp
80109270:	ff 75 f4             	push   -0xc(%ebp)
80109273:	e8 b7 01 00 00       	call   8010942f <arp_table_update>
80109278:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
8010927b:	b8 01 00 00 00       	mov    $0x1,%eax
80109280:	eb 05                	jmp    80109287 <arp_proc+0x175>
  }else{
    return -1;
80109282:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109287:	c9                   	leave
80109288:	c3                   	ret

80109289 <arp_scan>:

void arp_scan(){
80109289:	f3 0f 1e fb          	endbr32
8010928d:	55                   	push   %ebp
8010928e:	89 e5                	mov    %esp,%ebp
80109290:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109293:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010929a:	eb 6f                	jmp    8010930b <arp_scan+0x82>
    uint send = (uint)kalloc();
8010929c:	e8 01 96 ff ff       	call   801028a2 <kalloc>
801092a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801092a4:	83 ec 04             	sub    $0x4,%esp
801092a7:	ff 75 f4             	push   -0xc(%ebp)
801092aa:	8d 45 e8             	lea    -0x18(%ebp),%eax
801092ad:	50                   	push   %eax
801092ae:	ff 75 ec             	push   -0x14(%ebp)
801092b1:	e8 62 00 00 00       	call   80109318 <arp_broadcast>
801092b6:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801092b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092bc:	83 ec 08             	sub    $0x8,%esp
801092bf:	50                   	push   %eax
801092c0:	ff 75 ec             	push   -0x14(%ebp)
801092c3:	e8 14 fd ff ff       	call   80108fdc <i8254_send>
801092c8:	83 c4 10             	add    $0x10,%esp
801092cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801092ce:	eb 22                	jmp    801092f2 <arp_scan+0x69>
      microdelay(1);
801092d0:	83 ec 0c             	sub    $0xc,%esp
801092d3:	6a 01                	push   $0x1
801092d5:	e8 7a 99 ff ff       	call   80102c54 <microdelay>
801092da:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
801092dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092e0:	83 ec 08             	sub    $0x8,%esp
801092e3:	50                   	push   %eax
801092e4:	ff 75 ec             	push   -0x14(%ebp)
801092e7:	e8 f0 fc ff ff       	call   80108fdc <i8254_send>
801092ec:	83 c4 10             	add    $0x10,%esp
801092ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801092f2:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801092f6:	74 d8                	je     801092d0 <arp_scan+0x47>
    }
    kfree((char *)send);
801092f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092fb:	83 ec 0c             	sub    $0xc,%esp
801092fe:	50                   	push   %eax
801092ff:	e8 00 95 ff ff       	call   80102804 <kfree>
80109304:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109307:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010930b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109312:	7e 88                	jle    8010929c <arp_scan+0x13>
  }
}
80109314:	90                   	nop
80109315:	90                   	nop
80109316:	c9                   	leave
80109317:	c3                   	ret

80109318 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109318:	f3 0f 1e fb          	endbr32
8010931c:	55                   	push   %ebp
8010931d:	89 e5                	mov    %esp,%ebp
8010931f:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109322:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109326:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
8010932a:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
8010932e:	8b 45 10             	mov    0x10(%ebp),%eax
80109331:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109334:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
8010933b:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109341:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109348:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010934e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109351:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109357:	8b 45 08             	mov    0x8(%ebp),%eax
8010935a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010935d:	8b 45 08             	mov    0x8(%ebp),%eax
80109360:	83 c0 0e             	add    $0xe,%eax
80109363:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109369:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010936d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109370:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109374:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109377:	83 ec 04             	sub    $0x4,%esp
8010937a:	6a 06                	push   $0x6
8010937c:	8d 55 e6             	lea    -0x1a(%ebp),%edx
8010937f:	52                   	push   %edx
80109380:	50                   	push   %eax
80109381:	e8 0d ba ff ff       	call   80104d93 <memmove>
80109386:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109389:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010938c:	83 c0 06             	add    $0x6,%eax
8010938f:	83 ec 04             	sub    $0x4,%esp
80109392:	6a 06                	push   $0x6
80109394:	68 68 d0 18 80       	push   $0x8018d068
80109399:	50                   	push   %eax
8010939a:	e8 f4 b9 ff ff       	call   80104d93 <memmove>
8010939f:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801093a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093a5:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801093aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093ad:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801093b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093b6:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801093ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093bd:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801093c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093c4:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801093ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093cd:	8d 50 12             	lea    0x12(%eax),%edx
801093d0:	83 ec 04             	sub    $0x4,%esp
801093d3:	6a 06                	push   $0x6
801093d5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801093d8:	50                   	push   %eax
801093d9:	52                   	push   %edx
801093da:	e8 b4 b9 ff ff       	call   80104d93 <memmove>
801093df:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
801093e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093e5:	8d 50 18             	lea    0x18(%eax),%edx
801093e8:	83 ec 04             	sub    $0x4,%esp
801093eb:	6a 04                	push   $0x4
801093ed:	8d 45 ec             	lea    -0x14(%ebp),%eax
801093f0:	50                   	push   %eax
801093f1:	52                   	push   %edx
801093f2:	e8 9c b9 ff ff       	call   80104d93 <memmove>
801093f7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801093fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093fd:	83 c0 08             	add    $0x8,%eax
80109400:	83 ec 04             	sub    $0x4,%esp
80109403:	6a 06                	push   $0x6
80109405:	68 68 d0 18 80       	push   $0x8018d068
8010940a:	50                   	push   %eax
8010940b:	e8 83 b9 ff ff       	call   80104d93 <memmove>
80109410:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109413:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109416:	83 c0 0e             	add    $0xe,%eax
80109419:	83 ec 04             	sub    $0x4,%esp
8010941c:	6a 04                	push   $0x4
8010941e:	68 e4 f4 10 80       	push   $0x8010f4e4
80109423:	50                   	push   %eax
80109424:	e8 6a b9 ff ff       	call   80104d93 <memmove>
80109429:	83 c4 10             	add    $0x10,%esp
}
8010942c:	90                   	nop
8010942d:	c9                   	leave
8010942e:	c3                   	ret

8010942f <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
8010942f:	f3 0f 1e fb          	endbr32
80109433:	55                   	push   %ebp
80109434:	89 e5                	mov    %esp,%ebp
80109436:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109439:	8b 45 08             	mov    0x8(%ebp),%eax
8010943c:	83 c0 0e             	add    $0xe,%eax
8010943f:	83 ec 0c             	sub    $0xc,%esp
80109442:	50                   	push   %eax
80109443:	e8 bc 00 00 00       	call   80109504 <arp_table_search>
80109448:	83 c4 10             	add    $0x10,%esp
8010944b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
8010944e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109452:	78 2d                	js     80109481 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109454:	8b 45 08             	mov    0x8(%ebp),%eax
80109457:	8d 48 08             	lea    0x8(%eax),%ecx
8010945a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010945d:	89 d0                	mov    %edx,%eax
8010945f:	c1 e0 02             	shl    $0x2,%eax
80109462:	01 d0                	add    %edx,%eax
80109464:	01 c0                	add    %eax,%eax
80109466:	01 d0                	add    %edx,%eax
80109468:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010946d:	83 c0 04             	add    $0x4,%eax
80109470:	83 ec 04             	sub    $0x4,%esp
80109473:	6a 06                	push   $0x6
80109475:	51                   	push   %ecx
80109476:	50                   	push   %eax
80109477:	e8 17 b9 ff ff       	call   80104d93 <memmove>
8010947c:	83 c4 10             	add    $0x10,%esp
8010947f:	eb 70                	jmp    801094f1 <arp_table_update+0xc2>
  }else{
    index += 1;
80109481:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109485:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109488:	8b 45 08             	mov    0x8(%ebp),%eax
8010948b:	8d 48 08             	lea    0x8(%eax),%ecx
8010948e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109491:	89 d0                	mov    %edx,%eax
80109493:	c1 e0 02             	shl    $0x2,%eax
80109496:	01 d0                	add    %edx,%eax
80109498:	01 c0                	add    %eax,%eax
8010949a:	01 d0                	add    %edx,%eax
8010949c:	05 80 d0 18 80       	add    $0x8018d080,%eax
801094a1:	83 c0 04             	add    $0x4,%eax
801094a4:	83 ec 04             	sub    $0x4,%esp
801094a7:	6a 06                	push   $0x6
801094a9:	51                   	push   %ecx
801094aa:	50                   	push   %eax
801094ab:	e8 e3 b8 ff ff       	call   80104d93 <memmove>
801094b0:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801094b3:	8b 45 08             	mov    0x8(%ebp),%eax
801094b6:	8d 48 0e             	lea    0xe(%eax),%ecx
801094b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094bc:	89 d0                	mov    %edx,%eax
801094be:	c1 e0 02             	shl    $0x2,%eax
801094c1:	01 d0                	add    %edx,%eax
801094c3:	01 c0                	add    %eax,%eax
801094c5:	01 d0                	add    %edx,%eax
801094c7:	05 80 d0 18 80       	add    $0x8018d080,%eax
801094cc:	83 ec 04             	sub    $0x4,%esp
801094cf:	6a 04                	push   $0x4
801094d1:	51                   	push   %ecx
801094d2:	50                   	push   %eax
801094d3:	e8 bb b8 ff ff       	call   80104d93 <memmove>
801094d8:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801094db:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094de:	89 d0                	mov    %edx,%eax
801094e0:	c1 e0 02             	shl    $0x2,%eax
801094e3:	01 d0                	add    %edx,%eax
801094e5:	01 c0                	add    %eax,%eax
801094e7:	01 d0                	add    %edx,%eax
801094e9:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801094ee:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801094f1:	83 ec 0c             	sub    $0xc,%esp
801094f4:	68 80 d0 18 80       	push   $0x8018d080
801094f9:	e8 87 00 00 00       	call   80109585 <print_arp_table>
801094fe:	83 c4 10             	add    $0x10,%esp
}
80109501:	90                   	nop
80109502:	c9                   	leave
80109503:	c3                   	ret

80109504 <arp_table_search>:

int arp_table_search(uchar *ip){
80109504:	f3 0f 1e fb          	endbr32
80109508:	55                   	push   %ebp
80109509:	89 e5                	mov    %esp,%ebp
8010950b:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
8010950e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109515:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010951c:	eb 59                	jmp    80109577 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
8010951e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109521:	89 d0                	mov    %edx,%eax
80109523:	c1 e0 02             	shl    $0x2,%eax
80109526:	01 d0                	add    %edx,%eax
80109528:	01 c0                	add    %eax,%eax
8010952a:	01 d0                	add    %edx,%eax
8010952c:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109531:	83 ec 04             	sub    $0x4,%esp
80109534:	6a 04                	push   $0x4
80109536:	ff 75 08             	push   0x8(%ebp)
80109539:	50                   	push   %eax
8010953a:	e8 f8 b7 ff ff       	call   80104d37 <memcmp>
8010953f:	83 c4 10             	add    $0x10,%esp
80109542:	85 c0                	test   %eax,%eax
80109544:	75 05                	jne    8010954b <arp_table_search+0x47>
      return i;
80109546:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109549:	eb 38                	jmp    80109583 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
8010954b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010954e:	89 d0                	mov    %edx,%eax
80109550:	c1 e0 02             	shl    $0x2,%eax
80109553:	01 d0                	add    %edx,%eax
80109555:	01 c0                	add    %eax,%eax
80109557:	01 d0                	add    %edx,%eax
80109559:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010955e:	0f b6 00             	movzbl (%eax),%eax
80109561:	84 c0                	test   %al,%al
80109563:	75 0e                	jne    80109573 <arp_table_search+0x6f>
80109565:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109569:	75 08                	jne    80109573 <arp_table_search+0x6f>
      empty = -i;
8010956b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010956e:	f7 d8                	neg    %eax
80109570:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109573:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109577:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010957b:	7e a1                	jle    8010951e <arp_table_search+0x1a>
    }
  }
  return empty-1;
8010957d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109580:	83 e8 01             	sub    $0x1,%eax
}
80109583:	c9                   	leave
80109584:	c3                   	ret

80109585 <print_arp_table>:

void print_arp_table(){
80109585:	f3 0f 1e fb          	endbr32
80109589:	55                   	push   %ebp
8010958a:	89 e5                	mov    %esp,%ebp
8010958c:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010958f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109596:	e9 92 00 00 00       	jmp    8010962d <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
8010959b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010959e:	89 d0                	mov    %edx,%eax
801095a0:	c1 e0 02             	shl    $0x2,%eax
801095a3:	01 d0                	add    %edx,%eax
801095a5:	01 c0                	add    %eax,%eax
801095a7:	01 d0                	add    %edx,%eax
801095a9:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801095ae:	0f b6 00             	movzbl (%eax),%eax
801095b1:	84 c0                	test   %al,%al
801095b3:	74 74                	je     80109629 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
801095b5:	83 ec 08             	sub    $0x8,%esp
801095b8:	ff 75 f4             	push   -0xc(%ebp)
801095bb:	68 4f c5 10 80       	push   $0x8010c54f
801095c0:	e8 47 6e ff ff       	call   8010040c <cprintf>
801095c5:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801095c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095cb:	89 d0                	mov    %edx,%eax
801095cd:	c1 e0 02             	shl    $0x2,%eax
801095d0:	01 d0                	add    %edx,%eax
801095d2:	01 c0                	add    %eax,%eax
801095d4:	01 d0                	add    %edx,%eax
801095d6:	05 80 d0 18 80       	add    $0x8018d080,%eax
801095db:	83 ec 0c             	sub    $0xc,%esp
801095de:	50                   	push   %eax
801095df:	e8 5c 02 00 00       	call   80109840 <print_ipv4>
801095e4:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801095e7:	83 ec 0c             	sub    $0xc,%esp
801095ea:	68 5e c5 10 80       	push   $0x8010c55e
801095ef:	e8 18 6e ff ff       	call   8010040c <cprintf>
801095f4:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801095f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095fa:	89 d0                	mov    %edx,%eax
801095fc:	c1 e0 02             	shl    $0x2,%eax
801095ff:	01 d0                	add    %edx,%eax
80109601:	01 c0                	add    %eax,%eax
80109603:	01 d0                	add    %edx,%eax
80109605:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010960a:	83 c0 04             	add    $0x4,%eax
8010960d:	83 ec 0c             	sub    $0xc,%esp
80109610:	50                   	push   %eax
80109611:	e8 7c 02 00 00       	call   80109892 <print_mac>
80109616:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109619:	83 ec 0c             	sub    $0xc,%esp
8010961c:	68 60 c5 10 80       	push   $0x8010c560
80109621:	e8 e6 6d ff ff       	call   8010040c <cprintf>
80109626:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109629:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010962d:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109631:	0f 8e 64 ff ff ff    	jle    8010959b <print_arp_table+0x16>
    }
  }
}
80109637:	90                   	nop
80109638:	90                   	nop
80109639:	c9                   	leave
8010963a:	c3                   	ret

8010963b <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
8010963b:	f3 0f 1e fb          	endbr32
8010963f:	55                   	push   %ebp
80109640:	89 e5                	mov    %esp,%ebp
80109642:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109645:	8b 45 10             	mov    0x10(%ebp),%eax
80109648:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010964e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109651:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109654:	8b 45 0c             	mov    0xc(%ebp),%eax
80109657:	83 c0 0e             	add    $0xe,%eax
8010965a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
8010965d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109660:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109667:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010966b:	8b 45 08             	mov    0x8(%ebp),%eax
8010966e:	8d 50 08             	lea    0x8(%eax),%edx
80109671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109674:	83 ec 04             	sub    $0x4,%esp
80109677:	6a 06                	push   $0x6
80109679:	52                   	push   %edx
8010967a:	50                   	push   %eax
8010967b:	e8 13 b7 ff ff       	call   80104d93 <memmove>
80109680:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109686:	83 c0 06             	add    $0x6,%eax
80109689:	83 ec 04             	sub    $0x4,%esp
8010968c:	6a 06                	push   $0x6
8010968e:	68 68 d0 18 80       	push   $0x8018d068
80109693:	50                   	push   %eax
80109694:	e8 fa b6 ff ff       	call   80104d93 <memmove>
80109699:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010969c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010969f:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801096a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096a7:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801096ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096b0:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801096b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096b7:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
801096bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096be:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801096c4:	8b 45 08             	mov    0x8(%ebp),%eax
801096c7:	8d 50 08             	lea    0x8(%eax),%edx
801096ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096cd:	83 c0 12             	add    $0x12,%eax
801096d0:	83 ec 04             	sub    $0x4,%esp
801096d3:	6a 06                	push   $0x6
801096d5:	52                   	push   %edx
801096d6:	50                   	push   %eax
801096d7:	e8 b7 b6 ff ff       	call   80104d93 <memmove>
801096dc:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801096df:	8b 45 08             	mov    0x8(%ebp),%eax
801096e2:	8d 50 0e             	lea    0xe(%eax),%edx
801096e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096e8:	83 c0 18             	add    $0x18,%eax
801096eb:	83 ec 04             	sub    $0x4,%esp
801096ee:	6a 04                	push   $0x4
801096f0:	52                   	push   %edx
801096f1:	50                   	push   %eax
801096f2:	e8 9c b6 ff ff       	call   80104d93 <memmove>
801096f7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801096fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096fd:	83 c0 08             	add    $0x8,%eax
80109700:	83 ec 04             	sub    $0x4,%esp
80109703:	6a 06                	push   $0x6
80109705:	68 68 d0 18 80       	push   $0x8018d068
8010970a:	50                   	push   %eax
8010970b:	e8 83 b6 ff ff       	call   80104d93 <memmove>
80109710:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109713:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109716:	83 c0 0e             	add    $0xe,%eax
80109719:	83 ec 04             	sub    $0x4,%esp
8010971c:	6a 04                	push   $0x4
8010971e:	68 e4 f4 10 80       	push   $0x8010f4e4
80109723:	50                   	push   %eax
80109724:	e8 6a b6 ff ff       	call   80104d93 <memmove>
80109729:	83 c4 10             	add    $0x10,%esp
}
8010972c:	90                   	nop
8010972d:	c9                   	leave
8010972e:	c3                   	ret

8010972f <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010972f:	f3 0f 1e fb          	endbr32
80109733:	55                   	push   %ebp
80109734:	89 e5                	mov    %esp,%ebp
80109736:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109739:	83 ec 0c             	sub    $0xc,%esp
8010973c:	68 62 c5 10 80       	push   $0x8010c562
80109741:	e8 c6 6c ff ff       	call   8010040c <cprintf>
80109746:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109749:	8b 45 08             	mov    0x8(%ebp),%eax
8010974c:	83 c0 0e             	add    $0xe,%eax
8010974f:	83 ec 0c             	sub    $0xc,%esp
80109752:	50                   	push   %eax
80109753:	e8 e8 00 00 00       	call   80109840 <print_ipv4>
80109758:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010975b:	83 ec 0c             	sub    $0xc,%esp
8010975e:	68 60 c5 10 80       	push   $0x8010c560
80109763:	e8 a4 6c ff ff       	call   8010040c <cprintf>
80109768:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010976b:	8b 45 08             	mov    0x8(%ebp),%eax
8010976e:	83 c0 08             	add    $0x8,%eax
80109771:	83 ec 0c             	sub    $0xc,%esp
80109774:	50                   	push   %eax
80109775:	e8 18 01 00 00       	call   80109892 <print_mac>
8010977a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010977d:	83 ec 0c             	sub    $0xc,%esp
80109780:	68 60 c5 10 80       	push   $0x8010c560
80109785:	e8 82 6c ff ff       	call   8010040c <cprintf>
8010978a:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010978d:	83 ec 0c             	sub    $0xc,%esp
80109790:	68 79 c5 10 80       	push   $0x8010c579
80109795:	e8 72 6c ff ff       	call   8010040c <cprintf>
8010979a:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010979d:	8b 45 08             	mov    0x8(%ebp),%eax
801097a0:	83 c0 18             	add    $0x18,%eax
801097a3:	83 ec 0c             	sub    $0xc,%esp
801097a6:	50                   	push   %eax
801097a7:	e8 94 00 00 00       	call   80109840 <print_ipv4>
801097ac:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801097af:	83 ec 0c             	sub    $0xc,%esp
801097b2:	68 60 c5 10 80       	push   $0x8010c560
801097b7:	e8 50 6c ff ff       	call   8010040c <cprintf>
801097bc:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
801097bf:	8b 45 08             	mov    0x8(%ebp),%eax
801097c2:	83 c0 12             	add    $0x12,%eax
801097c5:	83 ec 0c             	sub    $0xc,%esp
801097c8:	50                   	push   %eax
801097c9:	e8 c4 00 00 00       	call   80109892 <print_mac>
801097ce:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801097d1:	83 ec 0c             	sub    $0xc,%esp
801097d4:	68 60 c5 10 80       	push   $0x8010c560
801097d9:	e8 2e 6c ff ff       	call   8010040c <cprintf>
801097de:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
801097e1:	83 ec 0c             	sub    $0xc,%esp
801097e4:	68 90 c5 10 80       	push   $0x8010c590
801097e9:	e8 1e 6c ff ff       	call   8010040c <cprintf>
801097ee:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801097f1:	8b 45 08             	mov    0x8(%ebp),%eax
801097f4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801097f8:	66 3d 00 01          	cmp    $0x100,%ax
801097fc:	75 12                	jne    80109810 <print_arp_info+0xe1>
801097fe:	83 ec 0c             	sub    $0xc,%esp
80109801:	68 9c c5 10 80       	push   $0x8010c59c
80109806:	e8 01 6c ff ff       	call   8010040c <cprintf>
8010980b:	83 c4 10             	add    $0x10,%esp
8010980e:	eb 1d                	jmp    8010982d <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109810:	8b 45 08             	mov    0x8(%ebp),%eax
80109813:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109817:	66 3d 00 02          	cmp    $0x200,%ax
8010981b:	75 10                	jne    8010982d <print_arp_info+0xfe>
    cprintf("Reply\n");
8010981d:	83 ec 0c             	sub    $0xc,%esp
80109820:	68 a5 c5 10 80       	push   $0x8010c5a5
80109825:	e8 e2 6b ff ff       	call   8010040c <cprintf>
8010982a:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010982d:	83 ec 0c             	sub    $0xc,%esp
80109830:	68 60 c5 10 80       	push   $0x8010c560
80109835:	e8 d2 6b ff ff       	call   8010040c <cprintf>
8010983a:	83 c4 10             	add    $0x10,%esp
}
8010983d:	90                   	nop
8010983e:	c9                   	leave
8010983f:	c3                   	ret

80109840 <print_ipv4>:

void print_ipv4(uchar *ip){
80109840:	f3 0f 1e fb          	endbr32
80109844:	55                   	push   %ebp
80109845:	89 e5                	mov    %esp,%ebp
80109847:	53                   	push   %ebx
80109848:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010984b:	8b 45 08             	mov    0x8(%ebp),%eax
8010984e:	83 c0 03             	add    $0x3,%eax
80109851:	0f b6 00             	movzbl (%eax),%eax
80109854:	0f b6 d8             	movzbl %al,%ebx
80109857:	8b 45 08             	mov    0x8(%ebp),%eax
8010985a:	83 c0 02             	add    $0x2,%eax
8010985d:	0f b6 00             	movzbl (%eax),%eax
80109860:	0f b6 c8             	movzbl %al,%ecx
80109863:	8b 45 08             	mov    0x8(%ebp),%eax
80109866:	83 c0 01             	add    $0x1,%eax
80109869:	0f b6 00             	movzbl (%eax),%eax
8010986c:	0f b6 d0             	movzbl %al,%edx
8010986f:	8b 45 08             	mov    0x8(%ebp),%eax
80109872:	0f b6 00             	movzbl (%eax),%eax
80109875:	0f b6 c0             	movzbl %al,%eax
80109878:	83 ec 0c             	sub    $0xc,%esp
8010987b:	53                   	push   %ebx
8010987c:	51                   	push   %ecx
8010987d:	52                   	push   %edx
8010987e:	50                   	push   %eax
8010987f:	68 ac c5 10 80       	push   $0x8010c5ac
80109884:	e8 83 6b ff ff       	call   8010040c <cprintf>
80109889:	83 c4 20             	add    $0x20,%esp
}
8010988c:	90                   	nop
8010988d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109890:	c9                   	leave
80109891:	c3                   	ret

80109892 <print_mac>:

void print_mac(uchar *mac){
80109892:	f3 0f 1e fb          	endbr32
80109896:	55                   	push   %ebp
80109897:	89 e5                	mov    %esp,%ebp
80109899:	57                   	push   %edi
8010989a:	56                   	push   %esi
8010989b:	53                   	push   %ebx
8010989c:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010989f:	8b 45 08             	mov    0x8(%ebp),%eax
801098a2:	83 c0 05             	add    $0x5,%eax
801098a5:	0f b6 00             	movzbl (%eax),%eax
801098a8:	0f b6 f8             	movzbl %al,%edi
801098ab:	8b 45 08             	mov    0x8(%ebp),%eax
801098ae:	83 c0 04             	add    $0x4,%eax
801098b1:	0f b6 00             	movzbl (%eax),%eax
801098b4:	0f b6 f0             	movzbl %al,%esi
801098b7:	8b 45 08             	mov    0x8(%ebp),%eax
801098ba:	83 c0 03             	add    $0x3,%eax
801098bd:	0f b6 00             	movzbl (%eax),%eax
801098c0:	0f b6 d8             	movzbl %al,%ebx
801098c3:	8b 45 08             	mov    0x8(%ebp),%eax
801098c6:	83 c0 02             	add    $0x2,%eax
801098c9:	0f b6 00             	movzbl (%eax),%eax
801098cc:	0f b6 c8             	movzbl %al,%ecx
801098cf:	8b 45 08             	mov    0x8(%ebp),%eax
801098d2:	83 c0 01             	add    $0x1,%eax
801098d5:	0f b6 00             	movzbl (%eax),%eax
801098d8:	0f b6 d0             	movzbl %al,%edx
801098db:	8b 45 08             	mov    0x8(%ebp),%eax
801098de:	0f b6 00             	movzbl (%eax),%eax
801098e1:	0f b6 c0             	movzbl %al,%eax
801098e4:	83 ec 04             	sub    $0x4,%esp
801098e7:	57                   	push   %edi
801098e8:	56                   	push   %esi
801098e9:	53                   	push   %ebx
801098ea:	51                   	push   %ecx
801098eb:	52                   	push   %edx
801098ec:	50                   	push   %eax
801098ed:	68 c4 c5 10 80       	push   $0x8010c5c4
801098f2:	e8 15 6b ff ff       	call   8010040c <cprintf>
801098f7:	83 c4 20             	add    $0x20,%esp
}
801098fa:	90                   	nop
801098fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801098fe:	5b                   	pop    %ebx
801098ff:	5e                   	pop    %esi
80109900:	5f                   	pop    %edi
80109901:	5d                   	pop    %ebp
80109902:	c3                   	ret

80109903 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109903:	f3 0f 1e fb          	endbr32
80109907:	55                   	push   %ebp
80109908:	89 e5                	mov    %esp,%ebp
8010990a:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010990d:	8b 45 08             	mov    0x8(%ebp),%eax
80109910:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109913:	8b 45 08             	mov    0x8(%ebp),%eax
80109916:	83 c0 0e             	add    $0xe,%eax
80109919:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010991c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010991f:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109923:	3c 08                	cmp    $0x8,%al
80109925:	75 1b                	jne    80109942 <eth_proc+0x3f>
80109927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010992a:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010992e:	3c 06                	cmp    $0x6,%al
80109930:	75 10                	jne    80109942 <eth_proc+0x3f>
    arp_proc(pkt_addr);
80109932:	83 ec 0c             	sub    $0xc,%esp
80109935:	ff 75 f0             	push   -0x10(%ebp)
80109938:	e8 d5 f7 ff ff       	call   80109112 <arp_proc>
8010993d:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109940:	eb 24                	jmp    80109966 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109942:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109945:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109949:	3c 08                	cmp    $0x8,%al
8010994b:	75 19                	jne    80109966 <eth_proc+0x63>
8010994d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109950:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109954:	84 c0                	test   %al,%al
80109956:	75 0e                	jne    80109966 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
80109958:	83 ec 0c             	sub    $0xc,%esp
8010995b:	ff 75 08             	push   0x8(%ebp)
8010995e:	e8 b3 00 00 00       	call   80109a16 <ipv4_proc>
80109963:	83 c4 10             	add    $0x10,%esp
}
80109966:	90                   	nop
80109967:	c9                   	leave
80109968:	c3                   	ret

80109969 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109969:	f3 0f 1e fb          	endbr32
8010996d:	55                   	push   %ebp
8010996e:	89 e5                	mov    %esp,%ebp
80109970:	83 ec 04             	sub    $0x4,%esp
80109973:	8b 45 08             	mov    0x8(%ebp),%eax
80109976:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010997a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010997e:	c1 e0 08             	shl    $0x8,%eax
80109981:	89 c2                	mov    %eax,%edx
80109983:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109987:	66 c1 e8 08          	shr    $0x8,%ax
8010998b:	01 d0                	add    %edx,%eax
}
8010998d:	c9                   	leave
8010998e:	c3                   	ret

8010998f <H2N_ushort>:

ushort H2N_ushort(ushort value){
8010998f:	f3 0f 1e fb          	endbr32
80109993:	55                   	push   %ebp
80109994:	89 e5                	mov    %esp,%ebp
80109996:	83 ec 04             	sub    $0x4,%esp
80109999:	8b 45 08             	mov    0x8(%ebp),%eax
8010999c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801099a0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801099a4:	c1 e0 08             	shl    $0x8,%eax
801099a7:	89 c2                	mov    %eax,%edx
801099a9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801099ad:	66 c1 e8 08          	shr    $0x8,%ax
801099b1:	01 d0                	add    %edx,%eax
}
801099b3:	c9                   	leave
801099b4:	c3                   	ret

801099b5 <H2N_uint>:

uint H2N_uint(uint value){
801099b5:	f3 0f 1e fb          	endbr32
801099b9:	55                   	push   %ebp
801099ba:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
801099bc:	8b 45 08             	mov    0x8(%ebp),%eax
801099bf:	c1 e0 18             	shl    $0x18,%eax
801099c2:	25 00 00 00 0f       	and    $0xf000000,%eax
801099c7:	89 c2                	mov    %eax,%edx
801099c9:	8b 45 08             	mov    0x8(%ebp),%eax
801099cc:	c1 e0 08             	shl    $0x8,%eax
801099cf:	25 00 f0 00 00       	and    $0xf000,%eax
801099d4:	09 c2                	or     %eax,%edx
801099d6:	8b 45 08             	mov    0x8(%ebp),%eax
801099d9:	c1 e8 08             	shr    $0x8,%eax
801099dc:	83 e0 0f             	and    $0xf,%eax
801099df:	01 d0                	add    %edx,%eax
}
801099e1:	5d                   	pop    %ebp
801099e2:	c3                   	ret

801099e3 <N2H_uint>:

uint N2H_uint(uint value){
801099e3:	f3 0f 1e fb          	endbr32
801099e7:	55                   	push   %ebp
801099e8:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
801099ea:	8b 45 08             	mov    0x8(%ebp),%eax
801099ed:	c1 e0 18             	shl    $0x18,%eax
801099f0:	89 c2                	mov    %eax,%edx
801099f2:	8b 45 08             	mov    0x8(%ebp),%eax
801099f5:	c1 e0 08             	shl    $0x8,%eax
801099f8:	25 00 00 ff 00       	and    $0xff0000,%eax
801099fd:	01 c2                	add    %eax,%edx
801099ff:	8b 45 08             	mov    0x8(%ebp),%eax
80109a02:	c1 e8 08             	shr    $0x8,%eax
80109a05:	25 00 ff 00 00       	and    $0xff00,%eax
80109a0a:	01 c2                	add    %eax,%edx
80109a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80109a0f:	c1 e8 18             	shr    $0x18,%eax
80109a12:	01 d0                	add    %edx,%eax
}
80109a14:	5d                   	pop    %ebp
80109a15:	c3                   	ret

80109a16 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109a16:	f3 0f 1e fb          	endbr32
80109a1a:	55                   	push   %ebp
80109a1b:	89 e5                	mov    %esp,%ebp
80109a1d:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109a20:	8b 45 08             	mov    0x8(%ebp),%eax
80109a23:	83 c0 0e             	add    $0xe,%eax
80109a26:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a2c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109a30:	0f b7 d0             	movzwl %ax,%edx
80109a33:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109a38:	39 c2                	cmp    %eax,%edx
80109a3a:	74 60                	je     80109a9c <ipv4_proc+0x86>
80109a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a3f:	83 c0 0c             	add    $0xc,%eax
80109a42:	83 ec 04             	sub    $0x4,%esp
80109a45:	6a 04                	push   $0x4
80109a47:	50                   	push   %eax
80109a48:	68 e4 f4 10 80       	push   $0x8010f4e4
80109a4d:	e8 e5 b2 ff ff       	call   80104d37 <memcmp>
80109a52:	83 c4 10             	add    $0x10,%esp
80109a55:	85 c0                	test   %eax,%eax
80109a57:	74 43                	je     80109a9c <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
80109a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a5c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109a60:	0f b7 c0             	movzwl %ax,%eax
80109a63:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a6b:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109a6f:	3c 01                	cmp    $0x1,%al
80109a71:	75 10                	jne    80109a83 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109a73:	83 ec 0c             	sub    $0xc,%esp
80109a76:	ff 75 08             	push   0x8(%ebp)
80109a79:	e8 a7 00 00 00       	call   80109b25 <icmp_proc>
80109a7e:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109a81:	eb 19                	jmp    80109a9c <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a86:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109a8a:	3c 06                	cmp    $0x6,%al
80109a8c:	75 0e                	jne    80109a9c <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
80109a8e:	83 ec 0c             	sub    $0xc,%esp
80109a91:	ff 75 08             	push   0x8(%ebp)
80109a94:	e8 c7 03 00 00       	call   80109e60 <tcp_proc>
80109a99:	83 c4 10             	add    $0x10,%esp
}
80109a9c:	90                   	nop
80109a9d:	c9                   	leave
80109a9e:	c3                   	ret

80109a9f <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109a9f:	f3 0f 1e fb          	endbr32
80109aa3:	55                   	push   %ebp
80109aa4:	89 e5                	mov    %esp,%ebp
80109aa6:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109aa9:	8b 45 08             	mov    0x8(%ebp),%eax
80109aac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ab2:	0f b6 00             	movzbl (%eax),%eax
80109ab5:	83 e0 0f             	and    $0xf,%eax
80109ab8:	01 c0                	add    %eax,%eax
80109aba:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109abd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109ac4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109acb:	eb 48                	jmp    80109b15 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109acd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109ad0:	01 c0                	add    %eax,%eax
80109ad2:	89 c2                	mov    %eax,%edx
80109ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ad7:	01 d0                	add    %edx,%eax
80109ad9:	0f b6 00             	movzbl (%eax),%eax
80109adc:	0f b6 c0             	movzbl %al,%eax
80109adf:	c1 e0 08             	shl    $0x8,%eax
80109ae2:	89 c2                	mov    %eax,%edx
80109ae4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109ae7:	01 c0                	add    %eax,%eax
80109ae9:	8d 48 01             	lea    0x1(%eax),%ecx
80109aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aef:	01 c8                	add    %ecx,%eax
80109af1:	0f b6 00             	movzbl (%eax),%eax
80109af4:	0f b6 c0             	movzbl %al,%eax
80109af7:	01 d0                	add    %edx,%eax
80109af9:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109afc:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109b03:	76 0c                	jbe    80109b11 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
80109b05:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b08:	0f b7 c0             	movzwl %ax,%eax
80109b0b:	83 c0 01             	add    $0x1,%eax
80109b0e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109b11:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109b15:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109b19:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109b1c:	7c af                	jl     80109acd <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
80109b1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b21:	f7 d0                	not    %eax
}
80109b23:	c9                   	leave
80109b24:	c3                   	ret

80109b25 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109b25:	f3 0f 1e fb          	endbr32
80109b29:	55                   	push   %ebp
80109b2a:	89 e5                	mov    %esp,%ebp
80109b2c:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80109b32:	83 c0 0e             	add    $0xe,%eax
80109b35:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b3b:	0f b6 00             	movzbl (%eax),%eax
80109b3e:	0f b6 c0             	movzbl %al,%eax
80109b41:	83 e0 0f             	and    $0xf,%eax
80109b44:	c1 e0 02             	shl    $0x2,%eax
80109b47:	89 c2                	mov    %eax,%edx
80109b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b4c:	01 d0                	add    %edx,%eax
80109b4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b54:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109b58:	84 c0                	test   %al,%al
80109b5a:	75 4f                	jne    80109bab <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b5f:	0f b6 00             	movzbl (%eax),%eax
80109b62:	3c 08                	cmp    $0x8,%al
80109b64:	75 45                	jne    80109bab <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109b66:	e8 37 8d ff ff       	call   801028a2 <kalloc>
80109b6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109b6e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109b75:	83 ec 04             	sub    $0x4,%esp
80109b78:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109b7b:	50                   	push   %eax
80109b7c:	ff 75 ec             	push   -0x14(%ebp)
80109b7f:	ff 75 08             	push   0x8(%ebp)
80109b82:	e8 7c 00 00 00       	call   80109c03 <icmp_reply_pkt_create>
80109b87:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109b8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b8d:	83 ec 08             	sub    $0x8,%esp
80109b90:	50                   	push   %eax
80109b91:	ff 75 ec             	push   -0x14(%ebp)
80109b94:	e8 43 f4 ff ff       	call   80108fdc <i8254_send>
80109b99:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109b9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b9f:	83 ec 0c             	sub    $0xc,%esp
80109ba2:	50                   	push   %eax
80109ba3:	e8 5c 8c ff ff       	call   80102804 <kfree>
80109ba8:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109bab:	90                   	nop
80109bac:	c9                   	leave
80109bad:	c3                   	ret

80109bae <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109bae:	f3 0f 1e fb          	endbr32
80109bb2:	55                   	push   %ebp
80109bb3:	89 e5                	mov    %esp,%ebp
80109bb5:	53                   	push   %ebx
80109bb6:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80109bbc:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109bc0:	0f b7 c0             	movzwl %ax,%eax
80109bc3:	83 ec 0c             	sub    $0xc,%esp
80109bc6:	50                   	push   %eax
80109bc7:	e8 9d fd ff ff       	call   80109969 <N2H_ushort>
80109bcc:	83 c4 10             	add    $0x10,%esp
80109bcf:	0f b7 d8             	movzwl %ax,%ebx
80109bd2:	8b 45 08             	mov    0x8(%ebp),%eax
80109bd5:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109bd9:	0f b7 c0             	movzwl %ax,%eax
80109bdc:	83 ec 0c             	sub    $0xc,%esp
80109bdf:	50                   	push   %eax
80109be0:	e8 84 fd ff ff       	call   80109969 <N2H_ushort>
80109be5:	83 c4 10             	add    $0x10,%esp
80109be8:	0f b7 c0             	movzwl %ax,%eax
80109beb:	83 ec 04             	sub    $0x4,%esp
80109bee:	53                   	push   %ebx
80109bef:	50                   	push   %eax
80109bf0:	68 e3 c5 10 80       	push   $0x8010c5e3
80109bf5:	e8 12 68 ff ff       	call   8010040c <cprintf>
80109bfa:	83 c4 10             	add    $0x10,%esp
}
80109bfd:	90                   	nop
80109bfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109c01:	c9                   	leave
80109c02:	c3                   	ret

80109c03 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109c03:	f3 0f 1e fb          	endbr32
80109c07:	55                   	push   %ebp
80109c08:	89 e5                	mov    %esp,%ebp
80109c0a:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80109c10:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109c13:	8b 45 08             	mov    0x8(%ebp),%eax
80109c16:	83 c0 0e             	add    $0xe,%eax
80109c19:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109c1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c1f:	0f b6 00             	movzbl (%eax),%eax
80109c22:	0f b6 c0             	movzbl %al,%eax
80109c25:	83 e0 0f             	and    $0xf,%eax
80109c28:	c1 e0 02             	shl    $0x2,%eax
80109c2b:	89 c2                	mov    %eax,%edx
80109c2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c30:	01 d0                	add    %edx,%eax
80109c32:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109c35:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c38:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c3e:	83 c0 0e             	add    $0xe,%eax
80109c41:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109c44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c47:	83 c0 14             	add    $0x14,%eax
80109c4a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109c4d:	8b 45 10             	mov    0x10(%ebp),%eax
80109c50:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c59:	8d 50 06             	lea    0x6(%eax),%edx
80109c5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c5f:	83 ec 04             	sub    $0x4,%esp
80109c62:	6a 06                	push   $0x6
80109c64:	52                   	push   %edx
80109c65:	50                   	push   %eax
80109c66:	e8 28 b1 ff ff       	call   80104d93 <memmove>
80109c6b:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109c6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c71:	83 c0 06             	add    $0x6,%eax
80109c74:	83 ec 04             	sub    $0x4,%esp
80109c77:	6a 06                	push   $0x6
80109c79:	68 68 d0 18 80       	push   $0x8018d068
80109c7e:	50                   	push   %eax
80109c7f:	e8 0f b1 ff ff       	call   80104d93 <memmove>
80109c84:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109c87:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c8a:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109c8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c91:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109c95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c98:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109c9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c9e:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109ca2:	83 ec 0c             	sub    $0xc,%esp
80109ca5:	6a 54                	push   $0x54
80109ca7:	e8 e3 fc ff ff       	call   8010998f <H2N_ushort>
80109cac:	83 c4 10             	add    $0x10,%esp
80109caf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109cb2:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109cb6:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109cbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cc0:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109cc4:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109ccb:	83 c0 01             	add    $0x1,%eax
80109cce:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
80109cd4:	83 ec 0c             	sub    $0xc,%esp
80109cd7:	68 00 40 00 00       	push   $0x4000
80109cdc:	e8 ae fc ff ff       	call   8010998f <H2N_ushort>
80109ce1:	83 c4 10             	add    $0x10,%esp
80109ce4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ce7:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109ceb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cee:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109cf2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cf5:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109cf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cfc:	83 c0 0c             	add    $0xc,%eax
80109cff:	83 ec 04             	sub    $0x4,%esp
80109d02:	6a 04                	push   $0x4
80109d04:	68 e4 f4 10 80       	push   $0x8010f4e4
80109d09:	50                   	push   %eax
80109d0a:	e8 84 b0 ff ff       	call   80104d93 <memmove>
80109d0f:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d15:	8d 50 0c             	lea    0xc(%eax),%edx
80109d18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d1b:	83 c0 10             	add    $0x10,%eax
80109d1e:	83 ec 04             	sub    $0x4,%esp
80109d21:	6a 04                	push   $0x4
80109d23:	52                   	push   %edx
80109d24:	50                   	push   %eax
80109d25:	e8 69 b0 ff ff       	call   80104d93 <memmove>
80109d2a:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109d2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d30:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109d36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d39:	83 ec 0c             	sub    $0xc,%esp
80109d3c:	50                   	push   %eax
80109d3d:	e8 5d fd ff ff       	call   80109a9f <ipv4_chksum>
80109d42:	83 c4 10             	add    $0x10,%esp
80109d45:	0f b7 c0             	movzwl %ax,%eax
80109d48:	83 ec 0c             	sub    $0xc,%esp
80109d4b:	50                   	push   %eax
80109d4c:	e8 3e fc ff ff       	call   8010998f <H2N_ushort>
80109d51:	83 c4 10             	add    $0x10,%esp
80109d54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d57:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109d5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d5e:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109d61:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d64:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109d68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d6b:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109d6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d72:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109d76:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d79:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109d7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d80:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109d84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d87:	8d 50 08             	lea    0x8(%eax),%edx
80109d8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d8d:	83 c0 08             	add    $0x8,%eax
80109d90:	83 ec 04             	sub    $0x4,%esp
80109d93:	6a 08                	push   $0x8
80109d95:	52                   	push   %edx
80109d96:	50                   	push   %eax
80109d97:	e8 f7 af ff ff       	call   80104d93 <memmove>
80109d9c:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109d9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109da2:	8d 50 10             	lea    0x10(%eax),%edx
80109da5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109da8:	83 c0 10             	add    $0x10,%eax
80109dab:	83 ec 04             	sub    $0x4,%esp
80109dae:	6a 30                	push   $0x30
80109db0:	52                   	push   %edx
80109db1:	50                   	push   %eax
80109db2:	e8 dc af ff ff       	call   80104d93 <memmove>
80109db7:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109dba:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dbd:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109dc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dc6:	83 ec 0c             	sub    $0xc,%esp
80109dc9:	50                   	push   %eax
80109dca:	e8 1c 00 00 00       	call   80109deb <icmp_chksum>
80109dcf:	83 c4 10             	add    $0x10,%esp
80109dd2:	0f b7 c0             	movzwl %ax,%eax
80109dd5:	83 ec 0c             	sub    $0xc,%esp
80109dd8:	50                   	push   %eax
80109dd9:	e8 b1 fb ff ff       	call   8010998f <H2N_ushort>
80109dde:	83 c4 10             	add    $0x10,%esp
80109de1:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109de4:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109de8:	90                   	nop
80109de9:	c9                   	leave
80109dea:	c3                   	ret

80109deb <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109deb:	f3 0f 1e fb          	endbr32
80109def:	55                   	push   %ebp
80109df0:	89 e5                	mov    %esp,%ebp
80109df2:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109df5:	8b 45 08             	mov    0x8(%ebp),%eax
80109df8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109dfb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109e02:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109e09:	eb 48                	jmp    80109e53 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e0e:	01 c0                	add    %eax,%eax
80109e10:	89 c2                	mov    %eax,%edx
80109e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e15:	01 d0                	add    %edx,%eax
80109e17:	0f b6 00             	movzbl (%eax),%eax
80109e1a:	0f b6 c0             	movzbl %al,%eax
80109e1d:	c1 e0 08             	shl    $0x8,%eax
80109e20:	89 c2                	mov    %eax,%edx
80109e22:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e25:	01 c0                	add    %eax,%eax
80109e27:	8d 48 01             	lea    0x1(%eax),%ecx
80109e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e2d:	01 c8                	add    %ecx,%eax
80109e2f:	0f b6 00             	movzbl (%eax),%eax
80109e32:	0f b6 c0             	movzbl %al,%eax
80109e35:	01 d0                	add    %edx,%eax
80109e37:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109e3a:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109e41:	76 0c                	jbe    80109e4f <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
80109e43:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109e46:	0f b7 c0             	movzwl %ax,%eax
80109e49:	83 c0 01             	add    $0x1,%eax
80109e4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109e4f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109e53:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109e57:	7e b2                	jle    80109e0b <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
80109e59:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109e5c:	f7 d0                	not    %eax
}
80109e5e:	c9                   	leave
80109e5f:	c3                   	ret

80109e60 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109e60:	f3 0f 1e fb          	endbr32
80109e64:	55                   	push   %ebp
80109e65:	89 e5                	mov    %esp,%ebp
80109e67:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80109e6d:	83 c0 0e             	add    $0xe,%eax
80109e70:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e76:	0f b6 00             	movzbl (%eax),%eax
80109e79:	0f b6 c0             	movzbl %al,%eax
80109e7c:	83 e0 0f             	and    $0xf,%eax
80109e7f:	c1 e0 02             	shl    $0x2,%eax
80109e82:	89 c2                	mov    %eax,%edx
80109e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e87:	01 d0                	add    %edx,%eax
80109e89:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109e8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e8f:	83 c0 14             	add    $0x14,%eax
80109e92:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109e95:	e8 08 8a ff ff       	call   801028a2 <kalloc>
80109e9a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109e9d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109ea4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ea7:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109eab:	0f b6 c0             	movzbl %al,%eax
80109eae:	83 e0 02             	and    $0x2,%eax
80109eb1:	85 c0                	test   %eax,%eax
80109eb3:	74 3d                	je     80109ef2 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109eb5:	83 ec 0c             	sub    $0xc,%esp
80109eb8:	6a 00                	push   $0x0
80109eba:	6a 12                	push   $0x12
80109ebc:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ebf:	50                   	push   %eax
80109ec0:	ff 75 e8             	push   -0x18(%ebp)
80109ec3:	ff 75 08             	push   0x8(%ebp)
80109ec6:	e8 a2 01 00 00       	call   8010a06d <tcp_pkt_create>
80109ecb:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109ece:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ed1:	83 ec 08             	sub    $0x8,%esp
80109ed4:	50                   	push   %eax
80109ed5:	ff 75 e8             	push   -0x18(%ebp)
80109ed8:	e8 ff f0 ff ff       	call   80108fdc <i8254_send>
80109edd:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109ee0:	a1 44 d3 18 80       	mov    0x8018d344,%eax
80109ee5:	83 c0 01             	add    $0x1,%eax
80109ee8:	a3 44 d3 18 80       	mov    %eax,0x8018d344
80109eed:	e9 69 01 00 00       	jmp    8010a05b <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109ef2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ef5:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ef9:	3c 18                	cmp    $0x18,%al
80109efb:	0f 85 10 01 00 00    	jne    8010a011 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
80109f01:	83 ec 04             	sub    $0x4,%esp
80109f04:	6a 03                	push   $0x3
80109f06:	68 fe c5 10 80       	push   $0x8010c5fe
80109f0b:	ff 75 ec             	push   -0x14(%ebp)
80109f0e:	e8 24 ae ff ff       	call   80104d37 <memcmp>
80109f13:	83 c4 10             	add    $0x10,%esp
80109f16:	85 c0                	test   %eax,%eax
80109f18:	74 74                	je     80109f8e <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
80109f1a:	83 ec 0c             	sub    $0xc,%esp
80109f1d:	68 02 c6 10 80       	push   $0x8010c602
80109f22:	e8 e5 64 ff ff       	call   8010040c <cprintf>
80109f27:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109f2a:	83 ec 0c             	sub    $0xc,%esp
80109f2d:	6a 00                	push   $0x0
80109f2f:	6a 10                	push   $0x10
80109f31:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f34:	50                   	push   %eax
80109f35:	ff 75 e8             	push   -0x18(%ebp)
80109f38:	ff 75 08             	push   0x8(%ebp)
80109f3b:	e8 2d 01 00 00       	call   8010a06d <tcp_pkt_create>
80109f40:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109f43:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f46:	83 ec 08             	sub    $0x8,%esp
80109f49:	50                   	push   %eax
80109f4a:	ff 75 e8             	push   -0x18(%ebp)
80109f4d:	e8 8a f0 ff ff       	call   80108fdc <i8254_send>
80109f52:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109f55:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f58:	83 c0 36             	add    $0x36,%eax
80109f5b:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109f5e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109f61:	50                   	push   %eax
80109f62:	ff 75 e0             	push   -0x20(%ebp)
80109f65:	6a 00                	push   $0x0
80109f67:	6a 00                	push   $0x0
80109f69:	e8 66 04 00 00       	call   8010a3d4 <http_proc>
80109f6e:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109f71:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109f74:	83 ec 0c             	sub    $0xc,%esp
80109f77:	50                   	push   %eax
80109f78:	6a 18                	push   $0x18
80109f7a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f7d:	50                   	push   %eax
80109f7e:	ff 75 e8             	push   -0x18(%ebp)
80109f81:	ff 75 08             	push   0x8(%ebp)
80109f84:	e8 e4 00 00 00       	call   8010a06d <tcp_pkt_create>
80109f89:	83 c4 20             	add    $0x20,%esp
80109f8c:	eb 62                	jmp    80109ff0 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109f8e:	83 ec 0c             	sub    $0xc,%esp
80109f91:	6a 00                	push   $0x0
80109f93:	6a 10                	push   $0x10
80109f95:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f98:	50                   	push   %eax
80109f99:	ff 75 e8             	push   -0x18(%ebp)
80109f9c:	ff 75 08             	push   0x8(%ebp)
80109f9f:	e8 c9 00 00 00       	call   8010a06d <tcp_pkt_create>
80109fa4:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109fa7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109faa:	83 ec 08             	sub    $0x8,%esp
80109fad:	50                   	push   %eax
80109fae:	ff 75 e8             	push   -0x18(%ebp)
80109fb1:	e8 26 f0 ff ff       	call   80108fdc <i8254_send>
80109fb6:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109fb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fbc:	83 c0 36             	add    $0x36,%eax
80109fbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109fc2:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109fc5:	50                   	push   %eax
80109fc6:	ff 75 e4             	push   -0x1c(%ebp)
80109fc9:	6a 00                	push   $0x0
80109fcb:	6a 00                	push   $0x0
80109fcd:	e8 02 04 00 00       	call   8010a3d4 <http_proc>
80109fd2:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109fd5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109fd8:	83 ec 0c             	sub    $0xc,%esp
80109fdb:	50                   	push   %eax
80109fdc:	6a 18                	push   $0x18
80109fde:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109fe1:	50                   	push   %eax
80109fe2:	ff 75 e8             	push   -0x18(%ebp)
80109fe5:	ff 75 08             	push   0x8(%ebp)
80109fe8:	e8 80 00 00 00       	call   8010a06d <tcp_pkt_create>
80109fed:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109ff0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ff3:	83 ec 08             	sub    $0x8,%esp
80109ff6:	50                   	push   %eax
80109ff7:	ff 75 e8             	push   -0x18(%ebp)
80109ffa:	e8 dd ef ff ff       	call   80108fdc <i8254_send>
80109fff:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a002:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a007:	83 c0 01             	add    $0x1,%eax
8010a00a:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a00f:	eb 4a                	jmp    8010a05b <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a011:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a014:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a018:	3c 10                	cmp    $0x10,%al
8010a01a:	75 3f                	jne    8010a05b <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a01c:	a1 48 d3 18 80       	mov    0x8018d348,%eax
8010a021:	83 f8 01             	cmp    $0x1,%eax
8010a024:	75 35                	jne    8010a05b <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a026:	83 ec 0c             	sub    $0xc,%esp
8010a029:	6a 00                	push   $0x0
8010a02b:	6a 01                	push   $0x1
8010a02d:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a030:	50                   	push   %eax
8010a031:	ff 75 e8             	push   -0x18(%ebp)
8010a034:	ff 75 08             	push   0x8(%ebp)
8010a037:	e8 31 00 00 00       	call   8010a06d <tcp_pkt_create>
8010a03c:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a03f:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a042:	83 ec 08             	sub    $0x8,%esp
8010a045:	50                   	push   %eax
8010a046:	ff 75 e8             	push   -0x18(%ebp)
8010a049:	e8 8e ef ff ff       	call   80108fdc <i8254_send>
8010a04e:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a051:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
8010a058:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a05b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a05e:	83 ec 0c             	sub    $0xc,%esp
8010a061:	50                   	push   %eax
8010a062:	e8 9d 87 ff ff       	call   80102804 <kfree>
8010a067:	83 c4 10             	add    $0x10,%esp
}
8010a06a:	90                   	nop
8010a06b:	c9                   	leave
8010a06c:	c3                   	ret

8010a06d <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a06d:	f3 0f 1e fb          	endbr32
8010a071:	55                   	push   %ebp
8010a072:	89 e5                	mov    %esp,%ebp
8010a074:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a077:	8b 45 08             	mov    0x8(%ebp),%eax
8010a07a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a07d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a080:	83 c0 0e             	add    $0xe,%eax
8010a083:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a086:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a089:	0f b6 00             	movzbl (%eax),%eax
8010a08c:	0f b6 c0             	movzbl %al,%eax
8010a08f:	83 e0 0f             	and    $0xf,%eax
8010a092:	c1 e0 02             	shl    $0x2,%eax
8010a095:	89 c2                	mov    %eax,%edx
8010a097:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a09a:	01 d0                	add    %edx,%eax
8010a09c:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a09f:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a0a2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a0a5:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a0a8:	83 c0 0e             	add    $0xe,%eax
8010a0ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a0ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0b1:	83 c0 14             	add    $0x14,%eax
8010a0b4:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a0b7:	8b 45 18             	mov    0x18(%ebp),%eax
8010a0ba:	8d 50 36             	lea    0x36(%eax),%edx
8010a0bd:	8b 45 10             	mov    0x10(%ebp),%eax
8010a0c0:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a0c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0c5:	8d 50 06             	lea    0x6(%eax),%edx
8010a0c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0cb:	83 ec 04             	sub    $0x4,%esp
8010a0ce:	6a 06                	push   $0x6
8010a0d0:	52                   	push   %edx
8010a0d1:	50                   	push   %eax
8010a0d2:	e8 bc ac ff ff       	call   80104d93 <memmove>
8010a0d7:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a0da:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0dd:	83 c0 06             	add    $0x6,%eax
8010a0e0:	83 ec 04             	sub    $0x4,%esp
8010a0e3:	6a 06                	push   $0x6
8010a0e5:	68 68 d0 18 80       	push   $0x8018d068
8010a0ea:	50                   	push   %eax
8010a0eb:	e8 a3 ac ff ff       	call   80104d93 <memmove>
8010a0f0:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a0f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0f6:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a0fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0fd:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a101:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a104:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a107:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a10a:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a10e:	8b 45 18             	mov    0x18(%ebp),%eax
8010a111:	83 c0 28             	add    $0x28,%eax
8010a114:	0f b7 c0             	movzwl %ax,%eax
8010a117:	83 ec 0c             	sub    $0xc,%esp
8010a11a:	50                   	push   %eax
8010a11b:	e8 6f f8 ff ff       	call   8010998f <H2N_ushort>
8010a120:	83 c4 10             	add    $0x10,%esp
8010a123:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a126:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a12a:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a131:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a134:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a138:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a13f:	83 c0 01             	add    $0x1,%eax
8010a142:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a148:	83 ec 0c             	sub    $0xc,%esp
8010a14b:	6a 00                	push   $0x0
8010a14d:	e8 3d f8 ff ff       	call   8010998f <H2N_ushort>
8010a152:	83 c4 10             	add    $0x10,%esp
8010a155:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a158:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a15c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a15f:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a163:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a166:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a16a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a16d:	83 c0 0c             	add    $0xc,%eax
8010a170:	83 ec 04             	sub    $0x4,%esp
8010a173:	6a 04                	push   $0x4
8010a175:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a17a:	50                   	push   %eax
8010a17b:	e8 13 ac ff ff       	call   80104d93 <memmove>
8010a180:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a183:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a186:	8d 50 0c             	lea    0xc(%eax),%edx
8010a189:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a18c:	83 c0 10             	add    $0x10,%eax
8010a18f:	83 ec 04             	sub    $0x4,%esp
8010a192:	6a 04                	push   $0x4
8010a194:	52                   	push   %edx
8010a195:	50                   	push   %eax
8010a196:	e8 f8 ab ff ff       	call   80104d93 <memmove>
8010a19b:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a19e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1a1:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a1a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1aa:	83 ec 0c             	sub    $0xc,%esp
8010a1ad:	50                   	push   %eax
8010a1ae:	e8 ec f8 ff ff       	call   80109a9f <ipv4_chksum>
8010a1b3:	83 c4 10             	add    $0x10,%esp
8010a1b6:	0f b7 c0             	movzwl %ax,%eax
8010a1b9:	83 ec 0c             	sub    $0xc,%esp
8010a1bc:	50                   	push   %eax
8010a1bd:	e8 cd f7 ff ff       	call   8010998f <H2N_ushort>
8010a1c2:	83 c4 10             	add    $0x10,%esp
8010a1c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a1c8:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a1cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1cf:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a1d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1d6:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a1d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1dc:	0f b7 10             	movzwl (%eax),%edx
8010a1df:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1e2:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a1e6:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a1eb:	83 ec 0c             	sub    $0xc,%esp
8010a1ee:	50                   	push   %eax
8010a1ef:	e8 c1 f7 ff ff       	call   801099b5 <H2N_uint>
8010a1f4:	83 c4 10             	add    $0x10,%esp
8010a1f7:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a1fa:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a1fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a200:	8b 40 04             	mov    0x4(%eax),%eax
8010a203:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a209:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a20c:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a20f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a212:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a216:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a219:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a21d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a220:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a224:	8b 45 14             	mov    0x14(%ebp),%eax
8010a227:	89 c2                	mov    %eax,%edx
8010a229:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a22c:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a22f:	83 ec 0c             	sub    $0xc,%esp
8010a232:	68 90 38 00 00       	push   $0x3890
8010a237:	e8 53 f7 ff ff       	call   8010998f <H2N_ushort>
8010a23c:	83 c4 10             	add    $0x10,%esp
8010a23f:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a242:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a246:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a249:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a24f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a252:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a258:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a25b:	83 ec 0c             	sub    $0xc,%esp
8010a25e:	50                   	push   %eax
8010a25f:	e8 1f 00 00 00       	call   8010a283 <tcp_chksum>
8010a264:	83 c4 10             	add    $0x10,%esp
8010a267:	83 c0 08             	add    $0x8,%eax
8010a26a:	0f b7 c0             	movzwl %ax,%eax
8010a26d:	83 ec 0c             	sub    $0xc,%esp
8010a270:	50                   	push   %eax
8010a271:	e8 19 f7 ff ff       	call   8010998f <H2N_ushort>
8010a276:	83 c4 10             	add    $0x10,%esp
8010a279:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a27c:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a280:	90                   	nop
8010a281:	c9                   	leave
8010a282:	c3                   	ret

8010a283 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a283:	f3 0f 1e fb          	endbr32
8010a287:	55                   	push   %ebp
8010a288:	89 e5                	mov    %esp,%ebp
8010a28a:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a28d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a290:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a293:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a296:	83 c0 14             	add    $0x14,%eax
8010a299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a29c:	83 ec 04             	sub    $0x4,%esp
8010a29f:	6a 04                	push   $0x4
8010a2a1:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a2a6:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a2a9:	50                   	push   %eax
8010a2aa:	e8 e4 aa ff ff       	call   80104d93 <memmove>
8010a2af:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a2b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2b5:	83 c0 0c             	add    $0xc,%eax
8010a2b8:	83 ec 04             	sub    $0x4,%esp
8010a2bb:	6a 04                	push   $0x4
8010a2bd:	50                   	push   %eax
8010a2be:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a2c1:	83 c0 04             	add    $0x4,%eax
8010a2c4:	50                   	push   %eax
8010a2c5:	e8 c9 aa ff ff       	call   80104d93 <memmove>
8010a2ca:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a2cd:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a2d1:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a2d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2d8:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a2dc:	0f b7 c0             	movzwl %ax,%eax
8010a2df:	83 ec 0c             	sub    $0xc,%esp
8010a2e2:	50                   	push   %eax
8010a2e3:	e8 81 f6 ff ff       	call   80109969 <N2H_ushort>
8010a2e8:	83 c4 10             	add    $0x10,%esp
8010a2eb:	83 e8 14             	sub    $0x14,%eax
8010a2ee:	0f b7 c0             	movzwl %ax,%eax
8010a2f1:	83 ec 0c             	sub    $0xc,%esp
8010a2f4:	50                   	push   %eax
8010a2f5:	e8 95 f6 ff ff       	call   8010998f <H2N_ushort>
8010a2fa:	83 c4 10             	add    $0x10,%esp
8010a2fd:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a301:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a308:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a30b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a30e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a315:	eb 33                	jmp    8010a34a <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a317:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a31a:	01 c0                	add    %eax,%eax
8010a31c:	89 c2                	mov    %eax,%edx
8010a31e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a321:	01 d0                	add    %edx,%eax
8010a323:	0f b6 00             	movzbl (%eax),%eax
8010a326:	0f b6 c0             	movzbl %al,%eax
8010a329:	c1 e0 08             	shl    $0x8,%eax
8010a32c:	89 c2                	mov    %eax,%edx
8010a32e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a331:	01 c0                	add    %eax,%eax
8010a333:	8d 48 01             	lea    0x1(%eax),%ecx
8010a336:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a339:	01 c8                	add    %ecx,%eax
8010a33b:	0f b6 00             	movzbl (%eax),%eax
8010a33e:	0f b6 c0             	movzbl %al,%eax
8010a341:	01 d0                	add    %edx,%eax
8010a343:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a346:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a34a:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a34e:	7e c7                	jle    8010a317 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a350:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a353:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a356:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a35d:	eb 33                	jmp    8010a392 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a35f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a362:	01 c0                	add    %eax,%eax
8010a364:	89 c2                	mov    %eax,%edx
8010a366:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a369:	01 d0                	add    %edx,%eax
8010a36b:	0f b6 00             	movzbl (%eax),%eax
8010a36e:	0f b6 c0             	movzbl %al,%eax
8010a371:	c1 e0 08             	shl    $0x8,%eax
8010a374:	89 c2                	mov    %eax,%edx
8010a376:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a379:	01 c0                	add    %eax,%eax
8010a37b:	8d 48 01             	lea    0x1(%eax),%ecx
8010a37e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a381:	01 c8                	add    %ecx,%eax
8010a383:	0f b6 00             	movzbl (%eax),%eax
8010a386:	0f b6 c0             	movzbl %al,%eax
8010a389:	01 d0                	add    %edx,%eax
8010a38b:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a38e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a392:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a396:	0f b7 c0             	movzwl %ax,%eax
8010a399:	83 ec 0c             	sub    $0xc,%esp
8010a39c:	50                   	push   %eax
8010a39d:	e8 c7 f5 ff ff       	call   80109969 <N2H_ushort>
8010a3a2:	83 c4 10             	add    $0x10,%esp
8010a3a5:	66 d1 e8             	shr    $1,%ax
8010a3a8:	0f b7 c0             	movzwl %ax,%eax
8010a3ab:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a3ae:	7c af                	jl     8010a35f <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a3b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a3b3:	c1 e8 10             	shr    $0x10,%eax
8010a3b6:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a3b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a3bc:	f7 d0                	not    %eax
}
8010a3be:	c9                   	leave
8010a3bf:	c3                   	ret

8010a3c0 <tcp_fin>:

void tcp_fin(){
8010a3c0:	f3 0f 1e fb          	endbr32
8010a3c4:	55                   	push   %ebp
8010a3c5:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a3c7:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a3ce:	00 00 00 
}
8010a3d1:	90                   	nop
8010a3d2:	5d                   	pop    %ebp
8010a3d3:	c3                   	ret

8010a3d4 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a3d4:	f3 0f 1e fb          	endbr32
8010a3d8:	55                   	push   %ebp
8010a3d9:	89 e5                	mov    %esp,%ebp
8010a3db:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a3de:	8b 45 10             	mov    0x10(%ebp),%eax
8010a3e1:	83 ec 04             	sub    $0x4,%esp
8010a3e4:	6a 00                	push   $0x0
8010a3e6:	68 0b c6 10 80       	push   $0x8010c60b
8010a3eb:	50                   	push   %eax
8010a3ec:	e8 65 00 00 00       	call   8010a456 <http_strcpy>
8010a3f1:	83 c4 10             	add    $0x10,%esp
8010a3f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a3f7:	8b 45 10             	mov    0x10(%ebp),%eax
8010a3fa:	83 ec 04             	sub    $0x4,%esp
8010a3fd:	ff 75 f4             	push   -0xc(%ebp)
8010a400:	68 1e c6 10 80       	push   $0x8010c61e
8010a405:	50                   	push   %eax
8010a406:	e8 4b 00 00 00       	call   8010a456 <http_strcpy>
8010a40b:	83 c4 10             	add    $0x10,%esp
8010a40e:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a411:	8b 45 10             	mov    0x10(%ebp),%eax
8010a414:	83 ec 04             	sub    $0x4,%esp
8010a417:	ff 75 f4             	push   -0xc(%ebp)
8010a41a:	68 39 c6 10 80       	push   $0x8010c639
8010a41f:	50                   	push   %eax
8010a420:	e8 31 00 00 00       	call   8010a456 <http_strcpy>
8010a425:	83 c4 10             	add    $0x10,%esp
8010a428:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a42b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a42e:	83 e0 01             	and    $0x1,%eax
8010a431:	85 c0                	test   %eax,%eax
8010a433:	74 11                	je     8010a446 <http_proc+0x72>
    char *payload = (char *)send;
8010a435:	8b 45 10             	mov    0x10(%ebp),%eax
8010a438:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a43b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a43e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a441:	01 d0                	add    %edx,%eax
8010a443:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a446:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a449:	8b 45 14             	mov    0x14(%ebp),%eax
8010a44c:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a44e:	e8 6d ff ff ff       	call   8010a3c0 <tcp_fin>
}
8010a453:	90                   	nop
8010a454:	c9                   	leave
8010a455:	c3                   	ret

8010a456 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a456:	f3 0f 1e fb          	endbr32
8010a45a:	55                   	push   %ebp
8010a45b:	89 e5                	mov    %esp,%ebp
8010a45d:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a460:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a467:	eb 20                	jmp    8010a489 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a469:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a46c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a46f:	01 d0                	add    %edx,%eax
8010a471:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a474:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a477:	01 ca                	add    %ecx,%edx
8010a479:	89 d1                	mov    %edx,%ecx
8010a47b:	8b 55 08             	mov    0x8(%ebp),%edx
8010a47e:	01 ca                	add    %ecx,%edx
8010a480:	0f b6 00             	movzbl (%eax),%eax
8010a483:	88 02                	mov    %al,(%edx)
    i++;
8010a485:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a489:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a48c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a48f:	01 d0                	add    %edx,%eax
8010a491:	0f b6 00             	movzbl (%eax),%eax
8010a494:	84 c0                	test   %al,%al
8010a496:	75 d1                	jne    8010a469 <http_strcpy+0x13>
  }
  return i;
8010a498:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a49b:	c9                   	leave
8010a49c:	c3                   	ret

8010a49d <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a49d:	f3 0f 1e fb          	endbr32
8010a4a1:	55                   	push   %ebp
8010a4a2:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a4a4:	c7 05 50 d3 18 80 a2 	movl   $0x8010f5a2,0x8018d350
8010a4ab:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a4ae:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a4b3:	c1 e8 09             	shr    $0x9,%eax
8010a4b6:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a4bb:	90                   	nop
8010a4bc:	5d                   	pop    %ebp
8010a4bd:	c3                   	ret

8010a4be <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a4be:	f3 0f 1e fb          	endbr32
8010a4c2:	55                   	push   %ebp
8010a4c3:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a4c5:	90                   	nop
8010a4c6:	5d                   	pop    %ebp
8010a4c7:	c3                   	ret

8010a4c8 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a4c8:	f3 0f 1e fb          	endbr32
8010a4cc:	55                   	push   %ebp
8010a4cd:	89 e5                	mov    %esp,%ebp
8010a4cf:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a4d2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4d5:	83 c0 0c             	add    $0xc,%eax
8010a4d8:	83 ec 0c             	sub    $0xc,%esp
8010a4db:	50                   	push   %eax
8010a4dc:	e8 c3 a4 ff ff       	call   801049a4 <holdingsleep>
8010a4e1:	83 c4 10             	add    $0x10,%esp
8010a4e4:	85 c0                	test   %eax,%eax
8010a4e6:	75 0d                	jne    8010a4f5 <iderw+0x2d>
    panic("iderw: buf not locked");
8010a4e8:	83 ec 0c             	sub    $0xc,%esp
8010a4eb:	68 4a c6 10 80       	push   $0x8010c64a
8010a4f0:	e8 e9 60 ff ff       	call   801005de <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a4f5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4f8:	8b 00                	mov    (%eax),%eax
8010a4fa:	83 e0 06             	and    $0x6,%eax
8010a4fd:	83 f8 02             	cmp    $0x2,%eax
8010a500:	75 0d                	jne    8010a50f <iderw+0x47>
    panic("iderw: nothing to do");
8010a502:	83 ec 0c             	sub    $0xc,%esp
8010a505:	68 60 c6 10 80       	push   $0x8010c660
8010a50a:	e8 cf 60 ff ff       	call   801005de <panic>
  if(b->dev != 1)
8010a50f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a512:	8b 40 04             	mov    0x4(%eax),%eax
8010a515:	83 f8 01             	cmp    $0x1,%eax
8010a518:	74 0d                	je     8010a527 <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a51a:	83 ec 0c             	sub    $0xc,%esp
8010a51d:	68 75 c6 10 80       	push   $0x8010c675
8010a522:	e8 b7 60 ff ff       	call   801005de <panic>
  if(b->blockno >= disksize)
8010a527:	8b 45 08             	mov    0x8(%ebp),%eax
8010a52a:	8b 40 08             	mov    0x8(%eax),%eax
8010a52d:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a533:	39 d0                	cmp    %edx,%eax
8010a535:	72 0d                	jb     8010a544 <iderw+0x7c>
    panic("iderw: block out of range");
8010a537:	83 ec 0c             	sub    $0xc,%esp
8010a53a:	68 93 c6 10 80       	push   $0x8010c693
8010a53f:	e8 9a 60 ff ff       	call   801005de <panic>

  p = memdisk + b->blockno*BSIZE;
8010a544:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a54a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a54d:	8b 40 08             	mov    0x8(%eax),%eax
8010a550:	c1 e0 09             	shl    $0x9,%eax
8010a553:	01 d0                	add    %edx,%eax
8010a555:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a558:	8b 45 08             	mov    0x8(%ebp),%eax
8010a55b:	8b 00                	mov    (%eax),%eax
8010a55d:	83 e0 04             	and    $0x4,%eax
8010a560:	85 c0                	test   %eax,%eax
8010a562:	74 2b                	je     8010a58f <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a564:	8b 45 08             	mov    0x8(%ebp),%eax
8010a567:	8b 00                	mov    (%eax),%eax
8010a569:	83 e0 fb             	and    $0xfffffffb,%eax
8010a56c:	89 c2                	mov    %eax,%edx
8010a56e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a571:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a573:	8b 45 08             	mov    0x8(%ebp),%eax
8010a576:	83 c0 5c             	add    $0x5c,%eax
8010a579:	83 ec 04             	sub    $0x4,%esp
8010a57c:	68 00 02 00 00       	push   $0x200
8010a581:	50                   	push   %eax
8010a582:	ff 75 f4             	push   -0xc(%ebp)
8010a585:	e8 09 a8 ff ff       	call   80104d93 <memmove>
8010a58a:	83 c4 10             	add    $0x10,%esp
8010a58d:	eb 1a                	jmp    8010a5a9 <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a58f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a592:	83 c0 5c             	add    $0x5c,%eax
8010a595:	83 ec 04             	sub    $0x4,%esp
8010a598:	68 00 02 00 00       	push   $0x200
8010a59d:	ff 75 f4             	push   -0xc(%ebp)
8010a5a0:	50                   	push   %eax
8010a5a1:	e8 ed a7 ff ff       	call   80104d93 <memmove>
8010a5a6:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a5a9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5ac:	8b 00                	mov    (%eax),%eax
8010a5ae:	83 c8 02             	or     $0x2,%eax
8010a5b1:	89 c2                	mov    %eax,%edx
8010a5b3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5b6:	89 10                	mov    %edx,(%eax)
}
8010a5b8:	90                   	nop
8010a5b9:	c9                   	leave
8010a5ba:	c3                   	ret
