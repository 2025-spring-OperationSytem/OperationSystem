
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
8010005f:	ba 04 35 10 80       	mov    $0x80103504,%edx
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
80100073:	68 60 a6 10 80       	push   $0x8010a660
80100078:	68 60 e3 18 80       	push   $0x8018e360
8010007d:	e8 34 4a 00 00       	call   80104ab6 <initlock>
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
801000c1:	68 67 a6 10 80       	push   $0x8010a667
801000c6:	50                   	push   %eax
801000c7:	e8 7d 48 00 00       	call   80104949 <initsleeplock>
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
80100109:	e8 ce 49 00 00       	call   80104adc <acquire>
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
80100148:	e8 01 4a 00 00       	call   80104b4e <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 2a 48 00 00       	call   80104989 <acquiresleep>
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
801001c9:	e8 80 49 00 00       	call   80104b4e <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 a9 47 00 00       	call   80104989 <acquiresleep>
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
801001fd:	68 6e a6 10 80       	push   $0x8010a66e
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
80100239:	e8 28 a3 00 00       	call   8010a566 <iderw>
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
8010025a:	e8 e4 47 00 00       	call   80104a43 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 7f a6 10 80       	push   $0x8010a67f
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
80100288:	e8 d9 a2 00 00       	call   8010a566 <iderw>
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
801002a7:	e8 97 47 00 00       	call   80104a43 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 86 a6 10 80       	push   $0x8010a686
801002bb:	e8 1e 03 00 00       	call   801005de <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 22 47 00 00       	call   801049f1 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 fd 47 00 00       	call   80104adc <acquire>
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
8010034a:	e8 ff 47 00 00       	call   80104b4e <release>
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
8010042c:	e8 ab 46 00 00       	call   80104adc <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 90 a6 10 80       	push   $0x8010a690
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
801004ce:	8b 04 85 a0 a6 10 80 	mov    -0x7fef5960(,%eax,4),%eax
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
8010052c:	c7 45 ec 99 a6 10 80 	movl   $0x8010a699,-0x14(%ebp)
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
801005d3:	e8 76 45 00 00       	call   80104b4e <release>
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
801005f7:	e8 59 26 00 00       	call   80102c55 <lapicid>
801005fc:	83 ec 08             	sub    $0x8,%esp
801005ff:	50                   	push   %eax
80100600:	68 f8 a6 10 80       	push   $0x8010a6f8
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
8010061f:	68 0c a7 10 80       	push   $0x8010a70c
80100624:	e8 e3 fd ff ff       	call   8010040c <cprintf>
80100629:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
8010062c:	83 ec 08             	sub    $0x8,%esp
8010062f:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100632:	50                   	push   %eax
80100633:	8d 45 08             	lea    0x8(%ebp),%eax
80100636:	50                   	push   %eax
80100637:	e8 68 45 00 00       	call   80104ba4 <getcallerpcs>
8010063c:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010063f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100646:	eb 1c                	jmp    80100664 <panic+0x86>
    cprintf(" %p", pcs[i]);
80100648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010064b:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010064f:	83 ec 08             	sub    $0x8,%esp
80100652:	50                   	push   %eax
80100653:	68 0e a7 10 80       	push   $0x8010a70e
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
801006dd:	e8 18 7d 00 00       	call   801083fa <graphic_scroll_up>
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
80100730:	e8 c5 7c 00 00       	call   801083fa <graphic_scroll_up>
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
80100796:	e8 d3 7c 00 00       	call   8010846e <font_render>
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
801007d6:	e8 f7 5f 00 00       	call   801067d2 <uartputc>
801007db:	83 c4 10             	add    $0x10,%esp
801007de:	83 ec 0c             	sub    $0xc,%esp
801007e1:	6a 20                	push   $0x20
801007e3:	e8 ea 5f 00 00       	call   801067d2 <uartputc>
801007e8:	83 c4 10             	add    $0x10,%esp
801007eb:	83 ec 0c             	sub    $0xc,%esp
801007ee:	6a 08                	push   $0x8
801007f0:	e8 dd 5f 00 00       	call   801067d2 <uartputc>
801007f5:	83 c4 10             	add    $0x10,%esp
801007f8:	eb 0e                	jmp    80100808 <consputc+0x5a>
  } else {
    uartputc(c);
801007fa:	83 ec 0c             	sub    $0xc,%esp
801007fd:	ff 75 08             	push   0x8(%ebp)
80100800:	e8 cd 5f 00 00       	call   801067d2 <uartputc>
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
80100832:	e8 a5 42 00 00       	call   80104adc <acquire>
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
80100988:	e8 c5 3c 00 00       	call   80104652 <wakeup>
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
801009ab:	e8 9e 41 00 00       	call   80104b4e <release>
801009b0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b7:	74 05                	je     801009be <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009b9:	e8 57 3d 00 00       	call   80104715 <procdump>
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
801009d1:	e8 13 12 00 00       	call   80101be9 <iunlock>
801009d6:	83 c4 10             	add    $0x10,%esp
  target = n;
801009d9:	8b 45 10             	mov    0x10(%ebp),%eax
801009dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009df:	83 ec 0c             	sub    $0xc,%esp
801009e2:	68 20 d0 18 80       	push   $0x8018d020
801009e7:	e8 f0 40 00 00       	call   80104adc <acquire>
801009ec:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009ef:	e9 ab 00 00 00       	jmp    80100a9f <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
801009f4:	e8 06 32 00 00       	call   80103bff <myproc>
801009f9:	8b 40 24             	mov    0x24(%eax),%eax
801009fc:	85 c0                	test   %eax,%eax
801009fe:	74 28                	je     80100a28 <consoleread+0x67>
        release(&cons.lock);
80100a00:	83 ec 0c             	sub    $0xc,%esp
80100a03:	68 20 d0 18 80       	push   $0x8018d020
80100a08:	e8 41 41 00 00       	call   80104b4e <release>
80100a0d:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a10:	83 ec 0c             	sub    $0xc,%esp
80100a13:	ff 75 08             	push   0x8(%ebp)
80100a16:	e8 b7 10 00 00       	call   80101ad2 <ilock>
80100a1b:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a23:	e9 ab 00 00 00       	jmp    80100ad3 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100a28:	83 ec 08             	sub    $0x8,%esp
80100a2b:	68 20 d0 18 80       	push   $0x8018d020
80100a30:	68 40 2d 19 80       	push   $0x80192d40
80100a35:	e8 29 3b 00 00       	call   80104563 <sleep>
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
80100ab3:	e8 96 40 00 00       	call   80104b4e <release>
80100ab8:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100abb:	83 ec 0c             	sub    $0xc,%esp
80100abe:	ff 75 08             	push   0x8(%ebp)
80100ac1:	e8 0c 10 00 00       	call   80101ad2 <ilock>
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
80100ae5:	e8 ff 10 00 00       	call   80101be9 <iunlock>
80100aea:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100aed:	83 ec 0c             	sub    $0xc,%esp
80100af0:	68 20 d0 18 80       	push   $0x8018d020
80100af5:	e8 e2 3f 00 00       	call   80104adc <acquire>
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
80100b37:	e8 12 40 00 00       	call   80104b4e <release>
80100b3c:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b3f:	83 ec 0c             	sub    $0xc,%esp
80100b42:	ff 75 08             	push   0x8(%ebp)
80100b45:	e8 88 0f 00 00       	call   80101ad2 <ilock>
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
80100b69:	68 12 a7 10 80       	push   $0x8010a712
80100b6e:	68 20 d0 18 80       	push   $0x8018d020
80100b73:	e8 3e 3f 00 00       	call   80104ab6 <initlock>
80100b78:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b7b:	c7 05 0c 37 19 80 d5 	movl   $0x80100ad5,0x8019370c
80100b82:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b85:	c7 05 08 37 19 80 c1 	movl   $0x801009c1,0x80193708
80100b8c:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b8f:	c7 45 f4 1a a7 10 80 	movl   $0x8010a71a,-0xc(%ebp)
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
80100bcc:	e8 91 1b 00 00       	call   80102762 <ioapicenable>
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
80100be4:	e8 16 30 00 00       	call   80103bff <myproc>
80100be9:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bec:	e8 d6 25 00 00       	call   801031c7 <begin_op>

  if((ip = namei(path)) == 0){
80100bf1:	83 ec 0c             	sub    $0xc,%esp
80100bf4:	ff 75 08             	push   0x8(%ebp)
80100bf7:	e8 41 1a 00 00       	call   8010263d <namei>
80100bfc:	83 c4 10             	add    $0x10,%esp
80100bff:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c02:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c06:	75 1f                	jne    80100c27 <exec+0x50>
    end_op();
80100c08:	e8 4a 26 00 00       	call   80103257 <end_op>
    cprintf("exec: fail\n");
80100c0d:	83 ec 0c             	sub    $0xc,%esp
80100c10:	68 30 a7 10 80       	push   $0x8010a730
80100c15:	e8 f2 f7 ff ff       	call   8010040c <cprintf>
80100c1a:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c22:	e9 2e 04 00 00       	jmp    80101055 <exec+0x47e>
  }
  ilock(ip);
80100c27:	83 ec 0c             	sub    $0xc,%esp
80100c2a:	ff 75 d8             	push   -0x28(%ebp)
80100c2d:	e8 a0 0e 00 00       	call   80101ad2 <ilock>
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
80100c4a:	e8 8b 13 00 00       	call   80101fda <readi>
80100c4f:	83 c4 10             	add    $0x10,%esp
80100c52:	83 f8 34             	cmp    $0x34,%eax
80100c55:	0f 85 93 03 00 00    	jne    80100fee <exec+0x417>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c5b:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c61:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c66:	0f 85 85 03 00 00    	jne    80100ff1 <exec+0x41a>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c6c:	e8 75 6b 00 00       	call   801077e6 <setupkvm>
80100c71:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c74:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c78:	0f 84 76 03 00 00    	je     80100ff4 <exec+0x41d>
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
80100caa:	e8 2b 13 00 00       	call   80101fda <readi>
80100caf:	83 c4 10             	add    $0x10,%esp
80100cb2:	83 f8 20             	cmp    $0x20,%eax
80100cb5:	0f 85 3c 03 00 00    	jne    80100ff7 <exec+0x420>
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
80100cd8:	0f 82 1c 03 00 00    	jb     80100ffa <exec+0x423>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cde:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ce4:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cea:	01 c2                	add    %eax,%edx
80100cec:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cf2:	39 c2                	cmp    %eax,%edx
80100cf4:	0f 82 03 03 00 00    	jb     80100ffd <exec+0x426>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cfa:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d00:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d06:	01 d0                	add    %edx,%eax
80100d08:	83 ec 04             	sub    $0x4,%esp
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 e0             	push   -0x20(%ebp)
80100d0f:	ff 75 d4             	push   -0x2c(%ebp)
80100d12:	e8 e1 6e 00 00       	call   80107bf8 <allocuvm>
80100d17:	83 c4 10             	add    $0x10,%esp
80100d1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d21:	0f 84 d9 02 00 00    	je     80101000 <exec+0x429>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d27:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d2d:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d32:	85 c0                	test   %eax,%eax
80100d34:	0f 85 c9 02 00 00    	jne    80101003 <exec+0x42c>
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
80100d58:	e8 ca 6d 00 00       	call   80107b27 <loaduvm>
80100d5d:	83 c4 20             	add    $0x20,%esp
80100d60:	85 c0                	test   %eax,%eax
80100d62:	0f 88 9e 02 00 00    	js     80101006 <exec+0x42f>
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
80100d91:	e8 79 0f 00 00       	call   80101d0f <iunlockput>
80100d96:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d99:	e8 b9 24 00 00       	call   80103257 <end_op>
  ip = 0;
80100d9e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  cprintf("[exec] sz %x",sz);
80100da5:	83 ec 08             	sub    $0x8,%esp
80100da8:	ff 75 e0             	push   -0x20(%ebp)
80100dab:	68 3c a7 10 80       	push   $0x8010a73c
80100db0:	e8 57 f6 ff ff       	call   8010040c <cprintf>
80100db5:	83 c4 10             	add    $0x10,%esp
  // sz를 커널 베이스로 이동 페이지를 할당해야 하기 때문에 그 크기만큼 빼줌
  // 2*PGSIZE로 하면 페이지의 끝 주소가 커널 베이스가 되기 때문에 한단계 더 내린다.
  sz = PGROUNDDOWN(KERNBASE - 2*PGSIZE);
80100db8:	c7 45 e0 00 e0 ff 7f 	movl   $0x7fffe000,-0x20(%ebp)
  // 커널 베이스에서 PGSIZE만큼 할당
  if((sz = allocuvm(pgdir, sz, sz + PGSIZE)) == 0)
80100dbf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dc2:	05 00 10 00 00       	add    $0x1000,%eax
80100dc7:	83 ec 04             	sub    $0x4,%esp
80100dca:	50                   	push   %eax
80100dcb:	ff 75 e0             	push   -0x20(%ebp)
80100dce:	ff 75 d4             	push   -0x2c(%ebp)
80100dd1:	e8 22 6e 00 00       	call   80107bf8 <allocuvm>
80100dd6:	83 c4 10             	add    $0x10,%esp
80100dd9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ddc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100de0:	0f 84 23 02 00 00    	je     80101009 <exec+0x432>
    goto bad;
  cprintf("[exec] sz %x\n", sz);
80100de6:	83 ec 08             	sub    $0x8,%esp
80100de9:	ff 75 e0             	push   -0x20(%ebp)
80100dec:	68 49 a7 10 80       	push   $0x8010a749
80100df1:	e8 16 f6 ff ff       	call   8010040c <cprintf>
80100df6:	83 c4 10             	add    $0x10,%esp
  // 스택 포인터를 sz로
  sp = sz;
80100df9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dfc:	89 45 dc             	mov    %eax,-0x24(%ebp)
  sz = PGROUNDUP(0xb98)+1;
80100dff:	c7 45 e0 01 10 00 00 	movl   $0x1001,-0x20(%ebp)
  cprintf("[exec] allocuvm complete\n");
80100e06:	83 ec 0c             	sub    $0xc,%esp
80100e09:	68 57 a7 10 80       	push   $0x8010a757
80100e0e:	e8 f9 f5 ff ff       	call   8010040c <cprintf>
80100e13:	83 c4 10             	add    $0x10,%esp


  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e16:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e1d:	e9 96 00 00 00       	jmp    80100eb8 <exec+0x2e1>
    if(argc >= MAXARG)
80100e22:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e26:	0f 87 e0 01 00 00    	ja     8010100c <exec+0x435>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e36:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e39:	01 d0                	add    %edx,%eax
80100e3b:	8b 00                	mov    (%eax),%eax
80100e3d:	83 ec 0c             	sub    $0xc,%esp
80100e40:	50                   	push   %eax
80100e41:	e8 8e 41 00 00       	call   80104fd4 <strlen>
80100e46:	83 c4 10             	add    $0x10,%esp
80100e49:	89 c2                	mov    %eax,%edx
80100e4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e4e:	29 d0                	sub    %edx,%eax
80100e50:	83 e8 01             	sub    $0x1,%eax
80100e53:	83 e0 fc             	and    $0xfffffffc,%eax
80100e56:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e63:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e66:	01 d0                	add    %edx,%eax
80100e68:	8b 00                	mov    (%eax),%eax
80100e6a:	83 ec 0c             	sub    $0xc,%esp
80100e6d:	50                   	push   %eax
80100e6e:	e8 61 41 00 00       	call   80104fd4 <strlen>
80100e73:	83 c4 10             	add    $0x10,%esp
80100e76:	83 c0 01             	add    $0x1,%eax
80100e79:	89 c1                	mov    %eax,%ecx
80100e7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e7e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e85:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e88:	01 d0                	add    %edx,%eax
80100e8a:	8b 00                	mov    (%eax),%eax
80100e8c:	51                   	push   %ecx
80100e8d:	50                   	push   %eax
80100e8e:	ff 75 dc             	push   -0x24(%ebp)
80100e91:	ff 75 d4             	push   -0x2c(%ebp)
80100e94:	e8 b4 71 00 00       	call   8010804d <copyout>
80100e99:	83 c4 10             	add    $0x10,%esp
80100e9c:	85 c0                	test   %eax,%eax
80100e9e:	0f 88 6b 01 00 00    	js     8010100f <exec+0x438>
      goto bad;
    ustack[3+argc] = sp;
80100ea4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea7:	8d 50 03             	lea    0x3(%eax),%edx
80100eaa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ead:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100eb4:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100eb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ebb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ec5:	01 d0                	add    %edx,%eax
80100ec7:	8b 00                	mov    (%eax),%eax
80100ec9:	85 c0                	test   %eax,%eax
80100ecb:	0f 85 51 ff ff ff    	jne    80100e22 <exec+0x24b>
  }
  ustack[3+argc] = 0;
80100ed1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed4:	83 c0 03             	add    $0x3,%eax
80100ed7:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100ede:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ee2:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100ee9:	ff ff ff 
  ustack[1] = argc;
80100eec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eef:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ef5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ef8:	83 c0 01             	add    $0x1,%eax
80100efb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f02:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f05:	29 d0                	sub    %edx,%eax
80100f07:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100f0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f10:	83 c0 04             	add    $0x4,%eax
80100f13:	c1 e0 02             	shl    $0x2,%eax
80100f16:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f1c:	83 c0 04             	add    $0x4,%eax
80100f1f:	c1 e0 02             	shl    $0x2,%eax
80100f22:	50                   	push   %eax
80100f23:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100f29:	50                   	push   %eax
80100f2a:	ff 75 dc             	push   -0x24(%ebp)
80100f2d:	ff 75 d4             	push   -0x2c(%ebp)
80100f30:	e8 18 71 00 00       	call   8010804d <copyout>
80100f35:	83 c4 10             	add    $0x10,%esp
80100f38:	85 c0                	test   %eax,%eax
80100f3a:	0f 88 d2 00 00 00    	js     80101012 <exec+0x43b>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f40:	8b 45 08             	mov    0x8(%ebp),%eax
80100f43:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f49:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f4c:	eb 17                	jmp    80100f65 <exec+0x38e>
    if(*s == '/')
80100f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f51:	0f b6 00             	movzbl (%eax),%eax
80100f54:	3c 2f                	cmp    $0x2f,%al
80100f56:	75 09                	jne    80100f61 <exec+0x38a>
      last = s+1;
80100f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f5b:	83 c0 01             	add    $0x1,%eax
80100f5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f61:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f68:	0f b6 00             	movzbl (%eax),%eax
80100f6b:	84 c0                	test   %al,%al
80100f6d:	75 df                	jne    80100f4e <exec+0x377>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f6f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f72:	83 c0 6c             	add    $0x6c,%eax
80100f75:	83 ec 04             	sub    $0x4,%esp
80100f78:	6a 10                	push   $0x10
80100f7a:	ff 75 f0             	push   -0x10(%ebp)
80100f7d:	50                   	push   %eax
80100f7e:	e8 03 40 00 00       	call   80104f86 <safestrcpy>
80100f83:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f86:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f89:	8b 40 04             	mov    0x4(%eax),%eax
80100f8c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f92:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f95:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f98:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f9b:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f9e:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fa0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fa3:	8b 40 18             	mov    0x18(%eax),%eax
80100fa6:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100fac:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100faf:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fb2:	8b 40 18             	mov    0x18(%eax),%eax
80100fb5:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100fb8:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100fbb:	83 ec 0c             	sub    $0xc,%esp
80100fbe:	ff 75 d0             	push   -0x30(%ebp)
80100fc1:	e8 4a 69 00 00       	call   80107910 <switchuvm>
80100fc6:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fc9:	83 ec 0c             	sub    $0xc,%esp
80100fcc:	ff 75 cc             	push   -0x34(%ebp)
80100fcf:	e8 1b 6e 00 00       	call   80107def <freevm>
80100fd4:	83 c4 10             	add    $0x10,%esp
  cprintf("[exec] end\n");
80100fd7:	83 ec 0c             	sub    $0xc,%esp
80100fda:	68 71 a7 10 80       	push   $0x8010a771
80100fdf:	e8 28 f4 ff ff       	call   8010040c <cprintf>
80100fe4:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fe7:	b8 00 00 00 00       	mov    $0x0,%eax
80100fec:	eb 67                	jmp    80101055 <exec+0x47e>
    goto bad;
80100fee:	90                   	nop
80100fef:	eb 22                	jmp    80101013 <exec+0x43c>
    goto bad;
80100ff1:	90                   	nop
80100ff2:	eb 1f                	jmp    80101013 <exec+0x43c>
    goto bad;
80100ff4:	90                   	nop
80100ff5:	eb 1c                	jmp    80101013 <exec+0x43c>
      goto bad;
80100ff7:	90                   	nop
80100ff8:	eb 19                	jmp    80101013 <exec+0x43c>
      goto bad;
80100ffa:	90                   	nop
80100ffb:	eb 16                	jmp    80101013 <exec+0x43c>
      goto bad;
80100ffd:	90                   	nop
80100ffe:	eb 13                	jmp    80101013 <exec+0x43c>
      goto bad;
80101000:	90                   	nop
80101001:	eb 10                	jmp    80101013 <exec+0x43c>
      goto bad;
80101003:	90                   	nop
80101004:	eb 0d                	jmp    80101013 <exec+0x43c>
      goto bad;
80101006:	90                   	nop
80101007:	eb 0a                	jmp    80101013 <exec+0x43c>
    goto bad;
80101009:	90                   	nop
8010100a:	eb 07                	jmp    80101013 <exec+0x43c>
      goto bad;
8010100c:	90                   	nop
8010100d:	eb 04                	jmp    80101013 <exec+0x43c>
      goto bad;
8010100f:	90                   	nop
80101010:	eb 01                	jmp    80101013 <exec+0x43c>
    goto bad;
80101012:	90                   	nop

 bad:
  cprintf("bad \n");
80101013:	83 ec 0c             	sub    $0xc,%esp
80101016:	68 7d a7 10 80       	push   $0x8010a77d
8010101b:	e8 ec f3 ff ff       	call   8010040c <cprintf>
80101020:	83 c4 10             	add    $0x10,%esp
  if(pgdir)
80101023:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101027:	74 0e                	je     80101037 <exec+0x460>
    freevm(pgdir);
80101029:	83 ec 0c             	sub    $0xc,%esp
8010102c:	ff 75 d4             	push   -0x2c(%ebp)
8010102f:	e8 bb 6d 00 00       	call   80107def <freevm>
80101034:	83 c4 10             	add    $0x10,%esp
  if(ip){
80101037:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010103b:	74 13                	je     80101050 <exec+0x479>
    iunlockput(ip);
8010103d:	83 ec 0c             	sub    $0xc,%esp
80101040:	ff 75 d8             	push   -0x28(%ebp)
80101043:	e8 c7 0c 00 00       	call   80101d0f <iunlockput>
80101048:	83 c4 10             	add    $0x10,%esp
    end_op();
8010104b:	e8 07 22 00 00       	call   80103257 <end_op>
  }
  return -1;
80101050:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101055:	c9                   	leave
80101056:	c3                   	ret

80101057 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101057:	f3 0f 1e fb          	endbr32
8010105b:	55                   	push   %ebp
8010105c:	89 e5                	mov    %esp,%ebp
8010105e:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80101061:	83 ec 08             	sub    $0x8,%esp
80101064:	68 83 a7 10 80       	push   $0x8010a783
80101069:	68 60 2d 19 80       	push   $0x80192d60
8010106e:	e8 43 3a 00 00       	call   80104ab6 <initlock>
80101073:	83 c4 10             	add    $0x10,%esp
}
80101076:	90                   	nop
80101077:	c9                   	leave
80101078:	c3                   	ret

80101079 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101079:	f3 0f 1e fb          	endbr32
8010107d:	55                   	push   %ebp
8010107e:	89 e5                	mov    %esp,%ebp
80101080:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101083:	83 ec 0c             	sub    $0xc,%esp
80101086:	68 60 2d 19 80       	push   $0x80192d60
8010108b:	e8 4c 3a 00 00       	call   80104adc <acquire>
80101090:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101093:	c7 45 f4 94 2d 19 80 	movl   $0x80192d94,-0xc(%ebp)
8010109a:	eb 2d                	jmp    801010c9 <filealloc+0x50>
    if(f->ref == 0){
8010109c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010109f:	8b 40 04             	mov    0x4(%eax),%eax
801010a2:	85 c0                	test   %eax,%eax
801010a4:	75 1f                	jne    801010c5 <filealloc+0x4c>
      f->ref = 1;
801010a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010a9:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801010b0:	83 ec 0c             	sub    $0xc,%esp
801010b3:	68 60 2d 19 80       	push   $0x80192d60
801010b8:	e8 91 3a 00 00       	call   80104b4e <release>
801010bd:	83 c4 10             	add    $0x10,%esp
      return f;
801010c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010c3:	eb 23                	jmp    801010e8 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010c5:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801010c9:	b8 f4 36 19 80       	mov    $0x801936f4,%eax
801010ce:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801010d1:	72 c9                	jb     8010109c <filealloc+0x23>
    }
  }
  release(&ftable.lock);
801010d3:	83 ec 0c             	sub    $0xc,%esp
801010d6:	68 60 2d 19 80       	push   $0x80192d60
801010db:	e8 6e 3a 00 00       	call   80104b4e <release>
801010e0:	83 c4 10             	add    $0x10,%esp
  return 0;
801010e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801010e8:	c9                   	leave
801010e9:	c3                   	ret

801010ea <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801010ea:	f3 0f 1e fb          	endbr32
801010ee:	55                   	push   %ebp
801010ef:	89 e5                	mov    %esp,%ebp
801010f1:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801010f4:	83 ec 0c             	sub    $0xc,%esp
801010f7:	68 60 2d 19 80       	push   $0x80192d60
801010fc:	e8 db 39 00 00       	call   80104adc <acquire>
80101101:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101104:	8b 45 08             	mov    0x8(%ebp),%eax
80101107:	8b 40 04             	mov    0x4(%eax),%eax
8010110a:	85 c0                	test   %eax,%eax
8010110c:	7f 0d                	jg     8010111b <filedup+0x31>
    panic("filedup");
8010110e:	83 ec 0c             	sub    $0xc,%esp
80101111:	68 8a a7 10 80       	push   $0x8010a78a
80101116:	e8 c3 f4 ff ff       	call   801005de <panic>
  f->ref++;
8010111b:	8b 45 08             	mov    0x8(%ebp),%eax
8010111e:	8b 40 04             	mov    0x4(%eax),%eax
80101121:	8d 50 01             	lea    0x1(%eax),%edx
80101124:	8b 45 08             	mov    0x8(%ebp),%eax
80101127:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010112a:	83 ec 0c             	sub    $0xc,%esp
8010112d:	68 60 2d 19 80       	push   $0x80192d60
80101132:	e8 17 3a 00 00       	call   80104b4e <release>
80101137:	83 c4 10             	add    $0x10,%esp
  return f;
8010113a:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010113d:	c9                   	leave
8010113e:	c3                   	ret

8010113f <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010113f:	f3 0f 1e fb          	endbr32
80101143:	55                   	push   %ebp
80101144:	89 e5                	mov    %esp,%ebp
80101146:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101149:	83 ec 0c             	sub    $0xc,%esp
8010114c:	68 60 2d 19 80       	push   $0x80192d60
80101151:	e8 86 39 00 00       	call   80104adc <acquire>
80101156:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101159:	8b 45 08             	mov    0x8(%ebp),%eax
8010115c:	8b 40 04             	mov    0x4(%eax),%eax
8010115f:	85 c0                	test   %eax,%eax
80101161:	7f 0d                	jg     80101170 <fileclose+0x31>
    panic("fileclose");
80101163:	83 ec 0c             	sub    $0xc,%esp
80101166:	68 92 a7 10 80       	push   $0x8010a792
8010116b:	e8 6e f4 ff ff       	call   801005de <panic>
  if(--f->ref > 0){
80101170:	8b 45 08             	mov    0x8(%ebp),%eax
80101173:	8b 40 04             	mov    0x4(%eax),%eax
80101176:	8d 50 ff             	lea    -0x1(%eax),%edx
80101179:	8b 45 08             	mov    0x8(%ebp),%eax
8010117c:	89 50 04             	mov    %edx,0x4(%eax)
8010117f:	8b 45 08             	mov    0x8(%ebp),%eax
80101182:	8b 40 04             	mov    0x4(%eax),%eax
80101185:	85 c0                	test   %eax,%eax
80101187:	7e 15                	jle    8010119e <fileclose+0x5f>
    release(&ftable.lock);
80101189:	83 ec 0c             	sub    $0xc,%esp
8010118c:	68 60 2d 19 80       	push   $0x80192d60
80101191:	e8 b8 39 00 00       	call   80104b4e <release>
80101196:	83 c4 10             	add    $0x10,%esp
80101199:	e9 8b 00 00 00       	jmp    80101229 <fileclose+0xea>
    return;
  }
  ff = *f;
8010119e:	8b 45 08             	mov    0x8(%ebp),%eax
801011a1:	8b 10                	mov    (%eax),%edx
801011a3:	89 55 e0             	mov    %edx,-0x20(%ebp)
801011a6:	8b 50 04             	mov    0x4(%eax),%edx
801011a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801011ac:	8b 50 08             	mov    0x8(%eax),%edx
801011af:	89 55 e8             	mov    %edx,-0x18(%ebp)
801011b2:	8b 50 0c             	mov    0xc(%eax),%edx
801011b5:	89 55 ec             	mov    %edx,-0x14(%ebp)
801011b8:	8b 50 10             	mov    0x10(%eax),%edx
801011bb:	89 55 f0             	mov    %edx,-0x10(%ebp)
801011be:	8b 40 14             	mov    0x14(%eax),%eax
801011c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801011c4:	8b 45 08             	mov    0x8(%ebp),%eax
801011c7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801011ce:	8b 45 08             	mov    0x8(%ebp),%eax
801011d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801011d7:	83 ec 0c             	sub    $0xc,%esp
801011da:	68 60 2d 19 80       	push   $0x80192d60
801011df:	e8 6a 39 00 00       	call   80104b4e <release>
801011e4:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
801011e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011ea:	83 f8 01             	cmp    $0x1,%eax
801011ed:	75 19                	jne    80101208 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
801011ef:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801011f3:	0f be d0             	movsbl %al,%edx
801011f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011f9:	83 ec 08             	sub    $0x8,%esp
801011fc:	52                   	push   %edx
801011fd:	50                   	push   %eax
801011fe:	e8 73 26 00 00       	call   80103876 <pipeclose>
80101203:	83 c4 10             	add    $0x10,%esp
80101206:	eb 21                	jmp    80101229 <fileclose+0xea>
  else if(ff.type == FD_INODE){
80101208:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010120b:	83 f8 02             	cmp    $0x2,%eax
8010120e:	75 19                	jne    80101229 <fileclose+0xea>
    begin_op();
80101210:	e8 b2 1f 00 00       	call   801031c7 <begin_op>
    iput(ff.ip);
80101215:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101218:	83 ec 0c             	sub    $0xc,%esp
8010121b:	50                   	push   %eax
8010121c:	e8 1a 0a 00 00       	call   80101c3b <iput>
80101221:	83 c4 10             	add    $0x10,%esp
    end_op();
80101224:	e8 2e 20 00 00       	call   80103257 <end_op>
  }
}
80101229:	c9                   	leave
8010122a:	c3                   	ret

8010122b <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010122b:	f3 0f 1e fb          	endbr32
8010122f:	55                   	push   %ebp
80101230:	89 e5                	mov    %esp,%ebp
80101232:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101235:	8b 45 08             	mov    0x8(%ebp),%eax
80101238:	8b 00                	mov    (%eax),%eax
8010123a:	83 f8 02             	cmp    $0x2,%eax
8010123d:	75 40                	jne    8010127f <filestat+0x54>
    ilock(f->ip);
8010123f:	8b 45 08             	mov    0x8(%ebp),%eax
80101242:	8b 40 10             	mov    0x10(%eax),%eax
80101245:	83 ec 0c             	sub    $0xc,%esp
80101248:	50                   	push   %eax
80101249:	e8 84 08 00 00       	call   80101ad2 <ilock>
8010124e:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101251:	8b 45 08             	mov    0x8(%ebp),%eax
80101254:	8b 40 10             	mov    0x10(%eax),%eax
80101257:	83 ec 08             	sub    $0x8,%esp
8010125a:	ff 75 0c             	push   0xc(%ebp)
8010125d:	50                   	push   %eax
8010125e:	e8 2d 0d 00 00       	call   80101f90 <stati>
80101263:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	8b 40 10             	mov    0x10(%eax),%eax
8010126c:	83 ec 0c             	sub    $0xc,%esp
8010126f:	50                   	push   %eax
80101270:	e8 74 09 00 00       	call   80101be9 <iunlock>
80101275:	83 c4 10             	add    $0x10,%esp
    return 0;
80101278:	b8 00 00 00 00       	mov    $0x0,%eax
8010127d:	eb 05                	jmp    80101284 <filestat+0x59>
  }
  return -1;
8010127f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101284:	c9                   	leave
80101285:	c3                   	ret

80101286 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101286:	f3 0f 1e fb          	endbr32
8010128a:	55                   	push   %ebp
8010128b:	89 e5                	mov    %esp,%ebp
8010128d:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101290:	8b 45 08             	mov    0x8(%ebp),%eax
80101293:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101297:	84 c0                	test   %al,%al
80101299:	75 0a                	jne    801012a5 <fileread+0x1f>
    return -1;
8010129b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012a0:	e9 9b 00 00 00       	jmp    80101340 <fileread+0xba>
  if(f->type == FD_PIPE)
801012a5:	8b 45 08             	mov    0x8(%ebp),%eax
801012a8:	8b 00                	mov    (%eax),%eax
801012aa:	83 f8 01             	cmp    $0x1,%eax
801012ad:	75 1a                	jne    801012c9 <fileread+0x43>
    return piperead(f->pipe, addr, n);
801012af:	8b 45 08             	mov    0x8(%ebp),%eax
801012b2:	8b 40 0c             	mov    0xc(%eax),%eax
801012b5:	83 ec 04             	sub    $0x4,%esp
801012b8:	ff 75 10             	push   0x10(%ebp)
801012bb:	ff 75 0c             	push   0xc(%ebp)
801012be:	50                   	push   %eax
801012bf:	e8 67 27 00 00       	call   80103a2b <piperead>
801012c4:	83 c4 10             	add    $0x10,%esp
801012c7:	eb 77                	jmp    80101340 <fileread+0xba>
  if(f->type == FD_INODE){
801012c9:	8b 45 08             	mov    0x8(%ebp),%eax
801012cc:	8b 00                	mov    (%eax),%eax
801012ce:	83 f8 02             	cmp    $0x2,%eax
801012d1:	75 60                	jne    80101333 <fileread+0xad>
    ilock(f->ip);
801012d3:	8b 45 08             	mov    0x8(%ebp),%eax
801012d6:	8b 40 10             	mov    0x10(%eax),%eax
801012d9:	83 ec 0c             	sub    $0xc,%esp
801012dc:	50                   	push   %eax
801012dd:	e8 f0 07 00 00       	call   80101ad2 <ilock>
801012e2:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801012e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
801012e8:	8b 45 08             	mov    0x8(%ebp),%eax
801012eb:	8b 50 14             	mov    0x14(%eax),%edx
801012ee:	8b 45 08             	mov    0x8(%ebp),%eax
801012f1:	8b 40 10             	mov    0x10(%eax),%eax
801012f4:	51                   	push   %ecx
801012f5:	52                   	push   %edx
801012f6:	ff 75 0c             	push   0xc(%ebp)
801012f9:	50                   	push   %eax
801012fa:	e8 db 0c 00 00       	call   80101fda <readi>
801012ff:	83 c4 10             	add    $0x10,%esp
80101302:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101305:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101309:	7e 11                	jle    8010131c <fileread+0x96>
      f->off += r;
8010130b:	8b 45 08             	mov    0x8(%ebp),%eax
8010130e:	8b 50 14             	mov    0x14(%eax),%edx
80101311:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101314:	01 c2                	add    %eax,%edx
80101316:	8b 45 08             	mov    0x8(%ebp),%eax
80101319:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	8b 40 10             	mov    0x10(%eax),%eax
80101322:	83 ec 0c             	sub    $0xc,%esp
80101325:	50                   	push   %eax
80101326:	e8 be 08 00 00       	call   80101be9 <iunlock>
8010132b:	83 c4 10             	add    $0x10,%esp
    return r;
8010132e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101331:	eb 0d                	jmp    80101340 <fileread+0xba>
  }
  panic("fileread");
80101333:	83 ec 0c             	sub    $0xc,%esp
80101336:	68 9c a7 10 80       	push   $0x8010a79c
8010133b:	e8 9e f2 ff ff       	call   801005de <panic>
}
80101340:	c9                   	leave
80101341:	c3                   	ret

80101342 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101342:	f3 0f 1e fb          	endbr32
80101346:	55                   	push   %ebp
80101347:	89 e5                	mov    %esp,%ebp
80101349:	53                   	push   %ebx
8010134a:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010134d:	8b 45 08             	mov    0x8(%ebp),%eax
80101350:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101354:	84 c0                	test   %al,%al
80101356:	75 0a                	jne    80101362 <filewrite+0x20>
    return -1;
80101358:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010135d:	e9 1b 01 00 00       	jmp    8010147d <filewrite+0x13b>
  if(f->type == FD_PIPE)
80101362:	8b 45 08             	mov    0x8(%ebp),%eax
80101365:	8b 00                	mov    (%eax),%eax
80101367:	83 f8 01             	cmp    $0x1,%eax
8010136a:	75 1d                	jne    80101389 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
8010136c:	8b 45 08             	mov    0x8(%ebp),%eax
8010136f:	8b 40 0c             	mov    0xc(%eax),%eax
80101372:	83 ec 04             	sub    $0x4,%esp
80101375:	ff 75 10             	push   0x10(%ebp)
80101378:	ff 75 0c             	push   0xc(%ebp)
8010137b:	50                   	push   %eax
8010137c:	e8 a4 25 00 00       	call   80103925 <pipewrite>
80101381:	83 c4 10             	add    $0x10,%esp
80101384:	e9 f4 00 00 00       	jmp    8010147d <filewrite+0x13b>
  if(f->type == FD_INODE){
80101389:	8b 45 08             	mov    0x8(%ebp),%eax
8010138c:	8b 00                	mov    (%eax),%eax
8010138e:	83 f8 02             	cmp    $0x2,%eax
80101391:	0f 85 d9 00 00 00    	jne    80101470 <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
80101397:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
8010139e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013a5:	e9 a3 00 00 00       	jmp    8010144d <filewrite+0x10b>
      int n1 = n - i;
801013aa:	8b 45 10             	mov    0x10(%ebp),%eax
801013ad:	2b 45 f4             	sub    -0xc(%ebp),%eax
801013b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013b6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801013b9:	7e 06                	jle    801013c1 <filewrite+0x7f>
        n1 = max;
801013bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013be:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801013c1:	e8 01 1e 00 00       	call   801031c7 <begin_op>
      ilock(f->ip);
801013c6:	8b 45 08             	mov    0x8(%ebp),%eax
801013c9:	8b 40 10             	mov    0x10(%eax),%eax
801013cc:	83 ec 0c             	sub    $0xc,%esp
801013cf:	50                   	push   %eax
801013d0:	e8 fd 06 00 00       	call   80101ad2 <ilock>
801013d5:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801013d8:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801013db:	8b 45 08             	mov    0x8(%ebp),%eax
801013de:	8b 50 14             	mov    0x14(%eax),%edx
801013e1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801013e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801013e7:	01 c3                	add    %eax,%ebx
801013e9:	8b 45 08             	mov    0x8(%ebp),%eax
801013ec:	8b 40 10             	mov    0x10(%eax),%eax
801013ef:	51                   	push   %ecx
801013f0:	52                   	push   %edx
801013f1:	53                   	push   %ebx
801013f2:	50                   	push   %eax
801013f3:	e8 3b 0d 00 00       	call   80102133 <writei>
801013f8:	83 c4 10             	add    $0x10,%esp
801013fb:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013fe:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101402:	7e 11                	jle    80101415 <filewrite+0xd3>
        f->off += r;
80101404:	8b 45 08             	mov    0x8(%ebp),%eax
80101407:	8b 50 14             	mov    0x14(%eax),%edx
8010140a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010140d:	01 c2                	add    %eax,%edx
8010140f:	8b 45 08             	mov    0x8(%ebp),%eax
80101412:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101415:	8b 45 08             	mov    0x8(%ebp),%eax
80101418:	8b 40 10             	mov    0x10(%eax),%eax
8010141b:	83 ec 0c             	sub    $0xc,%esp
8010141e:	50                   	push   %eax
8010141f:	e8 c5 07 00 00       	call   80101be9 <iunlock>
80101424:	83 c4 10             	add    $0x10,%esp
      end_op();
80101427:	e8 2b 1e 00 00       	call   80103257 <end_op>

      if(r < 0)
8010142c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101430:	78 29                	js     8010145b <filewrite+0x119>
        break;
      if(r != n1)
80101432:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101435:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101438:	74 0d                	je     80101447 <filewrite+0x105>
        panic("short filewrite");
8010143a:	83 ec 0c             	sub    $0xc,%esp
8010143d:	68 a5 a7 10 80       	push   $0x8010a7a5
80101442:	e8 97 f1 ff ff       	call   801005de <panic>
      i += r;
80101447:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010144a:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
8010144d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101450:	3b 45 10             	cmp    0x10(%ebp),%eax
80101453:	0f 8c 51 ff ff ff    	jl     801013aa <filewrite+0x68>
80101459:	eb 01                	jmp    8010145c <filewrite+0x11a>
        break;
8010145b:	90                   	nop
    }
    return i == n ? n : -1;
8010145c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010145f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101462:	75 05                	jne    80101469 <filewrite+0x127>
80101464:	8b 45 10             	mov    0x10(%ebp),%eax
80101467:	eb 14                	jmp    8010147d <filewrite+0x13b>
80101469:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010146e:	eb 0d                	jmp    8010147d <filewrite+0x13b>
  }
  panic("filewrite");
80101470:	83 ec 0c             	sub    $0xc,%esp
80101473:	68 b5 a7 10 80       	push   $0x8010a7b5
80101478:	e8 61 f1 ff ff       	call   801005de <panic>
}
8010147d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101480:	c9                   	leave
80101481:	c3                   	ret

80101482 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101482:	f3 0f 1e fb          	endbr32
80101486:	55                   	push   %ebp
80101487:	89 e5                	mov    %esp,%ebp
80101489:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
8010148c:	8b 45 08             	mov    0x8(%ebp),%eax
8010148f:	83 ec 08             	sub    $0x8,%esp
80101492:	6a 01                	push   $0x1
80101494:	50                   	push   %eax
80101495:	e8 6f ed ff ff       	call   80100209 <bread>
8010149a:	83 c4 10             	add    $0x10,%esp
8010149d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014a3:	83 c0 5c             	add    $0x5c,%eax
801014a6:	83 ec 04             	sub    $0x4,%esp
801014a9:	6a 1c                	push   $0x1c
801014ab:	50                   	push   %eax
801014ac:	ff 75 0c             	push   0xc(%ebp)
801014af:	e8 7e 39 00 00       	call   80104e32 <memmove>
801014b4:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014b7:	83 ec 0c             	sub    $0xc,%esp
801014ba:	ff 75 f4             	push   -0xc(%ebp)
801014bd:	e8 d1 ed ff ff       	call   80100293 <brelse>
801014c2:	83 c4 10             	add    $0x10,%esp
}
801014c5:	90                   	nop
801014c6:	c9                   	leave
801014c7:	c3                   	ret

801014c8 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801014c8:	f3 0f 1e fb          	endbr32
801014cc:	55                   	push   %ebp
801014cd:	89 e5                	mov    %esp,%ebp
801014cf:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
801014d2:	8b 55 0c             	mov    0xc(%ebp),%edx
801014d5:	8b 45 08             	mov    0x8(%ebp),%eax
801014d8:	83 ec 08             	sub    $0x8,%esp
801014db:	52                   	push   %edx
801014dc:	50                   	push   %eax
801014dd:	e8 27 ed ff ff       	call   80100209 <bread>
801014e2:	83 c4 10             	add    $0x10,%esp
801014e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801014e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014eb:	83 c0 5c             	add    $0x5c,%eax
801014ee:	83 ec 04             	sub    $0x4,%esp
801014f1:	68 00 02 00 00       	push   $0x200
801014f6:	6a 00                	push   $0x0
801014f8:	50                   	push   %eax
801014f9:	e8 6d 38 00 00       	call   80104d6b <memset>
801014fe:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101501:	83 ec 0c             	sub    $0xc,%esp
80101504:	ff 75 f4             	push   -0xc(%ebp)
80101507:	e8 04 1f 00 00       	call   80103410 <log_write>
8010150c:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010150f:	83 ec 0c             	sub    $0xc,%esp
80101512:	ff 75 f4             	push   -0xc(%ebp)
80101515:	e8 79 ed ff ff       	call   80100293 <brelse>
8010151a:	83 c4 10             	add    $0x10,%esp
}
8010151d:	90                   	nop
8010151e:	c9                   	leave
8010151f:	c3                   	ret

80101520 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101520:	f3 0f 1e fb          	endbr32
80101524:	55                   	push   %ebp
80101525:	89 e5                	mov    %esp,%ebp
80101527:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010152a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101531:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101538:	e9 13 01 00 00       	jmp    80101650 <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
8010153d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101540:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101546:	85 c0                	test   %eax,%eax
80101548:	0f 48 c2             	cmovs  %edx,%eax
8010154b:	c1 f8 0c             	sar    $0xc,%eax
8010154e:	89 c2                	mov    %eax,%edx
80101550:	a1 78 37 19 80       	mov    0x80193778,%eax
80101555:	01 d0                	add    %edx,%eax
80101557:	83 ec 08             	sub    $0x8,%esp
8010155a:	50                   	push   %eax
8010155b:	ff 75 08             	push   0x8(%ebp)
8010155e:	e8 a6 ec ff ff       	call   80100209 <bread>
80101563:	83 c4 10             	add    $0x10,%esp
80101566:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101569:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101570:	e9 a6 00 00 00       	jmp    8010161b <balloc+0xfb>
      m = 1 << (bi % 8);
80101575:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101578:	99                   	cltd
80101579:	c1 ea 1d             	shr    $0x1d,%edx
8010157c:	01 d0                	add    %edx,%eax
8010157e:	83 e0 07             	and    $0x7,%eax
80101581:	29 d0                	sub    %edx,%eax
80101583:	ba 01 00 00 00       	mov    $0x1,%edx
80101588:	89 c1                	mov    %eax,%ecx
8010158a:	d3 e2                	shl    %cl,%edx
8010158c:	89 d0                	mov    %edx,%eax
8010158e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101591:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101594:	8d 50 07             	lea    0x7(%eax),%edx
80101597:	85 c0                	test   %eax,%eax
80101599:	0f 48 c2             	cmovs  %edx,%eax
8010159c:	c1 f8 03             	sar    $0x3,%eax
8010159f:	89 c2                	mov    %eax,%edx
801015a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015a4:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801015a9:	0f b6 c0             	movzbl %al,%eax
801015ac:	23 45 e8             	and    -0x18(%ebp),%eax
801015af:	85 c0                	test   %eax,%eax
801015b1:	75 64                	jne    80101617 <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
801015b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b6:	8d 50 07             	lea    0x7(%eax),%edx
801015b9:	85 c0                	test   %eax,%eax
801015bb:	0f 48 c2             	cmovs  %edx,%eax
801015be:	c1 f8 03             	sar    $0x3,%eax
801015c1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015c4:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801015c9:	89 d1                	mov    %edx,%ecx
801015cb:	8b 55 e8             	mov    -0x18(%ebp),%edx
801015ce:	09 ca                	or     %ecx,%edx
801015d0:	89 d1                	mov    %edx,%ecx
801015d2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015d5:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
801015d9:	83 ec 0c             	sub    $0xc,%esp
801015dc:	ff 75 ec             	push   -0x14(%ebp)
801015df:	e8 2c 1e 00 00       	call   80103410 <log_write>
801015e4:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801015e7:	83 ec 0c             	sub    $0xc,%esp
801015ea:	ff 75 ec             	push   -0x14(%ebp)
801015ed:	e8 a1 ec ff ff       	call   80100293 <brelse>
801015f2:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801015f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fb:	01 c2                	add    %eax,%edx
801015fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101600:	83 ec 08             	sub    $0x8,%esp
80101603:	52                   	push   %edx
80101604:	50                   	push   %eax
80101605:	e8 be fe ff ff       	call   801014c8 <bzero>
8010160a:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010160d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101613:	01 d0                	add    %edx,%eax
80101615:	eb 57                	jmp    8010166e <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101617:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010161b:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101622:	7f 17                	jg     8010163b <balloc+0x11b>
80101624:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101627:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010162a:	01 d0                	add    %edx,%eax
8010162c:	89 c2                	mov    %eax,%edx
8010162e:	a1 60 37 19 80       	mov    0x80193760,%eax
80101633:	39 c2                	cmp    %eax,%edx
80101635:	0f 82 3a ff ff ff    	jb     80101575 <balloc+0x55>
      }
    }
    brelse(bp);
8010163b:	83 ec 0c             	sub    $0xc,%esp
8010163e:	ff 75 ec             	push   -0x14(%ebp)
80101641:	e8 4d ec ff ff       	call   80100293 <brelse>
80101646:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101649:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101650:	8b 15 60 37 19 80    	mov    0x80193760,%edx
80101656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101659:	39 c2                	cmp    %eax,%edx
8010165b:	0f 87 dc fe ff ff    	ja     8010153d <balloc+0x1d>
  }
  panic("balloc: out of blocks");
80101661:	83 ec 0c             	sub    $0xc,%esp
80101664:	68 c0 a7 10 80       	push   $0x8010a7c0
80101669:	e8 70 ef ff ff       	call   801005de <panic>
}
8010166e:	c9                   	leave
8010166f:	c3                   	ret

80101670 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101670:	f3 0f 1e fb          	endbr32
80101674:	55                   	push   %ebp
80101675:	89 e5                	mov    %esp,%ebp
80101677:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010167a:	83 ec 08             	sub    $0x8,%esp
8010167d:	68 60 37 19 80       	push   $0x80193760
80101682:	ff 75 08             	push   0x8(%ebp)
80101685:	e8 f8 fd ff ff       	call   80101482 <readsb>
8010168a:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
8010168d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101690:	c1 e8 0c             	shr    $0xc,%eax
80101693:	89 c2                	mov    %eax,%edx
80101695:	a1 78 37 19 80       	mov    0x80193778,%eax
8010169a:	01 c2                	add    %eax,%edx
8010169c:	8b 45 08             	mov    0x8(%ebp),%eax
8010169f:	83 ec 08             	sub    $0x8,%esp
801016a2:	52                   	push   %edx
801016a3:	50                   	push   %eax
801016a4:	e8 60 eb ff ff       	call   80100209 <bread>
801016a9:	83 c4 10             	add    $0x10,%esp
801016ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016af:	8b 45 0c             	mov    0xc(%ebp),%eax
801016b2:	25 ff 0f 00 00       	and    $0xfff,%eax
801016b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016bd:	99                   	cltd
801016be:	c1 ea 1d             	shr    $0x1d,%edx
801016c1:	01 d0                	add    %edx,%eax
801016c3:	83 e0 07             	and    $0x7,%eax
801016c6:	29 d0                	sub    %edx,%eax
801016c8:	ba 01 00 00 00       	mov    $0x1,%edx
801016cd:	89 c1                	mov    %eax,%ecx
801016cf:	d3 e2                	shl    %cl,%edx
801016d1:	89 d0                	mov    %edx,%eax
801016d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016d9:	8d 50 07             	lea    0x7(%eax),%edx
801016dc:	85 c0                	test   %eax,%eax
801016de:	0f 48 c2             	cmovs  %edx,%eax
801016e1:	c1 f8 03             	sar    $0x3,%eax
801016e4:	89 c2                	mov    %eax,%edx
801016e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016e9:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801016ee:	0f b6 c0             	movzbl %al,%eax
801016f1:	23 45 ec             	and    -0x14(%ebp),%eax
801016f4:	85 c0                	test   %eax,%eax
801016f6:	75 0d                	jne    80101705 <bfree+0x95>
    panic("freeing free block");
801016f8:	83 ec 0c             	sub    $0xc,%esp
801016fb:	68 d6 a7 10 80       	push   $0x8010a7d6
80101700:	e8 d9 ee ff ff       	call   801005de <panic>
  bp->data[bi/8] &= ~m;
80101705:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101708:	8d 50 07             	lea    0x7(%eax),%edx
8010170b:	85 c0                	test   %eax,%eax
8010170d:	0f 48 c2             	cmovs  %edx,%eax
80101710:	c1 f8 03             	sar    $0x3,%eax
80101713:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101716:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010171b:	89 d1                	mov    %edx,%ecx
8010171d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101720:	f7 d2                	not    %edx
80101722:	21 ca                	and    %ecx,%edx
80101724:	89 d1                	mov    %edx,%ecx
80101726:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101729:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010172d:	83 ec 0c             	sub    $0xc,%esp
80101730:	ff 75 f4             	push   -0xc(%ebp)
80101733:	e8 d8 1c 00 00       	call   80103410 <log_write>
80101738:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010173b:	83 ec 0c             	sub    $0xc,%esp
8010173e:	ff 75 f4             	push   -0xc(%ebp)
80101741:	e8 4d eb ff ff       	call   80100293 <brelse>
80101746:	83 c4 10             	add    $0x10,%esp
}
80101749:	90                   	nop
8010174a:	c9                   	leave
8010174b:	c3                   	ret

8010174c <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010174c:	f3 0f 1e fb          	endbr32
80101750:	55                   	push   %ebp
80101751:	89 e5                	mov    %esp,%ebp
80101753:	57                   	push   %edi
80101754:	56                   	push   %esi
80101755:	53                   	push   %ebx
80101756:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101759:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101760:	83 ec 08             	sub    $0x8,%esp
80101763:	68 e9 a7 10 80       	push   $0x8010a7e9
80101768:	68 80 37 19 80       	push   $0x80193780
8010176d:	e8 44 33 00 00       	call   80104ab6 <initlock>
80101772:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101775:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010177c:	eb 2d                	jmp    801017ab <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
8010177e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101781:	89 d0                	mov    %edx,%eax
80101783:	c1 e0 03             	shl    $0x3,%eax
80101786:	01 d0                	add    %edx,%eax
80101788:	c1 e0 04             	shl    $0x4,%eax
8010178b:	83 c0 30             	add    $0x30,%eax
8010178e:	05 80 37 19 80       	add    $0x80193780,%eax
80101793:	83 c0 10             	add    $0x10,%eax
80101796:	83 ec 08             	sub    $0x8,%esp
80101799:	68 f0 a7 10 80       	push   $0x8010a7f0
8010179e:	50                   	push   %eax
8010179f:	e8 a5 31 00 00       	call   80104949 <initsleeplock>
801017a4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801017a7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801017ab:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801017af:	7e cd                	jle    8010177e <iinit+0x32>
  }

  readsb(dev, &sb);
801017b1:	83 ec 08             	sub    $0x8,%esp
801017b4:	68 60 37 19 80       	push   $0x80193760
801017b9:	ff 75 08             	push   0x8(%ebp)
801017bc:	e8 c1 fc ff ff       	call   80101482 <readsb>
801017c1:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017c4:	a1 78 37 19 80       	mov    0x80193778,%eax
801017c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801017cc:	8b 3d 74 37 19 80    	mov    0x80193774,%edi
801017d2:	8b 35 70 37 19 80    	mov    0x80193770,%esi
801017d8:	8b 1d 6c 37 19 80    	mov    0x8019376c,%ebx
801017de:	8b 0d 68 37 19 80    	mov    0x80193768,%ecx
801017e4:	8b 15 64 37 19 80    	mov    0x80193764,%edx
801017ea:	a1 60 37 19 80       	mov    0x80193760,%eax
801017ef:	ff 75 d4             	push   -0x2c(%ebp)
801017f2:	57                   	push   %edi
801017f3:	56                   	push   %esi
801017f4:	53                   	push   %ebx
801017f5:	51                   	push   %ecx
801017f6:	52                   	push   %edx
801017f7:	50                   	push   %eax
801017f8:	68 f8 a7 10 80       	push   $0x8010a7f8
801017fd:	e8 0a ec ff ff       	call   8010040c <cprintf>
80101802:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101805:	90                   	nop
80101806:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101809:	5b                   	pop    %ebx
8010180a:	5e                   	pop    %esi
8010180b:	5f                   	pop    %edi
8010180c:	5d                   	pop    %ebp
8010180d:	c3                   	ret

8010180e <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010180e:	f3 0f 1e fb          	endbr32
80101812:	55                   	push   %ebp
80101813:	89 e5                	mov    %esp,%ebp
80101815:	83 ec 28             	sub    $0x28,%esp
80101818:	8b 45 0c             	mov    0xc(%ebp),%eax
8010181b:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010181f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101826:	e9 9e 00 00 00       	jmp    801018c9 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
8010182b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182e:	c1 e8 03             	shr    $0x3,%eax
80101831:	89 c2                	mov    %eax,%edx
80101833:	a1 74 37 19 80       	mov    0x80193774,%eax
80101838:	01 d0                	add    %edx,%eax
8010183a:	83 ec 08             	sub    $0x8,%esp
8010183d:	50                   	push   %eax
8010183e:	ff 75 08             	push   0x8(%ebp)
80101841:	e8 c3 e9 ff ff       	call   80100209 <bread>
80101846:	83 c4 10             	add    $0x10,%esp
80101849:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010184c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010184f:	8d 50 5c             	lea    0x5c(%eax),%edx
80101852:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101855:	83 e0 07             	and    $0x7,%eax
80101858:	c1 e0 06             	shl    $0x6,%eax
8010185b:	01 d0                	add    %edx,%eax
8010185d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101860:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101863:	0f b7 00             	movzwl (%eax),%eax
80101866:	66 85 c0             	test   %ax,%ax
80101869:	75 4c                	jne    801018b7 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
8010186b:	83 ec 04             	sub    $0x4,%esp
8010186e:	6a 40                	push   $0x40
80101870:	6a 00                	push   $0x0
80101872:	ff 75 ec             	push   -0x14(%ebp)
80101875:	e8 f1 34 00 00       	call   80104d6b <memset>
8010187a:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
8010187d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101880:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101884:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101887:	83 ec 0c             	sub    $0xc,%esp
8010188a:	ff 75 f0             	push   -0x10(%ebp)
8010188d:	e8 7e 1b 00 00       	call   80103410 <log_write>
80101892:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101895:	83 ec 0c             	sub    $0xc,%esp
80101898:	ff 75 f0             	push   -0x10(%ebp)
8010189b:	e8 f3 e9 ff ff       	call   80100293 <brelse>
801018a0:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801018a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a6:	83 ec 08             	sub    $0x8,%esp
801018a9:	50                   	push   %eax
801018aa:	ff 75 08             	push   0x8(%ebp)
801018ad:	e8 fc 00 00 00       	call   801019ae <iget>
801018b2:	83 c4 10             	add    $0x10,%esp
801018b5:	eb 30                	jmp    801018e7 <ialloc+0xd9>
    }
    brelse(bp);
801018b7:	83 ec 0c             	sub    $0xc,%esp
801018ba:	ff 75 f0             	push   -0x10(%ebp)
801018bd:	e8 d1 e9 ff ff       	call   80100293 <brelse>
801018c2:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801018c5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801018c9:	8b 15 68 37 19 80    	mov    0x80193768,%edx
801018cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d2:	39 c2                	cmp    %eax,%edx
801018d4:	0f 87 51 ff ff ff    	ja     8010182b <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
801018da:	83 ec 0c             	sub    $0xc,%esp
801018dd:	68 4b a8 10 80       	push   $0x8010a84b
801018e2:	e8 f7 ec ff ff       	call   801005de <panic>
}
801018e7:	c9                   	leave
801018e8:	c3                   	ret

801018e9 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801018e9:	f3 0f 1e fb          	endbr32
801018ed:	55                   	push   %ebp
801018ee:	89 e5                	mov    %esp,%ebp
801018f0:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018f3:	8b 45 08             	mov    0x8(%ebp),%eax
801018f6:	8b 40 04             	mov    0x4(%eax),%eax
801018f9:	c1 e8 03             	shr    $0x3,%eax
801018fc:	89 c2                	mov    %eax,%edx
801018fe:	a1 74 37 19 80       	mov    0x80193774,%eax
80101903:	01 c2                	add    %eax,%edx
80101905:	8b 45 08             	mov    0x8(%ebp),%eax
80101908:	8b 00                	mov    (%eax),%eax
8010190a:	83 ec 08             	sub    $0x8,%esp
8010190d:	52                   	push   %edx
8010190e:	50                   	push   %eax
8010190f:	e8 f5 e8 ff ff       	call   80100209 <bread>
80101914:	83 c4 10             	add    $0x10,%esp
80101917:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010191a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101920:	8b 45 08             	mov    0x8(%ebp),%eax
80101923:	8b 40 04             	mov    0x4(%eax),%eax
80101926:	83 e0 07             	and    $0x7,%eax
80101929:	c1 e0 06             	shl    $0x6,%eax
8010192c:	01 d0                	add    %edx,%eax
8010192e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101931:	8b 45 08             	mov    0x8(%ebp),%eax
80101934:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101938:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010193e:	8b 45 08             	mov    0x8(%ebp),%eax
80101941:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101945:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101948:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010194c:	8b 45 08             	mov    0x8(%ebp),%eax
8010194f:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101956:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010195a:	8b 45 08             	mov    0x8(%ebp),%eax
8010195d:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101961:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101964:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101968:	8b 45 08             	mov    0x8(%ebp),%eax
8010196b:	8b 50 58             	mov    0x58(%eax),%edx
8010196e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101971:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101974:	8b 45 08             	mov    0x8(%ebp),%eax
80101977:	8d 50 5c             	lea    0x5c(%eax),%edx
8010197a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010197d:	83 c0 0c             	add    $0xc,%eax
80101980:	83 ec 04             	sub    $0x4,%esp
80101983:	6a 34                	push   $0x34
80101985:	52                   	push   %edx
80101986:	50                   	push   %eax
80101987:	e8 a6 34 00 00       	call   80104e32 <memmove>
8010198c:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010198f:	83 ec 0c             	sub    $0xc,%esp
80101992:	ff 75 f4             	push   -0xc(%ebp)
80101995:	e8 76 1a 00 00       	call   80103410 <log_write>
8010199a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010199d:	83 ec 0c             	sub    $0xc,%esp
801019a0:	ff 75 f4             	push   -0xc(%ebp)
801019a3:	e8 eb e8 ff ff       	call   80100293 <brelse>
801019a8:	83 c4 10             	add    $0x10,%esp
}
801019ab:	90                   	nop
801019ac:	c9                   	leave
801019ad:	c3                   	ret

801019ae <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019ae:	f3 0f 1e fb          	endbr32
801019b2:	55                   	push   %ebp
801019b3:	89 e5                	mov    %esp,%ebp
801019b5:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801019b8:	83 ec 0c             	sub    $0xc,%esp
801019bb:	68 80 37 19 80       	push   $0x80193780
801019c0:	e8 17 31 00 00       	call   80104adc <acquire>
801019c5:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801019c8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019cf:	c7 45 f4 b4 37 19 80 	movl   $0x801937b4,-0xc(%ebp)
801019d6:	eb 60                	jmp    80101a38 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801019d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019db:	8b 40 08             	mov    0x8(%eax),%eax
801019de:	85 c0                	test   %eax,%eax
801019e0:	7e 39                	jle    80101a1b <iget+0x6d>
801019e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e5:	8b 00                	mov    (%eax),%eax
801019e7:	39 45 08             	cmp    %eax,0x8(%ebp)
801019ea:	75 2f                	jne    80101a1b <iget+0x6d>
801019ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ef:	8b 40 04             	mov    0x4(%eax),%eax
801019f2:	39 45 0c             	cmp    %eax,0xc(%ebp)
801019f5:	75 24                	jne    80101a1b <iget+0x6d>
      ip->ref++;
801019f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019fa:	8b 40 08             	mov    0x8(%eax),%eax
801019fd:	8d 50 01             	lea    0x1(%eax),%edx
80101a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a03:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a06:	83 ec 0c             	sub    $0xc,%esp
80101a09:	68 80 37 19 80       	push   $0x80193780
80101a0e:	e8 3b 31 00 00       	call   80104b4e <release>
80101a13:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a19:	eb 77                	jmp    80101a92 <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a1b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a1f:	75 10                	jne    80101a31 <iget+0x83>
80101a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a24:	8b 40 08             	mov    0x8(%eax),%eax
80101a27:	85 c0                	test   %eax,%eax
80101a29:	75 06                	jne    80101a31 <iget+0x83>
      empty = ip;
80101a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a31:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a38:	81 7d f4 d4 53 19 80 	cmpl   $0x801953d4,-0xc(%ebp)
80101a3f:	72 97                	jb     801019d8 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a41:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a45:	75 0d                	jne    80101a54 <iget+0xa6>
    panic("iget: no inodes");
80101a47:	83 ec 0c             	sub    $0xc,%esp
80101a4a:	68 5d a8 10 80       	push   $0x8010a85d
80101a4f:	e8 8a eb ff ff       	call   801005de <panic>

  ip = empty;
80101a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a57:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a5d:	8b 55 08             	mov    0x8(%ebp),%edx
80101a60:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a65:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a68:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a78:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a7f:	83 ec 0c             	sub    $0xc,%esp
80101a82:	68 80 37 19 80       	push   $0x80193780
80101a87:	e8 c2 30 00 00       	call   80104b4e <release>
80101a8c:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a92:	c9                   	leave
80101a93:	c3                   	ret

80101a94 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a94:	f3 0f 1e fb          	endbr32
80101a98:	55                   	push   %ebp
80101a99:	89 e5                	mov    %esp,%ebp
80101a9b:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a9e:	83 ec 0c             	sub    $0xc,%esp
80101aa1:	68 80 37 19 80       	push   $0x80193780
80101aa6:	e8 31 30 00 00       	call   80104adc <acquire>
80101aab:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101aae:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab1:	8b 40 08             	mov    0x8(%eax),%eax
80101ab4:	8d 50 01             	lea    0x1(%eax),%edx
80101ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aba:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101abd:	83 ec 0c             	sub    $0xc,%esp
80101ac0:	68 80 37 19 80       	push   $0x80193780
80101ac5:	e8 84 30 00 00       	call   80104b4e <release>
80101aca:	83 c4 10             	add    $0x10,%esp
  return ip;
80101acd:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101ad0:	c9                   	leave
80101ad1:	c3                   	ret

80101ad2 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101ad2:	f3 0f 1e fb          	endbr32
80101ad6:	55                   	push   %ebp
80101ad7:	89 e5                	mov    %esp,%ebp
80101ad9:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101adc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ae0:	74 0a                	je     80101aec <ilock+0x1a>
80101ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae5:	8b 40 08             	mov    0x8(%eax),%eax
80101ae8:	85 c0                	test   %eax,%eax
80101aea:	7f 0d                	jg     80101af9 <ilock+0x27>
    panic("ilock");
80101aec:	83 ec 0c             	sub    $0xc,%esp
80101aef:	68 6d a8 10 80       	push   $0x8010a86d
80101af4:	e8 e5 ea ff ff       	call   801005de <panic>

  acquiresleep(&ip->lock);
80101af9:	8b 45 08             	mov    0x8(%ebp),%eax
80101afc:	83 c0 0c             	add    $0xc,%eax
80101aff:	83 ec 0c             	sub    $0xc,%esp
80101b02:	50                   	push   %eax
80101b03:	e8 81 2e 00 00       	call   80104989 <acquiresleep>
80101b08:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101b0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b11:	85 c0                	test   %eax,%eax
80101b13:	0f 85 cd 00 00 00    	jne    80101be6 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b19:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1c:	8b 40 04             	mov    0x4(%eax),%eax
80101b1f:	c1 e8 03             	shr    $0x3,%eax
80101b22:	89 c2                	mov    %eax,%edx
80101b24:	a1 74 37 19 80       	mov    0x80193774,%eax
80101b29:	01 c2                	add    %eax,%edx
80101b2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2e:	8b 00                	mov    (%eax),%eax
80101b30:	83 ec 08             	sub    $0x8,%esp
80101b33:	52                   	push   %edx
80101b34:	50                   	push   %eax
80101b35:	e8 cf e6 ff ff       	call   80100209 <bread>
80101b3a:	83 c4 10             	add    $0x10,%esp
80101b3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b43:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b46:	8b 45 08             	mov    0x8(%ebp),%eax
80101b49:	8b 40 04             	mov    0x4(%eax),%eax
80101b4c:	83 e0 07             	and    $0x7,%eax
80101b4f:	c1 e0 06             	shl    $0x6,%eax
80101b52:	01 d0                	add    %edx,%eax
80101b54:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b5a:	0f b7 10             	movzwl (%eax),%edx
80101b5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b60:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b67:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6e:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b75:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b79:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7c:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b83:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b87:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8a:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b91:	8b 50 08             	mov    0x8(%eax),%edx
80101b94:	8b 45 08             	mov    0x8(%ebp),%eax
80101b97:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b9d:	8d 50 0c             	lea    0xc(%eax),%edx
80101ba0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba3:	83 c0 5c             	add    $0x5c,%eax
80101ba6:	83 ec 04             	sub    $0x4,%esp
80101ba9:	6a 34                	push   $0x34
80101bab:	52                   	push   %edx
80101bac:	50                   	push   %eax
80101bad:	e8 80 32 00 00       	call   80104e32 <memmove>
80101bb2:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101bb5:	83 ec 0c             	sub    $0xc,%esp
80101bb8:	ff 75 f4             	push   -0xc(%ebp)
80101bbb:	e8 d3 e6 ff ff       	call   80100293 <brelse>
80101bc0:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc6:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101bd4:	66 85 c0             	test   %ax,%ax
80101bd7:	75 0d                	jne    80101be6 <ilock+0x114>
      panic("ilock: no type");
80101bd9:	83 ec 0c             	sub    $0xc,%esp
80101bdc:	68 73 a8 10 80       	push   $0x8010a873
80101be1:	e8 f8 e9 ff ff       	call   801005de <panic>
  }
}
80101be6:	90                   	nop
80101be7:	c9                   	leave
80101be8:	c3                   	ret

80101be9 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101be9:	f3 0f 1e fb          	endbr32
80101bed:	55                   	push   %ebp
80101bee:	89 e5                	mov    %esp,%ebp
80101bf0:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101bf3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bf7:	74 20                	je     80101c19 <iunlock+0x30>
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	83 c0 0c             	add    $0xc,%eax
80101bff:	83 ec 0c             	sub    $0xc,%esp
80101c02:	50                   	push   %eax
80101c03:	e8 3b 2e 00 00       	call   80104a43 <holdingsleep>
80101c08:	83 c4 10             	add    $0x10,%esp
80101c0b:	85 c0                	test   %eax,%eax
80101c0d:	74 0a                	je     80101c19 <iunlock+0x30>
80101c0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c12:	8b 40 08             	mov    0x8(%eax),%eax
80101c15:	85 c0                	test   %eax,%eax
80101c17:	7f 0d                	jg     80101c26 <iunlock+0x3d>
    panic("iunlock");
80101c19:	83 ec 0c             	sub    $0xc,%esp
80101c1c:	68 82 a8 10 80       	push   $0x8010a882
80101c21:	e8 b8 e9 ff ff       	call   801005de <panic>

  releasesleep(&ip->lock);
80101c26:	8b 45 08             	mov    0x8(%ebp),%eax
80101c29:	83 c0 0c             	add    $0xc,%eax
80101c2c:	83 ec 0c             	sub    $0xc,%esp
80101c2f:	50                   	push   %eax
80101c30:	e8 bc 2d 00 00       	call   801049f1 <releasesleep>
80101c35:	83 c4 10             	add    $0x10,%esp
}
80101c38:	90                   	nop
80101c39:	c9                   	leave
80101c3a:	c3                   	ret

80101c3b <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c3b:	f3 0f 1e fb          	endbr32
80101c3f:	55                   	push   %ebp
80101c40:	89 e5                	mov    %esp,%ebp
80101c42:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101c45:	8b 45 08             	mov    0x8(%ebp),%eax
80101c48:	83 c0 0c             	add    $0xc,%eax
80101c4b:	83 ec 0c             	sub    $0xc,%esp
80101c4e:	50                   	push   %eax
80101c4f:	e8 35 2d 00 00       	call   80104989 <acquiresleep>
80101c54:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c57:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c5d:	85 c0                	test   %eax,%eax
80101c5f:	74 6a                	je     80101ccb <iput+0x90>
80101c61:	8b 45 08             	mov    0x8(%ebp),%eax
80101c64:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c68:	66 85 c0             	test   %ax,%ax
80101c6b:	75 5e                	jne    80101ccb <iput+0x90>
    acquire(&icache.lock);
80101c6d:	83 ec 0c             	sub    $0xc,%esp
80101c70:	68 80 37 19 80       	push   $0x80193780
80101c75:	e8 62 2e 00 00       	call   80104adc <acquire>
80101c7a:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c80:	8b 40 08             	mov    0x8(%eax),%eax
80101c83:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c86:	83 ec 0c             	sub    $0xc,%esp
80101c89:	68 80 37 19 80       	push   $0x80193780
80101c8e:	e8 bb 2e 00 00       	call   80104b4e <release>
80101c93:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c96:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c9a:	75 2f                	jne    80101ccb <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c9c:	83 ec 0c             	sub    $0xc,%esp
80101c9f:	ff 75 08             	push   0x8(%ebp)
80101ca2:	e8 b5 01 00 00       	call   80101e5c <itrunc>
80101ca7:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101caa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cad:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101cb3:	83 ec 0c             	sub    $0xc,%esp
80101cb6:	ff 75 08             	push   0x8(%ebp)
80101cb9:	e8 2b fc ff ff       	call   801018e9 <iupdate>
80101cbe:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc4:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101ccb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cce:	83 c0 0c             	add    $0xc,%eax
80101cd1:	83 ec 0c             	sub    $0xc,%esp
80101cd4:	50                   	push   %eax
80101cd5:	e8 17 2d 00 00       	call   801049f1 <releasesleep>
80101cda:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101cdd:	83 ec 0c             	sub    $0xc,%esp
80101ce0:	68 80 37 19 80       	push   $0x80193780
80101ce5:	e8 f2 2d 00 00       	call   80104adc <acquire>
80101cea:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101ced:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf0:	8b 40 08             	mov    0x8(%eax),%eax
80101cf3:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf9:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cfc:	83 ec 0c             	sub    $0xc,%esp
80101cff:	68 80 37 19 80       	push   $0x80193780
80101d04:	e8 45 2e 00 00       	call   80104b4e <release>
80101d09:	83 c4 10             	add    $0x10,%esp
}
80101d0c:	90                   	nop
80101d0d:	c9                   	leave
80101d0e:	c3                   	ret

80101d0f <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d0f:	f3 0f 1e fb          	endbr32
80101d13:	55                   	push   %ebp
80101d14:	89 e5                	mov    %esp,%ebp
80101d16:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101d19:	83 ec 0c             	sub    $0xc,%esp
80101d1c:	ff 75 08             	push   0x8(%ebp)
80101d1f:	e8 c5 fe ff ff       	call   80101be9 <iunlock>
80101d24:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101d27:	83 ec 0c             	sub    $0xc,%esp
80101d2a:	ff 75 08             	push   0x8(%ebp)
80101d2d:	e8 09 ff ff ff       	call   80101c3b <iput>
80101d32:	83 c4 10             	add    $0x10,%esp
}
80101d35:	90                   	nop
80101d36:	c9                   	leave
80101d37:	c3                   	ret

80101d38 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d38:	f3 0f 1e fb          	endbr32
80101d3c:	55                   	push   %ebp
80101d3d:	89 e5                	mov    %esp,%ebp
80101d3f:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d42:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d46:	77 42                	ja     80101d8a <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101d48:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d4e:	83 c2 14             	add    $0x14,%edx
80101d51:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d55:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d58:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d5c:	75 24                	jne    80101d82 <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d61:	8b 00                	mov    (%eax),%eax
80101d63:	83 ec 0c             	sub    $0xc,%esp
80101d66:	50                   	push   %eax
80101d67:	e8 b4 f7 ff ff       	call   80101520 <balloc>
80101d6c:	83 c4 10             	add    $0x10,%esp
80101d6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d72:	8b 45 08             	mov    0x8(%ebp),%eax
80101d75:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d78:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d7e:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d85:	e9 d0 00 00 00       	jmp    80101e5a <bmap+0x122>
  }
  bn -= NDIRECT;
80101d8a:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d8e:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d92:	0f 87 b5 00 00 00    	ja     80101e4d <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d98:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9b:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101da1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101da4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101da8:	75 20                	jne    80101dca <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101daa:	8b 45 08             	mov    0x8(%ebp),%eax
80101dad:	8b 00                	mov    (%eax),%eax
80101daf:	83 ec 0c             	sub    $0xc,%esp
80101db2:	50                   	push   %eax
80101db3:	e8 68 f7 ff ff       	call   80101520 <balloc>
80101db8:	83 c4 10             	add    $0x10,%esp
80101dbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dc4:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101dca:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcd:	8b 00                	mov    (%eax),%eax
80101dcf:	83 ec 08             	sub    $0x8,%esp
80101dd2:	ff 75 f4             	push   -0xc(%ebp)
80101dd5:	50                   	push   %eax
80101dd6:	e8 2e e4 ff ff       	call   80100209 <bread>
80101ddb:	83 c4 10             	add    $0x10,%esp
80101dde:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101de4:	83 c0 5c             	add    $0x5c,%eax
80101de7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101dea:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ded:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101df4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df7:	01 d0                	add    %edx,%eax
80101df9:	8b 00                	mov    (%eax),%eax
80101dfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dfe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e02:	75 36                	jne    80101e3a <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101e04:	8b 45 08             	mov    0x8(%ebp),%eax
80101e07:	8b 00                	mov    (%eax),%eax
80101e09:	83 ec 0c             	sub    $0xc,%esp
80101e0c:	50                   	push   %eax
80101e0d:	e8 0e f7 ff ff       	call   80101520 <balloc>
80101e12:	83 c4 10             	add    $0x10,%esp
80101e15:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e18:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e25:	01 c2                	add    %eax,%edx
80101e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e2a:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101e2c:	83 ec 0c             	sub    $0xc,%esp
80101e2f:	ff 75 f0             	push   -0x10(%ebp)
80101e32:	e8 d9 15 00 00       	call   80103410 <log_write>
80101e37:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e3a:	83 ec 0c             	sub    $0xc,%esp
80101e3d:	ff 75 f0             	push   -0x10(%ebp)
80101e40:	e8 4e e4 ff ff       	call   80100293 <brelse>
80101e45:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e4b:	eb 0d                	jmp    80101e5a <bmap+0x122>
  }

  panic("bmap: out of range");
80101e4d:	83 ec 0c             	sub    $0xc,%esp
80101e50:	68 8a a8 10 80       	push   $0x8010a88a
80101e55:	e8 84 e7 ff ff       	call   801005de <panic>
}
80101e5a:	c9                   	leave
80101e5b:	c3                   	ret

80101e5c <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e5c:	f3 0f 1e fb          	endbr32
80101e60:	55                   	push   %ebp
80101e61:	89 e5                	mov    %esp,%ebp
80101e63:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e6d:	eb 45                	jmp    80101eb4 <itrunc+0x58>
    if(ip->addrs[i]){
80101e6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e75:	83 c2 14             	add    $0x14,%edx
80101e78:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e7c:	85 c0                	test   %eax,%eax
80101e7e:	74 30                	je     80101eb0 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101e80:	8b 45 08             	mov    0x8(%ebp),%eax
80101e83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e86:	83 c2 14             	add    $0x14,%edx
80101e89:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e8d:	8b 55 08             	mov    0x8(%ebp),%edx
80101e90:	8b 12                	mov    (%edx),%edx
80101e92:	83 ec 08             	sub    $0x8,%esp
80101e95:	50                   	push   %eax
80101e96:	52                   	push   %edx
80101e97:	e8 d4 f7 ff ff       	call   80101670 <bfree>
80101e9c:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ea5:	83 c2 14             	add    $0x14,%edx
80101ea8:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101eaf:	00 
  for(i = 0; i < NDIRECT; i++){
80101eb0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101eb4:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101eb8:	7e b5                	jle    80101e6f <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101eba:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebd:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ec3:	85 c0                	test   %eax,%eax
80101ec5:	0f 84 aa 00 00 00    	je     80101f75 <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101ecb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ece:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ed4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed7:	8b 00                	mov    (%eax),%eax
80101ed9:	83 ec 08             	sub    $0x8,%esp
80101edc:	52                   	push   %edx
80101edd:	50                   	push   %eax
80101ede:	e8 26 e3 ff ff       	call   80100209 <bread>
80101ee3:	83 c4 10             	add    $0x10,%esp
80101ee6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101ee9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eec:	83 c0 5c             	add    $0x5c,%eax
80101eef:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ef2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ef9:	eb 3c                	jmp    80101f37 <itrunc+0xdb>
      if(a[j])
80101efb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101efe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f08:	01 d0                	add    %edx,%eax
80101f0a:	8b 00                	mov    (%eax),%eax
80101f0c:	85 c0                	test   %eax,%eax
80101f0e:	74 23                	je     80101f33 <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101f10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f1d:	01 d0                	add    %edx,%eax
80101f1f:	8b 00                	mov    (%eax),%eax
80101f21:	8b 55 08             	mov    0x8(%ebp),%edx
80101f24:	8b 12                	mov    (%edx),%edx
80101f26:	83 ec 08             	sub    $0x8,%esp
80101f29:	50                   	push   %eax
80101f2a:	52                   	push   %edx
80101f2b:	e8 40 f7 ff ff       	call   80101670 <bfree>
80101f30:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101f33:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f3a:	83 f8 7f             	cmp    $0x7f,%eax
80101f3d:	76 bc                	jbe    80101efb <itrunc+0x9f>
    }
    brelse(bp);
80101f3f:	83 ec 0c             	sub    $0xc,%esp
80101f42:	ff 75 ec             	push   -0x14(%ebp)
80101f45:	e8 49 e3 ff ff       	call   80100293 <brelse>
80101f4a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f50:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f56:	8b 55 08             	mov    0x8(%ebp),%edx
80101f59:	8b 12                	mov    (%edx),%edx
80101f5b:	83 ec 08             	sub    $0x8,%esp
80101f5e:	50                   	push   %eax
80101f5f:	52                   	push   %edx
80101f60:	e8 0b f7 ff ff       	call   80101670 <bfree>
80101f65:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f68:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6b:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f72:	00 00 00 
  }

  ip->size = 0;
80101f75:	8b 45 08             	mov    0x8(%ebp),%eax
80101f78:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f7f:	83 ec 0c             	sub    $0xc,%esp
80101f82:	ff 75 08             	push   0x8(%ebp)
80101f85:	e8 5f f9 ff ff       	call   801018e9 <iupdate>
80101f8a:	83 c4 10             	add    $0x10,%esp
}
80101f8d:	90                   	nop
80101f8e:	c9                   	leave
80101f8f:	c3                   	ret

80101f90 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f90:	f3 0f 1e fb          	endbr32
80101f94:	55                   	push   %ebp
80101f95:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f97:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9a:	8b 00                	mov    (%eax),%eax
80101f9c:	89 c2                	mov    %eax,%edx
80101f9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fa1:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa7:	8b 50 04             	mov    0x4(%eax),%edx
80101faa:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fad:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb3:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101fb7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fba:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc0:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101fc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fc7:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fce:	8b 50 58             	mov    0x58(%eax),%edx
80101fd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fd4:	89 50 10             	mov    %edx,0x10(%eax)
}
80101fd7:	90                   	nop
80101fd8:	5d                   	pop    %ebp
80101fd9:	c3                   	ret

80101fda <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101fda:	f3 0f 1e fb          	endbr32
80101fde:	55                   	push   %ebp
80101fdf:	89 e5                	mov    %esp,%ebp
80101fe1:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101feb:	66 83 f8 03          	cmp    $0x3,%ax
80101fef:	75 5c                	jne    8010204d <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ff1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ff8:	66 85 c0             	test   %ax,%ax
80101ffb:	78 20                	js     8010201d <readi+0x43>
80101ffd:	8b 45 08             	mov    0x8(%ebp),%eax
80102000:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102004:	66 83 f8 09          	cmp    $0x9,%ax
80102008:	7f 13                	jg     8010201d <readi+0x43>
8010200a:	8b 45 08             	mov    0x8(%ebp),%eax
8010200d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102011:	98                   	cwtl
80102012:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80102019:	85 c0                	test   %eax,%eax
8010201b:	75 0a                	jne    80102027 <readi+0x4d>
      return -1;
8010201d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102022:	e9 0a 01 00 00       	jmp    80102131 <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80102027:	8b 45 08             	mov    0x8(%ebp),%eax
8010202a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010202e:	98                   	cwtl
8010202f:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80102036:	8b 55 14             	mov    0x14(%ebp),%edx
80102039:	83 ec 04             	sub    $0x4,%esp
8010203c:	52                   	push   %edx
8010203d:	ff 75 0c             	push   0xc(%ebp)
80102040:	ff 75 08             	push   0x8(%ebp)
80102043:	ff d0                	call   *%eax
80102045:	83 c4 10             	add    $0x10,%esp
80102048:	e9 e4 00 00 00       	jmp    80102131 <readi+0x157>
  }

  if(off > ip->size || off + n < off)
8010204d:	8b 45 08             	mov    0x8(%ebp),%eax
80102050:	8b 40 58             	mov    0x58(%eax),%eax
80102053:	39 45 10             	cmp    %eax,0x10(%ebp)
80102056:	77 0d                	ja     80102065 <readi+0x8b>
80102058:	8b 55 10             	mov    0x10(%ebp),%edx
8010205b:	8b 45 14             	mov    0x14(%ebp),%eax
8010205e:	01 d0                	add    %edx,%eax
80102060:	39 45 10             	cmp    %eax,0x10(%ebp)
80102063:	76 0a                	jbe    8010206f <readi+0x95>
    return -1;
80102065:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010206a:	e9 c2 00 00 00       	jmp    80102131 <readi+0x157>
  if(off + n > ip->size)
8010206f:	8b 55 10             	mov    0x10(%ebp),%edx
80102072:	8b 45 14             	mov    0x14(%ebp),%eax
80102075:	01 c2                	add    %eax,%edx
80102077:	8b 45 08             	mov    0x8(%ebp),%eax
8010207a:	8b 40 58             	mov    0x58(%eax),%eax
8010207d:	39 c2                	cmp    %eax,%edx
8010207f:	76 0c                	jbe    8010208d <readi+0xb3>
    n = ip->size - off;
80102081:	8b 45 08             	mov    0x8(%ebp),%eax
80102084:	8b 40 58             	mov    0x58(%eax),%eax
80102087:	2b 45 10             	sub    0x10(%ebp),%eax
8010208a:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010208d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102094:	e9 89 00 00 00       	jmp    80102122 <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102099:	8b 45 10             	mov    0x10(%ebp),%eax
8010209c:	c1 e8 09             	shr    $0x9,%eax
8010209f:	83 ec 08             	sub    $0x8,%esp
801020a2:	50                   	push   %eax
801020a3:	ff 75 08             	push   0x8(%ebp)
801020a6:	e8 8d fc ff ff       	call   80101d38 <bmap>
801020ab:	83 c4 10             	add    $0x10,%esp
801020ae:	8b 55 08             	mov    0x8(%ebp),%edx
801020b1:	8b 12                	mov    (%edx),%edx
801020b3:	83 ec 08             	sub    $0x8,%esp
801020b6:	50                   	push   %eax
801020b7:	52                   	push   %edx
801020b8:	e8 4c e1 ff ff       	call   80100209 <bread>
801020bd:	83 c4 10             	add    $0x10,%esp
801020c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020c3:	8b 45 10             	mov    0x10(%ebp),%eax
801020c6:	25 ff 01 00 00       	and    $0x1ff,%eax
801020cb:	ba 00 02 00 00       	mov    $0x200,%edx
801020d0:	29 c2                	sub    %eax,%edx
801020d2:	8b 45 14             	mov    0x14(%ebp),%eax
801020d5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801020d8:	39 c2                	cmp    %eax,%edx
801020da:	0f 46 c2             	cmovbe %edx,%eax
801020dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801020e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020e3:	8d 50 5c             	lea    0x5c(%eax),%edx
801020e6:	8b 45 10             	mov    0x10(%ebp),%eax
801020e9:	25 ff 01 00 00       	and    $0x1ff,%eax
801020ee:	01 d0                	add    %edx,%eax
801020f0:	83 ec 04             	sub    $0x4,%esp
801020f3:	ff 75 ec             	push   -0x14(%ebp)
801020f6:	50                   	push   %eax
801020f7:	ff 75 0c             	push   0xc(%ebp)
801020fa:	e8 33 2d 00 00       	call   80104e32 <memmove>
801020ff:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102102:	83 ec 0c             	sub    $0xc,%esp
80102105:	ff 75 f0             	push   -0x10(%ebp)
80102108:	e8 86 e1 ff ff       	call   80100293 <brelse>
8010210d:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102110:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102113:	01 45 f4             	add    %eax,-0xc(%ebp)
80102116:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102119:	01 45 10             	add    %eax,0x10(%ebp)
8010211c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010211f:	01 45 0c             	add    %eax,0xc(%ebp)
80102122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102125:	3b 45 14             	cmp    0x14(%ebp),%eax
80102128:	0f 82 6b ff ff ff    	jb     80102099 <readi+0xbf>
  }
  return n;
8010212e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102131:	c9                   	leave
80102132:	c3                   	ret

80102133 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102133:	f3 0f 1e fb          	endbr32
80102137:	55                   	push   %ebp
80102138:	89 e5                	mov    %esp,%ebp
8010213a:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010213d:	8b 45 08             	mov    0x8(%ebp),%eax
80102140:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102144:	66 83 f8 03          	cmp    $0x3,%ax
80102148:	75 5c                	jne    801021a6 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010214a:	8b 45 08             	mov    0x8(%ebp),%eax
8010214d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102151:	66 85 c0             	test   %ax,%ax
80102154:	78 20                	js     80102176 <writei+0x43>
80102156:	8b 45 08             	mov    0x8(%ebp),%eax
80102159:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010215d:	66 83 f8 09          	cmp    $0x9,%ax
80102161:	7f 13                	jg     80102176 <writei+0x43>
80102163:	8b 45 08             	mov    0x8(%ebp),%eax
80102166:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010216a:	98                   	cwtl
8010216b:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
80102172:	85 c0                	test   %eax,%eax
80102174:	75 0a                	jne    80102180 <writei+0x4d>
      return -1;
80102176:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010217b:	e9 3b 01 00 00       	jmp    801022bb <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
80102180:	8b 45 08             	mov    0x8(%ebp),%eax
80102183:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102187:	98                   	cwtl
80102188:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
8010218f:	8b 55 14             	mov    0x14(%ebp),%edx
80102192:	83 ec 04             	sub    $0x4,%esp
80102195:	52                   	push   %edx
80102196:	ff 75 0c             	push   0xc(%ebp)
80102199:	ff 75 08             	push   0x8(%ebp)
8010219c:	ff d0                	call   *%eax
8010219e:	83 c4 10             	add    $0x10,%esp
801021a1:	e9 15 01 00 00       	jmp    801022bb <writei+0x188>
  }

  if(off > ip->size || off + n < off)
801021a6:	8b 45 08             	mov    0x8(%ebp),%eax
801021a9:	8b 40 58             	mov    0x58(%eax),%eax
801021ac:	39 45 10             	cmp    %eax,0x10(%ebp)
801021af:	77 0d                	ja     801021be <writei+0x8b>
801021b1:	8b 55 10             	mov    0x10(%ebp),%edx
801021b4:	8b 45 14             	mov    0x14(%ebp),%eax
801021b7:	01 d0                	add    %edx,%eax
801021b9:	39 45 10             	cmp    %eax,0x10(%ebp)
801021bc:	76 0a                	jbe    801021c8 <writei+0x95>
    return -1;
801021be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021c3:	e9 f3 00 00 00       	jmp    801022bb <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
801021c8:	8b 55 10             	mov    0x10(%ebp),%edx
801021cb:	8b 45 14             	mov    0x14(%ebp),%eax
801021ce:	01 d0                	add    %edx,%eax
801021d0:	3d 00 18 01 00       	cmp    $0x11800,%eax
801021d5:	76 0a                	jbe    801021e1 <writei+0xae>
    return -1;
801021d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021dc:	e9 da 00 00 00       	jmp    801022bb <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021e8:	e9 97 00 00 00       	jmp    80102284 <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801021ed:	8b 45 10             	mov    0x10(%ebp),%eax
801021f0:	c1 e8 09             	shr    $0x9,%eax
801021f3:	83 ec 08             	sub    $0x8,%esp
801021f6:	50                   	push   %eax
801021f7:	ff 75 08             	push   0x8(%ebp)
801021fa:	e8 39 fb ff ff       	call   80101d38 <bmap>
801021ff:	83 c4 10             	add    $0x10,%esp
80102202:	8b 55 08             	mov    0x8(%ebp),%edx
80102205:	8b 12                	mov    (%edx),%edx
80102207:	83 ec 08             	sub    $0x8,%esp
8010220a:	50                   	push   %eax
8010220b:	52                   	push   %edx
8010220c:	e8 f8 df ff ff       	call   80100209 <bread>
80102211:	83 c4 10             	add    $0x10,%esp
80102214:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102217:	8b 45 10             	mov    0x10(%ebp),%eax
8010221a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010221f:	ba 00 02 00 00       	mov    $0x200,%edx
80102224:	29 c2                	sub    %eax,%edx
80102226:	8b 45 14             	mov    0x14(%ebp),%eax
80102229:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010222c:	39 c2                	cmp    %eax,%edx
8010222e:	0f 46 c2             	cmovbe %edx,%eax
80102231:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102234:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102237:	8d 50 5c             	lea    0x5c(%eax),%edx
8010223a:	8b 45 10             	mov    0x10(%ebp),%eax
8010223d:	25 ff 01 00 00       	and    $0x1ff,%eax
80102242:	01 d0                	add    %edx,%eax
80102244:	83 ec 04             	sub    $0x4,%esp
80102247:	ff 75 ec             	push   -0x14(%ebp)
8010224a:	ff 75 0c             	push   0xc(%ebp)
8010224d:	50                   	push   %eax
8010224e:	e8 df 2b 00 00       	call   80104e32 <memmove>
80102253:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102256:	83 ec 0c             	sub    $0xc,%esp
80102259:	ff 75 f0             	push   -0x10(%ebp)
8010225c:	e8 af 11 00 00       	call   80103410 <log_write>
80102261:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102264:	83 ec 0c             	sub    $0xc,%esp
80102267:	ff 75 f0             	push   -0x10(%ebp)
8010226a:	e8 24 e0 ff ff       	call   80100293 <brelse>
8010226f:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102272:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102275:	01 45 f4             	add    %eax,-0xc(%ebp)
80102278:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010227b:	01 45 10             	add    %eax,0x10(%ebp)
8010227e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102281:	01 45 0c             	add    %eax,0xc(%ebp)
80102284:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102287:	3b 45 14             	cmp    0x14(%ebp),%eax
8010228a:	0f 82 5d ff ff ff    	jb     801021ed <writei+0xba>
  }

  if(n > 0 && off > ip->size){
80102290:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102294:	74 22                	je     801022b8 <writei+0x185>
80102296:	8b 45 08             	mov    0x8(%ebp),%eax
80102299:	8b 40 58             	mov    0x58(%eax),%eax
8010229c:	39 45 10             	cmp    %eax,0x10(%ebp)
8010229f:	76 17                	jbe    801022b8 <writei+0x185>
    ip->size = off;
801022a1:	8b 45 08             	mov    0x8(%ebp),%eax
801022a4:	8b 55 10             	mov    0x10(%ebp),%edx
801022a7:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801022aa:	83 ec 0c             	sub    $0xc,%esp
801022ad:	ff 75 08             	push   0x8(%ebp)
801022b0:	e8 34 f6 ff ff       	call   801018e9 <iupdate>
801022b5:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801022b8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801022bb:	c9                   	leave
801022bc:	c3                   	ret

801022bd <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801022bd:	f3 0f 1e fb          	endbr32
801022c1:	55                   	push   %ebp
801022c2:	89 e5                	mov    %esp,%ebp
801022c4:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801022c7:	83 ec 04             	sub    $0x4,%esp
801022ca:	6a 0e                	push   $0xe
801022cc:	ff 75 0c             	push   0xc(%ebp)
801022cf:	ff 75 08             	push   0x8(%ebp)
801022d2:	e8 f9 2b 00 00       	call   80104ed0 <strncmp>
801022d7:	83 c4 10             	add    $0x10,%esp
}
801022da:	c9                   	leave
801022db:	c3                   	ret

801022dc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801022dc:	f3 0f 1e fb          	endbr32
801022e0:	55                   	push   %ebp
801022e1:	89 e5                	mov    %esp,%ebp
801022e3:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801022e6:	8b 45 08             	mov    0x8(%ebp),%eax
801022e9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801022ed:	66 83 f8 01          	cmp    $0x1,%ax
801022f1:	74 0d                	je     80102300 <dirlookup+0x24>
    panic("dirlookup not DIR");
801022f3:	83 ec 0c             	sub    $0xc,%esp
801022f6:	68 9d a8 10 80       	push   $0x8010a89d
801022fb:	e8 de e2 ff ff       	call   801005de <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102300:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102307:	eb 7b                	jmp    80102384 <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102309:	6a 10                	push   $0x10
8010230b:	ff 75 f4             	push   -0xc(%ebp)
8010230e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102311:	50                   	push   %eax
80102312:	ff 75 08             	push   0x8(%ebp)
80102315:	e8 c0 fc ff ff       	call   80101fda <readi>
8010231a:	83 c4 10             	add    $0x10,%esp
8010231d:	83 f8 10             	cmp    $0x10,%eax
80102320:	74 0d                	je     8010232f <dirlookup+0x53>
      panic("dirlookup read");
80102322:	83 ec 0c             	sub    $0xc,%esp
80102325:	68 af a8 10 80       	push   $0x8010a8af
8010232a:	e8 af e2 ff ff       	call   801005de <panic>
    if(de.inum == 0)
8010232f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102333:	66 85 c0             	test   %ax,%ax
80102336:	74 47                	je     8010237f <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
80102338:	83 ec 08             	sub    $0x8,%esp
8010233b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010233e:	83 c0 02             	add    $0x2,%eax
80102341:	50                   	push   %eax
80102342:	ff 75 0c             	push   0xc(%ebp)
80102345:	e8 73 ff ff ff       	call   801022bd <namecmp>
8010234a:	83 c4 10             	add    $0x10,%esp
8010234d:	85 c0                	test   %eax,%eax
8010234f:	75 2f                	jne    80102380 <dirlookup+0xa4>
      // entry matches path element
      if(poff)
80102351:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102355:	74 08                	je     8010235f <dirlookup+0x83>
        *poff = off;
80102357:	8b 45 10             	mov    0x10(%ebp),%eax
8010235a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010235d:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010235f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102363:	0f b7 c0             	movzwl %ax,%eax
80102366:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102369:	8b 45 08             	mov    0x8(%ebp),%eax
8010236c:	8b 00                	mov    (%eax),%eax
8010236e:	83 ec 08             	sub    $0x8,%esp
80102371:	ff 75 f0             	push   -0x10(%ebp)
80102374:	50                   	push   %eax
80102375:	e8 34 f6 ff ff       	call   801019ae <iget>
8010237a:	83 c4 10             	add    $0x10,%esp
8010237d:	eb 19                	jmp    80102398 <dirlookup+0xbc>
      continue;
8010237f:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102380:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102384:	8b 45 08             	mov    0x8(%ebp),%eax
80102387:	8b 40 58             	mov    0x58(%eax),%eax
8010238a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010238d:	0f 82 76 ff ff ff    	jb     80102309 <dirlookup+0x2d>
    }
  }

  return 0;
80102393:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102398:	c9                   	leave
80102399:	c3                   	ret

8010239a <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010239a:	f3 0f 1e fb          	endbr32
8010239e:	55                   	push   %ebp
8010239f:	89 e5                	mov    %esp,%ebp
801023a1:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801023a4:	83 ec 04             	sub    $0x4,%esp
801023a7:	6a 00                	push   $0x0
801023a9:	ff 75 0c             	push   0xc(%ebp)
801023ac:	ff 75 08             	push   0x8(%ebp)
801023af:	e8 28 ff ff ff       	call   801022dc <dirlookup>
801023b4:	83 c4 10             	add    $0x10,%esp
801023b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023be:	74 18                	je     801023d8 <dirlink+0x3e>
    iput(ip);
801023c0:	83 ec 0c             	sub    $0xc,%esp
801023c3:	ff 75 f0             	push   -0x10(%ebp)
801023c6:	e8 70 f8 ff ff       	call   80101c3b <iput>
801023cb:	83 c4 10             	add    $0x10,%esp
    return -1;
801023ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023d3:	e9 9c 00 00 00       	jmp    80102474 <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023df:	eb 39                	jmp    8010241a <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e4:	6a 10                	push   $0x10
801023e6:	50                   	push   %eax
801023e7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023ea:	50                   	push   %eax
801023eb:	ff 75 08             	push   0x8(%ebp)
801023ee:	e8 e7 fb ff ff       	call   80101fda <readi>
801023f3:	83 c4 10             	add    $0x10,%esp
801023f6:	83 f8 10             	cmp    $0x10,%eax
801023f9:	74 0d                	je     80102408 <dirlink+0x6e>
      panic("dirlink read");
801023fb:	83 ec 0c             	sub    $0xc,%esp
801023fe:	68 be a8 10 80       	push   $0x8010a8be
80102403:	e8 d6 e1 ff ff       	call   801005de <panic>
    if(de.inum == 0)
80102408:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010240c:	66 85 c0             	test   %ax,%ax
8010240f:	74 18                	je     80102429 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102411:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102414:	83 c0 10             	add    $0x10,%eax
80102417:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010241a:	8b 45 08             	mov    0x8(%ebp),%eax
8010241d:	8b 50 58             	mov    0x58(%eax),%edx
80102420:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102423:	39 c2                	cmp    %eax,%edx
80102425:	77 ba                	ja     801023e1 <dirlink+0x47>
80102427:	eb 01                	jmp    8010242a <dirlink+0x90>
      break;
80102429:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010242a:	83 ec 04             	sub    $0x4,%esp
8010242d:	6a 0e                	push   $0xe
8010242f:	ff 75 0c             	push   0xc(%ebp)
80102432:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102435:	83 c0 02             	add    $0x2,%eax
80102438:	50                   	push   %eax
80102439:	e8 ec 2a 00 00       	call   80104f2a <strncpy>
8010243e:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102441:	8b 45 10             	mov    0x10(%ebp),%eax
80102444:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010244b:	6a 10                	push   $0x10
8010244d:	50                   	push   %eax
8010244e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102451:	50                   	push   %eax
80102452:	ff 75 08             	push   0x8(%ebp)
80102455:	e8 d9 fc ff ff       	call   80102133 <writei>
8010245a:	83 c4 10             	add    $0x10,%esp
8010245d:	83 f8 10             	cmp    $0x10,%eax
80102460:	74 0d                	je     8010246f <dirlink+0xd5>
    panic("dirlink");
80102462:	83 ec 0c             	sub    $0xc,%esp
80102465:	68 cb a8 10 80       	push   $0x8010a8cb
8010246a:	e8 6f e1 ff ff       	call   801005de <panic>

  return 0;
8010246f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102474:	c9                   	leave
80102475:	c3                   	ret

80102476 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102476:	f3 0f 1e fb          	endbr32
8010247a:	55                   	push   %ebp
8010247b:	89 e5                	mov    %esp,%ebp
8010247d:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102480:	eb 04                	jmp    80102486 <skipelem+0x10>
    path++;
80102482:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102486:	8b 45 08             	mov    0x8(%ebp),%eax
80102489:	0f b6 00             	movzbl (%eax),%eax
8010248c:	3c 2f                	cmp    $0x2f,%al
8010248e:	74 f2                	je     80102482 <skipelem+0xc>
  if(*path == 0)
80102490:	8b 45 08             	mov    0x8(%ebp),%eax
80102493:	0f b6 00             	movzbl (%eax),%eax
80102496:	84 c0                	test   %al,%al
80102498:	75 07                	jne    801024a1 <skipelem+0x2b>
    return 0;
8010249a:	b8 00 00 00 00       	mov    $0x0,%eax
8010249f:	eb 77                	jmp    80102518 <skipelem+0xa2>
  s = path;
801024a1:	8b 45 08             	mov    0x8(%ebp),%eax
801024a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801024a7:	eb 04                	jmp    801024ad <skipelem+0x37>
    path++;
801024a9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801024ad:	8b 45 08             	mov    0x8(%ebp),%eax
801024b0:	0f b6 00             	movzbl (%eax),%eax
801024b3:	3c 2f                	cmp    $0x2f,%al
801024b5:	74 0a                	je     801024c1 <skipelem+0x4b>
801024b7:	8b 45 08             	mov    0x8(%ebp),%eax
801024ba:	0f b6 00             	movzbl (%eax),%eax
801024bd:	84 c0                	test   %al,%al
801024bf:	75 e8                	jne    801024a9 <skipelem+0x33>
  len = path - s;
801024c1:	8b 45 08             	mov    0x8(%ebp),%eax
801024c4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801024c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801024ca:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801024ce:	7e 15                	jle    801024e5 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801024d0:	83 ec 04             	sub    $0x4,%esp
801024d3:	6a 0e                	push   $0xe
801024d5:	ff 75 f4             	push   -0xc(%ebp)
801024d8:	ff 75 0c             	push   0xc(%ebp)
801024db:	e8 52 29 00 00       	call   80104e32 <memmove>
801024e0:	83 c4 10             	add    $0x10,%esp
801024e3:	eb 26                	jmp    8010250b <skipelem+0x95>
  else {
    memmove(name, s, len);
801024e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e8:	83 ec 04             	sub    $0x4,%esp
801024eb:	50                   	push   %eax
801024ec:	ff 75 f4             	push   -0xc(%ebp)
801024ef:	ff 75 0c             	push   0xc(%ebp)
801024f2:	e8 3b 29 00 00       	call   80104e32 <memmove>
801024f7:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801024fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80102500:	01 d0                	add    %edx,%eax
80102502:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102505:	eb 04                	jmp    8010250b <skipelem+0x95>
    path++;
80102507:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010250b:	8b 45 08             	mov    0x8(%ebp),%eax
8010250e:	0f b6 00             	movzbl (%eax),%eax
80102511:	3c 2f                	cmp    $0x2f,%al
80102513:	74 f2                	je     80102507 <skipelem+0x91>
  return path;
80102515:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102518:	c9                   	leave
80102519:	c3                   	ret

8010251a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010251a:	f3 0f 1e fb          	endbr32
8010251e:	55                   	push   %ebp
8010251f:	89 e5                	mov    %esp,%ebp
80102521:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102524:	8b 45 08             	mov    0x8(%ebp),%eax
80102527:	0f b6 00             	movzbl (%eax),%eax
8010252a:	3c 2f                	cmp    $0x2f,%al
8010252c:	75 17                	jne    80102545 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
8010252e:	83 ec 08             	sub    $0x8,%esp
80102531:	6a 01                	push   $0x1
80102533:	6a 01                	push   $0x1
80102535:	e8 74 f4 ff ff       	call   801019ae <iget>
8010253a:	83 c4 10             	add    $0x10,%esp
8010253d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102540:	e9 ba 00 00 00       	jmp    801025ff <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
80102545:	e8 b5 16 00 00       	call   80103bff <myproc>
8010254a:	8b 40 68             	mov    0x68(%eax),%eax
8010254d:	83 ec 0c             	sub    $0xc,%esp
80102550:	50                   	push   %eax
80102551:	e8 3e f5 ff ff       	call   80101a94 <idup>
80102556:	83 c4 10             	add    $0x10,%esp
80102559:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010255c:	e9 9e 00 00 00       	jmp    801025ff <namex+0xe5>
    ilock(ip);
80102561:	83 ec 0c             	sub    $0xc,%esp
80102564:	ff 75 f4             	push   -0xc(%ebp)
80102567:	e8 66 f5 ff ff       	call   80101ad2 <ilock>
8010256c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010256f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102572:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102576:	66 83 f8 01          	cmp    $0x1,%ax
8010257a:	74 18                	je     80102594 <namex+0x7a>
      iunlockput(ip);
8010257c:	83 ec 0c             	sub    $0xc,%esp
8010257f:	ff 75 f4             	push   -0xc(%ebp)
80102582:	e8 88 f7 ff ff       	call   80101d0f <iunlockput>
80102587:	83 c4 10             	add    $0x10,%esp
      return 0;
8010258a:	b8 00 00 00 00       	mov    $0x0,%eax
8010258f:	e9 a7 00 00 00       	jmp    8010263b <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
80102594:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102598:	74 20                	je     801025ba <namex+0xa0>
8010259a:	8b 45 08             	mov    0x8(%ebp),%eax
8010259d:	0f b6 00             	movzbl (%eax),%eax
801025a0:	84 c0                	test   %al,%al
801025a2:	75 16                	jne    801025ba <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
801025a4:	83 ec 0c             	sub    $0xc,%esp
801025a7:	ff 75 f4             	push   -0xc(%ebp)
801025aa:	e8 3a f6 ff ff       	call   80101be9 <iunlock>
801025af:	83 c4 10             	add    $0x10,%esp
      return ip;
801025b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025b5:	e9 81 00 00 00       	jmp    8010263b <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801025ba:	83 ec 04             	sub    $0x4,%esp
801025bd:	6a 00                	push   $0x0
801025bf:	ff 75 10             	push   0x10(%ebp)
801025c2:	ff 75 f4             	push   -0xc(%ebp)
801025c5:	e8 12 fd ff ff       	call   801022dc <dirlookup>
801025ca:	83 c4 10             	add    $0x10,%esp
801025cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801025d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025d4:	75 15                	jne    801025eb <namex+0xd1>
      iunlockput(ip);
801025d6:	83 ec 0c             	sub    $0xc,%esp
801025d9:	ff 75 f4             	push   -0xc(%ebp)
801025dc:	e8 2e f7 ff ff       	call   80101d0f <iunlockput>
801025e1:	83 c4 10             	add    $0x10,%esp
      return 0;
801025e4:	b8 00 00 00 00       	mov    $0x0,%eax
801025e9:	eb 50                	jmp    8010263b <namex+0x121>
    }
    iunlockput(ip);
801025eb:	83 ec 0c             	sub    $0xc,%esp
801025ee:	ff 75 f4             	push   -0xc(%ebp)
801025f1:	e8 19 f7 ff ff       	call   80101d0f <iunlockput>
801025f6:	83 c4 10             	add    $0x10,%esp
    ip = next;
801025f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801025ff:	83 ec 08             	sub    $0x8,%esp
80102602:	ff 75 10             	push   0x10(%ebp)
80102605:	ff 75 08             	push   0x8(%ebp)
80102608:	e8 69 fe ff ff       	call   80102476 <skipelem>
8010260d:	83 c4 10             	add    $0x10,%esp
80102610:	89 45 08             	mov    %eax,0x8(%ebp)
80102613:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102617:	0f 85 44 ff ff ff    	jne    80102561 <namex+0x47>
  }
  if(nameiparent){
8010261d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102621:	74 15                	je     80102638 <namex+0x11e>
    iput(ip);
80102623:	83 ec 0c             	sub    $0xc,%esp
80102626:	ff 75 f4             	push   -0xc(%ebp)
80102629:	e8 0d f6 ff ff       	call   80101c3b <iput>
8010262e:	83 c4 10             	add    $0x10,%esp
    return 0;
80102631:	b8 00 00 00 00       	mov    $0x0,%eax
80102636:	eb 03                	jmp    8010263b <namex+0x121>
  }
  return ip;
80102638:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010263b:	c9                   	leave
8010263c:	c3                   	ret

8010263d <namei>:

struct inode*
namei(char *path)
{
8010263d:	f3 0f 1e fb          	endbr32
80102641:	55                   	push   %ebp
80102642:	89 e5                	mov    %esp,%ebp
80102644:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102647:	83 ec 04             	sub    $0x4,%esp
8010264a:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010264d:	50                   	push   %eax
8010264e:	6a 00                	push   $0x0
80102650:	ff 75 08             	push   0x8(%ebp)
80102653:	e8 c2 fe ff ff       	call   8010251a <namex>
80102658:	83 c4 10             	add    $0x10,%esp
}
8010265b:	c9                   	leave
8010265c:	c3                   	ret

8010265d <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010265d:	f3 0f 1e fb          	endbr32
80102661:	55                   	push   %ebp
80102662:	89 e5                	mov    %esp,%ebp
80102664:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102667:	83 ec 04             	sub    $0x4,%esp
8010266a:	ff 75 0c             	push   0xc(%ebp)
8010266d:	6a 01                	push   $0x1
8010266f:	ff 75 08             	push   0x8(%ebp)
80102672:	e8 a3 fe ff ff       	call   8010251a <namex>
80102677:	83 c4 10             	add    $0x10,%esp
}
8010267a:	c9                   	leave
8010267b:	c3                   	ret

8010267c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010267c:	f3 0f 1e fb          	endbr32
80102680:	55                   	push   %ebp
80102681:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102683:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102688:	8b 55 08             	mov    0x8(%ebp),%edx
8010268b:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010268d:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102692:	8b 40 10             	mov    0x10(%eax),%eax
}
80102695:	5d                   	pop    %ebp
80102696:	c3                   	ret

80102697 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102697:	f3 0f 1e fb          	endbr32
8010269b:	55                   	push   %ebp
8010269c:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010269e:	a1 d4 53 19 80       	mov    0x801953d4,%eax
801026a3:	8b 55 08             	mov    0x8(%ebp),%edx
801026a6:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801026a8:	a1 d4 53 19 80       	mov    0x801953d4,%eax
801026ad:	8b 55 0c             	mov    0xc(%ebp),%edx
801026b0:	89 50 10             	mov    %edx,0x10(%eax)
}
801026b3:	90                   	nop
801026b4:	5d                   	pop    %ebp
801026b5:	c3                   	ret

801026b6 <ioapicinit>:

void
ioapicinit(void)
{
801026b6:	f3 0f 1e fb          	endbr32
801026ba:	55                   	push   %ebp
801026bb:	89 e5                	mov    %esp,%ebp
801026bd:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801026c0:	c7 05 d4 53 19 80 00 	movl   $0xfec00000,0x801953d4
801026c7:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801026ca:	6a 01                	push   $0x1
801026cc:	e8 ab ff ff ff       	call   8010267c <ioapicread>
801026d1:	83 c4 04             	add    $0x4,%esp
801026d4:	c1 e8 10             	shr    $0x10,%eax
801026d7:	25 ff 00 00 00       	and    $0xff,%eax
801026dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801026df:	6a 00                	push   $0x0
801026e1:	e8 96 ff ff ff       	call   8010267c <ioapicread>
801026e6:	83 c4 04             	add    $0x4,%esp
801026e9:	c1 e8 18             	shr    $0x18,%eax
801026ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801026ef:	0f b6 05 a0 7d 19 80 	movzbl 0x80197da0,%eax
801026f6:	0f b6 c0             	movzbl %al,%eax
801026f9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801026fc:	74 10                	je     8010270e <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801026fe:	83 ec 0c             	sub    $0xc,%esp
80102701:	68 d4 a8 10 80       	push   $0x8010a8d4
80102706:	e8 01 dd ff ff       	call   8010040c <cprintf>
8010270b:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010270e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102715:	eb 3f                	jmp    80102756 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271a:	83 c0 20             	add    $0x20,%eax
8010271d:	0d 00 00 01 00       	or     $0x10000,%eax
80102722:	89 c2                	mov    %eax,%edx
80102724:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102727:	83 c0 08             	add    $0x8,%eax
8010272a:	01 c0                	add    %eax,%eax
8010272c:	83 ec 08             	sub    $0x8,%esp
8010272f:	52                   	push   %edx
80102730:	50                   	push   %eax
80102731:	e8 61 ff ff ff       	call   80102697 <ioapicwrite>
80102736:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010273c:	83 c0 08             	add    $0x8,%eax
8010273f:	01 c0                	add    %eax,%eax
80102741:	83 c0 01             	add    $0x1,%eax
80102744:	83 ec 08             	sub    $0x8,%esp
80102747:	6a 00                	push   $0x0
80102749:	50                   	push   %eax
8010274a:	e8 48 ff ff ff       	call   80102697 <ioapicwrite>
8010274f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102752:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102756:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102759:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010275c:	7e b9                	jle    80102717 <ioapicinit+0x61>
  }
}
8010275e:	90                   	nop
8010275f:	90                   	nop
80102760:	c9                   	leave
80102761:	c3                   	ret

80102762 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102762:	f3 0f 1e fb          	endbr32
80102766:	55                   	push   %ebp
80102767:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102769:	8b 45 08             	mov    0x8(%ebp),%eax
8010276c:	83 c0 20             	add    $0x20,%eax
8010276f:	89 c2                	mov    %eax,%edx
80102771:	8b 45 08             	mov    0x8(%ebp),%eax
80102774:	83 c0 08             	add    $0x8,%eax
80102777:	01 c0                	add    %eax,%eax
80102779:	52                   	push   %edx
8010277a:	50                   	push   %eax
8010277b:	e8 17 ff ff ff       	call   80102697 <ioapicwrite>
80102780:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102783:	8b 45 0c             	mov    0xc(%ebp),%eax
80102786:	c1 e0 18             	shl    $0x18,%eax
80102789:	89 c2                	mov    %eax,%edx
8010278b:	8b 45 08             	mov    0x8(%ebp),%eax
8010278e:	83 c0 08             	add    $0x8,%eax
80102791:	01 c0                	add    %eax,%eax
80102793:	83 c0 01             	add    $0x1,%eax
80102796:	52                   	push   %edx
80102797:	50                   	push   %eax
80102798:	e8 fa fe ff ff       	call   80102697 <ioapicwrite>
8010279d:	83 c4 08             	add    $0x8,%esp
}
801027a0:	90                   	nop
801027a1:	c9                   	leave
801027a2:	c3                   	ret

801027a3 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801027a3:	f3 0f 1e fb          	endbr32
801027a7:	55                   	push   %ebp
801027a8:	89 e5                	mov    %esp,%ebp
801027aa:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
801027ad:	83 ec 08             	sub    $0x8,%esp
801027b0:	68 06 a9 10 80       	push   $0x8010a906
801027b5:	68 e0 53 19 80       	push   $0x801953e0
801027ba:	e8 f7 22 00 00       	call   80104ab6 <initlock>
801027bf:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
801027c2:	c7 05 14 54 19 80 00 	movl   $0x0,0x80195414
801027c9:	00 00 00 
  freerange(vstart, vend);
801027cc:	83 ec 08             	sub    $0x8,%esp
801027cf:	ff 75 0c             	push   0xc(%ebp)
801027d2:	ff 75 08             	push   0x8(%ebp)
801027d5:	e8 2e 00 00 00       	call   80102808 <freerange>
801027da:	83 c4 10             	add    $0x10,%esp
}
801027dd:	90                   	nop
801027de:	c9                   	leave
801027df:	c3                   	ret

801027e0 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801027e0:	f3 0f 1e fb          	endbr32
801027e4:	55                   	push   %ebp
801027e5:	89 e5                	mov    %esp,%ebp
801027e7:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801027ea:	83 ec 08             	sub    $0x8,%esp
801027ed:	ff 75 0c             	push   0xc(%ebp)
801027f0:	ff 75 08             	push   0x8(%ebp)
801027f3:	e8 10 00 00 00       	call   80102808 <freerange>
801027f8:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801027fb:	c7 05 14 54 19 80 01 	movl   $0x1,0x80195414
80102802:	00 00 00 
}
80102805:	90                   	nop
80102806:	c9                   	leave
80102807:	c3                   	ret

80102808 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102808:	f3 0f 1e fb          	endbr32
8010280c:	55                   	push   %ebp
8010280d:	89 e5                	mov    %esp,%ebp
8010280f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102812:	8b 45 08             	mov    0x8(%ebp),%eax
80102815:	05 ff 0f 00 00       	add    $0xfff,%eax
8010281a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010281f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102822:	eb 15                	jmp    80102839 <freerange+0x31>
    kfree(p);
80102824:	83 ec 0c             	sub    $0xc,%esp
80102827:	ff 75 f4             	push   -0xc(%ebp)
8010282a:	e8 1b 00 00 00       	call   8010284a <kfree>
8010282f:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102832:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010283c:	05 00 10 00 00       	add    $0x1000,%eax
80102841:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102844:	73 de                	jae    80102824 <freerange+0x1c>
}
80102846:	90                   	nop
80102847:	90                   	nop
80102848:	c9                   	leave
80102849:	c3                   	ret

8010284a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
8010284a:	f3 0f 1e fb          	endbr32
8010284e:	55                   	push   %ebp
8010284f:	89 e5                	mov    %esp,%ebp
80102851:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102854:	8b 45 08             	mov    0x8(%ebp),%eax
80102857:	25 ff 0f 00 00       	and    $0xfff,%eax
8010285c:	85 c0                	test   %eax,%eax
8010285e:	75 18                	jne    80102878 <kfree+0x2e>
80102860:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
80102867:	72 0f                	jb     80102878 <kfree+0x2e>
80102869:	8b 45 08             	mov    0x8(%ebp),%eax
8010286c:	05 00 00 00 80       	add    $0x80000000,%eax
80102871:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102876:	76 0d                	jbe    80102885 <kfree+0x3b>
    panic("kfree");
80102878:	83 ec 0c             	sub    $0xc,%esp
8010287b:	68 0b a9 10 80       	push   $0x8010a90b
80102880:	e8 59 dd ff ff       	call   801005de <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102885:	83 ec 04             	sub    $0x4,%esp
80102888:	68 00 10 00 00       	push   $0x1000
8010288d:	6a 01                	push   $0x1
8010288f:	ff 75 08             	push   0x8(%ebp)
80102892:	e8 d4 24 00 00       	call   80104d6b <memset>
80102897:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010289a:	a1 14 54 19 80       	mov    0x80195414,%eax
8010289f:	85 c0                	test   %eax,%eax
801028a1:	74 10                	je     801028b3 <kfree+0x69>
    acquire(&kmem.lock);
801028a3:	83 ec 0c             	sub    $0xc,%esp
801028a6:	68 e0 53 19 80       	push   $0x801953e0
801028ab:	e8 2c 22 00 00       	call   80104adc <acquire>
801028b0:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
801028b3:	8b 45 08             	mov    0x8(%ebp),%eax
801028b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
801028b9:	8b 15 18 54 19 80    	mov    0x80195418,%edx
801028bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c2:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
801028c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c7:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
801028cc:	a1 14 54 19 80       	mov    0x80195414,%eax
801028d1:	85 c0                	test   %eax,%eax
801028d3:	74 10                	je     801028e5 <kfree+0x9b>
    release(&kmem.lock);
801028d5:	83 ec 0c             	sub    $0xc,%esp
801028d8:	68 e0 53 19 80       	push   $0x801953e0
801028dd:	e8 6c 22 00 00       	call   80104b4e <release>
801028e2:	83 c4 10             	add    $0x10,%esp
}
801028e5:	90                   	nop
801028e6:	c9                   	leave
801028e7:	c3                   	ret

801028e8 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801028e8:	f3 0f 1e fb          	endbr32
801028ec:	55                   	push   %ebp
801028ed:	89 e5                	mov    %esp,%ebp
801028ef:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801028f2:	a1 14 54 19 80       	mov    0x80195414,%eax
801028f7:	85 c0                	test   %eax,%eax
801028f9:	74 10                	je     8010290b <kalloc+0x23>
    acquire(&kmem.lock);
801028fb:	83 ec 0c             	sub    $0xc,%esp
801028fe:	68 e0 53 19 80       	push   $0x801953e0
80102903:	e8 d4 21 00 00       	call   80104adc <acquire>
80102908:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
8010290b:	a1 18 54 19 80       	mov    0x80195418,%eax
80102910:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102913:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102917:	74 0a                	je     80102923 <kalloc+0x3b>
    kmem.freelist = r->next;
80102919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010291c:	8b 00                	mov    (%eax),%eax
8010291e:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
80102923:	a1 14 54 19 80       	mov    0x80195414,%eax
80102928:	85 c0                	test   %eax,%eax
8010292a:	74 10                	je     8010293c <kalloc+0x54>
    release(&kmem.lock);
8010292c:	83 ec 0c             	sub    $0xc,%esp
8010292f:	68 e0 53 19 80       	push   $0x801953e0
80102934:	e8 15 22 00 00       	call   80104b4e <release>
80102939:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010293c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010293f:	c9                   	leave
80102940:	c3                   	ret

80102941 <inb>:
{
80102941:	55                   	push   %ebp
80102942:	89 e5                	mov    %esp,%ebp
80102944:	83 ec 14             	sub    $0x14,%esp
80102947:	8b 45 08             	mov    0x8(%ebp),%eax
8010294a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010294e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102952:	89 c2                	mov    %eax,%edx
80102954:	ec                   	in     (%dx),%al
80102955:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102958:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010295c:	c9                   	leave
8010295d:	c3                   	ret

8010295e <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010295e:	f3 0f 1e fb          	endbr32
80102962:	55                   	push   %ebp
80102963:	89 e5                	mov    %esp,%ebp
80102965:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102968:	6a 64                	push   $0x64
8010296a:	e8 d2 ff ff ff       	call   80102941 <inb>
8010296f:	83 c4 04             	add    $0x4,%esp
80102972:	0f b6 c0             	movzbl %al,%eax
80102975:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010297b:	83 e0 01             	and    $0x1,%eax
8010297e:	85 c0                	test   %eax,%eax
80102980:	75 0a                	jne    8010298c <kbdgetc+0x2e>
    return -1;
80102982:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102987:	e9 23 01 00 00       	jmp    80102aaf <kbdgetc+0x151>
  data = inb(KBDATAP);
8010298c:	6a 60                	push   $0x60
8010298e:	e8 ae ff ff ff       	call   80102941 <inb>
80102993:	83 c4 04             	add    $0x4,%esp
80102996:	0f b6 c0             	movzbl %al,%eax
80102999:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
8010299c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
801029a3:	75 17                	jne    801029bc <kbdgetc+0x5e>
    shift |= E0ESC;
801029a5:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029aa:	83 c8 40             	or     $0x40,%eax
801029ad:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
801029b2:	b8 00 00 00 00       	mov    $0x0,%eax
801029b7:	e9 f3 00 00 00       	jmp    80102aaf <kbdgetc+0x151>
  } else if(data & 0x80){
801029bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029bf:	25 80 00 00 00       	and    $0x80,%eax
801029c4:	85 c0                	test   %eax,%eax
801029c6:	74 45                	je     80102a0d <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801029c8:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029cd:	83 e0 40             	and    $0x40,%eax
801029d0:	85 c0                	test   %eax,%eax
801029d2:	75 08                	jne    801029dc <kbdgetc+0x7e>
801029d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029d7:	83 e0 7f             	and    $0x7f,%eax
801029da:	eb 03                	jmp    801029df <kbdgetc+0x81>
801029dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029df:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801029e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029e5:	05 20 d0 10 80       	add    $0x8010d020,%eax
801029ea:	0f b6 00             	movzbl (%eax),%eax
801029ed:	83 c8 40             	or     $0x40,%eax
801029f0:	0f b6 c0             	movzbl %al,%eax
801029f3:	f7 d0                	not    %eax
801029f5:	89 c2                	mov    %eax,%edx
801029f7:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029fc:	21 d0                	and    %edx,%eax
801029fe:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
80102a03:	b8 00 00 00 00       	mov    $0x0,%eax
80102a08:	e9 a2 00 00 00       	jmp    80102aaf <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102a0d:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a12:	83 e0 40             	and    $0x40,%eax
80102a15:	85 c0                	test   %eax,%eax
80102a17:	74 14                	je     80102a2d <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102a19:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102a20:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a25:	83 e0 bf             	and    $0xffffffbf,%eax
80102a28:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  }

  shift |= shiftcode[data];
80102a2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a30:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102a35:	0f b6 00             	movzbl (%eax),%eax
80102a38:	0f b6 d0             	movzbl %al,%edx
80102a3b:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a40:	09 d0                	or     %edx,%eax
80102a42:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  shift ^= togglecode[data];
80102a47:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a4a:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102a4f:	0f b6 00             	movzbl (%eax),%eax
80102a52:	0f b6 d0             	movzbl %al,%edx
80102a55:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a5a:	31 d0                	xor    %edx,%eax
80102a5c:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  c = charcode[shift & (CTL | SHIFT)][data];
80102a61:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a66:	83 e0 03             	and    $0x3,%eax
80102a69:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102a70:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a73:	01 d0                	add    %edx,%eax
80102a75:	0f b6 00             	movzbl (%eax),%eax
80102a78:	0f b6 c0             	movzbl %al,%eax
80102a7b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102a7e:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a83:	83 e0 08             	and    $0x8,%eax
80102a86:	85 c0                	test   %eax,%eax
80102a88:	74 22                	je     80102aac <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102a8a:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102a8e:	76 0c                	jbe    80102a9c <kbdgetc+0x13e>
80102a90:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102a94:	77 06                	ja     80102a9c <kbdgetc+0x13e>
      c += 'A' - 'a';
80102a96:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102a9a:	eb 10                	jmp    80102aac <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102a9c:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102aa0:	76 0a                	jbe    80102aac <kbdgetc+0x14e>
80102aa2:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102aa6:	77 04                	ja     80102aac <kbdgetc+0x14e>
      c += 'a' - 'A';
80102aa8:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102aac:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102aaf:	c9                   	leave
80102ab0:	c3                   	ret

80102ab1 <kbdintr>:

void
kbdintr(void)
{
80102ab1:	f3 0f 1e fb          	endbr32
80102ab5:	55                   	push   %ebp
80102ab6:	89 e5                	mov    %esp,%ebp
80102ab8:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102abb:	83 ec 0c             	sub    $0xc,%esp
80102abe:	68 5e 29 10 80       	push   $0x8010295e
80102ac3:	e8 51 dd ff ff       	call   80100819 <consoleintr>
80102ac8:	83 c4 10             	add    $0x10,%esp
}
80102acb:	90                   	nop
80102acc:	c9                   	leave
80102acd:	c3                   	ret

80102ace <inb>:
{
80102ace:	55                   	push   %ebp
80102acf:	89 e5                	mov    %esp,%ebp
80102ad1:	83 ec 14             	sub    $0x14,%esp
80102ad4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102adb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102adf:	89 c2                	mov    %eax,%edx
80102ae1:	ec                   	in     (%dx),%al
80102ae2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ae5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ae9:	c9                   	leave
80102aea:	c3                   	ret

80102aeb <outb>:
{
80102aeb:	55                   	push   %ebp
80102aec:	89 e5                	mov    %esp,%ebp
80102aee:	83 ec 08             	sub    $0x8,%esp
80102af1:	8b 45 08             	mov    0x8(%ebp),%eax
80102af4:	8b 55 0c             	mov    0xc(%ebp),%edx
80102af7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102afb:	89 d0                	mov    %edx,%eax
80102afd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b00:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102b04:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102b08:	ee                   	out    %al,(%dx)
}
80102b09:	90                   	nop
80102b0a:	c9                   	leave
80102b0b:	c3                   	ret

80102b0c <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102b0c:	f3 0f 1e fb          	endbr32
80102b10:	55                   	push   %ebp
80102b11:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102b13:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b18:	8b 55 08             	mov    0x8(%ebp),%edx
80102b1b:	c1 e2 02             	shl    $0x2,%edx
80102b1e:	01 c2                	add    %eax,%edx
80102b20:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b23:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102b25:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b2a:	83 c0 20             	add    $0x20,%eax
80102b2d:	8b 00                	mov    (%eax),%eax
}
80102b2f:	90                   	nop
80102b30:	5d                   	pop    %ebp
80102b31:	c3                   	ret

80102b32 <lapicinit>:

void
lapicinit(void)
{
80102b32:	f3 0f 1e fb          	endbr32
80102b36:	55                   	push   %ebp
80102b37:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102b39:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b3e:	85 c0                	test   %eax,%eax
80102b40:	0f 84 0c 01 00 00    	je     80102c52 <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102b46:	68 3f 01 00 00       	push   $0x13f
80102b4b:	6a 3c                	push   $0x3c
80102b4d:	e8 ba ff ff ff       	call   80102b0c <lapicw>
80102b52:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102b55:	6a 0b                	push   $0xb
80102b57:	68 f8 00 00 00       	push   $0xf8
80102b5c:	e8 ab ff ff ff       	call   80102b0c <lapicw>
80102b61:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102b64:	68 20 00 02 00       	push   $0x20020
80102b69:	68 c8 00 00 00       	push   $0xc8
80102b6e:	e8 99 ff ff ff       	call   80102b0c <lapicw>
80102b73:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102b76:	68 80 96 98 00       	push   $0x989680
80102b7b:	68 e0 00 00 00       	push   $0xe0
80102b80:	e8 87 ff ff ff       	call   80102b0c <lapicw>
80102b85:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102b88:	68 00 00 01 00       	push   $0x10000
80102b8d:	68 d4 00 00 00       	push   $0xd4
80102b92:	e8 75 ff ff ff       	call   80102b0c <lapicw>
80102b97:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102b9a:	68 00 00 01 00       	push   $0x10000
80102b9f:	68 d8 00 00 00       	push   $0xd8
80102ba4:	e8 63 ff ff ff       	call   80102b0c <lapicw>
80102ba9:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102bac:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102bb1:	83 c0 30             	add    $0x30,%eax
80102bb4:	8b 00                	mov    (%eax),%eax
80102bb6:	c1 e8 10             	shr    $0x10,%eax
80102bb9:	25 fc 00 00 00       	and    $0xfc,%eax
80102bbe:	85 c0                	test   %eax,%eax
80102bc0:	74 12                	je     80102bd4 <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80102bc2:	68 00 00 01 00       	push   $0x10000
80102bc7:	68 d0 00 00 00       	push   $0xd0
80102bcc:	e8 3b ff ff ff       	call   80102b0c <lapicw>
80102bd1:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102bd4:	6a 33                	push   $0x33
80102bd6:	68 dc 00 00 00       	push   $0xdc
80102bdb:	e8 2c ff ff ff       	call   80102b0c <lapicw>
80102be0:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102be3:	6a 00                	push   $0x0
80102be5:	68 a0 00 00 00       	push   $0xa0
80102bea:	e8 1d ff ff ff       	call   80102b0c <lapicw>
80102bef:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102bf2:	6a 00                	push   $0x0
80102bf4:	68 a0 00 00 00       	push   $0xa0
80102bf9:	e8 0e ff ff ff       	call   80102b0c <lapicw>
80102bfe:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102c01:	6a 00                	push   $0x0
80102c03:	6a 2c                	push   $0x2c
80102c05:	e8 02 ff ff ff       	call   80102b0c <lapicw>
80102c0a:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102c0d:	6a 00                	push   $0x0
80102c0f:	68 c4 00 00 00       	push   $0xc4
80102c14:	e8 f3 fe ff ff       	call   80102b0c <lapicw>
80102c19:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102c1c:	68 00 85 08 00       	push   $0x88500
80102c21:	68 c0 00 00 00       	push   $0xc0
80102c26:	e8 e1 fe ff ff       	call   80102b0c <lapicw>
80102c2b:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102c2e:	90                   	nop
80102c2f:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c34:	05 00 03 00 00       	add    $0x300,%eax
80102c39:	8b 00                	mov    (%eax),%eax
80102c3b:	25 00 10 00 00       	and    $0x1000,%eax
80102c40:	85 c0                	test   %eax,%eax
80102c42:	75 eb                	jne    80102c2f <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102c44:	6a 00                	push   $0x0
80102c46:	6a 20                	push   $0x20
80102c48:	e8 bf fe ff ff       	call   80102b0c <lapicw>
80102c4d:	83 c4 08             	add    $0x8,%esp
80102c50:	eb 01                	jmp    80102c53 <lapicinit+0x121>
    return;
80102c52:	90                   	nop
}
80102c53:	c9                   	leave
80102c54:	c3                   	ret

80102c55 <lapicid>:

int
lapicid(void)
{
80102c55:	f3 0f 1e fb          	endbr32
80102c59:	55                   	push   %ebp
80102c5a:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102c5c:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c61:	85 c0                	test   %eax,%eax
80102c63:	75 07                	jne    80102c6c <lapicid+0x17>
    return 0;
80102c65:	b8 00 00 00 00       	mov    $0x0,%eax
80102c6a:	eb 0d                	jmp    80102c79 <lapicid+0x24>
  }
  return lapic[ID] >> 24;
80102c6c:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c71:	83 c0 20             	add    $0x20,%eax
80102c74:	8b 00                	mov    (%eax),%eax
80102c76:	c1 e8 18             	shr    $0x18,%eax
}
80102c79:	5d                   	pop    %ebp
80102c7a:	c3                   	ret

80102c7b <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102c7b:	f3 0f 1e fb          	endbr32
80102c7f:	55                   	push   %ebp
80102c80:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102c82:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c87:	85 c0                	test   %eax,%eax
80102c89:	74 0c                	je     80102c97 <lapiceoi+0x1c>
    lapicw(EOI, 0);
80102c8b:	6a 00                	push   $0x0
80102c8d:	6a 2c                	push   $0x2c
80102c8f:	e8 78 fe ff ff       	call   80102b0c <lapicw>
80102c94:	83 c4 08             	add    $0x8,%esp
}
80102c97:	90                   	nop
80102c98:	c9                   	leave
80102c99:	c3                   	ret

80102c9a <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102c9a:	f3 0f 1e fb          	endbr32
80102c9e:	55                   	push   %ebp
80102c9f:	89 e5                	mov    %esp,%ebp
}
80102ca1:	90                   	nop
80102ca2:	5d                   	pop    %ebp
80102ca3:	c3                   	ret

80102ca4 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102ca4:	f3 0f 1e fb          	endbr32
80102ca8:	55                   	push   %ebp
80102ca9:	89 e5                	mov    %esp,%ebp
80102cab:	83 ec 14             	sub    $0x14,%esp
80102cae:	8b 45 08             	mov    0x8(%ebp),%eax
80102cb1:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102cb4:	6a 0f                	push   $0xf
80102cb6:	6a 70                	push   $0x70
80102cb8:	e8 2e fe ff ff       	call   80102aeb <outb>
80102cbd:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102cc0:	6a 0a                	push   $0xa
80102cc2:	6a 71                	push   $0x71
80102cc4:	e8 22 fe ff ff       	call   80102aeb <outb>
80102cc9:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102ccc:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102cd3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102cd6:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102cdb:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cde:	c1 e8 04             	shr    $0x4,%eax
80102ce1:	89 c2                	mov    %eax,%edx
80102ce3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102ce6:	83 c0 02             	add    $0x2,%eax
80102ce9:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102cec:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102cf0:	c1 e0 18             	shl    $0x18,%eax
80102cf3:	50                   	push   %eax
80102cf4:	68 c4 00 00 00       	push   $0xc4
80102cf9:	e8 0e fe ff ff       	call   80102b0c <lapicw>
80102cfe:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102d01:	68 00 c5 00 00       	push   $0xc500
80102d06:	68 c0 00 00 00       	push   $0xc0
80102d0b:	e8 fc fd ff ff       	call   80102b0c <lapicw>
80102d10:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102d13:	68 c8 00 00 00       	push   $0xc8
80102d18:	e8 7d ff ff ff       	call   80102c9a <microdelay>
80102d1d:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102d20:	68 00 85 00 00       	push   $0x8500
80102d25:	68 c0 00 00 00       	push   $0xc0
80102d2a:	e8 dd fd ff ff       	call   80102b0c <lapicw>
80102d2f:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102d32:	6a 64                	push   $0x64
80102d34:	e8 61 ff ff ff       	call   80102c9a <microdelay>
80102d39:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102d3c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102d43:	eb 3d                	jmp    80102d82 <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
80102d45:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102d49:	c1 e0 18             	shl    $0x18,%eax
80102d4c:	50                   	push   %eax
80102d4d:	68 c4 00 00 00       	push   $0xc4
80102d52:	e8 b5 fd ff ff       	call   80102b0c <lapicw>
80102d57:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d5d:	c1 e8 0c             	shr    $0xc,%eax
80102d60:	80 cc 06             	or     $0x6,%ah
80102d63:	50                   	push   %eax
80102d64:	68 c0 00 00 00       	push   $0xc0
80102d69:	e8 9e fd ff ff       	call   80102b0c <lapicw>
80102d6e:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102d71:	68 c8 00 00 00       	push   $0xc8
80102d76:	e8 1f ff ff ff       	call   80102c9a <microdelay>
80102d7b:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102d7e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102d82:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102d86:	7e bd                	jle    80102d45 <lapicstartap+0xa1>
  }
}
80102d88:	90                   	nop
80102d89:	90                   	nop
80102d8a:	c9                   	leave
80102d8b:	c3                   	ret

80102d8c <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102d8c:	f3 0f 1e fb          	endbr32
80102d90:	55                   	push   %ebp
80102d91:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102d93:	8b 45 08             	mov    0x8(%ebp),%eax
80102d96:	0f b6 c0             	movzbl %al,%eax
80102d99:	50                   	push   %eax
80102d9a:	6a 70                	push   $0x70
80102d9c:	e8 4a fd ff ff       	call   80102aeb <outb>
80102da1:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102da4:	68 c8 00 00 00       	push   $0xc8
80102da9:	e8 ec fe ff ff       	call   80102c9a <microdelay>
80102dae:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102db1:	6a 71                	push   $0x71
80102db3:	e8 16 fd ff ff       	call   80102ace <inb>
80102db8:	83 c4 04             	add    $0x4,%esp
80102dbb:	0f b6 c0             	movzbl %al,%eax
}
80102dbe:	c9                   	leave
80102dbf:	c3                   	ret

80102dc0 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102dc0:	f3 0f 1e fb          	endbr32
80102dc4:	55                   	push   %ebp
80102dc5:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102dc7:	6a 00                	push   $0x0
80102dc9:	e8 be ff ff ff       	call   80102d8c <cmos_read>
80102dce:	83 c4 04             	add    $0x4,%esp
80102dd1:	8b 55 08             	mov    0x8(%ebp),%edx
80102dd4:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102dd6:	6a 02                	push   $0x2
80102dd8:	e8 af ff ff ff       	call   80102d8c <cmos_read>
80102ddd:	83 c4 04             	add    $0x4,%esp
80102de0:	8b 55 08             	mov    0x8(%ebp),%edx
80102de3:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102de6:	6a 04                	push   $0x4
80102de8:	e8 9f ff ff ff       	call   80102d8c <cmos_read>
80102ded:	83 c4 04             	add    $0x4,%esp
80102df0:	8b 55 08             	mov    0x8(%ebp),%edx
80102df3:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102df6:	6a 07                	push   $0x7
80102df8:	e8 8f ff ff ff       	call   80102d8c <cmos_read>
80102dfd:	83 c4 04             	add    $0x4,%esp
80102e00:	8b 55 08             	mov    0x8(%ebp),%edx
80102e03:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102e06:	6a 08                	push   $0x8
80102e08:	e8 7f ff ff ff       	call   80102d8c <cmos_read>
80102e0d:	83 c4 04             	add    $0x4,%esp
80102e10:	8b 55 08             	mov    0x8(%ebp),%edx
80102e13:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102e16:	6a 09                	push   $0x9
80102e18:	e8 6f ff ff ff       	call   80102d8c <cmos_read>
80102e1d:	83 c4 04             	add    $0x4,%esp
80102e20:	8b 55 08             	mov    0x8(%ebp),%edx
80102e23:	89 42 14             	mov    %eax,0x14(%edx)
}
80102e26:	90                   	nop
80102e27:	c9                   	leave
80102e28:	c3                   	ret

80102e29 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102e29:	f3 0f 1e fb          	endbr32
80102e2d:	55                   	push   %ebp
80102e2e:	89 e5                	mov    %esp,%ebp
80102e30:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102e33:	6a 0b                	push   $0xb
80102e35:	e8 52 ff ff ff       	call   80102d8c <cmos_read>
80102e3a:	83 c4 04             	add    $0x4,%esp
80102e3d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e43:	83 e0 04             	and    $0x4,%eax
80102e46:	85 c0                	test   %eax,%eax
80102e48:	0f 94 c0             	sete   %al
80102e4b:	0f b6 c0             	movzbl %al,%eax
80102e4e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102e51:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e54:	50                   	push   %eax
80102e55:	e8 66 ff ff ff       	call   80102dc0 <fill_rtcdate>
80102e5a:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102e5d:	6a 0a                	push   $0xa
80102e5f:	e8 28 ff ff ff       	call   80102d8c <cmos_read>
80102e64:	83 c4 04             	add    $0x4,%esp
80102e67:	25 80 00 00 00       	and    $0x80,%eax
80102e6c:	85 c0                	test   %eax,%eax
80102e6e:	75 27                	jne    80102e97 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80102e70:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e73:	50                   	push   %eax
80102e74:	e8 47 ff ff ff       	call   80102dc0 <fill_rtcdate>
80102e79:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102e7c:	83 ec 04             	sub    $0x4,%esp
80102e7f:	6a 18                	push   $0x18
80102e81:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e84:	50                   	push   %eax
80102e85:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e88:	50                   	push   %eax
80102e89:	e8 48 1f 00 00       	call   80104dd6 <memcmp>
80102e8e:	83 c4 10             	add    $0x10,%esp
80102e91:	85 c0                	test   %eax,%eax
80102e93:	74 05                	je     80102e9a <cmostime+0x71>
80102e95:	eb ba                	jmp    80102e51 <cmostime+0x28>
        continue;
80102e97:	90                   	nop
    fill_rtcdate(&t1);
80102e98:	eb b7                	jmp    80102e51 <cmostime+0x28>
      break;
80102e9a:	90                   	nop
  }

  // convert
  if(bcd) {
80102e9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102e9f:	0f 84 b4 00 00 00    	je     80102f59 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102ea5:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102ea8:	c1 e8 04             	shr    $0x4,%eax
80102eab:	89 c2                	mov    %eax,%edx
80102ead:	89 d0                	mov    %edx,%eax
80102eaf:	c1 e0 02             	shl    $0x2,%eax
80102eb2:	01 d0                	add    %edx,%eax
80102eb4:	01 c0                	add    %eax,%eax
80102eb6:	89 c2                	mov    %eax,%edx
80102eb8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102ebb:	83 e0 0f             	and    $0xf,%eax
80102ebe:	01 d0                	add    %edx,%eax
80102ec0:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102ec3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102ec6:	c1 e8 04             	shr    $0x4,%eax
80102ec9:	89 c2                	mov    %eax,%edx
80102ecb:	89 d0                	mov    %edx,%eax
80102ecd:	c1 e0 02             	shl    $0x2,%eax
80102ed0:	01 d0                	add    %edx,%eax
80102ed2:	01 c0                	add    %eax,%eax
80102ed4:	89 c2                	mov    %eax,%edx
80102ed6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102ed9:	83 e0 0f             	and    $0xf,%eax
80102edc:	01 d0                	add    %edx,%eax
80102ede:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102ee1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102ee4:	c1 e8 04             	shr    $0x4,%eax
80102ee7:	89 c2                	mov    %eax,%edx
80102ee9:	89 d0                	mov    %edx,%eax
80102eeb:	c1 e0 02             	shl    $0x2,%eax
80102eee:	01 d0                	add    %edx,%eax
80102ef0:	01 c0                	add    %eax,%eax
80102ef2:	89 c2                	mov    %eax,%edx
80102ef4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102ef7:	83 e0 0f             	and    $0xf,%eax
80102efa:	01 d0                	add    %edx,%eax
80102efc:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102eff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102f02:	c1 e8 04             	shr    $0x4,%eax
80102f05:	89 c2                	mov    %eax,%edx
80102f07:	89 d0                	mov    %edx,%eax
80102f09:	c1 e0 02             	shl    $0x2,%eax
80102f0c:	01 d0                	add    %edx,%eax
80102f0e:	01 c0                	add    %eax,%eax
80102f10:	89 c2                	mov    %eax,%edx
80102f12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102f15:	83 e0 0f             	and    $0xf,%eax
80102f18:	01 d0                	add    %edx,%eax
80102f1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102f1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f20:	c1 e8 04             	shr    $0x4,%eax
80102f23:	89 c2                	mov    %eax,%edx
80102f25:	89 d0                	mov    %edx,%eax
80102f27:	c1 e0 02             	shl    $0x2,%eax
80102f2a:	01 d0                	add    %edx,%eax
80102f2c:	01 c0                	add    %eax,%eax
80102f2e:	89 c2                	mov    %eax,%edx
80102f30:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f33:	83 e0 0f             	and    $0xf,%eax
80102f36:	01 d0                	add    %edx,%eax
80102f38:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102f3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f3e:	c1 e8 04             	shr    $0x4,%eax
80102f41:	89 c2                	mov    %eax,%edx
80102f43:	89 d0                	mov    %edx,%eax
80102f45:	c1 e0 02             	shl    $0x2,%eax
80102f48:	01 d0                	add    %edx,%eax
80102f4a:	01 c0                	add    %eax,%eax
80102f4c:	89 c2                	mov    %eax,%edx
80102f4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f51:	83 e0 0f             	and    $0xf,%eax
80102f54:	01 d0                	add    %edx,%eax
80102f56:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102f59:	8b 45 08             	mov    0x8(%ebp),%eax
80102f5c:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102f5f:	89 10                	mov    %edx,(%eax)
80102f61:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102f64:	89 50 04             	mov    %edx,0x4(%eax)
80102f67:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102f6a:	89 50 08             	mov    %edx,0x8(%eax)
80102f6d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102f70:	89 50 0c             	mov    %edx,0xc(%eax)
80102f73:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102f76:	89 50 10             	mov    %edx,0x10(%eax)
80102f79:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102f7c:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80102f82:	8b 40 14             	mov    0x14(%eax),%eax
80102f85:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80102f8e:	89 50 14             	mov    %edx,0x14(%eax)
}
80102f91:	90                   	nop
80102f92:	c9                   	leave
80102f93:	c3                   	ret

80102f94 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102f94:	f3 0f 1e fb          	endbr32
80102f98:	55                   	push   %ebp
80102f99:	89 e5                	mov    %esp,%ebp
80102f9b:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102f9e:	83 ec 08             	sub    $0x8,%esp
80102fa1:	68 11 a9 10 80       	push   $0x8010a911
80102fa6:	68 20 54 19 80       	push   $0x80195420
80102fab:	e8 06 1b 00 00       	call   80104ab6 <initlock>
80102fb0:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102fb3:	83 ec 08             	sub    $0x8,%esp
80102fb6:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102fb9:	50                   	push   %eax
80102fba:	ff 75 08             	push   0x8(%ebp)
80102fbd:	e8 c0 e4 ff ff       	call   80101482 <readsb>
80102fc2:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102fc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fc8:	a3 54 54 19 80       	mov    %eax,0x80195454
  log.size = sb.nlog;
80102fcd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102fd0:	a3 58 54 19 80       	mov    %eax,0x80195458
  log.dev = dev;
80102fd5:	8b 45 08             	mov    0x8(%ebp),%eax
80102fd8:	a3 64 54 19 80       	mov    %eax,0x80195464
  recover_from_log();
80102fdd:	e8 bf 01 00 00       	call   801031a1 <recover_from_log>
}
80102fe2:	90                   	nop
80102fe3:	c9                   	leave
80102fe4:	c3                   	ret

80102fe5 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102fe5:	f3 0f 1e fb          	endbr32
80102fe9:	55                   	push   %ebp
80102fea:	89 e5                	mov    %esp,%ebp
80102fec:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102fef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ff6:	e9 95 00 00 00       	jmp    80103090 <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102ffb:	8b 15 54 54 19 80    	mov    0x80195454,%edx
80103001:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103004:	01 d0                	add    %edx,%eax
80103006:	83 c0 01             	add    $0x1,%eax
80103009:	89 c2                	mov    %eax,%edx
8010300b:	a1 64 54 19 80       	mov    0x80195464,%eax
80103010:	83 ec 08             	sub    $0x8,%esp
80103013:	52                   	push   %edx
80103014:	50                   	push   %eax
80103015:	e8 ef d1 ff ff       	call   80100209 <bread>
8010301a:	83 c4 10             	add    $0x10,%esp
8010301d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103023:	83 c0 10             	add    $0x10,%eax
80103026:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
8010302d:	89 c2                	mov    %eax,%edx
8010302f:	a1 64 54 19 80       	mov    0x80195464,%eax
80103034:	83 ec 08             	sub    $0x8,%esp
80103037:	52                   	push   %edx
80103038:	50                   	push   %eax
80103039:	e8 cb d1 ff ff       	call   80100209 <bread>
8010303e:	83 c4 10             	add    $0x10,%esp
80103041:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103044:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103047:	8d 50 5c             	lea    0x5c(%eax),%edx
8010304a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010304d:	83 c0 5c             	add    $0x5c,%eax
80103050:	83 ec 04             	sub    $0x4,%esp
80103053:	68 00 02 00 00       	push   $0x200
80103058:	52                   	push   %edx
80103059:	50                   	push   %eax
8010305a:	e8 d3 1d 00 00       	call   80104e32 <memmove>
8010305f:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103062:	83 ec 0c             	sub    $0xc,%esp
80103065:	ff 75 ec             	push   -0x14(%ebp)
80103068:	e8 d9 d1 ff ff       	call   80100246 <bwrite>
8010306d:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80103070:	83 ec 0c             	sub    $0xc,%esp
80103073:	ff 75 f0             	push   -0x10(%ebp)
80103076:	e8 18 d2 ff ff       	call   80100293 <brelse>
8010307b:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010307e:	83 ec 0c             	sub    $0xc,%esp
80103081:	ff 75 ec             	push   -0x14(%ebp)
80103084:	e8 0a d2 ff ff       	call   80100293 <brelse>
80103089:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010308c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103090:	a1 68 54 19 80       	mov    0x80195468,%eax
80103095:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103098:	0f 8c 5d ff ff ff    	jl     80102ffb <install_trans+0x16>
  }
}
8010309e:	90                   	nop
8010309f:	90                   	nop
801030a0:	c9                   	leave
801030a1:	c3                   	ret

801030a2 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801030a2:	f3 0f 1e fb          	endbr32
801030a6:	55                   	push   %ebp
801030a7:	89 e5                	mov    %esp,%ebp
801030a9:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801030ac:	a1 54 54 19 80       	mov    0x80195454,%eax
801030b1:	89 c2                	mov    %eax,%edx
801030b3:	a1 64 54 19 80       	mov    0x80195464,%eax
801030b8:	83 ec 08             	sub    $0x8,%esp
801030bb:	52                   	push   %edx
801030bc:	50                   	push   %eax
801030bd:	e8 47 d1 ff ff       	call   80100209 <bread>
801030c2:	83 c4 10             	add    $0x10,%esp
801030c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801030c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030cb:	83 c0 5c             	add    $0x5c,%eax
801030ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801030d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030d4:	8b 00                	mov    (%eax),%eax
801030d6:	a3 68 54 19 80       	mov    %eax,0x80195468
  for (i = 0; i < log.lh.n; i++) {
801030db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801030e2:	eb 1b                	jmp    801030ff <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
801030e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801030ea:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801030ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801030f1:	83 c2 10             	add    $0x10,%edx
801030f4:	89 04 95 2c 54 19 80 	mov    %eax,-0x7fe6abd4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801030fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801030ff:	a1 68 54 19 80       	mov    0x80195468,%eax
80103104:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103107:	7c db                	jl     801030e4 <read_head+0x42>
  }
  brelse(buf);
80103109:	83 ec 0c             	sub    $0xc,%esp
8010310c:	ff 75 f0             	push   -0x10(%ebp)
8010310f:	e8 7f d1 ff ff       	call   80100293 <brelse>
80103114:	83 c4 10             	add    $0x10,%esp
}
80103117:	90                   	nop
80103118:	c9                   	leave
80103119:	c3                   	ret

8010311a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010311a:	f3 0f 1e fb          	endbr32
8010311e:	55                   	push   %ebp
8010311f:	89 e5                	mov    %esp,%ebp
80103121:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103124:	a1 54 54 19 80       	mov    0x80195454,%eax
80103129:	89 c2                	mov    %eax,%edx
8010312b:	a1 64 54 19 80       	mov    0x80195464,%eax
80103130:	83 ec 08             	sub    $0x8,%esp
80103133:	52                   	push   %edx
80103134:	50                   	push   %eax
80103135:	e8 cf d0 ff ff       	call   80100209 <bread>
8010313a:	83 c4 10             	add    $0x10,%esp
8010313d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103140:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103143:	83 c0 5c             	add    $0x5c,%eax
80103146:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103149:	8b 15 68 54 19 80    	mov    0x80195468,%edx
8010314f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103152:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103154:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010315b:	eb 1b                	jmp    80103178 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
8010315d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103160:	83 c0 10             	add    $0x10,%eax
80103163:	8b 0c 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%ecx
8010316a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010316d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103170:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103174:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103178:	a1 68 54 19 80       	mov    0x80195468,%eax
8010317d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103180:	7c db                	jl     8010315d <write_head+0x43>
  }
  bwrite(buf);
80103182:	83 ec 0c             	sub    $0xc,%esp
80103185:	ff 75 f0             	push   -0x10(%ebp)
80103188:	e8 b9 d0 ff ff       	call   80100246 <bwrite>
8010318d:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103190:	83 ec 0c             	sub    $0xc,%esp
80103193:	ff 75 f0             	push   -0x10(%ebp)
80103196:	e8 f8 d0 ff ff       	call   80100293 <brelse>
8010319b:	83 c4 10             	add    $0x10,%esp
}
8010319e:	90                   	nop
8010319f:	c9                   	leave
801031a0:	c3                   	ret

801031a1 <recover_from_log>:

static void
recover_from_log(void)
{
801031a1:	f3 0f 1e fb          	endbr32
801031a5:	55                   	push   %ebp
801031a6:	89 e5                	mov    %esp,%ebp
801031a8:	83 ec 08             	sub    $0x8,%esp
  read_head();
801031ab:	e8 f2 fe ff ff       	call   801030a2 <read_head>
  install_trans(); // if committed, copy from log to disk
801031b0:	e8 30 fe ff ff       	call   80102fe5 <install_trans>
  log.lh.n = 0;
801031b5:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
801031bc:	00 00 00 
  write_head(); // clear the log
801031bf:	e8 56 ff ff ff       	call   8010311a <write_head>
}
801031c4:	90                   	nop
801031c5:	c9                   	leave
801031c6:	c3                   	ret

801031c7 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801031c7:	f3 0f 1e fb          	endbr32
801031cb:	55                   	push   %ebp
801031cc:	89 e5                	mov    %esp,%ebp
801031ce:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801031d1:	83 ec 0c             	sub    $0xc,%esp
801031d4:	68 20 54 19 80       	push   $0x80195420
801031d9:	e8 fe 18 00 00       	call   80104adc <acquire>
801031de:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801031e1:	a1 60 54 19 80       	mov    0x80195460,%eax
801031e6:	85 c0                	test   %eax,%eax
801031e8:	74 17                	je     80103201 <begin_op+0x3a>
      sleep(&log, &log.lock);
801031ea:	83 ec 08             	sub    $0x8,%esp
801031ed:	68 20 54 19 80       	push   $0x80195420
801031f2:	68 20 54 19 80       	push   $0x80195420
801031f7:	e8 67 13 00 00       	call   80104563 <sleep>
801031fc:	83 c4 10             	add    $0x10,%esp
801031ff:	eb e0                	jmp    801031e1 <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103201:	8b 0d 68 54 19 80    	mov    0x80195468,%ecx
80103207:	a1 5c 54 19 80       	mov    0x8019545c,%eax
8010320c:	8d 50 01             	lea    0x1(%eax),%edx
8010320f:	89 d0                	mov    %edx,%eax
80103211:	c1 e0 02             	shl    $0x2,%eax
80103214:	01 d0                	add    %edx,%eax
80103216:	01 c0                	add    %eax,%eax
80103218:	01 c8                	add    %ecx,%eax
8010321a:	83 f8 1e             	cmp    $0x1e,%eax
8010321d:	7e 17                	jle    80103236 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010321f:	83 ec 08             	sub    $0x8,%esp
80103222:	68 20 54 19 80       	push   $0x80195420
80103227:	68 20 54 19 80       	push   $0x80195420
8010322c:	e8 32 13 00 00       	call   80104563 <sleep>
80103231:	83 c4 10             	add    $0x10,%esp
80103234:	eb ab                	jmp    801031e1 <begin_op+0x1a>
    } else {
      log.outstanding += 1;
80103236:	a1 5c 54 19 80       	mov    0x8019545c,%eax
8010323b:	83 c0 01             	add    $0x1,%eax
8010323e:	a3 5c 54 19 80       	mov    %eax,0x8019545c
      release(&log.lock);
80103243:	83 ec 0c             	sub    $0xc,%esp
80103246:	68 20 54 19 80       	push   $0x80195420
8010324b:	e8 fe 18 00 00       	call   80104b4e <release>
80103250:	83 c4 10             	add    $0x10,%esp
      break;
80103253:	90                   	nop
    }
  }
}
80103254:	90                   	nop
80103255:	c9                   	leave
80103256:	c3                   	ret

80103257 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103257:	f3 0f 1e fb          	endbr32
8010325b:	55                   	push   %ebp
8010325c:	89 e5                	mov    %esp,%ebp
8010325e:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103261:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103268:	83 ec 0c             	sub    $0xc,%esp
8010326b:	68 20 54 19 80       	push   $0x80195420
80103270:	e8 67 18 00 00       	call   80104adc <acquire>
80103275:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103278:	a1 5c 54 19 80       	mov    0x8019545c,%eax
8010327d:	83 e8 01             	sub    $0x1,%eax
80103280:	a3 5c 54 19 80       	mov    %eax,0x8019545c
  if(log.committing)
80103285:	a1 60 54 19 80       	mov    0x80195460,%eax
8010328a:	85 c0                	test   %eax,%eax
8010328c:	74 0d                	je     8010329b <end_op+0x44>
    panic("log.committing");
8010328e:	83 ec 0c             	sub    $0xc,%esp
80103291:	68 15 a9 10 80       	push   $0x8010a915
80103296:	e8 43 d3 ff ff       	call   801005de <panic>
  if(log.outstanding == 0){
8010329b:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801032a0:	85 c0                	test   %eax,%eax
801032a2:	75 13                	jne    801032b7 <end_op+0x60>
    do_commit = 1;
801032a4:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801032ab:	c7 05 60 54 19 80 01 	movl   $0x1,0x80195460
801032b2:	00 00 00 
801032b5:	eb 10                	jmp    801032c7 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801032b7:	83 ec 0c             	sub    $0xc,%esp
801032ba:	68 20 54 19 80       	push   $0x80195420
801032bf:	e8 8e 13 00 00       	call   80104652 <wakeup>
801032c4:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801032c7:	83 ec 0c             	sub    $0xc,%esp
801032ca:	68 20 54 19 80       	push   $0x80195420
801032cf:	e8 7a 18 00 00       	call   80104b4e <release>
801032d4:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801032d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801032db:	74 3f                	je     8010331c <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801032dd:	e8 fa 00 00 00       	call   801033dc <commit>
    acquire(&log.lock);
801032e2:	83 ec 0c             	sub    $0xc,%esp
801032e5:	68 20 54 19 80       	push   $0x80195420
801032ea:	e8 ed 17 00 00       	call   80104adc <acquire>
801032ef:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
801032f2:	c7 05 60 54 19 80 00 	movl   $0x0,0x80195460
801032f9:	00 00 00 
    wakeup(&log);
801032fc:	83 ec 0c             	sub    $0xc,%esp
801032ff:	68 20 54 19 80       	push   $0x80195420
80103304:	e8 49 13 00 00       	call   80104652 <wakeup>
80103309:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010330c:	83 ec 0c             	sub    $0xc,%esp
8010330f:	68 20 54 19 80       	push   $0x80195420
80103314:	e8 35 18 00 00       	call   80104b4e <release>
80103319:	83 c4 10             	add    $0x10,%esp
  }
}
8010331c:	90                   	nop
8010331d:	c9                   	leave
8010331e:	c3                   	ret

8010331f <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010331f:	f3 0f 1e fb          	endbr32
80103323:	55                   	push   %ebp
80103324:	89 e5                	mov    %esp,%ebp
80103326:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103329:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103330:	e9 95 00 00 00       	jmp    801033ca <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103335:	8b 15 54 54 19 80    	mov    0x80195454,%edx
8010333b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010333e:	01 d0                	add    %edx,%eax
80103340:	83 c0 01             	add    $0x1,%eax
80103343:	89 c2                	mov    %eax,%edx
80103345:	a1 64 54 19 80       	mov    0x80195464,%eax
8010334a:	83 ec 08             	sub    $0x8,%esp
8010334d:	52                   	push   %edx
8010334e:	50                   	push   %eax
8010334f:	e8 b5 ce ff ff       	call   80100209 <bread>
80103354:	83 c4 10             	add    $0x10,%esp
80103357:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010335a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010335d:	83 c0 10             	add    $0x10,%eax
80103360:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103367:	89 c2                	mov    %eax,%edx
80103369:	a1 64 54 19 80       	mov    0x80195464,%eax
8010336e:	83 ec 08             	sub    $0x8,%esp
80103371:	52                   	push   %edx
80103372:	50                   	push   %eax
80103373:	e8 91 ce ff ff       	call   80100209 <bread>
80103378:	83 c4 10             	add    $0x10,%esp
8010337b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010337e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103381:	8d 50 5c             	lea    0x5c(%eax),%edx
80103384:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103387:	83 c0 5c             	add    $0x5c,%eax
8010338a:	83 ec 04             	sub    $0x4,%esp
8010338d:	68 00 02 00 00       	push   $0x200
80103392:	52                   	push   %edx
80103393:	50                   	push   %eax
80103394:	e8 99 1a 00 00       	call   80104e32 <memmove>
80103399:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
8010339c:	83 ec 0c             	sub    $0xc,%esp
8010339f:	ff 75 f0             	push   -0x10(%ebp)
801033a2:	e8 9f ce ff ff       	call   80100246 <bwrite>
801033a7:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801033aa:	83 ec 0c             	sub    $0xc,%esp
801033ad:	ff 75 ec             	push   -0x14(%ebp)
801033b0:	e8 de ce ff ff       	call   80100293 <brelse>
801033b5:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801033b8:	83 ec 0c             	sub    $0xc,%esp
801033bb:	ff 75 f0             	push   -0x10(%ebp)
801033be:	e8 d0 ce ff ff       	call   80100293 <brelse>
801033c3:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801033c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033ca:	a1 68 54 19 80       	mov    0x80195468,%eax
801033cf:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801033d2:	0f 8c 5d ff ff ff    	jl     80103335 <write_log+0x16>
  }
}
801033d8:	90                   	nop
801033d9:	90                   	nop
801033da:	c9                   	leave
801033db:	c3                   	ret

801033dc <commit>:

static void
commit()
{
801033dc:	f3 0f 1e fb          	endbr32
801033e0:	55                   	push   %ebp
801033e1:	89 e5                	mov    %esp,%ebp
801033e3:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801033e6:	a1 68 54 19 80       	mov    0x80195468,%eax
801033eb:	85 c0                	test   %eax,%eax
801033ed:	7e 1e                	jle    8010340d <commit+0x31>
    write_log();     // Write modified blocks from cache to log
801033ef:	e8 2b ff ff ff       	call   8010331f <write_log>
    write_head();    // Write header to disk -- the real commit
801033f4:	e8 21 fd ff ff       	call   8010311a <write_head>
    install_trans(); // Now install writes to home locations
801033f9:	e8 e7 fb ff ff       	call   80102fe5 <install_trans>
    log.lh.n = 0;
801033fe:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
80103405:	00 00 00 
    write_head();    // Erase the transaction from the log
80103408:	e8 0d fd ff ff       	call   8010311a <write_head>
  }
}
8010340d:	90                   	nop
8010340e:	c9                   	leave
8010340f:	c3                   	ret

80103410 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103410:	f3 0f 1e fb          	endbr32
80103414:	55                   	push   %ebp
80103415:	89 e5                	mov    %esp,%ebp
80103417:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010341a:	a1 68 54 19 80       	mov    0x80195468,%eax
8010341f:	83 f8 1d             	cmp    $0x1d,%eax
80103422:	7f 12                	jg     80103436 <log_write+0x26>
80103424:	a1 68 54 19 80       	mov    0x80195468,%eax
80103429:	8b 15 58 54 19 80    	mov    0x80195458,%edx
8010342f:	83 ea 01             	sub    $0x1,%edx
80103432:	39 d0                	cmp    %edx,%eax
80103434:	7c 0d                	jl     80103443 <log_write+0x33>
    panic("too big a transaction");
80103436:	83 ec 0c             	sub    $0xc,%esp
80103439:	68 24 a9 10 80       	push   $0x8010a924
8010343e:	e8 9b d1 ff ff       	call   801005de <panic>
  if (log.outstanding < 1)
80103443:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103448:	85 c0                	test   %eax,%eax
8010344a:	7f 0d                	jg     80103459 <log_write+0x49>
    panic("log_write outside of trans");
8010344c:	83 ec 0c             	sub    $0xc,%esp
8010344f:	68 3a a9 10 80       	push   $0x8010a93a
80103454:	e8 85 d1 ff ff       	call   801005de <panic>

  acquire(&log.lock);
80103459:	83 ec 0c             	sub    $0xc,%esp
8010345c:	68 20 54 19 80       	push   $0x80195420
80103461:	e8 76 16 00 00       	call   80104adc <acquire>
80103466:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103469:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103470:	eb 1d                	jmp    8010348f <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103472:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103475:	83 c0 10             	add    $0x10,%eax
80103478:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
8010347f:	89 c2                	mov    %eax,%edx
80103481:	8b 45 08             	mov    0x8(%ebp),%eax
80103484:	8b 40 08             	mov    0x8(%eax),%eax
80103487:	39 c2                	cmp    %eax,%edx
80103489:	74 10                	je     8010349b <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
8010348b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010348f:	a1 68 54 19 80       	mov    0x80195468,%eax
80103494:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103497:	7c d9                	jl     80103472 <log_write+0x62>
80103499:	eb 01                	jmp    8010349c <log_write+0x8c>
      break;
8010349b:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
8010349c:	8b 45 08             	mov    0x8(%ebp),%eax
8010349f:	8b 40 08             	mov    0x8(%eax),%eax
801034a2:	89 c2                	mov    %eax,%edx
801034a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034a7:	83 c0 10             	add    $0x10,%eax
801034aa:	89 14 85 2c 54 19 80 	mov    %edx,-0x7fe6abd4(,%eax,4)
  if (i == log.lh.n)
801034b1:	a1 68 54 19 80       	mov    0x80195468,%eax
801034b6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034b9:	75 0d                	jne    801034c8 <log_write+0xb8>
    log.lh.n++;
801034bb:	a1 68 54 19 80       	mov    0x80195468,%eax
801034c0:	83 c0 01             	add    $0x1,%eax
801034c3:	a3 68 54 19 80       	mov    %eax,0x80195468
  b->flags |= B_DIRTY; // prevent eviction
801034c8:	8b 45 08             	mov    0x8(%ebp),%eax
801034cb:	8b 00                	mov    (%eax),%eax
801034cd:	83 c8 04             	or     $0x4,%eax
801034d0:	89 c2                	mov    %eax,%edx
801034d2:	8b 45 08             	mov    0x8(%ebp),%eax
801034d5:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801034d7:	83 ec 0c             	sub    $0xc,%esp
801034da:	68 20 54 19 80       	push   $0x80195420
801034df:	e8 6a 16 00 00       	call   80104b4e <release>
801034e4:	83 c4 10             	add    $0x10,%esp
}
801034e7:	90                   	nop
801034e8:	c9                   	leave
801034e9:	c3                   	ret

801034ea <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801034ea:	55                   	push   %ebp
801034eb:	89 e5                	mov    %esp,%ebp
801034ed:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801034f0:	8b 55 08             	mov    0x8(%ebp),%edx
801034f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801034f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801034f9:	f0 87 02             	lock xchg %eax,(%edx)
801034fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801034ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103502:	c9                   	leave
80103503:	c3                   	ret

80103504 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103504:	f3 0f 1e fb          	endbr32
80103508:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010350c:	83 e4 f0             	and    $0xfffffff0,%esp
8010350f:	ff 71 fc             	push   -0x4(%ecx)
80103512:	55                   	push   %ebp
80103513:	89 e5                	mov    %esp,%ebp
80103515:	51                   	push   %ecx
80103516:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103519:	e8 18 4e 00 00       	call   80108336 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010351e:	83 ec 08             	sub    $0x8,%esp
80103521:	68 00 00 40 80       	push   $0x80400000
80103526:	68 00 90 19 80       	push   $0x80199000
8010352b:	e8 73 f2 ff ff       	call   801027a3 <kinit1>
80103530:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103533:	e8 9f 43 00 00       	call   801078d7 <kvmalloc>
  mpinit_uefi();
80103538:	e8 b2 4b 00 00       	call   801080ef <mpinit_uefi>
  lapicinit();     // interrupt controller
8010353d:	e8 f0 f5 ff ff       	call   80102b32 <lapicinit>
  seginit();       // segment descriptors
80103542:	e8 17 3e 00 00       	call   8010735e <seginit>
  picinit();    // disable pic
80103547:	e8 a9 01 00 00       	call   801036f5 <picinit>
  ioapicinit();    // another interrupt controller
8010354c:	e8 65 f1 ff ff       	call   801026b6 <ioapicinit>
  consoleinit();   // console hardware
80103551:	e8 fc d5 ff ff       	call   80100b52 <consoleinit>
  uartinit();      // serial port
80103556:	e8 8c 31 00 00       	call   801066e7 <uartinit>
  pinit();         // process table
8010355b:	e8 e2 05 00 00       	call   80103b42 <pinit>
  tvinit();        // trap vectors
80103560:	e8 b2 2c 00 00       	call   80106217 <tvinit>
  binit();         // buffer cache
80103565:	e8 fc ca ff ff       	call   80100066 <binit>
  fileinit();      // file table
8010356a:	e8 e8 da ff ff       	call   80101057 <fileinit>
  ideinit();       // disk 
8010356f:	e8 c7 6f 00 00       	call   8010a53b <ideinit>
  startothers();   // start other processors
80103574:	e8 92 00 00 00       	call   8010360b <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103579:	83 ec 08             	sub    $0x8,%esp
8010357c:	68 00 00 00 a0       	push   $0xa0000000
80103581:	68 00 00 40 80       	push   $0x80400000
80103586:	e8 55 f2 ff ff       	call   801027e0 <kinit2>
8010358b:	83 c4 10             	add    $0x10,%esp
  pci_init();
8010358e:	e8 16 50 00 00       	call   801085a9 <pci_init>
  arp_scan();
80103593:	e8 8f 5d 00 00       	call   80109327 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
80103598:	e8 ab 07 00 00       	call   80103d48 <userinit>
  mpmain();        // finish this processor's setup
8010359d:	e8 1e 00 00 00       	call   801035c0 <mpmain>

801035a2 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801035a2:	f3 0f 1e fb          	endbr32
801035a6:	55                   	push   %ebp
801035a7:	89 e5                	mov    %esp,%ebp
801035a9:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801035ac:	e8 42 43 00 00       	call   801078f3 <switchkvm>
  seginit();
801035b1:	e8 a8 3d 00 00       	call   8010735e <seginit>
  lapicinit();
801035b6:	e8 77 f5 ff ff       	call   80102b32 <lapicinit>
  mpmain();
801035bb:	e8 00 00 00 00       	call   801035c0 <mpmain>

801035c0 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801035c0:	f3 0f 1e fb          	endbr32
801035c4:	55                   	push   %ebp
801035c5:	89 e5                	mov    %esp,%ebp
801035c7:	53                   	push   %ebx
801035c8:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801035cb:	e8 94 05 00 00       	call   80103b64 <cpuid>
801035d0:	89 c3                	mov    %eax,%ebx
801035d2:	e8 8d 05 00 00       	call   80103b64 <cpuid>
801035d7:	83 ec 04             	sub    $0x4,%esp
801035da:	53                   	push   %ebx
801035db:	50                   	push   %eax
801035dc:	68 55 a9 10 80       	push   $0x8010a955
801035e1:	e8 26 ce ff ff       	call   8010040c <cprintf>
801035e6:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801035e9:	e8 a3 2d 00 00       	call   80106391 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801035ee:	e8 90 05 00 00       	call   80103b83 <mycpu>
801035f3:	05 a0 00 00 00       	add    $0xa0,%eax
801035f8:	83 ec 08             	sub    $0x8,%esp
801035fb:	6a 01                	push   $0x1
801035fd:	50                   	push   %eax
801035fe:	e8 e7 fe ff ff       	call   801034ea <xchg>
80103603:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103606:	e8 35 0d 00 00       	call   80104340 <scheduler>

8010360b <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010360b:	f3 0f 1e fb          	endbr32
8010360f:	55                   	push   %ebp
80103610:	89 e5                	mov    %esp,%ebp
80103612:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103615:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010361c:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103621:	83 ec 04             	sub    $0x4,%esp
80103624:	50                   	push   %eax
80103625:	68 18 f5 10 80       	push   $0x8010f518
8010362a:	ff 75 f0             	push   -0x10(%ebp)
8010362d:	e8 00 18 00 00       	call   80104e32 <memmove>
80103632:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103635:	c7 45 f4 c0 7d 19 80 	movl   $0x80197dc0,-0xc(%ebp)
8010363c:	eb 79                	jmp    801036b7 <startothers+0xac>
    if(c == mycpu()){  // We've started already.
8010363e:	e8 40 05 00 00       	call   80103b83 <mycpu>
80103643:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103646:	74 67                	je     801036af <startothers+0xa4>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103648:	e8 9b f2 ff ff       	call   801028e8 <kalloc>
8010364d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103650:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103653:	83 e8 04             	sub    $0x4,%eax
80103656:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103659:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010365f:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103661:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103664:	83 e8 08             	sub    $0x8,%eax
80103667:	c7 00 a2 35 10 80    	movl   $0x801035a2,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
8010366d:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
80103672:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103678:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010367b:	83 e8 0c             	sub    $0xc,%eax
8010367e:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103680:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103683:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103689:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010368c:	0f b6 00             	movzbl (%eax),%eax
8010368f:	0f b6 c0             	movzbl %al,%eax
80103692:	83 ec 08             	sub    $0x8,%esp
80103695:	52                   	push   %edx
80103696:	50                   	push   %eax
80103697:	e8 08 f6 ff ff       	call   80102ca4 <lapicstartap>
8010369c:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010369f:	90                   	nop
801036a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036a3:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801036a9:	85 c0                	test   %eax,%eax
801036ab:	74 f3                	je     801036a0 <startothers+0x95>
801036ad:	eb 01                	jmp    801036b0 <startothers+0xa5>
      continue;
801036af:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801036b0:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801036b7:	a1 80 80 19 80       	mov    0x80198080,%eax
801036bc:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801036c2:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
801036c7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801036ca:	0f 82 6e ff ff ff    	jb     8010363e <startothers+0x33>
      ;
  }
}
801036d0:	90                   	nop
801036d1:	90                   	nop
801036d2:	c9                   	leave
801036d3:	c3                   	ret

801036d4 <outb>:
{
801036d4:	55                   	push   %ebp
801036d5:	89 e5                	mov    %esp,%ebp
801036d7:	83 ec 08             	sub    $0x8,%esp
801036da:	8b 45 08             	mov    0x8(%ebp),%eax
801036dd:	8b 55 0c             	mov    0xc(%ebp),%edx
801036e0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801036e4:	89 d0                	mov    %edx,%eax
801036e6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801036e9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801036ed:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801036f1:	ee                   	out    %al,(%dx)
}
801036f2:	90                   	nop
801036f3:	c9                   	leave
801036f4:	c3                   	ret

801036f5 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
801036f5:	f3 0f 1e fb          	endbr32
801036f9:	55                   	push   %ebp
801036fa:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801036fc:	68 ff 00 00 00       	push   $0xff
80103701:	6a 21                	push   $0x21
80103703:	e8 cc ff ff ff       	call   801036d4 <outb>
80103708:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
8010370b:	68 ff 00 00 00       	push   $0xff
80103710:	68 a1 00 00 00       	push   $0xa1
80103715:	e8 ba ff ff ff       	call   801036d4 <outb>
8010371a:	83 c4 08             	add    $0x8,%esp
}
8010371d:	90                   	nop
8010371e:	c9                   	leave
8010371f:	c3                   	ret

80103720 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103720:	f3 0f 1e fb          	endbr32
80103724:	55                   	push   %ebp
80103725:	89 e5                	mov    %esp,%ebp
80103727:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010372a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103731:	8b 45 0c             	mov    0xc(%ebp),%eax
80103734:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010373a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010373d:	8b 10                	mov    (%eax),%edx
8010373f:	8b 45 08             	mov    0x8(%ebp),%eax
80103742:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103744:	e8 30 d9 ff ff       	call   80101079 <filealloc>
80103749:	8b 55 08             	mov    0x8(%ebp),%edx
8010374c:	89 02                	mov    %eax,(%edx)
8010374e:	8b 45 08             	mov    0x8(%ebp),%eax
80103751:	8b 00                	mov    (%eax),%eax
80103753:	85 c0                	test   %eax,%eax
80103755:	0f 84 c8 00 00 00    	je     80103823 <pipealloc+0x103>
8010375b:	e8 19 d9 ff ff       	call   80101079 <filealloc>
80103760:	8b 55 0c             	mov    0xc(%ebp),%edx
80103763:	89 02                	mov    %eax,(%edx)
80103765:	8b 45 0c             	mov    0xc(%ebp),%eax
80103768:	8b 00                	mov    (%eax),%eax
8010376a:	85 c0                	test   %eax,%eax
8010376c:	0f 84 b1 00 00 00    	je     80103823 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103772:	e8 71 f1 ff ff       	call   801028e8 <kalloc>
80103777:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010377a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010377e:	0f 84 a2 00 00 00    	je     80103826 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
80103784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103787:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010378e:	00 00 00 
  p->writeopen = 1;
80103791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103794:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010379b:	00 00 00 
  p->nwrite = 0;
8010379e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037a1:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801037a8:	00 00 00 
  p->nread = 0;
801037ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ae:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801037b5:	00 00 00 
  initlock(&p->lock, "pipe");
801037b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037bb:	83 ec 08             	sub    $0x8,%esp
801037be:	68 69 a9 10 80       	push   $0x8010a969
801037c3:	50                   	push   %eax
801037c4:	e8 ed 12 00 00       	call   80104ab6 <initlock>
801037c9:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801037cc:	8b 45 08             	mov    0x8(%ebp),%eax
801037cf:	8b 00                	mov    (%eax),%eax
801037d1:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801037d7:	8b 45 08             	mov    0x8(%ebp),%eax
801037da:	8b 00                	mov    (%eax),%eax
801037dc:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801037e0:	8b 45 08             	mov    0x8(%ebp),%eax
801037e3:	8b 00                	mov    (%eax),%eax
801037e5:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801037e9:	8b 45 08             	mov    0x8(%ebp),%eax
801037ec:	8b 00                	mov    (%eax),%eax
801037ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037f1:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801037f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801037f7:	8b 00                	mov    (%eax),%eax
801037f9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801037ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80103802:	8b 00                	mov    (%eax),%eax
80103804:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103808:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380b:	8b 00                	mov    (%eax),%eax
8010380d:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103811:	8b 45 0c             	mov    0xc(%ebp),%eax
80103814:	8b 00                	mov    (%eax),%eax
80103816:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103819:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010381c:	b8 00 00 00 00       	mov    $0x0,%eax
80103821:	eb 51                	jmp    80103874 <pipealloc+0x154>
    goto bad;
80103823:	90                   	nop
80103824:	eb 01                	jmp    80103827 <pipealloc+0x107>
    goto bad;
80103826:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103827:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010382b:	74 0e                	je     8010383b <pipealloc+0x11b>
    kfree((char*)p);
8010382d:	83 ec 0c             	sub    $0xc,%esp
80103830:	ff 75 f4             	push   -0xc(%ebp)
80103833:	e8 12 f0 ff ff       	call   8010284a <kfree>
80103838:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010383b:	8b 45 08             	mov    0x8(%ebp),%eax
8010383e:	8b 00                	mov    (%eax),%eax
80103840:	85 c0                	test   %eax,%eax
80103842:	74 11                	je     80103855 <pipealloc+0x135>
    fileclose(*f0);
80103844:	8b 45 08             	mov    0x8(%ebp),%eax
80103847:	8b 00                	mov    (%eax),%eax
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	50                   	push   %eax
8010384d:	e8 ed d8 ff ff       	call   8010113f <fileclose>
80103852:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103855:	8b 45 0c             	mov    0xc(%ebp),%eax
80103858:	8b 00                	mov    (%eax),%eax
8010385a:	85 c0                	test   %eax,%eax
8010385c:	74 11                	je     8010386f <pipealloc+0x14f>
    fileclose(*f1);
8010385e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103861:	8b 00                	mov    (%eax),%eax
80103863:	83 ec 0c             	sub    $0xc,%esp
80103866:	50                   	push   %eax
80103867:	e8 d3 d8 ff ff       	call   8010113f <fileclose>
8010386c:	83 c4 10             	add    $0x10,%esp
  return -1;
8010386f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103874:	c9                   	leave
80103875:	c3                   	ret

80103876 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103876:	f3 0f 1e fb          	endbr32
8010387a:	55                   	push   %ebp
8010387b:	89 e5                	mov    %esp,%ebp
8010387d:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103880:	8b 45 08             	mov    0x8(%ebp),%eax
80103883:	83 ec 0c             	sub    $0xc,%esp
80103886:	50                   	push   %eax
80103887:	e8 50 12 00 00       	call   80104adc <acquire>
8010388c:	83 c4 10             	add    $0x10,%esp
  if(writable){
8010388f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103893:	74 23                	je     801038b8 <pipeclose+0x42>
    p->writeopen = 0;
80103895:	8b 45 08             	mov    0x8(%ebp),%eax
80103898:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010389f:	00 00 00 
    wakeup(&p->nread);
801038a2:	8b 45 08             	mov    0x8(%ebp),%eax
801038a5:	05 34 02 00 00       	add    $0x234,%eax
801038aa:	83 ec 0c             	sub    $0xc,%esp
801038ad:	50                   	push   %eax
801038ae:	e8 9f 0d 00 00       	call   80104652 <wakeup>
801038b3:	83 c4 10             	add    $0x10,%esp
801038b6:	eb 21                	jmp    801038d9 <pipeclose+0x63>
  } else {
    p->readopen = 0;
801038b8:	8b 45 08             	mov    0x8(%ebp),%eax
801038bb:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801038c2:	00 00 00 
    wakeup(&p->nwrite);
801038c5:	8b 45 08             	mov    0x8(%ebp),%eax
801038c8:	05 38 02 00 00       	add    $0x238,%eax
801038cd:	83 ec 0c             	sub    $0xc,%esp
801038d0:	50                   	push   %eax
801038d1:	e8 7c 0d 00 00       	call   80104652 <wakeup>
801038d6:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801038d9:	8b 45 08             	mov    0x8(%ebp),%eax
801038dc:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801038e2:	85 c0                	test   %eax,%eax
801038e4:	75 2c                	jne    80103912 <pipeclose+0x9c>
801038e6:	8b 45 08             	mov    0x8(%ebp),%eax
801038e9:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038ef:	85 c0                	test   %eax,%eax
801038f1:	75 1f                	jne    80103912 <pipeclose+0x9c>
    release(&p->lock);
801038f3:	8b 45 08             	mov    0x8(%ebp),%eax
801038f6:	83 ec 0c             	sub    $0xc,%esp
801038f9:	50                   	push   %eax
801038fa:	e8 4f 12 00 00       	call   80104b4e <release>
801038ff:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103902:	83 ec 0c             	sub    $0xc,%esp
80103905:	ff 75 08             	push   0x8(%ebp)
80103908:	e8 3d ef ff ff       	call   8010284a <kfree>
8010390d:	83 c4 10             	add    $0x10,%esp
80103910:	eb 10                	jmp    80103922 <pipeclose+0xac>
  } else
    release(&p->lock);
80103912:	8b 45 08             	mov    0x8(%ebp),%eax
80103915:	83 ec 0c             	sub    $0xc,%esp
80103918:	50                   	push   %eax
80103919:	e8 30 12 00 00       	call   80104b4e <release>
8010391e:	83 c4 10             	add    $0x10,%esp
}
80103921:	90                   	nop
80103922:	90                   	nop
80103923:	c9                   	leave
80103924:	c3                   	ret

80103925 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103925:	f3 0f 1e fb          	endbr32
80103929:	55                   	push   %ebp
8010392a:	89 e5                	mov    %esp,%ebp
8010392c:	53                   	push   %ebx
8010392d:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103930:	8b 45 08             	mov    0x8(%ebp),%eax
80103933:	83 ec 0c             	sub    $0xc,%esp
80103936:	50                   	push   %eax
80103937:	e8 a0 11 00 00       	call   80104adc <acquire>
8010393c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
8010393f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103946:	e9 ad 00 00 00       	jmp    801039f8 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010394b:	8b 45 08             	mov    0x8(%ebp),%eax
8010394e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103954:	85 c0                	test   %eax,%eax
80103956:	74 0c                	je     80103964 <pipewrite+0x3f>
80103958:	e8 a2 02 00 00       	call   80103bff <myproc>
8010395d:	8b 40 24             	mov    0x24(%eax),%eax
80103960:	85 c0                	test   %eax,%eax
80103962:	74 19                	je     8010397d <pipewrite+0x58>
        release(&p->lock);
80103964:	8b 45 08             	mov    0x8(%ebp),%eax
80103967:	83 ec 0c             	sub    $0xc,%esp
8010396a:	50                   	push   %eax
8010396b:	e8 de 11 00 00       	call   80104b4e <release>
80103970:	83 c4 10             	add    $0x10,%esp
        return -1;
80103973:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103978:	e9 a9 00 00 00       	jmp    80103a26 <pipewrite+0x101>
      }
      wakeup(&p->nread);
8010397d:	8b 45 08             	mov    0x8(%ebp),%eax
80103980:	05 34 02 00 00       	add    $0x234,%eax
80103985:	83 ec 0c             	sub    $0xc,%esp
80103988:	50                   	push   %eax
80103989:	e8 c4 0c 00 00       	call   80104652 <wakeup>
8010398e:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103991:	8b 45 08             	mov    0x8(%ebp),%eax
80103994:	8b 55 08             	mov    0x8(%ebp),%edx
80103997:	81 c2 38 02 00 00    	add    $0x238,%edx
8010399d:	83 ec 08             	sub    $0x8,%esp
801039a0:	50                   	push   %eax
801039a1:	52                   	push   %edx
801039a2:	e8 bc 0b 00 00       	call   80104563 <sleep>
801039a7:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801039aa:	8b 45 08             	mov    0x8(%ebp),%eax
801039ad:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801039b3:	8b 45 08             	mov    0x8(%ebp),%eax
801039b6:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801039bc:	05 00 02 00 00       	add    $0x200,%eax
801039c1:	39 c2                	cmp    %eax,%edx
801039c3:	74 86                	je     8010394b <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801039c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801039c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801039cb:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801039ce:	8b 45 08             	mov    0x8(%ebp),%eax
801039d1:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801039d7:	8d 48 01             	lea    0x1(%eax),%ecx
801039da:	8b 55 08             	mov    0x8(%ebp),%edx
801039dd:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801039e3:	25 ff 01 00 00       	and    $0x1ff,%eax
801039e8:	89 c1                	mov    %eax,%ecx
801039ea:	0f b6 13             	movzbl (%ebx),%edx
801039ed:	8b 45 08             	mov    0x8(%ebp),%eax
801039f0:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
801039f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039fb:	3b 45 10             	cmp    0x10(%ebp),%eax
801039fe:	7c aa                	jl     801039aa <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103a00:	8b 45 08             	mov    0x8(%ebp),%eax
80103a03:	05 34 02 00 00       	add    $0x234,%eax
80103a08:	83 ec 0c             	sub    $0xc,%esp
80103a0b:	50                   	push   %eax
80103a0c:	e8 41 0c 00 00       	call   80104652 <wakeup>
80103a11:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103a14:	8b 45 08             	mov    0x8(%ebp),%eax
80103a17:	83 ec 0c             	sub    $0xc,%esp
80103a1a:	50                   	push   %eax
80103a1b:	e8 2e 11 00 00       	call   80104b4e <release>
80103a20:	83 c4 10             	add    $0x10,%esp
  return n;
80103a23:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103a26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a29:	c9                   	leave
80103a2a:	c3                   	ret

80103a2b <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103a2b:	f3 0f 1e fb          	endbr32
80103a2f:	55                   	push   %ebp
80103a30:	89 e5                	mov    %esp,%ebp
80103a32:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103a35:	8b 45 08             	mov    0x8(%ebp),%eax
80103a38:	83 ec 0c             	sub    $0xc,%esp
80103a3b:	50                   	push   %eax
80103a3c:	e8 9b 10 00 00       	call   80104adc <acquire>
80103a41:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a44:	eb 3e                	jmp    80103a84 <piperead+0x59>
    if(myproc()->killed){
80103a46:	e8 b4 01 00 00       	call   80103bff <myproc>
80103a4b:	8b 40 24             	mov    0x24(%eax),%eax
80103a4e:	85 c0                	test   %eax,%eax
80103a50:	74 19                	je     80103a6b <piperead+0x40>
      release(&p->lock);
80103a52:	8b 45 08             	mov    0x8(%ebp),%eax
80103a55:	83 ec 0c             	sub    $0xc,%esp
80103a58:	50                   	push   %eax
80103a59:	e8 f0 10 00 00       	call   80104b4e <release>
80103a5e:	83 c4 10             	add    $0x10,%esp
      return -1;
80103a61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a66:	e9 be 00 00 00       	jmp    80103b29 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a6e:	8b 55 08             	mov    0x8(%ebp),%edx
80103a71:	81 c2 34 02 00 00    	add    $0x234,%edx
80103a77:	83 ec 08             	sub    $0x8,%esp
80103a7a:	50                   	push   %eax
80103a7b:	52                   	push   %edx
80103a7c:	e8 e2 0a 00 00       	call   80104563 <sleep>
80103a81:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a84:	8b 45 08             	mov    0x8(%ebp),%eax
80103a87:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80103a90:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a96:	39 c2                	cmp    %eax,%edx
80103a98:	75 0d                	jne    80103aa7 <piperead+0x7c>
80103a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a9d:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103aa3:	85 c0                	test   %eax,%eax
80103aa5:	75 9f                	jne    80103a46 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103aa7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103aae:	eb 48                	jmp    80103af8 <piperead+0xcd>
    if(p->nread == p->nwrite)
80103ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab3:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103ab9:	8b 45 08             	mov    0x8(%ebp),%eax
80103abc:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103ac2:	39 c2                	cmp    %eax,%edx
80103ac4:	74 3c                	je     80103b02 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac9:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103acf:	8d 48 01             	lea    0x1(%eax),%ecx
80103ad2:	8b 55 08             	mov    0x8(%ebp),%edx
80103ad5:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103adb:	25 ff 01 00 00       	and    $0x1ff,%eax
80103ae0:	89 c1                	mov    %eax,%ecx
80103ae2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ae8:	01 c2                	add    %eax,%edx
80103aea:	8b 45 08             	mov    0x8(%ebp),%eax
80103aed:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103af2:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103af4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afb:	3b 45 10             	cmp    0x10(%ebp),%eax
80103afe:	7c b0                	jl     80103ab0 <piperead+0x85>
80103b00:	eb 01                	jmp    80103b03 <piperead+0xd8>
      break;
80103b02:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103b03:	8b 45 08             	mov    0x8(%ebp),%eax
80103b06:	05 38 02 00 00       	add    $0x238,%eax
80103b0b:	83 ec 0c             	sub    $0xc,%esp
80103b0e:	50                   	push   %eax
80103b0f:	e8 3e 0b 00 00       	call   80104652 <wakeup>
80103b14:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103b17:	8b 45 08             	mov    0x8(%ebp),%eax
80103b1a:	83 ec 0c             	sub    $0xc,%esp
80103b1d:	50                   	push   %eax
80103b1e:	e8 2b 10 00 00       	call   80104b4e <release>
80103b23:	83 c4 10             	add    $0x10,%esp
  return i;
80103b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b29:	c9                   	leave
80103b2a:	c3                   	ret

80103b2b <readeflags>:
{
80103b2b:	55                   	push   %ebp
80103b2c:	89 e5                	mov    %esp,%ebp
80103b2e:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103b31:	9c                   	pushf
80103b32:	58                   	pop    %eax
80103b33:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103b36:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103b39:	c9                   	leave
80103b3a:	c3                   	ret

80103b3b <sti>:
{
80103b3b:	55                   	push   %ebp
80103b3c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103b3e:	fb                   	sti
}
80103b3f:	90                   	nop
80103b40:	5d                   	pop    %ebp
80103b41:	c3                   	ret

80103b42 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103b42:	f3 0f 1e fb          	endbr32
80103b46:	55                   	push   %ebp
80103b47:	89 e5                	mov    %esp,%ebp
80103b49:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103b4c:	83 ec 08             	sub    $0x8,%esp
80103b4f:	68 70 a9 10 80       	push   $0x8010a970
80103b54:	68 00 55 19 80       	push   $0x80195500
80103b59:	e8 58 0f 00 00       	call   80104ab6 <initlock>
80103b5e:	83 c4 10             	add    $0x10,%esp
}
80103b61:	90                   	nop
80103b62:	c9                   	leave
80103b63:	c3                   	ret

80103b64 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103b64:	f3 0f 1e fb          	endbr32
80103b68:	55                   	push   %ebp
80103b69:	89 e5                	mov    %esp,%ebp
80103b6b:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103b6e:	e8 10 00 00 00       	call   80103b83 <mycpu>
80103b73:	2d c0 7d 19 80       	sub    $0x80197dc0,%eax
80103b78:	c1 f8 04             	sar    $0x4,%eax
80103b7b:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103b81:	c9                   	leave
80103b82:	c3                   	ret

80103b83 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103b83:	f3 0f 1e fb          	endbr32
80103b87:	55                   	push   %ebp
80103b88:	89 e5                	mov    %esp,%ebp
80103b8a:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103b8d:	e8 99 ff ff ff       	call   80103b2b <readeflags>
80103b92:	25 00 02 00 00       	and    $0x200,%eax
80103b97:	85 c0                	test   %eax,%eax
80103b99:	74 0d                	je     80103ba8 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80103b9b:	83 ec 0c             	sub    $0xc,%esp
80103b9e:	68 78 a9 10 80       	push   $0x8010a978
80103ba3:	e8 36 ca ff ff       	call   801005de <panic>
  }

  apicid = lapicid();
80103ba8:	e8 a8 f0 ff ff       	call   80102c55 <lapicid>
80103bad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103bb0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103bb7:	eb 2d                	jmp    80103be6 <mycpu+0x63>
    if (cpus[i].apicid == apicid){
80103bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbc:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103bc2:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103bc7:	0f b6 00             	movzbl (%eax),%eax
80103bca:	0f b6 c0             	movzbl %al,%eax
80103bcd:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103bd0:	75 10                	jne    80103be2 <mycpu+0x5f>
      return &cpus[i];
80103bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd5:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103bdb:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103be0:	eb 1b                	jmp    80103bfd <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80103be2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103be6:	a1 80 80 19 80       	mov    0x80198080,%eax
80103beb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103bee:	7c c9                	jl     80103bb9 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80103bf0:	83 ec 0c             	sub    $0xc,%esp
80103bf3:	68 9e a9 10 80       	push   $0x8010a99e
80103bf8:	e8 e1 c9 ff ff       	call   801005de <panic>
}
80103bfd:	c9                   	leave
80103bfe:	c3                   	ret

80103bff <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103bff:	f3 0f 1e fb          	endbr32
80103c03:	55                   	push   %ebp
80103c04:	89 e5                	mov    %esp,%ebp
80103c06:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103c09:	e8 4a 10 00 00       	call   80104c58 <pushcli>
  c = mycpu();
80103c0e:	e8 70 ff ff ff       	call   80103b83 <mycpu>
80103c13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c19:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103c1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103c22:	e8 82 10 00 00       	call   80104ca9 <popcli>
  return p;
80103c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c2a:	c9                   	leave
80103c2b:	c3                   	ret

80103c2c <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103c2c:	f3 0f 1e fb          	endbr32
80103c30:	55                   	push   %ebp
80103c31:	89 e5                	mov    %esp,%ebp
80103c33:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;
  cprintf("[allocproc] in\n");
80103c36:	83 ec 0c             	sub    $0xc,%esp
80103c39:	68 ae a9 10 80       	push   $0x8010a9ae
80103c3e:	e8 c9 c7 ff ff       	call   8010040c <cprintf>
80103c43:	83 c4 10             	add    $0x10,%esp
  acquire(&ptable.lock);
80103c46:	83 ec 0c             	sub    $0xc,%esp
80103c49:	68 00 55 19 80       	push   $0x80195500
80103c4e:	e8 89 0e 00 00       	call   80104adc <acquire>
80103c53:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c56:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80103c5d:	eb 0e                	jmp    80103c6d <allocproc+0x41>
    if(p->state == UNUSED){
80103c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c62:	8b 40 0c             	mov    0xc(%eax),%eax
80103c65:	85 c0                	test   %eax,%eax
80103c67:	74 27                	je     80103c90 <allocproc+0x64>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c69:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103c6d:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80103c74:	72 e9                	jb     80103c5f <allocproc+0x33>
      goto found;
    }

  release(&ptable.lock);
80103c76:	83 ec 0c             	sub    $0xc,%esp
80103c79:	68 00 55 19 80       	push   $0x80195500
80103c7e:	e8 cb 0e 00 00       	call   80104b4e <release>
80103c83:	83 c4 10             	add    $0x10,%esp
  return 0;
80103c86:	b8 00 00 00 00       	mov    $0x0,%eax
80103c8b:	e9 b6 00 00 00       	jmp    80103d46 <allocproc+0x11a>
      goto found;
80103c90:	90                   	nop
80103c91:	f3 0f 1e fb          	endbr32

found:
  p->state = EMBRYO;
80103c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c98:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103c9f:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103ca4:	8d 50 01             	lea    0x1(%eax),%edx
80103ca7:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103cad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cb0:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103cb3:	83 ec 0c             	sub    $0xc,%esp
80103cb6:	68 00 55 19 80       	push   $0x80195500
80103cbb:	e8 8e 0e 00 00       	call   80104b4e <release>
80103cc0:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103cc3:	e8 20 ec ff ff       	call   801028e8 <kalloc>
80103cc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ccb:	89 42 08             	mov    %eax,0x8(%edx)
80103cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd1:	8b 40 08             	mov    0x8(%eax),%eax
80103cd4:	85 c0                	test   %eax,%eax
80103cd6:	75 11                	jne    80103ce9 <allocproc+0xbd>
    p->state = UNUSED;
80103cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cdb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103ce2:	b8 00 00 00 00       	mov    $0x0,%eax
80103ce7:	eb 5d                	jmp    80103d46 <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
80103ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cec:	8b 40 08             	mov    0x8(%eax),%eax
80103cef:	05 00 10 00 00       	add    $0x1000,%eax
80103cf4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103cf7:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cfe:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103d01:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103d04:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103d08:	ba d1 61 10 80       	mov    $0x801061d1,%edx
80103d0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d10:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103d12:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d19:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103d1c:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d22:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d25:	83 ec 04             	sub    $0x4,%esp
80103d28:	6a 14                	push   $0x14
80103d2a:	6a 00                	push   $0x0
80103d2c:	50                   	push   %eax
80103d2d:	e8 39 10 00 00       	call   80104d6b <memset>
80103d32:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d38:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d3b:	ba 19 45 10 80       	mov    $0x80104519,%edx
80103d40:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103d46:	c9                   	leave
80103d47:	c3                   	ret

80103d48 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103d48:	f3 0f 1e fb          	endbr32
80103d4c:	55                   	push   %ebp
80103d4d:	89 e5                	mov    %esp,%ebp
80103d4f:	83 ec 18             	sub    $0x18,%esp
  cprintf("[userinit] in \n");
80103d52:	83 ec 0c             	sub    $0xc,%esp
80103d55:	68 be a9 10 80       	push   $0x8010a9be
80103d5a:	e8 ad c6 ff ff       	call   8010040c <cprintf>
80103d5f:	83 c4 10             	add    $0x10,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103d62:	e8 c5 fe ff ff       	call   80103c2c <allocproc>
80103d67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d6d:	a3 5c d0 18 80       	mov    %eax,0x8018d05c
  if((p->pgdir = setupkvm()) == 0){
80103d72:	e8 6f 3a 00 00       	call   801077e6 <setupkvm>
80103d77:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d7a:	89 42 04             	mov    %eax,0x4(%edx)
80103d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d80:	8b 40 04             	mov    0x4(%eax),%eax
80103d83:	85 c0                	test   %eax,%eax
80103d85:	75 0d                	jne    80103d94 <userinit+0x4c>
    panic("userinit: out of memory?");
80103d87:	83 ec 0c             	sub    $0xc,%esp
80103d8a:	68 ce a9 10 80       	push   $0x8010a9ce
80103d8f:	e8 4a c8 ff ff       	call   801005de <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103d94:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d9c:	8b 40 04             	mov    0x4(%eax),%eax
80103d9f:	83 ec 04             	sub    $0x4,%esp
80103da2:	52                   	push   %edx
80103da3:	68 ec f4 10 80       	push   $0x8010f4ec
80103da8:	50                   	push   %eax
80103da9:	e8 05 3d 00 00       	call   80107ab3 <inituvm>
80103dae:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db4:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dbd:	8b 40 18             	mov    0x18(%eax),%eax
80103dc0:	83 ec 04             	sub    $0x4,%esp
80103dc3:	6a 4c                	push   $0x4c
80103dc5:	6a 00                	push   $0x0
80103dc7:	50                   	push   %eax
80103dc8:	e8 9e 0f 00 00       	call   80104d6b <memset>
80103dcd:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd3:	8b 40 18             	mov    0x18(%eax),%eax
80103dd6:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ddf:	8b 40 18             	mov    0x18(%eax),%eax
80103de2:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103deb:	8b 50 18             	mov    0x18(%eax),%edx
80103dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df1:	8b 40 18             	mov    0x18(%eax),%eax
80103df4:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103df8:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dff:	8b 50 18             	mov    0x18(%eax),%edx
80103e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e05:	8b 40 18             	mov    0x18(%eax),%eax
80103e08:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103e0c:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e13:	8b 40 18             	mov    0x18(%eax),%eax
80103e16:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e20:	8b 40 18             	mov    0x18(%eax),%eax
80103e23:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e2d:	8b 40 18             	mov    0x18(%eax),%eax
80103e30:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e3a:	83 c0 6c             	add    $0x6c,%eax
80103e3d:	83 ec 04             	sub    $0x4,%esp
80103e40:	6a 10                	push   $0x10
80103e42:	68 e7 a9 10 80       	push   $0x8010a9e7
80103e47:	50                   	push   %eax
80103e48:	e8 39 11 00 00       	call   80104f86 <safestrcpy>
80103e4d:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103e50:	83 ec 0c             	sub    $0xc,%esp
80103e53:	68 f0 a9 10 80       	push   $0x8010a9f0
80103e58:	e8 e0 e7 ff ff       	call   8010263d <namei>
80103e5d:	83 c4 10             	add    $0x10,%esp
80103e60:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e63:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103e66:	83 ec 0c             	sub    $0xc,%esp
80103e69:	68 00 55 19 80       	push   $0x80195500
80103e6e:	e8 69 0c 00 00       	call   80104adc <acquire>
80103e73:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e79:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e80:	83 ec 0c             	sub    $0xc,%esp
80103e83:	68 00 55 19 80       	push   $0x80195500
80103e88:	e8 c1 0c 00 00       	call   80104b4e <release>
80103e8d:	83 c4 10             	add    $0x10,%esp
}
80103e90:	90                   	nop
80103e91:	c9                   	leave
80103e92:	c3                   	ret

80103e93 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103e93:	f3 0f 1e fb          	endbr32
80103e97:	55                   	push   %ebp
80103e98:	89 e5                	mov    %esp,%ebp
80103e9a:	83 ec 18             	sub    $0x18,%esp
  cprintf("[growproc] in\n");
80103e9d:	83 ec 0c             	sub    $0xc,%esp
80103ea0:	68 f2 a9 10 80       	push   $0x8010a9f2
80103ea5:	e8 62 c5 ff ff       	call   8010040c <cprintf>
80103eaa:	83 c4 10             	add    $0x10,%esp
  uint sz;
  struct proc *curproc = myproc();
80103ead:	e8 4d fd ff ff       	call   80103bff <myproc>
80103eb2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103eb8:	8b 00                	mov    (%eax),%eax
80103eba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103ebd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ec1:	7e 2e                	jle    80103ef1 <growproc+0x5e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ec3:	8b 55 08             	mov    0x8(%ebp),%edx
80103ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec9:	01 c2                	add    %eax,%edx
80103ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ece:	8b 40 04             	mov    0x4(%eax),%eax
80103ed1:	83 ec 04             	sub    $0x4,%esp
80103ed4:	52                   	push   %edx
80103ed5:	ff 75 f4             	push   -0xc(%ebp)
80103ed8:	50                   	push   %eax
80103ed9:	e8 1a 3d 00 00       	call   80107bf8 <allocuvm>
80103ede:	83 c4 10             	add    $0x10,%esp
80103ee1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ee4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ee8:	75 3b                	jne    80103f25 <growproc+0x92>
      return -1;
80103eea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103eef:	eb 62                	jmp    80103f53 <growproc+0xc0>
  } else if(n < 0){
80103ef1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ef5:	79 2e                	jns    80103f25 <growproc+0x92>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ef7:	8b 55 08             	mov    0x8(%ebp),%edx
80103efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103efd:	01 c2                	add    %eax,%edx
80103eff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f02:	8b 40 04             	mov    0x4(%eax),%eax
80103f05:	83 ec 04             	sub    $0x4,%esp
80103f08:	52                   	push   %edx
80103f09:	ff 75 f4             	push   -0xc(%ebp)
80103f0c:	50                   	push   %eax
80103f0d:	e8 15 3e 00 00       	call   80107d27 <deallocuvm>
80103f12:	83 c4 10             	add    $0x10,%esp
80103f15:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f18:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f1c:	75 07                	jne    80103f25 <growproc+0x92>
      return -1;
80103f1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f23:	eb 2e                	jmp    80103f53 <growproc+0xc0>
  }
  curproc->sz = sz;
80103f25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f28:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f2b:	89 10                	mov    %edx,(%eax)
  cprintf("[growproc] sz %x\n",sz);
80103f2d:	83 ec 08             	sub    $0x8,%esp
80103f30:	ff 75 f4             	push   -0xc(%ebp)
80103f33:	68 01 aa 10 80       	push   $0x8010aa01
80103f38:	e8 cf c4 ff ff       	call   8010040c <cprintf>
80103f3d:	83 c4 10             	add    $0x10,%esp
  switchuvm(curproc);
80103f40:	83 ec 0c             	sub    $0xc,%esp
80103f43:	ff 75 f0             	push   -0x10(%ebp)
80103f46:	e8 c5 39 00 00       	call   80107910 <switchuvm>
80103f4b:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f53:	c9                   	leave
80103f54:	c3                   	ret

80103f55 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103f55:	f3 0f 1e fb          	endbr32
80103f59:	55                   	push   %ebp
80103f5a:	89 e5                	mov    %esp,%ebp
80103f5c:	57                   	push   %edi
80103f5d:	56                   	push   %esi
80103f5e:	53                   	push   %ebx
80103f5f:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103f62:	e8 98 fc ff ff       	call   80103bff <myproc>
80103f67:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103f6a:	e8 bd fc ff ff       	call   80103c2c <allocproc>
80103f6f:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103f72:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103f76:	75 0a                	jne    80103f82 <fork+0x2d>
    return -1;
80103f78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f7d:	e9 6e 01 00 00       	jmp    801040f0 <fork+0x19b>
  } 
  cprintf("[fork] curproc->sz %x\n",curproc->sz);
80103f82:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f85:	8b 00                	mov    (%eax),%eax
80103f87:	83 ec 08             	sub    $0x8,%esp
80103f8a:	50                   	push   %eax
80103f8b:	68 13 aa 10 80       	push   $0x8010aa13
80103f90:	e8 77 c4 ff ff       	call   8010040c <cprintf>
80103f95:	83 c4 10             	add    $0x10,%esp
  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103f98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f9b:	8b 10                	mov    (%eax),%edx
80103f9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fa0:	8b 40 04             	mov    0x4(%eax),%eax
80103fa3:	83 ec 08             	sub    $0x8,%esp
80103fa6:	52                   	push   %edx
80103fa7:	50                   	push   %eax
80103fa8:	e8 24 3f 00 00       	call   80107ed1 <copyuvm>
80103fad:	83 c4 10             	add    $0x10,%esp
80103fb0:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fb3:	89 42 04             	mov    %eax,0x4(%edx)
80103fb6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fb9:	8b 40 04             	mov    0x4(%eax),%eax
80103fbc:	85 c0                	test   %eax,%eax
80103fbe:	75 30                	jne    80103ff0 <fork+0x9b>
    kfree(np->kstack);
80103fc0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fc3:	8b 40 08             	mov    0x8(%eax),%eax
80103fc6:	83 ec 0c             	sub    $0xc,%esp
80103fc9:	50                   	push   %eax
80103fca:	e8 7b e8 ff ff       	call   8010284a <kfree>
80103fcf:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103fd2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fd5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103fdc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fdf:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103fe6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103feb:	e9 00 01 00 00       	jmp    801040f0 <fork+0x19b>
  }
  np->sz = curproc->sz;
80103ff0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ff3:	8b 10                	mov    (%eax),%edx
80103ff5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ff8:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103ffa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ffd:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104000:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104003:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104006:	8b 48 18             	mov    0x18(%eax),%ecx
80104009:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010400c:	8b 40 18             	mov    0x18(%eax),%eax
8010400f:	89 c2                	mov    %eax,%edx
80104011:	89 cb                	mov    %ecx,%ebx
80104013:	b8 13 00 00 00       	mov    $0x13,%eax
80104018:	89 d7                	mov    %edx,%edi
8010401a:	89 de                	mov    %ebx,%esi
8010401c:	89 c1                	mov    %eax,%ecx
8010401e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104020:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104023:	8b 40 18             	mov    0x18(%eax),%eax
80104026:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
8010402d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104034:	eb 3b                	jmp    80104071 <fork+0x11c>
    if(curproc->ofile[i])
80104036:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104039:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010403c:	83 c2 08             	add    $0x8,%edx
8010403f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104043:	85 c0                	test   %eax,%eax
80104045:	74 26                	je     8010406d <fork+0x118>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104047:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010404a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010404d:	83 c2 08             	add    $0x8,%edx
80104050:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104054:	83 ec 0c             	sub    $0xc,%esp
80104057:	50                   	push   %eax
80104058:	e8 8d d0 ff ff       	call   801010ea <filedup>
8010405d:	83 c4 10             	add    $0x10,%esp
80104060:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104063:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104066:	83 c1 08             	add    $0x8,%ecx
80104069:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
8010406d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104071:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104075:	7e bf                	jle    80104036 <fork+0xe1>
  np->cwd = idup(curproc->cwd);
80104077:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010407a:	8b 40 68             	mov    0x68(%eax),%eax
8010407d:	83 ec 0c             	sub    $0xc,%esp
80104080:	50                   	push   %eax
80104081:	e8 0e da ff ff       	call   80101a94 <idup>
80104086:	83 c4 10             	add    $0x10,%esp
80104089:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010408c:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010408f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104092:	8d 50 6c             	lea    0x6c(%eax),%edx
80104095:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104098:	83 c0 6c             	add    $0x6c,%eax
8010409b:	83 ec 04             	sub    $0x4,%esp
8010409e:	6a 10                	push   $0x10
801040a0:	52                   	push   %edx
801040a1:	50                   	push   %eax
801040a2:	e8 df 0e 00 00       	call   80104f86 <safestrcpy>
801040a7:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801040aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801040ad:	8b 40 10             	mov    0x10(%eax),%eax
801040b0:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801040b3:	83 ec 0c             	sub    $0xc,%esp
801040b6:	68 00 55 19 80       	push   $0x80195500
801040bb:	e8 1c 0a 00 00       	call   80104adc <acquire>
801040c0:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801040c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801040c6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801040cd:	83 ec 0c             	sub    $0xc,%esp
801040d0:	68 00 55 19 80       	push   $0x80195500
801040d5:	e8 74 0a 00 00       	call   80104b4e <release>
801040da:	83 c4 10             	add    $0x10,%esp
  cprintf("[FORK] end\n");
801040dd:	83 ec 0c             	sub    $0xc,%esp
801040e0:	68 2a aa 10 80       	push   $0x8010aa2a
801040e5:	e8 22 c3 ff ff       	call   8010040c <cprintf>
801040ea:	83 c4 10             	add    $0x10,%esp
  return pid;
801040ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801040f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801040f3:	5b                   	pop    %ebx
801040f4:	5e                   	pop    %esi
801040f5:	5f                   	pop    %edi
801040f6:	5d                   	pop    %ebp
801040f7:	c3                   	ret

801040f8 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801040f8:	f3 0f 1e fb          	endbr32
801040fc:	55                   	push   %ebp
801040fd:	89 e5                	mov    %esp,%ebp
801040ff:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104102:	e8 f8 fa ff ff       	call   80103bff <myproc>
80104107:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010410a:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
8010410f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104112:	75 0d                	jne    80104121 <exit+0x29>
    panic("init exiting");
80104114:	83 ec 0c             	sub    $0xc,%esp
80104117:	68 36 aa 10 80       	push   $0x8010aa36
8010411c:	e8 bd c4 ff ff       	call   801005de <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104121:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104128:	eb 3f                	jmp    80104169 <exit+0x71>
    if(curproc->ofile[fd]){
8010412a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010412d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104130:	83 c2 08             	add    $0x8,%edx
80104133:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104137:	85 c0                	test   %eax,%eax
80104139:	74 2a                	je     80104165 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
8010413b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010413e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104141:	83 c2 08             	add    $0x8,%edx
80104144:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104148:	83 ec 0c             	sub    $0xc,%esp
8010414b:	50                   	push   %eax
8010414c:	e8 ee cf ff ff       	call   8010113f <fileclose>
80104151:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104154:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104157:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010415a:	83 c2 08             	add    $0x8,%edx
8010415d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104164:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104165:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104169:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010416d:	7e bb                	jle    8010412a <exit+0x32>
    }
  }

  begin_op();
8010416f:	e8 53 f0 ff ff       	call   801031c7 <begin_op>
  iput(curproc->cwd);
80104174:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104177:	8b 40 68             	mov    0x68(%eax),%eax
8010417a:	83 ec 0c             	sub    $0xc,%esp
8010417d:	50                   	push   %eax
8010417e:	e8 b8 da ff ff       	call   80101c3b <iput>
80104183:	83 c4 10             	add    $0x10,%esp
  end_op();
80104186:	e8 cc f0 ff ff       	call   80103257 <end_op>
  curproc->cwd = 0;
8010418b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010418e:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104195:	83 ec 0c             	sub    $0xc,%esp
80104198:	68 00 55 19 80       	push   $0x80195500
8010419d:	e8 3a 09 00 00       	call   80104adc <acquire>
801041a2:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801041a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041a8:	8b 40 14             	mov    0x14(%eax),%eax
801041ab:	83 ec 0c             	sub    $0xc,%esp
801041ae:	50                   	push   %eax
801041af:	e8 5a 04 00 00       	call   8010460e <wakeup1>
801041b4:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041b7:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801041be:	eb 37                	jmp    801041f7 <exit+0xff>
    if(p->parent == curproc){
801041c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c3:	8b 40 14             	mov    0x14(%eax),%eax
801041c6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801041c9:	75 28                	jne    801041f3 <exit+0xfb>
      p->parent = initproc;
801041cb:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
801041d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d4:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801041d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041da:	8b 40 0c             	mov    0xc(%eax),%eax
801041dd:	83 f8 05             	cmp    $0x5,%eax
801041e0:	75 11                	jne    801041f3 <exit+0xfb>
        wakeup1(initproc);
801041e2:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
801041e7:	83 ec 0c             	sub    $0xc,%esp
801041ea:	50                   	push   %eax
801041eb:	e8 1e 04 00 00       	call   8010460e <wakeup1>
801041f0:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041f3:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801041f7:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801041fe:	72 c0                	jb     801041c0 <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104200:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104203:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010420a:	e8 0f 02 00 00       	call   8010441e <sched>
  panic("zombie exit");
8010420f:	83 ec 0c             	sub    $0xc,%esp
80104212:	68 43 aa 10 80       	push   $0x8010aa43
80104217:	e8 c2 c3 ff ff       	call   801005de <panic>

8010421c <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010421c:	f3 0f 1e fb          	endbr32
80104220:	55                   	push   %ebp
80104221:	89 e5                	mov    %esp,%ebp
80104223:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104226:	e8 d4 f9 ff ff       	call   80103bff <myproc>
8010422b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
8010422e:	83 ec 0c             	sub    $0xc,%esp
80104231:	68 00 55 19 80       	push   $0x80195500
80104236:	e8 a1 08 00 00       	call   80104adc <acquire>
8010423b:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
8010423e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104245:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010424c:	e9 a1 00 00 00       	jmp    801042f2 <wait+0xd6>
      if(p->parent != curproc)
80104251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104254:	8b 40 14             	mov    0x14(%eax),%eax
80104257:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010425a:	0f 85 8d 00 00 00    	jne    801042ed <wait+0xd1>
        continue;
      havekids = 1;
80104260:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104267:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010426a:	8b 40 0c             	mov    0xc(%eax),%eax
8010426d:	83 f8 05             	cmp    $0x5,%eax
80104270:	75 7c                	jne    801042ee <wait+0xd2>
        // Found one.
        pid = p->pid;
80104272:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104275:	8b 40 10             	mov    0x10(%eax),%eax
80104278:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010427b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427e:	8b 40 08             	mov    0x8(%eax),%eax
80104281:	83 ec 0c             	sub    $0xc,%esp
80104284:	50                   	push   %eax
80104285:	e8 c0 e5 ff ff       	call   8010284a <kfree>
8010428a:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010428d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104290:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010429a:	8b 40 04             	mov    0x4(%eax),%eax
8010429d:	83 ec 0c             	sub    $0xc,%esp
801042a0:	50                   	push   %eax
801042a1:	e8 49 3b 00 00       	call   80107def <freevm>
801042a6:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801042a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ac:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801042b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801042bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c0:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801042c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c7:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801042ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801042d8:	83 ec 0c             	sub    $0xc,%esp
801042db:	68 00 55 19 80       	push   $0x80195500
801042e0:	e8 69 08 00 00       	call   80104b4e <release>
801042e5:	83 c4 10             	add    $0x10,%esp
        return pid;
801042e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801042eb:	eb 51                	jmp    8010433e <wait+0x122>
        continue;
801042ed:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042ee:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801042f2:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801042f9:	0f 82 52 ff ff ff    	jb     80104251 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801042ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104303:	74 0a                	je     8010430f <wait+0xf3>
80104305:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104308:	8b 40 24             	mov    0x24(%eax),%eax
8010430b:	85 c0                	test   %eax,%eax
8010430d:	74 17                	je     80104326 <wait+0x10a>
      release(&ptable.lock);
8010430f:	83 ec 0c             	sub    $0xc,%esp
80104312:	68 00 55 19 80       	push   $0x80195500
80104317:	e8 32 08 00 00       	call   80104b4e <release>
8010431c:	83 c4 10             	add    $0x10,%esp
      return -1;
8010431f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104324:	eb 18                	jmp    8010433e <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104326:	83 ec 08             	sub    $0x8,%esp
80104329:	68 00 55 19 80       	push   $0x80195500
8010432e:	ff 75 ec             	push   -0x14(%ebp)
80104331:	e8 2d 02 00 00       	call   80104563 <sleep>
80104336:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104339:	e9 00 ff ff ff       	jmp    8010423e <wait+0x22>
  }
}
8010433e:	c9                   	leave
8010433f:	c3                   	ret

80104340 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104340:	f3 0f 1e fb          	endbr32
80104344:	55                   	push   %ebp
80104345:	89 e5                	mov    %esp,%ebp
80104347:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
8010434a:	e8 34 f8 ff ff       	call   80103b83 <mycpu>
8010434f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104352:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104355:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010435c:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010435f:	e8 d7 f7 ff ff       	call   80103b3b <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104364:	83 ec 0c             	sub    $0xc,%esp
80104367:	68 00 55 19 80       	push   $0x80195500
8010436c:	e8 6b 07 00 00       	call   80104adc <acquire>
80104371:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104374:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010437b:	eb 61                	jmp    801043de <scheduler+0x9e>
      if(p->state != RUNNABLE)
8010437d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104380:	8b 40 0c             	mov    0xc(%eax),%eax
80104383:	83 f8 03             	cmp    $0x3,%eax
80104386:	75 51                	jne    801043d9 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104388:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010438b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010438e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104394:	83 ec 0c             	sub    $0xc,%esp
80104397:	ff 75 f4             	push   -0xc(%ebp)
8010439a:	e8 71 35 00 00       	call   80107910 <switchuvm>
8010439f:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801043a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a5:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&(c->scheduler), p->context);
801043ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043af:	8b 40 1c             	mov    0x1c(%eax),%eax
801043b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043b5:	83 c2 04             	add    $0x4,%edx
801043b8:	83 ec 08             	sub    $0x8,%esp
801043bb:	50                   	push   %eax
801043bc:	52                   	push   %edx
801043bd:	e8 3d 0c 00 00       	call   80104fff <swtch>
801043c2:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801043c5:	e8 29 35 00 00       	call   801078f3 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
801043ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043cd:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801043d4:	00 00 00 
801043d7:	eb 01                	jmp    801043da <scheduler+0x9a>
        continue;
801043d9:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043da:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801043de:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801043e5:	72 96                	jb     8010437d <scheduler+0x3d>
    }
    release(&ptable.lock);
801043e7:	83 ec 0c             	sub    $0xc,%esp
801043ea:	68 00 55 19 80       	push   $0x80195500
801043ef:	e8 5a 07 00 00       	call   80104b4e <release>
801043f4:	83 c4 10             	add    $0x10,%esp
    sti();
801043f7:	e9 63 ff ff ff       	jmp    8010435f <scheduler+0x1f>

801043fc <uthread_init>:
// uthread_init: 유저 레벨 쓰레드의 스케줄러의 주소를 커널의 proccess에 넘겨준다.
// 이 함수를 시스템콜에서 호출하여 uthread의 스케줄러의 주소를 가져오고 
// 커널에서 인터럽트가 발생할 때 uthread의 스케줄러를 실행할 수 있게 된다.
int 
uthread_init(int address)
{
801043fc:	f3 0f 1e fb          	endbr32
80104400:	55                   	push   %ebp
80104401:	89 e5                	mov    %esp,%ebp
80104403:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104406:	e8 f4 f7 ff ff       	call   80103bff <myproc>
8010440b:	89 45 f4             	mov    %eax,-0xc(%ebp)
//  p->trapflag = 1;
  curproc->scheduler = (uint)address;
8010440e:	8b 55 08             	mov    0x8(%ebp),%edx
80104411:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104414:	89 50 7c             	mov    %edx,0x7c(%eax)
  //cprintf("address: %d", address);
  return 0;
80104417:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010441c:	c9                   	leave
8010441d:	c3                   	ret

8010441e <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
8010441e:	f3 0f 1e fb          	endbr32
80104422:	55                   	push   %ebp
80104423:	89 e5                	mov    %esp,%ebp
80104425:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104428:	e8 d2 f7 ff ff       	call   80103bff <myproc>
8010442d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104430:	83 ec 0c             	sub    $0xc,%esp
80104433:	68 00 55 19 80       	push   $0x80195500
80104438:	e8 e6 07 00 00       	call   80104c23 <holding>
8010443d:	83 c4 10             	add    $0x10,%esp
80104440:	85 c0                	test   %eax,%eax
80104442:	75 0d                	jne    80104451 <sched+0x33>
    panic("sched ptable.lock");
80104444:	83 ec 0c             	sub    $0xc,%esp
80104447:	68 4f aa 10 80       	push   $0x8010aa4f
8010444c:	e8 8d c1 ff ff       	call   801005de <panic>
  if(mycpu()->ncli != 1)
80104451:	e8 2d f7 ff ff       	call   80103b83 <mycpu>
80104456:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010445c:	83 f8 01             	cmp    $0x1,%eax
8010445f:	74 0d                	je     8010446e <sched+0x50>
    panic("sched locks");
80104461:	83 ec 0c             	sub    $0xc,%esp
80104464:	68 61 aa 10 80       	push   $0x8010aa61
80104469:	e8 70 c1 ff ff       	call   801005de <panic>
  if(p->state == RUNNING)
8010446e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104471:	8b 40 0c             	mov    0xc(%eax),%eax
80104474:	83 f8 04             	cmp    $0x4,%eax
80104477:	75 0d                	jne    80104486 <sched+0x68>
    panic("sched running");
80104479:	83 ec 0c             	sub    $0xc,%esp
8010447c:	68 6d aa 10 80       	push   $0x8010aa6d
80104481:	e8 58 c1 ff ff       	call   801005de <panic>
  if(readeflags()&FL_IF)
80104486:	e8 a0 f6 ff ff       	call   80103b2b <readeflags>
8010448b:	25 00 02 00 00       	and    $0x200,%eax
80104490:	85 c0                	test   %eax,%eax
80104492:	74 0d                	je     801044a1 <sched+0x83>
    panic("sched interruptible");
80104494:	83 ec 0c             	sub    $0xc,%esp
80104497:	68 7b aa 10 80       	push   $0x8010aa7b
8010449c:	e8 3d c1 ff ff       	call   801005de <panic>
  intena = mycpu()->intena;
801044a1:	e8 dd f6 ff ff       	call   80103b83 <mycpu>
801044a6:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801044ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801044af:	e8 cf f6 ff ff       	call   80103b83 <mycpu>
801044b4:	8b 40 04             	mov    0x4(%eax),%eax
801044b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044ba:	83 c2 1c             	add    $0x1c,%edx
801044bd:	83 ec 08             	sub    $0x8,%esp
801044c0:	50                   	push   %eax
801044c1:	52                   	push   %edx
801044c2:	e8 38 0b 00 00       	call   80104fff <swtch>
801044c7:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801044ca:	e8 b4 f6 ff ff       	call   80103b83 <mycpu>
801044cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044d2:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801044d8:	90                   	nop
801044d9:	c9                   	leave
801044da:	c3                   	ret

801044db <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801044db:	f3 0f 1e fb          	endbr32
801044df:	55                   	push   %ebp
801044e0:	89 e5                	mov    %esp,%ebp
801044e2:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801044e5:	83 ec 0c             	sub    $0xc,%esp
801044e8:	68 00 55 19 80       	push   $0x80195500
801044ed:	e8 ea 05 00 00       	call   80104adc <acquire>
801044f2:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
801044f5:	e8 05 f7 ff ff       	call   80103bff <myproc>
801044fa:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104501:	e8 18 ff ff ff       	call   8010441e <sched>
  release(&ptable.lock);
80104506:	83 ec 0c             	sub    $0xc,%esp
80104509:	68 00 55 19 80       	push   $0x80195500
8010450e:	e8 3b 06 00 00       	call   80104b4e <release>
80104513:	83 c4 10             	add    $0x10,%esp
}
80104516:	90                   	nop
80104517:	c9                   	leave
80104518:	c3                   	ret

80104519 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104519:	f3 0f 1e fb          	endbr32
8010451d:	55                   	push   %ebp
8010451e:	89 e5                	mov    %esp,%ebp
80104520:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104523:	83 ec 0c             	sub    $0xc,%esp
80104526:	68 00 55 19 80       	push   $0x80195500
8010452b:	e8 1e 06 00 00       	call   80104b4e <release>
80104530:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104533:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104538:	85 c0                	test   %eax,%eax
8010453a:	74 24                	je     80104560 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010453c:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104543:	00 00 00 
    iinit(ROOTDEV);
80104546:	83 ec 0c             	sub    $0xc,%esp
80104549:	6a 01                	push   $0x1
8010454b:	e8 fc d1 ff ff       	call   8010174c <iinit>
80104550:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104553:	83 ec 0c             	sub    $0xc,%esp
80104556:	6a 01                	push   $0x1
80104558:	e8 37 ea ff ff       	call   80102f94 <initlog>
8010455d:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104560:	90                   	nop
80104561:	c9                   	leave
80104562:	c3                   	ret

80104563 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104563:	f3 0f 1e fb          	endbr32
80104567:	55                   	push   %ebp
80104568:	89 e5                	mov    %esp,%ebp
8010456a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
8010456d:	e8 8d f6 ff ff       	call   80103bff <myproc>
80104572:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104575:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104579:	75 0d                	jne    80104588 <sleep+0x25>
    panic("sleep");
8010457b:	83 ec 0c             	sub    $0xc,%esp
8010457e:	68 8f aa 10 80       	push   $0x8010aa8f
80104583:	e8 56 c0 ff ff       	call   801005de <panic>

  if(lk == 0)
80104588:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010458c:	75 0d                	jne    8010459b <sleep+0x38>
    panic("sleep without lk");
8010458e:	83 ec 0c             	sub    $0xc,%esp
80104591:	68 95 aa 10 80       	push   $0x8010aa95
80104596:	e8 43 c0 ff ff       	call   801005de <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010459b:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
801045a2:	74 1e                	je     801045c2 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
801045a4:	83 ec 0c             	sub    $0xc,%esp
801045a7:	68 00 55 19 80       	push   $0x80195500
801045ac:	e8 2b 05 00 00       	call   80104adc <acquire>
801045b1:	83 c4 10             	add    $0x10,%esp
    release(lk);
801045b4:	83 ec 0c             	sub    $0xc,%esp
801045b7:	ff 75 0c             	push   0xc(%ebp)
801045ba:	e8 8f 05 00 00       	call   80104b4e <release>
801045bf:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801045c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c5:	8b 55 08             	mov    0x8(%ebp),%edx
801045c8:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801045cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ce:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801045d5:	e8 44 fe ff ff       	call   8010441e <sched>

  // Tidy up.
  p->chan = 0;
801045da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045dd:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801045e4:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
801045eb:	74 1e                	je     8010460b <sleep+0xa8>
    release(&ptable.lock);
801045ed:	83 ec 0c             	sub    $0xc,%esp
801045f0:	68 00 55 19 80       	push   $0x80195500
801045f5:	e8 54 05 00 00       	call   80104b4e <release>
801045fa:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801045fd:	83 ec 0c             	sub    $0xc,%esp
80104600:	ff 75 0c             	push   0xc(%ebp)
80104603:	e8 d4 04 00 00       	call   80104adc <acquire>
80104608:	83 c4 10             	add    $0x10,%esp
  }
}
8010460b:	90                   	nop
8010460c:	c9                   	leave
8010460d:	c3                   	ret

8010460e <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010460e:	f3 0f 1e fb          	endbr32
80104612:	55                   	push   %ebp
80104613:	89 e5                	mov    %esp,%ebp
80104615:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104618:	c7 45 fc 34 55 19 80 	movl   $0x80195534,-0x4(%ebp)
8010461f:	eb 24                	jmp    80104645 <wakeup1+0x37>
    if(p->state == SLEEPING && p->chan == chan)
80104621:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104624:	8b 40 0c             	mov    0xc(%eax),%eax
80104627:	83 f8 02             	cmp    $0x2,%eax
8010462a:	75 15                	jne    80104641 <wakeup1+0x33>
8010462c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010462f:	8b 40 20             	mov    0x20(%eax),%eax
80104632:	39 45 08             	cmp    %eax,0x8(%ebp)
80104635:	75 0a                	jne    80104641 <wakeup1+0x33>
      p->state = RUNNABLE;
80104637:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010463a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104641:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104645:	81 7d fc 34 75 19 80 	cmpl   $0x80197534,-0x4(%ebp)
8010464c:	72 d3                	jb     80104621 <wakeup1+0x13>
}
8010464e:	90                   	nop
8010464f:	90                   	nop
80104650:	c9                   	leave
80104651:	c3                   	ret

80104652 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104652:	f3 0f 1e fb          	endbr32
80104656:	55                   	push   %ebp
80104657:	89 e5                	mov    %esp,%ebp
80104659:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010465c:	83 ec 0c             	sub    $0xc,%esp
8010465f:	68 00 55 19 80       	push   $0x80195500
80104664:	e8 73 04 00 00       	call   80104adc <acquire>
80104669:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010466c:	83 ec 0c             	sub    $0xc,%esp
8010466f:	ff 75 08             	push   0x8(%ebp)
80104672:	e8 97 ff ff ff       	call   8010460e <wakeup1>
80104677:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010467a:	83 ec 0c             	sub    $0xc,%esp
8010467d:	68 00 55 19 80       	push   $0x80195500
80104682:	e8 c7 04 00 00       	call   80104b4e <release>
80104687:	83 c4 10             	add    $0x10,%esp
}
8010468a:	90                   	nop
8010468b:	c9                   	leave
8010468c:	c3                   	ret

8010468d <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010468d:	f3 0f 1e fb          	endbr32
80104691:	55                   	push   %ebp
80104692:	89 e5                	mov    %esp,%ebp
80104694:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104697:	83 ec 0c             	sub    $0xc,%esp
8010469a:	68 00 55 19 80       	push   $0x80195500
8010469f:	e8 38 04 00 00       	call   80104adc <acquire>
801046a4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046a7:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801046ae:	eb 45                	jmp    801046f5 <kill+0x68>
    if(p->pid == pid){
801046b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b3:	8b 40 10             	mov    0x10(%eax),%eax
801046b6:	39 45 08             	cmp    %eax,0x8(%ebp)
801046b9:	75 36                	jne    801046f1 <kill+0x64>
      p->killed = 1;
801046bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046be:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801046c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c8:	8b 40 0c             	mov    0xc(%eax),%eax
801046cb:	83 f8 02             	cmp    $0x2,%eax
801046ce:	75 0a                	jne    801046da <kill+0x4d>
        p->state = RUNNABLE;
801046d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801046da:	83 ec 0c             	sub    $0xc,%esp
801046dd:	68 00 55 19 80       	push   $0x80195500
801046e2:	e8 67 04 00 00       	call   80104b4e <release>
801046e7:	83 c4 10             	add    $0x10,%esp
      return 0;
801046ea:	b8 00 00 00 00       	mov    $0x0,%eax
801046ef:	eb 22                	jmp    80104713 <kill+0x86>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046f1:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801046f5:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801046fc:	72 b2                	jb     801046b0 <kill+0x23>
    }
  }
  release(&ptable.lock);
801046fe:	83 ec 0c             	sub    $0xc,%esp
80104701:	68 00 55 19 80       	push   $0x80195500
80104706:	e8 43 04 00 00       	call   80104b4e <release>
8010470b:	83 c4 10             	add    $0x10,%esp
  return -1;
8010470e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104713:	c9                   	leave
80104714:	c3                   	ret

80104715 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104715:	f3 0f 1e fb          	endbr32
80104719:	55                   	push   %ebp
8010471a:	89 e5                	mov    %esp,%ebp
8010471c:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010471f:	c7 45 f0 34 55 19 80 	movl   $0x80195534,-0x10(%ebp)
80104726:	e9 d7 00 00 00       	jmp    80104802 <procdump+0xed>
    if(p->state == UNUSED)
8010472b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010472e:	8b 40 0c             	mov    0xc(%eax),%eax
80104731:	85 c0                	test   %eax,%eax
80104733:	0f 84 c4 00 00 00    	je     801047fd <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104739:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010473c:	8b 40 0c             	mov    0xc(%eax),%eax
8010473f:	83 f8 05             	cmp    $0x5,%eax
80104742:	77 23                	ja     80104767 <procdump+0x52>
80104744:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104747:	8b 40 0c             	mov    0xc(%eax),%eax
8010474a:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104751:	85 c0                	test   %eax,%eax
80104753:	74 12                	je     80104767 <procdump+0x52>
      state = states[p->state];
80104755:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104758:	8b 40 0c             	mov    0xc(%eax),%eax
8010475b:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104762:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104765:	eb 07                	jmp    8010476e <procdump+0x59>
    else
      state = "???";
80104767:	c7 45 ec a6 aa 10 80 	movl   $0x8010aaa6,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010476e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104771:	8d 50 6c             	lea    0x6c(%eax),%edx
80104774:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104777:	8b 40 10             	mov    0x10(%eax),%eax
8010477a:	52                   	push   %edx
8010477b:	ff 75 ec             	push   -0x14(%ebp)
8010477e:	50                   	push   %eax
8010477f:	68 aa aa 10 80       	push   $0x8010aaaa
80104784:	e8 83 bc ff ff       	call   8010040c <cprintf>
80104789:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010478c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010478f:	8b 40 0c             	mov    0xc(%eax),%eax
80104792:	83 f8 02             	cmp    $0x2,%eax
80104795:	75 54                	jne    801047eb <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104797:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010479a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010479d:	8b 40 0c             	mov    0xc(%eax),%eax
801047a0:	83 c0 08             	add    $0x8,%eax
801047a3:	89 c2                	mov    %eax,%edx
801047a5:	83 ec 08             	sub    $0x8,%esp
801047a8:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801047ab:	50                   	push   %eax
801047ac:	52                   	push   %edx
801047ad:	e8 f2 03 00 00       	call   80104ba4 <getcallerpcs>
801047b2:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801047b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801047bc:	eb 1c                	jmp    801047da <procdump+0xc5>
        cprintf(" %p", pc[i]);
801047be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c1:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801047c5:	83 ec 08             	sub    $0x8,%esp
801047c8:	50                   	push   %eax
801047c9:	68 b3 aa 10 80       	push   $0x8010aab3
801047ce:	e8 39 bc ff ff       	call   8010040c <cprintf>
801047d3:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801047d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801047da:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801047de:	7f 0b                	jg     801047eb <procdump+0xd6>
801047e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e3:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801047e7:	85 c0                	test   %eax,%eax
801047e9:	75 d3                	jne    801047be <procdump+0xa9>
    }
    cprintf("\n");
801047eb:	83 ec 0c             	sub    $0xc,%esp
801047ee:	68 b7 aa 10 80       	push   $0x8010aab7
801047f3:	e8 14 bc ff ff       	call   8010040c <cprintf>
801047f8:	83 c4 10             	add    $0x10,%esp
801047fb:	eb 01                	jmp    801047fe <procdump+0xe9>
      continue;
801047fd:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047fe:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104802:	81 7d f0 34 75 19 80 	cmpl   $0x80197534,-0x10(%ebp)
80104809:	0f 82 1c ff ff ff    	jb     8010472b <procdump+0x16>
  }
}
8010480f:	90                   	nop
80104810:	90                   	nop
80104811:	c9                   	leave
80104812:	c3                   	ret

80104813 <printpt>:

// 페이지 테이블 출력
int printpt(int pid){
80104813:	f3 0f 1e fb          	endbr32
80104817:	55                   	push   %ebp
80104818:	89 e5                	mov    %esp,%ebp
8010481a:	53                   	push   %ebx
8010481b:	83 ec 14             	sub    $0x14,%esp
  struct proc* p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010481e:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104825:	eb 0f                	jmp    80104836 <printpt+0x23>
    if (p->pid == pid)
80104827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482a:	8b 40 10             	mov    0x10(%eax),%eax
8010482d:	39 45 08             	cmp    %eax,0x8(%ebp)
80104830:	74 0f                	je     80104841 <printpt+0x2e>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104832:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104836:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
8010483d:	72 e8                	jb     80104827 <printpt+0x14>
8010483f:	eb 01                	jmp    80104842 <printpt+0x2f>
      break;
80104841:	90                   	nop
  }
  if (p == 0){
80104842:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104846:	75 1a                	jne    80104862 <printpt+0x4f>
    cprintf("[printpt] invaild proccess\n");
80104848:	83 ec 0c             	sub    $0xc,%esp
8010484b:	68 b9 aa 10 80       	push   $0x8010aab9
80104850:	e8 b7 bb ff ff       	call   8010040c <cprintf>
80104855:	83 c4 10             	add    $0x10,%esp
    return -1;
80104858:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010485d:	e9 e2 00 00 00       	jmp    80104944 <printpt+0x131>
  }
  
  pde_t* pgdir = p->pgdir;
80104862:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104865:	8b 40 04             	mov    0x4(%eax),%eax
80104868:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint va;
  // walkpgdir은 pgdir에서 va(가상주소)가 위치한 페이지 테이블 엔트리를 반환한다.
  cprintf("START PAGE TABLE (pid %d) \n", pid);
8010486b:	83 ec 08             	sub    $0x8,%esp
8010486e:	ff 75 08             	push   0x8(%ebp)
80104871:	68 d5 aa 10 80       	push   $0x8010aad5
80104876:	e8 91 bb ff ff       	call   8010040c <cprintf>
8010487b:	83 c4 10             	add    $0x10,%esp
  // 페이지 테이블 엔트리를 한 줄씩 출력
  // xv6에서는 pagesize를 4KB로 설정 PGSIZE == 4096 임
  for (va = 0; va < KERNBASE; va += PGSIZE)
8010487e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104885:	e9 9a 00 00 00       	jmp    80104924 <printpt+0x111>
  {
    // va가 속한 페이지 테이블 엔트리
    pte_t* pte = walkpgdir(pgdir, (void*) va, 0);
8010488a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010488d:	83 ec 04             	sub    $0x4,%esp
80104890:	6a 00                	push   $0x0
80104892:	50                   	push   %eax
80104893:	ff 75 ec             	push   -0x14(%ebp)
80104896:	e8 1d 2e 00 00       	call   801076b8 <walkpgdir>
8010489b:	83 c4 10             	add    $0x10,%esp
8010489e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    // pte가 유효하지 않으면 패스
    if (!(*pte & PTE_P) || pte == 0) continue;
801048a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048a4:	8b 00                	mov    (%eax),%eax
801048a6:	83 e0 01             	and    $0x1,%eax
801048a9:	85 c0                	test   %eax,%eax
801048ab:	74 6f                	je     8010491c <printpt+0x109>
801048ad:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801048b1:	74 69                	je     8010491c <printpt+0x109>
    cprintf("pte: %x\n",pte);
801048b3:	83 ec 08             	sub    $0x8,%esp
801048b6:	ff 75 e8             	push   -0x18(%ebp)
801048b9:	68 f1 aa 10 80       	push   $0x8010aaf1
801048be:	e8 49 bb ff ff       	call   8010040c <cprintf>
801048c3:	83 c4 10             	add    $0x10,%esp
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
      (*pte & PTE_W)?'W':'-', PTE_ADDR(*pte) >> 12); 
801048c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048c9:	8b 00                	mov    (%eax),%eax
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
801048cb:	c1 e8 0c             	shr    $0xc,%eax
801048ce:	89 c2                	mov    %eax,%edx
      (*pte & PTE_W)?'W':'-', PTE_ADDR(*pte) >> 12); 
801048d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048d3:	8b 00                	mov    (%eax),%eax
801048d5:	83 e0 02             	and    $0x2,%eax
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
801048d8:	85 c0                	test   %eax,%eax
801048da:	74 07                	je     801048e3 <printpt+0xd0>
801048dc:	bb 57 00 00 00       	mov    $0x57,%ebx
801048e1:	eb 05                	jmp    801048e8 <printpt+0xd5>
801048e3:	bb 2d 00 00 00       	mov    $0x2d,%ebx
801048e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048eb:	8b 00                	mov    (%eax),%eax
801048ed:	83 e0 04             	and    $0x4,%eax
801048f0:	85 c0                	test   %eax,%eax
801048f2:	74 07                	je     801048fb <printpt+0xe8>
801048f4:	b9 55 00 00 00       	mov    $0x55,%ecx
801048f9:	eb 05                	jmp    80104900 <printpt+0xed>
801048fb:	b9 4b 00 00 00       	mov    $0x4b,%ecx
80104900:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104903:	c1 e8 0c             	shr    $0xc,%eax
80104906:	83 ec 0c             	sub    $0xc,%esp
80104909:	52                   	push   %edx
8010490a:	53                   	push   %ebx
8010490b:	51                   	push   %ecx
8010490c:	50                   	push   %eax
8010490d:	68 fa aa 10 80       	push   $0x8010aafa
80104912:	e8 f5 ba ff ff       	call   8010040c <cprintf>
80104917:	83 c4 20             	add    $0x20,%esp
8010491a:	eb 01                	jmp    8010491d <printpt+0x10a>
    if (!(*pte & PTE_P) || pte == 0) continue;
8010491c:	90                   	nop
  for (va = 0; va < KERNBASE; va += PGSIZE)
8010491d:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
80104924:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104927:	85 c0                	test   %eax,%eax
80104929:	0f 89 5b ff ff ff    	jns    8010488a <printpt+0x77>
  }
  cprintf("END PAGE TABLE\n");
8010492f:	83 ec 0c             	sub    $0xc,%esp
80104932:	68 09 ab 10 80       	push   $0x8010ab09
80104937:	e8 d0 ba ff ff       	call   8010040c <cprintf>
8010493c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010493f:	b8 00 00 00 00       	mov    $0x0,%eax
80104944:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104947:	c9                   	leave
80104948:	c3                   	ret

80104949 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104949:	f3 0f 1e fb          	endbr32
8010494d:	55                   	push   %ebp
8010494e:	89 e5                	mov    %esp,%ebp
80104950:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104953:	8b 45 08             	mov    0x8(%ebp),%eax
80104956:	83 c0 04             	add    $0x4,%eax
80104959:	83 ec 08             	sub    $0x8,%esp
8010495c:	68 43 ab 10 80       	push   $0x8010ab43
80104961:	50                   	push   %eax
80104962:	e8 4f 01 00 00       	call   80104ab6 <initlock>
80104967:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
8010496a:	8b 45 08             	mov    0x8(%ebp),%eax
8010496d:	8b 55 0c             	mov    0xc(%ebp),%edx
80104970:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104973:	8b 45 08             	mov    0x8(%ebp),%eax
80104976:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010497c:	8b 45 08             	mov    0x8(%ebp),%eax
8010497f:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104986:	90                   	nop
80104987:	c9                   	leave
80104988:	c3                   	ret

80104989 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104989:	f3 0f 1e fb          	endbr32
8010498d:	55                   	push   %ebp
8010498e:	89 e5                	mov    %esp,%ebp
80104990:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104993:	8b 45 08             	mov    0x8(%ebp),%eax
80104996:	83 c0 04             	add    $0x4,%eax
80104999:	83 ec 0c             	sub    $0xc,%esp
8010499c:	50                   	push   %eax
8010499d:	e8 3a 01 00 00       	call   80104adc <acquire>
801049a2:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801049a5:	eb 15                	jmp    801049bc <acquiresleep+0x33>
    sleep(lk, &lk->lk);
801049a7:	8b 45 08             	mov    0x8(%ebp),%eax
801049aa:	83 c0 04             	add    $0x4,%eax
801049ad:	83 ec 08             	sub    $0x8,%esp
801049b0:	50                   	push   %eax
801049b1:	ff 75 08             	push   0x8(%ebp)
801049b4:	e8 aa fb ff ff       	call   80104563 <sleep>
801049b9:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801049bc:	8b 45 08             	mov    0x8(%ebp),%eax
801049bf:	8b 00                	mov    (%eax),%eax
801049c1:	85 c0                	test   %eax,%eax
801049c3:	75 e2                	jne    801049a7 <acquiresleep+0x1e>
  }
  lk->locked = 1;
801049c5:	8b 45 08             	mov    0x8(%ebp),%eax
801049c8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801049ce:	e8 2c f2 ff ff       	call   80103bff <myproc>
801049d3:	8b 50 10             	mov    0x10(%eax),%edx
801049d6:	8b 45 08             	mov    0x8(%ebp),%eax
801049d9:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801049dc:	8b 45 08             	mov    0x8(%ebp),%eax
801049df:	83 c0 04             	add    $0x4,%eax
801049e2:	83 ec 0c             	sub    $0xc,%esp
801049e5:	50                   	push   %eax
801049e6:	e8 63 01 00 00       	call   80104b4e <release>
801049eb:	83 c4 10             	add    $0x10,%esp
}
801049ee:	90                   	nop
801049ef:	c9                   	leave
801049f0:	c3                   	ret

801049f1 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801049f1:	f3 0f 1e fb          	endbr32
801049f5:	55                   	push   %ebp
801049f6:	89 e5                	mov    %esp,%ebp
801049f8:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801049fb:	8b 45 08             	mov    0x8(%ebp),%eax
801049fe:	83 c0 04             	add    $0x4,%eax
80104a01:	83 ec 0c             	sub    $0xc,%esp
80104a04:	50                   	push   %eax
80104a05:	e8 d2 00 00 00       	call   80104adc <acquire>
80104a0a:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a10:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104a16:	8b 45 08             	mov    0x8(%ebp),%eax
80104a19:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104a20:	83 ec 0c             	sub    $0xc,%esp
80104a23:	ff 75 08             	push   0x8(%ebp)
80104a26:	e8 27 fc ff ff       	call   80104652 <wakeup>
80104a2b:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a31:	83 c0 04             	add    $0x4,%eax
80104a34:	83 ec 0c             	sub    $0xc,%esp
80104a37:	50                   	push   %eax
80104a38:	e8 11 01 00 00       	call   80104b4e <release>
80104a3d:	83 c4 10             	add    $0x10,%esp
}
80104a40:	90                   	nop
80104a41:	c9                   	leave
80104a42:	c3                   	ret

80104a43 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104a43:	f3 0f 1e fb          	endbr32
80104a47:	55                   	push   %ebp
80104a48:	89 e5                	mov    %esp,%ebp
80104a4a:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a50:	83 c0 04             	add    $0x4,%eax
80104a53:	83 ec 0c             	sub    $0xc,%esp
80104a56:	50                   	push   %eax
80104a57:	e8 80 00 00 00       	call   80104adc <acquire>
80104a5c:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104a62:	8b 00                	mov    (%eax),%eax
80104a64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104a67:	8b 45 08             	mov    0x8(%ebp),%eax
80104a6a:	83 c0 04             	add    $0x4,%eax
80104a6d:	83 ec 0c             	sub    $0xc,%esp
80104a70:	50                   	push   %eax
80104a71:	e8 d8 00 00 00       	call   80104b4e <release>
80104a76:	83 c4 10             	add    $0x10,%esp
  return r;
80104a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104a7c:	c9                   	leave
80104a7d:	c3                   	ret

80104a7e <readeflags>:
{
80104a7e:	55                   	push   %ebp
80104a7f:	89 e5                	mov    %esp,%ebp
80104a81:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104a84:	9c                   	pushf
80104a85:	58                   	pop    %eax
80104a86:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104a89:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a8c:	c9                   	leave
80104a8d:	c3                   	ret

80104a8e <cli>:
{
80104a8e:	55                   	push   %ebp
80104a8f:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104a91:	fa                   	cli
}
80104a92:	90                   	nop
80104a93:	5d                   	pop    %ebp
80104a94:	c3                   	ret

80104a95 <sti>:
{
80104a95:	55                   	push   %ebp
80104a96:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104a98:	fb                   	sti
}
80104a99:	90                   	nop
80104a9a:	5d                   	pop    %ebp
80104a9b:	c3                   	ret

80104a9c <xchg>:
{
80104a9c:	55                   	push   %ebp
80104a9d:	89 e5                	mov    %esp,%ebp
80104a9f:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104aa2:	8b 55 08             	mov    0x8(%ebp),%edx
80104aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aa8:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104aab:	f0 87 02             	lock xchg %eax,(%edx)
80104aae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104ab1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ab4:	c9                   	leave
80104ab5:	c3                   	ret

80104ab6 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104ab6:	f3 0f 1e fb          	endbr32
80104aba:	55                   	push   %ebp
80104abb:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104abd:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac0:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ac3:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104acf:	8b 45 08             	mov    0x8(%ebp),%eax
80104ad2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104ad9:	90                   	nop
80104ada:	5d                   	pop    %ebp
80104adb:	c3                   	ret

80104adc <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104adc:	f3 0f 1e fb          	endbr32
80104ae0:	55                   	push   %ebp
80104ae1:	89 e5                	mov    %esp,%ebp
80104ae3:	53                   	push   %ebx
80104ae4:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104ae7:	e8 6c 01 00 00       	call   80104c58 <pushcli>
  if(holding(lk)){
80104aec:	8b 45 08             	mov    0x8(%ebp),%eax
80104aef:	83 ec 0c             	sub    $0xc,%esp
80104af2:	50                   	push   %eax
80104af3:	e8 2b 01 00 00       	call   80104c23 <holding>
80104af8:	83 c4 10             	add    $0x10,%esp
80104afb:	85 c0                	test   %eax,%eax
80104afd:	74 0d                	je     80104b0c <acquire+0x30>
    panic("acquire");
80104aff:	83 ec 0c             	sub    $0xc,%esp
80104b02:	68 4e ab 10 80       	push   $0x8010ab4e
80104b07:	e8 d2 ba ff ff       	call   801005de <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104b0c:	90                   	nop
80104b0d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b10:	83 ec 08             	sub    $0x8,%esp
80104b13:	6a 01                	push   $0x1
80104b15:	50                   	push   %eax
80104b16:	e8 81 ff ff ff       	call   80104a9c <xchg>
80104b1b:	83 c4 10             	add    $0x10,%esp
80104b1e:	85 c0                	test   %eax,%eax
80104b20:	75 eb                	jne    80104b0d <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104b22:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104b27:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104b2a:	e8 54 f0 ff ff       	call   80103b83 <mycpu>
80104b2f:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104b32:	8b 45 08             	mov    0x8(%ebp),%eax
80104b35:	83 c0 0c             	add    $0xc,%eax
80104b38:	83 ec 08             	sub    $0x8,%esp
80104b3b:	50                   	push   %eax
80104b3c:	8d 45 08             	lea    0x8(%ebp),%eax
80104b3f:	50                   	push   %eax
80104b40:	e8 5f 00 00 00       	call   80104ba4 <getcallerpcs>
80104b45:	83 c4 10             	add    $0x10,%esp
}
80104b48:	90                   	nop
80104b49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b4c:	c9                   	leave
80104b4d:	c3                   	ret

80104b4e <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104b4e:	f3 0f 1e fb          	endbr32
80104b52:	55                   	push   %ebp
80104b53:	89 e5                	mov    %esp,%ebp
80104b55:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104b58:	83 ec 0c             	sub    $0xc,%esp
80104b5b:	ff 75 08             	push   0x8(%ebp)
80104b5e:	e8 c0 00 00 00       	call   80104c23 <holding>
80104b63:	83 c4 10             	add    $0x10,%esp
80104b66:	85 c0                	test   %eax,%eax
80104b68:	75 0d                	jne    80104b77 <release+0x29>
    panic("release");
80104b6a:	83 ec 0c             	sub    $0xc,%esp
80104b6d:	68 56 ab 10 80       	push   $0x8010ab56
80104b72:	e8 67 ba ff ff       	call   801005de <panic>

  lk->pcs[0] = 0;
80104b77:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104b81:	8b 45 08             	mov    0x8(%ebp),%eax
80104b84:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104b8b:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104b90:	8b 45 08             	mov    0x8(%ebp),%eax
80104b93:	8b 55 08             	mov    0x8(%ebp),%edx
80104b96:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104b9c:	e8 08 01 00 00       	call   80104ca9 <popcli>
}
80104ba1:	90                   	nop
80104ba2:	c9                   	leave
80104ba3:	c3                   	ret

80104ba4 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104ba4:	f3 0f 1e fb          	endbr32
80104ba8:	55                   	push   %ebp
80104ba9:	89 e5                	mov    %esp,%ebp
80104bab:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104bae:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb1:	83 e8 08             	sub    $0x8,%eax
80104bb4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104bb7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104bbe:	eb 38                	jmp    80104bf8 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104bc0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104bc4:	74 53                	je     80104c19 <getcallerpcs+0x75>
80104bc6:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104bcd:	76 4a                	jbe    80104c19 <getcallerpcs+0x75>
80104bcf:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104bd3:	74 44                	je     80104c19 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104bd5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bd8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104be2:	01 c2                	add    %eax,%edx
80104be4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104be7:	8b 40 04             	mov    0x4(%eax),%eax
80104bea:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104bec:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bef:	8b 00                	mov    (%eax),%eax
80104bf1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104bf4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104bf8:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104bfc:	7e c2                	jle    80104bc0 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80104bfe:	eb 19                	jmp    80104c19 <getcallerpcs+0x75>
    pcs[i] = 0;
80104c00:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c03:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c0d:	01 d0                	add    %edx,%eax
80104c0f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104c15:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c19:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c1d:	7e e1                	jle    80104c00 <getcallerpcs+0x5c>
}
80104c1f:	90                   	nop
80104c20:	90                   	nop
80104c21:	c9                   	leave
80104c22:	c3                   	ret

80104c23 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104c23:	f3 0f 1e fb          	endbr32
80104c27:	55                   	push   %ebp
80104c28:	89 e5                	mov    %esp,%ebp
80104c2a:	53                   	push   %ebx
80104c2b:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c31:	8b 00                	mov    (%eax),%eax
80104c33:	85 c0                	test   %eax,%eax
80104c35:	74 16                	je     80104c4d <holding+0x2a>
80104c37:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3a:	8b 58 08             	mov    0x8(%eax),%ebx
80104c3d:	e8 41 ef ff ff       	call   80103b83 <mycpu>
80104c42:	39 c3                	cmp    %eax,%ebx
80104c44:	75 07                	jne    80104c4d <holding+0x2a>
80104c46:	b8 01 00 00 00       	mov    $0x1,%eax
80104c4b:	eb 05                	jmp    80104c52 <holding+0x2f>
80104c4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c52:	83 c4 04             	add    $0x4,%esp
80104c55:	5b                   	pop    %ebx
80104c56:	5d                   	pop    %ebp
80104c57:	c3                   	ret

80104c58 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104c58:	f3 0f 1e fb          	endbr32
80104c5c:	55                   	push   %ebp
80104c5d:	89 e5                	mov    %esp,%ebp
80104c5f:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104c62:	e8 17 fe ff ff       	call   80104a7e <readeflags>
80104c67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104c6a:	e8 1f fe ff ff       	call   80104a8e <cli>
  if(mycpu()->ncli == 0)
80104c6f:	e8 0f ef ff ff       	call   80103b83 <mycpu>
80104c74:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104c7a:	85 c0                	test   %eax,%eax
80104c7c:	75 14                	jne    80104c92 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104c7e:	e8 00 ef ff ff       	call   80103b83 <mycpu>
80104c83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c86:	81 e2 00 02 00 00    	and    $0x200,%edx
80104c8c:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104c92:	e8 ec ee ff ff       	call   80103b83 <mycpu>
80104c97:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104c9d:	83 c2 01             	add    $0x1,%edx
80104ca0:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104ca6:	90                   	nop
80104ca7:	c9                   	leave
80104ca8:	c3                   	ret

80104ca9 <popcli>:

void
popcli(void)
{
80104ca9:	f3 0f 1e fb          	endbr32
80104cad:	55                   	push   %ebp
80104cae:	89 e5                	mov    %esp,%ebp
80104cb0:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104cb3:	e8 c6 fd ff ff       	call   80104a7e <readeflags>
80104cb8:	25 00 02 00 00       	and    $0x200,%eax
80104cbd:	85 c0                	test   %eax,%eax
80104cbf:	74 0d                	je     80104cce <popcli+0x25>
    panic("popcli - interruptible");
80104cc1:	83 ec 0c             	sub    $0xc,%esp
80104cc4:	68 5e ab 10 80       	push   $0x8010ab5e
80104cc9:	e8 10 b9 ff ff       	call   801005de <panic>
  if(--mycpu()->ncli < 0)
80104cce:	e8 b0 ee ff ff       	call   80103b83 <mycpu>
80104cd3:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104cd9:	83 ea 01             	sub    $0x1,%edx
80104cdc:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104ce2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ce8:	85 c0                	test   %eax,%eax
80104cea:	79 0d                	jns    80104cf9 <popcli+0x50>
    panic("popcli");
80104cec:	83 ec 0c             	sub    $0xc,%esp
80104cef:	68 75 ab 10 80       	push   $0x8010ab75
80104cf4:	e8 e5 b8 ff ff       	call   801005de <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104cf9:	e8 85 ee ff ff       	call   80103b83 <mycpu>
80104cfe:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d04:	85 c0                	test   %eax,%eax
80104d06:	75 14                	jne    80104d1c <popcli+0x73>
80104d08:	e8 76 ee ff ff       	call   80103b83 <mycpu>
80104d0d:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104d13:	85 c0                	test   %eax,%eax
80104d15:	74 05                	je     80104d1c <popcli+0x73>
    sti();
80104d17:	e8 79 fd ff ff       	call   80104a95 <sti>
}
80104d1c:	90                   	nop
80104d1d:	c9                   	leave
80104d1e:	c3                   	ret

80104d1f <stosb>:
{
80104d1f:	55                   	push   %ebp
80104d20:	89 e5                	mov    %esp,%ebp
80104d22:	57                   	push   %edi
80104d23:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104d24:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d27:	8b 55 10             	mov    0x10(%ebp),%edx
80104d2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d2d:	89 cb                	mov    %ecx,%ebx
80104d2f:	89 df                	mov    %ebx,%edi
80104d31:	89 d1                	mov    %edx,%ecx
80104d33:	fc                   	cld
80104d34:	f3 aa                	rep stos %al,%es:(%edi)
80104d36:	89 ca                	mov    %ecx,%edx
80104d38:	89 fb                	mov    %edi,%ebx
80104d3a:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d3d:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d40:	90                   	nop
80104d41:	5b                   	pop    %ebx
80104d42:	5f                   	pop    %edi
80104d43:	5d                   	pop    %ebp
80104d44:	c3                   	ret

80104d45 <stosl>:
{
80104d45:	55                   	push   %ebp
80104d46:	89 e5                	mov    %esp,%ebp
80104d48:	57                   	push   %edi
80104d49:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104d4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d4d:	8b 55 10             	mov    0x10(%ebp),%edx
80104d50:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d53:	89 cb                	mov    %ecx,%ebx
80104d55:	89 df                	mov    %ebx,%edi
80104d57:	89 d1                	mov    %edx,%ecx
80104d59:	fc                   	cld
80104d5a:	f3 ab                	rep stos %eax,%es:(%edi)
80104d5c:	89 ca                	mov    %ecx,%edx
80104d5e:	89 fb                	mov    %edi,%ebx
80104d60:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d63:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d66:	90                   	nop
80104d67:	5b                   	pop    %ebx
80104d68:	5f                   	pop    %edi
80104d69:	5d                   	pop    %ebp
80104d6a:	c3                   	ret

80104d6b <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104d6b:	f3 0f 1e fb          	endbr32
80104d6f:	55                   	push   %ebp
80104d70:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104d72:	8b 45 08             	mov    0x8(%ebp),%eax
80104d75:	83 e0 03             	and    $0x3,%eax
80104d78:	85 c0                	test   %eax,%eax
80104d7a:	75 43                	jne    80104dbf <memset+0x54>
80104d7c:	8b 45 10             	mov    0x10(%ebp),%eax
80104d7f:	83 e0 03             	and    $0x3,%eax
80104d82:	85 c0                	test   %eax,%eax
80104d84:	75 39                	jne    80104dbf <memset+0x54>
    c &= 0xFF;
80104d86:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104d8d:	8b 45 10             	mov    0x10(%ebp),%eax
80104d90:	c1 e8 02             	shr    $0x2,%eax
80104d93:	89 c1                	mov    %eax,%ecx
80104d95:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d98:	c1 e0 18             	shl    $0x18,%eax
80104d9b:	89 c2                	mov    %eax,%edx
80104d9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104da0:	c1 e0 10             	shl    $0x10,%eax
80104da3:	09 c2                	or     %eax,%edx
80104da5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104da8:	c1 e0 08             	shl    $0x8,%eax
80104dab:	09 d0                	or     %edx,%eax
80104dad:	0b 45 0c             	or     0xc(%ebp),%eax
80104db0:	51                   	push   %ecx
80104db1:	50                   	push   %eax
80104db2:	ff 75 08             	push   0x8(%ebp)
80104db5:	e8 8b ff ff ff       	call   80104d45 <stosl>
80104dba:	83 c4 0c             	add    $0xc,%esp
80104dbd:	eb 12                	jmp    80104dd1 <memset+0x66>
  } else
    stosb(dst, c, n);
80104dbf:	8b 45 10             	mov    0x10(%ebp),%eax
80104dc2:	50                   	push   %eax
80104dc3:	ff 75 0c             	push   0xc(%ebp)
80104dc6:	ff 75 08             	push   0x8(%ebp)
80104dc9:	e8 51 ff ff ff       	call   80104d1f <stosb>
80104dce:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104dd1:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104dd4:	c9                   	leave
80104dd5:	c3                   	ret

80104dd6 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104dd6:	f3 0f 1e fb          	endbr32
80104dda:	55                   	push   %ebp
80104ddb:	89 e5                	mov    %esp,%ebp
80104ddd:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104de0:	8b 45 08             	mov    0x8(%ebp),%eax
80104de3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104de6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104de9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104dec:	eb 30                	jmp    80104e1e <memcmp+0x48>
    if(*s1 != *s2)
80104dee:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104df1:	0f b6 10             	movzbl (%eax),%edx
80104df4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104df7:	0f b6 00             	movzbl (%eax),%eax
80104dfa:	38 c2                	cmp    %al,%dl
80104dfc:	74 18                	je     80104e16 <memcmp+0x40>
      return *s1 - *s2;
80104dfe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e01:	0f b6 00             	movzbl (%eax),%eax
80104e04:	0f b6 d0             	movzbl %al,%edx
80104e07:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e0a:	0f b6 00             	movzbl (%eax),%eax
80104e0d:	0f b6 c0             	movzbl %al,%eax
80104e10:	29 c2                	sub    %eax,%edx
80104e12:	89 d0                	mov    %edx,%eax
80104e14:	eb 1a                	jmp    80104e30 <memcmp+0x5a>
    s1++, s2++;
80104e16:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104e1a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104e1e:	8b 45 10             	mov    0x10(%ebp),%eax
80104e21:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e24:	89 55 10             	mov    %edx,0x10(%ebp)
80104e27:	85 c0                	test   %eax,%eax
80104e29:	75 c3                	jne    80104dee <memcmp+0x18>
  }

  return 0;
80104e2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e30:	c9                   	leave
80104e31:	c3                   	ret

80104e32 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104e32:	f3 0f 1e fb          	endbr32
80104e36:	55                   	push   %ebp
80104e37:	89 e5                	mov    %esp,%ebp
80104e39:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104e3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e3f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104e42:	8b 45 08             	mov    0x8(%ebp),%eax
80104e45:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104e48:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e4b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e4e:	73 54                	jae    80104ea4 <memmove+0x72>
80104e50:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e53:	8b 45 10             	mov    0x10(%ebp),%eax
80104e56:	01 d0                	add    %edx,%eax
80104e58:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104e5b:	73 47                	jae    80104ea4 <memmove+0x72>
    s += n;
80104e5d:	8b 45 10             	mov    0x10(%ebp),%eax
80104e60:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104e63:	8b 45 10             	mov    0x10(%ebp),%eax
80104e66:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104e69:	eb 13                	jmp    80104e7e <memmove+0x4c>
      *--d = *--s;
80104e6b:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104e6f:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104e73:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e76:	0f b6 10             	movzbl (%eax),%edx
80104e79:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e7c:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104e7e:	8b 45 10             	mov    0x10(%ebp),%eax
80104e81:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e84:	89 55 10             	mov    %edx,0x10(%ebp)
80104e87:	85 c0                	test   %eax,%eax
80104e89:	75 e0                	jne    80104e6b <memmove+0x39>
  if(s < d && s + n > d){
80104e8b:	eb 24                	jmp    80104eb1 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104e8d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e90:	8d 42 01             	lea    0x1(%edx),%eax
80104e93:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104e96:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e99:	8d 48 01             	lea    0x1(%eax),%ecx
80104e9c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104e9f:	0f b6 12             	movzbl (%edx),%edx
80104ea2:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104ea4:	8b 45 10             	mov    0x10(%ebp),%eax
80104ea7:	8d 50 ff             	lea    -0x1(%eax),%edx
80104eaa:	89 55 10             	mov    %edx,0x10(%ebp)
80104ead:	85 c0                	test   %eax,%eax
80104eaf:	75 dc                	jne    80104e8d <memmove+0x5b>

  return dst;
80104eb1:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104eb4:	c9                   	leave
80104eb5:	c3                   	ret

80104eb6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104eb6:	f3 0f 1e fb          	endbr32
80104eba:	55                   	push   %ebp
80104ebb:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104ebd:	ff 75 10             	push   0x10(%ebp)
80104ec0:	ff 75 0c             	push   0xc(%ebp)
80104ec3:	ff 75 08             	push   0x8(%ebp)
80104ec6:	e8 67 ff ff ff       	call   80104e32 <memmove>
80104ecb:	83 c4 0c             	add    $0xc,%esp
}
80104ece:	c9                   	leave
80104ecf:	c3                   	ret

80104ed0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104ed0:	f3 0f 1e fb          	endbr32
80104ed4:	55                   	push   %ebp
80104ed5:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104ed7:	eb 0c                	jmp    80104ee5 <strncmp+0x15>
    n--, p++, q++;
80104ed9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104edd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104ee1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104ee5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ee9:	74 1a                	je     80104f05 <strncmp+0x35>
80104eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80104eee:	0f b6 00             	movzbl (%eax),%eax
80104ef1:	84 c0                	test   %al,%al
80104ef3:	74 10                	je     80104f05 <strncmp+0x35>
80104ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef8:	0f b6 10             	movzbl (%eax),%edx
80104efb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104efe:	0f b6 00             	movzbl (%eax),%eax
80104f01:	38 c2                	cmp    %al,%dl
80104f03:	74 d4                	je     80104ed9 <strncmp+0x9>
  if(n == 0)
80104f05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f09:	75 07                	jne    80104f12 <strncmp+0x42>
    return 0;
80104f0b:	b8 00 00 00 00       	mov    $0x0,%eax
80104f10:	eb 16                	jmp    80104f28 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80104f12:	8b 45 08             	mov    0x8(%ebp),%eax
80104f15:	0f b6 00             	movzbl (%eax),%eax
80104f18:	0f b6 d0             	movzbl %al,%edx
80104f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f1e:	0f b6 00             	movzbl (%eax),%eax
80104f21:	0f b6 c0             	movzbl %al,%eax
80104f24:	29 c2                	sub    %eax,%edx
80104f26:	89 d0                	mov    %edx,%eax
}
80104f28:	5d                   	pop    %ebp
80104f29:	c3                   	ret

80104f2a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104f2a:	f3 0f 1e fb          	endbr32
80104f2e:	55                   	push   %ebp
80104f2f:	89 e5                	mov    %esp,%ebp
80104f31:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f34:	8b 45 08             	mov    0x8(%ebp),%eax
80104f37:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104f3a:	90                   	nop
80104f3b:	8b 45 10             	mov    0x10(%ebp),%eax
80104f3e:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f41:	89 55 10             	mov    %edx,0x10(%ebp)
80104f44:	85 c0                	test   %eax,%eax
80104f46:	7e 2c                	jle    80104f74 <strncpy+0x4a>
80104f48:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f4b:	8d 42 01             	lea    0x1(%edx),%eax
80104f4e:	89 45 0c             	mov    %eax,0xc(%ebp)
80104f51:	8b 45 08             	mov    0x8(%ebp),%eax
80104f54:	8d 48 01             	lea    0x1(%eax),%ecx
80104f57:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104f5a:	0f b6 12             	movzbl (%edx),%edx
80104f5d:	88 10                	mov    %dl,(%eax)
80104f5f:	0f b6 00             	movzbl (%eax),%eax
80104f62:	84 c0                	test   %al,%al
80104f64:	75 d5                	jne    80104f3b <strncpy+0x11>
    ;
  while(n-- > 0)
80104f66:	eb 0c                	jmp    80104f74 <strncpy+0x4a>
    *s++ = 0;
80104f68:	8b 45 08             	mov    0x8(%ebp),%eax
80104f6b:	8d 50 01             	lea    0x1(%eax),%edx
80104f6e:	89 55 08             	mov    %edx,0x8(%ebp)
80104f71:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104f74:	8b 45 10             	mov    0x10(%ebp),%eax
80104f77:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f7a:	89 55 10             	mov    %edx,0x10(%ebp)
80104f7d:	85 c0                	test   %eax,%eax
80104f7f:	7f e7                	jg     80104f68 <strncpy+0x3e>
  return os;
80104f81:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f84:	c9                   	leave
80104f85:	c3                   	ret

80104f86 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104f86:	f3 0f 1e fb          	endbr32
80104f8a:	55                   	push   %ebp
80104f8b:	89 e5                	mov    %esp,%ebp
80104f8d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f90:	8b 45 08             	mov    0x8(%ebp),%eax
80104f93:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104f96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f9a:	7f 05                	jg     80104fa1 <safestrcpy+0x1b>
    return os;
80104f9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f9f:	eb 31                	jmp    80104fd2 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80104fa1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104fa5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fa9:	7e 1e                	jle    80104fc9 <safestrcpy+0x43>
80104fab:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fae:	8d 42 01             	lea    0x1(%edx),%eax
80104fb1:	89 45 0c             	mov    %eax,0xc(%ebp)
80104fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb7:	8d 48 01             	lea    0x1(%eax),%ecx
80104fba:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104fbd:	0f b6 12             	movzbl (%edx),%edx
80104fc0:	88 10                	mov    %dl,(%eax)
80104fc2:	0f b6 00             	movzbl (%eax),%eax
80104fc5:	84 c0                	test   %al,%al
80104fc7:	75 d8                	jne    80104fa1 <safestrcpy+0x1b>
    ;
  *s = 0;
80104fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80104fcc:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104fcf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fd2:	c9                   	leave
80104fd3:	c3                   	ret

80104fd4 <strlen>:

int
strlen(const char *s)
{
80104fd4:	f3 0f 1e fb          	endbr32
80104fd8:	55                   	push   %ebp
80104fd9:	89 e5                	mov    %esp,%ebp
80104fdb:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104fde:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104fe5:	eb 04                	jmp    80104feb <strlen+0x17>
80104fe7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104feb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104fee:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff1:	01 d0                	add    %edx,%eax
80104ff3:	0f b6 00             	movzbl (%eax),%eax
80104ff6:	84 c0                	test   %al,%al
80104ff8:	75 ed                	jne    80104fe7 <strlen+0x13>
    ;
  return n;
80104ffa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ffd:	c9                   	leave
80104ffe:	c3                   	ret

80104fff <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104fff:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105003:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105007:	55                   	push   %ebp
  pushl %ebx
80105008:	53                   	push   %ebx
  pushl %esi
80105009:	56                   	push   %esi
  pushl %edi
8010500a:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010500b:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010500d:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010500f:	5f                   	pop    %edi
  popl %esi
80105010:	5e                   	pop    %esi
  popl %ebx
80105011:	5b                   	pop    %ebx
  popl %ebp
80105012:	5d                   	pop    %ebp
  ret
80105013:	c3                   	ret

80105014 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105014:	f3 0f 1e fb          	endbr32
80105018:	55                   	push   %ebp
80105019:	89 e5                	mov    %esp,%ebp

  if(addr >= KERNBASE || addr+4 >= KERNBASE)
8010501b:	8b 45 08             	mov    0x8(%ebp),%eax
8010501e:	85 c0                	test   %eax,%eax
80105020:	78 0a                	js     8010502c <fetchint+0x18>
80105022:	8b 45 08             	mov    0x8(%ebp),%eax
80105025:	83 c0 04             	add    $0x4,%eax
80105028:	85 c0                	test   %eax,%eax
8010502a:	79 07                	jns    80105033 <fetchint+0x1f>
    return -1;
8010502c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105031:	eb 0f                	jmp    80105042 <fetchint+0x2e>
  *ip = *(int*)(addr);
80105033:	8b 45 08             	mov    0x8(%ebp),%eax
80105036:	8b 10                	mov    (%eax),%edx
80105038:	8b 45 0c             	mov    0xc(%ebp),%eax
8010503b:	89 10                	mov    %edx,(%eax)
  return 0;
8010503d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105042:	5d                   	pop    %ebp
80105043:	c3                   	ret

80105044 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105044:	f3 0f 1e fb          	endbr32
80105048:	55                   	push   %ebp
80105049:	89 e5                	mov    %esp,%ebp
8010504b:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= KERNBASE)
8010504e:	8b 45 08             	mov    0x8(%ebp),%eax
80105051:	85 c0                	test   %eax,%eax
80105053:	79 07                	jns    8010505c <fetchstr+0x18>
    return -1;
80105055:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010505a:	eb 42                	jmp    8010509e <fetchstr+0x5a>
  *pp = (char*)addr;
8010505c:	8b 55 08             	mov    0x8(%ebp),%edx
8010505f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105062:	89 10                	mov    %edx,(%eax)
  ep = (char*)(KERNBASE-1);
80105064:	c7 45 f8 ff ff ff 7f 	movl   $0x7fffffff,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
8010506b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010506e:	8b 00                	mov    (%eax),%eax
80105070:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105073:	eb 1c                	jmp    80105091 <fetchstr+0x4d>
    if(*s == 0)
80105075:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105078:	0f b6 00             	movzbl (%eax),%eax
8010507b:	84 c0                	test   %al,%al
8010507d:	75 0e                	jne    8010508d <fetchstr+0x49>
      return s - *pp;
8010507f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105082:	8b 00                	mov    (%eax),%eax
80105084:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105087:	29 c2                	sub    %eax,%edx
80105089:	89 d0                	mov    %edx,%eax
8010508b:	eb 11                	jmp    8010509e <fetchstr+0x5a>
  for(s = *pp; s < ep; s++){
8010508d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105091:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105094:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105097:	72 dc                	jb     80105075 <fetchstr+0x31>
  }
  return -1;
80105099:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010509e:	c9                   	leave
8010509f:	c3                   	ret

801050a0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801050a0:	f3 0f 1e fb          	endbr32
801050a4:	55                   	push   %ebp
801050a5:	89 e5                	mov    %esp,%ebp
801050a7:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801050aa:	e8 50 eb ff ff       	call   80103bff <myproc>
801050af:	8b 40 18             	mov    0x18(%eax),%eax
801050b2:	8b 40 44             	mov    0x44(%eax),%eax
801050b5:	8b 55 08             	mov    0x8(%ebp),%edx
801050b8:	c1 e2 02             	shl    $0x2,%edx
801050bb:	01 d0                	add    %edx,%eax
801050bd:	83 c0 04             	add    $0x4,%eax
801050c0:	83 ec 08             	sub    $0x8,%esp
801050c3:	ff 75 0c             	push   0xc(%ebp)
801050c6:	50                   	push   %eax
801050c7:	e8 48 ff ff ff       	call   80105014 <fetchint>
801050cc:	83 c4 10             	add    $0x10,%esp
}
801050cf:	c9                   	leave
801050d0:	c3                   	ret

801050d1 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801050d1:	f3 0f 1e fb          	endbr32
801050d5:	55                   	push   %ebp
801050d6:	89 e5                	mov    %esp,%ebp
801050d8:	83 ec 18             	sub    $0x18,%esp
  int i;
 
  if(argint(n, &i) < 0)
801050db:	83 ec 08             	sub    $0x8,%esp
801050de:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050e1:	50                   	push   %eax
801050e2:	ff 75 08             	push   0x8(%ebp)
801050e5:	e8 b6 ff ff ff       	call   801050a0 <argint>
801050ea:	83 c4 10             	add    $0x10,%esp
801050ed:	85 c0                	test   %eax,%eax
801050ef:	79 07                	jns    801050f8 <argptr+0x27>
    return -1;
801050f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050f6:	eb 34                	jmp    8010512c <argptr+0x5b>
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
801050f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801050fc:	78 18                	js     80105116 <argptr+0x45>
801050fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105101:	85 c0                	test   %eax,%eax
80105103:	78 11                	js     80105116 <argptr+0x45>
80105105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105108:	89 c2                	mov    %eax,%edx
8010510a:	8b 45 10             	mov    0x10(%ebp),%eax
8010510d:	01 d0                	add    %edx,%eax
8010510f:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80105114:	76 07                	jbe    8010511d <argptr+0x4c>
    return -1;
80105116:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010511b:	eb 0f                	jmp    8010512c <argptr+0x5b>
  *pp = (char*)i;
8010511d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105120:	89 c2                	mov    %eax,%edx
80105122:	8b 45 0c             	mov    0xc(%ebp),%eax
80105125:	89 10                	mov    %edx,(%eax)
  return 0;
80105127:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010512c:	c9                   	leave
8010512d:	c3                   	ret

8010512e <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010512e:	f3 0f 1e fb          	endbr32
80105132:	55                   	push   %ebp
80105133:	89 e5                	mov    %esp,%ebp
80105135:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105138:	83 ec 08             	sub    $0x8,%esp
8010513b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010513e:	50                   	push   %eax
8010513f:	ff 75 08             	push   0x8(%ebp)
80105142:	e8 59 ff ff ff       	call   801050a0 <argint>
80105147:	83 c4 10             	add    $0x10,%esp
8010514a:	85 c0                	test   %eax,%eax
8010514c:	79 07                	jns    80105155 <argstr+0x27>
    return -1;
8010514e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105153:	eb 12                	jmp    80105167 <argstr+0x39>
  return fetchstr(addr, pp);
80105155:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105158:	83 ec 08             	sub    $0x8,%esp
8010515b:	ff 75 0c             	push   0xc(%ebp)
8010515e:	50                   	push   %eax
8010515f:	e8 e0 fe ff ff       	call   80105044 <fetchstr>
80105164:	83 c4 10             	add    $0x10,%esp
}
80105167:	c9                   	leave
80105168:	c3                   	ret

80105169 <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80105169:	f3 0f 1e fb          	endbr32
8010516d:	55                   	push   %ebp
8010516e:	89 e5                	mov    %esp,%ebp
80105170:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105173:	e8 87 ea ff ff       	call   80103bff <myproc>
80105178:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010517b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010517e:	8b 40 18             	mov    0x18(%eax),%eax
80105181:	8b 40 1c             	mov    0x1c(%eax),%eax
80105184:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105187:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010518b:	7e 2f                	jle    801051bc <syscall+0x53>
8010518d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105190:	83 f8 17             	cmp    $0x17,%eax
80105193:	77 27                	ja     801051bc <syscall+0x53>
80105195:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105198:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010519f:	85 c0                	test   %eax,%eax
801051a1:	74 19                	je     801051bc <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
801051a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051a6:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801051ad:	ff d0                	call   *%eax
801051af:	89 c2                	mov    %eax,%edx
801051b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b4:	8b 40 18             	mov    0x18(%eax),%eax
801051b7:	89 50 1c             	mov    %edx,0x1c(%eax)
801051ba:	eb 2c                	jmp    801051e8 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801051bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051bf:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801051c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051c5:	8b 40 10             	mov    0x10(%eax),%eax
801051c8:	ff 75 f0             	push   -0x10(%ebp)
801051cb:	52                   	push   %edx
801051cc:	50                   	push   %eax
801051cd:	68 7c ab 10 80       	push   $0x8010ab7c
801051d2:	e8 35 b2 ff ff       	call   8010040c <cprintf>
801051d7:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801051da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051dd:	8b 40 18             	mov    0x18(%eax),%eax
801051e0:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801051e7:	90                   	nop
801051e8:	90                   	nop
801051e9:	c9                   	leave
801051ea:	c3                   	ret

801051eb <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801051eb:	f3 0f 1e fb          	endbr32
801051ef:	55                   	push   %ebp
801051f0:	89 e5                	mov    %esp,%ebp
801051f2:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801051f5:	83 ec 08             	sub    $0x8,%esp
801051f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051fb:	50                   	push   %eax
801051fc:	ff 75 08             	push   0x8(%ebp)
801051ff:	e8 9c fe ff ff       	call   801050a0 <argint>
80105204:	83 c4 10             	add    $0x10,%esp
80105207:	85 c0                	test   %eax,%eax
80105209:	79 07                	jns    80105212 <argfd+0x27>
    return -1;
8010520b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105210:	eb 4f                	jmp    80105261 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105212:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105215:	85 c0                	test   %eax,%eax
80105217:	78 20                	js     80105239 <argfd+0x4e>
80105219:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010521c:	83 f8 0f             	cmp    $0xf,%eax
8010521f:	7f 18                	jg     80105239 <argfd+0x4e>
80105221:	e8 d9 e9 ff ff       	call   80103bff <myproc>
80105226:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105229:	83 c2 08             	add    $0x8,%edx
8010522c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105230:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105233:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105237:	75 07                	jne    80105240 <argfd+0x55>
    return -1;
80105239:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010523e:	eb 21                	jmp    80105261 <argfd+0x76>
  if(pfd)
80105240:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105244:	74 08                	je     8010524e <argfd+0x63>
    *pfd = fd;
80105246:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105249:	8b 45 0c             	mov    0xc(%ebp),%eax
8010524c:	89 10                	mov    %edx,(%eax)
  if(pf)
8010524e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105252:	74 08                	je     8010525c <argfd+0x71>
    *pf = f;
80105254:	8b 45 10             	mov    0x10(%ebp),%eax
80105257:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010525a:	89 10                	mov    %edx,(%eax)
  return 0;
8010525c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105261:	c9                   	leave
80105262:	c3                   	ret

80105263 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105263:	f3 0f 1e fb          	endbr32
80105267:	55                   	push   %ebp
80105268:	89 e5                	mov    %esp,%ebp
8010526a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010526d:	e8 8d e9 ff ff       	call   80103bff <myproc>
80105272:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105275:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010527c:	eb 2a                	jmp    801052a8 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
8010527e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105281:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105284:	83 c2 08             	add    $0x8,%edx
80105287:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010528b:	85 c0                	test   %eax,%eax
8010528d:	75 15                	jne    801052a4 <fdalloc+0x41>
      curproc->ofile[fd] = f;
8010528f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105292:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105295:	8d 4a 08             	lea    0x8(%edx),%ecx
80105298:	8b 55 08             	mov    0x8(%ebp),%edx
8010529b:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010529f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a2:	eb 0f                	jmp    801052b3 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
801052a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801052a8:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801052ac:	7e d0                	jle    8010527e <fdalloc+0x1b>
    }
  }
  return -1;
801052ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052b3:	c9                   	leave
801052b4:	c3                   	ret

801052b5 <sys_dup>:

int
sys_dup(void)
{
801052b5:	f3 0f 1e fb          	endbr32
801052b9:	55                   	push   %ebp
801052ba:	89 e5                	mov    %esp,%ebp
801052bc:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801052bf:	83 ec 04             	sub    $0x4,%esp
801052c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052c5:	50                   	push   %eax
801052c6:	6a 00                	push   $0x0
801052c8:	6a 00                	push   $0x0
801052ca:	e8 1c ff ff ff       	call   801051eb <argfd>
801052cf:	83 c4 10             	add    $0x10,%esp
801052d2:	85 c0                	test   %eax,%eax
801052d4:	79 07                	jns    801052dd <sys_dup+0x28>
    return -1;
801052d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052db:	eb 31                	jmp    8010530e <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
801052dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052e0:	83 ec 0c             	sub    $0xc,%esp
801052e3:	50                   	push   %eax
801052e4:	e8 7a ff ff ff       	call   80105263 <fdalloc>
801052e9:	83 c4 10             	add    $0x10,%esp
801052ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052f3:	79 07                	jns    801052fc <sys_dup+0x47>
    return -1;
801052f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052fa:	eb 12                	jmp    8010530e <sys_dup+0x59>
  filedup(f);
801052fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052ff:	83 ec 0c             	sub    $0xc,%esp
80105302:	50                   	push   %eax
80105303:	e8 e2 bd ff ff       	call   801010ea <filedup>
80105308:	83 c4 10             	add    $0x10,%esp
  return fd;
8010530b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010530e:	c9                   	leave
8010530f:	c3                   	ret

80105310 <sys_read>:

int
sys_read(void)
{
80105310:	f3 0f 1e fb          	endbr32
80105314:	55                   	push   %ebp
80105315:	89 e5                	mov    %esp,%ebp
80105317:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010531a:	83 ec 04             	sub    $0x4,%esp
8010531d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105320:	50                   	push   %eax
80105321:	6a 00                	push   $0x0
80105323:	6a 00                	push   $0x0
80105325:	e8 c1 fe ff ff       	call   801051eb <argfd>
8010532a:	83 c4 10             	add    $0x10,%esp
8010532d:	85 c0                	test   %eax,%eax
8010532f:	78 2e                	js     8010535f <sys_read+0x4f>
80105331:	83 ec 08             	sub    $0x8,%esp
80105334:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105337:	50                   	push   %eax
80105338:	6a 02                	push   $0x2
8010533a:	e8 61 fd ff ff       	call   801050a0 <argint>
8010533f:	83 c4 10             	add    $0x10,%esp
80105342:	85 c0                	test   %eax,%eax
80105344:	78 19                	js     8010535f <sys_read+0x4f>
80105346:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105349:	83 ec 04             	sub    $0x4,%esp
8010534c:	50                   	push   %eax
8010534d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105350:	50                   	push   %eax
80105351:	6a 01                	push   $0x1
80105353:	e8 79 fd ff ff       	call   801050d1 <argptr>
80105358:	83 c4 10             	add    $0x10,%esp
8010535b:	85 c0                	test   %eax,%eax
8010535d:	79 07                	jns    80105366 <sys_read+0x56>
    return -1;
8010535f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105364:	eb 17                	jmp    8010537d <sys_read+0x6d>
  return fileread(f, p, n);
80105366:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105369:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010536c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010536f:	83 ec 04             	sub    $0x4,%esp
80105372:	51                   	push   %ecx
80105373:	52                   	push   %edx
80105374:	50                   	push   %eax
80105375:	e8 0c bf ff ff       	call   80101286 <fileread>
8010537a:	83 c4 10             	add    $0x10,%esp
}
8010537d:	c9                   	leave
8010537e:	c3                   	ret

8010537f <sys_write>:

int
sys_write(void)
{
8010537f:	f3 0f 1e fb          	endbr32
80105383:	55                   	push   %ebp
80105384:	89 e5                	mov    %esp,%ebp
80105386:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105389:	83 ec 04             	sub    $0x4,%esp
8010538c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010538f:	50                   	push   %eax
80105390:	6a 00                	push   $0x0
80105392:	6a 00                	push   $0x0
80105394:	e8 52 fe ff ff       	call   801051eb <argfd>
80105399:	83 c4 10             	add    $0x10,%esp
8010539c:	85 c0                	test   %eax,%eax
8010539e:	78 2e                	js     801053ce <sys_write+0x4f>
801053a0:	83 ec 08             	sub    $0x8,%esp
801053a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053a6:	50                   	push   %eax
801053a7:	6a 02                	push   $0x2
801053a9:	e8 f2 fc ff ff       	call   801050a0 <argint>
801053ae:	83 c4 10             	add    $0x10,%esp
801053b1:	85 c0                	test   %eax,%eax
801053b3:	78 19                	js     801053ce <sys_write+0x4f>
801053b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053b8:	83 ec 04             	sub    $0x4,%esp
801053bb:	50                   	push   %eax
801053bc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801053bf:	50                   	push   %eax
801053c0:	6a 01                	push   $0x1
801053c2:	e8 0a fd ff ff       	call   801050d1 <argptr>
801053c7:	83 c4 10             	add    $0x10,%esp
801053ca:	85 c0                	test   %eax,%eax
801053cc:	79 07                	jns    801053d5 <sys_write+0x56>
    return -1;
801053ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053d3:	eb 17                	jmp    801053ec <sys_write+0x6d>
  return filewrite(f, p, n);
801053d5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053d8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053de:	83 ec 04             	sub    $0x4,%esp
801053e1:	51                   	push   %ecx
801053e2:	52                   	push   %edx
801053e3:	50                   	push   %eax
801053e4:	e8 59 bf ff ff       	call   80101342 <filewrite>
801053e9:	83 c4 10             	add    $0x10,%esp
}
801053ec:	c9                   	leave
801053ed:	c3                   	ret

801053ee <sys_close>:

int
sys_close(void)
{
801053ee:	f3 0f 1e fb          	endbr32
801053f2:	55                   	push   %ebp
801053f3:	89 e5                	mov    %esp,%ebp
801053f5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801053f8:	83 ec 04             	sub    $0x4,%esp
801053fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053fe:	50                   	push   %eax
801053ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105402:	50                   	push   %eax
80105403:	6a 00                	push   $0x0
80105405:	e8 e1 fd ff ff       	call   801051eb <argfd>
8010540a:	83 c4 10             	add    $0x10,%esp
8010540d:	85 c0                	test   %eax,%eax
8010540f:	79 07                	jns    80105418 <sys_close+0x2a>
    return -1;
80105411:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105416:	eb 27                	jmp    8010543f <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105418:	e8 e2 e7 ff ff       	call   80103bff <myproc>
8010541d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105420:	83 c2 08             	add    $0x8,%edx
80105423:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010542a:	00 
  fileclose(f);
8010542b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010542e:	83 ec 0c             	sub    $0xc,%esp
80105431:	50                   	push   %eax
80105432:	e8 08 bd ff ff       	call   8010113f <fileclose>
80105437:	83 c4 10             	add    $0x10,%esp
  return 0;
8010543a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010543f:	c9                   	leave
80105440:	c3                   	ret

80105441 <sys_fstat>:

int
sys_fstat(void)
{
80105441:	f3 0f 1e fb          	endbr32
80105445:	55                   	push   %ebp
80105446:	89 e5                	mov    %esp,%ebp
80105448:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010544b:	83 ec 04             	sub    $0x4,%esp
8010544e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105451:	50                   	push   %eax
80105452:	6a 00                	push   $0x0
80105454:	6a 00                	push   $0x0
80105456:	e8 90 fd ff ff       	call   801051eb <argfd>
8010545b:	83 c4 10             	add    $0x10,%esp
8010545e:	85 c0                	test   %eax,%eax
80105460:	78 17                	js     80105479 <sys_fstat+0x38>
80105462:	83 ec 04             	sub    $0x4,%esp
80105465:	6a 14                	push   $0x14
80105467:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010546a:	50                   	push   %eax
8010546b:	6a 01                	push   $0x1
8010546d:	e8 5f fc ff ff       	call   801050d1 <argptr>
80105472:	83 c4 10             	add    $0x10,%esp
80105475:	85 c0                	test   %eax,%eax
80105477:	79 07                	jns    80105480 <sys_fstat+0x3f>
    return -1;
80105479:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010547e:	eb 13                	jmp    80105493 <sys_fstat+0x52>
  return filestat(f, st);
80105480:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105486:	83 ec 08             	sub    $0x8,%esp
80105489:	52                   	push   %edx
8010548a:	50                   	push   %eax
8010548b:	e8 9b bd ff ff       	call   8010122b <filestat>
80105490:	83 c4 10             	add    $0x10,%esp
}
80105493:	c9                   	leave
80105494:	c3                   	ret

80105495 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105495:	f3 0f 1e fb          	endbr32
80105499:	55                   	push   %ebp
8010549a:	89 e5                	mov    %esp,%ebp
8010549c:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010549f:	83 ec 08             	sub    $0x8,%esp
801054a2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801054a5:	50                   	push   %eax
801054a6:	6a 00                	push   $0x0
801054a8:	e8 81 fc ff ff       	call   8010512e <argstr>
801054ad:	83 c4 10             	add    $0x10,%esp
801054b0:	85 c0                	test   %eax,%eax
801054b2:	78 15                	js     801054c9 <sys_link+0x34>
801054b4:	83 ec 08             	sub    $0x8,%esp
801054b7:	8d 45 dc             	lea    -0x24(%ebp),%eax
801054ba:	50                   	push   %eax
801054bb:	6a 01                	push   $0x1
801054bd:	e8 6c fc ff ff       	call   8010512e <argstr>
801054c2:	83 c4 10             	add    $0x10,%esp
801054c5:	85 c0                	test   %eax,%eax
801054c7:	79 0a                	jns    801054d3 <sys_link+0x3e>
    return -1;
801054c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054ce:	e9 68 01 00 00       	jmp    8010563b <sys_link+0x1a6>

  begin_op();
801054d3:	e8 ef dc ff ff       	call   801031c7 <begin_op>
  if((ip = namei(old)) == 0){
801054d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801054db:	83 ec 0c             	sub    $0xc,%esp
801054de:	50                   	push   %eax
801054df:	e8 59 d1 ff ff       	call   8010263d <namei>
801054e4:	83 c4 10             	add    $0x10,%esp
801054e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054ee:	75 0f                	jne    801054ff <sys_link+0x6a>
    end_op();
801054f0:	e8 62 dd ff ff       	call   80103257 <end_op>
    return -1;
801054f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054fa:	e9 3c 01 00 00       	jmp    8010563b <sys_link+0x1a6>
  }

  ilock(ip);
801054ff:	83 ec 0c             	sub    $0xc,%esp
80105502:	ff 75 f4             	push   -0xc(%ebp)
80105505:	e8 c8 c5 ff ff       	call   80101ad2 <ilock>
8010550a:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010550d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105510:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105514:	66 83 f8 01          	cmp    $0x1,%ax
80105518:	75 1d                	jne    80105537 <sys_link+0xa2>
    iunlockput(ip);
8010551a:	83 ec 0c             	sub    $0xc,%esp
8010551d:	ff 75 f4             	push   -0xc(%ebp)
80105520:	e8 ea c7 ff ff       	call   80101d0f <iunlockput>
80105525:	83 c4 10             	add    $0x10,%esp
    end_op();
80105528:	e8 2a dd ff ff       	call   80103257 <end_op>
    return -1;
8010552d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105532:	e9 04 01 00 00       	jmp    8010563b <sys_link+0x1a6>
  }

  ip->nlink++;
80105537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010553a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010553e:	83 c0 01             	add    $0x1,%eax
80105541:	89 c2                	mov    %eax,%edx
80105543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105546:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010554a:	83 ec 0c             	sub    $0xc,%esp
8010554d:	ff 75 f4             	push   -0xc(%ebp)
80105550:	e8 94 c3 ff ff       	call   801018e9 <iupdate>
80105555:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105558:	83 ec 0c             	sub    $0xc,%esp
8010555b:	ff 75 f4             	push   -0xc(%ebp)
8010555e:	e8 86 c6 ff ff       	call   80101be9 <iunlock>
80105563:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105566:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105569:	83 ec 08             	sub    $0x8,%esp
8010556c:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010556f:	52                   	push   %edx
80105570:	50                   	push   %eax
80105571:	e8 e7 d0 ff ff       	call   8010265d <nameiparent>
80105576:	83 c4 10             	add    $0x10,%esp
80105579:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010557c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105580:	74 71                	je     801055f3 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105582:	83 ec 0c             	sub    $0xc,%esp
80105585:	ff 75 f0             	push   -0x10(%ebp)
80105588:	e8 45 c5 ff ff       	call   80101ad2 <ilock>
8010558d:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105590:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105593:	8b 10                	mov    (%eax),%edx
80105595:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105598:	8b 00                	mov    (%eax),%eax
8010559a:	39 c2                	cmp    %eax,%edx
8010559c:	75 1d                	jne    801055bb <sys_link+0x126>
8010559e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a1:	8b 40 04             	mov    0x4(%eax),%eax
801055a4:	83 ec 04             	sub    $0x4,%esp
801055a7:	50                   	push   %eax
801055a8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801055ab:	50                   	push   %eax
801055ac:	ff 75 f0             	push   -0x10(%ebp)
801055af:	e8 e6 cd ff ff       	call   8010239a <dirlink>
801055b4:	83 c4 10             	add    $0x10,%esp
801055b7:	85 c0                	test   %eax,%eax
801055b9:	79 10                	jns    801055cb <sys_link+0x136>
    iunlockput(dp);
801055bb:	83 ec 0c             	sub    $0xc,%esp
801055be:	ff 75 f0             	push   -0x10(%ebp)
801055c1:	e8 49 c7 ff ff       	call   80101d0f <iunlockput>
801055c6:	83 c4 10             	add    $0x10,%esp
    goto bad;
801055c9:	eb 29                	jmp    801055f4 <sys_link+0x15f>
  }
  iunlockput(dp);
801055cb:	83 ec 0c             	sub    $0xc,%esp
801055ce:	ff 75 f0             	push   -0x10(%ebp)
801055d1:	e8 39 c7 ff ff       	call   80101d0f <iunlockput>
801055d6:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801055d9:	83 ec 0c             	sub    $0xc,%esp
801055dc:	ff 75 f4             	push   -0xc(%ebp)
801055df:	e8 57 c6 ff ff       	call   80101c3b <iput>
801055e4:	83 c4 10             	add    $0x10,%esp

  end_op();
801055e7:	e8 6b dc ff ff       	call   80103257 <end_op>

  return 0;
801055ec:	b8 00 00 00 00       	mov    $0x0,%eax
801055f1:	eb 48                	jmp    8010563b <sys_link+0x1a6>
    goto bad;
801055f3:	90                   	nop

bad:
  ilock(ip);
801055f4:	83 ec 0c             	sub    $0xc,%esp
801055f7:	ff 75 f4             	push   -0xc(%ebp)
801055fa:	e8 d3 c4 ff ff       	call   80101ad2 <ilock>
801055ff:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105605:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105609:	83 e8 01             	sub    $0x1,%eax
8010560c:	89 c2                	mov    %eax,%edx
8010560e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105611:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105615:	83 ec 0c             	sub    $0xc,%esp
80105618:	ff 75 f4             	push   -0xc(%ebp)
8010561b:	e8 c9 c2 ff ff       	call   801018e9 <iupdate>
80105620:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105623:	83 ec 0c             	sub    $0xc,%esp
80105626:	ff 75 f4             	push   -0xc(%ebp)
80105629:	e8 e1 c6 ff ff       	call   80101d0f <iunlockput>
8010562e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105631:	e8 21 dc ff ff       	call   80103257 <end_op>
  return -1;
80105636:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010563b:	c9                   	leave
8010563c:	c3                   	ret

8010563d <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010563d:	f3 0f 1e fb          	endbr32
80105641:	55                   	push   %ebp
80105642:	89 e5                	mov    %esp,%ebp
80105644:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105647:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010564e:	eb 40                	jmp    80105690 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105653:	6a 10                	push   $0x10
80105655:	50                   	push   %eax
80105656:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105659:	50                   	push   %eax
8010565a:	ff 75 08             	push   0x8(%ebp)
8010565d:	e8 78 c9 ff ff       	call   80101fda <readi>
80105662:	83 c4 10             	add    $0x10,%esp
80105665:	83 f8 10             	cmp    $0x10,%eax
80105668:	74 0d                	je     80105677 <isdirempty+0x3a>
      panic("isdirempty: readi");
8010566a:	83 ec 0c             	sub    $0xc,%esp
8010566d:	68 98 ab 10 80       	push   $0x8010ab98
80105672:	e8 67 af ff ff       	call   801005de <panic>
    if(de.inum != 0)
80105677:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010567b:	66 85 c0             	test   %ax,%ax
8010567e:	74 07                	je     80105687 <isdirempty+0x4a>
      return 0;
80105680:	b8 00 00 00 00       	mov    $0x0,%eax
80105685:	eb 1b                	jmp    801056a2 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568a:	83 c0 10             	add    $0x10,%eax
8010568d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105690:	8b 45 08             	mov    0x8(%ebp),%eax
80105693:	8b 50 58             	mov    0x58(%eax),%edx
80105696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105699:	39 c2                	cmp    %eax,%edx
8010569b:	77 b3                	ja     80105650 <isdirempty+0x13>
  }
  return 1;
8010569d:	b8 01 00 00 00       	mov    $0x1,%eax
}
801056a2:	c9                   	leave
801056a3:	c3                   	ret

801056a4 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801056a4:	f3 0f 1e fb          	endbr32
801056a8:	55                   	push   %ebp
801056a9:	89 e5                	mov    %esp,%ebp
801056ab:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801056ae:	83 ec 08             	sub    $0x8,%esp
801056b1:	8d 45 cc             	lea    -0x34(%ebp),%eax
801056b4:	50                   	push   %eax
801056b5:	6a 00                	push   $0x0
801056b7:	e8 72 fa ff ff       	call   8010512e <argstr>
801056bc:	83 c4 10             	add    $0x10,%esp
801056bf:	85 c0                	test   %eax,%eax
801056c1:	79 0a                	jns    801056cd <sys_unlink+0x29>
    return -1;
801056c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c8:	e9 bf 01 00 00       	jmp    8010588c <sys_unlink+0x1e8>

  begin_op();
801056cd:	e8 f5 da ff ff       	call   801031c7 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801056d2:	8b 45 cc             	mov    -0x34(%ebp),%eax
801056d5:	83 ec 08             	sub    $0x8,%esp
801056d8:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801056db:	52                   	push   %edx
801056dc:	50                   	push   %eax
801056dd:	e8 7b cf ff ff       	call   8010265d <nameiparent>
801056e2:	83 c4 10             	add    $0x10,%esp
801056e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056ec:	75 0f                	jne    801056fd <sys_unlink+0x59>
    end_op();
801056ee:	e8 64 db ff ff       	call   80103257 <end_op>
    return -1;
801056f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f8:	e9 8f 01 00 00       	jmp    8010588c <sys_unlink+0x1e8>
  }

  ilock(dp);
801056fd:	83 ec 0c             	sub    $0xc,%esp
80105700:	ff 75 f4             	push   -0xc(%ebp)
80105703:	e8 ca c3 ff ff       	call   80101ad2 <ilock>
80105708:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010570b:	83 ec 08             	sub    $0x8,%esp
8010570e:	68 aa ab 10 80       	push   $0x8010abaa
80105713:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105716:	50                   	push   %eax
80105717:	e8 a1 cb ff ff       	call   801022bd <namecmp>
8010571c:	83 c4 10             	add    $0x10,%esp
8010571f:	85 c0                	test   %eax,%eax
80105721:	0f 84 49 01 00 00    	je     80105870 <sys_unlink+0x1cc>
80105727:	83 ec 08             	sub    $0x8,%esp
8010572a:	68 ac ab 10 80       	push   $0x8010abac
8010572f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105732:	50                   	push   %eax
80105733:	e8 85 cb ff ff       	call   801022bd <namecmp>
80105738:	83 c4 10             	add    $0x10,%esp
8010573b:	85 c0                	test   %eax,%eax
8010573d:	0f 84 2d 01 00 00    	je     80105870 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105743:	83 ec 04             	sub    $0x4,%esp
80105746:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105749:	50                   	push   %eax
8010574a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010574d:	50                   	push   %eax
8010574e:	ff 75 f4             	push   -0xc(%ebp)
80105751:	e8 86 cb ff ff       	call   801022dc <dirlookup>
80105756:	83 c4 10             	add    $0x10,%esp
80105759:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010575c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105760:	0f 84 0d 01 00 00    	je     80105873 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105766:	83 ec 0c             	sub    $0xc,%esp
80105769:	ff 75 f0             	push   -0x10(%ebp)
8010576c:	e8 61 c3 ff ff       	call   80101ad2 <ilock>
80105771:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105774:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105777:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010577b:	66 85 c0             	test   %ax,%ax
8010577e:	7f 0d                	jg     8010578d <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105780:	83 ec 0c             	sub    $0xc,%esp
80105783:	68 af ab 10 80       	push   $0x8010abaf
80105788:	e8 51 ae ff ff       	call   801005de <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010578d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105790:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105794:	66 83 f8 01          	cmp    $0x1,%ax
80105798:	75 25                	jne    801057bf <sys_unlink+0x11b>
8010579a:	83 ec 0c             	sub    $0xc,%esp
8010579d:	ff 75 f0             	push   -0x10(%ebp)
801057a0:	e8 98 fe ff ff       	call   8010563d <isdirempty>
801057a5:	83 c4 10             	add    $0x10,%esp
801057a8:	85 c0                	test   %eax,%eax
801057aa:	75 13                	jne    801057bf <sys_unlink+0x11b>
    iunlockput(ip);
801057ac:	83 ec 0c             	sub    $0xc,%esp
801057af:	ff 75 f0             	push   -0x10(%ebp)
801057b2:	e8 58 c5 ff ff       	call   80101d0f <iunlockput>
801057b7:	83 c4 10             	add    $0x10,%esp
    goto bad;
801057ba:	e9 b5 00 00 00       	jmp    80105874 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
801057bf:	83 ec 04             	sub    $0x4,%esp
801057c2:	6a 10                	push   $0x10
801057c4:	6a 00                	push   $0x0
801057c6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801057c9:	50                   	push   %eax
801057ca:	e8 9c f5 ff ff       	call   80104d6b <memset>
801057cf:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801057d2:	8b 45 c8             	mov    -0x38(%ebp),%eax
801057d5:	6a 10                	push   $0x10
801057d7:	50                   	push   %eax
801057d8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801057db:	50                   	push   %eax
801057dc:	ff 75 f4             	push   -0xc(%ebp)
801057df:	e8 4f c9 ff ff       	call   80102133 <writei>
801057e4:	83 c4 10             	add    $0x10,%esp
801057e7:	83 f8 10             	cmp    $0x10,%eax
801057ea:	74 0d                	je     801057f9 <sys_unlink+0x155>
    panic("unlink: writei");
801057ec:	83 ec 0c             	sub    $0xc,%esp
801057ef:	68 c1 ab 10 80       	push   $0x8010abc1
801057f4:	e8 e5 ad ff ff       	call   801005de <panic>
  if(ip->type == T_DIR){
801057f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057fc:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105800:	66 83 f8 01          	cmp    $0x1,%ax
80105804:	75 21                	jne    80105827 <sys_unlink+0x183>
    dp->nlink--;
80105806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105809:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010580d:	83 e8 01             	sub    $0x1,%eax
80105810:	89 c2                	mov    %eax,%edx
80105812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105815:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105819:	83 ec 0c             	sub    $0xc,%esp
8010581c:	ff 75 f4             	push   -0xc(%ebp)
8010581f:	e8 c5 c0 ff ff       	call   801018e9 <iupdate>
80105824:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105827:	83 ec 0c             	sub    $0xc,%esp
8010582a:	ff 75 f4             	push   -0xc(%ebp)
8010582d:	e8 dd c4 ff ff       	call   80101d0f <iunlockput>
80105832:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105835:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105838:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010583c:	83 e8 01             	sub    $0x1,%eax
8010583f:	89 c2                	mov    %eax,%edx
80105841:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105844:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105848:	83 ec 0c             	sub    $0xc,%esp
8010584b:	ff 75 f0             	push   -0x10(%ebp)
8010584e:	e8 96 c0 ff ff       	call   801018e9 <iupdate>
80105853:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105856:	83 ec 0c             	sub    $0xc,%esp
80105859:	ff 75 f0             	push   -0x10(%ebp)
8010585c:	e8 ae c4 ff ff       	call   80101d0f <iunlockput>
80105861:	83 c4 10             	add    $0x10,%esp

  end_op();
80105864:	e8 ee d9 ff ff       	call   80103257 <end_op>

  return 0;
80105869:	b8 00 00 00 00       	mov    $0x0,%eax
8010586e:	eb 1c                	jmp    8010588c <sys_unlink+0x1e8>
    goto bad;
80105870:	90                   	nop
80105871:	eb 01                	jmp    80105874 <sys_unlink+0x1d0>
    goto bad;
80105873:	90                   	nop

bad:
  iunlockput(dp);
80105874:	83 ec 0c             	sub    $0xc,%esp
80105877:	ff 75 f4             	push   -0xc(%ebp)
8010587a:	e8 90 c4 ff ff       	call   80101d0f <iunlockput>
8010587f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105882:	e8 d0 d9 ff ff       	call   80103257 <end_op>
  return -1;
80105887:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010588c:	c9                   	leave
8010588d:	c3                   	ret

8010588e <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010588e:	f3 0f 1e fb          	endbr32
80105892:	55                   	push   %ebp
80105893:	89 e5                	mov    %esp,%ebp
80105895:	83 ec 38             	sub    $0x38,%esp
80105898:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010589b:	8b 55 10             	mov    0x10(%ebp),%edx
8010589e:	8b 45 14             	mov    0x14(%ebp),%eax
801058a1:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801058a5:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801058a9:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801058ad:	83 ec 08             	sub    $0x8,%esp
801058b0:	8d 45 de             	lea    -0x22(%ebp),%eax
801058b3:	50                   	push   %eax
801058b4:	ff 75 08             	push   0x8(%ebp)
801058b7:	e8 a1 cd ff ff       	call   8010265d <nameiparent>
801058bc:	83 c4 10             	add    $0x10,%esp
801058bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058c6:	75 0a                	jne    801058d2 <create+0x44>
    return 0;
801058c8:	b8 00 00 00 00       	mov    $0x0,%eax
801058cd:	e9 90 01 00 00       	jmp    80105a62 <create+0x1d4>
  ilock(dp);
801058d2:	83 ec 0c             	sub    $0xc,%esp
801058d5:	ff 75 f4             	push   -0xc(%ebp)
801058d8:	e8 f5 c1 ff ff       	call   80101ad2 <ilock>
801058dd:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801058e0:	83 ec 04             	sub    $0x4,%esp
801058e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058e6:	50                   	push   %eax
801058e7:	8d 45 de             	lea    -0x22(%ebp),%eax
801058ea:	50                   	push   %eax
801058eb:	ff 75 f4             	push   -0xc(%ebp)
801058ee:	e8 e9 c9 ff ff       	call   801022dc <dirlookup>
801058f3:	83 c4 10             	add    $0x10,%esp
801058f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801058f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058fd:	74 50                	je     8010594f <create+0xc1>
    iunlockput(dp);
801058ff:	83 ec 0c             	sub    $0xc,%esp
80105902:	ff 75 f4             	push   -0xc(%ebp)
80105905:	e8 05 c4 ff ff       	call   80101d0f <iunlockput>
8010590a:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010590d:	83 ec 0c             	sub    $0xc,%esp
80105910:	ff 75 f0             	push   -0x10(%ebp)
80105913:	e8 ba c1 ff ff       	call   80101ad2 <ilock>
80105918:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010591b:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105920:	75 15                	jne    80105937 <create+0xa9>
80105922:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105925:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105929:	66 83 f8 02          	cmp    $0x2,%ax
8010592d:	75 08                	jne    80105937 <create+0xa9>
      return ip;
8010592f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105932:	e9 2b 01 00 00       	jmp    80105a62 <create+0x1d4>
    iunlockput(ip);
80105937:	83 ec 0c             	sub    $0xc,%esp
8010593a:	ff 75 f0             	push   -0x10(%ebp)
8010593d:	e8 cd c3 ff ff       	call   80101d0f <iunlockput>
80105942:	83 c4 10             	add    $0x10,%esp
    return 0;
80105945:	b8 00 00 00 00       	mov    $0x0,%eax
8010594a:	e9 13 01 00 00       	jmp    80105a62 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010594f:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105956:	8b 00                	mov    (%eax),%eax
80105958:	83 ec 08             	sub    $0x8,%esp
8010595b:	52                   	push   %edx
8010595c:	50                   	push   %eax
8010595d:	e8 ac be ff ff       	call   8010180e <ialloc>
80105962:	83 c4 10             	add    $0x10,%esp
80105965:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105968:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010596c:	75 0d                	jne    8010597b <create+0xed>
    panic("create: ialloc");
8010596e:	83 ec 0c             	sub    $0xc,%esp
80105971:	68 d0 ab 10 80       	push   $0x8010abd0
80105976:	e8 63 ac ff ff       	call   801005de <panic>

  ilock(ip);
8010597b:	83 ec 0c             	sub    $0xc,%esp
8010597e:	ff 75 f0             	push   -0x10(%ebp)
80105981:	e8 4c c1 ff ff       	call   80101ad2 <ilock>
80105986:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105989:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010598c:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105990:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105994:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105997:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010599b:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
8010599f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a2:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801059a8:	83 ec 0c             	sub    $0xc,%esp
801059ab:	ff 75 f0             	push   -0x10(%ebp)
801059ae:	e8 36 bf ff ff       	call   801018e9 <iupdate>
801059b3:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801059b6:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801059bb:	75 6a                	jne    80105a27 <create+0x199>
    dp->nlink++;  // for ".."
801059bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801059c4:	83 c0 01             	add    $0x1,%eax
801059c7:	89 c2                	mov    %eax,%edx
801059c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cc:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801059d0:	83 ec 0c             	sub    $0xc,%esp
801059d3:	ff 75 f4             	push   -0xc(%ebp)
801059d6:	e8 0e bf ff ff       	call   801018e9 <iupdate>
801059db:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801059de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e1:	8b 40 04             	mov    0x4(%eax),%eax
801059e4:	83 ec 04             	sub    $0x4,%esp
801059e7:	50                   	push   %eax
801059e8:	68 aa ab 10 80       	push   $0x8010abaa
801059ed:	ff 75 f0             	push   -0x10(%ebp)
801059f0:	e8 a5 c9 ff ff       	call   8010239a <dirlink>
801059f5:	83 c4 10             	add    $0x10,%esp
801059f8:	85 c0                	test   %eax,%eax
801059fa:	78 1e                	js     80105a1a <create+0x18c>
801059fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ff:	8b 40 04             	mov    0x4(%eax),%eax
80105a02:	83 ec 04             	sub    $0x4,%esp
80105a05:	50                   	push   %eax
80105a06:	68 ac ab 10 80       	push   $0x8010abac
80105a0b:	ff 75 f0             	push   -0x10(%ebp)
80105a0e:	e8 87 c9 ff ff       	call   8010239a <dirlink>
80105a13:	83 c4 10             	add    $0x10,%esp
80105a16:	85 c0                	test   %eax,%eax
80105a18:	79 0d                	jns    80105a27 <create+0x199>
      panic("create dots");
80105a1a:	83 ec 0c             	sub    $0xc,%esp
80105a1d:	68 df ab 10 80       	push   $0x8010abdf
80105a22:	e8 b7 ab ff ff       	call   801005de <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2a:	8b 40 04             	mov    0x4(%eax),%eax
80105a2d:	83 ec 04             	sub    $0x4,%esp
80105a30:	50                   	push   %eax
80105a31:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a34:	50                   	push   %eax
80105a35:	ff 75 f4             	push   -0xc(%ebp)
80105a38:	e8 5d c9 ff ff       	call   8010239a <dirlink>
80105a3d:	83 c4 10             	add    $0x10,%esp
80105a40:	85 c0                	test   %eax,%eax
80105a42:	79 0d                	jns    80105a51 <create+0x1c3>
    panic("create: dirlink");
80105a44:	83 ec 0c             	sub    $0xc,%esp
80105a47:	68 eb ab 10 80       	push   $0x8010abeb
80105a4c:	e8 8d ab ff ff       	call   801005de <panic>

  iunlockput(dp);
80105a51:	83 ec 0c             	sub    $0xc,%esp
80105a54:	ff 75 f4             	push   -0xc(%ebp)
80105a57:	e8 b3 c2 ff ff       	call   80101d0f <iunlockput>
80105a5c:	83 c4 10             	add    $0x10,%esp

  return ip;
80105a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105a62:	c9                   	leave
80105a63:	c3                   	ret

80105a64 <sys_open>:

int
sys_open(void)
{
80105a64:	f3 0f 1e fb          	endbr32
80105a68:	55                   	push   %ebp
80105a69:	89 e5                	mov    %esp,%ebp
80105a6b:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105a6e:	83 ec 08             	sub    $0x8,%esp
80105a71:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105a74:	50                   	push   %eax
80105a75:	6a 00                	push   $0x0
80105a77:	e8 b2 f6 ff ff       	call   8010512e <argstr>
80105a7c:	83 c4 10             	add    $0x10,%esp
80105a7f:	85 c0                	test   %eax,%eax
80105a81:	78 15                	js     80105a98 <sys_open+0x34>
80105a83:	83 ec 08             	sub    $0x8,%esp
80105a86:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a89:	50                   	push   %eax
80105a8a:	6a 01                	push   $0x1
80105a8c:	e8 0f f6 ff ff       	call   801050a0 <argint>
80105a91:	83 c4 10             	add    $0x10,%esp
80105a94:	85 c0                	test   %eax,%eax
80105a96:	79 0a                	jns    80105aa2 <sys_open+0x3e>
    return -1;
80105a98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a9d:	e9 61 01 00 00       	jmp    80105c03 <sys_open+0x19f>

  begin_op();
80105aa2:	e8 20 d7 ff ff       	call   801031c7 <begin_op>

  if(omode & O_CREATE){
80105aa7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105aaa:	25 00 02 00 00       	and    $0x200,%eax
80105aaf:	85 c0                	test   %eax,%eax
80105ab1:	74 2a                	je     80105add <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80105ab3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ab6:	6a 00                	push   $0x0
80105ab8:	6a 00                	push   $0x0
80105aba:	6a 02                	push   $0x2
80105abc:	50                   	push   %eax
80105abd:	e8 cc fd ff ff       	call   8010588e <create>
80105ac2:	83 c4 10             	add    $0x10,%esp
80105ac5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105ac8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105acc:	75 75                	jne    80105b43 <sys_open+0xdf>
      end_op();
80105ace:	e8 84 d7 ff ff       	call   80103257 <end_op>
      return -1;
80105ad3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad8:	e9 26 01 00 00       	jmp    80105c03 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80105add:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ae0:	83 ec 0c             	sub    $0xc,%esp
80105ae3:	50                   	push   %eax
80105ae4:	e8 54 cb ff ff       	call   8010263d <namei>
80105ae9:	83 c4 10             	add    $0x10,%esp
80105aec:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105aef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105af3:	75 0f                	jne    80105b04 <sys_open+0xa0>
      end_op();
80105af5:	e8 5d d7 ff ff       	call   80103257 <end_op>
      return -1;
80105afa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aff:	e9 ff 00 00 00       	jmp    80105c03 <sys_open+0x19f>
    }
    ilock(ip);
80105b04:	83 ec 0c             	sub    $0xc,%esp
80105b07:	ff 75 f4             	push   -0xc(%ebp)
80105b0a:	e8 c3 bf ff ff       	call   80101ad2 <ilock>
80105b0f:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b15:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b19:	66 83 f8 01          	cmp    $0x1,%ax
80105b1d:	75 24                	jne    80105b43 <sys_open+0xdf>
80105b1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b22:	85 c0                	test   %eax,%eax
80105b24:	74 1d                	je     80105b43 <sys_open+0xdf>
      iunlockput(ip);
80105b26:	83 ec 0c             	sub    $0xc,%esp
80105b29:	ff 75 f4             	push   -0xc(%ebp)
80105b2c:	e8 de c1 ff ff       	call   80101d0f <iunlockput>
80105b31:	83 c4 10             	add    $0x10,%esp
      end_op();
80105b34:	e8 1e d7 ff ff       	call   80103257 <end_op>
      return -1;
80105b39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b3e:	e9 c0 00 00 00       	jmp    80105c03 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105b43:	e8 31 b5 ff ff       	call   80101079 <filealloc>
80105b48:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b4b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b4f:	74 17                	je     80105b68 <sys_open+0x104>
80105b51:	83 ec 0c             	sub    $0xc,%esp
80105b54:	ff 75 f0             	push   -0x10(%ebp)
80105b57:	e8 07 f7 ff ff       	call   80105263 <fdalloc>
80105b5c:	83 c4 10             	add    $0x10,%esp
80105b5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105b62:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105b66:	79 2e                	jns    80105b96 <sys_open+0x132>
    if(f)
80105b68:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b6c:	74 0e                	je     80105b7c <sys_open+0x118>
      fileclose(f);
80105b6e:	83 ec 0c             	sub    $0xc,%esp
80105b71:	ff 75 f0             	push   -0x10(%ebp)
80105b74:	e8 c6 b5 ff ff       	call   8010113f <fileclose>
80105b79:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105b7c:	83 ec 0c             	sub    $0xc,%esp
80105b7f:	ff 75 f4             	push   -0xc(%ebp)
80105b82:	e8 88 c1 ff ff       	call   80101d0f <iunlockput>
80105b87:	83 c4 10             	add    $0x10,%esp
    end_op();
80105b8a:	e8 c8 d6 ff ff       	call   80103257 <end_op>
    return -1;
80105b8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b94:	eb 6d                	jmp    80105c03 <sys_open+0x19f>
  }
  iunlock(ip);
80105b96:	83 ec 0c             	sub    $0xc,%esp
80105b99:	ff 75 f4             	push   -0xc(%ebp)
80105b9c:	e8 48 c0 ff ff       	call   80101be9 <iunlock>
80105ba1:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ba4:	e8 ae d6 ff ff       	call   80103257 <end_op>

  f->type = FD_INODE;
80105ba9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bac:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105bb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bb8:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bbe:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105bc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bc8:	83 e0 01             	and    $0x1,%eax
80105bcb:	85 c0                	test   %eax,%eax
80105bcd:	0f 94 c0             	sete   %al
80105bd0:	89 c2                	mov    %eax,%edx
80105bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd5:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105bd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bdb:	83 e0 01             	and    $0x1,%eax
80105bde:	85 c0                	test   %eax,%eax
80105be0:	75 0a                	jne    80105bec <sys_open+0x188>
80105be2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105be5:	83 e0 02             	and    $0x2,%eax
80105be8:	85 c0                	test   %eax,%eax
80105bea:	74 07                	je     80105bf3 <sys_open+0x18f>
80105bec:	b8 01 00 00 00       	mov    $0x1,%eax
80105bf1:	eb 05                	jmp    80105bf8 <sys_open+0x194>
80105bf3:	b8 00 00 00 00       	mov    $0x0,%eax
80105bf8:	89 c2                	mov    %eax,%edx
80105bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bfd:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105c00:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105c03:	c9                   	leave
80105c04:	c3                   	ret

80105c05 <sys_mkdir>:

int
sys_mkdir(void)
{
80105c05:	f3 0f 1e fb          	endbr32
80105c09:	55                   	push   %ebp
80105c0a:	89 e5                	mov    %esp,%ebp
80105c0c:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105c0f:	e8 b3 d5 ff ff       	call   801031c7 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105c14:	83 ec 08             	sub    $0x8,%esp
80105c17:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c1a:	50                   	push   %eax
80105c1b:	6a 00                	push   $0x0
80105c1d:	e8 0c f5 ff ff       	call   8010512e <argstr>
80105c22:	83 c4 10             	add    $0x10,%esp
80105c25:	85 c0                	test   %eax,%eax
80105c27:	78 1b                	js     80105c44 <sys_mkdir+0x3f>
80105c29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c2c:	6a 00                	push   $0x0
80105c2e:	6a 00                	push   $0x0
80105c30:	6a 01                	push   $0x1
80105c32:	50                   	push   %eax
80105c33:	e8 56 fc ff ff       	call   8010588e <create>
80105c38:	83 c4 10             	add    $0x10,%esp
80105c3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c3e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c42:	75 0c                	jne    80105c50 <sys_mkdir+0x4b>
    end_op();
80105c44:	e8 0e d6 ff ff       	call   80103257 <end_op>
    return -1;
80105c49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c4e:	eb 18                	jmp    80105c68 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105c50:	83 ec 0c             	sub    $0xc,%esp
80105c53:	ff 75 f4             	push   -0xc(%ebp)
80105c56:	e8 b4 c0 ff ff       	call   80101d0f <iunlockput>
80105c5b:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c5e:	e8 f4 d5 ff ff       	call   80103257 <end_op>
  return 0;
80105c63:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c68:	c9                   	leave
80105c69:	c3                   	ret

80105c6a <sys_mknod>:

int
sys_mknod(void)
{
80105c6a:	f3 0f 1e fb          	endbr32
80105c6e:	55                   	push   %ebp
80105c6f:	89 e5                	mov    %esp,%ebp
80105c71:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105c74:	e8 4e d5 ff ff       	call   801031c7 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105c79:	83 ec 08             	sub    $0x8,%esp
80105c7c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c7f:	50                   	push   %eax
80105c80:	6a 00                	push   $0x0
80105c82:	e8 a7 f4 ff ff       	call   8010512e <argstr>
80105c87:	83 c4 10             	add    $0x10,%esp
80105c8a:	85 c0                	test   %eax,%eax
80105c8c:	78 4f                	js     80105cdd <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105c8e:	83 ec 08             	sub    $0x8,%esp
80105c91:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c94:	50                   	push   %eax
80105c95:	6a 01                	push   $0x1
80105c97:	e8 04 f4 ff ff       	call   801050a0 <argint>
80105c9c:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105c9f:	85 c0                	test   %eax,%eax
80105ca1:	78 3a                	js     80105cdd <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105ca3:	83 ec 08             	sub    $0x8,%esp
80105ca6:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ca9:	50                   	push   %eax
80105caa:	6a 02                	push   $0x2
80105cac:	e8 ef f3 ff ff       	call   801050a0 <argint>
80105cb1:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105cb4:	85 c0                	test   %eax,%eax
80105cb6:	78 25                	js     80105cdd <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105cb8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105cbb:	0f bf c8             	movswl %ax,%ecx
80105cbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105cc1:	0f bf d0             	movswl %ax,%edx
80105cc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc7:	51                   	push   %ecx
80105cc8:	52                   	push   %edx
80105cc9:	6a 03                	push   $0x3
80105ccb:	50                   	push   %eax
80105ccc:	e8 bd fb ff ff       	call   8010588e <create>
80105cd1:	83 c4 10             	add    $0x10,%esp
80105cd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105cd7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cdb:	75 0c                	jne    80105ce9 <sys_mknod+0x7f>
    end_op();
80105cdd:	e8 75 d5 ff ff       	call   80103257 <end_op>
    return -1;
80105ce2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ce7:	eb 18                	jmp    80105d01 <sys_mknod+0x97>
  }
  iunlockput(ip);
80105ce9:	83 ec 0c             	sub    $0xc,%esp
80105cec:	ff 75 f4             	push   -0xc(%ebp)
80105cef:	e8 1b c0 ff ff       	call   80101d0f <iunlockput>
80105cf4:	83 c4 10             	add    $0x10,%esp
  end_op();
80105cf7:	e8 5b d5 ff ff       	call   80103257 <end_op>
  return 0;
80105cfc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d01:	c9                   	leave
80105d02:	c3                   	ret

80105d03 <sys_chdir>:

int
sys_chdir(void)
{
80105d03:	f3 0f 1e fb          	endbr32
80105d07:	55                   	push   %ebp
80105d08:	89 e5                	mov    %esp,%ebp
80105d0a:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105d0d:	e8 ed de ff ff       	call   80103bff <myproc>
80105d12:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105d15:	e8 ad d4 ff ff       	call   801031c7 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105d1a:	83 ec 08             	sub    $0x8,%esp
80105d1d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d20:	50                   	push   %eax
80105d21:	6a 00                	push   $0x0
80105d23:	e8 06 f4 ff ff       	call   8010512e <argstr>
80105d28:	83 c4 10             	add    $0x10,%esp
80105d2b:	85 c0                	test   %eax,%eax
80105d2d:	78 18                	js     80105d47 <sys_chdir+0x44>
80105d2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d32:	83 ec 0c             	sub    $0xc,%esp
80105d35:	50                   	push   %eax
80105d36:	e8 02 c9 ff ff       	call   8010263d <namei>
80105d3b:	83 c4 10             	add    $0x10,%esp
80105d3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d41:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d45:	75 0c                	jne    80105d53 <sys_chdir+0x50>
    end_op();
80105d47:	e8 0b d5 ff ff       	call   80103257 <end_op>
    return -1;
80105d4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d51:	eb 68                	jmp    80105dbb <sys_chdir+0xb8>
  }
  ilock(ip);
80105d53:	83 ec 0c             	sub    $0xc,%esp
80105d56:	ff 75 f0             	push   -0x10(%ebp)
80105d59:	e8 74 bd ff ff       	call   80101ad2 <ilock>
80105d5e:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d64:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d68:	66 83 f8 01          	cmp    $0x1,%ax
80105d6c:	74 1a                	je     80105d88 <sys_chdir+0x85>
    iunlockput(ip);
80105d6e:	83 ec 0c             	sub    $0xc,%esp
80105d71:	ff 75 f0             	push   -0x10(%ebp)
80105d74:	e8 96 bf ff ff       	call   80101d0f <iunlockput>
80105d79:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d7c:	e8 d6 d4 ff ff       	call   80103257 <end_op>
    return -1;
80105d81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d86:	eb 33                	jmp    80105dbb <sys_chdir+0xb8>
  }
  iunlock(ip);
80105d88:	83 ec 0c             	sub    $0xc,%esp
80105d8b:	ff 75 f0             	push   -0x10(%ebp)
80105d8e:	e8 56 be ff ff       	call   80101be9 <iunlock>
80105d93:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d99:	8b 40 68             	mov    0x68(%eax),%eax
80105d9c:	83 ec 0c             	sub    $0xc,%esp
80105d9f:	50                   	push   %eax
80105da0:	e8 96 be ff ff       	call   80101c3b <iput>
80105da5:	83 c4 10             	add    $0x10,%esp
  end_op();
80105da8:	e8 aa d4 ff ff       	call   80103257 <end_op>
  curproc->cwd = ip;
80105dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105db3:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105db6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dbb:	c9                   	leave
80105dbc:	c3                   	ret

80105dbd <sys_exec>:

int
sys_exec(void)
{
80105dbd:	f3 0f 1e fb          	endbr32
80105dc1:	55                   	push   %ebp
80105dc2:	89 e5                	mov    %esp,%ebp
80105dc4:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105dca:	83 ec 08             	sub    $0x8,%esp
80105dcd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105dd0:	50                   	push   %eax
80105dd1:	6a 00                	push   $0x0
80105dd3:	e8 56 f3 ff ff       	call   8010512e <argstr>
80105dd8:	83 c4 10             	add    $0x10,%esp
80105ddb:	85 c0                	test   %eax,%eax
80105ddd:	78 18                	js     80105df7 <sys_exec+0x3a>
80105ddf:	83 ec 08             	sub    $0x8,%esp
80105de2:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105de8:	50                   	push   %eax
80105de9:	6a 01                	push   $0x1
80105deb:	e8 b0 f2 ff ff       	call   801050a0 <argint>
80105df0:	83 c4 10             	add    $0x10,%esp
80105df3:	85 c0                	test   %eax,%eax
80105df5:	79 0a                	jns    80105e01 <sys_exec+0x44>
    return -1;
80105df7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dfc:	e9 c6 00 00 00       	jmp    80105ec7 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80105e01:	83 ec 04             	sub    $0x4,%esp
80105e04:	68 80 00 00 00       	push   $0x80
80105e09:	6a 00                	push   $0x0
80105e0b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e11:	50                   	push   %eax
80105e12:	e8 54 ef ff ff       	call   80104d6b <memset>
80105e17:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105e1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e24:	83 f8 1f             	cmp    $0x1f,%eax
80105e27:	76 0a                	jbe    80105e33 <sys_exec+0x76>
      return -1;
80105e29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e2e:	e9 94 00 00 00       	jmp    80105ec7 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e36:	c1 e0 02             	shl    $0x2,%eax
80105e39:	89 c2                	mov    %eax,%edx
80105e3b:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105e41:	01 c2                	add    %eax,%edx
80105e43:	83 ec 08             	sub    $0x8,%esp
80105e46:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105e4c:	50                   	push   %eax
80105e4d:	52                   	push   %edx
80105e4e:	e8 c1 f1 ff ff       	call   80105014 <fetchint>
80105e53:	83 c4 10             	add    $0x10,%esp
80105e56:	85 c0                	test   %eax,%eax
80105e58:	79 07                	jns    80105e61 <sys_exec+0xa4>
      return -1;
80105e5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e5f:	eb 66                	jmp    80105ec7 <sys_exec+0x10a>
    if(uarg == 0){
80105e61:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e67:	85 c0                	test   %eax,%eax
80105e69:	75 27                	jne    80105e92 <sys_exec+0xd5>
      argv[i] = 0;
80105e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e6e:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105e75:	00 00 00 00 
      break;
80105e79:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105e7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e7d:	83 ec 08             	sub    $0x8,%esp
80105e80:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105e86:	52                   	push   %edx
80105e87:	50                   	push   %eax
80105e88:	e8 4a ad ff ff       	call   80100bd7 <exec>
80105e8d:	83 c4 10             	add    $0x10,%esp
80105e90:	eb 35                	jmp    80105ec7 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80105e92:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e9b:	c1 e2 02             	shl    $0x2,%edx
80105e9e:	01 c2                	add    %eax,%edx
80105ea0:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105ea6:	83 ec 08             	sub    $0x8,%esp
80105ea9:	52                   	push   %edx
80105eaa:	50                   	push   %eax
80105eab:	e8 94 f1 ff ff       	call   80105044 <fetchstr>
80105eb0:	83 c4 10             	add    $0x10,%esp
80105eb3:	85 c0                	test   %eax,%eax
80105eb5:	79 07                	jns    80105ebe <sys_exec+0x101>
      return -1;
80105eb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ebc:	eb 09                	jmp    80105ec7 <sys_exec+0x10a>
  for(i=0;; i++){
80105ebe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ec2:	e9 5a ff ff ff       	jmp    80105e21 <sys_exec+0x64>
}
80105ec7:	c9                   	leave
80105ec8:	c3                   	ret

80105ec9 <sys_pipe>:

int
sys_pipe(void)
{
80105ec9:	f3 0f 1e fb          	endbr32
80105ecd:	55                   	push   %ebp
80105ece:	89 e5                	mov    %esp,%ebp
80105ed0:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105ed3:	83 ec 04             	sub    $0x4,%esp
80105ed6:	6a 08                	push   $0x8
80105ed8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105edb:	50                   	push   %eax
80105edc:	6a 00                	push   $0x0
80105ede:	e8 ee f1 ff ff       	call   801050d1 <argptr>
80105ee3:	83 c4 10             	add    $0x10,%esp
80105ee6:	85 c0                	test   %eax,%eax
80105ee8:	79 0a                	jns    80105ef4 <sys_pipe+0x2b>
    return -1;
80105eea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eef:	e9 ae 00 00 00       	jmp    80105fa2 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80105ef4:	83 ec 08             	sub    $0x8,%esp
80105ef7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105efa:	50                   	push   %eax
80105efb:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105efe:	50                   	push   %eax
80105eff:	e8 1c d8 ff ff       	call   80103720 <pipealloc>
80105f04:	83 c4 10             	add    $0x10,%esp
80105f07:	85 c0                	test   %eax,%eax
80105f09:	79 0a                	jns    80105f15 <sys_pipe+0x4c>
    return -1;
80105f0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f10:	e9 8d 00 00 00       	jmp    80105fa2 <sys_pipe+0xd9>
  fd0 = -1;
80105f15:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105f1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f1f:	83 ec 0c             	sub    $0xc,%esp
80105f22:	50                   	push   %eax
80105f23:	e8 3b f3 ff ff       	call   80105263 <fdalloc>
80105f28:	83 c4 10             	add    $0x10,%esp
80105f2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f32:	78 18                	js     80105f4c <sys_pipe+0x83>
80105f34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f37:	83 ec 0c             	sub    $0xc,%esp
80105f3a:	50                   	push   %eax
80105f3b:	e8 23 f3 ff ff       	call   80105263 <fdalloc>
80105f40:	83 c4 10             	add    $0x10,%esp
80105f43:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f46:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f4a:	79 3e                	jns    80105f8a <sys_pipe+0xc1>
    if(fd0 >= 0)
80105f4c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f50:	78 13                	js     80105f65 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80105f52:	e8 a8 dc ff ff       	call   80103bff <myproc>
80105f57:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f5a:	83 c2 08             	add    $0x8,%edx
80105f5d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105f64:	00 
    fileclose(rf);
80105f65:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f68:	83 ec 0c             	sub    $0xc,%esp
80105f6b:	50                   	push   %eax
80105f6c:	e8 ce b1 ff ff       	call   8010113f <fileclose>
80105f71:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105f74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f77:	83 ec 0c             	sub    $0xc,%esp
80105f7a:	50                   	push   %eax
80105f7b:	e8 bf b1 ff ff       	call   8010113f <fileclose>
80105f80:	83 c4 10             	add    $0x10,%esp
    return -1;
80105f83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f88:	eb 18                	jmp    80105fa2 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80105f8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f90:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105f92:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f95:	8d 50 04             	lea    0x4(%eax),%edx
80105f98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f9b:	89 02                	mov    %eax,(%edx)
  return 0;
80105f9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fa2:	c9                   	leave
80105fa3:	c3                   	ret

80105fa4 <sys_printpt>:
#include "mmu.h"
#include "proc.h"

int
sys_printpt(void)
{
80105fa4:	f3 0f 1e fb          	endbr32
80105fa8:	55                   	push   %ebp
80105fa9:	89 e5                	mov    %esp,%ebp
80105fab:	83 ec 18             	sub    $0x18,%esp
  int pid;
  if (argint(0, &pid) < 0)
80105fae:	83 ec 08             	sub    $0x8,%esp
80105fb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fb4:	50                   	push   %eax
80105fb5:	6a 00                	push   $0x0
80105fb7:	e8 e4 f0 ff ff       	call   801050a0 <argint>
80105fbc:	83 c4 10             	add    $0x10,%esp
80105fbf:	85 c0                	test   %eax,%eax
80105fc1:	79 07                	jns    80105fca <sys_printpt+0x26>
        return -1;
80105fc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fc8:	eb 0f                	jmp    80105fd9 <sys_printpt+0x35>
  return printpt(pid);
80105fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fcd:	83 ec 0c             	sub    $0xc,%esp
80105fd0:	50                   	push   %eax
80105fd1:	e8 3d e8 ff ff       	call   80104813 <printpt>
80105fd6:	83 c4 10             	add    $0x10,%esp
}
80105fd9:	c9                   	leave
80105fda:	c3                   	ret

80105fdb <sys_fork>:

int
sys_fork(void)
{
80105fdb:	f3 0f 1e fb          	endbr32
80105fdf:	55                   	push   %ebp
80105fe0:	89 e5                	mov    %esp,%ebp
80105fe2:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105fe5:	e8 6b df ff ff       	call   80103f55 <fork>
}
80105fea:	c9                   	leave
80105feb:	c3                   	ret

80105fec <sys_exit>:

int
sys_exit(void)
{
80105fec:	f3 0f 1e fb          	endbr32
80105ff0:	55                   	push   %ebp
80105ff1:	89 e5                	mov    %esp,%ebp
80105ff3:	83 ec 08             	sub    $0x8,%esp
  exit();
80105ff6:	e8 fd e0 ff ff       	call   801040f8 <exit>
  return 0;  // not reached
80105ffb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106000:	c9                   	leave
80106001:	c3                   	ret

80106002 <sys_wait>:

int
sys_wait(void)
{
80106002:	f3 0f 1e fb          	endbr32
80106006:	55                   	push   %ebp
80106007:	89 e5                	mov    %esp,%ebp
80106009:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010600c:	e8 0b e2 ff ff       	call   8010421c <wait>
}
80106011:	c9                   	leave
80106012:	c3                   	ret

80106013 <sys_uthread_init>:
int
sys_uthread_init(void)
{
80106013:	f3 0f 1e fb          	endbr32
80106017:	55                   	push   %ebp
80106018:	89 e5                	mov    %esp,%ebp
8010601a:	83 ec 18             	sub    $0x18,%esp
    // 시스템콜의 인자값을 받아온다.
    int address;
    if (argint(0, &address) < 0)
8010601d:	83 ec 08             	sub    $0x8,%esp
80106020:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106023:	50                   	push   %eax
80106024:	6a 00                	push   $0x0
80106026:	e8 75 f0 ff ff       	call   801050a0 <argint>
8010602b:	83 c4 10             	add    $0x10,%esp
8010602e:	85 c0                	test   %eax,%eax
80106030:	79 07                	jns    80106039 <sys_uthread_init+0x26>
        return -1;
80106032:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106037:	eb 0f                	jmp    80106048 <sys_uthread_init+0x35>
    // proc.c의 uthread_init() 함수 호출
    return uthread_init(address);
80106039:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603c:	83 ec 0c             	sub    $0xc,%esp
8010603f:	50                   	push   %eax
80106040:	e8 b7 e3 ff ff       	call   801043fc <uthread_init>
80106045:	83 c4 10             	add    $0x10,%esp
}
80106048:	c9                   	leave
80106049:	c3                   	ret

8010604a <sys_kill>:

int
sys_kill(void)
{
8010604a:	f3 0f 1e fb          	endbr32
8010604e:	55                   	push   %ebp
8010604f:	89 e5                	mov    %esp,%ebp
80106051:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106054:	83 ec 08             	sub    $0x8,%esp
80106057:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010605a:	50                   	push   %eax
8010605b:	6a 00                	push   $0x0
8010605d:	e8 3e f0 ff ff       	call   801050a0 <argint>
80106062:	83 c4 10             	add    $0x10,%esp
80106065:	85 c0                	test   %eax,%eax
80106067:	79 07                	jns    80106070 <sys_kill+0x26>
    return -1;
80106069:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010606e:	eb 0f                	jmp    8010607f <sys_kill+0x35>
  return kill(pid);
80106070:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106073:	83 ec 0c             	sub    $0xc,%esp
80106076:	50                   	push   %eax
80106077:	e8 11 e6 ff ff       	call   8010468d <kill>
8010607c:	83 c4 10             	add    $0x10,%esp
}
8010607f:	c9                   	leave
80106080:	c3                   	ret

80106081 <sys_getpid>:

int
sys_getpid(void)
{
80106081:	f3 0f 1e fb          	endbr32
80106085:	55                   	push   %ebp
80106086:	89 e5                	mov    %esp,%ebp
80106088:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010608b:	e8 6f db ff ff       	call   80103bff <myproc>
80106090:	8b 40 10             	mov    0x10(%eax),%eax
}
80106093:	c9                   	leave
80106094:	c3                   	ret

80106095 <sys_sbrk>:

int
sys_sbrk(void)
{
80106095:	f3 0f 1e fb          	endbr32
80106099:	55                   	push   %ebp
8010609a:	89 e5                	mov    %esp,%ebp
8010609c:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010609f:	83 ec 08             	sub    $0x8,%esp
801060a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060a5:	50                   	push   %eax
801060a6:	6a 00                	push   $0x0
801060a8:	e8 f3 ef ff ff       	call   801050a0 <argint>
801060ad:	83 c4 10             	add    $0x10,%esp
801060b0:	85 c0                	test   %eax,%eax
801060b2:	79 07                	jns    801060bb <sys_sbrk+0x26>
    return -1;
801060b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b9:	eb 27                	jmp    801060e2 <sys_sbrk+0x4d>
  addr = myproc()->sz;
801060bb:	e8 3f db ff ff       	call   80103bff <myproc>
801060c0:	8b 00                	mov    (%eax),%eax
801060c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801060c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c8:	83 ec 0c             	sub    $0xc,%esp
801060cb:	50                   	push   %eax
801060cc:	e8 c2 dd ff ff       	call   80103e93 <growproc>
801060d1:	83 c4 10             	add    $0x10,%esp
801060d4:	85 c0                	test   %eax,%eax
801060d6:	79 07                	jns    801060df <sys_sbrk+0x4a>
    return -1;
801060d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060dd:	eb 03                	jmp    801060e2 <sys_sbrk+0x4d>
  return addr;
801060df:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801060e2:	c9                   	leave
801060e3:	c3                   	ret

801060e4 <sys_sleep>:

int
sys_sleep(void)
{
801060e4:	f3 0f 1e fb          	endbr32
801060e8:	55                   	push   %ebp
801060e9:	89 e5                	mov    %esp,%ebp
801060eb:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801060ee:	83 ec 08             	sub    $0x8,%esp
801060f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060f4:	50                   	push   %eax
801060f5:	6a 00                	push   $0x0
801060f7:	e8 a4 ef ff ff       	call   801050a0 <argint>
801060fc:	83 c4 10             	add    $0x10,%esp
801060ff:	85 c0                	test   %eax,%eax
80106101:	79 07                	jns    8010610a <sys_sleep+0x26>
    return -1;
80106103:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106108:	eb 76                	jmp    80106180 <sys_sleep+0x9c>
  acquire(&tickslock);
8010610a:	83 ec 0c             	sub    $0xc,%esp
8010610d:	68 40 75 19 80       	push   $0x80197540
80106112:	e8 c5 e9 ff ff       	call   80104adc <acquire>
80106117:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010611a:	a1 80 7d 19 80       	mov    0x80197d80,%eax
8010611f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106122:	eb 38                	jmp    8010615c <sys_sleep+0x78>
    if(myproc()->killed){
80106124:	e8 d6 da ff ff       	call   80103bff <myproc>
80106129:	8b 40 24             	mov    0x24(%eax),%eax
8010612c:	85 c0                	test   %eax,%eax
8010612e:	74 17                	je     80106147 <sys_sleep+0x63>
      release(&tickslock);
80106130:	83 ec 0c             	sub    $0xc,%esp
80106133:	68 40 75 19 80       	push   $0x80197540
80106138:	e8 11 ea ff ff       	call   80104b4e <release>
8010613d:	83 c4 10             	add    $0x10,%esp
      return -1;
80106140:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106145:	eb 39                	jmp    80106180 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106147:	83 ec 08             	sub    $0x8,%esp
8010614a:	68 40 75 19 80       	push   $0x80197540
8010614f:	68 80 7d 19 80       	push   $0x80197d80
80106154:	e8 0a e4 ff ff       	call   80104563 <sleep>
80106159:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010615c:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106161:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106164:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106167:	39 d0                	cmp    %edx,%eax
80106169:	72 b9                	jb     80106124 <sys_sleep+0x40>
  }
  release(&tickslock);
8010616b:	83 ec 0c             	sub    $0xc,%esp
8010616e:	68 40 75 19 80       	push   $0x80197540
80106173:	e8 d6 e9 ff ff       	call   80104b4e <release>
80106178:	83 c4 10             	add    $0x10,%esp
  return 0;
8010617b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106180:	c9                   	leave
80106181:	c3                   	ret

80106182 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106182:	f3 0f 1e fb          	endbr32
80106186:	55                   	push   %ebp
80106187:	89 e5                	mov    %esp,%ebp
80106189:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010618c:	83 ec 0c             	sub    $0xc,%esp
8010618f:	68 40 75 19 80       	push   $0x80197540
80106194:	e8 43 e9 ff ff       	call   80104adc <acquire>
80106199:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010619c:	a1 80 7d 19 80       	mov    0x80197d80,%eax
801061a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801061a4:	83 ec 0c             	sub    $0xc,%esp
801061a7:	68 40 75 19 80       	push   $0x80197540
801061ac:	e8 9d e9 ff ff       	call   80104b4e <release>
801061b1:	83 c4 10             	add    $0x10,%esp
  return xticks;
801061b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801061b7:	c9                   	leave
801061b8:	c3                   	ret

801061b9 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801061b9:	1e                   	push   %ds
  pushl %es
801061ba:	06                   	push   %es
  pushl %fs
801061bb:	0f a0                	push   %fs
  pushl %gs
801061bd:	0f a8                	push   %gs
  pushal
801061bf:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801061c0:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801061c4:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801061c6:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801061c8:	54                   	push   %esp
  call trap
801061c9:	e8 df 01 00 00       	call   801063ad <trap>
  addl $4, %esp
801061ce:	83 c4 04             	add    $0x4,%esp

801061d1 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801061d1:	61                   	popa
  popl %gs
801061d2:	0f a9                	pop    %gs
  popl %fs
801061d4:	0f a1                	pop    %fs
  popl %es
801061d6:	07                   	pop    %es
  popl %ds
801061d7:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801061d8:	83 c4 08             	add    $0x8,%esp
  iret
801061db:	cf                   	iret

801061dc <lidt>:
{
801061dc:	55                   	push   %ebp
801061dd:	89 e5                	mov    %esp,%ebp
801061df:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801061e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801061e5:	83 e8 01             	sub    $0x1,%eax
801061e8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801061ec:	8b 45 08             	mov    0x8(%ebp),%eax
801061ef:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801061f3:	8b 45 08             	mov    0x8(%ebp),%eax
801061f6:	c1 e8 10             	shr    $0x10,%eax
801061f9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801061fd:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106200:	0f 01 18             	lidtl  (%eax)
}
80106203:	90                   	nop
80106204:	c9                   	leave
80106205:	c3                   	ret

80106206 <rcr2>:

static inline uint
rcr2(void)
{
80106206:	55                   	push   %ebp
80106207:	89 e5                	mov    %esp,%ebp
80106209:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010620c:	0f 20 d0             	mov    %cr2,%eax
8010620f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106212:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106215:	c9                   	leave
80106216:	c3                   	ret

80106217 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106217:	f3 0f 1e fb          	endbr32
8010621b:	55                   	push   %ebp
8010621c:	89 e5                	mov    %esp,%ebp
8010621e:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106221:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106228:	e9 c3 00 00 00       	jmp    801062f0 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010622d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106230:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80106237:	89 c2                	mov    %eax,%edx
80106239:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010623c:	66 89 14 c5 80 75 19 	mov    %dx,-0x7fe68a80(,%eax,8)
80106243:	80 
80106244:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106247:	66 c7 04 c5 82 75 19 	movw   $0x8,-0x7fe68a7e(,%eax,8)
8010624e:	80 08 00 
80106251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106254:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
8010625b:	80 
8010625c:	83 e2 e0             	and    $0xffffffe0,%edx
8010625f:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
80106266:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106269:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
80106270:	80 
80106271:	83 e2 1f             	and    $0x1f,%edx
80106274:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
8010627b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627e:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
80106285:	80 
80106286:	83 e2 f0             	and    $0xfffffff0,%edx
80106289:	83 ca 0e             	or     $0xe,%edx
8010628c:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
80106293:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106296:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
8010629d:	80 
8010629e:	83 e2 ef             	and    $0xffffffef,%edx
801062a1:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801062a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ab:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
801062b2:	80 
801062b3:	83 e2 9f             	and    $0xffffff9f,%edx
801062b6:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801062bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c0:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
801062c7:	80 
801062c8:	83 ca 80             	or     $0xffffff80,%edx
801062cb:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801062d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d5:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801062dc:	c1 e8 10             	shr    $0x10,%eax
801062df:	89 c2                	mov    %eax,%edx
801062e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e4:	66 89 14 c5 86 75 19 	mov    %dx,-0x7fe68a7a(,%eax,8)
801062eb:	80 
  for(i = 0; i < 256; i++)
801062ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801062f0:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801062f7:	0f 8e 30 ff ff ff    	jle    8010622d <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801062fd:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106302:	66 a3 80 77 19 80    	mov    %ax,0x80197780
80106308:	66 c7 05 82 77 19 80 	movw   $0x8,0x80197782
8010630f:	08 00 
80106311:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
80106318:	83 e0 e0             	and    $0xffffffe0,%eax
8010631b:	a2 84 77 19 80       	mov    %al,0x80197784
80106320:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
80106327:	83 e0 1f             	and    $0x1f,%eax
8010632a:	a2 84 77 19 80       	mov    %al,0x80197784
8010632f:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106336:	83 c8 0f             	or     $0xf,%eax
80106339:	a2 85 77 19 80       	mov    %al,0x80197785
8010633e:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106345:	83 e0 ef             	and    $0xffffffef,%eax
80106348:	a2 85 77 19 80       	mov    %al,0x80197785
8010634d:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106354:	83 c8 60             	or     $0x60,%eax
80106357:	a2 85 77 19 80       	mov    %al,0x80197785
8010635c:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106363:	83 c8 80             	or     $0xffffff80,%eax
80106366:	a2 85 77 19 80       	mov    %al,0x80197785
8010636b:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106370:	c1 e8 10             	shr    $0x10,%eax
80106373:	66 a3 86 77 19 80    	mov    %ax,0x80197786

  initlock(&tickslock, "time");
80106379:	83 ec 08             	sub    $0x8,%esp
8010637c:	68 fc ab 10 80       	push   $0x8010abfc
80106381:	68 40 75 19 80       	push   $0x80197540
80106386:	e8 2b e7 ff ff       	call   80104ab6 <initlock>
8010638b:	83 c4 10             	add    $0x10,%esp
}
8010638e:	90                   	nop
8010638f:	c9                   	leave
80106390:	c3                   	ret

80106391 <idtinit>:

void
idtinit(void)
{
80106391:	f3 0f 1e fb          	endbr32
80106395:	55                   	push   %ebp
80106396:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106398:	68 00 08 00 00       	push   $0x800
8010639d:	68 80 75 19 80       	push   $0x80197580
801063a2:	e8 35 fe ff ff       	call   801061dc <lidt>
801063a7:	83 c4 08             	add    $0x8,%esp
}
801063aa:	90                   	nop
801063ab:	c9                   	leave
801063ac:	c3                   	ret

801063ad <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801063ad:	f3 0f 1e fb          	endbr32
801063b1:	55                   	push   %ebp
801063b2:	89 e5                	mov    %esp,%ebp
801063b4:	57                   	push   %edi
801063b5:	56                   	push   %esi
801063b6:	53                   	push   %ebx
801063b7:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801063ba:	8b 45 08             	mov    0x8(%ebp),%eax
801063bd:	8b 40 30             	mov    0x30(%eax),%eax
801063c0:	83 f8 40             	cmp    $0x40,%eax
801063c3:	75 3b                	jne    80106400 <trap+0x53>
    if(myproc()->killed)
801063c5:	e8 35 d8 ff ff       	call   80103bff <myproc>
801063ca:	8b 40 24             	mov    0x24(%eax),%eax
801063cd:	85 c0                	test   %eax,%eax
801063cf:	74 05                	je     801063d6 <trap+0x29>
      exit();
801063d1:	e8 22 dd ff ff       	call   801040f8 <exit>
    myproc()->tf = tf;
801063d6:	e8 24 d8 ff ff       	call   80103bff <myproc>
801063db:	8b 55 08             	mov    0x8(%ebp),%edx
801063de:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801063e1:	e8 83 ed ff ff       	call   80105169 <syscall>
    if(myproc()->killed)
801063e6:	e8 14 d8 ff ff       	call   80103bff <myproc>
801063eb:	8b 40 24             	mov    0x24(%eax),%eax
801063ee:	85 c0                	test   %eax,%eax
801063f0:	0f 84 aa 02 00 00    	je     801066a0 <trap+0x2f3>
      exit();
801063f6:	e8 fd dc ff ff       	call   801040f8 <exit>
    return;
801063fb:	e9 a0 02 00 00       	jmp    801066a0 <trap+0x2f3>
  }

  switch(tf->trapno){
80106400:	8b 45 08             	mov    0x8(%ebp),%eax
80106403:	8b 40 30             	mov    0x30(%eax),%eax
80106406:	83 e8 0e             	sub    $0xe,%eax
80106409:	83 f8 31             	cmp    $0x31,%eax
8010640c:	0f 87 59 01 00 00    	ja     8010656b <trap+0x1be>
80106412:	8b 04 85 cc ac 10 80 	mov    -0x7fef5334(,%eax,4),%eax
80106419:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010641c:	e8 43 d7 ff ff       	call   80103b64 <cpuid>
80106421:	85 c0                	test   %eax,%eax
80106423:	75 3d                	jne    80106462 <trap+0xb5>
      acquire(&tickslock);
80106425:	83 ec 0c             	sub    $0xc,%esp
80106428:	68 40 75 19 80       	push   $0x80197540
8010642d:	e8 aa e6 ff ff       	call   80104adc <acquire>
80106432:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106435:	a1 80 7d 19 80       	mov    0x80197d80,%eax
8010643a:	83 c0 01             	add    $0x1,%eax
8010643d:	a3 80 7d 19 80       	mov    %eax,0x80197d80
      wakeup(&ticks);
80106442:	83 ec 0c             	sub    $0xc,%esp
80106445:	68 80 7d 19 80       	push   $0x80197d80
8010644a:	e8 03 e2 ff ff       	call   80104652 <wakeup>
8010644f:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106452:	83 ec 0c             	sub    $0xc,%esp
80106455:	68 40 75 19 80       	push   $0x80197540
8010645a:	e8 ef e6 ff ff       	call   80104b4e <release>
8010645f:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106462:	e8 14 c8 ff ff       	call   80102c7b <lapiceoi>


    break;
80106467:	e9 b4 01 00 00       	jmp    80106620 <trap+0x273>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010646c:	e8 eb 40 00 00       	call   8010a55c <ideintr>
    lapiceoi();
80106471:	e8 05 c8 ff ff       	call   80102c7b <lapiceoi>
    break;
80106476:	e9 a5 01 00 00       	jmp    80106620 <trap+0x273>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010647b:	e8 31 c6 ff ff       	call   80102ab1 <kbdintr>
    lapiceoi();
80106480:	e8 f6 c7 ff ff       	call   80102c7b <lapiceoi>
    break;
80106485:	e9 96 01 00 00       	jmp    80106620 <trap+0x273>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010648a:	e8 f3 03 00 00       	call   80106882 <uartintr>
    lapiceoi();
8010648f:	e8 e7 c7 ff ff       	call   80102c7b <lapiceoi>
    break;
80106494:	e9 87 01 00 00       	jmp    80106620 <trap+0x273>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106499:	e8 fd 2c 00 00       	call   8010919b <i8254_intr>
    lapiceoi();
8010649e:	e8 d8 c7 ff ff       	call   80102c7b <lapiceoi>
    break;
801064a3:	e9 78 01 00 00       	jmp    80106620 <trap+0x273>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801064a8:	8b 45 08             	mov    0x8(%ebp),%eax
801064ab:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801064ae:	8b 45 08             	mov    0x8(%ebp),%eax
801064b1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801064b5:	0f b7 d8             	movzwl %ax,%ebx
801064b8:	e8 a7 d6 ff ff       	call   80103b64 <cpuid>
801064bd:	56                   	push   %esi
801064be:	53                   	push   %ebx
801064bf:	50                   	push   %eax
801064c0:	68 04 ac 10 80       	push   $0x8010ac04
801064c5:	e8 42 9f ff ff       	call   8010040c <cprintf>
801064ca:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801064cd:	e8 a9 c7 ff ff       	call   80102c7b <lapiceoi>
    break;
801064d2:	e9 49 01 00 00       	jmp    80106620 <trap+0x273>
  case T_PGFLT:
    cprintf("[PAGE FAULT IN]\n");
801064d7:	83 ec 0c             	sub    $0xc,%esp
801064da:	68 28 ac 10 80       	push   $0x8010ac28
801064df:	e8 28 9f ff ff       	call   8010040c <cprintf>
801064e4:	83 c4 10             	add    $0x10,%esp
    pde_t* pgdir;
    uint va;
    struct proc* p;
    char *mem;
    // va = 페이지 폴트가 난 가상 주소의 페이지 시작 주소
    va = PGROUNDDOWN(rcr2());
801064e7:	e8 1a fd ff ff       	call   80106206 <rcr2>
801064ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801064f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    cprintf("[PAGE FAULT] va %x \n",va);
801064f4:	83 ec 08             	sub    $0x8,%esp
801064f7:	ff 75 e4             	push   -0x1c(%ebp)
801064fa:	68 39 ac 10 80       	push   $0x8010ac39
801064ff:	e8 08 9f ff ff       	call   8010040c <cprintf>
80106504:	83 c4 10             	add    $0x10,%esp

    p = myproc();
80106507:	e8 f3 d6 ff ff       	call   80103bff <myproc>
8010650c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pgdir = p->pgdir;
8010650f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106512:	8b 40 04             	mov    0x4(%eax),%eax
80106515:	89 45 dc             	mov    %eax,-0x24(%ebp)
    mem = kalloc();
80106518:	e8 cb c3 ff ff       	call   801028e8 <kalloc>
8010651d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    memset(mem, 0, PGSIZE);
80106520:	83 ec 04             	sub    $0x4,%esp
80106523:	68 00 10 00 00       	push   $0x1000
80106528:	6a 00                	push   $0x0
8010652a:	ff 75 d8             	push   -0x28(%ebp)
8010652d:	e8 39 e8 ff ff       	call   80104d6b <memset>
80106532:	83 c4 10             	add    $0x10,%esp

    // va 페이지 테이블에 매핑
    // 페이지 테이블 관련 처리는 mappages 안에서 자동으로 처리해줌
    mappages(pgdir, (void*)va, PGSIZE, V2P(mem), PTE_W|PTE_U|PTE_P);
80106535:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106538:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010653e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106541:	83 ec 0c             	sub    $0xc,%esp
80106544:	6a 07                	push   $0x7
80106546:	52                   	push   %edx
80106547:	68 00 10 00 00       	push   $0x1000
8010654c:	50                   	push   %eax
8010654d:	ff 75 dc             	push   -0x24(%ebp)
80106550:	e8 fd 11 00 00       	call   80107752 <mappages>
80106555:	83 c4 20             	add    $0x20,%esp

    // flush
    switchuvm(p);
80106558:	83 ec 0c             	sub    $0xc,%esp
8010655b:	ff 75 e0             	push   -0x20(%ebp)
8010655e:	e8 ad 13 00 00       	call   80107910 <switchuvm>
80106563:	83 c4 10             	add    $0x10,%esp
    break;
80106566:	e9 b5 00 00 00       	jmp    80106620 <trap+0x273>


  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010656b:	e8 8f d6 ff ff       	call   80103bff <myproc>
80106570:	85 c0                	test   %eax,%eax
80106572:	74 11                	je     80106585 <trap+0x1d8>
80106574:	8b 45 08             	mov    0x8(%ebp),%eax
80106577:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010657b:	0f b7 c0             	movzwl %ax,%eax
8010657e:	83 e0 03             	and    $0x3,%eax
80106581:	85 c0                	test   %eax,%eax
80106583:	75 39                	jne    801065be <trap+0x211>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106585:	e8 7c fc ff ff       	call   80106206 <rcr2>
8010658a:	89 c3                	mov    %eax,%ebx
8010658c:	8b 45 08             	mov    0x8(%ebp),%eax
8010658f:	8b 70 38             	mov    0x38(%eax),%esi
80106592:	e8 cd d5 ff ff       	call   80103b64 <cpuid>
80106597:	8b 55 08             	mov    0x8(%ebp),%edx
8010659a:	8b 52 30             	mov    0x30(%edx),%edx
8010659d:	83 ec 0c             	sub    $0xc,%esp
801065a0:	53                   	push   %ebx
801065a1:	56                   	push   %esi
801065a2:	50                   	push   %eax
801065a3:	52                   	push   %edx
801065a4:	68 50 ac 10 80       	push   $0x8010ac50
801065a9:	e8 5e 9e ff ff       	call   8010040c <cprintf>
801065ae:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801065b1:	83 ec 0c             	sub    $0xc,%esp
801065b4:	68 82 ac 10 80       	push   $0x8010ac82
801065b9:	e8 20 a0 ff ff       	call   801005de <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065be:	e8 43 fc ff ff       	call   80106206 <rcr2>
801065c3:	89 c6                	mov    %eax,%esi
801065c5:	8b 45 08             	mov    0x8(%ebp),%eax
801065c8:	8b 40 38             	mov    0x38(%eax),%eax
801065cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801065ce:	e8 91 d5 ff ff       	call   80103b64 <cpuid>
801065d3:	89 c3                	mov    %eax,%ebx
801065d5:	8b 45 08             	mov    0x8(%ebp),%eax
801065d8:	8b 48 34             	mov    0x34(%eax),%ecx
801065db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801065de:	8b 45 08             	mov    0x8(%ebp),%eax
801065e1:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801065e4:	e8 16 d6 ff ff       	call   80103bff <myproc>
801065e9:	8d 50 6c             	lea    0x6c(%eax),%edx
801065ec:	89 55 cc             	mov    %edx,-0x34(%ebp)
801065ef:	e8 0b d6 ff ff       	call   80103bff <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065f4:	8b 40 10             	mov    0x10(%eax),%eax
801065f7:	56                   	push   %esi
801065f8:	ff 75 d4             	push   -0x2c(%ebp)
801065fb:	53                   	push   %ebx
801065fc:	ff 75 d0             	push   -0x30(%ebp)
801065ff:	57                   	push   %edi
80106600:	ff 75 cc             	push   -0x34(%ebp)
80106603:	50                   	push   %eax
80106604:	68 88 ac 10 80       	push   $0x8010ac88
80106609:	e8 fe 9d ff ff       	call   8010040c <cprintf>
8010660e:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106611:	e8 e9 d5 ff ff       	call   80103bff <myproc>
80106616:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010661d:	eb 01                	jmp    80106620 <trap+0x273>
    break;
8010661f:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106620:	e8 da d5 ff ff       	call   80103bff <myproc>
80106625:	85 c0                	test   %eax,%eax
80106627:	74 23                	je     8010664c <trap+0x29f>
80106629:	e8 d1 d5 ff ff       	call   80103bff <myproc>
8010662e:	8b 40 24             	mov    0x24(%eax),%eax
80106631:	85 c0                	test   %eax,%eax
80106633:	74 17                	je     8010664c <trap+0x29f>
80106635:	8b 45 08             	mov    0x8(%ebp),%eax
80106638:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010663c:	0f b7 c0             	movzwl %ax,%eax
8010663f:	83 e0 03             	and    $0x3,%eax
80106642:	83 f8 03             	cmp    $0x3,%eax
80106645:	75 05                	jne    8010664c <trap+0x29f>
    exit();
80106647:	e8 ac da ff ff       	call   801040f8 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010664c:	e8 ae d5 ff ff       	call   80103bff <myproc>
80106651:	85 c0                	test   %eax,%eax
80106653:	74 1d                	je     80106672 <trap+0x2c5>
80106655:	e8 a5 d5 ff ff       	call   80103bff <myproc>
8010665a:	8b 40 0c             	mov    0xc(%eax),%eax
8010665d:	83 f8 04             	cmp    $0x4,%eax
80106660:	75 10                	jne    80106672 <trap+0x2c5>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106662:	8b 45 08             	mov    0x8(%ebp),%eax
80106665:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106668:	83 f8 20             	cmp    $0x20,%eax
8010666b:	75 05                	jne    80106672 <trap+0x2c5>
    yield();
8010666d:	e8 69 de ff ff       	call   801044db <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106672:	e8 88 d5 ff ff       	call   80103bff <myproc>
80106677:	85 c0                	test   %eax,%eax
80106679:	74 26                	je     801066a1 <trap+0x2f4>
8010667b:	e8 7f d5 ff ff       	call   80103bff <myproc>
80106680:	8b 40 24             	mov    0x24(%eax),%eax
80106683:	85 c0                	test   %eax,%eax
80106685:	74 1a                	je     801066a1 <trap+0x2f4>
80106687:	8b 45 08             	mov    0x8(%ebp),%eax
8010668a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010668e:	0f b7 c0             	movzwl %ax,%eax
80106691:	83 e0 03             	and    $0x3,%eax
80106694:	83 f8 03             	cmp    $0x3,%eax
80106697:	75 08                	jne    801066a1 <trap+0x2f4>
    exit();
80106699:	e8 5a da ff ff       	call   801040f8 <exit>
8010669e:	eb 01                	jmp    801066a1 <trap+0x2f4>
    return;
801066a0:	90                   	nop
}
801066a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066a4:	5b                   	pop    %ebx
801066a5:	5e                   	pop    %esi
801066a6:	5f                   	pop    %edi
801066a7:	5d                   	pop    %ebp
801066a8:	c3                   	ret

801066a9 <inb>:
{
801066a9:	55                   	push   %ebp
801066aa:	89 e5                	mov    %esp,%ebp
801066ac:	83 ec 14             	sub    $0x14,%esp
801066af:	8b 45 08             	mov    0x8(%ebp),%eax
801066b2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801066b6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801066ba:	89 c2                	mov    %eax,%edx
801066bc:	ec                   	in     (%dx),%al
801066bd:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801066c0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801066c4:	c9                   	leave
801066c5:	c3                   	ret

801066c6 <outb>:
{
801066c6:	55                   	push   %ebp
801066c7:	89 e5                	mov    %esp,%ebp
801066c9:	83 ec 08             	sub    $0x8,%esp
801066cc:	8b 45 08             	mov    0x8(%ebp),%eax
801066cf:	8b 55 0c             	mov    0xc(%ebp),%edx
801066d2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801066d6:	89 d0                	mov    %edx,%eax
801066d8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801066db:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801066df:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801066e3:	ee                   	out    %al,(%dx)
}
801066e4:	90                   	nop
801066e5:	c9                   	leave
801066e6:	c3                   	ret

801066e7 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801066e7:	f3 0f 1e fb          	endbr32
801066eb:	55                   	push   %ebp
801066ec:	89 e5                	mov    %esp,%ebp
801066ee:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801066f1:	6a 00                	push   $0x0
801066f3:	68 fa 03 00 00       	push   $0x3fa
801066f8:	e8 c9 ff ff ff       	call   801066c6 <outb>
801066fd:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106700:	68 80 00 00 00       	push   $0x80
80106705:	68 fb 03 00 00       	push   $0x3fb
8010670a:	e8 b7 ff ff ff       	call   801066c6 <outb>
8010670f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106712:	6a 0c                	push   $0xc
80106714:	68 f8 03 00 00       	push   $0x3f8
80106719:	e8 a8 ff ff ff       	call   801066c6 <outb>
8010671e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106721:	6a 00                	push   $0x0
80106723:	68 f9 03 00 00       	push   $0x3f9
80106728:	e8 99 ff ff ff       	call   801066c6 <outb>
8010672d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106730:	6a 03                	push   $0x3
80106732:	68 fb 03 00 00       	push   $0x3fb
80106737:	e8 8a ff ff ff       	call   801066c6 <outb>
8010673c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010673f:	6a 00                	push   $0x0
80106741:	68 fc 03 00 00       	push   $0x3fc
80106746:	e8 7b ff ff ff       	call   801066c6 <outb>
8010674b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010674e:	6a 01                	push   $0x1
80106750:	68 f9 03 00 00       	push   $0x3f9
80106755:	e8 6c ff ff ff       	call   801066c6 <outb>
8010675a:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010675d:	68 fd 03 00 00       	push   $0x3fd
80106762:	e8 42 ff ff ff       	call   801066a9 <inb>
80106767:	83 c4 04             	add    $0x4,%esp
8010676a:	3c ff                	cmp    $0xff,%al
8010676c:	74 61                	je     801067cf <uartinit+0xe8>
    return;
  uart = 1;
8010676e:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
80106775:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106778:	68 fa 03 00 00       	push   $0x3fa
8010677d:	e8 27 ff ff ff       	call   801066a9 <inb>
80106782:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106785:	68 f8 03 00 00       	push   $0x3f8
8010678a:	e8 1a ff ff ff       	call   801066a9 <inb>
8010678f:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106792:	83 ec 08             	sub    $0x8,%esp
80106795:	6a 00                	push   $0x0
80106797:	6a 04                	push   $0x4
80106799:	e8 c4 bf ff ff       	call   80102762 <ioapicenable>
8010679e:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801067a1:	c7 45 f4 94 ad 10 80 	movl   $0x8010ad94,-0xc(%ebp)
801067a8:	eb 19                	jmp    801067c3 <uartinit+0xdc>
    uartputc(*p);
801067aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ad:	0f b6 00             	movzbl (%eax),%eax
801067b0:	0f be c0             	movsbl %al,%eax
801067b3:	83 ec 0c             	sub    $0xc,%esp
801067b6:	50                   	push   %eax
801067b7:	e8 16 00 00 00       	call   801067d2 <uartputc>
801067bc:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801067bf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c6:	0f b6 00             	movzbl (%eax),%eax
801067c9:	84 c0                	test   %al,%al
801067cb:	75 dd                	jne    801067aa <uartinit+0xc3>
801067cd:	eb 01                	jmp    801067d0 <uartinit+0xe9>
    return;
801067cf:	90                   	nop
}
801067d0:	c9                   	leave
801067d1:	c3                   	ret

801067d2 <uartputc>:

void
uartputc(int c)
{
801067d2:	f3 0f 1e fb          	endbr32
801067d6:	55                   	push   %ebp
801067d7:	89 e5                	mov    %esp,%ebp
801067d9:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801067dc:	a1 60 d0 18 80       	mov    0x8018d060,%eax
801067e1:	85 c0                	test   %eax,%eax
801067e3:	74 53                	je     80106838 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067ec:	eb 11                	jmp    801067ff <uartputc+0x2d>
    microdelay(10);
801067ee:	83 ec 0c             	sub    $0xc,%esp
801067f1:	6a 0a                	push   $0xa
801067f3:	e8 a2 c4 ff ff       	call   80102c9a <microdelay>
801067f8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067ff:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106803:	7f 1a                	jg     8010681f <uartputc+0x4d>
80106805:	83 ec 0c             	sub    $0xc,%esp
80106808:	68 fd 03 00 00       	push   $0x3fd
8010680d:	e8 97 fe ff ff       	call   801066a9 <inb>
80106812:	83 c4 10             	add    $0x10,%esp
80106815:	0f b6 c0             	movzbl %al,%eax
80106818:	83 e0 20             	and    $0x20,%eax
8010681b:	85 c0                	test   %eax,%eax
8010681d:	74 cf                	je     801067ee <uartputc+0x1c>
  outb(COM1+0, c);
8010681f:	8b 45 08             	mov    0x8(%ebp),%eax
80106822:	0f b6 c0             	movzbl %al,%eax
80106825:	83 ec 08             	sub    $0x8,%esp
80106828:	50                   	push   %eax
80106829:	68 f8 03 00 00       	push   $0x3f8
8010682e:	e8 93 fe ff ff       	call   801066c6 <outb>
80106833:	83 c4 10             	add    $0x10,%esp
80106836:	eb 01                	jmp    80106839 <uartputc+0x67>
    return;
80106838:	90                   	nop
}
80106839:	c9                   	leave
8010683a:	c3                   	ret

8010683b <uartgetc>:

static int
uartgetc(void)
{
8010683b:	f3 0f 1e fb          	endbr32
8010683f:	55                   	push   %ebp
80106840:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106842:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106847:	85 c0                	test   %eax,%eax
80106849:	75 07                	jne    80106852 <uartgetc+0x17>
    return -1;
8010684b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106850:	eb 2e                	jmp    80106880 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80106852:	68 fd 03 00 00       	push   $0x3fd
80106857:	e8 4d fe ff ff       	call   801066a9 <inb>
8010685c:	83 c4 04             	add    $0x4,%esp
8010685f:	0f b6 c0             	movzbl %al,%eax
80106862:	83 e0 01             	and    $0x1,%eax
80106865:	85 c0                	test   %eax,%eax
80106867:	75 07                	jne    80106870 <uartgetc+0x35>
    return -1;
80106869:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010686e:	eb 10                	jmp    80106880 <uartgetc+0x45>
  return inb(COM1+0);
80106870:	68 f8 03 00 00       	push   $0x3f8
80106875:	e8 2f fe ff ff       	call   801066a9 <inb>
8010687a:	83 c4 04             	add    $0x4,%esp
8010687d:	0f b6 c0             	movzbl %al,%eax
}
80106880:	c9                   	leave
80106881:	c3                   	ret

80106882 <uartintr>:

void
uartintr(void)
{
80106882:	f3 0f 1e fb          	endbr32
80106886:	55                   	push   %ebp
80106887:	89 e5                	mov    %esp,%ebp
80106889:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010688c:	83 ec 0c             	sub    $0xc,%esp
8010688f:	68 3b 68 10 80       	push   $0x8010683b
80106894:	e8 80 9f ff ff       	call   80100819 <consoleintr>
80106899:	83 c4 10             	add    $0x10,%esp
}
8010689c:	90                   	nop
8010689d:	c9                   	leave
8010689e:	c3                   	ret

8010689f <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010689f:	6a 00                	push   $0x0
  pushl $0
801068a1:	6a 00                	push   $0x0
  jmp alltraps
801068a3:	e9 11 f9 ff ff       	jmp    801061b9 <alltraps>

801068a8 <vector1>:
.globl vector1
vector1:
  pushl $0
801068a8:	6a 00                	push   $0x0
  pushl $1
801068aa:	6a 01                	push   $0x1
  jmp alltraps
801068ac:	e9 08 f9 ff ff       	jmp    801061b9 <alltraps>

801068b1 <vector2>:
.globl vector2
vector2:
  pushl $0
801068b1:	6a 00                	push   $0x0
  pushl $2
801068b3:	6a 02                	push   $0x2
  jmp alltraps
801068b5:	e9 ff f8 ff ff       	jmp    801061b9 <alltraps>

801068ba <vector3>:
.globl vector3
vector3:
  pushl $0
801068ba:	6a 00                	push   $0x0
  pushl $3
801068bc:	6a 03                	push   $0x3
  jmp alltraps
801068be:	e9 f6 f8 ff ff       	jmp    801061b9 <alltraps>

801068c3 <vector4>:
.globl vector4
vector4:
  pushl $0
801068c3:	6a 00                	push   $0x0
  pushl $4
801068c5:	6a 04                	push   $0x4
  jmp alltraps
801068c7:	e9 ed f8 ff ff       	jmp    801061b9 <alltraps>

801068cc <vector5>:
.globl vector5
vector5:
  pushl $0
801068cc:	6a 00                	push   $0x0
  pushl $5
801068ce:	6a 05                	push   $0x5
  jmp alltraps
801068d0:	e9 e4 f8 ff ff       	jmp    801061b9 <alltraps>

801068d5 <vector6>:
.globl vector6
vector6:
  pushl $0
801068d5:	6a 00                	push   $0x0
  pushl $6
801068d7:	6a 06                	push   $0x6
  jmp alltraps
801068d9:	e9 db f8 ff ff       	jmp    801061b9 <alltraps>

801068de <vector7>:
.globl vector7
vector7:
  pushl $0
801068de:	6a 00                	push   $0x0
  pushl $7
801068e0:	6a 07                	push   $0x7
  jmp alltraps
801068e2:	e9 d2 f8 ff ff       	jmp    801061b9 <alltraps>

801068e7 <vector8>:
.globl vector8
vector8:
  pushl $8
801068e7:	6a 08                	push   $0x8
  jmp alltraps
801068e9:	e9 cb f8 ff ff       	jmp    801061b9 <alltraps>

801068ee <vector9>:
.globl vector9
vector9:
  pushl $0
801068ee:	6a 00                	push   $0x0
  pushl $9
801068f0:	6a 09                	push   $0x9
  jmp alltraps
801068f2:	e9 c2 f8 ff ff       	jmp    801061b9 <alltraps>

801068f7 <vector10>:
.globl vector10
vector10:
  pushl $10
801068f7:	6a 0a                	push   $0xa
  jmp alltraps
801068f9:	e9 bb f8 ff ff       	jmp    801061b9 <alltraps>

801068fe <vector11>:
.globl vector11
vector11:
  pushl $11
801068fe:	6a 0b                	push   $0xb
  jmp alltraps
80106900:	e9 b4 f8 ff ff       	jmp    801061b9 <alltraps>

80106905 <vector12>:
.globl vector12
vector12:
  pushl $12
80106905:	6a 0c                	push   $0xc
  jmp alltraps
80106907:	e9 ad f8 ff ff       	jmp    801061b9 <alltraps>

8010690c <vector13>:
.globl vector13
vector13:
  pushl $13
8010690c:	6a 0d                	push   $0xd
  jmp alltraps
8010690e:	e9 a6 f8 ff ff       	jmp    801061b9 <alltraps>

80106913 <vector14>:
.globl vector14
vector14:
  pushl $14
80106913:	6a 0e                	push   $0xe
  jmp alltraps
80106915:	e9 9f f8 ff ff       	jmp    801061b9 <alltraps>

8010691a <vector15>:
.globl vector15
vector15:
  pushl $0
8010691a:	6a 00                	push   $0x0
  pushl $15
8010691c:	6a 0f                	push   $0xf
  jmp alltraps
8010691e:	e9 96 f8 ff ff       	jmp    801061b9 <alltraps>

80106923 <vector16>:
.globl vector16
vector16:
  pushl $0
80106923:	6a 00                	push   $0x0
  pushl $16
80106925:	6a 10                	push   $0x10
  jmp alltraps
80106927:	e9 8d f8 ff ff       	jmp    801061b9 <alltraps>

8010692c <vector17>:
.globl vector17
vector17:
  pushl $17
8010692c:	6a 11                	push   $0x11
  jmp alltraps
8010692e:	e9 86 f8 ff ff       	jmp    801061b9 <alltraps>

80106933 <vector18>:
.globl vector18
vector18:
  pushl $0
80106933:	6a 00                	push   $0x0
  pushl $18
80106935:	6a 12                	push   $0x12
  jmp alltraps
80106937:	e9 7d f8 ff ff       	jmp    801061b9 <alltraps>

8010693c <vector19>:
.globl vector19
vector19:
  pushl $0
8010693c:	6a 00                	push   $0x0
  pushl $19
8010693e:	6a 13                	push   $0x13
  jmp alltraps
80106940:	e9 74 f8 ff ff       	jmp    801061b9 <alltraps>

80106945 <vector20>:
.globl vector20
vector20:
  pushl $0
80106945:	6a 00                	push   $0x0
  pushl $20
80106947:	6a 14                	push   $0x14
  jmp alltraps
80106949:	e9 6b f8 ff ff       	jmp    801061b9 <alltraps>

8010694e <vector21>:
.globl vector21
vector21:
  pushl $0
8010694e:	6a 00                	push   $0x0
  pushl $21
80106950:	6a 15                	push   $0x15
  jmp alltraps
80106952:	e9 62 f8 ff ff       	jmp    801061b9 <alltraps>

80106957 <vector22>:
.globl vector22
vector22:
  pushl $0
80106957:	6a 00                	push   $0x0
  pushl $22
80106959:	6a 16                	push   $0x16
  jmp alltraps
8010695b:	e9 59 f8 ff ff       	jmp    801061b9 <alltraps>

80106960 <vector23>:
.globl vector23
vector23:
  pushl $0
80106960:	6a 00                	push   $0x0
  pushl $23
80106962:	6a 17                	push   $0x17
  jmp alltraps
80106964:	e9 50 f8 ff ff       	jmp    801061b9 <alltraps>

80106969 <vector24>:
.globl vector24
vector24:
  pushl $0
80106969:	6a 00                	push   $0x0
  pushl $24
8010696b:	6a 18                	push   $0x18
  jmp alltraps
8010696d:	e9 47 f8 ff ff       	jmp    801061b9 <alltraps>

80106972 <vector25>:
.globl vector25
vector25:
  pushl $0
80106972:	6a 00                	push   $0x0
  pushl $25
80106974:	6a 19                	push   $0x19
  jmp alltraps
80106976:	e9 3e f8 ff ff       	jmp    801061b9 <alltraps>

8010697b <vector26>:
.globl vector26
vector26:
  pushl $0
8010697b:	6a 00                	push   $0x0
  pushl $26
8010697d:	6a 1a                	push   $0x1a
  jmp alltraps
8010697f:	e9 35 f8 ff ff       	jmp    801061b9 <alltraps>

80106984 <vector27>:
.globl vector27
vector27:
  pushl $0
80106984:	6a 00                	push   $0x0
  pushl $27
80106986:	6a 1b                	push   $0x1b
  jmp alltraps
80106988:	e9 2c f8 ff ff       	jmp    801061b9 <alltraps>

8010698d <vector28>:
.globl vector28
vector28:
  pushl $0
8010698d:	6a 00                	push   $0x0
  pushl $28
8010698f:	6a 1c                	push   $0x1c
  jmp alltraps
80106991:	e9 23 f8 ff ff       	jmp    801061b9 <alltraps>

80106996 <vector29>:
.globl vector29
vector29:
  pushl $0
80106996:	6a 00                	push   $0x0
  pushl $29
80106998:	6a 1d                	push   $0x1d
  jmp alltraps
8010699a:	e9 1a f8 ff ff       	jmp    801061b9 <alltraps>

8010699f <vector30>:
.globl vector30
vector30:
  pushl $0
8010699f:	6a 00                	push   $0x0
  pushl $30
801069a1:	6a 1e                	push   $0x1e
  jmp alltraps
801069a3:	e9 11 f8 ff ff       	jmp    801061b9 <alltraps>

801069a8 <vector31>:
.globl vector31
vector31:
  pushl $0
801069a8:	6a 00                	push   $0x0
  pushl $31
801069aa:	6a 1f                	push   $0x1f
  jmp alltraps
801069ac:	e9 08 f8 ff ff       	jmp    801061b9 <alltraps>

801069b1 <vector32>:
.globl vector32
vector32:
  pushl $0
801069b1:	6a 00                	push   $0x0
  pushl $32
801069b3:	6a 20                	push   $0x20
  jmp alltraps
801069b5:	e9 ff f7 ff ff       	jmp    801061b9 <alltraps>

801069ba <vector33>:
.globl vector33
vector33:
  pushl $0
801069ba:	6a 00                	push   $0x0
  pushl $33
801069bc:	6a 21                	push   $0x21
  jmp alltraps
801069be:	e9 f6 f7 ff ff       	jmp    801061b9 <alltraps>

801069c3 <vector34>:
.globl vector34
vector34:
  pushl $0
801069c3:	6a 00                	push   $0x0
  pushl $34
801069c5:	6a 22                	push   $0x22
  jmp alltraps
801069c7:	e9 ed f7 ff ff       	jmp    801061b9 <alltraps>

801069cc <vector35>:
.globl vector35
vector35:
  pushl $0
801069cc:	6a 00                	push   $0x0
  pushl $35
801069ce:	6a 23                	push   $0x23
  jmp alltraps
801069d0:	e9 e4 f7 ff ff       	jmp    801061b9 <alltraps>

801069d5 <vector36>:
.globl vector36
vector36:
  pushl $0
801069d5:	6a 00                	push   $0x0
  pushl $36
801069d7:	6a 24                	push   $0x24
  jmp alltraps
801069d9:	e9 db f7 ff ff       	jmp    801061b9 <alltraps>

801069de <vector37>:
.globl vector37
vector37:
  pushl $0
801069de:	6a 00                	push   $0x0
  pushl $37
801069e0:	6a 25                	push   $0x25
  jmp alltraps
801069e2:	e9 d2 f7 ff ff       	jmp    801061b9 <alltraps>

801069e7 <vector38>:
.globl vector38
vector38:
  pushl $0
801069e7:	6a 00                	push   $0x0
  pushl $38
801069e9:	6a 26                	push   $0x26
  jmp alltraps
801069eb:	e9 c9 f7 ff ff       	jmp    801061b9 <alltraps>

801069f0 <vector39>:
.globl vector39
vector39:
  pushl $0
801069f0:	6a 00                	push   $0x0
  pushl $39
801069f2:	6a 27                	push   $0x27
  jmp alltraps
801069f4:	e9 c0 f7 ff ff       	jmp    801061b9 <alltraps>

801069f9 <vector40>:
.globl vector40
vector40:
  pushl $0
801069f9:	6a 00                	push   $0x0
  pushl $40
801069fb:	6a 28                	push   $0x28
  jmp alltraps
801069fd:	e9 b7 f7 ff ff       	jmp    801061b9 <alltraps>

80106a02 <vector41>:
.globl vector41
vector41:
  pushl $0
80106a02:	6a 00                	push   $0x0
  pushl $41
80106a04:	6a 29                	push   $0x29
  jmp alltraps
80106a06:	e9 ae f7 ff ff       	jmp    801061b9 <alltraps>

80106a0b <vector42>:
.globl vector42
vector42:
  pushl $0
80106a0b:	6a 00                	push   $0x0
  pushl $42
80106a0d:	6a 2a                	push   $0x2a
  jmp alltraps
80106a0f:	e9 a5 f7 ff ff       	jmp    801061b9 <alltraps>

80106a14 <vector43>:
.globl vector43
vector43:
  pushl $0
80106a14:	6a 00                	push   $0x0
  pushl $43
80106a16:	6a 2b                	push   $0x2b
  jmp alltraps
80106a18:	e9 9c f7 ff ff       	jmp    801061b9 <alltraps>

80106a1d <vector44>:
.globl vector44
vector44:
  pushl $0
80106a1d:	6a 00                	push   $0x0
  pushl $44
80106a1f:	6a 2c                	push   $0x2c
  jmp alltraps
80106a21:	e9 93 f7 ff ff       	jmp    801061b9 <alltraps>

80106a26 <vector45>:
.globl vector45
vector45:
  pushl $0
80106a26:	6a 00                	push   $0x0
  pushl $45
80106a28:	6a 2d                	push   $0x2d
  jmp alltraps
80106a2a:	e9 8a f7 ff ff       	jmp    801061b9 <alltraps>

80106a2f <vector46>:
.globl vector46
vector46:
  pushl $0
80106a2f:	6a 00                	push   $0x0
  pushl $46
80106a31:	6a 2e                	push   $0x2e
  jmp alltraps
80106a33:	e9 81 f7 ff ff       	jmp    801061b9 <alltraps>

80106a38 <vector47>:
.globl vector47
vector47:
  pushl $0
80106a38:	6a 00                	push   $0x0
  pushl $47
80106a3a:	6a 2f                	push   $0x2f
  jmp alltraps
80106a3c:	e9 78 f7 ff ff       	jmp    801061b9 <alltraps>

80106a41 <vector48>:
.globl vector48
vector48:
  pushl $0
80106a41:	6a 00                	push   $0x0
  pushl $48
80106a43:	6a 30                	push   $0x30
  jmp alltraps
80106a45:	e9 6f f7 ff ff       	jmp    801061b9 <alltraps>

80106a4a <vector49>:
.globl vector49
vector49:
  pushl $0
80106a4a:	6a 00                	push   $0x0
  pushl $49
80106a4c:	6a 31                	push   $0x31
  jmp alltraps
80106a4e:	e9 66 f7 ff ff       	jmp    801061b9 <alltraps>

80106a53 <vector50>:
.globl vector50
vector50:
  pushl $0
80106a53:	6a 00                	push   $0x0
  pushl $50
80106a55:	6a 32                	push   $0x32
  jmp alltraps
80106a57:	e9 5d f7 ff ff       	jmp    801061b9 <alltraps>

80106a5c <vector51>:
.globl vector51
vector51:
  pushl $0
80106a5c:	6a 00                	push   $0x0
  pushl $51
80106a5e:	6a 33                	push   $0x33
  jmp alltraps
80106a60:	e9 54 f7 ff ff       	jmp    801061b9 <alltraps>

80106a65 <vector52>:
.globl vector52
vector52:
  pushl $0
80106a65:	6a 00                	push   $0x0
  pushl $52
80106a67:	6a 34                	push   $0x34
  jmp alltraps
80106a69:	e9 4b f7 ff ff       	jmp    801061b9 <alltraps>

80106a6e <vector53>:
.globl vector53
vector53:
  pushl $0
80106a6e:	6a 00                	push   $0x0
  pushl $53
80106a70:	6a 35                	push   $0x35
  jmp alltraps
80106a72:	e9 42 f7 ff ff       	jmp    801061b9 <alltraps>

80106a77 <vector54>:
.globl vector54
vector54:
  pushl $0
80106a77:	6a 00                	push   $0x0
  pushl $54
80106a79:	6a 36                	push   $0x36
  jmp alltraps
80106a7b:	e9 39 f7 ff ff       	jmp    801061b9 <alltraps>

80106a80 <vector55>:
.globl vector55
vector55:
  pushl $0
80106a80:	6a 00                	push   $0x0
  pushl $55
80106a82:	6a 37                	push   $0x37
  jmp alltraps
80106a84:	e9 30 f7 ff ff       	jmp    801061b9 <alltraps>

80106a89 <vector56>:
.globl vector56
vector56:
  pushl $0
80106a89:	6a 00                	push   $0x0
  pushl $56
80106a8b:	6a 38                	push   $0x38
  jmp alltraps
80106a8d:	e9 27 f7 ff ff       	jmp    801061b9 <alltraps>

80106a92 <vector57>:
.globl vector57
vector57:
  pushl $0
80106a92:	6a 00                	push   $0x0
  pushl $57
80106a94:	6a 39                	push   $0x39
  jmp alltraps
80106a96:	e9 1e f7 ff ff       	jmp    801061b9 <alltraps>

80106a9b <vector58>:
.globl vector58
vector58:
  pushl $0
80106a9b:	6a 00                	push   $0x0
  pushl $58
80106a9d:	6a 3a                	push   $0x3a
  jmp alltraps
80106a9f:	e9 15 f7 ff ff       	jmp    801061b9 <alltraps>

80106aa4 <vector59>:
.globl vector59
vector59:
  pushl $0
80106aa4:	6a 00                	push   $0x0
  pushl $59
80106aa6:	6a 3b                	push   $0x3b
  jmp alltraps
80106aa8:	e9 0c f7 ff ff       	jmp    801061b9 <alltraps>

80106aad <vector60>:
.globl vector60
vector60:
  pushl $0
80106aad:	6a 00                	push   $0x0
  pushl $60
80106aaf:	6a 3c                	push   $0x3c
  jmp alltraps
80106ab1:	e9 03 f7 ff ff       	jmp    801061b9 <alltraps>

80106ab6 <vector61>:
.globl vector61
vector61:
  pushl $0
80106ab6:	6a 00                	push   $0x0
  pushl $61
80106ab8:	6a 3d                	push   $0x3d
  jmp alltraps
80106aba:	e9 fa f6 ff ff       	jmp    801061b9 <alltraps>

80106abf <vector62>:
.globl vector62
vector62:
  pushl $0
80106abf:	6a 00                	push   $0x0
  pushl $62
80106ac1:	6a 3e                	push   $0x3e
  jmp alltraps
80106ac3:	e9 f1 f6 ff ff       	jmp    801061b9 <alltraps>

80106ac8 <vector63>:
.globl vector63
vector63:
  pushl $0
80106ac8:	6a 00                	push   $0x0
  pushl $63
80106aca:	6a 3f                	push   $0x3f
  jmp alltraps
80106acc:	e9 e8 f6 ff ff       	jmp    801061b9 <alltraps>

80106ad1 <vector64>:
.globl vector64
vector64:
  pushl $0
80106ad1:	6a 00                	push   $0x0
  pushl $64
80106ad3:	6a 40                	push   $0x40
  jmp alltraps
80106ad5:	e9 df f6 ff ff       	jmp    801061b9 <alltraps>

80106ada <vector65>:
.globl vector65
vector65:
  pushl $0
80106ada:	6a 00                	push   $0x0
  pushl $65
80106adc:	6a 41                	push   $0x41
  jmp alltraps
80106ade:	e9 d6 f6 ff ff       	jmp    801061b9 <alltraps>

80106ae3 <vector66>:
.globl vector66
vector66:
  pushl $0
80106ae3:	6a 00                	push   $0x0
  pushl $66
80106ae5:	6a 42                	push   $0x42
  jmp alltraps
80106ae7:	e9 cd f6 ff ff       	jmp    801061b9 <alltraps>

80106aec <vector67>:
.globl vector67
vector67:
  pushl $0
80106aec:	6a 00                	push   $0x0
  pushl $67
80106aee:	6a 43                	push   $0x43
  jmp alltraps
80106af0:	e9 c4 f6 ff ff       	jmp    801061b9 <alltraps>

80106af5 <vector68>:
.globl vector68
vector68:
  pushl $0
80106af5:	6a 00                	push   $0x0
  pushl $68
80106af7:	6a 44                	push   $0x44
  jmp alltraps
80106af9:	e9 bb f6 ff ff       	jmp    801061b9 <alltraps>

80106afe <vector69>:
.globl vector69
vector69:
  pushl $0
80106afe:	6a 00                	push   $0x0
  pushl $69
80106b00:	6a 45                	push   $0x45
  jmp alltraps
80106b02:	e9 b2 f6 ff ff       	jmp    801061b9 <alltraps>

80106b07 <vector70>:
.globl vector70
vector70:
  pushl $0
80106b07:	6a 00                	push   $0x0
  pushl $70
80106b09:	6a 46                	push   $0x46
  jmp alltraps
80106b0b:	e9 a9 f6 ff ff       	jmp    801061b9 <alltraps>

80106b10 <vector71>:
.globl vector71
vector71:
  pushl $0
80106b10:	6a 00                	push   $0x0
  pushl $71
80106b12:	6a 47                	push   $0x47
  jmp alltraps
80106b14:	e9 a0 f6 ff ff       	jmp    801061b9 <alltraps>

80106b19 <vector72>:
.globl vector72
vector72:
  pushl $0
80106b19:	6a 00                	push   $0x0
  pushl $72
80106b1b:	6a 48                	push   $0x48
  jmp alltraps
80106b1d:	e9 97 f6 ff ff       	jmp    801061b9 <alltraps>

80106b22 <vector73>:
.globl vector73
vector73:
  pushl $0
80106b22:	6a 00                	push   $0x0
  pushl $73
80106b24:	6a 49                	push   $0x49
  jmp alltraps
80106b26:	e9 8e f6 ff ff       	jmp    801061b9 <alltraps>

80106b2b <vector74>:
.globl vector74
vector74:
  pushl $0
80106b2b:	6a 00                	push   $0x0
  pushl $74
80106b2d:	6a 4a                	push   $0x4a
  jmp alltraps
80106b2f:	e9 85 f6 ff ff       	jmp    801061b9 <alltraps>

80106b34 <vector75>:
.globl vector75
vector75:
  pushl $0
80106b34:	6a 00                	push   $0x0
  pushl $75
80106b36:	6a 4b                	push   $0x4b
  jmp alltraps
80106b38:	e9 7c f6 ff ff       	jmp    801061b9 <alltraps>

80106b3d <vector76>:
.globl vector76
vector76:
  pushl $0
80106b3d:	6a 00                	push   $0x0
  pushl $76
80106b3f:	6a 4c                	push   $0x4c
  jmp alltraps
80106b41:	e9 73 f6 ff ff       	jmp    801061b9 <alltraps>

80106b46 <vector77>:
.globl vector77
vector77:
  pushl $0
80106b46:	6a 00                	push   $0x0
  pushl $77
80106b48:	6a 4d                	push   $0x4d
  jmp alltraps
80106b4a:	e9 6a f6 ff ff       	jmp    801061b9 <alltraps>

80106b4f <vector78>:
.globl vector78
vector78:
  pushl $0
80106b4f:	6a 00                	push   $0x0
  pushl $78
80106b51:	6a 4e                	push   $0x4e
  jmp alltraps
80106b53:	e9 61 f6 ff ff       	jmp    801061b9 <alltraps>

80106b58 <vector79>:
.globl vector79
vector79:
  pushl $0
80106b58:	6a 00                	push   $0x0
  pushl $79
80106b5a:	6a 4f                	push   $0x4f
  jmp alltraps
80106b5c:	e9 58 f6 ff ff       	jmp    801061b9 <alltraps>

80106b61 <vector80>:
.globl vector80
vector80:
  pushl $0
80106b61:	6a 00                	push   $0x0
  pushl $80
80106b63:	6a 50                	push   $0x50
  jmp alltraps
80106b65:	e9 4f f6 ff ff       	jmp    801061b9 <alltraps>

80106b6a <vector81>:
.globl vector81
vector81:
  pushl $0
80106b6a:	6a 00                	push   $0x0
  pushl $81
80106b6c:	6a 51                	push   $0x51
  jmp alltraps
80106b6e:	e9 46 f6 ff ff       	jmp    801061b9 <alltraps>

80106b73 <vector82>:
.globl vector82
vector82:
  pushl $0
80106b73:	6a 00                	push   $0x0
  pushl $82
80106b75:	6a 52                	push   $0x52
  jmp alltraps
80106b77:	e9 3d f6 ff ff       	jmp    801061b9 <alltraps>

80106b7c <vector83>:
.globl vector83
vector83:
  pushl $0
80106b7c:	6a 00                	push   $0x0
  pushl $83
80106b7e:	6a 53                	push   $0x53
  jmp alltraps
80106b80:	e9 34 f6 ff ff       	jmp    801061b9 <alltraps>

80106b85 <vector84>:
.globl vector84
vector84:
  pushl $0
80106b85:	6a 00                	push   $0x0
  pushl $84
80106b87:	6a 54                	push   $0x54
  jmp alltraps
80106b89:	e9 2b f6 ff ff       	jmp    801061b9 <alltraps>

80106b8e <vector85>:
.globl vector85
vector85:
  pushl $0
80106b8e:	6a 00                	push   $0x0
  pushl $85
80106b90:	6a 55                	push   $0x55
  jmp alltraps
80106b92:	e9 22 f6 ff ff       	jmp    801061b9 <alltraps>

80106b97 <vector86>:
.globl vector86
vector86:
  pushl $0
80106b97:	6a 00                	push   $0x0
  pushl $86
80106b99:	6a 56                	push   $0x56
  jmp alltraps
80106b9b:	e9 19 f6 ff ff       	jmp    801061b9 <alltraps>

80106ba0 <vector87>:
.globl vector87
vector87:
  pushl $0
80106ba0:	6a 00                	push   $0x0
  pushl $87
80106ba2:	6a 57                	push   $0x57
  jmp alltraps
80106ba4:	e9 10 f6 ff ff       	jmp    801061b9 <alltraps>

80106ba9 <vector88>:
.globl vector88
vector88:
  pushl $0
80106ba9:	6a 00                	push   $0x0
  pushl $88
80106bab:	6a 58                	push   $0x58
  jmp alltraps
80106bad:	e9 07 f6 ff ff       	jmp    801061b9 <alltraps>

80106bb2 <vector89>:
.globl vector89
vector89:
  pushl $0
80106bb2:	6a 00                	push   $0x0
  pushl $89
80106bb4:	6a 59                	push   $0x59
  jmp alltraps
80106bb6:	e9 fe f5 ff ff       	jmp    801061b9 <alltraps>

80106bbb <vector90>:
.globl vector90
vector90:
  pushl $0
80106bbb:	6a 00                	push   $0x0
  pushl $90
80106bbd:	6a 5a                	push   $0x5a
  jmp alltraps
80106bbf:	e9 f5 f5 ff ff       	jmp    801061b9 <alltraps>

80106bc4 <vector91>:
.globl vector91
vector91:
  pushl $0
80106bc4:	6a 00                	push   $0x0
  pushl $91
80106bc6:	6a 5b                	push   $0x5b
  jmp alltraps
80106bc8:	e9 ec f5 ff ff       	jmp    801061b9 <alltraps>

80106bcd <vector92>:
.globl vector92
vector92:
  pushl $0
80106bcd:	6a 00                	push   $0x0
  pushl $92
80106bcf:	6a 5c                	push   $0x5c
  jmp alltraps
80106bd1:	e9 e3 f5 ff ff       	jmp    801061b9 <alltraps>

80106bd6 <vector93>:
.globl vector93
vector93:
  pushl $0
80106bd6:	6a 00                	push   $0x0
  pushl $93
80106bd8:	6a 5d                	push   $0x5d
  jmp alltraps
80106bda:	e9 da f5 ff ff       	jmp    801061b9 <alltraps>

80106bdf <vector94>:
.globl vector94
vector94:
  pushl $0
80106bdf:	6a 00                	push   $0x0
  pushl $94
80106be1:	6a 5e                	push   $0x5e
  jmp alltraps
80106be3:	e9 d1 f5 ff ff       	jmp    801061b9 <alltraps>

80106be8 <vector95>:
.globl vector95
vector95:
  pushl $0
80106be8:	6a 00                	push   $0x0
  pushl $95
80106bea:	6a 5f                	push   $0x5f
  jmp alltraps
80106bec:	e9 c8 f5 ff ff       	jmp    801061b9 <alltraps>

80106bf1 <vector96>:
.globl vector96
vector96:
  pushl $0
80106bf1:	6a 00                	push   $0x0
  pushl $96
80106bf3:	6a 60                	push   $0x60
  jmp alltraps
80106bf5:	e9 bf f5 ff ff       	jmp    801061b9 <alltraps>

80106bfa <vector97>:
.globl vector97
vector97:
  pushl $0
80106bfa:	6a 00                	push   $0x0
  pushl $97
80106bfc:	6a 61                	push   $0x61
  jmp alltraps
80106bfe:	e9 b6 f5 ff ff       	jmp    801061b9 <alltraps>

80106c03 <vector98>:
.globl vector98
vector98:
  pushl $0
80106c03:	6a 00                	push   $0x0
  pushl $98
80106c05:	6a 62                	push   $0x62
  jmp alltraps
80106c07:	e9 ad f5 ff ff       	jmp    801061b9 <alltraps>

80106c0c <vector99>:
.globl vector99
vector99:
  pushl $0
80106c0c:	6a 00                	push   $0x0
  pushl $99
80106c0e:	6a 63                	push   $0x63
  jmp alltraps
80106c10:	e9 a4 f5 ff ff       	jmp    801061b9 <alltraps>

80106c15 <vector100>:
.globl vector100
vector100:
  pushl $0
80106c15:	6a 00                	push   $0x0
  pushl $100
80106c17:	6a 64                	push   $0x64
  jmp alltraps
80106c19:	e9 9b f5 ff ff       	jmp    801061b9 <alltraps>

80106c1e <vector101>:
.globl vector101
vector101:
  pushl $0
80106c1e:	6a 00                	push   $0x0
  pushl $101
80106c20:	6a 65                	push   $0x65
  jmp alltraps
80106c22:	e9 92 f5 ff ff       	jmp    801061b9 <alltraps>

80106c27 <vector102>:
.globl vector102
vector102:
  pushl $0
80106c27:	6a 00                	push   $0x0
  pushl $102
80106c29:	6a 66                	push   $0x66
  jmp alltraps
80106c2b:	e9 89 f5 ff ff       	jmp    801061b9 <alltraps>

80106c30 <vector103>:
.globl vector103
vector103:
  pushl $0
80106c30:	6a 00                	push   $0x0
  pushl $103
80106c32:	6a 67                	push   $0x67
  jmp alltraps
80106c34:	e9 80 f5 ff ff       	jmp    801061b9 <alltraps>

80106c39 <vector104>:
.globl vector104
vector104:
  pushl $0
80106c39:	6a 00                	push   $0x0
  pushl $104
80106c3b:	6a 68                	push   $0x68
  jmp alltraps
80106c3d:	e9 77 f5 ff ff       	jmp    801061b9 <alltraps>

80106c42 <vector105>:
.globl vector105
vector105:
  pushl $0
80106c42:	6a 00                	push   $0x0
  pushl $105
80106c44:	6a 69                	push   $0x69
  jmp alltraps
80106c46:	e9 6e f5 ff ff       	jmp    801061b9 <alltraps>

80106c4b <vector106>:
.globl vector106
vector106:
  pushl $0
80106c4b:	6a 00                	push   $0x0
  pushl $106
80106c4d:	6a 6a                	push   $0x6a
  jmp alltraps
80106c4f:	e9 65 f5 ff ff       	jmp    801061b9 <alltraps>

80106c54 <vector107>:
.globl vector107
vector107:
  pushl $0
80106c54:	6a 00                	push   $0x0
  pushl $107
80106c56:	6a 6b                	push   $0x6b
  jmp alltraps
80106c58:	e9 5c f5 ff ff       	jmp    801061b9 <alltraps>

80106c5d <vector108>:
.globl vector108
vector108:
  pushl $0
80106c5d:	6a 00                	push   $0x0
  pushl $108
80106c5f:	6a 6c                	push   $0x6c
  jmp alltraps
80106c61:	e9 53 f5 ff ff       	jmp    801061b9 <alltraps>

80106c66 <vector109>:
.globl vector109
vector109:
  pushl $0
80106c66:	6a 00                	push   $0x0
  pushl $109
80106c68:	6a 6d                	push   $0x6d
  jmp alltraps
80106c6a:	e9 4a f5 ff ff       	jmp    801061b9 <alltraps>

80106c6f <vector110>:
.globl vector110
vector110:
  pushl $0
80106c6f:	6a 00                	push   $0x0
  pushl $110
80106c71:	6a 6e                	push   $0x6e
  jmp alltraps
80106c73:	e9 41 f5 ff ff       	jmp    801061b9 <alltraps>

80106c78 <vector111>:
.globl vector111
vector111:
  pushl $0
80106c78:	6a 00                	push   $0x0
  pushl $111
80106c7a:	6a 6f                	push   $0x6f
  jmp alltraps
80106c7c:	e9 38 f5 ff ff       	jmp    801061b9 <alltraps>

80106c81 <vector112>:
.globl vector112
vector112:
  pushl $0
80106c81:	6a 00                	push   $0x0
  pushl $112
80106c83:	6a 70                	push   $0x70
  jmp alltraps
80106c85:	e9 2f f5 ff ff       	jmp    801061b9 <alltraps>

80106c8a <vector113>:
.globl vector113
vector113:
  pushl $0
80106c8a:	6a 00                	push   $0x0
  pushl $113
80106c8c:	6a 71                	push   $0x71
  jmp alltraps
80106c8e:	e9 26 f5 ff ff       	jmp    801061b9 <alltraps>

80106c93 <vector114>:
.globl vector114
vector114:
  pushl $0
80106c93:	6a 00                	push   $0x0
  pushl $114
80106c95:	6a 72                	push   $0x72
  jmp alltraps
80106c97:	e9 1d f5 ff ff       	jmp    801061b9 <alltraps>

80106c9c <vector115>:
.globl vector115
vector115:
  pushl $0
80106c9c:	6a 00                	push   $0x0
  pushl $115
80106c9e:	6a 73                	push   $0x73
  jmp alltraps
80106ca0:	e9 14 f5 ff ff       	jmp    801061b9 <alltraps>

80106ca5 <vector116>:
.globl vector116
vector116:
  pushl $0
80106ca5:	6a 00                	push   $0x0
  pushl $116
80106ca7:	6a 74                	push   $0x74
  jmp alltraps
80106ca9:	e9 0b f5 ff ff       	jmp    801061b9 <alltraps>

80106cae <vector117>:
.globl vector117
vector117:
  pushl $0
80106cae:	6a 00                	push   $0x0
  pushl $117
80106cb0:	6a 75                	push   $0x75
  jmp alltraps
80106cb2:	e9 02 f5 ff ff       	jmp    801061b9 <alltraps>

80106cb7 <vector118>:
.globl vector118
vector118:
  pushl $0
80106cb7:	6a 00                	push   $0x0
  pushl $118
80106cb9:	6a 76                	push   $0x76
  jmp alltraps
80106cbb:	e9 f9 f4 ff ff       	jmp    801061b9 <alltraps>

80106cc0 <vector119>:
.globl vector119
vector119:
  pushl $0
80106cc0:	6a 00                	push   $0x0
  pushl $119
80106cc2:	6a 77                	push   $0x77
  jmp alltraps
80106cc4:	e9 f0 f4 ff ff       	jmp    801061b9 <alltraps>

80106cc9 <vector120>:
.globl vector120
vector120:
  pushl $0
80106cc9:	6a 00                	push   $0x0
  pushl $120
80106ccb:	6a 78                	push   $0x78
  jmp alltraps
80106ccd:	e9 e7 f4 ff ff       	jmp    801061b9 <alltraps>

80106cd2 <vector121>:
.globl vector121
vector121:
  pushl $0
80106cd2:	6a 00                	push   $0x0
  pushl $121
80106cd4:	6a 79                	push   $0x79
  jmp alltraps
80106cd6:	e9 de f4 ff ff       	jmp    801061b9 <alltraps>

80106cdb <vector122>:
.globl vector122
vector122:
  pushl $0
80106cdb:	6a 00                	push   $0x0
  pushl $122
80106cdd:	6a 7a                	push   $0x7a
  jmp alltraps
80106cdf:	e9 d5 f4 ff ff       	jmp    801061b9 <alltraps>

80106ce4 <vector123>:
.globl vector123
vector123:
  pushl $0
80106ce4:	6a 00                	push   $0x0
  pushl $123
80106ce6:	6a 7b                	push   $0x7b
  jmp alltraps
80106ce8:	e9 cc f4 ff ff       	jmp    801061b9 <alltraps>

80106ced <vector124>:
.globl vector124
vector124:
  pushl $0
80106ced:	6a 00                	push   $0x0
  pushl $124
80106cef:	6a 7c                	push   $0x7c
  jmp alltraps
80106cf1:	e9 c3 f4 ff ff       	jmp    801061b9 <alltraps>

80106cf6 <vector125>:
.globl vector125
vector125:
  pushl $0
80106cf6:	6a 00                	push   $0x0
  pushl $125
80106cf8:	6a 7d                	push   $0x7d
  jmp alltraps
80106cfa:	e9 ba f4 ff ff       	jmp    801061b9 <alltraps>

80106cff <vector126>:
.globl vector126
vector126:
  pushl $0
80106cff:	6a 00                	push   $0x0
  pushl $126
80106d01:	6a 7e                	push   $0x7e
  jmp alltraps
80106d03:	e9 b1 f4 ff ff       	jmp    801061b9 <alltraps>

80106d08 <vector127>:
.globl vector127
vector127:
  pushl $0
80106d08:	6a 00                	push   $0x0
  pushl $127
80106d0a:	6a 7f                	push   $0x7f
  jmp alltraps
80106d0c:	e9 a8 f4 ff ff       	jmp    801061b9 <alltraps>

80106d11 <vector128>:
.globl vector128
vector128:
  pushl $0
80106d11:	6a 00                	push   $0x0
  pushl $128
80106d13:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106d18:	e9 9c f4 ff ff       	jmp    801061b9 <alltraps>

80106d1d <vector129>:
.globl vector129
vector129:
  pushl $0
80106d1d:	6a 00                	push   $0x0
  pushl $129
80106d1f:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106d24:	e9 90 f4 ff ff       	jmp    801061b9 <alltraps>

80106d29 <vector130>:
.globl vector130
vector130:
  pushl $0
80106d29:	6a 00                	push   $0x0
  pushl $130
80106d2b:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106d30:	e9 84 f4 ff ff       	jmp    801061b9 <alltraps>

80106d35 <vector131>:
.globl vector131
vector131:
  pushl $0
80106d35:	6a 00                	push   $0x0
  pushl $131
80106d37:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106d3c:	e9 78 f4 ff ff       	jmp    801061b9 <alltraps>

80106d41 <vector132>:
.globl vector132
vector132:
  pushl $0
80106d41:	6a 00                	push   $0x0
  pushl $132
80106d43:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106d48:	e9 6c f4 ff ff       	jmp    801061b9 <alltraps>

80106d4d <vector133>:
.globl vector133
vector133:
  pushl $0
80106d4d:	6a 00                	push   $0x0
  pushl $133
80106d4f:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106d54:	e9 60 f4 ff ff       	jmp    801061b9 <alltraps>

80106d59 <vector134>:
.globl vector134
vector134:
  pushl $0
80106d59:	6a 00                	push   $0x0
  pushl $134
80106d5b:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106d60:	e9 54 f4 ff ff       	jmp    801061b9 <alltraps>

80106d65 <vector135>:
.globl vector135
vector135:
  pushl $0
80106d65:	6a 00                	push   $0x0
  pushl $135
80106d67:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106d6c:	e9 48 f4 ff ff       	jmp    801061b9 <alltraps>

80106d71 <vector136>:
.globl vector136
vector136:
  pushl $0
80106d71:	6a 00                	push   $0x0
  pushl $136
80106d73:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106d78:	e9 3c f4 ff ff       	jmp    801061b9 <alltraps>

80106d7d <vector137>:
.globl vector137
vector137:
  pushl $0
80106d7d:	6a 00                	push   $0x0
  pushl $137
80106d7f:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106d84:	e9 30 f4 ff ff       	jmp    801061b9 <alltraps>

80106d89 <vector138>:
.globl vector138
vector138:
  pushl $0
80106d89:	6a 00                	push   $0x0
  pushl $138
80106d8b:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106d90:	e9 24 f4 ff ff       	jmp    801061b9 <alltraps>

80106d95 <vector139>:
.globl vector139
vector139:
  pushl $0
80106d95:	6a 00                	push   $0x0
  pushl $139
80106d97:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106d9c:	e9 18 f4 ff ff       	jmp    801061b9 <alltraps>

80106da1 <vector140>:
.globl vector140
vector140:
  pushl $0
80106da1:	6a 00                	push   $0x0
  pushl $140
80106da3:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106da8:	e9 0c f4 ff ff       	jmp    801061b9 <alltraps>

80106dad <vector141>:
.globl vector141
vector141:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $141
80106daf:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106db4:	e9 00 f4 ff ff       	jmp    801061b9 <alltraps>

80106db9 <vector142>:
.globl vector142
vector142:
  pushl $0
80106db9:	6a 00                	push   $0x0
  pushl $142
80106dbb:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106dc0:	e9 f4 f3 ff ff       	jmp    801061b9 <alltraps>

80106dc5 <vector143>:
.globl vector143
vector143:
  pushl $0
80106dc5:	6a 00                	push   $0x0
  pushl $143
80106dc7:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106dcc:	e9 e8 f3 ff ff       	jmp    801061b9 <alltraps>

80106dd1 <vector144>:
.globl vector144
vector144:
  pushl $0
80106dd1:	6a 00                	push   $0x0
  pushl $144
80106dd3:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106dd8:	e9 dc f3 ff ff       	jmp    801061b9 <alltraps>

80106ddd <vector145>:
.globl vector145
vector145:
  pushl $0
80106ddd:	6a 00                	push   $0x0
  pushl $145
80106ddf:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106de4:	e9 d0 f3 ff ff       	jmp    801061b9 <alltraps>

80106de9 <vector146>:
.globl vector146
vector146:
  pushl $0
80106de9:	6a 00                	push   $0x0
  pushl $146
80106deb:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106df0:	e9 c4 f3 ff ff       	jmp    801061b9 <alltraps>

80106df5 <vector147>:
.globl vector147
vector147:
  pushl $0
80106df5:	6a 00                	push   $0x0
  pushl $147
80106df7:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106dfc:	e9 b8 f3 ff ff       	jmp    801061b9 <alltraps>

80106e01 <vector148>:
.globl vector148
vector148:
  pushl $0
80106e01:	6a 00                	push   $0x0
  pushl $148
80106e03:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106e08:	e9 ac f3 ff ff       	jmp    801061b9 <alltraps>

80106e0d <vector149>:
.globl vector149
vector149:
  pushl $0
80106e0d:	6a 00                	push   $0x0
  pushl $149
80106e0f:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106e14:	e9 a0 f3 ff ff       	jmp    801061b9 <alltraps>

80106e19 <vector150>:
.globl vector150
vector150:
  pushl $0
80106e19:	6a 00                	push   $0x0
  pushl $150
80106e1b:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106e20:	e9 94 f3 ff ff       	jmp    801061b9 <alltraps>

80106e25 <vector151>:
.globl vector151
vector151:
  pushl $0
80106e25:	6a 00                	push   $0x0
  pushl $151
80106e27:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106e2c:	e9 88 f3 ff ff       	jmp    801061b9 <alltraps>

80106e31 <vector152>:
.globl vector152
vector152:
  pushl $0
80106e31:	6a 00                	push   $0x0
  pushl $152
80106e33:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106e38:	e9 7c f3 ff ff       	jmp    801061b9 <alltraps>

80106e3d <vector153>:
.globl vector153
vector153:
  pushl $0
80106e3d:	6a 00                	push   $0x0
  pushl $153
80106e3f:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106e44:	e9 70 f3 ff ff       	jmp    801061b9 <alltraps>

80106e49 <vector154>:
.globl vector154
vector154:
  pushl $0
80106e49:	6a 00                	push   $0x0
  pushl $154
80106e4b:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106e50:	e9 64 f3 ff ff       	jmp    801061b9 <alltraps>

80106e55 <vector155>:
.globl vector155
vector155:
  pushl $0
80106e55:	6a 00                	push   $0x0
  pushl $155
80106e57:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106e5c:	e9 58 f3 ff ff       	jmp    801061b9 <alltraps>

80106e61 <vector156>:
.globl vector156
vector156:
  pushl $0
80106e61:	6a 00                	push   $0x0
  pushl $156
80106e63:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106e68:	e9 4c f3 ff ff       	jmp    801061b9 <alltraps>

80106e6d <vector157>:
.globl vector157
vector157:
  pushl $0
80106e6d:	6a 00                	push   $0x0
  pushl $157
80106e6f:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106e74:	e9 40 f3 ff ff       	jmp    801061b9 <alltraps>

80106e79 <vector158>:
.globl vector158
vector158:
  pushl $0
80106e79:	6a 00                	push   $0x0
  pushl $158
80106e7b:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106e80:	e9 34 f3 ff ff       	jmp    801061b9 <alltraps>

80106e85 <vector159>:
.globl vector159
vector159:
  pushl $0
80106e85:	6a 00                	push   $0x0
  pushl $159
80106e87:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106e8c:	e9 28 f3 ff ff       	jmp    801061b9 <alltraps>

80106e91 <vector160>:
.globl vector160
vector160:
  pushl $0
80106e91:	6a 00                	push   $0x0
  pushl $160
80106e93:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106e98:	e9 1c f3 ff ff       	jmp    801061b9 <alltraps>

80106e9d <vector161>:
.globl vector161
vector161:
  pushl $0
80106e9d:	6a 00                	push   $0x0
  pushl $161
80106e9f:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106ea4:	e9 10 f3 ff ff       	jmp    801061b9 <alltraps>

80106ea9 <vector162>:
.globl vector162
vector162:
  pushl $0
80106ea9:	6a 00                	push   $0x0
  pushl $162
80106eab:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106eb0:	e9 04 f3 ff ff       	jmp    801061b9 <alltraps>

80106eb5 <vector163>:
.globl vector163
vector163:
  pushl $0
80106eb5:	6a 00                	push   $0x0
  pushl $163
80106eb7:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106ebc:	e9 f8 f2 ff ff       	jmp    801061b9 <alltraps>

80106ec1 <vector164>:
.globl vector164
vector164:
  pushl $0
80106ec1:	6a 00                	push   $0x0
  pushl $164
80106ec3:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106ec8:	e9 ec f2 ff ff       	jmp    801061b9 <alltraps>

80106ecd <vector165>:
.globl vector165
vector165:
  pushl $0
80106ecd:	6a 00                	push   $0x0
  pushl $165
80106ecf:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106ed4:	e9 e0 f2 ff ff       	jmp    801061b9 <alltraps>

80106ed9 <vector166>:
.globl vector166
vector166:
  pushl $0
80106ed9:	6a 00                	push   $0x0
  pushl $166
80106edb:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106ee0:	e9 d4 f2 ff ff       	jmp    801061b9 <alltraps>

80106ee5 <vector167>:
.globl vector167
vector167:
  pushl $0
80106ee5:	6a 00                	push   $0x0
  pushl $167
80106ee7:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106eec:	e9 c8 f2 ff ff       	jmp    801061b9 <alltraps>

80106ef1 <vector168>:
.globl vector168
vector168:
  pushl $0
80106ef1:	6a 00                	push   $0x0
  pushl $168
80106ef3:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106ef8:	e9 bc f2 ff ff       	jmp    801061b9 <alltraps>

80106efd <vector169>:
.globl vector169
vector169:
  pushl $0
80106efd:	6a 00                	push   $0x0
  pushl $169
80106eff:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106f04:	e9 b0 f2 ff ff       	jmp    801061b9 <alltraps>

80106f09 <vector170>:
.globl vector170
vector170:
  pushl $0
80106f09:	6a 00                	push   $0x0
  pushl $170
80106f0b:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106f10:	e9 a4 f2 ff ff       	jmp    801061b9 <alltraps>

80106f15 <vector171>:
.globl vector171
vector171:
  pushl $0
80106f15:	6a 00                	push   $0x0
  pushl $171
80106f17:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106f1c:	e9 98 f2 ff ff       	jmp    801061b9 <alltraps>

80106f21 <vector172>:
.globl vector172
vector172:
  pushl $0
80106f21:	6a 00                	push   $0x0
  pushl $172
80106f23:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106f28:	e9 8c f2 ff ff       	jmp    801061b9 <alltraps>

80106f2d <vector173>:
.globl vector173
vector173:
  pushl $0
80106f2d:	6a 00                	push   $0x0
  pushl $173
80106f2f:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106f34:	e9 80 f2 ff ff       	jmp    801061b9 <alltraps>

80106f39 <vector174>:
.globl vector174
vector174:
  pushl $0
80106f39:	6a 00                	push   $0x0
  pushl $174
80106f3b:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106f40:	e9 74 f2 ff ff       	jmp    801061b9 <alltraps>

80106f45 <vector175>:
.globl vector175
vector175:
  pushl $0
80106f45:	6a 00                	push   $0x0
  pushl $175
80106f47:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106f4c:	e9 68 f2 ff ff       	jmp    801061b9 <alltraps>

80106f51 <vector176>:
.globl vector176
vector176:
  pushl $0
80106f51:	6a 00                	push   $0x0
  pushl $176
80106f53:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106f58:	e9 5c f2 ff ff       	jmp    801061b9 <alltraps>

80106f5d <vector177>:
.globl vector177
vector177:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $177
80106f5f:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106f64:	e9 50 f2 ff ff       	jmp    801061b9 <alltraps>

80106f69 <vector178>:
.globl vector178
vector178:
  pushl $0
80106f69:	6a 00                	push   $0x0
  pushl $178
80106f6b:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106f70:	e9 44 f2 ff ff       	jmp    801061b9 <alltraps>

80106f75 <vector179>:
.globl vector179
vector179:
  pushl $0
80106f75:	6a 00                	push   $0x0
  pushl $179
80106f77:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106f7c:	e9 38 f2 ff ff       	jmp    801061b9 <alltraps>

80106f81 <vector180>:
.globl vector180
vector180:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $180
80106f83:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106f88:	e9 2c f2 ff ff       	jmp    801061b9 <alltraps>

80106f8d <vector181>:
.globl vector181
vector181:
  pushl $0
80106f8d:	6a 00                	push   $0x0
  pushl $181
80106f8f:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106f94:	e9 20 f2 ff ff       	jmp    801061b9 <alltraps>

80106f99 <vector182>:
.globl vector182
vector182:
  pushl $0
80106f99:	6a 00                	push   $0x0
  pushl $182
80106f9b:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106fa0:	e9 14 f2 ff ff       	jmp    801061b9 <alltraps>

80106fa5 <vector183>:
.globl vector183
vector183:
  pushl $0
80106fa5:	6a 00                	push   $0x0
  pushl $183
80106fa7:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106fac:	e9 08 f2 ff ff       	jmp    801061b9 <alltraps>

80106fb1 <vector184>:
.globl vector184
vector184:
  pushl $0
80106fb1:	6a 00                	push   $0x0
  pushl $184
80106fb3:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106fb8:	e9 fc f1 ff ff       	jmp    801061b9 <alltraps>

80106fbd <vector185>:
.globl vector185
vector185:
  pushl $0
80106fbd:	6a 00                	push   $0x0
  pushl $185
80106fbf:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106fc4:	e9 f0 f1 ff ff       	jmp    801061b9 <alltraps>

80106fc9 <vector186>:
.globl vector186
vector186:
  pushl $0
80106fc9:	6a 00                	push   $0x0
  pushl $186
80106fcb:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106fd0:	e9 e4 f1 ff ff       	jmp    801061b9 <alltraps>

80106fd5 <vector187>:
.globl vector187
vector187:
  pushl $0
80106fd5:	6a 00                	push   $0x0
  pushl $187
80106fd7:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106fdc:	e9 d8 f1 ff ff       	jmp    801061b9 <alltraps>

80106fe1 <vector188>:
.globl vector188
vector188:
  pushl $0
80106fe1:	6a 00                	push   $0x0
  pushl $188
80106fe3:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106fe8:	e9 cc f1 ff ff       	jmp    801061b9 <alltraps>

80106fed <vector189>:
.globl vector189
vector189:
  pushl $0
80106fed:	6a 00                	push   $0x0
  pushl $189
80106fef:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106ff4:	e9 c0 f1 ff ff       	jmp    801061b9 <alltraps>

80106ff9 <vector190>:
.globl vector190
vector190:
  pushl $0
80106ff9:	6a 00                	push   $0x0
  pushl $190
80106ffb:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107000:	e9 b4 f1 ff ff       	jmp    801061b9 <alltraps>

80107005 <vector191>:
.globl vector191
vector191:
  pushl $0
80107005:	6a 00                	push   $0x0
  pushl $191
80107007:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010700c:	e9 a8 f1 ff ff       	jmp    801061b9 <alltraps>

80107011 <vector192>:
.globl vector192
vector192:
  pushl $0
80107011:	6a 00                	push   $0x0
  pushl $192
80107013:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107018:	e9 9c f1 ff ff       	jmp    801061b9 <alltraps>

8010701d <vector193>:
.globl vector193
vector193:
  pushl $0
8010701d:	6a 00                	push   $0x0
  pushl $193
8010701f:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107024:	e9 90 f1 ff ff       	jmp    801061b9 <alltraps>

80107029 <vector194>:
.globl vector194
vector194:
  pushl $0
80107029:	6a 00                	push   $0x0
  pushl $194
8010702b:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107030:	e9 84 f1 ff ff       	jmp    801061b9 <alltraps>

80107035 <vector195>:
.globl vector195
vector195:
  pushl $0
80107035:	6a 00                	push   $0x0
  pushl $195
80107037:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010703c:	e9 78 f1 ff ff       	jmp    801061b9 <alltraps>

80107041 <vector196>:
.globl vector196
vector196:
  pushl $0
80107041:	6a 00                	push   $0x0
  pushl $196
80107043:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107048:	e9 6c f1 ff ff       	jmp    801061b9 <alltraps>

8010704d <vector197>:
.globl vector197
vector197:
  pushl $0
8010704d:	6a 00                	push   $0x0
  pushl $197
8010704f:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107054:	e9 60 f1 ff ff       	jmp    801061b9 <alltraps>

80107059 <vector198>:
.globl vector198
vector198:
  pushl $0
80107059:	6a 00                	push   $0x0
  pushl $198
8010705b:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107060:	e9 54 f1 ff ff       	jmp    801061b9 <alltraps>

80107065 <vector199>:
.globl vector199
vector199:
  pushl $0
80107065:	6a 00                	push   $0x0
  pushl $199
80107067:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010706c:	e9 48 f1 ff ff       	jmp    801061b9 <alltraps>

80107071 <vector200>:
.globl vector200
vector200:
  pushl $0
80107071:	6a 00                	push   $0x0
  pushl $200
80107073:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107078:	e9 3c f1 ff ff       	jmp    801061b9 <alltraps>

8010707d <vector201>:
.globl vector201
vector201:
  pushl $0
8010707d:	6a 00                	push   $0x0
  pushl $201
8010707f:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107084:	e9 30 f1 ff ff       	jmp    801061b9 <alltraps>

80107089 <vector202>:
.globl vector202
vector202:
  pushl $0
80107089:	6a 00                	push   $0x0
  pushl $202
8010708b:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107090:	e9 24 f1 ff ff       	jmp    801061b9 <alltraps>

80107095 <vector203>:
.globl vector203
vector203:
  pushl $0
80107095:	6a 00                	push   $0x0
  pushl $203
80107097:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010709c:	e9 18 f1 ff ff       	jmp    801061b9 <alltraps>

801070a1 <vector204>:
.globl vector204
vector204:
  pushl $0
801070a1:	6a 00                	push   $0x0
  pushl $204
801070a3:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801070a8:	e9 0c f1 ff ff       	jmp    801061b9 <alltraps>

801070ad <vector205>:
.globl vector205
vector205:
  pushl $0
801070ad:	6a 00                	push   $0x0
  pushl $205
801070af:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801070b4:	e9 00 f1 ff ff       	jmp    801061b9 <alltraps>

801070b9 <vector206>:
.globl vector206
vector206:
  pushl $0
801070b9:	6a 00                	push   $0x0
  pushl $206
801070bb:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801070c0:	e9 f4 f0 ff ff       	jmp    801061b9 <alltraps>

801070c5 <vector207>:
.globl vector207
vector207:
  pushl $0
801070c5:	6a 00                	push   $0x0
  pushl $207
801070c7:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801070cc:	e9 e8 f0 ff ff       	jmp    801061b9 <alltraps>

801070d1 <vector208>:
.globl vector208
vector208:
  pushl $0
801070d1:	6a 00                	push   $0x0
  pushl $208
801070d3:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801070d8:	e9 dc f0 ff ff       	jmp    801061b9 <alltraps>

801070dd <vector209>:
.globl vector209
vector209:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $209
801070df:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801070e4:	e9 d0 f0 ff ff       	jmp    801061b9 <alltraps>

801070e9 <vector210>:
.globl vector210
vector210:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $210
801070eb:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801070f0:	e9 c4 f0 ff ff       	jmp    801061b9 <alltraps>

801070f5 <vector211>:
.globl vector211
vector211:
  pushl $0
801070f5:	6a 00                	push   $0x0
  pushl $211
801070f7:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801070fc:	e9 b8 f0 ff ff       	jmp    801061b9 <alltraps>

80107101 <vector212>:
.globl vector212
vector212:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $212
80107103:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107108:	e9 ac f0 ff ff       	jmp    801061b9 <alltraps>

8010710d <vector213>:
.globl vector213
vector213:
  pushl $0
8010710d:	6a 00                	push   $0x0
  pushl $213
8010710f:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107114:	e9 a0 f0 ff ff       	jmp    801061b9 <alltraps>

80107119 <vector214>:
.globl vector214
vector214:
  pushl $0
80107119:	6a 00                	push   $0x0
  pushl $214
8010711b:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107120:	e9 94 f0 ff ff       	jmp    801061b9 <alltraps>

80107125 <vector215>:
.globl vector215
vector215:
  pushl $0
80107125:	6a 00                	push   $0x0
  pushl $215
80107127:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010712c:	e9 88 f0 ff ff       	jmp    801061b9 <alltraps>

80107131 <vector216>:
.globl vector216
vector216:
  pushl $0
80107131:	6a 00                	push   $0x0
  pushl $216
80107133:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107138:	e9 7c f0 ff ff       	jmp    801061b9 <alltraps>

8010713d <vector217>:
.globl vector217
vector217:
  pushl $0
8010713d:	6a 00                	push   $0x0
  pushl $217
8010713f:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107144:	e9 70 f0 ff ff       	jmp    801061b9 <alltraps>

80107149 <vector218>:
.globl vector218
vector218:
  pushl $0
80107149:	6a 00                	push   $0x0
  pushl $218
8010714b:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107150:	e9 64 f0 ff ff       	jmp    801061b9 <alltraps>

80107155 <vector219>:
.globl vector219
vector219:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $219
80107157:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010715c:	e9 58 f0 ff ff       	jmp    801061b9 <alltraps>

80107161 <vector220>:
.globl vector220
vector220:
  pushl $0
80107161:	6a 00                	push   $0x0
  pushl $220
80107163:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107168:	e9 4c f0 ff ff       	jmp    801061b9 <alltraps>

8010716d <vector221>:
.globl vector221
vector221:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $221
8010716f:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107174:	e9 40 f0 ff ff       	jmp    801061b9 <alltraps>

80107179 <vector222>:
.globl vector222
vector222:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $222
8010717b:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107180:	e9 34 f0 ff ff       	jmp    801061b9 <alltraps>

80107185 <vector223>:
.globl vector223
vector223:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $223
80107187:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010718c:	e9 28 f0 ff ff       	jmp    801061b9 <alltraps>

80107191 <vector224>:
.globl vector224
vector224:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $224
80107193:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107198:	e9 1c f0 ff ff       	jmp    801061b9 <alltraps>

8010719d <vector225>:
.globl vector225
vector225:
  pushl $0
8010719d:	6a 00                	push   $0x0
  pushl $225
8010719f:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801071a4:	e9 10 f0 ff ff       	jmp    801061b9 <alltraps>

801071a9 <vector226>:
.globl vector226
vector226:
  pushl $0
801071a9:	6a 00                	push   $0x0
  pushl $226
801071ab:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801071b0:	e9 04 f0 ff ff       	jmp    801061b9 <alltraps>

801071b5 <vector227>:
.globl vector227
vector227:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $227
801071b7:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801071bc:	e9 f8 ef ff ff       	jmp    801061b9 <alltraps>

801071c1 <vector228>:
.globl vector228
vector228:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $228
801071c3:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801071c8:	e9 ec ef ff ff       	jmp    801061b9 <alltraps>

801071cd <vector229>:
.globl vector229
vector229:
  pushl $0
801071cd:	6a 00                	push   $0x0
  pushl $229
801071cf:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801071d4:	e9 e0 ef ff ff       	jmp    801061b9 <alltraps>

801071d9 <vector230>:
.globl vector230
vector230:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $230
801071db:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801071e0:	e9 d4 ef ff ff       	jmp    801061b9 <alltraps>

801071e5 <vector231>:
.globl vector231
vector231:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $231
801071e7:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801071ec:	e9 c8 ef ff ff       	jmp    801061b9 <alltraps>

801071f1 <vector232>:
.globl vector232
vector232:
  pushl $0
801071f1:	6a 00                	push   $0x0
  pushl $232
801071f3:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801071f8:	e9 bc ef ff ff       	jmp    801061b9 <alltraps>

801071fd <vector233>:
.globl vector233
vector233:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $233
801071ff:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107204:	e9 b0 ef ff ff       	jmp    801061b9 <alltraps>

80107209 <vector234>:
.globl vector234
vector234:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $234
8010720b:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107210:	e9 a4 ef ff ff       	jmp    801061b9 <alltraps>

80107215 <vector235>:
.globl vector235
vector235:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $235
80107217:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010721c:	e9 98 ef ff ff       	jmp    801061b9 <alltraps>

80107221 <vector236>:
.globl vector236
vector236:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $236
80107223:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107228:	e9 8c ef ff ff       	jmp    801061b9 <alltraps>

8010722d <vector237>:
.globl vector237
vector237:
  pushl $0
8010722d:	6a 00                	push   $0x0
  pushl $237
8010722f:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107234:	e9 80 ef ff ff       	jmp    801061b9 <alltraps>

80107239 <vector238>:
.globl vector238
vector238:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $238
8010723b:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107240:	e9 74 ef ff ff       	jmp    801061b9 <alltraps>

80107245 <vector239>:
.globl vector239
vector239:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $239
80107247:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010724c:	e9 68 ef ff ff       	jmp    801061b9 <alltraps>

80107251 <vector240>:
.globl vector240
vector240:
  pushl $0
80107251:	6a 00                	push   $0x0
  pushl $240
80107253:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107258:	e9 5c ef ff ff       	jmp    801061b9 <alltraps>

8010725d <vector241>:
.globl vector241
vector241:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $241
8010725f:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107264:	e9 50 ef ff ff       	jmp    801061b9 <alltraps>

80107269 <vector242>:
.globl vector242
vector242:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $242
8010726b:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107270:	e9 44 ef ff ff       	jmp    801061b9 <alltraps>

80107275 <vector243>:
.globl vector243
vector243:
  pushl $0
80107275:	6a 00                	push   $0x0
  pushl $243
80107277:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010727c:	e9 38 ef ff ff       	jmp    801061b9 <alltraps>

80107281 <vector244>:
.globl vector244
vector244:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $244
80107283:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107288:	e9 2c ef ff ff       	jmp    801061b9 <alltraps>

8010728d <vector245>:
.globl vector245
vector245:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $245
8010728f:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107294:	e9 20 ef ff ff       	jmp    801061b9 <alltraps>

80107299 <vector246>:
.globl vector246
vector246:
  pushl $0
80107299:	6a 00                	push   $0x0
  pushl $246
8010729b:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801072a0:	e9 14 ef ff ff       	jmp    801061b9 <alltraps>

801072a5 <vector247>:
.globl vector247
vector247:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $247
801072a7:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801072ac:	e9 08 ef ff ff       	jmp    801061b9 <alltraps>

801072b1 <vector248>:
.globl vector248
vector248:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $248
801072b3:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801072b8:	e9 fc ee ff ff       	jmp    801061b9 <alltraps>

801072bd <vector249>:
.globl vector249
vector249:
  pushl $0
801072bd:	6a 00                	push   $0x0
  pushl $249
801072bf:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801072c4:	e9 f0 ee ff ff       	jmp    801061b9 <alltraps>

801072c9 <vector250>:
.globl vector250
vector250:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $250
801072cb:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801072d0:	e9 e4 ee ff ff       	jmp    801061b9 <alltraps>

801072d5 <vector251>:
.globl vector251
vector251:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $251
801072d7:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801072dc:	e9 d8 ee ff ff       	jmp    801061b9 <alltraps>

801072e1 <vector252>:
.globl vector252
vector252:
  pushl $0
801072e1:	6a 00                	push   $0x0
  pushl $252
801072e3:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801072e8:	e9 cc ee ff ff       	jmp    801061b9 <alltraps>

801072ed <vector253>:
.globl vector253
vector253:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $253
801072ef:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801072f4:	e9 c0 ee ff ff       	jmp    801061b9 <alltraps>

801072f9 <vector254>:
.globl vector254
vector254:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $254
801072fb:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107300:	e9 b4 ee ff ff       	jmp    801061b9 <alltraps>

80107305 <vector255>:
.globl vector255
vector255:
  pushl $0
80107305:	6a 00                	push   $0x0
  pushl $255
80107307:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010730c:	e9 a8 ee ff ff       	jmp    801061b9 <alltraps>

80107311 <lgdt>:
{
80107311:	55                   	push   %ebp
80107312:	89 e5                	mov    %esp,%ebp
80107314:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107317:	8b 45 0c             	mov    0xc(%ebp),%eax
8010731a:	83 e8 01             	sub    $0x1,%eax
8010731d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107321:	8b 45 08             	mov    0x8(%ebp),%eax
80107324:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107328:	8b 45 08             	mov    0x8(%ebp),%eax
8010732b:	c1 e8 10             	shr    $0x10,%eax
8010732e:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107332:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107335:	0f 01 10             	lgdtl  (%eax)
}
80107338:	90                   	nop
80107339:	c9                   	leave
8010733a:	c3                   	ret

8010733b <ltr>:
{
8010733b:	55                   	push   %ebp
8010733c:	89 e5                	mov    %esp,%ebp
8010733e:	83 ec 04             	sub    $0x4,%esp
80107341:	8b 45 08             	mov    0x8(%ebp),%eax
80107344:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107348:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010734c:	0f 00 d8             	ltr    %eax
}
8010734f:	90                   	nop
80107350:	c9                   	leave
80107351:	c3                   	ret

80107352 <lcr3>:

static inline void
lcr3(uint val)
{
80107352:	55                   	push   %ebp
80107353:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107355:	8b 45 08             	mov    0x8(%ebp),%eax
80107358:	0f 22 d8             	mov    %eax,%cr3
}
8010735b:	90                   	nop
8010735c:	5d                   	pop    %ebp
8010735d:	c3                   	ret

8010735e <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010735e:	f3 0f 1e fb          	endbr32
80107362:	55                   	push   %ebp
80107363:	89 e5                	mov    %esp,%ebp
80107365:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107368:	e8 f7 c7 ff ff       	call   80103b64 <cpuid>
8010736d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107373:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80107378:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010737b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010737e:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107384:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107387:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010738d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107390:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107397:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010739b:	83 e2 f0             	and    $0xfffffff0,%edx
8010739e:	83 ca 0a             	or     $0xa,%edx
801073a1:	88 50 7d             	mov    %dl,0x7d(%eax)
801073a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073ab:	83 ca 10             	or     $0x10,%edx
801073ae:	88 50 7d             	mov    %dl,0x7d(%eax)
801073b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073b8:	83 e2 9f             	and    $0xffffff9f,%edx
801073bb:	88 50 7d             	mov    %dl,0x7d(%eax)
801073be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073c5:	83 ca 80             	or     $0xffffff80,%edx
801073c8:	88 50 7d             	mov    %dl,0x7d(%eax)
801073cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ce:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073d2:	83 ca 0f             	or     $0xf,%edx
801073d5:	88 50 7e             	mov    %dl,0x7e(%eax)
801073d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073db:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073df:	83 e2 ef             	and    $0xffffffef,%edx
801073e2:	88 50 7e             	mov    %dl,0x7e(%eax)
801073e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073ec:	83 e2 df             	and    $0xffffffdf,%edx
801073ef:	88 50 7e             	mov    %dl,0x7e(%eax)
801073f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073f9:	83 ca 40             	or     $0x40,%edx
801073fc:	88 50 7e             	mov    %dl,0x7e(%eax)
801073ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107402:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107406:	83 ca 80             	or     $0xffffff80,%edx
80107409:	88 50 7e             	mov    %dl,0x7e(%eax)
8010740c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010740f:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107416:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010741d:	ff ff 
8010741f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107422:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107429:	00 00 
8010742b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010742e:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107435:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107438:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010743f:	83 e2 f0             	and    $0xfffffff0,%edx
80107442:	83 ca 02             	or     $0x2,%edx
80107445:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010744b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010744e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107455:	83 ca 10             	or     $0x10,%edx
80107458:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010745e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107461:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107468:	83 e2 9f             	and    $0xffffff9f,%edx
8010746b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107471:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107474:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010747b:	83 ca 80             	or     $0xffffff80,%edx
8010747e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107487:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010748e:	83 ca 0f             	or     $0xf,%edx
80107491:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107497:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010749a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074a1:	83 e2 ef             	and    $0xffffffef,%edx
801074a4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ad:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074b4:	83 e2 df             	and    $0xffffffdf,%edx
801074b7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074c7:	83 ca 40             	or     $0x40,%edx
801074ca:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074da:	83 ca 80             	or     $0xffffff80,%edx
801074dd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e6:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801074ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f0:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801074f7:	ff ff 
801074f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074fc:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107503:	00 00 
80107505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107508:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
8010750f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107512:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107519:	83 e2 f0             	and    $0xfffffff0,%edx
8010751c:	83 ca 0a             	or     $0xa,%edx
8010751f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107525:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107528:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010752f:	83 ca 10             	or     $0x10,%edx
80107532:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107542:	83 ca 60             	or     $0x60,%edx
80107545:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010754b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010754e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107555:	83 ca 80             	or     $0xffffff80,%edx
80107558:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010755e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107561:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107568:	83 ca 0f             	or     $0xf,%edx
8010756b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107574:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010757b:	83 e2 ef             	and    $0xffffffef,%edx
8010757e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107587:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010758e:	83 e2 df             	and    $0xffffffdf,%edx
80107591:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075a1:	83 ca 40             	or     $0x40,%edx
801075a4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ad:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075b4:	83 ca 80             	or     $0xffffff80,%edx
801075b7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c0:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801075c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ca:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801075d1:	ff ff 
801075d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d6:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801075dd:	00 00 
801075df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e2:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801075e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ec:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075f3:	83 e2 f0             	and    $0xfffffff0,%edx
801075f6:	83 ca 02             	or     $0x2,%edx
801075f9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107602:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107609:	83 ca 10             	or     $0x10,%edx
8010760c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107615:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010761c:	83 ca 60             	or     $0x60,%edx
8010761f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107628:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010762f:	83 ca 80             	or     $0xffffff80,%edx
80107632:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107642:	83 ca 0f             	or     $0xf,%edx
80107645:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010764b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107655:	83 e2 ef             	and    $0xffffffef,%edx
80107658:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010765e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107661:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107668:	83 e2 df             	and    $0xffffffdf,%edx
8010766b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107674:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010767b:	83 ca 40             	or     $0x40,%edx
8010767e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107687:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010768e:	83 ca 80             	or     $0xffffff80,%edx
80107691:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769a:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801076a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a4:	83 c0 70             	add    $0x70,%eax
801076a7:	83 ec 08             	sub    $0x8,%esp
801076aa:	6a 30                	push   $0x30
801076ac:	50                   	push   %eax
801076ad:	e8 5f fc ff ff       	call   80107311 <lgdt>
801076b2:	83 c4 10             	add    $0x10,%esp
}
801076b5:	90                   	nop
801076b6:	c9                   	leave
801076b7:	c3                   	ret

801076b8 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
/*static 전역에서 사용해야 함*/ pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801076b8:	f3 0f 1e fb          	endbr32
801076bc:	55                   	push   %ebp
801076bd:	89 e5                	mov    %esp,%ebp
801076bf:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801076c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801076c5:	c1 e8 16             	shr    $0x16,%eax
801076c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801076cf:	8b 45 08             	mov    0x8(%ebp),%eax
801076d2:	01 d0                	add    %edx,%eax
801076d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801076d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076da:	8b 00                	mov    (%eax),%eax
801076dc:	83 e0 01             	and    $0x1,%eax
801076df:	85 c0                	test   %eax,%eax
801076e1:	74 14                	je     801076f7 <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801076e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076e6:	8b 00                	mov    (%eax),%eax
801076e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076ed:	05 00 00 00 80       	add    $0x80000000,%eax
801076f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801076f5:	eb 42                	jmp    80107739 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801076f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801076fb:	74 0e                	je     8010770b <walkpgdir+0x53>
801076fd:	e8 e6 b1 ff ff       	call   801028e8 <kalloc>
80107702:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107705:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107709:	75 07                	jne    80107712 <walkpgdir+0x5a>
      return 0;
8010770b:	b8 00 00 00 00       	mov    $0x0,%eax
80107710:	eb 3e                	jmp    80107750 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107712:	83 ec 04             	sub    $0x4,%esp
80107715:	68 00 10 00 00       	push   $0x1000
8010771a:	6a 00                	push   $0x0
8010771c:	ff 75 f4             	push   -0xc(%ebp)
8010771f:	e8 47 d6 ff ff       	call   80104d6b <memset>
80107724:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772a:	05 00 00 00 80       	add    $0x80000000,%eax
8010772f:	83 c8 07             	or     $0x7,%eax
80107732:	89 c2                	mov    %eax,%edx
80107734:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107737:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107739:	8b 45 0c             	mov    0xc(%ebp),%eax
8010773c:	c1 e8 0c             	shr    $0xc,%eax
8010773f:	25 ff 03 00 00       	and    $0x3ff,%eax
80107744:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010774b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774e:	01 d0                	add    %edx,%eax
}
80107750:	c9                   	leave
80107751:	c3                   	ret

80107752 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
/*static 전역에서 사용해야 함*/ int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107752:	f3 0f 1e fb          	endbr32
80107756:	55                   	push   %ebp
80107757:	89 e5                	mov    %esp,%ebp
80107759:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010775c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010775f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107764:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107767:	8b 55 0c             	mov    0xc(%ebp),%edx
8010776a:	8b 45 10             	mov    0x10(%ebp),%eax
8010776d:	01 d0                	add    %edx,%eax
8010776f:	83 e8 01             	sub    $0x1,%eax
80107772:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107777:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010777a:	83 ec 04             	sub    $0x4,%esp
8010777d:	6a 01                	push   $0x1
8010777f:	ff 75 f4             	push   -0xc(%ebp)
80107782:	ff 75 08             	push   0x8(%ebp)
80107785:	e8 2e ff ff ff       	call   801076b8 <walkpgdir>
8010778a:	83 c4 10             	add    $0x10,%esp
8010778d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107790:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107794:	75 07                	jne    8010779d <mappages+0x4b>
      return -1;
80107796:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010779b:	eb 47                	jmp    801077e4 <mappages+0x92>
    if(*pte & PTE_P)
8010779d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801077a0:	8b 00                	mov    (%eax),%eax
801077a2:	83 e0 01             	and    $0x1,%eax
801077a5:	85 c0                	test   %eax,%eax
801077a7:	74 0d                	je     801077b6 <mappages+0x64>
      panic("remap");
801077a9:	83 ec 0c             	sub    $0xc,%esp
801077ac:	68 9c ad 10 80       	push   $0x8010ad9c
801077b1:	e8 28 8e ff ff       	call   801005de <panic>
    *pte = pa | perm | PTE_P;
801077b6:	8b 45 18             	mov    0x18(%ebp),%eax
801077b9:	0b 45 14             	or     0x14(%ebp),%eax
801077bc:	83 c8 01             	or     $0x1,%eax
801077bf:	89 c2                	mov    %eax,%edx
801077c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801077c4:	89 10                	mov    %edx,(%eax)
    if(a == last)
801077c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801077cc:	74 10                	je     801077de <mappages+0x8c>
      break;
    a += PGSIZE;
801077ce:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801077d5:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801077dc:	eb 9c                	jmp    8010777a <mappages+0x28>
      break;
801077de:	90                   	nop
  }
  return 0;
801077df:	b8 00 00 00 00       	mov    $0x0,%eax
}
801077e4:	c9                   	leave
801077e5:	c3                   	ret

801077e6 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801077e6:	f3 0f 1e fb          	endbr32
801077ea:	55                   	push   %ebp
801077eb:	89 e5                	mov    %esp,%ebp
801077ed:	53                   	push   %ebx
801077ee:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801077f1:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801077f8:	a1 8c 80 19 80       	mov    0x8019808c,%eax
801077fd:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107802:	29 c2                	sub    %eax,%edx
80107804:	89 d0                	mov    %edx,%eax
80107806:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107809:	a1 84 80 19 80       	mov    0x80198084,%eax
8010780e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107811:	8b 15 84 80 19 80    	mov    0x80198084,%edx
80107817:	a1 8c 80 19 80       	mov    0x8019808c,%eax
8010781c:	01 d0                	add    %edx,%eax
8010781e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107821:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782b:	83 c0 30             	add    $0x30,%eax
8010782e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107831:	89 10                	mov    %edx,(%eax)
80107833:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107836:	89 50 04             	mov    %edx,0x4(%eax)
80107839:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010783c:	89 50 08             	mov    %edx,0x8(%eax)
8010783f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107842:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107845:	e8 9e b0 ff ff       	call   801028e8 <kalloc>
8010784a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010784d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107851:	75 07                	jne    8010785a <setupkvm+0x74>
    return 0;
80107853:	b8 00 00 00 00       	mov    $0x0,%eax
80107858:	eb 78                	jmp    801078d2 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
8010785a:	83 ec 04             	sub    $0x4,%esp
8010785d:	68 00 10 00 00       	push   $0x1000
80107862:	6a 00                	push   $0x0
80107864:	ff 75 f0             	push   -0x10(%ebp)
80107867:	e8 ff d4 ff ff       	call   80104d6b <memset>
8010786c:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010786f:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107876:	eb 4e                	jmp    801078c6 <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787b:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010787e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107881:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107887:	8b 58 08             	mov    0x8(%eax),%ebx
8010788a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788d:	8b 40 04             	mov    0x4(%eax),%eax
80107890:	29 c3                	sub    %eax,%ebx
80107892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107895:	8b 00                	mov    (%eax),%eax
80107897:	83 ec 0c             	sub    $0xc,%esp
8010789a:	51                   	push   %ecx
8010789b:	52                   	push   %edx
8010789c:	53                   	push   %ebx
8010789d:	50                   	push   %eax
8010789e:	ff 75 f0             	push   -0x10(%ebp)
801078a1:	e8 ac fe ff ff       	call   80107752 <mappages>
801078a6:	83 c4 20             	add    $0x20,%esp
801078a9:	85 c0                	test   %eax,%eax
801078ab:	79 15                	jns    801078c2 <setupkvm+0xdc>
      freevm(pgdir);
801078ad:	83 ec 0c             	sub    $0xc,%esp
801078b0:	ff 75 f0             	push   -0x10(%ebp)
801078b3:	e8 37 05 00 00       	call   80107def <freevm>
801078b8:	83 c4 10             	add    $0x10,%esp
      return 0;
801078bb:	b8 00 00 00 00       	mov    $0x0,%eax
801078c0:	eb 10                	jmp    801078d2 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801078c2:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801078c6:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801078cd:	72 a9                	jb     80107878 <setupkvm+0x92>
    }
  return pgdir;
801078cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801078d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801078d5:	c9                   	leave
801078d6:	c3                   	ret

801078d7 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801078d7:	f3 0f 1e fb          	endbr32
801078db:	55                   	push   %ebp
801078dc:	89 e5                	mov    %esp,%ebp
801078de:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801078e1:	e8 00 ff ff ff       	call   801077e6 <setupkvm>
801078e6:	a3 84 7d 19 80       	mov    %eax,0x80197d84
  switchkvm();
801078eb:	e8 03 00 00 00       	call   801078f3 <switchkvm>
}
801078f0:	90                   	nop
801078f1:	c9                   	leave
801078f2:	c3                   	ret

801078f3 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801078f3:	f3 0f 1e fb          	endbr32
801078f7:	55                   	push   %ebp
801078f8:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801078fa:	a1 84 7d 19 80       	mov    0x80197d84,%eax
801078ff:	05 00 00 00 80       	add    $0x80000000,%eax
80107904:	50                   	push   %eax
80107905:	e8 48 fa ff ff       	call   80107352 <lcr3>
8010790a:	83 c4 04             	add    $0x4,%esp
}
8010790d:	90                   	nop
8010790e:	c9                   	leave
8010790f:	c3                   	ret

80107910 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107910:	f3 0f 1e fb          	endbr32
80107914:	55                   	push   %ebp
80107915:	89 e5                	mov    %esp,%ebp
80107917:	56                   	push   %esi
80107918:	53                   	push   %ebx
80107919:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
8010791c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107920:	75 0d                	jne    8010792f <switchuvm+0x1f>
    panic("switchuvm: no process");
80107922:	83 ec 0c             	sub    $0xc,%esp
80107925:	68 a2 ad 10 80       	push   $0x8010ada2
8010792a:	e8 af 8c ff ff       	call   801005de <panic>
  if(p->kstack == 0)
8010792f:	8b 45 08             	mov    0x8(%ebp),%eax
80107932:	8b 40 08             	mov    0x8(%eax),%eax
80107935:	85 c0                	test   %eax,%eax
80107937:	75 0d                	jne    80107946 <switchuvm+0x36>
    panic("switchuvm: no kstack");
80107939:	83 ec 0c             	sub    $0xc,%esp
8010793c:	68 b8 ad 10 80       	push   $0x8010adb8
80107941:	e8 98 8c ff ff       	call   801005de <panic>
  if(p->pgdir == 0)
80107946:	8b 45 08             	mov    0x8(%ebp),%eax
80107949:	8b 40 04             	mov    0x4(%eax),%eax
8010794c:	85 c0                	test   %eax,%eax
8010794e:	75 0d                	jne    8010795d <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
80107950:	83 ec 0c             	sub    $0xc,%esp
80107953:	68 cd ad 10 80       	push   $0x8010adcd
80107958:	e8 81 8c ff ff       	call   801005de <panic>

  pushcli();
8010795d:	e8 f6 d2 ff ff       	call   80104c58 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107962:	e8 1c c2 ff ff       	call   80103b83 <mycpu>
80107967:	89 c3                	mov    %eax,%ebx
80107969:	e8 15 c2 ff ff       	call   80103b83 <mycpu>
8010796e:	83 c0 08             	add    $0x8,%eax
80107971:	89 c6                	mov    %eax,%esi
80107973:	e8 0b c2 ff ff       	call   80103b83 <mycpu>
80107978:	83 c0 08             	add    $0x8,%eax
8010797b:	c1 e8 10             	shr    $0x10,%eax
8010797e:	88 45 f7             	mov    %al,-0x9(%ebp)
80107981:	e8 fd c1 ff ff       	call   80103b83 <mycpu>
80107986:	83 c0 08             	add    $0x8,%eax
80107989:	c1 e8 18             	shr    $0x18,%eax
8010798c:	89 c2                	mov    %eax,%edx
8010798e:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107995:	67 00 
80107997:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010799e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801079a2:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801079a8:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079af:	83 e0 f0             	and    $0xfffffff0,%eax
801079b2:	83 c8 09             	or     $0x9,%eax
801079b5:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079bb:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079c2:	83 c8 10             	or     $0x10,%eax
801079c5:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079cb:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079d2:	83 e0 9f             	and    $0xffffff9f,%eax
801079d5:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079db:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079e2:	83 c8 80             	or     $0xffffff80,%eax
801079e5:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079eb:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079f2:	83 e0 f0             	and    $0xfffffff0,%eax
801079f5:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079fb:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a02:	83 e0 ef             	and    $0xffffffef,%eax
80107a05:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a0b:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a12:	83 e0 df             	and    $0xffffffdf,%eax
80107a15:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a1b:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a22:	83 c8 40             	or     $0x40,%eax
80107a25:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a2b:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a32:	83 e0 7f             	and    $0x7f,%eax
80107a35:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a3b:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107a41:	e8 3d c1 ff ff       	call   80103b83 <mycpu>
80107a46:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a4d:	83 e2 ef             	and    $0xffffffef,%edx
80107a50:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107a56:	e8 28 c1 ff ff       	call   80103b83 <mycpu>
80107a5b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107a61:	8b 45 08             	mov    0x8(%ebp),%eax
80107a64:	8b 40 08             	mov    0x8(%eax),%eax
80107a67:	89 c3                	mov    %eax,%ebx
80107a69:	e8 15 c1 ff ff       	call   80103b83 <mycpu>
80107a6e:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107a74:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107a77:	e8 07 c1 ff ff       	call   80103b83 <mycpu>
80107a7c:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107a82:	83 ec 0c             	sub    $0xc,%esp
80107a85:	6a 28                	push   $0x28
80107a87:	e8 af f8 ff ff       	call   8010733b <ltr>
80107a8c:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80107a92:	8b 40 04             	mov    0x4(%eax),%eax
80107a95:	05 00 00 00 80       	add    $0x80000000,%eax
80107a9a:	83 ec 0c             	sub    $0xc,%esp
80107a9d:	50                   	push   %eax
80107a9e:	e8 af f8 ff ff       	call   80107352 <lcr3>
80107aa3:	83 c4 10             	add    $0x10,%esp
  popcli();
80107aa6:	e8 fe d1 ff ff       	call   80104ca9 <popcli>
}
80107aab:	90                   	nop
80107aac:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107aaf:	5b                   	pop    %ebx
80107ab0:	5e                   	pop    %esi
80107ab1:	5d                   	pop    %ebp
80107ab2:	c3                   	ret

80107ab3 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107ab3:	f3 0f 1e fb          	endbr32
80107ab7:	55                   	push   %ebp
80107ab8:	89 e5                	mov    %esp,%ebp
80107aba:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107abd:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107ac4:	76 0d                	jbe    80107ad3 <inituvm+0x20>
    panic("inituvm: more than a page");
80107ac6:	83 ec 0c             	sub    $0xc,%esp
80107ac9:	68 e1 ad 10 80       	push   $0x8010ade1
80107ace:	e8 0b 8b ff ff       	call   801005de <panic>
  mem = kalloc();
80107ad3:	e8 10 ae ff ff       	call   801028e8 <kalloc>
80107ad8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107adb:	83 ec 04             	sub    $0x4,%esp
80107ade:	68 00 10 00 00       	push   $0x1000
80107ae3:	6a 00                	push   $0x0
80107ae5:	ff 75 f4             	push   -0xc(%ebp)
80107ae8:	e8 7e d2 ff ff       	call   80104d6b <memset>
80107aed:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af3:	05 00 00 00 80       	add    $0x80000000,%eax
80107af8:	83 ec 0c             	sub    $0xc,%esp
80107afb:	6a 06                	push   $0x6
80107afd:	50                   	push   %eax
80107afe:	68 00 10 00 00       	push   $0x1000
80107b03:	6a 00                	push   $0x0
80107b05:	ff 75 08             	push   0x8(%ebp)
80107b08:	e8 45 fc ff ff       	call   80107752 <mappages>
80107b0d:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107b10:	83 ec 04             	sub    $0x4,%esp
80107b13:	ff 75 10             	push   0x10(%ebp)
80107b16:	ff 75 0c             	push   0xc(%ebp)
80107b19:	ff 75 f4             	push   -0xc(%ebp)
80107b1c:	e8 11 d3 ff ff       	call   80104e32 <memmove>
80107b21:	83 c4 10             	add    $0x10,%esp
}
80107b24:	90                   	nop
80107b25:	c9                   	leave
80107b26:	c3                   	ret

80107b27 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107b27:	f3 0f 1e fb          	endbr32
80107b2b:	55                   	push   %ebp
80107b2c:	89 e5                	mov    %esp,%ebp
80107b2e:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107b31:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b34:	25 ff 0f 00 00       	and    $0xfff,%eax
80107b39:	85 c0                	test   %eax,%eax
80107b3b:	74 0d                	je     80107b4a <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80107b3d:	83 ec 0c             	sub    $0xc,%esp
80107b40:	68 fc ad 10 80       	push   $0x8010adfc
80107b45:	e8 94 8a ff ff       	call   801005de <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107b4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b51:	e9 8f 00 00 00       	jmp    80107be5 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107b56:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5c:	01 d0                	add    %edx,%eax
80107b5e:	83 ec 04             	sub    $0x4,%esp
80107b61:	6a 00                	push   $0x0
80107b63:	50                   	push   %eax
80107b64:	ff 75 08             	push   0x8(%ebp)
80107b67:	e8 4c fb ff ff       	call   801076b8 <walkpgdir>
80107b6c:	83 c4 10             	add    $0x10,%esp
80107b6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b72:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b76:	75 0d                	jne    80107b85 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107b78:	83 ec 0c             	sub    $0xc,%esp
80107b7b:	68 1f ae 10 80       	push   $0x8010ae1f
80107b80:	e8 59 8a ff ff       	call   801005de <panic>
    pa = PTE_ADDR(*pte);
80107b85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b88:	8b 00                	mov    (%eax),%eax
80107b8a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b8f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107b92:	8b 45 18             	mov    0x18(%ebp),%eax
80107b95:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b98:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107b9d:	77 0b                	ja     80107baa <loaduvm+0x83>
      n = sz - i;
80107b9f:	8b 45 18             	mov    0x18(%ebp),%eax
80107ba2:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107ba5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ba8:	eb 07                	jmp    80107bb1 <loaduvm+0x8a>
    else
      n = PGSIZE;
80107baa:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107bb1:	8b 55 14             	mov    0x14(%ebp),%edx
80107bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb7:	01 d0                	add    %edx,%eax
80107bb9:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107bbc:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107bc2:	ff 75 f0             	push   -0x10(%ebp)
80107bc5:	50                   	push   %eax
80107bc6:	52                   	push   %edx
80107bc7:	ff 75 10             	push   0x10(%ebp)
80107bca:	e8 0b a4 ff ff       	call   80101fda <readi>
80107bcf:	83 c4 10             	add    $0x10,%esp
80107bd2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107bd5:	74 07                	je     80107bde <loaduvm+0xb7>
      return -1;
80107bd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bdc:	eb 18                	jmp    80107bf6 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80107bde:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be8:	3b 45 18             	cmp    0x18(%ebp),%eax
80107beb:	0f 82 65 ff ff ff    	jb     80107b56 <loaduvm+0x2f>
  }
  return 0;
80107bf1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107bf6:	c9                   	leave
80107bf7:	c3                   	ret

80107bf8 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107bf8:	f3 0f 1e fb          	endbr32
80107bfc:	55                   	push   %ebp
80107bfd:	89 e5                	mov    %esp,%ebp
80107bff:	83 ec 18             	sub    $0x18,%esp
  cprintf("[allocuvm] in \n");
80107c02:	83 ec 0c             	sub    $0xc,%esp
80107c05:	68 3d ae 10 80       	push   $0x8010ae3d
80107c0a:	e8 fd 87 ff ff       	call   8010040c <cprintf>
80107c0f:	83 c4 10             	add    $0x10,%esp
  cprintf("[allocuvm] oldsz %x newsz %x\n",oldsz, newsz);
80107c12:	83 ec 04             	sub    $0x4,%esp
80107c15:	ff 75 10             	push   0x10(%ebp)
80107c18:	ff 75 0c             	push   0xc(%ebp)
80107c1b:	68 4d ae 10 80       	push   $0x8010ae4d
80107c20:	e8 e7 87 ff ff       	call   8010040c <cprintf>
80107c25:	83 c4 10             	add    $0x10,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107c28:	8b 45 10             	mov    0x10(%ebp),%eax
80107c2b:	85 c0                	test   %eax,%eax
80107c2d:	79 0a                	jns    80107c39 <allocuvm+0x41>
    return 0;
80107c2f:	b8 00 00 00 00       	mov    $0x0,%eax
80107c34:	e9 ec 00 00 00       	jmp    80107d25 <allocuvm+0x12d>
  if(newsz < oldsz)
80107c39:	8b 45 10             	mov    0x10(%ebp),%eax
80107c3c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107c3f:	73 08                	jae    80107c49 <allocuvm+0x51>
    return oldsz;
80107c41:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c44:	e9 dc 00 00 00       	jmp    80107d25 <allocuvm+0x12d>

  a = PGROUNDUP(oldsz);
80107c49:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c4c:	05 ff 0f 00 00       	add    $0xfff,%eax
80107c51:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c56:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107c59:	e9 b8 00 00 00       	jmp    80107d16 <allocuvm+0x11e>
    mem = kalloc();
80107c5e:	e8 85 ac ff ff       	call   801028e8 <kalloc>
80107c63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107c66:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c6a:	75 2e                	jne    80107c9a <allocuvm+0xa2>
      cprintf("allocuvm out of memory\n");
80107c6c:	83 ec 0c             	sub    $0xc,%esp
80107c6f:	68 6b ae 10 80       	push   $0x8010ae6b
80107c74:	e8 93 87 ff ff       	call   8010040c <cprintf>
80107c79:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107c7c:	83 ec 04             	sub    $0x4,%esp
80107c7f:	ff 75 0c             	push   0xc(%ebp)
80107c82:	ff 75 10             	push   0x10(%ebp)
80107c85:	ff 75 08             	push   0x8(%ebp)
80107c88:	e8 9a 00 00 00       	call   80107d27 <deallocuvm>
80107c8d:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c90:	b8 00 00 00 00       	mov    $0x0,%eax
80107c95:	e9 8b 00 00 00       	jmp    80107d25 <allocuvm+0x12d>
    }
    memset(mem, 0, PGSIZE);
80107c9a:	83 ec 04             	sub    $0x4,%esp
80107c9d:	68 00 10 00 00       	push   $0x1000
80107ca2:	6a 00                	push   $0x0
80107ca4:	ff 75 f0             	push   -0x10(%ebp)
80107ca7:	e8 bf d0 ff ff       	call   80104d6b <memset>
80107cac:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107caf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cb2:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbb:	83 ec 0c             	sub    $0xc,%esp
80107cbe:	6a 06                	push   $0x6
80107cc0:	52                   	push   %edx
80107cc1:	68 00 10 00 00       	push   $0x1000
80107cc6:	50                   	push   %eax
80107cc7:	ff 75 08             	push   0x8(%ebp)
80107cca:	e8 83 fa ff ff       	call   80107752 <mappages>
80107ccf:	83 c4 20             	add    $0x20,%esp
80107cd2:	85 c0                	test   %eax,%eax
80107cd4:	79 39                	jns    80107d0f <allocuvm+0x117>
      cprintf("allocuvm out of memory (2)\n");
80107cd6:	83 ec 0c             	sub    $0xc,%esp
80107cd9:	68 83 ae 10 80       	push   $0x8010ae83
80107cde:	e8 29 87 ff ff       	call   8010040c <cprintf>
80107ce3:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107ce6:	83 ec 04             	sub    $0x4,%esp
80107ce9:	ff 75 0c             	push   0xc(%ebp)
80107cec:	ff 75 10             	push   0x10(%ebp)
80107cef:	ff 75 08             	push   0x8(%ebp)
80107cf2:	e8 30 00 00 00       	call   80107d27 <deallocuvm>
80107cf7:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107cfa:	83 ec 0c             	sub    $0xc,%esp
80107cfd:	ff 75 f0             	push   -0x10(%ebp)
80107d00:	e8 45 ab ff ff       	call   8010284a <kfree>
80107d05:	83 c4 10             	add    $0x10,%esp
      return 0;
80107d08:	b8 00 00 00 00       	mov    $0x0,%eax
80107d0d:	eb 16                	jmp    80107d25 <allocuvm+0x12d>
  for(; a < newsz; a += PGSIZE){
80107d0f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d19:	3b 45 10             	cmp    0x10(%ebp),%eax
80107d1c:	0f 82 3c ff ff ff    	jb     80107c5e <allocuvm+0x66>
    }
  }
  return newsz;
80107d22:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107d25:	c9                   	leave
80107d26:	c3                   	ret

80107d27 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d27:	f3 0f 1e fb          	endbr32
80107d2b:	55                   	push   %ebp
80107d2c:	89 e5                	mov    %esp,%ebp
80107d2e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107d31:	8b 45 10             	mov    0x10(%ebp),%eax
80107d34:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d37:	72 08                	jb     80107d41 <deallocuvm+0x1a>
    return oldsz;
80107d39:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d3c:	e9 ac 00 00 00       	jmp    80107ded <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80107d41:	8b 45 10             	mov    0x10(%ebp),%eax
80107d44:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107d51:	e9 88 00 00 00       	jmp    80107dde <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d59:	83 ec 04             	sub    $0x4,%esp
80107d5c:	6a 00                	push   $0x0
80107d5e:	50                   	push   %eax
80107d5f:	ff 75 08             	push   0x8(%ebp)
80107d62:	e8 51 f9 ff ff       	call   801076b8 <walkpgdir>
80107d67:	83 c4 10             	add    $0x10,%esp
80107d6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107d6d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d71:	75 16                	jne    80107d89 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d76:	c1 e8 16             	shr    $0x16,%eax
80107d79:	83 c0 01             	add    $0x1,%eax
80107d7c:	c1 e0 16             	shl    $0x16,%eax
80107d7f:	2d 00 10 00 00       	sub    $0x1000,%eax
80107d84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d87:	eb 4e                	jmp    80107dd7 <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80107d89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d8c:	8b 00                	mov    (%eax),%eax
80107d8e:	83 e0 01             	and    $0x1,%eax
80107d91:	85 c0                	test   %eax,%eax
80107d93:	74 42                	je     80107dd7 <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80107d95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d98:	8b 00                	mov    (%eax),%eax
80107d9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d9f:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107da2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107da6:	75 0d                	jne    80107db5 <deallocuvm+0x8e>
        panic("kfree");
80107da8:	83 ec 0c             	sub    $0xc,%esp
80107dab:	68 9f ae 10 80       	push   $0x8010ae9f
80107db0:	e8 29 88 ff ff       	call   801005de <panic>
      char *v = P2V(pa);
80107db5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107db8:	05 00 00 00 80       	add    $0x80000000,%eax
80107dbd:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107dc0:	83 ec 0c             	sub    $0xc,%esp
80107dc3:	ff 75 e8             	push   -0x18(%ebp)
80107dc6:	e8 7f aa ff ff       	call   8010284a <kfree>
80107dcb:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107dce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dd1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107dd7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de1:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107de4:	0f 82 6c ff ff ff    	jb     80107d56 <deallocuvm+0x2f>
    }
  }
  return newsz;
80107dea:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ded:	c9                   	leave
80107dee:	c3                   	ret

80107def <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107def:	f3 0f 1e fb          	endbr32
80107df3:	55                   	push   %ebp
80107df4:	89 e5                	mov    %esp,%ebp
80107df6:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107df9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107dfd:	75 0d                	jne    80107e0c <freevm+0x1d>
    panic("freevm: no pgdir");
80107dff:	83 ec 0c             	sub    $0xc,%esp
80107e02:	68 a5 ae 10 80       	push   $0x8010aea5
80107e07:	e8 d2 87 ff ff       	call   801005de <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107e0c:	83 ec 04             	sub    $0x4,%esp
80107e0f:	6a 00                	push   $0x0
80107e11:	68 00 00 00 80       	push   $0x80000000
80107e16:	ff 75 08             	push   0x8(%ebp)
80107e19:	e8 09 ff ff ff       	call   80107d27 <deallocuvm>
80107e1e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e28:	eb 48                	jmp    80107e72 <freevm+0x83>
    if(pgdir[i] & PTE_P){
80107e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e34:	8b 45 08             	mov    0x8(%ebp),%eax
80107e37:	01 d0                	add    %edx,%eax
80107e39:	8b 00                	mov    (%eax),%eax
80107e3b:	83 e0 01             	and    $0x1,%eax
80107e3e:	85 c0                	test   %eax,%eax
80107e40:	74 2c                	je     80107e6e <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e45:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e4c:	8b 45 08             	mov    0x8(%ebp),%eax
80107e4f:	01 d0                	add    %edx,%eax
80107e51:	8b 00                	mov    (%eax),%eax
80107e53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e58:	05 00 00 00 80       	add    $0x80000000,%eax
80107e5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107e60:	83 ec 0c             	sub    $0xc,%esp
80107e63:	ff 75 f0             	push   -0x10(%ebp)
80107e66:	e8 df a9 ff ff       	call   8010284a <kfree>
80107e6b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e6e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e72:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107e79:	76 af                	jbe    80107e2a <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80107e7b:	83 ec 0c             	sub    $0xc,%esp
80107e7e:	ff 75 08             	push   0x8(%ebp)
80107e81:	e8 c4 a9 ff ff       	call   8010284a <kfree>
80107e86:	83 c4 10             	add    $0x10,%esp
}
80107e89:	90                   	nop
80107e8a:	c9                   	leave
80107e8b:	c3                   	ret

80107e8c <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107e8c:	f3 0f 1e fb          	endbr32
80107e90:	55                   	push   %ebp
80107e91:	89 e5                	mov    %esp,%ebp
80107e93:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107e96:	83 ec 04             	sub    $0x4,%esp
80107e99:	6a 00                	push   $0x0
80107e9b:	ff 75 0c             	push   0xc(%ebp)
80107e9e:	ff 75 08             	push   0x8(%ebp)
80107ea1:	e8 12 f8 ff ff       	call   801076b8 <walkpgdir>
80107ea6:	83 c4 10             	add    $0x10,%esp
80107ea9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107eac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107eb0:	75 0d                	jne    80107ebf <clearpteu+0x33>
    panic("clearpteu");
80107eb2:	83 ec 0c             	sub    $0xc,%esp
80107eb5:	68 b6 ae 10 80       	push   $0x8010aeb6
80107eba:	e8 1f 87 ff ff       	call   801005de <panic>
  *pte &= ~PTE_U;
80107ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec2:	8b 00                	mov    (%eax),%eax
80107ec4:	83 e0 fb             	and    $0xfffffffb,%eax
80107ec7:	89 c2                	mov    %eax,%edx
80107ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecc:	89 10                	mov    %edx,(%eax)
}
80107ece:	90                   	nop
80107ecf:	c9                   	leave
80107ed0:	c3                   	ret

80107ed1 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107ed1:	f3 0f 1e fb          	endbr32
80107ed5:	55                   	push   %ebp
80107ed6:	89 e5                	mov    %esp,%ebp
80107ed8:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;
  
  if((d = setupkvm()) == 0)
80107edb:	e8 06 f9 ff ff       	call   801077e6 <setupkvm>
80107ee0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ee3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ee7:	75 0a                	jne    80107ef3 <copyuvm+0x22>
    return 0;
80107ee9:	b8 00 00 00 00       	mov    $0x0,%eax
80107eee:	e9 01 01 00 00       	jmp    80107ff4 <copyuvm+0x123>
    // 스택을 힙 영역으로 옮겼으니 힙 영역까지의 페이지 복사
    // text, data 영역 0xb98까지 stack 영역 0xb98+ 2*PGSIZE까지
    // heap 영역 stack영역 위부터 kernbase까지
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107ef3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107efa:	e9 be 00 00 00       	jmp    80107fbd <copyuvm+0xec>
    
    // 스택을 힙 영역의 맨 위에 할당했기 때문에 kernbase까지 복사를 해야하는데
    // 할당되지 않은 페이지, 유효하지 않은 페이지는 복사하지 않고 지나감
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f02:	83 ec 04             	sub    $0x4,%esp
80107f05:	6a 00                	push   $0x0
80107f07:	50                   	push   %eax
80107f08:	ff 75 08             	push   0x8(%ebp)
80107f0b:	e8 a8 f7 ff ff       	call   801076b8 <walkpgdir>
80107f10:	83 c4 10             	add    $0x10,%esp
80107f13:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f16:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f1a:	0f 84 92 00 00 00    	je     80107fb2 <copyuvm+0xe1>
      continue;
    if(!(*pte & PTE_P)){
80107f20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f23:	8b 00                	mov    (%eax),%eax
80107f25:	83 e0 01             	and    $0x1,%eax
80107f28:	85 c0                	test   %eax,%eax
80107f2a:	0f 84 85 00 00 00    	je     80107fb5 <copyuvm+0xe4>
      continue;
    }
    cprintf("[copyuvm] i %x\n",i);
80107f30:	83 ec 08             	sub    $0x8,%esp
80107f33:	ff 75 f4             	push   -0xc(%ebp)
80107f36:	68 c0 ae 10 80       	push   $0x8010aec0
80107f3b:	e8 cc 84 ff ff       	call   8010040c <cprintf>
80107f40:	83 c4 10             	add    $0x10,%esp

    // PTE_ADDR 페이지 테이블 엔트리에서 물리 주소 부분
    // PTE_FLAGS flag 부분 추출
    pa = PTE_ADDR(*pte);
80107f43:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f46:	8b 00                	mov    (%eax),%eax
80107f48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107f50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f53:	8b 00                	mov    (%eax),%eax
80107f55:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 페이지를 복사할 물리 주소 할당
    if((mem = kalloc()) == 0)
80107f5d:	e8 86 a9 ff ff       	call   801028e8 <kalloc>
80107f62:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107f65:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107f69:	74 72                	je     80107fdd <copyuvm+0x10c>
      goto bad;
    // 현재 페이지의 물리 주소인 pa를  mem에 복사
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107f6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f6e:	05 00 00 00 80       	add    $0x80000000,%eax
80107f73:	83 ec 04             	sub    $0x4,%esp
80107f76:	68 00 10 00 00       	push   $0x1000
80107f7b:	50                   	push   %eax
80107f7c:	ff 75 e0             	push   -0x20(%ebp)
80107f7f:	e8 ae ce ff ff       	call   80104e32 <memmove>
80107f84:	83 c4 10             	add    $0x10,%esp
    // 현재 가상주소에 복사받은 mem을 매핑
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107f87:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107f8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107f8d:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f96:	83 ec 0c             	sub    $0xc,%esp
80107f99:	52                   	push   %edx
80107f9a:	51                   	push   %ecx
80107f9b:	68 00 10 00 00       	push   $0x1000
80107fa0:	50                   	push   %eax
80107fa1:	ff 75 f0             	push   -0x10(%ebp)
80107fa4:	e8 a9 f7 ff ff       	call   80107752 <mappages>
80107fa9:	83 c4 20             	add    $0x20,%esp
80107fac:	85 c0                	test   %eax,%eax
80107fae:	78 30                	js     80107fe0 <copyuvm+0x10f>
80107fb0:	eb 04                	jmp    80107fb6 <copyuvm+0xe5>
      continue;
80107fb2:	90                   	nop
80107fb3:	eb 01                	jmp    80107fb6 <copyuvm+0xe5>
      continue;
80107fb5:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107fb6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc0:	85 c0                	test   %eax,%eax
80107fc2:	0f 89 37 ff ff ff    	jns    80107eff <copyuvm+0x2e>
      goto bad;
  }  

  cprintf("[copyuvm] complete\n");
80107fc8:	83 ec 0c             	sub    $0xc,%esp
80107fcb:	68 d0 ae 10 80       	push   $0x8010aed0
80107fd0:	e8 37 84 ff ff       	call   8010040c <cprintf>
80107fd5:	83 c4 10             	add    $0x10,%esp
  return d;
80107fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fdb:	eb 17                	jmp    80107ff4 <copyuvm+0x123>
      goto bad;
80107fdd:	90                   	nop
80107fde:	eb 01                	jmp    80107fe1 <copyuvm+0x110>
      goto bad;
80107fe0:	90                   	nop

bad:
  freevm(d);
80107fe1:	83 ec 0c             	sub    $0xc,%esp
80107fe4:	ff 75 f0             	push   -0x10(%ebp)
80107fe7:	e8 03 fe ff ff       	call   80107def <freevm>
80107fec:	83 c4 10             	add    $0x10,%esp
  return 0;
80107fef:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ff4:	c9                   	leave
80107ff5:	c3                   	ret

80107ff6 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107ff6:	f3 0f 1e fb          	endbr32
80107ffa:	55                   	push   %ebp
80107ffb:	89 e5                	mov    %esp,%ebp
80107ffd:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108000:	83 ec 04             	sub    $0x4,%esp
80108003:	6a 00                	push   $0x0
80108005:	ff 75 0c             	push   0xc(%ebp)
80108008:	ff 75 08             	push   0x8(%ebp)
8010800b:	e8 a8 f6 ff ff       	call   801076b8 <walkpgdir>
80108010:	83 c4 10             	add    $0x10,%esp
80108013:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108016:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108019:	8b 00                	mov    (%eax),%eax
8010801b:	83 e0 01             	and    $0x1,%eax
8010801e:	85 c0                	test   %eax,%eax
80108020:	75 07                	jne    80108029 <uva2ka+0x33>
    return 0;
80108022:	b8 00 00 00 00       	mov    $0x0,%eax
80108027:	eb 22                	jmp    8010804b <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
80108029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802c:	8b 00                	mov    (%eax),%eax
8010802e:	83 e0 04             	and    $0x4,%eax
80108031:	85 c0                	test   %eax,%eax
80108033:	75 07                	jne    8010803c <uva2ka+0x46>
    return 0;
80108035:	b8 00 00 00 00       	mov    $0x0,%eax
8010803a:	eb 0f                	jmp    8010804b <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
8010803c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803f:	8b 00                	mov    (%eax),%eax
80108041:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108046:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010804b:	c9                   	leave
8010804c:	c3                   	ret

8010804d <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010804d:	f3 0f 1e fb          	endbr32
80108051:	55                   	push   %ebp
80108052:	89 e5                	mov    %esp,%ebp
80108054:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108057:	8b 45 10             	mov    0x10(%ebp),%eax
8010805a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010805d:	eb 7f                	jmp    801080de <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
8010805f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108062:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108067:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010806a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010806d:	83 ec 08             	sub    $0x8,%esp
80108070:	50                   	push   %eax
80108071:	ff 75 08             	push   0x8(%ebp)
80108074:	e8 7d ff ff ff       	call   80107ff6 <uva2ka>
80108079:	83 c4 10             	add    $0x10,%esp
8010807c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010807f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108083:	75 07                	jne    8010808c <copyout+0x3f>
      return -1;
80108085:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010808a:	eb 61                	jmp    801080ed <copyout+0xa0>
    n = PGSIZE - (va - va0);
8010808c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010808f:	2b 45 0c             	sub    0xc(%ebp),%eax
80108092:	05 00 10 00 00       	add    $0x1000,%eax
80108097:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010809a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010809d:	3b 45 14             	cmp    0x14(%ebp),%eax
801080a0:	76 06                	jbe    801080a8 <copyout+0x5b>
      n = len;
801080a2:	8b 45 14             	mov    0x14(%ebp),%eax
801080a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801080a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801080ab:	2b 45 ec             	sub    -0x14(%ebp),%eax
801080ae:	89 c2                	mov    %eax,%edx
801080b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801080b3:	01 d0                	add    %edx,%eax
801080b5:	83 ec 04             	sub    $0x4,%esp
801080b8:	ff 75 f0             	push   -0x10(%ebp)
801080bb:	ff 75 f4             	push   -0xc(%ebp)
801080be:	50                   	push   %eax
801080bf:	e8 6e cd ff ff       	call   80104e32 <memmove>
801080c4:	83 c4 10             	add    $0x10,%esp
    len -= n;
801080c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080ca:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801080cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080d0:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801080d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080d6:	05 00 10 00 00       	add    $0x1000,%eax
801080db:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801080de:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801080e2:	0f 85 77 ff ff ff    	jne    8010805f <copyout+0x12>
  }
  return 0;
801080e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080ed:	c9                   	leave
801080ee:	c3                   	ret

801080ef <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
801080ef:	f3 0f 1e fb          	endbr32
801080f3:	55                   	push   %ebp
801080f4:	89 e5                	mov    %esp,%ebp
801080f6:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801080f9:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108100:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108103:	8b 40 08             	mov    0x8(%eax),%eax
80108106:	05 00 00 00 80       	add    $0x80000000,%eax
8010810b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
8010810e:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108118:	8b 40 24             	mov    0x24(%eax),%eax
8010811b:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
80108120:	c7 05 80 80 19 80 00 	movl   $0x0,0x80198080
80108127:	00 00 00 

  while(i<madt->len){
8010812a:	90                   	nop
8010812b:	e9 be 00 00 00       	jmp    801081ee <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
80108130:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108133:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108136:	01 d0                	add    %edx,%eax
80108138:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
8010813b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010813e:	0f b6 00             	movzbl (%eax),%eax
80108141:	0f b6 c0             	movzbl %al,%eax
80108144:	83 f8 05             	cmp    $0x5,%eax
80108147:	0f 87 a1 00 00 00    	ja     801081ee <mpinit_uefi+0xff>
8010814d:	8b 04 85 e4 ae 10 80 	mov    -0x7fef511c(,%eax,4),%eax
80108154:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108157:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010815a:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
8010815d:	a1 80 80 19 80       	mov    0x80198080,%eax
80108162:	83 f8 03             	cmp    $0x3,%eax
80108165:	7f 28                	jg     8010818f <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108167:	8b 15 80 80 19 80    	mov    0x80198080,%edx
8010816d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108170:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108174:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
8010817a:	81 c2 c0 7d 19 80    	add    $0x80197dc0,%edx
80108180:	88 02                	mov    %al,(%edx)
          ncpu++;
80108182:	a1 80 80 19 80       	mov    0x80198080,%eax
80108187:	83 c0 01             	add    $0x1,%eax
8010818a:	a3 80 80 19 80       	mov    %eax,0x80198080
        }
        i += lapic_entry->record_len;
8010818f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108192:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108196:	0f b6 c0             	movzbl %al,%eax
80108199:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010819c:	eb 50                	jmp    801081ee <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
8010819e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
801081a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801081a7:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801081ab:	a2 a0 7d 19 80       	mov    %al,0x80197da0
        i += ioapic->record_len;
801081b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801081b3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801081b7:	0f b6 c0             	movzbl %al,%eax
801081ba:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801081bd:	eb 2f                	jmp    801081ee <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801081bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801081c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081c8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801081cc:	0f b6 c0             	movzbl %al,%eax
801081cf:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801081d2:	eb 1a                	jmp    801081ee <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801081d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801081da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081dd:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801081e1:	0f b6 c0             	movzbl %al,%eax
801081e4:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801081e7:	eb 05                	jmp    801081ee <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
801081e9:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801081ed:	90                   	nop
  while(i<madt->len){
801081ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f1:	8b 40 04             	mov    0x4(%eax),%eax
801081f4:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801081f7:	0f 82 33 ff ff ff    	jb     80108130 <mpinit_uefi+0x41>
    }
  }

}
801081fd:	90                   	nop
801081fe:	90                   	nop
801081ff:	c9                   	leave
80108200:	c3                   	ret

80108201 <inb>:
{
80108201:	55                   	push   %ebp
80108202:	89 e5                	mov    %esp,%ebp
80108204:	83 ec 14             	sub    $0x14,%esp
80108207:	8b 45 08             	mov    0x8(%ebp),%eax
8010820a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010820e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108212:	89 c2                	mov    %eax,%edx
80108214:	ec                   	in     (%dx),%al
80108215:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108218:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010821c:	c9                   	leave
8010821d:	c3                   	ret

8010821e <outb>:
{
8010821e:	55                   	push   %ebp
8010821f:	89 e5                	mov    %esp,%ebp
80108221:	83 ec 08             	sub    $0x8,%esp
80108224:	8b 45 08             	mov    0x8(%ebp),%eax
80108227:	8b 55 0c             	mov    0xc(%ebp),%edx
8010822a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010822e:	89 d0                	mov    %edx,%eax
80108230:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108233:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108237:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010823b:	ee                   	out    %al,(%dx)
}
8010823c:	90                   	nop
8010823d:	c9                   	leave
8010823e:	c3                   	ret

8010823f <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
8010823f:	f3 0f 1e fb          	endbr32
80108243:	55                   	push   %ebp
80108244:	89 e5                	mov    %esp,%ebp
80108246:	83 ec 28             	sub    $0x28,%esp
80108249:	8b 45 08             	mov    0x8(%ebp),%eax
8010824c:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
8010824f:	6a 00                	push   $0x0
80108251:	68 fa 03 00 00       	push   $0x3fa
80108256:	e8 c3 ff ff ff       	call   8010821e <outb>
8010825b:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010825e:	68 80 00 00 00       	push   $0x80
80108263:	68 fb 03 00 00       	push   $0x3fb
80108268:	e8 b1 ff ff ff       	call   8010821e <outb>
8010826d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108270:	6a 0c                	push   $0xc
80108272:	68 f8 03 00 00       	push   $0x3f8
80108277:	e8 a2 ff ff ff       	call   8010821e <outb>
8010827c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010827f:	6a 00                	push   $0x0
80108281:	68 f9 03 00 00       	push   $0x3f9
80108286:	e8 93 ff ff ff       	call   8010821e <outb>
8010828b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010828e:	6a 03                	push   $0x3
80108290:	68 fb 03 00 00       	push   $0x3fb
80108295:	e8 84 ff ff ff       	call   8010821e <outb>
8010829a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010829d:	6a 00                	push   $0x0
8010829f:	68 fc 03 00 00       	push   $0x3fc
801082a4:	e8 75 ff ff ff       	call   8010821e <outb>
801082a9:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801082ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082b3:	eb 11                	jmp    801082c6 <uart_debug+0x87>
801082b5:	83 ec 0c             	sub    $0xc,%esp
801082b8:	6a 0a                	push   $0xa
801082ba:	e8 db a9 ff ff       	call   80102c9a <microdelay>
801082bf:	83 c4 10             	add    $0x10,%esp
801082c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801082c6:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801082ca:	7f 1a                	jg     801082e6 <uart_debug+0xa7>
801082cc:	83 ec 0c             	sub    $0xc,%esp
801082cf:	68 fd 03 00 00       	push   $0x3fd
801082d4:	e8 28 ff ff ff       	call   80108201 <inb>
801082d9:	83 c4 10             	add    $0x10,%esp
801082dc:	0f b6 c0             	movzbl %al,%eax
801082df:	83 e0 20             	and    $0x20,%eax
801082e2:	85 c0                	test   %eax,%eax
801082e4:	74 cf                	je     801082b5 <uart_debug+0x76>
  outb(COM1+0, p);
801082e6:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801082ea:	0f b6 c0             	movzbl %al,%eax
801082ed:	83 ec 08             	sub    $0x8,%esp
801082f0:	50                   	push   %eax
801082f1:	68 f8 03 00 00       	push   $0x3f8
801082f6:	e8 23 ff ff ff       	call   8010821e <outb>
801082fb:	83 c4 10             	add    $0x10,%esp
}
801082fe:	90                   	nop
801082ff:	c9                   	leave
80108300:	c3                   	ret

80108301 <uart_debugs>:

void uart_debugs(char *p){
80108301:	f3 0f 1e fb          	endbr32
80108305:	55                   	push   %ebp
80108306:	89 e5                	mov    %esp,%ebp
80108308:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010830b:	eb 1b                	jmp    80108328 <uart_debugs+0x27>
    uart_debug(*p++);
8010830d:	8b 45 08             	mov    0x8(%ebp),%eax
80108310:	8d 50 01             	lea    0x1(%eax),%edx
80108313:	89 55 08             	mov    %edx,0x8(%ebp)
80108316:	0f b6 00             	movzbl (%eax),%eax
80108319:	0f be c0             	movsbl %al,%eax
8010831c:	83 ec 0c             	sub    $0xc,%esp
8010831f:	50                   	push   %eax
80108320:	e8 1a ff ff ff       	call   8010823f <uart_debug>
80108325:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108328:	8b 45 08             	mov    0x8(%ebp),%eax
8010832b:	0f b6 00             	movzbl (%eax),%eax
8010832e:	84 c0                	test   %al,%al
80108330:	75 db                	jne    8010830d <uart_debugs+0xc>
  }
}
80108332:	90                   	nop
80108333:	90                   	nop
80108334:	c9                   	leave
80108335:	c3                   	ret

80108336 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108336:	f3 0f 1e fb          	endbr32
8010833a:	55                   	push   %ebp
8010833b:	89 e5                	mov    %esp,%ebp
8010833d:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108340:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108347:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010834a:	8b 50 14             	mov    0x14(%eax),%edx
8010834d:	8b 40 10             	mov    0x10(%eax),%eax
80108350:	a3 84 80 19 80       	mov    %eax,0x80198084
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108355:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108358:	8b 50 1c             	mov    0x1c(%eax),%edx
8010835b:	8b 40 18             	mov    0x18(%eax),%eax
8010835e:	a3 8c 80 19 80       	mov    %eax,0x8019808c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108363:	a1 8c 80 19 80       	mov    0x8019808c,%eax
80108368:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
8010836d:	29 c2                	sub    %eax,%edx
8010836f:	89 d0                	mov    %edx,%eax
80108371:	a3 88 80 19 80       	mov    %eax,0x80198088
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108376:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108379:	8b 50 24             	mov    0x24(%eax),%edx
8010837c:	8b 40 20             	mov    0x20(%eax),%eax
8010837f:	a3 90 80 19 80       	mov    %eax,0x80198090
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108384:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108387:	8b 50 2c             	mov    0x2c(%eax),%edx
8010838a:	8b 40 28             	mov    0x28(%eax),%eax
8010838d:	a3 94 80 19 80       	mov    %eax,0x80198094
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108392:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108395:	8b 50 34             	mov    0x34(%eax),%edx
80108398:	8b 40 30             	mov    0x30(%eax),%eax
8010839b:	a3 98 80 19 80       	mov    %eax,0x80198098
}
801083a0:	90                   	nop
801083a1:	c9                   	leave
801083a2:	c3                   	ret

801083a3 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801083a3:	f3 0f 1e fb          	endbr32
801083a7:	55                   	push   %ebp
801083a8:	89 e5                	mov    %esp,%ebp
801083aa:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801083ad:	8b 15 98 80 19 80    	mov    0x80198098,%edx
801083b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801083b6:	0f af d0             	imul   %eax,%edx
801083b9:	8b 45 08             	mov    0x8(%ebp),%eax
801083bc:	01 d0                	add    %edx,%eax
801083be:	c1 e0 02             	shl    $0x2,%eax
801083c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801083c4:	8b 15 88 80 19 80    	mov    0x80198088,%edx
801083ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083cd:	01 d0                	add    %edx,%eax
801083cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801083d2:	8b 45 10             	mov    0x10(%ebp),%eax
801083d5:	0f b6 10             	movzbl (%eax),%edx
801083d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083db:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801083dd:	8b 45 10             	mov    0x10(%ebp),%eax
801083e0:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801083e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083e7:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801083ea:	8b 45 10             	mov    0x10(%ebp),%eax
801083ed:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801083f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083f4:	88 50 02             	mov    %dl,0x2(%eax)
}
801083f7:	90                   	nop
801083f8:	c9                   	leave
801083f9:	c3                   	ret

801083fa <graphic_scroll_up>:

void graphic_scroll_up(int height){
801083fa:	f3 0f 1e fb          	endbr32
801083fe:	55                   	push   %ebp
801083ff:	89 e5                	mov    %esp,%ebp
80108401:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108404:	8b 15 98 80 19 80    	mov    0x80198098,%edx
8010840a:	8b 45 08             	mov    0x8(%ebp),%eax
8010840d:	0f af c2             	imul   %edx,%eax
80108410:	c1 e0 02             	shl    $0x2,%eax
80108413:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108416:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
8010841c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841f:	29 c2                	sub    %eax,%edx
80108421:	89 d0                	mov    %edx,%eax
80108423:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
80108429:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010842c:	01 ca                	add    %ecx,%edx
8010842e:	89 d1                	mov    %edx,%ecx
80108430:	8b 15 88 80 19 80    	mov    0x80198088,%edx
80108436:	83 ec 04             	sub    $0x4,%esp
80108439:	50                   	push   %eax
8010843a:	51                   	push   %ecx
8010843b:	52                   	push   %edx
8010843c:	e8 f1 c9 ff ff       	call   80104e32 <memmove>
80108441:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108447:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
8010844d:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
80108453:	01 d1                	add    %edx,%ecx
80108455:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108458:	29 d1                	sub    %edx,%ecx
8010845a:	89 ca                	mov    %ecx,%edx
8010845c:	83 ec 04             	sub    $0x4,%esp
8010845f:	50                   	push   %eax
80108460:	6a 00                	push   $0x0
80108462:	52                   	push   %edx
80108463:	e8 03 c9 ff ff       	call   80104d6b <memset>
80108468:	83 c4 10             	add    $0x10,%esp
}
8010846b:	90                   	nop
8010846c:	c9                   	leave
8010846d:	c3                   	ret

8010846e <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
8010846e:	f3 0f 1e fb          	endbr32
80108472:	55                   	push   %ebp
80108473:	89 e5                	mov    %esp,%ebp
80108475:	53                   	push   %ebx
80108476:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108479:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108480:	e9 b1 00 00 00       	jmp    80108536 <font_render+0xc8>
    for(int j=14;j>-1;j--){
80108485:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
8010848c:	e9 97 00 00 00       	jmp    80108528 <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108491:	8b 45 10             	mov    0x10(%ebp),%eax
80108494:	83 e8 20             	sub    $0x20,%eax
80108497:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010849a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010849d:	01 d0                	add    %edx,%eax
8010849f:	0f b7 84 00 00 af 10 	movzwl -0x7fef5100(%eax,%eax,1),%eax
801084a6:	80 
801084a7:	0f b7 d0             	movzwl %ax,%edx
801084aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084ad:	bb 01 00 00 00       	mov    $0x1,%ebx
801084b2:	89 c1                	mov    %eax,%ecx
801084b4:	d3 e3                	shl    %cl,%ebx
801084b6:	89 d8                	mov    %ebx,%eax
801084b8:	21 d0                	and    %edx,%eax
801084ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801084bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084c0:	ba 01 00 00 00       	mov    $0x1,%edx
801084c5:	89 c1                	mov    %eax,%ecx
801084c7:	d3 e2                	shl    %cl,%edx
801084c9:	89 d0                	mov    %edx,%eax
801084cb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801084ce:	75 2b                	jne    801084fb <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801084d0:	8b 55 0c             	mov    0xc(%ebp),%edx
801084d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d6:	01 c2                	add    %eax,%edx
801084d8:	b8 0e 00 00 00       	mov    $0xe,%eax
801084dd:	2b 45 f0             	sub    -0x10(%ebp),%eax
801084e0:	89 c1                	mov    %eax,%ecx
801084e2:	8b 45 08             	mov    0x8(%ebp),%eax
801084e5:	01 c8                	add    %ecx,%eax
801084e7:	83 ec 04             	sub    $0x4,%esp
801084ea:	68 e0 f4 10 80       	push   $0x8010f4e0
801084ef:	52                   	push   %edx
801084f0:	50                   	push   %eax
801084f1:	e8 ad fe ff ff       	call   801083a3 <graphic_draw_pixel>
801084f6:	83 c4 10             	add    $0x10,%esp
801084f9:	eb 29                	jmp    80108524 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801084fb:	8b 55 0c             	mov    0xc(%ebp),%edx
801084fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108501:	01 c2                	add    %eax,%edx
80108503:	b8 0e 00 00 00       	mov    $0xe,%eax
80108508:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010850b:	89 c1                	mov    %eax,%ecx
8010850d:	8b 45 08             	mov    0x8(%ebp),%eax
80108510:	01 c8                	add    %ecx,%eax
80108512:	83 ec 04             	sub    $0x4,%esp
80108515:	68 64 d0 18 80       	push   $0x8018d064
8010851a:	52                   	push   %edx
8010851b:	50                   	push   %eax
8010851c:	e8 82 fe ff ff       	call   801083a3 <graphic_draw_pixel>
80108521:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108524:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108528:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010852c:	0f 89 5f ff ff ff    	jns    80108491 <font_render+0x23>
  for(int i=0;i<30;i++){
80108532:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108536:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010853a:	0f 8e 45 ff ff ff    	jle    80108485 <font_render+0x17>
      }
    }
  }
}
80108540:	90                   	nop
80108541:	90                   	nop
80108542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108545:	c9                   	leave
80108546:	c3                   	ret

80108547 <font_render_string>:

void font_render_string(char *string,int row){
80108547:	f3 0f 1e fb          	endbr32
8010854b:	55                   	push   %ebp
8010854c:	89 e5                	mov    %esp,%ebp
8010854e:	53                   	push   %ebx
8010854f:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108552:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108559:	eb 33                	jmp    8010858e <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
8010855b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010855e:	8b 45 08             	mov    0x8(%ebp),%eax
80108561:	01 d0                	add    %edx,%eax
80108563:	0f b6 00             	movzbl (%eax),%eax
80108566:	0f be d8             	movsbl %al,%ebx
80108569:	8b 45 0c             	mov    0xc(%ebp),%eax
8010856c:	6b c8 1e             	imul   $0x1e,%eax,%ecx
8010856f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108572:	89 d0                	mov    %edx,%eax
80108574:	c1 e0 04             	shl    $0x4,%eax
80108577:	29 d0                	sub    %edx,%eax
80108579:	83 c0 02             	add    $0x2,%eax
8010857c:	83 ec 04             	sub    $0x4,%esp
8010857f:	53                   	push   %ebx
80108580:	51                   	push   %ecx
80108581:	50                   	push   %eax
80108582:	e8 e7 fe ff ff       	call   8010846e <font_render>
80108587:	83 c4 10             	add    $0x10,%esp
    i++;
8010858a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
8010858e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108591:	8b 45 08             	mov    0x8(%ebp),%eax
80108594:	01 d0                	add    %edx,%eax
80108596:	0f b6 00             	movzbl (%eax),%eax
80108599:	84 c0                	test   %al,%al
8010859b:	74 06                	je     801085a3 <font_render_string+0x5c>
8010859d:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801085a1:	7e b8                	jle    8010855b <font_render_string+0x14>
  }
}
801085a3:	90                   	nop
801085a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801085a7:	c9                   	leave
801085a8:	c3                   	ret

801085a9 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801085a9:	f3 0f 1e fb          	endbr32
801085ad:	55                   	push   %ebp
801085ae:	89 e5                	mov    %esp,%ebp
801085b0:	53                   	push   %ebx
801085b1:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801085b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085bb:	eb 6b                	jmp    80108628 <pci_init+0x7f>
    for(int j=0;j<32;j++){
801085bd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801085c4:	eb 58                	jmp    8010861e <pci_init+0x75>
      for(int k=0;k<8;k++){
801085c6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801085cd:	eb 45                	jmp    80108614 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
801085cf:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801085d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801085d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d8:	83 ec 0c             	sub    $0xc,%esp
801085db:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801085de:	53                   	push   %ebx
801085df:	6a 00                	push   $0x0
801085e1:	51                   	push   %ecx
801085e2:	52                   	push   %edx
801085e3:	50                   	push   %eax
801085e4:	e8 c0 00 00 00       	call   801086a9 <pci_access_config>
801085e9:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801085ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085ef:	0f b7 c0             	movzwl %ax,%eax
801085f2:	3d ff ff 00 00       	cmp    $0xffff,%eax
801085f7:	74 17                	je     80108610 <pci_init+0x67>
        pci_init_device(i,j,k);
801085f9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801085fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801085ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108602:	83 ec 04             	sub    $0x4,%esp
80108605:	51                   	push   %ecx
80108606:	52                   	push   %edx
80108607:	50                   	push   %eax
80108608:	e8 4f 01 00 00       	call   8010875c <pci_init_device>
8010860d:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108610:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108614:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108618:	7e b5                	jle    801085cf <pci_init+0x26>
    for(int j=0;j<32;j++){
8010861a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010861e:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108622:	7e a2                	jle    801085c6 <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108624:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108628:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010862f:	7e 8c                	jle    801085bd <pci_init+0x14>
      }
      }
    }
  }
}
80108631:	90                   	nop
80108632:	90                   	nop
80108633:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108636:	c9                   	leave
80108637:	c3                   	ret

80108638 <pci_write_config>:

void pci_write_config(uint config){
80108638:	f3 0f 1e fb          	endbr32
8010863c:	55                   	push   %ebp
8010863d:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010863f:	8b 45 08             	mov    0x8(%ebp),%eax
80108642:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108647:	89 c0                	mov    %eax,%eax
80108649:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010864a:	90                   	nop
8010864b:	5d                   	pop    %ebp
8010864c:	c3                   	ret

8010864d <pci_write_data>:

void pci_write_data(uint config){
8010864d:	f3 0f 1e fb          	endbr32
80108651:	55                   	push   %ebp
80108652:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108654:	8b 45 08             	mov    0x8(%ebp),%eax
80108657:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010865c:	89 c0                	mov    %eax,%eax
8010865e:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010865f:	90                   	nop
80108660:	5d                   	pop    %ebp
80108661:	c3                   	ret

80108662 <pci_read_config>:
uint pci_read_config(){
80108662:	f3 0f 1e fb          	endbr32
80108666:	55                   	push   %ebp
80108667:	89 e5                	mov    %esp,%ebp
80108669:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
8010866c:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108671:	ed                   	in     (%dx),%eax
80108672:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108675:	83 ec 0c             	sub    $0xc,%esp
80108678:	68 c8 00 00 00       	push   $0xc8
8010867d:	e8 18 a6 ff ff       	call   80102c9a <microdelay>
80108682:	83 c4 10             	add    $0x10,%esp
  return data;
80108685:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108688:	c9                   	leave
80108689:	c3                   	ret

8010868a <pci_test>:


void pci_test(){
8010868a:	f3 0f 1e fb          	endbr32
8010868e:	55                   	push   %ebp
8010868f:	89 e5                	mov    %esp,%ebp
80108691:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108694:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
8010869b:	ff 75 fc             	push   -0x4(%ebp)
8010869e:	e8 95 ff ff ff       	call   80108638 <pci_write_config>
801086a3:	83 c4 04             	add    $0x4,%esp
}
801086a6:	90                   	nop
801086a7:	c9                   	leave
801086a8:	c3                   	ret

801086a9 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801086a9:	f3 0f 1e fb          	endbr32
801086ad:	55                   	push   %ebp
801086ae:	89 e5                	mov    %esp,%ebp
801086b0:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801086b3:	8b 45 08             	mov    0x8(%ebp),%eax
801086b6:	c1 e0 10             	shl    $0x10,%eax
801086b9:	25 00 00 ff 00       	and    $0xff0000,%eax
801086be:	89 c2                	mov    %eax,%edx
801086c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801086c3:	c1 e0 0b             	shl    $0xb,%eax
801086c6:	0f b7 c0             	movzwl %ax,%eax
801086c9:	09 c2                	or     %eax,%edx
801086cb:	8b 45 10             	mov    0x10(%ebp),%eax
801086ce:	c1 e0 08             	shl    $0x8,%eax
801086d1:	25 00 07 00 00       	and    $0x700,%eax
801086d6:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801086d8:	8b 45 14             	mov    0x14(%ebp),%eax
801086db:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801086e0:	09 d0                	or     %edx,%eax
801086e2:	0d 00 00 00 80       	or     $0x80000000,%eax
801086e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801086ea:	ff 75 f4             	push   -0xc(%ebp)
801086ed:	e8 46 ff ff ff       	call   80108638 <pci_write_config>
801086f2:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801086f5:	e8 68 ff ff ff       	call   80108662 <pci_read_config>
801086fa:	8b 55 18             	mov    0x18(%ebp),%edx
801086fd:	89 02                	mov    %eax,(%edx)
}
801086ff:	90                   	nop
80108700:	c9                   	leave
80108701:	c3                   	ret

80108702 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108702:	f3 0f 1e fb          	endbr32
80108706:	55                   	push   %ebp
80108707:	89 e5                	mov    %esp,%ebp
80108709:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010870c:	8b 45 08             	mov    0x8(%ebp),%eax
8010870f:	c1 e0 10             	shl    $0x10,%eax
80108712:	25 00 00 ff 00       	and    $0xff0000,%eax
80108717:	89 c2                	mov    %eax,%edx
80108719:	8b 45 0c             	mov    0xc(%ebp),%eax
8010871c:	c1 e0 0b             	shl    $0xb,%eax
8010871f:	0f b7 c0             	movzwl %ax,%eax
80108722:	09 c2                	or     %eax,%edx
80108724:	8b 45 10             	mov    0x10(%ebp),%eax
80108727:	c1 e0 08             	shl    $0x8,%eax
8010872a:	25 00 07 00 00       	and    $0x700,%eax
8010872f:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108731:	8b 45 14             	mov    0x14(%ebp),%eax
80108734:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108739:	09 d0                	or     %edx,%eax
8010873b:	0d 00 00 00 80       	or     $0x80000000,%eax
80108740:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108743:	ff 75 fc             	push   -0x4(%ebp)
80108746:	e8 ed fe ff ff       	call   80108638 <pci_write_config>
8010874b:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
8010874e:	ff 75 18             	push   0x18(%ebp)
80108751:	e8 f7 fe ff ff       	call   8010864d <pci_write_data>
80108756:	83 c4 04             	add    $0x4,%esp
}
80108759:	90                   	nop
8010875a:	c9                   	leave
8010875b:	c3                   	ret

8010875c <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010875c:	f3 0f 1e fb          	endbr32
80108760:	55                   	push   %ebp
80108761:	89 e5                	mov    %esp,%ebp
80108763:	53                   	push   %ebx
80108764:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108767:	8b 45 08             	mov    0x8(%ebp),%eax
8010876a:	a2 9c 80 19 80       	mov    %al,0x8019809c
  dev.device_num = device_num;
8010876f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108772:	a2 9d 80 19 80       	mov    %al,0x8019809d
  dev.function_num = function_num;
80108777:	8b 45 10             	mov    0x10(%ebp),%eax
8010877a:	a2 9e 80 19 80       	mov    %al,0x8019809e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
8010877f:	ff 75 10             	push   0x10(%ebp)
80108782:	ff 75 0c             	push   0xc(%ebp)
80108785:	ff 75 08             	push   0x8(%ebp)
80108788:	68 44 c5 10 80       	push   $0x8010c544
8010878d:	e8 7a 7c ff ff       	call   8010040c <cprintf>
80108792:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108795:	83 ec 0c             	sub    $0xc,%esp
80108798:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010879b:	50                   	push   %eax
8010879c:	6a 00                	push   $0x0
8010879e:	ff 75 10             	push   0x10(%ebp)
801087a1:	ff 75 0c             	push   0xc(%ebp)
801087a4:	ff 75 08             	push   0x8(%ebp)
801087a7:	e8 fd fe ff ff       	call   801086a9 <pci_access_config>
801087ac:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
801087af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087b2:	c1 e8 10             	shr    $0x10,%eax
801087b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801087b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087bb:	25 ff ff 00 00       	and    $0xffff,%eax
801087c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801087c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c6:	a3 a0 80 19 80       	mov    %eax,0x801980a0
  dev.vendor_id = vendor_id;
801087cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087ce:	a3 a4 80 19 80       	mov    %eax,0x801980a4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801087d3:	83 ec 04             	sub    $0x4,%esp
801087d6:	ff 75 f0             	push   -0x10(%ebp)
801087d9:	ff 75 f4             	push   -0xc(%ebp)
801087dc:	68 78 c5 10 80       	push   $0x8010c578
801087e1:	e8 26 7c ff ff       	call   8010040c <cprintf>
801087e6:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801087e9:	83 ec 0c             	sub    $0xc,%esp
801087ec:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087ef:	50                   	push   %eax
801087f0:	6a 08                	push   $0x8
801087f2:	ff 75 10             	push   0x10(%ebp)
801087f5:	ff 75 0c             	push   0xc(%ebp)
801087f8:	ff 75 08             	push   0x8(%ebp)
801087fb:	e8 a9 fe ff ff       	call   801086a9 <pci_access_config>
80108800:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108803:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108806:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108809:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010880c:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010880f:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108812:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108815:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108818:	0f b6 c0             	movzbl %al,%eax
8010881b:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010881e:	c1 eb 18             	shr    $0x18,%ebx
80108821:	83 ec 0c             	sub    $0xc,%esp
80108824:	51                   	push   %ecx
80108825:	52                   	push   %edx
80108826:	50                   	push   %eax
80108827:	53                   	push   %ebx
80108828:	68 9c c5 10 80       	push   $0x8010c59c
8010882d:	e8 da 7b ff ff       	call   8010040c <cprintf>
80108832:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108835:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108838:	c1 e8 18             	shr    $0x18,%eax
8010883b:	a2 a8 80 19 80       	mov    %al,0x801980a8
  dev.sub_class = (data>>16)&0xFF;
80108840:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108843:	c1 e8 10             	shr    $0x10,%eax
80108846:	a2 a9 80 19 80       	mov    %al,0x801980a9
  dev.interface = (data>>8)&0xFF;
8010884b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010884e:	c1 e8 08             	shr    $0x8,%eax
80108851:	a2 aa 80 19 80       	mov    %al,0x801980aa
  dev.revision_id = data&0xFF;
80108856:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108859:	a2 ab 80 19 80       	mov    %al,0x801980ab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
8010885e:	83 ec 0c             	sub    $0xc,%esp
80108861:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108864:	50                   	push   %eax
80108865:	6a 10                	push   $0x10
80108867:	ff 75 10             	push   0x10(%ebp)
8010886a:	ff 75 0c             	push   0xc(%ebp)
8010886d:	ff 75 08             	push   0x8(%ebp)
80108870:	e8 34 fe ff ff       	call   801086a9 <pci_access_config>
80108875:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108878:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010887b:	a3 ac 80 19 80       	mov    %eax,0x801980ac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108880:	83 ec 0c             	sub    $0xc,%esp
80108883:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108886:	50                   	push   %eax
80108887:	6a 14                	push   $0x14
80108889:	ff 75 10             	push   0x10(%ebp)
8010888c:	ff 75 0c             	push   0xc(%ebp)
8010888f:	ff 75 08             	push   0x8(%ebp)
80108892:	e8 12 fe ff ff       	call   801086a9 <pci_access_config>
80108897:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
8010889a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010889d:	a3 b0 80 19 80       	mov    %eax,0x801980b0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801088a2:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801088a9:	75 5a                	jne    80108905 <pci_init_device+0x1a9>
801088ab:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801088b2:	75 51                	jne    80108905 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
801088b4:	83 ec 0c             	sub    $0xc,%esp
801088b7:	68 e1 c5 10 80       	push   $0x8010c5e1
801088bc:	e8 4b 7b ff ff       	call   8010040c <cprintf>
801088c1:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801088c4:	83 ec 0c             	sub    $0xc,%esp
801088c7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801088ca:	50                   	push   %eax
801088cb:	68 f0 00 00 00       	push   $0xf0
801088d0:	ff 75 10             	push   0x10(%ebp)
801088d3:	ff 75 0c             	push   0xc(%ebp)
801088d6:	ff 75 08             	push   0x8(%ebp)
801088d9:	e8 cb fd ff ff       	call   801086a9 <pci_access_config>
801088de:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801088e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088e4:	83 ec 08             	sub    $0x8,%esp
801088e7:	50                   	push   %eax
801088e8:	68 fb c5 10 80       	push   $0x8010c5fb
801088ed:	e8 1a 7b ff ff       	call   8010040c <cprintf>
801088f2:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801088f5:	83 ec 0c             	sub    $0xc,%esp
801088f8:	68 9c 80 19 80       	push   $0x8019809c
801088fd:	e8 09 00 00 00       	call   8010890b <i8254_init>
80108902:	83 c4 10             	add    $0x10,%esp
  }
}
80108905:	90                   	nop
80108906:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108909:	c9                   	leave
8010890a:	c3                   	ret

8010890b <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
8010890b:	f3 0f 1e fb          	endbr32
8010890f:	55                   	push   %ebp
80108910:	89 e5                	mov    %esp,%ebp
80108912:	53                   	push   %ebx
80108913:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108916:	8b 45 08             	mov    0x8(%ebp),%eax
80108919:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010891d:	0f b6 c8             	movzbl %al,%ecx
80108920:	8b 45 08             	mov    0x8(%ebp),%eax
80108923:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108927:	0f b6 d0             	movzbl %al,%edx
8010892a:	8b 45 08             	mov    0x8(%ebp),%eax
8010892d:	0f b6 00             	movzbl (%eax),%eax
80108930:	0f b6 c0             	movzbl %al,%eax
80108933:	83 ec 0c             	sub    $0xc,%esp
80108936:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108939:	53                   	push   %ebx
8010893a:	6a 04                	push   $0x4
8010893c:	51                   	push   %ecx
8010893d:	52                   	push   %edx
8010893e:	50                   	push   %eax
8010893f:	e8 65 fd ff ff       	call   801086a9 <pci_access_config>
80108944:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108947:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010894a:	83 c8 04             	or     $0x4,%eax
8010894d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108950:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108953:	8b 45 08             	mov    0x8(%ebp),%eax
80108956:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010895a:	0f b6 c8             	movzbl %al,%ecx
8010895d:	8b 45 08             	mov    0x8(%ebp),%eax
80108960:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108964:	0f b6 d0             	movzbl %al,%edx
80108967:	8b 45 08             	mov    0x8(%ebp),%eax
8010896a:	0f b6 00             	movzbl (%eax),%eax
8010896d:	0f b6 c0             	movzbl %al,%eax
80108970:	83 ec 0c             	sub    $0xc,%esp
80108973:	53                   	push   %ebx
80108974:	6a 04                	push   $0x4
80108976:	51                   	push   %ecx
80108977:	52                   	push   %edx
80108978:	50                   	push   %eax
80108979:	e8 84 fd ff ff       	call   80108702 <pci_write_config_register>
8010897e:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108981:	8b 45 08             	mov    0x8(%ebp),%eax
80108984:	8b 40 10             	mov    0x10(%eax),%eax
80108987:	05 00 00 00 40       	add    $0x40000000,%eax
8010898c:	a3 b4 80 19 80       	mov    %eax,0x801980b4
  uint *ctrl = (uint *)base_addr;
80108991:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108996:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108999:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010899e:	05 d8 00 00 00       	add    $0xd8,%eax
801089a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801089a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089a9:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801089af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b2:	8b 00                	mov    (%eax),%eax
801089b4:	0d 00 00 00 04       	or     $0x4000000,%eax
801089b9:	89 c2                	mov    %eax,%edx
801089bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089be:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801089c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089c3:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801089c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089cc:	8b 00                	mov    (%eax),%eax
801089ce:	83 c8 40             	or     $0x40,%eax
801089d1:	89 c2                	mov    %eax,%edx
801089d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d6:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
801089d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089db:	8b 10                	mov    (%eax),%edx
801089dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e0:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
801089e2:	83 ec 0c             	sub    $0xc,%esp
801089e5:	68 10 c6 10 80       	push   $0x8010c610
801089ea:	e8 1d 7a ff ff       	call   8010040c <cprintf>
801089ef:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801089f2:	e8 f1 9e ff ff       	call   801028e8 <kalloc>
801089f7:	a3 b8 80 19 80       	mov    %eax,0x801980b8
  *intr_addr = 0;
801089fc:	a1 b8 80 19 80       	mov    0x801980b8,%eax
80108a01:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108a07:	a1 b8 80 19 80       	mov    0x801980b8,%eax
80108a0c:	83 ec 08             	sub    $0x8,%esp
80108a0f:	50                   	push   %eax
80108a10:	68 32 c6 10 80       	push   $0x8010c632
80108a15:	e8 f2 79 ff ff       	call   8010040c <cprintf>
80108a1a:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108a1d:	e8 50 00 00 00       	call   80108a72 <i8254_init_recv>
  i8254_init_send();
80108a22:	e8 6d 03 00 00       	call   80108d94 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108a27:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a2e:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108a31:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a38:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108a3b:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a42:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108a45:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a4c:	0f b6 c0             	movzbl %al,%eax
80108a4f:	83 ec 0c             	sub    $0xc,%esp
80108a52:	53                   	push   %ebx
80108a53:	51                   	push   %ecx
80108a54:	52                   	push   %edx
80108a55:	50                   	push   %eax
80108a56:	68 40 c6 10 80       	push   $0x8010c640
80108a5b:	e8 ac 79 ff ff       	call   8010040c <cprintf>
80108a60:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a66:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108a6c:	90                   	nop
80108a6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a70:	c9                   	leave
80108a71:	c3                   	ret

80108a72 <i8254_init_recv>:

void i8254_init_recv(){
80108a72:	f3 0f 1e fb          	endbr32
80108a76:	55                   	push   %ebp
80108a77:	89 e5                	mov    %esp,%ebp
80108a79:	57                   	push   %edi
80108a7a:	56                   	push   %esi
80108a7b:	53                   	push   %ebx
80108a7c:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108a7f:	83 ec 0c             	sub    $0xc,%esp
80108a82:	6a 00                	push   $0x0
80108a84:	e8 ec 04 00 00       	call   80108f75 <i8254_read_eeprom>
80108a89:	83 c4 10             	add    $0x10,%esp
80108a8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108a8f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108a92:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
80108a97:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108a9a:	c1 e8 08             	shr    $0x8,%eax
80108a9d:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
80108aa2:	83 ec 0c             	sub    $0xc,%esp
80108aa5:	6a 01                	push   $0x1
80108aa7:	e8 c9 04 00 00       	call   80108f75 <i8254_read_eeprom>
80108aac:	83 c4 10             	add    $0x10,%esp
80108aaf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108ab2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108ab5:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
80108aba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108abd:	c1 e8 08             	shr    $0x8,%eax
80108ac0:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
80108ac5:	83 ec 0c             	sub    $0xc,%esp
80108ac8:	6a 02                	push   $0x2
80108aca:	e8 a6 04 00 00       	call   80108f75 <i8254_read_eeprom>
80108acf:	83 c4 10             	add    $0x10,%esp
80108ad2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108ad5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ad8:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
80108add:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ae0:	c1 e8 08             	shr    $0x8,%eax
80108ae3:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108ae8:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108aef:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108af2:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108af9:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108afc:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b03:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108b06:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b0d:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108b10:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b17:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108b1a:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b21:	0f b6 c0             	movzbl %al,%eax
80108b24:	83 ec 04             	sub    $0x4,%esp
80108b27:	57                   	push   %edi
80108b28:	56                   	push   %esi
80108b29:	53                   	push   %ebx
80108b2a:	51                   	push   %ecx
80108b2b:	52                   	push   %edx
80108b2c:	50                   	push   %eax
80108b2d:	68 58 c6 10 80       	push   $0x8010c658
80108b32:	e8 d5 78 ff ff       	call   8010040c <cprintf>
80108b37:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108b3a:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b3f:	05 00 54 00 00       	add    $0x5400,%eax
80108b44:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108b47:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b4c:	05 04 54 00 00       	add    $0x5404,%eax
80108b51:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108b54:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108b57:	c1 e0 10             	shl    $0x10,%eax
80108b5a:	0b 45 d8             	or     -0x28(%ebp),%eax
80108b5d:	89 c2                	mov    %eax,%edx
80108b5f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108b62:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108b64:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b67:	0d 00 00 00 80       	or     $0x80000000,%eax
80108b6c:	89 c2                	mov    %eax,%edx
80108b6e:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108b71:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108b73:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b78:	05 00 52 00 00       	add    $0x5200,%eax
80108b7d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108b80:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108b87:	eb 19                	jmp    80108ba2 <i8254_init_recv+0x130>
    mta[i] = 0;
80108b89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108b8c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b93:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108b96:	01 d0                	add    %edx,%eax
80108b98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108b9e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108ba2:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108ba6:	7e e1                	jle    80108b89 <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108ba8:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bad:	05 d0 00 00 00       	add    $0xd0,%eax
80108bb2:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108bb5:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108bb8:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108bbe:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bc3:	05 c8 00 00 00       	add    $0xc8,%eax
80108bc8:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108bcb:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108bce:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108bd4:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bd9:	05 28 28 00 00       	add    $0x2828,%eax
80108bde:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108be1:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108be4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108bea:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bef:	05 00 01 00 00       	add    $0x100,%eax
80108bf4:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108bf7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108bfa:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108c00:	e8 e3 9c ff ff       	call   801028e8 <kalloc>
80108c05:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108c08:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c0d:	05 00 28 00 00       	add    $0x2800,%eax
80108c12:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108c15:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c1a:	05 04 28 00 00       	add    $0x2804,%eax
80108c1f:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108c22:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c27:	05 08 28 00 00       	add    $0x2808,%eax
80108c2c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108c2f:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c34:	05 10 28 00 00       	add    $0x2810,%eax
80108c39:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108c3c:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c41:	05 18 28 00 00       	add    $0x2818,%eax
80108c46:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108c49:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108c4c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108c52:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108c55:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108c57:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108c5a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108c60:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108c63:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108c69:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108c6c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108c72:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108c75:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108c7b:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108c7e:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108c81:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108c88:	eb 73                	jmp    80108cfd <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108c8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c8d:	c1 e0 04             	shl    $0x4,%eax
80108c90:	89 c2                	mov    %eax,%edx
80108c92:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c95:	01 d0                	add    %edx,%eax
80108c97:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108c9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ca1:	c1 e0 04             	shl    $0x4,%eax
80108ca4:	89 c2                	mov    %eax,%edx
80108ca6:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ca9:	01 d0                	add    %edx,%eax
80108cab:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108cb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cb4:	c1 e0 04             	shl    $0x4,%eax
80108cb7:	89 c2                	mov    %eax,%edx
80108cb9:	8b 45 98             	mov    -0x68(%ebp),%eax
80108cbc:	01 d0                	add    %edx,%eax
80108cbe:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108cc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cc7:	c1 e0 04             	shl    $0x4,%eax
80108cca:	89 c2                	mov    %eax,%edx
80108ccc:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ccf:	01 d0                	add    %edx,%eax
80108cd1:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108cd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cd8:	c1 e0 04             	shl    $0x4,%eax
80108cdb:	89 c2                	mov    %eax,%edx
80108cdd:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ce0:	01 d0                	add    %edx,%eax
80108ce2:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108ce6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ce9:	c1 e0 04             	shl    $0x4,%eax
80108cec:	89 c2                	mov    %eax,%edx
80108cee:	8b 45 98             	mov    -0x68(%ebp),%eax
80108cf1:	01 d0                	add    %edx,%eax
80108cf3:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108cf9:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108cfd:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108d04:	7e 84                	jle    80108c8a <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108d06:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108d0d:	eb 57                	jmp    80108d66 <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80108d0f:	e8 d4 9b ff ff       	call   801028e8 <kalloc>
80108d14:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108d17:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108d1b:	75 12                	jne    80108d2f <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80108d1d:	83 ec 0c             	sub    $0xc,%esp
80108d20:	68 78 c6 10 80       	push   $0x8010c678
80108d25:	e8 e2 76 ff ff       	call   8010040c <cprintf>
80108d2a:	83 c4 10             	add    $0x10,%esp
      break;
80108d2d:	eb 3d                	jmp    80108d6c <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108d2f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108d32:	c1 e0 04             	shl    $0x4,%eax
80108d35:	89 c2                	mov    %eax,%edx
80108d37:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d3a:	01 d0                	add    %edx,%eax
80108d3c:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108d3f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108d45:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108d47:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108d4a:	83 c0 01             	add    $0x1,%eax
80108d4d:	c1 e0 04             	shl    $0x4,%eax
80108d50:	89 c2                	mov    %eax,%edx
80108d52:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d55:	01 d0                	add    %edx,%eax
80108d57:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108d5a:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108d60:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108d62:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108d66:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108d6a:	7e a3                	jle    80108d0f <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80108d6c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d6f:	8b 00                	mov    (%eax),%eax
80108d71:	83 c8 02             	or     $0x2,%eax
80108d74:	89 c2                	mov    %eax,%edx
80108d76:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d79:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108d7b:	83 ec 0c             	sub    $0xc,%esp
80108d7e:	68 98 c6 10 80       	push   $0x8010c698
80108d83:	e8 84 76 ff ff       	call   8010040c <cprintf>
80108d88:	83 c4 10             	add    $0x10,%esp
}
80108d8b:	90                   	nop
80108d8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108d8f:	5b                   	pop    %ebx
80108d90:	5e                   	pop    %esi
80108d91:	5f                   	pop    %edi
80108d92:	5d                   	pop    %ebp
80108d93:	c3                   	ret

80108d94 <i8254_init_send>:

void i8254_init_send(){
80108d94:	f3 0f 1e fb          	endbr32
80108d98:	55                   	push   %ebp
80108d99:	89 e5                	mov    %esp,%ebp
80108d9b:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108d9e:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108da3:	05 28 38 00 00       	add    $0x3828,%eax
80108da8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108dab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dae:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108db4:	e8 2f 9b ff ff       	call   801028e8 <kalloc>
80108db9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108dbc:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108dc1:	05 00 38 00 00       	add    $0x3800,%eax
80108dc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108dc9:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108dce:	05 04 38 00 00       	add    $0x3804,%eax
80108dd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108dd6:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ddb:	05 08 38 00 00       	add    $0x3808,%eax
80108de0:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108de3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108de6:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108dec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108def:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108df1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108df4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108dfa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108dfd:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108e03:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108e08:	05 10 38 00 00       	add    $0x3810,%eax
80108e0d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108e10:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108e15:	05 18 38 00 00       	add    $0x3818,%eax
80108e1a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108e1d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108e20:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108e26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e29:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108e2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e32:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108e35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e3c:	e9 82 00 00 00       	jmp    80108ec3 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80108e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e44:	c1 e0 04             	shl    $0x4,%eax
80108e47:	89 c2                	mov    %eax,%edx
80108e49:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e4c:	01 d0                	add    %edx,%eax
80108e4e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e58:	c1 e0 04             	shl    $0x4,%eax
80108e5b:	89 c2                	mov    %eax,%edx
80108e5d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e60:	01 d0                	add    %edx,%eax
80108e62:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e6b:	c1 e0 04             	shl    $0x4,%eax
80108e6e:	89 c2                	mov    %eax,%edx
80108e70:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e73:	01 d0                	add    %edx,%eax
80108e75:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e7c:	c1 e0 04             	shl    $0x4,%eax
80108e7f:	89 c2                	mov    %eax,%edx
80108e81:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e84:	01 d0                	add    %edx,%eax
80108e86:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e8d:	c1 e0 04             	shl    $0x4,%eax
80108e90:	89 c2                	mov    %eax,%edx
80108e92:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e95:	01 d0                	add    %edx,%eax
80108e97:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e9e:	c1 e0 04             	shl    $0x4,%eax
80108ea1:	89 c2                	mov    %eax,%edx
80108ea3:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ea6:	01 d0                	add    %edx,%eax
80108ea8:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eaf:	c1 e0 04             	shl    $0x4,%eax
80108eb2:	89 c2                	mov    %eax,%edx
80108eb4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108eb7:	01 d0                	add    %edx,%eax
80108eb9:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108ebf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108ec3:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108eca:	0f 8e 71 ff ff ff    	jle    80108e41 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108ed0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108ed7:	eb 57                	jmp    80108f30 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80108ed9:	e8 0a 9a ff ff       	call   801028e8 <kalloc>
80108ede:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108ee1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108ee5:	75 12                	jne    80108ef9 <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80108ee7:	83 ec 0c             	sub    $0xc,%esp
80108eea:	68 78 c6 10 80       	push   $0x8010c678
80108eef:	e8 18 75 ff ff       	call   8010040c <cprintf>
80108ef4:	83 c4 10             	add    $0x10,%esp
      break;
80108ef7:	eb 3d                	jmp    80108f36 <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108efc:	c1 e0 04             	shl    $0x4,%eax
80108eff:	89 c2                	mov    %eax,%edx
80108f01:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f04:	01 d0                	add    %edx,%eax
80108f06:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108f09:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108f0f:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108f11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f14:	83 c0 01             	add    $0x1,%eax
80108f17:	c1 e0 04             	shl    $0x4,%eax
80108f1a:	89 c2                	mov    %eax,%edx
80108f1c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f1f:	01 d0                	add    %edx,%eax
80108f21:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108f24:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108f2a:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108f2c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108f30:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108f34:	7e a3                	jle    80108ed9 <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108f36:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f3b:	05 00 04 00 00       	add    $0x400,%eax
80108f40:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108f43:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108f46:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108f4c:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f51:	05 10 04 00 00       	add    $0x410,%eax
80108f56:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108f59:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108f5c:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108f62:	83 ec 0c             	sub    $0xc,%esp
80108f65:	68 b8 c6 10 80       	push   $0x8010c6b8
80108f6a:	e8 9d 74 ff ff       	call   8010040c <cprintf>
80108f6f:	83 c4 10             	add    $0x10,%esp

}
80108f72:	90                   	nop
80108f73:	c9                   	leave
80108f74:	c3                   	ret

80108f75 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108f75:	f3 0f 1e fb          	endbr32
80108f79:	55                   	push   %ebp
80108f7a:	89 e5                	mov    %esp,%ebp
80108f7c:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108f7f:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f84:	83 c0 14             	add    $0x14,%eax
80108f87:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80108f8d:	c1 e0 08             	shl    $0x8,%eax
80108f90:	0f b7 c0             	movzwl %ax,%eax
80108f93:	83 c8 01             	or     $0x1,%eax
80108f96:	89 c2                	mov    %eax,%edx
80108f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f9b:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108f9d:	83 ec 0c             	sub    $0xc,%esp
80108fa0:	68 d8 c6 10 80       	push   $0x8010c6d8
80108fa5:	e8 62 74 ff ff       	call   8010040c <cprintf>
80108faa:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb0:	8b 00                	mov    (%eax),%eax
80108fb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108fb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fb8:	83 e0 10             	and    $0x10,%eax
80108fbb:	85 c0                	test   %eax,%eax
80108fbd:	75 02                	jne    80108fc1 <i8254_read_eeprom+0x4c>
  while(1){
80108fbf:	eb dc                	jmp    80108f9d <i8254_read_eeprom+0x28>
      break;
80108fc1:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fc5:	8b 00                	mov    (%eax),%eax
80108fc7:	c1 e8 10             	shr    $0x10,%eax
}
80108fca:	c9                   	leave
80108fcb:	c3                   	ret

80108fcc <i8254_recv>:
void i8254_recv(){
80108fcc:	f3 0f 1e fb          	endbr32
80108fd0:	55                   	push   %ebp
80108fd1:	89 e5                	mov    %esp,%ebp
80108fd3:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108fd6:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108fdb:	05 10 28 00 00       	add    $0x2810,%eax
80108fe0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108fe3:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108fe8:	05 18 28 00 00       	add    $0x2818,%eax
80108fed:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108ff0:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ff5:	05 00 28 00 00       	add    $0x2800,%eax
80108ffa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108ffd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109000:	8b 00                	mov    (%eax),%eax
80109002:	05 00 00 00 80       	add    $0x80000000,%eax
80109007:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
8010900a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010900d:	8b 10                	mov    (%eax),%edx
8010900f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109012:	8b 00                	mov    (%eax),%eax
80109014:	29 c2                	sub    %eax,%edx
80109016:	89 d0                	mov    %edx,%eax
80109018:	25 ff 00 00 00       	and    $0xff,%eax
8010901d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109020:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109024:	7e 37                	jle    8010905d <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109026:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109029:	8b 00                	mov    (%eax),%eax
8010902b:	c1 e0 04             	shl    $0x4,%eax
8010902e:	89 c2                	mov    %eax,%edx
80109030:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109033:	01 d0                	add    %edx,%eax
80109035:	8b 00                	mov    (%eax),%eax
80109037:	05 00 00 00 80       	add    $0x80000000,%eax
8010903c:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
8010903f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109042:	8b 00                	mov    (%eax),%eax
80109044:	83 c0 01             	add    $0x1,%eax
80109047:	0f b6 d0             	movzbl %al,%edx
8010904a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010904d:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
8010904f:	83 ec 0c             	sub    $0xc,%esp
80109052:	ff 75 e0             	push   -0x20(%ebp)
80109055:	e8 47 09 00 00       	call   801099a1 <eth_proc>
8010905a:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
8010905d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109060:	8b 10                	mov    (%eax),%edx
80109062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109065:	8b 00                	mov    (%eax),%eax
80109067:	39 c2                	cmp    %eax,%edx
80109069:	75 9f                	jne    8010900a <i8254_recv+0x3e>
      (*rdt)--;
8010906b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010906e:	8b 00                	mov    (%eax),%eax
80109070:	8d 50 ff             	lea    -0x1(%eax),%edx
80109073:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109076:	89 10                	mov    %edx,(%eax)
  while(1){
80109078:	eb 90                	jmp    8010900a <i8254_recv+0x3e>

8010907a <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
8010907a:	f3 0f 1e fb          	endbr32
8010907e:	55                   	push   %ebp
8010907f:	89 e5                	mov    %esp,%ebp
80109081:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109084:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80109089:	05 10 38 00 00       	add    $0x3810,%eax
8010908e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109091:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80109096:	05 18 38 00 00       	add    $0x3818,%eax
8010909b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010909e:	a1 b4 80 19 80       	mov    0x801980b4,%eax
801090a3:	05 00 38 00 00       	add    $0x3800,%eax
801090a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801090ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090ae:	8b 00                	mov    (%eax),%eax
801090b0:	05 00 00 00 80       	add    $0x80000000,%eax
801090b5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801090b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090bb:	8b 10                	mov    (%eax),%edx
801090bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c0:	8b 00                	mov    (%eax),%eax
801090c2:	29 c2                	sub    %eax,%edx
801090c4:	89 d0                	mov    %edx,%eax
801090c6:	0f b6 c0             	movzbl %al,%eax
801090c9:	ba 00 01 00 00       	mov    $0x100,%edx
801090ce:	29 c2                	sub    %eax,%edx
801090d0:	89 d0                	mov    %edx,%eax
801090d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801090d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090d8:	8b 00                	mov    (%eax),%eax
801090da:	25 ff 00 00 00       	and    $0xff,%eax
801090df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801090e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801090e6:	0f 8e a8 00 00 00    	jle    80109194 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
801090ec:	8b 45 08             	mov    0x8(%ebp),%eax
801090ef:	8b 55 e0             	mov    -0x20(%ebp),%edx
801090f2:	89 d1                	mov    %edx,%ecx
801090f4:	c1 e1 04             	shl    $0x4,%ecx
801090f7:	8b 55 e8             	mov    -0x18(%ebp),%edx
801090fa:	01 ca                	add    %ecx,%edx
801090fc:	8b 12                	mov    (%edx),%edx
801090fe:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109104:	83 ec 04             	sub    $0x4,%esp
80109107:	ff 75 0c             	push   0xc(%ebp)
8010910a:	50                   	push   %eax
8010910b:	52                   	push   %edx
8010910c:	e8 21 bd ff ff       	call   80104e32 <memmove>
80109111:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109114:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109117:	c1 e0 04             	shl    $0x4,%eax
8010911a:	89 c2                	mov    %eax,%edx
8010911c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010911f:	01 d0                	add    %edx,%eax
80109121:	8b 55 0c             	mov    0xc(%ebp),%edx
80109124:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109128:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010912b:	c1 e0 04             	shl    $0x4,%eax
8010912e:	89 c2                	mov    %eax,%edx
80109130:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109133:	01 d0                	add    %edx,%eax
80109135:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109139:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010913c:	c1 e0 04             	shl    $0x4,%eax
8010913f:	89 c2                	mov    %eax,%edx
80109141:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109144:	01 d0                	add    %edx,%eax
80109146:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
8010914a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010914d:	c1 e0 04             	shl    $0x4,%eax
80109150:	89 c2                	mov    %eax,%edx
80109152:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109155:	01 d0                	add    %edx,%eax
80109157:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
8010915b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010915e:	c1 e0 04             	shl    $0x4,%eax
80109161:	89 c2                	mov    %eax,%edx
80109163:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109166:	01 d0                	add    %edx,%eax
80109168:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
8010916e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109171:	c1 e0 04             	shl    $0x4,%eax
80109174:	89 c2                	mov    %eax,%edx
80109176:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109179:	01 d0                	add    %edx,%eax
8010917b:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
8010917f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109182:	8b 00                	mov    (%eax),%eax
80109184:	83 c0 01             	add    $0x1,%eax
80109187:	0f b6 d0             	movzbl %al,%edx
8010918a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010918d:	89 10                	mov    %edx,(%eax)
    return len;
8010918f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109192:	eb 05                	jmp    80109199 <i8254_send+0x11f>
  }else{
    return -1;
80109194:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109199:	c9                   	leave
8010919a:	c3                   	ret

8010919b <i8254_intr>:

void i8254_intr(){
8010919b:	f3 0f 1e fb          	endbr32
8010919f:	55                   	push   %ebp
801091a0:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801091a2:	a1 b8 80 19 80       	mov    0x801980b8,%eax
801091a7:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801091ad:	90                   	nop
801091ae:	5d                   	pop    %ebp
801091af:	c3                   	ret

801091b0 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801091b0:	f3 0f 1e fb          	endbr32
801091b4:	55                   	push   %ebp
801091b5:	89 e5                	mov    %esp,%ebp
801091b7:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801091ba:	8b 45 08             	mov    0x8(%ebp),%eax
801091bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801091c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c3:	0f b7 00             	movzwl (%eax),%eax
801091c6:	66 3d 00 01          	cmp    $0x100,%ax
801091ca:	74 0a                	je     801091d6 <arp_proc+0x26>
801091cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091d1:	e9 4f 01 00 00       	jmp    80109325 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801091d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091d9:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801091dd:	66 83 f8 08          	cmp    $0x8,%ax
801091e1:	74 0a                	je     801091ed <arp_proc+0x3d>
801091e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091e8:	e9 38 01 00 00       	jmp    80109325 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
801091ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801091f4:	3c 06                	cmp    $0x6,%al
801091f6:	74 0a                	je     80109202 <arp_proc+0x52>
801091f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091fd:	e9 23 01 00 00       	jmp    80109325 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80109202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109205:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109209:	3c 04                	cmp    $0x4,%al
8010920b:	74 0a                	je     80109217 <arp_proc+0x67>
8010920d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109212:	e9 0e 01 00 00       	jmp    80109325 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010921a:	83 c0 18             	add    $0x18,%eax
8010921d:	83 ec 04             	sub    $0x4,%esp
80109220:	6a 04                	push   $0x4
80109222:	50                   	push   %eax
80109223:	68 e4 f4 10 80       	push   $0x8010f4e4
80109228:	e8 a9 bb ff ff       	call   80104dd6 <memcmp>
8010922d:	83 c4 10             	add    $0x10,%esp
80109230:	85 c0                	test   %eax,%eax
80109232:	74 27                	je     8010925b <arp_proc+0xab>
80109234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109237:	83 c0 0e             	add    $0xe,%eax
8010923a:	83 ec 04             	sub    $0x4,%esp
8010923d:	6a 04                	push   $0x4
8010923f:	50                   	push   %eax
80109240:	68 e4 f4 10 80       	push   $0x8010f4e4
80109245:	e8 8c bb ff ff       	call   80104dd6 <memcmp>
8010924a:	83 c4 10             	add    $0x10,%esp
8010924d:	85 c0                	test   %eax,%eax
8010924f:	74 0a                	je     8010925b <arp_proc+0xab>
80109251:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109256:	e9 ca 00 00 00       	jmp    80109325 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010925b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010925e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109262:	66 3d 00 01          	cmp    $0x100,%ax
80109266:	75 69                	jne    801092d1 <arp_proc+0x121>
80109268:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010926b:	83 c0 18             	add    $0x18,%eax
8010926e:	83 ec 04             	sub    $0x4,%esp
80109271:	6a 04                	push   $0x4
80109273:	50                   	push   %eax
80109274:	68 e4 f4 10 80       	push   $0x8010f4e4
80109279:	e8 58 bb ff ff       	call   80104dd6 <memcmp>
8010927e:	83 c4 10             	add    $0x10,%esp
80109281:	85 c0                	test   %eax,%eax
80109283:	75 4c                	jne    801092d1 <arp_proc+0x121>
    uint send = (uint)kalloc();
80109285:	e8 5e 96 ff ff       	call   801028e8 <kalloc>
8010928a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
8010928d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109294:	83 ec 04             	sub    $0x4,%esp
80109297:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010929a:	50                   	push   %eax
8010929b:	ff 75 f0             	push   -0x10(%ebp)
8010929e:	ff 75 f4             	push   -0xc(%ebp)
801092a1:	e8 33 04 00 00       	call   801096d9 <arp_reply_pkt_create>
801092a6:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801092a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092ac:	83 ec 08             	sub    $0x8,%esp
801092af:	50                   	push   %eax
801092b0:	ff 75 f0             	push   -0x10(%ebp)
801092b3:	e8 c2 fd ff ff       	call   8010907a <i8254_send>
801092b8:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801092bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092be:	83 ec 0c             	sub    $0xc,%esp
801092c1:	50                   	push   %eax
801092c2:	e8 83 95 ff ff       	call   8010284a <kfree>
801092c7:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801092ca:	b8 02 00 00 00       	mov    $0x2,%eax
801092cf:	eb 54                	jmp    80109325 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801092d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801092d8:	66 3d 00 02          	cmp    $0x200,%ax
801092dc:	75 42                	jne    80109320 <arp_proc+0x170>
801092de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092e1:	83 c0 18             	add    $0x18,%eax
801092e4:	83 ec 04             	sub    $0x4,%esp
801092e7:	6a 04                	push   $0x4
801092e9:	50                   	push   %eax
801092ea:	68 e4 f4 10 80       	push   $0x8010f4e4
801092ef:	e8 e2 ba ff ff       	call   80104dd6 <memcmp>
801092f4:	83 c4 10             	add    $0x10,%esp
801092f7:	85 c0                	test   %eax,%eax
801092f9:	75 25                	jne    80109320 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
801092fb:	83 ec 0c             	sub    $0xc,%esp
801092fe:	68 dc c6 10 80       	push   $0x8010c6dc
80109303:	e8 04 71 ff ff       	call   8010040c <cprintf>
80109308:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010930b:	83 ec 0c             	sub    $0xc,%esp
8010930e:	ff 75 f4             	push   -0xc(%ebp)
80109311:	e8 b7 01 00 00       	call   801094cd <arp_table_update>
80109316:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109319:	b8 01 00 00 00       	mov    $0x1,%eax
8010931e:	eb 05                	jmp    80109325 <arp_proc+0x175>
  }else{
    return -1;
80109320:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109325:	c9                   	leave
80109326:	c3                   	ret

80109327 <arp_scan>:

void arp_scan(){
80109327:	f3 0f 1e fb          	endbr32
8010932b:	55                   	push   %ebp
8010932c:	89 e5                	mov    %esp,%ebp
8010932e:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109331:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109338:	eb 6f                	jmp    801093a9 <arp_scan+0x82>
    uint send = (uint)kalloc();
8010933a:	e8 a9 95 ff ff       	call   801028e8 <kalloc>
8010933f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109342:	83 ec 04             	sub    $0x4,%esp
80109345:	ff 75 f4             	push   -0xc(%ebp)
80109348:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010934b:	50                   	push   %eax
8010934c:	ff 75 ec             	push   -0x14(%ebp)
8010934f:	e8 62 00 00 00       	call   801093b6 <arp_broadcast>
80109354:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109357:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010935a:	83 ec 08             	sub    $0x8,%esp
8010935d:	50                   	push   %eax
8010935e:	ff 75 ec             	push   -0x14(%ebp)
80109361:	e8 14 fd ff ff       	call   8010907a <i8254_send>
80109366:	83 c4 10             	add    $0x10,%esp
80109369:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010936c:	eb 22                	jmp    80109390 <arp_scan+0x69>
      microdelay(1);
8010936e:	83 ec 0c             	sub    $0xc,%esp
80109371:	6a 01                	push   $0x1
80109373:	e8 22 99 ff ff       	call   80102c9a <microdelay>
80109378:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010937b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010937e:	83 ec 08             	sub    $0x8,%esp
80109381:	50                   	push   %eax
80109382:	ff 75 ec             	push   -0x14(%ebp)
80109385:	e8 f0 fc ff ff       	call   8010907a <i8254_send>
8010938a:	83 c4 10             	add    $0x10,%esp
8010938d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109390:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109394:	74 d8                	je     8010936e <arp_scan+0x47>
    }
    kfree((char *)send);
80109396:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109399:	83 ec 0c             	sub    $0xc,%esp
8010939c:	50                   	push   %eax
8010939d:	e8 a8 94 ff ff       	call   8010284a <kfree>
801093a2:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801093a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801093a9:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801093b0:	7e 88                	jle    8010933a <arp_scan+0x13>
  }
}
801093b2:	90                   	nop
801093b3:	90                   	nop
801093b4:	c9                   	leave
801093b5:	c3                   	ret

801093b6 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801093b6:	f3 0f 1e fb          	endbr32
801093ba:	55                   	push   %ebp
801093bb:	89 e5                	mov    %esp,%ebp
801093bd:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801093c0:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801093c4:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801093c8:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801093cc:	8b 45 10             	mov    0x10(%ebp),%eax
801093cf:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801093d2:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801093d9:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801093df:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801093e6:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801093ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801093ef:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801093f5:	8b 45 08             	mov    0x8(%ebp),%eax
801093f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801093fb:	8b 45 08             	mov    0x8(%ebp),%eax
801093fe:	83 c0 0e             	add    $0xe,%eax
80109401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109404:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109407:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010940b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010940e:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109415:	83 ec 04             	sub    $0x4,%esp
80109418:	6a 06                	push   $0x6
8010941a:	8d 55 e6             	lea    -0x1a(%ebp),%edx
8010941d:	52                   	push   %edx
8010941e:	50                   	push   %eax
8010941f:	e8 0e ba ff ff       	call   80104e32 <memmove>
80109424:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010942a:	83 c0 06             	add    $0x6,%eax
8010942d:	83 ec 04             	sub    $0x4,%esp
80109430:	6a 06                	push   $0x6
80109432:	68 68 d0 18 80       	push   $0x8018d068
80109437:	50                   	push   %eax
80109438:	e8 f5 b9 ff ff       	call   80104e32 <memmove>
8010943d:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109440:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109443:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109448:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010944b:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109451:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109454:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109458:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010945b:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
8010945f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109462:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109468:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010946b:	8d 50 12             	lea    0x12(%eax),%edx
8010946e:	83 ec 04             	sub    $0x4,%esp
80109471:	6a 06                	push   $0x6
80109473:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109476:	50                   	push   %eax
80109477:	52                   	push   %edx
80109478:	e8 b5 b9 ff ff       	call   80104e32 <memmove>
8010947d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109480:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109483:	8d 50 18             	lea    0x18(%eax),%edx
80109486:	83 ec 04             	sub    $0x4,%esp
80109489:	6a 04                	push   $0x4
8010948b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010948e:	50                   	push   %eax
8010948f:	52                   	push   %edx
80109490:	e8 9d b9 ff ff       	call   80104e32 <memmove>
80109495:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010949b:	83 c0 08             	add    $0x8,%eax
8010949e:	83 ec 04             	sub    $0x4,%esp
801094a1:	6a 06                	push   $0x6
801094a3:	68 68 d0 18 80       	push   $0x8018d068
801094a8:	50                   	push   %eax
801094a9:	e8 84 b9 ff ff       	call   80104e32 <memmove>
801094ae:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801094b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094b4:	83 c0 0e             	add    $0xe,%eax
801094b7:	83 ec 04             	sub    $0x4,%esp
801094ba:	6a 04                	push   $0x4
801094bc:	68 e4 f4 10 80       	push   $0x8010f4e4
801094c1:	50                   	push   %eax
801094c2:	e8 6b b9 ff ff       	call   80104e32 <memmove>
801094c7:	83 c4 10             	add    $0x10,%esp
}
801094ca:	90                   	nop
801094cb:	c9                   	leave
801094cc:	c3                   	ret

801094cd <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801094cd:	f3 0f 1e fb          	endbr32
801094d1:	55                   	push   %ebp
801094d2:	89 e5                	mov    %esp,%ebp
801094d4:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801094d7:	8b 45 08             	mov    0x8(%ebp),%eax
801094da:	83 c0 0e             	add    $0xe,%eax
801094dd:	83 ec 0c             	sub    $0xc,%esp
801094e0:	50                   	push   %eax
801094e1:	e8 bc 00 00 00       	call   801095a2 <arp_table_search>
801094e6:	83 c4 10             	add    $0x10,%esp
801094e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801094ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801094f0:	78 2d                	js     8010951f <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801094f2:	8b 45 08             	mov    0x8(%ebp),%eax
801094f5:	8d 48 08             	lea    0x8(%eax),%ecx
801094f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094fb:	89 d0                	mov    %edx,%eax
801094fd:	c1 e0 02             	shl    $0x2,%eax
80109500:	01 d0                	add    %edx,%eax
80109502:	01 c0                	add    %eax,%eax
80109504:	01 d0                	add    %edx,%eax
80109506:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010950b:	83 c0 04             	add    $0x4,%eax
8010950e:	83 ec 04             	sub    $0x4,%esp
80109511:	6a 06                	push   $0x6
80109513:	51                   	push   %ecx
80109514:	50                   	push   %eax
80109515:	e8 18 b9 ff ff       	call   80104e32 <memmove>
8010951a:	83 c4 10             	add    $0x10,%esp
8010951d:	eb 70                	jmp    8010958f <arp_table_update+0xc2>
  }else{
    index += 1;
8010951f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109523:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109526:	8b 45 08             	mov    0x8(%ebp),%eax
80109529:	8d 48 08             	lea    0x8(%eax),%ecx
8010952c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010952f:	89 d0                	mov    %edx,%eax
80109531:	c1 e0 02             	shl    $0x2,%eax
80109534:	01 d0                	add    %edx,%eax
80109536:	01 c0                	add    %eax,%eax
80109538:	01 d0                	add    %edx,%eax
8010953a:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010953f:	83 c0 04             	add    $0x4,%eax
80109542:	83 ec 04             	sub    $0x4,%esp
80109545:	6a 06                	push   $0x6
80109547:	51                   	push   %ecx
80109548:	50                   	push   %eax
80109549:	e8 e4 b8 ff ff       	call   80104e32 <memmove>
8010954e:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109551:	8b 45 08             	mov    0x8(%ebp),%eax
80109554:	8d 48 0e             	lea    0xe(%eax),%ecx
80109557:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010955a:	89 d0                	mov    %edx,%eax
8010955c:	c1 e0 02             	shl    $0x2,%eax
8010955f:	01 d0                	add    %edx,%eax
80109561:	01 c0                	add    %eax,%eax
80109563:	01 d0                	add    %edx,%eax
80109565:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010956a:	83 ec 04             	sub    $0x4,%esp
8010956d:	6a 04                	push   $0x4
8010956f:	51                   	push   %ecx
80109570:	50                   	push   %eax
80109571:	e8 bc b8 ff ff       	call   80104e32 <memmove>
80109576:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109579:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010957c:	89 d0                	mov    %edx,%eax
8010957e:	c1 e0 02             	shl    $0x2,%eax
80109581:	01 d0                	add    %edx,%eax
80109583:	01 c0                	add    %eax,%eax
80109585:	01 d0                	add    %edx,%eax
80109587:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010958c:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
8010958f:	83 ec 0c             	sub    $0xc,%esp
80109592:	68 80 d0 18 80       	push   $0x8018d080
80109597:	e8 87 00 00 00       	call   80109623 <print_arp_table>
8010959c:	83 c4 10             	add    $0x10,%esp
}
8010959f:	90                   	nop
801095a0:	c9                   	leave
801095a1:	c3                   	ret

801095a2 <arp_table_search>:

int arp_table_search(uchar *ip){
801095a2:	f3 0f 1e fb          	endbr32
801095a6:	55                   	push   %ebp
801095a7:	89 e5                	mov    %esp,%ebp
801095a9:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801095ac:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801095b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801095ba:	eb 59                	jmp    80109615 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801095bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095bf:	89 d0                	mov    %edx,%eax
801095c1:	c1 e0 02             	shl    $0x2,%eax
801095c4:	01 d0                	add    %edx,%eax
801095c6:	01 c0                	add    %eax,%eax
801095c8:	01 d0                	add    %edx,%eax
801095ca:	05 80 d0 18 80       	add    $0x8018d080,%eax
801095cf:	83 ec 04             	sub    $0x4,%esp
801095d2:	6a 04                	push   $0x4
801095d4:	ff 75 08             	push   0x8(%ebp)
801095d7:	50                   	push   %eax
801095d8:	e8 f9 b7 ff ff       	call   80104dd6 <memcmp>
801095dd:	83 c4 10             	add    $0x10,%esp
801095e0:	85 c0                	test   %eax,%eax
801095e2:	75 05                	jne    801095e9 <arp_table_search+0x47>
      return i;
801095e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095e7:	eb 38                	jmp    80109621 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
801095e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095ec:	89 d0                	mov    %edx,%eax
801095ee:	c1 e0 02             	shl    $0x2,%eax
801095f1:	01 d0                	add    %edx,%eax
801095f3:	01 c0                	add    %eax,%eax
801095f5:	01 d0                	add    %edx,%eax
801095f7:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801095fc:	0f b6 00             	movzbl (%eax),%eax
801095ff:	84 c0                	test   %al,%al
80109601:	75 0e                	jne    80109611 <arp_table_search+0x6f>
80109603:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109607:	75 08                	jne    80109611 <arp_table_search+0x6f>
      empty = -i;
80109609:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010960c:	f7 d8                	neg    %eax
8010960e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109611:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109615:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109619:	7e a1                	jle    801095bc <arp_table_search+0x1a>
    }
  }
  return empty-1;
8010961b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010961e:	83 e8 01             	sub    $0x1,%eax
}
80109621:	c9                   	leave
80109622:	c3                   	ret

80109623 <print_arp_table>:

void print_arp_table(){
80109623:	f3 0f 1e fb          	endbr32
80109627:	55                   	push   %ebp
80109628:	89 e5                	mov    %esp,%ebp
8010962a:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010962d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109634:	e9 92 00 00 00       	jmp    801096cb <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
80109639:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010963c:	89 d0                	mov    %edx,%eax
8010963e:	c1 e0 02             	shl    $0x2,%eax
80109641:	01 d0                	add    %edx,%eax
80109643:	01 c0                	add    %eax,%eax
80109645:	01 d0                	add    %edx,%eax
80109647:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010964c:	0f b6 00             	movzbl (%eax),%eax
8010964f:	84 c0                	test   %al,%al
80109651:	74 74                	je     801096c7 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109653:	83 ec 08             	sub    $0x8,%esp
80109656:	ff 75 f4             	push   -0xc(%ebp)
80109659:	68 ef c6 10 80       	push   $0x8010c6ef
8010965e:	e8 a9 6d ff ff       	call   8010040c <cprintf>
80109663:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109666:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109669:	89 d0                	mov    %edx,%eax
8010966b:	c1 e0 02             	shl    $0x2,%eax
8010966e:	01 d0                	add    %edx,%eax
80109670:	01 c0                	add    %eax,%eax
80109672:	01 d0                	add    %edx,%eax
80109674:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109679:	83 ec 0c             	sub    $0xc,%esp
8010967c:	50                   	push   %eax
8010967d:	e8 5c 02 00 00       	call   801098de <print_ipv4>
80109682:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109685:	83 ec 0c             	sub    $0xc,%esp
80109688:	68 fe c6 10 80       	push   $0x8010c6fe
8010968d:	e8 7a 6d ff ff       	call   8010040c <cprintf>
80109692:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109695:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109698:	89 d0                	mov    %edx,%eax
8010969a:	c1 e0 02             	shl    $0x2,%eax
8010969d:	01 d0                	add    %edx,%eax
8010969f:	01 c0                	add    %eax,%eax
801096a1:	01 d0                	add    %edx,%eax
801096a3:	05 80 d0 18 80       	add    $0x8018d080,%eax
801096a8:	83 c0 04             	add    $0x4,%eax
801096ab:	83 ec 0c             	sub    $0xc,%esp
801096ae:	50                   	push   %eax
801096af:	e8 7c 02 00 00       	call   80109930 <print_mac>
801096b4:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801096b7:	83 ec 0c             	sub    $0xc,%esp
801096ba:	68 00 c7 10 80       	push   $0x8010c700
801096bf:	e8 48 6d ff ff       	call   8010040c <cprintf>
801096c4:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801096c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801096cb:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801096cf:	0f 8e 64 ff ff ff    	jle    80109639 <print_arp_table+0x16>
    }
  }
}
801096d5:	90                   	nop
801096d6:	90                   	nop
801096d7:	c9                   	leave
801096d8:	c3                   	ret

801096d9 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801096d9:	f3 0f 1e fb          	endbr32
801096dd:	55                   	push   %ebp
801096de:	89 e5                	mov    %esp,%ebp
801096e0:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801096e3:	8b 45 10             	mov    0x10(%ebp),%eax
801096e6:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801096ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801096ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801096f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801096f5:	83 c0 0e             	add    $0xe,%eax
801096f8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801096fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096fe:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109705:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109709:	8b 45 08             	mov    0x8(%ebp),%eax
8010970c:	8d 50 08             	lea    0x8(%eax),%edx
8010970f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109712:	83 ec 04             	sub    $0x4,%esp
80109715:	6a 06                	push   $0x6
80109717:	52                   	push   %edx
80109718:	50                   	push   %eax
80109719:	e8 14 b7 ff ff       	call   80104e32 <memmove>
8010971e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109721:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109724:	83 c0 06             	add    $0x6,%eax
80109727:	83 ec 04             	sub    $0x4,%esp
8010972a:	6a 06                	push   $0x6
8010972c:	68 68 d0 18 80       	push   $0x8018d068
80109731:	50                   	push   %eax
80109732:	e8 fb b6 ff ff       	call   80104e32 <memmove>
80109737:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010973a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010973d:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109742:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109745:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010974b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010974e:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109752:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109755:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109759:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010975c:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109762:	8b 45 08             	mov    0x8(%ebp),%eax
80109765:	8d 50 08             	lea    0x8(%eax),%edx
80109768:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010976b:	83 c0 12             	add    $0x12,%eax
8010976e:	83 ec 04             	sub    $0x4,%esp
80109771:	6a 06                	push   $0x6
80109773:	52                   	push   %edx
80109774:	50                   	push   %eax
80109775:	e8 b8 b6 ff ff       	call   80104e32 <memmove>
8010977a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
8010977d:	8b 45 08             	mov    0x8(%ebp),%eax
80109780:	8d 50 0e             	lea    0xe(%eax),%edx
80109783:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109786:	83 c0 18             	add    $0x18,%eax
80109789:	83 ec 04             	sub    $0x4,%esp
8010978c:	6a 04                	push   $0x4
8010978e:	52                   	push   %edx
8010978f:	50                   	push   %eax
80109790:	e8 9d b6 ff ff       	call   80104e32 <memmove>
80109795:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109798:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010979b:	83 c0 08             	add    $0x8,%eax
8010979e:	83 ec 04             	sub    $0x4,%esp
801097a1:	6a 06                	push   $0x6
801097a3:	68 68 d0 18 80       	push   $0x8018d068
801097a8:	50                   	push   %eax
801097a9:	e8 84 b6 ff ff       	call   80104e32 <memmove>
801097ae:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801097b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097b4:	83 c0 0e             	add    $0xe,%eax
801097b7:	83 ec 04             	sub    $0x4,%esp
801097ba:	6a 04                	push   $0x4
801097bc:	68 e4 f4 10 80       	push   $0x8010f4e4
801097c1:	50                   	push   %eax
801097c2:	e8 6b b6 ff ff       	call   80104e32 <memmove>
801097c7:	83 c4 10             	add    $0x10,%esp
}
801097ca:	90                   	nop
801097cb:	c9                   	leave
801097cc:	c3                   	ret

801097cd <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801097cd:	f3 0f 1e fb          	endbr32
801097d1:	55                   	push   %ebp
801097d2:	89 e5                	mov    %esp,%ebp
801097d4:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801097d7:	83 ec 0c             	sub    $0xc,%esp
801097da:	68 02 c7 10 80       	push   $0x8010c702
801097df:	e8 28 6c ff ff       	call   8010040c <cprintf>
801097e4:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801097e7:	8b 45 08             	mov    0x8(%ebp),%eax
801097ea:	83 c0 0e             	add    $0xe,%eax
801097ed:	83 ec 0c             	sub    $0xc,%esp
801097f0:	50                   	push   %eax
801097f1:	e8 e8 00 00 00       	call   801098de <print_ipv4>
801097f6:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801097f9:	83 ec 0c             	sub    $0xc,%esp
801097fc:	68 00 c7 10 80       	push   $0x8010c700
80109801:	e8 06 6c ff ff       	call   8010040c <cprintf>
80109806:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109809:	8b 45 08             	mov    0x8(%ebp),%eax
8010980c:	83 c0 08             	add    $0x8,%eax
8010980f:	83 ec 0c             	sub    $0xc,%esp
80109812:	50                   	push   %eax
80109813:	e8 18 01 00 00       	call   80109930 <print_mac>
80109818:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010981b:	83 ec 0c             	sub    $0xc,%esp
8010981e:	68 00 c7 10 80       	push   $0x8010c700
80109823:	e8 e4 6b ff ff       	call   8010040c <cprintf>
80109828:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010982b:	83 ec 0c             	sub    $0xc,%esp
8010982e:	68 19 c7 10 80       	push   $0x8010c719
80109833:	e8 d4 6b ff ff       	call   8010040c <cprintf>
80109838:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010983b:	8b 45 08             	mov    0x8(%ebp),%eax
8010983e:	83 c0 18             	add    $0x18,%eax
80109841:	83 ec 0c             	sub    $0xc,%esp
80109844:	50                   	push   %eax
80109845:	e8 94 00 00 00       	call   801098de <print_ipv4>
8010984a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010984d:	83 ec 0c             	sub    $0xc,%esp
80109850:	68 00 c7 10 80       	push   $0x8010c700
80109855:	e8 b2 6b ff ff       	call   8010040c <cprintf>
8010985a:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010985d:	8b 45 08             	mov    0x8(%ebp),%eax
80109860:	83 c0 12             	add    $0x12,%eax
80109863:	83 ec 0c             	sub    $0xc,%esp
80109866:	50                   	push   %eax
80109867:	e8 c4 00 00 00       	call   80109930 <print_mac>
8010986c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010986f:	83 ec 0c             	sub    $0xc,%esp
80109872:	68 00 c7 10 80       	push   $0x8010c700
80109877:	e8 90 6b ff ff       	call   8010040c <cprintf>
8010987c:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010987f:	83 ec 0c             	sub    $0xc,%esp
80109882:	68 30 c7 10 80       	push   $0x8010c730
80109887:	e8 80 6b ff ff       	call   8010040c <cprintf>
8010988c:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010988f:	8b 45 08             	mov    0x8(%ebp),%eax
80109892:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109896:	66 3d 00 01          	cmp    $0x100,%ax
8010989a:	75 12                	jne    801098ae <print_arp_info+0xe1>
8010989c:	83 ec 0c             	sub    $0xc,%esp
8010989f:	68 3c c7 10 80       	push   $0x8010c73c
801098a4:	e8 63 6b ff ff       	call   8010040c <cprintf>
801098a9:	83 c4 10             	add    $0x10,%esp
801098ac:	eb 1d                	jmp    801098cb <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
801098ae:	8b 45 08             	mov    0x8(%ebp),%eax
801098b1:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801098b5:	66 3d 00 02          	cmp    $0x200,%ax
801098b9:	75 10                	jne    801098cb <print_arp_info+0xfe>
    cprintf("Reply\n");
801098bb:	83 ec 0c             	sub    $0xc,%esp
801098be:	68 45 c7 10 80       	push   $0x8010c745
801098c3:	e8 44 6b ff ff       	call   8010040c <cprintf>
801098c8:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801098cb:	83 ec 0c             	sub    $0xc,%esp
801098ce:	68 00 c7 10 80       	push   $0x8010c700
801098d3:	e8 34 6b ff ff       	call   8010040c <cprintf>
801098d8:	83 c4 10             	add    $0x10,%esp
}
801098db:	90                   	nop
801098dc:	c9                   	leave
801098dd:	c3                   	ret

801098de <print_ipv4>:

void print_ipv4(uchar *ip){
801098de:	f3 0f 1e fb          	endbr32
801098e2:	55                   	push   %ebp
801098e3:	89 e5                	mov    %esp,%ebp
801098e5:	53                   	push   %ebx
801098e6:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801098e9:	8b 45 08             	mov    0x8(%ebp),%eax
801098ec:	83 c0 03             	add    $0x3,%eax
801098ef:	0f b6 00             	movzbl (%eax),%eax
801098f2:	0f b6 d8             	movzbl %al,%ebx
801098f5:	8b 45 08             	mov    0x8(%ebp),%eax
801098f8:	83 c0 02             	add    $0x2,%eax
801098fb:	0f b6 00             	movzbl (%eax),%eax
801098fe:	0f b6 c8             	movzbl %al,%ecx
80109901:	8b 45 08             	mov    0x8(%ebp),%eax
80109904:	83 c0 01             	add    $0x1,%eax
80109907:	0f b6 00             	movzbl (%eax),%eax
8010990a:	0f b6 d0             	movzbl %al,%edx
8010990d:	8b 45 08             	mov    0x8(%ebp),%eax
80109910:	0f b6 00             	movzbl (%eax),%eax
80109913:	0f b6 c0             	movzbl %al,%eax
80109916:	83 ec 0c             	sub    $0xc,%esp
80109919:	53                   	push   %ebx
8010991a:	51                   	push   %ecx
8010991b:	52                   	push   %edx
8010991c:	50                   	push   %eax
8010991d:	68 4c c7 10 80       	push   $0x8010c74c
80109922:	e8 e5 6a ff ff       	call   8010040c <cprintf>
80109927:	83 c4 20             	add    $0x20,%esp
}
8010992a:	90                   	nop
8010992b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010992e:	c9                   	leave
8010992f:	c3                   	ret

80109930 <print_mac>:

void print_mac(uchar *mac){
80109930:	f3 0f 1e fb          	endbr32
80109934:	55                   	push   %ebp
80109935:	89 e5                	mov    %esp,%ebp
80109937:	57                   	push   %edi
80109938:	56                   	push   %esi
80109939:	53                   	push   %ebx
8010993a:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010993d:	8b 45 08             	mov    0x8(%ebp),%eax
80109940:	83 c0 05             	add    $0x5,%eax
80109943:	0f b6 00             	movzbl (%eax),%eax
80109946:	0f b6 f8             	movzbl %al,%edi
80109949:	8b 45 08             	mov    0x8(%ebp),%eax
8010994c:	83 c0 04             	add    $0x4,%eax
8010994f:	0f b6 00             	movzbl (%eax),%eax
80109952:	0f b6 f0             	movzbl %al,%esi
80109955:	8b 45 08             	mov    0x8(%ebp),%eax
80109958:	83 c0 03             	add    $0x3,%eax
8010995b:	0f b6 00             	movzbl (%eax),%eax
8010995e:	0f b6 d8             	movzbl %al,%ebx
80109961:	8b 45 08             	mov    0x8(%ebp),%eax
80109964:	83 c0 02             	add    $0x2,%eax
80109967:	0f b6 00             	movzbl (%eax),%eax
8010996a:	0f b6 c8             	movzbl %al,%ecx
8010996d:	8b 45 08             	mov    0x8(%ebp),%eax
80109970:	83 c0 01             	add    $0x1,%eax
80109973:	0f b6 00             	movzbl (%eax),%eax
80109976:	0f b6 d0             	movzbl %al,%edx
80109979:	8b 45 08             	mov    0x8(%ebp),%eax
8010997c:	0f b6 00             	movzbl (%eax),%eax
8010997f:	0f b6 c0             	movzbl %al,%eax
80109982:	83 ec 04             	sub    $0x4,%esp
80109985:	57                   	push   %edi
80109986:	56                   	push   %esi
80109987:	53                   	push   %ebx
80109988:	51                   	push   %ecx
80109989:	52                   	push   %edx
8010998a:	50                   	push   %eax
8010998b:	68 64 c7 10 80       	push   $0x8010c764
80109990:	e8 77 6a ff ff       	call   8010040c <cprintf>
80109995:	83 c4 20             	add    $0x20,%esp
}
80109998:	90                   	nop
80109999:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010999c:	5b                   	pop    %ebx
8010999d:	5e                   	pop    %esi
8010999e:	5f                   	pop    %edi
8010999f:	5d                   	pop    %ebp
801099a0:	c3                   	ret

801099a1 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
801099a1:	f3 0f 1e fb          	endbr32
801099a5:	55                   	push   %ebp
801099a6:	89 e5                	mov    %esp,%ebp
801099a8:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801099ab:	8b 45 08             	mov    0x8(%ebp),%eax
801099ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801099b1:	8b 45 08             	mov    0x8(%ebp),%eax
801099b4:	83 c0 0e             	add    $0xe,%eax
801099b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801099ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099bd:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801099c1:	3c 08                	cmp    $0x8,%al
801099c3:	75 1b                	jne    801099e0 <eth_proc+0x3f>
801099c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099c8:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801099cc:	3c 06                	cmp    $0x6,%al
801099ce:	75 10                	jne    801099e0 <eth_proc+0x3f>
    arp_proc(pkt_addr);
801099d0:	83 ec 0c             	sub    $0xc,%esp
801099d3:	ff 75 f0             	push   -0x10(%ebp)
801099d6:	e8 d5 f7 ff ff       	call   801091b0 <arp_proc>
801099db:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801099de:	eb 24                	jmp    80109a04 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801099e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099e3:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801099e7:	3c 08                	cmp    $0x8,%al
801099e9:	75 19                	jne    80109a04 <eth_proc+0x63>
801099eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099ee:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801099f2:	84 c0                	test   %al,%al
801099f4:	75 0e                	jne    80109a04 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
801099f6:	83 ec 0c             	sub    $0xc,%esp
801099f9:	ff 75 08             	push   0x8(%ebp)
801099fc:	e8 b3 00 00 00       	call   80109ab4 <ipv4_proc>
80109a01:	83 c4 10             	add    $0x10,%esp
}
80109a04:	90                   	nop
80109a05:	c9                   	leave
80109a06:	c3                   	ret

80109a07 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109a07:	f3 0f 1e fb          	endbr32
80109a0b:	55                   	push   %ebp
80109a0c:	89 e5                	mov    %esp,%ebp
80109a0e:	83 ec 04             	sub    $0x4,%esp
80109a11:	8b 45 08             	mov    0x8(%ebp),%eax
80109a14:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109a18:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a1c:	c1 e0 08             	shl    $0x8,%eax
80109a1f:	89 c2                	mov    %eax,%edx
80109a21:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a25:	66 c1 e8 08          	shr    $0x8,%ax
80109a29:	01 d0                	add    %edx,%eax
}
80109a2b:	c9                   	leave
80109a2c:	c3                   	ret

80109a2d <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109a2d:	f3 0f 1e fb          	endbr32
80109a31:	55                   	push   %ebp
80109a32:	89 e5                	mov    %esp,%ebp
80109a34:	83 ec 04             	sub    $0x4,%esp
80109a37:	8b 45 08             	mov    0x8(%ebp),%eax
80109a3a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109a3e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a42:	c1 e0 08             	shl    $0x8,%eax
80109a45:	89 c2                	mov    %eax,%edx
80109a47:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a4b:	66 c1 e8 08          	shr    $0x8,%ax
80109a4f:	01 d0                	add    %edx,%eax
}
80109a51:	c9                   	leave
80109a52:	c3                   	ret

80109a53 <H2N_uint>:

uint H2N_uint(uint value){
80109a53:	f3 0f 1e fb          	endbr32
80109a57:	55                   	push   %ebp
80109a58:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80109a5d:	c1 e0 18             	shl    $0x18,%eax
80109a60:	25 00 00 00 0f       	and    $0xf000000,%eax
80109a65:	89 c2                	mov    %eax,%edx
80109a67:	8b 45 08             	mov    0x8(%ebp),%eax
80109a6a:	c1 e0 08             	shl    $0x8,%eax
80109a6d:	25 00 f0 00 00       	and    $0xf000,%eax
80109a72:	09 c2                	or     %eax,%edx
80109a74:	8b 45 08             	mov    0x8(%ebp),%eax
80109a77:	c1 e8 08             	shr    $0x8,%eax
80109a7a:	83 e0 0f             	and    $0xf,%eax
80109a7d:	01 d0                	add    %edx,%eax
}
80109a7f:	5d                   	pop    %ebp
80109a80:	c3                   	ret

80109a81 <N2H_uint>:

uint N2H_uint(uint value){
80109a81:	f3 0f 1e fb          	endbr32
80109a85:	55                   	push   %ebp
80109a86:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109a88:	8b 45 08             	mov    0x8(%ebp),%eax
80109a8b:	c1 e0 18             	shl    $0x18,%eax
80109a8e:	89 c2                	mov    %eax,%edx
80109a90:	8b 45 08             	mov    0x8(%ebp),%eax
80109a93:	c1 e0 08             	shl    $0x8,%eax
80109a96:	25 00 00 ff 00       	and    $0xff0000,%eax
80109a9b:	01 c2                	add    %eax,%edx
80109a9d:	8b 45 08             	mov    0x8(%ebp),%eax
80109aa0:	c1 e8 08             	shr    $0x8,%eax
80109aa3:	25 00 ff 00 00       	and    $0xff00,%eax
80109aa8:	01 c2                	add    %eax,%edx
80109aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80109aad:	c1 e8 18             	shr    $0x18,%eax
80109ab0:	01 d0                	add    %edx,%eax
}
80109ab2:	5d                   	pop    %ebp
80109ab3:	c3                   	ret

80109ab4 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109ab4:	f3 0f 1e fb          	endbr32
80109ab8:	55                   	push   %ebp
80109ab9:	89 e5                	mov    %esp,%ebp
80109abb:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109abe:	8b 45 08             	mov    0x8(%ebp),%eax
80109ac1:	83 c0 0e             	add    $0xe,%eax
80109ac4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aca:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109ace:	0f b7 d0             	movzwl %ax,%edx
80109ad1:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109ad6:	39 c2                	cmp    %eax,%edx
80109ad8:	74 60                	je     80109b3a <ipv4_proc+0x86>
80109ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109add:	83 c0 0c             	add    $0xc,%eax
80109ae0:	83 ec 04             	sub    $0x4,%esp
80109ae3:	6a 04                	push   $0x4
80109ae5:	50                   	push   %eax
80109ae6:	68 e4 f4 10 80       	push   $0x8010f4e4
80109aeb:	e8 e6 b2 ff ff       	call   80104dd6 <memcmp>
80109af0:	83 c4 10             	add    $0x10,%esp
80109af3:	85 c0                	test   %eax,%eax
80109af5:	74 43                	je     80109b3a <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
80109af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109afa:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109afe:	0f b7 c0             	movzwl %ax,%eax
80109b01:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b09:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109b0d:	3c 01                	cmp    $0x1,%al
80109b0f:	75 10                	jne    80109b21 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109b11:	83 ec 0c             	sub    $0xc,%esp
80109b14:	ff 75 08             	push   0x8(%ebp)
80109b17:	e8 a7 00 00 00       	call   80109bc3 <icmp_proc>
80109b1c:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109b1f:	eb 19                	jmp    80109b3a <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b24:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109b28:	3c 06                	cmp    $0x6,%al
80109b2a:	75 0e                	jne    80109b3a <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
80109b2c:	83 ec 0c             	sub    $0xc,%esp
80109b2f:	ff 75 08             	push   0x8(%ebp)
80109b32:	e8 c7 03 00 00       	call   80109efe <tcp_proc>
80109b37:	83 c4 10             	add    $0x10,%esp
}
80109b3a:	90                   	nop
80109b3b:	c9                   	leave
80109b3c:	c3                   	ret

80109b3d <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109b3d:	f3 0f 1e fb          	endbr32
80109b41:	55                   	push   %ebp
80109b42:	89 e5                	mov    %esp,%ebp
80109b44:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109b47:	8b 45 08             	mov    0x8(%ebp),%eax
80109b4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b50:	0f b6 00             	movzbl (%eax),%eax
80109b53:	83 e0 0f             	and    $0xf,%eax
80109b56:	01 c0                	add    %eax,%eax
80109b58:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109b5b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109b62:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109b69:	eb 48                	jmp    80109bb3 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109b6b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b6e:	01 c0                	add    %eax,%eax
80109b70:	89 c2                	mov    %eax,%edx
80109b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b75:	01 d0                	add    %edx,%eax
80109b77:	0f b6 00             	movzbl (%eax),%eax
80109b7a:	0f b6 c0             	movzbl %al,%eax
80109b7d:	c1 e0 08             	shl    $0x8,%eax
80109b80:	89 c2                	mov    %eax,%edx
80109b82:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b85:	01 c0                	add    %eax,%eax
80109b87:	8d 48 01             	lea    0x1(%eax),%ecx
80109b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b8d:	01 c8                	add    %ecx,%eax
80109b8f:	0f b6 00             	movzbl (%eax),%eax
80109b92:	0f b6 c0             	movzbl %al,%eax
80109b95:	01 d0                	add    %edx,%eax
80109b97:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109b9a:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109ba1:	76 0c                	jbe    80109baf <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
80109ba3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ba6:	0f b7 c0             	movzwl %ax,%eax
80109ba9:	83 c0 01             	add    $0x1,%eax
80109bac:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109baf:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109bb3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109bb7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109bba:	7c af                	jl     80109b6b <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
80109bbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109bbf:	f7 d0                	not    %eax
}
80109bc1:	c9                   	leave
80109bc2:	c3                   	ret

80109bc3 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109bc3:	f3 0f 1e fb          	endbr32
80109bc7:	55                   	push   %ebp
80109bc8:	89 e5                	mov    %esp,%ebp
80109bca:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80109bd0:	83 c0 0e             	add    $0xe,%eax
80109bd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bd9:	0f b6 00             	movzbl (%eax),%eax
80109bdc:	0f b6 c0             	movzbl %al,%eax
80109bdf:	83 e0 0f             	and    $0xf,%eax
80109be2:	c1 e0 02             	shl    $0x2,%eax
80109be5:	89 c2                	mov    %eax,%edx
80109be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bea:	01 d0                	add    %edx,%eax
80109bec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109bef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bf2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109bf6:	84 c0                	test   %al,%al
80109bf8:	75 4f                	jne    80109c49 <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bfd:	0f b6 00             	movzbl (%eax),%eax
80109c00:	3c 08                	cmp    $0x8,%al
80109c02:	75 45                	jne    80109c49 <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109c04:	e8 df 8c ff ff       	call   801028e8 <kalloc>
80109c09:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109c0c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109c13:	83 ec 04             	sub    $0x4,%esp
80109c16:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109c19:	50                   	push   %eax
80109c1a:	ff 75 ec             	push   -0x14(%ebp)
80109c1d:	ff 75 08             	push   0x8(%ebp)
80109c20:	e8 7c 00 00 00       	call   80109ca1 <icmp_reply_pkt_create>
80109c25:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109c28:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c2b:	83 ec 08             	sub    $0x8,%esp
80109c2e:	50                   	push   %eax
80109c2f:	ff 75 ec             	push   -0x14(%ebp)
80109c32:	e8 43 f4 ff ff       	call   8010907a <i8254_send>
80109c37:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109c3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c3d:	83 ec 0c             	sub    $0xc,%esp
80109c40:	50                   	push   %eax
80109c41:	e8 04 8c ff ff       	call   8010284a <kfree>
80109c46:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109c49:	90                   	nop
80109c4a:	c9                   	leave
80109c4b:	c3                   	ret

80109c4c <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109c4c:	f3 0f 1e fb          	endbr32
80109c50:	55                   	push   %ebp
80109c51:	89 e5                	mov    %esp,%ebp
80109c53:	53                   	push   %ebx
80109c54:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109c57:	8b 45 08             	mov    0x8(%ebp),%eax
80109c5a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109c5e:	0f b7 c0             	movzwl %ax,%eax
80109c61:	83 ec 0c             	sub    $0xc,%esp
80109c64:	50                   	push   %eax
80109c65:	e8 9d fd ff ff       	call   80109a07 <N2H_ushort>
80109c6a:	83 c4 10             	add    $0x10,%esp
80109c6d:	0f b7 d8             	movzwl %ax,%ebx
80109c70:	8b 45 08             	mov    0x8(%ebp),%eax
80109c73:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109c77:	0f b7 c0             	movzwl %ax,%eax
80109c7a:	83 ec 0c             	sub    $0xc,%esp
80109c7d:	50                   	push   %eax
80109c7e:	e8 84 fd ff ff       	call   80109a07 <N2H_ushort>
80109c83:	83 c4 10             	add    $0x10,%esp
80109c86:	0f b7 c0             	movzwl %ax,%eax
80109c89:	83 ec 04             	sub    $0x4,%esp
80109c8c:	53                   	push   %ebx
80109c8d:	50                   	push   %eax
80109c8e:	68 83 c7 10 80       	push   $0x8010c783
80109c93:	e8 74 67 ff ff       	call   8010040c <cprintf>
80109c98:	83 c4 10             	add    $0x10,%esp
}
80109c9b:	90                   	nop
80109c9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109c9f:	c9                   	leave
80109ca0:	c3                   	ret

80109ca1 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109ca1:	f3 0f 1e fb          	endbr32
80109ca5:	55                   	push   %ebp
80109ca6:	89 e5                	mov    %esp,%ebp
80109ca8:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109cab:	8b 45 08             	mov    0x8(%ebp),%eax
80109cae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109cb1:	8b 45 08             	mov    0x8(%ebp),%eax
80109cb4:	83 c0 0e             	add    $0xe,%eax
80109cb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109cba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cbd:	0f b6 00             	movzbl (%eax),%eax
80109cc0:	0f b6 c0             	movzbl %al,%eax
80109cc3:	83 e0 0f             	and    $0xf,%eax
80109cc6:	c1 e0 02             	shl    $0x2,%eax
80109cc9:	89 c2                	mov    %eax,%edx
80109ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cce:	01 d0                	add    %edx,%eax
80109cd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109cd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cd6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cdc:	83 c0 0e             	add    $0xe,%eax
80109cdf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109ce2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ce5:	83 c0 14             	add    $0x14,%eax
80109ce8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109ceb:	8b 45 10             	mov    0x10(%ebp),%eax
80109cee:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cf7:	8d 50 06             	lea    0x6(%eax),%edx
80109cfa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cfd:	83 ec 04             	sub    $0x4,%esp
80109d00:	6a 06                	push   $0x6
80109d02:	52                   	push   %edx
80109d03:	50                   	push   %eax
80109d04:	e8 29 b1 ff ff       	call   80104e32 <memmove>
80109d09:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109d0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d0f:	83 c0 06             	add    $0x6,%eax
80109d12:	83 ec 04             	sub    $0x4,%esp
80109d15:	6a 06                	push   $0x6
80109d17:	68 68 d0 18 80       	push   $0x8018d068
80109d1c:	50                   	push   %eax
80109d1d:	e8 10 b1 ff ff       	call   80104e32 <memmove>
80109d22:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109d25:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d28:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109d2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d2f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109d33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d36:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109d39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d3c:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109d40:	83 ec 0c             	sub    $0xc,%esp
80109d43:	6a 54                	push   $0x54
80109d45:	e8 e3 fc ff ff       	call   80109a2d <H2N_ushort>
80109d4a:	83 c4 10             	add    $0x10,%esp
80109d4d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d50:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109d54:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109d5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d5e:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109d62:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109d69:	83 c0 01             	add    $0x1,%eax
80109d6c:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
80109d72:	83 ec 0c             	sub    $0xc,%esp
80109d75:	68 00 40 00 00       	push   $0x4000
80109d7a:	e8 ae fc ff ff       	call   80109a2d <H2N_ushort>
80109d7f:	83 c4 10             	add    $0x10,%esp
80109d82:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d85:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109d89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d8c:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109d90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d93:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109d97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d9a:	83 c0 0c             	add    $0xc,%eax
80109d9d:	83 ec 04             	sub    $0x4,%esp
80109da0:	6a 04                	push   $0x4
80109da2:	68 e4 f4 10 80       	push   $0x8010f4e4
80109da7:	50                   	push   %eax
80109da8:	e8 85 b0 ff ff       	call   80104e32 <memmove>
80109dad:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109db0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109db3:	8d 50 0c             	lea    0xc(%eax),%edx
80109db6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109db9:	83 c0 10             	add    $0x10,%eax
80109dbc:	83 ec 04             	sub    $0x4,%esp
80109dbf:	6a 04                	push   $0x4
80109dc1:	52                   	push   %edx
80109dc2:	50                   	push   %eax
80109dc3:	e8 6a b0 ff ff       	call   80104e32 <memmove>
80109dc8:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109dcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dce:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109dd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dd7:	83 ec 0c             	sub    $0xc,%esp
80109dda:	50                   	push   %eax
80109ddb:	e8 5d fd ff ff       	call   80109b3d <ipv4_chksum>
80109de0:	83 c4 10             	add    $0x10,%esp
80109de3:	0f b7 c0             	movzwl %ax,%eax
80109de6:	83 ec 0c             	sub    $0xc,%esp
80109de9:	50                   	push   %eax
80109dea:	e8 3e fc ff ff       	call   80109a2d <H2N_ushort>
80109def:	83 c4 10             	add    $0x10,%esp
80109df2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109df5:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109df9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dfc:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109dff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e02:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109e06:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e09:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109e0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e10:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109e14:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e17:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109e1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e1e:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109e22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e25:	8d 50 08             	lea    0x8(%eax),%edx
80109e28:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e2b:	83 c0 08             	add    $0x8,%eax
80109e2e:	83 ec 04             	sub    $0x4,%esp
80109e31:	6a 08                	push   $0x8
80109e33:	52                   	push   %edx
80109e34:	50                   	push   %eax
80109e35:	e8 f8 af ff ff       	call   80104e32 <memmove>
80109e3a:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109e3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e40:	8d 50 10             	lea    0x10(%eax),%edx
80109e43:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e46:	83 c0 10             	add    $0x10,%eax
80109e49:	83 ec 04             	sub    $0x4,%esp
80109e4c:	6a 30                	push   $0x30
80109e4e:	52                   	push   %edx
80109e4f:	50                   	push   %eax
80109e50:	e8 dd af ff ff       	call   80104e32 <memmove>
80109e55:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109e58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e5b:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109e61:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e64:	83 ec 0c             	sub    $0xc,%esp
80109e67:	50                   	push   %eax
80109e68:	e8 1c 00 00 00       	call   80109e89 <icmp_chksum>
80109e6d:	83 c4 10             	add    $0x10,%esp
80109e70:	0f b7 c0             	movzwl %ax,%eax
80109e73:	83 ec 0c             	sub    $0xc,%esp
80109e76:	50                   	push   %eax
80109e77:	e8 b1 fb ff ff       	call   80109a2d <H2N_ushort>
80109e7c:	83 c4 10             	add    $0x10,%esp
80109e7f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109e82:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109e86:	90                   	nop
80109e87:	c9                   	leave
80109e88:	c3                   	ret

80109e89 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109e89:	f3 0f 1e fb          	endbr32
80109e8d:	55                   	push   %ebp
80109e8e:	89 e5                	mov    %esp,%ebp
80109e90:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109e93:	8b 45 08             	mov    0x8(%ebp),%eax
80109e96:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109e99:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109ea0:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109ea7:	eb 48                	jmp    80109ef1 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109ea9:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109eac:	01 c0                	add    %eax,%eax
80109eae:	89 c2                	mov    %eax,%edx
80109eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109eb3:	01 d0                	add    %edx,%eax
80109eb5:	0f b6 00             	movzbl (%eax),%eax
80109eb8:	0f b6 c0             	movzbl %al,%eax
80109ebb:	c1 e0 08             	shl    $0x8,%eax
80109ebe:	89 c2                	mov    %eax,%edx
80109ec0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109ec3:	01 c0                	add    %eax,%eax
80109ec5:	8d 48 01             	lea    0x1(%eax),%ecx
80109ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ecb:	01 c8                	add    %ecx,%eax
80109ecd:	0f b6 00             	movzbl (%eax),%eax
80109ed0:	0f b6 c0             	movzbl %al,%eax
80109ed3:	01 d0                	add    %edx,%eax
80109ed5:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109ed8:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109edf:	76 0c                	jbe    80109eed <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
80109ee1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ee4:	0f b7 c0             	movzwl %ax,%eax
80109ee7:	83 c0 01             	add    $0x1,%eax
80109eea:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109eed:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109ef1:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109ef5:	7e b2                	jle    80109ea9 <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
80109ef7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109efa:	f7 d0                	not    %eax
}
80109efc:	c9                   	leave
80109efd:	c3                   	ret

80109efe <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109efe:	f3 0f 1e fb          	endbr32
80109f02:	55                   	push   %ebp
80109f03:	89 e5                	mov    %esp,%ebp
80109f05:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109f08:	8b 45 08             	mov    0x8(%ebp),%eax
80109f0b:	83 c0 0e             	add    $0xe,%eax
80109f0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f14:	0f b6 00             	movzbl (%eax),%eax
80109f17:	0f b6 c0             	movzbl %al,%eax
80109f1a:	83 e0 0f             	and    $0xf,%eax
80109f1d:	c1 e0 02             	shl    $0x2,%eax
80109f20:	89 c2                	mov    %eax,%edx
80109f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f25:	01 d0                	add    %edx,%eax
80109f27:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109f2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f2d:	83 c0 14             	add    $0x14,%eax
80109f30:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109f33:	e8 b0 89 ff ff       	call   801028e8 <kalloc>
80109f38:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109f3b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109f42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f45:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f49:	0f b6 c0             	movzbl %al,%eax
80109f4c:	83 e0 02             	and    $0x2,%eax
80109f4f:	85 c0                	test   %eax,%eax
80109f51:	74 3d                	je     80109f90 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109f53:	83 ec 0c             	sub    $0xc,%esp
80109f56:	6a 00                	push   $0x0
80109f58:	6a 12                	push   $0x12
80109f5a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f5d:	50                   	push   %eax
80109f5e:	ff 75 e8             	push   -0x18(%ebp)
80109f61:	ff 75 08             	push   0x8(%ebp)
80109f64:	e8 a2 01 00 00       	call   8010a10b <tcp_pkt_create>
80109f69:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109f6c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f6f:	83 ec 08             	sub    $0x8,%esp
80109f72:	50                   	push   %eax
80109f73:	ff 75 e8             	push   -0x18(%ebp)
80109f76:	e8 ff f0 ff ff       	call   8010907a <i8254_send>
80109f7b:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109f7e:	a1 44 d3 18 80       	mov    0x8018d344,%eax
80109f83:	83 c0 01             	add    $0x1,%eax
80109f86:	a3 44 d3 18 80       	mov    %eax,0x8018d344
80109f8b:	e9 69 01 00 00       	jmp    8010a0f9 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109f90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f93:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f97:	3c 18                	cmp    $0x18,%al
80109f99:	0f 85 10 01 00 00    	jne    8010a0af <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
80109f9f:	83 ec 04             	sub    $0x4,%esp
80109fa2:	6a 03                	push   $0x3
80109fa4:	68 9e c7 10 80       	push   $0x8010c79e
80109fa9:	ff 75 ec             	push   -0x14(%ebp)
80109fac:	e8 25 ae ff ff       	call   80104dd6 <memcmp>
80109fb1:	83 c4 10             	add    $0x10,%esp
80109fb4:	85 c0                	test   %eax,%eax
80109fb6:	74 74                	je     8010a02c <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
80109fb8:	83 ec 0c             	sub    $0xc,%esp
80109fbb:	68 a2 c7 10 80       	push   $0x8010c7a2
80109fc0:	e8 47 64 ff ff       	call   8010040c <cprintf>
80109fc5:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109fc8:	83 ec 0c             	sub    $0xc,%esp
80109fcb:	6a 00                	push   $0x0
80109fcd:	6a 10                	push   $0x10
80109fcf:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109fd2:	50                   	push   %eax
80109fd3:	ff 75 e8             	push   -0x18(%ebp)
80109fd6:	ff 75 08             	push   0x8(%ebp)
80109fd9:	e8 2d 01 00 00       	call   8010a10b <tcp_pkt_create>
80109fde:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109fe1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109fe4:	83 ec 08             	sub    $0x8,%esp
80109fe7:	50                   	push   %eax
80109fe8:	ff 75 e8             	push   -0x18(%ebp)
80109feb:	e8 8a f0 ff ff       	call   8010907a <i8254_send>
80109ff0:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109ff3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ff6:	83 c0 36             	add    $0x36,%eax
80109ff9:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109ffc:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109fff:	50                   	push   %eax
8010a000:	ff 75 e0             	push   -0x20(%ebp)
8010a003:	6a 00                	push   $0x0
8010a005:	6a 00                	push   $0x0
8010a007:	e8 66 04 00 00       	call   8010a472 <http_proc>
8010a00c:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a00f:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a012:	83 ec 0c             	sub    $0xc,%esp
8010a015:	50                   	push   %eax
8010a016:	6a 18                	push   $0x18
8010a018:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a01b:	50                   	push   %eax
8010a01c:	ff 75 e8             	push   -0x18(%ebp)
8010a01f:	ff 75 08             	push   0x8(%ebp)
8010a022:	e8 e4 00 00 00       	call   8010a10b <tcp_pkt_create>
8010a027:	83 c4 20             	add    $0x20,%esp
8010a02a:	eb 62                	jmp    8010a08e <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a02c:	83 ec 0c             	sub    $0xc,%esp
8010a02f:	6a 00                	push   $0x0
8010a031:	6a 10                	push   $0x10
8010a033:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a036:	50                   	push   %eax
8010a037:	ff 75 e8             	push   -0x18(%ebp)
8010a03a:	ff 75 08             	push   0x8(%ebp)
8010a03d:	e8 c9 00 00 00       	call   8010a10b <tcp_pkt_create>
8010a042:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a045:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a048:	83 ec 08             	sub    $0x8,%esp
8010a04b:	50                   	push   %eax
8010a04c:	ff 75 e8             	push   -0x18(%ebp)
8010a04f:	e8 26 f0 ff ff       	call   8010907a <i8254_send>
8010a054:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a057:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a05a:	83 c0 36             	add    $0x36,%eax
8010a05d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a060:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a063:	50                   	push   %eax
8010a064:	ff 75 e4             	push   -0x1c(%ebp)
8010a067:	6a 00                	push   $0x0
8010a069:	6a 00                	push   $0x0
8010a06b:	e8 02 04 00 00       	call   8010a472 <http_proc>
8010a070:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a073:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a076:	83 ec 0c             	sub    $0xc,%esp
8010a079:	50                   	push   %eax
8010a07a:	6a 18                	push   $0x18
8010a07c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a07f:	50                   	push   %eax
8010a080:	ff 75 e8             	push   -0x18(%ebp)
8010a083:	ff 75 08             	push   0x8(%ebp)
8010a086:	e8 80 00 00 00       	call   8010a10b <tcp_pkt_create>
8010a08b:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a08e:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a091:	83 ec 08             	sub    $0x8,%esp
8010a094:	50                   	push   %eax
8010a095:	ff 75 e8             	push   -0x18(%ebp)
8010a098:	e8 dd ef ff ff       	call   8010907a <i8254_send>
8010a09d:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a0a0:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a0a5:	83 c0 01             	add    $0x1,%eax
8010a0a8:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a0ad:	eb 4a                	jmp    8010a0f9 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a0af:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0b2:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a0b6:	3c 10                	cmp    $0x10,%al
8010a0b8:	75 3f                	jne    8010a0f9 <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a0ba:	a1 48 d3 18 80       	mov    0x8018d348,%eax
8010a0bf:	83 f8 01             	cmp    $0x1,%eax
8010a0c2:	75 35                	jne    8010a0f9 <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a0c4:	83 ec 0c             	sub    $0xc,%esp
8010a0c7:	6a 00                	push   $0x0
8010a0c9:	6a 01                	push   $0x1
8010a0cb:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a0ce:	50                   	push   %eax
8010a0cf:	ff 75 e8             	push   -0x18(%ebp)
8010a0d2:	ff 75 08             	push   0x8(%ebp)
8010a0d5:	e8 31 00 00 00       	call   8010a10b <tcp_pkt_create>
8010a0da:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a0dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a0e0:	83 ec 08             	sub    $0x8,%esp
8010a0e3:	50                   	push   %eax
8010a0e4:	ff 75 e8             	push   -0x18(%ebp)
8010a0e7:	e8 8e ef ff ff       	call   8010907a <i8254_send>
8010a0ec:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a0ef:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
8010a0f6:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a0f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0fc:	83 ec 0c             	sub    $0xc,%esp
8010a0ff:	50                   	push   %eax
8010a100:	e8 45 87 ff ff       	call   8010284a <kfree>
8010a105:	83 c4 10             	add    $0x10,%esp
}
8010a108:	90                   	nop
8010a109:	c9                   	leave
8010a10a:	c3                   	ret

8010a10b <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a10b:	f3 0f 1e fb          	endbr32
8010a10f:	55                   	push   %ebp
8010a110:	89 e5                	mov    %esp,%ebp
8010a112:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a115:	8b 45 08             	mov    0x8(%ebp),%eax
8010a118:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a11b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a11e:	83 c0 0e             	add    $0xe,%eax
8010a121:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a124:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a127:	0f b6 00             	movzbl (%eax),%eax
8010a12a:	0f b6 c0             	movzbl %al,%eax
8010a12d:	83 e0 0f             	and    $0xf,%eax
8010a130:	c1 e0 02             	shl    $0x2,%eax
8010a133:	89 c2                	mov    %eax,%edx
8010a135:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a138:	01 d0                	add    %edx,%eax
8010a13a:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a13d:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a140:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a143:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a146:	83 c0 0e             	add    $0xe,%eax
8010a149:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a14c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a14f:	83 c0 14             	add    $0x14,%eax
8010a152:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a155:	8b 45 18             	mov    0x18(%ebp),%eax
8010a158:	8d 50 36             	lea    0x36(%eax),%edx
8010a15b:	8b 45 10             	mov    0x10(%ebp),%eax
8010a15e:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a160:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a163:	8d 50 06             	lea    0x6(%eax),%edx
8010a166:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a169:	83 ec 04             	sub    $0x4,%esp
8010a16c:	6a 06                	push   $0x6
8010a16e:	52                   	push   %edx
8010a16f:	50                   	push   %eax
8010a170:	e8 bd ac ff ff       	call   80104e32 <memmove>
8010a175:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a178:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a17b:	83 c0 06             	add    $0x6,%eax
8010a17e:	83 ec 04             	sub    $0x4,%esp
8010a181:	6a 06                	push   $0x6
8010a183:	68 68 d0 18 80       	push   $0x8018d068
8010a188:	50                   	push   %eax
8010a189:	e8 a4 ac ff ff       	call   80104e32 <memmove>
8010a18e:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a191:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a194:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a198:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a19b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a19f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1a2:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a1a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1a8:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a1ac:	8b 45 18             	mov    0x18(%ebp),%eax
8010a1af:	83 c0 28             	add    $0x28,%eax
8010a1b2:	0f b7 c0             	movzwl %ax,%eax
8010a1b5:	83 ec 0c             	sub    $0xc,%esp
8010a1b8:	50                   	push   %eax
8010a1b9:	e8 6f f8 ff ff       	call   80109a2d <H2N_ushort>
8010a1be:	83 c4 10             	add    $0x10,%esp
8010a1c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a1c4:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a1c8:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a1cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1d2:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a1d6:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a1dd:	83 c0 01             	add    $0x1,%eax
8010a1e0:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a1e6:	83 ec 0c             	sub    $0xc,%esp
8010a1e9:	6a 00                	push   $0x0
8010a1eb:	e8 3d f8 ff ff       	call   80109a2d <H2N_ushort>
8010a1f0:	83 c4 10             	add    $0x10,%esp
8010a1f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a1f6:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a1fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1fd:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a201:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a204:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a208:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a20b:	83 c0 0c             	add    $0xc,%eax
8010a20e:	83 ec 04             	sub    $0x4,%esp
8010a211:	6a 04                	push   $0x4
8010a213:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a218:	50                   	push   %eax
8010a219:	e8 14 ac ff ff       	call   80104e32 <memmove>
8010a21e:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a221:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a224:	8d 50 0c             	lea    0xc(%eax),%edx
8010a227:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a22a:	83 c0 10             	add    $0x10,%eax
8010a22d:	83 ec 04             	sub    $0x4,%esp
8010a230:	6a 04                	push   $0x4
8010a232:	52                   	push   %edx
8010a233:	50                   	push   %eax
8010a234:	e8 f9 ab ff ff       	call   80104e32 <memmove>
8010a239:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a23c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a23f:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a245:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a248:	83 ec 0c             	sub    $0xc,%esp
8010a24b:	50                   	push   %eax
8010a24c:	e8 ec f8 ff ff       	call   80109b3d <ipv4_chksum>
8010a251:	83 c4 10             	add    $0x10,%esp
8010a254:	0f b7 c0             	movzwl %ax,%eax
8010a257:	83 ec 0c             	sub    $0xc,%esp
8010a25a:	50                   	push   %eax
8010a25b:	e8 cd f7 ff ff       	call   80109a2d <H2N_ushort>
8010a260:	83 c4 10             	add    $0x10,%esp
8010a263:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a266:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a26a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a26d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a271:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a274:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a277:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a27a:	0f b7 10             	movzwl (%eax),%edx
8010a27d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a280:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a284:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a289:	83 ec 0c             	sub    $0xc,%esp
8010a28c:	50                   	push   %eax
8010a28d:	e8 c1 f7 ff ff       	call   80109a53 <H2N_uint>
8010a292:	83 c4 10             	add    $0x10,%esp
8010a295:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a298:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a29b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a29e:	8b 40 04             	mov    0x4(%eax),%eax
8010a2a1:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a2a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2aa:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a2ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2b0:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a2b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2b7:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a2bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2be:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a2c2:	8b 45 14             	mov    0x14(%ebp),%eax
8010a2c5:	89 c2                	mov    %eax,%edx
8010a2c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2ca:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a2cd:	83 ec 0c             	sub    $0xc,%esp
8010a2d0:	68 90 38 00 00       	push   $0x3890
8010a2d5:	e8 53 f7 ff ff       	call   80109a2d <H2N_ushort>
8010a2da:	83 c4 10             	add    $0x10,%esp
8010a2dd:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a2e0:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a2e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2e7:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a2ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2f0:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a2f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2f9:	83 ec 0c             	sub    $0xc,%esp
8010a2fc:	50                   	push   %eax
8010a2fd:	e8 1f 00 00 00       	call   8010a321 <tcp_chksum>
8010a302:	83 c4 10             	add    $0x10,%esp
8010a305:	83 c0 08             	add    $0x8,%eax
8010a308:	0f b7 c0             	movzwl %ax,%eax
8010a30b:	83 ec 0c             	sub    $0xc,%esp
8010a30e:	50                   	push   %eax
8010a30f:	e8 19 f7 ff ff       	call   80109a2d <H2N_ushort>
8010a314:	83 c4 10             	add    $0x10,%esp
8010a317:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a31a:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a31e:	90                   	nop
8010a31f:	c9                   	leave
8010a320:	c3                   	ret

8010a321 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a321:	f3 0f 1e fb          	endbr32
8010a325:	55                   	push   %ebp
8010a326:	89 e5                	mov    %esp,%ebp
8010a328:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a32b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a32e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a331:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a334:	83 c0 14             	add    $0x14,%eax
8010a337:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a33a:	83 ec 04             	sub    $0x4,%esp
8010a33d:	6a 04                	push   $0x4
8010a33f:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a344:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a347:	50                   	push   %eax
8010a348:	e8 e5 aa ff ff       	call   80104e32 <memmove>
8010a34d:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a350:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a353:	83 c0 0c             	add    $0xc,%eax
8010a356:	83 ec 04             	sub    $0x4,%esp
8010a359:	6a 04                	push   $0x4
8010a35b:	50                   	push   %eax
8010a35c:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a35f:	83 c0 04             	add    $0x4,%eax
8010a362:	50                   	push   %eax
8010a363:	e8 ca aa ff ff       	call   80104e32 <memmove>
8010a368:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a36b:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a36f:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a373:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a376:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a37a:	0f b7 c0             	movzwl %ax,%eax
8010a37d:	83 ec 0c             	sub    $0xc,%esp
8010a380:	50                   	push   %eax
8010a381:	e8 81 f6 ff ff       	call   80109a07 <N2H_ushort>
8010a386:	83 c4 10             	add    $0x10,%esp
8010a389:	83 e8 14             	sub    $0x14,%eax
8010a38c:	0f b7 c0             	movzwl %ax,%eax
8010a38f:	83 ec 0c             	sub    $0xc,%esp
8010a392:	50                   	push   %eax
8010a393:	e8 95 f6 ff ff       	call   80109a2d <H2N_ushort>
8010a398:	83 c4 10             	add    $0x10,%esp
8010a39b:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a39f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a3a6:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a3a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a3ac:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a3b3:	eb 33                	jmp    8010a3e8 <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a3b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3b8:	01 c0                	add    %eax,%eax
8010a3ba:	89 c2                	mov    %eax,%edx
8010a3bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3bf:	01 d0                	add    %edx,%eax
8010a3c1:	0f b6 00             	movzbl (%eax),%eax
8010a3c4:	0f b6 c0             	movzbl %al,%eax
8010a3c7:	c1 e0 08             	shl    $0x8,%eax
8010a3ca:	89 c2                	mov    %eax,%edx
8010a3cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3cf:	01 c0                	add    %eax,%eax
8010a3d1:	8d 48 01             	lea    0x1(%eax),%ecx
8010a3d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3d7:	01 c8                	add    %ecx,%eax
8010a3d9:	0f b6 00             	movzbl (%eax),%eax
8010a3dc:	0f b6 c0             	movzbl %al,%eax
8010a3df:	01 d0                	add    %edx,%eax
8010a3e1:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a3e4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a3e8:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a3ec:	7e c7                	jle    8010a3b5 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a3ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a3f4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a3fb:	eb 33                	jmp    8010a430 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a3fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a400:	01 c0                	add    %eax,%eax
8010a402:	89 c2                	mov    %eax,%edx
8010a404:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a407:	01 d0                	add    %edx,%eax
8010a409:	0f b6 00             	movzbl (%eax),%eax
8010a40c:	0f b6 c0             	movzbl %al,%eax
8010a40f:	c1 e0 08             	shl    $0x8,%eax
8010a412:	89 c2                	mov    %eax,%edx
8010a414:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a417:	01 c0                	add    %eax,%eax
8010a419:	8d 48 01             	lea    0x1(%eax),%ecx
8010a41c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a41f:	01 c8                	add    %ecx,%eax
8010a421:	0f b6 00             	movzbl (%eax),%eax
8010a424:	0f b6 c0             	movzbl %al,%eax
8010a427:	01 d0                	add    %edx,%eax
8010a429:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a42c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a430:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a434:	0f b7 c0             	movzwl %ax,%eax
8010a437:	83 ec 0c             	sub    $0xc,%esp
8010a43a:	50                   	push   %eax
8010a43b:	e8 c7 f5 ff ff       	call   80109a07 <N2H_ushort>
8010a440:	83 c4 10             	add    $0x10,%esp
8010a443:	66 d1 e8             	shr    $1,%ax
8010a446:	0f b7 c0             	movzwl %ax,%eax
8010a449:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a44c:	7c af                	jl     8010a3fd <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a44e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a451:	c1 e8 10             	shr    $0x10,%eax
8010a454:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a45a:	f7 d0                	not    %eax
}
8010a45c:	c9                   	leave
8010a45d:	c3                   	ret

8010a45e <tcp_fin>:

void tcp_fin(){
8010a45e:	f3 0f 1e fb          	endbr32
8010a462:	55                   	push   %ebp
8010a463:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a465:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a46c:	00 00 00 
}
8010a46f:	90                   	nop
8010a470:	5d                   	pop    %ebp
8010a471:	c3                   	ret

8010a472 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a472:	f3 0f 1e fb          	endbr32
8010a476:	55                   	push   %ebp
8010a477:	89 e5                	mov    %esp,%ebp
8010a479:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a47c:	8b 45 10             	mov    0x10(%ebp),%eax
8010a47f:	83 ec 04             	sub    $0x4,%esp
8010a482:	6a 00                	push   $0x0
8010a484:	68 ab c7 10 80       	push   $0x8010c7ab
8010a489:	50                   	push   %eax
8010a48a:	e8 65 00 00 00       	call   8010a4f4 <http_strcpy>
8010a48f:	83 c4 10             	add    $0x10,%esp
8010a492:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a495:	8b 45 10             	mov    0x10(%ebp),%eax
8010a498:	83 ec 04             	sub    $0x4,%esp
8010a49b:	ff 75 f4             	push   -0xc(%ebp)
8010a49e:	68 be c7 10 80       	push   $0x8010c7be
8010a4a3:	50                   	push   %eax
8010a4a4:	e8 4b 00 00 00       	call   8010a4f4 <http_strcpy>
8010a4a9:	83 c4 10             	add    $0x10,%esp
8010a4ac:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a4af:	8b 45 10             	mov    0x10(%ebp),%eax
8010a4b2:	83 ec 04             	sub    $0x4,%esp
8010a4b5:	ff 75 f4             	push   -0xc(%ebp)
8010a4b8:	68 d9 c7 10 80       	push   $0x8010c7d9
8010a4bd:	50                   	push   %eax
8010a4be:	e8 31 00 00 00       	call   8010a4f4 <http_strcpy>
8010a4c3:	83 c4 10             	add    $0x10,%esp
8010a4c6:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a4c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4cc:	83 e0 01             	and    $0x1,%eax
8010a4cf:	85 c0                	test   %eax,%eax
8010a4d1:	74 11                	je     8010a4e4 <http_proc+0x72>
    char *payload = (char *)send;
8010a4d3:	8b 45 10             	mov    0x10(%ebp),%eax
8010a4d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a4d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a4dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4df:	01 d0                	add    %edx,%eax
8010a4e1:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a4e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a4e7:	8b 45 14             	mov    0x14(%ebp),%eax
8010a4ea:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a4ec:	e8 6d ff ff ff       	call   8010a45e <tcp_fin>
}
8010a4f1:	90                   	nop
8010a4f2:	c9                   	leave
8010a4f3:	c3                   	ret

8010a4f4 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a4f4:	f3 0f 1e fb          	endbr32
8010a4f8:	55                   	push   %ebp
8010a4f9:	89 e5                	mov    %esp,%ebp
8010a4fb:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a4fe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a505:	eb 20                	jmp    8010a527 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a507:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a50a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a50d:	01 d0                	add    %edx,%eax
8010a50f:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a512:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a515:	01 ca                	add    %ecx,%edx
8010a517:	89 d1                	mov    %edx,%ecx
8010a519:	8b 55 08             	mov    0x8(%ebp),%edx
8010a51c:	01 ca                	add    %ecx,%edx
8010a51e:	0f b6 00             	movzbl (%eax),%eax
8010a521:	88 02                	mov    %al,(%edx)
    i++;
8010a523:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a527:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a52a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a52d:	01 d0                	add    %edx,%eax
8010a52f:	0f b6 00             	movzbl (%eax),%eax
8010a532:	84 c0                	test   %al,%al
8010a534:	75 d1                	jne    8010a507 <http_strcpy+0x13>
  }
  return i;
8010a536:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a539:	c9                   	leave
8010a53a:	c3                   	ret

8010a53b <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a53b:	f3 0f 1e fb          	endbr32
8010a53f:	55                   	push   %ebp
8010a540:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a542:	c7 05 50 d3 18 80 a2 	movl   $0x8010f5a2,0x8018d350
8010a549:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a54c:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a551:	c1 e8 09             	shr    $0x9,%eax
8010a554:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a559:	90                   	nop
8010a55a:	5d                   	pop    %ebp
8010a55b:	c3                   	ret

8010a55c <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a55c:	f3 0f 1e fb          	endbr32
8010a560:	55                   	push   %ebp
8010a561:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a563:	90                   	nop
8010a564:	5d                   	pop    %ebp
8010a565:	c3                   	ret

8010a566 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a566:	f3 0f 1e fb          	endbr32
8010a56a:	55                   	push   %ebp
8010a56b:	89 e5                	mov    %esp,%ebp
8010a56d:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a570:	8b 45 08             	mov    0x8(%ebp),%eax
8010a573:	83 c0 0c             	add    $0xc,%eax
8010a576:	83 ec 0c             	sub    $0xc,%esp
8010a579:	50                   	push   %eax
8010a57a:	e8 c4 a4 ff ff       	call   80104a43 <holdingsleep>
8010a57f:	83 c4 10             	add    $0x10,%esp
8010a582:	85 c0                	test   %eax,%eax
8010a584:	75 0d                	jne    8010a593 <iderw+0x2d>
    panic("iderw: buf not locked");
8010a586:	83 ec 0c             	sub    $0xc,%esp
8010a589:	68 ea c7 10 80       	push   $0x8010c7ea
8010a58e:	e8 4b 60 ff ff       	call   801005de <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a593:	8b 45 08             	mov    0x8(%ebp),%eax
8010a596:	8b 00                	mov    (%eax),%eax
8010a598:	83 e0 06             	and    $0x6,%eax
8010a59b:	83 f8 02             	cmp    $0x2,%eax
8010a59e:	75 0d                	jne    8010a5ad <iderw+0x47>
    panic("iderw: nothing to do");
8010a5a0:	83 ec 0c             	sub    $0xc,%esp
8010a5a3:	68 00 c8 10 80       	push   $0x8010c800
8010a5a8:	e8 31 60 ff ff       	call   801005de <panic>
  if(b->dev != 1)
8010a5ad:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5b0:	8b 40 04             	mov    0x4(%eax),%eax
8010a5b3:	83 f8 01             	cmp    $0x1,%eax
8010a5b6:	74 0d                	je     8010a5c5 <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a5b8:	83 ec 0c             	sub    $0xc,%esp
8010a5bb:	68 15 c8 10 80       	push   $0x8010c815
8010a5c0:	e8 19 60 ff ff       	call   801005de <panic>
  if(b->blockno >= disksize)
8010a5c5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5c8:	8b 40 08             	mov    0x8(%eax),%eax
8010a5cb:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a5d1:	39 d0                	cmp    %edx,%eax
8010a5d3:	72 0d                	jb     8010a5e2 <iderw+0x7c>
    panic("iderw: block out of range");
8010a5d5:	83 ec 0c             	sub    $0xc,%esp
8010a5d8:	68 33 c8 10 80       	push   $0x8010c833
8010a5dd:	e8 fc 5f ff ff       	call   801005de <panic>

  p = memdisk + b->blockno*BSIZE;
8010a5e2:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a5e8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5eb:	8b 40 08             	mov    0x8(%eax),%eax
8010a5ee:	c1 e0 09             	shl    $0x9,%eax
8010a5f1:	01 d0                	add    %edx,%eax
8010a5f3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a5f6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5f9:	8b 00                	mov    (%eax),%eax
8010a5fb:	83 e0 04             	and    $0x4,%eax
8010a5fe:	85 c0                	test   %eax,%eax
8010a600:	74 2b                	je     8010a62d <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a602:	8b 45 08             	mov    0x8(%ebp),%eax
8010a605:	8b 00                	mov    (%eax),%eax
8010a607:	83 e0 fb             	and    $0xfffffffb,%eax
8010a60a:	89 c2                	mov    %eax,%edx
8010a60c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a60f:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a611:	8b 45 08             	mov    0x8(%ebp),%eax
8010a614:	83 c0 5c             	add    $0x5c,%eax
8010a617:	83 ec 04             	sub    $0x4,%esp
8010a61a:	68 00 02 00 00       	push   $0x200
8010a61f:	50                   	push   %eax
8010a620:	ff 75 f4             	push   -0xc(%ebp)
8010a623:	e8 0a a8 ff ff       	call   80104e32 <memmove>
8010a628:	83 c4 10             	add    $0x10,%esp
8010a62b:	eb 1a                	jmp    8010a647 <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a62d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a630:	83 c0 5c             	add    $0x5c,%eax
8010a633:	83 ec 04             	sub    $0x4,%esp
8010a636:	68 00 02 00 00       	push   $0x200
8010a63b:	ff 75 f4             	push   -0xc(%ebp)
8010a63e:	50                   	push   %eax
8010a63f:	e8 ee a7 ff ff       	call   80104e32 <memmove>
8010a644:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a647:	8b 45 08             	mov    0x8(%ebp),%eax
8010a64a:	8b 00                	mov    (%eax),%eax
8010a64c:	83 c8 02             	or     $0x2,%eax
8010a64f:	89 c2                	mov    %eax,%edx
8010a651:	8b 45 08             	mov    0x8(%ebp),%eax
8010a654:	89 10                	mov    %edx,(%eax)
}
8010a656:	90                   	nop
8010a657:	c9                   	leave
8010a658:	c3                   	ret
