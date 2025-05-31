
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
80100073:	68 40 a6 10 80       	push   $0x8010a640
80100078:	68 60 e3 18 80       	push   $0x8018e360
8010007d:	e8 a5 49 00 00       	call   80104a27 <initlock>
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
801000c1:	68 47 a6 10 80       	push   $0x8010a647
801000c6:	50                   	push   %eax
801000c7:	e8 ee 47 00 00       	call   801048ba <initsleeplock>
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
80100109:	e8 3f 49 00 00       	call   80104a4d <acquire>
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
80100148:	e8 72 49 00 00       	call   80104abf <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 9b 47 00 00       	call   801048fa <acquiresleep>
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
801001c9:	e8 f1 48 00 00       	call   80104abf <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 1a 47 00 00       	call   801048fa <acquiresleep>
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
801001fd:	68 4e a6 10 80       	push   $0x8010a64e
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
80100239:	e8 0d a3 00 00       	call   8010a54b <iderw>
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
8010025a:	e8 55 47 00 00       	call   801049b4 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 5f a6 10 80       	push   $0x8010a65f
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
80100288:	e8 be a2 00 00       	call   8010a54b <iderw>
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
801002a7:	e8 08 47 00 00       	call   801049b4 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 66 a6 10 80       	push   $0x8010a666
801002bb:	e8 1e 03 00 00       	call   801005de <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 93 46 00 00       	call   80104962 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 6e 47 00 00       	call   80104a4d <acquire>
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
8010034a:	e8 70 47 00 00       	call   80104abf <release>
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
8010042c:	e8 1c 46 00 00       	call   80104a4d <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 70 a6 10 80       	push   $0x8010a670
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
801004ce:	8b 04 85 80 a6 10 80 	mov    -0x7fef5980(,%eax,4),%eax
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
8010052c:	c7 45 ec 79 a6 10 80 	movl   $0x8010a679,-0x14(%ebp)
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
801005d3:	e8 e7 44 00 00       	call   80104abf <release>
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
80100600:	68 d8 a6 10 80       	push   $0x8010a6d8
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
8010061f:	68 ec a6 10 80       	push   $0x8010a6ec
80100624:	e8 e3 fd ff ff       	call   8010040c <cprintf>
80100629:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
8010062c:	83 ec 08             	sub    $0x8,%esp
8010062f:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100632:	50                   	push   %eax
80100633:	8d 45 08             	lea    0x8(%ebp),%eax
80100636:	50                   	push   %eax
80100637:	e8 d9 44 00 00       	call   80104b15 <getcallerpcs>
8010063c:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010063f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100646:	eb 1c                	jmp    80100664 <panic+0x86>
    cprintf(" %p", pcs[i]);
80100648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010064b:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010064f:	83 ec 08             	sub    $0x8,%esp
80100652:	50                   	push   %eax
80100653:	68 ee a6 10 80       	push   $0x8010a6ee
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
801006dd:	e8 fd 7c 00 00       	call   801083df <graphic_scroll_up>
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
80100730:	e8 aa 7c 00 00       	call   801083df <graphic_scroll_up>
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
80100796:	e8 b8 7c 00 00       	call   80108453 <font_render>
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
801007d6:	e8 1d 60 00 00       	call   801067f8 <uartputc>
801007db:	83 c4 10             	add    $0x10,%esp
801007de:	83 ec 0c             	sub    $0xc,%esp
801007e1:	6a 20                	push   $0x20
801007e3:	e8 10 60 00 00       	call   801067f8 <uartputc>
801007e8:	83 c4 10             	add    $0x10,%esp
801007eb:	83 ec 0c             	sub    $0xc,%esp
801007ee:	6a 08                	push   $0x8
801007f0:	e8 03 60 00 00       	call   801067f8 <uartputc>
801007f5:	83 c4 10             	add    $0x10,%esp
801007f8:	eb 0e                	jmp    80100808 <consputc+0x5a>
  } else {
    uartputc(c);
801007fa:	83 ec 0c             	sub    $0xc,%esp
801007fd:	ff 75 08             	push   0x8(%ebp)
80100800:	e8 f3 5f 00 00       	call   801067f8 <uartputc>
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
80100832:	e8 16 42 00 00       	call   80104a4d <acquire>
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
801009ab:	e8 0f 41 00 00       	call   80104abf <release>
801009b0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b7:	74 05                	je     801009be <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009b9:	e8 c8 3c 00 00       	call   80104686 <procdump>
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
801009e7:	e8 61 40 00 00       	call   80104a4d <acquire>
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
80100a08:	e8 b2 40 00 00       	call   80104abf <release>
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
80100ab3:	e8 07 40 00 00       	call   80104abf <release>
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
80100af5:	e8 53 3f 00 00       	call   80104a4d <acquire>
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
80100b37:	e8 83 3f 00 00       	call   80104abf <release>
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
80100b69:	68 f2 a6 10 80       	push   $0x8010a6f2
80100b6e:	68 20 d0 18 80       	push   $0x8018d020
80100b73:	e8 af 3e 00 00       	call   80104a27 <initlock>
80100b78:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b7b:	c7 05 0c 37 19 80 d5 	movl   $0x80100ad5,0x8019370c
80100b82:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b85:	c7 05 08 37 19 80 c1 	movl   $0x801009c1,0x80193708
80100b8c:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b8f:	c7 45 f4 fa a6 10 80 	movl   $0x8010a6fa,-0xc(%ebp)
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
80100c10:	68 10 a7 10 80       	push   $0x8010a710
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
80100c6c:	e8 9b 6b 00 00       	call   8010780c <setupkvm>
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
80100d12:	e8 07 6f 00 00       	call   80107c1e <allocuvm>
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
80100d58:	e8 f0 6d 00 00       	call   80107b4d <loaduvm>
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
  // 2*PGSIZE로 하면 페이지의 끝 주소가 커널 베이스가 되기 때문에 한 단계 더 내린다.
  // Pagefault가 발생했을 때 스택의 바로 아래인지를 판단하기 위해 gaurd page도 할당한다.
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
80100dbe:	e8 5b 6e 00 00       	call   80107c1e <allocuvm>
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
80100e0b:	e8 35 41 00 00       	call   80104f45 <strlen>
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
80100e38:	e8 08 41 00 00       	call   80104f45 <strlen>
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
80100e5e:	e8 cf 71 00 00       	call   80108032 <copyout>
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
80100efa:	e8 33 71 00 00       	call   80108032 <copyout>
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
80100f48:	e8 aa 3f 00 00       	call   80104ef7 <safestrcpy>
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
80100f8b:	e8 a6 69 00 00       	call   80107936 <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	push   -0x34(%ebp)
80100f99:	e8 61 6e 00 00       	call   80107dff <freevm>
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
80100fd0:	68 1c a7 10 80       	push   $0x8010a71c
80100fd5:	e8 32 f4 ff ff       	call   8010040c <cprintf>
80100fda:	83 c4 10             	add    $0x10,%esp
  if(pgdir)
80100fdd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fe1:	74 0e                	je     80100ff1 <exec+0x41a>
    freevm(pgdir);
80100fe3:	83 ec 0c             	sub    $0xc,%esp
80100fe6:	ff 75 d4             	push   -0x2c(%ebp)
80100fe9:	e8 11 6e 00 00       	call   80107dff <freevm>
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
8010101e:	68 22 a7 10 80       	push   $0x8010a722
80101023:	68 60 2d 19 80       	push   $0x80192d60
80101028:	e8 fa 39 00 00       	call   80104a27 <initlock>
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
80101045:	e8 03 3a 00 00       	call   80104a4d <acquire>
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
80101072:	e8 48 3a 00 00       	call   80104abf <release>
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
80101095:	e8 25 3a 00 00       	call   80104abf <release>
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
801010b6:	e8 92 39 00 00       	call   80104a4d <acquire>
801010bb:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010be:	8b 45 08             	mov    0x8(%ebp),%eax
801010c1:	8b 40 04             	mov    0x4(%eax),%eax
801010c4:	85 c0                	test   %eax,%eax
801010c6:	7f 0d                	jg     801010d5 <filedup+0x31>
    panic("filedup");
801010c8:	83 ec 0c             	sub    $0xc,%esp
801010cb:	68 29 a7 10 80       	push   $0x8010a729
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
801010ec:	e8 ce 39 00 00       	call   80104abf <release>
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
8010110b:	e8 3d 39 00 00       	call   80104a4d <acquire>
80101110:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101113:	8b 45 08             	mov    0x8(%ebp),%eax
80101116:	8b 40 04             	mov    0x4(%eax),%eax
80101119:	85 c0                	test   %eax,%eax
8010111b:	7f 0d                	jg     8010112a <fileclose+0x31>
    panic("fileclose");
8010111d:	83 ec 0c             	sub    $0xc,%esp
80101120:	68 31 a7 10 80       	push   $0x8010a731
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
8010114b:	e8 6f 39 00 00       	call   80104abf <release>
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
80101199:	e8 21 39 00 00       	call   80104abf <release>
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
801012f0:	68 3b a7 10 80       	push   $0x8010a73b
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
801013f7:	68 44 a7 10 80       	push   $0x8010a744
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
8010142d:	68 54 a7 10 80       	push   $0x8010a754
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
80101469:	e8 35 39 00 00       	call   80104da3 <memmove>
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
801014b3:	e8 24 38 00 00       	call   80104cdc <memset>
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
8010161e:	68 60 a7 10 80       	push   $0x8010a760
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
801016b5:	68 76 a7 10 80       	push   $0x8010a776
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
8010171d:	68 89 a7 10 80       	push   $0x8010a789
80101722:	68 80 37 19 80       	push   $0x80193780
80101727:	e8 fb 32 00 00       	call   80104a27 <initlock>
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
80101753:	68 90 a7 10 80       	push   $0x8010a790
80101758:	50                   	push   %eax
80101759:	e8 5c 31 00 00       	call   801048ba <initsleeplock>
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
801017b2:	68 98 a7 10 80       	push   $0x8010a798
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
8010182f:	e8 a8 34 00 00       	call   80104cdc <memset>
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
80101897:	68 eb a7 10 80       	push   $0x8010a7eb
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
80101941:	e8 5d 34 00 00       	call   80104da3 <memmove>
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
8010197a:	e8 ce 30 00 00       	call   80104a4d <acquire>
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
801019c8:	e8 f2 30 00 00       	call   80104abf <release>
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
80101a04:	68 fd a7 10 80       	push   $0x8010a7fd
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
80101a41:	e8 79 30 00 00       	call   80104abf <release>
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
80101a60:	e8 e8 2f 00 00       	call   80104a4d <acquire>
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
80101a7f:	e8 3b 30 00 00       	call   80104abf <release>
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
80101aa9:	68 0d a8 10 80       	push   $0x8010a80d
80101aae:	e8 2b eb ff ff       	call   801005de <panic>

  acquiresleep(&ip->lock);
80101ab3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab6:	83 c0 0c             	add    $0xc,%eax
80101ab9:	83 ec 0c             	sub    $0xc,%esp
80101abc:	50                   	push   %eax
80101abd:	e8 38 2e 00 00       	call   801048fa <acquiresleep>
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
80101b67:	e8 37 32 00 00       	call   80104da3 <memmove>
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
80101b96:	68 13 a8 10 80       	push   $0x8010a813
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
80101bbd:	e8 f2 2d 00 00       	call   801049b4 <holdingsleep>
80101bc2:	83 c4 10             	add    $0x10,%esp
80101bc5:	85 c0                	test   %eax,%eax
80101bc7:	74 0a                	je     80101bd3 <iunlock+0x30>
80101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcc:	8b 40 08             	mov    0x8(%eax),%eax
80101bcf:	85 c0                	test   %eax,%eax
80101bd1:	7f 0d                	jg     80101be0 <iunlock+0x3d>
    panic("iunlock");
80101bd3:	83 ec 0c             	sub    $0xc,%esp
80101bd6:	68 22 a8 10 80       	push   $0x8010a822
80101bdb:	e8 fe e9 ff ff       	call   801005de <panic>

  releasesleep(&ip->lock);
80101be0:	8b 45 08             	mov    0x8(%ebp),%eax
80101be3:	83 c0 0c             	add    $0xc,%eax
80101be6:	83 ec 0c             	sub    $0xc,%esp
80101be9:	50                   	push   %eax
80101bea:	e8 73 2d 00 00       	call   80104962 <releasesleep>
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
80101c09:	e8 ec 2c 00 00       	call   801048fa <acquiresleep>
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
80101c2f:	e8 19 2e 00 00       	call   80104a4d <acquire>
80101c34:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c37:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3a:	8b 40 08             	mov    0x8(%eax),%eax
80101c3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c40:	83 ec 0c             	sub    $0xc,%esp
80101c43:	68 80 37 19 80       	push   $0x80193780
80101c48:	e8 72 2e 00 00       	call   80104abf <release>
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
80101c8f:	e8 ce 2c 00 00       	call   80104962 <releasesleep>
80101c94:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c97:	83 ec 0c             	sub    $0xc,%esp
80101c9a:	68 80 37 19 80       	push   $0x80193780
80101c9f:	e8 a9 2d 00 00       	call   80104a4d <acquire>
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
80101cbe:	e8 fc 2d 00 00       	call   80104abf <release>
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
80101e0a:	68 2a a8 10 80       	push   $0x8010a82a
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
801020b4:	e8 ea 2c 00 00       	call   80104da3 <memmove>
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
80102208:	e8 96 2b 00 00       	call   80104da3 <memmove>
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
8010228c:	e8 b0 2b 00 00       	call   80104e41 <strncmp>
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
801022b0:	68 3d a8 10 80       	push   $0x8010a83d
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
801022df:	68 4f a8 10 80       	push   $0x8010a84f
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
801023b8:	68 5e a8 10 80       	push   $0x8010a85e
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
801023f3:	e8 a3 2a 00 00       	call   80104e9b <strncpy>
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
8010241f:	68 6b a8 10 80       	push   $0x8010a86b
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
80102495:	e8 09 29 00 00       	call   80104da3 <memmove>
8010249a:	83 c4 10             	add    $0x10,%esp
8010249d:	eb 26                	jmp    801024c5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010249f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024a2:	83 ec 04             	sub    $0x4,%esp
801024a5:	50                   	push   %eax
801024a6:	ff 75 f4             	push   -0xc(%ebp)
801024a9:	ff 75 0c             	push   0xc(%ebp)
801024ac:	e8 f2 28 00 00       	call   80104da3 <memmove>
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
801026bb:	68 74 a8 10 80       	push   $0x8010a874
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
8010276a:	68 a6 a8 10 80       	push   $0x8010a8a6
8010276f:	68 e0 53 19 80       	push   $0x801953e0
80102774:	e8 ae 22 00 00       	call   80104a27 <initlock>
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
80102835:	68 ab a8 10 80       	push   $0x8010a8ab
8010283a:	e8 9f dd ff ff       	call   801005de <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010283f:	83 ec 04             	sub    $0x4,%esp
80102842:	68 00 10 00 00       	push   $0x1000
80102847:	6a 01                	push   $0x1
80102849:	ff 75 08             	push   0x8(%ebp)
8010284c:	e8 8b 24 00 00       	call   80104cdc <memset>
80102851:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102854:	a1 14 54 19 80       	mov    0x80195414,%eax
80102859:	85 c0                	test   %eax,%eax
8010285b:	74 10                	je     8010286d <kfree+0x69>
    acquire(&kmem.lock);
8010285d:	83 ec 0c             	sub    $0xc,%esp
80102860:	68 e0 53 19 80       	push   $0x801953e0
80102865:	e8 e3 21 00 00       	call   80104a4d <acquire>
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
80102897:	e8 23 22 00 00       	call   80104abf <release>
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
801028bd:	e8 8b 21 00 00       	call   80104a4d <acquire>
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
801028ee:	e8 cc 21 00 00       	call   80104abf <release>
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
80102e43:	e8 ff 1e 00 00       	call   80104d47 <memcmp>
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
80102f5b:	68 b1 a8 10 80       	push   $0x8010a8b1
80102f60:	68 20 54 19 80       	push   $0x80195420
80102f65:	e8 bd 1a 00 00       	call   80104a27 <initlock>
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
80103014:	e8 8a 1d 00 00       	call   80104da3 <memmove>
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
80103193:	e8 b5 18 00 00       	call   80104a4d <acquire>
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
80103205:	e8 b5 18 00 00       	call   80104abf <release>
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
8010322a:	e8 1e 18 00 00       	call   80104a4d <acquire>
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
8010324b:	68 b5 a8 10 80       	push   $0x8010a8b5
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
80103289:	e8 31 18 00 00       	call   80104abf <release>
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
801032a4:	e8 a4 17 00 00       	call   80104a4d <acquire>
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
801032ce:	e8 ec 17 00 00       	call   80104abf <release>
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
8010334e:	e8 50 1a 00 00       	call   80104da3 <memmove>
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
801033f3:	68 c4 a8 10 80       	push   $0x8010a8c4
801033f8:	e8 e1 d1 ff ff       	call   801005de <panic>
  if (log.outstanding < 1)
801033fd:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103402:	85 c0                	test   %eax,%eax
80103404:	7f 0d                	jg     80103413 <log_write+0x49>
    panic("log_write outside of trans");
80103406:	83 ec 0c             	sub    $0xc,%esp
80103409:	68 da a8 10 80       	push   $0x8010a8da
8010340e:	e8 cb d1 ff ff       	call   801005de <panic>

  acquire(&log.lock);
80103413:	83 ec 0c             	sub    $0xc,%esp
80103416:	68 20 54 19 80       	push   $0x80195420
8010341b:	e8 2d 16 00 00       	call   80104a4d <acquire>
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
80103499:	e8 21 16 00 00       	call   80104abf <release>
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
801034d3:	e8 43 4e 00 00       	call   8010831b <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801034d8:	83 ec 08             	sub    $0x8,%esp
801034db:	68 00 00 40 80       	push   $0x80400000
801034e0:	68 00 90 19 80       	push   $0x80199000
801034e5:	e8 73 f2 ff ff       	call   8010275d <kinit1>
801034ea:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034ed:	e8 0b 44 00 00       	call   801078fd <kvmalloc>
  mpinit_uefi();
801034f2:	e8 dd 4b 00 00       	call   801080d4 <mpinit_uefi>
  lapicinit();     // interrupt controller
801034f7:	e8 f0 f5 ff ff       	call   80102aec <lapicinit>
  seginit();       // segment descriptors
801034fc:	e8 83 3e 00 00       	call   80107384 <seginit>
  picinit();    // disable pic
80103501:	e8 a9 01 00 00       	call   801036af <picinit>
  ioapicinit();    // another interrupt controller
80103506:	e8 65 f1 ff ff       	call   80102670 <ioapicinit>
  consoleinit();   // console hardware
8010350b:	e8 42 d6 ff ff       	call   80100b52 <consoleinit>
  uartinit();      // serial port
80103510:	e8 f8 31 00 00       	call   8010670d <uartinit>
  pinit();         // process table
80103515:	e8 e2 05 00 00       	call   80103afc <pinit>
  tvinit();        // trap vectors
8010351a:	e8 be 2c 00 00       	call   801061dd <tvinit>
  binit();         // buffer cache
8010351f:	e8 42 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103524:	e8 e8 da ff ff       	call   80101011 <fileinit>
  ideinit();       // disk 
80103529:	e8 f2 6f 00 00       	call   8010a520 <ideinit>
  startothers();   // start other processors
8010352e:	e8 92 00 00 00       	call   801035c5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103533:	83 ec 08             	sub    $0x8,%esp
80103536:	68 00 00 00 a0       	push   $0xa0000000
8010353b:	68 00 00 40 80       	push   $0x80400000
80103540:	e8 55 f2 ff ff       	call   8010279a <kinit2>
80103545:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103548:	e8 41 50 00 00       	call   8010858e <pci_init>
  arp_scan();
8010354d:	e8 ba 5d 00 00       	call   8010930c <arp_scan>
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
80103566:	e8 ae 43 00 00       	call   80107919 <switchkvm>
  seginit();
8010356b:	e8 14 3e 00 00       	call   80107384 <seginit>
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
80103596:	68 f5 a8 10 80       	push   $0x8010a8f5
8010359b:	e8 6c ce ff ff       	call   8010040c <cprintf>
801035a0:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801035a3:	e8 af 2d 00 00       	call   80106357 <idtinit>
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
801035e7:	e8 b7 17 00 00       	call   80104da3 <memmove>
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
80103778:	68 09 a9 10 80       	push   $0x8010a909
8010377d:	50                   	push   %eax
8010377e:	e8 a4 12 00 00       	call   80104a27 <initlock>
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
80103841:	e8 07 12 00 00       	call   80104a4d <acquire>
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
801038b4:	e8 06 12 00 00       	call   80104abf <release>
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
801038d3:	e8 e7 11 00 00       	call   80104abf <release>
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
801038f1:	e8 57 11 00 00       	call   80104a4d <acquire>
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
80103925:	e8 95 11 00 00       	call   80104abf <release>
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
801039d5:	e8 e5 10 00 00       	call   80104abf <release>
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
801039f6:	e8 52 10 00 00       	call   80104a4d <acquire>
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
80103a13:	e8 a7 10 00 00       	call   80104abf <release>
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
80103ad8:	e8 e2 0f 00 00       	call   80104abf <release>
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
80103b09:	68 10 a9 10 80       	push   $0x8010a910
80103b0e:	68 00 55 19 80       	push   $0x80195500
80103b13:	e8 0f 0f 00 00       	call   80104a27 <initlock>
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
80103b58:	68 18 a9 10 80       	push   $0x8010a918
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
80103bad:	68 3e a9 10 80       	push   $0x8010a93e
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
80103bc3:	e8 01 10 00 00       	call   80104bc9 <pushcli>
  c = mycpu();
80103bc8:	e8 70 ff ff ff       	call   80103b3d <mycpu>
80103bcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103bd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103bdc:	e8 39 10 00 00       	call   80104c1a <popcli>
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
80103bf8:	e8 50 0e 00 00       	call   80104a4d <acquire>
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
80103c28:	e8 92 0e 00 00       	call   80104abf <release>
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
80103c65:	e8 55 0e 00 00       	call   80104abf <release>
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
80103cb2:	ba 97 61 10 80       	mov    $0x80106197,%edx
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
80103cd7:	e8 00 10 00 00       	call   80104cdc <memset>
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
80103cff:	68 4e a9 10 80       	push   $0x8010a94e
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
80103d1c:	e8 eb 3a 00 00       	call   8010780c <setupkvm>
80103d21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d24:	89 42 04             	mov    %eax,0x4(%edx)
80103d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d2a:	8b 40 04             	mov    0x4(%eax),%eax
80103d2d:	85 c0                	test   %eax,%eax
80103d2f:	75 0d                	jne    80103d3e <userinit+0x4c>
    panic("userinit: out of memory?");
80103d31:	83 ec 0c             	sub    $0xc,%esp
80103d34:	68 5e a9 10 80       	push   $0x8010a95e
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
80103d53:	e8 81 3d 00 00       	call   80107ad9 <inituvm>
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
80103d72:	e8 65 0f 00 00       	call   80104cdc <memset>
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
80103dec:	68 77 a9 10 80       	push   $0x8010a977
80103df1:	50                   	push   %eax
80103df2:	e8 00 11 00 00       	call   80104ef7 <safestrcpy>
80103df7:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103dfa:	83 ec 0c             	sub    $0xc,%esp
80103dfd:	68 80 a9 10 80       	push   $0x8010a980
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
80103e18:	e8 30 0c 00 00       	call   80104a4d <acquire>
80103e1d:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e23:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e2a:	83 ec 0c             	sub    $0xc,%esp
80103e2d:	68 00 55 19 80       	push   $0x80195500
80103e32:	e8 88 0c 00 00       	call   80104abf <release>
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
80103e73:	e8 a6 3d 00 00       	call   80107c1e <allocuvm>
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
80103ea7:	e8 7b 3e 00 00       	call   80107d27 <deallocuvm>
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
80103ecd:	e8 64 3a 00 00       	call   80107936 <switchuvm>
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
80103f19:	e8 c3 3f 00 00       	call   80107ee1 <copyuvm>
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
80104013:	e8 df 0e 00 00       	call   80104ef7 <safestrcpy>
80104018:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
8010401b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010401e:	8b 40 10             	mov    0x10(%eax),%eax
80104021:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104024:	83 ec 0c             	sub    $0xc,%esp
80104027:	68 00 55 19 80       	push   $0x80195500
8010402c:	e8 1c 0a 00 00       	call   80104a4d <acquire>
80104031:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104034:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104037:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010403e:	83 ec 0c             	sub    $0xc,%esp
80104041:	68 00 55 19 80       	push   $0x80195500
80104046:	e8 74 0a 00 00       	call   80104abf <release>
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
80104078:	68 82 a9 10 80       	push   $0x8010a982
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
801040fe:	e8 4a 09 00 00       	call   80104a4d <acquire>
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
80104173:	68 8f a9 10 80       	push   $0x8010a98f
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
80104197:	e8 b1 08 00 00       	call   80104a4d <acquire>
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
80104202:	e8 f8 3b 00 00       	call   80107dff <freevm>
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
80104241:	e8 79 08 00 00       	call   80104abf <release>
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
80104278:	e8 42 08 00 00       	call   80104abf <release>
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
801042cd:	e8 7b 07 00 00       	call   80104a4d <acquire>
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
801042fb:	e8 36 36 00 00       	call   80107936 <switchuvm>
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
8010431e:	e8 4d 0c 00 00       	call   80104f70 <swtch>
80104323:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104326:	e8 ee 35 00 00       	call   80107919 <switchkvm>

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
80104350:	e8 6a 07 00 00       	call   80104abf <release>
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
80104399:	e8 f6 07 00 00       	call   80104b94 <holding>
8010439e:	83 c4 10             	add    $0x10,%esp
801043a1:	85 c0                	test   %eax,%eax
801043a3:	75 0d                	jne    801043b2 <sched+0x33>
    panic("sched ptable.lock");
801043a5:	83 ec 0c             	sub    $0xc,%esp
801043a8:	68 9b a9 10 80       	push   $0x8010a99b
801043ad:	e8 2c c2 ff ff       	call   801005de <panic>
  if(mycpu()->ncli != 1)
801043b2:	e8 86 f7 ff ff       	call   80103b3d <mycpu>
801043b7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801043bd:	83 f8 01             	cmp    $0x1,%eax
801043c0:	74 0d                	je     801043cf <sched+0x50>
    panic("sched locks");
801043c2:	83 ec 0c             	sub    $0xc,%esp
801043c5:	68 ad a9 10 80       	push   $0x8010a9ad
801043ca:	e8 0f c2 ff ff       	call   801005de <panic>
  if(p->state == RUNNING)
801043cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d2:	8b 40 0c             	mov    0xc(%eax),%eax
801043d5:	83 f8 04             	cmp    $0x4,%eax
801043d8:	75 0d                	jne    801043e7 <sched+0x68>
    panic("sched running");
801043da:	83 ec 0c             	sub    $0xc,%esp
801043dd:	68 b9 a9 10 80       	push   $0x8010a9b9
801043e2:	e8 f7 c1 ff ff       	call   801005de <panic>
  if(readeflags()&FL_IF)
801043e7:	e8 f9 f6 ff ff       	call   80103ae5 <readeflags>
801043ec:	25 00 02 00 00       	and    $0x200,%eax
801043f1:	85 c0                	test   %eax,%eax
801043f3:	74 0d                	je     80104402 <sched+0x83>
    panic("sched interruptible");
801043f5:	83 ec 0c             	sub    $0xc,%esp
801043f8:	68 c7 a9 10 80       	push   $0x8010a9c7
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
80104423:	e8 48 0b 00 00       	call   80104f70 <swtch>
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
8010444e:	e8 fa 05 00 00       	call   80104a4d <acquire>
80104453:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104456:	e8 5e f7 ff ff       	call   80103bb9 <myproc>
8010445b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104462:	e8 18 ff ff ff       	call   8010437f <sched>
  release(&ptable.lock);
80104467:	83 ec 0c             	sub    $0xc,%esp
8010446a:	68 00 55 19 80       	push   $0x80195500
8010446f:	e8 4b 06 00 00       	call   80104abf <release>
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
8010448c:	e8 2e 06 00 00       	call   80104abf <release>
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
801044df:	68 db a9 10 80       	push   $0x8010a9db
801044e4:	e8 f5 c0 ff ff       	call   801005de <panic>

  if(lk == 0)
801044e9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801044ed:	75 0d                	jne    801044fc <sleep+0x38>
    panic("sleep without lk");
801044ef:	83 ec 0c             	sub    $0xc,%esp
801044f2:	68 e1 a9 10 80       	push   $0x8010a9e1
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
8010450d:	e8 3b 05 00 00       	call   80104a4d <acquire>
80104512:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104515:	83 ec 0c             	sub    $0xc,%esp
80104518:	ff 75 0c             	push   0xc(%ebp)
8010451b:	e8 9f 05 00 00       	call   80104abf <release>
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
80104556:	e8 64 05 00 00       	call   80104abf <release>
8010455b:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010455e:	83 ec 0c             	sub    $0xc,%esp
80104561:	ff 75 0c             	push   0xc(%ebp)
80104564:	e8 e4 04 00 00       	call   80104a4d <acquire>
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
801045c5:	e8 83 04 00 00       	call   80104a4d <acquire>
801045ca:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801045cd:	83 ec 0c             	sub    $0xc,%esp
801045d0:	ff 75 08             	push   0x8(%ebp)
801045d3:	e8 97 ff ff ff       	call   8010456f <wakeup1>
801045d8:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801045db:	83 ec 0c             	sub    $0xc,%esp
801045de:	68 00 55 19 80       	push   $0x80195500
801045e3:	e8 d7 04 00 00       	call   80104abf <release>
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
  cprintf("kill\n");
801045f8:	83 ec 0c             	sub    $0xc,%esp
801045fb:	68 f2 a9 10 80       	push   $0x8010a9f2
80104600:	e8 07 be ff ff       	call   8010040c <cprintf>
80104605:	83 c4 10             	add    $0x10,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104608:	83 ec 0c             	sub    $0xc,%esp
8010460b:	68 00 55 19 80       	push   $0x80195500
80104610:	e8 38 04 00 00       	call   80104a4d <acquire>
80104615:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104618:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010461f:	eb 45                	jmp    80104666 <kill+0x78>
    if(p->pid == pid){
80104621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104624:	8b 40 10             	mov    0x10(%eax),%eax
80104627:	39 45 08             	cmp    %eax,0x8(%ebp)
8010462a:	75 36                	jne    80104662 <kill+0x74>
      p->killed = 1;
8010462c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104636:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104639:	8b 40 0c             	mov    0xc(%eax),%eax
8010463c:	83 f8 02             	cmp    $0x2,%eax
8010463f:	75 0a                	jne    8010464b <kill+0x5d>
        p->state = RUNNABLE;
80104641:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104644:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010464b:	83 ec 0c             	sub    $0xc,%esp
8010464e:	68 00 55 19 80       	push   $0x80195500
80104653:	e8 67 04 00 00       	call   80104abf <release>
80104658:	83 c4 10             	add    $0x10,%esp
      return 0;
8010465b:	b8 00 00 00 00       	mov    $0x0,%eax
80104660:	eb 22                	jmp    80104684 <kill+0x96>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104662:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104666:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
8010466d:	72 b2                	jb     80104621 <kill+0x33>
    }
  }
  release(&ptable.lock);
8010466f:	83 ec 0c             	sub    $0xc,%esp
80104672:	68 00 55 19 80       	push   $0x80195500
80104677:	e8 43 04 00 00       	call   80104abf <release>
8010467c:	83 c4 10             	add    $0x10,%esp
  return -1;
8010467f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104684:	c9                   	leave
80104685:	c3                   	ret

80104686 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104686:	f3 0f 1e fb          	endbr32
8010468a:	55                   	push   %ebp
8010468b:	89 e5                	mov    %esp,%ebp
8010468d:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104690:	c7 45 f0 34 55 19 80 	movl   $0x80195534,-0x10(%ebp)
80104697:	e9 d7 00 00 00       	jmp    80104773 <procdump+0xed>
    if(p->state == UNUSED)
8010469c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010469f:	8b 40 0c             	mov    0xc(%eax),%eax
801046a2:	85 c0                	test   %eax,%eax
801046a4:	0f 84 c4 00 00 00    	je     8010476e <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801046aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046ad:	8b 40 0c             	mov    0xc(%eax),%eax
801046b0:	83 f8 05             	cmp    $0x5,%eax
801046b3:	77 23                	ja     801046d8 <procdump+0x52>
801046b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046b8:	8b 40 0c             	mov    0xc(%eax),%eax
801046bb:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801046c2:	85 c0                	test   %eax,%eax
801046c4:	74 12                	je     801046d8 <procdump+0x52>
      state = states[p->state];
801046c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046c9:	8b 40 0c             	mov    0xc(%eax),%eax
801046cc:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801046d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801046d6:	eb 07                	jmp    801046df <procdump+0x59>
    else
      state = "???";
801046d8:	c7 45 ec f8 a9 10 80 	movl   $0x8010a9f8,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801046df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046e2:	8d 50 6c             	lea    0x6c(%eax),%edx
801046e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046e8:	8b 40 10             	mov    0x10(%eax),%eax
801046eb:	52                   	push   %edx
801046ec:	ff 75 ec             	push   -0x14(%ebp)
801046ef:	50                   	push   %eax
801046f0:	68 fc a9 10 80       	push   $0x8010a9fc
801046f5:	e8 12 bd ff ff       	call   8010040c <cprintf>
801046fa:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801046fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104700:	8b 40 0c             	mov    0xc(%eax),%eax
80104703:	83 f8 02             	cmp    $0x2,%eax
80104706:	75 54                	jne    8010475c <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104708:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010470b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010470e:	8b 40 0c             	mov    0xc(%eax),%eax
80104711:	83 c0 08             	add    $0x8,%eax
80104714:	89 c2                	mov    %eax,%edx
80104716:	83 ec 08             	sub    $0x8,%esp
80104719:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010471c:	50                   	push   %eax
8010471d:	52                   	push   %edx
8010471e:	e8 f2 03 00 00       	call   80104b15 <getcallerpcs>
80104723:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104726:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010472d:	eb 1c                	jmp    8010474b <procdump+0xc5>
        cprintf(" %p", pc[i]);
8010472f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104732:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104736:	83 ec 08             	sub    $0x8,%esp
80104739:	50                   	push   %eax
8010473a:	68 05 aa 10 80       	push   $0x8010aa05
8010473f:	e8 c8 bc ff ff       	call   8010040c <cprintf>
80104744:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104747:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010474b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010474f:	7f 0b                	jg     8010475c <procdump+0xd6>
80104751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104754:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104758:	85 c0                	test   %eax,%eax
8010475a:	75 d3                	jne    8010472f <procdump+0xa9>
    }
    cprintf("\n");
8010475c:	83 ec 0c             	sub    $0xc,%esp
8010475f:	68 09 aa 10 80       	push   $0x8010aa09
80104764:	e8 a3 bc ff ff       	call   8010040c <cprintf>
80104769:	83 c4 10             	add    $0x10,%esp
8010476c:	eb 01                	jmp    8010476f <procdump+0xe9>
      continue;
8010476e:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010476f:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104773:	81 7d f0 34 75 19 80 	cmpl   $0x80197534,-0x10(%ebp)
8010477a:	0f 82 1c ff ff ff    	jb     8010469c <procdump+0x16>
  }
}
80104780:	90                   	nop
80104781:	90                   	nop
80104782:	c9                   	leave
80104783:	c3                   	ret

80104784 <printpt>:

// 페이지 테이블 출력
int printpt(int pid){
80104784:	f3 0f 1e fb          	endbr32
80104788:	55                   	push   %ebp
80104789:	89 e5                	mov    %esp,%ebp
8010478b:	53                   	push   %ebx
8010478c:	83 ec 14             	sub    $0x14,%esp
  struct proc* p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010478f:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104796:	eb 0f                	jmp    801047a7 <printpt+0x23>
    if (p->pid == pid)
80104798:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479b:	8b 40 10             	mov    0x10(%eax),%eax
8010479e:	39 45 08             	cmp    %eax,0x8(%ebp)
801047a1:	74 0f                	je     801047b2 <printpt+0x2e>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047a3:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801047a7:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801047ae:	72 e8                	jb     80104798 <printpt+0x14>
801047b0:	eb 01                	jmp    801047b3 <printpt+0x2f>
      break;
801047b2:	90                   	nop
  }
  if (p == 0){
801047b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047b7:	75 1a                	jne    801047d3 <printpt+0x4f>
    cprintf("[printpt] invaild proccess\n");
801047b9:	83 ec 0c             	sub    $0xc,%esp
801047bc:	68 0b aa 10 80       	push   $0x8010aa0b
801047c1:	e8 46 bc ff ff       	call   8010040c <cprintf>
801047c6:	83 c4 10             	add    $0x10,%esp
    return -1;
801047c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047ce:	e9 e2 00 00 00       	jmp    801048b5 <printpt+0x131>
  }
  
  pde_t* pgdir = p->pgdir;
801047d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d6:	8b 40 04             	mov    0x4(%eax),%eax
801047d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint va;
  // walkpgdir은 pgdir에서 va(가상주소)가 위치한 페이지 테이블 엔트리를 반환한다.
  cprintf("START PAGE TABLE (pid %d) \n", pid);
801047dc:	83 ec 08             	sub    $0x8,%esp
801047df:	ff 75 08             	push   0x8(%ebp)
801047e2:	68 27 aa 10 80       	push   $0x8010aa27
801047e7:	e8 20 bc ff ff       	call   8010040c <cprintf>
801047ec:	83 c4 10             	add    $0x10,%esp
  // 페이지 테이블 엔트리를 한 줄씩 출력
  // xv6에서는 pagesize를 4KB로 설정 PGSIZE == 4096 임
  for (va = 0; va < KERNBASE; va += PGSIZE)
801047ef:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047f6:	e9 9a 00 00 00       	jmp    80104895 <printpt+0x111>
  {
    // va가 속한 페이지 테이블 엔트리
    pte_t* pte = walkpgdir(pgdir, (void*) va, 0);
801047fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047fe:	83 ec 04             	sub    $0x4,%esp
80104801:	6a 00                	push   $0x0
80104803:	50                   	push   %eax
80104804:	ff 75 ec             	push   -0x14(%ebp)
80104807:	e8 d2 2e 00 00       	call   801076de <walkpgdir>
8010480c:	83 c4 10             	add    $0x10,%esp
8010480f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    // pte가 유효하지 않으면 패스
    if (!(*pte & PTE_P) || pte == 0) continue;
80104812:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104815:	8b 00                	mov    (%eax),%eax
80104817:	83 e0 01             	and    $0x1,%eax
8010481a:	85 c0                	test   %eax,%eax
8010481c:	74 6f                	je     8010488d <printpt+0x109>
8010481e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104822:	74 69                	je     8010488d <printpt+0x109>
    cprintf("pte: %x\n",pte);
80104824:	83 ec 08             	sub    $0x8,%esp
80104827:	ff 75 e8             	push   -0x18(%ebp)
8010482a:	68 43 aa 10 80       	push   $0x8010aa43
8010482f:	e8 d8 bb ff ff       	call   8010040c <cprintf>
80104834:	83 c4 10             	add    $0x10,%esp
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
      (*pte & PTE_W)?'W':'-', PTE_ADDR(*pte) >> 12); 
80104837:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010483a:	8b 00                	mov    (%eax),%eax
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
8010483c:	c1 e8 0c             	shr    $0xc,%eax
8010483f:	89 c2                	mov    %eax,%edx
      (*pte & PTE_W)?'W':'-', PTE_ADDR(*pte) >> 12); 
80104841:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104844:	8b 00                	mov    (%eax),%eax
80104846:	83 e0 02             	and    $0x2,%eax
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
80104849:	85 c0                	test   %eax,%eax
8010484b:	74 07                	je     80104854 <printpt+0xd0>
8010484d:	bb 57 00 00 00       	mov    $0x57,%ebx
80104852:	eb 05                	jmp    80104859 <printpt+0xd5>
80104854:	bb 2d 00 00 00       	mov    $0x2d,%ebx
80104859:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010485c:	8b 00                	mov    (%eax),%eax
8010485e:	83 e0 04             	and    $0x4,%eax
80104861:	85 c0                	test   %eax,%eax
80104863:	74 07                	je     8010486c <printpt+0xe8>
80104865:	b9 55 00 00 00       	mov    $0x55,%ecx
8010486a:	eb 05                	jmp    80104871 <printpt+0xed>
8010486c:	b9 4b 00 00 00       	mov    $0x4b,%ecx
80104871:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104874:	c1 e8 0c             	shr    $0xc,%eax
80104877:	83 ec 0c             	sub    $0xc,%esp
8010487a:	52                   	push   %edx
8010487b:	53                   	push   %ebx
8010487c:	51                   	push   %ecx
8010487d:	50                   	push   %eax
8010487e:	68 4c aa 10 80       	push   $0x8010aa4c
80104883:	e8 84 bb ff ff       	call   8010040c <cprintf>
80104888:	83 c4 20             	add    $0x20,%esp
8010488b:	eb 01                	jmp    8010488e <printpt+0x10a>
    if (!(*pte & PTE_P) || pte == 0) continue;
8010488d:	90                   	nop
  for (va = 0; va < KERNBASE; va += PGSIZE)
8010488e:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
80104895:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104898:	85 c0                	test   %eax,%eax
8010489a:	0f 89 5b ff ff ff    	jns    801047fb <printpt+0x77>
  }
  cprintf("END PAGE TABLE\n");
801048a0:	83 ec 0c             	sub    $0xc,%esp
801048a3:	68 5b aa 10 80       	push   $0x8010aa5b
801048a8:	e8 5f bb ff ff       	call   8010040c <cprintf>
801048ad:	83 c4 10             	add    $0x10,%esp
  return 0;
801048b0:	b8 00 00 00 00       	mov    $0x0,%eax
801048b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048b8:	c9                   	leave
801048b9:	c3                   	ret

801048ba <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801048ba:	f3 0f 1e fb          	endbr32
801048be:	55                   	push   %ebp
801048bf:	89 e5                	mov    %esp,%ebp
801048c1:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801048c4:	8b 45 08             	mov    0x8(%ebp),%eax
801048c7:	83 c0 04             	add    $0x4,%eax
801048ca:	83 ec 08             	sub    $0x8,%esp
801048cd:	68 95 aa 10 80       	push   $0x8010aa95
801048d2:	50                   	push   %eax
801048d3:	e8 4f 01 00 00       	call   80104a27 <initlock>
801048d8:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801048db:	8b 45 08             	mov    0x8(%ebp),%eax
801048de:	8b 55 0c             	mov    0xc(%ebp),%edx
801048e1:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801048e4:	8b 45 08             	mov    0x8(%ebp),%eax
801048e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801048ed:	8b 45 08             	mov    0x8(%ebp),%eax
801048f0:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801048f7:	90                   	nop
801048f8:	c9                   	leave
801048f9:	c3                   	ret

801048fa <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801048fa:	f3 0f 1e fb          	endbr32
801048fe:	55                   	push   %ebp
801048ff:	89 e5                	mov    %esp,%ebp
80104901:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104904:	8b 45 08             	mov    0x8(%ebp),%eax
80104907:	83 c0 04             	add    $0x4,%eax
8010490a:	83 ec 0c             	sub    $0xc,%esp
8010490d:	50                   	push   %eax
8010490e:	e8 3a 01 00 00       	call   80104a4d <acquire>
80104913:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104916:	eb 15                	jmp    8010492d <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80104918:	8b 45 08             	mov    0x8(%ebp),%eax
8010491b:	83 c0 04             	add    $0x4,%eax
8010491e:	83 ec 08             	sub    $0x8,%esp
80104921:	50                   	push   %eax
80104922:	ff 75 08             	push   0x8(%ebp)
80104925:	e8 9a fb ff ff       	call   801044c4 <sleep>
8010492a:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010492d:	8b 45 08             	mov    0x8(%ebp),%eax
80104930:	8b 00                	mov    (%eax),%eax
80104932:	85 c0                	test   %eax,%eax
80104934:	75 e2                	jne    80104918 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80104936:	8b 45 08             	mov    0x8(%ebp),%eax
80104939:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010493f:	e8 75 f2 ff ff       	call   80103bb9 <myproc>
80104944:	8b 50 10             	mov    0x10(%eax),%edx
80104947:	8b 45 08             	mov    0x8(%ebp),%eax
8010494a:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
8010494d:	8b 45 08             	mov    0x8(%ebp),%eax
80104950:	83 c0 04             	add    $0x4,%eax
80104953:	83 ec 0c             	sub    $0xc,%esp
80104956:	50                   	push   %eax
80104957:	e8 63 01 00 00       	call   80104abf <release>
8010495c:	83 c4 10             	add    $0x10,%esp
}
8010495f:	90                   	nop
80104960:	c9                   	leave
80104961:	c3                   	ret

80104962 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104962:	f3 0f 1e fb          	endbr32
80104966:	55                   	push   %ebp
80104967:	89 e5                	mov    %esp,%ebp
80104969:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010496c:	8b 45 08             	mov    0x8(%ebp),%eax
8010496f:	83 c0 04             	add    $0x4,%eax
80104972:	83 ec 0c             	sub    $0xc,%esp
80104975:	50                   	push   %eax
80104976:	e8 d2 00 00 00       	call   80104a4d <acquire>
8010497b:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
8010497e:	8b 45 08             	mov    0x8(%ebp),%eax
80104981:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104987:	8b 45 08             	mov    0x8(%ebp),%eax
8010498a:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104991:	83 ec 0c             	sub    $0xc,%esp
80104994:	ff 75 08             	push   0x8(%ebp)
80104997:	e8 17 fc ff ff       	call   801045b3 <wakeup>
8010499c:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
8010499f:	8b 45 08             	mov    0x8(%ebp),%eax
801049a2:	83 c0 04             	add    $0x4,%eax
801049a5:	83 ec 0c             	sub    $0xc,%esp
801049a8:	50                   	push   %eax
801049a9:	e8 11 01 00 00       	call   80104abf <release>
801049ae:	83 c4 10             	add    $0x10,%esp
}
801049b1:	90                   	nop
801049b2:	c9                   	leave
801049b3:	c3                   	ret

801049b4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801049b4:	f3 0f 1e fb          	endbr32
801049b8:	55                   	push   %ebp
801049b9:	89 e5                	mov    %esp,%ebp
801049bb:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
801049be:	8b 45 08             	mov    0x8(%ebp),%eax
801049c1:	83 c0 04             	add    $0x4,%eax
801049c4:	83 ec 0c             	sub    $0xc,%esp
801049c7:	50                   	push   %eax
801049c8:	e8 80 00 00 00       	call   80104a4d <acquire>
801049cd:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801049d0:	8b 45 08             	mov    0x8(%ebp),%eax
801049d3:	8b 00                	mov    (%eax),%eax
801049d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801049d8:	8b 45 08             	mov    0x8(%ebp),%eax
801049db:	83 c0 04             	add    $0x4,%eax
801049de:	83 ec 0c             	sub    $0xc,%esp
801049e1:	50                   	push   %eax
801049e2:	e8 d8 00 00 00       	call   80104abf <release>
801049e7:	83 c4 10             	add    $0x10,%esp
  return r;
801049ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801049ed:	c9                   	leave
801049ee:	c3                   	ret

801049ef <readeflags>:
{
801049ef:	55                   	push   %ebp
801049f0:	89 e5                	mov    %esp,%ebp
801049f2:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801049f5:	9c                   	pushf
801049f6:	58                   	pop    %eax
801049f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801049fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801049fd:	c9                   	leave
801049fe:	c3                   	ret

801049ff <cli>:
{
801049ff:	55                   	push   %ebp
80104a00:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104a02:	fa                   	cli
}
80104a03:	90                   	nop
80104a04:	5d                   	pop    %ebp
80104a05:	c3                   	ret

80104a06 <sti>:
{
80104a06:	55                   	push   %ebp
80104a07:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104a09:	fb                   	sti
}
80104a0a:	90                   	nop
80104a0b:	5d                   	pop    %ebp
80104a0c:	c3                   	ret

80104a0d <xchg>:
{
80104a0d:	55                   	push   %ebp
80104a0e:	89 e5                	mov    %esp,%ebp
80104a10:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104a13:	8b 55 08             	mov    0x8(%ebp),%edx
80104a16:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a19:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a1c:	f0 87 02             	lock xchg %eax,(%edx)
80104a1f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104a22:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a25:	c9                   	leave
80104a26:	c3                   	ret

80104a27 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104a27:	f3 0f 1e fb          	endbr32
80104a2b:	55                   	push   %ebp
80104a2c:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a31:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a34:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104a37:	8b 45 08             	mov    0x8(%ebp),%eax
80104a3a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104a40:	8b 45 08             	mov    0x8(%ebp),%eax
80104a43:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104a4a:	90                   	nop
80104a4b:	5d                   	pop    %ebp
80104a4c:	c3                   	ret

80104a4d <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104a4d:	f3 0f 1e fb          	endbr32
80104a51:	55                   	push   %ebp
80104a52:	89 e5                	mov    %esp,%ebp
80104a54:	53                   	push   %ebx
80104a55:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104a58:	e8 6c 01 00 00       	call   80104bc9 <pushcli>
  if(holding(lk)){
80104a5d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a60:	83 ec 0c             	sub    $0xc,%esp
80104a63:	50                   	push   %eax
80104a64:	e8 2b 01 00 00       	call   80104b94 <holding>
80104a69:	83 c4 10             	add    $0x10,%esp
80104a6c:	85 c0                	test   %eax,%eax
80104a6e:	74 0d                	je     80104a7d <acquire+0x30>
    panic("acquire");
80104a70:	83 ec 0c             	sub    $0xc,%esp
80104a73:	68 a0 aa 10 80       	push   $0x8010aaa0
80104a78:	e8 61 bb ff ff       	call   801005de <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104a7d:	90                   	nop
80104a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a81:	83 ec 08             	sub    $0x8,%esp
80104a84:	6a 01                	push   $0x1
80104a86:	50                   	push   %eax
80104a87:	e8 81 ff ff ff       	call   80104a0d <xchg>
80104a8c:	83 c4 10             	add    $0x10,%esp
80104a8f:	85 c0                	test   %eax,%eax
80104a91:	75 eb                	jne    80104a7e <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104a93:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104a98:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104a9b:	e8 9d f0 ff ff       	call   80103b3d <mycpu>
80104aa0:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa6:	83 c0 0c             	add    $0xc,%eax
80104aa9:	83 ec 08             	sub    $0x8,%esp
80104aac:	50                   	push   %eax
80104aad:	8d 45 08             	lea    0x8(%ebp),%eax
80104ab0:	50                   	push   %eax
80104ab1:	e8 5f 00 00 00       	call   80104b15 <getcallerpcs>
80104ab6:	83 c4 10             	add    $0x10,%esp
}
80104ab9:	90                   	nop
80104aba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104abd:	c9                   	leave
80104abe:	c3                   	ret

80104abf <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104abf:	f3 0f 1e fb          	endbr32
80104ac3:	55                   	push   %ebp
80104ac4:	89 e5                	mov    %esp,%ebp
80104ac6:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104ac9:	83 ec 0c             	sub    $0xc,%esp
80104acc:	ff 75 08             	push   0x8(%ebp)
80104acf:	e8 c0 00 00 00       	call   80104b94 <holding>
80104ad4:	83 c4 10             	add    $0x10,%esp
80104ad7:	85 c0                	test   %eax,%eax
80104ad9:	75 0d                	jne    80104ae8 <release+0x29>
    panic("release");
80104adb:	83 ec 0c             	sub    $0xc,%esp
80104ade:	68 a8 aa 10 80       	push   $0x8010aaa8
80104ae3:	e8 f6 ba ff ff       	call   801005de <panic>

  lk->pcs[0] = 0;
80104ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80104aeb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104af2:	8b 45 08             	mov    0x8(%ebp),%eax
80104af5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104afc:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104b01:	8b 45 08             	mov    0x8(%ebp),%eax
80104b04:	8b 55 08             	mov    0x8(%ebp),%edx
80104b07:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104b0d:	e8 08 01 00 00       	call   80104c1a <popcli>
}
80104b12:	90                   	nop
80104b13:	c9                   	leave
80104b14:	c3                   	ret

80104b15 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104b15:	f3 0f 1e fb          	endbr32
80104b19:	55                   	push   %ebp
80104b1a:	89 e5                	mov    %esp,%ebp
80104b1c:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b22:	83 e8 08             	sub    $0x8,%eax
80104b25:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104b28:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104b2f:	eb 38                	jmp    80104b69 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104b31:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104b35:	74 53                	je     80104b8a <getcallerpcs+0x75>
80104b37:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104b3e:	76 4a                	jbe    80104b8a <getcallerpcs+0x75>
80104b40:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104b44:	74 44                	je     80104b8a <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104b46:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b49:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104b50:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b53:	01 c2                	add    %eax,%edx
80104b55:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b58:	8b 40 04             	mov    0x4(%eax),%eax
80104b5b:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104b5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b60:	8b 00                	mov    (%eax),%eax
80104b62:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104b65:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104b69:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104b6d:	7e c2                	jle    80104b31 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80104b6f:	eb 19                	jmp    80104b8a <getcallerpcs+0x75>
    pcs[i] = 0;
80104b71:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b74:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b7e:	01 d0                	add    %edx,%eax
80104b80:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104b86:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104b8a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104b8e:	7e e1                	jle    80104b71 <getcallerpcs+0x5c>
}
80104b90:	90                   	nop
80104b91:	90                   	nop
80104b92:	c9                   	leave
80104b93:	c3                   	ret

80104b94 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104b94:	f3 0f 1e fb          	endbr32
80104b98:	55                   	push   %ebp
80104b99:	89 e5                	mov    %esp,%ebp
80104b9b:	53                   	push   %ebx
80104b9c:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba2:	8b 00                	mov    (%eax),%eax
80104ba4:	85 c0                	test   %eax,%eax
80104ba6:	74 16                	je     80104bbe <holding+0x2a>
80104ba8:	8b 45 08             	mov    0x8(%ebp),%eax
80104bab:	8b 58 08             	mov    0x8(%eax),%ebx
80104bae:	e8 8a ef ff ff       	call   80103b3d <mycpu>
80104bb3:	39 c3                	cmp    %eax,%ebx
80104bb5:	75 07                	jne    80104bbe <holding+0x2a>
80104bb7:	b8 01 00 00 00       	mov    $0x1,%eax
80104bbc:	eb 05                	jmp    80104bc3 <holding+0x2f>
80104bbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104bc3:	83 c4 04             	add    $0x4,%esp
80104bc6:	5b                   	pop    %ebx
80104bc7:	5d                   	pop    %ebp
80104bc8:	c3                   	ret

80104bc9 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104bc9:	f3 0f 1e fb          	endbr32
80104bcd:	55                   	push   %ebp
80104bce:	89 e5                	mov    %esp,%ebp
80104bd0:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104bd3:	e8 17 fe ff ff       	call   801049ef <readeflags>
80104bd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104bdb:	e8 1f fe ff ff       	call   801049ff <cli>
  if(mycpu()->ncli == 0)
80104be0:	e8 58 ef ff ff       	call   80103b3d <mycpu>
80104be5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104beb:	85 c0                	test   %eax,%eax
80104bed:	75 14                	jne    80104c03 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104bef:	e8 49 ef ff ff       	call   80103b3d <mycpu>
80104bf4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bf7:	81 e2 00 02 00 00    	and    $0x200,%edx
80104bfd:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104c03:	e8 35 ef ff ff       	call   80103b3d <mycpu>
80104c08:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104c0e:	83 c2 01             	add    $0x1,%edx
80104c11:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104c17:	90                   	nop
80104c18:	c9                   	leave
80104c19:	c3                   	ret

80104c1a <popcli>:

void
popcli(void)
{
80104c1a:	f3 0f 1e fb          	endbr32
80104c1e:	55                   	push   %ebp
80104c1f:	89 e5                	mov    %esp,%ebp
80104c21:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104c24:	e8 c6 fd ff ff       	call   801049ef <readeflags>
80104c29:	25 00 02 00 00       	and    $0x200,%eax
80104c2e:	85 c0                	test   %eax,%eax
80104c30:	74 0d                	je     80104c3f <popcli+0x25>
    panic("popcli - interruptible");
80104c32:	83 ec 0c             	sub    $0xc,%esp
80104c35:	68 b0 aa 10 80       	push   $0x8010aab0
80104c3a:	e8 9f b9 ff ff       	call   801005de <panic>
  if(--mycpu()->ncli < 0)
80104c3f:	e8 f9 ee ff ff       	call   80103b3d <mycpu>
80104c44:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104c4a:	83 ea 01             	sub    $0x1,%edx
80104c4d:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104c53:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104c59:	85 c0                	test   %eax,%eax
80104c5b:	79 0d                	jns    80104c6a <popcli+0x50>
    panic("popcli");
80104c5d:	83 ec 0c             	sub    $0xc,%esp
80104c60:	68 c7 aa 10 80       	push   $0x8010aac7
80104c65:	e8 74 b9 ff ff       	call   801005de <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104c6a:	e8 ce ee ff ff       	call   80103b3d <mycpu>
80104c6f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104c75:	85 c0                	test   %eax,%eax
80104c77:	75 14                	jne    80104c8d <popcli+0x73>
80104c79:	e8 bf ee ff ff       	call   80103b3d <mycpu>
80104c7e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104c84:	85 c0                	test   %eax,%eax
80104c86:	74 05                	je     80104c8d <popcli+0x73>
    sti();
80104c88:	e8 79 fd ff ff       	call   80104a06 <sti>
}
80104c8d:	90                   	nop
80104c8e:	c9                   	leave
80104c8f:	c3                   	ret

80104c90 <stosb>:
{
80104c90:	55                   	push   %ebp
80104c91:	89 e5                	mov    %esp,%ebp
80104c93:	57                   	push   %edi
80104c94:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104c95:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104c98:	8b 55 10             	mov    0x10(%ebp),%edx
80104c9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c9e:	89 cb                	mov    %ecx,%ebx
80104ca0:	89 df                	mov    %ebx,%edi
80104ca2:	89 d1                	mov    %edx,%ecx
80104ca4:	fc                   	cld
80104ca5:	f3 aa                	rep stos %al,%es:(%edi)
80104ca7:	89 ca                	mov    %ecx,%edx
80104ca9:	89 fb                	mov    %edi,%ebx
80104cab:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104cae:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104cb1:	90                   	nop
80104cb2:	5b                   	pop    %ebx
80104cb3:	5f                   	pop    %edi
80104cb4:	5d                   	pop    %ebp
80104cb5:	c3                   	ret

80104cb6 <stosl>:
{
80104cb6:	55                   	push   %ebp
80104cb7:	89 e5                	mov    %esp,%ebp
80104cb9:	57                   	push   %edi
80104cba:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104cbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104cbe:	8b 55 10             	mov    0x10(%ebp),%edx
80104cc1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cc4:	89 cb                	mov    %ecx,%ebx
80104cc6:	89 df                	mov    %ebx,%edi
80104cc8:	89 d1                	mov    %edx,%ecx
80104cca:	fc                   	cld
80104ccb:	f3 ab                	rep stos %eax,%es:(%edi)
80104ccd:	89 ca                	mov    %ecx,%edx
80104ccf:	89 fb                	mov    %edi,%ebx
80104cd1:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104cd4:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104cd7:	90                   	nop
80104cd8:	5b                   	pop    %ebx
80104cd9:	5f                   	pop    %edi
80104cda:	5d                   	pop    %ebp
80104cdb:	c3                   	ret

80104cdc <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104cdc:	f3 0f 1e fb          	endbr32
80104ce0:	55                   	push   %ebp
80104ce1:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104ce3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce6:	83 e0 03             	and    $0x3,%eax
80104ce9:	85 c0                	test   %eax,%eax
80104ceb:	75 43                	jne    80104d30 <memset+0x54>
80104ced:	8b 45 10             	mov    0x10(%ebp),%eax
80104cf0:	83 e0 03             	and    $0x3,%eax
80104cf3:	85 c0                	test   %eax,%eax
80104cf5:	75 39                	jne    80104d30 <memset+0x54>
    c &= 0xFF;
80104cf7:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104cfe:	8b 45 10             	mov    0x10(%ebp),%eax
80104d01:	c1 e8 02             	shr    $0x2,%eax
80104d04:	89 c1                	mov    %eax,%ecx
80104d06:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d09:	c1 e0 18             	shl    $0x18,%eax
80104d0c:	89 c2                	mov    %eax,%edx
80104d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d11:	c1 e0 10             	shl    $0x10,%eax
80104d14:	09 c2                	or     %eax,%edx
80104d16:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d19:	c1 e0 08             	shl    $0x8,%eax
80104d1c:	09 d0                	or     %edx,%eax
80104d1e:	0b 45 0c             	or     0xc(%ebp),%eax
80104d21:	51                   	push   %ecx
80104d22:	50                   	push   %eax
80104d23:	ff 75 08             	push   0x8(%ebp)
80104d26:	e8 8b ff ff ff       	call   80104cb6 <stosl>
80104d2b:	83 c4 0c             	add    $0xc,%esp
80104d2e:	eb 12                	jmp    80104d42 <memset+0x66>
  } else
    stosb(dst, c, n);
80104d30:	8b 45 10             	mov    0x10(%ebp),%eax
80104d33:	50                   	push   %eax
80104d34:	ff 75 0c             	push   0xc(%ebp)
80104d37:	ff 75 08             	push   0x8(%ebp)
80104d3a:	e8 51 ff ff ff       	call   80104c90 <stosb>
80104d3f:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104d42:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104d45:	c9                   	leave
80104d46:	c3                   	ret

80104d47 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104d47:	f3 0f 1e fb          	endbr32
80104d4b:	55                   	push   %ebp
80104d4c:	89 e5                	mov    %esp,%ebp
80104d4e:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104d51:	8b 45 08             	mov    0x8(%ebp),%eax
80104d54:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104d57:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d5a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104d5d:	eb 30                	jmp    80104d8f <memcmp+0x48>
    if(*s1 != *s2)
80104d5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d62:	0f b6 10             	movzbl (%eax),%edx
80104d65:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104d68:	0f b6 00             	movzbl (%eax),%eax
80104d6b:	38 c2                	cmp    %al,%dl
80104d6d:	74 18                	je     80104d87 <memcmp+0x40>
      return *s1 - *s2;
80104d6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d72:	0f b6 00             	movzbl (%eax),%eax
80104d75:	0f b6 d0             	movzbl %al,%edx
80104d78:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104d7b:	0f b6 00             	movzbl (%eax),%eax
80104d7e:	0f b6 c0             	movzbl %al,%eax
80104d81:	29 c2                	sub    %eax,%edx
80104d83:	89 d0                	mov    %edx,%eax
80104d85:	eb 1a                	jmp    80104da1 <memcmp+0x5a>
    s1++, s2++;
80104d87:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104d8b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104d8f:	8b 45 10             	mov    0x10(%ebp),%eax
80104d92:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d95:	89 55 10             	mov    %edx,0x10(%ebp)
80104d98:	85 c0                	test   %eax,%eax
80104d9a:	75 c3                	jne    80104d5f <memcmp+0x18>
  }

  return 0;
80104d9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104da1:	c9                   	leave
80104da2:	c3                   	ret

80104da3 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104da3:	f3 0f 1e fb          	endbr32
80104da7:	55                   	push   %ebp
80104da8:	89 e5                	mov    %esp,%ebp
80104daa:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104dad:	8b 45 0c             	mov    0xc(%ebp),%eax
80104db0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104db3:	8b 45 08             	mov    0x8(%ebp),%eax
80104db6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104db9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dbc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104dbf:	73 54                	jae    80104e15 <memmove+0x72>
80104dc1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104dc4:	8b 45 10             	mov    0x10(%ebp),%eax
80104dc7:	01 d0                	add    %edx,%eax
80104dc9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104dcc:	73 47                	jae    80104e15 <memmove+0x72>
    s += n;
80104dce:	8b 45 10             	mov    0x10(%ebp),%eax
80104dd1:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104dd4:	8b 45 10             	mov    0x10(%ebp),%eax
80104dd7:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104dda:	eb 13                	jmp    80104def <memmove+0x4c>
      *--d = *--s;
80104ddc:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104de0:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104de4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104de7:	0f b6 10             	movzbl (%eax),%edx
80104dea:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ded:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104def:	8b 45 10             	mov    0x10(%ebp),%eax
80104df2:	8d 50 ff             	lea    -0x1(%eax),%edx
80104df5:	89 55 10             	mov    %edx,0x10(%ebp)
80104df8:	85 c0                	test   %eax,%eax
80104dfa:	75 e0                	jne    80104ddc <memmove+0x39>
  if(s < d && s + n > d){
80104dfc:	eb 24                	jmp    80104e22 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104dfe:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e01:	8d 42 01             	lea    0x1(%edx),%eax
80104e04:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104e07:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e0a:	8d 48 01             	lea    0x1(%eax),%ecx
80104e0d:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104e10:	0f b6 12             	movzbl (%edx),%edx
80104e13:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104e15:	8b 45 10             	mov    0x10(%ebp),%eax
80104e18:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e1b:	89 55 10             	mov    %edx,0x10(%ebp)
80104e1e:	85 c0                	test   %eax,%eax
80104e20:	75 dc                	jne    80104dfe <memmove+0x5b>

  return dst;
80104e22:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e25:	c9                   	leave
80104e26:	c3                   	ret

80104e27 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104e27:	f3 0f 1e fb          	endbr32
80104e2b:	55                   	push   %ebp
80104e2c:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104e2e:	ff 75 10             	push   0x10(%ebp)
80104e31:	ff 75 0c             	push   0xc(%ebp)
80104e34:	ff 75 08             	push   0x8(%ebp)
80104e37:	e8 67 ff ff ff       	call   80104da3 <memmove>
80104e3c:	83 c4 0c             	add    $0xc,%esp
}
80104e3f:	c9                   	leave
80104e40:	c3                   	ret

80104e41 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104e41:	f3 0f 1e fb          	endbr32
80104e45:	55                   	push   %ebp
80104e46:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104e48:	eb 0c                	jmp    80104e56 <strncmp+0x15>
    n--, p++, q++;
80104e4a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104e4e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104e52:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104e56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e5a:	74 1a                	je     80104e76 <strncmp+0x35>
80104e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80104e5f:	0f b6 00             	movzbl (%eax),%eax
80104e62:	84 c0                	test   %al,%al
80104e64:	74 10                	je     80104e76 <strncmp+0x35>
80104e66:	8b 45 08             	mov    0x8(%ebp),%eax
80104e69:	0f b6 10             	movzbl (%eax),%edx
80104e6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e6f:	0f b6 00             	movzbl (%eax),%eax
80104e72:	38 c2                	cmp    %al,%dl
80104e74:	74 d4                	je     80104e4a <strncmp+0x9>
  if(n == 0)
80104e76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e7a:	75 07                	jne    80104e83 <strncmp+0x42>
    return 0;
80104e7c:	b8 00 00 00 00       	mov    $0x0,%eax
80104e81:	eb 16                	jmp    80104e99 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80104e83:	8b 45 08             	mov    0x8(%ebp),%eax
80104e86:	0f b6 00             	movzbl (%eax),%eax
80104e89:	0f b6 d0             	movzbl %al,%edx
80104e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e8f:	0f b6 00             	movzbl (%eax),%eax
80104e92:	0f b6 c0             	movzbl %al,%eax
80104e95:	29 c2                	sub    %eax,%edx
80104e97:	89 d0                	mov    %edx,%eax
}
80104e99:	5d                   	pop    %ebp
80104e9a:	c3                   	ret

80104e9b <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104e9b:	f3 0f 1e fb          	endbr32
80104e9f:	55                   	push   %ebp
80104ea0:	89 e5                	mov    %esp,%ebp
80104ea2:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104eab:	90                   	nop
80104eac:	8b 45 10             	mov    0x10(%ebp),%eax
80104eaf:	8d 50 ff             	lea    -0x1(%eax),%edx
80104eb2:	89 55 10             	mov    %edx,0x10(%ebp)
80104eb5:	85 c0                	test   %eax,%eax
80104eb7:	7e 2c                	jle    80104ee5 <strncpy+0x4a>
80104eb9:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ebc:	8d 42 01             	lea    0x1(%edx),%eax
80104ebf:	89 45 0c             	mov    %eax,0xc(%ebp)
80104ec2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec5:	8d 48 01             	lea    0x1(%eax),%ecx
80104ec8:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104ecb:	0f b6 12             	movzbl (%edx),%edx
80104ece:	88 10                	mov    %dl,(%eax)
80104ed0:	0f b6 00             	movzbl (%eax),%eax
80104ed3:	84 c0                	test   %al,%al
80104ed5:	75 d5                	jne    80104eac <strncpy+0x11>
    ;
  while(n-- > 0)
80104ed7:	eb 0c                	jmp    80104ee5 <strncpy+0x4a>
    *s++ = 0;
80104ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80104edc:	8d 50 01             	lea    0x1(%eax),%edx
80104edf:	89 55 08             	mov    %edx,0x8(%ebp)
80104ee2:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104ee5:	8b 45 10             	mov    0x10(%ebp),%eax
80104ee8:	8d 50 ff             	lea    -0x1(%eax),%edx
80104eeb:	89 55 10             	mov    %edx,0x10(%ebp)
80104eee:	85 c0                	test   %eax,%eax
80104ef0:	7f e7                	jg     80104ed9 <strncpy+0x3e>
  return os;
80104ef2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ef5:	c9                   	leave
80104ef6:	c3                   	ret

80104ef7 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104ef7:	f3 0f 1e fb          	endbr32
80104efb:	55                   	push   %ebp
80104efc:	89 e5                	mov    %esp,%ebp
80104efe:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f01:	8b 45 08             	mov    0x8(%ebp),%eax
80104f04:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104f07:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f0b:	7f 05                	jg     80104f12 <safestrcpy+0x1b>
    return os;
80104f0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f10:	eb 31                	jmp    80104f43 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80104f12:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f16:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f1a:	7e 1e                	jle    80104f3a <safestrcpy+0x43>
80104f1c:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f1f:	8d 42 01             	lea    0x1(%edx),%eax
80104f22:	89 45 0c             	mov    %eax,0xc(%ebp)
80104f25:	8b 45 08             	mov    0x8(%ebp),%eax
80104f28:	8d 48 01             	lea    0x1(%eax),%ecx
80104f2b:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104f2e:	0f b6 12             	movzbl (%edx),%edx
80104f31:	88 10                	mov    %dl,(%eax)
80104f33:	0f b6 00             	movzbl (%eax),%eax
80104f36:	84 c0                	test   %al,%al
80104f38:	75 d8                	jne    80104f12 <safestrcpy+0x1b>
    ;
  *s = 0;
80104f3a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f3d:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104f40:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f43:	c9                   	leave
80104f44:	c3                   	ret

80104f45 <strlen>:

int
strlen(const char *s)
{
80104f45:	f3 0f 1e fb          	endbr32
80104f49:	55                   	push   %ebp
80104f4a:	89 e5                	mov    %esp,%ebp
80104f4c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104f4f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104f56:	eb 04                	jmp    80104f5c <strlen+0x17>
80104f58:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104f5c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f62:	01 d0                	add    %edx,%eax
80104f64:	0f b6 00             	movzbl (%eax),%eax
80104f67:	84 c0                	test   %al,%al
80104f69:	75 ed                	jne    80104f58 <strlen+0x13>
    ;
  return n;
80104f6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f6e:	c9                   	leave
80104f6f:	c3                   	ret

80104f70 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104f70:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104f74:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104f78:	55                   	push   %ebp
  pushl %ebx
80104f79:	53                   	push   %ebx
  pushl %esi
80104f7a:	56                   	push   %esi
  pushl %edi
80104f7b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104f7c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104f7e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104f80:	5f                   	pop    %edi
  popl %esi
80104f81:	5e                   	pop    %esi
  popl %ebx
80104f82:	5b                   	pop    %ebx
  popl %ebp
80104f83:	5d                   	pop    %ebp
  ret
80104f84:	c3                   	ret

80104f85 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104f85:	f3 0f 1e fb          	endbr32
80104f89:	55                   	push   %ebp
80104f8a:	89 e5                	mov    %esp,%ebp
  // sz가 stack영역은 포함하지 않게 설정되었기 때문에 kernbase로 변경
  // fetchstr, argptr도 동일
  if(addr >= KERNBASE || addr+4 >= KERNBASE)
80104f8c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f8f:	85 c0                	test   %eax,%eax
80104f91:	78 0a                	js     80104f9d <fetchint+0x18>
80104f93:	8b 45 08             	mov    0x8(%ebp),%eax
80104f96:	83 c0 04             	add    $0x4,%eax
80104f99:	85 c0                	test   %eax,%eax
80104f9b:	79 07                	jns    80104fa4 <fetchint+0x1f>
    return -1;
80104f9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fa2:	eb 0f                	jmp    80104fb3 <fetchint+0x2e>
  *ip = *(int*)(addr);
80104fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa7:	8b 10                	mov    (%eax),%edx
80104fa9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fac:	89 10                	mov    %edx,(%eax)
  return 0;
80104fae:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fb3:	5d                   	pop    %ebp
80104fb4:	c3                   	ret

80104fb5 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104fb5:	f3 0f 1e fb          	endbr32
80104fb9:	55                   	push   %ebp
80104fba:	89 e5                	mov    %esp,%ebp
80104fbc:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= KERNBASE)
80104fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc2:	85 c0                	test   %eax,%eax
80104fc4:	79 07                	jns    80104fcd <fetchstr+0x18>
    return -1;
80104fc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fcb:	eb 42                	jmp    8010500f <fetchstr+0x5a>
  *pp = (char*)addr;
80104fcd:	8b 55 08             	mov    0x8(%ebp),%edx
80104fd0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fd3:	89 10                	mov    %edx,(%eax)
  ep = (char*)(KERNBASE-1);
80104fd5:	c7 45 f8 ff ff ff 7f 	movl   $0x7fffffff,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
80104fdc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fdf:	8b 00                	mov    (%eax),%eax
80104fe1:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104fe4:	eb 1c                	jmp    80105002 <fetchstr+0x4d>
    if(*s == 0)
80104fe6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fe9:	0f b6 00             	movzbl (%eax),%eax
80104fec:	84 c0                	test   %al,%al
80104fee:	75 0e                	jne    80104ffe <fetchstr+0x49>
      return s - *pp;
80104ff0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ff3:	8b 00                	mov    (%eax),%eax
80104ff5:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ff8:	29 c2                	sub    %eax,%edx
80104ffa:	89 d0                	mov    %edx,%eax
80104ffc:	eb 11                	jmp    8010500f <fetchstr+0x5a>
  for(s = *pp; s < ep; s++){
80104ffe:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105002:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105005:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105008:	72 dc                	jb     80104fe6 <fetchstr+0x31>
  }
  return -1;
8010500a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010500f:	c9                   	leave
80105010:	c3                   	ret

80105011 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105011:	f3 0f 1e fb          	endbr32
80105015:	55                   	push   %ebp
80105016:	89 e5                	mov    %esp,%ebp
80105018:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010501b:	e8 99 eb ff ff       	call   80103bb9 <myproc>
80105020:	8b 40 18             	mov    0x18(%eax),%eax
80105023:	8b 40 44             	mov    0x44(%eax),%eax
80105026:	8b 55 08             	mov    0x8(%ebp),%edx
80105029:	c1 e2 02             	shl    $0x2,%edx
8010502c:	01 d0                	add    %edx,%eax
8010502e:	83 c0 04             	add    $0x4,%eax
80105031:	83 ec 08             	sub    $0x8,%esp
80105034:	ff 75 0c             	push   0xc(%ebp)
80105037:	50                   	push   %eax
80105038:	e8 48 ff ff ff       	call   80104f85 <fetchint>
8010503d:	83 c4 10             	add    $0x10,%esp
}
80105040:	c9                   	leave
80105041:	c3                   	ret

80105042 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105042:	f3 0f 1e fb          	endbr32
80105046:	55                   	push   %ebp
80105047:	89 e5                	mov    %esp,%ebp
80105049:	83 ec 18             	sub    $0x18,%esp
  int i;
 
  if(argint(n, &i) < 0)
8010504c:	83 ec 08             	sub    $0x8,%esp
8010504f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105052:	50                   	push   %eax
80105053:	ff 75 08             	push   0x8(%ebp)
80105056:	e8 b6 ff ff ff       	call   80105011 <argint>
8010505b:	83 c4 10             	add    $0x10,%esp
8010505e:	85 c0                	test   %eax,%eax
80105060:	79 07                	jns    80105069 <argptr+0x27>
    return -1;
80105062:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105067:	eb 34                	jmp    8010509d <argptr+0x5b>
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
80105069:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010506d:	78 18                	js     80105087 <argptr+0x45>
8010506f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105072:	85 c0                	test   %eax,%eax
80105074:	78 11                	js     80105087 <argptr+0x45>
80105076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105079:	89 c2                	mov    %eax,%edx
8010507b:	8b 45 10             	mov    0x10(%ebp),%eax
8010507e:	01 d0                	add    %edx,%eax
80105080:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80105085:	76 07                	jbe    8010508e <argptr+0x4c>
    return -1;
80105087:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010508c:	eb 0f                	jmp    8010509d <argptr+0x5b>
  *pp = (char*)i;
8010508e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105091:	89 c2                	mov    %eax,%edx
80105093:	8b 45 0c             	mov    0xc(%ebp),%eax
80105096:	89 10                	mov    %edx,(%eax)
  return 0;
80105098:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010509d:	c9                   	leave
8010509e:	c3                   	ret

8010509f <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010509f:	f3 0f 1e fb          	endbr32
801050a3:	55                   	push   %ebp
801050a4:	89 e5                	mov    %esp,%ebp
801050a6:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801050a9:	83 ec 08             	sub    $0x8,%esp
801050ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050af:	50                   	push   %eax
801050b0:	ff 75 08             	push   0x8(%ebp)
801050b3:	e8 59 ff ff ff       	call   80105011 <argint>
801050b8:	83 c4 10             	add    $0x10,%esp
801050bb:	85 c0                	test   %eax,%eax
801050bd:	79 07                	jns    801050c6 <argstr+0x27>
    return -1;
801050bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050c4:	eb 12                	jmp    801050d8 <argstr+0x39>
  return fetchstr(addr, pp);
801050c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c9:	83 ec 08             	sub    $0x8,%esp
801050cc:	ff 75 0c             	push   0xc(%ebp)
801050cf:	50                   	push   %eax
801050d0:	e8 e0 fe ff ff       	call   80104fb5 <fetchstr>
801050d5:	83 c4 10             	add    $0x10,%esp
}
801050d8:	c9                   	leave
801050d9:	c3                   	ret

801050da <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
801050da:	f3 0f 1e fb          	endbr32
801050de:	55                   	push   %ebp
801050df:	89 e5                	mov    %esp,%ebp
801050e1:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801050e4:	e8 d0 ea ff ff       	call   80103bb9 <myproc>
801050e9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801050ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ef:	8b 40 18             	mov    0x18(%eax),%eax
801050f2:	8b 40 1c             	mov    0x1c(%eax),%eax
801050f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801050f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801050fc:	7e 2f                	jle    8010512d <syscall+0x53>
801050fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105101:	83 f8 17             	cmp    $0x17,%eax
80105104:	77 27                	ja     8010512d <syscall+0x53>
80105106:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105109:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105110:	85 c0                	test   %eax,%eax
80105112:	74 19                	je     8010512d <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105114:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105117:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010511e:	ff d0                	call   *%eax
80105120:	89 c2                	mov    %eax,%edx
80105122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105125:	8b 40 18             	mov    0x18(%eax),%eax
80105128:	89 50 1c             	mov    %edx,0x1c(%eax)
8010512b:	eb 2c                	jmp    80105159 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010512d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105130:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105136:	8b 40 10             	mov    0x10(%eax),%eax
80105139:	ff 75 f0             	push   -0x10(%ebp)
8010513c:	52                   	push   %edx
8010513d:	50                   	push   %eax
8010513e:	68 ce aa 10 80       	push   $0x8010aace
80105143:	e8 c4 b2 ff ff       	call   8010040c <cprintf>
80105148:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
8010514b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010514e:	8b 40 18             	mov    0x18(%eax),%eax
80105151:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105158:	90                   	nop
80105159:	90                   	nop
8010515a:	c9                   	leave
8010515b:	c3                   	ret

8010515c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010515c:	f3 0f 1e fb          	endbr32
80105160:	55                   	push   %ebp
80105161:	89 e5                	mov    %esp,%ebp
80105163:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105166:	83 ec 08             	sub    $0x8,%esp
80105169:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010516c:	50                   	push   %eax
8010516d:	ff 75 08             	push   0x8(%ebp)
80105170:	e8 9c fe ff ff       	call   80105011 <argint>
80105175:	83 c4 10             	add    $0x10,%esp
80105178:	85 c0                	test   %eax,%eax
8010517a:	79 07                	jns    80105183 <argfd+0x27>
    return -1;
8010517c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105181:	eb 4f                	jmp    801051d2 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105183:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105186:	85 c0                	test   %eax,%eax
80105188:	78 20                	js     801051aa <argfd+0x4e>
8010518a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010518d:	83 f8 0f             	cmp    $0xf,%eax
80105190:	7f 18                	jg     801051aa <argfd+0x4e>
80105192:	e8 22 ea ff ff       	call   80103bb9 <myproc>
80105197:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010519a:	83 c2 08             	add    $0x8,%edx
8010519d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801051a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801051a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051a8:	75 07                	jne    801051b1 <argfd+0x55>
    return -1;
801051aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051af:	eb 21                	jmp    801051d2 <argfd+0x76>
  if(pfd)
801051b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801051b5:	74 08                	je     801051bf <argfd+0x63>
    *pfd = fd;
801051b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801051bd:	89 10                	mov    %edx,(%eax)
  if(pf)
801051bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051c3:	74 08                	je     801051cd <argfd+0x71>
    *pf = f;
801051c5:	8b 45 10             	mov    0x10(%ebp),%eax
801051c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801051cb:	89 10                	mov    %edx,(%eax)
  return 0;
801051cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051d2:	c9                   	leave
801051d3:	c3                   	ret

801051d4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801051d4:	f3 0f 1e fb          	endbr32
801051d8:	55                   	push   %ebp
801051d9:	89 e5                	mov    %esp,%ebp
801051db:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801051de:	e8 d6 e9 ff ff       	call   80103bb9 <myproc>
801051e3:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801051e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801051ed:	eb 2a                	jmp    80105219 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
801051ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801051f5:	83 c2 08             	add    $0x8,%edx
801051f8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801051fc:	85 c0                	test   %eax,%eax
801051fe:	75 15                	jne    80105215 <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105200:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105203:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105206:	8d 4a 08             	lea    0x8(%edx),%ecx
80105209:	8b 55 08             	mov    0x8(%ebp),%edx
8010520c:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105213:	eb 0f                	jmp    80105224 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105215:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105219:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010521d:	7e d0                	jle    801051ef <fdalloc+0x1b>
    }
  }
  return -1;
8010521f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105224:	c9                   	leave
80105225:	c3                   	ret

80105226 <sys_dup>:

int
sys_dup(void)
{
80105226:	f3 0f 1e fb          	endbr32
8010522a:	55                   	push   %ebp
8010522b:	89 e5                	mov    %esp,%ebp
8010522d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105230:	83 ec 04             	sub    $0x4,%esp
80105233:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105236:	50                   	push   %eax
80105237:	6a 00                	push   $0x0
80105239:	6a 00                	push   $0x0
8010523b:	e8 1c ff ff ff       	call   8010515c <argfd>
80105240:	83 c4 10             	add    $0x10,%esp
80105243:	85 c0                	test   %eax,%eax
80105245:	79 07                	jns    8010524e <sys_dup+0x28>
    return -1;
80105247:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010524c:	eb 31                	jmp    8010527f <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
8010524e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105251:	83 ec 0c             	sub    $0xc,%esp
80105254:	50                   	push   %eax
80105255:	e8 7a ff ff ff       	call   801051d4 <fdalloc>
8010525a:	83 c4 10             	add    $0x10,%esp
8010525d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105260:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105264:	79 07                	jns    8010526d <sys_dup+0x47>
    return -1;
80105266:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010526b:	eb 12                	jmp    8010527f <sys_dup+0x59>
  filedup(f);
8010526d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105270:	83 ec 0c             	sub    $0xc,%esp
80105273:	50                   	push   %eax
80105274:	e8 2b be ff ff       	call   801010a4 <filedup>
80105279:	83 c4 10             	add    $0x10,%esp
  return fd;
8010527c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010527f:	c9                   	leave
80105280:	c3                   	ret

80105281 <sys_read>:

int
sys_read(void)
{
80105281:	f3 0f 1e fb          	endbr32
80105285:	55                   	push   %ebp
80105286:	89 e5                	mov    %esp,%ebp
80105288:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010528b:	83 ec 04             	sub    $0x4,%esp
8010528e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105291:	50                   	push   %eax
80105292:	6a 00                	push   $0x0
80105294:	6a 00                	push   $0x0
80105296:	e8 c1 fe ff ff       	call   8010515c <argfd>
8010529b:	83 c4 10             	add    $0x10,%esp
8010529e:	85 c0                	test   %eax,%eax
801052a0:	78 2e                	js     801052d0 <sys_read+0x4f>
801052a2:	83 ec 08             	sub    $0x8,%esp
801052a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052a8:	50                   	push   %eax
801052a9:	6a 02                	push   $0x2
801052ab:	e8 61 fd ff ff       	call   80105011 <argint>
801052b0:	83 c4 10             	add    $0x10,%esp
801052b3:	85 c0                	test   %eax,%eax
801052b5:	78 19                	js     801052d0 <sys_read+0x4f>
801052b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052ba:	83 ec 04             	sub    $0x4,%esp
801052bd:	50                   	push   %eax
801052be:	8d 45 ec             	lea    -0x14(%ebp),%eax
801052c1:	50                   	push   %eax
801052c2:	6a 01                	push   $0x1
801052c4:	e8 79 fd ff ff       	call   80105042 <argptr>
801052c9:	83 c4 10             	add    $0x10,%esp
801052cc:	85 c0                	test   %eax,%eax
801052ce:	79 07                	jns    801052d7 <sys_read+0x56>
    return -1;
801052d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052d5:	eb 17                	jmp    801052ee <sys_read+0x6d>
  return fileread(f, p, n);
801052d7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801052da:	8b 55 ec             	mov    -0x14(%ebp),%edx
801052dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e0:	83 ec 04             	sub    $0x4,%esp
801052e3:	51                   	push   %ecx
801052e4:	52                   	push   %edx
801052e5:	50                   	push   %eax
801052e6:	e8 55 bf ff ff       	call   80101240 <fileread>
801052eb:	83 c4 10             	add    $0x10,%esp
}
801052ee:	c9                   	leave
801052ef:	c3                   	ret

801052f0 <sys_write>:

int
sys_write(void)
{
801052f0:	f3 0f 1e fb          	endbr32
801052f4:	55                   	push   %ebp
801052f5:	89 e5                	mov    %esp,%ebp
801052f7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801052fa:	83 ec 04             	sub    $0x4,%esp
801052fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105300:	50                   	push   %eax
80105301:	6a 00                	push   $0x0
80105303:	6a 00                	push   $0x0
80105305:	e8 52 fe ff ff       	call   8010515c <argfd>
8010530a:	83 c4 10             	add    $0x10,%esp
8010530d:	85 c0                	test   %eax,%eax
8010530f:	78 2e                	js     8010533f <sys_write+0x4f>
80105311:	83 ec 08             	sub    $0x8,%esp
80105314:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105317:	50                   	push   %eax
80105318:	6a 02                	push   $0x2
8010531a:	e8 f2 fc ff ff       	call   80105011 <argint>
8010531f:	83 c4 10             	add    $0x10,%esp
80105322:	85 c0                	test   %eax,%eax
80105324:	78 19                	js     8010533f <sys_write+0x4f>
80105326:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105329:	83 ec 04             	sub    $0x4,%esp
8010532c:	50                   	push   %eax
8010532d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105330:	50                   	push   %eax
80105331:	6a 01                	push   $0x1
80105333:	e8 0a fd ff ff       	call   80105042 <argptr>
80105338:	83 c4 10             	add    $0x10,%esp
8010533b:	85 c0                	test   %eax,%eax
8010533d:	79 07                	jns    80105346 <sys_write+0x56>
    return -1;
8010533f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105344:	eb 17                	jmp    8010535d <sys_write+0x6d>
  return filewrite(f, p, n);
80105346:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105349:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010534c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010534f:	83 ec 04             	sub    $0x4,%esp
80105352:	51                   	push   %ecx
80105353:	52                   	push   %edx
80105354:	50                   	push   %eax
80105355:	e8 a2 bf ff ff       	call   801012fc <filewrite>
8010535a:	83 c4 10             	add    $0x10,%esp
}
8010535d:	c9                   	leave
8010535e:	c3                   	ret

8010535f <sys_close>:

int
sys_close(void)
{
8010535f:	f3 0f 1e fb          	endbr32
80105363:	55                   	push   %ebp
80105364:	89 e5                	mov    %esp,%ebp
80105366:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105369:	83 ec 04             	sub    $0x4,%esp
8010536c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010536f:	50                   	push   %eax
80105370:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105373:	50                   	push   %eax
80105374:	6a 00                	push   $0x0
80105376:	e8 e1 fd ff ff       	call   8010515c <argfd>
8010537b:	83 c4 10             	add    $0x10,%esp
8010537e:	85 c0                	test   %eax,%eax
80105380:	79 07                	jns    80105389 <sys_close+0x2a>
    return -1;
80105382:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105387:	eb 27                	jmp    801053b0 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105389:	e8 2b e8 ff ff       	call   80103bb9 <myproc>
8010538e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105391:	83 c2 08             	add    $0x8,%edx
80105394:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010539b:	00 
  fileclose(f);
8010539c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010539f:	83 ec 0c             	sub    $0xc,%esp
801053a2:	50                   	push   %eax
801053a3:	e8 51 bd ff ff       	call   801010f9 <fileclose>
801053a8:	83 c4 10             	add    $0x10,%esp
  return 0;
801053ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053b0:	c9                   	leave
801053b1:	c3                   	ret

801053b2 <sys_fstat>:

int
sys_fstat(void)
{
801053b2:	f3 0f 1e fb          	endbr32
801053b6:	55                   	push   %ebp
801053b7:	89 e5                	mov    %esp,%ebp
801053b9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801053bc:	83 ec 04             	sub    $0x4,%esp
801053bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053c2:	50                   	push   %eax
801053c3:	6a 00                	push   $0x0
801053c5:	6a 00                	push   $0x0
801053c7:	e8 90 fd ff ff       	call   8010515c <argfd>
801053cc:	83 c4 10             	add    $0x10,%esp
801053cf:	85 c0                	test   %eax,%eax
801053d1:	78 17                	js     801053ea <sys_fstat+0x38>
801053d3:	83 ec 04             	sub    $0x4,%esp
801053d6:	6a 14                	push   $0x14
801053d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053db:	50                   	push   %eax
801053dc:	6a 01                	push   $0x1
801053de:	e8 5f fc ff ff       	call   80105042 <argptr>
801053e3:	83 c4 10             	add    $0x10,%esp
801053e6:	85 c0                	test   %eax,%eax
801053e8:	79 07                	jns    801053f1 <sys_fstat+0x3f>
    return -1;
801053ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053ef:	eb 13                	jmp    80105404 <sys_fstat+0x52>
  return filestat(f, st);
801053f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801053f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f7:	83 ec 08             	sub    $0x8,%esp
801053fa:	52                   	push   %edx
801053fb:	50                   	push   %eax
801053fc:	e8 e4 bd ff ff       	call   801011e5 <filestat>
80105401:	83 c4 10             	add    $0x10,%esp
}
80105404:	c9                   	leave
80105405:	c3                   	ret

80105406 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105406:	f3 0f 1e fb          	endbr32
8010540a:	55                   	push   %ebp
8010540b:	89 e5                	mov    %esp,%ebp
8010540d:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105410:	83 ec 08             	sub    $0x8,%esp
80105413:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105416:	50                   	push   %eax
80105417:	6a 00                	push   $0x0
80105419:	e8 81 fc ff ff       	call   8010509f <argstr>
8010541e:	83 c4 10             	add    $0x10,%esp
80105421:	85 c0                	test   %eax,%eax
80105423:	78 15                	js     8010543a <sys_link+0x34>
80105425:	83 ec 08             	sub    $0x8,%esp
80105428:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010542b:	50                   	push   %eax
8010542c:	6a 01                	push   $0x1
8010542e:	e8 6c fc ff ff       	call   8010509f <argstr>
80105433:	83 c4 10             	add    $0x10,%esp
80105436:	85 c0                	test   %eax,%eax
80105438:	79 0a                	jns    80105444 <sys_link+0x3e>
    return -1;
8010543a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010543f:	e9 68 01 00 00       	jmp    801055ac <sys_link+0x1a6>

  begin_op();
80105444:	e8 38 dd ff ff       	call   80103181 <begin_op>
  if((ip = namei(old)) == 0){
80105449:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010544c:	83 ec 0c             	sub    $0xc,%esp
8010544f:	50                   	push   %eax
80105450:	e8 a2 d1 ff ff       	call   801025f7 <namei>
80105455:	83 c4 10             	add    $0x10,%esp
80105458:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010545b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010545f:	75 0f                	jne    80105470 <sys_link+0x6a>
    end_op();
80105461:	e8 ab dd ff ff       	call   80103211 <end_op>
    return -1;
80105466:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010546b:	e9 3c 01 00 00       	jmp    801055ac <sys_link+0x1a6>
  }

  ilock(ip);
80105470:	83 ec 0c             	sub    $0xc,%esp
80105473:	ff 75 f4             	push   -0xc(%ebp)
80105476:	e8 11 c6 ff ff       	call   80101a8c <ilock>
8010547b:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010547e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105481:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105485:	66 83 f8 01          	cmp    $0x1,%ax
80105489:	75 1d                	jne    801054a8 <sys_link+0xa2>
    iunlockput(ip);
8010548b:	83 ec 0c             	sub    $0xc,%esp
8010548e:	ff 75 f4             	push   -0xc(%ebp)
80105491:	e8 33 c8 ff ff       	call   80101cc9 <iunlockput>
80105496:	83 c4 10             	add    $0x10,%esp
    end_op();
80105499:	e8 73 dd ff ff       	call   80103211 <end_op>
    return -1;
8010549e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054a3:	e9 04 01 00 00       	jmp    801055ac <sys_link+0x1a6>
  }

  ip->nlink++;
801054a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054ab:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801054af:	83 c0 01             	add    $0x1,%eax
801054b2:	89 c2                	mov    %eax,%edx
801054b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b7:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801054bb:	83 ec 0c             	sub    $0xc,%esp
801054be:	ff 75 f4             	push   -0xc(%ebp)
801054c1:	e8 dd c3 ff ff       	call   801018a3 <iupdate>
801054c6:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801054c9:	83 ec 0c             	sub    $0xc,%esp
801054cc:	ff 75 f4             	push   -0xc(%ebp)
801054cf:	e8 cf c6 ff ff       	call   80101ba3 <iunlock>
801054d4:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801054d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801054da:	83 ec 08             	sub    $0x8,%esp
801054dd:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801054e0:	52                   	push   %edx
801054e1:	50                   	push   %eax
801054e2:	e8 30 d1 ff ff       	call   80102617 <nameiparent>
801054e7:	83 c4 10             	add    $0x10,%esp
801054ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
801054ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054f1:	74 71                	je     80105564 <sys_link+0x15e>
    goto bad;
  ilock(dp);
801054f3:	83 ec 0c             	sub    $0xc,%esp
801054f6:	ff 75 f0             	push   -0x10(%ebp)
801054f9:	e8 8e c5 ff ff       	call   80101a8c <ilock>
801054fe:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105501:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105504:	8b 10                	mov    (%eax),%edx
80105506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105509:	8b 00                	mov    (%eax),%eax
8010550b:	39 c2                	cmp    %eax,%edx
8010550d:	75 1d                	jne    8010552c <sys_link+0x126>
8010550f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105512:	8b 40 04             	mov    0x4(%eax),%eax
80105515:	83 ec 04             	sub    $0x4,%esp
80105518:	50                   	push   %eax
80105519:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010551c:	50                   	push   %eax
8010551d:	ff 75 f0             	push   -0x10(%ebp)
80105520:	e8 2f ce ff ff       	call   80102354 <dirlink>
80105525:	83 c4 10             	add    $0x10,%esp
80105528:	85 c0                	test   %eax,%eax
8010552a:	79 10                	jns    8010553c <sys_link+0x136>
    iunlockput(dp);
8010552c:	83 ec 0c             	sub    $0xc,%esp
8010552f:	ff 75 f0             	push   -0x10(%ebp)
80105532:	e8 92 c7 ff ff       	call   80101cc9 <iunlockput>
80105537:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010553a:	eb 29                	jmp    80105565 <sys_link+0x15f>
  }
  iunlockput(dp);
8010553c:	83 ec 0c             	sub    $0xc,%esp
8010553f:	ff 75 f0             	push   -0x10(%ebp)
80105542:	e8 82 c7 ff ff       	call   80101cc9 <iunlockput>
80105547:	83 c4 10             	add    $0x10,%esp
  iput(ip);
8010554a:	83 ec 0c             	sub    $0xc,%esp
8010554d:	ff 75 f4             	push   -0xc(%ebp)
80105550:	e8 a0 c6 ff ff       	call   80101bf5 <iput>
80105555:	83 c4 10             	add    $0x10,%esp

  end_op();
80105558:	e8 b4 dc ff ff       	call   80103211 <end_op>

  return 0;
8010555d:	b8 00 00 00 00       	mov    $0x0,%eax
80105562:	eb 48                	jmp    801055ac <sys_link+0x1a6>
    goto bad;
80105564:	90                   	nop

bad:
  ilock(ip);
80105565:	83 ec 0c             	sub    $0xc,%esp
80105568:	ff 75 f4             	push   -0xc(%ebp)
8010556b:	e8 1c c5 ff ff       	call   80101a8c <ilock>
80105570:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105576:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010557a:	83 e8 01             	sub    $0x1,%eax
8010557d:	89 c2                	mov    %eax,%edx
8010557f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105582:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105586:	83 ec 0c             	sub    $0xc,%esp
80105589:	ff 75 f4             	push   -0xc(%ebp)
8010558c:	e8 12 c3 ff ff       	call   801018a3 <iupdate>
80105591:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105594:	83 ec 0c             	sub    $0xc,%esp
80105597:	ff 75 f4             	push   -0xc(%ebp)
8010559a:	e8 2a c7 ff ff       	call   80101cc9 <iunlockput>
8010559f:	83 c4 10             	add    $0x10,%esp
  end_op();
801055a2:	e8 6a dc ff ff       	call   80103211 <end_op>
  return -1;
801055a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055ac:	c9                   	leave
801055ad:	c3                   	ret

801055ae <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801055ae:	f3 0f 1e fb          	endbr32
801055b2:	55                   	push   %ebp
801055b3:	89 e5                	mov    %esp,%ebp
801055b5:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801055b8:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801055bf:	eb 40                	jmp    80105601 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801055c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c4:	6a 10                	push   $0x10
801055c6:	50                   	push   %eax
801055c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801055ca:	50                   	push   %eax
801055cb:	ff 75 08             	push   0x8(%ebp)
801055ce:	e8 c1 c9 ff ff       	call   80101f94 <readi>
801055d3:	83 c4 10             	add    $0x10,%esp
801055d6:	83 f8 10             	cmp    $0x10,%eax
801055d9:	74 0d                	je     801055e8 <isdirempty+0x3a>
      panic("isdirempty: readi");
801055db:	83 ec 0c             	sub    $0xc,%esp
801055de:	68 ea aa 10 80       	push   $0x8010aaea
801055e3:	e8 f6 af ff ff       	call   801005de <panic>
    if(de.inum != 0)
801055e8:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801055ec:	66 85 c0             	test   %ax,%ax
801055ef:	74 07                	je     801055f8 <isdirempty+0x4a>
      return 0;
801055f1:	b8 00 00 00 00       	mov    $0x0,%eax
801055f6:	eb 1b                	jmp    80105613 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801055f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055fb:	83 c0 10             	add    $0x10,%eax
801055fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105601:	8b 45 08             	mov    0x8(%ebp),%eax
80105604:	8b 50 58             	mov    0x58(%eax),%edx
80105607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560a:	39 c2                	cmp    %eax,%edx
8010560c:	77 b3                	ja     801055c1 <isdirempty+0x13>
  }
  return 1;
8010560e:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105613:	c9                   	leave
80105614:	c3                   	ret

80105615 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105615:	f3 0f 1e fb          	endbr32
80105619:	55                   	push   %ebp
8010561a:	89 e5                	mov    %esp,%ebp
8010561c:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010561f:	83 ec 08             	sub    $0x8,%esp
80105622:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105625:	50                   	push   %eax
80105626:	6a 00                	push   $0x0
80105628:	e8 72 fa ff ff       	call   8010509f <argstr>
8010562d:	83 c4 10             	add    $0x10,%esp
80105630:	85 c0                	test   %eax,%eax
80105632:	79 0a                	jns    8010563e <sys_unlink+0x29>
    return -1;
80105634:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105639:	e9 bf 01 00 00       	jmp    801057fd <sys_unlink+0x1e8>

  begin_op();
8010563e:	e8 3e db ff ff       	call   80103181 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105643:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105646:	83 ec 08             	sub    $0x8,%esp
80105649:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010564c:	52                   	push   %edx
8010564d:	50                   	push   %eax
8010564e:	e8 c4 cf ff ff       	call   80102617 <nameiparent>
80105653:	83 c4 10             	add    $0x10,%esp
80105656:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105659:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010565d:	75 0f                	jne    8010566e <sys_unlink+0x59>
    end_op();
8010565f:	e8 ad db ff ff       	call   80103211 <end_op>
    return -1;
80105664:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105669:	e9 8f 01 00 00       	jmp    801057fd <sys_unlink+0x1e8>
  }

  ilock(dp);
8010566e:	83 ec 0c             	sub    $0xc,%esp
80105671:	ff 75 f4             	push   -0xc(%ebp)
80105674:	e8 13 c4 ff ff       	call   80101a8c <ilock>
80105679:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010567c:	83 ec 08             	sub    $0x8,%esp
8010567f:	68 fc aa 10 80       	push   $0x8010aafc
80105684:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105687:	50                   	push   %eax
80105688:	e8 ea cb ff ff       	call   80102277 <namecmp>
8010568d:	83 c4 10             	add    $0x10,%esp
80105690:	85 c0                	test   %eax,%eax
80105692:	0f 84 49 01 00 00    	je     801057e1 <sys_unlink+0x1cc>
80105698:	83 ec 08             	sub    $0x8,%esp
8010569b:	68 fe aa 10 80       	push   $0x8010aafe
801056a0:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801056a3:	50                   	push   %eax
801056a4:	e8 ce cb ff ff       	call   80102277 <namecmp>
801056a9:	83 c4 10             	add    $0x10,%esp
801056ac:	85 c0                	test   %eax,%eax
801056ae:	0f 84 2d 01 00 00    	je     801057e1 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801056b4:	83 ec 04             	sub    $0x4,%esp
801056b7:	8d 45 c8             	lea    -0x38(%ebp),%eax
801056ba:	50                   	push   %eax
801056bb:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801056be:	50                   	push   %eax
801056bf:	ff 75 f4             	push   -0xc(%ebp)
801056c2:	e8 cf cb ff ff       	call   80102296 <dirlookup>
801056c7:	83 c4 10             	add    $0x10,%esp
801056ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
801056cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801056d1:	0f 84 0d 01 00 00    	je     801057e4 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
801056d7:	83 ec 0c             	sub    $0xc,%esp
801056da:	ff 75 f0             	push   -0x10(%ebp)
801056dd:	e8 aa c3 ff ff       	call   80101a8c <ilock>
801056e2:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801056e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056e8:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056ec:	66 85 c0             	test   %ax,%ax
801056ef:	7f 0d                	jg     801056fe <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
801056f1:	83 ec 0c             	sub    $0xc,%esp
801056f4:	68 01 ab 10 80       	push   $0x8010ab01
801056f9:	e8 e0 ae ff ff       	call   801005de <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801056fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105701:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105705:	66 83 f8 01          	cmp    $0x1,%ax
80105709:	75 25                	jne    80105730 <sys_unlink+0x11b>
8010570b:	83 ec 0c             	sub    $0xc,%esp
8010570e:	ff 75 f0             	push   -0x10(%ebp)
80105711:	e8 98 fe ff ff       	call   801055ae <isdirempty>
80105716:	83 c4 10             	add    $0x10,%esp
80105719:	85 c0                	test   %eax,%eax
8010571b:	75 13                	jne    80105730 <sys_unlink+0x11b>
    iunlockput(ip);
8010571d:	83 ec 0c             	sub    $0xc,%esp
80105720:	ff 75 f0             	push   -0x10(%ebp)
80105723:	e8 a1 c5 ff ff       	call   80101cc9 <iunlockput>
80105728:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010572b:	e9 b5 00 00 00       	jmp    801057e5 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105730:	83 ec 04             	sub    $0x4,%esp
80105733:	6a 10                	push   $0x10
80105735:	6a 00                	push   $0x0
80105737:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010573a:	50                   	push   %eax
8010573b:	e8 9c f5 ff ff       	call   80104cdc <memset>
80105740:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105743:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105746:	6a 10                	push   $0x10
80105748:	50                   	push   %eax
80105749:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010574c:	50                   	push   %eax
8010574d:	ff 75 f4             	push   -0xc(%ebp)
80105750:	e8 98 c9 ff ff       	call   801020ed <writei>
80105755:	83 c4 10             	add    $0x10,%esp
80105758:	83 f8 10             	cmp    $0x10,%eax
8010575b:	74 0d                	je     8010576a <sys_unlink+0x155>
    panic("unlink: writei");
8010575d:	83 ec 0c             	sub    $0xc,%esp
80105760:	68 13 ab 10 80       	push   $0x8010ab13
80105765:	e8 74 ae ff ff       	call   801005de <panic>
  if(ip->type == T_DIR){
8010576a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010576d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105771:	66 83 f8 01          	cmp    $0x1,%ax
80105775:	75 21                	jne    80105798 <sys_unlink+0x183>
    dp->nlink--;
80105777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010577a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010577e:	83 e8 01             	sub    $0x1,%eax
80105781:	89 c2                	mov    %eax,%edx
80105783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105786:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010578a:	83 ec 0c             	sub    $0xc,%esp
8010578d:	ff 75 f4             	push   -0xc(%ebp)
80105790:	e8 0e c1 ff ff       	call   801018a3 <iupdate>
80105795:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105798:	83 ec 0c             	sub    $0xc,%esp
8010579b:	ff 75 f4             	push   -0xc(%ebp)
8010579e:	e8 26 c5 ff ff       	call   80101cc9 <iunlockput>
801057a3:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801057a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057ad:	83 e8 01             	sub    $0x1,%eax
801057b0:	89 c2                	mov    %eax,%edx
801057b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057b5:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801057b9:	83 ec 0c             	sub    $0xc,%esp
801057bc:	ff 75 f0             	push   -0x10(%ebp)
801057bf:	e8 df c0 ff ff       	call   801018a3 <iupdate>
801057c4:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801057c7:	83 ec 0c             	sub    $0xc,%esp
801057ca:	ff 75 f0             	push   -0x10(%ebp)
801057cd:	e8 f7 c4 ff ff       	call   80101cc9 <iunlockput>
801057d2:	83 c4 10             	add    $0x10,%esp

  end_op();
801057d5:	e8 37 da ff ff       	call   80103211 <end_op>

  return 0;
801057da:	b8 00 00 00 00       	mov    $0x0,%eax
801057df:	eb 1c                	jmp    801057fd <sys_unlink+0x1e8>
    goto bad;
801057e1:	90                   	nop
801057e2:	eb 01                	jmp    801057e5 <sys_unlink+0x1d0>
    goto bad;
801057e4:	90                   	nop

bad:
  iunlockput(dp);
801057e5:	83 ec 0c             	sub    $0xc,%esp
801057e8:	ff 75 f4             	push   -0xc(%ebp)
801057eb:	e8 d9 c4 ff ff       	call   80101cc9 <iunlockput>
801057f0:	83 c4 10             	add    $0x10,%esp
  end_op();
801057f3:	e8 19 da ff ff       	call   80103211 <end_op>
  return -1;
801057f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057fd:	c9                   	leave
801057fe:	c3                   	ret

801057ff <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801057ff:	f3 0f 1e fb          	endbr32
80105803:	55                   	push   %ebp
80105804:	89 e5                	mov    %esp,%ebp
80105806:	83 ec 38             	sub    $0x38,%esp
80105809:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010580c:	8b 55 10             	mov    0x10(%ebp),%edx
8010580f:	8b 45 14             	mov    0x14(%ebp),%eax
80105812:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105816:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010581a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010581e:	83 ec 08             	sub    $0x8,%esp
80105821:	8d 45 de             	lea    -0x22(%ebp),%eax
80105824:	50                   	push   %eax
80105825:	ff 75 08             	push   0x8(%ebp)
80105828:	e8 ea cd ff ff       	call   80102617 <nameiparent>
8010582d:	83 c4 10             	add    $0x10,%esp
80105830:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105833:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105837:	75 0a                	jne    80105843 <create+0x44>
    return 0;
80105839:	b8 00 00 00 00       	mov    $0x0,%eax
8010583e:	e9 90 01 00 00       	jmp    801059d3 <create+0x1d4>
  ilock(dp);
80105843:	83 ec 0c             	sub    $0xc,%esp
80105846:	ff 75 f4             	push   -0xc(%ebp)
80105849:	e8 3e c2 ff ff       	call   80101a8c <ilock>
8010584e:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105851:	83 ec 04             	sub    $0x4,%esp
80105854:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105857:	50                   	push   %eax
80105858:	8d 45 de             	lea    -0x22(%ebp),%eax
8010585b:	50                   	push   %eax
8010585c:	ff 75 f4             	push   -0xc(%ebp)
8010585f:	e8 32 ca ff ff       	call   80102296 <dirlookup>
80105864:	83 c4 10             	add    $0x10,%esp
80105867:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010586a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010586e:	74 50                	je     801058c0 <create+0xc1>
    iunlockput(dp);
80105870:	83 ec 0c             	sub    $0xc,%esp
80105873:	ff 75 f4             	push   -0xc(%ebp)
80105876:	e8 4e c4 ff ff       	call   80101cc9 <iunlockput>
8010587b:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010587e:	83 ec 0c             	sub    $0xc,%esp
80105881:	ff 75 f0             	push   -0x10(%ebp)
80105884:	e8 03 c2 ff ff       	call   80101a8c <ilock>
80105889:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010588c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105891:	75 15                	jne    801058a8 <create+0xa9>
80105893:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105896:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010589a:	66 83 f8 02          	cmp    $0x2,%ax
8010589e:	75 08                	jne    801058a8 <create+0xa9>
      return ip;
801058a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a3:	e9 2b 01 00 00       	jmp    801059d3 <create+0x1d4>
    iunlockput(ip);
801058a8:	83 ec 0c             	sub    $0xc,%esp
801058ab:	ff 75 f0             	push   -0x10(%ebp)
801058ae:	e8 16 c4 ff ff       	call   80101cc9 <iunlockput>
801058b3:	83 c4 10             	add    $0x10,%esp
    return 0;
801058b6:	b8 00 00 00 00       	mov    $0x0,%eax
801058bb:	e9 13 01 00 00       	jmp    801059d3 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801058c0:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801058c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c7:	8b 00                	mov    (%eax),%eax
801058c9:	83 ec 08             	sub    $0x8,%esp
801058cc:	52                   	push   %edx
801058cd:	50                   	push   %eax
801058ce:	e8 f5 be ff ff       	call   801017c8 <ialloc>
801058d3:	83 c4 10             	add    $0x10,%esp
801058d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801058d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058dd:	75 0d                	jne    801058ec <create+0xed>
    panic("create: ialloc");
801058df:	83 ec 0c             	sub    $0xc,%esp
801058e2:	68 22 ab 10 80       	push   $0x8010ab22
801058e7:	e8 f2 ac ff ff       	call   801005de <panic>

  ilock(ip);
801058ec:	83 ec 0c             	sub    $0xc,%esp
801058ef:	ff 75 f0             	push   -0x10(%ebp)
801058f2:	e8 95 c1 ff ff       	call   80101a8c <ilock>
801058f7:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801058fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058fd:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105901:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105905:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105908:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010590c:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105910:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105913:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105919:	83 ec 0c             	sub    $0xc,%esp
8010591c:	ff 75 f0             	push   -0x10(%ebp)
8010591f:	e8 7f bf ff ff       	call   801018a3 <iupdate>
80105924:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105927:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010592c:	75 6a                	jne    80105998 <create+0x199>
    dp->nlink++;  // for ".."
8010592e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105931:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105935:	83 c0 01             	add    $0x1,%eax
80105938:	89 c2                	mov    %eax,%edx
8010593a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010593d:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105941:	83 ec 0c             	sub    $0xc,%esp
80105944:	ff 75 f4             	push   -0xc(%ebp)
80105947:	e8 57 bf ff ff       	call   801018a3 <iupdate>
8010594c:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010594f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105952:	8b 40 04             	mov    0x4(%eax),%eax
80105955:	83 ec 04             	sub    $0x4,%esp
80105958:	50                   	push   %eax
80105959:	68 fc aa 10 80       	push   $0x8010aafc
8010595e:	ff 75 f0             	push   -0x10(%ebp)
80105961:	e8 ee c9 ff ff       	call   80102354 <dirlink>
80105966:	83 c4 10             	add    $0x10,%esp
80105969:	85 c0                	test   %eax,%eax
8010596b:	78 1e                	js     8010598b <create+0x18c>
8010596d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105970:	8b 40 04             	mov    0x4(%eax),%eax
80105973:	83 ec 04             	sub    $0x4,%esp
80105976:	50                   	push   %eax
80105977:	68 fe aa 10 80       	push   $0x8010aafe
8010597c:	ff 75 f0             	push   -0x10(%ebp)
8010597f:	e8 d0 c9 ff ff       	call   80102354 <dirlink>
80105984:	83 c4 10             	add    $0x10,%esp
80105987:	85 c0                	test   %eax,%eax
80105989:	79 0d                	jns    80105998 <create+0x199>
      panic("create dots");
8010598b:	83 ec 0c             	sub    $0xc,%esp
8010598e:	68 31 ab 10 80       	push   $0x8010ab31
80105993:	e8 46 ac ff ff       	call   801005de <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105998:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010599b:	8b 40 04             	mov    0x4(%eax),%eax
8010599e:	83 ec 04             	sub    $0x4,%esp
801059a1:	50                   	push   %eax
801059a2:	8d 45 de             	lea    -0x22(%ebp),%eax
801059a5:	50                   	push   %eax
801059a6:	ff 75 f4             	push   -0xc(%ebp)
801059a9:	e8 a6 c9 ff ff       	call   80102354 <dirlink>
801059ae:	83 c4 10             	add    $0x10,%esp
801059b1:	85 c0                	test   %eax,%eax
801059b3:	79 0d                	jns    801059c2 <create+0x1c3>
    panic("create: dirlink");
801059b5:	83 ec 0c             	sub    $0xc,%esp
801059b8:	68 3d ab 10 80       	push   $0x8010ab3d
801059bd:	e8 1c ac ff ff       	call   801005de <panic>

  iunlockput(dp);
801059c2:	83 ec 0c             	sub    $0xc,%esp
801059c5:	ff 75 f4             	push   -0xc(%ebp)
801059c8:	e8 fc c2 ff ff       	call   80101cc9 <iunlockput>
801059cd:	83 c4 10             	add    $0x10,%esp

  return ip;
801059d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801059d3:	c9                   	leave
801059d4:	c3                   	ret

801059d5 <sys_open>:

int
sys_open(void)
{
801059d5:	f3 0f 1e fb          	endbr32
801059d9:	55                   	push   %ebp
801059da:	89 e5                	mov    %esp,%ebp
801059dc:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801059df:	83 ec 08             	sub    $0x8,%esp
801059e2:	8d 45 e8             	lea    -0x18(%ebp),%eax
801059e5:	50                   	push   %eax
801059e6:	6a 00                	push   $0x0
801059e8:	e8 b2 f6 ff ff       	call   8010509f <argstr>
801059ed:	83 c4 10             	add    $0x10,%esp
801059f0:	85 c0                	test   %eax,%eax
801059f2:	78 15                	js     80105a09 <sys_open+0x34>
801059f4:	83 ec 08             	sub    $0x8,%esp
801059f7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801059fa:	50                   	push   %eax
801059fb:	6a 01                	push   $0x1
801059fd:	e8 0f f6 ff ff       	call   80105011 <argint>
80105a02:	83 c4 10             	add    $0x10,%esp
80105a05:	85 c0                	test   %eax,%eax
80105a07:	79 0a                	jns    80105a13 <sys_open+0x3e>
    return -1;
80105a09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a0e:	e9 61 01 00 00       	jmp    80105b74 <sys_open+0x19f>

  begin_op();
80105a13:	e8 69 d7 ff ff       	call   80103181 <begin_op>

  if(omode & O_CREATE){
80105a18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a1b:	25 00 02 00 00       	and    $0x200,%eax
80105a20:	85 c0                	test   %eax,%eax
80105a22:	74 2a                	je     80105a4e <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80105a24:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a27:	6a 00                	push   $0x0
80105a29:	6a 00                	push   $0x0
80105a2b:	6a 02                	push   $0x2
80105a2d:	50                   	push   %eax
80105a2e:	e8 cc fd ff ff       	call   801057ff <create>
80105a33:	83 c4 10             	add    $0x10,%esp
80105a36:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105a39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a3d:	75 75                	jne    80105ab4 <sys_open+0xdf>
      end_op();
80105a3f:	e8 cd d7 ff ff       	call   80103211 <end_op>
      return -1;
80105a44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a49:	e9 26 01 00 00       	jmp    80105b74 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80105a4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a51:	83 ec 0c             	sub    $0xc,%esp
80105a54:	50                   	push   %eax
80105a55:	e8 9d cb ff ff       	call   801025f7 <namei>
80105a5a:	83 c4 10             	add    $0x10,%esp
80105a5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a60:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a64:	75 0f                	jne    80105a75 <sys_open+0xa0>
      end_op();
80105a66:	e8 a6 d7 ff ff       	call   80103211 <end_op>
      return -1;
80105a6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a70:	e9 ff 00 00 00       	jmp    80105b74 <sys_open+0x19f>
    }
    ilock(ip);
80105a75:	83 ec 0c             	sub    $0xc,%esp
80105a78:	ff 75 f4             	push   -0xc(%ebp)
80105a7b:	e8 0c c0 ff ff       	call   80101a8c <ilock>
80105a80:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a86:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a8a:	66 83 f8 01          	cmp    $0x1,%ax
80105a8e:	75 24                	jne    80105ab4 <sys_open+0xdf>
80105a90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a93:	85 c0                	test   %eax,%eax
80105a95:	74 1d                	je     80105ab4 <sys_open+0xdf>
      iunlockput(ip);
80105a97:	83 ec 0c             	sub    $0xc,%esp
80105a9a:	ff 75 f4             	push   -0xc(%ebp)
80105a9d:	e8 27 c2 ff ff       	call   80101cc9 <iunlockput>
80105aa2:	83 c4 10             	add    $0x10,%esp
      end_op();
80105aa5:	e8 67 d7 ff ff       	call   80103211 <end_op>
      return -1;
80105aaa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aaf:	e9 c0 00 00 00       	jmp    80105b74 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105ab4:	e8 7a b5 ff ff       	call   80101033 <filealloc>
80105ab9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105abc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ac0:	74 17                	je     80105ad9 <sys_open+0x104>
80105ac2:	83 ec 0c             	sub    $0xc,%esp
80105ac5:	ff 75 f0             	push   -0x10(%ebp)
80105ac8:	e8 07 f7 ff ff       	call   801051d4 <fdalloc>
80105acd:	83 c4 10             	add    $0x10,%esp
80105ad0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105ad3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105ad7:	79 2e                	jns    80105b07 <sys_open+0x132>
    if(f)
80105ad9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105add:	74 0e                	je     80105aed <sys_open+0x118>
      fileclose(f);
80105adf:	83 ec 0c             	sub    $0xc,%esp
80105ae2:	ff 75 f0             	push   -0x10(%ebp)
80105ae5:	e8 0f b6 ff ff       	call   801010f9 <fileclose>
80105aea:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105aed:	83 ec 0c             	sub    $0xc,%esp
80105af0:	ff 75 f4             	push   -0xc(%ebp)
80105af3:	e8 d1 c1 ff ff       	call   80101cc9 <iunlockput>
80105af8:	83 c4 10             	add    $0x10,%esp
    end_op();
80105afb:	e8 11 d7 ff ff       	call   80103211 <end_op>
    return -1;
80105b00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b05:	eb 6d                	jmp    80105b74 <sys_open+0x19f>
  }
  iunlock(ip);
80105b07:	83 ec 0c             	sub    $0xc,%esp
80105b0a:	ff 75 f4             	push   -0xc(%ebp)
80105b0d:	e8 91 c0 ff ff       	call   80101ba3 <iunlock>
80105b12:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b15:	e8 f7 d6 ff ff       	call   80103211 <end_op>

  f->type = FD_INODE;
80105b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b1d:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b26:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b29:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105b2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b2f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105b36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b39:	83 e0 01             	and    $0x1,%eax
80105b3c:	85 c0                	test   %eax,%eax
80105b3e:	0f 94 c0             	sete   %al
80105b41:	89 c2                	mov    %eax,%edx
80105b43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b46:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105b49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b4c:	83 e0 01             	and    $0x1,%eax
80105b4f:	85 c0                	test   %eax,%eax
80105b51:	75 0a                	jne    80105b5d <sys_open+0x188>
80105b53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b56:	83 e0 02             	and    $0x2,%eax
80105b59:	85 c0                	test   %eax,%eax
80105b5b:	74 07                	je     80105b64 <sys_open+0x18f>
80105b5d:	b8 01 00 00 00       	mov    $0x1,%eax
80105b62:	eb 05                	jmp    80105b69 <sys_open+0x194>
80105b64:	b8 00 00 00 00       	mov    $0x0,%eax
80105b69:	89 c2                	mov    %eax,%edx
80105b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6e:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105b71:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105b74:	c9                   	leave
80105b75:	c3                   	ret

80105b76 <sys_mkdir>:

int
sys_mkdir(void)
{
80105b76:	f3 0f 1e fb          	endbr32
80105b7a:	55                   	push   %ebp
80105b7b:	89 e5                	mov    %esp,%ebp
80105b7d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105b80:	e8 fc d5 ff ff       	call   80103181 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105b85:	83 ec 08             	sub    $0x8,%esp
80105b88:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b8b:	50                   	push   %eax
80105b8c:	6a 00                	push   $0x0
80105b8e:	e8 0c f5 ff ff       	call   8010509f <argstr>
80105b93:	83 c4 10             	add    $0x10,%esp
80105b96:	85 c0                	test   %eax,%eax
80105b98:	78 1b                	js     80105bb5 <sys_mkdir+0x3f>
80105b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b9d:	6a 00                	push   $0x0
80105b9f:	6a 00                	push   $0x0
80105ba1:	6a 01                	push   $0x1
80105ba3:	50                   	push   %eax
80105ba4:	e8 56 fc ff ff       	call   801057ff <create>
80105ba9:	83 c4 10             	add    $0x10,%esp
80105bac:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105baf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bb3:	75 0c                	jne    80105bc1 <sys_mkdir+0x4b>
    end_op();
80105bb5:	e8 57 d6 ff ff       	call   80103211 <end_op>
    return -1;
80105bba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bbf:	eb 18                	jmp    80105bd9 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105bc1:	83 ec 0c             	sub    $0xc,%esp
80105bc4:	ff 75 f4             	push   -0xc(%ebp)
80105bc7:	e8 fd c0 ff ff       	call   80101cc9 <iunlockput>
80105bcc:	83 c4 10             	add    $0x10,%esp
  end_op();
80105bcf:	e8 3d d6 ff ff       	call   80103211 <end_op>
  return 0;
80105bd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105bd9:	c9                   	leave
80105bda:	c3                   	ret

80105bdb <sys_mknod>:

int
sys_mknod(void)
{
80105bdb:	f3 0f 1e fb          	endbr32
80105bdf:	55                   	push   %ebp
80105be0:	89 e5                	mov    %esp,%ebp
80105be2:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105be5:	e8 97 d5 ff ff       	call   80103181 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105bea:	83 ec 08             	sub    $0x8,%esp
80105bed:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bf0:	50                   	push   %eax
80105bf1:	6a 00                	push   $0x0
80105bf3:	e8 a7 f4 ff ff       	call   8010509f <argstr>
80105bf8:	83 c4 10             	add    $0x10,%esp
80105bfb:	85 c0                	test   %eax,%eax
80105bfd:	78 4f                	js     80105c4e <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105bff:	83 ec 08             	sub    $0x8,%esp
80105c02:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c05:	50                   	push   %eax
80105c06:	6a 01                	push   $0x1
80105c08:	e8 04 f4 ff ff       	call   80105011 <argint>
80105c0d:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105c10:	85 c0                	test   %eax,%eax
80105c12:	78 3a                	js     80105c4e <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105c14:	83 ec 08             	sub    $0x8,%esp
80105c17:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c1a:	50                   	push   %eax
80105c1b:	6a 02                	push   $0x2
80105c1d:	e8 ef f3 ff ff       	call   80105011 <argint>
80105c22:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105c25:	85 c0                	test   %eax,%eax
80105c27:	78 25                	js     80105c4e <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105c29:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c2c:	0f bf c8             	movswl %ax,%ecx
80105c2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c32:	0f bf d0             	movswl %ax,%edx
80105c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c38:	51                   	push   %ecx
80105c39:	52                   	push   %edx
80105c3a:	6a 03                	push   $0x3
80105c3c:	50                   	push   %eax
80105c3d:	e8 bd fb ff ff       	call   801057ff <create>
80105c42:	83 c4 10             	add    $0x10,%esp
80105c45:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105c48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c4c:	75 0c                	jne    80105c5a <sys_mknod+0x7f>
    end_op();
80105c4e:	e8 be d5 ff ff       	call   80103211 <end_op>
    return -1;
80105c53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c58:	eb 18                	jmp    80105c72 <sys_mknod+0x97>
  }
  iunlockput(ip);
80105c5a:	83 ec 0c             	sub    $0xc,%esp
80105c5d:	ff 75 f4             	push   -0xc(%ebp)
80105c60:	e8 64 c0 ff ff       	call   80101cc9 <iunlockput>
80105c65:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c68:	e8 a4 d5 ff ff       	call   80103211 <end_op>
  return 0;
80105c6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c72:	c9                   	leave
80105c73:	c3                   	ret

80105c74 <sys_chdir>:

int
sys_chdir(void)
{
80105c74:	f3 0f 1e fb          	endbr32
80105c78:	55                   	push   %ebp
80105c79:	89 e5                	mov    %esp,%ebp
80105c7b:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105c7e:	e8 36 df ff ff       	call   80103bb9 <myproc>
80105c83:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105c86:	e8 f6 d4 ff ff       	call   80103181 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105c8b:	83 ec 08             	sub    $0x8,%esp
80105c8e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c91:	50                   	push   %eax
80105c92:	6a 00                	push   $0x0
80105c94:	e8 06 f4 ff ff       	call   8010509f <argstr>
80105c99:	83 c4 10             	add    $0x10,%esp
80105c9c:	85 c0                	test   %eax,%eax
80105c9e:	78 18                	js     80105cb8 <sys_chdir+0x44>
80105ca0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ca3:	83 ec 0c             	sub    $0xc,%esp
80105ca6:	50                   	push   %eax
80105ca7:	e8 4b c9 ff ff       	call   801025f7 <namei>
80105cac:	83 c4 10             	add    $0x10,%esp
80105caf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105cb2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cb6:	75 0c                	jne    80105cc4 <sys_chdir+0x50>
    end_op();
80105cb8:	e8 54 d5 ff ff       	call   80103211 <end_op>
    return -1;
80105cbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cc2:	eb 68                	jmp    80105d2c <sys_chdir+0xb8>
  }
  ilock(ip);
80105cc4:	83 ec 0c             	sub    $0xc,%esp
80105cc7:	ff 75 f0             	push   -0x10(%ebp)
80105cca:	e8 bd bd ff ff       	call   80101a8c <ilock>
80105ccf:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105cd9:	66 83 f8 01          	cmp    $0x1,%ax
80105cdd:	74 1a                	je     80105cf9 <sys_chdir+0x85>
    iunlockput(ip);
80105cdf:	83 ec 0c             	sub    $0xc,%esp
80105ce2:	ff 75 f0             	push   -0x10(%ebp)
80105ce5:	e8 df bf ff ff       	call   80101cc9 <iunlockput>
80105cea:	83 c4 10             	add    $0x10,%esp
    end_op();
80105ced:	e8 1f d5 ff ff       	call   80103211 <end_op>
    return -1;
80105cf2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cf7:	eb 33                	jmp    80105d2c <sys_chdir+0xb8>
  }
  iunlock(ip);
80105cf9:	83 ec 0c             	sub    $0xc,%esp
80105cfc:	ff 75 f0             	push   -0x10(%ebp)
80105cff:	e8 9f be ff ff       	call   80101ba3 <iunlock>
80105d04:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d0a:	8b 40 68             	mov    0x68(%eax),%eax
80105d0d:	83 ec 0c             	sub    $0xc,%esp
80105d10:	50                   	push   %eax
80105d11:	e8 df be ff ff       	call   80101bf5 <iput>
80105d16:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d19:	e8 f3 d4 ff ff       	call   80103211 <end_op>
  curproc->cwd = ip;
80105d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d21:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d24:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105d27:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d2c:	c9                   	leave
80105d2d:	c3                   	ret

80105d2e <sys_exec>:

int
sys_exec(void)
{
80105d2e:	f3 0f 1e fb          	endbr32
80105d32:	55                   	push   %ebp
80105d33:	89 e5                	mov    %esp,%ebp
80105d35:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105d3b:	83 ec 08             	sub    $0x8,%esp
80105d3e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d41:	50                   	push   %eax
80105d42:	6a 00                	push   $0x0
80105d44:	e8 56 f3 ff ff       	call   8010509f <argstr>
80105d49:	83 c4 10             	add    $0x10,%esp
80105d4c:	85 c0                	test   %eax,%eax
80105d4e:	78 18                	js     80105d68 <sys_exec+0x3a>
80105d50:	83 ec 08             	sub    $0x8,%esp
80105d53:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105d59:	50                   	push   %eax
80105d5a:	6a 01                	push   $0x1
80105d5c:	e8 b0 f2 ff ff       	call   80105011 <argint>
80105d61:	83 c4 10             	add    $0x10,%esp
80105d64:	85 c0                	test   %eax,%eax
80105d66:	79 0a                	jns    80105d72 <sys_exec+0x44>
    return -1;
80105d68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6d:	e9 c6 00 00 00       	jmp    80105e38 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80105d72:	83 ec 04             	sub    $0x4,%esp
80105d75:	68 80 00 00 00       	push   $0x80
80105d7a:	6a 00                	push   $0x0
80105d7c:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105d82:	50                   	push   %eax
80105d83:	e8 54 ef ff ff       	call   80104cdc <memset>
80105d88:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105d8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d95:	83 f8 1f             	cmp    $0x1f,%eax
80105d98:	76 0a                	jbe    80105da4 <sys_exec+0x76>
      return -1;
80105d9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d9f:	e9 94 00 00 00       	jmp    80105e38 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da7:	c1 e0 02             	shl    $0x2,%eax
80105daa:	89 c2                	mov    %eax,%edx
80105dac:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105db2:	01 c2                	add    %eax,%edx
80105db4:	83 ec 08             	sub    $0x8,%esp
80105db7:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105dbd:	50                   	push   %eax
80105dbe:	52                   	push   %edx
80105dbf:	e8 c1 f1 ff ff       	call   80104f85 <fetchint>
80105dc4:	83 c4 10             	add    $0x10,%esp
80105dc7:	85 c0                	test   %eax,%eax
80105dc9:	79 07                	jns    80105dd2 <sys_exec+0xa4>
      return -1;
80105dcb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dd0:	eb 66                	jmp    80105e38 <sys_exec+0x10a>
    if(uarg == 0){
80105dd2:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105dd8:	85 c0                	test   %eax,%eax
80105dda:	75 27                	jne    80105e03 <sys_exec+0xd5>
      argv[i] = 0;
80105ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddf:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105de6:	00 00 00 00 
      break;
80105dea:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105deb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dee:	83 ec 08             	sub    $0x8,%esp
80105df1:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105df7:	52                   	push   %edx
80105df8:	50                   	push   %eax
80105df9:	e8 d9 ad ff ff       	call   80100bd7 <exec>
80105dfe:	83 c4 10             	add    $0x10,%esp
80105e01:	eb 35                	jmp    80105e38 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80105e03:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e09:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e0c:	c1 e2 02             	shl    $0x2,%edx
80105e0f:	01 c2                	add    %eax,%edx
80105e11:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e17:	83 ec 08             	sub    $0x8,%esp
80105e1a:	52                   	push   %edx
80105e1b:	50                   	push   %eax
80105e1c:	e8 94 f1 ff ff       	call   80104fb5 <fetchstr>
80105e21:	83 c4 10             	add    $0x10,%esp
80105e24:	85 c0                	test   %eax,%eax
80105e26:	79 07                	jns    80105e2f <sys_exec+0x101>
      return -1;
80105e28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e2d:	eb 09                	jmp    80105e38 <sys_exec+0x10a>
  for(i=0;; i++){
80105e2f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e33:	e9 5a ff ff ff       	jmp    80105d92 <sys_exec+0x64>
}
80105e38:	c9                   	leave
80105e39:	c3                   	ret

80105e3a <sys_pipe>:

int
sys_pipe(void)
{
80105e3a:	f3 0f 1e fb          	endbr32
80105e3e:	55                   	push   %ebp
80105e3f:	89 e5                	mov    %esp,%ebp
80105e41:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105e44:	83 ec 04             	sub    $0x4,%esp
80105e47:	6a 08                	push   $0x8
80105e49:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e4c:	50                   	push   %eax
80105e4d:	6a 00                	push   $0x0
80105e4f:	e8 ee f1 ff ff       	call   80105042 <argptr>
80105e54:	83 c4 10             	add    $0x10,%esp
80105e57:	85 c0                	test   %eax,%eax
80105e59:	79 0a                	jns    80105e65 <sys_pipe+0x2b>
    return -1;
80105e5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e60:	e9 ae 00 00 00       	jmp    80105f13 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80105e65:	83 ec 08             	sub    $0x8,%esp
80105e68:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e6b:	50                   	push   %eax
80105e6c:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105e6f:	50                   	push   %eax
80105e70:	e8 65 d8 ff ff       	call   801036da <pipealloc>
80105e75:	83 c4 10             	add    $0x10,%esp
80105e78:	85 c0                	test   %eax,%eax
80105e7a:	79 0a                	jns    80105e86 <sys_pipe+0x4c>
    return -1;
80105e7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e81:	e9 8d 00 00 00       	jmp    80105f13 <sys_pipe+0xd9>
  fd0 = -1;
80105e86:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105e8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e90:	83 ec 0c             	sub    $0xc,%esp
80105e93:	50                   	push   %eax
80105e94:	e8 3b f3 ff ff       	call   801051d4 <fdalloc>
80105e99:	83 c4 10             	add    $0x10,%esp
80105e9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ea3:	78 18                	js     80105ebd <sys_pipe+0x83>
80105ea5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ea8:	83 ec 0c             	sub    $0xc,%esp
80105eab:	50                   	push   %eax
80105eac:	e8 23 f3 ff ff       	call   801051d4 <fdalloc>
80105eb1:	83 c4 10             	add    $0x10,%esp
80105eb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105eb7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ebb:	79 3e                	jns    80105efb <sys_pipe+0xc1>
    if(fd0 >= 0)
80105ebd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ec1:	78 13                	js     80105ed6 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80105ec3:	e8 f1 dc ff ff       	call   80103bb9 <myproc>
80105ec8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ecb:	83 c2 08             	add    $0x8,%edx
80105ece:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105ed5:	00 
    fileclose(rf);
80105ed6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ed9:	83 ec 0c             	sub    $0xc,%esp
80105edc:	50                   	push   %eax
80105edd:	e8 17 b2 ff ff       	call   801010f9 <fileclose>
80105ee2:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105ee5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ee8:	83 ec 0c             	sub    $0xc,%esp
80105eeb:	50                   	push   %eax
80105eec:	e8 08 b2 ff ff       	call   801010f9 <fileclose>
80105ef1:	83 c4 10             	add    $0x10,%esp
    return -1;
80105ef4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef9:	eb 18                	jmp    80105f13 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80105efb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105efe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f01:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105f03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f06:	8d 50 04             	lea    0x4(%eax),%edx
80105f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0c:	89 02                	mov    %eax,(%edx)
  return 0;
80105f0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f13:	c9                   	leave
80105f14:	c3                   	ret

80105f15 <sys_printpt>:
#include "mmu.h"
#include "proc.h"

int
sys_printpt(void)
{
80105f15:	f3 0f 1e fb          	endbr32
80105f19:	55                   	push   %ebp
80105f1a:	89 e5                	mov    %esp,%ebp
80105f1c:	83 ec 18             	sub    $0x18,%esp
  int pid;
  if (argint(0, &pid) < 0)
80105f1f:	83 ec 08             	sub    $0x8,%esp
80105f22:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f25:	50                   	push   %eax
80105f26:	6a 00                	push   $0x0
80105f28:	e8 e4 f0 ff ff       	call   80105011 <argint>
80105f2d:	83 c4 10             	add    $0x10,%esp
80105f30:	85 c0                	test   %eax,%eax
80105f32:	79 07                	jns    80105f3b <sys_printpt+0x26>
        return -1;
80105f34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f39:	eb 0f                	jmp    80105f4a <sys_printpt+0x35>
  return printpt(pid);
80105f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f3e:	83 ec 0c             	sub    $0xc,%esp
80105f41:	50                   	push   %eax
80105f42:	e8 3d e8 ff ff       	call   80104784 <printpt>
80105f47:	83 c4 10             	add    $0x10,%esp
}
80105f4a:	c9                   	leave
80105f4b:	c3                   	ret

80105f4c <sys_fork>:

int
sys_fork(void)
{
80105f4c:	f3 0f 1e fb          	endbr32
80105f50:	55                   	push   %ebp
80105f51:	89 e5                	mov    %esp,%ebp
80105f53:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105f56:	e8 81 df ff ff       	call   80103edc <fork>
}
80105f5b:	c9                   	leave
80105f5c:	c3                   	ret

80105f5d <sys_exit>:

int
sys_exit(void)
{
80105f5d:	f3 0f 1e fb          	endbr32
80105f61:	55                   	push   %ebp
80105f62:	89 e5                	mov    %esp,%ebp
80105f64:	83 ec 08             	sub    $0x8,%esp
  exit();
80105f67:	e8 ed e0 ff ff       	call   80104059 <exit>
  return 0;  // not reached
80105f6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f71:	c9                   	leave
80105f72:	c3                   	ret

80105f73 <sys_wait>:

int
sys_wait(void)
{
80105f73:	f3 0f 1e fb          	endbr32
80105f77:	55                   	push   %ebp
80105f78:	89 e5                	mov    %esp,%ebp
80105f7a:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105f7d:	e8 fb e1 ff ff       	call   8010417d <wait>
}
80105f82:	c9                   	leave
80105f83:	c3                   	ret

80105f84 <sys_uthread_init>:
int
sys_uthread_init(void)
{
80105f84:	f3 0f 1e fb          	endbr32
80105f88:	55                   	push   %ebp
80105f89:	89 e5                	mov    %esp,%ebp
80105f8b:	83 ec 18             	sub    $0x18,%esp
    // 시스템콜의 인자값을 받아온다.
    int address;
    if (argint(0, &address) < 0)
80105f8e:	83 ec 08             	sub    $0x8,%esp
80105f91:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f94:	50                   	push   %eax
80105f95:	6a 00                	push   $0x0
80105f97:	e8 75 f0 ff ff       	call   80105011 <argint>
80105f9c:	83 c4 10             	add    $0x10,%esp
80105f9f:	85 c0                	test   %eax,%eax
80105fa1:	79 07                	jns    80105faa <sys_uthread_init+0x26>
        return -1;
80105fa3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fa8:	eb 0f                	jmp    80105fb9 <sys_uthread_init+0x35>
    // proc.c의 uthread_init() 함수 호출
    return uthread_init(address);
80105faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fad:	83 ec 0c             	sub    $0xc,%esp
80105fb0:	50                   	push   %eax
80105fb1:	e8 a7 e3 ff ff       	call   8010435d <uthread_init>
80105fb6:	83 c4 10             	add    $0x10,%esp
}
80105fb9:	c9                   	leave
80105fba:	c3                   	ret

80105fbb <sys_kill>:

int
sys_kill(void)
{
80105fbb:	f3 0f 1e fb          	endbr32
80105fbf:	55                   	push   %ebp
80105fc0:	89 e5                	mov    %esp,%ebp
80105fc2:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105fc5:	83 ec 08             	sub    $0x8,%esp
80105fc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fcb:	50                   	push   %eax
80105fcc:	6a 00                	push   $0x0
80105fce:	e8 3e f0 ff ff       	call   80105011 <argint>
80105fd3:	83 c4 10             	add    $0x10,%esp
80105fd6:	85 c0                	test   %eax,%eax
80105fd8:	79 07                	jns    80105fe1 <sys_kill+0x26>
    return -1;
80105fda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fdf:	eb 0f                	jmp    80105ff0 <sys_kill+0x35>
  return kill(pid);
80105fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fe4:	83 ec 0c             	sub    $0xc,%esp
80105fe7:	50                   	push   %eax
80105fe8:	e8 01 e6 ff ff       	call   801045ee <kill>
80105fed:	83 c4 10             	add    $0x10,%esp
}
80105ff0:	c9                   	leave
80105ff1:	c3                   	ret

80105ff2 <sys_getpid>:

int
sys_getpid(void)
{
80105ff2:	f3 0f 1e fb          	endbr32
80105ff6:	55                   	push   %ebp
80105ff7:	89 e5                	mov    %esp,%ebp
80105ff9:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105ffc:	e8 b8 db ff ff       	call   80103bb9 <myproc>
80106001:	8b 40 10             	mov    0x10(%eax),%eax
}
80106004:	c9                   	leave
80106005:	c3                   	ret

80106006 <sys_sbrk>:

int
sys_sbrk(void)
{
80106006:	f3 0f 1e fb          	endbr32
8010600a:	55                   	push   %ebp
8010600b:	89 e5                	mov    %esp,%ebp
8010600d:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;
  struct proc* p = myproc();
80106010:	e8 a4 db ff ff       	call   80103bb9 <myproc>
80106015:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(argint(0, &n) < 0)
80106018:	83 ec 08             	sub    $0x8,%esp
8010601b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010601e:	50                   	push   %eax
8010601f:	6a 00                	push   $0x0
80106021:	e8 eb ef ff ff       	call   80105011 <argint>
80106026:	83 c4 10             	add    $0x10,%esp
80106029:	85 c0                	test   %eax,%eax
8010602b:	79 07                	jns    80106034 <sys_sbrk+0x2e>
    return -1;
8010602d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106032:	eb 74                	jmp    801060a8 <sys_sbrk+0xa2>
  // addr = 메모리를 늘리기 전 주소
  addr = p->sz;
80106034:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106037:	8b 00                	mov    (%eax),%eax
80106039:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // 메모리를 할당할 때는 lazy allocation을 위해 sz만 올림
  if (n > 0)
8010603c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010603f:	85 c0                	test   %eax,%eax
80106041:	7e 41                	jle    80106084 <sys_sbrk+0x7e>
  { 
    if ((p->sz + n) >= p->tf->esp){
80106043:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106046:	8b 00                	mov    (%eax),%eax
80106048:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010604b:	01 c2                	add    %eax,%edx
8010604d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106050:	8b 40 18             	mov    0x18(%eax),%eax
80106053:	8b 40 44             	mov    0x44(%eax),%eax
80106056:	39 c2                	cmp    %eax,%edx
80106058:	72 19                	jb     80106073 <sys_sbrk+0x6d>
      kill(p->pid);
8010605a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010605d:	8b 40 10             	mov    0x10(%eax),%eax
80106060:	83 ec 0c             	sub    $0xc,%esp
80106063:	50                   	push   %eax
80106064:	e8 85 e5 ff ff       	call   801045ee <kill>
80106069:	83 c4 10             	add    $0x10,%esp
      return -1;
8010606c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106071:	eb 35                	jmp    801060a8 <sys_sbrk+0xa2>
    }
    else
      p->sz += n;
80106073:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106076:	8b 00                	mov    (%eax),%eax
80106078:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010607b:	01 c2                	add    %eax,%edx
8010607d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106080:	89 10                	mov    %edx,(%eax)
80106082:	eb 21                	jmp    801060a5 <sys_sbrk+0x9f>
  }
  // 메모리 할당을 해제할 때는 바로 해제
  else if (n<0)
80106084:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106087:	85 c0                	test   %eax,%eax
80106089:	79 1a                	jns    801060a5 <sys_sbrk+0x9f>
  {
    if(growproc(n) < 0)
8010608b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010608e:	83 ec 0c             	sub    $0xc,%esp
80106091:	50                   	push   %eax
80106092:	e8 a6 dd ff ff       	call   80103e3d <growproc>
80106097:	83 c4 10             	add    $0x10,%esp
8010609a:	85 c0                	test   %eax,%eax
8010609c:	79 07                	jns    801060a5 <sys_sbrk+0x9f>
      return -1;
8010609e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a3:	eb 03                	jmp    801060a8 <sys_sbrk+0xa2>
  }
  
  return addr;
801060a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801060a8:	c9                   	leave
801060a9:	c3                   	ret

801060aa <sys_sleep>:

int
sys_sleep(void)
{
801060aa:	f3 0f 1e fb          	endbr32
801060ae:	55                   	push   %ebp
801060af:	89 e5                	mov    %esp,%ebp
801060b1:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801060b4:	83 ec 08             	sub    $0x8,%esp
801060b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060ba:	50                   	push   %eax
801060bb:	6a 00                	push   $0x0
801060bd:	e8 4f ef ff ff       	call   80105011 <argint>
801060c2:	83 c4 10             	add    $0x10,%esp
801060c5:	85 c0                	test   %eax,%eax
801060c7:	79 07                	jns    801060d0 <sys_sleep+0x26>
    return -1;
801060c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ce:	eb 76                	jmp    80106146 <sys_sleep+0x9c>
  acquire(&tickslock);
801060d0:	83 ec 0c             	sub    $0xc,%esp
801060d3:	68 40 75 19 80       	push   $0x80197540
801060d8:	e8 70 e9 ff ff       	call   80104a4d <acquire>
801060dd:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801060e0:	a1 80 7d 19 80       	mov    0x80197d80,%eax
801060e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801060e8:	eb 38                	jmp    80106122 <sys_sleep+0x78>
    if(myproc()->killed){
801060ea:	e8 ca da ff ff       	call   80103bb9 <myproc>
801060ef:	8b 40 24             	mov    0x24(%eax),%eax
801060f2:	85 c0                	test   %eax,%eax
801060f4:	74 17                	je     8010610d <sys_sleep+0x63>
      release(&tickslock);
801060f6:	83 ec 0c             	sub    $0xc,%esp
801060f9:	68 40 75 19 80       	push   $0x80197540
801060fe:	e8 bc e9 ff ff       	call   80104abf <release>
80106103:	83 c4 10             	add    $0x10,%esp
      return -1;
80106106:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010610b:	eb 39                	jmp    80106146 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
8010610d:	83 ec 08             	sub    $0x8,%esp
80106110:	68 40 75 19 80       	push   $0x80197540
80106115:	68 80 7d 19 80       	push   $0x80197d80
8010611a:	e8 a5 e3 ff ff       	call   801044c4 <sleep>
8010611f:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106122:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106127:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010612a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010612d:	39 d0                	cmp    %edx,%eax
8010612f:	72 b9                	jb     801060ea <sys_sleep+0x40>
  }
  release(&tickslock);
80106131:	83 ec 0c             	sub    $0xc,%esp
80106134:	68 40 75 19 80       	push   $0x80197540
80106139:	e8 81 e9 ff ff       	call   80104abf <release>
8010613e:	83 c4 10             	add    $0x10,%esp
  return 0;
80106141:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106146:	c9                   	leave
80106147:	c3                   	ret

80106148 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106148:	f3 0f 1e fb          	endbr32
8010614c:	55                   	push   %ebp
8010614d:	89 e5                	mov    %esp,%ebp
8010614f:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106152:	83 ec 0c             	sub    $0xc,%esp
80106155:	68 40 75 19 80       	push   $0x80197540
8010615a:	e8 ee e8 ff ff       	call   80104a4d <acquire>
8010615f:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106162:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106167:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010616a:	83 ec 0c             	sub    $0xc,%esp
8010616d:	68 40 75 19 80       	push   $0x80197540
80106172:	e8 48 e9 ff ff       	call   80104abf <release>
80106177:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010617a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010617d:	c9                   	leave
8010617e:	c3                   	ret

8010617f <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010617f:	1e                   	push   %ds
  pushl %es
80106180:	06                   	push   %es
  pushl %fs
80106181:	0f a0                	push   %fs
  pushl %gs
80106183:	0f a8                	push   %gs
  pushal
80106185:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106186:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010618a:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010618c:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010618e:	54                   	push   %esp
  call trap
8010618f:	e8 df 01 00 00       	call   80106373 <trap>
  addl $4, %esp
80106194:	83 c4 04             	add    $0x4,%esp

80106197 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106197:	61                   	popa
  popl %gs
80106198:	0f a9                	pop    %gs
  popl %fs
8010619a:	0f a1                	pop    %fs
  popl %es
8010619c:	07                   	pop    %es
  popl %ds
8010619d:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010619e:	83 c4 08             	add    $0x8,%esp
  iret
801061a1:	cf                   	iret

801061a2 <lidt>:
{
801061a2:	55                   	push   %ebp
801061a3:	89 e5                	mov    %esp,%ebp
801061a5:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801061a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801061ab:	83 e8 01             	sub    $0x1,%eax
801061ae:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801061b2:	8b 45 08             	mov    0x8(%ebp),%eax
801061b5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801061b9:	8b 45 08             	mov    0x8(%ebp),%eax
801061bc:	c1 e8 10             	shr    $0x10,%eax
801061bf:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801061c3:	8d 45 fa             	lea    -0x6(%ebp),%eax
801061c6:	0f 01 18             	lidtl  (%eax)
}
801061c9:	90                   	nop
801061ca:	c9                   	leave
801061cb:	c3                   	ret

801061cc <rcr2>:

static inline uint
rcr2(void)
{
801061cc:	55                   	push   %ebp
801061cd:	89 e5                	mov    %esp,%ebp
801061cf:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801061d2:	0f 20 d0             	mov    %cr2,%eax
801061d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801061d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801061db:	c9                   	leave
801061dc:	c3                   	ret

801061dd <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801061dd:	f3 0f 1e fb          	endbr32
801061e1:	55                   	push   %ebp
801061e2:	89 e5                	mov    %esp,%ebp
801061e4:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801061e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801061ee:	e9 c3 00 00 00       	jmp    801062b6 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801061f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f6:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801061fd:	89 c2                	mov    %eax,%edx
801061ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106202:	66 89 14 c5 80 75 19 	mov    %dx,-0x7fe68a80(,%eax,8)
80106209:	80 
8010620a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620d:	66 c7 04 c5 82 75 19 	movw   $0x8,-0x7fe68a7e(,%eax,8)
80106214:	80 08 00 
80106217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010621a:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
80106221:	80 
80106222:	83 e2 e0             	and    $0xffffffe0,%edx
80106225:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
8010622c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622f:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
80106236:	80 
80106237:	83 e2 1f             	and    $0x1f,%edx
8010623a:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
80106241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106244:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
8010624b:	80 
8010624c:	83 e2 f0             	and    $0xfffffff0,%edx
8010624f:	83 ca 0e             	or     $0xe,%edx
80106252:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
80106259:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010625c:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
80106263:	80 
80106264:	83 e2 ef             	and    $0xffffffef,%edx
80106267:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
8010626e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106271:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
80106278:	80 
80106279:	83 e2 9f             	and    $0xffffff9f,%edx
8010627c:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
80106283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106286:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
8010628d:	80 
8010628e:	83 ca 80             	or     $0xffffff80,%edx
80106291:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
80106298:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010629b:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801062a2:	c1 e8 10             	shr    $0x10,%eax
801062a5:	89 c2                	mov    %eax,%edx
801062a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062aa:	66 89 14 c5 86 75 19 	mov    %dx,-0x7fe68a7a(,%eax,8)
801062b1:	80 
  for(i = 0; i < 256; i++)
801062b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801062b6:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801062bd:	0f 8e 30 ff ff ff    	jle    801061f3 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801062c3:	a1 80 f1 10 80       	mov    0x8010f180,%eax
801062c8:	66 a3 80 77 19 80    	mov    %ax,0x80197780
801062ce:	66 c7 05 82 77 19 80 	movw   $0x8,0x80197782
801062d5:	08 00 
801062d7:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
801062de:	83 e0 e0             	and    $0xffffffe0,%eax
801062e1:	a2 84 77 19 80       	mov    %al,0x80197784
801062e6:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
801062ed:	83 e0 1f             	and    $0x1f,%eax
801062f0:	a2 84 77 19 80       	mov    %al,0x80197784
801062f5:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
801062fc:	83 c8 0f             	or     $0xf,%eax
801062ff:	a2 85 77 19 80       	mov    %al,0x80197785
80106304:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
8010630b:	83 e0 ef             	and    $0xffffffef,%eax
8010630e:	a2 85 77 19 80       	mov    %al,0x80197785
80106313:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
8010631a:	83 c8 60             	or     $0x60,%eax
8010631d:	a2 85 77 19 80       	mov    %al,0x80197785
80106322:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
80106329:	83 c8 80             	or     $0xffffff80,%eax
8010632c:	a2 85 77 19 80       	mov    %al,0x80197785
80106331:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106336:	c1 e8 10             	shr    $0x10,%eax
80106339:	66 a3 86 77 19 80    	mov    %ax,0x80197786

  initlock(&tickslock, "time");
8010633f:	83 ec 08             	sub    $0x8,%esp
80106342:	68 50 ab 10 80       	push   $0x8010ab50
80106347:	68 40 75 19 80       	push   $0x80197540
8010634c:	e8 d6 e6 ff ff       	call   80104a27 <initlock>
80106351:	83 c4 10             	add    $0x10,%esp
}
80106354:	90                   	nop
80106355:	c9                   	leave
80106356:	c3                   	ret

80106357 <idtinit>:

void
idtinit(void)
{
80106357:	f3 0f 1e fb          	endbr32
8010635b:	55                   	push   %ebp
8010635c:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010635e:	68 00 08 00 00       	push   $0x800
80106363:	68 80 75 19 80       	push   $0x80197580
80106368:	e8 35 fe ff ff       	call   801061a2 <lidt>
8010636d:	83 c4 08             	add    $0x8,%esp
}
80106370:	90                   	nop
80106371:	c9                   	leave
80106372:	c3                   	ret

80106373 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106373:	f3 0f 1e fb          	endbr32
80106377:	55                   	push   %ebp
80106378:	89 e5                	mov    %esp,%ebp
8010637a:	57                   	push   %edi
8010637b:	56                   	push   %esi
8010637c:	53                   	push   %ebx
8010637d:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106380:	8b 45 08             	mov    0x8(%ebp),%eax
80106383:	8b 40 30             	mov    0x30(%eax),%eax
80106386:	83 f8 40             	cmp    $0x40,%eax
80106389:	75 3b                	jne    801063c6 <trap+0x53>
    if(myproc()->killed)
8010638b:	e8 29 d8 ff ff       	call   80103bb9 <myproc>
80106390:	8b 40 24             	mov    0x24(%eax),%eax
80106393:	85 c0                	test   %eax,%eax
80106395:	74 05                	je     8010639c <trap+0x29>
      exit();
80106397:	e8 bd dc ff ff       	call   80104059 <exit>
    myproc()->tf = tf;
8010639c:	e8 18 d8 ff ff       	call   80103bb9 <myproc>
801063a1:	8b 55 08             	mov    0x8(%ebp),%edx
801063a4:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801063a7:	e8 2e ed ff ff       	call   801050da <syscall>
    if(myproc()->killed)
801063ac:	e8 08 d8 ff ff       	call   80103bb9 <myproc>
801063b1:	8b 40 24             	mov    0x24(%eax),%eax
801063b4:	85 c0                	test   %eax,%eax
801063b6:	0f 84 0a 03 00 00    	je     801066c6 <trap+0x353>
      exit();
801063bc:	e8 98 dc ff ff       	call   80104059 <exit>
    return;
801063c1:	e9 00 03 00 00       	jmp    801066c6 <trap+0x353>
  }

  switch(tf->trapno){
801063c6:	8b 45 08             	mov    0x8(%ebp),%eax
801063c9:	8b 40 30             	mov    0x30(%eax),%eax
801063cc:	83 e8 0e             	sub    $0xe,%eax
801063cf:	83 f8 31             	cmp    $0x31,%eax
801063d2:	0f 87 b9 01 00 00    	ja     80106591 <trap+0x21e>
801063d8:	8b 04 85 18 ac 10 80 	mov    -0x7fef53e8(,%eax,4),%eax
801063df:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801063e2:	e8 37 d7 ff ff       	call   80103b1e <cpuid>
801063e7:	85 c0                	test   %eax,%eax
801063e9:	75 3d                	jne    80106428 <trap+0xb5>
      acquire(&tickslock);
801063eb:	83 ec 0c             	sub    $0xc,%esp
801063ee:	68 40 75 19 80       	push   $0x80197540
801063f3:	e8 55 e6 ff ff       	call   80104a4d <acquire>
801063f8:	83 c4 10             	add    $0x10,%esp
      ticks++;
801063fb:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106400:	83 c0 01             	add    $0x1,%eax
80106403:	a3 80 7d 19 80       	mov    %eax,0x80197d80
      wakeup(&ticks);
80106408:	83 ec 0c             	sub    $0xc,%esp
8010640b:	68 80 7d 19 80       	push   $0x80197d80
80106410:	e8 9e e1 ff ff       	call   801045b3 <wakeup>
80106415:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106418:	83 ec 0c             	sub    $0xc,%esp
8010641b:	68 40 75 19 80       	push   $0x80197540
80106420:	e8 9a e6 ff ff       	call   80104abf <release>
80106425:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106428:	e8 08 c8 ff ff       	call   80102c35 <lapiceoi>


    break;
8010642d:	e9 14 02 00 00       	jmp    80106646 <trap+0x2d3>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106432:	e8 0a 41 00 00       	call   8010a541 <ideintr>
    lapiceoi();
80106437:	e8 f9 c7 ff ff       	call   80102c35 <lapiceoi>
    break;
8010643c:	e9 05 02 00 00       	jmp    80106646 <trap+0x2d3>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106441:	e8 25 c6 ff ff       	call   80102a6b <kbdintr>
    lapiceoi();
80106446:	e8 ea c7 ff ff       	call   80102c35 <lapiceoi>
    break;
8010644b:	e9 f6 01 00 00       	jmp    80106646 <trap+0x2d3>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106450:	e8 53 04 00 00       	call   801068a8 <uartintr>
    lapiceoi();
80106455:	e8 db c7 ff ff       	call   80102c35 <lapiceoi>
    break;
8010645a:	e9 e7 01 00 00       	jmp    80106646 <trap+0x2d3>
  case T_IRQ0 + 0xB:
    i8254_intr();
8010645f:	e8 1c 2d 00 00       	call   80109180 <i8254_intr>
    lapiceoi();
80106464:	e8 cc c7 ff ff       	call   80102c35 <lapiceoi>
    break;
80106469:	e9 d8 01 00 00       	jmp    80106646 <trap+0x2d3>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010646e:	8b 45 08             	mov    0x8(%ebp),%eax
80106471:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106474:	8b 45 08             	mov    0x8(%ebp),%eax
80106477:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010647b:	0f b7 d8             	movzwl %ax,%ebx
8010647e:	e8 9b d6 ff ff       	call   80103b1e <cpuid>
80106483:	56                   	push   %esi
80106484:	53                   	push   %ebx
80106485:	50                   	push   %eax
80106486:	68 58 ab 10 80       	push   $0x8010ab58
8010648b:	e8 7c 9f ff ff       	call   8010040c <cprintf>
80106490:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106493:	e8 9d c7 ff ff       	call   80102c35 <lapiceoi>
    break;
80106498:	e9 a9 01 00 00       	jmp    80106646 <trap+0x2d3>
  
    // page fault 발생 시 이 블록 실행
  case T_PGFLT:
    if(myproc()->killed)
8010649d:	e8 17 d7 ff ff       	call   80103bb9 <myproc>
801064a2:	8b 40 24             	mov    0x24(%eax),%eax
801064a5:	85 c0                	test   %eax,%eax
801064a7:	74 05                	je     801064ae <trap+0x13b>
      exit();
801064a9:	e8 ab db ff ff       	call   80104059 <exit>
    pde_t* pgdir;
    uint va;
    struct proc* p;
    char *mem;
    uint sp;
    p = myproc();
801064ae:	e8 06 d7 ff ff       	call   80103bb9 <myproc>
801064b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    // va = 페이지 폴트가 난 가상 주소의 페이지 시작 주소
    va = PGROUNDDOWN(rcr2());
801064b6:	e8 11 fd ff ff       	call   801061cc <rcr2>
801064bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801064c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pgdir = p->pgdir;
801064c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064c6:	8b 40 04             	mov    0x4(%eax),%eax
801064c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
    sp = p->tf->esp;
801064cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064cf:	8b 40 18             	mov    0x18(%eax),%eax
801064d2:	8b 40 44             	mov    0x44(%eax),%eax
801064d5:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // sz+PGSIZE보다 크면 비정상적인 힙 영역 접근
    // sp-PGSIZE보다 작으면 비정상적인 스택 접근
    if (va > p->sz + PGSIZE && va < sp - PGSIZE){
801064d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064db:	8b 00                	mov    (%eax),%eax
801064dd:	05 00 10 00 00       	add    $0x1000,%eax
801064e2:	39 45 e0             	cmp    %eax,-0x20(%ebp)
801064e5:	76 2f                	jbe    80106516 <trap+0x1a3>
801064e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801064ea:	2d 00 10 00 00       	sub    $0x1000,%eax
801064ef:	39 45 e0             	cmp    %eax,-0x20(%ebp)
801064f2:	73 22                	jae    80106516 <trap+0x1a3>
      cprintf("invaild access\n");
801064f4:	83 ec 0c             	sub    $0xc,%esp
801064f7:	68 7c ab 10 80       	push   $0x8010ab7c
801064fc:	e8 0b 9f ff ff       	call   8010040c <cprintf>
80106501:	83 c4 10             	add    $0x10,%esp
      kill(p->pid);
80106504:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106507:	8b 40 10             	mov    0x10(%eax),%eax
8010650a:	83 ec 0c             	sub    $0xc,%esp
8010650d:	50                   	push   %eax
8010650e:	e8 db e0 ff ff       	call   801045ee <kill>
80106513:	83 c4 10             	add    $0x10,%esp
    // 스택을 늘릴 때 sz보다 작아지면 메모리가 꽉 찬 것이다.
    // 힙을 늘리는 경우는 sbrk에서 처리
    // if ((sp = sp - PGSIZE) <= p->sz)
    //   kill(p->pid);
    // 새 페이지를 할당할 물리 주소 할당
    if ((mem = kalloc()) == 0){
80106516:	e8 87 c3 ff ff       	call   801028a2 <kalloc>
8010651b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010651e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80106522:	75 22                	jne    80106546 <trap+0x1d3>
      cprintf("out of memory\n");
80106524:	83 ec 0c             	sub    $0xc,%esp
80106527:	68 8c ab 10 80       	push   $0x8010ab8c
8010652c:	e8 db 9e ff ff       	call   8010040c <cprintf>
80106531:	83 c4 10             	add    $0x10,%esp
      kill(p->pid);
80106534:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106537:	8b 40 10             	mov    0x10(%eax),%eax
8010653a:	83 ec 0c             	sub    $0xc,%esp
8010653d:	50                   	push   %eax
8010653e:	e8 ab e0 ff ff       	call   801045ee <kill>
80106543:	83 c4 10             	add    $0x10,%esp
    }
    
    memset(mem, 0, PGSIZE);
80106546:	83 ec 04             	sub    $0x4,%esp
80106549:	68 00 10 00 00       	push   $0x1000
8010654e:	6a 00                	push   $0x0
80106550:	ff 75 d4             	push   -0x2c(%ebp)
80106553:	e8 84 e7 ff ff       	call   80104cdc <memset>
80106558:	83 c4 10             	add    $0x10,%esp

    // va 페이지 테이블에 매핑
    // 페이지 테이블 관련 처리는 mappages 안에서 자동으로 처리해줌
    mappages(pgdir, (void*)va, PGSIZE, V2P(mem), PTE_W|PTE_U|PTE_P);
8010655b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010655e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80106564:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106567:	83 ec 0c             	sub    $0xc,%esp
8010656a:	6a 07                	push   $0x7
8010656c:	52                   	push   %edx
8010656d:	68 00 10 00 00       	push   $0x1000
80106572:	50                   	push   %eax
80106573:	ff 75 dc             	push   -0x24(%ebp)
80106576:	e8 fd 11 00 00       	call   80107778 <mappages>
8010657b:	83 c4 20             	add    $0x20,%esp

    // flush
    switchuvm(p);
8010657e:	83 ec 0c             	sub    $0xc,%esp
80106581:	ff 75 e4             	push   -0x1c(%ebp)
80106584:	e8 ad 13 00 00       	call   80107936 <switchuvm>
80106589:	83 c4 10             	add    $0x10,%esp
    break;
8010658c:	e9 b5 00 00 00       	jmp    80106646 <trap+0x2d3>


  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106591:	e8 23 d6 ff ff       	call   80103bb9 <myproc>
80106596:	85 c0                	test   %eax,%eax
80106598:	74 11                	je     801065ab <trap+0x238>
8010659a:	8b 45 08             	mov    0x8(%ebp),%eax
8010659d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801065a1:	0f b7 c0             	movzwl %ax,%eax
801065a4:	83 e0 03             	and    $0x3,%eax
801065a7:	85 c0                	test   %eax,%eax
801065a9:	75 39                	jne    801065e4 <trap+0x271>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801065ab:	e8 1c fc ff ff       	call   801061cc <rcr2>
801065b0:	89 c3                	mov    %eax,%ebx
801065b2:	8b 45 08             	mov    0x8(%ebp),%eax
801065b5:	8b 70 38             	mov    0x38(%eax),%esi
801065b8:	e8 61 d5 ff ff       	call   80103b1e <cpuid>
801065bd:	8b 55 08             	mov    0x8(%ebp),%edx
801065c0:	8b 52 30             	mov    0x30(%edx),%edx
801065c3:	83 ec 0c             	sub    $0xc,%esp
801065c6:	53                   	push   %ebx
801065c7:	56                   	push   %esi
801065c8:	50                   	push   %eax
801065c9:	52                   	push   %edx
801065ca:	68 9c ab 10 80       	push   $0x8010ab9c
801065cf:	e8 38 9e ff ff       	call   8010040c <cprintf>
801065d4:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801065d7:	83 ec 0c             	sub    $0xc,%esp
801065da:	68 ce ab 10 80       	push   $0x8010abce
801065df:	e8 fa 9f ff ff       	call   801005de <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065e4:	e8 e3 fb ff ff       	call   801061cc <rcr2>
801065e9:	89 c6                	mov    %eax,%esi
801065eb:	8b 45 08             	mov    0x8(%ebp),%eax
801065ee:	8b 40 38             	mov    0x38(%eax),%eax
801065f1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
801065f4:	e8 25 d5 ff ff       	call   80103b1e <cpuid>
801065f9:	89 c3                	mov    %eax,%ebx
801065fb:	8b 45 08             	mov    0x8(%ebp),%eax
801065fe:	8b 48 34             	mov    0x34(%eax),%ecx
80106601:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80106604:	8b 45 08             	mov    0x8(%ebp),%eax
80106607:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010660a:	e8 aa d5 ff ff       	call   80103bb9 <myproc>
8010660f:	8d 50 6c             	lea    0x6c(%eax),%edx
80106612:	89 55 bc             	mov    %edx,-0x44(%ebp)
80106615:	e8 9f d5 ff ff       	call   80103bb9 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010661a:	8b 40 10             	mov    0x10(%eax),%eax
8010661d:	56                   	push   %esi
8010661e:	ff 75 c4             	push   -0x3c(%ebp)
80106621:	53                   	push   %ebx
80106622:	ff 75 c0             	push   -0x40(%ebp)
80106625:	57                   	push   %edi
80106626:	ff 75 bc             	push   -0x44(%ebp)
80106629:	50                   	push   %eax
8010662a:	68 d4 ab 10 80       	push   $0x8010abd4
8010662f:	e8 d8 9d ff ff       	call   8010040c <cprintf>
80106634:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106637:	e8 7d d5 ff ff       	call   80103bb9 <myproc>
8010663c:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106643:	eb 01                	jmp    80106646 <trap+0x2d3>
    break;
80106645:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106646:	e8 6e d5 ff ff       	call   80103bb9 <myproc>
8010664b:	85 c0                	test   %eax,%eax
8010664d:	74 23                	je     80106672 <trap+0x2ff>
8010664f:	e8 65 d5 ff ff       	call   80103bb9 <myproc>
80106654:	8b 40 24             	mov    0x24(%eax),%eax
80106657:	85 c0                	test   %eax,%eax
80106659:	74 17                	je     80106672 <trap+0x2ff>
8010665b:	8b 45 08             	mov    0x8(%ebp),%eax
8010665e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106662:	0f b7 c0             	movzwl %ax,%eax
80106665:	83 e0 03             	and    $0x3,%eax
80106668:	83 f8 03             	cmp    $0x3,%eax
8010666b:	75 05                	jne    80106672 <trap+0x2ff>
    exit();
8010666d:	e8 e7 d9 ff ff       	call   80104059 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106672:	e8 42 d5 ff ff       	call   80103bb9 <myproc>
80106677:	85 c0                	test   %eax,%eax
80106679:	74 1d                	je     80106698 <trap+0x325>
8010667b:	e8 39 d5 ff ff       	call   80103bb9 <myproc>
80106680:	8b 40 0c             	mov    0xc(%eax),%eax
80106683:	83 f8 04             	cmp    $0x4,%eax
80106686:	75 10                	jne    80106698 <trap+0x325>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106688:	8b 45 08             	mov    0x8(%ebp),%eax
8010668b:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
8010668e:	83 f8 20             	cmp    $0x20,%eax
80106691:	75 05                	jne    80106698 <trap+0x325>
    yield();
80106693:	e8 a4 dd ff ff       	call   8010443c <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106698:	e8 1c d5 ff ff       	call   80103bb9 <myproc>
8010669d:	85 c0                	test   %eax,%eax
8010669f:	74 26                	je     801066c7 <trap+0x354>
801066a1:	e8 13 d5 ff ff       	call   80103bb9 <myproc>
801066a6:	8b 40 24             	mov    0x24(%eax),%eax
801066a9:	85 c0                	test   %eax,%eax
801066ab:	74 1a                	je     801066c7 <trap+0x354>
801066ad:	8b 45 08             	mov    0x8(%ebp),%eax
801066b0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801066b4:	0f b7 c0             	movzwl %ax,%eax
801066b7:	83 e0 03             	and    $0x3,%eax
801066ba:	83 f8 03             	cmp    $0x3,%eax
801066bd:	75 08                	jne    801066c7 <trap+0x354>
    exit();
801066bf:	e8 95 d9 ff ff       	call   80104059 <exit>
801066c4:	eb 01                	jmp    801066c7 <trap+0x354>
    return;
801066c6:	90                   	nop
}
801066c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066ca:	5b                   	pop    %ebx
801066cb:	5e                   	pop    %esi
801066cc:	5f                   	pop    %edi
801066cd:	5d                   	pop    %ebp
801066ce:	c3                   	ret

801066cf <inb>:
{
801066cf:	55                   	push   %ebp
801066d0:	89 e5                	mov    %esp,%ebp
801066d2:	83 ec 14             	sub    $0x14,%esp
801066d5:	8b 45 08             	mov    0x8(%ebp),%eax
801066d8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801066dc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801066e0:	89 c2                	mov    %eax,%edx
801066e2:	ec                   	in     (%dx),%al
801066e3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801066e6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801066ea:	c9                   	leave
801066eb:	c3                   	ret

801066ec <outb>:
{
801066ec:	55                   	push   %ebp
801066ed:	89 e5                	mov    %esp,%ebp
801066ef:	83 ec 08             	sub    $0x8,%esp
801066f2:	8b 45 08             	mov    0x8(%ebp),%eax
801066f5:	8b 55 0c             	mov    0xc(%ebp),%edx
801066f8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801066fc:	89 d0                	mov    %edx,%eax
801066fe:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106701:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106705:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106709:	ee                   	out    %al,(%dx)
}
8010670a:	90                   	nop
8010670b:	c9                   	leave
8010670c:	c3                   	ret

8010670d <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010670d:	f3 0f 1e fb          	endbr32
80106711:	55                   	push   %ebp
80106712:	89 e5                	mov    %esp,%ebp
80106714:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106717:	6a 00                	push   $0x0
80106719:	68 fa 03 00 00       	push   $0x3fa
8010671e:	e8 c9 ff ff ff       	call   801066ec <outb>
80106723:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106726:	68 80 00 00 00       	push   $0x80
8010672b:	68 fb 03 00 00       	push   $0x3fb
80106730:	e8 b7 ff ff ff       	call   801066ec <outb>
80106735:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106738:	6a 0c                	push   $0xc
8010673a:	68 f8 03 00 00       	push   $0x3f8
8010673f:	e8 a8 ff ff ff       	call   801066ec <outb>
80106744:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106747:	6a 00                	push   $0x0
80106749:	68 f9 03 00 00       	push   $0x3f9
8010674e:	e8 99 ff ff ff       	call   801066ec <outb>
80106753:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106756:	6a 03                	push   $0x3
80106758:	68 fb 03 00 00       	push   $0x3fb
8010675d:	e8 8a ff ff ff       	call   801066ec <outb>
80106762:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106765:	6a 00                	push   $0x0
80106767:	68 fc 03 00 00       	push   $0x3fc
8010676c:	e8 7b ff ff ff       	call   801066ec <outb>
80106771:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106774:	6a 01                	push   $0x1
80106776:	68 f9 03 00 00       	push   $0x3f9
8010677b:	e8 6c ff ff ff       	call   801066ec <outb>
80106780:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106783:	68 fd 03 00 00       	push   $0x3fd
80106788:	e8 42 ff ff ff       	call   801066cf <inb>
8010678d:	83 c4 04             	add    $0x4,%esp
80106790:	3c ff                	cmp    $0xff,%al
80106792:	74 61                	je     801067f5 <uartinit+0xe8>
    return;
  uart = 1;
80106794:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
8010679b:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010679e:	68 fa 03 00 00       	push   $0x3fa
801067a3:	e8 27 ff ff ff       	call   801066cf <inb>
801067a8:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801067ab:	68 f8 03 00 00       	push   $0x3f8
801067b0:	e8 1a ff ff ff       	call   801066cf <inb>
801067b5:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801067b8:	83 ec 08             	sub    $0x8,%esp
801067bb:	6a 00                	push   $0x0
801067bd:	6a 04                	push   $0x4
801067bf:	e8 58 bf ff ff       	call   8010271c <ioapicenable>
801067c4:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801067c7:	c7 45 f4 e0 ac 10 80 	movl   $0x8010ace0,-0xc(%ebp)
801067ce:	eb 19                	jmp    801067e9 <uartinit+0xdc>
    uartputc(*p);
801067d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d3:	0f b6 00             	movzbl (%eax),%eax
801067d6:	0f be c0             	movsbl %al,%eax
801067d9:	83 ec 0c             	sub    $0xc,%esp
801067dc:	50                   	push   %eax
801067dd:	e8 16 00 00 00       	call   801067f8 <uartputc>
801067e2:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801067e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ec:	0f b6 00             	movzbl (%eax),%eax
801067ef:	84 c0                	test   %al,%al
801067f1:	75 dd                	jne    801067d0 <uartinit+0xc3>
801067f3:	eb 01                	jmp    801067f6 <uartinit+0xe9>
    return;
801067f5:	90                   	nop
}
801067f6:	c9                   	leave
801067f7:	c3                   	ret

801067f8 <uartputc>:

void
uartputc(int c)
{
801067f8:	f3 0f 1e fb          	endbr32
801067fc:	55                   	push   %ebp
801067fd:	89 e5                	mov    %esp,%ebp
801067ff:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106802:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106807:	85 c0                	test   %eax,%eax
80106809:	74 53                	je     8010685e <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010680b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106812:	eb 11                	jmp    80106825 <uartputc+0x2d>
    microdelay(10);
80106814:	83 ec 0c             	sub    $0xc,%esp
80106817:	6a 0a                	push   $0xa
80106819:	e8 36 c4 ff ff       	call   80102c54 <microdelay>
8010681e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106821:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106825:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106829:	7f 1a                	jg     80106845 <uartputc+0x4d>
8010682b:	83 ec 0c             	sub    $0xc,%esp
8010682e:	68 fd 03 00 00       	push   $0x3fd
80106833:	e8 97 fe ff ff       	call   801066cf <inb>
80106838:	83 c4 10             	add    $0x10,%esp
8010683b:	0f b6 c0             	movzbl %al,%eax
8010683e:	83 e0 20             	and    $0x20,%eax
80106841:	85 c0                	test   %eax,%eax
80106843:	74 cf                	je     80106814 <uartputc+0x1c>
  outb(COM1+0, c);
80106845:	8b 45 08             	mov    0x8(%ebp),%eax
80106848:	0f b6 c0             	movzbl %al,%eax
8010684b:	83 ec 08             	sub    $0x8,%esp
8010684e:	50                   	push   %eax
8010684f:	68 f8 03 00 00       	push   $0x3f8
80106854:	e8 93 fe ff ff       	call   801066ec <outb>
80106859:	83 c4 10             	add    $0x10,%esp
8010685c:	eb 01                	jmp    8010685f <uartputc+0x67>
    return;
8010685e:	90                   	nop
}
8010685f:	c9                   	leave
80106860:	c3                   	ret

80106861 <uartgetc>:

static int
uartgetc(void)
{
80106861:	f3 0f 1e fb          	endbr32
80106865:	55                   	push   %ebp
80106866:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106868:	a1 60 d0 18 80       	mov    0x8018d060,%eax
8010686d:	85 c0                	test   %eax,%eax
8010686f:	75 07                	jne    80106878 <uartgetc+0x17>
    return -1;
80106871:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106876:	eb 2e                	jmp    801068a6 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80106878:	68 fd 03 00 00       	push   $0x3fd
8010687d:	e8 4d fe ff ff       	call   801066cf <inb>
80106882:	83 c4 04             	add    $0x4,%esp
80106885:	0f b6 c0             	movzbl %al,%eax
80106888:	83 e0 01             	and    $0x1,%eax
8010688b:	85 c0                	test   %eax,%eax
8010688d:	75 07                	jne    80106896 <uartgetc+0x35>
    return -1;
8010688f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106894:	eb 10                	jmp    801068a6 <uartgetc+0x45>
  return inb(COM1+0);
80106896:	68 f8 03 00 00       	push   $0x3f8
8010689b:	e8 2f fe ff ff       	call   801066cf <inb>
801068a0:	83 c4 04             	add    $0x4,%esp
801068a3:	0f b6 c0             	movzbl %al,%eax
}
801068a6:	c9                   	leave
801068a7:	c3                   	ret

801068a8 <uartintr>:

void
uartintr(void)
{
801068a8:	f3 0f 1e fb          	endbr32
801068ac:	55                   	push   %ebp
801068ad:	89 e5                	mov    %esp,%ebp
801068af:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801068b2:	83 ec 0c             	sub    $0xc,%esp
801068b5:	68 61 68 10 80       	push   $0x80106861
801068ba:	e8 5a 9f ff ff       	call   80100819 <consoleintr>
801068bf:	83 c4 10             	add    $0x10,%esp
}
801068c2:	90                   	nop
801068c3:	c9                   	leave
801068c4:	c3                   	ret

801068c5 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801068c5:	6a 00                	push   $0x0
  pushl $0
801068c7:	6a 00                	push   $0x0
  jmp alltraps
801068c9:	e9 b1 f8 ff ff       	jmp    8010617f <alltraps>

801068ce <vector1>:
.globl vector1
vector1:
  pushl $0
801068ce:	6a 00                	push   $0x0
  pushl $1
801068d0:	6a 01                	push   $0x1
  jmp alltraps
801068d2:	e9 a8 f8 ff ff       	jmp    8010617f <alltraps>

801068d7 <vector2>:
.globl vector2
vector2:
  pushl $0
801068d7:	6a 00                	push   $0x0
  pushl $2
801068d9:	6a 02                	push   $0x2
  jmp alltraps
801068db:	e9 9f f8 ff ff       	jmp    8010617f <alltraps>

801068e0 <vector3>:
.globl vector3
vector3:
  pushl $0
801068e0:	6a 00                	push   $0x0
  pushl $3
801068e2:	6a 03                	push   $0x3
  jmp alltraps
801068e4:	e9 96 f8 ff ff       	jmp    8010617f <alltraps>

801068e9 <vector4>:
.globl vector4
vector4:
  pushl $0
801068e9:	6a 00                	push   $0x0
  pushl $4
801068eb:	6a 04                	push   $0x4
  jmp alltraps
801068ed:	e9 8d f8 ff ff       	jmp    8010617f <alltraps>

801068f2 <vector5>:
.globl vector5
vector5:
  pushl $0
801068f2:	6a 00                	push   $0x0
  pushl $5
801068f4:	6a 05                	push   $0x5
  jmp alltraps
801068f6:	e9 84 f8 ff ff       	jmp    8010617f <alltraps>

801068fb <vector6>:
.globl vector6
vector6:
  pushl $0
801068fb:	6a 00                	push   $0x0
  pushl $6
801068fd:	6a 06                	push   $0x6
  jmp alltraps
801068ff:	e9 7b f8 ff ff       	jmp    8010617f <alltraps>

80106904 <vector7>:
.globl vector7
vector7:
  pushl $0
80106904:	6a 00                	push   $0x0
  pushl $7
80106906:	6a 07                	push   $0x7
  jmp alltraps
80106908:	e9 72 f8 ff ff       	jmp    8010617f <alltraps>

8010690d <vector8>:
.globl vector8
vector8:
  pushl $8
8010690d:	6a 08                	push   $0x8
  jmp alltraps
8010690f:	e9 6b f8 ff ff       	jmp    8010617f <alltraps>

80106914 <vector9>:
.globl vector9
vector9:
  pushl $0
80106914:	6a 00                	push   $0x0
  pushl $9
80106916:	6a 09                	push   $0x9
  jmp alltraps
80106918:	e9 62 f8 ff ff       	jmp    8010617f <alltraps>

8010691d <vector10>:
.globl vector10
vector10:
  pushl $10
8010691d:	6a 0a                	push   $0xa
  jmp alltraps
8010691f:	e9 5b f8 ff ff       	jmp    8010617f <alltraps>

80106924 <vector11>:
.globl vector11
vector11:
  pushl $11
80106924:	6a 0b                	push   $0xb
  jmp alltraps
80106926:	e9 54 f8 ff ff       	jmp    8010617f <alltraps>

8010692b <vector12>:
.globl vector12
vector12:
  pushl $12
8010692b:	6a 0c                	push   $0xc
  jmp alltraps
8010692d:	e9 4d f8 ff ff       	jmp    8010617f <alltraps>

80106932 <vector13>:
.globl vector13
vector13:
  pushl $13
80106932:	6a 0d                	push   $0xd
  jmp alltraps
80106934:	e9 46 f8 ff ff       	jmp    8010617f <alltraps>

80106939 <vector14>:
.globl vector14
vector14:
  pushl $14
80106939:	6a 0e                	push   $0xe
  jmp alltraps
8010693b:	e9 3f f8 ff ff       	jmp    8010617f <alltraps>

80106940 <vector15>:
.globl vector15
vector15:
  pushl $0
80106940:	6a 00                	push   $0x0
  pushl $15
80106942:	6a 0f                	push   $0xf
  jmp alltraps
80106944:	e9 36 f8 ff ff       	jmp    8010617f <alltraps>

80106949 <vector16>:
.globl vector16
vector16:
  pushl $0
80106949:	6a 00                	push   $0x0
  pushl $16
8010694b:	6a 10                	push   $0x10
  jmp alltraps
8010694d:	e9 2d f8 ff ff       	jmp    8010617f <alltraps>

80106952 <vector17>:
.globl vector17
vector17:
  pushl $17
80106952:	6a 11                	push   $0x11
  jmp alltraps
80106954:	e9 26 f8 ff ff       	jmp    8010617f <alltraps>

80106959 <vector18>:
.globl vector18
vector18:
  pushl $0
80106959:	6a 00                	push   $0x0
  pushl $18
8010695b:	6a 12                	push   $0x12
  jmp alltraps
8010695d:	e9 1d f8 ff ff       	jmp    8010617f <alltraps>

80106962 <vector19>:
.globl vector19
vector19:
  pushl $0
80106962:	6a 00                	push   $0x0
  pushl $19
80106964:	6a 13                	push   $0x13
  jmp alltraps
80106966:	e9 14 f8 ff ff       	jmp    8010617f <alltraps>

8010696b <vector20>:
.globl vector20
vector20:
  pushl $0
8010696b:	6a 00                	push   $0x0
  pushl $20
8010696d:	6a 14                	push   $0x14
  jmp alltraps
8010696f:	e9 0b f8 ff ff       	jmp    8010617f <alltraps>

80106974 <vector21>:
.globl vector21
vector21:
  pushl $0
80106974:	6a 00                	push   $0x0
  pushl $21
80106976:	6a 15                	push   $0x15
  jmp alltraps
80106978:	e9 02 f8 ff ff       	jmp    8010617f <alltraps>

8010697d <vector22>:
.globl vector22
vector22:
  pushl $0
8010697d:	6a 00                	push   $0x0
  pushl $22
8010697f:	6a 16                	push   $0x16
  jmp alltraps
80106981:	e9 f9 f7 ff ff       	jmp    8010617f <alltraps>

80106986 <vector23>:
.globl vector23
vector23:
  pushl $0
80106986:	6a 00                	push   $0x0
  pushl $23
80106988:	6a 17                	push   $0x17
  jmp alltraps
8010698a:	e9 f0 f7 ff ff       	jmp    8010617f <alltraps>

8010698f <vector24>:
.globl vector24
vector24:
  pushl $0
8010698f:	6a 00                	push   $0x0
  pushl $24
80106991:	6a 18                	push   $0x18
  jmp alltraps
80106993:	e9 e7 f7 ff ff       	jmp    8010617f <alltraps>

80106998 <vector25>:
.globl vector25
vector25:
  pushl $0
80106998:	6a 00                	push   $0x0
  pushl $25
8010699a:	6a 19                	push   $0x19
  jmp alltraps
8010699c:	e9 de f7 ff ff       	jmp    8010617f <alltraps>

801069a1 <vector26>:
.globl vector26
vector26:
  pushl $0
801069a1:	6a 00                	push   $0x0
  pushl $26
801069a3:	6a 1a                	push   $0x1a
  jmp alltraps
801069a5:	e9 d5 f7 ff ff       	jmp    8010617f <alltraps>

801069aa <vector27>:
.globl vector27
vector27:
  pushl $0
801069aa:	6a 00                	push   $0x0
  pushl $27
801069ac:	6a 1b                	push   $0x1b
  jmp alltraps
801069ae:	e9 cc f7 ff ff       	jmp    8010617f <alltraps>

801069b3 <vector28>:
.globl vector28
vector28:
  pushl $0
801069b3:	6a 00                	push   $0x0
  pushl $28
801069b5:	6a 1c                	push   $0x1c
  jmp alltraps
801069b7:	e9 c3 f7 ff ff       	jmp    8010617f <alltraps>

801069bc <vector29>:
.globl vector29
vector29:
  pushl $0
801069bc:	6a 00                	push   $0x0
  pushl $29
801069be:	6a 1d                	push   $0x1d
  jmp alltraps
801069c0:	e9 ba f7 ff ff       	jmp    8010617f <alltraps>

801069c5 <vector30>:
.globl vector30
vector30:
  pushl $0
801069c5:	6a 00                	push   $0x0
  pushl $30
801069c7:	6a 1e                	push   $0x1e
  jmp alltraps
801069c9:	e9 b1 f7 ff ff       	jmp    8010617f <alltraps>

801069ce <vector31>:
.globl vector31
vector31:
  pushl $0
801069ce:	6a 00                	push   $0x0
  pushl $31
801069d0:	6a 1f                	push   $0x1f
  jmp alltraps
801069d2:	e9 a8 f7 ff ff       	jmp    8010617f <alltraps>

801069d7 <vector32>:
.globl vector32
vector32:
  pushl $0
801069d7:	6a 00                	push   $0x0
  pushl $32
801069d9:	6a 20                	push   $0x20
  jmp alltraps
801069db:	e9 9f f7 ff ff       	jmp    8010617f <alltraps>

801069e0 <vector33>:
.globl vector33
vector33:
  pushl $0
801069e0:	6a 00                	push   $0x0
  pushl $33
801069e2:	6a 21                	push   $0x21
  jmp alltraps
801069e4:	e9 96 f7 ff ff       	jmp    8010617f <alltraps>

801069e9 <vector34>:
.globl vector34
vector34:
  pushl $0
801069e9:	6a 00                	push   $0x0
  pushl $34
801069eb:	6a 22                	push   $0x22
  jmp alltraps
801069ed:	e9 8d f7 ff ff       	jmp    8010617f <alltraps>

801069f2 <vector35>:
.globl vector35
vector35:
  pushl $0
801069f2:	6a 00                	push   $0x0
  pushl $35
801069f4:	6a 23                	push   $0x23
  jmp alltraps
801069f6:	e9 84 f7 ff ff       	jmp    8010617f <alltraps>

801069fb <vector36>:
.globl vector36
vector36:
  pushl $0
801069fb:	6a 00                	push   $0x0
  pushl $36
801069fd:	6a 24                	push   $0x24
  jmp alltraps
801069ff:	e9 7b f7 ff ff       	jmp    8010617f <alltraps>

80106a04 <vector37>:
.globl vector37
vector37:
  pushl $0
80106a04:	6a 00                	push   $0x0
  pushl $37
80106a06:	6a 25                	push   $0x25
  jmp alltraps
80106a08:	e9 72 f7 ff ff       	jmp    8010617f <alltraps>

80106a0d <vector38>:
.globl vector38
vector38:
  pushl $0
80106a0d:	6a 00                	push   $0x0
  pushl $38
80106a0f:	6a 26                	push   $0x26
  jmp alltraps
80106a11:	e9 69 f7 ff ff       	jmp    8010617f <alltraps>

80106a16 <vector39>:
.globl vector39
vector39:
  pushl $0
80106a16:	6a 00                	push   $0x0
  pushl $39
80106a18:	6a 27                	push   $0x27
  jmp alltraps
80106a1a:	e9 60 f7 ff ff       	jmp    8010617f <alltraps>

80106a1f <vector40>:
.globl vector40
vector40:
  pushl $0
80106a1f:	6a 00                	push   $0x0
  pushl $40
80106a21:	6a 28                	push   $0x28
  jmp alltraps
80106a23:	e9 57 f7 ff ff       	jmp    8010617f <alltraps>

80106a28 <vector41>:
.globl vector41
vector41:
  pushl $0
80106a28:	6a 00                	push   $0x0
  pushl $41
80106a2a:	6a 29                	push   $0x29
  jmp alltraps
80106a2c:	e9 4e f7 ff ff       	jmp    8010617f <alltraps>

80106a31 <vector42>:
.globl vector42
vector42:
  pushl $0
80106a31:	6a 00                	push   $0x0
  pushl $42
80106a33:	6a 2a                	push   $0x2a
  jmp alltraps
80106a35:	e9 45 f7 ff ff       	jmp    8010617f <alltraps>

80106a3a <vector43>:
.globl vector43
vector43:
  pushl $0
80106a3a:	6a 00                	push   $0x0
  pushl $43
80106a3c:	6a 2b                	push   $0x2b
  jmp alltraps
80106a3e:	e9 3c f7 ff ff       	jmp    8010617f <alltraps>

80106a43 <vector44>:
.globl vector44
vector44:
  pushl $0
80106a43:	6a 00                	push   $0x0
  pushl $44
80106a45:	6a 2c                	push   $0x2c
  jmp alltraps
80106a47:	e9 33 f7 ff ff       	jmp    8010617f <alltraps>

80106a4c <vector45>:
.globl vector45
vector45:
  pushl $0
80106a4c:	6a 00                	push   $0x0
  pushl $45
80106a4e:	6a 2d                	push   $0x2d
  jmp alltraps
80106a50:	e9 2a f7 ff ff       	jmp    8010617f <alltraps>

80106a55 <vector46>:
.globl vector46
vector46:
  pushl $0
80106a55:	6a 00                	push   $0x0
  pushl $46
80106a57:	6a 2e                	push   $0x2e
  jmp alltraps
80106a59:	e9 21 f7 ff ff       	jmp    8010617f <alltraps>

80106a5e <vector47>:
.globl vector47
vector47:
  pushl $0
80106a5e:	6a 00                	push   $0x0
  pushl $47
80106a60:	6a 2f                	push   $0x2f
  jmp alltraps
80106a62:	e9 18 f7 ff ff       	jmp    8010617f <alltraps>

80106a67 <vector48>:
.globl vector48
vector48:
  pushl $0
80106a67:	6a 00                	push   $0x0
  pushl $48
80106a69:	6a 30                	push   $0x30
  jmp alltraps
80106a6b:	e9 0f f7 ff ff       	jmp    8010617f <alltraps>

80106a70 <vector49>:
.globl vector49
vector49:
  pushl $0
80106a70:	6a 00                	push   $0x0
  pushl $49
80106a72:	6a 31                	push   $0x31
  jmp alltraps
80106a74:	e9 06 f7 ff ff       	jmp    8010617f <alltraps>

80106a79 <vector50>:
.globl vector50
vector50:
  pushl $0
80106a79:	6a 00                	push   $0x0
  pushl $50
80106a7b:	6a 32                	push   $0x32
  jmp alltraps
80106a7d:	e9 fd f6 ff ff       	jmp    8010617f <alltraps>

80106a82 <vector51>:
.globl vector51
vector51:
  pushl $0
80106a82:	6a 00                	push   $0x0
  pushl $51
80106a84:	6a 33                	push   $0x33
  jmp alltraps
80106a86:	e9 f4 f6 ff ff       	jmp    8010617f <alltraps>

80106a8b <vector52>:
.globl vector52
vector52:
  pushl $0
80106a8b:	6a 00                	push   $0x0
  pushl $52
80106a8d:	6a 34                	push   $0x34
  jmp alltraps
80106a8f:	e9 eb f6 ff ff       	jmp    8010617f <alltraps>

80106a94 <vector53>:
.globl vector53
vector53:
  pushl $0
80106a94:	6a 00                	push   $0x0
  pushl $53
80106a96:	6a 35                	push   $0x35
  jmp alltraps
80106a98:	e9 e2 f6 ff ff       	jmp    8010617f <alltraps>

80106a9d <vector54>:
.globl vector54
vector54:
  pushl $0
80106a9d:	6a 00                	push   $0x0
  pushl $54
80106a9f:	6a 36                	push   $0x36
  jmp alltraps
80106aa1:	e9 d9 f6 ff ff       	jmp    8010617f <alltraps>

80106aa6 <vector55>:
.globl vector55
vector55:
  pushl $0
80106aa6:	6a 00                	push   $0x0
  pushl $55
80106aa8:	6a 37                	push   $0x37
  jmp alltraps
80106aaa:	e9 d0 f6 ff ff       	jmp    8010617f <alltraps>

80106aaf <vector56>:
.globl vector56
vector56:
  pushl $0
80106aaf:	6a 00                	push   $0x0
  pushl $56
80106ab1:	6a 38                	push   $0x38
  jmp alltraps
80106ab3:	e9 c7 f6 ff ff       	jmp    8010617f <alltraps>

80106ab8 <vector57>:
.globl vector57
vector57:
  pushl $0
80106ab8:	6a 00                	push   $0x0
  pushl $57
80106aba:	6a 39                	push   $0x39
  jmp alltraps
80106abc:	e9 be f6 ff ff       	jmp    8010617f <alltraps>

80106ac1 <vector58>:
.globl vector58
vector58:
  pushl $0
80106ac1:	6a 00                	push   $0x0
  pushl $58
80106ac3:	6a 3a                	push   $0x3a
  jmp alltraps
80106ac5:	e9 b5 f6 ff ff       	jmp    8010617f <alltraps>

80106aca <vector59>:
.globl vector59
vector59:
  pushl $0
80106aca:	6a 00                	push   $0x0
  pushl $59
80106acc:	6a 3b                	push   $0x3b
  jmp alltraps
80106ace:	e9 ac f6 ff ff       	jmp    8010617f <alltraps>

80106ad3 <vector60>:
.globl vector60
vector60:
  pushl $0
80106ad3:	6a 00                	push   $0x0
  pushl $60
80106ad5:	6a 3c                	push   $0x3c
  jmp alltraps
80106ad7:	e9 a3 f6 ff ff       	jmp    8010617f <alltraps>

80106adc <vector61>:
.globl vector61
vector61:
  pushl $0
80106adc:	6a 00                	push   $0x0
  pushl $61
80106ade:	6a 3d                	push   $0x3d
  jmp alltraps
80106ae0:	e9 9a f6 ff ff       	jmp    8010617f <alltraps>

80106ae5 <vector62>:
.globl vector62
vector62:
  pushl $0
80106ae5:	6a 00                	push   $0x0
  pushl $62
80106ae7:	6a 3e                	push   $0x3e
  jmp alltraps
80106ae9:	e9 91 f6 ff ff       	jmp    8010617f <alltraps>

80106aee <vector63>:
.globl vector63
vector63:
  pushl $0
80106aee:	6a 00                	push   $0x0
  pushl $63
80106af0:	6a 3f                	push   $0x3f
  jmp alltraps
80106af2:	e9 88 f6 ff ff       	jmp    8010617f <alltraps>

80106af7 <vector64>:
.globl vector64
vector64:
  pushl $0
80106af7:	6a 00                	push   $0x0
  pushl $64
80106af9:	6a 40                	push   $0x40
  jmp alltraps
80106afb:	e9 7f f6 ff ff       	jmp    8010617f <alltraps>

80106b00 <vector65>:
.globl vector65
vector65:
  pushl $0
80106b00:	6a 00                	push   $0x0
  pushl $65
80106b02:	6a 41                	push   $0x41
  jmp alltraps
80106b04:	e9 76 f6 ff ff       	jmp    8010617f <alltraps>

80106b09 <vector66>:
.globl vector66
vector66:
  pushl $0
80106b09:	6a 00                	push   $0x0
  pushl $66
80106b0b:	6a 42                	push   $0x42
  jmp alltraps
80106b0d:	e9 6d f6 ff ff       	jmp    8010617f <alltraps>

80106b12 <vector67>:
.globl vector67
vector67:
  pushl $0
80106b12:	6a 00                	push   $0x0
  pushl $67
80106b14:	6a 43                	push   $0x43
  jmp alltraps
80106b16:	e9 64 f6 ff ff       	jmp    8010617f <alltraps>

80106b1b <vector68>:
.globl vector68
vector68:
  pushl $0
80106b1b:	6a 00                	push   $0x0
  pushl $68
80106b1d:	6a 44                	push   $0x44
  jmp alltraps
80106b1f:	e9 5b f6 ff ff       	jmp    8010617f <alltraps>

80106b24 <vector69>:
.globl vector69
vector69:
  pushl $0
80106b24:	6a 00                	push   $0x0
  pushl $69
80106b26:	6a 45                	push   $0x45
  jmp alltraps
80106b28:	e9 52 f6 ff ff       	jmp    8010617f <alltraps>

80106b2d <vector70>:
.globl vector70
vector70:
  pushl $0
80106b2d:	6a 00                	push   $0x0
  pushl $70
80106b2f:	6a 46                	push   $0x46
  jmp alltraps
80106b31:	e9 49 f6 ff ff       	jmp    8010617f <alltraps>

80106b36 <vector71>:
.globl vector71
vector71:
  pushl $0
80106b36:	6a 00                	push   $0x0
  pushl $71
80106b38:	6a 47                	push   $0x47
  jmp alltraps
80106b3a:	e9 40 f6 ff ff       	jmp    8010617f <alltraps>

80106b3f <vector72>:
.globl vector72
vector72:
  pushl $0
80106b3f:	6a 00                	push   $0x0
  pushl $72
80106b41:	6a 48                	push   $0x48
  jmp alltraps
80106b43:	e9 37 f6 ff ff       	jmp    8010617f <alltraps>

80106b48 <vector73>:
.globl vector73
vector73:
  pushl $0
80106b48:	6a 00                	push   $0x0
  pushl $73
80106b4a:	6a 49                	push   $0x49
  jmp alltraps
80106b4c:	e9 2e f6 ff ff       	jmp    8010617f <alltraps>

80106b51 <vector74>:
.globl vector74
vector74:
  pushl $0
80106b51:	6a 00                	push   $0x0
  pushl $74
80106b53:	6a 4a                	push   $0x4a
  jmp alltraps
80106b55:	e9 25 f6 ff ff       	jmp    8010617f <alltraps>

80106b5a <vector75>:
.globl vector75
vector75:
  pushl $0
80106b5a:	6a 00                	push   $0x0
  pushl $75
80106b5c:	6a 4b                	push   $0x4b
  jmp alltraps
80106b5e:	e9 1c f6 ff ff       	jmp    8010617f <alltraps>

80106b63 <vector76>:
.globl vector76
vector76:
  pushl $0
80106b63:	6a 00                	push   $0x0
  pushl $76
80106b65:	6a 4c                	push   $0x4c
  jmp alltraps
80106b67:	e9 13 f6 ff ff       	jmp    8010617f <alltraps>

80106b6c <vector77>:
.globl vector77
vector77:
  pushl $0
80106b6c:	6a 00                	push   $0x0
  pushl $77
80106b6e:	6a 4d                	push   $0x4d
  jmp alltraps
80106b70:	e9 0a f6 ff ff       	jmp    8010617f <alltraps>

80106b75 <vector78>:
.globl vector78
vector78:
  pushl $0
80106b75:	6a 00                	push   $0x0
  pushl $78
80106b77:	6a 4e                	push   $0x4e
  jmp alltraps
80106b79:	e9 01 f6 ff ff       	jmp    8010617f <alltraps>

80106b7e <vector79>:
.globl vector79
vector79:
  pushl $0
80106b7e:	6a 00                	push   $0x0
  pushl $79
80106b80:	6a 4f                	push   $0x4f
  jmp alltraps
80106b82:	e9 f8 f5 ff ff       	jmp    8010617f <alltraps>

80106b87 <vector80>:
.globl vector80
vector80:
  pushl $0
80106b87:	6a 00                	push   $0x0
  pushl $80
80106b89:	6a 50                	push   $0x50
  jmp alltraps
80106b8b:	e9 ef f5 ff ff       	jmp    8010617f <alltraps>

80106b90 <vector81>:
.globl vector81
vector81:
  pushl $0
80106b90:	6a 00                	push   $0x0
  pushl $81
80106b92:	6a 51                	push   $0x51
  jmp alltraps
80106b94:	e9 e6 f5 ff ff       	jmp    8010617f <alltraps>

80106b99 <vector82>:
.globl vector82
vector82:
  pushl $0
80106b99:	6a 00                	push   $0x0
  pushl $82
80106b9b:	6a 52                	push   $0x52
  jmp alltraps
80106b9d:	e9 dd f5 ff ff       	jmp    8010617f <alltraps>

80106ba2 <vector83>:
.globl vector83
vector83:
  pushl $0
80106ba2:	6a 00                	push   $0x0
  pushl $83
80106ba4:	6a 53                	push   $0x53
  jmp alltraps
80106ba6:	e9 d4 f5 ff ff       	jmp    8010617f <alltraps>

80106bab <vector84>:
.globl vector84
vector84:
  pushl $0
80106bab:	6a 00                	push   $0x0
  pushl $84
80106bad:	6a 54                	push   $0x54
  jmp alltraps
80106baf:	e9 cb f5 ff ff       	jmp    8010617f <alltraps>

80106bb4 <vector85>:
.globl vector85
vector85:
  pushl $0
80106bb4:	6a 00                	push   $0x0
  pushl $85
80106bb6:	6a 55                	push   $0x55
  jmp alltraps
80106bb8:	e9 c2 f5 ff ff       	jmp    8010617f <alltraps>

80106bbd <vector86>:
.globl vector86
vector86:
  pushl $0
80106bbd:	6a 00                	push   $0x0
  pushl $86
80106bbf:	6a 56                	push   $0x56
  jmp alltraps
80106bc1:	e9 b9 f5 ff ff       	jmp    8010617f <alltraps>

80106bc6 <vector87>:
.globl vector87
vector87:
  pushl $0
80106bc6:	6a 00                	push   $0x0
  pushl $87
80106bc8:	6a 57                	push   $0x57
  jmp alltraps
80106bca:	e9 b0 f5 ff ff       	jmp    8010617f <alltraps>

80106bcf <vector88>:
.globl vector88
vector88:
  pushl $0
80106bcf:	6a 00                	push   $0x0
  pushl $88
80106bd1:	6a 58                	push   $0x58
  jmp alltraps
80106bd3:	e9 a7 f5 ff ff       	jmp    8010617f <alltraps>

80106bd8 <vector89>:
.globl vector89
vector89:
  pushl $0
80106bd8:	6a 00                	push   $0x0
  pushl $89
80106bda:	6a 59                	push   $0x59
  jmp alltraps
80106bdc:	e9 9e f5 ff ff       	jmp    8010617f <alltraps>

80106be1 <vector90>:
.globl vector90
vector90:
  pushl $0
80106be1:	6a 00                	push   $0x0
  pushl $90
80106be3:	6a 5a                	push   $0x5a
  jmp alltraps
80106be5:	e9 95 f5 ff ff       	jmp    8010617f <alltraps>

80106bea <vector91>:
.globl vector91
vector91:
  pushl $0
80106bea:	6a 00                	push   $0x0
  pushl $91
80106bec:	6a 5b                	push   $0x5b
  jmp alltraps
80106bee:	e9 8c f5 ff ff       	jmp    8010617f <alltraps>

80106bf3 <vector92>:
.globl vector92
vector92:
  pushl $0
80106bf3:	6a 00                	push   $0x0
  pushl $92
80106bf5:	6a 5c                	push   $0x5c
  jmp alltraps
80106bf7:	e9 83 f5 ff ff       	jmp    8010617f <alltraps>

80106bfc <vector93>:
.globl vector93
vector93:
  pushl $0
80106bfc:	6a 00                	push   $0x0
  pushl $93
80106bfe:	6a 5d                	push   $0x5d
  jmp alltraps
80106c00:	e9 7a f5 ff ff       	jmp    8010617f <alltraps>

80106c05 <vector94>:
.globl vector94
vector94:
  pushl $0
80106c05:	6a 00                	push   $0x0
  pushl $94
80106c07:	6a 5e                	push   $0x5e
  jmp alltraps
80106c09:	e9 71 f5 ff ff       	jmp    8010617f <alltraps>

80106c0e <vector95>:
.globl vector95
vector95:
  pushl $0
80106c0e:	6a 00                	push   $0x0
  pushl $95
80106c10:	6a 5f                	push   $0x5f
  jmp alltraps
80106c12:	e9 68 f5 ff ff       	jmp    8010617f <alltraps>

80106c17 <vector96>:
.globl vector96
vector96:
  pushl $0
80106c17:	6a 00                	push   $0x0
  pushl $96
80106c19:	6a 60                	push   $0x60
  jmp alltraps
80106c1b:	e9 5f f5 ff ff       	jmp    8010617f <alltraps>

80106c20 <vector97>:
.globl vector97
vector97:
  pushl $0
80106c20:	6a 00                	push   $0x0
  pushl $97
80106c22:	6a 61                	push   $0x61
  jmp alltraps
80106c24:	e9 56 f5 ff ff       	jmp    8010617f <alltraps>

80106c29 <vector98>:
.globl vector98
vector98:
  pushl $0
80106c29:	6a 00                	push   $0x0
  pushl $98
80106c2b:	6a 62                	push   $0x62
  jmp alltraps
80106c2d:	e9 4d f5 ff ff       	jmp    8010617f <alltraps>

80106c32 <vector99>:
.globl vector99
vector99:
  pushl $0
80106c32:	6a 00                	push   $0x0
  pushl $99
80106c34:	6a 63                	push   $0x63
  jmp alltraps
80106c36:	e9 44 f5 ff ff       	jmp    8010617f <alltraps>

80106c3b <vector100>:
.globl vector100
vector100:
  pushl $0
80106c3b:	6a 00                	push   $0x0
  pushl $100
80106c3d:	6a 64                	push   $0x64
  jmp alltraps
80106c3f:	e9 3b f5 ff ff       	jmp    8010617f <alltraps>

80106c44 <vector101>:
.globl vector101
vector101:
  pushl $0
80106c44:	6a 00                	push   $0x0
  pushl $101
80106c46:	6a 65                	push   $0x65
  jmp alltraps
80106c48:	e9 32 f5 ff ff       	jmp    8010617f <alltraps>

80106c4d <vector102>:
.globl vector102
vector102:
  pushl $0
80106c4d:	6a 00                	push   $0x0
  pushl $102
80106c4f:	6a 66                	push   $0x66
  jmp alltraps
80106c51:	e9 29 f5 ff ff       	jmp    8010617f <alltraps>

80106c56 <vector103>:
.globl vector103
vector103:
  pushl $0
80106c56:	6a 00                	push   $0x0
  pushl $103
80106c58:	6a 67                	push   $0x67
  jmp alltraps
80106c5a:	e9 20 f5 ff ff       	jmp    8010617f <alltraps>

80106c5f <vector104>:
.globl vector104
vector104:
  pushl $0
80106c5f:	6a 00                	push   $0x0
  pushl $104
80106c61:	6a 68                	push   $0x68
  jmp alltraps
80106c63:	e9 17 f5 ff ff       	jmp    8010617f <alltraps>

80106c68 <vector105>:
.globl vector105
vector105:
  pushl $0
80106c68:	6a 00                	push   $0x0
  pushl $105
80106c6a:	6a 69                	push   $0x69
  jmp alltraps
80106c6c:	e9 0e f5 ff ff       	jmp    8010617f <alltraps>

80106c71 <vector106>:
.globl vector106
vector106:
  pushl $0
80106c71:	6a 00                	push   $0x0
  pushl $106
80106c73:	6a 6a                	push   $0x6a
  jmp alltraps
80106c75:	e9 05 f5 ff ff       	jmp    8010617f <alltraps>

80106c7a <vector107>:
.globl vector107
vector107:
  pushl $0
80106c7a:	6a 00                	push   $0x0
  pushl $107
80106c7c:	6a 6b                	push   $0x6b
  jmp alltraps
80106c7e:	e9 fc f4 ff ff       	jmp    8010617f <alltraps>

80106c83 <vector108>:
.globl vector108
vector108:
  pushl $0
80106c83:	6a 00                	push   $0x0
  pushl $108
80106c85:	6a 6c                	push   $0x6c
  jmp alltraps
80106c87:	e9 f3 f4 ff ff       	jmp    8010617f <alltraps>

80106c8c <vector109>:
.globl vector109
vector109:
  pushl $0
80106c8c:	6a 00                	push   $0x0
  pushl $109
80106c8e:	6a 6d                	push   $0x6d
  jmp alltraps
80106c90:	e9 ea f4 ff ff       	jmp    8010617f <alltraps>

80106c95 <vector110>:
.globl vector110
vector110:
  pushl $0
80106c95:	6a 00                	push   $0x0
  pushl $110
80106c97:	6a 6e                	push   $0x6e
  jmp alltraps
80106c99:	e9 e1 f4 ff ff       	jmp    8010617f <alltraps>

80106c9e <vector111>:
.globl vector111
vector111:
  pushl $0
80106c9e:	6a 00                	push   $0x0
  pushl $111
80106ca0:	6a 6f                	push   $0x6f
  jmp alltraps
80106ca2:	e9 d8 f4 ff ff       	jmp    8010617f <alltraps>

80106ca7 <vector112>:
.globl vector112
vector112:
  pushl $0
80106ca7:	6a 00                	push   $0x0
  pushl $112
80106ca9:	6a 70                	push   $0x70
  jmp alltraps
80106cab:	e9 cf f4 ff ff       	jmp    8010617f <alltraps>

80106cb0 <vector113>:
.globl vector113
vector113:
  pushl $0
80106cb0:	6a 00                	push   $0x0
  pushl $113
80106cb2:	6a 71                	push   $0x71
  jmp alltraps
80106cb4:	e9 c6 f4 ff ff       	jmp    8010617f <alltraps>

80106cb9 <vector114>:
.globl vector114
vector114:
  pushl $0
80106cb9:	6a 00                	push   $0x0
  pushl $114
80106cbb:	6a 72                	push   $0x72
  jmp alltraps
80106cbd:	e9 bd f4 ff ff       	jmp    8010617f <alltraps>

80106cc2 <vector115>:
.globl vector115
vector115:
  pushl $0
80106cc2:	6a 00                	push   $0x0
  pushl $115
80106cc4:	6a 73                	push   $0x73
  jmp alltraps
80106cc6:	e9 b4 f4 ff ff       	jmp    8010617f <alltraps>

80106ccb <vector116>:
.globl vector116
vector116:
  pushl $0
80106ccb:	6a 00                	push   $0x0
  pushl $116
80106ccd:	6a 74                	push   $0x74
  jmp alltraps
80106ccf:	e9 ab f4 ff ff       	jmp    8010617f <alltraps>

80106cd4 <vector117>:
.globl vector117
vector117:
  pushl $0
80106cd4:	6a 00                	push   $0x0
  pushl $117
80106cd6:	6a 75                	push   $0x75
  jmp alltraps
80106cd8:	e9 a2 f4 ff ff       	jmp    8010617f <alltraps>

80106cdd <vector118>:
.globl vector118
vector118:
  pushl $0
80106cdd:	6a 00                	push   $0x0
  pushl $118
80106cdf:	6a 76                	push   $0x76
  jmp alltraps
80106ce1:	e9 99 f4 ff ff       	jmp    8010617f <alltraps>

80106ce6 <vector119>:
.globl vector119
vector119:
  pushl $0
80106ce6:	6a 00                	push   $0x0
  pushl $119
80106ce8:	6a 77                	push   $0x77
  jmp alltraps
80106cea:	e9 90 f4 ff ff       	jmp    8010617f <alltraps>

80106cef <vector120>:
.globl vector120
vector120:
  pushl $0
80106cef:	6a 00                	push   $0x0
  pushl $120
80106cf1:	6a 78                	push   $0x78
  jmp alltraps
80106cf3:	e9 87 f4 ff ff       	jmp    8010617f <alltraps>

80106cf8 <vector121>:
.globl vector121
vector121:
  pushl $0
80106cf8:	6a 00                	push   $0x0
  pushl $121
80106cfa:	6a 79                	push   $0x79
  jmp alltraps
80106cfc:	e9 7e f4 ff ff       	jmp    8010617f <alltraps>

80106d01 <vector122>:
.globl vector122
vector122:
  pushl $0
80106d01:	6a 00                	push   $0x0
  pushl $122
80106d03:	6a 7a                	push   $0x7a
  jmp alltraps
80106d05:	e9 75 f4 ff ff       	jmp    8010617f <alltraps>

80106d0a <vector123>:
.globl vector123
vector123:
  pushl $0
80106d0a:	6a 00                	push   $0x0
  pushl $123
80106d0c:	6a 7b                	push   $0x7b
  jmp alltraps
80106d0e:	e9 6c f4 ff ff       	jmp    8010617f <alltraps>

80106d13 <vector124>:
.globl vector124
vector124:
  pushl $0
80106d13:	6a 00                	push   $0x0
  pushl $124
80106d15:	6a 7c                	push   $0x7c
  jmp alltraps
80106d17:	e9 63 f4 ff ff       	jmp    8010617f <alltraps>

80106d1c <vector125>:
.globl vector125
vector125:
  pushl $0
80106d1c:	6a 00                	push   $0x0
  pushl $125
80106d1e:	6a 7d                	push   $0x7d
  jmp alltraps
80106d20:	e9 5a f4 ff ff       	jmp    8010617f <alltraps>

80106d25 <vector126>:
.globl vector126
vector126:
  pushl $0
80106d25:	6a 00                	push   $0x0
  pushl $126
80106d27:	6a 7e                	push   $0x7e
  jmp alltraps
80106d29:	e9 51 f4 ff ff       	jmp    8010617f <alltraps>

80106d2e <vector127>:
.globl vector127
vector127:
  pushl $0
80106d2e:	6a 00                	push   $0x0
  pushl $127
80106d30:	6a 7f                	push   $0x7f
  jmp alltraps
80106d32:	e9 48 f4 ff ff       	jmp    8010617f <alltraps>

80106d37 <vector128>:
.globl vector128
vector128:
  pushl $0
80106d37:	6a 00                	push   $0x0
  pushl $128
80106d39:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106d3e:	e9 3c f4 ff ff       	jmp    8010617f <alltraps>

80106d43 <vector129>:
.globl vector129
vector129:
  pushl $0
80106d43:	6a 00                	push   $0x0
  pushl $129
80106d45:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106d4a:	e9 30 f4 ff ff       	jmp    8010617f <alltraps>

80106d4f <vector130>:
.globl vector130
vector130:
  pushl $0
80106d4f:	6a 00                	push   $0x0
  pushl $130
80106d51:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106d56:	e9 24 f4 ff ff       	jmp    8010617f <alltraps>

80106d5b <vector131>:
.globl vector131
vector131:
  pushl $0
80106d5b:	6a 00                	push   $0x0
  pushl $131
80106d5d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106d62:	e9 18 f4 ff ff       	jmp    8010617f <alltraps>

80106d67 <vector132>:
.globl vector132
vector132:
  pushl $0
80106d67:	6a 00                	push   $0x0
  pushl $132
80106d69:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106d6e:	e9 0c f4 ff ff       	jmp    8010617f <alltraps>

80106d73 <vector133>:
.globl vector133
vector133:
  pushl $0
80106d73:	6a 00                	push   $0x0
  pushl $133
80106d75:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106d7a:	e9 00 f4 ff ff       	jmp    8010617f <alltraps>

80106d7f <vector134>:
.globl vector134
vector134:
  pushl $0
80106d7f:	6a 00                	push   $0x0
  pushl $134
80106d81:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106d86:	e9 f4 f3 ff ff       	jmp    8010617f <alltraps>

80106d8b <vector135>:
.globl vector135
vector135:
  pushl $0
80106d8b:	6a 00                	push   $0x0
  pushl $135
80106d8d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106d92:	e9 e8 f3 ff ff       	jmp    8010617f <alltraps>

80106d97 <vector136>:
.globl vector136
vector136:
  pushl $0
80106d97:	6a 00                	push   $0x0
  pushl $136
80106d99:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106d9e:	e9 dc f3 ff ff       	jmp    8010617f <alltraps>

80106da3 <vector137>:
.globl vector137
vector137:
  pushl $0
80106da3:	6a 00                	push   $0x0
  pushl $137
80106da5:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106daa:	e9 d0 f3 ff ff       	jmp    8010617f <alltraps>

80106daf <vector138>:
.globl vector138
vector138:
  pushl $0
80106daf:	6a 00                	push   $0x0
  pushl $138
80106db1:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106db6:	e9 c4 f3 ff ff       	jmp    8010617f <alltraps>

80106dbb <vector139>:
.globl vector139
vector139:
  pushl $0
80106dbb:	6a 00                	push   $0x0
  pushl $139
80106dbd:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106dc2:	e9 b8 f3 ff ff       	jmp    8010617f <alltraps>

80106dc7 <vector140>:
.globl vector140
vector140:
  pushl $0
80106dc7:	6a 00                	push   $0x0
  pushl $140
80106dc9:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106dce:	e9 ac f3 ff ff       	jmp    8010617f <alltraps>

80106dd3 <vector141>:
.globl vector141
vector141:
  pushl $0
80106dd3:	6a 00                	push   $0x0
  pushl $141
80106dd5:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106dda:	e9 a0 f3 ff ff       	jmp    8010617f <alltraps>

80106ddf <vector142>:
.globl vector142
vector142:
  pushl $0
80106ddf:	6a 00                	push   $0x0
  pushl $142
80106de1:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106de6:	e9 94 f3 ff ff       	jmp    8010617f <alltraps>

80106deb <vector143>:
.globl vector143
vector143:
  pushl $0
80106deb:	6a 00                	push   $0x0
  pushl $143
80106ded:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106df2:	e9 88 f3 ff ff       	jmp    8010617f <alltraps>

80106df7 <vector144>:
.globl vector144
vector144:
  pushl $0
80106df7:	6a 00                	push   $0x0
  pushl $144
80106df9:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106dfe:	e9 7c f3 ff ff       	jmp    8010617f <alltraps>

80106e03 <vector145>:
.globl vector145
vector145:
  pushl $0
80106e03:	6a 00                	push   $0x0
  pushl $145
80106e05:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106e0a:	e9 70 f3 ff ff       	jmp    8010617f <alltraps>

80106e0f <vector146>:
.globl vector146
vector146:
  pushl $0
80106e0f:	6a 00                	push   $0x0
  pushl $146
80106e11:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106e16:	e9 64 f3 ff ff       	jmp    8010617f <alltraps>

80106e1b <vector147>:
.globl vector147
vector147:
  pushl $0
80106e1b:	6a 00                	push   $0x0
  pushl $147
80106e1d:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106e22:	e9 58 f3 ff ff       	jmp    8010617f <alltraps>

80106e27 <vector148>:
.globl vector148
vector148:
  pushl $0
80106e27:	6a 00                	push   $0x0
  pushl $148
80106e29:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106e2e:	e9 4c f3 ff ff       	jmp    8010617f <alltraps>

80106e33 <vector149>:
.globl vector149
vector149:
  pushl $0
80106e33:	6a 00                	push   $0x0
  pushl $149
80106e35:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106e3a:	e9 40 f3 ff ff       	jmp    8010617f <alltraps>

80106e3f <vector150>:
.globl vector150
vector150:
  pushl $0
80106e3f:	6a 00                	push   $0x0
  pushl $150
80106e41:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106e46:	e9 34 f3 ff ff       	jmp    8010617f <alltraps>

80106e4b <vector151>:
.globl vector151
vector151:
  pushl $0
80106e4b:	6a 00                	push   $0x0
  pushl $151
80106e4d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106e52:	e9 28 f3 ff ff       	jmp    8010617f <alltraps>

80106e57 <vector152>:
.globl vector152
vector152:
  pushl $0
80106e57:	6a 00                	push   $0x0
  pushl $152
80106e59:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106e5e:	e9 1c f3 ff ff       	jmp    8010617f <alltraps>

80106e63 <vector153>:
.globl vector153
vector153:
  pushl $0
80106e63:	6a 00                	push   $0x0
  pushl $153
80106e65:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106e6a:	e9 10 f3 ff ff       	jmp    8010617f <alltraps>

80106e6f <vector154>:
.globl vector154
vector154:
  pushl $0
80106e6f:	6a 00                	push   $0x0
  pushl $154
80106e71:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106e76:	e9 04 f3 ff ff       	jmp    8010617f <alltraps>

80106e7b <vector155>:
.globl vector155
vector155:
  pushl $0
80106e7b:	6a 00                	push   $0x0
  pushl $155
80106e7d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106e82:	e9 f8 f2 ff ff       	jmp    8010617f <alltraps>

80106e87 <vector156>:
.globl vector156
vector156:
  pushl $0
80106e87:	6a 00                	push   $0x0
  pushl $156
80106e89:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106e8e:	e9 ec f2 ff ff       	jmp    8010617f <alltraps>

80106e93 <vector157>:
.globl vector157
vector157:
  pushl $0
80106e93:	6a 00                	push   $0x0
  pushl $157
80106e95:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106e9a:	e9 e0 f2 ff ff       	jmp    8010617f <alltraps>

80106e9f <vector158>:
.globl vector158
vector158:
  pushl $0
80106e9f:	6a 00                	push   $0x0
  pushl $158
80106ea1:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106ea6:	e9 d4 f2 ff ff       	jmp    8010617f <alltraps>

80106eab <vector159>:
.globl vector159
vector159:
  pushl $0
80106eab:	6a 00                	push   $0x0
  pushl $159
80106ead:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106eb2:	e9 c8 f2 ff ff       	jmp    8010617f <alltraps>

80106eb7 <vector160>:
.globl vector160
vector160:
  pushl $0
80106eb7:	6a 00                	push   $0x0
  pushl $160
80106eb9:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106ebe:	e9 bc f2 ff ff       	jmp    8010617f <alltraps>

80106ec3 <vector161>:
.globl vector161
vector161:
  pushl $0
80106ec3:	6a 00                	push   $0x0
  pushl $161
80106ec5:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106eca:	e9 b0 f2 ff ff       	jmp    8010617f <alltraps>

80106ecf <vector162>:
.globl vector162
vector162:
  pushl $0
80106ecf:	6a 00                	push   $0x0
  pushl $162
80106ed1:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106ed6:	e9 a4 f2 ff ff       	jmp    8010617f <alltraps>

80106edb <vector163>:
.globl vector163
vector163:
  pushl $0
80106edb:	6a 00                	push   $0x0
  pushl $163
80106edd:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106ee2:	e9 98 f2 ff ff       	jmp    8010617f <alltraps>

80106ee7 <vector164>:
.globl vector164
vector164:
  pushl $0
80106ee7:	6a 00                	push   $0x0
  pushl $164
80106ee9:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106eee:	e9 8c f2 ff ff       	jmp    8010617f <alltraps>

80106ef3 <vector165>:
.globl vector165
vector165:
  pushl $0
80106ef3:	6a 00                	push   $0x0
  pushl $165
80106ef5:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106efa:	e9 80 f2 ff ff       	jmp    8010617f <alltraps>

80106eff <vector166>:
.globl vector166
vector166:
  pushl $0
80106eff:	6a 00                	push   $0x0
  pushl $166
80106f01:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106f06:	e9 74 f2 ff ff       	jmp    8010617f <alltraps>

80106f0b <vector167>:
.globl vector167
vector167:
  pushl $0
80106f0b:	6a 00                	push   $0x0
  pushl $167
80106f0d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106f12:	e9 68 f2 ff ff       	jmp    8010617f <alltraps>

80106f17 <vector168>:
.globl vector168
vector168:
  pushl $0
80106f17:	6a 00                	push   $0x0
  pushl $168
80106f19:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106f1e:	e9 5c f2 ff ff       	jmp    8010617f <alltraps>

80106f23 <vector169>:
.globl vector169
vector169:
  pushl $0
80106f23:	6a 00                	push   $0x0
  pushl $169
80106f25:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106f2a:	e9 50 f2 ff ff       	jmp    8010617f <alltraps>

80106f2f <vector170>:
.globl vector170
vector170:
  pushl $0
80106f2f:	6a 00                	push   $0x0
  pushl $170
80106f31:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106f36:	e9 44 f2 ff ff       	jmp    8010617f <alltraps>

80106f3b <vector171>:
.globl vector171
vector171:
  pushl $0
80106f3b:	6a 00                	push   $0x0
  pushl $171
80106f3d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106f42:	e9 38 f2 ff ff       	jmp    8010617f <alltraps>

80106f47 <vector172>:
.globl vector172
vector172:
  pushl $0
80106f47:	6a 00                	push   $0x0
  pushl $172
80106f49:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106f4e:	e9 2c f2 ff ff       	jmp    8010617f <alltraps>

80106f53 <vector173>:
.globl vector173
vector173:
  pushl $0
80106f53:	6a 00                	push   $0x0
  pushl $173
80106f55:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106f5a:	e9 20 f2 ff ff       	jmp    8010617f <alltraps>

80106f5f <vector174>:
.globl vector174
vector174:
  pushl $0
80106f5f:	6a 00                	push   $0x0
  pushl $174
80106f61:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106f66:	e9 14 f2 ff ff       	jmp    8010617f <alltraps>

80106f6b <vector175>:
.globl vector175
vector175:
  pushl $0
80106f6b:	6a 00                	push   $0x0
  pushl $175
80106f6d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106f72:	e9 08 f2 ff ff       	jmp    8010617f <alltraps>

80106f77 <vector176>:
.globl vector176
vector176:
  pushl $0
80106f77:	6a 00                	push   $0x0
  pushl $176
80106f79:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106f7e:	e9 fc f1 ff ff       	jmp    8010617f <alltraps>

80106f83 <vector177>:
.globl vector177
vector177:
  pushl $0
80106f83:	6a 00                	push   $0x0
  pushl $177
80106f85:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106f8a:	e9 f0 f1 ff ff       	jmp    8010617f <alltraps>

80106f8f <vector178>:
.globl vector178
vector178:
  pushl $0
80106f8f:	6a 00                	push   $0x0
  pushl $178
80106f91:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106f96:	e9 e4 f1 ff ff       	jmp    8010617f <alltraps>

80106f9b <vector179>:
.globl vector179
vector179:
  pushl $0
80106f9b:	6a 00                	push   $0x0
  pushl $179
80106f9d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106fa2:	e9 d8 f1 ff ff       	jmp    8010617f <alltraps>

80106fa7 <vector180>:
.globl vector180
vector180:
  pushl $0
80106fa7:	6a 00                	push   $0x0
  pushl $180
80106fa9:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106fae:	e9 cc f1 ff ff       	jmp    8010617f <alltraps>

80106fb3 <vector181>:
.globl vector181
vector181:
  pushl $0
80106fb3:	6a 00                	push   $0x0
  pushl $181
80106fb5:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106fba:	e9 c0 f1 ff ff       	jmp    8010617f <alltraps>

80106fbf <vector182>:
.globl vector182
vector182:
  pushl $0
80106fbf:	6a 00                	push   $0x0
  pushl $182
80106fc1:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106fc6:	e9 b4 f1 ff ff       	jmp    8010617f <alltraps>

80106fcb <vector183>:
.globl vector183
vector183:
  pushl $0
80106fcb:	6a 00                	push   $0x0
  pushl $183
80106fcd:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106fd2:	e9 a8 f1 ff ff       	jmp    8010617f <alltraps>

80106fd7 <vector184>:
.globl vector184
vector184:
  pushl $0
80106fd7:	6a 00                	push   $0x0
  pushl $184
80106fd9:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106fde:	e9 9c f1 ff ff       	jmp    8010617f <alltraps>

80106fe3 <vector185>:
.globl vector185
vector185:
  pushl $0
80106fe3:	6a 00                	push   $0x0
  pushl $185
80106fe5:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106fea:	e9 90 f1 ff ff       	jmp    8010617f <alltraps>

80106fef <vector186>:
.globl vector186
vector186:
  pushl $0
80106fef:	6a 00                	push   $0x0
  pushl $186
80106ff1:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106ff6:	e9 84 f1 ff ff       	jmp    8010617f <alltraps>

80106ffb <vector187>:
.globl vector187
vector187:
  pushl $0
80106ffb:	6a 00                	push   $0x0
  pushl $187
80106ffd:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107002:	e9 78 f1 ff ff       	jmp    8010617f <alltraps>

80107007 <vector188>:
.globl vector188
vector188:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $188
80107009:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010700e:	e9 6c f1 ff ff       	jmp    8010617f <alltraps>

80107013 <vector189>:
.globl vector189
vector189:
  pushl $0
80107013:	6a 00                	push   $0x0
  pushl $189
80107015:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010701a:	e9 60 f1 ff ff       	jmp    8010617f <alltraps>

8010701f <vector190>:
.globl vector190
vector190:
  pushl $0
8010701f:	6a 00                	push   $0x0
  pushl $190
80107021:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107026:	e9 54 f1 ff ff       	jmp    8010617f <alltraps>

8010702b <vector191>:
.globl vector191
vector191:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $191
8010702d:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107032:	e9 48 f1 ff ff       	jmp    8010617f <alltraps>

80107037 <vector192>:
.globl vector192
vector192:
  pushl $0
80107037:	6a 00                	push   $0x0
  pushl $192
80107039:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010703e:	e9 3c f1 ff ff       	jmp    8010617f <alltraps>

80107043 <vector193>:
.globl vector193
vector193:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $193
80107045:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010704a:	e9 30 f1 ff ff       	jmp    8010617f <alltraps>

8010704f <vector194>:
.globl vector194
vector194:
  pushl $0
8010704f:	6a 00                	push   $0x0
  pushl $194
80107051:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107056:	e9 24 f1 ff ff       	jmp    8010617f <alltraps>

8010705b <vector195>:
.globl vector195
vector195:
  pushl $0
8010705b:	6a 00                	push   $0x0
  pushl $195
8010705d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107062:	e9 18 f1 ff ff       	jmp    8010617f <alltraps>

80107067 <vector196>:
.globl vector196
vector196:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $196
80107069:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010706e:	e9 0c f1 ff ff       	jmp    8010617f <alltraps>

80107073 <vector197>:
.globl vector197
vector197:
  pushl $0
80107073:	6a 00                	push   $0x0
  pushl $197
80107075:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010707a:	e9 00 f1 ff ff       	jmp    8010617f <alltraps>

8010707f <vector198>:
.globl vector198
vector198:
  pushl $0
8010707f:	6a 00                	push   $0x0
  pushl $198
80107081:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107086:	e9 f4 f0 ff ff       	jmp    8010617f <alltraps>

8010708b <vector199>:
.globl vector199
vector199:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $199
8010708d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107092:	e9 e8 f0 ff ff       	jmp    8010617f <alltraps>

80107097 <vector200>:
.globl vector200
vector200:
  pushl $0
80107097:	6a 00                	push   $0x0
  pushl $200
80107099:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010709e:	e9 dc f0 ff ff       	jmp    8010617f <alltraps>

801070a3 <vector201>:
.globl vector201
vector201:
  pushl $0
801070a3:	6a 00                	push   $0x0
  pushl $201
801070a5:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801070aa:	e9 d0 f0 ff ff       	jmp    8010617f <alltraps>

801070af <vector202>:
.globl vector202
vector202:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $202
801070b1:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801070b6:	e9 c4 f0 ff ff       	jmp    8010617f <alltraps>

801070bb <vector203>:
.globl vector203
vector203:
  pushl $0
801070bb:	6a 00                	push   $0x0
  pushl $203
801070bd:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801070c2:	e9 b8 f0 ff ff       	jmp    8010617f <alltraps>

801070c7 <vector204>:
.globl vector204
vector204:
  pushl $0
801070c7:	6a 00                	push   $0x0
  pushl $204
801070c9:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801070ce:	e9 ac f0 ff ff       	jmp    8010617f <alltraps>

801070d3 <vector205>:
.globl vector205
vector205:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $205
801070d5:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801070da:	e9 a0 f0 ff ff       	jmp    8010617f <alltraps>

801070df <vector206>:
.globl vector206
vector206:
  pushl $0
801070df:	6a 00                	push   $0x0
  pushl $206
801070e1:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801070e6:	e9 94 f0 ff ff       	jmp    8010617f <alltraps>

801070eb <vector207>:
.globl vector207
vector207:
  pushl $0
801070eb:	6a 00                	push   $0x0
  pushl $207
801070ed:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801070f2:	e9 88 f0 ff ff       	jmp    8010617f <alltraps>

801070f7 <vector208>:
.globl vector208
vector208:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $208
801070f9:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801070fe:	e9 7c f0 ff ff       	jmp    8010617f <alltraps>

80107103 <vector209>:
.globl vector209
vector209:
  pushl $0
80107103:	6a 00                	push   $0x0
  pushl $209
80107105:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010710a:	e9 70 f0 ff ff       	jmp    8010617f <alltraps>

8010710f <vector210>:
.globl vector210
vector210:
  pushl $0
8010710f:	6a 00                	push   $0x0
  pushl $210
80107111:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107116:	e9 64 f0 ff ff       	jmp    8010617f <alltraps>

8010711b <vector211>:
.globl vector211
vector211:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $211
8010711d:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107122:	e9 58 f0 ff ff       	jmp    8010617f <alltraps>

80107127 <vector212>:
.globl vector212
vector212:
  pushl $0
80107127:	6a 00                	push   $0x0
  pushl $212
80107129:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010712e:	e9 4c f0 ff ff       	jmp    8010617f <alltraps>

80107133 <vector213>:
.globl vector213
vector213:
  pushl $0
80107133:	6a 00                	push   $0x0
  pushl $213
80107135:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010713a:	e9 40 f0 ff ff       	jmp    8010617f <alltraps>

8010713f <vector214>:
.globl vector214
vector214:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $214
80107141:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107146:	e9 34 f0 ff ff       	jmp    8010617f <alltraps>

8010714b <vector215>:
.globl vector215
vector215:
  pushl $0
8010714b:	6a 00                	push   $0x0
  pushl $215
8010714d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107152:	e9 28 f0 ff ff       	jmp    8010617f <alltraps>

80107157 <vector216>:
.globl vector216
vector216:
  pushl $0
80107157:	6a 00                	push   $0x0
  pushl $216
80107159:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010715e:	e9 1c f0 ff ff       	jmp    8010617f <alltraps>

80107163 <vector217>:
.globl vector217
vector217:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $217
80107165:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010716a:	e9 10 f0 ff ff       	jmp    8010617f <alltraps>

8010716f <vector218>:
.globl vector218
vector218:
  pushl $0
8010716f:	6a 00                	push   $0x0
  pushl $218
80107171:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107176:	e9 04 f0 ff ff       	jmp    8010617f <alltraps>

8010717b <vector219>:
.globl vector219
vector219:
  pushl $0
8010717b:	6a 00                	push   $0x0
  pushl $219
8010717d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107182:	e9 f8 ef ff ff       	jmp    8010617f <alltraps>

80107187 <vector220>:
.globl vector220
vector220:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $220
80107189:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010718e:	e9 ec ef ff ff       	jmp    8010617f <alltraps>

80107193 <vector221>:
.globl vector221
vector221:
  pushl $0
80107193:	6a 00                	push   $0x0
  pushl $221
80107195:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010719a:	e9 e0 ef ff ff       	jmp    8010617f <alltraps>

8010719f <vector222>:
.globl vector222
vector222:
  pushl $0
8010719f:	6a 00                	push   $0x0
  pushl $222
801071a1:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801071a6:	e9 d4 ef ff ff       	jmp    8010617f <alltraps>

801071ab <vector223>:
.globl vector223
vector223:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $223
801071ad:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801071b2:	e9 c8 ef ff ff       	jmp    8010617f <alltraps>

801071b7 <vector224>:
.globl vector224
vector224:
  pushl $0
801071b7:	6a 00                	push   $0x0
  pushl $224
801071b9:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801071be:	e9 bc ef ff ff       	jmp    8010617f <alltraps>

801071c3 <vector225>:
.globl vector225
vector225:
  pushl $0
801071c3:	6a 00                	push   $0x0
  pushl $225
801071c5:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801071ca:	e9 b0 ef ff ff       	jmp    8010617f <alltraps>

801071cf <vector226>:
.globl vector226
vector226:
  pushl $0
801071cf:	6a 00                	push   $0x0
  pushl $226
801071d1:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801071d6:	e9 a4 ef ff ff       	jmp    8010617f <alltraps>

801071db <vector227>:
.globl vector227
vector227:
  pushl $0
801071db:	6a 00                	push   $0x0
  pushl $227
801071dd:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801071e2:	e9 98 ef ff ff       	jmp    8010617f <alltraps>

801071e7 <vector228>:
.globl vector228
vector228:
  pushl $0
801071e7:	6a 00                	push   $0x0
  pushl $228
801071e9:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801071ee:	e9 8c ef ff ff       	jmp    8010617f <alltraps>

801071f3 <vector229>:
.globl vector229
vector229:
  pushl $0
801071f3:	6a 00                	push   $0x0
  pushl $229
801071f5:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801071fa:	e9 80 ef ff ff       	jmp    8010617f <alltraps>

801071ff <vector230>:
.globl vector230
vector230:
  pushl $0
801071ff:	6a 00                	push   $0x0
  pushl $230
80107201:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107206:	e9 74 ef ff ff       	jmp    8010617f <alltraps>

8010720b <vector231>:
.globl vector231
vector231:
  pushl $0
8010720b:	6a 00                	push   $0x0
  pushl $231
8010720d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107212:	e9 68 ef ff ff       	jmp    8010617f <alltraps>

80107217 <vector232>:
.globl vector232
vector232:
  pushl $0
80107217:	6a 00                	push   $0x0
  pushl $232
80107219:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010721e:	e9 5c ef ff ff       	jmp    8010617f <alltraps>

80107223 <vector233>:
.globl vector233
vector233:
  pushl $0
80107223:	6a 00                	push   $0x0
  pushl $233
80107225:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010722a:	e9 50 ef ff ff       	jmp    8010617f <alltraps>

8010722f <vector234>:
.globl vector234
vector234:
  pushl $0
8010722f:	6a 00                	push   $0x0
  pushl $234
80107231:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107236:	e9 44 ef ff ff       	jmp    8010617f <alltraps>

8010723b <vector235>:
.globl vector235
vector235:
  pushl $0
8010723b:	6a 00                	push   $0x0
  pushl $235
8010723d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107242:	e9 38 ef ff ff       	jmp    8010617f <alltraps>

80107247 <vector236>:
.globl vector236
vector236:
  pushl $0
80107247:	6a 00                	push   $0x0
  pushl $236
80107249:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010724e:	e9 2c ef ff ff       	jmp    8010617f <alltraps>

80107253 <vector237>:
.globl vector237
vector237:
  pushl $0
80107253:	6a 00                	push   $0x0
  pushl $237
80107255:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010725a:	e9 20 ef ff ff       	jmp    8010617f <alltraps>

8010725f <vector238>:
.globl vector238
vector238:
  pushl $0
8010725f:	6a 00                	push   $0x0
  pushl $238
80107261:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107266:	e9 14 ef ff ff       	jmp    8010617f <alltraps>

8010726b <vector239>:
.globl vector239
vector239:
  pushl $0
8010726b:	6a 00                	push   $0x0
  pushl $239
8010726d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107272:	e9 08 ef ff ff       	jmp    8010617f <alltraps>

80107277 <vector240>:
.globl vector240
vector240:
  pushl $0
80107277:	6a 00                	push   $0x0
  pushl $240
80107279:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010727e:	e9 fc ee ff ff       	jmp    8010617f <alltraps>

80107283 <vector241>:
.globl vector241
vector241:
  pushl $0
80107283:	6a 00                	push   $0x0
  pushl $241
80107285:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010728a:	e9 f0 ee ff ff       	jmp    8010617f <alltraps>

8010728f <vector242>:
.globl vector242
vector242:
  pushl $0
8010728f:	6a 00                	push   $0x0
  pushl $242
80107291:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107296:	e9 e4 ee ff ff       	jmp    8010617f <alltraps>

8010729b <vector243>:
.globl vector243
vector243:
  pushl $0
8010729b:	6a 00                	push   $0x0
  pushl $243
8010729d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801072a2:	e9 d8 ee ff ff       	jmp    8010617f <alltraps>

801072a7 <vector244>:
.globl vector244
vector244:
  pushl $0
801072a7:	6a 00                	push   $0x0
  pushl $244
801072a9:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801072ae:	e9 cc ee ff ff       	jmp    8010617f <alltraps>

801072b3 <vector245>:
.globl vector245
vector245:
  pushl $0
801072b3:	6a 00                	push   $0x0
  pushl $245
801072b5:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801072ba:	e9 c0 ee ff ff       	jmp    8010617f <alltraps>

801072bf <vector246>:
.globl vector246
vector246:
  pushl $0
801072bf:	6a 00                	push   $0x0
  pushl $246
801072c1:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801072c6:	e9 b4 ee ff ff       	jmp    8010617f <alltraps>

801072cb <vector247>:
.globl vector247
vector247:
  pushl $0
801072cb:	6a 00                	push   $0x0
  pushl $247
801072cd:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801072d2:	e9 a8 ee ff ff       	jmp    8010617f <alltraps>

801072d7 <vector248>:
.globl vector248
vector248:
  pushl $0
801072d7:	6a 00                	push   $0x0
  pushl $248
801072d9:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801072de:	e9 9c ee ff ff       	jmp    8010617f <alltraps>

801072e3 <vector249>:
.globl vector249
vector249:
  pushl $0
801072e3:	6a 00                	push   $0x0
  pushl $249
801072e5:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801072ea:	e9 90 ee ff ff       	jmp    8010617f <alltraps>

801072ef <vector250>:
.globl vector250
vector250:
  pushl $0
801072ef:	6a 00                	push   $0x0
  pushl $250
801072f1:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801072f6:	e9 84 ee ff ff       	jmp    8010617f <alltraps>

801072fb <vector251>:
.globl vector251
vector251:
  pushl $0
801072fb:	6a 00                	push   $0x0
  pushl $251
801072fd:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107302:	e9 78 ee ff ff       	jmp    8010617f <alltraps>

80107307 <vector252>:
.globl vector252
vector252:
  pushl $0
80107307:	6a 00                	push   $0x0
  pushl $252
80107309:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010730e:	e9 6c ee ff ff       	jmp    8010617f <alltraps>

80107313 <vector253>:
.globl vector253
vector253:
  pushl $0
80107313:	6a 00                	push   $0x0
  pushl $253
80107315:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010731a:	e9 60 ee ff ff       	jmp    8010617f <alltraps>

8010731f <vector254>:
.globl vector254
vector254:
  pushl $0
8010731f:	6a 00                	push   $0x0
  pushl $254
80107321:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107326:	e9 54 ee ff ff       	jmp    8010617f <alltraps>

8010732b <vector255>:
.globl vector255
vector255:
  pushl $0
8010732b:	6a 00                	push   $0x0
  pushl $255
8010732d:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107332:	e9 48 ee ff ff       	jmp    8010617f <alltraps>

80107337 <lgdt>:
{
80107337:	55                   	push   %ebp
80107338:	89 e5                	mov    %esp,%ebp
8010733a:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010733d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107340:	83 e8 01             	sub    $0x1,%eax
80107343:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107347:	8b 45 08             	mov    0x8(%ebp),%eax
8010734a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010734e:	8b 45 08             	mov    0x8(%ebp),%eax
80107351:	c1 e8 10             	shr    $0x10,%eax
80107354:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107358:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010735b:	0f 01 10             	lgdtl  (%eax)
}
8010735e:	90                   	nop
8010735f:	c9                   	leave
80107360:	c3                   	ret

80107361 <ltr>:
{
80107361:	55                   	push   %ebp
80107362:	89 e5                	mov    %esp,%ebp
80107364:	83 ec 04             	sub    $0x4,%esp
80107367:	8b 45 08             	mov    0x8(%ebp),%eax
8010736a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010736e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107372:	0f 00 d8             	ltr    %eax
}
80107375:	90                   	nop
80107376:	c9                   	leave
80107377:	c3                   	ret

80107378 <lcr3>:

static inline void
lcr3(uint val)
{
80107378:	55                   	push   %ebp
80107379:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010737b:	8b 45 08             	mov    0x8(%ebp),%eax
8010737e:	0f 22 d8             	mov    %eax,%cr3
}
80107381:	90                   	nop
80107382:	5d                   	pop    %ebp
80107383:	c3                   	ret

80107384 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107384:	f3 0f 1e fb          	endbr32
80107388:	55                   	push   %ebp
80107389:	89 e5                	mov    %esp,%ebp
8010738b:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010738e:	e8 8b c7 ff ff       	call   80103b1e <cpuid>
80107393:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107399:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
8010739e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801073a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a4:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801073aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ad:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801073b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b6:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801073ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073bd:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073c1:	83 e2 f0             	and    $0xfffffff0,%edx
801073c4:	83 ca 0a             	or     $0xa,%edx
801073c7:	88 50 7d             	mov    %dl,0x7d(%eax)
801073ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073cd:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073d1:	83 ca 10             	or     $0x10,%edx
801073d4:	88 50 7d             	mov    %dl,0x7d(%eax)
801073d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073da:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073de:	83 e2 9f             	and    $0xffffff9f,%edx
801073e1:	88 50 7d             	mov    %dl,0x7d(%eax)
801073e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073eb:	83 ca 80             	or     $0xffffff80,%edx
801073ee:	88 50 7d             	mov    %dl,0x7d(%eax)
801073f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073f8:	83 ca 0f             	or     $0xf,%edx
801073fb:	88 50 7e             	mov    %dl,0x7e(%eax)
801073fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107401:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107405:	83 e2 ef             	and    $0xffffffef,%edx
80107408:	88 50 7e             	mov    %dl,0x7e(%eax)
8010740b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010740e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107412:	83 e2 df             	and    $0xffffffdf,%edx
80107415:	88 50 7e             	mov    %dl,0x7e(%eax)
80107418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010741f:	83 ca 40             	or     $0x40,%edx
80107422:	88 50 7e             	mov    %dl,0x7e(%eax)
80107425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107428:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010742c:	83 ca 80             	or     $0xffffff80,%edx
8010742f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107432:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107435:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107439:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107443:	ff ff 
80107445:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107448:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010744f:	00 00 
80107451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107454:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010745b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010745e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107465:	83 e2 f0             	and    $0xfffffff0,%edx
80107468:	83 ca 02             	or     $0x2,%edx
8010746b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107471:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107474:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010747b:	83 ca 10             	or     $0x10,%edx
8010747e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107487:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010748e:	83 e2 9f             	and    $0xffffff9f,%edx
80107491:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107497:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010749a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074a1:	83 ca 80             	or     $0xffffff80,%edx
801074a4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ad:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074b4:	83 ca 0f             	or     $0xf,%edx
801074b7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074c7:	83 e2 ef             	and    $0xffffffef,%edx
801074ca:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074da:	83 e2 df             	and    $0xffffffdf,%edx
801074dd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074ed:	83 ca 40             	or     $0x40,%edx
801074f0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107500:	83 ca 80             	or     $0xffffff80,%edx
80107503:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010750c:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107516:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010751d:	ff ff 
8010751f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107522:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107529:	00 00 
8010752b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752e:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107538:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010753f:	83 e2 f0             	and    $0xfffffff0,%edx
80107542:	83 ca 0a             	or     $0xa,%edx
80107545:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010754b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010754e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107555:	83 ca 10             	or     $0x10,%edx
80107558:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010755e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107561:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107568:	83 ca 60             	or     $0x60,%edx
8010756b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107574:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010757b:	83 ca 80             	or     $0xffffff80,%edx
8010757e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107587:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010758e:	83 ca 0f             	or     $0xf,%edx
80107591:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075a1:	83 e2 ef             	and    $0xffffffef,%edx
801075a4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ad:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075b4:	83 e2 df             	and    $0xffffffdf,%edx
801075b7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c0:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075c7:	83 ca 40             	or     $0x40,%edx
801075ca:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d3:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075da:	83 ca 80             	or     $0xffffff80,%edx
801075dd:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e6:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801075ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f0:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801075f7:	ff ff 
801075f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075fc:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107603:	00 00 
80107605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107608:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010760f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107612:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107619:	83 e2 f0             	and    $0xfffffff0,%edx
8010761c:	83 ca 02             	or     $0x2,%edx
8010761f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107628:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010762f:	83 ca 10             	or     $0x10,%edx
80107632:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107642:	83 ca 60             	or     $0x60,%edx
80107645:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010764b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107655:	83 ca 80             	or     $0xffffff80,%edx
80107658:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010765e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107661:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107668:	83 ca 0f             	or     $0xf,%edx
8010766b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107674:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010767b:	83 e2 ef             	and    $0xffffffef,%edx
8010767e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107687:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010768e:	83 e2 df             	and    $0xffffffdf,%edx
80107691:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801076a1:	83 ca 40             	or     $0x40,%edx
801076a4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801076aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ad:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801076b4:	83 ca 80             	or     $0xffffff80,%edx
801076b7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801076bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c0:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801076c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ca:	83 c0 70             	add    $0x70,%eax
801076cd:	83 ec 08             	sub    $0x8,%esp
801076d0:	6a 30                	push   $0x30
801076d2:	50                   	push   %eax
801076d3:	e8 5f fc ff ff       	call   80107337 <lgdt>
801076d8:	83 c4 10             	add    $0x10,%esp
}
801076db:	90                   	nop
801076dc:	c9                   	leave
801076dd:	c3                   	ret

801076de <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
/*static 전역에서 사용해야 함*/ pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801076de:	f3 0f 1e fb          	endbr32
801076e2:	55                   	push   %ebp
801076e3:	89 e5                	mov    %esp,%ebp
801076e5:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801076e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801076eb:	c1 e8 16             	shr    $0x16,%eax
801076ee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801076f5:	8b 45 08             	mov    0x8(%ebp),%eax
801076f8:	01 d0                	add    %edx,%eax
801076fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801076fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107700:	8b 00                	mov    (%eax),%eax
80107702:	83 e0 01             	and    $0x1,%eax
80107705:	85 c0                	test   %eax,%eax
80107707:	74 14                	je     8010771d <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107709:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010770c:	8b 00                	mov    (%eax),%eax
8010770e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107713:	05 00 00 00 80       	add    $0x80000000,%eax
80107718:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010771b:	eb 42                	jmp    8010775f <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010771d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107721:	74 0e                	je     80107731 <walkpgdir+0x53>
80107723:	e8 7a b1 ff ff       	call   801028a2 <kalloc>
80107728:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010772b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010772f:	75 07                	jne    80107738 <walkpgdir+0x5a>
      return 0;
80107731:	b8 00 00 00 00       	mov    $0x0,%eax
80107736:	eb 3e                	jmp    80107776 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107738:	83 ec 04             	sub    $0x4,%esp
8010773b:	68 00 10 00 00       	push   $0x1000
80107740:	6a 00                	push   $0x0
80107742:	ff 75 f4             	push   -0xc(%ebp)
80107745:	e8 92 d5 ff ff       	call   80104cdc <memset>
8010774a:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010774d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107750:	05 00 00 00 80       	add    $0x80000000,%eax
80107755:	83 c8 07             	or     $0x7,%eax
80107758:	89 c2                	mov    %eax,%edx
8010775a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010775d:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010775f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107762:	c1 e8 0c             	shr    $0xc,%eax
80107765:	25 ff 03 00 00       	and    $0x3ff,%eax
8010776a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107774:	01 d0                	add    %edx,%eax
}
80107776:	c9                   	leave
80107777:	c3                   	ret

80107778 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
/*static 전역에서 사용해야 함*/ int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107778:	f3 0f 1e fb          	endbr32
8010777c:	55                   	push   %ebp
8010777d:	89 e5                	mov    %esp,%ebp
8010777f:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107782:	8b 45 0c             	mov    0xc(%ebp),%eax
80107785:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010778a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010778d:	8b 55 0c             	mov    0xc(%ebp),%edx
80107790:	8b 45 10             	mov    0x10(%ebp),%eax
80107793:	01 d0                	add    %edx,%eax
80107795:	83 e8 01             	sub    $0x1,%eax
80107798:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010779d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801077a0:	83 ec 04             	sub    $0x4,%esp
801077a3:	6a 01                	push   $0x1
801077a5:	ff 75 f4             	push   -0xc(%ebp)
801077a8:	ff 75 08             	push   0x8(%ebp)
801077ab:	e8 2e ff ff ff       	call   801076de <walkpgdir>
801077b0:	83 c4 10             	add    $0x10,%esp
801077b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801077b6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801077ba:	75 07                	jne    801077c3 <mappages+0x4b>
      return -1;
801077bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077c1:	eb 47                	jmp    8010780a <mappages+0x92>
    if(*pte & PTE_P)
801077c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801077c6:	8b 00                	mov    (%eax),%eax
801077c8:	83 e0 01             	and    $0x1,%eax
801077cb:	85 c0                	test   %eax,%eax
801077cd:	74 0d                	je     801077dc <mappages+0x64>
      panic("remap");
801077cf:	83 ec 0c             	sub    $0xc,%esp
801077d2:	68 e8 ac 10 80       	push   $0x8010ace8
801077d7:	e8 02 8e ff ff       	call   801005de <panic>
    *pte = pa | perm | PTE_P;
801077dc:	8b 45 18             	mov    0x18(%ebp),%eax
801077df:	0b 45 14             	or     0x14(%ebp),%eax
801077e2:	83 c8 01             	or     $0x1,%eax
801077e5:	89 c2                	mov    %eax,%edx
801077e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801077ea:	89 10                	mov    %edx,(%eax)
    if(a == last)
801077ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ef:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801077f2:	74 10                	je     80107804 <mappages+0x8c>
      break;
    a += PGSIZE;
801077f4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801077fb:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107802:	eb 9c                	jmp    801077a0 <mappages+0x28>
      break;
80107804:	90                   	nop
  }
  return 0;
80107805:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010780a:	c9                   	leave
8010780b:	c3                   	ret

8010780c <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010780c:	f3 0f 1e fb          	endbr32
80107810:	55                   	push   %ebp
80107811:	89 e5                	mov    %esp,%ebp
80107813:	53                   	push   %ebx
80107814:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107817:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
8010781e:	a1 8c 80 19 80       	mov    0x8019808c,%eax
80107823:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107828:	29 c2                	sub    %eax,%edx
8010782a:	89 d0                	mov    %edx,%eax
8010782c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010782f:	a1 84 80 19 80       	mov    0x80198084,%eax
80107834:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107837:	8b 15 84 80 19 80    	mov    0x80198084,%edx
8010783d:	a1 8c 80 19 80       	mov    0x8019808c,%eax
80107842:	01 d0                	add    %edx,%eax
80107844:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107847:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
8010784e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107851:	83 c0 30             	add    $0x30,%eax
80107854:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107857:	89 10                	mov    %edx,(%eax)
80107859:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010785c:	89 50 04             	mov    %edx,0x4(%eax)
8010785f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107862:	89 50 08             	mov    %edx,0x8(%eax)
80107865:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107868:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
8010786b:	e8 32 b0 ff ff       	call   801028a2 <kalloc>
80107870:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107873:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107877:	75 07                	jne    80107880 <setupkvm+0x74>
    return 0;
80107879:	b8 00 00 00 00       	mov    $0x0,%eax
8010787e:	eb 78                	jmp    801078f8 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
80107880:	83 ec 04             	sub    $0x4,%esp
80107883:	68 00 10 00 00       	push   $0x1000
80107888:	6a 00                	push   $0x0
8010788a:	ff 75 f0             	push   -0x10(%ebp)
8010788d:	e8 4a d4 ff ff       	call   80104cdc <memset>
80107892:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107895:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
8010789c:	eb 4e                	jmp    801078ec <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010789e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a1:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801078a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a7:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801078aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ad:	8b 58 08             	mov    0x8(%eax),%ebx
801078b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b3:	8b 40 04             	mov    0x4(%eax),%eax
801078b6:	29 c3                	sub    %eax,%ebx
801078b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bb:	8b 00                	mov    (%eax),%eax
801078bd:	83 ec 0c             	sub    $0xc,%esp
801078c0:	51                   	push   %ecx
801078c1:	52                   	push   %edx
801078c2:	53                   	push   %ebx
801078c3:	50                   	push   %eax
801078c4:	ff 75 f0             	push   -0x10(%ebp)
801078c7:	e8 ac fe ff ff       	call   80107778 <mappages>
801078cc:	83 c4 20             	add    $0x20,%esp
801078cf:	85 c0                	test   %eax,%eax
801078d1:	79 15                	jns    801078e8 <setupkvm+0xdc>
      freevm(pgdir);
801078d3:	83 ec 0c             	sub    $0xc,%esp
801078d6:	ff 75 f0             	push   -0x10(%ebp)
801078d9:	e8 21 05 00 00       	call   80107dff <freevm>
801078de:	83 c4 10             	add    $0x10,%esp
      return 0;
801078e1:	b8 00 00 00 00       	mov    $0x0,%eax
801078e6:	eb 10                	jmp    801078f8 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801078e8:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801078ec:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801078f3:	72 a9                	jb     8010789e <setupkvm+0x92>
    }
  return pgdir;
801078f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801078f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801078fb:	c9                   	leave
801078fc:	c3                   	ret

801078fd <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801078fd:	f3 0f 1e fb          	endbr32
80107901:	55                   	push   %ebp
80107902:	89 e5                	mov    %esp,%ebp
80107904:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107907:	e8 00 ff ff ff       	call   8010780c <setupkvm>
8010790c:	a3 84 7d 19 80       	mov    %eax,0x80197d84
  switchkvm();
80107911:	e8 03 00 00 00       	call   80107919 <switchkvm>
}
80107916:	90                   	nop
80107917:	c9                   	leave
80107918:	c3                   	ret

80107919 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107919:	f3 0f 1e fb          	endbr32
8010791d:	55                   	push   %ebp
8010791e:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107920:	a1 84 7d 19 80       	mov    0x80197d84,%eax
80107925:	05 00 00 00 80       	add    $0x80000000,%eax
8010792a:	50                   	push   %eax
8010792b:	e8 48 fa ff ff       	call   80107378 <lcr3>
80107930:	83 c4 04             	add    $0x4,%esp
}
80107933:	90                   	nop
80107934:	c9                   	leave
80107935:	c3                   	ret

80107936 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107936:	f3 0f 1e fb          	endbr32
8010793a:	55                   	push   %ebp
8010793b:	89 e5                	mov    %esp,%ebp
8010793d:	56                   	push   %esi
8010793e:	53                   	push   %ebx
8010793f:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107942:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107946:	75 0d                	jne    80107955 <switchuvm+0x1f>
    panic("switchuvm: no process");
80107948:	83 ec 0c             	sub    $0xc,%esp
8010794b:	68 ee ac 10 80       	push   $0x8010acee
80107950:	e8 89 8c ff ff       	call   801005de <panic>
  if(p->kstack == 0)
80107955:	8b 45 08             	mov    0x8(%ebp),%eax
80107958:	8b 40 08             	mov    0x8(%eax),%eax
8010795b:	85 c0                	test   %eax,%eax
8010795d:	75 0d                	jne    8010796c <switchuvm+0x36>
    panic("switchuvm: no kstack");
8010795f:	83 ec 0c             	sub    $0xc,%esp
80107962:	68 04 ad 10 80       	push   $0x8010ad04
80107967:	e8 72 8c ff ff       	call   801005de <panic>
  if(p->pgdir == 0)
8010796c:	8b 45 08             	mov    0x8(%ebp),%eax
8010796f:	8b 40 04             	mov    0x4(%eax),%eax
80107972:	85 c0                	test   %eax,%eax
80107974:	75 0d                	jne    80107983 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
80107976:	83 ec 0c             	sub    $0xc,%esp
80107979:	68 19 ad 10 80       	push   $0x8010ad19
8010797e:	e8 5b 8c ff ff       	call   801005de <panic>

  pushcli();
80107983:	e8 41 d2 ff ff       	call   80104bc9 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107988:	e8 b0 c1 ff ff       	call   80103b3d <mycpu>
8010798d:	89 c3                	mov    %eax,%ebx
8010798f:	e8 a9 c1 ff ff       	call   80103b3d <mycpu>
80107994:	83 c0 08             	add    $0x8,%eax
80107997:	89 c6                	mov    %eax,%esi
80107999:	e8 9f c1 ff ff       	call   80103b3d <mycpu>
8010799e:	83 c0 08             	add    $0x8,%eax
801079a1:	c1 e8 10             	shr    $0x10,%eax
801079a4:	88 45 f7             	mov    %al,-0x9(%ebp)
801079a7:	e8 91 c1 ff ff       	call   80103b3d <mycpu>
801079ac:	83 c0 08             	add    $0x8,%eax
801079af:	c1 e8 18             	shr    $0x18,%eax
801079b2:	89 c2                	mov    %eax,%edx
801079b4:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801079bb:	67 00 
801079bd:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801079c4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801079c8:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801079ce:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079d5:	83 e0 f0             	and    $0xfffffff0,%eax
801079d8:	83 c8 09             	or     $0x9,%eax
801079db:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079e1:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079e8:	83 c8 10             	or     $0x10,%eax
801079eb:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079f1:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079f8:	83 e0 9f             	and    $0xffffff9f,%eax
801079fb:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107a01:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107a08:	83 c8 80             	or     $0xffffff80,%eax
80107a0b:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107a11:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a18:	83 e0 f0             	and    $0xfffffff0,%eax
80107a1b:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a21:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a28:	83 e0 ef             	and    $0xffffffef,%eax
80107a2b:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a31:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a38:	83 e0 df             	and    $0xffffffdf,%eax
80107a3b:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a41:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a48:	83 c8 40             	or     $0x40,%eax
80107a4b:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a51:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a58:	83 e0 7f             	and    $0x7f,%eax
80107a5b:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a61:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107a67:	e8 d1 c0 ff ff       	call   80103b3d <mycpu>
80107a6c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a73:	83 e2 ef             	and    $0xffffffef,%edx
80107a76:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107a7c:	e8 bc c0 ff ff       	call   80103b3d <mycpu>
80107a81:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107a87:	8b 45 08             	mov    0x8(%ebp),%eax
80107a8a:	8b 40 08             	mov    0x8(%eax),%eax
80107a8d:	89 c3                	mov    %eax,%ebx
80107a8f:	e8 a9 c0 ff ff       	call   80103b3d <mycpu>
80107a94:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107a9a:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107a9d:	e8 9b c0 ff ff       	call   80103b3d <mycpu>
80107aa2:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107aa8:	83 ec 0c             	sub    $0xc,%esp
80107aab:	6a 28                	push   $0x28
80107aad:	e8 af f8 ff ff       	call   80107361 <ltr>
80107ab2:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80107ab8:	8b 40 04             	mov    0x4(%eax),%eax
80107abb:	05 00 00 00 80       	add    $0x80000000,%eax
80107ac0:	83 ec 0c             	sub    $0xc,%esp
80107ac3:	50                   	push   %eax
80107ac4:	e8 af f8 ff ff       	call   80107378 <lcr3>
80107ac9:	83 c4 10             	add    $0x10,%esp
  popcli();
80107acc:	e8 49 d1 ff ff       	call   80104c1a <popcli>
}
80107ad1:	90                   	nop
80107ad2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107ad5:	5b                   	pop    %ebx
80107ad6:	5e                   	pop    %esi
80107ad7:	5d                   	pop    %ebp
80107ad8:	c3                   	ret

80107ad9 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107ad9:	f3 0f 1e fb          	endbr32
80107add:	55                   	push   %ebp
80107ade:	89 e5                	mov    %esp,%ebp
80107ae0:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107ae3:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107aea:	76 0d                	jbe    80107af9 <inituvm+0x20>
    panic("inituvm: more than a page");
80107aec:	83 ec 0c             	sub    $0xc,%esp
80107aef:	68 2d ad 10 80       	push   $0x8010ad2d
80107af4:	e8 e5 8a ff ff       	call   801005de <panic>
  mem = kalloc();
80107af9:	e8 a4 ad ff ff       	call   801028a2 <kalloc>
80107afe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107b01:	83 ec 04             	sub    $0x4,%esp
80107b04:	68 00 10 00 00       	push   $0x1000
80107b09:	6a 00                	push   $0x0
80107b0b:	ff 75 f4             	push   -0xc(%ebp)
80107b0e:	e8 c9 d1 ff ff       	call   80104cdc <memset>
80107b13:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b19:	05 00 00 00 80       	add    $0x80000000,%eax
80107b1e:	83 ec 0c             	sub    $0xc,%esp
80107b21:	6a 06                	push   $0x6
80107b23:	50                   	push   %eax
80107b24:	68 00 10 00 00       	push   $0x1000
80107b29:	6a 00                	push   $0x0
80107b2b:	ff 75 08             	push   0x8(%ebp)
80107b2e:	e8 45 fc ff ff       	call   80107778 <mappages>
80107b33:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107b36:	83 ec 04             	sub    $0x4,%esp
80107b39:	ff 75 10             	push   0x10(%ebp)
80107b3c:	ff 75 0c             	push   0xc(%ebp)
80107b3f:	ff 75 f4             	push   -0xc(%ebp)
80107b42:	e8 5c d2 ff ff       	call   80104da3 <memmove>
80107b47:	83 c4 10             	add    $0x10,%esp
}
80107b4a:	90                   	nop
80107b4b:	c9                   	leave
80107b4c:	c3                   	ret

80107b4d <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107b4d:	f3 0f 1e fb          	endbr32
80107b51:	55                   	push   %ebp
80107b52:	89 e5                	mov    %esp,%ebp
80107b54:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107b57:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b5a:	25 ff 0f 00 00       	and    $0xfff,%eax
80107b5f:	85 c0                	test   %eax,%eax
80107b61:	74 0d                	je     80107b70 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80107b63:	83 ec 0c             	sub    $0xc,%esp
80107b66:	68 48 ad 10 80       	push   $0x8010ad48
80107b6b:	e8 6e 8a ff ff       	call   801005de <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107b70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b77:	e9 8f 00 00 00       	jmp    80107c0b <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b82:	01 d0                	add    %edx,%eax
80107b84:	83 ec 04             	sub    $0x4,%esp
80107b87:	6a 00                	push   $0x0
80107b89:	50                   	push   %eax
80107b8a:	ff 75 08             	push   0x8(%ebp)
80107b8d:	e8 4c fb ff ff       	call   801076de <walkpgdir>
80107b92:	83 c4 10             	add    $0x10,%esp
80107b95:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b98:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b9c:	75 0d                	jne    80107bab <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107b9e:	83 ec 0c             	sub    $0xc,%esp
80107ba1:	68 6b ad 10 80       	push   $0x8010ad6b
80107ba6:	e8 33 8a ff ff       	call   801005de <panic>
    pa = PTE_ADDR(*pte);
80107bab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bae:	8b 00                	mov    (%eax),%eax
80107bb0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bb5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107bb8:	8b 45 18             	mov    0x18(%ebp),%eax
80107bbb:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107bbe:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107bc3:	77 0b                	ja     80107bd0 <loaduvm+0x83>
      n = sz - i;
80107bc5:	8b 45 18             	mov    0x18(%ebp),%eax
80107bc8:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107bcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107bce:	eb 07                	jmp    80107bd7 <loaduvm+0x8a>
    else
      n = PGSIZE;
80107bd0:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107bd7:	8b 55 14             	mov    0x14(%ebp),%edx
80107bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdd:	01 d0                	add    %edx,%eax
80107bdf:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107be2:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107be8:	ff 75 f0             	push   -0x10(%ebp)
80107beb:	50                   	push   %eax
80107bec:	52                   	push   %edx
80107bed:	ff 75 10             	push   0x10(%ebp)
80107bf0:	e8 9f a3 ff ff       	call   80101f94 <readi>
80107bf5:	83 c4 10             	add    $0x10,%esp
80107bf8:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107bfb:	74 07                	je     80107c04 <loaduvm+0xb7>
      return -1;
80107bfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c02:	eb 18                	jmp    80107c1c <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80107c04:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0e:	3b 45 18             	cmp    0x18(%ebp),%eax
80107c11:	0f 82 65 ff ff ff    	jb     80107b7c <loaduvm+0x2f>
  }
  return 0;
80107c17:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c1c:	c9                   	leave
80107c1d:	c3                   	ret

80107c1e <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107c1e:	f3 0f 1e fb          	endbr32
80107c22:	55                   	push   %ebp
80107c23:	89 e5                	mov    %esp,%ebp
80107c25:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107c28:	8b 45 10             	mov    0x10(%ebp),%eax
80107c2b:	85 c0                	test   %eax,%eax
80107c2d:	79 0a                	jns    80107c39 <allocuvm+0x1b>
    return 0;
80107c2f:	b8 00 00 00 00       	mov    $0x0,%eax
80107c34:	e9 ec 00 00 00       	jmp    80107d25 <allocuvm+0x107>
  if(newsz < oldsz)
80107c39:	8b 45 10             	mov    0x10(%ebp),%eax
80107c3c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107c3f:	73 08                	jae    80107c49 <allocuvm+0x2b>
    return oldsz;
80107c41:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c44:	e9 dc 00 00 00       	jmp    80107d25 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80107c49:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c4c:	05 ff 0f 00 00       	add    $0xfff,%eax
80107c51:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c56:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107c59:	e9 b8 00 00 00       	jmp    80107d16 <allocuvm+0xf8>
    mem = kalloc();
80107c5e:	e8 3f ac ff ff       	call   801028a2 <kalloc>
80107c63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107c66:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c6a:	75 2e                	jne    80107c9a <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80107c6c:	83 ec 0c             	sub    $0xc,%esp
80107c6f:	68 89 ad 10 80       	push   $0x8010ad89
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
80107c95:	e9 8b 00 00 00       	jmp    80107d25 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80107c9a:	83 ec 04             	sub    $0x4,%esp
80107c9d:	68 00 10 00 00       	push   $0x1000
80107ca2:	6a 00                	push   $0x0
80107ca4:	ff 75 f0             	push   -0x10(%ebp)
80107ca7:	e8 30 d0 ff ff       	call   80104cdc <memset>
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
80107cca:	e8 a9 fa ff ff       	call   80107778 <mappages>
80107ccf:	83 c4 20             	add    $0x20,%esp
80107cd2:	85 c0                	test   %eax,%eax
80107cd4:	79 39                	jns    80107d0f <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80107cd6:	83 ec 0c             	sub    $0xc,%esp
80107cd9:	68 a1 ad 10 80       	push   $0x8010ada1
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
80107d00:	e8 ff aa ff ff       	call   80102804 <kfree>
80107d05:	83 c4 10             	add    $0x10,%esp
      return 0;
80107d08:	b8 00 00 00 00       	mov    $0x0,%eax
80107d0d:	eb 16                	jmp    80107d25 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80107d0f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d19:	3b 45 10             	cmp    0x10(%ebp),%eax
80107d1c:	0f 82 3c ff ff ff    	jb     80107c5e <allocuvm+0x40>
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
  cprintf("deallocuvm \n");
80107d31:	83 ec 0c             	sub    $0xc,%esp
80107d34:	68 bd ad 10 80       	push   $0x8010adbd
80107d39:	e8 ce 86 ff ff       	call   8010040c <cprintf>
80107d3e:	83 c4 10             	add    $0x10,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107d41:	8b 45 10             	mov    0x10(%ebp),%eax
80107d44:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d47:	72 08                	jb     80107d51 <deallocuvm+0x2a>
    return oldsz;
80107d49:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d4c:	e9 ac 00 00 00       	jmp    80107dfd <deallocuvm+0xd6>

  a = PGROUNDUP(newsz);
80107d51:	8b 45 10             	mov    0x10(%ebp),%eax
80107d54:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d59:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107d61:	e9 88 00 00 00       	jmp    80107dee <deallocuvm+0xc7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d69:	83 ec 04             	sub    $0x4,%esp
80107d6c:	6a 00                	push   $0x0
80107d6e:	50                   	push   %eax
80107d6f:	ff 75 08             	push   0x8(%ebp)
80107d72:	e8 67 f9 ff ff       	call   801076de <walkpgdir>
80107d77:	83 c4 10             	add    $0x10,%esp
80107d7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107d7d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d81:	75 16                	jne    80107d99 <deallocuvm+0x72>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d86:	c1 e8 16             	shr    $0x16,%eax
80107d89:	83 c0 01             	add    $0x1,%eax
80107d8c:	c1 e0 16             	shl    $0x16,%eax
80107d8f:	2d 00 10 00 00       	sub    $0x1000,%eax
80107d94:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d97:	eb 4e                	jmp    80107de7 <deallocuvm+0xc0>
    else if((*pte & PTE_P) != 0){
80107d99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d9c:	8b 00                	mov    (%eax),%eax
80107d9e:	83 e0 01             	and    $0x1,%eax
80107da1:	85 c0                	test   %eax,%eax
80107da3:	74 42                	je     80107de7 <deallocuvm+0xc0>
      pa = PTE_ADDR(*pte);
80107da5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107da8:	8b 00                	mov    (%eax),%eax
80107daa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107daf:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107db2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107db6:	75 0d                	jne    80107dc5 <deallocuvm+0x9e>
        panic("kfree");
80107db8:	83 ec 0c             	sub    $0xc,%esp
80107dbb:	68 ca ad 10 80       	push   $0x8010adca
80107dc0:	e8 19 88 ff ff       	call   801005de <panic>
      char *v = P2V(pa);
80107dc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107dc8:	05 00 00 00 80       	add    $0x80000000,%eax
80107dcd:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107dd0:	83 ec 0c             	sub    $0xc,%esp
80107dd3:	ff 75 e8             	push   -0x18(%ebp)
80107dd6:	e8 29 aa ff ff       	call   80102804 <kfree>
80107ddb:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107dde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107de1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107de7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df1:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107df4:	0f 82 6c ff ff ff    	jb     80107d66 <deallocuvm+0x3f>
    }
  }
  return newsz;
80107dfa:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107dfd:	c9                   	leave
80107dfe:	c3                   	ret

80107dff <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107dff:	f3 0f 1e fb          	endbr32
80107e03:	55                   	push   %ebp
80107e04:	89 e5                	mov    %esp,%ebp
80107e06:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107e09:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107e0d:	75 0d                	jne    80107e1c <freevm+0x1d>
    panic("freevm: no pgdir");
80107e0f:	83 ec 0c             	sub    $0xc,%esp
80107e12:	68 d0 ad 10 80       	push   $0x8010add0
80107e17:	e8 c2 87 ff ff       	call   801005de <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107e1c:	83 ec 04             	sub    $0x4,%esp
80107e1f:	6a 00                	push   $0x0
80107e21:	68 00 00 00 80       	push   $0x80000000
80107e26:	ff 75 08             	push   0x8(%ebp)
80107e29:	e8 f9 fe ff ff       	call   80107d27 <deallocuvm>
80107e2e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e38:	eb 48                	jmp    80107e82 <freevm+0x83>
    if(pgdir[i] & PTE_P){
80107e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e44:	8b 45 08             	mov    0x8(%ebp),%eax
80107e47:	01 d0                	add    %edx,%eax
80107e49:	8b 00                	mov    (%eax),%eax
80107e4b:	83 e0 01             	and    $0x1,%eax
80107e4e:	85 c0                	test   %eax,%eax
80107e50:	74 2c                	je     80107e7e <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e55:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80107e5f:	01 d0                	add    %edx,%eax
80107e61:	8b 00                	mov    (%eax),%eax
80107e63:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e68:	05 00 00 00 80       	add    $0x80000000,%eax
80107e6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107e70:	83 ec 0c             	sub    $0xc,%esp
80107e73:	ff 75 f0             	push   -0x10(%ebp)
80107e76:	e8 89 a9 ff ff       	call   80102804 <kfree>
80107e7b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e7e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e82:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107e89:	76 af                	jbe    80107e3a <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80107e8b:	83 ec 0c             	sub    $0xc,%esp
80107e8e:	ff 75 08             	push   0x8(%ebp)
80107e91:	e8 6e a9 ff ff       	call   80102804 <kfree>
80107e96:	83 c4 10             	add    $0x10,%esp
}
80107e99:	90                   	nop
80107e9a:	c9                   	leave
80107e9b:	c3                   	ret

80107e9c <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107e9c:	f3 0f 1e fb          	endbr32
80107ea0:	55                   	push   %ebp
80107ea1:	89 e5                	mov    %esp,%ebp
80107ea3:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107ea6:	83 ec 04             	sub    $0x4,%esp
80107ea9:	6a 00                	push   $0x0
80107eab:	ff 75 0c             	push   0xc(%ebp)
80107eae:	ff 75 08             	push   0x8(%ebp)
80107eb1:	e8 28 f8 ff ff       	call   801076de <walkpgdir>
80107eb6:	83 c4 10             	add    $0x10,%esp
80107eb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107ebc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ec0:	75 0d                	jne    80107ecf <clearpteu+0x33>
    panic("clearpteu");
80107ec2:	83 ec 0c             	sub    $0xc,%esp
80107ec5:	68 e1 ad 10 80       	push   $0x8010ade1
80107eca:	e8 0f 87 ff ff       	call   801005de <panic>
  *pte &= ~PTE_U;
80107ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed2:	8b 00                	mov    (%eax),%eax
80107ed4:	83 e0 fb             	and    $0xfffffffb,%eax
80107ed7:	89 c2                	mov    %eax,%edx
80107ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107edc:	89 10                	mov    %edx,(%eax)
}
80107ede:	90                   	nop
80107edf:	c9                   	leave
80107ee0:	c3                   	ret

80107ee1 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107ee1:	f3 0f 1e fb          	endbr32
80107ee5:	55                   	push   %ebp
80107ee6:	89 e5                	mov    %esp,%ebp
80107ee8:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;
  
  if((d = setupkvm()) == 0)
80107eeb:	e8 1c f9 ff ff       	call   8010780c <setupkvm>
80107ef0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ef3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ef7:	75 0a                	jne    80107f03 <copyuvm+0x22>
    return 0;
80107ef9:	b8 00 00 00 00       	mov    $0x0,%eax
80107efe:	e9 d6 00 00 00       	jmp    80107fd9 <copyuvm+0xf8>
    // 스택을 힙 영역으로 옮겼으니 힙 영역까지의 페이지 복사
    // text, data 영역 0xb98까지 stack 영역 0xb98+ 2*PGSIZE까지
    // heap 영역 stack영역 위부터 kernbase까지
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107f03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f0a:	e9 a3 00 00 00       	jmp    80107fb2 <copyuvm+0xd1>
    
    // 스택을 힙 영역의 맨 위에 할당했기 때문에 kernbase까지 복사를 해야하는데
    // 할당되지 않은 페이지, 유효하지 않은 페이지는 복사하지 않고 지나감
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f12:	83 ec 04             	sub    $0x4,%esp
80107f15:	6a 00                	push   $0x0
80107f17:	50                   	push   %eax
80107f18:	ff 75 08             	push   0x8(%ebp)
80107f1b:	e8 be f7 ff ff       	call   801076de <walkpgdir>
80107f20:	83 c4 10             	add    $0x10,%esp
80107f23:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f26:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f2a:	74 7b                	je     80107fa7 <copyuvm+0xc6>
      continue;
    if(!(*pte & PTE_P)){
80107f2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f2f:	8b 00                	mov    (%eax),%eax
80107f31:	83 e0 01             	and    $0x1,%eax
80107f34:	85 c0                	test   %eax,%eax
80107f36:	74 72                	je     80107faa <copyuvm+0xc9>
      continue;
    }
    // PTE_ADDR 페이지 테이블 엔트리에서 물리 주소 부분
    // PTE_FLAGS flag 부분 추출
    pa = PTE_ADDR(*pte);
80107f38:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f3b:	8b 00                	mov    (%eax),%eax
80107f3d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f42:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107f45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f48:	8b 00                	mov    (%eax),%eax
80107f4a:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f4f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    // 페이지를 복사할 물리 주소 할당
    if((mem = kalloc()) == 0)
80107f52:	e8 4b a9 ff ff       	call   801028a2 <kalloc>
80107f57:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107f5a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107f5e:	74 62                	je     80107fc2 <copyuvm+0xe1>
      goto bad;
    // 현재 페이지의 물리 주소인 pa를  mem에 복사
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107f60:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f63:	05 00 00 00 80       	add    $0x80000000,%eax
80107f68:	83 ec 04             	sub    $0x4,%esp
80107f6b:	68 00 10 00 00       	push   $0x1000
80107f70:	50                   	push   %eax
80107f71:	ff 75 e0             	push   -0x20(%ebp)
80107f74:	e8 2a ce ff ff       	call   80104da3 <memmove>
80107f79:	83 c4 10             	add    $0x10,%esp
    // 현재 가상주소에 복사받은 mem을 매핑
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107f7c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107f7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107f82:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8b:	83 ec 0c             	sub    $0xc,%esp
80107f8e:	52                   	push   %edx
80107f8f:	51                   	push   %ecx
80107f90:	68 00 10 00 00       	push   $0x1000
80107f95:	50                   	push   %eax
80107f96:	ff 75 f0             	push   -0x10(%ebp)
80107f99:	e8 da f7 ff ff       	call   80107778 <mappages>
80107f9e:	83 c4 20             	add    $0x20,%esp
80107fa1:	85 c0                	test   %eax,%eax
80107fa3:	78 20                	js     80107fc5 <copyuvm+0xe4>
80107fa5:	eb 04                	jmp    80107fab <copyuvm+0xca>
      continue;
80107fa7:	90                   	nop
80107fa8:	eb 01                	jmp    80107fab <copyuvm+0xca>
      continue;
80107faa:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107fab:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb5:	85 c0                	test   %eax,%eax
80107fb7:	0f 89 52 ff ff ff    	jns    80107f0f <copyuvm+0x2e>
      goto bad;
  }  
  return d;
80107fbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fc0:	eb 17                	jmp    80107fd9 <copyuvm+0xf8>
      goto bad;
80107fc2:	90                   	nop
80107fc3:	eb 01                	jmp    80107fc6 <copyuvm+0xe5>
      goto bad;
80107fc5:	90                   	nop

bad:
  freevm(d);
80107fc6:	83 ec 0c             	sub    $0xc,%esp
80107fc9:	ff 75 f0             	push   -0x10(%ebp)
80107fcc:	e8 2e fe ff ff       	call   80107dff <freevm>
80107fd1:	83 c4 10             	add    $0x10,%esp
  return 0;
80107fd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107fd9:	c9                   	leave
80107fda:	c3                   	ret

80107fdb <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107fdb:	f3 0f 1e fb          	endbr32
80107fdf:	55                   	push   %ebp
80107fe0:	89 e5                	mov    %esp,%ebp
80107fe2:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107fe5:	83 ec 04             	sub    $0x4,%esp
80107fe8:	6a 00                	push   $0x0
80107fea:	ff 75 0c             	push   0xc(%ebp)
80107fed:	ff 75 08             	push   0x8(%ebp)
80107ff0:	e8 e9 f6 ff ff       	call   801076de <walkpgdir>
80107ff5:	83 c4 10             	add    $0x10,%esp
80107ff8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffe:	8b 00                	mov    (%eax),%eax
80108000:	83 e0 01             	and    $0x1,%eax
80108003:	85 c0                	test   %eax,%eax
80108005:	75 07                	jne    8010800e <uva2ka+0x33>
    return 0;
80108007:	b8 00 00 00 00       	mov    $0x0,%eax
8010800c:	eb 22                	jmp    80108030 <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
8010800e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108011:	8b 00                	mov    (%eax),%eax
80108013:	83 e0 04             	and    $0x4,%eax
80108016:	85 c0                	test   %eax,%eax
80108018:	75 07                	jne    80108021 <uva2ka+0x46>
    return 0;
8010801a:	b8 00 00 00 00       	mov    $0x0,%eax
8010801f:	eb 0f                	jmp    80108030 <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
80108021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108024:	8b 00                	mov    (%eax),%eax
80108026:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010802b:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108030:	c9                   	leave
80108031:	c3                   	ret

80108032 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108032:	f3 0f 1e fb          	endbr32
80108036:	55                   	push   %ebp
80108037:	89 e5                	mov    %esp,%ebp
80108039:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010803c:	8b 45 10             	mov    0x10(%ebp),%eax
8010803f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108042:	eb 7f                	jmp    801080c3 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108044:	8b 45 0c             	mov    0xc(%ebp),%eax
80108047:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010804c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010804f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108052:	83 ec 08             	sub    $0x8,%esp
80108055:	50                   	push   %eax
80108056:	ff 75 08             	push   0x8(%ebp)
80108059:	e8 7d ff ff ff       	call   80107fdb <uva2ka>
8010805e:	83 c4 10             	add    $0x10,%esp
80108061:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108064:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108068:	75 07                	jne    80108071 <copyout+0x3f>
      return -1;
8010806a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010806f:	eb 61                	jmp    801080d2 <copyout+0xa0>
    n = PGSIZE - (va - va0);
80108071:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108074:	2b 45 0c             	sub    0xc(%ebp),%eax
80108077:	05 00 10 00 00       	add    $0x1000,%eax
8010807c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010807f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108082:	3b 45 14             	cmp    0x14(%ebp),%eax
80108085:	76 06                	jbe    8010808d <copyout+0x5b>
      n = len;
80108087:	8b 45 14             	mov    0x14(%ebp),%eax
8010808a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010808d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108090:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108093:	89 c2                	mov    %eax,%edx
80108095:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108098:	01 d0                	add    %edx,%eax
8010809a:	83 ec 04             	sub    $0x4,%esp
8010809d:	ff 75 f0             	push   -0x10(%ebp)
801080a0:	ff 75 f4             	push   -0xc(%ebp)
801080a3:	50                   	push   %eax
801080a4:	e8 fa cc ff ff       	call   80104da3 <memmove>
801080a9:	83 c4 10             	add    $0x10,%esp
    len -= n;
801080ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080af:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801080b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080b5:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801080b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080bb:	05 00 10 00 00       	add    $0x1000,%eax
801080c0:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801080c3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801080c7:	0f 85 77 ff ff ff    	jne    80108044 <copyout+0x12>
  }
  return 0;
801080cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080d2:	c9                   	leave
801080d3:	c3                   	ret

801080d4 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
801080d4:	f3 0f 1e fb          	endbr32
801080d8:	55                   	push   %ebp
801080d9:	89 e5                	mov    %esp,%ebp
801080db:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801080de:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
801080e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801080e8:	8b 40 08             	mov    0x8(%eax),%eax
801080eb:	05 00 00 00 80       	add    $0x80000000,%eax
801080f0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
801080f3:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
801080fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080fd:	8b 40 24             	mov    0x24(%eax),%eax
80108100:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
80108105:	c7 05 80 80 19 80 00 	movl   $0x0,0x80198080
8010810c:	00 00 00 

  while(i<madt->len){
8010810f:	90                   	nop
80108110:	e9 be 00 00 00       	jmp    801081d3 <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
80108115:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108118:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010811b:	01 d0                	add    %edx,%eax
8010811d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108120:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108123:	0f b6 00             	movzbl (%eax),%eax
80108126:	0f b6 c0             	movzbl %al,%eax
80108129:	83 f8 05             	cmp    $0x5,%eax
8010812c:	0f 87 a1 00 00 00    	ja     801081d3 <mpinit_uefi+0xff>
80108132:	8b 04 85 ec ad 10 80 	mov    -0x7fef5214(,%eax,4),%eax
80108139:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
8010813c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010813f:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108142:	a1 80 80 19 80       	mov    0x80198080,%eax
80108147:	83 f8 03             	cmp    $0x3,%eax
8010814a:	7f 28                	jg     80108174 <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
8010814c:	8b 15 80 80 19 80    	mov    0x80198080,%edx
80108152:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108155:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108159:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
8010815f:	81 c2 c0 7d 19 80    	add    $0x80197dc0,%edx
80108165:	88 02                	mov    %al,(%edx)
          ncpu++;
80108167:	a1 80 80 19 80       	mov    0x80198080,%eax
8010816c:	83 c0 01             	add    $0x1,%eax
8010816f:	a3 80 80 19 80       	mov    %eax,0x80198080
        }
        i += lapic_entry->record_len;
80108174:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108177:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010817b:	0f b6 c0             	movzbl %al,%eax
8010817e:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108181:	eb 50                	jmp    801081d3 <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108183:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108186:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108189:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010818c:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108190:	a2 a0 7d 19 80       	mov    %al,0x80197da0
        i += ioapic->record_len;
80108195:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108198:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010819c:	0f b6 c0             	movzbl %al,%eax
8010819f:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801081a2:	eb 2f                	jmp    801081d3 <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801081a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801081aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081ad:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801081b1:	0f b6 c0             	movzbl %al,%eax
801081b4:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801081b7:	eb 1a                	jmp    801081d3 <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801081b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801081bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081c2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801081c6:	0f b6 c0             	movzbl %al,%eax
801081c9:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801081cc:	eb 05                	jmp    801081d3 <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
801081ce:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801081d2:	90                   	nop
  while(i<madt->len){
801081d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d6:	8b 40 04             	mov    0x4(%eax),%eax
801081d9:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801081dc:	0f 82 33 ff ff ff    	jb     80108115 <mpinit_uefi+0x41>
    }
  }

}
801081e2:	90                   	nop
801081e3:	90                   	nop
801081e4:	c9                   	leave
801081e5:	c3                   	ret

801081e6 <inb>:
{
801081e6:	55                   	push   %ebp
801081e7:	89 e5                	mov    %esp,%ebp
801081e9:	83 ec 14             	sub    $0x14,%esp
801081ec:	8b 45 08             	mov    0x8(%ebp),%eax
801081ef:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801081f3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801081f7:	89 c2                	mov    %eax,%edx
801081f9:	ec                   	in     (%dx),%al
801081fa:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801081fd:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108201:	c9                   	leave
80108202:	c3                   	ret

80108203 <outb>:
{
80108203:	55                   	push   %ebp
80108204:	89 e5                	mov    %esp,%ebp
80108206:	83 ec 08             	sub    $0x8,%esp
80108209:	8b 45 08             	mov    0x8(%ebp),%eax
8010820c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010820f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108213:	89 d0                	mov    %edx,%eax
80108215:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108218:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010821c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108220:	ee                   	out    %al,(%dx)
}
80108221:	90                   	nop
80108222:	c9                   	leave
80108223:	c3                   	ret

80108224 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108224:	f3 0f 1e fb          	endbr32
80108228:	55                   	push   %ebp
80108229:	89 e5                	mov    %esp,%ebp
8010822b:	83 ec 28             	sub    $0x28,%esp
8010822e:	8b 45 08             	mov    0x8(%ebp),%eax
80108231:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108234:	6a 00                	push   $0x0
80108236:	68 fa 03 00 00       	push   $0x3fa
8010823b:	e8 c3 ff ff ff       	call   80108203 <outb>
80108240:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108243:	68 80 00 00 00       	push   $0x80
80108248:	68 fb 03 00 00       	push   $0x3fb
8010824d:	e8 b1 ff ff ff       	call   80108203 <outb>
80108252:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108255:	6a 0c                	push   $0xc
80108257:	68 f8 03 00 00       	push   $0x3f8
8010825c:	e8 a2 ff ff ff       	call   80108203 <outb>
80108261:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108264:	6a 00                	push   $0x0
80108266:	68 f9 03 00 00       	push   $0x3f9
8010826b:	e8 93 ff ff ff       	call   80108203 <outb>
80108270:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108273:	6a 03                	push   $0x3
80108275:	68 fb 03 00 00       	push   $0x3fb
8010827a:	e8 84 ff ff ff       	call   80108203 <outb>
8010827f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108282:	6a 00                	push   $0x0
80108284:	68 fc 03 00 00       	push   $0x3fc
80108289:	e8 75 ff ff ff       	call   80108203 <outb>
8010828e:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108291:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108298:	eb 11                	jmp    801082ab <uart_debug+0x87>
8010829a:	83 ec 0c             	sub    $0xc,%esp
8010829d:	6a 0a                	push   $0xa
8010829f:	e8 b0 a9 ff ff       	call   80102c54 <microdelay>
801082a4:	83 c4 10             	add    $0x10,%esp
801082a7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801082ab:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801082af:	7f 1a                	jg     801082cb <uart_debug+0xa7>
801082b1:	83 ec 0c             	sub    $0xc,%esp
801082b4:	68 fd 03 00 00       	push   $0x3fd
801082b9:	e8 28 ff ff ff       	call   801081e6 <inb>
801082be:	83 c4 10             	add    $0x10,%esp
801082c1:	0f b6 c0             	movzbl %al,%eax
801082c4:	83 e0 20             	and    $0x20,%eax
801082c7:	85 c0                	test   %eax,%eax
801082c9:	74 cf                	je     8010829a <uart_debug+0x76>
  outb(COM1+0, p);
801082cb:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801082cf:	0f b6 c0             	movzbl %al,%eax
801082d2:	83 ec 08             	sub    $0x8,%esp
801082d5:	50                   	push   %eax
801082d6:	68 f8 03 00 00       	push   $0x3f8
801082db:	e8 23 ff ff ff       	call   80108203 <outb>
801082e0:	83 c4 10             	add    $0x10,%esp
}
801082e3:	90                   	nop
801082e4:	c9                   	leave
801082e5:	c3                   	ret

801082e6 <uart_debugs>:

void uart_debugs(char *p){
801082e6:	f3 0f 1e fb          	endbr32
801082ea:	55                   	push   %ebp
801082eb:	89 e5                	mov    %esp,%ebp
801082ed:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801082f0:	eb 1b                	jmp    8010830d <uart_debugs+0x27>
    uart_debug(*p++);
801082f2:	8b 45 08             	mov    0x8(%ebp),%eax
801082f5:	8d 50 01             	lea    0x1(%eax),%edx
801082f8:	89 55 08             	mov    %edx,0x8(%ebp)
801082fb:	0f b6 00             	movzbl (%eax),%eax
801082fe:	0f be c0             	movsbl %al,%eax
80108301:	83 ec 0c             	sub    $0xc,%esp
80108304:	50                   	push   %eax
80108305:	e8 1a ff ff ff       	call   80108224 <uart_debug>
8010830a:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010830d:	8b 45 08             	mov    0x8(%ebp),%eax
80108310:	0f b6 00             	movzbl (%eax),%eax
80108313:	84 c0                	test   %al,%al
80108315:	75 db                	jne    801082f2 <uart_debugs+0xc>
  }
}
80108317:	90                   	nop
80108318:	90                   	nop
80108319:	c9                   	leave
8010831a:	c3                   	ret

8010831b <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
8010831b:	f3 0f 1e fb          	endbr32
8010831f:	55                   	push   %ebp
80108320:	89 e5                	mov    %esp,%ebp
80108322:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108325:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
8010832c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010832f:	8b 50 14             	mov    0x14(%eax),%edx
80108332:	8b 40 10             	mov    0x10(%eax),%eax
80108335:	a3 84 80 19 80       	mov    %eax,0x80198084
  gpu.vram_size = boot_param->graphic_config.frame_size;
8010833a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010833d:	8b 50 1c             	mov    0x1c(%eax),%edx
80108340:	8b 40 18             	mov    0x18(%eax),%eax
80108343:	a3 8c 80 19 80       	mov    %eax,0x8019808c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108348:	a1 8c 80 19 80       	mov    0x8019808c,%eax
8010834d:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108352:	29 c2                	sub    %eax,%edx
80108354:	89 d0                	mov    %edx,%eax
80108356:	a3 88 80 19 80       	mov    %eax,0x80198088
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010835b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010835e:	8b 50 24             	mov    0x24(%eax),%edx
80108361:	8b 40 20             	mov    0x20(%eax),%eax
80108364:	a3 90 80 19 80       	mov    %eax,0x80198090
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108369:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010836c:	8b 50 2c             	mov    0x2c(%eax),%edx
8010836f:	8b 40 28             	mov    0x28(%eax),%eax
80108372:	a3 94 80 19 80       	mov    %eax,0x80198094
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108377:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010837a:	8b 50 34             	mov    0x34(%eax),%edx
8010837d:	8b 40 30             	mov    0x30(%eax),%eax
80108380:	a3 98 80 19 80       	mov    %eax,0x80198098
}
80108385:	90                   	nop
80108386:	c9                   	leave
80108387:	c3                   	ret

80108388 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108388:	f3 0f 1e fb          	endbr32
8010838c:	55                   	push   %ebp
8010838d:	89 e5                	mov    %esp,%ebp
8010838f:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108392:	8b 15 98 80 19 80    	mov    0x80198098,%edx
80108398:	8b 45 0c             	mov    0xc(%ebp),%eax
8010839b:	0f af d0             	imul   %eax,%edx
8010839e:	8b 45 08             	mov    0x8(%ebp),%eax
801083a1:	01 d0                	add    %edx,%eax
801083a3:	c1 e0 02             	shl    $0x2,%eax
801083a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801083a9:	8b 15 88 80 19 80    	mov    0x80198088,%edx
801083af:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083b2:	01 d0                	add    %edx,%eax
801083b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801083b7:	8b 45 10             	mov    0x10(%ebp),%eax
801083ba:	0f b6 10             	movzbl (%eax),%edx
801083bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083c0:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801083c2:	8b 45 10             	mov    0x10(%ebp),%eax
801083c5:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801083c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083cc:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801083cf:	8b 45 10             	mov    0x10(%ebp),%eax
801083d2:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801083d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083d9:	88 50 02             	mov    %dl,0x2(%eax)
}
801083dc:	90                   	nop
801083dd:	c9                   	leave
801083de:	c3                   	ret

801083df <graphic_scroll_up>:

void graphic_scroll_up(int height){
801083df:	f3 0f 1e fb          	endbr32
801083e3:	55                   	push   %ebp
801083e4:	89 e5                	mov    %esp,%ebp
801083e6:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801083e9:	8b 15 98 80 19 80    	mov    0x80198098,%edx
801083ef:	8b 45 08             	mov    0x8(%ebp),%eax
801083f2:	0f af c2             	imul   %edx,%eax
801083f5:	c1 e0 02             	shl    $0x2,%eax
801083f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801083fb:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
80108401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108404:	29 c2                	sub    %eax,%edx
80108406:	89 d0                	mov    %edx,%eax
80108408:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
8010840e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108411:	01 ca                	add    %ecx,%edx
80108413:	89 d1                	mov    %edx,%ecx
80108415:	8b 15 88 80 19 80    	mov    0x80198088,%edx
8010841b:	83 ec 04             	sub    $0x4,%esp
8010841e:	50                   	push   %eax
8010841f:	51                   	push   %ecx
80108420:	52                   	push   %edx
80108421:	e8 7d c9 ff ff       	call   80104da3 <memmove>
80108426:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842c:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
80108432:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
80108438:	01 d1                	add    %edx,%ecx
8010843a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010843d:	29 d1                	sub    %edx,%ecx
8010843f:	89 ca                	mov    %ecx,%edx
80108441:	83 ec 04             	sub    $0x4,%esp
80108444:	50                   	push   %eax
80108445:	6a 00                	push   $0x0
80108447:	52                   	push   %edx
80108448:	e8 8f c8 ff ff       	call   80104cdc <memset>
8010844d:	83 c4 10             	add    $0x10,%esp
}
80108450:	90                   	nop
80108451:	c9                   	leave
80108452:	c3                   	ret

80108453 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108453:	f3 0f 1e fb          	endbr32
80108457:	55                   	push   %ebp
80108458:	89 e5                	mov    %esp,%ebp
8010845a:	53                   	push   %ebx
8010845b:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
8010845e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108465:	e9 b1 00 00 00       	jmp    8010851b <font_render+0xc8>
    for(int j=14;j>-1;j--){
8010846a:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108471:	e9 97 00 00 00       	jmp    8010850d <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108476:	8b 45 10             	mov    0x10(%ebp),%eax
80108479:	83 e8 20             	sub    $0x20,%eax
8010847c:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010847f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108482:	01 d0                	add    %edx,%eax
80108484:	0f b7 84 00 20 ae 10 	movzwl -0x7fef51e0(%eax,%eax,1),%eax
8010848b:	80 
8010848c:	0f b7 d0             	movzwl %ax,%edx
8010848f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108492:	bb 01 00 00 00       	mov    $0x1,%ebx
80108497:	89 c1                	mov    %eax,%ecx
80108499:	d3 e3                	shl    %cl,%ebx
8010849b:	89 d8                	mov    %ebx,%eax
8010849d:	21 d0                	and    %edx,%eax
8010849f:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801084a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084a5:	ba 01 00 00 00       	mov    $0x1,%edx
801084aa:	89 c1                	mov    %eax,%ecx
801084ac:	d3 e2                	shl    %cl,%edx
801084ae:	89 d0                	mov    %edx,%eax
801084b0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801084b3:	75 2b                	jne    801084e0 <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801084b5:	8b 55 0c             	mov    0xc(%ebp),%edx
801084b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084bb:	01 c2                	add    %eax,%edx
801084bd:	b8 0e 00 00 00       	mov    $0xe,%eax
801084c2:	2b 45 f0             	sub    -0x10(%ebp),%eax
801084c5:	89 c1                	mov    %eax,%ecx
801084c7:	8b 45 08             	mov    0x8(%ebp),%eax
801084ca:	01 c8                	add    %ecx,%eax
801084cc:	83 ec 04             	sub    $0x4,%esp
801084cf:	68 e0 f4 10 80       	push   $0x8010f4e0
801084d4:	52                   	push   %edx
801084d5:	50                   	push   %eax
801084d6:	e8 ad fe ff ff       	call   80108388 <graphic_draw_pixel>
801084db:	83 c4 10             	add    $0x10,%esp
801084de:	eb 29                	jmp    80108509 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801084e0:	8b 55 0c             	mov    0xc(%ebp),%edx
801084e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e6:	01 c2                	add    %eax,%edx
801084e8:	b8 0e 00 00 00       	mov    $0xe,%eax
801084ed:	2b 45 f0             	sub    -0x10(%ebp),%eax
801084f0:	89 c1                	mov    %eax,%ecx
801084f2:	8b 45 08             	mov    0x8(%ebp),%eax
801084f5:	01 c8                	add    %ecx,%eax
801084f7:	83 ec 04             	sub    $0x4,%esp
801084fa:	68 64 d0 18 80       	push   $0x8018d064
801084ff:	52                   	push   %edx
80108500:	50                   	push   %eax
80108501:	e8 82 fe ff ff       	call   80108388 <graphic_draw_pixel>
80108506:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108509:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010850d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108511:	0f 89 5f ff ff ff    	jns    80108476 <font_render+0x23>
  for(int i=0;i<30;i++){
80108517:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010851b:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010851f:	0f 8e 45 ff ff ff    	jle    8010846a <font_render+0x17>
      }
    }
  }
}
80108525:	90                   	nop
80108526:	90                   	nop
80108527:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010852a:	c9                   	leave
8010852b:	c3                   	ret

8010852c <font_render_string>:

void font_render_string(char *string,int row){
8010852c:	f3 0f 1e fb          	endbr32
80108530:	55                   	push   %ebp
80108531:	89 e5                	mov    %esp,%ebp
80108533:	53                   	push   %ebx
80108534:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108537:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010853e:	eb 33                	jmp    80108573 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
80108540:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108543:	8b 45 08             	mov    0x8(%ebp),%eax
80108546:	01 d0                	add    %edx,%eax
80108548:	0f b6 00             	movzbl (%eax),%eax
8010854b:	0f be d8             	movsbl %al,%ebx
8010854e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108551:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108554:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108557:	89 d0                	mov    %edx,%eax
80108559:	c1 e0 04             	shl    $0x4,%eax
8010855c:	29 d0                	sub    %edx,%eax
8010855e:	83 c0 02             	add    $0x2,%eax
80108561:	83 ec 04             	sub    $0x4,%esp
80108564:	53                   	push   %ebx
80108565:	51                   	push   %ecx
80108566:	50                   	push   %eax
80108567:	e8 e7 fe ff ff       	call   80108453 <font_render>
8010856c:	83 c4 10             	add    $0x10,%esp
    i++;
8010856f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108573:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108576:	8b 45 08             	mov    0x8(%ebp),%eax
80108579:	01 d0                	add    %edx,%eax
8010857b:	0f b6 00             	movzbl (%eax),%eax
8010857e:	84 c0                	test   %al,%al
80108580:	74 06                	je     80108588 <font_render_string+0x5c>
80108582:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108586:	7e b8                	jle    80108540 <font_render_string+0x14>
  }
}
80108588:	90                   	nop
80108589:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010858c:	c9                   	leave
8010858d:	c3                   	ret

8010858e <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010858e:	f3 0f 1e fb          	endbr32
80108592:	55                   	push   %ebp
80108593:	89 e5                	mov    %esp,%ebp
80108595:	53                   	push   %ebx
80108596:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108599:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085a0:	eb 6b                	jmp    8010860d <pci_init+0x7f>
    for(int j=0;j<32;j++){
801085a2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801085a9:	eb 58                	jmp    80108603 <pci_init+0x75>
      for(int k=0;k<8;k++){
801085ab:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801085b2:	eb 45                	jmp    801085f9 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
801085b4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801085b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801085ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085bd:	83 ec 0c             	sub    $0xc,%esp
801085c0:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801085c3:	53                   	push   %ebx
801085c4:	6a 00                	push   $0x0
801085c6:	51                   	push   %ecx
801085c7:	52                   	push   %edx
801085c8:	50                   	push   %eax
801085c9:	e8 c0 00 00 00       	call   8010868e <pci_access_config>
801085ce:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801085d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085d4:	0f b7 c0             	movzwl %ax,%eax
801085d7:	3d ff ff 00 00       	cmp    $0xffff,%eax
801085dc:	74 17                	je     801085f5 <pci_init+0x67>
        pci_init_device(i,j,k);
801085de:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801085e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801085e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e7:	83 ec 04             	sub    $0x4,%esp
801085ea:	51                   	push   %ecx
801085eb:	52                   	push   %edx
801085ec:	50                   	push   %eax
801085ed:	e8 4f 01 00 00       	call   80108741 <pci_init_device>
801085f2:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801085f5:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801085f9:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801085fd:	7e b5                	jle    801085b4 <pci_init+0x26>
    for(int j=0;j<32;j++){
801085ff:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108603:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108607:	7e a2                	jle    801085ab <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108609:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010860d:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108614:	7e 8c                	jle    801085a2 <pci_init+0x14>
      }
      }
    }
  }
}
80108616:	90                   	nop
80108617:	90                   	nop
80108618:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010861b:	c9                   	leave
8010861c:	c3                   	ret

8010861d <pci_write_config>:

void pci_write_config(uint config){
8010861d:	f3 0f 1e fb          	endbr32
80108621:	55                   	push   %ebp
80108622:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108624:	8b 45 08             	mov    0x8(%ebp),%eax
80108627:	ba f8 0c 00 00       	mov    $0xcf8,%edx
8010862c:	89 c0                	mov    %eax,%eax
8010862e:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010862f:	90                   	nop
80108630:	5d                   	pop    %ebp
80108631:	c3                   	ret

80108632 <pci_write_data>:

void pci_write_data(uint config){
80108632:	f3 0f 1e fb          	endbr32
80108636:	55                   	push   %ebp
80108637:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108639:	8b 45 08             	mov    0x8(%ebp),%eax
8010863c:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108641:	89 c0                	mov    %eax,%eax
80108643:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108644:	90                   	nop
80108645:	5d                   	pop    %ebp
80108646:	c3                   	ret

80108647 <pci_read_config>:
uint pci_read_config(){
80108647:	f3 0f 1e fb          	endbr32
8010864b:	55                   	push   %ebp
8010864c:	89 e5                	mov    %esp,%ebp
8010864e:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108651:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108656:	ed                   	in     (%dx),%eax
80108657:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
8010865a:	83 ec 0c             	sub    $0xc,%esp
8010865d:	68 c8 00 00 00       	push   $0xc8
80108662:	e8 ed a5 ff ff       	call   80102c54 <microdelay>
80108667:	83 c4 10             	add    $0x10,%esp
  return data;
8010866a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010866d:	c9                   	leave
8010866e:	c3                   	ret

8010866f <pci_test>:


void pci_test(){
8010866f:	f3 0f 1e fb          	endbr32
80108673:	55                   	push   %ebp
80108674:	89 e5                	mov    %esp,%ebp
80108676:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108679:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108680:	ff 75 fc             	push   -0x4(%ebp)
80108683:	e8 95 ff ff ff       	call   8010861d <pci_write_config>
80108688:	83 c4 04             	add    $0x4,%esp
}
8010868b:	90                   	nop
8010868c:	c9                   	leave
8010868d:	c3                   	ret

8010868e <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
8010868e:	f3 0f 1e fb          	endbr32
80108692:	55                   	push   %ebp
80108693:	89 e5                	mov    %esp,%ebp
80108695:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108698:	8b 45 08             	mov    0x8(%ebp),%eax
8010869b:	c1 e0 10             	shl    $0x10,%eax
8010869e:	25 00 00 ff 00       	and    $0xff0000,%eax
801086a3:	89 c2                	mov    %eax,%edx
801086a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801086a8:	c1 e0 0b             	shl    $0xb,%eax
801086ab:	0f b7 c0             	movzwl %ax,%eax
801086ae:	09 c2                	or     %eax,%edx
801086b0:	8b 45 10             	mov    0x10(%ebp),%eax
801086b3:	c1 e0 08             	shl    $0x8,%eax
801086b6:	25 00 07 00 00       	and    $0x700,%eax
801086bb:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801086bd:	8b 45 14             	mov    0x14(%ebp),%eax
801086c0:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801086c5:	09 d0                	or     %edx,%eax
801086c7:	0d 00 00 00 80       	or     $0x80000000,%eax
801086cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801086cf:	ff 75 f4             	push   -0xc(%ebp)
801086d2:	e8 46 ff ff ff       	call   8010861d <pci_write_config>
801086d7:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801086da:	e8 68 ff ff ff       	call   80108647 <pci_read_config>
801086df:	8b 55 18             	mov    0x18(%ebp),%edx
801086e2:	89 02                	mov    %eax,(%edx)
}
801086e4:	90                   	nop
801086e5:	c9                   	leave
801086e6:	c3                   	ret

801086e7 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801086e7:	f3 0f 1e fb          	endbr32
801086eb:	55                   	push   %ebp
801086ec:	89 e5                	mov    %esp,%ebp
801086ee:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801086f1:	8b 45 08             	mov    0x8(%ebp),%eax
801086f4:	c1 e0 10             	shl    $0x10,%eax
801086f7:	25 00 00 ff 00       	and    $0xff0000,%eax
801086fc:	89 c2                	mov    %eax,%edx
801086fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80108701:	c1 e0 0b             	shl    $0xb,%eax
80108704:	0f b7 c0             	movzwl %ax,%eax
80108707:	09 c2                	or     %eax,%edx
80108709:	8b 45 10             	mov    0x10(%ebp),%eax
8010870c:	c1 e0 08             	shl    $0x8,%eax
8010870f:	25 00 07 00 00       	and    $0x700,%eax
80108714:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108716:	8b 45 14             	mov    0x14(%ebp),%eax
80108719:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010871e:	09 d0                	or     %edx,%eax
80108720:	0d 00 00 00 80       	or     $0x80000000,%eax
80108725:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108728:	ff 75 fc             	push   -0x4(%ebp)
8010872b:	e8 ed fe ff ff       	call   8010861d <pci_write_config>
80108730:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108733:	ff 75 18             	push   0x18(%ebp)
80108736:	e8 f7 fe ff ff       	call   80108632 <pci_write_data>
8010873b:	83 c4 04             	add    $0x4,%esp
}
8010873e:	90                   	nop
8010873f:	c9                   	leave
80108740:	c3                   	ret

80108741 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108741:	f3 0f 1e fb          	endbr32
80108745:	55                   	push   %ebp
80108746:	89 e5                	mov    %esp,%ebp
80108748:	53                   	push   %ebx
80108749:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
8010874c:	8b 45 08             	mov    0x8(%ebp),%eax
8010874f:	a2 9c 80 19 80       	mov    %al,0x8019809c
  dev.device_num = device_num;
80108754:	8b 45 0c             	mov    0xc(%ebp),%eax
80108757:	a2 9d 80 19 80       	mov    %al,0x8019809d
  dev.function_num = function_num;
8010875c:	8b 45 10             	mov    0x10(%ebp),%eax
8010875f:	a2 9e 80 19 80       	mov    %al,0x8019809e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108764:	ff 75 10             	push   0x10(%ebp)
80108767:	ff 75 0c             	push   0xc(%ebp)
8010876a:	ff 75 08             	push   0x8(%ebp)
8010876d:	68 64 c4 10 80       	push   $0x8010c464
80108772:	e8 95 7c ff ff       	call   8010040c <cprintf>
80108777:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
8010877a:	83 ec 0c             	sub    $0xc,%esp
8010877d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108780:	50                   	push   %eax
80108781:	6a 00                	push   $0x0
80108783:	ff 75 10             	push   0x10(%ebp)
80108786:	ff 75 0c             	push   0xc(%ebp)
80108789:	ff 75 08             	push   0x8(%ebp)
8010878c:	e8 fd fe ff ff       	call   8010868e <pci_access_config>
80108791:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108794:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108797:	c1 e8 10             	shr    $0x10,%eax
8010879a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
8010879d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087a0:	25 ff ff 00 00       	and    $0xffff,%eax
801087a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801087a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ab:	a3 a0 80 19 80       	mov    %eax,0x801980a0
  dev.vendor_id = vendor_id;
801087b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087b3:	a3 a4 80 19 80       	mov    %eax,0x801980a4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801087b8:	83 ec 04             	sub    $0x4,%esp
801087bb:	ff 75 f0             	push   -0x10(%ebp)
801087be:	ff 75 f4             	push   -0xc(%ebp)
801087c1:	68 98 c4 10 80       	push   $0x8010c498
801087c6:	e8 41 7c ff ff       	call   8010040c <cprintf>
801087cb:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801087ce:	83 ec 0c             	sub    $0xc,%esp
801087d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087d4:	50                   	push   %eax
801087d5:	6a 08                	push   $0x8
801087d7:	ff 75 10             	push   0x10(%ebp)
801087da:	ff 75 0c             	push   0xc(%ebp)
801087dd:	ff 75 08             	push   0x8(%ebp)
801087e0:	e8 a9 fe ff ff       	call   8010868e <pci_access_config>
801087e5:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801087e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087eb:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801087ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087f1:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801087f4:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801087f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087fa:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801087fd:	0f b6 c0             	movzbl %al,%eax
80108800:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108803:	c1 eb 18             	shr    $0x18,%ebx
80108806:	83 ec 0c             	sub    $0xc,%esp
80108809:	51                   	push   %ecx
8010880a:	52                   	push   %edx
8010880b:	50                   	push   %eax
8010880c:	53                   	push   %ebx
8010880d:	68 bc c4 10 80       	push   $0x8010c4bc
80108812:	e8 f5 7b ff ff       	call   8010040c <cprintf>
80108817:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
8010881a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010881d:	c1 e8 18             	shr    $0x18,%eax
80108820:	a2 a8 80 19 80       	mov    %al,0x801980a8
  dev.sub_class = (data>>16)&0xFF;
80108825:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108828:	c1 e8 10             	shr    $0x10,%eax
8010882b:	a2 a9 80 19 80       	mov    %al,0x801980a9
  dev.interface = (data>>8)&0xFF;
80108830:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108833:	c1 e8 08             	shr    $0x8,%eax
80108836:	a2 aa 80 19 80       	mov    %al,0x801980aa
  dev.revision_id = data&0xFF;
8010883b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010883e:	a2 ab 80 19 80       	mov    %al,0x801980ab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108843:	83 ec 0c             	sub    $0xc,%esp
80108846:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108849:	50                   	push   %eax
8010884a:	6a 10                	push   $0x10
8010884c:	ff 75 10             	push   0x10(%ebp)
8010884f:	ff 75 0c             	push   0xc(%ebp)
80108852:	ff 75 08             	push   0x8(%ebp)
80108855:	e8 34 fe ff ff       	call   8010868e <pci_access_config>
8010885a:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
8010885d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108860:	a3 ac 80 19 80       	mov    %eax,0x801980ac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108865:	83 ec 0c             	sub    $0xc,%esp
80108868:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010886b:	50                   	push   %eax
8010886c:	6a 14                	push   $0x14
8010886e:	ff 75 10             	push   0x10(%ebp)
80108871:	ff 75 0c             	push   0xc(%ebp)
80108874:	ff 75 08             	push   0x8(%ebp)
80108877:	e8 12 fe ff ff       	call   8010868e <pci_access_config>
8010887c:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
8010887f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108882:	a3 b0 80 19 80       	mov    %eax,0x801980b0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108887:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
8010888e:	75 5a                	jne    801088ea <pci_init_device+0x1a9>
80108890:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108897:	75 51                	jne    801088ea <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
80108899:	83 ec 0c             	sub    $0xc,%esp
8010889c:	68 01 c5 10 80       	push   $0x8010c501
801088a1:	e8 66 7b ff ff       	call   8010040c <cprintf>
801088a6:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801088a9:	83 ec 0c             	sub    $0xc,%esp
801088ac:	8d 45 ec             	lea    -0x14(%ebp),%eax
801088af:	50                   	push   %eax
801088b0:	68 f0 00 00 00       	push   $0xf0
801088b5:	ff 75 10             	push   0x10(%ebp)
801088b8:	ff 75 0c             	push   0xc(%ebp)
801088bb:	ff 75 08             	push   0x8(%ebp)
801088be:	e8 cb fd ff ff       	call   8010868e <pci_access_config>
801088c3:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801088c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088c9:	83 ec 08             	sub    $0x8,%esp
801088cc:	50                   	push   %eax
801088cd:	68 1b c5 10 80       	push   $0x8010c51b
801088d2:	e8 35 7b ff ff       	call   8010040c <cprintf>
801088d7:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801088da:	83 ec 0c             	sub    $0xc,%esp
801088dd:	68 9c 80 19 80       	push   $0x8019809c
801088e2:	e8 09 00 00 00       	call   801088f0 <i8254_init>
801088e7:	83 c4 10             	add    $0x10,%esp
  }
}
801088ea:	90                   	nop
801088eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801088ee:	c9                   	leave
801088ef:	c3                   	ret

801088f0 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
801088f0:	f3 0f 1e fb          	endbr32
801088f4:	55                   	push   %ebp
801088f5:	89 e5                	mov    %esp,%ebp
801088f7:	53                   	push   %ebx
801088f8:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
801088fb:	8b 45 08             	mov    0x8(%ebp),%eax
801088fe:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108902:	0f b6 c8             	movzbl %al,%ecx
80108905:	8b 45 08             	mov    0x8(%ebp),%eax
80108908:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010890c:	0f b6 d0             	movzbl %al,%edx
8010890f:	8b 45 08             	mov    0x8(%ebp),%eax
80108912:	0f b6 00             	movzbl (%eax),%eax
80108915:	0f b6 c0             	movzbl %al,%eax
80108918:	83 ec 0c             	sub    $0xc,%esp
8010891b:	8d 5d ec             	lea    -0x14(%ebp),%ebx
8010891e:	53                   	push   %ebx
8010891f:	6a 04                	push   $0x4
80108921:	51                   	push   %ecx
80108922:	52                   	push   %edx
80108923:	50                   	push   %eax
80108924:	e8 65 fd ff ff       	call   8010868e <pci_access_config>
80108929:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
8010892c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010892f:	83 c8 04             	or     $0x4,%eax
80108932:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108935:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108938:	8b 45 08             	mov    0x8(%ebp),%eax
8010893b:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010893f:	0f b6 c8             	movzbl %al,%ecx
80108942:	8b 45 08             	mov    0x8(%ebp),%eax
80108945:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108949:	0f b6 d0             	movzbl %al,%edx
8010894c:	8b 45 08             	mov    0x8(%ebp),%eax
8010894f:	0f b6 00             	movzbl (%eax),%eax
80108952:	0f b6 c0             	movzbl %al,%eax
80108955:	83 ec 0c             	sub    $0xc,%esp
80108958:	53                   	push   %ebx
80108959:	6a 04                	push   $0x4
8010895b:	51                   	push   %ecx
8010895c:	52                   	push   %edx
8010895d:	50                   	push   %eax
8010895e:	e8 84 fd ff ff       	call   801086e7 <pci_write_config_register>
80108963:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108966:	8b 45 08             	mov    0x8(%ebp),%eax
80108969:	8b 40 10             	mov    0x10(%eax),%eax
8010896c:	05 00 00 00 40       	add    $0x40000000,%eax
80108971:	a3 b4 80 19 80       	mov    %eax,0x801980b4
  uint *ctrl = (uint *)base_addr;
80108976:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010897b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
8010897e:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108983:	05 d8 00 00 00       	add    $0xd8,%eax
80108988:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
8010898b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010898e:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108997:	8b 00                	mov    (%eax),%eax
80108999:	0d 00 00 00 04       	or     $0x4000000,%eax
8010899e:	89 c2                	mov    %eax,%edx
801089a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a3:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801089a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089a8:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801089ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b1:	8b 00                	mov    (%eax),%eax
801089b3:	83 c8 40             	or     $0x40,%eax
801089b6:	89 c2                	mov    %eax,%edx
801089b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089bb:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
801089bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c0:	8b 10                	mov    (%eax),%edx
801089c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c5:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
801089c7:	83 ec 0c             	sub    $0xc,%esp
801089ca:	68 30 c5 10 80       	push   $0x8010c530
801089cf:	e8 38 7a ff ff       	call   8010040c <cprintf>
801089d4:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801089d7:	e8 c6 9e ff ff       	call   801028a2 <kalloc>
801089dc:	a3 b8 80 19 80       	mov    %eax,0x801980b8
  *intr_addr = 0;
801089e1:	a1 b8 80 19 80       	mov    0x801980b8,%eax
801089e6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
801089ec:	a1 b8 80 19 80       	mov    0x801980b8,%eax
801089f1:	83 ec 08             	sub    $0x8,%esp
801089f4:	50                   	push   %eax
801089f5:	68 52 c5 10 80       	push   $0x8010c552
801089fa:	e8 0d 7a ff ff       	call   8010040c <cprintf>
801089ff:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108a02:	e8 50 00 00 00       	call   80108a57 <i8254_init_recv>
  i8254_init_send();
80108a07:	e8 6d 03 00 00       	call   80108d79 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108a0c:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a13:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108a16:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a1d:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108a20:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a27:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108a2a:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a31:	0f b6 c0             	movzbl %al,%eax
80108a34:	83 ec 0c             	sub    $0xc,%esp
80108a37:	53                   	push   %ebx
80108a38:	51                   	push   %ecx
80108a39:	52                   	push   %edx
80108a3a:	50                   	push   %eax
80108a3b:	68 60 c5 10 80       	push   $0x8010c560
80108a40:	e8 c7 79 ff ff       	call   8010040c <cprintf>
80108a45:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a4b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108a51:	90                   	nop
80108a52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a55:	c9                   	leave
80108a56:	c3                   	ret

80108a57 <i8254_init_recv>:

void i8254_init_recv(){
80108a57:	f3 0f 1e fb          	endbr32
80108a5b:	55                   	push   %ebp
80108a5c:	89 e5                	mov    %esp,%ebp
80108a5e:	57                   	push   %edi
80108a5f:	56                   	push   %esi
80108a60:	53                   	push   %ebx
80108a61:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108a64:	83 ec 0c             	sub    $0xc,%esp
80108a67:	6a 00                	push   $0x0
80108a69:	e8 ec 04 00 00       	call   80108f5a <i8254_read_eeprom>
80108a6e:	83 c4 10             	add    $0x10,%esp
80108a71:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108a74:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108a77:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
80108a7c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108a7f:	c1 e8 08             	shr    $0x8,%eax
80108a82:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
80108a87:	83 ec 0c             	sub    $0xc,%esp
80108a8a:	6a 01                	push   $0x1
80108a8c:	e8 c9 04 00 00       	call   80108f5a <i8254_read_eeprom>
80108a91:	83 c4 10             	add    $0x10,%esp
80108a94:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108a97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a9a:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
80108a9f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108aa2:	c1 e8 08             	shr    $0x8,%eax
80108aa5:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
80108aaa:	83 ec 0c             	sub    $0xc,%esp
80108aad:	6a 02                	push   $0x2
80108aaf:	e8 a6 04 00 00       	call   80108f5a <i8254_read_eeprom>
80108ab4:	83 c4 10             	add    $0x10,%esp
80108ab7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108aba:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108abd:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
80108ac2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ac5:	c1 e8 08             	shr    $0x8,%eax
80108ac8:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108acd:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ad4:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108ad7:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ade:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108ae1:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ae8:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108aeb:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108af2:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108af5:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108afc:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108aff:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b06:	0f b6 c0             	movzbl %al,%eax
80108b09:	83 ec 04             	sub    $0x4,%esp
80108b0c:	57                   	push   %edi
80108b0d:	56                   	push   %esi
80108b0e:	53                   	push   %ebx
80108b0f:	51                   	push   %ecx
80108b10:	52                   	push   %edx
80108b11:	50                   	push   %eax
80108b12:	68 78 c5 10 80       	push   $0x8010c578
80108b17:	e8 f0 78 ff ff       	call   8010040c <cprintf>
80108b1c:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108b1f:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b24:	05 00 54 00 00       	add    $0x5400,%eax
80108b29:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108b2c:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b31:	05 04 54 00 00       	add    $0x5404,%eax
80108b36:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108b39:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108b3c:	c1 e0 10             	shl    $0x10,%eax
80108b3f:	0b 45 d8             	or     -0x28(%ebp),%eax
80108b42:	89 c2                	mov    %eax,%edx
80108b44:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108b47:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108b49:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b4c:	0d 00 00 00 80       	or     $0x80000000,%eax
80108b51:	89 c2                	mov    %eax,%edx
80108b53:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108b56:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108b58:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b5d:	05 00 52 00 00       	add    $0x5200,%eax
80108b62:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108b65:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108b6c:	eb 19                	jmp    80108b87 <i8254_init_recv+0x130>
    mta[i] = 0;
80108b6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108b71:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b78:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108b7b:	01 d0                	add    %edx,%eax
80108b7d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108b83:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108b87:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108b8b:	7e e1                	jle    80108b6e <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108b8d:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b92:	05 d0 00 00 00       	add    $0xd0,%eax
80108b97:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108b9a:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108b9d:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108ba3:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ba8:	05 c8 00 00 00       	add    $0xc8,%eax
80108bad:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108bb0:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108bb3:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108bb9:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bbe:	05 28 28 00 00       	add    $0x2828,%eax
80108bc3:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108bc6:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108bc9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108bcf:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bd4:	05 00 01 00 00       	add    $0x100,%eax
80108bd9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108bdc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108bdf:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108be5:	e8 b8 9c ff ff       	call   801028a2 <kalloc>
80108bea:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108bed:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bf2:	05 00 28 00 00       	add    $0x2800,%eax
80108bf7:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108bfa:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bff:	05 04 28 00 00       	add    $0x2804,%eax
80108c04:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108c07:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c0c:	05 08 28 00 00       	add    $0x2808,%eax
80108c11:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108c14:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c19:	05 10 28 00 00       	add    $0x2810,%eax
80108c1e:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108c21:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c26:	05 18 28 00 00       	add    $0x2818,%eax
80108c2b:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108c2e:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108c31:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108c37:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108c3a:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108c3c:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108c3f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108c45:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108c48:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108c4e:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108c51:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108c57:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108c5a:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108c60:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108c63:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108c66:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108c6d:	eb 73                	jmp    80108ce2 <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108c6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c72:	c1 e0 04             	shl    $0x4,%eax
80108c75:	89 c2                	mov    %eax,%edx
80108c77:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c7a:	01 d0                	add    %edx,%eax
80108c7c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108c83:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c86:	c1 e0 04             	shl    $0x4,%eax
80108c89:	89 c2                	mov    %eax,%edx
80108c8b:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c8e:	01 d0                	add    %edx,%eax
80108c90:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108c96:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c99:	c1 e0 04             	shl    $0x4,%eax
80108c9c:	89 c2                	mov    %eax,%edx
80108c9e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ca1:	01 d0                	add    %edx,%eax
80108ca3:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108ca9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cac:	c1 e0 04             	shl    $0x4,%eax
80108caf:	89 c2                	mov    %eax,%edx
80108cb1:	8b 45 98             	mov    -0x68(%ebp),%eax
80108cb4:	01 d0                	add    %edx,%eax
80108cb6:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108cba:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cbd:	c1 e0 04             	shl    $0x4,%eax
80108cc0:	89 c2                	mov    %eax,%edx
80108cc2:	8b 45 98             	mov    -0x68(%ebp),%eax
80108cc5:	01 d0                	add    %edx,%eax
80108cc7:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108ccb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cce:	c1 e0 04             	shl    $0x4,%eax
80108cd1:	89 c2                	mov    %eax,%edx
80108cd3:	8b 45 98             	mov    -0x68(%ebp),%eax
80108cd6:	01 d0                	add    %edx,%eax
80108cd8:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108cde:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108ce2:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108ce9:	7e 84                	jle    80108c6f <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108ceb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108cf2:	eb 57                	jmp    80108d4b <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80108cf4:	e8 a9 9b ff ff       	call   801028a2 <kalloc>
80108cf9:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108cfc:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108d00:	75 12                	jne    80108d14 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80108d02:	83 ec 0c             	sub    $0xc,%esp
80108d05:	68 98 c5 10 80       	push   $0x8010c598
80108d0a:	e8 fd 76 ff ff       	call   8010040c <cprintf>
80108d0f:	83 c4 10             	add    $0x10,%esp
      break;
80108d12:	eb 3d                	jmp    80108d51 <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108d14:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108d17:	c1 e0 04             	shl    $0x4,%eax
80108d1a:	89 c2                	mov    %eax,%edx
80108d1c:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d1f:	01 d0                	add    %edx,%eax
80108d21:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108d24:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108d2a:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108d2c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108d2f:	83 c0 01             	add    $0x1,%eax
80108d32:	c1 e0 04             	shl    $0x4,%eax
80108d35:	89 c2                	mov    %eax,%edx
80108d37:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d3a:	01 d0                	add    %edx,%eax
80108d3c:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108d3f:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108d45:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108d47:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108d4b:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108d4f:	7e a3                	jle    80108cf4 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80108d51:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d54:	8b 00                	mov    (%eax),%eax
80108d56:	83 c8 02             	or     $0x2,%eax
80108d59:	89 c2                	mov    %eax,%edx
80108d5b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d5e:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108d60:	83 ec 0c             	sub    $0xc,%esp
80108d63:	68 b8 c5 10 80       	push   $0x8010c5b8
80108d68:	e8 9f 76 ff ff       	call   8010040c <cprintf>
80108d6d:	83 c4 10             	add    $0x10,%esp
}
80108d70:	90                   	nop
80108d71:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108d74:	5b                   	pop    %ebx
80108d75:	5e                   	pop    %esi
80108d76:	5f                   	pop    %edi
80108d77:	5d                   	pop    %ebp
80108d78:	c3                   	ret

80108d79 <i8254_init_send>:

void i8254_init_send(){
80108d79:	f3 0f 1e fb          	endbr32
80108d7d:	55                   	push   %ebp
80108d7e:	89 e5                	mov    %esp,%ebp
80108d80:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108d83:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d88:	05 28 38 00 00       	add    $0x3828,%eax
80108d8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108d90:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d93:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108d99:	e8 04 9b ff ff       	call   801028a2 <kalloc>
80108d9e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108da1:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108da6:	05 00 38 00 00       	add    $0x3800,%eax
80108dab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108dae:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108db3:	05 04 38 00 00       	add    $0x3804,%eax
80108db8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108dbb:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108dc0:	05 08 38 00 00       	add    $0x3808,%eax
80108dc5:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108dc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108dcb:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108dd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108dd4:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108dd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dd9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108ddf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108de2:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108de8:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ded:	05 10 38 00 00       	add    $0x3810,%eax
80108df2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108df5:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108dfa:	05 18 38 00 00       	add    $0x3818,%eax
80108dff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108e02:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108e05:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108e0b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e0e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108e14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e17:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108e1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e21:	e9 82 00 00 00       	jmp    80108ea8 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80108e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e29:	c1 e0 04             	shl    $0x4,%eax
80108e2c:	89 c2                	mov    %eax,%edx
80108e2e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e31:	01 d0                	add    %edx,%eax
80108e33:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e3d:	c1 e0 04             	shl    $0x4,%eax
80108e40:	89 c2                	mov    %eax,%edx
80108e42:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e45:	01 d0                	add    %edx,%eax
80108e47:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e50:	c1 e0 04             	shl    $0x4,%eax
80108e53:	89 c2                	mov    %eax,%edx
80108e55:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e58:	01 d0                	add    %edx,%eax
80108e5a:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e61:	c1 e0 04             	shl    $0x4,%eax
80108e64:	89 c2                	mov    %eax,%edx
80108e66:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e69:	01 d0                	add    %edx,%eax
80108e6b:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e72:	c1 e0 04             	shl    $0x4,%eax
80108e75:	89 c2                	mov    %eax,%edx
80108e77:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e7a:	01 d0                	add    %edx,%eax
80108e7c:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e83:	c1 e0 04             	shl    $0x4,%eax
80108e86:	89 c2                	mov    %eax,%edx
80108e88:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e8b:	01 d0                	add    %edx,%eax
80108e8d:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e94:	c1 e0 04             	shl    $0x4,%eax
80108e97:	89 c2                	mov    %eax,%edx
80108e99:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e9c:	01 d0                	add    %edx,%eax
80108e9e:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108ea4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108ea8:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108eaf:	0f 8e 71 ff ff ff    	jle    80108e26 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108eb5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108ebc:	eb 57                	jmp    80108f15 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80108ebe:	e8 df 99 ff ff       	call   801028a2 <kalloc>
80108ec3:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108ec6:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108eca:	75 12                	jne    80108ede <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80108ecc:	83 ec 0c             	sub    $0xc,%esp
80108ecf:	68 98 c5 10 80       	push   $0x8010c598
80108ed4:	e8 33 75 ff ff       	call   8010040c <cprintf>
80108ed9:	83 c4 10             	add    $0x10,%esp
      break;
80108edc:	eb 3d                	jmp    80108f1b <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ee1:	c1 e0 04             	shl    $0x4,%eax
80108ee4:	89 c2                	mov    %eax,%edx
80108ee6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ee9:	01 d0                	add    %edx,%eax
80108eeb:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108eee:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108ef4:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ef9:	83 c0 01             	add    $0x1,%eax
80108efc:	c1 e0 04             	shl    $0x4,%eax
80108eff:	89 c2                	mov    %eax,%edx
80108f01:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f04:	01 d0                	add    %edx,%eax
80108f06:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108f09:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108f0f:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108f11:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108f15:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108f19:	7e a3                	jle    80108ebe <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108f1b:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f20:	05 00 04 00 00       	add    $0x400,%eax
80108f25:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108f28:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108f2b:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108f31:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f36:	05 10 04 00 00       	add    $0x410,%eax
80108f3b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108f3e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108f41:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108f47:	83 ec 0c             	sub    $0xc,%esp
80108f4a:	68 d8 c5 10 80       	push   $0x8010c5d8
80108f4f:	e8 b8 74 ff ff       	call   8010040c <cprintf>
80108f54:	83 c4 10             	add    $0x10,%esp

}
80108f57:	90                   	nop
80108f58:	c9                   	leave
80108f59:	c3                   	ret

80108f5a <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108f5a:	f3 0f 1e fb          	endbr32
80108f5e:	55                   	push   %ebp
80108f5f:	89 e5                	mov    %esp,%ebp
80108f61:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108f64:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f69:	83 c0 14             	add    $0x14,%eax
80108f6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80108f72:	c1 e0 08             	shl    $0x8,%eax
80108f75:	0f b7 c0             	movzwl %ax,%eax
80108f78:	83 c8 01             	or     $0x1,%eax
80108f7b:	89 c2                	mov    %eax,%edx
80108f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f80:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108f82:	83 ec 0c             	sub    $0xc,%esp
80108f85:	68 f8 c5 10 80       	push   $0x8010c5f8
80108f8a:	e8 7d 74 ff ff       	call   8010040c <cprintf>
80108f8f:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f95:	8b 00                	mov    (%eax),%eax
80108f97:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108f9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f9d:	83 e0 10             	and    $0x10,%eax
80108fa0:	85 c0                	test   %eax,%eax
80108fa2:	75 02                	jne    80108fa6 <i8254_read_eeprom+0x4c>
  while(1){
80108fa4:	eb dc                	jmp    80108f82 <i8254_read_eeprom+0x28>
      break;
80108fa6:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108faa:	8b 00                	mov    (%eax),%eax
80108fac:	c1 e8 10             	shr    $0x10,%eax
}
80108faf:	c9                   	leave
80108fb0:	c3                   	ret

80108fb1 <i8254_recv>:
void i8254_recv(){
80108fb1:	f3 0f 1e fb          	endbr32
80108fb5:	55                   	push   %ebp
80108fb6:	89 e5                	mov    %esp,%ebp
80108fb8:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108fbb:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108fc0:	05 10 28 00 00       	add    $0x2810,%eax
80108fc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108fc8:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108fcd:	05 18 28 00 00       	add    $0x2818,%eax
80108fd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108fd5:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108fda:	05 00 28 00 00       	add    $0x2800,%eax
80108fdf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108fe2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fe5:	8b 00                	mov    (%eax),%eax
80108fe7:	05 00 00 00 80       	add    $0x80000000,%eax
80108fec:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff2:	8b 10                	mov    (%eax),%edx
80108ff4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ff7:	8b 00                	mov    (%eax),%eax
80108ff9:	29 c2                	sub    %eax,%edx
80108ffb:	89 d0                	mov    %edx,%eax
80108ffd:	25 ff 00 00 00       	and    $0xff,%eax
80109002:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109005:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109009:	7e 37                	jle    80109042 <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
8010900b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010900e:	8b 00                	mov    (%eax),%eax
80109010:	c1 e0 04             	shl    $0x4,%eax
80109013:	89 c2                	mov    %eax,%edx
80109015:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109018:	01 d0                	add    %edx,%eax
8010901a:	8b 00                	mov    (%eax),%eax
8010901c:	05 00 00 00 80       	add    $0x80000000,%eax
80109021:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109024:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109027:	8b 00                	mov    (%eax),%eax
80109029:	83 c0 01             	add    $0x1,%eax
8010902c:	0f b6 d0             	movzbl %al,%edx
8010902f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109032:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109034:	83 ec 0c             	sub    $0xc,%esp
80109037:	ff 75 e0             	push   -0x20(%ebp)
8010903a:	e8 47 09 00 00       	call   80109986 <eth_proc>
8010903f:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109042:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109045:	8b 10                	mov    (%eax),%edx
80109047:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010904a:	8b 00                	mov    (%eax),%eax
8010904c:	39 c2                	cmp    %eax,%edx
8010904e:	75 9f                	jne    80108fef <i8254_recv+0x3e>
      (*rdt)--;
80109050:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109053:	8b 00                	mov    (%eax),%eax
80109055:	8d 50 ff             	lea    -0x1(%eax),%edx
80109058:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010905b:	89 10                	mov    %edx,(%eax)
  while(1){
8010905d:	eb 90                	jmp    80108fef <i8254_recv+0x3e>

8010905f <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
8010905f:	f3 0f 1e fb          	endbr32
80109063:	55                   	push   %ebp
80109064:	89 e5                	mov    %esp,%ebp
80109066:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109069:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010906e:	05 10 38 00 00       	add    $0x3810,%eax
80109073:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109076:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010907b:	05 18 38 00 00       	add    $0x3818,%eax
80109080:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109083:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80109088:	05 00 38 00 00       	add    $0x3800,%eax
8010908d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109090:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109093:	8b 00                	mov    (%eax),%eax
80109095:	05 00 00 00 80       	add    $0x80000000,%eax
8010909a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
8010909d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090a0:	8b 10                	mov    (%eax),%edx
801090a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090a5:	8b 00                	mov    (%eax),%eax
801090a7:	29 c2                	sub    %eax,%edx
801090a9:	89 d0                	mov    %edx,%eax
801090ab:	0f b6 c0             	movzbl %al,%eax
801090ae:	ba 00 01 00 00       	mov    $0x100,%edx
801090b3:	29 c2                	sub    %eax,%edx
801090b5:	89 d0                	mov    %edx,%eax
801090b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801090ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090bd:	8b 00                	mov    (%eax),%eax
801090bf:	25 ff 00 00 00       	and    $0xff,%eax
801090c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801090c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801090cb:	0f 8e a8 00 00 00    	jle    80109179 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
801090d1:	8b 45 08             	mov    0x8(%ebp),%eax
801090d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801090d7:	89 d1                	mov    %edx,%ecx
801090d9:	c1 e1 04             	shl    $0x4,%ecx
801090dc:	8b 55 e8             	mov    -0x18(%ebp),%edx
801090df:	01 ca                	add    %ecx,%edx
801090e1:	8b 12                	mov    (%edx),%edx
801090e3:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801090e9:	83 ec 04             	sub    $0x4,%esp
801090ec:	ff 75 0c             	push   0xc(%ebp)
801090ef:	50                   	push   %eax
801090f0:	52                   	push   %edx
801090f1:	e8 ad bc ff ff       	call   80104da3 <memmove>
801090f6:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
801090f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090fc:	c1 e0 04             	shl    $0x4,%eax
801090ff:	89 c2                	mov    %eax,%edx
80109101:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109104:	01 d0                	add    %edx,%eax
80109106:	8b 55 0c             	mov    0xc(%ebp),%edx
80109109:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
8010910d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109110:	c1 e0 04             	shl    $0x4,%eax
80109113:	89 c2                	mov    %eax,%edx
80109115:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109118:	01 d0                	add    %edx,%eax
8010911a:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
8010911e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109121:	c1 e0 04             	shl    $0x4,%eax
80109124:	89 c2                	mov    %eax,%edx
80109126:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109129:	01 d0                	add    %edx,%eax
8010912b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
8010912f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109132:	c1 e0 04             	shl    $0x4,%eax
80109135:	89 c2                	mov    %eax,%edx
80109137:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010913a:	01 d0                	add    %edx,%eax
8010913c:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109140:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109143:	c1 e0 04             	shl    $0x4,%eax
80109146:	89 c2                	mov    %eax,%edx
80109148:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010914b:	01 d0                	add    %edx,%eax
8010914d:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109153:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109156:	c1 e0 04             	shl    $0x4,%eax
80109159:	89 c2                	mov    %eax,%edx
8010915b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010915e:	01 d0                	add    %edx,%eax
80109160:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109164:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109167:	8b 00                	mov    (%eax),%eax
80109169:	83 c0 01             	add    $0x1,%eax
8010916c:	0f b6 d0             	movzbl %al,%edx
8010916f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109172:	89 10                	mov    %edx,(%eax)
    return len;
80109174:	8b 45 0c             	mov    0xc(%ebp),%eax
80109177:	eb 05                	jmp    8010917e <i8254_send+0x11f>
  }else{
    return -1;
80109179:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
8010917e:	c9                   	leave
8010917f:	c3                   	ret

80109180 <i8254_intr>:

void i8254_intr(){
80109180:	f3 0f 1e fb          	endbr32
80109184:	55                   	push   %ebp
80109185:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109187:	a1 b8 80 19 80       	mov    0x801980b8,%eax
8010918c:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109192:	90                   	nop
80109193:	5d                   	pop    %ebp
80109194:	c3                   	ret

80109195 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109195:	f3 0f 1e fb          	endbr32
80109199:	55                   	push   %ebp
8010919a:	89 e5                	mov    %esp,%ebp
8010919c:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
8010919f:	8b 45 08             	mov    0x8(%ebp),%eax
801091a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801091a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091a8:	0f b7 00             	movzwl (%eax),%eax
801091ab:	66 3d 00 01          	cmp    $0x100,%ax
801091af:	74 0a                	je     801091bb <arp_proc+0x26>
801091b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091b6:	e9 4f 01 00 00       	jmp    8010930a <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801091bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091be:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801091c2:	66 83 f8 08          	cmp    $0x8,%ax
801091c6:	74 0a                	je     801091d2 <arp_proc+0x3d>
801091c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091cd:	e9 38 01 00 00       	jmp    8010930a <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
801091d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091d5:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801091d9:	3c 06                	cmp    $0x6,%al
801091db:	74 0a                	je     801091e7 <arp_proc+0x52>
801091dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091e2:	e9 23 01 00 00       	jmp    8010930a <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
801091e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ea:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801091ee:	3c 04                	cmp    $0x4,%al
801091f0:	74 0a                	je     801091fc <arp_proc+0x67>
801091f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091f7:	e9 0e 01 00 00       	jmp    8010930a <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801091fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ff:	83 c0 18             	add    $0x18,%eax
80109202:	83 ec 04             	sub    $0x4,%esp
80109205:	6a 04                	push   $0x4
80109207:	50                   	push   %eax
80109208:	68 e4 f4 10 80       	push   $0x8010f4e4
8010920d:	e8 35 bb ff ff       	call   80104d47 <memcmp>
80109212:	83 c4 10             	add    $0x10,%esp
80109215:	85 c0                	test   %eax,%eax
80109217:	74 27                	je     80109240 <arp_proc+0xab>
80109219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010921c:	83 c0 0e             	add    $0xe,%eax
8010921f:	83 ec 04             	sub    $0x4,%esp
80109222:	6a 04                	push   $0x4
80109224:	50                   	push   %eax
80109225:	68 e4 f4 10 80       	push   $0x8010f4e4
8010922a:	e8 18 bb ff ff       	call   80104d47 <memcmp>
8010922f:	83 c4 10             	add    $0x10,%esp
80109232:	85 c0                	test   %eax,%eax
80109234:	74 0a                	je     80109240 <arp_proc+0xab>
80109236:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010923b:	e9 ca 00 00 00       	jmp    8010930a <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109243:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109247:	66 3d 00 01          	cmp    $0x100,%ax
8010924b:	75 69                	jne    801092b6 <arp_proc+0x121>
8010924d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109250:	83 c0 18             	add    $0x18,%eax
80109253:	83 ec 04             	sub    $0x4,%esp
80109256:	6a 04                	push   $0x4
80109258:	50                   	push   %eax
80109259:	68 e4 f4 10 80       	push   $0x8010f4e4
8010925e:	e8 e4 ba ff ff       	call   80104d47 <memcmp>
80109263:	83 c4 10             	add    $0x10,%esp
80109266:	85 c0                	test   %eax,%eax
80109268:	75 4c                	jne    801092b6 <arp_proc+0x121>
    uint send = (uint)kalloc();
8010926a:	e8 33 96 ff ff       	call   801028a2 <kalloc>
8010926f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109272:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109279:	83 ec 04             	sub    $0x4,%esp
8010927c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010927f:	50                   	push   %eax
80109280:	ff 75 f0             	push   -0x10(%ebp)
80109283:	ff 75 f4             	push   -0xc(%ebp)
80109286:	e8 33 04 00 00       	call   801096be <arp_reply_pkt_create>
8010928b:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
8010928e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109291:	83 ec 08             	sub    $0x8,%esp
80109294:	50                   	push   %eax
80109295:	ff 75 f0             	push   -0x10(%ebp)
80109298:	e8 c2 fd ff ff       	call   8010905f <i8254_send>
8010929d:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801092a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092a3:	83 ec 0c             	sub    $0xc,%esp
801092a6:	50                   	push   %eax
801092a7:	e8 58 95 ff ff       	call   80102804 <kfree>
801092ac:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801092af:	b8 02 00 00 00       	mov    $0x2,%eax
801092b4:	eb 54                	jmp    8010930a <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801092b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092b9:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801092bd:	66 3d 00 02          	cmp    $0x200,%ax
801092c1:	75 42                	jne    80109305 <arp_proc+0x170>
801092c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092c6:	83 c0 18             	add    $0x18,%eax
801092c9:	83 ec 04             	sub    $0x4,%esp
801092cc:	6a 04                	push   $0x4
801092ce:	50                   	push   %eax
801092cf:	68 e4 f4 10 80       	push   $0x8010f4e4
801092d4:	e8 6e ba ff ff       	call   80104d47 <memcmp>
801092d9:	83 c4 10             	add    $0x10,%esp
801092dc:	85 c0                	test   %eax,%eax
801092de:	75 25                	jne    80109305 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
801092e0:	83 ec 0c             	sub    $0xc,%esp
801092e3:	68 fc c5 10 80       	push   $0x8010c5fc
801092e8:	e8 1f 71 ff ff       	call   8010040c <cprintf>
801092ed:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801092f0:	83 ec 0c             	sub    $0xc,%esp
801092f3:	ff 75 f4             	push   -0xc(%ebp)
801092f6:	e8 b7 01 00 00       	call   801094b2 <arp_table_update>
801092fb:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801092fe:	b8 01 00 00 00       	mov    $0x1,%eax
80109303:	eb 05                	jmp    8010930a <arp_proc+0x175>
  }else{
    return -1;
80109305:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
8010930a:	c9                   	leave
8010930b:	c3                   	ret

8010930c <arp_scan>:

void arp_scan(){
8010930c:	f3 0f 1e fb          	endbr32
80109310:	55                   	push   %ebp
80109311:	89 e5                	mov    %esp,%ebp
80109313:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109316:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010931d:	eb 6f                	jmp    8010938e <arp_scan+0x82>
    uint send = (uint)kalloc();
8010931f:	e8 7e 95 ff ff       	call   801028a2 <kalloc>
80109324:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109327:	83 ec 04             	sub    $0x4,%esp
8010932a:	ff 75 f4             	push   -0xc(%ebp)
8010932d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109330:	50                   	push   %eax
80109331:	ff 75 ec             	push   -0x14(%ebp)
80109334:	e8 62 00 00 00       	call   8010939b <arp_broadcast>
80109339:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
8010933c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010933f:	83 ec 08             	sub    $0x8,%esp
80109342:	50                   	push   %eax
80109343:	ff 75 ec             	push   -0x14(%ebp)
80109346:	e8 14 fd ff ff       	call   8010905f <i8254_send>
8010934b:	83 c4 10             	add    $0x10,%esp
8010934e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109351:	eb 22                	jmp    80109375 <arp_scan+0x69>
      microdelay(1);
80109353:	83 ec 0c             	sub    $0xc,%esp
80109356:	6a 01                	push   $0x1
80109358:	e8 f7 98 ff ff       	call   80102c54 <microdelay>
8010935d:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109360:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109363:	83 ec 08             	sub    $0x8,%esp
80109366:	50                   	push   %eax
80109367:	ff 75 ec             	push   -0x14(%ebp)
8010936a:	e8 f0 fc ff ff       	call   8010905f <i8254_send>
8010936f:	83 c4 10             	add    $0x10,%esp
80109372:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109375:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109379:	74 d8                	je     80109353 <arp_scan+0x47>
    }
    kfree((char *)send);
8010937b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010937e:	83 ec 0c             	sub    $0xc,%esp
80109381:	50                   	push   %eax
80109382:	e8 7d 94 ff ff       	call   80102804 <kfree>
80109387:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
8010938a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010938e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109395:	7e 88                	jle    8010931f <arp_scan+0x13>
  }
}
80109397:	90                   	nop
80109398:	90                   	nop
80109399:	c9                   	leave
8010939a:	c3                   	ret

8010939b <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
8010939b:	f3 0f 1e fb          	endbr32
8010939f:	55                   	push   %ebp
801093a0:	89 e5                	mov    %esp,%ebp
801093a2:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801093a5:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801093a9:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801093ad:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801093b1:	8b 45 10             	mov    0x10(%ebp),%eax
801093b4:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801093b7:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801093be:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801093c4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801093cb:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801093d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801093d4:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801093da:	8b 45 08             	mov    0x8(%ebp),%eax
801093dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801093e0:	8b 45 08             	mov    0x8(%ebp),%eax
801093e3:	83 c0 0e             	add    $0xe,%eax
801093e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801093e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093ec:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801093f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093f3:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801093f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093fa:	83 ec 04             	sub    $0x4,%esp
801093fd:	6a 06                	push   $0x6
801093ff:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109402:	52                   	push   %edx
80109403:	50                   	push   %eax
80109404:	e8 9a b9 ff ff       	call   80104da3 <memmove>
80109409:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010940c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010940f:	83 c0 06             	add    $0x6,%eax
80109412:	83 ec 04             	sub    $0x4,%esp
80109415:	6a 06                	push   $0x6
80109417:	68 68 d0 18 80       	push   $0x8018d068
8010941c:	50                   	push   %eax
8010941d:	e8 81 b9 ff ff       	call   80104da3 <memmove>
80109422:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109425:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109428:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010942d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109430:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109436:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109439:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010943d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109440:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109444:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109447:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
8010944d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109450:	8d 50 12             	lea    0x12(%eax),%edx
80109453:	83 ec 04             	sub    $0x4,%esp
80109456:	6a 06                	push   $0x6
80109458:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010945b:	50                   	push   %eax
8010945c:	52                   	push   %edx
8010945d:	e8 41 b9 ff ff       	call   80104da3 <memmove>
80109462:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109465:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109468:	8d 50 18             	lea    0x18(%eax),%edx
8010946b:	83 ec 04             	sub    $0x4,%esp
8010946e:	6a 04                	push   $0x4
80109470:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109473:	50                   	push   %eax
80109474:	52                   	push   %edx
80109475:	e8 29 b9 ff ff       	call   80104da3 <memmove>
8010947a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010947d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109480:	83 c0 08             	add    $0x8,%eax
80109483:	83 ec 04             	sub    $0x4,%esp
80109486:	6a 06                	push   $0x6
80109488:	68 68 d0 18 80       	push   $0x8018d068
8010948d:	50                   	push   %eax
8010948e:	e8 10 b9 ff ff       	call   80104da3 <memmove>
80109493:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109499:	83 c0 0e             	add    $0xe,%eax
8010949c:	83 ec 04             	sub    $0x4,%esp
8010949f:	6a 04                	push   $0x4
801094a1:	68 e4 f4 10 80       	push   $0x8010f4e4
801094a6:	50                   	push   %eax
801094a7:	e8 f7 b8 ff ff       	call   80104da3 <memmove>
801094ac:	83 c4 10             	add    $0x10,%esp
}
801094af:	90                   	nop
801094b0:	c9                   	leave
801094b1:	c3                   	ret

801094b2 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801094b2:	f3 0f 1e fb          	endbr32
801094b6:	55                   	push   %ebp
801094b7:	89 e5                	mov    %esp,%ebp
801094b9:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801094bc:	8b 45 08             	mov    0x8(%ebp),%eax
801094bf:	83 c0 0e             	add    $0xe,%eax
801094c2:	83 ec 0c             	sub    $0xc,%esp
801094c5:	50                   	push   %eax
801094c6:	e8 bc 00 00 00       	call   80109587 <arp_table_search>
801094cb:	83 c4 10             	add    $0x10,%esp
801094ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801094d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801094d5:	78 2d                	js     80109504 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801094d7:	8b 45 08             	mov    0x8(%ebp),%eax
801094da:	8d 48 08             	lea    0x8(%eax),%ecx
801094dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094e0:	89 d0                	mov    %edx,%eax
801094e2:	c1 e0 02             	shl    $0x2,%eax
801094e5:	01 d0                	add    %edx,%eax
801094e7:	01 c0                	add    %eax,%eax
801094e9:	01 d0                	add    %edx,%eax
801094eb:	05 80 d0 18 80       	add    $0x8018d080,%eax
801094f0:	83 c0 04             	add    $0x4,%eax
801094f3:	83 ec 04             	sub    $0x4,%esp
801094f6:	6a 06                	push   $0x6
801094f8:	51                   	push   %ecx
801094f9:	50                   	push   %eax
801094fa:	e8 a4 b8 ff ff       	call   80104da3 <memmove>
801094ff:	83 c4 10             	add    $0x10,%esp
80109502:	eb 70                	jmp    80109574 <arp_table_update+0xc2>
  }else{
    index += 1;
80109504:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109508:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010950b:	8b 45 08             	mov    0x8(%ebp),%eax
8010950e:	8d 48 08             	lea    0x8(%eax),%ecx
80109511:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109514:	89 d0                	mov    %edx,%eax
80109516:	c1 e0 02             	shl    $0x2,%eax
80109519:	01 d0                	add    %edx,%eax
8010951b:	01 c0                	add    %eax,%eax
8010951d:	01 d0                	add    %edx,%eax
8010951f:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109524:	83 c0 04             	add    $0x4,%eax
80109527:	83 ec 04             	sub    $0x4,%esp
8010952a:	6a 06                	push   $0x6
8010952c:	51                   	push   %ecx
8010952d:	50                   	push   %eax
8010952e:	e8 70 b8 ff ff       	call   80104da3 <memmove>
80109533:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109536:	8b 45 08             	mov    0x8(%ebp),%eax
80109539:	8d 48 0e             	lea    0xe(%eax),%ecx
8010953c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010953f:	89 d0                	mov    %edx,%eax
80109541:	c1 e0 02             	shl    $0x2,%eax
80109544:	01 d0                	add    %edx,%eax
80109546:	01 c0                	add    %eax,%eax
80109548:	01 d0                	add    %edx,%eax
8010954a:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010954f:	83 ec 04             	sub    $0x4,%esp
80109552:	6a 04                	push   $0x4
80109554:	51                   	push   %ecx
80109555:	50                   	push   %eax
80109556:	e8 48 b8 ff ff       	call   80104da3 <memmove>
8010955b:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010955e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109561:	89 d0                	mov    %edx,%eax
80109563:	c1 e0 02             	shl    $0x2,%eax
80109566:	01 d0                	add    %edx,%eax
80109568:	01 c0                	add    %eax,%eax
8010956a:	01 d0                	add    %edx,%eax
8010956c:	05 8a d0 18 80       	add    $0x8018d08a,%eax
80109571:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109574:	83 ec 0c             	sub    $0xc,%esp
80109577:	68 80 d0 18 80       	push   $0x8018d080
8010957c:	e8 87 00 00 00       	call   80109608 <print_arp_table>
80109581:	83 c4 10             	add    $0x10,%esp
}
80109584:	90                   	nop
80109585:	c9                   	leave
80109586:	c3                   	ret

80109587 <arp_table_search>:

int arp_table_search(uchar *ip){
80109587:	f3 0f 1e fb          	endbr32
8010958b:	55                   	push   %ebp
8010958c:	89 e5                	mov    %esp,%ebp
8010958e:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109591:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109598:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010959f:	eb 59                	jmp    801095fa <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801095a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095a4:	89 d0                	mov    %edx,%eax
801095a6:	c1 e0 02             	shl    $0x2,%eax
801095a9:	01 d0                	add    %edx,%eax
801095ab:	01 c0                	add    %eax,%eax
801095ad:	01 d0                	add    %edx,%eax
801095af:	05 80 d0 18 80       	add    $0x8018d080,%eax
801095b4:	83 ec 04             	sub    $0x4,%esp
801095b7:	6a 04                	push   $0x4
801095b9:	ff 75 08             	push   0x8(%ebp)
801095bc:	50                   	push   %eax
801095bd:	e8 85 b7 ff ff       	call   80104d47 <memcmp>
801095c2:	83 c4 10             	add    $0x10,%esp
801095c5:	85 c0                	test   %eax,%eax
801095c7:	75 05                	jne    801095ce <arp_table_search+0x47>
      return i;
801095c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095cc:	eb 38                	jmp    80109606 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
801095ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095d1:	89 d0                	mov    %edx,%eax
801095d3:	c1 e0 02             	shl    $0x2,%eax
801095d6:	01 d0                	add    %edx,%eax
801095d8:	01 c0                	add    %eax,%eax
801095da:	01 d0                	add    %edx,%eax
801095dc:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801095e1:	0f b6 00             	movzbl (%eax),%eax
801095e4:	84 c0                	test   %al,%al
801095e6:	75 0e                	jne    801095f6 <arp_table_search+0x6f>
801095e8:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801095ec:	75 08                	jne    801095f6 <arp_table_search+0x6f>
      empty = -i;
801095ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095f1:	f7 d8                	neg    %eax
801095f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801095f6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801095fa:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801095fe:	7e a1                	jle    801095a1 <arp_table_search+0x1a>
    }
  }
  return empty-1;
80109600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109603:	83 e8 01             	sub    $0x1,%eax
}
80109606:	c9                   	leave
80109607:	c3                   	ret

80109608 <print_arp_table>:

void print_arp_table(){
80109608:	f3 0f 1e fb          	endbr32
8010960c:	55                   	push   %ebp
8010960d:	89 e5                	mov    %esp,%ebp
8010960f:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109612:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109619:	e9 92 00 00 00       	jmp    801096b0 <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
8010961e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109621:	89 d0                	mov    %edx,%eax
80109623:	c1 e0 02             	shl    $0x2,%eax
80109626:	01 d0                	add    %edx,%eax
80109628:	01 c0                	add    %eax,%eax
8010962a:	01 d0                	add    %edx,%eax
8010962c:	05 8a d0 18 80       	add    $0x8018d08a,%eax
80109631:	0f b6 00             	movzbl (%eax),%eax
80109634:	84 c0                	test   %al,%al
80109636:	74 74                	je     801096ac <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109638:	83 ec 08             	sub    $0x8,%esp
8010963b:	ff 75 f4             	push   -0xc(%ebp)
8010963e:	68 0f c6 10 80       	push   $0x8010c60f
80109643:	e8 c4 6d ff ff       	call   8010040c <cprintf>
80109648:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010964b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010964e:	89 d0                	mov    %edx,%eax
80109650:	c1 e0 02             	shl    $0x2,%eax
80109653:	01 d0                	add    %edx,%eax
80109655:	01 c0                	add    %eax,%eax
80109657:	01 d0                	add    %edx,%eax
80109659:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010965e:	83 ec 0c             	sub    $0xc,%esp
80109661:	50                   	push   %eax
80109662:	e8 5c 02 00 00       	call   801098c3 <print_ipv4>
80109667:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
8010966a:	83 ec 0c             	sub    $0xc,%esp
8010966d:	68 1e c6 10 80       	push   $0x8010c61e
80109672:	e8 95 6d ff ff       	call   8010040c <cprintf>
80109677:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
8010967a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010967d:	89 d0                	mov    %edx,%eax
8010967f:	c1 e0 02             	shl    $0x2,%eax
80109682:	01 d0                	add    %edx,%eax
80109684:	01 c0                	add    %eax,%eax
80109686:	01 d0                	add    %edx,%eax
80109688:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010968d:	83 c0 04             	add    $0x4,%eax
80109690:	83 ec 0c             	sub    $0xc,%esp
80109693:	50                   	push   %eax
80109694:	e8 7c 02 00 00       	call   80109915 <print_mac>
80109699:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
8010969c:	83 ec 0c             	sub    $0xc,%esp
8010969f:	68 20 c6 10 80       	push   $0x8010c620
801096a4:	e8 63 6d ff ff       	call   8010040c <cprintf>
801096a9:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801096ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801096b0:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801096b4:	0f 8e 64 ff ff ff    	jle    8010961e <print_arp_table+0x16>
    }
  }
}
801096ba:	90                   	nop
801096bb:	90                   	nop
801096bc:	c9                   	leave
801096bd:	c3                   	ret

801096be <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801096be:	f3 0f 1e fb          	endbr32
801096c2:	55                   	push   %ebp
801096c3:	89 e5                	mov    %esp,%ebp
801096c5:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801096c8:	8b 45 10             	mov    0x10(%ebp),%eax
801096cb:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801096d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801096d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801096d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801096da:	83 c0 0e             	add    $0xe,%eax
801096dd:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801096e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096e3:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801096e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ea:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801096ee:	8b 45 08             	mov    0x8(%ebp),%eax
801096f1:	8d 50 08             	lea    0x8(%eax),%edx
801096f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096f7:	83 ec 04             	sub    $0x4,%esp
801096fa:	6a 06                	push   $0x6
801096fc:	52                   	push   %edx
801096fd:	50                   	push   %eax
801096fe:	e8 a0 b6 ff ff       	call   80104da3 <memmove>
80109703:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109709:	83 c0 06             	add    $0x6,%eax
8010970c:	83 ec 04             	sub    $0x4,%esp
8010970f:	6a 06                	push   $0x6
80109711:	68 68 d0 18 80       	push   $0x8018d068
80109716:	50                   	push   %eax
80109717:	e8 87 b6 ff ff       	call   80104da3 <memmove>
8010971c:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010971f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109722:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109727:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010972a:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109730:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109733:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109737:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010973a:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010973e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109741:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109747:	8b 45 08             	mov    0x8(%ebp),%eax
8010974a:	8d 50 08             	lea    0x8(%eax),%edx
8010974d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109750:	83 c0 12             	add    $0x12,%eax
80109753:	83 ec 04             	sub    $0x4,%esp
80109756:	6a 06                	push   $0x6
80109758:	52                   	push   %edx
80109759:	50                   	push   %eax
8010975a:	e8 44 b6 ff ff       	call   80104da3 <memmove>
8010975f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109762:	8b 45 08             	mov    0x8(%ebp),%eax
80109765:	8d 50 0e             	lea    0xe(%eax),%edx
80109768:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010976b:	83 c0 18             	add    $0x18,%eax
8010976e:	83 ec 04             	sub    $0x4,%esp
80109771:	6a 04                	push   $0x4
80109773:	52                   	push   %edx
80109774:	50                   	push   %eax
80109775:	e8 29 b6 ff ff       	call   80104da3 <memmove>
8010977a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010977d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109780:	83 c0 08             	add    $0x8,%eax
80109783:	83 ec 04             	sub    $0x4,%esp
80109786:	6a 06                	push   $0x6
80109788:	68 68 d0 18 80       	push   $0x8018d068
8010978d:	50                   	push   %eax
8010978e:	e8 10 b6 ff ff       	call   80104da3 <memmove>
80109793:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109796:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109799:	83 c0 0e             	add    $0xe,%eax
8010979c:	83 ec 04             	sub    $0x4,%esp
8010979f:	6a 04                	push   $0x4
801097a1:	68 e4 f4 10 80       	push   $0x8010f4e4
801097a6:	50                   	push   %eax
801097a7:	e8 f7 b5 ff ff       	call   80104da3 <memmove>
801097ac:	83 c4 10             	add    $0x10,%esp
}
801097af:	90                   	nop
801097b0:	c9                   	leave
801097b1:	c3                   	ret

801097b2 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801097b2:	f3 0f 1e fb          	endbr32
801097b6:	55                   	push   %ebp
801097b7:	89 e5                	mov    %esp,%ebp
801097b9:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801097bc:	83 ec 0c             	sub    $0xc,%esp
801097bf:	68 22 c6 10 80       	push   $0x8010c622
801097c4:	e8 43 6c ff ff       	call   8010040c <cprintf>
801097c9:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801097cc:	8b 45 08             	mov    0x8(%ebp),%eax
801097cf:	83 c0 0e             	add    $0xe,%eax
801097d2:	83 ec 0c             	sub    $0xc,%esp
801097d5:	50                   	push   %eax
801097d6:	e8 e8 00 00 00       	call   801098c3 <print_ipv4>
801097db:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801097de:	83 ec 0c             	sub    $0xc,%esp
801097e1:	68 20 c6 10 80       	push   $0x8010c620
801097e6:	e8 21 6c ff ff       	call   8010040c <cprintf>
801097eb:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801097ee:	8b 45 08             	mov    0x8(%ebp),%eax
801097f1:	83 c0 08             	add    $0x8,%eax
801097f4:	83 ec 0c             	sub    $0xc,%esp
801097f7:	50                   	push   %eax
801097f8:	e8 18 01 00 00       	call   80109915 <print_mac>
801097fd:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109800:	83 ec 0c             	sub    $0xc,%esp
80109803:	68 20 c6 10 80       	push   $0x8010c620
80109808:	e8 ff 6b ff ff       	call   8010040c <cprintf>
8010980d:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109810:	83 ec 0c             	sub    $0xc,%esp
80109813:	68 39 c6 10 80       	push   $0x8010c639
80109818:	e8 ef 6b ff ff       	call   8010040c <cprintf>
8010981d:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109820:	8b 45 08             	mov    0x8(%ebp),%eax
80109823:	83 c0 18             	add    $0x18,%eax
80109826:	83 ec 0c             	sub    $0xc,%esp
80109829:	50                   	push   %eax
8010982a:	e8 94 00 00 00       	call   801098c3 <print_ipv4>
8010982f:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109832:	83 ec 0c             	sub    $0xc,%esp
80109835:	68 20 c6 10 80       	push   $0x8010c620
8010983a:	e8 cd 6b ff ff       	call   8010040c <cprintf>
8010983f:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109842:	8b 45 08             	mov    0x8(%ebp),%eax
80109845:	83 c0 12             	add    $0x12,%eax
80109848:	83 ec 0c             	sub    $0xc,%esp
8010984b:	50                   	push   %eax
8010984c:	e8 c4 00 00 00       	call   80109915 <print_mac>
80109851:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109854:	83 ec 0c             	sub    $0xc,%esp
80109857:	68 20 c6 10 80       	push   $0x8010c620
8010985c:	e8 ab 6b ff ff       	call   8010040c <cprintf>
80109861:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109864:	83 ec 0c             	sub    $0xc,%esp
80109867:	68 50 c6 10 80       	push   $0x8010c650
8010986c:	e8 9b 6b ff ff       	call   8010040c <cprintf>
80109871:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109874:	8b 45 08             	mov    0x8(%ebp),%eax
80109877:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010987b:	66 3d 00 01          	cmp    $0x100,%ax
8010987f:	75 12                	jne    80109893 <print_arp_info+0xe1>
80109881:	83 ec 0c             	sub    $0xc,%esp
80109884:	68 5c c6 10 80       	push   $0x8010c65c
80109889:	e8 7e 6b ff ff       	call   8010040c <cprintf>
8010988e:	83 c4 10             	add    $0x10,%esp
80109891:	eb 1d                	jmp    801098b0 <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109893:	8b 45 08             	mov    0x8(%ebp),%eax
80109896:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010989a:	66 3d 00 02          	cmp    $0x200,%ax
8010989e:	75 10                	jne    801098b0 <print_arp_info+0xfe>
    cprintf("Reply\n");
801098a0:	83 ec 0c             	sub    $0xc,%esp
801098a3:	68 65 c6 10 80       	push   $0x8010c665
801098a8:	e8 5f 6b ff ff       	call   8010040c <cprintf>
801098ad:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801098b0:	83 ec 0c             	sub    $0xc,%esp
801098b3:	68 20 c6 10 80       	push   $0x8010c620
801098b8:	e8 4f 6b ff ff       	call   8010040c <cprintf>
801098bd:	83 c4 10             	add    $0x10,%esp
}
801098c0:	90                   	nop
801098c1:	c9                   	leave
801098c2:	c3                   	ret

801098c3 <print_ipv4>:

void print_ipv4(uchar *ip){
801098c3:	f3 0f 1e fb          	endbr32
801098c7:	55                   	push   %ebp
801098c8:	89 e5                	mov    %esp,%ebp
801098ca:	53                   	push   %ebx
801098cb:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801098ce:	8b 45 08             	mov    0x8(%ebp),%eax
801098d1:	83 c0 03             	add    $0x3,%eax
801098d4:	0f b6 00             	movzbl (%eax),%eax
801098d7:	0f b6 d8             	movzbl %al,%ebx
801098da:	8b 45 08             	mov    0x8(%ebp),%eax
801098dd:	83 c0 02             	add    $0x2,%eax
801098e0:	0f b6 00             	movzbl (%eax),%eax
801098e3:	0f b6 c8             	movzbl %al,%ecx
801098e6:	8b 45 08             	mov    0x8(%ebp),%eax
801098e9:	83 c0 01             	add    $0x1,%eax
801098ec:	0f b6 00             	movzbl (%eax),%eax
801098ef:	0f b6 d0             	movzbl %al,%edx
801098f2:	8b 45 08             	mov    0x8(%ebp),%eax
801098f5:	0f b6 00             	movzbl (%eax),%eax
801098f8:	0f b6 c0             	movzbl %al,%eax
801098fb:	83 ec 0c             	sub    $0xc,%esp
801098fe:	53                   	push   %ebx
801098ff:	51                   	push   %ecx
80109900:	52                   	push   %edx
80109901:	50                   	push   %eax
80109902:	68 6c c6 10 80       	push   $0x8010c66c
80109907:	e8 00 6b ff ff       	call   8010040c <cprintf>
8010990c:	83 c4 20             	add    $0x20,%esp
}
8010990f:	90                   	nop
80109910:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109913:	c9                   	leave
80109914:	c3                   	ret

80109915 <print_mac>:

void print_mac(uchar *mac){
80109915:	f3 0f 1e fb          	endbr32
80109919:	55                   	push   %ebp
8010991a:	89 e5                	mov    %esp,%ebp
8010991c:	57                   	push   %edi
8010991d:	56                   	push   %esi
8010991e:	53                   	push   %ebx
8010991f:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109922:	8b 45 08             	mov    0x8(%ebp),%eax
80109925:	83 c0 05             	add    $0x5,%eax
80109928:	0f b6 00             	movzbl (%eax),%eax
8010992b:	0f b6 f8             	movzbl %al,%edi
8010992e:	8b 45 08             	mov    0x8(%ebp),%eax
80109931:	83 c0 04             	add    $0x4,%eax
80109934:	0f b6 00             	movzbl (%eax),%eax
80109937:	0f b6 f0             	movzbl %al,%esi
8010993a:	8b 45 08             	mov    0x8(%ebp),%eax
8010993d:	83 c0 03             	add    $0x3,%eax
80109940:	0f b6 00             	movzbl (%eax),%eax
80109943:	0f b6 d8             	movzbl %al,%ebx
80109946:	8b 45 08             	mov    0x8(%ebp),%eax
80109949:	83 c0 02             	add    $0x2,%eax
8010994c:	0f b6 00             	movzbl (%eax),%eax
8010994f:	0f b6 c8             	movzbl %al,%ecx
80109952:	8b 45 08             	mov    0x8(%ebp),%eax
80109955:	83 c0 01             	add    $0x1,%eax
80109958:	0f b6 00             	movzbl (%eax),%eax
8010995b:	0f b6 d0             	movzbl %al,%edx
8010995e:	8b 45 08             	mov    0x8(%ebp),%eax
80109961:	0f b6 00             	movzbl (%eax),%eax
80109964:	0f b6 c0             	movzbl %al,%eax
80109967:	83 ec 04             	sub    $0x4,%esp
8010996a:	57                   	push   %edi
8010996b:	56                   	push   %esi
8010996c:	53                   	push   %ebx
8010996d:	51                   	push   %ecx
8010996e:	52                   	push   %edx
8010996f:	50                   	push   %eax
80109970:	68 84 c6 10 80       	push   $0x8010c684
80109975:	e8 92 6a ff ff       	call   8010040c <cprintf>
8010997a:	83 c4 20             	add    $0x20,%esp
}
8010997d:	90                   	nop
8010997e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109981:	5b                   	pop    %ebx
80109982:	5e                   	pop    %esi
80109983:	5f                   	pop    %edi
80109984:	5d                   	pop    %ebp
80109985:	c3                   	ret

80109986 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109986:	f3 0f 1e fb          	endbr32
8010998a:	55                   	push   %ebp
8010998b:	89 e5                	mov    %esp,%ebp
8010998d:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109990:	8b 45 08             	mov    0x8(%ebp),%eax
80109993:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109996:	8b 45 08             	mov    0x8(%ebp),%eax
80109999:	83 c0 0e             	add    $0xe,%eax
8010999c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010999f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099a2:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801099a6:	3c 08                	cmp    $0x8,%al
801099a8:	75 1b                	jne    801099c5 <eth_proc+0x3f>
801099aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099ad:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801099b1:	3c 06                	cmp    $0x6,%al
801099b3:	75 10                	jne    801099c5 <eth_proc+0x3f>
    arp_proc(pkt_addr);
801099b5:	83 ec 0c             	sub    $0xc,%esp
801099b8:	ff 75 f0             	push   -0x10(%ebp)
801099bb:	e8 d5 f7 ff ff       	call   80109195 <arp_proc>
801099c0:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801099c3:	eb 24                	jmp    801099e9 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801099c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099c8:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801099cc:	3c 08                	cmp    $0x8,%al
801099ce:	75 19                	jne    801099e9 <eth_proc+0x63>
801099d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d3:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801099d7:	84 c0                	test   %al,%al
801099d9:	75 0e                	jne    801099e9 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
801099db:	83 ec 0c             	sub    $0xc,%esp
801099de:	ff 75 08             	push   0x8(%ebp)
801099e1:	e8 b3 00 00 00       	call   80109a99 <ipv4_proc>
801099e6:	83 c4 10             	add    $0x10,%esp
}
801099e9:	90                   	nop
801099ea:	c9                   	leave
801099eb:	c3                   	ret

801099ec <N2H_ushort>:

ushort N2H_ushort(ushort value){
801099ec:	f3 0f 1e fb          	endbr32
801099f0:	55                   	push   %ebp
801099f1:	89 e5                	mov    %esp,%ebp
801099f3:	83 ec 04             	sub    $0x4,%esp
801099f6:	8b 45 08             	mov    0x8(%ebp),%eax
801099f9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801099fd:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a01:	c1 e0 08             	shl    $0x8,%eax
80109a04:	89 c2                	mov    %eax,%edx
80109a06:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a0a:	66 c1 e8 08          	shr    $0x8,%ax
80109a0e:	01 d0                	add    %edx,%eax
}
80109a10:	c9                   	leave
80109a11:	c3                   	ret

80109a12 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109a12:	f3 0f 1e fb          	endbr32
80109a16:	55                   	push   %ebp
80109a17:	89 e5                	mov    %esp,%ebp
80109a19:	83 ec 04             	sub    $0x4,%esp
80109a1c:	8b 45 08             	mov    0x8(%ebp),%eax
80109a1f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109a23:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a27:	c1 e0 08             	shl    $0x8,%eax
80109a2a:	89 c2                	mov    %eax,%edx
80109a2c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a30:	66 c1 e8 08          	shr    $0x8,%ax
80109a34:	01 d0                	add    %edx,%eax
}
80109a36:	c9                   	leave
80109a37:	c3                   	ret

80109a38 <H2N_uint>:

uint H2N_uint(uint value){
80109a38:	f3 0f 1e fb          	endbr32
80109a3c:	55                   	push   %ebp
80109a3d:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80109a42:	c1 e0 18             	shl    $0x18,%eax
80109a45:	25 00 00 00 0f       	and    $0xf000000,%eax
80109a4a:	89 c2                	mov    %eax,%edx
80109a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80109a4f:	c1 e0 08             	shl    $0x8,%eax
80109a52:	25 00 f0 00 00       	and    $0xf000,%eax
80109a57:	09 c2                	or     %eax,%edx
80109a59:	8b 45 08             	mov    0x8(%ebp),%eax
80109a5c:	c1 e8 08             	shr    $0x8,%eax
80109a5f:	83 e0 0f             	and    $0xf,%eax
80109a62:	01 d0                	add    %edx,%eax
}
80109a64:	5d                   	pop    %ebp
80109a65:	c3                   	ret

80109a66 <N2H_uint>:

uint N2H_uint(uint value){
80109a66:	f3 0f 1e fb          	endbr32
80109a6a:	55                   	push   %ebp
80109a6b:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80109a70:	c1 e0 18             	shl    $0x18,%eax
80109a73:	89 c2                	mov    %eax,%edx
80109a75:	8b 45 08             	mov    0x8(%ebp),%eax
80109a78:	c1 e0 08             	shl    $0x8,%eax
80109a7b:	25 00 00 ff 00       	and    $0xff0000,%eax
80109a80:	01 c2                	add    %eax,%edx
80109a82:	8b 45 08             	mov    0x8(%ebp),%eax
80109a85:	c1 e8 08             	shr    $0x8,%eax
80109a88:	25 00 ff 00 00       	and    $0xff00,%eax
80109a8d:	01 c2                	add    %eax,%edx
80109a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80109a92:	c1 e8 18             	shr    $0x18,%eax
80109a95:	01 d0                	add    %edx,%eax
}
80109a97:	5d                   	pop    %ebp
80109a98:	c3                   	ret

80109a99 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109a99:	f3 0f 1e fb          	endbr32
80109a9d:	55                   	push   %ebp
80109a9e:	89 e5                	mov    %esp,%ebp
80109aa0:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80109aa6:	83 c0 0e             	add    $0xe,%eax
80109aa9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aaf:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109ab3:	0f b7 d0             	movzwl %ax,%edx
80109ab6:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109abb:	39 c2                	cmp    %eax,%edx
80109abd:	74 60                	je     80109b1f <ipv4_proc+0x86>
80109abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ac2:	83 c0 0c             	add    $0xc,%eax
80109ac5:	83 ec 04             	sub    $0x4,%esp
80109ac8:	6a 04                	push   $0x4
80109aca:	50                   	push   %eax
80109acb:	68 e4 f4 10 80       	push   $0x8010f4e4
80109ad0:	e8 72 b2 ff ff       	call   80104d47 <memcmp>
80109ad5:	83 c4 10             	add    $0x10,%esp
80109ad8:	85 c0                	test   %eax,%eax
80109ada:	74 43                	je     80109b1f <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
80109adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109adf:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109ae3:	0f b7 c0             	movzwl %ax,%eax
80109ae6:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aee:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109af2:	3c 01                	cmp    $0x1,%al
80109af4:	75 10                	jne    80109b06 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109af6:	83 ec 0c             	sub    $0xc,%esp
80109af9:	ff 75 08             	push   0x8(%ebp)
80109afc:	e8 a7 00 00 00       	call   80109ba8 <icmp_proc>
80109b01:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109b04:	eb 19                	jmp    80109b1f <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b09:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109b0d:	3c 06                	cmp    $0x6,%al
80109b0f:	75 0e                	jne    80109b1f <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
80109b11:	83 ec 0c             	sub    $0xc,%esp
80109b14:	ff 75 08             	push   0x8(%ebp)
80109b17:	e8 c7 03 00 00       	call   80109ee3 <tcp_proc>
80109b1c:	83 c4 10             	add    $0x10,%esp
}
80109b1f:	90                   	nop
80109b20:	c9                   	leave
80109b21:	c3                   	ret

80109b22 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109b22:	f3 0f 1e fb          	endbr32
80109b26:	55                   	push   %ebp
80109b27:	89 e5                	mov    %esp,%ebp
80109b29:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80109b2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b35:	0f b6 00             	movzbl (%eax),%eax
80109b38:	83 e0 0f             	and    $0xf,%eax
80109b3b:	01 c0                	add    %eax,%eax
80109b3d:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109b40:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109b47:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109b4e:	eb 48                	jmp    80109b98 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109b50:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b53:	01 c0                	add    %eax,%eax
80109b55:	89 c2                	mov    %eax,%edx
80109b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b5a:	01 d0                	add    %edx,%eax
80109b5c:	0f b6 00             	movzbl (%eax),%eax
80109b5f:	0f b6 c0             	movzbl %al,%eax
80109b62:	c1 e0 08             	shl    $0x8,%eax
80109b65:	89 c2                	mov    %eax,%edx
80109b67:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b6a:	01 c0                	add    %eax,%eax
80109b6c:	8d 48 01             	lea    0x1(%eax),%ecx
80109b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b72:	01 c8                	add    %ecx,%eax
80109b74:	0f b6 00             	movzbl (%eax),%eax
80109b77:	0f b6 c0             	movzbl %al,%eax
80109b7a:	01 d0                	add    %edx,%eax
80109b7c:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109b7f:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109b86:	76 0c                	jbe    80109b94 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
80109b88:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b8b:	0f b7 c0             	movzwl %ax,%eax
80109b8e:	83 c0 01             	add    $0x1,%eax
80109b91:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109b94:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109b98:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109b9c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109b9f:	7c af                	jl     80109b50 <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
80109ba1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ba4:	f7 d0                	not    %eax
}
80109ba6:	c9                   	leave
80109ba7:	c3                   	ret

80109ba8 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109ba8:	f3 0f 1e fb          	endbr32
80109bac:	55                   	push   %ebp
80109bad:	89 e5                	mov    %esp,%ebp
80109baf:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80109bb5:	83 c0 0e             	add    $0xe,%eax
80109bb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bbe:	0f b6 00             	movzbl (%eax),%eax
80109bc1:	0f b6 c0             	movzbl %al,%eax
80109bc4:	83 e0 0f             	and    $0xf,%eax
80109bc7:	c1 e0 02             	shl    $0x2,%eax
80109bca:	89 c2                	mov    %eax,%edx
80109bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bcf:	01 d0                	add    %edx,%eax
80109bd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109bd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bd7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109bdb:	84 c0                	test   %al,%al
80109bdd:	75 4f                	jne    80109c2e <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109bdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109be2:	0f b6 00             	movzbl (%eax),%eax
80109be5:	3c 08                	cmp    $0x8,%al
80109be7:	75 45                	jne    80109c2e <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109be9:	e8 b4 8c ff ff       	call   801028a2 <kalloc>
80109bee:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109bf1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109bf8:	83 ec 04             	sub    $0x4,%esp
80109bfb:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109bfe:	50                   	push   %eax
80109bff:	ff 75 ec             	push   -0x14(%ebp)
80109c02:	ff 75 08             	push   0x8(%ebp)
80109c05:	e8 7c 00 00 00       	call   80109c86 <icmp_reply_pkt_create>
80109c0a:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109c0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c10:	83 ec 08             	sub    $0x8,%esp
80109c13:	50                   	push   %eax
80109c14:	ff 75 ec             	push   -0x14(%ebp)
80109c17:	e8 43 f4 ff ff       	call   8010905f <i8254_send>
80109c1c:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109c1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c22:	83 ec 0c             	sub    $0xc,%esp
80109c25:	50                   	push   %eax
80109c26:	e8 d9 8b ff ff       	call   80102804 <kfree>
80109c2b:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109c2e:	90                   	nop
80109c2f:	c9                   	leave
80109c30:	c3                   	ret

80109c31 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109c31:	f3 0f 1e fb          	endbr32
80109c35:	55                   	push   %ebp
80109c36:	89 e5                	mov    %esp,%ebp
80109c38:	53                   	push   %ebx
80109c39:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109c3c:	8b 45 08             	mov    0x8(%ebp),%eax
80109c3f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109c43:	0f b7 c0             	movzwl %ax,%eax
80109c46:	83 ec 0c             	sub    $0xc,%esp
80109c49:	50                   	push   %eax
80109c4a:	e8 9d fd ff ff       	call   801099ec <N2H_ushort>
80109c4f:	83 c4 10             	add    $0x10,%esp
80109c52:	0f b7 d8             	movzwl %ax,%ebx
80109c55:	8b 45 08             	mov    0x8(%ebp),%eax
80109c58:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109c5c:	0f b7 c0             	movzwl %ax,%eax
80109c5f:	83 ec 0c             	sub    $0xc,%esp
80109c62:	50                   	push   %eax
80109c63:	e8 84 fd ff ff       	call   801099ec <N2H_ushort>
80109c68:	83 c4 10             	add    $0x10,%esp
80109c6b:	0f b7 c0             	movzwl %ax,%eax
80109c6e:	83 ec 04             	sub    $0x4,%esp
80109c71:	53                   	push   %ebx
80109c72:	50                   	push   %eax
80109c73:	68 a3 c6 10 80       	push   $0x8010c6a3
80109c78:	e8 8f 67 ff ff       	call   8010040c <cprintf>
80109c7d:	83 c4 10             	add    $0x10,%esp
}
80109c80:	90                   	nop
80109c81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109c84:	c9                   	leave
80109c85:	c3                   	ret

80109c86 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109c86:	f3 0f 1e fb          	endbr32
80109c8a:	55                   	push   %ebp
80109c8b:	89 e5                	mov    %esp,%ebp
80109c8d:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109c90:	8b 45 08             	mov    0x8(%ebp),%eax
80109c93:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109c96:	8b 45 08             	mov    0x8(%ebp),%eax
80109c99:	83 c0 0e             	add    $0xe,%eax
80109c9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109c9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ca2:	0f b6 00             	movzbl (%eax),%eax
80109ca5:	0f b6 c0             	movzbl %al,%eax
80109ca8:	83 e0 0f             	and    $0xf,%eax
80109cab:	c1 e0 02             	shl    $0x2,%eax
80109cae:	89 c2                	mov    %eax,%edx
80109cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cb3:	01 d0                	add    %edx,%eax
80109cb5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cbb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109cbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cc1:	83 c0 0e             	add    $0xe,%eax
80109cc4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109cc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cca:	83 c0 14             	add    $0x14,%eax
80109ccd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109cd0:	8b 45 10             	mov    0x10(%ebp),%eax
80109cd3:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cdc:	8d 50 06             	lea    0x6(%eax),%edx
80109cdf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ce2:	83 ec 04             	sub    $0x4,%esp
80109ce5:	6a 06                	push   $0x6
80109ce7:	52                   	push   %edx
80109ce8:	50                   	push   %eax
80109ce9:	e8 b5 b0 ff ff       	call   80104da3 <memmove>
80109cee:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109cf1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cf4:	83 c0 06             	add    $0x6,%eax
80109cf7:	83 ec 04             	sub    $0x4,%esp
80109cfa:	6a 06                	push   $0x6
80109cfc:	68 68 d0 18 80       	push   $0x8018d068
80109d01:	50                   	push   %eax
80109d02:	e8 9c b0 ff ff       	call   80104da3 <memmove>
80109d07:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109d0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d0d:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109d11:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d14:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109d18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d1b:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109d1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d21:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109d25:	83 ec 0c             	sub    $0xc,%esp
80109d28:	6a 54                	push   $0x54
80109d2a:	e8 e3 fc ff ff       	call   80109a12 <H2N_ushort>
80109d2f:	83 c4 10             	add    $0x10,%esp
80109d32:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d35:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109d39:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109d40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d43:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109d47:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109d4e:	83 c0 01             	add    $0x1,%eax
80109d51:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
80109d57:	83 ec 0c             	sub    $0xc,%esp
80109d5a:	68 00 40 00 00       	push   $0x4000
80109d5f:	e8 ae fc ff ff       	call   80109a12 <H2N_ushort>
80109d64:	83 c4 10             	add    $0x10,%esp
80109d67:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d6a:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109d6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d71:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109d75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d78:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109d7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d7f:	83 c0 0c             	add    $0xc,%eax
80109d82:	83 ec 04             	sub    $0x4,%esp
80109d85:	6a 04                	push   $0x4
80109d87:	68 e4 f4 10 80       	push   $0x8010f4e4
80109d8c:	50                   	push   %eax
80109d8d:	e8 11 b0 ff ff       	call   80104da3 <memmove>
80109d92:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109d95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d98:	8d 50 0c             	lea    0xc(%eax),%edx
80109d9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d9e:	83 c0 10             	add    $0x10,%eax
80109da1:	83 ec 04             	sub    $0x4,%esp
80109da4:	6a 04                	push   $0x4
80109da6:	52                   	push   %edx
80109da7:	50                   	push   %eax
80109da8:	e8 f6 af ff ff       	call   80104da3 <memmove>
80109dad:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109db0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109db3:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109db9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dbc:	83 ec 0c             	sub    $0xc,%esp
80109dbf:	50                   	push   %eax
80109dc0:	e8 5d fd ff ff       	call   80109b22 <ipv4_chksum>
80109dc5:	83 c4 10             	add    $0x10,%esp
80109dc8:	0f b7 c0             	movzwl %ax,%eax
80109dcb:	83 ec 0c             	sub    $0xc,%esp
80109dce:	50                   	push   %eax
80109dcf:	e8 3e fc ff ff       	call   80109a12 <H2N_ushort>
80109dd4:	83 c4 10             	add    $0x10,%esp
80109dd7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109dda:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109dde:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109de1:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109de4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109de7:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109deb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dee:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109df2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109df5:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109df9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dfc:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109e00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e03:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109e07:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e0a:	8d 50 08             	lea    0x8(%eax),%edx
80109e0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e10:	83 c0 08             	add    $0x8,%eax
80109e13:	83 ec 04             	sub    $0x4,%esp
80109e16:	6a 08                	push   $0x8
80109e18:	52                   	push   %edx
80109e19:	50                   	push   %eax
80109e1a:	e8 84 af ff ff       	call   80104da3 <memmove>
80109e1f:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109e22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e25:	8d 50 10             	lea    0x10(%eax),%edx
80109e28:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e2b:	83 c0 10             	add    $0x10,%eax
80109e2e:	83 ec 04             	sub    $0x4,%esp
80109e31:	6a 30                	push   $0x30
80109e33:	52                   	push   %edx
80109e34:	50                   	push   %eax
80109e35:	e8 69 af ff ff       	call   80104da3 <memmove>
80109e3a:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109e3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e40:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109e46:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e49:	83 ec 0c             	sub    $0xc,%esp
80109e4c:	50                   	push   %eax
80109e4d:	e8 1c 00 00 00       	call   80109e6e <icmp_chksum>
80109e52:	83 c4 10             	add    $0x10,%esp
80109e55:	0f b7 c0             	movzwl %ax,%eax
80109e58:	83 ec 0c             	sub    $0xc,%esp
80109e5b:	50                   	push   %eax
80109e5c:	e8 b1 fb ff ff       	call   80109a12 <H2N_ushort>
80109e61:	83 c4 10             	add    $0x10,%esp
80109e64:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109e67:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109e6b:	90                   	nop
80109e6c:	c9                   	leave
80109e6d:	c3                   	ret

80109e6e <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109e6e:	f3 0f 1e fb          	endbr32
80109e72:	55                   	push   %ebp
80109e73:	89 e5                	mov    %esp,%ebp
80109e75:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109e78:	8b 45 08             	mov    0x8(%ebp),%eax
80109e7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109e7e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109e85:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109e8c:	eb 48                	jmp    80109ed6 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e8e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e91:	01 c0                	add    %eax,%eax
80109e93:	89 c2                	mov    %eax,%edx
80109e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e98:	01 d0                	add    %edx,%eax
80109e9a:	0f b6 00             	movzbl (%eax),%eax
80109e9d:	0f b6 c0             	movzbl %al,%eax
80109ea0:	c1 e0 08             	shl    $0x8,%eax
80109ea3:	89 c2                	mov    %eax,%edx
80109ea5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109ea8:	01 c0                	add    %eax,%eax
80109eaa:	8d 48 01             	lea    0x1(%eax),%ecx
80109ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109eb0:	01 c8                	add    %ecx,%eax
80109eb2:	0f b6 00             	movzbl (%eax),%eax
80109eb5:	0f b6 c0             	movzbl %al,%eax
80109eb8:	01 d0                	add    %edx,%eax
80109eba:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109ebd:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109ec4:	76 0c                	jbe    80109ed2 <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
80109ec6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ec9:	0f b7 c0             	movzwl %ax,%eax
80109ecc:	83 c0 01             	add    $0x1,%eax
80109ecf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109ed2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109ed6:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109eda:	7e b2                	jle    80109e8e <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
80109edc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109edf:	f7 d0                	not    %eax
}
80109ee1:	c9                   	leave
80109ee2:	c3                   	ret

80109ee3 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109ee3:	f3 0f 1e fb          	endbr32
80109ee7:	55                   	push   %ebp
80109ee8:	89 e5                	mov    %esp,%ebp
80109eea:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109eed:	8b 45 08             	mov    0x8(%ebp),%eax
80109ef0:	83 c0 0e             	add    $0xe,%eax
80109ef3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ef9:	0f b6 00             	movzbl (%eax),%eax
80109efc:	0f b6 c0             	movzbl %al,%eax
80109eff:	83 e0 0f             	and    $0xf,%eax
80109f02:	c1 e0 02             	shl    $0x2,%eax
80109f05:	89 c2                	mov    %eax,%edx
80109f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f0a:	01 d0                	add    %edx,%eax
80109f0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109f0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f12:	83 c0 14             	add    $0x14,%eax
80109f15:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109f18:	e8 85 89 ff ff       	call   801028a2 <kalloc>
80109f1d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109f20:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f2a:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f2e:	0f b6 c0             	movzbl %al,%eax
80109f31:	83 e0 02             	and    $0x2,%eax
80109f34:	85 c0                	test   %eax,%eax
80109f36:	74 3d                	je     80109f75 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109f38:	83 ec 0c             	sub    $0xc,%esp
80109f3b:	6a 00                	push   $0x0
80109f3d:	6a 12                	push   $0x12
80109f3f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f42:	50                   	push   %eax
80109f43:	ff 75 e8             	push   -0x18(%ebp)
80109f46:	ff 75 08             	push   0x8(%ebp)
80109f49:	e8 a2 01 00 00       	call   8010a0f0 <tcp_pkt_create>
80109f4e:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109f51:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f54:	83 ec 08             	sub    $0x8,%esp
80109f57:	50                   	push   %eax
80109f58:	ff 75 e8             	push   -0x18(%ebp)
80109f5b:	e8 ff f0 ff ff       	call   8010905f <i8254_send>
80109f60:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109f63:	a1 44 d3 18 80       	mov    0x8018d344,%eax
80109f68:	83 c0 01             	add    $0x1,%eax
80109f6b:	a3 44 d3 18 80       	mov    %eax,0x8018d344
80109f70:	e9 69 01 00 00       	jmp    8010a0de <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109f75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f78:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f7c:	3c 18                	cmp    $0x18,%al
80109f7e:	0f 85 10 01 00 00    	jne    8010a094 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
80109f84:	83 ec 04             	sub    $0x4,%esp
80109f87:	6a 03                	push   $0x3
80109f89:	68 be c6 10 80       	push   $0x8010c6be
80109f8e:	ff 75 ec             	push   -0x14(%ebp)
80109f91:	e8 b1 ad ff ff       	call   80104d47 <memcmp>
80109f96:	83 c4 10             	add    $0x10,%esp
80109f99:	85 c0                	test   %eax,%eax
80109f9b:	74 74                	je     8010a011 <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
80109f9d:	83 ec 0c             	sub    $0xc,%esp
80109fa0:	68 c2 c6 10 80       	push   $0x8010c6c2
80109fa5:	e8 62 64 ff ff       	call   8010040c <cprintf>
80109faa:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109fad:	83 ec 0c             	sub    $0xc,%esp
80109fb0:	6a 00                	push   $0x0
80109fb2:	6a 10                	push   $0x10
80109fb4:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109fb7:	50                   	push   %eax
80109fb8:	ff 75 e8             	push   -0x18(%ebp)
80109fbb:	ff 75 08             	push   0x8(%ebp)
80109fbe:	e8 2d 01 00 00       	call   8010a0f0 <tcp_pkt_create>
80109fc3:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109fc6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109fc9:	83 ec 08             	sub    $0x8,%esp
80109fcc:	50                   	push   %eax
80109fcd:	ff 75 e8             	push   -0x18(%ebp)
80109fd0:	e8 8a f0 ff ff       	call   8010905f <i8254_send>
80109fd5:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109fd8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fdb:	83 c0 36             	add    $0x36,%eax
80109fde:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109fe1:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109fe4:	50                   	push   %eax
80109fe5:	ff 75 e0             	push   -0x20(%ebp)
80109fe8:	6a 00                	push   $0x0
80109fea:	6a 00                	push   $0x0
80109fec:	e8 66 04 00 00       	call   8010a457 <http_proc>
80109ff1:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109ff4:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109ff7:	83 ec 0c             	sub    $0xc,%esp
80109ffa:	50                   	push   %eax
80109ffb:	6a 18                	push   $0x18
80109ffd:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a000:	50                   	push   %eax
8010a001:	ff 75 e8             	push   -0x18(%ebp)
8010a004:	ff 75 08             	push   0x8(%ebp)
8010a007:	e8 e4 00 00 00       	call   8010a0f0 <tcp_pkt_create>
8010a00c:	83 c4 20             	add    $0x20,%esp
8010a00f:	eb 62                	jmp    8010a073 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a011:	83 ec 0c             	sub    $0xc,%esp
8010a014:	6a 00                	push   $0x0
8010a016:	6a 10                	push   $0x10
8010a018:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a01b:	50                   	push   %eax
8010a01c:	ff 75 e8             	push   -0x18(%ebp)
8010a01f:	ff 75 08             	push   0x8(%ebp)
8010a022:	e8 c9 00 00 00       	call   8010a0f0 <tcp_pkt_create>
8010a027:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a02a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a02d:	83 ec 08             	sub    $0x8,%esp
8010a030:	50                   	push   %eax
8010a031:	ff 75 e8             	push   -0x18(%ebp)
8010a034:	e8 26 f0 ff ff       	call   8010905f <i8254_send>
8010a039:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a03c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a03f:	83 c0 36             	add    $0x36,%eax
8010a042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a045:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a048:	50                   	push   %eax
8010a049:	ff 75 e4             	push   -0x1c(%ebp)
8010a04c:	6a 00                	push   $0x0
8010a04e:	6a 00                	push   $0x0
8010a050:	e8 02 04 00 00       	call   8010a457 <http_proc>
8010a055:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a058:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a05b:	83 ec 0c             	sub    $0xc,%esp
8010a05e:	50                   	push   %eax
8010a05f:	6a 18                	push   $0x18
8010a061:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a064:	50                   	push   %eax
8010a065:	ff 75 e8             	push   -0x18(%ebp)
8010a068:	ff 75 08             	push   0x8(%ebp)
8010a06b:	e8 80 00 00 00       	call   8010a0f0 <tcp_pkt_create>
8010a070:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a073:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a076:	83 ec 08             	sub    $0x8,%esp
8010a079:	50                   	push   %eax
8010a07a:	ff 75 e8             	push   -0x18(%ebp)
8010a07d:	e8 dd ef ff ff       	call   8010905f <i8254_send>
8010a082:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a085:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a08a:	83 c0 01             	add    $0x1,%eax
8010a08d:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a092:	eb 4a                	jmp    8010a0de <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a094:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a097:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a09b:	3c 10                	cmp    $0x10,%al
8010a09d:	75 3f                	jne    8010a0de <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a09f:	a1 48 d3 18 80       	mov    0x8018d348,%eax
8010a0a4:	83 f8 01             	cmp    $0x1,%eax
8010a0a7:	75 35                	jne    8010a0de <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a0a9:	83 ec 0c             	sub    $0xc,%esp
8010a0ac:	6a 00                	push   $0x0
8010a0ae:	6a 01                	push   $0x1
8010a0b0:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a0b3:	50                   	push   %eax
8010a0b4:	ff 75 e8             	push   -0x18(%ebp)
8010a0b7:	ff 75 08             	push   0x8(%ebp)
8010a0ba:	e8 31 00 00 00       	call   8010a0f0 <tcp_pkt_create>
8010a0bf:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a0c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a0c5:	83 ec 08             	sub    $0x8,%esp
8010a0c8:	50                   	push   %eax
8010a0c9:	ff 75 e8             	push   -0x18(%ebp)
8010a0cc:	e8 8e ef ff ff       	call   8010905f <i8254_send>
8010a0d1:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a0d4:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
8010a0db:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a0de:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0e1:	83 ec 0c             	sub    $0xc,%esp
8010a0e4:	50                   	push   %eax
8010a0e5:	e8 1a 87 ff ff       	call   80102804 <kfree>
8010a0ea:	83 c4 10             	add    $0x10,%esp
}
8010a0ed:	90                   	nop
8010a0ee:	c9                   	leave
8010a0ef:	c3                   	ret

8010a0f0 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a0f0:	f3 0f 1e fb          	endbr32
8010a0f4:	55                   	push   %ebp
8010a0f5:	89 e5                	mov    %esp,%ebp
8010a0f7:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a0fa:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a100:	8b 45 08             	mov    0x8(%ebp),%eax
8010a103:	83 c0 0e             	add    $0xe,%eax
8010a106:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a109:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a10c:	0f b6 00             	movzbl (%eax),%eax
8010a10f:	0f b6 c0             	movzbl %al,%eax
8010a112:	83 e0 0f             	and    $0xf,%eax
8010a115:	c1 e0 02             	shl    $0x2,%eax
8010a118:	89 c2                	mov    %eax,%edx
8010a11a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a11d:	01 d0                	add    %edx,%eax
8010a11f:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a122:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a125:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a128:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a12b:	83 c0 0e             	add    $0xe,%eax
8010a12e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a131:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a134:	83 c0 14             	add    $0x14,%eax
8010a137:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a13a:	8b 45 18             	mov    0x18(%ebp),%eax
8010a13d:	8d 50 36             	lea    0x36(%eax),%edx
8010a140:	8b 45 10             	mov    0x10(%ebp),%eax
8010a143:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a145:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a148:	8d 50 06             	lea    0x6(%eax),%edx
8010a14b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a14e:	83 ec 04             	sub    $0x4,%esp
8010a151:	6a 06                	push   $0x6
8010a153:	52                   	push   %edx
8010a154:	50                   	push   %eax
8010a155:	e8 49 ac ff ff       	call   80104da3 <memmove>
8010a15a:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a15d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a160:	83 c0 06             	add    $0x6,%eax
8010a163:	83 ec 04             	sub    $0x4,%esp
8010a166:	6a 06                	push   $0x6
8010a168:	68 68 d0 18 80       	push   $0x8018d068
8010a16d:	50                   	push   %eax
8010a16e:	e8 30 ac ff ff       	call   80104da3 <memmove>
8010a173:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a176:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a179:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a17d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a180:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a184:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a187:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a18a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a18d:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a191:	8b 45 18             	mov    0x18(%ebp),%eax
8010a194:	83 c0 28             	add    $0x28,%eax
8010a197:	0f b7 c0             	movzwl %ax,%eax
8010a19a:	83 ec 0c             	sub    $0xc,%esp
8010a19d:	50                   	push   %eax
8010a19e:	e8 6f f8 ff ff       	call   80109a12 <H2N_ushort>
8010a1a3:	83 c4 10             	add    $0x10,%esp
8010a1a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a1a9:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a1ad:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a1b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1b7:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a1bb:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a1c2:	83 c0 01             	add    $0x1,%eax
8010a1c5:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a1cb:	83 ec 0c             	sub    $0xc,%esp
8010a1ce:	6a 00                	push   $0x0
8010a1d0:	e8 3d f8 ff ff       	call   80109a12 <H2N_ushort>
8010a1d5:	83 c4 10             	add    $0x10,%esp
8010a1d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a1db:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a1df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1e2:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a1e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1e9:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a1ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1f0:	83 c0 0c             	add    $0xc,%eax
8010a1f3:	83 ec 04             	sub    $0x4,%esp
8010a1f6:	6a 04                	push   $0x4
8010a1f8:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a1fd:	50                   	push   %eax
8010a1fe:	e8 a0 ab ff ff       	call   80104da3 <memmove>
8010a203:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a206:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a209:	8d 50 0c             	lea    0xc(%eax),%edx
8010a20c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a20f:	83 c0 10             	add    $0x10,%eax
8010a212:	83 ec 04             	sub    $0x4,%esp
8010a215:	6a 04                	push   $0x4
8010a217:	52                   	push   %edx
8010a218:	50                   	push   %eax
8010a219:	e8 85 ab ff ff       	call   80104da3 <memmove>
8010a21e:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a221:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a224:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a22a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a22d:	83 ec 0c             	sub    $0xc,%esp
8010a230:	50                   	push   %eax
8010a231:	e8 ec f8 ff ff       	call   80109b22 <ipv4_chksum>
8010a236:	83 c4 10             	add    $0x10,%esp
8010a239:	0f b7 c0             	movzwl %ax,%eax
8010a23c:	83 ec 0c             	sub    $0xc,%esp
8010a23f:	50                   	push   %eax
8010a240:	e8 cd f7 ff ff       	call   80109a12 <H2N_ushort>
8010a245:	83 c4 10             	add    $0x10,%esp
8010a248:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a24b:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a24f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a252:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a256:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a259:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a25c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a25f:	0f b7 10             	movzwl (%eax),%edx
8010a262:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a265:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a269:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a26e:	83 ec 0c             	sub    $0xc,%esp
8010a271:	50                   	push   %eax
8010a272:	e8 c1 f7 ff ff       	call   80109a38 <H2N_uint>
8010a277:	83 c4 10             	add    $0x10,%esp
8010a27a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a27d:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a280:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a283:	8b 40 04             	mov    0x4(%eax),%eax
8010a286:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a28c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a28f:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a292:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a295:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a299:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a29c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a2a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2a3:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a2a7:	8b 45 14             	mov    0x14(%ebp),%eax
8010a2aa:	89 c2                	mov    %eax,%edx
8010a2ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2af:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a2b2:	83 ec 0c             	sub    $0xc,%esp
8010a2b5:	68 90 38 00 00       	push   $0x3890
8010a2ba:	e8 53 f7 ff ff       	call   80109a12 <H2N_ushort>
8010a2bf:	83 c4 10             	add    $0x10,%esp
8010a2c2:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a2c5:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a2c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2cc:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a2d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2d5:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a2db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2de:	83 ec 0c             	sub    $0xc,%esp
8010a2e1:	50                   	push   %eax
8010a2e2:	e8 1f 00 00 00       	call   8010a306 <tcp_chksum>
8010a2e7:	83 c4 10             	add    $0x10,%esp
8010a2ea:	83 c0 08             	add    $0x8,%eax
8010a2ed:	0f b7 c0             	movzwl %ax,%eax
8010a2f0:	83 ec 0c             	sub    $0xc,%esp
8010a2f3:	50                   	push   %eax
8010a2f4:	e8 19 f7 ff ff       	call   80109a12 <H2N_ushort>
8010a2f9:	83 c4 10             	add    $0x10,%esp
8010a2fc:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a2ff:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a303:	90                   	nop
8010a304:	c9                   	leave
8010a305:	c3                   	ret

8010a306 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a306:	f3 0f 1e fb          	endbr32
8010a30a:	55                   	push   %ebp
8010a30b:	89 e5                	mov    %esp,%ebp
8010a30d:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a310:	8b 45 08             	mov    0x8(%ebp),%eax
8010a313:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a316:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a319:	83 c0 14             	add    $0x14,%eax
8010a31c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a31f:	83 ec 04             	sub    $0x4,%esp
8010a322:	6a 04                	push   $0x4
8010a324:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a329:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a32c:	50                   	push   %eax
8010a32d:	e8 71 aa ff ff       	call   80104da3 <memmove>
8010a332:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a335:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a338:	83 c0 0c             	add    $0xc,%eax
8010a33b:	83 ec 04             	sub    $0x4,%esp
8010a33e:	6a 04                	push   $0x4
8010a340:	50                   	push   %eax
8010a341:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a344:	83 c0 04             	add    $0x4,%eax
8010a347:	50                   	push   %eax
8010a348:	e8 56 aa ff ff       	call   80104da3 <memmove>
8010a34d:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a350:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a354:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a358:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a35b:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a35f:	0f b7 c0             	movzwl %ax,%eax
8010a362:	83 ec 0c             	sub    $0xc,%esp
8010a365:	50                   	push   %eax
8010a366:	e8 81 f6 ff ff       	call   801099ec <N2H_ushort>
8010a36b:	83 c4 10             	add    $0x10,%esp
8010a36e:	83 e8 14             	sub    $0x14,%eax
8010a371:	0f b7 c0             	movzwl %ax,%eax
8010a374:	83 ec 0c             	sub    $0xc,%esp
8010a377:	50                   	push   %eax
8010a378:	e8 95 f6 ff ff       	call   80109a12 <H2N_ushort>
8010a37d:	83 c4 10             	add    $0x10,%esp
8010a380:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a384:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a38b:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a38e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a391:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a398:	eb 33                	jmp    8010a3cd <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a39a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a39d:	01 c0                	add    %eax,%eax
8010a39f:	89 c2                	mov    %eax,%edx
8010a3a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3a4:	01 d0                	add    %edx,%eax
8010a3a6:	0f b6 00             	movzbl (%eax),%eax
8010a3a9:	0f b6 c0             	movzbl %al,%eax
8010a3ac:	c1 e0 08             	shl    $0x8,%eax
8010a3af:	89 c2                	mov    %eax,%edx
8010a3b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3b4:	01 c0                	add    %eax,%eax
8010a3b6:	8d 48 01             	lea    0x1(%eax),%ecx
8010a3b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3bc:	01 c8                	add    %ecx,%eax
8010a3be:	0f b6 00             	movzbl (%eax),%eax
8010a3c1:	0f b6 c0             	movzbl %al,%eax
8010a3c4:	01 d0                	add    %edx,%eax
8010a3c6:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a3c9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a3cd:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a3d1:	7e c7                	jle    8010a39a <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a3d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a3d9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a3e0:	eb 33                	jmp    8010a415 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a3e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3e5:	01 c0                	add    %eax,%eax
8010a3e7:	89 c2                	mov    %eax,%edx
8010a3e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3ec:	01 d0                	add    %edx,%eax
8010a3ee:	0f b6 00             	movzbl (%eax),%eax
8010a3f1:	0f b6 c0             	movzbl %al,%eax
8010a3f4:	c1 e0 08             	shl    $0x8,%eax
8010a3f7:	89 c2                	mov    %eax,%edx
8010a3f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3fc:	01 c0                	add    %eax,%eax
8010a3fe:	8d 48 01             	lea    0x1(%eax),%ecx
8010a401:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a404:	01 c8                	add    %ecx,%eax
8010a406:	0f b6 00             	movzbl (%eax),%eax
8010a409:	0f b6 c0             	movzbl %al,%eax
8010a40c:	01 d0                	add    %edx,%eax
8010a40e:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a411:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a415:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a419:	0f b7 c0             	movzwl %ax,%eax
8010a41c:	83 ec 0c             	sub    $0xc,%esp
8010a41f:	50                   	push   %eax
8010a420:	e8 c7 f5 ff ff       	call   801099ec <N2H_ushort>
8010a425:	83 c4 10             	add    $0x10,%esp
8010a428:	66 d1 e8             	shr    $1,%ax
8010a42b:	0f b7 c0             	movzwl %ax,%eax
8010a42e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a431:	7c af                	jl     8010a3e2 <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a433:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a436:	c1 e8 10             	shr    $0x10,%eax
8010a439:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a43c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a43f:	f7 d0                	not    %eax
}
8010a441:	c9                   	leave
8010a442:	c3                   	ret

8010a443 <tcp_fin>:

void tcp_fin(){
8010a443:	f3 0f 1e fb          	endbr32
8010a447:	55                   	push   %ebp
8010a448:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a44a:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a451:	00 00 00 
}
8010a454:	90                   	nop
8010a455:	5d                   	pop    %ebp
8010a456:	c3                   	ret

8010a457 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a457:	f3 0f 1e fb          	endbr32
8010a45b:	55                   	push   %ebp
8010a45c:	89 e5                	mov    %esp,%ebp
8010a45e:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a461:	8b 45 10             	mov    0x10(%ebp),%eax
8010a464:	83 ec 04             	sub    $0x4,%esp
8010a467:	6a 00                	push   $0x0
8010a469:	68 cb c6 10 80       	push   $0x8010c6cb
8010a46e:	50                   	push   %eax
8010a46f:	e8 65 00 00 00       	call   8010a4d9 <http_strcpy>
8010a474:	83 c4 10             	add    $0x10,%esp
8010a477:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a47a:	8b 45 10             	mov    0x10(%ebp),%eax
8010a47d:	83 ec 04             	sub    $0x4,%esp
8010a480:	ff 75 f4             	push   -0xc(%ebp)
8010a483:	68 de c6 10 80       	push   $0x8010c6de
8010a488:	50                   	push   %eax
8010a489:	e8 4b 00 00 00       	call   8010a4d9 <http_strcpy>
8010a48e:	83 c4 10             	add    $0x10,%esp
8010a491:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a494:	8b 45 10             	mov    0x10(%ebp),%eax
8010a497:	83 ec 04             	sub    $0x4,%esp
8010a49a:	ff 75 f4             	push   -0xc(%ebp)
8010a49d:	68 f9 c6 10 80       	push   $0x8010c6f9
8010a4a2:	50                   	push   %eax
8010a4a3:	e8 31 00 00 00       	call   8010a4d9 <http_strcpy>
8010a4a8:	83 c4 10             	add    $0x10,%esp
8010a4ab:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a4ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4b1:	83 e0 01             	and    $0x1,%eax
8010a4b4:	85 c0                	test   %eax,%eax
8010a4b6:	74 11                	je     8010a4c9 <http_proc+0x72>
    char *payload = (char *)send;
8010a4b8:	8b 45 10             	mov    0x10(%ebp),%eax
8010a4bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a4be:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a4c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4c4:	01 d0                	add    %edx,%eax
8010a4c6:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a4c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a4cc:	8b 45 14             	mov    0x14(%ebp),%eax
8010a4cf:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a4d1:	e8 6d ff ff ff       	call   8010a443 <tcp_fin>
}
8010a4d6:	90                   	nop
8010a4d7:	c9                   	leave
8010a4d8:	c3                   	ret

8010a4d9 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a4d9:	f3 0f 1e fb          	endbr32
8010a4dd:	55                   	push   %ebp
8010a4de:	89 e5                	mov    %esp,%ebp
8010a4e0:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a4e3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a4ea:	eb 20                	jmp    8010a50c <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a4ec:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a4ef:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a4f2:	01 d0                	add    %edx,%eax
8010a4f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a4f7:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a4fa:	01 ca                	add    %ecx,%edx
8010a4fc:	89 d1                	mov    %edx,%ecx
8010a4fe:	8b 55 08             	mov    0x8(%ebp),%edx
8010a501:	01 ca                	add    %ecx,%edx
8010a503:	0f b6 00             	movzbl (%eax),%eax
8010a506:	88 02                	mov    %al,(%edx)
    i++;
8010a508:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a50c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a50f:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a512:	01 d0                	add    %edx,%eax
8010a514:	0f b6 00             	movzbl (%eax),%eax
8010a517:	84 c0                	test   %al,%al
8010a519:	75 d1                	jne    8010a4ec <http_strcpy+0x13>
  }
  return i;
8010a51b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a51e:	c9                   	leave
8010a51f:	c3                   	ret

8010a520 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a520:	f3 0f 1e fb          	endbr32
8010a524:	55                   	push   %ebp
8010a525:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a527:	c7 05 50 d3 18 80 a2 	movl   $0x8010f5a2,0x8018d350
8010a52e:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a531:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a536:	c1 e8 09             	shr    $0x9,%eax
8010a539:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a53e:	90                   	nop
8010a53f:	5d                   	pop    %ebp
8010a540:	c3                   	ret

8010a541 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a541:	f3 0f 1e fb          	endbr32
8010a545:	55                   	push   %ebp
8010a546:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a548:	90                   	nop
8010a549:	5d                   	pop    %ebp
8010a54a:	c3                   	ret

8010a54b <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a54b:	f3 0f 1e fb          	endbr32
8010a54f:	55                   	push   %ebp
8010a550:	89 e5                	mov    %esp,%ebp
8010a552:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a555:	8b 45 08             	mov    0x8(%ebp),%eax
8010a558:	83 c0 0c             	add    $0xc,%eax
8010a55b:	83 ec 0c             	sub    $0xc,%esp
8010a55e:	50                   	push   %eax
8010a55f:	e8 50 a4 ff ff       	call   801049b4 <holdingsleep>
8010a564:	83 c4 10             	add    $0x10,%esp
8010a567:	85 c0                	test   %eax,%eax
8010a569:	75 0d                	jne    8010a578 <iderw+0x2d>
    panic("iderw: buf not locked");
8010a56b:	83 ec 0c             	sub    $0xc,%esp
8010a56e:	68 0a c7 10 80       	push   $0x8010c70a
8010a573:	e8 66 60 ff ff       	call   801005de <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a578:	8b 45 08             	mov    0x8(%ebp),%eax
8010a57b:	8b 00                	mov    (%eax),%eax
8010a57d:	83 e0 06             	and    $0x6,%eax
8010a580:	83 f8 02             	cmp    $0x2,%eax
8010a583:	75 0d                	jne    8010a592 <iderw+0x47>
    panic("iderw: nothing to do");
8010a585:	83 ec 0c             	sub    $0xc,%esp
8010a588:	68 20 c7 10 80       	push   $0x8010c720
8010a58d:	e8 4c 60 ff ff       	call   801005de <panic>
  if(b->dev != 1)
8010a592:	8b 45 08             	mov    0x8(%ebp),%eax
8010a595:	8b 40 04             	mov    0x4(%eax),%eax
8010a598:	83 f8 01             	cmp    $0x1,%eax
8010a59b:	74 0d                	je     8010a5aa <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a59d:	83 ec 0c             	sub    $0xc,%esp
8010a5a0:	68 35 c7 10 80       	push   $0x8010c735
8010a5a5:	e8 34 60 ff ff       	call   801005de <panic>
  if(b->blockno >= disksize)
8010a5aa:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5ad:	8b 40 08             	mov    0x8(%eax),%eax
8010a5b0:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a5b6:	39 d0                	cmp    %edx,%eax
8010a5b8:	72 0d                	jb     8010a5c7 <iderw+0x7c>
    panic("iderw: block out of range");
8010a5ba:	83 ec 0c             	sub    $0xc,%esp
8010a5bd:	68 53 c7 10 80       	push   $0x8010c753
8010a5c2:	e8 17 60 ff ff       	call   801005de <panic>

  p = memdisk + b->blockno*BSIZE;
8010a5c7:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a5cd:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5d0:	8b 40 08             	mov    0x8(%eax),%eax
8010a5d3:	c1 e0 09             	shl    $0x9,%eax
8010a5d6:	01 d0                	add    %edx,%eax
8010a5d8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a5db:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5de:	8b 00                	mov    (%eax),%eax
8010a5e0:	83 e0 04             	and    $0x4,%eax
8010a5e3:	85 c0                	test   %eax,%eax
8010a5e5:	74 2b                	je     8010a612 <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a5e7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5ea:	8b 00                	mov    (%eax),%eax
8010a5ec:	83 e0 fb             	and    $0xfffffffb,%eax
8010a5ef:	89 c2                	mov    %eax,%edx
8010a5f1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5f4:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a5f6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5f9:	83 c0 5c             	add    $0x5c,%eax
8010a5fc:	83 ec 04             	sub    $0x4,%esp
8010a5ff:	68 00 02 00 00       	push   $0x200
8010a604:	50                   	push   %eax
8010a605:	ff 75 f4             	push   -0xc(%ebp)
8010a608:	e8 96 a7 ff ff       	call   80104da3 <memmove>
8010a60d:	83 c4 10             	add    $0x10,%esp
8010a610:	eb 1a                	jmp    8010a62c <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a612:	8b 45 08             	mov    0x8(%ebp),%eax
8010a615:	83 c0 5c             	add    $0x5c,%eax
8010a618:	83 ec 04             	sub    $0x4,%esp
8010a61b:	68 00 02 00 00       	push   $0x200
8010a620:	ff 75 f4             	push   -0xc(%ebp)
8010a623:	50                   	push   %eax
8010a624:	e8 7a a7 ff ff       	call   80104da3 <memmove>
8010a629:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a62c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a62f:	8b 00                	mov    (%eax),%eax
8010a631:	83 c8 02             	or     $0x2,%eax
8010a634:	89 c2                	mov    %eax,%edx
8010a636:	8b 45 08             	mov    0x8(%ebp),%eax
8010a639:	89 10                	mov    %edx,(%eax)
}
8010a63b:	90                   	nop
8010a63c:	c9                   	leave
8010a63d:	c3                   	ret
