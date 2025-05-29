
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
8010005f:	ba eb 34 10 80       	mov    $0x801034eb,%edx
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
8010007d:	e8 1b 4a 00 00       	call   80104a9d <initlock>
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
801000c7:	e8 64 48 00 00       	call   80104930 <initsleeplock>
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
80100109:	e8 b5 49 00 00       	call   80104ac3 <acquire>
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
80100148:	e8 e8 49 00 00       	call   80104b35 <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 11 48 00 00       	call   80104970 <acquiresleep>
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
801001c9:	e8 67 49 00 00       	call   80104b35 <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 90 47 00 00       	call   80104970 <acquiresleep>
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
80100202:	e8 be 03 00 00       	call   801005c5 <panic>
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
80100239:	e8 14 a3 00 00       	call   8010a552 <iderw>
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
8010025a:	e8 cb 47 00 00       	call   80104a2a <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 7f a6 10 80       	push   $0x8010a67f
8010026e:	e8 52 03 00 00       	call   801005c5 <panic>
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
80100288:	e8 c5 a2 00 00       	call   8010a552 <iderw>
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
801002a7:	e8 7e 47 00 00       	call   80104a2a <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 86 a6 10 80       	push   $0x8010a686
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 09 47 00 00       	call   801049d8 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 e4 47 00 00       	call   80104ac3 <acquire>
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
8010034a:	e8 e6 47 00 00       	call   80104b35 <release>
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
801003f6:	e8 9a 03 00 00       	call   80100795 <consputc>
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
8010042c:	e8 92 46 00 00       	call   80104ac3 <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 8d a6 10 80       	push   $0x8010a68d
80100443:	e8 7d 01 00 00       	call   801005c5 <panic>


  argp = (uint*)(void*)(&fmt + 1);
80100448:	8d 45 0c             	lea    0xc(%ebp),%eax
8010044b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010044e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100455:	e9 2f 01 00 00       	jmp    80100589 <cprintf+0x17d>
    if(c != '%'){
8010045a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010045e:	74 13                	je     80100473 <cprintf+0x67>
      consputc(c);
80100460:	83 ec 0c             	sub    $0xc,%esp
80100463:	ff 75 e4             	push   -0x1c(%ebp)
80100466:	e8 2a 03 00 00       	call   80100795 <consputc>
8010046b:	83 c4 10             	add    $0x10,%esp
      continue;
8010046e:	e9 12 01 00 00       	jmp    80100585 <cprintf+0x179>
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
80100491:	0f 84 14 01 00 00    	je     801005ab <cprintf+0x19f>
      break;
    switch(c){
80100497:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010049b:	74 5e                	je     801004fb <cprintf+0xef>
8010049d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
801004a1:	0f 8f c2 00 00 00    	jg     80100569 <cprintf+0x15d>
801004a7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004ab:	74 6b                	je     80100518 <cprintf+0x10c>
801004ad:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004b1:	0f 8f b2 00 00 00    	jg     80100569 <cprintf+0x15d>
801004b7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004bb:	74 3e                	je     801004fb <cprintf+0xef>
801004bd:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004c1:	0f 8f a2 00 00 00    	jg     80100569 <cprintf+0x15d>
801004c7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004cb:	0f 84 89 00 00 00    	je     8010055a <cprintf+0x14e>
801004d1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004d5:	0f 85 8e 00 00 00    	jne    80100569 <cprintf+0x15d>
    case 'd':
      printint(*argp++, 10, 1);
801004db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004de:	8d 50 04             	lea    0x4(%eax),%edx
801004e1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e4:	8b 00                	mov    (%eax),%eax
801004e6:	83 ec 04             	sub    $0x4,%esp
801004e9:	6a 01                	push   $0x1
801004eb:	6a 0a                	push   $0xa
801004ed:	50                   	push   %eax
801004ee:	e8 69 fe ff ff       	call   8010035c <printint>
801004f3:	83 c4 10             	add    $0x10,%esp
      break;
801004f6:	e9 8a 00 00 00       	jmp    80100585 <cprintf+0x179>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004fe:	8d 50 04             	lea    0x4(%eax),%edx
80100501:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100504:	8b 00                	mov    (%eax),%eax
80100506:	83 ec 04             	sub    $0x4,%esp
80100509:	6a 00                	push   $0x0
8010050b:	6a 10                	push   $0x10
8010050d:	50                   	push   %eax
8010050e:	e8 49 fe ff ff       	call   8010035c <printint>
80100513:	83 c4 10             	add    $0x10,%esp
      break;
80100516:	eb 6d                	jmp    80100585 <cprintf+0x179>
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
8010052c:	c7 45 ec 96 a6 10 80 	movl   $0x8010a696,-0x14(%ebp)
      for(; *s; s++)
80100533:	eb 19                	jmp    8010054e <cprintf+0x142>
        consputc(*s);
80100535:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100538:	0f b6 00             	movzbl (%eax),%eax
8010053b:	0f be c0             	movsbl %al,%eax
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	50                   	push   %eax
80100542:	e8 4e 02 00 00       	call   80100795 <consputc>
80100547:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010054a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010054e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100551:	0f b6 00             	movzbl (%eax),%eax
80100554:	84 c0                	test   %al,%al
80100556:	75 dd                	jne    80100535 <cprintf+0x129>
      break;
80100558:	eb 2b                	jmp    80100585 <cprintf+0x179>
    case '%':
      consputc('%');
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	6a 25                	push   $0x25
8010055f:	e8 31 02 00 00       	call   80100795 <consputc>
80100564:	83 c4 10             	add    $0x10,%esp
      break;
80100567:	eb 1c                	jmp    80100585 <cprintf+0x179>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100569:	83 ec 0c             	sub    $0xc,%esp
8010056c:	6a 25                	push   $0x25
8010056e:	e8 22 02 00 00       	call   80100795 <consputc>
80100573:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100576:	83 ec 0c             	sub    $0xc,%esp
80100579:	ff 75 e4             	push   -0x1c(%ebp)
8010057c:	e8 14 02 00 00       	call   80100795 <consputc>
80100581:	83 c4 10             	add    $0x10,%esp
      break;
80100584:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100585:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100589:	8b 55 08             	mov    0x8(%ebp),%edx
8010058c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010058f:	01 d0                	add    %edx,%eax
80100591:	0f b6 00             	movzbl (%eax),%eax
80100594:	0f be c0             	movsbl %al,%eax
80100597:	25 ff 00 00 00       	and    $0xff,%eax
8010059c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010059f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005a3:	0f 85 b1 fe ff ff    	jne    8010045a <cprintf+0x4e>
801005a9:	eb 01                	jmp    801005ac <cprintf+0x1a0>
      break;
801005ab:	90                   	nop
    }
  }

  if(locking)
801005ac:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005b0:	74 10                	je     801005c2 <cprintf+0x1b6>
    release(&cons.lock);
801005b2:	83 ec 0c             	sub    $0xc,%esp
801005b5:	68 20 d0 18 80       	push   $0x8018d020
801005ba:	e8 76 45 00 00       	call   80104b35 <release>
801005bf:	83 c4 10             	add    $0x10,%esp
}
801005c2:	90                   	nop
801005c3:	c9                   	leave
801005c4:	c3                   	ret

801005c5 <panic>:

void
panic(char *s)
{
801005c5:	f3 0f 1e fb          	endbr32
801005c9:	55                   	push   %ebp
801005ca:	89 e5                	mov    %esp,%ebp
801005cc:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005cf:	e8 81 fd ff ff       	call   80100355 <cli>
  cons.locking = 0;
801005d4:	c7 05 54 d0 18 80 00 	movl   $0x0,0x8018d054
801005db:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005de:	e8 59 26 00 00       	call   80102c3c <lapicid>
801005e3:	83 ec 08             	sub    $0x8,%esp
801005e6:	50                   	push   %eax
801005e7:	68 9d a6 10 80       	push   $0x8010a69d
801005ec:	e8 1b fe ff ff       	call   8010040c <cprintf>
801005f1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005f4:	8b 45 08             	mov    0x8(%ebp),%eax
801005f7:	83 ec 0c             	sub    $0xc,%esp
801005fa:	50                   	push   %eax
801005fb:	e8 0c fe ff ff       	call   8010040c <cprintf>
80100600:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80100603:	83 ec 0c             	sub    $0xc,%esp
80100606:	68 b1 a6 10 80       	push   $0x8010a6b1
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 68 45 00 00       	call   80104b8b <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 b3 a6 10 80       	push   $0x8010a6b3
8010063f:	e8 c8 fd ff ff       	call   8010040c <cprintf>
80100644:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100647:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010064b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010064f:	7e de                	jle    8010062f <panic+0x6a>
  panicked = 1; // freeze other CPU
80100651:	c7 05 00 d0 18 80 01 	movl   $0x1,0x8018d000
80100658:	00 00 00 
  for(;;)
8010065b:	eb fe                	jmp    8010065b <panic+0x96>

8010065d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010065d:	f3 0f 1e fb          	endbr32
80100661:	55                   	push   %ebp
80100662:	89 e5                	mov    %esp,%ebp
80100664:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100667:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010066b:	75 64                	jne    801006d1 <graphic_putc+0x74>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
8010066d:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100673:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100678:	89 c8                	mov    %ecx,%eax
8010067a:	f7 ea                	imul   %edx
8010067c:	c1 fa 04             	sar    $0x4,%edx
8010067f:	89 c8                	mov    %ecx,%eax
80100681:	c1 f8 1f             	sar    $0x1f,%eax
80100684:	29 c2                	sub    %eax,%edx
80100686:	89 d0                	mov    %edx,%eax
80100688:	6b c0 35             	imul   $0x35,%eax,%eax
8010068b:	29 c1                	sub    %eax,%ecx
8010068d:	89 c8                	mov    %ecx,%eax
8010068f:	ba 35 00 00 00       	mov    $0x35,%edx
80100694:	29 c2                	sub    %eax,%edx
80100696:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010069b:	01 d0                	add    %edx,%eax
8010069d:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006a2:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006a7:	3d 23 04 00 00       	cmp    $0x423,%eax
801006ac:	0f 8e e0 00 00 00    	jle    80100792 <graphic_putc+0x135>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006b2:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006b7:	83 e8 35             	sub    $0x35,%eax
801006ba:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006bf:	83 ec 0c             	sub    $0xc,%esp
801006c2:	6a 1e                	push   $0x1e
801006c4:	e8 1d 7d 00 00       	call   801083e6 <graphic_scroll_up>
801006c9:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006cc:	e9 c1 00 00 00       	jmp    80100792 <graphic_putc+0x135>
  }else if(c == BACKSPACE){
801006d1:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006d8:	75 1f                	jne    801006f9 <graphic_putc+0x9c>
    if(console_pos>0) --console_pos;
801006da:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006df:	85 c0                	test   %eax,%eax
801006e1:	0f 8e ab 00 00 00    	jle    80100792 <graphic_putc+0x135>
801006e7:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006ec:	83 e8 01             	sub    $0x1,%eax
801006ef:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006f4:	e9 99 00 00 00       	jmp    80100792 <graphic_putc+0x135>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006f9:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006fe:	3d 23 04 00 00       	cmp    $0x423,%eax
80100703:	7e 1a                	jle    8010071f <graphic_putc+0xc2>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
80100705:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010070a:	83 e8 35             	sub    $0x35,%eax
8010070d:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
80100712:	83 ec 0c             	sub    $0xc,%esp
80100715:	6a 1e                	push   $0x1e
80100717:	e8 ca 7c 00 00       	call   801083e6 <graphic_scroll_up>
8010071c:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
8010071f:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100725:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010072a:	89 c8                	mov    %ecx,%eax
8010072c:	f7 ea                	imul   %edx
8010072e:	c1 fa 04             	sar    $0x4,%edx
80100731:	89 c8                	mov    %ecx,%eax
80100733:	c1 f8 1f             	sar    $0x1f,%eax
80100736:	29 c2                	sub    %eax,%edx
80100738:	89 d0                	mov    %edx,%eax
8010073a:	6b c0 35             	imul   $0x35,%eax,%eax
8010073d:	29 c1                	sub    %eax,%ecx
8010073f:	89 c8                	mov    %ecx,%eax
80100741:	89 c2                	mov    %eax,%edx
80100743:	c1 e2 04             	shl    $0x4,%edx
80100746:	29 c2                	sub    %eax,%edx
80100748:	89 d0                	mov    %edx,%eax
8010074a:	83 c0 02             	add    $0x2,%eax
8010074d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
80100750:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100756:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010075b:	89 c8                	mov    %ecx,%eax
8010075d:	f7 ea                	imul   %edx
8010075f:	c1 fa 04             	sar    $0x4,%edx
80100762:	89 c8                	mov    %ecx,%eax
80100764:	c1 f8 1f             	sar    $0x1f,%eax
80100767:	29 c2                	sub    %eax,%edx
80100769:	89 d0                	mov    %edx,%eax
8010076b:	6b c0 1e             	imul   $0x1e,%eax,%eax
8010076e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
80100771:	83 ec 04             	sub    $0x4,%esp
80100774:	ff 75 08             	push   0x8(%ebp)
80100777:	ff 75 f0             	push   -0x10(%ebp)
8010077a:	ff 75 f4             	push   -0xc(%ebp)
8010077d:	e8 d8 7c 00 00       	call   8010845a <font_render>
80100782:	83 c4 10             	add    $0x10,%esp
    console_pos++;
80100785:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010078a:	83 c0 01             	add    $0x1,%eax
8010078d:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
80100792:	90                   	nop
80100793:	c9                   	leave
80100794:	c3                   	ret

80100795 <consputc>:


void
consputc(int c)
{
80100795:	f3 0f 1e fb          	endbr32
80100799:	55                   	push   %ebp
8010079a:	89 e5                	mov    %esp,%ebp
8010079c:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010079f:	a1 00 d0 18 80       	mov    0x8018d000,%eax
801007a4:	85 c0                	test   %eax,%eax
801007a6:	74 07                	je     801007af <consputc+0x1a>
    cli();
801007a8:	e8 a8 fb ff ff       	call   80100355 <cli>
    for(;;)
801007ad:	eb fe                	jmp    801007ad <consputc+0x18>
      ;
  }

  if(c == BACKSPACE){
801007af:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007b6:	75 29                	jne    801007e1 <consputc+0x4c>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b8:	83 ec 0c             	sub    $0xc,%esp
801007bb:	6a 08                	push   $0x8
801007bd:	e8 fc 5f 00 00       	call   801067be <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 ef 5f 00 00       	call   801067be <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 e2 5f 00 00       	call   801067be <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	push   0x8(%ebp)
801007e7:	e8 d2 5f 00 00       	call   801067be <uartputc>
801007ec:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007ef:	83 ec 0c             	sub    $0xc,%esp
801007f2:	ff 75 08             	push   0x8(%ebp)
801007f5:	e8 63 fe ff ff       	call   8010065d <graphic_putc>
801007fa:	83 c4 10             	add    $0x10,%esp
}
801007fd:	90                   	nop
801007fe:	c9                   	leave
801007ff:	c3                   	ret

80100800 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100800:	f3 0f 1e fb          	endbr32
80100804:	55                   	push   %ebp
80100805:	89 e5                	mov    %esp,%ebp
80100807:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
8010080a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100811:	83 ec 0c             	sub    $0xc,%esp
80100814:	68 20 d0 18 80       	push   $0x8018d020
80100819:	e8 a5 42 00 00       	call   80104ac3 <acquire>
8010081e:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100821:	e9 52 01 00 00       	jmp    80100978 <consoleintr+0x178>
    switch(c){
80100826:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010082a:	0f 84 81 00 00 00    	je     801008b1 <consoleintr+0xb1>
80100830:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100834:	0f 8f ac 00 00 00    	jg     801008e6 <consoleintr+0xe6>
8010083a:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010083e:	74 43                	je     80100883 <consoleintr+0x83>
80100840:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100844:	0f 8f 9c 00 00 00    	jg     801008e6 <consoleintr+0xe6>
8010084a:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
8010084e:	74 61                	je     801008b1 <consoleintr+0xb1>
80100850:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100854:	0f 85 8c 00 00 00    	jne    801008e6 <consoleintr+0xe6>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010085a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100861:	e9 12 01 00 00       	jmp    80100978 <consoleintr+0x178>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100866:	a1 48 2d 19 80       	mov    0x80192d48,%eax
8010086b:	83 e8 01             	sub    $0x1,%eax
8010086e:	a3 48 2d 19 80       	mov    %eax,0x80192d48
        consputc(BACKSPACE);
80100873:	83 ec 0c             	sub    $0xc,%esp
80100876:	68 00 01 00 00       	push   $0x100
8010087b:	e8 15 ff ff ff       	call   80100795 <consputc>
80100880:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100883:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
80100889:	a1 44 2d 19 80       	mov    0x80192d44,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 e2 00 00 00    	je     80100978 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100896:	a1 48 2d 19 80       	mov    0x80192d48,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	83 e0 7f             	and    $0x7f,%eax
801008a1:	0f b6 80 c0 2c 19 80 	movzbl -0x7fe6d340(%eax),%eax
      while(input.e != input.w &&
801008a8:	3c 0a                	cmp    $0xa,%al
801008aa:	75 ba                	jne    80100866 <consoleintr+0x66>
      }
      break;
801008ac:	e9 c7 00 00 00       	jmp    80100978 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008b1:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
801008b7:	a1 44 2d 19 80       	mov    0x80192d44,%eax
801008bc:	39 c2                	cmp    %eax,%edx
801008be:	0f 84 b4 00 00 00    	je     80100978 <consoleintr+0x178>
        input.e--;
801008c4:	a1 48 2d 19 80       	mov    0x80192d48,%eax
801008c9:	83 e8 01             	sub    $0x1,%eax
801008cc:	a3 48 2d 19 80       	mov    %eax,0x80192d48
        consputc(BACKSPACE);
801008d1:	83 ec 0c             	sub    $0xc,%esp
801008d4:	68 00 01 00 00       	push   $0x100
801008d9:	e8 b7 fe ff ff       	call   80100795 <consputc>
801008de:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008e1:	e9 92 00 00 00       	jmp    80100978 <consoleintr+0x178>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008ea:	0f 84 87 00 00 00    	je     80100977 <consoleintr+0x177>
801008f0:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
801008f6:	a1 40 2d 19 80       	mov    0x80192d40,%eax
801008fb:	29 c2                	sub    %eax,%edx
801008fd:	89 d0                	mov    %edx,%eax
801008ff:	83 f8 7f             	cmp    $0x7f,%eax
80100902:	77 73                	ja     80100977 <consoleintr+0x177>
        c = (c == '\r') ? '\n' : c;
80100904:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100908:	74 05                	je     8010090f <consoleintr+0x10f>
8010090a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010090d:	eb 05                	jmp    80100914 <consoleintr+0x114>
8010090f:	b8 0a 00 00 00       	mov    $0xa,%eax
80100914:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100917:	a1 48 2d 19 80       	mov    0x80192d48,%eax
8010091c:	8d 50 01             	lea    0x1(%eax),%edx
8010091f:	89 15 48 2d 19 80    	mov    %edx,0x80192d48
80100925:	83 e0 7f             	and    $0x7f,%eax
80100928:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010092b:	88 90 c0 2c 19 80    	mov    %dl,-0x7fe6d340(%eax)
        consputc(c);
80100931:	83 ec 0c             	sub    $0xc,%esp
80100934:	ff 75 f0             	push   -0x10(%ebp)
80100937:	e8 59 fe ff ff       	call   80100795 <consputc>
8010093c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010093f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100943:	74 18                	je     8010095d <consoleintr+0x15d>
80100945:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100949:	74 12                	je     8010095d <consoleintr+0x15d>
8010094b:	a1 48 2d 19 80       	mov    0x80192d48,%eax
80100950:	8b 15 40 2d 19 80    	mov    0x80192d40,%edx
80100956:	83 ea 80             	sub    $0xffffff80,%edx
80100959:	39 d0                	cmp    %edx,%eax
8010095b:	75 1a                	jne    80100977 <consoleintr+0x177>
          input.w = input.e;
8010095d:	a1 48 2d 19 80       	mov    0x80192d48,%eax
80100962:	a3 44 2d 19 80       	mov    %eax,0x80192d44
          wakeup(&input.r);
80100967:	83 ec 0c             	sub    $0xc,%esp
8010096a:	68 40 2d 19 80       	push   $0x80192d40
8010096f:	e8 c5 3c 00 00       	call   80104639 <wakeup>
80100974:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100977:	90                   	nop
  while((c = getc()) >= 0){
80100978:	8b 45 08             	mov    0x8(%ebp),%eax
8010097b:	ff d0                	call   *%eax
8010097d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100980:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100984:	0f 89 9c fe ff ff    	jns    80100826 <consoleintr+0x26>
    }
  }
  release(&cons.lock);
8010098a:	83 ec 0c             	sub    $0xc,%esp
8010098d:	68 20 d0 18 80       	push   $0x8018d020
80100992:	e8 9e 41 00 00       	call   80104b35 <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 57 3d 00 00       	call   801046fc <procdump>
  }
}
801009a5:	90                   	nop
801009a6:	c9                   	leave
801009a7:	c3                   	ret

801009a8 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009a8:	f3 0f 1e fb          	endbr32
801009ac:	55                   	push   %ebp
801009ad:	89 e5                	mov    %esp,%ebp
801009af:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009b2:	83 ec 0c             	sub    $0xc,%esp
801009b5:	ff 75 08             	push   0x8(%ebp)
801009b8:	e8 13 12 00 00       	call   80101bd0 <iunlock>
801009bd:	83 c4 10             	add    $0x10,%esp
  target = n;
801009c0:	8b 45 10             	mov    0x10(%ebp),%eax
801009c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009c6:	83 ec 0c             	sub    $0xc,%esp
801009c9:	68 20 d0 18 80       	push   $0x8018d020
801009ce:	e8 f0 40 00 00       	call   80104ac3 <acquire>
801009d3:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009d6:	e9 ab 00 00 00       	jmp    80100a86 <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
801009db:	e8 06 32 00 00       	call   80103be6 <myproc>
801009e0:	8b 40 24             	mov    0x24(%eax),%eax
801009e3:	85 c0                	test   %eax,%eax
801009e5:	74 28                	je     80100a0f <consoleread+0x67>
        release(&cons.lock);
801009e7:	83 ec 0c             	sub    $0xc,%esp
801009ea:	68 20 d0 18 80       	push   $0x8018d020
801009ef:	e8 41 41 00 00       	call   80104b35 <release>
801009f4:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009f7:	83 ec 0c             	sub    $0xc,%esp
801009fa:	ff 75 08             	push   0x8(%ebp)
801009fd:	e8 b7 10 00 00       	call   80101ab9 <ilock>
80100a02:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a0a:	e9 ab 00 00 00       	jmp    80100aba <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100a0f:	83 ec 08             	sub    $0x8,%esp
80100a12:	68 20 d0 18 80       	push   $0x8018d020
80100a17:	68 40 2d 19 80       	push   $0x80192d40
80100a1c:	e8 29 3b 00 00       	call   8010454a <sleep>
80100a21:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a24:	8b 15 40 2d 19 80    	mov    0x80192d40,%edx
80100a2a:	a1 44 2d 19 80       	mov    0x80192d44,%eax
80100a2f:	39 c2                	cmp    %eax,%edx
80100a31:	74 a8                	je     801009db <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a33:	a1 40 2d 19 80       	mov    0x80192d40,%eax
80100a38:	8d 50 01             	lea    0x1(%eax),%edx
80100a3b:	89 15 40 2d 19 80    	mov    %edx,0x80192d40
80100a41:	83 e0 7f             	and    $0x7f,%eax
80100a44:	0f b6 80 c0 2c 19 80 	movzbl -0x7fe6d340(%eax),%eax
80100a4b:	0f be c0             	movsbl %al,%eax
80100a4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a51:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a55:	75 17                	jne    80100a6e <consoleread+0xc6>
      if(n < target){
80100a57:	8b 45 10             	mov    0x10(%ebp),%eax
80100a5a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a5d:	76 2f                	jbe    80100a8e <consoleread+0xe6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a5f:	a1 40 2d 19 80       	mov    0x80192d40,%eax
80100a64:	83 e8 01             	sub    $0x1,%eax
80100a67:	a3 40 2d 19 80       	mov    %eax,0x80192d40
      }
      break;
80100a6c:	eb 20                	jmp    80100a8e <consoleread+0xe6>
    }
    *dst++ = c;
80100a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a71:	8d 50 01             	lea    0x1(%eax),%edx
80100a74:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a77:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a7a:	88 10                	mov    %dl,(%eax)
    --n;
80100a7c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a80:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a84:	74 0b                	je     80100a91 <consoleread+0xe9>
  while(n > 0){
80100a86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a8a:	7f 98                	jg     80100a24 <consoleread+0x7c>
80100a8c:	eb 04                	jmp    80100a92 <consoleread+0xea>
      break;
80100a8e:	90                   	nop
80100a8f:	eb 01                	jmp    80100a92 <consoleread+0xea>
      break;
80100a91:	90                   	nop
  }
  release(&cons.lock);
80100a92:	83 ec 0c             	sub    $0xc,%esp
80100a95:	68 20 d0 18 80       	push   $0x8018d020
80100a9a:	e8 96 40 00 00       	call   80104b35 <release>
80100a9f:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aa2:	83 ec 0c             	sub    $0xc,%esp
80100aa5:	ff 75 08             	push   0x8(%ebp)
80100aa8:	e8 0c 10 00 00       	call   80101ab9 <ilock>
80100aad:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100ab0:	8b 45 10             	mov    0x10(%ebp),%eax
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	29 c2                	sub    %eax,%edx
80100ab8:	89 d0                	mov    %edx,%eax
}
80100aba:	c9                   	leave
80100abb:	c3                   	ret

80100abc <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100abc:	f3 0f 1e fb          	endbr32
80100ac0:	55                   	push   %ebp
80100ac1:	89 e5                	mov    %esp,%ebp
80100ac3:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100ac6:	83 ec 0c             	sub    $0xc,%esp
80100ac9:	ff 75 08             	push   0x8(%ebp)
80100acc:	e8 ff 10 00 00       	call   80101bd0 <iunlock>
80100ad1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ad4:	83 ec 0c             	sub    $0xc,%esp
80100ad7:	68 20 d0 18 80       	push   $0x8018d020
80100adc:	e8 e2 3f 00 00       	call   80104ac3 <acquire>
80100ae1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ae4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100aeb:	eb 21                	jmp    80100b0e <consolewrite+0x52>
    consputc(buf[i] & 0xff);
80100aed:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100af0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100af3:	01 d0                	add    %edx,%eax
80100af5:	0f b6 00             	movzbl (%eax),%eax
80100af8:	0f be c0             	movsbl %al,%eax
80100afb:	0f b6 c0             	movzbl %al,%eax
80100afe:	83 ec 0c             	sub    $0xc,%esp
80100b01:	50                   	push   %eax
80100b02:	e8 8e fc ff ff       	call   80100795 <consputc>
80100b07:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b0a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b11:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b14:	7c d7                	jl     80100aed <consolewrite+0x31>
  release(&cons.lock);
80100b16:	83 ec 0c             	sub    $0xc,%esp
80100b19:	68 20 d0 18 80       	push   $0x8018d020
80100b1e:	e8 12 40 00 00       	call   80104b35 <release>
80100b23:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b26:	83 ec 0c             	sub    $0xc,%esp
80100b29:	ff 75 08             	push   0x8(%ebp)
80100b2c:	e8 88 0f 00 00       	call   80101ab9 <ilock>
80100b31:	83 c4 10             	add    $0x10,%esp

  return n;
80100b34:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b37:	c9                   	leave
80100b38:	c3                   	ret

80100b39 <consoleinit>:

void
consoleinit(void)
{
80100b39:	f3 0f 1e fb          	endbr32
80100b3d:	55                   	push   %ebp
80100b3e:	89 e5                	mov    %esp,%ebp
80100b40:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b43:	c7 05 00 d0 18 80 00 	movl   $0x0,0x8018d000
80100b4a:	00 00 00 
  initlock(&cons.lock, "console");
80100b4d:	83 ec 08             	sub    $0x8,%esp
80100b50:	68 b7 a6 10 80       	push   $0x8010a6b7
80100b55:	68 20 d0 18 80       	push   $0x8018d020
80100b5a:	e8 3e 3f 00 00       	call   80104a9d <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 0c 37 19 80 bc 	movl   $0x80100abc,0x8019370c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 08 37 19 80 a8 	movl   $0x801009a8,0x80193708
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 bf a6 10 80 	movl   $0x8010a6bf,-0xc(%ebp)
80100b7d:	eb 19                	jmp    80100b98 <consoleinit+0x5f>
    graphic_putc(*p);
80100b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b82:	0f b6 00             	movzbl (%eax),%eax
80100b85:	0f be c0             	movsbl %al,%eax
80100b88:	83 ec 0c             	sub    $0xc,%esp
80100b8b:	50                   	push   %eax
80100b8c:	e8 cc fa ff ff       	call   8010065d <graphic_putc>
80100b91:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b94:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b9b:	0f b6 00             	movzbl (%eax),%eax
80100b9e:	84 c0                	test   %al,%al
80100ba0:	75 dd                	jne    80100b7f <consoleinit+0x46>
  
  cons.locking = 1;
80100ba2:	c7 05 54 d0 18 80 01 	movl   $0x1,0x8018d054
80100ba9:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100bac:	83 ec 08             	sub    $0x8,%esp
80100baf:	6a 00                	push   $0x0
80100bb1:	6a 01                	push   $0x1
80100bb3:	e8 91 1b 00 00       	call   80102749 <ioapicenable>
80100bb8:	83 c4 10             	add    $0x10,%esp
}
80100bbb:	90                   	nop
80100bbc:	c9                   	leave
80100bbd:	c3                   	ret

80100bbe <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100bbe:	f3 0f 1e fb          	endbr32
80100bc2:	55                   	push   %ebp
80100bc3:	89 e5                	mov    %esp,%ebp
80100bc5:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100bcb:	e8 16 30 00 00       	call   80103be6 <myproc>
80100bd0:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bd3:	e8 d6 25 00 00       	call   801031ae <begin_op>

  if((ip = namei(path)) == 0){
80100bd8:	83 ec 0c             	sub    $0xc,%esp
80100bdb:	ff 75 08             	push   0x8(%ebp)
80100bde:	e8 41 1a 00 00       	call   80102624 <namei>
80100be3:	83 c4 10             	add    $0x10,%esp
80100be6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100be9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bed:	75 1f                	jne    80100c0e <exec+0x50>
    end_op();
80100bef:	e8 4a 26 00 00       	call   8010323e <end_op>
    cprintf("exec: fail\n");
80100bf4:	83 ec 0c             	sub    $0xc,%esp
80100bf7:	68 d5 a6 10 80       	push   $0x8010a6d5
80100bfc:	e8 0b f8 ff ff       	call   8010040c <cprintf>
80100c01:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c09:	e9 2e 04 00 00       	jmp    8010103c <exec+0x47e>
  }
  ilock(ip);
80100c0e:	83 ec 0c             	sub    $0xc,%esp
80100c11:	ff 75 d8             	push   -0x28(%ebp)
80100c14:	e8 a0 0e 00 00       	call   80101ab9 <ilock>
80100c19:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c1c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c23:	6a 34                	push   $0x34
80100c25:	6a 00                	push   $0x0
80100c27:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c2d:	50                   	push   %eax
80100c2e:	ff 75 d8             	push   -0x28(%ebp)
80100c31:	e8 8b 13 00 00       	call   80101fc1 <readi>
80100c36:	83 c4 10             	add    $0x10,%esp
80100c39:	83 f8 34             	cmp    $0x34,%eax
80100c3c:	0f 85 93 03 00 00    	jne    80100fd5 <exec+0x417>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c42:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c48:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c4d:	0f 85 85 03 00 00    	jne    80100fd8 <exec+0x41a>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c53:	e8 7a 6b 00 00       	call   801077d2 <setupkvm>
80100c58:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c5b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c5f:	0f 84 76 03 00 00    	je     80100fdb <exec+0x41d>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c65:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c6c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c73:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c79:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c7c:	e9 de 00 00 00       	jmp    80100d5f <exec+0x1a1>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c81:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c84:	6a 20                	push   $0x20
80100c86:	50                   	push   %eax
80100c87:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c8d:	50                   	push   %eax
80100c8e:	ff 75 d8             	push   -0x28(%ebp)
80100c91:	e8 2b 13 00 00       	call   80101fc1 <readi>
80100c96:	83 c4 10             	add    $0x10,%esp
80100c99:	83 f8 20             	cmp    $0x20,%eax
80100c9c:	0f 85 3c 03 00 00    	jne    80100fde <exec+0x420>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100ca2:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100ca8:	83 f8 01             	cmp    $0x1,%eax
80100cab:	0f 85 a0 00 00 00    	jne    80100d51 <exec+0x193>
      continue;
    if(ph.memsz < ph.filesz)
80100cb1:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cb7:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100cbd:	39 c2                	cmp    %eax,%edx
80100cbf:	0f 82 1c 03 00 00    	jb     80100fe1 <exec+0x423>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cc5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ccb:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cd1:	01 c2                	add    %eax,%edx
80100cd3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd9:	39 c2                	cmp    %eax,%edx
80100cdb:	0f 82 03 03 00 00    	jb     80100fe4 <exec+0x426>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ce1:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ce7:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ced:	01 d0                	add    %edx,%eax
80100cef:	83 ec 04             	sub    $0x4,%esp
80100cf2:	50                   	push   %eax
80100cf3:	ff 75 e0             	push   -0x20(%ebp)
80100cf6:	ff 75 d4             	push   -0x2c(%ebp)
80100cf9:	e8 e6 6e 00 00       	call   80107be4 <allocuvm>
80100cfe:	83 c4 10             	add    $0x10,%esp
80100d01:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d04:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d08:	0f 84 d9 02 00 00    	je     80100fe7 <exec+0x429>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d0e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d14:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d19:	85 c0                	test   %eax,%eax
80100d1b:	0f 85 c9 02 00 00    	jne    80100fea <exec+0x42c>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d21:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d27:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d2d:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d33:	83 ec 0c             	sub    $0xc,%esp
80100d36:	52                   	push   %edx
80100d37:	50                   	push   %eax
80100d38:	ff 75 d8             	push   -0x28(%ebp)
80100d3b:	51                   	push   %ecx
80100d3c:	ff 75 d4             	push   -0x2c(%ebp)
80100d3f:	e8 cf 6d 00 00       	call   80107b13 <loaduvm>
80100d44:	83 c4 20             	add    $0x20,%esp
80100d47:	85 c0                	test   %eax,%eax
80100d49:	0f 88 9e 02 00 00    	js     80100fed <exec+0x42f>
80100d4f:	eb 01                	jmp    80100d52 <exec+0x194>
      continue;
80100d51:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d52:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d56:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d59:	83 c0 20             	add    $0x20,%eax
80100d5c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d5f:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d66:	0f b7 c0             	movzwl %ax,%eax
80100d69:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d6c:	0f 8c 0f ff ff ff    	jl     80100c81 <exec+0xc3>
      goto bad;
  }
  iunlockput(ip);
80100d72:	83 ec 0c             	sub    $0xc,%esp
80100d75:	ff 75 d8             	push   -0x28(%ebp)
80100d78:	e8 79 0f 00 00       	call   80101cf6 <iunlockput>
80100d7d:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d80:	e8 b9 24 00 00       	call   8010323e <end_op>
  ip = 0;
80100d85:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  cprintf("[exec] sz %x",sz);
80100d8c:	83 ec 08             	sub    $0x8,%esp
80100d8f:	ff 75 e0             	push   -0x20(%ebp)
80100d92:	68 e1 a6 10 80       	push   $0x8010a6e1
80100d97:	e8 70 f6 ff ff       	call   8010040c <cprintf>
80100d9c:	83 c4 10             	add    $0x10,%esp
  // sz를 커널 베이스로 이동 페이지를 할당해야 하기 때문에 그 크기만큼 빼줌
  // 2*PGSIZE로 하면 페이지의 끝 주소가 커널 베이스가 되기 때문에 한단계 더 내린다.
  sz = PGROUNDDOWN(KERNBASE - 3*PGSIZE);
80100d9f:	c7 45 e0 00 d0 ff 7f 	movl   $0x7fffd000,-0x20(%ebp)
  // 커널 베이스에서 PGSIZE만큼 할당
  if((sz = allocuvm(pgdir, sz, sz + 2 * PGSIZE)) == 0)
80100da6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100da9:	05 00 20 00 00       	add    $0x2000,%eax
80100dae:	83 ec 04             	sub    $0x4,%esp
80100db1:	50                   	push   %eax
80100db2:	ff 75 e0             	push   -0x20(%ebp)
80100db5:	ff 75 d4             	push   -0x2c(%ebp)
80100db8:	e8 27 6e 00 00       	call   80107be4 <allocuvm>
80100dbd:	83 c4 10             	add    $0x10,%esp
80100dc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dc3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dc7:	0f 84 23 02 00 00    	je     80100ff0 <exec+0x432>
    goto bad;
  cprintf("[exec] sz %x\n", sz);
80100dcd:	83 ec 08             	sub    $0x8,%esp
80100dd0:	ff 75 e0             	push   -0x20(%ebp)
80100dd3:	68 ee a6 10 80       	push   $0x8010a6ee
80100dd8:	e8 2f f6 ff ff       	call   8010040c <cprintf>
80100ddd:	83 c4 10             	add    $0x10,%esp
  // 스택 포인터를 sz로
  sp = sz;
80100de0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100de3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  sz = PGROUNDUP(0xb98)+1;
80100de6:	c7 45 e0 01 10 00 00 	movl   $0x1001,-0x20(%ebp)
  cprintf("[exec] allocuvm complete\n");
80100ded:	83 ec 0c             	sub    $0xc,%esp
80100df0:	68 fc a6 10 80       	push   $0x8010a6fc
80100df5:	e8 12 f6 ff ff       	call   8010040c <cprintf>
80100dfa:	83 c4 10             	add    $0x10,%esp


  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dfd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e04:	e9 96 00 00 00       	jmp    80100e9f <exec+0x2e1>
    if(argc >= MAXARG)
80100e09:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e0d:	0f 87 e0 01 00 00    	ja     80100ff3 <exec+0x435>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e16:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e20:	01 d0                	add    %edx,%eax
80100e22:	8b 00                	mov    (%eax),%eax
80100e24:	83 ec 0c             	sub    $0xc,%esp
80100e27:	50                   	push   %eax
80100e28:	e8 8e 41 00 00       	call   80104fbb <strlen>
80100e2d:	83 c4 10             	add    $0x10,%esp
80100e30:	89 c2                	mov    %eax,%edx
80100e32:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e35:	29 d0                	sub    %edx,%eax
80100e37:	83 e8 01             	sub    $0x1,%eax
80100e3a:	83 e0 fc             	and    $0xfffffffc,%eax
80100e3d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e43:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e4d:	01 d0                	add    %edx,%eax
80100e4f:	8b 00                	mov    (%eax),%eax
80100e51:	83 ec 0c             	sub    $0xc,%esp
80100e54:	50                   	push   %eax
80100e55:	e8 61 41 00 00       	call   80104fbb <strlen>
80100e5a:	83 c4 10             	add    $0x10,%esp
80100e5d:	83 c0 01             	add    $0x1,%eax
80100e60:	89 c1                	mov    %eax,%ecx
80100e62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e65:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e6f:	01 d0                	add    %edx,%eax
80100e71:	8b 00                	mov    (%eax),%eax
80100e73:	51                   	push   %ecx
80100e74:	50                   	push   %eax
80100e75:	ff 75 dc             	push   -0x24(%ebp)
80100e78:	ff 75 d4             	push   -0x2c(%ebp)
80100e7b:	e8 b9 71 00 00       	call   80108039 <copyout>
80100e80:	83 c4 10             	add    $0x10,%esp
80100e83:	85 c0                	test   %eax,%eax
80100e85:	0f 88 6b 01 00 00    	js     80100ff6 <exec+0x438>
      goto bad;
    ustack[3+argc] = sp;
80100e8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8e:	8d 50 03             	lea    0x3(%eax),%edx
80100e91:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e94:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e9b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
80100eac:	01 d0                	add    %edx,%eax
80100eae:	8b 00                	mov    (%eax),%eax
80100eb0:	85 c0                	test   %eax,%eax
80100eb2:	0f 85 51 ff ff ff    	jne    80100e09 <exec+0x24b>
  }
  ustack[3+argc] = 0;
80100eb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ebb:	83 c0 03             	add    $0x3,%eax
80100ebe:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100ec5:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ec9:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100ed0:	ff ff ff 
  ustack[1] = argc;
80100ed3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed6:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100edc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100edf:	83 c0 01             	add    $0x1,%eax
80100ee2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ee9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100eec:	29 d0                	sub    %edx,%eax
80100eee:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100ef4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ef7:	83 c0 04             	add    $0x4,%eax
80100efa:	c1 e0 02             	shl    $0x2,%eax
80100efd:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f03:	83 c0 04             	add    $0x4,%eax
80100f06:	c1 e0 02             	shl    $0x2,%eax
80100f09:	50                   	push   %eax
80100f0a:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100f10:	50                   	push   %eax
80100f11:	ff 75 dc             	push   -0x24(%ebp)
80100f14:	ff 75 d4             	push   -0x2c(%ebp)
80100f17:	e8 1d 71 00 00       	call   80108039 <copyout>
80100f1c:	83 c4 10             	add    $0x10,%esp
80100f1f:	85 c0                	test   %eax,%eax
80100f21:	0f 88 d2 00 00 00    	js     80100ff9 <exec+0x43b>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f27:	8b 45 08             	mov    0x8(%ebp),%eax
80100f2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f30:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f33:	eb 17                	jmp    80100f4c <exec+0x38e>
    if(*s == '/')
80100f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f38:	0f b6 00             	movzbl (%eax),%eax
80100f3b:	3c 2f                	cmp    $0x2f,%al
80100f3d:	75 09                	jne    80100f48 <exec+0x38a>
      last = s+1;
80100f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f42:	83 c0 01             	add    $0x1,%eax
80100f45:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f48:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f4f:	0f b6 00             	movzbl (%eax),%eax
80100f52:	84 c0                	test   %al,%al
80100f54:	75 df                	jne    80100f35 <exec+0x377>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f56:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f59:	83 c0 6c             	add    $0x6c,%eax
80100f5c:	83 ec 04             	sub    $0x4,%esp
80100f5f:	6a 10                	push   $0x10
80100f61:	ff 75 f0             	push   -0x10(%ebp)
80100f64:	50                   	push   %eax
80100f65:	e8 03 40 00 00       	call   80104f6d <safestrcpy>
80100f6a:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f6d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f70:	8b 40 04             	mov    0x4(%eax),%eax
80100f73:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f76:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f79:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f7c:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f7f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f82:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f85:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f87:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f8a:	8b 40 18             	mov    0x18(%eax),%eax
80100f8d:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f93:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f96:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f99:	8b 40 18             	mov    0x18(%eax),%eax
80100f9c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f9f:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100fa2:	83 ec 0c             	sub    $0xc,%esp
80100fa5:	ff 75 d0             	push   -0x30(%ebp)
80100fa8:	e8 4f 69 00 00       	call   801078fc <switchuvm>
80100fad:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fb0:	83 ec 0c             	sub    $0xc,%esp
80100fb3:	ff 75 cc             	push   -0x34(%ebp)
80100fb6:	e8 20 6e 00 00       	call   80107ddb <freevm>
80100fbb:	83 c4 10             	add    $0x10,%esp
  cprintf("[exec] end\n");
80100fbe:	83 ec 0c             	sub    $0xc,%esp
80100fc1:	68 16 a7 10 80       	push   $0x8010a716
80100fc6:	e8 41 f4 ff ff       	call   8010040c <cprintf>
80100fcb:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fce:	b8 00 00 00 00       	mov    $0x0,%eax
80100fd3:	eb 67                	jmp    8010103c <exec+0x47e>
    goto bad;
80100fd5:	90                   	nop
80100fd6:	eb 22                	jmp    80100ffa <exec+0x43c>
    goto bad;
80100fd8:	90                   	nop
80100fd9:	eb 1f                	jmp    80100ffa <exec+0x43c>
    goto bad;
80100fdb:	90                   	nop
80100fdc:	eb 1c                	jmp    80100ffa <exec+0x43c>
      goto bad;
80100fde:	90                   	nop
80100fdf:	eb 19                	jmp    80100ffa <exec+0x43c>
      goto bad;
80100fe1:	90                   	nop
80100fe2:	eb 16                	jmp    80100ffa <exec+0x43c>
      goto bad;
80100fe4:	90                   	nop
80100fe5:	eb 13                	jmp    80100ffa <exec+0x43c>
      goto bad;
80100fe7:	90                   	nop
80100fe8:	eb 10                	jmp    80100ffa <exec+0x43c>
      goto bad;
80100fea:	90                   	nop
80100feb:	eb 0d                	jmp    80100ffa <exec+0x43c>
      goto bad;
80100fed:	90                   	nop
80100fee:	eb 0a                	jmp    80100ffa <exec+0x43c>
    goto bad;
80100ff0:	90                   	nop
80100ff1:	eb 07                	jmp    80100ffa <exec+0x43c>
      goto bad;
80100ff3:	90                   	nop
80100ff4:	eb 04                	jmp    80100ffa <exec+0x43c>
      goto bad;
80100ff6:	90                   	nop
80100ff7:	eb 01                	jmp    80100ffa <exec+0x43c>
    goto bad;
80100ff9:	90                   	nop

 bad:
  cprintf("bad \n");
80100ffa:	83 ec 0c             	sub    $0xc,%esp
80100ffd:	68 22 a7 10 80       	push   $0x8010a722
80101002:	e8 05 f4 ff ff       	call   8010040c <cprintf>
80101007:	83 c4 10             	add    $0x10,%esp
  if(pgdir)
8010100a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010100e:	74 0e                	je     8010101e <exec+0x460>
    freevm(pgdir);
80101010:	83 ec 0c             	sub    $0xc,%esp
80101013:	ff 75 d4             	push   -0x2c(%ebp)
80101016:	e8 c0 6d 00 00       	call   80107ddb <freevm>
8010101b:	83 c4 10             	add    $0x10,%esp
  if(ip){
8010101e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101022:	74 13                	je     80101037 <exec+0x479>
    iunlockput(ip);
80101024:	83 ec 0c             	sub    $0xc,%esp
80101027:	ff 75 d8             	push   -0x28(%ebp)
8010102a:	e8 c7 0c 00 00       	call   80101cf6 <iunlockput>
8010102f:	83 c4 10             	add    $0x10,%esp
    end_op();
80101032:	e8 07 22 00 00       	call   8010323e <end_op>
  }
  return -1;
80101037:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010103c:	c9                   	leave
8010103d:	c3                   	ret

8010103e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
8010103e:	f3 0f 1e fb          	endbr32
80101042:	55                   	push   %ebp
80101043:	89 e5                	mov    %esp,%ebp
80101045:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80101048:	83 ec 08             	sub    $0x8,%esp
8010104b:	68 28 a7 10 80       	push   $0x8010a728
80101050:	68 60 2d 19 80       	push   $0x80192d60
80101055:	e8 43 3a 00 00       	call   80104a9d <initlock>
8010105a:	83 c4 10             	add    $0x10,%esp
}
8010105d:	90                   	nop
8010105e:	c9                   	leave
8010105f:	c3                   	ret

80101060 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101060:	f3 0f 1e fb          	endbr32
80101064:	55                   	push   %ebp
80101065:	89 e5                	mov    %esp,%ebp
80101067:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010106a:	83 ec 0c             	sub    $0xc,%esp
8010106d:	68 60 2d 19 80       	push   $0x80192d60
80101072:	e8 4c 3a 00 00       	call   80104ac3 <acquire>
80101077:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010107a:	c7 45 f4 94 2d 19 80 	movl   $0x80192d94,-0xc(%ebp)
80101081:	eb 2d                	jmp    801010b0 <filealloc+0x50>
    if(f->ref == 0){
80101083:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101086:	8b 40 04             	mov    0x4(%eax),%eax
80101089:	85 c0                	test   %eax,%eax
8010108b:	75 1f                	jne    801010ac <filealloc+0x4c>
      f->ref = 1;
8010108d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101090:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101097:	83 ec 0c             	sub    $0xc,%esp
8010109a:	68 60 2d 19 80       	push   $0x80192d60
8010109f:	e8 91 3a 00 00       	call   80104b35 <release>
801010a4:	83 c4 10             	add    $0x10,%esp
      return f;
801010a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010aa:	eb 23                	jmp    801010cf <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010ac:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801010b0:	b8 f4 36 19 80       	mov    $0x801936f4,%eax
801010b5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801010b8:	72 c9                	jb     80101083 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
801010ba:	83 ec 0c             	sub    $0xc,%esp
801010bd:	68 60 2d 19 80       	push   $0x80192d60
801010c2:	e8 6e 3a 00 00       	call   80104b35 <release>
801010c7:	83 c4 10             	add    $0x10,%esp
  return 0;
801010ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
801010cf:	c9                   	leave
801010d0:	c3                   	ret

801010d1 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801010d1:	f3 0f 1e fb          	endbr32
801010d5:	55                   	push   %ebp
801010d6:	89 e5                	mov    %esp,%ebp
801010d8:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801010db:	83 ec 0c             	sub    $0xc,%esp
801010de:	68 60 2d 19 80       	push   $0x80192d60
801010e3:	e8 db 39 00 00       	call   80104ac3 <acquire>
801010e8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010eb:	8b 45 08             	mov    0x8(%ebp),%eax
801010ee:	8b 40 04             	mov    0x4(%eax),%eax
801010f1:	85 c0                	test   %eax,%eax
801010f3:	7f 0d                	jg     80101102 <filedup+0x31>
    panic("filedup");
801010f5:	83 ec 0c             	sub    $0xc,%esp
801010f8:	68 2f a7 10 80       	push   $0x8010a72f
801010fd:	e8 c3 f4 ff ff       	call   801005c5 <panic>
  f->ref++;
80101102:	8b 45 08             	mov    0x8(%ebp),%eax
80101105:	8b 40 04             	mov    0x4(%eax),%eax
80101108:	8d 50 01             	lea    0x1(%eax),%edx
8010110b:	8b 45 08             	mov    0x8(%ebp),%eax
8010110e:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101111:	83 ec 0c             	sub    $0xc,%esp
80101114:	68 60 2d 19 80       	push   $0x80192d60
80101119:	e8 17 3a 00 00       	call   80104b35 <release>
8010111e:	83 c4 10             	add    $0x10,%esp
  return f;
80101121:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101124:	c9                   	leave
80101125:	c3                   	ret

80101126 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101126:	f3 0f 1e fb          	endbr32
8010112a:	55                   	push   %ebp
8010112b:	89 e5                	mov    %esp,%ebp
8010112d:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101130:	83 ec 0c             	sub    $0xc,%esp
80101133:	68 60 2d 19 80       	push   $0x80192d60
80101138:	e8 86 39 00 00       	call   80104ac3 <acquire>
8010113d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101140:	8b 45 08             	mov    0x8(%ebp),%eax
80101143:	8b 40 04             	mov    0x4(%eax),%eax
80101146:	85 c0                	test   %eax,%eax
80101148:	7f 0d                	jg     80101157 <fileclose+0x31>
    panic("fileclose");
8010114a:	83 ec 0c             	sub    $0xc,%esp
8010114d:	68 37 a7 10 80       	push   $0x8010a737
80101152:	e8 6e f4 ff ff       	call   801005c5 <panic>
  if(--f->ref > 0){
80101157:	8b 45 08             	mov    0x8(%ebp),%eax
8010115a:	8b 40 04             	mov    0x4(%eax),%eax
8010115d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101160:	8b 45 08             	mov    0x8(%ebp),%eax
80101163:	89 50 04             	mov    %edx,0x4(%eax)
80101166:	8b 45 08             	mov    0x8(%ebp),%eax
80101169:	8b 40 04             	mov    0x4(%eax),%eax
8010116c:	85 c0                	test   %eax,%eax
8010116e:	7e 15                	jle    80101185 <fileclose+0x5f>
    release(&ftable.lock);
80101170:	83 ec 0c             	sub    $0xc,%esp
80101173:	68 60 2d 19 80       	push   $0x80192d60
80101178:	e8 b8 39 00 00       	call   80104b35 <release>
8010117d:	83 c4 10             	add    $0x10,%esp
80101180:	e9 8b 00 00 00       	jmp    80101210 <fileclose+0xea>
    return;
  }
  ff = *f;
80101185:	8b 45 08             	mov    0x8(%ebp),%eax
80101188:	8b 10                	mov    (%eax),%edx
8010118a:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010118d:	8b 50 04             	mov    0x4(%eax),%edx
80101190:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101193:	8b 50 08             	mov    0x8(%eax),%edx
80101196:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101199:	8b 50 0c             	mov    0xc(%eax),%edx
8010119c:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010119f:	8b 50 10             	mov    0x10(%eax),%edx
801011a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801011a5:	8b 40 14             	mov    0x14(%eax),%eax
801011a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801011ab:	8b 45 08             	mov    0x8(%ebp),%eax
801011ae:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801011b5:	8b 45 08             	mov    0x8(%ebp),%eax
801011b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801011be:	83 ec 0c             	sub    $0xc,%esp
801011c1:	68 60 2d 19 80       	push   $0x80192d60
801011c6:	e8 6a 39 00 00       	call   80104b35 <release>
801011cb:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
801011ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011d1:	83 f8 01             	cmp    $0x1,%eax
801011d4:	75 19                	jne    801011ef <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
801011d6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801011da:	0f be d0             	movsbl %al,%edx
801011dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011e0:	83 ec 08             	sub    $0x8,%esp
801011e3:	52                   	push   %edx
801011e4:	50                   	push   %eax
801011e5:	e8 73 26 00 00       	call   8010385d <pipeclose>
801011ea:	83 c4 10             	add    $0x10,%esp
801011ed:	eb 21                	jmp    80101210 <fileclose+0xea>
  else if(ff.type == FD_INODE){
801011ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011f2:	83 f8 02             	cmp    $0x2,%eax
801011f5:	75 19                	jne    80101210 <fileclose+0xea>
    begin_op();
801011f7:	e8 b2 1f 00 00       	call   801031ae <begin_op>
    iput(ff.ip);
801011fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011ff:	83 ec 0c             	sub    $0xc,%esp
80101202:	50                   	push   %eax
80101203:	e8 1a 0a 00 00       	call   80101c22 <iput>
80101208:	83 c4 10             	add    $0x10,%esp
    end_op();
8010120b:	e8 2e 20 00 00       	call   8010323e <end_op>
  }
}
80101210:	c9                   	leave
80101211:	c3                   	ret

80101212 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101212:	f3 0f 1e fb          	endbr32
80101216:	55                   	push   %ebp
80101217:	89 e5                	mov    %esp,%ebp
80101219:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010121c:	8b 45 08             	mov    0x8(%ebp),%eax
8010121f:	8b 00                	mov    (%eax),%eax
80101221:	83 f8 02             	cmp    $0x2,%eax
80101224:	75 40                	jne    80101266 <filestat+0x54>
    ilock(f->ip);
80101226:	8b 45 08             	mov    0x8(%ebp),%eax
80101229:	8b 40 10             	mov    0x10(%eax),%eax
8010122c:	83 ec 0c             	sub    $0xc,%esp
8010122f:	50                   	push   %eax
80101230:	e8 84 08 00 00       	call   80101ab9 <ilock>
80101235:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101238:	8b 45 08             	mov    0x8(%ebp),%eax
8010123b:	8b 40 10             	mov    0x10(%eax),%eax
8010123e:	83 ec 08             	sub    $0x8,%esp
80101241:	ff 75 0c             	push   0xc(%ebp)
80101244:	50                   	push   %eax
80101245:	e8 2d 0d 00 00       	call   80101f77 <stati>
8010124a:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010124d:	8b 45 08             	mov    0x8(%ebp),%eax
80101250:	8b 40 10             	mov    0x10(%eax),%eax
80101253:	83 ec 0c             	sub    $0xc,%esp
80101256:	50                   	push   %eax
80101257:	e8 74 09 00 00       	call   80101bd0 <iunlock>
8010125c:	83 c4 10             	add    $0x10,%esp
    return 0;
8010125f:	b8 00 00 00 00       	mov    $0x0,%eax
80101264:	eb 05                	jmp    8010126b <filestat+0x59>
  }
  return -1;
80101266:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010126b:	c9                   	leave
8010126c:	c3                   	ret

8010126d <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010126d:	f3 0f 1e fb          	endbr32
80101271:	55                   	push   %ebp
80101272:	89 e5                	mov    %esp,%ebp
80101274:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101277:	8b 45 08             	mov    0x8(%ebp),%eax
8010127a:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010127e:	84 c0                	test   %al,%al
80101280:	75 0a                	jne    8010128c <fileread+0x1f>
    return -1;
80101282:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101287:	e9 9b 00 00 00       	jmp    80101327 <fileread+0xba>
  if(f->type == FD_PIPE)
8010128c:	8b 45 08             	mov    0x8(%ebp),%eax
8010128f:	8b 00                	mov    (%eax),%eax
80101291:	83 f8 01             	cmp    $0x1,%eax
80101294:	75 1a                	jne    801012b0 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101296:	8b 45 08             	mov    0x8(%ebp),%eax
80101299:	8b 40 0c             	mov    0xc(%eax),%eax
8010129c:	83 ec 04             	sub    $0x4,%esp
8010129f:	ff 75 10             	push   0x10(%ebp)
801012a2:	ff 75 0c             	push   0xc(%ebp)
801012a5:	50                   	push   %eax
801012a6:	e8 67 27 00 00       	call   80103a12 <piperead>
801012ab:	83 c4 10             	add    $0x10,%esp
801012ae:	eb 77                	jmp    80101327 <fileread+0xba>
  if(f->type == FD_INODE){
801012b0:	8b 45 08             	mov    0x8(%ebp),%eax
801012b3:	8b 00                	mov    (%eax),%eax
801012b5:	83 f8 02             	cmp    $0x2,%eax
801012b8:	75 60                	jne    8010131a <fileread+0xad>
    ilock(f->ip);
801012ba:	8b 45 08             	mov    0x8(%ebp),%eax
801012bd:	8b 40 10             	mov    0x10(%eax),%eax
801012c0:	83 ec 0c             	sub    $0xc,%esp
801012c3:	50                   	push   %eax
801012c4:	e8 f0 07 00 00       	call   80101ab9 <ilock>
801012c9:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801012cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
801012cf:	8b 45 08             	mov    0x8(%ebp),%eax
801012d2:	8b 50 14             	mov    0x14(%eax),%edx
801012d5:	8b 45 08             	mov    0x8(%ebp),%eax
801012d8:	8b 40 10             	mov    0x10(%eax),%eax
801012db:	51                   	push   %ecx
801012dc:	52                   	push   %edx
801012dd:	ff 75 0c             	push   0xc(%ebp)
801012e0:	50                   	push   %eax
801012e1:	e8 db 0c 00 00       	call   80101fc1 <readi>
801012e6:	83 c4 10             	add    $0x10,%esp
801012e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012f0:	7e 11                	jle    80101303 <fileread+0x96>
      f->off += r;
801012f2:	8b 45 08             	mov    0x8(%ebp),%eax
801012f5:	8b 50 14             	mov    0x14(%eax),%edx
801012f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012fb:	01 c2                	add    %eax,%edx
801012fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101300:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101303:	8b 45 08             	mov    0x8(%ebp),%eax
80101306:	8b 40 10             	mov    0x10(%eax),%eax
80101309:	83 ec 0c             	sub    $0xc,%esp
8010130c:	50                   	push   %eax
8010130d:	e8 be 08 00 00       	call   80101bd0 <iunlock>
80101312:	83 c4 10             	add    $0x10,%esp
    return r;
80101315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101318:	eb 0d                	jmp    80101327 <fileread+0xba>
  }
  panic("fileread");
8010131a:	83 ec 0c             	sub    $0xc,%esp
8010131d:	68 41 a7 10 80       	push   $0x8010a741
80101322:	e8 9e f2 ff ff       	call   801005c5 <panic>
}
80101327:	c9                   	leave
80101328:	c3                   	ret

80101329 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101329:	f3 0f 1e fb          	endbr32
8010132d:	55                   	push   %ebp
8010132e:	89 e5                	mov    %esp,%ebp
80101330:	53                   	push   %ebx
80101331:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101334:	8b 45 08             	mov    0x8(%ebp),%eax
80101337:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010133b:	84 c0                	test   %al,%al
8010133d:	75 0a                	jne    80101349 <filewrite+0x20>
    return -1;
8010133f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101344:	e9 1b 01 00 00       	jmp    80101464 <filewrite+0x13b>
  if(f->type == FD_PIPE)
80101349:	8b 45 08             	mov    0x8(%ebp),%eax
8010134c:	8b 00                	mov    (%eax),%eax
8010134e:	83 f8 01             	cmp    $0x1,%eax
80101351:	75 1d                	jne    80101370 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101353:	8b 45 08             	mov    0x8(%ebp),%eax
80101356:	8b 40 0c             	mov    0xc(%eax),%eax
80101359:	83 ec 04             	sub    $0x4,%esp
8010135c:	ff 75 10             	push   0x10(%ebp)
8010135f:	ff 75 0c             	push   0xc(%ebp)
80101362:	50                   	push   %eax
80101363:	e8 a4 25 00 00       	call   8010390c <pipewrite>
80101368:	83 c4 10             	add    $0x10,%esp
8010136b:	e9 f4 00 00 00       	jmp    80101464 <filewrite+0x13b>
  if(f->type == FD_INODE){
80101370:	8b 45 08             	mov    0x8(%ebp),%eax
80101373:	8b 00                	mov    (%eax),%eax
80101375:	83 f8 02             	cmp    $0x2,%eax
80101378:	0f 85 d9 00 00 00    	jne    80101457 <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
8010137e:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101385:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010138c:	e9 a3 00 00 00       	jmp    80101434 <filewrite+0x10b>
      int n1 = n - i;
80101391:	8b 45 10             	mov    0x10(%ebp),%eax
80101394:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101397:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010139a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010139d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801013a0:	7e 06                	jle    801013a8 <filewrite+0x7f>
        n1 = max;
801013a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013a5:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801013a8:	e8 01 1e 00 00       	call   801031ae <begin_op>
      ilock(f->ip);
801013ad:	8b 45 08             	mov    0x8(%ebp),%eax
801013b0:	8b 40 10             	mov    0x10(%eax),%eax
801013b3:	83 ec 0c             	sub    $0xc,%esp
801013b6:	50                   	push   %eax
801013b7:	e8 fd 06 00 00       	call   80101ab9 <ilock>
801013bc:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801013bf:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801013c2:	8b 45 08             	mov    0x8(%ebp),%eax
801013c5:	8b 50 14             	mov    0x14(%eax),%edx
801013c8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801013cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801013ce:	01 c3                	add    %eax,%ebx
801013d0:	8b 45 08             	mov    0x8(%ebp),%eax
801013d3:	8b 40 10             	mov    0x10(%eax),%eax
801013d6:	51                   	push   %ecx
801013d7:	52                   	push   %edx
801013d8:	53                   	push   %ebx
801013d9:	50                   	push   %eax
801013da:	e8 3b 0d 00 00       	call   8010211a <writei>
801013df:	83 c4 10             	add    $0x10,%esp
801013e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013e5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013e9:	7e 11                	jle    801013fc <filewrite+0xd3>
        f->off += r;
801013eb:	8b 45 08             	mov    0x8(%ebp),%eax
801013ee:	8b 50 14             	mov    0x14(%eax),%edx
801013f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013f4:	01 c2                	add    %eax,%edx
801013f6:	8b 45 08             	mov    0x8(%ebp),%eax
801013f9:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013fc:	8b 45 08             	mov    0x8(%ebp),%eax
801013ff:	8b 40 10             	mov    0x10(%eax),%eax
80101402:	83 ec 0c             	sub    $0xc,%esp
80101405:	50                   	push   %eax
80101406:	e8 c5 07 00 00       	call   80101bd0 <iunlock>
8010140b:	83 c4 10             	add    $0x10,%esp
      end_op();
8010140e:	e8 2b 1e 00 00       	call   8010323e <end_op>

      if(r < 0)
80101413:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101417:	78 29                	js     80101442 <filewrite+0x119>
        break;
      if(r != n1)
80101419:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010141c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010141f:	74 0d                	je     8010142e <filewrite+0x105>
        panic("short filewrite");
80101421:	83 ec 0c             	sub    $0xc,%esp
80101424:	68 4a a7 10 80       	push   $0x8010a74a
80101429:	e8 97 f1 ff ff       	call   801005c5 <panic>
      i += r;
8010142e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101431:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101437:	3b 45 10             	cmp    0x10(%ebp),%eax
8010143a:	0f 8c 51 ff ff ff    	jl     80101391 <filewrite+0x68>
80101440:	eb 01                	jmp    80101443 <filewrite+0x11a>
        break;
80101442:	90                   	nop
    }
    return i == n ? n : -1;
80101443:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101446:	3b 45 10             	cmp    0x10(%ebp),%eax
80101449:	75 05                	jne    80101450 <filewrite+0x127>
8010144b:	8b 45 10             	mov    0x10(%ebp),%eax
8010144e:	eb 14                	jmp    80101464 <filewrite+0x13b>
80101450:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101455:	eb 0d                	jmp    80101464 <filewrite+0x13b>
  }
  panic("filewrite");
80101457:	83 ec 0c             	sub    $0xc,%esp
8010145a:	68 5a a7 10 80       	push   $0x8010a75a
8010145f:	e8 61 f1 ff ff       	call   801005c5 <panic>
}
80101464:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101467:	c9                   	leave
80101468:	c3                   	ret

80101469 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101469:	f3 0f 1e fb          	endbr32
8010146d:	55                   	push   %ebp
8010146e:	89 e5                	mov    %esp,%ebp
80101470:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101473:	8b 45 08             	mov    0x8(%ebp),%eax
80101476:	83 ec 08             	sub    $0x8,%esp
80101479:	6a 01                	push   $0x1
8010147b:	50                   	push   %eax
8010147c:	e8 88 ed ff ff       	call   80100209 <bread>
80101481:	83 c4 10             	add    $0x10,%esp
80101484:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010148a:	83 c0 5c             	add    $0x5c,%eax
8010148d:	83 ec 04             	sub    $0x4,%esp
80101490:	6a 1c                	push   $0x1c
80101492:	50                   	push   %eax
80101493:	ff 75 0c             	push   0xc(%ebp)
80101496:	e8 7e 39 00 00       	call   80104e19 <memmove>
8010149b:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010149e:	83 ec 0c             	sub    $0xc,%esp
801014a1:	ff 75 f4             	push   -0xc(%ebp)
801014a4:	e8 ea ed ff ff       	call   80100293 <brelse>
801014a9:	83 c4 10             	add    $0x10,%esp
}
801014ac:	90                   	nop
801014ad:	c9                   	leave
801014ae:	c3                   	ret

801014af <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801014af:	f3 0f 1e fb          	endbr32
801014b3:	55                   	push   %ebp
801014b4:	89 e5                	mov    %esp,%ebp
801014b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
801014b9:	8b 55 0c             	mov    0xc(%ebp),%edx
801014bc:	8b 45 08             	mov    0x8(%ebp),%eax
801014bf:	83 ec 08             	sub    $0x8,%esp
801014c2:	52                   	push   %edx
801014c3:	50                   	push   %eax
801014c4:	e8 40 ed ff ff       	call   80100209 <bread>
801014c9:	83 c4 10             	add    $0x10,%esp
801014cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801014cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d2:	83 c0 5c             	add    $0x5c,%eax
801014d5:	83 ec 04             	sub    $0x4,%esp
801014d8:	68 00 02 00 00       	push   $0x200
801014dd:	6a 00                	push   $0x0
801014df:	50                   	push   %eax
801014e0:	e8 6d 38 00 00       	call   80104d52 <memset>
801014e5:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014e8:	83 ec 0c             	sub    $0xc,%esp
801014eb:	ff 75 f4             	push   -0xc(%ebp)
801014ee:	e8 04 1f 00 00       	call   801033f7 <log_write>
801014f3:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014f6:	83 ec 0c             	sub    $0xc,%esp
801014f9:	ff 75 f4             	push   -0xc(%ebp)
801014fc:	e8 92 ed ff ff       	call   80100293 <brelse>
80101501:	83 c4 10             	add    $0x10,%esp
}
80101504:	90                   	nop
80101505:	c9                   	leave
80101506:	c3                   	ret

80101507 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101507:	f3 0f 1e fb          	endbr32
8010150b:	55                   	push   %ebp
8010150c:	89 e5                	mov    %esp,%ebp
8010150e:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101511:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101518:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010151f:	e9 13 01 00 00       	jmp    80101637 <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
80101524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101527:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010152d:	85 c0                	test   %eax,%eax
8010152f:	0f 48 c2             	cmovs  %edx,%eax
80101532:	c1 f8 0c             	sar    $0xc,%eax
80101535:	89 c2                	mov    %eax,%edx
80101537:	a1 78 37 19 80       	mov    0x80193778,%eax
8010153c:	01 d0                	add    %edx,%eax
8010153e:	83 ec 08             	sub    $0x8,%esp
80101541:	50                   	push   %eax
80101542:	ff 75 08             	push   0x8(%ebp)
80101545:	e8 bf ec ff ff       	call   80100209 <bread>
8010154a:	83 c4 10             	add    $0x10,%esp
8010154d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101550:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101557:	e9 a6 00 00 00       	jmp    80101602 <balloc+0xfb>
      m = 1 << (bi % 8);
8010155c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010155f:	99                   	cltd
80101560:	c1 ea 1d             	shr    $0x1d,%edx
80101563:	01 d0                	add    %edx,%eax
80101565:	83 e0 07             	and    $0x7,%eax
80101568:	29 d0                	sub    %edx,%eax
8010156a:	ba 01 00 00 00       	mov    $0x1,%edx
8010156f:	89 c1                	mov    %eax,%ecx
80101571:	d3 e2                	shl    %cl,%edx
80101573:	89 d0                	mov    %edx,%eax
80101575:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101578:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010157b:	8d 50 07             	lea    0x7(%eax),%edx
8010157e:	85 c0                	test   %eax,%eax
80101580:	0f 48 c2             	cmovs  %edx,%eax
80101583:	c1 f8 03             	sar    $0x3,%eax
80101586:	89 c2                	mov    %eax,%edx
80101588:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010158b:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101590:	0f b6 c0             	movzbl %al,%eax
80101593:	23 45 e8             	and    -0x18(%ebp),%eax
80101596:	85 c0                	test   %eax,%eax
80101598:	75 64                	jne    801015fe <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
8010159a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010159d:	8d 50 07             	lea    0x7(%eax),%edx
801015a0:	85 c0                	test   %eax,%eax
801015a2:	0f 48 c2             	cmovs  %edx,%eax
801015a5:	c1 f8 03             	sar    $0x3,%eax
801015a8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015ab:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801015b0:	89 d1                	mov    %edx,%ecx
801015b2:	8b 55 e8             	mov    -0x18(%ebp),%edx
801015b5:	09 ca                	or     %ecx,%edx
801015b7:	89 d1                	mov    %edx,%ecx
801015b9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015bc:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
801015c0:	83 ec 0c             	sub    $0xc,%esp
801015c3:	ff 75 ec             	push   -0x14(%ebp)
801015c6:	e8 2c 1e 00 00       	call   801033f7 <log_write>
801015cb:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801015ce:	83 ec 0c             	sub    $0xc,%esp
801015d1:	ff 75 ec             	push   -0x14(%ebp)
801015d4:	e8 ba ec ff ff       	call   80100293 <brelse>
801015d9:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801015dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e2:	01 c2                	add    %eax,%edx
801015e4:	8b 45 08             	mov    0x8(%ebp),%eax
801015e7:	83 ec 08             	sub    $0x8,%esp
801015ea:	52                   	push   %edx
801015eb:	50                   	push   %eax
801015ec:	e8 be fe ff ff       	call   801014af <bzero>
801015f1:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fa:	01 d0                	add    %edx,%eax
801015fc:	eb 57                	jmp    80101655 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015fe:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101602:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101609:	7f 17                	jg     80101622 <balloc+0x11b>
8010160b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010160e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101611:	01 d0                	add    %edx,%eax
80101613:	89 c2                	mov    %eax,%edx
80101615:	a1 60 37 19 80       	mov    0x80193760,%eax
8010161a:	39 c2                	cmp    %eax,%edx
8010161c:	0f 82 3a ff ff ff    	jb     8010155c <balloc+0x55>
      }
    }
    brelse(bp);
80101622:	83 ec 0c             	sub    $0xc,%esp
80101625:	ff 75 ec             	push   -0x14(%ebp)
80101628:	e8 66 ec ff ff       	call   80100293 <brelse>
8010162d:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101630:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101637:	8b 15 60 37 19 80    	mov    0x80193760,%edx
8010163d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101640:	39 c2                	cmp    %eax,%edx
80101642:	0f 87 dc fe ff ff    	ja     80101524 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
80101648:	83 ec 0c             	sub    $0xc,%esp
8010164b:	68 64 a7 10 80       	push   $0x8010a764
80101650:	e8 70 ef ff ff       	call   801005c5 <panic>
}
80101655:	c9                   	leave
80101656:	c3                   	ret

80101657 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101657:	f3 0f 1e fb          	endbr32
8010165b:	55                   	push   %ebp
8010165c:	89 e5                	mov    %esp,%ebp
8010165e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101661:	83 ec 08             	sub    $0x8,%esp
80101664:	68 60 37 19 80       	push   $0x80193760
80101669:	ff 75 08             	push   0x8(%ebp)
8010166c:	e8 f8 fd ff ff       	call   80101469 <readsb>
80101671:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101674:	8b 45 0c             	mov    0xc(%ebp),%eax
80101677:	c1 e8 0c             	shr    $0xc,%eax
8010167a:	89 c2                	mov    %eax,%edx
8010167c:	a1 78 37 19 80       	mov    0x80193778,%eax
80101681:	01 c2                	add    %eax,%edx
80101683:	8b 45 08             	mov    0x8(%ebp),%eax
80101686:	83 ec 08             	sub    $0x8,%esp
80101689:	52                   	push   %edx
8010168a:	50                   	push   %eax
8010168b:	e8 79 eb ff ff       	call   80100209 <bread>
80101690:	83 c4 10             	add    $0x10,%esp
80101693:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101696:	8b 45 0c             	mov    0xc(%ebp),%eax
80101699:	25 ff 0f 00 00       	and    $0xfff,%eax
8010169e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016a4:	99                   	cltd
801016a5:	c1 ea 1d             	shr    $0x1d,%edx
801016a8:	01 d0                	add    %edx,%eax
801016aa:	83 e0 07             	and    $0x7,%eax
801016ad:	29 d0                	sub    %edx,%eax
801016af:	ba 01 00 00 00       	mov    $0x1,%edx
801016b4:	89 c1                	mov    %eax,%ecx
801016b6:	d3 e2                	shl    %cl,%edx
801016b8:	89 d0                	mov    %edx,%eax
801016ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c0:	8d 50 07             	lea    0x7(%eax),%edx
801016c3:	85 c0                	test   %eax,%eax
801016c5:	0f 48 c2             	cmovs  %edx,%eax
801016c8:	c1 f8 03             	sar    $0x3,%eax
801016cb:	89 c2                	mov    %eax,%edx
801016cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d0:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801016d5:	0f b6 c0             	movzbl %al,%eax
801016d8:	23 45 ec             	and    -0x14(%ebp),%eax
801016db:	85 c0                	test   %eax,%eax
801016dd:	75 0d                	jne    801016ec <bfree+0x95>
    panic("freeing free block");
801016df:	83 ec 0c             	sub    $0xc,%esp
801016e2:	68 7a a7 10 80       	push   $0x8010a77a
801016e7:	e8 d9 ee ff ff       	call   801005c5 <panic>
  bp->data[bi/8] &= ~m;
801016ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ef:	8d 50 07             	lea    0x7(%eax),%edx
801016f2:	85 c0                	test   %eax,%eax
801016f4:	0f 48 c2             	cmovs  %edx,%eax
801016f7:	c1 f8 03             	sar    $0x3,%eax
801016fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016fd:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101702:	89 d1                	mov    %edx,%ecx
80101704:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101707:	f7 d2                	not    %edx
80101709:	21 ca                	and    %ecx,%edx
8010170b:	89 d1                	mov    %edx,%ecx
8010170d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101710:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101714:	83 ec 0c             	sub    $0xc,%esp
80101717:	ff 75 f4             	push   -0xc(%ebp)
8010171a:	e8 d8 1c 00 00       	call   801033f7 <log_write>
8010171f:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101722:	83 ec 0c             	sub    $0xc,%esp
80101725:	ff 75 f4             	push   -0xc(%ebp)
80101728:	e8 66 eb ff ff       	call   80100293 <brelse>
8010172d:	83 c4 10             	add    $0x10,%esp
}
80101730:	90                   	nop
80101731:	c9                   	leave
80101732:	c3                   	ret

80101733 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101733:	f3 0f 1e fb          	endbr32
80101737:	55                   	push   %ebp
80101738:	89 e5                	mov    %esp,%ebp
8010173a:	57                   	push   %edi
8010173b:	56                   	push   %esi
8010173c:	53                   	push   %ebx
8010173d:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101740:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101747:	83 ec 08             	sub    $0x8,%esp
8010174a:	68 8d a7 10 80       	push   $0x8010a78d
8010174f:	68 80 37 19 80       	push   $0x80193780
80101754:	e8 44 33 00 00       	call   80104a9d <initlock>
80101759:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010175c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101763:	eb 2d                	jmp    80101792 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
80101765:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101768:	89 d0                	mov    %edx,%eax
8010176a:	c1 e0 03             	shl    $0x3,%eax
8010176d:	01 d0                	add    %edx,%eax
8010176f:	c1 e0 04             	shl    $0x4,%eax
80101772:	83 c0 30             	add    $0x30,%eax
80101775:	05 80 37 19 80       	add    $0x80193780,%eax
8010177a:	83 c0 10             	add    $0x10,%eax
8010177d:	83 ec 08             	sub    $0x8,%esp
80101780:	68 94 a7 10 80       	push   $0x8010a794
80101785:	50                   	push   %eax
80101786:	e8 a5 31 00 00       	call   80104930 <initsleeplock>
8010178b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010178e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101792:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101796:	7e cd                	jle    80101765 <iinit+0x32>
  }

  readsb(dev, &sb);
80101798:	83 ec 08             	sub    $0x8,%esp
8010179b:	68 60 37 19 80       	push   $0x80193760
801017a0:	ff 75 08             	push   0x8(%ebp)
801017a3:	e8 c1 fc ff ff       	call   80101469 <readsb>
801017a8:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017ab:	a1 78 37 19 80       	mov    0x80193778,%eax
801017b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801017b3:	8b 3d 74 37 19 80    	mov    0x80193774,%edi
801017b9:	8b 35 70 37 19 80    	mov    0x80193770,%esi
801017bf:	8b 1d 6c 37 19 80    	mov    0x8019376c,%ebx
801017c5:	8b 0d 68 37 19 80    	mov    0x80193768,%ecx
801017cb:	8b 15 64 37 19 80    	mov    0x80193764,%edx
801017d1:	a1 60 37 19 80       	mov    0x80193760,%eax
801017d6:	ff 75 d4             	push   -0x2c(%ebp)
801017d9:	57                   	push   %edi
801017da:	56                   	push   %esi
801017db:	53                   	push   %ebx
801017dc:	51                   	push   %ecx
801017dd:	52                   	push   %edx
801017de:	50                   	push   %eax
801017df:	68 9c a7 10 80       	push   $0x8010a79c
801017e4:	e8 23 ec ff ff       	call   8010040c <cprintf>
801017e9:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801017ec:	90                   	nop
801017ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017f0:	5b                   	pop    %ebx
801017f1:	5e                   	pop    %esi
801017f2:	5f                   	pop    %edi
801017f3:	5d                   	pop    %ebp
801017f4:	c3                   	ret

801017f5 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801017f5:	f3 0f 1e fb          	endbr32
801017f9:	55                   	push   %ebp
801017fa:	89 e5                	mov    %esp,%ebp
801017fc:	83 ec 28             	sub    $0x28,%esp
801017ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80101802:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101806:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010180d:	e9 9e 00 00 00       	jmp    801018b0 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
80101812:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101815:	c1 e8 03             	shr    $0x3,%eax
80101818:	89 c2                	mov    %eax,%edx
8010181a:	a1 74 37 19 80       	mov    0x80193774,%eax
8010181f:	01 d0                	add    %edx,%eax
80101821:	83 ec 08             	sub    $0x8,%esp
80101824:	50                   	push   %eax
80101825:	ff 75 08             	push   0x8(%ebp)
80101828:	e8 dc e9 ff ff       	call   80100209 <bread>
8010182d:	83 c4 10             	add    $0x10,%esp
80101830:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101833:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101836:	8d 50 5c             	lea    0x5c(%eax),%edx
80101839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183c:	83 e0 07             	and    $0x7,%eax
8010183f:	c1 e0 06             	shl    $0x6,%eax
80101842:	01 d0                	add    %edx,%eax
80101844:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101847:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010184a:	0f b7 00             	movzwl (%eax),%eax
8010184d:	66 85 c0             	test   %ax,%ax
80101850:	75 4c                	jne    8010189e <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
80101852:	83 ec 04             	sub    $0x4,%esp
80101855:	6a 40                	push   $0x40
80101857:	6a 00                	push   $0x0
80101859:	ff 75 ec             	push   -0x14(%ebp)
8010185c:	e8 f1 34 00 00       	call   80104d52 <memset>
80101861:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101864:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101867:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010186b:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010186e:	83 ec 0c             	sub    $0xc,%esp
80101871:	ff 75 f0             	push   -0x10(%ebp)
80101874:	e8 7e 1b 00 00       	call   801033f7 <log_write>
80101879:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010187c:	83 ec 0c             	sub    $0xc,%esp
8010187f:	ff 75 f0             	push   -0x10(%ebp)
80101882:	e8 0c ea ff ff       	call   80100293 <brelse>
80101887:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010188a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188d:	83 ec 08             	sub    $0x8,%esp
80101890:	50                   	push   %eax
80101891:	ff 75 08             	push   0x8(%ebp)
80101894:	e8 fc 00 00 00       	call   80101995 <iget>
80101899:	83 c4 10             	add    $0x10,%esp
8010189c:	eb 30                	jmp    801018ce <ialloc+0xd9>
    }
    brelse(bp);
8010189e:	83 ec 0c             	sub    $0xc,%esp
801018a1:	ff 75 f0             	push   -0x10(%ebp)
801018a4:	e8 ea e9 ff ff       	call   80100293 <brelse>
801018a9:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801018ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801018b0:	8b 15 68 37 19 80    	mov    0x80193768,%edx
801018b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b9:	39 c2                	cmp    %eax,%edx
801018bb:	0f 87 51 ff ff ff    	ja     80101812 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
801018c1:	83 ec 0c             	sub    $0xc,%esp
801018c4:	68 ef a7 10 80       	push   $0x8010a7ef
801018c9:	e8 f7 ec ff ff       	call   801005c5 <panic>
}
801018ce:	c9                   	leave
801018cf:	c3                   	ret

801018d0 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801018d0:	f3 0f 1e fb          	endbr32
801018d4:	55                   	push   %ebp
801018d5:	89 e5                	mov    %esp,%ebp
801018d7:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018da:	8b 45 08             	mov    0x8(%ebp),%eax
801018dd:	8b 40 04             	mov    0x4(%eax),%eax
801018e0:	c1 e8 03             	shr    $0x3,%eax
801018e3:	89 c2                	mov    %eax,%edx
801018e5:	a1 74 37 19 80       	mov    0x80193774,%eax
801018ea:	01 c2                	add    %eax,%edx
801018ec:	8b 45 08             	mov    0x8(%ebp),%eax
801018ef:	8b 00                	mov    (%eax),%eax
801018f1:	83 ec 08             	sub    $0x8,%esp
801018f4:	52                   	push   %edx
801018f5:	50                   	push   %eax
801018f6:	e8 0e e9 ff ff       	call   80100209 <bread>
801018fb:	83 c4 10             	add    $0x10,%esp
801018fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101904:	8d 50 5c             	lea    0x5c(%eax),%edx
80101907:	8b 45 08             	mov    0x8(%ebp),%eax
8010190a:	8b 40 04             	mov    0x4(%eax),%eax
8010190d:	83 e0 07             	and    $0x7,%eax
80101910:	c1 e0 06             	shl    $0x6,%eax
80101913:	01 d0                	add    %edx,%eax
80101915:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101918:	8b 45 08             	mov    0x8(%ebp),%eax
8010191b:	0f b7 50 50          	movzwl 0x50(%eax),%edx
8010191f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101922:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101925:	8b 45 08             	mov    0x8(%ebp),%eax
80101928:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010192c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010192f:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101933:	8b 45 08             	mov    0x8(%ebp),%eax
80101936:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010193a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193d:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101941:	8b 45 08             	mov    0x8(%ebp),%eax
80101944:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101948:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010194b:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010194f:	8b 45 08             	mov    0x8(%ebp),%eax
80101952:	8b 50 58             	mov    0x58(%eax),%edx
80101955:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101958:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010195b:	8b 45 08             	mov    0x8(%ebp),%eax
8010195e:	8d 50 5c             	lea    0x5c(%eax),%edx
80101961:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101964:	83 c0 0c             	add    $0xc,%eax
80101967:	83 ec 04             	sub    $0x4,%esp
8010196a:	6a 34                	push   $0x34
8010196c:	52                   	push   %edx
8010196d:	50                   	push   %eax
8010196e:	e8 a6 34 00 00       	call   80104e19 <memmove>
80101973:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101976:	83 ec 0c             	sub    $0xc,%esp
80101979:	ff 75 f4             	push   -0xc(%ebp)
8010197c:	e8 76 1a 00 00       	call   801033f7 <log_write>
80101981:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101984:	83 ec 0c             	sub    $0xc,%esp
80101987:	ff 75 f4             	push   -0xc(%ebp)
8010198a:	e8 04 e9 ff ff       	call   80100293 <brelse>
8010198f:	83 c4 10             	add    $0x10,%esp
}
80101992:	90                   	nop
80101993:	c9                   	leave
80101994:	c3                   	ret

80101995 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101995:	f3 0f 1e fb          	endbr32
80101999:	55                   	push   %ebp
8010199a:	89 e5                	mov    %esp,%ebp
8010199c:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010199f:	83 ec 0c             	sub    $0xc,%esp
801019a2:	68 80 37 19 80       	push   $0x80193780
801019a7:	e8 17 31 00 00       	call   80104ac3 <acquire>
801019ac:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801019af:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019b6:	c7 45 f4 b4 37 19 80 	movl   $0x801937b4,-0xc(%ebp)
801019bd:	eb 60                	jmp    80101a1f <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801019bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c2:	8b 40 08             	mov    0x8(%eax),%eax
801019c5:	85 c0                	test   %eax,%eax
801019c7:	7e 39                	jle    80101a02 <iget+0x6d>
801019c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019cc:	8b 00                	mov    (%eax),%eax
801019ce:	39 45 08             	cmp    %eax,0x8(%ebp)
801019d1:	75 2f                	jne    80101a02 <iget+0x6d>
801019d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d6:	8b 40 04             	mov    0x4(%eax),%eax
801019d9:	39 45 0c             	cmp    %eax,0xc(%ebp)
801019dc:	75 24                	jne    80101a02 <iget+0x6d>
      ip->ref++;
801019de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e1:	8b 40 08             	mov    0x8(%eax),%eax
801019e4:	8d 50 01             	lea    0x1(%eax),%edx
801019e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ea:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801019ed:	83 ec 0c             	sub    $0xc,%esp
801019f0:	68 80 37 19 80       	push   $0x80193780
801019f5:	e8 3b 31 00 00       	call   80104b35 <release>
801019fa:	83 c4 10             	add    $0x10,%esp
      return ip;
801019fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a00:	eb 77                	jmp    80101a79 <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a02:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a06:	75 10                	jne    80101a18 <iget+0x83>
80101a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a0b:	8b 40 08             	mov    0x8(%eax),%eax
80101a0e:	85 c0                	test   %eax,%eax
80101a10:	75 06                	jne    80101a18 <iget+0x83>
      empty = ip;
80101a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a15:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a18:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a1f:	81 7d f4 d4 53 19 80 	cmpl   $0x801953d4,-0xc(%ebp)
80101a26:	72 97                	jb     801019bf <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a28:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a2c:	75 0d                	jne    80101a3b <iget+0xa6>
    panic("iget: no inodes");
80101a2e:	83 ec 0c             	sub    $0xc,%esp
80101a31:	68 01 a8 10 80       	push   $0x8010a801
80101a36:	e8 8a eb ff ff       	call   801005c5 <panic>

  ip = empty;
80101a3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a44:	8b 55 08             	mov    0x8(%ebp),%edx
80101a47:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a4f:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a55:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a5f:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a66:	83 ec 0c             	sub    $0xc,%esp
80101a69:	68 80 37 19 80       	push   $0x80193780
80101a6e:	e8 c2 30 00 00       	call   80104b35 <release>
80101a73:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a79:	c9                   	leave
80101a7a:	c3                   	ret

80101a7b <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a7b:	f3 0f 1e fb          	endbr32
80101a7f:	55                   	push   %ebp
80101a80:	89 e5                	mov    %esp,%ebp
80101a82:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a85:	83 ec 0c             	sub    $0xc,%esp
80101a88:	68 80 37 19 80       	push   $0x80193780
80101a8d:	e8 31 30 00 00       	call   80104ac3 <acquire>
80101a92:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a95:	8b 45 08             	mov    0x8(%ebp),%eax
80101a98:	8b 40 08             	mov    0x8(%eax),%eax
80101a9b:	8d 50 01             	lea    0x1(%eax),%edx
80101a9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa1:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101aa4:	83 ec 0c             	sub    $0xc,%esp
80101aa7:	68 80 37 19 80       	push   $0x80193780
80101aac:	e8 84 30 00 00       	call   80104b35 <release>
80101ab1:	83 c4 10             	add    $0x10,%esp
  return ip;
80101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101ab7:	c9                   	leave
80101ab8:	c3                   	ret

80101ab9 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101ab9:	f3 0f 1e fb          	endbr32
80101abd:	55                   	push   %ebp
80101abe:	89 e5                	mov    %esp,%ebp
80101ac0:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101ac3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ac7:	74 0a                	je     80101ad3 <ilock+0x1a>
80101ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80101acc:	8b 40 08             	mov    0x8(%eax),%eax
80101acf:	85 c0                	test   %eax,%eax
80101ad1:	7f 0d                	jg     80101ae0 <ilock+0x27>
    panic("ilock");
80101ad3:	83 ec 0c             	sub    $0xc,%esp
80101ad6:	68 11 a8 10 80       	push   $0x8010a811
80101adb:	e8 e5 ea ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101ae0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae3:	83 c0 0c             	add    $0xc,%eax
80101ae6:	83 ec 0c             	sub    $0xc,%esp
80101ae9:	50                   	push   %eax
80101aea:	e8 81 2e 00 00       	call   80104970 <acquiresleep>
80101aef:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101af2:	8b 45 08             	mov    0x8(%ebp),%eax
80101af5:	8b 40 4c             	mov    0x4c(%eax),%eax
80101af8:	85 c0                	test   %eax,%eax
80101afa:	0f 85 cd 00 00 00    	jne    80101bcd <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b00:	8b 45 08             	mov    0x8(%ebp),%eax
80101b03:	8b 40 04             	mov    0x4(%eax),%eax
80101b06:	c1 e8 03             	shr    $0x3,%eax
80101b09:	89 c2                	mov    %eax,%edx
80101b0b:	a1 74 37 19 80       	mov    0x80193774,%eax
80101b10:	01 c2                	add    %eax,%edx
80101b12:	8b 45 08             	mov    0x8(%ebp),%eax
80101b15:	8b 00                	mov    (%eax),%eax
80101b17:	83 ec 08             	sub    $0x8,%esp
80101b1a:	52                   	push   %edx
80101b1b:	50                   	push   %eax
80101b1c:	e8 e8 e6 ff ff       	call   80100209 <bread>
80101b21:	83 c4 10             	add    $0x10,%esp
80101b24:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b2a:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b30:	8b 40 04             	mov    0x4(%eax),%eax
80101b33:	83 e0 07             	and    $0x7,%eax
80101b36:	c1 e0 06             	shl    $0x6,%eax
80101b39:	01 d0                	add    %edx,%eax
80101b3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b41:	0f b7 10             	movzwl (%eax),%edx
80101b44:	8b 45 08             	mov    0x8(%ebp),%eax
80101b47:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b4e:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b52:	8b 45 08             	mov    0x8(%ebp),%eax
80101b55:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b5c:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b60:	8b 45 08             	mov    0x8(%ebp),%eax
80101b63:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b6a:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b71:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b78:	8b 50 08             	mov    0x8(%eax),%edx
80101b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7e:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b84:	8d 50 0c             	lea    0xc(%eax),%edx
80101b87:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8a:	83 c0 5c             	add    $0x5c,%eax
80101b8d:	83 ec 04             	sub    $0x4,%esp
80101b90:	6a 34                	push   $0x34
80101b92:	52                   	push   %edx
80101b93:	50                   	push   %eax
80101b94:	e8 80 32 00 00       	call   80104e19 <memmove>
80101b99:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b9c:	83 ec 0c             	sub    $0xc,%esp
80101b9f:	ff 75 f4             	push   -0xc(%ebp)
80101ba2:	e8 ec e6 ff ff       	call   80100293 <brelse>
80101ba7:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101baa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bad:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101bbb:	66 85 c0             	test   %ax,%ax
80101bbe:	75 0d                	jne    80101bcd <ilock+0x114>
      panic("ilock: no type");
80101bc0:	83 ec 0c             	sub    $0xc,%esp
80101bc3:	68 17 a8 10 80       	push   $0x8010a817
80101bc8:	e8 f8 e9 ff ff       	call   801005c5 <panic>
  }
}
80101bcd:	90                   	nop
80101bce:	c9                   	leave
80101bcf:	c3                   	ret

80101bd0 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101bd0:	f3 0f 1e fb          	endbr32
80101bd4:	55                   	push   %ebp
80101bd5:	89 e5                	mov    %esp,%ebp
80101bd7:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101bda:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bde:	74 20                	je     80101c00 <iunlock+0x30>
80101be0:	8b 45 08             	mov    0x8(%ebp),%eax
80101be3:	83 c0 0c             	add    $0xc,%eax
80101be6:	83 ec 0c             	sub    $0xc,%esp
80101be9:	50                   	push   %eax
80101bea:	e8 3b 2e 00 00       	call   80104a2a <holdingsleep>
80101bef:	83 c4 10             	add    $0x10,%esp
80101bf2:	85 c0                	test   %eax,%eax
80101bf4:	74 0a                	je     80101c00 <iunlock+0x30>
80101bf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf9:	8b 40 08             	mov    0x8(%eax),%eax
80101bfc:	85 c0                	test   %eax,%eax
80101bfe:	7f 0d                	jg     80101c0d <iunlock+0x3d>
    panic("iunlock");
80101c00:	83 ec 0c             	sub    $0xc,%esp
80101c03:	68 26 a8 10 80       	push   $0x8010a826
80101c08:	e8 b8 e9 ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c10:	83 c0 0c             	add    $0xc,%eax
80101c13:	83 ec 0c             	sub    $0xc,%esp
80101c16:	50                   	push   %eax
80101c17:	e8 bc 2d 00 00       	call   801049d8 <releasesleep>
80101c1c:	83 c4 10             	add    $0x10,%esp
}
80101c1f:	90                   	nop
80101c20:	c9                   	leave
80101c21:	c3                   	ret

80101c22 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c22:	f3 0f 1e fb          	endbr32
80101c26:	55                   	push   %ebp
80101c27:	89 e5                	mov    %esp,%ebp
80101c29:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101c2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2f:	83 c0 0c             	add    $0xc,%eax
80101c32:	83 ec 0c             	sub    $0xc,%esp
80101c35:	50                   	push   %eax
80101c36:	e8 35 2d 00 00       	call   80104970 <acquiresleep>
80101c3b:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c41:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c44:	85 c0                	test   %eax,%eax
80101c46:	74 6a                	je     80101cb2 <iput+0x90>
80101c48:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c4f:	66 85 c0             	test   %ax,%ax
80101c52:	75 5e                	jne    80101cb2 <iput+0x90>
    acquire(&icache.lock);
80101c54:	83 ec 0c             	sub    $0xc,%esp
80101c57:	68 80 37 19 80       	push   $0x80193780
80101c5c:	e8 62 2e 00 00       	call   80104ac3 <acquire>
80101c61:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c64:	8b 45 08             	mov    0x8(%ebp),%eax
80101c67:	8b 40 08             	mov    0x8(%eax),%eax
80101c6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c6d:	83 ec 0c             	sub    $0xc,%esp
80101c70:	68 80 37 19 80       	push   $0x80193780
80101c75:	e8 bb 2e 00 00       	call   80104b35 <release>
80101c7a:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c7d:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c81:	75 2f                	jne    80101cb2 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c83:	83 ec 0c             	sub    $0xc,%esp
80101c86:	ff 75 08             	push   0x8(%ebp)
80101c89:	e8 b5 01 00 00       	call   80101e43 <itrunc>
80101c8e:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101c91:	8b 45 08             	mov    0x8(%ebp),%eax
80101c94:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c9a:	83 ec 0c             	sub    $0xc,%esp
80101c9d:	ff 75 08             	push   0x8(%ebp)
80101ca0:	e8 2b fc ff ff       	call   801018d0 <iupdate>
80101ca5:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101ca8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cab:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101cb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb5:	83 c0 0c             	add    $0xc,%eax
80101cb8:	83 ec 0c             	sub    $0xc,%esp
80101cbb:	50                   	push   %eax
80101cbc:	e8 17 2d 00 00       	call   801049d8 <releasesleep>
80101cc1:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101cc4:	83 ec 0c             	sub    $0xc,%esp
80101cc7:	68 80 37 19 80       	push   $0x80193780
80101ccc:	e8 f2 2d 00 00       	call   80104ac3 <acquire>
80101cd1:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd7:	8b 40 08             	mov    0x8(%eax),%eax
80101cda:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ce3:	83 ec 0c             	sub    $0xc,%esp
80101ce6:	68 80 37 19 80       	push   $0x80193780
80101ceb:	e8 45 2e 00 00       	call   80104b35 <release>
80101cf0:	83 c4 10             	add    $0x10,%esp
}
80101cf3:	90                   	nop
80101cf4:	c9                   	leave
80101cf5:	c3                   	ret

80101cf6 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cf6:	f3 0f 1e fb          	endbr32
80101cfa:	55                   	push   %ebp
80101cfb:	89 e5                	mov    %esp,%ebp
80101cfd:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101d00:	83 ec 0c             	sub    $0xc,%esp
80101d03:	ff 75 08             	push   0x8(%ebp)
80101d06:	e8 c5 fe ff ff       	call   80101bd0 <iunlock>
80101d0b:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101d0e:	83 ec 0c             	sub    $0xc,%esp
80101d11:	ff 75 08             	push   0x8(%ebp)
80101d14:	e8 09 ff ff ff       	call   80101c22 <iput>
80101d19:	83 c4 10             	add    $0x10,%esp
}
80101d1c:	90                   	nop
80101d1d:	c9                   	leave
80101d1e:	c3                   	ret

80101d1f <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d1f:	f3 0f 1e fb          	endbr32
80101d23:	55                   	push   %ebp
80101d24:	89 e5                	mov    %esp,%ebp
80101d26:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d29:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d2d:	77 42                	ja     80101d71 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d32:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d35:	83 c2 14             	add    $0x14,%edx
80101d38:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d3f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d43:	75 24                	jne    80101d69 <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d45:	8b 45 08             	mov    0x8(%ebp),%eax
80101d48:	8b 00                	mov    (%eax),%eax
80101d4a:	83 ec 0c             	sub    $0xc,%esp
80101d4d:	50                   	push   %eax
80101d4e:	e8 b4 f7 ff ff       	call   80101507 <balloc>
80101d53:	83 c4 10             	add    $0x10,%esp
80101d56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d59:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d5f:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d62:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d65:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d6c:	e9 d0 00 00 00       	jmp    80101e41 <bmap+0x122>
  }
  bn -= NDIRECT;
80101d71:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d75:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d79:	0f 87 b5 00 00 00    	ja     80101e34 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d82:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d88:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d8b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d8f:	75 20                	jne    80101db1 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d91:	8b 45 08             	mov    0x8(%ebp),%eax
80101d94:	8b 00                	mov    (%eax),%eax
80101d96:	83 ec 0c             	sub    $0xc,%esp
80101d99:	50                   	push   %eax
80101d9a:	e8 68 f7 ff ff       	call   80101507 <balloc>
80101d9f:	83 c4 10             	add    $0x10,%esp
80101da2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101da5:	8b 45 08             	mov    0x8(%ebp),%eax
80101da8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dab:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101db1:	8b 45 08             	mov    0x8(%ebp),%eax
80101db4:	8b 00                	mov    (%eax),%eax
80101db6:	83 ec 08             	sub    $0x8,%esp
80101db9:	ff 75 f4             	push   -0xc(%ebp)
80101dbc:	50                   	push   %eax
80101dbd:	e8 47 e4 ff ff       	call   80100209 <bread>
80101dc2:	83 c4 10             	add    $0x10,%esp
80101dc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101dc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dcb:	83 c0 5c             	add    $0x5c,%eax
80101dce:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dd4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ddb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dde:	01 d0                	add    %edx,%eax
80101de0:	8b 00                	mov    (%eax),%eax
80101de2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101de5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101de9:	75 36                	jne    80101e21 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101deb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dee:	8b 00                	mov    (%eax),%eax
80101df0:	83 ec 0c             	sub    $0xc,%esp
80101df3:	50                   	push   %eax
80101df4:	e8 0e f7 ff ff       	call   80101507 <balloc>
80101df9:	83 c4 10             	add    $0x10,%esp
80101dfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dff:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e02:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e09:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e0c:	01 c2                	add    %eax,%edx
80101e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e11:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101e13:	83 ec 0c             	sub    $0xc,%esp
80101e16:	ff 75 f0             	push   -0x10(%ebp)
80101e19:	e8 d9 15 00 00       	call   801033f7 <log_write>
80101e1e:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e21:	83 ec 0c             	sub    $0xc,%esp
80101e24:	ff 75 f0             	push   -0x10(%ebp)
80101e27:	e8 67 e4 ff ff       	call   80100293 <brelse>
80101e2c:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e32:	eb 0d                	jmp    80101e41 <bmap+0x122>
  }

  panic("bmap: out of range");
80101e34:	83 ec 0c             	sub    $0xc,%esp
80101e37:	68 2e a8 10 80       	push   $0x8010a82e
80101e3c:	e8 84 e7 ff ff       	call   801005c5 <panic>
}
80101e41:	c9                   	leave
80101e42:	c3                   	ret

80101e43 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e43:	f3 0f 1e fb          	endbr32
80101e47:	55                   	push   %ebp
80101e48:	89 e5                	mov    %esp,%ebp
80101e4a:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e54:	eb 45                	jmp    80101e9b <itrunc+0x58>
    if(ip->addrs[i]){
80101e56:	8b 45 08             	mov    0x8(%ebp),%eax
80101e59:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e5c:	83 c2 14             	add    $0x14,%edx
80101e5f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e63:	85 c0                	test   %eax,%eax
80101e65:	74 30                	je     80101e97 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101e67:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e6d:	83 c2 14             	add    $0x14,%edx
80101e70:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e74:	8b 55 08             	mov    0x8(%ebp),%edx
80101e77:	8b 12                	mov    (%edx),%edx
80101e79:	83 ec 08             	sub    $0x8,%esp
80101e7c:	50                   	push   %eax
80101e7d:	52                   	push   %edx
80101e7e:	e8 d4 f7 ff ff       	call   80101657 <bfree>
80101e83:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e86:	8b 45 08             	mov    0x8(%ebp),%eax
80101e89:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e8c:	83 c2 14             	add    $0x14,%edx
80101e8f:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e96:	00 
  for(i = 0; i < NDIRECT; i++){
80101e97:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e9b:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e9f:	7e b5                	jle    80101e56 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea4:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101eaa:	85 c0                	test   %eax,%eax
80101eac:	0f 84 aa 00 00 00    	je     80101f5c <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101eb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb5:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebe:	8b 00                	mov    (%eax),%eax
80101ec0:	83 ec 08             	sub    $0x8,%esp
80101ec3:	52                   	push   %edx
80101ec4:	50                   	push   %eax
80101ec5:	e8 3f e3 ff ff       	call   80100209 <bread>
80101eca:	83 c4 10             	add    $0x10,%esp
80101ecd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101ed0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ed3:	83 c0 5c             	add    $0x5c,%eax
80101ed6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ed9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ee0:	eb 3c                	jmp    80101f1e <itrunc+0xdb>
      if(a[j])
80101ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ee5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eec:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eef:	01 d0                	add    %edx,%eax
80101ef1:	8b 00                	mov    (%eax),%eax
80101ef3:	85 c0                	test   %eax,%eax
80101ef5:	74 23                	je     80101f1a <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101efa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f01:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f04:	01 d0                	add    %edx,%eax
80101f06:	8b 00                	mov    (%eax),%eax
80101f08:	8b 55 08             	mov    0x8(%ebp),%edx
80101f0b:	8b 12                	mov    (%edx),%edx
80101f0d:	83 ec 08             	sub    $0x8,%esp
80101f10:	50                   	push   %eax
80101f11:	52                   	push   %edx
80101f12:	e8 40 f7 ff ff       	call   80101657 <bfree>
80101f17:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101f1a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f21:	83 f8 7f             	cmp    $0x7f,%eax
80101f24:	76 bc                	jbe    80101ee2 <itrunc+0x9f>
    }
    brelse(bp);
80101f26:	83 ec 0c             	sub    $0xc,%esp
80101f29:	ff 75 ec             	push   -0x14(%ebp)
80101f2c:	e8 62 e3 ff ff       	call   80100293 <brelse>
80101f31:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f34:	8b 45 08             	mov    0x8(%ebp),%eax
80101f37:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f3d:	8b 55 08             	mov    0x8(%ebp),%edx
80101f40:	8b 12                	mov    (%edx),%edx
80101f42:	83 ec 08             	sub    $0x8,%esp
80101f45:	50                   	push   %eax
80101f46:	52                   	push   %edx
80101f47:	e8 0b f7 ff ff       	call   80101657 <bfree>
80101f4c:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f52:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f59:	00 00 00 
  }

  ip->size = 0;
80101f5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5f:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f66:	83 ec 0c             	sub    $0xc,%esp
80101f69:	ff 75 08             	push   0x8(%ebp)
80101f6c:	e8 5f f9 ff ff       	call   801018d0 <iupdate>
80101f71:	83 c4 10             	add    $0x10,%esp
}
80101f74:	90                   	nop
80101f75:	c9                   	leave
80101f76:	c3                   	ret

80101f77 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f77:	f3 0f 1e fb          	endbr32
80101f7b:	55                   	push   %ebp
80101f7c:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f81:	8b 00                	mov    (%eax),%eax
80101f83:	89 c2                	mov    %eax,%edx
80101f85:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f88:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8e:	8b 50 04             	mov    0x4(%eax),%edx
80101f91:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f94:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f97:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9a:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101f9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fa1:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa7:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101fab:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fae:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101fb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb5:	8b 50 58             	mov    0x58(%eax),%edx
80101fb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fbb:	89 50 10             	mov    %edx,0x10(%eax)
}
80101fbe:	90                   	nop
80101fbf:	5d                   	pop    %ebp
80101fc0:	c3                   	ret

80101fc1 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101fc1:	f3 0f 1e fb          	endbr32
80101fc5:	55                   	push   %ebp
80101fc6:	89 e5                	mov    %esp,%ebp
80101fc8:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fce:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101fd2:	66 83 f8 03          	cmp    $0x3,%ax
80101fd6:	75 5c                	jne    80102034 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101fd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101fdb:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fdf:	66 85 c0             	test   %ax,%ax
80101fe2:	78 20                	js     80102004 <readi+0x43>
80101fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101feb:	66 83 f8 09          	cmp    $0x9,%ax
80101fef:	7f 13                	jg     80102004 <readi+0x43>
80101ff1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ff8:	98                   	cwtl
80101ff9:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80102000:	85 c0                	test   %eax,%eax
80102002:	75 0a                	jne    8010200e <readi+0x4d>
      return -1;
80102004:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102009:	e9 0a 01 00 00       	jmp    80102118 <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
8010200e:	8b 45 08             	mov    0x8(%ebp),%eax
80102011:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102015:	98                   	cwtl
80102016:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
8010201d:	8b 55 14             	mov    0x14(%ebp),%edx
80102020:	83 ec 04             	sub    $0x4,%esp
80102023:	52                   	push   %edx
80102024:	ff 75 0c             	push   0xc(%ebp)
80102027:	ff 75 08             	push   0x8(%ebp)
8010202a:	ff d0                	call   *%eax
8010202c:	83 c4 10             	add    $0x10,%esp
8010202f:	e9 e4 00 00 00       	jmp    80102118 <readi+0x157>
  }

  if(off > ip->size || off + n < off)
80102034:	8b 45 08             	mov    0x8(%ebp),%eax
80102037:	8b 40 58             	mov    0x58(%eax),%eax
8010203a:	39 45 10             	cmp    %eax,0x10(%ebp)
8010203d:	77 0d                	ja     8010204c <readi+0x8b>
8010203f:	8b 55 10             	mov    0x10(%ebp),%edx
80102042:	8b 45 14             	mov    0x14(%ebp),%eax
80102045:	01 d0                	add    %edx,%eax
80102047:	39 45 10             	cmp    %eax,0x10(%ebp)
8010204a:	76 0a                	jbe    80102056 <readi+0x95>
    return -1;
8010204c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102051:	e9 c2 00 00 00       	jmp    80102118 <readi+0x157>
  if(off + n > ip->size)
80102056:	8b 55 10             	mov    0x10(%ebp),%edx
80102059:	8b 45 14             	mov    0x14(%ebp),%eax
8010205c:	01 c2                	add    %eax,%edx
8010205e:	8b 45 08             	mov    0x8(%ebp),%eax
80102061:	8b 40 58             	mov    0x58(%eax),%eax
80102064:	39 c2                	cmp    %eax,%edx
80102066:	76 0c                	jbe    80102074 <readi+0xb3>
    n = ip->size - off;
80102068:	8b 45 08             	mov    0x8(%ebp),%eax
8010206b:	8b 40 58             	mov    0x58(%eax),%eax
8010206e:	2b 45 10             	sub    0x10(%ebp),%eax
80102071:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102074:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010207b:	e9 89 00 00 00       	jmp    80102109 <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102080:	8b 45 10             	mov    0x10(%ebp),%eax
80102083:	c1 e8 09             	shr    $0x9,%eax
80102086:	83 ec 08             	sub    $0x8,%esp
80102089:	50                   	push   %eax
8010208a:	ff 75 08             	push   0x8(%ebp)
8010208d:	e8 8d fc ff ff       	call   80101d1f <bmap>
80102092:	83 c4 10             	add    $0x10,%esp
80102095:	8b 55 08             	mov    0x8(%ebp),%edx
80102098:	8b 12                	mov    (%edx),%edx
8010209a:	83 ec 08             	sub    $0x8,%esp
8010209d:	50                   	push   %eax
8010209e:	52                   	push   %edx
8010209f:	e8 65 e1 ff ff       	call   80100209 <bread>
801020a4:	83 c4 10             	add    $0x10,%esp
801020a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020aa:	8b 45 10             	mov    0x10(%ebp),%eax
801020ad:	25 ff 01 00 00       	and    $0x1ff,%eax
801020b2:	ba 00 02 00 00       	mov    $0x200,%edx
801020b7:	29 c2                	sub    %eax,%edx
801020b9:	8b 45 14             	mov    0x14(%ebp),%eax
801020bc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801020bf:	39 c2                	cmp    %eax,%edx
801020c1:	0f 46 c2             	cmovbe %edx,%eax
801020c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801020c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020ca:	8d 50 5c             	lea    0x5c(%eax),%edx
801020cd:	8b 45 10             	mov    0x10(%ebp),%eax
801020d0:	25 ff 01 00 00       	and    $0x1ff,%eax
801020d5:	01 d0                	add    %edx,%eax
801020d7:	83 ec 04             	sub    $0x4,%esp
801020da:	ff 75 ec             	push   -0x14(%ebp)
801020dd:	50                   	push   %eax
801020de:	ff 75 0c             	push   0xc(%ebp)
801020e1:	e8 33 2d 00 00       	call   80104e19 <memmove>
801020e6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020e9:	83 ec 0c             	sub    $0xc,%esp
801020ec:	ff 75 f0             	push   -0x10(%ebp)
801020ef:	e8 9f e1 ff ff       	call   80100293 <brelse>
801020f4:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020fa:	01 45 f4             	add    %eax,-0xc(%ebp)
801020fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102100:	01 45 10             	add    %eax,0x10(%ebp)
80102103:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102106:	01 45 0c             	add    %eax,0xc(%ebp)
80102109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010210c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010210f:	0f 82 6b ff ff ff    	jb     80102080 <readi+0xbf>
  }
  return n;
80102115:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102118:	c9                   	leave
80102119:	c3                   	ret

8010211a <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010211a:	f3 0f 1e fb          	endbr32
8010211e:	55                   	push   %ebp
8010211f:	89 e5                	mov    %esp,%ebp
80102121:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102124:	8b 45 08             	mov    0x8(%ebp),%eax
80102127:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010212b:	66 83 f8 03          	cmp    $0x3,%ax
8010212f:	75 5c                	jne    8010218d <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102131:	8b 45 08             	mov    0x8(%ebp),%eax
80102134:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102138:	66 85 c0             	test   %ax,%ax
8010213b:	78 20                	js     8010215d <writei+0x43>
8010213d:	8b 45 08             	mov    0x8(%ebp),%eax
80102140:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102144:	66 83 f8 09          	cmp    $0x9,%ax
80102148:	7f 13                	jg     8010215d <writei+0x43>
8010214a:	8b 45 08             	mov    0x8(%ebp),%eax
8010214d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102151:	98                   	cwtl
80102152:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
80102159:	85 c0                	test   %eax,%eax
8010215b:	75 0a                	jne    80102167 <writei+0x4d>
      return -1;
8010215d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102162:	e9 3b 01 00 00       	jmp    801022a2 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
80102167:	8b 45 08             	mov    0x8(%ebp),%eax
8010216a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010216e:	98                   	cwtl
8010216f:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
80102176:	8b 55 14             	mov    0x14(%ebp),%edx
80102179:	83 ec 04             	sub    $0x4,%esp
8010217c:	52                   	push   %edx
8010217d:	ff 75 0c             	push   0xc(%ebp)
80102180:	ff 75 08             	push   0x8(%ebp)
80102183:	ff d0                	call   *%eax
80102185:	83 c4 10             	add    $0x10,%esp
80102188:	e9 15 01 00 00       	jmp    801022a2 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
8010218d:	8b 45 08             	mov    0x8(%ebp),%eax
80102190:	8b 40 58             	mov    0x58(%eax),%eax
80102193:	39 45 10             	cmp    %eax,0x10(%ebp)
80102196:	77 0d                	ja     801021a5 <writei+0x8b>
80102198:	8b 55 10             	mov    0x10(%ebp),%edx
8010219b:	8b 45 14             	mov    0x14(%ebp),%eax
8010219e:	01 d0                	add    %edx,%eax
801021a0:	39 45 10             	cmp    %eax,0x10(%ebp)
801021a3:	76 0a                	jbe    801021af <writei+0x95>
    return -1;
801021a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021aa:	e9 f3 00 00 00       	jmp    801022a2 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
801021af:	8b 55 10             	mov    0x10(%ebp),%edx
801021b2:	8b 45 14             	mov    0x14(%ebp),%eax
801021b5:	01 d0                	add    %edx,%eax
801021b7:	3d 00 18 01 00       	cmp    $0x11800,%eax
801021bc:	76 0a                	jbe    801021c8 <writei+0xae>
    return -1;
801021be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021c3:	e9 da 00 00 00       	jmp    801022a2 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021cf:	e9 97 00 00 00       	jmp    8010226b <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801021d4:	8b 45 10             	mov    0x10(%ebp),%eax
801021d7:	c1 e8 09             	shr    $0x9,%eax
801021da:	83 ec 08             	sub    $0x8,%esp
801021dd:	50                   	push   %eax
801021de:	ff 75 08             	push   0x8(%ebp)
801021e1:	e8 39 fb ff ff       	call   80101d1f <bmap>
801021e6:	83 c4 10             	add    $0x10,%esp
801021e9:	8b 55 08             	mov    0x8(%ebp),%edx
801021ec:	8b 12                	mov    (%edx),%edx
801021ee:	83 ec 08             	sub    $0x8,%esp
801021f1:	50                   	push   %eax
801021f2:	52                   	push   %edx
801021f3:	e8 11 e0 ff ff       	call   80100209 <bread>
801021f8:	83 c4 10             	add    $0x10,%esp
801021fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021fe:	8b 45 10             	mov    0x10(%ebp),%eax
80102201:	25 ff 01 00 00       	and    $0x1ff,%eax
80102206:	ba 00 02 00 00       	mov    $0x200,%edx
8010220b:	29 c2                	sub    %eax,%edx
8010220d:	8b 45 14             	mov    0x14(%ebp),%eax
80102210:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102213:	39 c2                	cmp    %eax,%edx
80102215:	0f 46 c2             	cmovbe %edx,%eax
80102218:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010221b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010221e:	8d 50 5c             	lea    0x5c(%eax),%edx
80102221:	8b 45 10             	mov    0x10(%ebp),%eax
80102224:	25 ff 01 00 00       	and    $0x1ff,%eax
80102229:	01 d0                	add    %edx,%eax
8010222b:	83 ec 04             	sub    $0x4,%esp
8010222e:	ff 75 ec             	push   -0x14(%ebp)
80102231:	ff 75 0c             	push   0xc(%ebp)
80102234:	50                   	push   %eax
80102235:	e8 df 2b 00 00       	call   80104e19 <memmove>
8010223a:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010223d:	83 ec 0c             	sub    $0xc,%esp
80102240:	ff 75 f0             	push   -0x10(%ebp)
80102243:	e8 af 11 00 00       	call   801033f7 <log_write>
80102248:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010224b:	83 ec 0c             	sub    $0xc,%esp
8010224e:	ff 75 f0             	push   -0x10(%ebp)
80102251:	e8 3d e0 ff ff       	call   80100293 <brelse>
80102256:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102259:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010225c:	01 45 f4             	add    %eax,-0xc(%ebp)
8010225f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102262:	01 45 10             	add    %eax,0x10(%ebp)
80102265:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102268:	01 45 0c             	add    %eax,0xc(%ebp)
8010226b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010226e:	3b 45 14             	cmp    0x14(%ebp),%eax
80102271:	0f 82 5d ff ff ff    	jb     801021d4 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
80102277:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010227b:	74 22                	je     8010229f <writei+0x185>
8010227d:	8b 45 08             	mov    0x8(%ebp),%eax
80102280:	8b 40 58             	mov    0x58(%eax),%eax
80102283:	39 45 10             	cmp    %eax,0x10(%ebp)
80102286:	76 17                	jbe    8010229f <writei+0x185>
    ip->size = off;
80102288:	8b 45 08             	mov    0x8(%ebp),%eax
8010228b:	8b 55 10             	mov    0x10(%ebp),%edx
8010228e:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102291:	83 ec 0c             	sub    $0xc,%esp
80102294:	ff 75 08             	push   0x8(%ebp)
80102297:	e8 34 f6 ff ff       	call   801018d0 <iupdate>
8010229c:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010229f:	8b 45 14             	mov    0x14(%ebp),%eax
}
801022a2:	c9                   	leave
801022a3:	c3                   	ret

801022a4 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801022a4:	f3 0f 1e fb          	endbr32
801022a8:	55                   	push   %ebp
801022a9:	89 e5                	mov    %esp,%ebp
801022ab:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801022ae:	83 ec 04             	sub    $0x4,%esp
801022b1:	6a 0e                	push   $0xe
801022b3:	ff 75 0c             	push   0xc(%ebp)
801022b6:	ff 75 08             	push   0x8(%ebp)
801022b9:	e8 f9 2b 00 00       	call   80104eb7 <strncmp>
801022be:	83 c4 10             	add    $0x10,%esp
}
801022c1:	c9                   	leave
801022c2:	c3                   	ret

801022c3 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801022c3:	f3 0f 1e fb          	endbr32
801022c7:	55                   	push   %ebp
801022c8:	89 e5                	mov    %esp,%ebp
801022ca:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801022cd:	8b 45 08             	mov    0x8(%ebp),%eax
801022d0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801022d4:	66 83 f8 01          	cmp    $0x1,%ax
801022d8:	74 0d                	je     801022e7 <dirlookup+0x24>
    panic("dirlookup not DIR");
801022da:	83 ec 0c             	sub    $0xc,%esp
801022dd:	68 41 a8 10 80       	push   $0x8010a841
801022e2:	e8 de e2 ff ff       	call   801005c5 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022ee:	eb 7b                	jmp    8010236b <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022f0:	6a 10                	push   $0x10
801022f2:	ff 75 f4             	push   -0xc(%ebp)
801022f5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022f8:	50                   	push   %eax
801022f9:	ff 75 08             	push   0x8(%ebp)
801022fc:	e8 c0 fc ff ff       	call   80101fc1 <readi>
80102301:	83 c4 10             	add    $0x10,%esp
80102304:	83 f8 10             	cmp    $0x10,%eax
80102307:	74 0d                	je     80102316 <dirlookup+0x53>
      panic("dirlookup read");
80102309:	83 ec 0c             	sub    $0xc,%esp
8010230c:	68 53 a8 10 80       	push   $0x8010a853
80102311:	e8 af e2 ff ff       	call   801005c5 <panic>
    if(de.inum == 0)
80102316:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010231a:	66 85 c0             	test   %ax,%ax
8010231d:	74 47                	je     80102366 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
8010231f:	83 ec 08             	sub    $0x8,%esp
80102322:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102325:	83 c0 02             	add    $0x2,%eax
80102328:	50                   	push   %eax
80102329:	ff 75 0c             	push   0xc(%ebp)
8010232c:	e8 73 ff ff ff       	call   801022a4 <namecmp>
80102331:	83 c4 10             	add    $0x10,%esp
80102334:	85 c0                	test   %eax,%eax
80102336:	75 2f                	jne    80102367 <dirlookup+0xa4>
      // entry matches path element
      if(poff)
80102338:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010233c:	74 08                	je     80102346 <dirlookup+0x83>
        *poff = off;
8010233e:	8b 45 10             	mov    0x10(%ebp),%eax
80102341:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102344:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102346:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010234a:	0f b7 c0             	movzwl %ax,%eax
8010234d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102350:	8b 45 08             	mov    0x8(%ebp),%eax
80102353:	8b 00                	mov    (%eax),%eax
80102355:	83 ec 08             	sub    $0x8,%esp
80102358:	ff 75 f0             	push   -0x10(%ebp)
8010235b:	50                   	push   %eax
8010235c:	e8 34 f6 ff ff       	call   80101995 <iget>
80102361:	83 c4 10             	add    $0x10,%esp
80102364:	eb 19                	jmp    8010237f <dirlookup+0xbc>
      continue;
80102366:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102367:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010236b:	8b 45 08             	mov    0x8(%ebp),%eax
8010236e:	8b 40 58             	mov    0x58(%eax),%eax
80102371:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102374:	0f 82 76 ff ff ff    	jb     801022f0 <dirlookup+0x2d>
    }
  }

  return 0;
8010237a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010237f:	c9                   	leave
80102380:	c3                   	ret

80102381 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102381:	f3 0f 1e fb          	endbr32
80102385:	55                   	push   %ebp
80102386:	89 e5                	mov    %esp,%ebp
80102388:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010238b:	83 ec 04             	sub    $0x4,%esp
8010238e:	6a 00                	push   $0x0
80102390:	ff 75 0c             	push   0xc(%ebp)
80102393:	ff 75 08             	push   0x8(%ebp)
80102396:	e8 28 ff ff ff       	call   801022c3 <dirlookup>
8010239b:	83 c4 10             	add    $0x10,%esp
8010239e:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023a5:	74 18                	je     801023bf <dirlink+0x3e>
    iput(ip);
801023a7:	83 ec 0c             	sub    $0xc,%esp
801023aa:	ff 75 f0             	push   -0x10(%ebp)
801023ad:	e8 70 f8 ff ff       	call   80101c22 <iput>
801023b2:	83 c4 10             	add    $0x10,%esp
    return -1;
801023b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023ba:	e9 9c 00 00 00       	jmp    8010245b <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023c6:	eb 39                	jmp    80102401 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023cb:	6a 10                	push   $0x10
801023cd:	50                   	push   %eax
801023ce:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023d1:	50                   	push   %eax
801023d2:	ff 75 08             	push   0x8(%ebp)
801023d5:	e8 e7 fb ff ff       	call   80101fc1 <readi>
801023da:	83 c4 10             	add    $0x10,%esp
801023dd:	83 f8 10             	cmp    $0x10,%eax
801023e0:	74 0d                	je     801023ef <dirlink+0x6e>
      panic("dirlink read");
801023e2:	83 ec 0c             	sub    $0xc,%esp
801023e5:	68 62 a8 10 80       	push   $0x8010a862
801023ea:	e8 d6 e1 ff ff       	call   801005c5 <panic>
    if(de.inum == 0)
801023ef:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023f3:	66 85 c0             	test   %ax,%ax
801023f6:	74 18                	je     80102410 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
801023f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023fb:	83 c0 10             	add    $0x10,%eax
801023fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102401:	8b 45 08             	mov    0x8(%ebp),%eax
80102404:	8b 50 58             	mov    0x58(%eax),%edx
80102407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010240a:	39 c2                	cmp    %eax,%edx
8010240c:	77 ba                	ja     801023c8 <dirlink+0x47>
8010240e:	eb 01                	jmp    80102411 <dirlink+0x90>
      break;
80102410:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102411:	83 ec 04             	sub    $0x4,%esp
80102414:	6a 0e                	push   $0xe
80102416:	ff 75 0c             	push   0xc(%ebp)
80102419:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010241c:	83 c0 02             	add    $0x2,%eax
8010241f:	50                   	push   %eax
80102420:	e8 ec 2a 00 00       	call   80104f11 <strncpy>
80102425:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102428:	8b 45 10             	mov    0x10(%ebp),%eax
8010242b:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010242f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102432:	6a 10                	push   $0x10
80102434:	50                   	push   %eax
80102435:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102438:	50                   	push   %eax
80102439:	ff 75 08             	push   0x8(%ebp)
8010243c:	e8 d9 fc ff ff       	call   8010211a <writei>
80102441:	83 c4 10             	add    $0x10,%esp
80102444:	83 f8 10             	cmp    $0x10,%eax
80102447:	74 0d                	je     80102456 <dirlink+0xd5>
    panic("dirlink");
80102449:	83 ec 0c             	sub    $0xc,%esp
8010244c:	68 6f a8 10 80       	push   $0x8010a86f
80102451:	e8 6f e1 ff ff       	call   801005c5 <panic>

  return 0;
80102456:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010245b:	c9                   	leave
8010245c:	c3                   	ret

8010245d <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010245d:	f3 0f 1e fb          	endbr32
80102461:	55                   	push   %ebp
80102462:	89 e5                	mov    %esp,%ebp
80102464:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102467:	eb 04                	jmp    8010246d <skipelem+0x10>
    path++;
80102469:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010246d:	8b 45 08             	mov    0x8(%ebp),%eax
80102470:	0f b6 00             	movzbl (%eax),%eax
80102473:	3c 2f                	cmp    $0x2f,%al
80102475:	74 f2                	je     80102469 <skipelem+0xc>
  if(*path == 0)
80102477:	8b 45 08             	mov    0x8(%ebp),%eax
8010247a:	0f b6 00             	movzbl (%eax),%eax
8010247d:	84 c0                	test   %al,%al
8010247f:	75 07                	jne    80102488 <skipelem+0x2b>
    return 0;
80102481:	b8 00 00 00 00       	mov    $0x0,%eax
80102486:	eb 77                	jmp    801024ff <skipelem+0xa2>
  s = path;
80102488:	8b 45 08             	mov    0x8(%ebp),%eax
8010248b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010248e:	eb 04                	jmp    80102494 <skipelem+0x37>
    path++;
80102490:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102494:	8b 45 08             	mov    0x8(%ebp),%eax
80102497:	0f b6 00             	movzbl (%eax),%eax
8010249a:	3c 2f                	cmp    $0x2f,%al
8010249c:	74 0a                	je     801024a8 <skipelem+0x4b>
8010249e:	8b 45 08             	mov    0x8(%ebp),%eax
801024a1:	0f b6 00             	movzbl (%eax),%eax
801024a4:	84 c0                	test   %al,%al
801024a6:	75 e8                	jne    80102490 <skipelem+0x33>
  len = path - s;
801024a8:	8b 45 08             	mov    0x8(%ebp),%eax
801024ab:	2b 45 f4             	sub    -0xc(%ebp),%eax
801024ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801024b1:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801024b5:	7e 15                	jle    801024cc <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801024b7:	83 ec 04             	sub    $0x4,%esp
801024ba:	6a 0e                	push   $0xe
801024bc:	ff 75 f4             	push   -0xc(%ebp)
801024bf:	ff 75 0c             	push   0xc(%ebp)
801024c2:	e8 52 29 00 00       	call   80104e19 <memmove>
801024c7:	83 c4 10             	add    $0x10,%esp
801024ca:	eb 26                	jmp    801024f2 <skipelem+0x95>
  else {
    memmove(name, s, len);
801024cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024cf:	83 ec 04             	sub    $0x4,%esp
801024d2:	50                   	push   %eax
801024d3:	ff 75 f4             	push   -0xc(%ebp)
801024d6:	ff 75 0c             	push   0xc(%ebp)
801024d9:	e8 3b 29 00 00       	call   80104e19 <memmove>
801024de:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801024e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801024e7:	01 d0                	add    %edx,%eax
801024e9:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024ec:	eb 04                	jmp    801024f2 <skipelem+0x95>
    path++;
801024ee:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024f2:	8b 45 08             	mov    0x8(%ebp),%eax
801024f5:	0f b6 00             	movzbl (%eax),%eax
801024f8:	3c 2f                	cmp    $0x2f,%al
801024fa:	74 f2                	je     801024ee <skipelem+0x91>
  return path;
801024fc:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024ff:	c9                   	leave
80102500:	c3                   	ret

80102501 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102501:	f3 0f 1e fb          	endbr32
80102505:	55                   	push   %ebp
80102506:	89 e5                	mov    %esp,%ebp
80102508:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010250b:	8b 45 08             	mov    0x8(%ebp),%eax
8010250e:	0f b6 00             	movzbl (%eax),%eax
80102511:	3c 2f                	cmp    $0x2f,%al
80102513:	75 17                	jne    8010252c <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
80102515:	83 ec 08             	sub    $0x8,%esp
80102518:	6a 01                	push   $0x1
8010251a:	6a 01                	push   $0x1
8010251c:	e8 74 f4 ff ff       	call   80101995 <iget>
80102521:	83 c4 10             	add    $0x10,%esp
80102524:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102527:	e9 ba 00 00 00       	jmp    801025e6 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
8010252c:	e8 b5 16 00 00       	call   80103be6 <myproc>
80102531:	8b 40 68             	mov    0x68(%eax),%eax
80102534:	83 ec 0c             	sub    $0xc,%esp
80102537:	50                   	push   %eax
80102538:	e8 3e f5 ff ff       	call   80101a7b <idup>
8010253d:	83 c4 10             	add    $0x10,%esp
80102540:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102543:	e9 9e 00 00 00       	jmp    801025e6 <namex+0xe5>
    ilock(ip);
80102548:	83 ec 0c             	sub    $0xc,%esp
8010254b:	ff 75 f4             	push   -0xc(%ebp)
8010254e:	e8 66 f5 ff ff       	call   80101ab9 <ilock>
80102553:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102559:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010255d:	66 83 f8 01          	cmp    $0x1,%ax
80102561:	74 18                	je     8010257b <namex+0x7a>
      iunlockput(ip);
80102563:	83 ec 0c             	sub    $0xc,%esp
80102566:	ff 75 f4             	push   -0xc(%ebp)
80102569:	e8 88 f7 ff ff       	call   80101cf6 <iunlockput>
8010256e:	83 c4 10             	add    $0x10,%esp
      return 0;
80102571:	b8 00 00 00 00       	mov    $0x0,%eax
80102576:	e9 a7 00 00 00       	jmp    80102622 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
8010257b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010257f:	74 20                	je     801025a1 <namex+0xa0>
80102581:	8b 45 08             	mov    0x8(%ebp),%eax
80102584:	0f b6 00             	movzbl (%eax),%eax
80102587:	84 c0                	test   %al,%al
80102589:	75 16                	jne    801025a1 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
8010258b:	83 ec 0c             	sub    $0xc,%esp
8010258e:	ff 75 f4             	push   -0xc(%ebp)
80102591:	e8 3a f6 ff ff       	call   80101bd0 <iunlock>
80102596:	83 c4 10             	add    $0x10,%esp
      return ip;
80102599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010259c:	e9 81 00 00 00       	jmp    80102622 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801025a1:	83 ec 04             	sub    $0x4,%esp
801025a4:	6a 00                	push   $0x0
801025a6:	ff 75 10             	push   0x10(%ebp)
801025a9:	ff 75 f4             	push   -0xc(%ebp)
801025ac:	e8 12 fd ff ff       	call   801022c3 <dirlookup>
801025b1:	83 c4 10             	add    $0x10,%esp
801025b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801025b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025bb:	75 15                	jne    801025d2 <namex+0xd1>
      iunlockput(ip);
801025bd:	83 ec 0c             	sub    $0xc,%esp
801025c0:	ff 75 f4             	push   -0xc(%ebp)
801025c3:	e8 2e f7 ff ff       	call   80101cf6 <iunlockput>
801025c8:	83 c4 10             	add    $0x10,%esp
      return 0;
801025cb:	b8 00 00 00 00       	mov    $0x0,%eax
801025d0:	eb 50                	jmp    80102622 <namex+0x121>
    }
    iunlockput(ip);
801025d2:	83 ec 0c             	sub    $0xc,%esp
801025d5:	ff 75 f4             	push   -0xc(%ebp)
801025d8:	e8 19 f7 ff ff       	call   80101cf6 <iunlockput>
801025dd:	83 c4 10             	add    $0x10,%esp
    ip = next;
801025e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801025e6:	83 ec 08             	sub    $0x8,%esp
801025e9:	ff 75 10             	push   0x10(%ebp)
801025ec:	ff 75 08             	push   0x8(%ebp)
801025ef:	e8 69 fe ff ff       	call   8010245d <skipelem>
801025f4:	83 c4 10             	add    $0x10,%esp
801025f7:	89 45 08             	mov    %eax,0x8(%ebp)
801025fa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025fe:	0f 85 44 ff ff ff    	jne    80102548 <namex+0x47>
  }
  if(nameiparent){
80102604:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102608:	74 15                	je     8010261f <namex+0x11e>
    iput(ip);
8010260a:	83 ec 0c             	sub    $0xc,%esp
8010260d:	ff 75 f4             	push   -0xc(%ebp)
80102610:	e8 0d f6 ff ff       	call   80101c22 <iput>
80102615:	83 c4 10             	add    $0x10,%esp
    return 0;
80102618:	b8 00 00 00 00       	mov    $0x0,%eax
8010261d:	eb 03                	jmp    80102622 <namex+0x121>
  }
  return ip;
8010261f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102622:	c9                   	leave
80102623:	c3                   	ret

80102624 <namei>:

struct inode*
namei(char *path)
{
80102624:	f3 0f 1e fb          	endbr32
80102628:	55                   	push   %ebp
80102629:	89 e5                	mov    %esp,%ebp
8010262b:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010262e:	83 ec 04             	sub    $0x4,%esp
80102631:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102634:	50                   	push   %eax
80102635:	6a 00                	push   $0x0
80102637:	ff 75 08             	push   0x8(%ebp)
8010263a:	e8 c2 fe ff ff       	call   80102501 <namex>
8010263f:	83 c4 10             	add    $0x10,%esp
}
80102642:	c9                   	leave
80102643:	c3                   	ret

80102644 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102644:	f3 0f 1e fb          	endbr32
80102648:	55                   	push   %ebp
80102649:	89 e5                	mov    %esp,%ebp
8010264b:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010264e:	83 ec 04             	sub    $0x4,%esp
80102651:	ff 75 0c             	push   0xc(%ebp)
80102654:	6a 01                	push   $0x1
80102656:	ff 75 08             	push   0x8(%ebp)
80102659:	e8 a3 fe ff ff       	call   80102501 <namex>
8010265e:	83 c4 10             	add    $0x10,%esp
}
80102661:	c9                   	leave
80102662:	c3                   	ret

80102663 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102663:	f3 0f 1e fb          	endbr32
80102667:	55                   	push   %ebp
80102668:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010266a:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010266f:	8b 55 08             	mov    0x8(%ebp),%edx
80102672:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102674:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102679:	8b 40 10             	mov    0x10(%eax),%eax
}
8010267c:	5d                   	pop    %ebp
8010267d:	c3                   	ret

8010267e <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010267e:	f3 0f 1e fb          	endbr32
80102682:	55                   	push   %ebp
80102683:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102685:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010268a:	8b 55 08             	mov    0x8(%ebp),%edx
8010268d:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010268f:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102694:	8b 55 0c             	mov    0xc(%ebp),%edx
80102697:	89 50 10             	mov    %edx,0x10(%eax)
}
8010269a:	90                   	nop
8010269b:	5d                   	pop    %ebp
8010269c:	c3                   	ret

8010269d <ioapicinit>:

void
ioapicinit(void)
{
8010269d:	f3 0f 1e fb          	endbr32
801026a1:	55                   	push   %ebp
801026a2:	89 e5                	mov    %esp,%ebp
801026a4:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801026a7:	c7 05 d4 53 19 80 00 	movl   $0xfec00000,0x801953d4
801026ae:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801026b1:	6a 01                	push   $0x1
801026b3:	e8 ab ff ff ff       	call   80102663 <ioapicread>
801026b8:	83 c4 04             	add    $0x4,%esp
801026bb:	c1 e8 10             	shr    $0x10,%eax
801026be:	25 ff 00 00 00       	and    $0xff,%eax
801026c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801026c6:	6a 00                	push   $0x0
801026c8:	e8 96 ff ff ff       	call   80102663 <ioapicread>
801026cd:	83 c4 04             	add    $0x4,%esp
801026d0:	c1 e8 18             	shr    $0x18,%eax
801026d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801026d6:	0f b6 05 a0 7d 19 80 	movzbl 0x80197da0,%eax
801026dd:	0f b6 c0             	movzbl %al,%eax
801026e0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801026e3:	74 10                	je     801026f5 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801026e5:	83 ec 0c             	sub    $0xc,%esp
801026e8:	68 78 a8 10 80       	push   $0x8010a878
801026ed:	e8 1a dd ff ff       	call   8010040c <cprintf>
801026f2:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801026f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026fc:	eb 3f                	jmp    8010273d <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801026fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102701:	83 c0 20             	add    $0x20,%eax
80102704:	0d 00 00 01 00       	or     $0x10000,%eax
80102709:	89 c2                	mov    %eax,%edx
8010270b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010270e:	83 c0 08             	add    $0x8,%eax
80102711:	01 c0                	add    %eax,%eax
80102713:	83 ec 08             	sub    $0x8,%esp
80102716:	52                   	push   %edx
80102717:	50                   	push   %eax
80102718:	e8 61 ff ff ff       	call   8010267e <ioapicwrite>
8010271d:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102720:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102723:	83 c0 08             	add    $0x8,%eax
80102726:	01 c0                	add    %eax,%eax
80102728:	83 c0 01             	add    $0x1,%eax
8010272b:	83 ec 08             	sub    $0x8,%esp
8010272e:	6a 00                	push   $0x0
80102730:	50                   	push   %eax
80102731:	e8 48 ff ff ff       	call   8010267e <ioapicwrite>
80102736:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102739:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010273d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102740:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102743:	7e b9                	jle    801026fe <ioapicinit+0x61>
  }
}
80102745:	90                   	nop
80102746:	90                   	nop
80102747:	c9                   	leave
80102748:	c3                   	ret

80102749 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102749:	f3 0f 1e fb          	endbr32
8010274d:	55                   	push   %ebp
8010274e:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102750:	8b 45 08             	mov    0x8(%ebp),%eax
80102753:	83 c0 20             	add    $0x20,%eax
80102756:	89 c2                	mov    %eax,%edx
80102758:	8b 45 08             	mov    0x8(%ebp),%eax
8010275b:	83 c0 08             	add    $0x8,%eax
8010275e:	01 c0                	add    %eax,%eax
80102760:	52                   	push   %edx
80102761:	50                   	push   %eax
80102762:	e8 17 ff ff ff       	call   8010267e <ioapicwrite>
80102767:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010276a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010276d:	c1 e0 18             	shl    $0x18,%eax
80102770:	89 c2                	mov    %eax,%edx
80102772:	8b 45 08             	mov    0x8(%ebp),%eax
80102775:	83 c0 08             	add    $0x8,%eax
80102778:	01 c0                	add    %eax,%eax
8010277a:	83 c0 01             	add    $0x1,%eax
8010277d:	52                   	push   %edx
8010277e:	50                   	push   %eax
8010277f:	e8 fa fe ff ff       	call   8010267e <ioapicwrite>
80102784:	83 c4 08             	add    $0x8,%esp
}
80102787:	90                   	nop
80102788:	c9                   	leave
80102789:	c3                   	ret

8010278a <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010278a:	f3 0f 1e fb          	endbr32
8010278e:	55                   	push   %ebp
8010278f:	89 e5                	mov    %esp,%ebp
80102791:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102794:	83 ec 08             	sub    $0x8,%esp
80102797:	68 aa a8 10 80       	push   $0x8010a8aa
8010279c:	68 e0 53 19 80       	push   $0x801953e0
801027a1:	e8 f7 22 00 00       	call   80104a9d <initlock>
801027a6:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
801027a9:	c7 05 14 54 19 80 00 	movl   $0x0,0x80195414
801027b0:	00 00 00 
  freerange(vstart, vend);
801027b3:	83 ec 08             	sub    $0x8,%esp
801027b6:	ff 75 0c             	push   0xc(%ebp)
801027b9:	ff 75 08             	push   0x8(%ebp)
801027bc:	e8 2e 00 00 00       	call   801027ef <freerange>
801027c1:	83 c4 10             	add    $0x10,%esp
}
801027c4:	90                   	nop
801027c5:	c9                   	leave
801027c6:	c3                   	ret

801027c7 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801027c7:	f3 0f 1e fb          	endbr32
801027cb:	55                   	push   %ebp
801027cc:	89 e5                	mov    %esp,%ebp
801027ce:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801027d1:	83 ec 08             	sub    $0x8,%esp
801027d4:	ff 75 0c             	push   0xc(%ebp)
801027d7:	ff 75 08             	push   0x8(%ebp)
801027da:	e8 10 00 00 00       	call   801027ef <freerange>
801027df:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801027e2:	c7 05 14 54 19 80 01 	movl   $0x1,0x80195414
801027e9:	00 00 00 
}
801027ec:	90                   	nop
801027ed:	c9                   	leave
801027ee:	c3                   	ret

801027ef <freerange>:

void
freerange(void *vstart, void *vend)
{
801027ef:	f3 0f 1e fb          	endbr32
801027f3:	55                   	push   %ebp
801027f4:	89 e5                	mov    %esp,%ebp
801027f6:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801027f9:	8b 45 08             	mov    0x8(%ebp),%eax
801027fc:	05 ff 0f 00 00       	add    $0xfff,%eax
80102801:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102806:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102809:	eb 15                	jmp    80102820 <freerange+0x31>
    kfree(p);
8010280b:	83 ec 0c             	sub    $0xc,%esp
8010280e:	ff 75 f4             	push   -0xc(%ebp)
80102811:	e8 1b 00 00 00       	call   80102831 <kfree>
80102816:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102819:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102823:	05 00 10 00 00       	add    $0x1000,%eax
80102828:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010282b:	73 de                	jae    8010280b <freerange+0x1c>
}
8010282d:	90                   	nop
8010282e:	90                   	nop
8010282f:	c9                   	leave
80102830:	c3                   	ret

80102831 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102831:	f3 0f 1e fb          	endbr32
80102835:	55                   	push   %ebp
80102836:	89 e5                	mov    %esp,%ebp
80102838:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010283b:	8b 45 08             	mov    0x8(%ebp),%eax
8010283e:	25 ff 0f 00 00       	and    $0xfff,%eax
80102843:	85 c0                	test   %eax,%eax
80102845:	75 18                	jne    8010285f <kfree+0x2e>
80102847:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
8010284e:	72 0f                	jb     8010285f <kfree+0x2e>
80102850:	8b 45 08             	mov    0x8(%ebp),%eax
80102853:	05 00 00 00 80       	add    $0x80000000,%eax
80102858:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010285d:	76 0d                	jbe    8010286c <kfree+0x3b>
    panic("kfree");
8010285f:	83 ec 0c             	sub    $0xc,%esp
80102862:	68 af a8 10 80       	push   $0x8010a8af
80102867:	e8 59 dd ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010286c:	83 ec 04             	sub    $0x4,%esp
8010286f:	68 00 10 00 00       	push   $0x1000
80102874:	6a 01                	push   $0x1
80102876:	ff 75 08             	push   0x8(%ebp)
80102879:	e8 d4 24 00 00       	call   80104d52 <memset>
8010287e:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102881:	a1 14 54 19 80       	mov    0x80195414,%eax
80102886:	85 c0                	test   %eax,%eax
80102888:	74 10                	je     8010289a <kfree+0x69>
    acquire(&kmem.lock);
8010288a:	83 ec 0c             	sub    $0xc,%esp
8010288d:	68 e0 53 19 80       	push   $0x801953e0
80102892:	e8 2c 22 00 00       	call   80104ac3 <acquire>
80102897:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010289a:	8b 45 08             	mov    0x8(%ebp),%eax
8010289d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
801028a0:	8b 15 18 54 19 80    	mov    0x80195418,%edx
801028a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028a9:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
801028ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ae:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
801028b3:	a1 14 54 19 80       	mov    0x80195414,%eax
801028b8:	85 c0                	test   %eax,%eax
801028ba:	74 10                	je     801028cc <kfree+0x9b>
    release(&kmem.lock);
801028bc:	83 ec 0c             	sub    $0xc,%esp
801028bf:	68 e0 53 19 80       	push   $0x801953e0
801028c4:	e8 6c 22 00 00       	call   80104b35 <release>
801028c9:	83 c4 10             	add    $0x10,%esp
}
801028cc:	90                   	nop
801028cd:	c9                   	leave
801028ce:	c3                   	ret

801028cf <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801028cf:	f3 0f 1e fb          	endbr32
801028d3:	55                   	push   %ebp
801028d4:	89 e5                	mov    %esp,%ebp
801028d6:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801028d9:	a1 14 54 19 80       	mov    0x80195414,%eax
801028de:	85 c0                	test   %eax,%eax
801028e0:	74 10                	je     801028f2 <kalloc+0x23>
    acquire(&kmem.lock);
801028e2:	83 ec 0c             	sub    $0xc,%esp
801028e5:	68 e0 53 19 80       	push   $0x801953e0
801028ea:	e8 d4 21 00 00       	call   80104ac3 <acquire>
801028ef:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801028f2:	a1 18 54 19 80       	mov    0x80195418,%eax
801028f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801028fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028fe:	74 0a                	je     8010290a <kalloc+0x3b>
    kmem.freelist = r->next;
80102900:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102903:	8b 00                	mov    (%eax),%eax
80102905:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
8010290a:	a1 14 54 19 80       	mov    0x80195414,%eax
8010290f:	85 c0                	test   %eax,%eax
80102911:	74 10                	je     80102923 <kalloc+0x54>
    release(&kmem.lock);
80102913:	83 ec 0c             	sub    $0xc,%esp
80102916:	68 e0 53 19 80       	push   $0x801953e0
8010291b:	e8 15 22 00 00       	call   80104b35 <release>
80102920:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102923:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102926:	c9                   	leave
80102927:	c3                   	ret

80102928 <inb>:
{
80102928:	55                   	push   %ebp
80102929:	89 e5                	mov    %esp,%ebp
8010292b:	83 ec 14             	sub    $0x14,%esp
8010292e:	8b 45 08             	mov    0x8(%ebp),%eax
80102931:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102935:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102939:	89 c2                	mov    %eax,%edx
8010293b:	ec                   	in     (%dx),%al
8010293c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010293f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102943:	c9                   	leave
80102944:	c3                   	ret

80102945 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102945:	f3 0f 1e fb          	endbr32
80102949:	55                   	push   %ebp
8010294a:	89 e5                	mov    %esp,%ebp
8010294c:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
8010294f:	6a 64                	push   $0x64
80102951:	e8 d2 ff ff ff       	call   80102928 <inb>
80102956:	83 c4 04             	add    $0x4,%esp
80102959:	0f b6 c0             	movzbl %al,%eax
8010295c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
8010295f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102962:	83 e0 01             	and    $0x1,%eax
80102965:	85 c0                	test   %eax,%eax
80102967:	75 0a                	jne    80102973 <kbdgetc+0x2e>
    return -1;
80102969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010296e:	e9 23 01 00 00       	jmp    80102a96 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102973:	6a 60                	push   $0x60
80102975:	e8 ae ff ff ff       	call   80102928 <inb>
8010297a:	83 c4 04             	add    $0x4,%esp
8010297d:	0f b6 c0             	movzbl %al,%eax
80102980:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102983:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010298a:	75 17                	jne    801029a3 <kbdgetc+0x5e>
    shift |= E0ESC;
8010298c:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102991:	83 c8 40             	or     $0x40,%eax
80102994:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
80102999:	b8 00 00 00 00       	mov    $0x0,%eax
8010299e:	e9 f3 00 00 00       	jmp    80102a96 <kbdgetc+0x151>
  } else if(data & 0x80){
801029a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029a6:	25 80 00 00 00       	and    $0x80,%eax
801029ab:	85 c0                	test   %eax,%eax
801029ad:	74 45                	je     801029f4 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801029af:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029b4:	83 e0 40             	and    $0x40,%eax
801029b7:	85 c0                	test   %eax,%eax
801029b9:	75 08                	jne    801029c3 <kbdgetc+0x7e>
801029bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029be:	83 e0 7f             	and    $0x7f,%eax
801029c1:	eb 03                	jmp    801029c6 <kbdgetc+0x81>
801029c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801029c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029cc:	05 20 d0 10 80       	add    $0x8010d020,%eax
801029d1:	0f b6 00             	movzbl (%eax),%eax
801029d4:	83 c8 40             	or     $0x40,%eax
801029d7:	0f b6 c0             	movzbl %al,%eax
801029da:	f7 d0                	not    %eax
801029dc:	89 c2                	mov    %eax,%edx
801029de:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029e3:	21 d0                	and    %edx,%eax
801029e5:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
801029ea:	b8 00 00 00 00       	mov    $0x0,%eax
801029ef:	e9 a2 00 00 00       	jmp    80102a96 <kbdgetc+0x151>
  } else if(shift & E0ESC){
801029f4:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029f9:	83 e0 40             	and    $0x40,%eax
801029fc:	85 c0                	test   %eax,%eax
801029fe:	74 14                	je     80102a14 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102a00:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102a07:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a0c:	83 e0 bf             	and    $0xffffffbf,%eax
80102a0f:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  }

  shift |= shiftcode[data];
80102a14:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a17:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102a1c:	0f b6 00             	movzbl (%eax),%eax
80102a1f:	0f b6 d0             	movzbl %al,%edx
80102a22:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a27:	09 d0                	or     %edx,%eax
80102a29:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  shift ^= togglecode[data];
80102a2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a31:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102a36:	0f b6 00             	movzbl (%eax),%eax
80102a39:	0f b6 d0             	movzbl %al,%edx
80102a3c:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a41:	31 d0                	xor    %edx,%eax
80102a43:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  c = charcode[shift & (CTL | SHIFT)][data];
80102a48:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a4d:	83 e0 03             	and    $0x3,%eax
80102a50:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102a57:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a5a:	01 d0                	add    %edx,%eax
80102a5c:	0f b6 00             	movzbl (%eax),%eax
80102a5f:	0f b6 c0             	movzbl %al,%eax
80102a62:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102a65:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a6a:	83 e0 08             	and    $0x8,%eax
80102a6d:	85 c0                	test   %eax,%eax
80102a6f:	74 22                	je     80102a93 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102a71:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102a75:	76 0c                	jbe    80102a83 <kbdgetc+0x13e>
80102a77:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102a7b:	77 06                	ja     80102a83 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102a7d:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102a81:	eb 10                	jmp    80102a93 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102a83:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102a87:	76 0a                	jbe    80102a93 <kbdgetc+0x14e>
80102a89:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102a8d:	77 04                	ja     80102a93 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102a8f:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102a93:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102a96:	c9                   	leave
80102a97:	c3                   	ret

80102a98 <kbdintr>:

void
kbdintr(void)
{
80102a98:	f3 0f 1e fb          	endbr32
80102a9c:	55                   	push   %ebp
80102a9d:	89 e5                	mov    %esp,%ebp
80102a9f:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102aa2:	83 ec 0c             	sub    $0xc,%esp
80102aa5:	68 45 29 10 80       	push   $0x80102945
80102aaa:	e8 51 dd ff ff       	call   80100800 <consoleintr>
80102aaf:	83 c4 10             	add    $0x10,%esp
}
80102ab2:	90                   	nop
80102ab3:	c9                   	leave
80102ab4:	c3                   	ret

80102ab5 <inb>:
{
80102ab5:	55                   	push   %ebp
80102ab6:	89 e5                	mov    %esp,%ebp
80102ab8:	83 ec 14             	sub    $0x14,%esp
80102abb:	8b 45 08             	mov    0x8(%ebp),%eax
80102abe:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ac2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ac6:	89 c2                	mov    %eax,%edx
80102ac8:	ec                   	in     (%dx),%al
80102ac9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102acc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ad0:	c9                   	leave
80102ad1:	c3                   	ret

80102ad2 <outb>:
{
80102ad2:	55                   	push   %ebp
80102ad3:	89 e5                	mov    %esp,%ebp
80102ad5:	83 ec 08             	sub    $0x8,%esp
80102ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80102adb:	8b 55 0c             	mov    0xc(%ebp),%edx
80102ade:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102ae2:	89 d0                	mov    %edx,%eax
80102ae4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ae7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102aeb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102aef:	ee                   	out    %al,(%dx)
}
80102af0:	90                   	nop
80102af1:	c9                   	leave
80102af2:	c3                   	ret

80102af3 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102af3:	f3 0f 1e fb          	endbr32
80102af7:	55                   	push   %ebp
80102af8:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102afa:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102aff:	8b 55 08             	mov    0x8(%ebp),%edx
80102b02:	c1 e2 02             	shl    $0x2,%edx
80102b05:	01 c2                	add    %eax,%edx
80102b07:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b0a:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102b0c:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b11:	83 c0 20             	add    $0x20,%eax
80102b14:	8b 00                	mov    (%eax),%eax
}
80102b16:	90                   	nop
80102b17:	5d                   	pop    %ebp
80102b18:	c3                   	ret

80102b19 <lapicinit>:

void
lapicinit(void)
{
80102b19:	f3 0f 1e fb          	endbr32
80102b1d:	55                   	push   %ebp
80102b1e:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102b20:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b25:	85 c0                	test   %eax,%eax
80102b27:	0f 84 0c 01 00 00    	je     80102c39 <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102b2d:	68 3f 01 00 00       	push   $0x13f
80102b32:	6a 3c                	push   $0x3c
80102b34:	e8 ba ff ff ff       	call   80102af3 <lapicw>
80102b39:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102b3c:	6a 0b                	push   $0xb
80102b3e:	68 f8 00 00 00       	push   $0xf8
80102b43:	e8 ab ff ff ff       	call   80102af3 <lapicw>
80102b48:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102b4b:	68 20 00 02 00       	push   $0x20020
80102b50:	68 c8 00 00 00       	push   $0xc8
80102b55:	e8 99 ff ff ff       	call   80102af3 <lapicw>
80102b5a:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102b5d:	68 80 96 98 00       	push   $0x989680
80102b62:	68 e0 00 00 00       	push   $0xe0
80102b67:	e8 87 ff ff ff       	call   80102af3 <lapicw>
80102b6c:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102b6f:	68 00 00 01 00       	push   $0x10000
80102b74:	68 d4 00 00 00       	push   $0xd4
80102b79:	e8 75 ff ff ff       	call   80102af3 <lapicw>
80102b7e:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102b81:	68 00 00 01 00       	push   $0x10000
80102b86:	68 d8 00 00 00       	push   $0xd8
80102b8b:	e8 63 ff ff ff       	call   80102af3 <lapicw>
80102b90:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102b93:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b98:	83 c0 30             	add    $0x30,%eax
80102b9b:	8b 00                	mov    (%eax),%eax
80102b9d:	c1 e8 10             	shr    $0x10,%eax
80102ba0:	25 fc 00 00 00       	and    $0xfc,%eax
80102ba5:	85 c0                	test   %eax,%eax
80102ba7:	74 12                	je     80102bbb <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80102ba9:	68 00 00 01 00       	push   $0x10000
80102bae:	68 d0 00 00 00       	push   $0xd0
80102bb3:	e8 3b ff ff ff       	call   80102af3 <lapicw>
80102bb8:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102bbb:	6a 33                	push   $0x33
80102bbd:	68 dc 00 00 00       	push   $0xdc
80102bc2:	e8 2c ff ff ff       	call   80102af3 <lapicw>
80102bc7:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102bca:	6a 00                	push   $0x0
80102bcc:	68 a0 00 00 00       	push   $0xa0
80102bd1:	e8 1d ff ff ff       	call   80102af3 <lapicw>
80102bd6:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102bd9:	6a 00                	push   $0x0
80102bdb:	68 a0 00 00 00       	push   $0xa0
80102be0:	e8 0e ff ff ff       	call   80102af3 <lapicw>
80102be5:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102be8:	6a 00                	push   $0x0
80102bea:	6a 2c                	push   $0x2c
80102bec:	e8 02 ff ff ff       	call   80102af3 <lapicw>
80102bf1:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102bf4:	6a 00                	push   $0x0
80102bf6:	68 c4 00 00 00       	push   $0xc4
80102bfb:	e8 f3 fe ff ff       	call   80102af3 <lapicw>
80102c00:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102c03:	68 00 85 08 00       	push   $0x88500
80102c08:	68 c0 00 00 00       	push   $0xc0
80102c0d:	e8 e1 fe ff ff       	call   80102af3 <lapicw>
80102c12:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102c15:	90                   	nop
80102c16:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c1b:	05 00 03 00 00       	add    $0x300,%eax
80102c20:	8b 00                	mov    (%eax),%eax
80102c22:	25 00 10 00 00       	and    $0x1000,%eax
80102c27:	85 c0                	test   %eax,%eax
80102c29:	75 eb                	jne    80102c16 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102c2b:	6a 00                	push   $0x0
80102c2d:	6a 20                	push   $0x20
80102c2f:	e8 bf fe ff ff       	call   80102af3 <lapicw>
80102c34:	83 c4 08             	add    $0x8,%esp
80102c37:	eb 01                	jmp    80102c3a <lapicinit+0x121>
    return;
80102c39:	90                   	nop
}
80102c3a:	c9                   	leave
80102c3b:	c3                   	ret

80102c3c <lapicid>:

int
lapicid(void)
{
80102c3c:	f3 0f 1e fb          	endbr32
80102c40:	55                   	push   %ebp
80102c41:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102c43:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c48:	85 c0                	test   %eax,%eax
80102c4a:	75 07                	jne    80102c53 <lapicid+0x17>
    return 0;
80102c4c:	b8 00 00 00 00       	mov    $0x0,%eax
80102c51:	eb 0d                	jmp    80102c60 <lapicid+0x24>
  }
  return lapic[ID] >> 24;
80102c53:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c58:	83 c0 20             	add    $0x20,%eax
80102c5b:	8b 00                	mov    (%eax),%eax
80102c5d:	c1 e8 18             	shr    $0x18,%eax
}
80102c60:	5d                   	pop    %ebp
80102c61:	c3                   	ret

80102c62 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102c62:	f3 0f 1e fb          	endbr32
80102c66:	55                   	push   %ebp
80102c67:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102c69:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c6e:	85 c0                	test   %eax,%eax
80102c70:	74 0c                	je     80102c7e <lapiceoi+0x1c>
    lapicw(EOI, 0);
80102c72:	6a 00                	push   $0x0
80102c74:	6a 2c                	push   $0x2c
80102c76:	e8 78 fe ff ff       	call   80102af3 <lapicw>
80102c7b:	83 c4 08             	add    $0x8,%esp
}
80102c7e:	90                   	nop
80102c7f:	c9                   	leave
80102c80:	c3                   	ret

80102c81 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102c81:	f3 0f 1e fb          	endbr32
80102c85:	55                   	push   %ebp
80102c86:	89 e5                	mov    %esp,%ebp
}
80102c88:	90                   	nop
80102c89:	5d                   	pop    %ebp
80102c8a:	c3                   	ret

80102c8b <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102c8b:	f3 0f 1e fb          	endbr32
80102c8f:	55                   	push   %ebp
80102c90:	89 e5                	mov    %esp,%ebp
80102c92:	83 ec 14             	sub    $0x14,%esp
80102c95:	8b 45 08             	mov    0x8(%ebp),%eax
80102c98:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102c9b:	6a 0f                	push   $0xf
80102c9d:	6a 70                	push   $0x70
80102c9f:	e8 2e fe ff ff       	call   80102ad2 <outb>
80102ca4:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102ca7:	6a 0a                	push   $0xa
80102ca9:	6a 71                	push   $0x71
80102cab:	e8 22 fe ff ff       	call   80102ad2 <outb>
80102cb0:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102cb3:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102cba:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102cbd:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102cc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cc5:	c1 e8 04             	shr    $0x4,%eax
80102cc8:	89 c2                	mov    %eax,%edx
80102cca:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102ccd:	83 c0 02             	add    $0x2,%eax
80102cd0:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102cd3:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102cd7:	c1 e0 18             	shl    $0x18,%eax
80102cda:	50                   	push   %eax
80102cdb:	68 c4 00 00 00       	push   $0xc4
80102ce0:	e8 0e fe ff ff       	call   80102af3 <lapicw>
80102ce5:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102ce8:	68 00 c5 00 00       	push   $0xc500
80102ced:	68 c0 00 00 00       	push   $0xc0
80102cf2:	e8 fc fd ff ff       	call   80102af3 <lapicw>
80102cf7:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102cfa:	68 c8 00 00 00       	push   $0xc8
80102cff:	e8 7d ff ff ff       	call   80102c81 <microdelay>
80102d04:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102d07:	68 00 85 00 00       	push   $0x8500
80102d0c:	68 c0 00 00 00       	push   $0xc0
80102d11:	e8 dd fd ff ff       	call   80102af3 <lapicw>
80102d16:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102d19:	6a 64                	push   $0x64
80102d1b:	e8 61 ff ff ff       	call   80102c81 <microdelay>
80102d20:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102d23:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102d2a:	eb 3d                	jmp    80102d69 <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
80102d2c:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102d30:	c1 e0 18             	shl    $0x18,%eax
80102d33:	50                   	push   %eax
80102d34:	68 c4 00 00 00       	push   $0xc4
80102d39:	e8 b5 fd ff ff       	call   80102af3 <lapicw>
80102d3e:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102d41:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d44:	c1 e8 0c             	shr    $0xc,%eax
80102d47:	80 cc 06             	or     $0x6,%ah
80102d4a:	50                   	push   %eax
80102d4b:	68 c0 00 00 00       	push   $0xc0
80102d50:	e8 9e fd ff ff       	call   80102af3 <lapicw>
80102d55:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102d58:	68 c8 00 00 00       	push   $0xc8
80102d5d:	e8 1f ff ff ff       	call   80102c81 <microdelay>
80102d62:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102d65:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102d69:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102d6d:	7e bd                	jle    80102d2c <lapicstartap+0xa1>
  }
}
80102d6f:	90                   	nop
80102d70:	90                   	nop
80102d71:	c9                   	leave
80102d72:	c3                   	ret

80102d73 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102d73:	f3 0f 1e fb          	endbr32
80102d77:	55                   	push   %ebp
80102d78:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80102d7d:	0f b6 c0             	movzbl %al,%eax
80102d80:	50                   	push   %eax
80102d81:	6a 70                	push   $0x70
80102d83:	e8 4a fd ff ff       	call   80102ad2 <outb>
80102d88:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102d8b:	68 c8 00 00 00       	push   $0xc8
80102d90:	e8 ec fe ff ff       	call   80102c81 <microdelay>
80102d95:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102d98:	6a 71                	push   $0x71
80102d9a:	e8 16 fd ff ff       	call   80102ab5 <inb>
80102d9f:	83 c4 04             	add    $0x4,%esp
80102da2:	0f b6 c0             	movzbl %al,%eax
}
80102da5:	c9                   	leave
80102da6:	c3                   	ret

80102da7 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102da7:	f3 0f 1e fb          	endbr32
80102dab:	55                   	push   %ebp
80102dac:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102dae:	6a 00                	push   $0x0
80102db0:	e8 be ff ff ff       	call   80102d73 <cmos_read>
80102db5:	83 c4 04             	add    $0x4,%esp
80102db8:	8b 55 08             	mov    0x8(%ebp),%edx
80102dbb:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102dbd:	6a 02                	push   $0x2
80102dbf:	e8 af ff ff ff       	call   80102d73 <cmos_read>
80102dc4:	83 c4 04             	add    $0x4,%esp
80102dc7:	8b 55 08             	mov    0x8(%ebp),%edx
80102dca:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102dcd:	6a 04                	push   $0x4
80102dcf:	e8 9f ff ff ff       	call   80102d73 <cmos_read>
80102dd4:	83 c4 04             	add    $0x4,%esp
80102dd7:	8b 55 08             	mov    0x8(%ebp),%edx
80102dda:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102ddd:	6a 07                	push   $0x7
80102ddf:	e8 8f ff ff ff       	call   80102d73 <cmos_read>
80102de4:	83 c4 04             	add    $0x4,%esp
80102de7:	8b 55 08             	mov    0x8(%ebp),%edx
80102dea:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102ded:	6a 08                	push   $0x8
80102def:	e8 7f ff ff ff       	call   80102d73 <cmos_read>
80102df4:	83 c4 04             	add    $0x4,%esp
80102df7:	8b 55 08             	mov    0x8(%ebp),%edx
80102dfa:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102dfd:	6a 09                	push   $0x9
80102dff:	e8 6f ff ff ff       	call   80102d73 <cmos_read>
80102e04:	83 c4 04             	add    $0x4,%esp
80102e07:	8b 55 08             	mov    0x8(%ebp),%edx
80102e0a:	89 42 14             	mov    %eax,0x14(%edx)
}
80102e0d:	90                   	nop
80102e0e:	c9                   	leave
80102e0f:	c3                   	ret

80102e10 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102e10:	f3 0f 1e fb          	endbr32
80102e14:	55                   	push   %ebp
80102e15:	89 e5                	mov    %esp,%ebp
80102e17:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102e1a:	6a 0b                	push   $0xb
80102e1c:	e8 52 ff ff ff       	call   80102d73 <cmos_read>
80102e21:	83 c4 04             	add    $0x4,%esp
80102e24:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e2a:	83 e0 04             	and    $0x4,%eax
80102e2d:	85 c0                	test   %eax,%eax
80102e2f:	0f 94 c0             	sete   %al
80102e32:	0f b6 c0             	movzbl %al,%eax
80102e35:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102e38:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e3b:	50                   	push   %eax
80102e3c:	e8 66 ff ff ff       	call   80102da7 <fill_rtcdate>
80102e41:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102e44:	6a 0a                	push   $0xa
80102e46:	e8 28 ff ff ff       	call   80102d73 <cmos_read>
80102e4b:	83 c4 04             	add    $0x4,%esp
80102e4e:	25 80 00 00 00       	and    $0x80,%eax
80102e53:	85 c0                	test   %eax,%eax
80102e55:	75 27                	jne    80102e7e <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80102e57:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e5a:	50                   	push   %eax
80102e5b:	e8 47 ff ff ff       	call   80102da7 <fill_rtcdate>
80102e60:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102e63:	83 ec 04             	sub    $0x4,%esp
80102e66:	6a 18                	push   $0x18
80102e68:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e6b:	50                   	push   %eax
80102e6c:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e6f:	50                   	push   %eax
80102e70:	e8 48 1f 00 00       	call   80104dbd <memcmp>
80102e75:	83 c4 10             	add    $0x10,%esp
80102e78:	85 c0                	test   %eax,%eax
80102e7a:	74 05                	je     80102e81 <cmostime+0x71>
80102e7c:	eb ba                	jmp    80102e38 <cmostime+0x28>
        continue;
80102e7e:	90                   	nop
    fill_rtcdate(&t1);
80102e7f:	eb b7                	jmp    80102e38 <cmostime+0x28>
      break;
80102e81:	90                   	nop
  }

  // convert
  if(bcd) {
80102e82:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102e86:	0f 84 b4 00 00 00    	je     80102f40 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102e8c:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102e8f:	c1 e8 04             	shr    $0x4,%eax
80102e92:	89 c2                	mov    %eax,%edx
80102e94:	89 d0                	mov    %edx,%eax
80102e96:	c1 e0 02             	shl    $0x2,%eax
80102e99:	01 d0                	add    %edx,%eax
80102e9b:	01 c0                	add    %eax,%eax
80102e9d:	89 c2                	mov    %eax,%edx
80102e9f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102ea2:	83 e0 0f             	and    $0xf,%eax
80102ea5:	01 d0                	add    %edx,%eax
80102ea7:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102eaa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102ead:	c1 e8 04             	shr    $0x4,%eax
80102eb0:	89 c2                	mov    %eax,%edx
80102eb2:	89 d0                	mov    %edx,%eax
80102eb4:	c1 e0 02             	shl    $0x2,%eax
80102eb7:	01 d0                	add    %edx,%eax
80102eb9:	01 c0                	add    %eax,%eax
80102ebb:	89 c2                	mov    %eax,%edx
80102ebd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102ec0:	83 e0 0f             	and    $0xf,%eax
80102ec3:	01 d0                	add    %edx,%eax
80102ec5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102ec8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102ecb:	c1 e8 04             	shr    $0x4,%eax
80102ece:	89 c2                	mov    %eax,%edx
80102ed0:	89 d0                	mov    %edx,%eax
80102ed2:	c1 e0 02             	shl    $0x2,%eax
80102ed5:	01 d0                	add    %edx,%eax
80102ed7:	01 c0                	add    %eax,%eax
80102ed9:	89 c2                	mov    %eax,%edx
80102edb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102ede:	83 e0 0f             	and    $0xf,%eax
80102ee1:	01 d0                	add    %edx,%eax
80102ee3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102ee6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102ee9:	c1 e8 04             	shr    $0x4,%eax
80102eec:	89 c2                	mov    %eax,%edx
80102eee:	89 d0                	mov    %edx,%eax
80102ef0:	c1 e0 02             	shl    $0x2,%eax
80102ef3:	01 d0                	add    %edx,%eax
80102ef5:	01 c0                	add    %eax,%eax
80102ef7:	89 c2                	mov    %eax,%edx
80102ef9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102efc:	83 e0 0f             	and    $0xf,%eax
80102eff:	01 d0                	add    %edx,%eax
80102f01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102f04:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f07:	c1 e8 04             	shr    $0x4,%eax
80102f0a:	89 c2                	mov    %eax,%edx
80102f0c:	89 d0                	mov    %edx,%eax
80102f0e:	c1 e0 02             	shl    $0x2,%eax
80102f11:	01 d0                	add    %edx,%eax
80102f13:	01 c0                	add    %eax,%eax
80102f15:	89 c2                	mov    %eax,%edx
80102f17:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f1a:	83 e0 0f             	and    $0xf,%eax
80102f1d:	01 d0                	add    %edx,%eax
80102f1f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102f22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f25:	c1 e8 04             	shr    $0x4,%eax
80102f28:	89 c2                	mov    %eax,%edx
80102f2a:	89 d0                	mov    %edx,%eax
80102f2c:	c1 e0 02             	shl    $0x2,%eax
80102f2f:	01 d0                	add    %edx,%eax
80102f31:	01 c0                	add    %eax,%eax
80102f33:	89 c2                	mov    %eax,%edx
80102f35:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f38:	83 e0 0f             	and    $0xf,%eax
80102f3b:	01 d0                	add    %edx,%eax
80102f3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102f40:	8b 45 08             	mov    0x8(%ebp),%eax
80102f43:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102f46:	89 10                	mov    %edx,(%eax)
80102f48:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102f4b:	89 50 04             	mov    %edx,0x4(%eax)
80102f4e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102f51:	89 50 08             	mov    %edx,0x8(%eax)
80102f54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102f57:	89 50 0c             	mov    %edx,0xc(%eax)
80102f5a:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102f5d:	89 50 10             	mov    %edx,0x10(%eax)
80102f60:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102f63:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102f66:	8b 45 08             	mov    0x8(%ebp),%eax
80102f69:	8b 40 14             	mov    0x14(%eax),%eax
80102f6c:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102f72:	8b 45 08             	mov    0x8(%ebp),%eax
80102f75:	89 50 14             	mov    %edx,0x14(%eax)
}
80102f78:	90                   	nop
80102f79:	c9                   	leave
80102f7a:	c3                   	ret

80102f7b <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102f7b:	f3 0f 1e fb          	endbr32
80102f7f:	55                   	push   %ebp
80102f80:	89 e5                	mov    %esp,%ebp
80102f82:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102f85:	83 ec 08             	sub    $0x8,%esp
80102f88:	68 b5 a8 10 80       	push   $0x8010a8b5
80102f8d:	68 20 54 19 80       	push   $0x80195420
80102f92:	e8 06 1b 00 00       	call   80104a9d <initlock>
80102f97:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102f9a:	83 ec 08             	sub    $0x8,%esp
80102f9d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102fa0:	50                   	push   %eax
80102fa1:	ff 75 08             	push   0x8(%ebp)
80102fa4:	e8 c0 e4 ff ff       	call   80101469 <readsb>
80102fa9:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102fac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102faf:	a3 54 54 19 80       	mov    %eax,0x80195454
  log.size = sb.nlog;
80102fb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102fb7:	a3 58 54 19 80       	mov    %eax,0x80195458
  log.dev = dev;
80102fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80102fbf:	a3 64 54 19 80       	mov    %eax,0x80195464
  recover_from_log();
80102fc4:	e8 bf 01 00 00       	call   80103188 <recover_from_log>
}
80102fc9:	90                   	nop
80102fca:	c9                   	leave
80102fcb:	c3                   	ret

80102fcc <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102fcc:	f3 0f 1e fb          	endbr32
80102fd0:	55                   	push   %ebp
80102fd1:	89 e5                	mov    %esp,%ebp
80102fd3:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102fd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fdd:	e9 95 00 00 00       	jmp    80103077 <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102fe2:	8b 15 54 54 19 80    	mov    0x80195454,%edx
80102fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102feb:	01 d0                	add    %edx,%eax
80102fed:	83 c0 01             	add    $0x1,%eax
80102ff0:	89 c2                	mov    %eax,%edx
80102ff2:	a1 64 54 19 80       	mov    0x80195464,%eax
80102ff7:	83 ec 08             	sub    $0x8,%esp
80102ffa:	52                   	push   %edx
80102ffb:	50                   	push   %eax
80102ffc:	e8 08 d2 ff ff       	call   80100209 <bread>
80103001:	83 c4 10             	add    $0x10,%esp
80103004:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010300a:	83 c0 10             	add    $0x10,%eax
8010300d:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103014:	89 c2                	mov    %eax,%edx
80103016:	a1 64 54 19 80       	mov    0x80195464,%eax
8010301b:	83 ec 08             	sub    $0x8,%esp
8010301e:	52                   	push   %edx
8010301f:	50                   	push   %eax
80103020:	e8 e4 d1 ff ff       	call   80100209 <bread>
80103025:	83 c4 10             	add    $0x10,%esp
80103028:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010302b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010302e:	8d 50 5c             	lea    0x5c(%eax),%edx
80103031:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103034:	83 c0 5c             	add    $0x5c,%eax
80103037:	83 ec 04             	sub    $0x4,%esp
8010303a:	68 00 02 00 00       	push   $0x200
8010303f:	52                   	push   %edx
80103040:	50                   	push   %eax
80103041:	e8 d3 1d 00 00       	call   80104e19 <memmove>
80103046:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103049:	83 ec 0c             	sub    $0xc,%esp
8010304c:	ff 75 ec             	push   -0x14(%ebp)
8010304f:	e8 f2 d1 ff ff       	call   80100246 <bwrite>
80103054:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80103057:	83 ec 0c             	sub    $0xc,%esp
8010305a:	ff 75 f0             	push   -0x10(%ebp)
8010305d:	e8 31 d2 ff ff       	call   80100293 <brelse>
80103062:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103065:	83 ec 0c             	sub    $0xc,%esp
80103068:	ff 75 ec             	push   -0x14(%ebp)
8010306b:	e8 23 d2 ff ff       	call   80100293 <brelse>
80103070:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103073:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103077:	a1 68 54 19 80       	mov    0x80195468,%eax
8010307c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010307f:	0f 8c 5d ff ff ff    	jl     80102fe2 <install_trans+0x16>
  }
}
80103085:	90                   	nop
80103086:	90                   	nop
80103087:	c9                   	leave
80103088:	c3                   	ret

80103089 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103089:	f3 0f 1e fb          	endbr32
8010308d:	55                   	push   %ebp
8010308e:	89 e5                	mov    %esp,%ebp
80103090:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103093:	a1 54 54 19 80       	mov    0x80195454,%eax
80103098:	89 c2                	mov    %eax,%edx
8010309a:	a1 64 54 19 80       	mov    0x80195464,%eax
8010309f:	83 ec 08             	sub    $0x8,%esp
801030a2:	52                   	push   %edx
801030a3:	50                   	push   %eax
801030a4:	e8 60 d1 ff ff       	call   80100209 <bread>
801030a9:	83 c4 10             	add    $0x10,%esp
801030ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801030af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030b2:	83 c0 5c             	add    $0x5c,%eax
801030b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801030b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030bb:	8b 00                	mov    (%eax),%eax
801030bd:	a3 68 54 19 80       	mov    %eax,0x80195468
  for (i = 0; i < log.lh.n; i++) {
801030c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801030c9:	eb 1b                	jmp    801030e6 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
801030cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801030d1:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801030d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801030d8:	83 c2 10             	add    $0x10,%edx
801030db:	89 04 95 2c 54 19 80 	mov    %eax,-0x7fe6abd4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801030e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801030e6:	a1 68 54 19 80       	mov    0x80195468,%eax
801030eb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801030ee:	7c db                	jl     801030cb <read_head+0x42>
  }
  brelse(buf);
801030f0:	83 ec 0c             	sub    $0xc,%esp
801030f3:	ff 75 f0             	push   -0x10(%ebp)
801030f6:	e8 98 d1 ff ff       	call   80100293 <brelse>
801030fb:	83 c4 10             	add    $0x10,%esp
}
801030fe:	90                   	nop
801030ff:	c9                   	leave
80103100:	c3                   	ret

80103101 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103101:	f3 0f 1e fb          	endbr32
80103105:	55                   	push   %ebp
80103106:	89 e5                	mov    %esp,%ebp
80103108:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010310b:	a1 54 54 19 80       	mov    0x80195454,%eax
80103110:	89 c2                	mov    %eax,%edx
80103112:	a1 64 54 19 80       	mov    0x80195464,%eax
80103117:	83 ec 08             	sub    $0x8,%esp
8010311a:	52                   	push   %edx
8010311b:	50                   	push   %eax
8010311c:	e8 e8 d0 ff ff       	call   80100209 <bread>
80103121:	83 c4 10             	add    $0x10,%esp
80103124:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103127:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010312a:	83 c0 5c             	add    $0x5c,%eax
8010312d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103130:	8b 15 68 54 19 80    	mov    0x80195468,%edx
80103136:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103139:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010313b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103142:	eb 1b                	jmp    8010315f <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103144:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103147:	83 c0 10             	add    $0x10,%eax
8010314a:	8b 0c 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%ecx
80103151:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103154:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103157:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010315b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010315f:	a1 68 54 19 80       	mov    0x80195468,%eax
80103164:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103167:	7c db                	jl     80103144 <write_head+0x43>
  }
  bwrite(buf);
80103169:	83 ec 0c             	sub    $0xc,%esp
8010316c:	ff 75 f0             	push   -0x10(%ebp)
8010316f:	e8 d2 d0 ff ff       	call   80100246 <bwrite>
80103174:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103177:	83 ec 0c             	sub    $0xc,%esp
8010317a:	ff 75 f0             	push   -0x10(%ebp)
8010317d:	e8 11 d1 ff ff       	call   80100293 <brelse>
80103182:	83 c4 10             	add    $0x10,%esp
}
80103185:	90                   	nop
80103186:	c9                   	leave
80103187:	c3                   	ret

80103188 <recover_from_log>:

static void
recover_from_log(void)
{
80103188:	f3 0f 1e fb          	endbr32
8010318c:	55                   	push   %ebp
8010318d:	89 e5                	mov    %esp,%ebp
8010318f:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103192:	e8 f2 fe ff ff       	call   80103089 <read_head>
  install_trans(); // if committed, copy from log to disk
80103197:	e8 30 fe ff ff       	call   80102fcc <install_trans>
  log.lh.n = 0;
8010319c:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
801031a3:	00 00 00 
  write_head(); // clear the log
801031a6:	e8 56 ff ff ff       	call   80103101 <write_head>
}
801031ab:	90                   	nop
801031ac:	c9                   	leave
801031ad:	c3                   	ret

801031ae <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801031ae:	f3 0f 1e fb          	endbr32
801031b2:	55                   	push   %ebp
801031b3:	89 e5                	mov    %esp,%ebp
801031b5:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801031b8:	83 ec 0c             	sub    $0xc,%esp
801031bb:	68 20 54 19 80       	push   $0x80195420
801031c0:	e8 fe 18 00 00       	call   80104ac3 <acquire>
801031c5:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801031c8:	a1 60 54 19 80       	mov    0x80195460,%eax
801031cd:	85 c0                	test   %eax,%eax
801031cf:	74 17                	je     801031e8 <begin_op+0x3a>
      sleep(&log, &log.lock);
801031d1:	83 ec 08             	sub    $0x8,%esp
801031d4:	68 20 54 19 80       	push   $0x80195420
801031d9:	68 20 54 19 80       	push   $0x80195420
801031de:	e8 67 13 00 00       	call   8010454a <sleep>
801031e3:	83 c4 10             	add    $0x10,%esp
801031e6:	eb e0                	jmp    801031c8 <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801031e8:	8b 0d 68 54 19 80    	mov    0x80195468,%ecx
801031ee:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801031f3:	8d 50 01             	lea    0x1(%eax),%edx
801031f6:	89 d0                	mov    %edx,%eax
801031f8:	c1 e0 02             	shl    $0x2,%eax
801031fb:	01 d0                	add    %edx,%eax
801031fd:	01 c0                	add    %eax,%eax
801031ff:	01 c8                	add    %ecx,%eax
80103201:	83 f8 1e             	cmp    $0x1e,%eax
80103204:	7e 17                	jle    8010321d <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103206:	83 ec 08             	sub    $0x8,%esp
80103209:	68 20 54 19 80       	push   $0x80195420
8010320e:	68 20 54 19 80       	push   $0x80195420
80103213:	e8 32 13 00 00       	call   8010454a <sleep>
80103218:	83 c4 10             	add    $0x10,%esp
8010321b:	eb ab                	jmp    801031c8 <begin_op+0x1a>
    } else {
      log.outstanding += 1;
8010321d:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103222:	83 c0 01             	add    $0x1,%eax
80103225:	a3 5c 54 19 80       	mov    %eax,0x8019545c
      release(&log.lock);
8010322a:	83 ec 0c             	sub    $0xc,%esp
8010322d:	68 20 54 19 80       	push   $0x80195420
80103232:	e8 fe 18 00 00       	call   80104b35 <release>
80103237:	83 c4 10             	add    $0x10,%esp
      break;
8010323a:	90                   	nop
    }
  }
}
8010323b:	90                   	nop
8010323c:	c9                   	leave
8010323d:	c3                   	ret

8010323e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010323e:	f3 0f 1e fb          	endbr32
80103242:	55                   	push   %ebp
80103243:	89 e5                	mov    %esp,%ebp
80103245:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103248:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010324f:	83 ec 0c             	sub    $0xc,%esp
80103252:	68 20 54 19 80       	push   $0x80195420
80103257:	e8 67 18 00 00       	call   80104ac3 <acquire>
8010325c:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
8010325f:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103264:	83 e8 01             	sub    $0x1,%eax
80103267:	a3 5c 54 19 80       	mov    %eax,0x8019545c
  if(log.committing)
8010326c:	a1 60 54 19 80       	mov    0x80195460,%eax
80103271:	85 c0                	test   %eax,%eax
80103273:	74 0d                	je     80103282 <end_op+0x44>
    panic("log.committing");
80103275:	83 ec 0c             	sub    $0xc,%esp
80103278:	68 b9 a8 10 80       	push   $0x8010a8b9
8010327d:	e8 43 d3 ff ff       	call   801005c5 <panic>
  if(log.outstanding == 0){
80103282:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103287:	85 c0                	test   %eax,%eax
80103289:	75 13                	jne    8010329e <end_op+0x60>
    do_commit = 1;
8010328b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103292:	c7 05 60 54 19 80 01 	movl   $0x1,0x80195460
80103299:	00 00 00 
8010329c:	eb 10                	jmp    801032ae <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010329e:	83 ec 0c             	sub    $0xc,%esp
801032a1:	68 20 54 19 80       	push   $0x80195420
801032a6:	e8 8e 13 00 00       	call   80104639 <wakeup>
801032ab:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801032ae:	83 ec 0c             	sub    $0xc,%esp
801032b1:	68 20 54 19 80       	push   $0x80195420
801032b6:	e8 7a 18 00 00       	call   80104b35 <release>
801032bb:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801032be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801032c2:	74 3f                	je     80103303 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801032c4:	e8 fa 00 00 00       	call   801033c3 <commit>
    acquire(&log.lock);
801032c9:	83 ec 0c             	sub    $0xc,%esp
801032cc:	68 20 54 19 80       	push   $0x80195420
801032d1:	e8 ed 17 00 00       	call   80104ac3 <acquire>
801032d6:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
801032d9:	c7 05 60 54 19 80 00 	movl   $0x0,0x80195460
801032e0:	00 00 00 
    wakeup(&log);
801032e3:	83 ec 0c             	sub    $0xc,%esp
801032e6:	68 20 54 19 80       	push   $0x80195420
801032eb:	e8 49 13 00 00       	call   80104639 <wakeup>
801032f0:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801032f3:	83 ec 0c             	sub    $0xc,%esp
801032f6:	68 20 54 19 80       	push   $0x80195420
801032fb:	e8 35 18 00 00       	call   80104b35 <release>
80103300:	83 c4 10             	add    $0x10,%esp
  }
}
80103303:	90                   	nop
80103304:	c9                   	leave
80103305:	c3                   	ret

80103306 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103306:	f3 0f 1e fb          	endbr32
8010330a:	55                   	push   %ebp
8010330b:	89 e5                	mov    %esp,%ebp
8010330d:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103310:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103317:	e9 95 00 00 00       	jmp    801033b1 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010331c:	8b 15 54 54 19 80    	mov    0x80195454,%edx
80103322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103325:	01 d0                	add    %edx,%eax
80103327:	83 c0 01             	add    $0x1,%eax
8010332a:	89 c2                	mov    %eax,%edx
8010332c:	a1 64 54 19 80       	mov    0x80195464,%eax
80103331:	83 ec 08             	sub    $0x8,%esp
80103334:	52                   	push   %edx
80103335:	50                   	push   %eax
80103336:	e8 ce ce ff ff       	call   80100209 <bread>
8010333b:	83 c4 10             	add    $0x10,%esp
8010333e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103341:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103344:	83 c0 10             	add    $0x10,%eax
80103347:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
8010334e:	89 c2                	mov    %eax,%edx
80103350:	a1 64 54 19 80       	mov    0x80195464,%eax
80103355:	83 ec 08             	sub    $0x8,%esp
80103358:	52                   	push   %edx
80103359:	50                   	push   %eax
8010335a:	e8 aa ce ff ff       	call   80100209 <bread>
8010335f:	83 c4 10             	add    $0x10,%esp
80103362:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103365:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103368:	8d 50 5c             	lea    0x5c(%eax),%edx
8010336b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010336e:	83 c0 5c             	add    $0x5c,%eax
80103371:	83 ec 04             	sub    $0x4,%esp
80103374:	68 00 02 00 00       	push   $0x200
80103379:	52                   	push   %edx
8010337a:	50                   	push   %eax
8010337b:	e8 99 1a 00 00       	call   80104e19 <memmove>
80103380:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103383:	83 ec 0c             	sub    $0xc,%esp
80103386:	ff 75 f0             	push   -0x10(%ebp)
80103389:	e8 b8 ce ff ff       	call   80100246 <bwrite>
8010338e:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103391:	83 ec 0c             	sub    $0xc,%esp
80103394:	ff 75 ec             	push   -0x14(%ebp)
80103397:	e8 f7 ce ff ff       	call   80100293 <brelse>
8010339c:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010339f:	83 ec 0c             	sub    $0xc,%esp
801033a2:	ff 75 f0             	push   -0x10(%ebp)
801033a5:	e8 e9 ce ff ff       	call   80100293 <brelse>
801033aa:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801033ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033b1:	a1 68 54 19 80       	mov    0x80195468,%eax
801033b6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801033b9:	0f 8c 5d ff ff ff    	jl     8010331c <write_log+0x16>
  }
}
801033bf:	90                   	nop
801033c0:	90                   	nop
801033c1:	c9                   	leave
801033c2:	c3                   	ret

801033c3 <commit>:

static void
commit()
{
801033c3:	f3 0f 1e fb          	endbr32
801033c7:	55                   	push   %ebp
801033c8:	89 e5                	mov    %esp,%ebp
801033ca:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801033cd:	a1 68 54 19 80       	mov    0x80195468,%eax
801033d2:	85 c0                	test   %eax,%eax
801033d4:	7e 1e                	jle    801033f4 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
801033d6:	e8 2b ff ff ff       	call   80103306 <write_log>
    write_head();    // Write header to disk -- the real commit
801033db:	e8 21 fd ff ff       	call   80103101 <write_head>
    install_trans(); // Now install writes to home locations
801033e0:	e8 e7 fb ff ff       	call   80102fcc <install_trans>
    log.lh.n = 0;
801033e5:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
801033ec:	00 00 00 
    write_head();    // Erase the transaction from the log
801033ef:	e8 0d fd ff ff       	call   80103101 <write_head>
  }
}
801033f4:	90                   	nop
801033f5:	c9                   	leave
801033f6:	c3                   	ret

801033f7 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801033f7:	f3 0f 1e fb          	endbr32
801033fb:	55                   	push   %ebp
801033fc:	89 e5                	mov    %esp,%ebp
801033fe:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103401:	a1 68 54 19 80       	mov    0x80195468,%eax
80103406:	83 f8 1d             	cmp    $0x1d,%eax
80103409:	7f 12                	jg     8010341d <log_write+0x26>
8010340b:	a1 68 54 19 80       	mov    0x80195468,%eax
80103410:	8b 15 58 54 19 80    	mov    0x80195458,%edx
80103416:	83 ea 01             	sub    $0x1,%edx
80103419:	39 d0                	cmp    %edx,%eax
8010341b:	7c 0d                	jl     8010342a <log_write+0x33>
    panic("too big a transaction");
8010341d:	83 ec 0c             	sub    $0xc,%esp
80103420:	68 c8 a8 10 80       	push   $0x8010a8c8
80103425:	e8 9b d1 ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
8010342a:	a1 5c 54 19 80       	mov    0x8019545c,%eax
8010342f:	85 c0                	test   %eax,%eax
80103431:	7f 0d                	jg     80103440 <log_write+0x49>
    panic("log_write outside of trans");
80103433:	83 ec 0c             	sub    $0xc,%esp
80103436:	68 de a8 10 80       	push   $0x8010a8de
8010343b:	e8 85 d1 ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
80103440:	83 ec 0c             	sub    $0xc,%esp
80103443:	68 20 54 19 80       	push   $0x80195420
80103448:	e8 76 16 00 00       	call   80104ac3 <acquire>
8010344d:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103450:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103457:	eb 1d                	jmp    80103476 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103459:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010345c:	83 c0 10             	add    $0x10,%eax
8010345f:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103466:	89 c2                	mov    %eax,%edx
80103468:	8b 45 08             	mov    0x8(%ebp),%eax
8010346b:	8b 40 08             	mov    0x8(%eax),%eax
8010346e:	39 c2                	cmp    %eax,%edx
80103470:	74 10                	je     80103482 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103472:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103476:	a1 68 54 19 80       	mov    0x80195468,%eax
8010347b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010347e:	7c d9                	jl     80103459 <log_write+0x62>
80103480:	eb 01                	jmp    80103483 <log_write+0x8c>
      break;
80103482:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103483:	8b 45 08             	mov    0x8(%ebp),%eax
80103486:	8b 40 08             	mov    0x8(%eax),%eax
80103489:	89 c2                	mov    %eax,%edx
8010348b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010348e:	83 c0 10             	add    $0x10,%eax
80103491:	89 14 85 2c 54 19 80 	mov    %edx,-0x7fe6abd4(,%eax,4)
  if (i == log.lh.n)
80103498:	a1 68 54 19 80       	mov    0x80195468,%eax
8010349d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034a0:	75 0d                	jne    801034af <log_write+0xb8>
    log.lh.n++;
801034a2:	a1 68 54 19 80       	mov    0x80195468,%eax
801034a7:	83 c0 01             	add    $0x1,%eax
801034aa:	a3 68 54 19 80       	mov    %eax,0x80195468
  b->flags |= B_DIRTY; // prevent eviction
801034af:	8b 45 08             	mov    0x8(%ebp),%eax
801034b2:	8b 00                	mov    (%eax),%eax
801034b4:	83 c8 04             	or     $0x4,%eax
801034b7:	89 c2                	mov    %eax,%edx
801034b9:	8b 45 08             	mov    0x8(%ebp),%eax
801034bc:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801034be:	83 ec 0c             	sub    $0xc,%esp
801034c1:	68 20 54 19 80       	push   $0x80195420
801034c6:	e8 6a 16 00 00       	call   80104b35 <release>
801034cb:	83 c4 10             	add    $0x10,%esp
}
801034ce:	90                   	nop
801034cf:	c9                   	leave
801034d0:	c3                   	ret

801034d1 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801034d1:	55                   	push   %ebp
801034d2:	89 e5                	mov    %esp,%ebp
801034d4:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801034d7:	8b 55 08             	mov    0x8(%ebp),%edx
801034da:	8b 45 0c             	mov    0xc(%ebp),%eax
801034dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
801034e0:	f0 87 02             	lock xchg %eax,(%edx)
801034e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801034e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801034e9:	c9                   	leave
801034ea:	c3                   	ret

801034eb <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801034eb:	f3 0f 1e fb          	endbr32
801034ef:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801034f3:	83 e4 f0             	and    $0xfffffff0,%esp
801034f6:	ff 71 fc             	push   -0x4(%ecx)
801034f9:	55                   	push   %ebp
801034fa:	89 e5                	mov    %esp,%ebp
801034fc:	51                   	push   %ecx
801034fd:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103500:	e8 1d 4e 00 00       	call   80108322 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103505:	83 ec 08             	sub    $0x8,%esp
80103508:	68 00 00 40 80       	push   $0x80400000
8010350d:	68 00 90 19 80       	push   $0x80199000
80103512:	e8 73 f2 ff ff       	call   8010278a <kinit1>
80103517:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010351a:	e8 a4 43 00 00       	call   801078c3 <kvmalloc>
  mpinit_uefi();
8010351f:	e8 b7 4b 00 00       	call   801080db <mpinit_uefi>
  lapicinit();     // interrupt controller
80103524:	e8 f0 f5 ff ff       	call   80102b19 <lapicinit>
  seginit();       // segment descriptors
80103529:	e8 1c 3e 00 00       	call   8010734a <seginit>
  picinit();    // disable pic
8010352e:	e8 a9 01 00 00       	call   801036dc <picinit>
  ioapicinit();    // another interrupt controller
80103533:	e8 65 f1 ff ff       	call   8010269d <ioapicinit>
  consoleinit();   // console hardware
80103538:	e8 fc d5 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
8010353d:	e8 91 31 00 00       	call   801066d3 <uartinit>
  pinit();         // process table
80103542:	e8 e2 05 00 00       	call   80103b29 <pinit>
  tvinit();        // trap vectors
80103547:	e8 b2 2c 00 00       	call   801061fe <tvinit>
  binit();         // buffer cache
8010354c:	e8 15 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103551:	e8 e8 da ff ff       	call   8010103e <fileinit>
  ideinit();       // disk 
80103556:	e8 cc 6f 00 00       	call   8010a527 <ideinit>
  startothers();   // start other processors
8010355b:	e8 92 00 00 00       	call   801035f2 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103560:	83 ec 08             	sub    $0x8,%esp
80103563:	68 00 00 00 a0       	push   $0xa0000000
80103568:	68 00 00 40 80       	push   $0x80400000
8010356d:	e8 55 f2 ff ff       	call   801027c7 <kinit2>
80103572:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103575:	e8 1b 50 00 00       	call   80108595 <pci_init>
  arp_scan();
8010357a:	e8 94 5d 00 00       	call   80109313 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
8010357f:	e8 ab 07 00 00       	call   80103d2f <userinit>
  mpmain();        // finish this processor's setup
80103584:	e8 1e 00 00 00       	call   801035a7 <mpmain>

80103589 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103589:	f3 0f 1e fb          	endbr32
8010358d:	55                   	push   %ebp
8010358e:	89 e5                	mov    %esp,%ebp
80103590:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103593:	e8 47 43 00 00       	call   801078df <switchkvm>
  seginit();
80103598:	e8 ad 3d 00 00       	call   8010734a <seginit>
  lapicinit();
8010359d:	e8 77 f5 ff ff       	call   80102b19 <lapicinit>
  mpmain();
801035a2:	e8 00 00 00 00       	call   801035a7 <mpmain>

801035a7 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801035a7:	f3 0f 1e fb          	endbr32
801035ab:	55                   	push   %ebp
801035ac:	89 e5                	mov    %esp,%ebp
801035ae:	53                   	push   %ebx
801035af:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801035b2:	e8 94 05 00 00       	call   80103b4b <cpuid>
801035b7:	89 c3                	mov    %eax,%ebx
801035b9:	e8 8d 05 00 00       	call   80103b4b <cpuid>
801035be:	83 ec 04             	sub    $0x4,%esp
801035c1:	53                   	push   %ebx
801035c2:	50                   	push   %eax
801035c3:	68 f9 a8 10 80       	push   $0x8010a8f9
801035c8:	e8 3f ce ff ff       	call   8010040c <cprintf>
801035cd:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801035d0:	e8 a3 2d 00 00       	call   80106378 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801035d5:	e8 90 05 00 00       	call   80103b6a <mycpu>
801035da:	05 a0 00 00 00       	add    $0xa0,%eax
801035df:	83 ec 08             	sub    $0x8,%esp
801035e2:	6a 01                	push   $0x1
801035e4:	50                   	push   %eax
801035e5:	e8 e7 fe ff ff       	call   801034d1 <xchg>
801035ea:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801035ed:	e8 35 0d 00 00       	call   80104327 <scheduler>

801035f2 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801035f2:	f3 0f 1e fb          	endbr32
801035f6:	55                   	push   %ebp
801035f7:	89 e5                	mov    %esp,%ebp
801035f9:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801035fc:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103603:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103608:	83 ec 04             	sub    $0x4,%esp
8010360b:	50                   	push   %eax
8010360c:	68 18 f5 10 80       	push   $0x8010f518
80103611:	ff 75 f0             	push   -0x10(%ebp)
80103614:	e8 00 18 00 00       	call   80104e19 <memmove>
80103619:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010361c:	c7 45 f4 c0 7d 19 80 	movl   $0x80197dc0,-0xc(%ebp)
80103623:	eb 79                	jmp    8010369e <startothers+0xac>
    if(c == mycpu()){  // We've started already.
80103625:	e8 40 05 00 00       	call   80103b6a <mycpu>
8010362a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010362d:	74 67                	je     80103696 <startothers+0xa4>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010362f:	e8 9b f2 ff ff       	call   801028cf <kalloc>
80103634:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103637:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010363a:	83 e8 04             	sub    $0x4,%eax
8010363d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103640:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103646:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103648:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010364b:	83 e8 08             	sub    $0x8,%eax
8010364e:	c7 00 89 35 10 80    	movl   $0x80103589,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103654:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
80103659:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010365f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103662:	83 e8 0c             	sub    $0xc,%eax
80103665:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103667:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010366a:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103673:	0f b6 00             	movzbl (%eax),%eax
80103676:	0f b6 c0             	movzbl %al,%eax
80103679:	83 ec 08             	sub    $0x8,%esp
8010367c:	52                   	push   %edx
8010367d:	50                   	push   %eax
8010367e:	e8 08 f6 ff ff       	call   80102c8b <lapicstartap>
80103683:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103686:	90                   	nop
80103687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010368a:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103690:	85 c0                	test   %eax,%eax
80103692:	74 f3                	je     80103687 <startothers+0x95>
80103694:	eb 01                	jmp    80103697 <startothers+0xa5>
      continue;
80103696:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103697:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
8010369e:	a1 80 80 19 80       	mov    0x80198080,%eax
801036a3:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801036a9:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
801036ae:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801036b1:	0f 82 6e ff ff ff    	jb     80103625 <startothers+0x33>
      ;
  }
}
801036b7:	90                   	nop
801036b8:	90                   	nop
801036b9:	c9                   	leave
801036ba:	c3                   	ret

801036bb <outb>:
{
801036bb:	55                   	push   %ebp
801036bc:	89 e5                	mov    %esp,%ebp
801036be:	83 ec 08             	sub    $0x8,%esp
801036c1:	8b 45 08             	mov    0x8(%ebp),%eax
801036c4:	8b 55 0c             	mov    0xc(%ebp),%edx
801036c7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801036cb:	89 d0                	mov    %edx,%eax
801036cd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801036d0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801036d4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801036d8:	ee                   	out    %al,(%dx)
}
801036d9:	90                   	nop
801036da:	c9                   	leave
801036db:	c3                   	ret

801036dc <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
801036dc:	f3 0f 1e fb          	endbr32
801036e0:	55                   	push   %ebp
801036e1:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801036e3:	68 ff 00 00 00       	push   $0xff
801036e8:	6a 21                	push   $0x21
801036ea:	e8 cc ff ff ff       	call   801036bb <outb>
801036ef:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
801036f2:	68 ff 00 00 00       	push   $0xff
801036f7:	68 a1 00 00 00       	push   $0xa1
801036fc:	e8 ba ff ff ff       	call   801036bb <outb>
80103701:	83 c4 08             	add    $0x8,%esp
}
80103704:	90                   	nop
80103705:	c9                   	leave
80103706:	c3                   	ret

80103707 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103707:	f3 0f 1e fb          	endbr32
8010370b:	55                   	push   %ebp
8010370c:	89 e5                	mov    %esp,%ebp
8010370e:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103711:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103718:	8b 45 0c             	mov    0xc(%ebp),%eax
8010371b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103721:	8b 45 0c             	mov    0xc(%ebp),%eax
80103724:	8b 10                	mov    (%eax),%edx
80103726:	8b 45 08             	mov    0x8(%ebp),%eax
80103729:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010372b:	e8 30 d9 ff ff       	call   80101060 <filealloc>
80103730:	8b 55 08             	mov    0x8(%ebp),%edx
80103733:	89 02                	mov    %eax,(%edx)
80103735:	8b 45 08             	mov    0x8(%ebp),%eax
80103738:	8b 00                	mov    (%eax),%eax
8010373a:	85 c0                	test   %eax,%eax
8010373c:	0f 84 c8 00 00 00    	je     8010380a <pipealloc+0x103>
80103742:	e8 19 d9 ff ff       	call   80101060 <filealloc>
80103747:	8b 55 0c             	mov    0xc(%ebp),%edx
8010374a:	89 02                	mov    %eax,(%edx)
8010374c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010374f:	8b 00                	mov    (%eax),%eax
80103751:	85 c0                	test   %eax,%eax
80103753:	0f 84 b1 00 00 00    	je     8010380a <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103759:	e8 71 f1 ff ff       	call   801028cf <kalloc>
8010375e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103761:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103765:	0f 84 a2 00 00 00    	je     8010380d <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
8010376b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010376e:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103775:	00 00 00 
  p->writeopen = 1;
80103778:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010377b:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103782:	00 00 00 
  p->nwrite = 0;
80103785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103788:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010378f:	00 00 00 
  p->nread = 0;
80103792:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103795:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010379c:	00 00 00 
  initlock(&p->lock, "pipe");
8010379f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037a2:	83 ec 08             	sub    $0x8,%esp
801037a5:	68 0d a9 10 80       	push   $0x8010a90d
801037aa:	50                   	push   %eax
801037ab:	e8 ed 12 00 00       	call   80104a9d <initlock>
801037b0:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801037b3:	8b 45 08             	mov    0x8(%ebp),%eax
801037b6:	8b 00                	mov    (%eax),%eax
801037b8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801037be:	8b 45 08             	mov    0x8(%ebp),%eax
801037c1:	8b 00                	mov    (%eax),%eax
801037c3:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801037c7:	8b 45 08             	mov    0x8(%ebp),%eax
801037ca:	8b 00                	mov    (%eax),%eax
801037cc:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801037d0:	8b 45 08             	mov    0x8(%ebp),%eax
801037d3:	8b 00                	mov    (%eax),%eax
801037d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037d8:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801037db:	8b 45 0c             	mov    0xc(%ebp),%eax
801037de:	8b 00                	mov    (%eax),%eax
801037e0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801037e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801037e9:	8b 00                	mov    (%eax),%eax
801037eb:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801037ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801037f2:	8b 00                	mov    (%eax),%eax
801037f4:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801037f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801037fb:	8b 00                	mov    (%eax),%eax
801037fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103800:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103803:	b8 00 00 00 00       	mov    $0x0,%eax
80103808:	eb 51                	jmp    8010385b <pipealloc+0x154>
    goto bad;
8010380a:	90                   	nop
8010380b:	eb 01                	jmp    8010380e <pipealloc+0x107>
    goto bad;
8010380d:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
8010380e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103812:	74 0e                	je     80103822 <pipealloc+0x11b>
    kfree((char*)p);
80103814:	83 ec 0c             	sub    $0xc,%esp
80103817:	ff 75 f4             	push   -0xc(%ebp)
8010381a:	e8 12 f0 ff ff       	call   80102831 <kfree>
8010381f:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103822:	8b 45 08             	mov    0x8(%ebp),%eax
80103825:	8b 00                	mov    (%eax),%eax
80103827:	85 c0                	test   %eax,%eax
80103829:	74 11                	je     8010383c <pipealloc+0x135>
    fileclose(*f0);
8010382b:	8b 45 08             	mov    0x8(%ebp),%eax
8010382e:	8b 00                	mov    (%eax),%eax
80103830:	83 ec 0c             	sub    $0xc,%esp
80103833:	50                   	push   %eax
80103834:	e8 ed d8 ff ff       	call   80101126 <fileclose>
80103839:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010383c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010383f:	8b 00                	mov    (%eax),%eax
80103841:	85 c0                	test   %eax,%eax
80103843:	74 11                	je     80103856 <pipealloc+0x14f>
    fileclose(*f1);
80103845:	8b 45 0c             	mov    0xc(%ebp),%eax
80103848:	8b 00                	mov    (%eax),%eax
8010384a:	83 ec 0c             	sub    $0xc,%esp
8010384d:	50                   	push   %eax
8010384e:	e8 d3 d8 ff ff       	call   80101126 <fileclose>
80103853:	83 c4 10             	add    $0x10,%esp
  return -1;
80103856:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010385b:	c9                   	leave
8010385c:	c3                   	ret

8010385d <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010385d:	f3 0f 1e fb          	endbr32
80103861:	55                   	push   %ebp
80103862:	89 e5                	mov    %esp,%ebp
80103864:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103867:	8b 45 08             	mov    0x8(%ebp),%eax
8010386a:	83 ec 0c             	sub    $0xc,%esp
8010386d:	50                   	push   %eax
8010386e:	e8 50 12 00 00       	call   80104ac3 <acquire>
80103873:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103876:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010387a:	74 23                	je     8010389f <pipeclose+0x42>
    p->writeopen = 0;
8010387c:	8b 45 08             	mov    0x8(%ebp),%eax
8010387f:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103886:	00 00 00 
    wakeup(&p->nread);
80103889:	8b 45 08             	mov    0x8(%ebp),%eax
8010388c:	05 34 02 00 00       	add    $0x234,%eax
80103891:	83 ec 0c             	sub    $0xc,%esp
80103894:	50                   	push   %eax
80103895:	e8 9f 0d 00 00       	call   80104639 <wakeup>
8010389a:	83 c4 10             	add    $0x10,%esp
8010389d:	eb 21                	jmp    801038c0 <pipeclose+0x63>
  } else {
    p->readopen = 0;
8010389f:	8b 45 08             	mov    0x8(%ebp),%eax
801038a2:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801038a9:	00 00 00 
    wakeup(&p->nwrite);
801038ac:	8b 45 08             	mov    0x8(%ebp),%eax
801038af:	05 38 02 00 00       	add    $0x238,%eax
801038b4:	83 ec 0c             	sub    $0xc,%esp
801038b7:	50                   	push   %eax
801038b8:	e8 7c 0d 00 00       	call   80104639 <wakeup>
801038bd:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801038c0:	8b 45 08             	mov    0x8(%ebp),%eax
801038c3:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801038c9:	85 c0                	test   %eax,%eax
801038cb:	75 2c                	jne    801038f9 <pipeclose+0x9c>
801038cd:	8b 45 08             	mov    0x8(%ebp),%eax
801038d0:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038d6:	85 c0                	test   %eax,%eax
801038d8:	75 1f                	jne    801038f9 <pipeclose+0x9c>
    release(&p->lock);
801038da:	8b 45 08             	mov    0x8(%ebp),%eax
801038dd:	83 ec 0c             	sub    $0xc,%esp
801038e0:	50                   	push   %eax
801038e1:	e8 4f 12 00 00       	call   80104b35 <release>
801038e6:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801038e9:	83 ec 0c             	sub    $0xc,%esp
801038ec:	ff 75 08             	push   0x8(%ebp)
801038ef:	e8 3d ef ff ff       	call   80102831 <kfree>
801038f4:	83 c4 10             	add    $0x10,%esp
801038f7:	eb 10                	jmp    80103909 <pipeclose+0xac>
  } else
    release(&p->lock);
801038f9:	8b 45 08             	mov    0x8(%ebp),%eax
801038fc:	83 ec 0c             	sub    $0xc,%esp
801038ff:	50                   	push   %eax
80103900:	e8 30 12 00 00       	call   80104b35 <release>
80103905:	83 c4 10             	add    $0x10,%esp
}
80103908:	90                   	nop
80103909:	90                   	nop
8010390a:	c9                   	leave
8010390b:	c3                   	ret

8010390c <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010390c:	f3 0f 1e fb          	endbr32
80103910:	55                   	push   %ebp
80103911:	89 e5                	mov    %esp,%ebp
80103913:	53                   	push   %ebx
80103914:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103917:	8b 45 08             	mov    0x8(%ebp),%eax
8010391a:	83 ec 0c             	sub    $0xc,%esp
8010391d:	50                   	push   %eax
8010391e:	e8 a0 11 00 00       	call   80104ac3 <acquire>
80103923:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103926:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010392d:	e9 ad 00 00 00       	jmp    801039df <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103932:	8b 45 08             	mov    0x8(%ebp),%eax
80103935:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010393b:	85 c0                	test   %eax,%eax
8010393d:	74 0c                	je     8010394b <pipewrite+0x3f>
8010393f:	e8 a2 02 00 00       	call   80103be6 <myproc>
80103944:	8b 40 24             	mov    0x24(%eax),%eax
80103947:	85 c0                	test   %eax,%eax
80103949:	74 19                	je     80103964 <pipewrite+0x58>
        release(&p->lock);
8010394b:	8b 45 08             	mov    0x8(%ebp),%eax
8010394e:	83 ec 0c             	sub    $0xc,%esp
80103951:	50                   	push   %eax
80103952:	e8 de 11 00 00       	call   80104b35 <release>
80103957:	83 c4 10             	add    $0x10,%esp
        return -1;
8010395a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010395f:	e9 a9 00 00 00       	jmp    80103a0d <pipewrite+0x101>
      }
      wakeup(&p->nread);
80103964:	8b 45 08             	mov    0x8(%ebp),%eax
80103967:	05 34 02 00 00       	add    $0x234,%eax
8010396c:	83 ec 0c             	sub    $0xc,%esp
8010396f:	50                   	push   %eax
80103970:	e8 c4 0c 00 00       	call   80104639 <wakeup>
80103975:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103978:	8b 45 08             	mov    0x8(%ebp),%eax
8010397b:	8b 55 08             	mov    0x8(%ebp),%edx
8010397e:	81 c2 38 02 00 00    	add    $0x238,%edx
80103984:	83 ec 08             	sub    $0x8,%esp
80103987:	50                   	push   %eax
80103988:	52                   	push   %edx
80103989:	e8 bc 0b 00 00       	call   8010454a <sleep>
8010398e:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103991:	8b 45 08             	mov    0x8(%ebp),%eax
80103994:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010399a:	8b 45 08             	mov    0x8(%ebp),%eax
8010399d:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801039a3:	05 00 02 00 00       	add    $0x200,%eax
801039a8:	39 c2                	cmp    %eax,%edx
801039aa:	74 86                	je     80103932 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801039ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801039af:	8b 45 0c             	mov    0xc(%ebp),%eax
801039b2:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801039b5:	8b 45 08             	mov    0x8(%ebp),%eax
801039b8:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801039be:	8d 48 01             	lea    0x1(%eax),%ecx
801039c1:	8b 55 08             	mov    0x8(%ebp),%edx
801039c4:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801039ca:	25 ff 01 00 00       	and    $0x1ff,%eax
801039cf:	89 c1                	mov    %eax,%ecx
801039d1:	0f b6 13             	movzbl (%ebx),%edx
801039d4:	8b 45 08             	mov    0x8(%ebp),%eax
801039d7:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
801039db:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e2:	3b 45 10             	cmp    0x10(%ebp),%eax
801039e5:	7c aa                	jl     80103991 <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801039e7:	8b 45 08             	mov    0x8(%ebp),%eax
801039ea:	05 34 02 00 00       	add    $0x234,%eax
801039ef:	83 ec 0c             	sub    $0xc,%esp
801039f2:	50                   	push   %eax
801039f3:	e8 41 0c 00 00       	call   80104639 <wakeup>
801039f8:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801039fb:	8b 45 08             	mov    0x8(%ebp),%eax
801039fe:	83 ec 0c             	sub    $0xc,%esp
80103a01:	50                   	push   %eax
80103a02:	e8 2e 11 00 00       	call   80104b35 <release>
80103a07:	83 c4 10             	add    $0x10,%esp
  return n;
80103a0a:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a10:	c9                   	leave
80103a11:	c3                   	ret

80103a12 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103a12:	f3 0f 1e fb          	endbr32
80103a16:	55                   	push   %ebp
80103a17:	89 e5                	mov    %esp,%ebp
80103a19:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103a1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a1f:	83 ec 0c             	sub    $0xc,%esp
80103a22:	50                   	push   %eax
80103a23:	e8 9b 10 00 00       	call   80104ac3 <acquire>
80103a28:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a2b:	eb 3e                	jmp    80103a6b <piperead+0x59>
    if(myproc()->killed){
80103a2d:	e8 b4 01 00 00       	call   80103be6 <myproc>
80103a32:	8b 40 24             	mov    0x24(%eax),%eax
80103a35:	85 c0                	test   %eax,%eax
80103a37:	74 19                	je     80103a52 <piperead+0x40>
      release(&p->lock);
80103a39:	8b 45 08             	mov    0x8(%ebp),%eax
80103a3c:	83 ec 0c             	sub    $0xc,%esp
80103a3f:	50                   	push   %eax
80103a40:	e8 f0 10 00 00       	call   80104b35 <release>
80103a45:	83 c4 10             	add    $0x10,%esp
      return -1;
80103a48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a4d:	e9 be 00 00 00       	jmp    80103b10 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103a52:	8b 45 08             	mov    0x8(%ebp),%eax
80103a55:	8b 55 08             	mov    0x8(%ebp),%edx
80103a58:	81 c2 34 02 00 00    	add    $0x234,%edx
80103a5e:	83 ec 08             	sub    $0x8,%esp
80103a61:	50                   	push   %eax
80103a62:	52                   	push   %edx
80103a63:	e8 e2 0a 00 00       	call   8010454a <sleep>
80103a68:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a6e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a74:	8b 45 08             	mov    0x8(%ebp),%eax
80103a77:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a7d:	39 c2                	cmp    %eax,%edx
80103a7f:	75 0d                	jne    80103a8e <piperead+0x7c>
80103a81:	8b 45 08             	mov    0x8(%ebp),%eax
80103a84:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103a8a:	85 c0                	test   %eax,%eax
80103a8c:	75 9f                	jne    80103a2d <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a8e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a95:	eb 48                	jmp    80103adf <piperead+0xcd>
    if(p->nread == p->nwrite)
80103a97:	8b 45 08             	mov    0x8(%ebp),%eax
80103a9a:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80103aa3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103aa9:	39 c2                	cmp    %eax,%edx
80103aab:	74 3c                	je     80103ae9 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103aad:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab0:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103ab6:	8d 48 01             	lea    0x1(%eax),%ecx
80103ab9:	8b 55 08             	mov    0x8(%ebp),%edx
80103abc:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103ac2:	25 ff 01 00 00       	and    $0x1ff,%eax
80103ac7:	89 c1                	mov    %eax,%ecx
80103ac9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103acc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103acf:	01 c2                	add    %eax,%edx
80103ad1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ad4:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103ad9:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103adb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae2:	3b 45 10             	cmp    0x10(%ebp),%eax
80103ae5:	7c b0                	jl     80103a97 <piperead+0x85>
80103ae7:	eb 01                	jmp    80103aea <piperead+0xd8>
      break;
80103ae9:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103aea:	8b 45 08             	mov    0x8(%ebp),%eax
80103aed:	05 38 02 00 00       	add    $0x238,%eax
80103af2:	83 ec 0c             	sub    $0xc,%esp
80103af5:	50                   	push   %eax
80103af6:	e8 3e 0b 00 00       	call   80104639 <wakeup>
80103afb:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103afe:	8b 45 08             	mov    0x8(%ebp),%eax
80103b01:	83 ec 0c             	sub    $0xc,%esp
80103b04:	50                   	push   %eax
80103b05:	e8 2b 10 00 00       	call   80104b35 <release>
80103b0a:	83 c4 10             	add    $0x10,%esp
  return i;
80103b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b10:	c9                   	leave
80103b11:	c3                   	ret

80103b12 <readeflags>:
{
80103b12:	55                   	push   %ebp
80103b13:	89 e5                	mov    %esp,%ebp
80103b15:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103b18:	9c                   	pushf
80103b19:	58                   	pop    %eax
80103b1a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103b1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103b20:	c9                   	leave
80103b21:	c3                   	ret

80103b22 <sti>:
{
80103b22:	55                   	push   %ebp
80103b23:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103b25:	fb                   	sti
}
80103b26:	90                   	nop
80103b27:	5d                   	pop    %ebp
80103b28:	c3                   	ret

80103b29 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103b29:	f3 0f 1e fb          	endbr32
80103b2d:	55                   	push   %ebp
80103b2e:	89 e5                	mov    %esp,%ebp
80103b30:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103b33:	83 ec 08             	sub    $0x8,%esp
80103b36:	68 14 a9 10 80       	push   $0x8010a914
80103b3b:	68 00 55 19 80       	push   $0x80195500
80103b40:	e8 58 0f 00 00       	call   80104a9d <initlock>
80103b45:	83 c4 10             	add    $0x10,%esp
}
80103b48:	90                   	nop
80103b49:	c9                   	leave
80103b4a:	c3                   	ret

80103b4b <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103b4b:	f3 0f 1e fb          	endbr32
80103b4f:	55                   	push   %ebp
80103b50:	89 e5                	mov    %esp,%ebp
80103b52:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103b55:	e8 10 00 00 00       	call   80103b6a <mycpu>
80103b5a:	2d c0 7d 19 80       	sub    $0x80197dc0,%eax
80103b5f:	c1 f8 04             	sar    $0x4,%eax
80103b62:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103b68:	c9                   	leave
80103b69:	c3                   	ret

80103b6a <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103b6a:	f3 0f 1e fb          	endbr32
80103b6e:	55                   	push   %ebp
80103b6f:	89 e5                	mov    %esp,%ebp
80103b71:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103b74:	e8 99 ff ff ff       	call   80103b12 <readeflags>
80103b79:	25 00 02 00 00       	and    $0x200,%eax
80103b7e:	85 c0                	test   %eax,%eax
80103b80:	74 0d                	je     80103b8f <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80103b82:	83 ec 0c             	sub    $0xc,%esp
80103b85:	68 1c a9 10 80       	push   $0x8010a91c
80103b8a:	e8 36 ca ff ff       	call   801005c5 <panic>
  }

  apicid = lapicid();
80103b8f:	e8 a8 f0 ff ff       	call   80102c3c <lapicid>
80103b94:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103b97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b9e:	eb 2d                	jmp    80103bcd <mycpu+0x63>
    if (cpus[i].apicid == apicid){
80103ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba3:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103ba9:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103bae:	0f b6 00             	movzbl (%eax),%eax
80103bb1:	0f b6 c0             	movzbl %al,%eax
80103bb4:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103bb7:	75 10                	jne    80103bc9 <mycpu+0x5f>
      return &cpus[i];
80103bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbc:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103bc2:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103bc7:	eb 1b                	jmp    80103be4 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80103bc9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103bcd:	a1 80 80 19 80       	mov    0x80198080,%eax
80103bd2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103bd5:	7c c9                	jl     80103ba0 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80103bd7:	83 ec 0c             	sub    $0xc,%esp
80103bda:	68 42 a9 10 80       	push   $0x8010a942
80103bdf:	e8 e1 c9 ff ff       	call   801005c5 <panic>
}
80103be4:	c9                   	leave
80103be5:	c3                   	ret

80103be6 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103be6:	f3 0f 1e fb          	endbr32
80103bea:	55                   	push   %ebp
80103beb:	89 e5                	mov    %esp,%ebp
80103bed:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103bf0:	e8 4a 10 00 00       	call   80104c3f <pushcli>
  c = mycpu();
80103bf5:	e8 70 ff ff ff       	call   80103b6a <mycpu>
80103bfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c00:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103c06:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103c09:	e8 82 10 00 00       	call   80104c90 <popcli>
  return p;
80103c0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c11:	c9                   	leave
80103c12:	c3                   	ret

80103c13 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103c13:	f3 0f 1e fb          	endbr32
80103c17:	55                   	push   %ebp
80103c18:	89 e5                	mov    %esp,%ebp
80103c1a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;
  cprintf("[allocproc] in\n");
80103c1d:	83 ec 0c             	sub    $0xc,%esp
80103c20:	68 52 a9 10 80       	push   $0x8010a952
80103c25:	e8 e2 c7 ff ff       	call   8010040c <cprintf>
80103c2a:	83 c4 10             	add    $0x10,%esp
  acquire(&ptable.lock);
80103c2d:	83 ec 0c             	sub    $0xc,%esp
80103c30:	68 00 55 19 80       	push   $0x80195500
80103c35:	e8 89 0e 00 00       	call   80104ac3 <acquire>
80103c3a:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c3d:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80103c44:	eb 0e                	jmp    80103c54 <allocproc+0x41>
    if(p->state == UNUSED){
80103c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c49:	8b 40 0c             	mov    0xc(%eax),%eax
80103c4c:	85 c0                	test   %eax,%eax
80103c4e:	74 27                	je     80103c77 <allocproc+0x64>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c50:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103c54:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80103c5b:	72 e9                	jb     80103c46 <allocproc+0x33>
      goto found;
    }

  release(&ptable.lock);
80103c5d:	83 ec 0c             	sub    $0xc,%esp
80103c60:	68 00 55 19 80       	push   $0x80195500
80103c65:	e8 cb 0e 00 00       	call   80104b35 <release>
80103c6a:	83 c4 10             	add    $0x10,%esp
  return 0;
80103c6d:	b8 00 00 00 00       	mov    $0x0,%eax
80103c72:	e9 b6 00 00 00       	jmp    80103d2d <allocproc+0x11a>
      goto found;
80103c77:	90                   	nop
80103c78:	f3 0f 1e fb          	endbr32

found:
  p->state = EMBRYO;
80103c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7f:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103c86:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103c8b:	8d 50 01             	lea    0x1(%eax),%edx
80103c8e:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103c94:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c97:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103c9a:	83 ec 0c             	sub    $0xc,%esp
80103c9d:	68 00 55 19 80       	push   $0x80195500
80103ca2:	e8 8e 0e 00 00       	call   80104b35 <release>
80103ca7:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103caa:	e8 20 ec ff ff       	call   801028cf <kalloc>
80103caf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cb2:	89 42 08             	mov    %eax,0x8(%edx)
80103cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb8:	8b 40 08             	mov    0x8(%eax),%eax
80103cbb:	85 c0                	test   %eax,%eax
80103cbd:	75 11                	jne    80103cd0 <allocproc+0xbd>
    p->state = UNUSED;
80103cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103cc9:	b8 00 00 00 00       	mov    $0x0,%eax
80103cce:	eb 5d                	jmp    80103d2d <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
80103cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd3:	8b 40 08             	mov    0x8(%eax),%eax
80103cd6:	05 00 10 00 00       	add    $0x1000,%eax
80103cdb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103cde:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ce8:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103ceb:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103cef:	ba b8 61 10 80       	mov    $0x801061b8,%edx
80103cf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf7:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103cf9:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d00:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103d03:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d09:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d0c:	83 ec 04             	sub    $0x4,%esp
80103d0f:	6a 14                	push   $0x14
80103d11:	6a 00                	push   $0x0
80103d13:	50                   	push   %eax
80103d14:	e8 39 10 00 00       	call   80104d52 <memset>
80103d19:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d1f:	8b 40 1c             	mov    0x1c(%eax),%eax
80103d22:	ba 00 45 10 80       	mov    $0x80104500,%edx
80103d27:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103d2d:	c9                   	leave
80103d2e:	c3                   	ret

80103d2f <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103d2f:	f3 0f 1e fb          	endbr32
80103d33:	55                   	push   %ebp
80103d34:	89 e5                	mov    %esp,%ebp
80103d36:	83 ec 18             	sub    $0x18,%esp
  cprintf("[userinit] in \n");
80103d39:	83 ec 0c             	sub    $0xc,%esp
80103d3c:	68 62 a9 10 80       	push   $0x8010a962
80103d41:	e8 c6 c6 ff ff       	call   8010040c <cprintf>
80103d46:	83 c4 10             	add    $0x10,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103d49:	e8 c5 fe ff ff       	call   80103c13 <allocproc>
80103d4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d54:	a3 5c d0 18 80       	mov    %eax,0x8018d05c
  if((p->pgdir = setupkvm()) == 0){
80103d59:	e8 74 3a 00 00       	call   801077d2 <setupkvm>
80103d5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d61:	89 42 04             	mov    %eax,0x4(%edx)
80103d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d67:	8b 40 04             	mov    0x4(%eax),%eax
80103d6a:	85 c0                	test   %eax,%eax
80103d6c:	75 0d                	jne    80103d7b <userinit+0x4c>
    panic("userinit: out of memory?");
80103d6e:	83 ec 0c             	sub    $0xc,%esp
80103d71:	68 72 a9 10 80       	push   $0x8010a972
80103d76:	e8 4a c8 ff ff       	call   801005c5 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103d7b:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d83:	8b 40 04             	mov    0x4(%eax),%eax
80103d86:	83 ec 04             	sub    $0x4,%esp
80103d89:	52                   	push   %edx
80103d8a:	68 ec f4 10 80       	push   $0x8010f4ec
80103d8f:	50                   	push   %eax
80103d90:	e8 0a 3d 00 00       	call   80107a9f <inituvm>
80103d95:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d9b:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da4:	8b 40 18             	mov    0x18(%eax),%eax
80103da7:	83 ec 04             	sub    $0x4,%esp
80103daa:	6a 4c                	push   $0x4c
80103dac:	6a 00                	push   $0x0
80103dae:	50                   	push   %eax
80103daf:	e8 9e 0f 00 00       	call   80104d52 <memset>
80103db4:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dba:	8b 40 18             	mov    0x18(%eax),%eax
80103dbd:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc6:	8b 40 18             	mov    0x18(%eax),%eax
80103dc9:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd2:	8b 50 18             	mov    0x18(%eax),%edx
80103dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd8:	8b 40 18             	mov    0x18(%eax),%eax
80103ddb:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103ddf:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103de6:	8b 50 18             	mov    0x18(%eax),%edx
80103de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dec:	8b 40 18             	mov    0x18(%eax),%eax
80103def:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103df3:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dfa:	8b 40 18             	mov    0x18(%eax),%eax
80103dfd:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e07:	8b 40 18             	mov    0x18(%eax),%eax
80103e0a:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e14:	8b 40 18             	mov    0x18(%eax),%eax
80103e17:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e21:	83 c0 6c             	add    $0x6c,%eax
80103e24:	83 ec 04             	sub    $0x4,%esp
80103e27:	6a 10                	push   $0x10
80103e29:	68 8b a9 10 80       	push   $0x8010a98b
80103e2e:	50                   	push   %eax
80103e2f:	e8 39 11 00 00       	call   80104f6d <safestrcpy>
80103e34:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103e37:	83 ec 0c             	sub    $0xc,%esp
80103e3a:	68 94 a9 10 80       	push   $0x8010a994
80103e3f:	e8 e0 e7 ff ff       	call   80102624 <namei>
80103e44:	83 c4 10             	add    $0x10,%esp
80103e47:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e4a:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103e4d:	83 ec 0c             	sub    $0xc,%esp
80103e50:	68 00 55 19 80       	push   $0x80195500
80103e55:	e8 69 0c 00 00       	call   80104ac3 <acquire>
80103e5a:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e60:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e67:	83 ec 0c             	sub    $0xc,%esp
80103e6a:	68 00 55 19 80       	push   $0x80195500
80103e6f:	e8 c1 0c 00 00       	call   80104b35 <release>
80103e74:	83 c4 10             	add    $0x10,%esp
}
80103e77:	90                   	nop
80103e78:	c9                   	leave
80103e79:	c3                   	ret

80103e7a <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103e7a:	f3 0f 1e fb          	endbr32
80103e7e:	55                   	push   %ebp
80103e7f:	89 e5                	mov    %esp,%ebp
80103e81:	83 ec 18             	sub    $0x18,%esp
  cprintf("[growproc] in\n");
80103e84:	83 ec 0c             	sub    $0xc,%esp
80103e87:	68 96 a9 10 80       	push   $0x8010a996
80103e8c:	e8 7b c5 ff ff       	call   8010040c <cprintf>
80103e91:	83 c4 10             	add    $0x10,%esp
  uint sz;
  struct proc *curproc = myproc();
80103e94:	e8 4d fd ff ff       	call   80103be6 <myproc>
80103e99:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103e9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e9f:	8b 00                	mov    (%eax),%eax
80103ea1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103ea4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ea8:	7e 2e                	jle    80103ed8 <growproc+0x5e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103eaa:	8b 55 08             	mov    0x8(%ebp),%edx
80103ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eb0:	01 c2                	add    %eax,%edx
80103eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103eb5:	8b 40 04             	mov    0x4(%eax),%eax
80103eb8:	83 ec 04             	sub    $0x4,%esp
80103ebb:	52                   	push   %edx
80103ebc:	ff 75 f4             	push   -0xc(%ebp)
80103ebf:	50                   	push   %eax
80103ec0:	e8 1f 3d 00 00       	call   80107be4 <allocuvm>
80103ec5:	83 c4 10             	add    $0x10,%esp
80103ec8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ecb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ecf:	75 3b                	jne    80103f0c <growproc+0x92>
      return -1;
80103ed1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ed6:	eb 62                	jmp    80103f3a <growproc+0xc0>
  } else if(n < 0){
80103ed8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103edc:	79 2e                	jns    80103f0c <growproc+0x92>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ede:	8b 55 08             	mov    0x8(%ebp),%edx
80103ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ee4:	01 c2                	add    %eax,%edx
80103ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ee9:	8b 40 04             	mov    0x4(%eax),%eax
80103eec:	83 ec 04             	sub    $0x4,%esp
80103eef:	52                   	push   %edx
80103ef0:	ff 75 f4             	push   -0xc(%ebp)
80103ef3:	50                   	push   %eax
80103ef4:	e8 1a 3e 00 00       	call   80107d13 <deallocuvm>
80103ef9:	83 c4 10             	add    $0x10,%esp
80103efc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103eff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f03:	75 07                	jne    80103f0c <growproc+0x92>
      return -1;
80103f05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f0a:	eb 2e                	jmp    80103f3a <growproc+0xc0>
  }
  curproc->sz = sz;
80103f0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f12:	89 10                	mov    %edx,(%eax)
  cprintf("[growproc] sz %x\n",sz);
80103f14:	83 ec 08             	sub    $0x8,%esp
80103f17:	ff 75 f4             	push   -0xc(%ebp)
80103f1a:	68 a5 a9 10 80       	push   $0x8010a9a5
80103f1f:	e8 e8 c4 ff ff       	call   8010040c <cprintf>
80103f24:	83 c4 10             	add    $0x10,%esp
  switchuvm(curproc);
80103f27:	83 ec 0c             	sub    $0xc,%esp
80103f2a:	ff 75 f0             	push   -0x10(%ebp)
80103f2d:	e8 ca 39 00 00       	call   801078fc <switchuvm>
80103f32:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f35:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f3a:	c9                   	leave
80103f3b:	c3                   	ret

80103f3c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103f3c:	f3 0f 1e fb          	endbr32
80103f40:	55                   	push   %ebp
80103f41:	89 e5                	mov    %esp,%ebp
80103f43:	57                   	push   %edi
80103f44:	56                   	push   %esi
80103f45:	53                   	push   %ebx
80103f46:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103f49:	e8 98 fc ff ff       	call   80103be6 <myproc>
80103f4e:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103f51:	e8 bd fc ff ff       	call   80103c13 <allocproc>
80103f56:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103f59:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103f5d:	75 0a                	jne    80103f69 <fork+0x2d>
    return -1;
80103f5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f64:	e9 6e 01 00 00       	jmp    801040d7 <fork+0x19b>
  } 
  cprintf("[fork] curproc->sz %x\n",curproc->sz);
80103f69:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f6c:	8b 00                	mov    (%eax),%eax
80103f6e:	83 ec 08             	sub    $0x8,%esp
80103f71:	50                   	push   %eax
80103f72:	68 b7 a9 10 80       	push   $0x8010a9b7
80103f77:	e8 90 c4 ff ff       	call   8010040c <cprintf>
80103f7c:	83 c4 10             	add    $0x10,%esp
  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103f7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f82:	8b 10                	mov    (%eax),%edx
80103f84:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f87:	8b 40 04             	mov    0x4(%eax),%eax
80103f8a:	83 ec 08             	sub    $0x8,%esp
80103f8d:	52                   	push   %edx
80103f8e:	50                   	push   %eax
80103f8f:	e8 29 3f 00 00       	call   80107ebd <copyuvm>
80103f94:	83 c4 10             	add    $0x10,%esp
80103f97:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f9a:	89 42 04             	mov    %eax,0x4(%edx)
80103f9d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fa0:	8b 40 04             	mov    0x4(%eax),%eax
80103fa3:	85 c0                	test   %eax,%eax
80103fa5:	75 30                	jne    80103fd7 <fork+0x9b>
    kfree(np->kstack);
80103fa7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103faa:	8b 40 08             	mov    0x8(%eax),%eax
80103fad:	83 ec 0c             	sub    $0xc,%esp
80103fb0:	50                   	push   %eax
80103fb1:	e8 7b e8 ff ff       	call   80102831 <kfree>
80103fb6:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103fb9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fbc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103fc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fc6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103fcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fd2:	e9 00 01 00 00       	jmp    801040d7 <fork+0x19b>
  }
  np->sz = curproc->sz;
80103fd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fda:	8b 10                	mov    (%eax),%edx
80103fdc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fdf:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103fe1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fe4:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103fe7:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103fea:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fed:	8b 48 18             	mov    0x18(%eax),%ecx
80103ff0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ff3:	8b 40 18             	mov    0x18(%eax),%eax
80103ff6:	89 c2                	mov    %eax,%edx
80103ff8:	89 cb                	mov    %ecx,%ebx
80103ffa:	b8 13 00 00 00       	mov    $0x13,%eax
80103fff:	89 d7                	mov    %edx,%edi
80104001:	89 de                	mov    %ebx,%esi
80104003:	89 c1                	mov    %eax,%ecx
80104005:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104007:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010400a:	8b 40 18             	mov    0x18(%eax),%eax
8010400d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80104014:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010401b:	eb 3b                	jmp    80104058 <fork+0x11c>
    if(curproc->ofile[i])
8010401d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104020:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104023:	83 c2 08             	add    $0x8,%edx
80104026:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010402a:	85 c0                	test   %eax,%eax
8010402c:	74 26                	je     80104054 <fork+0x118>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010402e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104031:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104034:	83 c2 08             	add    $0x8,%edx
80104037:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010403b:	83 ec 0c             	sub    $0xc,%esp
8010403e:	50                   	push   %eax
8010403f:	e8 8d d0 ff ff       	call   801010d1 <filedup>
80104044:	83 c4 10             	add    $0x10,%esp
80104047:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010404a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010404d:	83 c1 08             	add    $0x8,%ecx
80104050:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104054:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104058:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010405c:	7e bf                	jle    8010401d <fork+0xe1>
  np->cwd = idup(curproc->cwd);
8010405e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104061:	8b 40 68             	mov    0x68(%eax),%eax
80104064:	83 ec 0c             	sub    $0xc,%esp
80104067:	50                   	push   %eax
80104068:	e8 0e da ff ff       	call   80101a7b <idup>
8010406d:	83 c4 10             	add    $0x10,%esp
80104070:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104073:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104076:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104079:	8d 50 6c             	lea    0x6c(%eax),%edx
8010407c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010407f:	83 c0 6c             	add    $0x6c,%eax
80104082:	83 ec 04             	sub    $0x4,%esp
80104085:	6a 10                	push   $0x10
80104087:	52                   	push   %edx
80104088:	50                   	push   %eax
80104089:	e8 df 0e 00 00       	call   80104f6d <safestrcpy>
8010408e:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104091:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104094:	8b 40 10             	mov    0x10(%eax),%eax
80104097:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
8010409a:	83 ec 0c             	sub    $0xc,%esp
8010409d:	68 00 55 19 80       	push   $0x80195500
801040a2:	e8 1c 0a 00 00       	call   80104ac3 <acquire>
801040a7:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801040aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801040ad:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801040b4:	83 ec 0c             	sub    $0xc,%esp
801040b7:	68 00 55 19 80       	push   $0x80195500
801040bc:	e8 74 0a 00 00       	call   80104b35 <release>
801040c1:	83 c4 10             	add    $0x10,%esp
  cprintf("[FORK] end\n");
801040c4:	83 ec 0c             	sub    $0xc,%esp
801040c7:	68 ce a9 10 80       	push   $0x8010a9ce
801040cc:	e8 3b c3 ff ff       	call   8010040c <cprintf>
801040d1:	83 c4 10             	add    $0x10,%esp
  return pid;
801040d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801040d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801040da:	5b                   	pop    %ebx
801040db:	5e                   	pop    %esi
801040dc:	5f                   	pop    %edi
801040dd:	5d                   	pop    %ebp
801040de:	c3                   	ret

801040df <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801040df:	f3 0f 1e fb          	endbr32
801040e3:	55                   	push   %ebp
801040e4:	89 e5                	mov    %esp,%ebp
801040e6:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801040e9:	e8 f8 fa ff ff       	call   80103be6 <myproc>
801040ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801040f1:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
801040f6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801040f9:	75 0d                	jne    80104108 <exit+0x29>
    panic("init exiting");
801040fb:	83 ec 0c             	sub    $0xc,%esp
801040fe:	68 da a9 10 80       	push   $0x8010a9da
80104103:	e8 bd c4 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104108:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010410f:	eb 3f                	jmp    80104150 <exit+0x71>
    if(curproc->ofile[fd]){
80104111:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104114:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104117:	83 c2 08             	add    $0x8,%edx
8010411a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010411e:	85 c0                	test   %eax,%eax
80104120:	74 2a                	je     8010414c <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104122:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104125:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104128:	83 c2 08             	add    $0x8,%edx
8010412b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010412f:	83 ec 0c             	sub    $0xc,%esp
80104132:	50                   	push   %eax
80104133:	e8 ee cf ff ff       	call   80101126 <fileclose>
80104138:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
8010413b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010413e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104141:	83 c2 08             	add    $0x8,%edx
80104144:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010414b:	00 
  for(fd = 0; fd < NOFILE; fd++){
8010414c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104150:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104154:	7e bb                	jle    80104111 <exit+0x32>
    }
  }

  begin_op();
80104156:	e8 53 f0 ff ff       	call   801031ae <begin_op>
  iput(curproc->cwd);
8010415b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010415e:	8b 40 68             	mov    0x68(%eax),%eax
80104161:	83 ec 0c             	sub    $0xc,%esp
80104164:	50                   	push   %eax
80104165:	e8 b8 da ff ff       	call   80101c22 <iput>
8010416a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010416d:	e8 cc f0 ff ff       	call   8010323e <end_op>
  curproc->cwd = 0;
80104172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104175:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010417c:	83 ec 0c             	sub    $0xc,%esp
8010417f:	68 00 55 19 80       	push   $0x80195500
80104184:	e8 3a 09 00 00       	call   80104ac3 <acquire>
80104189:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010418c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010418f:	8b 40 14             	mov    0x14(%eax),%eax
80104192:	83 ec 0c             	sub    $0xc,%esp
80104195:	50                   	push   %eax
80104196:	e8 5a 04 00 00       	call   801045f5 <wakeup1>
8010419b:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010419e:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801041a5:	eb 37                	jmp    801041de <exit+0xff>
    if(p->parent == curproc){
801041a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041aa:	8b 40 14             	mov    0x14(%eax),%eax
801041ad:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801041b0:	75 28                	jne    801041da <exit+0xfb>
      p->parent = initproc;
801041b2:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
801041b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041bb:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801041be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c1:	8b 40 0c             	mov    0xc(%eax),%eax
801041c4:	83 f8 05             	cmp    $0x5,%eax
801041c7:	75 11                	jne    801041da <exit+0xfb>
        wakeup1(initproc);
801041c9:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
801041ce:	83 ec 0c             	sub    $0xc,%esp
801041d1:	50                   	push   %eax
801041d2:	e8 1e 04 00 00       	call   801045f5 <wakeup1>
801041d7:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041da:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801041de:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801041e5:	72 c0                	jb     801041a7 <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801041e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041ea:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801041f1:	e8 0f 02 00 00       	call   80104405 <sched>
  panic("zombie exit");
801041f6:	83 ec 0c             	sub    $0xc,%esp
801041f9:	68 e7 a9 10 80       	push   $0x8010a9e7
801041fe:	e8 c2 c3 ff ff       	call   801005c5 <panic>

80104203 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104203:	f3 0f 1e fb          	endbr32
80104207:	55                   	push   %ebp
80104208:	89 e5                	mov    %esp,%ebp
8010420a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010420d:	e8 d4 f9 ff ff       	call   80103be6 <myproc>
80104212:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104215:	83 ec 0c             	sub    $0xc,%esp
80104218:	68 00 55 19 80       	push   $0x80195500
8010421d:	e8 a1 08 00 00       	call   80104ac3 <acquire>
80104222:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104225:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010422c:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104233:	e9 a1 00 00 00       	jmp    801042d9 <wait+0xd6>
      if(p->parent != curproc)
80104238:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010423b:	8b 40 14             	mov    0x14(%eax),%eax
8010423e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104241:	0f 85 8d 00 00 00    	jne    801042d4 <wait+0xd1>
        continue;
      havekids = 1;
80104247:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010424e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104251:	8b 40 0c             	mov    0xc(%eax),%eax
80104254:	83 f8 05             	cmp    $0x5,%eax
80104257:	75 7c                	jne    801042d5 <wait+0xd2>
        // Found one.
        pid = p->pid;
80104259:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425c:	8b 40 10             	mov    0x10(%eax),%eax
8010425f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104265:	8b 40 08             	mov    0x8(%eax),%eax
80104268:	83 ec 0c             	sub    $0xc,%esp
8010426b:	50                   	push   %eax
8010426c:	e8 c0 e5 ff ff       	call   80102831 <kfree>
80104271:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104274:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104277:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010427e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104281:	8b 40 04             	mov    0x4(%eax),%eax
80104284:	83 ec 0c             	sub    $0xc,%esp
80104287:	50                   	push   %eax
80104288:	e8 4e 3b 00 00       	call   80107ddb <freevm>
8010428d:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104290:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104293:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010429a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010429d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801042a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a7:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801042ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ae:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801042b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801042bf:	83 ec 0c             	sub    $0xc,%esp
801042c2:	68 00 55 19 80       	push   $0x80195500
801042c7:	e8 69 08 00 00       	call   80104b35 <release>
801042cc:	83 c4 10             	add    $0x10,%esp
        return pid;
801042cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801042d2:	eb 51                	jmp    80104325 <wait+0x122>
        continue;
801042d4:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042d5:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801042d9:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801042e0:	0f 82 52 ff ff ff    	jb     80104238 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801042e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801042ea:	74 0a                	je     801042f6 <wait+0xf3>
801042ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042ef:	8b 40 24             	mov    0x24(%eax),%eax
801042f2:	85 c0                	test   %eax,%eax
801042f4:	74 17                	je     8010430d <wait+0x10a>
      release(&ptable.lock);
801042f6:	83 ec 0c             	sub    $0xc,%esp
801042f9:	68 00 55 19 80       	push   $0x80195500
801042fe:	e8 32 08 00 00       	call   80104b35 <release>
80104303:	83 c4 10             	add    $0x10,%esp
      return -1;
80104306:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010430b:	eb 18                	jmp    80104325 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010430d:	83 ec 08             	sub    $0x8,%esp
80104310:	68 00 55 19 80       	push   $0x80195500
80104315:	ff 75 ec             	push   -0x14(%ebp)
80104318:	e8 2d 02 00 00       	call   8010454a <sleep>
8010431d:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104320:	e9 00 ff ff ff       	jmp    80104225 <wait+0x22>
  }
}
80104325:	c9                   	leave
80104326:	c3                   	ret

80104327 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104327:	f3 0f 1e fb          	endbr32
8010432b:	55                   	push   %ebp
8010432c:	89 e5                	mov    %esp,%ebp
8010432e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104331:	e8 34 f8 ff ff       	call   80103b6a <mycpu>
80104336:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104339:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010433c:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104343:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104346:	e8 d7 f7 ff ff       	call   80103b22 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
8010434b:	83 ec 0c             	sub    $0xc,%esp
8010434e:	68 00 55 19 80       	push   $0x80195500
80104353:	e8 6b 07 00 00       	call   80104ac3 <acquire>
80104358:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010435b:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104362:	eb 61                	jmp    801043c5 <scheduler+0x9e>
      if(p->state != RUNNABLE)
80104364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104367:	8b 40 0c             	mov    0xc(%eax),%eax
8010436a:	83 f8 03             	cmp    $0x3,%eax
8010436d:	75 51                	jne    801043c0 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010436f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104372:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104375:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
8010437b:	83 ec 0c             	sub    $0xc,%esp
8010437e:	ff 75 f4             	push   -0xc(%ebp)
80104381:	e8 76 35 00 00       	call   801078fc <switchuvm>
80104386:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104389:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010438c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&(c->scheduler), p->context);
80104393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104396:	8b 40 1c             	mov    0x1c(%eax),%eax
80104399:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010439c:	83 c2 04             	add    $0x4,%edx
8010439f:	83 ec 08             	sub    $0x8,%esp
801043a2:	50                   	push   %eax
801043a3:	52                   	push   %edx
801043a4:	e8 3d 0c 00 00       	call   80104fe6 <swtch>
801043a9:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801043ac:	e8 2e 35 00 00       	call   801078df <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
801043b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043b4:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801043bb:	00 00 00 
801043be:	eb 01                	jmp    801043c1 <scheduler+0x9a>
        continue;
801043c0:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043c1:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801043c5:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801043cc:	72 96                	jb     80104364 <scheduler+0x3d>
    }
    release(&ptable.lock);
801043ce:	83 ec 0c             	sub    $0xc,%esp
801043d1:	68 00 55 19 80       	push   $0x80195500
801043d6:	e8 5a 07 00 00       	call   80104b35 <release>
801043db:	83 c4 10             	add    $0x10,%esp
    sti();
801043de:	e9 63 ff ff ff       	jmp    80104346 <scheduler+0x1f>

801043e3 <uthread_init>:
// uthread_init: 유저 레벨 쓰레드의 스케줄러의 주소를 커널의 proccess에 넘겨준다.
// 이 함수를 시스템콜에서 호출하여 uthread의 스케줄러의 주소를 가져오고 
// 커널에서 인터럽트가 발생할 때 uthread의 스케줄러를 실행할 수 있게 된다.
int 
uthread_init(int address)
{
801043e3:	f3 0f 1e fb          	endbr32
801043e7:	55                   	push   %ebp
801043e8:	89 e5                	mov    %esp,%ebp
801043ea:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801043ed:	e8 f4 f7 ff ff       	call   80103be6 <myproc>
801043f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
//  p->trapflag = 1;
  curproc->scheduler = (uint)address;
801043f5:	8b 55 08             	mov    0x8(%ebp),%edx
801043f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fb:	89 50 7c             	mov    %edx,0x7c(%eax)
  //cprintf("address: %d", address);
  return 0;
801043fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104403:	c9                   	leave
80104404:	c3                   	ret

80104405 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104405:	f3 0f 1e fb          	endbr32
80104409:	55                   	push   %ebp
8010440a:	89 e5                	mov    %esp,%ebp
8010440c:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
8010440f:	e8 d2 f7 ff ff       	call   80103be6 <myproc>
80104414:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104417:	83 ec 0c             	sub    $0xc,%esp
8010441a:	68 00 55 19 80       	push   $0x80195500
8010441f:	e8 e6 07 00 00       	call   80104c0a <holding>
80104424:	83 c4 10             	add    $0x10,%esp
80104427:	85 c0                	test   %eax,%eax
80104429:	75 0d                	jne    80104438 <sched+0x33>
    panic("sched ptable.lock");
8010442b:	83 ec 0c             	sub    $0xc,%esp
8010442e:	68 f3 a9 10 80       	push   $0x8010a9f3
80104433:	e8 8d c1 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
80104438:	e8 2d f7 ff ff       	call   80103b6a <mycpu>
8010443d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104443:	83 f8 01             	cmp    $0x1,%eax
80104446:	74 0d                	je     80104455 <sched+0x50>
    panic("sched locks");
80104448:	83 ec 0c             	sub    $0xc,%esp
8010444b:	68 05 aa 10 80       	push   $0x8010aa05
80104450:	e8 70 c1 ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
80104455:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104458:	8b 40 0c             	mov    0xc(%eax),%eax
8010445b:	83 f8 04             	cmp    $0x4,%eax
8010445e:	75 0d                	jne    8010446d <sched+0x68>
    panic("sched running");
80104460:	83 ec 0c             	sub    $0xc,%esp
80104463:	68 11 aa 10 80       	push   $0x8010aa11
80104468:	e8 58 c1 ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
8010446d:	e8 a0 f6 ff ff       	call   80103b12 <readeflags>
80104472:	25 00 02 00 00       	and    $0x200,%eax
80104477:	85 c0                	test   %eax,%eax
80104479:	74 0d                	je     80104488 <sched+0x83>
    panic("sched interruptible");
8010447b:	83 ec 0c             	sub    $0xc,%esp
8010447e:	68 1f aa 10 80       	push   $0x8010aa1f
80104483:	e8 3d c1 ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
80104488:	e8 dd f6 ff ff       	call   80103b6a <mycpu>
8010448d:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104493:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104496:	e8 cf f6 ff ff       	call   80103b6a <mycpu>
8010449b:	8b 40 04             	mov    0x4(%eax),%eax
8010449e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044a1:	83 c2 1c             	add    $0x1c,%edx
801044a4:	83 ec 08             	sub    $0x8,%esp
801044a7:	50                   	push   %eax
801044a8:	52                   	push   %edx
801044a9:	e8 38 0b 00 00       	call   80104fe6 <swtch>
801044ae:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801044b1:	e8 b4 f6 ff ff       	call   80103b6a <mycpu>
801044b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044b9:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801044bf:	90                   	nop
801044c0:	c9                   	leave
801044c1:	c3                   	ret

801044c2 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801044c2:	f3 0f 1e fb          	endbr32
801044c6:	55                   	push   %ebp
801044c7:	89 e5                	mov    %esp,%ebp
801044c9:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801044cc:	83 ec 0c             	sub    $0xc,%esp
801044cf:	68 00 55 19 80       	push   $0x80195500
801044d4:	e8 ea 05 00 00       	call   80104ac3 <acquire>
801044d9:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
801044dc:	e8 05 f7 ff ff       	call   80103be6 <myproc>
801044e1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801044e8:	e8 18 ff ff ff       	call   80104405 <sched>
  release(&ptable.lock);
801044ed:	83 ec 0c             	sub    $0xc,%esp
801044f0:	68 00 55 19 80       	push   $0x80195500
801044f5:	e8 3b 06 00 00       	call   80104b35 <release>
801044fa:	83 c4 10             	add    $0x10,%esp
}
801044fd:	90                   	nop
801044fe:	c9                   	leave
801044ff:	c3                   	ret

80104500 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104500:	f3 0f 1e fb          	endbr32
80104504:	55                   	push   %ebp
80104505:	89 e5                	mov    %esp,%ebp
80104507:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010450a:	83 ec 0c             	sub    $0xc,%esp
8010450d:	68 00 55 19 80       	push   $0x80195500
80104512:	e8 1e 06 00 00       	call   80104b35 <release>
80104517:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010451a:	a1 04 f0 10 80       	mov    0x8010f004,%eax
8010451f:	85 c0                	test   %eax,%eax
80104521:	74 24                	je     80104547 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104523:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
8010452a:	00 00 00 
    iinit(ROOTDEV);
8010452d:	83 ec 0c             	sub    $0xc,%esp
80104530:	6a 01                	push   $0x1
80104532:	e8 fc d1 ff ff       	call   80101733 <iinit>
80104537:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010453a:	83 ec 0c             	sub    $0xc,%esp
8010453d:	6a 01                	push   $0x1
8010453f:	e8 37 ea ff ff       	call   80102f7b <initlog>
80104544:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104547:	90                   	nop
80104548:	c9                   	leave
80104549:	c3                   	ret

8010454a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010454a:	f3 0f 1e fb          	endbr32
8010454e:	55                   	push   %ebp
8010454f:	89 e5                	mov    %esp,%ebp
80104551:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104554:	e8 8d f6 ff ff       	call   80103be6 <myproc>
80104559:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
8010455c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104560:	75 0d                	jne    8010456f <sleep+0x25>
    panic("sleep");
80104562:	83 ec 0c             	sub    $0xc,%esp
80104565:	68 33 aa 10 80       	push   $0x8010aa33
8010456a:	e8 56 c0 ff ff       	call   801005c5 <panic>

  if(lk == 0)
8010456f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104573:	75 0d                	jne    80104582 <sleep+0x38>
    panic("sleep without lk");
80104575:	83 ec 0c             	sub    $0xc,%esp
80104578:	68 39 aa 10 80       	push   $0x8010aa39
8010457d:	e8 43 c0 ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104582:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
80104589:	74 1e                	je     801045a9 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010458b:	83 ec 0c             	sub    $0xc,%esp
8010458e:	68 00 55 19 80       	push   $0x80195500
80104593:	e8 2b 05 00 00       	call   80104ac3 <acquire>
80104598:	83 c4 10             	add    $0x10,%esp
    release(lk);
8010459b:	83 ec 0c             	sub    $0xc,%esp
8010459e:	ff 75 0c             	push   0xc(%ebp)
801045a1:	e8 8f 05 00 00       	call   80104b35 <release>
801045a6:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801045a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ac:	8b 55 08             	mov    0x8(%ebp),%edx
801045af:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801045b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b5:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801045bc:	e8 44 fe ff ff       	call   80104405 <sched>

  // Tidy up.
  p->chan = 0;
801045c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c4:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801045cb:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
801045d2:	74 1e                	je     801045f2 <sleep+0xa8>
    release(&ptable.lock);
801045d4:	83 ec 0c             	sub    $0xc,%esp
801045d7:	68 00 55 19 80       	push   $0x80195500
801045dc:	e8 54 05 00 00       	call   80104b35 <release>
801045e1:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801045e4:	83 ec 0c             	sub    $0xc,%esp
801045e7:	ff 75 0c             	push   0xc(%ebp)
801045ea:	e8 d4 04 00 00       	call   80104ac3 <acquire>
801045ef:	83 c4 10             	add    $0x10,%esp
  }
}
801045f2:	90                   	nop
801045f3:	c9                   	leave
801045f4:	c3                   	ret

801045f5 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801045f5:	f3 0f 1e fb          	endbr32
801045f9:	55                   	push   %ebp
801045fa:	89 e5                	mov    %esp,%ebp
801045fc:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045ff:	c7 45 fc 34 55 19 80 	movl   $0x80195534,-0x4(%ebp)
80104606:	eb 24                	jmp    8010462c <wakeup1+0x37>
    if(p->state == SLEEPING && p->chan == chan)
80104608:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010460b:	8b 40 0c             	mov    0xc(%eax),%eax
8010460e:	83 f8 02             	cmp    $0x2,%eax
80104611:	75 15                	jne    80104628 <wakeup1+0x33>
80104613:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104616:	8b 40 20             	mov    0x20(%eax),%eax
80104619:	39 45 08             	cmp    %eax,0x8(%ebp)
8010461c:	75 0a                	jne    80104628 <wakeup1+0x33>
      p->state = RUNNABLE;
8010461e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104621:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104628:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
8010462c:	81 7d fc 34 75 19 80 	cmpl   $0x80197534,-0x4(%ebp)
80104633:	72 d3                	jb     80104608 <wakeup1+0x13>
}
80104635:	90                   	nop
80104636:	90                   	nop
80104637:	c9                   	leave
80104638:	c3                   	ret

80104639 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104639:	f3 0f 1e fb          	endbr32
8010463d:	55                   	push   %ebp
8010463e:	89 e5                	mov    %esp,%ebp
80104640:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104643:	83 ec 0c             	sub    $0xc,%esp
80104646:	68 00 55 19 80       	push   $0x80195500
8010464b:	e8 73 04 00 00       	call   80104ac3 <acquire>
80104650:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104653:	83 ec 0c             	sub    $0xc,%esp
80104656:	ff 75 08             	push   0x8(%ebp)
80104659:	e8 97 ff ff ff       	call   801045f5 <wakeup1>
8010465e:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104661:	83 ec 0c             	sub    $0xc,%esp
80104664:	68 00 55 19 80       	push   $0x80195500
80104669:	e8 c7 04 00 00       	call   80104b35 <release>
8010466e:	83 c4 10             	add    $0x10,%esp
}
80104671:	90                   	nop
80104672:	c9                   	leave
80104673:	c3                   	ret

80104674 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104674:	f3 0f 1e fb          	endbr32
80104678:	55                   	push   %ebp
80104679:	89 e5                	mov    %esp,%ebp
8010467b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010467e:	83 ec 0c             	sub    $0xc,%esp
80104681:	68 00 55 19 80       	push   $0x80195500
80104686:	e8 38 04 00 00       	call   80104ac3 <acquire>
8010468b:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010468e:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104695:	eb 45                	jmp    801046dc <kill+0x68>
    if(p->pid == pid){
80104697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469a:	8b 40 10             	mov    0x10(%eax),%eax
8010469d:	39 45 08             	cmp    %eax,0x8(%ebp)
801046a0:	75 36                	jne    801046d8 <kill+0x64>
      p->killed = 1;
801046a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801046ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046af:	8b 40 0c             	mov    0xc(%eax),%eax
801046b2:	83 f8 02             	cmp    $0x2,%eax
801046b5:	75 0a                	jne    801046c1 <kill+0x4d>
        p->state = RUNNABLE;
801046b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ba:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801046c1:	83 ec 0c             	sub    $0xc,%esp
801046c4:	68 00 55 19 80       	push   $0x80195500
801046c9:	e8 67 04 00 00       	call   80104b35 <release>
801046ce:	83 c4 10             	add    $0x10,%esp
      return 0;
801046d1:	b8 00 00 00 00       	mov    $0x0,%eax
801046d6:	eb 22                	jmp    801046fa <kill+0x86>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046d8:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801046dc:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801046e3:	72 b2                	jb     80104697 <kill+0x23>
    }
  }
  release(&ptable.lock);
801046e5:	83 ec 0c             	sub    $0xc,%esp
801046e8:	68 00 55 19 80       	push   $0x80195500
801046ed:	e8 43 04 00 00       	call   80104b35 <release>
801046f2:	83 c4 10             	add    $0x10,%esp
  return -1;
801046f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801046fa:	c9                   	leave
801046fb:	c3                   	ret

801046fc <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801046fc:	f3 0f 1e fb          	endbr32
80104700:	55                   	push   %ebp
80104701:	89 e5                	mov    %esp,%ebp
80104703:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104706:	c7 45 f0 34 55 19 80 	movl   $0x80195534,-0x10(%ebp)
8010470d:	e9 d7 00 00 00       	jmp    801047e9 <procdump+0xed>
    if(p->state == UNUSED)
80104712:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104715:	8b 40 0c             	mov    0xc(%eax),%eax
80104718:	85 c0                	test   %eax,%eax
8010471a:	0f 84 c4 00 00 00    	je     801047e4 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104720:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104723:	8b 40 0c             	mov    0xc(%eax),%eax
80104726:	83 f8 05             	cmp    $0x5,%eax
80104729:	77 23                	ja     8010474e <procdump+0x52>
8010472b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010472e:	8b 40 0c             	mov    0xc(%eax),%eax
80104731:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104738:	85 c0                	test   %eax,%eax
8010473a:	74 12                	je     8010474e <procdump+0x52>
      state = states[p->state];
8010473c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010473f:	8b 40 0c             	mov    0xc(%eax),%eax
80104742:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104749:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010474c:	eb 07                	jmp    80104755 <procdump+0x59>
    else
      state = "???";
8010474e:	c7 45 ec 4a aa 10 80 	movl   $0x8010aa4a,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104755:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104758:	8d 50 6c             	lea    0x6c(%eax),%edx
8010475b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010475e:	8b 40 10             	mov    0x10(%eax),%eax
80104761:	52                   	push   %edx
80104762:	ff 75 ec             	push   -0x14(%ebp)
80104765:	50                   	push   %eax
80104766:	68 4e aa 10 80       	push   $0x8010aa4e
8010476b:	e8 9c bc ff ff       	call   8010040c <cprintf>
80104770:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104773:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104776:	8b 40 0c             	mov    0xc(%eax),%eax
80104779:	83 f8 02             	cmp    $0x2,%eax
8010477c:	75 54                	jne    801047d2 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010477e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104781:	8b 40 1c             	mov    0x1c(%eax),%eax
80104784:	8b 40 0c             	mov    0xc(%eax),%eax
80104787:	83 c0 08             	add    $0x8,%eax
8010478a:	89 c2                	mov    %eax,%edx
8010478c:	83 ec 08             	sub    $0x8,%esp
8010478f:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104792:	50                   	push   %eax
80104793:	52                   	push   %edx
80104794:	e8 f2 03 00 00       	call   80104b8b <getcallerpcs>
80104799:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010479c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801047a3:	eb 1c                	jmp    801047c1 <procdump+0xc5>
        cprintf(" %p", pc[i]);
801047a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a8:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801047ac:	83 ec 08             	sub    $0x8,%esp
801047af:	50                   	push   %eax
801047b0:	68 57 aa 10 80       	push   $0x8010aa57
801047b5:	e8 52 bc ff ff       	call   8010040c <cprintf>
801047ba:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801047bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801047c1:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801047c5:	7f 0b                	jg     801047d2 <procdump+0xd6>
801047c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ca:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801047ce:	85 c0                	test   %eax,%eax
801047d0:	75 d3                	jne    801047a5 <procdump+0xa9>
    }
    cprintf("\n");
801047d2:	83 ec 0c             	sub    $0xc,%esp
801047d5:	68 5b aa 10 80       	push   $0x8010aa5b
801047da:	e8 2d bc ff ff       	call   8010040c <cprintf>
801047df:	83 c4 10             	add    $0x10,%esp
801047e2:	eb 01                	jmp    801047e5 <procdump+0xe9>
      continue;
801047e4:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047e5:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
801047e9:	81 7d f0 34 75 19 80 	cmpl   $0x80197534,-0x10(%ebp)
801047f0:	0f 82 1c ff ff ff    	jb     80104712 <procdump+0x16>
  }
}
801047f6:	90                   	nop
801047f7:	90                   	nop
801047f8:	c9                   	leave
801047f9:	c3                   	ret

801047fa <printpt>:

// 페이지 테이블 출력
int printpt(int pid){
801047fa:	f3 0f 1e fb          	endbr32
801047fe:	55                   	push   %ebp
801047ff:	89 e5                	mov    %esp,%ebp
80104801:	53                   	push   %ebx
80104802:	83 ec 14             	sub    $0x14,%esp
  struct proc* p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104805:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010480c:	eb 0f                	jmp    8010481d <printpt+0x23>
    if (p->pid == pid)
8010480e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104811:	8b 40 10             	mov    0x10(%eax),%eax
80104814:	39 45 08             	cmp    %eax,0x8(%ebp)
80104817:	74 0f                	je     80104828 <printpt+0x2e>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104819:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010481d:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80104824:	72 e8                	jb     8010480e <printpt+0x14>
80104826:	eb 01                	jmp    80104829 <printpt+0x2f>
      break;
80104828:	90                   	nop
  }
  if (p == 0){
80104829:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010482d:	75 1a                	jne    80104849 <printpt+0x4f>
    cprintf("[printpt] invaild proccess\n");
8010482f:	83 ec 0c             	sub    $0xc,%esp
80104832:	68 5d aa 10 80       	push   $0x8010aa5d
80104837:	e8 d0 bb ff ff       	call   8010040c <cprintf>
8010483c:	83 c4 10             	add    $0x10,%esp
    return -1;
8010483f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104844:	e9 e2 00 00 00       	jmp    8010492b <printpt+0x131>
  }
  
  pde_t* pgdir = p->pgdir;
80104849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010484c:	8b 40 04             	mov    0x4(%eax),%eax
8010484f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint va;
  // walkpgdir은 pgdir에서 va(가상주소)가 위치한 페이지 테이블 엔트리를 반환한다.
  cprintf("START PAGE TABLE (pid %d) \n", pid);
80104852:	83 ec 08             	sub    $0x8,%esp
80104855:	ff 75 08             	push   0x8(%ebp)
80104858:	68 79 aa 10 80       	push   $0x8010aa79
8010485d:	e8 aa bb ff ff       	call   8010040c <cprintf>
80104862:	83 c4 10             	add    $0x10,%esp
  // 페이지 테이블 엔트리를 한 줄씩 출력
  // xv6에서는 pagesize를 4KB로 설정 PGSIZE == 4096 임
  for (va = 0; va < KERNBASE; va += PGSIZE)
80104865:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010486c:	e9 9a 00 00 00       	jmp    8010490b <printpt+0x111>
  {
    // va가 속한 페이지 테이블 엔트리
    pte_t* pte = walkpgdir(pgdir, (void*) va, 0);
80104871:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104874:	83 ec 04             	sub    $0x4,%esp
80104877:	6a 00                	push   $0x0
80104879:	50                   	push   %eax
8010487a:	ff 75 ec             	push   -0x14(%ebp)
8010487d:	e8 22 2e 00 00       	call   801076a4 <walkpgdir>
80104882:	83 c4 10             	add    $0x10,%esp
80104885:	89 45 e8             	mov    %eax,-0x18(%ebp)
    // pte가 유효하지 않으면 패스
    if (!(*pte & PTE_P) || pte == 0) continue;
80104888:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010488b:	8b 00                	mov    (%eax),%eax
8010488d:	83 e0 01             	and    $0x1,%eax
80104890:	85 c0                	test   %eax,%eax
80104892:	74 6f                	je     80104903 <printpt+0x109>
80104894:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80104898:	74 69                	je     80104903 <printpt+0x109>
    cprintf("pte: %x\n",pte);
8010489a:	83 ec 08             	sub    $0x8,%esp
8010489d:	ff 75 e8             	push   -0x18(%ebp)
801048a0:	68 95 aa 10 80       	push   $0x8010aa95
801048a5:	e8 62 bb ff ff       	call   8010040c <cprintf>
801048aa:	83 c4 10             	add    $0x10,%esp
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
      (*pte & PTE_W)?'W':'-', PTE_ADDR(*pte) >> 12); 
801048ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048b0:	8b 00                	mov    (%eax),%eax
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
801048b2:	c1 e8 0c             	shr    $0xc,%eax
801048b5:	89 c2                	mov    %eax,%edx
      (*pte & PTE_W)?'W':'-', PTE_ADDR(*pte) >> 12); 
801048b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048ba:	8b 00                	mov    (%eax),%eax
801048bc:	83 e0 02             	and    $0x2,%eax
    cprintf("%d P %c %c %x\n", (va / PGSIZE), (*pte & PTE_U)?'U':'K' , 
801048bf:	85 c0                	test   %eax,%eax
801048c1:	74 07                	je     801048ca <printpt+0xd0>
801048c3:	bb 57 00 00 00       	mov    $0x57,%ebx
801048c8:	eb 05                	jmp    801048cf <printpt+0xd5>
801048ca:	bb 2d 00 00 00       	mov    $0x2d,%ebx
801048cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048d2:	8b 00                	mov    (%eax),%eax
801048d4:	83 e0 04             	and    $0x4,%eax
801048d7:	85 c0                	test   %eax,%eax
801048d9:	74 07                	je     801048e2 <printpt+0xe8>
801048db:	b9 55 00 00 00       	mov    $0x55,%ecx
801048e0:	eb 05                	jmp    801048e7 <printpt+0xed>
801048e2:	b9 4b 00 00 00       	mov    $0x4b,%ecx
801048e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048ea:	c1 e8 0c             	shr    $0xc,%eax
801048ed:	83 ec 0c             	sub    $0xc,%esp
801048f0:	52                   	push   %edx
801048f1:	53                   	push   %ebx
801048f2:	51                   	push   %ecx
801048f3:	50                   	push   %eax
801048f4:	68 9e aa 10 80       	push   $0x8010aa9e
801048f9:	e8 0e bb ff ff       	call   8010040c <cprintf>
801048fe:	83 c4 20             	add    $0x20,%esp
80104901:	eb 01                	jmp    80104904 <printpt+0x10a>
    if (!(*pte & PTE_P) || pte == 0) continue;
80104903:	90                   	nop
  for (va = 0; va < KERNBASE; va += PGSIZE)
80104904:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
8010490b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010490e:	85 c0                	test   %eax,%eax
80104910:	0f 89 5b ff ff ff    	jns    80104871 <printpt+0x77>
  }
  cprintf("END PAGE TABLE\n");
80104916:	83 ec 0c             	sub    $0xc,%esp
80104919:	68 ad aa 10 80       	push   $0x8010aaad
8010491e:	e8 e9 ba ff ff       	call   8010040c <cprintf>
80104923:	83 c4 10             	add    $0x10,%esp
  return 0;
80104926:	b8 00 00 00 00       	mov    $0x0,%eax
8010492b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010492e:	c9                   	leave
8010492f:	c3                   	ret

80104930 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104930:	f3 0f 1e fb          	endbr32
80104934:	55                   	push   %ebp
80104935:	89 e5                	mov    %esp,%ebp
80104937:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
8010493a:	8b 45 08             	mov    0x8(%ebp),%eax
8010493d:	83 c0 04             	add    $0x4,%eax
80104940:	83 ec 08             	sub    $0x8,%esp
80104943:	68 e7 aa 10 80       	push   $0x8010aae7
80104948:	50                   	push   %eax
80104949:	e8 4f 01 00 00       	call   80104a9d <initlock>
8010494e:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104951:	8b 45 08             	mov    0x8(%ebp),%eax
80104954:	8b 55 0c             	mov    0xc(%ebp),%edx
80104957:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
8010495a:	8b 45 08             	mov    0x8(%ebp),%eax
8010495d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104963:	8b 45 08             	mov    0x8(%ebp),%eax
80104966:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
8010496d:	90                   	nop
8010496e:	c9                   	leave
8010496f:	c3                   	ret

80104970 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104970:	f3 0f 1e fb          	endbr32
80104974:	55                   	push   %ebp
80104975:	89 e5                	mov    %esp,%ebp
80104977:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010497a:	8b 45 08             	mov    0x8(%ebp),%eax
8010497d:	83 c0 04             	add    $0x4,%eax
80104980:	83 ec 0c             	sub    $0xc,%esp
80104983:	50                   	push   %eax
80104984:	e8 3a 01 00 00       	call   80104ac3 <acquire>
80104989:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010498c:	eb 15                	jmp    801049a3 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
8010498e:	8b 45 08             	mov    0x8(%ebp),%eax
80104991:	83 c0 04             	add    $0x4,%eax
80104994:	83 ec 08             	sub    $0x8,%esp
80104997:	50                   	push   %eax
80104998:	ff 75 08             	push   0x8(%ebp)
8010499b:	e8 aa fb ff ff       	call   8010454a <sleep>
801049a0:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801049a3:	8b 45 08             	mov    0x8(%ebp),%eax
801049a6:	8b 00                	mov    (%eax),%eax
801049a8:	85 c0                	test   %eax,%eax
801049aa:	75 e2                	jne    8010498e <acquiresleep+0x1e>
  }
  lk->locked = 1;
801049ac:	8b 45 08             	mov    0x8(%ebp),%eax
801049af:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801049b5:	e8 2c f2 ff ff       	call   80103be6 <myproc>
801049ba:	8b 50 10             	mov    0x10(%eax),%edx
801049bd:	8b 45 08             	mov    0x8(%ebp),%eax
801049c0:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801049c3:	8b 45 08             	mov    0x8(%ebp),%eax
801049c6:	83 c0 04             	add    $0x4,%eax
801049c9:	83 ec 0c             	sub    $0xc,%esp
801049cc:	50                   	push   %eax
801049cd:	e8 63 01 00 00       	call   80104b35 <release>
801049d2:	83 c4 10             	add    $0x10,%esp
}
801049d5:	90                   	nop
801049d6:	c9                   	leave
801049d7:	c3                   	ret

801049d8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801049d8:	f3 0f 1e fb          	endbr32
801049dc:	55                   	push   %ebp
801049dd:	89 e5                	mov    %esp,%ebp
801049df:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801049e2:	8b 45 08             	mov    0x8(%ebp),%eax
801049e5:	83 c0 04             	add    $0x4,%eax
801049e8:	83 ec 0c             	sub    $0xc,%esp
801049eb:	50                   	push   %eax
801049ec:	e8 d2 00 00 00       	call   80104ac3 <acquire>
801049f1:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801049f4:	8b 45 08             	mov    0x8(%ebp),%eax
801049f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801049fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104a00:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104a07:	83 ec 0c             	sub    $0xc,%esp
80104a0a:	ff 75 08             	push   0x8(%ebp)
80104a0d:	e8 27 fc ff ff       	call   80104639 <wakeup>
80104a12:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104a15:	8b 45 08             	mov    0x8(%ebp),%eax
80104a18:	83 c0 04             	add    $0x4,%eax
80104a1b:	83 ec 0c             	sub    $0xc,%esp
80104a1e:	50                   	push   %eax
80104a1f:	e8 11 01 00 00       	call   80104b35 <release>
80104a24:	83 c4 10             	add    $0x10,%esp
}
80104a27:	90                   	nop
80104a28:	c9                   	leave
80104a29:	c3                   	ret

80104a2a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104a2a:	f3 0f 1e fb          	endbr32
80104a2e:	55                   	push   %ebp
80104a2f:	89 e5                	mov    %esp,%ebp
80104a31:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104a34:	8b 45 08             	mov    0x8(%ebp),%eax
80104a37:	83 c0 04             	add    $0x4,%eax
80104a3a:	83 ec 0c             	sub    $0xc,%esp
80104a3d:	50                   	push   %eax
80104a3e:	e8 80 00 00 00       	call   80104ac3 <acquire>
80104a43:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104a46:	8b 45 08             	mov    0x8(%ebp),%eax
80104a49:	8b 00                	mov    (%eax),%eax
80104a4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104a4e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a51:	83 c0 04             	add    $0x4,%eax
80104a54:	83 ec 0c             	sub    $0xc,%esp
80104a57:	50                   	push   %eax
80104a58:	e8 d8 00 00 00       	call   80104b35 <release>
80104a5d:	83 c4 10             	add    $0x10,%esp
  return r;
80104a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104a63:	c9                   	leave
80104a64:	c3                   	ret

80104a65 <readeflags>:
{
80104a65:	55                   	push   %ebp
80104a66:	89 e5                	mov    %esp,%ebp
80104a68:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104a6b:	9c                   	pushf
80104a6c:	58                   	pop    %eax
80104a6d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104a70:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a73:	c9                   	leave
80104a74:	c3                   	ret

80104a75 <cli>:
{
80104a75:	55                   	push   %ebp
80104a76:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104a78:	fa                   	cli
}
80104a79:	90                   	nop
80104a7a:	5d                   	pop    %ebp
80104a7b:	c3                   	ret

80104a7c <sti>:
{
80104a7c:	55                   	push   %ebp
80104a7d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104a7f:	fb                   	sti
}
80104a80:	90                   	nop
80104a81:	5d                   	pop    %ebp
80104a82:	c3                   	ret

80104a83 <xchg>:
{
80104a83:	55                   	push   %ebp
80104a84:	89 e5                	mov    %esp,%ebp
80104a86:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104a89:	8b 55 08             	mov    0x8(%ebp),%edx
80104a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a92:	f0 87 02             	lock xchg %eax,(%edx)
80104a95:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104a98:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104a9b:	c9                   	leave
80104a9c:	c3                   	ret

80104a9d <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104a9d:	f3 0f 1e fb          	endbr32
80104aa1:	55                   	push   %ebp
80104aa2:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa7:	8b 55 0c             	mov    0xc(%ebp),%edx
80104aaa:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104aad:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104ab6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104ac0:	90                   	nop
80104ac1:	5d                   	pop    %ebp
80104ac2:	c3                   	ret

80104ac3 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104ac3:	f3 0f 1e fb          	endbr32
80104ac7:	55                   	push   %ebp
80104ac8:	89 e5                	mov    %esp,%ebp
80104aca:	53                   	push   %ebx
80104acb:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104ace:	e8 6c 01 00 00       	call   80104c3f <pushcli>
  if(holding(lk)){
80104ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ad6:	83 ec 0c             	sub    $0xc,%esp
80104ad9:	50                   	push   %eax
80104ada:	e8 2b 01 00 00       	call   80104c0a <holding>
80104adf:	83 c4 10             	add    $0x10,%esp
80104ae2:	85 c0                	test   %eax,%eax
80104ae4:	74 0d                	je     80104af3 <acquire+0x30>
    panic("acquire");
80104ae6:	83 ec 0c             	sub    $0xc,%esp
80104ae9:	68 f2 aa 10 80       	push   $0x8010aaf2
80104aee:	e8 d2 ba ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104af3:	90                   	nop
80104af4:	8b 45 08             	mov    0x8(%ebp),%eax
80104af7:	83 ec 08             	sub    $0x8,%esp
80104afa:	6a 01                	push   $0x1
80104afc:	50                   	push   %eax
80104afd:	e8 81 ff ff ff       	call   80104a83 <xchg>
80104b02:	83 c4 10             	add    $0x10,%esp
80104b05:	85 c0                	test   %eax,%eax
80104b07:	75 eb                	jne    80104af4 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104b09:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104b0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104b11:	e8 54 f0 ff ff       	call   80103b6a <mycpu>
80104b16:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104b19:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1c:	83 c0 0c             	add    $0xc,%eax
80104b1f:	83 ec 08             	sub    $0x8,%esp
80104b22:	50                   	push   %eax
80104b23:	8d 45 08             	lea    0x8(%ebp),%eax
80104b26:	50                   	push   %eax
80104b27:	e8 5f 00 00 00       	call   80104b8b <getcallerpcs>
80104b2c:	83 c4 10             	add    $0x10,%esp
}
80104b2f:	90                   	nop
80104b30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b33:	c9                   	leave
80104b34:	c3                   	ret

80104b35 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104b35:	f3 0f 1e fb          	endbr32
80104b39:	55                   	push   %ebp
80104b3a:	89 e5                	mov    %esp,%ebp
80104b3c:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104b3f:	83 ec 0c             	sub    $0xc,%esp
80104b42:	ff 75 08             	push   0x8(%ebp)
80104b45:	e8 c0 00 00 00       	call   80104c0a <holding>
80104b4a:	83 c4 10             	add    $0x10,%esp
80104b4d:	85 c0                	test   %eax,%eax
80104b4f:	75 0d                	jne    80104b5e <release+0x29>
    panic("release");
80104b51:	83 ec 0c             	sub    $0xc,%esp
80104b54:	68 fa aa 10 80       	push   $0x8010aafa
80104b59:	e8 67 ba ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
80104b5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b61:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104b68:	8b 45 08             	mov    0x8(%ebp),%eax
80104b6b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104b72:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104b77:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7a:	8b 55 08             	mov    0x8(%ebp),%edx
80104b7d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104b83:	e8 08 01 00 00       	call   80104c90 <popcli>
}
80104b88:	90                   	nop
80104b89:	c9                   	leave
80104b8a:	c3                   	ret

80104b8b <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104b8b:	f3 0f 1e fb          	endbr32
80104b8f:	55                   	push   %ebp
80104b90:	89 e5                	mov    %esp,%ebp
80104b92:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104b95:	8b 45 08             	mov    0x8(%ebp),%eax
80104b98:	83 e8 08             	sub    $0x8,%eax
80104b9b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104b9e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104ba5:	eb 38                	jmp    80104bdf <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104ba7:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104bab:	74 53                	je     80104c00 <getcallerpcs+0x75>
80104bad:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104bb4:	76 4a                	jbe    80104c00 <getcallerpcs+0x75>
80104bb6:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104bba:	74 44                	je     80104c00 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104bbc:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bbf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bc9:	01 c2                	add    %eax,%edx
80104bcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bce:	8b 40 04             	mov    0x4(%eax),%eax
80104bd1:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104bd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bd6:	8b 00                	mov    (%eax),%eax
80104bd8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104bdb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104bdf:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104be3:	7e c2                	jle    80104ba7 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80104be5:	eb 19                	jmp    80104c00 <getcallerpcs+0x75>
    pcs[i] = 0;
80104be7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bf4:	01 d0                	add    %edx,%eax
80104bf6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104bfc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c00:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c04:	7e e1                	jle    80104be7 <getcallerpcs+0x5c>
}
80104c06:	90                   	nop
80104c07:	90                   	nop
80104c08:	c9                   	leave
80104c09:	c3                   	ret

80104c0a <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104c0a:	f3 0f 1e fb          	endbr32
80104c0e:	55                   	push   %ebp
80104c0f:	89 e5                	mov    %esp,%ebp
80104c11:	53                   	push   %ebx
80104c12:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104c15:	8b 45 08             	mov    0x8(%ebp),%eax
80104c18:	8b 00                	mov    (%eax),%eax
80104c1a:	85 c0                	test   %eax,%eax
80104c1c:	74 16                	je     80104c34 <holding+0x2a>
80104c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c21:	8b 58 08             	mov    0x8(%eax),%ebx
80104c24:	e8 41 ef ff ff       	call   80103b6a <mycpu>
80104c29:	39 c3                	cmp    %eax,%ebx
80104c2b:	75 07                	jne    80104c34 <holding+0x2a>
80104c2d:	b8 01 00 00 00       	mov    $0x1,%eax
80104c32:	eb 05                	jmp    80104c39 <holding+0x2f>
80104c34:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c39:	83 c4 04             	add    $0x4,%esp
80104c3c:	5b                   	pop    %ebx
80104c3d:	5d                   	pop    %ebp
80104c3e:	c3                   	ret

80104c3f <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104c3f:	f3 0f 1e fb          	endbr32
80104c43:	55                   	push   %ebp
80104c44:	89 e5                	mov    %esp,%ebp
80104c46:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104c49:	e8 17 fe ff ff       	call   80104a65 <readeflags>
80104c4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104c51:	e8 1f fe ff ff       	call   80104a75 <cli>
  if(mycpu()->ncli == 0)
80104c56:	e8 0f ef ff ff       	call   80103b6a <mycpu>
80104c5b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104c61:	85 c0                	test   %eax,%eax
80104c63:	75 14                	jne    80104c79 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104c65:	e8 00 ef ff ff       	call   80103b6a <mycpu>
80104c6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c6d:	81 e2 00 02 00 00    	and    $0x200,%edx
80104c73:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104c79:	e8 ec ee ff ff       	call   80103b6a <mycpu>
80104c7e:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104c84:	83 c2 01             	add    $0x1,%edx
80104c87:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104c8d:	90                   	nop
80104c8e:	c9                   	leave
80104c8f:	c3                   	ret

80104c90 <popcli>:

void
popcli(void)
{
80104c90:	f3 0f 1e fb          	endbr32
80104c94:	55                   	push   %ebp
80104c95:	89 e5                	mov    %esp,%ebp
80104c97:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104c9a:	e8 c6 fd ff ff       	call   80104a65 <readeflags>
80104c9f:	25 00 02 00 00       	and    $0x200,%eax
80104ca4:	85 c0                	test   %eax,%eax
80104ca6:	74 0d                	je     80104cb5 <popcli+0x25>
    panic("popcli - interruptible");
80104ca8:	83 ec 0c             	sub    $0xc,%esp
80104cab:	68 02 ab 10 80       	push   $0x8010ab02
80104cb0:	e8 10 b9 ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
80104cb5:	e8 b0 ee ff ff       	call   80103b6a <mycpu>
80104cba:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104cc0:	83 ea 01             	sub    $0x1,%edx
80104cc3:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104cc9:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ccf:	85 c0                	test   %eax,%eax
80104cd1:	79 0d                	jns    80104ce0 <popcli+0x50>
    panic("popcli");
80104cd3:	83 ec 0c             	sub    $0xc,%esp
80104cd6:	68 19 ab 10 80       	push   $0x8010ab19
80104cdb:	e8 e5 b8 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104ce0:	e8 85 ee ff ff       	call   80103b6a <mycpu>
80104ce5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ceb:	85 c0                	test   %eax,%eax
80104ced:	75 14                	jne    80104d03 <popcli+0x73>
80104cef:	e8 76 ee ff ff       	call   80103b6a <mycpu>
80104cf4:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104cfa:	85 c0                	test   %eax,%eax
80104cfc:	74 05                	je     80104d03 <popcli+0x73>
    sti();
80104cfe:	e8 79 fd ff ff       	call   80104a7c <sti>
}
80104d03:	90                   	nop
80104d04:	c9                   	leave
80104d05:	c3                   	ret

80104d06 <stosb>:
{
80104d06:	55                   	push   %ebp
80104d07:	89 e5                	mov    %esp,%ebp
80104d09:	57                   	push   %edi
80104d0a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104d0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d0e:	8b 55 10             	mov    0x10(%ebp),%edx
80104d11:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d14:	89 cb                	mov    %ecx,%ebx
80104d16:	89 df                	mov    %ebx,%edi
80104d18:	89 d1                	mov    %edx,%ecx
80104d1a:	fc                   	cld
80104d1b:	f3 aa                	rep stos %al,%es:(%edi)
80104d1d:	89 ca                	mov    %ecx,%edx
80104d1f:	89 fb                	mov    %edi,%ebx
80104d21:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d24:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d27:	90                   	nop
80104d28:	5b                   	pop    %ebx
80104d29:	5f                   	pop    %edi
80104d2a:	5d                   	pop    %ebp
80104d2b:	c3                   	ret

80104d2c <stosl>:
{
80104d2c:	55                   	push   %ebp
80104d2d:	89 e5                	mov    %esp,%ebp
80104d2f:	57                   	push   %edi
80104d30:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104d31:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d34:	8b 55 10             	mov    0x10(%ebp),%edx
80104d37:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d3a:	89 cb                	mov    %ecx,%ebx
80104d3c:	89 df                	mov    %ebx,%edi
80104d3e:	89 d1                	mov    %edx,%ecx
80104d40:	fc                   	cld
80104d41:	f3 ab                	rep stos %eax,%es:(%edi)
80104d43:	89 ca                	mov    %ecx,%edx
80104d45:	89 fb                	mov    %edi,%ebx
80104d47:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d4a:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d4d:	90                   	nop
80104d4e:	5b                   	pop    %ebx
80104d4f:	5f                   	pop    %edi
80104d50:	5d                   	pop    %ebp
80104d51:	c3                   	ret

80104d52 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104d52:	f3 0f 1e fb          	endbr32
80104d56:	55                   	push   %ebp
80104d57:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104d59:	8b 45 08             	mov    0x8(%ebp),%eax
80104d5c:	83 e0 03             	and    $0x3,%eax
80104d5f:	85 c0                	test   %eax,%eax
80104d61:	75 43                	jne    80104da6 <memset+0x54>
80104d63:	8b 45 10             	mov    0x10(%ebp),%eax
80104d66:	83 e0 03             	and    $0x3,%eax
80104d69:	85 c0                	test   %eax,%eax
80104d6b:	75 39                	jne    80104da6 <memset+0x54>
    c &= 0xFF;
80104d6d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104d74:	8b 45 10             	mov    0x10(%ebp),%eax
80104d77:	c1 e8 02             	shr    $0x2,%eax
80104d7a:	89 c1                	mov    %eax,%ecx
80104d7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d7f:	c1 e0 18             	shl    $0x18,%eax
80104d82:	89 c2                	mov    %eax,%edx
80104d84:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d87:	c1 e0 10             	shl    $0x10,%eax
80104d8a:	09 c2                	or     %eax,%edx
80104d8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d8f:	c1 e0 08             	shl    $0x8,%eax
80104d92:	09 d0                	or     %edx,%eax
80104d94:	0b 45 0c             	or     0xc(%ebp),%eax
80104d97:	51                   	push   %ecx
80104d98:	50                   	push   %eax
80104d99:	ff 75 08             	push   0x8(%ebp)
80104d9c:	e8 8b ff ff ff       	call   80104d2c <stosl>
80104da1:	83 c4 0c             	add    $0xc,%esp
80104da4:	eb 12                	jmp    80104db8 <memset+0x66>
  } else
    stosb(dst, c, n);
80104da6:	8b 45 10             	mov    0x10(%ebp),%eax
80104da9:	50                   	push   %eax
80104daa:	ff 75 0c             	push   0xc(%ebp)
80104dad:	ff 75 08             	push   0x8(%ebp)
80104db0:	e8 51 ff ff ff       	call   80104d06 <stosb>
80104db5:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104db8:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104dbb:	c9                   	leave
80104dbc:	c3                   	ret

80104dbd <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104dbd:	f3 0f 1e fb          	endbr32
80104dc1:	55                   	push   %ebp
80104dc2:	89 e5                	mov    %esp,%ebp
80104dc4:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104dc7:	8b 45 08             	mov    0x8(%ebp),%eax
80104dca:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dd0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104dd3:	eb 30                	jmp    80104e05 <memcmp+0x48>
    if(*s1 != *s2)
80104dd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dd8:	0f b6 10             	movzbl (%eax),%edx
80104ddb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104dde:	0f b6 00             	movzbl (%eax),%eax
80104de1:	38 c2                	cmp    %al,%dl
80104de3:	74 18                	je     80104dfd <memcmp+0x40>
      return *s1 - *s2;
80104de5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104de8:	0f b6 00             	movzbl (%eax),%eax
80104deb:	0f b6 d0             	movzbl %al,%edx
80104dee:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104df1:	0f b6 00             	movzbl (%eax),%eax
80104df4:	0f b6 c0             	movzbl %al,%eax
80104df7:	29 c2                	sub    %eax,%edx
80104df9:	89 d0                	mov    %edx,%eax
80104dfb:	eb 1a                	jmp    80104e17 <memcmp+0x5a>
    s1++, s2++;
80104dfd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104e01:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104e05:	8b 45 10             	mov    0x10(%ebp),%eax
80104e08:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e0b:	89 55 10             	mov    %edx,0x10(%ebp)
80104e0e:	85 c0                	test   %eax,%eax
80104e10:	75 c3                	jne    80104dd5 <memcmp+0x18>
  }

  return 0;
80104e12:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e17:	c9                   	leave
80104e18:	c3                   	ret

80104e19 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104e19:	f3 0f 1e fb          	endbr32
80104e1d:	55                   	push   %ebp
80104e1e:	89 e5                	mov    %esp,%ebp
80104e20:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104e23:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e26:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104e29:	8b 45 08             	mov    0x8(%ebp),%eax
80104e2c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104e2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e32:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e35:	73 54                	jae    80104e8b <memmove+0x72>
80104e37:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e3a:	8b 45 10             	mov    0x10(%ebp),%eax
80104e3d:	01 d0                	add    %edx,%eax
80104e3f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104e42:	73 47                	jae    80104e8b <memmove+0x72>
    s += n;
80104e44:	8b 45 10             	mov    0x10(%ebp),%eax
80104e47:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104e4a:	8b 45 10             	mov    0x10(%ebp),%eax
80104e4d:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104e50:	eb 13                	jmp    80104e65 <memmove+0x4c>
      *--d = *--s;
80104e52:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104e56:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104e5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e5d:	0f b6 10             	movzbl (%eax),%edx
80104e60:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e63:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104e65:	8b 45 10             	mov    0x10(%ebp),%eax
80104e68:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e6b:	89 55 10             	mov    %edx,0x10(%ebp)
80104e6e:	85 c0                	test   %eax,%eax
80104e70:	75 e0                	jne    80104e52 <memmove+0x39>
  if(s < d && s + n > d){
80104e72:	eb 24                	jmp    80104e98 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104e74:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e77:	8d 42 01             	lea    0x1(%edx),%eax
80104e7a:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104e7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e80:	8d 48 01             	lea    0x1(%eax),%ecx
80104e83:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104e86:	0f b6 12             	movzbl (%edx),%edx
80104e89:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104e8b:	8b 45 10             	mov    0x10(%ebp),%eax
80104e8e:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e91:	89 55 10             	mov    %edx,0x10(%ebp)
80104e94:	85 c0                	test   %eax,%eax
80104e96:	75 dc                	jne    80104e74 <memmove+0x5b>

  return dst;
80104e98:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e9b:	c9                   	leave
80104e9c:	c3                   	ret

80104e9d <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104e9d:	f3 0f 1e fb          	endbr32
80104ea1:	55                   	push   %ebp
80104ea2:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104ea4:	ff 75 10             	push   0x10(%ebp)
80104ea7:	ff 75 0c             	push   0xc(%ebp)
80104eaa:	ff 75 08             	push   0x8(%ebp)
80104ead:	e8 67 ff ff ff       	call   80104e19 <memmove>
80104eb2:	83 c4 0c             	add    $0xc,%esp
}
80104eb5:	c9                   	leave
80104eb6:	c3                   	ret

80104eb7 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104eb7:	f3 0f 1e fb          	endbr32
80104ebb:	55                   	push   %ebp
80104ebc:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104ebe:	eb 0c                	jmp    80104ecc <strncmp+0x15>
    n--, p++, q++;
80104ec0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ec4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104ec8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104ecc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ed0:	74 1a                	je     80104eec <strncmp+0x35>
80104ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed5:	0f b6 00             	movzbl (%eax),%eax
80104ed8:	84 c0                	test   %al,%al
80104eda:	74 10                	je     80104eec <strncmp+0x35>
80104edc:	8b 45 08             	mov    0x8(%ebp),%eax
80104edf:	0f b6 10             	movzbl (%eax),%edx
80104ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ee5:	0f b6 00             	movzbl (%eax),%eax
80104ee8:	38 c2                	cmp    %al,%dl
80104eea:	74 d4                	je     80104ec0 <strncmp+0x9>
  if(n == 0)
80104eec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ef0:	75 07                	jne    80104ef9 <strncmp+0x42>
    return 0;
80104ef2:	b8 00 00 00 00       	mov    $0x0,%eax
80104ef7:	eb 16                	jmp    80104f0f <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80104ef9:	8b 45 08             	mov    0x8(%ebp),%eax
80104efc:	0f b6 00             	movzbl (%eax),%eax
80104eff:	0f b6 d0             	movzbl %al,%edx
80104f02:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f05:	0f b6 00             	movzbl (%eax),%eax
80104f08:	0f b6 c0             	movzbl %al,%eax
80104f0b:	29 c2                	sub    %eax,%edx
80104f0d:	89 d0                	mov    %edx,%eax
}
80104f0f:	5d                   	pop    %ebp
80104f10:	c3                   	ret

80104f11 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104f11:	f3 0f 1e fb          	endbr32
80104f15:	55                   	push   %ebp
80104f16:	89 e5                	mov    %esp,%ebp
80104f18:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f1e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104f21:	90                   	nop
80104f22:	8b 45 10             	mov    0x10(%ebp),%eax
80104f25:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f28:	89 55 10             	mov    %edx,0x10(%ebp)
80104f2b:	85 c0                	test   %eax,%eax
80104f2d:	7e 2c                	jle    80104f5b <strncpy+0x4a>
80104f2f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f32:	8d 42 01             	lea    0x1(%edx),%eax
80104f35:	89 45 0c             	mov    %eax,0xc(%ebp)
80104f38:	8b 45 08             	mov    0x8(%ebp),%eax
80104f3b:	8d 48 01             	lea    0x1(%eax),%ecx
80104f3e:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104f41:	0f b6 12             	movzbl (%edx),%edx
80104f44:	88 10                	mov    %dl,(%eax)
80104f46:	0f b6 00             	movzbl (%eax),%eax
80104f49:	84 c0                	test   %al,%al
80104f4b:	75 d5                	jne    80104f22 <strncpy+0x11>
    ;
  while(n-- > 0)
80104f4d:	eb 0c                	jmp    80104f5b <strncpy+0x4a>
    *s++ = 0;
80104f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f52:	8d 50 01             	lea    0x1(%eax),%edx
80104f55:	89 55 08             	mov    %edx,0x8(%ebp)
80104f58:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104f5b:	8b 45 10             	mov    0x10(%ebp),%eax
80104f5e:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f61:	89 55 10             	mov    %edx,0x10(%ebp)
80104f64:	85 c0                	test   %eax,%eax
80104f66:	7f e7                	jg     80104f4f <strncpy+0x3e>
  return os;
80104f68:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f6b:	c9                   	leave
80104f6c:	c3                   	ret

80104f6d <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104f6d:	f3 0f 1e fb          	endbr32
80104f71:	55                   	push   %ebp
80104f72:	89 e5                	mov    %esp,%ebp
80104f74:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f77:	8b 45 08             	mov    0x8(%ebp),%eax
80104f7a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104f7d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f81:	7f 05                	jg     80104f88 <safestrcpy+0x1b>
    return os;
80104f83:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f86:	eb 31                	jmp    80104fb9 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80104f88:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f90:	7e 1e                	jle    80104fb0 <safestrcpy+0x43>
80104f92:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f95:	8d 42 01             	lea    0x1(%edx),%eax
80104f98:	89 45 0c             	mov    %eax,0xc(%ebp)
80104f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f9e:	8d 48 01             	lea    0x1(%eax),%ecx
80104fa1:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104fa4:	0f b6 12             	movzbl (%edx),%edx
80104fa7:	88 10                	mov    %dl,(%eax)
80104fa9:	0f b6 00             	movzbl (%eax),%eax
80104fac:	84 c0                	test   %al,%al
80104fae:	75 d8                	jne    80104f88 <safestrcpy+0x1b>
    ;
  *s = 0;
80104fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb3:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104fb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fb9:	c9                   	leave
80104fba:	c3                   	ret

80104fbb <strlen>:

int
strlen(const char *s)
{
80104fbb:	f3 0f 1e fb          	endbr32
80104fbf:	55                   	push   %ebp
80104fc0:	89 e5                	mov    %esp,%ebp
80104fc2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104fc5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104fcc:	eb 04                	jmp    80104fd2 <strlen+0x17>
80104fce:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104fd2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104fd5:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd8:	01 d0                	add    %edx,%eax
80104fda:	0f b6 00             	movzbl (%eax),%eax
80104fdd:	84 c0                	test   %al,%al
80104fdf:	75 ed                	jne    80104fce <strlen+0x13>
    ;
  return n;
80104fe1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fe4:	c9                   	leave
80104fe5:	c3                   	ret

80104fe6 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104fe6:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104fea:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104fee:	55                   	push   %ebp
  pushl %ebx
80104fef:	53                   	push   %ebx
  pushl %esi
80104ff0:	56                   	push   %esi
  pushl %edi
80104ff1:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104ff2:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104ff4:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104ff6:	5f                   	pop    %edi
  popl %esi
80104ff7:	5e                   	pop    %esi
  popl %ebx
80104ff8:	5b                   	pop    %ebx
  popl %ebp
80104ff9:	5d                   	pop    %ebp
  ret
80104ffa:	c3                   	ret

80104ffb <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104ffb:	f3 0f 1e fb          	endbr32
80104fff:	55                   	push   %ebp
80105000:	89 e5                	mov    %esp,%ebp

  if(addr >= KERNBASE || addr+4 >= KERNBASE)
80105002:	8b 45 08             	mov    0x8(%ebp),%eax
80105005:	85 c0                	test   %eax,%eax
80105007:	78 0a                	js     80105013 <fetchint+0x18>
80105009:	8b 45 08             	mov    0x8(%ebp),%eax
8010500c:	83 c0 04             	add    $0x4,%eax
8010500f:	85 c0                	test   %eax,%eax
80105011:	79 07                	jns    8010501a <fetchint+0x1f>
    return -1;
80105013:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105018:	eb 0f                	jmp    80105029 <fetchint+0x2e>
  *ip = *(int*)(addr);
8010501a:	8b 45 08             	mov    0x8(%ebp),%eax
8010501d:	8b 10                	mov    (%eax),%edx
8010501f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105022:	89 10                	mov    %edx,(%eax)
  return 0;
80105024:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105029:	5d                   	pop    %ebp
8010502a:	c3                   	ret

8010502b <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010502b:	f3 0f 1e fb          	endbr32
8010502f:	55                   	push   %ebp
80105030:	89 e5                	mov    %esp,%ebp
80105032:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= KERNBASE)
80105035:	8b 45 08             	mov    0x8(%ebp),%eax
80105038:	85 c0                	test   %eax,%eax
8010503a:	79 07                	jns    80105043 <fetchstr+0x18>
    return -1;
8010503c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105041:	eb 42                	jmp    80105085 <fetchstr+0x5a>
  *pp = (char*)addr;
80105043:	8b 55 08             	mov    0x8(%ebp),%edx
80105046:	8b 45 0c             	mov    0xc(%ebp),%eax
80105049:	89 10                	mov    %edx,(%eax)
  ep = (char*)(KERNBASE-1);
8010504b:	c7 45 f8 ff ff ff 7f 	movl   $0x7fffffff,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
80105052:	8b 45 0c             	mov    0xc(%ebp),%eax
80105055:	8b 00                	mov    (%eax),%eax
80105057:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010505a:	eb 1c                	jmp    80105078 <fetchstr+0x4d>
    if(*s == 0)
8010505c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010505f:	0f b6 00             	movzbl (%eax),%eax
80105062:	84 c0                	test   %al,%al
80105064:	75 0e                	jne    80105074 <fetchstr+0x49>
      return s - *pp;
80105066:	8b 45 0c             	mov    0xc(%ebp),%eax
80105069:	8b 00                	mov    (%eax),%eax
8010506b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010506e:	29 c2                	sub    %eax,%edx
80105070:	89 d0                	mov    %edx,%eax
80105072:	eb 11                	jmp    80105085 <fetchstr+0x5a>
  for(s = *pp; s < ep; s++){
80105074:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105078:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010507b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010507e:	72 dc                	jb     8010505c <fetchstr+0x31>
  }
  return -1;
80105080:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105085:	c9                   	leave
80105086:	c3                   	ret

80105087 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105087:	f3 0f 1e fb          	endbr32
8010508b:	55                   	push   %ebp
8010508c:	89 e5                	mov    %esp,%ebp
8010508e:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105091:	e8 50 eb ff ff       	call   80103be6 <myproc>
80105096:	8b 40 18             	mov    0x18(%eax),%eax
80105099:	8b 40 44             	mov    0x44(%eax),%eax
8010509c:	8b 55 08             	mov    0x8(%ebp),%edx
8010509f:	c1 e2 02             	shl    $0x2,%edx
801050a2:	01 d0                	add    %edx,%eax
801050a4:	83 c0 04             	add    $0x4,%eax
801050a7:	83 ec 08             	sub    $0x8,%esp
801050aa:	ff 75 0c             	push   0xc(%ebp)
801050ad:	50                   	push   %eax
801050ae:	e8 48 ff ff ff       	call   80104ffb <fetchint>
801050b3:	83 c4 10             	add    $0x10,%esp
}
801050b6:	c9                   	leave
801050b7:	c3                   	ret

801050b8 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801050b8:	f3 0f 1e fb          	endbr32
801050bc:	55                   	push   %ebp
801050bd:	89 e5                	mov    %esp,%ebp
801050bf:	83 ec 18             	sub    $0x18,%esp
  int i;
 
  if(argint(n, &i) < 0)
801050c2:	83 ec 08             	sub    $0x8,%esp
801050c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050c8:	50                   	push   %eax
801050c9:	ff 75 08             	push   0x8(%ebp)
801050cc:	e8 b6 ff ff ff       	call   80105087 <argint>
801050d1:	83 c4 10             	add    $0x10,%esp
801050d4:	85 c0                	test   %eax,%eax
801050d6:	79 07                	jns    801050df <argptr+0x27>
    return -1;
801050d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050dd:	eb 34                	jmp    80105113 <argptr+0x5b>
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
801050df:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801050e3:	78 18                	js     801050fd <argptr+0x45>
801050e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e8:	85 c0                	test   %eax,%eax
801050ea:	78 11                	js     801050fd <argptr+0x45>
801050ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ef:	89 c2                	mov    %eax,%edx
801050f1:	8b 45 10             	mov    0x10(%ebp),%eax
801050f4:	01 d0                	add    %edx,%eax
801050f6:	3d 00 00 00 80       	cmp    $0x80000000,%eax
801050fb:	76 07                	jbe    80105104 <argptr+0x4c>
    return -1;
801050fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105102:	eb 0f                	jmp    80105113 <argptr+0x5b>
  *pp = (char*)i;
80105104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105107:	89 c2                	mov    %eax,%edx
80105109:	8b 45 0c             	mov    0xc(%ebp),%eax
8010510c:	89 10                	mov    %edx,(%eax)
  return 0;
8010510e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105113:	c9                   	leave
80105114:	c3                   	ret

80105115 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105115:	f3 0f 1e fb          	endbr32
80105119:	55                   	push   %ebp
8010511a:	89 e5                	mov    %esp,%ebp
8010511c:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010511f:	83 ec 08             	sub    $0x8,%esp
80105122:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105125:	50                   	push   %eax
80105126:	ff 75 08             	push   0x8(%ebp)
80105129:	e8 59 ff ff ff       	call   80105087 <argint>
8010512e:	83 c4 10             	add    $0x10,%esp
80105131:	85 c0                	test   %eax,%eax
80105133:	79 07                	jns    8010513c <argstr+0x27>
    return -1;
80105135:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010513a:	eb 12                	jmp    8010514e <argstr+0x39>
  return fetchstr(addr, pp);
8010513c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513f:	83 ec 08             	sub    $0x8,%esp
80105142:	ff 75 0c             	push   0xc(%ebp)
80105145:	50                   	push   %eax
80105146:	e8 e0 fe ff ff       	call   8010502b <fetchstr>
8010514b:	83 c4 10             	add    $0x10,%esp
}
8010514e:	c9                   	leave
8010514f:	c3                   	ret

80105150 <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80105150:	f3 0f 1e fb          	endbr32
80105154:	55                   	push   %ebp
80105155:	89 e5                	mov    %esp,%ebp
80105157:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
8010515a:	e8 87 ea ff ff       	call   80103be6 <myproc>
8010515f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105165:	8b 40 18             	mov    0x18(%eax),%eax
80105168:	8b 40 1c             	mov    0x1c(%eax),%eax
8010516b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010516e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105172:	7e 2f                	jle    801051a3 <syscall+0x53>
80105174:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105177:	83 f8 17             	cmp    $0x17,%eax
8010517a:	77 27                	ja     801051a3 <syscall+0x53>
8010517c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010517f:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105186:	85 c0                	test   %eax,%eax
80105188:	74 19                	je     801051a3 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
8010518a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010518d:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105194:	ff d0                	call   *%eax
80105196:	89 c2                	mov    %eax,%edx
80105198:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010519b:	8b 40 18             	mov    0x18(%eax),%eax
8010519e:	89 50 1c             	mov    %edx,0x1c(%eax)
801051a1:	eb 2c                	jmp    801051cf <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801051a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a6:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801051a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ac:	8b 40 10             	mov    0x10(%eax),%eax
801051af:	ff 75 f0             	push   -0x10(%ebp)
801051b2:	52                   	push   %edx
801051b3:	50                   	push   %eax
801051b4:	68 20 ab 10 80       	push   $0x8010ab20
801051b9:	e8 4e b2 ff ff       	call   8010040c <cprintf>
801051be:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801051c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051c4:	8b 40 18             	mov    0x18(%eax),%eax
801051c7:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801051ce:	90                   	nop
801051cf:	90                   	nop
801051d0:	c9                   	leave
801051d1:	c3                   	ret

801051d2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801051d2:	f3 0f 1e fb          	endbr32
801051d6:	55                   	push   %ebp
801051d7:	89 e5                	mov    %esp,%ebp
801051d9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801051dc:	83 ec 08             	sub    $0x8,%esp
801051df:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051e2:	50                   	push   %eax
801051e3:	ff 75 08             	push   0x8(%ebp)
801051e6:	e8 9c fe ff ff       	call   80105087 <argint>
801051eb:	83 c4 10             	add    $0x10,%esp
801051ee:	85 c0                	test   %eax,%eax
801051f0:	79 07                	jns    801051f9 <argfd+0x27>
    return -1;
801051f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051f7:	eb 4f                	jmp    80105248 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801051f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051fc:	85 c0                	test   %eax,%eax
801051fe:	78 20                	js     80105220 <argfd+0x4e>
80105200:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105203:	83 f8 0f             	cmp    $0xf,%eax
80105206:	7f 18                	jg     80105220 <argfd+0x4e>
80105208:	e8 d9 e9 ff ff       	call   80103be6 <myproc>
8010520d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105210:	83 c2 08             	add    $0x8,%edx
80105213:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105217:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010521a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010521e:	75 07                	jne    80105227 <argfd+0x55>
    return -1;
80105220:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105225:	eb 21                	jmp    80105248 <argfd+0x76>
  if(pfd)
80105227:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010522b:	74 08                	je     80105235 <argfd+0x63>
    *pfd = fd;
8010522d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105230:	8b 45 0c             	mov    0xc(%ebp),%eax
80105233:	89 10                	mov    %edx,(%eax)
  if(pf)
80105235:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105239:	74 08                	je     80105243 <argfd+0x71>
    *pf = f;
8010523b:	8b 45 10             	mov    0x10(%ebp),%eax
8010523e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105241:	89 10                	mov    %edx,(%eax)
  return 0;
80105243:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105248:	c9                   	leave
80105249:	c3                   	ret

8010524a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010524a:	f3 0f 1e fb          	endbr32
8010524e:	55                   	push   %ebp
8010524f:	89 e5                	mov    %esp,%ebp
80105251:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105254:	e8 8d e9 ff ff       	call   80103be6 <myproc>
80105259:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010525c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105263:	eb 2a                	jmp    8010528f <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105265:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105268:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010526b:	83 c2 08             	add    $0x8,%edx
8010526e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105272:	85 c0                	test   %eax,%eax
80105274:	75 15                	jne    8010528b <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105276:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105279:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010527c:	8d 4a 08             	lea    0x8(%edx),%ecx
8010527f:	8b 55 08             	mov    0x8(%ebp),%edx
80105282:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105289:	eb 0f                	jmp    8010529a <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
8010528b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010528f:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105293:	7e d0                	jle    80105265 <fdalloc+0x1b>
    }
  }
  return -1;
80105295:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010529a:	c9                   	leave
8010529b:	c3                   	ret

8010529c <sys_dup>:

int
sys_dup(void)
{
8010529c:	f3 0f 1e fb          	endbr32
801052a0:	55                   	push   %ebp
801052a1:	89 e5                	mov    %esp,%ebp
801052a3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801052a6:	83 ec 04             	sub    $0x4,%esp
801052a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052ac:	50                   	push   %eax
801052ad:	6a 00                	push   $0x0
801052af:	6a 00                	push   $0x0
801052b1:	e8 1c ff ff ff       	call   801051d2 <argfd>
801052b6:	83 c4 10             	add    $0x10,%esp
801052b9:	85 c0                	test   %eax,%eax
801052bb:	79 07                	jns    801052c4 <sys_dup+0x28>
    return -1;
801052bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052c2:	eb 31                	jmp    801052f5 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
801052c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052c7:	83 ec 0c             	sub    $0xc,%esp
801052ca:	50                   	push   %eax
801052cb:	e8 7a ff ff ff       	call   8010524a <fdalloc>
801052d0:	83 c4 10             	add    $0x10,%esp
801052d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052da:	79 07                	jns    801052e3 <sys_dup+0x47>
    return -1;
801052dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052e1:	eb 12                	jmp    801052f5 <sys_dup+0x59>
  filedup(f);
801052e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052e6:	83 ec 0c             	sub    $0xc,%esp
801052e9:	50                   	push   %eax
801052ea:	e8 e2 bd ff ff       	call   801010d1 <filedup>
801052ef:	83 c4 10             	add    $0x10,%esp
  return fd;
801052f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801052f5:	c9                   	leave
801052f6:	c3                   	ret

801052f7 <sys_read>:

int
sys_read(void)
{
801052f7:	f3 0f 1e fb          	endbr32
801052fb:	55                   	push   %ebp
801052fc:	89 e5                	mov    %esp,%ebp
801052fe:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105301:	83 ec 04             	sub    $0x4,%esp
80105304:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105307:	50                   	push   %eax
80105308:	6a 00                	push   $0x0
8010530a:	6a 00                	push   $0x0
8010530c:	e8 c1 fe ff ff       	call   801051d2 <argfd>
80105311:	83 c4 10             	add    $0x10,%esp
80105314:	85 c0                	test   %eax,%eax
80105316:	78 2e                	js     80105346 <sys_read+0x4f>
80105318:	83 ec 08             	sub    $0x8,%esp
8010531b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010531e:	50                   	push   %eax
8010531f:	6a 02                	push   $0x2
80105321:	e8 61 fd ff ff       	call   80105087 <argint>
80105326:	83 c4 10             	add    $0x10,%esp
80105329:	85 c0                	test   %eax,%eax
8010532b:	78 19                	js     80105346 <sys_read+0x4f>
8010532d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105330:	83 ec 04             	sub    $0x4,%esp
80105333:	50                   	push   %eax
80105334:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105337:	50                   	push   %eax
80105338:	6a 01                	push   $0x1
8010533a:	e8 79 fd ff ff       	call   801050b8 <argptr>
8010533f:	83 c4 10             	add    $0x10,%esp
80105342:	85 c0                	test   %eax,%eax
80105344:	79 07                	jns    8010534d <sys_read+0x56>
    return -1;
80105346:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010534b:	eb 17                	jmp    80105364 <sys_read+0x6d>
  return fileread(f, p, n);
8010534d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105350:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105356:	83 ec 04             	sub    $0x4,%esp
80105359:	51                   	push   %ecx
8010535a:	52                   	push   %edx
8010535b:	50                   	push   %eax
8010535c:	e8 0c bf ff ff       	call   8010126d <fileread>
80105361:	83 c4 10             	add    $0x10,%esp
}
80105364:	c9                   	leave
80105365:	c3                   	ret

80105366 <sys_write>:

int
sys_write(void)
{
80105366:	f3 0f 1e fb          	endbr32
8010536a:	55                   	push   %ebp
8010536b:	89 e5                	mov    %esp,%ebp
8010536d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105370:	83 ec 04             	sub    $0x4,%esp
80105373:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105376:	50                   	push   %eax
80105377:	6a 00                	push   $0x0
80105379:	6a 00                	push   $0x0
8010537b:	e8 52 fe ff ff       	call   801051d2 <argfd>
80105380:	83 c4 10             	add    $0x10,%esp
80105383:	85 c0                	test   %eax,%eax
80105385:	78 2e                	js     801053b5 <sys_write+0x4f>
80105387:	83 ec 08             	sub    $0x8,%esp
8010538a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010538d:	50                   	push   %eax
8010538e:	6a 02                	push   $0x2
80105390:	e8 f2 fc ff ff       	call   80105087 <argint>
80105395:	83 c4 10             	add    $0x10,%esp
80105398:	85 c0                	test   %eax,%eax
8010539a:	78 19                	js     801053b5 <sys_write+0x4f>
8010539c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010539f:	83 ec 04             	sub    $0x4,%esp
801053a2:	50                   	push   %eax
801053a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801053a6:	50                   	push   %eax
801053a7:	6a 01                	push   $0x1
801053a9:	e8 0a fd ff ff       	call   801050b8 <argptr>
801053ae:	83 c4 10             	add    $0x10,%esp
801053b1:	85 c0                	test   %eax,%eax
801053b3:	79 07                	jns    801053bc <sys_write+0x56>
    return -1;
801053b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053ba:	eb 17                	jmp    801053d3 <sys_write+0x6d>
  return filewrite(f, p, n);
801053bc:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053bf:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c5:	83 ec 04             	sub    $0x4,%esp
801053c8:	51                   	push   %ecx
801053c9:	52                   	push   %edx
801053ca:	50                   	push   %eax
801053cb:	e8 59 bf ff ff       	call   80101329 <filewrite>
801053d0:	83 c4 10             	add    $0x10,%esp
}
801053d3:	c9                   	leave
801053d4:	c3                   	ret

801053d5 <sys_close>:

int
sys_close(void)
{
801053d5:	f3 0f 1e fb          	endbr32
801053d9:	55                   	push   %ebp
801053da:	89 e5                	mov    %esp,%ebp
801053dc:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801053df:	83 ec 04             	sub    $0x4,%esp
801053e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053e5:	50                   	push   %eax
801053e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053e9:	50                   	push   %eax
801053ea:	6a 00                	push   $0x0
801053ec:	e8 e1 fd ff ff       	call   801051d2 <argfd>
801053f1:	83 c4 10             	add    $0x10,%esp
801053f4:	85 c0                	test   %eax,%eax
801053f6:	79 07                	jns    801053ff <sys_close+0x2a>
    return -1;
801053f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053fd:	eb 27                	jmp    80105426 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
801053ff:	e8 e2 e7 ff ff       	call   80103be6 <myproc>
80105404:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105407:	83 c2 08             	add    $0x8,%edx
8010540a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105411:	00 
  fileclose(f);
80105412:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105415:	83 ec 0c             	sub    $0xc,%esp
80105418:	50                   	push   %eax
80105419:	e8 08 bd ff ff       	call   80101126 <fileclose>
8010541e:	83 c4 10             	add    $0x10,%esp
  return 0;
80105421:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105426:	c9                   	leave
80105427:	c3                   	ret

80105428 <sys_fstat>:

int
sys_fstat(void)
{
80105428:	f3 0f 1e fb          	endbr32
8010542c:	55                   	push   %ebp
8010542d:	89 e5                	mov    %esp,%ebp
8010542f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105432:	83 ec 04             	sub    $0x4,%esp
80105435:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105438:	50                   	push   %eax
80105439:	6a 00                	push   $0x0
8010543b:	6a 00                	push   $0x0
8010543d:	e8 90 fd ff ff       	call   801051d2 <argfd>
80105442:	83 c4 10             	add    $0x10,%esp
80105445:	85 c0                	test   %eax,%eax
80105447:	78 17                	js     80105460 <sys_fstat+0x38>
80105449:	83 ec 04             	sub    $0x4,%esp
8010544c:	6a 14                	push   $0x14
8010544e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105451:	50                   	push   %eax
80105452:	6a 01                	push   $0x1
80105454:	e8 5f fc ff ff       	call   801050b8 <argptr>
80105459:	83 c4 10             	add    $0x10,%esp
8010545c:	85 c0                	test   %eax,%eax
8010545e:	79 07                	jns    80105467 <sys_fstat+0x3f>
    return -1;
80105460:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105465:	eb 13                	jmp    8010547a <sys_fstat+0x52>
  return filestat(f, st);
80105467:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010546a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010546d:	83 ec 08             	sub    $0x8,%esp
80105470:	52                   	push   %edx
80105471:	50                   	push   %eax
80105472:	e8 9b bd ff ff       	call   80101212 <filestat>
80105477:	83 c4 10             	add    $0x10,%esp
}
8010547a:	c9                   	leave
8010547b:	c3                   	ret

8010547c <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010547c:	f3 0f 1e fb          	endbr32
80105480:	55                   	push   %ebp
80105481:	89 e5                	mov    %esp,%ebp
80105483:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105486:	83 ec 08             	sub    $0x8,%esp
80105489:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010548c:	50                   	push   %eax
8010548d:	6a 00                	push   $0x0
8010548f:	e8 81 fc ff ff       	call   80105115 <argstr>
80105494:	83 c4 10             	add    $0x10,%esp
80105497:	85 c0                	test   %eax,%eax
80105499:	78 15                	js     801054b0 <sys_link+0x34>
8010549b:	83 ec 08             	sub    $0x8,%esp
8010549e:	8d 45 dc             	lea    -0x24(%ebp),%eax
801054a1:	50                   	push   %eax
801054a2:	6a 01                	push   $0x1
801054a4:	e8 6c fc ff ff       	call   80105115 <argstr>
801054a9:	83 c4 10             	add    $0x10,%esp
801054ac:	85 c0                	test   %eax,%eax
801054ae:	79 0a                	jns    801054ba <sys_link+0x3e>
    return -1;
801054b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054b5:	e9 68 01 00 00       	jmp    80105622 <sys_link+0x1a6>

  begin_op();
801054ba:	e8 ef dc ff ff       	call   801031ae <begin_op>
  if((ip = namei(old)) == 0){
801054bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
801054c2:	83 ec 0c             	sub    $0xc,%esp
801054c5:	50                   	push   %eax
801054c6:	e8 59 d1 ff ff       	call   80102624 <namei>
801054cb:	83 c4 10             	add    $0x10,%esp
801054ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054d5:	75 0f                	jne    801054e6 <sys_link+0x6a>
    end_op();
801054d7:	e8 62 dd ff ff       	call   8010323e <end_op>
    return -1;
801054dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054e1:	e9 3c 01 00 00       	jmp    80105622 <sys_link+0x1a6>
  }

  ilock(ip);
801054e6:	83 ec 0c             	sub    $0xc,%esp
801054e9:	ff 75 f4             	push   -0xc(%ebp)
801054ec:	e8 c8 c5 ff ff       	call   80101ab9 <ilock>
801054f1:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801054f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801054fb:	66 83 f8 01          	cmp    $0x1,%ax
801054ff:	75 1d                	jne    8010551e <sys_link+0xa2>
    iunlockput(ip);
80105501:	83 ec 0c             	sub    $0xc,%esp
80105504:	ff 75 f4             	push   -0xc(%ebp)
80105507:	e8 ea c7 ff ff       	call   80101cf6 <iunlockput>
8010550c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010550f:	e8 2a dd ff ff       	call   8010323e <end_op>
    return -1;
80105514:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105519:	e9 04 01 00 00       	jmp    80105622 <sys_link+0x1a6>
  }

  ip->nlink++;
8010551e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105521:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105525:	83 c0 01             	add    $0x1,%eax
80105528:	89 c2                	mov    %eax,%edx
8010552a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010552d:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105531:	83 ec 0c             	sub    $0xc,%esp
80105534:	ff 75 f4             	push   -0xc(%ebp)
80105537:	e8 94 c3 ff ff       	call   801018d0 <iupdate>
8010553c:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010553f:	83 ec 0c             	sub    $0xc,%esp
80105542:	ff 75 f4             	push   -0xc(%ebp)
80105545:	e8 86 c6 ff ff       	call   80101bd0 <iunlock>
8010554a:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010554d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105550:	83 ec 08             	sub    $0x8,%esp
80105553:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105556:	52                   	push   %edx
80105557:	50                   	push   %eax
80105558:	e8 e7 d0 ff ff       	call   80102644 <nameiparent>
8010555d:	83 c4 10             	add    $0x10,%esp
80105560:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105563:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105567:	74 71                	je     801055da <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105569:	83 ec 0c             	sub    $0xc,%esp
8010556c:	ff 75 f0             	push   -0x10(%ebp)
8010556f:	e8 45 c5 ff ff       	call   80101ab9 <ilock>
80105574:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105577:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010557a:	8b 10                	mov    (%eax),%edx
8010557c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010557f:	8b 00                	mov    (%eax),%eax
80105581:	39 c2                	cmp    %eax,%edx
80105583:	75 1d                	jne    801055a2 <sys_link+0x126>
80105585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105588:	8b 40 04             	mov    0x4(%eax),%eax
8010558b:	83 ec 04             	sub    $0x4,%esp
8010558e:	50                   	push   %eax
8010558f:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105592:	50                   	push   %eax
80105593:	ff 75 f0             	push   -0x10(%ebp)
80105596:	e8 e6 cd ff ff       	call   80102381 <dirlink>
8010559b:	83 c4 10             	add    $0x10,%esp
8010559e:	85 c0                	test   %eax,%eax
801055a0:	79 10                	jns    801055b2 <sys_link+0x136>
    iunlockput(dp);
801055a2:	83 ec 0c             	sub    $0xc,%esp
801055a5:	ff 75 f0             	push   -0x10(%ebp)
801055a8:	e8 49 c7 ff ff       	call   80101cf6 <iunlockput>
801055ad:	83 c4 10             	add    $0x10,%esp
    goto bad;
801055b0:	eb 29                	jmp    801055db <sys_link+0x15f>
  }
  iunlockput(dp);
801055b2:	83 ec 0c             	sub    $0xc,%esp
801055b5:	ff 75 f0             	push   -0x10(%ebp)
801055b8:	e8 39 c7 ff ff       	call   80101cf6 <iunlockput>
801055bd:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801055c0:	83 ec 0c             	sub    $0xc,%esp
801055c3:	ff 75 f4             	push   -0xc(%ebp)
801055c6:	e8 57 c6 ff ff       	call   80101c22 <iput>
801055cb:	83 c4 10             	add    $0x10,%esp

  end_op();
801055ce:	e8 6b dc ff ff       	call   8010323e <end_op>

  return 0;
801055d3:	b8 00 00 00 00       	mov    $0x0,%eax
801055d8:	eb 48                	jmp    80105622 <sys_link+0x1a6>
    goto bad;
801055da:	90                   	nop

bad:
  ilock(ip);
801055db:	83 ec 0c             	sub    $0xc,%esp
801055de:	ff 75 f4             	push   -0xc(%ebp)
801055e1:	e8 d3 c4 ff ff       	call   80101ab9 <ilock>
801055e6:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801055e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ec:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055f0:	83 e8 01             	sub    $0x1,%eax
801055f3:	89 c2                	mov    %eax,%edx
801055f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f8:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801055fc:	83 ec 0c             	sub    $0xc,%esp
801055ff:	ff 75 f4             	push   -0xc(%ebp)
80105602:	e8 c9 c2 ff ff       	call   801018d0 <iupdate>
80105607:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010560a:	83 ec 0c             	sub    $0xc,%esp
8010560d:	ff 75 f4             	push   -0xc(%ebp)
80105610:	e8 e1 c6 ff ff       	call   80101cf6 <iunlockput>
80105615:	83 c4 10             	add    $0x10,%esp
  end_op();
80105618:	e8 21 dc ff ff       	call   8010323e <end_op>
  return -1;
8010561d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105622:	c9                   	leave
80105623:	c3                   	ret

80105624 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105624:	f3 0f 1e fb          	endbr32
80105628:	55                   	push   %ebp
80105629:	89 e5                	mov    %esp,%ebp
8010562b:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010562e:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105635:	eb 40                	jmp    80105677 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010563a:	6a 10                	push   $0x10
8010563c:	50                   	push   %eax
8010563d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105640:	50                   	push   %eax
80105641:	ff 75 08             	push   0x8(%ebp)
80105644:	e8 78 c9 ff ff       	call   80101fc1 <readi>
80105649:	83 c4 10             	add    $0x10,%esp
8010564c:	83 f8 10             	cmp    $0x10,%eax
8010564f:	74 0d                	je     8010565e <isdirempty+0x3a>
      panic("isdirempty: readi");
80105651:	83 ec 0c             	sub    $0xc,%esp
80105654:	68 3c ab 10 80       	push   $0x8010ab3c
80105659:	e8 67 af ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
8010565e:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105662:	66 85 c0             	test   %ax,%ax
80105665:	74 07                	je     8010566e <isdirempty+0x4a>
      return 0;
80105667:	b8 00 00 00 00       	mov    $0x0,%eax
8010566c:	eb 1b                	jmp    80105689 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010566e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105671:	83 c0 10             	add    $0x10,%eax
80105674:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105677:	8b 45 08             	mov    0x8(%ebp),%eax
8010567a:	8b 50 58             	mov    0x58(%eax),%edx
8010567d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105680:	39 c2                	cmp    %eax,%edx
80105682:	77 b3                	ja     80105637 <isdirempty+0x13>
  }
  return 1;
80105684:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105689:	c9                   	leave
8010568a:	c3                   	ret

8010568b <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010568b:	f3 0f 1e fb          	endbr32
8010568f:	55                   	push   %ebp
80105690:	89 e5                	mov    %esp,%ebp
80105692:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105695:	83 ec 08             	sub    $0x8,%esp
80105698:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010569b:	50                   	push   %eax
8010569c:	6a 00                	push   $0x0
8010569e:	e8 72 fa ff ff       	call   80105115 <argstr>
801056a3:	83 c4 10             	add    $0x10,%esp
801056a6:	85 c0                	test   %eax,%eax
801056a8:	79 0a                	jns    801056b4 <sys_unlink+0x29>
    return -1;
801056aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056af:	e9 bf 01 00 00       	jmp    80105873 <sys_unlink+0x1e8>

  begin_op();
801056b4:	e8 f5 da ff ff       	call   801031ae <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801056b9:	8b 45 cc             	mov    -0x34(%ebp),%eax
801056bc:	83 ec 08             	sub    $0x8,%esp
801056bf:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801056c2:	52                   	push   %edx
801056c3:	50                   	push   %eax
801056c4:	e8 7b cf ff ff       	call   80102644 <nameiparent>
801056c9:	83 c4 10             	add    $0x10,%esp
801056cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056d3:	75 0f                	jne    801056e4 <sys_unlink+0x59>
    end_op();
801056d5:	e8 64 db ff ff       	call   8010323e <end_op>
    return -1;
801056da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056df:	e9 8f 01 00 00       	jmp    80105873 <sys_unlink+0x1e8>
  }

  ilock(dp);
801056e4:	83 ec 0c             	sub    $0xc,%esp
801056e7:	ff 75 f4             	push   -0xc(%ebp)
801056ea:	e8 ca c3 ff ff       	call   80101ab9 <ilock>
801056ef:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801056f2:	83 ec 08             	sub    $0x8,%esp
801056f5:	68 4e ab 10 80       	push   $0x8010ab4e
801056fa:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801056fd:	50                   	push   %eax
801056fe:	e8 a1 cb ff ff       	call   801022a4 <namecmp>
80105703:	83 c4 10             	add    $0x10,%esp
80105706:	85 c0                	test   %eax,%eax
80105708:	0f 84 49 01 00 00    	je     80105857 <sys_unlink+0x1cc>
8010570e:	83 ec 08             	sub    $0x8,%esp
80105711:	68 50 ab 10 80       	push   $0x8010ab50
80105716:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105719:	50                   	push   %eax
8010571a:	e8 85 cb ff ff       	call   801022a4 <namecmp>
8010571f:	83 c4 10             	add    $0x10,%esp
80105722:	85 c0                	test   %eax,%eax
80105724:	0f 84 2d 01 00 00    	je     80105857 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010572a:	83 ec 04             	sub    $0x4,%esp
8010572d:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105730:	50                   	push   %eax
80105731:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105734:	50                   	push   %eax
80105735:	ff 75 f4             	push   -0xc(%ebp)
80105738:	e8 86 cb ff ff       	call   801022c3 <dirlookup>
8010573d:	83 c4 10             	add    $0x10,%esp
80105740:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105743:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105747:	0f 84 0d 01 00 00    	je     8010585a <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
8010574d:	83 ec 0c             	sub    $0xc,%esp
80105750:	ff 75 f0             	push   -0x10(%ebp)
80105753:	e8 61 c3 ff ff       	call   80101ab9 <ilock>
80105758:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010575b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010575e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105762:	66 85 c0             	test   %ax,%ax
80105765:	7f 0d                	jg     80105774 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105767:	83 ec 0c             	sub    $0xc,%esp
8010576a:	68 53 ab 10 80       	push   $0x8010ab53
8010576f:	e8 51 ae ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105774:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105777:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010577b:	66 83 f8 01          	cmp    $0x1,%ax
8010577f:	75 25                	jne    801057a6 <sys_unlink+0x11b>
80105781:	83 ec 0c             	sub    $0xc,%esp
80105784:	ff 75 f0             	push   -0x10(%ebp)
80105787:	e8 98 fe ff ff       	call   80105624 <isdirempty>
8010578c:	83 c4 10             	add    $0x10,%esp
8010578f:	85 c0                	test   %eax,%eax
80105791:	75 13                	jne    801057a6 <sys_unlink+0x11b>
    iunlockput(ip);
80105793:	83 ec 0c             	sub    $0xc,%esp
80105796:	ff 75 f0             	push   -0x10(%ebp)
80105799:	e8 58 c5 ff ff       	call   80101cf6 <iunlockput>
8010579e:	83 c4 10             	add    $0x10,%esp
    goto bad;
801057a1:	e9 b5 00 00 00       	jmp    8010585b <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
801057a6:	83 ec 04             	sub    $0x4,%esp
801057a9:	6a 10                	push   $0x10
801057ab:	6a 00                	push   $0x0
801057ad:	8d 45 e0             	lea    -0x20(%ebp),%eax
801057b0:	50                   	push   %eax
801057b1:	e8 9c f5 ff ff       	call   80104d52 <memset>
801057b6:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801057b9:	8b 45 c8             	mov    -0x38(%ebp),%eax
801057bc:	6a 10                	push   $0x10
801057be:	50                   	push   %eax
801057bf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801057c2:	50                   	push   %eax
801057c3:	ff 75 f4             	push   -0xc(%ebp)
801057c6:	e8 4f c9 ff ff       	call   8010211a <writei>
801057cb:	83 c4 10             	add    $0x10,%esp
801057ce:	83 f8 10             	cmp    $0x10,%eax
801057d1:	74 0d                	je     801057e0 <sys_unlink+0x155>
    panic("unlink: writei");
801057d3:	83 ec 0c             	sub    $0xc,%esp
801057d6:	68 65 ab 10 80       	push   $0x8010ab65
801057db:	e8 e5 ad ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
801057e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801057e7:	66 83 f8 01          	cmp    $0x1,%ax
801057eb:	75 21                	jne    8010580e <sys_unlink+0x183>
    dp->nlink--;
801057ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057f4:	83 e8 01             	sub    $0x1,%eax
801057f7:	89 c2                	mov    %eax,%edx
801057f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057fc:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105800:	83 ec 0c             	sub    $0xc,%esp
80105803:	ff 75 f4             	push   -0xc(%ebp)
80105806:	e8 c5 c0 ff ff       	call   801018d0 <iupdate>
8010580b:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010580e:	83 ec 0c             	sub    $0xc,%esp
80105811:	ff 75 f4             	push   -0xc(%ebp)
80105814:	e8 dd c4 ff ff       	call   80101cf6 <iunlockput>
80105819:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010581c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010581f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105823:	83 e8 01             	sub    $0x1,%eax
80105826:	89 c2                	mov    %eax,%edx
80105828:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010582b:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010582f:	83 ec 0c             	sub    $0xc,%esp
80105832:	ff 75 f0             	push   -0x10(%ebp)
80105835:	e8 96 c0 ff ff       	call   801018d0 <iupdate>
8010583a:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010583d:	83 ec 0c             	sub    $0xc,%esp
80105840:	ff 75 f0             	push   -0x10(%ebp)
80105843:	e8 ae c4 ff ff       	call   80101cf6 <iunlockput>
80105848:	83 c4 10             	add    $0x10,%esp

  end_op();
8010584b:	e8 ee d9 ff ff       	call   8010323e <end_op>

  return 0;
80105850:	b8 00 00 00 00       	mov    $0x0,%eax
80105855:	eb 1c                	jmp    80105873 <sys_unlink+0x1e8>
    goto bad;
80105857:	90                   	nop
80105858:	eb 01                	jmp    8010585b <sys_unlink+0x1d0>
    goto bad;
8010585a:	90                   	nop

bad:
  iunlockput(dp);
8010585b:	83 ec 0c             	sub    $0xc,%esp
8010585e:	ff 75 f4             	push   -0xc(%ebp)
80105861:	e8 90 c4 ff ff       	call   80101cf6 <iunlockput>
80105866:	83 c4 10             	add    $0x10,%esp
  end_op();
80105869:	e8 d0 d9 ff ff       	call   8010323e <end_op>
  return -1;
8010586e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105873:	c9                   	leave
80105874:	c3                   	ret

80105875 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105875:	f3 0f 1e fb          	endbr32
80105879:	55                   	push   %ebp
8010587a:	89 e5                	mov    %esp,%ebp
8010587c:	83 ec 38             	sub    $0x38,%esp
8010587f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105882:	8b 55 10             	mov    0x10(%ebp),%edx
80105885:	8b 45 14             	mov    0x14(%ebp),%eax
80105888:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010588c:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105890:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105894:	83 ec 08             	sub    $0x8,%esp
80105897:	8d 45 de             	lea    -0x22(%ebp),%eax
8010589a:	50                   	push   %eax
8010589b:	ff 75 08             	push   0x8(%ebp)
8010589e:	e8 a1 cd ff ff       	call   80102644 <nameiparent>
801058a3:	83 c4 10             	add    $0x10,%esp
801058a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058ad:	75 0a                	jne    801058b9 <create+0x44>
    return 0;
801058af:	b8 00 00 00 00       	mov    $0x0,%eax
801058b4:	e9 90 01 00 00       	jmp    80105a49 <create+0x1d4>
  ilock(dp);
801058b9:	83 ec 0c             	sub    $0xc,%esp
801058bc:	ff 75 f4             	push   -0xc(%ebp)
801058bf:	e8 f5 c1 ff ff       	call   80101ab9 <ilock>
801058c4:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801058c7:	83 ec 04             	sub    $0x4,%esp
801058ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058cd:	50                   	push   %eax
801058ce:	8d 45 de             	lea    -0x22(%ebp),%eax
801058d1:	50                   	push   %eax
801058d2:	ff 75 f4             	push   -0xc(%ebp)
801058d5:	e8 e9 c9 ff ff       	call   801022c3 <dirlookup>
801058da:	83 c4 10             	add    $0x10,%esp
801058dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801058e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058e4:	74 50                	je     80105936 <create+0xc1>
    iunlockput(dp);
801058e6:	83 ec 0c             	sub    $0xc,%esp
801058e9:	ff 75 f4             	push   -0xc(%ebp)
801058ec:	e8 05 c4 ff ff       	call   80101cf6 <iunlockput>
801058f1:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801058f4:	83 ec 0c             	sub    $0xc,%esp
801058f7:	ff 75 f0             	push   -0x10(%ebp)
801058fa:	e8 ba c1 ff ff       	call   80101ab9 <ilock>
801058ff:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105902:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105907:	75 15                	jne    8010591e <create+0xa9>
80105909:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010590c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105910:	66 83 f8 02          	cmp    $0x2,%ax
80105914:	75 08                	jne    8010591e <create+0xa9>
      return ip;
80105916:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105919:	e9 2b 01 00 00       	jmp    80105a49 <create+0x1d4>
    iunlockput(ip);
8010591e:	83 ec 0c             	sub    $0xc,%esp
80105921:	ff 75 f0             	push   -0x10(%ebp)
80105924:	e8 cd c3 ff ff       	call   80101cf6 <iunlockput>
80105929:	83 c4 10             	add    $0x10,%esp
    return 0;
8010592c:	b8 00 00 00 00       	mov    $0x0,%eax
80105931:	e9 13 01 00 00       	jmp    80105a49 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105936:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010593a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010593d:	8b 00                	mov    (%eax),%eax
8010593f:	83 ec 08             	sub    $0x8,%esp
80105942:	52                   	push   %edx
80105943:	50                   	push   %eax
80105944:	e8 ac be ff ff       	call   801017f5 <ialloc>
80105949:	83 c4 10             	add    $0x10,%esp
8010594c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010594f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105953:	75 0d                	jne    80105962 <create+0xed>
    panic("create: ialloc");
80105955:	83 ec 0c             	sub    $0xc,%esp
80105958:	68 74 ab 10 80       	push   $0x8010ab74
8010595d:	e8 63 ac ff ff       	call   801005c5 <panic>

  ilock(ip);
80105962:	83 ec 0c             	sub    $0xc,%esp
80105965:	ff 75 f0             	push   -0x10(%ebp)
80105968:	e8 4c c1 ff ff       	call   80101ab9 <ilock>
8010596d:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105970:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105973:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105977:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
8010597b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010597e:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105982:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105986:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105989:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010598f:	83 ec 0c             	sub    $0xc,%esp
80105992:	ff 75 f0             	push   -0x10(%ebp)
80105995:	e8 36 bf ff ff       	call   801018d0 <iupdate>
8010599a:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
8010599d:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801059a2:	75 6a                	jne    80105a0e <create+0x199>
    dp->nlink++;  // for ".."
801059a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801059ab:	83 c0 01             	add    $0x1,%eax
801059ae:	89 c2                	mov    %eax,%edx
801059b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b3:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801059b7:	83 ec 0c             	sub    $0xc,%esp
801059ba:	ff 75 f4             	push   -0xc(%ebp)
801059bd:	e8 0e bf ff ff       	call   801018d0 <iupdate>
801059c2:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801059c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059c8:	8b 40 04             	mov    0x4(%eax),%eax
801059cb:	83 ec 04             	sub    $0x4,%esp
801059ce:	50                   	push   %eax
801059cf:	68 4e ab 10 80       	push   $0x8010ab4e
801059d4:	ff 75 f0             	push   -0x10(%ebp)
801059d7:	e8 a5 c9 ff ff       	call   80102381 <dirlink>
801059dc:	83 c4 10             	add    $0x10,%esp
801059df:	85 c0                	test   %eax,%eax
801059e1:	78 1e                	js     80105a01 <create+0x18c>
801059e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e6:	8b 40 04             	mov    0x4(%eax),%eax
801059e9:	83 ec 04             	sub    $0x4,%esp
801059ec:	50                   	push   %eax
801059ed:	68 50 ab 10 80       	push   $0x8010ab50
801059f2:	ff 75 f0             	push   -0x10(%ebp)
801059f5:	e8 87 c9 ff ff       	call   80102381 <dirlink>
801059fa:	83 c4 10             	add    $0x10,%esp
801059fd:	85 c0                	test   %eax,%eax
801059ff:	79 0d                	jns    80105a0e <create+0x199>
      panic("create dots");
80105a01:	83 ec 0c             	sub    $0xc,%esp
80105a04:	68 83 ab 10 80       	push   $0x8010ab83
80105a09:	e8 b7 ab ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a11:	8b 40 04             	mov    0x4(%eax),%eax
80105a14:	83 ec 04             	sub    $0x4,%esp
80105a17:	50                   	push   %eax
80105a18:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a1b:	50                   	push   %eax
80105a1c:	ff 75 f4             	push   -0xc(%ebp)
80105a1f:	e8 5d c9 ff ff       	call   80102381 <dirlink>
80105a24:	83 c4 10             	add    $0x10,%esp
80105a27:	85 c0                	test   %eax,%eax
80105a29:	79 0d                	jns    80105a38 <create+0x1c3>
    panic("create: dirlink");
80105a2b:	83 ec 0c             	sub    $0xc,%esp
80105a2e:	68 8f ab 10 80       	push   $0x8010ab8f
80105a33:	e8 8d ab ff ff       	call   801005c5 <panic>

  iunlockput(dp);
80105a38:	83 ec 0c             	sub    $0xc,%esp
80105a3b:	ff 75 f4             	push   -0xc(%ebp)
80105a3e:	e8 b3 c2 ff ff       	call   80101cf6 <iunlockput>
80105a43:	83 c4 10             	add    $0x10,%esp

  return ip;
80105a46:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105a49:	c9                   	leave
80105a4a:	c3                   	ret

80105a4b <sys_open>:

int
sys_open(void)
{
80105a4b:	f3 0f 1e fb          	endbr32
80105a4f:	55                   	push   %ebp
80105a50:	89 e5                	mov    %esp,%ebp
80105a52:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105a55:	83 ec 08             	sub    $0x8,%esp
80105a58:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105a5b:	50                   	push   %eax
80105a5c:	6a 00                	push   $0x0
80105a5e:	e8 b2 f6 ff ff       	call   80105115 <argstr>
80105a63:	83 c4 10             	add    $0x10,%esp
80105a66:	85 c0                	test   %eax,%eax
80105a68:	78 15                	js     80105a7f <sys_open+0x34>
80105a6a:	83 ec 08             	sub    $0x8,%esp
80105a6d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a70:	50                   	push   %eax
80105a71:	6a 01                	push   $0x1
80105a73:	e8 0f f6 ff ff       	call   80105087 <argint>
80105a78:	83 c4 10             	add    $0x10,%esp
80105a7b:	85 c0                	test   %eax,%eax
80105a7d:	79 0a                	jns    80105a89 <sys_open+0x3e>
    return -1;
80105a7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a84:	e9 61 01 00 00       	jmp    80105bea <sys_open+0x19f>

  begin_op();
80105a89:	e8 20 d7 ff ff       	call   801031ae <begin_op>

  if(omode & O_CREATE){
80105a8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105a91:	25 00 02 00 00       	and    $0x200,%eax
80105a96:	85 c0                	test   %eax,%eax
80105a98:	74 2a                	je     80105ac4 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80105a9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105a9d:	6a 00                	push   $0x0
80105a9f:	6a 00                	push   $0x0
80105aa1:	6a 02                	push   $0x2
80105aa3:	50                   	push   %eax
80105aa4:	e8 cc fd ff ff       	call   80105875 <create>
80105aa9:	83 c4 10             	add    $0x10,%esp
80105aac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105aaf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ab3:	75 75                	jne    80105b2a <sys_open+0xdf>
      end_op();
80105ab5:	e8 84 d7 ff ff       	call   8010323e <end_op>
      return -1;
80105aba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105abf:	e9 26 01 00 00       	jmp    80105bea <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80105ac4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ac7:	83 ec 0c             	sub    $0xc,%esp
80105aca:	50                   	push   %eax
80105acb:	e8 54 cb ff ff       	call   80102624 <namei>
80105ad0:	83 c4 10             	add    $0x10,%esp
80105ad3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ad6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ada:	75 0f                	jne    80105aeb <sys_open+0xa0>
      end_op();
80105adc:	e8 5d d7 ff ff       	call   8010323e <end_op>
      return -1;
80105ae1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ae6:	e9 ff 00 00 00       	jmp    80105bea <sys_open+0x19f>
    }
    ilock(ip);
80105aeb:	83 ec 0c             	sub    $0xc,%esp
80105aee:	ff 75 f4             	push   -0xc(%ebp)
80105af1:	e8 c3 bf ff ff       	call   80101ab9 <ilock>
80105af6:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afc:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b00:	66 83 f8 01          	cmp    $0x1,%ax
80105b04:	75 24                	jne    80105b2a <sys_open+0xdf>
80105b06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b09:	85 c0                	test   %eax,%eax
80105b0b:	74 1d                	je     80105b2a <sys_open+0xdf>
      iunlockput(ip);
80105b0d:	83 ec 0c             	sub    $0xc,%esp
80105b10:	ff 75 f4             	push   -0xc(%ebp)
80105b13:	e8 de c1 ff ff       	call   80101cf6 <iunlockput>
80105b18:	83 c4 10             	add    $0x10,%esp
      end_op();
80105b1b:	e8 1e d7 ff ff       	call   8010323e <end_op>
      return -1;
80105b20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b25:	e9 c0 00 00 00       	jmp    80105bea <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105b2a:	e8 31 b5 ff ff       	call   80101060 <filealloc>
80105b2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b32:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b36:	74 17                	je     80105b4f <sys_open+0x104>
80105b38:	83 ec 0c             	sub    $0xc,%esp
80105b3b:	ff 75 f0             	push   -0x10(%ebp)
80105b3e:	e8 07 f7 ff ff       	call   8010524a <fdalloc>
80105b43:	83 c4 10             	add    $0x10,%esp
80105b46:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105b49:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105b4d:	79 2e                	jns    80105b7d <sys_open+0x132>
    if(f)
80105b4f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b53:	74 0e                	je     80105b63 <sys_open+0x118>
      fileclose(f);
80105b55:	83 ec 0c             	sub    $0xc,%esp
80105b58:	ff 75 f0             	push   -0x10(%ebp)
80105b5b:	e8 c6 b5 ff ff       	call   80101126 <fileclose>
80105b60:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105b63:	83 ec 0c             	sub    $0xc,%esp
80105b66:	ff 75 f4             	push   -0xc(%ebp)
80105b69:	e8 88 c1 ff ff       	call   80101cf6 <iunlockput>
80105b6e:	83 c4 10             	add    $0x10,%esp
    end_op();
80105b71:	e8 c8 d6 ff ff       	call   8010323e <end_op>
    return -1;
80105b76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b7b:	eb 6d                	jmp    80105bea <sys_open+0x19f>
  }
  iunlock(ip);
80105b7d:	83 ec 0c             	sub    $0xc,%esp
80105b80:	ff 75 f4             	push   -0xc(%ebp)
80105b83:	e8 48 c0 ff ff       	call   80101bd0 <iunlock>
80105b88:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b8b:	e8 ae d6 ff ff       	call   8010323e <end_op>

  f->type = FD_INODE;
80105b90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b93:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b9f:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba5:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105bac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105baf:	83 e0 01             	and    $0x1,%eax
80105bb2:	85 c0                	test   %eax,%eax
80105bb4:	0f 94 c0             	sete   %al
80105bb7:	89 c2                	mov    %eax,%edx
80105bb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bbc:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105bbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bc2:	83 e0 01             	and    $0x1,%eax
80105bc5:	85 c0                	test   %eax,%eax
80105bc7:	75 0a                	jne    80105bd3 <sys_open+0x188>
80105bc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bcc:	83 e0 02             	and    $0x2,%eax
80105bcf:	85 c0                	test   %eax,%eax
80105bd1:	74 07                	je     80105bda <sys_open+0x18f>
80105bd3:	b8 01 00 00 00       	mov    $0x1,%eax
80105bd8:	eb 05                	jmp    80105bdf <sys_open+0x194>
80105bda:	b8 00 00 00 00       	mov    $0x0,%eax
80105bdf:	89 c2                	mov    %eax,%edx
80105be1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105be4:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105be7:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105bea:	c9                   	leave
80105beb:	c3                   	ret

80105bec <sys_mkdir>:

int
sys_mkdir(void)
{
80105bec:	f3 0f 1e fb          	endbr32
80105bf0:	55                   	push   %ebp
80105bf1:	89 e5                	mov    %esp,%ebp
80105bf3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105bf6:	e8 b3 d5 ff ff       	call   801031ae <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105bfb:	83 ec 08             	sub    $0x8,%esp
80105bfe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c01:	50                   	push   %eax
80105c02:	6a 00                	push   $0x0
80105c04:	e8 0c f5 ff ff       	call   80105115 <argstr>
80105c09:	83 c4 10             	add    $0x10,%esp
80105c0c:	85 c0                	test   %eax,%eax
80105c0e:	78 1b                	js     80105c2b <sys_mkdir+0x3f>
80105c10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c13:	6a 00                	push   $0x0
80105c15:	6a 00                	push   $0x0
80105c17:	6a 01                	push   $0x1
80105c19:	50                   	push   %eax
80105c1a:	e8 56 fc ff ff       	call   80105875 <create>
80105c1f:	83 c4 10             	add    $0x10,%esp
80105c22:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c25:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c29:	75 0c                	jne    80105c37 <sys_mkdir+0x4b>
    end_op();
80105c2b:	e8 0e d6 ff ff       	call   8010323e <end_op>
    return -1;
80105c30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c35:	eb 18                	jmp    80105c4f <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105c37:	83 ec 0c             	sub    $0xc,%esp
80105c3a:	ff 75 f4             	push   -0xc(%ebp)
80105c3d:	e8 b4 c0 ff ff       	call   80101cf6 <iunlockput>
80105c42:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c45:	e8 f4 d5 ff ff       	call   8010323e <end_op>
  return 0;
80105c4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c4f:	c9                   	leave
80105c50:	c3                   	ret

80105c51 <sys_mknod>:

int
sys_mknod(void)
{
80105c51:	f3 0f 1e fb          	endbr32
80105c55:	55                   	push   %ebp
80105c56:	89 e5                	mov    %esp,%ebp
80105c58:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105c5b:	e8 4e d5 ff ff       	call   801031ae <begin_op>
  if((argstr(0, &path)) < 0 ||
80105c60:	83 ec 08             	sub    $0x8,%esp
80105c63:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c66:	50                   	push   %eax
80105c67:	6a 00                	push   $0x0
80105c69:	e8 a7 f4 ff ff       	call   80105115 <argstr>
80105c6e:	83 c4 10             	add    $0x10,%esp
80105c71:	85 c0                	test   %eax,%eax
80105c73:	78 4f                	js     80105cc4 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105c75:	83 ec 08             	sub    $0x8,%esp
80105c78:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c7b:	50                   	push   %eax
80105c7c:	6a 01                	push   $0x1
80105c7e:	e8 04 f4 ff ff       	call   80105087 <argint>
80105c83:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105c86:	85 c0                	test   %eax,%eax
80105c88:	78 3a                	js     80105cc4 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105c8a:	83 ec 08             	sub    $0x8,%esp
80105c8d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c90:	50                   	push   %eax
80105c91:	6a 02                	push   $0x2
80105c93:	e8 ef f3 ff ff       	call   80105087 <argint>
80105c98:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105c9b:	85 c0                	test   %eax,%eax
80105c9d:	78 25                	js     80105cc4 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105c9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ca2:	0f bf c8             	movswl %ax,%ecx
80105ca5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ca8:	0f bf d0             	movswl %ax,%edx
80105cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cae:	51                   	push   %ecx
80105caf:	52                   	push   %edx
80105cb0:	6a 03                	push   $0x3
80105cb2:	50                   	push   %eax
80105cb3:	e8 bd fb ff ff       	call   80105875 <create>
80105cb8:	83 c4 10             	add    $0x10,%esp
80105cbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105cbe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cc2:	75 0c                	jne    80105cd0 <sys_mknod+0x7f>
    end_op();
80105cc4:	e8 75 d5 ff ff       	call   8010323e <end_op>
    return -1;
80105cc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cce:	eb 18                	jmp    80105ce8 <sys_mknod+0x97>
  }
  iunlockput(ip);
80105cd0:	83 ec 0c             	sub    $0xc,%esp
80105cd3:	ff 75 f4             	push   -0xc(%ebp)
80105cd6:	e8 1b c0 ff ff       	call   80101cf6 <iunlockput>
80105cdb:	83 c4 10             	add    $0x10,%esp
  end_op();
80105cde:	e8 5b d5 ff ff       	call   8010323e <end_op>
  return 0;
80105ce3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ce8:	c9                   	leave
80105ce9:	c3                   	ret

80105cea <sys_chdir>:

int
sys_chdir(void)
{
80105cea:	f3 0f 1e fb          	endbr32
80105cee:	55                   	push   %ebp
80105cef:	89 e5                	mov    %esp,%ebp
80105cf1:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105cf4:	e8 ed de ff ff       	call   80103be6 <myproc>
80105cf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105cfc:	e8 ad d4 ff ff       	call   801031ae <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105d01:	83 ec 08             	sub    $0x8,%esp
80105d04:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d07:	50                   	push   %eax
80105d08:	6a 00                	push   $0x0
80105d0a:	e8 06 f4 ff ff       	call   80105115 <argstr>
80105d0f:	83 c4 10             	add    $0x10,%esp
80105d12:	85 c0                	test   %eax,%eax
80105d14:	78 18                	js     80105d2e <sys_chdir+0x44>
80105d16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d19:	83 ec 0c             	sub    $0xc,%esp
80105d1c:	50                   	push   %eax
80105d1d:	e8 02 c9 ff ff       	call   80102624 <namei>
80105d22:	83 c4 10             	add    $0x10,%esp
80105d25:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d28:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d2c:	75 0c                	jne    80105d3a <sys_chdir+0x50>
    end_op();
80105d2e:	e8 0b d5 ff ff       	call   8010323e <end_op>
    return -1;
80105d33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d38:	eb 68                	jmp    80105da2 <sys_chdir+0xb8>
  }
  ilock(ip);
80105d3a:	83 ec 0c             	sub    $0xc,%esp
80105d3d:	ff 75 f0             	push   -0x10(%ebp)
80105d40:	e8 74 bd ff ff       	call   80101ab9 <ilock>
80105d45:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105d48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d4b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d4f:	66 83 f8 01          	cmp    $0x1,%ax
80105d53:	74 1a                	je     80105d6f <sys_chdir+0x85>
    iunlockput(ip);
80105d55:	83 ec 0c             	sub    $0xc,%esp
80105d58:	ff 75 f0             	push   -0x10(%ebp)
80105d5b:	e8 96 bf ff ff       	call   80101cf6 <iunlockput>
80105d60:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d63:	e8 d6 d4 ff ff       	call   8010323e <end_op>
    return -1;
80105d68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6d:	eb 33                	jmp    80105da2 <sys_chdir+0xb8>
  }
  iunlock(ip);
80105d6f:	83 ec 0c             	sub    $0xc,%esp
80105d72:	ff 75 f0             	push   -0x10(%ebp)
80105d75:	e8 56 be ff ff       	call   80101bd0 <iunlock>
80105d7a:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d80:	8b 40 68             	mov    0x68(%eax),%eax
80105d83:	83 ec 0c             	sub    $0xc,%esp
80105d86:	50                   	push   %eax
80105d87:	e8 96 be ff ff       	call   80101c22 <iput>
80105d8c:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d8f:	e8 aa d4 ff ff       	call   8010323e <end_op>
  curproc->cwd = ip;
80105d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d97:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d9a:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105d9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105da2:	c9                   	leave
80105da3:	c3                   	ret

80105da4 <sys_exec>:

int
sys_exec(void)
{
80105da4:	f3 0f 1e fb          	endbr32
80105da8:	55                   	push   %ebp
80105da9:	89 e5                	mov    %esp,%ebp
80105dab:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105db1:	83 ec 08             	sub    $0x8,%esp
80105db4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105db7:	50                   	push   %eax
80105db8:	6a 00                	push   $0x0
80105dba:	e8 56 f3 ff ff       	call   80105115 <argstr>
80105dbf:	83 c4 10             	add    $0x10,%esp
80105dc2:	85 c0                	test   %eax,%eax
80105dc4:	78 18                	js     80105dde <sys_exec+0x3a>
80105dc6:	83 ec 08             	sub    $0x8,%esp
80105dc9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105dcf:	50                   	push   %eax
80105dd0:	6a 01                	push   $0x1
80105dd2:	e8 b0 f2 ff ff       	call   80105087 <argint>
80105dd7:	83 c4 10             	add    $0x10,%esp
80105dda:	85 c0                	test   %eax,%eax
80105ddc:	79 0a                	jns    80105de8 <sys_exec+0x44>
    return -1;
80105dde:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105de3:	e9 c6 00 00 00       	jmp    80105eae <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80105de8:	83 ec 04             	sub    $0x4,%esp
80105deb:	68 80 00 00 00       	push   $0x80
80105df0:	6a 00                	push   $0x0
80105df2:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105df8:	50                   	push   %eax
80105df9:	e8 54 ef ff ff       	call   80104d52 <memset>
80105dfe:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105e01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0b:	83 f8 1f             	cmp    $0x1f,%eax
80105e0e:	76 0a                	jbe    80105e1a <sys_exec+0x76>
      return -1;
80105e10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e15:	e9 94 00 00 00       	jmp    80105eae <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1d:	c1 e0 02             	shl    $0x2,%eax
80105e20:	89 c2                	mov    %eax,%edx
80105e22:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105e28:	01 c2                	add    %eax,%edx
80105e2a:	83 ec 08             	sub    $0x8,%esp
80105e2d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105e33:	50                   	push   %eax
80105e34:	52                   	push   %edx
80105e35:	e8 c1 f1 ff ff       	call   80104ffb <fetchint>
80105e3a:	83 c4 10             	add    $0x10,%esp
80105e3d:	85 c0                	test   %eax,%eax
80105e3f:	79 07                	jns    80105e48 <sys_exec+0xa4>
      return -1;
80105e41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e46:	eb 66                	jmp    80105eae <sys_exec+0x10a>
    if(uarg == 0){
80105e48:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e4e:	85 c0                	test   %eax,%eax
80105e50:	75 27                	jne    80105e79 <sys_exec+0xd5>
      argv[i] = 0;
80105e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e55:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105e5c:	00 00 00 00 
      break;
80105e60:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e64:	83 ec 08             	sub    $0x8,%esp
80105e67:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105e6d:	52                   	push   %edx
80105e6e:	50                   	push   %eax
80105e6f:	e8 4a ad ff ff       	call   80100bbe <exec>
80105e74:	83 c4 10             	add    $0x10,%esp
80105e77:	eb 35                	jmp    80105eae <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80105e79:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e82:	c1 e2 02             	shl    $0x2,%edx
80105e85:	01 c2                	add    %eax,%edx
80105e87:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e8d:	83 ec 08             	sub    $0x8,%esp
80105e90:	52                   	push   %edx
80105e91:	50                   	push   %eax
80105e92:	e8 94 f1 ff ff       	call   8010502b <fetchstr>
80105e97:	83 c4 10             	add    $0x10,%esp
80105e9a:	85 c0                	test   %eax,%eax
80105e9c:	79 07                	jns    80105ea5 <sys_exec+0x101>
      return -1;
80105e9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ea3:	eb 09                	jmp    80105eae <sys_exec+0x10a>
  for(i=0;; i++){
80105ea5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ea9:	e9 5a ff ff ff       	jmp    80105e08 <sys_exec+0x64>
}
80105eae:	c9                   	leave
80105eaf:	c3                   	ret

80105eb0 <sys_pipe>:

int
sys_pipe(void)
{
80105eb0:	f3 0f 1e fb          	endbr32
80105eb4:	55                   	push   %ebp
80105eb5:	89 e5                	mov    %esp,%ebp
80105eb7:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105eba:	83 ec 04             	sub    $0x4,%esp
80105ebd:	6a 08                	push   $0x8
80105ebf:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ec2:	50                   	push   %eax
80105ec3:	6a 00                	push   $0x0
80105ec5:	e8 ee f1 ff ff       	call   801050b8 <argptr>
80105eca:	83 c4 10             	add    $0x10,%esp
80105ecd:	85 c0                	test   %eax,%eax
80105ecf:	79 0a                	jns    80105edb <sys_pipe+0x2b>
    return -1;
80105ed1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ed6:	e9 ae 00 00 00       	jmp    80105f89 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80105edb:	83 ec 08             	sub    $0x8,%esp
80105ede:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ee1:	50                   	push   %eax
80105ee2:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ee5:	50                   	push   %eax
80105ee6:	e8 1c d8 ff ff       	call   80103707 <pipealloc>
80105eeb:	83 c4 10             	add    $0x10,%esp
80105eee:	85 c0                	test   %eax,%eax
80105ef0:	79 0a                	jns    80105efc <sys_pipe+0x4c>
    return -1;
80105ef2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef7:	e9 8d 00 00 00       	jmp    80105f89 <sys_pipe+0xd9>
  fd0 = -1;
80105efc:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105f03:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f06:	83 ec 0c             	sub    $0xc,%esp
80105f09:	50                   	push   %eax
80105f0a:	e8 3b f3 ff ff       	call   8010524a <fdalloc>
80105f0f:	83 c4 10             	add    $0x10,%esp
80105f12:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f15:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f19:	78 18                	js     80105f33 <sys_pipe+0x83>
80105f1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f1e:	83 ec 0c             	sub    $0xc,%esp
80105f21:	50                   	push   %eax
80105f22:	e8 23 f3 ff ff       	call   8010524a <fdalloc>
80105f27:	83 c4 10             	add    $0x10,%esp
80105f2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f2d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f31:	79 3e                	jns    80105f71 <sys_pipe+0xc1>
    if(fd0 >= 0)
80105f33:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f37:	78 13                	js     80105f4c <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80105f39:	e8 a8 dc ff ff       	call   80103be6 <myproc>
80105f3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f41:	83 c2 08             	add    $0x8,%edx
80105f44:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105f4b:	00 
    fileclose(rf);
80105f4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f4f:	83 ec 0c             	sub    $0xc,%esp
80105f52:	50                   	push   %eax
80105f53:	e8 ce b1 ff ff       	call   80101126 <fileclose>
80105f58:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105f5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f5e:	83 ec 0c             	sub    $0xc,%esp
80105f61:	50                   	push   %eax
80105f62:	e8 bf b1 ff ff       	call   80101126 <fileclose>
80105f67:	83 c4 10             	add    $0x10,%esp
    return -1;
80105f6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f6f:	eb 18                	jmp    80105f89 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80105f71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f74:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f77:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105f79:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f7c:	8d 50 04             	lea    0x4(%eax),%edx
80105f7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f82:	89 02                	mov    %eax,(%edx)
  return 0;
80105f84:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f89:	c9                   	leave
80105f8a:	c3                   	ret

80105f8b <sys_printpt>:
#include "mmu.h"
#include "proc.h"

int
sys_printpt(void)
{
80105f8b:	f3 0f 1e fb          	endbr32
80105f8f:	55                   	push   %ebp
80105f90:	89 e5                	mov    %esp,%ebp
80105f92:	83 ec 18             	sub    $0x18,%esp
  int pid;
  if (argint(0, &pid) < 0)
80105f95:	83 ec 08             	sub    $0x8,%esp
80105f98:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f9b:	50                   	push   %eax
80105f9c:	6a 00                	push   $0x0
80105f9e:	e8 e4 f0 ff ff       	call   80105087 <argint>
80105fa3:	83 c4 10             	add    $0x10,%esp
80105fa6:	85 c0                	test   %eax,%eax
80105fa8:	79 07                	jns    80105fb1 <sys_printpt+0x26>
        return -1;
80105faa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105faf:	eb 0f                	jmp    80105fc0 <sys_printpt+0x35>
  return printpt(pid);
80105fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb4:	83 ec 0c             	sub    $0xc,%esp
80105fb7:	50                   	push   %eax
80105fb8:	e8 3d e8 ff ff       	call   801047fa <printpt>
80105fbd:	83 c4 10             	add    $0x10,%esp
}
80105fc0:	c9                   	leave
80105fc1:	c3                   	ret

80105fc2 <sys_fork>:

int
sys_fork(void)
{
80105fc2:	f3 0f 1e fb          	endbr32
80105fc6:	55                   	push   %ebp
80105fc7:	89 e5                	mov    %esp,%ebp
80105fc9:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105fcc:	e8 6b df ff ff       	call   80103f3c <fork>
}
80105fd1:	c9                   	leave
80105fd2:	c3                   	ret

80105fd3 <sys_exit>:

int
sys_exit(void)
{
80105fd3:	f3 0f 1e fb          	endbr32
80105fd7:	55                   	push   %ebp
80105fd8:	89 e5                	mov    %esp,%ebp
80105fda:	83 ec 08             	sub    $0x8,%esp
  exit();
80105fdd:	e8 fd e0 ff ff       	call   801040df <exit>
  return 0;  // not reached
80105fe2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fe7:	c9                   	leave
80105fe8:	c3                   	ret

80105fe9 <sys_wait>:

int
sys_wait(void)
{
80105fe9:	f3 0f 1e fb          	endbr32
80105fed:	55                   	push   %ebp
80105fee:	89 e5                	mov    %esp,%ebp
80105ff0:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105ff3:	e8 0b e2 ff ff       	call   80104203 <wait>
}
80105ff8:	c9                   	leave
80105ff9:	c3                   	ret

80105ffa <sys_uthread_init>:
int
sys_uthread_init(void)
{
80105ffa:	f3 0f 1e fb          	endbr32
80105ffe:	55                   	push   %ebp
80105fff:	89 e5                	mov    %esp,%ebp
80106001:	83 ec 18             	sub    $0x18,%esp
    // 시스템콜의 인자값을 받아온다.
    int address;
    if (argint(0, &address) < 0)
80106004:	83 ec 08             	sub    $0x8,%esp
80106007:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010600a:	50                   	push   %eax
8010600b:	6a 00                	push   $0x0
8010600d:	e8 75 f0 ff ff       	call   80105087 <argint>
80106012:	83 c4 10             	add    $0x10,%esp
80106015:	85 c0                	test   %eax,%eax
80106017:	79 07                	jns    80106020 <sys_uthread_init+0x26>
        return -1;
80106019:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010601e:	eb 0f                	jmp    8010602f <sys_uthread_init+0x35>
    // proc.c의 uthread_init() 함수 호출
    return uthread_init(address);
80106020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106023:	83 ec 0c             	sub    $0xc,%esp
80106026:	50                   	push   %eax
80106027:	e8 b7 e3 ff ff       	call   801043e3 <uthread_init>
8010602c:	83 c4 10             	add    $0x10,%esp
}
8010602f:	c9                   	leave
80106030:	c3                   	ret

80106031 <sys_kill>:

int
sys_kill(void)
{
80106031:	f3 0f 1e fb          	endbr32
80106035:	55                   	push   %ebp
80106036:	89 e5                	mov    %esp,%ebp
80106038:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010603b:	83 ec 08             	sub    $0x8,%esp
8010603e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106041:	50                   	push   %eax
80106042:	6a 00                	push   $0x0
80106044:	e8 3e f0 ff ff       	call   80105087 <argint>
80106049:	83 c4 10             	add    $0x10,%esp
8010604c:	85 c0                	test   %eax,%eax
8010604e:	79 07                	jns    80106057 <sys_kill+0x26>
    return -1;
80106050:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106055:	eb 0f                	jmp    80106066 <sys_kill+0x35>
  return kill(pid);
80106057:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010605a:	83 ec 0c             	sub    $0xc,%esp
8010605d:	50                   	push   %eax
8010605e:	e8 11 e6 ff ff       	call   80104674 <kill>
80106063:	83 c4 10             	add    $0x10,%esp
}
80106066:	c9                   	leave
80106067:	c3                   	ret

80106068 <sys_getpid>:

int
sys_getpid(void)
{
80106068:	f3 0f 1e fb          	endbr32
8010606c:	55                   	push   %ebp
8010606d:	89 e5                	mov    %esp,%ebp
8010606f:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106072:	e8 6f db ff ff       	call   80103be6 <myproc>
80106077:	8b 40 10             	mov    0x10(%eax),%eax
}
8010607a:	c9                   	leave
8010607b:	c3                   	ret

8010607c <sys_sbrk>:

int
sys_sbrk(void)
{
8010607c:	f3 0f 1e fb          	endbr32
80106080:	55                   	push   %ebp
80106081:	89 e5                	mov    %esp,%ebp
80106083:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106086:	83 ec 08             	sub    $0x8,%esp
80106089:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010608c:	50                   	push   %eax
8010608d:	6a 00                	push   $0x0
8010608f:	e8 f3 ef ff ff       	call   80105087 <argint>
80106094:	83 c4 10             	add    $0x10,%esp
80106097:	85 c0                	test   %eax,%eax
80106099:	79 07                	jns    801060a2 <sys_sbrk+0x26>
    return -1;
8010609b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a0:	eb 27                	jmp    801060c9 <sys_sbrk+0x4d>
  addr = myproc()->sz;
801060a2:	e8 3f db ff ff       	call   80103be6 <myproc>
801060a7:	8b 00                	mov    (%eax),%eax
801060a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801060ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060af:	83 ec 0c             	sub    $0xc,%esp
801060b2:	50                   	push   %eax
801060b3:	e8 c2 dd ff ff       	call   80103e7a <growproc>
801060b8:	83 c4 10             	add    $0x10,%esp
801060bb:	85 c0                	test   %eax,%eax
801060bd:	79 07                	jns    801060c6 <sys_sbrk+0x4a>
    return -1;
801060bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c4:	eb 03                	jmp    801060c9 <sys_sbrk+0x4d>
  return addr;
801060c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801060c9:	c9                   	leave
801060ca:	c3                   	ret

801060cb <sys_sleep>:

int
sys_sleep(void)
{
801060cb:	f3 0f 1e fb          	endbr32
801060cf:	55                   	push   %ebp
801060d0:	89 e5                	mov    %esp,%ebp
801060d2:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801060d5:	83 ec 08             	sub    $0x8,%esp
801060d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060db:	50                   	push   %eax
801060dc:	6a 00                	push   $0x0
801060de:	e8 a4 ef ff ff       	call   80105087 <argint>
801060e3:	83 c4 10             	add    $0x10,%esp
801060e6:	85 c0                	test   %eax,%eax
801060e8:	79 07                	jns    801060f1 <sys_sleep+0x26>
    return -1;
801060ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ef:	eb 76                	jmp    80106167 <sys_sleep+0x9c>
  acquire(&tickslock);
801060f1:	83 ec 0c             	sub    $0xc,%esp
801060f4:	68 40 75 19 80       	push   $0x80197540
801060f9:	e8 c5 e9 ff ff       	call   80104ac3 <acquire>
801060fe:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106101:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106106:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106109:	eb 38                	jmp    80106143 <sys_sleep+0x78>
    if(myproc()->killed){
8010610b:	e8 d6 da ff ff       	call   80103be6 <myproc>
80106110:	8b 40 24             	mov    0x24(%eax),%eax
80106113:	85 c0                	test   %eax,%eax
80106115:	74 17                	je     8010612e <sys_sleep+0x63>
      release(&tickslock);
80106117:	83 ec 0c             	sub    $0xc,%esp
8010611a:	68 40 75 19 80       	push   $0x80197540
8010611f:	e8 11 ea ff ff       	call   80104b35 <release>
80106124:	83 c4 10             	add    $0x10,%esp
      return -1;
80106127:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010612c:	eb 39                	jmp    80106167 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
8010612e:	83 ec 08             	sub    $0x8,%esp
80106131:	68 40 75 19 80       	push   $0x80197540
80106136:	68 80 7d 19 80       	push   $0x80197d80
8010613b:	e8 0a e4 ff ff       	call   8010454a <sleep>
80106140:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106143:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106148:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010614b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010614e:	39 d0                	cmp    %edx,%eax
80106150:	72 b9                	jb     8010610b <sys_sleep+0x40>
  }
  release(&tickslock);
80106152:	83 ec 0c             	sub    $0xc,%esp
80106155:	68 40 75 19 80       	push   $0x80197540
8010615a:	e8 d6 e9 ff ff       	call   80104b35 <release>
8010615f:	83 c4 10             	add    $0x10,%esp
  return 0;
80106162:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106167:	c9                   	leave
80106168:	c3                   	ret

80106169 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106169:	f3 0f 1e fb          	endbr32
8010616d:	55                   	push   %ebp
8010616e:	89 e5                	mov    %esp,%ebp
80106170:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106173:	83 ec 0c             	sub    $0xc,%esp
80106176:	68 40 75 19 80       	push   $0x80197540
8010617b:	e8 43 e9 ff ff       	call   80104ac3 <acquire>
80106180:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106183:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106188:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010618b:	83 ec 0c             	sub    $0xc,%esp
8010618e:	68 40 75 19 80       	push   $0x80197540
80106193:	e8 9d e9 ff ff       	call   80104b35 <release>
80106198:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010619b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010619e:	c9                   	leave
8010619f:	c3                   	ret

801061a0 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801061a0:	1e                   	push   %ds
  pushl %es
801061a1:	06                   	push   %es
  pushl %fs
801061a2:	0f a0                	push   %fs
  pushl %gs
801061a4:	0f a8                	push   %gs
  pushal
801061a6:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801061a7:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801061ab:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801061ad:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801061af:	54                   	push   %esp
  call trap
801061b0:	e8 df 01 00 00       	call   80106394 <trap>
  addl $4, %esp
801061b5:	83 c4 04             	add    $0x4,%esp

801061b8 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801061b8:	61                   	popa
  popl %gs
801061b9:	0f a9                	pop    %gs
  popl %fs
801061bb:	0f a1                	pop    %fs
  popl %es
801061bd:	07                   	pop    %es
  popl %ds
801061be:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801061bf:	83 c4 08             	add    $0x8,%esp
  iret
801061c2:	cf                   	iret

801061c3 <lidt>:
{
801061c3:	55                   	push   %ebp
801061c4:	89 e5                	mov    %esp,%ebp
801061c6:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801061c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801061cc:	83 e8 01             	sub    $0x1,%eax
801061cf:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801061d3:	8b 45 08             	mov    0x8(%ebp),%eax
801061d6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801061da:	8b 45 08             	mov    0x8(%ebp),%eax
801061dd:	c1 e8 10             	shr    $0x10,%eax
801061e0:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801061e4:	8d 45 fa             	lea    -0x6(%ebp),%eax
801061e7:	0f 01 18             	lidtl  (%eax)
}
801061ea:	90                   	nop
801061eb:	c9                   	leave
801061ec:	c3                   	ret

801061ed <rcr2>:

static inline uint
rcr2(void)
{
801061ed:	55                   	push   %ebp
801061ee:	89 e5                	mov    %esp,%ebp
801061f0:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801061f3:	0f 20 d0             	mov    %cr2,%eax
801061f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801061f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801061fc:	c9                   	leave
801061fd:	c3                   	ret

801061fe <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801061fe:	f3 0f 1e fb          	endbr32
80106202:	55                   	push   %ebp
80106203:	89 e5                	mov    %esp,%ebp
80106205:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106208:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010620f:	e9 c3 00 00 00       	jmp    801062d7 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106217:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
8010621e:	89 c2                	mov    %eax,%edx
80106220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106223:	66 89 14 c5 80 75 19 	mov    %dx,-0x7fe68a80(,%eax,8)
8010622a:	80 
8010622b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622e:	66 c7 04 c5 82 75 19 	movw   $0x8,-0x7fe68a7e(,%eax,8)
80106235:	80 08 00 
80106238:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010623b:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
80106242:	80 
80106243:	83 e2 e0             	and    $0xffffffe0,%edx
80106246:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
8010624d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106250:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
80106257:	80 
80106258:	83 e2 1f             	and    $0x1f,%edx
8010625b:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
80106262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106265:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
8010626c:	80 
8010626d:	83 e2 f0             	and    $0xfffffff0,%edx
80106270:	83 ca 0e             	or     $0xe,%edx
80106273:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
8010627a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627d:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
80106284:	80 
80106285:	83 e2 ef             	and    $0xffffffef,%edx
80106288:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
8010628f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106292:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
80106299:	80 
8010629a:	83 e2 9f             	and    $0xffffff9f,%edx
8010629d:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801062a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a7:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
801062ae:	80 
801062af:	83 ca 80             	or     $0xffffff80,%edx
801062b2:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
801062b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062bc:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801062c3:	c1 e8 10             	shr    $0x10,%eax
801062c6:	89 c2                	mov    %eax,%edx
801062c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062cb:	66 89 14 c5 86 75 19 	mov    %dx,-0x7fe68a7a(,%eax,8)
801062d2:	80 
  for(i = 0; i < 256; i++)
801062d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801062d7:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801062de:	0f 8e 30 ff ff ff    	jle    80106214 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801062e4:	a1 80 f1 10 80       	mov    0x8010f180,%eax
801062e9:	66 a3 80 77 19 80    	mov    %ax,0x80197780
801062ef:	66 c7 05 82 77 19 80 	movw   $0x8,0x80197782
801062f6:	08 00 
801062f8:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
801062ff:	83 e0 e0             	and    $0xffffffe0,%eax
80106302:	a2 84 77 19 80       	mov    %al,0x80197784
80106307:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
8010630e:	83 e0 1f             	and    $0x1f,%eax
80106311:	a2 84 77 19 80       	mov    %al,0x80197784
80106316:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
8010631d:	83 c8 0f             	or     $0xf,%eax
80106320:	a2 85 77 19 80       	mov    %al,0x80197785
80106325:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
8010632c:	83 e0 ef             	and    $0xffffffef,%eax
8010632f:	a2 85 77 19 80       	mov    %al,0x80197785
80106334:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
8010633b:	83 c8 60             	or     $0x60,%eax
8010633e:	a2 85 77 19 80       	mov    %al,0x80197785
80106343:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
8010634a:	83 c8 80             	or     $0xffffff80,%eax
8010634d:	a2 85 77 19 80       	mov    %al,0x80197785
80106352:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106357:	c1 e8 10             	shr    $0x10,%eax
8010635a:	66 a3 86 77 19 80    	mov    %ax,0x80197786

  initlock(&tickslock, "time");
80106360:	83 ec 08             	sub    $0x8,%esp
80106363:	68 a0 ab 10 80       	push   $0x8010aba0
80106368:	68 40 75 19 80       	push   $0x80197540
8010636d:	e8 2b e7 ff ff       	call   80104a9d <initlock>
80106372:	83 c4 10             	add    $0x10,%esp
}
80106375:	90                   	nop
80106376:	c9                   	leave
80106377:	c3                   	ret

80106378 <idtinit>:

void
idtinit(void)
{
80106378:	f3 0f 1e fb          	endbr32
8010637c:	55                   	push   %ebp
8010637d:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010637f:	68 00 08 00 00       	push   $0x800
80106384:	68 80 75 19 80       	push   $0x80197580
80106389:	e8 35 fe ff ff       	call   801061c3 <lidt>
8010638e:	83 c4 08             	add    $0x8,%esp
}
80106391:	90                   	nop
80106392:	c9                   	leave
80106393:	c3                   	ret

80106394 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106394:	f3 0f 1e fb          	endbr32
80106398:	55                   	push   %ebp
80106399:	89 e5                	mov    %esp,%ebp
8010639b:	57                   	push   %edi
8010639c:	56                   	push   %esi
8010639d:	53                   	push   %ebx
8010639e:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
801063a1:	8b 45 08             	mov    0x8(%ebp),%eax
801063a4:	8b 40 30             	mov    0x30(%eax),%eax
801063a7:	83 f8 40             	cmp    $0x40,%eax
801063aa:	75 3b                	jne    801063e7 <trap+0x53>
    if(myproc()->killed)
801063ac:	e8 35 d8 ff ff       	call   80103be6 <myproc>
801063b1:	8b 40 24             	mov    0x24(%eax),%eax
801063b4:	85 c0                	test   %eax,%eax
801063b6:	74 05                	je     801063bd <trap+0x29>
      exit();
801063b8:	e8 22 dd ff ff       	call   801040df <exit>
    myproc()->tf = tf;
801063bd:	e8 24 d8 ff ff       	call   80103be6 <myproc>
801063c2:	8b 55 08             	mov    0x8(%ebp),%edx
801063c5:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801063c8:	e8 83 ed ff ff       	call   80105150 <syscall>
    if(myproc()->killed)
801063cd:	e8 14 d8 ff ff       	call   80103be6 <myproc>
801063d2:	8b 40 24             	mov    0x24(%eax),%eax
801063d5:	85 c0                	test   %eax,%eax
801063d7:	0f 84 af 02 00 00    	je     8010668c <trap+0x2f8>
      exit();
801063dd:	e8 fd dc ff ff       	call   801040df <exit>
    return;
801063e2:	e9 a5 02 00 00       	jmp    8010668c <trap+0x2f8>
  }

  switch(tf->trapno){
801063e7:	8b 45 08             	mov    0x8(%ebp),%eax
801063ea:	8b 40 30             	mov    0x30(%eax),%eax
801063ed:	83 e8 0e             	sub    $0xe,%eax
801063f0:	83 f8 31             	cmp    $0x31,%eax
801063f3:	0f 87 5e 01 00 00    	ja     80106557 <trap+0x1c3>
801063f9:	8b 04 85 70 ac 10 80 	mov    -0x7fef5390(,%eax,4),%eax
80106400:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106403:	e8 43 d7 ff ff       	call   80103b4b <cpuid>
80106408:	85 c0                	test   %eax,%eax
8010640a:	75 3d                	jne    80106449 <trap+0xb5>
      acquire(&tickslock);
8010640c:	83 ec 0c             	sub    $0xc,%esp
8010640f:	68 40 75 19 80       	push   $0x80197540
80106414:	e8 aa e6 ff ff       	call   80104ac3 <acquire>
80106419:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010641c:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106421:	83 c0 01             	add    $0x1,%eax
80106424:	a3 80 7d 19 80       	mov    %eax,0x80197d80
      wakeup(&ticks);
80106429:	83 ec 0c             	sub    $0xc,%esp
8010642c:	68 80 7d 19 80       	push   $0x80197d80
80106431:	e8 03 e2 ff ff       	call   80104639 <wakeup>
80106436:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106439:	83 ec 0c             	sub    $0xc,%esp
8010643c:	68 40 75 19 80       	push   $0x80197540
80106441:	e8 ef e6 ff ff       	call   80104b35 <release>
80106446:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106449:	e8 14 c8 ff ff       	call   80102c62 <lapiceoi>


    break;
8010644e:	e9 b9 01 00 00       	jmp    8010660c <trap+0x278>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106453:	e8 f0 40 00 00       	call   8010a548 <ideintr>
    lapiceoi();
80106458:	e8 05 c8 ff ff       	call   80102c62 <lapiceoi>
    break;
8010645d:	e9 aa 01 00 00       	jmp    8010660c <trap+0x278>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106462:	e8 31 c6 ff ff       	call   80102a98 <kbdintr>
    lapiceoi();
80106467:	e8 f6 c7 ff ff       	call   80102c62 <lapiceoi>
    break;
8010646c:	e9 9b 01 00 00       	jmp    8010660c <trap+0x278>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106471:	e8 f8 03 00 00       	call   8010686e <uartintr>
    lapiceoi();
80106476:	e8 e7 c7 ff ff       	call   80102c62 <lapiceoi>
    break;
8010647b:	e9 8c 01 00 00       	jmp    8010660c <trap+0x278>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106480:	e8 02 2d 00 00       	call   80109187 <i8254_intr>
    lapiceoi();
80106485:	e8 d8 c7 ff ff       	call   80102c62 <lapiceoi>
    break;
8010648a:	e9 7d 01 00 00       	jmp    8010660c <trap+0x278>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010648f:	8b 45 08             	mov    0x8(%ebp),%eax
80106492:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106495:	8b 45 08             	mov    0x8(%ebp),%eax
80106498:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010649c:	0f b7 d8             	movzwl %ax,%ebx
8010649f:	e8 a7 d6 ff ff       	call   80103b4b <cpuid>
801064a4:	56                   	push   %esi
801064a5:	53                   	push   %ebx
801064a6:	50                   	push   %eax
801064a7:	68 a8 ab 10 80       	push   $0x8010aba8
801064ac:	e8 5b 9f ff ff       	call   8010040c <cprintf>
801064b1:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801064b4:	e8 a9 c7 ff ff       	call   80102c62 <lapiceoi>
    break;
801064b9:	e9 4e 01 00 00       	jmp    8010660c <trap+0x278>
  case T_PGFLT:
    cprintf("[PAGE FAULT IN]\n");
801064be:	83 ec 0c             	sub    $0xc,%esp
801064c1:	68 cc ab 10 80       	push   $0x8010abcc
801064c6:	e8 41 9f ff ff       	call   8010040c <cprintf>
801064cb:	83 c4 10             	add    $0x10,%esp
    pde_t* pgdir;
    uint va;
    struct proc* p;
    char *mem;
    // va = 페이지 폴트가 난 가상 주소의 페이지 시작 주소
    va = PGROUNDDOWN(rcr2());
801064ce:	e8 1a fd ff ff       	call   801061ed <rcr2>
801064d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801064d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    cprintf("[PAGE FAULT] va %x \n",va);
801064db:	83 ec 08             	sub    $0x8,%esp
801064de:	ff 75 e4             	push   -0x1c(%ebp)
801064e1:	68 dd ab 10 80       	push   $0x8010abdd
801064e6:	e8 21 9f ff ff       	call   8010040c <cprintf>
801064eb:	83 c4 10             	add    $0x10,%esp

    p = myproc();
801064ee:	e8 f3 d6 ff ff       	call   80103be6 <myproc>
801064f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    pgdir = p->pgdir;
801064f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801064f9:	8b 40 04             	mov    0x4(%eax),%eax
801064fc:	89 45 dc             	mov    %eax,-0x24(%ebp)
    mem = kalloc();
801064ff:	e8 cb c3 ff ff       	call   801028cf <kalloc>
80106504:	89 45 d8             	mov    %eax,-0x28(%ebp)
    memset(mem, 0, PGSIZE);
80106507:	83 ec 04             	sub    $0x4,%esp
8010650a:	68 00 10 00 00       	push   $0x1000
8010650f:	6a 00                	push   $0x0
80106511:	ff 75 d8             	push   -0x28(%ebp)
80106514:	e8 39 e8 ff ff       	call   80104d52 <memset>
80106519:	83 c4 10             	add    $0x10,%esp

    // va 페이지 테이블에 매핑
    // 페이지 테이블 관련 처리는 mappages 안에서 자동으로 처리해줌
    mappages(pgdir, (void*)(va - PGSIZE), PGSIZE, V2P(mem), PTE_W|PTE_U|PTE_P);
8010651c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010651f:	05 00 00 00 80       	add    $0x80000000,%eax
80106524:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106527:	81 ea 00 10 00 00    	sub    $0x1000,%edx
8010652d:	83 ec 0c             	sub    $0xc,%esp
80106530:	6a 07                	push   $0x7
80106532:	50                   	push   %eax
80106533:	68 00 10 00 00       	push   $0x1000
80106538:	52                   	push   %edx
80106539:	ff 75 dc             	push   -0x24(%ebp)
8010653c:	e8 fd 11 00 00       	call   8010773e <mappages>
80106541:	83 c4 20             	add    $0x20,%esp

    // flush
    switchuvm(p);
80106544:	83 ec 0c             	sub    $0xc,%esp
80106547:	ff 75 e0             	push   -0x20(%ebp)
8010654a:	e8 ad 13 00 00       	call   801078fc <switchuvm>
8010654f:	83 c4 10             	add    $0x10,%esp
    break;
80106552:	e9 b5 00 00 00       	jmp    8010660c <trap+0x278>


  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106557:	e8 8a d6 ff ff       	call   80103be6 <myproc>
8010655c:	85 c0                	test   %eax,%eax
8010655e:	74 11                	je     80106571 <trap+0x1dd>
80106560:	8b 45 08             	mov    0x8(%ebp),%eax
80106563:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106567:	0f b7 c0             	movzwl %ax,%eax
8010656a:	83 e0 03             	and    $0x3,%eax
8010656d:	85 c0                	test   %eax,%eax
8010656f:	75 39                	jne    801065aa <trap+0x216>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106571:	e8 77 fc ff ff       	call   801061ed <rcr2>
80106576:	89 c3                	mov    %eax,%ebx
80106578:	8b 45 08             	mov    0x8(%ebp),%eax
8010657b:	8b 70 38             	mov    0x38(%eax),%esi
8010657e:	e8 c8 d5 ff ff       	call   80103b4b <cpuid>
80106583:	8b 55 08             	mov    0x8(%ebp),%edx
80106586:	8b 52 30             	mov    0x30(%edx),%edx
80106589:	83 ec 0c             	sub    $0xc,%esp
8010658c:	53                   	push   %ebx
8010658d:	56                   	push   %esi
8010658e:	50                   	push   %eax
8010658f:	52                   	push   %edx
80106590:	68 f4 ab 10 80       	push   $0x8010abf4
80106595:	e8 72 9e ff ff       	call   8010040c <cprintf>
8010659a:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010659d:	83 ec 0c             	sub    $0xc,%esp
801065a0:	68 26 ac 10 80       	push   $0x8010ac26
801065a5:	e8 1b a0 ff ff       	call   801005c5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065aa:	e8 3e fc ff ff       	call   801061ed <rcr2>
801065af:	89 c6                	mov    %eax,%esi
801065b1:	8b 45 08             	mov    0x8(%ebp),%eax
801065b4:	8b 40 38             	mov    0x38(%eax),%eax
801065b7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801065ba:	e8 8c d5 ff ff       	call   80103b4b <cpuid>
801065bf:	89 c3                	mov    %eax,%ebx
801065c1:	8b 45 08             	mov    0x8(%ebp),%eax
801065c4:	8b 48 34             	mov    0x34(%eax),%ecx
801065c7:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801065ca:	8b 45 08             	mov    0x8(%ebp),%eax
801065cd:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801065d0:	e8 11 d6 ff ff       	call   80103be6 <myproc>
801065d5:	8d 50 6c             	lea    0x6c(%eax),%edx
801065d8:	89 55 cc             	mov    %edx,-0x34(%ebp)
801065db:	e8 06 d6 ff ff       	call   80103be6 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065e0:	8b 40 10             	mov    0x10(%eax),%eax
801065e3:	56                   	push   %esi
801065e4:	ff 75 d4             	push   -0x2c(%ebp)
801065e7:	53                   	push   %ebx
801065e8:	ff 75 d0             	push   -0x30(%ebp)
801065eb:	57                   	push   %edi
801065ec:	ff 75 cc             	push   -0x34(%ebp)
801065ef:	50                   	push   %eax
801065f0:	68 2c ac 10 80       	push   $0x8010ac2c
801065f5:	e8 12 9e ff ff       	call   8010040c <cprintf>
801065fa:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801065fd:	e8 e4 d5 ff ff       	call   80103be6 <myproc>
80106602:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106609:	eb 01                	jmp    8010660c <trap+0x278>
    break;
8010660b:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010660c:	e8 d5 d5 ff ff       	call   80103be6 <myproc>
80106611:	85 c0                	test   %eax,%eax
80106613:	74 23                	je     80106638 <trap+0x2a4>
80106615:	e8 cc d5 ff ff       	call   80103be6 <myproc>
8010661a:	8b 40 24             	mov    0x24(%eax),%eax
8010661d:	85 c0                	test   %eax,%eax
8010661f:	74 17                	je     80106638 <trap+0x2a4>
80106621:	8b 45 08             	mov    0x8(%ebp),%eax
80106624:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106628:	0f b7 c0             	movzwl %ax,%eax
8010662b:	83 e0 03             	and    $0x3,%eax
8010662e:	83 f8 03             	cmp    $0x3,%eax
80106631:	75 05                	jne    80106638 <trap+0x2a4>
    exit();
80106633:	e8 a7 da ff ff       	call   801040df <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106638:	e8 a9 d5 ff ff       	call   80103be6 <myproc>
8010663d:	85 c0                	test   %eax,%eax
8010663f:	74 1d                	je     8010665e <trap+0x2ca>
80106641:	e8 a0 d5 ff ff       	call   80103be6 <myproc>
80106646:	8b 40 0c             	mov    0xc(%eax),%eax
80106649:	83 f8 04             	cmp    $0x4,%eax
8010664c:	75 10                	jne    8010665e <trap+0x2ca>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010664e:	8b 45 08             	mov    0x8(%ebp),%eax
80106651:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106654:	83 f8 20             	cmp    $0x20,%eax
80106657:	75 05                	jne    8010665e <trap+0x2ca>
    yield();
80106659:	e8 64 de ff ff       	call   801044c2 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010665e:	e8 83 d5 ff ff       	call   80103be6 <myproc>
80106663:	85 c0                	test   %eax,%eax
80106665:	74 26                	je     8010668d <trap+0x2f9>
80106667:	e8 7a d5 ff ff       	call   80103be6 <myproc>
8010666c:	8b 40 24             	mov    0x24(%eax),%eax
8010666f:	85 c0                	test   %eax,%eax
80106671:	74 1a                	je     8010668d <trap+0x2f9>
80106673:	8b 45 08             	mov    0x8(%ebp),%eax
80106676:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010667a:	0f b7 c0             	movzwl %ax,%eax
8010667d:	83 e0 03             	and    $0x3,%eax
80106680:	83 f8 03             	cmp    $0x3,%eax
80106683:	75 08                	jne    8010668d <trap+0x2f9>
    exit();
80106685:	e8 55 da ff ff       	call   801040df <exit>
8010668a:	eb 01                	jmp    8010668d <trap+0x2f9>
    return;
8010668c:	90                   	nop
}
8010668d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106690:	5b                   	pop    %ebx
80106691:	5e                   	pop    %esi
80106692:	5f                   	pop    %edi
80106693:	5d                   	pop    %ebp
80106694:	c3                   	ret

80106695 <inb>:
{
80106695:	55                   	push   %ebp
80106696:	89 e5                	mov    %esp,%ebp
80106698:	83 ec 14             	sub    $0x14,%esp
8010669b:	8b 45 08             	mov    0x8(%ebp),%eax
8010669e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801066a2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801066a6:	89 c2                	mov    %eax,%edx
801066a8:	ec                   	in     (%dx),%al
801066a9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801066ac:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801066b0:	c9                   	leave
801066b1:	c3                   	ret

801066b2 <outb>:
{
801066b2:	55                   	push   %ebp
801066b3:	89 e5                	mov    %esp,%ebp
801066b5:	83 ec 08             	sub    $0x8,%esp
801066b8:	8b 45 08             	mov    0x8(%ebp),%eax
801066bb:	8b 55 0c             	mov    0xc(%ebp),%edx
801066be:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801066c2:	89 d0                	mov    %edx,%eax
801066c4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801066c7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801066cb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801066cf:	ee                   	out    %al,(%dx)
}
801066d0:	90                   	nop
801066d1:	c9                   	leave
801066d2:	c3                   	ret

801066d3 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801066d3:	f3 0f 1e fb          	endbr32
801066d7:	55                   	push   %ebp
801066d8:	89 e5                	mov    %esp,%ebp
801066da:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801066dd:	6a 00                	push   $0x0
801066df:	68 fa 03 00 00       	push   $0x3fa
801066e4:	e8 c9 ff ff ff       	call   801066b2 <outb>
801066e9:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801066ec:	68 80 00 00 00       	push   $0x80
801066f1:	68 fb 03 00 00       	push   $0x3fb
801066f6:	e8 b7 ff ff ff       	call   801066b2 <outb>
801066fb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801066fe:	6a 0c                	push   $0xc
80106700:	68 f8 03 00 00       	push   $0x3f8
80106705:	e8 a8 ff ff ff       	call   801066b2 <outb>
8010670a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010670d:	6a 00                	push   $0x0
8010670f:	68 f9 03 00 00       	push   $0x3f9
80106714:	e8 99 ff ff ff       	call   801066b2 <outb>
80106719:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010671c:	6a 03                	push   $0x3
8010671e:	68 fb 03 00 00       	push   $0x3fb
80106723:	e8 8a ff ff ff       	call   801066b2 <outb>
80106728:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010672b:	6a 00                	push   $0x0
8010672d:	68 fc 03 00 00       	push   $0x3fc
80106732:	e8 7b ff ff ff       	call   801066b2 <outb>
80106737:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010673a:	6a 01                	push   $0x1
8010673c:	68 f9 03 00 00       	push   $0x3f9
80106741:	e8 6c ff ff ff       	call   801066b2 <outb>
80106746:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106749:	68 fd 03 00 00       	push   $0x3fd
8010674e:	e8 42 ff ff ff       	call   80106695 <inb>
80106753:	83 c4 04             	add    $0x4,%esp
80106756:	3c ff                	cmp    $0xff,%al
80106758:	74 61                	je     801067bb <uartinit+0xe8>
    return;
  uart = 1;
8010675a:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
80106761:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106764:	68 fa 03 00 00       	push   $0x3fa
80106769:	e8 27 ff ff ff       	call   80106695 <inb>
8010676e:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106771:	68 f8 03 00 00       	push   $0x3f8
80106776:	e8 1a ff ff ff       	call   80106695 <inb>
8010677b:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010677e:	83 ec 08             	sub    $0x8,%esp
80106781:	6a 00                	push   $0x0
80106783:	6a 04                	push   $0x4
80106785:	e8 bf bf ff ff       	call   80102749 <ioapicenable>
8010678a:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010678d:	c7 45 f4 38 ad 10 80 	movl   $0x8010ad38,-0xc(%ebp)
80106794:	eb 19                	jmp    801067af <uartinit+0xdc>
    uartputc(*p);
80106796:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106799:	0f b6 00             	movzbl (%eax),%eax
8010679c:	0f be c0             	movsbl %al,%eax
8010679f:	83 ec 0c             	sub    $0xc,%esp
801067a2:	50                   	push   %eax
801067a3:	e8 16 00 00 00       	call   801067be <uartputc>
801067a8:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801067ab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b2:	0f b6 00             	movzbl (%eax),%eax
801067b5:	84 c0                	test   %al,%al
801067b7:	75 dd                	jne    80106796 <uartinit+0xc3>
801067b9:	eb 01                	jmp    801067bc <uartinit+0xe9>
    return;
801067bb:	90                   	nop
}
801067bc:	c9                   	leave
801067bd:	c3                   	ret

801067be <uartputc>:

void
uartputc(int c)
{
801067be:	f3 0f 1e fb          	endbr32
801067c2:	55                   	push   %ebp
801067c3:	89 e5                	mov    %esp,%ebp
801067c5:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801067c8:	a1 60 d0 18 80       	mov    0x8018d060,%eax
801067cd:	85 c0                	test   %eax,%eax
801067cf:	74 53                	je     80106824 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067d8:	eb 11                	jmp    801067eb <uartputc+0x2d>
    microdelay(10);
801067da:	83 ec 0c             	sub    $0xc,%esp
801067dd:	6a 0a                	push   $0xa
801067df:	e8 9d c4 ff ff       	call   80102c81 <microdelay>
801067e4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067eb:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801067ef:	7f 1a                	jg     8010680b <uartputc+0x4d>
801067f1:	83 ec 0c             	sub    $0xc,%esp
801067f4:	68 fd 03 00 00       	push   $0x3fd
801067f9:	e8 97 fe ff ff       	call   80106695 <inb>
801067fe:	83 c4 10             	add    $0x10,%esp
80106801:	0f b6 c0             	movzbl %al,%eax
80106804:	83 e0 20             	and    $0x20,%eax
80106807:	85 c0                	test   %eax,%eax
80106809:	74 cf                	je     801067da <uartputc+0x1c>
  outb(COM1+0, c);
8010680b:	8b 45 08             	mov    0x8(%ebp),%eax
8010680e:	0f b6 c0             	movzbl %al,%eax
80106811:	83 ec 08             	sub    $0x8,%esp
80106814:	50                   	push   %eax
80106815:	68 f8 03 00 00       	push   $0x3f8
8010681a:	e8 93 fe ff ff       	call   801066b2 <outb>
8010681f:	83 c4 10             	add    $0x10,%esp
80106822:	eb 01                	jmp    80106825 <uartputc+0x67>
    return;
80106824:	90                   	nop
}
80106825:	c9                   	leave
80106826:	c3                   	ret

80106827 <uartgetc>:

static int
uartgetc(void)
{
80106827:	f3 0f 1e fb          	endbr32
8010682b:	55                   	push   %ebp
8010682c:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010682e:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106833:	85 c0                	test   %eax,%eax
80106835:	75 07                	jne    8010683e <uartgetc+0x17>
    return -1;
80106837:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010683c:	eb 2e                	jmp    8010686c <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
8010683e:	68 fd 03 00 00       	push   $0x3fd
80106843:	e8 4d fe ff ff       	call   80106695 <inb>
80106848:	83 c4 04             	add    $0x4,%esp
8010684b:	0f b6 c0             	movzbl %al,%eax
8010684e:	83 e0 01             	and    $0x1,%eax
80106851:	85 c0                	test   %eax,%eax
80106853:	75 07                	jne    8010685c <uartgetc+0x35>
    return -1;
80106855:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010685a:	eb 10                	jmp    8010686c <uartgetc+0x45>
  return inb(COM1+0);
8010685c:	68 f8 03 00 00       	push   $0x3f8
80106861:	e8 2f fe ff ff       	call   80106695 <inb>
80106866:	83 c4 04             	add    $0x4,%esp
80106869:	0f b6 c0             	movzbl %al,%eax
}
8010686c:	c9                   	leave
8010686d:	c3                   	ret

8010686e <uartintr>:

void
uartintr(void)
{
8010686e:	f3 0f 1e fb          	endbr32
80106872:	55                   	push   %ebp
80106873:	89 e5                	mov    %esp,%ebp
80106875:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106878:	83 ec 0c             	sub    $0xc,%esp
8010687b:	68 27 68 10 80       	push   $0x80106827
80106880:	e8 7b 9f ff ff       	call   80100800 <consoleintr>
80106885:	83 c4 10             	add    $0x10,%esp
}
80106888:	90                   	nop
80106889:	c9                   	leave
8010688a:	c3                   	ret

8010688b <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010688b:	6a 00                	push   $0x0
  pushl $0
8010688d:	6a 00                	push   $0x0
  jmp alltraps
8010688f:	e9 0c f9 ff ff       	jmp    801061a0 <alltraps>

80106894 <vector1>:
.globl vector1
vector1:
  pushl $0
80106894:	6a 00                	push   $0x0
  pushl $1
80106896:	6a 01                	push   $0x1
  jmp alltraps
80106898:	e9 03 f9 ff ff       	jmp    801061a0 <alltraps>

8010689d <vector2>:
.globl vector2
vector2:
  pushl $0
8010689d:	6a 00                	push   $0x0
  pushl $2
8010689f:	6a 02                	push   $0x2
  jmp alltraps
801068a1:	e9 fa f8 ff ff       	jmp    801061a0 <alltraps>

801068a6 <vector3>:
.globl vector3
vector3:
  pushl $0
801068a6:	6a 00                	push   $0x0
  pushl $3
801068a8:	6a 03                	push   $0x3
  jmp alltraps
801068aa:	e9 f1 f8 ff ff       	jmp    801061a0 <alltraps>

801068af <vector4>:
.globl vector4
vector4:
  pushl $0
801068af:	6a 00                	push   $0x0
  pushl $4
801068b1:	6a 04                	push   $0x4
  jmp alltraps
801068b3:	e9 e8 f8 ff ff       	jmp    801061a0 <alltraps>

801068b8 <vector5>:
.globl vector5
vector5:
  pushl $0
801068b8:	6a 00                	push   $0x0
  pushl $5
801068ba:	6a 05                	push   $0x5
  jmp alltraps
801068bc:	e9 df f8 ff ff       	jmp    801061a0 <alltraps>

801068c1 <vector6>:
.globl vector6
vector6:
  pushl $0
801068c1:	6a 00                	push   $0x0
  pushl $6
801068c3:	6a 06                	push   $0x6
  jmp alltraps
801068c5:	e9 d6 f8 ff ff       	jmp    801061a0 <alltraps>

801068ca <vector7>:
.globl vector7
vector7:
  pushl $0
801068ca:	6a 00                	push   $0x0
  pushl $7
801068cc:	6a 07                	push   $0x7
  jmp alltraps
801068ce:	e9 cd f8 ff ff       	jmp    801061a0 <alltraps>

801068d3 <vector8>:
.globl vector8
vector8:
  pushl $8
801068d3:	6a 08                	push   $0x8
  jmp alltraps
801068d5:	e9 c6 f8 ff ff       	jmp    801061a0 <alltraps>

801068da <vector9>:
.globl vector9
vector9:
  pushl $0
801068da:	6a 00                	push   $0x0
  pushl $9
801068dc:	6a 09                	push   $0x9
  jmp alltraps
801068de:	e9 bd f8 ff ff       	jmp    801061a0 <alltraps>

801068e3 <vector10>:
.globl vector10
vector10:
  pushl $10
801068e3:	6a 0a                	push   $0xa
  jmp alltraps
801068e5:	e9 b6 f8 ff ff       	jmp    801061a0 <alltraps>

801068ea <vector11>:
.globl vector11
vector11:
  pushl $11
801068ea:	6a 0b                	push   $0xb
  jmp alltraps
801068ec:	e9 af f8 ff ff       	jmp    801061a0 <alltraps>

801068f1 <vector12>:
.globl vector12
vector12:
  pushl $12
801068f1:	6a 0c                	push   $0xc
  jmp alltraps
801068f3:	e9 a8 f8 ff ff       	jmp    801061a0 <alltraps>

801068f8 <vector13>:
.globl vector13
vector13:
  pushl $13
801068f8:	6a 0d                	push   $0xd
  jmp alltraps
801068fa:	e9 a1 f8 ff ff       	jmp    801061a0 <alltraps>

801068ff <vector14>:
.globl vector14
vector14:
  pushl $14
801068ff:	6a 0e                	push   $0xe
  jmp alltraps
80106901:	e9 9a f8 ff ff       	jmp    801061a0 <alltraps>

80106906 <vector15>:
.globl vector15
vector15:
  pushl $0
80106906:	6a 00                	push   $0x0
  pushl $15
80106908:	6a 0f                	push   $0xf
  jmp alltraps
8010690a:	e9 91 f8 ff ff       	jmp    801061a0 <alltraps>

8010690f <vector16>:
.globl vector16
vector16:
  pushl $0
8010690f:	6a 00                	push   $0x0
  pushl $16
80106911:	6a 10                	push   $0x10
  jmp alltraps
80106913:	e9 88 f8 ff ff       	jmp    801061a0 <alltraps>

80106918 <vector17>:
.globl vector17
vector17:
  pushl $17
80106918:	6a 11                	push   $0x11
  jmp alltraps
8010691a:	e9 81 f8 ff ff       	jmp    801061a0 <alltraps>

8010691f <vector18>:
.globl vector18
vector18:
  pushl $0
8010691f:	6a 00                	push   $0x0
  pushl $18
80106921:	6a 12                	push   $0x12
  jmp alltraps
80106923:	e9 78 f8 ff ff       	jmp    801061a0 <alltraps>

80106928 <vector19>:
.globl vector19
vector19:
  pushl $0
80106928:	6a 00                	push   $0x0
  pushl $19
8010692a:	6a 13                	push   $0x13
  jmp alltraps
8010692c:	e9 6f f8 ff ff       	jmp    801061a0 <alltraps>

80106931 <vector20>:
.globl vector20
vector20:
  pushl $0
80106931:	6a 00                	push   $0x0
  pushl $20
80106933:	6a 14                	push   $0x14
  jmp alltraps
80106935:	e9 66 f8 ff ff       	jmp    801061a0 <alltraps>

8010693a <vector21>:
.globl vector21
vector21:
  pushl $0
8010693a:	6a 00                	push   $0x0
  pushl $21
8010693c:	6a 15                	push   $0x15
  jmp alltraps
8010693e:	e9 5d f8 ff ff       	jmp    801061a0 <alltraps>

80106943 <vector22>:
.globl vector22
vector22:
  pushl $0
80106943:	6a 00                	push   $0x0
  pushl $22
80106945:	6a 16                	push   $0x16
  jmp alltraps
80106947:	e9 54 f8 ff ff       	jmp    801061a0 <alltraps>

8010694c <vector23>:
.globl vector23
vector23:
  pushl $0
8010694c:	6a 00                	push   $0x0
  pushl $23
8010694e:	6a 17                	push   $0x17
  jmp alltraps
80106950:	e9 4b f8 ff ff       	jmp    801061a0 <alltraps>

80106955 <vector24>:
.globl vector24
vector24:
  pushl $0
80106955:	6a 00                	push   $0x0
  pushl $24
80106957:	6a 18                	push   $0x18
  jmp alltraps
80106959:	e9 42 f8 ff ff       	jmp    801061a0 <alltraps>

8010695e <vector25>:
.globl vector25
vector25:
  pushl $0
8010695e:	6a 00                	push   $0x0
  pushl $25
80106960:	6a 19                	push   $0x19
  jmp alltraps
80106962:	e9 39 f8 ff ff       	jmp    801061a0 <alltraps>

80106967 <vector26>:
.globl vector26
vector26:
  pushl $0
80106967:	6a 00                	push   $0x0
  pushl $26
80106969:	6a 1a                	push   $0x1a
  jmp alltraps
8010696b:	e9 30 f8 ff ff       	jmp    801061a0 <alltraps>

80106970 <vector27>:
.globl vector27
vector27:
  pushl $0
80106970:	6a 00                	push   $0x0
  pushl $27
80106972:	6a 1b                	push   $0x1b
  jmp alltraps
80106974:	e9 27 f8 ff ff       	jmp    801061a0 <alltraps>

80106979 <vector28>:
.globl vector28
vector28:
  pushl $0
80106979:	6a 00                	push   $0x0
  pushl $28
8010697b:	6a 1c                	push   $0x1c
  jmp alltraps
8010697d:	e9 1e f8 ff ff       	jmp    801061a0 <alltraps>

80106982 <vector29>:
.globl vector29
vector29:
  pushl $0
80106982:	6a 00                	push   $0x0
  pushl $29
80106984:	6a 1d                	push   $0x1d
  jmp alltraps
80106986:	e9 15 f8 ff ff       	jmp    801061a0 <alltraps>

8010698b <vector30>:
.globl vector30
vector30:
  pushl $0
8010698b:	6a 00                	push   $0x0
  pushl $30
8010698d:	6a 1e                	push   $0x1e
  jmp alltraps
8010698f:	e9 0c f8 ff ff       	jmp    801061a0 <alltraps>

80106994 <vector31>:
.globl vector31
vector31:
  pushl $0
80106994:	6a 00                	push   $0x0
  pushl $31
80106996:	6a 1f                	push   $0x1f
  jmp alltraps
80106998:	e9 03 f8 ff ff       	jmp    801061a0 <alltraps>

8010699d <vector32>:
.globl vector32
vector32:
  pushl $0
8010699d:	6a 00                	push   $0x0
  pushl $32
8010699f:	6a 20                	push   $0x20
  jmp alltraps
801069a1:	e9 fa f7 ff ff       	jmp    801061a0 <alltraps>

801069a6 <vector33>:
.globl vector33
vector33:
  pushl $0
801069a6:	6a 00                	push   $0x0
  pushl $33
801069a8:	6a 21                	push   $0x21
  jmp alltraps
801069aa:	e9 f1 f7 ff ff       	jmp    801061a0 <alltraps>

801069af <vector34>:
.globl vector34
vector34:
  pushl $0
801069af:	6a 00                	push   $0x0
  pushl $34
801069b1:	6a 22                	push   $0x22
  jmp alltraps
801069b3:	e9 e8 f7 ff ff       	jmp    801061a0 <alltraps>

801069b8 <vector35>:
.globl vector35
vector35:
  pushl $0
801069b8:	6a 00                	push   $0x0
  pushl $35
801069ba:	6a 23                	push   $0x23
  jmp alltraps
801069bc:	e9 df f7 ff ff       	jmp    801061a0 <alltraps>

801069c1 <vector36>:
.globl vector36
vector36:
  pushl $0
801069c1:	6a 00                	push   $0x0
  pushl $36
801069c3:	6a 24                	push   $0x24
  jmp alltraps
801069c5:	e9 d6 f7 ff ff       	jmp    801061a0 <alltraps>

801069ca <vector37>:
.globl vector37
vector37:
  pushl $0
801069ca:	6a 00                	push   $0x0
  pushl $37
801069cc:	6a 25                	push   $0x25
  jmp alltraps
801069ce:	e9 cd f7 ff ff       	jmp    801061a0 <alltraps>

801069d3 <vector38>:
.globl vector38
vector38:
  pushl $0
801069d3:	6a 00                	push   $0x0
  pushl $38
801069d5:	6a 26                	push   $0x26
  jmp alltraps
801069d7:	e9 c4 f7 ff ff       	jmp    801061a0 <alltraps>

801069dc <vector39>:
.globl vector39
vector39:
  pushl $0
801069dc:	6a 00                	push   $0x0
  pushl $39
801069de:	6a 27                	push   $0x27
  jmp alltraps
801069e0:	e9 bb f7 ff ff       	jmp    801061a0 <alltraps>

801069e5 <vector40>:
.globl vector40
vector40:
  pushl $0
801069e5:	6a 00                	push   $0x0
  pushl $40
801069e7:	6a 28                	push   $0x28
  jmp alltraps
801069e9:	e9 b2 f7 ff ff       	jmp    801061a0 <alltraps>

801069ee <vector41>:
.globl vector41
vector41:
  pushl $0
801069ee:	6a 00                	push   $0x0
  pushl $41
801069f0:	6a 29                	push   $0x29
  jmp alltraps
801069f2:	e9 a9 f7 ff ff       	jmp    801061a0 <alltraps>

801069f7 <vector42>:
.globl vector42
vector42:
  pushl $0
801069f7:	6a 00                	push   $0x0
  pushl $42
801069f9:	6a 2a                	push   $0x2a
  jmp alltraps
801069fb:	e9 a0 f7 ff ff       	jmp    801061a0 <alltraps>

80106a00 <vector43>:
.globl vector43
vector43:
  pushl $0
80106a00:	6a 00                	push   $0x0
  pushl $43
80106a02:	6a 2b                	push   $0x2b
  jmp alltraps
80106a04:	e9 97 f7 ff ff       	jmp    801061a0 <alltraps>

80106a09 <vector44>:
.globl vector44
vector44:
  pushl $0
80106a09:	6a 00                	push   $0x0
  pushl $44
80106a0b:	6a 2c                	push   $0x2c
  jmp alltraps
80106a0d:	e9 8e f7 ff ff       	jmp    801061a0 <alltraps>

80106a12 <vector45>:
.globl vector45
vector45:
  pushl $0
80106a12:	6a 00                	push   $0x0
  pushl $45
80106a14:	6a 2d                	push   $0x2d
  jmp alltraps
80106a16:	e9 85 f7 ff ff       	jmp    801061a0 <alltraps>

80106a1b <vector46>:
.globl vector46
vector46:
  pushl $0
80106a1b:	6a 00                	push   $0x0
  pushl $46
80106a1d:	6a 2e                	push   $0x2e
  jmp alltraps
80106a1f:	e9 7c f7 ff ff       	jmp    801061a0 <alltraps>

80106a24 <vector47>:
.globl vector47
vector47:
  pushl $0
80106a24:	6a 00                	push   $0x0
  pushl $47
80106a26:	6a 2f                	push   $0x2f
  jmp alltraps
80106a28:	e9 73 f7 ff ff       	jmp    801061a0 <alltraps>

80106a2d <vector48>:
.globl vector48
vector48:
  pushl $0
80106a2d:	6a 00                	push   $0x0
  pushl $48
80106a2f:	6a 30                	push   $0x30
  jmp alltraps
80106a31:	e9 6a f7 ff ff       	jmp    801061a0 <alltraps>

80106a36 <vector49>:
.globl vector49
vector49:
  pushl $0
80106a36:	6a 00                	push   $0x0
  pushl $49
80106a38:	6a 31                	push   $0x31
  jmp alltraps
80106a3a:	e9 61 f7 ff ff       	jmp    801061a0 <alltraps>

80106a3f <vector50>:
.globl vector50
vector50:
  pushl $0
80106a3f:	6a 00                	push   $0x0
  pushl $50
80106a41:	6a 32                	push   $0x32
  jmp alltraps
80106a43:	e9 58 f7 ff ff       	jmp    801061a0 <alltraps>

80106a48 <vector51>:
.globl vector51
vector51:
  pushl $0
80106a48:	6a 00                	push   $0x0
  pushl $51
80106a4a:	6a 33                	push   $0x33
  jmp alltraps
80106a4c:	e9 4f f7 ff ff       	jmp    801061a0 <alltraps>

80106a51 <vector52>:
.globl vector52
vector52:
  pushl $0
80106a51:	6a 00                	push   $0x0
  pushl $52
80106a53:	6a 34                	push   $0x34
  jmp alltraps
80106a55:	e9 46 f7 ff ff       	jmp    801061a0 <alltraps>

80106a5a <vector53>:
.globl vector53
vector53:
  pushl $0
80106a5a:	6a 00                	push   $0x0
  pushl $53
80106a5c:	6a 35                	push   $0x35
  jmp alltraps
80106a5e:	e9 3d f7 ff ff       	jmp    801061a0 <alltraps>

80106a63 <vector54>:
.globl vector54
vector54:
  pushl $0
80106a63:	6a 00                	push   $0x0
  pushl $54
80106a65:	6a 36                	push   $0x36
  jmp alltraps
80106a67:	e9 34 f7 ff ff       	jmp    801061a0 <alltraps>

80106a6c <vector55>:
.globl vector55
vector55:
  pushl $0
80106a6c:	6a 00                	push   $0x0
  pushl $55
80106a6e:	6a 37                	push   $0x37
  jmp alltraps
80106a70:	e9 2b f7 ff ff       	jmp    801061a0 <alltraps>

80106a75 <vector56>:
.globl vector56
vector56:
  pushl $0
80106a75:	6a 00                	push   $0x0
  pushl $56
80106a77:	6a 38                	push   $0x38
  jmp alltraps
80106a79:	e9 22 f7 ff ff       	jmp    801061a0 <alltraps>

80106a7e <vector57>:
.globl vector57
vector57:
  pushl $0
80106a7e:	6a 00                	push   $0x0
  pushl $57
80106a80:	6a 39                	push   $0x39
  jmp alltraps
80106a82:	e9 19 f7 ff ff       	jmp    801061a0 <alltraps>

80106a87 <vector58>:
.globl vector58
vector58:
  pushl $0
80106a87:	6a 00                	push   $0x0
  pushl $58
80106a89:	6a 3a                	push   $0x3a
  jmp alltraps
80106a8b:	e9 10 f7 ff ff       	jmp    801061a0 <alltraps>

80106a90 <vector59>:
.globl vector59
vector59:
  pushl $0
80106a90:	6a 00                	push   $0x0
  pushl $59
80106a92:	6a 3b                	push   $0x3b
  jmp alltraps
80106a94:	e9 07 f7 ff ff       	jmp    801061a0 <alltraps>

80106a99 <vector60>:
.globl vector60
vector60:
  pushl $0
80106a99:	6a 00                	push   $0x0
  pushl $60
80106a9b:	6a 3c                	push   $0x3c
  jmp alltraps
80106a9d:	e9 fe f6 ff ff       	jmp    801061a0 <alltraps>

80106aa2 <vector61>:
.globl vector61
vector61:
  pushl $0
80106aa2:	6a 00                	push   $0x0
  pushl $61
80106aa4:	6a 3d                	push   $0x3d
  jmp alltraps
80106aa6:	e9 f5 f6 ff ff       	jmp    801061a0 <alltraps>

80106aab <vector62>:
.globl vector62
vector62:
  pushl $0
80106aab:	6a 00                	push   $0x0
  pushl $62
80106aad:	6a 3e                	push   $0x3e
  jmp alltraps
80106aaf:	e9 ec f6 ff ff       	jmp    801061a0 <alltraps>

80106ab4 <vector63>:
.globl vector63
vector63:
  pushl $0
80106ab4:	6a 00                	push   $0x0
  pushl $63
80106ab6:	6a 3f                	push   $0x3f
  jmp alltraps
80106ab8:	e9 e3 f6 ff ff       	jmp    801061a0 <alltraps>

80106abd <vector64>:
.globl vector64
vector64:
  pushl $0
80106abd:	6a 00                	push   $0x0
  pushl $64
80106abf:	6a 40                	push   $0x40
  jmp alltraps
80106ac1:	e9 da f6 ff ff       	jmp    801061a0 <alltraps>

80106ac6 <vector65>:
.globl vector65
vector65:
  pushl $0
80106ac6:	6a 00                	push   $0x0
  pushl $65
80106ac8:	6a 41                	push   $0x41
  jmp alltraps
80106aca:	e9 d1 f6 ff ff       	jmp    801061a0 <alltraps>

80106acf <vector66>:
.globl vector66
vector66:
  pushl $0
80106acf:	6a 00                	push   $0x0
  pushl $66
80106ad1:	6a 42                	push   $0x42
  jmp alltraps
80106ad3:	e9 c8 f6 ff ff       	jmp    801061a0 <alltraps>

80106ad8 <vector67>:
.globl vector67
vector67:
  pushl $0
80106ad8:	6a 00                	push   $0x0
  pushl $67
80106ada:	6a 43                	push   $0x43
  jmp alltraps
80106adc:	e9 bf f6 ff ff       	jmp    801061a0 <alltraps>

80106ae1 <vector68>:
.globl vector68
vector68:
  pushl $0
80106ae1:	6a 00                	push   $0x0
  pushl $68
80106ae3:	6a 44                	push   $0x44
  jmp alltraps
80106ae5:	e9 b6 f6 ff ff       	jmp    801061a0 <alltraps>

80106aea <vector69>:
.globl vector69
vector69:
  pushl $0
80106aea:	6a 00                	push   $0x0
  pushl $69
80106aec:	6a 45                	push   $0x45
  jmp alltraps
80106aee:	e9 ad f6 ff ff       	jmp    801061a0 <alltraps>

80106af3 <vector70>:
.globl vector70
vector70:
  pushl $0
80106af3:	6a 00                	push   $0x0
  pushl $70
80106af5:	6a 46                	push   $0x46
  jmp alltraps
80106af7:	e9 a4 f6 ff ff       	jmp    801061a0 <alltraps>

80106afc <vector71>:
.globl vector71
vector71:
  pushl $0
80106afc:	6a 00                	push   $0x0
  pushl $71
80106afe:	6a 47                	push   $0x47
  jmp alltraps
80106b00:	e9 9b f6 ff ff       	jmp    801061a0 <alltraps>

80106b05 <vector72>:
.globl vector72
vector72:
  pushl $0
80106b05:	6a 00                	push   $0x0
  pushl $72
80106b07:	6a 48                	push   $0x48
  jmp alltraps
80106b09:	e9 92 f6 ff ff       	jmp    801061a0 <alltraps>

80106b0e <vector73>:
.globl vector73
vector73:
  pushl $0
80106b0e:	6a 00                	push   $0x0
  pushl $73
80106b10:	6a 49                	push   $0x49
  jmp alltraps
80106b12:	e9 89 f6 ff ff       	jmp    801061a0 <alltraps>

80106b17 <vector74>:
.globl vector74
vector74:
  pushl $0
80106b17:	6a 00                	push   $0x0
  pushl $74
80106b19:	6a 4a                	push   $0x4a
  jmp alltraps
80106b1b:	e9 80 f6 ff ff       	jmp    801061a0 <alltraps>

80106b20 <vector75>:
.globl vector75
vector75:
  pushl $0
80106b20:	6a 00                	push   $0x0
  pushl $75
80106b22:	6a 4b                	push   $0x4b
  jmp alltraps
80106b24:	e9 77 f6 ff ff       	jmp    801061a0 <alltraps>

80106b29 <vector76>:
.globl vector76
vector76:
  pushl $0
80106b29:	6a 00                	push   $0x0
  pushl $76
80106b2b:	6a 4c                	push   $0x4c
  jmp alltraps
80106b2d:	e9 6e f6 ff ff       	jmp    801061a0 <alltraps>

80106b32 <vector77>:
.globl vector77
vector77:
  pushl $0
80106b32:	6a 00                	push   $0x0
  pushl $77
80106b34:	6a 4d                	push   $0x4d
  jmp alltraps
80106b36:	e9 65 f6 ff ff       	jmp    801061a0 <alltraps>

80106b3b <vector78>:
.globl vector78
vector78:
  pushl $0
80106b3b:	6a 00                	push   $0x0
  pushl $78
80106b3d:	6a 4e                	push   $0x4e
  jmp alltraps
80106b3f:	e9 5c f6 ff ff       	jmp    801061a0 <alltraps>

80106b44 <vector79>:
.globl vector79
vector79:
  pushl $0
80106b44:	6a 00                	push   $0x0
  pushl $79
80106b46:	6a 4f                	push   $0x4f
  jmp alltraps
80106b48:	e9 53 f6 ff ff       	jmp    801061a0 <alltraps>

80106b4d <vector80>:
.globl vector80
vector80:
  pushl $0
80106b4d:	6a 00                	push   $0x0
  pushl $80
80106b4f:	6a 50                	push   $0x50
  jmp alltraps
80106b51:	e9 4a f6 ff ff       	jmp    801061a0 <alltraps>

80106b56 <vector81>:
.globl vector81
vector81:
  pushl $0
80106b56:	6a 00                	push   $0x0
  pushl $81
80106b58:	6a 51                	push   $0x51
  jmp alltraps
80106b5a:	e9 41 f6 ff ff       	jmp    801061a0 <alltraps>

80106b5f <vector82>:
.globl vector82
vector82:
  pushl $0
80106b5f:	6a 00                	push   $0x0
  pushl $82
80106b61:	6a 52                	push   $0x52
  jmp alltraps
80106b63:	e9 38 f6 ff ff       	jmp    801061a0 <alltraps>

80106b68 <vector83>:
.globl vector83
vector83:
  pushl $0
80106b68:	6a 00                	push   $0x0
  pushl $83
80106b6a:	6a 53                	push   $0x53
  jmp alltraps
80106b6c:	e9 2f f6 ff ff       	jmp    801061a0 <alltraps>

80106b71 <vector84>:
.globl vector84
vector84:
  pushl $0
80106b71:	6a 00                	push   $0x0
  pushl $84
80106b73:	6a 54                	push   $0x54
  jmp alltraps
80106b75:	e9 26 f6 ff ff       	jmp    801061a0 <alltraps>

80106b7a <vector85>:
.globl vector85
vector85:
  pushl $0
80106b7a:	6a 00                	push   $0x0
  pushl $85
80106b7c:	6a 55                	push   $0x55
  jmp alltraps
80106b7e:	e9 1d f6 ff ff       	jmp    801061a0 <alltraps>

80106b83 <vector86>:
.globl vector86
vector86:
  pushl $0
80106b83:	6a 00                	push   $0x0
  pushl $86
80106b85:	6a 56                	push   $0x56
  jmp alltraps
80106b87:	e9 14 f6 ff ff       	jmp    801061a0 <alltraps>

80106b8c <vector87>:
.globl vector87
vector87:
  pushl $0
80106b8c:	6a 00                	push   $0x0
  pushl $87
80106b8e:	6a 57                	push   $0x57
  jmp alltraps
80106b90:	e9 0b f6 ff ff       	jmp    801061a0 <alltraps>

80106b95 <vector88>:
.globl vector88
vector88:
  pushl $0
80106b95:	6a 00                	push   $0x0
  pushl $88
80106b97:	6a 58                	push   $0x58
  jmp alltraps
80106b99:	e9 02 f6 ff ff       	jmp    801061a0 <alltraps>

80106b9e <vector89>:
.globl vector89
vector89:
  pushl $0
80106b9e:	6a 00                	push   $0x0
  pushl $89
80106ba0:	6a 59                	push   $0x59
  jmp alltraps
80106ba2:	e9 f9 f5 ff ff       	jmp    801061a0 <alltraps>

80106ba7 <vector90>:
.globl vector90
vector90:
  pushl $0
80106ba7:	6a 00                	push   $0x0
  pushl $90
80106ba9:	6a 5a                	push   $0x5a
  jmp alltraps
80106bab:	e9 f0 f5 ff ff       	jmp    801061a0 <alltraps>

80106bb0 <vector91>:
.globl vector91
vector91:
  pushl $0
80106bb0:	6a 00                	push   $0x0
  pushl $91
80106bb2:	6a 5b                	push   $0x5b
  jmp alltraps
80106bb4:	e9 e7 f5 ff ff       	jmp    801061a0 <alltraps>

80106bb9 <vector92>:
.globl vector92
vector92:
  pushl $0
80106bb9:	6a 00                	push   $0x0
  pushl $92
80106bbb:	6a 5c                	push   $0x5c
  jmp alltraps
80106bbd:	e9 de f5 ff ff       	jmp    801061a0 <alltraps>

80106bc2 <vector93>:
.globl vector93
vector93:
  pushl $0
80106bc2:	6a 00                	push   $0x0
  pushl $93
80106bc4:	6a 5d                	push   $0x5d
  jmp alltraps
80106bc6:	e9 d5 f5 ff ff       	jmp    801061a0 <alltraps>

80106bcb <vector94>:
.globl vector94
vector94:
  pushl $0
80106bcb:	6a 00                	push   $0x0
  pushl $94
80106bcd:	6a 5e                	push   $0x5e
  jmp alltraps
80106bcf:	e9 cc f5 ff ff       	jmp    801061a0 <alltraps>

80106bd4 <vector95>:
.globl vector95
vector95:
  pushl $0
80106bd4:	6a 00                	push   $0x0
  pushl $95
80106bd6:	6a 5f                	push   $0x5f
  jmp alltraps
80106bd8:	e9 c3 f5 ff ff       	jmp    801061a0 <alltraps>

80106bdd <vector96>:
.globl vector96
vector96:
  pushl $0
80106bdd:	6a 00                	push   $0x0
  pushl $96
80106bdf:	6a 60                	push   $0x60
  jmp alltraps
80106be1:	e9 ba f5 ff ff       	jmp    801061a0 <alltraps>

80106be6 <vector97>:
.globl vector97
vector97:
  pushl $0
80106be6:	6a 00                	push   $0x0
  pushl $97
80106be8:	6a 61                	push   $0x61
  jmp alltraps
80106bea:	e9 b1 f5 ff ff       	jmp    801061a0 <alltraps>

80106bef <vector98>:
.globl vector98
vector98:
  pushl $0
80106bef:	6a 00                	push   $0x0
  pushl $98
80106bf1:	6a 62                	push   $0x62
  jmp alltraps
80106bf3:	e9 a8 f5 ff ff       	jmp    801061a0 <alltraps>

80106bf8 <vector99>:
.globl vector99
vector99:
  pushl $0
80106bf8:	6a 00                	push   $0x0
  pushl $99
80106bfa:	6a 63                	push   $0x63
  jmp alltraps
80106bfc:	e9 9f f5 ff ff       	jmp    801061a0 <alltraps>

80106c01 <vector100>:
.globl vector100
vector100:
  pushl $0
80106c01:	6a 00                	push   $0x0
  pushl $100
80106c03:	6a 64                	push   $0x64
  jmp alltraps
80106c05:	e9 96 f5 ff ff       	jmp    801061a0 <alltraps>

80106c0a <vector101>:
.globl vector101
vector101:
  pushl $0
80106c0a:	6a 00                	push   $0x0
  pushl $101
80106c0c:	6a 65                	push   $0x65
  jmp alltraps
80106c0e:	e9 8d f5 ff ff       	jmp    801061a0 <alltraps>

80106c13 <vector102>:
.globl vector102
vector102:
  pushl $0
80106c13:	6a 00                	push   $0x0
  pushl $102
80106c15:	6a 66                	push   $0x66
  jmp alltraps
80106c17:	e9 84 f5 ff ff       	jmp    801061a0 <alltraps>

80106c1c <vector103>:
.globl vector103
vector103:
  pushl $0
80106c1c:	6a 00                	push   $0x0
  pushl $103
80106c1e:	6a 67                	push   $0x67
  jmp alltraps
80106c20:	e9 7b f5 ff ff       	jmp    801061a0 <alltraps>

80106c25 <vector104>:
.globl vector104
vector104:
  pushl $0
80106c25:	6a 00                	push   $0x0
  pushl $104
80106c27:	6a 68                	push   $0x68
  jmp alltraps
80106c29:	e9 72 f5 ff ff       	jmp    801061a0 <alltraps>

80106c2e <vector105>:
.globl vector105
vector105:
  pushl $0
80106c2e:	6a 00                	push   $0x0
  pushl $105
80106c30:	6a 69                	push   $0x69
  jmp alltraps
80106c32:	e9 69 f5 ff ff       	jmp    801061a0 <alltraps>

80106c37 <vector106>:
.globl vector106
vector106:
  pushl $0
80106c37:	6a 00                	push   $0x0
  pushl $106
80106c39:	6a 6a                	push   $0x6a
  jmp alltraps
80106c3b:	e9 60 f5 ff ff       	jmp    801061a0 <alltraps>

80106c40 <vector107>:
.globl vector107
vector107:
  pushl $0
80106c40:	6a 00                	push   $0x0
  pushl $107
80106c42:	6a 6b                	push   $0x6b
  jmp alltraps
80106c44:	e9 57 f5 ff ff       	jmp    801061a0 <alltraps>

80106c49 <vector108>:
.globl vector108
vector108:
  pushl $0
80106c49:	6a 00                	push   $0x0
  pushl $108
80106c4b:	6a 6c                	push   $0x6c
  jmp alltraps
80106c4d:	e9 4e f5 ff ff       	jmp    801061a0 <alltraps>

80106c52 <vector109>:
.globl vector109
vector109:
  pushl $0
80106c52:	6a 00                	push   $0x0
  pushl $109
80106c54:	6a 6d                	push   $0x6d
  jmp alltraps
80106c56:	e9 45 f5 ff ff       	jmp    801061a0 <alltraps>

80106c5b <vector110>:
.globl vector110
vector110:
  pushl $0
80106c5b:	6a 00                	push   $0x0
  pushl $110
80106c5d:	6a 6e                	push   $0x6e
  jmp alltraps
80106c5f:	e9 3c f5 ff ff       	jmp    801061a0 <alltraps>

80106c64 <vector111>:
.globl vector111
vector111:
  pushl $0
80106c64:	6a 00                	push   $0x0
  pushl $111
80106c66:	6a 6f                	push   $0x6f
  jmp alltraps
80106c68:	e9 33 f5 ff ff       	jmp    801061a0 <alltraps>

80106c6d <vector112>:
.globl vector112
vector112:
  pushl $0
80106c6d:	6a 00                	push   $0x0
  pushl $112
80106c6f:	6a 70                	push   $0x70
  jmp alltraps
80106c71:	e9 2a f5 ff ff       	jmp    801061a0 <alltraps>

80106c76 <vector113>:
.globl vector113
vector113:
  pushl $0
80106c76:	6a 00                	push   $0x0
  pushl $113
80106c78:	6a 71                	push   $0x71
  jmp alltraps
80106c7a:	e9 21 f5 ff ff       	jmp    801061a0 <alltraps>

80106c7f <vector114>:
.globl vector114
vector114:
  pushl $0
80106c7f:	6a 00                	push   $0x0
  pushl $114
80106c81:	6a 72                	push   $0x72
  jmp alltraps
80106c83:	e9 18 f5 ff ff       	jmp    801061a0 <alltraps>

80106c88 <vector115>:
.globl vector115
vector115:
  pushl $0
80106c88:	6a 00                	push   $0x0
  pushl $115
80106c8a:	6a 73                	push   $0x73
  jmp alltraps
80106c8c:	e9 0f f5 ff ff       	jmp    801061a0 <alltraps>

80106c91 <vector116>:
.globl vector116
vector116:
  pushl $0
80106c91:	6a 00                	push   $0x0
  pushl $116
80106c93:	6a 74                	push   $0x74
  jmp alltraps
80106c95:	e9 06 f5 ff ff       	jmp    801061a0 <alltraps>

80106c9a <vector117>:
.globl vector117
vector117:
  pushl $0
80106c9a:	6a 00                	push   $0x0
  pushl $117
80106c9c:	6a 75                	push   $0x75
  jmp alltraps
80106c9e:	e9 fd f4 ff ff       	jmp    801061a0 <alltraps>

80106ca3 <vector118>:
.globl vector118
vector118:
  pushl $0
80106ca3:	6a 00                	push   $0x0
  pushl $118
80106ca5:	6a 76                	push   $0x76
  jmp alltraps
80106ca7:	e9 f4 f4 ff ff       	jmp    801061a0 <alltraps>

80106cac <vector119>:
.globl vector119
vector119:
  pushl $0
80106cac:	6a 00                	push   $0x0
  pushl $119
80106cae:	6a 77                	push   $0x77
  jmp alltraps
80106cb0:	e9 eb f4 ff ff       	jmp    801061a0 <alltraps>

80106cb5 <vector120>:
.globl vector120
vector120:
  pushl $0
80106cb5:	6a 00                	push   $0x0
  pushl $120
80106cb7:	6a 78                	push   $0x78
  jmp alltraps
80106cb9:	e9 e2 f4 ff ff       	jmp    801061a0 <alltraps>

80106cbe <vector121>:
.globl vector121
vector121:
  pushl $0
80106cbe:	6a 00                	push   $0x0
  pushl $121
80106cc0:	6a 79                	push   $0x79
  jmp alltraps
80106cc2:	e9 d9 f4 ff ff       	jmp    801061a0 <alltraps>

80106cc7 <vector122>:
.globl vector122
vector122:
  pushl $0
80106cc7:	6a 00                	push   $0x0
  pushl $122
80106cc9:	6a 7a                	push   $0x7a
  jmp alltraps
80106ccb:	e9 d0 f4 ff ff       	jmp    801061a0 <alltraps>

80106cd0 <vector123>:
.globl vector123
vector123:
  pushl $0
80106cd0:	6a 00                	push   $0x0
  pushl $123
80106cd2:	6a 7b                	push   $0x7b
  jmp alltraps
80106cd4:	e9 c7 f4 ff ff       	jmp    801061a0 <alltraps>

80106cd9 <vector124>:
.globl vector124
vector124:
  pushl $0
80106cd9:	6a 00                	push   $0x0
  pushl $124
80106cdb:	6a 7c                	push   $0x7c
  jmp alltraps
80106cdd:	e9 be f4 ff ff       	jmp    801061a0 <alltraps>

80106ce2 <vector125>:
.globl vector125
vector125:
  pushl $0
80106ce2:	6a 00                	push   $0x0
  pushl $125
80106ce4:	6a 7d                	push   $0x7d
  jmp alltraps
80106ce6:	e9 b5 f4 ff ff       	jmp    801061a0 <alltraps>

80106ceb <vector126>:
.globl vector126
vector126:
  pushl $0
80106ceb:	6a 00                	push   $0x0
  pushl $126
80106ced:	6a 7e                	push   $0x7e
  jmp alltraps
80106cef:	e9 ac f4 ff ff       	jmp    801061a0 <alltraps>

80106cf4 <vector127>:
.globl vector127
vector127:
  pushl $0
80106cf4:	6a 00                	push   $0x0
  pushl $127
80106cf6:	6a 7f                	push   $0x7f
  jmp alltraps
80106cf8:	e9 a3 f4 ff ff       	jmp    801061a0 <alltraps>

80106cfd <vector128>:
.globl vector128
vector128:
  pushl $0
80106cfd:	6a 00                	push   $0x0
  pushl $128
80106cff:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106d04:	e9 97 f4 ff ff       	jmp    801061a0 <alltraps>

80106d09 <vector129>:
.globl vector129
vector129:
  pushl $0
80106d09:	6a 00                	push   $0x0
  pushl $129
80106d0b:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106d10:	e9 8b f4 ff ff       	jmp    801061a0 <alltraps>

80106d15 <vector130>:
.globl vector130
vector130:
  pushl $0
80106d15:	6a 00                	push   $0x0
  pushl $130
80106d17:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106d1c:	e9 7f f4 ff ff       	jmp    801061a0 <alltraps>

80106d21 <vector131>:
.globl vector131
vector131:
  pushl $0
80106d21:	6a 00                	push   $0x0
  pushl $131
80106d23:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106d28:	e9 73 f4 ff ff       	jmp    801061a0 <alltraps>

80106d2d <vector132>:
.globl vector132
vector132:
  pushl $0
80106d2d:	6a 00                	push   $0x0
  pushl $132
80106d2f:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106d34:	e9 67 f4 ff ff       	jmp    801061a0 <alltraps>

80106d39 <vector133>:
.globl vector133
vector133:
  pushl $0
80106d39:	6a 00                	push   $0x0
  pushl $133
80106d3b:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106d40:	e9 5b f4 ff ff       	jmp    801061a0 <alltraps>

80106d45 <vector134>:
.globl vector134
vector134:
  pushl $0
80106d45:	6a 00                	push   $0x0
  pushl $134
80106d47:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106d4c:	e9 4f f4 ff ff       	jmp    801061a0 <alltraps>

80106d51 <vector135>:
.globl vector135
vector135:
  pushl $0
80106d51:	6a 00                	push   $0x0
  pushl $135
80106d53:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106d58:	e9 43 f4 ff ff       	jmp    801061a0 <alltraps>

80106d5d <vector136>:
.globl vector136
vector136:
  pushl $0
80106d5d:	6a 00                	push   $0x0
  pushl $136
80106d5f:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106d64:	e9 37 f4 ff ff       	jmp    801061a0 <alltraps>

80106d69 <vector137>:
.globl vector137
vector137:
  pushl $0
80106d69:	6a 00                	push   $0x0
  pushl $137
80106d6b:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106d70:	e9 2b f4 ff ff       	jmp    801061a0 <alltraps>

80106d75 <vector138>:
.globl vector138
vector138:
  pushl $0
80106d75:	6a 00                	push   $0x0
  pushl $138
80106d77:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106d7c:	e9 1f f4 ff ff       	jmp    801061a0 <alltraps>

80106d81 <vector139>:
.globl vector139
vector139:
  pushl $0
80106d81:	6a 00                	push   $0x0
  pushl $139
80106d83:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106d88:	e9 13 f4 ff ff       	jmp    801061a0 <alltraps>

80106d8d <vector140>:
.globl vector140
vector140:
  pushl $0
80106d8d:	6a 00                	push   $0x0
  pushl $140
80106d8f:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106d94:	e9 07 f4 ff ff       	jmp    801061a0 <alltraps>

80106d99 <vector141>:
.globl vector141
vector141:
  pushl $0
80106d99:	6a 00                	push   $0x0
  pushl $141
80106d9b:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106da0:	e9 fb f3 ff ff       	jmp    801061a0 <alltraps>

80106da5 <vector142>:
.globl vector142
vector142:
  pushl $0
80106da5:	6a 00                	push   $0x0
  pushl $142
80106da7:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106dac:	e9 ef f3 ff ff       	jmp    801061a0 <alltraps>

80106db1 <vector143>:
.globl vector143
vector143:
  pushl $0
80106db1:	6a 00                	push   $0x0
  pushl $143
80106db3:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106db8:	e9 e3 f3 ff ff       	jmp    801061a0 <alltraps>

80106dbd <vector144>:
.globl vector144
vector144:
  pushl $0
80106dbd:	6a 00                	push   $0x0
  pushl $144
80106dbf:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106dc4:	e9 d7 f3 ff ff       	jmp    801061a0 <alltraps>

80106dc9 <vector145>:
.globl vector145
vector145:
  pushl $0
80106dc9:	6a 00                	push   $0x0
  pushl $145
80106dcb:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106dd0:	e9 cb f3 ff ff       	jmp    801061a0 <alltraps>

80106dd5 <vector146>:
.globl vector146
vector146:
  pushl $0
80106dd5:	6a 00                	push   $0x0
  pushl $146
80106dd7:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106ddc:	e9 bf f3 ff ff       	jmp    801061a0 <alltraps>

80106de1 <vector147>:
.globl vector147
vector147:
  pushl $0
80106de1:	6a 00                	push   $0x0
  pushl $147
80106de3:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106de8:	e9 b3 f3 ff ff       	jmp    801061a0 <alltraps>

80106ded <vector148>:
.globl vector148
vector148:
  pushl $0
80106ded:	6a 00                	push   $0x0
  pushl $148
80106def:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106df4:	e9 a7 f3 ff ff       	jmp    801061a0 <alltraps>

80106df9 <vector149>:
.globl vector149
vector149:
  pushl $0
80106df9:	6a 00                	push   $0x0
  pushl $149
80106dfb:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106e00:	e9 9b f3 ff ff       	jmp    801061a0 <alltraps>

80106e05 <vector150>:
.globl vector150
vector150:
  pushl $0
80106e05:	6a 00                	push   $0x0
  pushl $150
80106e07:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106e0c:	e9 8f f3 ff ff       	jmp    801061a0 <alltraps>

80106e11 <vector151>:
.globl vector151
vector151:
  pushl $0
80106e11:	6a 00                	push   $0x0
  pushl $151
80106e13:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106e18:	e9 83 f3 ff ff       	jmp    801061a0 <alltraps>

80106e1d <vector152>:
.globl vector152
vector152:
  pushl $0
80106e1d:	6a 00                	push   $0x0
  pushl $152
80106e1f:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106e24:	e9 77 f3 ff ff       	jmp    801061a0 <alltraps>

80106e29 <vector153>:
.globl vector153
vector153:
  pushl $0
80106e29:	6a 00                	push   $0x0
  pushl $153
80106e2b:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106e30:	e9 6b f3 ff ff       	jmp    801061a0 <alltraps>

80106e35 <vector154>:
.globl vector154
vector154:
  pushl $0
80106e35:	6a 00                	push   $0x0
  pushl $154
80106e37:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106e3c:	e9 5f f3 ff ff       	jmp    801061a0 <alltraps>

80106e41 <vector155>:
.globl vector155
vector155:
  pushl $0
80106e41:	6a 00                	push   $0x0
  pushl $155
80106e43:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106e48:	e9 53 f3 ff ff       	jmp    801061a0 <alltraps>

80106e4d <vector156>:
.globl vector156
vector156:
  pushl $0
80106e4d:	6a 00                	push   $0x0
  pushl $156
80106e4f:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106e54:	e9 47 f3 ff ff       	jmp    801061a0 <alltraps>

80106e59 <vector157>:
.globl vector157
vector157:
  pushl $0
80106e59:	6a 00                	push   $0x0
  pushl $157
80106e5b:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106e60:	e9 3b f3 ff ff       	jmp    801061a0 <alltraps>

80106e65 <vector158>:
.globl vector158
vector158:
  pushl $0
80106e65:	6a 00                	push   $0x0
  pushl $158
80106e67:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106e6c:	e9 2f f3 ff ff       	jmp    801061a0 <alltraps>

80106e71 <vector159>:
.globl vector159
vector159:
  pushl $0
80106e71:	6a 00                	push   $0x0
  pushl $159
80106e73:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106e78:	e9 23 f3 ff ff       	jmp    801061a0 <alltraps>

80106e7d <vector160>:
.globl vector160
vector160:
  pushl $0
80106e7d:	6a 00                	push   $0x0
  pushl $160
80106e7f:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106e84:	e9 17 f3 ff ff       	jmp    801061a0 <alltraps>

80106e89 <vector161>:
.globl vector161
vector161:
  pushl $0
80106e89:	6a 00                	push   $0x0
  pushl $161
80106e8b:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106e90:	e9 0b f3 ff ff       	jmp    801061a0 <alltraps>

80106e95 <vector162>:
.globl vector162
vector162:
  pushl $0
80106e95:	6a 00                	push   $0x0
  pushl $162
80106e97:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106e9c:	e9 ff f2 ff ff       	jmp    801061a0 <alltraps>

80106ea1 <vector163>:
.globl vector163
vector163:
  pushl $0
80106ea1:	6a 00                	push   $0x0
  pushl $163
80106ea3:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106ea8:	e9 f3 f2 ff ff       	jmp    801061a0 <alltraps>

80106ead <vector164>:
.globl vector164
vector164:
  pushl $0
80106ead:	6a 00                	push   $0x0
  pushl $164
80106eaf:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106eb4:	e9 e7 f2 ff ff       	jmp    801061a0 <alltraps>

80106eb9 <vector165>:
.globl vector165
vector165:
  pushl $0
80106eb9:	6a 00                	push   $0x0
  pushl $165
80106ebb:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106ec0:	e9 db f2 ff ff       	jmp    801061a0 <alltraps>

80106ec5 <vector166>:
.globl vector166
vector166:
  pushl $0
80106ec5:	6a 00                	push   $0x0
  pushl $166
80106ec7:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106ecc:	e9 cf f2 ff ff       	jmp    801061a0 <alltraps>

80106ed1 <vector167>:
.globl vector167
vector167:
  pushl $0
80106ed1:	6a 00                	push   $0x0
  pushl $167
80106ed3:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106ed8:	e9 c3 f2 ff ff       	jmp    801061a0 <alltraps>

80106edd <vector168>:
.globl vector168
vector168:
  pushl $0
80106edd:	6a 00                	push   $0x0
  pushl $168
80106edf:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106ee4:	e9 b7 f2 ff ff       	jmp    801061a0 <alltraps>

80106ee9 <vector169>:
.globl vector169
vector169:
  pushl $0
80106ee9:	6a 00                	push   $0x0
  pushl $169
80106eeb:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106ef0:	e9 ab f2 ff ff       	jmp    801061a0 <alltraps>

80106ef5 <vector170>:
.globl vector170
vector170:
  pushl $0
80106ef5:	6a 00                	push   $0x0
  pushl $170
80106ef7:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106efc:	e9 9f f2 ff ff       	jmp    801061a0 <alltraps>

80106f01 <vector171>:
.globl vector171
vector171:
  pushl $0
80106f01:	6a 00                	push   $0x0
  pushl $171
80106f03:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106f08:	e9 93 f2 ff ff       	jmp    801061a0 <alltraps>

80106f0d <vector172>:
.globl vector172
vector172:
  pushl $0
80106f0d:	6a 00                	push   $0x0
  pushl $172
80106f0f:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106f14:	e9 87 f2 ff ff       	jmp    801061a0 <alltraps>

80106f19 <vector173>:
.globl vector173
vector173:
  pushl $0
80106f19:	6a 00                	push   $0x0
  pushl $173
80106f1b:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106f20:	e9 7b f2 ff ff       	jmp    801061a0 <alltraps>

80106f25 <vector174>:
.globl vector174
vector174:
  pushl $0
80106f25:	6a 00                	push   $0x0
  pushl $174
80106f27:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106f2c:	e9 6f f2 ff ff       	jmp    801061a0 <alltraps>

80106f31 <vector175>:
.globl vector175
vector175:
  pushl $0
80106f31:	6a 00                	push   $0x0
  pushl $175
80106f33:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106f38:	e9 63 f2 ff ff       	jmp    801061a0 <alltraps>

80106f3d <vector176>:
.globl vector176
vector176:
  pushl $0
80106f3d:	6a 00                	push   $0x0
  pushl $176
80106f3f:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106f44:	e9 57 f2 ff ff       	jmp    801061a0 <alltraps>

80106f49 <vector177>:
.globl vector177
vector177:
  pushl $0
80106f49:	6a 00                	push   $0x0
  pushl $177
80106f4b:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106f50:	e9 4b f2 ff ff       	jmp    801061a0 <alltraps>

80106f55 <vector178>:
.globl vector178
vector178:
  pushl $0
80106f55:	6a 00                	push   $0x0
  pushl $178
80106f57:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106f5c:	e9 3f f2 ff ff       	jmp    801061a0 <alltraps>

80106f61 <vector179>:
.globl vector179
vector179:
  pushl $0
80106f61:	6a 00                	push   $0x0
  pushl $179
80106f63:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106f68:	e9 33 f2 ff ff       	jmp    801061a0 <alltraps>

80106f6d <vector180>:
.globl vector180
vector180:
  pushl $0
80106f6d:	6a 00                	push   $0x0
  pushl $180
80106f6f:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106f74:	e9 27 f2 ff ff       	jmp    801061a0 <alltraps>

80106f79 <vector181>:
.globl vector181
vector181:
  pushl $0
80106f79:	6a 00                	push   $0x0
  pushl $181
80106f7b:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106f80:	e9 1b f2 ff ff       	jmp    801061a0 <alltraps>

80106f85 <vector182>:
.globl vector182
vector182:
  pushl $0
80106f85:	6a 00                	push   $0x0
  pushl $182
80106f87:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106f8c:	e9 0f f2 ff ff       	jmp    801061a0 <alltraps>

80106f91 <vector183>:
.globl vector183
vector183:
  pushl $0
80106f91:	6a 00                	push   $0x0
  pushl $183
80106f93:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106f98:	e9 03 f2 ff ff       	jmp    801061a0 <alltraps>

80106f9d <vector184>:
.globl vector184
vector184:
  pushl $0
80106f9d:	6a 00                	push   $0x0
  pushl $184
80106f9f:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106fa4:	e9 f7 f1 ff ff       	jmp    801061a0 <alltraps>

80106fa9 <vector185>:
.globl vector185
vector185:
  pushl $0
80106fa9:	6a 00                	push   $0x0
  pushl $185
80106fab:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106fb0:	e9 eb f1 ff ff       	jmp    801061a0 <alltraps>

80106fb5 <vector186>:
.globl vector186
vector186:
  pushl $0
80106fb5:	6a 00                	push   $0x0
  pushl $186
80106fb7:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106fbc:	e9 df f1 ff ff       	jmp    801061a0 <alltraps>

80106fc1 <vector187>:
.globl vector187
vector187:
  pushl $0
80106fc1:	6a 00                	push   $0x0
  pushl $187
80106fc3:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106fc8:	e9 d3 f1 ff ff       	jmp    801061a0 <alltraps>

80106fcd <vector188>:
.globl vector188
vector188:
  pushl $0
80106fcd:	6a 00                	push   $0x0
  pushl $188
80106fcf:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106fd4:	e9 c7 f1 ff ff       	jmp    801061a0 <alltraps>

80106fd9 <vector189>:
.globl vector189
vector189:
  pushl $0
80106fd9:	6a 00                	push   $0x0
  pushl $189
80106fdb:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106fe0:	e9 bb f1 ff ff       	jmp    801061a0 <alltraps>

80106fe5 <vector190>:
.globl vector190
vector190:
  pushl $0
80106fe5:	6a 00                	push   $0x0
  pushl $190
80106fe7:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106fec:	e9 af f1 ff ff       	jmp    801061a0 <alltraps>

80106ff1 <vector191>:
.globl vector191
vector191:
  pushl $0
80106ff1:	6a 00                	push   $0x0
  pushl $191
80106ff3:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106ff8:	e9 a3 f1 ff ff       	jmp    801061a0 <alltraps>

80106ffd <vector192>:
.globl vector192
vector192:
  pushl $0
80106ffd:	6a 00                	push   $0x0
  pushl $192
80106fff:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107004:	e9 97 f1 ff ff       	jmp    801061a0 <alltraps>

80107009 <vector193>:
.globl vector193
vector193:
  pushl $0
80107009:	6a 00                	push   $0x0
  pushl $193
8010700b:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107010:	e9 8b f1 ff ff       	jmp    801061a0 <alltraps>

80107015 <vector194>:
.globl vector194
vector194:
  pushl $0
80107015:	6a 00                	push   $0x0
  pushl $194
80107017:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010701c:	e9 7f f1 ff ff       	jmp    801061a0 <alltraps>

80107021 <vector195>:
.globl vector195
vector195:
  pushl $0
80107021:	6a 00                	push   $0x0
  pushl $195
80107023:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107028:	e9 73 f1 ff ff       	jmp    801061a0 <alltraps>

8010702d <vector196>:
.globl vector196
vector196:
  pushl $0
8010702d:	6a 00                	push   $0x0
  pushl $196
8010702f:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107034:	e9 67 f1 ff ff       	jmp    801061a0 <alltraps>

80107039 <vector197>:
.globl vector197
vector197:
  pushl $0
80107039:	6a 00                	push   $0x0
  pushl $197
8010703b:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107040:	e9 5b f1 ff ff       	jmp    801061a0 <alltraps>

80107045 <vector198>:
.globl vector198
vector198:
  pushl $0
80107045:	6a 00                	push   $0x0
  pushl $198
80107047:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010704c:	e9 4f f1 ff ff       	jmp    801061a0 <alltraps>

80107051 <vector199>:
.globl vector199
vector199:
  pushl $0
80107051:	6a 00                	push   $0x0
  pushl $199
80107053:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107058:	e9 43 f1 ff ff       	jmp    801061a0 <alltraps>

8010705d <vector200>:
.globl vector200
vector200:
  pushl $0
8010705d:	6a 00                	push   $0x0
  pushl $200
8010705f:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107064:	e9 37 f1 ff ff       	jmp    801061a0 <alltraps>

80107069 <vector201>:
.globl vector201
vector201:
  pushl $0
80107069:	6a 00                	push   $0x0
  pushl $201
8010706b:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107070:	e9 2b f1 ff ff       	jmp    801061a0 <alltraps>

80107075 <vector202>:
.globl vector202
vector202:
  pushl $0
80107075:	6a 00                	push   $0x0
  pushl $202
80107077:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010707c:	e9 1f f1 ff ff       	jmp    801061a0 <alltraps>

80107081 <vector203>:
.globl vector203
vector203:
  pushl $0
80107081:	6a 00                	push   $0x0
  pushl $203
80107083:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107088:	e9 13 f1 ff ff       	jmp    801061a0 <alltraps>

8010708d <vector204>:
.globl vector204
vector204:
  pushl $0
8010708d:	6a 00                	push   $0x0
  pushl $204
8010708f:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107094:	e9 07 f1 ff ff       	jmp    801061a0 <alltraps>

80107099 <vector205>:
.globl vector205
vector205:
  pushl $0
80107099:	6a 00                	push   $0x0
  pushl $205
8010709b:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801070a0:	e9 fb f0 ff ff       	jmp    801061a0 <alltraps>

801070a5 <vector206>:
.globl vector206
vector206:
  pushl $0
801070a5:	6a 00                	push   $0x0
  pushl $206
801070a7:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801070ac:	e9 ef f0 ff ff       	jmp    801061a0 <alltraps>

801070b1 <vector207>:
.globl vector207
vector207:
  pushl $0
801070b1:	6a 00                	push   $0x0
  pushl $207
801070b3:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801070b8:	e9 e3 f0 ff ff       	jmp    801061a0 <alltraps>

801070bd <vector208>:
.globl vector208
vector208:
  pushl $0
801070bd:	6a 00                	push   $0x0
  pushl $208
801070bf:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801070c4:	e9 d7 f0 ff ff       	jmp    801061a0 <alltraps>

801070c9 <vector209>:
.globl vector209
vector209:
  pushl $0
801070c9:	6a 00                	push   $0x0
  pushl $209
801070cb:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801070d0:	e9 cb f0 ff ff       	jmp    801061a0 <alltraps>

801070d5 <vector210>:
.globl vector210
vector210:
  pushl $0
801070d5:	6a 00                	push   $0x0
  pushl $210
801070d7:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801070dc:	e9 bf f0 ff ff       	jmp    801061a0 <alltraps>

801070e1 <vector211>:
.globl vector211
vector211:
  pushl $0
801070e1:	6a 00                	push   $0x0
  pushl $211
801070e3:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801070e8:	e9 b3 f0 ff ff       	jmp    801061a0 <alltraps>

801070ed <vector212>:
.globl vector212
vector212:
  pushl $0
801070ed:	6a 00                	push   $0x0
  pushl $212
801070ef:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801070f4:	e9 a7 f0 ff ff       	jmp    801061a0 <alltraps>

801070f9 <vector213>:
.globl vector213
vector213:
  pushl $0
801070f9:	6a 00                	push   $0x0
  pushl $213
801070fb:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107100:	e9 9b f0 ff ff       	jmp    801061a0 <alltraps>

80107105 <vector214>:
.globl vector214
vector214:
  pushl $0
80107105:	6a 00                	push   $0x0
  pushl $214
80107107:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010710c:	e9 8f f0 ff ff       	jmp    801061a0 <alltraps>

80107111 <vector215>:
.globl vector215
vector215:
  pushl $0
80107111:	6a 00                	push   $0x0
  pushl $215
80107113:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107118:	e9 83 f0 ff ff       	jmp    801061a0 <alltraps>

8010711d <vector216>:
.globl vector216
vector216:
  pushl $0
8010711d:	6a 00                	push   $0x0
  pushl $216
8010711f:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107124:	e9 77 f0 ff ff       	jmp    801061a0 <alltraps>

80107129 <vector217>:
.globl vector217
vector217:
  pushl $0
80107129:	6a 00                	push   $0x0
  pushl $217
8010712b:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107130:	e9 6b f0 ff ff       	jmp    801061a0 <alltraps>

80107135 <vector218>:
.globl vector218
vector218:
  pushl $0
80107135:	6a 00                	push   $0x0
  pushl $218
80107137:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010713c:	e9 5f f0 ff ff       	jmp    801061a0 <alltraps>

80107141 <vector219>:
.globl vector219
vector219:
  pushl $0
80107141:	6a 00                	push   $0x0
  pushl $219
80107143:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107148:	e9 53 f0 ff ff       	jmp    801061a0 <alltraps>

8010714d <vector220>:
.globl vector220
vector220:
  pushl $0
8010714d:	6a 00                	push   $0x0
  pushl $220
8010714f:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107154:	e9 47 f0 ff ff       	jmp    801061a0 <alltraps>

80107159 <vector221>:
.globl vector221
vector221:
  pushl $0
80107159:	6a 00                	push   $0x0
  pushl $221
8010715b:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107160:	e9 3b f0 ff ff       	jmp    801061a0 <alltraps>

80107165 <vector222>:
.globl vector222
vector222:
  pushl $0
80107165:	6a 00                	push   $0x0
  pushl $222
80107167:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010716c:	e9 2f f0 ff ff       	jmp    801061a0 <alltraps>

80107171 <vector223>:
.globl vector223
vector223:
  pushl $0
80107171:	6a 00                	push   $0x0
  pushl $223
80107173:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107178:	e9 23 f0 ff ff       	jmp    801061a0 <alltraps>

8010717d <vector224>:
.globl vector224
vector224:
  pushl $0
8010717d:	6a 00                	push   $0x0
  pushl $224
8010717f:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107184:	e9 17 f0 ff ff       	jmp    801061a0 <alltraps>

80107189 <vector225>:
.globl vector225
vector225:
  pushl $0
80107189:	6a 00                	push   $0x0
  pushl $225
8010718b:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107190:	e9 0b f0 ff ff       	jmp    801061a0 <alltraps>

80107195 <vector226>:
.globl vector226
vector226:
  pushl $0
80107195:	6a 00                	push   $0x0
  pushl $226
80107197:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010719c:	e9 ff ef ff ff       	jmp    801061a0 <alltraps>

801071a1 <vector227>:
.globl vector227
vector227:
  pushl $0
801071a1:	6a 00                	push   $0x0
  pushl $227
801071a3:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801071a8:	e9 f3 ef ff ff       	jmp    801061a0 <alltraps>

801071ad <vector228>:
.globl vector228
vector228:
  pushl $0
801071ad:	6a 00                	push   $0x0
  pushl $228
801071af:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801071b4:	e9 e7 ef ff ff       	jmp    801061a0 <alltraps>

801071b9 <vector229>:
.globl vector229
vector229:
  pushl $0
801071b9:	6a 00                	push   $0x0
  pushl $229
801071bb:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801071c0:	e9 db ef ff ff       	jmp    801061a0 <alltraps>

801071c5 <vector230>:
.globl vector230
vector230:
  pushl $0
801071c5:	6a 00                	push   $0x0
  pushl $230
801071c7:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801071cc:	e9 cf ef ff ff       	jmp    801061a0 <alltraps>

801071d1 <vector231>:
.globl vector231
vector231:
  pushl $0
801071d1:	6a 00                	push   $0x0
  pushl $231
801071d3:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801071d8:	e9 c3 ef ff ff       	jmp    801061a0 <alltraps>

801071dd <vector232>:
.globl vector232
vector232:
  pushl $0
801071dd:	6a 00                	push   $0x0
  pushl $232
801071df:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801071e4:	e9 b7 ef ff ff       	jmp    801061a0 <alltraps>

801071e9 <vector233>:
.globl vector233
vector233:
  pushl $0
801071e9:	6a 00                	push   $0x0
  pushl $233
801071eb:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801071f0:	e9 ab ef ff ff       	jmp    801061a0 <alltraps>

801071f5 <vector234>:
.globl vector234
vector234:
  pushl $0
801071f5:	6a 00                	push   $0x0
  pushl $234
801071f7:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801071fc:	e9 9f ef ff ff       	jmp    801061a0 <alltraps>

80107201 <vector235>:
.globl vector235
vector235:
  pushl $0
80107201:	6a 00                	push   $0x0
  pushl $235
80107203:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107208:	e9 93 ef ff ff       	jmp    801061a0 <alltraps>

8010720d <vector236>:
.globl vector236
vector236:
  pushl $0
8010720d:	6a 00                	push   $0x0
  pushl $236
8010720f:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107214:	e9 87 ef ff ff       	jmp    801061a0 <alltraps>

80107219 <vector237>:
.globl vector237
vector237:
  pushl $0
80107219:	6a 00                	push   $0x0
  pushl $237
8010721b:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107220:	e9 7b ef ff ff       	jmp    801061a0 <alltraps>

80107225 <vector238>:
.globl vector238
vector238:
  pushl $0
80107225:	6a 00                	push   $0x0
  pushl $238
80107227:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010722c:	e9 6f ef ff ff       	jmp    801061a0 <alltraps>

80107231 <vector239>:
.globl vector239
vector239:
  pushl $0
80107231:	6a 00                	push   $0x0
  pushl $239
80107233:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107238:	e9 63 ef ff ff       	jmp    801061a0 <alltraps>

8010723d <vector240>:
.globl vector240
vector240:
  pushl $0
8010723d:	6a 00                	push   $0x0
  pushl $240
8010723f:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107244:	e9 57 ef ff ff       	jmp    801061a0 <alltraps>

80107249 <vector241>:
.globl vector241
vector241:
  pushl $0
80107249:	6a 00                	push   $0x0
  pushl $241
8010724b:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107250:	e9 4b ef ff ff       	jmp    801061a0 <alltraps>

80107255 <vector242>:
.globl vector242
vector242:
  pushl $0
80107255:	6a 00                	push   $0x0
  pushl $242
80107257:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010725c:	e9 3f ef ff ff       	jmp    801061a0 <alltraps>

80107261 <vector243>:
.globl vector243
vector243:
  pushl $0
80107261:	6a 00                	push   $0x0
  pushl $243
80107263:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107268:	e9 33 ef ff ff       	jmp    801061a0 <alltraps>

8010726d <vector244>:
.globl vector244
vector244:
  pushl $0
8010726d:	6a 00                	push   $0x0
  pushl $244
8010726f:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107274:	e9 27 ef ff ff       	jmp    801061a0 <alltraps>

80107279 <vector245>:
.globl vector245
vector245:
  pushl $0
80107279:	6a 00                	push   $0x0
  pushl $245
8010727b:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107280:	e9 1b ef ff ff       	jmp    801061a0 <alltraps>

80107285 <vector246>:
.globl vector246
vector246:
  pushl $0
80107285:	6a 00                	push   $0x0
  pushl $246
80107287:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010728c:	e9 0f ef ff ff       	jmp    801061a0 <alltraps>

80107291 <vector247>:
.globl vector247
vector247:
  pushl $0
80107291:	6a 00                	push   $0x0
  pushl $247
80107293:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107298:	e9 03 ef ff ff       	jmp    801061a0 <alltraps>

8010729d <vector248>:
.globl vector248
vector248:
  pushl $0
8010729d:	6a 00                	push   $0x0
  pushl $248
8010729f:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801072a4:	e9 f7 ee ff ff       	jmp    801061a0 <alltraps>

801072a9 <vector249>:
.globl vector249
vector249:
  pushl $0
801072a9:	6a 00                	push   $0x0
  pushl $249
801072ab:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801072b0:	e9 eb ee ff ff       	jmp    801061a0 <alltraps>

801072b5 <vector250>:
.globl vector250
vector250:
  pushl $0
801072b5:	6a 00                	push   $0x0
  pushl $250
801072b7:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801072bc:	e9 df ee ff ff       	jmp    801061a0 <alltraps>

801072c1 <vector251>:
.globl vector251
vector251:
  pushl $0
801072c1:	6a 00                	push   $0x0
  pushl $251
801072c3:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801072c8:	e9 d3 ee ff ff       	jmp    801061a0 <alltraps>

801072cd <vector252>:
.globl vector252
vector252:
  pushl $0
801072cd:	6a 00                	push   $0x0
  pushl $252
801072cf:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801072d4:	e9 c7 ee ff ff       	jmp    801061a0 <alltraps>

801072d9 <vector253>:
.globl vector253
vector253:
  pushl $0
801072d9:	6a 00                	push   $0x0
  pushl $253
801072db:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801072e0:	e9 bb ee ff ff       	jmp    801061a0 <alltraps>

801072e5 <vector254>:
.globl vector254
vector254:
  pushl $0
801072e5:	6a 00                	push   $0x0
  pushl $254
801072e7:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801072ec:	e9 af ee ff ff       	jmp    801061a0 <alltraps>

801072f1 <vector255>:
.globl vector255
vector255:
  pushl $0
801072f1:	6a 00                	push   $0x0
  pushl $255
801072f3:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801072f8:	e9 a3 ee ff ff       	jmp    801061a0 <alltraps>

801072fd <lgdt>:
{
801072fd:	55                   	push   %ebp
801072fe:	89 e5                	mov    %esp,%ebp
80107300:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107303:	8b 45 0c             	mov    0xc(%ebp),%eax
80107306:	83 e8 01             	sub    $0x1,%eax
80107309:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010730d:	8b 45 08             	mov    0x8(%ebp),%eax
80107310:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107314:	8b 45 08             	mov    0x8(%ebp),%eax
80107317:	c1 e8 10             	shr    $0x10,%eax
8010731a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010731e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107321:	0f 01 10             	lgdtl  (%eax)
}
80107324:	90                   	nop
80107325:	c9                   	leave
80107326:	c3                   	ret

80107327 <ltr>:
{
80107327:	55                   	push   %ebp
80107328:	89 e5                	mov    %esp,%ebp
8010732a:	83 ec 04             	sub    $0x4,%esp
8010732d:	8b 45 08             	mov    0x8(%ebp),%eax
80107330:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107334:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107338:	0f 00 d8             	ltr    %eax
}
8010733b:	90                   	nop
8010733c:	c9                   	leave
8010733d:	c3                   	ret

8010733e <lcr3>:

static inline void
lcr3(uint val)
{
8010733e:	55                   	push   %ebp
8010733f:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107341:	8b 45 08             	mov    0x8(%ebp),%eax
80107344:	0f 22 d8             	mov    %eax,%cr3
}
80107347:	90                   	nop
80107348:	5d                   	pop    %ebp
80107349:	c3                   	ret

8010734a <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010734a:	f3 0f 1e fb          	endbr32
8010734e:	55                   	push   %ebp
8010734f:	89 e5                	mov    %esp,%ebp
80107351:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107354:	e8 f2 c7 ff ff       	call   80103b4b <cpuid>
80107359:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010735f:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80107364:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010736a:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107373:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010737c:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107383:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107387:	83 e2 f0             	and    $0xfffffff0,%edx
8010738a:	83 ca 0a             	or     $0xa,%edx
8010738d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107390:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107393:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107397:	83 ca 10             	or     $0x10,%edx
8010739a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010739d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073a4:	83 e2 9f             	and    $0xffffff9f,%edx
801073a7:	88 50 7d             	mov    %dl,0x7d(%eax)
801073aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ad:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073b1:	83 ca 80             	or     $0xffffff80,%edx
801073b4:	88 50 7d             	mov    %dl,0x7d(%eax)
801073b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ba:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073be:	83 ca 0f             	or     $0xf,%edx
801073c1:	88 50 7e             	mov    %dl,0x7e(%eax)
801073c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073cb:	83 e2 ef             	and    $0xffffffef,%edx
801073ce:	88 50 7e             	mov    %dl,0x7e(%eax)
801073d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073d8:	83 e2 df             	and    $0xffffffdf,%edx
801073db:	88 50 7e             	mov    %dl,0x7e(%eax)
801073de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073e5:	83 ca 40             	or     $0x40,%edx
801073e8:	88 50 7e             	mov    %dl,0x7e(%eax)
801073eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ee:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073f2:	83 ca 80             	or     $0xffffff80,%edx
801073f5:	88 50 7e             	mov    %dl,0x7e(%eax)
801073f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073fb:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801073ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107402:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107409:	ff ff 
8010740b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010740e:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107415:	00 00 
80107417:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741a:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107424:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010742b:	83 e2 f0             	and    $0xfffffff0,%edx
8010742e:	83 ca 02             	or     $0x2,%edx
80107431:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107441:	83 ca 10             	or     $0x10,%edx
80107444:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010744a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010744d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107454:	83 e2 9f             	and    $0xffffff9f,%edx
80107457:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010745d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107460:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107467:	83 ca 80             	or     $0xffffff80,%edx
8010746a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107473:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010747a:	83 ca 0f             	or     $0xf,%edx
8010747d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107486:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010748d:	83 e2 ef             	and    $0xffffffef,%edx
80107490:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107499:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074a0:	83 e2 df             	and    $0xffffffdf,%edx
801074a3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ac:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074b3:	83 ca 40             	or     $0x40,%edx
801074b6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074bf:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074c6:	83 ca 80             	or     $0xffffff80,%edx
801074c9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d2:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801074d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074dc:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801074e3:	ff ff 
801074e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e8:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801074ef:	00 00 
801074f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f4:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801074fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074fe:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107505:	83 e2 f0             	and    $0xfffffff0,%edx
80107508:	83 ca 0a             	or     $0xa,%edx
8010750b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107514:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010751b:	83 ca 10             	or     $0x10,%edx
8010751e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107527:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010752e:	83 ca 60             	or     $0x60,%edx
80107531:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107541:	83 ca 80             	or     $0xffffff80,%edx
80107544:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010754a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010754d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107554:	83 ca 0f             	or     $0xf,%edx
80107557:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010755d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107560:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107567:	83 e2 ef             	and    $0xffffffef,%edx
8010756a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107573:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010757a:	83 e2 df             	and    $0xffffffdf,%edx
8010757d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107586:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010758d:	83 ca 40             	or     $0x40,%edx
80107590:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107599:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075a0:	83 ca 80             	or     $0xffffff80,%edx
801075a3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ac:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801075b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b6:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801075bd:	ff ff 
801075bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c2:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801075c9:	00 00 
801075cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ce:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801075d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075df:	83 e2 f0             	and    $0xfffffff0,%edx
801075e2:	83 ca 02             	or     $0x2,%edx
801075e5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ee:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075f5:	83 ca 10             	or     $0x10,%edx
801075f8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107601:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107608:	83 ca 60             	or     $0x60,%edx
8010760b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107614:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010761b:	83 ca 80             	or     $0xffffff80,%edx
8010761e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107627:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010762e:	83 ca 0f             	or     $0xf,%edx
80107631:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107641:	83 e2 ef             	and    $0xffffffef,%edx
80107644:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010764a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107654:	83 e2 df             	and    $0xffffffdf,%edx
80107657:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010765d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107660:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107667:	83 ca 40             	or     $0x40,%edx
8010766a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107673:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010767a:	83 ca 80             	or     $0xffffff80,%edx
8010767d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107686:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010768d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107690:	83 c0 70             	add    $0x70,%eax
80107693:	83 ec 08             	sub    $0x8,%esp
80107696:	6a 30                	push   $0x30
80107698:	50                   	push   %eax
80107699:	e8 5f fc ff ff       	call   801072fd <lgdt>
8010769e:	83 c4 10             	add    $0x10,%esp
}
801076a1:	90                   	nop
801076a2:	c9                   	leave
801076a3:	c3                   	ret

801076a4 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
/*static 전역에서 사용해야 함*/ pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801076a4:	f3 0f 1e fb          	endbr32
801076a8:	55                   	push   %ebp
801076a9:	89 e5                	mov    %esp,%ebp
801076ab:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801076ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801076b1:	c1 e8 16             	shr    $0x16,%eax
801076b4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801076bb:	8b 45 08             	mov    0x8(%ebp),%eax
801076be:	01 d0                	add    %edx,%eax
801076c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801076c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076c6:	8b 00                	mov    (%eax),%eax
801076c8:	83 e0 01             	and    $0x1,%eax
801076cb:	85 c0                	test   %eax,%eax
801076cd:	74 14                	je     801076e3 <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801076cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076d2:	8b 00                	mov    (%eax),%eax
801076d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076d9:	05 00 00 00 80       	add    $0x80000000,%eax
801076de:	89 45 f4             	mov    %eax,-0xc(%ebp)
801076e1:	eb 42                	jmp    80107725 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801076e3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801076e7:	74 0e                	je     801076f7 <walkpgdir+0x53>
801076e9:	e8 e1 b1 ff ff       	call   801028cf <kalloc>
801076ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801076f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801076f5:	75 07                	jne    801076fe <walkpgdir+0x5a>
      return 0;
801076f7:	b8 00 00 00 00       	mov    $0x0,%eax
801076fc:	eb 3e                	jmp    8010773c <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801076fe:	83 ec 04             	sub    $0x4,%esp
80107701:	68 00 10 00 00       	push   $0x1000
80107706:	6a 00                	push   $0x0
80107708:	ff 75 f4             	push   -0xc(%ebp)
8010770b:	e8 42 d6 ff ff       	call   80104d52 <memset>
80107710:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107716:	05 00 00 00 80       	add    $0x80000000,%eax
8010771b:	83 c8 07             	or     $0x7,%eax
8010771e:	89 c2                	mov    %eax,%edx
80107720:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107723:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107725:	8b 45 0c             	mov    0xc(%ebp),%eax
80107728:	c1 e8 0c             	shr    $0xc,%eax
8010772b:	25 ff 03 00 00       	and    $0x3ff,%eax
80107730:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773a:	01 d0                	add    %edx,%eax
}
8010773c:	c9                   	leave
8010773d:	c3                   	ret

8010773e <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
/*static 전역에서 사용해야 함*/ int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010773e:	f3 0f 1e fb          	endbr32
80107742:	55                   	push   %ebp
80107743:	89 e5                	mov    %esp,%ebp
80107745:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107748:	8b 45 0c             	mov    0xc(%ebp),%eax
8010774b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107750:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107753:	8b 55 0c             	mov    0xc(%ebp),%edx
80107756:	8b 45 10             	mov    0x10(%ebp),%eax
80107759:	01 d0                	add    %edx,%eax
8010775b:	83 e8 01             	sub    $0x1,%eax
8010775e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107763:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107766:	83 ec 04             	sub    $0x4,%esp
80107769:	6a 01                	push   $0x1
8010776b:	ff 75 f4             	push   -0xc(%ebp)
8010776e:	ff 75 08             	push   0x8(%ebp)
80107771:	e8 2e ff ff ff       	call   801076a4 <walkpgdir>
80107776:	83 c4 10             	add    $0x10,%esp
80107779:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010777c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107780:	75 07                	jne    80107789 <mappages+0x4b>
      return -1;
80107782:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107787:	eb 47                	jmp    801077d0 <mappages+0x92>
    if(*pte & PTE_P)
80107789:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010778c:	8b 00                	mov    (%eax),%eax
8010778e:	83 e0 01             	and    $0x1,%eax
80107791:	85 c0                	test   %eax,%eax
80107793:	74 0d                	je     801077a2 <mappages+0x64>
      panic("remap");
80107795:	83 ec 0c             	sub    $0xc,%esp
80107798:	68 40 ad 10 80       	push   $0x8010ad40
8010779d:	e8 23 8e ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
801077a2:	8b 45 18             	mov    0x18(%ebp),%eax
801077a5:	0b 45 14             	or     0x14(%ebp),%eax
801077a8:	83 c8 01             	or     $0x1,%eax
801077ab:	89 c2                	mov    %eax,%edx
801077ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801077b0:	89 10                	mov    %edx,(%eax)
    if(a == last)
801077b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801077b8:	74 10                	je     801077ca <mappages+0x8c>
      break;
    a += PGSIZE;
801077ba:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801077c1:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801077c8:	eb 9c                	jmp    80107766 <mappages+0x28>
      break;
801077ca:	90                   	nop
  }
  return 0;
801077cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801077d0:	c9                   	leave
801077d1:	c3                   	ret

801077d2 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801077d2:	f3 0f 1e fb          	endbr32
801077d6:	55                   	push   %ebp
801077d7:	89 e5                	mov    %esp,%ebp
801077d9:	53                   	push   %ebx
801077da:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801077dd:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801077e4:	a1 8c 80 19 80       	mov    0x8019808c,%eax
801077e9:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801077ee:	29 c2                	sub    %eax,%edx
801077f0:	89 d0                	mov    %edx,%eax
801077f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
801077f5:	a1 84 80 19 80       	mov    0x80198084,%eax
801077fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801077fd:	8b 15 84 80 19 80    	mov    0x80198084,%edx
80107803:	a1 8c 80 19 80       	mov    0x8019808c,%eax
80107808:	01 d0                	add    %edx,%eax
8010780a:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010780d:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107817:	83 c0 30             	add    $0x30,%eax
8010781a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010781d:	89 10                	mov    %edx,(%eax)
8010781f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107822:	89 50 04             	mov    %edx,0x4(%eax)
80107825:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107828:	89 50 08             	mov    %edx,0x8(%eax)
8010782b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010782e:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107831:	e8 99 b0 ff ff       	call   801028cf <kalloc>
80107836:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107839:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010783d:	75 07                	jne    80107846 <setupkvm+0x74>
    return 0;
8010783f:	b8 00 00 00 00       	mov    $0x0,%eax
80107844:	eb 78                	jmp    801078be <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
80107846:	83 ec 04             	sub    $0x4,%esp
80107849:	68 00 10 00 00       	push   $0x1000
8010784e:	6a 00                	push   $0x0
80107850:	ff 75 f0             	push   -0x10(%ebp)
80107853:	e8 fa d4 ff ff       	call   80104d52 <memset>
80107858:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010785b:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107862:	eb 4e                	jmp    801078b2 <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107864:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107867:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010786a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786d:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107873:	8b 58 08             	mov    0x8(%eax),%ebx
80107876:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107879:	8b 40 04             	mov    0x4(%eax),%eax
8010787c:	29 c3                	sub    %eax,%ebx
8010787e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107881:	8b 00                	mov    (%eax),%eax
80107883:	83 ec 0c             	sub    $0xc,%esp
80107886:	51                   	push   %ecx
80107887:	52                   	push   %edx
80107888:	53                   	push   %ebx
80107889:	50                   	push   %eax
8010788a:	ff 75 f0             	push   -0x10(%ebp)
8010788d:	e8 ac fe ff ff       	call   8010773e <mappages>
80107892:	83 c4 20             	add    $0x20,%esp
80107895:	85 c0                	test   %eax,%eax
80107897:	79 15                	jns    801078ae <setupkvm+0xdc>
      freevm(pgdir);
80107899:	83 ec 0c             	sub    $0xc,%esp
8010789c:	ff 75 f0             	push   -0x10(%ebp)
8010789f:	e8 37 05 00 00       	call   80107ddb <freevm>
801078a4:	83 c4 10             	add    $0x10,%esp
      return 0;
801078a7:	b8 00 00 00 00       	mov    $0x0,%eax
801078ac:	eb 10                	jmp    801078be <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801078ae:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801078b2:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801078b9:	72 a9                	jb     80107864 <setupkvm+0x92>
    }
  return pgdir;
801078bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801078be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801078c1:	c9                   	leave
801078c2:	c3                   	ret

801078c3 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801078c3:	f3 0f 1e fb          	endbr32
801078c7:	55                   	push   %ebp
801078c8:	89 e5                	mov    %esp,%ebp
801078ca:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801078cd:	e8 00 ff ff ff       	call   801077d2 <setupkvm>
801078d2:	a3 84 7d 19 80       	mov    %eax,0x80197d84
  switchkvm();
801078d7:	e8 03 00 00 00       	call   801078df <switchkvm>
}
801078dc:	90                   	nop
801078dd:	c9                   	leave
801078de:	c3                   	ret

801078df <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801078df:	f3 0f 1e fb          	endbr32
801078e3:	55                   	push   %ebp
801078e4:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801078e6:	a1 84 7d 19 80       	mov    0x80197d84,%eax
801078eb:	05 00 00 00 80       	add    $0x80000000,%eax
801078f0:	50                   	push   %eax
801078f1:	e8 48 fa ff ff       	call   8010733e <lcr3>
801078f6:	83 c4 04             	add    $0x4,%esp
}
801078f9:	90                   	nop
801078fa:	c9                   	leave
801078fb:	c3                   	ret

801078fc <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801078fc:	f3 0f 1e fb          	endbr32
80107900:	55                   	push   %ebp
80107901:	89 e5                	mov    %esp,%ebp
80107903:	56                   	push   %esi
80107904:	53                   	push   %ebx
80107905:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107908:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010790c:	75 0d                	jne    8010791b <switchuvm+0x1f>
    panic("switchuvm: no process");
8010790e:	83 ec 0c             	sub    $0xc,%esp
80107911:	68 46 ad 10 80       	push   $0x8010ad46
80107916:	e8 aa 8c ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
8010791b:	8b 45 08             	mov    0x8(%ebp),%eax
8010791e:	8b 40 08             	mov    0x8(%eax),%eax
80107921:	85 c0                	test   %eax,%eax
80107923:	75 0d                	jne    80107932 <switchuvm+0x36>
    panic("switchuvm: no kstack");
80107925:	83 ec 0c             	sub    $0xc,%esp
80107928:	68 5c ad 10 80       	push   $0x8010ad5c
8010792d:	e8 93 8c ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
80107932:	8b 45 08             	mov    0x8(%ebp),%eax
80107935:	8b 40 04             	mov    0x4(%eax),%eax
80107938:	85 c0                	test   %eax,%eax
8010793a:	75 0d                	jne    80107949 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
8010793c:	83 ec 0c             	sub    $0xc,%esp
8010793f:	68 71 ad 10 80       	push   $0x8010ad71
80107944:	e8 7c 8c ff ff       	call   801005c5 <panic>

  pushcli();
80107949:	e8 f1 d2 ff ff       	call   80104c3f <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010794e:	e8 17 c2 ff ff       	call   80103b6a <mycpu>
80107953:	89 c3                	mov    %eax,%ebx
80107955:	e8 10 c2 ff ff       	call   80103b6a <mycpu>
8010795a:	83 c0 08             	add    $0x8,%eax
8010795d:	89 c6                	mov    %eax,%esi
8010795f:	e8 06 c2 ff ff       	call   80103b6a <mycpu>
80107964:	83 c0 08             	add    $0x8,%eax
80107967:	c1 e8 10             	shr    $0x10,%eax
8010796a:	88 45 f7             	mov    %al,-0x9(%ebp)
8010796d:	e8 f8 c1 ff ff       	call   80103b6a <mycpu>
80107972:	83 c0 08             	add    $0x8,%eax
80107975:	c1 e8 18             	shr    $0x18,%eax
80107978:	89 c2                	mov    %eax,%edx
8010797a:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107981:	67 00 
80107983:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010798a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
8010798e:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107994:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010799b:	83 e0 f0             	and    $0xfffffff0,%eax
8010799e:	83 c8 09             	or     $0x9,%eax
801079a1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079a7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079ae:	83 c8 10             	or     $0x10,%eax
801079b1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079b7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079be:	83 e0 9f             	and    $0xffffff9f,%eax
801079c1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079c7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079ce:	83 c8 80             	or     $0xffffff80,%eax
801079d1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079d7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079de:	83 e0 f0             	and    $0xfffffff0,%eax
801079e1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079e7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079ee:	83 e0 ef             	and    $0xffffffef,%eax
801079f1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079f7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079fe:	83 e0 df             	and    $0xffffffdf,%eax
80107a01:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a07:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a0e:	83 c8 40             	or     $0x40,%eax
80107a11:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a17:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a1e:	83 e0 7f             	and    $0x7f,%eax
80107a21:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a27:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107a2d:	e8 38 c1 ff ff       	call   80103b6a <mycpu>
80107a32:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a39:	83 e2 ef             	and    $0xffffffef,%edx
80107a3c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107a42:	e8 23 c1 ff ff       	call   80103b6a <mycpu>
80107a47:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80107a50:	8b 40 08             	mov    0x8(%eax),%eax
80107a53:	89 c3                	mov    %eax,%ebx
80107a55:	e8 10 c1 ff ff       	call   80103b6a <mycpu>
80107a5a:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107a60:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107a63:	e8 02 c1 ff ff       	call   80103b6a <mycpu>
80107a68:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107a6e:	83 ec 0c             	sub    $0xc,%esp
80107a71:	6a 28                	push   $0x28
80107a73:	e8 af f8 ff ff       	call   80107327 <ltr>
80107a78:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107a7b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a7e:	8b 40 04             	mov    0x4(%eax),%eax
80107a81:	05 00 00 00 80       	add    $0x80000000,%eax
80107a86:	83 ec 0c             	sub    $0xc,%esp
80107a89:	50                   	push   %eax
80107a8a:	e8 af f8 ff ff       	call   8010733e <lcr3>
80107a8f:	83 c4 10             	add    $0x10,%esp
  popcli();
80107a92:	e8 f9 d1 ff ff       	call   80104c90 <popcli>
}
80107a97:	90                   	nop
80107a98:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107a9b:	5b                   	pop    %ebx
80107a9c:	5e                   	pop    %esi
80107a9d:	5d                   	pop    %ebp
80107a9e:	c3                   	ret

80107a9f <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107a9f:	f3 0f 1e fb          	endbr32
80107aa3:	55                   	push   %ebp
80107aa4:	89 e5                	mov    %esp,%ebp
80107aa6:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107aa9:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107ab0:	76 0d                	jbe    80107abf <inituvm+0x20>
    panic("inituvm: more than a page");
80107ab2:	83 ec 0c             	sub    $0xc,%esp
80107ab5:	68 85 ad 10 80       	push   $0x8010ad85
80107aba:	e8 06 8b ff ff       	call   801005c5 <panic>
  mem = kalloc();
80107abf:	e8 0b ae ff ff       	call   801028cf <kalloc>
80107ac4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107ac7:	83 ec 04             	sub    $0x4,%esp
80107aca:	68 00 10 00 00       	push   $0x1000
80107acf:	6a 00                	push   $0x0
80107ad1:	ff 75 f4             	push   -0xc(%ebp)
80107ad4:	e8 79 d2 ff ff       	call   80104d52 <memset>
80107ad9:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adf:	05 00 00 00 80       	add    $0x80000000,%eax
80107ae4:	83 ec 0c             	sub    $0xc,%esp
80107ae7:	6a 06                	push   $0x6
80107ae9:	50                   	push   %eax
80107aea:	68 00 10 00 00       	push   $0x1000
80107aef:	6a 00                	push   $0x0
80107af1:	ff 75 08             	push   0x8(%ebp)
80107af4:	e8 45 fc ff ff       	call   8010773e <mappages>
80107af9:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107afc:	83 ec 04             	sub    $0x4,%esp
80107aff:	ff 75 10             	push   0x10(%ebp)
80107b02:	ff 75 0c             	push   0xc(%ebp)
80107b05:	ff 75 f4             	push   -0xc(%ebp)
80107b08:	e8 0c d3 ff ff       	call   80104e19 <memmove>
80107b0d:	83 c4 10             	add    $0x10,%esp
}
80107b10:	90                   	nop
80107b11:	c9                   	leave
80107b12:	c3                   	ret

80107b13 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107b13:	f3 0f 1e fb          	endbr32
80107b17:	55                   	push   %ebp
80107b18:	89 e5                	mov    %esp,%ebp
80107b1a:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b20:	25 ff 0f 00 00       	and    $0xfff,%eax
80107b25:	85 c0                	test   %eax,%eax
80107b27:	74 0d                	je     80107b36 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80107b29:	83 ec 0c             	sub    $0xc,%esp
80107b2c:	68 a0 ad 10 80       	push   $0x8010ada0
80107b31:	e8 8f 8a ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107b36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b3d:	e9 8f 00 00 00       	jmp    80107bd1 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107b42:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b48:	01 d0                	add    %edx,%eax
80107b4a:	83 ec 04             	sub    $0x4,%esp
80107b4d:	6a 00                	push   $0x0
80107b4f:	50                   	push   %eax
80107b50:	ff 75 08             	push   0x8(%ebp)
80107b53:	e8 4c fb ff ff       	call   801076a4 <walkpgdir>
80107b58:	83 c4 10             	add    $0x10,%esp
80107b5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b5e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b62:	75 0d                	jne    80107b71 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107b64:	83 ec 0c             	sub    $0xc,%esp
80107b67:	68 c3 ad 10 80       	push   $0x8010adc3
80107b6c:	e8 54 8a ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80107b71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b74:	8b 00                	mov    (%eax),%eax
80107b76:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b7b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107b7e:	8b 45 18             	mov    0x18(%ebp),%eax
80107b81:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b84:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107b89:	77 0b                	ja     80107b96 <loaduvm+0x83>
      n = sz - i;
80107b8b:	8b 45 18             	mov    0x18(%ebp),%eax
80107b8e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b91:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b94:	eb 07                	jmp    80107b9d <loaduvm+0x8a>
    else
      n = PGSIZE;
80107b96:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107b9d:	8b 55 14             	mov    0x14(%ebp),%edx
80107ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba3:	01 d0                	add    %edx,%eax
80107ba5:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107ba8:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107bae:	ff 75 f0             	push   -0x10(%ebp)
80107bb1:	50                   	push   %eax
80107bb2:	52                   	push   %edx
80107bb3:	ff 75 10             	push   0x10(%ebp)
80107bb6:	e8 06 a4 ff ff       	call   80101fc1 <readi>
80107bbb:	83 c4 10             	add    $0x10,%esp
80107bbe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107bc1:	74 07                	je     80107bca <loaduvm+0xb7>
      return -1;
80107bc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bc8:	eb 18                	jmp    80107be2 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80107bca:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd4:	3b 45 18             	cmp    0x18(%ebp),%eax
80107bd7:	0f 82 65 ff ff ff    	jb     80107b42 <loaduvm+0x2f>
  }
  return 0;
80107bdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107be2:	c9                   	leave
80107be3:	c3                   	ret

80107be4 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107be4:	f3 0f 1e fb          	endbr32
80107be8:	55                   	push   %ebp
80107be9:	89 e5                	mov    %esp,%ebp
80107beb:	83 ec 18             	sub    $0x18,%esp
  cprintf("[allocuvm] in \n");
80107bee:	83 ec 0c             	sub    $0xc,%esp
80107bf1:	68 e1 ad 10 80       	push   $0x8010ade1
80107bf6:	e8 11 88 ff ff       	call   8010040c <cprintf>
80107bfb:	83 c4 10             	add    $0x10,%esp
  cprintf("[allocuvm] oldsz %x newsz %x\n",oldsz, newsz);
80107bfe:	83 ec 04             	sub    $0x4,%esp
80107c01:	ff 75 10             	push   0x10(%ebp)
80107c04:	ff 75 0c             	push   0xc(%ebp)
80107c07:	68 f1 ad 10 80       	push   $0x8010adf1
80107c0c:	e8 fb 87 ff ff       	call   8010040c <cprintf>
80107c11:	83 c4 10             	add    $0x10,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107c14:	8b 45 10             	mov    0x10(%ebp),%eax
80107c17:	85 c0                	test   %eax,%eax
80107c19:	79 0a                	jns    80107c25 <allocuvm+0x41>
    return 0;
80107c1b:	b8 00 00 00 00       	mov    $0x0,%eax
80107c20:	e9 ec 00 00 00       	jmp    80107d11 <allocuvm+0x12d>
  if(newsz < oldsz)
80107c25:	8b 45 10             	mov    0x10(%ebp),%eax
80107c28:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107c2b:	73 08                	jae    80107c35 <allocuvm+0x51>
    return oldsz;
80107c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c30:	e9 dc 00 00 00       	jmp    80107d11 <allocuvm+0x12d>

  a = PGROUNDUP(oldsz);
80107c35:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c38:	05 ff 0f 00 00       	add    $0xfff,%eax
80107c3d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c42:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107c45:	e9 b8 00 00 00       	jmp    80107d02 <allocuvm+0x11e>
    mem = kalloc();
80107c4a:	e8 80 ac ff ff       	call   801028cf <kalloc>
80107c4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107c52:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c56:	75 2e                	jne    80107c86 <allocuvm+0xa2>
      cprintf("allocuvm out of memory\n");
80107c58:	83 ec 0c             	sub    $0xc,%esp
80107c5b:	68 0f ae 10 80       	push   $0x8010ae0f
80107c60:	e8 a7 87 ff ff       	call   8010040c <cprintf>
80107c65:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107c68:	83 ec 04             	sub    $0x4,%esp
80107c6b:	ff 75 0c             	push   0xc(%ebp)
80107c6e:	ff 75 10             	push   0x10(%ebp)
80107c71:	ff 75 08             	push   0x8(%ebp)
80107c74:	e8 9a 00 00 00       	call   80107d13 <deallocuvm>
80107c79:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c7c:	b8 00 00 00 00       	mov    $0x0,%eax
80107c81:	e9 8b 00 00 00       	jmp    80107d11 <allocuvm+0x12d>
    }
    memset(mem, 0, PGSIZE);
80107c86:	83 ec 04             	sub    $0x4,%esp
80107c89:	68 00 10 00 00       	push   $0x1000
80107c8e:	6a 00                	push   $0x0
80107c90:	ff 75 f0             	push   -0x10(%ebp)
80107c93:	e8 ba d0 ff ff       	call   80104d52 <memset>
80107c98:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107c9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c9e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca7:	83 ec 0c             	sub    $0xc,%esp
80107caa:	6a 06                	push   $0x6
80107cac:	52                   	push   %edx
80107cad:	68 00 10 00 00       	push   $0x1000
80107cb2:	50                   	push   %eax
80107cb3:	ff 75 08             	push   0x8(%ebp)
80107cb6:	e8 83 fa ff ff       	call   8010773e <mappages>
80107cbb:	83 c4 20             	add    $0x20,%esp
80107cbe:	85 c0                	test   %eax,%eax
80107cc0:	79 39                	jns    80107cfb <allocuvm+0x117>
      cprintf("allocuvm out of memory (2)\n");
80107cc2:	83 ec 0c             	sub    $0xc,%esp
80107cc5:	68 27 ae 10 80       	push   $0x8010ae27
80107cca:	e8 3d 87 ff ff       	call   8010040c <cprintf>
80107ccf:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107cd2:	83 ec 04             	sub    $0x4,%esp
80107cd5:	ff 75 0c             	push   0xc(%ebp)
80107cd8:	ff 75 10             	push   0x10(%ebp)
80107cdb:	ff 75 08             	push   0x8(%ebp)
80107cde:	e8 30 00 00 00       	call   80107d13 <deallocuvm>
80107ce3:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107ce6:	83 ec 0c             	sub    $0xc,%esp
80107ce9:	ff 75 f0             	push   -0x10(%ebp)
80107cec:	e8 40 ab ff ff       	call   80102831 <kfree>
80107cf1:	83 c4 10             	add    $0x10,%esp
      return 0;
80107cf4:	b8 00 00 00 00       	mov    $0x0,%eax
80107cf9:	eb 16                	jmp    80107d11 <allocuvm+0x12d>
  for(; a < newsz; a += PGSIZE){
80107cfb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d05:	3b 45 10             	cmp    0x10(%ebp),%eax
80107d08:	0f 82 3c ff ff ff    	jb     80107c4a <allocuvm+0x66>
    }
  }
  return newsz;
80107d0e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107d11:	c9                   	leave
80107d12:	c3                   	ret

80107d13 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d13:	f3 0f 1e fb          	endbr32
80107d17:	55                   	push   %ebp
80107d18:	89 e5                	mov    %esp,%ebp
80107d1a:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107d1d:	8b 45 10             	mov    0x10(%ebp),%eax
80107d20:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d23:	72 08                	jb     80107d2d <deallocuvm+0x1a>
    return oldsz;
80107d25:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d28:	e9 ac 00 00 00       	jmp    80107dd9 <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80107d2d:	8b 45 10             	mov    0x10(%ebp),%eax
80107d30:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d35:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107d3d:	e9 88 00 00 00       	jmp    80107dca <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d45:	83 ec 04             	sub    $0x4,%esp
80107d48:	6a 00                	push   $0x0
80107d4a:	50                   	push   %eax
80107d4b:	ff 75 08             	push   0x8(%ebp)
80107d4e:	e8 51 f9 ff ff       	call   801076a4 <walkpgdir>
80107d53:	83 c4 10             	add    $0x10,%esp
80107d56:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107d59:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d5d:	75 16                	jne    80107d75 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d62:	c1 e8 16             	shr    $0x16,%eax
80107d65:	83 c0 01             	add    $0x1,%eax
80107d68:	c1 e0 16             	shl    $0x16,%eax
80107d6b:	2d 00 10 00 00       	sub    $0x1000,%eax
80107d70:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d73:	eb 4e                	jmp    80107dc3 <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80107d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d78:	8b 00                	mov    (%eax),%eax
80107d7a:	83 e0 01             	and    $0x1,%eax
80107d7d:	85 c0                	test   %eax,%eax
80107d7f:	74 42                	je     80107dc3 <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80107d81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d84:	8b 00                	mov    (%eax),%eax
80107d86:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107d8e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d92:	75 0d                	jne    80107da1 <deallocuvm+0x8e>
        panic("kfree");
80107d94:	83 ec 0c             	sub    $0xc,%esp
80107d97:	68 43 ae 10 80       	push   $0x8010ae43
80107d9c:	e8 24 88 ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
80107da1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107da4:	05 00 00 00 80       	add    $0x80000000,%eax
80107da9:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107dac:	83 ec 0c             	sub    $0xc,%esp
80107daf:	ff 75 e8             	push   -0x18(%ebp)
80107db2:	e8 7a aa ff ff       	call   80102831 <kfree>
80107db7:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dbd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107dc3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcd:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107dd0:	0f 82 6c ff ff ff    	jb     80107d42 <deallocuvm+0x2f>
    }
  }
  return newsz;
80107dd6:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107dd9:	c9                   	leave
80107dda:	c3                   	ret

80107ddb <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107ddb:	f3 0f 1e fb          	endbr32
80107ddf:	55                   	push   %ebp
80107de0:	89 e5                	mov    %esp,%ebp
80107de2:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107de5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107de9:	75 0d                	jne    80107df8 <freevm+0x1d>
    panic("freevm: no pgdir");
80107deb:	83 ec 0c             	sub    $0xc,%esp
80107dee:	68 49 ae 10 80       	push   $0x8010ae49
80107df3:	e8 cd 87 ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107df8:	83 ec 04             	sub    $0x4,%esp
80107dfb:	6a 00                	push   $0x0
80107dfd:	68 00 00 00 80       	push   $0x80000000
80107e02:	ff 75 08             	push   0x8(%ebp)
80107e05:	e8 09 ff ff ff       	call   80107d13 <deallocuvm>
80107e0a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e0d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e14:	eb 48                	jmp    80107e5e <freevm+0x83>
    if(pgdir[i] & PTE_P){
80107e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e20:	8b 45 08             	mov    0x8(%ebp),%eax
80107e23:	01 d0                	add    %edx,%eax
80107e25:	8b 00                	mov    (%eax),%eax
80107e27:	83 e0 01             	and    $0x1,%eax
80107e2a:	85 c0                	test   %eax,%eax
80107e2c:	74 2c                	je     80107e5a <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e31:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e38:	8b 45 08             	mov    0x8(%ebp),%eax
80107e3b:	01 d0                	add    %edx,%eax
80107e3d:	8b 00                	mov    (%eax),%eax
80107e3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e44:	05 00 00 00 80       	add    $0x80000000,%eax
80107e49:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107e4c:	83 ec 0c             	sub    $0xc,%esp
80107e4f:	ff 75 f0             	push   -0x10(%ebp)
80107e52:	e8 da a9 ff ff       	call   80102831 <kfree>
80107e57:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e5a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e5e:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107e65:	76 af                	jbe    80107e16 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80107e67:	83 ec 0c             	sub    $0xc,%esp
80107e6a:	ff 75 08             	push   0x8(%ebp)
80107e6d:	e8 bf a9 ff ff       	call   80102831 <kfree>
80107e72:	83 c4 10             	add    $0x10,%esp
}
80107e75:	90                   	nop
80107e76:	c9                   	leave
80107e77:	c3                   	ret

80107e78 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107e78:	f3 0f 1e fb          	endbr32
80107e7c:	55                   	push   %ebp
80107e7d:	89 e5                	mov    %esp,%ebp
80107e7f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107e82:	83 ec 04             	sub    $0x4,%esp
80107e85:	6a 00                	push   $0x0
80107e87:	ff 75 0c             	push   0xc(%ebp)
80107e8a:	ff 75 08             	push   0x8(%ebp)
80107e8d:	e8 12 f8 ff ff       	call   801076a4 <walkpgdir>
80107e92:	83 c4 10             	add    $0x10,%esp
80107e95:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107e98:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e9c:	75 0d                	jne    80107eab <clearpteu+0x33>
    panic("clearpteu");
80107e9e:	83 ec 0c             	sub    $0xc,%esp
80107ea1:	68 5a ae 10 80       	push   $0x8010ae5a
80107ea6:	e8 1a 87 ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
80107eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eae:	8b 00                	mov    (%eax),%eax
80107eb0:	83 e0 fb             	and    $0xfffffffb,%eax
80107eb3:	89 c2                	mov    %eax,%edx
80107eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb8:	89 10                	mov    %edx,(%eax)
}
80107eba:	90                   	nop
80107ebb:	c9                   	leave
80107ebc:	c3                   	ret

80107ebd <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107ebd:	f3 0f 1e fb          	endbr32
80107ec1:	55                   	push   %ebp
80107ec2:	89 e5                	mov    %esp,%ebp
80107ec4:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;
  
  if((d = setupkvm()) == 0)
80107ec7:	e8 06 f9 ff ff       	call   801077d2 <setupkvm>
80107ecc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ecf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ed3:	75 0a                	jne    80107edf <copyuvm+0x22>
    return 0;
80107ed5:	b8 00 00 00 00       	mov    $0x0,%eax
80107eda:	e9 01 01 00 00       	jmp    80107fe0 <copyuvm+0x123>
    // 스택을 힙 영역으로 옮겼으니 위에서 부터 내려와야 한다.
    // 힙 영역까지의 페이지 복사
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107edf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ee6:	e9 be 00 00 00       	jmp    80107fa9 <copyuvm+0xec>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eee:	83 ec 04             	sub    $0x4,%esp
80107ef1:	6a 00                	push   $0x0
80107ef3:	50                   	push   %eax
80107ef4:	ff 75 08             	push   0x8(%ebp)
80107ef7:	e8 a8 f7 ff ff       	call   801076a4 <walkpgdir>
80107efc:	83 c4 10             	add    $0x10,%esp
80107eff:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f02:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f06:	0f 84 92 00 00 00    	je     80107f9e <copyuvm+0xe1>
      continue;
    if(!(*pte & PTE_P)){
80107f0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f0f:	8b 00                	mov    (%eax),%eax
80107f11:	83 e0 01             	and    $0x1,%eax
80107f14:	85 c0                	test   %eax,%eax
80107f16:	0f 84 85 00 00 00    	je     80107fa1 <copyuvm+0xe4>
      continue;
    }
    cprintf("[copyuvm] i %x\n",i);
80107f1c:	83 ec 08             	sub    $0x8,%esp
80107f1f:	ff 75 f4             	push   -0xc(%ebp)
80107f22:	68 64 ae 10 80       	push   $0x8010ae64
80107f27:	e8 e0 84 ff ff       	call   8010040c <cprintf>
80107f2c:	83 c4 10             	add    $0x10,%esp
    pa = PTE_ADDR(*pte);
80107f2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f32:	8b 00                	mov    (%eax),%eax
80107f34:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f39:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107f3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f3f:	8b 00                	mov    (%eax),%eax
80107f41:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107f49:	e8 81 a9 ff ff       	call   801028cf <kalloc>
80107f4e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107f51:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107f55:	74 72                	je     80107fc9 <copyuvm+0x10c>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107f57:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f5a:	05 00 00 00 80       	add    $0x80000000,%eax
80107f5f:	83 ec 04             	sub    $0x4,%esp
80107f62:	68 00 10 00 00       	push   $0x1000
80107f67:	50                   	push   %eax
80107f68:	ff 75 e0             	push   -0x20(%ebp)
80107f6b:	e8 a9 ce ff ff       	call   80104e19 <memmove>
80107f70:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107f73:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107f76:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107f79:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f82:	83 ec 0c             	sub    $0xc,%esp
80107f85:	52                   	push   %edx
80107f86:	51                   	push   %ecx
80107f87:	68 00 10 00 00       	push   $0x1000
80107f8c:	50                   	push   %eax
80107f8d:	ff 75 f0             	push   -0x10(%ebp)
80107f90:	e8 a9 f7 ff ff       	call   8010773e <mappages>
80107f95:	83 c4 20             	add    $0x20,%esp
80107f98:	85 c0                	test   %eax,%eax
80107f9a:	78 30                	js     80107fcc <copyuvm+0x10f>
80107f9c:	eb 04                	jmp    80107fa2 <copyuvm+0xe5>
      continue;
80107f9e:	90                   	nop
80107f9f:	eb 01                	jmp    80107fa2 <copyuvm+0xe5>
      continue;
80107fa1:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107fa2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fac:	85 c0                	test   %eax,%eax
80107fae:	0f 89 37 ff ff ff    	jns    80107eeb <copyuvm+0x2e>
      goto bad;
  }  

  cprintf("[copyuvm] complete\n");
80107fb4:	83 ec 0c             	sub    $0xc,%esp
80107fb7:	68 74 ae 10 80       	push   $0x8010ae74
80107fbc:	e8 4b 84 ff ff       	call   8010040c <cprintf>
80107fc1:	83 c4 10             	add    $0x10,%esp
  return d;
80107fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fc7:	eb 17                	jmp    80107fe0 <copyuvm+0x123>
      goto bad;
80107fc9:	90                   	nop
80107fca:	eb 01                	jmp    80107fcd <copyuvm+0x110>
      goto bad;
80107fcc:	90                   	nop

bad:
  freevm(d);
80107fcd:	83 ec 0c             	sub    $0xc,%esp
80107fd0:	ff 75 f0             	push   -0x10(%ebp)
80107fd3:	e8 03 fe ff ff       	call   80107ddb <freevm>
80107fd8:	83 c4 10             	add    $0x10,%esp
  return 0;
80107fdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107fe0:	c9                   	leave
80107fe1:	c3                   	ret

80107fe2 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107fe2:	f3 0f 1e fb          	endbr32
80107fe6:	55                   	push   %ebp
80107fe7:	89 e5                	mov    %esp,%ebp
80107fe9:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107fec:	83 ec 04             	sub    $0x4,%esp
80107fef:	6a 00                	push   $0x0
80107ff1:	ff 75 0c             	push   0xc(%ebp)
80107ff4:	ff 75 08             	push   0x8(%ebp)
80107ff7:	e8 a8 f6 ff ff       	call   801076a4 <walkpgdir>
80107ffc:	83 c4 10             	add    $0x10,%esp
80107fff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108005:	8b 00                	mov    (%eax),%eax
80108007:	83 e0 01             	and    $0x1,%eax
8010800a:	85 c0                	test   %eax,%eax
8010800c:	75 07                	jne    80108015 <uva2ka+0x33>
    return 0;
8010800e:	b8 00 00 00 00       	mov    $0x0,%eax
80108013:	eb 22                	jmp    80108037 <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
80108015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108018:	8b 00                	mov    (%eax),%eax
8010801a:	83 e0 04             	and    $0x4,%eax
8010801d:	85 c0                	test   %eax,%eax
8010801f:	75 07                	jne    80108028 <uva2ka+0x46>
    return 0;
80108021:	b8 00 00 00 00       	mov    $0x0,%eax
80108026:	eb 0f                	jmp    80108037 <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
80108028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802b:	8b 00                	mov    (%eax),%eax
8010802d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108032:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108037:	c9                   	leave
80108038:	c3                   	ret

80108039 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108039:	f3 0f 1e fb          	endbr32
8010803d:	55                   	push   %ebp
8010803e:	89 e5                	mov    %esp,%ebp
80108040:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108043:	8b 45 10             	mov    0x10(%ebp),%eax
80108046:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108049:	eb 7f                	jmp    801080ca <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
8010804b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010804e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108053:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108056:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108059:	83 ec 08             	sub    $0x8,%esp
8010805c:	50                   	push   %eax
8010805d:	ff 75 08             	push   0x8(%ebp)
80108060:	e8 7d ff ff ff       	call   80107fe2 <uva2ka>
80108065:	83 c4 10             	add    $0x10,%esp
80108068:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010806b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010806f:	75 07                	jne    80108078 <copyout+0x3f>
      return -1;
80108071:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108076:	eb 61                	jmp    801080d9 <copyout+0xa0>
    n = PGSIZE - (va - va0);
80108078:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010807b:	2b 45 0c             	sub    0xc(%ebp),%eax
8010807e:	05 00 10 00 00       	add    $0x1000,%eax
80108083:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108086:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108089:	3b 45 14             	cmp    0x14(%ebp),%eax
8010808c:	76 06                	jbe    80108094 <copyout+0x5b>
      n = len;
8010808e:	8b 45 14             	mov    0x14(%ebp),%eax
80108091:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108094:	8b 45 0c             	mov    0xc(%ebp),%eax
80108097:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010809a:	89 c2                	mov    %eax,%edx
8010809c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010809f:	01 d0                	add    %edx,%eax
801080a1:	83 ec 04             	sub    $0x4,%esp
801080a4:	ff 75 f0             	push   -0x10(%ebp)
801080a7:	ff 75 f4             	push   -0xc(%ebp)
801080aa:	50                   	push   %eax
801080ab:	e8 69 cd ff ff       	call   80104e19 <memmove>
801080b0:	83 c4 10             	add    $0x10,%esp
    len -= n;
801080b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080b6:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801080b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080bc:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801080bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080c2:	05 00 10 00 00       	add    $0x1000,%eax
801080c7:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801080ca:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801080ce:	0f 85 77 ff ff ff    	jne    8010804b <copyout+0x12>
  }
  return 0;
801080d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080d9:	c9                   	leave
801080da:	c3                   	ret

801080db <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
801080db:	f3 0f 1e fb          	endbr32
801080df:	55                   	push   %ebp
801080e0:	89 e5                	mov    %esp,%ebp
801080e2:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801080e5:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
801080ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
801080ef:	8b 40 08             	mov    0x8(%eax),%eax
801080f2:	05 00 00 00 80       	add    $0x80000000,%eax
801080f7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
801080fa:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108101:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108104:	8b 40 24             	mov    0x24(%eax),%eax
80108107:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
8010810c:	c7 05 80 80 19 80 00 	movl   $0x0,0x80198080
80108113:	00 00 00 

  while(i<madt->len){
80108116:	90                   	nop
80108117:	e9 be 00 00 00       	jmp    801081da <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
8010811c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010811f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108122:	01 d0                	add    %edx,%eax
80108124:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108127:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010812a:	0f b6 00             	movzbl (%eax),%eax
8010812d:	0f b6 c0             	movzbl %al,%eax
80108130:	83 f8 05             	cmp    $0x5,%eax
80108133:	0f 87 a1 00 00 00    	ja     801081da <mpinit_uefi+0xff>
80108139:	8b 04 85 88 ae 10 80 	mov    -0x7fef5178(,%eax,4),%eax
80108140:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108143:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108146:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108149:	a1 80 80 19 80       	mov    0x80198080,%eax
8010814e:	83 f8 03             	cmp    $0x3,%eax
80108151:	7f 28                	jg     8010817b <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108153:	8b 15 80 80 19 80    	mov    0x80198080,%edx
80108159:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010815c:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108160:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80108166:	81 c2 c0 7d 19 80    	add    $0x80197dc0,%edx
8010816c:	88 02                	mov    %al,(%edx)
          ncpu++;
8010816e:	a1 80 80 19 80       	mov    0x80198080,%eax
80108173:	83 c0 01             	add    $0x1,%eax
80108176:	a3 80 80 19 80       	mov    %eax,0x80198080
        }
        i += lapic_entry->record_len;
8010817b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010817e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108182:	0f b6 c0             	movzbl %al,%eax
80108185:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108188:	eb 50                	jmp    801081da <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
8010818a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010818d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108190:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108193:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108197:	a2 a0 7d 19 80       	mov    %al,0x80197da0
        i += ioapic->record_len;
8010819c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010819f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801081a3:	0f b6 c0             	movzbl %al,%eax
801081a6:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801081a9:	eb 2f                	jmp    801081da <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801081ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801081b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081b4:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801081b8:	0f b6 c0             	movzbl %al,%eax
801081bb:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801081be:	eb 1a                	jmp    801081da <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801081c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801081c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081c9:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801081cd:	0f b6 c0             	movzbl %al,%eax
801081d0:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801081d3:	eb 05                	jmp    801081da <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
801081d5:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801081d9:	90                   	nop
  while(i<madt->len){
801081da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081dd:	8b 40 04             	mov    0x4(%eax),%eax
801081e0:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801081e3:	0f 82 33 ff ff ff    	jb     8010811c <mpinit_uefi+0x41>
    }
  }

}
801081e9:	90                   	nop
801081ea:	90                   	nop
801081eb:	c9                   	leave
801081ec:	c3                   	ret

801081ed <inb>:
{
801081ed:	55                   	push   %ebp
801081ee:	89 e5                	mov    %esp,%ebp
801081f0:	83 ec 14             	sub    $0x14,%esp
801081f3:	8b 45 08             	mov    0x8(%ebp),%eax
801081f6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801081fa:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801081fe:	89 c2                	mov    %eax,%edx
80108200:	ec                   	in     (%dx),%al
80108201:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108204:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108208:	c9                   	leave
80108209:	c3                   	ret

8010820a <outb>:
{
8010820a:	55                   	push   %ebp
8010820b:	89 e5                	mov    %esp,%ebp
8010820d:	83 ec 08             	sub    $0x8,%esp
80108210:	8b 45 08             	mov    0x8(%ebp),%eax
80108213:	8b 55 0c             	mov    0xc(%ebp),%edx
80108216:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010821a:	89 d0                	mov    %edx,%eax
8010821c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010821f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108223:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108227:	ee                   	out    %al,(%dx)
}
80108228:	90                   	nop
80108229:	c9                   	leave
8010822a:	c3                   	ret

8010822b <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
8010822b:	f3 0f 1e fb          	endbr32
8010822f:	55                   	push   %ebp
80108230:	89 e5                	mov    %esp,%ebp
80108232:	83 ec 28             	sub    $0x28,%esp
80108235:	8b 45 08             	mov    0x8(%ebp),%eax
80108238:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
8010823b:	6a 00                	push   $0x0
8010823d:	68 fa 03 00 00       	push   $0x3fa
80108242:	e8 c3 ff ff ff       	call   8010820a <outb>
80108247:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010824a:	68 80 00 00 00       	push   $0x80
8010824f:	68 fb 03 00 00       	push   $0x3fb
80108254:	e8 b1 ff ff ff       	call   8010820a <outb>
80108259:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010825c:	6a 0c                	push   $0xc
8010825e:	68 f8 03 00 00       	push   $0x3f8
80108263:	e8 a2 ff ff ff       	call   8010820a <outb>
80108268:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010826b:	6a 00                	push   $0x0
8010826d:	68 f9 03 00 00       	push   $0x3f9
80108272:	e8 93 ff ff ff       	call   8010820a <outb>
80108277:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010827a:	6a 03                	push   $0x3
8010827c:	68 fb 03 00 00       	push   $0x3fb
80108281:	e8 84 ff ff ff       	call   8010820a <outb>
80108286:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108289:	6a 00                	push   $0x0
8010828b:	68 fc 03 00 00       	push   $0x3fc
80108290:	e8 75 ff ff ff       	call   8010820a <outb>
80108295:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108298:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010829f:	eb 11                	jmp    801082b2 <uart_debug+0x87>
801082a1:	83 ec 0c             	sub    $0xc,%esp
801082a4:	6a 0a                	push   $0xa
801082a6:	e8 d6 a9 ff ff       	call   80102c81 <microdelay>
801082ab:	83 c4 10             	add    $0x10,%esp
801082ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801082b2:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801082b6:	7f 1a                	jg     801082d2 <uart_debug+0xa7>
801082b8:	83 ec 0c             	sub    $0xc,%esp
801082bb:	68 fd 03 00 00       	push   $0x3fd
801082c0:	e8 28 ff ff ff       	call   801081ed <inb>
801082c5:	83 c4 10             	add    $0x10,%esp
801082c8:	0f b6 c0             	movzbl %al,%eax
801082cb:	83 e0 20             	and    $0x20,%eax
801082ce:	85 c0                	test   %eax,%eax
801082d0:	74 cf                	je     801082a1 <uart_debug+0x76>
  outb(COM1+0, p);
801082d2:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801082d6:	0f b6 c0             	movzbl %al,%eax
801082d9:	83 ec 08             	sub    $0x8,%esp
801082dc:	50                   	push   %eax
801082dd:	68 f8 03 00 00       	push   $0x3f8
801082e2:	e8 23 ff ff ff       	call   8010820a <outb>
801082e7:	83 c4 10             	add    $0x10,%esp
}
801082ea:	90                   	nop
801082eb:	c9                   	leave
801082ec:	c3                   	ret

801082ed <uart_debugs>:

void uart_debugs(char *p){
801082ed:	f3 0f 1e fb          	endbr32
801082f1:	55                   	push   %ebp
801082f2:	89 e5                	mov    %esp,%ebp
801082f4:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801082f7:	eb 1b                	jmp    80108314 <uart_debugs+0x27>
    uart_debug(*p++);
801082f9:	8b 45 08             	mov    0x8(%ebp),%eax
801082fc:	8d 50 01             	lea    0x1(%eax),%edx
801082ff:	89 55 08             	mov    %edx,0x8(%ebp)
80108302:	0f b6 00             	movzbl (%eax),%eax
80108305:	0f be c0             	movsbl %al,%eax
80108308:	83 ec 0c             	sub    $0xc,%esp
8010830b:	50                   	push   %eax
8010830c:	e8 1a ff ff ff       	call   8010822b <uart_debug>
80108311:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108314:	8b 45 08             	mov    0x8(%ebp),%eax
80108317:	0f b6 00             	movzbl (%eax),%eax
8010831a:	84 c0                	test   %al,%al
8010831c:	75 db                	jne    801082f9 <uart_debugs+0xc>
  }
}
8010831e:	90                   	nop
8010831f:	90                   	nop
80108320:	c9                   	leave
80108321:	c3                   	ret

80108322 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108322:	f3 0f 1e fb          	endbr32
80108326:	55                   	push   %ebp
80108327:	89 e5                	mov    %esp,%ebp
80108329:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010832c:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108333:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108336:	8b 50 14             	mov    0x14(%eax),%edx
80108339:	8b 40 10             	mov    0x10(%eax),%eax
8010833c:	a3 84 80 19 80       	mov    %eax,0x80198084
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108341:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108344:	8b 50 1c             	mov    0x1c(%eax),%edx
80108347:	8b 40 18             	mov    0x18(%eax),%eax
8010834a:	a3 8c 80 19 80       	mov    %eax,0x8019808c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
8010834f:	a1 8c 80 19 80       	mov    0x8019808c,%eax
80108354:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108359:	29 c2                	sub    %eax,%edx
8010835b:	89 d0                	mov    %edx,%eax
8010835d:	a3 88 80 19 80       	mov    %eax,0x80198088
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108362:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108365:	8b 50 24             	mov    0x24(%eax),%edx
80108368:	8b 40 20             	mov    0x20(%eax),%eax
8010836b:	a3 90 80 19 80       	mov    %eax,0x80198090
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108370:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108373:	8b 50 2c             	mov    0x2c(%eax),%edx
80108376:	8b 40 28             	mov    0x28(%eax),%eax
80108379:	a3 94 80 19 80       	mov    %eax,0x80198094
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
8010837e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108381:	8b 50 34             	mov    0x34(%eax),%edx
80108384:	8b 40 30             	mov    0x30(%eax),%eax
80108387:	a3 98 80 19 80       	mov    %eax,0x80198098
}
8010838c:	90                   	nop
8010838d:	c9                   	leave
8010838e:	c3                   	ret

8010838f <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010838f:	f3 0f 1e fb          	endbr32
80108393:	55                   	push   %ebp
80108394:	89 e5                	mov    %esp,%ebp
80108396:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108399:	8b 15 98 80 19 80    	mov    0x80198098,%edx
8010839f:	8b 45 0c             	mov    0xc(%ebp),%eax
801083a2:	0f af d0             	imul   %eax,%edx
801083a5:	8b 45 08             	mov    0x8(%ebp),%eax
801083a8:	01 d0                	add    %edx,%eax
801083aa:	c1 e0 02             	shl    $0x2,%eax
801083ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801083b0:	8b 15 88 80 19 80    	mov    0x80198088,%edx
801083b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083b9:	01 d0                	add    %edx,%eax
801083bb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801083be:	8b 45 10             	mov    0x10(%ebp),%eax
801083c1:	0f b6 10             	movzbl (%eax),%edx
801083c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083c7:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801083c9:	8b 45 10             	mov    0x10(%ebp),%eax
801083cc:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801083d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083d3:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801083d6:	8b 45 10             	mov    0x10(%ebp),%eax
801083d9:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801083dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083e0:	88 50 02             	mov    %dl,0x2(%eax)
}
801083e3:	90                   	nop
801083e4:	c9                   	leave
801083e5:	c3                   	ret

801083e6 <graphic_scroll_up>:

void graphic_scroll_up(int height){
801083e6:	f3 0f 1e fb          	endbr32
801083ea:	55                   	push   %ebp
801083eb:	89 e5                	mov    %esp,%ebp
801083ed:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801083f0:	8b 15 98 80 19 80    	mov    0x80198098,%edx
801083f6:	8b 45 08             	mov    0x8(%ebp),%eax
801083f9:	0f af c2             	imul   %edx,%eax
801083fc:	c1 e0 02             	shl    $0x2,%eax
801083ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108402:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
80108408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010840b:	29 c2                	sub    %eax,%edx
8010840d:	89 d0                	mov    %edx,%eax
8010840f:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
80108415:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108418:	01 ca                	add    %ecx,%edx
8010841a:	89 d1                	mov    %edx,%ecx
8010841c:	8b 15 88 80 19 80    	mov    0x80198088,%edx
80108422:	83 ec 04             	sub    $0x4,%esp
80108425:	50                   	push   %eax
80108426:	51                   	push   %ecx
80108427:	52                   	push   %edx
80108428:	e8 ec c9 ff ff       	call   80104e19 <memmove>
8010842d:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108433:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
80108439:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
8010843f:	01 d1                	add    %edx,%ecx
80108441:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108444:	29 d1                	sub    %edx,%ecx
80108446:	89 ca                	mov    %ecx,%edx
80108448:	83 ec 04             	sub    $0x4,%esp
8010844b:	50                   	push   %eax
8010844c:	6a 00                	push   $0x0
8010844e:	52                   	push   %edx
8010844f:	e8 fe c8 ff ff       	call   80104d52 <memset>
80108454:	83 c4 10             	add    $0x10,%esp
}
80108457:	90                   	nop
80108458:	c9                   	leave
80108459:	c3                   	ret

8010845a <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
8010845a:	f3 0f 1e fb          	endbr32
8010845e:	55                   	push   %ebp
8010845f:	89 e5                	mov    %esp,%ebp
80108461:	53                   	push   %ebx
80108462:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108465:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010846c:	e9 b1 00 00 00       	jmp    80108522 <font_render+0xc8>
    for(int j=14;j>-1;j--){
80108471:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108478:	e9 97 00 00 00       	jmp    80108514 <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
8010847d:	8b 45 10             	mov    0x10(%ebp),%eax
80108480:	83 e8 20             	sub    $0x20,%eax
80108483:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108489:	01 d0                	add    %edx,%eax
8010848b:	0f b7 84 00 a0 ae 10 	movzwl -0x7fef5160(%eax,%eax,1),%eax
80108492:	80 
80108493:	0f b7 d0             	movzwl %ax,%edx
80108496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108499:	bb 01 00 00 00       	mov    $0x1,%ebx
8010849e:	89 c1                	mov    %eax,%ecx
801084a0:	d3 e3                	shl    %cl,%ebx
801084a2:	89 d8                	mov    %ebx,%eax
801084a4:	21 d0                	and    %edx,%eax
801084a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801084a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084ac:	ba 01 00 00 00       	mov    $0x1,%edx
801084b1:	89 c1                	mov    %eax,%ecx
801084b3:	d3 e2                	shl    %cl,%edx
801084b5:	89 d0                	mov    %edx,%eax
801084b7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801084ba:	75 2b                	jne    801084e7 <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801084bc:	8b 55 0c             	mov    0xc(%ebp),%edx
801084bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c2:	01 c2                	add    %eax,%edx
801084c4:	b8 0e 00 00 00       	mov    $0xe,%eax
801084c9:	2b 45 f0             	sub    -0x10(%ebp),%eax
801084cc:	89 c1                	mov    %eax,%ecx
801084ce:	8b 45 08             	mov    0x8(%ebp),%eax
801084d1:	01 c8                	add    %ecx,%eax
801084d3:	83 ec 04             	sub    $0x4,%esp
801084d6:	68 e0 f4 10 80       	push   $0x8010f4e0
801084db:	52                   	push   %edx
801084dc:	50                   	push   %eax
801084dd:	e8 ad fe ff ff       	call   8010838f <graphic_draw_pixel>
801084e2:	83 c4 10             	add    $0x10,%esp
801084e5:	eb 29                	jmp    80108510 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801084e7:	8b 55 0c             	mov    0xc(%ebp),%edx
801084ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ed:	01 c2                	add    %eax,%edx
801084ef:	b8 0e 00 00 00       	mov    $0xe,%eax
801084f4:	2b 45 f0             	sub    -0x10(%ebp),%eax
801084f7:	89 c1                	mov    %eax,%ecx
801084f9:	8b 45 08             	mov    0x8(%ebp),%eax
801084fc:	01 c8                	add    %ecx,%eax
801084fe:	83 ec 04             	sub    $0x4,%esp
80108501:	68 64 d0 18 80       	push   $0x8018d064
80108506:	52                   	push   %edx
80108507:	50                   	push   %eax
80108508:	e8 82 fe ff ff       	call   8010838f <graphic_draw_pixel>
8010850d:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108510:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108514:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108518:	0f 89 5f ff ff ff    	jns    8010847d <font_render+0x23>
  for(int i=0;i<30;i++){
8010851e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108522:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108526:	0f 8e 45 ff ff ff    	jle    80108471 <font_render+0x17>
      }
    }
  }
}
8010852c:	90                   	nop
8010852d:	90                   	nop
8010852e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108531:	c9                   	leave
80108532:	c3                   	ret

80108533 <font_render_string>:

void font_render_string(char *string,int row){
80108533:	f3 0f 1e fb          	endbr32
80108537:	55                   	push   %ebp
80108538:	89 e5                	mov    %esp,%ebp
8010853a:	53                   	push   %ebx
8010853b:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
8010853e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108545:	eb 33                	jmp    8010857a <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
80108547:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010854a:	8b 45 08             	mov    0x8(%ebp),%eax
8010854d:	01 d0                	add    %edx,%eax
8010854f:	0f b6 00             	movzbl (%eax),%eax
80108552:	0f be d8             	movsbl %al,%ebx
80108555:	8b 45 0c             	mov    0xc(%ebp),%eax
80108558:	6b c8 1e             	imul   $0x1e,%eax,%ecx
8010855b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010855e:	89 d0                	mov    %edx,%eax
80108560:	c1 e0 04             	shl    $0x4,%eax
80108563:	29 d0                	sub    %edx,%eax
80108565:	83 c0 02             	add    $0x2,%eax
80108568:	83 ec 04             	sub    $0x4,%esp
8010856b:	53                   	push   %ebx
8010856c:	51                   	push   %ecx
8010856d:	50                   	push   %eax
8010856e:	e8 e7 fe ff ff       	call   8010845a <font_render>
80108573:	83 c4 10             	add    $0x10,%esp
    i++;
80108576:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
8010857a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010857d:	8b 45 08             	mov    0x8(%ebp),%eax
80108580:	01 d0                	add    %edx,%eax
80108582:	0f b6 00             	movzbl (%eax),%eax
80108585:	84 c0                	test   %al,%al
80108587:	74 06                	je     8010858f <font_render_string+0x5c>
80108589:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
8010858d:	7e b8                	jle    80108547 <font_render_string+0x14>
  }
}
8010858f:	90                   	nop
80108590:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108593:	c9                   	leave
80108594:	c3                   	ret

80108595 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108595:	f3 0f 1e fb          	endbr32
80108599:	55                   	push   %ebp
8010859a:	89 e5                	mov    %esp,%ebp
8010859c:	53                   	push   %ebx
8010859d:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801085a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085a7:	eb 6b                	jmp    80108614 <pci_init+0x7f>
    for(int j=0;j<32;j++){
801085a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801085b0:	eb 58                	jmp    8010860a <pci_init+0x75>
      for(int k=0;k<8;k++){
801085b2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801085b9:	eb 45                	jmp    80108600 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
801085bb:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801085be:	8b 55 f0             	mov    -0x10(%ebp),%edx
801085c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c4:	83 ec 0c             	sub    $0xc,%esp
801085c7:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801085ca:	53                   	push   %ebx
801085cb:	6a 00                	push   $0x0
801085cd:	51                   	push   %ecx
801085ce:	52                   	push   %edx
801085cf:	50                   	push   %eax
801085d0:	e8 c0 00 00 00       	call   80108695 <pci_access_config>
801085d5:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801085d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085db:	0f b7 c0             	movzwl %ax,%eax
801085de:	3d ff ff 00 00       	cmp    $0xffff,%eax
801085e3:	74 17                	je     801085fc <pci_init+0x67>
        pci_init_device(i,j,k);
801085e5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801085e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801085eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ee:	83 ec 04             	sub    $0x4,%esp
801085f1:	51                   	push   %ecx
801085f2:	52                   	push   %edx
801085f3:	50                   	push   %eax
801085f4:	e8 4f 01 00 00       	call   80108748 <pci_init_device>
801085f9:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801085fc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108600:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108604:	7e b5                	jle    801085bb <pci_init+0x26>
    for(int j=0;j<32;j++){
80108606:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010860a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
8010860e:	7e a2                	jle    801085b2 <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108610:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108614:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010861b:	7e 8c                	jle    801085a9 <pci_init+0x14>
      }
      }
    }
  }
}
8010861d:	90                   	nop
8010861e:	90                   	nop
8010861f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108622:	c9                   	leave
80108623:	c3                   	ret

80108624 <pci_write_config>:

void pci_write_config(uint config){
80108624:	f3 0f 1e fb          	endbr32
80108628:	55                   	push   %ebp
80108629:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010862b:	8b 45 08             	mov    0x8(%ebp),%eax
8010862e:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108633:	89 c0                	mov    %eax,%eax
80108635:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108636:	90                   	nop
80108637:	5d                   	pop    %ebp
80108638:	c3                   	ret

80108639 <pci_write_data>:

void pci_write_data(uint config){
80108639:	f3 0f 1e fb          	endbr32
8010863d:	55                   	push   %ebp
8010863e:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108640:	8b 45 08             	mov    0x8(%ebp),%eax
80108643:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108648:	89 c0                	mov    %eax,%eax
8010864a:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010864b:	90                   	nop
8010864c:	5d                   	pop    %ebp
8010864d:	c3                   	ret

8010864e <pci_read_config>:
uint pci_read_config(){
8010864e:	f3 0f 1e fb          	endbr32
80108652:	55                   	push   %ebp
80108653:	89 e5                	mov    %esp,%ebp
80108655:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108658:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010865d:	ed                   	in     (%dx),%eax
8010865e:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108661:	83 ec 0c             	sub    $0xc,%esp
80108664:	68 c8 00 00 00       	push   $0xc8
80108669:	e8 13 a6 ff ff       	call   80102c81 <microdelay>
8010866e:	83 c4 10             	add    $0x10,%esp
  return data;
80108671:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108674:	c9                   	leave
80108675:	c3                   	ret

80108676 <pci_test>:


void pci_test(){
80108676:	f3 0f 1e fb          	endbr32
8010867a:	55                   	push   %ebp
8010867b:	89 e5                	mov    %esp,%ebp
8010867d:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108680:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108687:	ff 75 fc             	push   -0x4(%ebp)
8010868a:	e8 95 ff ff ff       	call   80108624 <pci_write_config>
8010868f:	83 c4 04             	add    $0x4,%esp
}
80108692:	90                   	nop
80108693:	c9                   	leave
80108694:	c3                   	ret

80108695 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108695:	f3 0f 1e fb          	endbr32
80108699:	55                   	push   %ebp
8010869a:	89 e5                	mov    %esp,%ebp
8010869c:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010869f:	8b 45 08             	mov    0x8(%ebp),%eax
801086a2:	c1 e0 10             	shl    $0x10,%eax
801086a5:	25 00 00 ff 00       	and    $0xff0000,%eax
801086aa:	89 c2                	mov    %eax,%edx
801086ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801086af:	c1 e0 0b             	shl    $0xb,%eax
801086b2:	0f b7 c0             	movzwl %ax,%eax
801086b5:	09 c2                	or     %eax,%edx
801086b7:	8b 45 10             	mov    0x10(%ebp),%eax
801086ba:	c1 e0 08             	shl    $0x8,%eax
801086bd:	25 00 07 00 00       	and    $0x700,%eax
801086c2:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801086c4:	8b 45 14             	mov    0x14(%ebp),%eax
801086c7:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801086cc:	09 d0                	or     %edx,%eax
801086ce:	0d 00 00 00 80       	or     $0x80000000,%eax
801086d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801086d6:	ff 75 f4             	push   -0xc(%ebp)
801086d9:	e8 46 ff ff ff       	call   80108624 <pci_write_config>
801086de:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801086e1:	e8 68 ff ff ff       	call   8010864e <pci_read_config>
801086e6:	8b 55 18             	mov    0x18(%ebp),%edx
801086e9:	89 02                	mov    %eax,(%edx)
}
801086eb:	90                   	nop
801086ec:	c9                   	leave
801086ed:	c3                   	ret

801086ee <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801086ee:	f3 0f 1e fb          	endbr32
801086f2:	55                   	push   %ebp
801086f3:	89 e5                	mov    %esp,%ebp
801086f5:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801086f8:	8b 45 08             	mov    0x8(%ebp),%eax
801086fb:	c1 e0 10             	shl    $0x10,%eax
801086fe:	25 00 00 ff 00       	and    $0xff0000,%eax
80108703:	89 c2                	mov    %eax,%edx
80108705:	8b 45 0c             	mov    0xc(%ebp),%eax
80108708:	c1 e0 0b             	shl    $0xb,%eax
8010870b:	0f b7 c0             	movzwl %ax,%eax
8010870e:	09 c2                	or     %eax,%edx
80108710:	8b 45 10             	mov    0x10(%ebp),%eax
80108713:	c1 e0 08             	shl    $0x8,%eax
80108716:	25 00 07 00 00       	and    $0x700,%eax
8010871b:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010871d:	8b 45 14             	mov    0x14(%ebp),%eax
80108720:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108725:	09 d0                	or     %edx,%eax
80108727:	0d 00 00 00 80       	or     $0x80000000,%eax
8010872c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
8010872f:	ff 75 fc             	push   -0x4(%ebp)
80108732:	e8 ed fe ff ff       	call   80108624 <pci_write_config>
80108737:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
8010873a:	ff 75 18             	push   0x18(%ebp)
8010873d:	e8 f7 fe ff ff       	call   80108639 <pci_write_data>
80108742:	83 c4 04             	add    $0x4,%esp
}
80108745:	90                   	nop
80108746:	c9                   	leave
80108747:	c3                   	ret

80108748 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108748:	f3 0f 1e fb          	endbr32
8010874c:	55                   	push   %ebp
8010874d:	89 e5                	mov    %esp,%ebp
8010874f:	53                   	push   %ebx
80108750:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108753:	8b 45 08             	mov    0x8(%ebp),%eax
80108756:	a2 9c 80 19 80       	mov    %al,0x8019809c
  dev.device_num = device_num;
8010875b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010875e:	a2 9d 80 19 80       	mov    %al,0x8019809d
  dev.function_num = function_num;
80108763:	8b 45 10             	mov    0x10(%ebp),%eax
80108766:	a2 9e 80 19 80       	mov    %al,0x8019809e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
8010876b:	ff 75 10             	push   0x10(%ebp)
8010876e:	ff 75 0c             	push   0xc(%ebp)
80108771:	ff 75 08             	push   0x8(%ebp)
80108774:	68 e4 c4 10 80       	push   $0x8010c4e4
80108779:	e8 8e 7c ff ff       	call   8010040c <cprintf>
8010877e:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108781:	83 ec 0c             	sub    $0xc,%esp
80108784:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108787:	50                   	push   %eax
80108788:	6a 00                	push   $0x0
8010878a:	ff 75 10             	push   0x10(%ebp)
8010878d:	ff 75 0c             	push   0xc(%ebp)
80108790:	ff 75 08             	push   0x8(%ebp)
80108793:	e8 fd fe ff ff       	call   80108695 <pci_access_config>
80108798:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
8010879b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010879e:	c1 e8 10             	shr    $0x10,%eax
801087a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
801087a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087a7:	25 ff ff 00 00       	and    $0xffff,%eax
801087ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
801087af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b2:	a3 a0 80 19 80       	mov    %eax,0x801980a0
  dev.vendor_id = vendor_id;
801087b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087ba:	a3 a4 80 19 80       	mov    %eax,0x801980a4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801087bf:	83 ec 04             	sub    $0x4,%esp
801087c2:	ff 75 f0             	push   -0x10(%ebp)
801087c5:	ff 75 f4             	push   -0xc(%ebp)
801087c8:	68 18 c5 10 80       	push   $0x8010c518
801087cd:	e8 3a 7c ff ff       	call   8010040c <cprintf>
801087d2:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801087d5:	83 ec 0c             	sub    $0xc,%esp
801087d8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087db:	50                   	push   %eax
801087dc:	6a 08                	push   $0x8
801087de:	ff 75 10             	push   0x10(%ebp)
801087e1:	ff 75 0c             	push   0xc(%ebp)
801087e4:	ff 75 08             	push   0x8(%ebp)
801087e7:	e8 a9 fe ff ff       	call   80108695 <pci_access_config>
801087ec:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801087ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087f2:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801087f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087f8:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801087fb:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801087fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108801:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108804:	0f b6 c0             	movzbl %al,%eax
80108807:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010880a:	c1 eb 18             	shr    $0x18,%ebx
8010880d:	83 ec 0c             	sub    $0xc,%esp
80108810:	51                   	push   %ecx
80108811:	52                   	push   %edx
80108812:	50                   	push   %eax
80108813:	53                   	push   %ebx
80108814:	68 3c c5 10 80       	push   $0x8010c53c
80108819:	e8 ee 7b ff ff       	call   8010040c <cprintf>
8010881e:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108821:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108824:	c1 e8 18             	shr    $0x18,%eax
80108827:	a2 a8 80 19 80       	mov    %al,0x801980a8
  dev.sub_class = (data>>16)&0xFF;
8010882c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010882f:	c1 e8 10             	shr    $0x10,%eax
80108832:	a2 a9 80 19 80       	mov    %al,0x801980a9
  dev.interface = (data>>8)&0xFF;
80108837:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010883a:	c1 e8 08             	shr    $0x8,%eax
8010883d:	a2 aa 80 19 80       	mov    %al,0x801980aa
  dev.revision_id = data&0xFF;
80108842:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108845:	a2 ab 80 19 80       	mov    %al,0x801980ab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
8010884a:	83 ec 0c             	sub    $0xc,%esp
8010884d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108850:	50                   	push   %eax
80108851:	6a 10                	push   $0x10
80108853:	ff 75 10             	push   0x10(%ebp)
80108856:	ff 75 0c             	push   0xc(%ebp)
80108859:	ff 75 08             	push   0x8(%ebp)
8010885c:	e8 34 fe ff ff       	call   80108695 <pci_access_config>
80108861:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108864:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108867:	a3 ac 80 19 80       	mov    %eax,0x801980ac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
8010886c:	83 ec 0c             	sub    $0xc,%esp
8010886f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108872:	50                   	push   %eax
80108873:	6a 14                	push   $0x14
80108875:	ff 75 10             	push   0x10(%ebp)
80108878:	ff 75 0c             	push   0xc(%ebp)
8010887b:	ff 75 08             	push   0x8(%ebp)
8010887e:	e8 12 fe ff ff       	call   80108695 <pci_access_config>
80108883:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108886:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108889:	a3 b0 80 19 80       	mov    %eax,0x801980b0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
8010888e:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108895:	75 5a                	jne    801088f1 <pci_init_device+0x1a9>
80108897:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
8010889e:	75 51                	jne    801088f1 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
801088a0:	83 ec 0c             	sub    $0xc,%esp
801088a3:	68 81 c5 10 80       	push   $0x8010c581
801088a8:	e8 5f 7b ff ff       	call   8010040c <cprintf>
801088ad:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801088b0:	83 ec 0c             	sub    $0xc,%esp
801088b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801088b6:	50                   	push   %eax
801088b7:	68 f0 00 00 00       	push   $0xf0
801088bc:	ff 75 10             	push   0x10(%ebp)
801088bf:	ff 75 0c             	push   0xc(%ebp)
801088c2:	ff 75 08             	push   0x8(%ebp)
801088c5:	e8 cb fd ff ff       	call   80108695 <pci_access_config>
801088ca:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801088cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088d0:	83 ec 08             	sub    $0x8,%esp
801088d3:	50                   	push   %eax
801088d4:	68 9b c5 10 80       	push   $0x8010c59b
801088d9:	e8 2e 7b ff ff       	call   8010040c <cprintf>
801088de:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801088e1:	83 ec 0c             	sub    $0xc,%esp
801088e4:	68 9c 80 19 80       	push   $0x8019809c
801088e9:	e8 09 00 00 00       	call   801088f7 <i8254_init>
801088ee:	83 c4 10             	add    $0x10,%esp
  }
}
801088f1:	90                   	nop
801088f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801088f5:	c9                   	leave
801088f6:	c3                   	ret

801088f7 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
801088f7:	f3 0f 1e fb          	endbr32
801088fb:	55                   	push   %ebp
801088fc:	89 e5                	mov    %esp,%ebp
801088fe:	53                   	push   %ebx
801088ff:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108902:	8b 45 08             	mov    0x8(%ebp),%eax
80108905:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108909:	0f b6 c8             	movzbl %al,%ecx
8010890c:	8b 45 08             	mov    0x8(%ebp),%eax
8010890f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108913:	0f b6 d0             	movzbl %al,%edx
80108916:	8b 45 08             	mov    0x8(%ebp),%eax
80108919:	0f b6 00             	movzbl (%eax),%eax
8010891c:	0f b6 c0             	movzbl %al,%eax
8010891f:	83 ec 0c             	sub    $0xc,%esp
80108922:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108925:	53                   	push   %ebx
80108926:	6a 04                	push   $0x4
80108928:	51                   	push   %ecx
80108929:	52                   	push   %edx
8010892a:	50                   	push   %eax
8010892b:	e8 65 fd ff ff       	call   80108695 <pci_access_config>
80108930:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108933:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108936:	83 c8 04             	or     $0x4,%eax
80108939:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
8010893c:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010893f:	8b 45 08             	mov    0x8(%ebp),%eax
80108942:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108946:	0f b6 c8             	movzbl %al,%ecx
80108949:	8b 45 08             	mov    0x8(%ebp),%eax
8010894c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108950:	0f b6 d0             	movzbl %al,%edx
80108953:	8b 45 08             	mov    0x8(%ebp),%eax
80108956:	0f b6 00             	movzbl (%eax),%eax
80108959:	0f b6 c0             	movzbl %al,%eax
8010895c:	83 ec 0c             	sub    $0xc,%esp
8010895f:	53                   	push   %ebx
80108960:	6a 04                	push   $0x4
80108962:	51                   	push   %ecx
80108963:	52                   	push   %edx
80108964:	50                   	push   %eax
80108965:	e8 84 fd ff ff       	call   801086ee <pci_write_config_register>
8010896a:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
8010896d:	8b 45 08             	mov    0x8(%ebp),%eax
80108970:	8b 40 10             	mov    0x10(%eax),%eax
80108973:	05 00 00 00 40       	add    $0x40000000,%eax
80108978:	a3 b4 80 19 80       	mov    %eax,0x801980b4
  uint *ctrl = (uint *)base_addr;
8010897d:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108982:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108985:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010898a:	05 d8 00 00 00       	add    $0xd8,%eax
8010898f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108992:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108995:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
8010899b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010899e:	8b 00                	mov    (%eax),%eax
801089a0:	0d 00 00 00 04       	or     $0x4000000,%eax
801089a5:	89 c2                	mov    %eax,%edx
801089a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089aa:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801089ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089af:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801089b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b8:	8b 00                	mov    (%eax),%eax
801089ba:	83 c8 40             	or     $0x40,%eax
801089bd:	89 c2                	mov    %eax,%edx
801089bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c2:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
801089c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c7:	8b 10                	mov    (%eax),%edx
801089c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089cc:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
801089ce:	83 ec 0c             	sub    $0xc,%esp
801089d1:	68 b0 c5 10 80       	push   $0x8010c5b0
801089d6:	e8 31 7a ff ff       	call   8010040c <cprintf>
801089db:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801089de:	e8 ec 9e ff ff       	call   801028cf <kalloc>
801089e3:	a3 b8 80 19 80       	mov    %eax,0x801980b8
  *intr_addr = 0;
801089e8:	a1 b8 80 19 80       	mov    0x801980b8,%eax
801089ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
801089f3:	a1 b8 80 19 80       	mov    0x801980b8,%eax
801089f8:	83 ec 08             	sub    $0x8,%esp
801089fb:	50                   	push   %eax
801089fc:	68 d2 c5 10 80       	push   $0x8010c5d2
80108a01:	e8 06 7a ff ff       	call   8010040c <cprintf>
80108a06:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108a09:	e8 50 00 00 00       	call   80108a5e <i8254_init_recv>
  i8254_init_send();
80108a0e:	e8 6d 03 00 00       	call   80108d80 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108a13:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a1a:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108a1d:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a24:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108a27:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a2e:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108a31:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a38:	0f b6 c0             	movzbl %al,%eax
80108a3b:	83 ec 0c             	sub    $0xc,%esp
80108a3e:	53                   	push   %ebx
80108a3f:	51                   	push   %ecx
80108a40:	52                   	push   %edx
80108a41:	50                   	push   %eax
80108a42:	68 e0 c5 10 80       	push   $0x8010c5e0
80108a47:	e8 c0 79 ff ff       	call   8010040c <cprintf>
80108a4c:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a52:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108a58:	90                   	nop
80108a59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a5c:	c9                   	leave
80108a5d:	c3                   	ret

80108a5e <i8254_init_recv>:

void i8254_init_recv(){
80108a5e:	f3 0f 1e fb          	endbr32
80108a62:	55                   	push   %ebp
80108a63:	89 e5                	mov    %esp,%ebp
80108a65:	57                   	push   %edi
80108a66:	56                   	push   %esi
80108a67:	53                   	push   %ebx
80108a68:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108a6b:	83 ec 0c             	sub    $0xc,%esp
80108a6e:	6a 00                	push   $0x0
80108a70:	e8 ec 04 00 00       	call   80108f61 <i8254_read_eeprom>
80108a75:	83 c4 10             	add    $0x10,%esp
80108a78:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108a7b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108a7e:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
80108a83:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108a86:	c1 e8 08             	shr    $0x8,%eax
80108a89:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
80108a8e:	83 ec 0c             	sub    $0xc,%esp
80108a91:	6a 01                	push   $0x1
80108a93:	e8 c9 04 00 00       	call   80108f61 <i8254_read_eeprom>
80108a98:	83 c4 10             	add    $0x10,%esp
80108a9b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108a9e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108aa1:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
80108aa6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108aa9:	c1 e8 08             	shr    $0x8,%eax
80108aac:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
80108ab1:	83 ec 0c             	sub    $0xc,%esp
80108ab4:	6a 02                	push   $0x2
80108ab6:	e8 a6 04 00 00       	call   80108f61 <i8254_read_eeprom>
80108abb:	83 c4 10             	add    $0x10,%esp
80108abe:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108ac1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ac4:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
80108ac9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108acc:	c1 e8 08             	shr    $0x8,%eax
80108acf:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108ad4:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108adb:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108ade:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ae5:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108ae8:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108aef:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108af2:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108af9:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108afc:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b03:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108b06:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b0d:	0f b6 c0             	movzbl %al,%eax
80108b10:	83 ec 04             	sub    $0x4,%esp
80108b13:	57                   	push   %edi
80108b14:	56                   	push   %esi
80108b15:	53                   	push   %ebx
80108b16:	51                   	push   %ecx
80108b17:	52                   	push   %edx
80108b18:	50                   	push   %eax
80108b19:	68 f8 c5 10 80       	push   $0x8010c5f8
80108b1e:	e8 e9 78 ff ff       	call   8010040c <cprintf>
80108b23:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108b26:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b2b:	05 00 54 00 00       	add    $0x5400,%eax
80108b30:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108b33:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b38:	05 04 54 00 00       	add    $0x5404,%eax
80108b3d:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108b40:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108b43:	c1 e0 10             	shl    $0x10,%eax
80108b46:	0b 45 d8             	or     -0x28(%ebp),%eax
80108b49:	89 c2                	mov    %eax,%edx
80108b4b:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108b4e:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108b50:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b53:	0d 00 00 00 80       	or     $0x80000000,%eax
80108b58:	89 c2                	mov    %eax,%edx
80108b5a:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108b5d:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108b5f:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b64:	05 00 52 00 00       	add    $0x5200,%eax
80108b69:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108b6c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108b73:	eb 19                	jmp    80108b8e <i8254_init_recv+0x130>
    mta[i] = 0;
80108b75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108b78:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b7f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108b82:	01 d0                	add    %edx,%eax
80108b84:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108b8a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108b8e:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108b92:	7e e1                	jle    80108b75 <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108b94:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b99:	05 d0 00 00 00       	add    $0xd0,%eax
80108b9e:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108ba1:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108ba4:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108baa:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108baf:	05 c8 00 00 00       	add    $0xc8,%eax
80108bb4:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108bb7:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108bba:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108bc0:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bc5:	05 28 28 00 00       	add    $0x2828,%eax
80108bca:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108bcd:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108bd0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108bd6:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bdb:	05 00 01 00 00       	add    $0x100,%eax
80108be0:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108be3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108be6:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108bec:	e8 de 9c ff ff       	call   801028cf <kalloc>
80108bf1:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108bf4:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bf9:	05 00 28 00 00       	add    $0x2800,%eax
80108bfe:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108c01:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c06:	05 04 28 00 00       	add    $0x2804,%eax
80108c0b:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108c0e:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c13:	05 08 28 00 00       	add    $0x2808,%eax
80108c18:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108c1b:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c20:	05 10 28 00 00       	add    $0x2810,%eax
80108c25:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108c28:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108c2d:	05 18 28 00 00       	add    $0x2818,%eax
80108c32:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108c35:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108c38:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108c3e:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108c41:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108c43:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108c46:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108c4c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108c4f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108c55:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108c58:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108c5e:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108c61:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108c67:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108c6a:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108c6d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108c74:	eb 73                	jmp    80108ce9 <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108c76:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c79:	c1 e0 04             	shl    $0x4,%eax
80108c7c:	89 c2                	mov    %eax,%edx
80108c7e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c81:	01 d0                	add    %edx,%eax
80108c83:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108c8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c8d:	c1 e0 04             	shl    $0x4,%eax
80108c90:	89 c2                	mov    %eax,%edx
80108c92:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c95:	01 d0                	add    %edx,%eax
80108c97:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108c9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ca0:	c1 e0 04             	shl    $0x4,%eax
80108ca3:	89 c2                	mov    %eax,%edx
80108ca5:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ca8:	01 d0                	add    %edx,%eax
80108caa:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108cb0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cb3:	c1 e0 04             	shl    $0x4,%eax
80108cb6:	89 c2                	mov    %eax,%edx
80108cb8:	8b 45 98             	mov    -0x68(%ebp),%eax
80108cbb:	01 d0                	add    %edx,%eax
80108cbd:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108cc1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cc4:	c1 e0 04             	shl    $0x4,%eax
80108cc7:	89 c2                	mov    %eax,%edx
80108cc9:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ccc:	01 d0                	add    %edx,%eax
80108cce:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108cd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108cd5:	c1 e0 04             	shl    $0x4,%eax
80108cd8:	89 c2                	mov    %eax,%edx
80108cda:	8b 45 98             	mov    -0x68(%ebp),%eax
80108cdd:	01 d0                	add    %edx,%eax
80108cdf:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108ce5:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108ce9:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108cf0:	7e 84                	jle    80108c76 <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108cf2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108cf9:	eb 57                	jmp    80108d52 <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80108cfb:	e8 cf 9b ff ff       	call   801028cf <kalloc>
80108d00:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108d03:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108d07:	75 12                	jne    80108d1b <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80108d09:	83 ec 0c             	sub    $0xc,%esp
80108d0c:	68 18 c6 10 80       	push   $0x8010c618
80108d11:	e8 f6 76 ff ff       	call   8010040c <cprintf>
80108d16:	83 c4 10             	add    $0x10,%esp
      break;
80108d19:	eb 3d                	jmp    80108d58 <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108d1b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108d1e:	c1 e0 04             	shl    $0x4,%eax
80108d21:	89 c2                	mov    %eax,%edx
80108d23:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d26:	01 d0                	add    %edx,%eax
80108d28:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108d2b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108d31:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108d33:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108d36:	83 c0 01             	add    $0x1,%eax
80108d39:	c1 e0 04             	shl    $0x4,%eax
80108d3c:	89 c2                	mov    %eax,%edx
80108d3e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d41:	01 d0                	add    %edx,%eax
80108d43:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108d46:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108d4c:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108d4e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108d52:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108d56:	7e a3                	jle    80108cfb <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80108d58:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d5b:	8b 00                	mov    (%eax),%eax
80108d5d:	83 c8 02             	or     $0x2,%eax
80108d60:	89 c2                	mov    %eax,%edx
80108d62:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d65:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108d67:	83 ec 0c             	sub    $0xc,%esp
80108d6a:	68 38 c6 10 80       	push   $0x8010c638
80108d6f:	e8 98 76 ff ff       	call   8010040c <cprintf>
80108d74:	83 c4 10             	add    $0x10,%esp
}
80108d77:	90                   	nop
80108d78:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108d7b:	5b                   	pop    %ebx
80108d7c:	5e                   	pop    %esi
80108d7d:	5f                   	pop    %edi
80108d7e:	5d                   	pop    %ebp
80108d7f:	c3                   	ret

80108d80 <i8254_init_send>:

void i8254_init_send(){
80108d80:	f3 0f 1e fb          	endbr32
80108d84:	55                   	push   %ebp
80108d85:	89 e5                	mov    %esp,%ebp
80108d87:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108d8a:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d8f:	05 28 38 00 00       	add    $0x3828,%eax
80108d94:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108d97:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d9a:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108da0:	e8 2a 9b ff ff       	call   801028cf <kalloc>
80108da5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108da8:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108dad:	05 00 38 00 00       	add    $0x3800,%eax
80108db2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108db5:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108dba:	05 04 38 00 00       	add    $0x3804,%eax
80108dbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108dc2:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108dc7:	05 08 38 00 00       	add    $0x3808,%eax
80108dcc:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108dcf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108dd2:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108dd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ddb:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108ddd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108de0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108de6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108de9:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108def:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108df4:	05 10 38 00 00       	add    $0x3810,%eax
80108df9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108dfc:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108e01:	05 18 38 00 00       	add    $0x3818,%eax
80108e06:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108e09:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108e0c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108e12:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e15:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108e1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e1e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108e21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e28:	e9 82 00 00 00       	jmp    80108eaf <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80108e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e30:	c1 e0 04             	shl    $0x4,%eax
80108e33:	89 c2                	mov    %eax,%edx
80108e35:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e38:	01 d0                	add    %edx,%eax
80108e3a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e44:	c1 e0 04             	shl    $0x4,%eax
80108e47:	89 c2                	mov    %eax,%edx
80108e49:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e4c:	01 d0                	add    %edx,%eax
80108e4e:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e57:	c1 e0 04             	shl    $0x4,%eax
80108e5a:	89 c2                	mov    %eax,%edx
80108e5c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e5f:	01 d0                	add    %edx,%eax
80108e61:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e68:	c1 e0 04             	shl    $0x4,%eax
80108e6b:	89 c2                	mov    %eax,%edx
80108e6d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e70:	01 d0                	add    %edx,%eax
80108e72:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e79:	c1 e0 04             	shl    $0x4,%eax
80108e7c:	89 c2                	mov    %eax,%edx
80108e7e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e81:	01 d0                	add    %edx,%eax
80108e83:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e8a:	c1 e0 04             	shl    $0x4,%eax
80108e8d:	89 c2                	mov    %eax,%edx
80108e8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e92:	01 d0                	add    %edx,%eax
80108e94:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e9b:	c1 e0 04             	shl    $0x4,%eax
80108e9e:	89 c2                	mov    %eax,%edx
80108ea0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ea3:	01 d0                	add    %edx,%eax
80108ea5:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108eab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108eaf:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108eb6:	0f 8e 71 ff ff ff    	jle    80108e2d <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108ebc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108ec3:	eb 57                	jmp    80108f1c <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80108ec5:	e8 05 9a ff ff       	call   801028cf <kalloc>
80108eca:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108ecd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108ed1:	75 12                	jne    80108ee5 <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80108ed3:	83 ec 0c             	sub    $0xc,%esp
80108ed6:	68 18 c6 10 80       	push   $0x8010c618
80108edb:	e8 2c 75 ff ff       	call   8010040c <cprintf>
80108ee0:	83 c4 10             	add    $0x10,%esp
      break;
80108ee3:	eb 3d                	jmp    80108f22 <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108ee5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ee8:	c1 e0 04             	shl    $0x4,%eax
80108eeb:	89 c2                	mov    %eax,%edx
80108eed:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ef0:	01 d0                	add    %edx,%eax
80108ef2:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108ef5:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108efb:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f00:	83 c0 01             	add    $0x1,%eax
80108f03:	c1 e0 04             	shl    $0x4,%eax
80108f06:	89 c2                	mov    %eax,%edx
80108f08:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f0b:	01 d0                	add    %edx,%eax
80108f0d:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108f10:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108f16:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108f18:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108f1c:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108f20:	7e a3                	jle    80108ec5 <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108f22:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f27:	05 00 04 00 00       	add    $0x400,%eax
80108f2c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108f2f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108f32:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108f38:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f3d:	05 10 04 00 00       	add    $0x410,%eax
80108f42:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108f45:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108f48:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108f4e:	83 ec 0c             	sub    $0xc,%esp
80108f51:	68 58 c6 10 80       	push   $0x8010c658
80108f56:	e8 b1 74 ff ff       	call   8010040c <cprintf>
80108f5b:	83 c4 10             	add    $0x10,%esp

}
80108f5e:	90                   	nop
80108f5f:	c9                   	leave
80108f60:	c3                   	ret

80108f61 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108f61:	f3 0f 1e fb          	endbr32
80108f65:	55                   	push   %ebp
80108f66:	89 e5                	mov    %esp,%ebp
80108f68:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108f6b:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f70:	83 c0 14             	add    $0x14,%eax
80108f73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108f76:	8b 45 08             	mov    0x8(%ebp),%eax
80108f79:	c1 e0 08             	shl    $0x8,%eax
80108f7c:	0f b7 c0             	movzwl %ax,%eax
80108f7f:	83 c8 01             	or     $0x1,%eax
80108f82:	89 c2                	mov    %eax,%edx
80108f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f87:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108f89:	83 ec 0c             	sub    $0xc,%esp
80108f8c:	68 78 c6 10 80       	push   $0x8010c678
80108f91:	e8 76 74 ff ff       	call   8010040c <cprintf>
80108f96:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f9c:	8b 00                	mov    (%eax),%eax
80108f9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fa4:	83 e0 10             	and    $0x10,%eax
80108fa7:	85 c0                	test   %eax,%eax
80108fa9:	75 02                	jne    80108fad <i8254_read_eeprom+0x4c>
  while(1){
80108fab:	eb dc                	jmp    80108f89 <i8254_read_eeprom+0x28>
      break;
80108fad:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb1:	8b 00                	mov    (%eax),%eax
80108fb3:	c1 e8 10             	shr    $0x10,%eax
}
80108fb6:	c9                   	leave
80108fb7:	c3                   	ret

80108fb8 <i8254_recv>:
void i8254_recv(){
80108fb8:	f3 0f 1e fb          	endbr32
80108fbc:	55                   	push   %ebp
80108fbd:	89 e5                	mov    %esp,%ebp
80108fbf:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108fc2:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108fc7:	05 10 28 00 00       	add    $0x2810,%eax
80108fcc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108fcf:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108fd4:	05 18 28 00 00       	add    $0x2818,%eax
80108fd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108fdc:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108fe1:	05 00 28 00 00       	add    $0x2800,%eax
80108fe6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108fe9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fec:	8b 00                	mov    (%eax),%eax
80108fee:	05 00 00 00 80       	add    $0x80000000,%eax
80108ff3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff9:	8b 10                	mov    (%eax),%edx
80108ffb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ffe:	8b 00                	mov    (%eax),%eax
80109000:	29 c2                	sub    %eax,%edx
80109002:	89 d0                	mov    %edx,%eax
80109004:	25 ff 00 00 00       	and    $0xff,%eax
80109009:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
8010900c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109010:	7e 37                	jle    80109049 <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109012:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109015:	8b 00                	mov    (%eax),%eax
80109017:	c1 e0 04             	shl    $0x4,%eax
8010901a:	89 c2                	mov    %eax,%edx
8010901c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010901f:	01 d0                	add    %edx,%eax
80109021:	8b 00                	mov    (%eax),%eax
80109023:	05 00 00 00 80       	add    $0x80000000,%eax
80109028:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
8010902b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010902e:	8b 00                	mov    (%eax),%eax
80109030:	83 c0 01             	add    $0x1,%eax
80109033:	0f b6 d0             	movzbl %al,%edx
80109036:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109039:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
8010903b:	83 ec 0c             	sub    $0xc,%esp
8010903e:	ff 75 e0             	push   -0x20(%ebp)
80109041:	e8 47 09 00 00       	call   8010998d <eth_proc>
80109046:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109049:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010904c:	8b 10                	mov    (%eax),%edx
8010904e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109051:	8b 00                	mov    (%eax),%eax
80109053:	39 c2                	cmp    %eax,%edx
80109055:	75 9f                	jne    80108ff6 <i8254_recv+0x3e>
      (*rdt)--;
80109057:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010905a:	8b 00                	mov    (%eax),%eax
8010905c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010905f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109062:	89 10                	mov    %edx,(%eax)
  while(1){
80109064:	eb 90                	jmp    80108ff6 <i8254_recv+0x3e>

80109066 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80109066:	f3 0f 1e fb          	endbr32
8010906a:	55                   	push   %ebp
8010906b:	89 e5                	mov    %esp,%ebp
8010906d:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109070:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80109075:	05 10 38 00 00       	add    $0x3810,%eax
8010907a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
8010907d:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80109082:	05 18 38 00 00       	add    $0x3818,%eax
80109087:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010908a:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010908f:	05 00 38 00 00       	add    $0x3800,%eax
80109094:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109097:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010909a:	8b 00                	mov    (%eax),%eax
8010909c:	05 00 00 00 80       	add    $0x80000000,%eax
801090a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801090a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090a7:	8b 10                	mov    (%eax),%edx
801090a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ac:	8b 00                	mov    (%eax),%eax
801090ae:	29 c2                	sub    %eax,%edx
801090b0:	89 d0                	mov    %edx,%eax
801090b2:	0f b6 c0             	movzbl %al,%eax
801090b5:	ba 00 01 00 00       	mov    $0x100,%edx
801090ba:	29 c2                	sub    %eax,%edx
801090bc:	89 d0                	mov    %edx,%eax
801090be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801090c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090c4:	8b 00                	mov    (%eax),%eax
801090c6:	25 ff 00 00 00       	and    $0xff,%eax
801090cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801090ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801090d2:	0f 8e a8 00 00 00    	jle    80109180 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
801090d8:	8b 45 08             	mov    0x8(%ebp),%eax
801090db:	8b 55 e0             	mov    -0x20(%ebp),%edx
801090de:	89 d1                	mov    %edx,%ecx
801090e0:	c1 e1 04             	shl    $0x4,%ecx
801090e3:	8b 55 e8             	mov    -0x18(%ebp),%edx
801090e6:	01 ca                	add    %ecx,%edx
801090e8:	8b 12                	mov    (%edx),%edx
801090ea:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801090f0:	83 ec 04             	sub    $0x4,%esp
801090f3:	ff 75 0c             	push   0xc(%ebp)
801090f6:	50                   	push   %eax
801090f7:	52                   	push   %edx
801090f8:	e8 1c bd ff ff       	call   80104e19 <memmove>
801090fd:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109100:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109103:	c1 e0 04             	shl    $0x4,%eax
80109106:	89 c2                	mov    %eax,%edx
80109108:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010910b:	01 d0                	add    %edx,%eax
8010910d:	8b 55 0c             	mov    0xc(%ebp),%edx
80109110:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109114:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109117:	c1 e0 04             	shl    $0x4,%eax
8010911a:	89 c2                	mov    %eax,%edx
8010911c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010911f:	01 d0                	add    %edx,%eax
80109121:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109125:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109128:	c1 e0 04             	shl    $0x4,%eax
8010912b:	89 c2                	mov    %eax,%edx
8010912d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109130:	01 d0                	add    %edx,%eax
80109132:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109136:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109139:	c1 e0 04             	shl    $0x4,%eax
8010913c:	89 c2                	mov    %eax,%edx
8010913e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109141:	01 d0                	add    %edx,%eax
80109143:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109147:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010914a:	c1 e0 04             	shl    $0x4,%eax
8010914d:	89 c2                	mov    %eax,%edx
8010914f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109152:	01 d0                	add    %edx,%eax
80109154:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
8010915a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010915d:	c1 e0 04             	shl    $0x4,%eax
80109160:	89 c2                	mov    %eax,%edx
80109162:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109165:	01 d0                	add    %edx,%eax
80109167:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
8010916b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010916e:	8b 00                	mov    (%eax),%eax
80109170:	83 c0 01             	add    $0x1,%eax
80109173:	0f b6 d0             	movzbl %al,%edx
80109176:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109179:	89 10                	mov    %edx,(%eax)
    return len;
8010917b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010917e:	eb 05                	jmp    80109185 <i8254_send+0x11f>
  }else{
    return -1;
80109180:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109185:	c9                   	leave
80109186:	c3                   	ret

80109187 <i8254_intr>:

void i8254_intr(){
80109187:	f3 0f 1e fb          	endbr32
8010918b:	55                   	push   %ebp
8010918c:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
8010918e:	a1 b8 80 19 80       	mov    0x801980b8,%eax
80109193:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109199:	90                   	nop
8010919a:	5d                   	pop    %ebp
8010919b:	c3                   	ret

8010919c <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
8010919c:	f3 0f 1e fb          	endbr32
801091a0:	55                   	push   %ebp
801091a1:	89 e5                	mov    %esp,%ebp
801091a3:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801091a6:	8b 45 08             	mov    0x8(%ebp),%eax
801091a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801091ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091af:	0f b7 00             	movzwl (%eax),%eax
801091b2:	66 3d 00 01          	cmp    $0x100,%ax
801091b6:	74 0a                	je     801091c2 <arp_proc+0x26>
801091b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091bd:	e9 4f 01 00 00       	jmp    80109311 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801091c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c5:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801091c9:	66 83 f8 08          	cmp    $0x8,%ax
801091cd:	74 0a                	je     801091d9 <arp_proc+0x3d>
801091cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091d4:	e9 38 01 00 00       	jmp    80109311 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
801091d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091dc:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801091e0:	3c 06                	cmp    $0x6,%al
801091e2:	74 0a                	je     801091ee <arp_proc+0x52>
801091e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091e9:	e9 23 01 00 00       	jmp    80109311 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
801091ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f1:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801091f5:	3c 04                	cmp    $0x4,%al
801091f7:	74 0a                	je     80109203 <arp_proc+0x67>
801091f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091fe:	e9 0e 01 00 00       	jmp    80109311 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109206:	83 c0 18             	add    $0x18,%eax
80109209:	83 ec 04             	sub    $0x4,%esp
8010920c:	6a 04                	push   $0x4
8010920e:	50                   	push   %eax
8010920f:	68 e4 f4 10 80       	push   $0x8010f4e4
80109214:	e8 a4 bb ff ff       	call   80104dbd <memcmp>
80109219:	83 c4 10             	add    $0x10,%esp
8010921c:	85 c0                	test   %eax,%eax
8010921e:	74 27                	je     80109247 <arp_proc+0xab>
80109220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109223:	83 c0 0e             	add    $0xe,%eax
80109226:	83 ec 04             	sub    $0x4,%esp
80109229:	6a 04                	push   $0x4
8010922b:	50                   	push   %eax
8010922c:	68 e4 f4 10 80       	push   $0x8010f4e4
80109231:	e8 87 bb ff ff       	call   80104dbd <memcmp>
80109236:	83 c4 10             	add    $0x10,%esp
80109239:	85 c0                	test   %eax,%eax
8010923b:	74 0a                	je     80109247 <arp_proc+0xab>
8010923d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109242:	e9 ca 00 00 00       	jmp    80109311 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109247:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010924a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010924e:	66 3d 00 01          	cmp    $0x100,%ax
80109252:	75 69                	jne    801092bd <arp_proc+0x121>
80109254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109257:	83 c0 18             	add    $0x18,%eax
8010925a:	83 ec 04             	sub    $0x4,%esp
8010925d:	6a 04                	push   $0x4
8010925f:	50                   	push   %eax
80109260:	68 e4 f4 10 80       	push   $0x8010f4e4
80109265:	e8 53 bb ff ff       	call   80104dbd <memcmp>
8010926a:	83 c4 10             	add    $0x10,%esp
8010926d:	85 c0                	test   %eax,%eax
8010926f:	75 4c                	jne    801092bd <arp_proc+0x121>
    uint send = (uint)kalloc();
80109271:	e8 59 96 ff ff       	call   801028cf <kalloc>
80109276:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109279:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109280:	83 ec 04             	sub    $0x4,%esp
80109283:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109286:	50                   	push   %eax
80109287:	ff 75 f0             	push   -0x10(%ebp)
8010928a:	ff 75 f4             	push   -0xc(%ebp)
8010928d:	e8 33 04 00 00       	call   801096c5 <arp_reply_pkt_create>
80109292:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109295:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109298:	83 ec 08             	sub    $0x8,%esp
8010929b:	50                   	push   %eax
8010929c:	ff 75 f0             	push   -0x10(%ebp)
8010929f:	e8 c2 fd ff ff       	call   80109066 <i8254_send>
801092a4:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801092a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092aa:	83 ec 0c             	sub    $0xc,%esp
801092ad:	50                   	push   %eax
801092ae:	e8 7e 95 ff ff       	call   80102831 <kfree>
801092b3:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801092b6:	b8 02 00 00 00       	mov    $0x2,%eax
801092bb:	eb 54                	jmp    80109311 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801092bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092c0:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801092c4:	66 3d 00 02          	cmp    $0x200,%ax
801092c8:	75 42                	jne    8010930c <arp_proc+0x170>
801092ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092cd:	83 c0 18             	add    $0x18,%eax
801092d0:	83 ec 04             	sub    $0x4,%esp
801092d3:	6a 04                	push   $0x4
801092d5:	50                   	push   %eax
801092d6:	68 e4 f4 10 80       	push   $0x8010f4e4
801092db:	e8 dd ba ff ff       	call   80104dbd <memcmp>
801092e0:	83 c4 10             	add    $0x10,%esp
801092e3:	85 c0                	test   %eax,%eax
801092e5:	75 25                	jne    8010930c <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
801092e7:	83 ec 0c             	sub    $0xc,%esp
801092ea:	68 7c c6 10 80       	push   $0x8010c67c
801092ef:	e8 18 71 ff ff       	call   8010040c <cprintf>
801092f4:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801092f7:	83 ec 0c             	sub    $0xc,%esp
801092fa:	ff 75 f4             	push   -0xc(%ebp)
801092fd:	e8 b7 01 00 00       	call   801094b9 <arp_table_update>
80109302:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109305:	b8 01 00 00 00       	mov    $0x1,%eax
8010930a:	eb 05                	jmp    80109311 <arp_proc+0x175>
  }else{
    return -1;
8010930c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109311:	c9                   	leave
80109312:	c3                   	ret

80109313 <arp_scan>:

void arp_scan(){
80109313:	f3 0f 1e fb          	endbr32
80109317:	55                   	push   %ebp
80109318:	89 e5                	mov    %esp,%ebp
8010931a:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
8010931d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109324:	eb 6f                	jmp    80109395 <arp_scan+0x82>
    uint send = (uint)kalloc();
80109326:	e8 a4 95 ff ff       	call   801028cf <kalloc>
8010932b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
8010932e:	83 ec 04             	sub    $0x4,%esp
80109331:	ff 75 f4             	push   -0xc(%ebp)
80109334:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109337:	50                   	push   %eax
80109338:	ff 75 ec             	push   -0x14(%ebp)
8010933b:	e8 62 00 00 00       	call   801093a2 <arp_broadcast>
80109340:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109343:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109346:	83 ec 08             	sub    $0x8,%esp
80109349:	50                   	push   %eax
8010934a:	ff 75 ec             	push   -0x14(%ebp)
8010934d:	e8 14 fd ff ff       	call   80109066 <i8254_send>
80109352:	83 c4 10             	add    $0x10,%esp
80109355:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109358:	eb 22                	jmp    8010937c <arp_scan+0x69>
      microdelay(1);
8010935a:	83 ec 0c             	sub    $0xc,%esp
8010935d:	6a 01                	push   $0x1
8010935f:	e8 1d 99 ff ff       	call   80102c81 <microdelay>
80109364:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109367:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010936a:	83 ec 08             	sub    $0x8,%esp
8010936d:	50                   	push   %eax
8010936e:	ff 75 ec             	push   -0x14(%ebp)
80109371:	e8 f0 fc ff ff       	call   80109066 <i8254_send>
80109376:	83 c4 10             	add    $0x10,%esp
80109379:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010937c:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109380:	74 d8                	je     8010935a <arp_scan+0x47>
    }
    kfree((char *)send);
80109382:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109385:	83 ec 0c             	sub    $0xc,%esp
80109388:	50                   	push   %eax
80109389:	e8 a3 94 ff ff       	call   80102831 <kfree>
8010938e:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109391:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109395:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010939c:	7e 88                	jle    80109326 <arp_scan+0x13>
  }
}
8010939e:	90                   	nop
8010939f:	90                   	nop
801093a0:	c9                   	leave
801093a1:	c3                   	ret

801093a2 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801093a2:	f3 0f 1e fb          	endbr32
801093a6:	55                   	push   %ebp
801093a7:	89 e5                	mov    %esp,%ebp
801093a9:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801093ac:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801093b0:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801093b4:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801093b8:	8b 45 10             	mov    0x10(%ebp),%eax
801093bb:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801093be:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801093c5:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801093cb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801093d2:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801093d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801093db:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801093e1:	8b 45 08             	mov    0x8(%ebp),%eax
801093e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801093e7:	8b 45 08             	mov    0x8(%ebp),%eax
801093ea:	83 c0 0e             	add    $0xe,%eax
801093ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801093f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093f3:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801093f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093fa:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801093fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109401:	83 ec 04             	sub    $0x4,%esp
80109404:	6a 06                	push   $0x6
80109406:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109409:	52                   	push   %edx
8010940a:	50                   	push   %eax
8010940b:	e8 09 ba ff ff       	call   80104e19 <memmove>
80109410:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109416:	83 c0 06             	add    $0x6,%eax
80109419:	83 ec 04             	sub    $0x4,%esp
8010941c:	6a 06                	push   $0x6
8010941e:	68 68 d0 18 80       	push   $0x8018d068
80109423:	50                   	push   %eax
80109424:	e8 f0 b9 ff ff       	call   80104e19 <memmove>
80109429:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010942c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010942f:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109434:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109437:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010943d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109440:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109444:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109447:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
8010944b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010944e:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109454:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109457:	8d 50 12             	lea    0x12(%eax),%edx
8010945a:	83 ec 04             	sub    $0x4,%esp
8010945d:	6a 06                	push   $0x6
8010945f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109462:	50                   	push   %eax
80109463:	52                   	push   %edx
80109464:	e8 b0 b9 ff ff       	call   80104e19 <memmove>
80109469:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
8010946c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010946f:	8d 50 18             	lea    0x18(%eax),%edx
80109472:	83 ec 04             	sub    $0x4,%esp
80109475:	6a 04                	push   $0x4
80109477:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010947a:	50                   	push   %eax
8010947b:	52                   	push   %edx
8010947c:	e8 98 b9 ff ff       	call   80104e19 <memmove>
80109481:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109484:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109487:	83 c0 08             	add    $0x8,%eax
8010948a:	83 ec 04             	sub    $0x4,%esp
8010948d:	6a 06                	push   $0x6
8010948f:	68 68 d0 18 80       	push   $0x8018d068
80109494:	50                   	push   %eax
80109495:	e8 7f b9 ff ff       	call   80104e19 <memmove>
8010949a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010949d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094a0:	83 c0 0e             	add    $0xe,%eax
801094a3:	83 ec 04             	sub    $0x4,%esp
801094a6:	6a 04                	push   $0x4
801094a8:	68 e4 f4 10 80       	push   $0x8010f4e4
801094ad:	50                   	push   %eax
801094ae:	e8 66 b9 ff ff       	call   80104e19 <memmove>
801094b3:	83 c4 10             	add    $0x10,%esp
}
801094b6:	90                   	nop
801094b7:	c9                   	leave
801094b8:	c3                   	ret

801094b9 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801094b9:	f3 0f 1e fb          	endbr32
801094bd:	55                   	push   %ebp
801094be:	89 e5                	mov    %esp,%ebp
801094c0:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801094c3:	8b 45 08             	mov    0x8(%ebp),%eax
801094c6:	83 c0 0e             	add    $0xe,%eax
801094c9:	83 ec 0c             	sub    $0xc,%esp
801094cc:	50                   	push   %eax
801094cd:	e8 bc 00 00 00       	call   8010958e <arp_table_search>
801094d2:	83 c4 10             	add    $0x10,%esp
801094d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801094d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801094dc:	78 2d                	js     8010950b <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801094de:	8b 45 08             	mov    0x8(%ebp),%eax
801094e1:	8d 48 08             	lea    0x8(%eax),%ecx
801094e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094e7:	89 d0                	mov    %edx,%eax
801094e9:	c1 e0 02             	shl    $0x2,%eax
801094ec:	01 d0                	add    %edx,%eax
801094ee:	01 c0                	add    %eax,%eax
801094f0:	01 d0                	add    %edx,%eax
801094f2:	05 80 d0 18 80       	add    $0x8018d080,%eax
801094f7:	83 c0 04             	add    $0x4,%eax
801094fa:	83 ec 04             	sub    $0x4,%esp
801094fd:	6a 06                	push   $0x6
801094ff:	51                   	push   %ecx
80109500:	50                   	push   %eax
80109501:	e8 13 b9 ff ff       	call   80104e19 <memmove>
80109506:	83 c4 10             	add    $0x10,%esp
80109509:	eb 70                	jmp    8010957b <arp_table_update+0xc2>
  }else{
    index += 1;
8010950b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
8010950f:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109512:	8b 45 08             	mov    0x8(%ebp),%eax
80109515:	8d 48 08             	lea    0x8(%eax),%ecx
80109518:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010951b:	89 d0                	mov    %edx,%eax
8010951d:	c1 e0 02             	shl    $0x2,%eax
80109520:	01 d0                	add    %edx,%eax
80109522:	01 c0                	add    %eax,%eax
80109524:	01 d0                	add    %edx,%eax
80109526:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010952b:	83 c0 04             	add    $0x4,%eax
8010952e:	83 ec 04             	sub    $0x4,%esp
80109531:	6a 06                	push   $0x6
80109533:	51                   	push   %ecx
80109534:	50                   	push   %eax
80109535:	e8 df b8 ff ff       	call   80104e19 <memmove>
8010953a:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
8010953d:	8b 45 08             	mov    0x8(%ebp),%eax
80109540:	8d 48 0e             	lea    0xe(%eax),%ecx
80109543:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109546:	89 d0                	mov    %edx,%eax
80109548:	c1 e0 02             	shl    $0x2,%eax
8010954b:	01 d0                	add    %edx,%eax
8010954d:	01 c0                	add    %eax,%eax
8010954f:	01 d0                	add    %edx,%eax
80109551:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109556:	83 ec 04             	sub    $0x4,%esp
80109559:	6a 04                	push   $0x4
8010955b:	51                   	push   %ecx
8010955c:	50                   	push   %eax
8010955d:	e8 b7 b8 ff ff       	call   80104e19 <memmove>
80109562:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109565:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109568:	89 d0                	mov    %edx,%eax
8010956a:	c1 e0 02             	shl    $0x2,%eax
8010956d:	01 d0                	add    %edx,%eax
8010956f:	01 c0                	add    %eax,%eax
80109571:	01 d0                	add    %edx,%eax
80109573:	05 8a d0 18 80       	add    $0x8018d08a,%eax
80109578:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
8010957b:	83 ec 0c             	sub    $0xc,%esp
8010957e:	68 80 d0 18 80       	push   $0x8018d080
80109583:	e8 87 00 00 00       	call   8010960f <print_arp_table>
80109588:	83 c4 10             	add    $0x10,%esp
}
8010958b:	90                   	nop
8010958c:	c9                   	leave
8010958d:	c3                   	ret

8010958e <arp_table_search>:

int arp_table_search(uchar *ip){
8010958e:	f3 0f 1e fb          	endbr32
80109592:	55                   	push   %ebp
80109593:	89 e5                	mov    %esp,%ebp
80109595:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109598:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010959f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801095a6:	eb 59                	jmp    80109601 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801095a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095ab:	89 d0                	mov    %edx,%eax
801095ad:	c1 e0 02             	shl    $0x2,%eax
801095b0:	01 d0                	add    %edx,%eax
801095b2:	01 c0                	add    %eax,%eax
801095b4:	01 d0                	add    %edx,%eax
801095b6:	05 80 d0 18 80       	add    $0x8018d080,%eax
801095bb:	83 ec 04             	sub    $0x4,%esp
801095be:	6a 04                	push   $0x4
801095c0:	ff 75 08             	push   0x8(%ebp)
801095c3:	50                   	push   %eax
801095c4:	e8 f4 b7 ff ff       	call   80104dbd <memcmp>
801095c9:	83 c4 10             	add    $0x10,%esp
801095cc:	85 c0                	test   %eax,%eax
801095ce:	75 05                	jne    801095d5 <arp_table_search+0x47>
      return i;
801095d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095d3:	eb 38                	jmp    8010960d <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
801095d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095d8:	89 d0                	mov    %edx,%eax
801095da:	c1 e0 02             	shl    $0x2,%eax
801095dd:	01 d0                	add    %edx,%eax
801095df:	01 c0                	add    %eax,%eax
801095e1:	01 d0                	add    %edx,%eax
801095e3:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801095e8:	0f b6 00             	movzbl (%eax),%eax
801095eb:	84 c0                	test   %al,%al
801095ed:	75 0e                	jne    801095fd <arp_table_search+0x6f>
801095ef:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801095f3:	75 08                	jne    801095fd <arp_table_search+0x6f>
      empty = -i;
801095f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095f8:	f7 d8                	neg    %eax
801095fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801095fd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109601:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109605:	7e a1                	jle    801095a8 <arp_table_search+0x1a>
    }
  }
  return empty-1;
80109607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010960a:	83 e8 01             	sub    $0x1,%eax
}
8010960d:	c9                   	leave
8010960e:	c3                   	ret

8010960f <print_arp_table>:

void print_arp_table(){
8010960f:	f3 0f 1e fb          	endbr32
80109613:	55                   	push   %ebp
80109614:	89 e5                	mov    %esp,%ebp
80109616:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109619:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109620:	e9 92 00 00 00       	jmp    801096b7 <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
80109625:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109628:	89 d0                	mov    %edx,%eax
8010962a:	c1 e0 02             	shl    $0x2,%eax
8010962d:	01 d0                	add    %edx,%eax
8010962f:	01 c0                	add    %eax,%eax
80109631:	01 d0                	add    %edx,%eax
80109633:	05 8a d0 18 80       	add    $0x8018d08a,%eax
80109638:	0f b6 00             	movzbl (%eax),%eax
8010963b:	84 c0                	test   %al,%al
8010963d:	74 74                	je     801096b3 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
8010963f:	83 ec 08             	sub    $0x8,%esp
80109642:	ff 75 f4             	push   -0xc(%ebp)
80109645:	68 8f c6 10 80       	push   $0x8010c68f
8010964a:	e8 bd 6d ff ff       	call   8010040c <cprintf>
8010964f:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109655:	89 d0                	mov    %edx,%eax
80109657:	c1 e0 02             	shl    $0x2,%eax
8010965a:	01 d0                	add    %edx,%eax
8010965c:	01 c0                	add    %eax,%eax
8010965e:	01 d0                	add    %edx,%eax
80109660:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109665:	83 ec 0c             	sub    $0xc,%esp
80109668:	50                   	push   %eax
80109669:	e8 5c 02 00 00       	call   801098ca <print_ipv4>
8010966e:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109671:	83 ec 0c             	sub    $0xc,%esp
80109674:	68 9e c6 10 80       	push   $0x8010c69e
80109679:	e8 8e 6d ff ff       	call   8010040c <cprintf>
8010967e:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109681:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109684:	89 d0                	mov    %edx,%eax
80109686:	c1 e0 02             	shl    $0x2,%eax
80109689:	01 d0                	add    %edx,%eax
8010968b:	01 c0                	add    %eax,%eax
8010968d:	01 d0                	add    %edx,%eax
8010968f:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109694:	83 c0 04             	add    $0x4,%eax
80109697:	83 ec 0c             	sub    $0xc,%esp
8010969a:	50                   	push   %eax
8010969b:	e8 7c 02 00 00       	call   8010991c <print_mac>
801096a0:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801096a3:	83 ec 0c             	sub    $0xc,%esp
801096a6:	68 a0 c6 10 80       	push   $0x8010c6a0
801096ab:	e8 5c 6d ff ff       	call   8010040c <cprintf>
801096b0:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801096b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801096b7:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801096bb:	0f 8e 64 ff ff ff    	jle    80109625 <print_arp_table+0x16>
    }
  }
}
801096c1:	90                   	nop
801096c2:	90                   	nop
801096c3:	c9                   	leave
801096c4:	c3                   	ret

801096c5 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801096c5:	f3 0f 1e fb          	endbr32
801096c9:	55                   	push   %ebp
801096ca:	89 e5                	mov    %esp,%ebp
801096cc:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801096cf:	8b 45 10             	mov    0x10(%ebp),%eax
801096d2:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801096d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801096db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801096de:	8b 45 0c             	mov    0xc(%ebp),%eax
801096e1:	83 c0 0e             	add    $0xe,%eax
801096e4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801096e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ea:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801096ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096f1:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801096f5:	8b 45 08             	mov    0x8(%ebp),%eax
801096f8:	8d 50 08             	lea    0x8(%eax),%edx
801096fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096fe:	83 ec 04             	sub    $0x4,%esp
80109701:	6a 06                	push   $0x6
80109703:	52                   	push   %edx
80109704:	50                   	push   %eax
80109705:	e8 0f b7 ff ff       	call   80104e19 <memmove>
8010970a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010970d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109710:	83 c0 06             	add    $0x6,%eax
80109713:	83 ec 04             	sub    $0x4,%esp
80109716:	6a 06                	push   $0x6
80109718:	68 68 d0 18 80       	push   $0x8018d068
8010971d:	50                   	push   %eax
8010971e:	e8 f6 b6 ff ff       	call   80104e19 <memmove>
80109723:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109726:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109729:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010972e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109731:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109737:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010973a:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010973e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109741:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109745:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109748:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010974e:	8b 45 08             	mov    0x8(%ebp),%eax
80109751:	8d 50 08             	lea    0x8(%eax),%edx
80109754:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109757:	83 c0 12             	add    $0x12,%eax
8010975a:	83 ec 04             	sub    $0x4,%esp
8010975d:	6a 06                	push   $0x6
8010975f:	52                   	push   %edx
80109760:	50                   	push   %eax
80109761:	e8 b3 b6 ff ff       	call   80104e19 <memmove>
80109766:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109769:	8b 45 08             	mov    0x8(%ebp),%eax
8010976c:	8d 50 0e             	lea    0xe(%eax),%edx
8010976f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109772:	83 c0 18             	add    $0x18,%eax
80109775:	83 ec 04             	sub    $0x4,%esp
80109778:	6a 04                	push   $0x4
8010977a:	52                   	push   %edx
8010977b:	50                   	push   %eax
8010977c:	e8 98 b6 ff ff       	call   80104e19 <memmove>
80109781:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109784:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109787:	83 c0 08             	add    $0x8,%eax
8010978a:	83 ec 04             	sub    $0x4,%esp
8010978d:	6a 06                	push   $0x6
8010978f:	68 68 d0 18 80       	push   $0x8018d068
80109794:	50                   	push   %eax
80109795:	e8 7f b6 ff ff       	call   80104e19 <memmove>
8010979a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010979d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097a0:	83 c0 0e             	add    $0xe,%eax
801097a3:	83 ec 04             	sub    $0x4,%esp
801097a6:	6a 04                	push   $0x4
801097a8:	68 e4 f4 10 80       	push   $0x8010f4e4
801097ad:	50                   	push   %eax
801097ae:	e8 66 b6 ff ff       	call   80104e19 <memmove>
801097b3:	83 c4 10             	add    $0x10,%esp
}
801097b6:	90                   	nop
801097b7:	c9                   	leave
801097b8:	c3                   	ret

801097b9 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801097b9:	f3 0f 1e fb          	endbr32
801097bd:	55                   	push   %ebp
801097be:	89 e5                	mov    %esp,%ebp
801097c0:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801097c3:	83 ec 0c             	sub    $0xc,%esp
801097c6:	68 a2 c6 10 80       	push   $0x8010c6a2
801097cb:	e8 3c 6c ff ff       	call   8010040c <cprintf>
801097d0:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801097d3:	8b 45 08             	mov    0x8(%ebp),%eax
801097d6:	83 c0 0e             	add    $0xe,%eax
801097d9:	83 ec 0c             	sub    $0xc,%esp
801097dc:	50                   	push   %eax
801097dd:	e8 e8 00 00 00       	call   801098ca <print_ipv4>
801097e2:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801097e5:	83 ec 0c             	sub    $0xc,%esp
801097e8:	68 a0 c6 10 80       	push   $0x8010c6a0
801097ed:	e8 1a 6c ff ff       	call   8010040c <cprintf>
801097f2:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801097f5:	8b 45 08             	mov    0x8(%ebp),%eax
801097f8:	83 c0 08             	add    $0x8,%eax
801097fb:	83 ec 0c             	sub    $0xc,%esp
801097fe:	50                   	push   %eax
801097ff:	e8 18 01 00 00       	call   8010991c <print_mac>
80109804:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109807:	83 ec 0c             	sub    $0xc,%esp
8010980a:	68 a0 c6 10 80       	push   $0x8010c6a0
8010980f:	e8 f8 6b ff ff       	call   8010040c <cprintf>
80109814:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109817:	83 ec 0c             	sub    $0xc,%esp
8010981a:	68 b9 c6 10 80       	push   $0x8010c6b9
8010981f:	e8 e8 6b ff ff       	call   8010040c <cprintf>
80109824:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109827:	8b 45 08             	mov    0x8(%ebp),%eax
8010982a:	83 c0 18             	add    $0x18,%eax
8010982d:	83 ec 0c             	sub    $0xc,%esp
80109830:	50                   	push   %eax
80109831:	e8 94 00 00 00       	call   801098ca <print_ipv4>
80109836:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109839:	83 ec 0c             	sub    $0xc,%esp
8010983c:	68 a0 c6 10 80       	push   $0x8010c6a0
80109841:	e8 c6 6b ff ff       	call   8010040c <cprintf>
80109846:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109849:	8b 45 08             	mov    0x8(%ebp),%eax
8010984c:	83 c0 12             	add    $0x12,%eax
8010984f:	83 ec 0c             	sub    $0xc,%esp
80109852:	50                   	push   %eax
80109853:	e8 c4 00 00 00       	call   8010991c <print_mac>
80109858:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010985b:	83 ec 0c             	sub    $0xc,%esp
8010985e:	68 a0 c6 10 80       	push   $0x8010c6a0
80109863:	e8 a4 6b ff ff       	call   8010040c <cprintf>
80109868:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010986b:	83 ec 0c             	sub    $0xc,%esp
8010986e:	68 d0 c6 10 80       	push   $0x8010c6d0
80109873:	e8 94 6b ff ff       	call   8010040c <cprintf>
80109878:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010987b:	8b 45 08             	mov    0x8(%ebp),%eax
8010987e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109882:	66 3d 00 01          	cmp    $0x100,%ax
80109886:	75 12                	jne    8010989a <print_arp_info+0xe1>
80109888:	83 ec 0c             	sub    $0xc,%esp
8010988b:	68 dc c6 10 80       	push   $0x8010c6dc
80109890:	e8 77 6b ff ff       	call   8010040c <cprintf>
80109895:	83 c4 10             	add    $0x10,%esp
80109898:	eb 1d                	jmp    801098b7 <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010989a:	8b 45 08             	mov    0x8(%ebp),%eax
8010989d:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801098a1:	66 3d 00 02          	cmp    $0x200,%ax
801098a5:	75 10                	jne    801098b7 <print_arp_info+0xfe>
    cprintf("Reply\n");
801098a7:	83 ec 0c             	sub    $0xc,%esp
801098aa:	68 e5 c6 10 80       	push   $0x8010c6e5
801098af:	e8 58 6b ff ff       	call   8010040c <cprintf>
801098b4:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801098b7:	83 ec 0c             	sub    $0xc,%esp
801098ba:	68 a0 c6 10 80       	push   $0x8010c6a0
801098bf:	e8 48 6b ff ff       	call   8010040c <cprintf>
801098c4:	83 c4 10             	add    $0x10,%esp
}
801098c7:	90                   	nop
801098c8:	c9                   	leave
801098c9:	c3                   	ret

801098ca <print_ipv4>:

void print_ipv4(uchar *ip){
801098ca:	f3 0f 1e fb          	endbr32
801098ce:	55                   	push   %ebp
801098cf:	89 e5                	mov    %esp,%ebp
801098d1:	53                   	push   %ebx
801098d2:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801098d5:	8b 45 08             	mov    0x8(%ebp),%eax
801098d8:	83 c0 03             	add    $0x3,%eax
801098db:	0f b6 00             	movzbl (%eax),%eax
801098de:	0f b6 d8             	movzbl %al,%ebx
801098e1:	8b 45 08             	mov    0x8(%ebp),%eax
801098e4:	83 c0 02             	add    $0x2,%eax
801098e7:	0f b6 00             	movzbl (%eax),%eax
801098ea:	0f b6 c8             	movzbl %al,%ecx
801098ed:	8b 45 08             	mov    0x8(%ebp),%eax
801098f0:	83 c0 01             	add    $0x1,%eax
801098f3:	0f b6 00             	movzbl (%eax),%eax
801098f6:	0f b6 d0             	movzbl %al,%edx
801098f9:	8b 45 08             	mov    0x8(%ebp),%eax
801098fc:	0f b6 00             	movzbl (%eax),%eax
801098ff:	0f b6 c0             	movzbl %al,%eax
80109902:	83 ec 0c             	sub    $0xc,%esp
80109905:	53                   	push   %ebx
80109906:	51                   	push   %ecx
80109907:	52                   	push   %edx
80109908:	50                   	push   %eax
80109909:	68 ec c6 10 80       	push   $0x8010c6ec
8010990e:	e8 f9 6a ff ff       	call   8010040c <cprintf>
80109913:	83 c4 20             	add    $0x20,%esp
}
80109916:	90                   	nop
80109917:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010991a:	c9                   	leave
8010991b:	c3                   	ret

8010991c <print_mac>:

void print_mac(uchar *mac){
8010991c:	f3 0f 1e fb          	endbr32
80109920:	55                   	push   %ebp
80109921:	89 e5                	mov    %esp,%ebp
80109923:	57                   	push   %edi
80109924:	56                   	push   %esi
80109925:	53                   	push   %ebx
80109926:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109929:	8b 45 08             	mov    0x8(%ebp),%eax
8010992c:	83 c0 05             	add    $0x5,%eax
8010992f:	0f b6 00             	movzbl (%eax),%eax
80109932:	0f b6 f8             	movzbl %al,%edi
80109935:	8b 45 08             	mov    0x8(%ebp),%eax
80109938:	83 c0 04             	add    $0x4,%eax
8010993b:	0f b6 00             	movzbl (%eax),%eax
8010993e:	0f b6 f0             	movzbl %al,%esi
80109941:	8b 45 08             	mov    0x8(%ebp),%eax
80109944:	83 c0 03             	add    $0x3,%eax
80109947:	0f b6 00             	movzbl (%eax),%eax
8010994a:	0f b6 d8             	movzbl %al,%ebx
8010994d:	8b 45 08             	mov    0x8(%ebp),%eax
80109950:	83 c0 02             	add    $0x2,%eax
80109953:	0f b6 00             	movzbl (%eax),%eax
80109956:	0f b6 c8             	movzbl %al,%ecx
80109959:	8b 45 08             	mov    0x8(%ebp),%eax
8010995c:	83 c0 01             	add    $0x1,%eax
8010995f:	0f b6 00             	movzbl (%eax),%eax
80109962:	0f b6 d0             	movzbl %al,%edx
80109965:	8b 45 08             	mov    0x8(%ebp),%eax
80109968:	0f b6 00             	movzbl (%eax),%eax
8010996b:	0f b6 c0             	movzbl %al,%eax
8010996e:	83 ec 04             	sub    $0x4,%esp
80109971:	57                   	push   %edi
80109972:	56                   	push   %esi
80109973:	53                   	push   %ebx
80109974:	51                   	push   %ecx
80109975:	52                   	push   %edx
80109976:	50                   	push   %eax
80109977:	68 04 c7 10 80       	push   $0x8010c704
8010997c:	e8 8b 6a ff ff       	call   8010040c <cprintf>
80109981:	83 c4 20             	add    $0x20,%esp
}
80109984:	90                   	nop
80109985:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109988:	5b                   	pop    %ebx
80109989:	5e                   	pop    %esi
8010998a:	5f                   	pop    %edi
8010998b:	5d                   	pop    %ebp
8010998c:	c3                   	ret

8010998d <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
8010998d:	f3 0f 1e fb          	endbr32
80109991:	55                   	push   %ebp
80109992:	89 e5                	mov    %esp,%ebp
80109994:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109997:	8b 45 08             	mov    0x8(%ebp),%eax
8010999a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
8010999d:	8b 45 08             	mov    0x8(%ebp),%eax
801099a0:	83 c0 0e             	add    $0xe,%eax
801099a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801099a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099a9:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801099ad:	3c 08                	cmp    $0x8,%al
801099af:	75 1b                	jne    801099cc <eth_proc+0x3f>
801099b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099b4:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801099b8:	3c 06                	cmp    $0x6,%al
801099ba:	75 10                	jne    801099cc <eth_proc+0x3f>
    arp_proc(pkt_addr);
801099bc:	83 ec 0c             	sub    $0xc,%esp
801099bf:	ff 75 f0             	push   -0x10(%ebp)
801099c2:	e8 d5 f7 ff ff       	call   8010919c <arp_proc>
801099c7:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801099ca:	eb 24                	jmp    801099f0 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801099cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099cf:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801099d3:	3c 08                	cmp    $0x8,%al
801099d5:	75 19                	jne    801099f0 <eth_proc+0x63>
801099d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099da:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801099de:	84 c0                	test   %al,%al
801099e0:	75 0e                	jne    801099f0 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
801099e2:	83 ec 0c             	sub    $0xc,%esp
801099e5:	ff 75 08             	push   0x8(%ebp)
801099e8:	e8 b3 00 00 00       	call   80109aa0 <ipv4_proc>
801099ed:	83 c4 10             	add    $0x10,%esp
}
801099f0:	90                   	nop
801099f1:	c9                   	leave
801099f2:	c3                   	ret

801099f3 <N2H_ushort>:

ushort N2H_ushort(ushort value){
801099f3:	f3 0f 1e fb          	endbr32
801099f7:	55                   	push   %ebp
801099f8:	89 e5                	mov    %esp,%ebp
801099fa:	83 ec 04             	sub    $0x4,%esp
801099fd:	8b 45 08             	mov    0x8(%ebp),%eax
80109a00:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109a04:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a08:	c1 e0 08             	shl    $0x8,%eax
80109a0b:	89 c2                	mov    %eax,%edx
80109a0d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a11:	66 c1 e8 08          	shr    $0x8,%ax
80109a15:	01 d0                	add    %edx,%eax
}
80109a17:	c9                   	leave
80109a18:	c3                   	ret

80109a19 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109a19:	f3 0f 1e fb          	endbr32
80109a1d:	55                   	push   %ebp
80109a1e:	89 e5                	mov    %esp,%ebp
80109a20:	83 ec 04             	sub    $0x4,%esp
80109a23:	8b 45 08             	mov    0x8(%ebp),%eax
80109a26:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109a2a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a2e:	c1 e0 08             	shl    $0x8,%eax
80109a31:	89 c2                	mov    %eax,%edx
80109a33:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109a37:	66 c1 e8 08          	shr    $0x8,%ax
80109a3b:	01 d0                	add    %edx,%eax
}
80109a3d:	c9                   	leave
80109a3e:	c3                   	ret

80109a3f <H2N_uint>:

uint H2N_uint(uint value){
80109a3f:	f3 0f 1e fb          	endbr32
80109a43:	55                   	push   %ebp
80109a44:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109a46:	8b 45 08             	mov    0x8(%ebp),%eax
80109a49:	c1 e0 18             	shl    $0x18,%eax
80109a4c:	25 00 00 00 0f       	and    $0xf000000,%eax
80109a51:	89 c2                	mov    %eax,%edx
80109a53:	8b 45 08             	mov    0x8(%ebp),%eax
80109a56:	c1 e0 08             	shl    $0x8,%eax
80109a59:	25 00 f0 00 00       	and    $0xf000,%eax
80109a5e:	09 c2                	or     %eax,%edx
80109a60:	8b 45 08             	mov    0x8(%ebp),%eax
80109a63:	c1 e8 08             	shr    $0x8,%eax
80109a66:	83 e0 0f             	and    $0xf,%eax
80109a69:	01 d0                	add    %edx,%eax
}
80109a6b:	5d                   	pop    %ebp
80109a6c:	c3                   	ret

80109a6d <N2H_uint>:

uint N2H_uint(uint value){
80109a6d:	f3 0f 1e fb          	endbr32
80109a71:	55                   	push   %ebp
80109a72:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109a74:	8b 45 08             	mov    0x8(%ebp),%eax
80109a77:	c1 e0 18             	shl    $0x18,%eax
80109a7a:	89 c2                	mov    %eax,%edx
80109a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80109a7f:	c1 e0 08             	shl    $0x8,%eax
80109a82:	25 00 00 ff 00       	and    $0xff0000,%eax
80109a87:	01 c2                	add    %eax,%edx
80109a89:	8b 45 08             	mov    0x8(%ebp),%eax
80109a8c:	c1 e8 08             	shr    $0x8,%eax
80109a8f:	25 00 ff 00 00       	and    $0xff00,%eax
80109a94:	01 c2                	add    %eax,%edx
80109a96:	8b 45 08             	mov    0x8(%ebp),%eax
80109a99:	c1 e8 18             	shr    $0x18,%eax
80109a9c:	01 d0                	add    %edx,%eax
}
80109a9e:	5d                   	pop    %ebp
80109a9f:	c3                   	ret

80109aa0 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109aa0:	f3 0f 1e fb          	endbr32
80109aa4:	55                   	push   %ebp
80109aa5:	89 e5                	mov    %esp,%ebp
80109aa7:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80109aad:	83 c0 0e             	add    $0xe,%eax
80109ab0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ab6:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109aba:	0f b7 d0             	movzwl %ax,%edx
80109abd:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109ac2:	39 c2                	cmp    %eax,%edx
80109ac4:	74 60                	je     80109b26 <ipv4_proc+0x86>
80109ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ac9:	83 c0 0c             	add    $0xc,%eax
80109acc:	83 ec 04             	sub    $0x4,%esp
80109acf:	6a 04                	push   $0x4
80109ad1:	50                   	push   %eax
80109ad2:	68 e4 f4 10 80       	push   $0x8010f4e4
80109ad7:	e8 e1 b2 ff ff       	call   80104dbd <memcmp>
80109adc:	83 c4 10             	add    $0x10,%esp
80109adf:	85 c0                	test   %eax,%eax
80109ae1:	74 43                	je     80109b26 <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
80109ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ae6:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109aea:	0f b7 c0             	movzwl %ax,%eax
80109aed:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109af5:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109af9:	3c 01                	cmp    $0x1,%al
80109afb:	75 10                	jne    80109b0d <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109afd:	83 ec 0c             	sub    $0xc,%esp
80109b00:	ff 75 08             	push   0x8(%ebp)
80109b03:	e8 a7 00 00 00       	call   80109baf <icmp_proc>
80109b08:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109b0b:	eb 19                	jmp    80109b26 <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b10:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109b14:	3c 06                	cmp    $0x6,%al
80109b16:	75 0e                	jne    80109b26 <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
80109b18:	83 ec 0c             	sub    $0xc,%esp
80109b1b:	ff 75 08             	push   0x8(%ebp)
80109b1e:	e8 c7 03 00 00       	call   80109eea <tcp_proc>
80109b23:	83 c4 10             	add    $0x10,%esp
}
80109b26:	90                   	nop
80109b27:	c9                   	leave
80109b28:	c3                   	ret

80109b29 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109b29:	f3 0f 1e fb          	endbr32
80109b2d:	55                   	push   %ebp
80109b2e:	89 e5                	mov    %esp,%ebp
80109b30:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109b33:	8b 45 08             	mov    0x8(%ebp),%eax
80109b36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b3c:	0f b6 00             	movzbl (%eax),%eax
80109b3f:	83 e0 0f             	and    $0xf,%eax
80109b42:	01 c0                	add    %eax,%eax
80109b44:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109b47:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109b4e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109b55:	eb 48                	jmp    80109b9f <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109b57:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b5a:	01 c0                	add    %eax,%eax
80109b5c:	89 c2                	mov    %eax,%edx
80109b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b61:	01 d0                	add    %edx,%eax
80109b63:	0f b6 00             	movzbl (%eax),%eax
80109b66:	0f b6 c0             	movzbl %al,%eax
80109b69:	c1 e0 08             	shl    $0x8,%eax
80109b6c:	89 c2                	mov    %eax,%edx
80109b6e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b71:	01 c0                	add    %eax,%eax
80109b73:	8d 48 01             	lea    0x1(%eax),%ecx
80109b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b79:	01 c8                	add    %ecx,%eax
80109b7b:	0f b6 00             	movzbl (%eax),%eax
80109b7e:	0f b6 c0             	movzbl %al,%eax
80109b81:	01 d0                	add    %edx,%eax
80109b83:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109b86:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109b8d:	76 0c                	jbe    80109b9b <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
80109b8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b92:	0f b7 c0             	movzwl %ax,%eax
80109b95:	83 c0 01             	add    $0x1,%eax
80109b98:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109b9b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109b9f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109ba3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109ba6:	7c af                	jl     80109b57 <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
80109ba8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109bab:	f7 d0                	not    %eax
}
80109bad:	c9                   	leave
80109bae:	c3                   	ret

80109baf <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109baf:	f3 0f 1e fb          	endbr32
80109bb3:	55                   	push   %ebp
80109bb4:	89 e5                	mov    %esp,%ebp
80109bb6:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80109bbc:	83 c0 0e             	add    $0xe,%eax
80109bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bc5:	0f b6 00             	movzbl (%eax),%eax
80109bc8:	0f b6 c0             	movzbl %al,%eax
80109bcb:	83 e0 0f             	and    $0xf,%eax
80109bce:	c1 e0 02             	shl    $0x2,%eax
80109bd1:	89 c2                	mov    %eax,%edx
80109bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bd6:	01 d0                	add    %edx,%eax
80109bd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bde:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109be2:	84 c0                	test   %al,%al
80109be4:	75 4f                	jne    80109c35 <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109be6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109be9:	0f b6 00             	movzbl (%eax),%eax
80109bec:	3c 08                	cmp    $0x8,%al
80109bee:	75 45                	jne    80109c35 <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109bf0:	e8 da 8c ff ff       	call   801028cf <kalloc>
80109bf5:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109bf8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109bff:	83 ec 04             	sub    $0x4,%esp
80109c02:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109c05:	50                   	push   %eax
80109c06:	ff 75 ec             	push   -0x14(%ebp)
80109c09:	ff 75 08             	push   0x8(%ebp)
80109c0c:	e8 7c 00 00 00       	call   80109c8d <icmp_reply_pkt_create>
80109c11:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109c14:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c17:	83 ec 08             	sub    $0x8,%esp
80109c1a:	50                   	push   %eax
80109c1b:	ff 75 ec             	push   -0x14(%ebp)
80109c1e:	e8 43 f4 ff ff       	call   80109066 <i8254_send>
80109c23:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109c26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c29:	83 ec 0c             	sub    $0xc,%esp
80109c2c:	50                   	push   %eax
80109c2d:	e8 ff 8b ff ff       	call   80102831 <kfree>
80109c32:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109c35:	90                   	nop
80109c36:	c9                   	leave
80109c37:	c3                   	ret

80109c38 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109c38:	f3 0f 1e fb          	endbr32
80109c3c:	55                   	push   %ebp
80109c3d:	89 e5                	mov    %esp,%ebp
80109c3f:	53                   	push   %ebx
80109c40:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109c43:	8b 45 08             	mov    0x8(%ebp),%eax
80109c46:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109c4a:	0f b7 c0             	movzwl %ax,%eax
80109c4d:	83 ec 0c             	sub    $0xc,%esp
80109c50:	50                   	push   %eax
80109c51:	e8 9d fd ff ff       	call   801099f3 <N2H_ushort>
80109c56:	83 c4 10             	add    $0x10,%esp
80109c59:	0f b7 d8             	movzwl %ax,%ebx
80109c5c:	8b 45 08             	mov    0x8(%ebp),%eax
80109c5f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109c63:	0f b7 c0             	movzwl %ax,%eax
80109c66:	83 ec 0c             	sub    $0xc,%esp
80109c69:	50                   	push   %eax
80109c6a:	e8 84 fd ff ff       	call   801099f3 <N2H_ushort>
80109c6f:	83 c4 10             	add    $0x10,%esp
80109c72:	0f b7 c0             	movzwl %ax,%eax
80109c75:	83 ec 04             	sub    $0x4,%esp
80109c78:	53                   	push   %ebx
80109c79:	50                   	push   %eax
80109c7a:	68 23 c7 10 80       	push   $0x8010c723
80109c7f:	e8 88 67 ff ff       	call   8010040c <cprintf>
80109c84:	83 c4 10             	add    $0x10,%esp
}
80109c87:	90                   	nop
80109c88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109c8b:	c9                   	leave
80109c8c:	c3                   	ret

80109c8d <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109c8d:	f3 0f 1e fb          	endbr32
80109c91:	55                   	push   %ebp
80109c92:	89 e5                	mov    %esp,%ebp
80109c94:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109c97:	8b 45 08             	mov    0x8(%ebp),%eax
80109c9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80109ca0:	83 c0 0e             	add    $0xe,%eax
80109ca3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ca9:	0f b6 00             	movzbl (%eax),%eax
80109cac:	0f b6 c0             	movzbl %al,%eax
80109caf:	83 e0 0f             	and    $0xf,%eax
80109cb2:	c1 e0 02             	shl    $0x2,%eax
80109cb5:	89 c2                	mov    %eax,%edx
80109cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cba:	01 d0                	add    %edx,%eax
80109cbc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109cbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cc2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109cc5:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cc8:	83 c0 0e             	add    $0xe,%eax
80109ccb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109cce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cd1:	83 c0 14             	add    $0x14,%eax
80109cd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109cd7:	8b 45 10             	mov    0x10(%ebp),%eax
80109cda:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ce3:	8d 50 06             	lea    0x6(%eax),%edx
80109ce6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ce9:	83 ec 04             	sub    $0x4,%esp
80109cec:	6a 06                	push   $0x6
80109cee:	52                   	push   %edx
80109cef:	50                   	push   %eax
80109cf0:	e8 24 b1 ff ff       	call   80104e19 <memmove>
80109cf5:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109cf8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cfb:	83 c0 06             	add    $0x6,%eax
80109cfe:	83 ec 04             	sub    $0x4,%esp
80109d01:	6a 06                	push   $0x6
80109d03:	68 68 d0 18 80       	push   $0x8018d068
80109d08:	50                   	push   %eax
80109d09:	e8 0b b1 ff ff       	call   80104e19 <memmove>
80109d0e:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109d11:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d14:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109d18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d1b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109d1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d22:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109d25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d28:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109d2c:	83 ec 0c             	sub    $0xc,%esp
80109d2f:	6a 54                	push   $0x54
80109d31:	e8 e3 fc ff ff       	call   80109a19 <H2N_ushort>
80109d36:	83 c4 10             	add    $0x10,%esp
80109d39:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d3c:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109d40:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109d47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d4a:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109d4e:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109d55:	83 c0 01             	add    $0x1,%eax
80109d58:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
80109d5e:	83 ec 0c             	sub    $0xc,%esp
80109d61:	68 00 40 00 00       	push   $0x4000
80109d66:	e8 ae fc ff ff       	call   80109a19 <H2N_ushort>
80109d6b:	83 c4 10             	add    $0x10,%esp
80109d6e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d71:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109d75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d78:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109d7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d7f:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109d83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d86:	83 c0 0c             	add    $0xc,%eax
80109d89:	83 ec 04             	sub    $0x4,%esp
80109d8c:	6a 04                	push   $0x4
80109d8e:	68 e4 f4 10 80       	push   $0x8010f4e4
80109d93:	50                   	push   %eax
80109d94:	e8 80 b0 ff ff       	call   80104e19 <memmove>
80109d99:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109d9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d9f:	8d 50 0c             	lea    0xc(%eax),%edx
80109da2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109da5:	83 c0 10             	add    $0x10,%eax
80109da8:	83 ec 04             	sub    $0x4,%esp
80109dab:	6a 04                	push   $0x4
80109dad:	52                   	push   %edx
80109dae:	50                   	push   %eax
80109daf:	e8 65 b0 ff ff       	call   80104e19 <memmove>
80109db4:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109db7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dba:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109dc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dc3:	83 ec 0c             	sub    $0xc,%esp
80109dc6:	50                   	push   %eax
80109dc7:	e8 5d fd ff ff       	call   80109b29 <ipv4_chksum>
80109dcc:	83 c4 10             	add    $0x10,%esp
80109dcf:	0f b7 c0             	movzwl %ax,%eax
80109dd2:	83 ec 0c             	sub    $0xc,%esp
80109dd5:	50                   	push   %eax
80109dd6:	e8 3e fc ff ff       	call   80109a19 <H2N_ushort>
80109ddb:	83 c4 10             	add    $0x10,%esp
80109dde:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109de1:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109de5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109de8:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109deb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dee:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109df2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109df5:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109df9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dfc:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109e00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e03:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109e07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e0a:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109e0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e11:	8d 50 08             	lea    0x8(%eax),%edx
80109e14:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e17:	83 c0 08             	add    $0x8,%eax
80109e1a:	83 ec 04             	sub    $0x4,%esp
80109e1d:	6a 08                	push   $0x8
80109e1f:	52                   	push   %edx
80109e20:	50                   	push   %eax
80109e21:	e8 f3 af ff ff       	call   80104e19 <memmove>
80109e26:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109e29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e2c:	8d 50 10             	lea    0x10(%eax),%edx
80109e2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e32:	83 c0 10             	add    $0x10,%eax
80109e35:	83 ec 04             	sub    $0x4,%esp
80109e38:	6a 30                	push   $0x30
80109e3a:	52                   	push   %edx
80109e3b:	50                   	push   %eax
80109e3c:	e8 d8 af ff ff       	call   80104e19 <memmove>
80109e41:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109e44:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e47:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109e4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e50:	83 ec 0c             	sub    $0xc,%esp
80109e53:	50                   	push   %eax
80109e54:	e8 1c 00 00 00       	call   80109e75 <icmp_chksum>
80109e59:	83 c4 10             	add    $0x10,%esp
80109e5c:	0f b7 c0             	movzwl %ax,%eax
80109e5f:	83 ec 0c             	sub    $0xc,%esp
80109e62:	50                   	push   %eax
80109e63:	e8 b1 fb ff ff       	call   80109a19 <H2N_ushort>
80109e68:	83 c4 10             	add    $0x10,%esp
80109e6b:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109e6e:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109e72:	90                   	nop
80109e73:	c9                   	leave
80109e74:	c3                   	ret

80109e75 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109e75:	f3 0f 1e fb          	endbr32
80109e79:	55                   	push   %ebp
80109e7a:	89 e5                	mov    %esp,%ebp
80109e7c:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109e7f:	8b 45 08             	mov    0x8(%ebp),%eax
80109e82:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109e85:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109e8c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109e93:	eb 48                	jmp    80109edd <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e95:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e98:	01 c0                	add    %eax,%eax
80109e9a:	89 c2                	mov    %eax,%edx
80109e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e9f:	01 d0                	add    %edx,%eax
80109ea1:	0f b6 00             	movzbl (%eax),%eax
80109ea4:	0f b6 c0             	movzbl %al,%eax
80109ea7:	c1 e0 08             	shl    $0x8,%eax
80109eaa:	89 c2                	mov    %eax,%edx
80109eac:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109eaf:	01 c0                	add    %eax,%eax
80109eb1:	8d 48 01             	lea    0x1(%eax),%ecx
80109eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109eb7:	01 c8                	add    %ecx,%eax
80109eb9:	0f b6 00             	movzbl (%eax),%eax
80109ebc:	0f b6 c0             	movzbl %al,%eax
80109ebf:	01 d0                	add    %edx,%eax
80109ec1:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109ec4:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109ecb:	76 0c                	jbe    80109ed9 <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
80109ecd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ed0:	0f b7 c0             	movzwl %ax,%eax
80109ed3:	83 c0 01             	add    $0x1,%eax
80109ed6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109ed9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109edd:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109ee1:	7e b2                	jle    80109e95 <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
80109ee3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ee6:	f7 d0                	not    %eax
}
80109ee8:	c9                   	leave
80109ee9:	c3                   	ret

80109eea <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109eea:	f3 0f 1e fb          	endbr32
80109eee:	55                   	push   %ebp
80109eef:	89 e5                	mov    %esp,%ebp
80109ef1:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109ef4:	8b 45 08             	mov    0x8(%ebp),%eax
80109ef7:	83 c0 0e             	add    $0xe,%eax
80109efa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f00:	0f b6 00             	movzbl (%eax),%eax
80109f03:	0f b6 c0             	movzbl %al,%eax
80109f06:	83 e0 0f             	and    $0xf,%eax
80109f09:	c1 e0 02             	shl    $0x2,%eax
80109f0c:	89 c2                	mov    %eax,%edx
80109f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f11:	01 d0                	add    %edx,%eax
80109f13:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109f16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f19:	83 c0 14             	add    $0x14,%eax
80109f1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109f1f:	e8 ab 89 ff ff       	call   801028cf <kalloc>
80109f24:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109f27:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f31:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f35:	0f b6 c0             	movzbl %al,%eax
80109f38:	83 e0 02             	and    $0x2,%eax
80109f3b:	85 c0                	test   %eax,%eax
80109f3d:	74 3d                	je     80109f7c <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109f3f:	83 ec 0c             	sub    $0xc,%esp
80109f42:	6a 00                	push   $0x0
80109f44:	6a 12                	push   $0x12
80109f46:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f49:	50                   	push   %eax
80109f4a:	ff 75 e8             	push   -0x18(%ebp)
80109f4d:	ff 75 08             	push   0x8(%ebp)
80109f50:	e8 a2 01 00 00       	call   8010a0f7 <tcp_pkt_create>
80109f55:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109f58:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f5b:	83 ec 08             	sub    $0x8,%esp
80109f5e:	50                   	push   %eax
80109f5f:	ff 75 e8             	push   -0x18(%ebp)
80109f62:	e8 ff f0 ff ff       	call   80109066 <i8254_send>
80109f67:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109f6a:	a1 44 d3 18 80       	mov    0x8018d344,%eax
80109f6f:	83 c0 01             	add    $0x1,%eax
80109f72:	a3 44 d3 18 80       	mov    %eax,0x8018d344
80109f77:	e9 69 01 00 00       	jmp    8010a0e5 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f7f:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f83:	3c 18                	cmp    $0x18,%al
80109f85:	0f 85 10 01 00 00    	jne    8010a09b <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
80109f8b:	83 ec 04             	sub    $0x4,%esp
80109f8e:	6a 03                	push   $0x3
80109f90:	68 3e c7 10 80       	push   $0x8010c73e
80109f95:	ff 75 ec             	push   -0x14(%ebp)
80109f98:	e8 20 ae ff ff       	call   80104dbd <memcmp>
80109f9d:	83 c4 10             	add    $0x10,%esp
80109fa0:	85 c0                	test   %eax,%eax
80109fa2:	74 74                	je     8010a018 <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
80109fa4:	83 ec 0c             	sub    $0xc,%esp
80109fa7:	68 42 c7 10 80       	push   $0x8010c742
80109fac:	e8 5b 64 ff ff       	call   8010040c <cprintf>
80109fb1:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109fb4:	83 ec 0c             	sub    $0xc,%esp
80109fb7:	6a 00                	push   $0x0
80109fb9:	6a 10                	push   $0x10
80109fbb:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109fbe:	50                   	push   %eax
80109fbf:	ff 75 e8             	push   -0x18(%ebp)
80109fc2:	ff 75 08             	push   0x8(%ebp)
80109fc5:	e8 2d 01 00 00       	call   8010a0f7 <tcp_pkt_create>
80109fca:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109fcd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109fd0:	83 ec 08             	sub    $0x8,%esp
80109fd3:	50                   	push   %eax
80109fd4:	ff 75 e8             	push   -0x18(%ebp)
80109fd7:	e8 8a f0 ff ff       	call   80109066 <i8254_send>
80109fdc:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109fdf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fe2:	83 c0 36             	add    $0x36,%eax
80109fe5:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109fe8:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109feb:	50                   	push   %eax
80109fec:	ff 75 e0             	push   -0x20(%ebp)
80109fef:	6a 00                	push   $0x0
80109ff1:	6a 00                	push   $0x0
80109ff3:	e8 66 04 00 00       	call   8010a45e <http_proc>
80109ff8:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109ffb:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109ffe:	83 ec 0c             	sub    $0xc,%esp
8010a001:	50                   	push   %eax
8010a002:	6a 18                	push   $0x18
8010a004:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a007:	50                   	push   %eax
8010a008:	ff 75 e8             	push   -0x18(%ebp)
8010a00b:	ff 75 08             	push   0x8(%ebp)
8010a00e:	e8 e4 00 00 00       	call   8010a0f7 <tcp_pkt_create>
8010a013:	83 c4 20             	add    $0x20,%esp
8010a016:	eb 62                	jmp    8010a07a <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a018:	83 ec 0c             	sub    $0xc,%esp
8010a01b:	6a 00                	push   $0x0
8010a01d:	6a 10                	push   $0x10
8010a01f:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a022:	50                   	push   %eax
8010a023:	ff 75 e8             	push   -0x18(%ebp)
8010a026:	ff 75 08             	push   0x8(%ebp)
8010a029:	e8 c9 00 00 00       	call   8010a0f7 <tcp_pkt_create>
8010a02e:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a031:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a034:	83 ec 08             	sub    $0x8,%esp
8010a037:	50                   	push   %eax
8010a038:	ff 75 e8             	push   -0x18(%ebp)
8010a03b:	e8 26 f0 ff ff       	call   80109066 <i8254_send>
8010a040:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a043:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a046:	83 c0 36             	add    $0x36,%eax
8010a049:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a04c:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a04f:	50                   	push   %eax
8010a050:	ff 75 e4             	push   -0x1c(%ebp)
8010a053:	6a 00                	push   $0x0
8010a055:	6a 00                	push   $0x0
8010a057:	e8 02 04 00 00       	call   8010a45e <http_proc>
8010a05c:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a05f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a062:	83 ec 0c             	sub    $0xc,%esp
8010a065:	50                   	push   %eax
8010a066:	6a 18                	push   $0x18
8010a068:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a06b:	50                   	push   %eax
8010a06c:	ff 75 e8             	push   -0x18(%ebp)
8010a06f:	ff 75 08             	push   0x8(%ebp)
8010a072:	e8 80 00 00 00       	call   8010a0f7 <tcp_pkt_create>
8010a077:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a07a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a07d:	83 ec 08             	sub    $0x8,%esp
8010a080:	50                   	push   %eax
8010a081:	ff 75 e8             	push   -0x18(%ebp)
8010a084:	e8 dd ef ff ff       	call   80109066 <i8254_send>
8010a089:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a08c:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a091:	83 c0 01             	add    $0x1,%eax
8010a094:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a099:	eb 4a                	jmp    8010a0e5 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a09b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a09e:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a0a2:	3c 10                	cmp    $0x10,%al
8010a0a4:	75 3f                	jne    8010a0e5 <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a0a6:	a1 48 d3 18 80       	mov    0x8018d348,%eax
8010a0ab:	83 f8 01             	cmp    $0x1,%eax
8010a0ae:	75 35                	jne    8010a0e5 <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a0b0:	83 ec 0c             	sub    $0xc,%esp
8010a0b3:	6a 00                	push   $0x0
8010a0b5:	6a 01                	push   $0x1
8010a0b7:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a0ba:	50                   	push   %eax
8010a0bb:	ff 75 e8             	push   -0x18(%ebp)
8010a0be:	ff 75 08             	push   0x8(%ebp)
8010a0c1:	e8 31 00 00 00       	call   8010a0f7 <tcp_pkt_create>
8010a0c6:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a0c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a0cc:	83 ec 08             	sub    $0x8,%esp
8010a0cf:	50                   	push   %eax
8010a0d0:	ff 75 e8             	push   -0x18(%ebp)
8010a0d3:	e8 8e ef ff ff       	call   80109066 <i8254_send>
8010a0d8:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a0db:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
8010a0e2:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a0e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0e8:	83 ec 0c             	sub    $0xc,%esp
8010a0eb:	50                   	push   %eax
8010a0ec:	e8 40 87 ff ff       	call   80102831 <kfree>
8010a0f1:	83 c4 10             	add    $0x10,%esp
}
8010a0f4:	90                   	nop
8010a0f5:	c9                   	leave
8010a0f6:	c3                   	ret

8010a0f7 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a0f7:	f3 0f 1e fb          	endbr32
8010a0fb:	55                   	push   %ebp
8010a0fc:	89 e5                	mov    %esp,%ebp
8010a0fe:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a101:	8b 45 08             	mov    0x8(%ebp),%eax
8010a104:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a107:	8b 45 08             	mov    0x8(%ebp),%eax
8010a10a:	83 c0 0e             	add    $0xe,%eax
8010a10d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a110:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a113:	0f b6 00             	movzbl (%eax),%eax
8010a116:	0f b6 c0             	movzbl %al,%eax
8010a119:	83 e0 0f             	and    $0xf,%eax
8010a11c:	c1 e0 02             	shl    $0x2,%eax
8010a11f:	89 c2                	mov    %eax,%edx
8010a121:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a124:	01 d0                	add    %edx,%eax
8010a126:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a129:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a12c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a12f:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a132:	83 c0 0e             	add    $0xe,%eax
8010a135:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a138:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a13b:	83 c0 14             	add    $0x14,%eax
8010a13e:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a141:	8b 45 18             	mov    0x18(%ebp),%eax
8010a144:	8d 50 36             	lea    0x36(%eax),%edx
8010a147:	8b 45 10             	mov    0x10(%ebp),%eax
8010a14a:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a14c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a14f:	8d 50 06             	lea    0x6(%eax),%edx
8010a152:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a155:	83 ec 04             	sub    $0x4,%esp
8010a158:	6a 06                	push   $0x6
8010a15a:	52                   	push   %edx
8010a15b:	50                   	push   %eax
8010a15c:	e8 b8 ac ff ff       	call   80104e19 <memmove>
8010a161:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a164:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a167:	83 c0 06             	add    $0x6,%eax
8010a16a:	83 ec 04             	sub    $0x4,%esp
8010a16d:	6a 06                	push   $0x6
8010a16f:	68 68 d0 18 80       	push   $0x8018d068
8010a174:	50                   	push   %eax
8010a175:	e8 9f ac ff ff       	call   80104e19 <memmove>
8010a17a:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a17d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a180:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a184:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a187:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a18b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a18e:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a191:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a194:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a198:	8b 45 18             	mov    0x18(%ebp),%eax
8010a19b:	83 c0 28             	add    $0x28,%eax
8010a19e:	0f b7 c0             	movzwl %ax,%eax
8010a1a1:	83 ec 0c             	sub    $0xc,%esp
8010a1a4:	50                   	push   %eax
8010a1a5:	e8 6f f8 ff ff       	call   80109a19 <H2N_ushort>
8010a1aa:	83 c4 10             	add    $0x10,%esp
8010a1ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a1b0:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a1b4:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a1bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1be:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a1c2:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a1c9:	83 c0 01             	add    $0x1,%eax
8010a1cc:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a1d2:	83 ec 0c             	sub    $0xc,%esp
8010a1d5:	6a 00                	push   $0x0
8010a1d7:	e8 3d f8 ff ff       	call   80109a19 <H2N_ushort>
8010a1dc:	83 c4 10             	add    $0x10,%esp
8010a1df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a1e2:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a1e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1e9:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a1ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1f0:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a1f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1f7:	83 c0 0c             	add    $0xc,%eax
8010a1fa:	83 ec 04             	sub    $0x4,%esp
8010a1fd:	6a 04                	push   $0x4
8010a1ff:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a204:	50                   	push   %eax
8010a205:	e8 0f ac ff ff       	call   80104e19 <memmove>
8010a20a:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a20d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a210:	8d 50 0c             	lea    0xc(%eax),%edx
8010a213:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a216:	83 c0 10             	add    $0x10,%eax
8010a219:	83 ec 04             	sub    $0x4,%esp
8010a21c:	6a 04                	push   $0x4
8010a21e:	52                   	push   %edx
8010a21f:	50                   	push   %eax
8010a220:	e8 f4 ab ff ff       	call   80104e19 <memmove>
8010a225:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a228:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a22b:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a231:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a234:	83 ec 0c             	sub    $0xc,%esp
8010a237:	50                   	push   %eax
8010a238:	e8 ec f8 ff ff       	call   80109b29 <ipv4_chksum>
8010a23d:	83 c4 10             	add    $0x10,%esp
8010a240:	0f b7 c0             	movzwl %ax,%eax
8010a243:	83 ec 0c             	sub    $0xc,%esp
8010a246:	50                   	push   %eax
8010a247:	e8 cd f7 ff ff       	call   80109a19 <H2N_ushort>
8010a24c:	83 c4 10             	add    $0x10,%esp
8010a24f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a252:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a256:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a259:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a25d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a260:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a263:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a266:	0f b7 10             	movzwl (%eax),%edx
8010a269:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a26c:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a270:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a275:	83 ec 0c             	sub    $0xc,%esp
8010a278:	50                   	push   %eax
8010a279:	e8 c1 f7 ff ff       	call   80109a3f <H2N_uint>
8010a27e:	83 c4 10             	add    $0x10,%esp
8010a281:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a284:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a287:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a28a:	8b 40 04             	mov    0x4(%eax),%eax
8010a28d:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a293:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a296:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a299:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a29c:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a2a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2a3:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a2a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2aa:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a2ae:	8b 45 14             	mov    0x14(%ebp),%eax
8010a2b1:	89 c2                	mov    %eax,%edx
8010a2b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2b6:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a2b9:	83 ec 0c             	sub    $0xc,%esp
8010a2bc:	68 90 38 00 00       	push   $0x3890
8010a2c1:	e8 53 f7 ff ff       	call   80109a19 <H2N_ushort>
8010a2c6:	83 c4 10             	add    $0x10,%esp
8010a2c9:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a2cc:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a2d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2d3:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a2d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2dc:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a2e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2e5:	83 ec 0c             	sub    $0xc,%esp
8010a2e8:	50                   	push   %eax
8010a2e9:	e8 1f 00 00 00       	call   8010a30d <tcp_chksum>
8010a2ee:	83 c4 10             	add    $0x10,%esp
8010a2f1:	83 c0 08             	add    $0x8,%eax
8010a2f4:	0f b7 c0             	movzwl %ax,%eax
8010a2f7:	83 ec 0c             	sub    $0xc,%esp
8010a2fa:	50                   	push   %eax
8010a2fb:	e8 19 f7 ff ff       	call   80109a19 <H2N_ushort>
8010a300:	83 c4 10             	add    $0x10,%esp
8010a303:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a306:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a30a:	90                   	nop
8010a30b:	c9                   	leave
8010a30c:	c3                   	ret

8010a30d <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a30d:	f3 0f 1e fb          	endbr32
8010a311:	55                   	push   %ebp
8010a312:	89 e5                	mov    %esp,%ebp
8010a314:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a317:	8b 45 08             	mov    0x8(%ebp),%eax
8010a31a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a31d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a320:	83 c0 14             	add    $0x14,%eax
8010a323:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a326:	83 ec 04             	sub    $0x4,%esp
8010a329:	6a 04                	push   $0x4
8010a32b:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a330:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a333:	50                   	push   %eax
8010a334:	e8 e0 aa ff ff       	call   80104e19 <memmove>
8010a339:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a33c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a33f:	83 c0 0c             	add    $0xc,%eax
8010a342:	83 ec 04             	sub    $0x4,%esp
8010a345:	6a 04                	push   $0x4
8010a347:	50                   	push   %eax
8010a348:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a34b:	83 c0 04             	add    $0x4,%eax
8010a34e:	50                   	push   %eax
8010a34f:	e8 c5 aa ff ff       	call   80104e19 <memmove>
8010a354:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a357:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a35b:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a35f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a362:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a366:	0f b7 c0             	movzwl %ax,%eax
8010a369:	83 ec 0c             	sub    $0xc,%esp
8010a36c:	50                   	push   %eax
8010a36d:	e8 81 f6 ff ff       	call   801099f3 <N2H_ushort>
8010a372:	83 c4 10             	add    $0x10,%esp
8010a375:	83 e8 14             	sub    $0x14,%eax
8010a378:	0f b7 c0             	movzwl %ax,%eax
8010a37b:	83 ec 0c             	sub    $0xc,%esp
8010a37e:	50                   	push   %eax
8010a37f:	e8 95 f6 ff ff       	call   80109a19 <H2N_ushort>
8010a384:	83 c4 10             	add    $0x10,%esp
8010a387:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a38b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a392:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a395:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a398:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a39f:	eb 33                	jmp    8010a3d4 <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a3a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3a4:	01 c0                	add    %eax,%eax
8010a3a6:	89 c2                	mov    %eax,%edx
8010a3a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3ab:	01 d0                	add    %edx,%eax
8010a3ad:	0f b6 00             	movzbl (%eax),%eax
8010a3b0:	0f b6 c0             	movzbl %al,%eax
8010a3b3:	c1 e0 08             	shl    $0x8,%eax
8010a3b6:	89 c2                	mov    %eax,%edx
8010a3b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3bb:	01 c0                	add    %eax,%eax
8010a3bd:	8d 48 01             	lea    0x1(%eax),%ecx
8010a3c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3c3:	01 c8                	add    %ecx,%eax
8010a3c5:	0f b6 00             	movzbl (%eax),%eax
8010a3c8:	0f b6 c0             	movzbl %al,%eax
8010a3cb:	01 d0                	add    %edx,%eax
8010a3cd:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a3d0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a3d4:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a3d8:	7e c7                	jle    8010a3a1 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a3da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a3e0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a3e7:	eb 33                	jmp    8010a41c <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a3e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3ec:	01 c0                	add    %eax,%eax
8010a3ee:	89 c2                	mov    %eax,%edx
8010a3f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3f3:	01 d0                	add    %edx,%eax
8010a3f5:	0f b6 00             	movzbl (%eax),%eax
8010a3f8:	0f b6 c0             	movzbl %al,%eax
8010a3fb:	c1 e0 08             	shl    $0x8,%eax
8010a3fe:	89 c2                	mov    %eax,%edx
8010a400:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a403:	01 c0                	add    %eax,%eax
8010a405:	8d 48 01             	lea    0x1(%eax),%ecx
8010a408:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a40b:	01 c8                	add    %ecx,%eax
8010a40d:	0f b6 00             	movzbl (%eax),%eax
8010a410:	0f b6 c0             	movzbl %al,%eax
8010a413:	01 d0                	add    %edx,%eax
8010a415:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a418:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a41c:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a420:	0f b7 c0             	movzwl %ax,%eax
8010a423:	83 ec 0c             	sub    $0xc,%esp
8010a426:	50                   	push   %eax
8010a427:	e8 c7 f5 ff ff       	call   801099f3 <N2H_ushort>
8010a42c:	83 c4 10             	add    $0x10,%esp
8010a42f:	66 d1 e8             	shr    $1,%ax
8010a432:	0f b7 c0             	movzwl %ax,%eax
8010a435:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a438:	7c af                	jl     8010a3e9 <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a43a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a43d:	c1 e8 10             	shr    $0x10,%eax
8010a440:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a443:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a446:	f7 d0                	not    %eax
}
8010a448:	c9                   	leave
8010a449:	c3                   	ret

8010a44a <tcp_fin>:

void tcp_fin(){
8010a44a:	f3 0f 1e fb          	endbr32
8010a44e:	55                   	push   %ebp
8010a44f:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a451:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a458:	00 00 00 
}
8010a45b:	90                   	nop
8010a45c:	5d                   	pop    %ebp
8010a45d:	c3                   	ret

8010a45e <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a45e:	f3 0f 1e fb          	endbr32
8010a462:	55                   	push   %ebp
8010a463:	89 e5                	mov    %esp,%ebp
8010a465:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a468:	8b 45 10             	mov    0x10(%ebp),%eax
8010a46b:	83 ec 04             	sub    $0x4,%esp
8010a46e:	6a 00                	push   $0x0
8010a470:	68 4b c7 10 80       	push   $0x8010c74b
8010a475:	50                   	push   %eax
8010a476:	e8 65 00 00 00       	call   8010a4e0 <http_strcpy>
8010a47b:	83 c4 10             	add    $0x10,%esp
8010a47e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a481:	8b 45 10             	mov    0x10(%ebp),%eax
8010a484:	83 ec 04             	sub    $0x4,%esp
8010a487:	ff 75 f4             	push   -0xc(%ebp)
8010a48a:	68 5e c7 10 80       	push   $0x8010c75e
8010a48f:	50                   	push   %eax
8010a490:	e8 4b 00 00 00       	call   8010a4e0 <http_strcpy>
8010a495:	83 c4 10             	add    $0x10,%esp
8010a498:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a49b:	8b 45 10             	mov    0x10(%ebp),%eax
8010a49e:	83 ec 04             	sub    $0x4,%esp
8010a4a1:	ff 75 f4             	push   -0xc(%ebp)
8010a4a4:	68 79 c7 10 80       	push   $0x8010c779
8010a4a9:	50                   	push   %eax
8010a4aa:	e8 31 00 00 00       	call   8010a4e0 <http_strcpy>
8010a4af:	83 c4 10             	add    $0x10,%esp
8010a4b2:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a4b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4b8:	83 e0 01             	and    $0x1,%eax
8010a4bb:	85 c0                	test   %eax,%eax
8010a4bd:	74 11                	je     8010a4d0 <http_proc+0x72>
    char *payload = (char *)send;
8010a4bf:	8b 45 10             	mov    0x10(%ebp),%eax
8010a4c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a4c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a4c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4cb:	01 d0                	add    %edx,%eax
8010a4cd:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a4d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a4d3:	8b 45 14             	mov    0x14(%ebp),%eax
8010a4d6:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a4d8:	e8 6d ff ff ff       	call   8010a44a <tcp_fin>
}
8010a4dd:	90                   	nop
8010a4de:	c9                   	leave
8010a4df:	c3                   	ret

8010a4e0 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a4e0:	f3 0f 1e fb          	endbr32
8010a4e4:	55                   	push   %ebp
8010a4e5:	89 e5                	mov    %esp,%ebp
8010a4e7:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a4ea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a4f1:	eb 20                	jmp    8010a513 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a4f3:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a4f6:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a4f9:	01 d0                	add    %edx,%eax
8010a4fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a4fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a501:	01 ca                	add    %ecx,%edx
8010a503:	89 d1                	mov    %edx,%ecx
8010a505:	8b 55 08             	mov    0x8(%ebp),%edx
8010a508:	01 ca                	add    %ecx,%edx
8010a50a:	0f b6 00             	movzbl (%eax),%eax
8010a50d:	88 02                	mov    %al,(%edx)
    i++;
8010a50f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a513:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a516:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a519:	01 d0                	add    %edx,%eax
8010a51b:	0f b6 00             	movzbl (%eax),%eax
8010a51e:	84 c0                	test   %al,%al
8010a520:	75 d1                	jne    8010a4f3 <http_strcpy+0x13>
  }
  return i;
8010a522:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a525:	c9                   	leave
8010a526:	c3                   	ret

8010a527 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a527:	f3 0f 1e fb          	endbr32
8010a52b:	55                   	push   %ebp
8010a52c:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a52e:	c7 05 50 d3 18 80 a2 	movl   $0x8010f5a2,0x8018d350
8010a535:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a538:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a53d:	c1 e8 09             	shr    $0x9,%eax
8010a540:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a545:	90                   	nop
8010a546:	5d                   	pop    %ebp
8010a547:	c3                   	ret

8010a548 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a548:	f3 0f 1e fb          	endbr32
8010a54c:	55                   	push   %ebp
8010a54d:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a54f:	90                   	nop
8010a550:	5d                   	pop    %ebp
8010a551:	c3                   	ret

8010a552 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a552:	f3 0f 1e fb          	endbr32
8010a556:	55                   	push   %ebp
8010a557:	89 e5                	mov    %esp,%ebp
8010a559:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a55c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a55f:	83 c0 0c             	add    $0xc,%eax
8010a562:	83 ec 0c             	sub    $0xc,%esp
8010a565:	50                   	push   %eax
8010a566:	e8 bf a4 ff ff       	call   80104a2a <holdingsleep>
8010a56b:	83 c4 10             	add    $0x10,%esp
8010a56e:	85 c0                	test   %eax,%eax
8010a570:	75 0d                	jne    8010a57f <iderw+0x2d>
    panic("iderw: buf not locked");
8010a572:	83 ec 0c             	sub    $0xc,%esp
8010a575:	68 8a c7 10 80       	push   $0x8010c78a
8010a57a:	e8 46 60 ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a57f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a582:	8b 00                	mov    (%eax),%eax
8010a584:	83 e0 06             	and    $0x6,%eax
8010a587:	83 f8 02             	cmp    $0x2,%eax
8010a58a:	75 0d                	jne    8010a599 <iderw+0x47>
    panic("iderw: nothing to do");
8010a58c:	83 ec 0c             	sub    $0xc,%esp
8010a58f:	68 a0 c7 10 80       	push   $0x8010c7a0
8010a594:	e8 2c 60 ff ff       	call   801005c5 <panic>
  if(b->dev != 1)
8010a599:	8b 45 08             	mov    0x8(%ebp),%eax
8010a59c:	8b 40 04             	mov    0x4(%eax),%eax
8010a59f:	83 f8 01             	cmp    $0x1,%eax
8010a5a2:	74 0d                	je     8010a5b1 <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a5a4:	83 ec 0c             	sub    $0xc,%esp
8010a5a7:	68 b5 c7 10 80       	push   $0x8010c7b5
8010a5ac:	e8 14 60 ff ff       	call   801005c5 <panic>
  if(b->blockno >= disksize)
8010a5b1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5b4:	8b 40 08             	mov    0x8(%eax),%eax
8010a5b7:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a5bd:	39 d0                	cmp    %edx,%eax
8010a5bf:	72 0d                	jb     8010a5ce <iderw+0x7c>
    panic("iderw: block out of range");
8010a5c1:	83 ec 0c             	sub    $0xc,%esp
8010a5c4:	68 d3 c7 10 80       	push   $0x8010c7d3
8010a5c9:	e8 f7 5f ff ff       	call   801005c5 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a5ce:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a5d4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5d7:	8b 40 08             	mov    0x8(%eax),%eax
8010a5da:	c1 e0 09             	shl    $0x9,%eax
8010a5dd:	01 d0                	add    %edx,%eax
8010a5df:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a5e2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5e5:	8b 00                	mov    (%eax),%eax
8010a5e7:	83 e0 04             	and    $0x4,%eax
8010a5ea:	85 c0                	test   %eax,%eax
8010a5ec:	74 2b                	je     8010a619 <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a5ee:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5f1:	8b 00                	mov    (%eax),%eax
8010a5f3:	83 e0 fb             	and    $0xfffffffb,%eax
8010a5f6:	89 c2                	mov    %eax,%edx
8010a5f8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5fb:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a5fd:	8b 45 08             	mov    0x8(%ebp),%eax
8010a600:	83 c0 5c             	add    $0x5c,%eax
8010a603:	83 ec 04             	sub    $0x4,%esp
8010a606:	68 00 02 00 00       	push   $0x200
8010a60b:	50                   	push   %eax
8010a60c:	ff 75 f4             	push   -0xc(%ebp)
8010a60f:	e8 05 a8 ff ff       	call   80104e19 <memmove>
8010a614:	83 c4 10             	add    $0x10,%esp
8010a617:	eb 1a                	jmp    8010a633 <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a619:	8b 45 08             	mov    0x8(%ebp),%eax
8010a61c:	83 c0 5c             	add    $0x5c,%eax
8010a61f:	83 ec 04             	sub    $0x4,%esp
8010a622:	68 00 02 00 00       	push   $0x200
8010a627:	ff 75 f4             	push   -0xc(%ebp)
8010a62a:	50                   	push   %eax
8010a62b:	e8 e9 a7 ff ff       	call   80104e19 <memmove>
8010a630:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a633:	8b 45 08             	mov    0x8(%ebp),%eax
8010a636:	8b 00                	mov    (%eax),%eax
8010a638:	83 c8 02             	or     $0x2,%eax
8010a63b:	89 c2                	mov    %eax,%edx
8010a63d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a640:	89 10                	mov    %edx,(%eax)
}
8010a642:	90                   	nop
8010a643:	c9                   	leave
8010a644:	c3                   	ret
